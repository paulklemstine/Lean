#!/usr/bin/env python3
"""
Algorithms for the Temporal Adjunction framework.

Implements:
1. Sieve enumeration for the experiment category
2. Heyting algebra operations on sieves
3. Adjunction verification algorithm
4. Distributivity test for LTS determinism
5. Non-Boolean witness computation
"""

from itertools import product
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

Trace = Tuple[str, ...]


def is_prefix(s: Trace, t: Trace) -> bool:
    """Check if trace s is a prefix of trace t.

    Complexity: O(min(|s|, |t|))
    """
    return len(s) <= len(t) and t[:len(s)] == s


def enumerate_traces(actions: List[str], max_len: int) -> List[Trace]:
    """Enumerate all traces over the given action set up to max_len.

    Args:
        actions: The action alphabet.
        max_len: Maximum trace length.

    Returns:
        List of all traces (tuples of actions) of length 0 to max_len.

    Complexity: O(|actions|^max_len)
    """
    traces = [()]
    for length in range(1, max_len + 1):
        for combo in product(actions, repeat=length):
            traces.append(combo)
    return traces


# ============================================================
# Algorithm 1: Sieve Enumeration
# ============================================================

def enumerate_sieves(actions: List[str], base: Trace,
                     max_len: int) -> List[FrozenSet[Trace]]:
    """Enumerate all sieves (upward-closed sets) on a base trace.

    A sieve on base trace σ is an upward-closed set of extensions of σ.
    "Upward-closed" means: if τ ∈ S and τ is a prefix of ρ, then ρ ∈ S.

    Args:
        actions: The action alphabet.
        base: The base trace σ.
        max_len: Maximum trace length to consider.

    Returns:
        List of all sieves on base, each as a frozenset of traces.

    Complexity: O(2^N) where N = number of extensions of base up to max_len.
                This is optimal since there can be exponentially many sieves.

    Example:
        >>> sieves = enumerate_sieves(["a"], (), 2)
        >>> len(sieves)  # Should include ∅, {(a,),(a,a)}, {(a,a)}, {(),(a,),(a,a)}
        4
    """
    traces = enumerate_traces(actions, max_len)
    extensions = [t for t in traces if is_prefix(base, t)]

    sieves = []
    n = len(extensions)

    for bits in range(1 << n):
        subset = frozenset(extensions[i] for i in range(n) if bits & (1 << i))
        if _is_upward_closed(subset, extensions):
            sieves.append(subset)

    return sieves


def _is_upward_closed(s: FrozenSet[Trace], all_traces: List[Trace]) -> bool:
    """Check if a set of traces is upward-closed.

    Complexity: O(|s| · |all_traces|)
    """
    for t in s:
        for u in all_traces:
            if is_prefix(t, u) and u not in s:
                return False
    return True


# ============================================================
# Algorithm 2: Heyting Algebra Operations
# ============================================================

def heyting_meet(S1: FrozenSet[Trace], S2: FrozenSet[Trace]) -> FrozenSet[Trace]:
    """Heyting algebra meet (intersection of sieves).

    Complexity: O(min(|S1|, |S2|))
    """
    return S1 & S2


def heyting_join(S1: FrozenSet[Trace], S2: FrozenSet[Trace]) -> FrozenSet[Trace]:
    """Heyting algebra join (union of sieves).

    Complexity: O(|S1| + |S2|)
    """
    return S1 | S2


def heyting_implication(P: FrozenSet[Trace], Q: FrozenSet[Trace],
                         all_traces: List[Trace]) -> FrozenSet[Trace]:
    """Compute the Heyting implication P ⇒ Q.

    (P ⇒ Q)(σ) = ∀τ, σ <+: τ → τ ∈ P → τ ∈ Q

    This is the temporal "unless" operator: at σ, P ⇒ Q holds iff
    for all future extensions, whenever P holds, Q also holds.

    Args:
        P, Q: Sieves (upward-closed sets of traces).
        all_traces: Universe of traces.

    Returns:
        The Heyting implication as a frozenset.

    Complexity: O(|all_traces|^2)
    """
    result = set()
    for sigma in all_traces:
        holds = True
        for tau in all_traces:
            if is_prefix(sigma, tau) and tau in P and tau not in Q:
                holds = False
                break
        if holds:
            result.add(sigma)
    return frozenset(result)


def heyting_negation(P: FrozenSet[Trace],
                      all_traces: List[Trace]) -> FrozenSet[Trace]:
    """Compute the Heyting negation ¬_H P = P ⇒ ⊥.

    ¬_H P(σ) = ∀τ, σ <+: τ → τ ∉ P
    "No extension of σ is in P"

    Complexity: O(|all_traces|^2)
    """
    return heyting_implication(P, frozenset(), all_traces)


def double_heyting_negation(P: FrozenSet[Trace],
                             all_traces: List[Trace]) -> FrozenSet[Trace]:
    """Compute ¬_H ¬_H P.

    ¬¬P(σ) holds iff every extension of σ has a further extension in P.
    This is the "density" condition: P is dense above σ.

    Complexity: O(|all_traces|^3)
    """
    neg_P = heyting_negation(P, all_traces)
    return heyting_negation(neg_P, all_traces)


# ============================================================
# Algorithm 3: Adjunction Verification
# ============================================================

def diamond(a: str, P: FrozenSet[Trace],
            all_traces: List[Trace]) -> FrozenSet[Trace]:
    """Diamond modality ⟨a⟩P.

    ⟨a⟩P(τ) = ∃σ, τ = σ ++ [a] ∧ P(σ)

    Complexity: O(|P|)
    """
    result = set()
    trace_set = set(all_traces)
    for sigma in P:
        tau = sigma + (a,)
        if tau in trace_set:
            result.add(tau)
    return frozenset(result)


def box(a: str, P: FrozenSet[Trace],
        all_traces: List[Trace]) -> FrozenSet[Trace]:
    """Box modality [a]P.

    [a]P(τ) = ∀σ, τ = σ ++ [a] → P(σ)

    Complexity: O(|all_traces|)
    """
    result = set()
    for tau in all_traces:
        if len(tau) > 0 and tau[-1] == a:
            sigma = tau[:-1]
            if sigma in P:
                result.add(tau)
        else:
            result.add(tau)
    return frozenset(result)


def pullback_ext(a: str, P: FrozenSet[Trace],
                 all_traces: List[Trace]) -> FrozenSet[Trace]:
    """Pullback along trace extension (ext_a)*(P).

    (ext_a)*(P)(σ) = P(σ ++ [a])

    Complexity: O(|all_traces|)
    """
    result = set()
    for sigma in all_traces:
        tau = sigma + (a,)
        if tau in P:
            result.add(sigma)
    return frozenset(result)


def verify_adjunction(actions: List[str], max_len: int) -> bool:
    """Verify the adjunction ⟨a⟩ ⊣ (ext_a)* ⊣ [a] exhaustively.

    Tests both:
    - Left adjunction: ⟨a⟩P ⊆ Q ↔ P ⊆ (ext_a)*Q
    - Right adjunction: (ext_a)*P ⊆ Q ↔ P ⊆ [a]Q

    Args:
        actions: The action alphabet.
        max_len: Maximum trace length.

    Returns:
        True if the adjunction holds for all predicates.

    Complexity: O(|actions| · 2^{2N}) where N = number of traces.
    """
    traces = enumerate_traces(actions, max_len)
    # Restrict P to interior traces (length < max_len) to avoid boundary effects
    interior = [t for t in traces if len(t) < max_len]
    n_int = len(interior)
    n = len(traces)
    trace_set = set(traces)

    for a in actions:
        for p_bits in range(1 << n_int):
            P = frozenset(interior[i] for i in range(n_int) if p_bits & (1 << i))
            for q_bits in range(1 << n):
                Q = frozenset(traces[i] for i in range(n) if q_bits & (1 << i))

                # Left adjunction
                dia = diamond(a, P, traces)
                pull_Q = pullback_ext(a, Q, traces)
                left_lhs = dia.issubset(Q)
                left_rhs = P.issubset(pull_Q)
                if left_lhs != left_rhs:
                    return False

                # Right adjunction
                pull_P = pullback_ext(a, P, traces)
                bx = box(a, Q, traces)
                right_lhs = pull_P.issubset(Q)
                right_rhs = P.issubset(bx)
                if right_lhs != right_rhs:
                    return False

    return True


# ============================================================
# Algorithm 4: Distributivity Test
# ============================================================

class LTS:
    """Labeled Transition System for distributivity analysis."""

    def __init__(self, states: List[str], actions: List[str],
                 transitions: List[Tuple[str, str, str]]):
        self.states = states
        self.actions = actions
        self.trans: Dict[Tuple[str, str], Set[str]] = {}
        for s, a, t in transitions:
            self.trans.setdefault((s, a), set()).add(t)

    def successors(self, s: str, a: str) -> Set[str]:
        return self.trans.get((s, a), set())

    def is_deterministic_at(self, s: str, a: str) -> bool:
        return len(self.successors(s, a)) <= 1

    def is_deterministic(self) -> bool:
        return all(
            self.is_deterministic_at(s, a)
            for s in self.states for a in self.actions
        )


def lts_diamond(lts: LTS, a: str, P: Set[str]) -> Set[str]:
    """LTS diamond modality ⟨a⟩P."""
    return {s for s in lts.states if lts.successors(s, a) & P}


def lts_box(lts: LTS, a: str, P: Set[str]) -> Set[str]:
    """LTS box modality [a]P."""
    return {s for s in lts.states if lts.successors(s, a).issubset(P)}


def test_distributivity(lts: LTS, a: str) -> Tuple[bool, Optional[Tuple]]:
    """Test if diamond distributes over conjunction for action a.

    Returns (holds, counterexample) where counterexample is
    (s, P, Q) witnessing failure, or None.

    Complexity: O(|S|^3) — tests all singleton predicate pairs.
    """
    for s in lts.states:
        succs = lts.successors(s, a)
        if len(succs) >= 2:
            succs_list = list(succs)
            s1, s2 = succs_list[0], succs_list[1]
            P = {s1}
            Q = {s2}
            dia_P_inter_Q = lts_diamond(lts, a, P & Q)
            dia_P_cap_dia_Q = lts_diamond(lts, a, P) & lts_diamond(lts, a, Q)
            if dia_P_inter_Q != dia_P_cap_dia_Q:
                return False, (s, P, Q)
    return True, None


# ============================================================
# Algorithm 5: Non-Boolean Witness
# ============================================================

def find_non_boolean_witness(actions: List[str],
                              max_len: int) -> Optional[Tuple]:
    """Find a witness showing the sieve algebra is non-Boolean.

    Searches for a sieve P such that ¬¬P ⊋ P.

    Returns (P, sigma, trace_info) or None.

    Complexity: O(2^N · N^3) where N = number of traces.
    """
    traces = enumerate_traces(actions, max_len)
    sieves = enumerate_sieves(actions, (), max_len)

    for sieve in sieves:
        dbl_neg = double_heyting_negation(sieve, traces)
        if dbl_neg.issuperset(sieve) and dbl_neg != sieve:
            gap = dbl_neg - sieve
            return sieve, gap, traces

    return None


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

def main():
    print("=" * 60)
    print("TEMPORAL ADJUNCTION: Algorithm Demonstrations")
    print("=" * 60)

    # Algorithm 1: Sieve enumeration
    print("\n--- Algorithm 1: Sieve Enumeration ---")
    actions = ["a"]
    sieves = enumerate_sieves(actions, (), 2)
    print(f"Actions: {actions}, max_len: 2")
    print(f"Number of sieves on (): {len(sieves)}")
    for s in sorted(sieves, key=len):
        print(f"  {set(s) if s else '∅'}")

    # Algorithm 2: Heyting operations
    print("\n--- Algorithm 2: Heyting Algebra ---")
    traces = enumerate_traces(["a"], 2)
    P = frozenset({("a",), ("a", "a")})
    Q = frozenset({(), ("a",), ("a", "a")})
    impl = heyting_implication(P, Q, traces)
    neg = heyting_negation(P, traces)
    print(f"P = {set(P)}")
    print(f"Q = {set(Q)}")
    print(f"P ⇒ Q = {set(impl)}")
    print(f"¬_H P = {set(neg)}")

    # Algorithm 3: Adjunction verification
    print("\n--- Algorithm 3: Adjunction Verification ---")
    result = verify_adjunction(["a"], 2)
    print(f"Adjunction verified for Act={{a}}, max_len=2: {result}")

    result2 = verify_adjunction(["a", "b"], 1)
    print(f"Adjunction verified for Act={{a,b}}, max_len=1: {result2}")

    # Algorithm 4: Distributivity test
    print("\n--- Algorithm 4: Distributivity Test ---")

    det_lts = LTS(["s0", "s1", "s2"], ["a"],
                   [("s0", "a", "s1"), ("s1", "a", "s2")])
    holds, cex = test_distributivity(det_lts, "a")
    print(f"Deterministic LTS: distributive = {holds}")

    nd_lts = LTS(["s0", "s1", "s2"], ["a"],
                  [("s0", "a", "s1"), ("s0", "a", "s2")])
    holds, cex = test_distributivity(nd_lts, "a")
    print(f"Nondeterministic LTS: distributive = {holds}")
    if cex:
        print(f"  Counterexample: state={cex[0]}, P={cex[1]}, Q={cex[2]}")

    # Algorithm 5: Non-Boolean witness
    print("\n--- Algorithm 5: Non-Boolean Witness ---")
    witness = find_non_boolean_witness(["a"], 2)
    if witness:
        sieve, gap, _ = witness
        print(f"Found non-Boolean witness:")
        print(f"  P = {set(sieve)}")
        print(f"  ¬¬P \\ P = {set(gap)}")
        print(f"  The Heyting algebra is NON-BOOLEAN")
    else:
        print("No witness found (algebra may be Boolean)")

    print("\n" + "=" * 60)
    print("All algorithms completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()
