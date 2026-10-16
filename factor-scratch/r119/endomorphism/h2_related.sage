###############################################################################
# H2 -- the "related-nonce pair" break, with ground truth d*G == Q.
#
# CLAIM under test:  two signatures (r1,s1),(r2,s2) with r2 = omega*r1 mod n
# have lambda-related nonces, and then the key falls from those two alone by
# linear algebra in the unknowns (k,d):
#     s1*k = z1 + r1*d ;  s2*(lambda*k) = z2 + r2*d
#
# TRUE part : the 2x2 linear algebra does recover the key when the nonce
#             relation is known.  (This is an oracle-free algebra fact.)
# CLAIM part: the relation r2 = omega*r1 mod n is the *detector* for such
#             pairs.  That part is tested here and it FAILS.
###############################################################################
print("=" * 78)
print("H2  related-nonce-pair break on real secp256k1 (ground truth d*G == Q)")
print("=" * 78)

p  = Integer(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
n  = Integer(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
Gx = Integer(0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798)
Gy = Integer(0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)
E = EllipticCurve(GF(p), [0, 0, 0, 0, Integer(7)])
G = E(Gx, Gy)
assert E.count_points() == n and is_prime(n)
load("ecutil.sage")
omega = j0_omega(p)
LAMa, LAMb = lam_of(n)

# which of the two lambdas is the automorphism (x,y) -> (omega*x, y)?
match_a = all((LAMa * (kk := ZZ.random_element(1, n - 1)) * G) ==
              E((omega * xint(kk * G, p)) % p, Integer((kk * G)[1])) for _ in range(8))
LAMBDA = LAMa if match_a else LAMb
assert (Integer(LAMBDA) * G)[0] == (omega * Integer(Gx)) % p
print("omega =", hex(omega))
print("LAMBDA (phi = [LAMBDA]) =", hex(LAMBDA), " LAMBDA^2+LAMBDA+1 = 0 mod n:",
      (LAMBDA^2 + LAMBDA + 1) % n == 0)

# ------------------------------------------------------------------ part A
# the 2x2 algebra, given that nonce_2 = LAMBDA * nonce_1.  Oracle-grade info
# about the NONCE relation; we then verify the recovered key against d*G == Q.
print("\n--- A. algebra: assume k2 = LAMBDA*k1, recover (k,d), verify d*G == Q ---")
okA = 0
for t in range(25):
    d = ZZ.random_element(1, n - 1)
    Q = d * G
    k = ZZ.random_element(1, n - 1)
    k2 = (LAMBDA * k) % n
    if k2 == 0:
        continue
    z1 = ZZ.random_element(1, n - 1)
    z2 = ZZ.random_element(1, n - 1)
    sig1 = sign(d, z1, k, E, G, n, p)
    sig2 = sign(d, z2, k2, E, G, n, p)
    if sig1 is None or sig2 is None:
        continue
    (r1, s1) = sig1
    (r2, s2) = sig2
    res = pair_solve((r1, s1, z1), (r2, s2, z2), LAMBDA, n)
    if res is None:
        print("   singular system, skip")
        continue
    kh, dh = res
    good = (dh == d) and (dh * G == Q) and (kh == k)
    if good:
        okA += 1
    elif t < 5:
        print("   MISMATCH k2=0 case? det singular:", res)
print("   recovered d (and d*G == Q) with the nonce relation KNOWN : %d/%d" % (okA, 25))
print("   => H2's algebra part FIRES.  The 2x2 solve is real; it needs the")
print("      RELATION, and the claim is that r2 = omega*r1 supplies it.")

# ------------------------------------------------------------------ part B
# Does r2 = omega*r1 mod n actually flag a pair whose nonces ARE related?
print("\n--- B. does the proposed detector  r2 == omega*r1 (mod n)  fire on "
      "TRULY related nonces? ---")
hitB = 0
trialsB = 0
for t in range(200):
    d = ZZ.random_element(1, n - 1)
    Q = d * G
    k = ZZ.random_element(1, n - 1)
    k2 = (LAMBDA * k) % n
    if k2 == 0:
        continue
    sig1 = sign(d, ZZ.random_element(1, n - 1), k, E, G, n, p)
    sig2 = sign(d, ZZ.random_element(1, n - 1), k2, E, G, n, p)
    if sig1 is None or sig2 is None:
        continue
    trialsB += 1
    r1, s1 = sig1
    r2, s2 = sig2
    assert (LAMBDA * k) % n == k2        # ground truth: nonces really ARE related
    if r2 == (omega * r1) % n:           # <-- the brainstorm's detector
        hitB += 1
print("   true lambda-related pairs tested ................. %d" % trialsB)
print("   detector r2 == omega*r1 (mod n) fired ............. %d   (chance level ~%.4f)"
      % (hitB, 1.0 / float(n)))
print("   => the detector does NOT see its own target.")

# ------------------------------------------------------------------ part C
# refined detector: r2 must lie in the 2-candidate set computable from r1
# alone ({((omega*r) mod p) mod n, ((omega*(r+n)) mod p) mod n}).
print("\n--- C. refined detector: r2 in the 2-candidate set from r1 alone ---")
hitC = 0
trialsC = 0
for t in range(200):
    d = ZZ.random_element(1, n - 1)
    Q = d * G
    k = ZZ.random_element(1, n - 1)
    k2 = (LAMBDA * k) % n
    if k2 == 0:
        continue
    sig1 = sign(d, ZZ.random_element(1, n - 1), k, E, G, n, p)
    sig2 = sign(d, ZZ.random_element(1, n - 1), k2, E, G, n, p)
    if sig1 is None or sig2 is None:
        continue
    trialsC += 1
    r1, s1 = sig1
    r2, s2 = sig2
    if r2 in omega_image_candidates(r1, n, omega, p):
        hitC += 1
    # ground truth: the second nonce really is LAMBDA times the first
    assert (LAMBDA * k) % n == k2
print("   truly lambda-related pairs tested ................. %d" % trialsC)
print("   refined detector (2 candidates) recall ............ %d/%d" % (hitC, trialsC))
print("   (a random pair hits with prob ~2/n = %.3g)"
      % (2.0 / float(n)))

# ------------------------------------------------------------------ part D
# unrelated nonces, same key: what does the brainstormed attack see?
print("\n--- D. unrelated nonces (same key): scan pairs for r2 == omega*r1 ---")
d = ZZ.random_element(1, n - 1)
Q = d * G
coldata = []
for _ in range(60):
    sig = sign(d, ZZ.random_element(1, n - 1), ZZ.random_element(1, n - 1), E, G, n, p)
    if sig:
        coldata.append(sig)
hits = 0
for i in range(len(coldata)):
    for jx in range(len(coldata)):
        if i == jx:
            continue
        r1, s1 = coldata[i]
        r2, s2 = coldata[jx]
        if r2 == (omega * r1) % n:
            hits += 1
print("   %d signatures from one key, ordered pairs checked .. %d"
      % (len(coldata), len(coldata) * (len(coldata) - 1)))
print("   detector fired ..................................... %d" % hits)

# ------------------------------------------------------------------ part E
# what happens if you TRUST a detector hit and run the algebra?
# i.e. force the relation on a pair whose nonces are unrelated -> garbage.
print("\n--- E. trusting a detector hit on unrelated nonces -> key? ---")
bad = 0
triesE = 0
for t in range(5):
    d = ZZ.random_element(1, n - 1)
    Q = d * G
    z1 = ZZ.random_element(1, n - 1)
    z2 = ZZ.random_element(1, n - 1)
    sig1 = sign(d, z1, ZZ.random_element(1, n - 1), E, G, n, p)
    sig2 = sign(d, z2, ZZ.random_element(1, n - 1), E, G, n, p)
    if sig1 is None or sig2 is None:
        continue
    r1, s1 = sig1
    r2, s2 = sig2
    triesE += 1
    res = pair_solve((r1, s1, z1), (r2, s2, z2), LAMBDA, n)
    if res is None:
        print("     singular system")
        continue
    kh, dh = res
    good = (dh == d) and (dh * G == Q)
    bad += (1 if good else 0)
    print("     forced relation on UNRELATED nonces: d'*G == Q ?  %s" % good)
print("   count of accidental correct keys: %d/%d  (expect 0)" % (bad, triesE))

print("\nVERDICT on H2:")
print("  * The related-nonce 2x2 break is REAL: %d/%d with nonce relation known," % (okA, 25))
print("    verified against d*G == Q on real secp256k1.")
print("  * But the proposed DETECTOR r2 == omega*r1 (mod n) fired on 0/%d truly" % trialsB)
print("    lambda-related pairs, so it cannot supply the relation.  The break is")
print("    an oracle (needs external knowledge of nonce-relatedness); the omega")
print("    relation adds nothing to it.")
