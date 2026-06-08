#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

Self-contained Python script demonstrating the key results from the formal
verification of first-species counterpoint as algebraic structure.

All functions are inlined. No external dependencies beyond the standard library.
"""

from __future__ import annotations
from itertools import product
from typing import NamedTuple


# =============================================================================
# Section 1: The 12-TET Counterpoint System
# =============================================================================

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}
N: int = 12  # chromatic modulus

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


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in Z/12Z."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute target interval: source + soprano - bass (mod 12)."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if bass == soprano and bass != 0."""
    return vl.bass == vl.soprano and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading from source to target is permitted."""
    return (
        source % N in CONSONANT
        and target % N in CONSONANT
        and target_interval(source, vl) == target % N
        and not (target % N in PERFECT and is_parallel(vl))
    )


# =============================================================================
# Section 2: Enumerate All Permitted Voice Leadings
# =============================================================================

def enumerate_permitted() -> dict[tuple[int, int], list[VoiceLeading]]:
    """Enumerate all permitted voice leadings between consonant intervals.
    
    Returns a dict mapping (source, target) to list of permitted VoiceLeadings.
    """
    result: dict[tuple[int, int], list[VoiceLeading]] = {}
    for src in sorted(CONSONANT):
        for tgt in sorted(CONSONANT):
            permitted: list[VoiceLeading] = []
            for b in range(N):
                for s in range(N):
                    vl = VoiceLeading(b, s)
                    if target_interval(src, vl) == tgt and is_permitted(src, tgt, vl):
                        permitted.append(vl)
            if permitted:
                result[(src, tgt)] = permitted
    return result


# =============================================================================
# Section 3: Demonstrate Strong Connectivity (Theorem 3.1)
# =============================================================================

def demo_strong_connectivity() -> None:
    """Demonstrate: between any two consonant intervals, a permitted VL exists."""
    print("=" * 70)
    print("THEOREM 3.1: Strong Connectivity of the Counterpoint Quiver")
    print("=" * 70)
    print()
    print("For every pair (i, j) of consonant intervals, we exhibit a")
    print("permitted voice leading from i to j.")
    print()

    all_permitted = enumerate_permitted()
    for src in sorted(CONSONANT):
        for tgt in sorted(CONSONANT):
            vls = all_permitted.get((src, tgt), [])
            canonical = VoiceLeading(0, (tgt - src) % N)
            is_canon_permitted = is_permitted(src, tgt, canonical)
            print(
                f"  {INTERVAL_NAMES[src]:>15s} → {INTERVAL_NAMES[tgt]:<15s}: "
                f"{len(vls):2d} permitted VLs | "
                f"canonical (0, {(tgt - src) % N:2d}) permitted: {is_canon_permitted}"
            )
    print()
    print("✓ All 36 pairs have at least one permitted voice leading.")
    print("✓ The canonical voice leading (0, j−i) always works.")
    print()


# =============================================================================
# Section 4: Demonstrate Non-Composability (Theorem 3.2)
# =============================================================================

def demo_non_composability() -> None:
    """Find and display a concrete counterexample to composability."""
    print("=" * 70)
    print("THEOREM 3.2: Non-Composability — Counterpoint Is Not a Category")
    print("=" * 70)
    print()

    all_permitted = enumerate_permitted()
    found = False

    for mid in sorted(CONSONANT):
        for (s1, t1), vls1 in sorted(all_permitted.items()):
            if t1 != mid:
                continue
            for (s2, t2), vls2 in sorted(all_permitted.items()):
                if s2 != mid:
                    continue
                for vl1 in vls1:
                    for vl2 in vls2:
                        # Compose: add bass and soprano motions
                        comp = VoiceLeading(
                            (vl1.bass + vl2.bass) % N,
                            (vl1.soprano + vl2.soprano) % N,
                        )
                        comp_target = target_interval(s1, comp)
                        if comp_target == t2 and not is_permitted(s1, t2, comp):
                            print(f"  Counterexample found!")
                            print(f"    Step 1: {INTERVAL_NAMES[s1]} → {INTERVAL_NAMES[t1]}")
                            print(f"            VL₁ = (bass={vl1.bass}, soprano={vl1.soprano})")
                            print(f"            Permitted: {is_permitted(s1, t1, vl1)}")
                            print()
                            print(f"    Step 2: {INTERVAL_NAMES[s2]} → {INTERVAL_NAMES[t2]}")
                            print(f"            VL₂ = (bass={vl2.bass}, soprano={vl2.soprano})")
                            print(f"            Permitted: {is_permitted(s2, t2, vl2)}")
                            print()
                            print(f"    Composite: {INTERVAL_NAMES[s1]} → {INTERVAL_NAMES[t2]}")
                            print(f"            VL₁∘VL₂ = (bass={comp.bass}, soprano={comp.soprano})")
                            print(f"            Is parallel: {is_parallel(comp)}")
                            print(f"            Target is perfect: {t2 in PERFECT}")
                            print(f"            Permitted: {is_permitted(s1, t2, comp)}")
                            print()
                            print("  ✓ Two legal steps compose into an illegal one.")
                            print("  ✓ Permitted voice leadings do NOT form a category.")
                            print()
                            found = True
                            return

    if not found:
        print("  (No counterexample found — check logic)")
    print()


# =============================================================================
# Section 5: Perfect Consonance Bottleneck (Theorems 3.4–3.6)
# =============================================================================

def demo_bottleneck() -> None:
    """Demonstrate the self-loop and hom-set asymmetry."""
    print("=" * 70)
    print("THEOREMS 3.4–3.6: The Perfect Consonance Bottleneck")
    print("=" * 70)
    print()

    all_permitted = enumerate_permitted()

    print("Self-loops (voice leadings from an interval to itself):")
    print()
    for iv in sorted(CONSONANT):
        self_loops = all_permitted.get((iv, iv), [])
        kind = "PERFECT" if iv in PERFECT else "IMPERFECT"
        print(f"  {INTERVAL_NAMES[iv]:>15s} ({kind:>9s}): {len(self_loops):2d} self-loops")
        if len(self_loops) <= 3:
            for vl in self_loops:
                print(f"    └─ (bass={vl.bass}, soprano={vl.soprano})")

    print()
    print("Incoming voice leadings (from all consonant sources):")
    print()
    for tgt in sorted(CONSONANT):
        total = sum(len(all_permitted.get((src, tgt), [])) for src in CONSONANT)
        kind = "PERFECT" if tgt in PERFECT else "IMPERFECT"
        print(f"  → {INTERVAL_NAMES[tgt]:>15s} ({kind:>9s}): {total:3d} incoming VLs")

    print()
    print("✓ Perfect consonances: exactly 1 self-loop (identity only).")
    print("✓ Imperfect consonances: exactly 12 self-loops.")
    print("✓ Perfect consonances: 61 incoming VLs (vs 72 for imperfect).")
    print("✓ The 15% reduction quantifies Fux's parallel-motion prohibition.")
    print()


# =============================================================================
# Section 6: Voice-Swap Asymmetry (Theorem 3.7)
# =============================================================================

def demo_voice_swap() -> None:
    """Demonstrate that negation does not preserve consonance."""
    print("=" * 70)
    print("THEOREM 3.7: Voice-Swap Breaks Consonance")
    print("=" * 70)
    print()
    print("The involution i ↦ −i (mod 12) on interval classes:")
    print()

    for iv in range(N):
        neg = (-iv) % N
        src_cons = "consonant" if iv in CONSONANT else "dissonant"
        tgt_cons = "consonant" if neg in CONSONANT else "dissonant"
        marker = " ← BREAKS CONSONANCE!" if (iv in CONSONANT) != (neg in CONSONANT) else ""
        print(
            f"  {INTERVAL_NAMES[iv]:>15s} ({iv:2d}) → "
            f"{INTERVAL_NAMES[neg]:>15s} ({neg:2d})  "
            f"[{src_cons:>9s} → {tgt_cons:<9s}]{marker}"
        )

    print()
    print("✓ The perfect fifth (7) maps to the perfect fourth (5).")
    print("✓ The perfect fourth is DISSONANT in two-voice counterpoint.")
    print("✓ Consonance is NOT preserved under voice exchange.")
    print("✓ This formalizes the bass voice privilege in counterpoint.")
    print()


# =============================================================================
# Section 7: Voice-Leading Cost Seminorm (Theorems 4.1–4.2)
# =============================================================================

def voice_leading_cost(m: list[int]) -> int:
    """L¹ norm of a voice motion: sum of |m_i|."""
    return sum(abs(x) for x in m)


def componentwise_min(m1: list[int], m2: list[int]) -> list[int]:
    """Lattice meet: componentwise minimum."""
    return [min(a, b) for a, b in zip(m1, m2)]


def componentwise_max(m1: list[int], m2: list[int]) -> list[int]:
    """Lattice join: componentwise maximum."""
    return [max(a, b) for a, b in zip(m1, m2)]


def demo_cost_seminorm() -> None:
    """Demonstrate the cost function properties and lattice identity."""
    print("=" * 70)
    print("THEOREMS 4.1–4.2: Voice-Leading Cost as Seminorm + Lattice Identity")
    print("=" * 70)
    print()

    # Example voice motions (4 voices)
    examples: list[tuple[list[int], list[int]]] = [
        ([2, -1, 0, 3], [-1, 4, -2, 1]),
        ([5, -3, 2, -4], [1, 1, 1, 1]),
        ([-2, -2, -2, -2], [3, 0, -1, 2]),
        ([0, 0, 0, 0], [7, -3, 2, -5]),
    ]

    print("Triangle inequality: cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂)")
    print()
    for m1, m2 in examples:
        m_sum = [a + b for a, b in zip(m1, m2)]
        c1 = voice_leading_cost(m1)
        c2 = voice_leading_cost(m2)
        c_sum = voice_leading_cost(m_sum)
        holds = c_sum <= c1 + c2
        print(f"  m₁={m1}, m₂={m2}")
        print(f"  cost(m₁)={c1}, cost(m₂)={c2}, cost(m₁+m₂)={c_sum}, "
              f"sum={c1+c2}, holds: {holds}")
        print()

    print("-" * 70)
    print("L¹-Lattice Identity: cost(m₁⊓m₂) + cost(m₁⊔m₂) = cost(m₁) + cost(m₂)")
    print()
    for m1, m2 in examples:
        meet = componentwise_min(m1, m2)
        join = componentwise_max(m1, m2)
        c1 = voice_leading_cost(m1)
        c2 = voice_leading_cost(m2)
        c_meet = voice_leading_cost(meet)
        c_join = voice_leading_cost(join)
        lhs = c_meet + c_join
        rhs = c1 + c2
        print(f"  m₁={m1}, m₂={m2}")
        print(f"  meet={meet}, join={join}")
        print(f"  cost(meet)={c_meet} + cost(join)={c_join} = {lhs}")
        print(f"  cost(m₁)={c1} + cost(m₂)={c2} = {rhs}")
        print(f"  Identity holds: {lhs == rhs}")
        print()

    print("-" * 70)
    print("Absolute homogeneity: cost(c·m) = |c| · cost(m)")
    print()
    m = [2, -1, 3, -4]
    for c in [-3, -1, 0, 1, 2, 5]:
        scaled = [c * x for x in m]
        cost_m = voice_leading_cost(m)
        cost_scaled = voice_leading_cost(scaled)
        expected = abs(c) * cost_m
        print(f"  c={c:+d}, m={m}, c·m={scaled}")
        print(f"  cost(c·m)={cost_scaled}, |c|·cost(m)={expected}, "
              f"holds: {cost_scaled == expected}")

    print()
    print("✓ All seminorm properties verified numerically.")
    print("✓ The L¹-lattice identity is a conservation law for displacement.")
    print()


# =============================================================================
# Section 8: Full Quiver Statistics
# =============================================================================

def demo_quiver_statistics() -> None:
    """Print complete statistics of the Counterpoint Quiver."""
    print("=" * 70)
    print("COMPLETE QUIVER STATISTICS")
    print("=" * 70)
    print()

    all_permitted = enumerate_permitted()
    total_edges = sum(len(vls) for vls in all_permitted.values())

    print(f"Vertices (consonant intervals): {len(CONSONANT)}")
    print(f"  Perfect:   {sorted(PERFECT)} = "
          f"{', '.join(INTERVAL_NAMES[i] for i in sorted(PERFECT))}")
    print(f"  Imperfect: {sorted(IMPERFECT)} = "
          f"{', '.join(INTERVAL_NAMES[i] for i in sorted(IMPERFECT))}")
    print(f"Total permitted edges: {total_edges}")
    print()

    print("Adjacency matrix (edge counts):")
    print()
    header = "        " + "".join(f"{iv:>6d}" for iv in sorted(CONSONANT))
    print(header)
    print("        " + "-" * (6 * len(CONSONANT)))
    for src in sorted(CONSONANT):
        row = f"  {src:>4d} |"
        for tgt in sorted(CONSONANT):
            count = len(all_permitted.get((src, tgt), []))
            row += f"{count:>6d}"
        print(row)
    print()

    # In-degree and out-degree
    print("In-degree and out-degree:")
    print()
    for iv in sorted(CONSONANT):
        in_deg = sum(len(all_permitted.get((s, iv), [])) for s in CONSONANT)
        out_deg = sum(len(all_permitted.get((iv, t), [])) for t in CONSONANT)
        kind = "P" if iv in PERFECT else "I"
        print(f"  {INTERVAL_NAMES[iv]:>15s} [{kind}]: in={in_deg:3d}, out={out_deg:3d}")
    print()


# =============================================================================
# Section 9: Ascending Motion Sublattice Demo (Theorems 4.5–4.6)
# =============================================================================

def demo_ascending_sublattice() -> None:
    """Demonstrate that ascending motions form a sublattice."""
    print("=" * 70)
    print("THEOREMS 4.5–4.6: Ascending Motion Sublattice")
    print("=" * 70)
    print()

    asc_pairs: list[tuple[list[int], list[int]]] = [
        ([1, 3, 0, 2], [2, 1, 4, 0]),
        ([0, 0, 5, 1], [3, 2, 0, 0]),
        ([4, 4, 4, 4], [1, 2, 3, 7]),
    ]

    for m1, m2 in asc_pairs:
        meet = componentwise_min(m1, m2)
        join = componentwise_max(m1, m2)
        m1_asc = all(x >= 0 for x in m1)
        m2_asc = all(x >= 0 for x in m2)
        meet_asc = all(x >= 0 for x in meet)
        join_asc = all(x >= 0 for x in join)

        print(f"  m₁ = {m1} (ascending: {m1_asc})")
        print(f"  m₂ = {m2} (ascending: {m2_asc})")
        print(f"  m₁⊓m₂ = {meet} (ascending: {meet_asc})")
        print(f"  m₁⊔m₂ = {join} (ascending: {join_asc})")
        print(f"  cost(m₁⊓m₂) = {voice_leading_cost(meet)} ≤ cost(m₁) = {voice_leading_cost(m1)}: "
              f"{voice_leading_cost(meet) <= voice_leading_cost(m1)}")
        print()

    print("✓ Meet and join of ascending motions are ascending (sublattice).")
    print("✓ cost(meet) ≤ cost(m₁) for ascending motions.")
    print()


# =============================================================================
# Main
# =============================================================================

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   SONIC MATHEMATICS: Counterpoint as Category Theory               ║")
    print("║   Numerical Demonstrations of Formally Verified Results            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_strong_connectivity()
    demo_non_composability()
    demo_bottleneck()
    demo_voice_swap()
    demo_cost_seminorm()
    demo_ascending_sublattice()
    demo_quiver_statistics()

    print("=" * 70)
    print("All demonstrations complete. Every result shown here has been")
    print("formally verified with machine-checked mathematical proofs.")
    print("=" * 70)


if __name__ == "__main__":
    main()
