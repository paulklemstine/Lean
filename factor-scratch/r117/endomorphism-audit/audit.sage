# T1 (v3) -- endomorphism-ring audit of the deployed ECDSA curves.
#
# Corrections over v2 (each of these silently produced a WRONG control before):
#   * j=0 control must be y^2 = x^3 + a6 (v2 built y^2=x^3+x, which is j=1728).
#   * curve-with-given-j must be [a1,a2,a3,a4,a6] = [0,0,0,3c,2c] with c = j/(1728-j)
#     (v2 put 3c into the a1 slot, so it audited a different curve).
#   * the CM-by-D=-163 search is bounded (v2's bound was 10^14 primes => infinite loop).
#
# The audit reports TWO different things, which must not be conflated:
#   (A) the ISOGENY CLASS SIZE, ~ h(disc(End(E))) with |disc(End(E))| <= |t^2-4p|.
#       For every curve over F_p this is ~2^(nbits/2) unless |t| ~ 2*sqrt(p), which
#       cannot happen for large p. This is what defeats Galbraith-Hess-Smart transport.
#   (B) the STRUCTURAL specialness: Aut(E) = {+-1} generically, order 6 if j=0
#       (CM by Z[(1+sqrt(-3))/2], class number 1), order 4 if j=1728 (CM by Z[i]).
#       This gives GLV-style endomorphisms but does NOT shrink (A).

import time

def audit(name, coeffs, p, verbose=True):
    E = EllipticCurve(GF(p), coeffs)
    t0 = time.time(); nE = E.cardinality(); el = time.time() - t0
    t = p + 1 - nE
    d = t**2 - 4 * p
    j = int(E.j_invariant()) % p
    ratio = float(abs(d) / QQ(4 * p))
    supersing = (t % p == 0) or (t == 0)
    anomalous = abs(t) == 1
    j0 = (j == 0); j1728 = (j == 1728 % p)
    flags = []
    if supersing: flags.append("SUPERSINGULAR(t=0)")
    if anomalous: flags.append("ANOMALOUS(|t|=1)")
    if j0:       flags.append("j=0(CM -3,Aut6)")
    if j1728:    flags.append("j=1728(CM -4,Aut4)")
    if j0 and p % 3 == 1:     flags.append("omega-in-F_p")
    if j1728 and p % 4 == 1:  flags.append("i-in-F_p")
    if ratio < 1e-6:          flags.append("NEAR-SQUARE-p(|t|~2sqrt(p))")
    if verbose:
        print(f"  {name:24s} t={t.nbits():4d}b |d|={abs(d).nbits():4d}b |d|/4p={ratio:.4f} "
              f"isogeny-class~2^{abs(d).nbits()//2}b j=0:{j0} j1728:{j1728} "
              f"{'FLAGS:'+'+'.join(flags) if flags else 'clean'} ({el:.1f}s)", flush=True)
    return dict(name=name, t=t, d=d, j=j, flags=flags, ratio=ratio, secs=el)

def neighbourhood(name, coeffs, p):
    E = EllipticCurve(GF(p), coeffs); nE = E.cardinality()
    special = {0, 1728 % p}; notes = []
    for ell in (2, 3):
        if nE % ell != 0:
            notes.append(f"{ell}: no {ell}-torsion over F_p"); continue
        js = set()
        try:
            for g in E.torsion_subgroup().gens():
                for i in range(1, ell):
                    P = i * g
                    if P.order() == ell:
                        try: js.add(int(E.isogeny(P).codomain().j_invariant()) % p)
                        except Exception: pass
        except Exception as ex:
            notes.append(f"{ell}: walk failed {type(ex).__name__}"); continue
        notes.append(f"{ell}: {len(js)} neighbour(s)" + (", SPECIAL-j" if any(x in special for x in js) else ", none special"))
    print(f"    neighbourhood[{name}]: " + "; ".join(notes), flush=True)

print("=== CONTROLS -- each must fire ===", flush=True)

p_ss = ZZ(next_prime(2**100))
while p_ss % 3 != 2: p_ss = ZZ(next_prime(p_ss + 1))
audit("C-supersingular t=0", [0, 0, 0, 0, 1], p_ss)

p0 = ZZ(next_prime(2**90))
while p0 % 3 != 1: p0 = ZZ(next_prime(p0 + 1))
audit("C-j=0 (CM -3)", [0, 0, 0, 0, 1], p0)

p144 = ZZ(next_prime(2**90))
while p144 % 4 != 1: p144 = ZZ(next_prime(p144 + 1))
audit("C-j=1728 (CM -4)", [0, 0, 0, 1, 0], p144)

audit("C-anomalous t=-1", [0, 0, 0, 2, 1], 5)

# CM with class number 1, D = -163 (Heegner). j = -640320^3. Over any p != 163 the
# reduction must satisfy 4p - t^2 = 163 * f^2.
j163 = ZZ(-640320)**3
p_cm = ZZ(next_prime(2**129))
while p_cm % 163 == 0: p_cm = ZZ(next_prime(p_cm + 1))
jm = j163 % p_cm
if jm == 1728 % p_cm:   Ee = EllipticCurve(GF(p_cm), [0, 0, 0, 1, 0])
elif jm == 0:           Ee = EllipticCurve(GF(p_cm), [0, 0, 0, 0, 1])
else:
    c = jm * inverse_mod((1728 - jm) % p_cm, p_cm) % p_cm
    Ee = EllipticCurve(GF(p_cm), [0, 0, 0, 3 * c % p_cm, 2 * c % p_cm])
nEe = Ee.cardinality(); te = p_cm + 1 - nEe; de = te**2 - 4 * p_cm
rem = (-de) % 163
if rem == 0:
    f2 = -de // 163
    print(f"  C-CM D=-163          FIRES: t={te.nbits()}b 4p-t^2={163}*f^2, f={f2.nbits()//2}b, "
          f"|d|/4p={float(abs(de)/QQ(4*p_cm)):.4f}  (End ring has class number 1)", flush=True)
else:
    print(f"  C-CM D=-163          DID NOT FIRE: 4p-t^2 = {(-de)} is not divisible by 163", flush=True)

print("=== MEASUREMENT: deployed curves ===", flush=True)

PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
audit("secp256k1 (y^2=x^3+7)", [0, 0, 0, 0, 7], PK)
neighbourhood("secp256k1", [0, 0, 0, 0, 7], PK)

PR = ZZ(0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff)
audit("P-256 (secp256r1)", [0, 0, 0,
      ZZ(0xffffffff00000001000000000000000000000000fffffffffffffffffffffffc),
      ZZ(0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b)], PR)

P19 = ZZ(2**255 - 19); A19 = ZZ(486662)
E19 = EllipticCurve(GF(P19), [0, A19, 0, 1, 0])
nE19 = E19.cardinality(); t19 = P19 + 1 - nE19; d19 = t19**2 - 4 * P19; j19 = int(E19.j_invariant()) % P19
print(f"  Curve25519 (montgom.) t={t19.nbits()}b |d|={abs(d19).nbits()}b "
      f"|d|/4p={float(abs(d19)/QQ(4*P19)):.4f} isogeny-class~2^{abs(d19).nbits()//2}b "
      f"j=0:{j19==0} j1728:{j19==1728%P19} j_bits={j19.nbits()}", flush=True)
neighbourhood("Curve25519", [0, A19, 0, 1, 0], P19)

Eed = EllipticCurve(GF(P19), [0, ZZ(-(121665 * inverse_mod(121666, P19)) % P19), 0, 1, 0])
print(f"  Ed25519 (edwards)  #E == Curve25519 #E: {Eed.cardinality() == nE19}", flush=True)

PB = ZZ(0xa9fb57dba1eea9bc3e660a909d838d726e3bf623d52620282013481d1f6e5377)
audit("BrainpoolP256r1", [0, 0, 0,
      ZZ(0x7d5a0975fc2c3057eef67530417affe7fb8055c126dc5c6ce94a4b44f330b5d9),
      ZZ(0x26dc5c6ce94a4b44f330b5d9bbd77cbf958416295cf7e1ce6bccdc18ff8c07b6)], PB)

P384 = ZZ(2**384 - 2**128 - 2**96 + 2**32 - 1)
audit("P-384", [0, 0, 0,
      ZZ(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffff0000000000000000fffffffc),
      ZZ(0xb3312fa7e23ee7e4988e056be3f82d19181d9c6efe8141120314088f5013875ac656398d8a2ed19d2a85c8edd3ec2aef)], P384)

print(f"    secp256k1 detail: p mod 3 = {PK % 3} (1 => primitive cube root of unity in F_p)", flush=True)
w2 = GF(PK)(PK - 1).sqrt(); w3 = GF(PK)(PK - 1).nth_root(3) if False else None
print(f"    a cube root of unity in F_p exists: {(PK-1) % 3 == 0}", flush=True)
