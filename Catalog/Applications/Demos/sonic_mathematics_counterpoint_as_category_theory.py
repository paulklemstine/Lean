#!/usr/bin/env python3
"""
Sonic Mathematics: Counterpoint as Category Theory — Numerical Demonstrations

This module enumerates all permitted voice leadings in first-species counterpoint
over 12-TET and demonstrates the five main structural theorems:
  1. Strong connectivity
  2. Non-composability
  3. The Bottleneck Theorem (self-loop asymmetry)
  4. Voice-swap asymmetry
  5. Hom-set cardinalities (61 vs 72)

All arithmetic is mod 12, matching the formal definitions in ZMod 12.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import NamedTuple


# ---------------------------------------------------------------------------
# Core Definitions (mirrors the Lean formalization)
# ---------------------------------------------------------------------------

N: int = 12  # chromatic pitch classes

CONSONANT: frozenset[int] = frozenset({0, 3, 4, 7, 8, 9})
PERFECT: frozenset[int] = frozenset({0, 7})
IMPERFECT: frozenset[int] = CONSONANT - PERFECT

INTERVAL_NAMES: dict[int, str] = {
    0: "Unison/Octave",
    1: "minor 2nd",
    2: "Major 2nd",
    3: "minor 3rd",
    4: "Major 3rd",
    5: "Perfect 4th",
    6: "Tritone",
    7: "Perfect 5th",
    8: "minor 6th",
    9: "Major 6th",
    10: "minor 7th",
    11: "Major 7th",
}


class VoiceLeading(NamedTuple):
    """A voice leading is a pair (bass_motion, soprano_motion) in Z/12Z."""
    bass: int
    soprano: int


def target_interval(source: int, vl: VoiceLeading) -> int:
    """Compute the target interval: source + soprano - bass (mod 12)."""
    return (source + vl.soprano - vl.bass) % N


def is_parallel(vl: VoiceLeading) -> bool:
    """A voice leading is parallel if bass == soprano and bass != 0."""
    return vl.bass == vl.soprano and vl.bass % N != 0


def is_permitted(source: int, target: int, vl: VoiceLeading) -> bool:
    """Check whether a voice leading is permitted in the standard 12-TET system."""
    return (
        source % N in CONSONANT
        and target % N in CONSONANT
        and target_interval(source, vl) == target % N
        and not (target % N in PERFECT and is_parallel(vl))
    )


# ---------------------------------------------------------------------------
# Enumeration: build the full Counterpoint Quiver
# ---------------------------------------------------------------------------

def enumerate_permitted(source: int, target: int) -> list[VoiceLeading]:
    """Return all permitted voice leadings from source to target."""
    results: list[VoiceLeading] = []
    for b in range(N):
        for s in range(N):
            vl = VoiceLeading(b, s)
            if is_permitted(source, target, vl):
                results.append(vl)
    return results


def build_adjacency_matrix() -> dict[tuple[int, int], int]:
    """Build the weighted adjacency matrix |E(i,j)| for all consonant pairs."""
    matrix: dict[tuple[int, int], int] = {}
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            matrix[(i, j)] = len(enumerate_permitted(i, j))
    return matrix


# ---------------------------------------------------------------------------
# Theorem 1: Strong Connectivity
# ---------------------------------------------------------------------------

def demo_strong_connectivity() -> None:
    """Demonstrate that between any two consonant intervals, a permitted VL exists."""
    print("=" * 70)
    print("THEOREM 1: Strong Connectivity")
    print("=" * 70)
    print("Between ANY two consonant intervals, at least one permitted voice")
    print("leading exists. The quiver has diameter 1.\n")

    all_connected = True
    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            vls = enumerate_permitted(i, j)
            if not vls:
                print(f"  ✗ NO voice leading from {INTERVAL_NAMES[i]} to {INTERVAL_NAMES[j]}")
                all_connected = False
            else:
                # Show the canonical VL
                canonical = VoiceLeading(0, (j - i) % N)
                tag = " (canonical)" if canonical in vls else ""
                print(
                    f"  ✓ {INTERVAL_NAMES[i]:15s} → {INTERVAL_NAMES[j]:15s}: "
                    f"{len(vls):3d} voice leadings  "
                    f"[e.g. bass={vls[0].bass}, sop={vls[0].soprano}{tag}]"
                )

    print(f"\nStrong connectivity verified: {all_connected}")
    print()


# ---------------------------------------------------------------------------
# Theorem 2: Non-Composability
# ---------------------------------------------------------------------------

def compose_vl(v1: VoiceLeading, v2: VoiceLeading) -> VoiceLeading:
    """Compose two voice leadings: add motions mod 12."""
    return VoiceLeading((v1.bass + v2.bass) % N, (v1.soprano + v2.soprano) % N)


def demo_non_composability() -> None:
    """Find and display a concrete counterexample to composability."""
    print("=" * 70)
    print("THEOREM 2: Non-Composability")
    print("=" * 70)
    print("Permitted voice leadings are NOT closed under composition.\n")

    counterexamples: list[tuple[int, int, int, VoiceLeading, VoiceLeading]] = []

    for i in sorted(CONSONANT):
        for j in sorted(CONSONANT):
            for k in sorted(CONSONANT):
                vls_ij = enumerate_permitted(i, j)
                vls_jk = enumerate_permitted(j, k)
                for v1 in vls_ij:
                    for v2 in vls_jk:
                        comp = compose_vl(v1, v2)
                        if target_interval(i, comp) == k and not is_permitted(i, k, comp):
                            counterexamples.append((i, j, k, v1, v2))

    print(f"  Found {len(counterexamples)} composition failures total.\n")

    # Show first 3 examples
    for idx, (i, j, k, v1, v2) in enumerate(counterexamples[:3]):
        comp = compose_vl(v1, v2)
        print(f"  Example {idx + 1}:")
        print(f"    Step 1: {INTERVAL_NAMES[i]} → {INTERVAL_NAMES[j]}  "
              f"via (bass={v1.bass}, sop={v1.soprano})  [permitted ✓]")
        print(f"    Step 2: {INTERVAL_NAMES[j]} → {INTERVAL_NAMES[k]}  "
              f"via (bass={v2.bass}, sop={v2.soprano})  [permitted ✓]")
        print(f"    Composite: (bass={comp.bass}, sop={comp.soprano})  "
              f"parallel={is_parallel(comp)}, target_perfect={k in PERFECT}  "
              f"[FORBIDDEN ✗]")
        print()

    print()


# ---------------------------------------------------------------------------
# Theorem 3: Bottleneck Theorem (Self-Loop Asymmetry)
# ---------------------------------------------------------------------------

def demo_bottleneck() -> None:
    """Demonstrate the 12:1 self-loop ratio."""
    print("=" * 70)
    print("THEOREM 3: Bottleneck Theorem (Self-Loop Asymmetry)")
    print("=" * 70)
    print("Perfect consonances: 1 self-loop. Imperfect consonances: 12.\n")

    for i in sorted(CONSONANT):
        loops = enumerate_permitted(i, i)
        kind = "PERFECT" if i in PERFECT else "imperfect"
        print(f"  {INTERVAL_NAMES[i]:15s} ({kind:9s}): {len(loops):2d} self-loops", end="")
        if len(loops) <= 3:
            detail = ", ".join(f"({v.bass},{v.soprano})" for v in loops)
            print(f"  → [{detail}]", end="")
        print()

    perfect_loops = sum(len(enumerate_permitted(i, i)) for i in PERFECT)
    imperfect_loops = sum(len(enumerate_permitted(i, i)) for i in IMPERFECT)
    print(f"\n  Total self-loops at perfect consonances:   {perfect_loops}")
    print(f"  Total self-loops at imperfect consonances: {imperfect_loops}")
    print(f"  Ratio (imperfect/perfect per interval):    {12}:1")
    print()


# ---------------------------------------------------------------------------
# Theorem 4: Voice-Swap Asymmetry
# ---------------------------------------------------------------------------

def demo_voice_swap() -> None:
    """Show that negation mod 12 does not preserve the consonant set."""
    print("=" * 70)
    print("THEOREM 4: Voice-Swap Asymmetry")
    print("=" * 70)
    print("The involution i ↦ -i (mod 12) does NOT preserve consonance.\n")

    print(f"  Consonant intervals C = {sorted(CONSONANT)}")
    negated = frozenset((-i) % N for i in CONSONANT)
    print(f"  Negated set  -C     = {sorted(negated)}")
    print(f"  C == -C ?  {CONSONANT == negated}")
    print()

    for i in sorted(CONSONANT):
        neg = (-i) % N
        in_c = neg in CONSONANT
        symbol = "✓" if in_c else "✗"
        print(
            f"  {INTERVAL_NAMES[i]:15s} (i={i:2d})  "
            f"→  -i ≡ {neg:2d}  ({INTERVAL_NAMES[neg]:15s})  "
            f"consonant? {symbol}"
        )

    print(f"\n  The perfect fifth (7) maps to the perfect fourth (5),")
    print(f"  which is DISSONANT — formalizing the bass voice's privileged role.")
    print()


# ---------------------------------------------------------------------------
# Theorem 5: Hom-Set Cardinalities
# ---------------------------------------------------------------------------

def demo_hom_sets() -> None:
    """Compute and display incoming voice-leading counts."""
    print("=" * 70)
    print("THEOREM 5: Hom-Set Cardinalities (61 vs 72)")
    print("=" * 70)
    print("Perfect consonances receive fewer incoming voice leadings.\n")

    matrix = build_adjacency_matrix()

    # Print adjacency matrix
    header = "        " + "  ".join(f"{j:>4d}" for j in sorted(CONSONANT))
    print(f"  Adjacency matrix |E(i,j)|:")
    print(f"  {header}")
    for i in sorted(CONSONANT):
        row = "  ".join(f"{matrix[(i, j)]:4d}" for j in sorted(CONSONANT))
        print(f"  {i:>4d}:   {row}")
    print()

    # Incoming totals
    for j in sorted(CONSONANT):
        total = sum(matrix[(i, j)] for i in sorted(CONSONANT))
        kind = "PERFECT" if j in PERFECT else "imperfect"
        print(f"  Incoming to {INTERVAL_NAMES[j]:15s} ({kind:9s}): {total}")

    perf_total = sum(
        sum(matrix[(i, j)] for i in sorted(CONSONANT))
        for j in sorted(PERFECT)
    )
    imperf_total = sum(
        sum(matrix[(i, j)] for i in sorted(CONSONANT))
        for j in sorted(IMPERFECT)
    )

    print(f"\n  Total incoming to all perfect consonances:   {perf_total}  "
          f"(avg {perf_total / len(PERFECT):.0f} per interval)")
    print(f"  Total incoming to all imperfect consonances: {imperf_total}  "
          f"(avg {imperf_total / len(IMPERFECT):.0f} per interval)")
    print(f"  Reduction: {72 - 61} fewer per perfect interval  "
          f"({(72 - 61) / 72 * 100:.1f}%)")
    print()

    # Grand total
    grand = sum(matrix.values())
    print(f"  Grand total of permitted voice leadings in the quiver: {grand}")
    print()


# ---------------------------------------------------------------------------
# Bonus: Musical Example — a short counterpoint fragment
# ---------------------------------------------------------------------------

def demo_musical_fragment() -> None:
    """Generate a short random valid counterpoint path through the quiver."""
    import random

    print("=" * 70)
    print("BONUS: A Random Walk Through the Counterpoint Quiver")
    print("=" * 70)
    print("Each step is a permitted voice leading. Bass starts on C4 (60).\n")

    random.seed(42)
    bass_pitch = 60  # MIDI middle C
    current_interval = 7  # start on a fifth

    NOTE_NAMES = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]

    steps = 8
    print(f"  {'Beat':>4s}  {'Bass':>6s}  {'Soprano':>7s}  {'Interval':>15s}  {'VL':>12s}")
    print(f"  {'----':>4s}  {'------':>6s}  {'-------':>7s}  {'--------':>15s}  {'--':>12s}")

    soprano_pitch = bass_pitch + current_interval
    print(
        f"  {1:4d}  "
        f"{NOTE_NAMES[bass_pitch % 12]:>6s}  "
        f"{NOTE_NAMES[soprano_pitch % 12]:>7s}  "
        f"{INTERVAL_NAMES[current_interval]:>15s}  "
        f"{'(start)':>12s}"
    )

    for beat in range(2, steps + 1):
        # Pick a random target interval
        target = random.choice(sorted(CONSONANT))
        vls = enumerate_permitted(current_interval, target)
        vl = random.choice(vls)

        bass_pitch = (bass_pitch + vl.bass) % 128
        soprano_pitch = (soprano_pitch + vl.soprano) % 128

        # Keep in reasonable range
        if bass_pitch < 48:
            bass_pitch += 12
        if bass_pitch > 72:
            bass_pitch -= 12
        if soprano_pitch < 60:
            soprano_pitch += 12
        if soprano_pitch > 84:
            soprano_pitch -= 12

        actual_interval = (soprano_pitch - bass_pitch) % 12

        print(
            f"  {beat:4d}  "
            f"{NOTE_NAMES[bass_pitch % 12]:>6s}  "
            f"{NOTE_NAMES[soprano_pitch % 12]:>7s}  "
            f"{INTERVAL_NAMES[actual_interval]:>15s}  "
            f"{'b=' + str(vl.bass) + ' s=' + str(vl.soprano):>12s}"
        )
        current_interval = target

    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   SONIC MATHEMATICS: Counterpoint as Category Theory               ║")
    print("║   Numerical Demonstrations of Five Structural Theorems             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_strong_connectivity()
    demo_non_composability()
    demo_bottleneck()
    demo_voice_swap()
    demo_hom_sets()
    demo_musical_fragment()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
