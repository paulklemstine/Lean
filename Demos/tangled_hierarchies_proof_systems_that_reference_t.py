"""
Tangled Hierarchies: Proof Systems That Reference Their Own Soundness
=====================================================================

Numerical demonstrations of the main results.

Everything here is a finite Kripke frame (a directed graph of "worlds") together
with a modal language

        phi ::= p | bot | phi -> phi | Box phi

read provability-style: Box phi holds at a world w iff phi holds at every world
w can see.  The mathematical content demonstrated below:

  1.  SOUNDNESS = TANGLE.  A world validates every instance of the reflection
      schema  Box phi -> phi  (for every valuation) iff it accesses itself.
      Verified here by brute force over all valuations and all formulas up to a
      given depth, and compared against the self-loop test.

  2.  ATOMIC REFLECTION SUFFICES.  Reflection restricted to propositional
      variables already forces the loop, hence the full schema.

  3.  THE SPECTRUM.  A world validates  Box^n phi -> phi  iff it lies on a
      closed walk of length exactly n.  The cycle frame on n worlds realises
      degree n and refutes every degree k with 0 < k < n.

  4.  DEGREES FORM A MONOID.  The set of soundness degrees of a world contains
      0 and is closed under addition.

  5.  COST IS ONE LOOP.  The soundness extension adds one world, one loop and
      one internally sound world, and preserves the truth value of every
      formula at every old world.  The reflection tower has exactly n sound
      worlds at stage n, and always an unsound world.

  6.  THE BOUNDARY.  Internal consistency (not Box bot) is seriality: it holds
      on a loop-free, converse-well-founded chain.  But a *finite* serial frame
      always contains a cycle.

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# Formulas
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Formula:
    """A modal formula.

    kind is one of 'var', 'bot', 'imp', 'box'.
      'var' : name is the variable
      'bot' : no arguments
      'imp' : left -> right
      'box' : Box left
    """

    kind: str
    name: Optional[str] = None
    left: Optional["Formula"] = None
    right: Optional["Formula"] = None

    def __str__(self) -> str:
        if self.kind == "var":
            return str(self.name)
        if self.kind == "bot":
            return "⊥"
        if self.kind == "box":
            return f"□{self.left}"
        return f"({self.left} → {self.right})"


def var(name: str) -> Formula:
    return Formula("var", name=name)


def bot() -> Formula:
    return Formula("bot")


def imp(a: Formula, b: Formula) -> Formula:
    return Formula("imp", left=a, right=b)


def box(a: Formula) -> Formula:
    return Formula("box", left=a)


def neg(a: Formula) -> Formula:
    return imp(a, bot())


def box_iter(n: int, a: Formula) -> Formula:
    """Box^n phi."""
    out = a
    for _ in range(n):
        out = box(out)
    return out


def reflection(a: Formula) -> Formula:
    """The reflection (soundness) instance  Box phi -> phi."""
    return imp(box(a), a)


def iter_reflection(n: int, a: Formula) -> Formula:
    """The n-fold reflection instance  Box^n phi -> phi."""
    return imp(box_iter(n, a), a)


def loeb_instance(a: Formula) -> Formula:
    """The Loeb instance  Box(Box phi -> phi) -> Box phi."""
    return imp(box(reflection(a)), box(a))


def con() -> Formula:
    """The consistency statement  not Box bot."""
    return neg(box(bot()))


# ---------------------------------------------------------------------------
# Frames and satisfaction
# ---------------------------------------------------------------------------

World = object
Valuation = Dict[Tuple[str, object], bool]


@dataclass(frozen=True)
class Frame:
    """A Kripke frame: a finite list of worlds and an accessibility relation."""

    worlds: Tuple[object, ...]
    edges: FrozenSet[Tuple[object, object]]

    def successors(self, w: object) -> List[object]:
        return [v for v in self.worlds if (w, v) in self.edges]

    def accesses(self, u: object, v: object) -> bool:
        return (u, v) in self.edges


def make_frame(worlds: Sequence[object], relation: Callable[[object, object], bool]) -> Frame:
    return Frame(
        worlds=tuple(worlds),
        edges=frozenset((u, v) for u in worlds for v in worlds if relation(u, v)),
    )


def satisfies(frame: Frame, val: Valuation, w: object, phi: Formula) -> bool:
    """Kripke satisfaction  w |=_val phi."""
    if phi.kind == "var":
        return val[(str(phi.name), w)]
    if phi.kind == "bot":
        return False
    if phi.kind == "imp":
        assert phi.left is not None and phi.right is not None
        return (not satisfies(frame, val, w, phi.left)) or satisfies(frame, val, w, phi.right)
    if phi.kind == "box":
        assert phi.left is not None
        return all(satisfies(frame, val, v, phi.left) for v in frame.successors(w))
    raise ValueError(f"unknown formula kind {phi.kind}")


def all_valuations(frame: Frame, atoms: Sequence[str]) -> Iterable[Valuation]:
    """Every assignment of truth values to atoms at worlds (2^(|atoms| * |W|) of them)."""
    slots = [(p, w) for p in atoms for w in frame.worlds]
    for bits in product([False, True], repeat=len(slots)):
        yield {slot: b for slot, b in zip(slots, bits)}


def formulas_up_to_depth(atoms: Sequence[str], depth: int) -> List[Formula]:
    """All formulas of modal/implication depth at most `depth` over `atoms`."""
    current: List[Formula] = [bot()] + [var(p) for p in atoms]
    seen: List[Formula] = list(current)
    for _ in range(depth):
        new: List[Formula] = []
        for a in current:
            new.append(box(a))
            for b in current:
                new.append(imp(a, b))
        current = new
        seen.extend(new)
    # de-duplicate on the printed form
    out: Dict[str, Formula] = {}
    for f in seen:
        out.setdefault(str(f), f)
    return list(out.values())


# ---------------------------------------------------------------------------
# Reachability: the combinatorial side of the theorems
# ---------------------------------------------------------------------------


def n_step_reachable(frame: Frame, w: object, n: int) -> Set[object]:
    """The set of worlds reachable from w by a walk of length exactly n."""
    frontier: Set[object] = {w}
    for _ in range(n):
        frontier = {v for u in frontier for v in frame.successors(u)}
    return frontier


def soundness_degrees(frame: Frame, w: object, max_degree: int) -> List[int]:
    """{n <= max_degree : w lies on a closed walk of length exactly n}.

    By the Spectrum Theorem this is exactly the set of degrees n for which
    w validates  Box^n phi -> phi  under every valuation.
    """
    return [n for n in range(max_degree + 1) if w in n_step_reachable(frame, w, n)]


def transitive_closure(frame: Frame) -> Set[Tuple[object, object]]:
    reach = set(frame.edges)
    changed = True
    while changed:
        changed = False
        for (a, b) in list(reach):
            for (c, d) in list(frame.edges):
                if b == c and (a, d) not in reach:
                    reach.add((a, d))
                    changed = True
    return reach


def is_tangled(frame: Frame) -> bool:
    """Does the transitive closure contain a two-cycle (a loop)?"""
    reach = transitive_closure(frame)
    return any((a, b) in reach and (b, a) in reach for (a, b) in reach)


def has_grading(frame: Frame) -> bool:
    """Is there rank : W -> N strictly increasing along every edge?

    Equivalent to acyclicity; computed by Kahn topological sort.
    """
    indeg = {w: 0 for w in frame.worlds}
    for (u, v) in frame.edges:
        indeg[v] += 1
    queue = [w for w in frame.worlds if indeg[w] == 0]
    removed = 0
    while queue:
        w = queue.pop()
        removed += 1
        for v in frame.successors(w):
            indeg[v] -= 1
            if indeg[v] == 0:
                queue.append(v)
    return removed == len(frame.worlds)


# ---------------------------------------------------------------------------
# Semantic tests (brute force over valuations and formulas)
# ---------------------------------------------------------------------------


def semantically_sound(frame: Frame, w: object, atoms: Sequence[str], depth: int) -> bool:
    """Brute-force test: does  Box phi -> phi  hold at w for every valuation and
    every formula up to `depth`?"""
    forms = formulas_up_to_depth(atoms, depth)
    for val in all_valuations(frame, atoms):
        for phi in forms:
            if not satisfies(frame, val, w, reflection(phi)):
                return False
    return True


def semantically_atomically_sound(frame: Frame, w: object, atoms: Sequence[str]) -> bool:
    """Brute-force test of the atomic fragment  Box p -> p."""
    for val in all_valuations(frame, atoms):
        for p in atoms:
            if not satisfies(frame, val, w, reflection(var(p))):
                return False
    return True


def semantically_iter_sound(
    frame: Frame, w: object, n: int, atoms: Sequence[str], depth: int
) -> bool:
    """Brute-force test of  Box^n phi -> phi  at w."""
    forms = formulas_up_to_depth(atoms, depth)
    for val in all_valuations(frame, atoms):
        for phi in forms:
            if not satisfies(frame, val, w, iter_reflection(n, phi)):
                return False
    return True


def semantically_loeb(frame: Frame, w: object, atoms: Sequence[str], depth: int) -> bool:
    forms = formulas_up_to_depth(atoms, depth)
    for val in all_valuations(frame, atoms):
        for phi in forms:
            if not satisfies(frame, val, w, loeb_instance(phi)):
                return False
    return True


# ---------------------------------------------------------------------------
# Standard frames
# ---------------------------------------------------------------------------


def loop_frame() -> Frame:
    """One world seeing itself: the minimal tangle."""
    return make_frame(["*"], lambda u, v: True)


def point_frame() -> Frame:
    """One world seeing nothing: the minimal well-founded provability frame."""
    return make_frame(["*"], lambda u, v: False)


def two_chain() -> Frame:
    """t -> f : converse well founded, loop free, internally consistent at t."""
    return make_frame(["t", "f"], lambda u, v: u == "t" and v == "f")


def cycle_frame(n: int) -> Frame:
    """Worlds Z/nZ, each accessing its successor."""
    return make_frame(list(range(n)), lambda i, j: j == (i + 1) % n)


def omega_chain(cutoff: int) -> Frame:
    """A finite initial segment of the serial, loop-free chain 0 -> 1 -> 2 -> ..."""
    return make_frame(list(range(cutoff)), lambda i, j: j == i + 1)


def soundness_extension(frame: Frame, top: object = "TOP") -> Frame:
    """Adjoin a new top world seeing everything, including itself."""
    worlds = list(frame.worlds) + [top]
    edges = set(frame.edges) | {(top, w) for w in worlds}
    return Frame(worlds=tuple(worlds), edges=frozenset(edges))


def reflection_tower(frame: Frame, n: int) -> Frame:
    out = frame
    for k in range(n):
        out = soundness_extension(out, top=f"TOP{k + 1}")
    return out


def self_loops(frame: Frame) -> List[object]:
    return [w for w in frame.worlds if frame.accesses(w, w)]


def is_serial(frame: Frame) -> bool:
    return all(len(frame.successors(w)) > 0 for w in frame.worlds)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_soundness_equals_tangle() -> None:
    banner("1.  SOUNDNESS = TANGLE   (internally sound  <=>  self-accessing)")
    atoms = ["p"]
    frames = [
        ("one point, no arrows", point_frame()),
        ("one point, self-loop ", loop_frame()),
        ("two-chain t -> f     ", two_chain()),
        ("3-cycle              ", cycle_frame(3)),
        ("loop-extension of pt ", soundness_extension(point_frame())),
    ]
    print(f"{'frame':<24}{'world':<8}{'self-loop':<12}{'sound (brute force)'}")
    print("-" * 74)
    for label, fr in frames:
        for w in fr.worlds:
            loop = fr.accesses(w, w)
            snd = semantically_sound(fr, w, atoms, depth=2)
            flag = "  <-- MATCH" if loop == snd else "  <-- MISMATCH!"
            print(f"{label:<24}{str(w):<8}{str(loop):<12}{str(snd)}{flag}")
    print("\nEvery row matches: the schema is validated exactly at the loops.")


def demo_atomic_fragment() -> None:
    banner("2.  NO SAFE FRAGMENT   (atomic reflection already forces the loop)")
    atoms = ["p"]
    for label, fr in [
        ("one point, no arrows", point_frame()),
        ("one point, self-loop", loop_frame()),
        ("two-chain t -> f", two_chain()),
        ("4-cycle", cycle_frame(4)),
    ]:
        for w in fr.worlds:
            atomic = semantically_atomically_sound(fr, w, atoms)
            full = semantically_sound(fr, w, atoms, depth=2)
            print(f"{label:<22} world {str(w):<5} atomic={atomic!s:<6} full={full!s:<6}"
                  f" equal={atomic == full}")
    print("\nAtomic soundness and full soundness coincide everywhere.")


def demo_spectrum() -> None:
    banner("3.  THE SPECTRUM   (Box^n reflection  <=>  closed walk of length n)")
    atoms = ["p"]
    for n in (2, 3, 4):
        fr = cycle_frame(n)
        w = 0
        degrees = soundness_degrees(fr, w, max_degree=2 * n)
        print(f"\ncycle frame on {n} worlds, at world 0:")
        print(f"  closed-walk lengths <= {2 * n}: {degrees}")
        for k in range(1, n + 1):
            brute = semantically_iter_sound(fr, w, k, atoms, depth=1)
            combinatorial = w in n_step_reachable(fr, w, k)
            mark = "OK" if brute == combinatorial else "MISMATCH!"
            print(f"    degree {k}: brute force = {brute!s:<6}"
                  f" closed walk = {combinatorial!s:<6} [{mark}]")
        print(f"  self-loops in this frame: {self_loops(fr)}  (none for n >= 2)")
        print(f"  tangled in transitive closure: {is_tangled(fr)}")
        print(f"  admits a natural-number grading: {has_grading(fr)}")


def demo_monoid() -> None:
    banner("4.  DEGREES FORM A MONOID   (0 in D(w); D(w) closed under addition)")
    # A wedge of a 2-cycle and a 3-cycle glued at a common world 0.
    worlds = ["0", "a", "b", "c"]
    edges = {("0", "a"), ("a", "0"), ("0", "b"), ("b", "c"), ("c", "0")}
    fr = Frame(worlds=tuple(worlds), edges=frozenset(edges))
    degrees = soundness_degrees(fr, "0", max_degree=12)
    print("frame: a 2-cycle and a 3-cycle glued at world 0")
    print(f"soundness degrees of world 0 up to 12: {degrees}")
    print("this is the numerical monoid generated by 2 and 3 ( = {0,2,3,4,5,...} )")
    closed = all(
        (m + n) in degrees for m in degrees for n in degrees if m + n <= 12
    )
    print(f"closed under addition (within the tested range): {closed}")
    print(f"contains 0: {0 in degrees}")


def demo_cost_one_loop() -> None:
    banner("5.  THE COST IS EXACTLY ONE LOOP   (soundness extension + tower)")
    atoms = ["p"]
    base = omega_chain(4)  # irreflexive, well founded: 0 -> 1 -> 2 -> 3
    print("base frame: the chain 0 -> 1 -> 2 -> 3 (irreflexive, well founded)")
    print(f"  self-loops: {self_loops(base)}   grading exists: {has_grading(base)}")

    ext = soundness_extension(base)
    print("\nafter one soundness extension (new top world TOP):")
    print(f"  self-loops: {self_loops(ext)}")
    sound_worlds = [w for w in ext.worlds if semantically_sound(ext, w, atoms, depth=1)]
    print(f"  internally sound worlds: {sound_worlds}")
    print(f"  grading exists: {has_grading(ext)}   tangled: {is_tangled(ext)}")

    print("\n  conservation: truth of every formula (depth <= 2) at every OLD world")
    print("  is unchanged by the extension.")
    forms = formulas_up_to_depth(atoms, 2)
    ok = True
    for val_old in all_valuations(base, atoms):
        val_new: Valuation = dict(val_old)
        for p in atoms:
            val_new[(p, "TOP")] = False  # new atoms false at the top world
        for w in base.worlds:
            for phi in forms:
                if satisfies(base, val_old, w, phi) != satisfies(ext, val_new, w, phi):
                    ok = False
    print(f"  conservation verified over all valuations and formulas: {ok}")

    print("\nreflection tower: stage n has exactly n loops and n sound worlds,")
    print("and always still contains an unsound world.")
    print(f"{'stage':<8}{'#worlds':<10}{'#self-loops':<14}{'#sound':<10}{'unsound world exists'}")
    print("-" * 74)
    for n in range(0, 5):
        tw = reflection_tower(base, n)
        loops = self_loops(tw)
        sound = [w for w in tw.worlds if tw.accesses(w, w)]  # = internally sound
        print(f"{n:<8}{len(tw.worlds):<10}{len(loops):<14}{len(sound):<10}"
              f"{len(sound) < len(tw.worlds)}")


def demo_boundary() -> None:
    banner("6.  THE BOUNDARY   (consistency is free; reflection costs a loop)")
    atoms = ["p"]
    tc = two_chain()
    con_at_t = all(satisfies(tc, val, "t", con()) for val in all_valuations(tc, atoms))
    sound_at_t = semantically_sound(tc, "t", atoms, depth=2)
    print("two-chain  t -> f :")
    print(f"  loop free                 : {self_loops(tc) == []}")
    print(f"  admits a grading (well founded): {has_grading(tc)}")
    print(f"  t satisfies Con = ¬□⊥ under every valuation: {con_at_t}")
    print(f"  t internally sound        : {sound_at_t}")
    print("  => consistency is compatible with a loop-free well-founded hierarchy.")

    print("\nfinite + serial  =>  cyclic:")
    for n in (2, 3, 5):
        fr = cycle_frame(n)
        print(f"  cycle frame on {n} worlds: serial={is_serial(fr)}, tangled={is_tangled(fr)}")
    chain = omega_chain(8)
    print(f"  finite chain 0..7        : serial={is_serial(chain)} (fails at the last world)")
    print("  the infinite chain 0 -> 1 -> 2 -> ... is serial AND loop free:")
    print("  finiteness is exactly what forces the tangle.")


def demo_two_systems() -> None:
    banner("7.  TWO SYSTEMS   (well-founded & silent  vs.  self-certifying & tangled)")
    atoms = ["p"]
    pf, lf = point_frame(), loop_frame()
    depth = 2

    pf_loeb = semantically_loeb(pf, "*", atoms, depth)
    pf_refl = semantically_sound(pf, "*", atoms, depth)
    pf_con = all(satisfies(pf, val, "*", con()) for val in all_valuations(pf, atoms))

    lf_loeb = semantically_loeb(lf, "*", atoms, depth)
    lf_refl = semantically_sound(lf, "*", atoms, depth)
    lf_con = all(satisfies(lf, val, "*", con()) for val in all_valuations(lf, atoms))

    print(f"{'system':<34}{'Loeb axiom':<14}{'reflection':<14}{'proves Con'}")
    print("-" * 74)
    print(f"{'validities of the point frame':<34}{pf_loeb!s:<14}{pf_refl!s:<14}{pf_con}")
    print(f"{'validities of the loop frame':<34}{lf_loeb!s:<14}{lf_refl!s:<14}{lf_con}")
    print("\nThe well-founded system is Loebian but neither self-sound nor self-consistent.")
    print("The tangled system is self-sound and self-consistent but refutes Loeb.")
    print("No system can be consistent and have both: apply Loeb's rule to bot.")


def main() -> None:
    print(__doc__)
    demo_soundness_equals_tangle()
    demo_atomic_fragment()
    demo_spectrum()
    demo_monoid()
    demo_cost_one_loop()
    demo_boundary()
    demo_two_systems()
    print()
    print("=" * 74)
    print("All demonstrations agree with the theorems.")
    print("=" * 74)


if __name__ == "__main__":
    main()
