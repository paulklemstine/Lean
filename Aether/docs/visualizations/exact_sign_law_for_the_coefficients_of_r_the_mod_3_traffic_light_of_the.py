"""
Visualization: the mod-3 traffic light of Ramanujan's rho(q).

Plots the coefficients r(n) colored by residue class modulo 3, making the sign
law visible at a glance: the class n = 0 (mod 3) is strictly positive, while the
classes n = 1, 2 (mod 3) are non-positive with five sporadic zeros at
n = 2, 4, 8, 11, 20.

Requires matplotlib. Self-contained: the coefficient computation is inlined.
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def ps_mul(a: List[int], b: List[int], n_max: int) -> List[int]:
    out = [0] * (n_max + 1)
    for i, ai in enumerate(a):
        if ai == 0 or i > n_max:
            continue
        for j in range(0, n_max - i + 1):
            bj = b[j] if j < len(b) else 0
            if bj:
                out[i + j] += ai * bj
    return out


def rho_coeffs(n_max: int) -> List[int]:
    def one_minus(s: int) -> List[int]:
        v = [0] * (n_max + 1)
        v[0] = 1
        if 0 < s <= n_max:
            v[s] -= 1
        return v

    def geom(s: int) -> List[int]:
        return [1 if (n % s == 0) else 0 for n in range(n_max + 1)]

    def factor_inv(k: int) -> List[int]:
        return ps_mul(one_minus(2 * k + 1), geom(6 * k + 3), n_max)

    def inv_prod(m: int) -> List[int]:
        result = [0] * (n_max + 1)
        result[0] = 1
        for k in range(m + 1):
            result = ps_mul(result, factor_inv(k), n_max)
        return result

    r = [0] * (n_max + 1)
    m = 0
    while 2 * m * (m + 1) <= n_max:
        shift = 2 * m * (m + 1)
        ip = inv_prod(m)
        for n in range(0, n_max + 1 - shift):
            r[shift + n] += ip[n]
        m += 1
    return r


def main() -> None:
    n_max = 60
    r = rho_coeffs(n_max)
    xs = list(range(n_max + 1))
    colors = ["#2ca02c" if n % 3 == 0 else ("#d62728" if r[n] != 0 else "#7f7f7f") for n in xs]

    fig, ax = plt.subplots(figsize=(13, 5))
    ax.bar(xs, r, color=colors)
    ax.axhline(0, color="black", linewidth=0.8)
    for z in [2, 4, 8, 11, 20]:
        ax.annotate("0", (z, 0), textcoords="offset points", xytext=(0, 6),
                    ha="center", fontsize=8, color="#7f7f7f")
    ax.set_xlabel("n")
    ax.set_ylabel("r(n)")
    ax.set_title("Ramanujan's rho(q): the mod-3 traffic light\n"
                 "green n=0 (mod 3) > 0, red n=1,2 (mod 3) <= 0, grey = sporadic zero")
    fig.tight_layout()
    fig.savefig("rho_traffic_light.png", dpi=150)
    print("Saved rho_traffic_light.png")


if __name__ == "__main__":
    main()
