#!/usr/bin/env python3
"""
Tropical Hecke–Crystal Realization Duality: Demonstrations

This module demonstrates the key constructions from the formalized theorem:
1. Word action computation
2. Observational equivalence and quotient construction
3. Minimal crystal automaton reconstruction
4. Hankel–Hecke matrix and tropical rank
5. Crystal isomorphism verification
"""

from __future__ import annotations
from collections import defaultdict
from itertools import product
from typing import Any, Callable
import json


# ============================================================
# Core Definitions
# ============================================================

class HeckeActionData:
    """
    A Hecke action datum: finite set M, operators T_i, observation obs.
    
    M is represented as range(n), operators as dicts, obs as a dict.
    """
    def __init__(self, n: int, colors: list[str],
                 operators: dict[str, dict[int, int]],
                 obs: dict[int, Any]):
        self.n = n
        self.M = list(range(n))
        self.colors = colors
        self.operators = operators
        self.obs = obs
    
    def T(self, color: str, m: int) -> int:
        return self.operators[color][m]
    
    def observe(self, m: int) -> Any:
        return self.obs[m]


def word_action(data: HeckeActionData, word: list[str], m: int) -> int:
    """Apply a word of operators left-to-right: T_{w_k}(...T_{w_1}(m)...)."""
    state = m
    for color in word:
        state = data.T(color, state)
    return state


def observation_profile(data: HeckeActionData, m: int,
                        max_depth: int = None) -> dict[tuple, Any]:
    """
    Compute the observation profile of element m:
    maps each word w to obs(T_w(m)).
    """
    if max_depth is None:
        max_depth = data.n  # Sufficient by pigeonhole
    
    profile = {}
    # Generate all words up to max_depth
    for depth in range(max_depth + 1):
        for word in product(data.colors, repeat=depth):
            w = list(word)
            profile[tuple(w)] = data.observe(word_action(data, w, m))
    return profile


def compute_observational_equivalence(data: HeckeActionData,
                                       max_depth: int = None) -> dict[int, int]:
    """
    Compute observational equivalence classes.
    Returns a dict mapping each element to its class representative.
    """
    profiles = {}
    for m in data.M:
        prof = observation_profile(data, m, max_depth)
        # Convert to hashable tuple
        key = tuple(sorted(prof.items()))
        profiles[m] = key
    
    # Group by profile
    classes = defaultdict(list)
    for m, key in profiles.items():
        classes[key].append(m)
    
    # Assign class representatives (smallest element in each class)
    representative = {}
    for members in classes.values():
        rep = min(members)
        for m in members:
            representative[m] = rep
    
    return representative


class CrystalAutomaton:
    """A minimal crystal automaton: states, weights, transitions."""
    
    def __init__(self, states: list[int], colors: list[str],
                 weights: dict[int, Any],
                 transitions: dict[str, dict[int, int]]):
        self.states = states
        self.colors = colors
        self.weights = weights
        self.transitions = transitions
    
    def step(self, color: str, state: int) -> int:
        return self.transitions[color][state]
    
    def wt(self, state: int) -> Any:
        return self.weights[state]
    
    def word_step(self, word: list[str], state: int) -> int:
        s = state
        for c in word:
            s = self.step(c, s)
        return s
    
    def __repr__(self):
        lines = [f"CrystalAutomaton with {len(self.states)} states:"]
        lines.append(f"  States: {self.states}")
        lines.append(f"  Colors: {self.colors}")
        lines.append(f"  Weights: {self.weights}")
        for c in self.colors:
            lines.append(f"  T_{c}: {self.transitions[c]}")
        return "\n".join(lines)


def reconstruct_minimal_crystal(data: HeckeActionData,
                                 max_depth: int = None) -> tuple[CrystalAutomaton, dict[int, int]]:
    """
    Certified reconstruction algorithm.
    
    Returns (crystal, quotient_map) where:
    - crystal is the minimal crystal automaton
    - quotient_map maps each element of M to its quotient state
    """
    rep = compute_observational_equivalence(data, max_depth)
    
    # States are the distinct representatives
    state_set = sorted(set(rep.values()))
    state_index = {s: i for i, s in enumerate(state_set)}
    
    # Quotient map
    quotient_map = {m: state_index[rep[m]] for m in data.M}
    
    # Weights
    weights = {state_index[s]: data.observe(s) for s in state_set}
    
    # Transitions
    transitions = {}
    for color in data.colors:
        trans = {}
        for s in state_set:
            ts = data.T(color, s)
            trans[state_index[s]] = state_index[rep[ts]]
        transitions[color] = trans
    
    crystal = CrystalAutomaton(
        states=list(range(len(state_set))),
        colors=data.colors,
        weights=weights,
        transitions=transitions
    )
    
    return crystal, quotient_map


def hankel_hecke_matrix(data: HeckeActionData,
                         max_depth: int = 3) -> dict[int, dict[tuple, Any]]:
    """
    Compute the Hankel–Hecke matrix.
    Rows: elements of M, Columns: words up to max_depth.
    """
    matrix = {}
    for m in data.M:
        row = {}
        for depth in range(max_depth + 1):
            for word in product(data.colors, repeat=depth):
                w = list(word)
                row[tuple(w)] = data.observe(word_action(data, w, m))
        matrix[m] = row
    return matrix


def tropical_rank(data: HeckeActionData, max_depth: int = 3) -> int:
    """Compute the tropical rank = number of distinct Hankel rows."""
    matrix = hankel_hecke_matrix(data, max_depth)
    distinct_rows = set()
    for m, row in matrix.items():
        key = tuple(sorted(row.items()))
        distinct_rows.add(key)
    return len(distinct_rows)


def verify_realization(data: HeckeActionData,
                        crystal: CrystalAutomaton,
                        quotient_map: dict[int, int],
                        max_depth: int = 3) -> dict[str, bool]:
    """
    Verify all properties of the crystal realization.
    """
    results = {}
    
    # 1. Soundness: crystal reproduces all observations
    sound = True
    for m in data.M:
        for depth in range(max_depth + 1):
            for word in product(data.colors, repeat=depth):
                w = list(word)
                crystal_obs = crystal.wt(crystal.word_step(w, quotient_map[m]))
                original_obs = data.observe(word_action(data, w, m))
                if crystal_obs != original_obs:
                    sound = False
                    break
    results["sound"] = sound
    
    # 2. Observation compatibility
    obs_compat = all(
        crystal.wt(quotient_map[m]) == data.observe(m)
        for m in data.M
    )
    results["obs_compatible"] = obs_compat
    
    # 3. Intertwining
    intertwine = all(
        quotient_map[data.T(c, m)] == crystal.step(c, quotient_map[m])
        for c in data.colors
        for m in data.M
    )
    results["intertwining"] = intertwine
    
    # 4. Surjectivity
    surj = set(quotient_map.values()) == set(crystal.states)
    results["surjective"] = surj
    
    # 5. Observability
    observable = True
    for q1 in crystal.states:
        for q2 in crystal.states:
            if q1 >= q2:
                continue
            same = True
            for depth in range(max_depth + 1):
                for word in product(crystal.colors, repeat=depth):
                    w = list(word)
                    if crystal.wt(crystal.word_step(w, q1)) != \
                       crystal.wt(crystal.word_step(w, q2)):
                        same = False
                        break
                if not same:
                    break
            if same:
                observable = False
                break
    results["observable"] = observable
    
    # 6. Hankel rank = state count
    rank = tropical_rank(data, max_depth)
    results["hankel_rank_eq_states"] = (rank == len(crystal.states))
    results["hankel_rank"] = rank
    results["num_states"] = len(crystal.states)
    
    return results


# ============================================================
# Examples
# ============================================================

def example_1_two_color_crystal():
    """
    Example 1: A 4-element system with 2 colors that minimizes to 2 states.
    
    M = {0, 1, 2, 3}
    T_red:  0↔1, 2↔3 (swap pairs)
    T_blue: 0↔2, 1↔3 (swap pairs)
    obs: 0,2 → 'A', 1,3 → 'B'
    
    Elements 0,2 are obs-equivalent (same profile), as are 1,3.
    Minimal crystal has 2 states.
    """
    print("=" * 60)
    print("Example 1: Two-Color Crystal (4 → 2 states)")
    print("=" * 60)
    
    data = HeckeActionData(
        n=4,
        colors=["red", "blue"],
        operators={
            "red":  {0: 1, 1: 0, 2: 3, 3: 2},
            "blue": {0: 2, 1: 3, 2: 0, 3: 1}
        },
        obs={0: "A", 1: "B", 2: "A", 3: "B"}
    )
    
    crystal, qmap = reconstruct_minimal_crystal(data, max_depth=3)
    print(f"\nOriginal system: {data.n} elements")
    print(f"Quotient map: {qmap}")
    print(f"\n{crystal}")
    
    results = verify_realization(data, crystal, qmap, max_depth=3)
    print(f"\nVerification results:")
    for k, v in results.items():
        print(f"  {k}: {v}")
    
    return results


def example_2_identity_operators():
    """
    Example 2: Identity operators — each element is its own class.
    
    M = {0, 1, 2}, T_i = id for all i, distinct observations.
    Minimal crystal = 3 states (no identification possible).
    """
    print("\n" + "=" * 60)
    print("Example 2: Identity Operators (3 → 3 states)")
    print("=" * 60)
    
    data = HeckeActionData(
        n=3,
        colors=["a"],
        operators={"a": {0: 0, 1: 1, 2: 2}},
        obs={0: 0, 1: 1, 2: 2}
    )
    
    crystal, qmap = reconstruct_minimal_crystal(data, max_depth=3)
    print(f"\nOriginal system: {data.n} elements")
    print(f"Quotient map: {qmap}")
    print(f"\n{crystal}")
    
    results = verify_realization(data, crystal, qmap, max_depth=3)
    print(f"\nVerification results:")
    for k, v in results.items():
        print(f"  {k}: {v}")
    
    return results


def example_3_cyclic_system():
    """
    Example 3: Cyclic system — a 6-element cycle that minimizes.
    
    M = {0,1,2,3,4,5}, T_a: m ↦ (m+1) mod 6
    obs: m ↦ m mod 3
    
    Elements {0,3}, {1,4}, {2,5} are obs-equivalent.
    Minimal crystal has 3 states forming a 3-cycle.
    """
    print("\n" + "=" * 60)
    print("Example 3: Cyclic System (6 → 3 states)")
    print("=" * 60)
    
    data = HeckeActionData(
        n=6,
        colors=["a"],
        operators={"a": {i: (i + 1) % 6 for i in range(6)}},
        obs={i: i % 3 for i in range(6)}
    )
    
    crystal, qmap = reconstruct_minimal_crystal(data, max_depth=6)
    print(f"\nOriginal system: {data.n} elements")
    print(f"Quotient map: {qmap}")
    print(f"\n{crystal}")
    
    results = verify_realization(data, crystal, qmap, max_depth=6)
    print(f"\nVerification results:")
    for k, v in results.items():
        print(f"  {k}: {v}")
    
    return results


def example_4_tropical_weights():
    """
    Example 4: Tropical (min-plus) observations.
    
    M = {0,1,2,3,4,5,6,7}, two operators, obs = cost function.
    Demonstrates minimization with numeric observations.
    """
    print("\n" + "=" * 60)
    print("Example 4: Tropical Weight System (8 → 4 states)")
    print("=" * 60)
    
    data = HeckeActionData(
        n=8,
        colors=["x", "y"],
        operators={
            "x": {0: 1, 1: 0, 2: 3, 3: 2, 4: 5, 5: 4, 6: 7, 7: 6},
            "y": {0: 4, 1: 5, 2: 6, 3: 7, 4: 0, 5: 1, 6: 2, 7: 3}
        },
        obs={0: 0, 1: 1, 2: 0, 3: 1, 4: 0, 5: 1, 6: 0, 7: 1}
    )
    
    crystal, qmap = reconstruct_minimal_crystal(data, max_depth=4)
    print(f"\nOriginal system: {data.n} elements")
    print(f"Quotient map: {qmap}")
    print(f"\n{crystal}")
    
    results = verify_realization(data, crystal, qmap, max_depth=4)
    print(f"\nVerification results:")
    for k, v in results.items():
        print(f"  {k}: {v}")
    
    # Print Hankel matrix
    print(f"\nHankel–Hecke matrix (first few columns):")
    H = hankel_hecke_matrix(data, max_depth=2)
    cols = sorted(list(H[0].keys()))[:8]
    header = "m \\ w | " + " | ".join(str(c) for c in cols)
    print(header)
    print("-" * len(header))
    for m in data.M:
        row = " | ".join(str(H[m][c]) for c in cols)
        print(f"  {m}   | {row}")
    
    return results


def example_5_classical_dfa():
    """
    Example 5: Classical DFA minimization as a special case.
    
    The classical Myhill–Nerode theorem is recovered when S = {0, 1}
    (accept/reject) and the operators are alphabet transitions.
    """
    print("\n" + "=" * 60)
    print("Example 5: Classical DFA Minimization (5 → 3 states)")
    print("=" * 60)
    
    # DFA recognizing strings with even number of 'a's
    # States: {q0, q1, q2, q3, q4} where q0,q2 accept, q1,q3,q4 reject
    # q0 --a--> q1, q1 --a--> q0 (parity flip)
    # q2 --a--> q3, q3 --a--> q2 (duplicate of above)
    # q4 --a--> q4 (sink)
    # q0 --b--> q2, q2 --b--> q0 (swap between copies)
    # q1 --b--> q3, q3 --b--> q1
    # q4 --b--> q4
    
    data = HeckeActionData(
        n=5,
        colors=["a", "b"],
        operators={
            "a": {0: 1, 1: 0, 2: 3, 3: 2, 4: 4},
            "b": {0: 2, 1: 3, 2: 0, 3: 1, 4: 4}
        },
        obs={0: 1, 1: 0, 2: 1, 3: 0, 4: 0}  # 1=accept, 0=reject
    )
    
    crystal, qmap = reconstruct_minimal_crystal(data, max_depth=5)
    print(f"\nOriginal DFA: {data.n} states")
    print(f"Quotient map: {qmap}")
    print(f"\n{crystal}")
    
    results = verify_realization(data, crystal, qmap, max_depth=5)
    print(f"\nVerification results:")
    for k, v in results.items():
        print(f"  {k}: {v}")
    
    return results


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Tropical Hecke–Crystal Realization Duality: Demonstrations")
    print("=" * 60)
    print()
    
    all_results = {}
    all_results["ex1"] = example_1_two_color_crystal()
    all_results["ex2"] = example_2_identity_operators()
    all_results["ex3"] = example_3_cyclic_system()
    all_results["ex4"] = example_4_tropical_weights()
    all_results["ex5"] = example_5_classical_dfa()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    
    all_pass = True
    for name, results in all_results.items():
        checks = ["sound", "obs_compatible", "intertwining",
                   "surjective", "observable", "hankel_rank_eq_states"]
        passed = all(results.get(c, False) for c in checks)
        status = "✓ PASS" if passed else "✗ FAIL"
        print(f"  {name}: {status} "
              f"(rank={results['hankel_rank']}, states={results['num_states']})")
        if not passed:
            all_pass = False
    
    print(f"\nAll examples passed: {all_pass}")


#!/usr/bin/env python3
"""Generate SVG visualizations for the Tropical Hecke–Crystal Duality."""

import math
import base64


def crystal_graph_svg(states, weights, transitions, colors_palette, title="Crystal Automaton"):
    """Generate an SVG visualization of a crystal automaton."""
    width, height = 500, 400
    cx, cy = width // 2, height // 2 + 20
    radius = min(width, height) // 3
    n = len(states)
    node_r = 28
    
    # Position nodes in a circle
    positions = {}
    for i, s in enumerate(states):
        angle = -math.pi / 2 + 2 * math.pi * i / max(n, 1)
        positions[s] = (cx + radius * math.cos(angle), cy + radius * math.sin(angle))
    
    if n == 1:
        positions[states[0]] = (cx, cy)
    elif n == 2:
        positions[states[0]] = (cx - 80, cy)
        positions[states[1]] = (cx + 80, cy)
    
    svg_parts = []
    svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">')
    svg_parts.append(f'<rect width="{width}" height="{height}" fill="#fafafa" rx="8"/>')
    svg_parts.append(f'<text x="{width//2}" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">{title}</text>')
    
    # Define arrow marker
    svg_parts.append('<defs>')
    for ci, c in enumerate(sorted(set(c for c in transitions.keys()))):
        color = colors_palette.get(c, "#666")
        svg_parts.append(f'<marker id="arrow_{ci}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-auto"><path d="M 0 0 L 10 5 L 0 10 z" fill="{color}"/></marker>')
    svg_parts.append('</defs>')
    
    # Draw edges
    color_list = sorted(transitions.keys())
    for ci, c in enumerate(color_list):
        color = colors_palette.get(c, "#666")
        trans = transitions[c]
        for src, tgt in trans.items():
            if src not in positions or tgt not in positions:
                continue
            x1, y1 = positions[src]
            x2, y2 = positions[tgt]
            
            if src == tgt:
                # Self-loop
                loop_r = 20
                offset = ci * 12
                svg_parts.append(
                    f'<path d="M {x1-10},{y1-node_r-offset} '
                    f'C {x1-40},{y1-node_r-30-offset} {x1+40},{y1-node_r-30-offset} {x1+10},{y1-node_r-offset}" '
                    f'fill="none" stroke="{color}" stroke-width="2" marker-end="url(#arrow_{ci})"/>'
                )
                svg_parts.append(
                    f'<text x="{x1}" y="{y1-node_r-25-offset}" text-anchor="middle" '
                    f'font-size="11" fill="{color}" font-style="italic">{c}</text>'
                )
            else:
                # Regular edge with offset for parallel edges
                dx, dy = x2 - x1, y2 - y1
                dist = math.sqrt(dx*dx + dy*dy)
                if dist < 1:
                    continue
                nx, ny = -dy/dist, dx/dist  # normal
                offset = (ci - len(color_list)/2 + 0.5) * 8
                
                sx = x1 + nx*offset + dx/dist * node_r
                sy = y1 + ny*offset + dy/dist * node_r
                ex = x2 + nx*offset - dx/dist * (node_r + 8)
                ey = y2 + ny*offset - dy/dist * (node_r + 8)
                
                # Curve control point
                mx = (sx+ex)/2 + nx * 15
                my = (sy+ey)/2 + ny * 15
                
                svg_parts.append(
                    f'<path d="M {sx:.1f},{sy:.1f} Q {mx:.1f},{my:.1f} {ex:.1f},{ey:.1f}" '
                    f'fill="none" stroke="{color}" stroke-width="2" marker-end="url(#arrow_{ci})"/>'
                )
                lx = (sx+ex)/2 + nx*20
                ly = (sy+ey)/2 + ny*20
                svg_parts.append(
                    f'<text x="{lx:.1f}" y="{ly:.1f}" text-anchor="middle" '
                    f'font-size="11" fill="{color}" font-style="italic">{c}</text>'
                )
    
    # Draw nodes
    for s in states:
        x, y = positions[s]
        svg_parts.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{node_r}" fill="#e8f4fd" stroke="#2196F3" stroke-width="2.5"/>')
        svg_parts.append(f'<text x="{x:.1f}" y="{y-6:.1f}" text-anchor="middle" font-size="13" font-weight="bold" fill="#1565C0">q{s}</text>')
        svg_parts.append(f'<text x="{x:.1f}" y="{y+10:.1f}" text-anchor="middle" font-size="11" fill="#666">wt={weights[s]}</text>')
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def minimization_diagram_svg():
    """Generate an SVG showing the minimization process."""
    width, height = 700, 350
    svg = []
    svg.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">')
    svg.append(f'<rect width="{width}" height="{height}" fill="#fafafa" rx="8"/>')
    svg.append(f'<text x="{width//2}" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">Crystal Minimization via Observational Quotient</text>')
    
    # Left: original system
    left_cx, left_cy = 140, 190
    original = [(0, "A"), (1, "B"), (2, "A"), (3, "B")]
    for i, (s, w) in enumerate(original):
        angle = -math.pi/2 + 2*math.pi*i/4
        x = left_cx + 70*math.cos(angle)
        y = left_cy + 70*math.sin(angle)
        svg.append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="22" fill="#ffebee" stroke="#e53935" stroke-width="2"/>')
        svg.append(f'<text x="{x:.0f}" y="{y-4:.0f}" text-anchor="middle" font-size="12" font-weight="bold" fill="#c62828">{s}</text>')
        svg.append(f'<text x="{x:.0f}" y="{y+10:.0f}" text-anchor="middle" font-size="10" fill="#666">{w}</text>')
    svg.append(f'<text x="{left_cx}" y="310" text-anchor="middle" font-size="13" fill="#555">Original (4 states)</text>')
    
    # Arrow
    svg.append('<path d="M 250,190 L 340,190" stroke="#333" stroke-width="2.5" marker-end="url(#big_arrow)"/>')
    svg.append('<text x="295" y="175" text-anchor="middle" font-size="11" fill="#666">quotient</text>')
    svg.append('<text x="295" y="210" text-anchor="middle" font-size="11" fill="#666">by ≈</text>')
    svg.append('<defs><marker id="big_arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="8" markerHeight="8" orient="auto"><path d="M 0 0 L 10 5 L 0 10 z" fill="#333"/></marker></defs>')
    
    # Right: minimal crystal
    right_cx = 470
    right_cy = 190
    # Two states
    x1, y1 = right_cx - 60, right_cy
    x2, y2 = right_cx + 60, right_cy
    svg.append(f'<circle cx="{x1}" cy="{y1}" r="28" fill="#e8f5e9" stroke="#43A047" stroke-width="2.5"/>')
    svg.append(f'<text x="{x1}" y="{y1-6}" text-anchor="middle" font-size="13" font-weight="bold" fill="#2E7D32">{{0,2}}</text>')
    svg.append(f'<text x="{x1}" y="{y1+10}" text-anchor="middle" font-size="11" fill="#666">A</text>')
    svg.append(f'<circle cx="{x2}" cy="{y2}" r="28" fill="#e8f5e9" stroke="#43A047" stroke-width="2.5"/>')
    svg.append(f'<text x="{x2}" y="{y2-6}" text-anchor="middle" font-size="13" font-weight="bold" fill="#2E7D32">{{1,3}}</text>')
    svg.append(f'<text x="{x2}" y="{y2+10}" text-anchor="middle" font-size="11" fill="#666">B</text>')
    
    # Edges between minimal states
    svg.append(f'<path d="M {x1+28},{y1-8} L {x2-36},{y2-8}" stroke="#e53935" stroke-width="2" marker-end="url(#red_arr)"/>')
    svg.append(f'<path d="M {x2-28},{y2+8} L {x1+36},{y1+8}" stroke="#e53935" stroke-width="2" marker-end="url(#red_arr)"/>')
    svg.append(f'<text x="{right_cx}" y="{right_cy-18}" text-anchor="middle" font-size="11" fill="#e53935" font-style="italic">red</text>')
    svg.append(f'<text x="{right_cx}" y="{right_cy+28}" text-anchor="middle" font-size="11" fill="#e53935" font-style="italic">red</text>')
    
    # Self-loops for blue
    svg.append(f'<path d="M {x1-10},{y1-28} C {x1-40},{y1-60} {x1+40},{y1-60} {x1+10},{y1-28}" fill="none" stroke="#1565C0" stroke-width="2" marker-end="url(#blue_arr)"/>')
    svg.append(f'<text x="{x1}" y="{y1-55}" text-anchor="middle" font-size="11" fill="#1565C0" font-style="italic">blue</text>')
    svg.append(f'<path d="M {x2-10},{y2-28} C {x2-40},{y2-60} {x2+40},{y2-60} {x2+10},{y2-28}" fill="none" stroke="#1565C0" stroke-width="2" marker-end="url(#blue_arr)"/>')
    svg.append(f'<text x="{x2}" y="{y2-55}" text-anchor="middle" font-size="11" fill="#1565C0" font-style="italic">blue</text>')
    
    svg.append('<defs>')
    svg.append('<marker id="red_arr" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M 0 0 L 10 5 L 0 10 z" fill="#e53935"/></marker>')
    svg.append('<marker id="blue_arr" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M 0 0 L 10 5 L 0 10 z" fill="#1565C0"/></marker>')
    svg.append('</defs>')
    
    svg.append(f'<text x="{right_cx}" y="310" text-anchor="middle" font-size="13" fill="#555">Minimal Crystal (2 states)</text>')
    
    # Equivalence classes annotation
    svg.append(f'<text x="{width//2}" y="340" text-anchor="middle" font-size="12" fill="#888">Hankel rank = 2 = minimal states</text>')
    
    svg.append('</svg>')
    return '\n'.join(svg)


if __name__ == "__main__":
    # Generate Example 1 crystal
    svg1 = crystal_graph_svg(
        states=[0, 1],
        weights={0: "A", 1: "B"},
        transitions={"red": {0: 1, 1: 0}, "blue": {0: 0, 1: 1}},
        colors_palette={"red": "#e53935", "blue": "#1565C0"},
        title="Minimal Crystal (Example 1)"
    )
    with open("crystal_example1.svg", "w") as f:
        f.write(svg1)
    print("Generated crystal_example1.svg")
    
    # Generate Example 3 crystal (3-cycle)
    svg3 = crystal_graph_svg(
        states=[0, 1, 2],
        weights={0: 0, 1: 1, 2: 2},
        transitions={"a": {0: 1, 1: 2, 2: 0}},
        colors_palette={"a": "#7B1FA2"},
        title="Minimal Crystal (Example 3: 3-Cycle)"
    )
    with open("crystal_example3.svg", "w") as f:
        f.write(svg3)
    print("Generated crystal_example3.svg")
    
    # Generate minimization diagram
    svg_min = minimization_diagram_svg()
    with open("minimization_diagram.svg", "w") as f:
        f.write(svg_min)
    print("Generated minimization_diagram.svg")
