"""
The Corpus Algebra of the Attention Knee — numerical demonstrations.

Self-contained, dependency-free (standard library only).  Every function is
inlined and type-hinted.  Running this file exercises, numerically, each of the
main results:

  1.  The knee as a Galois left adjoint, and the razor bracket.
  2.  Context monotonicity of the knee.
  3.  The pooling sandwich  min <= k*(A+B) <= max, and its sharpness:
      the SAME pair of corpora attains min at one gate and max at another.
  4.  Exact corpus robustness on the diagonal, plus scale invariance and
      invariance under arbitrary positive mixing weights.
  5.  The four-decimal theorem: eps-agreement + gate margin  =>  equal knees;
      and the scale-free counterexample showing the margin is necessary.
  6.  Gate/budget Galois duality: the retention curve is the upper envelope of
      the gate sweep.
  7.  The domain-jump law in the missing-mass coordinate: a rho-tilt inflates
      the missing mass by rho^2; the explicit geometric-tail budget.
  8.  The knee fan: cells cut out by two measurements, disjoint, covering, and
      every label realised by a one-hot corpus.

Notation.  A *corpus* is a list of nonnegative weights w[0], w[1], ... already
sorted by importance.  Head mass  M_w(k) = sum_{i<k} w[i].  The gate condition
is the LINEAR inequality  tau * M_w(n) <= M_w(k), and the knee is the least k
that satisfies it.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Number = float

# ----------------------------------------------------------------------------
# 1.  Core objects: head mass, the linear gate, the knee
# ----------------------------------------------------------------------------


def head_mass(w: Sequence[Number], k: int) -> Number:
    """Total mass of the top-k keys:  M_w(k) = sum_{i<k} w[i]."""
    return sum(w[i] for i in range(min(k, len(w))))


def is_corpus(w: Sequence[Number]) -> bool:
    """A profile is a corpus iff all its weights are nonnegative."""
    return all(x >= 0 for x in w)


def clears(w: Sequence[Number], n: int, k: int, tau: Number) -> bool:
    """The gate in LINEAR form:  tau * M_w(n) <= M_w(k).

    Equivalent to  tau <= M_w(k)/M_w(n)  whenever the context carries mass, but
    linear in w — which is the whole point: it is a half space.
    """
    return tau * head_mass(w, n) <= head_mass(w, k)


def knee(w: Sequence[Number], n: int, tau: Number) -> int:
    """k*(w; n, tau) = least budget k <= n clearing the gate.

    Monotonicity of the gate in k makes this a step predicate, so we could
    bisect; we scan here for transparency (see `knee_bisect` for O(log n)).
    """
    for k in range(n + 1):
        if clears(w, n, k, tau):
            return k
    return n  # unreachable for a corpus and tau <= 1


def knee_bisect(prefix: Sequence[Number], n: int, tau: Number) -> int:
    """O(log n) knee from precomputed prefix sums `prefix[k] = M_w(k)`."""
    target = tau * prefix[n]
    lo, hi = 0, n
    while lo < hi:
        mid = (lo + hi) // 2
        if prefix[mid] >= target:
            hi = mid
        else:
            lo = mid + 1
    return lo


def prefix_sums(w: Sequence[Number], n: int) -> List[Number]:
    """prefix[k] = M_w(k) for 0 <= k <= n."""
    out: List[Number] = [0.0]
    total: Number = 0.0
    for i in range(n):
        total += w[i] if i < len(w) else 0.0
        out.append(total)
    return out


def retained(w: Sequence[Number], n: int, k: int) -> Number:
    """Retained mass fraction R_w(n,k) = M_w(k) / M_w(n)."""
    denom = head_mass(w, n)
    return 0.0 if denom == 0 else head_mass(w, k) / denom


def razor_bracket(w: Sequence[Number], n: int, tau: Number) -> Tuple[int, int]:
    """(last failing budget, first passing budget) — a cell certificate."""
    k = knee(w, n, tau)
    return (k - 1, k)


# ----------------------------------------------------------------------------
# 2.  Model corpora
# ----------------------------------------------------------------------------


def geometric_corpus(n: int, r: float) -> List[float]:
    """Heavy-headed profile w[i] = (1-r) r^i: an r-geometric retention tail."""
    return [(1.0 - r) * r ** i for i in range(n)]


def zipf_corpus(n: int) -> List[float]:
    """Heavy-tailed profile w[i] = 1/(i+1): a much harder case than geometric."""
    return [1.0 / (i + 1) for i in range(n)]


def uniform_corpus(n: int) -> List[float]:
    """The flat profile: the worst case for any sparse-attention budget."""
    return [1.0] * n


def one_hot(j: int, n: int) -> List[float]:
    """All mass on key j: the corpus realising knee label j+1."""
    return [1.0 if i == j else 0.0 for i in range(n)]


def tilt(w: Sequence[float], factors: Sequence[float]) -> List[float]:
    """Pointwise multiplicative distortion of a corpus."""
    return [w[i] * factors[i] for i in range(len(w))]


def pool(a: Sequence[float], b: Sequence[float]) -> List[float]:
    """Pooling two corpora = pointwise addition of profiles."""
    m = max(len(a), len(b))
    return [(a[i] if i < len(a) else 0.0) + (b[i] if i < len(b) else 0.0) for i in range(m)]


def scale(c: float, w: Sequence[float]) -> List[float]:
    return [c * x for x in w]


# ----------------------------------------------------------------------------
# 3.  Certificates
# ----------------------------------------------------------------------------


def replication_certificate(
    a: Sequence[float], b: Sequence[float], n: int, tau: float
) -> Tuple[float, float, bool]:
    """Four-decimal theorem, checked directly.

    Returns (eps, margin, certified) where
        eps    = max_{k<=n} |R_A(k) - R_B(k)|      (curve agreement)
        margin = min_{k<=n} |R_A(k) - tau|         (distance from the gate)
    If margin > eps, the knees are PROVABLY equal: no perturbation of size eps
    can carry the reference curve across the gate at any grid point.
    """
    eps = max(abs(retained(a, n, k) - retained(b, n, k)) for k in range(n + 1))
    margin = min(abs(retained(a, n, k) - tau) for k in range(n + 1))
    return eps, margin, margin > eps


def geometric_tail_budget(r: float, rho: float, tau: float) -> int:
    """Least K with r^K <= 1 - rho^2 * tau  (Corollary: log-cost domain jump)."""
    import math

    slack = 1.0 - rho * rho * tau
    if slack <= 0:
        raise ValueError("gate inflated past 1: use the missing-mass coordinate")
    return math.ceil(math.log(slack) / math.log(r))


def achieved_gate_after_tilt(tau: float, rho: float) -> float:
    """Sharp domain-jump law in the complementary coordinate.

    Reference clears gate 1-delta  =>  every rho-tilt clears 1 - rho^2 delta.
    """
    delta = 1.0 - tau
    return 1.0 - rho * rho * delta


# ----------------------------------------------------------------------------
# 4.  Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_adjunction_and_bracket() -> None:
    banner("1. The knee as a left adjoint, and the razor bracket")
    n, tau, r = 512, 0.98, 0.885
    w = geometric_corpus(n, r)
    k = knee(w, n, tau)
    lo, hi = razor_bracket(w, n, tau)
    print(f"geometric corpus r={r}, context n={n}, gate tau={tau}")
    print(f"  knee k*            = {k}")
    print(f"  razor bracket      = fail at {lo}, pass at {hi}")
    print("  adjunction  k* <= k  <=>  gate clears at k :")
    for probe in (k - 2, k - 1, k, k + 1):
        lhs = k <= probe
        rhs = clears(w, n, probe, tau)
        print(f"    k={probe:3d}   k*<=k : {str(lhs):5s}   clears : {str(rhs):5s}"
              f"   agree: {lhs == rhs}")
    ps = prefix_sums(w, n)
    print(f"  bisection agrees   : {knee_bisect(ps, n, tau) == k}")


def demo_context_monotone() -> None:
    banner("2. Knees are monotone in the context length")
    tau = 0.98
    print(f"gate tau={tau}; two profile families, both showing the forced ladder")
    for name, make in (("geometric r=0.885", lambda n: geometric_corpus(n, 0.885)),
                       ("Zipf w[i]=1/(i+1)", zipf_corpus)):
        prev = -1
        row = []
        ok = True
        for n in (128, 256, 512, 1024, 2048):
            k = knee(make(n), n, tau)
            ok = ok and k >= prev
            row.append(f"n={n}: k*={k}")
            prev = k
        print(f"  {name:20s} {'   '.join(row)}   monotone: {ok}")
    print("  (no corpus can invert this ladder — Theorem: knees are monotone")
    print("   in the context length, so a measured inversion is a bug.)")


def demo_pooling_sandwich() -> None:
    banner("3. The pooling sandwich, and its sharpness")
    e1, e2 = one_hot(0, 2), one_hot(1, 2)
    print("two one-hot corpora on a context of length 2:")
    print(f"  e1 = {e1},  e2 = {e2},  pooled = {pool(e1, e2)}")
    for tau in (0.5, 0.75):
        ka, kb = knee(e1, 2, tau), knee(e2, 2, tau)
        kp = knee(pool(e1, e2), 2, tau)
        where = "MIN" if kp == min(ka, kb) else ("MAX" if kp == max(ka, kb) else "?")
        print(f"  tau={tau}:  k*(e1)={ka}  k*(e2)={kb}  k*(e1+e2)={kp}"
              f"   -> attains {where}")
    print("  ingredient knees are identical at both gates, pooled knee is not:")
    print("  => the knee is NOT additive, and the pooled knee is not a function")
    print("     of the ingredient knees alone.  Both bounds are sharp.")

    print("\n  random check of the sandwich on heavy-headed corpora:")
    import random

    random.seed(20260902)
    n, tau = 64, 0.9
    bad = 0
    for _ in range(2000):
        a = sorted((random.random() ** random.uniform(1, 6) for _ in range(n)), reverse=True)
        b = sorted((random.random() ** random.uniform(1, 6) for _ in range(n)), reverse=True)
        ka, kb, kp = knee(a, n, tau), knee(b, n, tau), knee(pool(a, b), n, tau)
        if not (min(ka, kb) <= kp <= max(ka, kb)):
            bad += 1
    print(f"    2000 random pairs, violations of min <= k*(A+B) <= max : {bad}")


def demo_exact_robustness() -> None:
    banner("4. Exact corpus robustness, scale and mixing invariance")
    n, tau = 256, 0.95
    a = geometric_corpus(n, 0.86)
    ka = knee(a, n, tau)
    # find a structurally different corpus with the SAME knee
    b: List[float] = []
    for j in range(1, 200):
        cand = [x ** (1.0 + 0.005 * j) for x in a]
        if knee(cand, n, tau) == ka:
            b = cand
            break
    kb = knee(b, n, tau)
    print(f"corpus A (geometric, r=0.86):        k* = {ka}")
    print(f"corpus B (a power-reshaped profile): k* = {kb}")
    print(f"  equal knees -> pooled knee k*(A+B) = {knee(pool(a, b), n, tau)}"
          f"  (must be {ka})")
    for wa, wb in ((1.0, 1.0), (0.01, 100.0), (7.5, 0.3)):
        mix = pool(scale(wa, a), scale(wb, b))
        print(f"  mixture {wa:>6}*A + {wb:>6}*B :  k* = {knee(mix, n, tau)}")
    print("  scale invariance:")
    for c in (1e-6, 1.0, 1e6):
        print(f"    k*({c:g} * A) = {knee(scale(c, a), n, tau)}   (must be {ka})")


def demo_four_decimal_theorem() -> None:
    banner("5. The four-decimal theorem, and necessity of the margin")
    n, tau = 512, 0.98
    a = geometric_corpus(n, 0.885)
    # corpus B: an independent shard, agreeing with A to ~1e-4 in retention
    import random

    random.seed(57)
    b = [x * (1.0 + 1e-5 * random.uniform(-1, 1)) for x in a]
    eps, margin, certified = replication_certificate(a, b, n, tau)
    print(f"context {n}, gate {tau}")
    print(f"  curve agreement  eps    = {eps:.3e}")
    print(f"  gate margin      margin = {margin:.3e}")
    print(f"  margin > eps ?          = {certified}")
    print(f"  k*(A) = {knee(a, n, tau)},  k*(B) = {knee(b, n, tau)}"
          f"   -> equal: {knee(a, n, tau) == knee(b, n, tau)}")
    print("  => four-decimal agreement FORCES the integer knee to replicate.")

    print("\n  the margin hypothesis is necessary, at every scale:")
    print("  uniform corpus on n=2 at gate 1/2 sits EXACTLY on the gate.")
    u = [Fraction(1), Fraction(1)]

    def frac_knee(w: Sequence[Fraction], n: int, tau: Fraction) -> int:
        for k in range(n + 1):
            if tau * sum(w[:n]) <= sum(w[:k]):
                return k
        return n

    half = Fraction(1, 2)
    print(f"    k*(uniform) = {frac_knee(u, 2, half)}   (retention at k=1 is exactly 1/2)")
    for delta in (Fraction(1, 10), Fraction(1, 10 ** 4), Fraction(1, 10 ** 12)):
        t = [Fraction(1) - delta, Fraction(1)]
        curve_gap = max(
            abs(Fraction(sum(u[:k]), 1) / sum(u[:2]) - Fraction(sum(t[:k]), 1) / sum(t[:2]))
            for k in range(3)
        )
        print(f"    tilt delta={float(delta):.1e}:  curve gap = {float(curve_gap):.3e},"
              f"  k*(tilted) = {frac_knee(t, 2, half)}  (differs)")
    print("    shrinking the tolerance never helps: at zero margin nothing is forced.")


def demo_gate_duality() -> None:
    banner("6. Gate/budget duality: the curve is the envelope of the sweep")
    n, r = 64, 0.75
    w = geometric_corpus(n, r)
    print(f"geometric corpus r={r}, context n={n}")
    print("  gate sweep tau -> k*(tau) (a non-decreasing step function):")
    row = []
    for i in range(10):
        tau = 0.90 + 0.01 * i
        row.append(f"{tau:.2f}:{knee(w, n, tau):2d}")
    print("    " + "  ".join(row))
    print("  duality: sup { tau <= 1 : k*(tau) <= k } = R_w(n,k)")
    for k in (4, 8, 12, 16):
        grid = [j / 20000.0 for j in range(20001)]
        env = max(t for t in grid if knee(w, n, t) <= k)
        print(f"    k={k:3d}:  envelope = {env:.5f}   retained = {retained(w, n, k):.5f}"
              f"   |diff| = {abs(env - retained(w, n, k)):.2e}")


def demo_domain_jump() -> None:
    banner("7. Domain jumps: the projective law and the explicit budget")
    import random

    random.seed(11)
    n, r = 512, 0.885
    a = geometric_corpus(n, r)
    print("  gate window  k*_A(tau/rho^2) <= k*_B(tau) <= k*_A(rho^2 tau),")
    print("  at a gate low enough for the retained coordinate to be non-vacuous:")
    tau_low = 0.80
    for rho in (1.02, 1.05, 1.1):
        factors = [random.uniform(1.0 / rho, rho) for _ in range(n)]
        b = tilt(a, factors)
        ka_lo = knee(a, n, tau_low / rho ** 2)
        ka_hi = knee(a, n, min(1.0, rho ** 2 * tau_low))
        kb = knee(b, n, tau_low)
        print(f"    rho={rho:<5} window = [{ka_lo:3d}, {ka_hi:3d}]"
              f"   k*_B({tau_low}) = {kb:3d}   inside: {ka_lo <= kb <= ka_hi}")
    print("\n  the sharp coordinate is MISSING MASS, not retained mass:")
    tau = 0.98
    for rho in (1.05, 1.1, 1.25):
        print(f"    rho={rho}:  retained-coordinate gate rho^2*tau = {rho**2*tau:.4f}"
              f"  (>1: vacuous)   missing-mass gate = {achieved_gate_after_tilt(tau, rho):.4f}")
    print("\n  sharp law checked directly:  A clears 1-delta at K  =>  B clears")
    print("  1-rho^2 delta at the SAME K, for every rho-tilt B of A:")
    for rho in (1.05, 1.1, 1.25):
        K = knee(a, n, tau)
        target = achieved_gate_after_tilt(tau, rho)
        worst = True
        for _ in range(400):
            factors = [random.uniform(1.0 / rho, rho) for _ in range(n)]
            if not clears(tilt(a, factors), n, K, target):
                worst = False
                break
        print(f"    rho={rho}:  K = {K}, target gate = {target:.4f},"
              f"  400 random tilts all clear: {worst}")
    print("\n  explicit geometric-tail budget  (least K with r^K <= 1 - rho^2 tau):")
    for rho, t in ((1.0, 0.98), (1.0, 0.99), (1.05, 0.90), (1.1, 0.80)):
        try:
            K = geometric_tail_budget(r, rho, t)
            print(f"    r={r}, rho={rho}, tau={t}:  K = {K:3d}   "
                  f"(verify: r^K = {r**K:.5f} <= {1 - rho**2*t:.5f})")
        except ValueError as exc:
            print(f"    r={r}, rho={rho}, tau={t}:  {exc}")


def demo_knee_fan() -> None:
    banner("8. The knee fan: non-empty polyhedral cells, two facets each")
    n, tau = 12, 0.9
    print(f"context n={n}, gate tau={tau}")
    print("  every label 1..n is realised by a one-hot corpus:")
    labels = [knee(one_hot(K - 1, n), n, tau) for K in range(1, n + 1)]
    print(f"    labels of one-hot corpora delta_0..delta_{n-1}: {labels}")
    print(f"    surjective onto 1..{n}: {labels == list(range(1, n + 1))}")
    print("  cell membership = pass at K and failure at K-1 (two linear facets):")
    w = geometric_corpus(n, 0.8)
    K = knee(w, n, tau)
    print(f"    geometric corpus: K = {K}, clears(K) = {clears(w, n, K, tau)},"
          f" clears(K-1) = {clears(w, n, K - 1, tau)}")
    print("  cells are closed under pooling and positive scaling:")
    v = one_hot(K - 1, n)
    if knee(v, n, tau) == K:
        print(f"    k*(w + delta_{K-1}) = {knee(pool(w, v), n, tau)}  (must be {K})")
    print("  cells are disjoint by construction: a corpus has exactly one knee.")


def main() -> None:
    print("The Corpus Algebra of the Attention Knee — numerical demonstrations")
    demo_adjunction_and_bracket()
    demo_context_monotone()
    demo_pooling_sandwich()
    demo_exact_robustness()
    demo_four_decimal_theorem()
    demo_gate_duality()
    demo_domain_jump()
    demo_knee_fan()
    print()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
