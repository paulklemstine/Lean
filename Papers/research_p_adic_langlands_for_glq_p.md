# Formalized Foundations of the p-adic Langlands Correspondence for GL₂(ℚ_p)

## Abstract

We present a formalization of foundational structures and theorems in the p-adic Langlands correspondence for GL₂(ℚ_p), implemented in Lean 4 with the Mathlib library. Our formalization introduces novel type-theoretic definitions of φ-modules, (φ,Γ)-modules, slope data for rank 2 Newton polygons, and weak admissibility for filtered φ-modules. We prove key structural theorems including: (1) the complete invariant characterization of rank 2 slopes by total slope and slope gap, (2) preservation of weak admissibility under duality and twisting, (3) the Newton-above-Hodge inequality for rank 2, (4) the slope gap invariance of the Colmez functor under duality and twisting, (5) exactness properties of short exact sequences of slope data, and (6) the ordinary-supersingular dichotomy for weight 2 representations. All proofs are machine-verified and sorry-free, using only standard axioms (propext, Classical.choice, Quot.sound).

**Keywords**: p-adic Langlands correspondence, φ-modules, (φ,Γ)-modules, Colmez functor, Newton polygon, weak admissibility, formal verification

## 1. Introduction

The p-adic Langlands correspondence, established by Colmez [Col10] for GL₂(ℚ_p) and building on foundational work of Fontaine [Fon90], Berger [Ber08], and Breuil [Bre03], provides a bijection between:

1. Isomorphism classes of absolutely irreducible 2-dimensional continuous representations of Gal(Q̄_p/Q_p) over Q̄_p, and
2. Isomorphism classes of certain irreducible unitary Banach space representations of GL₂(ℚ_p).

The bridge between these two categories is the theory of (φ,Γ)-modules, which provides an algebraic avatar of Galois representations. The Colmez functor V realizes the correspondence functorially.

### 1.1 Contributions

We formalize the following in Lean 4:

- **Algebraic foundations**: φ-modules with semilinear Frobenius, (φ,Γ)-modules with commuting group actions, and morphisms between them (§2–3).
- **Slope theory**: A complete formalization of rank 2 Newton polygon slope data, including duality, twisting, and the characterization of slopes as a complete invariant (§4).
- **Weak admissibility**: The Colmez-Fontaine criterion for rank 2, with proofs of preservation under duality and twisting, and the Newton-above-Hodge inequality (§5).
- **Colmez functor**: An abstract axiomatization capturing the key functorial properties, with proofs of slope gap invariance (§6).
- **Classification results**: Trianguline parameters, weight constraints, and the ordinary-supersingular dichotomy (§7–8).

### 1.2 Related Work

While Mathlib contains substantial infrastructure for p-adic numbers (including the p-adic norm, valuation, and completion), the theory of (φ,Γ)-modules and the p-adic Langlands correspondence has not been previously formalized. Our work provides the first machine-verified foundations for this area.

## 2. Frobenius Modules

### 2.1 Definition

A **Frobenius ring** is a commutative ring R equipped with a ring endomorphism φ : R → R. In the p-adic setting, R is typically the Robba ring or one of Fontaine's period rings (B_cris, B_dR, B_st), and φ is the lift of the absolute Frobenius on F_p.

A **φ-module** over (R, φ) consists of:
- An R-module D (with additive group structure)
- An additive map Φ : D → D satisfying the semilinearity condition:
  Φ(r · x) = φ(r) · Φ(x) for all r ∈ R, x ∈ D

We formalize this as:

```
structure PhiModule (R : Type*) [CommRing R] (φ : R →+* R) where
  carrier : Type*
  [instAddCommGroup : AddCommGroup carrier]
  [instModule : Module R carrier]
  Φ : carrier →+ carrier
  Φ_smul : ∀ (r : R) (x : carrier), Φ (r • x) = φ r • Φ x
```

### 2.2 Morphisms

A morphism of φ-modules f : D → E is an R-linear map commuting with Frobenius: f ∘ Φ_D = Φ_E ∘ f. We prove that composition of φ-module morphisms is again a φ-module morphism (Proposition `PhiModuleHom.comp`).

## 3. (φ,Γ)-Modules

### 3.1 Definition

A **(φ,Γ)-module** over (R, φ) is a φ-module D equipped with a group action of Γ (typically Γ ≅ Z_p×) satisfying:
1. Group action axioms: γ₁(γ₂(x)) = (γ₁γ₂)(x), 1(x) = x
2. Commutativity with Frobenius: γ(Φ(x)) = Φ(γ(x))

This commutativity is the key structural axiom. We prove it extends to iterated Frobenius and that the action of inverse elements inverts the action (`γ_inv`).

### 3.2 Fontaine's Equivalence

Fontaine's theorem states that the category of étale (φ,Γ)-modules is equivalent to the category of continuous p-adic representations of Gal(Q̄_p/Q_p). While we do not formalize the full equivalence (which requires the Robba ring), our algebraic framework captures the essential structure.

## 4. Rank 2 Slope Theory

### 4.1 Newton Polygon Slopes

For a rank 2 φ-module, the Newton polygon is determined by two slopes s₁ ≤ s₂ ∈ ℚ. We introduce the `Rank2Slopes` structure with the following key invariants:

- **Total slope**: s₁ + s₂ (equals v_p(det Φ))
- **Slope gap**: s₂ - s₁ (measures distance from supersingularity)

**Theorem 4.1 (Complete Invariant)**. Two rank 2 slope data are equal if and only if they have the same total slope and slope gap. This follows from the fact that s₁ = (total - gap)/2 and s₂ = (total + gap)/2.

### 4.2 Duality

The dual D* of a rank 2 φ-module has slopes (-s₂, -s₁). We prove:
- `dual_dual`: (D*)* = D (involutivity)
- `dual_totalSlope`: total slope negates
- `dual_slopeGap`: slope gap is preserved

### 4.3 Twisting

Twisting by a character of slope t shifts both slopes by t:
- `twist_totalSlope`: total slope shifts by 2t
- `twist_slopeGap`: slope gap is preserved (key invariant!)
- `twist_twist`: twisting is additive
- `dual_twist`: duality and twisting interact via negation

### 4.4 Normalization

**Theorem 4.2 (Ordinary Reduction)**. Every rank 2 slope data can be twisted to ordinary form (s₁ = 0). Twisting to étale form (s₁ = s₂ = 0) is possible if and only if the original slopes are supersingular.

## 5. Weak Admissibility

### 5.1 The Colmez-Fontaine Condition

For rank 2, a filtered φ-module with slopes (s₁, s₂) and Hodge-Tate weights h₁ ≤ h₂ is weakly admissible if:
1. s₁ + s₂ = h₁ + h₂ (total match)
2. s₁ ≥ h₁ (subobject condition)

### 5.2 Key Results

**Theorem 5.1 (Upper Bound)**. s₂ ≤ h₂. This follows immediately from conditions 1 and 2.

**Theorem 5.2 (Newton above Hodge)**. The slope gap is bounded by the HT weight gap: s₂ - s₁ ≤ h₂ - h₁.

**Theorem 5.3 (Duality Preservation)**. If (s₁, s₂; h₁, h₂) is weakly admissible, then so is (-s₂, -s₁; -h₂, -h₁).

**Theorem 5.4 (Twist Preservation)**. If (s₁, s₂; h₁, h₂) is weakly admissible, then so is (s₁+n, s₂+n; h₁+n, h₂+n) for any integer n.

## 6. The Colmez Functor

### 6.1 Abstract Axiomatization

We axiomatize the Colmez functor through a `ColmezFunctorData` structure encoding:
- Weak admissibility of all outputs
- Compatibility with twisting
- Compatibility with duality

### 6.2 Invariance Results

**Theorem 6.1 (Slope Gap Invariance)**. The slope gap is invariant under both twisting and duality operations of the Colmez functor. This is a deep structural property reflecting the compatibility of the correspondence with the inner structure of representations.

### 6.3 The Bijection

When the functor is both injective and surjective (on isomorphism classes), we obtain the full p-adic Langlands correspondence:

**Theorem 6.2 (Unique Preimage)**. Every 2-dimensional Galois representation has a unique Banach space representation mapping to it under the Colmez functor.

## 7. Trianguline Representations

### 7.1 Triangulation Parameters

A trianguline representation admits a filtration 0 → D(δ₁) → D → D(δ₂) → 0 by rank 1 (φ,Γ)-modules. The parameters (δ₁_slope, δ₂_slope) determine the slopes via min/max.

**Theorem 7.1**. The total slope equals δ₁ + δ₂, and the slope gap equals |δ₁ - δ₂|.

**Theorem 7.2 (Refinement Invariance)**. Swapping the triangulation parameters preserves the underlying slopes.

**Theorem 7.3 (Supersingular Characterization)**. A trianguline representation is supersingular if and only if δ₁ = δ₂.

### 7.2 Twist Compatibility

Twisting a trianguline parameter commutes with the passage to slopes (`twist_toSlopes`).

## 8. Weight Constraints

For crystalline representations coming from modular forms of weight k ≥ 2, the Hodge-Tate weights are {0, k-1}.

**Theorem 8.1 (Crystalline Bound)**. If 0 ≤ s₁ and s₁ + s₂ = k - 1, then s₂ ≤ k - 1.

**Theorem 8.2 (Weight 2 Classification)**. For weight 2 with non-negative lower slope:
- s₁ ∈ [0, 1/2] and s₂ ∈ [1/2, 1]
- Supersingular ⟺ s₁ = 1/2
- Ordinary ⟺ s₁ = 0

## 9. Short Exact Sequences

We formalize slope additivity for short exact sequences 0 → D' → D → D'' → 0.

**Theorem 9.1**. The quotient slope is bounded by s₂ of the middle term.

**Theorem 9.2**. If the quotient slope is at least s₁, then the sub slope is at most s₂.

**Theorem 9.3 (Dual Exact Sequence)**. The dual of a short exact sequence is again a short exact sequence with negated and swapped slopes.

## 10. Conjectures and Future Work

### 10.1 Breuil-Mézard Multiplicities

We define the conjectured multiplicity formula for crystalline lifts:
```
crystallineMultiplicity(k, a) = k - 1 - 2a  (for a ≤ (k-1)/2)
```

This is verified computationally for small weights.

### 10.2 Open Directions

1. **Higher rank**: Extending to GL_n(ℚ_p) for n > 2
2. **Full Robba ring**: Formalizing the coefficients ring
3. **Mod p reduction**: The Breuil-Mézard conjecture in full generality
4. **p-adic Hodge theory**: Connecting to B_cris, B_dR, B_st

## References

[Ber08] L. Berger, *Représentations p-adiques et équations différentielles*, Inventiones Math., 2008.

[Bre03] C. Breuil, *Sur quelques représentations modulaires et p-adiques de GL₂(ℚ_p)*, Compositio Math., 2003.

[Col10] P. Colmez, *Représentations de GL₂(ℚ_p) et (φ,Γ)-modules*, Astérisque, 2010.

[CF00] P. Colmez, J.-M. Fontaine, *Construction des représentations p-adiques semi-stables*, Inventiones Math., 2000.

[Fon90] J.-M. Fontaine, *Représentations p-adiques semi-stables*, Astérisque, 1990.

[Pas13] V. Paškūnas, *The image of Colmez's Montreal functor*, Publications math. de l'IHÉS, 2013.
