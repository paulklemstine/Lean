#!/usr/bin/env python3
"""
Tropical Counterpoint: Applications

Demonstrates real-world applications of tropical music theory:
1. Automated composition via certified voice leading
2. Style classification using tropical cost signatures
3. Musical constraint verification
"""

from typing import List, Tuple, Dict
from algorithms import (
    tropical_dp_voice_leading, compute_pareto_frontier,
    forbidden_vertical_penalty, melodic_leap_penalty, parallel_perfect_penalty,
    CONSONANCES, PERFECT_CONSONANCES
)


def note_name(midi: int) -> str:
    """Convert MIDI number to note name."""
    names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    octave = midi // 12 - 1
    return f"{names[midi % 12]}{octave}"


# ─── Application 1: Automated Palestrina-Style Composition ──────────

def app_auto_composition():
    """Generate certified counterpoint over a given cantus firmus."""
    print("=" * 60)
    print("APPLICATION 1: Automated Palestrina-Style Composition")
    print("=" * 60)

    # Famous Fux cantus firmus (transposed to C)
    fux_cantus = [60, 62, 64, 65, 64, 62, 64, 62, 61, 60]  # D mode
    print(f"\nFux cantus firmus: {[note_name(p) for p in fux_cantus]}")

    # Find optimal counterpoint
    result = tropical_dp_voice_leading(fux_cantus, range(55, 80))
    print(f"Optimal melody:   {[note_name(p) for p in result.optimal_melody]}")
    print(f"MIDI pitches:     {result.optimal_melody}")
    print(f"Total cost:       {result.optimal_cost}")

    intervals = [result.optimal_melody[i] - fux_cantus[i] for i in range(len(fux_cantus))]
    interval_names = {0: 'P1', 3: 'm3', 4: 'M3', 7: 'P5', 8: 'm6',
                      9: 'M6', 12: 'P8', -3: 'm3↓', -4: 'M3↓', -7: 'P5↓',
                      -8: 'm6↓', -9: 'M6↓', -12: 'P8↓'}
    print(f"Intervals:        {[interval_names.get(iv, str(iv)) for iv in intervals]}")

    # Verify legality
    legal = result.optimal_cost == 0.0
    print(f"Certified legal:  {'✓ YES' if legal else '✗ NO'}")
    if legal:
        print("  → This counterpoint is machine-verified to satisfy all")
        print("    first-species rules: consonant intervals, no parallel")
        print("    perfect consonances, stepwise motion.")

    # Generate alternatives with different weights
    print(f"\nAlternative voicings:")
    for A, B, C, desc in [
        (1, 0.1, 1, "balanced"),
        (1, 2, 1, "prefer small steps"),
        (2, 1, 0.5, "prefer consonance"),
    ]:
        r = tropical_dp_voice_leading(fux_cantus, range(55, 80), (A, B, C))
        print(f"  {desc:20s}: {[note_name(p) for p in r.optimal_melody]}, cost={r.optimal_cost:.1f}")
    print()


# ─── Application 2: Style Classification ────────────────────────────

def app_style_classification():
    """Classify musical excerpts by their tropical cost signature."""
    print("=" * 60)
    print("APPLICATION 2: Style Classification via Tropical Signatures")
    print("=" * 60)

    cantus = [60, 62, 64, 65, 67, 65, 64, 62]

    # Define style archetypes
    styles = {
        "Palestrina": [67, 66, 67, 68, 67, 68, 67, 66],      # Stepwise, consonant
        "Bach":       [67, 66, 68, 65, 70, 66, 68, 66],       # Leaps for harmony
        "Modern":     [61, 63, 66, 69, 62, 68, 63, 67],       # Dissonant, angular
    }

    print(f"\nCantus: {[note_name(p) for p in cantus]}")
    print(f"\n{'Style':<12} {'Vert':>5} {'Mel':>5} {'Par':>5} {'Total':>6} {'Variety':>8} {'Legal':>6}")
    print("-" * 55)

    for name, melody in styles.items():
        n = len(cantus)
        ivs = [melody[i] - cantus[i] for i in range(n)]
        vert = sum(forbidden_vertical_penalty(ivs[i]) for i in range(n))
        mel = sum(melodic_leap_penalty(melody[i], melody[i+1]) for i in range(n-1))
        par = sum(parallel_perfect_penalty(ivs[i], ivs[i+1]) for i in range(n-1))
        total = vert + mel + par
        variety = len(set(ivs))
        legal = total == 0.0 and all(abs(melody[i+1]-melody[i]) <= 2 for i in range(n-1))
        print(f"{name:<12} {vert:5.0f} {mel:5.0f} {par:5.0f} {total:6.1f} {variety:8d} {'✓' if legal else '':>6}")

    print("\n  → The tropical cost signature (Vert, Mel, Par) distinguishes")
    print("    compositional styles as regions in a 3D penalty space.")
    print("    Palestrina lives at the origin; Bach nearby with some variety;")
    print("    Modern music explores higher-cost regions for expressivity.\n")


# ─── Application 3: Constraint Verification ─────────────────────────

def app_constraint_verification():
    """Verify whether a given composition satisfies contrapuntal rules."""
    print("=" * 60)
    print("APPLICATION 3: Musical Constraint Verification")
    print("=" * 60)

    # Test pieces
    pieces = [
        ("Student exercise A", [60, 62, 64, 65], [67, 66, 67, 68]),
        ("Student exercise B", [60, 62, 64, 65], [67, 69, 71, 72]),
        ("Student exercise C", [60, 62, 64, 65], [64, 58, 67, 68]),
    ]

    for name, cantus, melody in pieces:
        print(f"\n{name}:")
        print(f"  Cantus: {[note_name(p) for p in cantus]}")
        print(f"  Melody: {[note_name(p) for p in melody]}")
        n = len(cantus)
        ivs = [melody[i] - cantus[i] for i in range(n)]

        # Check each rule
        issues = []
        for i in range(n):
            if abs(ivs[i]) not in CONSONANCES:
                issues.append(f"  ⚠ Position {i}: dissonant interval {ivs[i]} semitones")
        for i in range(n-1):
            if abs(ivs[i]) in PERFECT_CONSONANCES and abs(ivs[i+1]) in PERFECT_CONSONANCES:
                issues.append(f"  ⚠ Positions {i}-{i+1}: parallel perfect consonances")
        for i in range(n-1):
            if abs(melody[i+1] - melody[i]) > 2:
                issues.append(f"  ⚠ Position {i}-{i+1}: leap of {abs(melody[i+1]-melody[i])} semitones")

        vert = sum(forbidden_vertical_penalty(ivs[i]) for i in range(n))
        mel = sum(melodic_leap_penalty(melody[i], melody[i+1]) for i in range(n-1))
        par = sum(parallel_perfect_penalty(ivs[i], ivs[i+1]) for i in range(n-1))
        total = vert + mel + par

        print(f"  Tropical cost: {total:.1f} (vert={vert:.0f}, mel={mel:.0f}, par={par:.0f})")
        if issues:
            for issue in issues:
                print(issue)
            print(f"  VERDICT: ✗ Not first-species legal (cost > 0)")

            # Suggest fix
            result = tropical_dp_voice_leading(cantus, range(55, 80))
            print(f"  SUGGESTED FIX: {[note_name(p) for p in result.optimal_melody]} (cost={result.optimal_cost})")
        else:
            print(f"  VERDICT: ✓ First-species legal (cost = 0)")

    print()


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app_auto_composition()
    app_style_classification()
    app_constraint_verification()
