#!/usr/bin/env python3
"""
Tropical Helly Geometry — Applications

Demonstrates real-world applications of the tropical Helly theorem
and feasibility certificate:

1. Scheduling: checking consistency of time-window constraints
2. Resource allocation: verifying capacity bounds
3. Network routing: shortest-path constraint consistency
"""

import numpy as np
from typing import List, Tuple, Optional


# ─── Application 1: Scheduling ──────────────────────────────────────────

def scheduling_demo():
    """
    Application: Job Scheduling with Time Windows
    
    Each job j must be completed within a time window [earliest_j, deadline_j].
    Multiple resources each impose their own time windows on the jobs.
    
    Question: Is there a feasible schedule satisfying ALL resource constraints?
    
    By the tropical Helly theorem (Helly number 2 for boxes):
    if every PAIR of resource constraints is simultaneously satisfiable,
    then ALL constraints are simultaneously satisfiable.
    """
    print("=" * 70)
    print("APPLICATION 1: Job Scheduling with Time Windows")
    print("=" * 70)
    
    # 3 jobs, 4 resource constraints
    # Each constraint specifies [earliest, deadline] for each job
    constraints = [
        # Resource A: jobs can start early but must finish by moderate deadlines
        (np.array([0.0, 1.0, 2.0]), np.array([5.0, 6.0, 7.0])),
        # Resource B: tighter windows
        (np.array([1.0, 2.0, 3.0]), np.array([4.0, 5.0, 6.0])),
        # Resource C: shifted later
        (np.array([2.0, 3.0, 4.0]), np.array([6.0, 7.0, 8.0])),
        # Resource D: wide windows
        (np.array([0.0, 0.0, 0.0]), np.array([10.0, 10.0, 10.0])),
    ]
    
    print("\nResource constraints (time windows for 3 jobs):")
    for i, (lo, hi) in enumerate(constraints):
        print(f"  Resource {chr(65+i)}: earliest={lo}, deadline={hi}")
    
    # Check feasibility
    lo_max = np.max([lo for lo, _ in constraints], axis=0)
    hi_min = np.min([hi for _, hi in constraints], axis=0)
    
    print(f"\nTightest feasible window: [{lo_max}] to [{hi_min}]")
    
    if np.all(lo_max <= hi_min):
        schedule = (lo_max + hi_min) / 2
        print(f"✓ Feasible! Schedule: {schedule}")
        print(f"  (Each job scheduled at the midpoint of its feasible window)")
    else:
        print("✗ Infeasible!")
        # Find certificate
        for i in range(len(constraints)):
            for j in range(i+1, len(constraints)):
                lo_i, hi_i = constraints[i]
                lo_j, hi_j = constraints[j]
                if not (np.all(lo_i <= hi_j) and np.all(lo_j <= hi_i)):
                    print(f"  Certificate: Resources {chr(65+i)} and {chr(65+j)} conflict")
                    break
    
    # Now create an infeasible scenario
    print("\n--- Infeasible scenario ---")
    constraints_bad = constraints + [
        (np.array([7.0, 8.0, 9.0]), np.array([10.0, 11.0, 12.0])),  # too late
    ]
    print(f"  Added Resource E: earliest=[7, 8, 9], deadline=[10, 11, 12]")
    
    lo_max = np.max([lo for lo, _ in constraints_bad], axis=0)
    hi_min = np.min([hi for _, hi in constraints_bad], axis=0)
    
    if np.all(lo_max <= hi_min):
        print("  ✓ Still feasible")
    else:
        print("  ✗ Infeasible!")
        for i in range(len(constraints_bad)):
            for j in range(i+1, len(constraints_bad)):
                lo_i, hi_i = constraints_bad[i]
                lo_j, hi_j = constraints_bad[j]
                if not (np.all(lo_i <= hi_j) and np.all(lo_j <= hi_i)):
                    for k in range(len(lo_i)):
                        if lo_i[k] > hi_j[k]:
                            print(f"  Certificate: Resource {chr(65+i)} and {chr(65+j)}, "
                                  f"job {k}: earliest[{chr(65+i)}]={lo_i[k]} > deadline[{chr(65+j)}]={hi_j[k]}")
                        if lo_j[k] > hi_i[k]:
                            print(f"  Certificate: Resource {chr(65+j)} and {chr(65+i)}, "
                                  f"job {k}: earliest[{chr(65+j)}]={lo_j[k]} > deadline[{chr(65+i)}]={hi_i[k]}")
                    break
            else:
                continue
            break


# ─── Application 2: Network Routing ─────────────────────────────────────

def network_routing_demo():
    """
    Application: Network Distance Consistency
    
    In a network with n nodes, each edge gives bounds on the distance
    between nodes. The question: is there a consistent distance assignment?
    
    This is a box constraint system where each dimension is a node distance.
    The Helly theorem guarantees that pairwise consistency implies global consistency.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Network Distance Consistency")
    print("=" * 70)
    
    # 4 nodes, distance bounds from different measurement sources
    # Each source gives [min_dist, max_dist] for each node pair
    sources = {
        "GPS": (np.array([10.0, 20.0, 15.0, 25.0]), 
                np.array([15.0, 30.0, 25.0, 35.0])),
        "WiFi": (np.array([8.0, 18.0, 12.0, 22.0]), 
                 np.array([14.0, 28.0, 22.0, 32.0])),
        "Bluetooth": (np.array([11.0, 22.0, 16.0, 26.0]), 
                      np.array([16.0, 32.0, 26.0, 36.0])),
    }
    
    print("\nDistance bounds from different sources (4 node pairs):")
    for name, (lo, hi) in sources.items():
        print(f"  {name:>10s}: min={lo}, max={hi}")
    
    boxes = list(sources.values())
    lo_max = np.max([lo for lo, _ in boxes], axis=0)
    hi_min = np.min([hi for _, hi in boxes], axis=0)
    
    if np.all(lo_max <= hi_min):
        consistent = (lo_max + hi_min) / 2
        print(f"\n✓ Consistent! Distances: {consistent}")
        print(f"  Consistent range: [{lo_max}] to [{hi_min}]")
    else:
        print(f"\n✗ Inconsistent measurements!")


# ─── Application 3: Supply Chain ─────────────────────────────────────────

def supply_chain_demo():
    """
    Application: Supply Chain Capacity Planning
    
    Multiple suppliers each have capacity ranges for d products.
    A customer needs to ensure that the combined supply range covers demand.
    
    Each supplier's capacity is a box in R^d.
    The Helly theorem tells us: if any two suppliers can together meet demand,
    then all suppliers' constraints are mutually consistent.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Supply Chain Capacity Bounds")
    print("=" * 70)
    
    # 3 products, 5 suppliers with capacity ranges
    suppliers = {
        "Alpha": (np.array([100, 50, 200]), np.array([500, 300, 800])),
        "Beta":  (np.array([150, 100, 150]), np.array([400, 250, 600])),
        "Gamma": (np.array([200, 80, 250]), np.array([600, 350, 900])),
        "Delta": (np.array([50, 120, 100]), np.array([350, 400, 550])),
    }
    
    print("\nSupplier capacity ranges (3 products):")
    for name, (lo, hi) in suppliers.items():
        print(f"  {name:>6s}: min={lo}, max={hi}")
    
    boxes = list(suppliers.values())
    lo_max = np.max([lo for lo, _ in boxes], axis=0)
    hi_min = np.min([hi for _, hi in boxes], axis=0)
    
    print(f"\nConsensus capacity range: [{lo_max}] to [{hi_min}]")
    
    if np.all(lo_max <= hi_min):
        target = (lo_max + hi_min) / 2
        print(f"✓ Compatible! Feasible production target: {target}")
    else:
        print("✗ Incompatible capacity ranges!")
        for i, (n1, b1) in enumerate(suppliers.items()):
            for j, (n2, b2) in enumerate(suppliers.items()):
                if j <= i:
                    continue
                lo1, hi1 = b1
                lo2, hi2 = b2
                if not (np.all(lo1 <= hi2) and np.all(lo2 <= hi1)):
                    print(f"  Certificate: {n1} and {n2} are incompatible")


if __name__ == "__main__":
    scheduling_demo()
    network_routing_demo()
    supply_chain_demo()
    
    print("\n" + "=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Helly Geometry — Interactive Demonstration

This script demonstrates the tropical Helly theorem for boxes:
  "Pairwise intersection of boxes implies global intersection."

It generates random box constraint systems, tests pairwise feasibility,
and verifies the Helly property. It also demonstrates the feasibility
certificate: when a system is infeasible, a pair of conflicting boxes is found.

Usage:
    python demo.py
"""

import numpy as np
from itertools import combinations
from typing import Optional

# ─── Tropical Operations ────────────────────────────────────────────────

def trop_comb(t: float, x: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Max-plus tropical combination: z_i = max(x_i, t + y_i) with t <= 0."""
    return np.maximum(x, t + y)


def trop_segment_sample(x: np.ndarray, y: np.ndarray, num_points: int = 20) -> np.ndarray:
    """Sample points from the tropical segment between x and y."""
    points = []
    for t in np.linspace(-5, 0, num_points):
        points.append(trop_comb(t, x, y))
        points.append(trop_comb(t, y, x))
    return np.array(points)


# ─── Box Operations ─────────────────────────────────────────────────────

def random_box(d: int, lo_range=(-5, 5), width_range=(0.5, 4.0)) -> tuple:
    """Generate a random box [lo, hi] in R^d."""
    lo = np.random.uniform(*lo_range, size=d)
    widths = np.random.uniform(*width_range, size=d)
    hi = lo + widths
    return lo, hi


def boxes_intersect(lo1, hi1, lo2, hi2) -> bool:
    """Check if two boxes intersect (coordinatewise)."""
    return np.all(lo1 <= hi2) and np.all(lo2 <= hi1)


def find_box_intersection_point(lo1, hi1, lo2, hi2) -> Optional[np.ndarray]:
    """Find a point in the intersection of two boxes, or None."""
    meet_lo = np.maximum(lo1, lo2)
    meet_hi = np.minimum(hi1, hi2)
    if np.all(meet_lo <= meet_hi):
        return (meet_lo + meet_hi) / 2
    return None


def find_global_intersection(boxes: list) -> Optional[np.ndarray]:
    """Find a point in the intersection of all boxes, or None."""
    if not boxes:
        return np.zeros(0)
    lo_max = np.max([lo for lo, _ in boxes], axis=0)
    hi_min = np.min([hi for _, hi in boxes], axis=0)
    if np.all(lo_max <= hi_min):
        return (lo_max + hi_min) / 2
    return None


def find_infeasible_pair(boxes: list) -> Optional[tuple]:
    """Find a pair of boxes that don't intersect, or None if all pairs do."""
    for i, j in combinations(range(len(boxes)), 2):
        lo_i, hi_i = boxes[i]
        lo_j, hi_j = boxes[j]
        if not boxes_intersect(lo_i, hi_i, lo_j, hi_j):
            return (i, j)
    return None


# ─── Helly Theorem Verification ─────────────────────────────────────────

def verify_helly_property(boxes: list) -> dict:
    """
    Verify the tropical Helly property for a family of boxes:
    pairwise intersection ⟹ global intersection.
    
    Returns a dict with the verification results.
    """
    n = len(boxes)
    if n == 0:
        return {"n": 0, "pairwise": True, "global": True, "helly_holds": True}
    
    # Check pairwise intersections
    pairwise_ok = True
    bad_pair = None
    for i, j in combinations(range(n), 2):
        lo_i, hi_i = boxes[i]
        lo_j, hi_j = boxes[j]
        if not boxes_intersect(lo_i, hi_i, lo_j, hi_j):
            pairwise_ok = False
            bad_pair = (i, j)
            break
    
    # Check global intersection
    global_point = find_global_intersection(boxes)
    global_ok = global_point is not None
    
    # Helly property: pairwise ⟹ global
    helly_holds = (not pairwise_ok) or global_ok
    
    return {
        "n": n,
        "pairwise": pairwise_ok,
        "global": global_ok,
        "helly_holds": helly_holds,
        "global_point": global_point,
        "bad_pair": bad_pair,
    }


# ─── Demonstrations ─────────────────────────────────────────────────────

def demo_helly_theorem():
    """Demonstrate the Helly theorem for boxes."""
    print("=" * 70)
    print("DEMONSTRATION: Tropical Helly Theorem for Boxes")
    print("=" * 70)
    
    np.random.seed(42)
    
    for d in [1, 2, 3, 5]:
        print(f"\n--- Dimension d = {d} ---")
        
        successes = 0
        trials = 1000
        
        for trial in range(trials):
            n = np.random.randint(3, 15)
            boxes = [random_box(d) for _ in range(n)]
            result = verify_helly_property(boxes)
            if result["helly_holds"]:
                successes += 1
        
        print(f"  Tested {trials} random box families")
        print(f"  Helly property held: {successes}/{trials} (should be {trials}/{trials})")
        assert successes == trials, "Helly property violated!"
    
    print("\n✓ All tests passed! The Helly property holds for all tested cases.")


def demo_feasibility_certificate():
    """Demonstrate the feasibility certificate theorem."""
    print("\n" + "=" * 70)
    print("DEMONSTRATION: Feasibility Certificate Theorem")
    print("=" * 70)
    
    np.random.seed(123)
    d = 3
    
    # Create an infeasible system by making two boxes that don't overlap
    boxes = [
        (np.array([0.0, 0.0, 0.0]), np.array([1.0, 1.0, 1.0])),
        (np.array([0.5, 0.5, 0.5]), np.array([2.0, 2.0, 2.0])),
        (np.array([3.0, 0.0, 0.0]), np.array([4.0, 1.0, 1.0])),  # disjoint from box 0 in x
        (np.array([0.0, 0.0, 0.0]), np.array([3.5, 3.5, 3.5])),
    ]
    
    print(f"\nSystem of {len(boxes)} boxes in R^{d}:")
    for i, (lo, hi) in enumerate(boxes):
        print(f"  Box {i}: [{lo}] to [{hi}]")
    
    global_pt = find_global_intersection(boxes)
    print(f"\nGlobal intersection: {'nonempty' if global_pt is not None else 'EMPTY'}")
    
    if global_pt is None:
        pair = find_infeasible_pair(boxes)
        if pair:
            i, j = pair
            print(f"Certificate: Boxes {i} and {j} are mutually infeasible")
            lo_i, hi_i = boxes[i]
            lo_j, hi_j = boxes[j]
            print(f"  Box {i}: [{lo_i}] to [{hi_i}]")
            print(f"  Box {j}: [{lo_j}] to [{hi_j}]")
            # Show which coordinate fails
            for k in range(d):
                if lo_i[k] > hi_j[k]:
                    print(f"  Conflict on coordinate {k}: lo[{i}][{k}]={lo_i[k]} > hi[{j}][{k}]={hi_j[k]}")
                if lo_j[k] > hi_i[k]:
                    print(f"  Conflict on coordinate {k}: lo[{j}][{k}]={lo_j[k]} > hi[{i}][{k}]={hi_i[k]}")
        else:
            print("No infeasible pair found — but system is infeasible. (Impossible by theorem!)")
    
    print("\n✓ The certificate theorem correctly identifies the conflicting pair.")


def demo_tropical_segments():
    """Demonstrate tropical segments in 2D."""
    print("\n" + "=" * 70)
    print("DEMONSTRATION: Tropical Segments in 2D")
    print("=" * 70)
    
    x = np.array([0.0, 2.0])
    y = np.array([3.0, 0.0])
    
    print(f"\nPoint x = {x}")
    print(f"Point y = {y}")
    
    print("\nTropical segment (max-plus, t ≤ 0):")
    print("  z_i = max(x_i, t + y_i) for various t:")
    for t in [0, -0.5, -1.0, -1.5, -2.0, -3.0, -5.0]:
        z = trop_comb(t, x, y)
        print(f"    t = {t:5.1f}: z = ({z[0]:5.2f}, {z[1]:5.2f})")
    
    print("\n  z_i = max(y_i, s + x_i) for various s:")
    for s in [0, -0.5, -1.0, -1.5, -2.0, -3.0, -5.0]:
        z = trop_comb(s, y, x)
        print(f"    s = {s:5.1f}: z = ({z[0]:5.2f}, {z[1]:5.2f})")


def demo_convex_hull():
    """Demonstrate tropical convex hull."""
    print("\n" + "=" * 70)
    print("DEMONSTRATION: Tropical Convex Hull")
    print("=" * 70)
    
    pts = np.array([
        [0.0, 0.0],
        [3.0, 1.0],
        [1.0, 4.0],
    ])
    
    print(f"\nGenerators: {pts.tolist()}")
    print("\nTropical convex hull points (max-plus, sampled):")
    print("  z_i = max_k(w_k + pts_k_i) for various weights w:")
    
    for _ in range(10):
        w = np.random.uniform(-5, 0, size=3)
        z = np.max(w[:, None] + pts, axis=0)
        print(f"    w = [{w[0]:5.2f}, {w[1]:5.2f}, {w[2]:5.2f}] → z = ({z[0]:5.2f}, {z[1]:5.2f})")


def demo_stress_test():
    """Stress-test the Helly property with many random systems."""
    print("\n" + "=" * 70)
    print("STRESS TEST: Helly Property for Boxes")
    print("=" * 70)
    
    np.random.seed(0)
    
    for d in [1, 2, 3, 5, 10]:
        for n_range in [(3, 10), (10, 50), (50, 100)]:
            trials = 500
            pairwise_implies_global = 0
            pairwise_count = 0
            
            for _ in range(trials):
                n = np.random.randint(*n_range)
                boxes = [random_box(d) for _ in range(n)]
                result = verify_helly_property(boxes)
                if result["pairwise"]:
                    pairwise_count += 1
                    if result["global"]:
                        pairwise_implies_global += 1
            
            if pairwise_count > 0:
                rate = pairwise_implies_global / pairwise_count
                print(f"  d={d:2d}, n∈{n_range}: "
                      f"pairwise→global: {pairwise_implies_global}/{pairwise_count} = {rate:.4f}")
                assert rate == 1.0, f"Helly violated at d={d}, n_range={n_range}"
    
    print("\n✓ All stress tests passed!")


if __name__ == "__main__":
    demo_helly_theorem()
    demo_feasibility_certificate()
    demo_tropical_segments()
    demo_convex_hull()
    demo_stress_test()
    
    print("\n" + "=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Tropical Feasibility Certificate

Demonstrates the feasibility certificate theorem:
when a system of box constraints is infeasible, exactly which pair
of constraints conflicts. Shows both feasible and infeasible scenarios.

Uses matplotlib. Output: helly_certificate.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Panel 1: Feasible system ---
ax = axes[0]

boxes_feasible = [
    (np.array([0, 0]), np.array([3, 3]), 'lightcoral', 'Constraint 1'),
    (np.array([1, 0.5]), np.array([4, 3.5]), 'lightgreen', 'Constraint 2'),
    (np.array([0.5, 1]), np.array([3.5, 4]), 'lightskyblue', 'Constraint 3'),
    (np.array([1.5, 0.5]), np.array([5, 2.5]), 'plum', 'Constraint 4'),
]

for lo, hi, color, label in boxes_feasible:
    rect = plt.Rectangle(lo, hi[0]-lo[0], hi[1]-lo[1],
                         alpha=0.25, facecolor=color, edgecolor='black', linewidth=1.5,
                         label=label)
    ax.add_patch(rect)

lo_max = np.max([lo for lo, _, _, _ in boxes_feasible], axis=0)
hi_min = np.min([hi for _, hi, _, _ in boxes_feasible], axis=0)

if np.all(lo_max <= hi_min):
    rect_int = plt.Rectangle(lo_max, hi_min[0]-lo_max[0], hi_min[1]-lo_max[1],
                             alpha=0.5, facecolor='gold', edgecolor='darkred', linewidth=2.5)
    ax.add_patch(rect_int)
    center = (lo_max + hi_min) / 2
    ax.plot(*center, 'r*', markersize=20, zorder=5, label='Feasible point')
    ax.annotate(f'({center[0]:.1f}, {center[1]:.1f})', center,
                fontsize=11, fontweight='bold', xytext=(10, 10),
                textcoords='offset points',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.8))

ax.set_xlim(-0.5, 6)
ax.set_ylim(-0.5, 5)
ax.set_title('Feasible System\n(All pairs intersect → global intersection)', 
             fontsize=13, fontweight='bold')
ax.set_xlabel('x₁', fontsize=12)
ax.set_ylabel('x₂', fontsize=12)
ax.legend(fontsize=9, loc='upper right')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 2: Infeasible system with certificate ---
ax = axes[1]

boxes_infeasible = [
    (np.array([0, 0]), np.array([2, 3]), 'lightcoral', 'Constraint 1'),
    (np.array([1, 0.5]), np.array([3, 3.5]), 'lightgreen', 'Constraint 2'),
    (np.array([4, 0]), np.array([6, 3]), 'lightskyblue', 'Constraint 3'),
    (np.array([0.5, 1]), np.array([5, 4]), 'plum', 'Constraint 4'),
]

for lo, hi, color, label in boxes_infeasible:
    rect = plt.Rectangle(lo, hi[0]-lo[0], hi[1]-lo[1],
                         alpha=0.25, facecolor=color, edgecolor='black', linewidth=1.5,
                         label=label)
    ax.add_patch(rect)

# Find and highlight the conflicting pair
for i in range(len(boxes_infeasible)):
    for j in range(i+1, len(boxes_infeasible)):
        lo_i, hi_i = boxes_infeasible[i][0], boxes_infeasible[i][1]
        lo_j, hi_j = boxes_infeasible[j][0], boxes_infeasible[j][1]
        if not (np.all(lo_i <= hi_j) and np.all(lo_j <= hi_i)):
            # Highlight conflicting boxes
            rect1 = plt.Rectangle(lo_i, hi_i[0]-lo_i[0], hi_i[1]-lo_i[1],
                                 alpha=0, edgecolor='red', linewidth=3, linestyle='--')
            rect2 = plt.Rectangle(lo_j, hi_j[0]-lo_j[0], hi_j[1]-lo_j[1],
                                 alpha=0, edgecolor='red', linewidth=3, linestyle='--')
            ax.add_patch(rect1)
            ax.add_patch(rect2)
            
            # Arrow between them
            c1 = (lo_i + hi_i) / 2
            c2 = (lo_j + hi_j) / 2
            ax.annotate('', xy=c2, xytext=c1,
                       arrowprops=dict(arrowstyle='<->', color='red', lw=2.5))
            mid = (c1 + c2) / 2
            ax.annotate(f'CONFLICT\n(boxes {i+1} & {j+1})', mid,
                       fontsize=11, fontweight='bold', color='red',
                       ha='center', va='bottom',
                       bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))
            break
    else:
        continue
    break

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 5)
ax.set_title('Infeasible System with Certificate\n(Pair of conflicting constraints found)', 
             fontsize=13, fontweight='bold')
ax.set_xlabel('x₁', fontsize=12)
ax.set_ylabel('x₂', fontsize=12)
ax.legend(fontsize=9, loc='upper right')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('helly_certificate.png', dpi=150, bbox_inches='tight')
print("Saved: helly_certificate.png")


#!/usr/bin/env python3
"""
Visualization: Tropical Convex Hull Structure

Shows the structure of tropical convex hulls in 2D, comparing them with
classical convex hulls. Illustrates the piecewise-linear nature of
tropical geometry and the role of max-plus combinations.

Uses matplotlib. Output: tropical_hull.png
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial import ConvexHull


def trop_comb(t, x, y):
    return np.maximum(x, t + y)


def sample_trop_hull(generators, num=10000):
    n = len(generators)
    pts = []
    for _ in range(num):
        w = np.random.uniform(-8, 0, size=n)
        z = np.max(w[:, None] + generators, axis=0)
        pts.append(z)
    return np.array(pts)


def sample_trop_segment(x, y, num=300):
    diff = np.max(np.abs(x - y))
    t_range = max(diff * 2, 5.0)
    pts = []
    for t in np.linspace(-t_range, 0, num):
        pts.append(trop_comb(t, x, y))
        pts.append(trop_comb(t, y, x))
    return np.array(pts)


fig, axes = plt.subplots(2, 2, figsize=(14, 13))

# --- Panel 1: 2 generators ---
ax = axes[0, 0]
gens = np.array([[0.0, 3.0], [4.0, 0.0]])
seg = sample_trop_segment(gens[0], gens[1], num=500)

# Sort for clean plotting
order = np.argsort(seg[:, 0])
seg_sorted = seg[order]
# Remove duplicates approximately
unique_mask = np.concatenate([[True], np.any(np.abs(np.diff(seg_sorted, axis=0)) > 0.01, axis=1)])
seg_unique = seg_sorted[unique_mask]

ax.fill_between(seg_unique[:, 0], seg_unique[:, 1] - 0.05, seg_unique[:, 1] + 0.05,
                alpha=0.3, color='blue', label='Tropical segment')
ax.plot(seg_unique[:, 0], seg_unique[:, 1], 'b-', linewidth=2)

# Classical segment
ts = np.linspace(0, 1, 100)
classical = np.array([t * gens[0] + (1 - t) * gens[1] for t in ts])
ax.plot(classical[:, 0], classical[:, 1], 'r--', linewidth=2, label='Classical segment')

for i, g in enumerate(gens):
    ax.plot(*g, 'ko', markersize=12, zorder=5)
    
ax.set_title('2 Points: Tropical vs Classical', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_xlabel('x₁'); ax.set_ylabel('x₂')

# --- Panel 2: 3 generators ---
ax = axes[0, 1]
gens3 = np.array([[0.0, 0.0], [5.0, 1.0], [2.0, 6.0]])
hull_pts = sample_trop_hull(gens3, num=15000)

ax.scatter(hull_pts[:, 0], hull_pts[:, 1], c='lightblue', s=0.5, alpha=0.3, label='Tropical hull')

# Tropical segments between generators
for i in range(3):
    for j in range(i+1, 3):
        seg = sample_trop_segment(gens3[i], gens3[j], num=300)
        ax.plot(seg[:, 0], seg[:, 1], 'b-', linewidth=1.5, alpha=0.7)

# Classical hull
try:
    ch = ConvexHull(gens3)
    for simplex in ch.simplices:
        ax.plot(gens3[simplex, 0], gens3[simplex, 1], 'r--', linewidth=2)
except:
    pass

for i, g in enumerate(gens3):
    ax.plot(*g, 'ro', markersize=10, zorder=5)
    ax.annotate(f'p{i}', g, fontsize=12, fontweight='bold', 
                xytext=(8, 5), textcoords='offset points')

ax.set_title('3 Points: Tropical Convex Hull', fontsize=13, fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_xlabel('x₁'); ax.set_ylabel('x₂')

# --- Panel 3: 4 generators ---
ax = axes[1, 0]
gens4 = np.array([[0.0, 0.0], [6.0, 1.0], [4.0, 7.0], [1.0, 5.0]])
hull_pts4 = sample_trop_hull(gens4, num=20000)

ax.scatter(hull_pts4[:, 0], hull_pts4[:, 1], c='lightgreen', s=0.5, alpha=0.3)

for i in range(4):
    for j in range(i+1, 4):
        seg = sample_trop_segment(gens4[i], gens4[j], num=200)
        ax.plot(seg[:, 0], seg[:, 1], 'g-', linewidth=1, alpha=0.5)

for i, g in enumerate(gens4):
    ax.plot(*g, 'ko', markersize=10, zorder=5)
    ax.annotate(f'p{i}', g, fontsize=11, fontweight='bold',
                xytext=(8, 5), textcoords='offset points')

ax.set_title('4 Points: Larger Hull', fontsize=13, fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_xlabel('x₁'); ax.set_ylabel('x₂')

# --- Panel 4: Weight space exploration ---
ax = axes[1, 1]
gens_demo = np.array([[0.0, 0.0], [4.0, 1.0], [1.0, 5.0]])

# Color by which generator dominates
hull_colors = []
hull_x, hull_y = [], []
for _ in range(15000):
    w = np.random.uniform(-6, 0, size=3)
    shifted = w[:, None] + gens_demo
    z = np.max(shifted, axis=0)
    # For each coordinate, which generator achieves the max?
    dominant = np.argmax(shifted, axis=0)
    # Color encoding: mix based on dominance
    colors = np.array([[1, 0, 0], [0, 0.7, 0], [0, 0, 1]])
    color = np.mean([colors[dominant[0]], colors[dominant[1]]], axis=0)
    hull_colors.append(color)
    hull_x.append(z[0])
    hull_y.append(z[1])

hull_colors = np.array(hull_colors)
ax.scatter(hull_x, hull_y, c=hull_colors, s=1, alpha=0.4)

for i, g in enumerate(gens_demo):
    colors = ['red', 'green', 'blue']
    ax.plot(*g, 'o', color=colors[i], markersize=12, zorder=5,
            markeredgecolor='black', markeredgewidth=1.5)
    ax.annotate(f'p{i}', g, fontsize=12, fontweight='bold',
                xytext=(8, 5), textcoords='offset points')

ax.set_title('Hull Colored by Dominant Generator', fontsize=13, fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
ax.set_xlabel('x₁'); ax.set_ylabel('x₂')

plt.suptitle('Tropical Convex Geometry (Max-Plus Convention)', 
             fontsize=16, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('tropical_hull.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_hull.png")


#!/usr/bin/env python3
"""
Visualization: Tropical Segments and Convex Hulls in 2D

Visualizes the max-plus tropical segment between two points and the
tropical convex hull of three generators. Shows how tropical geometry
creates piecewise-linear "geodesics" unlike classical straight lines.

Uses matplotlib. Output: tropical_segments.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def trop_comb(t, x, y):
    """Max-plus tropical combination: z_i = max(x_i, t + y_i)."""
    return np.maximum(x, t + y)


def compute_segment(x, y, num=500):
    """Compute tropical segment between x and y."""
    diff = np.max(np.abs(x - y))
    t_range = max(diff * 2, 5.0)
    pts = []
    for t in np.linspace(-t_range, 0, num):
        pts.append(trop_comb(t, x, y))
        pts.append(trop_comb(t, y, x))
    return np.array(pts)


def compute_hull(generators, num=2000):
    """Sample points from tropical convex hull."""
    n = len(generators)
    pts = []
    for _ in range(num):
        w = np.random.uniform(-6, 0, size=n)
        z = np.max(w[:, None] + generators, axis=0)
        pts.append(z)
    return np.array(pts)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# --- Panel 1: Tropical segment vs Euclidean segment ---
ax = axes[0]
x = np.array([0.0, 3.0])
y = np.array([4.0, 0.0])

seg = compute_segment(x, y)
ax.plot(seg[:, 0], seg[:, 1], 'b.', markersize=1, alpha=0.5, label='Tropical segment')

# Euclidean segment
ts = np.linspace(0, 1, 100)
euclid = np.array([t * x + (1 - t) * y for t in ts])
ax.plot(euclid[:, 0], euclid[:, 1], 'r--', linewidth=2, label='Euclidean segment')

ax.plot(*x, 'ko', markersize=10, zorder=5)
ax.plot(*y, 'ko', markersize=10, zorder=5)
ax.annotate('x = (0, 3)', x, fontsize=11, xytext=(-1.5, 3.3))
ax.annotate('y = (4, 0)', y, fontsize=11, xytext=(3.5, 0.5))

ax.set_title('Tropical vs Euclidean Segment', fontsize=14, fontweight='bold')
ax.set_xlabel('Coordinate 1')
ax.set_ylabel('Coordinate 2')
ax.legend(fontsize=10)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 2: Tropical convex hull of 3 points ---
ax = axes[1]
generators = np.array([
    [0.0, 0.0],
    [5.0, 1.0],
    [2.0, 6.0],
])

hull_pts = compute_hull(generators, num=5000)
ax.scatter(hull_pts[:, 0], hull_pts[:, 1], c='lightblue', s=1, alpha=0.3)

# Draw segments between generators
for i in range(3):
    for j in range(i + 1, 3):
        seg = compute_segment(generators[i], generators[j])
        ax.plot(seg[:, 0], seg[:, 1], 'b-', linewidth=1, alpha=0.6)

for i, g in enumerate(generators):
    ax.plot(*g, 'ro', markersize=10, zorder=5)
    ax.annotate(f'p{i}', g, fontsize=12, fontweight='bold', 
                xytext=(5, 5), textcoords='offset points')

ax.set_title('Tropical Convex Hull (3 generators)', fontsize=14, fontweight='bold')
ax.set_xlabel('Coordinate 1')
ax.set_ylabel('Coordinate 2')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 3: Helly theorem for boxes ---
ax = axes[2]

boxes = [
    (np.array([0, 0]), np.array([4, 3]), 'lightcoral', 'Box 1'),
    (np.array([1, 1]), np.array([5, 4]), 'lightgreen', 'Box 2'),
    (np.array([2, 0.5]), np.array([6, 3.5]), 'lightskyblue', 'Box 3'),
    (np.array([1.5, 0]), np.array([4.5, 2.5]), 'lightyellow', 'Box 4'),
]

for lo, hi, color, label in boxes:
    rect = plt.Rectangle(lo, hi[0] - lo[0], hi[1] - lo[1], 
                         alpha=0.3, facecolor=color, edgecolor='black', linewidth=1.5,
                         label=label)
    ax.add_patch(rect)

# Compute and show intersection
lo_max = np.max([lo for lo, _, _, _ in boxes], axis=0)
hi_min = np.min([hi for _, hi, _, _ in boxes], axis=0)

if np.all(lo_max <= hi_min):
    rect_int = plt.Rectangle(lo_max, hi_min[0] - lo_max[0], hi_min[1] - lo_max[1],
                             alpha=0.6, facecolor='gold', edgecolor='darkred', linewidth=2,
                             label='Intersection')
    ax.add_patch(rect_int)
    center = (lo_max + hi_min) / 2
    ax.plot(*center, 'r*', markersize=15, zorder=5, label='Witness point')

ax.set_xlim(-0.5, 7)
ax.set_ylim(-0.5, 5)
ax.set_title('Helly Theorem: Pairwise → Global', fontsize=14, fontweight='bold')
ax.set_xlabel('Coordinate 1')
ax.set_ylabel('Coordinate 2')
ax.legend(fontsize=9, loc='upper right')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_segments.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_segments.png")
