from math import comb

def signed_vandermonde(p: int, m: int) -> int:
    """Evaluate sum_i (-1)^i C(p+i,i) C(p, m-i); equals (-1)^m."""
    return sum((-1) ** i * comb(p + i, i) * comb(p, m - i) for i in range(m + 1))

def check_signed_vandermonde(P: int) -> bool:
    """Verify the crux identity for all 0 <= m <= p < P."""
    return all(signed_vandermonde(p, m) == (-1) ** m
               for p in range(P) for m in range(p + 1))
