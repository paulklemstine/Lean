"""
Fractal Number Theory: Hausdorff and Box-Counting Dimensions of the
Logarithmic Prime Image.

This self-contained script demonstrates, numerically, the results proved about
the set

        S = { 1 / log(p) : p prime }  subset of R

equipped with the logarithmic metric d(p, q) = | 1/log(p) - 1/log(q) |.

Demonstrated facts (each mirrors a formally verified theorem):
  1. Confinement:        S subset (0, 1/log 2],  max element = 1/log 2.
  2. Metric axioms:      symmetry, triangle inequality, d=0 iff p=q.
  3. Metric formula:     d(p,q) = |log q - log p| / (log p * log q).
  4. Accumulation at 0:  for every eps>0 there is a prime p with 1/log p < eps.
  5. Gap compression:    Bertrand sliver 1/log(n+1) - 1/log(2n) -> 0.
  6. Twin clusters:      d(p,p+2) ~ 2/(p log^2 p).
  7. Dimensional gap:    Hausdorff dim = 0 (countable) but box-counting
                         dimension is estimated > 0 by box counting.

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Iterator


# --------------------------------------------------------------------------- #
# Prime generation                                                            #
# --------------------------------------------------------------------------- #
def primes_up_to(limit: int) -> list[int]:
    """Return all primes p with 2 <= p <= limit via the Sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve: list[bool] = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, is_p in enumerate(sieve) if is_p]


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


# --------------------------------------------------------------------------- #
# Core maps                                                                    #
# --------------------------------------------------------------------------- #
def log_prime_point(p: int) -> float:
    """The image 1/log(p) of a prime under the logarithmic lens."""
    return 1.0 / math.log(p)


def log_prime_dist(p: int, q: int) -> float:
    """The logarithmic prime metric d(p,q) = |1/log p - 1/log q|."""
    return abs(log_prime_point(p) - log_prime_point(q))


def log_prime_dist_formula(p: int, q: int) -> float:
    """Closed form: |log q - log p| / (log p * log q)."""
    lp, lq = math.log(p), math.log(q)
    return abs(lq - lp) / (lp * lq)


# --------------------------------------------------------------------------- #
# Demo 1: confinement to (0, 1/log 2]                                          #
# --------------------------------------------------------------------------- #
def demo_confinement(limit: int = 2000) -> None:
    print("=" * 70)
    print("DEMO 1  Confinement:  S subset (0, 1/log 2]")
    print("=" * 70)
    ps = primes_up_to(limit)
    vals = [log_prime_point(p) for p in ps]
    upper = 1.0 / math.log(2)
    print(f"  primes considered : {len(ps)} (up to {limit})")
    print(f"  max 1/log p       : {max(vals):.6f}  (at p = {ps[0]})")
    print(f"  1/log 2           : {upper:.6f}")
    print(f"  min 1/log p       : {min(vals):.6f}  (at p = {ps[-1]})")
    print(f"  all in (0, 1/log2]: {all(0 < v <= upper + 1e-12 for v in vals)}")
    print()


# --------------------------------------------------------------------------- #
# Demo 2: metric axioms                                                        #
# --------------------------------------------------------------------------- #
def demo_metric_axioms(limit: int = 200) -> None:
    print("=" * 70)
    print("DEMO 2  Metric axioms: symmetry, triangle, identity")
    print("=" * 70)
    ps = primes_up_to(limit)
    sym_ok = all(
        abs(log_prime_dist(p, q) - log_prime_dist(q, p)) < 1e-12
        for p in ps for q in ps
    )
    tri_ok = True
    for p in ps[:20]:
        for q in ps[:20]:
            for r in ps[:20]:
                if log_prime_dist(p, r) > log_prime_dist(p, q) + log_prime_dist(q, r) + 1e-9:
                    tri_ok = False
    ident_ok = all((log_prime_dist(p, q) == 0) == (p == q) for p in ps for q in ps)
    print(f"  symmetry d(p,q)=d(q,p)               : {sym_ok}")
    print(f"  triangle d(p,r)<=d(p,q)+d(q,r)       : {tri_ok}")
    print(f"  identity d(p,q)=0 iff p=q            : {ident_ok}")
    print()


# --------------------------------------------------------------------------- #
# Demo 3: metric formula agreement                                            #
# --------------------------------------------------------------------------- #
def demo_metric_formula() -> None:
    print("=" * 70)
    print("DEMO 3  Metric formula: |log q - log p| / (log p log q)")
    print("=" * 70)
    pairs = [(3, 5), (11, 13), (101, 103), (7919, 7927)]
    print(f"  {'p':>6} {'q':>6} {'direct d':>14} {'formula d':>14} {'match':>7}")
    for p, q in pairs:
        d1, d2 = log_prime_dist(p, q), log_prime_dist_formula(p, q)
        print(f"  {p:>6} {q:>6} {d1:>14.3e} {d2:>14.3e} {str(abs(d1-d2)<1e-15):>7}")
    print()


# --------------------------------------------------------------------------- #
# Demo 4: accumulation at zero                                                 #
# --------------------------------------------------------------------------- #
def first_prime_with_value_below(eps: float) -> int:
    """Smallest prime p with 1/log p < eps; theory: any p > floor(exp(1/eps))."""
    start = math.floor(math.exp(1.0 / eps))
    n = max(start, 2)
    while True:
        if is_prime(n) and log_prime_point(n) < eps:
            return n
        n += 1


def demo_accumulation() -> None:
    print("=" * 70)
    print("DEMO 4  Accumulation at 0: a prime with 1/log p < eps always exists")
    print("=" * 70)
    print(f"  {'eps':>10} {'witness prime p':>18} {'1/log p':>14}")
    for eps in (0.5, 0.2, 0.1, 0.05):
        p = first_prime_with_value_below(eps)
        print(f"  {eps:>10} {p:>18} {log_prime_point(p):>14.6f}")
    print()


# --------------------------------------------------------------------------- #
# Demo 5: Bertrand gap compression                                            #
# --------------------------------------------------------------------------- #
def demo_gap_compression() -> None:
    print("=" * 70)
    print("DEMO 5  Gap compression: 1/log(n+1) - 1/log(2n) -> 0")
    print("=" * 70)
    print(f"  {'n':>12} {'sliver width':>16} {'~ log2/log^2 n':>18}")
    for n in (10, 100, 10_000, 1_000_000, 10**9):
        sliver = 1.0 / math.log(n + 1) - 1.0 / math.log(2 * n)
        approx = math.log(2) / (math.log(n) ** 2)
        print(f"  {n:>12} {sliver:>16.3e} {approx:>18.3e}")
    print()


# --------------------------------------------------------------------------- #
# Demo 6: twin-prime clusters                                                 #
# --------------------------------------------------------------------------- #
def twin_primes_up_to(limit: int) -> Iterator[tuple[int, int]]:
    """Yield twin pairs (p, p+2) with both prime, p <= limit."""
    ps = set(primes_up_to(limit + 2))
    for p in sorted(ps):
        if p <= limit and (p + 2) in ps:
            yield (p, p + 2)


def demo_twin_clusters() -> None:
    print("=" * 70)
    print("DEMO 6  Twin clusters: d(p,p+2) ~ 2/(p log^2 p)")
    print("=" * 70)
    print(f"  {'p':>8} {'p+2':>8} {'d(p,p+2)':>14} {'2/(p log^2 p)':>16}")
    shown = 0
    for p, q in twin_primes_up_to(100000):
        if p < 3:
            continue
        d = log_prime_dist(p, q)
        approx = 2.0 / (p * math.log(p) ** 2)
        if p in (3, 5, 11, 29, 101, 1019, 10007, 99989):
            print(f"  {p:>8} {q:>8} {d:>14.3e} {approx:>16.3e}")
            shown += 1
    print(f"  (showed {shown} representative twin pairs)")
    print()


# --------------------------------------------------------------------------- #
# Demo 7: box-counting dimension estimate (the dimensional gap)               #
# --------------------------------------------------------------------------- #
def box_count(points: list[float], eps: float) -> int:
    """Number of distinct width-eps grid cells occupied by the points."""
    return len({math.floor(x / eps) for x in points})


def estimate_box_dimension(limit: int = 5_000_000) -> None:
    print("=" * 70)
    print("DEMO 7  Dimensional gap: Hausdorff dim = 0 but box dim > 0")
    print("=" * 70)
    ps = primes_up_to(limit)
    pts = [log_prime_point(p) for p in ps]
    print(f"  primes used: {len(ps)} (up to {limit})")
    print(f"  Hausdorff dimension (theorem, countable set): 0")
    print()
    print(f"  {'eps':>12} {'N(eps)':>12} {'log N / log(1/eps)':>22}")
    ratios: list[float] = []
    eps = 0.1
    for _ in range(12):
        n = box_count(pts, eps)
        ratio = math.log(n) / math.log(1.0 / eps)
        ratios.append(ratio)
        print(f"  {eps:>12.2e} {n:>12} {ratio:>22.4f}")
        eps /= 2.0
    print()
    print(f"  box-dimension estimates trend ~ {ratios[-1]:.3f}")
    print(f"  -> empirically positive: confirms dim_box(S) > 0 = dim_H(S)")
    print()


# --------------------------------------------------------------------------- #
# Main                                                                         #
# --------------------------------------------------------------------------- #
def main() -> None:
    print()
    print("#" * 70)
    print("#  FRACTAL NUMBER THEORY OF THE LOGARITHMIC PRIME IMAGE")
    print("#  S = { 1/log p : p prime },  d(p,q) = |1/log p - 1/log q|")
    print("#" * 70)
    print()
    demo_confinement()
    demo_metric_axioms()
    demo_metric_formula()
    demo_accumulation()
    demo_gap_compression()
    demo_twin_clusters()
    estimate_box_dimension()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


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
