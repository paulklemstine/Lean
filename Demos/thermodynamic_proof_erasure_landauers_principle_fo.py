"""
Thermodynamic Proof Erasure: Landauer's Principle for Mathematics
=================================================================

Numerical demonstrations of the main results of the formal development:

    * H(uniform on N points) = ln N                       (shannonEntropy_uniformProb)
    * H(p) <= ln N for every distribution p   (Gibbs)     (shannonEntropy_le_log_card)
    * an n-bit proof tree has entropy n * ln 2            (entropy_uniformProb_pow_two)
    * any compression 2^n -> 2^m erases >= (n-m) ln 2     (landauer_compression_lower_bound)
    * the residue map i |-> i mod 2^m attains it exactly  (landauer_compression_tight)
    * worked example: 1000 -> 100 steps => >= 900 k T ln2 (compression_cost_1000_to_100)

All functions are self-contained and use only the Python standard library.
"""

from __future__ import annotations

import math
import random
from typing import Callable, Sequence

# Physical constants (SI).
BOLTZMANN_K: float = 1.380649e-23  # J / K
ROOM_T: float = 300.0              # K
LN2: float = math.log(2.0)


# ---------------------------------------------------------------------------
# Core information-theoretic primitives
# ---------------------------------------------------------------------------
def shannon_entropy(p: Sequence[float]) -> float:
    """Shannon entropy in nats: H(p) = - sum_i p_i ln p_i, with 0 ln 0 := 0."""
    total = 0.0
    for prob in p:
        if prob > 0.0:
            total -= prob * math.log(prob)
    return total


def uniform_prob(n_points: int) -> list[float]:
    """The uniform distribution on `n_points` points."""
    if n_points <= 0:
        raise ValueError("need at least one point")
    return [1.0 / n_points] * n_points


def is_prob(p: Sequence[float], tol: float = 1e-9) -> bool:
    """Check that p is a probability distribution (nonnegative, sums to 1)."""
    return all(x >= -tol for x in p) and abs(sum(p) - 1.0) < tol


def pushforward(f: Callable[[int], int], p: Sequence[float], m_points: int) -> list[float]:
    """Pushforward of distribution p (length 2^n) along f into m_points configurations."""
    q = [0.0] * m_points
    for x, prob in enumerate(p):
        q[f(x)] += prob
    return q


def residue_map(m: int) -> Callable[[int], int]:
    """The bound-saturating residue compressor i |-> i mod 2^m."""
    modulus = 1 << m
    return lambda i: i % modulus


# ---------------------------------------------------------------------------
# Landauer cost of compression
# ---------------------------------------------------------------------------
def erased_information(
    f: Callable[[int], int], n: int, m: int, p: Sequence[float] | None = None
) -> float:
    """Erased information (nats) when compressing 2^n proofs to 2^m via f.

    Returns H(p) - H(f_* p).  By the theory this is >= (n - m) ln 2 when p is uniform.
    """
    src = list(p) if p is not None else uniform_prob(1 << n)
    img = pushforward(f, src, 1 << m)
    return shannon_entropy(src) - shannon_entropy(img)


def landauer_heat(erased_nats: float, k: float = BOLTZMANN_K, t: float = ROOM_T) -> float:
    """Dissipated heat (joules) for erasing `erased_nats` nats at temperature t."""
    return k * t * erased_nats


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_uniform_entropy() -> None:
    print("=" * 70)
    print("1. Entropy of the uniform distribution: H(uniform on N) = ln N")
    print("=" * 70)
    for n_points in (2, 4, 8, 1024):
        h = shannon_entropy(uniform_prob(n_points))
        print(f"   N = {n_points:>5}:  H = {h:.6f} nats   ln N = {math.log(n_points):.6f}"
              f"   ({h / LN2:.3f} bits)")
    print()


def demo_proof_tree_entropy() -> None:
    print("=" * 70)
    print("2. An n-step proof tree carries exactly n * ln 2 nats (= n bits)")
    print("=" * 70)
    for n in (1, 2, 5, 10):
        h = shannon_entropy(uniform_prob(1 << n))
        print(f"   n = {n:>2}:  H = {h:.6f} nats   n*ln2 = {n * LN2:.6f}"
              f"   => {h / LN2:.1f} bits")
    print()


def demo_gibbs_bound(trials: int = 5, n_points: int = 6, seed: int = 0) -> None:
    print("=" * 70)
    print("3. Gibbs / maximum entropy:  H(p) <= ln N  for every distribution p")
    print("=" * 70)
    rng = random.Random(seed)
    cap = math.log(n_points)
    print(f"   N = {n_points}, ceiling ln N = {cap:.6f} nats")
    for t in range(trials):
        raw = [rng.random() for _ in range(n_points)]
        s = sum(raw)
        p = [x / s for x in raw]
        h = shannon_entropy(p)
        ok = "OK" if h <= cap + 1e-12 else "VIOLATION"
        print(f"   trial {t}: H(p) = {h:.6f}  <=  {cap:.6f}  [{ok}]")
    print(f"   (uniform attains the ceiling: H = {shannon_entropy(uniform_prob(n_points)):.6f})")
    print()


def demo_compression_lower_bound(n: int = 8, m: int = 3, seed: int = 1) -> None:
    print("=" * 70)
    print("4. Landauer lower bound: ANY compression 2^n -> 2^m erases >= (n-m) ln 2")
    print("=" * 70)
    floor = (n - m) * LN2
    print(f"   n = {n}, m = {m}: theoretical floor (n-m)*ln2 = {floor:.6f} nats")
    rng = random.Random(seed)
    # Several arbitrary (random) compression maps; all must clear the floor.
    for label in range(4):
        # Freeze a random map into a table so it is a genuine function.
        table = [rng.randrange(1 << m) for _ in range(1 << n)]
        fmap = lambda x, _t=table: _t[x]  # noqa: E731
        erased = erased_information(fmap, n, m)
        ok = "OK" if erased >= floor - 1e-9 else "VIOLATION"
        print(f"   random map #{label}: erased = {erased:.6f} nats  >= {floor:.6f}  [{ok}]")
    print()


def demo_residue_tightness(n: int = 8, m: int = 3) -> None:
    print("=" * 70)
    print("5. Tightness: the residue map i |-> i mod 2^m attains the floor exactly")
    print("=" * 70)
    floor = (n - m) * LN2
    f = residue_map(m)
    erased = erased_information(f, n, m)
    img = pushforward(f, uniform_prob(1 << n), 1 << m)
    # Each fiber should have exactly 2^(n-m) elements.
    fiber_sizes = [0] * (1 << m)
    for x in range(1 << n):
        fiber_sizes[f(x)] += 1
    print(f"   n = {n}, m = {m}: floor (n-m)*ln2 = {floor:.6f} nats")
    print(f"   residue map erased = {erased:.6f} nats   (gap = {erased - floor:.2e})")
    print(f"   fiber sizes all equal 2^(n-m) = {1 << (n - m)}? "
          f"{all(s == (1 << (n - m)) for s in fiber_sizes)}")
    print(f"   pushforward uniform on 2^m = {1 << m} points? {is_prob(img)} and "
          f"max-min = {max(img) - min(img):.2e}")
    print()


def demo_worked_example(n: int = 1000, m: int = 100) -> None:
    print("=" * 70)
    print(f"6. Worked example: compressing a {n}-step proof to {m} steps")
    print("=" * 70)
    erased_nats = (n - m) * LN2
    erased_bits = n - m
    heat = landauer_heat(erased_nats)
    print(f"   bits erased        : {erased_bits}")
    print(f"   information erased  : (n-m)*ln2 = {erased_nats:.4f} nats")
    print(f"   minimum heat        : (n-m)*k*T*ln2 = {heat:.4e} J  at T = {ROOM_T} K")
    print(f"   i.e. about {heat * 1e18:.3f} attojoules -- tiny, but exact and unavoidable.")
    print()


def main() -> None:
    print("\nThermodynamic Proof Erasure -- numerical demonstrations\n")
    demo_uniform_entropy()
    demo_proof_tree_entropy()
    demo_gibbs_bound()
    demo_compression_lower_bound()
    demo_residue_tightness()
    demo_worked_example()
    print("All demonstrations consistent with the formally verified theorems.")


if __name__ == "__main__":
    main()
