#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

This script demonstrates the key results from the formal verification of
first-species counterpoint as a directed graph over ℤ/12ℤ.

Results demonstrated:
  1. Strong connectivity of the counterpoint quiver
  2. Self-loop asymmetry (1 vs 12) between perfect and imperfect consonances
  3. Non-composability of permitted voice leadings
  4. Voice-swap asymmetry (perfect fifth ↦ perfect fourth)
  5. Hom-set cardinalities (61 vs 72)
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import NamedTuple


# ── Musical constants ──────────────────────────────────────────────────

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison (P1)",
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
    """A voice leading: (bass_motion, soprano_motion) in semitones mod 12."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval given a source interval and voice leading."""
    return (source + vl.soprano - vl.bass) % 12


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass == vl.soprano and vl.bass != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading from source to target is permitted."""
    if source not in CONSONANT:
        return False
    if target not in CONSONANT:
        return False
    if target_interval(source, vl) != target:
        return False
    if target in PERFECT and is_parallel(vl):
        return False
    return True


def all_permitted_vls(source: int, target: int) -> list[VoiceLeading]:
    """Enumerate all permitted voice leadings from source to target."""
    result: list[VoiceLeading] = []
    for b in range(12):
        for s in range(12):
            vl = VoiceLeading(b, s)
            if is_permitted(source, target, vl):
                result.append(vl)
    return result


def compose(vl1: VoiceLeading, vl2: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings (component-wise addition mod 12)."""
    return VoiceLeading((vl1.bass + vl2.bass) % 12, (vl1.soprano + vl2.soprano) % 12)


# ── Demonstration Functions ────────────────────────────────────────────

def demo_consonant_intervals() -> None:
    """Display the consonant and perfect intervals."""
    print("=" * 65)
    print("THE CONSONANT INTERVALS OF FIRST-SPECIES COUNTERPOINT")
    print("=" * 65)
    print()
    for i in sorted(CONSONANT):
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"  {i:2d} semitones  →  {INTERVAL_NAMES[i]:<16s}  [{kind}]")
    print()
    print(f"Total consonances: {len(CONSONANT)}")
    print(f"  Perfect:   {sorted(PERFECT)}")
    print(f"  Imperfect: {sorted(IMPERFECT)}")
    print()


def demo_strong_connectivity() -> None:
    """Demonstrate Theorem 3.1: strong connectivity."""
    print("=" * 65)
    print("THEOREM 3.1: STRONG CONNECTIVITY")
    print("=" * 65)
    print()
    print("For every pair of consonant intervals (i, j), there exists")
    print("at least one permitted voice leading from i to j.")
    print()

    all_connected = True
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            vls = all_permitted_vls(i, j)
            count = len(vls)
            if count == 0:
                all_connected = False
                print(f"  {INTERVAL_NAMES[i]:>16s} → {INTERVAL_NAMES[j]:<16s}: "
                      f"NO VOICE LEADINGS ✗")
            else:
                # Show one example
                ex = vls[0]
                print(f"  {INTERVAL_NAMES[i]:>16s} → {INTERVAL_NAMES[j]:<16s}: "
                      f"{count:2d} voice leadings  "
                      f"(e.g. bass={ex.bass:+d}, sop={ex.soprano:+d})")

    print()
    status = "✓ VERIFIED" if all_connected else "✗ FAILED"
    print(f"Strong connectivity: {status}")
    print()


def demo_self_loop_asymmetry() -> None:
    """Demonstrate Theorems 3.2–3.3: self-loop bottleneck."""
    print("=" * 65)
    print("THEOREMS 3.2–3.3: SELF-LOOP ASYMMETRY (BOTTLENECK)")
    print("=" * 65)
    print()
    print("Perfect consonances admit exactly 1 self-loop (the identity).")
    print("Imperfect consonances admit all 12 self-loops.")
    print()

    for i in sorted(CONSONANT):
        self_loops = all_permitted_vls(i, i)
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"  {INTERVAL_NAMES[i]:>16s} ({kind:>9s}): "
              f"{len(self_loops):2d} self-loop(s)")
        if i in PERFECT:
            # Show the unique self-loop
            assert len(self_loops) == 1
            assert self_loops[0] == VoiceLeading(0, 0)
            print(f"    └─ Only: identity (0, 0)")
        else:
            assert len(self_loops) == 12

    print()
    print("Bottleneck ratio (perfect : imperfect) = 1 : 12  ✓")
    print()


def demo_non_composability() -> None:
    """Demonstrate Theorem 3.6: non-composability."""
    print("=" * 65)
    print("THEOREM 3.6: NON-COMPOSABILITY")
    print("=" * 65)
    print()
    print("Two individually permitted voice leadings can compose into")
    print("a forbidden one. Here are concrete examples:")
    print()

    examples_found = 0
    for i in sorted(CONSONANT):
        if examples_found >= 3:
            break
        for j in sorted(CONSONANT):
            if examples_found >= 3:
                break
            for k in sorted(CONSONANT):
                if examples_found >= 3:
                    break
                for vl1 in all_permitted_vls(i, j):
                    if examples_found >= 3:
                        break
                    for vl2 in all_permitted_vls(j, k):
                        comp = compose(vl1, vl2)
                        if not is_permitted(i, k, comp):
                            examples_found += 1
                            print(f"  Example {examples_found}:")
                            print(f"    Step 1: {INTERVAL_NAMES[i]} → "
                                  f"{INTERVAL_NAMES[j]} via "
                                  f"(bass={vl1.bass}, sop={vl1.soprano})  ✓ permitted")
                            print(f"    Step 2: {INTERVAL_NAMES[j]} → "
                                  f"{INTERVAL_NAMES[k]} via "
                                  f"(bass={vl2.bass}, sop={vl2.soprano})  ✓ permitted")
                            print(f"    Composed: {INTERVAL_NAMES[i]} → "
                                  f"{INTERVAL_NAMES[k]} via "
                                  f"(bass={comp.bass}, sop={comp.soprano})  "
                                  f"✗ FORBIDDEN")
                            reason = ""
                            if k in PERFECT and is_parallel(comp):
                                reason = f"(parallel motion into {INTERVAL_NAMES[k]})"
                            elif target_interval(i, comp) != k:
                                reason = "(doesn't reach target)"
                            print(f"    Reason: {reason}")
                            print()
                            break

    print("Permitted voice leadings do NOT form a subcategory.  ✓")
    print()


def demo_voice_swap() -> None:
    """Demonstrate Theorem 3.8: voice-swap breaks consonance."""
    print("=" * 65)
    print("THEOREM 3.8: VOICE-SWAP BREAKS CONSONANCE")
    print("=" * 65)
    print()
    print("The involution i ↦ −i (mod 12) does NOT preserve consonance.")
    print()
    print("  Interval  →  Negation  →  Consonant?")
    print("  ─────────────────────────────────────")

    swap_preserves = True
    for i in sorted(CONSONANT):
        neg = (-i) % 12
        is_cons = neg in CONSONANT
        mark = "✓" if is_cons else "✗ BREAKS!"
        print(f"    {i:2d} ({INTERVAL_NAMES[i]:>16s})  →  "
              f"{neg:2d} ({INTERVAL_NAMES[neg]:>16s})  {mark}")
        if not is_cons:
            swap_preserves = False

    print()
    print(f"Voice swap preserves consonance: {'Yes' if swap_preserves else 'NO'}  ✓")
    print()
    print("The perfect fifth (7) maps to the perfect fourth (5),")
    print("which is DISSONANT in counterpoint. This formalizes the")
    print("asymmetric role of the bass voice.")
    print()


def demo_hom_set_cardinalities() -> None:
    """Demonstrate Theorem 3.9: incoming voice-leading counts."""
    print("=" * 65)
    print("THEOREM 3.9: HOM-SET CARDINALITIES (61 vs 72)")
    print("=" * 65)
    print()
    print("Total permitted incoming voice leadings to each consonance:")
    print()

    for j in sorted(CONSONANT):
        total = sum(len(all_permitted_vls(i, j)) for i in sorted(CONSONANT))
        kind = "PERFECT" if j in PERFECT else "imperfect"
        expected = 61 if j in PERFECT else 72
        check = "✓" if total == expected else "✗"
        print(f"  → {INTERVAL_NAMES[j]:>16s} ({kind:>9s}): "
              f"{total:3d} incoming  (expected {expected})  {check}")

    print()
    print("Perfect consonances: 61 incoming voice leadings each")
    print("Imperfect consonances: 72 incoming voice leadings each")
    print(f"Constraint differential: {(72-61)/72*100:.1f}% reduction  ✓")
    print()


def demo_adjacency_matrix() -> None:
    """Display the full adjacency matrix of the counterpoint quiver."""
    print("=" * 65)
    print("ADJACENCY MATRIX OF THE COUNTERPOINT QUIVER")
    print("=" * 65)
    print()
    intervals = sorted(CONSONANT)
    header = "      " + "".join(f"  →{i:<3d}" for i in intervals)
    print(header)
    print("      " + "─" * (6 * len(intervals)))

    for i in intervals:
        row = f"  {i:2d} │"
        for j in intervals:
            count = len(all_permitted_vls(i, j))
            row += f"  {count:3d} "
        print(row)

    print()
    print("Note: Diagonal entries for perfect consonances (0, 7) = 1")
    print("      Diagonal entries for imperfect consonances = 12")
    print("      This is the bottleneck theorem in matrix form.")
    print()


def demo_motion_types() -> None:
    """Classify all permitted voice leadings by motion type."""
    print("=" * 65)
    print("VOICE LEADING CLASSIFICATION BY MOTION TYPE")
    print("=" * 65)
    print()

    total_contrary = 0
    total_oblique = 0
    total_similar = 0
    total_parallel = 0
    total_static = 0

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for vl in all_permitted_vls(i, j):
                if vl.bass == 0 and vl.soprano == 0:
                    total_static += 1
                elif vl.bass == 0 or vl.soprano == 0:
                    total_oblique += 1
                elif vl.bass == vl.soprano:
                    total_parallel += 1
                elif (vl.bass < 6) != (vl.soprano < 6):
                    # Crude contrary motion check (one up, one down in mod 12)
                    total_contrary += 1
                else:
                    total_similar += 1

    total = total_static + total_oblique + total_parallel + total_contrary + total_similar
    print(f"  Static (identity):     {total_static:4d}  ({total_static/total*100:5.1f}%)")
    print(f"  Oblique (one holds):   {total_oblique:4d}  ({total_oblique/total*100:5.1f}%)")
    print(f"  Parallel (same):       {total_parallel:4d}  ({total_parallel/total*100:5.1f}%)")
    print(f"  Similar (same dir):    {total_similar:4d}  ({total_similar/total*100:5.1f}%)")
    print(f"  Contrary (opp dir):    {total_contrary:4d}  ({total_contrary/total*100:5.1f}%)")
    print(f"  ─────────────────────────────")
    print(f"  Total permitted:       {total:4d}")
    print()


# ── Main ───────────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║  SONIC MATHEMATICS: COUNTERPOINT AS CATEGORY THEORY         ║")
    print("║  Numerical Demonstrations of Formally Verified Results      ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    demo_consonant_intervals()
    demo_strong_connectivity()
    demo_self_loop_asymmetry()
    demo_non_composability()
    demo_voice_swap()
    demo_hom_set_cardinalities()
    demo_adjacency_matrix()
    demo_motion_types()

    print("=" * 65)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 65)
    print()
    print("Summary of verified results:")
    print("  ✓ Theorem 3.1: Strong connectivity (all pairs reachable)")
    print("  ✓ Theorem 3.2: Perfect self-loop uniqueness (1 each)")
    print("  ✓ Theorem 3.3: Imperfect self-loops (12 each)")
    print("  ✓ Theorem 3.6: Non-composability (concrete examples found)")
    print("  ✓ Theorem 3.8: Voice-swap breaks consonance (7 ↦ 5)")
    print("  ✓ Theorem 3.9: Hom-sets: 61 (perfect) vs 72 (imperfect)")
    print()


if __name__ == "__main__":
    main()
