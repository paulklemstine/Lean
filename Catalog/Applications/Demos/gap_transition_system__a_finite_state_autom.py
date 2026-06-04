#!/usr/bin/env python3
"""
Gap Transition System — Interactive Demo

Demonstrates the Gap Transition System (GTS), a finite-state automaton
for studying prime gap sequences. States are coprime residue classes
modulo a primorial M; transitions are driven by gap values.
"""

from math import gcd
from typing import List, Tuple, Set


def coprime_residues(M: int) -> List[int]:
    """Return sorted list of coprime residue classes mod M."""
    return [s for s in range(M) if gcd(s, M) == 1]


def transition(M: int, s: int, g: int) -> int:
    """GTS transition: state s with gap g → (s + g) % M."""
    return (s + g) % M


def is_admissible(M: int, s: int, g: int) -> bool:
    """Check if gap g is admissible from state s in GTS(M)."""
    return gcd(s, M) == 1 and gcd((s + g) % M, M) == 1


def admissible_gaps(M: int, s: int, max_gap: int = None) -> List[int]:
    """Return admissible gaps from state s in [1, max_gap]."""
    if max_gap is None:
        max_gap = M
    return [g for g in range(1, max_gap + 1) if is_admissible(M, s, g)]


def min_admissible_gap(M: int, s: int) -> int:
    """Return the minimum admissible gap from state s."""
    for g in range(1, M + 1):
        if is_admissible(M, s, g):
            return g
    return -1  # should not happen for valid states


def run_orbit(M: int, s: int, gaps: List[int]) -> List[int]:
    """Run the automaton from state s through a list of gaps."""
    orbit = [s]
    for g in gaps:
        s = transition(M, s, g)
        orbit.append(s)
    return orbit


def is_cycle(M: int, s: int, gaps: List[int]) -> bool:
    """Check if gaps form a cycle from state s."""
    return len(gaps) > 0 and transition_sequence(M, s, gaps) == s


def transition_sequence(M: int, s: int, gaps: List[int]) -> int:
    """Apply a sequence of gaps starting from state s."""
    for g in gaps:
        s = transition(M, s, g)
    return s


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def transition_graph(M: int) -> dict:
    """Build the transition graph: for each state, map target → list of gaps."""
    states = coprime_residues(M)
    graph = {s: {} for s in states}
    for s in states:
        for g in range(1, M + 1):
            t = transition(M, s, g)
            if gcd(t, M) == 1:
                if t not in graph[s]:
                    graph[s][t] = []
                graph[s][t].append(g)
    return graph


# === DEMO ===

if __name__ == "__main__":
    print("=" * 60)
    print("GAP TRANSITION SYSTEM — NUMERICAL DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: GTS(6)
    print("\n--- GTS(6): The Simplest Non-Trivial Case ---")
    M = 6
    states = coprime_residues(M)
    print(f"States (coprime residues mod {M}): {states}")
    print(f"Number of states: {len(states)} = φ({M})")
    for s in states:
        gaps = admissible_gaps(M, s)
        print(f"  From state {s}: admissible gaps in [1,{M}] = {gaps}")
        print(f"    min gap = {min_admissible_gap(M, s)}")

    # Demo 2: GTS(30)
    print("\n--- GTS(30): The Primorial-30 System ---")
    M = 30
    states = coprime_residues(M)
    print(f"States: {states}")
    print(f"Number of states: {len(states)} = φ({M})")

    print("\nMinimum admissible gaps from each state:")
    for s in states:
        mg = min_admissible_gap(M, s)
        t = transition(M, s, mg)
        print(f"  State {s:2d} → min gap = {mg}, reaches state {t}")

    # Demo 3: Uniform admissibility
    print(f"\n--- Uniform Admissibility Theorem ---")
    print(f"φ({M}) = {euler_totient(M)}")
    for s in states:
        count = len([g for g in range(M) if gcd((s + g) % M, M) == 1])
        print(f"  From state {s:2d}: {count} admissible gaps in [0,{M-1}]", end="")
        print(" ✓" if count == euler_totient(M) else " ✗")

    # Demo 4: Cycle sum divisibility
    print(f"\n--- Cycle Sum Divisibility ---")
    cycles = [
        (1, [6, 4, 2, 4, 2, 4, 6, 2]),   # canonical 30-cycle
        (1, [6, 24]),                       # short cycle
        (7, [4, 2, 4, 2, 4, 6, 2, 6]),    # shifted canonical
    ]
    for s, gaps in cycles:
        orbit = run_orbit(M, s, gaps)
        total = sum(gaps)
        print(f"  Start={s}, gaps={gaps}")
        print(f"    Orbit: {orbit}")
        print(f"    Sum={total}, {M}|{total}? {'✓' if total % M == 0 else '✗'}")

    # Demo 5: Forcing theorem
    print(f"\n--- Gap Forcing Analysis ---")
    print("States requiring minimum gap ≥ 6:")
    for s in states:
        mg = min_admissible_gap(M, s)
        if mg >= 6:
            blocked = [(g, (s+g)%M, gcd((s+g)%M, M)) for g in range(1, mg)]
            print(f"  State {s}: min gap = {mg}")
            for g, t, d in blocked:
                print(f"    gap {g} → residue {t}, gcd={d} (blocked)")

    # Demo 6: Prime verification
    print(f"\n--- Prime Verification ---")
    primes = [7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    print(f"First primes > 5 and their GTS(30) states:")
    for i, p in enumerate(primes):
        state = p % M
        print(f"  p={p:2d}, state={state:2d}", end="")
        if i > 0:
            gap = primes[i] - primes[i-1]
            prev_state = primes[i-1] % M
            next_state = transition(M, prev_state, gap)
            print(f"  (gap from prev = {gap}, transition {prev_state}→{next_state})", end="")
            assert next_state == state, "Transition mismatch!"
        print()

    # Demo 7: Transition graph structure
    print(f"\n--- Transition Graph Summary for GTS(30) ---")
    graph = transition_graph(M)
    for s in states:
        targets = sorted(graph[s].keys())
        print(f"  State {s:2d} → targets: {targets}")

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Gap Transition System transition graph for GTS(30).
Produces a circular layout of the 8 coprime residue states with
directed edges showing minimum admissible gaps.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from math import gcd, pi, cos, sin


def coprime_residues(M):
    return [s for s in range(M) if gcd(s, M) == 1]


def min_admissible_gap(M, s):
    for g in range(1, M + 1):
        if gcd((s + g) % M, M) == 1:
            return g
    return -1


def euler_totient(n):
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def draw_gts_graph(M, filename="gts_graph.png"):
    states = coprime_residues(M)
    n = len(states)

    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    # Circular layout
    angles = [2 * pi * i / n - pi / 2 for i in range(n)]
    radius = 3.0
    positions = {s: (radius * cos(a), radius * sin(a)) for s, a in zip(states, angles)}

    # Draw edges (minimum gap transitions)
    for s in states:
        mg = min_admissible_gap(M, s)
        t = (s + mg) % M
        x1, y1 = positions[s]
        x2, y2 = positions[t]

        # Curved arrow
        dx, dy = x2 - x1, y2 - y1
        mid_x = (x1 + x2) / 2
        mid_y = (y1 + y2) / 2

        # Add slight curve
        perp_x, perp_y = -dy * 0.15, dx * 0.15
        ctrl_x, ctrl_y = mid_x + perp_x, mid_y + perp_y

        # Shorten to not overlap with circles
        node_r = 0.35
        dist = (dx**2 + dy**2)**0.5
        if dist > 0:
            start_x = x1 + (dx / dist) * node_r
            start_y = y1 + (dy / dist) * node_r
            end_x = x2 - (dx / dist) * node_r
            end_y = y2 - (dy / dist) * node_r
        else:
            start_x, start_y = x1, y1
            end_x, end_y = x2, y2

        color = '#2196F3' if mg == 2 else '#FF9800' if mg == 4 else '#F44336'
        ax.annotate("", xy=(end_x, end_y), xytext=(start_x, start_y),
                     arrowprops=dict(arrowstyle="->", color=color, lw=2,
                                     connectionstyle=f"arc3,rad=0.15"))

        # Label with gap value
        label_x = mid_x + perp_x * 1.8
        label_y = mid_y + perp_y * 1.8
        ax.text(label_x, label_y, str(mg), fontsize=10, ha='center', va='center',
                color=color, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white', edgecolor=color, alpha=0.8))

    # Draw nodes
    for s in states:
        x, y = positions[s]
        circle = plt.Circle((x, y), node_r, color='#1a237e', ec='white', lw=2, zorder=10)
        ax.add_patch(circle)
        ax.text(x, y, str(s), fontsize=14, ha='center', va='center',
                color='white', fontweight='bold', zorder=11)

    # Legend
    legend_elements = [
        mpatches.Patch(color='#2196F3', label='Min gap = 2 (twin-prime type)'),
        mpatches.Patch(color='#FF9800', label='Min gap = 4 (cousin-prime type)'),
        mpatches.Patch(color='#F44336', label='Min gap = 6 (sexy-prime type)'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=11)

    ax.set_xlim(-4.5, 4.5)
    ax.set_ylim(-4.5, 4.5)
    ax.set_aspect('equal')
    ax.set_title(f'Gap Transition System GTS({M})\n{n} states = φ({M}) coprime residue classes',
                 fontsize=16, fontweight='bold', pad=20)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved {filename}")


def draw_forcing_profile(M, filename="forcing_profile.png"):
    states = coprime_residues(M)
    min_gaps = [min_admissible_gap(M, s) for s in states]

    fig, ax = plt.subplots(figsize=(12, 5))

    colors = ['#F44336' if mg >= 6 else '#FF9800' if mg >= 4 else '#2196F3' for mg in min_gaps]
    bars = ax.bar(range(len(states)), min_gaps, color=colors, edgecolor='white', linewidth=0.5)

    ax.set_xticks(range(len(states)))
    ax.set_xticklabels([str(s) for s in states], fontsize=11)
    ax.set_xlabel('State (coprime residue mod 30)', fontsize=13)
    ax.set_ylabel('Minimum admissible gap', fontsize=13)
    ax.set_title(f'Gap Forcing Profile of GTS({M})', fontsize=15, fontweight='bold')

    # Add value labels on bars
    for bar, mg in zip(bars, min_gaps):
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.1,
                str(mg), ha='center', va='bottom', fontsize=12, fontweight='bold')

    ax.set_ylim(0, max(min_gaps) + 1.5)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved {filename}")


if __name__ == "__main__":
    draw_gts_graph(30)
    draw_forcing_profile(30)
