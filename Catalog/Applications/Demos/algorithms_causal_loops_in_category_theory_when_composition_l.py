"""
Algorithms for computing associator defects, pentagon obstructions,
and causal loop properties in non-associative algebraic structures.

All functions are type-hinted and self-contained.
"""

from typing import Callable, List, Tuple, Optional
from functools import reduce


def assoc_defect(op: Callable[[int, int], int], a: int, b: int, c: int) -> int:
    """Compute the associator defect of a binary operation at (a, b, c).

    Returns op(op(a,b), c) - op(a, op(b,c)).
    Zero iff op is associative at this triple.
    """
    return op(op(a, b), c) - op(a, op(b, c))


def sub_defect(a: int, b: int, c: int) -> int:
    """Associator defect for subtraction. Always equals -2*c."""
    return assoc_defect(lambda x, y: x - y, a, b, c)


def twisted_comp(p: Tuple[int, int], q: Tuple[int, int]) -> Tuple[int, int]:
    """Twisted composition: add first components, subtract second."""
    return (p[0] + q[0], p[1] - q[1])


def twisted_defect(p: Tuple[int, int], q: Tuple[int, int],
                   r: Tuple[int, int]) -> Tuple[int, int]:
    """Associator defect for twisted composition."""
    lhs = twisted_comp(twisted_comp(p, q), r)
    rhs = twisted_comp(p, twisted_comp(q, r))
    return (lhs[0] - rhs[0], lhs[1] - rhs[1])


def pentagon_check(op: Callable[[int, int], int],
                   a: int, b: int, c: int, d: int) -> int:
    """Check the pentagon condition. Returns LHS - RHS.
    Zero iff the pentagon condition holds at (a,b,c,d)."""
    lhs = (assoc_defect(op, a, b, c) +
           assoc_defect(op, a, op(b, c), d) +
           assoc_defect(op, b, c, d))
    rhs = (assoc_defect(op, op(a, b), c, d) +
           assoc_defect(op, a, b, op(c, d)))
    return lhs - rhs


def iter_sub_left(lst: List[int]) -> int:
    """Left-associated iterated subtraction: (...((a1 - a2) - a3) ... - an)."""
    if not lst:
        return 0
    return reduce(lambda a, b: a - b, lst)


def iter_sub_right(lst: List[int]) -> int:
    """Right-associated iterated subtraction: a1 - (a2 - (a3 - ... - an))."""
    if not lst:
        return 0
    if len(lst) == 1:
        return lst[0]
    return lst[0] - iter_sub_right(lst[1:])


def catalan(n: int) -> int:
    """Compute the nth Catalan number."""
    if n <= 0:
        return 1
    c = 1
    for i in range(n):
        c = c * 2 * (2 * i + 1) // (i + 2)
    return c


def coherence_dimension(n: int) -> int:
    """Number of independent coherence conditions at level n.
    Equals the nth Catalan number (number of binary trees with n+1 leaves)."""
    return catalan(n)


def is_loop(path: List[int]) -> bool:
    """Check if a list of integers forms an additive loop (sums to 0)."""
    return sum(path) == 0


def rotate(lst: List[int], n: int) -> List[int]:
    """Rotate a list by n positions."""
    if not lst:
        return lst
    n = n % len(lst)
    return lst[n:] + lst[:n]


def defect_scan(op: Callable[[int, int], int],
                values: List[int]) -> List[int]:
    """Compute the associator defect at each position in a list of values.

    For a list [a1, ..., an], returns [defect(a1,a2,a3), defect(a2,a3,a4), ...].
    """
    if len(values) < 3:
        return []
    return [assoc_defect(op, values[i], values[i+1], values[i+2])
            for i in range(len(values) - 2)]


def pentagon_scan(op: Callable[[int, int], int],
                  values: List[int]) -> List[int]:
    """Compute the pentagon defect at each 4-element window."""
    if len(values) < 4:
        return []
    return [pentagon_check(op, values[i], values[i+1], values[i+2], values[i+3])
            for i in range(len(values) - 3)]


def find_causal_operations(modulus: int) -> List[Tuple[int, ...]]:
    """Find all binary operations on Z/modulus that have causal defects.

    A causal defect depends only on c (the third argument).
    Returns list of operation tables (as tuples) that are causal.
    """
    results = []
    # For small modulus, enumerate all linear operations op(a,b) = α*a + β*b mod n
    for alpha in range(modulus):
        for beta in range(modulus):
            op = lambda a, b, al=alpha, be=beta: (al * a + be * b) % modulus
            is_causal = True
            # Check if defect depends only on c
            for c in range(modulus):
                defect_val = None
                for a in range(modulus):
                    for b in range(modulus):
                        d = assoc_defect(op, a, b, c) % modulus
                        if defect_val is None:
                            defect_val = d
                        elif d != defect_val:
                            is_causal = False
                            break
                    if not is_causal:
                        break
                if not is_causal:
                    break
            if is_causal:
                results.append((alpha, beta))
    return results


if __name__ == "__main__":
    # Demonstrate key algorithms
    sub = lambda a, b: a - b

    print("=== Associator Defect for Subtraction ===")
    for c in range(-3, 4):
        d = sub_defect(0, 0, c)
        print(f"  defect(0, 0, {c}) = {d} (expected {-2*c})")

    print("\n=== Twisted Composition Defect ===")
    for r2 in range(-2, 3):
        d = twisted_defect((1, 2), (3, 4), (5, r2))
        print(f"  twisted_defect((1,2), (3,4), (5,{r2})) = {d}")

    print("\n=== Pentagon Check for Subtraction ===")
    for d in range(-3, 4):
        p = pentagon_check(sub, 1, 2, 3, d)
        print(f"  pentagon(1, 2, 3, {d}) = {p} (expected {-4*d})")

    print("\n=== Defect Accumulation ===")
    lst = [10, 3, 5, 2]
    print(f"  Left-associated: {iter_sub_left(lst)}")
    print(f"  Right-associated: {iter_sub_right(lst)}")
    print(f"  Defect: {iter_sub_left(lst) - iter_sub_right(lst)}")

    print("\n=== Catalan Numbers (Coherence Dimensions) ===")
    for n in range(10):
        print(f"  C({n}) = {catalan(n)}")

    print("\n=== Causal Operations mod 5 ===")
    causal = find_causal_operations(5)
    print(f"  Found {len(causal)} causal linear ops: {causal}")
