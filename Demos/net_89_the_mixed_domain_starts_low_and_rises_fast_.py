"""
The Arithmetic of Mixed-Domain Key Budgets — numerical demonstrations.

Self-contained. No third-party dependencies. Run with:

    python3 demo.py

Every routine below is a direct numerical realisation of one of the theorems in the
accompanying paper:

  * the mediant sandwich and the cage on the pooled knee,
  * the three witnesses attaining min / midpoint / max (no-formula theorem),
  * the convex-combination identity with weight the mass share,
  * the halving reduction and the doubling law for context-doubling increments,
  * the m-fold multiplier law and the rarest-domain (s:1) multiplier,
  * the gate staircase, its stability radius, and its sharpness,
  * block interleaving: aligned invariance, the intra-block identities, the exact knee,
  * the closed formula for the mixing-ratio critical weight,
  * the two-sided spectral estimators.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Number = Fraction

# ----------------------------------------------------------------------------------
# 1. Core definitions: head mass, retained mass, knee, increment
# ----------------------------------------------------------------------------------


def head_mass(w: Sequence[Number], k: int) -> Number:
    """H_w(k) = sum of the first k weights."""
    return sum(w[:k], Fraction(0))


def retained(w: Sequence[Number], n: int, k: int) -> Number:
    """R_w(n,k) = H_w(min(k,n)) / H_w(n)."""
    return head_mass(w, min(k, n)) / head_mass(w, n)


def knee(w: Sequence[Number], n: int, tau: Number) -> int:
    """k*_w(n,tau) = least k with R_w(n,k) >= tau."""
    total = head_mass(w, n)
    acc = Fraction(0)
    for k in range(n + 1):
        if acc >= tau * total:
            return k
        acc += w[k]
    return n


def increment(w: Sequence[Number], tau: Number, n: int) -> int:
    """Delta_w(tau,n) = k*(2n) - k*(n)."""
    return knee(w, 2 * n, tau) - knee(w, n, tau)


def step_width(w: Sequence[Number], n: int, k: int) -> Number:
    """sw_w(n,k) = w_k / H_w(n): the width of one step of the gate staircase."""
    return w[k] / head_mass(w, n)


# ----------------------------------------------------------------------------------
# 2. Combination operators
# ----------------------------------------------------------------------------------


def pool(a: Number, b: Number, u: Sequence[Number], v: Sequence[Number]) -> List[Number]:
    """(pool_{a,b}(u,v))_i = a u_i + b v_i."""
    return [a * ui + b * vi for ui, vi in zip(u, v)]


def mix(u: Sequence[Number], v: Sequence[Number]) -> List[Number]:
    """Alternating interleaving: u_0, v_0, u_1, v_1, ..."""
    out: List[Number] = []
    for ui, vi in zip(u, v):
        out.append(ui)
        out.append(vi)
    return out


def mix_block(b: int, u: Sequence[Number], v: Sequence[Number]) -> List[Number]:
    """Blocks of b keys alternate between the two domains; mix_block(1,.,.) = mix."""
    out: List[Number] = []
    n = min(len(u), len(v))
    for q in range(n // b):
        out.extend(u[b * q: b * q + b])
        out.extend(v[b * q: b * q + b])
    return out


def round_robin(family: Sequence[Sequence[Number]]) -> List[Number]:
    """m-fold round robin: U^{(i mod m)}_{floor(i/m)}."""
    m = len(family)
    n = min(len(f) for f in family)
    return [family[i % m][i // m] for i in range(m * n)]


def pool_family(family: Sequence[Sequence[Number]]) -> List[Number]:
    """Keywise sum of a family of profiles."""
    n = min(len(f) for f in family)
    return [sum((f[i] for f in family), Fraction(0)) for i in range(n)]


def mix_rate(s: int, u: Sequence[Number], v: Sequence[Number]) -> List[Number]:
    """s:1 interleaving: s keys of u, then one key of v, periodically."""
    out: List[Number] = []
    periods = min(len(u) // s, len(v))
    for q in range(periods):
        out.extend(u[s * q: s * q + s])
        out.append(v[q])
    return out


def pool_uneven(s: int, u: Sequence[Number], v: Sequence[Number]) -> List[Number]:
    """The pooled partner of the s:1 mixture: each key bundles s keys of u with one of v."""
    periods = min(len(u) // s, len(v))
    return [head_mass(u, s * (q + 1)) - head_mass(u, s * q) + v[q] for q in range(periods)]


def mass_share(a: Number, b: Number, u: Sequence[Number], v: Sequence[Number], n: int) -> Number:
    """lambda = a H_u(n) / (a H_u(n) + b H_v(n))."""
    return a * head_mass(u, n) / (a * head_mass(u, n) + b * head_mass(v, n))


# ----------------------------------------------------------------------------------
# 3. Profiles used in the demonstrations
# ----------------------------------------------------------------------------------


def const_profile(value: Number, n: int) -> List[Number]:
    return [value for _ in range(n)]


def geometric_profile(r: Number, n: int) -> List[Number]:
    return [r ** i for i in range(n)]


def head_heavy(head: Number, tail: Number, n: int) -> List[Number]:
    return [head if i == 0 else tail for i in range(n)]


F = Fraction

U_A: List[Number] = head_heavy(F(10), F(1), 4)
U_B: List[Number] = head_heavy(F(100), F(1), 4)
U_C: List[Number] = head_heavy(F(1, 10), F(1, 1000), 4)
V_FLAT: List[Number] = const_profile(F(1), 4)
TAU: Number = F(7, 10)


# ----------------------------------------------------------------------------------
# 4. Demonstrations
# ----------------------------------------------------------------------------------


def demo_sandwich_and_witnesses() -> None:
    print("=" * 78)
    print("1. The mediant sandwich, and the three witnesses that kill the midpoint rule")
    print("=" * 78)
    n, tau = 4, TAU
    for name, u in (("u_A = (10,1,1,1)", U_A), ("u_B = (100,1,1,1)", U_B),
                    ("u_C = (1/10,1/1000,...)", U_C)):
        p = pool(F(1), F(1), u, V_FLAT)
        ku, kv, kp = knee(u, n, tau), knee(V_FLAT, n, tau), knee(p, n, tau)
        lam = mass_share(F(1), F(1), u, V_FLAT, n)
        inside = min(ku, kv) <= kp <= max(ku, kv)
        print(f"  {name:26s}  k*_u={ku}  k*_v={kv}  k*_pool={kp}"
              f"   mass share lambda={float(lam):.4f}   cage holds: {inside}")
        # the mediant sandwich, budget by budget
        for k in range(n + 1):
            lo = min(retained(u, n, k), retained(V_FLAT, n, k))
            hi = max(retained(u, n, k), retained(V_FLAT, n, k))
            assert lo <= retained(p, n, k) <= hi
        # the convex-combination identity
        for k in range(n + 1):
            lhs = retained(p, n, k)
            rhs = lam * retained(u, n, k) + (1 - lam) * retained(V_FLAT, n, k)
            assert lhs == rhs, (k, lhs, rhs)
    print("  All three pairs have component knees (1,3); the pooled knees are 2, 1, 3.")
    print("  => min, midpoint and max are all attained: no function of the component")
    print("     knees can compute the mixed knee, and 'mixed = midpoint' is refuted.")
    print("  The convex-combination identity R_pool = lam*R_u + (1-lam)*R_v held exactly")
    print("  at every budget, for every pair.\n")


def demo_halving_and_doubling() -> None:
    print("=" * 78)
    print("2. Interleaving is pooling in doubled key units; the doubling law")
    print("=" * 78)
    n = 32
    u = geometric_profile(F(9, 10), 2 * n)
    v = [F(1, 1) / (i + 1) for i in range(2 * n)]
    m = mix(u, v)
    p = pool(F(1), F(1), u, v)
    for k in range(n + 1):
        assert retained(m, 2 * n, 2 * k) == retained(p, n, k)
    print("  Verified: R_mix(2n,2k) = R_pool(n,k) for all k <= n = 32.")
    for tau_num in (70, 80, 90, 95, 99):
        tau = F(tau_num, 100)
        q = knee(p, n, tau)
        km = knee(m, 2 * n, tau)
        d_pool = increment(p, tau, n // 2)
        d_mix = increment(m, tau, n)
        print(f"  tau={float(tau):.2f}:  Q=k*_pool(n)={q:3d}   k*_mix(2n)={km:3d}"
              f"   bracket [2Q-1,2Q]=[{2*q-1},{2*q}]  ok={2*q-1 <= km <= 2*q}"
              f"   |D_mix - 2 D_pool| = {abs(d_mix - 2 * d_pool)}")
    print("  The mixed knee sits in [2Q-1, 2Q] always, and the increment is twice the")
    print("  pooled increment up to one key.\n")


def demo_doubling_is_not_cross_domain() -> None:
    print("=" * 78)
    print("3. The doubled increment is NOT a cross-domain effect")
    print("=" * 78)
    n = 64
    u = [F(1, 1) / (i + 1) for i in range(2 * n)]
    for c in (F(1), F(3), F(1, 7)):
        selfmix = mix(u, [c * x for x in u])
        tau = F(9, 10)
        d_pure = increment(u, tau, n // 2)
        d_mix = increment(selfmix, tau, n)
        print(f"  c={str(c):5s}  pure increment={d_pure}   self-interleaved increment={d_mix}"
              f"   (predicted {2*d_pure-1}..{2*d_pure+1})")
    print("  A domain interleaved with a rescaled copy of ITSELF already doubles the")
    print("  increment: '+8 versus +4' is a property of the protocol, not of Python vs")
    print("  English.\n")


def demo_multiplier_laws() -> None:
    print("=" * 78)
    print("4. Multiplier laws: m domains give multiplier m; s:1 gives multiplier s+1")
    print("=" * 78)
    n = 24
    tau = F(9, 10)
    base = [F(1, 1) / (i + 1) for i in range(2 * n)]
    for m in (2, 3, 4):
        family = [[x * F(m - j, m) for x in base] for j in range(m)]
        rr = round_robin(family)
        pf = pool_family(family)
        d_pool = increment(pf, tau, n // 2)
        d_rr = increment(rr, tau, m * n // 2)
        print(f"  m={m}:  pooled increment={d_pool}   round-robin increment={d_rr}"
              f"   |D_rr - m*D_pool| = {abs(d_rr - m * d_pool)} <= {m-1}")
    print()
    u = [F(1, 1) / (i + 1) for i in range(8 * n)]
    v = [F(1, 2) / (i + 1) for i in range(8 * n)]
    for s in (1, 2, 3, 4, 9):
        mr = mix_rate(s, u, v)
        pu = pool_uneven(s, u, v)
        d_pool = increment(pu, tau, n // 2)
        d_rate = increment(mr, tau, (s + 1) * n // 2)
        print(f"  s={s}: rates {s}/{s+1} and 1/{s+1};  pooled increment={d_pool}"
              f"   {s}:1 increment={d_rate}   ratio ~ {d_rate / max(d_pool,1):.2f}"
              f"   (predicted multiplier {s+1})")
    print("  The multiplier is the reciprocal of the RAREST rate, not the number of")
    print("  domains (which is 2 for every s). A 90:10 blend must show a tenfold rise.\n")


def demo_staircase_and_resolution() -> None:
    print("=" * 78)
    print("5. The gate staircase: stability radius, sharpness, and halved resolution")
    print("=" * 78)
    n = 8
    w = [F(1, 1) / (i + 1) for i in range(n)]
    tau = F(3, 4)
    k = knee(w, n, tau)
    radius = min(tau - retained(w, n, k - 1), retained(w, n, k) - tau)
    print(f"  Profile w_i = 1/(i+1), n={n}, tau={float(tau):.3f}: knee K={k}, "
          f"stability radius={float(radius):.6f}")
    for delta in (radius / 2, -radius / 2):
        assert knee(w, n, tau + delta) == k
    print("  Every gate within that radius returns the same knee. Now sit on a step edge:")
    edge = retained(w, n, 3)
    eps = step_width(w, n, 3) / 2
    print(f"    gate exactly at R_w(n,3)={float(edge):.6f}:  knee={knee(w, n, edge)}")
    print(f"    gate raised by half a step ({float(eps):.6f}): "
          f"knee={knee(w, n, edge + eps)}")
    print("  => the radius is sharp; a knee reported near a step edge measures the gate.")
    u = [F(1, 1) / (i + 1) for i in range(n)]
    v = [F(1, 3) / (i + 1) ** 2 for i in range(n)]
    m, p = mix(u, v), pool(F(1), F(1), u, v)
    for k in range(n - 1):
        lhs = step_width(m, 2 * n, 2 * k) + step_width(m, 2 * n, 2 * k + 1)
        assert lhs == step_width(p, n, k)
        assert min(step_width(m, 2 * n, 2 * k),
                   step_width(m, 2 * n, 2 * k + 1)) <= step_width(p, n, k) / 2
    print("  Verified: the two mixed sub-steps sum to the pooled step, and the narrower")
    print("  one is at most half of it. Doubled increment, halved resolution.\n")


def demo_block_interleaving() -> None:
    print("=" * 78)
    print("6. Block interleaving: aligned invariance and the EXACT intra-block knee")
    print("=" * 78)
    n, b = 6, 5
    u = [F(1, 1) / (i + 1) for i in range(b * n)]
    v = [F(2, 3) ** i for i in range(b * n)]
    mb = mix_block(b, u, v)
    p = pool(F(1), F(1), u, v)
    for k in range(n + 1):
        assert retained(mb, 2 * b * n, 2 * b * k) == retained(p, b * n, b * k)
    print(f"  Block size b={b}: verified R_block(2bn,2bk) = R_pool(bn,bk) for all k.")
    # intra-block master identities
    for q in range(n):
        for r in range(b + 1):
            assert head_mass(mb, 2 * b * q + r) == head_mass(u, b * q + r) + head_mass(v, b * q)
            assert (head_mass(mb, 2 * b * q + b + r)
                    == head_mass(u, b * q + b) + head_mass(v, b * q + r))
    print("  Verified both intra-block identities: inside a half-block only one domain")
    print("  accumulates, so the head mass grows one domain at a time.")
    for tau_num in (50, 70, 90, 97):
        tau = F(tau_num, 100)
        kb = knee(mb, 2 * b * n, tau)
        q_pool = knee(p, b * n, tau)
        sharp = 2 * q_pool + b - (q_pool % b)
        print(f"  tau={float(tau):.2f}: blocked knee={kb:3d}   pooled Q={q_pool:3d}"
              f"   old bracket ({2*q_pool-2*b},{2*q_pool+2*b}]"
              f"   sharp upper bound {sharp}  ok={kb <= sharp}")
    print("  The exact blocked knee is pinned by two PURE-domain inequalities; the mixed")
    print("  context never needs to be built.\n")


def demo_critical_weight() -> None:
    print("=" * 78)
    print("7. The mixing-ratio sweep: monotone, one kink, closed formula")
    print("=" * 78)
    n, tau = 4, TAU
    u, v = U_A, V_FLAT
    K = knee(u, n, tau)
    num = tau * head_mass(v, n) - head_mass(v, K)
    den = head_mass(u, K) - tau * head_mass(u, n)
    a_star = max(Fraction(0), num / den)
    print(f"  u=(10,1,1,1), v=(1,1,1,1), n=4, tau=7/10.  Dominant knee K={K}.")
    print(f"  Closed formula: a* = (tau*H_v(n) - H_v(K)) / (H_u(K) - tau*H_u(n))"
          f" = ({num}) / ({den}) = {a_star}")
    weights = [F(1, 10), F(2, 5), F(8, 19), F(1), F(19, 10), F(2), F(5)]
    print("  Sweep (weight a on the dominant domain, weight 1 on the other):")
    for a in weights:
        p = pool(a, F(1), u, v)
        print(f"    a = {str(a):6s}  ->  k*_pool = {knee(p, n, tau)}"
              f"   {'(collapsed onto k*_u)' if knee(p, n, tau) == K else ''}")
    print(f"  The sweep is monotone with kinks at 8/19 and {a_star}; the balanced protocol")
    print("  a=1 sits strictly BELOW the critical weight, which is exactly why its knee")
    print("  (2) exceeds the dominant knee (1). No mixed measurement was needed.\n")


def demo_spectral_estimators() -> None:
    print("=" * 78)
    print("8. A budget measurement is a spectral measurement")
    print("=" * 78)

    def universal_budget_ok(r: float, tau: float, K: int) -> bool:
        """r^K <= (1-tau)(1-r)  =>  k*(n) <= K for every context length n."""
        return r ** K <= (1.0 - tau) * (1.0 - r)

    tau = 0.99
    for K in (6, 9, 12):
        # the largest candidate ratio still excluded by an observation k* > K
        lo, hi = 0.0, 1.0
        for _ in range(80):
            mid = 0.5 * (lo + hi)
            if universal_budget_ok(mid, tau, K):
                lo = mid
            else:
                hi = mid
        print(f"  gate {tau}: an observed knee exceeding K={K} certifies decay ratio "
              f"r > {lo:.4f}")
    print(f"  In particular K=9 passes the criterion ((1/2)^9 = {0.5**9:.6f} <= "
          f"{(1-tau)*(1-0.5):.6f}), so a MIXED knee of 20 at context 2n --- which")
    print("  exceeds 2K = 18 --- already certifies r > 1/2.")
    # the dual, floor-rate bound: q^{2K} <= (1-tau)/tau
    print("  Dually, the mixed knee of 20 forces the pooled knee to be at most 10")
    print("  (halving reduction), and the floor-rate estimator at K=10 then gives:")
    for K, tau in ((10, 0.99), (6, 0.95)):
        bound = ((1.0 - tau) / tau) ** (1.0 / (2 * K))
        print(f"    gate {tau}: pooled knee at most K={K} (with n >= 2K) certifies "
              f"floor rate q <= {bound:.4f}")
    print("  So the two reported integers pin the per-key ratio into (1/2, 4/5):")
    print("  a genuine two-sided spectral measurement, not a corpus measurement.\n")


def demo_reported_table() -> None:
    print("=" * 78)
    print("9. The reported table, audited")
    print("=" * 78)
    print("      ctx    mixed   code   prose")
    print("      512      12     12      16")
    print("     1024      20     16      20")
    print("  Sampling grid: failures observed at 8 and 16, passes at 12 and 20.")
    lo = 17 - 12
    hi = 20 - 9
    print(f"  => k*(512) in [9,12] and k*(1024) in [17,20], so the increment is only")
    print(f"     pinned to [{lo},{hi}] -- the reported '+8' is one point of a width-{hi-lo}")
    print("     window. The doubling law predicts a value near 8; the data are consistent")
    print("     with it but do not isolate it. Reporting the bracket is the honest form.\n")


def main() -> None:
    demo_sandwich_and_witnesses()
    demo_halving_and_doubling()
    demo_doubling_is_not_cross_domain()
    demo_multiplier_laws()
    demo_staircase_and_resolution()
    demo_block_interleaving()
    demo_critical_weight()
    demo_spectral_estimators()
    demo_reported_table()
    print("All structural identities asserted above held exactly (rational arithmetic).")


if __name__ == "__main__":
    main()
