#!/usr/bin/env python3
"""
Applications of Causal Holography

Demonstrates real-world applications of the causal reconstruction theorems:
1. Network tomography: recovering internal network structure from boundary probes
2. Causal inference: reconstructing hidden causal relationships from observables
3. Sensor placement: finding minimal boundary sets for full reconstruction
"""

from algorithms import (
    Poset, compute_all_profiles, verify_separation, verify_order_reflection,
    reconstruct_order, reconstruct_covers, find_minimal_separating_boundary,
    enumerate_compatible_pairs
)
from typing import List, Tuple


# ============================================================
# Application 1: Network Tomography
# ============================================================
def network_tomography_demo():
    """
    Network Tomography: Reconstruct internal router topology from boundary probes.

    Scenario: A network has edge routers (boundary) and internal routers (bulk).
    We can only observe which edge routers can reach which other edge routers
    through which paths. Can we reconstruct the internal topology?

    Model: Routers form a DAG (directed acyclic graph) representing packet flow.
    The partial order is reachability. Boundary = edge routers.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Tomography")
    print("=" * 60)
    print()
    print("Scenario: 7-router network with 4 edge routers (E1-E4)")
    print("and 3 internal routers (R1-R3)")
    print()
    print("  E1 → R1 → R2 → E3")
    print("  E2 → R1    R2 → E4")
    print("         ↓  ↗")
    print("         R3")
    print()

    network = Poset(
        elements=["E1", "E2", "R1", "R3", "R2", "E3", "E4"],
        covers=[
            ("E1", "R1"), ("E2", "R1"),
            ("R1", "R3"), ("R3", "R2"),
            ("R1", "R2"),
            ("R2", "E3"), ("R2", "E4")
        ]
    )

    boundary = ["E1", "E2", "E3", "E4"]

    print("Edge router profiles (observable data):")
    profiles = compute_all_profiles(network, boundary)
    for x in network.elements:
        p, f = profiles[x]
        kind = "edge" if x in boundary else "internal"
        print(f"  {x} ({kind}): past={set(p)}, future={set(f)}")

    sep, _ = verify_separation(network, boundary)
    ref, _ = verify_order_reflection(network, boundary)
    print(f"\nSeparation: {sep}")
    print(f"Order reflection: {ref}")

    if sep and ref:
        covers = reconstruct_covers(profiles)
        print(f"\nReconstructed Hasse diagram from boundary data:")
        for x, y in covers:
            print(f"  {x} → {y}")
        print("\nInternal structure successfully recovered from edge observations!")
    else:
        print("\nInsufficient boundary data for full reconstruction.")


# ============================================================
# Application 2: Causal Inference
# ============================================================
def causal_inference_demo():
    """
    Causal Inference: Reconstruct hidden causal mechanisms from observable variables.

    Scenario: A system has observable variables (boundary) and hidden
    confounders/mediators (bulk). We observe which observables can
    influence which others. Can we reconstruct the hidden causal structure?
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Causal Inference")
    print("=" * 60)
    print()
    print("Scenario: Drug trial with observable and hidden variables")
    print()
    print("  Genotype → Metabolism → Drug_Level → Outcome")
    print("                           ↑")
    print("              Dosage -------+")
    print()
    print("Observable (boundary): {Genotype, Dosage, Outcome}")
    print("Hidden (bulk): {Metabolism, Drug_Level}")
    print()

    causal = Poset(
        elements=["Genotype", "Metabolism", "Dosage", "Drug_Level", "Outcome"],
        covers=[
            ("Genotype", "Metabolism"),
            ("Metabolism", "Drug_Level"),
            ("Dosage", "Drug_Level"),
            ("Drug_Level", "Outcome")
        ]
    )

    boundary = ["Genotype", "Dosage", "Outcome"]

    profiles = compute_all_profiles(causal, boundary)
    print("Causal profiles:")
    for x in causal.elements:
        p, f = profiles[x]
        kind = "observable" if x in boundary else "hidden"
        print(f"  {x} ({kind}): causes seen by={set(p)}, effects seen by={set(f)}")

    sep, counter = verify_separation(causal, boundary)
    print(f"\nSeparation: {sep}")
    if not sep:
        print(f"  Cannot distinguish: {counter}")
        print("  This means the hidden variables cannot be individually")
        print("  reconstructed from these observables alone.")

    # Find minimal separating boundary
    min_b = find_minimal_separating_boundary(causal)
    if min_b:
        print(f"\nMinimal separating set: {min_b}")
        print("(These are the minimum observables needed for full reconstruction)")
    else:
        print(f"\nNo single antichain separates all elements.")


# ============================================================
# Application 3: Sensor Placement Optimization
# ============================================================
def sensor_placement_demo():
    """
    Sensor Placement: Find optimal boundary sensors to monitor a system.

    Scenario: A manufacturing pipeline has stages. We want to place
    quality sensors at minimal locations to reconstruct the full
    causal chain of defects.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Sensor Placement for Manufacturing")
    print("=" * 60)
    print()
    print("Manufacturing pipeline:")
    print("  Raw_Material → Mixing → Heating → Molding → Cooling → Inspection → Ship")
    print()

    pipeline = Poset(
        elements=["Raw", "Mix", "Heat", "Mold", "Cool", "Inspect", "Ship"],
        covers=[
            ("Raw", "Mix"), ("Mix", "Heat"), ("Heat", "Mold"),
            ("Mold", "Cool"), ("Cool", "Inspect"), ("Inspect", "Ship")
        ]
    )

    print("Testing different sensor placements:\n")

    placements = [
        ["Raw", "Ship"],
        ["Raw", "Mold", "Ship"],
        ["Raw", "Heat", "Cool", "Ship"],
    ]

    for boundary in placements:
        sep, _ = verify_separation(pipeline, boundary)
        ref, _ = verify_order_reflection(pipeline, boundary)
        print(f"  Sensors at {boundary}:")
        print(f"    Separates all stages: {sep}")
        if sep:
            profiles = compute_all_profiles(pipeline, boundary)
            covers = reconstruct_covers(profiles)
            print(f"    Reconstructed pipeline: {' → '.join(x for x, _ in covers)} → {covers[-1][1]}")
        print()

    min_b = find_minimal_separating_boundary(pipeline)
    if min_b:
        print(f"  Minimum sensors needed: {len(min_b)} at {min_b}")
    else:
        print(f"  No antichain separates all stages (linear order needs non-antichain boundary)")


# ============================================================
# Application 4: Spacetime Reconstruction
# ============================================================
def spacetime_demo():
    """
    Discrete Spacetime: Reconstruct causal structure from boundary observations.

    A simple 2+1D discrete spacetime causal diamond.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Discrete Spacetime Reconstruction")
    print("=" * 60)
    print()
    print("2D causal diamond (Minkowski-like):")
    print("           (1,2)")
    print("          / | \\")
    print("     (0,1) (1,1) (2,1)")
    print("          \\ | /")
    print("           (1,0)")
    print()

    spacetime = Poset(
        elements=["(1,0)", "(0,1)", "(1,1)", "(2,1)", "(1,2)"],
        covers=[
            ("(1,0)", "(0,1)"), ("(1,0)", "(1,1)"), ("(1,0)", "(2,1)"),
            ("(0,1)", "(1,2)"), ("(1,1)", "(1,2)"), ("(2,1)", "(1,2)")
        ]
    )

    # Boundary = spacelike slice at t=1
    boundary = ["(0,1)", "(1,1)", "(2,1)"]
    print(f"Boundary (spacelike slice): {boundary}")

    profiles = compute_all_profiles(spacetime, boundary)
    print("\nCausal profiles:")
    for x in spacetime.elements:
        p, f = profiles[x]
        print(f"  {x}: past_boundary={set(p)}, future_boundary={set(f)}")

    sep, _ = verify_separation(spacetime, boundary)
    ref, _ = verify_order_reflection(spacetime, boundary)
    print(f"\nSeparation: {sep}")
    print(f"Order reflection: {ref}")

    compatible = enumerate_compatible_pairs(spacetime, boundary)
    realized = set(profiles.values())
    print(f"Compatible pairs: {len(compatible)}")
    print(f"Realized by spacetime points: {len(realized)}")
    print(f"Interval generated: {len(compatible) == len(realized)}")

    if sep and ref:
        covers = reconstruct_covers(profiles)
        print(f"\nReconstructed causal structure:")
        for x, y in covers:
            print(f"  {x} → {y}")
        print("\nSpacetime successfully reconstructed from boundary data!")


if __name__ == "__main__":
    network_tomography_demo()
    causal_inference_demo()
    sensor_placement_demo()
    spacetime_demo()


#!/usr/bin/env python3
"""
Demonstration of Causal Holography: Reconstructing Bulk Causal Order from Boundary Profiles

This script demonstrates the core theorem: a finite causal poset can be canonically
reconstructed from its boundary past/future profile data.
"""

from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

# ============================================================
# Core data structures
# ============================================================

class CausalPoset:
    """A finite poset represented by its Hasse diagram (cover relations)."""

    def __init__(self, elements: List[str], covers: List[Tuple[str, str]]):
        self.elements = list(elements)
        self.covers = list(covers)
        # Compute transitive closure
        self._le: Dict[str, Set[str]] = {e: {e} for e in elements}
        changed = True
        while changed:
            changed = False
            for a, b in covers:
                for c in list(self._le[b]):
                    if c not in self._le[a]:
                        self._le[a].add(c)
                        changed = True

    def le(self, x: str, y: str) -> bool:
        return y in self._le[x]

    def lt(self, x: str, y: str) -> bool:
        return x != y and self.le(x, y)

    def is_cover(self, x: str, y: str) -> bool:
        if not self.lt(x, y):
            return False
        return not any(self.lt(x, z) and self.lt(z, y) for z in self.elements)


def past_profile(poset: CausalPoset, boundary: List[str], x: str) -> FrozenSet[str]:
    """Boundary elements below x."""
    return frozenset(b for b in boundary if poset.le(b, x))


def future_profile(poset: CausalPoset, boundary: List[str], x: str) -> FrozenSet[str]:
    """Boundary elements above x."""
    return frozenset(b for b in boundary if poset.le(x, b))


def profile_pair(poset: CausalPoset, boundary: List[str], x: str):
    """The bi-profile (past, future) for element x."""
    return (past_profile(poset, boundary, x), future_profile(poset, boundary, x))


def is_antichain(poset: CausalPoset, subset: List[str]) -> bool:
    """Check if subset is an antichain."""
    for i, x in enumerate(subset):
        for y in subset[i+1:]:
            if poset.le(x, y) or poset.le(y, x):
                return False
    return True


def check_separation(poset: CausalPoset, boundary: List[str]) -> bool:
    """Check if the boundary separates all bulk points."""
    profiles = {}
    for x in poset.elements:
        p = profile_pair(poset, boundary, x)
        if p in profiles:
            print(f"  FAIL: {x} and {profiles[p]} have the same profile")
            return False
        profiles[p] = x
    return True


def check_order_reflection(poset: CausalPoset, boundary: List[str]) -> bool:
    """Check if order is reflected by profile inclusion."""
    for x in poset.elements:
        for y in poset.elements:
            pp_x = past_profile(poset, boundary, x)
            pp_y = past_profile(poset, boundary, y)
            fp_x = future_profile(poset, boundary, x)
            fp_y = future_profile(poset, boundary, y)

            profile_says_le = pp_x.issubset(pp_y) and fp_y.issubset(fp_x)
            actual_le = poset.le(x, y)

            if profile_says_le != actual_le:
                print(f"  FAIL: profile says {x}≤{y} is {profile_says_le}, but actually {actual_le}")
                return False
    return True


def is_compatible(past: FrozenSet[str], future: FrozenSet[str],
                  poset: CausalPoset) -> bool:
    """Check if a profile pair is compatible (every past ≤ every future)."""
    return all(poset.le(bp, bf) for bp in past for bf in future)


def check_interval_generation(poset: CausalPoset, boundary: List[str]) -> bool:
    """Check if every compatible profile pair is realized."""
    realized = {profile_pair(poset, boundary, x) for x in poset.elements}
    boundary_set = set(boundary)

    for r in range(len(boundary) + 1):
        for past_sub in combinations(boundary, r):
            past = frozenset(past_sub)
            for s in range(len(boundary) + 1):
                for future_sub in combinations(boundary, s):
                    future = frozenset(future_sub)
                    if is_compatible(past, future, poset):
                        if (past, future) not in realized:
                            print(f"  FAIL: compatible pair ({past}, {future}) not realized")
                            return False
    return True


def reconstruct_order(poset: CausalPoset, boundary: List[str]):
    """Reconstruct the causal order from profiles and verify it matches."""
    # Build profile pairs for all elements
    profiles = {}
    for x in poset.elements:
        p = profile_pair(poset, boundary, x)
        profiles[x] = p

    # Reconstruct order from profiles
    print("\n  Reconstructed order relations (from profiles):")
    correct = 0
    total = 0
    for x in poset.elements:
        for y in poset.elements:
            if x == y:
                continue
            total += 1
            px, fx = profiles[x]
            py, fy = profiles[y]
            reconstructed_le = px.issubset(py) and fy.issubset(fx)
            actual_le = poset.le(x, y)
            if reconstructed_le == actual_le:
                correct += 1
            if reconstructed_le:
                print(f"    {x} ≤ {y}", end="")
                if actual_le:
                    print(" ✓")
                else:
                    print(" ✗ (FALSE POSITIVE)")

    print(f"\n  Accuracy: {correct}/{total} relations correct")
    return correct == total


# ============================================================
# Example 1: Diamond poset
# ============================================================
print("=" * 60)
print("EXAMPLE 1: Diamond Poset")
print("=" * 60)
print()
print("  Structure:     top")
print("                / \\")
print("              mid1 mid2")
print("                \\ /")
print("                bot")
print()

diamond = CausalPoset(
    elements=["bot", "mid1", "mid2", "top"],
    covers=[("bot", "mid1"), ("bot", "mid2"), ("mid1", "top"), ("mid2", "top")]
)

boundary = ["mid1", "mid2"]
print(f"Boundary B = {boundary}")
print(f"Is antichain: {is_antichain(diamond, boundary)}")
print()

print("Profiles:")
for x in diamond.elements:
    p = past_profile(diamond, boundary, x)
    f = future_profile(diamond, boundary, x)
    print(f"  {x:5s}: past={set(p)}, future={set(f)}")

print()
print(f"Separation check: {check_separation(diamond, boundary)}")
print(f"Order reflection check: {check_order_reflection(diamond, boundary)}")
print(f"Interval generation check: {check_interval_generation(diamond, boundary)}")

print()
reconstruct_order(diamond, boundary)

# ============================================================
# Example 2: Linear chain (3 elements)
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 2: Linear Chain a < b < c")
print("=" * 60)
print()

chain = CausalPoset(
    elements=["a", "b", "c"],
    covers=[("a", "b"), ("b", "c")]
)

boundary = ["a", "c"]
print(f"Boundary B = {boundary}")
print(f"Is antichain: {is_antichain(chain, boundary)}")
print()

print("Profiles:")
for x in chain.elements:
    p = past_profile(chain, boundary, x)
    f = future_profile(chain, boundary, x)
    print(f"  {x}: past={set(p)}, future={set(f)}")

print()
print(f"Separation check: {check_separation(chain, boundary)}")
print(f"Order reflection check: {check_order_reflection(chain, boundary)}")
print(f"Interval generation check: {check_interval_generation(chain, boundary)}")

print()
reconstruct_order(chain, boundary)

# ============================================================
# Example 3: 2D grid / spacetime lattice
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 3: 2x3 Spacetime Grid")
print("=" * 60)
print()
print("  (0,2) (1,2)")
print("   |  \\/ |")
print("   |  /\\ |")
print("  (0,1) (1,1)")
print("   |  \\/ |")
print("   |  /\\ |")
print("  (0,0) (1,0)")
print()

# 2D grid: (i,j) ≤ (i',j') iff i≤i' and j≤j'
grid_elements = [f"({i},{j})" for i in range(2) for j in range(3)]
grid_covers = []
for i in range(2):
    for j in range(3):
        for di, dj in [(1, 0), (0, 1)]:
            ni, nj = i + di, j + dj
            if 0 <= ni < 2 and 0 <= nj < 3:
                # Check it's a cover (no intermediate)
                grid_covers.append((f"({i},{j})", f"({ni},{nj})"))

grid = CausalPoset(elements=grid_elements, covers=grid_covers)

# Use the "past boundary" (bottom row) and "future boundary" (top row)
boundary = ["(0,0)", "(1,0)", "(0,2)", "(1,2)"]
print(f"Boundary B = {boundary}")
print(f"Is antichain: {is_antichain(grid, boundary)}")
print()

print("Profiles:")
for x in grid_elements:
    p = past_profile(grid, boundary, x)
    f = future_profile(grid, boundary, x)
    print(f"  {x}: past={set(p)}, future={set(f)}")

print()
print(f"Separation check: {check_separation(grid, boundary)}")
print(f"Order reflection check: {check_order_reflection(grid, boundary)}")

print()
reconstruct_order(grid, boundary)

# ============================================================
# Example 4: Cover reconstruction
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 4: Cover Relation Reconstruction (Diamond)")
print("=" * 60)
print()

boundary = ["mid1", "mid2"]
print("Original cover relations:")
for x in diamond.elements:
    for y in diamond.elements:
        if diamond.is_cover(x, y):
            print(f"  {x} ⋖ {y}")

print("\nReconstructed cover relations (from profiles):")
profiles = {x: profile_pair(diamond, boundary, x) for x in diamond.elements}

for x in diamond.elements:
    for y in diamond.elements:
        px, fx = profiles[x]
        py, fy = profiles[y]
        # Check x < y in profile order
        if px.issubset(py) and fy.issubset(fx) and (px != py or fx != fy):
            # Check no z strictly between
            is_cover = True
            for z in diamond.elements:
                if z == x or z == y:
                    continue
                pz, fz = profiles[z]
                x_lt_z = (px.issubset(pz) and fz.issubset(fx) and (px != pz or fx != fz))
                z_lt_y = (pz.issubset(py) and fy.issubset(fz) and (pz != py or fz != fy))
                if x_lt_z and z_lt_y:
                    is_cover = False
                    break
            if is_cover:
                matches = "✓" if diamond.is_cover(x, y) else "✗"
                print(f"  {x} ⋖ {y}  {matches}")

# ============================================================
# Example 5: Alexandrov interval reconstruction
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 5: Interval Reconstruction (Diamond)")
print("=" * 60)
print()

x, y = "bot", "top"
print(f"Alexandrov interval [{x}, {y}]:")
interval = [z for z in diamond.elements if diamond.le(x, z) and diamond.le(z, y)]
print(f"  Original: {interval}")

# Reconstruct via profiles
px, fx = profiles[x]
py, fy = profiles[y]
reconstructed_interval = []
for z in diamond.elements:
    pz, fz = profiles[z]
    if px.issubset(pz) and fz.issubset(fx) and pz.issubset(py) and fy.issubset(fz):
        reconstructed_interval.append(z)

print(f"  Reconstructed: {reconstructed_interval}")
print(f"  Match: {set(interval) == set(reconstructed_interval)}")

print("\n" + "=" * 60)
print("All demonstrations complete!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Causal Holography

Generates figures illustrating the key concepts:
1. Diamond poset with boundary profiles
2. Profile embedding visualization
3. Reconstruction comparison
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import Poset, compute_all_profiles, reconstruct_covers
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def draw_poset_with_profiles():
    """Draw the diamond poset with boundary annotations and profiles."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 6))

    # Panel 1: Original poset
    ax = axes[0]
    ax.set_title("Original Causal Poset", fontsize=14, fontweight='bold')

    positions = {
        'bot': (0.5, 0), 'mid1': (0.2, 0.5),
        'mid2': (0.8, 0.5), 'top': (0.5, 1.0)
    }
    edges = [('bot', 'mid1'), ('bot', 'mid2'), ('mid1', 'top'), ('mid2', 'top')]

    for a, b in edges:
        ax.annotate("", xy=positions[b], xytext=positions[a],
                     arrowprops=dict(arrowstyle="->", color='gray', lw=1.5))

    boundary = ['mid1', 'mid2']
    for name, (x, y) in positions.items():
        color = '#FF6B6B' if name in boundary else '#4ECDC4'
        ax.plot(x, y, 'o', markersize=25, color=color, zorder=5)
        ax.text(x, y, name, ha='center', va='center', fontsize=8,
                fontweight='bold', zorder=6)

    legend_elements = [
        mpatches.Patch(color='#FF6B6B', label='Boundary'),
        mpatches.Patch(color='#4ECDC4', label='Bulk')
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=9)
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.15, 1.15)
    ax.set_aspect('equal')
    ax.axis('off')

    # Panel 2: Profile table
    ax = axes[1]
    ax.set_title("Boundary Profiles Φ_B", fontsize=14, fontweight='bold')

    diamond = Poset(
        elements=["bot", "mid1", "mid2", "top"],
        covers=[("bot", "mid1"), ("bot", "mid2"), ("mid1", "top"), ("mid2", "top")]
    )
    profiles = compute_all_profiles(diamond, boundary)

    table_data = []
    for x in ["bot", "mid1", "mid2", "top"]:
        p, f = profiles[x]
        table_data.append([x, str(set(p) if p else '∅'),
                           str(set(f) if f else '∅')])

    table = ax.table(cellText=table_data,
                     colLabels=['Element', 'Past Profile', 'Future Profile'],
                     loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1, 2)

    for (row, col), cell in table.get_celld().items():
        if row == 0:
            cell.set_facecolor('#2C3E50')
            cell.set_text_props(color='white', fontweight='bold')
        elif table_data[row-1][0] in boundary:
            cell.set_facecolor('#FFE0E0')
        else:
            cell.set_facecolor('#E0F5F2')

    ax.axis('off')

    # Panel 3: Reconstructed poset
    ax = axes[2]
    ax.set_title("Reconstructed Order\n(from profiles alone)", fontsize=14, fontweight='bold')

    covers = reconstruct_covers(profiles)
    for a, b in covers:
        ax.annotate("", xy=positions[b], xytext=positions[a],
                     arrowprops=dict(arrowstyle="->", color='#2ECC71', lw=2.5))

    for name, (x, y) in positions.items():
        ax.plot(x, y, 'o', markersize=25, color='#2ECC71', zorder=5)
        ax.text(x, y, name, ha='center', va='center', fontsize=8,
                fontweight='bold', zorder=6)

    ax.text(0.5, -0.1, "✓ Perfect reconstruction!", ha='center',
            fontsize=11, color='green', fontweight='bold')
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.2, 1.15)
    ax.set_aspect('equal')
    ax.axis('off')

    fig.suptitle("Causal Holography: Bulk Reconstruction from Boundary Data",
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_poset_profiles.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def draw_profile_embedding():
    """Visualize the profile embedding in 2D profile space."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    diamond = Poset(
        elements=["bot", "mid1", "mid2", "top"],
        covers=[("bot", "mid1"), ("bot", "mid2"), ("mid1", "top"), ("mid2", "top")]
    )
    boundary = ["mid1", "mid2"]
    profiles = compute_all_profiles(diamond, boundary)

    # Map profiles to coordinates: x = |past|, y = |B| - |future|
    coords = {}
    for name, (p, f) in profiles.items():
        x = len(p)
        y = len(boundary) - len(f)
        coords[name] = (x, y)

    # Draw edges
    edges = [("bot", "mid1"), ("bot", "mid2"), ("mid1", "top"), ("mid2", "top")]
    for a, b in edges:
        ax.annotate("", xy=coords[b], xytext=coords[a],
                     arrowprops=dict(arrowstyle="->", color='#BDC3C7', lw=2))

    # Draw points
    colors = {'bot': '#3498DB', 'mid1': '#E74C3C', 'mid2': '#E74C3C', 'top': '#3498DB'}
    for name, (x, y) in coords.items():
        color = colors[name]
        ax.plot(x, y, 'o', markersize=30, color=color, zorder=5)
        p, f = profiles[name]
        label = f"{name}\nP={set(p) if p else '∅'}\nF={set(f) if f else '∅'}"
        ax.annotate(label, (x, y), textcoords="offset points",
                    xytext=(35, 0), fontsize=8, ha='left',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    ax.set_xlabel("|Past Profile|", fontsize=13)
    ax.set_ylabel("|B| − |Future Profile|", fontsize=13)
    ax.set_title("Profile Embedding: Φ_B maps bulk points\nto (past size, complementary future size) space",
                 fontsize=14, fontweight='bold')
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2.5)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    fig.savefig('/workspace/request-project/fig_profile_embedding.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def draw_spacetime_reconstruction():
    """Visualize spacetime reconstruction from boundary slice."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 7))

    spacetime = Poset(
        elements=["(1,0)", "(0,1)", "(1,1)", "(2,1)", "(1,2)"],
        covers=[
            ("(1,0)", "(0,1)"), ("(1,0)", "(1,1)"), ("(1,0)", "(2,1)"),
            ("(0,1)", "(1,2)"), ("(1,1)", "(1,2)"), ("(2,1)", "(1,2)")
        ]
    )

    positions = {
        '(1,0)': (1, 0), '(0,1)': (0, 1), '(1,1)': (1, 1),
        '(2,1)': (2, 1), '(1,2)': (1, 2)
    }

    boundary = ["(0,1)", "(1,1)", "(2,1)"]

    # Panel 1: Original spacetime
    ax = axes[0]
    ax.set_title("Original Causal Diamond", fontsize=14, fontweight='bold')

    for a, b in spacetime.covers:
        xa, ya = positions[a]
        xb, yb = positions[b]
        ax.plot([xa, xb], [ya, yb], '-', color='gray', lw=1.5, zorder=1)

    for name, (x, y) in positions.items():
        color = '#FF6B6B' if name in boundary else '#4ECDC4'
        ax.plot(x, y, 'o', markersize=20, color=color, zorder=5)
        ax.text(x, y - 0.2, name, ha='center', va='top', fontsize=9)

    # Draw boundary slice
    ax.axhspan(0.9, 1.1, alpha=0.2, color='red', label='Boundary slice')
    ax.legend(fontsize=10)
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_xlabel("Space", fontsize=12)
    ax.set_ylabel("Time", fontsize=12)
    ax.set_aspect('equal')

    # Panel 2: Reconstructed spacetime
    ax = axes[1]
    ax.set_title("Reconstructed from Boundary\n(profiles alone)", fontsize=14, fontweight='bold')

    profiles = compute_all_profiles(spacetime, boundary)
    covers = reconstruct_covers(profiles)

    for a, b in covers:
        xa, ya = positions[a]
        xb, yb = positions[b]
        ax.plot([xa, xb], [ya, yb], '-', color='#2ECC71', lw=2.5, zorder=1)

    for name, (x, y) in positions.items():
        ax.plot(x, y, 'o', markersize=20, color='#2ECC71', zorder=5)
        ax.text(x, y - 0.2, name, ha='center', va='top', fontsize=9)

    ax.text(1, -0.3, "✓ Perfect match!", ha='center', fontsize=12,
            color='green', fontweight='bold')
    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_xlabel("Space", fontsize=12)
    ax.set_ylabel("Time", fontsize=12)
    ax.set_aspect('equal')

    fig.suptitle("Discrete Spacetime Holography:\nRecovering Causal Structure from a Spacelike Boundary Slice",
                 fontsize=15, fontweight='bold', y=1.05)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_spacetime_reconstruction.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = draw_poset_with_profiles()
    print(f"  fig_poset_profiles.png generated ({len(b64_1)} chars base64)")
    b64_2 = draw_profile_embedding()
    print(f"  fig_profile_embedding.png generated ({len(b64_2)} chars base64)")
    b64_3 = draw_spacetime_reconstruction()
    print(f"  fig_spacetime_reconstruction.png generated ({len(b64_3)} chars base64)")
    print("Done!")
