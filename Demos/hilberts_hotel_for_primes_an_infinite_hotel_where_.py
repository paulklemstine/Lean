"""Hilbert's Hotel for Primes: numerical demonstrations.

Room ``n`` of an infinite hotel holds the ``n``-th prime ``p_n`` (indexed from 0,
so ``p_0 = 2``).  A *rearrangement* is a permutation ``sigma`` of the room
indices; after rearranging, room ``n`` holds ``p_{sigma(n)}``.  We measure
disruption by the *displacement ratio*

    R_sigma(n) = p_{sigma(n)} / p_n .

A rearrangement is *well behaved* when ``R_sigma(n) -> 1``.  This script
illustrates the three theorems:

  1. Finite-support permutations are well behaved (ratio eventually == 1).
  2. Density: any permutation is matched on a finite initial segment by a
     finite-support (hence well-behaved) permutation.
  3. Non-universality: an involution built from prime-doubling long-range swaps
     has displacement ratio >= 2 infinitely often.

The code is self-contained (standard library only) with type hints throughout.
"""

from __future__ import annotations

import random
from typing import Callable, Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Prime generation
# --------------------------------------------------------------------------- #
def first_primes(count: int) -> List[int]:
    """Return the first ``count`` primes as a list ``[p_0, p_1, ...]``."""
    if count <= 0:
        return []
    primes: List[int] = []
    candidate: int = 2
    while len(primes) < count:
        is_prime: bool = True
        for q in primes:
            if q * q > candidate:
                break
            if candidate % q == 0:
                is_prime = False
                break
        if is_prime:
            primes.append(candidate)
        candidate += 1
    return primes


# --------------------------------------------------------------------------- #
# Displacement ratios (Algorithm A)
# --------------------------------------------------------------------------- #
def displacement_ratios(
    primes: List[int], sigma: List[int]
) -> List[float]:
    """Return ``[p[sigma[n]] / p[n] for n in range(len(sigma))]``."""
    return [primes[sigma[n]] / primes[n] for n in range(len(sigma))]


def tail_summary(
    ratios: List[float], eps: float = 0.05, tail_frac: float = 0.5
) -> Dict[str, float]:
    """Summarize the tail of a ratio sequence.

    Reports the mean of the last ``tail_frac`` portion, its max deviation from
    1, and the fraction of tail entries within ``eps`` of 1.
    """
    start: int = int(len(ratios) * (1.0 - tail_frac))
    tail: List[float] = ratios[start:]
    if not tail:
        return {"mean": float("nan"), "max_dev": float("nan"), "frac_near_1": 0.0}
    mean: float = sum(tail) / len(tail)
    max_dev: float = max(abs(r - 1.0) for r in tail)
    frac_near_1: float = sum(1 for r in tail if abs(r - 1.0) <= eps) / len(tail)
    return {"mean": mean, "max_dev": max_dev, "frac_near_1": frac_near_1}


# --------------------------------------------------------------------------- #
# Finite-support approximant (Algorithm B) -- proof of the density theorem
# --------------------------------------------------------------------------- #
def finite_support_approximant(
    sigma: List[int], horizon: int, size: int
) -> List[int]:
    """Build a finite-support permutation of ``{0,...,size-1}`` agreeing with
    ``sigma`` on ``{0,...,horizon-1}`` by the inductive transposition
    construction (Lemma 4.1).

    ``sigma`` must be a permutation of ``range(size)`` and ``horizon <= size``.
    """
    tau: List[int] = list(range(size))          # start at identity
    pos: List[int] = list(range(size))          # pos[value] = index holding value
    for n in range(horizon):
        target: int = sigma[n]
        a: int = tau[n]                          # currently at index n
        if a == target:
            continue
        # swap so that index n holds ``target``
        j: int = pos[target]                     # index currently holding target
        tau[n], tau[j] = tau[j], tau[n]
        pos[a], pos[target] = pos[target], pos[a]
    return tau


def support(sigma: List[int]) -> List[int]:
    """Indices actually moved by ``sigma``."""
    return [n for n, v in enumerate(sigma) if v != n]


# --------------------------------------------------------------------------- #
# Bad permutation (Algorithm C) -- proof of non-universality
# --------------------------------------------------------------------------- #
def jump_sequence(primes: List[int]) -> List[int]:
    """Greedy landmarks: j_0 = 0, and j_{k+1} is the least b > j_k with
    ``2 * p[j_k] <= p[b]`` (bounded by the available primes)."""
    jumps: List[int] = [0]
    while True:
        current: int = jumps[-1]
        threshold: int = 2 * primes[current]
        nxt: int = -1
        for b in range(current + 1, len(primes)):
            if primes[b] >= threshold:
                nxt = b
                break
        if nxt == -1:
            break
        jumps.append(nxt)
    return jumps


def bad_permutation(primes: List[int]) -> List[int]:
    """Involution beta on ``range(len(primes))`` swapping landmark pairs
    (j_0<->j_1, j_2<->j_3, ...) and fixing everything else."""
    size: int = len(primes)
    beta: List[int] = list(range(size))
    jumps: List[int] = jump_sequence(primes)
    for i in range(0, len(jumps) - 1, 2):
        a, b = jumps[i], jumps[i + 1]
        beta[a], beta[b] = beta[b], beta[a]
    return beta


def random_permutation(size: int, rng: random.Random) -> List[int]:
    """A uniform random permutation of ``range(size)``."""
    perm: List[int] = list(range(size))
    rng.shuffle(perm)
    return perm


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_finite_support(primes: List[int]) -> None:
    print("=" * 70)
    print("DEMO 1  Finite-support permutation is well behaved (ratio -> 1)")
    print("=" * 70)
    size: int = len(primes)
    sigma: List[int] = list(range(size))
    # a small finite disturbance: swap a few low rooms
    for a, b in [(0, 3), (1, 7), (2, 5)]:
        sigma[a], sigma[b] = sigma[b], sigma[a]
    ratios = displacement_ratios(primes, sigma)
    last_moved = max(support(sigma))
    print(f"support = {support(sigma)},  last moved index = {last_moved}")
    print(f"R(n) for n = {last_moved} .. {last_moved + 3}:",
          [round(ratios[n], 6) for n in range(last_moved, last_moved + 4)])
    print(f"All R(n) == 1 for n > {last_moved}? ",
          all(ratios[n] == 1.0 for n in range(last_moved + 1, size)))
    print()


def demo_density(primes: List[int], rng: random.Random) -> None:
    print("=" * 70)
    print("DEMO 2  Density: match a wild permutation on a finite segment")
    print("=" * 70)
    size: int = len(primes)
    horizon: int = 20
    sigma: List[int] = random_permutation(size, rng)
    tau: List[int] = finite_support_approximant(sigma, horizon, size)
    agree: bool = all(tau[i] == sigma[i] for i in range(horizon))
    ratios = displacement_ratios(primes, tau)
    last_moved = max(support(tau)) if support(tau) else -1
    print(f"horizon N = {horizon}")
    print(f"tau agrees with sigma on first {horizon} rooms? {agree}")
    print(f"tau has finite support, last moved index = {last_moved}")
    print(f"R_tau(n) == 1 for all n > {last_moved}? ",
          all(ratios[n] == 1.0 for n in range(last_moved + 1, size)))
    print()


def demo_random_ratios(primes: List[int], rng: random.Random,
                       trials: int = 10) -> None:
    print("=" * 70)
    print("DEMO 3  Tail behavior of random permutations (mostly NOT near 1)")
    print("=" * 70)
    size: int = len(primes)
    print(f"{'trial':>5} {'tail mean R':>14} {'max |R-1|':>12} "
          f"{'frac within 5%':>16}")
    for t in range(trials):
        sigma = random_permutation(size, rng)
        ratios = displacement_ratios(primes, sigma)
        s = tail_summary(ratios)
        print(f"{t:>5} {s['mean']:>14.4f} {s['max_dev']:>12.2f} "
              f"{s['frac_near_1']:>16.4f}")
    print("\nUniformly random permutations scramble magnitudes wildly:")
    print("the fraction of rooms with R(n) ~ 1 is tiny -- density is about")
    print("carefully chosen permutations, not typical ones.")
    print()


def demo_bad_permutation(primes: List[int]) -> None:
    print("=" * 70)
    print("DEMO 4  Non-universality: prime-doubling swaps give R >= 2 often")
    print("=" * 70)
    beta = bad_permutation(primes)
    jumps = jump_sequence(primes)
    ratios = displacement_ratios(primes, beta)
    print(f"number of landmarks found: {len(jumps)}")
    print("even-landmark ratios R_beta(j_2i) (should all be >= 2):")
    rows: List[Tuple[int, int, float]] = []
    for i in range(0, len(jumps) - 1, 2):
        n = jumps[i]
        rows.append((i, n, ratios[n]))
    for i, n, r in rows[:12]:
        print(f"  i={i:>3}  room j_{2 * (i // 2) if False else i}={n:>6}  "
              f"R_beta(n) = {r:.4f}   (>= 2? {r >= 2.0})")
    print(f"all even-landmark ratios >= 2? {all(r >= 2.0 for _, _, r in rows)}")
    print("Since this recurs for infinitely many rooms, R_beta cannot -> 1.")
    print()


def main() -> None:
    rng = random.Random(20260710)
    primes = first_primes(5000)
    print(f"Loaded first {len(primes)} primes: "
          f"p_0={primes[0]}, p_1={primes[1]}, ..., p_last={primes[-1]}\n")
    demo_finite_support(primes)
    demo_density(primes, rng)
    demo_random_ratios(primes, rng)
    demo_bad_permutation(primes)


if __name__ == "__main__":
    main()
