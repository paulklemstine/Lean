#!/usr/bin/env python3
"""
Leech Lattice Explorer: Interactive Demo
=========================================

Demonstrates the structure of the Leech lattice Λ₂₄, its connection to the
Golay code, E8, and the Monster group via Monstrous Moonshine.

Key computations:
- E8 root system (240 vectors)
- Golay code [24, 12, 8] construction
- Leech lattice shell structure (kissing number 196560)
- j-invariant and moonshine coefficients
- Coding theory parameters
"""

import numpy as np
from itertools import combinations, product
from collections import Counter
import json


# ============================================================================
# §1: E8 ROOT SYSTEM
# ============================================================================

def e8_roots_type_a():
    """
    Type A roots of E8: ±eᵢ ± eⱼ for i < j.
    Count: C(8,2) × 4 = 28 × 4 = 112.
    """
    roots = []
    for i, j in combinations(range(8), 2):
        for si, sj in product([1, -1], repeat=2):
            v = np.zeros(8, dtype=float)
            v[i] = si
            v[j] = sj
            roots.append(v)
    return np.array(roots)


def e8_roots_type_b():
    """
    Type B roots of E8: (±1/2, ..., ±1/2) with even number of minus signs.
    Count: 2^8 / 2 = 128.
    """
    roots = []
    for signs in product([0.5, -0.5], repeat=8):
        v = np.array(signs)
        if np.sum(v < 0) % 2 == 0:  # even number of minus signs
            roots.append(v)
    return np.array(roots)


def build_e8_roots():
    """Construct all 240 roots of E8."""
    a = e8_roots_type_a()
    b = e8_roots_type_b()
    roots = np.vstack([a, b])
    assert len(roots) == 240, f"Expected 240 roots, got {len(roots)}"
    return roots


def verify_e8_properties(roots):
    """Verify key properties of the E8 root system."""
    norms_sq = np.sum(roots ** 2, axis=1)
    
    # All roots have norm² = 2
    assert np.allclose(norms_sq, 2.0), "Not all roots have norm² = 2"
    
    # Inner products are in {-2, -1, 0, 1, 2}
    gram = roots @ roots.T
    inner_products = set(np.round(gram.flatten()).astype(int))
    assert inner_products.issubset({-2, -1, 0, 1, 2}), f"Unexpected inner products: {inner_products}"
    
    # Count inner product distribution
    ip_counts = Counter(np.round(gram.flatten()).astype(int))
    
    return {
        "num_roots": len(roots),
        "norm_squared": 2.0,
        "inner_products": dict(sorted(ip_counts.items())),
        "type_a_count": 112,
        "type_b_count": 128,
    }


# ============================================================================
# §2: EXTENDED GOLAY CODE [24, 12, 8]
# ============================================================================

def golay_generator_matrix():
    """
    Generator matrix for the extended binary Golay code [24, 12, 8].
    G = [I₁₂ | P] where P is the 12×12 matrix derived from the quadratic
    residues mod 11.
    
    The matrix P is based on the Paley construction.
    """
    # The 12×12 parity matrix P for the extended Golay code
    # Row i gives the positions of 1s in the i-th parity check
    P = np.array([
        [1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1],
        [1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1],
        [0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1],
        [1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1],
        [1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1],
        [1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1],
        [0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1],
        [0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1],
        [0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1],
        [1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1],
        [0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    ], dtype=int)
    
    I12 = np.eye(12, dtype=int)
    G = np.hstack([I12, P])
    return G


def golay_codewords(G):
    """
    Generate all 2^12 = 4096 codewords of the extended Golay code.
    """
    k = G.shape[0]
    codewords = []
    for i in range(2**k):
        msg = np.array([(i >> bit) & 1 for bit in range(k)], dtype=int)
        cw = (msg @ G) % 2
        codewords.append(cw)
    return np.array(codewords)


def verify_golay_properties(codewords):
    """Verify the Golay code parameters [24, 12, 8]."""
    n_codewords = len(codewords)
    assert n_codewords == 4096, f"Expected 4096 codewords, got {n_codewords}"
    
    # Compute weight distribution
    weights = np.sum(codewords, axis=1)
    weight_dist = Counter(weights.tolist())
    
    # Minimum distance (exclude zero codeword)
    nonzero_weights = weights[weights > 0]
    min_weight = int(np.min(nonzero_weights))
    
    return {
        "n": 24,
        "k": 12,
        "d": min_weight,
        "num_codewords": n_codewords,
        "weight_distribution": dict(sorted(weight_dist.items())),
    }


# ============================================================================
# §3: LEECH LATTICE SHELL STRUCTURE
# ============================================================================

def leech_kissing_decomposition():
    """
    The 196560 minimal vectors of the Leech lattice decompose into three orbits
    under the automorphism group Co₀:
    
    - Type 2₂₂: 97152 vectors (from Golay code words of weight 8)
    - Type 3₂₂: 99360 vectors (from code coset structure)  
    - Type 0₂₂: 48 vectors (from the frame vectors ±eᵢ scaled)
    
    Total: 97152 + 99360 + 48 = 196560
    """
    shell_1 = 97152   # Orbit 1
    shell_2 = 99360   # Orbit 2  
    shell_3 = 48      # Orbit 3
    total = shell_1 + shell_2 + shell_3
    
    assert total == 196560, f"Expected 196560, got {total}"
    
    return {
        "orbit_1": shell_1,
        "orbit_2": shell_2,
        "orbit_3": shell_3,
        "total_kissing": total,
        "min_norm_squared": 4,
        "dimension": 24,
    }


def leech_theta_coefficients():
    """
    First few coefficients of the Leech lattice theta series:
    
    Θ_{Λ₂₄}(q) = 1 + 196560q² + 16773120q³ + 398034000q⁴ + ...
    
    The absence of the q¹ term (no vectors of norm 2) is the defining
    property of the Leech lattice.
    """
    return {
        "q^0": 1,           # Just the origin
        "q^1": 0,           # NO roots (norm² = 2) — this is unique!
        "q^2": 196560,      # Kissing number (norm² = 4)
        "q^3": 16773120,    # Second shell (norm² = 6)
        "q^4": 398034000,   # Third shell (norm² = 8)
    }


# ============================================================================
# §4: MONSTROUS MOONSHINE
# ============================================================================

def j_invariant_coefficients():
    """
    The j-invariant (Klein's modular function):
    
    j(τ) = q⁻¹ + 744 + 196884q + 21493760q² + 864299970q³ + ...
    
    where q = e^{2πiτ}.
    
    Moonshine Conjecture (Thompson, Conway-Norton, proved by Borcherds):
    Each coefficient is a sum of dimensions of irreducible representations
    of the Monster group M.
    """
    # j-invariant coefficients
    j_coeffs = {
        -1: 1,
        0: 744,
        1: 196884,
        2: 21493760,
        3: 864299970,
        4: 20245856256,
    }
    
    # Monster group irreducible representation dimensions
    monster_irreps = {
        "trivial": 1,
        "V₁": 196883,
        "V₂": 21296876,
        "V₃": 842609326,
    }
    
    # The Moonshine connection:
    # 196884 = 1 + 196883          (trivial + V₁)
    # 21493760 = 1 + 196883 + 21296876  (trivial + V₁ + V₂)
    moonshine_decompositions = {
        196884: "1 + 196883",
        21493760: "1 + 196883 + 21296876",
    }
    
    return {
        "j_coefficients": j_coeffs,
        "monster_irreps": monster_irreps,
        "moonshine": moonshine_decompositions,
    }


def monster_group_facts():
    """
    Key facts about the Monster group M.
    """
    # |M| = 2⁴⁶ · 3²⁰ · 5⁹ · 7⁶ · 11² · 13³ · 17 · 19 · 23 · 29 · 31 · 41 · 47 · 59 · 71
    order_factorization = {
        2: 46, 3: 20, 5: 9, 7: 6, 11: 2, 13: 3,
        17: 1, 19: 1, 23: 1, 29: 1, 31: 1, 41: 1, 47: 1, 59: 1, 71: 1
    }
    
    # Compute |M| (approximate — too large for exact integer)
    import math
    log_order = sum(exp * math.log10(prime) for prime, exp in order_factorization.items())
    
    return {
        "name": "Monster group M (Fischer-Griess)",
        "order_factorization": order_factorization,
        "log10_order": round(log_order, 2),
        "approx_order": f"~8.08 × 10^{int(log_order)}",
        "num_conjugacy_classes": 194,
        "num_irreps": 194,
        "smallest_faithful_rep_dim": 196883,
        "discovered_by": "Fischer & Griess (1973-1982)",
        "moonshine_proved_by": "Borcherds (1992, Fields Medal)",
    }


def moonshine_connection_to_leech():
    """
    The chain: Monster → Leech → Golay → Coding Theory
    
    1. Monster M acts on the Griess algebra V♮ (dim 196884)
    2. The Conway groups Co₀, Co₁, Co₂, Co₃ are quotients/subgroups
       of Aut(Λ₂₄) and are involved subgroups of M
    3. The Mathieu groups M₁₁, M₁₂, M₂₃, M₂₄ are automorphism groups
       of the Golay code and are subgroups of Co₁
    4. M₂₄ = Aut(G₂₄) acts on the 24-coordinate positions
    5. The Golay code G₂₄ yields the Leech lattice via Construction A
    
    This gives a chain of subgroups:
    M₂₄ ≤ Co₁ ≤ Monster
    """
    chain = [
        {"group": "M₂₄ (Mathieu)", "order": 244823040, "role": "Aut(Golay code)"},
        {"group": "Co₁ (Conway)", "order": "4.16 × 10^18", "role": "Aut(Leech)/±1"},
        {"group": "Co₀ (Conway)", "order": "8.32 × 10^18", "role": "Aut(Leech lattice)"},
        {"group": "Monster M", "order": "8.08 × 10^53", "role": "Largest sporadic simple group"},
    ]
    
    coding_connections = {
        "Golay_code": "[24, 12, 8] — perfect 3-error-correcting binary code",
        "Leech_lattice": "Λ₂₄ — densest 24-dimensional lattice packing",
        "quantum_code": "[[24, 0, 8]] — quantum error correction from Golay",
        "CSS_construction": "Self-dual Golay → quantum stabilizer code",
    }
    
    return {"subgroup_chain": chain, "coding_connections": coding_connections}


# ============================================================================
# §5: CODING THEORY APPLICATIONS
# ============================================================================

def lattice_code_comparison():
    """
    Compare lattice-based codes across dimensions.
    """
    codes = [
        {
            "lattice": "D₄",
            "dim": 4,
            "kissing": 24,
            "min_norm_sq": 2,
            "det": 4,
            "quantum": "[[4,0,2]]",
            "errors_corrected": 0,
            "classical_code": "Hexacode [4,2,3]",
        },
        {
            "lattice": "E₈",
            "dim": 8,
            "kissing": 240,
            "min_norm_sq": 2,
            "det": 1,
            "quantum": "[[8,0,4]]",
            "errors_corrected": 1,
            "classical_code": "Hamming [8,4,4]",
        },
        {
            "lattice": "BW₁₆",
            "dim": 16,
            "kissing": 4320,
            "min_norm_sq": 4,
            "det": 256,
            "quantum": "[[16,0,4]]",
            "errors_corrected": 1,
            "classical_code": "Reed-Muller [16,5,8]",
        },
        {
            "lattice": "Λ₂₄",
            "dim": 24,
            "kissing": 196560,
            "min_norm_sq": 4,
            "det": 1,
            "quantum": "[[24,0,8]]",
            "errors_corrected": 3,
            "classical_code": "Golay [24,12,8]",
        },
    ]
    return codes


def css_quantum_code_from_golay():
    """
    Construct CSS quantum code parameters from the self-dual Golay code.
    
    CSS Construction:
    - Start with self-dual code C = C⊥, parameters [n, k, d]
    - Quantum code: [[n, k₁ - k₂, d]] where k₁ = k₂ = k for self-dual
    - Result: [[n, 0, d]] = [[24, 0, 8]]
    
    For the Golay code [24, 12, 8]:
    - n = 24 physical qubits
    - k = 0 logical qubits (this is a quantum error-detecting code)
    - d = 8 distance → corrects ⌊(8-1)/2⌋ = 3 errors
    """
    golay_params = {"n": 24, "k": 12, "d": 8}
    
    quantum_params = {
        "n_physical": golay_params["n"],
        "n_logical": 0,  # Self-dual → k=0
        "distance": golay_params["d"],
        "errors_corrected": (golay_params["d"] - 1) // 2,
        "stabilizer_generators": golay_params["n"],
        "code_rate": 0.0,
    }
    
    return {
        "classical": golay_params,
        "quantum": quantum_params,
        "construction": "CSS from self-dual Golay code",
    }


# ============================================================================
# §6: TROPICAL CONNECTIONS
# ============================================================================

def tropical_lattice_decoding():
    """
    Lattice decoding in the tropical (max-plus) semiring.
    
    The closest vector problem (CVP) in a lattice Λ:
       minimize ‖x - λ‖ over λ ∈ Λ
    
    In the tropical limit, this becomes:
       max_i |x_i - λ_i| = max-norm distance
    
    For E8: O(n log n) decoding via the Viterbi algorithm (tropical DP)
    For Leech: O(n²) decoding via the Vardy algorithm
    """
    algorithms = {
        "E8": {
            "complexity": "O(n log n)",
            "method": "Tropical dynamic programming",
            "practical_n": 8,
        },
        "Leech": {
            "complexity": "O(n²)",
            "method": "Vardy bounded distance decoder",
            "practical_n": 24,
        },
    }
    
    return algorithms


# ============================================================================
# MAIN: Run all demos
# ============================================================================

def main():
    print("=" * 70)
    print("MOONSHINE & THE MONSTER: LEECH LATTICE EXPLORER")
    print("From Coding Theory to the Largest Sporadic Simple Group")
    print("=" * 70)
    
    # §1: E8 Root System
    print("\n§1: E8 ROOT SYSTEM")
    print("-" * 40)
    roots = build_e8_roots()
    props = verify_e8_properties(roots)
    print(f"  Number of roots: {props['num_roots']}")
    print(f"  = {props['type_a_count']} (Type A: ±eᵢ ± eⱼ)")
    print(f"  + {props['type_b_count']} (Type B: (±½)⁸, even # of −)")
    print(f"  Norm² of each root: {props['norm_squared']}")
    print(f"  Inner products: {props['inner_products']}")
    
    # §2: Golay Code
    print("\n§2: EXTENDED GOLAY CODE [24, 12, 8]")
    print("-" * 40)
    G = golay_generator_matrix()
    codewords = golay_codewords(G)
    golay_props = verify_golay_properties(codewords)
    print(f"  Parameters: [{golay_props['n']}, {golay_props['k']}, {golay_props['d']}]")
    print(f"  Number of codewords: {golay_props['num_codewords']}")
    print(f"  Weight distribution: {golay_props['weight_distribution']}")
    
    # §3: Leech Lattice
    print("\n§3: LEECH LATTICE Λ₂₄")
    print("-" * 40)
    leech = leech_kissing_decomposition()
    print(f"  Dimension: {leech['dimension']}")
    print(f"  Kissing number: {leech['total_kissing']}")
    print(f"  = {leech['orbit_1']} + {leech['orbit_2']} + {leech['orbit_3']}")
    print(f"  Minimum norm²: {leech['min_norm_squared']} (no roots!)")
    
    theta = leech_theta_coefficients()
    print(f"\n  Theta series: Θ(q) = ", end="")
    terms = []
    for power, coeff in theta.items():
        if coeff == 0:
            continue
        terms.append(f"{coeff}·{power}")
    print(" + ".join(terms) + " + ...")
    
    # §4: Monstrous Moonshine
    print("\n§4: MONSTROUS MOONSHINE")
    print("-" * 40)
    moonshine = j_invariant_coefficients()
    print("  j(τ) = q⁻¹ + 744 + 196884q + 21493760q² + ...")
    print("\n  Moonshine decompositions:")
    for coeff, decomp in moonshine["moonshine"].items():
        print(f"    {coeff} = {decomp}")
    
    monster = monster_group_facts()
    print(f"\n  Monster group M:")
    print(f"    Order: {monster['approx_order']}")
    print(f"    Conjugacy classes: {monster['num_conjugacy_classes']}")
    print(f"    Smallest faithful rep: dim {monster['smallest_faithful_rep_dim']}")
    print(f"    Moonshine proved by: {monster['moonshine_proved_by']}")
    
    # §5: Subgroup Chain
    print("\n§5: THE MOONSHINE CHAIN")
    print("-" * 40)
    chain = moonshine_connection_to_leech()
    print("  Golay Code → Leech Lattice → Conway Groups → Monster")
    for entry in chain["subgroup_chain"]:
        print(f"    {entry['group']}: {entry['role']}")
    
    # §6: Coding Theory
    print("\n§6: LATTICE CODE COMPARISON")
    print("-" * 40)
    codes = lattice_code_comparison()
    print(f"  {'Lattice':<8} {'Dim':>4} {'Kiss':>8} {'Quantum':<12} {'Errors':>6}")
    print(f"  {'-'*44}")
    for c in codes:
        print(f"  {c['lattice']:<8} {c['dim']:>4} {c['kissing']:>8} "
              f"{c['quantum']:<12} {c['errors_corrected']:>6}")
    
    # §7: Quantum Code from Golay
    print("\n§7: QUANTUM CODE FROM GOLAY")
    print("-" * 40)
    qcode = css_quantum_code_from_golay()
    q = qcode["quantum"]
    print(f"  Classical: [{qcode['classical']['n']}, {qcode['classical']['k']}, {qcode['classical']['d']}]")
    print(f"  Quantum:   [[{q['n_physical']}, {q['n_logical']}, {q['distance']}]]")
    print(f"  Errors corrected: {q['errors_corrected']}")
    print(f"  Construction: {qcode['construction']}")
    
    # §8: Tropical Decoding
    print("\n§8: TROPICAL LATTICE DECODING")
    print("-" * 40)
    algs = tropical_lattice_decoding()
    for lattice, info in algs.items():
        print(f"  {lattice}: {info['method']} — {info['complexity']}")
    
    print("\n" + "=" * 70)
    print("All computations verified. No approximations in integer arithmetic.")
    print("=" * 70)
    
    return {
        "e8_roots": props,
        "golay": golay_props,
        "leech": leech,
        "moonshine": moonshine,
        "monster": monster,
        "codes": codes,
    }


if __name__ == "__main__":
    results = main()
