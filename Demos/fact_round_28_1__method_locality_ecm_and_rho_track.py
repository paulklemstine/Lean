"""
Method locality: numerical demonstrations.

Factoring methods split into two strata.  A method is *factor-local* when the number of
state updates it needs against a composite N = p*q is a function of the hunted prime p
alone.  This script demonstrates, by direct computation:

  1. The shadow theorem: reducing a mod-N polynomial orbit modulo p reproduces, term for
     term, the orbit computed modulo p.  Hence cofactor flatness, exactly.
  2. Factor boundedness: the collision time never exceeds p (pigeonhole), and the
     successor map x -> x+1 attains that bound (locality is not speed).
  3. Exact anchors: the orbit of x -> x^2 + 1 from x0 = 2 closes at step 49 modulo 1009
     and at step 70 modulo 4093, both inside the birthday window 2*sqrt(p).
  4. Trial division: cost exactly minFac(N) - 1; factor bounded but NOT cofactor flat
     (cost 2 at 4093*3 versus 4092 at 4093*4093).
  5. Rigidity: a modulus-determined, cofactor-flat cost model is constant on composites.
  6. The elliptic curve stage-1 ledger: the mod-p success rate gcd(m, k(B))/m is exactly
     cofactor-free; the expected curve count is antitone in B and equals 1 past the
     Hasse window.
  7. Exact two-prime outcome counts; the reveal count vanishes exactly when the bound
     covers BOTH group orders (the real wall sits at max(p, q)); individual channels
     redistribute; a non-injective ledger manufactures a wall at the smaller prime.

Pure standard library; no dependencies.
"""

from __future__ import annotations

from math import exp, gcd, isqrt
from typing import Callable, Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------------
# 1. Collision time: the cost model
# ----------------------------------------------------------------------------------


def collision_time(step: Callable[[int], int], x0: int, modulus: int) -> int:
    """First index n such that state n equals a strictly earlier state.

    The state space has `modulus` elements, so by pigeonhole the answer is at most
    `modulus`.
    """
    seen: Dict[int, int] = {}
    x = x0 % modulus
    n = 0
    while x not in seen:
        seen[x] = n
        x = step(x) % modulus
        n += 1
    return n


def rho_step(c: int) -> Callable[[int], int]:
    """One Pollard-rho update x -> x^2 + c, valid in any commutative ring."""
    return lambda x: x * x + c


def shadow_orbit(f: Callable[[int], int], x0: int, N: int, p: int, length: int) -> List[int]:
    """The mod-p shadow of the orbit computed modulo N."""
    out: List[int] = []
    x = x0 % N
    for _ in range(length):
        out.append(x % p)
        x = f(x) % N
    return out


def intrinsic_orbit(f: Callable[[int], int], x0: int, p: int, length: int) -> List[int]:
    """The orbit computed entirely modulo p."""
    out: List[int] = []
    x = x0 % p
    for _ in range(length):
        out.append(x)
        x = f(x) % p
    return out


def shadow_collision_time(f: Callable[[int], int], x0: int, N: int, p: int) -> int:
    """Cost of a run modulo N while hunting p: collision time of the mod-p shadow."""
    seen: Dict[int, int] = {}
    x = x0 % N
    n = 0
    while (x % p) not in seen:
        seen[x % p] = n
        x = f(x) % N
        n += 1
    return n


# ----------------------------------------------------------------------------------
# 2. Trial division
# ----------------------------------------------------------------------------------


def min_fac(n: int) -> int:
    """Least prime factor of n >= 2."""
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n


def trial_steps(n: int) -> int:
    """Cost of ascending trial division: one failed test per candidate below minFac."""
    return min_fac(n) - 1


# ----------------------------------------------------------------------------------
# 3. Elliptic curve stage-1 ledger
# ----------------------------------------------------------------------------------


def stage1_scalar(B: int) -> int:
    """k(B) = lcm(1, 2, ..., B)."""
    k = 1
    for i in range(1, B + 1):
        k = k * i // gcd(k, i)
    return k


def firing_count(m: int, k: int) -> int:
    """Number of residues a < m with m | k*a.  Equals gcd(m, k)."""
    return gcd(m, k)


def firing_count_bruteforce(m: int, k: int) -> int:
    return sum(1 for a in range(m) if (k * a) % m == 0)


def hasse_ceil(p: int) -> int:
    """Integer ceiling of the Hasse window: p + 3 + 2*floor(sqrt(p))."""
    return p + 3 + 2 * isqrt(p)


def expected_curves(m: int, B: int) -> int:
    """Expected number of curves: reciprocal of the stage-1 firing rate."""
    return m // gcd(m, stage1_scalar(B))


def blocks(m_p: int, m_q: int, k: int) -> Tuple[int, int, int, int]:
    """(dead, found_p, found_q, nothing) counts of a two-prime stage-1 run."""
    fp, fq = gcd(m_p, k), gcd(m_q, k)
    return (fp * fq, fp * (m_q - fq), (m_p - fp) * fq, (m_p - fp) * (m_q - fq))


def reveal_count(m_p: int, m_q: int, k: int) -> int:
    dead, found_p, found_q, nothing = blocks(m_p, m_q, k)
    del dead, nothing
    return found_p + found_q


def blocks_bruteforce(m_p: int, m_q: int, k: int) -> Tuple[int, int, int, int]:
    dead = found_p = found_q = nothing = 0
    for a in range(m_p):
        for b in range(m_q):
            fp = (k * a) % m_p == 0
            fq = (k * b) % m_q == 0
            if fp and fq:
                dead += 1
            elif fp:
                found_p += 1
            elif fq:
                found_q += 1
            else:
                nothing += 1
    return dead, found_p, found_q, nothing


# ----------------------------------------------------------------------------------
# 4. Birthday bound
# ----------------------------------------------------------------------------------


def birthday_product(p: int, k: int) -> float:
    """Probability that k uniform draws from Z/p are pairwise distinct."""
    prob = 1.0
    for i in range(k):
        prob *= 1.0 - i / p
    return prob


def birthday_bound(p: int, k: int) -> float:
    """exp(-k(k-1)/(2p)), an upper bound for the product above."""
    return exp(-k * (k - 1) / (2.0 * p))


# ----------------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------------


def demo_shadow_theorem() -> None:
    print("=" * 78)
    print("1. THE SHADOW THEOREM: reduction of a mod-N run IS the mod-p run")
    print("=" * 78)
    p = 4093
    f = rho_step(1)
    for q in (3, 7919, 1_000_003, 2**23 + 15):
        N = p * q
        s = shadow_orbit(f, 2, N, p, 40)
        t = intrinsic_orbit(f, 2, p, 40)
        print(f"  q = {q:>12}   shadow == intrinsic orbit: {s == t}   first states {s[:5]}")
    print()


def demo_cofactor_flatness() -> None:
    print("=" * 78)
    print("2. COFACTOR FLATNESS: same prime, nine cofactors, identical cost")
    print("=" * 78)
    p = 4093
    f = rho_step(1)
    costs: List[int] = []
    print(f"  {'cofactor q':>14} {'N = p*q':>26} {'rho cost':>10} {'trial-div cost':>16}")
    for e in range(14, 23):
        q = next_prime(2**e)
        N = p * q
        c = shadow_collision_time(f, 2, N, p)
        costs.append(c)
        print(f"  {q:>14} {N:>26} {c:>10} {trial_steps(N):>16}")
    print(f"\n  rho:  max/min median spread over 2^23 of cofactor growth = "
          f"{max(costs) / min(costs):.2f}  (theory: exactly 1.00)")
    print(f"  rho cost <= p ?  {max(costs)} <= {p}: {max(costs) <= p}")
    print()


def next_prime(n: int) -> int:
    def is_prime(x: int) -> bool:
        if x < 2:
            return False
        if x % 2 == 0:
            return x == 2
        d = 3
        while d * d <= x:
            if x % d == 0:
                return False
            d += 2
        return True

    while not is_prime(n):
        n += 1
    return n


def demo_anchors() -> None:
    print("=" * 78)
    print("3. EXACT ANCHORS for x -> x^2 + 1 from x0 = 2")
    print("=" * 78)
    f = rho_step(1)
    for p in (3, 1009, 4093):
        t = collision_time(f, 2, p)
        print(f"  p = {p:>6}   collision time = {t:>5}   sqrt(p) = {isqrt(p):>4}   "
              f"window 2*sqrt(p) = {2 * isqrt(p):>4}   inside: {t <= 2 * isqrt(p)}")
    print("\n  Locality is not speed: the successor map x -> x+1 attains the pigeonhole bound.")
    for p in (3, 1009, 4093):
        t = collision_time(lambda x: x + 1, 2, p)
        print(f"  p = {p:>6}   successor-map collision time = {t:>5} (= p: {t == p})")
    print()


def demo_trial_division() -> None:
    print("=" * 78)
    print("4. TRIAL DIVISION: factor bounded, but NOT cofactor flat")
    print("=" * 78)
    p = 4093
    print(f"  hunted prime held fixed at p = {p}")
    for q in (3, 7, 4093):
        N = p * q
        print(f"    q = {q:>6}:  N = {N:>10}   minFac(N) = {min_fac(N):>6}   "
              f"cost = {trial_steps(N):>6}")
    print(f"\n  spread purely from the cofactor: "
          f"{trial_steps(p * 4093) / trial_steps(p * 3):.0f}x")
    print("\n  On the least-factor stratum the cost is exactly p - 1 (the definition face):")
    for pr in (101, 1009, 4093):
        N = pr * next_prime(pr + 1)
        print(f"    p = {pr:>6}:  cost = {trial_steps(N):>6}  = p - 1: {trial_steps(N) == pr - 1}")
    print("\n  Certified cross-method separation (same hunted prime, least-factor stratum):")
    f = rho_step(1)
    for pr in (1009, 4093):
        t = collision_time(f, 2, pr)
        td = trial_steps(pr * pr)
        print(f"    p = {pr:>6}:  rho {t:>4} steps vs trial division {td:>6}  "
              f"-> {td // t}x cheaper")
    print()


def demo_rigidity() -> None:
    print("=" * 78)
    print("5. RIGIDITY: modulus-determined + cofactor flat  =>  constant on composites")
    print("=" * 78)
    print("  cost(a*b) = cost(a*(c*d)) = cost((c*d)*a) = cost((c*d)*1) = cost(c*d)")
    print("  Every step uses flatness once and re-labels the hunted factor, which a")
    print("  modulus-determined ledger permits.  Hence trial division, being")
    print("  modulus-determined and non-constant, CANNOT be cofactor flat.")
    print()
    print("  rho's ledger, by contrast, is NOT modulus-determined - it reads the factor:")
    f = rho_step(1)
    print(f"    cost at p = 3    : {collision_time(f, 2, 3)}")
    print(f"    cost at p = 4093 : {collision_time(f, 2, 4093)}")
    print("  which is exactly the freedom rigidity shows a nontrivial flat model must have.")
    print()


def demo_birthday() -> None:
    print("=" * 78)
    print("6. THE BIRTHDAY WINDOW at p = 4093")
    print("=" * 78)
    p = 4093
    print(f"  {'k':>5} {'P[all distinct]':>18} {'exp(-k(k-1)/2p)':>18}")
    for k in (20, 40, 64, 76, 100, 128):
        print(f"  {k:>5} {birthday_product(p, k):>18.6f} {birthday_bound(p, k):>18.6f}")
    k = 76
    print(f"\n  at k = {k}: product = {birthday_product(p, k):.4f} <= 1/2, and the bound "
          f"{birthday_bound(p, k):.4f} <= 1/2 certifies it")
    print(f"  measured collision time = {collision_time(rho_step(1), 2, p)}")
    print()


def demo_ecm_ledger() -> None:
    print("=" * 78)
    print("7. THE ECM STAGE-1 LEDGER IS COFACTOR-FREE")
    print("=" * 78)
    m, k = 60, stage1_scalar(3)
    print(f"  mod-p group order m = {m}, smoothness bound B = 3, k(B) = {k}")
    print(f"  {'cofactor order m2':>18} {'joint firing states':>22} {'success rate':>16}")
    for m2 in (7, 13, 101, 4099):
        joint = firing_count(m, k) * m2
        print(f"  {m2:>18} {joint:>22} {joint / (m * m2):>16.6f}")
    print(f"  theory: gcd(m, k)/m = {gcd(m, k)}/{m} = {gcd(m, k) / m:.6f}  (m2 cancels)")

    print("\n  expected curve count m/gcd(m, k(B)) is antitone in B:")
    print(f"  {'B':>4} {'k(B)':>14} {'gcd(m,k)':>10} {'curves':>8}")
    for B in (1, 2, 3, 4, 5, 6, 10, 20, 60):
        print(f"  {B:>4} {stage1_scalar(B):>14} {gcd(m, stage1_scalar(B)):>10} "
              f"{expected_curves(m, B):>8}")
    p = 53
    print(f"\n  past the Hasse window of p = {p} (ceiling {hasse_ceil(p)}) one curve suffices:")
    for m_ in (48, 53, 60):
        B = hasse_ceil(p)
        print(f"    group order m = {m_:>3}, B = {B}:  curves = {expected_curves(m_, B)}")
    print()


def demo_two_prime_counts() -> None:
    print("=" * 78)
    print("8. EXACT TWO-PRIME OUTCOME COUNTS, AND WHERE THE WALL REALLY IS")
    print("=" * 78)
    m_p, m_q = 12, 10
    print(f"  group orders m_p = {m_p}, m_q = {m_q}; closed form vs brute force:")
    print(f"  {'B':>3} {'k(B)':>8} {'dead':>7} {'found_p':>9} {'found_q':>9} {'nothing':>9}"
          f" {'sum':>7} {'reveal':>8} {'matches':>9}")
    for B in range(1, 13):
        k = stage1_scalar(B)
        cf = blocks(m_p, m_q, k)
        bf = blocks_bruteforce(m_p, m_q, k)
        print(f"  {B:>3} {k:>8} {cf[0]:>7} {cf[1]:>9} {cf[2]:>9} {cf[3]:>9} {sum(cf):>7}"
              f" {reveal_count(m_p, m_q, k):>8} {str(cf == bf):>9}")
    print(f"  every row sums to m_p*m_q = {m_p * m_q}")

    print("\n  the real wall: the reveal count first vanishes only once B covers BOTH orders")
    for (a, b) in ((2, 2), (4, 6), (12, 10), (7, 11)):
        first_zero = next(B for B in range(1, max(a, b) + 1)
                          if reveal_count(a, b, stage1_scalar(B)) == 0)
        k0 = stage1_scalar(first_zero)
        both = (k0 % a == 0) and (k0 % b == 0)
        print(f"    orders ({a},{b}):  min = {min(a,b):>3}, max = {max(a,b):>3};  "
              f"first B with reveal = 0 is {first_zero:>3};  "
              f"k(B) annihilates BOTH groups: {both}")
    print("    (reveal = 0 exactly when k(B) is a multiple of both orders; B >= max(m_p,m_q)")
    print("     always suffices, and no bound below min(m_p,m_q) can ever do it)")

    print("\n  minimal witness (orders 2 and 2):")
    print(f"    B = 1 (k = 1): reveal = {reveal_count(2, 2, stage1_scalar(1))}")
    print(f"    B = 2 (k = 2): reveal = {reveal_count(2, 2, stage1_scalar(2))}")

    print("\n  channels redistribute: found_p alone is NOT monotone (orders 4 and 6)")
    for B in (2, 3):
        d, fp_, fq_, no = blocks(4, 6, stage1_scalar(B))
        print(f"    B = {B} (k = {stage1_scalar(B)}): dead {d:>3}  found_p {fp_:>3}  "
              f"found_q {fq_:>3}  nothing {no:>3}")
    print("    the eight found_p trials moved into the dead block - nothing failed.")
    print()


def demo_ledger_faithfulness() -> None:
    print("=" * 78)
    print("9. LEDGER FAITHFULNESS: how a conflation manufactures a wall")
    print("=" * 78)
    patterns: Sequence[Tuple[bool, bool]] = [(True, True), (True, False),
                                             (False, True), (False, False)]

    def canonical(fp: bool, fq: bool) -> str:
        if fp:
            return "dead" if fq else "found_p"
        return "found_q" if fq else "nothing"

    def wall(fp: bool, fq: bool) -> str:
        if fp:
            return "dead"
        return "found_q" if fq else "nothing"

    print(f"  {'p fires':>9} {'q fires':>9} {'canonical ledger':>19} {'wall ledger':>14}")
    for fp, fq in patterns:
        print(f"  {str(fp):>9} {str(fq):>9} {canonical(fp, fq):>19} {wall(fp, fq):>14}")

    can_img = [canonical(a, b) for a, b in patterns]
    wall_img = [wall(a, b) for a, b in patterns]
    print(f"\n  canonical ledger injective (faithful): {len(set(can_img)) == len(patterns)}")
    print(f"  wall ledger injective:                 {len(set(wall_img)) == len(patterns)}")
    print("  the conflated pair is (p fires, q inert) with (p fires, q fires):")
    print(f"    truth   = {canonical(True, False)}   (a factor IS revealed)")
    print(f"    recorded = {wall(True, False)}      (the wall sentence)")
    print()


def main() -> None:
    demo_shadow_theorem()
    demo_cofactor_flatness()
    demo_anchors()
    demo_trial_division()
    demo_rigidity()
    demo_birthday()
    demo_ecm_ledger()
    demo_two_prime_counts()
    demo_ledger_faithfulness()
    print("=" * 78)
    print("SUMMARY: rho and the elliptic curve method track the factor; trial division")
    print("tracks the modulus - and rigidity says it has no choice.")
    print("=" * 78)


if __name__ == "__main__":
    main()
