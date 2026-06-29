#!/usr/bin/env python3
"""
Algorithms for Tropical Arithmetic Undecidability Analysis

Implements the key algorithms from the research:
1. Tropical term normal form computation (min-of-affine decomposition)
2. Satisfiability checker for mul-free tropical formulas
3. Polynomial-to-tropical encoding
4. Two-counter machine simulator with trace analysis
"""

from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass, field
import itertools


# ============================================================
# Algorithm 1: Min-of-Affine Normal Form
# ============================================================

@dataclass
class AffineFunc:
    """An affine function: offset + Σ coeffs[i] * v(i)."""
    offset: int
    coeffs: Dict[int, int] = field(default_factory=dict)

    def eval(self, v: Dict[int, int]) -> int:
        result = self.offset
        for var_idx, coeff in self.coeffs.items():
            result += coeff * v.get(var_idx, 0)
        return result

    def __repr__(self):
        terms = [str(self.offset)] if self.offset != 0 else []
        for var_idx, coeff in sorted(self.coeffs.items()):
            if coeff == 1:
                terms.append(f"x{var_idx}")
            elif coeff == -1:
                terms.append(f"-x{var_idx}")
            elif coeff != 0:
                terms.append(f"{coeff}·x{var_idx}")
        return " + ".join(terms) if terms else "0"

    def plus(self, other: 'AffineFunc') -> 'AffineFunc':
        """Add two affine functions."""
        new_coeffs = dict(self.coeffs)
        for var_idx, coeff in other.coeffs.items():
            new_coeffs[var_idx] = new_coeffs.get(var_idx, 0) + coeff
        return AffineFunc(self.offset + other.offset, new_coeffs)


@dataclass
class MinOfAffine:
    """
    Normal form for mul-free tropical terms: min(f₁, f₂, ..., fₖ).

    Time complexity of construction: O(|term|) with branching factor
    bounded by the product of min-node arities.
    Space complexity: O(2^d) where d = depth of min-nesting.
    """
    funcs: List[AffineFunc]

    def eval(self, v: Dict[int, int]) -> int:
        """Evaluate: take minimum of all constituent affine functions.
        Time: O(k) where k = len(self.funcs).
        """
        return min(f.eval(v) for f in self.funcs)

    @staticmethod
    def from_var(idx: int) -> 'MinOfAffine':
        return MinOfAffine([AffineFunc(0, {idx: 1})])

    @staticmethod
    def from_const(c: int) -> 'MinOfAffine':
        return MinOfAffine([AffineFunc(c)])

    def add(self, other: 'MinOfAffine') -> 'MinOfAffine':
        """
        Add two min-of-affine functions.
        min(f₁,...,fₖ) + min(g₁,...,gₘ) = min(fᵢ + gⱼ : i,j)

        Time: O(k * m) where k, m are the sizes of the two representations.
        """
        result = []
        for f in self.funcs:
            for g in other.funcs:
                result.append(f.plus(g))
        return MinOfAffine(result)

    def tmin(self, other: 'MinOfAffine') -> 'MinOfAffine':
        """
        min of two min-of-affine functions.
        min(min(f₁,...,fₖ), min(g₁,...,gₘ)) = min(f₁,...,fₖ,g₁,...,gₘ)

        Time: O(k + m).
        """
        return MinOfAffine(self.funcs + other.funcs)

    def __repr__(self):
        if len(self.funcs) == 1:
            return repr(self.funcs[0])
        return "min(" + ", ".join(repr(f) for f in self.funcs) + ")"


def normalize_mul_free_term(term) -> MinOfAffine:
    """
    Convert a mul-free tropical term to min-of-affine normal form.

    Algorithm: Structural recursion on the term tree.
    - var(n) → single affine function x_n
    - const(c) → single affine function c
    - add(s, t) → Cartesian product of affine functions from s and t
    - tmin(s, t) → union of affine functions from s and t

    Time complexity: O(2^d · n) where d = depth of tmin nesting, n = term size.
    Space complexity: O(2^d) for the output representation.

    This is the algorithmic content behind the formal theorem
    `mul_free_term_has_affine_decomp` and `mul_free_eval_midpoint_concavity`.
    """
    from demo import TropTerm, TermKind

    if term.kind == TermKind.VAR:
        return MinOfAffine.from_var(term.var_idx)
    elif term.kind == TermKind.CONST:
        return MinOfAffine.from_const(term.value)
    elif term.kind == TermKind.ADD:
        left_nf = normalize_mul_free_term(term.left)
        right_nf = normalize_mul_free_term(term.right)
        return left_nf.add(right_nf)
    elif term.kind == TermKind.TMIN:
        left_nf = normalize_mul_free_term(term.left)
        right_nf = normalize_mul_free_term(term.right)
        return left_nf.tmin(right_nf)
    else:
        raise ValueError(f"Term contains multiplication — not mul-free!")


# ============================================================
# Algorithm 2: Mul-Free Satisfiability Checker
# ============================================================

def check_mul_free_sat(atoms: List[Tuple[str, 'MinOfAffine', 'MinOfAffine']],
                       var_range: range = range(-10, 11)) -> Optional[Dict[int, int]]:
    """
    Check satisfiability of a conjunction of mul-free tropical atoms.

    Since mul-free atoms reduce to piecewise-linear constraints (which are
    finite unions of polyhedra over integers), satisfiability is decidable.

    This brute-force checker works for small variable domains.
    A production implementation would use integer linear programming.

    Args:
        atoms: List of (kind, lhs_nf, rhs_nf) where kind is "eq" or "le"
        var_range: Range to search over for each variable

    Returns:
        A satisfying assignment, or None if unsatisfiable in the given range.

    Time complexity: O(|var_range|^num_vars · num_atoms · max_affine_funcs)
    """
    # Collect all variable indices
    all_vars: Set[int] = set()
    for _, lhs, rhs in atoms:
        for f in lhs.funcs + rhs.funcs:
            all_vars.update(f.coeffs.keys())

    var_list = sorted(all_vars)
    if not var_list:
        var_list = [0]  # need at least one variable dimension

    # Enumerate assignments
    for vals in itertools.product(var_range, repeat=len(var_list)):
        assignment = dict(zip(var_list, vals))
        satisfied = True
        for kind, lhs, rhs in atoms:
            lval = lhs.eval(assignment)
            rval = rhs.eval(assignment)
            if kind == "eq" and lval != rval:
                satisfied = False
                break
            if kind == "le" and lval > rval:
                satisfied = False
                break
        if satisfied:
            return assignment

    return None


# ============================================================
# Algorithm 3: Polynomial-to-Tropical Encoder
# ============================================================

@dataclass
class IntPoly:
    """Integer polynomial represented as a sum of monomials."""
    # Each monomial is (coefficient, {var_idx: power})
    terms: List[Tuple[int, Dict[int, int]]]

    def eval(self, v: Dict[int, int]) -> int:
        result = 0
        for coeff, powers in self.terms:
            term_val = coeff
            for var_idx, power in powers.items():
                term_val *= v.get(var_idx, 0) ** power
            result += term_val
        return result

    def to_tropical_term(self):
        """
        Encode this polynomial as a TropTerm using mul.

        Algorithm:
        1. Each monomial c · x₁^a₁ · ... · xₙ^aₙ is encoded as
           mul(const(c), mul(var(x₁), mul(var(x₁), ... ))) with repeated vars for powers.
        2. Sum of monomials uses add.

        Time: O(Σ degree_i) for the encoding.
        """
        from demo import Const, Var, Add, Mul, TropTerm

        if not self.terms:
            return Const(0)

        def encode_monomial(coeff: int, powers: Dict[int, int]):
            result = Const(coeff)
            for var_idx, power in sorted(powers.items()):
                for _ in range(power):
                    result = Mul(result, Var(var_idx))
            return result

        encoded = encode_monomial(*self.terms[0])
        for coeff, powers in self.terms[1:]:
            encoded = Add(encoded, encode_monomial(coeff, powers))
        return encoded


def encode_diophantine_system(polys: List[IntPoly]) -> List:
    """
    Encode a system of polynomial equations p₁ = 0, ..., pₖ = 0
    as tropical atoms.

    This is the algorithmic implementation of `encodePolySystem` from the
    formal development. The encoding is exact: satisfiability is preserved.

    Time: O(Σ |pᵢ|) where |pᵢ| = total degree of polynomial pᵢ.
    Space: O(Σ |pᵢ|) for the encoded terms.
    """
    from demo import Const, TropTerm
    atoms = []
    for poly in polys:
        trop_term = poly.to_tropical_term()
        atoms.append(("eq", trop_term, Const(0)))
    return atoms


# ============================================================
# Algorithm 4: Two-Counter Machine Analysis
# ============================================================

def analyze_tcm_complexity(instrs, max_steps: int = 1000) -> Dict:
    """
    Analyze the computational behavior of a two-counter machine.

    Returns:
        Dict with keys:
        - 'halted': bool
        - 'steps': int (number of steps to halt, or max_steps)
        - 'max_c1': int (maximum value of counter 1)
        - 'max_c2': int (maximum value of counter 2)
        - 'states_visited': set of visited states
        - 'periodic': bool (whether a configuration repeated)
    """
    from demo import Halt, Inc1, Inc2, Dec1, Dec2

    pc, c1, c2 = 0, 0, 0
    seen_configs = set()
    max_c1 = 0
    max_c2 = 0
    states_visited = set()
    halted = False
    periodic = False

    for step in range(max_steps):
        config = (pc, c1, c2)
        if config in seen_configs:
            periodic = True
            break
        seen_configs.add(config)
        states_visited.add(pc)
        max_c1 = max(max_c1, c1)
        max_c2 = max(max_c2, c2)

        if pc >= len(instrs):
            halted = True
            break
        instr = instrs[pc]
        if isinstance(instr, Halt):
            halted = True
            break
        elif isinstance(instr, Inc1):
            c1 += 1; pc = instr.next
        elif isinstance(instr, Inc2):
            c2 += 1; pc = instr.next
        elif isinstance(instr, Dec1):
            if c1 > 0: c1 -= 1; pc = instr.if_pos
            else: pc = instr.if_zero
        elif isinstance(instr, Dec2):
            if c2 > 0: c2 -= 1; pc = instr.if_pos
            else: pc = instr.if_zero

    return {
        'halted': halted,
        'steps': step,
        'max_c1': max_c1,
        'max_c2': max_c2,
        'states_visited': states_visited,
        'periodic': periodic,
    }


# ============================================================
# Demonstrations
# ============================================================

if __name__ == "__main__":
    from demo import Var, Const, Add, TMin, Mul

    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Normal form computation
    print("\n--- Min-of-Affine Normal Form ---")
    t1 = TMin(Add(Var(0), Const(3)), Add(Var(1), Const(1)))
    nf1 = normalize_mul_free_term(t1)
    print(f"Term: {t1}")
    print(f"Normal form: {nf1}")
    print(f"Number of affine components: {len(nf1.funcs)}")

    t2 = Add(TMin(Var(0), Var(1)), TMin(Const(2), Var(2)))
    nf2 = normalize_mul_free_term(t2)
    print(f"\nTerm: {t2}")
    print(f"Normal form: {nf2}")
    print(f"Number of affine components: {len(nf2.funcs)}")

    # Verify equivalence
    for x0 in range(-3, 4):
        for x1 in range(-3, 4):
            for x2 in range(-3, 4):
                v = {0: x0, 1: x1, 2: x2}
                assert t2.eval(lambda i: v.get(i, 0)) == nf2.eval(v), \
                    f"Mismatch at {v}"
    print("  ✓ Normal form verified for all values in [-3, 3]³")

    # Demo 2: Mul-free satisfiability
    print("\n--- Mul-Free Satisfiability Checker ---")
    # min(x, 5) = 3  →  satisfiable when x ∈ {3}
    lhs = MinOfAffine.from_var(0).tmin(MinOfAffine.from_const(5))
    rhs = MinOfAffine.from_const(3)
    result = check_mul_free_sat([("eq", lhs, rhs)])
    print(f"min(x, 5) = 3: solution = {result}")

    # x + y ≤ 3 and x ≥ 1 and y ≥ 1
    xy = MinOfAffine.from_var(0).add(MinOfAffine.from_var(1))
    c3 = MinOfAffine.from_const(3)
    c1 = MinOfAffine.from_const(1)
    x_moa = MinOfAffine.from_var(0)
    y_moa = MinOfAffine.from_var(1)
    result = check_mul_free_sat([("le", xy, c3), ("le", c1, x_moa), ("le", c1, y_moa)])
    print(f"x+y ≤ 3, x ≥ 1, y ≥ 1: solution = {result}")

    # Demo 3: Polynomial encoding
    print("\n--- Polynomial Encoding ---")
    p = IntPoly([(1, {0: 2}), (-1, {})])  # x² - 1
    trop = p.to_tropical_term()
    print(f"Polynomial x² - 1 encoded as: {trop}")
    for x in range(-3, 4):
        orig = p.eval({0: x})
        encoded = trop.eval(lambda i: x)
        assert orig == encoded, f"Mismatch at x={x}"
    print("  ✓ Encoding verified for x ∈ [-3, 3]")

    # Demo 4: TCM analysis
    print("\n--- Two-Counter Machine Analysis ---")
    from demo import Halt, Inc1, Inc2, Dec1, Dec2

    # Doubling machine: c2 := 2 * c1 (with c1 = 3)
    # Setup: inc c1 three times
    # Loop: dec c1, inc c2, inc c2, repeat
    doubler = [Inc1(1), Inc1(2), Inc1(3),  # states 0-2: c1 = 3
               Dec1(4, 7),                  # state 3: if c1>0 goto 4, else goto 7
               Inc2(5),                     # state 4: inc c2
               Inc2(3),                     # state 5: inc c2, go back to check
               Halt(),                      # state 6: unused
               Halt()]                      # state 7: done
    analysis = analyze_tcm_complexity(doubler)
    print(f"Doubler machine: {analysis}")
    print(f"  Expected: c2 = 2*3 = 6, and halted = True")

    print("\n✓ All algorithm demonstrations complete.")
