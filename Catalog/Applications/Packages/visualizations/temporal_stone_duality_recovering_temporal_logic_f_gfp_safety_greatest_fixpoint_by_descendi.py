#!/usr/bin/env python3
"""
Temporal Stone Duality: Core Algorithms

Implements the certified algorithms from the research paper:
1. GFP-SAFETY: Greatest fixpoint by descending Kleene iteration
2. LFP-REACH: Least fixpoint by ascending Kleene iteration
3. BEHAVIORAL-QUOTIENT: Behavioral quotient via dual points
4. TEMPORAL-EVAL: Full temporal formula evaluation
"""

from typing import Set, Dict, FrozenSet, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum, auto


# ============================================================
# Core Data Structures
# ============================================================

class FormulaKind(Enum):
    ATOM = auto()
    TOP = auto()
    BOT = auto()
    NEG = auto()
    CONJ = auto()
    DISJ = auto()
    BOX = auto()
    DIAMOND = auto()
    ALWAYS = auto()
    EVENTUALLY = auto()


@dataclass
class TempFormula:
    """Temporal formula AST node."""
    kind: FormulaKind
    atom_index: Optional[int] = None
    left: Optional['TempFormula'] = None
    right: Optional['TempFormula'] = None

    @staticmethod
    def atom(i: int) -> 'TempFormula':
        return TempFormula(FormulaKind.ATOM, atom_index=i)

    @staticmethod
    def top() -> 'TempFormula':
        return TempFormula(FormulaKind.TOP)

    @staticmethod
    def bot() -> 'TempFormula':
        return TempFormula(FormulaKind.BOT)

    @staticmethod
    def neg(phi: 'TempFormula') -> 'TempFormula':
        return TempFormula(FormulaKind.NEG, left=phi)

    @staticmethod
    def conj(phi: 'TempFormula', psi: 'TempFormula') -> 'TempFormula':
        return TempFormula(FormulaKind.CONJ, left=phi, right=psi)

    @staticmethod
    def disj(phi: 'TempFormula', psi: 'TempFormula') -> 'TempFormula':
        return TempFormula(FormulaKind.DISJ, left=phi, right=psi)

    @staticmethod
    def box(phi: 'TempFormula') -> 'TempFormula':
        return TempFormula(FormulaKind.BOX, left=phi)

    @staticmethod
    def diamond(phi: 'TempFormula') -> 'TempFormula':
        return TempFormula(FormulaKind.DIAMOND, left=phi)

    @staticmethod
    def always(i: int) -> 'TempFormula':
        return TempFormula(FormulaKind.ALWAYS, atom_index=i)

    @staticmethod
    def eventually(i: int) -> 'TempFormula':
        return TempFormula(FormulaKind.EVENTUALLY, atom_index=i)


@dataclass
class TransitionSystem:
    """Finite transition system with labeled atomic propositions."""
    states: Set[int]
    transitions: Dict[int, Set[int]]  # state -> set of successor states
    valuation: Dict[int, Set[int]]    # atom index -> set of satisfying states

    def successors(self, s: int) -> Set[int]:
        return self.transitions.get(s, set())


# ============================================================
# Predecessor Operators
# ============================================================

def universal_pre(ts: TransitionSystem, X: Set[int]) -> Set[int]:
    """Universal predecessor: {s | ∀t. R(s,t) → t ∈ X}.

    Time complexity: O(|states| · max_degree)
    Space complexity: O(|states|)
    """
    return {s for s in ts.states if all(t in X for t in ts.successors(s))}


def existential_pre(ts: TransitionSystem, X: Set[int]) -> Set[int]:
    """Existential predecessor: {s | ∃t. R(s,t) ∧ t ∈ X}.

    Time complexity: O(|states| · max_degree)
    Space complexity: O(|states|)
    """
    return {s for s in ts.states if any(t in X for t in ts.successors(s))}


# ============================================================
# Algorithm 1: GFP-SAFETY
# ============================================================

def gfp_safety(ts: TransitionSystem, p: Set[int],
               trace: bool = False) -> Tuple[Set[int], List[Set[int]]]:
    """Compute greatest fixpoint of Φ(X) = p ∩ pre(X) by descending
    Kleene iteration.

    This certifiably computes the semantics of □*p (always p).

    Args:
        ts: The transition system
        p: The safety property (set of "good" states)
        trace: If True, record all intermediate sets

    Returns:
        (fixpoint, chain) where chain is the descending Kleene chain

    Time complexity: O(|states|² · max_degree)
    Space complexity: O(|states|²) if trace=True, O(|states|) otherwise

    Convergence: Guaranteed in at most |states| iterations.
    """
    X = set(ts.states)
    chain = [set(X)] if trace else []

    for _ in range(len(ts.states) + 1):
        X_new = p & universal_pre(ts, X)
        if trace:
            chain.append(set(X_new))
        if X_new == X:
            return X, chain
        X = X_new

    return X, chain  # Should never reach here for finite systems


# ============================================================
# Algorithm 2: LFP-REACH
# ============================================================

def lfp_reach(ts: TransitionSystem, p: Set[int],
              trace: bool = False) -> Tuple[Set[int], List[Set[int]]]:
    """Compute least fixpoint of Ψ(X) = p ∪ ∃pre(X) by ascending
    Kleene iteration.

    This certifiably computes the semantics of ◇*p (eventually p).

    Args:
        ts: The transition system
        p: The reachability target
        trace: If True, record all intermediate sets

    Returns:
        (fixpoint, chain) where chain is the ascending Kleene chain

    Time complexity: O(|states|² · max_degree)
    Space complexity: O(|states|²) if trace=True, O(|states|) otherwise

    Convergence: Guaranteed in at most |states| iterations.
    """
    X: Set[int] = set()
    chain = [set(X)] if trace else []

    for _ in range(len(ts.states) + 1):
        X_new = p | existential_pre(ts, X)
        if trace:
            chain.append(set(X_new))
        if X_new == X:
            return X, chain
        X = X_new

    return X, chain


# ============================================================
# Algorithm 3: Temporal Formula Evaluation
# ============================================================

def eval_formula(ts: TransitionSystem, phi: TempFormula) -> Set[int]:
    """Evaluate a temporal formula to its set of satisfying states.

    Time complexity: O(|φ| · |states|² · max_degree) for non-fixpoint formulas
                     O(|states|³ · max_degree) for fixpoint formulas
    """
    match phi.kind:
        case FormulaKind.ATOM:
            return set(ts.valuation.get(phi.atom_index, set()))
        case FormulaKind.TOP:
            return set(ts.states)
        case FormulaKind.BOT:
            return set()
        case FormulaKind.NEG:
            return ts.states - eval_formula(ts, phi.left)
        case FormulaKind.CONJ:
            return eval_formula(ts, phi.left) & eval_formula(ts, phi.right)
        case FormulaKind.DISJ:
            return eval_formula(ts, phi.left) | eval_formula(ts, phi.right)
        case FormulaKind.BOX:
            return universal_pre(ts, eval_formula(ts, phi.left))
        case FormulaKind.DIAMOND:
            return existential_pre(ts, eval_formula(ts, phi.left))
        case FormulaKind.ALWAYS:
            p = ts.valuation.get(phi.atom_index, set())
            result, _ = gfp_safety(ts, p)
            return result
        case FormulaKind.EVENTUALLY:
            p = ts.valuation.get(phi.atom_index, set())
            result, _ = lfp_reach(ts, p)
            return result


# ============================================================
# Algorithm 4: Behavioral Quotient
# ============================================================

def compute_definable_predicates(ts: TransitionSystem,
                                  depth: int = 4) -> Set[FrozenSet[int]]:
    """Compute the set of definable predicates by closing atoms under
    boolean operations and the modal operators.

    Args:
        ts: The transition system
        depth: Number of closure iterations

    Returns:
        Set of definable predicates (as frozen sets)
    """
    preds: Set[FrozenSet[int]] = set()
    preds.add(frozenset(ts.states))
    preds.add(frozenset())

    for p in ts.valuation.values():
        preds.add(frozenset(p))

    for _ in range(depth):
        new_preds = set(preds)
        for X in list(preds):
            Xs = set(X)
            new_preds.add(frozenset(ts.states - Xs))
            new_preds.add(frozenset(universal_pre(ts, Xs)))
            new_preds.add(frozenset(existential_pre(ts, Xs)))
        for X in list(preds):
            for Y in list(preds):
                new_preds.add(X & Y)
                new_preds.add(X | Y)
        preds = new_preds

    return preds


def behavioral_quotient(ts: TransitionSystem,
                         depth: int = 4) -> List[Set[int]]:
    """Compute the behavioral quotient of a transition system.

    Two states are in the same equivalence class iff they satisfy
    exactly the same temporal formulas (Theorem A).

    Args:
        ts: The transition system
        depth: Closure depth for definable predicates

    Returns:
        List of equivalence classes (partitioning ts.states)

    Time complexity: O(2^|states| · |states| · depth · max_degree)
    """
    preds = compute_definable_predicates(ts, depth)

    # Compute dual points
    dual_points: Dict[int, FrozenSet[FrozenSet[int]]] = {}
    for s in ts.states:
        dual_points[s] = frozenset(X for X in preds if s in X)

    # Partition by equal dual points
    classes: Dict[FrozenSet[FrozenSet[int]], Set[int]] = {}
    for s, dp in dual_points.items():
        if dp not in classes:
            classes[dp] = set()
        classes[dp].add(s)

    return list(classes.values())


# ============================================================
# Algorithm 5: Model Checking
# ============================================================

def model_check(ts: TransitionSystem, phi: TempFormula) -> bool:
    """Check whether all states satisfy a temporal formula.

    Returns True iff ∀ s ∈ states, s ∈ ⟦φ⟧.

    This is decidable by Theorem C.
    """
    return eval_formula(ts, phi) == ts.states


def model_check_state(ts: TransitionSystem, phi: TempFormula, s: int) -> bool:
    """Check whether a specific state satisfies a temporal formula."""
    return s in eval_formula(ts, phi)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Temporal Stone Duality: Algorithm Demonstrations")
    print("=" * 55)

    # Example: Mutual exclusion protocol
    # States: (p1_state, p2_state) where each ∈ {idle, trying, critical}
    # Encoded as 3*p1 + p2, values: 0=idle, 1=trying, 2=critical
    states = set(range(9))
    transitions = {
        0: {1, 3},   # (I,I) → (T,I) or (I,T)
        1: {2, 4},   # (T,I) → (C,I) or (T,T)
        2: {0, 5},   # (C,I) → (I,I) or (C,T)
        3: {4, 6},   # (I,T) → (T,T) or (I,C)
        4: {5, 7},   # (T,T) → (C,T) or (T,C)
        5: {3, 8},   # (C,T) → (I,T) or (C,C) - BUG if 8 reachable
        6: {7, 0},   # (I,C) → (T,C) or (I,I)
        7: {8, 3},   # (T,C) → (C,C) or (I,T) - BUG if 8 reachable
        8: {0},       # (C,C) → (I,I) - mutual exclusion violated!
    }

    # Remove the buggy transitions to make the protocol safe
    transitions_safe = dict(transitions)
    transitions_safe[5] = {3}     # (C,T) → (I,T) only
    transitions_safe[7] = {3}     # (T,C) → (I,T) only

    safe_prop = states - {8}  # Not both critical

    ts_buggy = TransitionSystem(states, transitions, {0: safe_prop})
    ts_safe = TransitionSystem(states, transitions_safe, {0: safe_prop})

    # Check safety for buggy protocol
    gfp_buggy, chain_buggy = gfp_safety(ts_buggy, safe_prop, trace=True)
    print(f"\nBuggy protocol: □*(safe) = {sorted(gfp_buggy)}")
    print(f"  Convergence chain ({len(chain_buggy)-1} steps):")
    for i, step in enumerate(chain_buggy):
        print(f"    Step {i}: {sorted(step)}")

    # Check safety for fixed protocol
    gfp_safe, chain_safe = gfp_safety(ts_safe, safe_prop, trace=True)
    print(f"\nFixed protocol: □*(safe) = {sorted(gfp_safe)}")
    print(f"  All states safe: {gfp_safe == states}")

    # Behavioral quotient
    quotient = behavioral_quotient(ts_safe)
    print(f"\nBehavioral quotient ({len(quotient)} classes):")
    for cls in quotient:
        print(f"  {cls}")

    # Model checking
    phi_safe = TempFormula.always(0)
    print(f"\nModel check □*(safe) on buggy: {model_check(ts_buggy, phi_safe)}")
    print(f"Model check □*(safe) on fixed: {model_check(ts_safe, phi_safe)}")
