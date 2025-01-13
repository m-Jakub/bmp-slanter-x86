#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// 14. void slantbmp1(void *img, int width, int height)
// Slant a 1 bpp .BMP image so that each line of image is rotated (wrapping around the edge)
// to the right by a number of pixels equal to the line number, assuming that topmost line is
// assigned number 0. Handle any image width properly.

// Assembly function declaration
extern void slantbmp1(void *img, int width, int height, int stride);
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

	// Read BMP header
	uint8_t header[62];
	size_t header_read = fread(header, sizeof(uint8_t), 62, file);
	if (header_read != 62)
	{
		fprintf(stderr, "Error reading complete BMP header\n");
		fclose(file);
		return 1;
	}

	// Validate BMP format
	if (header[0] != 'B' || header[1] != 'M')
	{
		fprintf(stderr, "Invalid BMP file\n");
		fclose(file);
		return 1;
	}

	// Extract image dimensions and bit depth using memcpy for safety
	int width_header;
	int height;
	short bit_depth;
	int pixel_data_offset;

	memcpy(&width_header, &header[18], sizeof(int));
	memcpy(&height, &header[22], sizeof(int));
	memcpy(&bit_depth, &header[28], sizeof(short));
	memcpy(&pixel_data_offset, &header[10], sizeof(int));

	// Display extracted information
	printf("Header Width: %d pixels\n", width_header);
	printf("Header Height: %d pixels\n", height);
	printf("Bit Depth: %d bits per pixel\n", bit_depth);
	printf("Pixel Data Offset: %d bytes\n", pixel_data_offset);

	if (bit_depth != 1)
	{
		fprintf(stderr, "Only 1 bpp BMP images are supported\n");
		fclose(file);
		return 1;
	}

	// Use the width from the BMP header
	int width = width_header;

	// Calculate stride (padded row size)
	int stride = ((width + 31) / 32) * 4;
	printf("Calculated Stride: %d bytes\n", stride);

	// Allocate memory for the image
	size_t img_size = stride * (size_t)abs(height);
	printf("Image Size: %zu bytes\n", img_size);
	uint8_t *img = malloc(img_size);
	if (!img)
	{
		perror("Error allocating memory for image");
		fclose(file);
		return 1;
	}

	// Seek to pixel data offset
	if (fseek(file, pixel_data_offset, SEEK_SET) != 0)
	{
		fprintf(stderr, "Error seeking to pixel data\n");
		free(img);
		fclose(file);
		return 1;
	}

	// Read image data
	size_t img_read = fread(img, sizeof(uint8_t), img_size, file);
	if (img_read != img_size)
	{
		fprintf(stderr, "Error reading BMP data\n");
		free(img);
		fclose(file);
		return 1;
	}
	fclose(file);

	// Debug: Inspect every height/10th row of pixel data
	// inspect_rows(img, height, stride, img_size);

	// Call assembly function to process the image
	slantbmp1(img, width, height, stride);

	// Open the output BMP file for writing
	FILE *outfile = fopen(output_file, "wb");
	if (!outfile)
	{
		perror("Error opening output file");
		free(img);
		return 1;
	}

	// Write the complete 62-byte header
	size_t header_written = fwrite(header, sizeof(uint8_t), 62, outfile);
	if (header_written != 62)
	{
		fprintf(stderr, "Error writing BMP header to output file\n");
		free(img);
		fclose(outfile);
		return 1;
	}

	// Write the pixel data
	size_t img_written = fwrite(img, sizeof(uint8_t), img_size, outfile);
	if (img_written != img_size)
	{
		fprintf(stderr, "Error writing BMP pixel data to output file\n");
		free(img);
		fclose(outfile);
		return 1;
	}

	fclose(outfile);

	printf("Image processed successfully! Saved to %s\n", output_file);

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