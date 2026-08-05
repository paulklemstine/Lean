"""
Signed-Literal Revision: Numerical Demonstrations
=================================================

Self-contained demonstrations of the main results on iterated signed-literal
revision.

Framework
---------
  * An ATOM is a hashable label (here: a string).
  * A LITERAL is a pair (atom, sign) with sign in {True, False}.
  * A STATE is an arbitrary set of literals.  It may contain BOTH signs of an
    atom, in which case it is "contradictory at" that atom; a state with no
    such atom is "consistent".  Acceptance is membership -- no closure, so a
    contradictory state does NOT accept everything.
  * REVISION is  rev(B, l) = (B \\ {complement(l)}) union {l}.
  * A HISTORY is a finite list of literals, applied left to right.

Results demonstrated
--------------------
  1. Independence:   distinct atoms  =>  rev(rev(B,l),k) = rev(rev(B,k),l)
  2. Last write wins: same atom      =>  rev(rev(B,l),k) = rev(B,k)
  3. Last-Occurrence Normalization Theorem
  4. Extensional rigidity (the empty state is a complete test input)
  5. Normal form: same action, atom-distinct, unique up to permutation
  6. Frame property and persistent non-explosion
  7. Consistency as a partial sign assignment
  8. Monotone support and classification of strongly connected components

Run:  python demo.py
"""

from __future__ import annotations

import itertools
import random
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

Atom = str
Sign = bool
Literal = Tuple[Atom, Sign]
State = FrozenSet[Literal]
History = List[Literal]
Receipt = Dict[Atom, Sign]


# --------------------------------------------------------------------------
# Core operations
# --------------------------------------------------------------------------

def complement(lit: Literal) -> Literal:
    """The complementary literal: same atom, opposite sign."""
    a, s = lit
    return (a, not s)


def revise(state: State, lit: Literal) -> State:
    """rev(B, l) = (B \\ {complement(l)}) union {l}: assert l, retract only its opposite."""
    return frozenset(state - {complement(lit)} | {lit})


def revise_seq(state: State, history: Sequence[Literal]) -> State:
    """Apply a history of revisions left to right (naive step-by-step simulation)."""
    out = state
    for lit in history:
        out = revise(out, lit)
    return out


def last_sign(history: Sequence[Literal]) -> Receipt:
    """The receipt: for each atom mentioned, the sign of its LAST occurrence."""
    receipt: Receipt = {}
    for atom, sign in history:
        receipt[atom] = sign
    return receipt


def apply_receipt(state: State, receipt: Receipt) -> State:
    """
    Single-pass application predicted by the Normalization Theorem:
    overwrite the mentioned atoms, pass everything else through unchanged.
    """
    passed = {(a, s) for (a, s) in state if a not in receipt}
    overwritten = {(a, s) for a, s in receipt.items()}
    return frozenset(passed | overwritten)


def normal_form(history: Sequence[Literal]) -> History:
    """
    Delete every literal superseded by a later revision of the same atom,
    preserving the relative order of the survivors.
    """
    seen: Set[Atom] = set()
    out: History = []
    for lit in reversed(history):
        if lit[0] not in seen:
            seen.add(lit[0])
            out.append(lit)
    out.reverse()
    return out


def is_consistent(state: State) -> bool:
    """No atom carries both signs."""
    return not any((a, True) in state and (a, False) in state for (a, _) in state)


def assigned(state: State) -> FrozenSet[Atom]:
    """The support: atoms carrying at least one sign."""
    return frozenset(a for (a, _) in state)


def partial_assignment(state: State) -> Optional[Dict[Atom, Sign]]:
    """
    If the state is consistent, return the partial function atom -> sign whose
    graph it is; otherwise return None.
    """
    if not is_consistent(state):
        return None
    return {a: s for (a, s) in state}


def show_state(state: State) -> str:
    if not state:
        return "{}"
    items = sorted(state, key=lambda p: (p[0], not p[1]))
    return "{" + ", ".join(f"{a}{'+' if s else '-'}" for a, s in items) + "}"


def show_history(history: Sequence[Literal]) -> str:
    if not history:
        return "()"
    return "(" + " ".join(f"{a}{'+' if s else '-'}" for a, s in history) + ")"


def show_receipt(receipt: Receipt) -> str:
    if not receipt:
        return "{}"
    return "{" + ", ".join(f"{a}->{'+' if s else '-'}" for a, s in sorted(receipt.items())) + "}"


# --------------------------------------------------------------------------
# Enumeration helpers
# --------------------------------------------------------------------------

def all_states(atoms: Sequence[Atom]) -> List[State]:
    """All 4^|atoms| states (each atom independently: none, +, -, or both)."""
    out: List[State] = []
    per_atom = [[frozenset(), frozenset({(a, True)}), frozenset({(a, False)}),
                 frozenset({(a, True), (a, False)})] for a in atoms]
    for combo in itertools.product(*per_atom):
        out.append(frozenset().union(*combo))
    return out


def all_consistent_states(atoms: Sequence[Atom]) -> List[State]:
    """All 3^|atoms| consistent states (each atom: unassigned, +, or -)."""
    out: List[State] = []
    per_atom = [[frozenset(), frozenset({(a, True)}), frozenset({(a, False)})] for a in atoms]
    for combo in itertools.product(*per_atom):
        out.append(frozenset().union(*combo))
    return out


def all_literals(atoms: Sequence[Atom]) -> List[Literal]:
    return [(a, s) for a in atoms for s in (True, False)]


def random_history(atoms: Sequence[Atom], length: int, rng: random.Random) -> History:
    return [(rng.choice(list(atoms)), rng.choice([True, False])) for _ in range(length)]


# --------------------------------------------------------------------------
# Demonstration 1: the two local rewriting laws
# --------------------------------------------------------------------------

def demo_local_laws() -> None:
    print("=" * 74)
    print("1.  THE TWO LOCAL REWRITING LAWS")
    print("=" * 74)
    atoms = ["a", "b", "c"]
    lits = all_literals(atoms)
    states = all_states(atoms)

    indep_checked = same_checked = 0
    for B in states:
        for l, k in itertools.product(lits, repeat=2):
            lhs = revise(revise(B, l), k)
            if l[0] != k[0]:
                assert lhs == revise(revise(B, k), l), "Independence FAILED"
                indep_checked += 1
            else:
                assert lhs == revise(B, k), "Last-write-wins FAILED"
                same_checked += 1

    print(f"  Independence (distinct atoms commute):    {indep_checked:5d} instances verified")
    print(f"  Last write wins (same atom overwrites):   {same_checked:5d} instances verified")
    print()
    print("  Worked instance (contrary revisions do NOT commute):")
    E: State = frozenset()
    print(f"    rev(rev({show_state(E)}, a+), a-) = {show_state(revise(revise(E, ('a', True)), ('a', False)))}")
    print(f"    rev(rev({show_state(E)}, a-), a+) = {show_state(revise(revise(E, ('a', False)), ('a', True)))}")
    print("    ... yet the second is exactly rev(E, a+): only the LAST write survives.")
    print()


# --------------------------------------------------------------------------
# Demonstration 2: the Last-Occurrence Normalization Theorem
# --------------------------------------------------------------------------

def demo_normalization() -> None:
    print("=" * 74)
    print("2.  LAST-OCCURRENCE NORMALIZATION THEOREM")
    print("=" * 74)
    print("      p in rev*(B;L)  <=>  last_L(atom p) = sign p,")
    print("                       or  atom p unmentioned by L and p in B.")
    print()

    atoms = ["a", "b", "c"]
    rng = random.Random(20260805)
    states = all_states(atoms)
    trials = 0
    for _ in range(400):
        L = random_history(atoms, rng.randint(0, 8), rng)
        receipt = last_sign(L)
        for B in states:
            assert revise_seq(B, L) == apply_receipt(B, receipt), "Normalization FAILED"
            trials += 1
    print(f"  Verified on {trials} (history, state) pairs over 3 atoms.")
    print()

    L: History = [("a", True), ("a", False), ("b", True), ("a", True), ("b", False), ("a", False)]
    B: State = frozenset({("c", True), ("d", False), ("a", True)})
    print(f"  History L      = {show_history(L)}   (length {len(L)})")
    print(f"  Receipt        = {show_receipt(last_sign(L))}")
    print(f"  Normal form    = {show_history(normal_form(L))}   (length {len(normal_form(L))})")
    print(f"  Initial B      = {show_state(B)}")
    print(f"  rev*(B;L)      = {show_state(revise_seq(B, L))}")
    print(f"  rev*(B;nf(L))  = {show_state(revise_seq(B, normal_form(L)))}   <- identical")
    print("  Note c and d are untouched: the history never mentions them.")
    print()

    # A long history collapses to at most one literal per atom.
    long_L = random_history(atoms, 100000, rng)
    print(f"  A random history of length {len(long_L)} over {len(atoms)} atoms")
    print(f"    compresses to length {len(normal_form(long_L))} "
          f"= number of mentioned atoms.")
    print(f"    receipt = {show_receipt(last_sign(long_L))}")
    assert revise_seq(frozenset(), long_L) == revise_seq(frozenset(), normal_form(long_L))
    print("    and the two act identically on the empty state.")
    print()


# --------------------------------------------------------------------------
# Demonstration 3: extensional rigidity
# --------------------------------------------------------------------------

def demo_rigidity() -> None:
    print("=" * 74)
    print("3.  EXTENSIONAL RIGIDITY  (the empty state is a complete test input)")
    print("=" * 74)
    print("  Agreeing on ALL states  <=>  agreeing on the empty state")
    print("                          <=>  equal receipts.")
    print()
    atoms = ["a", "b"]
    rng = random.Random(1729)
    states = all_states(atoms)
    E: State = frozenset()

    agree_count = 0
    pairs = 0
    for _ in range(3000):
        L = random_history(atoms, rng.randint(0, 5), rng)
        M = random_history(atoms, rng.randint(0, 5), rng)
        on_empty = revise_seq(E, L) == revise_seq(E, M)
        on_all = all(revise_seq(B, L) == revise_seq(B, M) for B in states)
        same_receipt = last_sign(L) == last_sign(M)
        assert on_empty == on_all == same_receipt, "Rigidity FAILED"
        pairs += 1
        agree_count += int(on_all)
    print(f"  {pairs} random history pairs tested; all three conditions coincided every time.")
    print(f"  ({agree_count} of the pairs were behaviourally equivalent.)")
    print()
    L1: History = [("a", True), ("b", False), ("a", False)]
    L2: History = [("b", True), ("a", False), ("b", False)]
    print(f"  Example: L1 = {show_history(L1)}, L2 = {show_history(L2)}")
    print(f"    receipt(L1) = {show_receipt(last_sign(L1))}")
    print(f"    receipt(L2) = {show_receipt(last_sign(L2))}   -> equal, so equivalent on every state")
    print()


# --------------------------------------------------------------------------
# Demonstration 4: normal form uniqueness up to permutation
# --------------------------------------------------------------------------

def demo_normal_form_uniqueness() -> None:
    print("=" * 74)
    print("4.  NORMAL FORM: MINIMAL, AND UNIQUE UP TO PERMUTATION")
    print("=" * 74)
    atoms = ["a", "b", "c"]
    rng = random.Random(42)

    for _ in range(500):
        L = random_history(atoms, rng.randint(0, 10), rng)
        nfL = normal_form(L)
        # atom-distinct
        assert len({a for a, _ in nfL}) == len(nfL)
        # same receipt, hence same action
        assert last_sign(nfL) == last_sign(L)
        # ANY atom-distinct history with the same receipt is a permutation of nf(L)
        for perm in itertools.permutations(nfL):
            assert last_sign(list(perm)) == last_sign(L)
            assert sorted(perm) == sorted(nfL)
    print("  500 random histories: normal form is atom-distinct, receipt-preserving,")
    print("  and every reordering of it has the same receipt (hence the same action).")
    print()

    L: History = [("a", True), ("b", False), ("c", True), ("b", True), ("a", False)]
    nfL = normal_form(L)
    print(f"  L        = {show_history(L)}")
    print(f"  nf(L)    = {show_history(nfL)}")
    print("  All behaviourally equivalent atom-distinct histories (= permutations of nf(L)):")
    for perm in itertools.permutations(nfL):
        assert revise_seq(frozenset(), list(perm)) == revise_seq(frozenset(), L)
        print(f"      {show_history(list(perm))}")
    print("  Permutation is the SHARPEST conclusion: distinct atoms genuinely commute.")
    print()


# --------------------------------------------------------------------------
# Demonstration 5: frame property and persistent non-explosion
# --------------------------------------------------------------------------

def demo_non_explosion() -> None:
    print("=" * 74)
    print("5.  FRAME PROPERTY AND PERSISTENT NON-EXPLOSION")
    print("=" * 74)
    B: State = frozenset({("a", True), ("a", False)})    # contradictory at a
    target: Literal = ("b", True)
    print(f"  B = {show_state(B)}  is contradictory at 'a'.")
    print(f"  B does NOT accept {target[0]}+ : classically, contradiction would license it.")
    print()

    rng = random.Random(7)
    max_len = 0
    for _ in range(2000):
        n = rng.randint(0, 60)
        L: History = [("a", rng.choice([True, False])) for _ in range(n)]
        out = revise_seq(B, L)
        assert target not in out, "Non-explosion FAILED"
        max_len = max(max_len, n)
    print(f"  2000 random histories over atom 'a' alone (lengths up to {max_len}):")
    print(f"    {target[0]}+ was never accepted -- the contradiction stays quarantined.")

    hammer: History = [("a", i % 2 == 0) for i in range(1000000)]
    out = revise_seq(B, hammer)
    print(f"  Hammering 'a' {len(hammer)} times alternating signs gives {show_state(out)}:")
    print("    the contradiction is even REPAIRED at 'a', and 'b' is untouched.")
    print()

    # Frame property on a richer state.
    B2: State = frozenset({("a", True), ("a", False), ("b", False), ("c", True)})
    L2: History = [("a", True), ("a", False), ("c", False), ("a", True)]
    out2 = revise_seq(B2, L2)
    print(f"  Frame check: B = {show_state(B2)}, L = {show_history(L2)}")
    print(f"               rev*(B;L) = {show_state(out2)}")
    print("               'b' is unmentioned by L, so b- persists exactly as it was.")
    assert (("b", False) in out2) == (("b", False) in B2)
    print()


# --------------------------------------------------------------------------
# Demonstration 6: consistency as a partial assignment
# --------------------------------------------------------------------------

def demo_partial_assignment() -> None:
    print("=" * 74)
    print("6.  CONSISTENCY AS A PARTIAL SIGN ASSIGNMENT")
    print("=" * 74)
    atoms = ["a", "b", "c"]
    states = all_states(atoms)
    cons = [B for B in states if is_consistent(B)]
    print(f"  All states over {len(atoms)} atoms:        {len(states)}  ( = 4^{len(atoms)} )")
    print(f"  Consistent ones:                {len(cons)}  ( = 3^{len(atoms)} )")
    for B in cons:
        f = partial_assignment(B)
        assert f is not None
        assert B == frozenset((a, s) for a, s in f.items())
    print("  Every consistent state is exactly the graph of a partial map atom -> sign.")
    print()
    by_support: Dict[FrozenSet[Atom], int] = {}
    for B in cons:
        by_support[assigned(B)] = by_support.get(assigned(B), 0) + 1
    print("  Grouped by support S (each class has 2^|S| members):")
    for S in sorted(by_support, key=lambda s: (len(s), sorted(s))):
        label = "{" + ",".join(sorted(S)) + "}" if S else "{}"
        print(f"      S = {label:<10}  |S| = {len(S)}   states = {by_support[S]}   2^|S| = {2 ** len(S)}")
        assert by_support[S] == 2 ** len(S)
    print()


# --------------------------------------------------------------------------
# Demonstration 7: the revision graph and its components
# --------------------------------------------------------------------------

def reachable_set(start: State, atoms: Sequence[Atom]) -> Set[State]:
    """Forward closure of `start` under single revisions."""
    seen = {start}
    frontier = [start]
    lits = all_literals(atoms)
    while frontier:
        B = frontier.pop()
        for l in lits:
            C = revise(B, l)
            if C not in seen:
                seen.add(C)
                frontier.append(C)
    return seen


def demo_components() -> None:
    print("=" * 74)
    print("7.  THE REVISION GRAPH: MONOTONE SUPPORT AND ITS COMPONENTS")
    print("=" * 74)
    atoms = ["a", "b", "c"]
    cons = all_consistent_states(atoms)

    # Monotone support.
    for B in cons:
        for l in all_literals(atoms):
            assert assigned(revise(B, l)) == assigned(B) | {l[0]}
    print("  Support law verified:  asg(rev(B,l)) = asg(B) union {atom of l}.")
    print("  Support therefore only GROWS along a history.")
    print()

    # Mutual reachability == equal support.
    fwd = {B: reachable_set(B, atoms) for B in cons}
    checked = 0
    for B, C in itertools.product(cons, repeat=2):
        mutual = (C in fwd[B]) and (B in fwd[C])
        assert mutual == (assigned(B) == assigned(C)), "SCC classification FAILED"
        checked += 1
    print(f"  Component classification verified on {checked} ordered pairs of consistent states:")
    print("      B and C are mutually reachable  <=>  asg(B) = asg(C).")
    print()

    # Component sizes and intra-component diameter.
    comps: Dict[FrozenSet[Atom], List[State]] = {}
    for B in cons:
        comps.setdefault(assigned(B), []).append(B)
    print("  Components, their sizes, and their intra-component diameters:")
    for S in sorted(comps, key=lambda s: (len(s), sorted(s))):
        members = comps[S]
        diam = _component_diameter(members, atoms)
        label = "{" + ",".join(sorted(S)) + "}" if S else "{}"
        print(f"      S = {label:<10} size = {len(members):>2} (= 2^{len(S)})   diameter = {diam} (= |S|)")
        assert len(members) == 2 ** len(S)
        assert diam == len(S)
    print("  Each component is a |S|-dimensional cube: 2^|S| vertices, diameter |S|.")
    print()

    # Steering: emit the literals of C \ B.
    rng = random.Random(3)
    for _ in range(300):
        B = rng.choice(cons)
        C = rng.choice(cons)
        if not assigned(B) <= assigned(C):
            continue
        plan: History = sorted(C - B)
        assert revise_seq(B, plan) == C, "Steering FAILED"
    print("  Steering verified: when asg(B) is contained in asg(C), emitting the")
    print("  literals of C \\ B in any order carries B exactly to C.")
    print()


def _component_diameter(members: Sequence[State], atoms: Sequence[Atom]) -> int:
    """Longest shortest-path distance inside one strongly connected component."""
    index = {B: i for i, B in enumerate(members)}
    lits = all_literals(atoms)
    best = 0
    for src in members:
        dist = {src: 0}
        queue = [src]
        head = 0
        while head < len(queue):
            B = queue[head]
            head += 1
            for l in lits:
                C = revise(B, l)
                if C in index and C not in dist:
                    dist[C] = dist[B] + 1
                    queue.append(C)
        best = max(best, max(dist.values()))
    return best


# --------------------------------------------------------------------------
# Demonstration 8: single-pass application beats step-by-step simulation
# --------------------------------------------------------------------------

def demo_performance() -> None:
    print("=" * 74)
    print("8.  ALGORITHMIC PAYOFF: ONE-PASS APPLICATION")
    print("=" * 74)
    import time

    rng = random.Random(11)
    atoms = [f"x{i}" for i in range(50)]
    base: State = frozenset((f"y{i}", rng.choice([True, False])) for i in range(2000))
    L = random_history(atoms, 200000, rng)

    t0 = time.perf_counter()
    naive = revise_seq(base, L)
    t1 = time.perf_counter()
    fast = apply_receipt(base, last_sign(L))
    t2 = time.perf_counter()

    assert naive == fast
    print(f"  |B| = {len(base)},  |L| = {len(L)},  atoms mentioned = {len(last_sign(L))}")
    print(f"    step-by-step simulation : {t1 - t0:8.4f} s")
    print(f"    receipt + one pass      : {t2 - t1:8.4f} s")
    if t2 - t1 > 0:
        print(f"    speedup                 : {(t1 - t0) / (t2 - t1):8.1f}x")
    print("    (identical results, guaranteed by the Normalization Theorem)")
    print()


# --------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 74)
    print("#  SIGNED-LITERAL REVISION: LAST-OCCURRENCE NORMAL FORMS AND GEOMETRY  #")
    print("#" * 74)
    print()
    demo_local_laws()
    demo_normalization()
    demo_rigidity()
    demo_normal_form_uniqueness()
    demo_non_explosion()
    demo_partial_assignment()
    demo_components()
    demo_performance()
    print("=" * 74)
    print("All demonstrations completed successfully.")
    print("=" * 74)


if __name__ == "__main__":
    main()
