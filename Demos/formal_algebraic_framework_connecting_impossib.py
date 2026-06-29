#!/usr/bin/env python3
"""
Equivariant Impossibility Spectra — Numerical Demonstrations

Computes impossibility spectra for small finite groups acting on finite sets,
demonstrating fixed-point obstructions, upward closure, and orbit structure.
"""

from itertools import product
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


def cyclic_group_action(n: int, set_size: int) -> Dict[int, Dict[int, int]]:
    """
    Returns the action of Z/nZ on {0, ..., set_size-1} by cyclic rotation.
    action[g][x] = (x + g) mod set_size
    """
    return {g: {x: (x + g) % set_size for x in range(set_size)} for g in range(n)}


def fixed_points(action: Dict[int, Dict[int, int]], subgroup: Set[int],
                 elements: Set[int]) -> Set[int]:
    """Compute the fixed point set of a subgroup under an action."""
    return {x for x in elements if all(action[h][x] == x for h in subgroup)}


def subgroups_of_cyclic(n: int) -> List[Set[int]]:
    """Return all subgroups of Z/nZ."""
    result = []
    for d in range(1, n + 1):
        if n % d == 0:
            # Subgroup of order d: multiples of n/d
            step = n // d
            result.append({(k * step) % n for k in range(d)})
    return result


def is_equivariant(f: Dict[int, int], action_X: Dict[int, Dict[int, int]],
                    action_Y: Dict[int, Dict[int, int]],
                    subgroup: Set[int]) -> bool:
    """Check if f : X -> Y is H-equivariant."""
    return all(
        f[action_X[h][x]] == action_Y[h][f[x]]
        for h in subgroup
        for x in f.keys()
    )


def exists_equivariant_map(X: Set[int], Y: Set[int],
                            action_X: Dict[int, Dict[int, int]],
                            action_Y: Dict[int, Dict[int, int]],
                            subgroup: Set[int]) -> bool:
    """Check if any H-equivariant map X -> Y exists (brute force for small sets)."""
    X_list = sorted(X)
    Y_list = sorted(Y)
    for assignment in product(Y_list, repeat=len(X_list)):
        f = dict(zip(X_list, assignment))
        if is_equivariant(f, action_X, action_Y, subgroup):
            return True
    return False


def compute_impossibility_spectrum(
    n: int, X: Set[int], Y: Set[int],
    action_X: Dict[int, Dict[int, int]],
    action_Y: Dict[int, Dict[int, int]]
) -> List[Tuple[Set[int], bool]]:
    """Compute the impossibility spectrum for Z/nZ-sets X, Y."""
    subgroups = subgroups_of_cyclic(n)
    spectrum = []
    for H in subgroups:
        impossible = not exists_equivariant_map(X, Y, action_X, action_Y, H)
        spectrum.append((H, impossible))
    return spectrum


def demo_cyclic_6():
    """Demo: Z/6Z acting on sets of different sizes."""
    print("=" * 60)
    print("DEMO 1: Impossibility Spectrum for Z/6Z")
    print("=" * 60)

    n = 6
    # X = Z/6Z with regular action, Y = Z/3Z with action by mod 3
    X = set(range(6))
    Y = set(range(3))

    action_X = cyclic_group_action(6, 6)
    action_Y = {g: {y: (y + g) % 3 for y in range(3)} for g in range(6)}

    subgroups = subgroups_of_cyclic(6)
    print(f"\nSubgroups of Z/6Z:")
    for i, H in enumerate(subgroups):
        print(f"  H_{i} = {sorted(H)} (order {len(H)})")

    print(f"\nX = {sorted(X)} with regular Z/6Z-action")
    print(f"Y = {sorted(Y)} with Z/6Z-action via mod 3")

    print(f"\nFixed points and impossibility spectrum:")
    spectrum = compute_impossibility_spectrum(6, X, Y, action_X, action_Y)

    for i, (H, impossible) in enumerate(spectrum):
        fp_X = fixed_points(action_X, H, X)
        fp_Y = fixed_points(action_Y, H, Y)
        status = "IMPOSSIBLE" if impossible else "POSSIBLE"
        fp_obstruction = "YES" if (len(fp_X) > 0 and len(fp_Y) == 0) else "no"
        print(f"  H_{i} = {str(sorted(H)):20s}  |X^H| = {len(fp_X)}, |Y^H| = {len(fp_Y)}  "
              f"FP obstruction: {fp_obstruction:3s}  Status: {status}")

    # Verify upward closure
    print("\nVerifying upward closure:")
    impossible_set = {frozenset(H) for H, imp in spectrum if imp}
    for H, imp_H in spectrum:
        if imp_H:
            for K, imp_K in spectrum:
                if frozenset(H).issubset(frozenset(K)):
                    if not imp_K:
                        print(f"  VIOLATION: H={sorted(H)} ⊆ K={sorted(K)} but K not impossible!")
                    else:
                        print(f"  ✓ H={sorted(H)} ⊆ K={sorted(K)}, both impossible")


def demo_fixed_point_obstruction():
    """Demo: Fixed-point obstruction in action."""
    print("\n" + "=" * 60)
    print("DEMO 2: Fixed-Point Obstruction")
    print("=" * 60)

    # Z/4Z acting on X = {0,1,2,3} by rotation
    # Y = {0,1} with action: generator sends 0↦1, 1↦0
    n = 4
    X = set(range(4))
    Y = {0, 1}

    action_X = cyclic_group_action(4, 4)
    action_Y = {g: {0: g % 2, 1: (1 + g) % 2} for g in range(4)}

    subgroups = subgroups_of_cyclic(4)
    print(f"\nZ/4Z subgroups and fixed-point analysis:")
    print(f"X = {sorted(X)} with cyclic rotation")
    print(f"Y = {sorted(Y)} with mod-2 action")

    for i, H in enumerate(subgroups):
        fp_X = fixed_points(action_X, H, X)
        fp_Y = fixed_points(action_Y, H, Y)
        can_map = exists_equivariant_map(X, Y, action_X, action_Y, H)
        print(f"\n  H_{i} = {sorted(H)} (order {len(H)})")
        print(f"    X^H = {sorted(fp_X)}, Y^H = {sorted(fp_Y)}")
        print(f"    Equivariant map exists: {can_map}")
        if len(fp_X) > 0 and len(fp_Y) == 0:
            print(f"    → Fixed-point obstruction detected!")


def demo_orbit_structure():
    """Demo: Orbit structure analysis."""
    print("\n" + "=" * 60)
    print("DEMO 3: Orbit Structure Analysis")
    print("=" * 60)

    n = 4
    X = set(range(4))
    action = cyclic_group_action(4, 4)

    # Compute orbits
    visited = set()
    orbits = []
    for x in sorted(X):
        if x not in visited:
            orb = {action[g][x] for g in range(n)}
            orbits.append(orb)
            visited.update(orb)

    print(f"\nZ/4Z acting on {sorted(X)} by cyclic rotation:")
    print(f"Orbits: {[sorted(o) for o in orbits]}")
    print(f"Number of orbits: {len(orbits)}")

    # Different target: 2 elements with trivial action
    Y = {0, 1}
    action_Y = {g: {y: y for y in Y} for g in range(n)}

    print(f"\nTarget Y = {sorted(Y)} with trivial action:")
    Y_orbits = [{y} for y in sorted(Y)]
    print(f"Y-Orbits: {Y_orbits}")
    print(f"Orbit sizes in X: {[len(o) for o in orbits]}")
    print(f"Orbit sizes in Y: {[len(o) for o in Y_orbits]}")
    print(f"\nSince X has an orbit of size 4 but Y only has orbits of size 1,")
    print(f"a G-equivariant map must collapse the entire orbit to a single point.")

    can_map = exists_equivariant_map(X, Y, action, action_Y, set(range(n)))
    print(f"G-equivariant map exists: {can_map}")
    print(f"(Yes — the constant map works since Y has trivial action)")


def demo_transfer_principle():
    """Demo: Transfer principle — equivariantly equivalent sets have same spectrum."""
    print("\n" + "=" * 60)
    print("DEMO 4: Transfer Principle")
    print("=" * 60)

    n = 3  # Z/3Z
    # X1 = {0,1,2} with regular action
    X1 = set(range(3))
    action_X1 = cyclic_group_action(3, 3)

    # X2 = {a,b,c} ≅ {10,11,12} with "same" action but relabeled
    X2 = {10, 11, 12}
    relabel = {0: 10, 1: 11, 2: 12}
    action_X2 = {g: {relabel[x]: relabel[action_X1[g][x]] for x in range(3)} for g in range(3)}

    # Y = {0} with trivial action
    Y = {0}
    action_Y = {g: {0: 0} for g in range(3)}

    subgroups = subgroups_of_cyclic(3)

    print(f"\nZ/3Z acting on X1={sorted(X1)} and X2={sorted(X2)} (equivariantly isomorphic)")
    print(f"Target Y={sorted(Y)} with trivial action")

    print(f"\nImpossibility spectra:")
    for i, H in enumerate(subgroups):
        imp1 = not exists_equivariant_map(X1, Y, action_X1, action_Y, H)
        imp2 = not exists_equivariant_map(X2, Y, action_X2, action_Y, H)
        match_str = "✓ MATCH" if imp1 == imp2 else "✗ MISMATCH"
        print(f"  H={str(sorted(H)):15s}  X1: {'IMPOSSIBLE' if imp1 else 'POSSIBLE':10s}  "
              f"X2: {'IMPOSSIBLE' if imp2 else 'POSSIBLE':10s}  {match_str}")


if __name__ == "__main__":
    demo_cyclic_6()
    demo_fixed_point_obstruction()
    demo_orbit_structure()
    demo_transfer_principle()


#!/usr/bin/env python3
"""
Visualization: Subgroup lattice with impossibility spectrum coloring.

Displays the subgroup lattice of Z/nZ with subgroups colored by whether they
belong to the impossibility spectrum for a given pair of G-sets.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product as itertools_product


def subgroups_of_cyclic(n):
    result = []
    for d in range(1, n + 1):
        if n % d == 0:
            step = n // d
            result.append(frozenset((k * step) % n for k in range(d)))
    return result


def is_equivariant(f, action_X, action_Y, subgroup):
    return all(
        f[action_X[h][x]] == action_Y[h][f[x]]
        for h in subgroup for x in f.keys()
    )


def compute_spectrum(n, X, Y, action_X, action_Y, subgroups):
    spectrum = set()
    for H in subgroups:
        X_list = sorted(X)
        Y_list = sorted(Y)
        found = False
        for assignment in itertools_product(Y_list, repeat=len(X_list)):
            f = dict(zip(X_list, assignment))
            if is_equivariant(f, action_X, action_Y, H):
                found = True
                break
        if not found:
            spectrum.add(H)
    return spectrum


def plot_subgroup_lattice_with_spectrum(n, spectrum, subgroups, title=""):
    """Plot the subgroup lattice with spectrum coloring."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Position subgroups by order (y-axis) and spread horizontally
    order_groups = {}
    for H in subgroups:
        order = len(H)
        if order not in order_groups:
            order_groups[order] = []
        order_groups[order].append(H)

    positions = {}
    for order, groups in order_groups.items():
        y = np.log2(order) if order > 0 else 0
        for i, H in enumerate(groups):
            x = (i - (len(groups) - 1) / 2) * 2
            positions[H] = (x, y)

    # Draw edges (Hasse diagram)
    for H in subgroups:
        for K in subgroups:
            if H < K and len(K) > len(H):
                # Check if K covers H (no intermediate subgroup)
                is_cover = True
                for M in subgroups:
                    if H < M and M < K:
                        is_cover = False
                        break
                if is_cover:
                    x1, y1 = positions[H]
                    x2, y2 = positions[K]
                    ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1.5)

    # Draw nodes
    for H in subgroups:
        x, y = positions[H]
        color = '#ff4444' if H in spectrum else '#44aa44'
        edge_color = '#cc0000' if H in spectrum else '#228822'
        size = 800

        ax.scatter(x, y, s=size, c=color, edgecolors=edge_color,
                   linewidth=2, zorder=5)
        label = f"|H|={len(H)}\n{sorted(H)}"
        ax.annotate(label, (x, y), textcoords="offset points",
                    xytext=(0, -35), ha='center', fontsize=8,
                    fontweight='bold')

    # Legend
    possible_patch = mpatches.Patch(color='#44aa44', label='Possible (equivariant map exists)')
    impossible_patch = mpatches.Patch(color='#ff4444', label='Impossible (in spectrum)')
    ax.legend(handles=[possible_patch, impossible_patch], loc='upper left', fontsize=11)

    ax.set_title(title or f"Impossibility Spectrum on Sub(Z/{n}Z)", fontsize=14, fontweight='bold')
    ax.set_xlabel("Horizontal spread", fontsize=10)
    ax.set_ylabel("log₂(subgroup order)", fontsize=10)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig("subgroup_lattice_spectrum.png", dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved to subgroup_lattice_spectrum.png")


if __name__ == "__main__":
    n = 12
    subgroups = subgroups_of_cyclic(n)

    # X = Z/12Z with regular action, Y = Z/4Z with mod-4 action
    X = set(range(12))
    Y = set(range(4))
    action_X = {g: {x: (x + g) % 12 for x in range(12)} for g in range(12)}
    action_Y = {g: {y: (y + g) % 4 for y in range(4)} for g in range(12)}

    spectrum = compute_spectrum(n, X, Y, action_X, action_Y, subgroups)

    print(f"Subgroups of Z/{n}Z:")
    for H in subgroups:
        status = "IMPOSSIBLE" if H in spectrum else "POSSIBLE"
        print(f"  {sorted(H)} (order {len(H)}): {status}")

    plot_subgroup_lattice_with_spectrum(
        n, spectrum, subgroups,
        title=f"Impossibility Spectrum: Z/12Z → Z/4Z"
    )
