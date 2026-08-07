#!/usr/bin/env python3
"""
Dependency-Adjusted Fitness of Mathematical Theories
====================================================

Numerical demonstrations of the exact results in the accompanying paper.

A *theory* is recorded by the transitive dependency closure of the material it
uses, together with the corpus statements it proves.  Its dependency-adjusted
cost is the total source length of that closure, each item charged exactly
once; its fitness is (statements proved) / cost.

The demonstrations below verify, on explicit finite data:

  1. Canonicity of the transitive closure: it is the LEAST dependency-closed
     superset of a base set.
  2. Exact merge accounting:  cost(T u U) + shared mass = cost(T) + cost(U).
  3. Fitness is the ordinal inverse of cost on a fixed corpus; the canonical
     library (the closure of the corpus' proof bases) is the global champion.
  4. Failure of canonicity with two inequivalent proof routes -- two cost-equal
     champions whose closures have empty intersection -- and survival of a
     minimum-cost cover.
  5. The exact k-fold reuse identity:
        cost(library) + k * core = sum_i cost(specialist_i) + core.
  6. The composition phase transition: fitness rises / is neutral / falls
     according as adapter cost < / = / > shared dependency mass.
  7. Exact candidate counts: independent parts multiply, the free family of n
     items has 2^n usable sub-libraries, the chain has exactly n+1.
  8. The quantitative adapter valley: guaranteed relative overshoot
     (alpha - beta) / (1 + beta).
  9. Three-style metastability: three distinct strict local maxima, only one
     of which is global.
 10. No global maximum without normalisation: raw theorems-per-line diverges
     under conservative inflation, while the semantics never changes.

Pure standard library; run with `python3 demo.py`.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import chain, combinations
from math import isqrt
from typing import Callable, Dict, FrozenSet, Iterable, Iterator, List, Optional, Set, Tuple

Item = int
Deps = Dict[Item, Set[Item]]


# ---------------------------------------------------------------------------
# 0.  Core machinery
# ---------------------------------------------------------------------------


def is_dependency_closed(deps: Deps, s: Iterable[Item]) -> bool:
    """A set is dependency-closed when it contains the direct dependencies of
    each of its members -- i.e. it is a self-contained development."""
    sset = set(s)
    return all(deps.get(i, set()) <= sset for i in sset)


def transitive_closure(deps: Deps, base: Iterable[Item]) -> Set[Item]:
    """The least dependency-closed superset of `base`.

    Worklist expansion; terminates in at most |universe| rounds.
    """
    out: Set[Item] = set(base)
    work: List[Item] = list(out)
    while work:
        i = work.pop()
        for j in deps.get(i, set()):
            if j not in out:
                out.add(j)
                work.append(j)
    return out


def cost(length: Callable[[Item], int], closure: Iterable[Item]) -> int:
    """Dependency-adjusted cost: each item in the closure charged once."""
    return sum(length(i) for i in closure)


def fitness(n_proved: int, c: int) -> Fraction:
    """Corpus statements proved per unit of dependency-adjusted cost."""
    return Fraction(n_proved, c)


def powerset(items: Iterable[Item]) -> Iterator[Tuple[Item, ...]]:
    xs = list(items)
    return chain.from_iterable(combinations(xs, r) for r in range(len(xs) + 1))


def closed_subsets(deps: Deps, universe: Iterable[Item]) -> List[FrozenSet[Item]]:
    """All usable sub-libraries: dependency-closed subsets of the universe."""
    us = list(universe)
    return [
        frozenset(s) for s in powerset(us) if is_dependency_closed(deps, s)
    ]


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


# ---------------------------------------------------------------------------
# 1.  Canonicity of the transitive closure
# ---------------------------------------------------------------------------


def demo_closure_minimality() -> None:
    banner("1.  The transitive closure is the LEAST dependency-closed superset")

    # 0 <- 1 <- 2,  3 <- 4,  5 isolated
    deps: Deps = {0: set(), 1: {0}, 2: {1}, 3: set(), 4: {3}, 5: set()}
    universe = set(deps)
    base = {2, 4}

    cl = transitive_closure(deps, base)
    print(f"  dependency structure : {{i: deps(i)}} = "
          f"{{ {', '.join(f'{k}:{sorted(v)}' for k, v in deps.items())} }}")
    print(f"  base                 : {sorted(base)}")
    print(f"  transitive closure   : {sorted(cl)}")
    print(f"  is dependency-closed : {is_dependency_closed(deps, cl)}")

    # Check minimality by brute force over every dependency-closed superset.
    supersets = [
        s for s in closed_subsets(deps, universe) if base <= set(s)
    ]
    minimal = all(cl <= set(s) for s in supersets)
    print(f"  dependency-closed supersets of the base : {len(supersets)}")
    print(f"  closure contained in every one of them  : {minimal}")
    assert minimal and is_dependency_closed(deps, cl)
    print("  => the cost model is canonical: no accounting slack.")


# ---------------------------------------------------------------------------
# 2.  Exact merge accounting (inclusion-exclusion)
# ---------------------------------------------------------------------------


def demo_merge_accounting() -> None:
    banner("2.  Exact merge accounting:  cost(T u U) + shared = cost(T) + cost(U)")

    length = lambda i: 10 * (i + 1)
    ct = {0, 1, 2, 3}
    cu = {2, 3, 4, 5}

    merged = ct | cu
    shared = ct & cu
    lhs = cost(length, merged) + cost(length, shared)
    rhs = cost(length, ct) + cost(length, cu)

    print(f"  closure(T) = {sorted(ct)}   cost = {cost(length, ct)}")
    print(f"  closure(U) = {sorted(cu)}   cost = {cost(length, cu)}")
    print(f"  pooled     = {sorted(merged)}   cost = {cost(length, merged)}")
    print(f"  shared     = {sorted(shared)}   mass = {cost(length, shared)}")
    print(f"  {cost(length, merged)} + {cost(length, shared)} = {lhs}"
          f"   vs   {cost(length, ct)} + {cost(length, cu)} = {rhs}")
    assert lhs == rhs
    print("  => pooling saves EXACTLY the shared mass.")


# ---------------------------------------------------------------------------
# 3.  The canonical library is the global champion
# ---------------------------------------------------------------------------


def demo_canonical_champion() -> None:
    banner("3.  The canonical library is the dependency-adjusted global champion")

    # Items 0..7.  Corpus statements have proof bases inside the items.
    deps: Deps = {0: set(), 1: {0}, 2: {1}, 3: {0}, 4: {3}, 5: set(), 6: {5}, 7: {6}}
    length = lambda i: 5
    corpus_bases = {"s1": {2}, "s2": {4}}          # two statements, one route each
    universe = set(deps)

    base = set().union(*corpus_bases.values())
    canonical = transitive_closure(deps, base)
    can_cost = cost(length, canonical)
    print(f"  proof bases    : {corpus_bases}")
    print(f"  canonical lib  : {sorted(canonical)}  cost = {can_cost}"
          f"  fitness = {fitness(2, can_cost)}")

    # Every dependency-closed competitor that covers the corpus.
    competitors = [
        s for s in closed_subsets(deps, universe)
        if all(b <= set(s) for b in corpus_bases.values())
    ]
    print(f"  dependency-closed covering developments : {len(competitors)}")
    worst = max(competitors, key=lambda s: cost(length, s))
    print(f"  most bloated competitor : {sorted(worst)}"
          f"  fitness = {fitness(2, cost(length, worst))}")
    ok = all(
        fitness(2, cost(length, s)) <= fitness(2, can_cost) for s in competitors
    )
    embeds = all(canonical <= set(s) for s in competitors)
    print(f"  canonical closure embeds in every competitor : {embeds}")
    print(f"  canonical library has maximal fitness        : {ok}")
    assert ok and embeds
    print("  => reuse wins structurally: every rival must contain the shared core.")


# ---------------------------------------------------------------------------
# 4.  Two routes destroy canonicity, but not existence
# ---------------------------------------------------------------------------


def min_cost_cover(
    length: Callable[[Item], int],
    routes: Dict[str, List[Set[Item]]],
    universe: Set[Item],
) -> Tuple[FrozenSet[Item], int]:
    """Minimum-cost covering sub-library under alternative proof routes.

    Exhaustive over subsets of the universe: exponential, and provably so in
    general (the problem is a weighted set cover in disguise).
    """
    best: Optional[FrozenSet[Item]] = None
    best_cost = None
    for s in powerset(sorted(universe)):
        sset = set(s)
        if all(any(r <= sset for r in rs) for rs in routes.values()):
            c = cost(length, sset)
            if best_cost is None or c < best_cost:
                best, best_cost = frozenset(sset), c
    assert best is not None and best_cost is not None
    return best, best_cost


def demo_two_routes() -> None:
    banner("4.  Two inequivalent proof routes: canonicity fails, existence survives")

    length = lambda i: 1
    r1, r2 = {1}, {2}
    print(f"  one statement, two routes: {sorted(r1)} and {sorted(r2)}")
    f1, f2 = fitness(1, cost(length, r1)), fitness(1, cost(length, r2))
    print(f"  fitness of route 1 = {f1},  fitness of route 2 = {f2}  (equal)")
    print(f"  closures incomparable : {not (r1 <= r2) and not (r2 <= r1)}")
    print(f"  intersection          : {sorted(r1 & r2)}  (proves nothing)")
    assert f1 == f2 and not (r1 <= r2) and not (r2 <= r1) and not (r1 & r2)
    print("  => no least covering closure exists; the champion is only")
    print("     determined up to cost.")

    print()
    print("  But a minimum-cost cover is still attained.  A larger instance:")
    routes = {
        "s1": [{1, 2}, {3}],
        "s2": [{2, 4}, {3, 4}],
        "s3": [{5}, {1, 3}],
    }
    lengths = {1: 4, 2: 4, 3: 5, 4: 2, 5: 9}
    length2 = lambda i: lengths[i]
    cover, c = min_cost_cover(length2, routes, set(lengths))
    print(f"  routes  : {routes}")
    print(f"  lengths : {lengths}")
    print(f"  minimum-cost cover : {sorted(cover)}  cost = {c}"
          f"  fitness = {fitness(3, c)}")
    print("  => existence is robust; only the METHOD of finding the optimum")
    print("     changes, from a closure computation to a set-cover search.")


# ---------------------------------------------------------------------------
# 5.  Exact k-fold reuse identity
# ---------------------------------------------------------------------------


def demo_reuse_identity() -> None:
    banner("5.  Exact k-fold reuse identity: specialists waste (k-1) copies of the core")

    length = lambda i: 3
    core = {100, 101, 102, 103}
    privs = {0: {0, 1}, 1: {2, 3, 4}, 2: {5}, 3: {6, 7}}
    k = len(privs)

    library = core | set().union(*privs.values())
    lib_cost = cost(length, library)
    spec_costs = {i: cost(length, core | p) for i, p in privs.items()}
    core_cost = cost(length, core)

    lhs = lib_cost + k * core_cost
    rhs = sum(spec_costs.values()) + core_cost

    print(f"  core          : {sorted(core)}   cost = {core_cost}")
    for i, p in privs.items():
        print(f"  specialist {i}  : core + {sorted(p)}   cost = {spec_costs[i]}")
    print(f"  shared library: cost = {lib_cost}")
    print(f"  identity      : {lib_cost} + {k}*{core_cost} = {lhs}"
          f"   vs   {sum(spec_costs.values())} + {core_cost} = {rhs}")
    assert lhs == rhs
    print(f"  waste of the suite = (k-1)*core = {(k - 1) * core_cost}")

    corpus = 12
    print(f"  fitness, suite   = {fitness(corpus, sum(spec_costs.values()))}")
    print(f"  fitness, library = {fitness(corpus, lib_cost)}   (strictly greater)")
    assert fitness(corpus, lib_cost) > fitness(corpus, sum(spec_costs.values()))
    print("  => the saving grows LINEARLY in the number of clients.")


# ---------------------------------------------------------------------------
# 6.  The composition phase transition
# ---------------------------------------------------------------------------


def demo_phase_transition() -> None:
    banner("6.  Composition phase transition at adapter = shared mass")

    length = lambda i: 10
    ct, cu = {0, 1, 2, 3}, {2, 3, 4, 5}
    n_corpus = 4

    shared = cost(length, ct & cu)
    dup = cost(length, ct) + cost(length, cu)
    pooled = cost(length, ct | cu)

    print(f"  duplicate cost = {dup},  pooled cost = {pooled},"
          f"  shared mass = {shared}")
    print(f"  dependency density rho = {Fraction(shared, dup)}")
    print()
    print("     A   composed cost   composed fitness   duplicated fitness   verdict")
    print("   " + "-" * 70)
    for a in (0, 10, 15, 20, 25, 30, 40):
        comp = pooled + a
        fc, fd = fitness(n_corpus, comp), fitness(n_corpus, dup)
        verdict = "GAIN " if fc > fd else ("neutral" if fc == fd else "LOSS ")
        # the trichotomy, verified numerically
        assert (fc > fd) == (a < shared)
        assert (fc == fd) == (a == shared)
        assert (fc < fd) == (a > shared)
        print(f"   {a:3d}   {comp:12d}   {str(fc):>16}   {str(fd):>18}   {verdict}")
    print()
    print(f"  => the crossing sits exactly at A = shared mass = {shared}.")

    print()
    print("  Product corpora: candidates multiply while costs add.")
    ct_cost, cu_cost, adapter = 100, 60, 40
    for m in (2, 3, 5, 10):
        comp = ct_cost + cu_cost + adapter          # upper bound on composed cost
        f_single = Fraction(4, ct_cost)
        f_product = Fraction(4 * m, comp)
        flag = "composition wins" if f_product > f_single else "component wins"
        print(f"   |P(U)| = {m:2d}:  single = {f_single}   product = {f_product}"
              f"   -> {flag}")
    print("  => multiplicative growth eventually beats additive cost,")
    print("     whatever the adapter charge.")


# ---------------------------------------------------------------------------
# 7.  Exact candidate counts
# ---------------------------------------------------------------------------


def demo_candidate_counts() -> None:
    banner("7.  Exact counts of usable sub-libraries")

    print("   n |  free (2^n)  chain (n+1)   verified by enumeration")
    print("  " + "-" * 58)
    for n in range(1, 9):
        free_deps: Deps = {i: set() for i in range(n)}
        chain_deps: Deps = {i: (set() if i == 0 else {i - 1}) for i in range(n)}
        universe = list(range(n))
        n_free = len(closed_subsets(free_deps, universe))
        n_chain = len(closed_subsets(chain_deps, universe))
        assert n_free == 2 ** n and n_chain == n + 1
        print(f"  {n:2d} | {2 ** n:11d}  {n + 1:11d}   free={n_free}, chain={n_chain}  OK")
    print("  => for every n >= 2 the chain has strictly fewer usable")
    print("     sub-libraries, and the gap is exponential.")

    print()
    print("  Independent parts multiply exactly:")
    # A = {0,1,2} a chain; B = {10,11} free; no dependency crosses.
    deps: Deps = {0: set(), 1: {0}, 2: {1}, 10: set(), 11: set()}
    a_items, b_items = [0, 1, 2], [10, 11]
    na = len(closed_subsets(deps, a_items))
    nb = len(closed_subsets(deps, b_items))
    nab = len(closed_subsets(deps, a_items + b_items))
    print(f"   N(A) = {na}  (chain of 3)")
    print(f"   N(B) = {nb}  (free pair)")
    print(f"   N(A u B) = {nab}   and   N(A)*N(B) = {na * nb}")
    assert nab == na * nb
    print("  => a bijection, not an estimate.")


# ---------------------------------------------------------------------------
# 8.  The quantitative adapter valley
# ---------------------------------------------------------------------------


def demo_adapter_valley() -> None:
    banner("8.  The quantitative adapter valley")

    content = Fraction(100)
    alpha, beta = Fraction(1, 2), Fraction(1, 10)
    # A three-state migration across an interface boundary.
    walk = [
        {"len": (1 + beta) * content, "iface": 0},   # efficient endpoint
        {"len": (1 + alpha) * content, "iface": 0},  # boundary-crossing state
        {"len": (1 + beta) * content, "iface": 1},   # efficient endpoint
    ]
    m = min(walk[0]["len"], walk[-1]["len"])
    guaranteed = (alpha - beta) / (1 + beta)

    # locate the crossing step -- it must exist since the endpoints differ
    crossing = next(
        i for i in range(len(walk) - 1) if walk[i]["iface"] != walk[i + 1]["iface"]
    )
    realised = (walk[crossing]["len"] - m) / m

    print(f"  content C = {content},  alpha = {alpha},  beta = {beta}")
    print(f"  states    : lengths {[str(w['len']) for w in walk]},"
          f" interfaces {[w['iface'] for w in walk]}")
    print(f"  crossing step index          : {crossing}")
    print(f"  smaller endpoint length m    : {m}")
    print(f"  guaranteed relative overshoot: (a-b)/(1+b) = {guaranteed}"
          f" = {float(guaranteed):.4f}")
    print(f"  realised relative overshoot  : {realised} = {float(realised):.4f}")
    assert realised >= guaranteed
    print("  => the bound is attained: the valley is unavoidable, and its depth")
    print("     depends only on the two efficiency exponents.")

    print()
    print("  Guaranteed overshoot as a function of the exponents:")
    print("     beta \\ alpha    0.25      0.50      0.75      1.00")
    for b in (Fraction(0), Fraction(1, 20), Fraction(1, 10), Fraction(1, 5)):
        row = []
        for a in (Fraction(1, 4), Fraction(1, 2), Fraction(3, 4), Fraction(1)):
            row.append(f"{float((a - b) / (1 + b)):8.4f}" if b < a else "       -")
        print(f"       {float(b):5.2f}     " + "  ".join(row))


# ---------------------------------------------------------------------------
# 9.  Three-style metastability
# ---------------------------------------------------------------------------


def demo_metastability() -> None:
    banner("9.  Three-style metastability: three peaks, only one of them global")

    fit = [Fraction(x) for x in (1, 2, 5, 3, 7, 4, 6, 2, 9)]
    style = [i // 3 for i in range(9)]
    names = {0: "algebraic", 1: "analytic", 2: "combinatorial"}
    adj = lambda i, j: style[i] == style[j]   # bounded refactorings preserve style

    def is_strict_local_max(b: int) -> bool:
        return all(fit[t] < fit[b] for t in range(9) if adj(b, t) and t != b)

    peaks = [b for b in range(9) if is_strict_local_max(b)]
    print("  development :  " + "  ".join(f"{i}" for i in range(9)))
    print("  fitness     :  " + "  ".join(f"{int(f)}" for f in fit))
    print("  style       :  " + "  ".join(f"{s}" for s in style))
    print()
    for b in peaks:
        print(f"  strict local maximum: development {b}"
              f"  (fitness {int(fit[b])}, {names[style[b]]})")
    assert peaks == [2, 4, 8]
    assert len({style[b] for b in peaks}) == 3
    globalmax = max(range(9), key=lambda i: fit[i])
    print(f"  global maximum      : development {globalmax}"
          f"  (fitness {int(fit[globalmax])})")
    print(f"  peaks that are NOT global: "
          f"{[b for b in peaks if fit[b] < fit[globalmax]]}")
    print("  => no path of small local improvements connects the algebraic peak")
    print("     to the strictly better combinatorial one.")


# ---------------------------------------------------------------------------
# 10.  No global maximum without normalisation
# ---------------------------------------------------------------------------


def demo_no_global_maximum() -> None:
    banner("10.  Raw theorems-per-line has no maximum -- and the witnesses say nothing")

    # A concrete language: a development is (count, len); stating n further
    # consequences of what is already proved costs floor(sqrt(n)) extra lines
    # and does not change the semantics.
    def extend(dev: Tuple[int, int], n: int) -> Tuple[int, int]:
        return (dev[0] + n, dev[1] + isqrt(n))

    def raw(dev: Tuple[int, int]) -> Fraction:
        return Fraction(dev[0], dev[1])

    base = (10, 100)
    print(f"  base development: {base[0]} statements in {base[1]} lines,"
          f"  raw fitness = {float(raw(base)):.4f}")
    print()
    print("            n     count      len   raw fitness   semantics changed?")
    print("  " + "-" * 66)
    for n in (0, 10 ** 2, 10 ** 4, 10 ** 6, 10 ** 8, 10 ** 10):
        d = extend(base, n)
        print(f"  {n:11d}   {d[0]:8d} {d[1]:8d}   {float(raw(d)):11.2f}   no")
    print("  => raw fitness diverges to infinity while the mathematics stands")
    print("     perfectly still: conservative inflation adds no semantic content.")

    # And the quantitative construction: exceed any prescribed target M.
    print()
    for M in (10, 1000, 10 ** 6):
        # Choose n > max(N, k) as in the proof, with c = 1/(2M):
        #   sqrt(n) <= n/(2M)  holds once n >= 4 M^2, and we need n > 2 M * len.
        n = max(4 * M * M, 2 * M * base[1]) + 1
        d = extend(base, n)
        assert raw(d) > M
        print(f"  target M = {M:>8}: inflate by n = {n:>14}"
              f"  -> raw fitness = {float(raw(d)):.2f} > {M}")
    print("  => no global champion exists on the unrestricted class; a champion")
    print("     is a meaningful notion only after resource normalisation.")

    print()
    print("  By contrast, on any FINITE normalised comparison class a champion")
    print("  always exists:")
    klass = [(12, 300), (9, 200), (25, 700), (4, 90)]
    best = max(klass, key=raw)
    for d in klass:
        mark = "  <-- champion" if d == best else ""
        print(f"    {d[0]:3d} statements / {d[1]:4d} lines"
              f"  = {float(raw(d)):.5f}{mark}")


# ---------------------------------------------------------------------------


def main() -> None:
    print(__doc__)
    demo_closure_minimality()
    demo_merge_accounting()
    demo_canonical_champion()
    demo_two_routes()
    demo_reuse_identity()
    demo_phase_transition()
    demo_candidate_counts()
    demo_adapter_valley()
    demo_metastability()
    demo_no_global_maximum()
    banner("All demonstrations completed; every assertion verified.")


if __name__ == "__main__":
    main()
