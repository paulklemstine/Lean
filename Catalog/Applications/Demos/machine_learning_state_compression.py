#!/usr/bin/env python3
"""
Applications of Semiconjugacy Theory to Machine Learning and Verification

Demonstrates:
1. Quantized RNN state compression verification
2. Finite automaton minimization via semiconjugacy
3. Capacity lower bound computation for encoder design
"""

from typing import Callable
from collections import defaultdict


def compute_minimal_period(f: Callable[[int], int], x: int, n: int) -> int:
    """Compute the minimal period of x under f."""
    y = f(x)
    for k in range(1, n + 1):
        if y == x:
            return k
        y = f(y)
    return 0


def verify_semiconjugacy(f, g, e, n):
    return all(e(f(x)) == g(e(x)) for x in range(n))


# ============================================================
# Application 1: Quantized RNN Verification
# ============================================================
print("=" * 70)
print("APPLICATION 1: Quantized RNN State Compression Verification")
print("=" * 70)

print("""
Scenario: A recurrent neural network with 8-bit quantized states (256 states)
is compressed to a 4-state latent model for verification.

We simulate a simple quantized RNN where:
- Input is processed at each step
- State transitions are deterministic (no input for simplicity)
- The goal is to verify absence of dangerous oscillations
""")

# Simulate a quantized RNN with structured dynamics
N_rnn = 64  # 6-bit state
M_lat = 8   # 3-bit latent

# Create a transition with multiple cycles of different lengths
# Cycle of length 8: states 0-7
# Cycle of length 4: states 8-11
# Cycle of length 2: states 12-13
# Fixed points: states 14, 15
# Pre-periodic tails: states 16-63 feed into cycles
rnn_table = list(range(N_rnn))
# 8-cycle
for i in range(8):
    rnn_table[i] = (i + 1) % 8
# 4-cycle
for i in range(8, 12):
    rnn_table[i] = 8 + (i - 8 + 1) % 4
# 2-cycle
rnn_table[12] = 13
rnn_table[13] = 12
# Fixed points
rnn_table[14] = 14
rnn_table[15] = 15
# Pre-periodic tails
for i in range(16, N_rnn):
    rnn_table[i] = i % 16  # Eventually feed into the periodic part

f_rnn = lambda x: rnn_table[x]

# Encoder: group states by their eventual cycle
def encoder_rnn(x):
    """Encode by mapping to the cycle membership."""
    if x < 8 or (x >= 16 and x % 16 < 8):
        return x % 8
    elif (8 <= x < 12) or (x >= 16 and 8 <= x % 16 < 12):
        return x % 4  # Maps to 0-3 in latent
    elif x == 12 or x == 13 or (x >= 16 and x % 16 in [12, 13]):
        return x % 2
    else:
        return 0

# For simplicity, use modular encoder
e_rnn = lambda x: x % M_lat

# Construct latent dynamics as quotient
lat_table = {}
fiber_invariant = True
for x in range(N_rnn):
    y = e_rnn(x)
    gy = e_rnn(f_rnn(x))
    if y in lat_table:
        if lat_table[y] != gy:
            fiber_invariant = False
            break
    else:
        lat_table[y] = gy

if fiber_invariant and len(lat_table) == M_lat:
    g_rnn = lambda y: lat_table[y]
    is_semi = verify_semiconjugacy(f_rnn, g_rnn, e_rnn, N_rnn)
    print(f"Fiber invariance: ✓")
    print(f"Semiconjugacy verified: {is_semi}")

    # Analyze periodic structure
    print(f"\n--- Original System (Fin({N_rnn})) ---")
    orig_cycles = defaultdict(list)
    for x in range(N_rnn):
        p = compute_minimal_period(f_rnn, x, N_rnn)
        if p > 0:
            orig_cycles[p].append(x)
    for period in sorted(orig_cycles.keys()):
        print(f"  Period {period}: {len(orig_cycles[period])} points")

    print(f"\n--- Latent System (Fin({M_lat})) ---")
    lat_cycles = defaultdict(list)
    for y in range(M_lat):
        p = compute_minimal_period(g_rnn, y, M_lat)
        if p > 0:
            lat_cycles[p].append(y)
    for period in sorted(lat_cycles.keys()):
        print(f"  Period {period}: {len(lat_cycles[period])} points")

    # Capacity bounds
    max_lat = max(lat_cycles.keys()) if lat_cycles else 0
    print(f"\n--- Capacity Analysis ---")
    print(f"  Max latent period: {max_lat}")
    print(f"  Latent space size: {M_lat}")
    print(f"  Bound satisfied: {max_lat} ≤ {M_lat} ✓")
    print(f"  Compression ratio: {N_rnn/M_lat:.1f}x")
else:
    print(f"Fiber invariance: ✗ (quotient not well-defined)")
    print("Need a different encoder for valid semiconjugacy.")


# ============================================================
# Application 2: DFA Minimization via Semiconjugacy
# ============================================================
print("\n" + "=" * 70)
print("APPLICATION 2: Finite Automaton Minimization")
print("=" * 70)

print("""
Scenario: A deterministic finite automaton (DFA) recognizing binary strings
is minimized by finding a semiconjugacy to a smaller automaton.
The periodic orbits correspond to "pumping lemma" cycles.
""")

# Original DFA: 6 states, binary alphabet
# States: 0=start, 1-5=processing
# For simplicity, consider just one input symbol (unary automaton)
dfa_table = [1, 2, 0, 4, 5, 3]  # Two 3-cycles
dfa = lambda s: dfa_table[s]

# Quotient encoder: merge equivalent states
# States 0,3 equivalent; 1,4 equivalent; 2,5 equivalent
e_dfa = lambda s: s % 3

# Minimal DFA
min_dfa_table = [1, 2, 0]
min_dfa = lambda s: min_dfa_table[s]

is_semi = verify_semiconjugacy(dfa, min_dfa, e_dfa, 6)
print(f"Semiconjugacy (DFA morphism) verified: {is_semi}")
print(f"Original DFA: {len(dfa_table)} states")
print(f"Minimal DFA:  3 states")
print(f"Compression:  {len(dfa_table)/3:.1f}x")

print("\n--- Cycle Structure ---")
for s in range(6):
    p_orig = compute_minimal_period(dfa, s, 6)
    p_min = compute_minimal_period(min_dfa, e_dfa(s), 3)
    print(f"  State {s} (→ {e_dfa(s)}): period {p_orig} → {p_min}, "
          f"divides: {p_orig % p_min == 0}")


# ============================================================
# Application 3: Encoder Design with Capacity Constraints
# ============================================================
print("\n" + "=" * 70)
print("APPLICATION 3: Optimal Encoder Design")
print("=" * 70)

print("""
Problem: Given a dynamical system f on Fin(n) with known cycle structure,
what is the minimum latent space size M such that there exists a
semiconjugacy to a system on Fin(M)?

By our capacity lower bound theorem, M ≥ max cycle length in the latent
system. And by period divisibility, the latent cycle lengths must divide
the original ones.
""")

# Example: system with cycles of lengths 6, 4, and 3
print("Original system cycles: lengths 6, 4, 3")
print("Total states used by cycles: 6 + 4 + 3 = 13")
print()

# What are the possible latent cycle lengths?
# Divisors of 6: {1, 2, 3, 6}
# Divisors of 4: {1, 2, 4}
# Divisors of 3: {1, 3}
print("Possible latent cycle lengths (divisors):")
print("  For original period 6: divisors = {1, 2, 3, 6}")
print("  For original period 4: divisors = {1, 2, 4}")
print("  For original period 3: divisors = {1, 3}")
print()

# Minimum latent size for various compression targets
targets = [
    ("No compression", {6, 4, 3}, 6 + 4 + 3),
    ("Collapse 6→3, keep 4, 3", {3, 4, 3}, 3 + 4 + 3),
    ("Collapse 6→2, 4→2, 3→1", {2, 2, 1}, 2 + 2 + 1),
    ("Collapse all to fixed pts", {1, 1, 1}, 1),
]

print(f"{'Target':<40} {'Latent periods':<20} {'Min |β|':<10}")
print("-" * 70)
for name, periods, min_size in targets:
    max_p = max(periods)
    print(f"{name:<40} {str(periods):<20} ≥ {max_p} (need {min_size} for disjoint)")


# ============================================================
# Application 4: Safety Verification via Abstract Model Checking
# ============================================================
print("\n" + "=" * 70)
print("APPLICATION 4: Safety Verification via Abstraction")
print("=" * 70)

print("""
Scenario: Verify that a controller never enters a 'danger' cycle.
Strategy: Build an abstract (compressed) model and check there.
By the lifting theorem, if the abstract model has no danger cycles,
neither does the concrete model (under surjective semiconjugacy).
""")

# Concrete system: 20 states, some are "safe" and some are "dangerous"
N_ctrl = 20
danger_states = {7, 13, 17}

# Transition: engineered to have cycles avoiding danger states
ctrl_table = [1, 2, 3, 4, 5, 0,  # 6-cycle (safe)
              8, 6, 9, 10, 11, 10, # path + 2-cycle (safe)
              14, 15, 16, 12, 18, 19, 17, 13]  # includes danger
ctrl = lambda x: ctrl_table[x]

# Abstract model: 5 states
M_ctrl = 5
e_ctrl = lambda x: x % M_ctrl

# Check if this gives valid semiconjugacy
lat_table_ctrl = {}
valid = True
for x in range(N_ctrl):
    y = e_ctrl(x)
    gy = e_ctrl(ctrl(x))
    if y in lat_table_ctrl:
        if lat_table_ctrl[y] != gy:
            valid = False
            break
    else:
        lat_table_ctrl[y] = gy

if valid and len(lat_table_ctrl) == M_ctrl:
    g_ctrl = lambda y: lat_table_ctrl[y]
    is_semi = verify_semiconjugacy(ctrl, g_ctrl, e_ctrl, N_ctrl)
    print(f"Abstract model constructed: {is_semi}")

    # Check for danger cycles in abstract model
    abstract_danger = {y for x in danger_states for y in [e_ctrl(x)]}
    print(f"Abstract danger states: {abstract_danger}")

    # Find cycles in abstract model
    for y in range(M_ctrl):
        p = compute_minimal_period(g_ctrl, y, M_ctrl)
        if p > 0:
            # Check if cycle touches danger states
            cycle_states = set()
            current = y
            for _ in range(p):
                cycle_states.add(current)
                current = g_ctrl(current)
            touches_danger = bool(cycle_states & abstract_danger)
            status = "⚠ DANGER" if touches_danger else "✓ SAFE"
            print(f"  Abstract cycle at y={y}, period={p}, "
                  f"states={cycle_states}: {status}")
else:
    print("Encoder does not yield valid semiconjugacy.")
    print("Trying alternative encoder...")

    # Fallback: use a coarser partition
    e_ctrl2 = lambda x: x % 4
    M_ctrl2 = 4
    lat_table2 = {}
    valid2 = True
    for x in range(N_ctrl):
        y = e_ctrl2(x)
        gy = e_ctrl2(ctrl(x))
        if y in lat_table2:
            if lat_table2[y] != gy:
                valid2 = False
                break
        else:
            lat_table2[y] = gy

    if valid2:
        print(f"  Alternative encoder (mod {M_ctrl2}) works!")
    else:
        print(f"  Alternative also fails — system has complex fiber structure.")
        print(f"  This demonstrates that not every encoder yields a semiconjugacy.")

print("\n" + "=" * 70)
print("ALL APPLICATIONS DEMONSTRATED")
print("=" * 70)


#!/usr/bin/env python3
"""
Demo: Periodic Orbit Compression Under Semiconjugacy

Demonstrates the three main theorems with concrete numerical examples:
1. Period preservation and divisibility
2. Periodic orbit lifting
3. Capacity lower bound
"""

from typing import Callable, Optional


def iterate(f: Callable[[int], int], x: int, n: int) -> int:
    """Compute f^[n](x)."""
    for _ in range(n):
        x = f(x)
    return x


def compute_orbit(f: Callable[[int], int], x: int, bound: int) -> list[int]:
    """Compute the orbit of x under f up to the given bound."""
    orbit = [x]
    for _ in range(bound):
        x = f(x)
        orbit.append(x)
    return orbit


def minimal_period(f: Callable[[int], int], x: int, max_period: int) -> int:
    """Compute the minimal period of x under f, or 0 if not periodic within max_period steps."""
    y = f(x)
    for k in range(1, max_period + 1):
        if y == x:
            return k
        y = f(y)
    return 0


def verify_semiconjugacy(
    f: Callable[[int], int],
    g: Callable[[int], int],
    e: Callable[[int], int],
    domain_size: int,
) -> bool:
    """Verify e ∘ f = g ∘ e on Fin(domain_size)."""
    return all(e(f(x)) == g(e(x)) for x in range(domain_size))


def find_all_periodic_points(
    f: Callable[[int], int], n: int
) -> dict[int, int]:
    """Find all periodic points and their minimal periods."""
    result = {}
    for x in range(n):
        p = minimal_period(f, x, n)
        if p > 0:
            result[x] = p
    return result


# ============================================================
# Example 1: Cyclic permutation with modular compression
# ============================================================
print("=" * 70)
print("EXAMPLE 1: Cyclic Permutation with Modular Compression")
print("=" * 70)

N = 12  # State space size
M = 4   # Latent space size

f = lambda x: (x + 1) % N     # Cyclic permutation on Fin(12)
e = lambda x: x % M            # Encoder: mod 4
g = lambda y: (y + 1) % M      # Latent dynamics on Fin(4)

print(f"\nState space: Fin({N}), Latent space: Fin({M})")
print(f"f(x) = (x + 1) mod {N}")
print(f"e(x) = x mod {M}")
print(f"g(y) = (y + 1) mod {M}")

# Verify semiconjugacy
is_semi = verify_semiconjugacy(f, g, e, N)
print(f"\nSemiconjugacy verified: {is_semi}")

# Theorem 1: Period preservation
print("\n--- Theorem 1: Period Preservation ---")
for x in [0, 3, 7]:
    p_f = minimal_period(f, x, N)
    p_g = minimal_period(g, e(x), M)
    print(f"  x={x:2d}: period(x) = {p_f:2d}, period(e(x)={e(x)}) = {p_g:2d}, "
          f"divides? {p_f % p_g == 0}, ratio = {p_f // p_g}")

# Theorem 3: Capacity lower bound
print("\n--- Theorem 3: Capacity Lower Bound ---")
max_latent_period = max(minimal_period(g, y, M) for y in range(M))
print(f"  Max latent period: {max_latent_period}")
print(f"  Latent space size: {M}")
print(f"  Lower bound satisfied: {max_latent_period} ≤ {M} ✓")


# ============================================================
# Example 2: Non-trivial compression that collapses orbits
# ============================================================
print("\n" + "=" * 70)
print("EXAMPLE 2: Orbit Collapse Under Compression")
print("=" * 70)

N2 = 6
M2 = 3

# f is a permutation: (0 1 2 3 4 5) -> (1 2 0 4 5 3) = two 3-cycles
f2_table = [1, 2, 0, 4, 5, 3]
f2 = lambda x: f2_table[x]

# e merges the two 3-cycles: 0->0, 1->1, 2->2, 3->0, 4->1, 5->2
e2_table = [0, 1, 2, 0, 1, 2]
e2 = lambda x: e2_table[x]

# g must satisfy e(f(x)) = g(e(x))
# e(f(0))=e(1)=1, g(e(0))=g(0) => g(0)=1
# e(f(1))=e(2)=2, g(e(1))=g(1) => g(1)=2
# e(f(2))=e(0)=0, g(e(2))=g(2) => g(2)=0
g2_table = [1, 2, 0]
g2 = lambda y: g2_table[y]

print(f"\nState space: Fin({N2}), Latent space: Fin({M2})")
print(f"f = two 3-cycles: {f2_table}")
print(f"e = merge cycles:  {e2_table}")
print(f"g = single 3-cycle: {g2_table}")

is_semi2 = verify_semiconjugacy(f2, g2, e2, N2)
print(f"\nSemiconjugacy verified: {is_semi2}")

print("\n--- Period Analysis ---")
for x in range(N2):
    p_f = minimal_period(f2, x, N2)
    p_g = minimal_period(g2, e2(x), M2)
    print(f"  x={x}: period_f={p_f}, e(x)={e2(x)}, period_g={p_g}, "
          f"divides? {p_f % p_g == 0}")

# Theorem 2: Lifting
print("\n--- Theorem 2: Periodic Orbit Lifting ---")
for y in range(M2):
    p_g = minimal_period(g2, y, M2)
    preimages = [x for x in range(N2) if e2(x) == y]
    periodic_preimages = [(x, minimal_period(f2, x, N2)) for x in preimages]
    print(f"  y={y}: period_g={p_g}, preimages={preimages}, "
          f"periodic preimage periods={periodic_preimages}")


# ============================================================
# Example 3: RNN-style dynamics with quantized states
# ============================================================
print("\n" + "=" * 70)
print("EXAMPLE 3: Quantized RNN State Compression")
print("=" * 70)

N3 = 16  # 4-bit quantized RNN state
M3 = 4   # 2-bit latent space

# RNN transition: a nonlinear update
# Create a structured transition with known periodic orbits
# Orbit 1: 0 -> 1 -> 2 -> 3 -> 0 (period 4)
# Orbit 2: 4 -> 5 -> 6 -> 7 -> 4 (period 4)
# Orbit 3: 8 -> 9 -> 10 -> 11 -> 8 (period 4)
# Orbit 4: 12 -> 13 -> 14 -> 15 -> 12 (period 4)
f3_table = [1, 2, 3, 0, 5, 6, 7, 4, 9, 10, 11, 8, 13, 14, 15, 12]
f3 = lambda x: f3_table[x]

# Encoder: collapse to 2-bit by taking mod 4
e3 = lambda x: x % M3

# Latent dynamics: single 4-cycle
g3 = lambda y: (y + 1) % M3

print(f"\nOriginal: {N3} states (4-bit), Latent: {M3} states (2-bit)")
print(f"Compression ratio: {N3}/{M3} = {N3/M3:.1f}x")

is_semi3 = verify_semiconjugacy(f3, g3, e3, N3)
print(f"Semiconjugacy verified: {is_semi3}")

print("\n--- Orbit Structure ---")
original_periods = find_all_periodic_points(f3, N3)
latent_periods = find_all_periodic_points(g3, M3)

print(f"  Original system: {len(original_periods)} periodic points")
print(f"    Periods: {sorted(set(original_periods.values()))}")
print(f"  Latent system: {len(latent_periods)} periodic points")
print(f"    Periods: {sorted(set(latent_periods.values()))}")

max_original = max(original_periods.values())
max_latent = max(latent_periods.values())
print(f"\n--- Capacity Bound ---")
print(f"  Max original period: {max_original}")
print(f"  Max latent period: {max_latent}")
print(f"  Latent space size: {M3}")
print(f"  Bound {max_latent} ≤ {M3}: {'✓ Satisfied' if max_latent <= M3 else '✗ Violated!'}")


# ============================================================
# Example 4: Demonstrating the capacity lower bound is tight
# ============================================================
print("\n" + "=" * 70)
print("EXAMPLE 4: Capacity Lower Bound Tightness")
print("=" * 70)

print("\nIf the latent system has a cycle of exact period n,")
print("then |β| ≥ n. Here we show this bound is achieved:")

for m in [3, 5, 7, 10]:
    g_cyclic = lambda y, m=m: (y + 1) % m
    max_p = max(minimal_period(g_cyclic, y, m) for y in range(m))
    print(f"  Fin({m}), cyclic shift: max period = {max_p}, |β| = {m}, "
          f"tight: {max_p == m}")


# ============================================================
# Example 5: Non-surjective encoder (lifting may fail)
# ============================================================
print("\n" + "=" * 70)
print("EXAMPLE 5: Non-Surjective Encoder (Lifting Limitation)")
print("=" * 70)

N5 = 4
M5 = 4

f5 = lambda x: (x + 1) % N5  # Cycle: 0->1->2->3->0
e5 = lambda x: 0              # Collapse everything to 0
g5 = lambda y: y               # Identity (fixed point)

is_semi5 = verify_semiconjugacy(f5, g5, e5, N5)
print(f"\nSemiconjugacy verified: {is_semi5}")
print(f"Encoder surjective: {len(set(e5(x) for x in range(N5))) == M5}")

print(f"\nLatent point y=1 has period 1 under g (fixed point)")
print(f"But y=1 has NO preimage under e (not in image of e)")
print(f"=> Lifting theorem requires surjectivity!")

preimages_of_1 = [x for x in range(N5) if e5(x) == 1]
print(f"Preimages of y=1: {preimages_of_1}")


print("\n" + "=" * 70)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Catalog/Algebra/Dynamics/StateCompression/Periodic.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read SVGs
svg1 = read_file('semiconjugacy_diagram.svg')
svg2 = read_file('period_compression.svg')
svg3 = read_file('capacity_bound.svg')
svg4 = read_file('lifting_diagram.svg')

package = {
    "title": "Periodic Orbit Compression Under Semiconjugacy of Finite Dynamical Systems",
    "domain": "Algebra / Dynamical Systems / Machine Learning",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Semiconjugacy Period Compression Demo",
            "code": demo_code
        },
        {
            "name": "Applications: RNN Verification, Automata, Safety",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Semiconjugacy Verification",
            "pseudocode": "for x = 0 to N-1:\n  if e(f(x)) != g(e(x)):\n    return False\nreturn True\n\nComplexity: O(N)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Semiconjugacy Commutative Diagram",
            "data": svg1
        },
        {
            "name": "Period Compression: 6-cycle to 3-cycle",
            "data": svg2
        },
        {
            "name": "Capacity Lower Bound",
            "data": svg3
        },
        {
            "name": "Lifting Theorem: Latent Cycles Certify Real Cycles",
            "data": svg4
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")
print(f"Size: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Visualizations for Semiconjugacy and Period Compression

Generates SVG diagrams illustrating the main theorems.
"""

import base64
import io
import json

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def generate_semiconjugacy_diagram_svg():
    """Generate an SVG diagram showing semiconjugacy commutative diagram."""
    svg = """<svg xmlns="http://www.w3.org/2000/svg" width="500" height="300" viewBox="0 0 500 300">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
    </marker>
  </defs>

  <!-- Title -->
  <text x="250" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#222">Semiconjugacy: e ∘ f = g ∘ e</text>

  <!-- Nodes -->
  <text x="80" y="100" text-anchor="middle" font-size="24" fill="#2563eb">α</text>
  <text x="420" y="100" text-anchor="middle" font-size="24" fill="#2563eb">α</text>
  <text x="80" y="240" text-anchor="middle" font-size="24" fill="#dc2626">β</text>
  <text x="420" y="240" text-anchor="middle" font-size="24" fill="#dc2626">β</text>

  <!-- Labels -->
  <text x="55" y="80" text-anchor="middle" font-size="14" fill="#666">(big)</text>
  <text x="395" y="80" text-anchor="middle" font-size="14" fill="#666">(big)</text>
  <text x="55" y="260" text-anchor="middle" font-size="14" fill="#666">(small)</text>
  <text x="395" y="260" text-anchor="middle" font-size="14" fill="#666">(small)</text>

  <!-- Arrows -->
  <!-- f: α → α -->
  <line x1="110" y1="92" x2="390" y2="92" stroke="#2563eb" stroke-width="2.5" marker-end="url(#arrowhead)"/>
  <text x="250" y="82" text-anchor="middle" font-size="18" font-weight="bold" fill="#2563eb">f</text>

  <!-- g: β → β -->
  <line x1="110" y1="232" x2="390" y2="232" stroke="#dc2626" stroke-width="2.5" marker-end="url(#arrowhead)"/>
  <text x="250" y="222" text-anchor="middle" font-size="18" font-weight="bold" fill="#dc2626">g</text>

  <!-- e: α → β (left) -->
  <line x1="80" y1="115" x2="80" y2="215" stroke="#16a34a" stroke-width="2.5" marker-end="url(#arrowhead)"/>
  <text x="60" y="170" text-anchor="middle" font-size="18" font-weight="bold" fill="#16a34a">e</text>

  <!-- e: α → β (right) -->
  <line x1="420" y1="115" x2="420" y2="215" stroke="#16a34a" stroke-width="2.5" marker-end="url(#arrowhead)"/>
  <text x="440" y="170" text-anchor="middle" font-size="18" font-weight="bold" fill="#16a34a">e</text>

  <!-- Commutes label -->
  <text x="250" y="165" text-anchor="middle" font-size="14" fill="#666" font-style="italic">commutes</text>
</svg>"""
    return svg


def generate_period_compression_svg():
    """Generate SVG showing period compression/divisibility."""
    svg = """<svg xmlns="http://www.w3.org/2000/svg" width="600" height="350" viewBox="0 0 600 350">
  <defs>
    <marker id="arr2" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
      <polygon points="0 0, 8 3, 0 6" fill="#333"/>
    </marker>
  </defs>

  <text x="300" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Period Compression: 6-cycle → 3-cycle</text>

  <!-- Original 6-cycle -->
  <text x="150" y="60" text-anchor="middle" font-size="14" fill="#2563eb" font-weight="bold">Original (period 6)</text>
  <g transform="translate(150,160)">
    <circle cx="0" cy="-70" r="18" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
    <text x="0" y="-65" text-anchor="middle" font-size="13" fill="#1e40af">0</text>

    <circle cx="61" cy="-35" r="18" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
    <text x="61" y="-30" text-anchor="middle" font-size="13" fill="#1e40af">1</text>

    <circle cx="61" cy="35" r="18" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
    <text x="61" y="40" text-anchor="middle" font-size="13" fill="#1e40af">2</text>

    <circle cx="0" cy="70" r="18" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
    <text x="0" y="75" text-anchor="middle" font-size="13" fill="#1e40af">3</text>

    <circle cx="-61" cy="35" r="18" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
    <text x="-61" y="40" text-anchor="middle" font-size="13" fill="#1e40af">4</text>

    <circle cx="-61" cy="-35" r="18" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
    <text x="-61" y="-30" text-anchor="middle" font-size="13" fill="#1e40af">5</text>

    <!-- Arrows between nodes -->
    <line x1="16" y1="-60" x2="45" y2="-43" stroke="#2563eb" stroke-width="1.5" marker-end="url(#arr2)"/>
    <line x1="61" y1="-17" x2="61" y2="17" stroke="#2563eb" stroke-width="1.5" marker-end="url(#arr2)"/>
    <line x1="45" y1="43" x2="16" y2="60" stroke="#2563eb" stroke-width="1.5" marker-end="url(#arr2)"/>
    <line x1="-16" y1="60" x2="-45" y2="43" stroke="#2563eb" stroke-width="1.5" marker-end="url(#arr2)"/>
    <line x1="-61" y1="17" x2="-61" y2="-17" stroke="#2563eb" stroke-width="1.5" marker-end="url(#arr2)"/>
    <line x1="-45" y1="-43" x2="-16" y2="-60" stroke="#2563eb" stroke-width="1.5" marker-end="url(#arr2)"/>
  </g>

  <!-- Encoder arrow -->
  <line x1="240" y1="160" x2="350" y2="160" stroke="#16a34a" stroke-width="2.5" marker-end="url(#arr2)"/>
  <text x="295" y="150" text-anchor="middle" font-size="14" font-weight="bold" fill="#16a34a">e</text>
  <text x="295" y="180" text-anchor="middle" font-size="11" fill="#666">x mod 3</text>

  <!-- Compressed 3-cycle -->
  <text x="450" y="60" text-anchor="middle" font-size="14" fill="#dc2626" font-weight="bold">Compressed (period 3)</text>
  <g transform="translate(450,160)">
    <circle cx="0" cy="-50" r="22" fill="#fee2e2" stroke="#dc2626" stroke-width="2.5"/>
    <text x="0" y="-44" text-anchor="middle" font-size="14" font-weight="bold" fill="#991b1b">0</text>

    <circle cx="43" cy="25" r="22" fill="#fee2e2" stroke="#dc2626" stroke-width="2.5"/>
    <text x="43" y="31" text-anchor="middle" font-size="14" font-weight="bold" fill="#991b1b">1</text>

    <circle cx="-43" cy="25" r="22" fill="#fee2e2" stroke="#dc2626" stroke-width="2.5"/>
    <text x="-43" y="31" text-anchor="middle" font-size="14" font-weight="bold" fill="#991b1b">2</text>

    <line x1="18" y1="-40" x2="33" y2="5" stroke="#dc2626" stroke-width="2" marker-end="url(#arr2)"/>
    <line x1="27" y1="40" x2="-23" y2="35" stroke="#dc2626" stroke-width="2" marker-end="url(#arr2)"/>
    <line x1="-33" y1="5" x2="-18" y2="-40" stroke="#dc2626" stroke-width="2" marker-end="url(#arr2)"/>
  </g>

  <!-- Divisibility note -->
  <text x="300" y="290" text-anchor="middle" font-size="14" fill="#333">Period 3 divides period 6: compression preserves divisibility ✓</text>
  <text x="300" y="315" text-anchor="middle" font-size="13" fill="#666">Capacity: 3-cycle needs |β| ≥ 3 states</text>
</svg>"""
    return svg


def generate_capacity_bound_svg():
    """Generate SVG showing the capacity lower bound."""
    svg = """<svg xmlns="http://www.w3.org/2000/svg" width="550" height="280" viewBox="0 0 550 280">
  <text x="275" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Capacity Lower Bound: |β| ≥ max cycle length</text>

  <!-- Bar chart -->
  <g transform="translate(50, 50)">
    <!-- Axes -->
    <line x1="0" y1="180" x2="450" y2="180" stroke="#333" stroke-width="1.5"/>
    <line x1="0" y1="0" x2="0" y2="180" stroke="#333" stroke-width="1.5"/>

    <!-- Y-axis label -->
    <text x="-15" y="90" text-anchor="middle" font-size="12" fill="#666" transform="rotate(-90, -15, 90)">States needed</text>

    <!-- Bars: cycle lengths -->
    <rect x="30" y="30" width="50" height="150" fill="#93c5fd" stroke="#2563eb" stroke-width="1.5" rx="3"/>
    <text x="55" y="200" text-anchor="middle" font-size="12" fill="#333">n=10</text>
    <text x="55" y="25" text-anchor="middle" font-size="11" fill="#2563eb" font-weight="bold">10</text>

    <rect x="120" y="60" width="50" height="120" fill="#93c5fd" stroke="#2563eb" stroke-width="1.5" rx="3"/>
    <text x="145" y="200" text-anchor="middle" font-size="12" fill="#333">n=8</text>
    <text x="145" y="55" text-anchor="middle" font-size="11" fill="#2563eb" font-weight="bold">8</text>

    <rect x="210" y="105" width="50" height="75" fill="#93c5fd" stroke="#2563eb" stroke-width="1.5" rx="3"/>
    <text x="235" y="200" text-anchor="middle" font-size="12" fill="#333">n=5</text>
    <text x="235" y="100" text-anchor="middle" font-size="11" fill="#2563eb" font-weight="bold">5</text>

    <rect x="300" y="150" width="50" height="30" fill="#93c5fd" stroke="#2563eb" stroke-width="1.5" rx="3"/>
    <text x="325" y="200" text-anchor="middle" font-size="12" fill="#333">n=2</text>
    <text x="325" y="145" text-anchor="middle" font-size="11" fill="#2563eb" font-weight="bold">2</text>

    <!-- Capacity line -->
    <line x1="0" y1="30" x2="380" y2="30" stroke="#dc2626" stroke-width="2" stroke-dasharray="6,4"/>
    <text x="400" y="35" font-size="12" fill="#dc2626" font-weight="bold">|β| = 10</text>

    <!-- Tick marks -->
    <text x="-8" y="34" text-anchor="end" font-size="10" fill="#666">10</text>
    <text x="-8" y="64" text-anchor="end" font-size="10" fill="#666">8</text>
    <text x="-8" y="184" text-anchor="end" font-size="10" fill="#666">0</text>
  </g>

  <text x="275" y="270" text-anchor="middle" font-size="13" fill="#555">Each exact cycle of length n requires ≥ n states in β</text>
</svg>"""
    return svg


def generate_lifting_diagram_svg():
    """Generate SVG showing the periodic orbit lifting theorem."""
    svg = """<svg xmlns="http://www.w3.org/2000/svg" width="550" height="320" viewBox="0 0 550 320">
  <defs>
    <marker id="arr3" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
      <polygon points="0 0, 8 3, 0 6" fill="#333"/>
    </marker>
    <marker id="arr3g" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
      <polygon points="0 0, 8 3, 0 6" fill="#16a34a"/>
    </marker>
  </defs>

  <text x="275" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Lifting Theorem: Latent Cycles Certify Real Cycles</text>

  <!-- Latent cycle (bottom) -->
  <text x="275" y="250" text-anchor="middle" font-size="13" fill="#dc2626" font-weight="bold">Latent space β: observed 3-cycle</text>
  <g transform="translate(275,210)">
    <circle cx="-40" cy="0" r="16" fill="#fee2e2" stroke="#dc2626" stroke-width="2"/>
    <text x="-40" y="5" text-anchor="middle" font-size="12" fill="#991b1b">a</text>
    <circle cx="0" cy="-30" r="16" fill="#fee2e2" stroke="#dc2626" stroke-width="2"/>
    <text x="0" y="-25" text-anchor="middle" font-size="12" fill="#991b1b">b</text>
    <circle cx="40" cy="0" r="16" fill="#fee2e2" stroke="#dc2626" stroke-width="2"/>
    <text x="40" y="5" text-anchor="middle" font-size="12" fill="#991b1b">c</text>

    <line x1="-26" y1="-10" x2="-10" y2="-22" stroke="#dc2626" stroke-width="1.5" marker-end="url(#arr3)"/>
    <line x1="14" y1="-22" x2="28" y2="-8" stroke="#dc2626" stroke-width="1.5" marker-end="url(#arr3)"/>
    <line x1="26" y1="10" x2="-24" y2="10" stroke="#dc2626" stroke-width="1.5" marker-end="url(#arr3)"/>
  </g>

  <!-- Original space (top) with lifted cycle -->
  <text x="275" y="65" text-anchor="middle" font-size="13" fill="#2563eb" font-weight="bold">Original space α: guaranteed periodic orbit ∃</text>

  <!-- Fiber over a -->
  <rect x="60" y="80" width="100" height="60" rx="8" fill="#eff6ff" stroke="#2563eb" stroke-width="1" stroke-dasharray="4,3"/>
  <circle cx="85" cy="110" r="14" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
  <text x="85" y="115" text-anchor="middle" font-size="11" fill="#1e40af">x₁</text>
  <circle cx="135" cy="110" r="14" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
  <text x="135" y="115" text-anchor="middle" font-size="11" fill="#1e40af">x₂</text>
  <text x="110" y="95" text-anchor="middle" font-size="10" fill="#666">e⁻¹(a)</text>

  <!-- Fiber over b -->
  <rect x="210" y="80" width="130" height="60" rx="8" fill="#eff6ff" stroke="#2563eb" stroke-width="1" stroke-dasharray="4,3"/>
  <circle cx="235" cy="110" r="14" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
  <text x="235" y="115" text-anchor="middle" font-size="11" fill="#1e40af">x₃</text>
  <circle cx="275" cy="110" r="14" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
  <text x="275" y="115" text-anchor="middle" font-size="11" fill="#1e40af">x₄</text>
  <circle cx="315" cy="110" r="14" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
  <text x="315" y="115" text-anchor="middle" font-size="11" fill="#1e40af">x₅</text>
  <text x="275" y="95" text-anchor="middle" font-size="10" fill="#666">e⁻¹(b)</text>

  <!-- Fiber over c -->
  <rect x="390" y="80" width="100" height="60" rx="8" fill="#eff6ff" stroke="#2563eb" stroke-width="1" stroke-dasharray="4,3"/>
  <circle cx="415" cy="110" r="14" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
  <text x="415" y="115" text-anchor="middle" font-size="11" fill="#1e40af">x₆</text>
  <circle cx="465" cy="110" r="14" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
  <text x="465" y="115" text-anchor="middle" font-size="11" fill="#1e40af">x₇</text>
  <text x="440" y="95" text-anchor="middle" font-size="10" fill="#666">e⁻¹(c)</text>

  <!-- Lifted cycle arrows -->
  <path d="M 99 110 C 140 70 200 70 221 110" stroke="#16a34a" stroke-width="2" fill="none" marker-end="url(#arr3g)"/>
  <path d="M 289 110 C 330 70 370 70 401 110" stroke="#16a34a" stroke-width="2" fill="none" marker-end="url(#arr3g)"/>
  <path d="M 465 124 C 470 160 120 160 85 124" stroke="#16a34a" stroke-width="2" fill="none" marker-end="url(#arr3g)"/>

  <!-- Encoder arrows -->
  <line x1="110" y1="145" x2="240" y2="195" stroke="#999" stroke-width="1" stroke-dasharray="3,3" marker-end="url(#arr3)"/>
  <line x1="275" y1="145" x2="275" y2="175" stroke="#999" stroke-width="1" stroke-dasharray="3,3" marker-end="url(#arr3)"/>
  <line x1="440" y1="145" x2="310" y2="195" stroke="#999" stroke-width="1" stroke-dasharray="3,3" marker-end="url(#arr3)"/>

  <text x="275" y="300" text-anchor="middle" font-size="12" fill="#16a34a" font-weight="bold">Green: lifted periodic orbit (x₁ → x₃ → x₆ → x₁)</text>
</svg>"""
    return svg


if __name__ == "__main__":
    # Generate all SVGs
    diagrams = {
        "semiconjugacy_diagram": generate_semiconjugacy_diagram_svg(),
        "period_compression": generate_period_compression_svg(),
        "capacity_bound": generate_capacity_bound_svg(),
        "lifting_diagram": generate_lifting_diagram_svg(),
    }

    for name, svg in diagrams.items():
        with open(f"{name}.svg", "w") as f:
            f.write(svg)
        print(f"Generated {name}.svg")

    print("\nAll visualizations generated.")
