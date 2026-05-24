#!/usr/bin/env python3
"""
Applications of the Boolean Topos Characterization of Determinism

Demonstrates real-world applications of the theorem:
  Determinism ↔ Diamond distributes over conjunction

1. Network Protocol Analysis: Detect hidden nondeterminism in protocols
2. Concurrency Verification: Check if parallel composition preserves
   Boolean logic
3. Biological Pathway Analysis: Classify signaling cascades by their
   logical structure
"""

from typing import Dict, List, Set, Tuple, Optional
from algorithms import (
    LTS, check_determinism, check_diamond_distributive,
    construct_nonboolean_witness, compute_bisimulation,
    branching_entropy, nondistributivity_score, diamond
)
import itertools

# ═══════════════════════════════════════════════════════════════════════
# Application 1: Network Protocol Analysis
# ═══════════════════════════════════════════════════════════════════════

def tcp_handshake_deterministic() -> LTS:
    """Model of a simplified TCP handshake (deterministic).

    States: 0=CLOSED, 1=SYN_SENT, 2=ESTABLISHED, 3=FIN_WAIT
    This models the client side with no packet loss.
    """
    return LTS(
        states={0, 1, 2, 3},
        actions={"syn", "syn_ack", "data", "fin"},
        transitions={
            (0, "syn", 1),        # CLOSED → SYN_SENT
            (1, "syn_ack", 2),    # SYN_SENT → ESTABLISHED
            (2, "data", 2),       # ESTABLISHED → ESTABLISHED (send data)
            (2, "fin", 3),        # ESTABLISHED → FIN_WAIT
        }
    )


def tcp_with_timeout() -> LTS:
    """Model of TCP with nondeterministic timeout behavior.

    From SYN_SENT, the response could be a SYN_ACK (success) or
    a timeout (back to CLOSED). This nondeterminism breaks Boolean logic.
    """
    return LTS(
        states={0, 1, 2, 3},
        actions={"syn", "response", "data", "fin"},
        transitions={
            (0, "syn", 1),
            (1, "response", 2),   # Success: SYN_ACK received
            (1, "response", 0),   # Timeout: back to CLOSED
            (2, "data", 2),
            (2, "fin", 3),
        }
    )


def analyze_protocol(name: str, lts: LTS):
    """Analyze a protocol LTS for logical classicality."""
    print(f"\n  Protocol: {name}")
    det = check_determinism(lts)
    dist = check_diamond_distributive(lts)
    print(f"    Deterministic:  {det.is_deterministic}")
    print(f"    Boolean logic:  {dist.is_distributive}")
    if not det.is_deterministic:
        w = construct_nonboolean_witness(lts)
        if w:
            print(f"    ⚠ Non-Boolean witness: {w.explanation}")
    entropy = branching_entropy(lts)
    print(f"    Branching entropy: {entropy:.4f} bits")


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Parallel Composition and Concurrency
# ═══════════════════════════════════════════════════════════════════════

def interleaving_product(l1: LTS, l2: LTS,
                         shared_actions: Set[str] = set()) -> LTS:
    """Compute the interleaving (asynchronous) product of two LTS.

    For independent actions, both components can move independently.
    For shared actions, both must synchronize.

    Args:
        l1, l2: Component LTS
        shared_actions: Actions that require synchronization

    Returns:
        Product LTS with state space l1.states × l2.states
    """
    states = set()
    transitions = set()
    all_actions = l1.actions | l2.actions

    for s1 in l1.states:
        for s2 in l2.states:
            state = s1 * 100 + s2  # Encode pair as single int
            states.add(state)

    for s1 in l1.states:
        for s2 in l2.states:
            src = s1 * 100 + s2
            for a in all_actions:
                if a in shared_actions:
                    # Synchronize
                    for t1 in l1.successors(s1, a):
                        for t2 in l2.successors(s2, a):
                            transitions.add((src, a, t1 * 100 + t2))
                elif a in l1.actions:
                    for t1 in l1.successors(s1, a):
                        transitions.add((src, a, t1 * 100 + s2))
                elif a in l2.actions:
                    for t2 in l2.successors(s2, a):
                        transitions.add((src, a, s1 * 100 + t2))

    return LTS(states=states, actions=all_actions, transitions=transitions)


def concurrency_analysis():
    """Analyze whether parallel composition preserves Boolean logic."""
    print("\n  === Parallel Composition Analysis ===")

    # Two deterministic components
    comp1 = LTS(
        states={0, 1},
        actions={"a"},
        transitions={(0, "a", 1), (1, "a", 0)}
    )
    comp2 = LTS(
        states={0, 1},
        actions={"b"},
        transitions={(0, "b", 1), (1, "b", 0)}
    )
    product = interleaving_product(comp1, comp2)
    det = check_determinism(product)
    print(f"\n  Det ∥ Det (independent actions):")
    print(f"    Product deterministic: {det.is_deterministic}")
    print(f"    → Boolean logic preserved: {det.is_deterministic}")

    # Deterministic with shared action
    comp3 = LTS(
        states={0, 1},
        actions={"a"},
        transitions={(0, "a", 1), (1, "a", 0)}
    )
    comp4 = LTS(
        states={0, 1},
        actions={"a"},
        transitions={(0, "a", 1), (1, "a", 0)}
    )
    product2 = interleaving_product(comp3, comp4, shared_actions={"a"})
    det2 = check_determinism(product2)
    print(f"\n  Det ∥ Det (shared action, synchronized):")
    print(f"    Product deterministic: {det2.is_deterministic}")

    # One nondeterministic component
    comp5 = LTS(
        states={0, 1, 2},
        actions={"a"},
        transitions={(0, "a", 1), (0, "a", 2), (1, "a", 1), (2, "a", 2)}
    )
    product3 = interleaving_product(comp1, comp5)
    det3 = check_determinism(product3)
    print(f"\n  Det ∥ Nondet (independent):")
    print(f"    Product deterministic: {det3.is_deterministic}")
    print(f"    → Boolean logic broken: {not det3.is_deterministic}")
    if not det3.is_deterministic:
        w = construct_nonboolean_witness(product3)
        if w:
            print(f"    Witness: state {w.state}, action {w.action}")


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Biological Pathway Classification
# ═══════════════════════════════════════════════════════════════════════

def simple_signaling_cascade() -> LTS:
    """A deterministic signaling cascade: ligand → receptor → kinase → gene.

    States: 0=inactive, 1=ligand_bound, 2=kinase_active, 3=gene_on
    """
    return LTS(
        states={0, 1, 2, 3},
        actions={"bind", "phosphorylate", "transcribe"},
        transitions={
            (0, "bind", 1),
            (1, "phosphorylate", 2),
            (2, "transcribe", 3),
        }
    )


def branching_signaling() -> LTS:
    """A nondeterministic signaling pathway with alternative outcomes.

    The kinase can activate either gene A or gene B — a genuine
    biological nondeterminism (stochastic cell fate decision).

    States: 0=inactive, 1=ligand_bound, 2=kinase_active,
            3=gene_A_on, 4=gene_B_on
    """
    return LTS(
        states={0, 1, 2, 3, 4},
        actions={"bind", "phosphorylate", "transcribe"},
        transitions={
            (0, "bind", 1),
            (1, "phosphorylate", 2),
            (2, "transcribe", 3),   # Path A
            (2, "transcribe", 4),   # Path B — nondeterminism!
        }
    )


def biological_analysis():
    """Classify biological pathways by their logical structure."""
    print("\n  === Biological Pathway Classification ===")

    for name, lts in [
        ("Simple cascade (deterministic)", simple_signaling_cascade()),
        ("Branching fate decision (nondeterministic)", branching_signaling()),
    ]:
        print(f"\n  Pathway: {name}")
        det = check_determinism(lts)
        print(f"    Deterministic: {det.is_deterministic}")
        print(f"    Logic type: {'Boolean (classical)' if det.is_deterministic else 'Heyting (non-classical)'}")
        entropy = branching_entropy(lts)
        print(f"    Branching entropy: {entropy:.4f} bits")
        if not det.is_deterministic:
            w = construct_nonboolean_witness(lts)
            if w:
                print(f"    Non-Boolean witness: {w.explanation}")


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Exhaustive Classification Table
# ═══════════════════════════════════════════════════════════════════════

def exhaustive_classification(max_states: int = 3, n_actions: int = 1):
    """Generate classification table for all small LTS.

    For each LTS, reports:
    - Deterministic?
    - Diamond distributive? (should match!)
    - Branching entropy
    - Non-distributivity score
    - Number of bisimulation classes
    """
    print(f"\n  === Exhaustive Classification (≤{max_states} states, "
          f"{n_actions} action(s)) ===")

    actions = {f"a{i}" for i in range(n_actions)}
    action_list = sorted(actions)
    results = {"det": 0, "nondet": 0, "agree": 0, "total": 0}

    for n in range(2, max_states + 1):
        states = set(range(n))
        pairs = [(s, a) for s in range(n) for a in action_list]

        for choice in itertools.product(range(1 << n), repeat=len(pairs)):
            trans = set()
            for idx, (s, a) in enumerate(pairs):
                for i in range(n):
                    if choice[idx] & (1 << i):
                        trans.add((s, a, i))

            lts = LTS(states=states, actions=actions, transitions=trans)
            det = check_determinism(lts).is_deterministic
            dist = check_diamond_distributive(lts).is_distributive

            results["total"] += 1
            if det:
                results["det"] += 1
            else:
                results["nondet"] += 1
            if det == dist:
                results["agree"] += 1

    print(f"\n  Results:")
    print(f"    Total LTS:       {results['total']}")
    print(f"    Deterministic:   {results['det']}")
    print(f"    Nondeterministic:{results['nondet']}")
    print(f"    Theorem verified:{results['agree']}/{results['total']} "
          f"({'✓ 100%' if results['agree'] == results['total'] else '✗ FAILURES'})")


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications: Boolean Topos & Determinism              ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Application 1: Network protocols
    print("\n" + "="*60)
    print(" Application 1: Network Protocol Analysis")
    print("="*60)
    analyze_protocol("TCP Handshake (ideal)", tcp_handshake_deterministic())
    analyze_protocol("TCP with Timeout", tcp_with_timeout())

    # Application 2: Concurrency
    print("\n" + "="*60)
    print(" Application 2: Concurrency Verification")
    print("="*60)
    concurrency_analysis()

    # Application 3: Biology
    print("\n" + "="*60)
    print(" Application 3: Biological Pathways")
    print("="*60)
    biological_analysis()

    # Application 4: Exhaustive classification
    print("\n" + "="*60)
    print(" Application 4: Exhaustive Classification")
    print("="*60)
    exhaustive_classification(max_states=3, n_actions=1)


#!/usr/bin/env python3
"""
Boolean Topos Characterization of Determinism — Interactive Demo

This script demonstrates the central theorem:
  Determinism ↔ Diamond distributes over conjunction

It constructs small LTS examples, checks determinism, computes diamond
operations, and highlights non-Boolean witnesses when branching is present.
"""

from itertools import product as cartesian_product
from typing import Dict, List, Set, Tuple, Optional

# ─── Core Types ───────────────────────────────────────────────────────

State = int
Action = str
Transition = Tuple[State, Action, State]


class LTS:
    """A labeled transition system."""

    def __init__(self, states: List[State], actions: List[Action],
                 transitions: List[Transition], name: str = ""):
        self.states = set(states)
        self.actions = set(actions)
        self.transitions = set(transitions)
        self.name = name
        # Build adjacency: (state, action) -> set of successors
        self._succ: Dict[Tuple[State, Action], Set[State]] = {}
        for s, a, t in transitions:
            self._succ.setdefault((s, a), set()).add(t)

    def successors(self, s: State, a: Action) -> Set[State]:
        return self._succ.get((s, a), set())

    def is_deterministic_at(self, s: State, a: Action) -> bool:
        return len(self.successors(s, a)) <= 1

    def is_fully_deterministic(self) -> bool:
        return all(self.is_deterministic_at(s, a)
                   for s in self.states for a in self.actions)

    def is_total_at(self, s: State, a: Action) -> bool:
        return len(self.successors(s, a)) >= 1

    def is_total(self) -> bool:
        return all(self.is_total_at(s, a)
                   for s in self.states for a in self.actions)


# ─── Modal Operators ──────────────────────────────────────────────────

def diamond(lts: LTS, a: Action, P: Set[State]) -> Set[State]:
    """⟨a⟩P = {s | ∃ t ∈ P, s →[a] t}"""
    return {s for s in lts.states
            if lts.successors(s, a) & P}


def box(lts: LTS, a: Action, P: Set[State]) -> Set[State]:
    """[a]P = {s | ∀ t, s →[a] t → t ∈ P}"""
    return {s for s in lts.states
            if lts.successors(s, a) <= P}


# ─── Diamond Distributivity Check ────────────────────────────────────

def check_diamond_distributive(lts: LTS) -> Tuple[bool, Optional[dict]]:
    """Check if ⟨a⟩(P ∩ Q) = ⟨a⟩P ∩ ⟨a⟩Q for all a, P, Q.

    Returns (True, None) if distributive, or (False, witness) with
    the first violating (a, P, Q, gap_states).
    """
    states_list = sorted(lts.states)
    n = len(states_list)
    for a in sorted(lts.actions):
        # Enumerate all subsets
        for mask_p in range(1 << n):
            P = {states_list[i] for i in range(n) if mask_p & (1 << i)}
            for mask_q in range(1 << n):
                Q = {states_list[i] for i in range(n) if mask_q & (1 << i)}
                lhs = diamond(lts, a, P & Q)
                rhs = diamond(lts, a, P) & diamond(lts, a, Q)
                if lhs != rhs:
                    gap = rhs - lhs
                    return False, {"action": a, "P": P, "Q": Q,
                                   "gap": gap, "lhs": lhs, "rhs": rhs}
    return True, None


def find_nonboolean_witness(lts: LTS) -> Optional[dict]:
    """Find explicit non-Boolean witness from branching fork.

    Uses the canonical construction: if s has two distinct a-successors
    t₁ ≠ t₂, then P={t₁}, Q={t₂} gives the witness.
    """
    for s in sorted(lts.states):
        for a in sorted(lts.actions):
            succs = sorted(lts.successors(s, a))
            if len(succs) >= 2:
                t1, t2 = succs[0], succs[1]
                return {
                    "state": s, "action": a,
                    "t1": t1, "t2": t2,
                    "P": {t1}, "Q": {t2},
                    "diamond_P": diamond(lts, a, {t1}),
                    "diamond_Q": diamond(lts, a, {t2}),
                    "diamond_PQ": diamond(lts, a, {t1} & {t2}),
                    "explanation": (
                        f"State {s} has two {a}-successors: {t1} and {t2}.\n"
                        f"  ⟨{a}⟩{{{t1}}} contains {s} ✓\n"
                        f"  ⟨{a}⟩{{{t2}}} contains {s} ✓\n"
                        f"  ⟨{a}⟩({{{t1}}} ∩ {{{t2}}}) = ⟨{a}⟩∅ = ∅, "
                        f"so {s} ∉ ⟨{a}⟩(P ∩ Q) ✗\n"
                        f"  → Diamond fails to distribute: "
                        f"non-Boolean witness found!"
                    )
                }
    return None


# ─── Complement Duality Check ────────────────────────────────────────

def check_complement_duality(lts: LTS) -> Tuple[bool, Optional[dict]]:
    """Check if ⟨a⟩(Pᶜ) = (⟨a⟩P)ᶜ for all a, P.

    This holds iff L is deterministic AND total.
    """
    states_list = sorted(lts.states)
    n = len(states_list)
    for a in sorted(lts.actions):
        for mask_p in range(1 << n):
            P = {states_list[i] for i in range(n) if mask_p & (1 << i)}
            P_compl = lts.states - P
            lhs = diamond(lts, a, P_compl)
            rhs = lts.states - diamond(lts, a, P)
            if lhs != rhs:
                return False, {"action": a, "P": P,
                               "lhs": lhs, "rhs": rhs, "gap": rhs - lhs}
    return True, None


# ─── Example LTS ─────────────────────────────────────────────────────

def example_deterministic() -> LTS:
    """A deterministic total LTS: a simple 3-state cycle."""
    return LTS(
        states=[0, 1, 2],
        actions=["a", "b"],
        transitions=[
            (0, "a", 1), (1, "a", 2), (2, "a", 0),
            (0, "b", 2), (1, "b", 0), (2, "b", 1),
        ],
        name="Deterministic 3-Cycle"
    )


def example_nondeterministic() -> LTS:
    """A nondeterministic LTS: state 0 has two a-successors."""
    return LTS(
        states=[0, 1, 2],
        actions=["a"],
        transitions=[
            (0, "a", 1), (0, "a", 2),  # Branching!
            (1, "a", 1),
            (2, "a", 2),
        ],
        name="Nondeterministic Branch"
    )


def example_coin_flip() -> LTS:
    """Models a coin flip: state 0 branches to heads (1) or tails (2)."""
    return LTS(
        states=[0, 1, 2],
        actions=["flip", "stay"],
        transitions=[
            (0, "flip", 1), (0, "flip", 2),   # Nondeterministic!
            (1, "stay", 1), (2, "stay", 2),
            (0, "stay", 0),
        ],
        name="Coin Flip"
    )


def example_mutex() -> LTS:
    """A deterministic mutual exclusion protocol (simplified)."""
    # States: 0=idle, 1=requesting, 2=critical, 3=releasing
    return LTS(
        states=[0, 1, 2, 3],
        actions=["req", "grant", "release", "idle"],
        transitions=[
            (0, "req", 1),
            (1, "grant", 2),
            (2, "release", 3),
            (3, "idle", 0),
        ],
        name="Deterministic Mutex"
    )


# ─── Subobject Display ───────────────────────────────────────────────

def display_subobject_structure(lts: LTS, max_display: int = 16):
    """Display the lattice of state subsets and their diamond images."""
    states_list = sorted(lts.states)
    n = len(states_list)
    if n > 4:
        print("  (Too many states for exhaustive display)")
        return

    print(f"\n  Subobject lattice (2^{n} = {1 << n} elements):")
    for a in sorted(lts.actions):
        print(f"\n  Action '{a}' — Diamond images:")
        count = 0
        for mask in range(1 << n):
            if count >= max_display:
                print(f"    ... ({(1 << n) - count} more)")
                break
            P = frozenset(states_list[i] for i in range(n) if mask & (1 << i))
            d = diamond(lts, a, set(P))
            P_str = str(set(P)) if P else '∅'
            d_str = str(d) if d else '∅'
            print(f"    ⟨{a}⟩{P_str:>15} = {d_str}")
            count += 1


# ─── Main Demo ────────────────────────────────────────────────────────

def analyze_lts(lts: LTS):
    """Full analysis of an LTS."""
    print(f"\n{'='*60}")
    print(f" LTS: {lts.name}")
    print(f"{'='*60}")
    print(f"  States:  {sorted(lts.states)}")
    print(f"  Actions: {sorted(lts.actions)}")
    print(f"  Transitions:")
    for s, a, t in sorted(lts.transitions):
        print(f"    {s} —[{a}]→ {t}")

    det = lts.is_fully_deterministic()
    total = lts.is_total()
    print(f"\n  Fully deterministic: {'YES ✓' if det else 'NO ✗'}")
    print(f"  Total:               {'YES ✓' if total else 'NO ✗'}")

    # Check diamond distributivity
    dist_ok, dist_witness = check_diamond_distributive(lts)
    print(f"\n  Diamond distributive: {'YES ✓' if dist_ok else 'NO ✗'}")
    print(f"  Determinism = Distributivity: "
          f"{'CONFIRMED ✓' if det == dist_ok else 'MISMATCH ✗'}")

    if not det:
        witness = find_nonboolean_witness(lts)
        if witness:
            print(f"\n  Non-Boolean Witness:")
            print(f"  {witness['explanation']}")

    if det and total:
        compl_ok, _ = check_complement_duality(lts)
        print(f"\n  Diamond-complement duality: "
              f"{'YES ✓ (full Boolean homomorphism)' if compl_ok else 'NO ✗'}")

    # Display subobject structure for small LTS
    if len(lts.states) <= 4:
        display_subobject_structure(lts)


def exhaustive_verification(max_states: int = 3, num_actions: int = 1):
    """Exhaustively verify Theorem A for all LTS up to given size."""
    print(f"\n{'='*60}")
    print(f" Exhaustive Verification: ≤{max_states} states, "
          f"{num_actions} action(s)")
    print(f"{'='*60}")

    actions = [f"a{i}" for i in range(num_actions)]
    total = 0
    det_count = 0
    agree_count = 0

    for n_states in range(1, max_states + 1):
        states = list(range(n_states))
        # Each (state, action) pair can map to any subset of states
        # For each (s, a), the successors form a subset of states
        # We enumerate by choosing successors for each (s, a) pair
        pairs = [(s, a) for s in states for a in actions]
        n_pairs = len(pairs)

        # Each pair maps to a subset of states (including empty)
        for choice in cartesian_product(range(1 << n_states),
                                         repeat=n_pairs):
            transitions = []
            for idx, (s, a) in enumerate(pairs):
                mask = choice[idx]
                for i in range(n_states):
                    if mask & (1 << i):
                        transitions.append((s, a, states[i]))

            lts = LTS(states, actions, transitions)
            det = lts.is_fully_deterministic()
            dist_ok, _ = check_diamond_distributive(lts)

            total += 1
            if det:
                det_count += 1
            if det == dist_ok:
                agree_count += 1
            else:
                print(f"  MISMATCH at states={n_states}! "
                      f"det={det}, dist={dist_ok}")

    print(f"\n  Total LTS enumerated: {total}")
    print(f"  Deterministic:        {det_count}")
    print(f"  Nondeterministic:     {total - det_count}")
    print(f"  Theorem A agreement:  {agree_count}/{total} "
          f"({'100%' if agree_count == total else 'FAILURES FOUND'})")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Boolean Topos Characterization of Determinism — Demo   ║")
    print("║  Determinism ↔ Diamond Distributes over Conjunction     ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Analyze example systems
    for lts in [example_deterministic(), example_nondeterministic(),
                example_coin_flip(), example_mutex()]:
        analyze_lts(lts)

    # Exhaustive verification of Theorem A
    exhaustive_verification(max_states=3, num_actions=1)
    exhaustive_verification(max_states=2, num_actions=2)

    print("\n" + "="*60)
    print(" All demonstrations complete.")
    print("="*60)
