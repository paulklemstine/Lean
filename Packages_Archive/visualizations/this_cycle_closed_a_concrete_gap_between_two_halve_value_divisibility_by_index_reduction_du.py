def fib_divides_index(m: int, n: int) -> bool:
    """
    Decide whether m | Fib(n) WITHOUT computing Fib(n), using the duality
    theorem  m | Fib(n)  <=>  R(m) | n.

    Computes R(m) by state iteration, then performs a single modular reduction
    of the (possibly astronomically large) index n.

    Complexity: O(R(m)) to find the rank, plus O(log n) for the modular test;
    independent of the magnitude of Fib(n).
    """
    if n == 0:
        return True                      # Fib(0) = 0 is divisible by everything
    r = fib_rank(m)
    return n % r == 0
