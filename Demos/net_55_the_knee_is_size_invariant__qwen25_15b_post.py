"""
Size-Invariant Attention Budgets — numerical demonstrations.

This script is fully self-contained (standard library only, exact rational
arithmetic via `fractions.Fraction` wherever a theorem is being checked).

It demonstrates, numerically:

  1. Scale invariance of the knee            k*(c w) = k*(w)      for c > 0.
  2. The envelope theorem                    one budget for a whole family.
  3. Rigidity                                size-uniformity => uniform concentration.
  4. Multi-head aggregation                  k*(sum of heads) <= max per-head k*.
  5. Bounded distortion / budget transfer    k*(w2,n,t) <= k*(w1,n,lam^2 t),
     and its sharpness                       4-comparable profiles with knees 1, 2.
  6. Refutation of the size law              more mass, smaller knee (18 vs 8).
  7. Realizability of the flat chain         k*(g_{39/50}) = 16 at 512 and 1024.
  8. Sweep audit of the measured tables      sound bracket, grid-floor hole,
                                             monotonicity violations.
  9. Two-point sweep realizability           explicit three-block witness.
 10. The Pythagorean mirror                  similarity invariance, universal
                                             12-key short-leg budget, dichotomy.

Definitions used throughout, for a strictly positive profile w : N -> R:

    head mass          M_w(k)      = sum_{i<k} w_i
    retained fraction  R_w(n,k)    = M_w(min(k,n)) / M_w(n)
    knee               k*(w,n,tau) = min { k : R_w(n,k) >= tau }
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple

Num = Fraction

# --------------------------------------------------------------------------- #
#  Core functionals                                                            #
# --------------------------------------------------------------------------- #


def head_mass(w: Callable[[int], Num], k: int) -> Num:
    """M_w(k) = sum_{i<k} w_i."""
    total: Num = Fraction(0)
    for i in range(k):
        total += w(i)
    return total


def retained(w: Callable[[int], Num], n: int, k: int) -> Num:
    """R_w(n,k) = M_w(min(k,n)) / M_w(n).  Requires n >= 1 and w > 0."""
    return head_mass(w, min(k, n)) / head_mass(w, n)


def kstar(w: Callable[[int], Num], n: int, tau: Num) -> int:
    """Least budget k with R_w(n,k) >= tau.  Always <= n for tau <= 1."""
    for k in range(0, n + 1):
        if retained(w, n, k) >= tau:
            return k
    raise ValueError("gate exceeds 1: no budget clears it")


def geom_profile(r: Num) -> Callable[[int], Num]:
    """g_r(i) = r^i, the geometric profile with decay ratio r in (0,1)."""
    return lambda i: r ** i


def kstar_geometric_small_powers(r: Num, tau: Num, ref: int = 64) -> int:
    """
    Exact knee of a geometric profile at ANY context n >= max(K, ref), computed
    with powers of size at most max(K, ref).

    Certificates (both context-cheap):
        pass:  r^K       <= 1 - tau           (context free)
        fail:  (1 - r^(K-1)) / (1 - r^ref) < tau
    """
    K = 1
    while r ** K > 1 - tau:
        K += 1
        if K > 10_000:
            raise ValueError("no context-free pass certificate found")
    fail = (1 - r ** (K - 1)) / (1 - r ** ref)
    assert fail < tau, "fail certificate did not check out"
    return K


# --------------------------------------------------------------------------- #
#  1. Scale invariance                                                         #
# --------------------------------------------------------------------------- #


def demo_scale_invariance() -> None:
    print("1. SCALE INVARIANCE:  k*(c w) = k*(w) for every c > 0")
    tau = Fraction(98, 100)
    base = geom_profile(Fraction(4, 5))
    for c in [Fraction(1), Fraction(3), Fraction(10), Fraction(1, 7)]:
        scaled: Callable[[int], Num] = lambda i, c=c: c * base(i)
        k0 = kstar(base, 64, tau)
        k1 = kstar(scaled, 64, tau)
        print(f"   c = {str(c):>4}   k*(w) = {k0:>3}   k*(c w) = {k1:>3}   equal: {k0 == k1}")
    print("   -> head replication (c = m) is exactly this case: tripling moves 0 keys.\n")


# --------------------------------------------------------------------------- #
#  2-3. Envelope theorem and rigidity                                          #
# --------------------------------------------------------------------------- #


def envelope_budget(v: Callable[[int], Num], tail_bound: Num, c: Num, tau: Num,
                    max_k: int = 4000) -> int:
    """
    Least K with  (sum_i v_i) - sum_{i<K} v_i  <  (1 - tau) * c,
    where `tail_bound` supplies the exact total sum_i v_i.
    """
    partial: Num = Fraction(0)
    for K in range(0, max_k):
        if tail_bound - partial < (1 - tau) * c:
            return max(K, 1)
        partial += v(K)
    raise ValueError("envelope tail did not shrink enough")


def demo_envelope_and_rigidity() -> None:
    print("2. ENVELOPE THEOREM:  one budget for an entire family, blind to size")
    tau = Fraction(98, 100)
    # envelope v_i = (4/5)^i, total 5;  lead weight floor c = 1/2
    rv = Fraction(4, 5)
    v = geom_profile(rv)
    total_v = 1 / (1 - rv)
    c = Fraction(1, 2)
    K = envelope_budget(v, total_v, c, tau)
    print(f"   envelope v_i = (4/5)^i, lead floor c = 1/2, gate 0.98  ->  K = {K}")

    # A family of genuinely different profiles all under this envelope,
    # indexed by a "size" parameter s (imagine s = parameter count).
    family: Dict[str, Callable[[int], Num]] = {}
    for s, r in [(1, Fraction(1, 2)), (2, Fraction(3, 5)), (3, Fraction(7, 10)),
                 (4, Fraction(39, 50)), (5, Fraction(4, 5))]:
        family[f"model s={s} (r={r})"] = geom_profile(r)

    print("   verifying the single budget K serves every member at every context:")
    ok = True
    for name, W in family.items():
        knees = [kstar(W, n, tau) for n in (16, 32, 64, 128)]
        ok = ok and all(k <= K for k in knees)
        print(f"     {name:<26} k* at n=16,32,64,128: {knees}   all <= K: {all(k <= K for k in knees)}")
    print(f"   size-uniform at K = {K}: {ok}")

    print("3. RIGIDITY:  size-uniformity forces tau * M(n) <= M(K) for every member")
    rigid = True
    for name, W in family.items():
        for n in (16, 32, 64, 128):
            rigid = rigid and (tau * head_mass(W, n) <= head_mass(W, K))
    print(f"   uniform concentration bound holds for every member and context: {rigid}\n")


# --------------------------------------------------------------------------- #
#  4. Multi-head aggregation                                                   #
# --------------------------------------------------------------------------- #


def demo_multihead() -> None:
    print("4. MULTI-HEAD AGGREGATION:  k*(sum of heads) <= max_j k*(head j),")
    print("   with NO hypothesis on the number of heads")
    tau = Fraction(98, 100)
    n = 128
    ratios = [Fraction(1, 2), Fraction(3, 5), Fraction(7, 10), Fraction(39, 50),
              Fraction(4, 5)]
    heads: List[Callable[[int], Num]] = [geom_profile(r) for r in ratios]
    per_head = [kstar(h, n, tau) for h in heads]
    worst = max(per_head)
    print(f"   per-head knees (ratios {[str(r) for r in ratios]}): {per_head}")
    print(f"   worst per-head knee K = {worst}")

    # Aggregate over head pools of growing size, cycling through the pool.
    for H in (1, 2, 3, 5, 10, 40, 200):
        pool = [heads[j % len(heads)] for j in range(H)]
        agg: Callable[[int], Num] = lambda i, pool=pool: sum((h(i) for h in pool), Fraction(0))
        k_agg = kstar(agg, n, tau)
        print(f"     H = {H:>4} heads   k*(aggregate) = {k_agg:>3}   <= {worst}: {k_agg <= worst}")
    print("   -> growing the model by adding heads cannot raise the budget.\n")


# --------------------------------------------------------------------------- #
#  5. Distortion transfer, and its sharpness                                   #
# --------------------------------------------------------------------------- #


def demo_distortion() -> None:
    print("5. BOUNDED DISTORTION:  R_{w1}(n,k)/lam^2 <= R_{w2}(n,k), and")
    print("   k*(w2,n,tau) <= k*(w1,n,lam^2 tau)")
    n = 64
    tau = Fraction(9, 10)
    lam = Fraction(21, 20)
    w1 = geom_profile(Fraction(4, 5))
    # w2 obtained from w1 by a per-coordinate perturbation inside [1/lam, lam]
    perturb = [Fraction(21, 20), Fraction(20, 21), Fraction(1), Fraction(21, 20),
               Fraction(20, 21)]
    w2: Callable[[int], Num] = lambda i: perturb[i % len(perturb)] * w1(i)

    comparable = all(w1(i) <= lam * w2(i) and w2(i) <= lam * w1(i) for i in range(n))
    print(f"   lam = {lam}, profiles lam-comparable on [0,{n}): {comparable}")
    worst_ratio = max(retained(w1, n, k) / retained(w2, n, k) for k in range(1, n + 1))
    print(f"   max_k R_w1/R_w2 = {float(worst_ratio):.6f}  <= lam^2 = {float(lam ** 2):.6f}: "
          f"{worst_ratio <= lam ** 2}")
    shifted = lam ** 2 * tau
    if shifted <= 1:
        lhs, rhs = kstar(w2, n, tau), kstar(w1, n, shifted)
        print(f"   k*(w2,n,{float(tau)}) = {lhs}  <=  k*(w1,n,{float(shifted)}) = {rhs}: {lhs <= rhs}")

    print("   SHARPNESS: 4-comparable profiles whose knees genuinely differ")
    a = [Fraction(95), Fraction(4), Fraction(1)]
    b = [Fraction(85), Fraction(14), Fraction(1)]
    wa: Callable[[int], Num] = lambda i: a[i] if i < 3 else Fraction(1)
    wb: Callable[[int], Num] = lambda i: b[i] if i < 3 else Fraction(1)
    cmp4 = all(wa(i) <= 4 * wb(i) and wb(i) <= 4 * wa(i) for i in range(3))
    print(f"     (95,4,1) and (85,14,1) are 4-comparable: {cmp4}")
    print(f"     k*((95,4,1), 3, 0.9)  = {kstar(wa, 3, Fraction(9, 10))}")
    print(f"     k*((85,14,1), 3, 0.9) = {kstar(wb, 3, Fraction(9, 10))}")
    print("   -> the lam^2 gate shift cannot be dropped.\n")


# --------------------------------------------------------------------------- #
#  6-7. Refuting the size law; realizing the flat chain                        #
# --------------------------------------------------------------------------- #


def demo_size_law_refuted() -> None:
    print("6. NO MONOTONE SIZE LAW: more total attention mass, SMALLER knee")
    tau = Fraction(98, 100)
    small = geom_profile(Fraction(4, 5))                      # M(n) -> 5
    large: Callable[[int], Num] = lambda i: 10 * geom_profile(Fraction(3, 5))(i)  # M(n) -> 25
    for n in (1, 2, 8, 64):
        ms, ml = head_mass(small, n), head_mass(large, n)
        print(f"   n = {n:>3}: M_small = {float(ms):8.4f} < M_large = {float(ml):8.4f}: {ms < ml}")
    ks = kstar_geometric_small_powers(Fraction(4, 5), tau)
    kl = kstar_geometric_small_powers(Fraction(3, 5), tau)
    print(f"   k*(w_small, 512, 0.98) = {ks}     k*(w_large, 512, 0.98) = {kl}   (scale-invariant)")
    print("   -> a capacity increase with a ten-key DECREASE of the budget.\n")

    print("7. THE MEASURED FLAT CHAIN IS EXACTLY REALIZABLE")
    r = Fraction(39, 50)
    K = kstar_geometric_small_powers(r, tau)
    print(f"   geometric profile with r = 39/50:  k* = {K} at context 512 AND at context 1024")
    print(f"     pass certificate  r^{K}   = {float(r ** K):.6f} <= 1 - tau = {float(1 - tau):.6f}")
    print(f"     fail certificate  (1-r^{K-1})/(1-r^64) = "
          f"{float((1 - r ** (K - 1)) / (1 - r ** 64)):.6f} < tau = {float(tau):.4f}\n")


# --------------------------------------------------------------------------- #
#  8-9. Sweep audit and realizability                                          #
# --------------------------------------------------------------------------- #


SWEEP_512: List[Tuple[int, Fraction]] = [
    (8, Fraction(9727, 10000)), (16, Fraction(9896, 10000)), (24, Fraction(9915, 10000)),
    (32, Fraction(9969, 10000)), (48, Fraction(9993, 10000)), (64, Fraction(9988, 10000)),
]
SWEEP_1024: List[Tuple[int, Fraction]] = [
    (16, Fraction(9806, 10000)), (24, Fraction(9867, 10000)), (32, Fraction(9881, 10000)),
    (48, Fraction(9928, 10000)), (64, Fraction(9927, 10000)), (96, Fraction(9954, 10000)),
    (128, Fraction(9974, 10000)),
]


def audit_sweep(table: Sequence[Tuple[int, Fraction]], n: int, tau: Fraction) -> None:
    """Bracket the knee, flag grid-floor holes, and detect monotonicity violations."""
    violations = [(table[i][0], table[i + 1][0])
                  for i in range(len(table) - 1) if table[i + 1][1] <= table[i][1]]
    fails = [k for k, v in table if v < tau]
    passes = [k for k, v in table if v >= tau]
    lo = max(fails) if fails else None
    hi = min(passes) if passes else None
    print(f"   context n = {n}, gate = {float(tau)}")
    if hi is None:
        print("     no passing grid point: the knee exceeds the grid")
    elif lo is None or lo > hi:
        print(f"     pass at grid floor {hi} with nothing failing below it")
        print(f"     => knee is only bracketed as [1, {hi}]  (GRID-FLOOR HOLE: upper bound only)")
    else:
        print(f"     fail at {lo}, pass at {hi}  =>  sound bracket ({lo}, {hi}]")
    if violations:
        print(f"     monotonicity violations at {violations}: the measured statistic is")
        print("     provably NOT the retained-mass functional (retained mass is strictly")
        print("     increasing in the budget below the context length)")
    else:
        print("     no monotonicity violation detected")


def block_profile(p: int, q: int, a: Num, b: Num, c: Num) -> Callable[[int], Num]:
    """Constant a on [0,p), b on [p,q), c on [q, inf)."""
    return lambda i: a if i < p else (b if i < q else c)


def realize_two_point(p: int, q: int, n: int, v1: Num, v2: Num) -> Callable[[int], Num]:
    """
    Build a strictly positive profile with R(n,p) = v1 and R(n,q) = v2.
    Possible exactly when 0 < v1 < v2 < 1.
    """
    assert 0 < p < q < n and 0 < v1 < v2 < 1, "unrealizable two-point segment"
    a = v1 / p
    b = (v2 - v1) / (q - p)
    c = (1 - v2) / (n - q)
    return block_profile(p, q, a, b, c)


def demo_sweep_audit() -> None:
    print("8. SWEEP AUDIT of the two measured tables")
    tau = Fraction(98, 100)
    audit_sweep(SWEEP_512, 512, tau)
    audit_sweep(SWEEP_1024, 1024, tau)

    print("   grid-floor indeterminacy is real: two genuine profiles both pass at 16 keys")
    print("   on a context of 1024, with knees 16 and 1:")
    for r in (Fraction(39, 50), Fraction(1, 100)):
        K = kstar_geometric_small_powers(r, tau)
        R16 = (1 - r ** 16) / (1 - r ** 1024)
        print(f"     r = {str(r):>7}:  R(1024,16) = {float(R16):.6f} >= 0.98,   k* = {K}")
    print()

    print("9. TWO-POINT REALIZABILITY: monotone segments are exactly the realizable ones")
    w = realize_two_point(8, 16, 512, Fraction(9727, 10000), Fraction(9896, 10000))
    print(f"   three-block witness for (8 -> 0.9727, 16 -> 0.9896) at n = 512:")
    print(f"     R(512,8)  = {float(retained(w, 512, 8)):.6f}")
    print(f"     R(512,16) = {float(retained(w, 512, 16)):.6f}")
    print("   whereas (48 -> 0.9993, 64 -> 0.9988) at n = 512 is NOT realizable:")
    print("     any positive profile has R(512,48) < R(512,64) strictly.\n")


# --------------------------------------------------------------------------- #
#  10. The Pythagorean mirror                                                  #
# --------------------------------------------------------------------------- #


def demo_pythagorean() -> None:
    print("10. THE PYTHAGOREAN MIRROR: the knee is a similarity invariant")
    tau = Fraction(98, 100)
    triples: List[Tuple[int, int, int]] = [(3, 4, 5), (5, 12, 13), (8, 15, 17),
                                           (20, 21, 29), (696, 697, 985)]
    print("   universal short-leg budget at gate 0.98 is 12, attained by (696,697,985):")
    for (a, b, c) in triples:
        r = Fraction(a, c)
        K = kstar_geometric_small_powers(r, tau)
        print(f"     ({a:>3},{b:>3},{c:>3})  short-leg ratio a/c = {float(r):.4f}  k* = {K:>2}"
              f"   <= 12: {K <= 12}")

    print("   exact size invariance: every rescaling of (696,697,985) has the same knee")
    for m in (1, 2, 7, 1000):
        r = Fraction(696 * m, 985 * m)
        print(f"     m = {m:>4}: triple ({696*m},{697*m},{985*m}), ratio {float(r):.6f}, "
              f"k* = {kstar_geometric_small_powers(r, tau)}")

    print("   shape, not size: the SAME triangle (3,4,5) gives knees 8 and 18")
    for (leg, r) in (("short 3/5", Fraction(3, 5)), ("long 4/5", Fraction(4, 5))):
        print(f"     {leg:>9}: k* = {kstar_geometric_small_powers(r, tau)}")

    print("   dichotomy: long legs of near-square triples have unbounded budgets")
    print("   (for large contexts the knee of a geometric profile is the least K with")
    print("    r^K <= 1 - tau, i.e. ceil(log(1-tau)/log r); exact powers are avoided here)")
    for m in (2, 10, 50, 250, 1000):
        t = 2 * m * m + 2 * m
        a, b, c = 2 * m + 1, t, t + 1
        assert a * a + b * b == c * c
        r = Fraction(b, c)
        K = math.ceil(math.log(float(1 - tau)) / math.log(float(r)))
        print(f"     m = {m:>4}: triple ({a},{b},{c}), long-leg ratio {float(r):.8f}, k* = {K}")
    print("   -> no universal budget on long legs, at any gate above 5/9.\n")


# --------------------------------------------------------------------------- #


def main() -> None:
    print("=" * 78)
    print(" SIZE-INVARIANT ATTENTION BUDGETS — numerical demonstrations")
    print("=" * 78 + "\n")
    demo_scale_invariance()
    demo_envelope_and_rigidity()
    demo_multihead()
    demo_distortion()
    demo_size_law_refuted()
    demo_sweep_audit()
    demo_pythagorean()
    print("=" * 78)
    print(" Every certificate above is checked in exact rational arithmetic; floating")
    print(" point appears only for display, and in the closed-form asymptotic knee")
    print(" ceil(log(1-tau)/log r) used for the very large long-leg ratios.")
    print("=" * 78)


if __name__ == "__main__":
    main()
