#include "defines.h"

void* memset(void* dest, int val, size_t n) {
  unsigned char* ptr = dest;
  while (n-- > 0) *ptr++ = val;
  return dest;
}

void* memcpy(void* dest, void* src, size_t n) {
  unsigned char* cdest = dest;
  unsigned char* csrc  = src;
  for (size_t i = 0; i < n; i++) cdest[i] = csrc[i];
  return dest;
}