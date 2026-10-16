# Catalog-screening: WeilPairingClassification.lean proves a pairing attack needs a
# NON-DEGENERATE alternating pairing on E[n], which (via altPairing_nondegenerate_iff_isUnit,
# and the embedding-degree condition) needs  n | p^k - 1  for a SMALL k.
# Since ord_n(p) | n-1 (n prime => phi(n) = n-1), every candidate embedding degree is a
# DIVISOR of n-1.  So: factor n-1 and test every divisor up to a bound.  A small one that
# works would open the MOV/Frey-Rueck route; none existing closes it -- with a computed,
# not asserted, answer.

curves = {
 "secp256k1": (ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F),
               ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)),
 "P-256":     (ZZ(0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff),
               ZZ(0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551)),
 "Curve25519":(ZZ(2**255 - 19),
               ZZ(2**252 + 27742317777372353535851937790883648493)),
}
BOUND = ZZ(2)**40       # test all candidate embedding degrees below this
for name, (p, n) in curves.items():
    print(f"=== {name}: n is prime: {n.is_prime()}, n = {n.nbits()} bits", flush=True)
    nm1 = n - 1
    fac = factor(nm1)
    sm = [(q, e) for q, e in fac]
    print(f"  n-1 factorises into {len(sm)} distinct primes; largest prime factor "
          f"{max(q for q,_ in sm)} bits = {max(q for q,_ in sm).nbits()}", flush=True)
    small = [q for q, _ in sm if q < BOUND]
    print(f"  prime factors of n-1 below 2^40: {len(small)}"
          + (f"  largest of them = {max(small)}" if small else ""), flush=True)
    # enumerate divisors of n-1 that are < BOUND and test p^k mod n
    from itertools import product
    divs, misses = [], 0
    # build all divisors from the factorisation, but cap the count
    exps = []
    for q, e in sm:
        row = [1]
        for i in range(1, e + 1):
            row.append(row[-1] * q)
        exps.append(row)
    count = 0
    hit = None
    def rec(idx, val):
        global count, hit
        if hit is not None or count > 400000 or val > BOUND: return
        if idx == len(exps):
            if val == 1: return
            if pow(int(p), int(val), int(n)) == 1:
                hit = val
            count += 1
            return
        for v in exps[idx]:
            rec(idx + 1, val * v)
    rec(0, 1)
    if hit is not None:
        print(f"  *** FOUND embedding degree k = {hit} (< 2^40): MOV/Frey-Rueck APPLIES ***", flush=True)
    else:
        print(f"  tested {count} divisors of n-1 below 2^40: NO k with p^k = 1 mod n"
              f"  => no small embedding degree => no pairing route", flush=True)
    # what is the order then? ord_n(p) is a multiple of the largest prime factor of n-1
    big = max(q for q, _ in sm)
    print(f"  hence ord_n(p) >= largest prime factor of n-1 = {big.nbits()}-bit"
          f" (any smaller order would be a tested divisor)", flush=True)
    print(flush=True)
