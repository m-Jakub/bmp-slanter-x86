#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// Assembly function declaration
extern void slantbmp1(void *img, int width, int height);

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
    uint8_t header[54];
    size_t header_read = fread(header, sizeof(uint8_t), 54, file);
    if (header_read != 54)
    {
        fprintf(stderr, "Error reading BMP header\n");
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

    // Call assembly function to process the image
    slantbmp1(img, width, abs(height));

    // Write the modified image to the output file
    file = fopen(output_file, "wb");
    if (!file)
    {
        perror("Error opening output file");
        free(img);
        return 1;
    }

    // Write header
    size_t header_written = fwrite(header, sizeof(uint8_t), 54, file);
    if (header_written != 54)
    {
        fprintf(stderr, "Error writing BMP header to output file\n");
        free(img);
        fclose(file);
        return 1;
    }

    // Write image data
    size_t img_written = fwrite(img, sizeof(uint8_t), img_size, file);
    if (img_written != img_size)
    {
        fprintf(stderr, "Error writing BMP data to output file\n");
        free(img);
        fclose(file);
        return 1;
    }
    fclose(file);

    printf("Image slanted successfully! Saved to %s\n", output_file);

    free(img);
    return 0;
}