"""
Fitness Landscapes of Mathematical Theories -- numerical demonstrations.

A *theory* (a mathematical development) is modelled by

  * the transitive closure of the declarations it uses, and
  * the set of corpus statements it proves.

Each declaration i carries a source length l(i) and a set deps(i) of direct
dependencies.  The dependency-adjusted cost of a theory is the sum of l over
its closure (each declaration charged exactly once); its fitness is

        fitness(T) = |proved statements| / cost(T).

This script demonstrates, with exact rational arithmetic:

  1. transitive closure by saturation, and its minimality;
  2. the merge identity  cost(T u U) + cost(T n U) = cost(T) + cost(U);
  3. the ordinal reduction: on a fixed corpus size, fitness reverses cost;
  4. the exact k-fold reuse identity  cost(lib) + k*core = sum(spec) + core;
  5. the composition phase transition  gain  <=>  adapter < shared mass,
     in absolute and in dimensionless density form;
  6. exact candidate counts: 2^n for independent, n+1 for a chain, and exact
     multiplicativity across an independent split;
  7. the quantitative adapter valley with relative depth (a-b)/(1+b);
  8. a nine-point three-style landscape with three strict local maxima.

Self-contained: standard library only.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Callable, Dict, FrozenSet, Iterable, List, Set

# --------------------------------------------------------------------------
# 1.  Dependency closures
# --------------------------------------------------------------------------


def dep_step(deps: Dict[int, Set[int]], s: Set[int]) -> Set[int]:
    """One round of dependency expansion: S |-> S u U_{i in S} deps(i)."""
    out: Set[int] = set(s)
    for i in s:
        out |= deps.get(i, set())
    return out


def is_dep_closed(deps: Dict[int, Set[int]], s: Set[int]) -> bool:
    """True iff S contains the direct dependencies of each of its members."""
    return all(deps.get(i, set()) <= s for i in s)


def dep_closure(deps: Dict[int, Set[int]], base: Set[int]) -> Set[int]:
    """Least dependency-closed superset of `base` (saturation to a fixed point)."""
    cur: Set[int] = set(base)
    while True:
        nxt = dep_step(deps, cur)
        if nxt == cur:
            return cur
        cur = nxt


# --------------------------------------------------------------------------
# 2.  Theories, cost, fitness
# --------------------------------------------------------------------------


class Theory:
    """A development: a dependency closure plus the corpus statements proved."""

    def __init__(self, closure: Iterable[int], proves: Iterable[int]) -> None:
        self.closure: FrozenSet[int] = frozenset(closure)
        self.proves: FrozenSet[int] = frozenset(proves)

    def __repr__(self) -> str:
        return f"Theory(closure={sorted(self.closure)}, proves={sorted(self.proves)})"


def cost(length: Callable[[int], int], t: Theory) -> int:
    """Dependency-adjusted cost: every declaration charged exactly once."""
    return sum(length(i) for i in t.closure)


def fitness(length: Callable[[int], int], t: Theory) -> Fraction:
    """Proved corpus statements per unit of dependency-adjusted cost."""
    return Fraction(len(t.proves), cost(length, t))


def merge(t: Theory, u: Theory) -> Theory:
    """Pool dependencies (shared ones charged once) and pool proved corpora."""
    return Theory(t.closure | u.closure, t.proves | u.proves)


def shared_mass(length: Callable[[int], int], t: Theory, u: Theory) -> int:
    """Summed source length of the declarations in both closures."""
    return sum(length(i) for i in (t.closure & u.closure))


# --------------------------------------------------------------------------
# 3.  Composition
# --------------------------------------------------------------------------


def compose_cost(length: Callable[[int], int], t: Theory, u: Theory, adapter: int) -> int:
    return cost(length, merge(t, u)) + adapter


def duplicate_cost(length: Callable[[int], int], t: Theory, u: Theory) -> int:
    return cost(length, t) + cost(length, u)


def composed_fitness(
    length: Callable[[int], int], t: Theory, u: Theory, adapter: int
) -> Fraction:
    return Fraction(len(merge(t, u).proves), compose_cost(length, t, u, adapter))


def duplicated_fitness(length: Callable[[int], int], t: Theory, u: Theory) -> Fraction:
    return Fraction(len(merge(t, u).proves), duplicate_cost(length, t, u))


def dependency_density(length: Callable[[int], int], t: Theory, u: Theory) -> Fraction:
    return Fraction(shared_mass(length, t, u), duplicate_cost(length, t, u))


def adapter_density(
    length: Callable[[int], int], t: Theory, u: Theory, adapter: int
) -> Fraction:
    return Fraction(adapter, duplicate_cost(length, t, u))


# --------------------------------------------------------------------------
# 4.  Candidate counts (usable sub-libraries = dependency-closed subsets)
# --------------------------------------------------------------------------


def closed_subsets(deps: Dict[int, Set[int]], universe: Set[int]) -> List[FrozenSet[int]]:
    """All dependency-closed subsets of `universe` (brute force; |universe| small)."""
    elems = sorted(universe)
    out: List[FrozenSet[int]] = []
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            s = set(combo)
            if is_dep_closed(deps, s):
                out.append(frozenset(s))
    return out


def no_deps(n: int) -> Dict[int, Set[int]]:
    """n mutually independent declarations."""
    return {i: set() for i in range(n)}


def chain_deps(n: int) -> Dict[int, Set[int]]:
    """A maximally dependent library: declaration i depends on i-1."""
    return {i: (set() if i == 0 else {i - 1}) for i in range(n)}


# --------------------------------------------------------------------------
# 5.  Adapter valleys
# --------------------------------------------------------------------------


class Dev:
    """A development seen by the migration graph."""

    def __init__(self, length: Fraction, iface: int, content: Fraction) -> None:
        self.len: Fraction = length
        self.iface: int = iface
        self.content: Fraction = content


def find_boundary_crossing(walk: List[Dev]) -> int:
    """Index i of a step crossing the interface boundary, or -1 if none."""
    for i in range(len(walk) - 1):
        if walk[i].iface != walk[i + 1].iface:
            return i
    return -1


def guaranteed_overshoot(alpha: Fraction, beta: Fraction) -> Fraction:
    """The relative valley depth (alpha - beta) / (1 + beta)."""
    return (alpha - beta) / (1 + beta)


# --------------------------------------------------------------------------
# 6.  Metastability
# --------------------------------------------------------------------------


def strict_local_maxima(
    fit: List[Fraction], style: List[int]
) -> List[int]:
    """Indices that strictly beat every same-style neighbour (bounded refactorings
    never change style, so neighbours are exactly the same-style points)."""
    out: List[int] = []
    for b in range(len(fit)):
        if all(fit[t] < fit[b] for t in range(len(fit)) if t != b and style[t] == style[b]):
            out.append(b)
    return out


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def demo_closure() -> None:
    rule("1.  Transitive dependency closure and its minimality")
    deps = {0: set(), 1: {0}, 2: {1}, 3: {0}, 4: {2, 3}, 5: set()}
    base = {4}
    cl = dep_closure(deps, base)
    print(f"deps            = {({i: sorted(d) for i, d in deps.items()})}")
    print(f"base            = {sorted(base)}")
    print(f"closure(base)   = {sorted(cl)}")
    print(f"is closed       = {is_dep_closed(deps, cl)}")
    # minimality: the closure sits inside every closed superset of the base
    universe = set(deps)
    supersets = [s for s in closed_subsets(deps, universe) if base <= s]
    print(f"closed supersets of base: {len(supersets)}")
    print(f"closure <= all of them  : {all(cl <= s for s in supersets)}")


def demo_merge_identity() -> None:
    rule("2.  Exact merge accounting:  cost(T u U) + shared = cost(T) + cost(U)")
    length = lambda i: 10
    t = Theory({0, 1, 2, 3}, {0, 1})
    u = Theory({2, 3, 4, 5}, {2, 3})
    lhs = cost(length, merge(t, u)) + shared_mass(length, t, u)
    rhs = cost(length, t) + cost(length, u)
    print(f"cost(T)          = {cost(length, t)}")
    print(f"cost(U)          = {cost(length, u)}")
    print(f"cost(T u U)      = {cost(length, merge(t, u))}")
    print(f"shared mass      = {shared_mass(length, t, u)}")
    print(f"identity holds   = {lhs == rhs}   ({lhs} = {rhs})")


def demo_ordinal() -> None:
    rule("3.  On a fixed corpus size, fitness is the reverse order of cost")
    length = lambda i: i + 1
    corpus = {0, 1, 2}
    a = Theory({0, 1, 2, 3}, corpus)      # cost 1+2+3+4 = 10
    b = Theory({0, 1, 2, 3, 4, 5}, corpus)  # cost 21
    print(f"cost(A) = {cost(length, a)}, fitness(A) = {fitness(length, a)}")
    print(f"cost(B) = {cost(length, b)}, fitness(B) = {fitness(length, b)}")
    print("fit(A) <= fit(B)  <=>  cost(B) <= cost(A) :",
          (fitness(length, a) <= fitness(length, b))
          == (cost(length, b) <= cost(length, a)))


def demo_reuse() -> None:
    rule("4.  Exact k-fold reuse identity: pooling k specialists saves (k-1) cores")
    length = lambda i: 5
    core = {100, 101, 102}                      # core mass = 15
    privs = {0: {0, 1}, 1: {2, 3}, 2: {4}, 3: {5, 6, 7}}
    k = len(privs)
    corpus = {900, 901, 902}
    core_mass = sum(length(x) for x in core)

    library = Theory(core | set().union(*privs.values()), corpus)
    specialists = [Theory(core | p, corpus) for p in privs.values()]

    lib_cost = cost(length, library)
    suite_cost = sum(cost(length, s) for s in specialists)
    print(f"k                     = {k}, core mass = {core_mass}")
    print(f"cost(library)         = {lib_cost}")
    print(f"sum cost(specialists) = {suite_cost}")
    print(f"identity: {lib_cost} + {k}*{core_mass} = {suite_cost} + {core_mass}  ->",
          lib_cost + k * core_mass == suite_cost + core_mass)
    print(f"saving = (k-1)*core   = {(k - 1) * core_mass}"
          f"  (measured {suite_cost - lib_cost})")
    print(f"fitness(library)      = {fitness(length, library)}")
    print(f"fitness(suite)        = {Fraction(len(corpus), suite_cost)}")


def demo_phase_transition() -> None:
    rule("5.  Composition phase transition:  gain <=> adapter < shared mass")
    length = lambda i: 10
    t = Theory({0, 1, 2, 3}, {0, 1})
    u = Theory({2, 3, 4, 5}, {2, 3})
    sm = shared_mass(length, t, u)
    dup = duplicate_cost(length, t, u)
    print(f"shared mass = {sm}, duplicated cost = {dup},"
          f" dependency density rho = {dependency_density(length, t, u)}")
    print()
    print(f"{'adapter':>8} {'alpha_A':>10} {'dup fitness':>14} {'comp fitness':>14}  verdict")
    for adapter in (0, 5, 10, 15, 20, 25, 30, 40):
        df = duplicated_fitness(length, t, u)
        cf = composed_fitness(length, t, u, adapter)
        verdict = "GAIN" if df < cf else ("neutral" if df == cf else "loss")
        # threshold agreement, both in absolute and density form
        assert (df < cf) == (adapter < sm)
        assert (df < cf) == (
            adapter_density(length, t, u, adapter) < dependency_density(length, t, u)
        )
        print(f"{adapter:>8} {str(adapter_density(length, t, u, adapter)):>10}"
              f" {str(df):>14} {str(cf):>14}  {verdict}")
    print("\nThreshold verified in both absolute and dimensionless density form.")


def demo_multiplicative() -> None:
    rule("6a. Multiplicative growth eventually beats additive cost")
    length = lambda i: 1
    t = Theory(range(0, 10), range(0, 3))        # cost 10, corpus 3
    print(f"{'|corpus(U)|':>12} {'cost(U)':>9} {'adapter':>8} "
          f"{'fit(T)':>10} {'product fit':>14}  verdict")
    for m in (2, 3, 5, 8, 12):
        u = Theory(range(8, 18), range(100, 100 + m))
        adapter = 4
        ft = fitness(length, t)
        pf = Fraction(len(t.proves) * len(u.proves),
                      compose_cost(length, t, u, adapter))
        suff = (cost(length, t) + cost(length, u) + adapter
                < cost(length, t) * len(u.proves))
        print(f"{m:>12} {cost(length, u):>9} {adapter:>8} {str(ft):>10} {str(pf):>14}"
              f"  {'GAIN' if ft < pf else 'loss'}"
              f"{'  (sufficient condition met)' if suff else ''}")
        if suff:
            assert ft < pf


def demo_candidate_counts() -> None:
    rule("6b. Exact candidate counts: 2^n independent vs n+1 chain")
    print(f"{'n':>3} {'#closed (independent)':>23} {'2^n':>8}"
          f" {'#closed (chain)':>17} {'n+1':>6}")
    for n in range(0, 9):
        ind = len(closed_subsets(no_deps(n), set(range(n))))
        ch = len(closed_subsets(chain_deps(n), set(range(n))))
        assert ind == 2 ** n and ch == n + 1
        assert n < 2 or ch < ind
        print(f"{n:>3} {ind:>23} {2 ** n:>8} {ch:>17} {n + 1:>6}")

    print("\nExact multiplicativity across an independent split:")
    # A = {0,1,2} a chain; B = {3,4} independent; no dependency crosses the split
    deps: Dict[int, Set[int]] = {0: set(), 1: {0}, 2: {1}, 3: set(), 4: set()}
    a, b = {0, 1, 2}, {3, 4}
    ca = len(closed_subsets(deps, a))
    cb = len(closed_subsets(deps, b))
    cab = len(closed_subsets(deps, a | b))
    print(f"  |C(A)| = {ca}, |C(B)| = {cb}, |C(A u B)| = {cab},"
          f"  product = {ca * cb}  -> {cab == ca * cb}")


def demo_valley() -> None:
    rule("7.  Quantitative adapter valley")
    content = Fraction(100)
    alpha, beta = Fraction(1, 2), Fraction(1, 10)
    walk = [
        Dev(Fraction(110), 0, content),   # efficient endpoint, interface 0
        Dev(Fraction(150), 0, content),   # adapter state: implements both
        Dev(Fraction(110), 1, content),   # efficient endpoint, interface 1
    ]
    i = find_boundary_crossing(walk)
    m = min(walk[0].len, walk[-1].len)
    depth = guaranteed_overshoot(alpha, beta)
    print(f"content C          = {content}")
    print(f"alpha = {alpha}, beta = {beta}")
    print(f"crossing step      = {i} -> {i + 1}")
    print(f"min endpoint m     = {m}")
    print(f"guaranteed depth   = (a-b)/(1+b) = {depth}  ({float(depth):.3%} of m)")
    print(f"required overshoot = {depth * m}")
    worst = max(w.len for w in walk) - m
    print(f"actual overshoot   = {worst}   -> bound satisfied: {worst >= depth * m}")
    print("\nGuaranteed relative depth for a range of (alpha, beta):")
    for a_, b_ in [(Fraction(1, 4), Fraction(1, 10)),
                   (Fraction(1, 2), Fraction(1, 10)),
                   (Fraction(1), Fraction(1, 5)),
                   (Fraction(3, 2), Fraction(0))]:
        d = guaranteed_overshoot(a_, b_)
        print(f"  alpha={str(a_):>4}  beta={str(b_):>4}  ->  depth = {str(d):>8}"
              f"  ({float(d):.2%})")


def demo_metastability() -> None:
    rule("8.  Three-style metastability: three distinct strict local maxima")
    fit = [Fraction(x) for x in (1, 2, 5, 3, 7, 4, 6, 2, 9)]
    style = [i // 3 for i in range(9)]
    names = {0: "algebraic", 1: "analytic", 2: "combinatorial"}
    maxima = strict_local_maxima(fit, style)
    print(f"{'dev':>4} {'style':>15} {'fitness':>9}  local max?")
    for i in range(9):
        print(f"{i:>4} {names[style[i]]:>15} {str(fit[i]):>9}"
              f"  {'YES' if i in maxima else ''}")
    print(f"\nstrict local maxima : {maxima}")
    print(f"their styles        : {[names[style[i]] for i in maxima]}")
    best = max(maxima, key=lambda i: fit[i])
    print(f"global maximum      : development {best} (fitness {fit[best]})")
    print(f"non-global peaks    : {[i for i in maxima if i != best]}"
          "  <- genuine metastability")


def demo_unbounded() -> None:
    rule("9.  No universal maximum without normalisation (marginal cost sqrt n)")
    import math

    base_count, base_len = 1, 1
    print("Conservative inflation: state n further consequences of what is already")
    print("proved; count += n, length += floor(sqrt n), semantics unchanged.")
    print(f"\n{'n':>12} {'count':>14} {'length':>10} {'raw fitness':>14}")
    for n in (0, 10, 10 ** 2, 10 ** 4, 10 ** 6, 10 ** 8, 10 ** 10):
        c = base_count + n
        L = base_len + math.isqrt(n)
        print(f"{n:>12} {c:>14} {L:>10} {float(Fraction(c, L)):>14.3f}")
    print("\nRaw theorem-per-line fitness diverges, yet every witness has exactly")
    print("the same semantics as the base development: no mathematical progress.")


def main() -> None:
    print(__doc__)
    demo_closure()
    demo_merge_identity()
    demo_ordinal()
    demo_reuse()
    demo_phase_transition()
    demo_multiplicative()
    demo_candidate_counts()
    demo_valley()
    demo_metastability()
    demo_unbounded()
    print("\nAll demonstrations completed; every asserted identity and threshold held.")


if __name__ == "__main__":
    main()
