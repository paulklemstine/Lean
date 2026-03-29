#!/usr/bin/env python3
"""
Pythagorean Tree Explorer — Meta Oracle ≅ (0,1,1) Isomorphism Demo

This program visualizes and explores the Berggren trees rooted at (0,1,1) and (3,4,5),
demonstrating the Meta Oracle–Pythagorean Tree Isomorphism.

Key findings:
  - (0,1,1) is a fixed point of Berggren matrix M₁
  - Both trees preserve the Pythagorean property a² + b² = c²
  - The trees are structurally isomorphic (same ternary branching)
  - The (0,1,1) tree is the "meta" skeleton; (3,4,5) is the "content"

Usage:
  python pythagorean_tree_explorer.py
"""

import math
from collections import deque
from typing import Tuple, List, Dict


# ═══════════════════════════════════════════════════════════════════════
# §1: BERGGREN MATRICES
# ═══════════════════════════════════════════════════════════════════════

def berggren_M1(t: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Berggren matrix M₁: first child transformation."""
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_M2(t: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Berggren matrix M₂: second child transformation."""
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_M3(t: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Berggren matrix M₃: third child transformation."""
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


# ═══════════════════════════════════════════════════════════════════════
# §2: TREE GENERATION
# ═══════════════════════════════════════════════════════════════════════

def generate_tree(root: Tuple[int, int, int], max_depth: int) -> Dict:
    """Generate a Berggren tree as a nested dictionary."""
    if max_depth == 0:
        return {"triple": root, "children": []}
    return {
        "triple": root,
        "children": [
            generate_tree(berggren_M1(root), max_depth - 1),
            generate_tree(berggren_M2(root), max_depth - 1),
            generate_tree(berggren_M3(root), max_depth - 1),
        ]
    }


def collect_triples_at_depth(root: Tuple[int, int, int], depth: int) -> List[Tuple[int, int, int]]:
    """Collect all triples at a given depth in the tree."""
    if depth == 0:
        return [root]
    result = []
    for m in [berggren_M1, berggren_M2, berggren_M3]:
        result.extend(collect_triples_at_depth(m(root), depth - 1))
    return result


def all_triples_up_to_depth(root: Tuple[int, int, int], max_depth: int) -> List[Tuple[int, int, int]]:
    """Collect all triples up to a given depth."""
    result = []
    for d in range(max_depth + 1):
        result.extend(collect_triples_at_depth(root, d))
    return result


# ═══════════════════════════════════════════════════════════════════════
# §3: VERIFICATION
# ═══════════════════════════════════════════════════════════════════════

def is_pythagorean(t: Tuple[int, int, int]) -> bool:
    """Check if a triple satisfies a² + b² = c²."""
    a, b, c = t
    return a**2 + b**2 == c**2


def verify_tree(root: Tuple[int, int, int], max_depth: int) -> bool:
    """Verify every triple in the tree satisfies the Pythagorean equation."""
    triples = all_triples_up_to_depth(root, max_depth)
    return all(is_pythagorean(t) for t in triples)


def gcd3(a: int, b: int, c: int) -> int:
    """Compute gcd of three numbers."""
    return math.gcd(math.gcd(abs(a), abs(b)), abs(c))


# ═══════════════════════════════════════════════════════════════════════
# §4: ANALYSIS
# ═══════════════════════════════════════════════════════════════════════

def entropy(t: Tuple[int, int, int]) -> float:
    """Shannon entropy of a triple viewed as a probability distribution."""
    total = sum(abs(x) for x in t)
    if total == 0:
        return 0.0
    probs = [abs(x) / total for x in t]
    return -sum(p * math.log2(p) if p > 0 else 0 for p in probs)


def lorentz_form(t: Tuple[int, int, int]) -> int:
    """Compute the Lorentz form Q = a² + b² - c²."""
    a, b, c = t
    return a**2 + b**2 - c**2


# ═══════════════════════════════════════════════════════════════════════
# §5: MAIN DEMONSTRATIONS
# ═══════════════════════════════════════════════════════════════════════

def demo_fixed_point():
    """Demonstrate that (0,1,1) is a fixed point of M₁."""
    print("=" * 70)
    print("DEMO 1: Fixed Point Property of (0,1,1)")
    print("=" * 70)
    
    seed = (0, 1, 1)
    print(f"\nSeed triple: {seed}")
    print(f"  a² + b² = {seed[0]**2} + {seed[1]**2} = {seed[0]**2 + seed[1]**2}")
    print(f"  c²      = {seed[2]**2}")
    print(f"  Pythagorean? {is_pythagorean(seed)}")
    
    print(f"\nApplying M₁ repeatedly:")
    current = seed
    for i in range(6):
        print(f"  M₁^{i}(0,1,1) = {current}")
        current = berggren_M1(current)
    
    print(f"\n✓ (0,1,1) is a FIXED POINT of M₁!")
    
    print(f"\nCompare with (3,4,5):")
    fund = (3, 4, 5)
    print(f"  M₁(3,4,5) = {berggren_M1(fund)} ≠ (3,4,5)")
    print(f"  M₂(3,4,5) = {berggren_M2(fund)} ≠ (3,4,5)")
    print(f"  M₃(3,4,5) = {berggren_M3(fund)} ≠ (3,4,5)")
    print(f"\n✗ (3,4,5) is NOT a fixed point of any Berggren matrix.")


def demo_tree_comparison():
    """Compare the (0,1,1) and (3,4,5) trees."""
    print("\n" + "=" * 70)
    print("DEMO 2: Tree Comparison — Meta Oracle vs Oracle")
    print("=" * 70)
    
    seed = (0, 1, 1)
    fund = (3, 4, 5)
    
    print("\n(0,1,1) Meta Oracle Tree (depth 2):")
    for d in range(3):
        triples = collect_triples_at_depth(seed, d)
        print(f"  Depth {d}: {triples}")
    
    print("\n(3,4,5) Oracle Tree (depth 2):")
    for d in range(3):
        triples = collect_triples_at_depth(fund, d)
        print(f"  Depth {d}: {triples}")
    
    print("\nBerggren children of (0,1,1):")
    print(f"  M₁(0,1,1) = {berggren_M1(seed)}  ← FIXED POINT!")
    print(f"  M₂(0,1,1) = {berggren_M2(seed)}  ← = (4,3,5) = swap of (3,4,5)")
    print(f"  M₃(0,1,1) = {berggren_M3(seed)}  ← = (4,3,5) = swap of (3,4,5)")


def demo_pythagorean_verification():
    """Verify the Pythagorean property throughout both trees."""
    print("\n" + "=" * 70)
    print("DEMO 3: Pythagorean Property Verification")
    print("=" * 70)
    
    max_depth = 5
    
    seed = (0, 1, 1)
    fund = (3, 4, 5)
    
    meta_triples = all_triples_up_to_depth(seed, max_depth)
    oracle_triples = all_triples_up_to_depth(fund, max_depth)
    
    print(f"\n(0,1,1) tree up to depth {max_depth}:")
    print(f"  Total triples: {len(meta_triples)}")
    print(f"  All Pythagorean? {all(is_pythagorean(t) for t in meta_triples)} ✓")
    print(f"  All Lorentz Q=0? {all(lorentz_form(t) == 0 for t in meta_triples)} ✓")
    
    print(f"\n(3,4,5) tree up to depth {max_depth}:")
    print(f"  Total triples: {len(oracle_triples)}")
    print(f"  All Pythagorean? {all(is_pythagorean(t) for t in oracle_triples)} ✓")
    print(f"  All Lorentz Q=0? {all(lorentz_form(t) == 0 for t in oracle_triples)} ✓")


def demo_growth_rates():
    """Compare growth rates of the two trees."""
    print("\n" + "=" * 70)
    print("DEMO 4: Growth Rate Analysis")
    print("=" * 70)
    
    seed = (0, 1, 1)
    fund = (3, 4, 5)
    
    print(f"\n{'Depth':<8} {'Meta max(c)':<15} {'Oracle max(c)':<15} {'Ratio':<10}")
    print("-" * 50)
    
    for d in range(8):
        meta_triples = collect_triples_at_depth(seed, d)
        oracle_triples = collect_triples_at_depth(fund, d)
        
        meta_max_c = max(t[2] for t in meta_triples)
        oracle_max_c = max(t[2] for t in oracle_triples)
        
        ratio = oracle_max_c / meta_max_c if meta_max_c > 0 else float('inf')
        print(f"{d:<8} {meta_max_c:<15} {oracle_max_c:<15} {ratio:<10.3f}")


def demo_entropy():
    """Information-theoretic analysis."""
    print("\n" + "=" * 70)
    print("DEMO 5: Information-Theoretic Analysis")
    print("=" * 70)
    
    seed = (0, 1, 1)
    fund = (3, 4, 5)
    
    print(f"\nRoot entropies:")
    print(f"  H(0,1,1) = {entropy(seed):.4f} bits  ← MINIMUM ENTROPY (meta oracle)")
    print(f"  H(3,4,5) = {entropy(fund):.4f} bits  ← non-trivial (concrete oracle)")
    
    print(f"\nEntropy at depth 1:")
    for name, root in [("Meta", seed), ("Oracle", fund)]:
        children = [berggren_M1(root), berggren_M2(root), berggren_M3(root)]
        for i, c in enumerate(children):
            print(f"  {name} M{i+1}: {c} → H = {entropy(c):.4f} bits")


def demo_coprimality():
    """Check coprimality (primitivity) in both trees."""
    print("\n" + "=" * 70)
    print("DEMO 6: Coprimality (Primitivity) Check")
    print("=" * 70)
    
    max_depth = 5
    
    for name, root in [("Meta (0,1,1)", (0, 1, 1)), ("Oracle (3,4,5)", (3, 4, 5))]:
        triples = all_triples_up_to_depth(root, max_depth)
        non_primitive = [(t, gcd3(*t)) for t in triples if gcd3(*t) > 1]
        
        print(f"\n{name} tree up to depth {max_depth}:")
        print(f"  Total triples: {len(triples)}")
        if non_primitive:
            print(f"  Non-primitive triples: {len(non_primitive)}")
            for t, g in non_primitive[:5]:
                print(f"    {t}, gcd = {g}")
        else:
            print(f"  All primitive! ✓")


def demo_isomorphism_visualization():
    """Visualize the tree isomorphism."""
    print("\n" + "=" * 70)
    print("DEMO 7: Tree Isomorphism Visualization")
    print("=" * 70)
    
    seed = (0, 1, 1)
    fund = (3, 4, 5)
    
    paths = [
        ("root", lambda r: r),
        ("L", lambda r: berggren_M1(r)),
        ("M", lambda r: berggren_M2(r)),
        ("R", lambda r: berggren_M3(r)),
        ("LL", lambda r: berggren_M1(berggren_M1(r))),
        ("LM", lambda r: berggren_M2(berggren_M1(r))),
        ("LR", lambda r: berggren_M3(berggren_M1(r))),
        ("ML", lambda r: berggren_M1(berggren_M2(r))),
        ("MM", lambda r: berggren_M2(berggren_M2(r))),
        ("MR", lambda r: berggren_M3(berggren_M2(r))),
        ("RL", lambda r: berggren_M1(berggren_M3(r))),
        ("RM", lambda r: berggren_M2(berggren_M3(r))),
        ("RR", lambda r: berggren_M3(berggren_M3(r))),
    ]
    
    print(f"\n{'Path':<8} {'Meta (0,1,1)':<20} {'Oracle (3,4,5)':<20} {'Both Pyth?':<12}")
    print("-" * 62)
    
    for name, fn in paths:
        mt = fn(seed)
        ot = fn(fund)
        both = is_pythagorean(mt) and is_pythagorean(ot)
        print(f"{name:<8} {str(mt):<20} {str(ot):<20} {'✓' if both else '✗':<12}")
    
    print(f"\nThe trees have IDENTICAL STRUCTURE (same paths),")
    print(f"but DIFFERENT CONTENT (different labels at each node).")
    print(f"This is the Meta Oracle ≅ (0,1,1) / Oracle ≅ (3,4,5) isomorphism.")


def demo_quantum_encoding():
    """Quantum state encoding via Pythagorean triples."""
    print("\n" + "=" * 70)
    print("DEMO 8: Quantum Oracle Encoding")
    print("=" * 70)
    
    triples = [(0,1,1), (3,4,5), (5,12,13), (8,15,17), (7,24,25)]
    
    print(f"\nPythagorean triples as qubit states |ψ⟩ = (a/c)|0⟩ + (b/c)|1⟩:")
    print(f"{'Triple':<15} {'|0⟩ coeff':<12} {'|1⟩ coeff':<12} {'|ψ|²':<10} {'Angle (°)':<10}")
    print("-" * 60)
    
    for t in triples:
        a, b, c = t
        alpha = a / c if c != 0 else 0
        beta = b / c if c != 0 else 0
        norm_sq = alpha**2 + beta**2
        angle = math.degrees(math.atan2(b, a)) if a != 0 else 90.0
        print(f"{str(t):<15} {alpha:<12.4f} {beta:<12.4f} {norm_sq:<10.4f} {angle:<10.1f}")
    
    print(f"\nThe (0,1,1) meta oracle → |1⟩ (pure basis state)")
    print(f"The (3,4,5) oracle → (3/5)|0⟩ + (4/5)|1⟩ (superposition)")


# ═══════════════════════════════════════════════════════════════════════
# §6: MAIN
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  META ORACLE–PYTHAGOREAN TREE ISOMORPHISM EXPLORER             ║")
    print("║  Formally verified in Lean 4 with Mathlib                      ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    demo_fixed_point()
    demo_tree_comparison()
    demo_pythagorean_verification()
    demo_growth_rates()
    demo_entropy()
    demo_coprimality()
    demo_isomorphism_visualization()
    demo_quantum_encoding()
    
    print("\n" + "=" * 70)
    print("ALL EXPERIMENTS COMPLETE")
    print("See research/MetaOraclePythagoreanIsomorphism_Paper.md for the full paper")
    print("See core/Oracle/MetaOraclePythagoreanIsomorphism.lean for formal proofs")
    print("=" * 70)
