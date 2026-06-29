"""
Thermodynamic Proof Erasure: Landauer's Principle for Mathematics
=================================================================

Numerical demonstrations of the four main results, modeling a length-n proof as
an n-bit string (Proof n = {0,1}^n, of which there are exactly 2^n).

Results demonstrated:
  1. card_proof                       : |Proof n| = 2^n
  2. proof_erasure_landauer_cost      : normalizing 2^n proofs costs exactly k*T*n*ln 2
  3. lossless_proof_compression_card  : injective encoder needs 2^n <= m codewords
  4. no_universal_proof_compressor    : shorter proofs number 2^n - 1 < 2^n, so no injection
  5. reversible vs deterministic heat : injective => 0 heat; collapsing => >= 0 heat

All functions are self-contained, type-hinted, and use only the standard library.
"""

from __future__ import annotations

import itertools
import math
from collections import Counter
from typing import Callable, Iterable

# Physical constant (J/K). Use 1.0 to read costs "in bits times ln 2".
BOLTZMANN_K: float = 1.380649e-23


# --------------------------------------------------------------------------- #
# Core model: proofs as bitstrings                                            #
# --------------------------------------------------------------------------- #
def proofs(n: int) -> list[tuple[int, ...]]:
    """Enumerate all 2^n length-n proofs (bitstrings)."""
    return list(itertools.product((0, 1), repeat=n))


def card_proof(n: int) -> int:
    """Result 1: there are exactly 2^n length-n proofs."""
    return 2 ** n


# --------------------------------------------------------------------------- #
# Entropy and Landauer cost                                                   #
# --------------------------------------------------------------------------- #
def shannon_entropy(dist: dict[object, float]) -> float:
    """Shannon entropy in nats: -sum p log p, with 0 log 0 = 0."""
    return -sum(p * math.log(p) for p in dist.values() if p > 0.0)


def uniform_dist(states: Iterable[object]) -> dict[object, float]:
    """Uniform distribution over the given finite set of states."""
    states = list(states)
    w = 1.0 / len(states)
    return {s: w for s in states}


def dirac_dist(point: object) -> dict[object, float]:
    """Point mass on a single state (a chosen normal form)."""
    return {point: 1.0}


def landauer_cost(entropy_drop: float, k: float, T: float) -> float:
    """Heat dissipated = k * T * (entropy drop)."""
    return k * T * entropy_drop


def proof_erasure_landauer_cost(n: int, k: float, T: float) -> float:
    """
    Result 2: collapsing all 2^n length-n proofs to one normal form dissipates
    exactly k*T*n*ln 2.  We verify the closed form against the entropy drop.
    """
    states = proofs(n)
    normal_form = states[0]
    drop = shannon_entropy(uniform_dist(states)) - shannon_entropy(dirac_dist(normal_form))
    return landauer_cost(drop, k, T)


# --------------------------------------------------------------------------- #
# Pushforward (image measure) and the data-processing inequality             #
# --------------------------------------------------------------------------- #
def pushforward(f: Callable[[object], object], dist: dict[object, float]) -> dict[object, float]:
    """Image measure: weight of y is the total weight of its fiber f^{-1}(y)."""
    out: dict[object, float] = {}
    for x, p in dist.items():
        y = f(x)
        out[y] = out.get(y, 0.0) + p
    return out


def transform_heat(n: int, f: Callable[[object], object], k: float, T: float) -> float:
    """
    Landauer heat of running f on the uniform distribution over Proof n:
        k * T * (H(uniform) - H(f_* uniform)).
    Injective f  => 0 (Result 4, reversible_proof_transform_free).
    Any f        => >= 0 (Result 5, proof_compression_nonneg_heat).
    """
    src = uniform_dist(proofs(n))
    drop = shannon_entropy(src) - shannon_entropy(pushforward(f, src))
    return landauer_cost(drop, k, T)


# --------------------------------------------------------------------------- #
# Compression counting bounds                                                 #
# --------------------------------------------------------------------------- #
def is_injective(f: Callable[[object], object], domain: Iterable[object]) -> bool:
    """Check whether f is injective (lossless) on the given domain."""
    seen: set[object] = set()
    for x in domain:
        y = f(x)
        if y in seen:
            return False
        seen.add(y)
    return True


def num_shorter_proofs(n: int) -> int:
    """Result 3: total number of proofs of length strictly less than n = 2^n - 1."""
    return sum(2 ** k for k in range(n))


def find_compression_collision(
    n: int, f: Callable[[tuple[int, ...]], object]
) -> tuple[tuple[int, ...], tuple[int, ...]] | None:
    """
    Given any map f from length-n proofs into shorter proofs, return an explicit
    collision (two proofs sent to the same output), guaranteed to exist by
    no_universal_proof_compressor.
    """
    images: dict[object, tuple[int, ...]] = {}
    for x in proofs(n):
        y = f(x)
        if y in images:
            return (images[y], x)
        images[y] = x
    return None


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_counting() -> None:
    print("=" * 70)
    print("Result 1  -  card_proof:  |Proof n| = 2^n")
    print("=" * 70)
    for n in range(0, 8):
        assert len(proofs(n)) == card_proof(n) == 2 ** n
        print(f"  n = {n}:  enumerated {len(proofs(n)):4d} proofs  =  2^{n}")
    print()


def demo_normalization_cost() -> None:
    print("=" * 70)
    print("Result 2  -  proof_erasure_landauer_cost = k*T*n*ln 2  (exact)")
    print("=" * 70)
    k, T = BOLTZMANN_K, 300.0  # room temperature
    print(f"  k = {k:.6e} J/K,  T = {T} K,  k*T*ln2 per bit = {k*T*math.log(2):.3e} J")
    for n in range(1, 9):
        measured = proof_erasure_landauer_cost(n, k, T)
        closed = k * T * n * math.log(2)
        assert math.isclose(measured, closed, rel_tol=1e-12)
        print(f"  n = {n}:  heat = {measured:.4e} J   (= {n} bits x k*T*ln2)")
    print()


def demo_lossless_bound() -> None:
    print("=" * 70)
    print("Result 3a -  lossless_proof_compression_card:  injective => 2^n <= m")
    print("=" * 70)
    n = 4
    # An injective encoder into m codewords: identity into range >= 2^n works.
    for m in (2 ** n - 1, 2 ** n, 2 ** n + 5):
        # try to build an injective map into {0,...,m-1}
        enc = {x: i for i, x in enumerate(proofs(n)) if i < m}
        injective = len(set(enc.values())) == len(proofs(n)) and len(enc) == len(proofs(n))
        feasible = 2 ** n <= m
        print(f"  n={n}, m={m:3d}:  2^n <= m is {feasible!s:5}  ->  lossless encoder "
              f"{'exists' if injective else 'IMPOSSIBLE (pigeonhole)'}")
        assert injective == feasible
    print()


def demo_no_universal_compressor() -> None:
    print("=" * 70)
    print("Result 3b -  no_universal_proof_compressor:  2^n - 1 < 2^n")
    print("=" * 70)
    for n in range(1, 9):
        shorter = num_shorter_proofs(n)
        assert shorter == 2 ** n - 1 < 2 ** n
        print(f"  n = {n}:  shorter proofs = {shorter:4d}  <  {2**n:4d} = length-n proofs")

    # Exhibit a concrete failed 'compressor' and the forced collision.
    n = 3
    shorter_list = [p for k in range(n) for p in proofs(k)]

    def compressor(x: tuple[int, ...]) -> tuple[int, ...]:
        # Any deterministic map into shorter proofs; here, drop the last bit-ish.
        idx = int("".join(map(str, x)), 2) % len(shorter_list)
        return shorter_list[idx]

    collision = find_compression_collision(n, compressor)
    print(f"\n  Forced collision for n={n}: proofs {collision[0]} and {collision[1]}")
    print("  map to the same shorter proof -> compression is NOT lossless.\n")


def demo_reversibility() -> None:
    print("=" * 70)
    print("Results 4 & 5 -  reversible = 0 heat;  deterministic >= 0 heat")
    print("=" * 70)
    k, T, n = BOLTZMANN_K, 300.0, 4

    # Reversible: bitwise NOT is a bijection of Proof n.
    flip = lambda x: tuple(1 - b for b in x)
    h_rev = transform_heat(n, flip, k, T)
    print(f"  reversible (bit-flip), injective={is_injective(flip, proofs(n))}: "
          f"heat = {h_rev:.3e} J  (expected 0)")
    assert math.isclose(h_rev, 0.0, abs_tol=1e-30)

    # Irreversible: zero out the last bit (merges pairs of proofs).
    erase_last = lambda x: x[:-1] + (0,)
    h_irr = transform_heat(n, erase_last, k, T)
    print(f"  irreversible (erase last bit), injective={is_injective(erase_last, proofs(n))}: "
          f"heat = {h_irr:.3e} J  (expected k*T*ln2 = {k*T*math.log(2):.3e})")
    assert h_irr >= -1e-30
    print()


def main() -> None:
    demo_counting()
    demo_normalization_cost()
    demo_lossless_bound()
    demo_no_universal_compressor()
    demo_reversibility()
    print("All demonstrations passed: the four theorems hold numerically.")


if __name__ == "__main__":
    main()
