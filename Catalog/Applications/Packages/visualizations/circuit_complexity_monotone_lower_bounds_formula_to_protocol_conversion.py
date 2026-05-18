#!/usr/bin/env python3
"""
Algorithms for Karchmer-Wigderson Correspondence

Implements:
1. Formula-to-protocol conversion
2. Protocol-to-formula conversion
3. KW cost computation via exhaustive search
4. Rectangle lower bound analysis
"""

from itertools import product
from typing import Optional, List, Tuple, Callable
import math

# ═══════════════════════════════════════════════════════════════════════
# Data Structures
# ═══════════════════════════════════════════════════════════════════════

class MonoFormula:
    """Base class for monotone Boolean formulas."""
    def eval(self, x: tuple) -> bool:
        raise NotImplementedError
    def depth(self) -> int:
        raise NotImplementedError
    def size(self) -> int:
        raise NotImplementedError

class Var(MonoFormula):
    def __init__(self, i: int):
        self.i = i
    def eval(self, x): return x[self.i] == 1
    def depth(self): return 0
    def size(self): return 1
    def __repr__(self): return f"x{self.i}"

class And(MonoFormula):
    def __init__(self, l: MonoFormula, r: MonoFormula):
        self.l, self.r = l, r
    def eval(self, x): return self.l.eval(x) and self.r.eval(x)
    def depth(self): return 1 + max(self.l.depth(), self.r.depth())
    def size(self): return 1 + self.l.size() + self.r.size()
    def __repr__(self): return f"({self.l} ∧ {self.r})"

class Or(MonoFormula):
    def __init__(self, l: MonoFormula, r: MonoFormula):
        self.l, self.r = l, r
    def eval(self, x): return self.l.eval(x) or self.r.eval(x)
    def depth(self): return 1 + max(self.l.depth(), self.r.depth())
    def size(self): return 1 + self.l.size() + self.r.size()
    def __repr__(self): return f"({self.l} ∨ {self.r})"

class KWTree:
    """A KW protocol tree."""
    pass

class Leaf(KWTree):
    def __init__(self, index: int):
        self.index = index
    def cost(self): return 0
    def __repr__(self): return f"Leaf({self.index})"

class AliceNode(KWTree):
    """Alice queries some function of x and sends a bit."""
    def __init__(self, query_fn, left: KWTree, right: KWTree):
        self.query_fn = query_fn  # Bool function of x
        self.left = left   # q(x) = False
        self.right = right  # q(x) = True
    def cost(self): return 1 + max(self.left.cost(), self.right.cost())

class BobNode(KWTree):
    """Bob queries some function of y and sends a bit."""
    def __init__(self, query_fn, left: KWTree, right: KWTree):
        self.query_fn = query_fn  # Bool function of y
        self.left = left   # q(y) = False
        self.right = right  # q(y) = True
    def cost(self): return 1 + max(self.left.cost(), self.right.cost())

# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Formula → Protocol
# ═══════════════════════════════════════════════════════════════════════

def formula_to_protocol(phi: MonoFormula) -> KWTree:
    """Convert a monotone formula to a KW protocol tree.

    Complexity: O(|φ|) — linear in formula size.

    The conversion is structural:
    - var(i) → Leaf(i)
    - or(φ₁, φ₂) → Alice node querying φ₁(x)
    - and(φ₁, φ₂) → Bob node querying φ₁(y)

    Theorem: The resulting protocol has cost ≤ φ.depth.

    Args:
        phi: A monotone Boolean formula.

    Returns:
        A KW protocol tree with cost ≤ phi.depth().
    """
    if isinstance(phi, Var):
        return Leaf(phi.i)
    elif isinstance(phi, Or):
        t1 = formula_to_protocol(phi.l)
        t2 = formula_to_protocol(phi.r)
        return AliceNode(lambda x, f=phi.l: f.eval(x), t2, t1)
    elif isinstance(phi, And):
        t1 = formula_to_protocol(phi.l)
        t2 = formula_to_protocol(phi.r)
        return BobNode(lambda y, f=phi.l: f.eval(y), t1, t2)
    else:
        raise ValueError(f"Unknown formula type: {type(phi)}")

# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Protocol → Formula
# ═══════════════════════════════════════════════════════════════════════

def protocol_to_formula(tree: KWTree) -> MonoFormula:
    """Convert a KW protocol tree to a monotone formula.

    Complexity: O(|T|) — linear in tree size.

    The conversion:
    - Leaf(i) → var(i)
    - Alice node → OR of children
    - Bob node → AND of children

    Theorem: The resulting formula has depth ≤ tree.cost.

    Args:
        tree: A KW protocol tree.

    Returns:
        A monotone formula with depth ≤ tree.cost().
    """
    if isinstance(tree, Leaf):
        return Var(tree.index)
    elif isinstance(tree, AliceNode):
        phi_l = protocol_to_formula(tree.left)
        phi_r = protocol_to_formula(tree.right)
        return Or(phi_l, phi_r)
    elif isinstance(tree, BobNode):
        phi_l = protocol_to_formula(tree.left)
        phi_r = protocol_to_formula(tree.right)
        return And(phi_l, phi_r)

# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Protocol Execution
# ═══════════════════════════════════════════════════════════════════════

def execute_protocol(tree: KWTree, x: tuple, y: tuple) -> int:
    """Execute a KW protocol and return the witness index.

    Complexity: O(cost(T) · n) per execution.

    Args:
        tree: The protocol tree.
        x: Alice's input (f(x) should be True).
        y: Bob's input (f(y) should be False).

    Returns:
        An index i such that x[i]=1 and y[i]=0 (if protocol is correct).
    """
    if isinstance(tree, Leaf):
        return tree.index
    elif isinstance(tree, AliceNode):
        if tree.query_fn(x):
            return execute_protocol(tree.right, x, y)
        else:
            return execute_protocol(tree.left, x, y)
    elif isinstance(tree, BobNode):
        if tree.query_fn(y):
            return execute_protocol(tree.right, x, y)
        else:
            return execute_protocol(tree.left, x, y)

# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: KW Cost Lower Bound via Rectangle Counting
# ═══════════════════════════════════════════════════════════════════════

def kw_rectangle_lower_bound(f: Callable, n: int) -> int:
    """Compute a lower bound on KW cost via rectangle counting.

    For each possible leaf index i, count how many valid (x,y) pairs
    it can correctly cover. A protocol of cost c can have at most 2^c leaves.

    Complexity: O(2^n · n) — exponential in n.

    Args:
        f: A Boolean function on n-bit inputs.
        n: Number of input bits.

    Returns:
        A lower bound on the KW cost.
    """
    inputs = list(product([0, 1], repeat=n))
    true_inputs = [x for x in inputs if f(x)]
    false_inputs = [y for y in inputs if not f(y)]

    if not true_inputs or not false_inputs:
        return 0  # Constant function

    # For each index i, count how many true inputs have x[i]=1
    # and how many false inputs have y[i]=0
    max_rectangle_size = 0
    for i in range(n):
        alice_ok = sum(1 for x in true_inputs if x[i] == 1)
        bob_ok = sum(1 for y in false_inputs if y[i] == 0)
        rect_size = alice_ok * bob_ok
        max_rectangle_size = max(max_rectangle_size, rect_size)

    total_pairs = len(true_inputs) * len(false_inputs)

    if max_rectangle_size == 0:
        return n  # No single leaf covers any pair

    # Minimum leaves needed ≥ total_pairs / max_rectangle_size
    min_leaves = math.ceil(total_pairs / max_rectangle_size)
    return math.ceil(math.log2(min_leaves)) if min_leaves > 1 else 0

# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Verify Protocol Correctness
# ═══════════════════════════════════════════════════════════════════════

def verify_protocol(tree: KWTree, f: Callable, n: int) -> bool:
    """Verify that a KW protocol is correct for function f.

    Checks all (x,y) pairs with f(x)=True, f(y)=False.

    Complexity: O(4^n · cost(T) · n) — exponential.

    Args:
        tree: The protocol tree.
        f: The Boolean function.
        n: Number of input bits.

    Returns:
        True if the protocol is correct for all valid (x,y) pairs.
    """
    inputs = list(product([0, 1], repeat=n))
    for x in inputs:
        if not f(x):
            continue
        for y in inputs:
            if f(y):
                continue
            i = execute_protocol(tree, x, y)
            if x[i] != 1 or y[i] != 0:
                return False
    return True

# ═══════════════════════════════════════════════════════════════════════
# Demo
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Karchmer-Wigderson Algorithms Demo")
    print("=" * 50)

    # OR function on 3 variables
    def or3(x): return any(b == 1 for b in x)

    # Build formula: x₀ ∨ (x₁ ∨ x₂)
    phi = Or(Var(0), Or(Var(1), Var(2)))
    print(f"\nFormula: {phi}")
    print(f"Depth: {phi.depth()}, Size: {phi.size()}")

    # Convert to protocol
    proto = formula_to_protocol(phi)
    print(f"Protocol cost: {proto.cost()}")

    # Verify correctness
    correct = verify_protocol(proto, or3, 3)
    print(f"Protocol correct: {correct}")

    # Execute on specific inputs
    x, y = (0, 1, 0), (0, 0, 0)
    idx = execute_protocol(proto, x, y)
    print(f"\nExecution: x={x}, y={y} → index={idx}")
    print(f"  x[{idx}]={x[idx]}, y[{idx}]={y[idx]}")

    # Convert back to formula
    phi2 = protocol_to_formula(proto)
    print(f"\nRound-trip formula: {phi2}")
    print(f"Round-trip depth: {phi2.depth()}")

    # Rectangle lower bounds
    print("\nRectangle Lower Bounds:")
    for n in range(2, 7):
        def or_n(x, n=n): return any(b == 1 for b in x)
        lb = kw_rectangle_lower_bound(or_n, n)
        print(f"  OR_{n}: lower bound = {lb}, ⌈log₂({n})⌉ = {math.ceil(math.log2(n))}")
