from fractions import Fraction

def fib_p_adic_height_below_one(p: int, n: int) -> bool:
    """
    Decide whether the p-adic arithmetic height |Fib(n)|_p is strictly below 1,
    using the capstone  |Fib(n)|_p < 1  <=>  R(p) | n.

    |Fib(n)|_p = p^{-v_p(Fib(n))}, the exponentiated tropical (min-plus)
    valuation, so |Fib(n)|_p < 1 iff p | Fib(n) iff R(p) | n.  We answer by the
    index test only, never forming the gigantic value Fib(n).
    """
    if n == 0:
        return True                      # Fib(0) = 0, |0|_p = 0 < 1
    r = fib_rank(p)
    return n % r == 0
