#!/usr/bin/env python3
"""
Algorithms for Counterpoint Category Theory

Type-hinted implementations of the core algorithms used in the
formalization of first-species counterpoint as category theory.
"""

from typing import Optional


# === Core Types ===

PitchClass = int  # Elements of Z/12Z
Interval = int    # Consonant interval (0, 3, 4, 7, 8, 9)
StepBound = int   # Maximum step size for voice leading

CONSONANT_INTERVALS: list[Interval] = [0, 3, 4, 7, 8, 9]
PERFECT_CONSONANCES: set[Interval] = {0, 7}
IMPERFECT_CONSONANCES: set[Interval] = {3, 4, 8, 9}


# === Algorithm 1: Step Distance ===

def step_distance(x: PitchClass) -> int:
    """
    Compute the minimum step distance for a pitch class motion.
    
    Pseudocode:
        stepDist(x) = min(x mod 12, 12 - (x mod 12))
    
    This gives the shortest path around the chromatic circle.
    """
    v = x % 12
    return min(v, 12 - v)


# === Algorithm 2: Chromatic Distance ===

def chromatic_distance(i: Interval, j: Interval) -> int:
    """
    Compute chromatic circle distance between two intervals.
    
    Pseudocode:
        chromDist(i, j) = stepDist(j - i)
    """
    return step_distance(j - i)


# === Algorithm 3: Valid Transition Check ===

def is_valid_transition(i: Interval, j: Interval, max_step: StepBound) -> bool:
    """
    Check if a valid voice leading exists from interval i to j.
    
    Pseudocode:
        validTransition(i, j, s):
            for δb in Z/12Z:
                for δs in Z/12Z:
                    if j ≡ i + δs - δb (mod 12)
                       AND stepDist(δb) ≤ s
                       AND stepDist(δs) ≤ s
                       AND NOT (δb = δs ≠ 0 AND j ∈ Perfect):
                        return True
            return False
    
    Time complexity: O(144) = O(1) since the search space is bounded.
    """
    if i not in CONSONANT_INTERVALS or j not in CONSONANT_INTERVALS:
        return False
    
    for db in range(12):
        for ds in range(12):
            if (i + ds - db) % 12 == j % 12:
                if step_distance(db) <= max_step and step_distance(ds) <= max_step:
                    if not (db == ds and db != 0 and j % 12 in PERFECT_CONSONANCES):
                        return True
    return False


# === Algorithm 4: Metric Bridge (O(1) shortcut) ===

def metric_bridge_check(i: Interval, j: Interval) -> bool:
    """
    O(1) check for step-2 transitions using the Metric Bridge Theorem.
    
    Pseudocode:
        metricBridge(i, j) = chromDist(i, j) ≤ 4
    
    This is equivalent to is_valid_transition(i, j, 2) but runs in O(1)
    instead of O(144), thanks to the Metric Bridge Theorem.
    """
    return chromatic_distance(i, j) <= 4


# === Algorithm 5: Find Shortest Path ===

def find_shortest_path(
    i: Interval, j: Interval, max_step: StepBound
) -> Optional[list[Interval]]:
    """
    Find shortest path in the counterpoint graph using BFS.
    
    Pseudocode:
        BFS from i, exploring valid transitions at step bound s.
        Returns shortest path [i, ..., j] or None if unreachable.
    
    By the Diameter Theorem, at step bound 2, paths have length ≤ 2.
    At step bound 3+, all direct paths exist (length 1).
    """
    from collections import deque
    
    if i == j:
        return [i]
    
    queue: deque[list[Interval]] = deque([[i]])
    visited: set[Interval] = {i}
    
    while queue:
        path = queue.popleft()
        current = path[-1]
        
        for next_interval in CONSONANT_INTERVALS:
            if next_interval not in visited:
                if is_valid_transition(current, next_interval, max_step):
                    new_path = path + [next_interval]
                    if next_interval == j:
                        return new_path
                    visited.add(next_interval)
                    queue.append(new_path)
    
    return None


# === Algorithm 6: Connected Components ===

def find_components(max_step: StepBound) -> list[set[Interval]]:
    """
    Find connected components of the counterpoint graph.
    
    Pseudocode:
        Standard DFS/BFS component finding on the transition graph.
    
    Results by step bound:
        Step 1: {0}, {3,4}, {7,8,9}  (3 components)
        Step 2: {0,3,4,7,8,9}        (1 component, connected)
        Step 3+: {0,3,4,7,8,9}       (1 component, complete)
    """
    remaining = set(CONSONANT_INTERVALS)
    components: list[set[Interval]] = []
    
    while remaining:
        start = min(remaining)
        component: set[Interval] = set()
        stack = [start]
        
        while stack:
            v = stack.pop()
            if v in remaining:
                remaining.discard(v)
                component.add(v)
                for w in CONSONANT_INTERVALS:
                    if w in remaining and is_valid_transition(v, w, max_step):
                        stack.append(w)
        
        components.append(component)
    
    return components


# === Algorithm 7: Transition Matrix ===

def transition_matrix(max_step: StepBound) -> list[list[bool]]:
    """
    Compute the full adjacency matrix of the counterpoint graph.
    
    Returns a 6×6 boolean matrix indexed by CONSONANT_INTERVALS.
    """
    return [
        [is_valid_transition(i, j, max_step) for j in CONSONANT_INTERVALS]
        for i in CONSONANT_INTERVALS
    ]


# === Algorithm 8: Graph Diameter ===

def compute_diameter(max_step: StepBound) -> int:
    """
    Compute the diameter of the counterpoint graph.
    Uses all-pairs BFS.
    """
    max_dist = 0
    for i in CONSONANT_INTERVALS:
        for j in CONSONANT_INTERVALS:
            path = find_shortest_path(i, j, max_step)
            if path is None:
                return float('inf')  # type: ignore
            max_dist = max(max_dist, len(path) - 1)
    return max_dist


# === Verification ===

def verify_metric_bridge() -> bool:
    """Verify the Metric Bridge Theorem for all consonant pairs."""
    for i in CONSONANT_INTERVALS:
        for j in CONSONANT_INTERVALS:
            brute = is_valid_transition(i, j, 2)
            metric = metric_bridge_check(i, j)
            if brute != metric:
                return False
    return True


if __name__ == "__main__":
    print("Verifying Metric Bridge Theorem...", end=" ")
    assert verify_metric_bridge(), "FAILED"
    print("✓ Verified for all 36 pairs")
    
    print("\nGraph diameters:")
    for s in [1, 2, 3]:
        d = compute_diameter(s)
        print(f"  Step bound {s}: diameter = {d}")
    
    print("\nConnected components:")
    for s in [1, 2, 3]:
        comps = find_components(s)
        print(f"  Step bound {s}: {len(comps)} component(s) — {comps}")
    
    print("\nShortest paths for blocked pairs at step 2:")
    blocked = [(0, 7), (3, 8), (3, 9), (4, 9)]
    for i, j in blocked:
        path = find_shortest_path(i, j, 2)
        names = {0: "P1", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}
        path_str = " → ".join(names[p] for p in path) if path else "unreachable"
        print(f"  {names[i]} → {names[j]}: {path_str}")
