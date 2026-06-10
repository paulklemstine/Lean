"""
algorithms.py — Core algorithms for shadow entropy computation on polynomial supports.

Implements the combinatorial machinery for:
- One-step shadow computation
- Shadow entropy and entropy production
- Support multiplication (Minkowski sum)
- Support circuit evaluation
- Double-counting identity verification

All algorithms correspond to formally verified Lean 4 theorems in
Pythagorean/ShadowEntropy.lean.
"""

from __future__ import annotations
import math
from itertools import product, permutations
from typing import List, Tuple, Set, FrozenSet, Optional, Dict
from collections import Counter
from functools import reduce

# Type aliases
Monomial = Tuple[int, ...]  # exponent vector (α₁, ..., αₙ)
SupportFamily = FrozenSet[Monomial]


def unit_vector(n: int, i: int) -> Monomial:
    """Standard basis vector eᵢ in ℕⁿ."""
    return tuple(1 if j == i else 0 for j in range(n))


def zero_vector(n: int) -> Monomial:
    """Zero vector in ℕⁿ."""
    return tuple(0 for _ in range(n))


def add_monomials(a: Monomial, b: Monomial) -> Monomial:
    """Componentwise addition of exponent vectors."""
    return tuple(x + y for x, y in zip(a, b))


def sub_monomial_at(m: Monomial, i: int) -> Optional[Monomial]:
    """Decrement coordinate i by 1, or None if m[i] == 0."""
    if m[i] <= 0:
        return None
    return tuple(m[j] - (1 if j == i else 0) for j in range(len(m)))


def add_monomial_at(m: Monomial, i: int) -> Monomial:
    """Increment coordinate i by 1."""
    return tuple(m[j] + (1 if j == i else 0) for j in range(len(m)))


# ──────────────────────────────────────────────────────────────────
# Core shadow operations
# ──────────────────────────────────────────────────────────────────

def one_shadow(S: SupportFamily) -> SupportFamily:
    """
    Compute the one-step shadow Sh₁(S).
    
    Sh₁(S) = {u : ∃ m ∈ S, ∃ i, m(i) > 0 ∧ u = m - eᵢ}
    
    This is the support-level analogue of taking all first partial derivatives.
    
    Complexity: O(|S| · n) where n is the dimension.
    """
    if not S:
        return frozenset()
    n = len(next(iter(S)))
    shadow = set()
    for m in S:
        for i in range(n):
            u = sub_monomial_at(m, i)
            if u is not None:
                shadow.add(u)
    return frozenset(shadow)


def support_mul(A: SupportFamily, B: SupportFamily) -> SupportFamily:
    """
    Minkowski sum of support families: S ⊕ T = {a + b : a ∈ S, b ∈ T}.
    
    Models the support of f·g under no-cancellation semantics.
    
    Complexity: O(|A| · |B|).
    """
    return frozenset(add_monomials(a, b) for a in A for b in B)


def support_union(A: SupportFamily, B: SupportFamily) -> SupportFamily:
    """Union of support families (models addition)."""
    return A | B


# ──────────────────────────────────────────────────────────────────
# Entropy quantities
# ──────────────────────────────────────────────────────────────────

def entropy_ratio(S: SupportFamily) -> float:
    """
    Entropy ratio: |Sh₁(S)| / |S|.
    
    Returns 0 for empty S.
    """
    if not S:
        return 0.0
    return len(one_shadow(S)) / len(S)


def shadow_entropy(S: SupportFamily) -> float:
    """
    Shadow entropy: H(S) = log(|Sh₁(S)|) - log(|S|).
    
    Uses natural logarithm. Returns -∞ for empty S (convention).
    Returns -∞ if shadow is empty (all monomials are zero vectors).
    
    Verified bound: H(S) ≤ log(n) for n-variable families (Theorem 1).
    """
    if not S:
        return float('-inf')
    sh = one_shadow(S)
    if not sh:
        return float('-inf')
    return math.log(len(sh)) - math.log(len(S))


def entropy_production(S: SupportFamily) -> int:
    """
    Absolute entropy production: ΔH(S) = |Sh₁(S)| - |S|.
    
    Measures net creation of accessible lower-degree states.
    """
    return len(one_shadow(S)) - len(S)


def normalized_entropy_production(S: SupportFamily) -> float:
    """
    Normalized entropy production: δH(S) = |Sh₁(S)|/|S| - 1.
    """
    if not S:
        return 0.0
    return entropy_ratio(S) - 1.0


# ──────────────────────────────────────────────────────────────────
# Down-degree and shadow incidence (Theorem 4)
# ──────────────────────────────────────────────────────────────────

def down_degree(m: Monomial) -> int:
    """
    Downward degree: number of coordinates with positive exponent.
    
    In statistical physics terms: number of removable excitation quanta.
    """
    return sum(1 for x in m if x > 0)


def unshadow_choices(S: SupportFamily, u: Monomial) -> List[int]:
    """
    For shadow element u and family S, return coordinates i where u + eᵢ ∈ S.
    
    These are the "raising operators" mapping shadow back to original family.
    """
    n = len(u)
    return [i for i in range(n) if add_monomial_at(u, i) in S]


def verify_double_counting(S: SupportFamily) -> Tuple[int, int, bool]:
    """
    Verify the double-counting identity (Theorem 4):
    
      ∑_{m ∈ S} d↓(m) = ∑_{u ∈ Sh₁(S)} |unshadow_choices(S, u)|
    
    Returns (left_sum, right_sum, are_equal).
    
    This identity is formally verified in Lean as
    sum_downDegree_eq_sum_unshadowChoices.
    """
    left = sum(down_degree(m) for m in S)
    sh = one_shadow(S)
    right = sum(len(unshadow_choices(S, u)) for u in sh)
    return left, right, left == right


# ──────────────────────────────────────────────────────────────────
# Support circuit model (Theorem 3)
# ──────────────────────────────────────────────────────────────────

class SupportCircuit:
    """
    A monotone support circuit generating finite support families.
    
    Types:
    - var(i): single variable xᵢ, support = {eᵢ}
    - const: constant, support = {0}
    - add(C, D): addition (union of supports)
    - mul(C, D): multiplication (Minkowski sum of supports)
    """
    
    def __init__(self, kind: str, children=None, var_index: int = 0, n: int = 1):
        self.kind = kind
        self.children = children or []
        self.var_index = var_index
        self.n = n
    
    @staticmethod
    def var(i: int, n: int) -> 'SupportCircuit':
        return SupportCircuit('var', var_index=i, n=n)
    
    @staticmethod
    def const(n: int) -> 'SupportCircuit':
        return SupportCircuit('const', n=n)
    
    @staticmethod
    def add(left: 'SupportCircuit', right: 'SupportCircuit') -> 'SupportCircuit':
        return SupportCircuit('add', [left, right], n=left.n)
    
    @staticmethod
    def mul(left: 'SupportCircuit', right: 'SupportCircuit') -> 'SupportCircuit':
        return SupportCircuit('mul', [left, right], n=left.n)
    
    @property
    def size(self) -> int:
        """Number of gates in the circuit."""
        if self.kind in ('var', 'const'):
            return 1
        return 1 + sum(c.size for c in self.children)
    
    @property
    def depth(self) -> int:
        """Multiplicative depth of the circuit."""
        if self.kind in ('var', 'const'):
            return 0
        if self.kind == 'add':
            return max(c.depth for c in self.children)
        # mul
        return 1 + max(c.depth for c in self.children)
    
    def eval(self) -> SupportFamily:
        """Evaluate the circuit to its support family."""
        if self.kind == 'var':
            return frozenset([unit_vector(self.n, self.var_index)])
        if self.kind == 'const':
            return frozenset([zero_vector(self.n)])
        if self.kind == 'add':
            return support_union(self.children[0].eval(), self.children[1].eval())
        # mul
        return support_mul(self.children[0].eval(), self.children[1].eval())
    
    def __repr__(self):
        if self.kind == 'var':
            return f'x{self.var_index}'
        if self.kind == 'const':
            return '1'
        op = '+' if self.kind == 'add' else '*'
        return f'({self.children[0]} {op} {self.children[1]})'


def verify_circuit_entropy_bound(C: SupportCircuit) -> Tuple[float, float, bool]:
    """
    Verify the circuit entropy depth bound (Theorem 3):
    
      H(eval(C)) ≤ (depth + 1) · log(n)
    
    Returns (actual_entropy, bound, satisfies_bound).
    """
    S = C.eval()
    H = shadow_entropy(S)
    d = C.depth
    n = C.n
    bound = (d + 1) * math.log(n) if n > 0 else 0.0
    return H, bound, H <= bound + 1e-10  # tolerance for float


def verify_product_shadow_inclusion(S: SupportFamily, T: SupportFamily) -> bool:
    """
    Verify the product shadow inclusion (Theorem 2):
    
      Sh₁(S ⊕ T) ⊆ Sh₁(S) ⊕ T ∪ S ⊕ Sh₁(T)
    
    Formally verified as oneShadow_supportMul_subset.
    """
    prod = support_mul(S, T)
    sh_prod = one_shadow(prod)
    sh_S = one_shadow(S)
    sh_T = one_shadow(T)
    rhs = support_mul(sh_S, T) | support_mul(S, sh_T)
    return sh_prod.issubset(rhs)


# ──────────────────────────────────────────────────────────────────
# Permanent support
# ──────────────────────────────────────────────────────────────────

def permanent_support(m: int) -> SupportFamily:
    """
    Support of the m×m permanent polynomial.
    
    Each permutation σ ∈ Sₘ gives an exponent vector in {0,1}^(m²)
    encoding the permutation matrix.
    """
    monomials = set()
    for perm in permutations(range(m)):
        vec = [0] * (m * m)
        for row, col in enumerate(perm):
            vec[row * m + col] = 1
        monomials.add(tuple(vec))
    return frozenset(monomials)


def determinant_support(m: int) -> SupportFamily:
    """
    Support of the m×m determinant polynomial.
    (Same monomials as permanent, since det and perm have the same support.)
    """
    return permanent_support(m)


def elementary_symmetric_support(m: int, k: int) -> SupportFamily:
    """
    Support of the k-th elementary symmetric polynomial in m variables.
    
    e_k(x₁,...,xₘ) = ∑_{|I|=k} ∏_{i∈I} xᵢ
    """
    from itertools import combinations
    monomials = set()
    for combo in combinations(range(m), k):
        vec = tuple(1 if i in combo else 0 for i in range(m))
        monomials.add(vec)
    return frozenset(monomials)


# ──────────────────────────────────────────────────────────────────
# Circuit enumeration
# ──────────────────────────────────────────────────────────────────

def enumerate_circuits(n: int, max_size: int) -> List[SupportCircuit]:
    """
    Enumerate support circuits over n variables up to given size.
    
    Uses memoization by size to build up from atoms.
    """
    by_size: Dict[int, List[SupportCircuit]] = {}
    
    # Size 1: atoms
    atoms = [SupportCircuit.var(i, n) for i in range(n)]
    atoms.append(SupportCircuit.const(n))
    by_size[1] = atoms
    
    all_circuits = list(atoms)
    
    for s in range(3, max_size + 1):  # minimum compound size is 3
        by_size[s] = []
        # Partition s-1 among two children (1 gate for the op)
        for s1 in range(1, s - 1):
            s2 = s - 1 - s1
            if s2 not in by_size or s1 not in by_size:
                continue
            for left in by_size[s1]:
                for right in by_size[s2]:
                    for op in ['add', 'mul']:
                        if op == 'add':
                            c = SupportCircuit.add(left, right)
                        else:
                            c = SupportCircuit.mul(left, right)
                        by_size[s] = by_size.get(s, []) + [c]
                        all_circuits.append(c)
    
    return all_circuits


def compute_circuit_stats(C: SupportCircuit) -> Dict:
    """Compute all entropy statistics for a circuit."""
    S = C.eval()
    sh = one_shadow(S)
    H = shadow_entropy(S)
    
    return {
        'circuit': str(C),
        'size': C.size,
        'depth': C.depth,
        'support_size': len(S),
        'shadow_size': len(sh),
        'entropy': H,
        'entropy_ratio': entropy_ratio(S),
        'entropy_production': entropy_production(S),
        'entropy_bound': (C.depth + 1) * math.log(C.n) if C.n > 0 else 0,
        'satisfies_bound': H <= (C.depth + 1) * math.log(C.n) + 1e-10 if C.n > 0 else True,
    }


if __name__ == '__main__':
    # Quick sanity check
    n = 3
    S = frozenset([unit_vector(n, i) for i in range(n)])  # {e₀, e₁, e₂}
    print(f"S = {S}")
    print(f"|S| = {len(S)}")
    sh = one_shadow(S)
    print(f"|Sh₁(S)| = {len(sh)}")
    print(f"H(S) = {shadow_entropy(S):.4f}")
    print(f"log(n) = {math.log(n):.4f}")
    
    left, right, eq = verify_double_counting(S)
    print(f"\nDouble-counting: {left} = {right}, verified = {eq}")
    
    T = frozenset([(1, 0, 0), (0, 1, 0)])
    print(f"\nProduct shadow inclusion verified: {verify_product_shadow_inclusion(S, T)}")
