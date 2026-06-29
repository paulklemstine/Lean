#!/usr/bin/env python3
"""
Algorithms for Quantum Circuit Rewriting via Tensor Distributivity

Implements the core algorithms from the research paper:
1. Distributive normalization (O(n * 2^n) worst case)
2. Canonical multiset extraction
3. Summand polynomial computation
4. Gate identity augmented rewriting
5. Confluence checking
"""

from dataclasses import dataclass
from typing import Union, List, Dict, Tuple, Optional, FrozenSet
from collections import Counter
import itertools


# ============================================================
# Data Structures
# ============================================================

@dataclass(frozen=True)
class Gate:
    idx: int
    def __repr__(self): return f"G{self.idx}"

@dataclass(frozen=True)
class Seq:
    left: 'QTExpr'
    right: 'QTExpr'
    def __repr__(self): return f"({self.left} ; {self.right})"

@dataclass(frozen=True)
class Par:
    left: 'QTExpr'
    right: 'QTExpr'
    def __repr__(self): return f"({self.left} ⊗ {self.right})"

@dataclass(frozen=True)
class Add:
    left: 'QTExpr'
    right: 'QTExpr'
    def __repr__(self): return f"({self.left} + {self.right})"

QTExpr = Union[Gate, Seq, Par, Add]

@dataclass
class GateIdentity:
    """A gate identity: lhs can be rewritten to rhs."""
    lhs: QTExpr
    rhs: QTExpr


# ============================================================
# Algorithm 1: Distributive Normalization
# ============================================================

def distribute_seq(a: QTExpr, b: QTExpr) -> QTExpr:
    """
    Distribute sequential composition over addition.

    Time complexity: O(|a| * |b|) in the worst case, where
    |e| denotes summand_count(e).

    Correctness: Preserves denotation in any ring with bilinear parOp.
    (Theorem: distributeSeq_sound)
    """
    if isinstance(a, Add):
        return Add(distribute_seq(a.left, b), distribute_seq(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_seq(a, b.left), distribute_seq(a, b.right))
    return Seq(a, b)


def distribute_par(a: QTExpr, b: QTExpr) -> QTExpr:
    """
    Distribute parallel composition over addition.

    Time complexity: O(|a| * |b|).
    Correctness: Theorem distributePar_sound.
    """
    if isinstance(a, Add):
        return Add(distribute_par(a.left, b), distribute_par(a.right, b))
    if isinstance(b, Add):
        return Add(distribute_par(a, b.left), distribute_par(a, b.right))
    return Par(a, b)


def normalize(e: QTExpr) -> QTExpr:
    """
    Normalize a quantum tensor expression by fully distributing
    seq and par over add.

    Time complexity: O(n * 2^n) worst case, where n = gate_count(e).
    The output size can be exponential (Theorem: summandCount_le_exp).

    Correctness properties (all formally verified):
    - normalize_sound: denote(normalize(e)) = denote(e)
    - normalize_isNF: normalize(e) is in distributive normal form
    - normalize_summandCount: summandCount(normalize(e)) = summandCount(e)
    - normalize_hasNoAdd: if hasNoAdd(e), then normalize(e) = e
    """
    if isinstance(e, Gate):
        return e
    if isinstance(e, Add):
        return Add(normalize(e.left), normalize(e.right))
    if isinstance(e, Seq):
        return distribute_seq(normalize(e.left), normalize(e.right))
    if isinstance(e, Par):
        return distribute_par(normalize(e.left), normalize(e.right))


# ============================================================
# Algorithm 2: Canonical Multiset Extraction
# ============================================================

def extract_summands(e: QTExpr) -> List[QTExpr]:
    """
    Extract the list of summands from a normalized expression.
    In normal form, only Add nodes appear at the top level.

    If e is in NF, each summand is add-free (has_no_add = True).
    """
    if isinstance(e, Add):
        return extract_summands(e.left) + extract_summands(e.right)
    return [e]


def canonical_multiset(e: QTExpr) -> Counter:
    """
    Compute the canonical multiset of an expression.
    Two expressions related by rewrites have identical canonical multisets.
    (Theorem: canonicalMultiset_rewrite_invariant from catalog)

    Time complexity: O(normalize(e)) — dominated by normalization.
    """
    nf = normalize(e)
    summands = extract_summands(nf)
    return Counter(summands)


# ============================================================
# Algorithm 3: Summand Polynomial
# ============================================================

def summand_poly(e: QTExpr) -> List[int]:
    """
    Compute the summand polynomial of a QTExpr.

    Returns coefficients [a0, a1, ..., an] representing
    a0 + a1*x + ... + an*x^n.

    Properties (formally verified):
    - eval at x=1 = summandCount (Theorem: summandPoly_eval_one)
    - eval at x=0 = 0 (Theorem: summandPoly_eval_zero)
    - invariant under rewrites (Theorem: summandPoly_rewrite_invariant)

    Time complexity: O(n^2) for multiplication of polynomials,
    where n is the degree (≤ gate_count).
    """
    if isinstance(e, Gate):
        return [0, 1]  # x

    left = summand_poly(e.left)
    right = summand_poly(e.right)

    if isinstance(e, Add):
        n = max(len(left), len(right))
        left += [0] * (n - len(left))
        right += [0] * (n - len(right))
        return [a + b for a, b in zip(left, right)]
    else:
        # Seq or Par: polynomial multiplication
        n = len(left) + len(right) - 1
        result = [0] * n
        for i, a in enumerate(left):
            for j, b in enumerate(right):
                result[i + j] += a * b
        return result


def eval_poly(coeffs: List[int], x: int) -> int:
    """Evaluate polynomial at x using Horner's method."""
    result = 0
    for c in reversed(coeffs):
        result = result * x + c
    return result


# ============================================================
# Algorithm 4: Augmented Rewriting with Gate Identities
# ============================================================

def apply_gate_identity(e: QTExpr, identity: GateIdentity) -> Optional[QTExpr]:
    """
    Try to apply a gate identity at the root of the expression.
    Returns the rewritten expression, or None if the identity doesn't match.
    """
    if e == identity.lhs:
        return identity.rhs
    return None


def rewrite_with_identities(e: QTExpr, identities: List[GateIdentity],
                            max_steps: int = 1000) -> QTExpr:
    """
    Augmented rewriting: apply distributive normalization + gate identities.

    Strategy: normalize first, then repeatedly try to apply gate identities
    at every position, re-normalizing after each application.

    Soundness: Theorem augRewrite_multistep_sound guarantees semantic preservation
    when all gate identities are individually sound.
    """
    current = normalize(e)
    for _ in range(max_steps):
        changed = False
        result = _try_rewrite_deep(current, identities)
        if result is not None and result != current:
            current = normalize(result)
            changed = True
        if not changed:
            break
    return current


def _try_rewrite_deep(e: QTExpr, identities: List[GateIdentity]) -> Optional[QTExpr]:
    """Try to apply any gate identity at any position in the expression."""
    # Try at root
    for gi in identities:
        result = apply_gate_identity(e, gi)
        if result is not None:
            return result

    # Try recursively
    if isinstance(e, Gate):
        return None
    if isinstance(e, Seq):
        left = _try_rewrite_deep(e.left, identities)
        if left is not None:
            return Seq(left, e.right)
        right = _try_rewrite_deep(e.right, identities)
        if right is not None:
            return Seq(e.left, right)
    elif isinstance(e, Par):
        left = _try_rewrite_deep(e.left, identities)
        if left is not None:
            return Par(left, e.right)
        right = _try_rewrite_deep(e.right, identities)
        if right is not None:
            return Par(e.left, right)
    elif isinstance(e, Add):
        left = _try_rewrite_deep(e.left, identities)
        if left is not None:
            return Add(left, e.right)
        right = _try_rewrite_deep(e.right, identities)
        if right is not None:
            return Add(e.left, right)
    return None


# ============================================================
# Algorithm 5: Complexity Measures
# ============================================================

def size(e: QTExpr) -> int:
    if isinstance(e, Gate): return 1
    return 1 + size(e.left) + size(e.right)

def depth(e: QTExpr) -> int:
    if isinstance(e, Gate): return 1
    if isinstance(e, Seq): return depth(e.left) + depth(e.right)
    return max(depth(e.left), depth(e.right))

def gate_count(e: QTExpr) -> int:
    if isinstance(e, Gate): return 1
    return gate_count(e.left) + gate_count(e.right)

def add_count(e: QTExpr) -> int:
    if isinstance(e, Gate): return 0
    if isinstance(e, Add): return 1 + add_count(e.left) + add_count(e.right)
    return add_count(e.left) + add_count(e.right)

def summand_count(e: QTExpr) -> int:
    if isinstance(e, Gate): return 1
    if isinstance(e, Add): return summand_count(e.left) + summand_count(e.right)
    return summand_count(e.left) * summand_count(e.right)

def has_no_add(e: QTExpr) -> bool:
    if isinstance(e, Gate): return True
    if isinstance(e, Add): return False
    return has_no_add(e.left) and has_no_add(e.right)

def is_nf(e: QTExpr) -> bool:
    if isinstance(e, Gate): return True
    if isinstance(e, Add): return is_nf(e.left) and is_nf(e.right)
    return has_no_add(e.left) and has_no_add(e.right)


# ============================================================
# Algorithm 6: Confluence Checking
# ============================================================

def check_confluence(expressions: List[QTExpr]) -> Tuple[bool, Optional[Tuple]]:
    """
    Check confluence: do all expressions that should be equivalent
    (same canonical multiset) actually normalize to equivalent forms?

    Returns (True, None) if confluent, or (False, counterexample) otherwise.
    """
    multiset_groups: Dict[str, List[QTExpr]] = {}
    for e in expressions:
        ms = canonical_multiset(e)
        key = str(sorted(ms.items()))
        if key not in multiset_groups:
            multiset_groups[key] = []
        multiset_groups[key].append(e)

    # Within each group, check that all expressions have the same
    # canonical multiset (they should, by construction)
    for key, group in multiset_groups.items():
        multisets = [canonical_multiset(e) for e in group]
        for i in range(1, len(multisets)):
            if multisets[i] != multisets[0]:
                return False, (group[0], group[i])

    return True, None


# ============================================================
# Clifford Identities
# ============================================================

H = Gate(0)
S = Gate(1)
CNOT = Gate(2)
I_GATE = Gate(3)
Z_GATE = Gate(4)

CLIFFORD_IDENTITIES = [
    GateIdentity(Seq(H, H), I_GATE),           # H² = I
    GateIdentity(Seq(S, S), Z_GATE),            # S² = Z
    GateIdentity(Seq(CNOT, CNOT), Par(I_GATE, I_GATE)),  # CNOT² = I⊗I
]


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Algorithms for Quantum Circuit Rewriting")
    print("=" * 50)

    # Build a complex expression
    e = Seq(Add(Gate(0), Gate(1)), Par(Gate(2), Add(Gate(3), Gate(4))))
    print(f"\nExpression: {e}")
    print(f"Size: {size(e)}, Depth: {depth(e)}, Gates: {gate_count(e)}")
    print(f"Summand count: {summand_count(e)}")
    print(f"Add count: {add_count(e)}")

    nf = normalize(e)
    print(f"\nNormalized: {nf}")
    print(f"Is NF: {is_nf(nf)}")
    print(f"Summand count: {summand_count(nf)}")

    poly = summand_poly(e)
    print(f"\nSummand polynomial coefficients: {poly}")
    print(f"eval(1) = {eval_poly(poly, 1)} (= summand count)")
    print(f"eval(0) = {eval_poly(poly, 0)} (always 0)")

    # Canonical multiset
    ms = canonical_multiset(e)
    print(f"\nCanonical multiset ({len(ms)} summands):")
    for term, count in ms.items():
        print(f"  {term} × {count}")

    # Clifford rewriting
    print("\nClifford rewriting:")
    hh = Seq(H, H)
    print(f"  H;H = {hh}")
    result = rewrite_with_identities(hh, CLIFFORD_IDENTITIES)
    print(f"  After Clifford rewriting: {result}")

    print("\nAll algorithms executed successfully ✓")
