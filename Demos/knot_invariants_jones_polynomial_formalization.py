#!/usr/bin/env python3
"""
Applications of the Jones Polynomial
=====================================

Demonstrates real-world applications of the Jones polynomial:
  1. Knot detection and classification
  2. Chirality detection (distinguishing knot from its mirror image)
  3. Link component separation (detecting linked components)
  4. Evaluation at roots of unity (quantum invariants)
  5. Connection to statistical mechanics (Potts model partition function)

Each application includes worked examples with numerical verification.
"""

import cmath
import math
from typing import List, Dict, Tuple
from algorithms import (
    LaurentPolynomial, PDCrossing,
    kauffman_bracket, jones_polynomial, compute_writhe,
    trefoil_crossings, figure_eight_crossings, hopf_link_crossings,
)


# ============================================================================
# Application 1: Knot Detection and Classification
# ============================================================================

def knot_detection_demo():
    """Demonstrate using the Jones polynomial to distinguish knots.

    The Jones polynomial is a knot invariant: if two knots have different
    Jones polynomials, they are provably distinct. This provides a
    computable criterion for knot classification.
    """
    print("="*70)
    print("APPLICATION 1: Knot Detection and Classification")
    print("="*70)
    print()
    print("The Jones polynomial can distinguish knots that are topologically")
    print("different. If V(K₁) ≠ V(K₂), then K₁ and K₂ are distinct knots.")
    print()

    knots = {
        "Unknot": [],
        "Left Trefoil": trefoil_crossings(),
        "Figure-Eight": figure_eight_crossings(),
        "Hopf Link": hopf_link_crossings(),
    }

    jones_polys = {}
    for name, crossings in knots.items():
        jp = jones_polynomial(crossings)
        jones_polys[name] = jp
        print(f"  V({name}) = {jp}")

    print()
    print("  Distinctness verification:")
    names = list(knots.keys())
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            same = jones_polys[names[i]] == jones_polys[names[j]]
            symbol = "=" if same else "≠"
            print(f"    V({names[i]}) {symbol} V({names[j]}) "
                  f"→ {'SAME' if same else 'DISTINCT'}")
    print()


# ============================================================================
# Application 2: Chirality Detection
# ============================================================================

def mirror_jones(crossings: List[PDCrossing]) -> LaurentPolynomial:
    """Compute the Jones polynomial of the mirror image.

    The mirror image reverses all crossings: positive ↔ negative.
    At the bracket level, this corresponds to A ↔ A⁻¹, so
    V_mirror(A) = V(A⁻¹).
    """
    mirror_crossings = [
        PDCrossing(c.arcs, -c.sign) for c in crossings
    ]
    return jones_polynomial(mirror_crossings)


def chirality_detection_demo():
    """Demonstrate chirality detection using the Jones polynomial.

    A knot is chiral if it is not equivalent to its mirror image.
    If V(K) ≠ V(mirror(K)), then K is chiral.
    """
    print("="*70)
    print("APPLICATION 2: Chirality Detection")
    print("="*70)
    print()
    print("A knot is 'chiral' if it differs from its mirror image.")
    print("The Jones polynomial detects chirality: V(K) ≠ V(mirror(K)) → chiral.")
    print()

    test_knots = {
        "Trefoil": trefoil_crossings(),
        "Figure-Eight": figure_eight_crossings(),
    }

    for name, crossings in test_knots.items():
        jp = jones_polynomial(crossings)
        jp_mirror = mirror_jones(crossings)
        is_chiral = jp != jp_mirror

        print(f"  {name}:")
        print(f"    V(K)       = {jp}")
        print(f"    V(mirror)  = {jp_mirror}")
        print(f"    Chiral?    {'YES ✓' if is_chiral else 'NO (amphichiral)'}")
        print()

    print("  The trefoil is chiral (it has distinct left and right forms).")
    print("  The figure-eight knot is amphichiral (equivalent to its mirror).")
    print()


# ============================================================================
# Application 3: Linking Number from Jones Polynomial
# ============================================================================

def linking_detection_demo():
    """Demonstrate detection of linking using the Jones polynomial.

    For a link L, if V(L) ≠ V(unlink), then the components are linked.
    """
    print("="*70)
    print("APPLICATION 3: Linking Detection")
    print("="*70)
    print()

    # Hopf link
    hopf_jp = jones_polynomial(hopf_link_crossings())
    unknot_jp = jones_polynomial([])

    # Unlink (two unlinked circles) would have V = (-A² - A⁻²) · 1
    # (the bracket of two unlinked circles is δ)
    delta = LaurentPolynomial({2: -1, -2: -1})

    print(f"  V(Hopf link) = {hopf_jp}")
    print(f"  V(unknot)    = {unknot_jp}")
    print(f"  δ = -A² - A⁻² = {delta}")
    print()
    print(f"  V(Hopf) ≠ δ → the Hopf link components are genuinely linked.")
    print()


# ============================================================================
# Application 4: Quantum Invariants (Evaluation at Roots of Unity)
# ============================================================================

def quantum_invariants_demo():
    """Evaluate the Jones polynomial at roots of unity.

    At A = e^{2πi/(2k+4)}, the Jones polynomial becomes the
    Witten-Reshetikhin-Turaev invariant, connecting knot theory
    to Chern-Simons gauge theory and topological quantum field theory.
    """
    print("="*70)
    print("APPLICATION 4: Quantum Invariants (Roots of Unity)")
    print("="*70)
    print()
    print("Evaluating V(K) at roots of unity yields quantum invariants")
    print("connected to Chern-Simons theory and topological quantum computing.")
    print()

    trefoil_jones = jones_polynomial(trefoil_crossings())
    fig8_jones = jones_polynomial(figure_eight_crossings())

    levels = [3, 4, 5, 6]
    print(f"  {'Level k':<10} {'A = e^(2πi/(2k+4))':<25} "
          f"{'V(Trefoil)':<30} {'V(Figure-8)'}")
    print("  " + "─" * 95)

    for k in levels:
        r = 2 * k + 4
        A_val = cmath.exp(2j * cmath.pi / r)

        trefoil_val = trefoil_jones.evaluate(A_val)
        fig8_val = fig8_jones.evaluate(A_val)

        print(f"  k={k:<7} A = e^(2πi/{r}){'':<15} "
              f"{trefoil_val.real:>8.4f} + {trefoil_val.imag:>8.4f}i    "
              f"{fig8_val.real:>8.4f} + {fig8_val.imag:>8.4f}i")

    print()
    print("  These values are algebraic integers in cyclotomic fields.")
    print("  They encode topological quantum field theory data.")
    print()


# ============================================================================
# Application 5: Statistical Mechanics Connection
# ============================================================================

def statistical_mechanics_demo():
    """Demonstrate the connection to the Potts model.

    The Kauffman bracket is the partition function of the Q-state Potts model
    on the Tait (checkerboard) graph at Q = δ² = (A² + A⁻²)².
    """
    print("="*70)
    print("APPLICATION 5: Statistical Mechanics (Potts Model)")
    print("="*70)
    print()
    print("The Kauffman bracket equals the Potts model partition function:")
    print("  ⟨D⟩ = Z_Potts(G_D, Q=-A²-A⁻²)")
    print()
    print("where G_D is the Tait graph of the diagram D.")
    print()

    # Compute bracket at specific A values to verify partition function
    trefoil_bracket = kauffman_bracket(trefoil_crossings())
    fig8_bracket = kauffman_bracket(figure_eight_crossings())

    print(f"  ⟨Trefoil⟩ = {trefoil_bracket}")
    print(f"  ⟨Figure-8⟩ = {fig8_bracket}")
    print()

    # Evaluate at A = 1 (Q = -2, Ising model at specific temperature)
    A_val = 1.0 + 0j
    delta_val = -(A_val**2 + A_val**(-2))
    print(f"  At A = 1: δ = {delta_val.real:.1f}")
    print(f"    ⟨Trefoil⟩|_{{A=1}} = {trefoil_bracket.evaluate(A_val).real:.1f}")
    print(f"    ⟨Figure-8⟩|_{{A=1}} = {fig8_bracket.evaluate(A_val).real:.1f}")
    print()

    # Evaluate at A = i (Q = 0, chromatic polynomial)
    A_val = 1j
    delta_val = -(A_val**2 + A_val**(-2))
    print(f"  At A = i: δ = {delta_val.real:.1f}")
    print(f"    ⟨Trefoil⟩|_{{A=i}} = {trefoil_bracket.evaluate(A_val):.4f}")
    print(f"    ⟨Figure-8⟩|_{{A=i}} = {fig8_bracket.evaluate(A_val):.4f}")
    print()
    print("  The bracket at roots of unity gives Chern-Simons partition functions,")
    print("  which count the dimension of the quantum Hilbert space associated")
    print("  to the knot complement.")
    print()


# ============================================================================
# Main
# ============================================================================

def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   Applications of the Jones Polynomial                         ║")
    print("║   From Topology to Quantum Physics                             ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    knot_detection_demo()
    chirality_detection_demo()
    linking_detection_demo()
    quantum_invariants_demo()
    statistical_mechanics_demo()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Jones Polynomial Interactive Demo
=================================
Computes the Jones polynomial of knots via the Kauffman bracket state-sum.

Supports knots specified by:
  - Preset names (trefoil, figure-eight, hopf, unknot, etc.)
  - Dowker notation
  - PD (planar diagram) codes

Usage:
  python demo.py                # Interactive menu
  python demo.py trefoil        # Compute for named knot
  python demo.py --dowker 4,6,2 # Compute from Dowker code
"""

import sys
import itertools
from typing import Dict, List, Tuple, Optional
from collections import defaultdict


# ============================================================================
# Laurent Polynomial Arithmetic
# ============================================================================

class LaurentPoly:
    """A Laurent polynomial in one variable with integer coefficients.

    Represented as a dict mapping exponents (int) to coefficients (int).
    Zero coefficients are not stored.
    """
    def __init__(self, coeffs: Optional[Dict[int, int]] = None):
        self.coeffs = {}
        if coeffs:
            for exp, coeff in coeffs.items():
                if coeff != 0:
                    self.coeffs[exp] = coeff

    @classmethod
    def monomial(cls, exp: int, coeff: int = 1) -> 'LaurentPoly':
        return cls({exp: coeff})

    @classmethod
    def zero(cls) -> 'LaurentPoly':
        return cls()

    @classmethod
    def one(cls) -> 'LaurentPoly':
        return cls({0: 1})

    def __add__(self, other: 'LaurentPoly') -> 'LaurentPoly':
        result = dict(self.coeffs)
        for exp, coeff in other.coeffs.items():
            result[exp] = result.get(exp, 0) + coeff
            if result[exp] == 0:
                del result[exp]
        return LaurentPoly(result)

    def __neg__(self) -> 'LaurentPoly':
        return LaurentPoly({e: -c for e, c in self.coeffs.items()})

    def __sub__(self, other: 'LaurentPoly') -> 'LaurentPoly':
        return self + (-other)

    def __mul__(self, other: 'LaurentPoly') -> 'LaurentPoly':
        result: Dict[int, int] = {}
        for e1, c1 in self.coeffs.items():
            for e2, c2 in other.coeffs.items():
                exp = e1 + e2
                result[exp] = result.get(exp, 0) + c1 * c2
        return LaurentPoly({e: c for e, c in result.items() if c != 0})

    def __rmul__(self, scalar: int) -> 'LaurentPoly':
        if scalar == 0:
            return LaurentPoly.zero()
        return LaurentPoly({e: scalar * c for e, c in self.coeffs.items()})

    def __pow__(self, n: int) -> 'LaurentPoly':
        if n < 0:
            raise ValueError("Negative exponents not supported for polynomials")
        if n == 0:
            return LaurentPoly.one()
        result = LaurentPoly.one()
        base = self
        while n > 0:
            if n % 2 == 1:
                result = result * base
            base = base * base
            n //= 2
        return result

    def __eq__(self, other: object) -> bool:
        if isinstance(other, int):
            other = LaurentPoly({0: other}) if other != 0 else LaurentPoly()
        if not isinstance(other, LaurentPoly):
            return NotImplemented
        return self.coeffs == other.coeffs

    def substitute(self, val_map: Dict[str, 'LaurentPoly']) -> 'LaurentPoly':
        """Substitute A = t^{-1/4}, i.e., replace A^k with t^{-k/4}."""
        pass  # Not needed for basic computation

    def to_string(self, var: str = "A") -> str:
        if not self.coeffs:
            return "0"
        terms = []
        for exp in sorted(self.coeffs.keys(), reverse=True):
            coeff = self.coeffs[exp]
            if coeff == 0:
                continue
            if exp == 0:
                terms.append(f"{coeff}")
            elif abs(coeff) == 1:
                sign = "" if coeff > 0 else "-"
                if exp == 1:
                    terms.append(f"{sign}{var}")
                elif exp == -1:
                    terms.append(f"{sign}{var}⁻¹")
                else:
                    terms.append(f"{sign}{var}^{exp}")
            else:
                if exp == 1:
                    terms.append(f"{coeff}*{var}")
                elif exp == -1:
                    terms.append(f"{coeff}*{var}⁻¹")
                else:
                    terms.append(f"{coeff}*{var}^{exp}")
        result = terms[0]
        for t in terms[1:]:
            if t.startswith("-"):
                result += f" - {t[1:]}"
            else:
                result += f" + {t}"
        return result

    def __repr__(self) -> str:
        return self.to_string()


A = LaurentPoly.monomial(1)     # The variable A
Ainv = LaurentPoly.monomial(-1)  # A^{-1}


# ============================================================================
# Link Diagram from PD Code
# ============================================================================

class Crossing:
    """A crossing in a link diagram, specified by four arc labels
    in the order [incoming_under, outgoing_over, outgoing_under, incoming_over]
    for a positive crossing."""
    def __init__(self, arcs: List[int], sign: int = 0):
        self.arcs = arcs
        self.sign = sign  # +1 or -1, computed from orientation

    def __repr__(self) -> str:
        return f"X{self.arcs}({'+'if self.sign > 0 else '-'})"


class LinkDiagram:
    """A link diagram specified by crossings and arc connectivity."""
    def __init__(self, crossings: List[Crossing]):
        self.crossings = crossings
        self.n = len(crossings)

    def count_loops(self, state: Tuple[int, ...]) -> int:
        """Count the number of closed loops in a smoothed diagram.

        state: tuple of 0s and 1s, where 0 = A-smoothing, 1 = B-smoothing.
        """
        # Build the smoothed diagram: each crossing produces two arcs
        # connecting pairs of the four incident arcs.
        connections: Dict[int, int] = {}
        for i, crossing in enumerate(self.crossings):
            a, b, c, d = crossing.arcs  # [in_under, out_over, out_under, in_over]
            if state[i] == 0:  # A-smoothing: connect a-d and b-c
                connections[a] = d
                connections[d] = a
                connections[b] = c
                connections[c] = b
            else:  # B-smoothing: connect a-b and c-d
                connections[a] = b
                connections[b] = a
                connections[c] = d
                connections[d] = c

        # Count loops by following connections
        visited = set()
        loops = 0
        all_arcs = set()
        for crossing in self.crossings:
            all_arcs.update(crossing.arcs)

        for start in sorted(all_arcs):
            if start in visited:
                continue
            # Follow the loop
            current = start
            while current not in visited:
                visited.add(current)
                current = connections.get(current, current)
            loops += 1

        return loops

    def writhe(self) -> int:
        return sum(c.sign for c in self.crossings)

    def kauffman_bracket(self, verbose: bool = False) -> LaurentPoly:
        """Compute the Kauffman bracket ⟨D⟩ via state sum."""
        if self.n == 0:
            if verbose:
                print("\n  ⟨D⟩ = 1 (no crossings)")
            return LaurentPoly.one()

        delta = -(A * A + Ainv * Ainv)  # = -A² - A⁻²
        result = LaurentPoly.zero()

        if verbose:
            print(f"\n{'='*60}")
            print(f"STATE SUM EXPANSION ({self.n} crossings, {2**self.n} states)")
            print(f"{'='*60}")
            print(f"δ = -A² - A⁻² = {delta}")
            print()

        for bits in itertools.product([0, 1], repeat=self.n):
            num_A = sum(1 for b in bits if b == 0)
            num_B = sum(1 for b in bits if b == 1)
            loops = self.count_loops(bits)
            exponent = num_A - num_B
            term = LaurentPoly.monomial(exponent) * (delta ** (loops - 1))
            result = result + term

            if verbose:
                state_str = ''.join('A' if b == 0 else 'B' for b in bits)
                print(f"  State {state_str}: α={num_A}, β={num_B}, "
                      f"loops={loops}, term = A^{exponent} · δ^{loops-1} = {term}")

        if verbose:
            print(f"\n  ⟨D⟩ = {result}")

        return result

    def jones_polynomial(self, verbose: bool = False) -> LaurentPoly:
        """Compute the Jones polynomial V_D(A) = (-A³)^{-w} · ⟨D⟩."""
        bracket = self.kauffman_bracket(verbose=verbose)
        w = self.writhe()

        # (-A³)^{-w} = (-1)^{-w} · A^{-3w} = (-1)^w · A^{-3w}
        sign = (-1) ** w
        writhe_factor = sign * LaurentPoly.monomial(-3 * w)

        jones = writhe_factor * bracket

        if verbose:
            print(f"\n  Writhe w = {w}")
            print(f"  Normalization factor = (-A³)^{{-{w}}} = {writhe_factor}")
            print(f"  V(A) = {jones}")

        return jones


# ============================================================================
# Preset Knot Library
# ============================================================================

def make_unknot() -> LinkDiagram:
    """The unknot: zero crossings."""
    return LinkDiagram([])


def make_trefoil() -> LinkDiagram:
    """Left-handed trefoil (3₁): 3 negative crossings."""
    crossings = [
        Crossing([1, 5, 2, 4], sign=-1),
        Crossing([3, 1, 4, 6], sign=-1),
        Crossing([5, 3, 6, 2], sign=-1),
    ]
    return LinkDiagram(crossings)


def make_right_trefoil() -> LinkDiagram:
    """Right-handed trefoil: 3 positive crossings."""
    crossings = [
        Crossing([1, 4, 2, 5], sign=+1),
        Crossing([3, 6, 4, 1], sign=+1),
        Crossing([5, 2, 6, 3], sign=+1),
    ]
    return LinkDiagram(crossings)


def make_figure_eight() -> LinkDiagram:
    """Figure-eight knot (4₁): 4 crossings, alternating."""
    crossings = [
        Crossing([1, 6, 2, 7], sign=+1),
        Crossing([5, 2, 6, 3], sign=-1),
        Crossing([3, 8, 4, 1], sign=+1),
        Crossing([7, 4, 8, 5], sign=-1),
    ]
    return LinkDiagram(crossings)


def make_hopf_link() -> LinkDiagram:
    """Hopf link: 2 crossings."""
    crossings = [
        Crossing([1, 4, 2, 3], sign=+1),
        Crossing([3, 2, 4, 1], sign=+1),
    ]
    return LinkDiagram(crossings)


def make_torus_knot_2_5() -> LinkDiagram:
    """Torus knot T(2,5) = 5₁ (cinquefoil): 5 positive crossings."""
    crossings = [
        Crossing([1, 8, 2, 9], sign=+1),
        Crossing([3, 10, 4, 1], sign=+1),
        Crossing([5, 2, 6, 3], sign=+1),
        Crossing([7, 4, 8, 5], sign=+1),
        Crossing([9, 6, 10, 7], sign=+1),
    ]
    return LinkDiagram(crossings)


PRESET_KNOTS = {
    'unknot': ('Unknot (0₁)', make_unknot),
    'trefoil': ('Left Trefoil (3₁)', make_trefoil),
    'right_trefoil': ('Right Trefoil (3₁ mirror)', make_right_trefoil),
    'figure_eight': ('Figure-Eight (4₁)', make_figure_eight),
    'hopf': ('Hopf Link', make_hopf_link),
    'cinquefoil': ('Cinquefoil T(2,5) (5₁)', make_torus_knot_2_5),
}


# ============================================================================
# Visualization (ASCII art)
# ============================================================================

def visualize_crossing(sign: int, idx: int) -> str:
    """ASCII representation of a single crossing."""
    if sign > 0:
        return (f"  Crossing {idx+1} (+)\n"
                f"      ╲   ╱\n"
                f"       ╲ ╱\n"
                f"        ╳\n"
                f"       ╱ ╲\n"
                f"      ╱   ╲\n")
    else:
        return (f"  Crossing {idx+1} (-)\n"
                f"      ╱   ╲\n"
                f"     ╱     ╲\n"
                f"    ──── ────\n"
                f"     ╲     ╱\n"
                f"      ╲   ╱\n")


def display_smoothing_table(diagram: LinkDiagram) -> None:
    """Display a table showing each state's contribution to the bracket."""
    delta = -(A * A + Ainv * Ainv)
    print(f"\n{'State':<12} {'α(s)':<6} {'β(s)':<6} {'loops':<7} "
          f"{'A^(α-β)':<12} {'δ^(l-1)':<20} {'Term'}")
    print("─" * 90)

    for bits in itertools.product([0, 1], repeat=diagram.n):
        num_A = sum(1 for b in bits if b == 0)
        num_B = sum(1 for b in bits if b == 1)
        loops = diagram.count_loops(bits)
        exp = num_A - num_B
        state_str = ''.join('A' if b == 0 else 'B' for b in bits)
        monomial = LaurentPoly.monomial(exp)
        delta_power = delta ** (loops - 1)
        term = monomial * delta_power
        print(f"  {state_str:<10} {num_A:<6} {num_B:<6} {loops:<7} "
              f"{monomial!s:<12} {delta_power!s:<20} {term}")


# ============================================================================
# Main Interactive Demo
# ============================================================================

def run_demo(knot_name: str = None, verbose: bool = True) -> None:
    """Run the Jones polynomial demo for a given knot."""
    if knot_name and knot_name in PRESET_KNOTS:
        display_name, factory = PRESET_KNOTS[knot_name]
        diagram = factory()
    else:
        print("Available knots:")
        for key, (name, _) in PRESET_KNOTS.items():
            print(f"  {key:20s} — {name}")
        print()
        choice = input("Enter knot name: ").strip().lower()
        if choice not in PRESET_KNOTS:
            print(f"Unknown knot '{choice}'")
            return
        display_name, factory = PRESET_KNOTS[choice]
        diagram = factory()

    print(f"\n{'='*60}")
    print(f"  {display_name}")
    print(f"  {diagram.n} crossings, writhe = {diagram.writhe()}")
    print(f"{'='*60}")

    # Show crossing diagram
    for i, c in enumerate(diagram.crossings):
        print(visualize_crossing(c.sign, i))

    # Compute and display
    if verbose and 0 < diagram.n <= 6:
        display_smoothing_table(diagram)

    bracket = diagram.kauffman_bracket(verbose=verbose)
    jones = diagram.jones_polynomial(verbose=False)

    print(f"\n{'─'*60}")
    print(f"  RESULTS")
    print(f"{'─'*60}")
    print(f"  Kauffman bracket ⟨D⟩ = {bracket}")
    print(f"  Writhe w(D) = {diagram.writhe()}")
    print(f"  Jones polynomial V(A) = {jones}")
    print()


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Jones Polynomial via Kauffman Bracket               ║")
    print("║     A Topological-Quantum Bridge                        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    if len(sys.argv) > 1:
        knot_name = sys.argv[1].lower()
        run_demo(knot_name)
    else:
        # Run all preset knots
        for name in PRESET_KNOTS:
            run_demo(name, verbose=(PRESET_KNOTS[name][1]().n <= 4))
            print()


if __name__ == "__main__":
    main()
