#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

Self-contained Python script demonstrating the key mathematical results from the
formalization of first-species counterpoint as a constrained voice-leading quiver.

Results demonstrated:
  1. Enumeration of the counterpoint quiver (vertices, edges, hom-sets)
  2. Strong connectivity verification
  3. Non-composability witness
  4. Perfect vs. imperfect self-loop counts (1 vs. 12)
  5. Incoming edge counts (61 vs. 72)
  6. Voice-swap asymmetry
  7. L¹-lattice identity for voice-leading cost
  8. Seminorm properties verification
"""

from __future__ import annotations
from typing import NamedTuple
from itertools import product


# ─── Core Definitions ──────────────────────────────────────────────────────────

CONSONANT_INTERVALS: set[int] = {0, 3, 4, 7, 8, 9}
PERFECT_CONSONANCES: set[int] = {0, 7}
IMPERFECT_CONSONANCES: set[int] = CONSONANT_INTERVALS - PERFECT_CONSONANCES
N: int = 12  # twelve-tone equal temperament

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison/Octave", 1: "Minor 2nd", 2: "Major 2nd", 3: "Minor 3rd",
    4: "Major 3rd", 5: "Perfect 4th", 6: "Tritone", 7: "Perfect 5th",
    8: "Minor 6th", 9: "Major 6th", 10: "Minor 7th", 11: "Major 7th",
}


class VoiceLeading(NamedTuple):
    """A voice leading: (bass_motion, soprano_motion) in semitones mod 12."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval: source + soprano - bass (mod 12)."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if both voices move by the same nonzero amount."""
    return vl.bass == vl.soprano and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check if a voice leading from source to target is permitted."""
    return (
        source % N in CONSONANT_INTERVALS
        and target % N in CONSONANT_INTERVALS
        and target_interval(source, vl) == target % N
        and not (target % N in PERFECT_CONSONANCES and is_parallel(vl))
    )


def voice_leading_cost(motion: list[int]) -> int:
    """L¹ cost of a voice motion: sum of absolute displacements."""
    return sum(abs(m) for m in motion)


# ─── Demo 1: Enumerate the Counterpoint Quiver ─────────────────────────────────

def demo_enumerate_quiver() -> None:
    """Enumerate all permitted voice leadings in the 12-TET counterpoint quiver."""
    print("=" * 70)
    print("DEMO 1: Enumeration of the Counterpoint Quiver Q(C₁₂, P₁₂)")
    print("=" * 70)
    print(f"\nVertices (consonant intervals): {sorted(CONSONANT_INTERVALS)}")
    print(f"  = {{{', '.join(INTERVAL_NAMES[i] for i in sorted(CONSONANT_INTERVALS))}}}")
    print(f"\nPerfect consonances: {sorted(PERFECT_CONSONANCES)}")
    print(f"  = {{{', '.join(INTERVAL_NAMES[i] for i in sorted(PERFECT_CONSONANCES))}}}")

    total_edges: int = 0
    hom_sets: dict[tuple[int, int], list[VoiceLeading]] = {}

    for src in sorted(CONSONANT_INTERVALS):
        for tgt in sorted(CONSONANT_INTERVALS):
            permitted: list[VoiceLeading] = []
            for b in range(N):
                for s in range(N):
                    vl = VoiceLeading(b, s)
                    if is_permitted(src, tgt, vl):
                        permitted.append(vl)
            hom_sets[(src, tgt)] = permitted
            total_edges += len(permitted)

    print(f"\nTotal permitted voice leadings (edges): {total_edges}")
    print(f"Total potential voice leadings (6×6×12): {6 * 6 * 12}")
    print(f"Forbidden (parallel into perfect): {6 * 6 * 12 - total_edges}")

    print("\nHom-set sizes |E(i, j)|:")
    print(f"{'':>14}", end="")
    for tgt in sorted(CONSONANT_INTERVALS):
        print(f"  →{tgt:>2}", end="")
    print("  | Row sum")
    print("-" * 62)
    for src in sorted(CONSONANT_INTERVALS):
        print(f"  From {src:>2}    ", end="")
        row_sum = 0
        for tgt in sorted(CONSONANT_INTERVALS):
            count = len(hom_sets[(src, tgt)])
            print(f"  {count:>3}", end="")
            row_sum += count
        print(f"  | {row_sum}")


# ─── Demo 2: Strong Connectivity ───────────────────────────────────────────────

def demo_strong_connectivity() -> None:
    """Verify strong connectivity via canonical voice leadings."""
    print("\n" + "=" * 70)
    print("DEMO 2: Strong Connectivity — Canonical Voice Leadings")
    print("=" * 70)

    print("\nFor every pair (i, j) of consonant intervals, the canonical voice")
    print("leading (bass=0, soprano=j−i) provides a permitted path:\n")

    for src in sorted(CONSONANT_INTERVALS):
        for tgt in sorted(CONSONANT_INTERVALS):
            vl = VoiceLeading(0, (tgt - src) % N)
            perm = is_permitted(src, tgt, vl)
            status = "✓ permitted" if perm else "✗ FORBIDDEN"
            par = " [parallel]" if is_parallel(vl) else ""
            print(f"  {INTERVAL_NAMES[src]:>14} → {INTERVAL_NAMES[tgt]:<14}  "
                  f"VL=(0, {vl.soprano:>2})  {status}{par}")

    print("\n✓ All 36 source-target pairs are reachable → quiver is strongly connected.")


# ─── Demo 3: Non-Composability ─────────────────────────────────────────────────

def demo_non_composability() -> None:
    """Find a witness for non-composability of permitted voice leadings."""
    print("\n" + "=" * 70)
    print("DEMO 3: Non-Composability — Permitted VLs Don't Compose")
    print("=" * 70)

    witnesses_found: int = 0
    for i in sorted(CONSONANT_INTERVALS):
        for j in sorted(CONSONANT_INTERVALS):
            for k in sorted(CONSONANT_INTERVALS):
                for b1 in range(N):
                    for s1 in range(N):
                        vl1 = VoiceLeading(b1, s1)
                        if not is_permitted(i, j, vl1):
                            continue
                        for b2 in range(N):
                            for s2 in range(N):
                                vl2 = VoiceLeading(b2, s2)
                                if not is_permitted(j, k, vl2):
                                    continue
                                # Compose
                                comp = VoiceLeading((b1 + b2) % N, (s1 + s2) % N)
                                if not is_permitted(i, k, comp):
                                    if witnesses_found < 3:
                                        print(f"\n  Witness {witnesses_found + 1}:")
                                        print(f"    Step 1: {INTERVAL_NAMES[i]} →"
                                              f" {INTERVAL_NAMES[j]}  via VL=({b1},{s1})"
                                              f"  {'✓ permitted'}")
                                        print(f"    Step 2: {INTERVAL_NAMES[j]} →"
                                              f" {INTERVAL_NAMES[k]}  via VL=({b2},{s2})"
                                              f"  {'✓ permitted'}")
                                        print(f"    Composed: {INTERVAL_NAMES[i]} →"
                                              f" {INTERVAL_NAMES[k]}  via VL="
                                              f"({comp.bass},{comp.soprano})"
                                              f"  {'✗ FORBIDDEN'}")
                                        reason = ""
                                        if k in PERFECT_CONSONANCES and is_parallel(comp):
                                            reason = "parallel motion into perfect consonance"
                                        elif target_interval(i, comp) != k:
                                            reason = "target mismatch after composition"
                                        print(f"    Reason: {reason}")
                                    witnesses_found += 1
                    if witnesses_found >= 3:
                        break
                if witnesses_found >= 3:
                    break
            if witnesses_found >= 3:
                break
        if witnesses_found >= 3:
            break

    print(f"\n  Total non-composable triples found: {witnesses_found}")
    print("  → Permitted voice leadings do NOT form a subcategory.")


# ─── Demo 4: Self-Loop Asymmetry ───────────────────────────────────────────────

def demo_self_loops() -> None:
    """Count self-loops at perfect vs. imperfect consonances."""
    print("\n" + "=" * 70)
    print("DEMO 4: Self-Loop Asymmetry — The Bottleneck Theorem")
    print("=" * 70)

    print(f"\n{'Interval':<20} {'Type':<12} {'Self-loops':>10}  Details")
    print("-" * 65)

    for iv in sorted(CONSONANT_INTERVALS):
        loops: list[VoiceLeading] = []
        for b in range(N):
            vl = VoiceLeading(b, b)  # self-loop requires s = b
            if is_permitted(iv, iv, vl):
                loops.append(vl)
        iv_type = "Perfect" if iv in PERFECT_CONSONANCES else "Imperfect"
        detail = ", ".join(f"({v.bass},{v.soprano})" for v in loops[:5])
        if len(loops) > 5:
            detail += f" ... ({len(loops)} total)"
        print(f"  {INTERVAL_NAMES[iv]:<18} {iv_type:<12} {len(loops):>10}  {detail}")

    print("\n  Perfect consonances: 1 self-loop each (identity only)")
    print("  Imperfect consonances: 12 self-loops each (all parallel motions)")
    print("  Ratio: 12:1 — this is the 'parallel fifths' bottleneck.")


# ─── Demo 5: Incoming Edge Counts ──────────────────────────────────────────────

def demo_incoming_edges() -> None:
    """Count total incoming permitted voice leadings per consonance type."""
    print("\n" + "=" * 70)
    print("DEMO 5: Incoming Edge Counts — 61 vs. 72")
    print("=" * 70)

    for tgt in sorted(CONSONANT_INTERVALS):
        total_incoming = 0
        for src in sorted(CONSONANT_INTERVALS):
            for b in range(N):
                for s in range(N):
                    vl = VoiceLeading(b, s)
                    if is_permitted(src, tgt, vl):
                        total_incoming += 1
        iv_type = "PERFECT" if tgt in PERFECT_CONSONANCES else "imperfect"
        print(f"  {INTERVAL_NAMES[tgt]:<18} [{iv_type:<9}]: {total_incoming} incoming VLs")

    print("\n  Perfect consonances: 61 incoming each")
    print("  Imperfect consonances: 72 incoming each")
    print("  Difference: 11 (= 12 - 1 forbidden parallel self-loops)")
    print("  Percentage reduction: {:.1f}%".format(100 * (72 - 61) / 72))


# ─── Demo 6: Voice-Swap Asymmetry ──────────────────────────────────────────────

def demo_voice_swap() -> None:
    """Show that interval negation breaks consonance."""
    print("\n" + "=" * 70)
    print("DEMO 6: Voice-Swap Asymmetry — Negation Breaks Consonance")
    print("=" * 70)

    print(f"\n  The negation map i ↦ −i (mod 12) on intervals:\n")
    print(f"  {'Interval i':<18} {'Name':<16} {'−i mod 12':>9}  {'Name of −i':<16} {'Consonant?':>10}")
    print("  " + "-" * 72)

    for i in range(N):
        neg_i = (-i) % N
        cons_i = "✓" if i in CONSONANT_INTERVALS else "✗"
        cons_neg = "✓" if neg_i in CONSONANT_INTERVALS else "✗"
        preserved = "=" if (i in CONSONANT_INTERVALS) == (neg_i in CONSONANT_INTERVALS) else "≠"
        print(f"  {i:>4} ({cons_i})        {INTERVAL_NAMES[i]:<16} {neg_i:>5}      "
              f"{INTERVAL_NAMES[neg_i]:<16} {cons_neg:>5}  {preserved}")

    breaks = [(i, (-i) % N) for i in CONSONANT_INTERVALS if (-i) % N not in CONSONANT_INTERVALS]
    print(f"\n  Consonance-breaking pairs: {breaks}")
    print(f"  Key example: Perfect 5th (7) → Perfect 4th (5), which is DISSONANT.")
    print(f"  → The bass voice is structurally asymmetric.")


# ─── Demo 7: L¹-Lattice Identity ───────────────────────────────────────────────

def demo_lattice_identity() -> None:
    """Verify the L¹-lattice identity: cost(m₁⊓m₂) + cost(m₁⊔m₂) = cost(m₁) + cost(m₂)."""
    print("\n" + "=" * 70)
    print("DEMO 7: L¹-Lattice Identity for Voice-Leading Cost")
    print("=" * 70)

    import random
    random.seed(42)

    n_voices = 4
    print(f"\n  Testing on random {n_voices}-voice motions (100,000 trials):\n")

    failures = 0
    for trial in range(100_000):
        m1 = [random.randint(-12, 12) for _ in range(n_voices)]
        m2 = [random.randint(-12, 12) for _ in range(n_voices)]

        meet = [min(a, b) for a, b in zip(m1, m2)]
        join = [max(a, b) for a, b in zip(m1, m2)]

        lhs = voice_leading_cost(meet) + voice_leading_cost(join)
        rhs = voice_leading_cost(m1) + voice_leading_cost(m2)

        if lhs != rhs:
            failures += 1

    print(f"  Failures: {failures} / 100,000")
    print(f"  → Identity ‖m₁⊓m₂‖₁ + ‖m₁⊔m₂‖₁ = ‖m₁‖₁ + ‖m₂‖₁ holds universally.")

    # Show a concrete example
    m1 = [3, -2, 5, -1]
    m2 = [1, 4, -3, 2]
    meet = [min(a, b) for a, b in zip(m1, m2)]
    join = [max(a, b) for a, b in zip(m1, m2)]

    print(f"\n  Concrete example:")
    print(f"    m₁ = {m1}, cost = {voice_leading_cost(m1)}")
    print(f"    m₂ = {m2}, cost = {voice_leading_cost(m2)}")
    print(f"    m₁ ⊓ m₂ = {meet}, cost = {voice_leading_cost(meet)}")
    print(f"    m₁ ⊔ m₂ = {join}, cost = {voice_leading_cost(join)}")
    print(f"    LHS: {voice_leading_cost(meet)} + {voice_leading_cost(join)} = "
          f"{voice_leading_cost(meet) + voice_leading_cost(join)}")
    print(f"    RHS: {voice_leading_cost(m1)} + {voice_leading_cost(m2)} = "
          f"{voice_leading_cost(m1) + voice_leading_cost(m2)}")


# ─── Demo 8: Seminorm Properties ───────────────────────────────────────────────

def demo_seminorm() -> None:
    """Verify the three seminorm properties of voice-leading cost."""
    print("\n" + "=" * 70)
    print("DEMO 8: Voice-Leading Cost as a Seminorm")
    print("=" * 70)

    import random
    random.seed(123)

    n_voices = 3
    trials = 50_000
    print(f"\n  Testing on random {n_voices}-voice motions ({trials} trials):\n")

    nonneg_ok = True
    triangle_ok = True
    homog_ok = True

    for _ in range(trials):
        m1 = [random.randint(-10, 10) for _ in range(n_voices)]
        m2 = [random.randint(-10, 10) for _ in range(n_voices)]
        c = random.randint(-5, 5)

        # Nonnegativity
        if voice_leading_cost(m1) < 0:
            nonneg_ok = False

        # Triangle inequality
        m_sum = [a + b for a, b in zip(m1, m2)]
        if voice_leading_cost(m_sum) > voice_leading_cost(m1) + voice_leading_cost(m2):
            triangle_ok = False

        # Absolute homogeneity
        cm = [c * a for a in m1]
        if voice_leading_cost(cm) != abs(c) * voice_leading_cost(m1):
            homog_ok = False

    print(f"  1. Nonnegativity:         {'✓ PASSED' if nonneg_ok else '✗ FAILED'}")
    print(f"  2. Triangle inequality:   {'✓ PASSED' if triangle_ok else '✗ FAILED'}")
    print(f"  3. Absolute homogeneity:  {'✓ PASSED' if homog_ok else '✗ FAILED'}")
    print(f"\n  → Voice-leading cost is a seminorm on ℤ^{n_voices}.")

    # Zero iff stationary
    print(f"\n  Additional: cost = 0 iff motion = 0")
    assert voice_leading_cost([0, 0, 0]) == 0
    assert voice_leading_cost([1, 0, 0]) > 0
    print(f"    cost([0,0,0]) = {voice_leading_cost([0, 0, 0])} ✓")
    print(f"    cost([1,0,0]) = {voice_leading_cost([1, 0, 0])} > 0 ✓")

    # Retrograde invariance
    m = [3, -2, 5]
    neg_m = [-x for x in m]
    print(f"\n  Retrograde invariance: cost(m) = cost(−m)")
    print(f"    cost({m}) = {voice_leading_cost(m)}")
    print(f"    cost({neg_m}) = {voice_leading_cost(neg_m)}")
    print(f"    Equal: {'✓' if voice_leading_cost(m) == voice_leading_cost(neg_m) else '✗'}")


# ─── Demo 9: Consonance Score Visualization ─────────────────────────────────────

def demo_consonance_scores() -> None:
    """Display the consonance scoring function."""
    print("\n" + "=" * 70)
    print("DEMO 9: Consonance Score Distribution")
    print("=" * 70)

    scores: dict[int, int] = {
        0: 8, 1: 1, 2: 2, 3: 5, 4: 5, 5: 6, 6: 0,
        7: 7, 8: 4, 9: 4, 10: 1, 11: 1,
    }

    print(f"\n  {'Semitones':<12} {'Interval':<18} {'Score':>5}  {'Bar':<30}  {'Class'}")
    print("  " + "-" * 80)
    for i in range(N):
        s = scores[i]
        bar = "█" * (s * 3)
        if s >= 6:
            cls = "PERFECT"
        elif s >= 4:
            cls = "imperfect"
        else:
            cls = "dissonant"
        cons = "♪" if i in CONSONANT_INTERVALS else " "
        print(f"  {i:>4}  {cons}     {INTERVAL_NAMES[i]:<18} {s:>5}  {bar:<30}  {cls}")

    print(f"\n  Consonant (score ≥ 4): {sorted(i for i, s in scores.items() if s >= 4)}")
    print(f"  Perfect   (score ≥ 6): {sorted(i for i, s in scores.items() if s >= 6)}")
    print(f"  Note: Perfect 4th (5) has score 6 but is NOT in the counterpoint")
    print(f"        consonant set — it requires contextual treatment above the bass.")


# ─── Main ───────────────────────────────────────────────────────────────────────

def main() -> None:
    """Run all demonstrations."""
    print("\n" + "╔" + "═" * 68 + "╗")
    print("║  SONIC MATHEMATICS: Counterpoint as Category Theory              ║")
    print("║  Numerical Demonstrations of Formally Verified Results           ║")
    print("╚" + "═" * 68 + "╝\n")

    demo_enumerate_quiver()
    demo_strong_connectivity()
    demo_non_composability()
    demo_self_loops()
    demo_incoming_edges()
    demo_voice_swap()
    demo_lattice_identity()
    demo_seminorm()
    demo_consonance_scores()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
