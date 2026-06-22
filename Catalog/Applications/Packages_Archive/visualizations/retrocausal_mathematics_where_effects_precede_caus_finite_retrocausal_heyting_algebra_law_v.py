from __future__ import annotations
from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple


class FiniteHeyting:
    """A finite Heyting algebra given by its order matrix `leq` on 0..n-1,
    with 0 = bottom and n-1 = top.  Meet/join derive from the order;
    pseudo-complement is a^c = join{ x : x meet a = bottom }."""

    def __init__(self, n: int, leq: Sequence[Sequence[bool]]) -> None:
        self.n: int = n
        self.leq: List[List[bool]] = [list(r) for r in leq]
        self.bot, self.top = 0, n - 1
        self._meet: Dict[Tuple[int, int], int] = {}
        self._join: Dict[Tuple[int, int], int] = {}
        for a in range(n):
            for b in range(n):
                self._meet[(a, b)] = self._glb(a, b)
                self._join[(a, b)] = self._lub(a, b)

    def _rank(self, x: int) -> int:
        return sum(self.leq[y][x] for y in range(self.n))

    def _glb(self, a: int, b: int) -> int:
        lo = [x for x in range(self.n) if self.leq[x][a] and self.leq[x][b]]
        return max(lo, key=self._rank)

    def _lub(self, a: int, b: int) -> int:
        up = [x for x in range(self.n) if self.leq[a][x] and self.leq[b][x]]
        return min(up, key=self._rank)

    def meet(self, a: int, b: int) -> int: return self._meet[(a, b)]
    def join(self, a: int, b: int) -> int: return self._join[(a, b)]

    def compl(self, a: int) -> int:
        r = self.bot
        for x in range(self.n):
            if self.meet(x, a) == self.bot:
                r = self.join(r, x)
        return r

    def dneg(self, a: int) -> int: return self.compl(self.compl(a))
    def lem(self, a: int) -> int: return self.join(a, self.compl(a))
    def tem(self, a: int) -> int: return self.dneg(self.lem(a))


def verify_retrocausal(H: FiniteHeyting, rev: Callable[[int], int]) -> Dict[str, object]:
    """Verify the retrocausal axioms and their consequences on a finite model."""
    involution = all(rev(rev(a)) == a for a in range(H.n))
    antitone = all((not H.leq[a][b]) or H.leq[rev(b)][rev(a)]
                   for a in range(H.n) for b in range(H.n))
    de_morgan = all(rev(H.join(a, b)) == H.meet(rev(a), rev(b)) and
                    rev(H.meet(a, b)) == H.join(rev(a), rev(b))
                    for a, b in product(range(H.n), repeat=2))
    pole_swap = rev(H.bot) == H.top and rev(H.top) == H.bot
    lem_fail = [a for a in range(H.n) if H.lem(a) != H.top]
    tem_all = all(H.tem(a) == H.top for a in range(H.n))
    lem_iff_dne = all((H.lem(a) == H.top) == (H.dneg(a) == a) for a in range(H.n))
    return {"involution": involution, "antitone": antitone, "de_morgan": de_morgan,
            "pole_swap": pole_swap, "lem_failure_points": lem_fail,
            "temporal_excluded_middle_everywhere": tem_all, "lem_iff_dne": lem_iff_dne}
