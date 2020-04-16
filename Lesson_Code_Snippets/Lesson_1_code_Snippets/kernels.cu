#include <cuda_runtime.h>
#include <device_launch_parameters.h>
__global__ 
void square(float* d_out, float* d_in)
{
    int idx = threadIdx.x;
    float f = d_in[idx];
    d_out[idx] = f * f;
}

void your_square(int array_size, float* d_out, float* d_in)
{
    square<<<1, array_size >>> (d_out, d_in);
}