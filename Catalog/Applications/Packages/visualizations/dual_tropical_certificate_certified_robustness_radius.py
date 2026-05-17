#!/usr/bin/env python3
"""
Algorithms for Tropical Classifier Certification
=================================================
Implements the key algorithms from the research paper:
  1. Chamber enumeration and polyhedral description
  2. Certified robustness radius computation
  3. Margin region membership testing
  4. Security stability verification
"""

import numpy as np
from itertools import product as cartesian_product
from typing import List, Tuple, Dict, Optional


# ──────────────────────────────────────────────
# Data Structures
# ──────────────────────────────────────────────

class AffineHalfspace:
    """An affine halfspace {x : w·x + b ≥ 0}."""
    def __init__(self, weights: np.ndarray, bias: float):
        self.weights = weights  # shape (n,)
        self.bias = bias

    def contains(self, x: np.ndarray) -> bool:
        return float(self.weights @ x + self.bias) >= -1e-12

    def __repr__(self):
        return f"AffineHalfspace(w={self.weights}, b={self.bias:.4f})"


class AffinePolyhedron:
    """A polyhedron defined as intersection of affine halfspaces."""
    def __init__(self, halfspaces: List[AffineHalfspace]):
        self.halfspaces = halfspaces

    def contains(self, x: np.ndarray) -> bool:
        return all(h.contains(x) for h in self.halfspaces)

    @property
    def num_constraints(self) -> int:
        return len(self.halfspaces)


class TropicalAffineForm:
    """f(x) = max_k (a_k · x + b_k)"""
    def __init__(self, slopes: np.ndarray, intercepts: np.ndarray):
        self.slopes = np.atleast_2d(slopes)
        self.intercepts = np.atleast_1d(intercepts)
        self.K = self.slopes.shape[0]
        self.n = self.slopes.shape[1]

    def eval(self, x: np.ndarray) -> float:
        return float(max(self.slopes[k] @ x + self.intercepts[k] for k in range(self.K)))

    def active_term(self, x: np.ndarray) -> int:
        vals = [float(self.slopes[k] @ x + self.intercepts[k]) for k in range(self.K)]
        return int(np.argmax(vals))

    def lipschitz_l1(self) -> float:
        """L1-based Lipschitz constant (for L∞ input metric)."""
        return max(float(np.sum(np.abs(self.slopes[k]))) for k in range(self.K))


# ──────────────────────────────────────────────
# Algorithm 1: Chamber Enumeration
# ──────────────────────────────────────────────

def enumerate_chambers(
    forms: Dict[str, TropicalAffineForm]
) -> List[Tuple[Dict[str, int], AffinePolyhedron]]:
    """
    Enumerate all chamber assignments and compute the corresponding
    affine polyhedral description.

    Returns list of (assignment, polyhedron) pairs.

    Time complexity: O(∏_c K_c · (∑_c K_c) · n)
    Space complexity: O(∑_c K_c · n) per chamber
    """
    classes = list(forms.keys())
    term_ranges = [range(forms[c].K) for c in classes]

    chambers = []
    for assignment_tuple in cartesian_product(*term_ranges):
        assignment = {c: k for c, k in zip(classes, assignment_tuple)}

        # Build halfspace constraints
        halfspaces = []
        for c in classes:
            form = forms[c]
            active_k = assignment[c]
            for k in range(form.K):
                if k == active_k:
                    continue
                # Constraint: a_{active} · x + b_{active} ≥ a_k · x + b_k
                # i.e., (a_{active} - a_k) · x + (b_{active} - b_k) ≥ 0
                w = form.slopes[active_k] - form.slopes[k]
                b = form.intercepts[active_k] - form.intercepts[k]
                halfspaces.append(AffineHalfspace(w, b))

        chambers.append((assignment, AffinePolyhedron(halfspaces)))

    return chambers


# ──────────────────────────────────────────────
# Algorithm 2: Margin Region Description
# ──────────────────────────────────────────────

def margin_region_on_chamber(
    forms: Dict[str, TropicalAffineForm],
    c0: str,
    m: float,
    assignment: Dict[str, int]
) -> AffinePolyhedron:
    """
    Compute the polyhedral description of
    {x ∈ Chamber(σ) : ∀ d ≠ c₀, m ≤ score(c₀, x) - score(d, x)}.

    On the chamber, each score is affine, so margin constraints become
    additional halfspace constraints.

    Time complexity: O((∑_c K_c + |classes|) · n)
    """
    classes = list(forms.keys())
    halfspaces = []

    # Chamber constraints (same as enumerate_chambers)
    for c in classes:
        form = forms[c]
        active_k = assignment[c]
        for k in range(form.K):
            if k == active_k:
                continue
            w = form.slopes[active_k] - form.slopes[k]
            b = form.intercepts[active_k] - form.intercepts[k]
            halfspaces.append(AffineHalfspace(w, b))

    # Margin constraints: for each d ≠ c₀
    form_c0 = forms[c0]
    k_c0 = assignment[c0]
    for d in classes:
        if d == c0:
            continue
        form_d = forms[d]
        k_d = assignment[d]
        # score(c₀, x) - score(d, x) ≥ m on this chamber means:
        # (a_{c₀,k_{c₀}} - a_{d,k_d}) · x + (b_{c₀,k_{c₀}} - b_{d,k_d} - m) ≥ 0
        w = form_c0.slopes[k_c0] - form_d.slopes[k_d]
        b = form_c0.intercepts[k_c0] - form_d.intercepts[k_d] - m
        halfspaces.append(AffineHalfspace(w, b))

    return AffinePolyhedron(halfspaces)


# ──────────────────────────────────────────────
# Algorithm 3: Certified Robustness Radius
# ──────────────────────────────────────────────

def certified_radius(
    forms: Dict[str, TropicalAffineForm],
    c0: str,
    x: np.ndarray
) -> Tuple[float, float, float]:
    """
    Compute the certified robustness radius for classifying x as c₀.

    Returns (margin, lipschitz_constant, certified_radius).

    The certified radius is margin / (2 * L), where L is the maximum
    L1-norm Lipschitz constant over all class scores.

    Time complexity: O(|classes| · max_c K_c · n)
    """
    classes = list(forms.keys())

    # Compute margin
    s0 = forms[c0].eval(x)
    margin = min(s0 - forms[d].eval(x) for d in classes if d != c0)

    # Compute Lipschitz constant
    L = max(forms[c].lipschitz_l1() for c in classes)

    if margin <= 0 or L <= 0:
        return margin, L, 0.0

    radius = margin / (2 * L)
    return margin, L, radius


# ──────────────────────────────────────────────
# Algorithm 4: Security Stability Verification
# ──────────────────────────────────────────────

def security_certified_radius(
    advantage_fn,
    lipschitz_constant: float,
    params: np.ndarray
) -> Tuple[float, float]:
    """
    Compute the certified perturbation radius for maintaining
    positive security advantage.

    Given advantage(params) ≥ m > 0 and Lip(advantage) ≤ L,
    any params' with ‖params' - params‖ ≤ m/L has advantage(params') ≥ 0.

    Returns (advantage_at_params, certified_radius).
    """
    m = advantage_fn(params)
    if m <= 0 or lipschitz_constant <= 0:
        return m, 0.0
    return m, m / lipschitz_constant


# ──────────────────────────────────────────────
# Algorithm 5: Full Margin Region Decomposition
# ──────────────────────────────────────────────

def full_margin_decomposition(
    forms: Dict[str, TropicalAffineForm],
    c0: str,
    m: float
) -> List[AffinePolyhedron]:
    """
    Decompose the margin region {x : ∀ d ≠ c₀, m ≤ score(c₀,x) - score(d,x)}
    into a finite union of affine polyhedra.

    This is the constructive content of Theorem A.

    Time complexity: O(∏_c K_c · (∑_c K_c + |classes|) · n)
    """
    classes = list(forms.keys())
    term_ranges = [range(forms[c].K) for c in classes]

    cells = []
    for assignment_tuple in cartesian_product(*term_ranges):
        assignment = {c: k for c, k in zip(classes, assignment_tuple)}
        poly = margin_region_on_chamber(forms, c0, m, assignment)
        cells.append(poly)

    return cells


# ──────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Certification Algorithms — Example Run")
    print("=" * 55)

    # Define a 2D classifier
    forms = {
        'A': TropicalAffineForm(
            slopes=np.array([[2.0, 1.0], [-1.0, 3.0]]),
            intercepts=np.array([1.0, 2.0])
        ),
        'B': TropicalAffineForm(
            slopes=np.array([[1.0, -1.0], [-2.0, 1.0]]),
            intercepts=np.array([0.5, 1.5])
        ),
        'C': TropicalAffineForm(
            slopes=np.array([[-1.0, -1.0], [1.0, 2.0]]),
            intercepts=np.array([3.0, -1.0])
        ),
    }

    x = np.array([1.0, 0.5])
    c0 = 'A'

    # Algorithm 1: Enumerate chambers
    chambers = enumerate_chambers(forms)
    print(f"\nChamber enumeration: {len(chambers)} chambers")
    for i, (assign, poly) in enumerate(chambers):
        in_chamber = poly.contains(x)
        print(f"  Chamber {i}: {assign}, {poly.num_constraints} constraints, x∈chamber: {in_chamber}")

    # Algorithm 3: Certified radius
    margin, L, radius = certified_radius(forms, c0, x)
    print(f"\nCertified radius computation:")
    print(f"  Margin = {margin:.4f}")
    print(f"  Lipschitz constant = {L:.2f}")
    print(f"  Certified radius = {radius:.6f}")

    # Algorithm 5: Full decomposition for margin ≥ 1.0
    cells = full_margin_decomposition(forms, c0, m=1.0)
    nonempty = sum(1 for cell in cells if cell.contains(x))
    print(f"\nMargin region decomposition (m=1.0):")
    print(f"  {len(cells)} polyhedral cells total")
    print(f"  {nonempty} cells containing x")
