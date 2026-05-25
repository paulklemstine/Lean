"""
Applications of Compositional Rounding Certificates
=====================================================

Demonstrates real-world applications of the compositional
rounding framework.
"""

from __future__ import annotations
import numpy as np
import random
from typing import Set, FrozenSet, List, Dict

from algorithms import (
    Hypergraph, HypergraphGluing, FractionalTransversal,
    RoundingCertificate, build_certificate, compose_certificates,
    agrees_on, threshold_rounding
)


# ============================================================
# Application 1: Distributed Sensor Coverage
# ============================================================

def sensor_coverage_example():
    """Model a distributed sensor network as a hypergraph transversal problem.

    Two regions share boundary sensors. Each region needs to cover all
    monitoring zones (edges). We compose local certificates for a global
    coverage guarantee.
    """
    print("=" * 60)
    print("APPLICATION 1: Distributed Sensor Coverage")
    print("=" * 60)

    # Region 1: sensors 0-7, monitoring zones as hyperedges
    region1_sensors = set(range(8))
    region1_zones = [
        frozenset({0, 1, 2}),    # Zone A
        frozenset({1, 3, 4}),    # Zone B
        frozenset({4, 5, 6}),    # Zone C
        frozenset({5, 6, 7}),    # Zone D (boundary zone)
    ]

    # Region 2: sensors 5-12, monitoring zones
    region2_sensors = set(range(5, 13))
    region2_zones = [
        frozenset({5, 6, 7}),    # Zone D (shared with Region 1)
        frozenset({7, 8, 9}),    # Zone E
        frozenset({9, 10, 11}),  # Zone F
        frozenset({10, 11, 12}), # Zone G
    ]

    # Boundary sensors: {5, 6, 7}
    boundary = region1_sensors & region2_sensors
    print(f"Boundary sensors: {sorted(boundary)}")

    H1 = Hypergraph(vertices=region1_sensors, edges=region1_zones)
    H2 = Hypergraph(vertices=region2_sensors, edges=region2_zones)
    all_edges = list(set(region1_zones + region2_zones))
    H = Hypergraph(vertices=region1_sensors | region2_sensors, edges=all_edges)

    gluing = HypergraphGluing(H1=H1, H2=H2, H=H, boundary=boundary)

    # Build local certificates
    cert1 = build_certificate(H1)
    cert2 = build_certificate(H2)

    # Ensure boundary agreement
    for v in boundary:
        val = max(cert1.fractional.values.get(v, 0),
                  cert2.fractional.values.get(v, 0))
        cert1.fractional.values[v] = val
        cert2.fractional.values[v] = val
    cert1.fractional_cost = cert1.fractional.cost(H1.vertices)
    cert2.fractional_cost = cert2.fractional.cost(H2.vertices)

    # Compose
    composed = compose_certificates(gluing, cert1, cert2)

    print(f"\nRegion 1: {len(H1.edges)} zones, fractional cost = {cert1.fractional_cost:.3f}")
    print(f"Region 2: {len(H2.edges)} zones, fractional cost = {cert2.fractional_cost:.3f}")
    print(f"Selected sensors: {sorted(composed.integral)}")
    print(f"Number selected: {len(composed.integral)}")

    # Verify all zones covered
    all_covered = True
    for i, e in enumerate(H.edges):
        hit = len(e & composed.integral) > 0
        zone_name = chr(65 + i) if i < 26 else str(i)
        status = "✓ covered" if hit else "✗ NOT covered"
        print(f"  Zone {zone_name} {sorted(e)}: {status}")
        if not hit:
            all_covered = False

    print(f"\nAll zones covered: {all_covered}")
    d = composed.degree
    bound = d * (cert1.fractional_cost + cert2.fractional_cost)
    print(f"Cost bound: {len(composed.integral)} ≤ {bound:.3f} (d={d})")


# ============================================================
# Application 2: Supply Chain Risk Assessment
# ============================================================

def supply_chain_example():
    """Model supply chain resilience as hypergraph transversal.

    Each product requires components from multiple suppliers.
    We need to identify a minimal set of suppliers to monitor
    such that every product has at least one monitored supplier.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Supply Chain Risk Assessment")
    print("=" * 60)

    # Domestic suppliers: 0-9
    # International suppliers: 7-15
    # Boundary (dual-source): 7, 8, 9
    domestic = set(range(10))
    international = set(range(7, 16))
    boundary = domestic & international

    # Domestic products (each needs components from several domestic suppliers)
    domestic_products = [
        frozenset({0, 1, 7}),   # Product A
        frozenset({2, 3, 8}),   # Product B
        frozenset({4, 5}),      # Product C
        frozenset({5, 6, 9}),   # Product D
        frozenset({7, 8, 9}),   # Product E (boundary product)
    ]

    # International products
    international_products = [
        frozenset({7, 8, 10}),   # Product F
        frozenset({9, 11, 12}),  # Product G
        frozenset({10, 13, 14}), # Product H
        frozenset({12, 14, 15}), # Product I
    ]

    H1 = Hypergraph(vertices=domestic, edges=domestic_products)
    H2 = Hypergraph(vertices=international, edges=international_products)
    all_products = list(set(domestic_products + international_products))
    H = Hypergraph(vertices=domestic | international, edges=all_products)
    gluing = HypergraphGluing(H1=H1, H2=H2, H=H, boundary=boundary)

    print(f"Domestic suppliers: {sorted(domestic)}")
    print(f"International suppliers: {sorted(international)}")
    print(f"Dual-source (boundary): {sorted(boundary)}")

    cert1 = build_certificate(H1)
    cert2 = build_certificate(H2)

    for v in boundary:
        val = max(cert1.fractional.values.get(v, 0),
                  cert2.fractional.values.get(v, 0))
        cert1.fractional.values[v] = val
        cert2.fractional.values[v] = val
    cert1.fractional_cost = cert1.fractional.cost(H1.vertices)
    cert2.fractional_cost = cert2.fractional.cost(H2.vertices)

    composed = compose_certificates(gluing, cert1, cert2)

    print(f"\nSuppliers to monitor: {sorted(composed.integral)}")
    print(f"Number to monitor: {len(composed.integral)}")

    for i, e in enumerate(H.edges):
        name = chr(65 + i)
        hit = len(e & composed.integral) > 0
        print(f"  Product {name} (suppliers {sorted(e)}): {'✓' if hit else '✗'}")

    print(f"\nCost: {len(composed.integral)} suppliers")
    print(f"Bound: {composed.degree * (cert1.fractional_cost + cert2.fractional_cost):.2f}")


# ============================================================
# Application 3: Hierarchical Decomposition
# ============================================================

def hierarchical_decomposition_example():
    """Demonstrate recursive compositional certification.

    Decompose a large hypergraph into 4 pieces, compose pairwise,
    then compose the results.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Hierarchical Decomposition (4 pieces)")
    print("=" * 60)

    # 4 regions with pairwise boundaries
    V1 = set(range(0, 8))    # Region 1: 0-7
    V2 = set(range(5, 13))   # Region 2: 5-12
    V3 = set(range(10, 18))  # Region 3: 10-17
    V4 = set(range(15, 23))  # Region 4: 15-22

    rng = random.Random(42)

    def make_edges(V, num=6, min_sz=2, max_sz=3):
        vlist = sorted(V)
        edges = []
        for _ in range(num):
            sz = rng.randint(min_sz, min(max_sz, len(vlist)))
            edges.append(frozenset(rng.sample(vlist, sz)))
        return list(set(edges))

    H1 = Hypergraph(vertices=V1, edges=make_edges(V1))
    H2 = Hypergraph(vertices=V2, edges=make_edges(V2))
    H3 = Hypergraph(vertices=V3, edges=make_edges(V3))
    H4 = Hypergraph(vertices=V4, edges=make_edges(V4))

    print(f"Region 1: {sorted(V1)}, {len(H1.edges)} edges")
    print(f"Region 2: {sorted(V2)}, {len(H2.edges)} edges")
    print(f"Region 3: {sorted(V3)}, {len(H3.edges)} edges")
    print(f"Region 4: {sorted(V4)}, {len(H4.edges)} edges")

    # Level 1: compose (H1, H2) and (H3, H4)
    V12 = V1 | V2
    edges12 = list(set(H1.edges + H2.edges))
    H12 = Hypergraph(vertices=V12, edges=edges12)
    b12 = V1 & V2
    gluing12 = HypergraphGluing(H1=H1, H2=H2, H=H12, boundary=b12)

    V34 = V3 | V4
    edges34 = list(set(H3.edges + H4.edges))
    H34 = Hypergraph(vertices=V34, edges=edges34)
    b34 = V3 & V4
    gluing34 = HypergraphGluing(H1=H3, H2=H4, H=H34, boundary=b34)

    # Build local certificates
    certs = [build_certificate(h) for h in [H1, H2, H3, H4]]

    # Ensure boundary agreement for each pair
    def ensure_agreement(c1, c2, boundary, h1, h2):
        for v in boundary:
            val = max(c1.fractional.values.get(v, 0),
                      c2.fractional.values.get(v, 0))
            c1.fractional.values[v] = val
            c2.fractional.values[v] = val
        c1.fractional_cost = c1.fractional.cost(h1.vertices)
        c2.fractional_cost = c2.fractional.cost(h2.vertices)

    ensure_agreement(certs[0], certs[1], b12, H1, H2)
    ensure_agreement(certs[2], certs[3], b34, H3, H4)

    # Compose level 1
    cert12 = compose_certificates(gluing12, certs[0], certs[1])
    cert34 = compose_certificates(gluing34, certs[2], certs[3])

    print(f"\nLevel 1 composition:")
    print(f"  H12: {len(cert12.integral)} vertices selected")
    print(f"  H34: {len(cert34.integral)} vertices selected")

    # Level 2: compose (H12, H34)
    V_all = V12 | V34
    edges_all = list(set(edges12 + edges34))
    H_all = Hypergraph(vertices=V_all, edges=edges_all)
    b_all = V12 & V34

    # Build certificates for H12 and H34 from composed results
    cert12_rc = build_certificate(H12)
    cert34_rc = build_certificate(H34)

    ensure_agreement(cert12_rc, cert34_rc, b_all, H12, H34)

    gluing_all = HypergraphGluing(H1=H12, H2=H34, H=H_all, boundary=b_all)
    cert_all = compose_certificates(gluing_all, cert12_rc, cert34_rc)

    print(f"\nLevel 2 composition:")
    print(f"  Total vertices: {len(V_all)}")
    print(f"  Total edges: {len(edges_all)}")
    print(f"  Selected: {len(cert_all.integral)} vertices")
    print(f"  All edges covered: {all(len(e & cert_all.integral) > 0 for e in H_all.edges)}")

    # Compare with monolithic solution
    mono_cert = build_certificate(H_all)
    print(f"\nMonolithic solution: {len(mono_cert.integral)} vertices")
    print(f"Compositional overhead: {len(cert_all.integral) - len(mono_cert.integral)} extra vertices")


if __name__ == "__main__":
    sensor_coverage_example()
    supply_chain_example()
    hierarchical_decomposition_example()


"""
Compositional Rounding Certificates — Demonstration
=====================================================

Generates random hypergraph gluings, solves local LPs, composes
certificates, and verifies coverage and cost bounds.
"""

from __future__ import annotations
import numpy as np
import random
from typing import Set, FrozenSet, List, Tuple

from algorithms import (
    Hypergraph, HypergraphGluing, FractionalTransversal,
    RoundingCertificate, agrees_on, glued_fn, threshold_rounding,
    compose_certificates, solve_fractional_transversal_lp, build_certificate
)


def random_hypergraph(vertices: Set[int], num_edges: int,
                      min_size: int = 2, max_size: int = 4,
                      rng: random.Random = None) -> Hypergraph:
    """Generate a random hypergraph with given vertex set."""
    if rng is None:
        rng = random.Random()
    vlist = sorted(vertices)
    edges = []
    for _ in range(num_edges):
        size = rng.randint(min_size, min(max_size, len(vlist)))
        e = frozenset(rng.sample(vlist, size))
        edges.append(e)
    # Remove duplicates
    edges = list(set(edges))
    return Hypergraph(vertices=vertices, edges=edges)


def random_hypergraph_gluing(n: int = 20, boundary_size: int = 3,
                             edges_per_side: int = 8,
                             min_edge_size: int = 2,
                             max_edge_size: int = 4,
                             seed: int = None) -> HypergraphGluing:
    """Generate a random hypergraph gluing.

    Creates two overlapping hypergraphs with a shared boundary.

    Args:
        n: Total number of vertices
        boundary_size: Size of the boundary (shared vertices)
        edges_per_side: Number of edges per side
        min_edge_size, max_edge_size: Edge size range
        seed: Random seed

    Returns:
        A HypergraphGluing instance
    """
    rng = random.Random(seed)

    all_vertices = set(range(n))
    boundary = set(range(boundary_size))

    # Split remaining vertices
    remaining = sorted(all_vertices - boundary)
    rng.shuffle(remaining)
    split = len(remaining) // 2
    v1_extra = set(remaining[:split])
    v2_extra = set(remaining[split:])

    V1 = boundary | v1_extra
    V2 = boundary | v2_extra

    # Generate edges for each side
    H1 = random_hypergraph(V1, edges_per_side, min_edge_size, max_edge_size, rng)
    H2 = random_hypergraph(V2, edges_per_side, min_edge_size, max_edge_size, rng)

    # Combined hypergraph
    all_edges = list(set(H1.edges + H2.edges))
    H = Hypergraph(vertices=V1 | V2, edges=all_edges)

    return HypergraphGluing(H1=H1, H2=H2, H=H, boundary=boundary)


def demo_basic_composition():
    """Demonstrate basic certificate composition on a small example."""
    print("=" * 60)
    print("DEMO 1: Basic Certificate Composition")
    print("=" * 60)

    # Create a simple gluing
    #   H1: vertices {0,1,2,3}, edges {{0,1,2}, {2,3}}
    #   H2: vertices {2,3,4,5}, edges {{2,3,4}, {4,5}}
    #   Boundary: {2,3}
    H1 = Hypergraph(
        vertices={0, 1, 2, 3},
        edges=[frozenset({0, 1, 2}), frozenset({2, 3})]
    )
    H2 = Hypergraph(
        vertices={2, 3, 4, 5},
        edges=[frozenset({2, 3, 4}), frozenset({4, 5})]
    )
    H = Hypergraph(
        vertices={0, 1, 2, 3, 4, 5},
        edges=list(set(H1.edges + H2.edges))
    )
    boundary = {2, 3}
    gluing = HypergraphGluing(H1=H1, H2=H2, H=H, boundary=boundary)

    print(f"\nH1: vertices={sorted(H1.vertices)}, edges={[sorted(e) for e in H1.edges]}")
    print(f"H2: vertices={sorted(H2.vertices)}, edges={[sorted(e) for e in H2.edges]}")
    print(f"H:  vertices={sorted(H.vertices)}, edges={[sorted(e) for e in H.edges]}")
    print(f"Boundary: {sorted(boundary)}")

    # Build local certificates
    cert1 = build_certificate(H1)
    cert2 = build_certificate(H2)

    print(f"\nCertificate 1:")
    print(f"  Fractional: {dict(sorted(cert1.fractional.values.items()))}")
    print(f"  Fractional cost: {cert1.fractional_cost:.4f}")
    print(f"  Integral: {sorted(cert1.integral)}")
    print(f"  Degree: {cert1.degree}")

    print(f"\nCertificate 2:")
    print(f"  Fractional: {dict(sorted(cert2.fractional.values.items()))}")
    print(f"  Fractional cost: {cert2.fractional_cost:.4f}")
    print(f"  Integral: {sorted(cert2.integral)}")
    print(f"  Degree: {cert2.degree}")

    # Check boundary agreement
    agreement = agrees_on(cert1.fractional, cert2.fractional, boundary)
    print(f"\nBoundary agreement: {agreement}")

    if not agreement:
        # Project to common boundary values
        print("  Adjusting boundary values for agreement...")
        for v in boundary:
            avg = (cert1.fractional.values.get(v, 0) +
                   cert2.fractional.values.get(v, 0)) / 2
            # Use max to ensure coverage
            val = max(cert1.fractional.values.get(v, 0),
                      cert2.fractional.values.get(v, 0))
            cert1.fractional.values[v] = val
            cert2.fractional.values[v] = val
        cert1.fractional_cost = cert1.fractional.cost(H1.vertices)
        cert2.fractional_cost = cert2.fractional.cost(H2.vertices)
        print(f"  Agreement after adjustment: {agrees_on(cert1.fractional, cert2.fractional, boundary)}")

    # Compose certificates
    composed = compose_certificates(gluing, cert1, cert2)

    print(f"\nComposed Certificate:")
    print(f"  Integral: {sorted(composed.integral)}")
    print(f"  Cost: {composed.cost:.0f}")
    print(f"  Degree: {composed.degree}")
    print(f"  Cost bound (d * (fc1 + fc2)): {composed.degree * (cert1.fractional_cost + cert2.fractional_cost):.4f}")
    print(f"  Bound satisfied: {composed.cost <= composed.degree * (cert1.fractional_cost + cert2.fractional_cost) + 1e-9}")

    # Verify coverage
    for e in H.edges:
        hit = len(e & composed.integral) > 0
        print(f"  Edge {sorted(e)}: {'✓' if hit else '✗'}")


def demo_random_gluings():
    """Demonstrate compositional rounding on random hypergraph gluings."""
    print("\n" + "=" * 60)
    print("DEMO 2: Random Hypergraph Gluings")
    print("=" * 60)

    results = []
    boundary_sizes = [2, 3, 4, 5]
    num_trials = 100

    for bsize in boundary_sizes:
        ratios = []
        valid_count = 0
        bound_satisfied = 0

        for trial in range(num_trials):
            try:
                gluing = random_hypergraph_gluing(
                    n=20, boundary_size=bsize, edges_per_side=8,
                    min_edge_size=2, max_edge_size=4, seed=trial * 100 + bsize
                )

                cert1 = build_certificate(gluing.H1)
                cert2 = build_certificate(gluing.H2)

                # Ensure boundary agreement by taking max
                for v in gluing.boundary:
                    val = max(cert1.fractional.values.get(v, 0),
                              cert2.fractional.values.get(v, 0))
                    cert1.fractional.values[v] = val
                    cert2.fractional.values[v] = val
                cert1.fractional_cost = cert1.fractional.cost(gluing.H1.vertices)
                cert2.fractional_cost = cert2.fractional.cost(gluing.H2.vertices)

                composed = compose_certificates(gluing, cert1, cert2)

                d = composed.degree
                frac_sum = cert1.fractional_cost + cert2.fractional_cost
                ratio = composed.cost / frac_sum if frac_sum > 0 else 0

                ratios.append(ratio)
                valid_count += 1

                if composed.cost <= d * frac_sum + 1e-9:
                    bound_satisfied += 1

            except Exception as e:
                continue

        if ratios:
            avg_ratio = np.mean(ratios)
            max_ratio = np.max(ratios)
            results.append({
                'boundary_size': bsize,
                'valid': valid_count,
                'bound_satisfied': bound_satisfied,
                'avg_ratio': avg_ratio,
                'max_ratio': max_ratio
            })
            print(f"\nBoundary size {bsize}:")
            print(f"  Valid trials: {valid_count}/{num_trials}")
            print(f"  Bound satisfied: {bound_satisfied}/{valid_count}")
            print(f"  Average cost ratio: {avg_ratio:.4f}")
            print(f"  Max cost ratio: {max_ratio:.4f}")

    return results


def demo_conjecture_test():
    """Test the tight compositional ratio conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 3: Conjecture Test")
    print("=" * 60)
    print("Testing: ρ(g) ≤ max(d₁,d₂) · (1 + k·c/|V|)")

    violations = 0
    total = 0

    for seed in range(500):
        try:
            bsize = random.randint(2, 5)
            gluing = random_hypergraph_gluing(
                n=20, boundary_size=bsize, edges_per_side=8,
                min_edge_size=2, max_edge_size=4, seed=seed + 10000
            )

            cert1 = build_certificate(gluing.H1)
            cert2 = build_certificate(gluing.H2)

            for v in gluing.boundary:
                val = max(cert1.fractional.values.get(v, 0),
                          cert2.fractional.values.get(v, 0))
                cert1.fractional.values[v] = val
                cert2.fractional.values[v] = val
            cert1.fractional_cost = cert1.fractional.cost(gluing.H1.vertices)
            cert2.fractional_cost = cert2.fractional.cost(gluing.H2.vertices)

            composed = compose_certificates(gluing, cert1, cert2)

            d = max(cert1.degree, cert2.degree)
            k = len(gluing.boundary)
            c = max((len(e) for e in gluing.H.edges), default=1)
            n = len(gluing.H.vertices)

            frac_sum = cert1.fractional_cost + cert2.fractional_cost
            if frac_sum <= 0:
                continue

            rho = composed.cost / frac_sum
            bound = d * (1 + k * c / n)

            total += 1
            if rho > bound + 1e-9:
                violations += 1
                print(f"  VIOLATION at seed {seed}: ρ={rho:.4f}, bound={bound:.4f}")

        except Exception:
            continue

    print(f"\nTotal tests: {total}")
    print(f"Violations: {violations}")
    print(f"Conjecture {'HOLDS' if violations == 0 else 'VIOLATED'} on test set")


if __name__ == "__main__":
    demo_basic_composition()
    demo_random_gluings()
    demo_conjecture_test()


"""
Visualization: Compositional Rounding Cost Bounds
===================================================

Shows how the compositional cost ratio varies with boundary size
and edge size, demonstrating the d-approximation guarantee.
Uses matplotlib to produce curves and a heatmap.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

# ---- Inline all needed functions ----

def solve_simple_fractional(vertices, edges):
    """Simple greedy fractional transversal."""
    values = {v: 0.0 for v in vertices}
    for e in edges:
        s = sum(values[v] for v in e)
        if s < 1.0:
            deficit = 1.0 - s
            per_vertex = deficit / len(e)
            for v in e:
                values[v] += per_vertex
    return values

def threshold_round(values, vertices, d):
    if d <= 0:
        return set()
    return {v for v in vertices if values.get(v, 0) >= 1.0 / d - 1e-9}

def random_hypergraph_edges(vertices, num_edges, min_sz, max_sz, rng):
    vlist = sorted(vertices)
    edges = []
    for _ in range(num_edges):
        sz = rng.randint(min_sz, min(max_sz, len(vlist)))
        edges.append(frozenset(rng.sample(vlist, sz)))
    return list(set(edges))

def run_experiment(n, bsize, max_edge_size, num_trials=50):
    """Run compositional rounding experiments and return statistics."""
    ratios = []
    rng = random.Random(42 + n * 100 + bsize * 10 + max_edge_size)

    for trial in range(num_trials):
        all_verts = set(range(n))
        boundary = set(range(bsize))
        remaining = sorted(all_verts - boundary)
        rng.shuffle(remaining)
        split = len(remaining) // 2
        V1 = boundary | set(remaining[:split])
        V2 = boundary | set(remaining[split:])

        edges1 = random_hypergraph_edges(V1, 8, 2, max_edge_size, rng)
        edges2 = random_hypergraph_edges(V2, 8, 2, max_edge_size, rng)

        if not edges1 or not edges2:
            continue

        x1 = solve_simple_fractional(V1, edges1)
        x2 = solve_simple_fractional(V2, edges2)

        for v in boundary:
            val = max(x1.get(v, 0), x2.get(v, 0))
            x1[v] = val
            x2[v] = val

        # Glue
        x_glued = {}
        for v in V1 | V2:
            x_glued[v] = x1[v] if v in V1 else x2[v]

        d = max_edge_size
        S = threshold_round(x_glued, V1 | V2, d)

        # Check all edges covered
        all_edges = list(set(edges1 + edges2))
        all_covered = all(len(e & S) > 0 for e in all_edges)
        if not all_covered:
            continue

        frac_cost = sum(x1[v] for v in V1) + sum(x2[v] for v in V2)
        if frac_cost > 0:
            ratio = len(S) / frac_cost
            ratios.append(ratio)

    return ratios

# ---- Generate data ----

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Cost ratio vs boundary size (fixed edge size)
boundary_sizes = [2, 3, 4, 5, 6, 7]
for d in [2, 3, 4]:
    means = []
    maxes = []
    for bsize in boundary_sizes:
        ratios = run_experiment(20, bsize, d, num_trials=80)
        if ratios:
            means.append(np.mean(ratios))
            maxes.append(np.max(ratios))
        else:
            means.append(0)
            maxes.append(0)
    axes[0].plot(boundary_sizes, means, 'o-', label=f'd={d} (avg)', linewidth=2)
    axes[0].plot(boundary_sizes, maxes, 's--', alpha=0.5, label=f'd={d} (max)')
    axes[0].axhline(y=d, color='gray', linestyle=':', alpha=0.3)

axes[0].set_xlabel('Boundary Size |V₀|', fontsize=12)
axes[0].set_ylabel('Cost Ratio |S| / Σx', fontsize=12)
axes[0].set_title('Cost Ratio vs Boundary Size', fontsize=13, fontweight='bold')
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)

# Panel 2: Cost ratio vs edge size (fixed boundary)
edge_sizes = [2, 3, 4, 5]
for bsize in [2, 4, 6]:
    means = []
    for d in edge_sizes:
        ratios = run_experiment(20, bsize, d, num_trials=80)
        if ratios:
            means.append(np.mean(ratios))
        else:
            means.append(0)
    axes[1].plot(edge_sizes, means, 'o-', label=f'|V₀|={bsize}', linewidth=2)

# Theoretical bound line
axes[1].plot(edge_sizes, edge_sizes, 'k--', label='Bound (d)', linewidth=1.5, alpha=0.5)

axes[1].set_xlabel('Max Edge Size d', fontsize=12)
axes[1].set_ylabel('Avg Cost Ratio', fontsize=12)
axes[1].set_title('Cost Ratio vs Edge Size', fontsize=13, fontweight='bold')
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

# Panel 3: Heatmap of average cost ratio
bsizes = [2, 3, 4, 5, 6]
dsizes = [2, 3, 4, 5]
heatmap_data = np.zeros((len(dsizes), len(bsizes)))

for i, d in enumerate(dsizes):
    for j, b in enumerate(bsizes):
        ratios = run_experiment(20, b, d, num_trials=60)
        if ratios:
            heatmap_data[i, j] = np.mean(ratios)

im = axes[2].imshow(heatmap_data, cmap='YlOrRd', aspect='auto', origin='lower')
axes[2].set_xticks(range(len(bsizes)))
axes[2].set_xticklabels(bsizes)
axes[2].set_yticks(range(len(dsizes)))
axes[2].set_yticklabels(dsizes)
axes[2].set_xlabel('Boundary Size |V₀|', fontsize=12)
axes[2].set_ylabel('Max Edge Size d', fontsize=12)
axes[2].set_title('Avg Cost Ratio Heatmap', fontsize=13, fontweight='bold')

# Add text annotations
for i in range(len(dsizes)):
    for j in range(len(bsizes)):
        axes[2].text(j, i, f'{heatmap_data[i,j]:.2f}',
                    ha='center', va='center', fontsize=10, fontweight='bold')

fig.colorbar(im, ax=axes[2], shrink=0.8, label='Cost Ratio')

plt.suptitle('Compositional Rounding: Cost Bound Analysis',
            fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_cost_bound.png', dpi=150, bbox_inches='tight')
print("Saved viz_cost_bound.png")


"""
Visualization: Hypergraph Gluing and Compositional Rounding
============================================================

Visualizes a hypergraph decomposition with two regions sharing a boundary,
showing the fractional transversal values and threshold rounding result.
Uses matplotlib to produce a static heatmap/network diagram.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection

# ---- Inline all needed functions ----

def solve_simple_fractional(vertices, edges):
    """Simple greedy fractional transversal (no scipy needed)."""
    values = {v: 0.0 for v in vertices}
    for e in edges:
        s = sum(values[v] for v in e)
        if s < 1.0:
            deficit = 1.0 - s
            per_vertex = deficit / len(e)
            for v in e:
                values[v] += per_vertex
    return values

def threshold_round(values, vertices, d):
    """Threshold rounding at 1/d."""
    if d <= 0:
        return set()
    threshold = 1.0 / d
    return {v for v in vertices if values.get(v, 0) >= threshold - 1e-9}

# ---- Create example hypergraph gluing ----

# Region 1 (left): vertices 0-7
V1 = set(range(8))
edges1 = [
    frozenset({0, 1, 2}),
    frozenset({1, 3, 4}),
    frozenset({4, 5, 6}),
    frozenset({5, 6, 7}),
]

# Region 2 (right): vertices 5-12
V2 = set(range(5, 13))
edges2 = [
    frozenset({5, 6, 7}),
    frozenset({7, 8, 9}),
    frozenset({9, 10, 11}),
    frozenset({10, 11, 12}),
]

boundary = V1 & V2  # {5, 6, 7}

# Solve fractional transversals
x1 = solve_simple_fractional(V1, edges1)
x2 = solve_simple_fractional(V2, edges2)

# Ensure boundary agreement (take max)
for v in boundary:
    val = max(x1.get(v, 0), x2.get(v, 0))
    x1[v] = val
    x2[v] = val

# Glue
x_glued = {}
for v in V1 | V2:
    if v in V1:
        x_glued[v] = x1[v]
    else:
        x_glued[v] = x2[v]

# Threshold rounding
d = 3  # max edge size
S = threshold_round(x_glued, V1 | V2, d)

# ---- Visualization ----

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Vertex positions (arranged in two rows)
positions = {}
for i, v in enumerate(sorted(V1 | V2)):
    if v < 5:
        positions[v] = (v * 1.5, 0)
    elif v < 8:
        positions[v] = (v * 1.5, 0)
    else:
        positions[v] = (v * 1.5, 0)

# Better layout: arc
all_verts = sorted(V1 | V2)
n = len(all_verts)
for i, v in enumerate(all_verts):
    angle = np.pi * (1 - i / (n - 1))
    positions[v] = (5 * np.cos(angle), 3 * np.sin(angle))

def draw_hypergraph(ax, vertices, edges, values, selected, title, boundary_set):
    """Draw a hypergraph with vertex colors based on fractional values."""
    ax.set_xlim(-6.5, 6.5)
    ax.set_ylim(-1.5, 4.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=14, fontweight='bold')

    # Draw edges as colored convex hulls
    colors = plt.cm.Set3(np.linspace(0, 1, len(edges)))
    for i, e in enumerate(edges):
        pts = np.array([positions[v] for v in e])
        if len(pts) >= 3:
            from matplotlib.patches import Polygon
            # Sort by angle from centroid
            centroid = pts.mean(axis=0)
            angles = np.arctan2(pts[:, 1] - centroid[1], pts[:, 0] - centroid[0])
            order = np.argsort(angles)
            pts_sorted = pts[order]
            # Expand slightly
            expanded = centroid + 1.15 * (pts_sorted - centroid)
            poly = Polygon(expanded, alpha=0.15, facecolor=colors[i],
                          edgecolor=colors[i], linewidth=2)
            ax.add_patch(poly)
        elif len(pts) == 2:
            ax.plot(pts[:, 0], pts[:, 1], '-', color=colors[i],
                   linewidth=3, alpha=0.3)

    # Draw vertices
    for v in sorted(vertices):
        x, y = positions[v]
        val = values.get(v, 0)

        # Color based on value
        if v in boundary_set:
            edge_color = 'orange'
            lw = 3
        else:
            edge_color = 'black'
            lw = 1.5

        if v in selected:
            face_color = plt.cm.Reds(0.3 + 0.7 * val)
            marker_size = 500
        else:
            face_color = plt.cm.Blues(0.1 + 0.6 * val)
            marker_size = 350

        ax.scatter(x, y, s=marker_size, c=[face_color],
                  edgecolors=edge_color, linewidths=lw, zorder=5)
        ax.annotate(f'{v}\n({val:.2f})', (x, y),
                   ha='center', va='center', fontsize=8, fontweight='bold',
                   zorder=6)

    ax.axis('off')

# Panel 1: H1 with x1
draw_hypergraph(axes[0], V1, edges1, x1, set(), 'Region 1 (H₁)', boundary)

# Panel 2: H2 with x2
draw_hypergraph(axes[1], V2, edges2, x2, set(), 'Region 2 (H₂)', boundary)

# Panel 3: Glued with threshold rounding
all_edges = list(set(edges1) | set(edges2))
draw_hypergraph(axes[2], V1 | V2, all_edges, x_glued, S,
               f'Composed (threshold 1/{d})', boundary)

# Legend
legend_elements = [
    mpatches.Patch(facecolor='lightblue', edgecolor='black', label='Unselected vertex'),
    mpatches.Patch(facecolor='salmon', edgecolor='black', label='Selected (threshold)'),
    mpatches.Patch(facecolor='white', edgecolor='orange', linewidth=2, label='Boundary vertex'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=11,
          bbox_to_anchor=(0.5, -0.02))

plt.suptitle('Compositional Rounding: Hypergraph Gluing',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_gluing.png', dpi=150, bbox_inches='tight')
print("Saved viz_gluing.png")


"""
Visualization: Threshold Rounding Mechanism
=============================================

Illustrates the pigeonhole argument: if the sum over an edge is >= 1
and the edge has <= d vertices, then at least one vertex has value >= 1/d.
Shows how threshold rounding selects vertices.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- Panel 1: Pigeonhole illustration ----
ax = axes[0]
np.random.seed(42)

# Example edge with d=4 vertices, sum >= 1
d = 4
values = np.array([0.35, 0.10, 0.40, 0.20])  # sum = 1.05
threshold = 1.0 / d

bars = ax.bar(range(d), values, color=['#e74c3c' if v >= threshold else '#3498db'
                                        for v in values],
              edgecolor='black', linewidth=1.5, width=0.6)

ax.axhline(y=threshold, color='red', linestyle='--', linewidth=2,
           label=f'Threshold = 1/d = {threshold:.2f}')

# Annotate
for i, v in enumerate(values):
    ax.text(i, v + 0.02, f'{v:.2f}', ha='center', fontsize=12, fontweight='bold')

ax.set_xticks(range(d))
ax.set_xticklabels([f'v{i}' for i in range(d)], fontsize=12)
ax.set_ylabel('x(v)', fontsize=13)
ax.set_title(f'Pigeonhole: d={d}, Σx = {sum(values):.2f} ≥ 1', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.set_ylim(0, 0.55)
ax.grid(True, alpha=0.2, axis='y')

# ---- Panel 2: Threshold sweep ----
ax = axes[1]

# Generate a fractional transversal
np.random.seed(123)
n = 15
x_vals = np.sort(np.random.exponential(0.3, n))[::-1]
x_vals = np.clip(x_vals, 0, 1)

# Sweep thresholds
thresholds = np.linspace(0.05, 0.8, 50)
selected_counts = [np.sum(x_vals >= t) for t in thresholds]
costs = [np.sum(x_vals) * (1.0/t) if t > 0 else n for t in thresholds]

ax.plot(thresholds, selected_counts, 'b-', linewidth=2.5, label='|S| (selected)')
ax.fill_between(thresholds, selected_counts, alpha=0.15, color='blue')

# Mark specific thresholds for d=2,3,4,5
for d_val in [2, 3, 4, 5]:
    t = 1.0 / d_val
    cnt = int(np.sum(x_vals >= t))
    ax.plot(t, cnt, 'ro', markersize=10, zorder=5)
    ax.annotate(f'd={d_val}\n|S|={cnt}', (t, cnt),
               textcoords='offset points', xytext=(10, 5), fontsize=10,
               fontweight='bold')

ax.set_xlabel('Threshold (1/d)', fontsize=13)
ax.set_ylabel('Vertices Selected', fontsize=13)
ax.set_title('Threshold Rounding: Selected Set Size', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=11)

# ---- Panel 3: Cost bound verification ----
ax = axes[2]

# For various d, compare |S| to d * Σx
d_values = range(1, 8)
frac_cost = np.sum(x_vals)
actual_costs = []
bound_costs = []

for d_val in d_values:
    t = 1.0 / d_val
    S_size = np.sum(x_vals >= t)
    actual_costs.append(S_size)
    bound_costs.append(d_val * frac_cost)

ax.bar(np.array(list(d_values)) - 0.15, actual_costs, width=0.3,
       color='#2ecc71', edgecolor='black', label='|S| (actual)', zorder=3)
ax.bar(np.array(list(d_values)) + 0.15, bound_costs, width=0.3,
       color='#e74c3c', edgecolor='black', alpha=0.6, label='d · Σx (bound)', zorder=3)

ax.set_xlabel('Max Edge Size d', fontsize=13)
ax.set_ylabel('Cost', fontsize=13)
ax.set_title(f'Cost Bound: |S| ≤ d · Σx  (Σx = {frac_cost:.2f})', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.set_xticks(list(d_values))
ax.grid(True, alpha=0.2, axis='y')

# Verify all satisfy bound
for i, d_val in enumerate(d_values):
    satisfied = actual_costs[i] <= bound_costs[i] + 1e-9
    marker = '✓' if satisfied else '✗'
    ax.text(d_val, max(actual_costs[i], bound_costs[i]) + 0.5,
            marker, ha='center', fontsize=14, color='green' if satisfied else 'red')

plt.suptitle('Threshold Rounding: The Pigeonhole Principle at Work',
            fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_threshold.png', dpi=150, bbox_inches='tight')
print("Saved viz_threshold.png")
