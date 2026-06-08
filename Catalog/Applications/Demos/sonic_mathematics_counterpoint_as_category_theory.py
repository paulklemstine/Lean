#!/usr/bin/env python3
"""
Sonic Mathematics: Numerical Demonstrations of Counterpoint Category Theory

This script demonstrates the key results from the formalization of first-species
counterpoint as a constrained quiver over Z/12Z:

1. Enumeration of the counterpoint quiver (all permitted voice leadings)
2. Strong connectivity verification
3. Self-loop counting (1 for perfect vs. 12 for imperfect consonances)
4. Hom-set cardinalities (61 vs. 72 incoming edges)
5. Non-composability counterexample
6. Voice-swap asymmetry demonstration
7. Voice-leading cost seminorm verification
8. Lattice-cost identity verification

All computations use modular arithmetic over Z/12Z.
"""

from __future__ import annotations
from typing import NamedTuple
from itertools import product
import math


# ─── Musical Constants ────────────────────────────────────────────────

CONSONANT: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT: set[int] = {0, 7}
IMPERFECT: set[int] = CONSONANT - PERFECT  # {3, 4, 8, 9}
N: int = 12

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
    """Compute the target interval given source and voice leading."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass == vl.soprano and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading from source to target is permitted."""
    return (
        source % N in CONSONANT
        and target % N in CONSONANT
        and target_interval(source, vl) == target % N
        and not (target % N in PERFECT and is_parallel(vl))
    )


# ─── Demo 1: Enumerate the Counterpoint Quiver ────────────────────────

def demo_enumerate_quiver() -> dict[tuple[int, int], list[VoiceLeading]]:
    """Enumerate all edges of the counterpoint quiver."""
    print("=" * 70)
    print("DEMO 1: Enumerating the Counterpoint Quiver Q(C, P)")
    print("=" * 70)

    quiver: dict[tuple[int, int], list[VoiceLeading]] = {}
    total_edges = 0

    for src in sorted(CONSONANT):
        for tgt in sorted(CONSONANT):
            permitted: list[VoiceLeading] = []
            for b in range(N):
                s = (tgt - src + b) % N  # s determined by constraint
                vl = VoiceLeading(b, s)
                if is_permitted(src, tgt, vl):
                    permitted.append(vl)
            quiver[(src, tgt)] = permitted
            total_edges += len(permitted)

    print(f"\nVertices (consonant intervals): {sorted(CONSONANT)}")
    print(f"  Perfect: {sorted(PERFECT)}")
    print(f"  Imperfect: {sorted(IMPERFECT)}")
    print(f"\nTotal permitted voice leadings (edges): {total_edges}")

    print("\nHom-set sizes |Hom(i, j)|:")
    header = "Src\\Tgt |" + "|".join(f" {t:>2} " for t in sorted(CONSONANT)) + "|"
    print(header)
    print("-" * len(header))
    for src in sorted(CONSONANT):
        row = f"   {src:>2}   |"
        for tgt in sorted(CONSONANT):
            count = len(quiver[(src, tgt)])
            row += f" {count:>2} |"
        marker = " (P)" if src in PERFECT else " (I)"
        print(row + marker)

    return quiver


# ─── Demo 2: Strong Connectivity ──────────────────────────────────────

def demo_strong_connectivity() -> None:
    """Verify strong connectivity via canonical voice leadings."""
    print("\n" + "=" * 70)
    print("DEMO 2: Strong Connectivity — Canonical Voice Leadings")
    print("=" * 70)

    print("\nFor each (i, j) pair, the canonical VL (0, j-i) is always permitted:")
    print()

    all_connected = True
    for src in sorted(CONSONANT):
        for tgt in sorted(CONSONANT):
            s = (tgt - src) % N
            vl = VoiceLeading(0, s)
            t = target_interval(src, vl)
            ok = is_permitted(src, tgt, vl)
            par = is_parallel(vl)
            status = "✓" if ok else "✗"
            if not ok:
                all_connected = False
            print(
                f"  {INTERVAL_NAMES[src]:>14} → {INTERVAL_NAMES[tgt]:<14}  "
                f"VL=(0, {s:>2})  target={t:>2}  parallel={par!s:<5}  {status}"
            )

    print(f"\nStrong connectivity verified: {all_connected}")


# ─── Demo 3: Self-Loop Counting (The Bottleneck) ──────────────────────

def demo_self_loops() -> None:
    """Count self-loops at each consonant interval."""
    print("\n" + "=" * 70)
    print("DEMO 3: Self-Loop Counting — The Perfect Consonance Bottleneck")
    print("=" * 70)

    print("\nSelf-loops at each consonant interval:")
    for i in sorted(CONSONANT):
        loops: list[VoiceLeading] = []
        for b in range(N):
            vl = VoiceLeading(b, b)  # s = b for self-loop
            if is_permitted(i, i, vl):
                loops.append(vl)
        kind = "PERFECT" if i in PERFECT else "IMPERFECT"
        print(f"  {INTERVAL_NAMES[i]:>14} ({kind:>9}): {len(loops):>2} self-loops")
        if len(loops) <= 3:
            for vl in loops:
                print(f"    VL=({vl.bass}, {vl.soprano})")

    print("\n  → Perfect consonances: 1 self-loop (identity only)")
    print("  → Imperfect consonances: 12 self-loops (all motions)")
    print("  → Ratio: 12:1")


# ─── Demo 4: Hom-Set Cardinalities (61 vs 72) ─────────────────────────

def demo_hom_set_cardinalities(quiver: dict[tuple[int, int], list[VoiceLeading]]) -> None:
    """Compute total incoming edges for perfect vs imperfect consonances."""
    print("\n" + "=" * 70)
    print("DEMO 4: Incoming Edge Counts — 61 vs. 72")
    print("=" * 70)

    for tgt in sorted(CONSONANT):
        total_incoming = sum(len(quiver[(src, tgt)]) for src in sorted(CONSONANT))
        kind = "PERFECT" if tgt in PERFECT else "IMPERFECT"
        print(f"  {INTERVAL_NAMES[tgt]:>14} ({kind:>9}): {total_incoming} incoming edges")

    perfect_incoming = [
        sum(len(quiver[(src, tgt)]) for src in sorted(CONSONANT))
        for tgt in sorted(PERFECT)
    ]
    imperfect_incoming = [
        sum(len(quiver[(src, tgt)]) for src in sorted(CONSONANT))
        for tgt in sorted(IMPERFECT)
    ]

    print(f"\n  Perfect consonances:   {perfect_incoming[0]} incoming each")
    print(f"  Imperfect consonances: {imperfect_incoming[0]} incoming each")
    print(f"  Reduction: {(1 - perfect_incoming[0] / imperfect_incoming[0]) * 100:.1f}%")


# ─── Demo 5: Non-Composability ────────────────────────────────────────

def demo_non_composability() -> None:
    """Demonstrate that composition of permitted VLs can be forbidden."""
    print("\n" + "=" * 70)
    print("DEMO 5: Non-Composability — Counterpoint Is Not a Category")
    print("=" * 70)

    print("\nSearching for composition failures...")
    failures: list[tuple[int, int, int, VoiceLeading, VoiceLeading, VoiceLeading]] = []

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for k in sorted(CONSONANT):
                for b1 in range(N):
                    s1 = (j - i + b1) % N
                    vl1 = VoiceLeading(b1, s1)
                    if not is_permitted(i, j, vl1):
                        continue
                    for b2 in range(N):
                        s2 = (k - j + b2) % N
                        vl2 = VoiceLeading(b2, s2)
                        if not is_permitted(j, k, vl2):
                            continue
                        # Compose
                        comp = VoiceLeading((b1 + b2) % N, (s1 + s2) % N)
                        if not is_permitted(i, k, comp):
                            failures.append((i, j, k, vl1, vl2, comp))

    print(f"Found {len(failures)} composition failures!\n")

    # Show first 5 examples
    for idx, (i, j, k, vl1, vl2, comp) in enumerate(failures[:5]):
        print(f"  Example {idx + 1}:")
        print(f"    {INTERVAL_NAMES[i]} →({vl1.bass},{vl1.soprano})→ {INTERVAL_NAMES[j]}"
              f"  [permitted ✓]")
        print(f"    {INTERVAL_NAMES[j]} →({vl2.bass},{vl2.soprano})→ {INTERVAL_NAMES[k]}"
              f"  [permitted ✓]")
        comp_tgt = target_interval(i, comp)
        par = is_parallel(comp)
        print(f"    Composite: ({comp.bass},{comp.soprano}) "
              f"target={comp_tgt} parallel={par} "
              f"{'target ∈ P' if comp_tgt in PERFECT else 'target ∉ P'}"
              f"  [FORBIDDEN ✗]")
        print()


# ─── Demo 6: Voice-Swap Asymmetry ─────────────────────────────────────

def demo_voice_swap() -> None:
    """Show that negation does not preserve the consonant set."""
    print("=" * 70)
    print("DEMO 6: Voice-Swap Asymmetry — Why the Bass Is Special")
    print("=" * 70)

    print("\nThe involution σ(i) = -i mod 12 on consonant intervals:")
    print()

    all_preserved = True
    for i in sorted(CONSONANT):
        neg_i = (-i) % N
        preserved = neg_i in CONSONANT
        status = "✓ preserved" if preserved else "✗ BROKEN"
        if not preserved:
            all_preserved = False
        print(
            f"  σ({i:>2}) = {neg_i:>2}   "
            f"{INTERVAL_NAMES[i]:>14} → {INTERVAL_NAMES[neg_i]:<14}  {status}"
        )

    print(f"\n  Consonant set preserved under negation: {all_preserved}")
    print(f"  Witness: σ(7) = 5, perfect fifth → perfect fourth (dissonant)")
    print(f"  This asymmetry makes the bass voice structurally privileged.")


# ─── Demo 7: Voice-Leading Cost Seminorm ───────────────────────────────

def demo_cost_seminorm() -> None:
    """Verify seminorm properties of voice-leading cost."""
    print("\n" + "=" * 70)
    print("DEMO 7: Voice-Leading Cost as a Seminorm")
    print("=" * 70)

    def cost(m: list[int]) -> int:
        return sum(abs(x) for x in m)

    # Test nonnegativity
    print("\n  Nonnegativity: cost(m) ≥ 0")
    test_motions = [[3, -2], [0, 0], [-1, 5, -3], [7, -7, 0, 2]]
    for m in test_motions:
        c = cost(m)
        print(f"    cost({m}) = {c} ≥ 0  ✓")

    # Test triangle inequality
    print("\n  Triangle inequality: cost(m₁ + m₂) ≤ cost(m₁) + cost(m₂)")
    pairs = [
        ([3, -2], [1, 4]),
        ([-1, 5], [2, -3]),
        ([0, 0, 7], [-1, 2, -4]),
    ]
    for m1, m2 in pairs:
        m_sum = [a + b for a, b in zip(m1, m2)]
        c_sum = cost(m_sum)
        c1, c2 = cost(m1), cost(m2)
        status = "✓" if c_sum <= c1 + c2 else "✗"
        print(f"    cost({m_sum}) = {c_sum} ≤ {c1} + {c2} = {c1 + c2}  {status}")

    # Test absolute homogeneity
    print("\n  Absolute homogeneity: cost(c·m) = |c|·cost(m)")
    for m, c in [([3, -2], 2), ([-1, 5], -3), ([0, 7], 0)]:
        cm = [c * x for x in m]
        cost_cm = cost(cm)
        expected = abs(c) * cost(m)
        status = "✓" if cost_cm == expected else "✗"
        print(f"    cost({c}·{m}) = cost({cm}) = {cost_cm} = |{c}|·{cost(m)} = {expected}  {status}")

    # Test lattice-cost identity
    print("\n  Lattice-cost identity: cost(m₁ ⊓ m₂) + cost(m₁ ⊔ m₂) = cost(m₁) + cost(m₂)")
    for m1, m2 in pairs:
        meet = [min(a, b) for a, b in zip(m1, m2)]
        join = [max(a, b) for a, b in zip(m1, m2)]
        lhs = cost(meet) + cost(join)
        rhs = cost(m1) + cost(m2)
        status = "✓" if lhs == rhs else "✗"
        print(f"    m₁={m1}, m₂={m2}")
        print(f"    ⊓={meet}, ⊔={join}")
        print(f"    cost(⊓)+cost(⊔) = {cost(meet)}+{cost(join)} = {lhs}"
              f"  =  cost(m₁)+cost(m₂) = {cost(m1)}+{cost(m2)} = {rhs}  {status}")


# ─── Demo 8: Microtonal Generalization ─────────────────────────────────

def demo_microtonal() -> None:
    """Demonstrate the framework for 19-TET and 31-TET."""
    print("\n" + "=" * 70)
    print("DEMO 8: Microtonal Generalization — Beyond 12-TET")
    print("=" * 70)

    systems: list[tuple[str, int, set[int], set[int]]] = [
        ("12-TET (standard)", 12, {0, 3, 4, 7, 8, 9}, {0, 7}),
        ("19-TET", 19, {0, 5, 6, 11, 13, 14}, {0, 11}),
        ("24-TET (quarter-tone)", 24, {0, 6, 7, 8, 14, 16, 17, 18}, {0, 14}),
    ]

    for name, n, cons, perf in systems:
        imp = cons - perf
        total_edges = 0
        perfect_incoming: dict[int, int] = {p: 0 for p in perf}
        imperfect_incoming: dict[int, int] = {i: 0 for i in imp}

        for src in cons:
            for tgt in cons:
                count = 0
                for b in range(n):
                    s = (tgt - src + b) % n
                    par = (b == s and b % n != 0)
                    forbidden = tgt in perf and par
                    if not forbidden:
                        count += 1
                total_edges += count
                if tgt in perf:
                    perfect_incoming[tgt] += count
                else:
                    imperfect_incoming[tgt] += count

        # Self-loops
        perf_self = 1  # Always just identity for perfect
        imp_self = n    # All n motions for imperfect

        p_inc = list(perfect_incoming.values())[0] if perfect_incoming else 0
        i_inc = list(imperfect_incoming.values())[0] if imperfect_incoming else 0

        print(f"\n  {name} (n={n}):")
        print(f"    Consonant: {sorted(cons)}  ({len(cons)} intervals)")
        print(f"    Perfect:   {sorted(perf)}  ({len(perf)} intervals)")
        print(f"    Imperfect: {sorted(imp)}  ({len(imp)} intervals)")
        print(f"    Total edges: {total_edges}")
        print(f"    Self-loops:  perfect={perf_self}, imperfect={imp_self} (ratio {imp_self}:1)")
        print(f"    Incoming:    perfect={p_inc}, imperfect={i_inc}"
              f"  (reduction: {(1 - p_inc / i_inc) * 100:.1f}%)" if i_inc > 0 else "")


# ─── Main ──────────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   SONIC MATHEMATICS: Counterpoint as Category Theory               ║")
    print("║   Numerical Demonstrations                                         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    quiver = demo_enumerate_quiver()
    demo_strong_connectivity()
    demo_self_loops()
    demo_hom_set_cardinalities(quiver)
    demo_non_composability()
    demo_voice_swap()
    demo_cost_seminorm()
    demo_microtonal()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
