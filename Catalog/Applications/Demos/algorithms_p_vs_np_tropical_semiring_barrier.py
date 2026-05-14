#!/usr/bin/env python3
"""
Algorithms for Tropical Semiring Barrier Analysis

Implements:
1. Tropical expression evaluation
2. Tropical monotonicity testing
3. Boolean function classification
4. Oscillation complexity measurement
5. Tropical expression enumeration and search
"""

from itertools import product
from typing import Callable, Dict, List, Optional, Tuple, Set
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 1: Tropical Expression Evaluation
# ═══════════════════════════════════════════════════════════════════════════

@dataclass
class TropExpr:
    """Base class for tropical expressions."""
    pass

@dataclass
class Const(TropExpr):
    """Constant tropical expression."""
    value: int
    
    def eval(self, assignment: List[int]) -> int:
        """Evaluate: returns the constant value. O(1)."""
        return self.value
    
    def size(self) -> int:
        return 1
    
    def depth(self) -> int:
        return 0
    
    def __repr__(self) -> str:
        return str(self.value)

@dataclass
class Var(TropExpr):
    """Variable reference."""
    index: int
    
    def eval(self, assignment: List[int]) -> int:
        """Evaluate: returns the variable's value. O(1)."""
        return assignment[self.index]
    
    def size(self) -> int:
        return 1
    
    def depth(self) -> int:
        return 0
    
    def __repr__(self) -> str:
        return f"x{self.index}"

@dataclass
class TMin(TropExpr):
    """Tropical addition: min(e1, e2)."""
    left: TropExpr
    right: TropExpr
    
    def eval(self, assignment: List[int]) -> int:
        """Evaluate: returns min of children. O(size)."""
        return min(self.left.eval(assignment), self.right.eval(assignment))
    
    def size(self) -> int:
        return 1 + self.left.size() + self.right.size()
    
    def depth(self) -> int:
        return 1 + max(self.left.depth(), self.right.depth())
    
    def __repr__(self) -> str:
        return f"min({self.left}, {self.right})"

@dataclass
class TAdd(TropExpr):
    """Tropical multiplication: e1 + e2."""
    left: TropExpr
    right: TropExpr
    
    def eval(self, assignment: List[int]) -> int:
        """Evaluate: returns sum of children. O(size)."""
        return self.left.eval(assignment) + self.right.eval(assignment)
    
    def size(self) -> int:
        return 1 + self.left.size() + self.right.size()
    
    def depth(self) -> int:
        return 1 + max(self.left.depth(), self.right.depth())
    
    def __repr__(self) -> str:
        return f"({self.left} + {self.right})"


def eval_tropical(expr: TropExpr, assignment: List[int]) -> int:
    """
    Algorithm 1: Evaluate a tropical expression.
    
    Time complexity: O(size(expr))
    Space complexity: O(depth(expr)) for recursion stack
    
    Args:
        expr: A tropical expression
        assignment: Variable values as a list of non-negative integers
    
    Returns:
        The evaluation result (non-negative integer)
    
    Example:
        >>> e = TMin(TAdd(Var(0), Var(1)), Const(3))
        >>> eval_tropical(e, [1, 2])  # min(1+2, 3) = 3
        3
    """
    return expr.eval(assignment)


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Monotonicity Testing
# ═══════════════════════════════════════════════════════════════════════════

def bool_enc(b: bool) -> int:
    """Boolean encoding: true → 0, false → 1."""
    return 0 if b else 1

def lift_bool(v: Tuple[bool, ...]) -> List[int]:
    """Lift Boolean assignment to tropical assignment."""
    return [bool_enc(b) for b in v]


def test_trop_monotone(
    f: Callable[[Tuple[bool, ...]], int],
    n: int
) -> Tuple[bool, Optional[Tuple[Tuple[bool, ...], Tuple[bool, ...]]]]:
    """
    Algorithm 2: Test if a Boolean function is tropically monotone.
    
    A function f is tropically monotone if:
      for all u, v: (∀i, boolEnc(u[i]) ≤ boolEnc(v[i])) → f(u) ≤ f(v)
    
    Time complexity: O(4^n · n)
    Space complexity: O(2^n)
    
    Args:
        f: Boolean function (Tuple[bool,...]) → int
        n: Number of variables
    
    Returns:
        (True, None) if monotone
        (False, (u, v)) if not monotone, with witnessing pair
    
    Example:
        >>> test_trop_monotone(lambda v: 0 if sum(v)%2==1 else 1, 3)
        (False, ...)
    """
    assignments = list(product([True, False], repeat=n))
    
    for u in assignments:
        enc_u = [bool_enc(b) for b in u]
        for v in assignments:
            enc_v = [bool_enc(b) for b in v]
            # Check encoding order
            if all(enc_u[i] <= enc_v[i] for i in range(n)):
                if f(u) > f(v):
                    return False, (u, v)
    
    return True, None


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 3: Oscillation Complexity
# ═══════════════════════════════════════════════════════════════════════════

def oscillation_complexity(
    f: Callable[[Tuple[bool, ...]], int],
    n: int
) -> int:
    """
    Algorithm 3: Compute the oscillation complexity of a Boolean function.
    
    The oscillation complexity is the maximum number of value changes
    along any monotone path in the Boolean cube (paths that add one
    'true' at each step).
    
    Time complexity: O(n! · n)
    Space complexity: O(n)
    
    Args:
        f: Boolean function
        n: Number of variables
    
    Returns:
        Maximum number of oscillations across all monotone paths
    
    Example:
        >>> oscillation_complexity(lambda v: 0 if sum(v)%2==1 else 1, 4)
        4
    """
    from itertools import permutations
    
    max_osc = 0
    
    for perm in permutations(range(n)):
        # Build monotone path: start all-false, set perm[0], perm[1], ...
        current = [False] * n
        prev_val = f(tuple(current))
        oscillations = 0
        
        for idx in perm:
            current[idx] = True
            curr_val = f(tuple(current))
            if curr_val != prev_val:
                oscillations += 1
            prev_val = curr_val
        
        max_osc = max(max_osc, oscillations)
    
    return max_osc


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 4: Boolean Function Classification
# ═══════════════════════════════════════════════════════════════════════════

@dataclass
class FunctionProfile:
    """Complete profile of a Boolean function's tropical properties."""
    name: str
    n: int
    is_monotone: bool
    is_representable: bool  # implied by monotonicity analysis
    oscillation: int
    witness: Optional[Tuple[Tuple[bool, ...], Tuple[bool, ...]]]
    truth_table: Dict[Tuple[bool, ...], int]


def classify_function(
    name: str,
    f: Callable[[Tuple[bool, ...]], int],
    n: int
) -> FunctionProfile:
    """
    Algorithm 4: Classify a Boolean function's tropical properties.
    
    Determines monotonicity, representability, and oscillation complexity.
    
    Time complexity: O(4^n · n + n! · n)
    Space complexity: O(2^n)
    
    Args:
        name: Human-readable function name
        f: Boolean function
        n: Number of variables
    
    Returns:
        Complete FunctionProfile
    """
    mono, witness = test_trop_monotone(f, n)
    osc = oscillation_complexity(f, n) if n <= 8 else -1
    
    truth_table = {}
    for v in product([True, False], repeat=n):
        truth_table[v] = f(v)
    
    return FunctionProfile(
        name=name,
        n=n,
        is_monotone=mono,
        is_representable=mono,  # by our theorem: monotone ↔ representable
        oscillation=osc,
        witness=witness,
        truth_table=truth_table
    )


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 5: Tropical Expression Enumeration
# ═══════════════════════════════════════════════════════════════════════════

def enumerate_expressions(
    n: int,
    max_size: int,
    max_const: int = 2
) -> List[TropExpr]:
    """
    Algorithm 5: Enumerate all tropical expressions up to a given size.
    
    Time complexity: O(C^max_size) where C depends on n and max_const
    Space complexity: O(C^max_size)
    
    Args:
        n: Number of variables
        max_size: Maximum expression size
        max_const: Maximum constant value
    
    Returns:
        List of all tropical expressions with size ≤ max_size
    """
    by_size: Dict[int, List[TropExpr]] = {}
    
    # Size 1: constants and variables
    by_size[1] = [Const(c) for c in range(max_const + 1)] + \
                 [Var(i) for i in range(n)]
    
    for s in range(2, max_size + 1):
        if s not in by_size:
            by_size[s] = []
        for s1 in range(1, s):
            s2 = s - 1 - s1
            if s2 < 1 or s2 not in by_size:
                continue
            for e1 in by_size[s1]:
                for e2 in by_size[s2]:
                    by_size[s].append(TMin(e1, e2))
                    by_size[s].append(TAdd(e1, e2))
    
    result = []
    for s in range(1, max_size + 1):
        result.extend(by_size.get(s, []))
    
    return result


def search_representation(
    f: Callable[[Tuple[bool, ...]], int],
    n: int,
    max_size: int = 7,
    max_const: int = 2
) -> Optional[TropExpr]:
    """
    Search for a tropical expression representing a Boolean function.
    
    Args:
        f: Target Boolean function
        n: Number of variables
        max_size: Maximum expression size to search
        max_const: Maximum constant value
    
    Returns:
        A tropical expression computing f, or None if not found
    """
    assignments = list(product([True, False], repeat=n))
    target = [f(v) for v in assignments]
    
    for expr in enumerate_expressions(n, max_size, max_const):
        values = [expr.eval(lift_bool(v)) for v in assignments]
        if values == target:
            return expr
    
    return None


# ═══════════════════════════════════════════════════════════════════════════
# Main: Run all algorithms
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Define test functions
    def parity(v):
        return 0 if sum(v) % 2 == 1 else 1
    
    def xor_2(v):
        return bool_enc(v[0] ^ v[1])
    
    def exact_one(v):
        return 0 if sum(v) == 1 else 1
    
    def and_fn(v):
        return 0 if all(v) else 1
    
    def or_fn(v):
        return 0 if any(v) else 1
    
    def majority(v):
        return 0 if sum(v) > len(v) / 2 else 1
    
    # Classify functions
    print("=" * 70)
    print("BOOLEAN FUNCTION CLASSIFICATION")
    print("=" * 70)
    
    tests = [
        ("AND", and_fn, 3),
        ("OR", or_fn, 3),
        ("Majority", majority, 3),
        ("Parity", parity, 3),
        ("XOR", xor_2, 2),
        ("Exact-One", exact_one, 3),
        ("Parity(n=4)", parity, 4),
    ]
    
    print(f"\n{'Function':<15s} {'n':>3s} {'Monotone':>10s} {'Representable':>14s} {'Oscillation':>12s}")
    print("-" * 60)
    
    for name, f, n in tests:
        profile = classify_function(name, f, n)
        mono_str = "Yes" if profile.is_monotone else "No"
        repr_str = "Yes" if profile.is_representable else "No"
        print(f"{profile.name:<15s} {profile.n:>3d} {mono_str:>10s} {repr_str:>14s} {profile.oscillation:>12d}")
        
        if profile.witness:
            u, v = profile.witness
            print(f"  Witness: u={u} (f={f(u)}), v={v} (f={f(v)})")
    
    # Search for representations of monotone functions
    print(f"\n{'=' * 70}")
    print("SEARCHING FOR TROPICAL REPRESENTATIONS (n=2)")
    print("=" * 70)
    
    for name, f in [("AND", and_fn), ("OR", or_fn), ("XOR", xor_2), ("Parity", parity)]:
        n_search = 2
        expr = search_representation(f, n_search, max_size=7)
        if expr:
            print(f"\n{name}: {expr}  (size={expr.size()})")
            for v in product([True, False], repeat=n_search):
                enc = lift_bool(v)
                print(f"  {v} → enc={enc} → eval={expr.eval(enc)} (target={f(v)})")
        else:
            print(f"\n{name}: No representation found (as expected from barrier theorem)")
    
    # Oscillation analysis
    print(f"\n{'=' * 70}")
    print("OSCILLATION COMPLEXITY ANALYSIS")
    print("=" * 70)
    
    for n in range(2, 6):
        osc = oscillation_complexity(parity, n)
        print(f"  Parity(n={n}): oscillation = {osc}")
    
    print("\nParity achieves maximal oscillation (= n), confirming it is")
    print("maximally non-monotone and cannot be tropically represented.")
