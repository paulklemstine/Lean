from math import gcd

def fib_divides_fib(m: int, n: int) -> bool:
    """Decide F(m) | F(n) WITHOUT materializing the Fibonacci values.

    By the converse divisibility law, for m >= 3 this is equivalent to m | n.
    For m in {1, 2}, F(m) = 1 divides every Fibonacci number, so the answer is
    always True. Complexity: O(1) after a single modulo / branch.
    """
    if m <= 2:
        return True            # F(1)=F(2)=1 divides everything
    return n % m == 0          # converse divisibility law, m >= 3

def fib_values_coprime(m: int, n: int) -> bool:
    """Decide gcd(F(m), F(n)) == 1 via the index gcd only.

    By the coprimality criterion, coprime iff gcd(m, n) in {1, 2}.
    Complexity: one Euclidean gcd, O(log min(m, n)).
    """
    return gcd(m, n) in (1, 2)
