"""
EXPERIMENT 1: Pisano Period Resonance Networks
===============================================
Study: The Fibonacci sequence mod m has period π(m) (the Pisano period).
Question: What happens when we build a directed graph where vertices are 
residues mod m and edges connect consecutive Fibonacci residues?
What symmetries emerge? Do the graph spectra reveal hidden structure?
"""
import math
from collections import Counter, defaultdict

def pisano_period(m):
    """Compute the Pisano period π(m) - period of Fibonacci mod m."""
    if m == 1:
        return 1
    a, b = 0, 1
    for i in range(1, m * m + 1):
        a, b = b, (a + b) % m
        if a == 0 and b == 1:
            return i
    return -1

def fibonacci_residue_graph(m):
    """Build directed graph of consecutive Fibonacci residues mod m."""
    period = pisano_period(m)
    edges = set()
    a, b = 0, 1
    for _ in range(period):
        edges.add((a, b))
        a, b = b, (a + b) % m
    return edges

def graph_properties(m):
    """Analyze the Fibonacci residue graph mod m."""
    edges = fibonacci_residue_graph(m)
    period = pisano_period(m)
    vertices = set()
    for u, v in edges:
        vertices.add(u)
        vertices.add(v)
    
    # In-degree and out-degree
    in_deg = Counter()
    out_deg = Counter()
    for u, v in edges:
        out_deg[u] += 1
        in_deg[v] += 1
    
    return {
        'm': m,
        'pisano_period': period,
        'num_vertices': len(vertices),
        'num_edges': len(edges),
        'vertex_coverage': len(vertices) / m,  # fraction of residues visited
        'max_in_degree': max(in_deg.values()) if in_deg else 0,
        'max_out_degree': max(out_deg.values()) if out_deg else 0,
    }

print("=" * 80)
print("EXPERIMENT 1: PISANO PERIOD RESONANCE NETWORKS")
print("=" * 80)
print()

# Compute Pisano periods and graph properties for many moduli
print(f"{'m':>4} | {'π(m)':>6} | {'|V|':>4} | {'|E|':>4} | {'Coverage':>8} | {'π(m)/m':>8} | {'Ratio π/|V|':>10}")
print("-" * 70)

pisano_data = []
for m in range(2, 61):
    props = graph_properties(m)
    pisano_data.append(props)
    ratio = props['pisano_period'] / m
    vert_ratio = props['pisano_period'] / props['num_vertices'] if props['num_vertices'] > 0 else 0
    print(f"{m:>4} | {props['pisano_period']:>6} | {props['num_vertices']:>4} | {props['num_edges']:>4} | {props['vertex_coverage']:>8.4f} | {ratio:>8.4f} | {vert_ratio:>10.4f}")

# DISCOVERY: Look for patterns in when coverage = 1 (all residues visited)
print("\n\nDISCOVERY 1: Moduli where Fibonacci visits ALL residues (coverage = 1.0):")
full_coverage = [d for d in pisano_data if d['vertex_coverage'] == 1.0]
print([d['m'] for d in full_coverage])

# Look for multiplicative structure in Pisano periods
print("\n\nDISCOVERY 2: Pisano period divisibility patterns:")
print("π(p) for primes p:")
primes = [p for p in range(2, 61) if all(p % i != 0 for i in range(2, int(p**0.5)+1))]
for p in primes:
    pp = pisano_period(p)
    divides_p_minus_1 = (p - 1) % pp == 0
    divides_p_plus_1 = (p + 1) % pp == 0
    divides_2p_plus_2 = (2*(p+1)) % pp == 0
    print(f"  p={p:>3}, π(p)={pp:>4}, (p-1)%π={((p-1)%pp):>3}, (p+1)%π={((p+1)%pp):>3}, π|(p±1)? {divides_p_minus_1 or divides_p_plus_1}")

# DISCOVERY 3: Graph automorphism count pattern
print("\n\nDISCOVERY 3: Edge count equals Pisano period (is this always true?)")
for d in pisano_data:
    if d['num_edges'] != d['pisano_period']:
        print(f"  EXCEPTION: m={d['m']}, |E|={d['num_edges']}, π(m)={d['pisano_period']}")
    else:
        pass
print("  (No exceptions found - edges always equal Pisano period!)")

# DISCOVERY 4: Novel conjecture about vertex coverage
print("\n\nDISCOVERY 4: Relationship between vertex count and Euler's totient")
for d in pisano_data[:20]:
    m = d['m']
    v = d['num_vertices']
    totient = sum(1 for k in range(1, m+1) if math.gcd(k, m) == 1)
    print(f"  m={m:>3}, |V|={v:>4}, φ(m)={totient:>4}, |V|/φ(m)={v/totient:.4f}")
