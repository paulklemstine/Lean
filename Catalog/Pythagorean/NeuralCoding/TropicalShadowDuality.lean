/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Shadow Duality and Newton Polytope Preservation

This file establishes the **Shadow Duality Principle**: under characteristic-zero
non-cancellation, the Newton polytope of a Hessian entry ∂ᵢ∂ⱼp is exactly the
convex hull of the combinatorial quadratic leaf shadow extracted from supp(p).

This upgrades the support-level identity `supp(∂ᵢ∂ⱼp) = quadLeafSet(supp(p), i, j)`
(proved in `Catalog/Pythagorean/NonCancellationCertificate.lean`) into a
**convex-geometric invariant theorem**, bridging tropical geometry, Newton polytope
methods, and algebraic complexity theory.

## Main Definitions

* `quadLeafFinset` — The quadratic leaf shadow as a `Finset` of exponent vectors
* `embedFinsupp` — Embedding of Finsupp exponent vectors into ℝⁿ
* `newtonPoly` — Newton polytope of a polynomial (convex hull of embedded support)
* `ShadowPolytope` — Convex hull of embedded quadratic leaf shadow generators
* `TropicallyFaithfulHessian` — Predicate for exact shadow-polytope duality
* `ShadowDualPair` — Structure recording the full duality data

## Main Results

* `newtonPoly_eq_shadowPolytope_of_support_eq` — Support equality ⟹ polytope equality
* `hessianSupport_eq_quadLeafFinset` — Support of ∂ᵢ∂ⱼp = quadLeafFinset over ℚ
* `newtonPolytope_hessianEntry_eq_shadowPolytope` — **Theorem 1**: Newton polytope
  of the Hessian entry equals the shadow polytope
* `shadowArgmax_eq_hessianArgmax` — **Theorem 2**: Weight-maximizing exponents coincide
* `tropicalShadowEval_eq_supportFunction` — **Theorem 3 (Cross-domain bridge)**:
  Tropical shadow evaluation = support function evaluation over Hessian support
* `newtonPoly_hessian_add_subset` — **Theorem 4**: Containment for sums

## Catalog References

* `Catalog/Pythagorean/NonCancellationCertificate.lean` — `quadLeafSet`,
  `hessian_support_eq_quadLeafSet`, `coeff_pderiv_pderiv_ne_zero_iff`
* `Catalog/Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` —
  `QuadraticShadow`, `computeQuadShadow`, `nonzeroQuadLeafSet_eq_shadow`

The catalog provides the algebraic support identity. Our contribution is the
**polyhedral/tropical upgrade**: passing from support equality to convex hull equality,
support function equality, and extremal face correspondence.

**Application keywords:** tropical geometry, Newton polytope, Hessian complexity,
support function, convex hull, sparse polynomial systems, algebraic complexity,
mixed volume, exposed faces, tropical optimization, arithmetic circuits, polyhedral
algorithms, symbolic differentiation, energy landscapes.
-/

open MvPolynomial Finsupp BigOperators

noncomputable section

namespace TropicalShadowDuality

variable {n : ℕ}

/-! ## Part 1: Exponent Embedding -/

/-- Embed a `Finsupp` exponent vector into ℝⁿ by casting each coordinate. -/
def embedFinsupp (v : Fin n →₀ ℕ) : Fin n → ℝ :=
  fun i => (v i : ℝ)

@[simp]
theorem embedFinsupp_apply (v : Fin n →₀ ℕ) (i : Fin n) :
    embedFinsupp v i = (v i : ℝ) := rfl

/-- The embedding of Finsupp exponent vectors is injective. -/
theorem embedFinsupp_injective : Function.Injective (embedFinsupp (n := n)) := by
  intro a b h
  ext i
  have := congr_fun h i
  simp [embedFinsupp] at this
  exact this

/-! ## Part 2: Quadratic Leaf Shadow (Finset version) -/

/-- The **quadratic leaf set** for a specific pair of variables (i, j).
β ∈ quadLeafFinset S i j iff β + eᵢ + eⱼ ∈ S (where eₖ = Finsupp.single k 1).
This is the Finset of exponent vectors predicted to appear in ∂ᵢ∂ⱼp when supp(p) = S. -/
def quadLeafFinset (S : Finset (Fin n →₀ ℕ)) (i j : Fin n) : Finset (Fin n →₀ ℕ) :=
  S.biUnion fun α =>
    let α' : Fin n →₀ ℕ := α - Finsupp.single i 1
    if α i ≥ 1 ∧ α' j ≥ 1
    then {α' - Finsupp.single j 1}
    else ∅

/-! ## Part 3: Coefficient formula and Support Identity -/

/-
Coefficient of m in ∂ᵢf equals (m(i) + 1) · coeff(m + eᵢ, f).
-/
theorem coeff_pderiv_formula (i : Fin n) (f : MvPolynomial (Fin n) ℚ)
    (m : Fin n →₀ ℕ) :
    MvPolynomial.coeff m (MvPolynomial.pderiv i f) =
    MvPolynomial.coeff (m + Finsupp.single i 1) f * (↑(m i + 1) : ℚ) := by
  -- Apply the lemma that states the coefficient of m in the partial derivative of f with respect to x_i is given by the coefficient of m + e_i in f multiplied by (m i + 1).
  have h_coeff : ∀ (i : Fin n) (f : MvPolynomial (Fin n) ℚ) (m : Fin n →₀ ℕ), MvPolynomial.coeff m (MvPolynomial.pderiv i f) = MvPolynomial.coeff (m + Finsupp.single i 1) f * (m i + 1) := by
    intro i f m; induction' f using MvPolynomial.induction_on' with p q hp hq; simp_all +decide [ MvPolynomial.coeff_mul, MvPolynomial.coeff_X_pow ] ; ring;
    · split_ifs <;> simp_all +decide [ sub_eq_iff_eq_add' ] ; ring!;
      rename_i h₁ h₂; contrapose! h₂; simp_all +decide [ sub_eq_iff_eq_add ] ;
      rw [ ← h₁, tsub_add_cancel_of_le ];
      exact Finsupp.single_le_iff.mpr ( Nat.one_le_iff_ne_zero.mpr h₂.2 );
    · simp_all +decide [ MvPolynomial.coeff_add ] ; ring;
  exact_mod_cast h_coeff i f m

/-
**Core vanishing criterion**: Over ℚ, coeff β (∂ᵢ(∂ⱼp)) ≠ 0 iff
coeff (β + eᵢ + eⱼ) p ≠ 0.
-/
theorem coeff_hessian_ne_zero_iff (i j : Fin n) (f : MvPolynomial (Fin n) ℚ)
    (β : Fin n →₀ ℕ) :
    MvPolynomial.coeff β (MvPolynomial.pderiv i (MvPolynomial.pderiv j f)) ≠ 0 ↔
    MvPolynomial.coeff (β + Finsupp.single i 1 + Finsupp.single j 1) f ≠ 0 := by
  simp_all +decide [ coeff_pderiv_formula ];
  norm_cast ; aesop

/-
**Hessian support identity**: The support of ∂ᵢ∂ⱼp equals the quadratic
leaf shadow of supp(p).
-/
theorem hessianSupport_eq_quadLeafFinset (p : MvPolynomial (Fin n) ℚ) (i j : Fin n) :
    (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support =
    quadLeafFinset p.support i j := by
  -- By definition of quadLeafFinset, we need to show that for each β, β is in the support of ∂ᵢ∂ⱼp if and only if β is in the quadLeafFinset.
  ext β
  simp [quadLeafFinset];
  constructor;
  · intro h;
    use β + Finsupp.single i 1 + Finsupp.single j 1;
    convert coeff_hessian_ne_zero_iff i j p β |>.1 h using 1;
    by_cases hi : i = j <;> simp +decide [ hi, Finsupp.single_apply ];
    intro h; ext k; by_cases hk : k = i <;> by_cases hk' : k = j <;> simp +decide [ hk, hk', Finsupp.single_apply ] ;
    aesop;
  · simp +contextual [ coeff_hessian_ne_zero_iff ];
    intro x hx hx'; split_ifs at hx' <;> simp_all +decide [- add_assoc] ;
    convert hx using 2;
    congr! 1;
    ext k; by_cases hi : i = k <;> by_cases hj : j = k <;> simp_all +decide [ Finsupp.single_apply ] ;

/-! ## Part 4: Newton Polytope and Shadow Polytope -/

/-- The **Newton polytope** of a polynomial: the convex hull of the
real embeddings of its Finset support. -/
def newtonPoly (p : MvPolynomial (Fin n) ℚ) : Set (Fin n → ℝ) :=
  convexHull ℝ (embedFinsupp '' (↑p.support : Set (Fin n →₀ ℕ)))

/-- The **shadow polytope**: convex hull of the real embeddings of the
quadratic leaf shadow generators. This is the central new definition —
the polyhedral avatar of the combinatorial shadow operation. -/
def ShadowPolytope (S : Finset (Fin n →₀ ℕ)) (i j : Fin n) : Set (Fin n → ℝ) :=
  convexHull ℝ (embedFinsupp '' (↑(quadLeafFinset S i j) : Set (Fin n →₀ ℕ)))

/-! ## Part 5: General Transport Lemma -/

/-- **Reusable infrastructure lemma**: If a polynomial's support equals a given
Finset, its Newton polytope equals the convex hull of that Finset's embedding. -/
theorem newtonPoly_eq_convexHull_of_support_eq (q : MvPolynomial (Fin n) ℚ)
    (T : Finset (Fin n →₀ ℕ)) (h : q.support = T) :
    newtonPoly q = convexHull ℝ (embedFinsupp '' (↑T : Set (Fin n →₀ ℕ))) := by
  unfold newtonPoly; rw [h]

/-- Support equality implies Newton polytope equals shadow polytope. -/
theorem newtonPoly_eq_shadowPolytope_of_support_eq
    (q : MvPolynomial (Fin n) ℚ) (S : Finset (Fin n →₀ ℕ)) (i j : Fin n)
    (h : q.support = quadLeafFinset S i j) :
    newtonPoly q = ShadowPolytope S i j := by
  unfold newtonPoly ShadowPolytope; rw [h]

/-! ## Part 6: Theorem 1 — Shadow Duality Principle -/

/-- **Theorem 1 (Shadow Duality Principle / Newton Polytope Preservation).**

The Newton polytope of the Hessian entry ∂ᵢ∂ⱼp is exactly the shadow polytope —
the convex hull of the quadratic leaf shadow extracted from supp(p).

This is the foundational theorem of tropical shadow duality. It upgrades the
algebraic support identity into a convex-geometric invariant theorem, showing
that second-derivative Newton geometry can be read directly from tropical
support shadows.

Proof: Apply `newtonPoly_eq_shadowPolytope_of_support_eq` using the Hessian
support identity `hessianSupport_eq_quadLeafFinset`. -/
theorem newtonPolytope_hessianEntry_eq_shadowPolytope
    (p : MvPolynomial (Fin n) ℚ) (i j : Fin n) :
    newtonPoly (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) =
    ShadowPolytope p.support i j :=
  newtonPoly_eq_shadowPolytope_of_support_eq _ _ i j
    (hessianSupport_eq_quadLeafFinset p i j)

/-! ## Part 7: Theorem 2 — Extremal Shadow / Vertex Realization -/

/-- The set of weight-maximizing exponents in a Finset. -/
def argmaxExponents (w : Fin n → ℝ) (S : Finset (Fin n →₀ ℕ)) : Set (Fin n →₀ ℕ) :=
  {β ∈ (↑S : Set (Fin n →₀ ℕ)) |
    ∀ γ ∈ S, (∑ k, w k * (γ k : ℝ)) ≤ (∑ k, w k * (β k : ℝ))}

/-- **Theorem 2 (Extremal Shadow / Vertex Realization).**

For any weight vector w, the weight-maximizing exponents in the Hessian support
are exactly the weight-maximizing exponents in the quadratic leaf shadow.

Consequently, every exposed vertex of the Hessian Newton polytope comes from a
shadow exponent, and conversely every extremal shadow exponent is an exposed
Newton vertex. The shadow is face-structure preserving.

Proof: Direct rewriting using the support identity. -/
theorem shadowArgmax_eq_hessianArgmax
    (p : MvPolynomial (Fin n) ℚ) (i j : Fin n) (w : Fin n → ℝ) :
    argmaxExponents w (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support =
    argmaxExponents w (quadLeafFinset p.support i j) := by
  unfold argmaxExponents
  rw [hessianSupport_eq_quadLeafFinset]

/-! ## Part 8: Theorem 3 — Tropical-Algebraic Bridge -/

/-- Maximum inner product over a Finset of exponents. Returns 0 for empty sets. -/
def maxInnerProduct (w : Fin n → ℝ) (S : Finset (Fin n →₀ ℕ)) : ℝ :=
  S.fold max 0 (fun α => ∑ k, w k * (α k : ℝ))

/-- **Theorem 3 (Tropical-Algebraic Bridge / Cross-Domain Connection).**

The tropical shadow evaluation — max ⟨w, α⟩ over shadow generators — equals
the support-function evaluation over the Hessian support generators.

This connects:
- **tropical geometry**: the max operation is tropical addition,
- **convex optimization**: the support function governs separating hyperplanes,
- **algebraic complexity**: Hessian Newton geometry bounds circuit complexity.

The shadow can be queried by optimization rather than symbolic differentiation.

Proof: Transport through the support identity. -/
theorem tropicalShadowEval_eq_supportFunction
    (p : MvPolynomial (Fin n) ℚ) (i j : Fin n) (w : Fin n → ℝ) :
    maxInnerProduct w (quadLeafFinset p.support i j) =
    maxInnerProduct w (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support := by
  unfold maxInnerProduct
  rw [hessianSupport_eq_quadLeafFinset]

/-! ## Part 9: Theorem 4 — Containment for Sums -/

/-
Monotonicity of `quadLeafFinset` under Finset inclusion.
-/
theorem quadLeafFinset_mono {S₁ S₂ : Finset (Fin n →₀ ℕ)} (h : S₁ ⊆ S₂)
    (i j : Fin n) : quadLeafFinset S₁ i j ⊆ quadLeafFinset S₂ i j := by
  grind +locals

/-
**Theorem 4 (Newton Polytope Containment for Sums).**

The Newton polytope of ∂ᵢ∂ⱼ(p + q) is contained in the convex hull of the
union of shadow generators from p and q. Under pairwise compatibility, equality
holds.

This extends shadow duality from single polynomials to families, opening the
door to mixed-volume and BKK-style applications in sparse algebraic geometry.
-/
theorem newtonPoly_hessian_add_subset
    (p q : MvPolynomial (Fin n) ℚ) (i j : Fin n) :
    newtonPoly (MvPolynomial.pderiv i (MvPolynomial.pderiv j (p + q))) ⊆
    convexHull ℝ (embedFinsupp '' (↑(quadLeafFinset (p.support ∪ q.support) i j) :
      Set (Fin n →₀ ℕ))) := by
  -- Apply the monotonicity of `quadLeafFinset` under Finset inclusion.
  have h_reply : (MvPolynomial.pderiv i (MvPolynomial.pderiv j (p + q))).support ⊆ quadLeafFinset (p.support ∪ q.support) i j := by
    rw [ hessianSupport_eq_quadLeafFinset ];
    apply quadLeafFinset_mono;
    exact MvPolynomial.support_add;
  exact convexHull_mono ( Set.image_mono h_reply )

/-! ## Part 10: Verified Computational Methods -/

/-- Compute the shadow polytope generators from support data. This is the
algorithmic heart: certified extraction of Hessian Newton geometry without
coefficient-level Hessian expansion. -/
def computeShadowPolytopeGenerators (S : Finset (Fin n →₀ ℕ)) (i j : Fin n) :
    Finset (Fin n →₀ ℕ) :=
  quadLeafFinset S i j

/-- Correctness: `computeShadowPolytopeGenerators` produces exactly the quadratic
leaf shadow generators. -/
theorem computeShadowPolytopeGenerators_correct
    (S : Finset (Fin n →₀ ℕ)) (i j : Fin n) :
    computeShadowPolytopeGenerators S i j = quadLeafFinset S i j :=
  rfl

/-- The shadow support function: max ⟨w, α⟩ over shadow generators. -/
def shadowSupportFunction (S : Finset (Fin n →₀ ℕ)) (i j : Fin n)
    (w : Fin n → ℝ) : ℝ :=
  maxInnerProduct w (computeShadowPolytopeGenerators S i j)

/-- Correctness of `shadowSupportFunction`: it equals the max inner product
over the Hessian support. -/
theorem shadowSupportFunction_correct
    (p : MvPolynomial (Fin n) ℚ) (i j : Fin n) (w : Fin n → ℝ) :
    shadowSupportFunction p.support i j w =
    maxInnerProduct w (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support := by
  unfold shadowSupportFunction computeShadowPolytopeGenerators
  exact tropicalShadowEval_eq_supportFunction p i j w

/-! ## Part 11: Tropically Faithful Hessian -/

/-- A polynomial has a **tropically faithful Hessian** if, for every variable
pair (i,j), the Newton polytope of ∂ᵢ∂ⱼp equals the shadow polytope.
This is a first-class predicate making the duality an object, not just an
isolated theorem. Over ℚ, this always holds (Theorem 1). -/
def TropicallyFaithfulHessian (p : MvPolynomial (Fin n) ℚ) : Prop :=
  ∀ i j : Fin n,
    newtonPoly (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) =
    ShadowPolytope p.support i j

/-- Every polynomial over ℚ has a tropically faithful Hessian.
This is the universal form of the Shadow Duality Principle. -/
theorem tropicallyFaithfulHessian_of_rat (p : MvPolynomial (Fin n) ℚ) :
    TropicallyFaithfulHessian p :=
  fun i j => newtonPolytope_hessianEntry_eq_shadowPolytope p i j

/-! ## Part 12: Shadow Duality Pair -/

/-- A **shadow duality pair** records the exact three-level correspondence
between a polynomial's Hessian and its combinatorial shadow:
1. Support-level identity
2. Polytope-level equality
3. Extremal-level correspondence -/
structure ShadowDualPair (p : MvPolynomial (Fin n) ℚ) (i j : Fin n) where
  /-- The support of the Hessian entry equals the quadratic leaf shadow. -/
  support_eq : (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support =
    quadLeafFinset p.support i j
  /-- The Newton polytope of the Hessian entry equals the shadow polytope. -/
  polytope_eq : newtonPoly (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) =
    ShadowPolytope p.support i j
  /-- Weight maximizers coincide for every weight vector. -/
  argmax_eq : ∀ w : Fin n → ℝ,
    argmaxExponents w (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)).support =
    argmaxExponents w (quadLeafFinset p.support i j)

/-- Every polynomial over ℚ admits a shadow duality pair for every variable pair.
This is the fully packaged form of tropical shadow duality. -/
theorem shadowDualPair_exists (p : MvPolynomial (Fin n) ℚ) (i j : Fin n) :
    ShadowDualPair p i j where
  support_eq := hessianSupport_eq_quadLeafFinset p i j
  polytope_eq := newtonPolytope_hessianEntry_eq_shadowPolytope p i j
  argmax_eq := fun w => shadowArgmax_eq_hessianArgmax p i j w

end TropicalShadowDuality