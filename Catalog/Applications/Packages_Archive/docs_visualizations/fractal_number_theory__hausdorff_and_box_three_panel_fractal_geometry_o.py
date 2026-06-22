"""
Visualization of the logarithmic prime image S = { 1/log p : p prime }.

Produces three panels:
  (left)   the points 1/log p on the interval (0, 1/log 2], showing the
           accumulation toward 0 and the spread of small primes;
  (middle) twin-prime distances d(p,p+2) vs the asymptotic 2/(p log^2 p);
  (right)  the box-counting estimate log N(eps)/log(1/eps) vs eps, the
           empirical box dimension contrasted with Hausdorff dimension 0.

Requires matplotlib. Run:  python visualization.py
"""

from __future__ import annotations

import math

import matplotlib.pyplot as plt


def primes_up_to(limit: int) -> list[int]:
    if limit < 2:
        return []
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, v in enumerate(sieve) if v]


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: the set S on the line
    ps = primes_up_to(500)
    vals = [1.0 / math.log(p) for p in ps]
    axes[0].vlines(vals, 0, 1, color="#1f77b4", alpha=0.6, linewidth=0.8)
    axes[0].axvline(1.0 / math.log(2), color="crimson", linestyle="--",
                    label="1/log 2 (max)")
    axes[0].axvline(0.0, color="black", linestyle=":", label="limit point 0")
    axes[0].set_title("S = {1/log p} accumulates at 0, capped at 1/log 2")
    axes[0].set_xlabel("1/log p")
    axes[0].set_yticks([])
    axes[0].legend()

    # Panel 2: twin distances vs asymptotic
    pset = set(primes_up_to(200000))
    tp = [(p, p + 2) for p in sorted(pset) if p >= 3 and (p + 2) in pset]
    xs = [p for p, _ in tp]
    d = [abs(1 / math.log(p) - 1 / math.log(q)) for p, q in tp]
    asy = [2.0 / (p * math.log(p) ** 2) for p, _ in tp]
    axes[1].loglog(xs, d, ".", ms=3, label="d(p, p+2)")
    axes[1].loglog(xs, asy, "-", color="orange", label="2/(p log^2 p)")
    axes[1].set_title("Twin primes are the tightest clusters")
    axes[1].set_xlabel("p")
    axes[1].set_ylabel("logarithmic distance")
    axes[1].legend()

    # Panel 3: box-counting dimension estimate
    pts = [1.0 / math.log(p) for p in primes_up_to(2_000_000)]
    eps = 0.1
    es, rs = [], []
    for _ in range(12):
        n = len({math.floor(x / eps) for x in pts})
        es.append(eps)
        rs.append(math.log(n) / math.log(1.0 / eps))
        eps /= 2.0
    axes[2].semilogx(es, rs, "o-", color="green", label="log N / log(1/eps)")
    axes[2].axhline(0.0, color="black", linestyle=":",
                    label="Hausdorff dim = 0")
    axes[2].axhline(0.5, color="purple", linestyle="--",
                    label="conjectured box dim = 1/2")
    axes[2].set_title("The dimensional gap")
    axes[2].set_xlabel("eps")
    axes[2].set_ylabel("box-dimension estimate")
    axes[2].invert_xaxis()
    axes[2].legend()

    fig.suptitle("Fractal Geometry of the Logarithmic Prime Image",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("prime_fractal.png", dpi=150)
    print("Saved prime_fractal.png")


if __name__ == "__main__":
    main()
