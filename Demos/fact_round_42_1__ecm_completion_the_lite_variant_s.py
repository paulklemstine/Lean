"""Computational evidence for Catalog/Geometry/ECMLiteBirthdayScaling.lean.

Two experiments:

E1. Detection-window check.  In Z/n (a cyclic curve group), the sequential run
    P, 2P, ..., B*P has a repeated x-coordinate (modelled by the elliptic
    involution Q -> -Q) iff addOrderOf P <= 2B-1.  Brute-force check of
    `xCollision_iff_addOrderOf_le` for many (n, B, P).

E2. Curve-budget scaling of ECM-lite with a FIXED bound B1 = 50 on genuine
    random elliptic curves over F_p: how many random curves are needed until
    the base point has order <= B1 (equivalently, until some j*P = O with
    2 <= j <= B1).  We report the median budget as a function of log2(p) and
    the fitted slope, testing exponent 1 (theory) against the reported 0.48.
"""

import random
from math import gcd, log2

random.seed(20260921)

# ---------------------------------------------------------------- E1


def order_in_zn(x, n):
    return n // gcd(x, n)


def has_x_collision(x, n, B):
    """Exists 1 <= i < j <= B with i*x == j*x or i*x == -(j*x) mod n."""
    for i in range(1, B + 1):
        for j in range(i + 1, B + 1):
            if (i * x - j * x) % n == 0 or (i * x + j * x) % n == 0:
                return True
    return False


def check_window():
    bad = []
    for n in range(1, 60):
        for B in range(3, 9):
            for x in range(n):
                lhs = has_x_collision(x, n, B)
                rhs = order_in_zn(x, n) <= 2 * B - 1
                if lhs != rhs:
                    bad.append((n, B, x, lhs, rhs))
    return bad


# ---------------------------------------------------------------- E2

def is_prime(m):
    if m < 2:
        return False
    for q in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if m % q == 0:
            return m == q
    d, s = m - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        y = pow(a, d, m)
        if y in (1, m - 1):
            continue
        for _ in range(s - 1):
            y = y * y % m
            if y == m - 1:
                break
        else:
            return False
    return True


def next_prime(m):
    while not is_prime(m):
        m += 1
    return m


def ec_add(P, Q, a, p):
    """Affine addition on y^2 = x^3 + a x + b over F_p; None is the point at infinity."""
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and (y1 + y2) % p == 0:
        return None
    if P == Q:
        lam = (3 * x1 * x1 + a) * pow(2 * y1 % p, -1, p) % p
    else:
        lam = (y2 - y1) * pow((x2 - x1) % p, -1, p) % p
    x3 = (lam * lam - x1 - x2) % p
    y3 = (lam * (x1 - x3) - y1) % p
    return (x3, y3)


def lite_hit(p, B):
    """One random curve + base point; True iff some j*P = O with 2 <= j <= B."""
    while True:
        x0 = random.randrange(p)
        y0 = random.randrange(p)
        a = random.randrange(p)
        b = (y0 * y0 - x0 * x0 * x0 - a * x0) % p
        if (4 * a * a * a + 27 * b * b) % p != 0:
            break
    P = (x0, y0)
    R = ec_add(P, P, a, p)  # explicit doubling: j = 2 (the v1 ledger fix)
    if R is None:
        return True
    for _ in range(3, B + 1):
        R = ec_add(R, P, a, p)
        if R is None:
            return True
    return False


def budget(p, B, cap=400000):
    c = 0
    while c < cap:
        c += 1
        if lite_hit(p, B):
            return c
    return cap


def median(v):
    v = sorted(v)
    n = len(v)
    return v[n // 2] if n % 2 else (v[n // 2 - 1] + v[n // 2]) / 2


def scaling(B=50, ks=(10, 12, 14, 16, 18), trials=15):
    rows = []
    for k in ks:
        p = next_prime(2 ** k + 1)
        vals = [budget(p, B) for _ in range(trials)]
        rows.append((k, p, median(vals), sum(vals) / len(vals)))
    return rows


def slope(rows):
    xs = [r[0] for r in rows]
    ys = [log2(r[2]) for r in rows]
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den


if __name__ == "__main__":
    bad = check_window()
    print("E1 detection-window counterexamples:", len(bad))
    if bad:
        print(bad[:5])
    rows = scaling()
    print("E2 k, p, median budget, mean budget")
    for r in rows:
        print(r)
    print("fitted slope of log2(median budget) per log2(p):", round(slope(rows), 3))
