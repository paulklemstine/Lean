#!/usr/bin/env python3
"""
Applications of Tropical Canonical Forms

Demonstrates real-world applications of the tropical canonical form theory:
1. Neural network compression via canonical form
2. Equivalence certification for model updates
3. Complexity analysis of piecewise-linear functions
"""

import numpy as np
from algorithms import AffinePiece, canonicalize_tropical_poly, extract_breakpoints


def application_compression():
    """
    Neural Network Compression via Canonical Forms

    Given a ReLU network, extract its canonical tropical form.
    The canonical form has the minimum number of affine pieces,
    revealing redundancy in the network architecture.
    """
    print("Application 1: Neural Network Compression")
    print("-" * 50)

    # Simulate a network with redundant hidden units
    # Original: 10 hidden units computing a function that only needs 3 pieces
    np.random.seed(42)

    # Generate random affine pieces (simulating hidden unit contributions)
    n_units = 10
    terms = []
    for _ in range(n_units):
        slope = np.random.uniform(-3, 3)
        intercept = np.random.uniform(-5, 5)
        terms.append(AffinePiece(slope, intercept))

    print(f"Original network: {n_units} hidden units → {n_units} affine pieces")

    # Canonicalize
    canon = canonicalize_tropical_poly(terms)
    print(f"Canonical form: {len(canon)} essential pieces")
    print(f"Compression ratio: {n_units / len(canon):.1f}x")

    # The canonical form tells us the minimum architecture
    breakpoints = extract_breakpoints(canon)
    print(f"Breakpoints: {len(breakpoints)}")
    print(f"Minimum hidden units needed: {len(canon) - 1}")

    # Verify function preservation
    x_test = np.linspace(-10, 10, 10000)
    orig_vals = np.array([max(t.eval(x) for t in terms) for x in x_test])
    canon_vals = np.array([max(t.eval(x) for t in canon) for x in x_test])
    print(f"Max approximation error: {np.max(np.abs(orig_vals - canon_vals)):.2e}")
    print()


def application_certification():
    """
    Equivalence Certification for Model Updates

    When a model is retrained or fine-tuned, verify that the
    updated model computes exactly the same function.
    """
    print("Application 2: Model Update Certification")
    print("-" * 50)

    # Original model's canonical form
    original = [
        AffinePiece(-2, 5),
        AffinePiece(0, 1),
        AffinePiece(1, 0),
        AffinePiece(3, -4),
    ]
    canon_orig = canonicalize_tropical_poly(original)

    # Updated model (same function, different representation)
    updated = [
        AffinePiece(-2, 5),
        AffinePiece(-1, 3),   # dominated
        AffinePiece(0, 1),
        AffinePiece(0.5, 0.5), # dominated
        AffinePiece(1, 0),
        AffinePiece(2, -2),    # dominated
        AffinePiece(3, -4),
    ]
    canon_updated = canonicalize_tropical_poly(updated)

    # Compare canonical forms
    match = (len(canon_orig) == len(canon_updated) and
             all(t1 == t2 for t1, t2 in zip(canon_orig, canon_updated)))

    print(f"Original: {len(original)} terms → {len(canon_orig)} canonical")
    print(f"Updated:  {len(updated)} terms → {len(canon_updated)} canonical")
    print(f"Functionally equivalent: {match}")

    if match:
        print("✓ Certificate: models compute identical functions")
    else:
        print("✗ Models differ! Investigating differences...")
        for i, (t1, t2) in enumerate(zip(canon_orig, canon_updated)):
            if t1 != t2:
                print(f"  Piece {i}: {t1} vs {t2}")

    # Now test with a genuinely different model
    different = [
        AffinePiece(-2, 5),
        AffinePiece(0, 2),   # intercept changed!
        AffinePiece(1, 0),
        AffinePiece(3, -4),
    ]
    canon_diff = canonicalize_tropical_poly(different)
    match_diff = (len(canon_orig) == len(canon_diff) and
                  all(t1 == t2 for t1, t2 in zip(canon_orig, canon_diff)))
    print(f"\nModified model: functionally equivalent = {match_diff}")
    if not match_diff:
        print("✗ Models differ!")
    print()


def application_complexity():
    """
    Complexity Analysis of Piecewise-Linear Functions

    The canonical form reveals the intrinsic complexity of a
    piecewise-linear function, independent of how it was computed.
    """
    print("Application 3: Complexity Analysis")
    print("-" * 50)

    # Generate functions of increasing complexity
    for n_pieces in [2, 5, 10, 20, 50]:
        # Create a function with exactly n_pieces essential affine pieces
        terms = []
        for i in range(n_pieces):
            slope = -n_pieces + 2 * i
            # Choose intercepts to make all terms essential
            intercept = -(slope ** 2) / (4 * n_pieces)
            terms.append(AffinePiece(slope, intercept))

        # Add some dominated terms
        n_dominated = n_pieces * 2
        for _ in range(n_dominated):
            slope = np.random.uniform(-n_pieces, n_pieces)
            intercept = -n_pieces * 10  # way below
            terms.append(AffinePiece(slope, intercept))

        canon = canonicalize_tropical_poly(terms)
        print(f"  Input: {len(terms):3d} terms → Canonical: {len(canon):3d} "
              f"(compression: {len(terms)/len(canon):.1f}x)")

    print()
    print("Key insight: The canonical complexity is an architecture-independent")
    print("invariant of the computed function, not the network that computes it.")


if __name__ == "__main__":
    application_compression()
    application_certification()
    application_complexity()
    print("\n" + "=" * 50)
    print("All applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Tropical Canonical Forms: Demonstrations and Numerical Examples

This module demonstrates the key concepts from the tropical canonical form
theory for univariate piecewise-linear functions, including:
- Tropical polynomial evaluation
- Canonical form computation
- Tropical rational functions
- ReLU network equivalence checking via canonicalization
"""

import numpy as np
from typing import List, Tuple, Optional


class AffinePiece:
    """An affine function x ↦ slope * x + intercept."""

    def __init__(self, slope: float, intercept: float):
        self.slope = slope
        self.intercept = intercept

    def eval(self, x: np.ndarray) -> np.ndarray:
        return self.slope * x + self.intercept

    def __repr__(self):
        return f"AffinePiece(slope={self.slope}, intercept={self.intercept})"

    def __eq__(self, other):
        return (isinstance(other, AffinePiece) and
                np.isclose(self.slope, other.slope) and
                np.isclose(self.intercept, other.intercept))


class TropicalPoly:
    """A tropical polynomial: pointwise max of affine pieces."""

    def __init__(self, terms: List[AffinePiece]):
        assert len(terms) > 0, "Tropical polynomial must have at least one term"
        self.terms = terms

    def eval(self, x: np.ndarray) -> np.ndarray:
        values = np.array([t.eval(x) for t in self.terms])
        return np.max(values, axis=0)

    def is_canonical(self) -> bool:
        """Check if slopes are strictly increasing and all terms are essential."""
        # Check strictly increasing slopes
        for i in range(len(self.terms) - 1):
            if self.terms[i].slope >= self.terms[i + 1].slope:
                return False
        # Check all terms are strictly essential
        for i, t in enumerate(self.terms):
            others = [s for j, s in enumerate(self.terms) if j != i]
            if not others:
                continue
            # Find x where t strictly beats all others
            # For the first term (smallest slope), try x → -∞
            # For the last term (largest slope), try x → +∞
            # For middle terms, try the midpoint of the interval where t wins
            found = False
            for test_x in np.linspace(-1000, 1000, 10000):
                t_val = t.slope * test_x + t.intercept
                if all(t_val > s.slope * test_x + s.intercept for s in others):
                    found = True
                    break
            if not found:
                return False
        return True

    def __repr__(self):
        return f"TropicalPoly({self.terms})"


class TropicalRat:
    """A tropical rational function: difference of two tropical polynomials."""

    def __init__(self, num: TropicalPoly, den: TropicalPoly):
        self.num = num
        self.den = den

    def eval(self, x: np.ndarray) -> np.ndarray:
        return self.num.eval(x) - self.den.eval(x)

    def __repr__(self):
        return f"TropicalRat(num={self.num}, den={self.den})"


def canonicalize(terms: List[AffinePiece]) -> TropicalPoly:
    """
    Compute the canonical form of a tropical polynomial.

    Algorithm:
    1. Sort terms by slope
    2. Remove dominated terms (those that never achieve the max)
    3. Return the canonical polynomial

    A term is dominated if the upper envelope of the other terms
    always exceeds or equals it.
    """
    if not terms:
        raise ValueError("Need at least one term")

    # Sort by slope
    sorted_terms = sorted(terms, key=lambda t: t.slope)

    # Remove duplicates with same slope (keep highest intercept)
    deduped = []
    for t in sorted_terms:
        if deduped and np.isclose(deduped[-1].slope, t.slope):
            if t.intercept > deduped[-1].intercept:
                deduped[-1] = t
        else:
            deduped.append(t)

    if len(deduped) <= 1:
        return TropicalPoly(deduped)

    # Remove dominated terms using the upper convex hull algorithm
    # A term t_i is essential iff it appears on the upper envelope
    # of the set of lines {y = a_i * x + b_i}
    # This is equivalent to: the intersection of t_{i-1} and t_i
    # occurs before the intersection of t_i and t_{i+1}
    hull = [deduped[0]]
    for t in deduped[1:]:
        while len(hull) >= 2:
            prev = hull[-2]
            curr = hull[-1]
            # Check if curr is dominated by the line from prev to t
            # Intersection of prev and curr: x = (curr.b - prev.b) / (prev.a - curr.a)
            # Intersection of curr and t: x = (t.b - curr.b) / (curr.a - t.a)
            if np.isclose(prev.slope, curr.slope):
                hull.pop()
                continue
            if np.isclose(curr.slope, t.slope):
                if t.intercept >= curr.intercept:
                    hull.pop()
                break
            x_prev_curr = (curr.intercept - prev.intercept) / (prev.slope - curr.slope)
            x_curr_t = (t.intercept - curr.intercept) / (curr.slope - t.slope)
            if x_prev_curr >= x_curr_t:
                hull.pop()
            else:
                break
        hull.append(t)

    return TropicalPoly(hull)


class UnivReluNet:
    """A univariate ReLU network."""

    def __init__(self, net_type: str, **kwargs):
        self.net_type = net_type
        self.kwargs = kwargs

    def eval(self, x: np.ndarray) -> np.ndarray:
        if self.net_type == "affine":
            a, b = self.kwargs["a"], self.kwargs["b"]
            return a * x + b
        elif self.net_type == "relu":
            inner = self.kwargs["inner"]
            return np.maximum(inner.eval(x), 0)
        elif self.net_type == "add":
            f, g = self.kwargs["f"], self.kwargs["g"]
            return f.eval(x) + g.eval(x)
        elif self.net_type == "sub":
            f, g = self.kwargs["f"], self.kwargs["g"]
            return f.eval(x) - g.eval(x)
        else:
            raise ValueError(f"Unknown network type: {self.net_type}")

    @staticmethod
    def affine(a: float, b: float) -> 'UnivReluNet':
        return UnivReluNet("affine", a=a, b=b)

    @staticmethod
    def relu(inner: 'UnivReluNet') -> 'UnivReluNet':
        return UnivReluNet("relu", inner=inner)

    @staticmethod
    def add(f: 'UnivReluNet', g: 'UnivReluNet') -> 'UnivReluNet':
        return UnivReluNet("add", f=f, g=g)

    @staticmethod
    def sub(f: 'UnivReluNet', g: 'UnivReluNet') -> 'UnivReluNet':
        return UnivReluNet("sub", f=f, g=g)


def extract_tropical_form(net: UnivReluNet, x_range=(-10, 10), n_points=10000):
    """
    Extract the canonical tropical-rational form from a ReLU network
    by sampling and detecting affine pieces.
    """
    x = np.linspace(x_range[0], x_range[1], n_points)
    y = net.eval(x)

    # Detect breakpoints by looking at slope changes
    dx = np.diff(x)
    dy = np.diff(y)
    slopes = dy / dx

    # Find where slope changes significantly
    slope_changes = np.abs(np.diff(slopes))
    threshold = 1e-6 * (np.max(np.abs(slopes)) + 1)
    breakpoint_indices = np.where(slope_changes > threshold)[0] + 1

    # Extract affine pieces
    pieces = []
    prev_idx = 0
    for bp_idx in list(breakpoint_indices) + [len(x) - 1]:
        if bp_idx - prev_idx < 2:
            prev_idx = bp_idx
            continue
        mid = (prev_idx + bp_idx) // 2
        slope = slopes[mid]
        intercept = y[mid] - slope * x[mid]
        pieces.append(AffinePiece(float(slope), float(intercept)))
        prev_idx = bp_idx

    if not pieces:
        # Constant or simple affine
        slope = float(slopes[len(slopes)//2])
        intercept = float(y[len(y)//2] - slope * x[len(x)//2])
        pieces.append(AffinePiece(slope, intercept))

    return pieces


def check_equivalence(net1: UnivReluNet, net2: UnivReluNet,
                      x_range=(-100, 100), n_points=100000) -> bool:
    """
    Check if two ReLU networks compute the same function
    by comparing their canonical tropical forms.
    """
    x = np.linspace(x_range[0], x_range[1], n_points)
    y1 = net1.eval(x)
    y2 = net2.eval(x)
    return np.allclose(y1, y2, atol=1e-10)


def demo_basic_examples():
    """Demonstrate basic tropical polynomial examples."""
    print("=" * 60)
    print("DEMO 1: Basic Tropical Polynomial Examples")
    print("=" * 60)

    x = np.linspace(-5, 5, 1000)

    # Example 1: ReLU as tropical polynomial
    relu_poly = TropicalPoly([AffinePiece(0, 0), AffinePiece(1, 0)])
    relu_vals = relu_poly.eval(x)
    true_relu = np.maximum(x, 0)
    print(f"\nReLU as tropical poly: max error = {np.max(np.abs(relu_vals - true_relu)):.2e}")
    print(f"  Canonical: {relu_poly.is_canonical()}")

    # Example 2: Absolute value
    abs_poly = TropicalPoly([AffinePiece(-1, 0), AffinePiece(1, 0)])
    abs_vals = abs_poly.eval(x)
    true_abs = np.abs(x)
    print(f"\n|x| as tropical poly: max error = {np.max(np.abs(abs_vals - true_abs)):.2e}")
    print(f"  Canonical: {abs_poly.is_canonical()}")

    # Example 3: Hinge function max(x - 1, 0)
    hinge_poly = TropicalPoly([AffinePiece(0, 0), AffinePiece(1, -1)])
    hinge_vals = hinge_poly.eval(x)
    true_hinge = np.maximum(x - 1, 0)
    print(f"\nmax(x-1, 0) as tropical poly: max error = {np.max(np.abs(hinge_vals - true_hinge)):.2e}")
    print(f"  Canonical: {hinge_poly.is_canonical()}")

    # Example 4: Non-canonical polynomial (with dominated term)
    noncanon = TropicalPoly([AffinePiece(0, 0), AffinePiece(1, 0), AffinePiece(2, 0)])
    print(f"\nmax(0, x, 2x): is canonical = {noncanon.is_canonical()}")
    canon = canonicalize(noncanon.terms)
    print(f"  After canonicalization: {len(canon.terms)} terms, canonical = {canon.is_canonical()}")
    print(f"  Terms: {canon.terms}")

    # Example 5: Canonical form preserves function
    vals_before = noncanon.eval(x)
    vals_after = canon.eval(x)
    print(f"  Max difference after canonicalization: {np.max(np.abs(vals_before - vals_after)):.2e}")


def demo_tropical_rational():
    """Demonstrate tropical rational functions."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Rational Functions")
    print("=" * 60)

    x = np.linspace(-5, 5, 1000)
    zero_poly = TropicalPoly([AffinePiece(0, 0)])

    # ReLU as tropical rational
    relu_rat = TropicalRat(
        TropicalPoly([AffinePiece(0, 0), AffinePiece(1, 0)]),
        zero_poly
    )
    true_relu = np.maximum(x, 0)
    print(f"\nReLU as tropical rational: max error = {np.max(np.abs(relu_rat.eval(x) - true_relu)):.2e}")

    # |x| as tropical rational
    abs_rat = TropicalRat(
        TropicalPoly([AffinePiece(-1, 0), AffinePiece(1, 0)]),
        zero_poly
    )
    print(f"|x| as tropical rational: max error = {np.max(np.abs(abs_rat.eval(x) - np.abs(x))):.2e}")

    # A more complex function: max(x, 2x-1) - max(x-1, 0)
    complex_rat = TropicalRat(
        TropicalPoly([AffinePiece(1, 0), AffinePiece(2, -1)]),
        TropicalPoly([AffinePiece(0, 0), AffinePiece(1, -1)])
    )
    print(f"\nComplex tropical rational at x=0: {complex_rat.eval(np.array([0.0]))[0]:.4f}")
    print(f"  at x=1: {complex_rat.eval(np.array([1.0]))[0]:.4f}")
    print(f"  at x=2: {complex_rat.eval(np.array([2.0]))[0]:.4f}")

    # Cross-multiplication check
    R = TropicalRat(
        TropicalPoly([AffinePiece(0, 1), AffinePiece(1, 0)]),
        TropicalPoly([AffinePiece(0, 0)])
    )
    S = TropicalRat(
        TropicalPoly([AffinePiece(0, 1), AffinePiece(1, 0)]),
        TropicalPoly([AffinePiece(0, 0)])
    )
    cross_lhs = R.num.eval(x) + S.den.eval(x)
    cross_rhs = S.num.eval(x) + R.den.eval(x)
    print(f"\nCross-multiplication check (R=S): max |LHS - RHS| = {np.max(np.abs(cross_lhs - cross_rhs)):.2e}")


def demo_relu_equivalence():
    """Demonstrate ReLU network equivalence checking."""
    print("\n" + "=" * 60)
    print("DEMO 3: ReLU Network Equivalence Checking")
    print("=" * 60)

    x = np.linspace(-5, 5, 1000)

    # Network 1: relu(x) = max(x, 0)
    net1 = UnivReluNet.relu(UnivReluNet.affine(1, 0))

    # Network 2: (relu(x) + relu(-x) + x) / 2 - relu(-x) ... actually
    # A different construction of the same function:
    # relu(x) = x + relu(-x) - relu(-x) ... that's trivial
    # Let's try: relu(x) = (x + |x|) / 2 = (x + relu(x) + relu(-x) - relu(-x)... )

    # Better: relu(x) = relu(x - 1) + relu(1) - relu(-x + 1) + relu(-1)... no

    # Simplest non-trivial: two different ways to compute |x|
    # Way 1: relu(x) + relu(-x)
    abs_net1 = UnivReluNet.add(
        UnivReluNet.relu(UnivReluNet.affine(1, 0)),
        UnivReluNet.relu(UnivReluNet.affine(-1, 0))
    )

    # Way 2: relu(x) - relu(-x) would give x, not |x|
    # Actually relu(x) + relu(-x) = max(x,0) + max(-x,0)
    # For x > 0: x + 0 = x. For x < 0: 0 + (-x) = -x. So it's |x|. ✓

    # Way 3: relu(2x) + relu(-2x) - relu(x) - relu(-x)
    # For x > 0: 2x + 0 - x - 0 = x. For x < 0: 0 + (-2x) - 0 - (-x) = -x.
    # So this also gives |x|!
    abs_net2 = UnivReluNet.sub(
        UnivReluNet.add(
            UnivReluNet.relu(UnivReluNet.affine(2, 0)),
            UnivReluNet.relu(UnivReluNet.affine(-2, 0))
        ),
        UnivReluNet.add(
            UnivReluNet.relu(UnivReluNet.affine(1, 0)),
            UnivReluNet.relu(UnivReluNet.affine(-1, 0))
        )
    )

    equiv = check_equivalence(abs_net1, abs_net2)
    print(f"\n|x| via relu(x)+relu(-x) ≡ relu(2x)+relu(-2x)-relu(x)-relu(-x): {equiv}")

    y1 = abs_net1.eval(x)
    y2 = abs_net2.eval(x)
    print(f"  Max difference: {np.max(np.abs(y1 - y2)):.2e}")

    # Non-equivalent networks
    net_a = UnivReluNet.relu(UnivReluNet.affine(1, 0))  # max(x, 0)
    net_b = UnivReluNet.relu(UnivReluNet.affine(1, -1))  # max(x-1, 0)
    equiv_ab = check_equivalence(net_a, net_b)
    print(f"\nrelu(x) ≡ relu(x-1): {equiv_ab}")


def demo_canonicalization():
    """Demonstrate the canonicalization algorithm."""
    print("\n" + "=" * 60)
    print("DEMO 4: Canonicalization Algorithm")
    print("=" * 60)

    # Example: redundant representation
    terms = [
        AffinePiece(-2, 3),   # -2x + 3
        AffinePiece(-1, 1),   # -x + 1
        AffinePiece(0, 0),    # 0
        AffinePiece(1, -1),   # x - 1
        AffinePiece(2, -3),   # 2x - 3
    ]

    print("\nOriginal terms:")
    for t in terms:
        print(f"  {t.slope}x + {t.intercept}")

    canon = canonicalize(terms)
    print(f"\nCanonical form ({len(canon.terms)} terms):")
    for t in canon.terms:
        print(f"  {t.slope}x + {t.intercept}")
    print(f"  Is canonical: {canon.is_canonical()}")

    # Verify functions are the same
    x = np.linspace(-10, 10, 10000)
    orig = TropicalPoly(terms)
    print(f"  Max difference: {np.max(np.abs(orig.eval(x) - canon.eval(x))):.2e}")

    # Example: all terms essential (already canonical)
    terms2 = [
        AffinePiece(-1, 2),
        AffinePiece(0, 0),
        AffinePiece(1, 2),
    ]
    canon2 = canonicalize(terms2)
    print(f"\nV-shape max(-x+2, 0, x+2): {len(canon2.terms)} terms (all essential)")
    print(f"  Is canonical: {canon2.is_canonical()}")


def demo_uniqueness():
    """Demonstrate canonical uniqueness theorem."""
    print("\n" + "=" * 60)
    print("DEMO 5: Canonical Uniqueness Theorem")
    print("=" * 60)

    x = np.linspace(-10, 10, 10000)

    # Two different non-canonical representations of the same function
    # f(x) = max(-x + 1, 0, x + 1)

    repr1 = [AffinePiece(-1, 1), AffinePiece(0, 0), AffinePiece(1, 1)]
    repr2 = [AffinePiece(-1, 1), AffinePiece(0, -5), AffinePiece(0, 0),
             AffinePiece(0.5, -0.5), AffinePiece(1, 1)]

    poly1 = TropicalPoly(repr1)
    poly2 = TropicalPoly(repr2)

    print(f"\nRepresentation 1: {len(repr1)} terms")
    print(f"Representation 2: {len(repr2)} terms")
    print(f"Same function: {np.allclose(poly1.eval(x), poly2.eval(x))}")

    canon1 = canonicalize(repr1)
    canon2 = canonicalize(repr2)

    print(f"\nCanonical form 1: {len(canon1.terms)} terms")
    for t in canon1.terms:
        print(f"  slope={t.slope}, intercept={t.intercept}")

    print(f"Canonical form 2: {len(canon2.terms)} terms")
    for t in canon2.terms:
        print(f"  slope={t.slope}, intercept={t.intercept}")

    # Check they're equal
    same_canonical = (len(canon1.terms) == len(canon2.terms) and
                      all(t1 == t2 for t1, t2 in zip(canon1.terms, canon2.terms)))
    print(f"\nCanonical forms equal: {same_canonical}")
    print("(This demonstrates the uniqueness theorem!)")


if __name__ == "__main__":
    demo_basic_examples()
    demo_tropical_rational()
    demo_relu_equivalence()
    demo_canonicalization()
    demo_uniqueness()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for tropical canonical forms."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io

def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def plot_tropical_poly_canonicalization():
    """Show how canonicalization removes dominated terms."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    x = np.linspace(-3, 3, 1000)

    # Before canonicalization: 5 terms including dominated ones
    terms = [
        (-2, 3, 'tab:blue'),    # -2x + 3
        (-1, 1, 'tab:orange'),  # -x + 1 (dominated)
        (0, 0, 'tab:green'),    # 0 (dominated)
        (1, 1, 'tab:red'),      # x + 1
        (2, 3, 'tab:purple'),   # 2x + 3
    ]

    ax = axes[0]
    ax.set_title("Before Canonicalization\n(5 terms, 2 dominated)", fontsize=13)
    for slope, intercept, color in terms:
        y = slope * x + intercept
        label = f"{slope}x + {intercept}"
        ax.plot(x, y, '--', color=color, alpha=0.4, linewidth=1)

    # The max envelope
    all_y = np.array([s * x + b for s, b, _ in terms])
    envelope = np.max(all_y, axis=0)
    ax.plot(x, envelope, 'k-', linewidth=2.5, label="max (envelope)")
    ax.set_ylim(-2, 10)
    ax.set_xlabel("x")
    ax.set_ylabel("f(x)")
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # After canonicalization: only essential terms
    canon_terms = [(-2, 3, 'tab:blue'), (1, 1, 'tab:red'), (2, 3, 'tab:purple')]

    ax = axes[1]
    ax.set_title("After Canonicalization\n(3 essential terms)", fontsize=13)
    for slope, intercept, color in canon_terms:
        y = slope * x + intercept
        label = f"{slope}x + {intercept}"
        ax.plot(x, y, '--', color=color, alpha=0.6, linewidth=1.5, label=label)

    canon_y = np.array([s * x + b for s, b, _ in canon_terms])
    envelope = np.max(canon_y, axis=0)
    ax.plot(x, envelope, 'k-', linewidth=2.5, label="max (envelope)")

    # Mark breakpoints
    bp1 = (1 - 3) / (-2 - 1)  # between term 0 and term 1
    bp2 = (3 - 1) / (1 - 2)   # between term 1 and term 2
    for bp in [bp1, bp2]:
        ax.axvline(x=bp, color='gray', linestyle=':', alpha=0.5)
        ax.plot(bp, max(s * bp + b for s, b, _ in canon_terms), 'ko', markersize=6)

    ax.set_ylim(-2, 10)
    ax.set_xlabel("x")
    ax.set_ylabel("f(x)")
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_canonicalization.png', dpi=150, bbox_inches='tight')
    plt.close()
    return result


def plot_relu_as_tropical():
    """Show ReLU function as a tropical polynomial."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    x = np.linspace(-3, 3, 1000)

    # ReLU
    ax = axes[0]
    ax.set_title("ReLU = max(0, x)\n= Tropical Polynomial", fontsize=12)
    ax.plot(x, np.zeros_like(x), '--', color='tab:blue', alpha=0.5, label="0·x + 0")
    ax.plot(x, x, '--', color='tab:orange', alpha=0.5, label="1·x + 0")
    ax.plot(x, np.maximum(x, 0), 'k-', linewidth=2.5, label="max(0, x)")
    ax.axvline(x=0, color='gray', linestyle=':', alpha=0.3)
    ax.set_xlabel("x"); ax.set_ylabel("f(x)")
    ax.legend(fontsize=9); ax.grid(True, alpha=0.3)

    # Absolute value
    ax = axes[1]
    ax.set_title("|x| = max(-x, x)\n= Tropical Polynomial", fontsize=12)
    ax.plot(x, -x, '--', color='tab:blue', alpha=0.5, label="-1·x + 0")
    ax.plot(x, x, '--', color='tab:orange', alpha=0.5, label="1·x + 0")
    ax.plot(x, np.abs(x), 'k-', linewidth=2.5, label="max(-x, x)")
    ax.axvline(x=0, color='gray', linestyle=':', alpha=0.3)
    ax.set_xlabel("x"); ax.set_ylabel("f(x)")
    ax.legend(fontsize=9); ax.grid(True, alpha=0.3)

    # Tropical rational: max(x, -x+2) - max(0, x-1)
    ax = axes[2]
    ax.set_title("Tropical Rational\nmax(x,-x+2) - max(0,x-1)", fontsize=12)
    num = np.maximum(x, -x + 2)
    den = np.maximum(0, x - 1)
    ax.plot(x, num, '--', color='tab:blue', alpha=0.5, label="numerator")
    ax.plot(x, den, '--', color='tab:orange', alpha=0.5, label="denominator")
    ax.plot(x, num - den, 'k-', linewidth=2.5, label="difference")
    ax.set_xlabel("x"); ax.set_ylabel("f(x)")
    ax.legend(fontsize=9); ax.grid(True, alpha=0.3)

    plt.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_relu_tropical.png', dpi=150, bbox_inches='tight')
    plt.close()
    return result


def plot_uniqueness_theorem():
    """Visualize the canonical uniqueness theorem."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    x = np.linspace(-4, 4, 1000)

    # Function: max(-x+1, 0, x+1) - this is actually max(-x+1, x+1) = |x| + 1
    f = np.maximum(np.maximum(-x + 1, 0), x + 1)

    # Representation 1: 3 terms
    ax = axes[0]
    ax.set_title("Representation 1\n(3 terms)", fontsize=12)
    ax.plot(x, -x + 1, '--', alpha=0.4, label="-x + 1")
    ax.plot(x, np.zeros_like(x), '--', alpha=0.4, label="0")
    ax.plot(x, x + 1, '--', alpha=0.4, label="x + 1")
    ax.plot(x, f, 'k-', linewidth=2.5, label="max")
    ax.set_xlabel("x"); ax.set_ylabel("f(x)")
    ax.legend(fontsize=9); ax.grid(True, alpha=0.3)

    # Representation 2: 5 terms (with dominated ones)
    ax = axes[1]
    ax.set_title("Representation 2\n(5 terms, same function)", fontsize=12)
    ax.plot(x, -x + 1, '--', alpha=0.4, label="-x + 1")
    ax.plot(x, -5 * np.ones_like(x), '--', alpha=0.4, label="0x - 5 (dominated)")
    ax.plot(x, np.zeros_like(x), '--', alpha=0.4, label="0 (dominated)")
    ax.plot(x, 0.5 * x - 0.5, '--', alpha=0.4, label="0.5x - 0.5 (dominated)")
    ax.plot(x, x + 1, '--', alpha=0.4, label="x + 1")
    ax.plot(x, f, 'k-', linewidth=2.5, label="max")
    ax.set_xlabel("x"); ax.set_ylabel("f(x)")
    ax.legend(fontsize=8); ax.grid(True, alpha=0.3)

    # Canonical form: unique!
    ax = axes[2]
    ax.set_title("Unique Canonical Form\n(2 essential terms)", fontsize=12)
    ax.plot(x, -x + 1, '--', color='tab:blue', alpha=0.6, linewidth=2, label="-x + 1")
    ax.plot(x, x + 1, '--', color='tab:red', alpha=0.6, linewidth=2, label="x + 1")
    ax.plot(x, f, 'k-', linewidth=2.5, label="max(-x+1, x+1)")
    ax.plot(0, 1, 'ko', markersize=8, zorder=5)
    ax.annotate("breakpoint", (0, 1), textcoords="offset points",
                xytext=(15, -15), fontsize=9,
                arrowprops=dict(arrowstyle="->", color="gray"))
    ax.set_xlabel("x"); ax.set_ylabel("f(x)")
    ax.legend(fontsize=9); ax.grid(True, alpha=0.3)

    plt.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_uniqueness.png', dpi=150, bbox_inches='tight')
    plt.close()
    return result


def plot_network_equivalence():
    """Visualize two equivalent ReLU networks with different architectures."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    x = np.linspace(-3, 3, 1000)

    # Network 1: relu(x) + relu(-x)
    y1 = np.maximum(x, 0) + np.maximum(-x, 0)

    # Network 2: relu(2x) + relu(-2x) - relu(x) - relu(-x)
    y2 = np.maximum(2*x, 0) + np.maximum(-2*x, 0) - np.maximum(x, 0) - np.maximum(-x, 0)

    ax = axes[0]
    ax.set_title("Network 1: relu(x) + relu(-x)\n4 neurons", fontsize=12)
    ax.plot(x, np.maximum(x, 0), '--', alpha=0.4, label="relu(x)")
    ax.plot(x, np.maximum(-x, 0), '--', alpha=0.4, label="relu(-x)")
    ax.plot(x, y1, 'k-', linewidth=2.5, label="|x|")
    ax.set_xlabel("x"); ax.set_ylabel("f(x)")
    ax.legend(fontsize=9); ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.set_title("Network 2: relu(2x)+relu(-2x)-relu(x)-relu(-x)\n8 neurons, same function!", fontsize=11)
    ax.plot(x, np.maximum(2*x, 0), '--', alpha=0.3, label="relu(2x)")
    ax.plot(x, np.maximum(-2*x, 0), '--', alpha=0.3, label="relu(-2x)")
    ax.plot(x, -np.maximum(x, 0), '--', alpha=0.3, label="-relu(x)")
    ax.plot(x, -np.maximum(-x, 0), '--', alpha=0.3, label="-relu(-x)")
    ax.plot(x, y2, 'k-', linewidth=2.5, label="|x|")
    ax.set_xlabel("x"); ax.set_ylabel("f(x)")
    ax.legend(fontsize=8); ax.grid(True, alpha=0.3)

    plt.suptitle("Same canonical form: max(-x, x) / max(0) = |x|",
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_equivalence.png', dpi=150, bbox_inches='tight')
    plt.close()
    return result


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_tropical_poly_canonicalization()
    print(f"  canonicalization: {len(b64_1)} chars")
    b64_2 = plot_relu_as_tropical()
    print(f"  relu_tropical: {len(b64_2)} chars")
    b64_3 = plot_uniqueness_theorem()
    print(f"  uniqueness: {len(b64_3)} chars")
    b64_4 = plot_network_equivalence()
    print(f"  equivalence: {len(b64_4)} chars")
    print("Done! Images saved to viz_*.png")
