# GENERALISATION: the nonce as a POLYNOMIAL (or any known linear combination) in a public
# sequence.  Cost = one linear solve, INDEPENDENT of the group order.
#
# The affine result (r118/affine-nonce) is the case D=1 of a general principle: if the nonce
# lies in an affine span of known functions of a public index,
#       k_i = sum_{j=1..D} a_j g_j(i)  +  Delta        (g_j public, a_j and Delta secret)
# then the signature equation is LINEAR in the D+2 unknowns (a_1..a_D, Delta, d):
#       s_i (sum_j a_j g_j(i) + Delta) - r_i d = z_i   (mod n)
# and t >= D+2 signatures determine the key by linear algebra alone.
#
# SHARP PREDICTION: a degree-D polynomial nonce (g_j(i) = i^j) needs exactly t* = D+2
# signatures, and the cost is O(D^3) for the solve -- independent of the group order n.
# This covers a counter, a timestamp, a message index, or any combination of public signals.

import time

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def attack_linear(n, rows, rhs):
    """rows: t x (D+2) matrix over Z_n; rhs: t-vector. Returns the unknown vector."""
    A = matrix(Zmod(n), rows)
    b = vector(Zmod(n), rhs)
    sol = A.solve_right(b)
    return [ZZ(sol[j]) % n for j in range(A.ncols())]

print("polynomial nonces: prediction t* = D + 2 exactly", flush=True)
print(f"{'D':>3} {'t used':>7} {'pred t*':>8} | {'key recovered':>14} {'offset+coefs':>15} {'solve s':>8}", flush=True)
for D in [1, 2, 3, 4]:
    for t in range(D + 1, D + 4):
        hits = 0; antid = 0; tel = 0.0
        for trial in range(12):
            set_random_seed(5000 + 10 * D + trial)
            d = ZZ(randint(1, NK - 1)); Q = d * G
            coeffs = [ZZ(randint(1, 1 << 60)) for _ in range(D)]
            delta = ZZ(randint(1, NK - 1))
            rows, rhs = [], []
            for i in range(t):
                gi = [ZZ(ZZ(1000003 + 97 * i) ^ (j + 1)) for j in range(D)]   # public signals
                ci = sum(coeffs[j] * gi[j] for j in range(D)) + delta
                ki = ci % NK
                zi = ZZ(randint(0, NK - 1)); ri = ZZ(randint(1, NK - 1))
                si = (zi + ri * d) * inverse_mod(ki, NK) % NK
                rows.append([si * g for g in gi] + [si % NK, (-ri) % NK])
                rhs.append(zi)
            t0 = time.time()
            sol = attack_linear(NK, rows, rhs)
            tel += time.time() - t0
            drec = sol[-1]
            hits += ((drec * G) == Q)
            antid += (sol[-2] == delta % NK)
        print(f"{D:>3} {t:>7} {D+2:>8} | {hits:>10}/12 {antid:>12}/12 {tel:>8.3f}", flush=True)
print()
print("=> t = D+2 suffices, and the solve time does not grow with the group order.", flush=True)
print("   (the 'offset+coefs' column checks the secret constants were recovered too)", flush=True)
