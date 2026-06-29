"""
Retrocausal Mathematics: Where Effects Precede Causes
=====================================================

Self-contained numerical demonstrations of the results formalized in the
project's Lean development:

  * Retrocausal Heyting algebras: an order-reversing involution `rev` with
        (R1) rev(rev a) = a            (involution)
        (R2) a <= b  =>  rev b <= rev a (antitone)
    automatically satisfies the De Morgan laws and swaps the truth poles.

  * The law of excluded middle (LEM)  `a v ~a = top`  FAILS in genuine
    (non-Boolean) Heyting algebras (three-element chain witness).

  * The temporal excluded middle (TEM)  `~~(a v ~a) = top`  HOLDS in EVERY
    Heyting algebra (Glivenko, read temporally).

  * LEM at `a`  <=>  double-negation elimination `~~a = a` at `a`
    (so any non-Boolean retrocausal logic is intuitionistic).

  * CPT bridge: an Osterwalder-Schrader time reflection `theta` (theta o theta = id)
    composed with complement gives `cptReversal S = theta^{-1}(S^c)`, an
    order-reversing involution on the powerset, i.e. a retrocausal Heyting algebra.

Run:  python demo.py
No third-party dependencies; pure standard library.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Part I. Finite Heyting algebras given by a partial order on {0, ..., n-1}.
#         Convention: 0 = bottom, n-1 = top, and `leq[a][b]` is the order.
# ---------------------------------------------------------------------------

class FiniteHeyting:
    """A finite Heyting algebra specified by its order relation.

    Elements are integers 0..n-1.  `leq` is the reflexive/transitive order
    matrix.  Meet/join are computed from the order; pseudo-complement is
    a^c = join{ x : x meet a = bottom }.
    """

    def __init__(self, n: int, leq: Sequence[Sequence[bool]]) -> None:
        self.n: int = n
        self.leq: List[List[bool]] = [list(row) for row in leq]
        self.bot: int = 0
        self.top: int = n - 1
        self._meet: Dict[Tuple[int, int], int] = {}
        self._join: Dict[Tuple[int, int], int] = {}
        self._precompute()

    def _precompute(self) -> None:
        for a in range(self.n):
            for b in range(self.n):
                self._meet[(a, b)] = self._glb(a, b)
                self._join[(a, b)] = self._lub(a, b)

    def _glb(self, a: int, b: int) -> int:
        # greatest lower bound: the largest x with x <= a and x <= b
        lowers = [x for x in range(self.n) if self.leq[x][a] and self.leq[x][b]]
        return max(lowers, key=lambda x: sum(self.leq[y][x] for y in range(self.n)))

    def _lub(self, a: int, b: int) -> int:
        uppers = [x for x in range(self.n) if self.leq[a][x] and self.leq[b][x]]
        return min(uppers, key=lambda x: sum(self.leq[y][x] for y in range(self.n)))

    def meet(self, a: int, b: int) -> int:
        return self._meet[(a, b)]

    def join(self, a: int, b: int) -> int:
        return self._join[(a, b)]

    def compl(self, a: int) -> int:
        """Pseudo-complement a^c = join{ x : x meet a = bottom }."""
        candidates = [x for x in range(self.n) if self.meet(x, a) == self.bot]
        result = self.bot
        for x in candidates:
            result = self.join(result, x)
        return result

    def dneg(self, a: int) -> int:
        """Double pseudo-complement a^cc."""
        return self.compl(self.compl(a))

    def lem(self, a: int) -> int:
        """Excluded-middle element  a v a^c."""
        return self.join(a, self.compl(a))

    def tem(self, a: int) -> int:
        """Temporal excluded middle element  (a v a^c)^cc."""
        return self.dneg(self.lem(a))


def three_element_chain() -> FiniteHeyting:
    """The Heyting algebra  bottom (0) < m (1) < top (2)."""
    leq = [[True, True, True],   # 0 <= 0,1,2
           [False, True, True],  # 1 <= 1,2
           [False, False, True]] # 2 <= 2
    return FiniteHeyting(3, leq)


def boolean_square() -> FiniteHeyting:
    """The 4-element Boolean algebra 2x2:  0 < {a,b} < 1, with a,b incomparable."""
    # elements: 0=bot, 1=a, 2=b, 3=top
    leq = [[True, True, True, True],
           [False, True, False, True],
           [False, False, True, True],
           [False, False, False, True]]
    return FiniteHeyting(4, leq)


# ---------------------------------------------------------------------------
# Part II. Retrocausal involution on a finite lattice and its laws.
# ---------------------------------------------------------------------------

def is_involution(H: FiniteHeyting, rev: Callable[[int], int]) -> bool:
    return all(rev(rev(a)) == a for a in range(H.n))


def is_antitone(H: FiniteHeyting, rev: Callable[[int], int]) -> bool:
    return all(
        (not H.leq[a][b]) or H.leq[rev(b)][rev(a)]
        for a in range(H.n) for b in range(H.n)
    )


def check_de_morgan(H: FiniteHeyting, rev: Callable[[int], int]) -> bool:
    """rev(a v b) = rev a ^ rev b  and  rev(a ^ b) = rev a v rev b."""
    ok = True
    for a, b in product(range(H.n), repeat=2):
        ok &= rev(H.join(a, b)) == H.meet(rev(a), rev(b))
        ok &= rev(H.meet(a, b)) == H.join(rev(a), rev(b))
    return ok


def check_pole_swap(H: FiniteHeyting, rev: Callable[[int], int]) -> bool:
    return rev(H.bot) == H.top and rev(H.top) == H.bot


# ---------------------------------------------------------------------------
# Part III. CPT reversal on a finite configuration space.
#           Propositions are frozensets of configurations.
# ---------------------------------------------------------------------------

def cpt_reversal(
    universe: FrozenSet[int],
    theta: Callable[[int], int],
    S: FrozenSet[int],
) -> FrozenSet[int]:
    """cptReversal S = theta^{-1}(S^c) = { v : theta(v) not in S }."""
    return frozenset(v for v in universe if theta(v) not in S)


def all_subsets(universe: Sequence[int]) -> List[FrozenSet[int]]:
    subsets: List[FrozenSet[int]] = []
    for bits in product([False, True], repeat=len(universe)):
        subsets.append(frozenset(u for u, b in zip(universe, bits) if b))
    return subsets


def check_cpt_laws(universe: FrozenSet[int], theta: Callable[[int], int]) -> Dict[str, bool]:
    """Verify involutivity, antitonicity, De Morgan, pole swap for cptReversal."""
    subs = all_subsets(sorted(universe))
    rev = lambda S: cpt_reversal(universe, theta, S)

    involutive = all(rev(rev(S)) == S for S in subs)
    antitone = all(
        (not S <= T) or (rev(T) <= rev(S))
        for S in subs for T in subs
    )
    de_morgan = all(
        rev(S | T) == (rev(S) & rev(T)) and rev(S & T) == (rev(S) | rev(T))
        for S in subs for T in subs
    )
    pole_swap = rev(frozenset()) == universe and rev(universe) == frozenset()
    return {
        "involutive": involutive,
        "antitone": antitone,
        "de_morgan": de_morgan,
        "pole_swap": pole_swap,
    }


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def main() -> None:
    names = {0: "bottom", 1: "m", 2: "top"}

    banner("1. THREE-ELEMENT CHAIN: LEM FAILS, TEM HOLDS")
    C = three_element_chain()
    print("Elements: 0=bottom < 1=m < 2=top,  with  m^c =", C.compl(1), "(= bottom)")
    for a in range(C.n):
        lem = C.lem(a)
        tem = C.tem(a)
        print(
            f"  a={names[a]:>6}:  a v a^c = {names[lem]:>6} "
            f"(LEM {'HOLDS' if lem == C.top else 'FAILS'}),  "
            f"(a v a^c)^cc = {names[tem]:>6} "
            f"(TEM {'HOLDS' if tem == C.top else 'FAILS'})"
        )
    print("  => LEM fails at m, but the temporal excluded middle holds everywhere.")

    banner("2. LEM <=> DNE  (pointwise) on the three-element chain")
    for a in range(C.n):
        lem_holds = C.lem(a) == C.top
        dne_holds = C.dneg(a) == a
        print(
            f"  a={names[a]:>6}:  (a v a^c = top) = {lem_holds!s:>5},  "
            f"(a^cc = a) = {dne_holds!s:>5}   ->  equivalent: {lem_holds == dne_holds}"
        )
    print("  => LEM and double-negation elimination agree elementwise.")

    banner("3. BOOLEAN ALGEBRA: LEM HOLDS EVERYWHERE (sanity check)")
    B = boolean_square()
    lem_all = all(B.lem(a) == B.top for a in range(B.n))
    print(f"  4-element Boolean algebra: LEM holds for all elements = {lem_all}")

    banner("4. RETROCAUSAL INVOLUTION rev (swap bottom/top, fix m) AND ITS LAWS")
    rev = lambda a: {0: 2, 1: 1, 2: 0}[a]
    print(f"  involution (R1):       {is_involution(C, rev)}")
    print(f"  antitone   (R2):       {is_antitone(C, rev)}")
    print(f"  De Morgan laws:        {check_de_morgan(C, rev)}")
    print(f"  pole swap bottom<->top:{check_pole_swap(C, rev)}")
    print("  => Two axioms (R1)+(R2) already force all De Morgan / pole-swap laws.")

    banner("5. CPT BRIDGE: theta-reflection composed with complement on Set V")
    universe = frozenset({0, 1, 2, 3})
    # An Osterwalder-Schrader-style time reflection: an involution on configurations.
    theta_map = {0: 1, 1: 0, 2: 3, 3: 2}  # theta o theta = id
    theta = lambda v: theta_map[v]
    print(f"  V = {sorted(universe)},  theta = {theta_map}  (theta o theta = id)")
    laws = check_cpt_laws(universe, theta)
    for name, ok in laws.items():
        print(f"  cptReversal {name:<12}: {ok}")
    S = frozenset({0, 2})
    rS = cpt_reversal(universe, theta, S)
    print(f"  example: S={sorted(S)},  cptReversal S = theta^-1(S^c) = {sorted(rS)}")
    print(f"           cptReversal(cptReversal S) = "
          f"{sorted(cpt_reversal(universe, theta, rS))}  (= S)")
    print("  => The QFT time reflection yields a retrocausal Heyting structure.")

    banner("SUMMARY")
    print("  * LEM fails in the genuine (non-Boolean) Heyting algebra.")
    print("  * The temporal excluded middle holds universally.")
    print("  * LEM <=> DNE, so retrocausal (non-Boolean) logic must be intuitionistic.")
    print("  * CPT's time reflection is a canonical retrocausal involution.")


if __name__ == "__main__":
    main()


"""
Visualization: the retrocausal landscape of a finite Heyting chain.
===================================================================

Generates a figure with two panels:

  (left)  the n-element Heyting chain bottom < ... < top, showing for each
          element a the values of  a v a^c (LEM) and (a v a^c)^cc (TEM),
          highlighting where the law of excluded middle fails while the
          temporal excluded middle persists;

  (right) the action of the retrocausal involution rev on the chain as an
          order-reversing permutation (a "time-reversal" arrow diagram).

Run:  python visualize.py   ->  writes retrocausal_landscape.png
Requires: matplotlib.
"""

from __future__ import annotations

from typing import List
import matplotlib.pyplot as plt


def chain_compl(i: int, n: int) -> int:
    """Pseudo-complement in the n-chain 0 < 1 < ... < n-1:
    a^c = top if a = bottom, else bottom."""
    return n - 1 if i == 0 else 0


def chain_lem(i: int, n: int) -> int:
    return max(i, chain_compl(i, n))


def chain_dneg(i: int, n: int) -> int:
    return chain_compl(chain_compl(i, n), n)


def chain_tem(i: int, n: int) -> int:
    return chain_dneg(chain_lem(i, n), n)


def main() -> None:
    n: int = 5
    elements: List[int] = list(range(n))

    fig, (axL, axR) = plt.subplots(1, 2, figsize=(13, 6))

    # ---- Left: LEM vs TEM per element -------------------------------------
    lem_vals = [chain_lem(i, n) for i in elements]
    tem_vals = [chain_tem(i, n) for i in elements]
    lem_fail = [i for i in elements if chain_lem(i, n) != n - 1]

    axL.plot(elements, lem_vals, "o-", color="#c0392b", label="a v a^c  (LEM)")
    axL.plot(elements, tem_vals, "s--", color="#2980b9", label="(a v a^c)^cc  (TEM)")
    axL.axhline(n - 1, color="gray", lw=0.8, ls=":")
    for i in lem_fail:
        axL.annotate("LEM fails", (i, chain_lem(i, n)),
                     textcoords="offset points", xytext=(0, -22),
                     ha="center", color="#c0392b", fontsize=9)
    axL.set_xticks(elements)
    axL.set_xlabel("element a  (0 = bottom, %d = top)" % (n - 1))
    axL.set_ylabel("value in the chain")
    axL.set_title("Excluded middle dies, temporal excluded middle survives")
    axL.legend(loc="lower right")
    axL.grid(alpha=0.3)

    # ---- Right: rev as order-reversing involution -------------------------
    rev = [n - 1 - i for i in elements]
    axR.set_xlim(-0.5, 1.5)
    axR.set_ylim(-0.5, n - 0.5)
    for i in elements:
        axR.scatter([0], [i], s=120, color="#27ae60")
        axR.scatter([1], [i], s=120, color="#8e44ad")
        axR.annotate("", xy=(1, rev[i]), xytext=(0, i),
                     arrowprops=dict(arrowstyle="->", color="#7f8c8d", lw=1.2))
        axR.text(-0.15, i, f"{i}", ha="right", va="center")
        axR.text(1.15, i, f"{i}", ha="left", va="center")
    axR.text(0, n - 0.3, "a", ha="center", fontsize=12, weight="bold")
    axR.text(1, n - 0.3, "rev a", ha="center", fontsize=12, weight="bold")
    axR.set_title("Time-reversal rev: order-reversing involution")
    axR.axis("off")

    fig.suptitle("The Retrocausal Landscape of a Heyting Chain", fontsize=14)
    fig.tight_layout()
    fig.savefig("retrocausal_landscape.png", dpi=150)
    print("wrote retrocausal_landscape.png")


if __name__ == "__main__":
    main()
