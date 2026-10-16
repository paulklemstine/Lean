# Consequence of T4: if the SAME nonce is used under TWO DIFFERENT keys (a shared buggy
# RNG across a service), then with r1 == r2 and the same message z:
#       s_1 R - s_2 R = r (Q_1 - Q_2)     =>     R = r (s_1-s_2)^{-1} (Q_1 - Q_2)
# i.e. the verification point kG is recovered from KNOWN quantities alone -- no lattice and
# no knowledge of either key. (The nonce *scalar* still needs a DLP; the point does not.)
PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [0, 7])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))
set_random_seed(5)
hits = tot = 0
for trial in range(20):
    d1 = ZZ(randint(1, NK - 1)); d2 = ZZ(randint(1, NK - 1))
    Q1, Q2 = d1 * G, d2 * G
    k = ZZ(randint(1, NK - 1)); R = k * G; r = ZZ(R[0]) % NK
    z = ZZ(randint(0, NK - 1))
    s1 = (z + r * d1) * inverse_mod(k, NK) % NK
    s2 = (z + r * d2) * inverse_mod(k, NK) % NK
    if (s1 - s2) % NK == 0:
        continue
    tot += 1
    Rrec = (r * inverse_mod((s1 - s2) % NK, NK) % NK) * (Q1 - Q2)
    hits += (Rrec == R)
print(f"cross-key same-nonce: recovered R == kG in {hits}/{tot} trials", flush=True)

# and the same-message, same-key identity, restated as a checkable identity
hits2 = tot2 = 0
for trial in range(20):
    d = ZZ(randint(1, NK - 1)); Q = d * G
    z = ZZ(randint(0, NK - 1))
    S = []
    for _ in range(2):
        kk = ZZ(randint(1, NK - 1)); Rk = kk * G
        rr = ZZ(Rk[0]) % NK
        ss = (z + rr * d) * inverse_mod(kk, NK) % NK
        S.append((rr, ss, Rk))
    (r1, s1, R1), (r2, s2, R2) = S
    tot2 += 1
    hits2 += (s1 * R1 - s2 * R2 == (r1 - r2) * Q)
print(f"same-message identity s1 R1 - s2 R2 == (r1-r2) Q holds: {hits2}/{tot2}", flush=True)
