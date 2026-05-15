#!/usr/bin/env python3
"""
Algorithms for Predicate Transport Along Invariant-Preserving Morphisms

This module implements the core algorithms for invariant-determined predicate
detection, factorization, and transport across theory morphisms.
"""

from typing import Callable, TypeVar, Generic, Optional
from dataclasses import dataclass, field

T = TypeVar('T')
U = TypeVar('U')


# ============================================================================
# Algorithm 1: Invariant Determination Check
# ============================================================================

def check_invariant_determined(
    carrier_elements: list,
    inv: Callable,
    predicate: Callable[[object], bool]
) -> tuple[bool, Optional[tuple]]:
    """
    Check if a predicate is invariant-determined on a finite set of elements.

    Algorithm:
        For each element x, compute (Inv(x), P(x)).
        Group by invariant value. If any group has both True and False,
        the predicate is NOT invariant-determined.

    Time complexity: O(n) where n = |carrier_elements|
    Space complexity: O(k) where k = |{Inv(x) : x in carrier}|

    Returns:
        (True, None) if invariant-determined
        (False, (x, y)) if not, with a witness pair x,y having same invariant
                        but different predicate values
    """
    inv_to_witness: dict = {}

    for x in carrier_elements:
        v = inv(x)
        px = predicate(x)

        if v in inv_to_witness:
            stored_x, stored_px = inv_to_witness[v]
            if stored_px != px:
                return False, (stored_x, x)
        else:
            inv_to_witness[v] = (x, px)

    return True, None


# ============================================================================
# Algorithm 2: Predicate Factorization
# ============================================================================

def factor_predicate(
    carrier_elements: list,
    inv: Callable,
    predicate: Callable[[object], bool]
) -> Optional[dict]:
    """
    Factor a predicate through the invariant: find R such that P(x) ↔ R(Inv(x)).

    Algorithm:
        1. Check invariant-determination
        2. If yes, build R as a dictionary from invariant values to truth values

    Time complexity: O(n)
    Space complexity: O(k)

    Returns:
        Dictionary mapping invariant values to truth values, or None if
        the predicate is not invariant-determined.
    """
    is_inv_det, witness = check_invariant_determined(
        carrier_elements, inv, predicate
    )

    if not is_inv_det:
        return None

    R: dict = {}
    for x in carrier_elements:
        v = inv(x)
        if v not in R:
            R[v] = predicate(x)

    return R


# ============================================================================
# Algorithm 3: Transferable Predicate Verification
# ============================================================================

def verify_transferable(
    carrier_elements: list,
    morphism: Callable,
    source_pred: Callable[[object], bool],
    target_pred: Callable[[object], bool]
) -> tuple[bool, Optional[object]]:
    """
    Verify that a predicate is transferable along a morphism.

    Algorithm:
        For each x with P(x), check Q(f(x)).
        Return (True, None) if all pass, (False, x) with counterexample otherwise.

    Time complexity: O(n)
    """
    for x in carrier_elements:
        if source_pred(x) and not target_pred(morphism(x)):
            return False, x

    return True, None


# ============================================================================
# Algorithm 4: Composable Transfer Chain
# ============================================================================

@dataclass
class TransferChain:
    """
    A composable chain of theory morphisms with predicate preservation.

    This implements the functorial composition:
    - Identity: id preserves P to P
    - Composition: if f preserves P→Q and g preserves Q→R,
      then g∘f preserves P→R
    """
    stages: list[tuple[str, Callable, Callable, Callable]] = field(default_factory=list)
    # Each stage: (name, morphism, source_pred, target_pred)

    def add_stage(self, name: str, morphism: Callable,
                  source_pred: Callable, target_pred: Callable):
        """Add a morphism stage to the chain."""
        self.stages.append((name, morphism, source_pred, target_pred))

    def compose(self) -> Callable:
        """Compose all morphisms in the chain."""
        def composed(x):
            result = x
            for _, morphism, _, _ in self.stages:
                result = morphism(result)
            return result
        return composed

    def verify_chain(self, elements: list) -> list[tuple[str, bool]]:
        """Verify each stage and the full composition."""
        results = []

        for name, morphism, sp, tp in self.stages:
            ok, _ = verify_transferable(elements, morphism, sp, tp)
            results.append((name, ok))

        # Verify full composition
        if self.stages:
            composed = self.compose()
            first_pred = self.stages[0][2]
            last_pred = self.stages[-1][3]
            ok, _ = verify_transferable(elements, composed, first_pred, last_pred)
            results.append(("full_composition", ok))

        return results

    def transport_witness(self, x: object) -> list[tuple[str, object, bool]]:
        """Transport a witness through the chain, showing each stage."""
        trace = []
        current = x
        for name, morphism, _, target_pred in self.stages:
            current = morphism(current)
            trace.append((name, current, target_pred(current)))
        return trace


# ============================================================================
# Algorithm 5: Boolean Closure Computation
# ============================================================================

def boolean_closure(
    predicates: dict[str, Callable[[object], bool]]
) -> dict[str, Callable[[object], bool]]:
    """
    Compute the Boolean closure of a set of predicates.

    Given named predicates P1, P2, ..., compute all Boolean combinations
    up to 2-ary operations: P∧Q, P∨Q, ¬P, P→Q, P↔Q.

    Returns a dictionary of named combined predicates.
    """
    result = dict(predicates)
    names = list(predicates.keys())

    # Negations
    for n in names:
        p = predicates[n]
        result[f"¬{n}"] = lambda x, p=p: not p(x)

    # Binary operations
    for i, n1 in enumerate(names):
        for n2 in names[i:]:
            p1, p2 = predicates[n1], predicates[n2]
            result[f"{n1}∧{n2}"] = lambda x, a=p1, b=p2: a(x) and b(x)
            result[f"{n1}∨{n2}"] = lambda x, a=p1, b=p2: a(x) or b(x)
            if n1 != n2:
                result[f"{n1}→{n2}"] = lambda x, a=p1, b=p2: (not a(x)) or b(x)
                result[f"{n2}→{n1}"] = lambda x, a=p1, b=p2: (not b(x)) or a(x)
                result[f"{n1}↔{n2}"] = lambda x, a=p1, b=p2: a(x) == b(x)

    return result


# ============================================================================
# Algorithm 6: Invariant-Space Predicate Pushforward
# ============================================================================

def pushforward_predicate(
    R: dict,  # invariant-level predicate as dict
    target_inv: Callable,
) -> Callable[[object], bool]:
    """
    Push an invariant-level predicate to the target carrier.

    Given R : InvariantType → Bool and target.Inv : Carrier → InvariantType,
    compute Q(y) = R(target.Inv(y)).

    This is the key operation for predicate transport: once we factor
    P through the source invariant to get R, we push R to the target
    carrier via the target invariant.
    """
    def Q(y):
        v = target_inv(y)
        return R.get(v, False)
    return Q


# ============================================================================
# Demo
# ============================================================================

def main():
    print("=" * 70)
    print("PREDICATE TRANSPORT ALGORITHMS — DEMONSTRATIONS")
    print("=" * 70)

    elements = list(range(20))

    # Height theory: Inv = id
    height_inv = lambda x: x
    # Cell theory: Inv = x*(x+1)
    cell_inv = lambda x: x * (x + 1)

    # --- Algorithm 1: Invariant determination ---
    print("\n--- Algorithm 1: Invariant Determination Check ---")
    lower5 = lambda x: 5 <= height_inv(x)
    ok, witness = check_invariant_determined(elements, height_inv, lower5)
    print(f"  'n ≤ Inv(x)' [n=5] on Height: invariant-determined = {ok}")

    # --- Algorithm 2: Factorization ---
    print("\n--- Algorithm 2: Predicate Factorization ---")
    interval = lambda x: 3 <= height_inv(x) and height_inv(x) <= 8
    R = factor_predicate(elements, height_inv, interval)
    if R is not None:
        true_vals = sorted(k for k, v in R.items() if v)
        false_vals = sorted(k for k, v in R.items() if not v)
        print(f"  Interval [3,8] factored: R(n)=True for n∈{true_vals}")

    # --- Algorithm 3: Transferable verification ---
    print("\n--- Algorithm 3: Transferable Predicate Verification ---")
    P = lambda x: 5 <= height_inv(x)
    Q = lambda x: 5 <= cell_inv(x)
    ok, cx = verify_transferable(elements, lambda x: x, P, Q)
    print(f"  LowerBound(5) Height→Cell: transferable = {ok}")

    # --- Algorithm 4: Transfer chain ---
    print("\n--- Algorithm 4: Composable Transfer Chain ---")
    chain = TransferChain()
    n = 3
    chain.add_stage(
        "height→dim",
        lambda x: x,
        lambda x: n <= height_inv(x),
        lambda x: n <= (x + 1)  # dimension inv
    )
    chain.add_stage(
        "dim→stab",
        lambda x: x + 1,
        lambda x: n <= (x + 1),
        lambda x: n <= x  # stability inv = id
    )

    results = chain.verify_chain(elements)
    for name, ok in results:
        print(f"  {name}: verified = {ok}")

    # Transport a specific witness
    print("\n  Witness transport for x=7:")
    trace = chain.transport_witness(7)
    for name, value, satisfied in trace:
        print(f"    After {name}: value={value}, predicate={satisfied}")

    # --- Algorithm 5: Boolean closure ---
    print("\n--- Algorithm 5: Boolean Closure ---")
    base_preds = {
        "lower3": lambda x: 3 <= height_inv(x),
        "upper10": lambda x: height_inv(x) <= 10,
    }
    closure = boolean_closure(base_preds)
    print(f"  Base predicates: {list(base_preds.keys())}")
    print(f"  Boolean closure size: {len(closure)} predicates")

    for name, pred in sorted(closure.items()):
        ok, _ = check_invariant_determined(elements, height_inv, pred)
        vals = [x for x in elements if pred(x)]
        print(f"    {name}: inv-det={ok}, true on {vals}")

    # --- Algorithm 6: Pushforward ---
    print("\n--- Algorithm 6: Invariant-Space Pushforward ---")
    R = factor_predicate(elements, height_inv, lower5)
    if R:
        Q_pushed = pushforward_predicate(R, cell_inv)
        for x in range(5):
            print(f"    x={x}: Cell.Inv={cell_inv(x)}, "
                  f"R(Cell.Inv(x))={Q_pushed(x)}")

    print("\nDone.")


if __name__ == "__main__":
    main()
