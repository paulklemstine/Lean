#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory
===================================================

Numerical demonstrations of the Counterpoint Quiver over Z/12Z.

This script computes and verifies all major results from the formalization:
1. Strong connectivity of the quiver
2. Non-composability of permitted voice leadings
3. The 12:1 self-loop bottleneck (perfect vs imperfect consonances)
4. Voice-swap asymmetry
5. Complete hom-set enumeration (61 vs 72)
"""

from __future__ import annotations
from dataclasses import dataclass
from itertools import product
from typing import NamedTuple


# ── Interval names ──────────────────────────────────────────────────

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


# ── Core definitions (matching the Lean formalization) ──────────────

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}
N: int = 12


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in Z/12Z."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval: source + soprano - bass (mod 12)."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass == vl.soprano and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading is permitted in the standard 12-TET system."""
    return (
        source % N in CONSONANT
        and target % N in CONSONANT
        and target_interval(source, vl) == target % N
        and not (target % N in PERFECT and is_parallel(vl))
    )


# ── Enumeration ─────────────────────────────────────────────────────

def all_voice_leadings() -> list[VoiceLeading]:
    """All 144 voice leadings in (Z/12Z)^2."""
    return [VoiceLeading(b, s) for b, s in product(range(N), repeat=2)]


def permitted_between(source: int, target: int) -> list[VoiceLeading]:
    """All permitted voice leadings from source to target."""
    return [vl for vl in all_voice_leadings() if is_permitted(source, target, vl)]


def compose(vl1: VoiceLeading, vl2: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings: (b1+b2, s1+s2) mod 12."""
    return VoiceLeading((vl1.bass + vl2.bass) % N, (vl1.soprano + vl2.soprano) % N)


# ── Demonstrations ──────────────────────────────────────────────────

def demo_consonance_set() -> None:
    """Display the consonant intervals and their classification."""
    print("=" * 65)
    print("THE CONSONANT INTERVALS OF FIRST-SPECIES COUNTERPOINT")
    print("=" * 65)
    print(f"\n{'Semitones':<12} {'Name':<18} {'Type':<12}")
    print("-" * 42)
    for i in sorted(CONSONANT):
        kind = "PERFECT" if i in PERFECT else "Imperfect"
        print(f"{i:<12} {INTERVAL_NAMES[i]:<18} {kind:<12}")
    print(f"\nTotal consonances: {len(CONSONANT)}")
    print(f"  Perfect:   {len(PERFECT)} ({sorted(PERFECT)})")
    print(f"  Imperfect: {len(IMPERFECT)} ({sorted(IMPERFECT)})")


def demo_strong_connectivity() -> None:
    """Verify Theorem 3.1: strong connectivity."""
    print("\n" + "=" * 65)
    print("THEOREM 3.1: STRONG CONNECTIVITY")
    print("=" * 65)
    print("\nFor every pair (i, j) of consonant intervals,")
    print("at least one permitted voice leading exists.\n")

    all_connected = True
    consonant_list = sorted(CONSONANT)

    for i in consonant_list:
        for j in consonant_list:
            vls = permitted_between(i, j)
            count = len(vls)
            marker = "✓" if count > 0 else "✗"
            if count == 0:
                all_connected = False

    # Print connectivity matrix
    header = "     " + "".join(f"{j:>5}" for j in consonant_list)
    print(f"Hom-set sizes |Hom(i, j)|:")
    print(header)
    for i in consonant_list:
        row = f"  {i:>2} "
        for j in consonant_list:
            count = len(permitted_between(i, j))
            row += f"{count:>5}"
        print(row)

    print(f"\nAll hom-sets nonempty: {all_connected} ✓")
    print("The Counterpoint Quiver is strongly connected.")


def demo_non_composability() -> None:
    """Verify Theorem 3.2: non-composability."""
    print("\n" + "=" * 65)
    print("THEOREM 3.2: NON-COMPOSABILITY")
    print("=" * 65)
    print("\nSearching for a counterexample to composition closure...")

    found = False
    consonant_list = sorted(CONSONANT)

    for i in consonant_list:
        if found:
            break
        for j in consonant_list:
            if found:
                break
            for k in consonant_list:
                if found:
                    break
                for vl1 in permitted_between(i, j):
                    if found:
                        break
                    for vl2 in permitted_between(j, k):
                        comp = compose(vl1, vl2)
                        if not is_permitted(i, k, comp):
                            print(f"\n  Counterexample found!")
                            print(f"  Path: {INTERVAL_NAMES[i]} → "
                                  f"{INTERVAL_NAMES[j]} → {INTERVAL_NAMES[k]}")
                            print(f"  v₁ = (bass={vl1.bass}, soprano={vl1.soprano})"
                                  f"  [permitted from {i} to {j}]")
                            print(f"  v₂ = (bass={vl2.bass}, soprano={vl2.soprano})"
                                  f"  [permitted from {j} to {k}]")
                            print(f"  v₁∘v₂ = (bass={comp.bass}, soprano={comp.soprano})"
                                  f"  [NOT permitted from {i} to {k}]")
                            reason = ""
                            if k in PERFECT and is_parallel(comp):
                                reason = (f"  Reason: parallel motion "
                                          f"(bass=soprano={comp.bass}) into "
                                          f"perfect consonance {INTERVAL_NAMES[k]}")
                            elif target_interval(i, comp) != k:
                                reason = (f"  Reason: composed VL maps {i} to "
                                          f"{target_interval(i, comp)}, not {k}")
                            print(reason)
                            found = True
                            break

    if found:
        print("\n  ∴ Permitted voice leadings do NOT form a subcategory. ✓")
    else:
        print("  No counterexample found (unexpected!).")


def demo_self_loop_bottleneck() -> None:
    """Verify Theorems 3.3–3.4: the perfect consonance bottleneck."""
    print("\n" + "=" * 65)
    print("THEOREMS 3.3–3.4: THE SELF-LOOP BOTTLENECK")
    print("=" * 65)
    print()

    for i in sorted(CONSONANT):
        self_loops = permitted_between(i, i)
        kind = "PERFECT" if i in PERFECT else "Imperfect"
        print(f"  {INTERVAL_NAMES[i]:>18} ({i:>2}): "
              f"{len(self_loops):>2} self-loops  [{kind}]")

    print()
    perfect_loops = {i: len(permitted_between(i, i)) for i in PERFECT}
    imperfect_loops = {i: len(permitted_between(i, i)) for i in IMPERFECT}

    for p, count in perfect_loops.items():
        assert count == 1, f"Expected 1 self-loop at perfect {p}, got {count}"
        print(f"  Perfect consonance {p} ({INTERVAL_NAMES[p]}): "
              f"exactly 1 self-loop (identity) ✓")

    for q, count in imperfect_loops.items():
        assert count == 12, f"Expected 12 self-loops at imperfect {q}, got {count}"

    print(f"  All imperfect consonances: exactly 12 self-loops each ✓")
    print(f"\n  Bottleneck ratio: 12:1 (imperfect:perfect)")


def demo_voice_swap() -> None:
    """Verify Theorem 3.6: voice-swap breaks consonance."""
    print("\n" + "=" * 65)
    print("THEOREM 3.6: VOICE-SWAP ASYMMETRY")
    print("=" * 65)
    print("\nThe involution i ↦ −i (mod 12) does NOT preserve consonance:\n")

    print(f"  {'i':>4}  {'Name':>18}  {'−i mod 12':>10}  {'Name':>18}  {'Consonant?':>11}")
    print("  " + "-" * 68)

    breaks = []
    for i in sorted(CONSONANT):
        neg_i = (-i) % N
        is_cons = neg_i in CONSONANT
        marker = "✓" if is_cons else "✗ BREAKS"
        print(f"  {i:>4}  {INTERVAL_NAMES[i]:>18}  {neg_i:>10}  "
              f"{INTERVAL_NAMES[neg_i]:>18}  {marker:>11}")
        if not is_cons:
            breaks.append((i, neg_i))

    print(f"\n  Voice exchange breaks consonance at: ", end="")
    print(", ".join(f"{INTERVAL_NAMES[i]} → {INTERVAL_NAMES[j]}" for i, j in breaks))
    print("  ∴ The bass voice has a privileged, asymmetric role. ✓")


def demo_hom_set_totals() -> None:
    """Verify Theorem 3.5: total incoming voice leadings."""
    print("\n" + "=" * 65)
    print("THEOREM 3.5: HOM-SET ENUMERATION")
    print("=" * 65)
    print("\nTotal incoming permitted voice leadings per target:\n")

    consonant_list = sorted(CONSONANT)

    for j in consonant_list:
        total = sum(len(permitted_between(i, j)) for i in consonant_list)
        kind = "PERFECT" if j in PERFECT else "Imperfect"
        print(f"  Target {j:>2} ({INTERVAL_NAMES[j]:>18}): "
              f"{total:>3} incoming VLs  [{kind}]")

    # Verify the exact numbers
    for p in sorted(PERFECT):
        total = sum(len(permitted_between(i, p)) for i in consonant_list)
        assert total == 61, f"Expected 61 for perfect {p}, got {total}"
    for q in sorted(IMPERFECT):
        total = sum(len(permitted_between(i, q)) for i in consonant_list)
        assert total == 72, f"Expected 72 for imperfect {q}, got {total}"

    print(f"\n  Perfect targets:   61 incoming VLs each ✓")
    print(f"  Imperfect targets: 72 incoming VLs each ✓")
    print(f"  Reduction: {(72-61)/72*100:.1f}% fewer paths into perfect consonances")
    print(f"\n  Total edges in the Counterpoint Quiver: "
          f"{sum(len(permitted_between(i,j)) for i in consonant_list for j in consonant_list)}")


def demo_full_quiver_summary() -> None:
    """Print a summary of the entire quiver structure."""
    print("\n" + "=" * 65)
    print("QUIVER SUMMARY")
    print("=" * 65)

    consonant_list = sorted(CONSONANT)
    total_edges = 0
    for i in consonant_list:
        for j in consonant_list:
            total_edges += len(permitted_between(i, j))

    print(f"\n  Vertices:  {len(CONSONANT)} consonant intervals")
    print(f"  Edges:     {total_edges} permitted voice leadings")
    print(f"  Max edges: {len(CONSONANT)**2 * N} "
          f"(if all {N} VLs were permitted for each pair)")
    print(f"  Density:   {total_edges / (len(CONSONANT)**2 * N) * 100:.1f}%")
    print(f"\n  Self-loops at perfect consonances: "
          f"{sum(len(permitted_between(p,p)) for p in PERFECT)}")
    print(f"  Self-loops at imperfect consonances: "
          f"{sum(len(permitted_between(q,q)) for q in IMPERFECT)}")


# ── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔" + "═" * 63 + "╗")
    print("║  SONIC MATHEMATICS: Counterpoint as Category Theory           ║")
    print("║  Numerical Demonstrations                                     ║")
    print("╚" + "═" * 63 + "╝\n")

    demo_consonance_set()
    demo_strong_connectivity()
    demo_self_loop_bottleneck()
    demo_non_composability()
    demo_voice_swap()
    demo_hom_set_totals()
    demo_full_quiver_summary()

    print("\n" + "=" * 65)
    print("All assertions passed. Results match the formal verification. ✓")
    print("=" * 65)
