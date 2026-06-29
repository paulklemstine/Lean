#!/usr/bin/env python3
"""
algorithms.py — Algorithms for clause space counting, width spectrum
analysis, and proof complexity bounds.

Implements the combinatorial counting procedures underlying the
width-to-size conversion theorem for tree-like resolution.
"""

from math import comb, log2, floor, ceil
from typing import List, Tuple, Dict, Set, Optional
from itertools import combinations, product


# ─────────────────────────────────────────────────
# Algorithm 1: Clause Space Bound Computation
# ─────────────────────────────────────────────────

def clause_space_bound(n: int, w: int) -> int:
    """
    Compute the number of distinct clauses over n variables with width ≤ w.
    
    Algorithm: Direct summation of C(n,k) * 2^k for k = 0, ..., min(w, n).
    
    Time complexity: O(min(w, n))
    Space complexity: O(1)
    
    Args:
        n: Number of propositional variables
        w: Maximum clause width
    
    Returns:
        Sum_{k=0}^{min(w,n)} C(n,k) * 2^k
    
    >>> clause_space_bound(5, 2)
    51
    >>> clause_space_bound(0, 5)
    1
    """
    return sum(comb(n, k) * (2 ** k) for k in range(min(w, n) + 1))


def clause_space_bound_incremental(n: int, w: int) -> List[int]:
    """
    Compute clauseSpaceBound(n, k) for k = 0, ..., w incrementally.
    
    Uses the recurrence: CSB(n, k+1) = CSB(n, k) + C(n, k+1) * 2^{k+1}
    
    Time complexity: O(w)
    Space complexity: O(w)
    
    Args:
        n: Number of variables
        w: Maximum width to compute
    
    Returns:
        List where result[k] = clauseSpaceBound(n, k)
    """
    result = [1]  # CSB(n, 0) = 1
    current = 1
    for k in range(1, w + 1):
        increment = comb(n, k) * (2 ** k)
        current += increment
        result.append(current)
    return result


# ─────────────────────────────────────────────────
# Algorithm 2: Clause Code Enumeration
# ─────────────────────────────────────────────────

def enumerate_clause_codes(n: int, w: int) -> List[Tuple[Tuple[int, ...], Tuple[bool, ...]]]:
    """
    Enumerate all clause codes (support, polarity) with width ≤ w over n variables.
    
    A clause code consists of:
    - A support: a subset of {0, ..., n-1} of size ≤ w
    - A polarity: an assignment of True/False to each variable in the support
    
    Time complexity: O(clauseSpaceBound(n, w))
    Space complexity: O(clauseSpaceBound(n, w))
    
    Args:
        n: Number of variables
        w: Maximum width
    
    Returns:
        List of (support, polarity) pairs
    
    >>> len(enumerate_clause_codes(3, 2))
    22
    """
    codes = []
    variables = list(range(n))
    
    for k in range(min(w, n) + 1):
        for support in combinations(variables, k):
            for polarity in product([True, False], repeat=k):
                codes.append((support, polarity))
    
    return codes


def clause_code_to_clause(code: Tuple[Tuple[int, ...], Tuple[bool, ...]], 
                           var_names: Optional[List[str]] = None) -> str:
    """
    Convert a clause code to a human-readable clause string.
    
    Args:
        code: (support, polarity) pair
        var_names: Optional variable names (default: x0, x1, ...)
    
    Returns:
        String representation like "{x0, ¬x2, x5}"
    """
    support, polarity = code
    if not support:
        return "∅ (empty clause)"
    
    literals = []
    for var, pol in zip(support, polarity):
        name = var_names[var] if var_names else f"x{var}"
        literals.append(name if pol else f"¬{name}")
    
    return "{" + ", ".join(literals) + "}"


# ─────────────────────────────────────────────────
# Algorithm 3: Width Spectrum Analysis
# ─────────────────────────────────────────────────

class ResolutionTree:
    """
    A tree-resolution proof node.
    
    Represents the tree structure used in tree-like resolution proofs.
    Each node is either:
    - A hypothesis (leaf) with a clause from the formula
    - A weakening step
    - A resolution step on a variable
    """
    
    def __init__(self, clause: frozenset, kind: str = "hyp",
                 children=None, resolve_var=None):
        self.clause = clause  # The clause derived at this node
        self.kind = kind       # "hyp", "weaken", or "resolve"
        self.children = children or []
        self.resolve_var = resolve_var
    
    @property
    def size(self) -> int:
        """Number of nodes in the tree."""
        return 1 + sum(c.size for c in self.children)
    
    @property
    def max_width(self) -> int:
        """Maximum clause width in the tree."""
        self_width = len(self.clause)
        child_widths = [c.max_width for c in self.children]
        return max([self_width] + child_widths)
    
    @property
    def num_leaves(self) -> int:
        """Number of leaf nodes."""
        if not self.children:
            return 1
        return sum(c.num_leaves for c in self.children)
    
    def all_clauses(self) -> Set[frozenset]:
        """Set of all distinct clauses in the tree."""
        result = {self.clause}
        for child in self.children:
            result |= child.all_clauses()
        return result
    
    def width_spectrum(self) -> Dict[int, int]:
        """
        Compute the width spectrum: for each width w, count how many
        distinct clauses of that width appear in the tree.
        
        Returns:
            Dictionary mapping width -> count of distinct clauses
        """
        spectrum: Dict[int, int] = {}
        for clause in self.all_clauses():
            w = len(clause)
            spectrum[w] = spectrum.get(w, 0) + 1
        return spectrum


def build_php_refutation(n: int) -> Optional[ResolutionTree]:
    """
    Build a simple tree-resolution refutation of PHP(n+1, n) for small n.
    
    This constructs a brute-force refutation for n=1 (PHP(2,1)).
    
    For n=1: PHP(2,1) has variables p(0,0), p(1,0).
    Clauses: {p(0,0)}, {p(1,0)}, {¬p(0,0), ¬p(1,0)}
    
    Refutation:
    1. Resolve {p(0,0)} with {¬p(0,0), ¬p(1,0)} on p(0,0) → {¬p(1,0)}
    2. Resolve {¬p(1,0)} with {p(1,0)} on p(1,0) → ∅
    """
    if n == 1:
        # Variables: p(0,0) = "a", p(1,0) = "b"
        a_pos = ("a", True)
        a_neg = ("a", False)
        b_pos = ("b", True)
        b_neg = ("b", False)
        
        # Hypothesis clauses
        h1 = ResolutionTree(frozenset({a_pos}), "hyp")       # {a}
        h2 = ResolutionTree(frozenset({b_pos}), "hyp")       # {b}
        h3 = ResolutionTree(frozenset({a_neg, b_neg}), "hyp") # {¬a, ¬b}
        
        # Resolve h1 with h3 on 'a': {b_neg} = {¬b}
        r1 = ResolutionTree(
            frozenset({b_neg}), "resolve",
            children=[h1, h3], resolve_var="a"
        )
        
        # Resolve r1 with h2 on 'b': ∅
        r2 = ResolutionTree(
            frozenset(), "resolve",
            children=[r1, h2], resolve_var="b"
        )
        
        return r2
    
    return None  # Only implemented for n=1


# ─────────────────────────────────────────────────
# Algorithm 4: Lower Bound Computation
# ─────────────────────────────────────────────────

def tree_resolution_size_lower_bound(max_width: int) -> int:
    """
    Lower bound on tree-resolution refutation size given the maximum width.
    
    By our formalized theorem: for any refutation deriving ∅,
    size ≥ maxWidth + 1.
    
    Args:
        max_width: The maximum width of any clause in the refutation
    
    Returns:
        Lower bound on the number of nodes in the proof tree
    """
    return max_width + 1


def php_bounds_table(max_n: int = 15) -> List[Dict]:
    """
    Compute a table of PHP(n+1, n) bounds.
    
    For each n, computes:
    - Width lower bound (≥ n)
    - Size lower bound (≥ n + 1)
    - clauseSpaceBound at the width lower bound
    - Entropy bound
    
    Returns:
        List of dictionaries with bound data
    """
    results = []
    for n in range(1, max_n + 1):
        num_vars = (n + 1) * n
        w_lb = n
        s_lb = n + 1
        csb = clause_space_bound(num_vars, w_lb)
        entropy = log2(csb) if csb > 1 else 0.0
        
        results.append({
            "n": n,
            "pigeons": n + 1,
            "holes": n,
            "variables": num_vars,
            "width_lower_bound": w_lb,
            "size_lower_bound": s_lb,
            "clause_space_bound": csb,
            "entropy_bound": entropy,
        })
    
    return results


# ─────────────────────────────────────────────────
# Main demonstration
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    
    # Demo 1: Clause code enumeration
    print("\n--- Clause Code Enumeration (n=3, w=1) ---")
    codes = enumerate_clause_codes(3, 1)
    print(f"Total codes: {len(codes)} (expected: {clause_space_bound(3, 1)})")
    for code in codes:
        print(f"  {clause_code_to_clause(code)}")
    
    # Demo 2: Width spectrum for PHP(2,1)
    print("\n--- Width Spectrum for PHP(2,1) Refutation ---")
    tree = build_php_refutation(1)
    if tree:
        print(f"Size: {tree.size}")
        print(f"Max width: {tree.max_width}")
        print(f"Num leaves: {tree.num_leaves}")
        print(f"Distinct clauses: {len(tree.all_clauses())}")
        spectrum = tree.width_spectrum()
        print("Width spectrum:")
        for w in sorted(spectrum.keys()):
            print(f"  Width {w}: {spectrum[w]} clause(s)")
    
    # Demo 3: PHP bounds table
    print("\n--- PHP(n+1, n) Lower Bounds ---")
    bounds = php_bounds_table(10)
    print(f"{'n':>3} {'W≥':>5} {'S≥':>5} {'CSB':>15} {'Entropy':>10}")
    print("-" * 40)
    for b in bounds:
        print(f"{b['n']:>3} {b['width_lower_bound']:>5} {b['size_lower_bound']:>5} "
              f"{b['clause_space_bound']:>15} {b['entropy_bound']:>10.2f}")
    
    # Demo 4: 3^n verification
    print("\n--- Verification: clauseSpaceBound(n, n) = 3^n ---")
    for n in range(8):
        csb = clause_space_bound(n, n)
        expected = 3 ** n
        status = "✓" if csb == expected else "✗"
        print(f"  n={n}: CSB={csb}, 3^n={expected} {status}")
