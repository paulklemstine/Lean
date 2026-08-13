"""
Numerical demonstrations for:

    An Internal Boolean-Valued Realization of the Forcing Multiverse

Everything is self-contained: no third-party dependencies, no imports beyond the
standard library.  Running the file executes eight demonstrations, each of which
checks -- by exhaustive finite computation -- one of the theorems of the paper.

Objects modelled
----------------
*   Control worlds  (S, g)   with  S ⊆ {0..n-1}  a set of *pushed buttons*
    (irreversible) and  g ∈ {0,1}^m  a setting of the *switches* (free).
    Accessibility:  (S,g) ⊑ (T,h)  iff  S ⊆ T.

*   Boolean algebra  B = P(G)  where  G = {0,1}^m  is the space of generic
    objects.  Elements of B are represented as integer bitmasks of width 2^m.

*   Boolean values ⟦p⟧_S of propositional assertions at stage S, generic
    filters, generic quotients, forcing.

Checks performed
----------------
1.  Forcing closure: every classical tautology has Boolean value ⊤.
2.  Truth lemma:  quot(v,U) ⊨ p   iff   ⟦p⟧ ∈ U.
3.  Realization theorem:  (S,g) ⊨ p  iff  g ∈ ⟦p⟧_S.
4.  Frame laws + S4.2 soundness; failure of 5, of Brouwer, and of linearity .3.
5.  Derived buttons (positive button fragment) and derived CH branches.
6.  Invariant fragment theorem: invariance  ⟺  button-free normal form.
7.  Branch-preservation criterion  b ∧ ⟦p⟧ ≠ ⊥  and  b ∧ ⟦p⟧^c ≠ ⊥.
8.  Exact count of accessibility pairs:  3^n · 4^m.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
#  Syntax:  p ::= atom | ⊥ | p → q,  with atoms ("btn", i) and ("sw", j)
# --------------------------------------------------------------------------- #

Atom = Tuple[str, int]
Formula = Tuple  # ("atom", Atom) | ("fls",) | ("imp", Formula, Formula)

FLS: Formula = ("fls",)


def atom(kind: str, index: int) -> Formula:
    """Atomic assertion: kind is 'btn' (a button) or 'sw' (a switch)."""
    return ("atom", (kind, index))


def imp(p: Formula, q: Formula) -> Formula:
    """Material implication p → q."""
    return ("imp", p, q)


def neg(p: Formula) -> Formula:
    """Negation ¬p := p → ⊥."""
    return imp(p, FLS)


TRU: Formula = neg(FLS)


def disj(p: Formula, q: Formula) -> Formula:
    """Disjunction p ∨ q := ¬p → q."""
    return imp(neg(p), q)


def conj(p: Formula, q: Formula) -> Formula:
    """Conjunction p ∧ q := ¬(p → ¬q)."""
    return neg(imp(p, neg(q)))


def show(p: Formula) -> str:
    """Human-readable rendering of a formula."""
    if p[0] == "fls":
        return "⊥"
    if p[0] == "atom":
        kind, i = p[1]
        return ("b%d" % i) if kind == "btn" else ("s%d" % i)
    left, right = p[1], p[2]
    if right == FLS:
        return "¬" + show(left)
    return "(%s → %s)" % (show(left), show(right))


def atoms_of(p: Formula) -> List[Atom]:
    """All atoms occurring in p, without repetition, in order of appearance."""
    out: List[Atom] = []

    def walk(q: Formula) -> None:
        if q[0] == "atom":
            if q[1] not in out:
                out.append(q[1])
        elif q[0] == "imp":
            walk(q[1])
            walk(q[2])

    walk(p)
    return out


# --------------------------------------------------------------------------- #
#  Layer A: Boolean values over the powerset algebra of generic objects
# --------------------------------------------------------------------------- #


def top_mask(m: int) -> int:
    """The element ⊤ of the algebra P({0,1}^m), as a bitmask of width 2^m."""
    return (1 << (1 << m)) - 1


def generic_objects(m: int) -> List[Tuple[int, ...]]:
    """All 2^m switch settings, indexed consistently with the bitmask order."""
    return [tuple(reversed(bits)) for bits in product((0, 1), repeat=m)]


def generic_index(g: Sequence[int]) -> int:
    """Index of the generic object g in the enumeration `generic_objects`."""
    return sum(bit << k for k, bit in enumerate(g))


def make_assignment(stage: FrozenSet[int], n: int, m: int) -> Dict[Atom, int]:
    """Stage-`stage` assignment of Boolean values to all atoms."""
    full = top_mask(m)
    assign: Dict[Atom, int] = {}
    for i in range(n):
        assign[("btn", i)] = full if i in stage else 0
    for j in range(m):
        mask = 0
        for idx, g in enumerate(generic_objects(m)):
            if g[j] == 1:
                mask |= 1 << idx
        assign[("sw", j)] = mask
    return assign


def bval(p: Formula, assign: Dict[Atom, int], m: int) -> int:
    """Boolean value ⟦p⟧ ∈ P({0,1}^m), computed by structural recursion."""
    full = top_mask(m)
    if p[0] == "fls":
        return 0
    if p[0] == "atom":
        return assign[p[1]]
    a = bval(p[1], assign, m)
    b = bval(p[2], assign, m)
    return (full & ~a) | b  # a ⇒ b = aᶜ ∨ b


# --------------------------------------------------------------------------- #
#  Two-valued satisfaction at a control world
# --------------------------------------------------------------------------- #

World = Tuple[FrozenSet[int], Tuple[int, ...]]


def csat(w: World, p: Formula) -> bool:
    """Two-valued truth of p at the control world w = (S, g)."""
    stage, g = w
    if p[0] == "fls":
        return False
    if p[0] == "atom":
        kind, i = p[1]
        return (i in stage) if kind == "btn" else (g[i] == 1)
    return (not csat(w, p[1])) or csat(w, p[2])


def worlds(n: int, m: int) -> List[World]:
    """All 2^(n+m) control worlds with n buttons and m switches."""
    out: List[World] = []
    for r in range(n + 1):
        for combo in combinations(range(n), r):
            for g in generic_objects(m):
                out.append((frozenset(combo), g))
    return out


def accessible(w: World, v: World) -> bool:
    """Forcing accessibility: buttons may only be pushed, never unpushed."""
    return w[0] <= v[0]


# --------------------------------------------------------------------------- #
#  Modal operators on predicates over a finite frame
# --------------------------------------------------------------------------- #

Pred = Callable[[World], bool]


def box(ws: Sequence[World], P: Pred) -> Pred:
    return lambda w: all(P(v) for v in ws if accessible(w, v))


def dia(ws: Sequence[World], P: Pred) -> Pred:
    return lambda w: any(P(v) for v in ws if accessible(w, v))


def gbox(ws: Sequence[World], P: Pred) -> Pred:
    """Ground necessity: quantify over worlds of which w is an extension."""
    return lambda w: all(P(v) for v in ws if accessible(v, w))


def gdia(ws: Sequence[World], P: Pred) -> Pred:
    """Ground possibility."""
    return lambda w: any(P(v) for v in ws if accessible(v, w))


def all_predicates(ws: Sequence[World]) -> Iterable[Pred]:
    """All 2^|W| predicates on a finite frame (used for schematic validity)."""
    k = len(ws)
    index = {w: i for i, w in enumerate(ws)}
    for mask in range(1 << k):
        yield (lambda mask=mask: (lambda w: bool(mask >> index[w] & 1)))()


# --------------------------------------------------------------------------- #
#  Demo 1 -- forcing closure: tautologies have Boolean value ⊤
# --------------------------------------------------------------------------- #


def demo_forcing_closure(n: int = 2, m: int = 2) -> None:
    print("=" * 74)
    print("1. FORCING CLOSURE:  every classical tautology has Boolean value ⊤")
    print("=" * 74)
    p, q, r = atom("btn", 0), atom("sw", 0), atom("sw", 1)
    axioms = {
        "A1  p → (q → p)": imp(p, imp(q, p)),
        "A2  (p→(q→r)) → ((p→q)→(p→r))": imp(
            imp(p, imp(q, r)), imp(imp(p, q), imp(p, r))
        ),
        "A3  ¬¬p → p": imp(neg(neg(p)), p),
        "excluded middle  p ∨ ¬p": disj(p, neg(p)),
        "Peirce  ((p→q)→p)→p": imp(imp(imp(p, q), p), p),
    }
    full = top_mask(m)
    for stage in (frozenset(), frozenset({0}), frozenset({0, 1})):
        assign = make_assignment(stage, n, m)
        for name, f in axioms.items():
            value = bval(f, assign, m)
            assert value == full, (name, stage, value)
    print("   all axioms and tautologies evaluate to ⊤ = %s at every stage" % bin(full))
    # a non-theorem does not:
    contingent = atom("sw", 0)
    assign = make_assignment(frozenset(), n, m)
    print("   by contrast ⟦s0⟧ = %s  (neither ⊥ nor ⊤)" % bin(bval(contingent, assign, m)))
    print()


# --------------------------------------------------------------------------- #
#  Demo 2 -- the truth lemma for principal generic filters
# --------------------------------------------------------------------------- #


def demo_truth_lemma(n: int = 2, m: int = 3) -> None:
    print("=" * 74)
    print("2. TRUTH LEMMA:  quot(v,U_g) ⊨ p   iff   ⟦p⟧ ∈ U_g   (U_g principal at g)")
    print("=" * 74)
    formulas = _sample_formulas(n, m)
    checked = 0
    for stage in _stages(n):
        assign = make_assignment(stage, n, m)
        for g in generic_objects(m):
            idx = generic_index(g)
            for f in formulas:
                value = bval(f, assign, m)
                in_filter = bool(value >> idx & 1)
                # the generic quotient by U_g has atomic diagram of (stage, g)
                assert csat((stage, g), f) == in_filter
                checked += 1
    print("   %d instances verified across %d stages and %d generic objects"
          % (checked, 2 ** n, 2 ** m))
    print()


# --------------------------------------------------------------------------- #
#  Demo 3 -- realization theorem
# --------------------------------------------------------------------------- #


def demo_realization(n: int = 2, m: int = 2) -> None:
    print("=" * 74)
    print("3. REALIZATION THEOREM:  (S,g) ⊨ p   iff   g ∈ ⟦p⟧_S")
    print("=" * 74)
    formulas = _sample_formulas(n, m)
    rows = 0
    for stage in _stages(n):
        assign = make_assignment(stage, n, m)
        for f in formulas:
            value = bval(f, assign, m)
            for g in generic_objects(m):
                assert csat((stage, g), f) == bool(value >> generic_index(g) & 1)
            rows += 1
    print("   %d (stage, formula) pairs verified; e.g." % rows)
    stage = frozenset({0})
    assign = make_assignment(stage, n, m)
    for f in [atom("btn", 0), atom("btn", 1), atom("sw", 0),
              conj(atom("btn", 0), atom("sw", 0))]:
        print("      S={0}   ⟦%-14s⟧ = %s" % (show(f), bin(bval(f, assign, m))))
    print()


# --------------------------------------------------------------------------- #
#  Demo 4 -- frame laws, S4.2 soundness, and the failures of 5, B and .3
# --------------------------------------------------------------------------- #


def demo_frame_logic(n: int = 2, m: int = 1) -> None:
    print("=" * 74)
    print("4. FRAME LAWS, S4.2 SOUNDNESS, AND THE FAILURE OF 5, B AND .3")
    print("=" * 74)
    ws = worlds(n, m)
    assert all(accessible(w, w) for w in ws)
    assert all(
        accessible(w, u)
        for w, v, u in product(ws, ws, ws)
        if accessible(w, v) and accessible(v, u)
    )
    directed = all(
        any(accessible(v1, u) and accessible(v2, u) for u in ws)
        for v1, v2 in product(ws, ws)
    )
    print("   reflexive: yes    transitive: yes    directed: %s" % directed)

    ok_T = ok_4 = ok_dot2 = True
    for P in all_predicates(ws):
        for w in ws:
            ok_T &= (not box(ws, P)(w)) or P(w)
            ok_4 &= (not box(ws, P)(w)) or box(ws, box(ws, P))(w)
            ok_dot2 &= (not dia(ws, box(ws, P))(w)) or box(ws, dia(ws, P))(w)
    print("   T (□p→p): %s    4 (□p→□□p): %s    .2 (◇□p→□◇p): %s"
          % (ok_T, ok_4, ok_dot2))

    # axiom 5 and Brouwer fail for P = "button 0 is still unpushed"
    P_unpushed: Pred = lambda w: 0 not in w[0]
    w0: World = (frozenset(), generic_objects(m)[0])
    print("   counterexample predicate: 'button 0 unpushed', base world S=∅")
    print("      ◇P holds:            %s" % dia(ws, P_unpushed)(w0))
    print("      P holds:             %s" % P_unpushed(w0))
    print("      □◇P holds:           %s   ->  axiom 5 and Brouwer both FAIL"
          % box(ws, dia(ws, P_unpushed))(w0))

    # linearity .3 fails with two independent buttons
    P1: Pred = lambda w: 0 in w[0]
    P2: Pred = lambda w: 1 in w[0]
    left = box(ws, lambda v: (not box(ws, P1)(v)) or P2(v))(w0)
    right = box(ws, lambda v: (not box(ws, P2)(v)) or P1(v))(w0)
    print("      .3  □(□p→q) ∨ □(□q→p) at S=∅: %s ∨ %s = %s   ->  FAILS"
          % (left, right, left or right))

    # the mixed tense axiom p → □ ◇̌ p is valid on the same frame
    tense_ok = all(
        (not P(w)) or box(ws, gdia(ws, P))(w)
        for P in all_predicates(ws)
        for w in ws
    )
    print("   mixed tense axiom p → □◇̌p (ground modality): %s" % tense_ok)
    print("      => bimodal separation: □◇̌ valid while □◇ (Brouwer) fails")
    print()


# --------------------------------------------------------------------------- #
#  Demo 5 -- derived buttons and derived CH branches
# --------------------------------------------------------------------------- #


def demo_buttons_and_branches(n: int = 2, m: int = 2) -> None:
    print("=" * 74)
    print("5. DERIVED BUTTONS AND DERIVED CH BRANCHES")
    print("=" * 74)
    positive = [
        atom("btn", 0),
        conj(atom("btn", 0), atom("btn", 1)),
        disj(atom("btn", 0), atom("btn", 1)),
        conj(TRU, disj(atom("btn", 0), conj(atom("btn", 1), atom("btn", 0)))),
    ]
    ws = worlds(n, m)
    for f in positive:
        # Boolean-valued monotonicity along the stage order
        for S, T in product(_stages(n), _stages(n)):
            if S <= T:
                vs = bval(f, make_assignment(S, n, m), m)
                vt = bval(f, make_assignment(T, n, m), m)
                assert vs & ~vt == 0, (show(f), S, T)
        # the resulting button law in the frame
        assert all(
            (not csat(w, f)) or csat(v, f)
            for w, v in product(ws, ws)
            if accessible(w, v)
        )
        print("   %-42s is a button (monotone Boolean value)" % show(f))

    ch = atom("sw", 0)  # the designated CH switch
    for S in _stages(n):
        value = bval(ch, make_assignment(S, n, m), m)
        assert value != 0 and value != top_mask(m)
    print("   ⟦CH⟧_S is neither ⊥ nor ⊤ at every stage -> branching theorem applies")
    for w in ws:
        assert dia(ws, lambda v: csat(v, ch))(w)
        assert dia(ws, lambda v: not csat(v, ch))(w)
    print("   ◇CH ∧ ◇¬CH holds at every one of the %d worlds: CH is a switch" % len(ws))
    print()


# --------------------------------------------------------------------------- #
#  Demo 6 -- the invariant fragment theorem
# --------------------------------------------------------------------------- #


def button_free_normal_form(p: Formula) -> Formula:
    """Substitute ⊥ for every button atom: the canonical button-free candidate."""
    if p[0] == "fls":
        return p
    if p[0] == "atom":
        return FLS if p[1][0] == "btn" else p
    return imp(button_free_normal_form(p[1]), button_free_normal_form(p[2]))


def is_invariant(p: Formula, n: int, m: int) -> bool:
    """Does the truth value of p depend only on the switch setting?"""
    for g in generic_objects(m):
        values = {csat((S, g), p) for S in _stages(n)}
        if len(values) > 1:
            return False
    return True


def demo_invariant_fragment(n: int = 2, m: int = 2) -> None:
    print("=" * 74)
    print("6. INVARIANT FRAGMENT THEOREM:  invariance ⟺ button-free normal form")
    print("=" * 74)
    tests = [
        atom("sw", 0),
        imp(atom("sw", 0), atom("sw", 1)),
        atom("btn", 0),
        disj(atom("btn", 0), neg(atom("btn", 0))),          # a tautology: invariant
        imp(atom("btn", 0), atom("btn", 0)),                # invariant
        conj(atom("btn", 0), atom("sw", 0)),                # not invariant
    ]
    for p in tests:
        inv = is_invariant(p, n, m)
        nf = button_free_normal_form(p)
        agrees = all(
            csat((S, g), p) == csat((S, g), nf)
            for S in _stages(n)
            for g in generic_objects(m)
        )
        assert inv == agrees, show(p)
        print("   %-28s invariant=%-5s  normal form %-22s agrees=%s"
              % (show(p), inv, show(nf), agrees))
    print("   (equality of the two columns is exactly the fragment theorem)")
    print()


# --------------------------------------------------------------------------- #
#  Demo 7 -- exact criterion for two-sided branch preservation
# --------------------------------------------------------------------------- #


def survives_both_branches(background: int, value: int, m: int) -> bool:
    """b ∧ ⟦p⟧ ≠ ⊥  and  b ∧ ⟦p⟧ᶜ ≠ ⊥ -- necessary and sufficient."""
    full = top_mask(m)
    return (background & value) != 0 and (background & full & ~value) != 0


def demo_branch_preservation(n: int = 2, m: int = 2) -> None:
    print("=" * 74)
    print("7. BRANCH PRESERVATION:  b ∧ ⟦p⟧ ≠ ⊥  and  b ∧ ⟦p⟧ᶜ ≠ ⊥")
    print("=" * 74)
    stage = frozenset({0})
    assign = make_assignment(stage, n, m)
    ch = atom("sw", 0)
    value = bval(ch, assign, m)
    cases = {
        "button background  ⟦b0⟧ (b0 pushed)": bval(atom("btn", 0), assign, m),
        "trivial background ⊤": top_mask(m),
        "switch background  ⟦s0⟧ = ⟦CH⟧": value,
        "opposite switch    ⟦¬s0⟧": bval(neg(ch), assign, m),
        "unpushed button    ⟦b1⟧": bval(atom("btn", 1), assign, m),
    }
    for name, b in cases.items():
        print("   %-38s  b=%-8s survives both CH branches: %s"
              % (name, bin(b), survives_both_branches(b, value, m)))
    print("   -> button-definable backgrounds branch; switch-entangled ones cannot,")
    print("      and an inconsistent background (⊥) branches vacuously nowhere.")
    print()


# --------------------------------------------------------------------------- #
#  Demo 8 -- counting the frame:  3^n · 4^m accessibility pairs
# --------------------------------------------------------------------------- #


def count_accessibility_pairs(n: int, m: int) -> int:
    """Brute-force count of the pairs (w,v) with w ⊑ v."""
    ws = worlds(n, m)
    return sum(1 for w, v in product(ws, ws) if accessible(w, v))


def demo_counting(max_n: int = 3, max_m: int = 3) -> None:
    print("=" * 74)
    print("8. EXACT SIZE OF THE FORCING RELATION:  |⊑| = 3^n · 4^m")
    print("=" * 74)
    print("    n  m   worlds 2^(n+m)   brute force   3^n·4^m   match")
    for n in range(max_n + 1):
        for m in range(max_m + 1):
            if n + m > 5:
                continue
            brute = count_accessibility_pairs(n, m)
            closed = 3 ** n * 4 ** m
            assert brute == closed
            print("   %2d %2d   %12d   %11d   %7d   %s"
                  % (n, m, 2 ** (n + m), brute, closed, brute == closed))
    print("   three states per button (off/off, off/on, on/on -- never on/off),")
    print("   four per switch (its value before and after are unconstrained).")
    print()


# --------------------------------------------------------------------------- #
#  helpers
# --------------------------------------------------------------------------- #


def _stages(n: int) -> List[FrozenSet[int]]:
    """All 2^n stages (sets of pushed buttons)."""
    return [
        frozenset(c) for r in range(n + 1) for c in combinations(range(n), r)
    ]


def _sample_formulas(n: int, m: int) -> List[Formula]:
    """A spread of test formulas mixing button and switch atoms."""
    b0, b1 = atom("btn", 0), atom("btn", min(1, n - 1))
    s0, s1 = atom("sw", 0), atom("sw", min(1, m - 1))
    return [
        FLS,
        TRU,
        b0,
        s0,
        neg(b0),
        neg(s0),
        imp(b0, s0),
        conj(b0, s0),
        disj(b0, s0),
        conj(disj(b0, b1), neg(s1)),
        imp(conj(s0, s1), disj(b0, neg(b1))),
    ]


# --------------------------------------------------------------------------- #


def main() -> None:
    print()
    print("BOOLEAN-VALUED REALIZATION OF THE FORCING MULTIVERSE -- NUMERICAL DEMOS")
    print()
    demo_forcing_closure()
    demo_truth_lemma()
    demo_realization()
    demo_frame_logic()
    demo_buttons_and_branches()
    demo_invariant_fragment()
    demo_branch_preservation()
    demo_counting()
    print("all checks passed.")


if __name__ == "__main__":
    main()
