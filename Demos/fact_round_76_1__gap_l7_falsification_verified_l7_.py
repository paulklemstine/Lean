"""Round-76 #1 evidence run for the GAP-L7' sign-flip law.

Monte-Carlo over genuine balanced semiprimes N = p*q with q/p drawn in [1, 1+delta],
measuring the two committed window policies (ascending / descending scan of the
balance window [sqrt(N)/sqrt(2), sqrt(N)]), the population tilt z, plus the wheel
calibration and the L7' cap audit.  Output: signflip_evidence_out.txt.
"""
import math
import random


def is_prime(n):
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def nextprime(n):
    n += 1
    while not is_prime(n):
        n += 1
    return n


def sim(delta, n=1500, seed=20260831, bits=24):
    rnd = random.Random(seed)
    asc = desc = tilt = 0.0
    root2 = math.sqrt(2)
    for _ in range(n):
        p = nextprime(rnd.randrange(2 ** (bits - 1), 2 ** bits))
        q = nextprime(int(p * (1 + rnd.random() * delta)))
        u = p / math.sqrt(p * q)
        asc += u - 1 / root2
        desc += 1 - u
        tilt += (u - 1 / root2) / (1 - 1 / root2)
    return asc / n, desc / n, tilt / n


def main():
    print("=== Monte-Carlo over genuine semiprimes (n=1500 per band, seed 20260831, 24-bit p) ===")
    for delta in [1.0, 0.9, 0.85, 0.81, 0.804, 0.8, 0.75, 0.5, 0.2]:
        a, d, z = sim(delta)
        print(f"delta={delta:<6} Easc={a:.5f} Edesc={d:.5f} desc/asc={d/a:.4f} "
              f"tilt={z:.4f} winner={'asc' if a < d else 'desc'}")
    print()
    print("=== analytic band law m(delta)=2/(1+sqrt(1+delta)) ===")
    for delta in [1.0, 0.804041, 0.5, 0.2]:
        m = 2 / (1 + math.sqrt(1 + delta))
        z = (m - 1 / math.sqrt(2)) / (1 - 1 / math.sqrt(2))
        print(f"delta={delta:<9} m={m:.6f} tilt z={z:.6f} "
              f"desc/asc={(1-m)/(m-1/math.sqrt(2)):.6f}")
    print()
    print("crossover width 80-56*sqrt2 =", 80 - 56 * math.sqrt(2))
    print("crossover mean (2+sqrt2)/4  =", (2 + math.sqrt(2)) / 4)
    print("reciprocal 4-2*sqrt2        =", 4 - 2 * math.sqrt(2))
    print("sqrt2-1 (hard-balance tilt) =", math.sqrt(2) - 1)
    print()
    print("=== wheel calibration ===")
    totient30 = sum(1 for k in range(1, 31) if math.gcd(k, 30) == 1)
    print("phi(30)/30 =", totient30 / 30, " 30/phi(30) =", 30 / totient30)
    for meas in (3.7331, 3.741, 3.7496):
        print(f"  measured {meas}: gap to 3.75 = {(3.75-meas)/3.75*100:.4f}%")
    print()
    print("=== cap audit (S <= (4/3)*min(1/mu,2^k)/Lambda) ===")
    cells = [(3.7331, 4/15, 32, 1), (3.741, 4/15, 32, 1), (3.7496, 4/15, 32, 1),
             (0.6366, 1, 32, 1), (0.6537, 1, 32, 1), (0.684, 1, 32, 1), (0.660, 1, 32, 1),
             (0.5682, 1, 32, 1), (1.0, 1, 32, 1), (0.9278, 1, 32, 1), (0.990, 1, 32, 1),
             (0.27, 1, 32, 1), (4.06, 4/15, 32, 0.7533)]
    violations = 0
    for S, mu, twok, lam in cells:
        cap = (4 / 3) * min(1 / mu, twok) / lam
        ok = S <= cap
        violations += 0 if ok else 1
        print(f"  S={S:<7} mu={mu:.4f} Lambda={lam:<7} cap={cap:.4f} "
              f"{'OK' if ok else 'VIOLATION'}")
    print("violations:", violations)
    print("mu=1 cap on hybrid cell:", (4 / 3) * min(1 / 1, 32) / 0.7533)


if __name__ == "__main__":
    main()
