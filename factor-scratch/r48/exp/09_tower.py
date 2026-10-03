"""09_tower.py -- can a TOWER make the order chooseable?  (H2's real form)

H2 says: adjoin elements to increase the number of points so we can TUNE the
group order to a smooth value.  The concrete version for a norm-one torus:
    T_D(F_p)   has order p - (D/p)
    T_D(F_{p^2}) has order (p^2 - 1)/(p - (D/p))   [norm-one torus, base change]
    and the tower T_D(F_p) subset T_D(F_{p^2}) ...
But F_{p^2} arithmetic is not available over Z/nZ without p.

PREDICTION (stated before measuring): a tower cannot help, because every level
of the tower has order Theta(p^k) for a k WE CANNOT KNOW without p, and the
smoothness of a number of size p^k at the ECM bound is governed by
u = ln(p^k)/ln B = k*u_1.  Multiplication of the order by an UNKNOWN k is
exactly what destroys the tuning.  A "controlled" k would need the tower degree
mod p.

MEASURED here: for k = 1, 2, 3, 4 the Dickman parameter u_k = k*u_1, hence the
success probability rho(u_k), and the cost.  The point is that if the tower
degree were controllable the cost would be *better* than k=1 -- and it is
driven by whether k is knowable.
"""
import math


def rho(u, N=20000):
    """Dickman rho (Buchstab integral)."""
    if u <= 1.0:
        return 1.0
    h = (u - 1.0) / N
    tot = 0.0
    for i in range(N + 1):
        t = 1.0 + i * h
        w = 1 if i in (0, N) else (4 if i % 2 else 2)
        v = 1.0 if t - 1.0 <= 1.0 else rho(t - 1.0, 3000)
        tot += w * v / t
    return max(1.0 - tot * h / 3.0, 1e-300)


def main():
    print("=" * 72)
    print("TOWERS: does raising the level make the order chooseable?")
    print("=" * 72)
    ln_p = 709.78          # p ~ 2^1024
    s = math.sqrt(2 * ln_p * math.log(ln_p))
    ln_B = s
    u1 = ln_p / ln_B
    print(f"\nECM level k=1:  u = ln p / ln B = {u1:.4f}")
    print(f"{'':>4}{'level k':>9}{'ln(order)':>14}{'u_k':>10}"
          f"{'ln rho(u_k)':>14}{'cost vs k=1':>14}")
    base = None
    for k in (1, 2, 3, 4, 6):
        uk = k * u1
        lg = math.log(uk)
        llg = math.log(lg) if lg > 0 else 0.0
        log_rho = -uk * (lg + llg - 1)
        # cost: the walk is over a group of order p^k; walk length scales with
        # the bound, and the Dickman penalty is rho(uk).  In the L[] accounting
        # the walk length is fixed by B, so the penalty is purely -ln rho.
        c = -log_rho
        if base is None:
            base = c
        print(f"{'':>4}{k:>9}{k*ln_p:>14.1f}{uk:>10.3f}{log_rho:>14.1f}"
              f"{c/base:>14.2f}x")

    print("\nREADING: raising the level multiplies the Dickman parameter by k,")
    print("so the success probability decays like rho(k*u) -- EXPONENTIALLY")
    print("worse, not better.  A tower is a LOSS, not a tuning knob.")

    print("\nWHY the level is not tunable:")
    print("  * the tower degree / Frobenius data mod p is a function of the")
    print("    UNKNOWN p;")
    print("  * F_{p^2} arithmetic has no model over Z/nZ without p;")
    print("  * so the level k that would make the order smooth is exactly the")
    print("    unknown, and we would have to try all k, paying rho(k*u) each.")
    print("  Summing over k up to K costs sum_k exp(-k*u(log(ku)+..)) which is")
    print("  dominated by k=1.  Trying levels is strictly worse than staying at 1.")

    print("\nVERDICT H2 (tower form): REFUTED.  The order of the reduction mod")
    print("  the unknown p is not a free parameter.  Choosing a curve, a")
    print("  discriminant, or a tower changes WHICH number of size p^g or p we")
    print("  get, but never makes it B-smooth on demand, because B-smoothness")
    print("  of a number of size Theta(p^k) is governed by u = k*ln p/ln B,")
    print("  and k is not knowable without p.")


if __name__ == "__main__":
    main()