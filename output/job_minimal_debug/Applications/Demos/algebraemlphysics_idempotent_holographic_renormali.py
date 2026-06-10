#!/usr/bin/env python3
"""
Applications of Idempotent Holographic Renormalization

Demonstrates real-world applications:
1. Tropical shortest-path observability (graph algorithms)
2. Neural network interpretability via closure-RG
3. Formal concept analysis with RG coarsening
"""

from __future__ import annotations
import math
from typing import Dict, FrozenSet, List, Set, Tuple


# ─── Application 1: Tropical Shortest-Path Observability ──────────────────

def tropical_shortest_path_demo():
    """
    Demonstrate holographic reconstruction on a graph shortest-path problem.

    The state space is the set of distance vectors in a max-plus semiring.
    Boundary observables are distances to designated boundary vertices.
    The theorem guarantees: if boundary distances separate fixed-point profiles,
    then the asymptotic distance profile of any vertex is uniquely determined
    by its boundary distances at all relaxation depths.
    """
    print("=" * 70)
    print("APPLICATION 1: Tropical Shortest-Path Observability")
    print("=" * 70)

    # Graph: 5 vertices, weighted directed edges
    INF = float("inf")
    n = 5
    # Weight matrix (conventional: lower = shorter)
    # Using standard shortest-path convention
    W = [
        [0,   2, INF, INF,   7],
        [INF, 0,   3, INF, INF],
        [INF, INF, 0,   1, INF],
        [  6, INF, INF, 0,   2],
        [INF, INF,   4, INF, 0],
    ]

    def bellman_ford_step(dist: Tuple[float, ...]) -> Tuple[float, ...]:
        """One relaxation step (min-plus)."""
        new_dist = list(dist)
        for u in range(n):
            for v in range(n):
                if W[u][v] < INF:
                    new_dist[v] = min(new_dist[v], dist[u] + W[u][v])
        return tuple(new_dist)

    def cl(dist: Tuple[float, ...]) -> Tuple[float, ...]:
        """Closure: idempotent projection — clamp values to multiples of 1."""
        return tuple(math.ceil(d) if d < INF else INF for d in dist)

    def rg_step(dist: Tuple[float, ...]) -> Tuple[float, ...]:
        return cl(bellman_ford_step(dist))

    # Boundary observables: distances to vertices 0 and 4
    boundary_indices = [0, 4]
    def boundary_profile(dist: Tuple[float, ...]) -> Tuple[float, ...]:
        return tuple(dist[i] for i in boundary_indices)

    print(f"\nGraph with {n} vertices")
    print(f"Boundary vertices: {boundary_indices}")
    print(f"Boundary observables: distance to vertices {boundary_indices}")

    # Compute fixed-point distance profiles from each source
    print(f"\n--- RG Flow from each source vertex ---")
    for src in range(n):
        dist = tuple(0 if i == src else INF for i in range(n))
        print(f"\nSource vertex {src}:")
        for step in range(6):
            bp = boundary_profile(dist)
            is_fixed = rg_step(dist) == dist
            marker = " ← FIXED" if is_fixed else ""
            dist_str = tuple(d if d < INF else "∞" for d in dist)
            print(f"  Step {step}: dist = {dist_str}  "
                  f"boundary = {bp}{marker}")
            if is_fixed:
                break
            dist = rg_step(dist)

    print("\n✓ Tropical shortest-path observability demonstrated")


# ─── Application 2: Neural Network Interpretability ───────────────────────

def neural_network_interpretability_demo():
    """
    Simulate holographic renormalization on a simple neural network.

    The 'network' is a chain of quantized linear layers.
    States are quantized activation vectors.
    Closure = quantization to a fixed lattice.
    R = one layer forward pass.
    Boundary observables = concept activation probes.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Neural Network Interpretability")
    print("=" * 70)

    import random
    random.seed(42)

    # Simple 3-dimensional hidden space, quantized to integers in [0, 4]
    levels = list(range(5))

    def quantize(v: Tuple[int, ...]) -> Tuple[int, ...]:
        """Closure: clamp and round to nearest lattice point."""
        return tuple(max(0, min(4, round(x))) for x in v)

    # 'Layer' transformation: a simple affine map
    # W = [[1, 1, 0], [0, 1, 1], [1, 0, 1]], bias = [0, 0, 0]
    def layer_forward(v: Tuple[int, ...]) -> Tuple[int, ...]:
        x, y, z = v
        return (
            min(x + y, 4),
            min(y + z, 4),
            min(x + z, 4),
        )

    def rg_step(v: Tuple[int, ...]) -> Tuple[int, ...]:
        return quantize(layer_forward(v))

    # Generate all states
    states = set()
    for x in levels:
        for y in levels:
            for z in levels:
                states.add((x, y, z))

    # Concept probes (boundary observables)
    def probe_magnitude(v: Tuple[int, ...]) -> int:
        """Total activation level."""
        return sum(v)

    def probe_dominant(v: Tuple[int, ...]) -> int:
        """Index of dominant dimension."""
        return v.index(max(v))

    def probe_symmetry(v: Tuple[int, ...]) -> int:
        """Symmetry score: number of equal pairs."""
        return int(v[0] == v[1]) + int(v[1] == v[2]) + int(v[0] == v[2])

    def boundary_profile(v: Tuple[int, ...]) -> Tuple[int, ...]:
        return (probe_magnitude(v), probe_dominant(v), probe_symmetry(v))

    # Find all closed RG-fixed points
    fixed_points = [v for v in states
                    if quantize(v) == v and rg_step(v) == v]

    print(f"\nState space: {len(states)} quantized activation patterns")
    print(f"Closed RG-fixed points: {len(fixed_points)}")
    print(f"Concept probes: magnitude, dominant_dim, symmetry_score")

    print(f"\n--- Fixed-Point Classification ---")
    profiles_seen: Dict[Tuple, List[Tuple]] = {}
    for fp in sorted(fixed_points):
        p = boundary_profile(fp)
        profiles_seen.setdefault(p, []).append(fp)
        print(f"  State {fp} → profile {p}")

    # Check separation
    all_separated = all(len(v) == 1 for v in profiles_seen.values())
    print(f"\nBoundary separation: {'✓' if all_separated else '✗'}")
    if not all_separated:
        print("  (Some fixed points share profiles — "
              "need more/better probes)")
        # Show which are not separated
        for p, fps in profiles_seen.items():
            if len(fps) > 1:
                print(f"  Profile {p} shared by: {fps}")

    # Demonstrate RG convergence from random states
    print(f"\n--- RG Convergence from Sample States ---")
    sample_states = random.sample(sorted(states), min(10, len(states)))
    for v in sample_states:
        y = v
        steps = 0
        for _ in range(20):
            y_next = rg_step(y)
            steps += 1
            if y_next == y:
                break
            y = y_next
        p = boundary_profile(y)
        print(f"  {v} → fixed {y} in {steps} steps, profile = {p}")

    print("\n✓ Neural network interpretability demo complete")


# ─── Application 3: Formal Concept Analysis ──────────────────────────────

def formal_concept_analysis_demo():
    """
    Demonstrate RG coarsening on formal concept analysis.

    Objects: animals with attributes
    Closure: attribute closure (shared attributes of objects with those attrs)
    R: drop the rarest attribute (coarsening)
    Boundary: selected probe attributes
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Formal Concept Analysis with RG Coarsening")
    print("=" * 70)

    # Simple context: animals and attributes
    attrs = ["flies", "swims", "legs4", "legs2", "warm", "lays_eggs"]
    objects = {
        "eagle":    frozenset({"flies", "legs2", "warm", "lays_eggs"}),
        "penguin":  frozenset({"swims", "legs2", "warm", "lays_eggs"}),
        "dog":      frozenset({"legs4", "warm"}),
        "cat":      frozenset({"legs4", "warm"}),
        "salmon":   frozenset({"swims", "lays_eggs"}),
        "frog":     frozenset({"swims", "legs4", "lays_eggs"}),
    }

    all_attrs = frozenset(attrs)

    # Closure: for an attribute set A, close(A) = attributes shared by
    # all objects that have A
    def objects_with(a_set: frozenset) -> List[str]:
        return [name for name, attrs in objects.items() if a_set <= attrs]

    def cl(a_set: frozenset) -> frozenset:
        """Formal concept closure: shared attributes of objects having a_set."""
        obj_list = objects_with(a_set)
        if not obj_list:
            return all_attrs  # maximal closure
        result = all_attrs
        for obj in obj_list:
            result = result & objects[obj]
        return result

    # R: add 'warm' attribute (coarsening toward warm-blooded)
    def R(a_set: frozenset) -> frozenset:
        return a_set | frozenset({"warm"})

    def rg_step(a_set: frozenset) -> frozenset:
        return cl(R(a_set))

    # All possible attribute sets from object descriptions
    states = set()
    for obj_attrs in objects.values():
        states.add(obj_attrs)
        states.add(cl(obj_attrs))
    # Add some subsets
    for a in attrs:
        states.add(frozenset({a}))
        states.add(cl(frozenset({a})))
    states.add(frozenset())
    states.add(cl(frozenset()))

    # Close all states
    extra = set()
    for s in states:
        extra.add(cl(s))
        extra.add(rg_step(s))
        extra.add(rg_step(rg_step(s)))
    states |= extra

    # Boundary observables
    def probe_has_warm(a: frozenset) -> int:
        return 1 if "warm" in a else 0

    def probe_mobility(a: frozenset) -> int:
        """How many mobility attributes."""
        return len(a & frozenset({"flies", "swims", "legs4", "legs2"}))

    def probe_size(a: frozenset) -> int:
        return len(a)

    def boundary_profile(a: frozenset) -> Tuple[int, ...]:
        return (probe_has_warm(a), probe_mobility(a), probe_size(a))

    print(f"\nContext: {len(objects)} animals, {len(attrs)} attributes")
    print(f"Attribute sets considered: {len(states)}")

    # Find fixed points
    fixed_points = [s for s in states
                    if cl(s) == s and rg_step(s) == s]
    print(f"Closed RG-fixed points: {len(fixed_points)}")

    print(f"\n--- Fixed Points (stable concept classes) ---")
    for fp in sorted(fixed_points, key=lambda x: (len(x), sorted(x))):
        objs = objects_with(fp)
        p = boundary_profile(fp)
        print(f"  {set(fp)}")
        print(f"    Objects: {objs}")
        print(f"    Profile: warm={p[0]}, mobility={p[1]}, size={p[2]}")

    # Show RG trajectories
    print(f"\n--- RG Trajectories (concept coarsening) ---")
    for name, obj_attrs in sorted(objects.items()):
        y = obj_attrs
        traj = [set(y)]
        for _ in range(5):
            y_next = rg_step(y)
            if y_next == y:
                break
            y = y_next
            traj.append(set(y))
        traj_str = " → ".join(str(t) for t in traj)
        print(f"  {name:8s}: {traj_str}")

    # Reconstruction
    print(f"\n--- Reconstruction ---")
    for fp in sorted(fixed_points, key=lambda x: (len(x), sorted(x))):
        p = boundary_profile(fp)
        candidates = [s for s in states
                      if cl(s) == s and rg_step(s) == s
                      and boundary_profile(s) == p]
        unique = len(candidates) == 1
        print(f"  Profile {p} → {'unique' if unique else f'{len(candidates)} matches'}: "
              f"{set(fp)}")

    print("\n✓ Formal concept analysis demo complete")


if __name__ == "__main__":
    tropical_shortest_path_demo()
    neural_network_interpretability_demo()
    formal_concept_analysis_demo()
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Idempotent Holographic Renormalization — Demonstration

Concrete numerical examples demonstrating the three main theorems:
  A) Boundary signature determines canonical fixed point
  B) Fixed-point profile classification (injectivity)
  C) Certified reconstruction from boundary data

This demo uses a simple finite lattice as the state space.
"""

from __future__ import annotations
import math
from typing import Set, Dict, List, Tuple, Optional, Callable


# ─── Concrete Example: Power-set lattice on {a, b, c} ─────────────────────

# Elements are subsets of {0, 1, 2}, encoded as frozensets
ALL_ELEMENTS = [frozenset(s) for i in range(8)
                for s in [set()]
                if True  # placeholder
               ]

def powerset_3() -> List[frozenset]:
    """All subsets of {0, 1, 2}."""
    result = []
    for mask in range(8):
        s = frozenset(i for i in range(3) if mask & (1 << i))
        result.append(s)
    return result


def demo_powerset_lattice():
    """Demonstrate holographic renormalization on the powerset lattice P({0,1,2}).

    - Closure: union with {0} (cl(S) = S ∪ {0})
    - Scale map R: union with {1} (R(S) = S ∪ {1})
    - Boundary observables: |S|, 2 ∈ S?, S ∩ {0,1}
    """
    print("=" * 70)
    print("DEMO: Holographic Renormalization on Powerset Lattice P({0,1,2})")
    print("=" * 70)

    elements = powerset_3()
    print(f"\nElements ({len(elements)} total):")
    for s in sorted(elements, key=lambda x: (len(x), sorted(x))):
        print(f"  {set(s) if s else '{}'}")

    # Closure: union with {0}
    def cl(s: frozenset) -> frozenset:
        return s | frozenset({0})

    # Scale map: union with {1}
    def R(s: frozenset) -> frozenset:
        return s | frozenset({1})

    # RG step: cl ∘ R
    def rg_step(s: frozenset) -> frozenset:
        return cl(R(s))

    print("\n--- Verifying closure axioms ---")
    # Extensive: S ⊆ cl(S)
    assert all(s <= cl(s) for s in elements), "Extensivity failed"
    print("  ✓ Extensive: S ⊆ cl(S) = S ∪ {0}")

    # Idempotent: cl(cl(S)) = cl(S)
    assert all(cl(cl(s)) == cl(s) for s in elements), "Idempotency failed"
    print("  ✓ Idempotent: cl(cl(S)) = cl(S)")

    # R compatibility: cl(R(S)) = cl(R(cl(S)))
    assert all(cl(R(s)) == cl(R(cl(s))) for s in elements), "R-compat failed"
    print("  ✓ R-compatible: cl(R(S)) = cl(R(cl(S)))")

    # Boundary observables
    def b1(s: frozenset) -> int:
        """Observable 1: cardinality."""
        return len(s)

    def b2(s: frozenset) -> int:
        """Observable 2: does S contain 2?"""
        return 1 if 2 in s else 0

    def b3(s: frozenset) -> int:
        """Observable 3: |S ∩ {0,1}|."""
        return len(s & frozenset({0, 1}))

    boundary = [b1, b2, b3]
    boundary_names = ["|S|", "2∈S?", "|S∩{0,1}|"]

    def profile(s: frozenset) -> Tuple[int, ...]:
        return tuple(b(s) for b in boundary)

    # Compute RG trajectories
    print("\n--- RG Trajectories ---")
    print(f"{'Element':<15} {'rgStep(S)':<15} {'rgStep²(S)':<15} {'Fixed?'}")
    print("-" * 60)

    canonical: Dict[frozenset, frozenset] = {}
    for s in sorted(elements, key=lambda x: (len(x), sorted(x))):
        y = s
        traj = [y]
        for _ in range(5):
            y = rg_step(y)
            traj.append(y)
            if y == traj[-2]:
                break
        canonical[s] = traj[-1]
        fixed = "✓" if rg_step(traj[-1]) == traj[-1] else ""
        s_str = str(set(s)) if s else "{}"
        t1 = str(set(traj[1])) if len(traj) > 1 else ""
        t2 = str(set(traj[2])) if len(traj) > 2 else ""
        print(f"  {s_str:<13} {t1:<15} {t2:<15} {fixed}")

    # Identify fixed points
    fixed_points = [s for s in elements
                    if cl(s) == s and rg_step(s) == s]
    print(f"\n--- Closed RG-Fixed Points ({len(fixed_points)}) ---")
    for fp in sorted(fixed_points, key=lambda x: (len(x), sorted(x))):
        fp_str = str(set(fp)) if fp else "{}"
        p = profile(fp)
        print(f"  {fp_str:<15} profile = {p}  "
              f"({', '.join(f'{n}={v}' for n, v in zip(boundary_names, p))})")

    # Verify separation
    profiles = [profile(fp) for fp in fixed_points]
    sep_holds = len(profiles) == len(set(profiles))
    print(f"\n--- Boundary Separation ---")
    print(f"  Separation holds: {'✓' if sep_holds else '✗'}")
    if sep_holds:
        print("  → Distinct fixed points have distinct boundary profiles")

    # THEOREM A: Boundary signature determines canonical fixed point
    print("\n" + "=" * 70)
    print("THEOREM A: Boundary Observability")
    print("=" * 70)
    print("Testing: same boundary signature → same canonical fixed point\n")

    # Group elements by canonical fixed point
    classes: Dict[frozenset, List[frozenset]] = {}
    for s, fp in canonical.items():
        classes.setdefault(fp, []).append(s)

    for fp, members in sorted(classes.items(), key=lambda x: len(x[0])):
        fp_str = str(set(fp)) if fp else "{}"
        print(f"  Canonical fixed point: {fp_str}")
        for m in sorted(members, key=lambda x: (len(x), sorted(x))):
            m_str = str(set(m)) if m else "{}"
            # Compute boundary signature at depth 0 and depth 1
            sig0 = profile(m)
            sig1 = profile(rg_step(m))
            sig2 = profile(rg_step(rg_step(m)))
            print(f"    {m_str:<13} sig = {sig0} → {sig1} → {sig2}")
        print()

    # Verify: elements with same full boundary signature have same canonical FP
    print("  Verification:")
    all_ok = True
    for s1 in elements:
        for s2 in elements:
            # Check if full signatures agree
            sig_agree = True
            y1, y2 = s1, s2
            for _ in range(5):
                if profile(y1) != profile(y2):
                    sig_agree = False
                    break
                y1, y2 = rg_step(y1), rg_step(y2)
            if sig_agree and canonical[s1] != canonical[s2]:
                s1_str = str(set(s1)) if s1 else "{}"
                s2_str = str(set(s2)) if s2 else "{}"
                print(f"  ✗ COUNTEREXAMPLE: {s1_str} and {s2_str}")
                all_ok = False
    if all_ok:
        print("  ✓ All elements with matching boundary signatures share "
              "canonical fixed points")

    # THEOREM B: Profile classification
    print("\n" + "=" * 70)
    print("THEOREM B: Fixed-Point Profile Classification")
    print("=" * 70)
    print("Testing: boundary profile is injective on fixed points\n")

    profile_map: Dict[Tuple, frozenset] = {}
    injective = True
    for fp in fixed_points:
        p = profile(fp)
        if p in profile_map:
            fp_str = str(set(fp)) if fp else "{}"
            other_str = str(set(profile_map[p])) if profile_map[p] else "{}"
            print(f"  ✗ Collision: {fp_str} and {other_str} have profile {p}")
            injective = False
        profile_map[p] = fp
    if injective:
        print("  ✓ Profile map is injective on fixed points")
        print(f"  → {len(fixed_points)} fixed points ↔ "
              f"{len(fixed_points)} distinct profiles")

    # THEOREM C: Certified reconstruction
    print("\n" + "=" * 70)
    print("THEOREM C: Certified Reconstruction")
    print("=" * 70)
    print("Testing: reconstruction from boundary profile\n")

    for fp in sorted(fixed_points, key=lambda x: (len(x), sorted(x))):
        p = profile(fp)
        # Reconstruct: find the unique fixed point with this profile
        candidates = [x for x in elements
                      if cl(x) == x and rg_step(x) == x and profile(x) == p]
        fp_str = str(set(fp)) if fp else "{}"
        if len(candidates) == 1 and candidates[0] == fp:
            print(f"  ✓ Profile {p} → reconstructed {fp_str} (unique)")
        elif len(candidates) == 1:
            c_str = str(set(candidates[0])) if candidates[0] else "{}"
            print(f"  ✗ Profile {p} → reconstructed {c_str}, expected {fp_str}")
        else:
            print(f"  ✗ Profile {p} → {len(candidates)} candidates")

    # End-to-end: from any element, compute canonical FP, then reconstruct
    print("\n  End-to-end reconstruction from arbitrary elements:")
    for s in sorted(elements, key=lambda x: (len(x), sorted(x))):
        fp = canonical[s]
        fp_profile = profile(fp)
        reconstructed = [x for x in elements
                         if cl(x) == x and rg_step(x) == x
                         and profile(x) == fp_profile]
        s_str = str(set(s)) if s else "{}"
        fp_str = str(set(fp)) if fp else "{}"
        ok = len(reconstructed) == 1 and reconstructed[0] == fp
        status = "✓" if ok else "✗"
        print(f"    {s_str:<13} → canon = {fp_str:<15} → "
              f"reconstruct(profile={fp_profile}) = {status}")


def demo_convergence_analysis():
    """Analyze convergence speed of RG trajectories."""
    print("\n" + "=" * 70)
    print("CONVERGENCE ANALYSIS")
    print("=" * 70)

    # Use a larger lattice: divisors of 360
    n = 360
    elements = [d for d in range(1, n + 1) if n % d == 0]
    print(f"\nDivisor lattice of {n}: {len(elements)} elements")

    def cl(x: int) -> int:
        v = math.lcm(x, 6)
        return v if n % v == 0 else n

    def R(x: int) -> int:
        v = math.lcm(x, 5)
        return v if n % v == 0 else n

    def rg_step(x: int) -> int:
        return cl(R(x))

    convergence_steps = []
    for x in elements:
        y = x
        steps = 0
        for i in range(100):
            y_next = rg_step(y)
            steps = i + 1
            if y_next == y:
                break
            y = y_next
        convergence_steps.append((x, steps, y))

    max_steps = max(s for _, s, _ in convergence_steps)
    print(f"Maximum convergence steps: {max_steps}")
    print(f"Average convergence steps: "
          f"{sum(s for _, s, _ in convergence_steps) / len(convergence_steps):.2f}")

    # Distribution
    from collections import Counter
    dist = Counter(s for _, s, _ in convergence_steps)
    print(f"\nConvergence step distribution:")
    for steps in sorted(dist):
        bar = "█" * dist[steps]
        print(f"  {steps} steps: {dist[steps]:3d} elements {bar}")


if __name__ == "__main__":
    demo_powerset_lattice()
    demo_convergence_analysis()
    print("\n✓ All demonstrations complete.")


#!/usr/bin/env python3
"""Generate PACKAGE.json by reading all deliverables."""

import json
import base64
import sys

def read_file(path):
    with open(path, "r") as f:
        return f.read()

def read_binary_as_base64(path):
    with open(path, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode("utf-8")

# Read all source files
article = read_file("ARTICLE.md")
research_paper = read_file("RESEARCH_PAPER.md")
future_directions = read_file("FUTURE_DIRECTIONS.md")
lean_code = read_file("Bridges/AlgebraEMLPhysics/IdempotentHolographicRenormalization.lean")
demo_code = read_file("demo.py")
algorithms_code = read_file("algorithms.py")
applications_code = read_file("applications.py")
visualizations_code = read_file("visualizations.py")

# Read visualization images
img_rg_flow = read_binary_as_base64("rg_flow.png")
img_convergence = read_binary_as_base64("convergence.png")
img_profile = read_binary_as_base64("profile_heatmap.png")
img_phase = read_binary_as_base64("phase_diagram.png")

package = {
    "title": "Idempotent Holographic Renormalization via Closure Boundary Flows and Certified Bulk Fixed-Point Reconstruction",
    "domain": "Algebra–EML–Physics Bridges",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Holographic Renormalization on Powerset Lattice",
            "code": demo_code
        },
        {
            "name": "Real-World Applications (Tropical Graphs, Neural Nets, Concept Analysis)",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "RG Flow Computation (ComputeCanonicalFixed)",
            "pseudocode": (
                "Input: element x, closure cl, scale map R\n"
                "Output: canonical fixed point\n\n"
                "1. y ← x\n"
                "2. repeat\n"
                "3.   y_prev ← y\n"
                "4.   y ← cl(R(y))\n"
                "5. until y = y_prev\n"
                "6. return y\n\n"
                "Complexity: O(|C|) iterations, O(T_cl + T_R) per step"
            ),
            "code": algorithms_code
        },
        {
            "name": "Certified Fixed-Point Reconstruction",
            "pseudocode": (
                "Input: boundary profile p, observables B, elements C\n"
                "Output: unique closed RG-fixed point with profile p\n\n"
                "1. for each x in C:\n"
                "2.   if IsClosed(x) and IsRGFixed(x):\n"
                "3.     if forall b in B: b(x) = p(b):\n"
                "4.       return x\n"
                "5. return None\n\n"
                "Correctness: Sound and complete by Theorems 3.7-3.8.\n"
                "Complexity: O(|C| * (T_cl + T_R + |B| * T_eval))"
            ),
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "RG Flow on Powerset Lattice",
            "data": img_rg_flow
        },
        {
            "name": "Convergence Behavior",
            "data": img_convergence
        },
        {
            "name": "Boundary Profile Heatmap",
            "data": img_profile
        },
        {
            "name": "RG Phase Diagram",
            "data": img_phase
        }
    ],
    "lean_proofs": lean_code
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} bytes)")


#!/usr/bin/env python3
"""
Visualizations for Idempotent Holographic Renormalization.

Generates matplotlib figures showing:
1. RG flow diagram on the powerset lattice
2. Convergence behavior across lattice sizes
3. Boundary profile classification heatmap
4. RG trajectory phase diagram
"""

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math
import base64
from io import BytesIO
from typing import Dict, List, Tuple, FrozenSet


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format="png", dpi=150, bbox_inches="tight",
                facecolor="white", edgecolor="none")
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode("utf-8")
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def visualize_rg_flow():
    """Visualize the RG flow on the powerset lattice P({0,1,2})."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Powerset lattice positions (Hasse diagram layout)
    def set_to_label(s):
        if not s:
            return "∅"
        return "{" + ",".join(str(x) for x in sorted(s)) + "}"

    elements = []
    for mask in range(8):
        s = frozenset(i for i in range(3) if mask & (1 << i))
        elements.append(s)

    # Positions in Hasse diagram (y = level = cardinality)
    positions = {
        frozenset():       (0, 0),
        frozenset({0}):    (-1.5, 1),
        frozenset({1}):    (0, 1),
        frozenset({2}):    (1.5, 1),
        frozenset({0,1}):  (-1.5, 2),
        frozenset({0,2}):  (0, 2),
        frozenset({1,2}):  (1.5, 2),
        frozenset({0,1,2}): (0, 3),
    }

    # Closure: union with {0}
    def cl(s): return s | frozenset({0})
    def R(s): return s | frozenset({1})
    def rg_step(s): return cl(R(s))

    # Compute canonical fixed points
    canonical = {}
    for s in elements:
        y = s
        for _ in range(5):
            y_next = rg_step(y)
            if y_next == y:
                break
            y = y_next
        canonical[s] = y

    # Draw Hasse diagram edges (covering relations)
    for s1 in elements:
        for s2 in elements:
            if s1 < s2 and len(s2) - len(s1) == 1:
                x1, y1 = positions[s1]
                x2, y2 = positions[s2]
                ax.plot([x1, x2], [y1, y2], "k-", alpha=0.2, linewidth=1)

    # Draw RG flow arrows
    for s in elements:
        target = rg_step(s)
        if target != s:
            x1, y1 = positions[s]
            x2, y2 = positions[target]
            dx, dy = x2 - x1, y2 - y1
            length = math.sqrt(dx**2 + dy**2)
            if length > 0:
                # Shorten arrow slightly
                factor = 0.85
                ax.annotate("",
                    xy=(x1 + dx*factor, y1 + dy*factor),
                    xytext=(x1 + dx*0.15, y1 + dy*0.15),
                    arrowprops=dict(arrowstyle="->", color="blue",
                                   lw=2, alpha=0.7))

    # Color nodes by canonical fixed point
    colors = {frozenset({0,1}): "#4CAF50", frozenset({0,1,2}): "#FF9800"}
    for s in elements:
        x, y = positions[s]
        color = colors.get(canonical[s], "gray")
        is_fixed = rg_step(s) == s
        size = 800 if is_fixed else 500
        edgecolor = "red" if is_fixed else "black"
        linewidth = 3 if is_fixed else 1
        ax.scatter([x], [y], s=size, c=color, edgecolors=edgecolor,
                  linewidths=linewidth, zorder=5)
        ax.text(x, y - 0.25, set_to_label(s), ha="center", va="top",
               fontsize=10, fontweight="bold")

    # Legend
    green_patch = mpatches.Patch(color="#4CAF50", label="Class → {0,1}")
    orange_patch = mpatches.Patch(color="#FF9800", label="Class → {0,1,2}")
    fixed_marker = plt.Line2D([0], [0], marker="o", color="w",
                              markerfacecolor="gray", markeredgecolor="red",
                              markeredgewidth=2, markersize=12,
                              label="RG Fixed Point")
    ax.legend(handles=[green_patch, orange_patch, fixed_marker],
             loc="upper right", fontsize=11)

    ax.set_title("RG Flow on Powerset Lattice P({0,1,2})\n"
                "Arrows show rgStep = cl ∘ R; colors show canonical fixed-point class",
                fontsize=13)
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-0.5, 3.8)
    ax.axis("off")

    return fig_to_base64(fig)


def visualize_convergence():
    """Visualize convergence behavior across different lattice sizes."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Test convergence on divisor lattices of varying sizes
    test_numbers = [12, 24, 36, 60, 120, 180, 360, 720, 1260]
    sizes = []
    max_steps_list = []
    avg_steps_list = []

    for n in test_numbers:
        elements = [d for d in range(1, n + 1) if n % d == 0]
        num_elts = len(elements)

        def cl(x, n=n):
            v = math.lcm(x, 2)
            return v if n % v == 0 else n

        def R(x, n=n):
            v = math.lcm(x, 3)
            return v if n % v == 0 else n

        def rg_step(x, n=n):
            return cl(R(x, n), n)

        steps_list = []
        for x in elements:
            y = x
            steps = 0
            for _ in range(100):
                y_next = rg_step(y, n)
                steps += 1
                if y_next == y:
                    break
                y = y_next
            steps_list.append(steps)

        sizes.append(num_elts)
        max_steps_list.append(max(steps_list))
        avg_steps_list.append(sum(steps_list) / len(steps_list))

    # Plot 1: Max and average convergence steps vs lattice size
    ax = axes[0]
    ax.plot(sizes, max_steps_list, "ro-", linewidth=2, markersize=8,
           label="Max steps")
    ax.plot(sizes, avg_steps_list, "bs-", linewidth=2, markersize=8,
           label="Average steps")
    ax.set_xlabel("Lattice size |C|", fontsize=12)
    ax.set_ylabel("Convergence steps", fontsize=12)
    ax.set_title("RG Convergence Speed vs Lattice Size", fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xscale("log")

    # Plot 2: Convergence step distribution for n=360
    ax = axes[1]
    n = 360
    elements = [d for d in range(1, n + 1) if n % d == 0]

    def cl360(x):
        v = math.lcm(x, 6)
        return v if 360 % v == 0 else 360

    def R360(x):
        v = math.lcm(x, 5)
        return v if 360 % v == 0 else 360

    step_counts = []
    for x in elements:
        y = x
        steps = 0
        for _ in range(100):
            y_next = cl360(R360(y))
            steps += 1
            if y_next == y:
                break
            y = y_next
        step_counts.append(steps)

    from collections import Counter
    dist = Counter(step_counts)
    steps_vals = sorted(dist.keys())
    counts = [dist[s] for s in steps_vals]

    ax.bar(steps_vals, counts, color="#2196F3", edgecolor="navy", alpha=0.8)
    ax.set_xlabel("Steps to convergence", fontsize=12)
    ax.set_ylabel("Number of elements", fontsize=12)
    ax.set_title(f"Convergence Distribution (divisors of {n})", fontsize=13)
    ax.grid(True, alpha=0.3, axis="y")

    plt.tight_layout()
    return fig_to_base64(fig)


def visualize_profile_heatmap():
    """Heatmap of boundary profiles across fixed points."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # Use divisors of 60
    n = 60
    elements = sorted(d for d in range(1, n + 1) if n % d == 0)

    def cl(x):
        v = math.lcm(x, 2)
        return v if n % v == 0 else n

    def R(x):
        v = math.lcm(x, 3)
        return v if n % v == 0 else n

    def rg_step(x):
        return cl(R(x))

    # Find fixed points
    fps = [x for x in elements if cl(x) == x and rg_step(x) == x]

    # More boundary observables
    observables = [
        ("x mod 4", lambda x: x % 4),
        ("x mod 5", lambda x: x % 5),
        ("x ≥ 10", lambda x: 1 if x >= 10 else 0),
        ("x mod 3", lambda x: x % 3),
        ("log₂(x)", lambda x: int(math.log2(x)) if x > 0 else 0),
    ]

    obs_names = [name for name, _ in observables]
    obs_fns = [fn for _, fn in observables]

    # Build profile matrix
    profile_matrix = np.array([[fn(fp) for fn in obs_fns] for fp in fps])

    im = ax.imshow(profile_matrix, cmap="YlOrRd", aspect="auto")
    ax.set_xticks(range(len(obs_names)))
    ax.set_xticklabels(obs_names, rotation=45, ha="right", fontsize=11)
    ax.set_yticks(range(len(fps)))
    ax.set_yticklabels([str(fp) for fp in fps], fontsize=11)
    ax.set_ylabel("Fixed Point", fontsize=12)
    ax.set_xlabel("Boundary Observable", fontsize=12)
    ax.set_title("Boundary Profiles of Closed RG-Fixed Points\n"
                "(Divisors of 60)", fontsize=13)

    # Add text annotations
    for i in range(len(fps)):
        for j in range(len(obs_names)):
            val = profile_matrix[i, j]
            color = "white" if val > profile_matrix.max() * 0.6 else "black"
            ax.text(j, i, str(int(val)), ha="center", va="center",
                   color=color, fontweight="bold", fontsize=11)

    plt.colorbar(im, ax=ax, label="Observable value")
    plt.tight_layout()
    return fig_to_base64(fig)


def visualize_trajectory_phase():
    """Phase diagram showing RG trajectory structure."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Use a 2D lattice: pairs (a, b) with a | 12, b | 12
    divs = sorted(d for d in range(1, 13) if 12 % d == 0)
    # divs = [1, 2, 3, 4, 6, 12]
    elements = [(a, b) for a in divs for b in divs]

    def cl(p):
        a, b = p
        a2 = math.lcm(a, 2)
        b2 = math.lcm(b, 2)
        return (a2 if 12 % a2 == 0 else 12,
                b2 if 12 % b2 == 0 else 12)

    def R(p):
        a, b = p
        a2 = math.lcm(a, 3)
        b2 = math.lcm(b, 3)
        return (a2 if 12 % a2 == 0 else 12,
                b2 if 12 % b2 == 0 else 12)

    def rg_step(p):
        return cl(R(p))

    # Find canonical fixed points
    canonical = {}
    for p in elements:
        y = p
        for _ in range(20):
            y_next = rg_step(y)
            if y_next == y:
                break
            y = y_next
        canonical[p] = y

    # Fixed points
    fps = list(set(canonical.values()))
    fp_colors = plt.cm.Set1(np.linspace(0, 1, max(len(fps), 2)))
    fp_color_map = {fp: fp_colors[i] for i, fp in enumerate(fps)}

    # Plot each element colored by its canonical fixed point
    for p in elements:
        fp = canonical[p]
        x_pos = divs.index(p[0])
        y_pos = divs.index(p[1])
        is_fp = rg_step(p) == p
        size = 300 if is_fp else 150
        edgecolor = "black" if is_fp else "gray"
        linewidth = 3 if is_fp else 0.5
        ax.scatter([x_pos], [y_pos], s=size, c=[fp_color_map[fp]],
                  edgecolors=edgecolor, linewidths=linewidth, zorder=5)

    # Draw RG flow arrows
    for p in elements:
        target = rg_step(p)
        if target != p:
            x1 = divs.index(p[0])
            y1 = divs.index(p[1])
            x2 = divs.index(target[0])
            y2 = divs.index(target[1])
            dx, dy = x2 - x1, y2 - y1
            if dx != 0 or dy != 0:
                ax.annotate("",
                    xy=(x1 + dx*0.7, y1 + dy*0.7),
                    xytext=(x1 + dx*0.1, y1 + dy*0.1),
                    arrowprops=dict(arrowstyle="->", color="navy",
                                   lw=1.5, alpha=0.5))

    ax.set_xticks(range(len(divs)))
    ax.set_xticklabels(divs, fontsize=12)
    ax.set_yticks(range(len(divs)))
    ax.set_yticklabels(divs, fontsize=12)
    ax.set_xlabel("First coordinate (divisors of 12)", fontsize=12)
    ax.set_ylabel("Second coordinate (divisors of 12)", fontsize=12)
    ax.set_title("RG Phase Diagram on 2D Divisor Lattice\n"
                "Colors show canonical fixed-point class; "
                "bold borders mark fixed points",
                fontsize=13)
    ax.grid(True, alpha=0.2)

    # Legend
    handles = []
    for fp in sorted(fps):
        handles.append(mpatches.Patch(color=fp_color_map[fp],
                                      label=f"Class → {fp}"))
    ax.legend(handles=handles, loc="upper left", fontsize=10)

    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    img1 = visualize_rg_flow()
    print(f"  RG flow diagram: {len(img1)} chars")

    img2 = visualize_convergence()
    print(f"  Convergence plot: {len(img2)} chars")

    img3 = visualize_profile_heatmap()
    print(f"  Profile heatmap: {len(img3)} chars")

    img4 = visualize_trajectory_phase()
    print(f"  Phase diagram: {len(img4)} chars")

    # Save to files
    for name, data in [("rg_flow.png", img1), ("convergence.png", img2),
                       ("profile_heatmap.png", img3), ("phase_diagram.png", img4)]:
        raw = base64.b64decode(data.split(",")[1])
        with open(name, "wb") as f:
            f.write(raw)
        print(f"  Saved {name}")

    print("✓ All visualizations generated")
