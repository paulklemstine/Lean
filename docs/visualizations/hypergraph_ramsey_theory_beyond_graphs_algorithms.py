"""
Hypergraph Ramsey Theory: Algorithms and Data Structures

Type-hinted implementations of key algorithms for computing and bounding
hypergraph Ramsey numbers, tower functions, and Ramsey density spectra.
"""

from typing import List, Tuple, Dict, Set, Optional, Callable
from itertools import combinations
from functools import lru_cache
import math


def tower_exp(base: int, height: int) -> int:
    """Compute the tower function: tower(b, 0) = 1, tower(b, n+1) = b^tower(b, n).

    >>> tower_exp(2, 0)
    1
    >>> tower_exp(2, 1)
    2
    >>> tower_exp(2, 2)
    4
    >>> tower_exp(2, 3)
    16
    >>> tower_exp(2, 4)
    65536
    """
    if height == 0:
        return 1
    return base ** tower_exp(base, height - 1)


def num_hyperedges(n: int, r: int) -> int:
    """Number of r-element subsets of an n-element set."""
    return math.comb(n, r)


def expected_mono_cliques(n: int, r: int, k: int) -> float:
    """Expected number of monochromatic k-cliques in a random 2-coloring
    of r-subsets of [n].

    Each k-subset has C(k,r) hyperedges. Probability of being monochromatic
    in one color is 2^{1 - C(k,r)}. Number of k-subsets is C(n,k).
    """
    edges_in_clique = math.comb(k, r)
    prob_mono = 2.0 * (0.5 ** edges_in_clique)
    num_potential = math.comb(n, k)
    return num_potential * prob_mono


def probabilistic_lower_bound(r: int, k: int) -> int:
    """Find the largest n such that E[mono cliques] < 1.

    This gives a lower bound: R_r(k,k) > n.
    Uses the first moment method (probabilistic method).
    """
    n = k
    while expected_mono_cliques(n, r, k) < 1.0:
        n += 1
    return n - 1


def stepping_up_upper_bound(r: int, k: int, graph_ramsey: int) -> int:
    """Upper bound on R_r(k,k) via the stepping-up lemma.

    R_{r+1}(k+1, k+1) <= 2^{R_r(k,k)} + 1
    Starting from R_2(k,k) and applying (r-2) times.
    """
    current = graph_ramsey
    for _ in range(r - 2):
        current = 2 ** current + 1
    return current


class HypergraphColoring:
    """A 2-coloring of r-element subsets of [n]."""

    def __init__(self, n: int, r: int, color_fn: Callable[..., bool]):
        self.n = n
        self.r = r
        self.color_fn = color_fn

    def color(self, edge: Tuple[int, ...]) -> bool:
        """Return the color of a hyperedge (sorted tuple of r elements)."""
        return self.color_fn(edge)

    def is_monochromatic(self, subset: Set[int], col: bool) -> bool:
        """Check if all r-subsets of `subset` have color `col`."""
        for edge in combinations(sorted(subset), self.r):
            if self.color(edge) != col:
                return False
        return True

    def largest_mono_clique(self, col: bool) -> Set[int]:
        """Find the largest monochromatic clique of given color (brute force)."""
        vertices = list(range(self.n))
        best: Set[int] = set()
        for size in range(len(vertices), 0, -1):
            if size <= len(best):
                break
            for subset in combinations(vertices, size):
                s = set(subset)
                if self.is_monochromatic(s, col):
                    best = s
                    break
        return best


class RamseyDensitySpectrum:
    """The Ramsey density spectrum of a coloring.

    Captures the sizes of the largest monochromatic cliques in each color
    and computes the Ramsey density = max(red, blue) / n.
    """

    def __init__(self, coloring: HypergraphColoring):
        self.coloring = coloring
        self.red_clique = coloring.largest_mono_clique(True)
        self.blue_clique = coloring.largest_mono_clique(False)
        self.max_red = len(self.red_clique)
        self.max_blue = len(self.blue_clique)

    @property
    def density(self) -> float:
        """The Ramsey density: max(red, blue) / n."""
        if self.coloring.n == 0:
            return 0.0
        return max(self.max_red, self.max_blue) / self.coloring.n

    @property
    def balance(self) -> float:
        """Balance ratio: min(red, blue) / max(red, blue).
        A balanced coloring has ratio close to 1."""
        mx = max(self.max_red, self.max_blue)
        if mx == 0:
            return 1.0
        return min(self.max_red, self.max_blue) / mx


def check_ramsey_prop(n: int, r: int, k: int, l: int,
                      max_colorings: int = 10000) -> Tuple[bool, Optional[Dict]]:
    """Check the hypergraph Ramsey property by sampling random colorings.

    Returns (result, counterexample_or_None).
    Note: This is a probabilistic check, not exhaustive.
    """
    import random
    edges = list(combinations(range(n), r))

    for trial in range(max_colorings):
        # Random coloring
        assignment = {e: random.random() < 0.5 for e in edges}
        coloring = HypergraphColoring(n, r, lambda e, a=assignment: a[e])

        has_red_k = False
        has_blue_l = False

        for subset in combinations(range(n), k):
            if coloring.is_monochromatic(set(subset), True):
                has_red_k = True
                break

        if not has_red_k:
            for subset in combinations(range(n), l):
                if coloring.is_monochromatic(set(subset), False):
                    has_blue_l = True
                    break

        if not has_red_k and not has_blue_l:
            return False, {"trial": trial, "assignment": assignment}

    return True, None


def compute_ramsey_bounds(r: int, k: int) -> Dict[str, int]:
    """Compute lower and upper bounds on R_r(k,k).

    Lower bound: probabilistic method (first moment).
    Upper bound: stepping-up from known graph Ramsey numbers.
    """
    # Known graph Ramsey numbers R_2(k,k)
    known_graph_ramsey = {
        3: 6, 4: 18, 5: 43, 6: 102, 7: 205, 8: 282,
    }

    lower = probabilistic_lower_bound(r, k)

    if k in known_graph_ramsey:
        upper = stepping_up_upper_bound(r, k, known_graph_ramsey[k])
    else:
        # Use R_2(k,k) <= 4^k as fallback
        upper = stepping_up_upper_bound(r, k, 4**k)

    return {
        "r": r,
        "k": k,
        "lower_bound": lower,
        "upper_bound": upper,
        "ratio": upper / lower if lower > 0 else float('inf'),
    }


def growth_rate_analysis(r: int, max_k: int = 8) -> List[Dict]:
    """Analyze the growth rate of R_r(k,k) for k = 3, ..., max_k."""
    results = []
    for k in range(3, max_k + 1):
        bounds = compute_ramsey_bounds(r, k)
        log_lower = math.log2(bounds["lower_bound"]) if bounds["lower_bound"] > 0 else 0
        log_upper = math.log2(bounds["upper_bound"]) if bounds["upper_bound"] > 0 else 0
        bounds["log2_lower"] = log_lower
        bounds["log2_upper"] = log_upper
        bounds["log2_lower_over_k2"] = log_lower / k**2 if k > 0 else 0
        bounds["log2_upper_over_k"] = log_upper / k if k > 0 else 0
        results.append(bounds)
    return results


if __name__ == "__main__":
    # Quick self-test
    print("Tower function values:")
    for h in range(6):
        print(f"  tower(2, {h}) = {tower_exp(2, h)}")

    print("\nProbabilistic lower bounds on R_r(k,k):")
    for r in [2, 3, 4]:
        for k in [3, 4, 5, 6]:
            lb = probabilistic_lower_bound(r, k)
            print(f"  R_{r}({k},{k}) >= {lb}")

    print("\n3-uniform growth rate analysis:")
    for entry in growth_rate_analysis(3, 7):
        print(f"  k={entry['k']}: [{entry['lower_bound']}, {entry['upper_bound']}]"
              f" ratio={entry['ratio']:.1f}")
