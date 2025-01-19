#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// 14. void slantbmp1(void *img, int width, int height)
// Slant a 1 bpp .BMP image so that each line of image is rotated (wrapping around the edge)
// to the right by a number of pixels equal to the line number, assuming that topmost line is
// assigned number 0. Handle any image width properly.
// Assembly function declaration
extern void slantbmp1(void *img, uint32_t width, uint32_t height, uint32_t stride);
void inspect_rows(uint8_t *img, int height, int stride, size_t img_size);

int main(int argc, char *argv[])
{
	if (argc != 3)
	{
		fprintf(stderr, "Usage: %s <input.bmp> <output.bmp>\n", argv[0]);
		return 1;
	}

	const char *input_file = argv[1];
	const char *output_file = argv[2];

	// Open and read BMP file
	FILE *file = fopen(input_file, "rb");
	if (!file)
	{
		perror("Error opening input file");
		return 1;
	}

	// Read initial 54-byte BMP header
	uint8_t header[54];
	size_t header_read = fread(header, sizeof(uint8_t), 54, file);
	if (header_read != 54)
	{
		fprintf(stderr, "Error reading complete BMP header\n");
		fclose(file);
		return 1;
	}

	// Print Header for Debugging
	for (int i = 0; i < 54; i++)
	{
		printf("Header[%d]: %d\n", i, header[i]);
	}

	// Validate BMP format
	if (header[0] != 'B' || header[1] != 'M')
	{
		fprintf(stderr, "Invalid BMP file\n");
		fclose(file);
		return 1;
	}

	// Extract offset to pixel data
	uint32_t bfOffBits;
	memcpy(&bfOffBits, &header[10], sizeof(uint32_t));
	printf("Pixel Data Offset: %d\n", bfOffBits);

	// Read remaining header data
	size_t remaining_header_size = bfOffBits - 54;
	uint8_t *header_remaining = NULL;
	if (remaining_header_size > 0)
	{
		header_remaining = malloc(remaining_header_size);
		if (!header_remaining)
		{
			perror("Error allocating memory for remaining header");
			fclose(file);
			return 1;
		}

		size_t remaining_header_read = fread(header_remaining, sizeof(uint8_t), remaining_header_size, file);
		if (remaining_header_read != remaining_header_size)
		{
			fprintf(stderr, "Error reading remaining header data\n");
			free(header_remaining);
			fclose(file);
			return 1;
		}
	}

	// Etract imade dimensions and bit depth
	uint32_t width, height;
	uint16_t bit_depth;

	memcpy(&width, &header[18], sizeof(uint32_t));
	memcpy(&height, &header[22], sizeof(uint32_t));
	memcpy(&bit_depth, &header[28], sizeof(uint16_t));

	// Display extracted information
	printf("Header Width: %d pixels\n", width);
	printf("Header Height: %d pixels\n", height);
	printf("Bit Depth: %d bits per pixel\n", bit_depth);

	if (bit_depth != 1)
	{
		fprintf(stderr, "Only 1 bpp BMP images are supported\n");
		fclose(file);
		return 1;
	}

	// Calculate stride (padded row size)
	int stride = ((width + 31u) / 32u) * 4u;
	printf("Calculated Stride: %d bytes\n", stride);

	// Calculate image size
	size_t img_size = stride * height;
	printf("Image Size: %zu bytes\n", img_size);

	// Allocate memory for the image
	uint8_t *img = malloc(img_size);
	if (!img)
	{
		perror("Error allocating memory for image");
		if (header_remaining)
			free(header_remaining);
		fclose(file);
		return 1;
	}

	// Seek to pixel data offset
	if (fseek(file, bfOffBits, SEEK_SET) != 0)
	{
		fprintf(stderr, "Error seeking to pixel data\n");
		if (img)
			free(img);
		if (header_remaining)
			free(header_remaining);
		fclose(file);
		return 1;
	}

	// Read image data
	size_t img_read = fread(img, sizeof(uint8_t), img_size, file);
	if (img_read != img_size)
	{
		fprintf(stderr, "Error reading BMP data\n");
		if (img)
			free(img);
		if (header_remaining)
			free(header_remaining);
		fclose(file);
		return 1;
	}
	fclose(file);

	// Debug: Inspect every height/10th row of pixel data
	// inspect_rows(img, height, stride, img_size);

	// Print pixel data for all rows (for debugging)
	for (int row = 0; row < 2; row++)
	{
		printf("Pixel Data for Row %d:\n", row);
		for (int i = 0; i < stride; i++)
		{
			printf("%02X ", img[row * stride + i]);
		}
		printf("\n");
	}

	// Call assembly function to process the image
	slantbmp1(img, width, height, stride);

	// Open the output BMP file for writing
	FILE *outfile = fopen(output_file, "wb");
	if (!outfile)
	{
		perror("Error opening output file");
		if (img)
			free(img);
		if (header_remaining)
			free(header_remaining);
		return 1;
	}

	// Write the complete 54-byte header
	size_t header_written = fwrite(header, sizeof(uint8_t), 54, outfile);
	if (header_written != 54)
	{
		fprintf(stderr, "Error writing BMP (54 bytes) header to output file\n");
		if (img)
			free(img);
		if (header_remaining)
			free(header_remaining);
		fclose(outfile);
		return 1;
	}

	// Write any remaining header data
	if (remaining_header_size > 0)
	{
		size_t remaining_header_written = fwrite(header_remaining, sizeof(uint8_t), remaining_header_size, outfile);
		if (remaining_header_written != remaining_header_size)
		{
			fprintf(stderr, "Error writing BMP remaining header data to output file\n");
			if (img)
				free(img);
			free(header_remaining);
			fclose(outfile);
			return 1;
		}
		free(header_remaining);
	}

	// Write the pixel data
	size_t img_written = fwrite(img, sizeof(uint8_t), img_size, outfile);
	if (img_written != img_size)
	{
		fprintf(stderr, "Error writing BMP pixel data to output file\n");
		if (img)
			free(img);
		fclose(outfile);
		return 1;
	}

	fclose(outfile);

	printf("Image processed successfully! Saved to %s\n", output_file);

	if (img)
		free(img);
	return 0;
}

void inspect_rows(uint8_t *img, int height, int stride, size_t img_size)
{
	int step = height / 10;
	if (step == 0)
		step = 1;

	printf("Inspecting pixel data at every %dth row:\n", step);
	for (int row = 0; row < height; row += step)
	{
		int offset = row * stride;
		printf("Row %d (offset %d): ", row, offset);
		for (int i = 0; i < 16 && (offset + i) < (int)img_size; i++) // Display up to 16 bytes per row
		{
			printf("%02X ", img[offset + i]);
		}
		printf("\n");
	}
}