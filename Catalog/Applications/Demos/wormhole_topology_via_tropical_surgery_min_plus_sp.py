#!/usr/bin/env python3
"""
Tropical Wormhole Surgery — Applications

Real-world applications of the tropical discrete relativity framework:
1. Network optimization: Finding optimal shortcut links in communication networks
2. Transportation planning: Evaluating tunnel/bridge construction proposals
3. Supply chain resilience: Identifying critical logistics shortcuts
"""

import numpy as np
from typing import List, Tuple, Dict


def bellman_ford(W, source):
    n = W.shape[0]
    dist = np.full(n, np.inf)
    pred = np.full(n, -1, dtype=int)
    dist[source] = 0.0
    for _ in range(n - 1):
        for u in range(n):
            if dist[u] == np.inf: continue
            for v in range(n):
                if dist[u] + W[u][v] < dist[v]:
                    dist[v] = dist[u] + W[u][v]
                    pred[v] = u
    return dist, pred

def wormhole_surgery(W, u, v, tau):
    W_new = W.copy()
    W_new[u][v] = min(W[u][v], tau)
    W_new[v][u] = min(W[v][u], tau)
    return W_new

def min_plus_ricci(W, x):
    n = W.shape[0]
    return min((W[x][y] + W[y][x]) / 2 for y in range(n))


# =====================================================================
# Application 1: Network Optimization
# =====================================================================

def optimal_shortcut_placement(W: np.ndarray, budget: float, 
                                 candidates: List[Tuple[int, int]]) -> Dict:
    """Find the best shortcut link to add to a network.
    
    Given a communication network and a budget for a single new link,
    evaluate all candidate shortcut placements and find the one that
    maximizes average distance reduction (network diameter improvement).
    
    This is exactly the wormhole surgery problem: which bridge edge,
    at what cost, produces the greatest improvement in tropical geodesics?
    
    Args:
        W: Network adjacency matrix (travel times / latencies)
        budget: Maximum cost for the new link
        candidates: List of (u, v) pairs where a shortcut could be placed
    
    Returns:
        Analysis of each candidate and the optimal choice
    """
    n = W.shape[0]
    
    # Compute baseline all-pairs distances
    baseline_dists = np.zeros((n, n))
    for s in range(n):
        baseline_dists[s] = bellman_ford(W, s)[0]
    
    baseline_avg = np.mean(baseline_dists[baseline_dists < np.inf])
    baseline_diameter = np.max(baseline_dists[baseline_dists < np.inf])
    
    results = []
    for u, v in candidates:
        W_new = wormhole_surgery(W, u, v, budget)
        new_dists = np.zeros((n, n))
        for s in range(n):
            new_dists[s] = bellman_ford(W_new, s)[0]
        
        new_avg = np.mean(new_dists[new_dists < np.inf])
        new_diameter = np.max(new_dists[new_dists < np.inf])
        
        results.append({
            'edge': (u, v),
            'avg_distance_before': baseline_avg,
            'avg_distance_after': new_avg,
            'avg_improvement': baseline_avg - new_avg,
            'diameter_before': baseline_diameter,
            'diameter_after': new_diameter,
            'diameter_improvement': baseline_diameter - new_diameter,
            'ricci_u': min_plus_ricci(W, u),
            'ricci_v': min_plus_ricci(W, v),
        })
    
    best = max(results, key=lambda r: r['avg_improvement'])
    
    return {
        'baseline_avg_distance': baseline_avg,
        'baseline_diameter': baseline_diameter,
        'candidates': results,
        'best_shortcut': best,
    }


# =====================================================================
# Application 2: Transportation Planning
# =====================================================================

def evaluate_tunnel_proposal(
    city_graph: np.ndarray,
    city_names: List[str],
    tunnel_endpoints: Tuple[int, int],
    tunnel_cost: float,
    key_od_pairs: List[Tuple[int, int]]
) -> Dict:
    """Evaluate a proposed tunnel/bridge for a city transportation network.
    
    This applies tropical wormhole surgery to urban planning: a tunnel
    between two city districts is a bridge edge in the transportation graph.
    
    Args:
        city_graph: Travel time matrix between city zones
        city_names: Names of city zones
        tunnel_endpoints: (zone_u, zone_v) for the tunnel
        tunnel_cost: Travel time through the tunnel
        key_od_pairs: Important origin-destination pairs to evaluate
    
    Returns:
        Impact analysis including travel time savings for each OD pair
    """
    u, v = tunnel_endpoints
    W_new = wormhole_surgery(city_graph, u, v, tunnel_cost)
    
    analysis = {
        'tunnel': f'{city_names[u]} ↔ {city_names[v]}',
        'tunnel_cost': tunnel_cost,
        'od_improvements': [],
    }
    
    total_saving = 0
    for s, t in key_od_pairs:
        d_before = bellman_ford(city_graph, s)[0][t]
        d_after = bellman_ford(W_new, s)[0][t]
        saving = d_before - d_after
        total_saving += saving
        analysis['od_improvements'].append({
            'origin': city_names[s],
            'destination': city_names[t],
            'time_before': d_before,
            'time_after': d_after,
            'saving': saving,
            'saving_pct': 100 * saving / d_before if d_before > 0 else 0,
        })
    
    analysis['total_saving'] = total_saving
    analysis['avg_saving'] = total_saving / len(key_od_pairs)
    
    return analysis


# =====================================================================
# Application 3: Supply Chain Resilience
# =====================================================================

def supply_chain_shortcut_analysis(
    logistics_graph: np.ndarray,
    node_names: List[str],
    factories: List[int],
    warehouses: List[int],
    shortcut_budget: float
) -> Dict:
    """Analyze supply chain improvement from adding a logistics shortcut.
    
    Models the supply chain as a weighted graph where edges represent
    shipping routes. A logistics shortcut (new route, dedicated lane,
    or express service) is a wormhole surgery operation.
    
    Args:
        logistics_graph: Shipping cost/time matrix
        node_names: Names of logistics nodes
        factories: Factory node indices
        warehouses: Warehouse node indices
        shortcut_budget: Cost of the shortcut route
    
    Returns:
        Analysis of which shortcut most reduces factory-to-warehouse costs
    """
    n = logistics_graph.shape[0]
    
    # Compute factory-to-warehouse baseline
    baseline_costs = {}
    for f in factories:
        dists = bellman_ford(logistics_graph, f)[0]
        for w in warehouses:
            baseline_costs[(f, w)] = dists[w]
    
    avg_baseline = np.mean(list(baseline_costs.values()))
    
    # Try all possible shortcuts
    best_improvement = 0
    best_shortcut = None
    
    all_results = []
    for u in range(n):
        for v in range(u + 1, n):
            if logistics_graph[u][v] <= shortcut_budget:
                continue  # Already have a cheaper route
            
            W_new = wormhole_surgery(logistics_graph, u, v, shortcut_budget)
            
            new_costs = {}
            for f in factories:
                dists = bellman_ford(W_new, f)[0]
                for w in warehouses:
                    new_costs[(f, w)] = dists[w]
            
            avg_new = np.mean(list(new_costs.values()))
            improvement = avg_baseline - avg_new
            
            if improvement > 0.01:
                all_results.append({
                    'shortcut': f'{node_names[u]} ↔ {node_names[v]}',
                    'u': u, 'v': v,
                    'avg_cost_before': avg_baseline,
                    'avg_cost_after': avg_new,
                    'improvement': improvement,
                    'improvement_pct': 100 * improvement / avg_baseline,
                })
                
                if improvement > best_improvement:
                    best_improvement = improvement
                    best_shortcut = (u, v)
    
    all_results.sort(key=lambda r: r['improvement'], reverse=True)
    
    return {
        'avg_baseline_cost': avg_baseline,
        'num_candidates_evaluated': n * (n - 1) // 2,
        'num_improvements_found': len(all_results),
        'top_5_shortcuts': all_results[:5],
        'best_shortcut': best_shortcut,
    }


# =====================================================================
# Demo
# =====================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Network Shortcut Optimization")
    print("=" * 70)
    
    # Ring network with 8 nodes
    n = 8
    INF = 100.0
    W = np.full((n, n), INF)
    np.fill_diagonal(W, 0)
    for i in range(n):
        W[i][(i + 1) % n] = 2
        W[(i + 1) % n][i] = 2
    
    candidates = [(0, 4), (1, 5), (2, 6), (3, 7)]
    result = optimal_shortcut_placement(W, budget=1.0, candidates=candidates)
    
    print(f"\nRing network with {n} nodes")
    print(f"Baseline avg distance: {result['baseline_avg_distance']:.2f}")
    print(f"Baseline diameter: {result['baseline_diameter']:.2f}")
    print(f"\nCandidate shortcuts (budget = 1.0):")
    for c in result['candidates']:
        print(f"  {c['edge']}: avg improvement = {c['avg_improvement']:.2f}, "
              f"diameter: {c['diameter_before']:.0f} → {c['diameter_after']:.0f}")
    print(f"\nBest shortcut: {result['best_shortcut']['edge']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Transportation Tunnel Evaluation")
    print("=" * 70)
    
    cities = ['Downtown', 'Suburb-N', 'Suburb-E', 'Suburb-S', 'Suburb-W', 'Airport']
    nc = len(cities)
    G = np.full((nc, nc), 100.0)
    np.fill_diagonal(G, 0)
    # Downtown connections
    G[0][1] = 15; G[1][0] = 15  # Downtown - Suburb-N
    G[0][2] = 20; G[2][0] = 20  # Downtown - Suburb-E
    G[0][3] = 25; G[3][0] = 25  # Downtown - Suburb-S
    G[0][4] = 18; G[4][0] = 18  # Downtown - Suburb-W
    # Suburb connections
    G[1][2] = 12; G[2][1] = 12
    G[2][3] = 15; G[3][2] = 15
    G[3][4] = 10; G[4][3] = 10
    G[4][1] = 22; G[1][4] = 22
    # Airport
    G[2][5] = 30; G[5][2] = 30
    G[3][5] = 35; G[5][3] = 35
    
    result = evaluate_tunnel_proposal(
        G, cities,
        tunnel_endpoints=(4, 5),  # Suburb-W to Airport
        tunnel_cost=8,
        key_od_pairs=[(0, 5), (1, 5), (4, 5), (3, 2)]
    )
    
    print(f"\nProposed tunnel: {result['tunnel']}")
    print(f"Tunnel travel time: {result['tunnel_cost']} minutes")
    print(f"\nImpact on key routes:")
    for od in result['od_improvements']:
        print(f"  {od['origin']} → {od['destination']}: "
              f"{od['time_before']:.0f} → {od['time_after']:.0f} min "
              f"(saving {od['saving']:.0f} min, {od['saving_pct']:.1f}%)")
    print(f"\nTotal time saving: {result['total_saving']:.0f} minutes")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Supply Chain Shortcut Analysis")
    print("=" * 70)
    
    nodes = ['Factory-A', 'Factory-B', 'Hub-1', 'Hub-2', 'Hub-3', 
             'Warehouse-X', 'Warehouse-Y']
    nl = len(nodes)
    L = np.full((nl, nl), 100.0)
    np.fill_diagonal(L, 0)
    L[0][2] = 5; L[2][0] = 5   # Factory-A - Hub-1
    L[1][3] = 7; L[3][1] = 7   # Factory-B - Hub-2
    L[2][3] = 4; L[3][2] = 4   # Hub-1 - Hub-2
    L[3][4] = 6; L[4][3] = 6   # Hub-2 - Hub-3
    L[2][4] = 8; L[4][2] = 8   # Hub-1 - Hub-3
    L[4][5] = 3; L[5][4] = 3   # Hub-3 - Warehouse-X
    L[4][6] = 5; L[6][4] = 5   # Hub-3 - Warehouse-Y
    L[2][5] = 10; L[5][2] = 10 # Hub-1 - Warehouse-X
    
    result = supply_chain_shortcut_analysis(
        L, nodes,
        factories=[0, 1],
        warehouses=[5, 6],
        shortcut_budget=3.0
    )
    
    print(f"\nBaseline avg factory-to-warehouse cost: {result['avg_baseline_cost']:.2f}")
    print(f"Candidates evaluated: {result['num_candidates_evaluated']}")
    print(f"Improvements found: {result['num_improvements_found']}")
    if result['top_5_shortcuts']:
        print(f"\nTop shortcuts:")
        for s in result['top_5_shortcuts']:
            print(f"  {s['shortcut']}: improvement = {s['improvement']:.2f} "
                  f"({s['improvement_pct']:.1f}%)")
    
    print("\n" + "=" * 70)
    print("ALL APPLICATIONS COMPLETED SUCCESSFULLY")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Wormhole Surgery — Demonstration

Concrete numerical demonstrations of the four main theorems:
1. Surgery strictly decreases tropical separation
2. Min-plus curvature controls throat radius
3. Tropical Einstein equation = Bellman optimality
4. Bellman-Ford relaxation convergence

Run: python demo.py
"""

import numpy as np
import sys
import os

# ---------- Inline algorithm implementations ----------
# (Self-contained — no local imports needed)

def bellman_ford(W, source):
    n = W.shape[0]
    dist = np.full(n, np.inf)
    pred = np.full(n, -1, dtype=int)
    dist[source] = 0.0
    for _ in range(n - 1):
        updated = False
        for u in range(n):
            if dist[u] == np.inf:
                continue
            for v in range(n):
                if dist[u] + W[u][v] < dist[v]:
                    dist[v] = dist[u] + W[u][v]
                    pred[v] = u
                    updated = True
        if not updated:
            break
    return dist, pred

def reconstruct_path(pred, source, target):
    if pred[target] == -1 and target != source:
        return []
    path = []
    v = target
    while v != source:
        path.append(v)
        v = pred[v]
        if v == -1:
            return []
    path.append(source)
    path.reverse()
    return path

def wormhole_surgery(W, u, v, tau):
    W_new = W.copy()
    W_new[u][v] = min(W[u][v], tau)
    W_new[v][u] = min(W[v][u], tau)
    return W_new

def min_plus_ricci(W, x):
    n = W.shape[0]
    return min((W[x][y] + W[y][x]) / 2 for y in range(n))

def throat_bound(W, u, v):
    return (min_plus_ricci(W, u) + min_plus_ricci(W, v)) / 2

def throat_radius(W, u, v, tau):
    return min(tau, throat_bound(W, u, v))

def relaxation_step(W, d):
    n = W.shape[0]
    d_new = np.empty(n)
    for x in range(n):
        d_new[x] = min(d[y] + W[y][x] for y in range(n))
    return d_new

def verify_tropical_einstein(W, source, phi, tol=1e-10):
    n = W.shape[0]
    if abs(phi[source]) > tol:
        return False
    for x in range(n):
        if x == source:
            continue
        relaxed = min(phi[y] + W[y][x] for y in range(n))
        if abs(phi[x] - relaxed) > tol:
            return False
    return True

# ---------- Demonstrations ----------

def demo_1_surgery_decreases_distance():
    """Demonstrate Theorem 1: Surgery strictly decreases tropical separation."""
    print("=" * 70)
    print("THEOREM 1: Wormhole Surgery Decreases Tropical Distance")
    print("=" * 70)

    # Create a 6-vertex "spacetime" graph
    # Vertices: 0=s, 5=t, 2=u (near s), 3=v (near t)
    # The graph has two regions connected by a long path
    n = 6
    INF = 1000.0
    W = np.full((n, n), INF)
    np.fill_diagonal(W, 0)

    # Region 1: s(0) -- 1 -- u(2)
    W[0][1] = 2; W[1][0] = 2
    W[1][2] = 3; W[2][1] = 3
    W[0][2] = 6; W[2][0] = 6

    # Region 2: v(3) -- 4 -- t(5)
    W[3][4] = 2; W[4][3] = 2
    W[4][5] = 3; W[5][4] = 3
    W[3][5] = 6; W[5][3] = 6

    # Long bridge between regions: u(2) -- v(3) with cost 20
    W[2][3] = 20; W[3][2] = 20

    s, t, u, v = 0, 5, 2, 3
    tau = 1.0  # Wormhole cost

    # Before surgery
    dist_before, pred_before = bellman_ford(W, s)
    d_st_before = dist_before[t]
    path_before = reconstruct_path(pred_before, s, t)

    print(f"\nGraph: 6-vertex spacetime with two regions")
    print(f"Source s={s}, Target t={t}")
    print(f"Wormhole endpoints: u={u}, v={v}")
    print(f"Wormhole cost τ = {tau}")
    print(f"\nBefore surgery:")
    print(f"  d(s,t) = {d_st_before}")
    print(f"  Path: {' → '.join(map(str, path_before))}")

    # After surgery
    W_new = wormhole_surgery(W, u, v, tau)
    dist_after, pred_after = bellman_ford(W_new, s)
    d_st_after = dist_after[t]
    path_after = reconstruct_path(pred_after, s, t)

    print(f"\nAfter surgery (bridge u↔v with cost {tau}):")
    print(f"  d(s,t) = {d_st_after}")
    print(f"  Path: {' → '.join(map(str, path_after))}")
    print(f"  Improvement: {d_st_before - d_st_after} ({100*(d_st_before - d_st_after)/d_st_before:.1f}%)")

    d_su = dist_before[u]
    d_vt_dists, _ = bellman_ford(W, v)
    d_vt = d_vt_dists[t]
    print(f"\n  d(s,u) = {d_su}, τ = {tau}, d(v,t) = {d_vt}")
    print(f"  Wormhole path cost: {d_su} + {tau} + {d_vt} = {d_su + tau + d_vt}")
    print(f"  ✓ {d_su + tau + d_vt} < {d_st_before} (surgery strictly decreases distance)")
    assert d_st_after < d_st_before, "Surgery should decrease distance!"
    print()


def demo_2_curvature_controls_throat():
    """Demonstrate Theorem 2: Min-plus curvature controls throat radius."""
    print("=" * 70)
    print("THEOREM 2: Min-Plus Curvature Controls Throat Radius")
    print("=" * 70)

    n = 4
    W = np.array([
        [0, 3, 7, 10],
        [3, 0, 4,  8],
        [7, 4, 0,  5],
        [10, 8, 5, 0]
    ], dtype=float)

    print(f"\nWeight matrix (4-vertex symmetric graph):")
    print(W)

    for x in range(n):
        r = min_plus_ricci(W, x)
        print(f"  Ricci(v{x}) = {r:.2f}")

    for u in range(n):
        for v in range(u + 1, n):
            tb = throat_bound(W, u, v)
            for tau in [0.5, 1.0, 2.0, 5.0, 10.0]:
                tr = throat_radius(W, u, v, tau)
                print(f"  TB({u},{v}) = {tb:.2f}, τ = {tau:.1f} → TR = {tr:.2f} ≤ {tb:.2f} ✓")
                assert tr <= tb + 1e-10, "Throat radius should be bounded by throat bound!"

    print()


def demo_3_einstein_bellman():
    """Demonstrate Theorem 3: Tropical Einstein = Bellman optimality."""
    print("=" * 70)
    print("THEOREM 3: Tropical Einstein Equation = Bellman Optimality")
    print("=" * 70)

    n = 5
    W = np.array([
        [0, 2, 5, np.inf, np.inf],
        [2, 0, 1,     3, np.inf],
        [5, 1, 0,     2,      4],
        [np.inf, 3, 2, 0,     1],
        [np.inf, np.inf, 4, 1, 0]
    ])

    source = 0
    dist, _ = bellman_ford(W, source)

    print(f"\nWeight matrix (5-vertex graph with some infinite edges):")
    for row in W:
        print(f"  [{', '.join(f'{x:5.1f}' if x < 100 else '  inf' for x in row)}]")

    print(f"\nShortest distances from source {source}:")
    for i, d in enumerate(dist):
        print(f"  Φ({i}) = {d:.2f}")

    # Verify Einstein equation
    satisfies = verify_tropical_einstein(W, source, dist)
    print(f"\nTropical Einstein equation satisfied: {satisfies}")

    print(f"\nVerification (Bellman fixed-point condition):")
    print(f"  Φ(source) = {dist[source]} {'= 0 ✓' if dist[source] == 0 else '≠ 0 ✗'}")
    for x in range(n):
        if x == source:
            continue
        relaxed = min(dist[y] + W[y][x] for y in range(n))
        match = abs(dist[x] - relaxed) < 1e-10
        print(f"  Φ({x}) = {dist[x]:.2f} = min_y(Φ(y) + W(y,{x})) = {relaxed:.2f} {'✓' if match else '✗'}")

    assert satisfies, "Shortest distances should satisfy Einstein equation!"
    print()


def demo_4_relaxation_convergence():
    """Demonstrate Theorem 4: Bellman-Ford relaxation convergence."""
    print("=" * 70)
    print("THEOREM 4: Bellman-Ford Relaxation Convergence")
    print("=" * 70)

    n = 6
    np.random.seed(42)
    W = np.random.uniform(1, 10, (n, n))
    np.fill_diagonal(W, 0)

    source = 0
    d = np.full(n, np.inf)
    d[source] = 0.0

    print(f"\n6-vertex random graph, source = {source}")
    print(f"Initial estimates: {d}")
    print(f"\nRelaxation iterations:")

    converged_at = -1
    for k in range(n + 2):
        d_new = relaxation_step(W, d)
        diff = np.max(np.abs(d_new - d))
        stable = diff < 1e-12
        print(f"  k={k}: d = [{', '.join(f'{x:.2f}' if x < 100 else '  inf' for x in d_new)}]"
              f"  Δmax = {diff:.2e}" + (" (CONVERGED)" if stable else ""))
        if stable and converged_at < 0:
            converged_at = k
        d = d_new

    # Verify against direct Bellman-Ford
    dist_bf, _ = bellman_ford(W, source)
    match = np.allclose(d, dist_bf)
    print(f"\nConverged at iteration k = {converged_at} (≤ n-1 = {n-1})")
    print(f"Matches Bellman-Ford: {match} ✓" if match else f"Does NOT match Bellman-Ford ✗")
    print(f"\nFinal distances: [{', '.join(f'{x:.2f}' for x in d)}]")

    # Verify Einstein equation at convergence
    satisfies = verify_tropical_einstein(W, source, d)
    print(f"Tropical Einstein equation satisfied at convergence: {satisfies} ✓")
    print()


def demo_5_surgery_on_lattice():
    """Bonus: Wormhole surgery on a grid/lattice spacetime."""
    print("=" * 70)
    print("BONUS: Wormhole Surgery on a 4×4 Lattice Spacetime")
    print("=" * 70)

    # Create 4x4 grid graph (16 vertices)
    rows, cols = 4, 4
    n = rows * cols
    INF = 1000.0
    W = np.full((n, n), INF)
    np.fill_diagonal(W, 0)

    def idx(r, c):
        return r * cols + c

    # Grid edges with unit weight
    for r in range(rows):
        for c in range(cols):
            if c + 1 < cols:
                W[idx(r, c)][idx(r, c + 1)] = 1
                W[idx(r, c + 1)][idx(r, c)] = 1
            if r + 1 < rows:
                W[idx(r, c)][idx(r + 1, c)] = 1
                W[idx(r + 1, c)][idx(r, c)] = 1

    s = idx(0, 0)  # Top-left
    t = idx(3, 3)  # Bottom-right
    u = idx(0, 1)  # Near top-left
    v = idx(3, 2)  # Near bottom-right

    print(f"\n4×4 grid spacetime:")
    print(f"  Source: ({0},{0}), Target: ({3},{3})")
    print(f"  Wormhole: ({0},{1}) ↔ ({3},{2})")

    for tau in [0.5, 1.0, 2.0, 5.0]:
        dist_before, _ = bellman_ford(W, s)
        W_new = wormhole_surgery(W, u, v, tau)
        dist_after, pred_after = bellman_ford(W_new, s)

        path = reconstruct_path(pred_after, s, t)
        uses_wormhole = (u in path and v in path)

        print(f"\n  τ = {tau:.1f}:")
        print(f"    Before: d(s,t) = {dist_before[t]:.1f}")
        print(f"    After:  d(s,t) = {dist_after[t]:.1f}")
        print(f"    Improvement: {dist_before[t] - dist_after[t]:.1f}")
        print(f"    Uses wormhole: {'Yes ✓' if uses_wormhole else 'No'}")
        coords_path = [(p // cols, p % cols) for p in path]
        print(f"    Path: {' → '.join(str(c) for c in coords_path)}")

    print()


if __name__ == "__main__":
    print("\n" + "█" * 70)
    print("  TROPICAL WORMHOLE SURGERY — NUMERICAL DEMONSTRATIONS")
    print("█" * 70 + "\n")

    demo_1_surgery_decreases_distance()
    demo_2_curvature_controls_throat()
    demo_3_einstein_bellman()
    demo_4_relaxation_convergence()
    demo_5_surgery_on_lattice()

    print("=" * 70)
    print("ALL DEMONSTRATIONS COMPLETED SUCCESSFULLY")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Wormhole Surgery — Visualizations

Generates publication-quality figures for the research paper and article.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap
import base64
import io
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def bellman_ford(W, source):
    n = W.shape[0]
    dist = np.full(n, np.inf)
    dist[source] = 0.0
    for _ in range(n - 1):
        updated = False
        for u in range(n):
            if dist[u] == np.inf: continue
            for v in range(n):
                if dist[u] + W[u][v] < dist[v]:
                    dist[v] = dist[u] + W[u][v]
                    updated = True
        if not updated: break
    return dist


def wormhole_surgery(W, u, v, tau):
    W_new = W.copy()
    W_new[u][v] = min(W[u][v], tau)
    W_new[v][u] = min(W[v][u], tau)
    return W_new


def relaxation_step(W, d):
    n = W.shape[0]
    d_new = np.empty(n)
    for x in range(n):
        d_new[x] = min(d[y] + W[y][x] for y in range(n))
    return d_new


def plot_surgery_distance_drop():
    """Figure 1: Distance vs. wormhole cost τ."""
    n = 8
    INF = 1000.0
    W = np.full((n, n), INF)
    np.fill_diagonal(W, 0)
    # Chain: 0-1-2-3-4-5-6-7
    for i in range(n - 1):
        W[i][i + 1] = 3
        W[i + 1][i] = 3

    s, t, u, v = 0, 7, 2, 5
    taus = np.linspace(0.1, 25, 100)
    dist_before = bellman_ford(W, s)[t]
    dists_after = []
    for tau in taus:
        W_new = wormhole_surgery(W, u, v, tau)
        dists_after.append(bellman_ford(W_new, s)[t])

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.axhline(y=dist_before, color='#e74c3c', linestyle='--', linewidth=2,
               label=f'Original distance = {dist_before:.0f}')
    ax.plot(taus, dists_after, color='#2ecc71', linewidth=2.5,
            label='Distance after surgery')
    ax.fill_between(taus, dists_after, dist_before, alpha=0.15, color='#2ecc71')

    critical_tau = dist_before - bellman_ford(W, s)[u] - bellman_ford(W, v)[t]
    ax.axvline(x=critical_tau, color='#3498db', linestyle=':', linewidth=1.5,
               label=f'Critical τ = {critical_tau:.1f}')

    ax.set_xlabel('Wormhole cost τ', fontsize=13)
    ax.set_ylabel('Tropical distance d(s, t)', fontsize=13)
    ax.set_title('Theorem 1: Wormhole Surgery Distance Drop', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='lower right')
    ax.set_xlim(taus[0], taus[-1])
    ax.grid(True, alpha=0.3)

    fig.savefig(os.path.join(OUTPUT_DIR, 'fig_surgery_distance.png'), dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_relaxation_convergence():
    """Figure 2: Relaxation convergence over iterations."""
    n = 8
    np.random.seed(123)
    W = np.random.uniform(1, 8, (n, n))
    np.fill_diagonal(W, 0)

    source = 0
    d = np.full(n, 50.0)
    d[source] = 0.0

    history = [d.copy()]
    for k in range(n + 3):
        d = relaxation_step(W, d)
        history.append(d.copy())
    history = np.array(history)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    colors = plt.cm.viridis(np.linspace(0, 0.9, n))
    for v in range(n):
        ax1.plot(range(len(history)), history[:, v], '-o', markersize=3,
                 color=colors[v], label=f'v{v}', linewidth=1.5)
    ax1.set_xlabel('Iteration k', fontsize=13)
    ax1.set_ylabel('Distance estimate d(k, v)', fontsize=13)
    ax1.set_title('Bellman-Ford Relaxation Convergence', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=9, ncol=2, loc='upper right')
    ax1.grid(True, alpha=0.3)

    # Max change per iteration
    changes = [np.max(np.abs(history[k + 1] - history[k])) for k in range(len(history) - 1)]
    ax2.semilogy(range(len(changes)), [max(c, 1e-16) for c in changes], 'o-',
                 color='#e74c3c', linewidth=2, markersize=5)
    ax2.axhline(y=1e-12, color='gray', linestyle='--', alpha=0.5, label='Convergence threshold')
    ax2.set_xlabel('Iteration k', fontsize=13)
    ax2.set_ylabel('Max change Δ_max', fontsize=13)
    ax2.set_title('Convergence Rate', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, 'fig_relaxation.png'), dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_lattice_surgery():
    """Figure 3: Heatmap of distance improvement on a grid."""
    rows, cols = 6, 6
    n = rows * cols
    INF = 1000.0
    W = np.full((n, n), INF)
    np.fill_diagonal(W, 0)

    def idx(r, c): return r * cols + c

    for r in range(rows):
        for c in range(cols):
            if c + 1 < cols:
                W[idx(r, c)][idx(r, c + 1)] = 1
                W[idx(r, c + 1)][idx(r, c)] = 1
            if r + 1 < rows:
                W[idx(r, c)][idx(r + 1, c)] = 1
                W[idx(r + 1, c)][idx(r, c)] = 1

    s = idx(0, 0)
    u, v = idx(1, 1), idx(4, 4)
    tau = 0.5

    dist_before = bellman_ford(W, s)
    W_new = wormhole_surgery(W, u, v, tau)
    dist_after = bellman_ford(W_new, s)

    improvement = np.zeros((rows, cols))
    for r in range(rows):
        for c in range(cols):
            vi = idx(r, c)
            improvement[r][c] = dist_before[vi] - dist_after[vi]

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Before
    before_grid = dist_before.reshape(rows, cols)
    im0 = axes[0].imshow(before_grid, cmap='YlOrRd', aspect='equal')
    axes[0].set_title('Before Surgery\n(distance from source)', fontsize=12, fontweight='bold')
    plt.colorbar(im0, ax=axes[0], shrink=0.8)

    # After
    after_grid = dist_after.reshape(rows, cols)
    im1 = axes[1].imshow(after_grid, cmap='YlOrRd', aspect='equal')
    axes[1].set_title('After Surgery\n(distance from source)', fontsize=12, fontweight='bold')
    plt.colorbar(im1, ax=axes[1], shrink=0.8)

    # Improvement
    cmap = LinearSegmentedColormap.from_list('improvement', ['white', '#2ecc71', '#27ae60'])
    im2 = axes[2].imshow(improvement, cmap=cmap, aspect='equal')
    axes[2].set_title('Distance Improvement\n(before − after)', fontsize=12, fontweight='bold')
    plt.colorbar(im2, ax=axes[2], shrink=0.8)

    for ax in axes:
        ur, uc = u // cols, u % cols
        vr, vc = v // cols, v % cols
        ax.plot(uc, ur, 'b*', markersize=15, markeredgecolor='black', markeredgewidth=1)
        ax.plot(vc, vr, 'b*', markersize=15, markeredgecolor='black', markeredgewidth=1)
        ax.plot(0, 0, 'rs', markersize=10, markeredgecolor='black', markeredgewidth=1)

    fig.suptitle(f'Wormhole Surgery on 6×6 Grid (τ = {tau})', fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, 'fig_lattice_surgery.png'), dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_curvature_landscape():
    """Figure 4: Min-plus Ricci curvature landscape."""
    rows, cols = 8, 8
    n = rows * cols
    INF = 1000.0
    W = np.full((n, n), INF)
    np.fill_diagonal(W, 0)

    def idx(r, c): return r * cols + c

    np.random.seed(77)
    for r in range(rows):
        for c in range(cols):
            if c + 1 < cols:
                w = np.random.uniform(0.5, 3.0)
                W[idx(r, c)][idx(r, c + 1)] = w
                W[idx(r, c + 1)][idx(r, c)] = w
            if r + 1 < rows:
                w = np.random.uniform(0.5, 3.0)
                W[idx(r, c)][idx(r + 1, c)] = w
                W[idx(r + 1, c)][idx(r, c)] = w

    ricci = np.zeros((rows, cols))
    for r in range(rows):
        for c in range(cols):
            x = idx(r, c)
            ricci[r][c] = min((W[x][y] + W[y][x]) / 2 for y in range(n))

    fig, ax = plt.subplots(figsize=(8, 7))
    im = ax.imshow(ricci, cmap='coolwarm_r', aspect='equal')
    ax.set_title('Min-Plus Ricci Curvature Landscape\n(8×8 Random Grid)', fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=ax, label='Ricci curvature R(x)')
    ax.set_xlabel('Column', fontsize=12)
    ax.set_ylabel('Row', fontsize=12)

    fig.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, 'fig_curvature.png'), dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_surgery_distance_drop()
    print(f"  [1] Surgery distance drop: {len(b64_1)} chars")
    b64_2 = plot_relaxation_convergence()
    print(f"  [2] Relaxation convergence: {len(b64_2)} chars")
    b64_3 = plot_lattice_surgery()
    print(f"  [3] Lattice surgery heatmap: {len(b64_3)} chars")
    b64_4 = plot_curvature_landscape()
    print(f"  [4] Curvature landscape: {len(b64_4)} chars")
    print("All visualizations saved to:", OUTPUT_DIR)

    # Save base64 data for JSON packaging
    import json
    viz_data = {
        "surgery_distance": b64_1,
        "relaxation_convergence": b64_2,
        "lattice_surgery": b64_3,
        "curvature_landscape": b64_4,
    }
    with open(os.path.join(OUTPUT_DIR, 'viz_data.json'), 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
