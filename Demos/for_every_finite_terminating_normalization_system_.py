"""
Thermodynamics of Proof Normalization -- numerical demonstrations.

This self-contained script demonstrates, on explicit finite examples, the four
results of the accompanying paper:

  1. The Fiber-Entropy Law.  For a normalization map f on a finite set of proof
     terms and a non-negative law p,

         H_p(x | f x)  <=  E_p[ log2 |f^{-1}(f x)| ],

     with equality if and only if p is constant on every fiber of f.

  2. The bureaucratic calculus Bur_n.  Derivations are pairs (u, c) in
     {0,1}^n x {0,1}^n; rewrite rule i sets u_i from 1 to 0.  It is strongly
     normalizing, normal forms are the terms with u = 0, normalization takes at
     most n steps, every normalization fiber has exactly 2^n elements, and the
     uniform law destroys exactly n bits (hence n * kB * T * ln 2 of heat).

  3. Compositional Landauer accounting.  For two obligations verified by f and
     g under a joint law p,

         separate - joint = I(inputs) - I(outputs),

     with additivity for independent obligations and a non-negative saving.

  4. The pipeline dichotomy.  Conditional entropy is exactly additive along a
     composite normalization, while the fiber-counting estimate is only
     subadditive under uniform laws and fails outright under skewed laws.

Only the Python standard library is used.
"""

from __future__ import annotations

from itertools import product
from math import isclose, log, log2
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

# Boltzmann constant (J/K) and room temperature (K).
K_B: float = 1.380649e-23
ROOM_T: float = 300.0

Term = Hashable
Law = Dict[Term, float]


# ---------------------------------------------------------------------------
# Core functionals
# ---------------------------------------------------------------------------

def fibers(domain: Sequence[Term], f: Callable[[Term], Hashable]) -> Dict[Hashable, List[Term]]:
    """Group the domain into the fibers f^{-1}(b).  One pass, O(|domain|)."""
    out: Dict[Hashable, List[Term]] = {}
    for x in domain:
        out.setdefault(f(x), []).append(x)
    return out


def pushforward(domain: Sequence[Term], f: Callable[[Term], Hashable], p: Law) -> Law:
    """(f_* p)(b) = sum of p over the fiber of f above b."""
    out: Law = {}
    for x in domain:
        b = f(x)
        out[b] = out.get(b, 0.0) + p[x]
    return out


def entropy(law: Iterable[float]) -> float:
    """Unnormalized Shannon entropy  -sum q log2 q,  with 0 log2 0 = 0."""
    total = 0.0
    for q in law:
        if q > 0.0:
            total -= q * log2(q)
    return total


def cond_entropy(domain: Sequence[Term], f: Callable[[Term], Hashable], p: Law) -> float:
    """Entropy destroyed by f under p:  -sum_x p(x) log2( p(x) / (f_*p)(f x) )."""
    push = pushforward(domain, f, p)
    total = 0.0
    for x in domain:
        px = p[x]
        if px > 0.0:
            total -= px * log2(px / push[f(x)])
    return total


def expected_log_fiber(domain: Sequence[Term], f: Callable[[Term], Hashable], p: Law) -> float:
    """Fiber-counting estimate:  sum_x p(x) log2 |f^{-1}(f x)|."""
    sizes = {b: len(members) for b, members in fibers(domain, f).items()}
    return sum(p[x] * log2(sizes[f(x)]) for x in domain)


def fiberwise_uniform(domain: Sequence[Term], f: Callable[[Term], Hashable], p: Law) -> bool:
    """Test the equality criterion of the Fiber-Entropy Law."""
    for members in fibers(domain, f).values():
        first = p[members[0]]
        if any(not isclose(p[x], first, rel_tol=1e-12, abs_tol=1e-15) for x in members):
            return False
    return True


def landauer_joules(bits: float, k_b: float = K_B, temperature: float = ROOM_T) -> float:
    """Landauer heat for erasing `bits` bits at temperature `temperature`."""
    return bits * k_b * temperature * log(2.0)


# ---------------------------------------------------------------------------
# 1. The Fiber-Entropy Law
# ---------------------------------------------------------------------------

def demo_fiber_entropy_law() -> None:
    print("=" * 74)
    print("1. THE FIBER-ENTROPY LAW")
    print("=" * 74)

    domain: List[Term] = [0, 1, 2]

    def collapse(x: Term) -> int:
        # x0, x1 |-> y0 ;  x2 |-> y1
        return 0 if x in (0, 1) else 1

    biased: Law = {0: 0.5, 1: 0.25, 2: 0.25}
    uniform: Law = {0: 1 / 3, 1: 1 / 3, 2: 1 / 3}

    for name, p in (("biased (1/2, 1/4, 1/4)", biased), ("uniform (1/3, 1/3, 1/3)", uniform)):
        est = expected_log_fiber(domain, collapse, p)
        hce = cond_entropy(domain, collapse, p)
        print(f"\nlaw = {name}")
        print(f"  fiberwise uniform?            {fiberwise_uniform(domain, collapse, p)}")
        print(f"  fiber-counting estimate  L  = {est:.6f} bits")
        print(f"  entropy destroyed        H  = {hce:.6f} bits")
        print(f"  defect  L - H               = {est - hce:.6f} bits")
        assert hce <= est + 1e-12, "the law's inequality must hold"
        assert isclose(hce, est, abs_tol=1e-12) == fiberwise_uniform(domain, collapse, p)

    predicted_gap = 1.25 - 0.75 * log2(3.0)
    actual_gap = expected_log_fiber(domain, collapse, biased) - cond_entropy(domain, collapse, biased)
    print(f"\nclosed form of the biased gap:  5/4 - (3/4) log2 3 = {predicted_gap:.6f}")
    print(f"measured gap                                       = {actual_gap:.6f}")
    assert isclose(predicted_gap, actual_gap, abs_tol=1e-12)
    print("closed form of H for the biased law: (3/4) log2 3 - 1/2 ="
          f" {0.75 * log2(3.0) - 0.5:.6f}")


# ---------------------------------------------------------------------------
# 2. The bureaucratic calculus
# ---------------------------------------------------------------------------

Deriv = Tuple[Tuple[int, ...], Tuple[int, ...]]  # (bookkeeping u, conclusion c)


def bureau_derivations(n: int) -> List[Deriv]:
    """All 4^n derivations (u, c) of the calculus Bur_n."""
    bits = list(product((0, 1), repeat=n))
    return [(u, c) for u in bits for c in bits]


def bureau_steps(d: Deriv) -> List[Deriv]:
    """One-step reducts of d: rule i applies exactly when u_i = 1."""
    u, c = d
    out: List[Deriv] = []
    for i, ui in enumerate(u):
        if ui == 1:
            v = list(u)
            v[i] = 0
            out.append((tuple(v), c))
    return out


def bureau_weight(d: Deriv) -> int:
    """Number of blocks still in bureaucratic order; a strictly decreasing measure."""
    return sum(d[0])


def bureau_normal_form(d: Deriv) -> Deriv:
    """Strip all bureaucracy, keep the conclusion."""
    return (tuple(0 for _ in d[0]), d[1])


def bureau_normalize(d: Deriv, strategy: str = "leftmost") -> Tuple[Deriv, int]:
    """Reduce d to normal form, returning the result and the number of steps."""
    steps = 0
    while True:
        reducts = bureau_steps(d)
        if not reducts:
            return d, steps
        d = reducts[0] if strategy == "leftmost" else reducts[-1]
        steps += 1


def demo_bureaucratic_calculus(n: int = 3) -> None:
    print()
    print("=" * 74)
    print(f"2. THE BUREAUCRATIC CALCULUS  Bur_{n}")
    print("=" * 74)

    derivs = bureau_derivations(n)
    normals = [d for d in derivs if bureau_weight(d) == 0]
    print(f"\nconclusions            : {2 ** n}")
    print(f"derivations            : {len(derivs)}  (= 4^{n})")
    print(f"normal derivations     : {len(normals)}  (= 2^{n})")

    # Strong normalization: every rewrite strictly decreases the weight.
    assert all(bureau_weight(e) < bureau_weight(d) for d in derivs for e in bureau_steps(d))
    print("strong normalization   : every rewrite strictly decreases the weight  OK")

    # Normal forms are exactly the irreducible terms.
    assert all((bureau_weight(d) == 0) == (len(bureau_steps(d)) == 0) for d in derivs)
    print("normal form criterion  : irreducible  <=>  u = 0                      OK")

    # Uniqueness of normal forms, under two different strategies.
    for strategy in ("leftmost", "rightmost"):
        assert all(bureau_normalize(d, strategy)[0] == bureau_normal_form(d) for d in derivs)
    print("unique normal forms    : strategy-independent                         OK")

    # Bounded length of normalization.
    max_steps = max(bureau_normalize(d)[1] for d in derivs)
    assert max_steps <= n
    print(f"normalization length   : at most {max_steps} steps (bound n = {n})               OK")

    # Exponential fibers.
    fib = fibers(derivs, bureau_normal_form)
    sizes = {len(v) for v in fib.values()}
    assert sizes == {2 ** n}
    print(f"fiber sizes            : all equal to {2 ** n}  (= 2^{n})                        OK")

    # Exact thermodynamic cost under the uniform law.
    uniform: Law = {d: 1.0 / len(derivs) for d in derivs}
    est = expected_log_fiber(derivs, bureau_normal_form, uniform)
    hce = cond_entropy(derivs, bureau_normal_form, uniform)
    erased = log2(len(derivs)) - log2(len(fib))
    print(f"\nfiber-counting estimate : {est:.6f} bits   (predicted {n})")
    print(f"entropy destroyed       : {hce:.6f} bits   (predicted {n})")
    print(f"image-counting erasure  : {erased:.6f} bits   (predicted {n})")
    assert isclose(est, n, abs_tol=1e-12) and isclose(hce, n, abs_tol=1e-12)
    assert isclose(erased, n, abs_tol=1e-12)
    print(f"Landauer heat at {ROOM_T:.0f} K   : {landauer_joules(hce):.4e} J per normalization")

    print("\nmultiplicity is not a syntactic size parameter:")
    print("   n | conclusion bits | normal-proof bits | max steps | fiber size")
    for m in (3, 10, 20, 30, 40):
        print(f"  {m:2d} | {m:15d} | {m:17d} | {m:9d} | {2 ** m:,}")


# ---------------------------------------------------------------------------
# 3. Compositional Landauer accounting
# ---------------------------------------------------------------------------

def marginals(joint: Dict[Tuple[Term, Term], float]) -> Tuple[Law, Law]:
    m1: Law = {}
    m2: Law = {}
    for (x, y), w in joint.items():
        m1[x] = m1.get(x, 0.0) + w
        m2[y] = m2.get(y, 0.0) + w
    return m1, m2


def mutual_information(joint: Dict[Tuple[Term, Term], float]) -> float:
    """I(p) = H(p_1) + H(p_2) - H(p)."""
    m1, m2 = marginals(joint)
    return entropy(m1.values()) + entropy(m2.values()) - entropy(joint.values())


def compositional_report(
    joint: Dict[Tuple[Term, Term], float],
    f: Callable[[Term], Hashable],
    g: Callable[[Term], Hashable],
    label: str,
) -> None:
    pairs = list(joint.keys())
    m1, m2 = marginals(joint)

    def prod_map(z: Tuple[Term, Term]) -> Tuple[Hashable, Hashable]:
        return (f(z[0]), g(z[1]))

    separate = cond_entropy(list(m1.keys()), f, m1) + cond_entropy(list(m2.keys()), g, m2)
    joint_cost = cond_entropy(pairs, prod_map, joint)
    pushed = pushforward(pairs, prod_map, joint)
    i_in = mutual_information(joint)
    i_out = mutual_information(pushed)

    print(f"\n{label}")
    print(f"  separate cost                 : {separate:.6f} bits")
    print(f"  joint cost                    : {joint_cost:.6f} bits")
    print(f"  saving  (separate - joint)    : {separate - joint_cost:.6f} bits")
    print(f"  I(inputs)                     : {i_in:.6f} bits")
    print(f"  I(outputs)                    : {i_out:.6f} bits")
    print(f"  I(inputs) - I(outputs)        : {i_in - i_out:.6f} bits")
    assert isclose(separate - joint_cost, i_in - i_out, abs_tol=1e-12), "accounting identity"
    assert separate - joint_cost >= -1e-12, "the saving is never negative"


def demo_compositional_accounting() -> None:
    print()
    print("=" * 74)
    print("3. COMPOSITIONAL LANDAUER ACCOUNTING")
    print("=" * 74)

    def collapse_to_point(_: Term) -> int:
        return 0

    def identity(x: Term) -> Term:
        return x

    # (a) A shared lemma: the joint law lives on the diagonal.
    shared = {(0, 0): 0.5, (0, 1): 0.0, (1, 0): 0.0, (1, 1): 0.5}
    compositional_report(shared, collapse_to_point, collapse_to_point,
                         "(a) shared lemma, collapsing verifiers  -> 2 bits vs 1 bit")

    # (b) Independent obligations: the saving must vanish.
    independent = {(x, y): 0.25 for x in (0, 1) for y in (0, 1)}
    compositional_report(independent, collapse_to_point, collapse_to_point,
                         "(b) independent obligations             -> additive, saving 0")

    # (c) Correlated inputs, correlation-preserving verifiers: the naive
    #     conjecture "saving = I(inputs)" fails; the drop is the invariant.
    compositional_report(shared, identity, identity,
                         "(c) shared lemma, identity verifiers    -> naive guess fails")
    i_in = mutual_information(shared)
    print(f"\n  naive prediction  saving = I(inputs) = {i_in:.6f} bits")
    print("  actual saving in case (c)           = 0.000000 bits")
    print("  => the invariant is the mutual-information DROP, not I(inputs).")


# ---------------------------------------------------------------------------
# 4. The pipeline dichotomy
# ---------------------------------------------------------------------------

def demo_pipeline_dichotomy() -> None:
    print()
    print("=" * 74)
    print("4. PIPELINES: ENTROPY COMPOSES, MULTIPLICITY DOES NOT")
    print("=" * 74)

    domain: List[Term] = [0, 1, 2]

    def f(x: Term) -> int:
        return 0 if x == 0 else 1          # fibers of sizes 1 and 2

    def g(_: Term) -> int:
        return 0                            # total collapse

    def gf(x: Term) -> int:
        return g(f(x))

    for name, p in (
        ("skewed law (4/5, 1/10, 1/10)", {0: 0.8, 1: 0.1, 2: 0.1}),
        ("uniform law (1/3, 1/3, 1/3)", {0: 1 / 3, 1: 1 / 3, 2: 1 / 3}),
    ):
        pf = pushforward(domain, f, p)
        stage1_H = cond_entropy(domain, f, p)
        stage2_H = cond_entropy(list(pf.keys()), g, pf)
        total_H = cond_entropy(domain, gf, p)

        stage1_L = expected_log_fiber(domain, f, p)
        stage2_L = expected_log_fiber(list(pf.keys()), g, pf)
        total_L = expected_log_fiber(domain, gf, p)

        print(f"\nlaw = {name}")
        print(f"  entropy   : H(stage1) + H(stage2) = {stage1_H:.6f} + {stage2_H:.6f}"
              f" = {stage1_H + stage2_H:.6f}")
        print(f"              H(composite)          = {total_H:.6f}   -> additive:"
              f" {isclose(stage1_H + stage2_H, total_H, abs_tol=1e-12)}")
        print(f"  counting  : L(stage1) + L(stage2) = {stage1_L:.6f} + {stage2_L:.6f}"
              f" = {stage1_L + stage2_L:.6f}")
        print(f"              L(composite)          = {total_L:.6f}")
        verdict = "SUBADDITIVE" if total_L <= stage1_L + stage2_L + 1e-12 else "NOT SUBADDITIVE"
        print(f"              verdict               : {verdict}")
        assert isclose(stage1_H + stage2_H, total_H, abs_tol=1e-12), "pipeline chain rule"

    print("\nclosed forms for the skewed law: two-stage total 1/5 + 1 = 1.2,")
    print(f"                                 one-stage estimate log2 3 = {log2(3.0):.6f}")
    print(f"                                 shortfall = {log2(3.0) - 1.2:.6f} bits")


# ---------------------------------------------------------------------------

def main() -> None:
    demo_fiber_entropy_law()
    demo_bureaucratic_calculus(n=3)
    demo_compositional_accounting()
    demo_pipeline_dichotomy()
    print()
    print("=" * 74)
    print("All predicted identities and inequalities verified numerically.")
    print("=" * 74)


if __name__ == "__main__":
    main()
