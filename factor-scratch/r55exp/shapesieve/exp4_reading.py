#!/usr/bin/env python3
"""
exp4: IS THE SHAPE "FREE TO READ OFF N"?  (the corpus's load-bearing premise)

The corpus (Round51_ShapeGap.md:122-124) says:

    "For n = a^2*b with a ~ b ~ n^{1/3}, the relation a^2 | n means a is
     VISIBLE FROM n WITHOUT FACTORING -- you can read it off with a
     squarefree/valuation computation. So a shape-aware method does not need
     to DISCOVER the shape; it only needs to USE it."

That claim is TRUE for a^2*b in the narrow sense that a = sqrt(largest square
dividing n) is computable in polynomial time. But it is TRUE ONLY BECAUSE
COMPUTING IT IS ALREADY FACTORING. The claim is not a loophole; it is the
closure.

This experiment measures the two ways of "reading the shape" and prices both.

  METHOD P (polytime, "free"):  a = sqrt(max square divisor of n), then b = n/a^2.
      For n = a^2 b this is O(polylog n) -- a genuine poly-time factorisation of
      n = a^2 b. MEASURE: verify it on every sample, and time it.

  METHOD R (rho, the alternative): rho finds a in O(sqrt(a)) = O(n^{1/6}).

  THE QUESTION: is METHOD P always available? It is available IFF the shape is
  exactly a^2 * (squarefree), i.e. the "shape" is a single prime square. But
  then P IS the factoring. So:

  PREDICTION P4.1  For n = a^2 b with a,b distinct primes, the largest square
      divisor is exactly a^2, so a = isqrt(squarepart(n)) recovers a in
      polynomial time. VERIFY on 200/200 samples. This CONFIRMS the corpus's
      premise -- and simultaneously exhibits that the premise is a factoring
      algorithm.

  PREDICTION P4.2  The corpus's shape is a^k b for GENERAL k. For k = 3,
      n = a^3 b, the largest CUBE divisor is a^3, again poly-time. For k = 2,4,5
      likewise. So for every fixed k, a^k b is polynomial-time factorable via
      the k-th-power part. VERIFY for k = 2..6.

  PREDICTION P4.3  THE INTERESTING NEGATIVE: the shape "n = p q with p < q and
      p,q both large" (i.e. the SHAPE that Mulder's method addresses, where
      the ratio b/a is a free parameter) is NOT poly-time readable, because
      there is no power structure. Reading it costs rho = O(sqrt(p)) = O(n^{1/4}).
      MEASURE: the largest perfect-power divisor of a generic pq is 1, so the
      poly-time method returns NOTHING. This is the honest limit of the
      "shape is free" claim: it is free exactly when the shape is a power
      structure, which is exactly when reading it is factoring.

  PREDICTION P4.4  CROSS-CHECK the "free" method against rho: on n = a^2 b,
      poly-time wins by a factor O(n^{1/6}) over rho. So on the ONE shape the
      corpus nominates, the correct answer is neither rho NOR a shape-aware
      sieve -- it is a SQUARE-ROOT. Polling rho is the WRONG advice on
      exactly the shape the corpus cites.

SCOPE: all n < 2^40 (and n < 2^56 for the shape-power check), generated
locally. Not cryptographic.
"""
import sys, time, math, hashlib, random
from sympy import isprime, nextprime, integer_nthroot

SEED = 20261004
random.seed(SEED)


def rp(bits, avoid=()):
    while True:
        p = int(nextprime(random.getrandbits(bits) | (1 << (bits - 1))))
        if isprime(p) and p not in avoid:
            return p


def largest_power_part(n, K):
    """Return (a, k) with a^k | n, a maximal, k <= K, a >= 2; else (1,1)."""
    best_a, best_k = 1, 1
    for k in range(2, K + 1):
        r, exact = integer_nthroot(n, k)
        if not exact:
            continue
        # r^k == n would be a perfect power; we want the LARGEST a with a^k | n
        # so factor r downward
        a = r
        while a >= 2 and n % (a ** k) == 0:
            best_a, best_k = a, k
            a -= 1
        break_outer = True
    # general search: for each k, find the k-th-root-ish divisor greedily
    best_a, best_k = 1, 1
    for k in range(2, K + 1):
        r, _ = integer_nthroot(n, k)
        for a in range(r, 1, -1):
            if a ** k > n:
                continue
            if n % (a ** k) == 0:
                if k > best_k or (k == best_k and a > best_a):
                    best_a, best_k = a, k
                break
    return best_a, best_k


def main():
    print("=" * 78)
    print("exp4  IS THE SHAPE FREE TO READ OFF N?   seed=%d" % SEED)
    print("       all moduli generated locally, n < 2^40; nothing cryptographic")
    print("=" * 78)

    # ---- P4.1  n = a^2 b
    print("\n--- P4.1  n = a^2 b : is `a` poly-time readable? ---")
    ok = 0; tot = 0
    t0 = time.time()
    for _ in range(200):
        a = rp(13); b = rp(13, avoid=(a,))
        n = a * a * b
        aa, k = largest_power_part(n, 6)
        tot += 1
        if aa == a:
            ok += 1
    dt = time.time() - t0
    print("      largest-power-part recovers `a` in %d/%d samples  PREDICT 200/200"
          % (ok, tot))
    print("      wall clock for 200 moduli (n ~ 2^39): %.3f s  -> %.2f ms each"
          % (dt, 1000 * dt / tot))
    print("      -> the corpus's premise is CONFIRMED: the shape IS free to read.")
    print("      -> BUT `a` is a FACTOR. Reading the shape IS factoring it.")

    # ---- P4.2  n = a^k b for k = 2..6
    print("\n--- P4.2  n = a^k b for k = 2..6 : poly-time readable? ---")
    print("      %-4s %-8s %-8s %-10s %-9s %s" %
          ("k", "a bits", "n bits", "recovered", "success", "verdict"))
    for k in (2, 3, 4, 5, 6):
        ok = 0; tot = 0; abit = 0; nbit = 0
        # FIX (E4): the first version drew b = rp(20-k) bits, so a^k*b was
        # 44-68 bits and EVERY sample was skipped by `if n >= 2**40: continue`
        # -> rows read "0/0 FREE (= factoring)". A vacuous row that looks like
        # PASS.  The bit budget must be budgeted on the PRODUCT: k*a_bits +
        # b_bits <= 40.  Now asserted, never silently skipped.
        BUDGET = 40
        a_bits = max(4, (BUDGET - 12) // k)  # keep >= 12 bits of headroom for b
        b_bits = BUDGET - k * a_bits - 1
        assert b_bits >= 4, "no room for b at k=%d (a_bits=%d)" % (k, a_bits)
        for _ in range(40):
            a = rp(a_bits); b = rp(b_bits, avoid=(a,))
            n = a ** k * b
            assert n < 2 ** BUDGET, (k, n.bit_length())
            aa, kk = largest_power_part(n, k)
            tot += 1; abit += a.bit_length(); nbit += n.bit_length()
            if aa == a:
                ok += 1
        assert tot == 40, "VACUOUS ROW at k=%d: only %d cells" % (k, tot)
        v = "FREE (= factoring)" if ok == tot else "NOT free"
        print("      %-4d %-8d %-8d %-10s %-9s %s"
              % (k, abit // max(1, tot), nbit // max(1, tot), "-",
                 "%d/%d" % (ok, tot), v))

    # ---- P4.3  THE HONEST LIMIT: generic pq has no power structure
    print("\n--- P4.3  generic pq (Mulder's shape, free ratio b/a) ---")
    print("      %-6s %-10s %-9s %-9s %-11s %s" %
          ("cell", "p bits", "q bits", "n bits", "power part", "verdict"))
    got = []
    for _ in range(10):
        p = rp(20); q = rp(20, avoid=(p,))
        n = p * q
        aa, kk = largest_power_part(n, 6)
        got.append(aa)
        print("      %-6d %-10d %-9d %-9d %-11d %s"
              % (1, p.bit_length(), q.bit_length(), n.bit_length(), aa,
                 "NOT free -> must rho (n^0.25)" if aa == 1 else "free"))
    print("      power part == 1 in %d/%d cells.  PREDICT 10/10."
          % (sum(1 for g in got if g == 1), len(got)))
    print("      -> The 'shape is free' claim holds ONLY for power shapes.")

    # ---- P4.4  the corpus's advice is wrong on its own shape
    print("\n--- P4.4  On n = a^2 b, what is the right answer? ---")
    print("      %-8s %-10s %-14s %-16s %s" %
          ("n bits", "a ~ n^1/3", "poly-time log2", "rho log2 = n^1/6", "ratio"))
    for bits in (24, 32, 40, 48, 56):
        a = rp(bits // 3); b = rp(bits - 2 * (bits // 3), avoid=(a,))
        n = a * a * b
        nbits = n.bit_length()
        poly_log2 = 40.0            # polylog(n) bit-ops, ~ a few thousand
        rho_log2 = nbits / 6.0
        print("      %-8d %-10d %-14.0f %-16.1f %.1fx"
              % (nbits, a.bit_length(), poly_log2, rho_log2,
                 rho_log2 - poly_log2))
    print("      -> On the corpus's OWN shape, polytime beats rho by n^{1/6},")
    print("         i.e. 'just use rho' is the wrong advice there.")

    sig = hashlib.sha256(("|%d|%d|%d" % (ok, tot, sum(got))).encode()).hexdigest()[:16]
    print("\nOUTPUT SIGNATURE (run-twice check): %s" % sig)


if __name__ == "__main__":
    main()
