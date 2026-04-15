# The Stereographic Projection Bridge: Open Questions Resolved and New Directions

## A Machine-Verified Research Program in Lean 4

---

### Abstract

We present a comprehensive investigation of the Stereographic Projection Bridge (SPB) operation spb(x, y) = (x + y)/(1 − xy), resolving several open questions from the original SPB research program and establishing new formally verified results. Working in Lean 4 with Mathlib, we prove **50+ theorems with zero `sorry` statements** across seven files covering:

1. **Complete three-leaf Machin classification** (Theorem 3.1): We prove that spb(spb(1/a, 1/b), 1/c) = 1 with 2 ≤ a ≤ b ≤ c has exactly three solutions: (2,4,13), (2,5,8), and (3,3,7). The proof uses a novel bounding argument showing a ≤ 3 via the inequality b²(a−3) ≤ 3b−1.

2. **Full SPB derivative chain rule** (Theorem 4.1): For differentiable f, g with f(t)g(t) ≠ 1:
   d/dt spb(f(t), g(t)) = [f'(1+g²) + g'(1+f²)] / (1−fg)²
   
3. **Cayley transform deep properties** (Section 5): Injectivity, homomorphism cayley(spb(x,y)) = cayley(x)·cayley(y), special values cayley(0)=1, cayley(1)=i, cayley(−1)=−i.

4. **Tropical SPB structure theorem** (Section 6): We prove tspb has NO global identity element, establish the sign-regime decomposition (tspb = −min for nonneg inputs, tspb = max for nonpos inputs), and prove the idempotency/anti-idempotency dichotomy.

5. **Corrected reciprocal law** (Theorem 2.5): The correct identity is spb(1/x, 1/y) = −spb(x, y), not spb(x,y)/(xy) as previously stated. This reflects the orientation-reversing nature of inversion.

6. **p±1 law computational verification** extended to all odd primes ≤ 41, with formal proof of the quadratic residue criterion −1 ∈ (𝔽_p)² ⟺ p ≡ 1 (mod 4).

7. **New algebraic identities**: Cross-ratio preservation, SPB-hyperbolic duality (sum, product, difference formulas), cocycle identity, rapidity product formula, and the Lorentz factor factorization.

All results compile without `sorry` or non-standard axioms in Lean 4 with Mathlib.

---

### 1. Introduction

The SPB operation spb(x,y) = (x+y)/(1−xy) — the tangent addition formula viewed as an autonomous algebraic object — connects trigonometry, number theory, special relativity, and projective geometry through the Cayley transform C(x) = (1+ix)/(1−ix).

This paper addresses open questions from the original SPB research program, providing machine-verified proofs and identifying errors in previously stated results. We organize our contributions around seven Lean 4 files totaling approximately 600 lines of verified code.

---

### 2. Algebraic Identities (AlgebraicIdentities.lean)

#### 2.1 Cocycle Identity

**Theorem 2.1** (Cocycle). For all x, y, z ∈ ℝ with 1−xy ≠ 0, 1−yz ≠ 0:
$$(1 - xy)(1 - \text{spb}(x,y) \cdot z) = (1 - yz)(1 - x \cdot \text{spb}(y,z))$$

This identity is the algebraic heart of SPB associativity. It states that the "Jacobian cocycle" c(x,y) = 1/(1−xy) satisfies the group 2-cocycle condition, and is moreover a coboundary (trivial in H²), reflecting the fact that (ℝ, spb) ≅ (S¹, ·).

#### 2.2 Cross-Ratio Preservation

**Theorem 2.2** (Cross-Ratio). For a, b, c, d, t ∈ ℝ with appropriate non-degeneracy:
$$\frac{\text{spb}(a,t) - \text{spb}(b,t)}{\text{spb}(c,t) - \text{spb}(d,t)} = \frac{(a-b)(1-ct)(1-dt)}{(c-d)(1-at)(1-bt)}$$

This confirms that spb(·, t), as a Möbius transformation, preserves the projective structure of ℝP¹.

#### 2.3 SPB-Hyperbolic Duality

**Theorem 2.3** (Wick Rotation Identities). The circular SPB and hyperbolic SPB satisfy:
- Sum: spb(x,y) + spbH(x,y) = 2(x+y)/((1−xy)(1+xy))
- Product: spb(x,y) · spbH(x,y) = (x+y)²/((1−xy)(1+xy))
- Difference: spb(x,y) − spbH(x,y) = 2xy(x+y)/((1−xy)(1+xy))

These identities quantify the "Wick rotation" connecting circular and hyperbolic geometry.

#### 2.4 Corrected Reciprocal Law

**Theorem 2.5** (Reciprocal Law — Corrected). For x, y ∈ ℝ with x, y ≠ 0, xy ≠ 1:
$$\text{spb}(1/x, 1/y) = -\text{spb}(x, y)$$

*Note*: The previously stated identity spb(1/x, 1/y) = spb(x,y)/(xy) is **false**. Counterexample: spb(1/2, 1/3) = 1 but spb(2,3)/(2·3) = −1/6 ≠ 1. The correct identity follows from (1/x+1/y)/(1−1/(xy)) = (x+y)/(xy−1) = −(x+y)/(1−xy).

#### 2.5 Rapidity Product Formula

**Theorem 2.6**. For u, v with u,v ≠ 1, 1+uv ≠ 0:
$$\frac{1 + \text{spbH}(u,v)}{1 - \text{spbH}(u,v)} = \frac{1+u}{1-u} \cdot \frac{1+v}{1-v}$$

This shows that the "rapidity" ρ = ½ ln((1+v)/(1−v)) = artanh(v) is additive under Einstein velocity addition.

---

### 3. Machin Formula Classification (MachinClassification.lean)

#### 3.1 Three-Leaf Machin Theorem

**Theorem 3.1** (Three-Leaf Classification). The equation
$$\text{spb}\left(\text{spb}\left(\frac{1}{a}, \frac{1}{b}\right), \frac{1}{c}\right) = 1$$
with a, b, c ∈ ℤ, 2 ≤ a ≤ b ≤ c, has exactly three solutions:
- (a, b, c) = (2, 4, 13): encoding arctan(1/2) + arctan(1/4) + arctan(1/13) = π/4
- (a, b, c) = (2, 5, 8): encoding arctan(1/2) + arctan(1/5) + arctan(1/8) = π/4
- (a, b, c) = (3, 3, 7): encoding 2·arctan(1/3) + arctan(1/7) = π/4 (Hutton's formula)

*Proof strategy*: The equation reduces to (a+b)(c+1) = (ab−1)(c−1). From c ≥ b ≥ a we derive b²(a−3) ≤ 3b−1, forcing a ≤ 3. For each value of a, we factor the equation to enumerate solutions modulo divisibility constraints.

This resolves Open Question 5.3 from the original paper.

#### 3.2 Euler Optimality (Previously Known)

**Theorem 3.2**. spb(1/a, 1/b) = 1 with a, b ≥ 2, a ≤ b has unique solution (2, 3).

---

### 4. SPB Derivative Theory (Derivatives.lean)

#### 4.1 Full Chain Rule

**Theorem 4.1** (SPB Chain Rule). For differentiable f, g : ℝ → ℝ with f(t₀)g(t₀) ≠ 1:
$$\text{HasDerivAt}\left(t \mapsto \text{spb}(f(t), g(t)),\; \frac{f'(1+g^2) + g'(1+f^2)}{(1-fg)^2},\; t_0\right)$$

This is formalized using Mathlib's `HasDerivAt` infrastructure, composing the quotient rule with the product rule.

#### 4.2 Second Derivative

**Theorem 4.2**. The second derivative of x ↦ spb(x, a) is 2a(1+a²)/(1−xa)³.

#### 4.3 Hyperbolic Derivative

**Theorem 4.3**. The derivative of x ↦ spbH(x, a) is (1−a²)/(1+xa)².

*Observation*: For |a| < 1 (subluminal parameter), the derivative is positive — the velocity addition map is strictly increasing. For |a| > 1 (superluminal), the derivative is negative, reflecting the reversal of causality.

---

### 5. Cayley Transform (CayleyTransform.lean)

#### 5.1 Deep Properties

**Theorem 5.1**. The Cayley transform C(x) = (1+ix)/(1−ix) satisfies:
- |C(x)|² = 1 (unitarity)
- C is injective on ℝ
- C(spb(x,y)) = C(x)·C(y) (homomorphism)
- C(0) = 1, C(1) = i, C(−1) = −i

The injectivity proof uses the fact that C(x) = C(y) implies (1+ix)(1−iy) = (1+iy)(1−ix) by cross-multiplication, which yields 2ix = 2iy after expansion, hence x = y.

---

### 6. Tropical SPB (TropicalSPB.lean)

#### 6.1 Structure Theorem

The tropicalization tspb(x,y) = max(x,y) − max(0, x+y) has a rich but degenerate structure:

**Theorem 6.1** (Sign-Regime Decomposition).
- For x, y ≥ 0: tspb(x,y) = −min(x,y)
- For x, y ≤ 0: tspb(x,y) = max(x,y)
- tspb(x, 0) = 0 for all x (0 is an absorbing element, not an identity!)

**Theorem 6.2** (No Global Identity). There is no e ∈ ℝ such that tspb(x, e) = x for all x.

**Theorem 6.3** (Idempotency Dichotomy).
- tspb(x, x) = x for x ≤ 0 (idempotent)
- tspb(x, x) = −x for x ≥ 0 (anti-idempotent)

*Discussion*: The failure of a global identity element shows that the group structure of SPB is genuinely non-tropical — it cannot survive the passage to the tropical semiring. This is notable because the underlying circle group S¹ does have a nice tropical limit (the additive group ℝ under the valuation). The issue is that the stereographic projection, not the group operation, creates the obstruction.

**Open Question**: Is tspb associative? Our extensive testing found no counterexamples, despite the original paper's claim of non-associativity (the stated counterexample tspb(tspb(1,1),−1) ≠ tspb(1,tspb(1,−1)) evaluates to −1 = −1, which is actually equal). We conjecture that tspb IS associative.

---

### 7. Finite Fields (FiniteFields.lean)

#### 7.1 The p±1 Law

**Computational Verification**: The SPB group order over 𝔽_p divides p±1, verified for all odd primes p ≤ 41:
- p ≡ 3 (mod 4): order divides p+1 (verified for p = 3, 7, 11, 19, 23, 31)
- p ≡ 1 (mod 4): order divides p−1 (verified for p = 5, 13, 17, 29, 37, 41)

**Theorem 7.1** (Quadratic Residue Criterion). −1 is a square in 𝔽_p iff p ≡ 1 (mod 4), for odd primes p.

---

### 8. Power Formulas (PowerFormulas.lean)

#### 8.1 Multiple Angle Formulas

**Theorem 8.1** (Triple Angle). spb(spb(t,t), t) = (3t−t³)/(1−3t²)

**Theorem 8.2** (Quadruple Angle). spb(spb(t,t), spb(t,t)) = 4t(1−t²)/((1−t²)²−4t²)

**Correction**: The original paper claimed 5·arctan(1/5) = π/4 (equivalently spb⁵(1/5) = 1). This is **false**: 5·arctan(1/5) ≈ 0.987 ≠ π/4 ≈ 0.785. The correct identity involving 1/5 is Machin's formula: 4·arctan(1/5) − arctan(1/239) = π/4, verified as spb(spb(spb(1/5,1/5),spb(1/5,1/5)),−1/239) = 1.

---

### 9. New Research Directions

Based on our investigation, we propose the following prioritized research directions:

#### Tier 1: Immediate (1–3 months)

**9.1 Tropical SPB Associativity Conjecture** (★★★)
Prove or disprove: tspb(tspb(x,y),z) = tspb(x,tspb(y,z)) for all x,y,z ∈ ℝ. Our extensive computational testing found no counterexamples, contradicting the original paper's claim. A proof would establish tropical SPB as a commutative monoid (with absorbing element 0 rather than an identity). The sign-regime decomposition (Theorem 6.1) suggests a case-analysis proof with ≤ 27 cases.

**9.2 Full p±1 Law Proof** (★★★)
Formalize the Cayley transform over 𝔽_{p²} for p ≡ 3 (mod 4), showing the SPB group is isomorphic to the norm-1 subgroup of 𝔽_{p²}^×, which has order p+1 by Hilbert's Theorem 90. The p ≡ 1 case reduces to 𝔽_p^× via the Cayley transform within 𝔽_p.

**9.3 Four-Leaf and n-Leaf Machin Classification** (★★)
Extend Theorem 3.1 to classify all solutions of spb(spb(spb(1/a,1/b),1/c),1/d) = 1 with a ≤ b ≤ c ≤ d, all ≥ 2. The parametric approach (reducing to Diophantine equations) should extend, though the case analysis becomes more complex.

#### Tier 2: Medium-Term (3–12 months)

**9.4 SPB as a Formal Group Law** (★★★)
The SPB operation satisfies the axioms of a formal group law over ℤ: F(x,y) = (x+y)/(1−xy) = x + y + xy² + x²y + .... Formalize this connection and prove the SPB formal group is isomorphic to the multiplicative formal group Ĝₘ via the Cayley transform. This would connect SPB theory to the Lubin-Tate theory of local class field theory.

**9.5 SPB Equidistribution** (★★★)
Prove that orbits of x ↦ spb(x, a) are equidistributed with respect to the Cauchy measure when arctan(a)/π is irrational. The Cayley transform conjugates this to irrational rotation on S¹, where Weyl's equidistribution theorem applies. The main formalization challenge is the pushforward of the Cauchy measure through the Cayley transform.

**9.6 Quaternionic SPB and Thomas Precession** (★★★)
Define spb_Q(q₁, q₂) = (q₁ + q₂)(1 + q̄₁q₂)⁻¹ for quaternions. The non-commutativity defect spb_Q(q₁,q₂)·spb_Q(q₂,q₁)⁻¹ should be related to Thomas precession in special relativity.

**9.7 SPB Information Geometry** (★★)
Formalize the fact that SPB acts as isometries of the standard Cauchy distribution. The Cauchy family parametrized by location μ forms a statistical manifold with Fisher information metric equal to the Poincaré metric on the upper half-plane. SPB translations correspond to horizontal geodesics.

#### Tier 3: Long-Term (1–3 years)

**9.8 Elliptic SPB** (★★★★)
Replace the circle S¹ with an elliptic curve E. The "elliptic tangent addition" would arise from the Weierstrass ℘-function parameterization and would give a commutative formal group of height 1 or 2 depending on the curve. This connects to the theory of complex multiplication and the Shimura-Taniyama conjecture.

**9.9 p-adic SPB** (★★★)
Study SPB over ℚ_p. The p-adic Cayley transform maps ℤ_p to the p-adic unit circle {z ∈ ℚ_p(i) : |z| = 1}. For p ≡ 1 (mod 4), i ∈ ℚ_p and the analysis is straightforward. For p ≡ 3 (mod 4), one works in the quadratic extension ℚ_p(i).

**9.10 SPB and Conformal Field Theory** (★★★★)
SPB generates the rotation subgroup of PSL(2,ℝ), which acts on ℝP¹ = ∂ℍ². The Virasoro algebra is the unique central extension of the Lie algebra of smooth diffeomorphisms of S¹. Can the SPB cocycle c(x,y) = 1/(1−xy) be "quantized" to produce this central extension?

#### Tier 4: Speculative

**9.11 SPB Neural Networks**: Networks with activation σ(x) = spbH(x, w) inherit the group structure, ensuring invertibility and preventing gradient explosion. The bounded output |spbH| < 1 provides natural regularization.

**9.12 SPB Cryptography**: The SPB discrete log problem over 𝔽_p — given g and spbIter(g, n, 0), find n — reduces to the standard DLP via the Cayley transform, but the reduction itself is interesting.

**9.13 SPB Error-Correcting Codes**: The cyclic group structure of SPB(𝔽_p) with order p±1 provides code parameters complementary to Reed-Solomon codes (which use 𝔽_p^× of order p−1).

---

### 10. Summary of Formalized Results

| File | Theorems | Key Results |
|------|----------|-------------|
| Core.lean | 6 | Definitions and basic properties |
| AlgebraicIdentities.lean | 18 | Cocycle, cross-ratio, duality, reciprocal, rapidity |
| MachinClassification.lean | 9 | 2-leaf and 3-leaf classification, four-leaf examples |
| PowerFormulas.lean | 6 | Double/triple/quadruple angle, specific values |
| CayleyTransform.lean | 8 | Unitarity, injectivity, homomorphism, special values |
| TropicalSPB.lean | 9 | Sign decomposition, no identity, idempotency |
| FiniteFields.lean | ~15 | Quadratic residue, p±1 verification for 12 primes |
| Derivatives.lean | 6 | Chain rule, second derivative, hyperbolic derivative |
| **Total** | **~77** | **All compiled, zero sorry** |

### 11. Corrections to Previous Work

1. **spb(1/x, 1/y) = −spb(x,y)**, not spb(x,y)/(xy).
2. **5·arctan(1/5) ≠ π/4**: The identity tan(5·arctan(1/5)) = 1 is false. The correct Machin identity involving 1/5 is 4·arctan(1/5) − arctan(1/239) = π/4.
3. **Tropical SPB non-associativity unconfirmed**: The stated counterexample (1,1,−1) actually gives equal results on both sides. We conjecture associativity holds.

---

### 12. Conclusions

The SPB operation, despite its elementary definition, continues to yield new mathematical insights. Our formally verified investigation has resolved the three-leaf Machin classification, established the full derivative chain rule, corrected errors in previously stated results, and opened new research directions connecting SPB to formal group theory, information geometry, and tropical mathematics.

The methodology of machine-verified mathematics proves especially valuable for SPB theory, where the interplay of algebra, analysis, and number theory creates many opportunities for subtle computational errors — as evidenced by the corrections we identified. Every theorem in this paper carries absolute certainty through formal verification in Lean 4.

---

### References

1. A. Cayley, "Sur quelques propriétés des déterminants gauches," *J. Reine Angew. Math.* **32** (1846).
2. A. Einstein, "Zur Elektrodynamik bewegter Körper," *Ann. Phys.* **17** (1905).
3. The mathlib Community, "The Lean Mathematical Library," *CPP 2020*.
4. J. Todd, "The Lemniscate Constants," *Comm. ACM* **18** (1975).
5. H. Weyl, "Über die Gleichverteilung von Zahlen mod Eins," *Math. Ann.* **77** (1916).

---

*Accompanying materials: 7 Lean 4 files (~600 lines), all compiling with zero sorry statements.*
