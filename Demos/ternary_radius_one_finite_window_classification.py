"""
Reversible radius-one cellular automata over a three-letter alphabet
====================================================================

Numerical companion to the paper "Reversible radius-one cellular automata over
three letters: refutation of the single-coordinate classification, a finite
reversibility test, and the inverse-radius gap".

Everything is self-contained: no third-party packages are required.

Setting
-------
Let ``A`` be a finite alphabet with ``q`` letters.  A *radius-one local rule* is
a map ``g : A x A x A -> A``.  On the cycle ``Z/n`` it induces the *global map*

    (G_n s)(i) = g(s(i-1), s(i), s(i+1)),      i in Z/n.

``g`` is *cycle-bijective* (= reversible) when ``G_n`` is a bijection for every
``n >= 1``.

The script demonstrates, by direct computation:

  1. the pair-graph reversibility test, cross-checked against brute force;
  2. the sign-twisted counterexample  g*(a,b,c) = sgn(a) * b * sgn(c)  over F_3,
     which is an involution on every cycle yet uses all three window cells;
  3. the eighteen-element family of counterexamples;
  4. the classification of affine rules  a*alpha + b*beta + c*gamma + delta;
  5. sharpness of the length-8 test inside the affine class;
  6. the binary alphabet, where the single-coordinate classification is true;
  7. the conditional-transposition rule, reversible with decoding width exactly
     four: no window-three inverse exists at any offset.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Iterable, List, Sequence, Set, Tuple

Rule = Dict[Tuple[int, int, int], int]

# ---------------------------------------------------------------------------
# Basic machinery
# ---------------------------------------------------------------------------


def make_rule(f: Callable[[int, int, int], int], q: int) -> Rule:
    """Tabulate a local rule given as a Python function."""
    return {(a, b, c): f(a, b, c) % q for a, b, c in product(range(q), repeat=3)}


def global_map(rule: Rule, s: Sequence[int]) -> Tuple[int, ...]:
    """Apply the global map of ``rule`` to the configuration ``s`` on a cycle."""
    n = len(s)
    return tuple(rule[(s[(i - 1) % n], s[i], s[(i + 1) % n])] for i in range(n))


def injective_on_cycle(rule: Rule, q: int, n: int) -> bool:
    """Brute-force injectivity of the global map on the cycle of length ``n``."""
    seen: Set[Tuple[int, ...]] = set()
    for s in product(range(q), repeat=n):
        img = global_map(rule, s)
        if img in seen:
            return False
        seen.add(img)
    return True


def first_failure_length(rule: Rule, q: int, bound: int) -> int:
    """Smallest cycle length <= ``bound`` on which injectivity fails (0 if none)."""
    for n in range(1, bound + 1):
        if not injective_on_cycle(rule, q, n):
            return n
    return 0


# ---------------------------------------------------------------------------
# The pair graph: a polynomial-time reversibility test
# ---------------------------------------------------------------------------


def pair_graph(rule: Rule, q: int) -> Dict[Tuple[int, int, int, int], List[Tuple[int, int, int, int]]]:
    """Vertices are pairs of length-two words; edges follow overlapping windows.

    There is an edge  ((a,b),(a',b')) -> ((b,c),(b',c'))  exactly when the two
    windows produce the same output letter, g(a,b,c) = g(a',b',c').
    """
    adj: Dict[Tuple[int, int, int, int], List[Tuple[int, int, int, int]]] = {}
    for a, b, ap, bp in product(range(q), repeat=4):
        out: List[Tuple[int, int, int, int]] = []
        for c, cp in product(range(q), repeat=2):
            if rule[(a, b, c)] == rule[(ap, bp, cp)]:
                out.append((b, c, bp, cp))
        adj[(a, b, ap, bp)] = out
    return adj


def vertices_on_cycles(
    adj: Dict[Tuple[int, int, int, int], List[Tuple[int, int, int, int]]]
) -> Set[Tuple[int, int, int, int]]:
    """All vertices that lie on at least one directed cycle."""
    on_cycle: Set[Tuple[int, int, int, int]] = set()
    for start in adj:
        stack = list(adj[start])
        seen: Set[Tuple[int, int, int, int]] = set()
        while stack:
            v = stack.pop()
            if v == start:
                on_cycle.add(start)
                break
            if v in seen:
                continue
            seen.add(v)
            stack.extend(adj[v])
    return on_cycle


def is_cycle_bijective(rule: Rule, q: int) -> bool:
    """Reversibility test.

    A failure of injectivity on some cycle is the same thing as a *collision*: a
    pair of periodic configurations that are locally indistinguishable and differ
    somewhere.  Collisions are precisely the directed cycles of the pair graph
    passing through a vertex ((a,b),(a',b')) with a != a'.  The test therefore
    costs O(q^4 * q^2) per rule, independent of the cycle length.
    """
    adj = pair_graph(rule, q)
    cyc = vertices_on_cycles(adj)
    return not any(a != ap for (a, _b, ap, _bp) in cyc)


# ---------------------------------------------------------------------------
# Dependence on the three window cells
# ---------------------------------------------------------------------------


def depends_left(rule: Rule, q: int) -> bool:
    return any(rule[(a, b, c)] != rule[(a2, b, c)]
               for a, a2, b, c in product(range(q), repeat=4))


def depends_middle(rule: Rule, q: int) -> bool:
    return any(rule[(a, b, c)] != rule[(a, b2, c)]
               for a, b, b2, c in product(range(q), repeat=4))


def depends_right(rule: Rule, q: int) -> bool:
    return any(rule[(a, b, c)] != rule[(a, b, c2)]
               for a, b, c, c2 in product(range(q), repeat=4))


def is_single_coordinate_perm(rule: Rule, q: int) -> bool:
    """Is the rule one window cell followed by a permutation of the alphabet?"""
    for coord in range(3):
        table = {}
        ok = True
        for a, b, c in product(range(q), repeat=3):
            key = (a, b, c)[coord]
            val = rule[(a, b, c)]
            if table.setdefault(key, val) != val:
                ok = False
                break
        if ok and len(set(table.values())) == q:
            return True
    return False


# ---------------------------------------------------------------------------
# The rules of the paper
# ---------------------------------------------------------------------------


def sgn(u: int, x: int) -> int:
    """1 if x = 0 and u otherwise: an even, unit-valued function on F_3."""
    return 1 if x == 0 else u


def sign_rule(u: int, v: int) -> Rule:
    """g_{u,v}(a,b,c) = sgn(u,a) * b * sgn(v,c) over F_3."""
    return make_rule(lambda a, b, c: sgn(u, a) * b * sgn(v, c), 3)


def fam_rule(u: int, v: int, c0: int, d: int) -> Rule:
    """The sign-twisted rule post-composed with the permutation x -> c0*x + d."""
    return make_rule(lambda a, b, c: c0 * (sgn(u, a) * b * sgn(v, c)) + d, 3)


def add_rule(alpha: int, beta: int, gamma: int, delta: int) -> Rule:
    """The affine rule  a,b,c -> alpha*a + beta*b + gamma*c + delta  over F_3."""
    return make_rule(lambda a, b, c: alpha * a + beta * b + gamma * c + delta, 3)


def exactly_one_nonzero(alpha: int, beta: int, gamma: int) -> bool:
    return [alpha, beta, gamma].count(0) == 2


def swap01(x: int) -> int:
    """The transposition of 0 and 1 that fixes 2."""
    return 2 if x == 2 else 1 - x


G_TWIST: Rule = make_rule(
    lambda a, b, c: swap01(a) if (b != 0 and c == 2) else a, 3
)


def d_twist(u0: int, u1: int, u2: int, u3: int) -> int:
    """Window-four decoder for the conditional-transposition rule."""
    fired = (u2 == 2) and ((u1 != 1) if u3 == 2 else (u1 != 0))
    return swap01(u0) if fired else u0


def twist_rule(x0: int, x1: int, x2: int, q: int) -> Rule:
    """Conditional transposition over an arbitrary alphabet of q >= 3 letters."""

    def f(a: int, b: int, c: int) -> int:
        if c != x0:
            return b
        if b == x1:
            return x2
        if b == x2:
            return x1
        return b

    return make_rule(f, q)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_test_agreement() -> None:
    banner("1.  The pair-graph test agrees with brute force")
    samples: List[Tuple[str, Rule]] = [
        ("identity        a,b,c -> b", make_rule(lambda a, b, c: b, 3)),
        ("shift           a,b,c -> a", make_rule(lambda a, b, c: a, 3)),
        ("sum             a,b,c -> a+b+c", add_rule(1, 1, 1, 0)),
        ("a + b + 2c", add_rule(1, 1, 2, 0)),
        ("sign-twist g*", sign_rule(2, 2)),
        ("conditional transposition", G_TWIST),
    ]
    print(f"{'rule':<32}{'pair graph':>12}{'cycles n<=9':>14}{'1st failure':>13}")
    for name, rule in samples:
        pg = is_cycle_bijective(rule, 3)
        bf = all(injective_on_cycle(rule, 3, n) for n in range(1, 10))
        ff = first_failure_length(rule, 3, 9)
        print(f"{name:<32}{str(pg):>12}{str(bf):>14}{(ff or '-'):>13}")


def demo_sign_twist() -> None:
    banner("2.  The sign-twisted rule g*(a,b,c) = sgn(a) b sgn(c) refutes the claim")
    g = sign_rule(2, 2)
    print("Window table of g*  (rows: (a,b), columns: c):")
    print("      c=0  c=1  c=2")
    for a, b in product(range(3), repeat=2):
        row = "  ".join(f"{g[(a, b, c)]:>3}" for c in range(3))
        print(f"a={a},b={b}  {row}")
    print()
    print("depends on left / middle / right cell:",
          depends_left(g, 3), depends_middle(g, 3), depends_right(g, 3))
    print("single coordinate followed by a permutation:", is_single_coordinate_perm(g, 3))
    print("reversible on every cycle:", is_cycle_bijective(g, 3))
    print()
    print("Involution check on all cycles of length 1..8:")
    for n in range(1, 9):
        ok = all(global_map(g, global_map(g, s)) == s
                 for s in product(range(3), repeat=n))
        print(f"   n = {n}: G_n o G_n = identity  ->  {ok}")
    print()
    print("Sample orbit on the 6-cycle:")
    s = (0, 1, 2, 2, 0, 1)
    print("   s      =", s)
    print("   G(s)   =", global_map(g, s))
    print("   G(G(s))=", global_map(g, global_map(g, s)))


def demo_eighteen() -> None:
    banner("3.  Eighteen counterexamples - as many as the claim allows rules in total")
    rules = []
    for u, v, c0, d in product([1, 2], [1, 2], [1, 2], [0, 1, 2]):
        if u == 1 and v == 1:
            continue
        rules.append(((u, v, c0, d), fam_rule(u, v, c0, d)))
    distinct = {tuple(sorted(r.items())) for _, r in rules}
    print(f"parameter tuples (u,v,c,d) with u,v,c units and (u,v) != (1,1): {len(rules)}")
    print(f"distinct rule tables:                                          {len(distinct)}")
    all_rev = all(is_cycle_bijective(r, 3) for _, r in rules)
    none_trivial = not any(is_single_coordinate_perm(r, 3) for _, r in rules)
    print(f"all reversible on every cycle:                                 {all_rev}")
    print(f"none of the predicted single-coordinate form:                  {none_trivial}")
    print()
    print("For comparison: the claim predicts 3 coordinates x 6 permutations = 18 rules,")
    print("all of which are indeed reversible:")
    predicted = []
    perms = [p for p in product(range(3), repeat=3) if len(set(p)) == 3]
    for coord in range(3):
        for p in perms:
            predicted.append(make_rule(lambda a, b, c, k=coord, pp=p: pp[(a, b, c)[k]], 3))
    print(f"   number of predicted rules: {len({tuple(sorted(r.items())) for r in predicted})}")
    print(f"   all reversible:            {all(is_cycle_bijective(r, 3) for r in predicted)}")


def demo_affine() -> None:
    banner("4.  Exhaustive classification of the 81 affine ternary rules")
    mismatches = 0
    reversible = []
    for alpha, beta, gamma, delta in product(range(3), repeat=4):
        rule = add_rule(alpha, beta, gamma, delta)
        rev = is_cycle_bijective(rule, 3)
        pred = exactly_one_nonzero(alpha, beta, gamma)
        if rev != pred:
            mismatches += 1
        if rev:
            reversible.append((alpha, beta, gamma, delta))
    print(f"affine rules tested:                       81")
    print(f"reversible ones:                           {len(reversible)}")
    print(f"predicted by 'exactly one coefficient !=0': "
          f"{sum(1 for a, b, c, d in product(range(3), repeat=4) if exactly_one_nonzero(a, b, c))}")
    print(f"mismatches between test and prediction:    {mismatches}")
    print()
    print("First failure length of each non-reversible affine rule "
          "(only 1, 2, 4, 8 occur):")
    lengths: Dict[int, int] = {}
    for alpha, beta, gamma in product(range(3), repeat=3):
        if exactly_one_nonzero(alpha, beta, gamma):
            continue
        ell = first_failure_length(add_rule(alpha, beta, gamma, 0), 3, 8)
        lengths[ell] = lengths.get(ell, 0) + 1
    for ell in sorted(lengths):
        print(f"   length {ell}: {lengths[ell]} coefficient triples")


def demo_sharpness() -> None:
    banner("5.  Sharpness of the length-8 test:  a + b + 2c")
    rule = add_rule(1, 1, 2, 0)
    for n in range(1, 10):
        print(f"   injective on the cycle of length {n}: "
              f"{injective_on_cycle(rule, 3, n)}")
    print()
    print("An explicit kernel configuration on the 8-cycle:")
    s = (1, 1, 2, 0, 2, 2, 1, 0)
    n = len(s)
    residues = [(s[(i - 1) % n] + s[i] + 2 * s[(i + 1) % n]) % 3 for i in range(n)]
    print(f"   s          = {s}")
    print(f"   a+b+2c at each site = {residues}   (all zero -> s collides with 0)")
    print(f"   G(s) = {global_map(rule, s)}")
    print(f"   G(0) = {global_map(rule, (0,) * n)}")
    print()
    print("Because injectivity at length n implies injectivity at every divisor")
    print("of n, the failure at length 8 propagates to 16, 24, 32, ...: the set of")
    print("bad cycle lengths of this rule is infinite.")


def demo_binary() -> None:
    banner("6.  The binary alphabet: the classification claim is TRUE")
    up_to_3 = 0
    up_to_4 = 0
    survivors = []
    for values in product(range(2), repeat=8):
        rule = {key: values[i]
                for i, key in enumerate(product(range(2), repeat=3))}
        if all(injective_on_cycle(rule, 2, n) for n in (1, 2, 3)):
            up_to_3 += 1
        if all(injective_on_cycle(rule, 2, n) for n in (1, 2, 3, 4)):
            up_to_4 += 1
            survivors.append(rule)
    print(f"binary rules in total:                            256")
    print(f"bijective on the cycles of length 1, 2, 3:        {up_to_3}")
    print(f"bijective on the cycles of length 1, 2, 3, 4:     {up_to_4}")
    print(f"of those, single coordinate + permutation:        "
          f"{sum(1 for r in survivors if is_single_coordinate_perm(r, 2))}")
    print()
    print("By contrast, over three letters the conditional transposition")
    print("   g(a,b,c) = (transpose 1 and 2 in b) if c = 0, else b")
    tw = twist_rule(0, 1, 2, 3)
    print(f"   is reversible:                    {is_cycle_bijective(tw, 3)}")
    print(f"   uses its middle and right cells:  "
          f"{depends_middle(tw, 3) and depends_right(tw, 3)}")
    print(f"   single coordinate + permutation:  {is_single_coordinate_perm(tw, 3)}")
    print("and the same construction works over every alphabet with >= 3 letters:")
    for q in (3, 4, 5):
        tw = twist_rule(0, 1, 2, q)
        print(f"   q = {q}: reversible = {is_cycle_bijective(tw, q)}, "
              f"trivial = {is_single_coordinate_perm(tw, q)}")


def demo_inverse_radius() -> None:
    banner("7.  A reversible rule whose inverse needs a wider window")
    g = G_TWIST
    print(f"reversible on every cycle:        {is_cycle_bijective(g, 3)}")
    print(f"single coordinate + permutation:  {is_single_coordinate_perm(g, 3)}")
    ok4 = all(
        d_twist(g[(x0, x1, x2)], g[(x1, x2, x3)], g[(x2, x3, x4)], g[(x3, x4, x5)]) == x0
        for x0, x1, x2, x3, x4, x5 in product(range(3), repeat=6)
    )
    print(f"window-four decoder recovers the leftmost cell on all 3^6 words: {ok4}")
    print()
    print("No window-three decoder exists, at any of the five offsets.")
    print("Each offset admits two input words with identical output triples but")
    print("different letters at that offset:")
    triples: Dict[Tuple[int, int, int], List[Tuple[int, ...]]] = {}
    for w in product(range(3), repeat=5):
        v, x1, x2, x3, z = w
        key = (g[(v, x1, x2)], g[(x1, x2, x3)], g[(x2, x3, z)])
        triples.setdefault(key, []).append(w)
    names = ["1st", "2nd", "3rd", "4th", "5th"]
    for pos in range(5):
        witness = None
        for words in triples.values():
            for i in range(len(words)):
                for j in range(i + 1, len(words)):
                    if words[i][pos] != words[j][pos]:
                        witness = (words[i], words[j])
                        break
                if witness:
                    break
            if witness:
                break
        print(f"   {names[pos]} cell: {witness[0]} vs {witness[1]} "
              f"-> same output triple, different {names[pos]} letter")
    print()
    print("Concretely, on the 5-cycle the all-zero configuration and (0,0,1,1,2)")
    print("have images that agree in three consecutive positions but differ in the")
    print("middle one, so no radius-one inverse can separate them:")
    s0 = (0, 0, 0, 0, 0)
    s1 = (0, 0, 1, 1, 2)
    i0, i1 = global_map(g, s0), global_map(g, s1)
    print(f"   G(0,0,0,0,0)   = {i0}")
    print(f"   G(0,0,1,1,2)   = {i1}")
    print(f"   positions 1,2,3 of the images: {i0[1:4]} vs {i1[1:4]}")
    print(f"   originals at position 2:       {s0[2]} vs {s1[2]}")


def main() -> None:
    demo_test_agreement()
    demo_sign_twist()
    demo_eighteen()
    demo_affine()
    demo_sharpness()
    demo_binary()
    demo_inverse_radius()
    print()
    print("Done.")


if __name__ == "__main__":
    main()
