"""
Quotient Steps and Evolutionary Paths — numerical demonstrations.
================================================================

This is a fully self-contained, dependency-free Python program that exhibits,
concretely, every major result of the theory of quotient systems:

  A quotient system is a labelled step relation  x --l--> y  on a set of
  objects, together with a rank function rank : objects -> N, satisfying

    (A1) TERMINATION       rank(y) < rank(x) for every step x --l--> y
    (A2) LABEL DETERMINACY the label of a step is determined by its endpoints
    (A3) EXCHANGE          two distinct steps out of x close into a diamond
                           with the labels swapped

  A *quotient step* is one such move; an *evolutionary path* is a finite chain
  of them, recording the list of labels used; it is *complete* when it ends at
  a terminal object (one admitting no further step).

  DECOMPOSITION THEOREM (abstract Jordan-Holder).  Any two complete
  evolutionary paths out of the same object end at the same terminal object and
  use the same MULTISET of labels.  The resulting invariant is written
  decomp(x).

The program:

  1. implements a generic finite quotient system and checks (A1)-(A3);
  2. verifies the decomposition theorem by brute-force enumeration of ALL
     complete paths;
  3. instantiates the arithmetic system (divide by a prime) and recovers the
     fundamental theorem of arithmetic, Omega, the p-adic valuations,
     divisibility-as-reachability and the divisor classification;
  4. instantiates the deletion system on finite sets and the bridge morphism
     S |-> prod(S) between the two;
  5. exhibits the three sharpness counterexamples (one per axiom);
  6. exhibits the diamond (separation fails) and the two-step chain
     (saturation fails);
  7. verifies the multinomial path census numerically;
  8. verifies the path-weight / path-action characterisation of completely
     multiplicative and completely additive arithmetic functions.

Run with:  python3 demo.py
"""

from __future__ import annotations

from collections import Counter
from itertools import combinations, permutations
from math import factorial, isqrt
from typing import Callable, Dict, FrozenSet, Hashable, Iterable, List, Sequence, Tuple

Object = Hashable
Label = Hashable
Step = Tuple[Object, Label, Object]


# ---------------------------------------------------------------------------
# 1.  A generic finite quotient system
# ---------------------------------------------------------------------------


class QuotientSystem:
    """A finite labelled step relation with a rank function.

    `objects` is the (finite) carrier, `steps` the list of triples
    (source, label, target), and `rank` the termination measure.
    """

    def __init__(
        self,
        objects: Sequence[Object],
        steps: Iterable[Step],
        rank: Callable[[Object], int],
    ) -> None:
        self.objects: List[Object] = list(objects)
        self.steps: List[Step] = list(steps)
        self.rank = rank
        self._out: Dict[Object, List[Tuple[Label, Object]]] = {o: [] for o in self.objects}
        for (x, l, y) in self.steps:
            self._out[x].append((l, y))

    # -- basic queries ------------------------------------------------------

    def out(self, x: Object) -> List[Tuple[Label, Object]]:
        """All quotient steps leaving `x`, as (label, target) pairs."""
        return self._out[x]

    def is_terminal(self, x: Object) -> bool:
        """`x` is terminal when no quotient step leaves it."""
        return not self._out[x]

    def has_step(self, x: Object, l: Label, y: Object) -> bool:
        return (l, y) in self._out[x]

    # -- axiom checking -----------------------------------------------------

    def check_termination(self) -> bool:
        """(A1): every step strictly decreases rank."""
        return all(self.rank(y) < self.rank(x) for (x, _, y) in self.steps)

    def check_label_determinacy(self) -> bool:
        """(A2): the label of a step is determined by its endpoints."""
        for x in self.objects:
            seen: Dict[Object, Label] = {}
            for (l, y) in self._out[x]:
                if y in seen and seen[y] != l:
                    return False
                seen[y] = l
        return True

    def check_exchange(self) -> bool:
        """(A3): distinct steps out of a common source close into a diamond."""
        for x in self.objects:
            for (l1, y1) in self._out[x]:
                for (l2, y2) in self._out[x]:
                    if y1 == y2:
                        continue
                    closes = any(
                        self.has_step(y1, l2, z) and self.has_step(y2, l1, z)
                        for z in self.objects
                    )
                    if not closes:
                        return False
        return True

    def check_axioms(self) -> Dict[str, bool]:
        return {
            "(A1) termination": self.check_termination(),
            "(A2) label determinacy": self.check_label_determinacy(),
            "(A3) exchange": self.check_exchange(),
        }

    def is_separated(self) -> bool:
        """A step is determined by its source AND its label."""
        for x in self.objects:
            seen: Dict[Label, Object] = {}
            for (l, y) in self._out[x]:
                if l in seen and seen[l] != y:
                    return False
                seen[l] = y
        return True

    def is_saturated(self) -> bool:
        """A label available one step later is already available now."""
        for x in self.objects:
            for (_, y) in self._out[x]:
                for (lp, _) in self._out[y]:
                    if not any(l2 == lp for (l2, _) in self._out[x]):
                        return False
        return True

    # -- paths --------------------------------------------------------------

    def complete_paths(self, x: Object) -> List[Tuple[Tuple[Label, ...], Object]]:
        """Every complete evolutionary path out of `x`, as (label list, endpoint)."""
        if self.is_terminal(x):
            return [((), x)]
        out: List[Tuple[Tuple[Label, ...], Object]] = []
        for (l, y) in self._out[x]:
            for (labels, end) in self.complete_paths(y):
                out.append(((l,) + labels, end))
        return out

    def reachable(self, x: Object) -> List[Object]:
        """All stages in the future of `x` (including `x` itself)."""
        seen = {x}
        frontier = [x]
        while frontier:
            u = frontier.pop()
            for (_, v) in self._out[u]:
                if v not in seen:
                    seen.add(v)
                    frontier.append(v)
        return sorted(seen, key=repr)

    # -- the invariant ------------------------------------------------------

    def decomp(self, x: Object) -> Counter:
        """The decomposition invariant: the label multiset of any complete path."""
        if self.is_terminal(x):
            return Counter()
        (l, y) = self._out[x][0]
        d = Counter(self.decomp(y))
        d[l] += 1
        return d

    def normal_form(self, x: Object) -> Object:
        while not self.is_terminal(x):
            x = self._out[x][0][1]
        return x

    def height(self, x: Object) -> int:
        return sum(self.decomp(x).values())

    # -- the theorem, checked by brute force --------------------------------

    def verify_decomposition_theorem(self) -> bool:
        """All complete paths out of each object agree in endpoint and labels."""
        for x in self.objects:
            paths = self.complete_paths(x)
            ends = {end for (_, end) in paths}
            multisets = {tuple(sorted(Counter(ls).items(), key=repr)) for (ls, _) in paths}
            if len(ends) != 1 or len(multisets) != 1:
                return False
        return True

    # -- path integrals -----------------------------------------------------

    def path_weight(self, w: Callable[[Label], float], x: Object) -> float:
        """Product of the label weight over the invariant (with multiplicity)."""
        p = 1.0
        for (l, m) in self.decomp(x).items():
            p *= w(l) ** m
        return p

    def path_action(self, w: Callable[[Label], float], x: Object) -> float:
        """Sum of the label weight over the invariant (with multiplicity)."""
        return sum(w(l) * m for (l, m) in self.decomp(x).items())


# ---------------------------------------------------------------------------
# 2.  The arithmetic quotient system:  n --p--> m  iff  p prime, m>0, n = p*m
# ---------------------------------------------------------------------------


def primes_up_to(n: int) -> List[int]:
    sieve = [True] * (n + 1)
    sieve[0:2] = [False, False]
    for i in range(2, isqrt(n) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def prime_factor_list(n: int) -> List[int]:
    """The prime factors of n > 0 with multiplicity, in nondecreasing order."""
    assert n > 0
    out: List[int] = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            out.append(d)
            n //= d
        d += 1
    if n > 1:
        out.append(n)
    return out


def arithmetic_system(bound: int) -> QuotientSystem:
    """The multiplicative quotient system restricted to {1, ..., bound}."""
    objects = list(range(1, bound + 1))
    ps = primes_up_to(bound)
    steps: List[Step] = []
    for n in objects:
        for p in ps:
            if n % p == 0 and n // p >= 1 and n != 1:
                steps.append((n, p, n // p))
    return QuotientSystem(objects, steps, rank=lambda n: len(prime_factor_list(n)))


# ---------------------------------------------------------------------------
# 3.  The deletion quotient system on finite subsets of a ground set
# ---------------------------------------------------------------------------


def deletion_system(ground: Sequence[Hashable]) -> QuotientSystem:
    """S --a--> S \\ {a}, over all subsets of `ground`."""
    subsets: List[FrozenSet[Hashable]] = []
    for k in range(len(ground) + 1):
        for c in combinations(ground, k):
            subsets.append(frozenset(c))
    steps: List[Step] = []
    for S in subsets:
        for a in S:
            steps.append((S, a, S - {a}))
    return QuotientSystem(subsets, steps, rank=len)


# ---------------------------------------------------------------------------
# 4.  Sharpness counterexamples
# ---------------------------------------------------------------------------


def no_exchange_system() -> QuotientSystem:
    """0 -> 1 -> 2 with the shortcut 0 -> 2.  (A1),(A2) hold; (A3) fails."""
    return QuotientSystem([0, 1, 2], [(0, "*", 1), (1, "*", 2), (0, "*", 2)],
                          rank=lambda x: 2 - x)


def no_label_determinacy_system() -> QuotientSystem:
    """The single move 0 -> 1 carrying either of two labels.  (A2) fails."""
    return QuotientSystem([0, 1], [(0, "T", 1), (0, "F", 1)], rank=lambda x: 1 - x)


def diamond_system() -> QuotientSystem:
    """3 -> {1,2} -> 0, single label.  A quotient system that is NOT separated."""
    return QuotientSystem(
        [0, 1, 2, 3],
        [(3, "*", 1), (3, "*", 2), (1, "*", 0), (2, "*", 0)],
        rank=lambda x: {0: 0, 1: 1, 2: 1, 3: 2}[x],
    )


def two_step_chain() -> QuotientSystem:
    """2 --b--> 1 --a--> 0.  A quotient system that is NOT saturated."""
    return QuotientSystem([0, 1, 2], [(2, "b", 1), (1, "a", 0)], rank=lambda x: x)


# ---------------------------------------------------------------------------
# 5.  Reporting helpers
# ---------------------------------------------------------------------------


def ms(c: Counter) -> str:
    if not c:
        return "{}"
    parts = []
    for k in sorted(c, key=repr):
        parts.extend([str(k)] * c[k])
    return "{" + ", ".join(parts) + "}"


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_axioms_and_theorem() -> None:
    banner("1.  The arithmetic quotient system satisfies (A1)-(A3)")
    Q = arithmetic_system(64)
    for name, ok in Q.check_axioms().items():
        print(f"   {name:<26} {'OK' if ok else 'FAILS'}")
    print(f"   separated                  {'yes' if Q.is_separated() else 'no'}")
    print(f"   saturated                  {'yes' if Q.is_saturated() else 'no'}")
    print()
    print("   Decomposition theorem, checked by enumerating ALL complete paths:")
    print(f"      holds for every n <= 64:  {Q.verify_decomposition_theorem()}")

    banner("2.  All factorisation chains of 60 agree as multisets")
    paths = Q.complete_paths(60)
    print(f"   number of complete evolutionary paths out of 60: {len(paths)}")
    for (labels, end) in paths:
        chain = " -> ".join(str(l) for l in labels)
        print(f"      60 :  divide by {chain:<14} ends at {end}")
    ends = {e for (_, e) in paths}
    mss = {tuple(sorted(ls)) for (ls, _) in paths}
    print(f"   distinct endpoints      : {ends}")
    print(f"   distinct label multisets: {ms(Counter(next(iter(mss))))}")
    print("   => the fundamental theorem of arithmetic, in one instance.")


def demo_invariant_identification() -> None:
    banner("3.  The invariant IS the prime factorisation")
    Q = arithmetic_system(64)
    print(f"   {'n':>4} | {'decomp(n)':<22} | {'ht = Omega(n)':>13} | v_2  v_3  v_5")
    print("   " + "-" * 66)
    for n in (1, 2, 12, 30, 36, 48, 60, 64):
        d = Q.decomp(n)
        assert sorted(d.elements()) == prime_factor_list(n)
        print(f"   {n:>4} | {ms(d):<22} | {Q.height(n):>13} | "
              f"{d[2]:>3}  {d[3]:>3}  {d[5]:>3}")
    print("   (every row verified against an independent trial-division factoriser)")

    banner("4.  Reachability is divisibility; futures are the divisors")
    n = 60
    fut = [m for m in Q.reachable(n)]
    div = sorted(m for m in range(1, n + 1) if n % m == 0)
    print(f"   stages reachable from {n}: {sorted(fut)}")
    print(f"   divisors of {n}          : {div}")
    print(f"   equal: {sorted(fut) == div}")
    print()
    print("   Divisor classification: sub-multisets of decomp(60) <-> divisors")
    e = Counter(prime_factor_list(n))
    predicted = 1
    for m in e.values():
        predicted *= m + 1
    print(f"      decomp(60) = {ms(e)}")
    print(f"      prod (m_l + 1) = {predicted},  #divisors = {len(div)}  -> "
          f"{predicted == len(div)}")


def demo_multinomial_census() -> None:
    banner("5.  Multinomial path census (Open Problem 1), checked numerically")
    Q = arithmetic_system(96)
    print(f"   {'n':>4} | {'decomp(n)':<20} | {'#complete paths':>15} | "
          f"{'|M|!/prod m_l!':>15} | match")
    print("   " + "-" * 74)
    all_ok = True
    for n in (1, 2, 6, 12, 30, 36, 60, 64, 72, 96):
        d = Q.decomp(n)
        counted = len(Q.complete_paths(n))
        total = sum(d.values())
        predicted = factorial(total)
        for m in d.values():
            predicted //= factorial(m)
        ok = counted == predicted
        all_ok &= ok
        print(f"   {n:>4} | {ms(d):<20} | {counted:>15} | {predicted:>15} | {ok}")
    print(f"   all match: {all_ok}")
    print("   (this is the bijective content of 'complete paths = permutations")
    print("    of the invariant', instantiated in arithmetic)")


def demo_deletion_and_bridge() -> None:
    banner("6.  The deletion system on finite sets, and its invariant")
    D = deletion_system(["a", "b", "c"])
    for name, ok in D.check_axioms().items():
        print(f"   {name:<26} {'OK' if ok else 'FAILS'}")
    S = frozenset({"a", "b", "c"})
    print(f"   decomp({{a,b,c}}) = {ms(D.decomp(S))},  height = {D.height(S)}")
    print(f"   complete deletion sequences of {{a,b,c}}: {len(D.complete_paths(S))} "
          f"(= 3! = {factorial(3)})")
    for (labels, end) in D.complete_paths(S):
        print(f"      delete {' , '.join(labels)}   ->  {set(end) or '{}'}")
    print(f"   stages reachable from {{a,b,c}} = its 2^3 = "
          f"{len(D.reachable(S))} subsets")

    banner("7.  The bridge morphism  S |-> prod(S)  from sets of primes to N")
    A = arithmetic_system(3000)
    ground = [2, 3, 5, 7]
    P = deletion_system(ground)
    print("   Functoriality: decomp(prod S) = image of decomp(S).")
    print(f"   {'S':<18} | {'prod S':>7} | {'decomp(prod S)':<20} | squarefree")
    print("   " + "-" * 64)
    prods = {}
    for k in range(len(ground) + 1):
        for c in combinations(ground, k):
            S = frozenset(c)
            prod = 1
            for p in S:
                prod *= p
            prods[S] = prod
            d = A.decomp(prod)
            sqfree = all(m <= 1 for m in d.values())
            assert set(d.elements()) == set(S) and sqfree
            print(f"   {str(sorted(S)):<18} | {prod:>7} | {ms(d):<20} | {sqfree}")
    print(f"   prime-product map injective: "
          f"{len(set(prods.values())) == len(prods)}")


def demo_sharpness() -> None:
    banner("8.  Sharpness: each of (A1)-(A3) is genuinely necessary")

    print("   (a) EXCHANGE dropped:  0 -> 1 -> 2  plus the shortcut  0 -> 2")
    B = no_exchange_system()
    for name, ok in B.check_axioms().items():
        print(f"       {name:<26} {'OK' if ok else 'FAILS'}")
    paths = B.complete_paths(0)
    print(f"       complete chains out of 0: "
          f"{[(''.join(map(str, ls)) or '<empty>', e) for (ls, e) in paths]}")
    print(f"       their lengths: {sorted(len(ls) for (ls, _) in paths)}"
          "   <-- DIFFERENT, so no invariant exists")

    print()
    print("   (b) LABEL DETERMINACY dropped:  0 -> 1 with two possible labels")
    C = no_label_determinacy_system()
    for name, ok in C.check_axioms().items():
        print(f"       {name:<26} {'OK' if ok else 'FAILS'}")
    paths = C.complete_paths(0)
    print(f"       complete chains out of 0: {[(ls, e) for (ls, e) in paths]}")
    print("       endpoints agree, LABEL MULTISETS DO NOT")

    print()
    print("   (c) TERMINATION dropped:  a single object with a self-loop")
    print("       (A2) and (A3) hold trivially; no chain is ever complete,")
    print("       so there is no decomposition invariant to define at all.")


def demo_separation_and_saturation() -> None:
    banner("9.  Separation: without it the invariant does not separate stages")
    Dm = diamond_system()
    for name, ok in Dm.check_axioms().items():
        print(f"   {name:<26} {'OK' if ok else 'FAILS'}")
    print(f"   separated: {Dm.is_separated()}   <-- fails")
    print(f"   1 and 2 are both reachable from 3: "
          f"{1 in Dm.reachable(3) and 2 in Dm.reachable(3)}")
    print(f"   decomp(1) = {ms(Dm.decomp(1))},  decomp(2) = {ms(Dm.decomp(2))},  "
          f"but 1 != 2")
    print("   => faithfulness of the universal multiset representation genuinely")
    print("      requires the separation hypothesis.")

    banner("10.  Saturation: not a consequence of (A1)-(A3)")
    Ch = two_step_chain()
    for name, ok in Ch.check_axioms().items():
        print(f"   {name:<26} {'OK' if ok else 'FAILS'}")
    print(f"   decomp(2) = {ms(Ch.decomp(2))}")
    print(f"   saturated: {Ch.is_saturated()}   <-- fails")
    print("   the label 'a' occurs in decomp(2) but labels no step out of 2,")
    print("   so surjectivity onto sub-multisets needs the extra hypothesis.")

    print()
    print("   By contrast, arithmetic and deletion are both separated AND saturated:")
    A = arithmetic_system(48)
    D = deletion_system(["a", "b", "c"])
    print(f"      arithmetic: separated={A.is_separated()}, saturated={A.is_saturated()}")
    print(f"      deletion  : separated={D.is_separated()}, saturated={D.is_saturated()}")


def demo_path_integrals() -> None:
    banner("11.  Path weights and path actions are conserved potentials")
    Q = arithmetic_system(200)

    # Conservation along an arbitrary (not necessarily complete) path.
    print("   Conservation law:  along ANY path x ~~> y, the accumulated weight")
    print("   depends only on the endpoints.  Check with w(p) = p:")
    x, y = 180, 5           # 180 = 2*2*3*3*5, 5 | 180
    routes = [[2, 2, 3, 3], [3, 2, 3, 2], [3, 3, 2, 2], [2, 3, 2, 3]]
    for r in routes:
        cur, prod_ = x, 1
        for p in r:
            assert cur % p == 0
            cur //= p
            prod_ *= p
        print(f"      180 divided by {r} -> {cur:<4}  accumulated product = {prod_}")
    print(f"      decomp(180) - decomp(5) = "
          f"{ms(Counter(prime_factor_list(180)) - Counter(prime_factor_list(5)))}")

    print()
    print("   Omega as the path action of the constant weight 1:")
    for n in (12, 30, 60, 128):
        print(f"      n={n:<4} pathAction(1) = {Q.path_action(lambda l: 1.0, n):>5.0f}"
              f"   Omega(n) = {len(prime_factor_list(n))}")

    print()
    print("   The 3-adic valuation as the path action of the indicator of 3:")
    for n in (9, 12, 54, 162):
        v = Q.path_action(lambda l: 1.0 if l == 3 else 0.0, n)
        true_v = Counter(prime_factor_list(n))[3]
        print(f"      n={n:<4} pathAction(1_3) = {v:>4.0f}   v_3(n) = {true_v}")

    banner("12.  Completely multiplicative <-> path weight;  additive <-> action")
    N = 120
    Q2 = arithmetic_system(N)

    # Liouville lambda(n) = (-1)^Omega(n) is the path weight of w(p) = -1.
    ok_lambda = all(
        abs(Q2.path_weight(lambda l: -1.0, n) - (-1.0) ** len(prime_factor_list(n))) < 1e-9
        for n in range(1, N + 1)
    )
    print(f"   Liouville lambda = path weight of w(p) = -1        : {ok_lambda}")

    # n |-> n itself is completely multiplicative: path weight of w(p) = p.
    ok_id = all(abs(Q2.path_weight(lambda l: float(l), n) - n) < 1e-6
                for n in range(1, N + 1))
    print(f"   identity n |-> n = path weight of w(p) = p          : {ok_id}")

    # n |-> n^{-s} for s = 1.5 : the Dirichlet kernel is a path weight.
    s = 1.5
    ok_dir = all(abs(Q2.path_weight(lambda l: float(l) ** (-s), n) - n ** (-s)) < 1e-9
                 for n in range(1, N + 1))
    print(f"   Dirichlet kernel n^-s = path weight of w(p) = p^-s  : {ok_dir}")

    # log is completely additive: path action of w(p) = log p.
    from math import log
    ok_log = all(abs(Q2.path_action(lambda l: log(l), n) - log(n)) < 1e-9
                 for n in range(1, N + 1))
    print(f"   log n = path action of w(p) = log p                 : {ok_log}")

    print()
    print("   Conversely: a NON-completely-multiplicative function is not a path")
    print("   weight.  Euler's totient phi is multiplicative but not completely so;")
    print("   phi(4) = 2 while the path weight of phi restricted to primes gives")
    def phi(n: int) -> int:
        r = n
        for p in set(prime_factor_list(n)) if n > 1 else set():
            r -= r // p
        return r
    w_phi = Q2.path_weight(lambda l: float(phi(l)), 4)
    print(f"      phi(4) = {phi(4)},  pathWeight_phi(4) = {w_phi:.0f}"
          f"   equal? {abs(w_phi - phi(4)) < 1e-9}")


def demo_grading_and_confluence() -> None:
    banner("13.  The evolutionary order is graded and confluent")
    Q = arithmetic_system(400)
    x, y = 360, 3       # 360 = 2^3 * 3^2 * 5,  3 | 360
    print(f"   height(360) = {Q.height(360)},  height(3) = {Q.height(3)}")
    print("   every intermediate height is realised by an actual stage:")
    for k in range(Q.height(y), Q.height(x) + 1):
        witnesses = [m for m in Q.reachable(x)
                     if y in Q.reachable(m) and Q.height(m) == k]
        print(f"      height {k}: {len(witnesses)} stage(s), e.g. {witnesses[0]}")
    print()
    print("   Confluence: any two futures of 360 share a common future (its")
    print("   normal form, 1).")
    a, b = 24, 45
    print(f"      360 ~~> {a} and 360 ~~> {b}: "
          f"{a in Q.reachable(360) and b in Q.reachable(360)}")
    print(f"      normal form of 24 = {Q.normal_form(a)}, of 45 = "
          f"{Q.normal_form(b)}, of 360 = {Q.normal_form(360)}")


def main() -> None:
    print(__doc__.split("Run with:")[0].rstrip())
    demo_axioms_and_theorem()
    demo_invariant_identification()
    demo_multinomial_census()
    demo_deletion_and_bridge()
    demo_sharpness()
    demo_separation_and_saturation()
    demo_path_integrals()
    demo_grading_and_confluence()
    banner("All demonstrations completed.")


if __name__ == "__main__":
    main()
