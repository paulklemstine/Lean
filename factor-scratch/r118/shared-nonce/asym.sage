# THE ASYMMETRIC ALLOCATION: one signature per key is enough for most of them.
#
# The counting bound is  sum_i t_i >= D + 1 + L  for the shared structure (D signals,
# 1 shared offset, L keys).  With L = 10 and D = 1 that is 12 signatures TOTAL -- so
# 8 keys can be broken from a single signature each.
#
# Prediction: allocate 2 signatures to D+1 = 2 keys and 1 signature to the remaining L-2,
# for a total of exactly L+2, and ALL L keys fall -- L-2 of them from ONE signature each.

import time

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def trial(L, alloc, D=1, seed=11):
    """alloc: dict key index -> number of signatures from that key."""
    set_random_seed(seed)
    ds = [ZZ(randint(1, NK - 1)) for _ in range(L)]
    Qs = [d * G for d in ds]
    coeffs = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
    delta = ZZ(randint(1, NK - 1))
    slots, rows, rhs = [], [], []
    sig_count = sum(alloc.values())
    for s in range(sig_count):
        signals = [ZZ(ZZ(1000003 + 97 * s) ^ (j + 1)) for j in range(D)]
        k = None
        for kk in range(L):
            if len([x for x in slots if x == kk]) < alloc[kk] and kk not in slots[:len(slots)]:
                pass
        slots.append(signals)
    # assign slots to keys respecting the allocation
    assign = {}
    idx = 0
    for k in range(L):
        for _ in range(alloc[k]):
            assign[idx] = k
            idx += 1
    assert idx == sig_count
    # rebuild the signal list for each slot
    signals = [[ZZ(ZZ(1000003 + 97 * s) ^ (j + 1)) for j in range(D)] for s in range(sig_count)]
    nonces = [(sum(coeffs[j] * signals[s][j] for j in range(D)) + delta) % NK
              for s in range(sig_count)]
    for s in range(sig_count):
        k = assign[s]
        ki = nonces[s]
        zi = ZZ(randint(0, NK - 1)); ri = ZZ(randint(1, NK - 1))
        si = (zi + ri * ds[k]) * inverse_mod(ki, NK) % NK
        row = [si * g for g in signals[s]] + [si % NK] + [ZZ(0)] * L
        row[D + 1 + k] = (-ri) % NK
        rows.append(row); rhs.append(zi)
    nunk = D + 1 + L
    A = matrix(Zmod(NK), rows); b = vector(Zmod(NK), rhs)
    if A.rank() < nunk:
        return None, A.rank(), nunk
    sol = A.solve_right(b)
    got_d = [ZZ(sol[D + 1 + k]) % NK for k in range(L)]
    ok = sum(1 for k in range(L) if (got_d[k] * G) == Qs[k])
    singles = sum(1 for k in range(L) if alloc[k] == 1 and (got_d[k] * G) == Qs[k])
    nsingle = sum(1 for k in range(L) if alloc[k] == 1)
    return ok, singles, nsingle

print("ASYMMETRIC allocation for L keys, D=1: total signatures = L+2 exactly", flush=True)
print(f"{'L':>4} {'total sig':>10} {'bound':>6} | {'keys broken':>12} {'from 1 sig':>18}", flush=True)
for L in [3, 5, 8, 10, 20]:
    need = 1 + 1 + L                       # D+1+L
    alloc = {}
    # D+1 = 2 keys get 2 signatures; the rest get 1  -> total = 2*2 + (L-2)*1 = L+2
    for k in range(L):
        alloc[k] = 2 if k < 2 else 1
    total = sum(alloc.values())
    r = trial(L, alloc, D=1, seed=11)
    if r[0] is None:
        print(f"{L:>4} {total:>10} {need:>6} | rank deficient: rank {r[1]} < {r[2]}", flush=True)
        continue
    ok, singles, nsingle = r
    print(f"{L:>4} {total:>10} {need:>6} | {str(ok):>5}/L={L:<4d} {str(singles):>6}/{nsingle:<6d}", flush=True)
print()
print("prediction: every key falls, and the L-2 keys with a SINGLE signature are recovered", flush=True)
print("too -- their key is pinned by the shared structure plus the other keys' data.", flush=True)
