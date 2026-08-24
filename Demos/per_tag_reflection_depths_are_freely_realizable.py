"""
Heights and reflection depths of tags in finite provability models
==================================================================

This script is a self-contained numerical companion to the article and paper
"Two Cut Points, One Chain: Heights and Reflection Depths of Provability Tags".

It implements, from scratch:

  *  the language of multi-tag modal formulas (bottom, atoms, implication and
     one box operator per tag),
  *  Kripke semantics on the finite chain of worlds 0, 1, ..., N in which each
     tag i carries its own accessibility relation R_i, restricted to strictly
     descending steps, together with a valuation V,
  *  the truncated theory of such a model (a formula is a theorem iff it is
     true at every world 0..N),
  *  the two numerical invariants of a tag:
         - the inconsistency height  H_i  (the least k with box_i^{k+1} bot a
           theorem, i.e. the length of the longest R_i-chain visible),
         - the reflection depth      rho_i (the largest r such that every
           formula of box depth < r that is provably necessary at i is itself
           a theorem),
  *  the two frame families of the paper: the *truncated* frames (tag i looks
     down from every world m <= c_i, and sees all of them) and the *window*
     frames (tag i looks down only from worlds m <= H_i and only onto worlds
     n >= b_i),
  *  the rigidity theorem, the height-gap inequality, the low-tag collapse,
     the exact two-valued spectrum, and the decoupling family that separates
     the reflection depths of two tags of equal height.

The reflection depth is computed exactly, without enumerating formulas, using
the depth-k modal type refinement described in the paper: a tag reflects to
depth r iff every world of the model is depth-(r-1) equivalent to some world
in the image of that tag's accessibility relation.

Run with:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, List, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# 1.  Formulas
# ---------------------------------------------------------------------------

Formula = Tuple  # ('bot',) | ('atom', p) | ('imp', a, b) | ('box', i, a)

BOT: Formula = ("bot",)


def atom(p: int) -> Formula:
    """The propositional atom number `p`."""
    return ("atom", p)


def imp(a: Formula, b: Formula) -> Formula:
    """Material implication `a -> b`."""
    return ("imp", a, b)


def box(i: int, a: Formula) -> Formula:
    """The box of tag `i` applied to `a`."""
    return ("box", i, a)


def neg(a: Formula) -> Formula:
    """Negation, encoded as `a -> bot`."""
    return imp(a, BOT)


def box_pow(i: int, k: int, a: Formula) -> Formula:
    """The `k`-fold iterated box of tag `i`."""
    out = a
    for _ in range(k):
        out = box(i, out)
    return out


def box_depth(a: Formula) -> int:
    """Maximal nesting depth of boxes."""
    head = a[0]
    if head in ("bot", "atom"):
        return 0
    if head == "imp":
        return max(box_depth(a[1]), box_depth(a[2]))
    return box_depth(a[2]) + 1


def show(a: Formula) -> str:
    """Human-readable rendering of a formula."""
    head = a[0]
    if head == "bot":
        return "⊥"
    if head == "atom":
        return f"p{a[1]}"
    if head == "imp":
        if a[2] == BOT:
            return f"¬{show(a[1])}"
        return f"({show(a[1])} → {show(a[2])})"
    return f"□{a[1]}{show(a[2])}"


# ---------------------------------------------------------------------------
# 2.  Models: a tag-indexed frame plus a valuation, truncated at N
# ---------------------------------------------------------------------------

Frame = Callable[[int, int, int], bool]      # (tag, source world, target world)
Valuation = Callable[[int, int], bool]       # (world, atom)


@dataclass(frozen=True)
class Model:
    """A finite tag-indexed Kripke model on the worlds 0, ..., N."""

    R: Frame
    V: Valuation
    N: int
    tags: Tuple[int, ...]
    atoms: Tuple[int, ...] = (0,)

    def worlds(self) -> range:
        return range(self.N + 1)

    def sees(self, i: int, m: int, n: int) -> bool:
        """World `m` sees world `n` at tag `i` (only strictly downwards)."""
        return n < m and self.R(i, m, n)

    def successors(self, i: int, m: int) -> List[int]:
        return [n for n in range(m) if self.R(i, m, n)]

    # -- satisfaction ------------------------------------------------------

    def sat(self, m: int, a: Formula) -> bool:
        head = a[0]
        if head == "bot":
            return False
        if head == "atom":
            return self.V(m, a[1])
        if head == "imp":
            return (not self.sat(m, a[1])) or self.sat(m, a[2])
        i = a[1]
        return all(self.sat(n, a[2]) for n in self.successors(i, m))

    def provable(self, a: Formula) -> bool:
        """`a` is a theorem of the truncated theory: true at every world <= N."""
        return all(self.sat(m, a) for m in self.worlds())

    def consistent(self) -> bool:
        return not self.provable(BOT)

    # -- images ------------------------------------------------------------

    def image(self, i: int) -> FrozenSet[int]:
        """The set of worlds seen by *some* world of the model at tag `i`."""
        return frozenset(
            n for m in self.worlds() for n in range(m) if self.R(i, m, n)
        )

    # -- invariants --------------------------------------------------------

    def inconsistency_height(self, i: int, cap: int | None = None) -> int:
        """Least `H` with `box_i^{H+1} bot` a theorem (the tag's height)."""
        cap = self.N + 2 if cap is None else cap
        for k in range(cap + 2):
            if self.provable(box_pow(i, k + 1, BOT)):
                return k
        return cap + 1

    def depth_types(self, k: int) -> Dict[int, object]:
        """The depth-`k` modal type of every world, by partition refinement.

        Depth 0: the valuation pattern.  Depth k+1: the depth-0 pattern
        together with, for every tag, the set of depth-`k` types of the
        successors at that tag.
        """
        types: Dict[int, object] = {
            m: tuple(self.V(m, p) for p in self.atoms) for m in self.worlds()
        }
        for _ in range(k):
            nxt: Dict[int, object] = {}
            for m in self.worlds():
                succ = tuple(
                    (i, frozenset(types[n] for n in self.successors(i, m)))
                    for i in self.tags
                )
                nxt[m] = (types[m], succ)
            types = nxt
        return types

    def reflects_to_depth(self, i: int, r: int) -> bool:
        """Does every formula of box depth `< r` provably necessary at `i`
        follow?  Equivalently: is every world depth-(r-1) equivalent to some
        world in the image of tag `i`?"""
        if r == 0:
            return True
        types = self.depth_types(r - 1)
        img = self.image(i)
        realized = {types[n] for n in img}
        return all(types[m] in realized for m in self.worlds())

    def reflection_depth(self, i: int, cap: int = 12) -> int:
        """Largest `r <= cap` with `reflects_to_depth(i, r)`."""
        r = 0
        while r < cap and self.reflects_to_depth(i, r + 1):
            r += 1
        return r


# ---------------------------------------------------------------------------
# 3.  The two frame families
# ---------------------------------------------------------------------------


def truncated_frame(c: Sequence[int]) -> Frame:
    """Tag `i` looks down from every world `m <= c_i`, and sees all of them.

    Its image is the initial segment [0, min(N, c_i)); such images are always
    nested, which is exactly the source of the rigidity phenomenon.
    """
    return lambda i, m, n: m <= c[i]


def window_frame(b: Sequence[int], H: Sequence[int]) -> Frame:
    """Tag `i` looks down from the worlds `m <= H_i`, onto the worlds `n >= b_i`.

    Its image is the interval [b_i, min(N, H_i)); such intervals can be
    incomparable, which is what makes decoupling possible.
    """
    return lambda i, m, n: m <= H[i] and n >= b[i]


def flat_valuation() -> Valuation:
    """No atom is ever true: worlds can only be separated by counting steps."""
    return lambda m, p: False


def block_valuation(t: int) -> Valuation:
    """Every atom is true exactly at the worlds strictly below `t`."""
    return lambda m, p: m < t


# ---------------------------------------------------------------------------
# 4.  Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_semantics() -> None:
    banner("1.  A first model: heights, images, reflection depths")
    N = 4
    c = [4, 2, 0]
    model = Model(truncated_frame(c), block_valuation(2), N, tags=(0, 1, 2))
    print(f"worlds 0..{N},  truncated frame with cuts c = {c},")
    print("valuation: the atom p0 is true exactly at the worlds 0 and 1.\n")
    print(f"{'tag':>4} {'image':>16} {'height':>8} {'reflection depth':>18}")
    for i in model.tags:
        img = sorted(model.image(i))
        print(
            f"{i:>4} {str(img):>16} {model.inconsistency_height(i):>8}"
            f" {model.reflection_depth(i):>18}"
        )
    print("\nsample theorems:")
    for f in [box_pow(0, 5, BOT), box_pow(1, 3, BOT), box(2, BOT), atom(0)]:
        print(f"   {show(f):<12} provable? {model.provable(f)}")


def demo_rigidity() -> None:
    banner("2.  Rigidity: equal truncated heights force equal reflection depths")
    print("Exhaustive check over truncated frames on 0..N with three tags and")
    print("all block valuations: whenever min(N, c_i) = min(N, c_j) the two")
    print("reflection depths agree -- for every valuation.\n")
    violations = 0
    checked = 0
    for N in range(1, 5):
        for c in product(range(N + 2), repeat=3):
            for t in range(N + 2):
                model = Model(truncated_frame(list(c)), block_valuation(t), N,
                              tags=(0, 1, 2))
                depths = [model.reflection_depth(i) for i in model.tags]
                for i in range(3):
                    for j in range(3):
                        if min(N, c[i]) == min(N, c[j]):
                            checked += 1
                            if depths[i] != depths[j]:
                                violations += 1
    print(f"pairs of equal-height tags checked : {checked}")
    print(f"violations of rigidity found       : {violations}")
    assert violations == 0


def demo_gap_bound() -> None:
    banner("3.  The height-gap inequality and the low-tag collapse")
    print("If min(N, c_j) < min(N, c_i) then, in a truncated model,")
    print("     rho_i <= min(N, c_i) - min(N, c_j)     and     rho_j <= 1.")
    print("The witness for the first bound is the gap probe")
    print("     □_i^{gap-1} (□_j ⊥ → □_i ⊥),   of box depth exactly the gap.\n")
    bad = 0
    for N in range(1, 6):
        for c in product(range(N + 1), repeat=2):
            for t in range(N + 2):
                model = Model(truncated_frame(list(c)), block_valuation(t), N,
                              tags=(0, 1))
                rho = [model.reflection_depth(i) for i in model.tags]
                hi, hj = min(N, c[0]), min(N, c[1])
                if hj < hi and not (rho[0] <= hi - hj and rho[1] <= 1):
                    bad += 1
                if hi < hj and not (rho[1] <= hj - hi and rho[0] <= 1):
                    bad += 1
    print(f"counterexamples to either inequality: {bad}")
    assert bad == 0

    N, c = 5, [5, 2]
    model = Model(truncated_frame(c), flat_valuation(), N, tags=(0, 1))
    gap = min(N, c[0]) - min(N, c[1])
    probe = box_pow(0, gap - 1, imp(box(1, BOT), box(0, BOT)))
    print(f"\nexample N = {N}, c = {c}, gap = {gap}")
    print(f"   probe                     : {show(probe)}")
    print(f"   its box depth             : {box_depth(probe)}")
    print(f"   □_0(probe) provable?      : {model.provable(box(0, probe))}")
    print(f"   probe provable?           : {model.provable(probe)}")
    print(f"   measured rho_0            : {model.reflection_depth(0)}"
          f"   (predicted {gap})")
    print(f"   measured rho_1            : {model.reflection_depth(1)}"
          f"   (predicted 1)")


def demo_two_valued_spectrum() -> None:
    banner("4.  The exact spectrum of a two-valued height vector")
    print("Heights N (high tags) and L (low tags), 1 <= L < N, flat valuation.")
    print("Prediction: rho_high = N - L exactly, rho_low = 1 exactly.\n")
    print(f"{'N':>3} {'L':>3} {'rho_high':>10} {'N-L':>6} {'rho_low':>9}")
    ok = True
    for N in range(2, 9):
        for L in range(1, N):
            model = Model(truncated_frame([N, L]), flat_valuation(), N,
                          tags=(0, 1))
            rh = model.reflection_depth(0)
            rl = model.reflection_depth(1)
            ok &= (rh == N - L and rl == 1)
            if N <= 6:
                print(f"{N:>3} {L:>3} {rh:>10} {N - L:>6} {rl:>9}")
    print(f"\nall predictions matched for 2 <= N <= 8: {ok}")
    assert ok


def demo_constant_profile() -> None:
    banner("5.  The uniform profile is realizable: rho = distance to the block")
    print("All tags of height N, block valuation with cut point N - rho:")
    print("the reflection depth is exactly the distance from the top of the")
    print("chain to the point where the valuation changes.\n")
    print(f"{'N':>3} {'cut':>5} {'measured rho':>14} {'N - cut':>9}")
    ok = True
    for N in range(1, 8):
        for cut in range(0, N + 1):
            model = Model(truncated_frame([N, N]), block_valuation(cut), N,
                          tags=(0, 1))
            rho = model.reflection_depth(0)
            ok &= (rho == N - cut)
            if N <= 5:
                print(f"{N:>3} {cut:>5} {rho:>14} {N - cut:>9}")
    print(f"\nall predictions matched for 1 <= N <= 7: {ok}")
    assert ok


def demo_decoupling_family() -> None:
    banner("6.  Decoupling: equal heights, different reflection depths")
    print("Window frame on the worlds 0..h+1:")
    print("   tag 0 looks down from the worlds m <= h and sees everything;")
    print("   tag 1 looks down from the worlds m <= h+1 but never sees world 0;")
    print("   the atom p0 is true exactly at the world 0.")
    print("Both tags have inconsistency height h, yet their reflection depths")
    print("are 1 and 0.  No truncated model can do this, by rigidity.\n")
    print(f"{'h':>3} {'H_0':>5} {'H_1':>5} {'rho_0':>7} {'rho_1':>7}"
          f" {'image of 0':>14} {'image of 1':>14}")
    for h in range(2, 7):
        b = [0, 1, 0]
        H = [h, h + 1, 0]
        model = Model(window_frame(b, H), block_valuation(1), h + 1,
                      tags=(0, 1, 2))
        print(
            f"{h:>3} {model.inconsistency_height(0):>5}"
            f" {model.inconsistency_height(1):>5}"
            f" {model.reflection_depth(0):>7} {model.reflection_depth(1):>7}"
            f" {str(sorted(model.image(0))):>14}"
            f" {str(sorted(model.image(1))):>14}"
        )
    h = 3
    model = Model(window_frame([0, 1, 0], [h, h + 1, 0]), block_valuation(1),
                  h + 1, tags=(0, 1, 2))
    im0, im1 = model.image(0), model.image(1)
    print(f"\nimages are incomparable at h = {h}: "
          f"{sorted(im0 - im1)} in image(0) only, "
          f"{sorted(im1 - im0)} in image(1) only.")
    print("separating formula for tag 1 (box depth 0):",
          show(neg(atom(0))),
          "-- necessary at tag 1, false at the root, hence not a theorem.")
    print("separating formula for tag 0 (box depth 1):",
          show(imp(box(0, BOT), box(1, BOT))),
          "-- necessary at tag 0, false at the top world.")


def demo_profile_census() -> None:
    banner("7.  Census of realizable profiles: truncated versus window frames")
    print("Two live tags and the truncation level N = 2.  A profile is a pair")
    print("((H_0, H_1), (rho_0, rho_1)) of truncated heights min(N, H_i) and")
    print("exact reflection depths.  We compare the profiles realized by")
    print("truncated models (any valuation) with those realized by window")
    print("models on up to five worlds, and with the profiles the naive")
    print("conjecture permits (rho_i <= H_i).\n")
    N = 2
    tags = (0, 1)

    def valuations(worlds: int) -> List[Valuation]:
        out: List[Valuation] = []
        for pattern in product([False, True], repeat=worlds + 1):
            out.append((lambda pat: (lambda m, p: pat[m]))(pattern))
        return out

    def profiles(frames, worlds: int
                 ) -> Set[Tuple[Tuple[int, int], Tuple[int, int]]]:
        found = set()
        for R in frames:
            for V in valuations(worlds):
                model = Model(R, V, worlds, tags=tags)
                if not model.consistent():
                    continue
                heights = tuple(min(N, model.inconsistency_height(i))
                                for i in tags)
                depths = tuple(model.reflection_depth(i, cap=N + 2)
                               for i in tags)
                found.add((heights, depths))
        return found

    trunc_frames = [truncated_frame(list(c))
                    for c in product(range(N + 1), repeat=2)]
    conjectured = {
        ((h0, h1), (r0, r1))
        for h0 in range(N + 1) for h1 in range(N + 1)
        for r0 in range(h0 + 1) for r1 in range(h1 + 1)
    }
    trunc = profiles(trunc_frames, N)
    win: Set[Tuple[Tuple[int, int], Tuple[int, int]]] = set()
    for worlds in range(N, N + 3):
        win |= profiles(
            [window_frame(list(b), list(H))
             for b in product(range(worlds + 2), repeat=2)
             for H in product(range(worlds + 2), repeat=2)],
            worlds,
        )
    print(f"profiles permitted by the naive conjecture : {len(conjectured)}")
    print(f"profiles realized by truncated models      : "
          f"{len(trunc & conjectured)}")
    print(f"profiles realized by window models         : "
          f"{len(win & conjectured)}")
    missing = sorted(conjectured - trunc)
    print(f"\nprofiles the truncated class misses ({len(missing)}):")
    for heights, depths in missing:
        reason: List[str] = []
        for i, j in ((0, 1), (1, 0)):
            if heights[i] < heights[j] and depths[i] > depths[j]:
                reason.append("monotonicity")
            if heights[j] < heights[i] and depths[i] > heights[i] - heights[j]:
                reason.append("gap bound")
            if heights[j] < heights[i] and depths[j] > 1:
                reason.append("low-tag collapse")
        if heights[0] == heights[1] and depths[0] != depths[1]:
            reason.append("rigidity")
        marker = "yes" if (heights, depths) in win else " no"
        print(f"   heights {heights}, depths {depths}"
              f"   blocked by: {', '.join(sorted(set(reason))):<40}"
              f" window model? {marker}")
    recovered = sorted((conjectured - trunc) & win)
    print(f"\nprofiles beyond the truncated class that window frames "
          f"do realize ({len(recovered)}):")
    for heights, depths in recovered:
        print(f"   heights {heights}, depths {depths}")


def main() -> None:
    demo_semantics()
    demo_rigidity()
    demo_gap_bound()
    demo_two_valued_spectrum()
    demo_constant_profile()
    demo_decoupling_family()
    demo_profile_census()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
