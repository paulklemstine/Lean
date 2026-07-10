"""
Combinatorial Fixed Points and Nash Equilibria: numerical demonstrations.

This self-contained script demonstrates, with concrete numbers, the results of the
accompanying paper:

  1. The one-dimensional Sperner lemma (parity of fully colored edges).
  2. The discrete intermediate value theorem and discrete Brouwer fixed point.
  3. Expected payoffs, the pure-deviation principle, and Nash-equilibrium
     verification for finite two-player games.
  4. The two canonical worked equilibria: Matching Pennies (fully mixed) and the
     Prisoner's Dilemma (mutual defection).
  5. Exact equilibrium finding for 2x2 games by support enumeration.

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Dict, List, Optional, Sequence, Tuple

Number = Fraction


# ---------------------------------------------------------------------------
# 1. One-dimensional Sperner lemma
# ---------------------------------------------------------------------------

def fully_colored_edges(coloring: Sequence[bool]) -> List[int]:
    """Return the left endpoints i of edges (i, i+1) whose endpoints differ."""
    return [i for i in range(len(coloring) - 1) if coloring[i] != coloring[i + 1]]


def sperner_parity_holds(coloring: Sequence[bool]) -> bool:
    """Check the parity form of the 1D Sperner lemma for one coloring.

    The number of fully colored edges is odd iff the endpoints differ.
    """
    count = len(fully_colored_edges(coloring))
    endpoints_differ = coloring[0] != coloring[-1]
    return (count % 2 == 1) == endpoints_differ


# ---------------------------------------------------------------------------
# 2. Discrete intermediate value theorem and discrete Brouwer fixed point
# ---------------------------------------------------------------------------

def discrete_ivt(values: Sequence[int]) -> Optional[int]:
    """Find i with values[i] <= 0 <= values[i+1], given values[0] <= 0 <= values[-1]."""
    for i in range(len(values) - 1):
        if values[i] <= 0 <= values[i + 1]:
            return i
    return None


def discrete_brouwer(g: Sequence[int]) -> Optional[int]:
    """Find i with i <= g[i] and g[i+1] <= i+1 for a self-map g of {0,...,n}."""
    displacement = [j - g[j] for j in range(len(g))]
    return discrete_ivt(displacement)


# ---------------------------------------------------------------------------
# 3. Finite two-player games
# ---------------------------------------------------------------------------

class FinGame:
    """A finite two-player game with rational payoff matrices u1, u2."""

    def __init__(self, u1: List[List[Number]], u2: List[List[Number]]) -> None:
        self.u1 = u1
        self.u2 = u2
        self.n_rows = len(u1)
        self.n_cols = len(u1[0])

    def E1(self, p: Sequence[Number], q: Sequence[Number]) -> Number:
        """Expected payoff to player 1 under mixed profile (p, q)."""
        return sum(p[i] * q[j] * self.u1[i][j]
                   for i in range(self.n_rows) for j in range(self.n_cols))

    def E2(self, p: Sequence[Number], q: Sequence[Number]) -> Number:
        """Expected payoff to player 2 under mixed profile (p, q)."""
        return sum(p[i] * q[j] * self.u2[i][j]
                   for i in range(self.n_rows) for j in range(self.n_cols))


def is_distribution(p: Sequence[Number]) -> bool:
    """True iff p is a probability distribution (nonnegative, sums to 1)."""
    return all(x >= 0 for x in p) and sum(p) == 1


def pure(index: int, size: int) -> List[Number]:
    """The pure-strategy distribution e_index over `size` options."""
    return [Fraction(1) if i == index else Fraction(0) for i in range(size)]


def is_nash_by_pure_deviation(game: FinGame,
                              p: Sequence[Number],
                              q: Sequence[Number]) -> bool:
    """Certify a Nash equilibrium via the pure-deviation principle.

    By linearity of expected payoff, (p, q) is a Nash equilibrium iff no pure
    deviation of either player strictly improves their payoff.
    """
    if not (is_distribution(p) and is_distribution(q)):
        return False
    base1 = game.E1(p, q)
    base2 = game.E2(p, q)
    for a in range(game.n_rows):
        if game.E1(pure(a, game.n_rows), q) > base1:
            return False
    for b in range(game.n_cols):
        if game.E2(p, pure(b, game.n_cols)) > base2:
            return False
    return True


# ---------------------------------------------------------------------------
# 5. Support enumeration for 2x2 games (finds all Nash equilibria exactly)
# ---------------------------------------------------------------------------

def find_all_nash_2x2(game: FinGame) -> List[Tuple[List[Number], List[Number]]]:
    """Enumerate all Nash equilibria of a 2x2 game by support analysis."""
    equilibria: List[Tuple[List[Number], List[Number]]] = []

    # Pure equilibria: check all 4 pure profiles.
    for a, b in product(range(2), range(2)):
        p, q = pure(a, 2), pure(b, 2)
        if is_nash_by_pure_deviation(game, p, q):
            equilibria.append((p, q))

    # Fully mixed equilibrium: each player makes the other indifferent.
    # Player 2 chooses q so player 1 is indifferent between rows:
    #   u1[0][0]*q0 + u1[0][1]*q1 = u1[1][0]*q0 + u1[1][1]*q1, q0 + q1 = 1.
    def mixed_making_opponent_indifferent(m: List[List[Number]]) -> Optional[List[Number]]:
        # Solve for the column mix q that equalizes the two rows of m.
        denom = (m[0][0] - m[0][1] - m[1][0] + m[1][1])
        if denom == 0:
            return None
        q0 = (m[1][1] - m[0][1]) / denom
        q1 = 1 - q0
        if 0 < q0 < 1:
            return [q0, q1]
        return None

    q_mix = mixed_making_opponent_indifferent(game.u1)
    # Player 1 chooses p so player 2 is indifferent between columns; this uses
    # the transpose orientation of u2.
    u2_T = [[game.u2[i][j] for i in range(2)] for j in range(2)]
    p_mix = mixed_making_opponent_indifferent(u2_T)
    if p_mix is not None and q_mix is not None:
        if is_nash_by_pure_deviation(game, p_mix, q_mix):
            equilibria.append((p_mix, q_mix))

    return equilibria


# ---------------------------------------------------------------------------
# Canonical games
# ---------------------------------------------------------------------------

def matching_pennies() -> FinGame:
    """Player 1 wins on a match, player 2 on a mismatch (zero-sum)."""
    one, neg = Fraction(1), Fraction(-1)
    u1 = [[one, neg], [neg, one]]
    u2 = [[neg, one], [one, neg]]
    return FinGame(u1, u2)


def prisoners_dilemma() -> FinGame:
    """Row/Col in {Cooperate=0, Defect=1}; payoffs (3,3),(0,5),(5,0),(1,1)."""
    f = Fraction
    u1 = [[f(3), f(0)], [f(5), f(1)]]
    u2 = [[f(3), f(5)], [f(0), f(1)]]
    return FinGame(u1, u2)


def _fmt(vec: Sequence[Number]) -> str:
    return "(" + ", ".join(str(x) for x in vec) + ")"


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("1. One-dimensional Sperner lemma (parity of fully colored edges)")
    print("=" * 70)
    R, B = False, True
    samples = [
        [R, B, B, B, B],
        [R, B, R, B, B],
        [R, R, B, R, B],
        [R, R, R, R, R],  # same endpoints -> even count
    ]
    for c in samples:
        edges = fully_colored_edges(c)
        label = "".join("R" if not x else "B" for x in c)
        print(f"  {label}: flips at {edges} -> count {len(edges)} "
              f"({'odd' if len(edges) % 2 else 'even'}); parity law holds: "
              f"{sperner_parity_holds(c)}")

    print()
    print("=" * 70)
    print("2. Discrete IVT and discrete Brouwer fixed point")
    print("=" * 70)
    f_vals = [-3, -1, -1, 2, 5]
    i = discrete_ivt(f_vals)
    print(f"  f = {f_vals}: sign change across edge ({i}, {i+1}): "
          f"f[{i}]={f_vals[i]} <= 0 <= f[{i+1}]={f_vals[i+1]}")
    g = [2, 0, 1, 4, 3]  # a self-map of {0,...,4}
    j = discrete_brouwer(g)
    print(f"  g = {g}: approximate fixed point at i={j}: "
          f"{j} <= g[{j}]={g[j]} and g[{j+1}]={g[j+1]} <= {j+1}")

    print()
    print("=" * 70)
    print("3-4. Pure-deviation principle and worked equilibria")
    print("=" * 70)
    mp = matching_pennies()
    half = Fraction(1, 2)
    unif = [half, half]
    print("  Matching Pennies, uniform profile p=q=(1/2,1/2):")
    print(f"    E1 = {mp.E1(unif, unif)}, E2 = {mp.E2(unif, unif)}")
    print(f"    Is Nash equilibrium: {is_nash_by_pure_deviation(mp, unif, unif)}")
    # No pure profile is an equilibrium:
    any_pure = any(is_nash_by_pure_deviation(mp, pure(a, 2), pure(b, 2))
                   for a in range(2) for b in range(2))
    print(f"    Any pure equilibrium exists: {any_pure}")

    pd = prisoners_dilemma()
    defect = pure(1, 2)
    print("  Prisoner's Dilemma, mutual defection (Defect, Defect):")
    print(f"    E1 = {pd.E1(defect, defect)}, E2 = {pd.E2(defect, defect)}")
    print(f"    Is Nash equilibrium: {is_nash_by_pure_deviation(pd, defect, defect)}")
    coop = pure(0, 2)
    print(f"    Mutual cooperation payoff (Pareto-better, NOT equilibrium): "
          f"E1={pd.E1(coop, coop)}, is Nash={is_nash_by_pure_deviation(pd, coop, coop)}")

    print()
    print("=" * 70)
    print("5. Support enumeration finds ALL equilibria of a 2x2 game")
    print("=" * 70)
    for name, game in [("Matching Pennies", mp), ("Prisoner's Dilemma", pd)]:
        eqs = find_all_nash_2x2(game)
        print(f"  {name}: {len(eqs)} equilibrium/equilibria")
        for p, q in eqs:
            print(f"    p={_fmt(p)}, q={_fmt(q)}")


if __name__ == "__main__":
    main()
