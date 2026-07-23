from typing import List


def base_p_digits(n: int, p: int) -> List[int]:
    """Digits of n in base p, least significant first."""
    if n == 0:
        return [0]
    out: List[int] = []
    while n > 0:
        out.append(n % p)
        n //= p
    return out


def kummer_carries(a: int, b: int, p: int) -> int:
    """Number of carries adding a and b in base p; equals v_p(C(a+b, a))."""
    da, db = base_p_digits(a, p), base_p_digits(b, p)
    L = max(len(da), len(db))
    da += [0] * (L - len(da))
    db += [0] * (L - len(db))
    carries = carry = 0
    for i in range(L):
        s = da[i] + db[i] + carry
        if s >= p:
            carries += 1
            carry = 1
        else:
            carry = 0
    return carries


def witness_index(n: int, p: int) -> int:
    """For p | n, return i = p^{v_p(n)}; if n is not a prime power this i is an
    interior index with zero carries in n = i + (n-i), so p does not divide C(n,i)."""
    a = 0
    m = n
    while m % p == 0:
        m //= p
        a += 1
    return p ** a
