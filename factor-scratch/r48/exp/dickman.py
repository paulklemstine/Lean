"""Dickman rho, validated against exact values rho(1)=1, rho(2)=1-ln2,
rho(3)=0.0486083883, rho(4)=0.0049109256, rho(5)=0.0003547242.

The shifted argument rho(u-1) must land exactly on a grid point, so the grid
step is 1/M and the table spans [0,u].  Getting that index wrong is what made
an earlier version return rho(3) = -0.0986 instead of 0.0486.
"""
import math


def rho(u, M=20000):
    if u <= 1:
        return 1.0
    if u > 10:
        return 0.0
    h = 1.0 / M
    N = int(round(u * M))
    tbl = [1.0] * (N + 1)
    for j in range(M + 1, N + 1):      # j <= M means x = j/M <= 1 -> rho = 1
        x = j * h
        tbl[j] = max(tbl[j - 1] - h * tbl[j - M] / x, 0.0)
    return max(tbl[N], 0.0)


if __name__ == "__main__":
    for u, ex in [(1, 1.0), (2, 1 - math.log(2)), (3, 0.0486083883),
                  (4, 0.0049109256), (5, 0.0003547242), (6, 1.964e-5)]:
        got = rho(u)
        rel = abs(got - ex) / ex
        print(f"rho({u}) = {got:.9f}  exact {ex:.9f}  rel.err {rel:.2e}"
              f"  {'OK' if rel < 0.02 else 'BAD'}")
