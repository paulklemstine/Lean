from functools import lru_cache

def gaussian_binomial(q: int, n: int, k: int) -> int:
    """[n,k]_q via the q-Pascal recurrence; counts k-subspaces of F_q^n."""
    @lru_cache(maxsize=None)
    def rec(n_: int, k_: int) -> int:
        if k_ == 0:
            return 1
        if n_ == 0:
            return 0
        return rec(n_ - 1, k_ - 1) + q ** k_ * rec(n_ - 1, k_)
    return rec(n, k)

def lines_of_PG3(q: int) -> int:
    """Number of lines of PG(3,q) = [4,2]_q = (q^2+1)(q^2+q+1)."""
    return gaussian_binomial(q, 4, 2)
