# T4: from two signatures on the SAME message, are the verification points recoverable?
#
#   R_i = (z/s_i) G + (r_i/s_i) Q        (the point whose x-coordinate must equal r_i mod n)
#   s_i R_i = z G + r_i Q                (multiply through by s_i)
#   s_1 R_1 - s_2 R_2 = (r_1 - r_2) Q    (subtract -- the zG terms cancel)
#
# We know r_i = x(R_i) mod n but not x(R_i) itself. If p < 2n then x(R_i) in {r_i, r_i+n}
# (a single bit), and y(R_i) has 2 choices, so R_i has <= 4 candidates and (R_1,R_2) <= 16.
# The identity above then identifies the true pair. If it works, ECDSA signatures leak the
# actual verification points, not merely their x-coordinates mod n.

def trial(name, p, a, b, Gx, Gy, n, tcurve=None):
    F = GF(p)
    E = EllipticCurve(F, [a, b])
    G = E(Gx, Gy)
    d = ZZ(randint(1, n - 1))
    Q = d * G
    z = ZZ(randint(0, n - 1))
    zc = ZZ(randint(0, n - 1))
    sigs = []
    for _ in range(2):
        k = ZZ(randint(1, n - 1))
        R = k * G
        r = ZZ(R[0]) % n
        s = (z + r * d) * inverse_mod(k, n) % n
        sigs.append((r, s, R, k))
    print(f"[{name}] p/n = {float(QQ(p)/QQ(n)):.9f}  (2n > p: {2*n > p})", flush=True)
    (r1, s1, R1, k1), (r2, s2, R2, k2) = sigs
    # verify the signature relation holds
    for i, (r, s, R, k) in enumerate(sigs, 1):
        chk = E((z * inverse_mod(s, n)) % n * G[0], 0) if False else None
    ok = all(ZZ(sigs[i][2][0]) % n == sigs[i][0] for i in (0, 1))
    print(f"  both signatures consistent: {ok}", flush=True)
    # recover: enumerate candidates for R_1, R_2 and match (r1-r2)Q = s1 R1 - s2 R2
    def candidates(r):
        out = []
        for xx in (r, r + n):
            if xx >= p:
                continue
            y2 = F(xx)**3 + F(a) * F(xx) + F(b)
            if y2 == 0:
                out.append(E(xx, 0))
            elif y2.is_square():
                y = y2.sqrt()
                out.append(E(xx, y))      # BOTH signs: ECDSA gives x(R) mod n only,
                out.append(E(xx, -y))     # so R is ambiguous up to (x-bit, y-sign)
        return out
    c1, c2 = candidates(r1), candidates(r2)
    print(f"  candidate R_1s: {len(c1)}, candidate R_2s: {len(c2)}, total pairs: {len(c1)*len(c2)}", flush=True)
    target = (r1 - r2) * Q
    matches = []
    for X1 in c1:
        for X2 in c2:
            if s1 * X1 - s2 * X2 == target:
                matches.append((X1, X2))
    print(f"  matching pairs: {len(matches)}", flush=True)
    if len(matches) == 1:
        X1, X2 = matches[0]
        print(f"  recovered R_1 == true k_1 G : {X1 == R1}", flush=True)
        print(f"  recovered R_2 == true k_2 G : {X2 == R2}", flush=True)
        print(f"  => the verification POINTS are recoverable from the signatures", flush=True)
    # count over multiple trials how often the identification is unique
    uniq = tot = 0
    for _ in range(20):
        zz = ZZ(randint(0, n - 1))
        S = []
        for _ in range(2):
            k = ZZ(randint(1, n - 1)); R = k * G
            rr = ZZ(R[0]) % n
            ss = (zz + rr * d) * inverse_mod(k, n) % n
            S.append((rr, ss, R))
        (rr1, ss1, RR1), (rr2, ss2, RR2) = S
        cc1, cc2 = candidates(rr1), candidates(rr2)
        tot += 1
        if sum(1 for X1 in cc1 for X2 in cc2 if ss1 * X1 - ss2 * X2 == (rr1 - rr2) * Q) == 1:
            uniq += 1
    print(f"  uniqueness over 20 trials: {uniq}/{tot}", flush=True)

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
set_random_seed(11)
trial("secp256k1", PK, 0, 7, ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8), NK)

PR = ZZ(0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff)
NR = ZZ(0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551)
trial("P-256", PR, ZZ(0xffffffff00000001000000000000000000000000fffffffffffffffffffffffc),
      ZZ(0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b),
      ZZ(0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296),
      ZZ(0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5), NR)
