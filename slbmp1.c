#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// Assembly function declaration
extern void slantbmp1(void *img, uint32_t width, uint32_t height, uint32_t stride);
void inspect_rows(uint8_t *img, uint32_t height, uint32_t stride);

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        fprintf(stderr, "Usage: %s <input.bmp> <output.bmp>\n", argv[0]);
        return 1;
    }

    const char *input_file = argv[1];
    const char *output_file = argv[2];

    uint32_t width, height, bits_per_pixel, stride, img_size;

    // Open and read BMP file
    FILE *file = fopen(input_file, "rb");
    if (!file)
    {
        perror("Error opening input file");
        return 1;
    }

    // Read BMP Header (14 bytes) and DIB Header (40 bytes) - Total 54 bytes
    unsigned char header[54];
    if (fread(header, sizeof(unsigned char), 54, file) != 54)
    {
        fprintf(stderr, "Error reading BMP header\n");
        fclose(file);
        return 1;
    }

    // Validate BMP Signature
    if (header[0] != 'B' || header[1] != 'M')
    {
        fprintf(stderr, "Invalid BMP file: Incorrect signature\n");
        fclose(file);
        return 1;
    }

    // Extract pixel data offset (bytes 10-13)
    uint32_t pixel_data_offset = *(uint32_t*)&header[10];
    printf("Pixel Data Offset: %u bytes\n", pixel_data_offset);

    // Extract width (bytes 18-21) and height (bytes 22-25)
    width = *(uint32_t*)&header[18];
    height = *(int32_t*)&header[22]; // height can be negative for top-down BMP
    printf("Width: %u pixels\n", width);
    printf("Height: %d pixels\n", height);

    // Extract bits per pixel (bytes 28-29)
    bits_per_pixel = *(uint16_t*)&header[28];
    printf("Bits per Pixel: %u\n", bits_per_pixel);

    // Validate bits per pixel
    if (bits_per_pixel != 1)
    {
        fprintf(stderr, "Unsupported BMP format: %u bits per pixel\n", bits_per_pixel);
        fclose(file);
        return 1;
    }

    // Calculate raw stride (bytes per row without padding)
    int raw_stride = (width + 7) / 8;

    // Calculate padding to align stride to 4-byte boundary
    uint32_t padding = (4 - (raw_stride % 4)) % 4;

    // Total stride including padding
    stride = raw_stride + padding;
    printf("Calculated Stride: %u bytes\n", stride);

    // Calculate image size
    img_size = stride * (uint32_t)(height);
    printf("Image Size: %u bytes\n", img_size);

    // Allocate memory for img data
    uint8_t *img = malloc(img_size);
    if (!img)
    {
        perror("Memory allocation failed for image data");
        fclose(file);
        return 1;
    }

    // Seek to the start of the bitmap data
    if (fseek(file, pixel_data_offset, SEEK_SET) != 0)
    {
        fprintf(stderr, "Error seeking to pixel data\n");
        free(img);
        fclose(file);
        return 1;
    }

    // Read the bitmap into the allocated memory row by row to handle padding correctly
    for (uint32_t row = 0; row < (uint32_t)(height); row++)
    {
        size_t bytes_read = fread(img + row * stride, sizeof(uint8_t), stride, file);
        if (bytes_read != stride)
        {
            fprintf(stderr, "Error reading BMP data at row %u: Expected %u bytes, got %zu bytes\n", row, stride, bytes_read);
            free(img);
            fclose(file);
            return 1;
        }
    }

    fclose(file);

    // Debug: Inspect every height/10th row of pixel data
    inspect_rows(img, (height), stride);

    // Call assembly function to process the image
    slantbmp1(img, width, (height), stride);

    // Open the output BMP file for writing
    FILE *outfile = fopen(output_file, "wb");
    if (!outfile)
    {
        perror("Error opening output file");
        free(img);
        return 1;
    }

    // Update image size in the header (bytes 34-37)
    *(uint32_t*)&header[34] = img_size;

    // Update file size in the header (bytes 2-5)
    *(uint32_t*)&header[2] = 54 + img_size;

    // Write the 54-byte BMP header to the output file
    size_t header_written = fwrite(header, sizeof(uint8_t), 54, outfile);
    if (header_written != 54)
    {
        fprintf(stderr, "Error writing BMP header to output file\n");
        free(img);
        fclose(outfile);
        return 1;
    }

    // Write the pixel data row by row to handle padding correctly
    for (uint32_t row = 0; row < (uint32_t)(height); row++)
    {
        size_t bytes_written = fwrite(img + row * stride, sizeof(uint8_t), stride, outfile);
        if (bytes_written != stride)
        {
            fprintf(stderr, "Error writing BMP pixel data at row %u: Expected %u bytes, wrote %zu bytes\n", row, stride, bytes_written);
            free(img);
            fclose(outfile);
            return 1;
        }
    }

    fclose(outfile);

    printf("Image processed successfully! Saved to %s\n", output_file);

    free(img);
    return 0;
}

void inspect_rows(uint8_t *img, uint32_t height, uint32_t stride)
{
    printf("\nInspecting every %u-th row of pixel data:\n", height / 10);
    for (uint32_t row = 0; row < height; row += height / 10)
    {
        printf("Row %u:\n", row);
        for (uint32_t i = 0; i < stride; i++)
        {
            printf("%02X ", img[row * stride + i]);
        }
        printf("\n");
    }
    printf("\n");
}