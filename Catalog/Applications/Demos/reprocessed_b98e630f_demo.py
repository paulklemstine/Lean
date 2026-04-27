#!/usr/bin/env python3
"""
demo.py — Quantum Berggren Superposition
=========================================

Illustrates how Pythagorean triples from the Berggren tree
encode normalized quantum superposition amplitudes.

Each primitive triple (a, b, c) with a² + b² = c² maps to
the qubit state |ψ⟩ = (a/c)|0⟩ + (b/c)|1⟩, which is
automatically normalized because the Pythagorean relation
guarantees (a/c)² + (b/c)² = 1.

The Berggren tree generates ALL primitive Pythagorean triples
via three matrix transformations from the seed (3, 4, 5).

Run: python3 demo.py
"""

import numpy as np
from math import gcd

# ─── Berggren matrices ────────────────────────────────────────────────
# These three matrices, acting on a primitive Pythagorean triple (a,b,c),
# produce three new primitive Pythagorean triples.
# Together they generate the full Berggren tree.

A = np.array([[ 1, -2,  2],
              [ 2, -1,  2],
              [ 2, -2,  3]])

B = np.array([[ 1,  2,  2],
              [ 2,  1,  2],
              [ 2,  2,  3]])

C = np.array([[-1,  2,  2],
              [-2,  1,  2],
              [-2,  2,  3]])


def generate_berggren_tree(seed, depth):
    """
    Generate Pythagorean triples from the Berggren tree
    up to a given depth via BFS.

    Parameters
    ----------
    seed : tuple (a, b, c) — the root triple (3, 4, 5)
    depth : int — tree depth to explore

    Returns
    -------
    list of (a, b, c) triples
    """
    triples = []
    current_level = [np.array(seed)]

    for d in range(depth):
        next_level = []
        for v in current_level:
            triples.append(tuple(int(x) for x in v))
            for M in [A, B, C]:
                child = M @ v
                # Take absolute values to ensure positive triples
                child = np.abs(child)
                next_level.append(child)
        current_level = next_level

    # Add the last level
    for v in current_level:
        triples.append(tuple(int(x) for x in v))

    return triples


def triple_to_quantum_state(a, b, c):
    """
    Map a Pythagorean triple to a quantum state.

    Given (a, b, c) with a² + b² = c², the state is:
        |ψ⟩ = (a/c)|0⟩ + (b/c)|1⟩

    This is normalized because (a/c)² + (b/c)² = 1.

    In the formal Lean proof, this corresponds to the encoding
    Φ : 𝕋 → ℂ² that maps triples to qubit amplitudes.
    """
    alpha = a / c  # amplitude for |0⟩
    beta = b / c   # amplitude for |1⟩
    return np.array([alpha, beta])


def is_primitive(a, b, c):
    """
    Check if a triple is primitive (coprime).

    In the quantum interpretation, primitivity corresponds to
    irreducibility of the quantum state — it cannot be factored
    into a simpler representation.
    """
    return gcd(gcd(abs(a), abs(b)), abs(c)) == 1


def main():
    """
    Main demonstration: generate Berggren tree triples and
    show their quantum state encodings.
    """
    print("=" * 65)
    print("  QUANTUM BERGGREN SUPERPOSITION — Numerical Demonstration")
    print("=" * 65)
    print()

    # ── Key Insight ──────────────────────────────────────────────
    print("KEY INSIGHT:")
    print("Every primitive Pythagorean triple (a, b, c) naturally")
    print("encodes a normalized qubit state |ψ⟩ = (a/c)|0⟩ + (b/c)|1⟩.")
    print("The Berggren tree generates ALL such states recursively.")
    print("Coprimality ↔ state irreducibility.")
    print()

    # ── Generate triples from the Berggren tree ──────────────────
    seed = (3, 4, 5)
    depth = 3
    triples = generate_berggren_tree(seed, depth)

    # Remove duplicates and sort
    triples = sorted(set(triples), key=lambda t: t[2])

    print(f"Generated {len(triples)} triples from Berggren tree (depth {depth}):")
    print("-" * 65)
    print(f"{'Triple':<20} {'Primitive?':<12} {'|ψ⟩ = α|0⟩ + β|1⟩':<28} {'‖ψ‖²'}")
    print("-" * 65)

    for a, b, c in triples[:20]:  # Show first 20
        psi = triple_to_quantum_state(a, b, c)
        norm_sq = psi[0]**2 + psi[1]**2
        prim = is_primitive(a, b, c)

        # Verify the Pythagorean relation => normalization
        assert abs(a**2 + b**2 - c**2) < 1e-10, f"Not Pythagorean: {(a,b,c)}"
        assert abs(norm_sq - 1.0) < 1e-10, f"Not normalized: {norm_sq}"

        print(f"({a:>3}, {b:>3}, {c:>3})     {'Yes' if prim else 'No':<12} "
              f"{psi[0]:>7.4f}|0⟩ + {psi[1]:.4f}|1⟩    {norm_sq:.6f}")

    print("-" * 65)
    print()

    # ── Demonstrate tree structure ───────────────────────────────
    print("BERGGREN TREE STRUCTURE (first 2 levels):")
    print()
    print("                    (3, 4, 5)")
    print("                   /    |    \\")
    print("            (5,12,13) (21,20,29) (15,8,17)")
    print()

    # Verify children
    v = np.array([3, 4, 5])
    children = [tuple(int(x) for x in np.abs(M @ v)) for M in [A, B, C]]
    for child in children:
        a, b, c = child
        assert a**2 + b**2 == c**2, f"Child {child} not Pythagorean!"
        assert is_primitive(a, b, c), f"Child {child} not primitive!"
    print(f"  Children verified: {children}")
    print(f"  All children are primitive Pythagorean triples. ✓")
    print()

    # ── Quantum state angles on the Bloch sphere ─────────────────
    print("BLOCH SPHERE ANGLES (θ such that |ψ⟩ = cos(θ)|0⟩ + sin(θ)|1⟩):")
    print("-" * 45)
    for a, b, c in triples[:10]:
        psi = triple_to_quantum_state(a, b, c)
        theta = np.arctan2(psi[1], psi[0])
        print(f"  ({a:>3}, {b:>3}, {c:>3})  →  θ = {np.degrees(theta):>7.2f}°"
              f"  ({theta:.4f} rad)")
    print("-" * 45)
    print()

    # ── Summary statistics ────────────────────────────────────────
    all_primitive = all(is_primitive(a, b, c) for a, b, c in triples)
    all_normalized = all(
        abs(triple_to_quantum_state(a, b, c) @ triple_to_quantum_state(a, b, c) - 1.0) < 1e-10
        for a, b, c in triples
    )

    print("VERIFICATION SUMMARY:")
    print(f"  Total triples generated:   {len(triples)}")
    print(f"  All primitive (coprime):   {'✓' if all_primitive else '✗'}")
    print(f"  All states normalized:     {'✓' if all_normalized else '✗'}")
    print(f"  Pythagorean relation holds: ✓ (by construction)")
    print()
    print("The formal Lean 4 proof (berggren_quantum_state) establishes")
    print("the type-theoretic foundation for this correspondence.")
    print()
    print("QED. ∎")


if __name__ == "__main__":
    main()
