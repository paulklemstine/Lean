#!/usr/bin/env python3
"""
Applications of the Yoneda-Bisimulation Correspondence.

Demonstrates real-world applications:
1. Protocol verification: checking equivalence of communication protocols
2. Circuit optimization: verifying behavioral equivalence of circuit designs
3. Software refactoring: proving equivalence of program state machines
4. Concurrency verification: checking process algebra equivalences
"""

from __future__ import annotations
from dataclasses import dataclass, field
from collections import defaultdict
from typing import Optional


# ============================================================
# Core LTS and Bisimulation (self-contained)
# ============================================================

@dataclass
class LTS:
    """Labeled Transition System."""
    name: str
    states: set[str]
    actions: set[str]
    transitions: dict[tuple[str, str], set[str]] = field(default_factory=dict)

    def successors(self, state: str, action: str) -> set[str]:
        return self.transitions.get((state, action), set())

    def add_transition(self, src: str, action: str, tgt: str):
        self.states.add(src)
        self.states.add(tgt)
        self.actions.add(action)
        self.transitions.setdefault((src, action), set()).add(tgt)


def partition_refinement(lts: LTS) -> list[set[str]]:
    """Compute bisimulation equivalence classes."""
    partition = [set(lts.states)]

    def block_of(state: str) -> int:
        for i, block in enumerate(partition):
            if state in block:
                return i
        return -1

    while True:
        new_partition: list[set[str]] = []
        for block in partition:
            sigs: dict[tuple, set[str]] = {}
            for state in block:
                sig = tuple(
                    frozenset(block_of(s) for s in lts.successors(state, a))
                    for a in sorted(lts.actions)
                )
                sigs.setdefault(sig, set()).add(state)
            new_partition.extend(sigs.values())

        if len(new_partition) == len(partition):
            break
        partition = new_partition
    return partition


def check_bisimilar_cross(lts1: LTS, s1: str, lts2: LTS, s2: str) -> bool:
    """Check bisimilarity across two LTS."""
    combined = LTS(f"{lts1.name}+{lts2.name}", set(), set())
    for (s, a), targets in lts1.transitions.items():
        for t in targets:
            combined.add_transition(f"L.{s}", a, f"L.{t}")
    for (s, a), targets in lts2.transitions.items():
        for t in targets:
            combined.add_transition(f"R.{s}", a, f"R.{t}")
    # Add isolated states
    for s in lts1.states:
        combined.states.add(f"L.{s}")
    for s in lts2.states:
        combined.states.add(f"R.{s}")
    combined.actions = lts1.actions | lts2.actions

    classes = partition_refinement(combined)
    return any(f"L.{s1}" in cls and f"R.{s2}" in cls for cls in classes)


# ============================================================
# Application 1: Communication Protocol Verification
# ============================================================

def app_protocol_verification():
    """Verify equivalence of two implementations of a simple handshake protocol.

    Protocol specification:
    - Client sends SYN, server responds with SYN-ACK, client sends ACK
    - After handshake, data can be exchanged
    - Either side can initiate FIN to close

    We compare a simple 3-way handshake with an optimized version.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 1: Communication Protocol Verification")
    print("=" * 70)

    # Standard 3-way handshake
    std = LTS("Standard", set(), set())
    std.add_transition("closed", "syn", "syn_sent")
    std.add_transition("syn_sent", "syn_ack", "established")
    std.add_transition("established", "data", "established")
    std.add_transition("established", "fin", "closing")
    std.add_transition("closing", "ack", "closed")

    # Optimized: SYN+data piggybacking (TCP Fast Open style)
    opt = LTS("Optimized", set(), set())
    opt.add_transition("idle", "syn", "connecting")
    opt.add_transition("connecting", "syn_ack", "ready")
    opt.add_transition("ready", "data", "ready")
    opt.add_transition("ready", "fin", "teardown")
    opt.add_transition("teardown", "ack", "idle")

    print("Standard protocol:")
    for (s, a), targets in sorted(std.transitions.items()):
        for t in sorted(targets):
            print(f"  {s} --[{a}]--> {t}")

    print("\nOptimized protocol:")
    for (s, a), targets in sorted(opt.transitions.items()):
        for t in sorted(targets):
            print(f"  {s} --[{a}]--> {t}")

    # Check bisimilarity
    bisim = check_bisimilar_cross(std, "closed", opt, "idle")
    print(f"\nProtocols bisimilar? {bisim}")
    print("→ The protocols are behaviorally equivalent: any sequence of")
    print("  observable actions produces identical behavior.")

    # Show the bisimulation relation
    combined = LTS("combined", set(), set())
    for (s, a), targets in std.transitions.items():
        for t in targets:
            combined.add_transition(f"L.{s}", a, f"L.{t}")
    for (s, a), targets in opt.transitions.items():
        for t in targets:
            combined.add_transition(f"R.{s}", a, f"R.{t}")
    for s in std.states:
        combined.states.add(f"L.{s}")
    for s in opt.states:
        combined.states.add(f"R.{s}")
    combined.actions = std.actions | opt.actions

    classes = partition_refinement(combined)
    print("\nBisimulation equivalence classes (state correspondence):")
    for cls in classes:
        l_states = [s[2:] for s in sorted(cls) if s.startswith("L.")]
        r_states = [s[2:] for s in sorted(cls) if s.startswith("R.")]
        if l_states and r_states:
            print(f"  {l_states} ↔ {r_states}")


# ============================================================
# Application 2: Circuit Design Verification
# ============================================================

def app_circuit_verification():
    """Verify behavioral equivalence of two circuit designs.

    We model a simple toggle flip-flop:
    - Input: clock signal (clk), reset
    - Output: changes state on each clock edge

    Compare two implementations: D flip-flop vs JK flip-flop.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Circuit Design Verification")
    print("=" * 70)

    # D flip-flop model
    d_ff = LTS("D-FlipFlop", set(), set())
    d_ff.add_transition("Q0", "clk_rise", "Q1")
    d_ff.add_transition("Q1", "clk_rise", "Q0")
    d_ff.add_transition("Q0", "reset", "Q0")
    d_ff.add_transition("Q1", "reset", "Q0")

    # JK flip-flop model (with J=K=1, acts as toggle)
    jk_ff = LTS("JK-FlipFlop", set(), set())
    jk_ff.add_transition("low", "clk_rise", "high")
    jk_ff.add_transition("high", "clk_rise", "low")
    jk_ff.add_transition("low", "reset", "low")
    jk_ff.add_transition("high", "reset", "low")

    print("D Flip-Flop (toggle mode):")
    for (s, a), targets in sorted(d_ff.transitions.items()):
        for t in sorted(targets):
            print(f"  {s} --[{a}]--> {t}")

    print("\nJK Flip-Flop (J=K=1):")
    for (s, a), targets in sorted(jk_ff.transitions.items()):
        for t in sorted(targets):
            print(f"  {s} --[{a}]--> {t}")

    bisim = check_bisimilar_cross(d_ff, "Q0", jk_ff, "low")
    print(f"\nCircuits bisimilar? {bisim}")
    print("→ The D flip-flop in toggle mode is behaviorally identical")
    print("  to the JK flip-flop with J=K=1. Safe to substitute.")


# ============================================================
# Application 3: Software State Machine Equivalence
# ============================================================

def app_software_refactoring():
    """Verify equivalence of two state machine implementations.

    Scenario: A traffic light controller is being refactored.
    The original has explicit intermediate states; the refactored
    version combines some states.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Software Refactoring Verification")
    print("=" * 70)

    # Original traffic light controller (with pedestrian button)
    original = LTS("Original", set(), set())
    original.add_transition("red", "timer", "green")
    original.add_transition("green", "timer", "yellow")
    original.add_transition("yellow", "timer", "red")
    original.add_transition("green", "pedestrian", "yellow")  # Can interrupt green
    original.add_transition("red", "emergency", "red")
    original.add_transition("green", "emergency", "red")
    original.add_transition("yellow", "emergency", "red")

    # Refactored: removed pedestrian interrupt (bug!)
    refactored = LTS("Refactored", set(), set())
    refactored.add_transition("R", "timer", "G")
    refactored.add_transition("G", "timer", "Y")
    refactored.add_transition("Y", "timer", "R")
    refactored.add_transition("R", "emergency", "R")
    refactored.add_transition("G", "emergency", "R")
    refactored.add_transition("Y", "emergency", "R")

    print("Original controller:")
    for (s, a), targets in sorted(original.transitions.items()):
        for t in sorted(targets):
            print(f"  {s} --[{a}]--> {t}")

    print("\nRefactored controller:")
    for (s, a), targets in sorted(refactored.transitions.items()):
        for t in sorted(targets):
            print(f"  {s} --[{a}]--> {t}")

    bisim = check_bisimilar_cross(original, "red", refactored, "R")
    print(f"\nControllers bisimilar? {bisim}")
    if bisim:
        print("→ Controllers are behaviorally equivalent.")
    else:
        print("→ WARNING: The refactored controller is NOT equivalent!")
        print("  The original has a 'pedestrian' interrupt from green → yellow.")
        print("  The refactored version removed this transition.")
        print("  Distinguishing trace: [timer, pedestrian]")
        print("  Original: red → green → yellow (pedestrian can interrupt green)")
        print("  Refactored: R → G (no pedestrian transition — stuck!)")
        print("  This is a real behavioral difference — the refactoring is INCORRECT.")


# ============================================================
# Application 4: Process Algebra CCS Equivalence
# ============================================================

def app_process_algebra():
    """Verify CCS process algebra equivalences.

    Compare two CCS processes:
    P = a.(b.P + c.P)   (choose between b and c after each a)
    Q = a.b.Q + a.c.Q    (choose before doing a)
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Process Algebra Equivalence (CCS)")
    print("=" * 70)

    # P = a.(b.P + c.P)
    proc_p = LTS("P", set(), set())
    proc_p.add_transition("p0", "a", "p1")
    proc_p.add_transition("p1", "b", "p0")
    proc_p.add_transition("p1", "c", "p0")

    # Q = a.b.Q + a.c.Q
    proc_q = LTS("Q", set(), set())
    proc_q.add_transition("q0", "a", "q1")  # going to do b
    proc_q.add_transition("q0", "a", "q2")  # going to do c
    proc_q.add_transition("q1", "b", "q0")
    proc_q.add_transition("q2", "c", "q0")

    print("Process P = a.(b.P + c.P):")
    for (s, a), targets in sorted(proc_p.transitions.items()):
        for t in sorted(targets):
            print(f"  {s} --[{a}]--> {t}")

    print("\nProcess Q = a.b.Q + a.c.Q:")
    for (s, a), targets in sorted(proc_q.transitions.items()):
        for t in sorted(targets):
            print(f"  {s} --[{a}]--> {t}")

    bisim = check_bisimilar_cross(proc_p, "p0", proc_q, "q0")
    print(f"\nP ~ Q (bisimilar)? {bisim}")

    if not bisim:
        print("→ These processes are NOT bisimilar!")
        print("  P: after doing 'a', reaches state p1 where BOTH b and c are available.")
        print("  Q: after doing 'a', reaches EITHER q1 (only b) OR q2 (only c).")
        print("  The distinguishing experiment: do 'a', then try both 'b' and 'c'.")
        print("  In P, both succeed. In Q, only one will succeed (depending on choice).")
        print("  This is the classic example showing bisimulation ≠ trace equivalence.")

    # But they ARE trace equivalent!
    print("\nTrace equivalence check:")
    def traces_up_to(lts, state, depth):
        if depth == 0:
            return {()}
        result = {()}
        for action in lts.actions:
            for succ in lts.successors(state, action):
                for sub in traces_up_to(lts, succ, depth - 1):
                    result.add((action,) + sub)
        return result

    for d in range(1, 7):
        tp = traces_up_to(proc_p, "p0", d)
        tq = traces_up_to(proc_q, "q0", d)
        print(f"  Depth {d}: trace equivalent? {tp == tq}")


# ============================================================
# Application 5: Deadlock Detection
# ============================================================

def app_deadlock_detection():
    """Detect deadlock states using the nerve presheaf.

    A state is a deadlock if it has no outgoing transitions.
    In terms of the nerve presheaf, deadlock states appear only
    at the empty trace level — they contribute to N(ε) but not
    to any N(a::σ).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Deadlock Detection via Nerve Analysis")
    print("=" * 70)

    # Dining philosophers (simplified, 2 philosophers)
    dp = LTS("DiningPhilosophers", set(), set())
    dp.add_transition("thinking", "pick_left", "has_left")
    dp.add_transition("has_left", "pick_right", "eating")
    dp.add_transition("eating", "put_down", "thinking")
    dp.add_transition("has_left", "timeout", "thinking")
    # Deadlock state: both philosophers holding left fork
    dp.add_transition("thinking", "pick_left", "deadlock")
    # deadlock has no outgoing transitions!
    dp.states.add("deadlock")

    print("Dining Philosophers (simplified):")
    for (s, a), targets in sorted(dp.transitions.items()):
        for t in sorted(targets):
            print(f"  {s} --[{a}]--> {t}")
    print(f"  deadlock has no outgoing transitions")

    # Find deadlock states via nerve analysis
    deadlocks = []
    for state in sorted(dp.states):
        has_outgoing = any(dp.successors(state, a) for a in dp.actions)
        if not has_outgoing:
            deadlocks.append(state)

    print(f"\nDeadlock states: {deadlocks}")
    print("→ In the nerve presheaf, deadlock states appear at N(ε)")
    print("  but NOT at any N(a::σ) for any action a.")
    print("  This is the 'sheafification test': the nerve of a")
    print("  deadlock-free process has non-empty fibers at all levels.")

    # Verify: deadlock states are not bisimilar to any non-deadlock state
    for dl in deadlocks:
        for nd in sorted(dp.states - set(deadlocks)):
            bisim = False
            classes = partition_refinement(dp)
            for cls in classes:
                if dl in cls and nd in cls:
                    bisim = True
            print(f"  {dl} ~ {nd}? {bisim}")


# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   Yoneda-Bisimulation Correspondence — Applications            ║")
    print("║   Real-World Uses of Categorical Process Equivalence           ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    app_protocol_verification()
    app_circuit_verification()
    app_software_refactoring()
    app_process_algebra()
    app_deadlock_detection()

    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Yoneda-Bisimulation Correspondence — Interactive Demo

Demonstrates the key theorems with concrete labeled transition systems:
1. Bisimulation checking via partition refinement
2. Nerve presheaf construction and comparison
3. Naturality squares showing the zigzag condition
4. Distinguishing Hennessy-Milner formulas for non-bisimilar systems
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class LTS:
    """Labeled Transition System.

    states: set of state labels
    actions: set of action labels
    transitions: dict mapping (state, action) -> set of successor states
    """
    name: str
    states: set[str]
    actions: set[str]
    transitions: dict[tuple[str, str], set[str]] = field(default_factory=dict)

    def successors(self, state: str, action: str) -> set[str]:
        return self.transitions.get((state, action), set())

    def can_do(self, state: str, action: str) -> bool:
        return len(self.successors(state, action)) > 0

    def is_deterministic(self) -> bool:
        return all(len(v) <= 1 for v in self.transitions.values())

    def accepts_trace(self, state: str, trace: list[str]) -> bool:
        """Check if state can perform the given trace."""
        if not trace:
            return True
        action, *rest = trace
        return any(self.accepts_trace(s, rest) for s in self.successors(state, action))

    def all_traces_up_to(self, state: str, max_depth: int) -> set[tuple[str, ...]]:
        """Return all traces accepted by state, up to given depth."""
        result: set[tuple[str, ...]] = {()}
        if max_depth == 0:
            return result
        for action in self.actions:
            for succ in self.successors(state, action):
                for trace in self.all_traces_up_to(succ, max_depth - 1):
                    result.add((action,) + trace)
        return result

    def display(self) -> str:
        lines = [f"LTS '{self.name}':"]
        lines.append(f"  States: {sorted(self.states)}")
        lines.append(f"  Actions: {sorted(self.actions)}")
        lines.append("  Transitions:")
        for (s, a), targets in sorted(self.transitions.items()):
            for t in sorted(targets):
                lines.append(f"    {s} --[{a}]--> {t}")
        return "\n".join(lines)


# ============================================================
# Bisimulation Checker (Partition Refinement)
# ============================================================

def compute_bisimulation_classes(lts: LTS) -> list[set[str]]:
    """Compute bisimulation equivalence classes via partition refinement."""
    partition = [set(lts.states)]

    def block_of(state: str) -> int:
        for i, block in enumerate(partition):
            if state in block:
                return i
        return -1

    changed = True
    while changed:
        changed = False
        new_partition: list[set[str]] = []
        for block in partition:
            # Split block based on transition signatures
            signatures: dict[tuple, set[str]] = {}
            for state in block:
                sig = tuple(
                    frozenset(block_of(s) for s in lts.successors(state, a))
                    for a in sorted(lts.actions)
                )
                signatures.setdefault(sig, set()).add(state)
            sub_blocks = list(signatures.values())
            if len(sub_blocks) > 1:
                changed = True
            new_partition.extend(sub_blocks)
        partition = new_partition

    return partition


def are_bisimilar(lts: LTS, s1: str, s2: str) -> bool:
    """Check if two states in the same LTS are bisimilar."""
    classes = compute_bisimulation_classes(lts)
    for cls in classes:
        if s1 in cls and s2 in cls:
            return True
    return False


def are_bisimilar_cross(lts1: LTS, s1: str, lts2: LTS, s2: str) -> tuple[bool, Optional[list[str]]]:
    """Check bisimilarity across two LTS by forming their disjoint union.
    Returns (is_bisimilar, distinguishing_trace_if_not).
    """
    combined = LTS(
        name=f"{lts1.name}+{lts2.name}",
        states={f"L.{s}" for s in lts1.states} | {f"R.{s}" for s in lts2.states},
        actions=lts1.actions | lts2.actions,
    )
    for (s, a), targets in lts1.transitions.items():
        combined.transitions[(f"L.{s}", a)] = {f"L.{t}" for t in targets}
    for (s, a), targets in lts2.transitions.items():
        combined.transitions[(f"R.{s}", a)] = {f"R.{t}" for t in targets}

    classes = compute_bisimulation_classes(combined)
    bisimilar = any(f"L.{s1}" in cls and f"R.{s2}" in cls for cls in classes)

    distinguishing_trace = None
    if not bisimilar:
        distinguishing_trace = find_distinguishing_trace(
            combined, f"L.{s1}", f"R.{s2}", max_depth=10
        )

    return bisimilar, distinguishing_trace


def find_distinguishing_trace(lts: LTS, s1: str, s2: str, max_depth: int = 10) -> Optional[list[str]]:
    """Find a trace accepted by s1 but not s2 (or vice versa)."""
    for depth in range(max_depth + 1):
        traces1 = lts.all_traces_up_to(s1, depth)
        traces2 = lts.all_traces_up_to(s2, depth)
        diff = traces1.symmetric_difference(traces2)
        if diff:
            trace = min(diff, key=len)
            return list(trace)
    return None


# ============================================================
# Nerve Presheaf Construction
# ============================================================

def nerve_presheaf(lts: LTS, state: str, max_depth: int = 5) -> dict[tuple[str, ...], set[str]]:
    """Construct the nerve presheaf of an LTS at a given state.

    Returns a dict mapping traces to the set of states reachable via that trace.
    N(P)(σ) = {s' : s can reach s' via trace σ}
    """
    nerve: dict[tuple[str, ...], set[str]] = {}

    def build(current: str, trace: tuple[str, ...], depth: int):
        nerve.setdefault(trace, set()).add(current)
        if depth >= max_depth:
            return
        for action in sorted(lts.actions):
            for succ in lts.successors(current, action):
                build(succ, trace + (action,), depth + 1)

    build(state, (), 0)
    return nerve


def display_nerve(nerve: dict[tuple[str, ...], set[str]], name: str, max_show: int = 15) -> str:
    """Pretty-print a nerve presheaf."""
    lines = [f"Nerve presheaf for {name}:"]
    items = sorted(nerve.items(), key=lambda x: (len(x[0]), x[0]))
    for trace, states in items[:max_show]:
        trace_str = "ε" if not trace else ".".join(trace)
        lines.append(f"  N({trace_str}) = {sorted(states)}")
    if len(items) > max_show:
        lines.append(f"  ... ({len(items) - max_show} more entries)")
    return "\n".join(lines)


# ============================================================
# Naturality Squares (Zigzag Visualization)
# ============================================================

def show_naturality_squares(lts1: LTS, s1: str, lts2: LTS, s2: str,
                            relation: dict[str, str]) -> str:
    """Visualize the naturality squares that encode the zigzag condition.

    relation maps states of lts1 to states of lts2.
    """
    lines = ["Naturality Squares (Zigzag Condition):"]
    lines.append("=" * 60)

    for action in sorted(lts1.actions):
        for succ1 in sorted(lts1.successors(s1, action)):
            if s1 in relation and succ1 in relation:
                t = relation[s1]
                t_prime = relation[succ1]
                # Check if t ->action-> t_prime in lts2
                valid = t_prime in lts2.successors(t, action)
                status = "✓ COMMUTES" if valid else "✗ FAILS"

                lines.append(f"\n  Action: {action}")
                lines.append(f"    {s1} --[{action}]--> {succ1}     (in {lts1.name})")
                lines.append(f"    |                    |")
                lines.append(f"    η                    η")
                lines.append(f"    |                    |")
                lines.append(f"    v                    v")
                lines.append(f"    {t} --[{action}]--> {t_prime}     (in {lts2.name})")
                lines.append(f"    {status}")

    return "\n".join(lines)


# ============================================================
# Hennessy-Milner Logic
# ============================================================

@dataclass
class HMFormula:
    """Hennessy-Milner Logic formula."""
    pass

@dataclass
class HMTrue(HMFormula):
    def __str__(self): return "⊤"

@dataclass
class HMConj(HMFormula):
    left: HMFormula
    right: HMFormula
    def __str__(self): return f"({self.left} ∧ {self.right})"

@dataclass
class HMNeg(HMFormula):
    sub: HMFormula
    def __str__(self): return f"¬{self.sub}"

@dataclass
class HMDiamond(HMFormula):
    action: str
    sub: HMFormula
    def __str__(self): return f"⟨{self.action}⟩{self.sub}"

@dataclass
class HMBox(HMFormula):
    action: str
    sub: HMFormula
    def __str__(self): return f"[{self.action}]{self.sub}"


def hm_satisfies(lts: LTS, state: str, formula: HMFormula) -> bool:
    """Check if a state satisfies an HM formula."""
    if isinstance(formula, HMTrue):
        return True
    elif isinstance(formula, HMConj):
        return hm_satisfies(lts, state, formula.left) and hm_satisfies(lts, state, formula.right)
    elif isinstance(formula, HMNeg):
        return not hm_satisfies(lts, state, formula.sub)
    elif isinstance(formula, HMDiamond):
        return any(hm_satisfies(lts, s, formula.sub) for s in lts.successors(state, formula.action))
    elif isinstance(formula, HMBox):
        return all(hm_satisfies(lts, s, formula.sub) for s in lts.successors(state, formula.action))
    return False


def find_distinguishing_formula(lts1: LTS, s1: str, lts2: LTS, s2: str,
                                 max_depth: int = 5) -> Optional[HMFormula]:
    """Find an HM formula that distinguishes s1 (in lts1) from s2 (in lts2)."""
    combined = LTS(
        name="combined",
        states={f"L.{s}" for s in lts1.states} | {f"R.{s}" for s in lts2.states},
        actions=lts1.actions | lts2.actions,
    )
    for (s, a), targets in lts1.transitions.items():
        combined.transitions[(f"L.{s}", a)] = {f"L.{t}" for t in targets}
    for (s, a), targets in lts2.transitions.items():
        combined.transitions[(f"R.{s}", a)] = {f"R.{t}" for t in targets}

    return _find_dist_formula(combined, f"L.{s1}", f"R.{s2}", max_depth)


def _find_dist_formula(lts: LTS, s1: str, s2: str, depth: int) -> Optional[HMFormula]:
    """Internal: find distinguishing formula in combined LTS."""
    if depth <= 0:
        return None

    for action in sorted(lts.actions):
        succs1 = sorted(lts.successors(s1, action))
        succs2 = sorted(lts.successors(s2, action))

        # Check if s1 has an a-successor that no s2-successor matches
        for succ1 in succs1:
            matched = False
            for succ2 in succs2:
                sub = _find_dist_formula(lts, succ1, succ2, depth - 1)
                if sub is None:
                    matched = True
                    break
            if not matched and succs2:
                # Find a formula satisfied by succ1 but not by any succ2
                for succ2 in succs2:
                    sub = _find_dist_formula(lts, succ1, succ2, depth - 1)
                    if sub is not None:
                        return HMDiamond(action, sub)
            if not matched and not succs2:
                return HMDiamond(action, HMTrue())

        # Check if s2 has an a-successor that no s1-successor matches
        for succ2 in succs2:
            matched = False
            for succ1 in succs1:
                sub = _find_dist_formula(lts, succ1, succ2, depth - 1)
                if sub is None:
                    matched = True
                    break
            if not matched and not succs1:
                return HMNeg(HMDiamond(action, HMTrue()))

    return None


# ============================================================
# Demo Examples
# ============================================================

def example_bisimilar_buffers():
    """Two bisimilar one-place buffers."""
    print("\n" + "=" * 70)
    print("EXAMPLE 1: Bisimilar One-Place Buffers")
    print("=" * 70)

    buf1 = LTS("Buffer1", {"empty", "full"}, {"put", "get"})
    buf1.transitions[("empty", "put")] = {"full"}
    buf1.transitions[("full", "get")] = {"empty"}

    buf2 = LTS("Buffer2", {"e", "f"}, {"put", "get"})
    buf2.transitions[("e", "put")] = {"f"}
    buf2.transitions[("f", "get")] = {"e"}

    print(buf1.display())
    print()
    print(buf2.display())

    # Check bisimilarity
    bisim, dist_trace = are_bisimilar_cross(buf1, "empty", buf2, "e")
    print(f"\nBisimilar(empty, e)? {bisim}")

    # Show nerve presheaves
    nerve1 = nerve_presheaf(buf1, "empty", max_depth=4)
    nerve2 = nerve_presheaf(buf2, "e", max_depth=4)
    print()
    print(display_nerve(nerve1, "Buffer1 @ empty"))
    print()
    print(display_nerve(nerve2, "Buffer2 @ e"))

    # Show naturality squares
    relation = {"empty": "e", "full": "f"}
    print()
    print(show_naturality_squares(buf1, "empty", buf2, "e", relation))

    # Traces
    print("\nTrace equivalence check (depth ≤ 4):")
    traces1 = buf1.all_traces_up_to("empty", 4)
    traces2 = buf2.all_traces_up_to("e", 4)
    print(f"  Traces from 'empty': {sorted(traces1, key=lambda t: (len(t), t))[:10]}...")
    print(f"  Traces from 'e':     {sorted(traces2, key=lambda t: (len(t), t))[:10]}...")
    print(f"  Trace equivalent? {traces1 == traces2}")


def example_non_bisimilar_machines():
    """Two coffee machines that are NOT bisimilar."""
    print("\n" + "=" * 70)
    print("EXAMPLE 2: Non-Bisimilar Coffee Machines")
    print("=" * 70)

    # Machine A: simple coffee machine
    machA = LTS("MachineA", {"idle", "ready"}, {"coin", "coffee", "tea"})
    machA.transitions[("idle", "coin")] = {"ready"}
    machA.transitions[("ready", "coffee")] = {"idle"}
    machA.transitions[("ready", "tea")] = {"idle"}

    # Machine B: coffee machine with non-deterministic choice
    machB = LTS("MachineB", {"idle", "coffee_only", "tea_only"}, {"coin", "coffee", "tea"})
    machB.transitions[("idle", "coin")] = {"coffee_only", "tea_only"}
    machB.transitions[("coffee_only", "coffee")] = {"idle"}
    machB.transitions[("tea_only", "tea")] = {"idle"}

    print(machA.display())
    print()
    print(machB.display())

    # Check bisimilarity
    bisim, dist_trace = are_bisimilar_cross(machA, "idle", machB, "idle")
    print(f"\nBisimilar(idle, idle)? {bisim}")
    if dist_trace:
        print(f"Distinguishing trace: {dist_trace}")

    # Show nerve presheaves
    nerve1 = nerve_presheaf(machA, "idle", max_depth=3)
    nerve2 = nerve_presheaf(machB, "idle", max_depth=3)
    print()
    print(display_nerve(nerve1, "MachineA @ idle"))
    print()
    print(display_nerve(nerve2, "MachineB @ idle"))

    # Note the difference: MachineA @ ready can do both coffee and tea,
    # but MachineB has two different successor states, each doing only one

    # Find distinguishing formula
    formula = find_distinguishing_formula(machA, "idle", machB, "idle", max_depth=4)
    if formula:
        print(f"\nDistinguishing HM formula: {formula}")
        print(f"  MachineA idle ⊨ φ? {hm_satisfies(machA, 'idle', formula)}")
        print(f"  MachineB idle ⊨ φ? {hm_satisfies(machB, 'idle', formula)}")


def example_deterministic_correspondence():
    """Deterministic LTS: trace equivalence = bisimilarity."""
    print("\n" + "=" * 70)
    print("EXAMPLE 3: Deterministic Correspondence (Yoneda-Bisimulation)")
    print("=" * 70)

    # Two deterministic LTS that are trace-equivalent (hence bisimilar)
    lts1 = LTS("DetLTS1", {"s0", "s1", "s2"}, {"a", "b"})
    lts1.transitions[("s0", "a")] = {"s1"}
    lts1.transitions[("s1", "b")] = {"s2"}
    lts1.transitions[("s2", "a")] = {"s1"}

    lts2 = LTS("DetLTS2", {"t0", "t1", "t2"}, {"a", "b"})
    lts2.transitions[("t0", "a")] = {"t1"}
    lts2.transitions[("t1", "b")] = {"t2"}
    lts2.transitions[("t2", "a")] = {"t1"}

    print(lts1.display())
    print(f"  Deterministic? {lts1.is_deterministic()}")
    print()
    print(lts2.display())
    print(f"  Deterministic? {lts2.is_deterministic()}")

    # Check trace equivalence
    max_d = 6
    traces1 = lts1.all_traces_up_to("s0", max_d)
    traces2 = lts2.all_traces_up_to("t0", max_d)
    print(f"\nTrace equivalent (depth ≤ {max_d})? {traces1 == traces2}")

    # Check bisimilarity
    bisim, _ = are_bisimilar_cross(lts1, "s0", lts2, "t0")
    print(f"Bisimilar? {bisim}")
    print(f"Correspondence holds: trace_equiv = bisimilar = {traces1 == traces2 and bisim}")

    # Show the functional bisimulation
    print("\nFunctional bisimulation: s0↔t0, s1↔t1, s2↔t2")
    relation = {"s0": "t0", "s1": "t1", "s2": "t2"}
    print(show_naturality_squares(lts1, "s0", lts2, "t0", relation))


def example_hm_logic():
    """Demonstrate Hennessy-Milner logic satisfaction."""
    print("\n" + "=" * 70)
    print("EXAMPLE 4: Hennessy-Milner Logic")
    print("=" * 70)

    lts = LTS("Process", {"s0", "s1", "s2", "s3"}, {"a", "b"})
    lts.transitions[("s0", "a")] = {"s1", "s2"}
    lts.transitions[("s1", "b")] = {"s3"}
    lts.transitions[("s2", "a")] = {"s3"}

    print(lts.display())

    formulas = [
        ("⟨a⟩⊤", HMDiamond("a", HMTrue())),
        ("⟨b⟩⊤", HMDiamond("b", HMTrue())),
        ("⟨a⟩⟨b⟩⊤", HMDiamond("a", HMDiamond("b", HMTrue()))),
        ("⟨a⟩⟨a⟩⊤", HMDiamond("a", HMDiamond("a", HMTrue()))),
        ("[a]⟨b⟩⊤", HMBox("a", HMDiamond("b", HMTrue()))),
        ("⟨a⟩⟨b⟩⊤ ∧ ⟨a⟩⟨a⟩⊤", HMConj(
            HMDiamond("a", HMDiamond("b", HMTrue())),
            HMDiamond("a", HMDiamond("a", HMTrue()))
        )),
    ]

    print("\nFormula satisfaction:")
    for name, formula in formulas:
        results = {s: hm_satisfies(lts, s, formula) for s in sorted(lts.states)}
        print(f"  {name:30s} : {results}")

    # Check bisimulation classes
    classes = compute_bisimulation_classes(lts)
    print(f"\nBisimulation equivalence classes: {[sorted(c) for c in classes]}")

    # Verify soundness: bisimilar states satisfy same formulas
    print("\nSoundness check (bisimilar states ⊨ same formulas):")
    for cls in classes:
        cls_list = sorted(cls)
        if len(cls_list) > 1:
            for name, formula in formulas:
                vals = [hm_satisfies(lts, s, formula) for s in cls_list]
                ok = all(v == vals[0] for v in vals)
                print(f"  Class {cls_list}: {name} -> {vals} {'✓' if ok else '✗'}")


def example_partition_refinement():
    """Show partition refinement steps."""
    print("\n" + "=" * 70)
    print("EXAMPLE 5: Bisimulation via Partition Refinement")
    print("=" * 70)

    lts = LTS("System", {"p", "q", "r", "s"}, {"a", "b"})
    lts.transitions[("p", "a")] = {"q"}
    lts.transitions[("p", "b")] = {"r"}
    lts.transitions[("q", "a")] = {"s"}
    lts.transitions[("r", "a")] = {"s"}
    lts.transitions[("s", "b")] = {"p"}

    print(lts.display())

    classes = compute_bisimulation_classes(lts)
    print(f"\nBisimulation equivalence classes: {[sorted(c) for c in classes]}")
    print(f"q and r bisimilar? {are_bisimilar(lts, 'q', 'r')}")

    # Show traces from q and r
    for state in ["q", "r"]:
        traces = lts.all_traces_up_to(state, 4)
        print(f"Traces from '{state}' (depth ≤ 4): {sorted(traces, key=lambda t: (len(t), t))}")


# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   Yoneda-Bisimulation Correspondence — Interactive Demo        ║")
    print("║   Naturality is Zigzag: Categorical Foundations for            ║")
    print("║   Process Equivalence                                          ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    example_bisimilar_buffers()
    example_non_bisimilar_machines()
    example_deterministic_correspondence()
    example_hm_logic()
    example_partition_refinement()

    print("\n" + "=" * 70)
    print("All examples completed successfully.")
    print("Key insight: Naturality of nerve presheaf maps = Zigzag condition")
    print("=" * 70)


if __name__ == "__main__":
    main()
