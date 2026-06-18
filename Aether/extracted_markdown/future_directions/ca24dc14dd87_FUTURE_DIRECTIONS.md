# Future Directions: Falsifiable Hypotheses for Beal Obstruction Theory

## Hypothesis 1: Finite Covering Hypothesis for Signature (3, 3, 3)

**Conjecture:** There exists a modulus N ≤ 10⁶ such that `PrimitiveResidueSolution N 3 3 3` is false (i.e., no triple of units modulo N satisfies a³ + b³ ≡ c³ (mod N)).

**Test:** Exhaustive enumeration of primitive residue solutions for each N from 2 to 10⁶. For each N, compute φ(N)³ and check all unit triples.

**Current evidence:** Already confirmed for N = 2, 4, 7, 8, 9, 13, 16 (small moduli). The conjecture predicts these are not isolated — there exist many such obstructing moduli, possibly including large primes.

**Refutation criterion:** If exhaustive computation shows that every prime p ≤ 10⁶ admits at least one primitive residue solution for (3,3,3), the hypothesis (in its prime form) is refuted. Note: composite moduli may still provide obstructions via CRT.

**Impact if true:** Provides an unconditional computational certificate proving that no coprime cube sum A³ + B³ = C³ exists among integers coprime to N, without invoking Fermat's Last Theorem.

---

## Hypothesis 2: CRT Compression Efficiency Hypothesis

**Conjecture:** For pairwise coprime moduli M₁, …, Mₖ with N = ∏ Mᵢ, the following equivalence holds:

PrimitiveResidueSolution(N, x, y, z) ⟺ ∀ i, PrimitiveResidueSolution(Mᵢ, x, y, z)

That is, a primitive solution modulo the product exists if and only if primitive solutions exist modulo each factor.

**Test:** 
- The forward direction (product → factors) follows from the CRT divisor inheritance theorem already proved.
- The reverse direction (factors → product) requires a careful CRT reconstruction. Formalize this as a theorem, or find a counterexample.

**Refutation criterion:** Exhibit pairwise coprime M₁, M₂ and a signature (x,y,z) such that PrimitiveResidueSolution holds for both M₁ and M₂ individually but NOT for M₁ · M₂. This would occur if the CRT-lifted solutions fail the coprimality-to-modulus condition at the product level.

**Subtlety:** The coprimality-to-N condition makes this nontrivial. A unit modulo M₁ and a unit modulo M₂ give a unit modulo M₁·M₂ (by CRT), so the reverse direction should hold for the primitive predicate. The key question is whether the algebraic interaction between the coprimality and congruence conditions introduces unexpected obstructions.

**Impact if true:** Establishes that obstruction searching can be fully decomposed into independent local computations at prime-power moduli, dramatically reducing computational cost.

---

## Hypothesis 3: Linear ABC Threshold Hypothesis

**Conjecture:** There exists a universal constant α ≤ 3 such that IntAbcBound(K) implies no primitive Beal solution for all exponents x, y, z > αK.

**Current status:** We have proved α = 3 works (threshold 3K + 1). The question is whether this is optimal.

**Test:** 
- Attempt to prove the theorem with threshold 2K + 1 instead of 3K + 1.
- The bottleneck is the bound A · B · C < C^(3z). If the effective exponent can be reduced to 2z (using A ≤ C^(z-1) from A^x < C^z and x ≥ 2), the threshold drops.

**Refutation criterion:** Prove that the argument structure necessarily requires α ≥ 3. Specifically, show that for K = 1, the threshold cannot be reduced below 4 (i.e., IntAbcBound(1) does NOT imply absence of solutions with exponents (3,3,3)). This can be checked by exhibiting a model of IntAbcBound(1) that admits a coprime (3,3,3)-solution, or by proving that the 3K bound is tight.

**Impact if true:** Sharpens the ABC-Beal connection, extending the forbidden region in exponent space by ~50%.

---

## Hypothesis 4: Reciprocal-Bound Sharpness Hypothesis

**Conjecture:** IntAbcBound(K) and the condition K(1/x + 1/y + 1/z) < 1 together imply no primitive Beal solution to A^x + B^y = C^z, WITHOUT any auxiliary power-amplification.

**Mathematical content:** This would give non-uniform bounds: for K = 2, the condition 2(1/3 + 1/3 + 1/3) = 2 > 1, so (3,3,3) is NOT excluded; but 2(1/4 + 1/4 + 1/4) = 1.5 > 1, so (4,4,4) is also not excluded; while 2(1/3 + 1/4 + 1/8) = 2·(37/96) ≈ 0.77 < 1, so (3,4,8) IS excluded.

**Test:** Formalize the proof over ℚ or ℝ. The key step is deriving A ≤ C^(z/x), B ≤ C^(z/y), C ≤ C^(z/z) from the Beal equation, giving ABC ≤ C^(z(1/x+1/y+1/z)). Combined with C^z ≤ (ABC)^K = (ABC)^K, this yields C^z ≤ C^(Kz(1/x+1/y+1/z)), contradicting K(1/x+1/y+1/z) < 1.

**Subtlety:** The bound A ≤ C^(z/x) requires working with non-integer exponents, which is harder to formalize. The integer-clearing approach multiplies through by xyz, working with C^(xyz) instead.

**Refutation criterion:** Identify a specific step in the proof that requires a strictly stronger bound than C^(z/x), making the reciprocal condition insufficient without amplification.

**Impact if true:** Gives a much more refined forbidden region in exponent space, excluding many asymmetric signatures that the uniform bound misses.

---

## Hypothesis 5: Obstruction Universality for Weighted Equations

**Conjecture:** The residue-covering framework extends from A^x + B^y = C^z to equations of the form A^p + B^q = D · C^r with a fixed integer coefficient D ≥ 1.

**Precise statement:** Define

```
WeightedResidueSolution(N, D, p, q, r) :=
  ∃ a b c ∈ {0,...,N-1},
    gcd(a,N) = gcd(b,N) = gcd(c,N) = 1 ∧
    (a^p + b^q) mod N = (D · c^r) mod N
```

Then: if ¬WeightedResidueSolution(N, D, p, q, r), then no coprime-to-N solution to A^p + B^q = D · C^r exists.

**Test:** Prove the analogue of the Residue Obstruction Theorem for the weighted predicate. The proof should be identical — the coefficient D is absorbed into the modular arithmetic.

**Refutation criterion:** Find a coefficient D and signature (p,q,r) for which the weighted predicate introduces a formal obstacle not present in the unweighted case. (This seems unlikely — the theorem should generalize directly.)

**Impact if true:** Extends the obstruction framework to a much broader class of Diophantine equations, including twisted Fermat equations, Catalan-type equations, and S-unit equations with fixed coefficients.

---

## Priority Ranking

1. **Hypothesis 4** (Reciprocal bound) — highest mathematical impact; would give the sharpest known conditional result.
2. **Hypothesis 2** (CRT compression) — essential infrastructure for practical certificate generation.
3. **Hypothesis 5** (Universality) — broadest generalization; likely straightforward to prove.
4. **Hypothesis 3** (Linear threshold) — interesting but may require fundamentally new ideas.
5. **Hypothesis 1** (Finite covering) — primarily computational; useful for benchmarking but less theoretical depth.
