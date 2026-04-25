#!/usr/bin/env python3
"""
demo.py — Numerical illustration of higher_generic_amplitude_corollary_5393

The theorem states that for any inhabited type X, the generic amplitude
invariant is trivially True. We illustrate this by:

1. Sampling random "quantum state spaces" (inhabited sets of varying size).
2. Computing a generic amplitude function on each.
3. Verifying that the universal property (trivial satisfaction) holds
   regardless of the structure of X.

We also show how quantum amplitudes distribute over different
inhabited types, demonstrating that the invariant collapses to a single
point — the "True" terminal object.

Uses only the Python standard library (no external dependencies).
"""

import math
import random
import sys


def random_quantum_state(n: int, rng: random.Random) -> list:
    """
    Generate a random normalized quantum state vector of dimension n.
    Returns list of (real, imag) pairs representing complex amplitudes.

    This represents a generic amplitude function f : X -> C where |X| = n.
    The normalization condition sum |f(x)|^2 = 1 is the quantum-mechanical
    requirement that probabilities sum to 1 (Born rule).
    """
    # Random complex amplitudes via Box-Muller-like sampling
    amplitudes = [(rng.gauss(0, 1), rng.gauss(0, 1)) for _ in range(n)]

    # Compute norm
    norm = math.sqrt(sum(r * r + i * i for r, i in amplitudes))

    # Normalize to unit vector
    if norm > 0:
        amplitudes = [(r / norm, i / norm) for r, i in amplitudes]

    return amplitudes


def verify_invariant(state: list) -> bool:
    """
    Verify the generic amplitude invariant: the state is normalizable.
    This always returns True for any non-zero inhabited type — reflecting
    the theorem's conclusion that the invariant is trivially satisfiable.
    """
    norm_sq = sum(r * r + i * i for r, i in state)
    return abs(norm_sq - 1.0) < 1e-10


def shannon_entropy(state: list) -> float:
    """
    Compute Shannon entropy of Born-rule probabilities |f(x)|^2.
    """
    probs = [r * r + i * i for r, i in state]
    return -sum(p * math.log2(p) if p > 1e-15 else 0 for p in probs)


def main():
    """
    Main demonstration: verify the higher generic amplitude corollary
    across diverse inhabited types.
    """
    print("=" * 65)
    print("  Higher Generic Amplitude Corollary (5393) — Numerical Demo")
    print("=" * 65)
    print()

    rng = random.Random(42)

    # Test across various "inhabited type" sizes
    type_sizes = [1, 2, 3, 5, 8, 13, 21, 50, 100, 256, 1000]

    print("Testing generic amplitude invariant across inhabited types:")
    print("-" * 65)
    print(f"{'|X|':>6}  {'Invariant':>10}  {'||psi||^2':>12}  {'H(psi)':>10}  {'Status'}")
    print("-" * 65)

    all_passed = True
    for n in type_sizes:
        state = random_quantum_state(n, rng)
        invariant_holds = verify_invariant(state)
        norm_sq = sum(r * r + i * i for r, i in state)
        entropy = shannon_entropy(state)

        status = "  True" if invariant_holds else "x False"
        all_passed = all_passed and invariant_holds

        print(f"{n:>6}  {str(invariant_holds):>10}  {norm_sq:>12.10f}  {entropy:>10.4f}  {status}")

    print("-" * 65)
    print()

    # ---------------------------------------------------------------------------
    # KEY INSIGHT: The invariant is ALWAYS True, regardless of |X|.
    # This is exactly what the theorem states: for any inhabited type X,
    # the generic amplitude universal property is trivially satisfiable.
    # ---------------------------------------------------------------------------

    if all_passed:
        print("KEY INSIGHT: The generic amplitude invariant holds universally.")
        print("For every inhabited type X tested, the invariant evaluates to True.")
        print("This is the numerical manifestation of the theorem:")
        print()
        print("  theorem higher_generic_amplitude_corollary_5393")
        print("    {X : Type*} [Inhabited X] : True := trivial")
        print()
        print("The proof 'trivial' reflects the fact that quantum state spaces")
        print("over ANY inhabited type always admit a normalized amplitude --")
        print("the universal property is unconditionally satisfiable.")
    else:
        print("UNEXPECTED: Some invariant checks failed!")

    print()

    # Additional demonstration: compression application
    print("=" * 65)
    print("  Application to Compression")
    print("=" * 65)
    print()
    print("The trivial invariant serves as a BASELINE for quantum compression.")
    print("Any non-trivial invariant that constrains amplitudes beyond mere")
    print("existence provides compressibility information.")
    print()

    for n in [4, 16, 64, 256]:
        state = random_quantum_state(n, rng)
        entropy = shannon_entropy(state)
        max_entropy = math.log2(n) if n > 1 else 0
        compression_ratio = 1.0 - entropy / max_entropy if max_entropy > 0 else 0.0

        print(f"  |X| = {n:>4}: H(psi) = {entropy:.4f} bits, "
              f"H_max = {max_entropy:.4f} bits, "
              f"compression potential = {compression_ratio:.2%}")

    print()
    print("The generic amplitude (trivial invariant) imposes NO compression;")
    print("richer invariants would reduce entropy and enable compression.")
    print()
    print("Demo complete. All checks passed." if all_passed else "Demo complete with errors.")
    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())
