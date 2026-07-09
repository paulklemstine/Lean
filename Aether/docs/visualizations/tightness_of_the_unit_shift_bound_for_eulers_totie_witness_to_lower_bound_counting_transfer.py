from typing import List

def is_collision(n: int) -> bool:
    from math import gcd
    def phi(m: int) -> int:
        if m == 1:
            return 1
        r, t, p = m, m, 2
        while p * p <= t:
            if t % p == 0:
                while t % p == 0:
                    t //= p
                r -= r // p
            p += 1
        if t > 1:
            r -= r // t
        return r
    return phi(n) == phi(n + 1)

def transfer_lower_bound(witnesses: List[int], x: int) -> int:
    """
    Counting transfer theorem (S1phi_ge_card): given a finite set of certified
    witnesses all <= x, return the guaranteed lower bound on S1phi(x), namely
    the number of distinct valid witnesses. O(|W| sqrt(x)).
    """
    valid = {w for w in witnesses if 1 <= w <= x and is_collision(w)}
    return len(valid)
