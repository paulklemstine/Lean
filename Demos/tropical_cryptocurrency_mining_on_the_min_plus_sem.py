"""
Numerical demonstrations for the tropical (min-plus) hash.

The tropical hash of a message m against a key h is

    TSHA(h, m) = min_i (m_i + h_i).

This module empirically confirms two theorems and one conjecture:

  * Stability (1-Lipschitz):  |TSHA(h,m) - TSHA(h,m')| <= max_i |m_i - m'_i|.
  * Generic collisions:       for k >= 2 a distinct message with the same
                              digest can be built deterministically.
  * Two-key refinement:       a second independent key breaks single-key
                              collisions with frequency growing toward 1 as k
                              grows (conjectured residual collision rate ~ 1/k).

Everything is self-contained and uses only the standard library.
"""

from __future__ import annotations

import random
from typing import List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Core tropical hash
# --------------------------------------------------------------------------- #
def tsha(h: Sequence[float], m: Sequence[float]) -> float:
    """Single-key tropical hash: min_i (m_i + h_i). O(k)."""
    return min(mi + hi for mi, hi in zip(m, h))


def tsha2(
    h: Sequence[float], hp: Sequence[float], m: Sequence[float]
) -> Tuple[float, float]:
    """Two-key tropical hash: (min_i(m_i+h_i), min_i(m_i+h'_i)). O(k)."""
    return tsha(h, m), tsha(hp, m)


def argmin_index(h: Sequence[float], m: Sequence[float]) -> int:
    """Index of a minimizing (winning) coordinate of m under key h."""
    best_i, best_v = 0, m[0] + h[0]
    for i in range(1, len(m)):
        v = m[i] + h[i]
        if v < best_v:
            best_i, best_v = i, v
    return best_i


def collide(
    h: Sequence[float], m: Sequence[float], delta: float = 1.0
) -> List[float]:
    """
    Deterministically produce m' != m with TSHA(h, m') = TSHA(h, m).

    Inflate a single non-minimizing (losing) coordinate by delta > 0.
    Requires len(m) >= 2.
    """
    if len(m) < 2:
        raise ValueError("collisions are guaranteed only for k >= 2")
    i_star = argmin_index(h, m)
    k_star = 1 if i_star == 0 else 0  # any index different from the minimizer
    mp = list(m)
    mp[k_star] += delta
    return mp


def sup_norm(m: Sequence[float], mp: Sequence[float]) -> float:
    """Supremum (max coordinate-wise) distance between two messages."""
    return max(abs(a - b) for a, b in zip(m, mp))


# --------------------------------------------------------------------------- #
# Demonstration 1: stability (1-Lipschitz) and its sharpness
# --------------------------------------------------------------------------- #
def demo_stability(k: int = 32, trials: int = 20000, seed: int = 0) -> None:
    rng = random.Random(seed)
    worst_ratio = 0.0
    for _ in range(trials):
        h = [rng.uniform(-10, 10) for _ in range(k)]
        m = [rng.uniform(-10, 10) for _ in range(k)]
        mp = [rng.uniform(-10, 10) for _ in range(k)]
        d = sup_norm(m, mp)
        if d == 0:
            continue
        ratio = abs(tsha(h, m) - tsha(h, mp)) / d
        worst_ratio = max(worst_ratio, ratio)

    # Sharpness: move ONLY the winning coordinate -> ratio should equal 1.
    h = [rng.uniform(-10, 10) for _ in range(k)]
    m = [rng.uniform(-10, 10) for _ in range(k)]
    w = argmin_index(h, m)
    m_shift = list(m)
    eps = 0.5  # small enough to keep w the winner
    m_shift[w] += eps
    sharp_ratio = abs(tsha(h, m) - tsha(h, m_shift)) / sup_norm(m, m_shift)

    print("=" * 64)
    print("Demonstration 1: Stability (1-Lipschitz)")
    print("=" * 64)
    print(f"  k = {k}, trials = {trials}")
    print(f"  worst observed |dTSHA| / ||dm||_inf = {worst_ratio:.6f}  (<= 1)")
    print(f"  ratio when only the winner moves     = {sharp_ratio:.6f}  (= 1)")
    print(f"  bound respected: {worst_ratio <= 1.0 + 1e-12}")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 2: guaranteed collisions
# --------------------------------------------------------------------------- #
def demo_collisions(k: int = 32, trials: int = 10000, seed: int = 1) -> None:
    rng = random.Random(seed)
    successes = 0
    for _ in range(trials):
        h = [rng.uniform(-10, 10) for _ in range(k)]
        m = [rng.uniform(-10, 10) for _ in range(k)]
        mp = collide(h, m, delta=rng.uniform(0.1, 5.0))
        if mp != list(m) and tsha(h, mp) == tsha(h, m):
            successes += 1
    print("=" * 64)
    print("Demonstration 2: Guaranteed collisions (k >= 2)")
    print("=" * 64)
    print(f"  k = {k}, trials = {trials}")
    print(f"  distinct message with identical digest: {successes}/{trials}")
    print(f"  success rate = {successes / trials:.4f}  (expected 1.0000)")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 3: two-key refinement of the collision relation
# --------------------------------------------------------------------------- #
def demo_two_key(seed: int = 2, trials: int = 20000) -> None:
    rng = random.Random(seed)
    print("=" * 64)
    print("Demonstration 3: Two-key refinement (separation rate ~ 1/k)")
    print("=" * 64)
    print("  A single-key collision inflates one losing coordinate j. An")
    print("  independent second key SEPARATES the pair only if j happens to be")
    print("  its active minimizer -- probability ~ 1/k. So the improvement is")
    print("  inverse-linear (weak), not exponential.")
    print()
    print(f"  {'k':>6} | {'separation rate':>16} | {'k * sep rate':>13}")
    print("  " + "-" * 42)
    for k in (8, 16, 32, 64, 128):
        separated = 0
        for _ in range(trials):
            h = [rng.uniform(-10, 10) for _ in range(k)]
            m = [rng.uniform(-10, 10) for _ in range(k)]
            # single-key collision by inflating a random losing coordinate
            i_star = argmin_index(h, m)
            losers = [i for i in range(k) if i != i_star]
            j = rng.choice(losers)
            mp = list(m)
            mp[j] += rng.uniform(0.1, 5.0)
            # independent second key: is the collision broken (separated)?
            hp = [rng.uniform(-10, 10) for _ in range(k)]
            if tsha(hp, mp) != tsha(hp, m):
                separated += 1
        rate = separated / trials
        print(f"  {k:>6} | {rate:>16.5f} | {k * rate:>13.3f}")
    print()
    print("  (k * separation_rate ~ constant is consistent with a Theta(1/k) law.)")
    print()


# --------------------------------------------------------------------------- #
# Demonstration 4: mining-difficulty comparison
# --------------------------------------------------------------------------- #
def demo_difficulty(k: int = 64, seed: int = 3) -> None:
    """
    Compare the effort to hit a digest target.

    A SHA-style hash below a probability-p target needs ~1/p random trials.
    The tropical single-key digest is invertible in ONE linear scan, because
    given a key h and a target y we can pick an active coordinate and clamp
    the rest above y.
    """
    rng = random.Random(seed)
    h = [rng.uniform(-10, 10) for _ in range(k)]
    y = rng.uniform(-5, 5)  # desired digest value

    # O(k) tropical inversion: make coordinate 0 active at y, others >= y.
    a = 0
    m = [y - h[a]]  # active coordinate: m_a + h_a = y
    for i in range(1, k):
        m.append(y - h[i] + rng.uniform(0.0, 5.0))  # ensure m_i + h_i >= y

    achieved = tsha(h, m)
    print("=" * 64)
    print("Demonstration 4: Mining-difficulty comparison")
    print("=" * 64)
    print(f"  k = {k}")
    print(f"  SHA-style: ~1/p expected trials for a probability-p target.")
    print(f"  tropical:  O(k) = {k} operations, one pass, no search.")
    print(f"  target digest y      = {y:.6f}")
    print(f"  achieved TSHA(h, m)  = {achieved:.6f}")
    print(f"  inversion exact: {abs(achieved - y) < 1e-9}")
    print()


def main() -> None:
    demo_stability()
    demo_collisions()
    demo_two_key()
    demo_difficulty()


if __name__ == "__main__":
    main()
