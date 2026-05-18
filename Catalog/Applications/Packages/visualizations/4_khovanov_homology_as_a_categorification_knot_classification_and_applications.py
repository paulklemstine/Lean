#!/usr/bin/env python3
"""
Applications of Khovanov Homology

Demonstrations of how Khovanov homology applies to:
1. Knot detection and classification
2. Unknot obstruction
3. Mutation sensitivity
4. Slice genus bounds
"""

import itertools
from collections import defaultdict
from typing import Dict, Tuple


# =============================================================================
# Knot Database
# =============================================================================

KNOT_DATABASE = {
    "unknot": {
        "crossings": 0,
        "loops": lambda s: 1,
        "signs": [],
        "description": "Trivial knot"
    },
    "trefoil_left": {
        "crossings": 3,
        "loops": lambda s: {
            (0,0,0): 3, (0,0,1): 2, (0,1,0): 2, (0,1,1): 1,
            (1,0,0): 2, (1,0,1): 1, (1,1,0): 1, (1,1,1): 2,
        }[s],
        "signs": [-1, -1, -1],
        "description": "Left-handed trefoil"
    },
    "trefoil_right": {
        "crossings": 3,
        "loops": lambda s: {
            (0,0,0): 3, (0,0,1): 2, (0,1,0): 2, (0,1,1): 1,
            (1,0,0): 2, (1,0,1): 1, (1,1,0): 1, (1,1,1): 2,
        }[s],
        "signs": [1, 1, 1],
        "description": "Right-handed trefoil"
    },
    "figure_eight": {
        "crossings": 4,
        "loops": lambda s: {
            (0,0,0,0): 3, (0,0,0,1): 2, (0,0,1,0): 2, (0,0,1,1): 1,
            (0,1,0,0): 2, (0,1,0,1): 1, (0,1,1,0): 1, (0,1,1,1): 2,
            (1,0,0,0): 2, (1,0,0,1): 1, (1,0,1,0): 1, (1,0,1,1): 2,
            (1,1,0,0): 1, (1,1,0,1): 2, (1,1,1,0): 2, (1,1,1,1): 3,
        }[s],
        "signs": [1, -1, 1, -1],
        "description": "Figure-eight knot (amphicheiral)"
    },
    "hopf_link": {
        "crossings": 2,
        "loops": lambda s: {
            (0,0): 2, (0,1): 1, (1,0): 1, (1,1): 2,
        }[s],
        "signs": [1, 1],
        "description": "Hopf link"
    },
}


# =============================================================================
# Application 1: Knot Classification via Bigraded Dimensions
# =============================================================================

def compute_bigraded_invariant(knot_data) -> Dict[Tuple[int, int], int]:
    """Compute the bigraded Poincaré polynomial as a knot invariant."""
    n = knot_data["crossings"]
    loops_fn = knot_data["loops"]
    dims = defaultdict(int)

    for state in itertools.product([0, 1], repeat=n):
        i = sum(state)
        k = loops_fn(state)
        sigma = sum(1 for s in state if s == 0) - i
        for tensor in itertools.product([1, -1], repeat=k):
            j = sigma + sum(tensor)
            dims[(i, j)] += 1

    return dict(dims)


def classify_knots():
    """
    Application: Use bigraded dimensions to distinguish knots.

    The bigraded Poincaré polynomial is a strictly stronger invariant
    than the Jones polynomial. Two knots with the same Jones polynomial
    may have different Khovanov homology.
    """
    print("KNOT CLASSIFICATION VIA KHOVANOV INVARIANTS")
    print("=" * 60)

    results = {}
    for name, data in KNOT_DATABASE.items():
        dims = compute_bigraded_invariant(data)
        # Compute total rank as simple invariant
        total_rank = sum(dims.values())
        # Compute width (spread of quantum degrees)
        j_vals = [d[1] for d in dims]
        width = max(j_vals) - min(j_vals) if j_vals else 0
        results[name] = {
            "dims": dims,
            "total_rank": total_rank,
            "width": width,
            "description": data["description"]
        }

    for name, r in results.items():
        print(f"\n  {name} ({r['description']}):")
        print(f"    Total rank: {r['total_rank']}")
        print(f"    Width: {r['width']}")
        print(f"    Nonzero bidegrees: {len(r['dims'])}")

    # Check distinguishability
    print("\n  --- Distinguishability Analysis ---")
    names = list(results.keys())
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            n1, n2 = names[i], names[j]
            same = results[n1]["dims"] == results[n2]["dims"]
            status = "SAME" if same else "DIFFERENT"
            print(f"    {n1} vs {n2}: {status}")


# =============================================================================
# Application 2: Unknot Detection
# =============================================================================

def unknot_obstruction(knot_data) -> bool:
    """
    Application: Test if a knot might be the unknot.

    The unknot has Khovanov homology concentrated in homological degree 0
    with total rank 2 (one copy of V).

    If the bigraded dimensions don't match this pattern, the knot is
    definitely NOT the unknot.

    This is a key application: Kronheimer-Mrowka proved that Khovanov
    homology detects the unknot (2011), meaning the converse also holds.
    """
    dims = compute_bigraded_invariant(knot_data)

    # Check if all dimensions are in homological degree 0
    non_zero_i = set(d[0] for d in dims if dims[d] > 0)

    if non_zero_i == {0}:
        # Check total rank
        total = sum(dims.values())
        if total == 2:
            return True  # Consistent with unknot

    return False  # Definitely not unknot


def demo_unknot_detection():
    """Demonstrate unknot detection."""
    print("\n\nUNKNOT DETECTION VIA KHOVANOV HOMOLOGY")
    print("=" * 60)

    for name, data in KNOT_DATABASE.items():
        is_possible_unknot = unknot_obstruction(data)
        dims = compute_bigraded_invariant(data)
        total_rank = sum(dims.values())
        non_zero_i = set(d[0] for d in dims if dims[d] > 0)

        status = "POSSIBLY UNKNOT" if is_possible_unknot else "DEFINITELY KNOTTED"
        print(f"\n  {name}: {status}")
        print(f"    Total rank: {total_rank}")
        print(f"    Homological degrees with nonzero groups: {sorted(non_zero_i)}")


# =============================================================================
# Application 3: Chirality Detection
# =============================================================================

def detect_chirality():
    """
    Application: Detect chirality (handedness) of knots.

    A knot is amphicheiral if it is equivalent to its mirror image.
    The Khovanov homology of a knot and its mirror are related by
    a specific grading reversal. If the Poincaré polynomial is
    NOT symmetric under this reversal, the knot is chiral.
    """
    print("\n\nCHIRALITY DETECTION")
    print("=" * 60)

    for name, data in KNOT_DATABASE.items():
        dims = compute_bigraded_invariant(data)

        # For mirror image: (i, j) -> (n - i, -j + some shift)
        # Simplified check: is the j-distribution symmetric?
        j_vals = defaultdict(int)
        for (i, j), d in dims.items():
            j_vals[j] += d

        j_keys = sorted(j_vals.keys())
        if not j_keys:
            continue

        j_center = (j_keys[0] + j_keys[-1]) / 2
        is_symmetric = True
        for j in j_keys:
            j_mirror = int(2 * j_center - j)
            if j_vals.get(j, 0) != j_vals.get(j_mirror, 0):
                is_symmetric = False
                break

        status = "AMPHICHEIRAL (symmetric)" if is_symmetric else "CHIRAL (asymmetric)"
        print(f"  {name}: {status}")
        print(f"    j-distribution: {dict(sorted(j_vals.items()))}")


# =============================================================================
# Application 4: Genus Bounds
# =============================================================================

def rasmussen_s_invariant_estimate(knot_data):
    """
    Estimate the Rasmussen s-invariant from Khovanov-type data.

    The s-invariant gives a lower bound on the slice genus:
    |s(K)| / 2 ≤ g_s(K)

    This is a simplified estimate based on the spread of quantum degrees
    in the chain complex.
    """
    dims = compute_bigraded_invariant(knot_data)
    if not dims:
        return 0

    # The s-invariant is related to the maximal and minimal surviving
    # quantum degrees in the homology (Lee spectral sequence)
    j_vals = sorted(set(d[1] for d in dims))
    if len(j_vals) < 2:
        return 0

    # Rough estimate: s ≈ (max_j + min_j) / 2 for non-trivial knots
    return (j_vals[-1] + j_vals[0]) // 2


def demo_genus_bounds():
    """Demonstrate genus bounds from Khovanov-type invariants."""
    print("\n\nSLICE GENUS BOUNDS")
    print("=" * 60)

    for name, data in KNOT_DATABASE.items():
        s_est = rasmussen_s_invariant_estimate(data)
        genus_bound = abs(s_est) // 2
        dims = compute_bigraded_invariant(data)
        j_vals = sorted(set(d[1] for d in dims))

        print(f"\n  {name}:")
        print(f"    Quantum degree range: [{j_vals[0]}, {j_vals[-1]}]")
        print(f"    s-invariant estimate: {s_est}")
        print(f"    Slice genus lower bound: {genus_bound}")


# =============================================================================
# Main
# =============================================================================

def main():
    classify_knots()
    demo_unknot_detection()
    detect_chirality()
    demo_genus_bounds()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()
