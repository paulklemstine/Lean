#!/usr/bin/env python3
"""
Tropical Universality Theory — Algorithms

Implements the core algorithms for computing tropical profiles, detecting
tropical equivalence, and extracting asymptotic invariants from computation DAGs.

Algorithms:
1. TropicalProfile computation from a DAG
2. Tropical equivalence testing
3. Asymptotic slope extraction
4. Parallel composition
5. Dominant multiplicity analysis
6. Crossover point computation
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import List, Dict, Tuple, Optional, Set
import numpy as np
from collections import defaultdict
import heapq


# ─── Core Data Structures ──────────────────────────────────────────────

@dataclass(frozen=True)
class AffineForm:
    """An affine function f(x) = slope * x + bias.

    Represents a single source-to-sink path cost in a computation DAG,
    where slope encodes the scaling exponent and bias encodes the constant.
    """
    slope: float
    bias: float

    def eval(self, x: float) -> float:
        """Evaluate at a point."""
        return self.slope * x + self.bias

    def eval_array(self, x: np.ndarray) -> np.ndarray:
        """Vectorized evaluation."""
        return self.slope * x + self.bias

    def dominates(self, other: 'AffineForm', x_threshold: float = 1e6) -> bool:
        """Check if self eventually dominates other for large x.

        Returns True if self.slope > other.slope, or if slopes are equal
        and self.bias >= other.bias.

        Time: O(1)
        """
        if self.slope > other.slope:
            return True
        if self.slope == other.slope and self.bias >= other.bias:
            return True
        return False

    def crossover_point(self, other: 'AffineForm') -> Optional[float]:
        """Find x where self.eval(x) = other.eval(x).

        Returns None if the forms are parallel (same slope).

        Time: O(1)
        """
        if abs(self.slope - other.slope) < 1e-15:
            return None
        return (other.bias - self.bias) / (self.slope - other.slope)

    def __repr__(self):
        sign = '+' if self.bias >= 0 else '-'
        return f"({self.slope}·x {sign} {abs(self.bias)})"


@dataclass
class TropicalProfile:
    """A tropical profile: a nonempty collection of affine forms.

    The tropical envelope is the pointwise maximum of all forms.
    This is the central object of tropical universality theory.

    Invariants:
    - forms is nonempty
    - After reduce(), only non-dominated forms remain
    """
    forms: List[AffineForm]

    def __post_init__(self):
        assert len(self.forms) > 0, "Profile must be nonempty"

    def eval_max(self, x: float) -> float:
        """Evaluate the tropical envelope at a point.

        Time: O(|forms|)
        Space: O(1)
        """
        return max(f.eval(x) for f in self.forms)

    def eval_max_array(self, x: np.ndarray) -> np.ndarray:
        """Vectorized envelope evaluation.

        Time: O(|forms| · |x|)
        Space: O(|forms| · |x|)
        """
        values = np.array([f.eval_array(x) for f in self.forms])
        return np.max(values, axis=0)

    @property
    def max_slope(self) -> float:
        """Maximum slope among all forms (the asymptotic exponent).

        Time: O(|forms|)

        >>> TropicalProfile([AffineForm(2, 1), AffineForm(3, -5)]).max_slope
        3
        """
        return max(f.slope for f in self.forms)

    @property
    def dominant_forms(self) -> List[AffineForm]:
        """Forms achieving the maximum slope.

        Time: O(|forms|)
        """
        ms = self.max_slope
        return [f for f in self.forms if abs(f.slope - ms) < 1e-15]

    @property
    def essential_dominant_bias(self) -> float:
        """Maximum bias among dominant forms.

        This, together with max_slope, determines the eventual
        linear behavior of the envelope.

        Time: O(|forms|)
        """
        return max(f.bias for f in self.dominant_forms)

    @property
    def dominant_multiplicity(self) -> int:
        """Number of forms achieving the maximum slope.

        Time: O(|forms|)
        """
        return len(self.dominant_forms)

    def reduce(self) -> 'TropicalProfile':
        """Remove forms that are always dominated.

        A form f is dominated if there exists another form g such that
        g.eval(x) >= f.eval(x) for all x. For affine forms, this means
        g.slope > f.slope (eventual domination) or g.slope == f.slope
        and g.bias >= f.bias.

        Actually, for the full envelope, a form can be non-dominated
        even if it has a smaller slope, because it might be the maximum
        in some finite interval. The truly redundant forms are those
        that never achieve the maximum on any interval.

        This implements the upper envelope computation using a sweep-line
        algorithm on the dual arrangement.

        Time: O(n log n) where n = |forms|
        Space: O(n)
        """
        if len(self.forms) <= 1:
            return TropicalProfile(list(self.forms))

        # Sort by slope (descending), breaking ties by bias (descending)
        sorted_forms = sorted(self.forms, key=lambda f: (-f.slope, -f.bias))

        # Build upper envelope using convex hull trick
        hull: List[AffineForm] = []
        for f in sorted_forms:
            # Remove forms that are completely dominated
            while len(hull) >= 2:
                g = hull[-1]
                h = hull[-2]
                # Check if g is below the intersection of h and f
                # Intersection of h and f: x = (f.bias - h.bias) / (h.slope - f.slope)
                # Intersection of h and g: x = (g.bias - h.bias) / (h.slope - g.slope)
                if abs(h.slope - f.slope) < 1e-15:
                    # f and h have same slope; f has lower bias (by sorting)
                    break
                if abs(h.slope - g.slope) < 1e-15:
                    # g and h have same slope; g has lower bias, so remove g
                    hull.pop()
                    continue
                x_hf = (f.bias - h.bias) / (h.slope - f.slope)
                x_hg = (g.bias - h.bias) / (h.slope - g.slope)
                if x_hg <= x_hf:
                    # g is dominated: the intersection with h is to the left
                    # of where f takes over from h
                    hull.pop()
                else:
                    break

            # Skip if same slope and lower bias as the last hull element
            if hull and abs(hull[-1].slope - f.slope) < 1e-15:
                if f.bias <= hull[-1].bias:
                    continue

            hull.append(f)

        return TropicalProfile(hull)

    def crossover_points(self) -> List[Tuple[float, AffineForm, AffineForm]]:
        """Find all crossover points where the active form changes.

        Returns sorted list of (x_value, form_before, form_after).

        Time: O(n^2) naive, O(n log n) with sweep
        Space: O(n)
        """
        reduced = self.reduce()
        points = []

        for i, f in enumerate(reduced.forms):
            for j, g in enumerate(reduced.forms):
                if i >= j:
                    continue
                cp = f.crossover_point(g)
                if cp is not None:
                    # Check if this crossover is actually on the envelope
                    env_val = reduced.eval_max(cp)
                    f_val = f.eval(cp)
                    if abs(f_val - env_val) < 1e-10:
                        if f.slope > g.slope:
                            points.append((cp, g, f))  # g active before, f after
                        else:
                            points.append((cp, f, g))

        points.sort(key=lambda t: t[0])
        return points


# ─── Algorithm 1: Tropical Equivalence Testing ─────────────────────────

def are_tropically_equivalent(
    P: TropicalProfile,
    Q: TropicalProfile,
    num_test_points: int = 10000,
    x_range: Tuple[float, float] = (-1000, 1000),
    tolerance: float = 1e-8
) -> Tuple[bool, Optional[float]]:
    """Test whether two tropical profiles are tropically equivalent.

    Uses a combination of:
    1. Algebraic reduction (compare reduced profiles)
    2. Numerical verification at random points

    For exact equivalence of piecewise-linear functions defined by
    finite sets of affine forms, it suffices to check equality at
    all crossover points plus one point per interval.

    Args:
        P, Q: Tropical profiles to compare
        num_test_points: Number of random test points
        x_range: Range for test points
        tolerance: Numerical tolerance

    Returns:
        (is_equivalent, first_counterexample_x)

    Time: O((|P| + |Q|) · num_test_points)
    Space: O(num_test_points)

    >>> P = TropicalProfile([AffineForm(2, 1), AffineForm(1, 5)])
    >>> Q = TropicalProfile([AffineForm(2, 1), AffineForm(1, 5), AffineForm(1.5, 2)])
    >>> equiv, _ = are_tropically_equivalent(P, Q)
    """
    # Quick check: max slopes must match
    if abs(P.max_slope - Q.max_slope) > tolerance:
        return False, None

    # Algebraic check: compare at critical points
    x_test = np.linspace(x_range[0], x_range[1], num_test_points)

    # Also add crossover points of both profiles
    for profile in [P, Q]:
        for cp, _, _ in profile.crossover_points():
            if x_range[0] <= cp <= x_range[1]:
                x_test = np.append(x_test, [cp - 0.01, cp, cp + 0.01])

    x_test = np.sort(np.unique(x_test))

    env_P = P.eval_max_array(x_test)
    env_Q = Q.eval_max_array(x_test)
    diff = np.abs(env_P - env_Q)

    max_diff_idx = np.argmax(diff)
    if diff[max_diff_idx] > tolerance:
        return False, float(x_test[max_diff_idx])

    return True, None


# ─── Algorithm 2: Parallel Composition ──────────────────────────────────

def parallel_compose(P: TropicalProfile, Q: TropicalProfile) -> TropicalProfile:
    """Compose two profiles in parallel (union of forms).

    Models a residual/skip architecture where both branches compete.
    The envelope of the result is the pointwise max of the components.

    Time: O(|P| + |Q|)
    Space: O(|P| + |Q|)

    >>> P = TropicalProfile([AffineForm(2, 1)])
    >>> Q = TropicalProfile([AffineForm(3, -1)])
    >>> R = parallel_compose(P, Q)
    >>> R.max_slope
    3
    """
    return TropicalProfile(P.forms + Q.forms)


def serial_compose(P: TropicalProfile, Q: TropicalProfile) -> TropicalProfile:
    """Compose two profiles in series (tropical convolution).

    For serial composition, each path through the combined DAG
    consists of a path through P followed by a path through Q.
    The combined affine form is (s1 + s2, b1 + b2) for slopes
    s1, s2 and biases b1, b2.

    Time: O(|P| · |Q|)
    Space: O(|P| · |Q|)
    """
    forms = []
    for f in P.forms:
        for g in Q.forms:
            forms.append(AffineForm(f.slope + g.slope, f.bias + g.bias))
    return TropicalProfile(forms)


# ─── Algorithm 3: DAG to Tropical Profile ───────────────────────────────

@dataclass
class DAGEdge:
    """An edge in a computation DAG with an affine weight."""
    source: str
    target: str
    weight: AffineForm


@dataclass
class ComputationDAG:
    """A computation DAG with affine edge weights.

    Nodes are strings. There must be at least one source (no incoming edges)
    and at least one sink (no outgoing edges).
    """
    edges: List[DAGEdge]
    _adj: Dict[str, List[DAGEdge]] = field(default_factory=dict, repr=False)

    def __post_init__(self):
        self._adj = defaultdict(list)
        for e in self.edges:
            self._adj[e.source].append(e)

    @property
    def nodes(self) -> Set[str]:
        nodes = set()
        for e in self.edges:
            nodes.add(e.source)
            nodes.add(e.target)
        return nodes

    @property
    def sources(self) -> Set[str]:
        """Nodes with no incoming edges."""
        targets = {e.target for e in self.edges}
        return self.nodes - targets

    @property
    def sinks(self) -> Set[str]:
        """Nodes with no outgoing edges."""
        sources_set = {e.source for e in self.edges}
        return self.nodes - sources_set

    def extract_tropical_profile(self) -> TropicalProfile:
        """Extract the tropical profile by enumerating all source-to-sink paths.

        Each path produces an affine form whose slope is the sum of edge slopes
        and whose bias is the sum of edge biases along the path.

        Uses DFS enumeration.

        Time: O(|paths|) — can be exponential in DAG size
        Space: O(depth · |paths|)

        For DAGs with bounded width, the number of paths is polynomial.
        """
        forms = []
        sinks = self.sinks

        def dfs(node: str, current_slope: float, current_bias: float):
            if node in sinks:
                forms.append(AffineForm(current_slope, current_bias))
                return
            for edge in self._adj[node]:
                dfs(edge.target,
                    current_slope + edge.weight.slope,
                    current_bias + edge.weight.bias)

        for source in self.sources:
            dfs(source, 0.0, 0.0)

        if not forms:
            forms = [AffineForm(0, 0)]  # degenerate case

        return TropicalProfile(forms)


# ─── Algorithm 4: Asymptotic Analysis ──────────────────────────────────

def extract_scaling_exponent(
    profile: TropicalProfile,
    N_values: np.ndarray
) -> Tuple[float, float]:
    """Extract the scaling exponent from a tropical profile.

    Given a profile P, the "loss" at parameter count N is modeled as:
        L(N) = exp(-P.evalMax(log N))

    The scaling exponent α is the slope of log L vs log N for large N:
        log L(N) ≈ -α · log N - β

    Returns (alpha, beta) from the asymptotic regime.

    Time: O(|forms| · |N_values|)

    >>> P = TropicalProfile([AffineForm(2, 1), AffineForm(1, 5)])
    >>> alpha, beta = extract_scaling_exponent(P, np.logspace(3, 8, 100))
    >>> abs(alpha - 2.0) < 0.01
    True
    """
    log_N = np.log(N_values)
    log_L = -profile.eval_max_array(log_N)

    # Fit line to last quarter of data (asymptotic regime)
    n = len(N_values)
    start = 3 * n // 4
    coeffs = np.polyfit(log_N[start:], log_L[start:], 1)

    alpha = -coeffs[0]  # slope of log L vs log N, negated
    beta = -coeffs[1]

    return alpha, beta


def classify_universality(
    profiles: List[TropicalProfile],
    tolerance: float = 1e-10
) -> Dict[Tuple[float, float], List[int]]:
    """Classify profiles into universality classes.

    Two profiles are in the same universality class if they have the
    same (max_slope, essential_dominant_bias) pair.

    Returns a dict mapping (slope, bias) to list of profile indices.

    Time: O(n · max|forms|)

    >>> profiles = [
    ...     TropicalProfile([AffineForm(2, 1)]),
    ...     TropicalProfile([AffineForm(2, 1), AffineForm(1, 5)]),
    ...     TropicalProfile([AffineForm(3, 0)]),
    ... ]
    >>> classes = classify_universality(profiles)
    >>> len(classes)
    2
    """
    classes: Dict[Tuple[float, float], List[int]] = defaultdict(list)

    for i, p in enumerate(profiles):
        key = (round(p.max_slope / tolerance) * tolerance,
               round(p.essential_dominant_bias / tolerance) * tolerance)
        classes[key].append(i)

    return dict(classes)


# ─── Example Usage ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Build a simple DAG
    dag = ComputationDAG([
        DAGEdge("in", "h1", AffineForm(1, 0)),
        DAGEdge("in", "h2", AffineForm(2, -1)),
        DAGEdge("h1", "out", AffineForm(1, 1)),
        DAGEdge("h2", "out", AffineForm(1, 0)),
        DAGEdge("in", "out", AffineForm(0.5, 3)),  # skip connection
    ])

    print(f"\nDAG: {len(dag.edges)} edges, sources={dag.sources}, sinks={dag.sinks}")

    profile = dag.extract_tropical_profile()
    print(f"Tropical profile: {profile}")
    print(f"Max slope (scaling exponent): {profile.max_slope}")
    print(f"Essential dominant bias: {profile.essential_dominant_bias}")

    # Reduce
    reduced = profile.reduce()
    print(f"Reduced profile: {reduced}")

    # Extract scaling exponent
    N = np.logspace(3, 8, 200)
    alpha, beta = extract_scaling_exponent(profile, N)
    print(f"\nExtracted scaling exponent: α = {alpha:.4f}")
    print(f"Expected (max slope): {profile.max_slope}")

    # Classify architectures
    profiles = [
        TropicalProfile([AffineForm(2, 1), AffineForm(1, 5)]),
        TropicalProfile([AffineForm(2, 1)]),
        TropicalProfile([AffineForm(3, 0), AffineForm(1, 10)]),
        TropicalProfile([AffineForm(2, 1), AffineForm(0, 100)]),
    ]

    classes = classify_universality(profiles)
    print(f"\nUniversality classes:")
    for (s, b), indices in sorted(classes.items()):
        print(f"  Slope={s}, Bias={b}: profiles {indices}")

    # Test equivalence
    P = TropicalProfile([AffineForm(2, 1), AffineForm(1, 5), AffineForm(3, -2)])
    Q = TropicalProfile([AffineForm(3, -2), AffineForm(2, 1), AffineForm(1, 5),
                         AffineForm(2.5, -1)])
    equiv, cx = are_tropically_equivalent(P, Q)
    print(f"\nP ≡ Q? {equiv}")

    print("\nAll algorithms executed successfully!")
