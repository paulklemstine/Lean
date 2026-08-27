"""
Committed local-oracle protocols: exact composition of locality and hiding.
===========================================================================

This self-contained script demonstrates, by exhaustive enumeration over finite
randomness spaces, the results of

    "Composing Locality with Hiding: An Exact Factorization of Perfect Zero
     Knowledge for Committed Local-Oracle Protocols".

The objects modelled here are:

  * a coordinate set I, an alphabet A,
  * a randomized proof string   proof : P -> (I -> A),
  * a commitment scheme         com : (I -> A) x Rc -> C,
                                open: (I -> A) x Rc x subset(I) -> O,
  * a query pattern             Q : Rv -> subset(I),  with |Q(r)| <= q,
  * a transcript                (com, r, proof(p)|_{Q(r)}, open(...)).

Everything is computed with exact rational arithmetic (fractions.Fraction), so
the equalities verified below are exact, never approximate.

Demonstrations
--------------
 1. The one-time pad perfectly hides unopened coordinates (bijection witness).
 2. Sharp 2-transitivity of the symmetric group on 3 letters: for distinct
    x != y and distinct a != b there is EXACTLY ONE permutation with
    pi(x)=a, pi(y)=b -- hence the opened colour pair is uniform.
 3. The committed 2-query proof for graph 3-colouring is perfect
    honest-verifier zero knowledge: the real and simulated transcript
    distributions are identical, transcript by transcript.
 4. Tightness: dropping hiding breaks it (probability 1 vs 0); dropping
    simulation breaks it (probability 1/2 vs 0).
 5. Cyclic (shift) rerandomization provably admits no simulator at all:
    the opened view (0,1) has probability 1/3 under one colouring and 0
    under another.
 6. Locality: the fibrewise decomposition of the transcript count, showing
    that the count is (#prover coins matching the opened view) x (fibre count)
    and never mentions unopened coordinates.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations, product
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Basic types
# ---------------------------------------------------------------------------

Coord = int                      # a coordinate i in I
Symbol = int                     # a symbol a in A
String = Tuple[Symbol, ...]      # a full proof string u : I -> A (indexed by position)
PartialView = Tuple[object, ...] # a partial assignment, None off the query set
QuerySet = FrozenSet[Coord]
Transcript = Tuple[object, object, PartialView, object]


def restrict_to(query: QuerySet, f: String) -> PartialView:
    """The partial view f|_T : None outside T, f(i) inside T."""
    return tuple(f[i] if i in query else None for i in range(len(f)))


def opened_support(view: PartialView) -> List[int]:
    """Coordinates on which a partial view is defined."""
    return [i for i, a in enumerate(view) if a is not None]


# ---------------------------------------------------------------------------
# A committed local-oracle protocol
# ---------------------------------------------------------------------------


class CommittedOracle:
    """A committed local-oracle protocol over finite randomness spaces.

    com        : (String, Rc) -> C
    open_info  : (String, Rc, QuerySet) -> O
    queries    : Rv -> QuerySet         with |Q(r)| <= qbound
    proof      : P -> String
    """

    def __init__(
        self,
        n_coords: int,
        com: Callable[[String, object], object],
        open_info: Callable[[String, object, QuerySet], object],
        queries: Callable[[object], QuerySet],
        qbound: int,
        proof: Callable[[object], String],
        prover_rand: Sequence[object],
        commit_rand: Sequence[object],
        verifier_rand: Sequence[object],
    ) -> None:
        self.n_coords = n_coords
        self.com = com
        self.open_info = open_info
        self.queries = queries
        self.qbound = qbound
        self.proof = proof
        self.P = list(prover_rand)
        self.Rc = list(commit_rand)
        self.Rv = list(verifier_rand)
        for r in self.Rv:
            assert len(self.queries(r)) <= self.qbound, "query bound violated"

    # -- transcripts -------------------------------------------------------

    def real_transcript(self, p: object, rho: object, r: object) -> Transcript:
        u = self.proof(p)
        T = self.queries(r)
        return (self.com(u, rho), r, restrict_to(T, u), self.open_info(u, rho, T))

    def sim_transcript(
        self, sim: Callable[[object, object], String], s: object, rho: object, r: object
    ) -> Transcript:
        u = sim(r, s)
        T = self.queries(r)
        return (self.com(u, rho), r, restrict_to(T, u), self.open_info(u, rho, T))

    # -- exact distributions ----------------------------------------------

    def real_distribution(self) -> Dict[Transcript, Fraction]:
        total = len(self.P) * len(self.Rc) * len(self.Rv)
        counts: Dict[Transcript, int] = {}
        for p, rho, r in product(self.P, self.Rc, self.Rv):
            tau = self.real_transcript(p, rho, r)
            counts[tau] = counts.get(tau, 0) + 1
        return {t: Fraction(c, total) for t, c in counts.items()}

    def sim_distribution(
        self, sim: Callable[[object, object], String], sim_rand: Sequence[object]
    ) -> Dict[Transcript, Fraction]:
        total = len(sim_rand) * len(self.Rc) * len(self.Rv)
        counts: Dict[Transcript, int] = {}
        for s, rho, r in product(sim_rand, self.Rc, self.Rv):
            tau = self.sim_transcript(sim, s, rho, r)
            counts[tau] = counts.get(tau, 0) + 1
        return {t: Fraction(c, total) for t, c in counts.items()}

    # -- the two resources -------------------------------------------------

    def fiber_count(self, u: String, T: QuerySet, c: object, o: object) -> int:
        """#{rho : com(u,rho)=c and open(u,rho,T)=o}."""
        return sum(
            1
            for rho in self.Rc
            if self.com(u, rho) == c and self.open_info(u, rho, T) == o
        )

    def hides_unopened(self, messages: Iterable[String]) -> bool:
        """Check Definition: for all T and all u,v agreeing on T, the fibre
        counts of u and v coincide for every (c,o).  (This is exactly the
        consequence of the hiding bijection that the composition theorem uses,
        and by a counting argument it is equivalent to it over finite Rc.)"""
        msgs = list(messages)
        all_T = [self.queries(r) for r in self.Rv]
        for T in all_T:
            for u, v in product(msgs, msgs):
                if any(u[i] != v[i] for i in T):
                    continue
                pairs = {(self.com(u, rho), self.open_info(u, rho, T)) for rho in self.Rc}
                pairs |= {(self.com(v, rho), self.open_info(v, rho, T)) for rho in self.Rc}
                for (c, o) in pairs:
                    if self.fiber_count(u, T, c, o) != self.fiber_count(v, T, c, o):
                        return False
        return True

    def simulates_opened(
        self, sim: Callable[[object, object], String], sim_rand: Sequence[object]
    ) -> bool:
        """Check  N_real(r,t)*|S| == N_sim(r,t)*|P|  for all r and all views t."""
        nP, nS = len(self.P), len(sim_rand)
        for r in self.Rv:
            T = self.queries(r)
            real: Dict[PartialView, int] = {}
            for p in self.P:
                t = restrict_to(T, self.proof(p))
                real[t] = real.get(t, 0) + 1
            fake: Dict[PartialView, int] = {}
            for s in sim_rand:
                t = restrict_to(T, sim(r, s))
                fake[t] = fake.get(t, 0) + 1
            for t in set(real) | set(fake):
                if real.get(t, 0) * nS != fake.get(t, 0) * nP:
                    return False
        return True


def distributions_equal(
    d1: Dict[Transcript, Fraction], d2: Dict[Transcript, Fraction]
) -> bool:
    return all(d1.get(t, Fraction(0)) == d2.get(t, Fraction(0)) for t in set(d1) | set(d2))


def statistical_distance(
    d1: Dict[Transcript, Fraction], d2: Dict[Transcript, Fraction]
) -> Fraction:
    return sum(
        abs(d1.get(t, Fraction(0)) - d2.get(t, Fraction(0))) for t in set(d1) | set(d2)
    ) / 2


# ---------------------------------------------------------------------------
# Ingredient 1: the coordinate-wise one-time pad
# ---------------------------------------------------------------------------


def otp_com(modulus: int) -> Callable[[String, String], String]:
    def com(u: String, rho: String) -> String:
        return tuple((a + b) % modulus for a, b in zip(u, rho))

    return com


def otp_open(u: String, rho: String, T: QuerySet) -> PartialView:
    """Opening data = the pad revealed on the queried set."""
    return restrict_to(T, rho)


def demo_one_time_pad_hiding() -> None:
    print("=" * 78)
    print("1.  THE ONE-TIME PAD PERFECTLY HIDES UNOPENED COORDINATES")
    print("=" * 78)
    m, n = 3, 3  # alphabet Z/3, three coordinates
    pads: List[String] = [tuple(x) for x in product(range(m), repeat=n)]
    com = otp_com(m)

    T: QuerySet = frozenset({0})  # open coordinate 0 only
    u: String = (1, 0, 2)
    v: String = (1, 2, 1)  # agrees with u on T, differs elsewhere
    print(f"    alphabet Z/{m},  coordinates {{0,1,2}},  opened set T = {set(T)}")
    print(f"    u = {u}   v = {v}   (u and v agree on T)")

    # the hiding bijection e(rho) = rho + (u - v)
    shift: String = tuple((a - b) % m for a, b in zip(u, v))
    print(f"    hiding bijection: e(rho) = rho + (u - v),  u - v = {shift}")

    ok = True
    for rho in pads:
        e_rho: String = tuple((r + s) % m for r, s in zip(rho, shift))
        ok &= com(u, rho) == com(v, e_rho)
        ok &= otp_open(u, rho, T) == otp_open(v, e_rho, T)
    print(f"    commitment AND openings preserved for all {len(pads)} pads: {ok}")

    # and the openings really are informative
    rho0: String = (2, 2, 2)
    c0 = com(u, rho0)
    revealed = otp_open(u, rho0, T)
    recovered = tuple(
        (c0[i] - revealed[i]) % m if revealed[i] is not None else None for i in range(n)
    )
    print(f"    openings are informative: from commitment {c0} and pad {revealed}")
    print(f"      the verifier recovers u|_T = {recovered}  (true u|_T = {restrict_to(T,u)})")
    assert ok and recovered == restrict_to(T, u)
    print()


# ---------------------------------------------------------------------------
# Ingredient 2: sharp 2-transitivity of Sym(Z/3)
# ---------------------------------------------------------------------------


def all_perms_of_3() -> List[Tuple[int, int, int]]:
    """Permutations of {0,1,2}, as tuples pi with pi[x] = image of x."""
    return [tuple(p) for p in permutations(range(3))]


def demo_sharp_two_transitivity() -> None:
    print("=" * 78)
    print("2.  SHARP 2-TRANSITIVITY OF THE SYMMETRIC GROUP ON THREE LETTERS")
    print("=" * 78)
    perms = all_perms_of_3()
    print(f"    |Sym(Z/3)| = {len(perms)};  ordered pairs of distinct colours = 6")
    all_one = True
    for x, y in product(range(3), repeat=2):
        if x == y:
            continue
        for a, b in product(range(3), repeat=2):
            if a == b:
                continue
            k = sum(1 for pi in perms if pi[x] == a and pi[y] == b)
            all_one &= k == 1
    print(f"    for every distinct (x,y) and distinct (a,b): exactly one permutation? {all_one}")

    # consequence: the opened pair is uniform, whatever the colouring
    print("    induced distribution of the opened pair (pi(c(x)), pi(c(y))):")
    for c_pair in [(0, 1), (1, 2), (2, 0)]:
        counts: Dict[Tuple[int, int], int] = {}
        for pi in perms:
            key = (pi[c_pair[0]], pi[c_pair[1]])
            counts[key] = counts.get(key, 0) + 1
        dist = {k: Fraction(v, len(perms)) for k, v in sorted(counts.items())}
        pretty = ", ".join(f"{k}:{v}" for k, v in dist.items())
        print(f"      underlying colours {c_pair} -> {pretty}")
    assert all_one
    print()


# ---------------------------------------------------------------------------
# 3. The committed 2-query proof for graph 3-colouring
# ---------------------------------------------------------------------------


def build_three_colouring_protocol(
    colouring: Sequence[int], edges: Sequence[Tuple[int, int]]
) -> CommittedOracle:
    """Prover randomness = the 6 palette permutations; commitment = OTP over Z/3;
    verifier randomness = a uniformly chosen edge; queries = its two endpoints."""
    n = len(colouring)
    perms = all_perms_of_3()
    pads: List[String] = [tuple(x) for x in product(range(3), repeat=n)]

    def proof(pi: Tuple[int, int, int]) -> String:
        return tuple(pi[colouring[v]] for v in range(n))

    def queries(e: Tuple[int, int]) -> QuerySet:
        return frozenset({e[0], e[1]})

    return CommittedOracle(
        n_coords=n,
        com=otp_com(3),
        open_info=otp_open,
        queries=queries,
        qbound=2,
        proof=proof,
        prover_rand=perms,
        commit_rand=pads,
        verifier_rand=list(edges),
    )


def three_colouring_simulator(n: int) -> Tuple[Callable[[object, object], String], List[object]]:
    """The witness-free simulator: on the challenged edge write a uniformly
    random ORDERED PAIR OF DISTINCT COLOURS; 0 elsewhere."""
    sim_rand: List[object] = [
        (a, b) for a, b in product(range(3), repeat=2) if a != b
    ]

    def sim(r: object, s: object) -> String:
        e = r  # the challenged edge
        a, b = s  # the invented distinct colour pair
        out = [0] * n
        out[e[0]] = a
        out[e[1]] = b
        return tuple(out)

    return sim, sim_rand


def demo_three_colouring_hvzk() -> None:
    print("=" * 78)
    print("3.  PERFECT ZERO KNOWLEDGE OF THE COMMITTED 2-QUERY 3-COLOURING PROOF")
    print("=" * 78)
    # a properly 3-coloured triangle
    colouring = [0, 1, 2]
    edges = [(0, 1), (1, 2), (2, 0)]
    for (x, y) in edges:
        assert colouring[x] != colouring[y], "colouring must be proper"
    print(f"    graph: vertices 0..2, edges {edges}")
    print(f"    proper 3-colouring c = {tuple(colouring)}")

    Pr = build_three_colouring_protocol(colouring, edges)
    sim, sim_rand = three_colouring_simulator(len(colouring))

    print(f"    |P| = {len(Pr.P)} palette permutations, |Rc| = {len(Pr.Rc)} pads, "
          f"|Rv| = {len(Pr.Rv)} edges, |S| = {len(sim_rand)} colour pairs")

    # locality
    max_opened = max(
        len(opened_support(restrict_to(Pr.queries(r), Pr.proof(p))))
        for p in Pr.P
        for r in Pr.Rv
    )
    print(f"    locality: max #symbols exposed by any transcript = {max_opened} (<= q = 2)")

    # completeness
    complete = all(
        Pr.proof(pi)[e[0]] != Pr.proof(pi)[e[1]] for pi in Pr.P for e in Pr.Rv
    )
    print(f"    perfect completeness (opened symbols always differ): {complete}")

    # the two resources
    messages = [Pr.proof(p) for p in Pr.P] + [sim(r, s) for r in Pr.Rv for s in sim_rand]
    print(f"    hiding of unopened coordinates:  {Pr.hides_unopened(messages)}")
    print(f"    perfect simulation of opened view: {Pr.simulates_opened(sim, sim_rand)}")

    # the composition theorem, verified transcript by transcript
    d_real = Pr.real_distribution()
    d_sim = Pr.sim_distribution(sim, sim_rand)
    print(f"    #transcripts with positive real probability: {len(d_real)}")
    print(f"    #transcripts with positive simulated probability: {len(d_sim)}")
    print(f"    distributions identical: {distributions_equal(d_real, d_sim)}")
    print(f"    statistical distance: {statistical_distance(d_real, d_sim)}  (exactly zero)")

    # zero distinguishing advantage for an arbitrary scoring function
    def score(tau: Transcript) -> Fraction:
        c, r, view, o = tau
        return Fraction(sum(x for x in c) * 7 + len(opened_support(view)) * 13 + hash(r) % 5)

    adv = sum(score(t) * d_real.get(t, Fraction(0)) for t in set(d_real) | set(d_sim)) - sum(
        score(t) * d_sim.get(t, Fraction(0)) for t in set(d_real) | set(d_sim)
    )
    print(f"    advantage of an arbitrary (unbounded) distinguisher: {adv}")

    assert distributions_equal(d_real, d_sim) and adv == 0
    print()


# ---------------------------------------------------------------------------
# 4. Tightness: each hypothesis is necessary
# ---------------------------------------------------------------------------


def demo_hiding_is_necessary() -> None:
    print("=" * 78)
    print("4a. HIDING IS NECESSARY (opened view simulated perfectly, yet ZK fails)")
    print("=" * 78)
    # I = {0,1}, A = Z/2, identity 'commitment', query set always {0}
    proof_str: String = (0, 1)

    Pr = CommittedOracle(
        n_coords=2,
        com=lambda u, rho: u,          # publishes the whole string!
        open_info=lambda u, rho, T: 0,  # trivial opening data
        queries=lambda r: frozenset({0}),
        qbound=1,
        proof=lambda p: proof_str,
        prover_rand=[0],
        commit_rand=[0],
        verifier_rand=[0],
    )
    sim_rand: List[object] = [0]
    sim: Callable[[object, object], String] = lambda r, s: (0, 0)

    print(f"    proof string {proof_str}; only coordinate 0 is ever queried")
    print(f"    opened view perfectly simulated: {Pr.simulates_opened(sim, sim_rand)}")
    print(f"    hiding of unopened coordinates:  "
          f"{Pr.hides_unopened([proof_str, (0, 0)])}   <-- FAILS")

    d_real = Pr.real_distribution()
    d_sim = Pr.sim_distribution(sim, sim_rand)
    tau = Pr.real_transcript(0, 0, 0)
    print(f"    honest transcript probability: real = {d_real.get(tau, Fraction(0))}, "
          f"simulated = {d_sim.get(tau, Fraction(0))}")
    print(f"    statistical distance: {statistical_distance(d_real, d_sim)} (maximal)")
    assert d_real[tau] == 1 and d_sim.get(tau, Fraction(0)) == 0
    print()


def demo_simulation_is_necessary() -> None:
    print("=" * 78)
    print("4b. SIMULATION IS NECESSARY (perfectly hiding, yet ZK fails)")
    print("=" * 78)
    # I = {0}, A = Z/2, one-time pad, proof string constantly 0
    pads: List[String] = [(0,), (1,)]
    Pr = CommittedOracle(
        n_coords=1,
        com=otp_com(2),
        open_info=otp_open,
        queries=lambda r: frozenset({0}),
        qbound=1,
        proof=lambda p: (0,),
        prover_rand=[0],
        commit_rand=pads,
        verifier_rand=[0],
    )
    sim_rand: List[object] = [0]
    sim: Callable[[object, object], String] = lambda r, s: (1,)  # wrong colour!

    print("    one-coordinate one-time-padded protocol, proof string (0,)")
    print(f"    hiding of unopened coordinates: {Pr.hides_unopened([(0,), (1,)])}")
    print(f"    opened view simulated:          {Pr.simulates_opened(sim, sim_rand)}"
          "   <-- FAILS (simulator opens 1, not 0)")

    d_real = Pr.real_distribution()
    d_sim = Pr.sim_distribution(sim, sim_rand)
    tau = Pr.real_transcript(0, (0,), 0)
    print(f"    a real transcript's probability: real = {d_real.get(tau, Fraction(0))}, "
          f"simulated = {d_sim.get(tau, Fraction(0))}")
    print(f"    statistical distance: {statistical_distance(d_real, d_sim)}")
    assert d_real[tau] == Fraction(1, 2) and d_sim.get(tau, Fraction(0)) == 0
    print()


# ---------------------------------------------------------------------------
# 5. Transitivity is not enough: cyclic rerandomization leaks
# ---------------------------------------------------------------------------


def demo_cyclic_leaks() -> None:
    print("=" * 78)
    print("5.  TRANSITIVITY IS NOT ENOUGH: CYCLIC RERANDOMIZATION ADMITS NO SIMULATOR")
    print("=" * 78)
    edges = [(0, 1)]
    pads: List[String] = [tuple(x) for x in product(range(3), repeat=2)]

    def shift_protocol(colouring: Sequence[int]) -> CommittedOracle:
        return CommittedOracle(
            n_coords=2,
            com=otp_com(3),
            open_info=otp_open,
            queries=lambda r: frozenset({0, 1}),
            qbound=2,
            proof=lambda d: tuple((colouring[v] + d) % 3 for v in range(2)),
            prover_rand=[0, 1, 2],       # the three cyclic shifts
            commit_rand=pads,
            verifier_rand=list(edges),
        )

    A, B = (0, 1), (0, 2)
    PrA, PrB = shift_protocol(A), shift_protocol(B)
    target: PartialView = (0, 1)  # opened view "colour 0 here, colour 1 there"

    def view_prob(Pr: CommittedOracle) -> Fraction:
        T = Pr.queries(edges[0])
        k = sum(1 for d in Pr.P if restrict_to(T, Pr.proof(d)) == target)
        return Fraction(k, len(Pr.P))

    pa, pb = view_prob(PrA), view_prob(PrB)
    print(f"    colouring A = {A}: P[opened view = (0,1)] = {pa}")
    print(f"    colouring B = {B}: P[opened view = (0,1)] = {pb}")
    print("    a simulator never sees the colouring, so it induces ONE number here;")
    print(f"    it would have to equal both {pa} and {pb} -- impossible.")
    print("    => no simulator over any randomness space works for both colourings.")

    # by contrast, with the FULL symmetric group both are 1/6
    def perm_view_prob(colouring: Sequence[int]) -> Fraction:
        perms = all_perms_of_3()
        k = sum(
            1
            for pi in perms
            if (pi[colouring[0]], pi[colouring[1]]) == (0, 1)
        )
        return Fraction(k, len(perms))

    print(f"    with the FULL symmetric group: A -> {perm_view_prob(A)}, "
          f"B -> {perm_view_prob(B)}  (equal, hence simulatable)")
    assert pa != pb and perm_view_prob(A) == perm_view_prob(B)
    print()


# ---------------------------------------------------------------------------
# 6. Locality: the fibrewise decomposition
# ---------------------------------------------------------------------------


def demo_fibrewise_decomposition() -> None:
    print("=" * 78)
    print("6.  FIBREWISE DECOMPOSITION:  count(tau) = #{p : view matches} x fibre count")
    print("=" * 78)
    colouring = [0, 1, 2]
    edges = [(0, 1), (1, 2), (2, 0)]
    Pr = build_three_colouring_protocol(colouring, edges)

    checked = 0
    worst = 0
    for p, rho, r in product(Pr.P[:2], Pr.Rc[:4], Pr.Rv[:2]):
        tau = Pr.real_transcript(p, rho, r)
        c, r0, t, o = tau
        T = Pr.queries(r0)
        # brute-force count
        brute = sum(
            1
            for pp, rr, rv in product(Pr.P, Pr.Rc, Pr.Rv)
            if Pr.real_transcript(pp, rr, rv) == tau
        )
        # decomposed count
        matching = [pp for pp in Pr.P if restrict_to(T, Pr.proof(pp)) == t]
        fibres = {Pr.fiber_count(Pr.proof(pp), T, c, o) for pp in matching}
        assert len(fibres) == 1, "hiding should flatten the fibre count"
        N = fibres.pop()
        decomposed = len(matching) * N
        assert brute == decomposed
        checked += 1
        worst = max(worst, brute)
    print(f"    verified count(tau) = |F| x N on {checked} transcripts")
    print("    the fibre count N is CONSTANT across the fibre (this is hiding),")
    print("    and |F| depends only on the <= 2 opened coordinates (this is locality).")
    print(f"    largest transcript count encountered: {worst}")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("COMMITTED LOCAL-ORACLE PROTOCOLS")
    print("Exact composition of PCP locality with commitment hiding")
    print("All probabilities are exact rationals; all claims are checked by enumeration.")
    print()
    demo_one_time_pad_hiding()
    demo_sharp_two_transitivity()
    demo_three_colouring_hvzk()
    demo_hiding_is_necessary()
    demo_simulation_is_necessary()
    demo_cyclic_leaks()
    demo_fibrewise_decomposition()
    print("=" * 78)
    print("ALL DEMONSTRATIONS PASSED.")
    print("=" * 78)


if __name__ == "__main__":
    main()
