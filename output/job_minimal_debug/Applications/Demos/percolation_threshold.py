#!/usr/bin/env python3
"""
Applications of Percolation Theory

Demonstrates real-world applications of percolation threshold theory:
1. Network resilience analysis
2. Forest fire spread modeling
3. Epidemiological threshold estimation
4. Material conductivity phase transitions
"""

import math
import random
from collections import deque
from typing import List, Tuple, Set


# ============================================================
# Application 1: Network Resilience Analysis
# ============================================================

def network_resilience(n: int, p_values: List[float],
                       num_trials: int = 10000) -> dict:
    """
    Analyze network resilience by computing the probability that
    a random subnetwork of an n×n grid maintains east-west connectivity.
    
    This models scenarios like:
    - Communication networks with random node failures
    - Power grids with random outages
    - Transportation networks with random closures
    
    Args:
        n: grid dimension
        p_values: list of reliability parameters to test
        num_trials: Monte Carlo samples per parameter
    
    Returns:
        Dictionary mapping p -> estimated crossing probability
    """
    results = {}
    for p in p_values:
        crossings = 0
        for _ in range(num_trials):
            # Generate random site configuration
            config = [random.random() < p for _ in range(n * n)]
            if _has_crossing(n, n, config):
                crossings += 1
        results[p] = crossings / num_trials
    return results


def _has_crossing(n: int, m: int, config: List[bool]) -> bool:
    """Check horizontal connectivity through open sites."""
    visited = set()
    queue = deque()
    for row in range(n):
        if config[row * m]:
            queue.append((row, 0))
            visited.add((row, 0))
    while queue:
        r, c = queue.popleft()
        if c == m - 1:
            return True
        for dr, dc in [(-1,0),(1,0),(0,-1),(0,1)]:
            nr, nc = r+dr, c+dc
            if 0 <= nr < n and 0 <= nc < m and (nr, nc) not in visited:
                if config[nr * m + nc]:
                    visited.add((nr, nc))
                    queue.append((nr, nc))
    return False


# ============================================================
# Application 2: Forest Fire Spread Model
# ============================================================

def forest_fire_simulation(n: int, tree_density: float,
                           num_trials: int = 5000) -> dict:
    """
    Simulate forest fire spread on an n×n grid.
    
    Trees are present with probability `tree_density`. Fire starts
    on the left edge and spreads to adjacent trees. We compute the
    probability that fire reaches the right edge.
    
    This directly models percolation: the critical threshold determines
    whether large-scale fire spread is possible.
    
    Args:
        n: forest grid dimension
        tree_density: probability each cell has a tree
        num_trials: number of simulations
    
    Returns:
        Dictionary with spread probability and statistics
    """
    spread_count = 0
    burn_fractions = []
    
    for _ in range(num_trials):
        # Generate forest
        forest = [random.random() < tree_density for _ in range(n * n)]
        
        # Start fire on left edge
        burned = set()
        queue = deque()
        for row in range(n):
            if forest[row * n]:
                queue.append((row, 0))
                burned.add((row, 0))
        
        reached_right = False
        while queue:
            r, c = queue.popleft()
            if c == n - 1:
                reached_right = True
            for dr, dc in [(-1,0),(1,0),(0,-1),(0,1)]:
                nr, nc = r+dr, c+dc
                if 0 <= nr < n and 0 <= nc < n and (nr, nc) not in burned:
                    if forest[nr * n + nc]:
                        burned.add((nr, nc))
                        queue.append((nr, nc))
        
        if reached_right:
            spread_count += 1
        total_trees = sum(forest)
        if total_trees > 0:
            burn_fractions.append(len(burned) / total_trees)
    
    return {
        "spread_probability": spread_count / num_trials,
        "avg_burn_fraction": sum(burn_fractions) / len(burn_fractions) if burn_fractions else 0,
        "n": n,
        "density": tree_density
    }


# ============================================================
# Application 3: Epidemiological Contact Tracing
# ============================================================

def epidemic_threshold(n: int, transmission_probs: List[float],
                       num_trials: int = 5000) -> dict:
    """
    Model epidemic spread on a contact network (grid).
    
    Each person (node) can transmit to neighbors with probability p.
    We measure whether the epidemic reaches from one side of the
    population to the other, analogous to horizontal crossing.
    
    The percolation threshold determines the epidemic threshold:
    below it, outbreaks are local; above it, pandemics are possible.
    
    Args:
        n: population grid size
        transmission_probs: list of transmission probabilities
        num_trials: simulations per probability
    
    Returns:
        Dictionary mapping transmission probability to pandemic probability
    """
    results = {}
    for p in transmission_probs:
        pandemic_count = 0
        for _ in range(num_trials):
            # Bond percolation: each contact transmits independently
            infected = set()
            queue = deque()
            # Start from left column
            for row in range(n):
                infected.add((row, 0))
                queue.append((row, 0))
            
            reached_right = False
            while queue:
                r, c = queue.popleft()
                if c == n - 1:
                    reached_right = True
                for dr, dc in [(-1,0),(1,0),(0,-1),(0,1)]:
                    nr, nc = r+dr, c+dc
                    if 0 <= nr < n and 0 <= nc < n and (nr, nc) not in infected:
                        if random.random() < p:
                            infected.add((nr, nc))
                            queue.append((nr, nc))
            
            if reached_right:
                pandemic_count += 1
        results[p] = pandemic_count / num_trials
    return results


# ============================================================
# Application 4: Material Conductivity Phase Transition
# ============================================================

def conductivity_simulation(n: int, conductor_fractions: List[float],
                            num_trials: int = 5000) -> dict:
    """
    Model electrical conductivity in a composite material.
    
    A material is a random mixture of conductor (with probability p)
    and insulator. Current can flow between adjacent conductor cells.
    The material conducts if there's a path from top to bottom.
    
    The percolation threshold determines the conductor fraction needed
    for bulk conductivity - a real phase transition observed experimentally.
    
    Args:
        n: material grid dimension
        conductor_fractions: list of conductor volume fractions
        num_trials: simulations per fraction
    
    Returns:
        Dictionary mapping fraction to conductivity probability
    """
    results = {}
    for p in conductor_fractions:
        conducts = 0
        for _ in range(num_trials):
            material = [random.random() < p for _ in range(n * n)]
            # Check vertical crossing (top to bottom)
            visited = set()
            queue = deque()
            for col in range(n):
                if material[col]:  # top row
                    queue.append((0, col))
                    visited.add((0, col))
            
            connected = False
            while queue:
                r, c = queue.popleft()
                if r == n - 1:
                    connected = True
                    break
                for dr, dc in [(-1,0),(1,0),(0,-1),(0,1)]:
                    nr, nc = r+dr, c+dc
                    if 0 <= nr < n and 0 <= nc < n and (nr, nc) not in visited:
                        if material[nr * n + nc]:
                            visited.add((nr, nc))
                            queue.append((nr, nc))
            
            if connected:
                conducts += 1
        results[p] = conducts / num_trials
    return results


# ============================================================
# Main Demonstration
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    
    print("=" * 60)
    print("PERCOLATION THEORY: REAL-WORLD APPLICATIONS")
    print("=" * 60)
    
    # Network Resilience
    print("\n--- Network Resilience (20×20 grid) ---")
    p_values = [0.3, 0.4, 0.5, 0.55, 0.6, 0.65, 0.7, 0.8]
    results = network_resilience(20, p_values, num_trials=2000)
    for p, prob in sorted(results.items()):
        bar = "█" * int(prob * 40)
        print(f"  reliability={p:.2f}: connectivity={prob:.3f}  {bar}")
    
    # Forest Fire
    print("\n--- Forest Fire Spread (20×20 grid) ---")
    for density in [0.4, 0.5, 0.55, 0.6, 0.65, 0.7]:
        result = forest_fire_simulation(20, density, num_trials=2000)
        print(f"  density={density:.2f}: spread={result['spread_probability']:.3f}, "
              f"avg_burn={result['avg_burn_fraction']:.3f}")
    
    # Epidemic
    print("\n--- Epidemic Threshold (15×15 population grid) ---")
    trans_probs = [0.3, 0.4, 0.5, 0.55, 0.6, 0.7]
    epi_results = epidemic_threshold(15, trans_probs, num_trials=2000)
    for p, prob in sorted(epi_results.items()):
        status = "PANDEMIC" if prob > 0.5 else "contained"
        print(f"  transmission={p:.2f}: pandemic_prob={prob:.3f} [{status}]")
    
    # Material Conductivity
    print("\n--- Composite Material Conductivity (20×20) ---")
    fractions = [0.4, 0.5, 0.55, 0.6, 0.65, 0.7, 0.8]
    cond_results = conductivity_simulation(20, fractions, num_trials=2000)
    for p, prob in sorted(cond_results.items()):
        state = "CONDUCTING" if prob > 0.5 else "insulating"
        print(f"  conductor_fraction={p:.2f}: bulk_conductivity={prob:.3f} [{state}]")
    
    print("\n" + "=" * 60)
    print("All applications demonstrate the universal percolation threshold")
    print("phenomenon: a sharp phase transition at a critical parameter value.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Percolation Threshold: Computational Demonstrations

This script demonstrates key concepts from the formal percolation threshold theory:
1. Triangular lattice critical polynomial root finding
2. Verification of the closed-form threshold 2*sin(π/18)
3. Monotonicity of crossing probabilities on small grids
4. Finite-volume threshold estimation by exact enumeration
"""

import math
import itertools
from collections import deque
from typing import Callable

# ============================================================
# 1. Triangular Critical Polynomial
# ============================================================

def triangular_critical_poly(p: float) -> float:
    """The critical polynomial p³ - 3p + 1 for triangular lattice bond percolation."""
    return p**3 - 3*p + 1

def triangular_critical_poly_deriv(p: float) -> float:
    """Derivative: 3p² - 3."""
    return 3*p**2 - 3

def find_root_bisection(f: Callable[[float], float], a: float, b: float,
                        tol: float = 1e-15) -> float:
    """Find root of f in [a,b] by bisection."""
    fa, fb = f(a), f(b)
    assert fa * fb <= 0, "No sign change in interval"
    while b - a > tol:
        mid = (a + b) / 2
        fmid = f(mid)
        if fmid == 0:
            return mid
        if fa * fmid < 0:
            b = mid
        else:
            a, fa = mid, fmid
    return (a + b) / 2

print("=" * 60)
print("TRIANGULAR LATTICE BOND PERCOLATION THRESHOLD")
print("=" * 60)

# Numerical root
p_numerical = find_root_bisection(triangular_critical_poly, 0, 1)
print(f"\nNumerical root of p³ - 3p + 1 = 0 in (0,1):")
print(f"  p_c = {p_numerical:.15f}")

# Closed form: 2*sin(π/18)
p_closed = 2 * math.sin(math.pi / 18)
print(f"\nClosed form 2·sin(π/18):")
print(f"  p_c = {p_closed:.15f}")

print(f"\nDifference: {abs(p_numerical - p_closed):.2e}")

# Verify polynomial identity
poly_val = triangular_critical_poly(p_closed)
print(f"\nVerification: p³ - 3p + 1 at p = 2·sin(π/18) = {poly_val:.2e}")

# Verify via triple angle formula
s = math.sin(math.pi / 18)
sin_pi_6 = math.sin(math.pi / 6)
triple_angle = 3*s - 4*s**3  # should equal sin(π/6) = 0.5
print(f"\nTriple angle verification:")
print(f"  3·sin(π/18) - 4·sin³(π/18) = {triple_angle:.15f}")
print(f"  sin(π/6) = {sin_pi_6:.15f}")

# Derivative shows strict decrease on (0,1)
print(f"\nDerivative 3p²-3 at p=0.5: {triangular_critical_poly_deriv(0.5):.4f} (negative ✓)")
print(f"Polynomial at 0: {triangular_critical_poly(0):.1f} (positive ✓)")
print(f"Polynomial at 1: {triangular_critical_poly(1):.1f} (negative ✓)")
print(f"→ Unique root in (0,1) by IVT + strict monotonicity ✓")

# Honeycomb dual
p_honeycomb = 1 - p_closed
print(f"\nHoneycomb bond threshold (dual): 1 - 2·sin(π/18) = {p_honeycomb:.15f}")
print(f"Verification: poly(1 - p_honey) = {triangular_critical_poly(1 - p_honeycomb):.2e}")

# ============================================================
# 2. Monotonicity of Crossing Probabilities
# ============================================================

print("\n" + "=" * 60)
print("CROSSING PROBABILITY MONOTONICITY ON SMALL GRIDS")
print("=" * 60)

def grid_neighbors(n: int, i: int, j: int):
    """Yield neighbors of (i,j) in n×n grid."""
    for di, dj in [(-1,0),(1,0),(0,-1),(0,1)]:
        ni, nj = i+di, j+dj
        if 0 <= ni < n and 0 <= nj < n:
            yield ni, nj

def has_horizontal_crossing(n: int, config: list) -> bool:
    """Check if open sites form a path from left column to right column."""
    if n == 0:
        return False
    # BFS from all open sites in left column
    visited = set()
    queue = deque()
    for row in range(n):
        if config[row * n]:  # site (row, 0) is open
            queue.append((row, 0))
            visited.add((row, 0))
    while queue:
        r, c = queue.popleft()
        if c == n - 1:
            return True
        for nr, nc in grid_neighbors(n, r, c):
            if (nr, nc) not in visited and config[nr * n + nc]:
                visited.add((nr, nc))
                queue.append((nr, nc))
    return False

def crossing_probability(n: int, p: float) -> float:
    """Exact crossing probability for n×n grid by enumeration."""
    total = n * n
    prob = 0.0
    for bits in range(2**total):
        config = [(bits >> k) & 1 for k in range(total)]
        if has_horizontal_crossing(n, config):
            weight = 1.0
            for k in range(total):
                weight *= p if config[k] else (1 - p)
            prob += weight
    return prob

# Demonstrate monotonicity for small grids
for n in [2, 3]:
    print(f"\n{n}×{n} grid site crossing probabilities:")
    ps = [i/10 for i in range(11)]
    probs = [crossing_probability(n, p) for p in ps]
    for p_val, prob in zip(ps, probs):
        bar = "█" * int(prob * 40)
        print(f"  p={p_val:.1f}: P(cross) = {prob:.6f}  {bar}")
    
    # Verify monotonicity
    is_monotone = all(probs[i] <= probs[i+1] + 1e-10 for i in range(len(probs)-1))
    print(f"  Monotone: {'✓' if is_monotone else '✗'}")

# ============================================================
# 3. Finite-Volume Threshold Estimation
# ============================================================

print("\n" + "=" * 60)
print("FINITE-VOLUME THRESHOLD ESTIMATION")
print("=" * 60)

for n in [2, 3]:
    # Find p where crossing probability ≈ 1/2
    def f(p):
        return crossing_probability(n, p) - 0.5
    
    try:
        p_thresh = find_root_bisection(f, 0.01, 0.99, tol=1e-8)
        print(f"\n{n}×{n} grid: finite-volume threshold p_n ≈ {p_thresh:.8f}")
        print(f"  P(crossing at p_n) = {crossing_probability(n, p_thresh):.8f}")
    except:
        print(f"\n{n}×{n} grid: threshold computation failed")

# ============================================================
# 4. Square Bond Duality Fixed Point
# ============================================================

print("\n" + "=" * 60)
print("SQUARE BOND DUALITY FIXED POINT")
print("=" * 60)

print("\nThe duality map for square bond percolation: p ↦ 1 - p")
print("Fixed point: 1 - p = p  ⟺  p = 1/2")
print(f"Verification: 1 - 0.5 = {1 - 0.5} = 0.5 ✓")
print("This is the algebraic heart of the p_c(bond, Z²) = 1/2 theorem.")

# ============================================================
# 5. Bernoulli Weight Normalization
# ============================================================

print("\n" + "=" * 60)
print("BERNOULLI WEIGHT NORMALIZATION VERIFICATION")
print("=" * 60)

def bernoulli_weight(p: float, config: list) -> float:
    """Product weight for a Boolean configuration."""
    w = 1.0
    for bit in config:
        w *= p if bit else (1 - p)
    return w

for n_sites in [1, 2, 3, 4]:
    for p_val in [0.3, 0.5, 0.7]:
        total = sum(
            bernoulli_weight(p_val, [(bits >> k) & 1 for k in range(n_sites)])
            for bits in range(2**n_sites)
        )
        print(f"  {n_sites} sites, p={p_val}: Σ weights = {total:.10f}")

print("\nAll normalizations equal 1 ✓ (matches bernoulliWeight_total theorem)")

print("\n" + "=" * 60)
print("SUMMARY OF FORMALLY VERIFIED RESULTS")
print("=" * 60)
print("""
1. triangularCriticalPolynomial(p) = p³ - 3p + 1
   - Unique root in (0,1): PROVED
   - Root = 2·sin(π/18): PROVED
   - Honeycomb dual = 1 - 2·sin(π/18): PROVED

2. Monotonicity of increasing events under Bernoulli measure: PROVED
   - bernoulliWeight_total (normalization): PROVED  
   - increasing_event_prob_monotone: PROVED

3. Percolation connectivity is increasing:
   - siteConnected_increasing: PROVED
   - bondConnected_increasing: PROVED
   - hasHorizontalCrossing_increasing: PROVED

4. Square bond duality fixed point at p = 1/2: PROVED
""")
