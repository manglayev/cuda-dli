#include <stdio.h>

void init(int *a, int N)
{
  int i;
  for (i = 0; i < N; ++i)
  {
    a[i] = i;
  }
}

__global__
void doubleElements(int *a, int N)
{

  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = gridDim.x * blockDim.x;

  for (int i = idx; i < N; i += stride)
  {
    a[i] *= 2;
  }
}

bool checkElementsAreDoubled(int *a, int N)
{
  int i;
  for (i = 0; i < N; ++i)
  {
    if (a[i] != i*2) return false;
  }
  return true;
}

int main()
{
  /*
   * Add error handling to this source code to learn what errors
   * exist, and then correct them. Googling error messages may be
   * of service if actions for resolving them are not clear to you.
   */

  int N = 10000;
  int *a;

  size_t size = N * sizeof(int);

  cudaError_t err_1;
  err_1 = cudaMallocManaged(&a, size);                    // Assume the existence of `a` and `N`.

  if (err_1 != cudaSuccess)                           // `cudaSuccess` is provided by CUDA.
  {
      printf("Error: %s\n", cudaGetErrorString(err_1)); // `cudaGetErrorString` is provided by CUDA.
  }

  init(a, N);

  size_t threads_per_block = 2048;
  size_t number_of_blocks = 32;

  doubleElements<<<number_of_blocks, threads_per_block>>>(a, N);
  cudaError_t err_2;
  err_2 = cudaGetLastError(); // `cudaGetLastError` will return the error from above.
  if (err_2 != cudaSuccess)
  {
      printf("Error: %s\n", cudaGetErrorString(err_2));
  }

  cudaDeviceSynchronize();
  cudaError_t err_3;
  err_3 = cudaGetLastError(); // `cudaGetLastError` will return the error from above.
  if (err_3 != cudaSuccess)
  {
      printf("Error: %s\n", cudaGetErrorString(err_3));
  }

  bool areDoubled = checkElementsAreDoubled(a, N);
  printf("All elements were doubled? %s\n", areDoubled ? "TRUE" : "FALSE");

  cudaFree(a);
}
