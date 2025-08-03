#include <stdint.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static uint8_t __attribute__ ((const))
can_rdtscp_(void)
{
  static uint8_t rdtscp = 0xFF;
  __asm__("cmpb $0xFF, %%al\n\t"
          "jne 2f\n\t"
          "movl $0x80000001, %%eax\n\t"
          "cpuid\n\t"
          "andl $0x8000000, %%edx\n\t"
          "jz 1f\n\t"
          "movb $1, %%al\n\t"
          "jmp 2f\n"
          "1:\n\t"
          "xorb %%al, %%al\n"
          "2:"
          : "=a" (rdtscp)
          : "0" (rdtscp)
          : "ebx", "ecx", "edx");
  return rdtscp;
}

static uint8_t __attribute__ ((const))
has_sse2_(void)
{
  static uint8_t sse2 = 0xFF;
  __asm__("cmpb $0xFF, %%al\n\t"
          "jne 2f\n\t"
          "movl $1, %%eax\n\t"
          "cpuid\n\t"
          "andl $0x4000000, %%edx\n\t"
          "jz 1f\n\t"
          "movb $1, %%al\n\t"
          "jmp 2f\n"
          "1:\n\t"
          "xorb %%al, %%al\n"
          "2:"
          : "=a" (sse2)
          : "0" (sse2)
          : "ebx", "ecx", "edx");
  return sse2;
}

static int
l_is_invariant_(lua_State* L)
{
  static uint8_t is = 0xFF;
  __asm__("cmpb $0xFF, %%al\n\t"
          "jne 2f\n\t"
          "movl $0x80000007, %%eax\n\t"
          "cpuid\n\t"
          "andl $0x100, %%edx\n\t"
          "jz 1f\n\t"
          "movb $1, %%al\n\t"
          "jmp 2f\n"
          "1:\n\t"
          "xorb %%al, %%al\n"
          "2:"
          : "=a" (is)
          : "0" (is)
          : "ebx", "ecx", "edx");
  lua_pushboolean(L, is);
  return 1;
}

static int
l_now_(lua_State* L)
{
  if (!can_rdtscp_())
  {
    return luaL_error(L, "cannot read time stamp counter.");
  }
  const uint8_t sse2 = has_sse2_();
  uint64_t counter;
  uint32_t aux;
#ifdef __ILP32__
  uint32_t high, low;
  __asm__("test %%bl, %%bl\n\t"
          "jz 1f\n\t"
          "mfence\n\t"
          "rdtscp\n\t"
          "lfence\n\t"
          "jmp 2f\n"
          "1:\n\t"
          "rdtscp\n"
          "2:"
          : "=a" (low), "=d" (high), "=c" (aux)
          : "b" (ss2));
  counter = ((uint64_t)high << 32) | low;
#else
  __asm__("test %%bl, %%bl\n\t"
          "jz 1f\n\t"
          "mfence\n\t"
          "rdtscp\n\t"
          "lfence\n\t"
          "jmp 2f\n"
          "1:\n\t"
          "rdtscp\n"
          "2:\n\t"
          "shlq $32, %%rdx\n\t"
          "orq %%rdx, %0"
          : "=a" (counter), "=c" (aux)
          : "b" (sse2)
          : "rdx");
#endif
  lua_pushinteger(L, counter);
  lua_pushinteger(L, aux);
  return 2;
}

static const struct luaL_Reg tsc[] = {
  { "now", l_now_ },
  { "isinvariant", l_is_invariant_ },
  { NULL, NULL }
};

int
luaopen_libluatsc(lua_State* L)
{
  luaL_newlib(L, tsc);
  return 1;
}
