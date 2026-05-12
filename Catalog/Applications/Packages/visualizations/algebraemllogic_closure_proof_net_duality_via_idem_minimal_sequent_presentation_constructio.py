#!/usr/bin/env python3
"""
Algorithms for Closure–Proof-Net Duality

Implements the key algorithms from the research:
1. Minimal sequent presentation construction (Nerode quotient)
2. Irredundant sequent extraction
3. Idempotent join semilattice computation
4. Factorization through minimal presentation
"""

from itertools import combinations, chain
from typing import FrozenSet, Set, Dict, List, Tuple, Optional
from dataclasses import dataclass


def powerset(s):
    s = list(s)
    return [frozenset(c) for c in chain.from_iterable(
        combinations(s, r) for r in range(len(s) + 1))]


@dataclass
class ClosureSystem:
    """A finite closure system on a set H."""
    H: set
    cl: object  # Callable[[frozenset], frozenset]

    def verify_axioms(self) -> bool:
        """Verify all closure and regularity axioms."""
        subs = powerset(self.H)
        for A in subs:
            if not A <= self.cl(A):
                return False
            if self.cl(self.cl(A)) != self.cl(A):
                return False
        for A in subs:
            for B in subs:
                if A <= B and not self.cl(A) <= self.cl(B):
                    return False
        return True

    def verify_exchange(self) -> bool:
        subs = powerset(self.H)
        for A in subs:
            for a in self.H:
                for b in self.H:
                    if a != b and a not in self.cl(A) and b not in self.cl(A):
                        if b in self.cl(A | {a}) and a not in self.cl(A | {b}):
                            return False
        return True

    def verify_absorption(self) -> bool:
        subs = powerset(self.H)
        for A in subs:
            for B in subs:
                if B <= self.cl(A) and self.cl(A | B) != self.cl(A):
                    return False
        return True


@dataclass
class MinimalPresentation:
    """A minimal sequent presentation of a closure system.

    Attributes:
        states: List of canonical states (closed sets)
        embed: Map from Finset H → state index
        step: Transition function (state_idx, hypothesis) → state_idx
        state_to_closed: Map from state index to closed set
    """
    states: List[frozenset]
    embed: Dict[frozenset, int]
    step: Dict[Tuple[int, str], int]
    state_to_closed: Dict[int, frozenset]


def construct_minimal_presentation(cs: ClosureSystem) -> MinimalPresentation:
    """
    Algorithm 1: Construct the minimal sequent presentation.

    Time complexity: O(2^|H| · |H|) for computing all closures.
    Space complexity: O(|closed sets| · |H|) for the presentation.

    This is the constructive content of exists_minimal_sequent_presentation.
    """
    # Step 1: Compute all closures (canonical states)
    all_contexts = powerset(cs.H)
    closure_map = {}  # context → closure
    for A in all_contexts:
        closure_map[A] = cs.cl(A)

    # Step 2: Identify distinct closed sets
    closed_sets = sorted(set(closure_map.values()),
                         key=lambda s: (len(s), sorted(s)))
    state_index = {s: i for i, s in enumerate(closed_sets)}

    # Step 3: Build embedding
    embed = {}
    for A in all_contexts:
        embed[A] = state_index[cs.cl(A)]

    # Step 4: Build step function
    step = {}
    for s in closed_sets:
        idx = state_index[s]
        for h in cs.H:
            new_closure = cs.cl(s | {h})
            step[(idx, h)] = state_index[new_closure]

    state_to_closed = {i: s for s, i in state_index.items()}

    return MinimalPresentation(
        states=closed_sets,
        embed=embed,
        step=step,
        state_to_closed=state_to_closed
    )


def verify_presentation_properties(cs: ClosureSystem,
                                    pres: MinimalPresentation) -> Dict[str, bool]:
    """Verify all properties of a minimal presentation."""
    results = {}

    # Surjectivity: every state is the image of some context
    all_embedded = set(pres.embed.values())
    results["surjective"] = all_embedded == set(range(len(pres.states)))

    # Faithfulness: embed(A) = embed(B) iff cl(A) = cl(B)
    faithful = True
    all_contexts = powerset(cs.H)
    for A in all_contexts:
        for B in all_contexts:
            if (pres.embed[A] == pres.embed[B]) != (cs.cl(A) == cs.cl(B)):
                faithful = False
                break
    results["faithful"] = faithful

    # Step compatibility: embed(cl(insert h A)) = step(embed(A), h)
    compat = True
    for A in all_contexts:
        for h in cs.H:
            lhs = pres.embed[cs.cl(A | {h})]
            rhs = pres.step[(pres.embed[A], h)]
            if lhs != rhs:
                compat = False
    results["step_compatible"] = compat

    # Separation: no two states have the same closed set
    results["separated"] = len(set(pres.state_to_closed.values())) == len(pres.states)

    return results


@dataclass
class IrredundantSequent:
    """An irredundant sequent Γ ⊢ h."""
    premises: frozenset
    conclusion: str


def extract_irredundant_sequents(cs: ClosureSystem) -> List[IrredundantSequent]:
    """
    Algorithm 2: Extract all irredundant sequents.

    An irredundant sequent Γ ⊢ h means h ∈ cl(Γ), h ∉ Γ,
    and for all proper subsets Γ' ⊂ Γ, h ∉ cl(Γ').

    Time complexity: O(2^|H| · |H| · 2^|H|) worst case.
    """
    sequents = []
    all_subsets = powerset(cs.H)

    for gamma in all_subsets:
        for h in cs.H:
            if h in cs.cl(gamma) and h not in gamma:
                irredundant = True
                for gamma_prime in all_subsets:
                    if gamma_prime < gamma and h in cs.cl(gamma_prime):
                        irredundant = False
                        break
                if irredundant:
                    sequents.append(IrredundantSequent(gamma, h))

    return sequents


def compute_join_semilattice(cs: ClosureSystem) -> Dict:
    """
    Algorithm 3: Compute the idempotent join semilattice of closed sets.

    Returns the join table and verifies semilattice properties.
    """
    pres = construct_minimal_presentation(cs)
    n = len(pres.states)

    # Join table
    join_table = {}
    for i in range(n):
        for j in range(n):
            si = pres.states[i]
            sj = pres.states[j]
            joined = cs.cl(si | sj)
            join_table[(i, j)] = pres.states.index(joined)

    # Verify properties
    is_idempotent = all(join_table[(i, i)] == i for i in range(n))
    is_commutative = all(
        join_table[(i, j)] == join_table[(j, i)]
        for i in range(n) for j in range(n))
    is_associative = all(
        join_table[(join_table[(i, j)], k)] == join_table[(i, join_table[(j, k)])]
        for i in range(n) for j in range(n) for k in range(n))

    return {
        "join_table": join_table,
        "n_states": n,
        "idempotent": is_idempotent,
        "commutative": is_commutative,
        "associative": is_associative,
    }


def factor_through_minimal(cs: ClosureSystem,
                           pres: MinimalPresentation,
                           other_embed: Dict[frozenset, object]) -> Dict:
    """
    Algorithm 4: Factor another presentation through the minimal one.

    Given a sound embedding other_embed : Finset H → Q',
    construct φ : states → Q' such that φ(embed(A)) = other_embed(A).

    This is the constructive content of the universal property.
    """
    phi = {}
    for idx, closed_set in pres.state_to_closed.items():
        # Find any context A with cl(A) = closed_set
        phi[idx] = other_embed[closed_set]

    return phi


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Build F2 matroid example
    H = {"e1", "e2", "e3", "e4", "e5"}
    vecs = {
        "e1": (1, 0, 0), "e2": (0, 1, 0), "e3": (0, 0, 1),
        "e4": (1, 1, 0), "e5": (1, 0, 1),
    }

    def f2_span(vectors):
        span_vecs = {(0, 0, 0)}
        vlist = list(vectors)
        for r in range(1, len(vlist) + 1):
            for combo in combinations(vlist, r):
                v = [0, 0, 0]
                for c in combo:
                    for i in range(3):
                        v[i] = (v[i] + c[i]) % 2
                span_vecs.add(tuple(v))
        result = set()
        for name, vec in vecs.items():
            if vec in span_vecs:
                result.add(name)
        return result

    def cl(A):
        input_vecs = [vecs[h] for h in A]
        in_span = f2_span(input_vecs)
        return frozenset(A | in_span)

    cs = ClosureSystem(H, cl)
    print("=== Closure System Verification ===")
    print(f"Axioms valid: {cs.verify_axioms()}")
    print(f"Exchange valid: {cs.verify_exchange()}")
    print(f"Absorption valid: {cs.verify_absorption()}")
    print()

    print("=== Minimal Presentation ===")
    pres = construct_minimal_presentation(cs)
    props = verify_presentation_properties(cs, pres)
    print(f"States: {len(pres.states)}")
    for prop, val in props.items():
        print(f"  {prop}: {val}")
    print()

    print("=== Irredundant Sequents ===")
    seqs = extract_irredundant_sequents(cs)
    print(f"Count: {len(seqs)}")
    for s in seqs:
        premises = "{" + ", ".join(sorted(s.premises)) + "}" if s.premises else "∅"
        print(f"  {premises} ⊢ {s.conclusion}")
    print()

    print("=== Join Semilattice ===")
    lattice = compute_join_semilattice(cs)
    print(f"States: {lattice['n_states']}")
    print(f"Idempotent: {lattice['idempotent']}")
    print(f"Commutative: {lattice['commutative']}")
    print(f"Associative: {lattice['associative']}")
