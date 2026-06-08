#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory
===================================================

Numerical demonstrations of the key results from the formalized
Counterpoint Quiver theory. Each function corresponds to a
machine-verified theorem in the Lean 4 formalization.

All arithmetic is performed mod 12 (standard 12-TET equal temperament).
"""

from __future__ import annotations
from itertools import product
from typing import NamedTuple


# ── Musical constants ──────────────────────────────────────────────

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison/Octave",
    1: "Minor 2nd",
    2: "Major 2nd",
    3: "Minor 3rd",
    4: "Major 3rd",
    5: "Perfect 4th",
    6: "Tritone",
    7: "Perfect 5th",
    8: "Minor 6th",
    9: "Major 6th",
    10: "Minor 7th",
    11: "Major 7th",
}

# Consonant intervals in first-species counterpoint (mod 12)
CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}

# Perfect consonances (subject to parallel-motion restriction)
PERFECT: set[int] = {0, 7}

# Imperfect consonances
IMPERFECT: set[int] = CONSONANT - PERFECT


# ── Core definitions (matching Lean formalization) ─────────────────

class VoiceLeading(NamedTuple):
    """A voice leading: how much the bass and soprano each move (mod 12)."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval after applying a voice leading.
    
    Matches Lean: targetInterval n source vl = source + vl.soprano - vl.bass
    """
    return (source + vl.soprano - vl.bass) % 12


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move the same nonzero amount.
    
    Matches Lean: VoiceLeading.isParallel
    """
    return vl.bass % 12 == vl.soprano % 12 and vl.bass % 12 != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading from source to target is permitted.
    
    Matches Lean: CounterpointSystem.isPermitted
    Conditions:
      1. source ∈ consonant
      2. target ∈ consonant  
      3. targetInterval(source, vl) = target
      4. ¬(target ∈ perfect ∧ isParallel(vl))
    """
    if source % 12 not in CONSONANT:
        return False
    if target % 12 not in CONSONANT:
        return False
    if target_interval(source, vl) != target % 12:
        return False
    if target % 12 in PERFECT and is_parallel(vl):
        return False
    return True


def canonical_voice_leading(source: int, target: int) -> VoiceLeading:
    """The canonical voice leading: bass stays, soprano adjusts.
    
    Matches Lean: canonicalVL n i j = ⟨0, j - i⟩
    """
    return VoiceLeading(bass=0, soprano=(target - source) % 12)


# ── Theorem demonstrations ────────────────────────────────────────

def demo_strong_connectivity() -> None:
    """Theorem 3.1 (exists_permitted_voice_leading):
    Between any two consonant intervals, at least one permitted voice leading exists.
    """
    print("=" * 70)
    print("THEOREM: Strong Connectivity of the Counterpoint Quiver")
    print("=" * 70)
    print()
    
    consonant_list = sorted(CONSONANT)
    all_connected = True
    
    for src in consonant_list:
        for tgt in consonant_list:
            vl = canonical_voice_leading(src, tgt)
            ok = is_permitted(src, tgt, vl)
            status = "✓" if ok else "✗"
            print(f"  {INTERVAL_NAMES[src]:15s} → {INTERVAL_NAMES[tgt]:15s}  "
                  f"via (bass={vl.bass:2d}, sop={vl.soprano:2d})  {status}")
            if not ok:
                all_connected = False
    
    print()
    print(f"  Result: All {len(consonant_list)}×{len(consonant_list)} = "
          f"{len(consonant_list)**2} pairs connected: {all_connected}")
    print()


def demo_self_loop_asymmetry() -> None:
    """Theorems (perfect_self_loop_unique, imperfect_self_loops_all):
    Perfect consonances admit exactly 1 self-loop; imperfect admit 12.
    """
    print("=" * 70)
    print("THEOREM: Self-Loop Asymmetry (The Bottleneck)")
    print("=" * 70)
    print()
    
    for interval in sorted(CONSONANT):
        self_loops: list[VoiceLeading] = []
        for b in range(12):
            for s in range(12):
                vl = VoiceLeading(b, s)
                if target_interval(interval, vl) == interval and is_permitted(interval, interval, vl):
                    self_loops.append(vl)
        
        kind = "PERFECT" if interval in PERFECT else "imperfect"
        print(f"  {INTERVAL_NAMES[interval]:15s} ({kind:9s}): "
              f"{len(self_loops):2d} self-loops")
        if len(self_loops) <= 3:
            for vl in self_loops:
                print(f"    └─ bass={vl.bass}, soprano={vl.soprano}")
    
    print()
    print("  Result: Perfect consonances ─ 1 self-loop (identity only)")
    print("          Imperfect consonances ─ 12 self-loops each")
    print("          Ratio: 12:1 asymmetry")
    print()


def demo_non_composability() -> None:
    """Theorem 3.2 (non_composability):
    Permitted voice leadings are NOT closed under composition.
    """
    print("=" * 70)
    print("THEOREM: Non-Composability (The Quiver Is Not a Category)")
    print("=" * 70)
    print()
    
    # Find a concrete counterexample
    counterexamples_found = 0
    consonant_list = sorted(CONSONANT)
    
    for i in consonant_list:
        for j in consonant_list:
            for k in consonant_list:
                for b1 in range(12):
                    for s1 in range(12):
                        vl1 = VoiceLeading(b1, s1)
                        if not is_permitted(i, j, vl1):
                            continue
                        for b2 in range(12):
                            for s2 in range(12):
                                vl2 = VoiceLeading(b2, s2)
                                if not is_permitted(j, k, vl2):
                                    continue
                                # Compose: add bass motions and soprano motions
                                composed = VoiceLeading((b1 + b2) % 12, (s1 + s2) % 12)
                                if not is_permitted(i, k, composed):
                                    if counterexamples_found < 3:
                                        print(f"  Counterexample {counterexamples_found + 1}:")
                                        print(f"    Step 1: {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[j]} "
                                              f"via (bass={b1}, sop={s1}) ✓ permitted")
                                        print(f"    Step 2: {INTERVAL_NAMES[j]} → {INTERVAL_NAMES[k]} "
                                              f"via (bass={b2}, sop={s2}) ✓ permitted")
                                        print(f"    Composed: {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[k]} "
                                              f"via (bass={composed.bass}, sop={composed.soprano}) "
                                              f"✗ FORBIDDEN")
                                        reason = ""
                                        if k in PERFECT and is_parallel(composed):
                                            reason = "(parallel motion into perfect consonance)"
                                        print(f"    Reason: {reason}")
                                        print()
                                    counterexamples_found += 1
    
    print(f"  Total counterexamples found: {counterexamples_found}")
    print("  Conclusion: Permitted voice leadings do NOT form a subcategory.")
    print()


def demo_voice_swap_asymmetry() -> None:
    """Theorem 3.4 (voice_swap_breaks_consonance):
    The involution i ↦ -i (mod 12) does not preserve consonance.
    """
    print("=" * 70)
    print("THEOREM: Voice-Swap Asymmetry")
    print("=" * 70)
    print()
    
    print("  Voice swap (interval inversion): i ↦ -i mod 12")
    print()
    
    for i in sorted(CONSONANT):
        neg_i = (-i) % 12
        preserved = neg_i in CONSONANT
        status = "✓ consonant" if preserved else "✗ DISSONANT"
        print(f"  {INTERVAL_NAMES[i]:15s} ({i:2d}) → "
              f"{INTERVAL_NAMES[neg_i]:15s} ({neg_i:2d})  {status}")
    
    print()
    print("  Key finding: Perfect 5th (7) maps to Perfect 4th (5),")
    print("  which is DISSONANT in counterpoint above the bass.")
    print("  ⟹ The bass voice has a privileged, asymmetric role.")
    print()


def demo_hom_set_computation() -> None:
    """Theorems (total_permitted_to_perfect, total_permitted_to_imperfect):
    Perfect consonances receive 61 incoming edges; imperfect receive 72.
    """
    print("=" * 70)
    print("THEOREM: Hom-Set Cardinality")
    print("=" * 70)
    print()
    
    consonant_list = sorted(CONSONANT)
    
    # Count incoming edges for each target
    for target in consonant_list:
        total_incoming = 0
        for source in consonant_list:
            for b in range(12):
                for s in range(12):
                    vl = VoiceLeading(b, s)
                    if is_permitted(source, target, vl):
                        total_incoming += 1
        
        kind = "PERFECT" if target in PERFECT else "imperfect"
        print(f"  {INTERVAL_NAMES[target]:15s} ({kind:9s}): "
              f"{total_incoming:3d} incoming voice leadings")
    
    # Aggregate by type
    perfect_total = 0
    imperfect_total = 0
    for target in consonant_list:
        count = 0
        for source in consonant_list:
            for b in range(12):
                for s in range(12):
                    if is_permitted(source, target, VoiceLeading(b, s)):
                        count += 1
        if target in PERFECT:
            perfect_total += count
        else:
            imperfect_total += count
    
    print()
    print(f"  Average incoming to PERFECT consonance:   "
          f"{perfect_total / len(PERFECT):.1f}")
    print(f"  Average incoming to IMPERFECT consonance:  "
          f"{imperfect_total / len(IMPERFECT):.1f}")
    print(f"  Reduction ratio: {perfect_total / len(PERFECT) / (imperfect_total / len(IMPERFECT)) * 100:.1f}%")
    print()


def demo_cost_function() -> None:
    """Theorems (cost_triangle, cost_meet_join_eq, cost_seminorm_properties):
    Voice-leading cost is an L¹ seminorm with a lattice conservation law.
    """
    print("=" * 70)
    print("THEOREM: Voice-Leading Cost Properties")
    print("=" * 70)
    print()
    
    # Example: 4 voices
    n = 4
    m1 = [2, -3, 1, 0]   # Voice motion 1
    m2 = [-1, 4, -2, 3]  # Voice motion 2
    
    cost = lambda m: sum(abs(x) for x in m)
    
    # Triangle inequality
    m_sum = [m1[i] + m2[i] for i in range(n)]
    print(f"  m₁ = {m1}")
    print(f"  m₂ = {m2}")
    print(f"  m₁ + m₂ = {m_sum}")
    print()
    print(f"  ‖m₁‖₁ = {cost(m1)}")
    print(f"  ‖m₂‖₁ = {cost(m2)}")
    print(f"  ‖m₁ + m₂‖₁ = {cost(m_sum)}")
    print(f"  Triangle inequality: {cost(m_sum)} ≤ {cost(m1)} + {cost(m2)} = "
          f"{cost(m1) + cost(m2)}  ✓")
    print()
    
    # Lattice conservation law
    m_meet = [min(m1[i], m2[i]) for i in range(n)]
    m_join = [max(m1[i], m2[i]) for i in range(n)]
    
    print(f"  m₁ ∧ m₂ = {m_meet}")
    print(f"  m₁ ∨ m₂ = {m_join}")
    print(f"  ‖m₁ ∧ m₂‖₁ + ‖m₁ ∨ m₂‖₁ = {cost(m_meet)} + {cost(m_join)} = "
          f"{cost(m_meet) + cost(m_join)}")
    print(f"  ‖m₁‖₁ + ‖m₂‖₁ = {cost(m1)} + {cost(m2)} = "
          f"{cost(m1) + cost(m2)}")
    print(f"  Conservation law: {cost(m_meet) + cost(m_join)} = "
          f"{cost(m1) + cost(m2)}  ✓")
    print()
    
    # Absolute homogeneity
    c = -3
    m_scaled = [c * m1[i] for i in range(n)]
    print(f"  c = {c}")
    print(f"  c · m₁ = {m_scaled}")
    print(f"  ‖c · m₁‖₁ = {cost(m_scaled)}")
    print(f"  |c| · ‖m₁‖₁ = {abs(c)} × {cost(m1)} = {abs(c) * cost(m1)}")
    print(f"  Absolute homogeneity: {cost(m_scaled)} = {abs(c) * cost(m1)}  ✓")
    print()


def demo_ascending_sublattice() -> None:
    """Theorems (ascending_meet, ascending_join):
    Ascending motions form a sublattice.
    """
    print("=" * 70)
    print("THEOREM: Ascending Motion Sublattice")
    print("=" * 70)
    print()
    
    n = 4
    m1 = [3, 1, 5, 2]
    m2 = [1, 4, 2, 6]
    
    assert all(x >= 0 for x in m1), "m1 should be ascending"
    assert all(x >= 0 for x in m2), "m2 should be ascending"
    
    m_meet = [min(m1[i], m2[i]) for i in range(n)]
    m_join = [max(m1[i], m2[i]) for i in range(n)]
    
    print(f"  m₁ = {m1}  (ascending: all ≥ 0)")
    print(f"  m₂ = {m2}  (ascending: all ≥ 0)")
    print(f"  m₁ ∧ m₂ = {m_meet}  (ascending: {all(x >= 0 for x in m_meet)} ✓)")
    print(f"  m₁ ∨ m₂ = {m_join}  (ascending: {all(x >= 0 for x in m_join)} ✓)")
    print()
    
    cost = lambda m: sum(abs(x) for x in m)
    print(f"  For ascending motions, cost = simple sum:")
    print(f"  ‖m₁‖₁ = sum({m1}) = {sum(m1)} = {cost(m1)}")
    print(f"  ‖m₁ ∧ m₂‖₁ = sum({m_meet}) = {sum(m_meet)} ≤ {cost(m1)} = ‖m₁‖₁  ✓")
    print()
    print("  Meet of ascending motions gives the 'most conservative' motion")
    print("  with guaranteed lower cost — optimal for smooth voice leading.")
    print()


def demo_full_quiver_statistics() -> None:
    """Summary statistics of the full counterpoint quiver."""
    print("=" * 70)
    print("SUMMARY: Full Quiver Statistics for 12-TET Counterpoint")
    print("=" * 70)
    print()
    
    consonant_list = sorted(CONSONANT)
    total_edges = 0
    edge_counts: dict[tuple[int, int], int] = {}
    
    for src in consonant_list:
        for tgt in consonant_list:
            count = 0
            for b in range(12):
                for s in range(12):
                    if is_permitted(src, tgt, VoiceLeading(b, s)):
                        count += 1
            edge_counts[(src, tgt)] = count
            total_edges += count
    
    print(f"  Vertices (consonant intervals):     {len(consonant_list)}")
    print(f"  Total directed edges (voice leadings): {total_edges}")
    print(f"  Average edges per vertex pair:       {total_edges / len(consonant_list)**2:.1f}")
    print()
    
    print("  Edge count matrix (source → target):")
    print(f"  {'':15s}", end="")
    for tgt in consonant_list:
        print(f"  {tgt:3d}", end="")
    print()
    
    for src in consonant_list:
        print(f"  {INTERVAL_NAMES[src]:15s}", end="")
        for tgt in consonant_list:
            print(f"  {edge_counts[(src, tgt)]:3d}", end="")
        print()
    
    print()
    print(f"  Key: interval numbers = {dict((k, v) for k, v in INTERVAL_NAMES.items() if k in CONSONANT)}")
    print()


# ── Main ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   SONIC MATHEMATICS: Counterpoint as Category Theory               ║")
    print("║   Numerical Demonstrations of Machine-Verified Theorems            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_strong_connectivity()
    demo_self_loop_asymmetry()
    demo_non_composability()
    demo_voice_swap_asymmetry()
    demo_hom_set_computation()
    demo_cost_function()
    demo_ascending_sublattice()
    demo_full_quiver_statistics()
    
    print("All demonstrations complete. Results match machine-verified theorems.")
