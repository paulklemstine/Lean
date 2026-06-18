# Future Directions: Formal Hodge Theory

## Hypothesis 1: Rank-One Uniqueness for Polarized Structures

**Conjecture:** In a polarized weight-2 rational Hodge structure with Picard rank 1, any two nonzero Hodge classes are rational multiples of each other. Moreover, the polarization class itself is always a Hodge class when the polarization form satisfies the Hodge–Riemann bilinear relations.

**Test:** Formalize the Hodge–Riemann bilinear relations as a Lean predicate on `PolarizedHodgeStructure`. Then prove that under these relations, the polarization class `[ω]` (represented as a vector in V) satisfies `IsHodge11`. Combine with Theorem B1 to derive that `hodgeClasses = ℚ · [ω]`.

**Refutation:** Construct an abstract polarized Hodge structure where the polarization class does not lie in `hodgeClasses` — i.e., where `complexifyEmbed V [ω] ∉ H11.restrictScalars ℚ`. This would show that polarization alone does not determine the Hodge classes without additional geometric input.

**Impact:** If confirmed, this would formalize the complete classification of Picard-rank-1 Hodge structures and provide a machine-checked proof that the Hodge conjecture holds trivially at Picard rank 1 for polarized varieties.

---

## Hypothesis 2: Direct Sum Stability Without Cross-Terms

**Conjecture:** For the exterior product (wedge square) of two weight-1 Hodge structures W₁ and W₂, the Hodge classes of Λ²(W₁ ⊕ W₂) decompose as:

```
Hdg(Λ²(W₁ ⊕ W₂)) = Hdg(Λ²W₁) ⊕ Hdg(W₁ ⊗ W₂) ⊕ Hdg(Λ²W₂)
```

and the cross-term `Hdg(W₁ ⊗ W₂)` is zero when W₁ and W₂ have "no common Hodge type" (i.e., their Hodge numbers are generically incompatible).

**Test:** Define weight-1 Hodge structures in Lean (decomposition `V_ℂ = H^{1,0} ⊕ H^{0,1}`). Construct the induced weight-2 structure on Λ²(W₁ ⊕ W₂). Prove the decomposition formula above. Then prove that `Hdg(W₁ ⊗ W₂) = ⊥` under a suitable "no common factor" hypothesis on the Hodge numbers.

**Refutation:** Exhibit a pair of weight-1 Hodge structures whose tensor product has unexpected rational (1,1)-classes — i.e., construct explicit elements of `(W₁ ⊗ W₂) ∩ H^{1,1}` that are nonzero despite generic incompatibility. This would arise from hidden arithmetic relations between the two structures.

**Impact:** A positive result would formalize the main structural theorem behind the Hodge conjecture for products of elliptic curves and abelian varieties, providing a machine-checked foundation for one of the best-understood cases of the conjecture.

---

## Hypothesis 3: Transcendental Complement Determines the Hodge Structure

**Conjecture:** For a polarized weight-2 Hodge structure with symmetric nondegenerate form Q, the transcendental lattice Tr = Alg^⊥ uniquely determines the Hodge structure up to isomorphism of Hodge structures. More precisely, two polarized Hodge structures with isometric transcendental lattices are isomorphic as Hodge structures.

**Test:** Formalize a notion of "isomorphism of Hodge structures" in Lean (a ℚ-linear isomorphism respecting the Hodge decomposition after complexification). Prove that if φ: Tr₁ → Tr₂ is an isometry of transcendental lattices compatible with the Hodge filtration on transcendental parts, then φ extends to an isomorphism of full Hodge structures.

**Refutation:** Construct two polarized Hodge structures on the same underlying space with identical transcendental lattices but different algebraic parts — e.g., where the embedding of Tr into V differs between the two structures, leading to different H^{1,1} intersections.

**Impact:** This is a formal version of the global Torelli theorem for K3 surfaces. Proving it abstractly in the formal framework would demonstrate that the framework captures deep geometric classification results.

---

## Hypothesis 4: Computability of the Algebraicity Criterion

**Conjecture:** Given a weight-2 rational Hodge structure with explicitly computable Hodge decomposition (e.g., specified by matrices over ℚ(i) describing the projections to H^{2,0}, H^{1,1}, H^{0,2}), there exists a polynomial-time algorithm that:
1. Computes a basis for hodgeClasses,
2. Determines the Picard rank,
3. Tests whether a given finite set of vectors generates all Hodge classes.

**Test:** Formalize the computational model: a Hodge structure given by three projection matrices P₂₀, P₁₁, P₀₂ over ℚ(i) satisfying P₂₀ + P₁₁ + P₀₂ = I. Implement the extraction algorithm in Lean as a computable function (using `Decidable` instances). Prove correctness with respect to the abstract `hodgeClasses` definition.

**Refutation:** Show that computing `hodgeClasses` from the Hodge decomposition data requires solving a system over ℚ that does not have polynomial-time solutions in general — e.g., by reduction from a known hard linear algebra problem over number fields.

**Impact:** A positive result would bridge the formal framework to algorithmic algebraic geometry, enabling machine computation of Hodge-theoretic invariants with certified correctness guarantees.

---

## Hypothesis 5: Hodge Classes Under Field Extension

**Conjecture:** For a weight-2 Hodge structure defined over ℚ, the Hodge classes do not change under extension of the coefficient field from ℚ to any algebraic number field K — i.e., the natural map

```
Hdg(V) ⊗_ℚ K → (V ⊗_ℚ K) ∩ (H^{1,1} after base change)
```

is an isomorphism. This is the "absolute Hodge" property at the divisor level.

**Test:** Formalize the scalar extension of a Hodge structure from ℚ to a number field K in Lean. Define `hodgeClasses` for the base-changed structure. Prove that the natural inclusion `Hdg(V) ⊗_ℚ K ≤ Hdg(V_K)` is an equality for weight-2 structures. Use Mathlib's `NumberField` and `Algebra` infrastructure.

**Refutation:** Construct an explicit weight-2 Hodge structure where base change from ℚ to ℚ(√−1) creates new Hodge classes — i.e., vectors v ∈ V ⊗_ℚ ℚ(i) whose complexification lands in H^{1,1} but that cannot be written as K-linear combinations of vectors from V ∩ H^{1,1}.

**Impact:** This would formalize a key step in Deligne's proof that Hodge classes on abelian varieties are absolute Hodge. A formal proof would represent significant progress toward machine-checked verification of one of the deepest known results in Hodge theory.
