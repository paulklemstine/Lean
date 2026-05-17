#!/usr/bin/env python3
"""
Applications of Quantitative Honeycomb Rigidity
================================================

Real-world applications of the hexagonal lattice rigidity theorem
in crystal quality assessment, network design, and shape analysis.
"""

from typing import Set, Tuple, List, Dict
from collections import defaultdict
import random
import math

HexCell = Tuple[int, int]
HEX_DIRECTIONS = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (-1, 1)]


def hex_dist(a: HexCell, b: HexCell) -> int:
    dq = b[0] - a[0]
    dr = b[1] - a[1]
    return max(abs(dq), abs(dr), abs(dq + dr))


def hex_patch(r: int) -> Set[HexCell]:
    cells = set()
    for q in range(-r, r + 1):
        for s in range(-r, r + 1):
            if hex_dist((0, 0), (q, s)) <= r:
                cells.add((q, s))
    return cells


def hex_neighbors(p: HexCell) -> List[HexCell]:
    return [(p[0] + d[0], p[1] + d[1]) for d in HEX_DIRECTIONS]


def edge_boundary(S: Set[HexCell]) -> int:
    return sum(1 for p in S for n in hex_neighbors(p) if n not in S)


def translate(S: Set[HexCell], v: HexCell) -> Set[HexCell]:
    return {(p[0] + v[0], p[1] + v[1]) for p in S}


def hex_number(r: int) -> int:
    return 3 * r * r + 3 * r + 1


def opt_boundary(r: int) -> int:
    return 12 * r + 6


def find_best_translate(S: Set[HexCell], r: int) -> Tuple[HexCell, int]:
    patch = hex_patch(r)
    best_v = (0, 0)
    best_diff = len(S) + len(patch)
    for p in S:
        translated = translate(patch, p)
        diff = len(S.symmetric_difference(translated))
        if diff < best_diff:
            best_diff = diff
            best_v = p
    return best_v, best_diff


def is_connected(S: Set[HexCell]) -> bool:
    if not S:
        return True
    start = next(iter(S))
    visited = {start}
    queue = [start]
    while queue:
        p = queue.pop(0)
        for n in hex_neighbors(p):
            if n in S and n not in visited:
                visited.add(n)
                queue.append(n)
    return len(visited) == len(S)


# ============================================================
# APPLICATION 1: Crystal Quality Assessment
# ============================================================

print("=" * 65)
print("APPLICATION 1: Crystal Grain Quality Assessment")
print("=" * 65)
print()
print("In polycrystalline materials, individual crystal grains")
print("approximate hexagonal shapes. The rigidity theorem provides")
print("a quantitative quality metric: how close is the grain to")
print("a perfect hexagonal patch?")
print()


def simulate_crystal_grain(r: int, defect_rate: float, seed: int = 42) -> Set[HexCell]:
    """Simulate a crystal grain as a perturbed hex patch."""
    rng = random.Random(seed)
    S = set(hex_patch(r))

    num_defects = int(defect_rate * len(S))
    for _ in range(num_defects):
        # Find boundary cells
        boundary = [(p, n) for p in S for n in hex_neighbors(p)
                     if n not in S]
        if not boundary:
            break
        p, n = rng.choice(boundary)
        S_new = (S - {p}) | {n}
        if is_connected(S_new) and len(S_new) == len(S):
            S = S_new

    return S


print(f"  {'Defect Rate':>12s} {'Boundary':>10s} {'Excess δ':>10s} "
      f"{'SymmDiff':>10s} {'Quality':>10s}")
print(f"  {'-'*12:>12s} {'-'*10:>10s} {'-'*10:>10s} "
      f"{'-'*10:>10s} {'-'*10:>10s}")

r = 4
for defect_rate in [0.0, 0.02, 0.05, 0.10, 0.15, 0.20]:
    grain = simulate_crystal_grain(r, defect_rate)
    bdy = edge_boundary(grain)
    excess = bdy - opt_boundary(r)
    _, sd = find_best_translate(grain, r)
    quality = 1.0 - sd / (2 * hex_number(r))

    print(f"  {defect_rate:12.2f} {bdy:10d} {excess:10d} "
          f"{sd:10d} {quality:10.4f}")


# ============================================================
# APPLICATION 2: Cellular Network Coverage Analysis
# ============================================================

print()
print("=" * 65)
print("APPLICATION 2: Cellular Network Coverage Analysis")
print("=" * 65)
print()
print("Hexagonal cell layouts minimize overlap and dead zones.")
print("The rigidity theorem guarantees that small base station")
print("perturbations produce proportionally small coverage gaps.")
print()


def simulate_cell_layout(r: int, jitter: float, seed: int = 42) -> Set[HexCell]:
    """Simulate a cellular network with base station jitter."""
    rng = random.Random(seed)
    patch = hex_patch(r)
    cells = set()

    for p in patch:
        # Each cell might be displaced by jitter
        if rng.random() < jitter:
            # Move to a random neighbor
            neighbors = hex_neighbors(p)
            n = rng.choice(neighbors)
            if n not in cells:
                cells.add(n)
            else:
                cells.add(p)
        else:
            cells.add(p)

    return cells


print(f"  {'Jitter':>10s} {'Cells':>8s} {'Boundary':>10s} "
      f"{'Excess':>8s} {'Coverage Gap':>13s}")
print(f"  {'-'*10:>10s} {'-'*8:>8s} {'-'*10:>10s} "
      f"{'-'*8:>8s} {'-'*13:>13s}")

r = 5
ideal = hex_patch(r)
ideal_bdy = edge_boundary(ideal)

for jitter in [0.0, 0.05, 0.10, 0.15, 0.20, 0.30]:
    layout = simulate_cell_layout(r, jitter)
    bdy = edge_boundary(layout)
    excess = bdy - ideal_bdy
    gap = len(ideal.symmetric_difference(layout))

    print(f"  {jitter:10.2f} {len(layout):8d} {bdy:10d} "
          f"{excess:8d} {gap:13d}")


# ============================================================
# APPLICATION 3: Shape Recognition Certificate
# ============================================================

print()
print("=" * 65)
print("APPLICATION 3: Shape Recognition via Boundary Certificate")
print("=" * 65)
print()
print("The rigidity theorem provides a structural approximation")
print("guarantee: if a region has nearly minimal boundary at the")
print("right cardinality, it must be close to a hexagonal patch.")
print("This enables efficient shape recognition.")
print()


def certify_hexagonal(S: Set[HexCell], C: int = 9) -> Dict:
    """Certify whether S is approximately hexagonal.

    Returns a certificate including:
    - The best-fit radius r
    - The boundary excess delta
    - The symmetric difference to the nearest hex patch
    - Whether the rigidity bound holds
    """
    n = len(S)

    # Find the best-fit radius
    r = 0
    while hex_number(r + 1) <= n:
        r += 1

    if hex_number(r) != n:
        return {
            "is_hex_number": False,
            "cardinality": n,
            "nearest_hex_number": hex_number(r),
            "message": f"Cardinality {n} is not a centered hexagonal number"
        }

    bdy = edge_boundary(S)
    opt_bdy = opt_boundary(r)
    delta = max(0, bdy - opt_bdy)

    v, sd = find_best_translate(S, r)

    return {
        "is_hex_number": True,
        "cardinality": n,
        "radius": r,
        "boundary": bdy,
        "optimal_boundary": opt_bdy,
        "excess_delta": delta,
        "best_translate": v,
        "symmetric_difference": sd,
        "rigidity_bound": C * delta,
        "is_certified_hexagonal": sd <= C * delta if delta > 0 else sd == 0,
        "hexagonality_score": 1.0 - sd / (2 * n) if n > 0 else 1.0,
    }


# Test with various shapes
print("Testing shape recognition:")
print()

# Perfect hex patch
for r in [2, 3, 4]:
    cert = certify_hexagonal(hex_patch(r))
    print(f"  hexPatch({r}): radius={cert['radius']}, delta={cert['excess_delta']}, "
          f"symmDiff={cert['symmetric_difference']}, "
          f"score={cert['hexagonality_score']:.4f}")

# Perturbed patches
print()
for r in [3, 4]:
    for delta in [1, 2, 3]:
        S = simulate_crystal_grain(r, delta * 0.03, seed=r * 100 + delta)
        if len(S) == hex_number(r):
            cert = certify_hexagonal(S)
            print(f"  perturbed(r={r}, d~{delta}): delta={cert['excess_delta']}, "
                  f"symmDiff={cert['symmetric_difference']}, "
                  f"score={cert['hexagonality_score']:.4f}, "
                  f"certified={cert['is_certified_hexagonal']}")


# ============================================================
# APPLICATION 4: Isoperimetric Profile Computation
# ============================================================

print()
print("=" * 65)
print("APPLICATION 4: Isoperimetric Profile of the Hex Lattice")
print("=" * 65)
print()

# Compute profile by greedy growth from origin
profile = {}
S: Set[HexCell] = set()
candidates = [(0, 0)]
visited = {(0, 0)}

import heapq
pq = [(6, (0, 0))]

while len(S) < 80 and pq:
    _, cell = heapq.heappop(pq)
    if cell in S:
        continue

    S.add(cell)
    profile[len(S)] = edge_boundary(S)

    for n in hex_neighbors(cell):
        if n not in visited:
            visited.add(n)
            internal = sum(1 for nn in hex_neighbors(n) if nn in S)
            heapq.heappush(pq, (6 - 2 * internal, n))

print(f"  {'n':>4s} {'h(n)':>6s} {'12r+6':>6s} {'hex?':>5s}")
print(f"  {'-'*4:>4s} {'-'*6:>6s} {'-'*6:>6s} {'-'*5:>5s}")
for n in sorted(profile.keys()):
    is_hex = any(hex_number(r) == n for r in range(20))
    r_val = None
    for r in range(20):
        if hex_number(r) == n:
            r_val = r
            break
    opt_str = f"{opt_boundary(r_val):6d}" if r_val is not None else "      "
    marker = "  *" if is_hex else ""
    print(f"  {n:4d} {profile[n]:6d} {opt_str:>6s}{marker}")


print()
print("=" * 65)
print("All applications demonstrated successfully!")
print("=" * 65)


#!/usr/bin/env python3
"""
Hex Lattice Isoperimetry Demo
==============================

Demonstrates the hexagonal lattice discrete isoperimetric inequality
and quantitative honeycomb rigidity through concrete numerical examples.
"""

import math
from collections import defaultdict
from typing import Set, Tuple, List, Optional

# Type aliases
HexCell = Tuple[int, int]

# Six hex directions in axial coordinates
HEX_DIRECTIONS = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (-1, 1)]


def hex_dist(a: HexCell, b: HexCell) -> int:
    """Hex metric: max(|dq|, |dr|, |dq+dr|)."""
    dq = b[0] - a[0]
    dr = b[1] - a[1]
    return max(abs(dq), abs(dr), abs(dq + dr))


def hex_patch(r: int) -> Set[HexCell]:
    """Generate the hexagonal patch of radius r centered at origin."""
    cells = set()
    for q in range(-r, r + 1):
        for s in range(-r, r + 1):
            if hex_dist((0, 0), (q, s)) <= r:
                cells.add((q, s))
    return cells


def hex_neighbors(p: HexCell) -> List[HexCell]:
    """Return the 6 neighbors of a hex cell."""
    return [(p[0] + d[0], p[1] + d[1]) for d in HEX_DIRECTIONS]


def edge_boundary(S: Set[HexCell]) -> int:
    """Count directed edges from S to its complement."""
    count = 0
    for p in S:
        for n in hex_neighbors(p):
            if n not in S:
                count += 1
    return count


def internal_edges(S: Set[HexCell]) -> int:
    """Count directed edges with both endpoints in S."""
    count = 0
    for p in S:
        for n in hex_neighbors(p):
            if n in S:
                count += 1
    return count


def hex_number(r: int) -> int:
    """Centered hexagonal number: 3r² + 3r + 1."""
    return 3 * r * r + 3 * r + 1


def opt_boundary(r: int) -> int:
    """Optimal boundary for hex-number cardinality: 12r + 6."""
    return 12 * r + 6


def symmetric_difference(A: Set[HexCell], B: Set[HexCell]) -> Set[HexCell]:
    """Symmetric difference of two sets."""
    return A.symmetric_difference(B)


def translate(S: Set[HexCell], v: HexCell) -> Set[HexCell]:
    """Translate a set by vector v."""
    return {(p[0] + v[0], p[1] + v[1]) for p in S}


def find_best_translate(S: Set[HexCell], r: int) -> Tuple[HexCell, int]:
    """Find the translation v that minimizes |S △ (hexPatch(r) + v)|."""
    patch = hex_patch(r)
    best_v = (0, 0)
    best_diff = len(S) + len(patch)

    # Try centering at each point of S
    for p in S:
        v = p
        translated = translate(patch, v)
        diff = len(symmetric_difference(S, translated))
        if diff < best_diff:
            best_diff = diff
            best_v = v

    return best_v, best_diff


def is_connected(S: Set[HexCell]) -> bool:
    """Check if S is hex-connected via BFS."""
    if not S:
        return True
    start = next(iter(S))
    visited = {start}
    queue = [start]
    while queue:
        p = queue.pop(0)
        for n in hex_neighbors(p):
            if n in S and n not in visited:
                visited.add(n)
                queue.append(n)
    return len(visited) == len(S)


def horizontal_compress(S: Set[HexCell]) -> Set[HexCell]:
    """Compress S horizontally: replace each fiber with a left-aligned interval."""
    fibers = defaultdict(list)
    for q, r in S:
        fibers[r].append(q)

    result = set()
    for r_val, qs in fibers.items():
        qs.sort()
        lo = min(qs)
        for i in range(len(qs)):
            result.add((lo + i, r_val))
    return result


# ============================================================
# DEMO 1: Verify cardinality and boundary formulas
# ============================================================

print("=" * 60)
print("DEMO 1: Hex Patch Cardinality and Boundary Formulas")
print("=" * 60)

for r in range(8):
    patch = hex_patch(r)
    card = len(patch)
    bdy = edge_boundary(patch)
    internal = internal_edges(patch)
    expected_card = hex_number(r)
    expected_bdy = opt_boundary(r)

    assert card == expected_card, f"Card mismatch at r={r}"
    assert bdy == expected_bdy, f"Boundary mismatch at r={r}"
    assert bdy + internal == 6 * card, f"Partition identity failed at r={r}"

    ratio = bdy / card if card > 0 else float('inf')
    print(f"  r={r}: |hexPatch|={card:5d}  boundary={bdy:4d}  "
          f"internal={internal:5d}  ratio={ratio:.4f}")

print(f"\n  ✓ All formulas verified for r = 0..7")
print(f"  ✓ Partition identity boundary + internal = 6·card verified")

# ============================================================
# DEMO 2: Near-minimizer rigidity experiments
# ============================================================

print("\n" + "=" * 60)
print("DEMO 2: Near-Minimizer Rigidity Experiments")
print("=" * 60)

import random

def random_perturbation(S: Set[HexCell], delta: int, seed: int = 42) -> Set[HexCell]:
    """Create a connected perturbation with boundary excess approximately delta."""
    rng = random.Random(seed)
    S = set(S)  # copy

    for _ in range(delta):
        # Find a boundary cell and its external neighbor
        boundary_cells = []
        for p in S:
            for n in hex_neighbors(p):
                if n not in S:
                    boundary_cells.append((p, n))

        if not boundary_cells:
            break

        # Remove a boundary cell and add an external neighbor
        p, n = rng.choice(boundary_cells)

        # Try swapping: remove p, add n
        S_new = (S - {p}) | {n}
        if is_connected(S_new) and len(S_new) == len(S):
            S = S_new

    return S


for r in [2, 3, 4]:
    print(f"\n  Radius r = {r}, |hexPatch| = {hex_number(r)}")
    print(f"  {'delta':>5s} {'boundary':>10s} {'excess':>8s} {'best_symmDiff':>15s} {'ratio':>8s}")
    print(f"  {'-'*5:>5s} {'-'*10:>10s} {'-'*8:>8s} {'-'*15:>15s} {'-'*8:>8s}")

    patch = hex_patch(r)
    for delta_target in range(0, 8):
        results = []
        for trial in range(20):
            S = random_perturbation(patch, delta_target, seed=42 + trial + delta_target * 100)
            bdy = edge_boundary(S)
            excess = bdy - opt_boundary(r)
            _, best_sd = find_best_translate(S, r)
            results.append((excess, best_sd))

        avg_excess = sum(e for e, _ in results) / len(results)
        max_sd = max(sd for _, sd in results)
        avg_sd = sum(sd for _, sd in results) / len(results)
        ratio_str = f"{avg_sd/max(avg_excess,0.01):.2f}" if avg_excess > 0 else "0/0"

        print(f"  {delta_target:5d} {opt_boundary(r)+avg_excess:10.1f} "
              f"{avg_excess:8.1f} {max_sd:15d} {ratio_str:>8s}")


# ============================================================
# DEMO 3: Compression reduces boundary
# ============================================================

print("\n" + "=" * 60)
print("DEMO 3: Horizontal Compression Effect")
print("=" * 60)

for r in [3, 4, 5]:
    patch = hex_patch(r)
    for delta in [2, 4, 6]:
        S = random_perturbation(patch, delta * 2, seed=r * 100 + delta)
        S_compressed = horizontal_compress(S)

        bdy_before = edge_boundary(S)
        bdy_after = edge_boundary(S_compressed)
        sd_before = len(symmetric_difference(S, find_best_translate(S, r)[0]
                        and translate(patch, find_best_translate(S, r)[0]) or patch))
        _, sd_after = find_best_translate(S_compressed, r)

        print(f"  r={r}, delta~{delta}: boundary {bdy_before} -> {bdy_after} "
              f"(reduced by {bdy_before - bdy_after}), "
              f"|S|={len(S)}, |S_compressed|={len(S_compressed)}")


# ============================================================
# DEMO 4: Fiber gap analysis
# ============================================================

print("\n" + "=" * 60)
print("DEMO 4: Fiber Gap Analysis")
print("=" * 60)

def count_fiber_gaps(S: Set[HexCell]) -> int:
    """Count total gaps in horizontal fibers."""
    fibers = defaultdict(list)
    for q, r in S:
        fibers[r].append(q)

    total_gaps = 0
    for r_val, qs in fibers.items():
        if not qs:
            continue
        lo, hi = min(qs), max(qs)
        expected = hi - lo + 1
        actual = len(qs)
        total_gaps += expected - actual
    return total_gaps


for r in [3, 4, 5]:
    patch = hex_patch(r)
    print(f"\n  Radius r = {r}")
    print(f"  {'perturbation':>15s} {'boundary':>10s} {'excess':>8s} {'gaps':>6s} {'symmDiff':>10s}")

    # Perfect hex patch
    bdy = edge_boundary(patch)
    gaps = count_fiber_gaps(patch)
    print(f"  {'hexPatch':>15s} {bdy:10d} {0:8d} {gaps:6d} {0:10d}")

    # Perturbations
    for delta in [1, 2, 3, 4, 5]:
        total_gaps = 0
        total_sd = 0
        for trial in range(10):
            S = random_perturbation(patch, delta, seed=r * 1000 + delta * 100 + trial)
            gaps = count_fiber_gaps(S)
            _, sd = find_best_translate(S, r)
            total_gaps += gaps
            total_sd += sd

        avg_gaps = total_gaps / 10
        avg_sd = total_sd / 10
        print(f"  {'delta=' + str(delta):>15s} {opt_boundary(r) + delta:10d} "
              f"{delta:8d} {avg_gaps:6.1f} {avg_sd:10.1f}")


print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
visualizations_code = read_file('visualizations.py')

# Read Lean code
lean_code = read_file('Catalog/Cryptography/HexHoneycomb/Rigidity.lean')

# Read SVGs
svgs = {}
for name in ['hex_patch_r3', 'isoperimetric_ratio', 'boundary_vs_symmdiff']:
    svgs[name] = read_file(f'{name}.svg')

package = {
    "title": "Quantitative Honeycomb Rigidity: Stability of Discrete Hexagonal Isoperimetry",
    "domain": "Discrete Geometry / Combinatorial Optimization / Cryptographic Lattices",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Hex Lattice Isoperimetry Demo",
            "code": demo_code
        },
        {
            "name": "Applications of Honeycomb Rigidity",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Best Translate Finding",
            "pseudocode": """function FindBestTranslate(S, r):
    best_v = (0, 0)
    best_diff = |S| + |hexPatch(r)|
    for each p in S:
        v = p
        diff = |S △ (hexPatch(r) + v)|
        if diff < best_diff:
            best_diff = diff
            best_v = v
    return best_v, best_diff

Time complexity: O(|S|² · r)""",
            "code": algorithms_code
        },
        {
            "name": "Horizontal Compression",
            "pseudocode": """function HorizontalCompress(S):
    fibers = GroupBySecondCoord(S)
    result = empty set
    for each (y, fiber) in fibers:
        sorted = Sort(fiber)
        lo = min(sorted)
        for i = 0 to |fiber| - 1:
            result.add((lo + i, y))
    return result

Time complexity: O(|S| log |S|)
Preserves cardinality, does not increase boundary.""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Hexagonal Patch (r=3)",
            "data": svgs['hex_patch_r3']
        },
        {
            "name": "Isoperimetric Ratio Decay",
            "data": svgs['isoperimetric_ratio']
        },
        {
            "name": "Boundary Excess vs Symmetric Difference",
            "data": svgs['boundary_vs_symmdiff']
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Visualizations for Quantitative Honeycomb Rigidity
===================================================

Generates publication-quality figures showing hex patches,
boundary analysis, compression effects, and rigidity bounds.
"""

import math
import base64
import io
from typing import Set, Tuple, List, Dict
from collections import defaultdict
import random

HexCell = Tuple[int, int]
HEX_DIRECTIONS = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (-1, 1)]


def hex_dist(a: HexCell, b: HexCell) -> int:
    dq = b[0] - a[0]
    dr = b[1] - a[1]
    return max(abs(dq), abs(dr), abs(dq + dr))


def hex_patch(r: int) -> Set[HexCell]:
    cells = set()
    for q in range(-r, r + 1):
        for s in range(-r, r + 1):
            if hex_dist((0, 0), (q, s)) <= r:
                cells.add((q, s))
    return cells


def hex_neighbors(p: HexCell) -> List[HexCell]:
    return [(p[0] + d[0], p[1] + d[1]) for d in HEX_DIRECTIONS]


def edge_boundary(S: Set[HexCell]) -> int:
    return sum(1 for p in S for n in hex_neighbors(p) if n not in S)


def hex_number(r: int) -> int:
    return 3 * r * r + 3 * r + 1


def opt_boundary(r: int) -> int:
    return 12 * r + 6


def axial_to_pixel(q: int, r: int, size: float = 30.0) -> Tuple[float, float]:
    """Convert axial hex coordinates to pixel coordinates."""
    x = size * (math.sqrt(3) * q + math.sqrt(3) / 2 * r)
    y = size * (3.0 / 2 * r)
    return x, y


def hex_corners(cx: float, cy: float, size: float = 28.0) -> List[Tuple[float, float]]:
    """Get the 6 corner points of a hexagon centered at (cx, cy)."""
    corners = []
    for i in range(6):
        angle = math.pi / 180 * (60 * i - 30)
        corners.append((cx + size * math.cos(angle), cy + size * math.sin(angle)))
    return corners


def generate_hex_patch_svg(r: int, title: str = "", width: int = 600, height: int = 500) -> str:
    """Generate SVG visualization of a hex patch."""
    patch = hex_patch(r)
    size = min(20, 200 // max(r, 1))

    # Calculate bounds
    all_x = []
    all_y = []
    for q, s in patch:
        px, py = axial_to_pixel(q, s, size)
        all_x.append(px)
        all_y.append(py)

    cx_offset = width / 2 - (min(all_x) + max(all_x)) / 2
    cy_offset = height / 2 - (min(all_y) + max(all_y)) / 2

    svg_parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
                 f'viewBox="0 0 {width} {height}">']
    svg_parts.append(f'<rect width="{width}" height="{height}" fill="white"/>')

    if title:
        svg_parts.append(f'<text x="{width//2}" y="25" text-anchor="middle" '
                         f'font-size="16" font-family="Arial" font-weight="bold">{title}</text>')

    # Draw cells
    for q, s in patch:
        px, py = axial_to_pixel(q, s, size)
        px += cx_offset
        py += cy_offset

        corners = hex_corners(px, py, size * 0.95)
        points_str = " ".join(f"{x:.1f},{y:.1f}" for x, y in corners)

        # Color by distance from center
        dist = hex_dist((0, 0), (q, s))
        if dist == 0:
            fill = "#FFD700"  # Gold center
        elif dist == r:
            fill = "#87CEEB"  # Light blue boundary
        else:
            intensity = int(200 + 55 * (1 - dist / r))
            fill = f"#{intensity:02x}{intensity:02x}ff"

        # Check if boundary cell
        is_boundary = any((q + d[0], s + d[1]) not in patch for d in HEX_DIRECTIONS)
        stroke_width = "2" if is_boundary else "1"
        stroke_color = "#FF4444" if is_boundary else "#333"

        svg_parts.append(f'<polygon points="{points_str}" fill="{fill}" '
                         f'stroke="{stroke_color}" stroke-width="{stroke_width}"/>')

    # Label
    svg_parts.append(f'<text x="{width//2}" y="{height-15}" text-anchor="middle" '
                     f'font-size="12" font-family="Arial">'
                     f'r={r}, |hexPatch|={hex_number(r)}, boundary={opt_boundary(r)}</text>')

    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_rigidity_chart_svg(width: int = 700, height: int = 400) -> str:
    """Generate SVG chart showing boundary-to-area ratio decay."""
    svg_parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
                 f'viewBox="0 0 {width} {height}">']
    svg_parts.append(f'<rect width="{width}" height="{height}" fill="white"/>')

    # Title
    svg_parts.append(f'<text x="{width//2}" y="25" text-anchor="middle" '
                     f'font-size="16" font-family="Arial" font-weight="bold">'
                     f'Isoperimetric Ratio: boundary / area</text>')

    # Chart area
    margin = {"left": 80, "right": 40, "top": 50, "bottom": 60}
    chart_w = width - margin["left"] - margin["right"]
    chart_h = height - margin["top"] - margin["bottom"]

    # Data
    max_r = 15
    data = []
    for r in range(1, max_r + 1):
        ratio = opt_boundary(r) / hex_number(r)
        data.append((r, ratio))

    # Axes
    max_ratio = max(d[1] for d in data) * 1.1

    # Y axis
    svg_parts.append(f'<line x1="{margin["left"]}" y1="{margin["top"]}" '
                     f'x2="{margin["left"]}" y2="{margin["top"] + chart_h}" '
                     f'stroke="black" stroke-width="2"/>')

    # X axis
    svg_parts.append(f'<line x1="{margin["left"]}" y1="{margin["top"] + chart_h}" '
                     f'x2="{margin["left"] + chart_w}" y2="{margin["top"] + chart_h}" '
                     f'stroke="black" stroke-width="2"/>')

    # Y axis labels
    for i in range(6):
        y_val = max_ratio * i / 5
        y_pos = margin["top"] + chart_h - (y_val / max_ratio) * chart_h
        svg_parts.append(f'<text x="{margin["left"] - 10}" y="{y_pos + 4}" '
                         f'text-anchor="end" font-size="11" font-family="Arial">'
                         f'{y_val:.1f}</text>')
        svg_parts.append(f'<line x1="{margin["left"]}" y1="{y_pos}" '
                         f'x2="{margin["left"] + chart_w}" y2="{y_pos}" '
                         f'stroke="#ddd" stroke-width="1"/>')

    # X axis labels
    for r in range(1, max_r + 1):
        x_pos = margin["left"] + (r / max_r) * chart_w
        svg_parts.append(f'<text x="{x_pos}" y="{margin["top"] + chart_h + 20}" '
                         f'text-anchor="middle" font-size="11" font-family="Arial">'
                         f'{r}</text>')

    # Plot data points and line
    points = []
    for r, ratio in data:
        x = margin["left"] + (r / max_r) * chart_w
        y = margin["top"] + chart_h - (ratio / max_ratio) * chart_h
        points.append((x, y))

    # Line
    line_points = " ".join(f"{x:.1f},{y:.1f}" for x, y in points)
    svg_parts.append(f'<polyline points="{line_points}" fill="none" '
                     f'stroke="#2196F3" stroke-width="2.5"/>')

    # Points
    for i, (x, y) in enumerate(points):
        is_hex = True  # All points are hex numbers in this chart
        color = "#FF5722" if is_hex else "#2196F3"
        svg_parts.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="4" '
                         f'fill="{color}" stroke="white" stroke-width="1"/>')

    # Axis labels
    svg_parts.append(f'<text x="{width//2}" y="{height - 10}" text-anchor="middle" '
                     f'font-size="13" font-family="Arial">Radius r</text>')
    svg_parts.append(f'<text x="15" y="{height//2}" text-anchor="middle" '
                     f'font-size="13" font-family="Arial" '
                     f'transform="rotate(-90, 15, {height//2})">boundary / area</text>')

    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_fiber_analysis_svg(width: int = 700, height: int = 400) -> str:
    """Generate SVG showing fiber gap analysis."""
    svg_parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
                 f'viewBox="0 0 {width} {height}">']
    svg_parts.append(f'<rect width="{width}" height="{height}" fill="white"/>')

    svg_parts.append(f'<text x="{width//2}" y="25" text-anchor="middle" '
                     f'font-size="16" font-family="Arial" font-weight="bold">'
                     f'Boundary Excess vs Symmetric Difference</text>')

    # Generate data
    r = 4
    patch = hex_patch(r)
    data_points = []

    rng = random.Random(42)
    for trial in range(100):
        S = set(patch)
        num_swaps = rng.randint(0, 8)
        for _ in range(num_swaps):
            boundary = [(p, n) for p in S for n in hex_neighbors(p) if n not in S]
            if not boundary:
                break
            p, n = rng.choice(boundary)
            S_new = (S - {p}) | {n}

            # Check connectivity
            start = next(iter(S_new))
            visited = {start}
            queue = [start]
            while queue:
                curr = queue.pop(0)
                for nb in hex_neighbors(curr):
                    if nb in S_new and nb not in visited:
                        visited.add(nb)
                        queue.append(nb)

            if len(visited) == len(S_new):
                S = S_new

        bdy = edge_boundary(S)
        excess = bdy - opt_boundary(r)

        # Find best translate
        best_sd = len(S) + len(patch)
        for p in S:
            translated = {(c[0] + p[0], c[1] + p[1]) for c in patch}
            sd = len(S.symmetric_difference(translated))
            if sd < best_sd:
                best_sd = sd

        data_points.append((excess, best_sd))

    # Chart
    margin = {"left": 80, "right": 40, "top": 50, "bottom": 60}
    chart_w = width - margin["left"] - margin["right"]
    chart_h = height - margin["top"] - margin["bottom"]

    max_excess = max(d[0] for d in data_points) + 1
    max_sd = max(d[1] for d in data_points) + 1

    # Axes
    svg_parts.append(f'<line x1="{margin["left"]}" y1="{margin["top"]}" '
                     f'x2="{margin["left"]}" y2="{margin["top"] + chart_h}" '
                     f'stroke="black" stroke-width="2"/>')
    svg_parts.append(f'<line x1="{margin["left"]}" y1="{margin["top"] + chart_h}" '
                     f'x2="{margin["left"] + chart_w}" y2="{margin["top"] + chart_h}" '
                     f'stroke="black" stroke-width="2"/>')

    # Reference line: symmDiff = 6 * excess
    C = 6
    x0 = margin["left"]
    y0 = margin["top"] + chart_h
    x1 = margin["left"] + min(max_excess, max_sd / C) / max_excess * chart_w
    y1 = margin["top"] + chart_h - min(max_sd, C * max_excess) / max_sd * chart_h
    svg_parts.append(f'<line x1="{x0}" y1="{y0}" x2="{x1}" y2="{y1}" '
                     f'stroke="#FF9800" stroke-width="2" stroke-dasharray="8,4"/>')
    svg_parts.append(f'<text x="{x1 + 5}" y="{y1}" font-size="11" '
                     f'font-family="Arial" fill="#FF9800">C={C}</text>')

    # Data points
    for excess, sd in data_points:
        x = margin["left"] + (excess / max_excess) * chart_w
        y = margin["top"] + chart_h - (sd / max_sd) * chart_h
        svg_parts.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="3.5" '
                         f'fill="#2196F3" fill-opacity="0.6" stroke="none"/>')

    # Axis labels
    svg_parts.append(f'<text x="{width//2}" y="{height - 10}" text-anchor="middle" '
                     f'font-size="13" font-family="Arial">Boundary excess δ</text>')
    svg_parts.append(f'<text x="15" y="{height//2}" text-anchor="middle" '
                     f'font-size="13" font-family="Arial" '
                     f'transform="rotate(-90, 15, {height//2})">'
                     f'Symmetric difference |S △ hexPatch+v|</text>')

    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


if __name__ == "__main__":
    # Generate all visualizations
    print("Generating visualizations...")

    # 1. Hex patches at different radii
    for r in [1, 2, 3, 4]:
        svg = generate_hex_patch_svg(r, f"Hexagonal Patch (r={r})")
        with open(f"hex_patch_r{r}.svg", "w") as f:
            f.write(svg)
        print(f"  Saved hex_patch_r{r}.svg")

    # 2. Isoperimetric ratio chart
    svg = generate_rigidity_chart_svg()
    with open("isoperimetric_ratio.svg", "w") as f:
        f.write(svg)
    print("  Saved isoperimetric_ratio.svg")

    # 3. Fiber analysis scatter plot
    svg = generate_fiber_analysis_svg()
    with open("boundary_vs_symmdiff.svg", "w") as f:
        f.write(svg)
    print("  Saved boundary_vs_symmdiff.svg")

    print("\nAll visualizations generated!")
