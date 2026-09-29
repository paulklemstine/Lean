"""
Round 34 / UMW channel.  Test UMW Lemma 6.2 (arXiv:2511.10851, Sec. 6, p.20) as a
CONSTRUCTION for the prime sub-case of the (alpha,beta)=(1/3,1/3) Strong Divisor Conjecture.

Lemma 6.2 (verbatim intent): for U = prod_{p in [n]} p, a factorization U = U_1...U_l
and V_i = (U/U_i)*T_i with T_i = (U/U_i)^{-1} mod U_i, there are b,c with
    c*(sum_i i*V_i) + b = 0 (mod U)
iff the AP {b + i*c : 1<=i<=l} contains a multiple of every prime in [n].

Since V_i = 1 mod U_i,  W := sum_i i*V_i  satisfies  W = i (mod U_i), so with c=1
    b = (-W) mod U
makes  b + i = 0 (mod U_i) for every i.  So EVERY consistent factorization gives a
covering AP.  The ONLY question is whether some b is small enough (b <= exp(n^alpha)).

Counting prediction: b ranges over [0,U), reachable values ~ M = l^{pi(n)} (partitions).
Pigeonhole (alternate reachable values and targets) gives  min b <~ U*l^2/M = e^{n-2beta*n}.
At alpha=beta=1/3:  M = exp(2n/3),  U = exp(n),  min b ~ exp(n/3).  <-- the target.
"""
import random, sys, time
from sympy import primerange

def one_trial(primes, U, l, rng):
    # random partition of the primes into l NON-EMPTY blocks
    perm = list(primes); rng.shuffle(perm)
    cuts = sorted(rng.sample(range(1, len(perm)), l-1))
    blocks, prev = [], 0
    for c in cuts:
        blocks.append(perm[prev:c]); prev = c
    blocks.append(perm[prev:])
    W = 0
    for idx, blk in enumerate(blocks, start=1):
        Ui = 1
        for p in blk: Ui *= p
        M = U // Ui
        T = pow(M, -1, Ui) if Ui > 1 else 0
        W += idx * M * T
    return W % U

def run(n, samples, seed):
    rng = random.Random(seed)
    primes = list(primerange(1, n+1))
    U = 1
    for p in primes: U *= p
    l = max(2, round(n ** (2/3)))
    best = U
    t0 = time.time()
    for _ in range(samples):
        b = one_trial(primes, U, l, rng)
        if b > U - b:      # also try negating the AP
            b = U - b
        if b < best:
            best = b
    M = l ** len(primes)          # number of consistent factorizations
    L = U * l * (l+1) // 2        # range length of W
    # verification: does b actually cover every prime in [n]?
    covered = all(any((best + i) % p == 0 for i in range(1, l+1)) for p in primes)
    return dict(n=n, l=l, pi_n=len(primes), U_digits=len(str(U)),
                samples=samples, best_b_digits=len(str(best)), best_b=int(best),
                pigeonhole_digits=len(str(max(1, L // M))),
                target_exp_n_over_3_digits=len(str(int(2.718281828**0 + 0)) ) if False else None,
                covers_all_primes=covered, secs=round(time.time()-t0, 1))

if __name__ == "__main__":
    import math
    for n, S in [(30, 200000), (40, 200000), (50, 200000), (60, 200000), (80, 200000)]:
        r = run(n, S, 12345 + n)
        target = int(round(math.exp(n/3)))          # exp(n/3): the (alpha,beta)=(1/3,1/3) target
        r["target_exp_n_over_3_digits"] = len(str(target))
        r["best_b"] = r["best_b"]
        ok = r["best_b_digits"] <= r["target_exp_n_over_3_digits"]
        print(f"n={r['n']:3d} l={r['l']:3d} pi={r['pi_n']:2d} |U|={r['U_digits']:3d}d "
              f"min_b={r['best_b_digits']:3d}d  pigeonhole~{r['pigeonhole_digits']:3d}d  "
              f"target e^(n/3)={r['target_exp_n_over_3_digits']:3d}d  "
              f"{'HIT' if ok else 'miss'}  covers_all_primes={r['covers_all_primes']}  "
              f"({r['secs']}s)", flush=True)
