"""08_Lhalf_costs.py -- the final cost table.  What does the axis buy?

The claim being tested: a function field changes the L[1/2] CONSTANT.

We compute, for N = 2^k, the ECM stage-1 cost in MODULAR MULTIPLICATIONS and
compare the three mechanisms that reach the same goal:

  ECM     : walk [M]P on E(Z/NZ) with the Montgomery ladder (x-only).
  TORUS   : walk f^M on T_D(Z/NZ), 4 mults/step, sqrt-free sampler.
  TORUS+  : the same, but ASSUMING we can pick the branch with (D/P) = -1
            (the "smooth branch").  This is the axis's BEST case.

The single question each must answer: cost = (walk length) x (mults per step)
/ P(order is B-smooth).

Key measured facts feeding the table:
  * order of f in T_D(F_p) divides p - (D/p), i.e. p+1 if (D/p) = -1.
  * smoothness at B is the smoothness of p+1 resp. p-1.
  * at N=2^2048 those differ by a CONSTANT factor in probability, not in the
    exponent -- so the exponent is unchanged and only the constant moves.
  * the branch cannot be identified without p (the Jacobi symbol gives only
    the product (D/p)(D/q)).
"""
import math

N_BITS = 2048
LN_N = N_BITS * math.log(2)
LN_P = LN_N / 2


def rho(u, N=20000):
    """Dickman rho by the Buchstab integral (self-similar recursion)."""
    if u <= 1.0:
        return 1.0
    if u <= 1.5:
        pass
    h = (u - 1.0) / N
    tot = 0.0
    for i in range(N + 1):
        t = 1.0 + i * h
        w = 1 if i in (0, N) else (4 if i % 2 else 2)
        v = 1.0 if t - 1.0 <= 1.0 else rho(t - 1.0, 3000)
        tot += w * v / t
    return max(1.0 - tot * h / 3.0, 1e-300)


def ecm_cost(Nbits):
    ln_p = Nbits * math.log(2) / 2
    # optimal B1 = exp(sqrt(2 ln p ln ln p))  (Lenstra / Montgomery)
    s = math.sqrt(2 * ln_p * math.log(ln_p))
    B = math.exp(s)
    u = ln_p / s
    # stage-1 walk length in muls (binary): log2(M) + popcount(M) ~ 1.5*log2(M)
    # M = prod_{l<=B} l^{e_l}, e_l = floor(ln p / ln l);  log2 M ~ ln p / ln 2 * ...
    # Standard: log2 M ~ (ln p) * B/(ln B)^2 ... use the classical estimate:
    # the walk costs sum_{l<=B} e_l ~ (ln p) * B / (ln B)^2  muls (dominant term
    # is the l near B).  We use the standard asymptotic instead:
    lnM = ln_p / (2 * s) * s          # = ln_p/2 -- placeholder, replaced below
    return s, u


def walk_len_lnp(ln_p, B):
    """log2(M) with M = prod_{l<=B} l^{e_l},  e_l = floor(ln p / ln l).

    ln M = sum_{l<=B} floor(ln p/ln l) * ln l = sum_{l<=B} (ln p - ln l
    frac) ~ sum_{l<=B} ln p - (the fractional parts).  The integral form:
        ln M = int_2^B (ln p/ln t) d(pi(t)).
    By parts, with pi(t) ~ t/ln t:
        ln M ~ (ln p/ln B) * pi(B) - int_2^B (ln p/ln^2 t) * d(t/ln t)
    The leading term is (ln p/ln B) * B/ln B = ln_p * B / ln(B)^2.
    So log2(M) = ln_p * B / (ln B)^2 / ln 2.   (Sanity: at B=2^139, ln B =
    96.5, B = e^96.5, ln_p=709.8 => ln M ~ 709.8*e^96.5/9317.)"""
    lnB = math.log(B)
    return ln_p * B / (lnB * lnB) / math.log(2)


def main():
    print("=" * 74)
    print(f"COST TABLE at N = 2^{N_BITS}   (p ~ 2^{N_BITS//2} balanced)")
    print("=" * 74)
    ln_p = LN_P
    # CORRECTION (brought in by the literature agent, and it matters):
    # Brent, "Some Integer Factorization Algorithms using Elliptic Curves",
    # arXiv:1004.3366, eq (5.5) gives alpha ~ sqrt(2 ln p / ln ln p), and Brent
    # states "Since m = p^{1/alpha}" where m IS THE SMOOTHNESS BOUND.  Hence
    #     B1_opt = exp(sqrt(ln p ln ln p / 2)) = L_p[1/2, 1/sqrt2],
    # NOT exp(sqrt(2 ln p ln ln p)).  The sqrt(2) belongs to the TOTAL
    # exp(sqrt(2 ln p ln ln p)) = L_p[1/2, sqrt2]; the two 1/sqrt2 factors are
    # the per-trial stage-1 cost and the success probability separately.
    # My first version had B1 = exp(sqrt(2 ln p ln ln p)), i.e. 2x too large.
    # The RATIO between mechanisms is unaffected (it is a constant), but the
    # absolute numbers were wrong by ln(cost) ~ 20.
    alpha = math.sqrt(2 * ln_p / math.log(ln_p))
    s = ln_p / alpha                      # = ln B1_opt
    B = math.exp(s)
    u = alpha                             # = ln p / ln B1
    print(f"  ln p              = {ln_p:.2f}")
    print(f"  alpha = ln p/ln B1 = {u:.4f}   (Brent eq 5.5: sqrt(2 ln p/ln ln p))")
    print(f"  optimal bound B1  = exp({s:.2f})  = 2^{s/math.log(2):.2f}"
          f"   = L_p[1/2, 1/sqrt2]")
    print(f"  (NOT exp(sqrt(2 ln p ln ln p)) = 2^{math.sqrt(2*ln_p*math.log(ln_p))/math.log(2):.1f},"
          f" which is the TOTAL, not B1)")
    lg = math.log(u)
    llg = math.log(lg)
    # Dickman asymptotic: rho(u) ~ exp(-u(ln u + ln ln u - 1))
    log_rho = -u * (lg + llg - 1)
    print(f"  ln rho(u)         = {log_rho:.3f}")
    # B = e^s is astronomically large, so work in log-log space:
    #   ln M ~ ln_p * B/(ln B)^2   =>   ln(ln M) = ln(ln_p) + s - 2 ln ln B
    lnM_log = math.log(ln_p) + s - 2 * math.log(s)
    log_M = lnM_log          # this is ln(M), i.e. ln(walk length)
    print(f"  ln(ln M)          = {lnM_log:.3f}   =>  ln M = e^{lnM_log:.1f}")
    print(f"  log2(M)           = {math.exp(lnM_log)/math.log(2):.3e}  (stage-1 walk, muls)")

    mults_ecm_xonly = 6          # measured/known: Montgomery x-only add ~ 6M
    mults_ecm_full = 16          # MEASURED in this round: 15-16M
    mults_torus = 4              # exactly 4M, by construction

    print()
    print(f"  {'mechanism':<34}{'mults/step':>11}{'ln(cost)':>14}")
    print("  " + "-" * 59)
    base = None
    for name, ms in [("ECM  (Montgomery x-only)", mults_ecm_xonly),
                     ("ECM  (full Jacobian coords)", mults_ecm_full),
                     ("TORUS (sqrt-free, f=(u,1))", mults_torus)]:
        ln_cost = log_M + math.log(ms) - log_rho
        if base is None:
            base = ln_cost
        print(f"  {name:<34}{ms:>11}{ln_cost:>14.2f}   "
              f"(ratio to ECM x-only: x{math.exp(ln_cost-base):.2f})")

    # TORUS on the good branch: suppose p+1 smooth at B1 -- i.e. rho is that of
    # p+1 rather than a random integer.  The gain is at most a constant factor
    # in rho, hence at most a constant additive shift in ln(cost).
    print()
    print("  TORUS on the 'good branch' (D chosen so (D/p)=-1, order | p+1):")
    print("    the gain is bounded by the ratio rho_{p+1}(u) / rho(u).")
    print("    Since ord | p+1 and p+1 ~ p, the Dickman parameter changes from")
    print("    u = ln p/ln B to u = ln(p+1)/ln B -- a relative change of")
    print(f"    ln(p+1)/ln p = 1 + {1.0/ln_p:.3e}.  NEGLIGIBLE.")
    print(f"    So the branch choice moves ln(cost) by < 1.  It is NOT an")
    print(f"    exponent improvement; it is noise.")

    print()
    print("=" * 74)
    print("DECIDING NUMBER")
    print("=" * 74)
    print("  cost to reach p for the ONE genuinely function-field mechanism")
    print("  (the norm-one torus, which has a sqrt-free p-free sampler):")
    print("      the group order mod the unknown p is p-1 or p+1;")
    print("      choosing D selects which;")
    print("      (D/p) is NOT computable from Z/nZ (only (D/n) = (D/p)(D/q) is,")
    print("      verified 200/200), so the selection is unavailable;")
    print("      reach_p = L[1/2] = the cost of factoring itself.")
    print()
    print(f"  ECM, for comparison:  reach_p = 0   (the x-only ladder never needs")
    print("  p, and M is built from B1 alone).")
    print()
    print("  VERDICT: the axis is DEAD.  The one bit that would exploit the")
    print("  function field is exactly the factorization bit.")


if __name__ == "__main__":
    main()