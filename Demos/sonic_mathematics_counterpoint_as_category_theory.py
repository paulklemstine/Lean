#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

Demonstrates the five main theorems about the voice-leading quiver of
first-species counterpoint over the 12-tone chromatic scale.

Self-contained. No external dependencies beyond Python 3.6+ standard library.
"""

from __future__ import annotations
from typing import NamedTuple, FrozenSet
from itertools import product


# ──────────────────────────────────────────────────────────────────────
# §1  Core Definitions
# ──────────────────────────────────────────────────────────────────────

CONSONANT: FrozenSet[int] = frozenset({0, 3, 4, 7, 8, 9})
PERFECT: FrozenSet[int] = frozenset({0, 7})
IMPERFECT: FrozenSet[int] = CONSONANT - PERFECT
N: int = 12

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison/Octave",
    3: "Minor Third",
    4: "Major Third",
    7: "Perfect Fifth",
    8: "Minor Sixth",
    9: "Major Sixth",
}


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in Z/12Z."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval given a source interval and a voice leading."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass % N == vl.soprano % N and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading from source to target is permitted."""
    return (
        source % N in CONSONANT
        and target % N in CONSONANT
        and target_interval(source, vl) == target % N
        and not (target % N in PERFECT and is_parallel(vl))
    )


def all_voice_leadings() -> list[VoiceLeading]:
    """Return all 144 voice leadings in Z/12Z × Z/12Z."""
    return [VoiceLeading(b, s) for b, s in product(range(N), repeat=2)]


def permitted_vls(source: int, target: int) -> list[VoiceLeading]:
    """Return all permitted voice leadings from source to target."""
    return [vl for vl in all_voice_leadings() if is_permitted(source, target, vl)]


def compose(v1: VoiceLeading, v2: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings (apply v1 then v2)."""
    return VoiceLeading((v1.bass + v2.bass) % N, (v1.soprano + v2.soprano) % N)


# ──────────────────────────────────────────────────────────────────────
# §2  Demonstrations
# ──────────────────────────────────────────────────────────────────────

def banner(title: str) -> None:
    width = 70
    print()
    print("═" * width)
    print(f"  {title}")
    print("═" * width)


def demo_consonance_set() -> None:
    """Display the consonance and perfect consonance sets."""
    banner("THE CONSONANCE LANDSCAPE")
    print(f"\n  All 12 intervals in Z/12Z, with consonance status:\n")
    for i in range(N):
        status = "  —"
        if i in PERFECT:
            status = "  ★ PERFECT consonance"
        elif i in CONSONANT:
            status = "  ● Imperfect consonance"
        name = INTERVAL_NAMES.get(i, f"Interval {i}")
        print(f"    {i:2d} semitones  ({name:15s}) {status}")
    print(f"\n  Consonant: {sorted(CONSONANT)}  ({len(CONSONANT)} intervals)")
    print(f"  Perfect:   {sorted(PERFECT)}  ({len(PERFECT)} intervals)")
    print(f"  Imperfect: {sorted(IMPERFECT)}  ({len(IMPERFECT)} intervals)")


def demo_strong_connectivity() -> None:
    """Theorem 3.1: Between any two consonant intervals, a permitted VL exists."""
    banner("THEOREM 1: STRONG CONNECTIVITY")
    print("\n  For every pair (i, j) of consonant intervals,")
    print("  at least one permitted voice leading exists.\n")

    all_connected = True
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            pvls = permitted_vls(i, j)
            ok = len(pvls) > 0
            marker = "✓" if ok else "✗"
            # Show canonical VL
            canonical = VoiceLeading(0, (j - i) % N)
            is_canon_ok = is_permitted(i, j, canonical)
            print(f"    {marker}  {INTERVAL_NAMES[i]:15s} → {INTERVAL_NAMES[j]:15s}"
                  f"  |  {len(pvls):2d} permitted VLs"
                  f"  |  canonical (0,{(j-i)%N:2d}): {'✓' if is_canon_ok else '✗'}")
            if not ok:
                all_connected = False

    print(f"\n  Strong connectivity verified: {all_connected}")


def demo_non_composability() -> None:
    """Theorem 4.1: Permitted VLs are not closed under composition."""
    banner("THEOREM 2: NON-COMPOSABILITY")
    print("\n  Finding two permitted voice leadings whose composition is forbidden...\n")

    found = 0
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for k in sorted(CONSONANT):
                for v1 in permitted_vls(i, j):
                    for v2 in permitted_vls(j, k):
                        v_comp = compose(v1, v2)
                        if not is_permitted(i, k, v_comp):
                            found += 1
                            if found <= 3:
                                print(f"    Example {found}:")
                                print(f"      {INTERVAL_NAMES[i]} —[{v1}]→ "
                                      f"{INTERVAL_NAMES[j]} —[{v2}]→ {INTERVAL_NAMES[k]}")
                                print(f"      Composed: {v_comp}")
                                reason = ""
                                if k in PERFECT and is_parallel(v_comp):
                                    reason = " (parallel motion into perfect consonance!)"
                                elif target_interval(i, v_comp) != k:
                                    reason = " (target mismatch)"
                                print(f"      Permitted? NO{reason}\n")

    print(f"  Total non-composable triples found: {found}")
    print(f"  Conclusion: Permitted voice leadings do NOT form a subcategory.")


def demo_self_loop_bottleneck() -> None:
    """Theorems 5.1–5.2: Self-loop counts at perfect vs imperfect consonances."""
    banner("THEOREM 3: PERFECT CONSONANCE BOTTLENECK")
    print("\n  Self-loops (voice leadings from an interval to itself):\n")

    for i in sorted(CONSONANT):
        loops = permitted_vls(i, i)
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"    {INTERVAL_NAMES[i]:15s} ({kind:9s}):  {len(loops):2d} self-loops")
        if i in PERFECT:
            print(f"      └─ Only the identity (0,0) survives: {loops}")

    print(f"\n  Perfect consonances:   1 self-loop  (identity only)")
    print(f"  Imperfect consonances: 12 self-loops (all parallel motions allowed)")
    print(f"  Bottleneck ratio:      1:12")


def demo_voice_swap_asymmetry() -> None:
    """Theorem 6.1: The involution i ↦ -i does not preserve consonance."""
    banner("THEOREM 4: VOICE-SWAP ASYMMETRY")
    print("\n  The involution σ(i) = -i mod 12 (swapping bass and soprano):\n")

    broken = False
    for i in sorted(CONSONANT):
        neg_i = (-i) % N
        preserved = neg_i in CONSONANT
        marker = "✓" if preserved else "✗ BROKEN!"
        name_neg = INTERVAL_NAMES.get(neg_i, f"Interval {neg_i}")
        print(f"    σ({i:2d}) = {neg_i:2d}  "
              f"({INTERVAL_NAMES[i]:15s} → {name_neg:15s})  {marker}")
        if not preserved:
            broken = True

    print(f"\n  Consonance preserved under voice swap? {'NO' if broken else 'YES'}")
    print(f"  The perfect fifth (7) maps to the perfect fourth (5),")
    print(f"  which is DISSONANT in first-species counterpoint.")
    print(f"  This formalizes the privileged role of the bass voice.")


def demo_hom_set_cardinalities() -> None:
    """Theorems 7.1–7.2: Total incoming voice leadings to each consonance."""
    banner("THEOREM 5: HOM-SET CARDINALITIES")
    print("\n  Total incoming permitted voice leadings from all consonant sources:\n")

    for j in sorted(CONSONANT):
        total = sum(len(permitted_vls(i, j)) for i in sorted(CONSONANT))
        kind = "PERFECT" if j in PERFECT else "imperfect"
        print(f"    → {INTERVAL_NAMES[j]:15s} ({kind:9s}):  {total:3d} incoming VLs")

    perf_total = sum(
        len(permitted_vls(i, j)) for j in PERFECT for i in CONSONANT
    ) // len(PERFECT)
    imp_total = sum(
        len(permitted_vls(i, j)) for j in IMPERFECT for i in CONSONANT
    ) // len(IMPERFECT)

    print(f"\n  Average incoming VLs to perfect consonance:   {perf_total}")
    print(f"  Average incoming VLs to imperfect consonance: {imp_total}")
    print(f"  Ratio: {perf_total}/{imp_total} = {perf_total/imp_total:.3f}")
    print(f"  Reduction: {100*(1 - perf_total/imp_total):.1f}%")


def demo_full_adjacency_matrix() -> None:
    """Display the full adjacency matrix of the counterpoint quiver."""
    banner("FULL ADJACENCY MATRIX OF THE COUNTERPOINT QUIVER")
    print("\n  Entry (i,j) = number of permitted voice leadings from i to j.\n")

    cons = sorted(CONSONANT)
    header = "         " + "".join(f"{INTERVAL_NAMES[j][:5]:>6s}" for j in cons)
    print(f"  {header}")
    print(f"  {'':>8s} " + "─" * (6 * len(cons)))

    for i in cons:
        row = f"  {INTERVAL_NAMES[i][:8]:>8s}│"
        for j in cons:
            count = len(permitted_vls(i, j))
            row += f"{count:6d}"
        row_total = sum(len(permitted_vls(i, j)) for j in cons)
        row += f"  │ Σ={row_total}"
        print(row)

    print(f"  {'':>8s} " + "─" * (6 * len(cons)))
    col_totals = "  {'Σ':>8s}│"
    footer = f"  {'Σ':>8s}│"
    for j in cons:
        ct = sum(len(permitted_vls(i, j)) for i in cons)
        footer += f"{ct:6d}"
    grand_total = sum(len(permitted_vls(i, j)) for i in cons for j in cons)
    footer += f"  │ Σ={grand_total}"
    print(footer)

    print(f"\n  Grand total of permitted voice leadings: {grand_total}")
    print(f"  Out of {len(cons)**2 * N} possible (6×6×12): {len(cons)**2 * N}")
    print(f"  Fraction permitted: {grand_total}/{len(cons)**2 * N}"
          f" = {grand_total/(len(cons)**2 * N):.3f}")


def demo_motion_types() -> None:
    """Classify permitted voice leadings by motion type."""
    banner("MOTION TYPE ANALYSIS")
    print("\n  Classifying all permitted voice leadings by motion type:\n")

    oblique = 0    # one voice stationary
    contrary = 0   # voices move in opposite directions
    similar = 0    # voices move in same direction (but not parallel)
    parallel = 0   # both move by same amount
    static = 0     # neither moves

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for vl in permitted_vls(i, j):
                b, s = vl.bass % N, vl.soprano % N
                if b == 0 and s == 0:
                    static += 1
                elif b == 0 or s == 0:
                    oblique += 1
                elif b == s:
                    parallel += 1
                else:
                    # In Z/12Z, "contrary" and "similar" are less well-defined
                    # We count non-parallel, non-oblique as "mixed"
                    if (b <= 6 and s > 6) or (b > 6 and s <= 6):
                        contrary += 1
                    else:
                        similar += 1

    total = static + oblique + contrary + similar + parallel
    print(f"    Static (0,0):     {static:4d}  ({100*static/total:.1f}%)")
    print(f"    Oblique:          {oblique:4d}  ({100*oblique/total:.1f}%)")
    print(f"    Contrary:         {contrary:4d}  ({100*contrary/total:.1f}%)")
    print(f"    Similar:          {similar:4d}  ({100*similar/total:.1f}%)")
    print(f"    Parallel:         {parallel:4d}  ({100*parallel/total:.1f}%)")
    print(f"    ─────────────────────────")
    print(f"    Total:            {total:4d}")


# ──────────────────────────────────────────────────────────────────────
# §3  Main
# ──────────────────────────────────────────────────────────────────────

def main() -> None:
    print("\n" + "█" * 70)
    print("█  SONIC MATHEMATICS: COUNTERPOINT AS CATEGORY THEORY")
    print("█  Numerical Demonstrations of the Five Main Theorems")
    print("█" * 70)

    demo_consonance_set()
    demo_strong_connectivity()
    demo_non_composability()
    demo_self_loop_bottleneck()
    demo_voice_swap_asymmetry()
    demo_hom_set_cardinalities()
    demo_full_adjacency_matrix()
    demo_motion_types()

    banner("SUMMARY")
    print("""
  ┌─────────────────────────────────────────────────────────────────┐
  │  Theorem 1 (Connectivity):    ✓ Quiver is strongly connected   │
  │  Theorem 2 (Non-composability): ✓ No subcategory structure     │
  │  Theorem 3 (Bottleneck):      ✓ 1 vs 12 self-loops (1:12)     │
  │  Theorem 4 (Voice swap):      ✓ Consonance not preserved       │
  │  Theorem 5 (Hom-sets):        ✓ 61 vs 72 incoming VLs         │
  └─────────────────────────────────────────────────────────────────┘
    """)


if __name__ == "__main__":
    main()
