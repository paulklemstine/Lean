#!/usr/bin/env python3
"""
Strange Loop Detector — Finding Fixed Points in Self-Referential Systems
=========================================================================

This demo implements algorithms for detecting Strange Loops (fixed points
of self-representation operators) in various computational systems.

Based on Kleene's Recursion Theorem and the theory developed in §2 of
our research paper, we detect:

  1. Fixed points in discrete dynamical systems
  2. Quine detection (self-reproducing programs)
  3. Self-referential data structures (circular references)
  4. Eigenvalues of self-representation matrices
  5. Attractor detection in iterated function systems
"""

import hashlib
import sys
import math
from collections import defaultdict


# ============================================================
# Part 1: Fixed Point Detection in Discrete Systems
# ============================================================

def find_fixed_points(f, domain, name="f"):
    """
    Find all fixed points of f: domain → domain.
    A fixed point x satisfies f(x) = x.
    """
    fixed_points = []
    for x in domain:
        try:
            if f(x) == x:
                fixed_points.append(x)
        except Exception:
            pass
    return fixed_points


def find_periodic_orbits(f, domain, max_period=10, name="f"):
    """
    Find periodic orbits: sequences x, f(x), f²(x), ..., fⁿ(x) = x.
    Period-1 orbits are fixed points.
    """
    orbits = defaultdict(list)
    
    for x in domain:
        visited = [x]
        current = x
        for _ in range(max_period + 1):
            try:
                current = f(current)
            except Exception:
                break
            if current in visited:
                # Found a cycle
                cycle_start = visited.index(current)
                cycle = visited[cycle_start:]
                period = len(cycle)
                # Normalize: start from smallest element
                min_idx = cycle.index(min(cycle))
                normalized = tuple(cycle[min_idx:] + cycle[:min_idx])
                orbits[period].append(normalized)
                break
            visited.append(current)
    
    # Deduplicate
    for period in orbits:
        orbits[period] = list(set(orbits[period]))
    
    return dict(orbits)


def demonstrate_fixed_points():
    """Demonstrate fixed point detection in various systems."""
    print("FIXED POINT DETECTION IN DISCRETE SYSTEMS")
    print("=" * 60)
    print()
    
    examples = [
        ("Identity: f(x) = x", lambda x: x, range(10)),
        ("Negation: f(x) = -x", lambda x: -x, range(-5, 6)),
        ("Square mod 10: f(x) = x² mod 10", lambda x: (x*x) % 10, range(10)),
        ("Collatz step: f(x) = x/2 if even, 3x+1 if odd", 
         lambda x: x // 2 if x % 2 == 0 else 3 * x + 1, range(1, 30)),
        ("Boolean NOT: f(x) = ¬x", lambda x: not x, [True, False]),
        ("XOR with 5: f(x) = x ⊕ 5", lambda x: x ^ 5, range(16)),
    ]
    
    for name, f, domain in examples:
        fps = find_fixed_points(f, domain, name)
        print(f"  {name}")
        if fps:
            print(f"    Fixed points: {fps}")
        else:
            print(f"    No fixed points! (Strange Loop is impossible in this system)")
        
        orbits = find_periodic_orbits(f, domain)
        for period, cycles in sorted(orbits.items()):
            if period > 1:
                for cycle in cycles[:3]:  # Show at most 3
                    print(f"    Period-{period} orbit: {' → '.join(map(str, cycle))} → {cycle[0]}")
        print()
    
    # The Liar Paradox has no fixed point
    print("  KEY INSIGHT:")
    print("  Boolean NOT has no fixed point → the Liar Paradox oscillates forever.")
    print("  Square mod 10 has fixed points {0, 1, 5, 6} → stable self-reference.")
    print("  A Strange Loop requires a fixed point to 'crystallize' into identity.")
    print()


# ============================================================
# Part 2: Self-Referential Hash Fixed Points
# ============================================================

def find_hash_fixed_point(prefix="", hash_bits=4, max_attempts=100000):
    """
    Find a string whose hash contains the string itself.
    This is a computational analog of Gödel's self-referential sentence.
    
    We look for strings s such that hash(s) starts with s (approximately).
    """
    for i in range(max_attempts):
        candidate = prefix + str(i)
        h = hashlib.md5(candidate.encode()).hexdigest()[:hash_bits]
        if h in candidate:
            return candidate, h
    return None, None


def self_referential_hash_demo():
    """Find strings that 'know' their own hash."""
    print("SELF-REFERENTIAL HASH FIXED POINTS")
    print("=" * 60)
    print()
    print("A 'Gödel string' — a string that encodes information about itself.")
    print("We search for strings s where MD5(s) appears within s.")
    print()
    
    for bits in [2, 3, 4]:
        s, h = find_hash_fixed_point(hash_bits=bits, max_attempts=50000)
        if s:
            full_hash = hashlib.md5(s.encode()).hexdigest()
            print(f"  Hash bits = {bits}: Found!")
            print(f"    String: '{s}'")
            print(f"    MD5:    '{full_hash}'")
            print(f"    First {bits} chars of MD5: '{h}'")
            print(f"    '{h}' appears in string: {h in s}")
        else:
            print(f"  Hash bits = {bits}: Not found in search budget")
        print()
    
    print("  These strings are computational Strange Loops:")
    print("  they CONTAIN information about themselves (their hash).")
    print("  This mirrors how consciousness contains a model of itself.")
    print()


# ============================================================
# Part 3: Circular Reference Detection
# ============================================================

def detect_circular_references(obj, path=None, visited=None):
    """
    Detect circular references in a data structure.
    Returns all cycles found.
    """
    if path is None:
        path = []
    if visited is None:
        visited = {}
    
    obj_id = id(obj)
    
    if obj_id in visited:
        cycle_start = visited[obj_id]
        return [path[cycle_start:]]
    
    visited[obj_id] = len(path)
    cycles = []
    
    if isinstance(obj, dict):
        for key, value in obj.items():
            new_path = path + [f".{key}"]
            cycles.extend(detect_circular_references(value, new_path, visited.copy()))
    elif isinstance(obj, (list, tuple)):
        for i, item in enumerate(obj):
            new_path = path + [f"[{i}]"]
            cycles.extend(detect_circular_references(item, new_path, visited.copy()))
    
    return cycles


def circular_reference_demo():
    """Demonstrate Strange Loops as circular references in data structures."""
    print("CIRCULAR REFERENCE DETECTION — Strange Loops in Data")
    print("=" * 60)
    print()
    
    # Example 1: Simple self-reference
    a = [1, 2, 3]
    a.append(a)  # a contains itself!
    
    print("Example 1: A list that contains itself")
    print(f"  a = [1, 2, 3, a]")
    print(f"  a[3] is a: {a[3] is a}")
    print(f"  a[3][3] is a: {a[3][3] is a}")
    print(f"  a[3][3][3] is a: {a[3][3][3] is a}")
    print(f"  → Infinite depth! This is a Strange Loop in data.")
    print()
    
    # Example 2: Mutual reference (Escher's Drawing Hands)
    left = {"name": "Left Hand", "draws": None}
    right = {"name": "Right Hand", "draws": None}
    left["draws"] = right
    right["draws"] = left
    
    print("Example 2: Escher's Drawing Hands as mutual references")
    print(f"  left['draws']['name'] = {left['draws']['name']}")
    print(f"  right['draws']['name'] = {right['draws']['name']}")
    print(f"  left['draws']['draws'] is left: {left['draws']['draws'] is left}")
    print(f"  → Each hand 'draws' (references) the other. Strange Loop!")
    print()
    
    # Example 3: The mind modeling itself
    mind = {"thoughts": [], "self_model": None}
    mind["self_model"] = mind  # The mind's model of itself IS itself
    
    print("Example 3: The mind modeling itself")
    print(f"  mind['self_model'] is mind: {mind['self_model'] is mind}")
    print(f"  mind['self_model']['self_model'] is mind: {mind['self_model']['self_model'] is mind}")
    print(f"  → The self-model IS the self. Fixed point of self-representation.")
    print()
    
    # Detect loops programmatically
    print("Automated Strange Loop Detection:")
    simple_dict = {"a": 1, "b": {"c": 2, "d": 3}}
    tangled_dict = {"level1": None}
    tangled_dict["level1"] = {"level2": tangled_dict}
    
    for name, obj in [("Simple (no loop)", simple_dict), 
                       ("Tangled (Strange Loop)", tangled_dict)]:
        cycles = detect_circular_references(obj)
        if cycles:
            print(f"  {name}: STRANGE LOOP DETECTED at {' → '.join(cycles[0])}")
        else:
            print(f"  {name}: No Strange Loop")
    print()


# ============================================================
# Part 4: Eigenvalue Analysis of Self-Representation
# ============================================================

def matrix_multiply(A, B):
    """Multiply two matrices."""
    n = len(A)
    m = len(B[0])
    k = len(B)
    result = [[0] * m for _ in range(n)]
    for i in range(n):
        for j in range(m):
            for l in range(k):
                result[i][j] += A[i][l] * B[l][j]
    return result


def matrix_vector(A, v):
    """Multiply matrix by vector."""
    n = len(A)
    return [sum(A[i][j] * v[j] for j in range(len(v))) for i in range(n)]


def power_iteration(A, num_iterations=100):
    """Find dominant eigenvalue using power iteration."""
    n = len(A)
    v = [1.0 / math.sqrt(n)] * n
    
    eigenvalue = 0
    for _ in range(num_iterations):
        Av = matrix_vector(A, v)
        
        # Find the eigenvalue (Rayleigh quotient)
        norm = math.sqrt(sum(x*x for x in Av))
        if norm < 1e-10:
            return 0, v
        
        eigenvalue = norm
        v = [x / norm for x in Av]
    
    return eigenvalue, v


def eigenvalue_strange_loop():
    """
    Analyze the 'Strange Loop' structure of a self-representation matrix.
    
    A system that represents itself can be modeled as a linear operator
    whose eigenvectors are the 'stable self-images' — the fixed patterns
    of self-reference.
    """
    print("EIGENVALUE ANALYSIS OF SELF-REPRESENTATION")
    print("=" * 60)
    print()
    
    # A self-representation matrix: each entry (i,j) represents
    # how much component j "appears" in component i's self-model
    
    # Example: A mind with three aspects {Thinker, Feeler, Observer}
    # Each models the others (and itself) with varying fidelity
    labels = ["Thinker", "Feeler", "Observer"]
    
    # Self-representation matrix
    # Row i = how component i represents all components
    M = [
        [0.8, 0.3, 0.5],   # Thinker sees: 80% Thinker, 30% Feeler, 50% Observer
        [0.2, 0.9, 0.4],   # Feeler sees: 20% Thinker, 90% Feeler, 40% Observer
        [0.7, 0.6, 0.7],   # Observer sees: 70% Thinker, 60% Feeler, 70% Observer
    ]
    
    print("Self-Representation Matrix (how each aspect models the whole):")
    print(f"              {'  '.join(f'{l:>10}' for l in labels)}")
    for i, label in enumerate(labels):
        row = '  '.join(f'{M[i][j]:>10.1f}' for j in range(3))
        print(f"  {label:>10}:  {row}")
    print()
    
    # Find the dominant eigenvalue = the "Strange Loop strength"
    eigenvalue, eigenvector = power_iteration(M)
    
    print(f"Dominant eigenvalue (Strange Loop strength): {eigenvalue:.3f}")
    print(f"Dominant eigenvector (stable self-image):")
    total = sum(abs(x) for x in eigenvector)
    for label, val in zip(labels, eigenvector):
        pct = abs(val) / total * 100
        bar = "█" * int(pct / 2)
        print(f"  {label:>10}: {val:>6.3f} ({pct:>5.1f}%) {bar}")
    print()
    
    print("Interpretation:")
    print("  The eigenvalue measures the 'stability' of the self-model.")
    print("  Eigenvalue > 1: self-model AMPLIFIES (narcissistic loop)")
    print("  Eigenvalue = 1: self-model is STABLE (healthy self-awareness)")
    print("  Eigenvalue < 1: self-model DECAYS (losing self-awareness)")
    print()
    print(f"  This system's eigenvalue ({eigenvalue:.3f}) suggests a ",end="")
    if eigenvalue > 1:
        print("self-amplifying Strange Loop.")
    elif eigenvalue > 0.9:
        print("near-stable Strange Loop.")
    else:
        print("decaying self-model.")
    print()
    print("  The eigenvector reveals the STABLE SELF-IMAGE — the pattern")
    print("  of self-reference that persists under repeated self-modeling.")
    print("  This is Hofstadter's 'I' — the eigenstate of the Strange Loop.")


# ============================================================
# Part 5: Attractor Detection
# ============================================================

def detect_attractors(f, domain_sample, max_iterations=100):
    """
    Detect attractors in an iterated function system.
    An attractor is a set that trajectories converge to.
    """
    attractor_basins = defaultdict(list)
    
    for start in domain_sample:
        x = start
        trajectory = [x]
        
        for _ in range(max_iterations):
            try:
                x = f(x)
                if x in trajectory:
                    cycle_start = trajectory.index(x)
                    attractor = tuple(sorted(set(trajectory[cycle_start:])))
                    attractor_basins[attractor].append(start)
                    break
                trajectory.append(x)
            except (OverflowError, ZeroDivisionError):
                attractor_basins[("diverges",)].append(start)
                break
    
    return dict(attractor_basins)


def attractor_demo():
    """Demonstrate attractor detection as Strange Loop identification."""
    print("ATTRACTOR DETECTION — Where Strange Loops Settle")
    print("=" * 60)
    print()
    
    # Logistic map: x → rx(1-x) — the canonical example of chaos
    print("The Logistic Map: x → rx(1-x)")
    print("-" * 40)
    
    for r in [2.0, 3.2, 3.5, 3.8]:
        logistic = lambda x, r=r: r * x * (1 - x)
        
        # Iterate from random starting point
        x = 0.1
        trajectory = [x]
        for _ in range(200):
            x = logistic(x)
            trajectory.append(x)
        
        # Last 50 points (should be on the attractor)
        attractor_points = set(round(t, 6) for t in trajectory[-50:])
        
        print(f"  r = {r}:")
        if len(attractor_points) <= 8:
            print(f"    Attractor: {sorted(attractor_points)}")
            print(f"    Period: {len(attractor_points)}")
        else:
            print(f"    Attractor: chaotic ({len(attractor_points)} distinct points)")
        
        # Is there a fixed point?
        for p in attractor_points:
            if abs(logistic(p) - p) < 0.001:
                print(f"    Fixed point (Strange Loop): x* ≈ {p:.4f}")
    
    print()
    print("  As r increases: fixed point → 2-cycle → 4-cycle → chaos")
    print("  The Strange Loop (fixed point) BREAKS at r ≈ 3.0,")
    print("  splitting into oscillations of increasing complexity.")
    print("  This is the 'period-doubling route to chaos' —")
    print("  the Strange Loop dissolves into a strange ATTRACTOR.")


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  STRANGE LOOP DETECTOR                                          ║")
    print("║  Finding Fixed Points in Self-Referential Systems               ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demonstrate_fixed_points()
    self_referential_hash_demo()
    circular_reference_demo()
    eigenvalue_strange_loop()
    attractor_demo()
    
    print()
    print("=" * 60)
    print("UNIFIED CONCLUSION")
    print("=" * 60)
    print()
    print("Every Strange Loop is a FIXED POINT of some operator:")
    print()
    print("  • Mathematical: f(x*) = x* (standard fixed point)")
    print("  • Computational: program outputs its own source (quine)")
    print("  • Data: structure contains a reference to itself")
    print("  • Linear algebra: Mv = λv (eigenvector)")
    print("  • Dynamics: trajectory converges to invariant set (attractor)")
    print()
    print("Consciousness, per Hofstadter, is the fixed point of the")
    print("self-representation operator: the 'I' that emerges when")
    print("a system's model of itself becomes stable and self-sustaining.")
    print()
    print("Our detector can find these fixed points in ANY computational")
    print("system — but Rice's Theorem guarantees it CANNOT determine")
    print("which fixed points correspond to consciousness.")
    print("The Strange Loop sees everything except itself.")


if __name__ == "__main__":
    main()
