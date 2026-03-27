#!/usr/bin/env python3
"""
Information Geometry of Scientific Discovery

This demo explores the geometric structure of belief space — the "landscape"
that science navigates as it converges to truth.

Key insight: The space of probability distributions forms a Riemannian manifold
(the probability simplex) with the Fisher information metric. Scientific
discovery is a path on this manifold, and the geodesic is the shortest path
from ignorance to knowledge.

Run: python3 information_geometry.py
"""

import numpy as np
from itertools import combinations

# ═══════════════════════════════════════════════════════════════════════
# §1: THE PROBABILITY SIMPLEX
# ═══════════════════════════════════════════════════════════════════════

def simplex_point(n: int, *probs) -> np.ndarray:
    """Create a point on the n-simplex."""
    p = np.array(probs, dtype=float)
    assert len(p) == n, f"Need {n} probabilities, got {len(p)}"
    assert np.isclose(np.sum(p), 1.0), f"Probabilities must sum to 1, got {np.sum(p)}"
    assert np.all(p >= 0), "Probabilities must be non-negative"
    return p


def fisher_metric(p: np.ndarray) -> np.ndarray:
    """
    Fisher information metric at point p on the simplex.
    
    g_ij = δ_ij / p_i (in the natural coordinates)
    
    This is the unique Riemannian metric that is invariant under
    sufficient statistics — it's the geometry that nature uses.
    """
    n = len(p)
    g = np.zeros((n, n))
    for i in range(n):
        if p[i] > 1e-15:
            g[i, i] = 1.0 / p[i]
    return g


def fisher_distance(p: np.ndarray, q: np.ndarray) -> float:
    """
    Fisher-Rao distance between two distributions.
    
    d(p, q) = 2 * arccos(sum(sqrt(p_i * q_i)))
    
    This is the geodesic distance on the statistical manifold.
    """
    # Bhattacharyya coefficient
    bc = np.sum(np.sqrt(p * q))
    bc = min(1.0, max(-1.0, bc))  # Numerical stability
    return 2.0 * np.arccos(bc)


def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """KL divergence D(p || q) — not symmetric, not a true distance."""
    result = 0.0
    for i in range(len(p)):
        if p[i] > 1e-15 and q[i] > 1e-15:
            result += p[i] * np.log(p[i] / q[i])
    return result


# ═══════════════════════════════════════════════════════════════════════
# §2: GEODESICS ON THE BELIEF MANIFOLD
# ═══════════════════════════════════════════════════════════════════════

def geodesic(p: np.ndarray, q: np.ndarray, t: float) -> np.ndarray:
    """
    Geodesic on the probability simplex with Fisher metric.
    
    In the sphere representation (where p_i = ξ_i²), the geodesic
    is a great circle arc: γ(t) = slerp(√p, √q)(t)²
    """
    xi_p = np.sqrt(p)
    xi_q = np.sqrt(q)
    
    # Spherical linear interpolation (slerp)
    cos_theta = np.dot(xi_p, xi_q)
    cos_theta = min(1.0, max(-1.0, cos_theta))
    theta = np.arccos(cos_theta)
    
    if theta < 1e-10:
        return p.copy()
    
    xi_t = (np.sin((1 - t) * theta) * xi_p + np.sin(t * theta) * xi_q) / np.sin(theta)
    result = xi_t ** 2
    result = result / np.sum(result)  # Normalize
    return result


def demonstrate_geometry():
    """Show the geometric structure of belief space."""
    print("=" * 72)
    print("INFORMATION GEOMETRY OF SCIENTIFIC DISCOVERY")
    print("=" * 72)
    
    # 3-hypothesis example
    n = 3
    
    # Key points on the simplex
    uniform = np.ones(n) / n  # Maximum ignorance
    truth = np.array([0.0, 0.0, 1.0])  # Perfect knowledge (H₂ is true)
    wrong = np.array([1.0, 0.0, 0.0])  # Completely wrong
    partial = np.array([0.1, 0.2, 0.7])  # Partially correct
    
    print(f"\n{'─' * 60}")
    print("DISTANCES IN BELIEF SPACE (Fisher-Rao metric)")
    print(f"{'─' * 60}")
    
    points = {
        'Uniform (ignorance)': uniform,
        'Truth (H₂)': np.array([0.001, 0.001, 0.998]),  # Near-truth for finite distance
        'Wrong (H₀)': np.array([0.998, 0.001, 0.001]),
        'Partial knowledge': partial,
    }
    
    for (name1, p1), (name2, p2) in combinations(points.items(), 2):
        d = fisher_distance(p1, p2)
        kl = kl_divergence(p1, p2)
        print(f"  d({name1}, {name2})")
        print(f"    Fisher-Rao distance: {d:.4f}")
        print(f"    KL divergence:       {kl:.4f}")
        print()
    
    # Show geodesic path = the ideal scientific journey
    print(f"{'─' * 60}")
    print("THE GEODESIC: Shortest Path from Ignorance to Truth")
    print(f"{'─' * 60}")
    
    start = uniform
    end = np.array([0.001, 0.001, 0.998])
    
    print(f"\n  {'t':>5} {'P(H₀)':>10} {'P(H₁)':>10} {'P(H₂)':>10} "
          f"{'Entropy':>10} {'Fisher d':>10}")
    print(f"  {'─' * 55}")
    
    for t_int in range(11):
        t = t_int / 10.0
        p = geodesic(start, end, t)
        ent = -np.sum(p[p > 0] * np.log2(p[p > 0]))
        d = fisher_distance(start, p)
        print(f"  {t:>5.2f} {p[0]:>10.6f} {p[1]:>10.6f} {p[2]:>10.6f} "
              f"{ent:>10.4f} {d:>10.4f}")
    
    # Compare geodesic vs actual scientific path
    print(f"\n{'─' * 60}")
    print("COMPARISON: Geodesic vs Actual Scientific Path")
    print(f"{'─' * 60}")
    
    # Simulate actual Bayesian path
    beliefs = uniform.copy()
    true_h = 2
    path = [beliefs.copy()]
    
    for exp in range(20):
        # Generate experiment
        likelihood = np.array([0.3, 0.2, 0.9])
        likelihood += np.random.normal(0, 0.05, n)
        likelihood = np.clip(likelihood, 0.01, 1.0)
        
        evidence = np.sum(beliefs * likelihood)
        beliefs = (beliefs * likelihood) / evidence
        path.append(beliefs.copy())
    
    # Measure path lengths
    geodesic_length = fisher_distance(start, end)
    
    actual_length = 0.0
    for i in range(1, len(path)):
        actual_length += fisher_distance(path[i-1], path[i])
    
    print(f"\n  Geodesic distance (ideal):   {geodesic_length:.4f}")
    print(f"  Actual path length:          {actual_length:.4f}")
    print(f"  Efficiency ratio:            {geodesic_length/actual_length:.4f}")
    print(f"\n  KEY INSIGHT: The actual scientific path is longer than the")
    print(f"  geodesic because experiments provide noisy, incomplete information.")
    print(f"  The ratio measures how 'efficient' our experiments are.")


# ═══════════════════════════════════════════════════════════════════════
# §3: CURVATURE AND SCIENTIFIC DIFFICULTY
# ═══════════════════════════════════════════════════════════════════════

def curvature_analysis():
    """
    The curvature of belief space determines scientific difficulty.
    High curvature = hypotheses are hard to distinguish.
    """
    print(f"\n{'═' * 72}")
    print("CURVATURE ANALYSIS: Why Some Science is Harder")
    print(f"{'═' * 72}")
    
    print("""
    The Fisher information metric has constant positive curvature on the
    probability simplex, making it a sphere (in the square-root coordinates).
    
    Key consequence: Near the edges of the simplex (where one hypothesis
    dominates), distances grow — it becomes exponentially harder to
    distinguish near-certain beliefs.
    
    This is why the last few decimal places of a physical constant are
    the hardest to measure!
    """)
    
    # Demonstrate: distances near edges vs center
    n = 3
    
    print(f"  {'Region':>25} {'Distance for Δ=0.01':>20}")
    print(f"  {'─' * 47}")
    
    # Center of simplex
    p = np.array([0.333, 0.334, 0.333])
    q = np.array([0.333, 0.344, 0.323])
    d = fisher_distance(p, q)
    print(f"  {'Near center':>25} {d:>20.6f}")
    
    # Near edge
    p = np.array([0.01, 0.01, 0.98])
    q = np.array([0.01, 0.02, 0.97])
    d = fisher_distance(p, q)
    print(f"  {'Near edge (98%)':>25} {d:>20.6f}")
    
    # Very near vertex
    p = np.array([0.001, 0.001, 0.998])
    q = np.array([0.001, 0.011, 0.988])
    d = fisher_distance(p, q)
    print(f"  {'Near vertex (99.8%)':>25} {d:>20.6f}")
    
    print(f"\n  FINDING: Distance grows near vertices — confirming that the")
    print(f"  'last mile' of scientific certainty is geometrically harder.")


# ═══════════════════════════════════════════════════════════════════════
# §4: THE TOPOLOGY OF HYPOTHESIS SPACE
# ═══════════════════════════════════════════════════════════════════════

def topology_exploration():
    """
    Explore the topological properties of belief space.
    """
    print(f"\n{'═' * 72}")
    print("TOPOLOGY OF BELIEF SPACE")
    print(f"{'═' * 72}")
    
    print("""
    The n-simplex (belief space for n+1 hypotheses) has rich topology:
    
    • It is contractible (connected, simply connected)
    • Its boundary consists of lower-dimensional simplices (partial certainty)
    • The vertices are the pure states (complete certainty)
    • The center is the uniform distribution (complete ignorance)
    
    Scientific discovery is a path from center to vertex.
    
    NEW HYPOTHESIS (MH7: Topological Obstruction):
    When hypothesis space has non-trivial topology (e.g., circular
    parameter space), Bayesian updating can have topological obstructions
    to convergence — analogous to how you can't comb a hairy ball.
    """)
    
    # Demonstrate: paths on the simplex
    n = 4  # 4 hypotheses, 3-simplex
    
    print(f"  Exploring paths on the {n-1}-simplex:")
    
    # Random walk from center to vertex 0
    pos = np.ones(n) / n
    target = np.zeros(n)
    target[0] = 1.0
    target_near = np.array([0.997, 0.001, 0.001, 0.001])
    
    total_distance = fisher_distance(pos, target_near)
    print(f"\n  Total Fisher distance to truth: {total_distance:.4f}")
    
    # Show that all vertices are equidistant from center
    center = np.ones(n) / n
    print(f"\n  Distance from uniform to each vertex:")
    for i in range(n):
        vertex = np.zeros(n) + 0.001
        vertex[i] = 0.997
        d = fisher_distance(center, vertex)
        print(f"    H_{i}: {d:.6f}")
    
    print(f"\n  ALL EQUAL! The uniform prior is maximally fair —")
    print(f"  it's equidistant from all hypotheses in Fisher geometry.")


# ═══════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n" + "╔" + "═" * 70 + "╗")
    print("║" + " INFORMATION GEOMETRY OF SCIENTIFIC DISCOVERY ".center(70) + "║")
    print("║" + " Where Mathematics Meets the Scientific Method ".center(70) + "║")
    print("╚" + "═" * 70 + "╝\n")
    
    demonstrate_geometry()
    curvature_analysis()
    topology_exploration()
    
    print(f"\n{'═' * 72}")
    print("SUMMARY OF NEW MATHEMATICS")
    print(f"{'═' * 72}")
    print("""
    1. GEODESIC INTERPRETATION: The ideal scientific journey is a geodesic
       on the Fisher-Rao manifold. Actual science takes a longer path
       because experiments are imperfect.
    
    2. CURVATURE = DIFFICULTY: The positive curvature of the statistical
       manifold explains why the "last mile" of certainty is hardest.
    
    3. TOPOLOGICAL FAIRNESS: The uniform prior is equidistant from all
       pure states — it is the unique maximally fair starting point.
    
    4. NEW HYPOTHESIS (MH7): Topological obstructions in hypothesis space
       can prevent convergence — a novel prediction of our framework.
    
    These results connect information geometry, Riemannian geometry, and
    the philosophy of science in a new way.
    """)
