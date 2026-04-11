#!/usr/bin/env python3
"""
Monstrous Moonshine: j-invariant and Monster Representations
=============================================================

This demo explores the deep connection between:
1. The j-invariant (modular function for SL(2,ℤ))
2. The Monster group (largest sporadic simple group)
3. Vertex operator algebras (the Moonshine module V♮)
4. Error-correcting codes

The key insight (Conway-Norton conjecture, proved by Borcherds 1992):
Every coefficient of the j-function decomposes as a sum of dimensions
of irreducible representations of the Monster.
"""

import numpy as np
from collections import defaultdict
import math


# ============================================================================
# §1: j-INVARIANT COMPUTATION
# ============================================================================

def eisenstein_series_coefficients(k, num_terms=20):
    """
    Compute coefficients of the normalized Eisenstein series E_k(τ).
    
    E_k(τ) = 1 - (2k/B_k) Σ σ_{k-1}(n) q^n
    
    where B_k is the k-th Bernoulli number and σ_{k-1}(n) = Σ_{d|n} d^{k-1}.
    """
    # Bernoulli numbers
    bernoulli = {2: 1/6, 4: -1/30, 6: 1/42, 8: -1/30, 10: 5/66, 12: -691/2730}
    
    if k not in bernoulli:
        raise ValueError(f"Bernoulli number B_{k} not available")
    
    B_k = bernoulli[k]
    
    def sigma(n, s):
        """Sum of s-th powers of divisors of n."""
        return sum(d**s for d in range(1, n+1) if n % d == 0)
    
    normalization = -2 * k / B_k
    
    coeffs = [1]  # constant term
    for n in range(1, num_terms):
        coeffs.append(int(round(normalization * sigma(n, k-1))))
    
    return coeffs


def j_invariant_coefficients(num_terms=10):
    """
    Compute coefficients of the j-invariant:
    
    j(τ) = E₄(τ)³ / Δ(τ) = q⁻¹ + 744 + 196884q + 21493760q² + ...
    
    where Δ(τ) = (E₄³ - E₆²)/1728 is the modular discriminant.
    
    We use: j = E₄³/Δ and compute via q-expansion.
    """
    N = num_terms + 5  # extra terms for safety
    
    # E₄ coefficients
    e4 = eisenstein_series_coefficients(4, N)
    
    # E₆ coefficients  
    e6 = eisenstein_series_coefficients(6, N)
    
    # E₄³ via polynomial multiplication
    e4_cubed = polynomial_multiply(polynomial_multiply(e4[:N], e4[:N], N), e4[:N], N)
    
    # E₆² 
    e6_squared = polynomial_multiply(e6[:N], e6[:N], N)
    
    # Δ = (E₄³ - E₆²) / 1728
    delta = [(e4_cubed[i] - e6_squared[i]) / 1728 for i in range(N)]
    
    # j = E₄³ / Δ  (as formal power series)
    # Since Δ starts with q (i.e., delta[0] = 0, delta[1] = 1, ...),
    # j starts with q⁻¹
    j_coeffs = formal_division(e4_cubed, delta, num_terms + 2)
    
    return j_coeffs


def polynomial_multiply(a, b, n):
    """Multiply two truncated power series to n terms."""
    result = [0] * n
    for i in range(min(len(a), n)):
        for j in range(min(len(b), n)):
            if i + j < n:
                result[i + j] += a[i] * b[j]
    return result


def formal_division(num, den, n):
    """
    Compute num/den as formal power series.
    Since den starts with 0 (i.e., Δ has no constant term),
    the quotient starts with q⁻¹.
    
    Returns coefficients of q⁻¹, q⁰, q¹, q², ...
    """
    # den[0] should be 0, den[1] should be 1 (for Δ)
    assert abs(den[0]) < 1e-6, f"Δ should have no constant term, got {den[0]}"
    
    # Shift: divide both by q, so den starts at 1
    den_shifted = den[1:]
    # num stays the same, but now represents num/q relative to den/q
    
    # Now compute num / den_shifted as power series
    result = []
    remainder = list(num[:n+2])
    
    for i in range(n):
        if i >= len(remainder):
            result.append(0)
            continue
        coeff = remainder[i] / den_shifted[0]
        result.append(int(round(coeff)))
        for j in range(len(den_shifted)):
            if i + j < len(remainder):
                remainder[i + j] -= coeff * den_shifted[j]
    
    return result


def display_j_invariant():
    """Display the j-invariant expansion and moonshine decompositions."""
    # Known exact values (computed to high precision)
    j_known = {
        -1: 1,
        0: 744,
        1: 196884,
        2: 21493760,
        3: 864299970,
        4: 20245856256,
        5: 333202640600,
        6: 4252023300096,
    }
    
    # Monster irreducible representation dimensions (first few)
    monster_dims = [
        1,          # χ₁ (trivial)
        196883,     # χ₂
        21296876,   # χ₃
        842609326,  # χ₄
        18538750076,# χ₅
        19360062527,# χ₆
    ]
    
    # Moonshine decompositions (McKay-Thompson)
    decompositions = {
        196884: [(1, 1), (1, 196883)],
        21493760: [(1, 1), (1, 196883), (1, 21296876)],
        864299970: [(2, 1), (2, 196883), (1, 21296876), (1, 842609326)],
    }
    
    print("THE j-INVARIANT AND MONSTROUS MOONSHINE")
    print("=" * 60)
    
    print("\nj(τ) = q⁻¹ + 744 + Σ c(n) qⁿ")
    print("\nCoefficients c(n):")
    for n, c in sorted(j_known.items()):
        if n == -1:
            print(f"  q⁻¹:  {c}")
        elif n == 0:
            print(f"  q⁰:   {c}")
        else:
            print(f"  q{superscript(n)}:   {c:>15,}")
    
    print("\nMonster group irreducible representations:")
    for i, d in enumerate(monster_dims[:6]):
        print(f"  χ_{i+1}: dim = {d:>15,}")
    
    print("\nMoonshine decompositions (c(n) = Σ mᵢ · dim(χᵢ)):")
    for coeff, parts in decompositions.items():
        decomp_str = " + ".join(f"{m}·{d}" for m, d in parts)
        check = sum(m * d for m, d in parts)
        print(f"  {coeff:>12,} = {decomp_str}")
        assert check == coeff, f"Decomposition check failed: {check} ≠ {coeff}"
    
    return j_known


def superscript(n):
    """Convert integer to Unicode superscript."""
    sup_map = str.maketrans("0123456789", "⁰¹²³⁴⁵⁶⁷⁸⁹")
    return str(n).translate(sup_map)


# ============================================================================
# §2: McKAY-THOMPSON SERIES
# ============================================================================

def mckay_thompson_series():
    """
    For each conjugacy class g of the Monster, there is a McKay-Thompson series:
    
    T_g(τ) = Σ Tr(g | Vₙ) qⁿ
    
    where Vₙ is the n-th graded piece of the Moonshine module V♮.
    
    Key property: Each T_g is the Hauptmodul (principal modulus) for a
    genus-zero subgroup of SL(2,ℝ).
    """
    # Selected McKay-Thompson series (for small-order conjugacy classes)
    series = {
        "1A": {
            "order": 1,
            "description": "Identity → j-invariant",
            "first_terms": [1, 744, 196884, 21493760],
            "genus_zero_group": "SL(2,ℤ)",
        },
        "2A": {
            "order": 2,
            "description": "Baby Monster involution",
            "first_terms": [1, 104, 4372, 96256],
            "genus_zero_group": "Γ₀(2)+",
        },
        "2B": {
            "order": 2,
            "description": "Fischer involution",
            "first_terms": [1, -104, 4372, -96256],
            "genus_zero_group": "Γ₀(2)",
        },
        "3A": {
            "order": 3,
            "description": "Thompson group element",
            "first_terms": [1, 42, 783, 8672],
            "genus_zero_group": "Γ₀(3)+",
        },
        "5A": {
            "order": 5,
            "description": "Harada-Norton element",
            "first_terms": [1, 6, 134, 760],
            "genus_zero_group": "Γ₀(5)+",
        },
    }
    
    print("\nMcKAY-THOMPSON SERIES")
    print("=" * 60)
    
    for label, info in series.items():
        print(f"\n  T_{label}(τ): order {info['order']} — {info['description']}")
        terms = info['first_terms']
        print(f"    = q⁻¹ + {terms[1]} + {terms[2]}q + {terms[3]}q² + ...")
        print(f"    Genus-zero group: {info['genus_zero_group']}")
    
    return series


# ============================================================================
# §3: CODING THEORY CONNECTION
# ============================================================================

def coding_theory_from_moonshine():
    """
    The Moonshine module V♮ connects to coding theory through:
    
    1. V♮ is built from the Leech lattice vertex operator algebra
    2. The Leech lattice comes from the Golay code (Construction A)
    3. The Golay code is the unique [24, 12, 8] self-dual doubly-even code
    4. The automorphism group of the Golay code is M₂₄ ≤ Monster
    
    This gives a functorial chain:
    Coding Theory → Lattice Theory → VOA → Moonshine → Monster
    """
    
    chain = {
        "level_1": {
            "object": "Binary Golay code G₂₄",
            "parameters": "[24, 12, 8]",
            "symmetry": "M₂₄ (Mathieu group, order 244823040)",
            "property": "Unique perfect 3-error-correcting code",
        },
        "level_2": {
            "object": "Leech lattice Λ₂₄",
            "parameters": "dim 24, kissing 196560",
            "symmetry": "Co₀ (Conway group, order 8315553613086720000)",
            "property": "Unique even unimodular rootless lattice in dim 24",
        },
        "level_3": {
            "object": "Leech lattice VOA V_Λ",
            "parameters": "central charge c = 24",
            "symmetry": "Co₁ (Conway simple group)",
            "property": "Conformal field theory on Leech lattice",
        },
        "level_4": {
            "object": "Moonshine module V♮",
            "parameters": "central charge c = 24",
            "symmetry": "Monster M (order ~8.08 × 10⁵³)",
            "property": "Z₂-orbifold of Leech lattice VOA",
        },
    }
    
    print("\nCODING THEORY → MOONSHINE CHAIN")
    print("=" * 60)
    
    for level, info in chain.items():
        print(f"\n  Level {level[-1]}: {info['object']}")
        print(f"    Parameters: {info['parameters']}")
        print(f"    Symmetry: {info['symmetry']}")
        print(f"    Property: {info['property']}")
    
    # Quantum error correction from moonshine
    print("\n\nQUANTUM ERROR CORRECTION FROM MOONSHINE")
    print("-" * 40)
    
    quantum_codes = [
        {
            "source": "Golay code",
            "quantum": "[[24, 0, 8]]",
            "errors": 3,
            "construction": "CSS (self-dual)",
        },
        {
            "source": "Hexacode (from M₁₂)",
            "quantum": "[[6, 0, 4]]",
            "errors": 1,
            "construction": "CSS",
        },
        {
            "source": "E₈ lattice code",
            "quantum": "[[8, 0, 4]]",
            "errors": 1,
            "construction": "CSS (self-dual)",
        },
        {
            "source": "Ternary Golay (from M₁₁)",
            "quantum": "[[12, 0, 6]]",
            "errors": 2,
            "construction": "CSS over GF(3)",
        },
    ]
    
    print(f"  {'Source':<26} {'Quantum':<14} {'Errors':>6}")
    print(f"  {'-'*48}")
    for qc in quantum_codes:
        print(f"  {qc['source']:<26} {qc['quantum']:<14} {qc['errors']:>6}")
    
    return chain


# ============================================================================
# §4: MODULAR FORMS AND THETA SERIES
# ============================================================================

def modular_forms_connection():
    """
    Key modular forms connecting Moonshine to coding/lattice theory:
    
    1. Θ_{E₈}(τ) = E₄(τ)  (the E₈ theta series IS the Eisenstein series)
    2. Θ_{Λ₂₄}(τ) = ...   (related to Ramanujan's tau function)
    3. j(τ) = E₄³/Δ       (the modular invariant)
    4. Δ(τ) = η(τ)²⁴      (Ramanujan's discriminant)
    
    The eta function: η(τ) = q^{1/24} Π(1 - qⁿ)
    """
    
    # E₄ coefficients = E₈ theta coefficients
    e4_coeffs = eisenstein_series_coefficients(4, 10)
    
    print("\nMODULAR FORMS AND LATTICE THETA SERIES")
    print("=" * 60)
    
    print("\n  E₄(τ) = Θ_{E₈}(τ) — the E₈ theta series is a modular form!")
    print("  E₄ = 1 + 240q + 2160q² + 6720q³ + ...")
    print(f"  Computed: {e4_coeffs[:6]}")
    
    # Verify kissing numbers
    assert e4_coeffs[1] == 240, f"E₈ kissing number should be 240, got {e4_coeffs[1]}"
    print(f"\n  ✓ E₈ kissing number (coefficient of q): {e4_coeffs[1]}")
    
    # 240 = 112 + 128 decomposition
    print(f"  ✓ 240 = 112 (type A: ±eᵢ±eⱼ) + 128 (type B: (±½)⁸)")
    
    # The connection to sphere packing
    print("\n  Sphere packing density from theta series:")
    print("  ρ(E₈) = π⁴/384 ≈ 0.2537 (optimal in dim 8, Viazovska 2016)")
    print("  ρ(Λ₂₄) = π¹²/12! ≈ 0.001930 (optimal in dim 24, CKMRV 2017)")
    
    return e4_coeffs


# ============================================================================
# MAIN
# ============================================================================

def main():
    print("=" * 70)
    print("MONSTROUS MOONSHINE: j-INVARIANT AND THE MONSTER GROUP")
    print("Connecting Modular Forms, Lattices, and Coding Theory")
    print("=" * 70)
    
    # §1: j-invariant
    j_coeffs = display_j_invariant()
    
    # §2: McKay-Thompson series
    mckay = mckay_thompson_series()
    
    # §3: Coding theory connection
    chain = coding_theory_from_moonshine()
    
    # §4: Modular forms
    e4 = modular_forms_connection()
    
    print("\n" + "=" * 70)
    print("'The Monster is the symmetry group of string theory on the")
    print(" Leech lattice.' — conceptual summary of Monstrous Moonshine")
    print("=" * 70)


if __name__ == "__main__":
    main()
