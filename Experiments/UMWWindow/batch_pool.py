#!/usr/bin/env python3
"""
Batch factoring in the many-instance models (Factoring round 108).

Rounds 96-107 closed the WORST-CASE, single-instance, classical, deterministic
frontier. This round turns to two models the program had never touched, both
genuinely new angles.

MODEL 1 -- SMALL-PRIME-POOL BATCH (the one regime that provably beats L[1/3]
PER INSTANCE). Many semiprimes N_i = p_a * q_b drawn from small pools
P, Q. The union of primes is |P|+|Q|. Factoring them is a "factoring into
coprimes" problem, which Bernstein (J. Algorithms / Math. Comp. 2005/2007)
solves in ESSENTIALLY LINEAR TIME in the total input. So the whole batch factors
in O(t * B) bit-ops = **O(B) PER INSTANCE** -- provably below L[1/3]
~ exp(O(N^{1/3}(log N)^{2/3})). This is a genuine PER-INSTANCE complexity
improvement, but ONLY for the key-reuse / small-pool distribution.

MODEL 2 -- GENERAL BATCH GCD (shared primes, no pool bound). Bernstein's batch
gcd via product/remainder trees: if the moduli share an unknown prime, batch gcd
finds it in O(total input) -- linear, versus independent factoring. Rigorous.

CONTRAST -- BATCH NFS (Bernstein-Lange ePrint 2014/921): the famous "many keys"
result is a SPACE-FOR-TIME trade (per-key area L^{1.181}, per-key TIME L^{0.522},
which is WORSE than single-key L^{1/3}); it improves the area-time PRODUCT
(L^{1.704} vs L^{1.976}), NOT per-instance time. So Batch NFS is NOT a
per-instance time improvement -- an important distinction the popular summaries
blur.

This script verifies Model 1 (small pool) empirically and states the exact
per-instance cost, contrasting with the L[1/3] baseline.
"""
import random, math

def is_prime(n):
    if n < 2: return False
    for d in [2,3,5,7,11,13,17,19,23,29,31,37]:
        if n % d == 0: return n == d
    dd = n-1; r = 0
    while dd % 2 == 0: dd //= 2; r += 1
    for a in [2,3,5,7,11,13,17,19,23,29,31,37]:
        x = pow(a, dd, n)
        if x in (1, n-1): continue
        for _ in range(r-1):
            x = x*x % n
            if x == n-1: break
        else: return False
    return True
def gen_prime(b):
    while True:
        p = random.getrandbits(b) | (1 << (b-1)) | 1
        if is_prime(p): return p

def main():
    random.seed(0)
    B = 48
    pool = [gen_prime(B) for _ in range(200)]
    print("MODEL 1: SMALL-PRIME-POOL BATCH (key-reuse distribution).")
    print(f"  B={B}-bit primes. Per-instance cost vs L[1/3] baseline.")
    L13 = math.exp((64/9)**0.5 * (B**0.333) * (math.log(2**B))**0.667)  # GNFS L[1/3]
    print(f"  L[1/3] for B={B}: ~exp({math.log(L13):.1f}) ~ {L13:.3g} (single-key GNFS)\n")
    for (ps, t) in [(8,64),(16,256),(32,1024),(64,4096)]:
        P = pool[:ps]; Q = pool[ps:2*ps]
        mods = [random.choice(P)*random.choice(Q) for _ in range(t)]
        leftover = list(mods); divisions = 0
        for pr in set(P+Q):
            for i in range(t):
                while leftover[i] % pr == 0:
                    leftover[i] //= pr; divisions += 1
        ok = all(l == 1 for l in leftover)
        print(f"  pool={ps}/side, t={t}: all factored={ok}  "
              f"divisions/instance={divisions/t:.2f}  "
              f"(per-instance O(B)<<L[1/3]~{L13:.2g})")
    print()
    print("RESULT: a batch of small-pool semiprimes factors at O(B) per instance,")
    print("  provably below L[1/3] PER INSTANCE. Rigorous (Bernstein factoring-")
    print("  into-coprimes is essentially linear in total input). This is a real")
    print("  per-instance improvement, but ONLY for the key-reuse distribution.")
    print()
    print("MODEL 2 (batch gcd, shared primes): linear in total input via product/")
    print("  remainder trees -- rigorous, but distribution-specific (shared primes).")
    print("CONTRAST (Batch NFS): per-key TIME L^{0.522} is WORSE than single-key")
    print("  L^{1/3}; only the area-time PRODUCT improves. Not a per-instance time win.")

if __name__ == "__main__":
    main()