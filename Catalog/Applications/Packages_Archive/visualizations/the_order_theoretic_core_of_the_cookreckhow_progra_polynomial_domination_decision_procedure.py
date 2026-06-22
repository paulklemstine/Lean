from typing import Callable, Optional

def p_simulates(a: Callable[[int], int], b: Callable[[int], int],
                N: int = 200, Kmax: int = 8) -> Optional[int]:
    """Least k with a(n) <= (b(n)+2)^k for all n < N, else None.
    A finite-prefix witness for the domination reduction."""
    for k in range(1, Kmax + 1):
        if all(a(n) <= (b(n) + 2) ** k for n in range(N)):
            return k
    return None

def fib(n: int) -> int:
    x, y = 0, 1
    for _ in range(n):
        x, y = y, x + y
    return x

if __name__ == '__main__':
    ident = lambda n: n
    print('lin simulates lin   k =', p_simulates(ident, ident))
    print('lin simulates fib   k =', p_simulates(ident, fib))   # None
    print('fib simulates lin   k =', p_simulates(fib, ident))   # some k
