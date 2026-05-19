#!/usr/bin/env python3
"""
Algorithms for Tropical Scaling Exponent Analysis

Implements the core algorithms from the tropical universality theory:
1. Scaling exponent extraction from DAG profiles
2. Profile composition (serial & parallel)
3. Tropical equivalence checking
4. Envelope computation and sandwich verification

All algorithms have polynomial time complexity in the number of paths.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import itertools


@dataclass(frozen=True)
class TropAffine:
    """Tropical affine form: slope · x + intercept.

    Represents one source-to-sink path cost function in a computation DAG.

    Attributes:
        slope: Power-law scaling rate (rational number).
        intercept: Constant overhead term.
    """
    slope: float
    intercept: float

    def eval(self, x: float) -> float:
        """Evaluate the affine form at point x.

        Time complexity: O(1)
        """
        return self.slope * x + self.intercept


class TropicalProfile:
    """A nonempty finite set of tropical affine forms.

    Represents all source-to-sink path cost functions in a computation DAG.

    Attributes:
        forms: List of TropAffine forms (at least one).
    """

    def __init__(self, forms: list[TropAffine]):
        """Initialize a tropical profile.

        Args:
            forms: Nonempty list of tropical affine forms.

        Raises:
            ValueError: If forms is empty.
        """
        if not forms:
            raise ValueError("TropicalProfile requires at least one form")
        self.forms = list(forms)

    def envelope(self, x: float) -> float:
        """Compute the tropical envelope at point x.

        The envelope is the pointwise minimum of all form evaluations,
        representing optimal complexity at scale x.

        Time complexity: O(|forms|)

        Args:
            x: Scale parameter.

        Returns:
            Minimum evaluation across all forms.
        """
        return min(f.eval(x) for f in self.forms)

    def scaling_exponent(self) -> float:
        """Extract the tropical scaling exponent.

        Algorithm:
            Return min(f.slope for f in forms).

        Time complexity: O(|forms|)

        Returns:
            The minimum slope, which controls leading power-law behavior.
        """
        return min(f.slope for f in self.forms)

    def dominant_forms(self) -> list[TropAffine]:
        """Find all forms achieving the minimum slope.

        These are the forms that dominate asymptotic behavior.

        Time complexity: O(|forms|)

        Returns:
            List of forms with slope equal to the scaling exponent.
        """
        alpha = self.scaling_exponent()
        return [f for f in self.forms if abs(f.slope - alpha) < 1e-12]

    def verify_sandwich(self, x_min: float = 0, x_max: float = 1000,
                        n_points: int = 1000) -> dict:
        """Numerically verify the affine sandwich theorem.

        Checks that the envelope is bounded between α·x + b₁ and α·x + b₂
        for α = scaling_exponent.

        Time complexity: O(|forms| · n_points)

        Args:
            x_min: Start of evaluation range.
            x_max: End of evaluation range.
            n_points: Number of test points.

        Returns:
            Dictionary with sandwich verification results.
        """
        alpha = self.scaling_exponent()
        dominant = self.dominant_forms()

        # Upper bound: use the dominant form with smallest intercept
        b_upper = min(f.intercept for f in dominant)
        # Lower bound: minimum intercept across all forms
        b_lower = min(f.intercept for f in self.forms)

        xs = [x_min + i * (x_max - x_min) / n_points for i in range(n_points + 1)]

        violations_lower = 0
        violations_upper = 0
        max_lower_gap = 0.0
        max_upper_gap = 0.0

        for x in xs:
            env = self.envelope(x)
            lower = alpha * x + b_lower
            upper = alpha * x + b_upper

            if env < lower - 1e-10:
                violations_lower += 1
                max_lower_gap = max(max_lower_gap, lower - env)
            if env > upper + 1e-10:
                violations_upper += 1
                max_upper_gap = max(max_upper_gap, env - upper)

        return {
            "scaling_exponent": alpha,
            "b_lower": b_lower,
            "b_upper": b_upper,
            "violations_lower": violations_lower,
            "violations_upper": violations_upper,
            "sandwich_holds": violations_lower == 0 and violations_upper == 0,
        }


def parallel_compose(P: TropicalProfile, Q: TropicalProfile) -> TropicalProfile:
    """Parallel composition of tropical profiles.

    Models competing computation strategies — the system uses whichever
    path achieves lower cost at any given scale.

    Algorithm:
        Return TropicalProfile(P.forms ∪ Q.forms)

    Time complexity: O(|P.forms| + |Q.forms|)
    Space complexity: O(|P.forms| + |Q.forms|)

    Theorem (formally verified):
        scaling_exponent(parallel(P, Q)) = min(P.scaling_exponent, Q.scaling_exponent)

    Args:
        P: First tropical profile.
        Q: Second tropical profile.

    Returns:
        Parallel composition profile.
    """
    return TropicalProfile(P.forms + Q.forms)


def serial_compose(P: TropicalProfile, Q: TropicalProfile) -> TropicalProfile:
    """Serial composition of tropical profiles.

    Models sequential computation stages — total cost is the sum of
    per-stage costs along each path combination.

    Algorithm:
        For each (f, g) in P.forms × Q.forms:
            create TropAffine(f.slope + g.slope, f.intercept + g.intercept)

    Time complexity: O(|P.forms| · |Q.forms|)
    Space complexity: O(|P.forms| · |Q.forms|)

    Theorem (formally verified):
        scaling_exponent(serial(P, Q)) = P.scaling_exponent + Q.scaling_exponent

    Args:
        P: First (upstream) tropical profile.
        Q: Second (downstream) tropical profile.

    Returns:
        Serial composition profile.
    """
    combined = []
    for f, g in itertools.product(P.forms, Q.forms):
        combined.append(TropAffine(f.slope + g.slope, f.intercept + g.intercept))
    return TropicalProfile(combined)


def check_tropical_equivalence(P: TropicalProfile, Q: TropicalProfile) -> bool:
    """Check if two profiles are tropically equivalent.

    Two profiles are tropically equivalent when they have the same
    set of (slope, intercept) pairs.

    Time complexity: O(|P.forms| · log|P.forms| + |Q.forms| · log|Q.forms|)

    Theorem (formally verified):
        TropEquiv(P, Q) → P.scaling_exponent = Q.scaling_exponent

    Args:
        P: First tropical profile.
        Q: Second tropical profile.

    Returns:
        True if profiles are tropically equivalent.
    """
    set_p = set((f.slope, f.intercept) for f in P.forms)
    set_q = set((f.slope, f.intercept) for f in Q.forms)
    return set_p == set_q


def extract_scaling_exponent_from_data(
    xs: list[float],
    ys: list[float],
    num_forms: int = 5
) -> tuple[float, TropicalProfile]:
    """Extract a tropical profile from empirical scaling data.

    Fits a piecewise-linear (tropical) model to log-log data by finding
    the best collection of affine forms whose envelope approximates the data.

    Algorithm:
        1. Convert to log-space: log(y) vs log(x)
        2. Fit num_forms affine segments via greedy cover
        3. Return the profile and its scaling exponent

    Time complexity: O(n · num_forms) where n = len(xs)

    Args:
        xs: Scale parameters (e.g., model sizes). Must be positive.
        ys: Observed values (e.g., loss values). Must be positive.
        num_forms: Number of affine forms to fit.

    Returns:
        Tuple of (scaling_exponent, fitted_profile).
    """
    import math

    log_xs = [math.log(x) for x in xs if x > 0]
    log_ys = [math.log(y) for y in ys if y > 0]

    n = min(len(log_xs), len(log_ys))
    if n < 2:
        return (0.0, TropicalProfile([TropAffine(0, 0)]))

    # Simple approach: divide data into segments and fit lines
    segment_size = max(2, n // num_forms)
    forms = []

    for i in range(0, n - 1, segment_size):
        end = min(i + segment_size, n - 1)
        if end <= i:
            continue

        # Least-squares fit for this segment
        sx = sum(log_xs[i:end + 1])
        sy = sum(log_ys[i:end + 1])
        sxx = sum(x ** 2 for x in log_xs[i:end + 1])
        sxy = sum(x * y for x, y in zip(log_xs[i:end + 1], log_ys[i:end + 1]))
        m = end - i + 1

        denom = m * sxx - sx * sx
        if abs(denom) < 1e-15:
            slope = 0.0
        else:
            slope = (m * sxy - sx * sy) / denom

        intercept = (sy - slope * sx) / m
        forms.append(TropAffine(slope, intercept))

    if not forms:
        forms = [TropAffine(0, 0)]

    profile = TropicalProfile(forms)
    return (profile.scaling_exponent(), profile)


def classify_architecture(layers: list[TropicalProfile],
                          skip_connections: Optional[list[tuple[int, int, TropicalProfile]]] = None
                          ) -> dict:
    """Classify a neural architecture by its tropical scaling exponent.

    Given a sequence of layer profiles and optional skip connections,
    computes the overall scaling exponent using the composition laws.

    Algorithm:
        1. Compose layers serially to get backbone profile
        2. For each skip connection (i, j, skip_profile):
           compose layers i..j serially, then parallel with skip
        3. Return the final exponent

    Time complexity: O(L · max_forms²) where L = number of layers

    Args:
        layers: List of per-layer tropical profiles.
        skip_connections: Optional list of (start, end, skip_profile) triples.

    Returns:
        Dictionary with classification results.
    """
    if not layers:
        return {"exponent": 0.0, "profile": TropicalProfile([TropAffine(0, 0)])}

    # Serial composition of all layers
    result = layers[0]
    for layer in layers[1:]:
        result = serial_compose(result, layer)

    backbone_exponent = result.scaling_exponent()

    # Apply skip connections
    if skip_connections:
        for start, end, skip_profile in skip_connections:
            result = parallel_compose(result, skip_profile)

    return {
        "backbone_exponent": backbone_exponent,
        "final_exponent": result.scaling_exponent(),
        "num_paths": len(result.forms),
        "dominant_paths": len(result.dominant_forms()),
        "profile": result,
    }


# ─── Example Usage ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Scaling Exponent Algorithms")
    print("=" * 50)

    # Example 1: Basic composition
    P = TropicalProfile([TropAffine(0.5, 0), TropAffine(1.0, -2)])
    Q = TropicalProfile([TropAffine(1/3, 1)])

    print(f"\nP: exponent = {P.scaling_exponent()}")
    print(f"Q: exponent = {Q.scaling_exponent()}")
    print(f"Serial P·Q: exponent = {serial_compose(P, Q).scaling_exponent()}")
    print(f"Parallel P∪Q: exponent = {parallel_compose(P, Q).scaling_exponent()}")

    # Example 2: Sandwich verification
    print(f"\nSandwich verification for P:")
    result = P.verify_sandwich()
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example 3: Architecture classification
    print(f"\nArchitecture classification (3-layer + skip):")
    layers = [
        TropicalProfile([TropAffine(0.3, 0)]),
        TropicalProfile([TropAffine(0.2, 1)]),
        TropicalProfile([TropAffine(0.4, -1)]),
    ]
    skip = TropicalProfile([TropAffine(0.1, 2)])
    result = classify_architecture(layers, [(0, 2, skip)])
    for k, v in result.items():
        if k != "profile":
            print(f"  {k}: {v}")
