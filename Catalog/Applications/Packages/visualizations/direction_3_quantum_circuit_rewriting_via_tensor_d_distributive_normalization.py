#!/usr/bin/env python3
"""
algorithms.py — Certified Normalization and Equivalence Checking Algorithms

Implements the distributive normalization algorithm for quantum tensor expressions
with complexity analysis and equivalence checking primitives.

Time complexity:
  - normalize(e): O(n · p) where n = size of expression, p = product of summand counts
  - equivalence check: O(normalize(e1) + normalize(e2) + sort) 

Space complexity: O(summandCount(e)) for the normalized expression
"""

import numpy as np
from collections import Counter
from typing import Optional


# ═══════════════════════════════════════════════════════════════
# Core Expression Types (self-contained)
# ═══════════════════════════════════════════════════════════════

class QExpr:
    """Base class for quantum tensor expressions."""
    pass

class Gate(QExpr):
    def __init__(self, name: str):
        self.name = name
    def __repr__(self): return self.name
    def __eq__(self, other): return isinstance(other, Gate) and self.name == other.name
    def __hash__(self): return hash(('G', self.name))
    def size(self) -> int: return 1

class Seq(QExpr):
    def __init__(self, l: QExpr, r: QExpr):
        self.left, self.right = l, r
    def __repr__(self): return f"({self.left};{self.right})"
    def __eq__(self, other): return isinstance(other, Seq) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('S', self.left, self.right))
    def size(self) -> int: return 1 + self.left.size() + self.right.size()

class Par(QExpr):
    def __init__(self, l: QExpr, r: QExpr):
        self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊗{self.right})"
    def __eq__(self, other): return isinstance(other, Par) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('P', self.left, self.right))
    def size(self) -> int: return 1 + self.left.size() + self.right.size()

class Add(QExpr):
    def __init__(self, l: QExpr, r: QExpr):
        self.left, self.right = l, r
    def __repr__(self): return f"({self.left}+{self.right})"
    def __eq__(self, other): return isinstance(other, Add) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('A', self.left, self.right))
    def size(self) -> int: return 1 + self.left.size() + self.right.size()


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Distributive Normalization
# ═══════════════════════════════════════════════════════════════

def distribute_seq(a: QExpr, b: QExpr) -> QExpr:
    """
    Distribute sequential composition over addition.
    
    Pseudocode:
        distributeSeq(Add(a,b), c) = Add(distributeSeq(a,c), distributeSeq(b,c))
        distributeSeq(a, Add(b,c)) = Add(distributeSeq(a,b), distributeSeq(a,c))
        distributeSeq(a, b)        = Seq(a, b)
    
    Complexity: O(|summands(a)| * |summands(b)|)
    Termination: decreasing on a.size() + b.size()
    """
    if isinstance(a, Add):
        return Add(distribute_seq(a.left, b), distribute_seq(a.right, b))
    elif isinstance(b, Add):
        return Add(distribute_seq(a, b.left), distribute_seq(a, b.right))
    else:
        return Seq(a, b)


def distribute_par(a: QExpr, b: QExpr) -> QExpr:
    """
    Distribute parallel/tensor composition over addition.
    
    Complexity: O(|summands(a)| * |summands(b)|)
    """
    if isinstance(a, Add):
        return Add(distribute_par(a.left, b), distribute_par(a.right, b))
    elif isinstance(b, Add):
        return Add(distribute_par(a, b.left), distribute_par(a, b.right))
    else:
        return Par(a, b)


def normalize(expr: QExpr) -> QExpr:
    """
    Distributive normalization: transform an expression into a sum of 
    add-free products by fully distributing seq and par over add.
    
    VERIFIED PROPERTIES (proved in Lean 4):
    1. normalize_sound:  denote(normalize(e)) = denote(e)
    2. normalize_isNF:   IsQuantumNormalForm(normalize(e))
    3. Summand count is preserved
    
    Pseudocode:
        normalize(Gate(n))    = Gate(n)
        normalize(Add(a,b))   = Add(normalize(a), normalize(b))
        normalize(Seq(a,b))   = distributeSeq(normalize(a), normalize(b))
        normalize(Par(a,b))   = distributePar(normalize(a), normalize(b))
    
    Time:  O(n * product of summand counts along each composition)
    Space: O(summandCount(e))
    """
    if isinstance(expr, Gate):
        return expr
    elif isinstance(expr, Add):
        return Add(normalize(expr.left), normalize(expr.right))
    elif isinstance(expr, Seq):
        return distribute_seq(normalize(expr.left), normalize(expr.right))
    elif isinstance(expr, Par):
        return distribute_par(normalize(expr.left), normalize(expr.right))
    raise TypeError(f"Unknown type: {type(expr)}")


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Canonical Multiset Computation
# ═══════════════════════════════════════════════════════════════

def canonical_multiset(expr: QExpr) -> Counter:
    """
    Compute the canonical multiset of summands.
    
    VERIFIED PROPERTY (proved in Lean 4):
    - canonicalMultiset_step_invariant: preserved by one-step rewrites
    - canonicalMultiset_rewrite_invariant: preserved by multi-step rewrites
    
    Returns a Counter (multiset) of string representations of atomic products.
    
    Time: O(summandCount(e) * max_product_size)
    """
    if isinstance(expr, Gate):
        return Counter([repr(expr)])
    elif isinstance(expr, Add):
        left = canonical_multiset(expr.left)
        right = canonical_multiset(expr.right)
        return left + right
    elif isinstance(expr, Seq):
        left_ms = canonical_multiset(expr.left)
        right_ms = canonical_multiset(expr.right)
        result = Counter()
        for l_term, l_count in left_ms.items():
            for r_term, r_count in right_ms.items():
                combined = f"({l_term};{r_term})"
                result[combined] += l_count * r_count
        return result
    elif isinstance(expr, Par):
        left_ms = canonical_multiset(expr.left)
        right_ms = canonical_multiset(expr.right)
        result = Counter()
        for l_term, l_count in left_ms.items():
            for r_term, r_count in right_ms.items():
                combined = f"({l_term}⊗{r_term})"
                result[combined] += l_count * r_count
        return result
    raise TypeError(f"Unknown type: {type(expr)}")


def summand_count(expr: QExpr) -> int:
    """
    Count summands in the fully distributed form.
    
    VERIFIED PROPERTY: 
    - summandCount_rewrite_invariant: preserved by all rewrites
    - canonicalMultiset_card: equals |canonicalMultiset(e)|
    """
    if isinstance(expr, Gate): return 1
    elif isinstance(expr, Add): return summand_count(expr.left) + summand_count(expr.right)
    elif isinstance(expr, (Seq, Par)): return summand_count(expr.left) * summand_count(expr.right)
    return 0


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Equivalence Checking
# ═══════════════════════════════════════════════════════════════

def are_rewrite_equivalent(e1: QExpr, e2: QExpr) -> bool:
    """
    Check if two expressions are rewrite-equivalent by comparing
    their canonical multisets.
    
    SOUNDNESS: If this returns True, then for ANY ring A with bilinear
    parallel operation, denote(e1) = denote(e2). This follows from
    canonicalMultiset_rewrite_invariant and denoteMultiset_canonicalMultiset.
    
    NOTE: This is sound but not complete — two expressions may have the
    same denotation without being rewrite-equivalent.
    
    Time: O(normalize(e1) + normalize(e2))
    """
    return canonical_multiset(e1) == canonical_multiset(e2)


def check_semantic_equivalence(e1: QExpr, e2: QExpr, 
                                gate_matrices: dict) -> bool:
    """
    Check semantic equivalence by numerical matrix comparison.
    
    This is complete for the given gate set but not certified.
    """
    def denote(expr):
        if isinstance(expr, Gate):
            return gate_matrices[expr.name]
        elif isinstance(expr, Seq):
            return denote(expr.left) @ denote(expr.right)
        elif isinstance(expr, Par):
            return np.kron(denote(expr.left), denote(expr.right))
        elif isinstance(expr, Add):
            return denote(expr.left) + denote(expr.right)
    
    return np.allclose(denote(e1), denote(e2), atol=1e-10)


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Circuit Depth and Complexity Analysis
# ═══════════════════════════════════════════════════════════════

def circuit_depth(expr: QExpr) -> int:
    """Compute the depth of a circuit expression."""
    if isinstance(expr, Gate): return 1
    elif isinstance(expr, Seq): return circuit_depth(expr.left) + circuit_depth(expr.right)
    elif isinstance(expr, Par): return max(circuit_depth(expr.left), circuit_depth(expr.right))
    elif isinstance(expr, Add): return max(circuit_depth(expr.left), circuit_depth(expr.right))
    return 0


def has_no_add(expr: QExpr) -> bool:
    """Check if an expression contains no Add nodes."""
    if isinstance(expr, Gate): return True
    elif isinstance(expr, Add): return False
    elif isinstance(expr, (Seq, Par)):
        return has_no_add(expr.left) and has_no_add(expr.right)
    return False


def is_normal_form(expr: QExpr) -> bool:
    """Check if an expression is in distributive normal form."""
    if isinstance(expr, Gate): return True
    elif isinstance(expr, Add):
        return is_normal_form(expr.left) and is_normal_form(expr.right)
    elif isinstance(expr, (Seq, Par)):
        return has_no_add(expr.left) and has_no_add(expr.right)
    return False


# ═══════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=== Distributive Normalization Algorithm ===\n")
    
    # Build a circuit with superposition
    e1 = Seq(Add(Gate('H'), Gate('T')), Add(Gate('CNOT'), Gate('I')))
    print(f"Expression: {e1}")
    print(f"Summand count: {summand_count(e1)}")
    
    n1 = normalize(e1)
    print(f"Normalized:  {n1}")
    print(f"Is NF: {is_normal_form(n1)}")
    print(f"Canonical multiset: {dict(canonical_multiset(e1))}")
    
    # Two different orderings of the same distributivity
    e2 = Add(Add(Seq(Gate('H'), Gate('CNOT')), Seq(Gate('H'), Gate('I'))),
             Add(Seq(Gate('T'), Gate('CNOT')), Seq(Gate('T'), Gate('I'))))
    
    print(f"\nAnother expression: {e2}")
    print(f"Canonical multiset: {dict(canonical_multiset(e2))}")
    print(f"Rewrite equivalent: {are_rewrite_equivalent(e1, e2)}")
    
    print("\n=== Equivalence Checking ===")
    # These should be rewrite-equivalent
    e3 = Seq(Gate('H'), Add(Gate('T'), Gate('I')))
    e4 = Add(Seq(Gate('H'), Gate('T')), Seq(Gate('H'), Gate('I')))
    print(f"\n{e3}")
    print(f"  ≡ {e4}")
    print(f"  Rewrite equivalent: {are_rewrite_equivalent(e3, e4)}")
