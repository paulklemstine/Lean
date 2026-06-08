#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

Demonstrates the key results from the formal counterpoint theory:
1. The Counterpoint Quiver: connectivity, non-composability, bottleneck
2. Voice-swap asymmetry
3. Voice-leading cost as seminorm with L¹-lattice identity

All functions are self-contained. No external dependencies beyond the standard library.
"""

from __future__ import annotations
from typing import NamedTuple
from itertools import product


# ─── Interval & Voice Leading Types ──────────────────────────────────────────

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

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}


class VoiceLeading(NamedTuple):
    bass: int   # mod 12
    soprano: int  # mod 12


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval: source + soprano - bass (mod 12)."""
    return (source + vl.soprano - vl.bass) % 12


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass % 12 == vl.soprano % 12 and vl.bass % 12 != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading from source to target is permitted."""
    return (
        source in CONSONANT
        and target in CONSONANT
        and target_interval(source, vl) == target
        and not (target in PERFECT and is_parallel(vl))
    )


# ─── Demo 1: Strong Connectivity ────────────────────────────────────────────

def demo_strong_connectivity() -> None:
    """
    Theorem (exists_permitted_voice_leading):
    Between any two consonant intervals, at least one permitted voice leading exists.
    
    We verify this exhaustively and show the canonical voice leading for each pair.
    """
    print("=" * 72)
    print("DEMO 1: Strong Connectivity of the Counterpoint Quiver")
    print("=" * 72)
    print()
    print("For each pair (source → target) of consonant intervals, we find")
    print("a permitted voice leading. The canonical VL keeps the bass still.\n")

    sorted_consonant = sorted(CONSONANT)
    for src in sorted_consonant:
        for tgt in sorted_consonant:
            # Canonical voice leading: bass stays, soprano moves by (tgt - src)
            canon = VoiceLeading(bass=0, soprano=(tgt - src) % 12)
            permitted = is_permitted(src, tgt, canon)
            tag = "✓" if permitted else "✗"
            src_name = INTERVAL_NAMES[src][:10].ljust(10)
            tgt_name = INTERVAL_NAMES[tgt][:10].ljust(10)
            print(f"  {tag} {src_name} → {tgt_name}  "
                  f"VL=({canon.bass:2d},{canon.soprano:2d})  "
                  f"parallel={is_parallel(canon)}")

    # Verify exhaustively
    all_connected = True
    for src in sorted_consonant:
        for tgt in sorted_consonant:
            found = any(
                is_permitted(src, tgt, VoiceLeading(b, s))
                for b in range(12) for s in range(12)
            )
            if not found:
                all_connected = False
                print(f"  !! No permitted VL from {src} to {tgt}")

    print(f"\n  Strong connectivity verified: {all_connected}\n")


# ─── Demo 2: Non-Composability ──────────────────────────────────────────────

def demo_non_composability() -> None:
    """
    Theorem (non_composability):
    Permitted voice leadings are NOT closed under composition.
    
    We find explicit counterexamples where two individually permitted voice leadings
    compose into a forbidden one.
    """
    print("=" * 72)
    print("DEMO 2: Non-Composability — Counterpoint Is Not a Category")
    print("=" * 72)
    print()

    counterexamples: list[tuple[int, int, int, VoiceLeading, VoiceLeading]] = []
    sorted_consonant = sorted(CONSONANT)

    for i in sorted_consonant:
        for j in sorted_consonant:
            for k in sorted_consonant:
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
                                # Compose
                                comp = VoiceLeading(
                                    (b1 + b2) % 12,
                                    (s1 + s2) % 12
                                )
                                if not is_permitted(i, k, comp):
                                    counterexamples.append((i, j, k, vl1, vl2))

    print(f"  Found {len(counterexamples)} composition failures.\n")
    print("  First 5 counterexamples:")
    for idx, (i, j, k, vl1, vl2) in enumerate(counterexamples[:5]):
        comp = VoiceLeading((vl1.bass + vl2.bass) % 12,
                            (vl1.soprano + vl2.soprano) % 12)
        print(f"    [{idx+1}] {INTERVAL_NAMES[i][:8]:>8} →({vl1.bass},{vl1.soprano})→ "
              f"{INTERVAL_NAMES[j][:8]:>8} →({vl2.bass},{vl2.soprano})→ "
              f"{INTERVAL_NAMES[k][:8]:>8}")
        print(f"         Composed VL=({comp.bass},{comp.soprano}): "
              f"parallel={is_parallel(comp)}, target_perfect={k in PERFECT}")
    print()


# ─── Demo 3: Self-Loop Bottleneck ───────────────────────────────────────────

def demo_bottleneck() -> None:
    """
    Theorems (perfect_self_loop_unique, imperfect_self_loops_all):
    Perfect consonances have 1 self-loop; imperfect consonances have 12.
    
    Theorems (total_permitted_to_perfect, total_permitted_to_imperfect):
    61 incoming voice leadings to perfect vs 72 to imperfect consonances.
    """
    print("=" * 72)
    print("DEMO 3: The Bottleneck Theorem — Perfect vs Imperfect Consonances")
    print("=" * 72)
    print()

    sorted_consonant = sorted(CONSONANT)

    # Count self-loops
    print("  Self-loops per consonant interval:")
    for interval in sorted_consonant:
        self_loops = sum(
            1 for b in range(12) for s in range(12)
            if is_permitted(interval, interval, VoiceLeading(b, s))
        )
        kind = "PERFECT" if interval in PERFECT else "imperf."
        print(f"    {INTERVAL_NAMES[interval]:15s} ({kind}): {self_loops:2d} self-loops")

    print()

    # Count total incoming
    print("  Total incoming voice leadings per target:")
    for tgt in sorted_consonant:
        total_incoming = sum(
            1 for src in sorted_consonant
            for b in range(12) for s in range(12)
            if is_permitted(src, tgt, VoiceLeading(b, s))
        )
        kind = "PERFECT" if tgt in PERFECT else "imperf."
        print(f"    → {INTERVAL_NAMES[tgt]:15s} ({kind}): {total_incoming:3d} incoming VLs")

    print()


# ─── Demo 4: Voice-Swap Asymmetry ───────────────────────────────────────────

def demo_voice_swap() -> None:
    """
    Theorem (voice_swap_breaks_consonance):
    The map i ↦ -i (mod 12) does NOT preserve the consonant set.
    The perfect fifth (7) maps to the perfect fourth (5), which is dissonant.
    """
    print("=" * 72)
    print("DEMO 4: Voice-Swap Asymmetry — Why the Bass Voice Is Special")
    print("=" * 72)
    print()
    print("  The voice-exchange involution i ↦ -i (mod 12) on consonant intervals:\n")

    for i in sorted(CONSONANT):
        neg_i = (-i) % 12
        src_cons = "consonant" if i in CONSONANT else "DISSONANT"
        tgt_cons = "consonant" if neg_i in CONSONANT else "DISSONANT"
        preserved = "✓" if neg_i in CONSONANT else "✗ BROKEN"
        print(f"    {INTERVAL_NAMES[i]:15s} ({i:2d}) → "
              f"{INTERVAL_NAMES[neg_i]:15s} ({neg_i:2d})  [{preserved}]")

    print()
    print("  The map fails to preserve consonance: 7 (P5) ↦ 5 (P4), which is dissonant.")
    print("  This formalizes the asymmetric role of the bass voice in counterpoint.\n")


# ─── Demo 5: Voice-Leading Cost Seminorm ─────────────────────────────────────

def voice_leading_cost(m: list[int]) -> int:
    """L¹ norm: sum of absolute values of voice motions."""
    return sum(abs(x) for x in m)


def componentwise_min(m1: list[int], m2: list[int]) -> list[int]:
    """Lattice meet: componentwise minimum."""
    return [min(a, b) for a, b in zip(m1, m2)]


def componentwise_max(m1: list[int], m2: list[int]) -> list[int]:
    """Lattice join: componentwise maximum."""
    return [max(a, b) for a, b in zip(m1, m2)]


def demo_seminorm_and_lattice() -> None:
    """
    Theorems: cost_triangle, cost_eq_zero_iff, cost_neg_eq,
              cost_meet_join_eq, cost_seminorm_properties
    
    Demonstrates the seminorm properties and the L¹-lattice identity.
    """
    print("=" * 72)
    print("DEMO 5: Voice-Leading Cost — Seminorm & L¹-Lattice Identity")
    print("=" * 72)
    print()

    # Example voice motions (4 voices)
    examples: list[tuple[list[int], list[int]]] = [
        ([2, -1, 3, 0], [1, 2, -1, 4]),
        ([-3, 5, -2, 1], [4, -1, 3, -2]),
        ([0, 0, 0, 0], [1, -1, 2, -2]),
        ([1, 1, 1, 1], [-1, -1, -1, -1]),
    ]

    print("  Seminorm properties:\n")
    for m1, m2 in examples:
        c1, c2 = voice_leading_cost(m1), voice_leading_cost(m2)
        m_sum = [a + b for a, b in zip(m1, m2)]
        c_sum = voice_leading_cost(m_sum)
        m_neg = [-a for a in m1]
        c_neg = voice_leading_cost(m_neg)

        print(f"    m₁ = {m1},  cost = {c1}")
        print(f"    m₂ = {m2},  cost = {c2}")
        print(f"    Triangle: cost(m₁+m₂) = {c_sum} ≤ {c1}+{c2} = {c1+c2}  "
              f"{'✓' if c_sum <= c1 + c2 else '✗'}")
        print(f"    Symmetry: cost(-m₁) = {c_neg} = cost(m₁) = {c1}  "
              f"{'✓' if c_neg == c1 else '✗'}")
        print()

    print("  L¹-Lattice Identity: cost(m₁ ⊓ m₂) + cost(m₁ ⊔ m₂) = cost(m₁) + cost(m₂)\n")
    for m1, m2 in examples:
        c1, c2 = voice_leading_cost(m1), voice_leading_cost(m2)
        meet = componentwise_min(m1, m2)
        join = componentwise_max(m1, m2)
        c_meet = voice_leading_cost(meet)
        c_join = voice_leading_cost(join)
        lhs = c_meet + c_join
        rhs = c1 + c2

        print(f"    m₁={m1}, m₂={m2}")
        print(f"    m₁⊓m₂={meet}  cost={c_meet}   m₁⊔m₂={join}  cost={c_join}")
        print(f"    LHS = {c_meet}+{c_join} = {lhs}   RHS = {c1}+{c2} = {rhs}   "
              f"{'✓ Equal' if lhs == rhs else '✗ FAIL'}")
        print()

    # Absolute homogeneity
    print("  Absolute homogeneity: cost(c·m) = |c|·cost(m)\n")
    m = [2, -3, 1, 5]
    for c in [-3, -1, 0, 1, 2, 4]:
        scaled = [c * x for x in m]
        cost_scaled = voice_leading_cost(scaled)
        expected = abs(c) * voice_leading_cost(m)
        print(f"    c={c:+d}, m={m}: cost({scaled}) = {cost_scaled}, "
              f"|{c}|·cost(m) = {expected}  "
              f"{'✓' if cost_scaled == expected else '✗'}")
    print()


# ─── Demo 6: Ascending Sublattice ───────────────────────────────────────────

def demo_ascending_sublattice() -> None:
    """
    Theorems: ascending_meet, ascending_join, ascending_cost_eq_sum,
              ascending_meet_cost_le
    """
    print("=" * 72)
    print("DEMO 6: Ascending Motions Form a Sublattice")
    print("=" * 72)
    print()

    asc_examples: list[tuple[list[int], list[int]]] = [
        ([2, 0, 3, 1], [1, 4, 0, 2]),
        ([5, 3, 1, 0], [0, 1, 4, 3]),
        ([1, 1, 1, 1], [2, 2, 2, 2]),
    ]

    for m1, m2 in asc_examples:
        meet = componentwise_min(m1, m2)
        join = componentwise_max(m1, m2)
        m1_asc = all(x >= 0 for x in m1)
        m2_asc = all(x >= 0 for x in m2)
        meet_asc = all(x >= 0 for x in meet)
        join_asc = all(x >= 0 for x in join)

        print(f"  m₁={m1} (ascending={m1_asc})")
        print(f"  m₂={m2} (ascending={m2_asc})")
        print(f"  m₁⊓m₂={meet} (ascending={meet_asc}) — "
              f"cost={voice_leading_cost(meet)}, sum={sum(meet)}")
        print(f"  m₁⊔m₂={join} (ascending={join_asc}) — "
              f"cost={voice_leading_cost(join)}, sum={sum(join)}")
        print(f"  cost(meet)={voice_leading_cost(meet)} ≤ "
              f"cost(m₁)={voice_leading_cost(m1)}  "
              f"{'✓' if voice_leading_cost(meet) <= voice_leading_cost(m1) else '✗'}")
        print()


# ─── Demo 7: Full Quiver Enumeration ────────────────────────────────────────

def demo_full_enumeration() -> None:
    """
    Complete enumeration of the Counterpoint Quiver's arrow counts.
    """
    print("=" * 72)
    print("DEMO 7: Full Counterpoint Quiver — Arrow Count Matrix")
    print("=" * 72)
    print()

    sorted_consonant = sorted(CONSONANT)
    short_names = {0: "P1", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}

    # Build count matrix
    matrix: dict[tuple[int, int], int] = {}
    for src in sorted_consonant:
        for tgt in sorted_consonant:
            count = sum(
                1 for b in range(12) for s in range(12)
                if is_permitted(src, tgt, VoiceLeading(b, s))
            )
            matrix[(src, tgt)] = count

    # Print matrix
    header = "     " + " ".join(f"{short_names[t]:>4s}" for t in sorted_consonant) + "  | Row Σ"
    print(f"  {header}")
    print(f"  {'─' * len(header)}")
    for src in sorted_consonant:
        row_vals = [matrix[(src, tgt)] for tgt in sorted_consonant]
        row_str = " ".join(f"{v:4d}" for v in row_vals)
        print(f"  {short_names[src]:>3s}  {row_str}  | {sum(row_vals):5d}")

    # Column sums
    col_sums = [sum(matrix[(s, t)] for s in sorted_consonant) for t in sorted_consonant]
    col_str = " ".join(f"{v:4d}" for v in col_sums)
    print(f"  {'─' * len(header)}")
    print(f"  Col  {col_str}  | {sum(col_sums):5d}")
    print()

    perf_incoming = [sum(matrix[(s, t)] for s in sorted_consonant) for t in sorted_consonant if t in PERFECT]
    imp_incoming = [sum(matrix[(s, t)] for s in sorted_consonant) for t in sorted_consonant if t not in PERFECT]
    print(f"  Avg incoming to PERFECT consonances: {sum(perf_incoming)/len(perf_incoming):.1f}")
    print(f"  Avg incoming to IMPERFECT consonances: {sum(imp_incoming)/len(imp_incoming):.1f}")
    print(f"  Bottleneck ratio: {sum(perf_incoming)/len(perf_incoming) / (sum(imp_incoming)/len(imp_incoming)):.3f}")
    print()


# ─── Main ────────────────────────────────────────────────────────────────────

def main() -> None:
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
    demo_seminorm_and_lattice()
    demo_ascending_sublattice()
    demo_full_enumeration()

    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
