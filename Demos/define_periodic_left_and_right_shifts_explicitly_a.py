"""
Fixed-Point Varieties of Elementary Cellular Automata
=====================================================

Self-contained numerical companion to the paper

    "Fixed-Point Varieties of Elementary Cellular Automata:
     Propagation Criteria, Symmetry Conjugacies, and Arithmetic Counting Functions"

Every claim of the paper that is checkable by finite computation is checked here,
by brute-force enumeration and, independently, by the 4x4 transfer-matrix formula

    #V(g, n) = trace( M(g)^n ),

where M(g) is the adjacency matrix of the "fixed de Bruijn graph" of the rule.

An elementary cellular automaton is a map g : F_2^3 -> F_2 (the local rule).
On the cyclic lattice Z/n it induces the global update

    (F_g s)(i) = g( s(i-1), s(i), s(i+1) ),      indices mod n.

A configuration s is FIXED when F_g s = s.  V(g, n) denotes the set of fixed
configurations, #V(g, n) its cardinality.

No third-party dependencies; pure Python 3, fully type-hinted.
Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Iterator, List, Sequence, Tuple

Bit = int
Neigh = Tuple[Bit, Bit, Bit]
Table = Dict[Neigh, Bit]
Config = Tuple[Bit, ...]
Matrix = List[List[int]]

NEIGHBOURHOODS: List[Neigh] = [(a, b, c) for a in (0, 1) for b in (0, 1) for c in (0, 1)]


# --------------------------------------------------------------------------
# 1.  Rules, rule numbers, and the global update map
# --------------------------------------------------------------------------

def rule_table(number: int) -> Table:
    """Decode a Wolfram rule number: the output on (a, b, c) is bit 4a+2b+c."""
    return {(a, b, c): (number >> (4 * a + 2 * b + c)) & 1 for (a, b, c) in NEIGHBOURHOODS}


def rule_number(table: Table) -> int:
    """Encode a local rule as its Wolfram rule number (inverse of `rule_table`)."""
    return sum(2 ** (4 * a + 2 * b + c) for (a, b, c) in NEIGHBOURHOODS if table[(a, b, c)] == 1)


def step(table: Table, s: Config) -> Config:
    """One synchronous update of the whole cyclic lattice."""
    n = len(s)
    return tuple(table[(s[(i - 1) % n], s[i], s[(i + 1) % n])] for i in range(n))


def configs(n: int) -> Iterator[Config]:
    """All 2^n configurations on the cyclic lattice of n sites."""
    return product((0, 1), repeat=n)


def fixed_configs(number: int, n: int) -> List[Config]:
    """V(g, n): all fixed configurations, by brute-force enumeration."""
    t = rule_table(number)
    return [s for s in configs(n) if step(t, s) == s]


def fixed_count(number: int, n: int) -> int:
    """#V(g, n), by brute-force enumeration.  Cost Theta(n * 2^n)."""
    return len(fixed_configs(number, n))


# --------------------------------------------------------------------------
# 2.  The transfer matrix: #V(g, n) = trace M(g)^n
# --------------------------------------------------------------------------

def fixed_de_bruijn_matrix(number: int) -> Matrix:
    """
    Adjacency matrix of the de Bruijn graph on overlapping pairs (a, b),
    restricted to the edges (a, b) -> (b, c) with g(a, b, c) = b.

    Fixed configurations of length n are exactly the closed walks of length n.
    """
    t = rule_table(number)
    m: Matrix = [[0] * 4 for _ in range(4)]
    for (a, b, c) in NEIGHBOURHOODS:
        if t[(a, b, c)] == b:
            m[2 * a + b][2 * b + c] += 1
    return m


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    k = len(a)
    return [[sum(a[i][t] * b[t][j] for t in range(k)) for j in range(k)] for i in range(k)]


def mat_pow(a: Matrix, n: int) -> Matrix:
    """Fast exponentiation: O(log n) multiplications of 4x4 matrices."""
    k = len(a)
    result: Matrix = [[1 if i == j else 0 for j in range(k)] for i in range(k)]
    base = [row[:] for row in a]
    e = n
    while e > 0:
        if e & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        e >>= 1
    return result


def fixed_count_fast(number: int, n: int) -> int:
    """#V(g, n) in O(log n) 4x4 matrix products, valid for arbitrarily large n."""
    p = mat_pow(fixed_de_bruijn_matrix(number), n)
    return sum(p[i][i] for i in range(4))


# --------------------------------------------------------------------------
# 3.  The two propagation criteria
# --------------------------------------------------------------------------

def right_transitive(t: Table) -> bool:
    """g(a, 0, c) = 0  ==>  c = 0 :  zeros propagate rightwards."""
    return all(t[(a, 0, c)] != 0 or c == 0 for a in (0, 1) for c in (0, 1))


def singleton_criterion(t: Table) -> bool:
    """Right-transitive, kills the all-ones pattern, fixes the all-zero pattern."""
    return right_transitive(t) and t[(1, 1, 1)] != 1 and t[(0, 0, 0)] == 0


def constant_pair_criterion(t: Table) -> bool:
    """Zeros travel left, ones travel right, and both constants are fixed."""
    left_zero = all(t[(a, 0, c)] != 0 or a == 0 for a in (0, 1) for c in (0, 1))
    right_one = all(t[(a, 1, c)] != 1 or c == 1 for a in (0, 1) for c in (0, 1))
    return left_zero and right_one and t[(0, 0, 0)] == 0 and t[(1, 1, 1)] == 1


# --------------------------------------------------------------------------
# 4.  The Klein four-group of symmetries
# --------------------------------------------------------------------------

def mirror(t: Table) -> Table:
    """Reflection: read the neighbourhood right-to-left."""
    return {(a, b, c): t[(c, b, a)] for (a, b, c) in NEIGHBOURHOODS}


def dual(t: Table) -> Table:
    """Complementation: swap the two letters of F_2 on inputs and outputs."""
    return {(a, b, c): 1 ^ t[(1 ^ a, 1 ^ b, 1 ^ c)] for (a, b, c) in NEIGHBOURHOODS}


def klein_orbit(number: int) -> List[int]:
    t = rule_table(number)
    return sorted({rule_number(f(t)) for f in
                   (lambda x: x, mirror, dual, lambda x: mirror(dual(x)))})


def ext_singleton_criterion(t: Table) -> bool:
    """The rule, or one of its three symmetry partners, passes the local criterion."""
    return any(singleton_criterion(f(t)) for f in
               (lambda x: x, mirror, dual, lambda x: mirror(dual(x))))


# --------------------------------------------------------------------------
# 5.  Orbits
# --------------------------------------------------------------------------

def exact_period(number: int, s: Config) -> int:
    """Minimal k > 0 with F_g^k(s) = s, or 0 if s is not on a periodic orbit."""
    t = rule_table(number)
    seen: Dict[Config, int] = {s: 0}
    cur = s
    for k in range(1, 2 ** len(s) + 2):
        cur = step(t, cur)
        if cur == s:
            return k
        if cur in seen:
            return 0
        seen[cur] = k
    return 0


def pull(t_small: Config, n: int) -> Config:
    """Periodic descent: pull a configuration on Z/d back to Z/n, for d | n."""
    d = len(t_small)
    if n % d != 0:
        raise ValueError(f"{d} does not divide {n}")
    return tuple(t_small[i % d] for i in range(n))


# --------------------------------------------------------------------------
# Reporting helpers
# --------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def check(claim: str, ok: bool) -> None:
    print(f"  [{'OK ' if ok else 'FAIL'}]  {claim}")
    assert ok, claim


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_singleton_theorem(max_n: int = 14) -> None:
    banner("1.  The Rule 110 Singleton Theorem:  #V(110, n) = 1 for every n")
    print("  Rule 110 has g(a,0,c) = c, so a zero forces its right neighbour to zero;")
    print("  the all-ones configuration is destroyed since g(1,1,1) = 0.  Cyclicity")
    print("  then sweeps the lattice, leaving only the all-zero configuration.\n")
    counts = [fixed_count(110, n) for n in range(1, max_n + 1)]
    print(f"  #V(110, n) for n = 1..{max_n}:  {counts}")
    check("count is identically 1 up to n = %d" % max_n, all(c == 1 for c in counts))
    check("the transfer matrix agrees for n up to 10**6",
          all(fixed_count_fast(110, n) == 1 for n in (10, 1000, 10 ** 6)))
    print("\n  Census of the local criterion (four bits of the rule number are pinned):")
    cert = [r for r in range(256) if singleton_criterion(rule_table(r))]
    print(f"    {len(cert)} rules: {cert}")
    check("exactly 16 rules pass the local singleton criterion", len(cert) == 16)
    check("Rule 110 is among them", 110 in cert)
    check("Rule 46 is among them (same four critical bits as Rule 110)", 46 in cert)
    check("every certified rule has #V = 1 up to n = 12",
          all(fixed_count(r, n) == 1 for r in cert for n in range(1, 13)))


def demo_symmetry_census() -> None:
    banner("2.  Reflection and complementation: a Klein four-group of conjugacies")
    print("  Reflecting the lattice conjugates the dynamics of g to that of mirror(g);")
    print("  complementing all cells conjugates it to that of dual(g).  Both the")
    print("  fixed-point count and every exact orbit period are therefore invariant.\n")
    print(f"  Klein orbit of Rule 110: {klein_orbit(110)}")
    check("the partners of Rule 110 are 110, 124, 137, 193",
          klein_orbit(110) == [110, 124, 137, 193])
    for r in (124, 137, 193):
        counts = [fixed_count(r, n) for n in range(1, 13)]
        local = singleton_criterion(rule_table(r))
        print(f"    Rule {r:3d}: #V = {counts[0]} for all tested n"
              f" (passes the LOCAL criterion: {local})")
        check(f"#V({r}, n) = 1 for n <= 12", all(c == 1 for c in counts))
    ext = [r for r in range(256) if ext_singleton_criterion(rule_table(r))]
    loc = [r for r in range(256) if singleton_criterion(rule_table(r))]
    print(f"\n  Local census: {len(loc)} rules.  Symmetry-closed census: {len(ext)} rules.")
    check("the symmetry-closed census has exactly 48 rules", len(ext) == 48)
    check("it contains the local census", set(loc) <= set(ext))
    check("every certified rule really has #V = 1 up to n = 12",
          all(fixed_count(r, n) == 1 for r in ext for n in range(1, 13)))


def demo_arithmetic_counts(max_n: int = 14) -> None:
    banner("3.  Counts that are arithmetic functions of the lattice size")

    def predicted_150(n: int) -> int:
        return 4 if n % 2 == 0 else 2

    def predicted_90(n: int) -> int:
        return 4 if n % 3 == 0 else 1

    def predicted_30(n: int) -> int:
        return 3 if n % 2 == 0 else 1

    for number, predict, formula in (
        (150, predicted_150, "4 if n even, 2 if n odd      (2-periodic fixed configs)"),
        (90, predicted_90, "4 if 3 | n, 1 otherwise      (F_2 Fibonacci, period 3)"),
        (30, predicted_30, "3 if n even, 1 if n odd      (nonlinear, still 2-periodic)"),
    ):
        counts = [fixed_count(number, n) for n in range(1, max_n + 1)]
        print(f"\n  Rule {number}:  {formula}")
        print(f"    enumerated : {counts}")
        print(f"    predicted  : {[predict(n) for n in range(1, max_n + 1)]}")
        check(f"formula for rule {number} holds up to n = {max_n}",
              all(fixed_count(number, n) == predict(n) for n in range(1, max_n + 1)))
        check(f"transfer matrix reproduces rule {number} for huge n",
              all(fixed_count_fast(number, n) == predict(n)
                  for n in (30, 31, 999, 1000, 10 ** 5, 10 ** 5 + 1)))


def demo_traffic_rule(max_n: int = 14) -> None:
    banner("4.  The traffic rule 184: exactly two fixed configurations, always")
    print("  Reading 1 as 'car' and 0 as 'empty road', Rule 184 advances a car exactly")
    print("  when the cell ahead is free.  Its table satisfies: g(a,0,c)=0 forces a=0")
    print("  (emptiness travels LEFT) and g(a,1,c)=1 forces c=1 (cars travel RIGHT).")
    print("  Hence the only stationary states are the empty road and the total jam.\n")
    counts = [fixed_count(184, n) for n in range(1, max_n + 1)]
    print(f"  #V(184, n) for n = 1..{max_n}:  {counts}")
    check("count is identically 2", all(c == 2 for c in counts))
    check("the two fixed configurations are the constants",
          all(set(fixed_configs(184, n)) == {(0,) * n, (1,) * n} for n in range(1, 11)))
    cp = [r for r in range(256) if constant_pair_criterion(rule_table(r))]
    print(f"\n  Census of the constant-pair criterion: {len(cp)} rules: {cp}")
    check("exactly the four rules 176, 178, 184, 186", cp == [176, 178, 184, 186])
    check("all four have #V = 2 up to n = 12",
          all(fixed_count(r, n) == 2 for r in cp for n in range(1, 13)))
    print("\n  A jam relaxing on a ring of 16 sites (Rule 184, 8 time steps):")
    t = rule_table(184)
    s: Config = tuple(1 if i in (3, 4, 5, 6, 10) else 0 for i in range(16))
    for _ in range(8):
        print("    " + "".join("#" if b else "." for b in s))
        s = step(t, s)


def demo_orbits() -> None:
    banner("5.  Orbits: what the fixed-point count cannot see")
    print("  Rule 51 (complement every cell) has NO fixed configuration at all,")
    print("  yet every configuration lies on an orbit of exact period two.")
    for n in range(1, 9):
        periods = {exact_period(51, s) for s in configs(n)}
        check(f"n = {n}: #V(51,n) = 0 and every exact period is 2",
              fixed_count(51, n) == 0 and periods == {2})

    print("\n  Rule 170 (the left shift) has #V = 2 for every n (the two constants),")
    print("  yet the one-hot configuration has exact period exactly n:")
    for n in range(1, 11):
        delta: Config = tuple(1 if i == 0 else 0 for i in range(n))
        p = exact_period(170, delta)
        check(f"n = {n:2d}: #V(170,n) = 2 and per(delta) = {p}",
              fixed_count(170, n) == 2 and p == n)

    print("\n  Rule 110 has a genuine two-cycle on the four-site lattice.")
    t110: Config = (1, 1, 1, 0)
    tbl = rule_table(110)
    print(f"    1110 -> {''.join(map(str, step(tbl, t110)))}"
          f" -> {''.join(map(str, step(tbl, step(tbl, t110))))}")
    check("1110 has exact period 2 on Z/4", exact_period(110, t110) == 2)
    two_per = [s for s in configs(4) if step(tbl, step(tbl, s)) == s]
    print("    All 2-periodic configurations on Z/4: "
          + ", ".join("".join(map(str, s)) for s in two_per))
    check("they are the fixed point plus two 2-cycles", len(two_per) == 5)
    print("\n  Periodic descent transports the two-cycle to every n divisible by 4:")
    for n in (4, 8, 12, 16):
        s = pull(t110, n)
        p = exact_period(110, s)
        check(f"n = {n:2d}: pull(1110) has exact period {p}, and #V(110,n) = 1",
              p == 2 and fixed_count(110, min(n, 14)) == 1)


def demo_separation() -> None:
    banner("6.  Which rules the fixed-point statistic separates - and which it does not")
    print("  (a) #V(90,n) differs from #V(110,n) exactly on the multiples of 3:")
    for n in range(1, 13):
        d = fixed_count(90, n) != fixed_count(110, n)
        check(f"n = {n:2d}: differ = {d}, 3 | n = {n % 3 == 0}", d == (n % 3 == 0))
    print("\n  (b) #V(110,n) < #V(150,n) for every n:")
    check("strict inequality up to n = 14",
          all(fixed_count(110, n) < fixed_count(150, n) for n in range(1, 15)))
    print("\n  (c) but #V(46,n) = #V(110,n) for every n, although the two rules are")
    print("      placed in different qualitative classes: the statistic is blind here.")
    check("rules 46 and 110 agree up to n = 14",
          all(fixed_count(46, n) == fixed_count(110, n) for n in range(1, 15)))
    same_bits = all(rule_table(46)[k] == rule_table(110)[k]
                    for k in ((0, 0, 0), (0, 0, 1), (1, 0, 1), (1, 1, 1)))
    check("they agree in exactly the four bits governing the count", same_bits)


def demo_transfer_matrix() -> None:
    banner("7.  The transfer matrix, and how far the enumeration can be trusted")
    print("  #V(g, n) = trace M(g)^n, where M(g) is the 4x4 adjacency matrix of the")
    print("  de Bruijn graph on pairs (a,b) with edges (a,b) -> (b,c) when g(a,b,c) = b.\n")
    for r in (110, 90, 150, 30, 184, 51):
        m = fixed_de_bruijn_matrix(r)
        brute = [fixed_count(r, n) for n in range(1, 13)]
        fast = [fixed_count_fast(r, n) for n in range(1, 13)]
        print(f"  Rule {r:3d}: M = {m}")
        print(f"            trace M^n = {fast}")
        check(f"transfer matrix matches enumeration for rule {r}", brute == fast)
    print("\n  Full agreement over all 256 rules and all n <= 12:")
    ok = all(fixed_count(r, n) == fixed_count_fast(r, n)
             for r in range(256) for n in range(1, 13))
    check("all 256 rules, n = 1..12", ok)
    print("\n  Rules whose count is 1 for every n <= 7 (candidates for the singleton")
    print("  property), compared with the 48 certified by symmetry-closed propagation:")
    unit = [r for r in range(256) if all(fixed_count_fast(r, n) == 1 for n in range(1, 8))]
    ext = [r for r in range(256) if ext_singleton_criterion(rule_table(r))]
    print(f"    candidates: {len(unit)}   certified: {len(ext)}   gap: {len(unit) - len(ext)}")
    check("78 candidates, 48 certified, 30 open", (len(unit), len(ext)) == (78, 48))
    check("certified rules are candidates", set(ext) <= set(unit))
    check("all 78 candidates still have count 1 at n = 40 (evidence for the conjecture)",
          all(fixed_count_fast(r, 40) == 1 for r in unit))


def main() -> None:
    print(__doc__)
    demo_singleton_theorem()
    demo_symmetry_census()
    demo_arithmetic_counts()
    demo_traffic_rule()
    demo_orbits()
    demo_separation()
    demo_transfer_matrix()
    banner("All checks passed.")


if __name__ == "__main__":
    main()
