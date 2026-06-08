#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

This script enumerates all permitted voice leadings in first-species counterpoint
over the 12-TET chromatic scale and verifies the five main theorems:

  1. Strong connectivity of the counterpoint quiver
  2. Non-composability of permitted voice leadings
  3. Self-loop bottleneck (1 for perfect, 12 for imperfect consonances)
  4. Voice-swap asymmetry (σ(7) = 5 ∉ C₁₂)
  5. Hom-set cardinalities (61 vs 72 incoming voice leadings)

All arithmetic is mod 12. No external dependencies required.
"""

from __future__ import annotations
from typing import NamedTuple
from itertools import product


# ─── Core Definitions ───────────────────────────────────────────────────────────

MODULUS: int = 12

CONSONANT_INTERVALS: frozenset[int] = frozenset({0, 3, 4, 7, 8, 9})
PERFECT_CONSONANCES: frozenset[int] = frozenset({0, 7})
IMPERFECT_CONSONANCES: frozenset[int] = CONSONANT_INTERVALS - PERFECT_CONSONANCES

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison/Octave",
    3: "Minor third",
    4: "Major third",
    7: "Perfect fifth",
    8: "Minor sixth",
    9: "Major sixth",
}


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in semitones mod 12."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval given source and voice leading."""
    return (source + vl.soprano - vl.bass) % MODULUS


def is_parallel(vl: VoiceLeading) -> bool:
    """Check if a voice leading is parallel (same nonzero motion in both voices)."""
    return vl.bass % MODULUS == vl.soprano % MODULUS and vl.bass % MODULUS != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading from source to target is permitted."""
    return (
        source % MODULUS in CONSONANT_INTERVALS
        and target % MODULUS in CONSONANT_INTERVALS
        and target_interval(source, vl) == target % MODULUS
        and not (target % MODULUS in PERFECT_CONSONANCES and is_parallel(vl))
    )


def all_voice_leadings() -> list[VoiceLeading]:
    """Generate all 144 voice leadings over Z/12Z."""
    return [VoiceLeading(b, s) for b, s in product(range(MODULUS), repeat=2)]


def permitted_vls(source: int, target: int) -> list[VoiceLeading]:
    """Enumerate all permitted voice leadings from source to target."""
    return [vl for vl in all_voice_leadings() if is_permitted(source, target, vl)]


# ─── Theorem Demonstrations ─────────────────────────────────────────────────────

def demo_strong_connectivity() -> None:
    """Theorem 1: Between any two consonant intervals, a permitted VL exists."""
    print("=" * 72)
    print("THEOREM 1: Strong Connectivity")
    print("=" * 72)
    print()
    all_connected = True
    for i in sorted(CONSONANT_INTERVALS):
        for j in sorted(CONSONANT_INTERVALS):
            vls = permitted_vls(i, j)
            if not vls:
                print(f"  ✗ No permitted VL from {i} to {j}!")
                all_connected = False
            else:
                # Show the canonical voice leading
                canonical = VoiceLeading(0, (j - i) % MODULUS)
                mark = "✓" if canonical in vls else "~"
                print(
                    f"  {mark} {INTERVAL_NAMES[i]:15s} → {INTERVAL_NAMES[j]:15s}: "
                    f"{len(vls):2d} permitted VLs "
                    f"(canonical: bass=0, soprano={canonical.soprano})"
                )
    print()
    print(f"  Result: {'ALL pairs connected ✓' if all_connected else 'CONNECTIVITY FAILS ✗'}")
    print()


def demo_non_composability() -> None:
    """Theorem 2: Permitted VLs do not compose — find a concrete counterexample."""
    print("=" * 72)
    print("THEOREM 2: Non-Composability of Permitted Voice Leadings")
    print("=" * 72)
    print()

    found = False
    for i in sorted(CONSONANT_INTERVALS):
        if found:
            break
        for j in sorted(CONSONANT_INTERVALS):
            if found:
                break
            for k in sorted(CONSONANT_INTERVALS):
                if found:
                    break
                for v1 in permitted_vls(i, j):
                    if found:
                        break
                    for v2 in permitted_vls(j, k):
                        # Compose: add the motions
                        comp = VoiceLeading(
                            (v1.bass + v2.bass) % MODULUS,
                            (v1.soprano + v2.soprano) % MODULUS,
                        )
                        if not is_permitted(i, k, comp):
                            print(f"  Counterexample found!")
                            print(f"    Step 1: {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[j]} "
                                  f"via VL(bass={v1.bass}, soprano={v1.soprano})")
                            print(f"    Step 2: {INTERVAL_NAMES[j]} → {INTERVAL_NAMES[k]} "
                                  f"via VL(bass={v2.bass}, soprano={v2.soprano})")
                            print(f"    Composed: VL(bass={comp.bass}, soprano={comp.soprano})")
                            print(f"    Target of composed VL from {i}: "
                                  f"{target_interval(i, comp)}")
                            print(f"    Is parallel: {is_parallel(comp)}")
                            print(f"    Target is perfect: {k in PERFECT_CONSONANCES}")
                            print(f"    ⇒ Composition is FORBIDDEN ✗")
                            print()
                            print("  Result: Permitted VLs do NOT compose — "
                                  "they do not form a subcategory ✓")
                            found = True
                            break
    print()


def demo_self_loop_bottleneck() -> None:
    """Theorems 3a/3b: Perfect consonances have 1 self-loop; imperfect have 12."""
    print("=" * 72)
    print("THEOREM 3: Self-Loop Bottleneck (Perfect vs Imperfect)")
    print("=" * 72)
    print()

    for i in sorted(CONSONANT_INTERVALS):
        loops = permitted_vls(i, i)
        typ = "PERFECT" if i in PERFECT_CONSONANCES else "IMPERFECT"
        print(f"  {INTERVAL_NAMES[i]:15s} ({typ:9s}): {len(loops):2d} self-loops")
        if len(loops) <= 3:
            for vl in loops:
                print(f"      VL(bass={vl.bass}, soprano={vl.soprano})")

    print()
    perfect_total = sum(len(permitted_vls(p, p)) for p in PERFECT_CONSONANCES)
    imperfect_total = sum(len(permitted_vls(q, q)) for q in IMPERFECT_CONSONANCES)
    print(f"  Perfect consonance self-loops:   {perfect_total} total "
          f"({perfect_total // len(PERFECT_CONSONANCES)} each)")
    print(f"  Imperfect consonance self-loops: {imperfect_total} total "
          f"({imperfect_total // len(IMPERFECT_CONSONANCES)} each)")
    print(f"  Ratio: 1:{imperfect_total // len(IMPERFECT_CONSONANCES)}")
    print()


def demo_voice_swap_asymmetry() -> None:
    """Theorem 4: The involution i ↦ -i (mod 12) does not preserve consonance."""
    print("=" * 72)
    print("THEOREM 4: Voice-Swap Asymmetry")
    print("=" * 72)
    print()

    print("  Voice exchange involution σ(i) = -i mod 12:")
    print()
    all_preserved = True
    for i in sorted(CONSONANT_INTERVALS):
        neg_i = (-i) % MODULUS
        preserved = neg_i in CONSONANT_INTERVALS
        name_neg = INTERVAL_NAMES.get(neg_i, f"({neg_i} semitones)")
        mark = "✓" if preserved else "✗ BREAKS CONSONANCE"
        print(f"    σ({INTERVAL_NAMES[i]:15s}) = {name_neg:15s}  [{mark}]")
        if not preserved:
            all_preserved = False

    print()
    if not all_preserved:
        print("  Result: Voice exchange does NOT preserve consonance ✓")
        print("  The perfect fifth (7) maps to the perfect fourth (5),")
        print("  which is dissonant in first-species counterpoint.")
        print("  This formalizes the asymmetric role of the bass voice.")
    else:
        print("  Result: Voice exchange preserves consonance (unexpected)")
    print()


def demo_hom_set_cardinalities() -> None:
    """Theorems 5a/5b: Perfect targets get 61 incoming VLs; imperfect get 72."""
    print("=" * 72)
    print("THEOREM 5: Hom-Set Cardinalities")
    print("=" * 72)
    print()

    # Build the full hom-set table
    sorted_consonances = sorted(CONSONANT_INTERVALS)
    print("  Complete hom-set table |Hom(source, target)|:")
    print()
    header = "  Source\\Target  " + "".join(f"{i:>5d}" for i in sorted_consonances)
    print(header)
    print("  " + "-" * (len(header) - 2))

    col_sums: dict[int, int] = {j: 0 for j in sorted_consonances}
    row_sums: dict[int, int] = {i: 0 for i in sorted_consonances}
    total_edges = 0

    for i in sorted_consonances:
        row = f"  {INTERVAL_NAMES[i]:15s}"
        for j in sorted_consonances:
            count = len(permitted_vls(i, j))
            row += f"{count:5d}"
            col_sums[j] += count
            row_sums[i] += count
            total_edges += count
        row += f"  | {row_sums[i]:3d}"
        print(row)

    print("  " + "-" * (len(header) - 2))
    footer = "  Column sums    " + "".join(f"{col_sums[j]:5d}" for j in sorted_consonances)
    print(footer)
    print()

    for j in sorted_consonances:
        typ = "PERFECT" if j in PERFECT_CONSONANCES else "IMPERFECT"
        print(f"  {INTERVAL_NAMES[j]:15s} ({typ:9s}): {col_sums[j]:3d} incoming VLs")

    print()
    print(f"  Total edges in quiver: {total_edges}")
    print()

    # Verify the theorem values
    perfect_incoming = {p: col_sums[p] for p in sorted(PERFECT_CONSONANCES)}
    imperfect_incoming = {q: col_sums[q] for q in sorted(IMPERFECT_CONSONANCES)}

    assert all(v == 61 for v in perfect_incoming.values()), \
        f"Perfect incoming counts not all 61: {perfect_incoming}"
    assert all(v == 72 for v in imperfect_incoming.values()), \
        f"Imperfect incoming counts not all 72: {imperfect_incoming}"

    print("  ✓ All perfect consonances: 61 incoming VLs each")
    print("  ✓ All imperfect consonances: 72 incoming VLs each")
    print(f"  ✓ Reduction factor: (72-61)/72 = {(72-61)/72:.1%}")
    print()


def demo_quiver_statistics() -> None:
    """Summary statistics for the full counterpoint quiver."""
    print("=" * 72)
    print("SUMMARY: The Counterpoint Quiver Q(C₁₂, P₁₂)")
    print("=" * 72)
    print()
    print(f"  Vertices: {len(CONSONANT_INTERVALS)} consonant intervals")
    print(f"    Perfect:   {sorted(PERFECT_CONSONANCES)} "
          f"({', '.join(INTERVAL_NAMES[p] for p in sorted(PERFECT_CONSONANCES))})")
    print(f"    Imperfect: {sorted(IMPERFECT_CONSONANCES)} "
          f"({', '.join(INTERVAL_NAMES[q] for q in sorted(IMPERFECT_CONSONANCES))})")

    total_edges = sum(
        len(permitted_vls(i, j))
        for i in CONSONANT_INTERVALS
        for j in CONSONANT_INTERVALS
    )
    total_self_loops = sum(len(permitted_vls(i, i)) for i in CONSONANT_INTERVALS)

    print(f"  Edges: {total_edges} permitted voice leadings")
    print(f"    Self-loops: {total_self_loops}")
    print(f"    Non-loops:  {total_edges - total_self_loops}")
    print(f"  Average in-degree: {total_edges / len(CONSONANT_INTERVALS):.1f}")
    print(f"  Average out-degree: {total_edges / len(CONSONANT_INTERVALS):.1f}")
    print()

    # Density: edges / (vertices² × max_edges_per_pair)
    max_possible = len(CONSONANT_INTERVALS) ** 2 * MODULUS
    print(f"  Edge density: {total_edges}/{max_possible} = "
          f"{total_edges/max_possible:.3f} of maximum")
    print()


# ─── Main ────────────────────────────────────────────────────────────────────────

def main() -> None:
    """Run all theorem demonstrations."""
    print()
    print("╔" + "═" * 70 + "╗")
    print("║  SONIC MATHEMATICS: Counterpoint as Category Theory               ║")
    print("║  Numerical Demonstrations of the Five Main Theorems               ║")
    print("╚" + "═" * 70 + "╝")
    print()

    demo_quiver_statistics()
    demo_strong_connectivity()
    demo_non_composability()
    demo_self_loop_bottleneck()
    demo_voice_swap_asymmetry()
    demo_hom_set_cardinalities()

    print("=" * 72)
    print("All theorems verified numerically. ✓")
    print("=" * 72)


if __name__ == "__main__":
    main()
