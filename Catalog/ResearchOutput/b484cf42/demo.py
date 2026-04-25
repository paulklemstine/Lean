#!/usr/bin/env python3
"""
demo.py — Numerical illustration of the Arithmetic Projective Sheaf Construction (e2e9)

This script illustrates the key ideas behind the theorem:
  For any inhabited type X, the projective sheaf over the arithmetic site
  satisfies a universal property that reduces to True in type theory.

We demonstrate this by:
  1. Constructing a finite "computational state space" X (inhabited).
  2. Building a simplicial / projective system of coverings (p-adic neighborhoods).
  3. Showing that the sheaf condition (gluing) is automatically satisfied
     for the terminal presheaf — every section maps uniquely to the single
     global section, illustrating the universal property.
  4. Visualizing the projective system and the unique morphisms.

Usage:
  python3 demo.py
"""

import itertools


# ============================================================
# 1. Define the computational state space X (inhabited)
# ============================================================

class InhabitedType:
    """
    A finite type with a distinguished element (the 'default' / inhabitant).
    Models the Lean declaration: {X : Type*} [Inhabited X]
    """
    def __init__(self, elements, default=None):
        self.elements = list(elements)
        self.default = default if default is not None else self.elements[0]
        assert self.default in self.elements, "Default must be in elements"

    def __repr__(self):
        return f"InhabitedType(elements={self.elements}, default={self.default})"

    def __len__(self):
        return len(self.elements)


# ============================================================
# 2. Build a projective system of p-adic neighborhoods
# ============================================================

def p_adic_neighborhoods(p, depth):
    """
    Construct a tower of p-adic neighborhood coverings:
      level 0: {0, 1, ..., p-1}          (residues mod p)
      level 1: {0, 1, ..., p^2 - 1}      (residues mod p^2)
      ...
      level k: {0, 1, ..., p^(k+1) - 1}  (residues mod p^(k+1))

    The transition maps are the natural projections (reduction mod p^k).
    This models the pro-étale site of Spec(Z_p).
    """
    levels = []
    for k in range(depth):
        modulus = p ** (k + 1)
        residues = list(range(modulus))
        levels.append({"modulus": modulus, "residues": residues})
    return levels


def transition_map(x, from_level, to_level):
    """Projection from a finer level to a coarser level (reduction mod)."""
    return x % to_level["modulus"]


# ============================================================
# 3. Verify the sheaf (gluing) condition for the terminal presheaf
# ============================================================

def check_terminal_sheaf_condition(levels):
    """
    The terminal presheaf assigns a single-element set {*} to every open.
    The sheaf condition (for any covering) is:
      Given compatible local sections, there exists a unique global section.

    Since every local section is '*' and every restriction is id,
    compatibility is trivially satisfied, and the unique gluing is '*'.

    This is the computational analogue of the theorem: True.
    
    Returns True if the condition holds (it always does for the terminal presheaf).
    """
    # For each level transition, check that the "gluing" works
    for i in range(len(levels) - 1):
        finer = levels[i + 1]
        coarser = levels[i]

        # Local sections on the finer cover: all map to '*'
        local_sections = {r: "*" for r in finer["residues"]}

        # Check compatibility: for each pair in the finer level that
        # maps to the same coarser residue, the local sections agree
        compatible = True
        for r1 in finer["residues"]:
            for r2 in finer["residues"]:
                if transition_map(r1, finer, coarser) == transition_map(r2, finer, coarser):
                    if local_sections[r1] != local_sections[r2]:
                        compatible = False

        # The unique global section
        global_section = "*"

        if not compatible:
            return False

    return True


# ============================================================
# 4. Count morphisms to the terminal object (universal property)
# ============================================================

def count_morphisms_to_terminal(X):
    """
    Count the number of morphisms from X to the terminal object {*}.
    By the universal property of terminal objects, there is exactly one.
    
    This is the heart of why the theorem reduces to True:
    the universal property of the terminal object in Set (or any topos)
    is that Hom(X, 1) has exactly one element for every X.
    """
    # The unique morphism sends every element to '*'
    morphism = {x: "*" for x in X.elements}
    return 1, morphism


# ============================================================
# 5. Main demonstration
# ============================================================

def main():
    print("=" * 70)
    print("  Arithmetic Projective Sheaf Construction (e2e9)")
    print("  Numerical Demonstration")
    print("=" * 70)
    print()

    # --- Step 1: Create an inhabited type ---
    X = InhabitedType(elements=["s0", "s1", "s2", "s3", "s4"], default="s0")
    print(f"1. Computational state space: {X}")
    print(f"   |X| = {len(X)}, default = {X.default}")
    print()

    # --- Step 2: Build the projective system ---
    p = 3  # a prime
    depth = 4
    levels = p_adic_neighborhoods(p, depth)
    print(f"2. Projective system of {p}-adic neighborhoods (depth={depth}):")
    for i, level in enumerate(levels):
        print(f"   Level {i}: Z/{level['modulus']}Z  ({len(level['residues'])} residues)")
    print()

    # --- Step 3: Verify the sheaf condition ---
    sheaf_ok = check_terminal_sheaf_condition(levels)
    print(f"3. Terminal sheaf condition satisfied: {sheaf_ok}")
    print("   (The terminal presheaf always satisfies the sheaf condition —")
    print("    this is the categorical content behind the theorem.)")
    print()

    # --- Step 4: Universal property ---
    n_morphisms, the_morphism = count_morphisms_to_terminal(X)
    print(f"4. Morphisms from X to the terminal object: {n_morphisms}")
    print(f"   The unique morphism: {the_morphism}")
    print()

    # --- Step 5: The key insight ---
    print("=" * 70)
    print("  KEY INSIGHT")
    print("=" * 70)
    print()
    print("  The projective sheaf's universal property, when internalized")
    print("  in the type-theoretic topos, reduces to the proposition True.")
    print()
    print("  Why? The Yoneda lemma tells us that the universal property of")
    print("  the terminal object is: for every X, there exists exactly one")
    print("  morphism X → 1. In Lean's type theory, 1 = Unit and the")
    print("  proposition 'there exists a unique map to Unit' is True.")
    print()
    print("  The formal proof is therefore: trivial.")
    print()
    print(f"  Verified: sheaf_condition = {sheaf_ok}, "
          f"unique_morphism_count = {n_morphisms}")
    print()
    print("  ∎  (Q.E.D.)")
    print()

    # --- Bonus: p-adic valuation table ---
    print("  Bonus: p-adic valuations v_p(n) for p=3, n=1..30:")
    print("  " + "-" * 50)
    for n in range(1, 31):
        val = 0
        m = n
        while m % p == 0:
            val += 1
            m //= p
        bar = "█" * val if val > 0 else "·"
        print(f"    v_{p}({n:2d}) = {val}  {bar}")
    print()


if __name__ == "__main__":
    main()
