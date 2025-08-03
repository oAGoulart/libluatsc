targ='libluatsc'

gcc -Wall -Wextra -Wpedantic -Wshadow -Wformat=2 \
    -fPIC $CFLAGS --std=c11 -O3 -c $targ.c

if [ "$(printenv 'OS')" = 'Windows_NT' ]; then
  gcc -shared -lm -o $targ.dll $targ.o $LFLAGS -llua54
else
  gcc -shared -lm -o $targ.so $targ.o $LFLAGS
fi
