from math import comb

def closed_form_certificate(m: int, n: int) -> tuple[int, int, bool, bool]:
    """Return (lhs, rhs, closed_form_ok, divisibility_ok) where
    lhs = (m*n+1)*Cat_m(n), rhs = C((m+1)n, n)."""
    cat = 1 if n == 0 else comb((m + 1) * n, n) - m * comb((m + 1) * n, n - 1)
    lhs = (m * n + 1) * cat
    rhs = comb((m + 1) * n, n)
    return lhs, rhs, lhs == rhs, rhs % (m * n + 1) == 0

def verify_grid(max_m: int, max_n: int) -> bool:
    """Certify the closed form and divisibility over a parameter grid."""
    for m in range(1, max_m + 1):
        for n in range(0, max_n + 1):
            _, _, cf_ok, dvd_ok = closed_form_certificate(m, n)
            if not (cf_ok and dvd_ok):
                return False
    return True
