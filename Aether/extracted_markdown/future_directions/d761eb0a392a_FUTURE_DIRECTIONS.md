# Future Directions: Formally Verified Galois Group Computation

This document outlines breakthrough research opportunities opened by the formal verification of Gal(X⁵ − X − 1 / ℚ) ≅ S₅.

---

## 1. Formal Dedekind Theorem for Unramified Primes

**Hypothesis**: Dedekind's theorem — connecting the factorization of a polynomial modulo an unramified prime p to the cycle type of the Frobenius element in the Galois group — can be fully formalized in Lean 4 using the existing Mathlib infrastructure for splitting fields, number fields, and local rings.

**Proof Strategy**:
- Formalize the notion of a Frobenius element at an unramified prime.
- Build on `Polynomial.SplittingField` and `NumberField` in Mathlib.
- Use the theory of completions and Hensel's lemma (partially available in Mathlib).
- Key technical challenge: connecting the global Galois group to the decomposition group at a prime.

**Impact**: This single theorem would unlock automated Galois group computation for *all* polynomials over ℚ, not just X⁵ − X − 1. It is the most impactful single formalization target.

**Cross-domain**: Connects algebraic number theory, commutative algebra, and computational algebra.

---

## 2. Generic S₅ Certification for Quintics

**Hypothesis**: For any monic irreducible f ∈ ℤ[X] of degree 5, if there exist primes p₁, p₂ (not dividing disc(f)) such that:
- f mod p₁ is irreducible over 𝔽_{p₁} (giving a 5-cycle), and
- f mod p₂ factors as (degree 2)(degree 3) over 𝔽_{p₂} (giving a (2,3)-cycle),
then Gal(f/ℚ) ≅ S₅.

**Proof Strategy**:
- Generalize our proof of `S5_of_30_dvd_not_alt` to a parametric theorem.
- Formalize the Dedekind theorem (Direction 1) and compose.
- The group theory is already done; the bottleneck is the arithmetic-to-permutation bridge.

**Deliverable**: A `galGroupIsS5` tactic or decision procedure for quintics.

---

## 3. Certified Galois Group Tactic for Low-Degree Polynomials

**Hypothesis**: A complete decision procedure for computing Galois groups of polynomials of degree ≤ 5 over ℚ can be formalized and certified.

**Proof Strategy**:
- Degree 1–3: classical formulas (quadratic formula, cubic resolvent).
- Degree 4: resolvent cubic analysis (distinguish S₄, A₄, D₄, V₄, C₄).
- Degree 5: combine Dedekind's theorem with transitive subgroup classification.
- Use `native_decide` for finite group calculations where possible.

**Impact**: First formally verified computer algebra system capability for Galois groups.

---

## 4. Explicit A₅ and Dihedral D₅ Quintic Examples

**Hypothesis**: Construct explicit quintic polynomials with Galois groups A₅ and D₅, and formally verify these identifications.

**Examples**:
- A₅: X⁵ − 5X + 12 (discriminant is a perfect square, Galois group is A₅).
- D₅: The minimal polynomial of 2cos(2π/11) has Galois group D₅.
- C₅: X⁵ − 1 (cyclotomic) has abelian Galois group.

**Proof Strategy**: Reuse the S₅ infrastructure but with different modular signatures.

---

## 5. Discriminant-Sign Theorem (Gal ≤ Aₙ iff disc is a square)

**Hypothesis**: The classical theorem "the Galois group is contained in Aₙ if and only if the discriminant is a perfect square in the base field" can be formalized.

**Proof Strategy**:
- Define δ = ∏_{i<j} (rᵢ − rⱼ) in the splitting field.
- Show σ(δ) = sign(σ) · δ for all σ ∈ Gal.
- Conclude: δ ∈ K iff Gal ≤ Aₙ, and δ ∈ K iff δ² = disc(f) is a square.
- Requires working with multivariate polynomials and symmetric functions.

**Impact**: Provides an alternative to Dedekind's theorem for the parity constraint, and is independently important for algebraic number theory.

---

## 6. Chebotarev Density and Frobenius Statistics

**Hypothesis**: Once the Dedekind theorem bridge exists, formal experiments on the distribution of Frobenius classes become possible.

**Next Steps**:
- Formalize the statement of the Chebotarev density theorem.
- Use computational experiments to verify Frobenius distributions for specific number fields.
- Build a certified prime-counting function that tracks factorization patterns.

**Cross-domain**: Connects analytic number theory, algebraic number theory, and computational mathematics.

---

## Priority Ranking

| Priority | Direction | Difficulty | Impact |
|----------|-----------|-----------|--------|
| 1 | Dedekind's Theorem | Very High | Transformative |
| 2 | Discriminant-Sign Theorem | High | High |
| 3 | Generic S₅ Certification | Medium | High |
| 4 | A₅ and D₅ Examples | Medium | Medium |
| 5 | Low-Degree Galois Tactic | High | Very High |
| 6 | Chebotarev Experiments | Very High | Research |

The Dedekind theorem formalization is the clear top priority: it is the single result that would transform a one-off computation into a general-purpose verified Galois group recognizer.
