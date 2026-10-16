# NEW ATTACK MODEL: nonce = known sequence + secret shared offset.
#
# The blocked bias-model axis (r118/bias-model) asked what happens when nonces share an
# UNKNOWN bias A: the lattice construction never got a working form.  But the special case
# that matters in practice is exactly linear, and needs no lattice and no statistics:
#
#     k_i = c_i + Delta        (c_i public, e.g. a counter or a message index; Delta secret)
#     signature:  s_i k_i = z_i + r_i d   (mod n)
#     =>  s_i c_i + s_i Delta - r_i d = z_i   -- LINEAR in the two unknowns (Delta, d)
#
# Two signatures give a 2x2 system in (Delta, d), generically invertible, so the private key
# falls IMMEDIATELY -- no lattice, no Fourier transform, no leakage budget.  The same holds
# for any AFFINE family k_i = a c_i + Delta with a known.
#
# This is a plausible implementation shape (a counter plus a per-key constant offset, or a
# fixed RNG seed initialised per key), and it is invisible to every statistic this campaign
# measured: k is uniform-ish, so p = 1/2 and the Fourier attack is inert; there is no MSB
# bias, so the lattice threshold is irrelevant.

import time

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
NK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
F = GF(PK); E = EllipticCurve(F, [ZZ(0), ZZ(7)])
G = E(ZZ(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798),
      ZZ(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8))

def attack_affine(n, c, r, s, z):
    """recover (Delta, d) from the linear system; return d or None."""
    # unknowns x = (Delta, d);  rows: [s_i, -r_i] . x = z_i - s_i c_i   (mod n)
    A = matrix(Zmod(n), [[s[i], (-r[i]) % n] for i in range(len(c))])
    b = vector(Zmod(n), [(z[i] - s[i]*c[i]) % n for i in range(len(c))])
    sol = A.solve_right(b)          # least-squares/least-norm solution
    delta = ZZ(sol[0]) % n
    d = ZZ(sol[1]) % n
    return d, delta

hits = tot = 0
for trial in range(20):
    set_random_seed(1000 + trial)
    d = ZZ(randint(1, NK - 1)); Q = d * G
    delta = ZZ(randint(1, NK - 1))                       # the secret shared offset
    # nonce sequence: counter + secret offset  (a plausible RNG shape)
    cs, rs, ss, zs, ks = [], [], [], [], []
    for i in range(4):
        ci = ZZ(randint(1, 1 << 40))                     # public counter, 40-bit
        ki = (ci + delta) % NK
        zi = ZZ(randint(0, NK - 1)); ri = ZZ(randint(1, NK - 1))
        si = (zi + ri * d) * inverse_mod(ki, NK) % NK
        cs.append(ci); rs.append(ri); ss.append(si); zs.append(zi); ks.append(ki)
    t_used = 2 if trial % 2 == 0 else 3
    drec, delrec = attack_affine(NK, cs[:t_used], rs[:t_used], ss[:t_used], zs[:t_used])
    # GROUND TRUTH: the recovered key must satisfy d*G = Q
    tot += 1
    if (drec * G) == Q:
        hits += 1
    if trial < 4:
        print(f"  trial {trial}: t={t_used}  recovered d, and d*G == Q: {(drec*G)==Q} "
              f"(Delta recovered: {delrec == delta % NK})", flush=True)
print(f"counter+offset nonces: private key recovered in {hits}/{tot} trials (2 or 3 signatures)", flush=True)

# also: the affine family k = a*c + delta with a known multiplier
print()
hits2 = tot2 = 0
for trial in range(20):
    set_random_seed(2000 + trial)
    d = ZZ(randint(1, NK - 1)); Q = d * G
    delta = ZZ(randint(1, NK - 1)); a_mult = ZZ(randint(1, 1 << 32))    # public multiplier
    cs, rs, ss, zs = [], [], [], []
    for i in range(3):
        ci = ZZ(randint(1, 1 << 40))
        ki = (a_mult * ci + delta) % NK
        zi = ZZ(randint(0, NK - 1)); ri = ZZ(randint(1, NK - 1))
        si = (zi + ri * d) * inverse_mod(ki, NK) % NK
        cs.append(ci); rs.append(ri); ss.append(si); zs.append(zi)
    # the multiplier a multiplies c_i, so fold it into the known part:
    # s_i*(a c_i) + s_i*Delta - r_i d = z_i   -> known part is a*c_i
    drec2, _ = attack_affine(NK, [a_mult * c for c in cs], rs, ss, zs)
    tot2 += 1
    if (drec2 * G) == Q:
        hits2 += 1
print(f"affine family k = a*c + delta (a public): {hits2}/{tot2} with 3 signatures", flush=True)
print()
print("=> any nonce family that is AFFINE in a public sequence with ONE secret shared offset", flush=True)
print("   falls to linear algebra in 2-3 signatures, with no leakage and no lattice.", flush=True)
print("   The public sequence can be a counter, a timestamp, or a message index.", flush=True)
