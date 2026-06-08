#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

Demonstrates the five main theorems from the formal counterpoint quiver framework:
1. Strong connectivity of the counterpoint quiver
2. Non-composability of permitted voice leadings
3. Perfect consonance bottleneck (1 vs 12 self-loops)
4. Voice-swap asymmetry (consonance not preserved under negation)
5. Hom-set cardinality computation (61 vs 72)
"""

from __future__ import annotations
from typing import NamedTuple


# ─── Core Definitions ───────────────────────────────────────────────────────

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
N: int = 12  # chromatic pitch classes


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in Z/12Z."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval: source + soprano - bass (mod 12)."""
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


def enumerate_permitted(source: int, target: int) -> list[VoiceLeading]:
    """Enumerate all permitted voice leadings from source to target."""
    result: list[VoiceLeading] = []
    for b in range(N):
        for s in range(N):
            vl = VoiceLeading(b, s)
            if is_permitted(source, target, vl):
                result.append(vl)
    return result


def canonical_vl(source: int, target: int) -> VoiceLeading:
    """The canonical voice leading: bass stays, soprano moves."""
    return VoiceLeading(0, (target - source) % N)


# ─── Demonstration 1: Strong Connectivity ───────────────────────────────────

def demo_strong_connectivity() -> None:
    """Theorem: Between any two consonant intervals, a permitted voice leading exists."""
    print("=" * 72)
    print("THEOREM 1: Strong Connectivity of the Counterpoint Quiver")
    print("=" * 72)
    print()
    print("For every pair (i, j) of consonant intervals, we exhibit a permitted")
    print("voice leading from i to j.")
    print()

    consonant_list = sorted(CONSONANT)
    all_connected = True
    for i in consonant_list:
        for j in consonant_list:
            permitted = enumerate_permitted(i, j)
            if not permitted:
                print(f"  ✗ {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[j]}: NO voice leading found!")
                all_connected = False
            else:
                cvl = canonical_vl(i, j)
                print(f"  ✓ {INTERVAL_NAMES[i]:>15s} → {INTERVAL_NAMES[j]:<15s}  "
                      f"| {len(permitted):2d} permitted | canonical: bass={cvl.bass}, sop={cvl.soprano}")

    print()
    print(f"  Result: {'✓ STRONGLY CONNECTED' if all_connected else '✗ NOT connected'}")
    print(f"  Total edges in quiver: {sum(len(enumerate_permitted(i, j)) for i in consonant_list for j in consonant_list)}")
    print()


# ─── Demonstration 2: Non-Composability ─────────────────────────────────────

def demo_non_composability() -> None:
    """Theorem: Permitted voice leadings do not compose."""
    print("=" * 72)
    print("THEOREM 2: Non-Composability of Permitted Voice Leadings")
    print("=" * 72)
    print()
    print("We search for composable pairs where both steps are permitted but")
    print("the composite is not permitted (from the same source to the final target).")
    print()

    consonant_list = sorted(CONSONANT)
    counterexamples: list[tuple[int, int, int, VoiceLeading, VoiceLeading]] = []

    for i in consonant_list:
        for j in consonant_list:
            for k in consonant_list:
                for vl1 in enumerate_permitted(i, j):
                    for vl2 in enumerate_permitted(j, k):
                        composite = VoiceLeading(
                            (vl1.bass + vl2.bass) % N,
                            (vl1.soprano + vl2.soprano) % N,
                        )
                        if not is_permitted(i, k, composite):
                            counterexamples.append((i, j, k, vl1, vl2))

    print(f"  Found {len(counterexamples)} counterexamples to composability!")
    print()
    # Show first 5
    for idx, (i, j, k, vl1, vl2) in enumerate(counterexamples[:5]):
        comp = VoiceLeading((vl1.bass + vl2.bass) % N, (vl1.soprano + vl2.soprano) % N)
        print(f"  Example {idx+1}:")
        print(f"    Step 1: {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[j]}  "
              f"via (bass={vl1.bass}, sop={vl1.soprano})  ✓ permitted")
        print(f"    Step 2: {INTERVAL_NAMES[j]} → {INTERVAL_NAMES[k]}  "
              f"via (bass={vl2.bass}, sop={vl2.soprano})  ✓ permitted")
        tgt = target_interval(i, comp)
        reason = "parallel into perfect" if (tgt in PERFECT and is_parallel(comp)) else "other"
        print(f"    Composite: (bass={comp.bass}, sop={comp.soprano}) → "
              f"target={INTERVAL_NAMES[tgt]}  ✗ FORBIDDEN ({reason})")
        print()

    print(f"  Result: ✓ Voice leadings do NOT form a category (composition fails)")
    print()


# ─── Demonstration 3: Self-Loop Bottleneck ──────────────────────────────────

def demo_self_loop_bottleneck() -> None:
    """Theorem: Perfect consonances have 1 self-loop; imperfect have 12."""
    print("=" * 72)
    print("THEOREM 3: Perfect Consonance Bottleneck (Self-Loops)")
    print("=" * 72)
    print()

    for i in sorted(CONSONANT):
        loops = enumerate_permitted(i, i)
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"  {INTERVAL_NAMES[i]:>15s} ({kind:>9s}): {len(loops):2d} self-loop(s)")
        if i in PERFECT:
            assert len(loops) == 1, f"Expected 1 self-loop for perfect consonance {i}"
            assert loops[0] == VoiceLeading(0, 0), "The unique self-loop must be the identity"
        else:
            assert len(loops) == N, f"Expected {N} self-loops for imperfect consonance {i}"

    print()
    print("  Result: ✓ Perfect consonances admit exactly 1 self-loop (identity)")
    print(f"  Result: ✓ Imperfect consonances admit exactly {N} self-loops")
    print("  Ratio:  1:{0} — a {1:.0f}x restriction at perfect consonances".format(
        N, N / 1))
    print()


# ─── Demonstration 4: Voice-Swap Asymmetry ──────────────────────────────────

def demo_voice_swap() -> None:
    """Theorem: Negation mod 12 does not preserve the consonance set."""
    print("=" * 72)
    print("THEOREM 4: Voice-Swap Breaks Consonance")
    print("=" * 72)
    print()
    print("  The involution ι(i) = -i mod 12 (swapping bass and soprano roles):")
    print()

    preserved = True
    for i in sorted(CONSONANT):
        neg_i = (-i) % N
        status = "✓ consonant" if neg_i in CONSONANT else "✗ DISSONANT"
        if neg_i not in CONSONANT:
            preserved = False
        print(f"    ι({i:2d}) = {neg_i:2d}  |  "
              f"{INTERVAL_NAMES[i]:>15s}  →  {INTERVAL_NAMES[neg_i]:<15s}  {status}")

    print()
    print(f"  Consonance set preserved? {'Yes' if preserved else 'NO'}")
    print(f"  Key: ι(7) = 5. The perfect fifth maps to the perfect fourth,")
    print(f"  which is DISSONANT in counterpoint — bass voice is privileged.")
    print()


# ─── Demonstration 5: Hom-Set Cardinalities ────────────────────────────────

def demo_hom_set_cardinalities() -> None:
    """Theorem: Perfect consonances receive 61 incoming edges; imperfect receive 72."""
    print("=" * 72)
    print("THEOREM 5: Hom-Set Computation (Incoming Voice Leadings)")
    print("=" * 72)
    print()

    consonant_list = sorted(CONSONANT)

    print("  Target interval        | Incoming from each source           | Total")
    print("  " + "-" * 68)

    for j in consonant_list:
        counts: list[int] = []
        for i in consonant_list:
            counts.append(len(enumerate_permitted(i, j)))
        total = sum(counts)
        kind = "PERFECT" if j in PERFECT else "imperf."
        detail = " + ".join(f"{c:2d}" for c in counts)
        print(f"  {INTERVAL_NAMES[j]:>15s} ({kind}) | {detail} | = {total}")

    print()
    # Verify
    for p in sorted(PERFECT):
        total_p = sum(len(enumerate_permitted(i, p)) for i in consonant_list)
        assert total_p == 61, f"Expected 61 for perfect {p}, got {total_p}"
    for q in sorted(IMPERFECT):
        total_q = sum(len(enumerate_permitted(i, q)) for i in consonant_list)
        assert total_q == 72, f"Expected 72 for imperfect {q}, got {total_q}"

    print("  Result: ✓ Perfect consonances receive exactly 61 incoming voice leadings")
    print("  Result: ✓ Imperfect consonances receive exactly 72 incoming voice leadings")
    print(f"  Reduction: {72 - 61} fewer = {(72 - 61) / 72 * 100:.1f}% constraint at perfect consonances")
    print()


# ─── Full Quiver Adjacency Matrix ──────────────────────────────────────────

def demo_adjacency_matrix() -> None:
    """Print the full hom-set cardinality matrix of the counterpoint quiver."""
    print("=" * 72)
    print("BONUS: Full Hom-Set Cardinality Matrix |Hom(i, j)|")
    print("=" * 72)
    print()

    consonant_list = sorted(CONSONANT)
    short = {0: "P1", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}

    header = "        " + "  ".join(f"{short[j]:>4s}" for j in consonant_list) + "  | Row Σ"
    print(header)
    print("  " + "-" * (len(header) - 2))

    for i in consonant_list:
        row = []
        for j in consonant_list:
            row.append(len(enumerate_permitted(i, j)))
        row_sum = sum(row)
        row_str = "  ".join(f"{c:4d}" for c in row)
        print(f"  {short[i]:>4s}  {row_str}  | {row_sum:4d}")

    total = sum(
        len(enumerate_permitted(i, j))
        for i in consonant_list
        for j in consonant_list
    )
    print("  " + "-" * (len(header) - 2))
    print(f"  Total edges in quiver: {total}")
    print(f"  Total possible (unconstrained): {len(consonant_list)**2 * N} "
          f"({len(consonant_list)}² × {N})")
    print(f"  Edges removed by counterpoint rules: {len(consonant_list)**2 * N - total}")
    print()


# ─── Main ───────────────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   SONIC MATHEMATICS: Counterpoint as Category Theory                ║")
    print("║   Numerical Demonstrations of the Counterpoint Quiver Theorems      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_strong_connectivity()
    demo_non_composability()
    demo_self_loop_bottleneck()
    demo_voice_swap()
    demo_hom_set_cardinalities()
    demo_adjacency_matrix()

    print("All assertions passed. ✓")
    print()


if __name__ == "__main__":
    main()
