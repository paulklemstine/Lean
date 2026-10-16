# Independent ground-truth checks (not relying on the audit routine).
PK = ZZ(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F)
a, b = 0, 7
# j = 1728 * 4a^3 / (4a^3 + 27b^2) computed by hand, not via Sage's routine
num = 1728 * 4 * a**3
den = (4 * a**3 + 27 * b**2)
num_mod = num % PK; den_mod = den % PK
j_manual = (num_mod * inverse_mod(den_mod, PK)) % PK
print("secp256k1 j by explicit formula:", j_manual, "== 0 ?", j_manual == 0, flush=True)

# explicit primitive cube root of unity in F_p
F = GF(PK)
print("p mod 3 =", int(PK % 3), flush=True)
w = F(1)
# find omega != 1 with omega^3 = 1 by taking a generator^((p-1)/3)
g = F.multiplicative_generator()
omega = g**((PK - 1) // 3)
print("omega =", omega, " omega^3 == 1:", omega**3 == 1, " omega != 1:", omega != 1, flush=True)

# the map (x,y) -> (omega*x, y) is an automorphism of y^2 = x^3 + 7
E = EllipticCurve(F, [a, b])
P = E.random_point()
print("phi(P) on curve:", E.is_on_curve(omega * P[0], P[1]), flush=True)
print("phi is a group hom (check on P, Q):",
      E.is_on_curve(*( (E(omega*P[0], P[1]) + E(omega*Q[0], Q[1])) if False else (0,0) )) if False else "checked below", flush=True)
Q = E.random_point()
phi_P = E(omega * P[0], P[1]); phi_Q = E(omega * Q[0], Q[1])
print("  phi(P)+phi(Q) == phi(P+Q):", (phi_P + phi_Q) == E(omega * (P + Q)[0], (P + Q)[1]), flush=True)
print("  phi has order 3:", phi_P.add_loop() if False else (P and (E(omega*(omega*(omega*P[0])), P[1]) == P)), flush=True)

# Ed25519 <-> Curve25519 birational isomorphism check
P19 = ZZ(2**255 - 19); A = ZZ(486662)
D = ZZ(121666)
a_ed, d_ed = -1, -121665 * inverse_mod(121666, P19) % P19
A_mont = 2 * (a_ed + d_ed) * inverse_mod((a_ed - d_ed) % P19, P19) % P19
B_mont = 4 * inverse_mod((a_ed - d_ed) % P19, P19) % P19
print("Ed25519 -> Montgomery: A =", A_mont, " (== 486662?)", A_mont == A, flush=True)
print("                      B =", int(B_mont), " is -486664?", int(B_mont) == (-486664) % P19, flush=True)
print("  -486664 is a QR mod p (=> isomorphic to Curve25519):",
      legendre_symbol(-486664, P19), flush=True)
