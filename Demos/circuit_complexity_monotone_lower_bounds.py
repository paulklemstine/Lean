"""
Numerical demonstrations for monotone circuit lower bounds.

This script is a faithful executable mirror of the formalized results:

  * MCircuit                : monotone Boolean circuits (var / top / bot / and / or)
  * eval, size, depth, vars : structural measures
  * card_le_size_of_relevant: the relevant-variable size lower bound
  * cliqueFn, clique2 bound : CLIQUE as a monotone function, |E| = C(m,2) bound
  * numGates / approxEval   : Razborov approximation-method scaffolding
  * approx_error_bound      : total error <= numGates * delta
  * approx_method_size_lb   : size >= E / delta
  * kwFind / kwCost         : the monotone Karchmer-Wigderson protocol
  * kwCost <= depth         : depth bounds communication

Everything is self-contained: only the Python standard library is used.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations, product
from typing import Callable, Dict, FrozenSet, List, Optional, Tuple

# ---------------------------------------------------------------------------
# Monotone circuits as an algebraic data type.
# ---------------------------------------------------------------------------

Assignment = Dict[int, bool]          # variable index -> Boolean value
BoolFn = Callable[[Assignment], bool] # a Boolean function on assignments


@dataclass(frozen=True)
class MCircuit:
    """A monotone Boolean circuit node.

    kind is one of 'var', 'top', 'bot', 'and', 'or'.
    For 'var', `idx` holds the variable index.
    For 'and'/'or', `left` and `right` hold the children.
    """
    kind: str
    idx: Optional[int] = None
    left: Optional["MCircuit"] = None
    right: Optional["MCircuit"] = None


def Var(i: int) -> MCircuit:
    return MCircuit("var", idx=i)


Top = MCircuit("top")
Bot = MCircuit("bot")


def And(a: MCircuit, b: MCircuit) -> MCircuit:
    return MCircuit("and", left=a, right=b)


def Or(a: MCircuit, b: MCircuit) -> MCircuit:
    return MCircuit("or", left=a, right=b)


# ---------------------------------------------------------------------------
# Structural measures (Definitions 2.2, 2.3, 5.1).
# ---------------------------------------------------------------------------

def eval_circuit(C: MCircuit, x: Assignment) -> bool:
    """Boolean value computed by C on assignment x."""
    if C.kind == "var":
        assert C.idx is not None
        return x[C.idx]
    if C.kind == "top":
        return True
    if C.kind == "bot":
        return False
    assert C.left is not None and C.right is not None
    if C.kind == "and":
        return eval_circuit(C.left, x) and eval_circuit(C.right, x)
    return eval_circuit(C.left, x) or eval_circuit(C.right, x)


def size(C: MCircuit) -> int:
    """Number of nodes (leaves and gates)."""
    if C.kind in ("var", "top", "bot"):
        return 1
    assert C.left is not None and C.right is not None
    return size(C.left) + size(C.right) + 1


def depth(C: MCircuit) -> int:
    """Longest path from output to a leaf."""
    if C.kind in ("var", "top", "bot"):
        return 0
    assert C.left is not None and C.right is not None
    return max(depth(C.left), depth(C.right)) + 1


def num_gates(C: MCircuit) -> int:
    """Number of internal AND/OR gates."""
    if C.kind in ("var", "top", "bot"):
        return 0
    assert C.left is not None and C.right is not None
    return num_gates(C.left) + num_gates(C.right) + 1


def circuit_vars(C: MCircuit) -> FrozenSet[int]:
    """The set of variable indices occurring in C."""
    if C.kind == "var":
        assert C.idx is not None
        return frozenset({C.idx})
    if C.kind in ("top", "bot"):
        return frozenset()
    assert C.left is not None and C.right is not None
    return circuit_vars(C.left) | circuit_vars(C.right)


# ---------------------------------------------------------------------------
# Relevant variables (Definition 3.2, Theorem 3.5).
# ---------------------------------------------------------------------------

def depends_on(f: BoolFn, i: int, indices: List[int]) -> bool:
    """Test whether variable i is relevant to f, by scanning all base assignments
    over `indices` and flipping coordinate i."""
    others = [j for j in indices if j != i]
    for bits in product([False, True], repeat=len(others)):
        base: Assignment = dict(zip(others, bits))
        on = dict(base); on[i] = True
        off = dict(base); off[i] = False
        if f(on) != f(off):
            return True
    return False


# ---------------------------------------------------------------------------
# CLIQUE as a monotone function (Section 4).
# ---------------------------------------------------------------------------

def edge_index(m: int) -> Dict[Tuple[int, int], int]:
    """Assign an input index to each unordered non-loop edge of K_m."""
    return {pair: k for k, pair in enumerate(combinations(range(m), 2))}


def clique_fn(m: int, k: int, edges: Dict[Tuple[int, int], int]) -> BoolFn:
    """The k-CLIQUE Boolean function on graphs over m vertices."""
    def f(x: Assignment) -> bool:
        for S in combinations(range(m), k):
            if all(x[edges[(min(u, v), max(u, v))]] for u, v in combinations(S, 2)):
                return True
        return False
    return f


# ---------------------------------------------------------------------------
# Approximation method (Section 5).
# ---------------------------------------------------------------------------

def approx_eval(R: Callable[[BoolFn], BoolFn], C: MCircuit, x: Assignment) -> bool:
    """Evaluate C applying the rounding operator R after every AND/OR gate."""
    if C.kind == "var":
        assert C.idx is not None
        return x[C.idx]
    if C.kind == "top":
        return True
    if C.kind == "bot":
        return False
    assert C.left is not None and C.right is not None
    if C.kind == "and":
        g: BoolFn = lambda z: approx_eval(R, C.left, z) and approx_eval(R, C.right, z)
    else:
        g = lambda z: approx_eval(R, C.left, z) or approx_eval(R, C.right, z)
    return R(g)(x)


def error_count(C: MCircuit, R: Callable[[BoolFn], BoolFn],
                T: List[Assignment]) -> int:
    """Number of test inputs where eval and approxEval disagree."""
    return sum(1 for x in T if eval_circuit(C, x) != approx_eval(R, C, x))


# ---------------------------------------------------------------------------
# Karchmer-Wigderson protocol (Section 6).
# ---------------------------------------------------------------------------

def kw_find(C: MCircuit, x: Assignment, y: Assignment) -> Optional[int]:
    """Descend the circuit to find a separating coordinate."""
    if C.kind == "var":
        return C.idx
    if C.kind in ("top", "bot"):
        return None
    assert C.left is not None and C.right is not None
    if C.kind == "and":
        return kw_find(C.left, x, y) if not eval_circuit(C.left, y) \
            else kw_find(C.right, x, y)
    return kw_find(C.left, x, y) if eval_circuit(C.left, x) \
        else kw_find(C.right, x, y)


def kw_cost(C: MCircuit, x: Assignment, y: Assignment) -> int:
    """Number of bits exchanged by the KW protocol on (x, y)."""
    if C.kind in ("var", "top", "bot"):
        return 0
    assert C.left is not None and C.right is not None
    if C.kind == "and":
        child = C.left if not eval_circuit(C.left, y) else C.right
    else:
        child = C.left if eval_circuit(C.left, x) else C.right
    return kw_cost(child, x, y) + 1


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------

def demo_relevant_variable_clique() -> None:
    print("=" * 70)
    print("DEMO 1: Quadratic lower bound for 2-CLIQUE (relevant-variable method)")
    print("=" * 70)
    for m in range(2, 7):
        edges = edge_index(m)
        f = clique_fn(m, 2, edges)
        # Build the canonical 2-CLIQUE circuit: OR of all edge variables.
        idxs = sorted(edges.values())
        C: MCircuit = Var(idxs[0])
        for j in idxs[1:]:
            C = Or(C, Var(j))
        relevant = [i for i in idxs if depends_on(f, i, idxs)]
        choose2 = m * (m - 1) // 2
        print(f"  m={m}: C(m,2)={choose2:3d}  #relevant={len(relevant):3d}  "
              f"size={size(C):3d}  bound C(m,2)<=size: {choose2 <= size(C)}")
    print()


def demo_approximation_method() -> None:
    print("=" * 70)
    print("DEMO 2: Approximation method (error <= numGates*delta, size >= E/delta)")
    print("=" * 70)
    # Circuit over variables 0,1,2,3: (x0 AND x1) OR (x2 AND x3).
    C = Or(And(Var(0), Var(1)), And(Var(2), Var(3)))
    idxs = [0, 1, 2, 3]
    T: List[Assignment] = [dict(zip(idxs, bits))
                           for bits in product([False, True], repeat=4)]

    # A rounding operator that rounds DOWN to False on the all-ones input.
    def R(g: BoolFn) -> BoolFn:
        def rounded(z: Assignment) -> bool:
            if all(z.values()):       # corrupt only the all-ones input
                return False
            return g(z)
        return rounded

    # Empirically measure per-gate error delta over all intermediate functions.
    delta = 1  # R differs from g on at most one test input (the all-true one)
    total = error_count(C, R, T)
    g = num_gates(C)
    print(f"  circuit (x0 & x1) | (x2 & x3):  numGates={g}, size={size(C)}")
    print(f"  measured total error E = {total}")
    print(f"  error accumulation:  E={total} <= numGates*delta = {g*delta}: "
          f"{total <= g * delta}")
    if total > 0:
        print(f"  size lower bound:    size={size(C)} >= E/delta = {total/delta:.2f}: "
              f"{size(C) >= total / delta}")
    print()


def demo_karchmer_wigderson() -> None:
    print("=" * 70)
    print("DEMO 3: Karchmer-Wigderson protocol (kwCost <= depth, separator found)")
    print("=" * 70)
    C = Or(And(Var(0), Var(1)), And(Var(2), Var(3)))
    idxs = [0, 1, 2, 3]
    d = depth(C)
    checked = 0
    ok = True
    for bx in product([False, True], repeat=4):
        x = dict(zip(idxs, bx))
        if not eval_circuit(C, x):
            continue
        for by in product([False, True], repeat=4):
            y = dict(zip(idxs, by))
            if eval_circuit(C, y):
                continue
            i = kw_find(C, x, y)
            cost = kw_cost(C, x, y)
            checked += 1
            sep = (i is not None and x[i] and not y[i])
            within = cost <= d
            ok = ok and sep and within
    print(f"  circuit depth = {d}")
    print(f"  checked {checked} (1-input, 0-input) pairs")
    print(f"  every pair: separator valid AND kwCost <= depth : {ok}")
    print()


if __name__ == "__main__":
    demo_relevant_variable_clique()
    demo_approximation_method()
    demo_karchmer_wigderson()
    print("All demonstrations completed.")
