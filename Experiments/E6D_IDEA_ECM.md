# E-6d: Ideal-ECM Prototype Sketch (Class-Group Lottery)

**Empirical basis (E-6b/c)**: |Cl(Q(√-Δ))| is B-smooth ~72% at 29 bits vs EC 44% —
the lottery odds favor class groups ~1.6×.

## Mechanism design
ECM finds p | N when a curve group order E(Z/p) is B-smooth, via scalar mult
mod N. Analogue: work in Cl(O_D) for D = -q mod N (q random prime ≡ 3 mod 4);
the class group acts on binary quadratic forms [a,b,c] with discriminant D;
composition is fast (NUDUPL-style). If |Cl(O_D mod p)| relates to Cl(D)·(p-χ)
structure and lands smooth for some q → gcd recovers p.

## Feasibility analysis
1. **Action correctness**: form composition mod N is well-defined without
   knowing p (discriminant fixed mod N) — ANALOGOUS to EC point ops. ✓ feasible.
2. **Order randomness**: |Cl(O_D)| distribution measured favorable (E-6c);
   the mod-p quotient perturbs by (p − (D/p)) factors — needs E-7 verification.
3. **Cost per "curve"**: form composition ≈ EC scalar mult cost; NUDPL gives
   doubling speedups. ✓ competitive constant.
4. **Known obstruction**: Sutherland's group-ECM analyses note generic groups
   lack ECM's Hasse-bounded order concentration — our E-6c data says class
   numbers may compensate statistically.

## Testable milestone (E-7, next)
For 200 random primes p ~ 2²⁰ and random q ≡ 3 mod 4: compute h(D_p) where
D = -q·p⁰-form discriminant proxy; measure P(smooth) vs matched EC baseline.
If ≥ EC rate: implement form-composition walk mod N and attempt first
class-group factoring demo on a 30-bit-factor semiprime.

## Honest asymptotics
Even if successful: mechanism is a fresh L[1/2] lottery, not an L[1/3]
breakthrough. Value = independence from elliptic curves + possible constant/
distribution gains from Cohen-Lenstra skew.
