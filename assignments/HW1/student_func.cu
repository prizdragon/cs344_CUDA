// Homework 1
// Color to Greyscale Conversion

//A common way to represent color images is known as RGBA - the color
//is specified by how much Red, Grean and Blue is in it.
//The 'A' stands for Alpha and is used for transparency, it will be
//ignored in this homework.

//Each channel Red, Blue, Green and Alpha is represented by one byte.
//Since we are using one byte for each color there are 256 different
//possible values for each color.  This means we use 4 bytes per pixel.

//Greyscale images are represented by a single intensity value per pixel
//which is one byte in size.

//To convert an image from color to grayscale one simple method is to
//set the intensity to the average of the RGB channels.  But we will
//use a more sophisticated method that takes into account how the eye 
//perceives color and weights the channels unequally.

//The eye responds most strongly to green followed by red and then blue.
//The NTSC (National Television System Committee) recommends the following
//formula for color to greyscale conversion:

//I = .299f * R + .587f * G + .114f * B

//Notice the trailing f's on the numbers which indicate that they are 
//single precision floating point constants and not double precision
//constants.

//You should fill in the kernel as well as set the block and grid sizes
//so that the entire image is processed.

#include "utils.h"
#include <device_launch_parameters.h>

// We chose this number in order to avoid problems with the max size in different GPUS.
#define MAX_NUM_OF_THREADS_PER_BLOCK 256
#define THREADS_PER_BLOCK_ROW 16
#define THREADS_PER_BLOCK_COL (MAX_NUM_OF_THREADS_PER_BLOCK/THREADS_PER_BLOCK_ROW)

__global__
void rgba_to_greyscale(const uchar4* const rgbaImage,
                       unsigned char* const greyImage,
                       int numRows, int numCols)
{
  //TODO
  //Fill in the kernel to convert from color to greyscale
  //the mapping from components of a uchar4 to RGBA is:
  // .x -> R ; .y -> G ; .z -> B ; .w -> A
  //
  //The output (greyImage) at each pixel should be the result of
  //applying the formula: output = .299f * R + .587f * G + .114f * B;
  //Note: We will be ignoring the alpha channel for this conversion

  //First create a mapping from the 2D block and grid locations
  //to an absolute 2D location in the image, then use that to
  //calculate a 1D offset

  // get location of pixel in grid
  int pixelCol = blockIdx.x * blockDim.x + threadIdx.x;
  int pixelRow = blockIdx.y * blockDim.y + threadIdx.y;

  // verify that pixel is in image
  if ((pixelRow >= numRows) || (pixelCol >= numCols) || (pixelRow < 0) || (pixelCol < 0))
      return;

  // get location of pixel in array
  int pixel_array_loc = pixelRow * numCols + pixelCol;

  // get pixel value in rgba
  uchar4 rgba = rgbaImage[pixel_array_loc];

  //convert pixel value to grayscale
  greyImage[pixel_array_loc] = .299f * rgba.x + .587f * rgba.y + .114f * rgba.z;
}

void your_rgba_to_greyscale(const uchar4 * const h_rgbaImage, uchar4 * const d_rgbaImage,
                            unsigned char* const d_greyImage, size_t numRows, size_t numCols)
{
  //You must fill in the correct sizes for the blockSize and gridSize
  //currently only one block with one thread is being launched

  int grid_x = (numCols % THREADS_PER_BLOCK_COL) == 0 ? numCols / THREADS_PER_BLOCK_COL : 
                                                        numCols / THREADS_PER_BLOCK_COL + 1;
  int grid_y = (numRows % THREADS_PER_BLOCK_ROW) == 0 ? numRows / THREADS_PER_BLOCK_ROW : 
                                                        numRows / THREADS_PER_BLOCK_ROW + 1;
  const dim3 blockSize(THREADS_PER_BLOCK_COL, THREADS_PER_BLOCK_ROW, 1);
  const dim3 gridSize(grid_x, grid_y, 1);
  rgba_to_greyscale<<<gridSize, blockSize>>>(d_rgbaImage, d_greyImage, numRows, numCols);
  
  cudaDeviceSynchronize(); checkCudaErrors(cudaGetLastError());

}
