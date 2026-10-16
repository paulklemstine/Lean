# (1) class-number control: verify h(-163) == 1 and h(-3) == 1 with PARI.
print("qfbclassno(-163) =", pari.qfbclassno(-163), " qfbclassno(-3) =", pari.qfbclassno(-3),
      " qfbclassno(-4) =", pari.qfbclassno(-4), flush=True)

# (2) Ed25519, built properly with Sage's EdwardsCurve, then compared to Curve25519.
from sage.schemes.elliptic_curves.edwards_curve import EdwardsCurve
P19 = ZZ(2**255 - 19)
d_ed = -121665 * inverse_mod(121666, P19) % P19
Eed = EdwardsCurve(GF(P19), [-1, d_ed])
print("Ed25519 Edwards curve built; #E =", Eed.cardinality(), flush=True)
E19 = EllipticCurve(GF(P19), [0, 486662, 0, 1, 0])
print("Curve25519 #E        =", E19.cardinality(), flush=True)
print("orders equal:", Eed.cardinality() == E19.cardinality(), flush=True)
print("Ed25519 j-invariant bits:", Eed.to_weierstrass().j_invariant().nbits(), flush=True)

# (3) Curve25519's 2-isogeny walk, done manually on each rational 2-torsion point.
x = PolynomialRing(GF(P19), 'x').gen()
A = ZZ(486662)
roots = [r for r, _ in (x * (x**2 + A * x + 1)).roots()]
print("rational 2-torsion x-coords:", roots, flush=True)
special = {0, 1728 % P19}
for r in roots:
    if r == 0:
        P = E19(0, 0)
    else:
        P = E19(r, 0)
    try:
        C = E19.isogeny(P).codomain()
        j = int(C.j_invariant()) % P19
        print(f"  2-isogeny from x={int(r)} -> codomain j bits={j.nbits()} "
              f"special={j in special}  #E(codomain)={C.cardinality()}", flush=True)
    except Exception as ex:
        print(f"  2-isogeny from x={int(r)} failed: {type(ex).__name__}: {ex}", flush=True)
print("original j bits:", int(E19.j_invariant()).nbits(), flush=True)
