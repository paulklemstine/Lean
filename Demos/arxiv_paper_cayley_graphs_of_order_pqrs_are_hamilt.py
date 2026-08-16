"""
Hamiltonian cycles in Cayley graphs of squarefree order
=======================================================

Self-contained numerical demonstration of the results:

  1. Connectivity criterion:  Cay(G, S) is connected  <=>  <S> = G.
  2. Cyclic-generator criterion:  a generator in S gives the cycle 1, a, a^2, ...
  3. Direction-sequence criterion (abelian torus C_m [] C_k):
        a sign vector d in {+1,-1}^k closes the cycle  <=>  m | sum_j d_j.
  4. Twisted direction-sequence criterion (metacyclic <a> x| <b>, b a b^-1 = a^e):
        closing condition   m | sum_j d_j e^j,
        automatic with d = (+1,...,+1) whenever gcd(e-1, m) = 1.
  5. Factor group lemma: a k-periodic word whose prefix products hit k distinct
     cosets of <z>, z = voltage, |G| = ord(z)*k, lifts to a hamiltonian cycle.
  6. Coset-pair criterion for the "partial transversal" configuration.
  7. The order-pq theorem: EVERY connected Cayley graph of a group of order pq
     is hamiltonian -- verified exhaustively for small pq by brute force.
  8. Frobenius group of order 21: the transversal configuration needs inverses.
  9. The order-210 example: neither generator generates, yet the graph is
     hamiltonian (boustrophedon on the 105 x 2 torus).

Every group of order pq is metacyclic: Z_q x|_e Z_p with e^p = 1 (mod q).
We therefore represent all groups uniformly as
        G(q, p, e) = { (u, j) : u in Z_q, j in Z_p },
        (u, j) * (v, l) = (u + v * e^j  mod q,  j + l  mod p).
Setting e = 1 gives the abelian group Z_q x Z_p.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

Elt = Tuple[int, int]  # (u, j) in Z_q x Z_p


# ----------------------------------------------------------------------------
# 1. The metacyclic group G(q, p, e) = Z_q x|_e Z_p
# ----------------------------------------------------------------------------


class MetacyclicGroup:
    """The group Z_q x|_e Z_p with (u,j)*(v,l) = (u + v e^j, j + l)."""

    def __init__(self, q: int, p: int, e: int = 1) -> None:
        if pow(e, p, q) != 1 % q:
            raise ValueError(f"e={e} must satisfy e^{p} = 1 (mod {q})")
        self.q = q
        self.p = p
        self.e = e % q
        self.elements: List[Elt] = [(u, j) for j in range(p) for u in range(q)]

    @property
    def order(self) -> int:
        return self.p * self.q

    @property
    def identity(self) -> Elt:
        return (0, 0)

    def mul(self, g: Elt, h: Elt) -> Elt:
        u, j = g
        v, l = h
        return ((u + v * pow(self.e, j, self.q)) % self.q, (j + l) % self.p)

    def inv(self, g: Elt) -> Elt:
        u, j = g
        jm = (-j) % self.p
        # (u,j)^-1 = (-u * e^-j, -j)
        einv = pow(self.e, (-j) % self.p, self.q)
        return ((-u * einv) % self.q, jm)

    def power(self, g: Elt, n: int) -> Elt:
        if n < 0:
            return self.power(self.inv(g), -n)
        acc = self.identity
        for _ in range(n):
            acc = self.mul(acc, g)
        return acc

    def order_of(self, g: Elt) -> int:
        n, acc = 1, g
        while acc != self.identity:
            acc = self.mul(acc, g)
            n += 1
        return n

    def is_abelian(self) -> bool:
        return self.e % self.q == 1 % self.q

    def subgroup_generated(self, gens: Iterable[Elt]) -> Set[Elt]:
        seen: Set[Elt] = {self.identity}
        frontier = [self.identity]
        gens = list(gens)
        while frontier:
            g = frontier.pop()
            for s in gens:
                for h in (self.mul(g, s), self.mul(g, self.inv(s))):
                    if h not in seen:
                        seen.add(h)
                        frontier.append(h)
        return seen

    def name(self) -> str:
        if self.is_abelian():
            return f"Z_{self.q} x Z_{self.p}"
        return f"Z_{self.q} x|_{self.e} Z_{self.p}"


# ----------------------------------------------------------------------------
# 2. Cayley graphs, connectivity, hamiltonicity
# ----------------------------------------------------------------------------


def cayley_adjacency(G: MetacyclicGroup, S: Sequence[Elt]) -> Dict[Elt, List[Elt]]:
    """Adjacency lists of Cay(G, S); the symmetric closure S u S^-1 is used."""
    moves = set()
    for s in S:
        if s != G.identity:
            moves.add(s)
            moves.add(G.inv(s))
    adj: Dict[Elt, List[Elt]] = {g: [] for g in G.elements}
    for g in G.elements:
        for s in moves:
            h = G.mul(g, s)
            if h != g:
                adj[g].append(h)
    return adj


def is_connected(G: MetacyclicGroup, S: Sequence[Elt]) -> bool:
    """Connectivity criterion: Cay(G,S) connected  <=>  <S> = G."""
    return len(G.subgroup_generated(S)) == G.order


def find_hamiltonian_cycle(
    G: MetacyclicGroup, S: Sequence[Elt]
) -> Optional[List[Elt]]:
    """Backtracking search, started at the identity by vertex-transitivity."""
    adj = cayley_adjacency(G, S)
    n = G.order
    if n < 3 or any(len(adj[g]) < 2 for g in G.elements):
        return None
    start = G.identity
    path: List[Elt] = [start]
    visited: Set[Elt] = {start}

    def remaining_connected(current: Elt) -> bool:
        """Prune: the unvisited vertices plus `current` must stay connected."""
        todo = [current]
        seen = {current}
        while todo:
            g = todo.pop()
            for h in adj[g]:
                if h not in seen and (h not in visited or h == start):
                    seen.add(h)
                    todo.append(h)
        return len(seen - {start}) >= n - len(path)

    def extend(current: Elt) -> bool:
        if len(path) == n:
            return start in adj[current]
        if not remaining_connected(current):
            return False
        for h in adj[current]:
            if h not in visited:
                visited.add(h)
                path.append(h)
                if extend(h):
                    return True
                path.pop()
                visited.remove(h)
        return False

    return list(path) if extend(start) else None


def check_cycle(G: MetacyclicGroup, S: Sequence[Elt], cycle: Sequence[Elt]) -> bool:
    """Verify that `cycle` really is a hamiltonian cycle of Cay(G, S)."""
    if len(cycle) != G.order or len(set(cycle)) != G.order:
        return False
    moves = {s for s in S if s != G.identity} | {
        G.inv(s) for s in S if s != G.identity
    }
    n = len(cycle)
    return all(
        G.mul(G.inv(cycle[i]), cycle[(i + 1) % n]) in moves for i in range(n)
    )


# ----------------------------------------------------------------------------
# 3. Explicit constructions
# ----------------------------------------------------------------------------


def cyclic_cycle(G: MetacyclicGroup, a: Elt) -> List[Elt]:
    """1, a, a^2, ..., a^{n-1} when ord(a) = |G|."""
    cyc, g = [], G.identity
    for _ in range(G.order):
        cyc.append(g)
        g = G.mul(g, a)
    return cyc


def direction_sequence(m: int, k: int, e: int = 1) -> Optional[List[int]]:
    """Signs d in {+1,-1}^k with  m | sum_j d_j e^j  (e = 1: untwisted).

    Untwisted: closed form (k even -> half/half; k odd -> (k+m)/2 pluses).
    Twisted with gcd(e-1, m) = 1: the constant sequence works.
    Otherwise: dynamic programming over Z_m.
    """
    if e % m == 1 % m:
        if k % 2 == 0:
            return [1] * (k // 2) + [-1] * (k // 2)
        if m % 2 == 1 and m <= k:
            plus = (k + m) // 2
            return [1] * plus + [-1] * (k - plus)
        return None
    from math import gcd

    if gcd((e - 1) % m, m) == 1:
        return [1] * k
    # DP over residues
    reach: List[Dict[int, Tuple[int, int]]] = [dict() for _ in range(k + 1)]
    reach[0][0] = (0, 0)
    for j in range(k):
        w = pow(e, j, m)
        for res, _ in list(reach[j].items()):
            for d in (1, -1):
                reach[j + 1].setdefault((res + d * w) % m, (res, d))
    if 0 not in reach[k]:
        return None
    d_seq: List[int] = []
    res = 0
    for j in range(k, 0, -1):
        prev, d = reach[j][res]
        d_seq.append(d)
        res = prev
    return list(reversed(d_seq))


def torus_cycle(
    G: MetacyclicGroup, a: Elt, b: Elt, m: int, k: int, d: Sequence[int]
) -> List[Elt]:
    """Ring-by-ring traversal.

    Inside ring j take m-1 steps of right multiplication by a^{d_j} (visiting all
    m vertices of the ring, using the wrap-around of the cycle C_m) and then one
    step of right multiplication by b.  The entry point of ring j+1 is therefore
    shifted by a^{-d_j} -- twisted to a^{-d_j e^j} in the metacyclic case.
    """
    cyc: List[Elt] = []
    g = G.identity
    for j in range(k):
        step = a if d[j] == 1 else G.inv(a)
        for i in range(m):
            cyc.append(g)
            if i < m - 1:
                g = G.mul(g, step)
        g = G.mul(g, b)
    return cyc


def prefix_products(G: MetacyclicGroup, word: Sequence[Elt]) -> List[Elt]:
    out = [G.identity]
    for s in word:
        out.append(G.mul(out[-1], s))
    return out


def voltage(G: MetacyclicGroup, word: Sequence[Elt]) -> Elt:
    return prefix_products(G, word)[-1]


def factor_group_lift(
    G: MetacyclicGroup, word: Sequence[Elt]
) -> Optional[List[Elt]]:
    """Factor group lemma: lift a k-periodic word to a hamiltonian cycle.

    Returns the lifted cycle if the hypotheses hold, else None.
    """
    k = len(word)
    P = prefix_products(G, word)
    z = P[k]
    m = G.order_of(z)
    if m * k != G.order:
        return None
    Z = {G.power(z, t) for t in range(m)}
    cosets = []
    for i in range(k):
        cs = frozenset(G.mul(x, P[i]) for x in Z)
        cosets.append(cs)
    if len(set(cosets)) != k:
        return None
    cycle: List[Elt] = []
    for t in range(m):
        zt = G.power(z, t)
        for i in range(k):
            cycle.append(G.mul(zt, P[i]))
    return cycle if len(set(cycle)) == G.order else None


def coset_pair_word(
    G: MetacyclicGroup, x: Elt, y: Elt, k: int
) -> Optional[Tuple[List[Elt], int, int]]:
    """The transversal word: blocks of x and x^-1 punctuated by two y's.

    The word has the shape
            x, ..., x (alpha times), y, x^-1, ..., x^-1 (beta times), y
    with alpha + beta = k - 2, so that it has period k and its projection to
    G/N = Z_k is a hamiltonian cycle of a circulant.  We scan the admissible
    splittings and return the first one whose voltage lifts.
    """
    for alpha in range(k - 1):
        beta = k - 2 - alpha
        word = [x] * alpha + [y] + [G.inv(x)] * beta + [y]
        if factor_group_lift(G, word) is not None:
            return word, alpha, beta
    return None


# ----------------------------------------------------------------------------
# 4. Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_connectivity() -> None:
    banner("1. Connectivity criterion:  Cay(G,S) connected  <=>  <S> = G")
    G = MetacyclicGroup(7, 3, 1)  # Z_7 x Z_3, order 21, cyclic
    tests = [
        ([(1, 0)], "S = {a}, a of order 7"),
        ([(0, 1)], "S = {b}, b of order 3"),
        ([(1, 0), (0, 1)], "S = {a, b}"),
        ([(1, 1)], "S = {ab}, ab of order 21"),
    ]
    for S, label in tests:
        sub = len(G.subgroup_generated(S))
        conn = is_connected(G, S)
        print(f"  {label:<28} |<S>| = {sub:>3}   connected: {conn}")


def demo_cyclic() -> None:
    banner("2. Cyclic-generator criterion")
    G = MetacyclicGroup(7, 3, 1)
    a = (1, 1)
    print(f"  group {G.name()} of order {G.order}, a = {a}, ord(a) = {G.order_of(a)}")
    cyc = cyclic_cycle(G, a)
    print(f"  cycle 1, a, a^2, ... has {len(cyc)} distinct vertices: "
          f"{len(set(cyc)) == G.order}")
    print(f"  verified hamiltonian cycle of Cay(G,{{a}}): {check_cycle(G, [a], cyc)}")


def demo_direction_sequences() -> None:
    banner("3. Direction sequences on the abelian torus  C_m [] C_k")
    for (q, p) in [(5, 3), (7, 2), (3, 5), (11, 3)]:
        G = MetacyclicGroup(q, p, 1)
        a, b = (1, 0), (0, 1)
        m, k = G.order_of(a), G.order_of(b)
        d = direction_sequence(m, k)
        if d is None:
            # swap the roles of the two generators
            a, b = b, a
            m, k = k, m
            d = direction_sequence(m, k)
        assert d is not None
        cyc = torus_cycle(G, a, b, m, k, d)
        ok = check_cycle(G, [a, b], cyc)
        print(f"  {G.name():<14} m={m:<3} k={k:<3} d={''.join('+' if s>0 else '-' for s in d):<8}"
              f" sum={sum(d):>3}  m | sum: {sum(d) % m == 0}   hamiltonian: {ok}")


def demo_twisted() -> None:
    banner("4. Twisted direction sequences on metacyclic groups")
    cases = [(7, 3, 2), (7, 3, 4), (11, 5, 3), (13, 3, 3), (7, 2, 6)]
    for (q, p, e) in cases:
        G = MetacyclicGroup(q, p, e)
        a, b = (1, 0), (0, 1)
        m, k = G.order_of(a), G.order_of(b)
        geo = sum(pow(e, j, m) for j in range(k)) % m
        d = direction_sequence(m, k, e)
        assert d is not None
        twisted_sum = sum(d[j] * pow(e, j, m) for j in range(k)) % m
        cyc = torus_cycle(G, a, b, m, k, d)
        ok = check_cycle(G, [a, b], cyc)
        print(f"  {G.name():<18} order {G.order:<4} m={m:<3} k={k:<2} e={e:<2}"
              f"  sum e^j = {geo}  d={''.join('+' if s>0 else '-' for s in d):<6}"
              f" twisted sum mod m = {twisted_sum}  hamiltonian: {ok}")


def demo_factor_group_lemma() -> None:
    banner("5. The factor group lemma (voltage form)")
    # Dihedral group of order 14 = Z_7 x|_6 Z_2, word (a, a, a, a, a, a, b)
    G = MetacyclicGroup(7, 2, 6)
    a, b = (1, 0), (0, 1)
    word = [a] * 6 + [b]
    z = voltage(G, word)
    print(f"  group {G.name()} (dihedral of order {G.order})")
    print(f"  word = a^6 b,  voltage z = {z},  ord(z) = {G.order_of(z)},"
          f"  k = {len(word)},  ord(z)*k = {G.order_of(z)*len(word)} = |G|")
    cyc = factor_group_lift(G, word)
    print(f"  lift succeeds: {cyc is not None}; "
          f"verified: {cyc is not None and check_cycle(G, [a, b], cyc)}")

    # A word whose voltage is trivial: the lift must fail
    bad = [a] * 7
    print(f"  word = a^7 has voltage {voltage(G, bad)} (trivial) -> "
          f"lift fails: {factor_group_lift(G, bad) is None}")


def demo_coset_pair() -> None:
    banner("6. The coset-pair criterion (partial transversal configuration)")
    G = MetacyclicGroup(7, 3, 2)
    # x of order 3 outside N = {(u,0)}, y = A x^m in another coset
    x = None
    for g in G.elements:
        if G.order_of(g) == 3 and g[1] != 0:
            x = g
            break
    assert x is not None
    A = (1, 0)  # nonidentity element of the normal subgroup N of order 7
    y = G.mul(A, G.mul(x, x))  # y = A x^2
    print(f"  group {G.name()} (Frobenius group of order {G.order})")
    print(f"  x = {x} (ord {G.order_of(x)}), y = A x^2 = {y} (ord {G.order_of(y)})")
    print(f"  x, y outside N: {x[1] != 0 and y[1] != 0};  "
          f"different cosets of N: {x[1] != y[1]}")
    print(f"  <x,y> = G: {is_connected(G, [x, y])}")
    found = coset_pair_word(G, x, y, G.order_of(x))
    if found is not None:
        word, alpha, beta = found
        z = voltage(G, word)
        lifted = factor_group_lift(G, word)
        print(f"  coset-pair word  x^{alpha} y (x^-1)^{beta} y  has voltage {z}"
              f" of order {G.order_of(z)}")
        print("  factor group lemma lifts it: "
              f"{lifted is not None and check_cycle(G, [x, y], lifted)}")
    cyc = find_hamiltonian_cycle(G, [x, y])
    print(f"  hamiltonian cycle found by search: {cyc is not None}; "
          f"verified: {cyc is not None and check_cycle(G, [x, y], cyc)}")
    if cyc is not None:
        moves = {x: "x", G.inv(x): "X", y: "y", G.inv(y): "Y"}
        cycle_word = "".join(
            moves[G.mul(G.inv(cyc[i]), cyc[(i + 1) % len(cyc)])]
            for i in range(len(cyc))
        )
        print(f"  cycle word (capital = inverse): {cycle_word}")
        print("  -> the word necessarily uses inverses: "
              f"{'X' in cycle_word or 'Y' in cycle_word}")

    # a larger instance of the same criterion, in order 55 = 5 * 11
    H = MetacyclicGroup(11, 5, 3)
    u = (0, 1)                      # element of odd order 5, outside N
    v = H.mul((1, 0), H.power(u, 3))  # v = A u^3 with A in N \ {1}
    got = coset_pair_word(H, u, v, H.order_of(u))
    assert got is not None
    w2, al, be = got
    lift2 = factor_group_lift(H, w2)
    print(f"\n  order 55, {H.name()}: x of order {H.order_of(u)}, y = A x^3")
    print(f"  word x^{al} y (x^-1)^{be} y, voltage {voltage(H, w2)} of order "
          f"{H.order_of(voltage(H, w2))} -> hamiltonian: "
          f"{lift2 is not None and check_cycle(H, [u, v], lift2)}")


def demo_order_pq_theorem(max_order: int = 22) -> None:
    banner("7. The order-pq theorem, verified exhaustively for small pq")
    primes = [2, 3, 5, 7, 11]
    print("  For every group of order pq and every generating connection set S")
    print("  with |S| <= 3 (up to the symmetric closure), a hamiltonian cycle exists.\n")
    total, hamiltonian = 0, 0
    for p, q in combinations(primes, 2):
        if p * q > max_order:
            continue
        # all groups of order pq: Z_q x|_e Z_p for e of multiplicative order 1 or p
        exps = sorted({pow(g, (q - 1) // p, q) for g in range(1, q)}) if (q - 1) % p == 0 else [1]
        for e in exps:
            G = MetacyclicGroup(q, p, e)
            nonid = [g for g in G.elements if g != G.identity]
            worst = None
            for size in (1, 2, 3):
                for S in combinations(nonid, size):
                    if not is_connected(G, S):
                        continue
                    total += 1
                    cyc = find_hamiltonian_cycle(G, S)
                    if cyc is not None and check_cycle(G, S, cyc):
                        hamiltonian += 1
                    else:
                        worst = S
            status = "ALL hamiltonian" if worst is None else f"FAILURE at {worst}"
            print(f"  |G| = {G.order:>3}  {G.name():<20} {status}")
    print(f"\n  connected connection sets tested: {total}; hamiltonian: {hamiltonian}")
    print(f"  order-pq theorem confirmed on this range: {total == hamiltonian}")


def demo_frobenius21() -> None:
    banner("8. The Frobenius group of order 21: inverses are unavoidable")
    G = MetacyclicGroup(7, 3, 2)
    # In the affine model t -> 2^a t + b the pair is x = (a,b) = (1,0) and
    # y = (2,1); in our coordinates (u, j) = (b, a) these are (0,1) and (1,2).
    x, y = (0, 1), (1, 2)
    print(f"  G = {G.name()} = F_21, affine maps t -> 2^a t + b on Z_7")
    print(f"  x = {x} (ord {G.order_of(x)}), y = {y} (ord {G.order_of(y)})")
    print(f"  both outside N = {{(u,0)}}? {x[1] != 0 and y[1] != 0}; "
          f"different cosets of N: {x[1] != y[1]}")
    print(f"  <x, y> = G: {is_connected(G, [x, y])}")
    # positive words can never close: their voltage is trivial
    for gen, nm in ((x, "x"), (y, "y")):
        w: List[Elt] = [gen] * 3
        print(f"  positive word {nm}^3 has voltage {voltage(G, w)} "
              f"(order {G.order_of(voltage(G, w))}) -> no lift")
    cyc = find_hamiltonian_cycle(G, [x, y])
    print(f"  hamiltonian cycle exists: {cyc is not None}, "
          f"verified: {cyc is not None and check_cycle(G, [x, y], cyc)}")


def demo_order210() -> None:
    banner("9. Order 210 = 2*3*5*7: neither generator generates")
    # Z_105 x Z_2 realised as the abelian metacyclic group with e = 1
    G = MetacyclicGroup(105, 2, 1)
    a, b = (1, 0), (0, 1)
    m, k = G.order_of(a), G.order_of(b)
    print(f"  |G| = {G.order} = 2*3*5*7,  ord(a) = {m}, ord(b) = {k}")
    print(f"  a generates G? {G.order_of(a) == G.order};  "
          f"b generates G? {G.order_of(b) == G.order}")
    d = direction_sequence(m, k)
    assert d is not None
    cyc = torus_cycle(G, a, b, m, k, d)
    print(f"  boustrophedon d = {['+' if s > 0 else '-' for s in d]}, sum = {sum(d)}")
    print(f"  hamiltonian cycle on {len(cyc)} vertices, verified: "
          f"{check_cycle(G, [a, b], cyc)}")
    print(f"  first 8 vertices: {cyc[:8]}")


def demo_gray_code() -> None:
    banner("10. A hamiltonian cycle is a Gray code for the group")
    G = MetacyclicGroup(5, 3, 1)  # Z_15
    a, b = (1, 0), (0, 1)
    cyc = find_hamiltonian_cycle(G, [a, b])
    assert cyc is not None
    labels = {a: "a", G.inv(a): "a^-1", b: "b", G.inv(b): "b^-1"}
    steps = [
        labels[G.mul(G.inv(cyc[i]), cyc[(i + 1) % len(cyc)])]
        for i in range(len(cyc))
    ]
    print(f"  group {G.name()} of order {G.order}")
    print("  ordering :", " ".join(f"{g}" for g in cyc[:8]), "...")
    print("  steps    :", " ".join(steps))
    print(f"  every consecutive difference lies in S u S^-1: "
          f"{check_cycle(G, [a, b], cyc)}")


def main() -> None:
    demo_connectivity()
    demo_cyclic()
    demo_direction_sequences()
    demo_twisted()
    demo_factor_group_lemma()
    demo_coset_pair()
    demo_order_pq_theorem()
    demo_frobenius21()
    demo_order210()
    demo_gray_code()
    print("\nAll demonstrations completed.\n")


if __name__ == "__main__":
    main()
