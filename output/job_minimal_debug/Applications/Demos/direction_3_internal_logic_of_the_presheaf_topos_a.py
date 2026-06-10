#!/usr/bin/env python3
"""
Applications of the Temporal Adjunction framework to real-world problems.

Demonstrates:
1. Model checking via adjunction-based reasoning
2. Process equivalence detection using the Heyting algebra
3. Determinism analysis of concurrent systems
"""

from typing import Dict, List, Set, Tuple


class LTS:
    """Labeled Transition System."""

    def __init__(self, states: List[str], actions: List[str],
                 transitions: List[Tuple[str, str, str]]):
        self.states = states
        self.actions = actions
        self.trans: Dict[Tuple[str, str], Set[str]] = {}
        for s, a, t in transitions:
            self.trans.setdefault((s, a), set()).add(t)

    def successors(self, s: str, a: str) -> Set[str]:
        return self.trans.get((s, a), set())


# ============================================================
# Application 1: Model Checking via Adjunction
# ============================================================

def model_check_diamond(lts: LTS, a: str, prop: Set[str]) -> Set[str]:
    """Compute ⟨a⟩P: states that can reach P via action a."""
    return {s for s in lts.states if lts.successors(s, a) & prop}


def model_check_box(lts: LTS, a: str, prop: Set[str]) -> Set[str]:
    """Compute [a]P: states where all a-successors satisfy P."""
    return {s for s in lts.states if lts.successors(s, a).issubset(prop)}


def model_check_until(lts: LTS, a: str, phi: Set[str],
                       psi: Set[str], bound: int = 100) -> Set[str]:
    """Compute φ AU ψ (Along Until): states from which ψ is eventually
    reached along a-transitions while φ holds throughout.

    Uses the temporal adjunction: φ AU ψ = μX. ψ ∨ (φ ∧ ⟨a⟩X)

    This is a fixed-point computation derived from the adjunction structure.
    The diamond ⟨a⟩ pushes the computation forward one step, and the
    Heyting conjunction with φ ensures the invariant holds.
    """
    X = set(psi)
    for _ in range(bound):
        new_X = psi | (phi & model_check_diamond(lts, a, X))
        if new_X == X:
            break
        X = new_X
    return X


def model_check_unless(lts: LTS, a: str, phi: Set[str],
                        psi: Set[str], bound: int = 100) -> Set[str]:
    """Compute φ Unless ψ: states where ψ holds at all future points
    where φ holds, along a-transitions.

    This is the Heyting implication applied at the state level:
    (φ ⇒ ψ)(s) iff for all a-reachable states s', φ(s') → ψ(s')

    Uses the temporal adjunction: φ Unless ψ = νX. ψ ∨ (¬φ) ∨ [a]X
    (greatest fixed point)
    """
    X = set(lts.states)
    for _ in range(bound):
        not_phi = set(lts.states) - phi
        new_X = psi | not_phi | model_check_box(lts, a, X)
        new_X = new_X & X  # Monotonically decrease
        if new_X == X:
            break
        X = new_X
    return X


def app_model_checking():
    """Application 1: Model checking a simple protocol."""
    print("=" * 60)
    print("APPLICATION 1: Model Checking via Temporal Adjunction")
    print("=" * 60)

    # Model: Simple mutual exclusion protocol
    # States: idle, requesting, critical, releasing
    # Actions: request, grant, release
    lts = LTS(
        states=["idle", "requesting", "critical", "releasing"],
        actions=["request", "grant", "release", "tick"],
        transitions=[
            ("idle", "request", "requesting"),
            ("requesting", "grant", "critical"),
            ("critical", "release", "releasing"),
            ("releasing", "tick", "idle"),
        ]
    )

    safe = {"idle", "requesting", "releasing"}  # Not in critical section
    critical = {"critical"}
    requesting = {"requesting"}

    print("\nMutual Exclusion Protocol:")
    print("  States: idle → requesting → critical → releasing → idle")
    print(f"\n  Safe states (not critical): {safe}")

    # Can we reach the critical section from requesting?
    reach_critical = model_check_diamond(lts, "grant", critical)
    print(f"  ⟨grant⟩(critical) = {reach_critical}")
    print(f"  → From 'requesting', critical is reachable: "
          f"{'requesting' in reach_critical}")

    # Is the critical section always followed by release?
    box_critical = model_check_box(lts, "release", {"releasing"})
    print(f"  [release](releasing) = {box_critical}")
    print(f"  → From 'critical', release always leads to releasing: "
          f"{'critical' in box_critical}")

    # Until: requesting AU critical (eventually reach critical)
    until_result = model_check_until(lts, "grant", requesting, critical)
    print(f"  requesting AU critical = {until_result}")

    # Unless: safe Unless critical
    unless_result = model_check_unless(lts, "grant", safe, critical)
    print(f"  safe Unless critical = {unless_result}")


# ============================================================
# Application 2: Process Equivalence via Heyting Algebra
# ============================================================

def trace_set(lts: LTS, s: str, max_depth: int = 5) -> Set[Tuple[str, ...]]:
    """Compute the set of traces accepted from state s (up to max_depth)."""
    traces = {()}
    frontier = [(s, ())]

    while frontier:
        new_frontier = []
        for state, trace in frontier:
            for a in lts.actions:
                for s_next in lts.successors(state, a):
                    new_trace = trace + (a,)
                    if len(new_trace) <= max_depth:
                        traces.add(new_trace)
                        new_frontier.append((s_next, new_trace))
        frontier = new_frontier

    return traces


def heyting_distance(traces1: Set, traces2: Set,
                      all_traces: List) -> float:
    """Compute a Heyting-algebra-based distance between two trace sets.

    The distance measures how far the two trace sets are from being
    Heyting-equivalent (i.e., having the same Heyting closure).

    Returns a value in [0, 1] where 0 means equivalent.
    """
    symmetric_diff = traces1.symmetric_difference(traces2)
    if not all_traces:
        return 0.0
    return len(symmetric_diff) / len(all_traces)


def app_process_equivalence():
    """Application 2: Process equivalence analysis."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Process Equivalence via Heyting Algebra")
    print("=" * 60)

    # Two vending machines
    vm1 = LTS(
        states=["start", "coin", "coffee"],
        actions=["insert", "brew"],
        transitions=[
            ("start", "insert", "coin"),
            ("coin", "brew", "coffee"),
        ]
    )

    vm2 = LTS(
        states=["s0", "s1", "s2"],
        actions=["insert", "brew"],
        transitions=[
            ("s0", "insert", "s1"),
            ("s1", "brew", "s2"),
        ]
    )

    # Nondeterministic variant
    vm3 = LTS(
        states=["s0", "s1a", "s1b", "s2"],
        actions=["insert", "brew"],
        transitions=[
            ("s0", "insert", "s1a"),
            ("s0", "insert", "s1b"),
            ("s1a", "brew", "s2"),
            ("s1b", "brew", "s2"),
        ]
    )

    traces1 = trace_set(vm1, "start", 3)
    traces2 = trace_set(vm2, "s0", 3)
    traces3 = trace_set(vm3, "s0", 3)

    print("\nVending Machine 1 (deterministic):")
    print(f"  Traces from 'start': {sorted(traces1, key=len)}")

    print("\nVending Machine 2 (deterministic, isomorphic to VM1):")
    print(f"  Traces from 's0': {sorted(traces2, key=len)}")

    print("\nVending Machine 3 (nondeterministic):")
    print(f"  Traces from 's0': {sorted(traces3, key=len)}")

    print(f"\n  VM1 ≡_trace VM2: {traces1 == traces2}")
    print(f"  VM1 ≡_trace VM3: {traces1 == traces3}")
    print(f"  VM2 ≡_trace VM3: {traces2 == traces3}")

    print("\n  Despite trace equivalence between VM2 and VM3,")
    print("  VM3 is nondeterministic: the diamond modality")
    print("  does NOT distribute over conjunction for VM3.")

    # Show distributivity failure
    P = {"s1a"}
    Q = {"s1b"}
    dia_P = model_check_diamond(vm3, "insert", P)
    dia_Q = model_check_diamond(vm3, "insert", Q)
    dia_PQ = model_check_diamond(vm3, "insert", P & Q)

    print(f"\n  For VM3, P={P}, Q={Q}:")
    print(f"    ⟨insert⟩P = {dia_P}")
    print(f"    ⟨insert⟩Q = {dia_Q}")
    print(f"    ⟨insert⟩P ∩ ⟨insert⟩Q = {dia_P & dia_Q}")
    print(f"    ⟨insert⟩(P ∩ Q) = {dia_PQ}")
    print(f"    Distributivity holds: {dia_PQ == dia_P & dia_Q}")
    print(f"\n  → Nondeterminism detected via distributivity failure!")


# ============================================================
# Application 3: Determinism Analysis of Concurrent Systems
# ============================================================

def analyze_determinism(lts: LTS) -> Dict[str, Dict[str, bool]]:
    """Analyze determinism at each state for each action.

    Returns a dictionary mapping state → action → is_deterministic.
    """
    result = {}
    for s in lts.states:
        result[s] = {}
        for a in lts.actions:
            succs = lts.successors(s, a)
            result[s][a] = len(succs) <= 1
    return result


def app_determinism_analysis():
    """Application 3: Determinism analysis."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Determinism Analysis of Concurrent Systems")
    print("=" * 60)

    # Dining philosophers (simplified: 2 philosophers)
    lts = LTS(
        states=["thinking", "hungry", "eating_left", "eating_right", "eating"],
        actions=["get_hungry", "pick_left", "pick_right", "eat", "release"],
        transitions=[
            ("thinking", "get_hungry", "hungry"),
            ("hungry", "pick_left", "eating_left"),
            ("hungry", "pick_right", "eating_right"),
            ("eating_left", "pick_right", "eating"),
            ("eating_right", "pick_left", "eating"),
            ("eating", "release", "thinking"),
        ]
    )

    print("\nDining Philosophers (simplified):")
    print("  States: thinking → hungry → (eating_left | eating_right) → eating")

    analysis = analyze_determinism(lts)

    print("\n  Determinism analysis:")
    for state, actions in analysis.items():
        for action, is_det in actions.items():
            succs = lts.successors(state, action)
            if succs:
                status = "✓ deterministic" if is_det else "✗ NONDETERMINISTIC"
                print(f"    {state} --{action}--> {succs}: {status}")

    # Check if system is fully deterministic
    is_det = all(
        is_det for actions in analysis.values() for is_det in actions.values()
    )
    print(f"\n  System is fully deterministic: {is_det}")

    if not is_det:
        print("  → The diamond modality does NOT distribute over conjunction")
        print("  → The internal logic is NON-BOOLEAN (intuitionistic)")
        print("  → This is the temporal analogue of quantum non-distributivity")

        # Demonstrate with specific predicates
        for s in lts.states:
            for a in lts.actions:
                succs = lts.successors(s, a)
                if len(succs) >= 2:
                    succs_list = list(succs)
                    P = {succs_list[0]}
                    Q = {succs_list[1]}
                    dia_P = model_check_diamond(lts, a, P)
                    dia_Q = model_check_diamond(lts, a, Q)
                    dia_PQ = model_check_diamond(lts, a, P & Q)
                    print(f"\n  Witness at state '{s}', action '{a}':")
                    print(f"    P = {P}, Q = {Q}")
                    print(f"    ⟨{a}⟩P = {dia_P}")
                    print(f"    ⟨{a}⟩Q = {dia_Q}")
                    print(f"    ⟨{a}⟩(P∩Q) = {dia_PQ}")
                    print(f"    ⟨{a}⟩P ∩ ⟨{a}⟩Q = {dia_P & dia_Q}")
                    print(f"    Gap: {(dia_P & dia_Q) - dia_PQ}")
                    break
            else:
                continue
            break


# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TEMPORAL ADJUNCTION: Real-World Applications          ║")
    print("╚══════════════════════════════════════════════════════════╝")

    app_model_checking()
    app_process_equivalence()
    app_determinism_analysis()

    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Temporal Adjunction Demo: Interactive visualization of the presheaf topos
structure for modal logic over labeled transition systems.

Demonstrates:
1. The sieve structure of Omega for small LTS
2. The diamond/box adjunction as Galois connections
3. The Heyting implication as temporal "unless"
4. Non-Boolean witness in the sieve algebra
5. Beck-Chevalley composition of modal operators
"""

from itertools import product
from typing import Dict, FrozenSet, List, Set, Tuple


# ============================================================
# Core Data Structures
# ============================================================

class LTS:
    """Labeled Transition System."""

    def __init__(self, states, actions, transitions):
        self.states = states
        self.actions = actions
        self.trans = {}
        for s, a, t in transitions:
            self.trans.setdefault((s, a), set()).add(t)

    def successors(self, s, a):
        return self.trans.get((s, a), set())

    def is_deterministic(self):
        return all(len(v) <= 1 for v in self.trans.values())


Trace = Tuple[str, ...]


def enumerate_traces(actions, max_len):
    """Enumerate all traces up to a given length."""
    traces = [()]
    for length in range(1, max_len + 1):
        for combo in product(actions, repeat=length):
            traces.append(combo)
    return traces


def is_prefix(s, t):
    """Check if s is a prefix of t."""
    return len(s) <= len(t) and t[:len(s)] == s


# ============================================================
# Sieve Operations
# ============================================================

def compute_sieves(actions, base, max_len):
    """Compute all sieves (upward-closed sets) on base trace."""
    traces = enumerate_traces(actions, max_len)
    extensions = [t for t in traces if is_prefix(base, t)]
    n = len(extensions)

    seen = set()
    sieves = []
    for bits in range(1 << n):
        subset = frozenset(extensions[i] for i in range(n) if bits & (1 << i))
        if subset not in seen and _is_upward_closed(subset, extensions):
            seen.add(subset)
            sieves.append(subset)
    return sieves


def _is_upward_closed(s, all_traces):
    for t in s:
        for u in all_traces:
            if is_prefix(t, u) and u not in s:
                return False
    return True


# ============================================================
# Modal Operations on Traces
# ============================================================

def diamond_trace(a, P, all_traces):
    """Diamond: <a>P(tau) = exists sigma, tau = sigma ++ [a] and P(sigma)"""
    result = set()
    trace_set = set(all_traces)
    for sigma in P:
        tau = sigma + (a,)
        if tau in trace_set:
            result.add(tau)
    return result


def box_trace(a, P, all_traces):
    """Box: [a]P(tau) = forall sigma, tau = sigma ++ [a] -> P(sigma)"""
    result = set()
    for tau in all_traces:
        if len(tau) > 0 and tau[-1] == a:
            sigma = tau[:-1]
            if sigma in P:
                result.add(tau)
        else:
            result.add(tau)
    return result


def pullback_ext(a, P, all_traces):
    """Pullback: (ext_a)*(P)(sigma) = P(sigma ++ [a])"""
    result = set()
    for sigma in all_traces:
        tau = sigma + (a,)
        if tau in P:
            result.add(sigma)
    return result


# ============================================================
# LTS Modal Operations
# ============================================================

def lts_diamond(lts, a, P):
    return {s for s in lts.states if lts.successors(s, a) & P}


def lts_box(lts, a, P):
    return {s for s in lts.states if lts.successors(s, a).issubset(P)}


# ============================================================
# Heyting Operations
# ============================================================

def heyting_impl(P, Q, all_traces):
    """(P => Q)(sigma) = forall tau, sigma prefix tau -> P(tau) -> Q(tau)"""
    result = set()
    for sigma in all_traces:
        holds = True
        for tau in all_traces:
            if is_prefix(sigma, tau) and tau in P and tau not in Q:
                holds = False
                break
        if holds:
            result.add(sigma)
    return result


def heyting_neg(P, all_traces):
    """Heyting negation: not_H P(sigma) = forall tau, sigma prefix tau -> tau not in P"""
    result = set()
    for sigma in all_traces:
        no_ext = True
        for tau in all_traces:
            if is_prefix(sigma, tau) and tau in P:
                no_ext = False
                break
        if no_ext:
            result.add(sigma)
    return result


# ============================================================
# DEMO 1: Sieve Structure
# ============================================================

def demo_sieve_structure():
    print("=" * 60)
    print("DEMO 1: Sieve Structure of Omega (Subobject Classifier)")
    print("=" * 60)

    actions = ["a"]
    base = ()
    max_len = 2

    sieves = compute_sieves(actions, base, max_len)
    traces = enumerate_traces(actions, max_len)
    extensions = [t for t in traces if is_prefix(base, t)]

    print(f"\nAction set: {actions}")
    print(f"Base trace: {base}")
    print(f"Max trace length: {max_len}")
    print(f"Extensions of base: {extensions}")
    print(f"\nNumber of sieves on base: {len(sieves)}")
    print(f"(These form the subobject classifier Omega(base))")
    print()

    for i, sieve in enumerate(sorted(sieves, key=len)):
        label = " [bottom]" if len(sieve) == 0 else " [top]" if len(sieve) == len(extensions) else ""
        print(f"  Sieve {i}: {set(sieve) if sieve else 'empty'}{label}")

    n_ext = len(extensions)
    print(f"\n  |Omega(base)| = {len(sieves)}")
    print(f"  Number of extensions = {n_ext}")
    print(f"  Total subsets = {2**n_ext}")
    print(f"  Upward-closed subsets (sieves) = {len(sieves)}")


# ============================================================
# DEMO 2: Diamond/Box Adjunction
# ============================================================

def demo_adjunction():
    print("\n" + "=" * 60)
    print("DEMO 2: Diamond/Box Adjunction (Galois Connection)")
    print("=" * 60)

    actions = ["a", "b"]
    max_len = 2
    traces = enumerate_traces(actions, max_len)

    a = "a"
    P = {(), ("b",)}
    Q = {("a",), ("a", "b")}

    dia_P = diamond_trace(a, P, traces)
    pull_Q = pullback_ext(a, Q, traces)

    print(f"\nAction: {a}")
    print(f"P = {P}")
    print(f"Q = {Q}")
    print(f"<{a}>P = {dia_P}")
    print(f"(ext_{a})*(Q) = {pull_Q}")

    dia_subset_Q = dia_P.issubset(Q)
    P_subset_pull = P.issubset(pull_Q)

    print(f"\n<{a}>P subset Q: {dia_subset_Q}")
    print(f"P subset (ext_{a})*(Q): {P_subset_pull}")
    ok = dia_subset_Q == P_subset_pull
    print(f"Adjunction holds: {ok}")

    # Exhaustive verification with interior traces
    print("\n--- Exhaustive adjunction verification ---")
    print("(P restricted to interior traces to avoid boundary effects)")
    small_max = 3
    small_traces = enumerate_traces(["a"], small_max)
    interior = [t for t in small_traces if len(t) < small_max]
    n_int = len(interior)
    n_all = len(small_traces)
    violations = 0
    total = 0

    for p_bits in range(2 ** n_int):
        P_test = {interior[i] for i in range(n_int) if p_bits & (1 << i)}
        for q_bits in range(2 ** n_all):
            Q_test = {small_traces[i] for i in range(n_all) if q_bits & (1 << i)}
            total += 1

            dia = diamond_trace("a", P_test, small_traces)
            pull = pullback_ext("a", Q_test, small_traces)

            left = dia.issubset(Q_test)
            right = P_test.issubset(pull)

            if left != right:
                violations += 1

    print(f"Tested {total} predicate pairs")
    print(f"Violations: {violations}")
    status = "VERIFIED" if violations == 0 else "FAILED"
    print(f"Diamond adjunction: {status}")


# ============================================================
# DEMO 3: Heyting Implication = Temporal Unless
# ============================================================

def demo_heyting():
    print("\n" + "=" * 60)
    print("DEMO 3: Heyting Implication = Temporal Unless")
    print("=" * 60)

    actions = ["a", "b"]
    max_len = 2
    traces = enumerate_traces(actions, max_len)

    P_contains_a = {t for t in traces if "a" in t}
    Q_len_ge_1 = {t for t in traces if len(t) >= 1}

    impl = heyting_impl(P_contains_a, Q_len_ge_1, traces)

    print(f"\nP (contains 'a'): {sorted(P_contains_a, key=len)}")
    print(f"Q (length >= 1): {sorted(Q_len_ge_1, key=len)}")
    print(f"\n(P => Q) = {sorted(impl, key=len)}")
    print(f"\nInterpretation: (P => Q)(sigma) holds iff for all extensions tau of sigma,")
    print(f"if tau contains 'a' then len(tau) >= 1. Always true!")
    print(f"(P => Q) = all traces: {impl == set(traces)}")

    # Non-Boolean witness
    print("\n--- Non-Boolean Witness ---")
    neg_P = heyting_neg(P_contains_a, traces)

    # Double negation: sigma such that not all extensions avoid P
    dbl_neg_P = set()
    for sigma in traces:
        has_ext_in_P = any(is_prefix(sigma, tau) and tau in P_contains_a
                          for tau in traces)
        if has_ext_in_P:
            dbl_neg_P.add(sigma)

    print(f"P (contains 'a'): {sorted(P_contains_a, key=len)}")
    print(f"not_H P: {sorted(neg_P, key=len)}")
    print(f"not_not_H P: {sorted(dbl_neg_P, key=len)}")
    print(f"\n() in P: {() in P_contains_a}")
    print(f"() in not_not_H P: {() in dbl_neg_P}")
    gap = dbl_neg_P - P_contains_a
    print(f"Gap (not_not_H P \\ P): {sorted(gap, key=len)}")
    print(f"Non-Boolean: {bool(gap)}")


# ============================================================
# DEMO 4: LTS Modalities and Determinism
# ============================================================

def demo_lts_modalities():
    print("\n" + "=" * 60)
    print("DEMO 4: LTS Modalities and Determinism")
    print("=" * 60)

    nd_lts = LTS(
        states=["s0", "s1", "s2"],
        actions=["a"],
        transitions=[("s0", "a", "s1"), ("s0", "a", "s2")]
    )

    det_lts = LTS(
        states=["s0", "s1", "s2"],
        actions=["a"],
        transitions=[("s0", "a", "s1"), ("s1", "a", "s2")]
    )

    for name, lts in [("Nondeterministic", nd_lts), ("Deterministic", det_lts)]:
        print(f"\n--- {name} LTS ---")
        print(f"  Deterministic: {lts.is_deterministic()}")

        P = {"s1"}
        Q = {"s2"}
        a = "a"

        dia_P = lts_diamond(lts, a, P)
        dia_Q = lts_diamond(lts, a, Q)
        dia_PQ = lts_diamond(lts, a, P & Q)
        dia_P_inter_dia_Q = dia_P & dia_Q

        box_P = lts_box(lts, a, P)
        compl_P = {s for s in lts.states if s not in P}
        dia_compl = lts_diamond(lts, a, compl_P)
        box_via_dm = {s for s in lts.states if s not in dia_compl}

        print(f"  P = {P}, Q = {Q}")
        print(f"  <a>P = {dia_P}")
        print(f"  <a>Q = {dia_Q}")
        print(f"  <a>(P inter Q) = {dia_PQ}")
        print(f"  <a>P inter <a>Q = {dia_P_inter_dia_Q}")
        dist = dia_PQ == dia_P_inter_dia_Q
        print(f"  Diamond distributes over conjunction: {dist}")
        print(f"  [a]P = {box_P}")
        print(f"  not<a>notP = {box_via_dm}")
        print(f"  De Morgan [a]P = not<a>notP: {box_P == box_via_dm}")


# ============================================================
# DEMO 5: Beck-Chevalley Composition
# ============================================================

def demo_beck_chevalley():
    print("\n" + "=" * 60)
    print("DEMO 5: Beck-Chevalley Composition")
    print("=" * 60)

    actions = ["a", "b"]
    max_len = 3
    traces = enumerate_traces(actions, max_len)

    P = {(), ("a",), ("b",)}

    # Compose diamonds
    dia_a_P = diamond_trace("a", P, traces)
    dia_b_dia_a_P = diamond_trace("b", dia_a_P, traces)

    # Two-step diamond <a,b>P
    dia_ab_P = set()
    for sigma in P:
        tau = sigma + ("a", "b")
        if tau in set(traces):
            dia_ab_P.add(tau)

    print(f"\nP = {P}")
    print(f"<a>P = {dia_a_P}")
    print(f"<b>(<a>P) = {dia_b_dia_a_P}")
    print(f"<a,b>P = {dia_ab_P}")
    bc_dia = dia_b_dia_a_P == dia_ab_P
    print(f"\nBeck-Chevalley for diamond: <b> o <a> = <a,b>: {bc_dia}")

    # Compose boxes
    box_a_P = box_trace("a", P, traces)
    box_b_box_a_P = box_trace("b", box_a_P, traces)

    # Two-step box [[a,b]]P
    box_ab_P = set()
    for tau in traces:
        if len(tau) >= 2 and tau[-2:] == ("a", "b"):
            sigma = tau[:-2]
            if sigma in P:
                box_ab_P.add(tau)
        else:
            box_ab_P.add(tau)

    print(f"\n[a]P (first 5): {sorted(box_a_P, key=len)[:5]}")
    print(f"[b]([a]P) (first 5): {sorted(box_b_box_a_P, key=len)[:5]}")
    print(f"[[a,b]]P (first 5): {sorted(box_ab_P, key=len)[:5]}")
    bc_box = box_b_box_a_P == box_ab_P
    print(f"Beck-Chevalley for box: [b] o [a] = [[a,b]]: {bc_box}")


# ============================================================
# Main
# ============================================================

def main():
    print("=" * 60)
    print("  TEMPORAL ADJUNCTION: Modal Logic in Presheaf Topos")
    print("=" * 60)

    demo_sieve_structure()
    demo_adjunction()
    demo_heyting()
    demo_lts_modalities()
    demo_beck_chevalley()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()
