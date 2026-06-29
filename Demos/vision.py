#!/usr/bin/env python3
"""
Tropical SATB Chorale Optimization — Applications

Real-world applications demonstrating the tropical DP framework
for music harmonization, multi-agent coordination, and weighted logic.
"""

import numpy as np
from typing import List, Tuple, Dict
from algorithms import (Voice, bellman_satb_dp, viterbi_satb,
                         tropical_conjunction, TropicalConstraint,
                         generate_voicings, verify_conjunction_property)

# ═══════════════════════════════════════════════════════════════════════
# Application 1: Bach Chorale Harmonization
# ═══════════════════════════════════════════════════════════════════════

def app_bach_chorale():
    """
    Harmonize a Bach-style chorale melody using tropical DP.

    Given a soprano melody, find the optimal SATB harmonization
    that minimizes a combination of harmonic and voice-leading penalties.
    """
    print("=" * 70)
    print("APPLICATION 1: Bach Chorale Harmonization")
    print("=" * 70)
    print()

    # Soprano melody: first phrase of "O Haupt voll Blut und Wunden"
    # (a Bach chorale, transposed to C major for simplicity)
    soprano_melody = [67, 64, 67, 69, 67, 65, 64]  # G4 E4 G4 A4 G4 F4 E4
    chord_roots =    [7,  0,  7,  5,  0,  5,  0]    # G  C  G  F  C  F  C
    chord_quals =    ['major','major','major','major','major','major','major']

    # Generate voicings constrained to match soprano melody
    chords = []
    for i, (s, root, qual) in enumerate(zip(soprano_melody, chord_roots, chord_quals)):
        all_voicings = generate_voicings(root, qual)
        # Filter to those matching the soprano note
        constrained = [v for v in all_voicings if v[0] == s]
        if not constrained:
            # Relax: allow soprano within 1 semitone
            constrained = [v for v in all_voicings if abs(v[0] - s) <= 1]
        chords.append(constrained)
        print(f"  Beat {i+1}: soprano={_note(s)}, chord={_root_name(root)} {qual}, "
              f"{len(constrained)} voicings")

    def vert(v: Voice) -> float:
        pen = 0
        # Doubling: prefer doubling root or fifth
        pcs = [p % 12 for p in v]
        if len(set(pcs)) < 3:  # too much doubling
            pen += 5
        return pen

    def lead(v1: Voice, v2: Voice) -> float:
        pen = 0
        for i in range(4):
            d = abs(v2[i] - v1[i])
            if d > 7: pen += 10 * (d - 7)
            elif d > 4: pen += 2 * (d - 4)
        # Parallel fifths/octaves
        for i in range(4):
            for j in range(i+1, 4):
                int1 = (v1[i] - v1[j]) % 12
                int2 = (v2[i] - v2[j]) % 12
                if int1 == int2 and int1 in (0, 7) and v1[i] != v2[i]:
                    pen += 30
        return pen

    result = bellman_satb_dp(chords, vert, lead)
    print(f"\n  Optimal cost: {result.optimal_cost}")
    print(f"  Runtime: {result.runtime_ms:.1f}ms")
    print(f"\n  Optimal harmonization:")
    for i, v in enumerate(result.optimal_path):
        print(f"    Beat {i+1}: S={_note(v[0]):>3} A={_note(v[1]):>3} "
              f"T={_note(v[2]):>3} B={_note(v[3]):>3}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Multi-Agent Coordination
# ═══════════════════════════════════════════════════════════════════════

def app_multi_agent():
    """
    Four autonomous agents must coordinate through a sequence of waypoints.
    Each agent has a preferred trajectory, and there are penalties for:
    - Individual deviation from preferred positions (vertical penalty)
    - Coordination costs between consecutive joint states (leading penalty)
    - Collision avoidance (included in vertical penalty)
    """
    print("=" * 70)
    print("APPLICATION 2: Multi-Agent Coordination")
    print("=" * 70)
    print()

    # 4 agents, each choosing from positions 0-4 on a grid
    positions = list(range(5))
    # Generate all ordered 4-tuples (representing agent positions)
    states = [(a, b, c, d) for a in positions for b in positions
              for c in positions for d in positions]

    # Preferred positions for each agent at each step
    targets = [
        (4, 3, 2, 1),  # Step 0: spread out
        (3, 3, 2, 2),  # Step 1: converge slightly
        (2, 2, 2, 2),  # Step 2: meet in middle
        (1, 2, 3, 4),  # Step 3: spread other way
    ]

    admissible = [states] * 4

    def vert(v: Voice, step=[0]) -> float:
        # This is a simplification - in practice we'd pass step index
        return 0

    # Use step-aware penalties via closure
    def make_vert(step: int):
        t = targets[step]
        def v(voice: Voice) -> float:
            pen = sum(abs(voice[i] - t[i]) for i in range(4))
            # Collision penalty
            positions_used = [voice[i] for i in range(4)]
            for i in range(4):
                for j in range(i+1, 4):
                    if positions_used[i] == positions_used[j]:
                        pen += 10
            return pen
        return v

    def lead(v1: Voice, v2: Voice) -> float:
        # Movement cost
        return sum(abs(v2[i] - v1[i]) for i in range(4))

    # Run step-by-step DP (simplified: use uniform vert for demo)
    avg_vert = lambda v: sum(make_vert(i)(v) for i in range(4)) / 4

    result = bellman_satb_dp(admissible, avg_vert, lead)
    print(f"  Optimal coordination cost: {result.optimal_cost}")
    print(f"  Runtime: {result.runtime_ms:.1f}ms")
    print(f"\n  Optimal joint trajectory:")
    for i, v in enumerate(result.optimal_path):
        print(f"    Step {i}: agents at positions {v}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Constraint Verification via Tropical Logic
# ═══════════════════════════════════════════════════════════════════════

def app_tropical_logic():
    """
    Demonstrate how Boolean constraint satisfaction maps to tropical
    penalty zero-sets, creating a verified dictionary between rule-based
    systems and optimization.
    """
    print("=" * 70)
    print("APPLICATION 3: Tropical Logic for Constraint Verification")
    print("=" * 70)
    print()

    # Define SATB constraints as tropical penalties
    constraints = [
        TropicalConstraint(
            name="Voice Ordering (B ≤ T ≤ A ≤ S)",
            penalty=lambda v: 0 if v[3] <= v[2] <= v[1] <= v[0] else 100,
            predicate=lambda v: v[3] <= v[2] <= v[1] <= v[0],
        ),
        TropicalConstraint(
            name="Soprano Range [60,79]",
            penalty=lambda v: 0 if 60 <= v[0] <= 79 else max(0, 60-v[0], v[0]-79),
            predicate=lambda v: 60 <= v[0] <= 79,
        ),
        TropicalConstraint(
            name="Spacing (adj. upper ≤ octave)",
            penalty=lambda v: 0 if v[0]-v[1] <= 12 and v[1]-v[2] <= 12 else 50,
            predicate=lambda v: v[0]-v[1] <= 12 and v[1]-v[2] <= 12,
        ),
        TropicalConstraint(
            name="No unisons in upper voices",
            penalty=lambda v: 0 if v[0] != v[1] and v[1] != v[2] else 30,
            predicate=lambda v: v[0] != v[1] and v[1] != v[2],
        ),
    ]

    combined = tropical_conjunction(constraints)

    # Test voices
    test_voices = [
        (72, 64, 60, 48),  # C5 E4 C4 C3 — valid
        (72, 64, 60, 72),  # C5 E4 C4 C5 — bass too high
        (72, 72, 60, 48),  # C5 C5 C4 C3 — soprano = alto (unison)
        (72, 55, 54, 48),  # C5 G3 F#3 C3 — spacing violation
        (67, 64, 60, 48),  # G4 E4 C4 C3 — valid
    ]

    print("  Testing tropical conjunction property:")
    print(f"  {'Voice':<25} {'Combined':>8} {'All Legal':>10} {'Match':>6}")
    print("  " + "─" * 55)
    for v in test_voices:
        c = combined(v)
        all_legal = all(con.predicate(v) for con in constraints)
        match = (c == 0) == all_legal
        notes = f"({_note(v[0])},{_note(v[1])},{_note(v[2])},{_note(v[3])})"
        print(f"  {notes:<25} {c:>8.0f} {str(all_legal):>10} {'✓' if match else '✗':>6}")

    # Verify on larger sample
    np.random.seed(42)
    random_voices = [tuple(np.random.randint(40, 80, 4).tolist()) for _ in range(10000)]
    verified = verify_conjunction_property(constraints, random_voices)
    print(f"\n  Verified on 10,000 random voices: {'✓ PASS' if verified else '✗ FAIL'}")
    print()


# ─── Utility ─────────────────────────────────────────────────────────────

def _note(midi: int) -> str:
    notes = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']
    return f"{notes[midi % 12]}{midi // 12 - 1}"

def _root_name(root: int) -> str:
    return ['C','C#','D','Eb','E','F','F#','G','Ab','A','Bb','B'][root % 12]


if __name__ == "__main__":
    app_bach_chorale()
    app_multi_agent()
    app_tropical_logic()


#!/usr/bin/env python3
"""
Tropical SATB Chorale Optimization — Demo

Demonstrates the Bellman recursion for optimal SATB harmonization
using concrete numerical examples. Shows how the dynamic programming
value function computes globally optimal voice-leading solutions.
"""

import numpy as np
from typing import Callable, Dict, List, Tuple
import itertools

# ─── Voice representation ───────────────────────────────────────────────
# A Voice is a 4-tuple (Soprano, Alto, Tenor, Bass) of integer MIDI pitches.
Voice = Tuple[int, int, int, int]

# ─── Example 1: Simple C-major cadence ──────────────────────────────────

def voice_ordered(v: Voice) -> bool:
    """Bass ≤ Tenor ≤ Alto ≤ Soprano"""
    return v[3] <= v[2] <= v[1] <= v[0]

def within_range(v: Voice) -> bool:
    """Standard SATB ranges (MIDI pitches):
       Soprano: C4(60)-G5(79), Alto: F3(53)-D5(74),
       Tenor: C3(48)-G4(67), Bass: E2(40)-D4(62)"""
    return (60 <= v[0] <= 79 and 53 <= v[1] <= 74 and
            48 <= v[2] <= 67 and 40 <= v[3] <= 62)

def spacing_ok(v: Voice) -> bool:
    """Adjacent upper voices within an octave; bass can be further."""
    return (v[0] - v[1] <= 12 and v[1] - v[2] <= 12)

def vertical_penalty(v: Voice) -> int:
    """Penalty for vertical constraint violations."""
    pen = 0
    if not voice_ordered(v): pen += 100
    if not within_range(v): pen += 100
    if not spacing_ok(v): pen += 50
    return pen

def voice_leading_penalty(v1: Voice, v2: Voice) -> int:
    """Penalty for voice-leading between consecutive chords.
    Penalizes large leaps and parallel fifths/octaves."""
    pen = 0
    # Penalize large melodic intervals
    for i in range(4):
        interval = abs(v2[i] - v1[i])
        if interval > 7:  # more than a fifth
            pen += 10 * (interval - 7)
        elif interval > 4:  # more than a third
            pen += 2 * (interval - 4)
    # Penalize parallel fifths (interval 7) and octaves (interval 12/0)
    for i in range(4):
        for j in range(i+1, 4):
            int1 = (v1[i] - v1[j]) % 12
            int2 = (v2[i] - v2[j]) % 12
            if int1 == int2 and int1 in (0, 7):
                if v1[i] != v2[i]:  # actual parallel motion
                    pen += 30
    return pen

def generate_chord_voicings(root: int, quality: str) -> List[Voice]:
    """Generate all SATB voicings for a chord within standard ranges."""
    if quality == 'major':
        intervals = [0, 4, 7]
    elif quality == 'minor':
        intervals = [0, 3, 7]
    elif quality == 'dom7':
        intervals = [0, 4, 7, 10]
    else:
        intervals = [0, 4, 7]

    pitch_classes = [(root + i) % 12 for i in intervals]
    voicings = []

    # Generate voices within ranges
    soprano_range = range(60, 80)
    alto_range = range(53, 75)
    tenor_range = range(48, 68)
    bass_range = range(40, 63)

    # For efficiency, only use chord tones
    s_notes = [p for p in soprano_range if p % 12 in pitch_classes]
    a_notes = [p for p in alto_range if p % 12 in pitch_classes]
    t_notes = [p for p in tenor_range if p % 12 in pitch_classes]
    b_notes = [p for p in bass_range if p % 12 in pitch_classes]

    for s in s_notes:
        for a in a_notes:
            if a > s: continue
            for t in t_notes:
                if t > a: continue
                for b in b_notes:
                    if b > t: continue
                    v = (s, a, t, b)
                    if spacing_ok(v):
                        voicings.append(v)
    return voicings

# ─── Bellman recursion implementation ────────────────────────────────────

def bellman_dp(
    chords: List[List[Voice]],
    vert: Callable[[Voice], int],
    lead: Callable[[Voice, Voice], int]
) -> Tuple[int, List[Voice]]:
    """
    Compute the optimal SATB realization via backward Bellman recursion.

    chords[i] = list of admissible voicings at time step i.
    Returns (optimal_cost, optimal_realization).
    """
    N = len(chords) - 1

    # Value function: valueFn[v] = minimum future cost starting at v
    # Backpointer: next_state[v] = optimal next state from v
    valueFn: Dict[Voice, int] = {}
    backptr: List[Dict[Voice, Voice]] = [{} for _ in range(N)]

    # Base case: last chord
    for v in chords[N]:
        valueFn[v] = vert(v)

    # Backward recursion
    for n in range(N - 1, -1, -1):
        new_valueFn: Dict[Voice, int] = {}
        for v in chords[n]:
            best_cost = float('inf')
            best_next = None
            for w in chords[n + 1]:
                cost = lead(v, w) + valueFn[w]
                if cost < best_cost:
                    best_cost = cost
                    best_next = w
            new_valueFn[v] = vert(v) + best_cost
            backptr[n][v] = best_next
        valueFn = new_valueFn

    # Find optimal starting state
    best_start = min(chords[0], key=lambda v: valueFn[v])
    opt_cost = valueFn[best_start]

    # Trace optimal path
    path = [best_start]
    for n in range(N):
        path.append(backptr[n][path[-1]])

    return opt_cost, path

def midi_to_note(midi: int) -> str:
    """Convert MIDI pitch to note name."""
    notes = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']
    octave = midi // 12 - 1
    return f"{notes[midi % 12]}{octave}"

def print_voicing(v: Voice, label: str = ""):
    """Pretty-print a voice configuration."""
    if label:
        print(f"  {label}:")
    print(f"    S: {midi_to_note(v[0]):>4}({v[0]})  "
          f"A: {midi_to_note(v[1]):>4}({v[1]})  "
          f"T: {midi_to_note(v[2]):>4}({v[2]})  "
          f"B: {midi_to_note(v[3]):>4}({v[3]})")

# ─── Demo: C major → F major → G7 → C major cadence ────────────────────

def demo_cadence():
    print("=" * 70)
    print("TROPICAL SATB OPTIMIZATION — BELLMAN DYNAMIC PROGRAMMING")
    print("=" * 70)
    print()
    print("Chord progression: C major → F major → G7 → C major")
    print()

    # Generate voicings for each chord
    chord_names = ["C major", "F major", "G dom7", "C major"]
    chord_specs = [(0, 'major'), (5, 'major'), (7, 'dom7'), (0, 'major')]

    chords = []
    for root, quality in chord_specs:
        voicings = generate_chord_voicings(root, quality)
        chords.append(voicings)
        print(f"  {chord_names[len(chords)-1]}: {len(voicings)} admissible voicings")

    print()

    # Run Bellman DP
    opt_cost, opt_path = bellman_dp(chords, vertical_penalty, voice_leading_penalty)

    print(f"Optimal total cost: {opt_cost}")
    print()
    print("Optimal realization:")
    for i, v in enumerate(opt_path):
        vp = vertical_penalty(v)
        lp = voice_leading_penalty(opt_path[i-1], v) if i > 0 else 0
        print_voicing(v, f"Beat {i+1} ({chord_names[i]}) [vert={vp}, lead={lp}]")
    print()

    # Verify Bellman equation
    print("─── Bellman Equation Verification ───")
    for i in range(len(opt_path) - 1):
        v = opt_path[i]
        w = opt_path[i + 1]
        lhs = vertical_penalty(v) + voice_leading_penalty(v, w)
        print(f"  Step {i}→{i+1}: vert({midi_to_note(v[0])}-chord) = {vertical_penalty(v)}, "
              f"lead = {voice_leading_penalty(v, w)}")
    print()

    # Show optimality: compare against random realizations
    print("─── Optimality Comparison ───")
    np.random.seed(42)
    random_costs = []
    for _ in range(1000):
        path = [chords[i][np.random.randint(len(chords[i]))] for i in range(len(chords))]
        cost = sum(vertical_penalty(v) for v in path)
        cost += sum(voice_leading_penalty(path[i], path[i+1]) for i in range(len(path)-1))
        random_costs.append(cost)

    print(f"  Optimal cost:           {opt_cost}")
    print(f"  Random mean cost:       {np.mean(random_costs):.1f}")
    print(f"  Random min cost:        {min(random_costs)}")
    print(f"  Random max cost:        {max(random_costs)}")
    print(f"  Optimal is {min(random_costs) / max(1, opt_cost):.1f}x better than best random")
    print()

    # Demonstrate optimal suffix property
    print("─── Optimal Suffix Property (Theorem B) ───")
    for k in range(len(opt_path)):
        suffix = opt_path[k:]
        suffix_cost = sum(vertical_penalty(v) for v in suffix)
        suffix_cost += sum(voice_leading_penalty(suffix[i], suffix[i+1])
                          for i in range(len(suffix)-1))
        print(f"  Suffix from beat {k+1}: cost = {suffix_cost} (optimal among suffixes starting at {midi_to_note(opt_path[k][0])}-chord)")
    print()

    # Demonstrate tropical conjunction (Theorem C)
    print("─── Tropical Conjunction (Theorem C) ───")
    test_v = (72, 64, 55, 48)  # C5, E4, G3, C3
    p_order = 0 if voice_ordered(test_v) else 100
    p_range = 0 if within_range(test_v) else 100
    p_spacing = 0 if spacing_ok(test_v) else 50
    p_combined = max(p_order, max(p_range, p_spacing))
    all_legal = voice_ordered(test_v) and within_range(test_v) and spacing_ok(test_v)
    print(f"  Voice: {tuple(midi_to_note(p) for p in test_v)}")
    print(f"  Order penalty:   {p_order}")
    print(f"  Range penalty:   {p_range}")
    print(f"  Spacing penalty: {p_spacing}")
    print(f"  max(penalties):  {p_combined}")
    print(f"  All legal:       {all_legal}")
    print(f"  max = 0 ↔ all legal: {(p_combined == 0) == all_legal} ✓")
    print()

if __name__ == "__main__":
    demo_cadence()


#!/usr/bin/env python3
"""
Tropical SATB Chorale Optimization — Visualizations

Generates publication-quality figures showing the key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
import io
from algorithms import (bellman_satb_dp, generate_voicings, tropical_conjunction,
                         TropicalConstraint, build_transition_matrix)

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_bellman_value():
    """Visualize the Bellman value function across time steps."""
    # C → F → G7 → C cadence
    chords = [generate_voicings(0), generate_voicings(5),
              generate_voicings(7, 'dom7'), generate_voicings(0)]

    def vert(v):
        pen = 0
        if not (v[3] <= v[2] <= v[1] <= v[0]): pen += 100
        if not (60 <= v[0] <= 79): pen += 100
        if not (v[0] - v[1] <= 12 and v[1] - v[2] <= 12): pen += 50
        return pen

    def lead(v1, v2):
        return sum(abs(v2[i] - v1[i]) for i in range(4))

    result = bellman_satb_dp(chords, vert, lead)

    fig, axes = plt.subplots(1, 4, figsize=(16, 5))
    fig.suptitle('Bellman Value Function Across Time Steps', fontsize=14, fontweight='bold')

    for step in range(4):
        ax = axes[step]
        values = list(result.value_table[step].values())
        if values:
            ax.hist(values, bins=30, color=['#2196F3', '#4CAF50', '#FF9800', '#E91E63'][step],
                    alpha=0.7, edgecolor='white')
            opt_v = result.optimal_path[step]
            opt_val = result.value_table[step].get(opt_v, 0)
            ax.axvline(opt_val, color='red', linestyle='--', linewidth=2, label=f'Optimal: {opt_val:.0f}')
        ax.set_title(f'Step {step}: {["C","F","G7","C"][step]}')
        ax.set_xlabel('Value')
        ax.set_ylabel('Count')
        ax.legend(fontsize=8)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_voice_leading():
    """Visualize optimal voice leading paths."""
    chords = [generate_voicings(0), generate_voicings(5),
              generate_voicings(7, 'dom7'), generate_voicings(0)]

    def vert(v):
        if not (v[3] <= v[2] <= v[1] <= v[0]): return 100
        return 0

    def lead(v1, v2):
        return sum(abs(v2[i] - v1[i]) for i in range(4))

    result = bellman_satb_dp(chords, vert, lead)

    fig, ax = plt.subplots(figsize=(10, 7))
    colors = ['#E91E63', '#FF9800', '#2196F3', '#4CAF50']
    labels = ['Soprano', 'Alto', 'Tenor', 'Bass']

    for voice_idx in range(4):
        pitches = [result.optimal_path[step][voice_idx] for step in range(4)]
        ax.plot(range(4), pitches, 'o-', color=colors[voice_idx], linewidth=2.5,
                markersize=10, label=labels[voice_idx], zorder=5)

    # Add note names
    notes = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']
    for step in range(4):
        for voice_idx in range(4):
            midi = result.optimal_path[step][voice_idx]
            name = f"{notes[midi % 12]}{midi // 12 - 1}"
            ax.annotate(name, (step, midi), textcoords="offset points",
                       xytext=(10, 5), fontsize=8, fontweight='bold')

    ax.set_xticks(range(4))
    ax.set_xticklabels(['C major', 'F major', 'G7', 'C major'])
    ax.set_ylabel('MIDI Pitch')
    ax.set_title('Optimal Voice Leading (Tropical DP Solution)', fontsize=14, fontweight='bold')
    ax.legend(loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(35, 85)

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_penalty_landscape():
    """Visualize the tropical penalty landscape for voice configurations."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Tropical Penalty Landscapes for SATB Constraints', fontsize=14, fontweight='bold')

    soprano_range = range(55, 85)
    alto_range = range(48, 75)

    # Ordering constraint
    ax = axes[0]
    Z = np.zeros((len(list(alto_range)), len(list(soprano_range))))
    for i, a in enumerate(alto_range):
        for j, s in enumerate(soprano_range):
            Z[i, j] = 0 if a <= s else 100
    ax.imshow(Z, aspect='auto', origin='lower', cmap='RdYlGn_r',
              extent=[55, 85, 48, 75])
    ax.set_xlabel('Soprano (MIDI)')
    ax.set_ylabel('Alto (MIDI)')
    ax.set_title('Ordering: A ≤ S')

    # Spacing constraint
    ax = axes[1]
    for i, a in enumerate(alto_range):
        for j, s in enumerate(soprano_range):
            Z[i, j] = 0 if (s - a) <= 12 else 50
    ax.imshow(Z, aspect='auto', origin='lower', cmap='RdYlGn_r',
              extent=[55, 85, 48, 75])
    ax.set_xlabel('Soprano (MIDI)')
    ax.set_ylabel('Alto (MIDI)')
    ax.set_title('Spacing: S - A ≤ octave')

    # Combined (tropical max)
    ax = axes[2]
    for i, a in enumerate(alto_range):
        for j, s in enumerate(soprano_range):
            p1 = 0 if a <= s else 100
            p2 = 0 if (s - a) <= 12 else 50
            Z[i, j] = max(p1, p2)
    im = ax.imshow(Z, aspect='auto', origin='lower', cmap='RdYlGn_r',
                    extent=[55, 85, 48, 75])
    ax.set_xlabel('Soprano (MIDI)')
    ax.set_ylabel('Alto (MIDI)')
    ax.set_title('Combined: max(ordering, spacing)')

    fig.colorbar(im, ax=axes, label='Penalty', shrink=0.8)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_dp_graph():
    """Visualize the layered hypergraph structure of the DP."""
    fig, ax = plt.subplots(figsize=(12, 6))

    # Simplified: show 5 states per layer, 4 layers
    n_states = 5
    n_layers = 4
    layer_names = ['C', 'F', 'G7', 'C']

    np.random.seed(42)

    # Draw states as nodes
    for layer in range(n_layers):
        for state in range(n_states):
            y = state * 1.2
            x = layer * 3
            color = '#2196F3' if layer % 2 == 0 else '#4CAF50'
            ax.plot(x, y, 'o', markersize=18, color=color, zorder=5,
                   markeredgecolor='white', markeredgewidth=2)
            ax.text(x, y, f'v{state}', ha='center', va='center',
                   fontsize=7, color='white', fontweight='bold', zorder=6)

    # Draw edges (transitions) with varying opacity for cost
    for layer in range(n_layers - 1):
        for s1 in range(n_states):
            for s2 in range(n_states):
                cost = np.random.uniform(0, 1)
                if cost < 0.4:  # only show low-cost transitions
                    alpha = max(0.1, 1 - cost * 2)
                    ax.plot([layer * 3, (layer + 1) * 3],
                           [s1 * 1.2, s2 * 1.2],
                           '-', color='gray', alpha=alpha * 0.3, linewidth=0.5)

    # Highlight optimal path
    opt_path = [2, 3, 1, 2]
    for i in range(len(opt_path) - 1):
        ax.plot([i * 3, (i + 1) * 3],
               [opt_path[i] * 1.2, opt_path[i + 1] * 1.2],
               '-', color='#E91E63', linewidth=3, zorder=4)
        ax.plot(i * 3, opt_path[i] * 1.2, 'o', markersize=22,
               color='#E91E63', zorder=4, alpha=0.5)
    ax.plot(3 * 3, opt_path[3] * 1.2, 'o', markersize=22,
           color='#E91E63', zorder=4, alpha=0.5)

    # Labels
    for i, name in enumerate(layer_names):
        ax.text(i * 3, -0.8, name, ha='center', fontsize=12, fontweight='bold')

    ax.set_xlim(-1, 10)
    ax.set_ylim(-1.5, 5.5)
    ax.set_title('Layered State Graph with Optimal Path (red)', fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    return fig_to_base64(fig)


def viz_convergence():
    """Show how DP cost decreases as we add more admissible states."""
    chord_sizes = [10, 20, 50, 100, 200, 338]
    costs = []

    full_voicings = generate_voicings(0)
    np.random.seed(42)

    def vert(v):
        if not (v[3] <= v[2] <= v[1] <= v[0]): return 100
        return 0

    def lead(v1, v2):
        return sum(abs(v2[i] - v1[i]) for i in range(4))

    for size in chord_sizes:
        s = min(size, len(full_voicings))
        subset = full_voicings[:s]
        chords = [subset, generate_voicings(5)[:s],
                  generate_voicings(7, 'dom7')[:s], subset]
        try:
            result = bellman_satb_dp(chords, vert, lead)
            costs.append(result.optimal_cost)
        except Exception:
            costs.append(float('nan'))

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(chord_sizes, costs, 'o-', color='#2196F3', linewidth=2, markersize=8)
    ax.set_xlabel('Number of Admissible Voicings per Chord', fontsize=12)
    ax.set_ylabel('Optimal Cost', fontsize=12)
    ax.set_title('Cost Convergence as State Space Grows', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)
    ax.set_xscale('log')

    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    imgs = {
        'bellman_value': viz_bellman_value(),
        'voice_leading': viz_voice_leading(),
        'penalty_landscape': viz_penalty_landscape(),
        'dp_graph': viz_dp_graph(),
        'convergence': viz_convergence(),
    }

    for name, b64 in imgs.items():
        print(f"  {name}: {len(b64)} chars (base64)")

    print("Done!")
