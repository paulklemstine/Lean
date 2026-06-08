#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

This module demonstrates the key results of the counterpoint quiver formalization:
  1. Strong connectivity of the counterpoint quiver
  2. Non-composability of permitted voice leadings
  3. Self-loop bottleneck (12:1 ratio perfect vs imperfect)
  4. Voice-swap asymmetry
  5. Hom-set computation (61 vs 72 incoming edges)

All computations are over Z_12 (integers mod 12), matching the formal proofs.
"""

from __future__ import annotations
from typing import NamedTuple
from itertools import product


# ── Core Definitions ──────────────────────────────────────────────────────────

N = 12  # chromatic pitch classes

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison/Octave",
    3: "Minor Third",
    4: "Major Third",
    7: "Perfect Fifth",
    8: "Minor Sixth",
    9: "Major Sixth",
}


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in Z_12."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval: source + soprano - bass (mod 12)."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass % N == vl.soprano % N and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check whether a voice leading from source to target is permitted."""
    return (
        source % N in CONSONANT
        and target % N in CONSONANT
        and target_interval(source, vl) == target % N
        and not (target % N in PERFECT and is_parallel(vl))
    )


def all_voice_leadings() -> list[VoiceLeading]:
    """All 144 voice leadings over Z_12."""
    return [VoiceLeading(b, s) for b, s in product(range(N), repeat=2)]


def permitted_vls(source: int, target: int) -> list[VoiceLeading]:
    """All permitted voice leadings from source to target."""
    return [vl for vl in all_voice_leadings() if is_permitted(source, target, vl)]


def canonical_vl(source: int, target: int) -> VoiceLeading:
    """The canonical voice leading: bass holds, soprano adjusts."""
    return VoiceLeading(0, (target - source) % N)


# ── Demonstration 1: Strong Connectivity ──────────────────────────────────────

def demo_strong_connectivity() -> None:
    """Show that every pair of consonant intervals is connected."""
    print("=" * 70)
    print("DEMO 1: Strong Connectivity of the Counterpoint Quiver")
    print("=" * 70)
    print()
    print("For every pair (i, j) of consonant intervals, we exhibit a")
    print("permitted voice leading from i to j (the canonical VL).")
    print()

    intervals = sorted(CONSONANT)
    all_connected = True

    for i in intervals:
        for j in intervals:
            cvl = canonical_vl(i, j)
            ok = is_permitted(i, j, cvl)
            count = len(permitted_vls(i, j))
            status = "✓" if ok else "✗"
            print(
                f"  {status}  {INTERVAL_NAMES[i]:>15s} → {INTERVAL_NAMES[j]:<15s}  "
                f"canonical=({cvl.bass},{cvl.soprano})  "
                f"total permitted={count}"
            )
            if not ok:
                all_connected = False

    print()
    print(f"  Result: {'All pairs connected — quiver is strongly connected.' if all_connected else 'FAILURE: some pairs not connected.'}")
    print()


# ── Demonstration 2: Non-Composability ────────────────────────────────────────

def compose_vl(vl1: VoiceLeading, vl2: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings: apply vl1 then vl2."""
    return VoiceLeading((vl1.bass + vl2.bass) % N, (vl1.soprano + vl2.soprano) % N)


def demo_non_composability() -> None:
    """Find a concrete example where two permitted VLs compose into a forbidden one."""
    print("=" * 70)
    print("DEMO 2: Non-Composability of Permitted Voice Leadings")
    print("=" * 70)
    print()
    print("We search for permitted VLs vl1: i→j and vl2: j→k whose")
    print("composition vl2∘vl1: i→k is NOT permitted.")
    print()

    intervals = sorted(CONSONANT)
    found = 0

    for i in intervals:
        for j in intervals:
            for k in intervals:
                for vl1 in permitted_vls(i, j):
                    for vl2 in permitted_vls(j, k):
                        comp = compose_vl(vl1, vl2)
                        comp_target = target_interval(i, comp)
                        if comp_target == k and not is_permitted(i, k, comp):
                            if found < 3:
                                print(
                                    f"  Example {found+1}: "
                                    f"{INTERVAL_NAMES[i]} →({vl1.bass},{vl1.soprano})→ "
                                    f"{INTERVAL_NAMES[j]} →({vl2.bass},{vl2.soprano})→ "
                                    f"{INTERVAL_NAMES[k]}"
                                )
                                print(
                                    f"    Composition = ({comp.bass},{comp.soprano}), "
                                    f"parallel={is_parallel(comp)}, "
                                    f"target_perfect={k in PERFECT}"
                                )
                                print(f"    vl1 permitted: True")
                                print(f"    vl2 permitted: True")
                                print(f"    composition permitted: False  ← breaks!")
                                print()
                            found += 1

    print(f"  Total non-composable triples found: {found}")
    print(f"  Conclusion: permitted VLs do NOT form a subcategory.")
    print()


# ── Demonstration 3: Self-Loop Bottleneck ─────────────────────────────────────

def demo_self_loop_bottleneck() -> None:
    """Count self-loops at each consonant interval."""
    print("=" * 70)
    print("DEMO 3: Self-Loop Bottleneck (12:1 Ratio)")
    print("=" * 70)
    print()
    print("Self-loops = voice leadings that preserve the interval.")
    print()

    intervals = sorted(CONSONANT)
    for i in intervals:
        loops = permitted_vls(i, i)
        ptype = "PERFECT" if i in PERFECT else "imperfect"
        print(f"  {INTERVAL_NAMES[i]:>15s} ({ptype:>9s}): {len(loops):2d} self-loops")
        if len(loops) <= 3:
            for vl in loops:
                print(f"    └─ ({vl.bass},{vl.soprano})")

    print()
    print("  Perfect consonances: 1 self-loop each (identity only)")
    print("  Imperfect consonances: 12 self-loops each (all parallel motions allowed)")
    print("  Ratio: 12:1 — maximal bottleneck at perfect consonances")
    print()


# ── Demonstration 4: Voice-Swap Asymmetry ─────────────────────────────────────

def demo_voice_swap() -> None:
    """Show that negation (voice swap) does not preserve consonance."""
    print("=" * 70)
    print("DEMO 4: Voice-Swap Asymmetry")
    print("=" * 70)
    print()
    print("The voice-swap involution sends interval i to -i (mod 12).")
    print("If consonance were symmetric, swapping bass and soprano would")
    print("preserve all consonant intervals. But it doesn't.")
    print()

    swapped = {(-i) % N for i in CONSONANT}
    print(f"  Consonant intervals C = {sorted(CONSONANT)}")
    print(f"  Swapped set -C        = {sorted(swapped)}")
    print(f"  Symmetric difference  = {sorted(CONSONANT.symmetric_difference(swapped))}")
    print()

    for i in sorted(CONSONANT):
        neg = (-i) % N
        preserved = neg in CONSONANT
        status = "✓ consonant" if preserved else "✗ DISSONANT"
        name_neg = INTERVAL_NAMES.get(neg, f"interval {neg}")
        print(f"  {INTERVAL_NAMES[i]:>15s} ({i:2d}) → neg = {neg:2d} ({name_neg}) : {status}")

    print()
    print("  Key: Perfect fifth (7) maps to perfect fourth (5), which is DISSONANT.")
    print("  The bass voice has a structurally privileged role in counterpoint.")
    print()


# ── Demonstration 5: Hom-Set Computation ──────────────────────────────────────

def demo_hom_sets() -> None:
    """Compute the full adjacency matrix and incoming edge counts."""
    print("=" * 70)
    print("DEMO 5: Hom-Set Computation (61 vs 72 Incoming Edges)")
    print("=" * 70)
    print()

    intervals = sorted(CONSONANT)

    # Adjacency matrix
    print("  Adjacency matrix A[i,j] = |Hom(i,j)| :")
    print()
    header = "        " + "".join(f"{INTERVAL_NAMES[j][:5]:>8s}" for j in intervals)
    print(header)
    print("        " + "-" * (8 * len(intervals)))

    for i in intervals:
        row = f"  {INTERVAL_NAMES[i][:5]:>5s} |"
        for j in intervals:
            count = len(permitted_vls(i, j))
            row += f"{count:8d}"
        print(row)

    print()

    # Incoming edge counts
    print("  Incoming edge counts (summed over all sources):")
    print()
    for j in intervals:
        total_in = sum(len(permitted_vls(i, j)) for i in intervals)
        ptype = "PERFECT" if j in PERFECT else "imperfect"
        print(f"    {INTERVAL_NAMES[j]:>15s} ({ptype:>9s}): {total_in} incoming VLs")

    # Totals
    total_all = sum(
        len(permitted_vls(i, j)) for i in intervals for j in intervals
    )
    total_unrestricted = len(intervals) ** 2 * N
    print()
    print(f"  Total permitted voice leadings: {total_all}")
    print(f"  Total unrestricted (6×6×12):    {total_unrestricted}")
    print(f"  Forbidden by parallel rule:     {total_unrestricted - total_all}")
    print(f"  Reduction:                      {100*(total_unrestricted - total_all)/total_unrestricted:.1f}%")
    print()


# ── Demonstration 6: Microtonal Generalization ────────────────────────────────

def demo_microtonal() -> None:
    """Explore the counterpoint system in 19-TET and 31-TET."""
    print("=" * 70)
    print("DEMO 6: Microtonal Generalization (19-TET and 31-TET)")
    print("=" * 70)
    print()
    print("The CounterpointSystem framework parameterizes over Z_n.")
    print("We explore hypothetical consonance sets in other tuning systems.")
    print()

    # 19-TET: approximate consonances (closest to just intervals)
    # P5 ≈ 11, M3 ≈ 6, m3 ≈ 5, M6 ≈ 14, m6 ≈ 13
    systems: list[tuple[str, int, set[int], set[int]]] = [
        ("19-TET", 19, {0, 5, 6, 11, 13, 14}, {0, 11}),
        ("31-TET", 31, {0, 8, 10, 18, 21, 23}, {0, 18}),
    ]

    for name, n, cons, perf in systems:
        print(f"  {name} (n={n}):")
        print(f"    Consonant: {sorted(cons)}")
        print(f"    Perfect:   {sorted(perf)}")

        # Check voice-swap symmetry
        swapped = {(-i) % n for i in cons}
        symmetric = cons == swapped
        print(f"    Voice-swap symmetric: {symmetric}")
        if not symmetric:
            diff = sorted(cons.symmetric_difference(swapped))
            print(f"    Symmetric difference: {diff}")

        # Count self-loops at perfect vs imperfect
        for p in sorted(perf):
            loops = sum(
                1
                for b in range(n)
                for s in range(n)
                if (p + s - b) % n == p
                and p in cons
                and not (p in perf and b == s and b != 0)
            )
            print(f"    Self-loops at {p} (perfect): {loops}")

        imp_example = sorted(cons - perf)[0]
        loops_imp = sum(
            1
            for b in range(n)
            for s in range(n)
            if (imp_example + s - b) % n == imp_example
            and imp_example in cons
            and not (imp_example in perf and b == s and b != 0)
        )
        print(f"    Self-loops at {imp_example} (imperfect): {loops_imp}")
        print(f"    Bottleneck ratio: {loops_imp}:1")
        print()


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     SONIC MATHEMATICS: COUNTERPOINT AS CATEGORY THEORY             ║")
    print("║     Numerical Demonstrations of Formal Results                     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_strong_connectivity()
    demo_non_composability()
    demo_self_loop_bottleneck()
    demo_voice_swap()
    demo_hom_sets()
    demo_microtonal()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
