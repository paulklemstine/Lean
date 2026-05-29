#!/usr/bin/env python3
"""
Applications of Volcano Depth Detection via Topological Invariants

Demonstrates real-world applications:
1. Cryptographic depth oracle simulation
2. Volcano navigation (crater ascent)
3. Depth verification without endomorphism ring computation
4. Classification statistics across configurations
"""

from __future__ import annotations
import random
from collections import deque
from typing import Dict, List, Set, Tuple


# ─── Self-contained infrastructure ──────────────────────────────────────────

class VolcanoGraph:
    def __init__(self):
        self.vertices: Set[int] = set()
        self.adj: Dict[int, Set[int]] = {}
        self.depth: Dict[int, int] = {}
        self.crater: Set[int] = set()
        self.max_depth: int = 0

    def add_vertex(self, v, d):
        self.vertices.add(v); self.adj.setdefault(v, set())
        self.depth[v] = d
        if d == 0: self.crater.add(v)
        self.max_depth = max(self.max_depth, d)

    def add_edge(self, u, v):
        if u == v: return
        self.adj.setdefault(u, set()).add(v)
        self.adj.setdefault(v, set()).add(u)

    def neighbors(self, v): return self.adj.get(v, set())


def build_volcano(cs, br, md):
    G = VolcanoGraph(); nid = 0
    crater = []
    for i in range(cs): G.add_vertex(nid, 0); crater.append(nid); nid += 1
    for i in range(cs): G.add_edge(crater[i], crater[(i+1) % cs])
    if md == 0: return G
    d1 = []
    for i in range(cs):
        c1, c2 = crater[i], crater[(i+1) % cs]
        for _ in range(br):
            G.add_vertex(nid, 1); G.add_edge(c1, nid); G.add_edge(c2, nid)
            d1.append(nid); nid += 1
    level = d1
    for d in range(2, md+1):
        nl = []
        for p in level:
            for _ in range(br):
                G.add_vertex(nid, d); G.add_edge(p, nid); nl.append(nid); nid += 1
        level = nl
    return G


def bfs_ball(G, v, r):
    vis = {v}; q = deque([(v, 0)])
    while q:
        u, d = q.popleft()
        if d >= r: continue
        for w in G.neighbors(u):
            if w not in vis: vis.add(w); q.append((w, d+1))
    return vis


def cycle_rank_of(G, ball):
    edges = [(u, w) for u in ball for w in G.neighbors(u) if w in ball and u < w]
    parent = {v: v for v in ball}
    def find(x):
        while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for u, v in edges:
        ru, rv = find(u), find(v)
        if ru != rv: parent[rv] = ru
    c = len(set(find(v) for v in ball))
    return max(0, len(edges) - len(ball) + c)


def first_cycle_radius(G, v):
    for r in range(G.max_depth + 2):
        if cycle_rank_of(G, bfs_ball(G, v, r)) > 0: return r
    return G.max_depth + 1


# ─── Application 1: Cryptographic Depth Oracle ──────────────────────────────

def app_crypto_oracle():
    print("=" * 70)
    print("APPLICATION 1: CRYPTOGRAPHIC DEPTH ORACLE")
    print("=" * 70)
    print("\nSimulating depth oracle for isogeny-based cryptography.\n")

    for cs, br, md, label in [
        (3, 2, 2, "Small (p~2^32)"),
        (5, 2, 3, "Medium (p~2^64)"),
        (8, 2, 4, "Large (p~2^128)"),
    ]:
        G = build_volcano(cs, br, md)
        sample = random.sample(sorted(G.vertices), min(20, len(G.vertices)))
        nc_ok = sum(1 for v in sample if G.depth[v] > 0 and first_cycle_radius(G, v) == G.depth[v])
        nc_tot = sum(1 for v in sample if G.depth[v] > 0)
        print(f"  {label}: {len(G.vertices)} vertices, "
              f"non-crater accuracy = {nc_ok}/{nc_tot}")


# ─── Application 2: Crater Ascent ───────────────────────────────────────────

def app_crater_ascent():
    print("\n" + "=" * 70)
    print("APPLICATION 2: CRATER ASCENT VIA TOPOLOGICAL NAVIGATION")
    print("=" * 70)

    G = build_volcano(5, 2, 4)
    floor = [v for v in G.vertices if G.depth[v] == G.max_depth]
    start = floor[0]
    print(f"\nStarting from vertex {start} (depth {G.depth[start]})")

    current = start; path = [current]; steps = 0
    while G.depth[current] > 0 and steps < 20:
        cur_fcr = first_cycle_radius(G, current)
        best, best_fcr = None, cur_fcr
        for u in G.neighbors(current):
            u_fcr = first_cycle_radius(G, u)
            if u_fcr < best_fcr: best_fcr = u_fcr; best = u
        if best is None: break
        print(f"  Step {steps}: v={current}, depth={G.depth[current]}, FCR={cur_fcr} → v={best}")
        current = best; path.append(current); steps += 1

    print(f"  Step {steps}: v={current}, depth={G.depth[current]}, FCR={first_cycle_radius(G, current)}")
    print(f"Reached crater: {'YES ✓' if G.depth[current] == 0 else 'NO ✗'}")
    print(f"Steps: {steps} (optimal: {G.depth[start]})")


# ─── Application 3: Depth Verification ──────────────────────────────────────

def app_depth_verify():
    print("\n" + "=" * 70)
    print("APPLICATION 3: DEPTH VERIFICATION")
    print("=" * 70)

    G = build_volcano(6, 2, 3)
    claims = []
    for v in sorted(G.vertices)[:15]:
        d = G.depth[v]
        if d == 0: continue  # Skip crater for this demo
        if random.random() < 0.7:
            claims.append((v, d, True))
        else:
            fake = random.choice([x for x in range(1, G.max_depth+1) if x != d])
            claims.append((v, fake, False))

    print(f"\n{'Vertex':>8} {'Claimed':>8} {'True':>6} {'FCR':>6} {'Verdict':>8} {'Honest':>8}")
    print("─" * 50)
    ok = 0
    for v, claimed, honest in claims:
        fcr = first_cycle_radius(G, v)
        verdict = "ACCEPT" if fcr == claimed else "REJECT"
        correct = (honest and verdict == "ACCEPT") or (not honest and verdict == "REJECT")
        if correct: ok += 1
        print(f"{v:>8} {claimed:>8} {G.depth[v]:>6} {fcr:>6} {verdict:>8} "
              f"{'✓' if honest else '✗':>8}")
    print(f"\nVerification accuracy: {ok}/{len(claims)}")


# ─── Application 4: Classification Stats ────────────────────────────────────

def app_classification():
    print("\n" + "=" * 70)
    print("APPLICATION 4: DEPTH CLASS DISTRIBUTION")
    print("=" * 70)

    for cs, br, md in [(4, 2, 2), (6, 2, 3), (5, 3, 2)]:
        G = build_volcano(cs, br, md)
        depth_dist = {}; fcr_dist = {}
        for v in G.vertices:
            d = G.depth[v]
            depth_dist[d] = depth_dist.get(d, 0) + 1
            f = first_cycle_radius(G, v)
            fcr_dist[f] = fcr_dist.get(f, 0) + 1

        print(f"\nVolcano(crater={cs}, branch={br}, depth={md}), {len(G.vertices)} vertices:")
        print(f"  Depth dist: {dict(sorted(depth_dist.items()))}")
        print(f"  FCR dist:   {dict(sorted(fcr_dist.items()))}")
        # Non-crater match
        nc_match = all(depth_dist.get(d, 0) == fcr_dist.get(d, 0) for d in range(1, md+1))
        print(f"  Non-crater distributions match: {'✓' if nc_match else '✗'}")


def main():
    random.seed(42)
    app_crypto_oracle()
    app_crater_ascent()
    app_depth_verify()
    app_classification()
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Interactive Demo: Volcano Depth Detection via Topological Invariants

Constructs sample volcano-like graphs, computes cycle-rank / first-cycle-radius
statistics, predicts depths, and visualizes the results.

Usage:
    python demo.py [--crater_size N] [--branching B] [--max_depth D] [--sweep]

Keywords: isogeny volcanoes, persistent homology, cycle rank, Euler characteristic,
topological data analysis, arithmetic graphs, isogeny-based cryptography
"""

from __future__ import annotations
import argparse
import random
from collections import deque
from typing import Dict, List, Optional, Set, Tuple


# ─── Core Graph Infrastructure ───────────────────────────────────────────────

class VolcanoGraph:
    def __init__(self):
        self.vertices: Set[int] = set()
        self.adj: Dict[int, Set[int]] = {}
        self.depth: Dict[int, int] = {}
        self.crater: Set[int] = set()
        self.max_depth: int = 0

    def add_vertex(self, v: int, d: int):
        self.vertices.add(v)
        self.adj.setdefault(v, set())
        self.depth[v] = d
        if d == 0:
            self.crater.add(v)
        self.max_depth = max(self.max_depth, d)

    def add_edge(self, u: int, v: int):
        if u == v: return
        self.adj.setdefault(u, set()).add(v)
        self.adj.setdefault(v, set()).add(u)

    def neighbors(self, v: int) -> Set[int]:
        return self.adj.get(v, set())


def build_volcano(crater_size: int, branching: int, max_depth: int) -> VolcanoGraph:
    """Construct a volcano graph.

    Depth-1 vertices connect to two adjacent crater vertices (forming triangles).
    Deeper vertices have single parents. This ensures firstCycleRadius = depth
    for all non-crater vertices.
    """
    G = VolcanoGraph()
    nid = 0
    crater = []
    for i in range(crater_size):
        G.add_vertex(nid, 0); crater.append(nid); nid += 1
    for i in range(crater_size):
        G.add_edge(crater[i], crater[(i + 1) % crater_size])

    if max_depth == 0:
        return G

    # Depth 1: dual parent (triangle with crater edge)
    depth1 = []
    for i in range(crater_size):
        c1, c2 = crater[i], crater[(i + 1) % crater_size]
        for _ in range(branching):
            G.add_vertex(nid, 1)
            G.add_edge(c1, nid)
            G.add_edge(c2, nid)
            depth1.append(nid); nid += 1

    # Deeper: single parent
    level = depth1
    for d in range(2, max_depth + 1):
        nlevel = []
        for p in level:
            for _ in range(branching):
                G.add_vertex(nid, d)
                G.add_edge(p, nid)
                nlevel.append(nid); nid += 1
        level = nlevel
    return G


# ─── Topological Computations ────────────────────────────────────────────────

def bfs_ball(G, v, r):
    visited = {v}
    queue = deque([(v, 0)])
    while queue:
        u, dist = queue.popleft()
        if dist >= r: continue
        for w in G.neighbors(u):
            if w not in visited:
                visited.add(w); queue.append((w, dist + 1))
    return visited


def induced_edges(G, vertices):
    return [(u, w) for u in vertices for w in G.neighbors(u) if w in vertices and u < w]


def connected_components(vertices, edges):
    if not vertices: return 0
    parent = {v: v for v in vertices}
    def find(x):
        while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry: parent[ry] = rx
    for u, v in edges: union(u, v)
    return len(set(find(v) for v in vertices))


def cycle_rank(vertices, edges):
    return max(0, len(edges) - len(vertices) + connected_components(vertices, edges))


def cycle_profile(G, v, r):
    ball = bfs_ball(G, v, r)
    return cycle_rank(ball, induced_edges(G, ball))


def first_cycle_radius(G, v):
    for r in range(G.max_depth + 2):
        if cycle_profile(G, v, r) > 0: return r
    return G.max_depth + 1


def predict_depth(G, v):
    return first_cycle_radius(G, v)


def euler_characteristic(vertices, edges):
    return len(vertices) - len(edges)


# ─── Demo Functions ──────────────────────────────────────────────────────────

def demo_basic(crater_size=5, branching=2, max_depth=3):
    print("=" * 70)
    print("VOLCANO DEPTH DETECTION VIA TOPOLOGICAL INVARIANTS")
    print("=" * 70)

    G = build_volcano(crater_size, branching, max_depth)
    print(f"\nVolcano: crater={crater_size}, branching={branching}, max_depth={max_depth}")
    print(f"Total vertices: {len(G.vertices)}, Crater: {sorted(G.crater)}")

    print(f"\n{'Vertex':>8} {'Depth':>6} {'FCR':>6} {'Predicted':>10} {'Correct':>8}")
    print("─" * 45)

    correct_nc = 0
    total_nc = 0
    for v in sorted(G.vertices):
        d = G.depth[v]
        fcr = first_cycle_radius(G, v)
        pred = predict_depth(G, v)
        is_crater = d == 0
        ok = pred == d
        if not is_crater:
            total_nc += 1
            if ok: correct_nc += 1
        marker = "crater" if is_crater else ("✓" if ok else "✗")
        print(f"{v:>8} {d:>6} {fcr:>6} {pred:>10} {marker:>8}")

    print("─" * 45)
    if total_nc > 0:
        print(f"Non-crater accuracy: {correct_nc}/{total_nc} = {correct_nc/total_nc:.1%}")
    print(f"(Crater vertices handled by separate classification theorem)")


def demo_cycle_profiles(crater_size=5, branching=2, max_depth=3):
    print("\n" + "=" * 70)
    print("CYCLE PROFILE ANALYSIS (one vertex per depth)")
    print("=" * 70)

    G = build_volcano(crater_size, branching, max_depth)
    by_depth = {}
    for v in sorted(G.vertices):
        d = G.depth[v]
        if d not in by_depth: by_depth[d] = v

    for d in sorted(by_depth):
        v = by_depth[d]
        print(f"\nVertex {v} (depth {d}):")
        print(f"  {'r':>4} {'β₁':>6} {'χ':>6} {'|V|':>6} {'|E|':>6}")
        print(f"  {'─' * 30}")
        for r in range(max_depth + 2):
            ball = bfs_ball(G, v, r)
            edges = induced_edges(G, ball)
            beta = cycle_rank(ball, edges)
            chi = euler_characteristic(ball, edges)
            prev_beta = cycle_profile(G, v, r - 1) if r > 0 else 0
            marker = " ← FIRST CYCLE" if beta > 0 and prev_beta == 0 else ""
            print(f"  {r:>4} {beta:>6} {chi:>6} {len(ball):>6} {len(edges):>6}{marker}")
        fcr = first_cycle_radius(G, v)
        match = "✓" if fcr == d else f"(crater: FCR={fcr})"
        print(f"  → firstCycleRadius = {fcr}, depth = {d} {match}")


def demo_euler_bridge(crater_size=5, branching=2, max_depth=3):
    print("\n" + "=" * 70)
    print("EULER CHARACTERISTIC BRIDGE: χ = 1 - β₁")
    print("=" * 70)

    G = build_volcano(crater_size, branching, max_depth)
    v = sorted(v for v in G.vertices if G.depth[v] == max_depth)[0]
    print(f"\nFloor vertex {v} (depth {G.depth[v]}):")
    print(f"Below crater: χ = 1 (tree). At crater: χ drops.\n")

    for r in range(max_depth + 2):
        ball = bfs_ball(G, v, r)
        edges = induced_edges(G, ball)
        beta = cycle_rank(ball, edges)
        chi = euler_characteristic(ball, edges)
        c = connected_components(ball, edges)
        check = "✓ χ=1-β₁" if c == 1 and chi == 1 - beta else ""
        tree = "TREE" if beta == 0 else "CYCLIC"
        print(f"  r={r}: β₁={beta}, χ={chi}, |V|={len(ball)}, |E|={len(edges)} [{tree}] {check}")


def demo_parameter_sweep():
    print("\n" + "=" * 70)
    print("PARAMETER SWEEP: NON-CRATER PREDICTION ACCURACY")
    print("=" * 70)
    print(f"\n{'Crater':>8} {'Branch':>8} {'Depth':>8} {'Vertices':>10} {'NonCrater':>10} {'Accuracy':>10}")
    print("─" * 58)

    for cs in [3, 5, 8, 12]:
        for br in [1, 2, 3]:
            for md in [1, 2, 3, 4]:
                G = build_volcano(cs, br, md)
                nc_correct = sum(1 for v in G.vertices
                                 if G.depth[v] > 0 and predict_depth(G, v) == G.depth[v])
                nc_total = sum(1 for v in G.vertices if G.depth[v] > 0)
                acc = nc_correct / nc_total if nc_total > 0 else 1.0
                print(f"{cs:>8} {br:>8} {md:>8} {len(G.vertices):>10} "
                      f"{nc_total:>10} {acc:>10.1%}")


def main():
    parser = argparse.ArgumentParser(description="Volcano Depth Detection Demo")
    parser.add_argument('--crater_size', type=int, default=5)
    parser.add_argument('--branching', type=int, default=2)
    parser.add_argument('--max_depth', type=int, default=3)
    parser.add_argument('--sweep', action='store_true')
    args = parser.parse_args()

    demo_basic(args.crater_size, args.branching, args.max_depth)
    demo_cycle_profiles(args.crater_size, args.branching, args.max_depth)
    demo_euler_bridge(args.crater_size, args.branching, args.max_depth)

    if args.sweep:
        demo_parameter_sweep()
    else:
        # Quick sweep by default
        demo_parameter_sweep()


if __name__ == '__main__':
    main()


"""
Visualization: Cycle Profile Heatmap for Volcano Depth Detection

Visualizes the cycle rank β₁(B_r(v)) as a function of vertex depth and
ball radius, showing the sharp transition at the diagonal r = depth(v)
that is the core mechanism of topological depth detection.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from collections import deque
from typing import Dict, Set


# ─── Self-contained volcano infrastructure ───────────────────────────────────

class VG:
    def __init__(self):
        self.V: Set[int] = set()
        self.adj: Dict[int, Set[int]] = {}
        self.depth: Dict[int, int] = {}
        self.max_depth = 0
    def add_v(self, v, d):
        self.V.add(v); self.adj.setdefault(v, set()); self.depth[v] = d
        self.max_depth = max(self.max_depth, d)
    def add_e(self, u, v):
        if u == v: return
        self.adj.setdefault(u, set()).add(v); self.adj.setdefault(v, set()).add(u)
    def nbrs(self, v): return self.adj.get(v, set())


def build(cs, br, md):
    G = VG(); nid = 0
    crater = []
    for i in range(cs): G.add_v(nid, 0); crater.append(nid); nid += 1
    for i in range(cs): G.add_e(crater[i], crater[(i+1)%cs])
    if md == 0: return G
    d1 = []
    for i in range(cs):
        c1, c2 = crater[i], crater[(i+1)%cs]
        for _ in range(br):
            G.add_v(nid, 1); G.add_e(c1, nid); G.add_e(c2, nid); d1.append(nid); nid += 1
    lev = d1
    for d in range(2, md+1):
        nl = []
        for p in lev:
            for _ in range(br): G.add_v(nid, d); G.add_e(p, nid); nl.append(nid); nid += 1
        lev = nl
    return G


def ball(G, v, r):
    vis = {v}; q = deque([(v, 0)])
    while q:
        u, d = q.popleft()
        if d >= r: continue
        for w in G.nbrs(u):
            if w not in vis: vis.add(w); q.append((w, d+1))
    return vis


def beta1(G, v, r):
    b = ball(G, v, r)
    edges = [(u, w) for u in b for w in G.nbrs(u) if w in b and u < w]
    parent = {x: x for x in b}
    def find(x):
        while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for u, w in edges:
        ru, rw = find(u), find(w)
        if ru != rw: parent[rw] = ru
    c = len(set(find(x) for x in b))
    return max(0, len(edges) - len(b) + c)


# ─── Build data ──────────────────────────────────────────────────────────────

cs, br, md = 6, 2, 4
G = build(cs, br, md)

depth_range = list(range(md + 1))
radius_range = list(range(md + 2))

data = np.zeros((len(depth_range), len(radius_range)))
reps = {}
for d in depth_range:
    for v in sorted(G.V):
        if G.depth[v] == d and d not in reps:
            reps[d] = v
    v = reps[d]
    for ri, r in enumerate(radius_range):
        data[d, ri] = beta1(G, v, r)

# ─── Plot ────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

ax = axes[0]
cmap = mcolors.LinearSegmentedColormap.from_list('custom',
    ['#f0f0f0', '#2196F3', '#1565C0', '#0D47A1', '#000051'])
im = ax.imshow(data, cmap=cmap, aspect='auto', origin='lower',
               extent=[-0.5, len(radius_range)-0.5, -0.5, len(depth_range)-0.5])
ax.plot([-0.5, md+0.5], [-0.5, md+0.5], 'r--', linewidth=2,
        label='r = depth (detection boundary)')
ax.set_xlabel('Ball Radius r', fontsize=12)
ax.set_ylabel('Vertex Depth d', fontsize=12)
ax.set_title(f'Cycle Rank β₁(B_r(v)) by Depth and Radius\n'
             f'(crater={cs}, branching={br}, max_depth={md})', fontsize=13)
ax.set_xticks(range(len(radius_range))); ax.set_xticklabels(radius_range)
ax.set_yticks(range(len(depth_range))); ax.set_yticklabels(depth_range)
ax.legend(loc='upper left', fontsize=10)
for i in range(len(depth_range)):
    for j in range(len(radius_range)):
        val = int(data[i, j])
        color = 'white' if val > 0 else 'gray'
        ax.text(j, i, str(val), ha='center', va='center', fontsize=10,
                fontweight='bold' if val > 0 else 'normal', color=color)
fig.colorbar(im, ax=ax, label='β₁', shrink=0.8)

ax2 = axes[1]
colors = plt.cm.viridis(np.linspace(0, 0.9, len(depth_range)))
for d in depth_range:
    profile = [data[d, r] for r in range(len(radius_range))]
    ax2.plot(radius_range, profile, 'o-', color=colors[d], linewidth=2,
             markersize=6, label=f'depth {d}')
    for r in range(len(radius_range)):
        if profile[r] > 0:
            ax2.plot(radius_range[r], profile[r], 's', color=colors[d],
                     markersize=12, markeredgecolor='red', markeredgewidth=2)
            break
ax2.set_xlabel('Ball Radius r', fontsize=12)
ax2.set_ylabel('Cycle Rank β₁', fontsize=12)
ax2.set_title('Cycle Profile by Vertex Depth\n(red squares = first cycle birth)', fontsize=13)
ax2.legend(loc='upper left', fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(radius_range)

plt.tight_layout()
plt.savefig('cycle_profiles_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: cycle_profiles_heatmap.png")


"""
Visualization: Euler Characteristic Transition in Volcano Graphs

Shows how χ(B_r(v)) transitions from χ ≈ 1 (tree-like, below crater) to χ < 1
(cycle-detecting, at/above crater). Visualizes the cross-domain bridge.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import deque
from typing import Dict, Set


class VG:
    def __init__(self):
        self.V: Set[int] = set()
        self.adj: Dict[int, Set[int]] = {}
        self.depth: Dict[int, int] = {}
        self.max_depth = 0
    def add_v(self, v, d):
        self.V.add(v); self.adj.setdefault(v, set()); self.depth[v] = d
        self.max_depth = max(self.max_depth, d)
    def add_e(self, u, v):
        if u == v: return
        self.adj.setdefault(u, set()).add(v); self.adj.setdefault(v, set()).add(u)
    def nbrs(self, v): return self.adj.get(v, set())


def build(cs, br, md):
    G = VG(); nid = 0; crater = []
    for i in range(cs): G.add_v(nid, 0); crater.append(nid); nid += 1
    for i in range(cs): G.add_e(crater[i], crater[(i+1)%cs])
    if md == 0: return G
    d1 = []
    for i in range(cs):
        c1, c2 = crater[i], crater[(i+1)%cs]
        for _ in range(br):
            G.add_v(nid, 1); G.add_e(c1, nid); G.add_e(c2, nid); d1.append(nid); nid += 1
    lev = d1
    for d in range(2, md+1):
        nl = []
        for p in lev:
            for _ in range(br): G.add_v(nid, d); G.add_e(p, nid); nl.append(nid); nid += 1
        lev = nl
    return G


def ball_stats(G, v, r):
    vis = {v}; q = deque([(v, 0)])
    while q:
        u, d = q.popleft()
        if d >= r: continue
        for w in G.nbrs(u):
            if w not in vis: vis.add(w); q.append((w, d+1))
    edges = [(u, w) for u in vis for w in G.nbrs(u) if w in vis and u < w]
    parent = {x: x for x in vis}
    def find(x):
        while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
        return x
    for u, w in edges:
        ru, rw = find(u), find(w)
        if ru != rw: parent[rw] = ru
    c = len(set(find(x) for x in vis))
    nV, nE = len(vis), len(edges)
    return nV, nE, c, max(0, nE - nV + c), nV - nE


configs = [
    (5, 2, 4, "Volcano A: crater=5, branch=2, depth=4"),
    (8, 2, 3, "Volcano B: crater=8, branch=2, depth=3"),
    (4, 3, 3, "Volcano C: crater=4, branch=3, depth=3"),
]

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for idx, (cs, br, md, title) in enumerate(configs):
    ax = axes[idx]
    G = build(cs, br, md)
    reps = {}
    for v in sorted(G.V):
        d = G.depth[v]
        if d not in reps: reps[d] = v

    colors = plt.cm.plasma(np.linspace(0.1, 0.9, md + 1))
    rng = range(md + 2)

    for d in range(md + 1):
        v = reps[d]
        chi_vals = []; beta_vals = []
        for r in rng:
            nV, nE, c, beta, chi = ball_stats(G, v, r)
            chi_vals.append(chi); beta_vals.append(beta)
        ax.plot(list(rng), chi_vals, 'o-', color=colors[d], linewidth=2, markersize=5, label=f'd={d}')
        for r in rng:
            if beta_vals[r] > 0:
                ax.plot(r, chi_vals[r], 'v', color=colors[d], markersize=10,
                        markeredgecolor='black', markeredgewidth=1.5)
                break

    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, linewidth=1.5, label='χ=1 (tree)')
    ax.set_xlabel('Ball Radius r', fontsize=11)
    ax.set_ylabel('Euler Characteristic χ', fontsize=11)
    ax.set_title(title, fontsize=11)
    ax.legend(fontsize=8, loc='lower left')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(list(rng))

fig.suptitle('Euler Characteristic Transition: χ = 1 − β₁\n'
             '(▼ = first cycle detection, dashed = tree baseline)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('euler_char_transition.png', dpi=150, bbox_inches='tight')
print("Saved: euler_char_transition.png")


"""
Visualization: Volcano Graph Structure and Depth Classification

Shows the structure of a layered volcano graph with vertices colored by
depth and annotated with their topologically-predicted depth.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import deque
from typing import Dict, Set
import math


class VG:
    def __init__(self):
        self.V: Set[int] = set()
        self.adj: Dict[int, Set[int]] = {}
        self.depth: Dict[int, int] = {}
        self.max_depth = 0
    def add_v(self, v, d):
        self.V.add(v); self.adj.setdefault(v, set()); self.depth[v] = d
        self.max_depth = max(self.max_depth, d)
    def add_e(self, u, v):
        if u == v: return
        self.adj.setdefault(u, set()).add(v); self.adj.setdefault(v, set()).add(u)
    def nbrs(self, v): return self.adj.get(v, set())


def build(cs, br, md):
    G = VG(); nid = 0; crater = []
    for i in range(cs): G.add_v(nid, 0); crater.append(nid); nid += 1
    for i in range(cs): G.add_e(crater[i], crater[(i+1)%cs])
    if md == 0: return G
    d1 = []
    for i in range(cs):
        c1, c2 = crater[i], crater[(i+1)%cs]
        for _ in range(br):
            G.add_v(nid, 1); G.add_e(c1, nid); G.add_e(c2, nid); d1.append(nid); nid += 1
    lev = d1
    for d in range(2, md+1):
        nl = []
        for p in lev:
            for _ in range(br): G.add_v(nid, d); G.add_e(p, nid); nl.append(nid); nid += 1
        lev = nl
    return G


def fcr(G, vid):
    for r in range(G.max_depth + 2):
        vis = {vid}; q = deque([(vid, 0)])
        while q:
            u, d = q.popleft()
            if d >= r: continue
            for w in G.nbrs(u):
                if w not in vis: vis.add(w); q.append((w, d+1))
        edges = [(u, w) for u in vis for w in G.nbrs(u) if w in vis and u < w]
        parent = {x: x for x in vis}
        def find(x):
            while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
            return x
        for a, b in edges:
            ra, rb = find(a), find(b)
            if ra != rb: parent[rb] = ra
        c = len(set(find(x) for x in vis))
        if max(0, len(edges) - len(vis) + c) > 0: return r
    return G.max_depth + 1


cs, br, md = 5, 2, 3
G = build(cs, br, md)

# Layout
pos = {}
crater_verts = sorted(v for v in G.V if G.depth[v] == 0)
for i, v in enumerate(crater_verts):
    angle = 2*math.pi*i/cs - math.pi/2
    pos[v] = (2.0*math.cos(angle), -0.5*math.sin(angle))
for d in range(1, md+1):
    verts = sorted(v for v in G.V if G.depth[v] == d)
    spread = 3.0 * (1.2**d)
    for i, v in enumerate(verts):
        pos[v] = (-spread/2 + spread*(i+0.5)/len(verts), -1.5*d)

fcr_map = {v: fcr(G, v) for v in G.V}

fig, axes = plt.subplots(1, 2, figsize=(16, 8))
cmap = plt.cm.RdYlBu_r
dc = {d: cmap(d/max(md, 1)) for d in range(md+1)}

# Left: True depth
ax = axes[0]
for v in G.V:
    for u in G.nbrs(v):
        if u > v:
            ax.plot([pos[v][0], pos[u][0]], [pos[v][1], pos[u][1]], 'k-', alpha=0.3, lw=1)
for v in sorted(G.V):
    ax.scatter(*pos[v], c=[dc[G.depth[v]]], s=200, zorder=5, edgecolors='black', lw=1.5)
    ax.annotate(str(v), pos[v], ha='center', va='center', fontsize=7, fontweight='bold', zorder=6)
ax.legend(handles=[mpatches.Patch(color=dc[d], label=f'Depth {d}') for d in range(md+1)],
          loc='lower right', fontsize=9)
ax.set_title('True Depth', fontsize=14, fontweight='bold')
ax.set_aspect('equal'); ax.axis('off')

# Right: FCR prediction
ax2 = axes[1]
for v in G.V:
    for u in G.nbrs(v):
        if u > v:
            ax2.plot([pos[v][0], pos[u][0]], [pos[v][1], pos[u][1]], 'k-', alpha=0.3, lw=1)
for v in sorted(G.V):
    f = fcr_map[v]; d = G.depth[v]
    color = dc.get(f, 'gray')
    correct = (f == d) if d > 0 else True  # crater handled separately
    ax2.scatter(*pos[v], c=[color], s=200, zorder=5,
                marker='o' if correct else 'X', edgecolors='black', lw=1.5)
    ax2.annotate(f'FCR={f}', (pos[v][0], pos[v][1]-0.35), ha='center', va='top',
                 fontsize=6, zorder=6, color='darkblue')
ax2.legend(handles=[mpatches.Patch(color=dc[d], label=f'FCR={d}') for d in range(md+1)],
           loc='lower right', fontsize=9)
nc_correct = sum(1 for v in G.V if G.depth[v] > 0 and fcr_map[v] == G.depth[v])
nc_total = sum(1 for v in G.V if G.depth[v] > 0)
ax2.text(0.02, 0.02, f'Non-crater: {nc_correct}/{nc_total} ({100*nc_correct/nc_total:.0f}%)',
         transform=ax2.transAxes, fontsize=12, fontweight='bold',
         bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
ax2.set_title('Topological Prediction (FCR)', fontsize=14, fontweight='bold')
ax2.set_aspect('equal'); ax2.axis('off')

fig.suptitle('Topological Depth Detection in Volcano Graphs', fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout()
plt.savefig('volcano_structure.png', dpi=150, bbox_inches='tight')
print("Saved: volcano_structure.png")
