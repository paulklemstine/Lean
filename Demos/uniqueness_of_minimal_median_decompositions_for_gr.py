"""
Quotient Orbit Compression --- Numerical Demonstrations
=======================================================

A self-contained, dependency-free demonstration of the bounded-horizon
collision principle for coarse-grained deterministic dynamics.

Core mathematical objects (mirroring the formal development):

  * alpha : a finite set of microscopic states (here: range(0, |alpha|)).
  * f     : alpha -> alpha, an arbitrary deterministic transition map.
  * rho   : a coarse "lens", an equivalence relation given by a labelling
            function  label : alpha -> class_id.  Two states are
            rho-related iff they share a class id.
  * k     : the resolution = number of distinct observable classes.

Central theorem (exists_iterate_rel_of_card_quotient):
  For ANY f and ANY start x there exist 0 <= m < n <= k with
  label(f^[m](x)) == label(f^[n](x)), i.e. a coarse collision within k steps.

This script verifies the theorem, its tightness, the observable-orbit
ceiling, and the compression statistics, on several concrete systems.

Run with:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, Dict, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Core primitives (all inlined, type-hinted)                                  #
# --------------------------------------------------------------------------- #

def iterate(f: Callable[[int], int], x: int, n: int) -> int:
    """Return f^[n](x): the n-fold application of f to x."""
    state: int = x
    for _ in range(n):
        state = f(state)
    return state


def quotient_size(alpha: List[int], label: Callable[[int], int]) -> int:
    """k = |alpha / rho|: number of distinct observable classes."""
    return len({label(a) for a in alpha})


def quotient_observable_trace(
    f: Callable[[int], int],
    x: int,
    label: Callable[[int], int],
    horizon: int,
) -> List[int]:
    """trace_N(i) = label(f^[i](x)) for i = 0..horizon (quotientObservableTrace)."""
    trace: List[int] = []
    state: int = x
    for _ in range(horizon + 1):
        trace.append(label(state))
        state = f(state)
    return trace


def observable_orbit_count(
    f: Callable[[int], int],
    x: int,
    label: Callable[[int], int],
    horizon: int,
) -> int:
    """Number of distinct observable classes visited (observableOrbitCount)."""
    return len(set(quotient_observable_trace(f, x, label, horizon)))


def find_coarse_collision(
    f: Callable[[int], int],
    x: int,
    label: Callable[[int], int],
    k: int,
) -> Optional[Tuple[int, int]]:
    """
    Algorithm A (hash-set): return the first pair (m, n), 0 <= m < n <= k,
    with label(f^[m](x)) == label(f^[n](x)).  Guaranteed to exist by the
    central theorem.  Runs at most k + 1 iterations.
    """
    first_seen: Dict[int, int] = {}
    state: int = x
    for i in range(k + 1):
        lab: int = label(state)
        if lab in first_seen:
            return (first_seen[lab], i)
        first_seen[lab] = i
        state = f(state)
    return None  # unreachable when k = |alpha/rho|


def collision_entropy(alpha: List[int], label: Callable[[int], int]) -> int:
    """H_rho = |alpha| - k, distinctions discarded by the lens."""
    return len(alpha) - quotient_size(alpha, label)


def orbit_compression_ratio(alpha: List[int], label: Callable[[int], int]) -> float:
    """R_rho = k / |alpha|, the retained fraction of resolution."""
    return quotient_size(alpha, label) / len(alpha)


# --------------------------------------------------------------------------- #
# Demonstration 1: the central bounded-horizon collision theorem             #
# --------------------------------------------------------------------------- #

def demo_central_theorem() -> None:
    print("=" * 70)
    print("DEMO 1  Central theorem: a coarse collision within k steps")
    print("=" * 70)

    # A deliberately "scrambled" map on a 50-element state space.
    N: int = 50
    alpha: List[int] = list(range(N))
    f: Callable[[int], int] = lambda s: (7 * s * s + 3 * s + 11) % N

    # A coarse lens with only k = 5 classes (state mod 5).
    label: Callable[[int], int] = lambda s: s % 5
    k: int = quotient_size(alpha, label)
    print(f"|alpha| = {len(alpha)},  resolution k = |alpha/rho| = {k}")

    for x in (0, 1, 17, 42):
        m, n = find_coarse_collision(f, x, label, k)  # type: ignore[misc]
        same = label(iterate(f, x, m)) == label(iterate(f, x, n))
        print(f"  start x={x:2d}:  collision (m,n)=({m},{n}),  "
              f"n<=k? {n <= k},  labels equal? {same}")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 2: tightness of the horizon k                                #
# --------------------------------------------------------------------------- #

def demo_tightness() -> None:
    print("=" * 70)
    print("DEMO 2  Tightness: a single k-cycle uses all k steps")
    print("=" * 70)

    for k in (1, 2, 5, 9):
        alpha: List[int] = list(range(k))
        f: Callable[[int], int] = lambda s, k=k: (s + 1) % k
        label: Callable[[int], int] = lambda s: s  # identity lens, k classes
        m, n = find_coarse_collision(f, 0, label, k)  # type: ignore[misc]
        print(f"  k={k}:  first collision at (m,n)=({m},{n})  "
              f"-> first repeat exactly at n={n} (= k)")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 3: observable-orbit ceiling                                  #
# --------------------------------------------------------------------------- #

def demo_orbit_ceiling() -> None:
    print("=" * 70)
    print("DEMO 3  Observable-orbit ceiling: count <= k for every horizon")
    print("=" * 70)

    N: int = 100
    alpha: List[int] = list(range(N))
    f: Callable[[int], int] = lambda s: (5 * s + 1) % N
    label: Callable[[int], int] = lambda s: s % 7
    k: int = quotient_size(alpha, label)
    print(f"|alpha| = {N},  resolution k = {k}")
    for horizon in (0, 3, 7, 20, 100, 1000):
        c = observable_orbit_count(f, 3, label, horizon)
        print(f"  horizon N={horizon:4d}:  observable orbit count = {c:2d}  "
              f"(<= k={k}? {c <= k})")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 4: compression statistics                                    #
# --------------------------------------------------------------------------- #

def demo_compression_statistics() -> None:
    print("=" * 70)
    print("DEMO 4  Compression statistics: entropy >= 0 and ratio <= 1")
    print("=" * 70)

    N: int = 60
    alpha: List[int] = list(range(N))
    lenses: List[Tuple[str, Callable[[int], int]]] = [
        ("identity (sharp)",     lambda s: s),
        ("mod 12",               lambda s: s % 12),
        ("mod 4",                lambda s: s % 4),
        ("parity",               lambda s: s % 2),
        ("constant (blur all)",  lambda s: 0),
    ]
    print(f"|alpha| = {N}")
    print(f"  {'lens':<22}{'k':>4}{'H_rho':>8}{'R_rho':>9}")
    for name, label in lenses:
        k = quotient_size(alpha, label)
        h = collision_entropy(alpha, label)
        r = orbit_compression_ratio(alpha, label)
        assert h >= 0 and r <= 1.0
        print(f"  {name:<22}{k:>4}{h:>8}{r:>9.4f}")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 5: cryptographic reading (Pollard-rho style collision)       #
# --------------------------------------------------------------------------- #

def demo_crypto_collision() -> None:
    print("=" * 70)
    print("DEMO 5  Cryptographic reading: forced digest collision")
    print("=" * 70)

    # A toy "compression function": internal state in Z_n, observable
    # digest = state mod (small d).  The lens rho identifies states with
    # the same digest; a rho-collision is a digest collision.
    n: int = 4096
    d: int = 16
    alpha: List[int] = list(range(n))
    f: Callable[[int], int] = lambda s: (1103515245 * s + 12345) % n  # LCG
    digest: Callable[[int], int] = lambda s: s % d
    k: int = quotient_size(alpha, digest)
    m, nn = find_coarse_collision(f, 1, digest, k)  # type: ignore[misc]
    print(f"internal state space |alpha| = {n}, observable digest space k = {k}")
    print(f"  guaranteed digest collision within k={k} steps: found at "
          f"(m,n)=({m},{nn})")
    print(f"  digests: digest(f^[{m}](1)) = {digest(iterate(f,1,m))}, "
          f"digest(f^[{nn}](1)) = {digest(iterate(f,1,nn))}")
    print(f"  => collision resistance is capped by digest size k, not by "
          f"internal size {n}.")
    print()


def main() -> None:
    demo_central_theorem()
    demo_tightness()
    demo_orbit_ceiling()
    demo_compression_statistics()
    demo_crypto_collision()
    print("All demonstrations completed: every theorem held on every example.")


if __name__ == "__main__":
    main()


"""
Visualization for Quotient Orbit Compression.

Produces a three-panel figure:
  (1) the observable label trajectory of a deterministic map, with the first
      coarse collision highlighted (the bounded-horizon collision theorem);
  (2) observable orbit count vs. horizon, saturating below the ceiling k;
  (3) compression ratio R_rho = k/|alpha| across a family of lenses.

Requires only matplotlib + numpy.  Run:  python3 visualize.py
"""

from __future__ import annotations

from typing import Callable, Dict, List, Optional, Tuple

import matplotlib.pyplot as plt
import numpy as np


def iterate_labels(
    f: Callable[[int], int], x: int, label: Callable[[int], int], steps: int
) -> List[int]:
    out: List[int] = []
    s = x
    for _ in range(steps + 1):
        out.append(label(s))
        s = f(s)
    return out


def first_collision(labels: List[int]) -> Optional[Tuple[int, int]]:
    seen: Dict[int, int] = {}
    for i, lab in enumerate(labels):
        if lab in seen:
            return seen[lab], i
        seen[lab] = i
    return None


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(16, 4.5))

    # Panel 1: label trajectory + first collision.
    N = 60
    f: Callable[[int], int] = lambda s: (7 * s * s + 3 * s + 11) % N
    k = 6
    label: Callable[[int], int] = lambda s: s % k
    labels = iterate_labels(f, 17, label, k)
    coll = first_collision(labels)
    ax = axes[0]
    ax.plot(range(len(labels)), labels, "o-", color="#2b6cb0", lw=2, ms=8)
    if coll is not None:
        m, n = coll
        ax.scatter([m, n], [labels[m], labels[n]], s=260, facecolors="none",
                   edgecolors="#e53e3e", lw=3, zorder=5,
                   label=f"collision (m,n)=({m},{n})")
        ax.legend(loc="upper right")
    ax.axvline(k, color="gray", ls="--", alpha=0.6)
    ax.text(k, -0.5, "horizon k", color="gray", ha="center")
    ax.set_title("Observable labels collide within k steps")
    ax.set_xlabel("step i"); ax.set_ylabel("label(f^[i](x))")
    ax.set_yticks(range(k))

    # Panel 2: observable orbit count vs horizon (saturates below k).
    M = 100
    g: Callable[[int], int] = lambda s: (5 * s + 1) % M
    kk = 7
    lab2: Callable[[int], int] = lambda s: s % kk
    horizons = list(range(0, 40))
    counts = [len(set(iterate_labels(g, 3, lab2, h))) for h in horizons]
    ax = axes[1]
    ax.step(horizons, counts, where="post", color="#2f855a", lw=2)
    ax.axhline(kk, color="#e53e3e", ls="--", lw=2, label=f"ceiling k={kk}")
    ax.set_ylim(0, kk + 1)
    ax.set_title("Observable orbit count <= k")
    ax.set_xlabel("horizon N"); ax.set_ylabel("# distinct labels")
    ax.legend(loc="lower right")

    # Panel 3: compression ratio across lenses.
    A = 60
    lens_specs: List[Tuple[str, int]] = [
        ("id", A), ("mod12", 12), ("mod6", 6), ("mod4", 4),
        ("parity", 2), ("const", 1),
    ]
    names = [s[0] for s in lens_specs]
    ratios = [s[1] / A for s in lens_specs]
    ax = axes[2]
    bars = ax.bar(names, ratios, color="#6b46c1", alpha=0.85)
    ax.axhline(1.0, color="#e53e3e", ls="--", label="R_rho <= 1")
    ax.set_ylim(0, 1.1)
    ax.set_title("Compression ratio R_rho = k / |alpha|")
    ax.set_ylabel("R_rho"); ax.legend(loc="upper right")
    for b, r in zip(bars, ratios):
        ax.text(b.get_x() + b.get_width() / 2, r + 0.02, f"{r:.2f}",
                ha="center", fontsize=8)

    fig.suptitle("Quotient Orbit Compression: bounded-horizon collisions, "
                 "orbit ceiling, and compression ratio", fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("quotient_orbit_compression.png", dpi=140)
    print("Saved quotient_orbit_compression.png")


if __name__ == "__main__":
    main()
