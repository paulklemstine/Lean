"""
The Symmetric-Mixture Bump — numerical demonstrations.
=====================================================

A self-contained, dependency-free demonstration of the sup-convolution theory of the
attention key budget of mixed-domain contexts.

Everything is computed in *exact rational arithmetic* (``fractions.Fraction``), so the
integer knee values printed below are exact, not floating-point approximations.

Model
-----
A *sorted attention profile* is a nonincreasing sequence of positive weights
``a_0 >= a_1 >= ...``.  Its *head mass* is ``A(n) = a_0 + ... + a_{n-1}``.  In a context
of ``n`` keys a budget of ``k`` keys retains the fraction ``A(min(k,n)) / A(n)``, and the
*knee* ``k*(n, tau)`` is the least budget whose retained fraction reaches the gate ``tau``.

For a context built from ``m`` keys of profile ``a`` and ``l`` keys of profile ``b`` the
head mass is the **sup-convolution**

    H(m, l, k) = max_{0 <= j <= k} [ A(min(j, m)) + B(min(k - j, l)) ],

because a top-``k`` selection of the union is exactly a split of the budget between the
two domains.  For ``d`` domains the head mass is the ``d``-fold sup-convolution, obtained
by nesting.

What the demonstrations show
----------------------------
1. Pure endpoints of the geometric profile sit at knee 6; the balanced mixture at 12.
2. The full mixing-ratio sweep is a *bump*: flat shoulders, strict interior maximum.
3. The three pre-registered shapes (linear, dip, monotone) are all refuted.
4. Mass, not blocks: a minority domain with half the keys but a thousandth of the mass
   leaves the knee at its pure value 6.
5. The sub/superadditive sandwich brackets the balanced knee at exactly twice the pure one.
6. Schur-concavity: the sweep is monotone in the imbalance, with no interior local minima.
7. The domain ladder 6, 12, 18, 23, ... equals ceil(143 d / 25) and *not* 6 d.
8. The tangent-line bound (7 - j)/64 <= 2^-j is tight exactly at j = 5 and j = 6.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

# --------------------------------------------------------------------------------------
# Profiles
# --------------------------------------------------------------------------------------

Profile = Callable[[int], Fraction]

GATE: Fraction = Fraction(98, 100)  # the experimental retention gate tau = 0.98


def geom_half(i: int) -> Fraction:
    """The reference geometric profile ``a_i = 2^-i`` — a clean spectral gap."""
    return Fraction(1, 2 ** i)


def geom_light(i: int) -> Fraction:
    """Same shape, a thousandth of the mass: ``b_i = 10^-3 * 2^-i``."""
    return Fraction(1, 1000) * Fraction(1, 2 ** i)


def inverse_square(i: int) -> Fraction:
    """A heavier-tailed profile ``a_i = (i+1)^-2``, closer to measured spectra."""
    return Fraction(1, (i + 1) ** 2)


# --------------------------------------------------------------------------------------
# Single-domain theory
# --------------------------------------------------------------------------------------


def prefix_masses(a: Profile, n: int) -> List[Fraction]:
    """Return ``[A(0), A(1), ..., A(n)]`` where ``A(t) = sum_{i<t} a_i``."""
    out: List[Fraction] = [Fraction(0)]
    acc = Fraction(0)
    for i in range(n):
        acc += a(i)
        out.append(acc)
    return out


def head_mass(a: Profile, n: int) -> Fraction:
    """Head mass ``A(n)`` of the top ``n`` keys."""
    return prefix_masses(a, n)[n]


def retained(a: Profile, n: int, k: int) -> Fraction:
    """Retained fraction ``A(min(k,n)) / A(n)`` of a budget ``k`` in a context of ``n``."""
    pre = prefix_masses(a, n)
    return pre[min(k, n)] / pre[n]


def knee(a: Profile, n: int, tau: Fraction = GATE) -> int:
    """The pure knee ``k*(n, tau)``: least budget whose retained fraction reaches ``tau``."""
    pre = prefix_masses(a, n)
    total = pre[n]
    for k in range(n + 1):
        if pre[min(k, n)] >= tau * total:
            return k
    return n


# --------------------------------------------------------------------------------------
# Two-domain theory: the sup-convolution
# --------------------------------------------------------------------------------------


def mix_head(a: Profile, b: Profile, m: int, l: int, k: int) -> Fraction:
    """Sup-convolution head mass ``H(m, l, k)`` of a two-domain context."""
    pa = prefix_masses(a, m)
    pb = prefix_masses(b, l)
    return max(pa[min(j, m)] + pb[min(k - j, l)] for j in range(k + 1))


def mix_total(a: Profile, b: Profile, m: int, l: int) -> Fraction:
    """Total mass ``A(m) + B(l)`` of a two-domain context."""
    return head_mass(a, m) + head_mass(b, l)


def mix_knee(a: Profile, b: Profile, m: int, l: int, tau: Fraction = GATE) -> int:
    """The mixed knee ``k*(m, l, tau)``."""
    pa = prefix_masses(a, m)
    pb = prefix_masses(b, l)
    total = pa[m] + pb[l]
    target = tau * total
    for k in range(m + l + 1):
        best = max(pa[min(j, m)] + pb[min(k - j, l)] for j in range(k + 1))
        if best >= target:
            return k
    return m + l


def optimal_split(a: Profile, b: Profile, m: int, l: int, k: int) -> Tuple[int, int]:
    """The budget split ``(j, k-j)`` attaining the sup-convolution at budget ``k``."""
    pa = prefix_masses(a, m)
    pb = prefix_masses(b, l)
    best_j, best_v = 0, None
    for j in range(k + 1):
        v = pa[min(j, m)] + pb[min(k - j, l)]
        if best_v is None or v > best_v:
            best_j, best_v = j, v
    return best_j, k - best_j


# --------------------------------------------------------------------------------------
# d-domain theory: the d-fold sup-convolution
# --------------------------------------------------------------------------------------


def mixn_head_table(a: Profile, m: int, d: int, kmax: int) -> List[Fraction]:
    """Table ``[H_d(0), ..., H_d(kmax)]`` of the ``d``-fold sup-convolution head mass."""
    pa = prefix_masses(a, m)
    cur: List[Fraction] = [Fraction(0)] * (kmax + 1)  # d = 0
    for _ in range(d):
        nxt = [
            max(cur[j] + pa[min(k - j, m)] for j in range(k + 1)) for k in range(kmax + 1)
        ]
        cur = nxt
    return cur


def mixn_knee(a: Profile, m: int, d: int, tau: Fraction = GATE, kmax: int = 0) -> int:
    """The ``d``-domain knee: least budget clearing ``tau`` against total mass ``d * A(m)``."""
    if kmax == 0:
        kmax = min(d * m, 8 * d + 8)
    table = mixn_head_table(a, m, d, kmax)
    target = tau * d * head_mass(a, m)
    for k, v in enumerate(table):
        if v >= target:
            return k
    raise RuntimeError("budget window too small; increase kmax")


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_1_endpoints_and_centre(m: int = 64) -> None:
    rule("1.  Pure endpoints cost 6; the balanced mixture costs 12")
    print(f"    profile a_i = 2^-i, gate tau = {float(GATE)}, {m} keys per side\n")
    kp = knee(geom_half, 2 * m)
    print(f"    pure context of {2*m} keys                  k* = {kp}")
    print(f"        retained at k=5 : {float(retained(geom_half, 2*m, 5)):.6f}  (fails)")
    print(f"        retained at k=6 : {float(retained(geom_half, 2*m, 6)):.6f}  (passes)")
    km = mix_knee(geom_half, geom_half, m, m)
    print(f"\n    balanced mixture {m} + {m}                  k* = {km}")
    h11 = mix_head(geom_half, geom_half, m, m, 11)
    h12 = mix_head(geom_half, geom_half, m, m, 12)
    tot = mix_total(geom_half, geom_half, m, m)
    print(f"        retained at k=11: {float(h11/tot):.6f}  (fails), best split "
          f"{optimal_split(geom_half, geom_half, m, m, 11)}")
    print(f"        retained at k=12: {float(h12/tot):.6f}  (passes), best split "
          f"{optimal_split(geom_half, geom_half, m, m, 12)}")
    assert kp == 6 and km == 12


def demo_2_the_sweep(total: int = 128) -> None:
    rule("2.  The mixing-ratio sweep is a BUMP, not a line, dip or ramp")
    print(f"    total key count fixed at {total}; sweeping the split (m, {total}-m)\n")
    print("      m      l    ratio     k*")
    print("    " + "-" * 34)
    values = []
    for m in [0, 8, 16, 32, 48, 64, 80, 96, 112, 120, total]:
        l = total - m
        k = mix_knee(geom_half, geom_half, m, l)
        values.append((m, k))
        bar = "#" * k
        print(f"    {m:4d}  {l:5d}   {m/total:5.2f}   {k:4d}  {bar}")
    ks = [k for _, k in values]
    endpoints = max(ks[0], ks[-1])
    centre = dict(values)[total // 2]
    print(f"\n    endpoints  = {ks[0]}, {ks[-1]}          centre = {centre}")
    print(f"    P1 (linear)  refuted: centre {centre} != endpoint average "
          f"{(ks[0]+ks[-1])/2}")
    print(f"    P2 (dip)     refuted: centre {centre} >  max(endpoints) {endpoints}")
    print("    P3 (monotone) refuted: the sweep rises then falls "
          f"({ks[0]} -> {centre} -> {ks[-1]})")
    assert centre > endpoints


def demo_3_mass_not_blocks(m: int = 64) -> None:
    rule("3.  Mass, not blocks: a light domain is invisible")
    heavy_heavy = mix_knee(geom_half, geom_half, m, m)
    heavy_light = mix_knee(geom_half, geom_light, m, m)
    pure = knee(geom_half, 2 * m)
    print(f"    balanced KEY count, balanced MASS   ({m}+{m}, both 2^-i)      k* = "
          f"{heavy_heavy}")
    print(f"    balanced KEY count, 1000:1 MASS     ({m}+{m}, second is light) k* = "
          f"{heavy_light}")
    print(f"    pure domain                                                    k* = {pure}")
    print("\n    Half the keys from the second domain and nothing happens: the premium")
    print("    is switched on by comparable MASS, not by comparable block counts.")
    assert heavy_light == pure == 6 and heavy_heavy == 12

    print("\n    Minority threshold (few keys, not little mass):")
    for l in [1, 3, 5, 8, 16]:
        k = mix_knee(geom_half, geom_half, m, l)
        tag = "below plateau" if k < 12 else "at plateau"
        print(f"        minority of {l:2d} keys   k* = {k:2d}   ({tag})")


def demo_4_sandwich(m: int = 64) -> None:
    rule("4.  The doubling sandwich brackets the balanced knee")
    tau = GATE
    relaxed = 2 * tau - 1
    lo = 2 * knee(geom_half, m, relaxed)
    mid = mix_knee(geom_half, geom_half, m, m, tau)
    hi = 2 * knee(geom_half, m, tau)
    print(f"    gate tau = {float(tau)},  relaxed gate 2*tau - 1 = {float(relaxed)}\n")
    print(f"        2 * k*(m, 2tau-1)  = {lo}")
    print(f"        k*(m, m, tau)      = {mid}     <-- balanced knee")
    print(f"        2 * k*(m, tau)     = {hi}")
    print("\n    The sandwich collapses: the balanced arm is EXACTLY twice a pure knee.")
    print("    A convex interpolation between the endpoints would give 6.  It gives 12.")
    assert lo <= mid <= hi


def demo_5_schur_concavity(total: int = 96) -> None:
    rule("5.  Schur-concavity: the sweep is ordered by imbalance")
    print("    A 'Robin Hood' step moves keys from the majority side to the minority")
    print("    side.  Each step (weakly) increases the knee, so the response has no")
    print("    interior local minima and peaks exactly at the balanced split.\n")
    print("      split         imbalance |m-l|    total mass       k*")
    print("    " + "-" * 62)
    prev = None
    for m in [16, 24, 32, 40, 48]:
        l = total - m
        k = mix_knee(geom_half, geom_half, m, l)
        mass = mix_total(geom_half, geom_half, m, l)
        print(f"    ({m:3d},{l:4d})        {abs(m-l):4d}         {float(mass):.10f}   {k:4d}")
        if prev is not None:
            assert k >= prev, "Schur-concavity violated"
        prev = k
    print("\n    Total mass is largest at the balanced split (head-mass concavity) and")
    print("    the best available head at each budget is smallest there (mirroring):")
    print("    two effects, same direction.")
    for k in [8, 10, 12]:
        hb = mix_head(geom_half, geom_half, 48, 48, k)
        hu = mix_head(geom_half, geom_half, 16, 80, k)
        print(f"        budget {k:2d}:  H(48,48) = {float(hb):.8f} <= "
              f"H(16,80) = {float(hu):.8f}   {'OK' if hb <= hu else 'FAIL'}")


def demo_6_domain_ladder(m: int = 40, dmax: int = 8) -> None:
    rule("6.  The domain ladder: ceil(143 d / 25), not 6 d")
    print(f"    {m} keys per domain, gate {float(GATE)}\n")
    print("      d    measured k*    ceil(143d/25)    6d     verdict")
    print("    " + "-" * 60)
    for d in range(1, dmax + 1):
        k = mixn_knee(geom_half, m, d)
        formula = -((-143 * d) // 25)  # ceiling division
        naive = 6 * d
        verdict = "6d law holds" if k == naive else f"6d law FAILS (saves {naive - k})"
        print(f"    {d:3d}    {k:8d}    {formula:11d}    {naive:4d}     {verdict}")
        assert k == formula
    print("\n    The per-domain rate is 143/25 = 5.72, not 6.  ceil(5.72 d) = 6 d exactly")
    print("    for d <= 3 because 0.28 d < 1 there — the first three rungs of the ladder")
    print("    are a rounding coincidence that hides the true rate.")


def demo_7_tangent_line() -> None:
    rule("7.  The tangent line (7-j)/64 <= 2^-j, tight exactly at j = 5 and j = 6")
    print("      j      (7-j)/64        2^-j        gap")
    print("    " + "-" * 50)
    for j in range(0, 10):
        lhs = Fraction(7 - j, 64)
        rhs = Fraction(1, 2 ** j)
        gap = rhs - lhs
        tag = "  <-- TIGHT" if gap == 0 else ""
        print(f"    {j:3d}   {float(lhs):10.6f}  {float(rhs):10.6f}  "
              f"{float(gap):10.6f}{tag}")
        assert lhs <= rhs
    print("\n    Summing over d domains with allocations totalling k gives")
    print("        sum_i 2^-j_i  >=  (7d - k)/64 ,")
    print("    and the gate demands sum_i 2^-j_i <= d/50, whence k >= 143 d / 25.")
    print("    Equality at block sizes 5 and 6 makes the bound attainable.")


def demo_8_extremal_allocations(dmax: int = 6) -> None:
    rule("8.  The extremal allocations use only block sizes 5 and 6")
    print("      d    k* = ceil(143d/25)    blocks (6's, 5's)     leftover tail")
    print("    " + "-" * 68)
    for d in range(1, dmax + 1):
        k = -((-143 * d) // 25)
        sixes = k - 5 * d          # x with 6x + 5y = k, x + y = d
        fives = d - sixes
        tail = Fraction(sixes, 64) + Fraction(fives, 32)
        budgetcap = Fraction(d, 50)
        ok = "clears gate" if tail <= budgetcap else "FAILS"
        print(f"    {d:3d}    {k:12d}         {sixes:3d} x 6, {fives:3d} x 5     "
              f"{float(tail):.6f} <= {float(budgetcap):.6f}  {ok}")
        assert tail <= budgetcap and sixes >= 0 and fives >= 0


def demo_9_finer_profile(m: int = 32) -> None:
    rule("9.  A finer-grained profile: the interior of the sweep becomes shaped")
    print("    The geometric profile has a coarse knee grid (mass halves per key), so")
    print("    its sweep is flat across the whole interior.  On a heavier tail the grid")
    print("    is finer and the interior resolves into a genuine curve — while the")
    print("    ordering guaranteed by Schur-concavity still holds.\n")

    total = 2 * m
    print("      m      l      k* (2^-i)     k* ((i+1)^-2)")
    print("    " + "-" * 50)
    for mm in [4, 8, 12, 16, 20, 24, 28, 32]:
        ll = total - mm
        kg = mix_knee(geom_half, geom_half, mm, ll)
        kp = mix_knee(inverse_square, inverse_square, mm, ll)
        print(f"    {mm:4d}  {ll:5d}   {kg:10d}     {kp:12d}")
    print("\n    Both sweeps peak at the balanced split; the heavier-tailed one climbs")
    print("    to the peak through intermediate values instead of jumping.")


def main() -> None:
    print(__doc__)
    demo_1_endpoints_and_centre()
    demo_2_the_sweep()
    demo_3_mass_not_blocks()
    demo_4_sandwich()
    demo_5_schur_concavity()
    demo_6_domain_ladder()
    demo_7_tangent_line()
    demo_8_extremal_allocations()
    demo_9_finer_profile()
    rule("All demonstrations completed; every assertion checked in exact arithmetic.")


if __name__ == "__main__":
    main()
