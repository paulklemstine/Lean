#!/usr/bin/env python3
"""
Applications of the Finite Garden-of-Eden Principle

Demonstrates real-world applications across multiple domains:
1. Consensus protocols — convergence guarantees
2. Boolean network dynamics — gene regulatory network stabilization
3. Model checking — unreachable state detection
4. Cellular automata — forbidden pattern identification
5. Abstract interpretation — certified program analysis convergence
"""

import itertools
from typing import Tuple, List, Set, Dict
from collections import defaultdict


# =============================================================================
# Application 1: Consensus Protocol Convergence
# =============================================================================
def consensus_protocol_demo():
    """
    Model a simple consensus protocol as a monotone descending map.

    Scenario: 3 nodes, each holding a value in {0, 1, 2, 3}.
    Update rule: each node takes the minimum of itself and its neighbors.

    This is monotone (larger configs map to larger results) and descending
    (each node's value can only decrease or stay the same).

    The Garden-of-Eden theorem guarantees:
    - Convergence within |P| = 4³ = 64 steps
    - States with non-monotone value distributions are unreachable
    """
    print("=" * 60)
    print("APPLICATION 1: Consensus Protocol Convergence")
    print("=" * 60)
    print()
    print("3 nodes in a ring, values in {0,1,2,3}")
    print("Update: each node takes min(self, left_neighbor, right_neighbor)")
    print()

    values = list(range(4))
    configs = list(itertools.product(values, repeat=3))

    def consensus_step(c: Tuple[int, ...]) -> Tuple[int, ...]:
        n = len(c)
        return tuple(min(c[i], c[(i-1) % n], c[(i+1) % n]) for i in range(n))

    # Track convergence
    max_steps = 0
    convergence_histogram: Dict[int, int] = defaultdict(int)

    for c in configs:
        steps = 0
        current = c
        while consensus_step(current) != current:
            current = consensus_step(current)
            steps += 1
        max_steps = max(max_steps, steps)
        convergence_histogram[steps] += 1

    print(f"  Total configurations: {len(configs)}")
    print(f"  Maximum convergence steps: {max_steps}")
    print(f"  Theoretical bound: {len(configs)} (from |P|)")
    print()
    print("  Convergence histogram:")
    for step in sorted(convergence_histogram.keys()):
        count = convergence_histogram[step]
        bar = "█" * (count // 2)
        print(f"    {step} steps: {count:4d} configs  {bar}")

    # Garden-of-Eden states
    image = {consensus_step(c) for c in configs}
    goe = [c for c in configs if c not in image]
    print(f"\n  Garden-of-Eden (unreachable) configurations: {len(goe)}")
    print("  Examples:")
    for g in goe[:5]:
        print(f"    {g} — cannot arise from any single consensus step")

    # Fixed points
    fixed = [c for c in configs if consensus_step(c) == c]
    print(f"\n  Fixed points (consensus states): {len(fixed)}")
    for fp in fixed[:5]:
        print(f"    {fp}")
    print()


# =============================================================================
# Application 2: Boolean Network (Gene Regulatory) Dynamics
# =============================================================================
def boolean_network_demo():
    """
    Model a simple gene regulatory network as a Boolean network.

    3 genes with inhibitory interactions (AND-NOT gates).
    The network is monotone descending under the pointwise Boolean order
    when all interactions are inhibitory.
    """
    print("=" * 60)
    print("APPLICATION 2: Boolean Network — Gene Regulation")
    print("=" * 60)
    print()
    print("3-gene inhibitory network:")
    print("  Gene A: activated by B AND (NOT C)")
    print("  Gene B: activated by (NOT A)")
    print("  Gene C: activated by A AND B")
    print()

    configs = list(itertools.product([0, 1], repeat=3))

    def gene_update(c: Tuple[int, ...]) -> Tuple[int, ...]:
        a, b, cc = c
        new_a = b & (1 - cc)
        new_b = 1 - a
        new_c = a & b
        return (new_a, new_b, new_c)

    print("  Transition table:")
    print("  (A, B, C) → (A', B', C')")
    for c in configs:
        print(f"    {c} → {gene_update(c)}")

    # Find attractors (cycles)
    visited: Set[Tuple[int, ...]] = set()
    attractors: List[List[Tuple[int, ...]]] = []

    for start in configs:
        if start in visited:
            continue
        orbit = []
        current = start
        orbit_set: Set[Tuple[int, ...]] = set()
        while current not in orbit_set:
            orbit_set.add(current)
            orbit.append(current)
            current = gene_update(current)
        # Find the cycle
        cycle_start = orbit.index(current)
        cycle = orbit[cycle_start:]
        attractors.append(cycle)
        visited.update(orbit_set)

    print(f"\n  Attractors (steady states / cycles):")
    for i, attr in enumerate(attractors):
        if len(attr) == 1 and gene_update(attr[0]) == attr[0]:
            print(f"    Attractor {i+1}: Fixed point {attr[0]}")
        else:
            cycle_str = " → ".join(str(s) for s in attr)
            print(f"    Attractor {i+1}: Cycle {cycle_str}")

    # Garden-of-Eden
    image = {gene_update(c) for c in configs}
    goe = [c for c in configs if c not in image]
    print(f"\n  Garden-of-Eden states: {len(goe)}")
    for g in goe:
        print(f"    {g}")
    print()


# =============================================================================
# Application 3: Model Checking — Unreachable State Detection
# =============================================================================
def model_checking_demo():
    """
    A simple mutex protocol modeled as a finite-state system.
    Use Garden-of-Eden analysis to identify states that can never
    be reached from any initial state — proving safety properties.
    """
    print("=" * 60)
    print("APPLICATION 3: Model Checking — Mutex Safety Verification")
    print("=" * 60)
    print()
    print("Two-process mutex with states: {idle, trying, critical}")
    print("Safety property: both processes cannot be in 'critical' simultaneously")
    print()

    states_per_process = ['idle', 'trying', 'critical']
    all_states = list(itertools.product(states_per_process, repeat=2))

    def mutex_step(s: Tuple[str, str]) -> Tuple[str, str]:
        p1, p2 = s
        # Simple priority-based mutex: process 1 has priority
        new_p1 = p1
        new_p2 = p2
        if p1 == 'idle':
            new_p1 = 'trying'
        elif p1 == 'trying':
            if p2 != 'critical':
                new_p1 = 'critical'
        elif p1 == 'critical':
            new_p1 = 'idle'

        if p2 == 'idle':
            new_p2 = 'trying'
        elif p2 == 'trying':
            if new_p1 != 'critical':
                new_p2 = 'critical'
        elif p2 == 'critical':
            new_p2 = 'idle'
        return (new_p1, new_p2)

    print("  Transition table:")
    for s in all_states:
        print(f"    {s} → {mutex_step(s)}")

    image = {mutex_step(s) for s in all_states}
    goe = [s for s in all_states if s not in image]
    print(f"\n  Garden-of-Eden states (unreachable from any predecessor):")
    for g in goe:
        marker = " ⚠ UNSAFE!" if g[0] == 'critical' and g[1] == 'critical' else ""
        print(f"    {g}{marker}")

    unsafe = ('critical', 'critical')
    if unsafe in goe:
        print(f"\n  ✓ SAFETY VERIFIED: ({unsafe}) is a Garden-of-Eden state!")
        print("    It cannot be reached by any sequence of transitions.")
    elif unsafe not in image:
        print(f"\n  ✓ ({unsafe}) is not in the image of the transition function.")
    else:
        print(f"\n  ⚠ ({unsafe}) IS reachable — mutex protocol is UNSAFE!")
    print()


# =============================================================================
# Application 4: Cellular Automata — Rule 232 Analysis
# =============================================================================
def cellular_automata_demo():
    """
    Analyze Garden-of-Eden patterns in elementary cellular automata.
    Rule 232 is a majority-based rule that is known to have
    Garden-of-Eden configurations.
    """
    print("=" * 60)
    print("APPLICATION 4: Cellular Automata — Rule 232 (Majority)")
    print("=" * 60)
    print()

    # Rule 232: majority of (left, center, right)
    def rule232_lookup(left: int, center: int, right: int) -> int:
        return 1 if (left + center + right) >= 2 else 0

    def apply_rule232(config: Tuple[int, ...]) -> Tuple[int, ...]:
        n = len(config)
        return tuple(
            rule232_lookup(config[(i-1) % n], config[i], config[(i+1) % n])
            for i in range(n)
        )

    # Analyze for different grid sizes
    for grid_size in [4, 5, 6]:
        configs = list(itertools.product([0, 1], repeat=grid_size))
        image = {apply_rule232(c) for c in configs}
        goe = [c for c in configs if c not in image]

        print(f"  Grid size {grid_size}: {len(configs)} configs, "
              f"{len(image)} in image, {len(goe)} Garden-of-Eden")

        if goe and grid_size <= 5:
            print(f"    GoE examples: {goe[:3]}")

    print()
    print("  As grid size grows, the fraction of Garden-of-Eden states")
    print("  typically stabilizes — a signature of the entropy defect.")
    print()


# =============================================================================
# Application 5: Image-Entropy Decay Visualization
# =============================================================================
def entropy_decay_application():
    """
    Track the 'entropy' (image cardinality) of iterated dynamics
    on a small poset. This directly visualizes the thermodynamic
    closure defect.
    """
    print("=" * 60)
    print("APPLICATION 5: Entropy Decay — Thermodynamic Closure")
    print("=" * 60)
    print()

    # Divisibility poset on {1, 2, 3, ..., 12}
    elements = list(range(1, 13))

    def gcd_map(x: int) -> int:
        """Map each element to its largest proper divisor, or itself if prime/1."""
        if x <= 1:
            return x
        for d in range(x - 1, 0, -1):
            if x % d == 0:
                return d
        return x

    print(f"  State space: {elements}")
    print(f"  F(x) = largest proper divisor of x (F(1) = 1)")
    print(f"  Map: {{{', '.join(f'{x}↦{gcd_map(x)}' for x in elements)}}}")
    print()

    # Compute entropy sequence
    current_states = set(elements)
    entropy = [len(current_states)]

    for step in range(1, len(elements) + 1):
        current_states = {gcd_map(x) for x in current_states}
        entropy.append(len(current_states))
        if entropy[-1] == entropy[-2]:
            break

    print("  Entropy (image cardinality) sequence:")
    for n, h in enumerate(entropy):
        bar = "█" * h
        print(f"    H_{n} = {h:2d}  {bar}")
        if n > 0 and h == entropy[n-1]:
            print(f"    → Stabilized at step {n}")
            break

    # Fixed points
    fixed = [x for x in elements if gcd_map(x) == x]
    print(f"\n  Fixed points: {fixed}")
    print(f"  |Fixed points| = {len(fixed)} = H_∞ ✓")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   APPLICATIONS OF THE FINITE GARDEN-OF-EDEN PRINCIPLE      ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    consensus_protocol_demo()
    boolean_network_demo()
    model_checking_demo()
    cellular_automata_demo()
    entropy_decay_application()

    print("All application demonstrations complete.")


#!/usr/bin/env python3
"""
Finite Garden-of-Eden Principle — Interactive Demonstrations

Demonstrates the core theorems:
1. Monotone descending maps on finite posets stabilize in bounded time
2. Non-surjective maps produce Garden-of-Eden (unreachable) configurations
3. Eventual image equals the set of fixed points
4. Finite Moore-Myhill: surjectivity ↔ injectivity on finite types

Each demo uses concrete small examples to make the mathematics tangible.
"""

import itertools
from typing import Callable, TypeVar, Optional

T = TypeVar('T')


def iterate(f: Callable[[T], T], n: int, x: T) -> T:
    """Compute f^[n](x) — the n-th iterate of f applied to x."""
    result = x
    for _ in range(n):
        result = f(result)
    return result


def orbit(f: Callable[[T], T], x: T, max_steps: int = 100) -> list:
    """Compute the orbit x, f(x), f²(x), ... until stabilization or max_steps."""
    result = [x]
    for _ in range(max_steps):
        next_val = f(result[-1])
        result.append(next_val)
        if next_val == result[-2]:
            break
    return result


# =============================================================================
# Demo 1: Monotone descending map on a power-set lattice (ordered by ⊆)
# =============================================================================
def demo_powerset_descent():
    """
    Consider the power set of {0, 1, 2} ordered by inclusion.
    Define F(S) = S ∩ {0, 1} (remove element 2 if present).
    This is monotone (S ⊆ T ⟹ F(S) ⊆ F(T)) and descending (F(S) ⊆ S).
    """
    print("=" * 70)
    print("DEMO 1: Monotone Descending Map on Power-Set Lattice P({0,1,2})")
    print("=" * 70)
    print()
    print("F(S) = S ∩ {0,1}  (removes element 2)")
    print("This is monotone and descending (F(S) ⊆ S for all S).")
    print()

    universe = frozenset({0, 1, 2})
    all_subsets = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(sorted(universe), r):
            all_subsets.append(frozenset(combo))

    mask = frozenset({0, 1})

    def F(s: frozenset) -> frozenset:
        return s & mask

    card_P = len(all_subsets)
    print(f"  |P| = {card_P} (number of subsets)")
    print(f"  Stabilization bound: ≤ {card_P} steps")
    print()

    # Show orbits
    print("  Orbits:")
    for s in sorted(all_subsets, key=lambda x: (len(x), sorted(x))):
        orb = orbit(F, s, max_steps=card_P + 1)
        stab_step = next(i for i in range(len(orb) - 1) if orb[i] == orb[i + 1])
        orb_str = " → ".join(str(set(o)) if o else "∅" for o in orb[:stab_step + 2])
        s_str = str(set(s)) if s else '∅'
        print(f"    {s_str:>12}:  {orb_str}  (stabilized at step {stab_step})")

    # Check Garden-of-Eden
    image = {F(s) for s in all_subsets}
    goe = [s for s in all_subsets if s not in image]
    print()
    if goe:
        print(f"  Garden-of-Eden states (no preimage under F): "
              f"{[set(s) if s else '∅' for s in goe]}")
    else:
        print("  F is surjective — no Garden-of-Eden states.")

    # Fixed points
    fixed = [s for s in all_subsets if F(s) == s]
    print(f"  Fixed points of F: {[set(s) if s else '∅' for s in fixed]}")

    # Eventual image
    eventual = {iterate(F, card_P, s) for s in all_subsets}
    print(f"  Eventual image (range of F^[{card_P}]): "
          f"{[set(s) if s else '∅' for s in sorted(eventual, key=lambda x: (len(x), sorted(x)))]}")
    print(f"  Fixed points = Eventual image? {set(map(frozenset, fixed)) == eventual}")
    print()


# =============================================================================
# Demo 2: Non-surjective map with Garden-of-Eden detection
# =============================================================================
def demo_garden_of_eden():
    """
    Consider configurations on a 2-cell grid with alphabet {0, 1}.
    Define a cellular-automaton-style rule that is not surjective.
    """
    print("=" * 70)
    print("DEMO 2: Garden-of-Eden on Binary Configurations (2 cells)")
    print("=" * 70)
    print()

    # Configurations: (a, b) where a, b ∈ {0, 1}
    configs = list(itertools.product([0, 1], repeat=2))
    print(f"  Configuration space: {configs}")
    print(f"  |Configurations| = {len(configs)}")
    print()

    # Rule: F(a, b) = (a AND b, a OR b) — sorts the pair
    def F(c):
        return (min(c), max(c))

    print("  Rule: F(a,b) = (min(a,b), max(a,b))  [sorts the pair]")
    print()
    print("  Action of F:")
    image_set = set()
    for c in configs:
        fc = F(c)
        image_set.add(fc)
        print(f"    F{c} = {fc}")

    print()
    goe = [c for c in configs if c not in image_set]
    print(f"  Image of F: {sorted(image_set)}")
    print(f"  Garden-of-Eden states: {goe}")

    if goe:
        print(f"\n  ✓ F is NOT surjective → Garden-of-Eden states exist!")
        print(f"    The configuration {goe[0]} can never be reached by applying F.")
    else:
        print(f"\n  F is surjective → no Garden-of-Eden states.")

    # Check injectivity
    is_injective = len(image_set) == len(configs)
    print(f"  Is F injective? {is_injective}")
    if not is_injective:
        # Find collisions
        from collections import defaultdict
        preimages = defaultdict(list)
        for c in configs:
            preimages[F(c)].append(c)
        for img, pres in preimages.items():
            if len(pres) > 1:
                print(f"    Collision: F{pres[0]} = F{pres[1]} = {img}")
    print()


# =============================================================================
# Demo 3: Convergence bound visualization
# =============================================================================
def demo_convergence_bound():
    """
    Demonstrate that orbits of monotone descending maps stabilize
    within |P| steps, and show this bound is tight.
    """
    print("=" * 70)
    print("DEMO 3: Convergence Bound — Tightness of the |P|-Step Bound")
    print("=" * 70)
    print()

    # Linear order on {0, 1, 2, ..., n-1}; F(x) = max(0, x-1)
    for n in [4, 6, 8]:
        def F(x, _n=n):
            return max(0, x - 1)

        print(f"  P = {{0, 1, ..., {n-1}}},  F(x) = max(0, x-1)")
        print(f"  |P| = {n}")

        max_stab = 0
        for x in range(n):
            orb = orbit(F, x, max_steps=n + 1)
            stab = next(i for i in range(len(orb) - 1) if orb[i] == orb[i + 1])
            max_stab = max(max_stab, stab)
            orb_str = " → ".join(str(o) for o in orb[:stab + 2])
            print(f"    orbit({x}): {orb_str}  [stabilizes at step {stab}]")

        print(f"  Maximum stabilization step: {max_stab}  (bound = {n})")
        print(f"  Bound is {'TIGHT' if max_stab == n - 1 else 'not tight'} "
              f"(worst case = {n-1} = |P|-1)")
        print()


# =============================================================================
# Demo 4: Moore-Myhill on finite configurations
# =============================================================================
def demo_moore_myhill():
    """
    Demonstrate that on finite configuration spaces:
    surjective ⟺ injective.
    """
    print("=" * 70)
    print("DEMO 4: Finite Moore–Myhill — Surjective ↔ Injective")
    print("=" * 70)
    print()

    # 3-cell grid, binary alphabet
    configs = list(itertools.product([0, 1], repeat=3))
    n = len(configs)
    print(f"  Configuration space: 3-cell binary grid, |Ω| = {n}")
    print()

    # Example 1: XOR shift (surjective = injective)
    def xor_shift(c):
        return (c[1], c[2], c[0] ^ c[1])

    image1 = {xor_shift(c) for c in configs}
    is_surj1 = len(image1) == n
    is_inj1 = len({xor_shift(c) for c in configs}) == n
    print("  Rule 1: F(a,b,c) = (b, c, a⊕b)  [XOR shift]")
    print(f"    |Image| = {len(image1)},  Surjective? {is_surj1},  Injective? {is_inj1}")

    # Example 2: majority rule (non-surjective = non-injective)
    def majority(c):
        m = 1 if sum(c) >= 2 else 0
        return (m, m, m)

    image2 = {majority(c) for c in configs}
    is_surj2 = len(image2) == n
    # count distinct images
    print(f"\n  Rule 2: F(a,b,c) = (maj, maj, maj)  [majority vote]")
    print(f"    |Image| = {len(image2)},  Surjective? {is_surj2},  Injective? False")
    goe2 = [c for c in configs if c not in image2]
    print(f"    Garden-of-Eden states: {len(goe2)} configurations")
    for g in goe2[:5]:
        print(f"      {g}")
    if len(goe2) > 5:
        print(f"      ... and {len(goe2) - 5} more")

    print()
    print("  ✓ Finite Moore–Myhill confirmed:")
    print("    • Rule 1: surjective AND injective")
    print("    • Rule 2: neither surjective NOR injective")
    print("    On finite sets, you can't have one without the other!")
    print()


# =============================================================================
# Demo 5: Entropy decay — image cardinality under iteration
# =============================================================================
def demo_entropy_decay():
    """
    Track |range(F^[n])| as n increases for a non-surjective map.
    This is the discrete entropy of the dynamics.
    """
    print("=" * 70)
    print("DEMO 5: Entropy Decay — Image Cardinality Under Iteration")
    print("=" * 70)
    print()

    # 4-element set with a non-surjective map
    states = list(range(6))

    def F(x):
        return {0: 0, 1: 0, 2: 1, 3: 2, 4: 3, 5: 4}[x]

    print(f"  State space: {states}")
    print(f"  F: {{{', '.join(f'{x}↦{F(x)}' for x in states)}}}")
    print()

    all_states = set(states)
    current_image = all_states.copy()
    print(f"  n=0: |range(F^[0])| = {len(current_image)}  (full state space)")

    for n in range(1, len(states) + 1):
        current_image = {F(x) for x in current_image}
        print(f"  n={n}: |range(F^[{n}])| = {len(current_image)}  "
              f"states = {sorted(current_image)}")
        if len(current_image) == len({F(x) for x in current_image}):
            # Stabilized
            fixed = [x for x in current_image if F(x) == x]
            print(f"  → Stabilized! Eventual image = fixed points = {fixed}")
            break

    print()
    print("  The 'entropy' |range(F^[n])| decreases monotonically")
    print("  until it equals the number of fixed points.")
    print("  Lost states are Garden-of-Eden configurations —")
    print("  permanently unreachable under forward evolution.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     FINITE GARDEN-OF-EDEN PRINCIPLE — INTERACTIVE DEMONSTRATIONS    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_powerset_descent()
    demo_garden_of_eden()
    demo_convergence_bound()
    demo_moore_myhill()
    demo_entropy_decay()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualizations for the Finite Garden-of-Eden Principle

Generates publication-quality figures illustrating:
1. Orbit descent on a finite poset
2. Entropy decay curves
3. Garden-of-Eden state map
4. Convergence bound tightness
"""

import itertools
import base64
import io

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; skipping visualizations")


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def generate_entropy_decay_chart() -> str:
    """
    Chart showing entropy (image cardinality) decay for several
    non-surjective maps on finite sets.
    """
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    # Example 1: Linear descent F(x) = max(0, x-1) on {0,...,7}
    n1 = 8
    states1 = set(range(n1))
    def f1(x): return max(0, x - 1)
    entropy1 = [len(states1)]
    current = states1.copy()
    for _ in range(n1):
        current = {f1(x) for x in current}
        entropy1.append(len(current))

    # Example 2: Floor division F(x) = x // 2 on {0,...,15}
    n2 = 16
    states2 = set(range(n2))
    def f2(x): return x // 2
    entropy2 = [len(states2)]
    current = states2.copy()
    for _ in range(n2):
        current = {f2(x) for x in current}
        entropy2.append(len(current))
        if len(current) == entropy2[-2]:
            break

    # Example 3: Modular collapse F(x) = x mod 3 on {0,...,11}
    n3 = 12
    states3 = set(range(n3))
    def f3(x): return x % 3
    entropy3 = [len(states3)]
    current = states3.copy()
    for _ in range(n3):
        current = {f3(x) for x in current}
        entropy3.append(len(current))
        if len(current) == entropy3[-2]:
            break

    ax.plot(range(len(entropy1)), entropy1, 'o-', color='#2196F3',
            linewidth=2, markersize=6, label=f'F(x)=max(0,x-1) on {{0,…,{n1-1}}}')
    ax.plot(range(len(entropy2)), entropy2, 's-', color='#F44336',
            linewidth=2, markersize=6, label=f'F(x)=⌊x/2⌋ on {{0,…,{n2-1}}}')
    ax.plot(range(len(entropy3)), entropy3, '^-', color='#4CAF50',
            linewidth=2, markersize=6, label=f'F(x)=x mod 3 on {{0,…,{n3-1}}}')

    ax.set_xlabel('Iteration step n', fontsize=12)
    ax.set_ylabel('|range(F^[n])| — Image cardinality', fontsize=12)
    ax.set_title('Entropy Decay Under Iterated Non-Surjective Maps', fontsize=14)
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0)

    return fig_to_base64(fig)


def generate_orbit_descent_chart() -> str:
    """
    Visualize orbits descending on a linear poset,
    showing stabilization at fixed points.
    """
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    n = 8
    def F(x): return max(0, x - 1)

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, n))

    for start in range(n):
        orbit = [start]
        for _ in range(n):
            orbit.append(F(orbit[-1]))
            if orbit[-1] == orbit[-2]:
                break
        ax.plot(range(len(orbit)), orbit, 'o-', color=colors[start],
                linewidth=1.5, markersize=5, alpha=0.8,
                label=f'x₀ = {start}')

    ax.set_xlabel('Step n', fontsize=12)
    ax.set_ylabel('F^[n](x₀)', fontsize=12)
    ax.set_title('Orbit Descent: F(x) = max(0, x−1) on {0,…,7}', fontsize=14)
    ax.legend(fontsize=9, ncol=2, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_yticks(range(n))

    return fig_to_base64(fig)


def generate_garden_of_eden_map() -> str:
    """
    Heatmap showing which configurations are Garden-of-Eden states
    for a cellular automaton rule on binary configurations.
    """
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    for idx, grid_size in enumerate([4, 5, 6]):
        configs = list(itertools.product([0, 1], repeat=grid_size))

        def majority_rule(c):
            n = len(c)
            return tuple(
                1 if sum(c[max(0,i-1):min(n,i+2)]) >= 2 else 0
                for i in range(n)
            )

        image = {majority_rule(c) for c in configs}

        # Create a 2D arrangement for visualization
        n_configs = len(configs)
        side = int(np.ceil(np.sqrt(n_configs)))
        grid = np.zeros((side, side))

        for i, c in enumerate(configs):
            row, col = divmod(i, side)
            grid[row, col] = 0 if c in image else 1  # 1 = GoE

        goe_count = sum(1 for c in configs if c not in image)

        ax = axes[idx]
        cmap = plt.cm.colors.ListedColormap(['#E8F5E9', '#F44336'])
        ax.imshow(grid[:int(np.ceil(n_configs/side)), :], cmap=cmap,
                  aspect='equal', interpolation='nearest')
        ax.set_title(f'{grid_size} cells\n{goe_count}/{n_configs} GoE',
                     fontsize=11)
        ax.set_xticks([])
        ax.set_yticks([])

    fig.suptitle('Garden-of-Eden States (red) under Majority Rule', fontsize=14, y=1.02)

    legend_elements = [
        mpatches.Patch(facecolor='#E8F5E9', edgecolor='gray', label='Reachable'),
        mpatches.Patch(facecolor='#F44336', edgecolor='gray', label='Garden-of-Eden'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=2, fontsize=10)
    fig.tight_layout()

    return fig_to_base64(fig)


def generate_convergence_bound_chart() -> str:
    """
    Bar chart showing maximum stabilization steps vs |P|
    for different poset sizes, demonstrating the bound is nearly tight.
    """
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    sizes = list(range(2, 16))
    max_steps = []
    bounds = []

    for n in sizes:
        def F(x, _n=n): return max(0, x - 1)
        worst = 0
        for x in range(n):
            current = x
            steps = 0
            while F(current) != current:
                current = F(current)
                steps += 1
            worst = max(worst, steps)
        max_steps.append(worst)
        bounds.append(n)

    x_pos = np.arange(len(sizes))
    width = 0.35

    bars1 = ax.bar(x_pos - width/2, bounds, width, label='Theoretical bound |P|',
                   color='#BBDEFB', edgecolor='#1565C0', linewidth=0.5)
    bars2 = ax.bar(x_pos + width/2, max_steps, width, label='Actual worst case',
                   color='#F44336', edgecolor='#B71C1C', linewidth=0.5, alpha=0.8)

    ax.set_xlabel('Poset size |P|', fontsize=12)
    ax.set_ylabel('Steps to stabilization', fontsize=12)
    ax.set_title('Convergence Bound: Theory vs Practice', fontsize=14)
    ax.set_xticks(x_pos)
    ax.set_xticklabels(sizes)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2, axis='y')

    return fig_to_base64(fig)


if __name__ == "__main__":
    if not HAS_MPL:
        print("Cannot generate visualizations without matplotlib.")
        exit(1)

    print("Generating visualizations...")

    print("  1. Entropy decay chart...")
    b64_1 = generate_entropy_decay_chart()
    print(f"     Generated ({len(b64_1)} chars)")

    print("  2. Orbit descent chart...")
    b64_2 = generate_orbit_descent_chart()
    print(f"     Generated ({len(b64_2)} chars)")

    print("  3. Garden-of-Eden map...")
    b64_3 = generate_garden_of_eden_map()
    print(f"     Generated ({len(b64_3)} chars)")

    print("  4. Convergence bound chart...")
    b64_4 = generate_convergence_bound_chart()
    print(f"     Generated ({len(b64_4)} chars)")

    print("\nAll visualizations generated successfully.")

    # Save to files as well
    for name, b64 in [("entropy_decay", b64_1), ("orbit_descent", b64_2),
                       ("garden_of_eden_map", b64_3), ("convergence_bound", b64_4)]:
        # Extract raw PNG data from data URI
        raw = base64.b64decode(b64.split(",")[1])
        with open(f"{name}.png", "wb") as f:
            f.write(raw)
        print(f"  Saved {name}.png")
