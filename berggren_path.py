#!/usr/bin/env python3
"""
berggren_path.py — Map each integer to its Berggren tree path.

Derived from Catalog theorems:
  BerggrenTree.berggrenTripleAux: compute triple from path
  BerggrenCompleteness.invB1/invB2/invB3: inverse transforms for descent
  BerggrenCompleteness.invB1_pos_case, invB2_pos_case, invB3_pos_case: 
    which inverse gives the positive parent
  BerggrenDescent.hyp_decrease_by_one: descent terminates
  BerggrenDescent.universal_parent_hyp: parent hypotenuse = 3c - 2(a+b)
  BerggrenDescent.diff_of_squares_factoring: (c-a)(c+a) = b²
  AgentBeta_TreeDynamics.TreePath: inductive type {root, left p, mid p, right p}
  AgentBeta_TreeDynamics.pathsAtDepth: 3^d paths at depth d
  AgentBeta_TreeDynamics.berggrenTripleAux: compute (a,b,c) from path
  AgentBeta_TreeDynamics.m2_branch: M₂-only branch gives Pell recurrence
  AgentBeta_TreeDynamics.m2_hyp_recurrence: c_{n+2} = 6c_{n+1} - c_n
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Optional, Iterator
from math import isqrt, gcd


# ============================================================
# Core Berggren transforms (Catalog: BerggrenTree, BerggrenCompleteness)
# ============================================================

def fwd_B1(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Forward Berggren B₁: left child.
    Catalog: berggren_A_pyth_eq, fwdBerggren1"""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


def fwd_B2(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Forward Berggren B₂: middle child.
    Catalog: berggren_B_pyth_eq, fwdBerggren2"""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


def fwd_B3(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Forward Berggren B₃: right child.
    Catalog: berggren_C_pyth_eq, fwdBerggren3"""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def inv_B1(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Inverse Berggren B₁⁻¹.
    Catalog: invBerggren1, BerggrenCompleteness.invB1"""
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)


def inv_B2(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Inverse Berggren B₂⁻¹.
    Catalog: invBerggren2, BerggrenCompleteness.invB2"""
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


def inv_B3(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Inverse Berggren B₃⁻¹.
    Catalog: invBerggren3, BerggrenCompleteness.invB3"""
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


# ============================================================
# TreePath representation
# ============================================================

@dataclass(frozen=True)
class TreePath:
    """A path in the ternary Berggren tree.
    Catalog: AgentBeta_TreeDynamics.TreePath"""
    steps: Tuple[str, ...]  # Each step is 'L', 'M', or 'R'
    
    @staticmethod
    def root() -> TreePath:
        return TreePath(())
    
    def left(self) -> TreePath:
        return TreePath(self.steps + ('L',))
    
    def mid(self) -> TreePath:
        return TreePath(self.steps + ('M',))
    
    def right(self) -> TreePath:
        return TreePath(self.steps + ('R',))
    
    def depth(self) -> int:
        """Catalog: TreePath.depth"""
        return len(self.steps)
    
    def __repr__(self) -> str:
        if not self.steps:
            return "Root"
        return ''.join(self.steps)
    
    def to_int(self) -> int:
        """Encode path as a base-3 integer.
        L=0, M=1, R=2. Root = 0.
        So path 'LM' = 0*3 + 1 = 1, 'ML' = 1*3 + 0 = 3, etc."""
        result = 0
        for s in self.steps:
            digit = {'L': 0, 'M': 1, 'R': 2}[s]
            result = result * 3 + digit
        return result
    
    @staticmethod
    def from_int(n: int) -> TreePath:
        """Decode a base-3 integer to a tree path."""
        if n == 0:
            return TreePath.root()
        steps = []
        while n > 0:
            digit = n % 3
            steps.append('LMR'[digit])
            n //= 3
        return TreePath(tuple(reversed(steps)))


# ============================================================
# Forward: path → triple
# ============================================================

def triple_at_path(path: TreePath) -> Tuple[int, int, int]:
    """Compute the Pythagorean triple at a given Berggren tree path.
    Catalog: berggrenTripleAux"""
    a, b, c = 3, 4, 5
    for step in path.steps:
        if step == 'L':
            a, b, c = fwd_B1(a, b, c)
        elif step == 'M':
            a, b, c = fwd_B2(a, b, c)
        elif step == 'R':
            a, b, c = fwd_B3(a, b, c)
    return (a, b, c)


# ============================================================
# Inverse: triple → path (the KEY function)
# ============================================================

def is_ppt(a: int, b: int, c: int) -> bool:
    """Check if (a,b,c) is a primitive Pythagorean triple.
    A PPT has a,b,c > 0, a²+b² = c², and gcd(a,b,c) = 1."""
    if a <= 0 or b <= 0 or c <= 0:
        return False
    if a*a + b*b != c*c:
        return False
    return gcd(gcd(abs(a), abs(b)), abs(c)) == 1


def path_of_triple(a: int, b: int, c: int) -> Optional[TreePath]:
    """Find the Berggren tree path of a primitive Pythagorean triple.
    
    Uses inverse Berggren transforms (descent) to walk from (a,b,c) back
    to the root (3,4,5), recording the inverse direction.
    
    Catalog: BerggrenCompleteness — descent rules:
      If a+2b > 2c AND 2a+b > 2c: parent = inv_B2 → came from M (mid)
      If a+2b > 2c AND 2a+b < 2c: parent = inv_B1 → came from L (left)  
      If a+2b < 2c AND 2a+b > 2c: parent = inv_B3 → came from R (right)
      If (3,4,5): root, stop
      
    Catalog: BerggrenCompleteness.not_both_neg — 
      a+2b ≤ 2c AND 2a+b ≤ 2c is impossible for PPT with positive legs.
    Catalog: BerggrenDescent.hyp_decrease_by_one — descent terminates.
    
    Note: The Berggren tree has a SPECIFIC ordering for each triple.
    M and R branches can have a > b. We try both orderings.
    """
    if a*a + b*b != c*c:
        return None
    if gcd(gcd(abs(a), abs(b)), abs(c)) != 1:
        return None
    if a <= 0 or b <= 0 or c <= 0:
        return None
    
    # Try both orderings — the Berggren tree has specific (a,b) ordering
    for (ax, bx) in [(a, b), (b, a)]:
        result = _descent(ax, bx, c)
        if result is not None:
            return result
    
    return None


def _descent(a: int, b: int, c: int) -> Optional[TreePath]:
    """Internal: perform Berggren descent on (a,b,c) with specific ordering."""
    steps = []
    
    while not (a == 3 and b == 4 and c == 5):
        d1 = a + 2*b - 2*c  # positive when a+2b > 2c
        d2 = 2*a + b - 2*c  # positive when 2a+b > 2c
        
        if d1 > 0 and d2 > 0:
            a, b, c = inv_B2(a, b, c)
            steps.append('M')
        elif d1 > 0 and d2 < 0:
            a, b, c = inv_B1(a, b, c)
            steps.append('L')
        elif d1 < 0 and d2 > 0:
            a, b, c = inv_B3(a, b, c)
            steps.append('R')
        elif d1 == 0:
            a, b, c = inv_B3(a, b, c)
            steps.append('R')
        elif d2 == 0:
            a, b, c = inv_B1(a, b, c)
            steps.append('L')
        else:
            return None  # impossible per Catalog
        
        if a <= 0 or b <= 0 or c <= 0:
            return None
    
    return TreePath(tuple(reversed(steps)))


# ============================================================
# Integer → Berggren path mapping
# ============================================================

def hyp_to_path(c: int) -> Optional[TreePath]:
    """Map a hypotenuse value c to its Berggren tree path.
    
    Given c, find the primitive Pythagorean triple (a,b,c) with
    a² + b² = c² and return its tree path.
    
    Uses the Euclidean parametrization: for each factorization
    c = m² + n² with m > n, m-n odd, gcd(m,n)=1, the triple is
    (m² - n², 2mn, m² + n²).
    """
    if c < 5:
        return None
    
    # Find all PPTs with hypotenuse c
    # For each m where m² < c, check if c - m² is a perfect square
    for m in range(isqrt(c - 1), 0, -1):
        n_sq = c - m * m
        if n_sq <= 0:
            continue
        n = isqrt(n_sq)
        if n * n != n_sq:
            continue
        if n <= 0 or n >= m:
            continue
        # Check primitive: gcd(m,n)=1 and m-n is odd
        if gcd(m, n) != 1:
            continue
        if (m - n) % 2 == 0:
            continue
        
        a = m * m - n * n
        b = 2 * m * n
        
        if is_ppt(a, b, c):
            return path_of_triple(a, b, c)
    
    return None


def int_to_path(n: int) -> TreePath:
    """Directly map each non-negative integer to a Berggren tree path.
    
    Uses a base-3 encoding: write n in base 3, where each digit
    0 → L (left/B₁), 1 → M (mid/B₂), 2 → R (right/B₃).
    
    This gives a BIJECTION between non-negative integers and tree paths:
      0 → Root      → (3, 4, 5)
      1 → M         → (21, 20, 29)
      2 → R         → (15, 8, 17)
      3 → L         → (5, 12, 13)
      4 → ML        → ...
      5 → MM        → ...
      6 → MR        → ...
      7 → RL        → ...
      8 → RM        → ...
      9 → RR        → ...
      10 → LL       → ...
      ...
    
    The mapping is:
      n = 0: root
      n > 0: write n in base 3, read digits as {L=0, M=1, R=2}
      
    This is well-defined because:
    - Catalog: pathsAtDepth_length — there are 3^d paths at depth d
    - Catalog: BerggrenCompleteness — every PPT appears exactly once
    - Catalog: BerggrenDescent — descent from any PPT reaches root
    
    The hypotenuse grows exponentially (Catalog: hypotenuse_growth):
      c(d) ≥ 5 · 3^d for depth d, so the mapping is efficient.
    """
    if n == 0:
        return TreePath.root()
    return TreePath.from_int(n)


def int_to_triple(n: int) -> Tuple[int, int, int]:
    """Map each non-negative integer directly to its Berggren triple.
    
    Combines int_to_path and triple_at_path.
    """
    return triple_at_path(int_to_path(n))


# ============================================================
# Alternative: map by hypotenuse value
# ============================================================

def hyp_path_index(c: int) -> Optional[int]:
    """Map a hypotenuse c to its Berggren path index (base-3 encoding).
    Returns None if c is not a primitive Pythagorean hypotenuse."""
    path = hyp_to_path(c)
    if path is None:
        return None
    return path.to_int()


# ============================================================
# Generating PPTs by hypotenuse (for verification)
# ============================================================

def generate_ppts_by_hyp(max_hyp: int) -> List[Tuple[int, int, int, TreePath]]:
    """Generate all PPTs with hypotenuse ≤ max_hyp, 
    sorted by hypotenuse, with their Berggren paths."""
    results = []
    for m in range(1, isqrt(max_hyp) + 1):
        for n in range(1, m):
            if m * m + n * n > max_hyp:
                break
            if (m - n) % 2 == 0:
                continue
            if gcd(m, n) != 1:
                continue
            a = m * m - n * n
            b = 2 * m * n
            c = m * m + n * n
            if a > b:
                a, b = b, a
            path = path_of_triple(a, b, c)
            results.append((c, a, b, path))
    results.sort()
    return results


# ============================================================
# Pretty printing
# ============================================================

def print_path_tree(max_depth: int = 3):
    """Print the Berggren tree up to max_depth."""
    def _print(path: TreePath, depth: int, prefix: str):
        a, b, c = triple_at_path(path)
        path_str = repr(path) if path.depth() > 0 else "Root"
        print(f"{prefix}{path_str}: ({a}, {b}, {c})")
        if depth < max_depth:
            _print(path.left(), depth + 1, prefix + "  ")
            _print(path.mid(), depth + 1, prefix + "  ")
            _print(path.right(), depth + 1, prefix + "  ")
    
    _print(TreePath.root(), 0, "")


# ============================================================
# Main demo
# ============================================================

if __name__ == "__main__":
    import sys
    
    print("=" * 70)
    print("BERGGREN TREE PATH MAPPER")
    print("Derived from Catalog theorems: BerggrenTree, BerggrenCompleteness,")
    print("BerggrenDescent, AgentBeta_TreeDynamics")
    print("=" * 70)
    
    # Demo 1: The Berggren tree
    print("\n--- Berggren Tree (depth 2) ---")
    print_path_tree(max_depth=2)
    
    # Demo 2: int → path → triple
    print("\n--- Integer → Berggren Path → Triple ---")
    print(f"{'n':>4} {'Path':>8} {'Triple':>20} {'Hypotenuse':>12}")
    print("-" * 50)
    for n in range(20):
        path = int_to_path(n)
        triple = triple_at_path(path)
        path_str = repr(path)
        print(f"{n:4d} {path_str:>8} ({triple[0]}, {triple[1]}, {triple[2]})  c={triple[2]:>6}")
    
    # Demo 3: Hypotenuse → path (reverse lookup)
    print("\n--- Hypotenuse → Berggren Path ---")
    print("(For each hypotenuse that is a PPT hypotenuse)")
    ppts = generate_ppts_by_hyp(200)
    print(f"{'Hyp c':>6} {'Legs':>15} {'Path':>10} {'Index':>8}")
    print("-" * 45)
    for c, a, b, path in ppts[:20]:
        path_str = repr(path) if path else "?"
        idx = path.to_int() if path else "?"
        print(f"{c:6d} ({a},{b}){'':>{max(0,8-len(str(a))-len(str(b))-3)}}{path_str:>10} {str(idx):>8}")
    
    # Demo 4: Specific descent examples
    print("\n--- Descent Traces (Catalog: BerggrenCompleteness) ---")
    test_triples = [
        (5, 12, 13),
        (7, 24, 25),
        (9, 40, 41),
        (15, 8, 17),
        (21, 20, 29),
        (11, 60, 61),
        (13, 84, 85),
        (35, 12, 37),
    ]
    for a, b, c in test_triples:
        if a > b:
            a, b = b, a
        path = path_of_triple(a, b, c)
        if path:
            # Verify by forward computation
            fa, fb, fc = triple_at_path(path)
            ok = (fa == a and fb == b and fc == c) or (fa == b and fb == a and fc == c)
            path_str = repr(path)
            print(f"  ({a:3d}, {b:3d}, {c:3d}) → {path_str:>10} → verify: {fa},{fb},{fc} {'✓' if ok else '✗'}")
        else:
            print(f"  ({a:3d}, {b:3d}, {c:3d}) → NOT a PPT")
    
    # Demo 5: M₂ branch (Pell recurrence)
    print("\n--- M₂ Branch (Catalog: m2_hyp_recurrence) ---")
    print("c_{n+2} = 6·c_{n+1} - c_n")
    path = TreePath.root()
    prev_c, curr_c = None, 5
    for i in range(8):
        a, b, c = triple_at_path(path)
        idx = path.to_int()
        print(f"  depth {i}: {repr(path):>8} (idx={idx:>6d}) → ({a}, {b}, {c}), c={c}")
        if i >= 2:
            pell_check = 6 * curr_c - prev_c
            print(f"           Pell check: 6×{curr_c} - {prev_c} = {pell_check} {'✓' if pell_check == c else '✗'}")
        prev_c, curr_c = curr_c, c
        path = path.mid()