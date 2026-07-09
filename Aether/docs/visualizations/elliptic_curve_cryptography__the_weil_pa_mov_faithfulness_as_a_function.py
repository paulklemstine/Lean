"""Visualization: the MOV reduction collapses the ECDLP onto a cyclic dial.

We render the symmetric pairing e(a, b) = zeta^(a*b) on G = Z_n by plotting, for
a fixed generator g, the target exponent e(x.g, g) = e(g,g)^x as x ranges over
0..n-1.  Because e(g,g) has order ord = n/gcd(.,n), the values wrap with period
ord -- exactly the content of `mov_reduction`: two secrets collide iff they are
congruent mod ord(e g g).  When ord = n (small embedding degree, e.g. g=1 with n
prime) every secret has a unique image, which is `mov_recovers_dlog`.
"""

from __future__ import annotations

from math import gcd
import matplotlib.pyplot as plt


def main() -> None:
    n: int = 101
    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    # Left: faithful case g=1 (e(g,g) generates mu_101, order 101).
    g1: int = 1
    base1: int = (g1 * g1) % n
    ord1: int = n // gcd(base1, n)
    xs = list(range(n))
    ys1 = [(base1 * x) % n for x in xs]
    axes[0].scatter(xs, ys1, s=14, c="tab:blue")
    axes[0].set_title(f"Faithful MOV: g={g1}, ord(e(g,g))={ord1}=n\n"
                      "bijection x -> e(x.g,g): secret uniquely recovered")
    axes[0].set_xlabel("ECDLP secret x")
    axes[0].set_ylabel("target exponent e(x.g, g)")

    # Right: degenerate case where the base has small order -> collisions.
    # Use a non-prime modulus so a generator can have small order.
    n2: int = 100
    g2: int = 10                       # e(g,g)=100 mod 100 = 0 -> order 1 (extreme)
    base2: int = (g2 * g2) % n2
    ord2: int = n2 // gcd(base2, n2) if base2 != 0 else 1
    xs2 = list(range(n2))
    ys2 = [(base2 * x) % n2 for x in xs2]
    axes[1].scatter(xs2, ys2, s=14, c="tab:red")
    axes[1].set_title(f"Tiny order: n={n2}, g={g2}, ord(e(g,g))={ord2}\n"
                      "massive collisions: secret NOT recoverable")
    axes[1].set_xlabel("ECDLP secret x")
    axes[1].set_ylabel("target exponent e(x.g, g)")

    fig.suptitle("MOV reduction faithfulness is governed by ord(e(g,g))",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("mov_faithfulness.png", dpi=130)
    print("wrote mov_faithfulness.png")


if __name__ == "__main__":
    main()
