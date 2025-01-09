#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stddef.h>

// Assembly function declaration
extern void slantbmp1(void *img, int stride, int height);

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <input.bmp> <output.bmp>\n", argv[0]);
        return 1;
    }

    const char *input_file = argv[1];
    const char *output_file = argv[2];

    // Open and read BMP file
    FILE *file = fopen(input_file, "rb");
    if (!file) {
        perror("Error opening input file");
        return 1;
    }

    // Read BMP header
    uint8_t header[54];
    if (fread(header, sizeof(uint8_t), 54, file) != 54) {
        fprintf(stderr, "Error reading BMP header\n");
        fclose(file);
        return 1;
    }

    // Validate BMP format
    if (header[0] != 'B' || header[1] != 'M') {
        fprintf(stderr, "Invalid BMP file\n");
        fclose(file);
        return 1;
    }

    // Get image dimensions
    int width = *(int *)&header[18];    // Extract width from header
    int height = *(int *)&header[22];   // Extract height from header
    int bit_depth = *(short *)&header[28];
    
    printf("Image Width: %d\n", width);
    printf("Image Height: %d\n", height);
    printf("Bit Depth: %d\n", bit_depth);

    if (bit_depth != 1) {
        fprintf(stderr, "Only 1 bpp BMP images are supported\n");
        fclose(file);
        return 1;
    }

    // Calculate stride (padded row size)
    size_t stride = ((size_t)(width + 31) / 32) * 4;
    printf("Calculated Stride: %zu bytes\n", stride);

    // Allocate memory for the image
    size_t img_size = stride * (size_t)abs(height);
    printf("Image Size: %zu bytes\n", img_size);

    uint8_t *img = malloc(img_size);
    if (!img) {
        perror("Error allocating memory for image");
        fclose(file);
        return 1;
    }

    // Read image data
    fseek(file, *(int *)&header[10], SEEK_SET); // Pixel data offset
    size_t read_bytes = fread(img, sizeof(uint8_t), img_size, file);
    printf("Bytes Read: %zu\n", read_bytes);
    if (read_bytes != img_size) {
        fprintf(stderr, "Error reading BMP data\n");
        free(img);
        fclose(file);
        return 1;
    }
    fclose(file);

    // Call assembly function to process the image
    slantbmp1(img, stride, abs(height));

    // Write the modified image to the output file
    file = fopen(output_file, "wb");
    if (!file) {
        perror("Error opening output file");
        free(img);
        return 1;
    }

    // Write header
    fwrite(header, sizeof(uint8_t), 54, file);
    // Write image data
    fwrite(img, sizeof(uint8_t), img_size, file);
    fclose(file);

    printf("Image slanted successfully! Saved to %s\n", output_file);

    free(img);
    return 0;
}