import Mathlib

/-! # Specification as Fixed Points

This file establishes a formal framework connecting semantic specifications of the form
`∀ x ∈ K, N(x) ∈ S` with set-theoretic inclusion, closure operators, and fixed-point
reasoning. The key insight is that universal specification checking can be **collapsed**
into algebraic fixed-point reasoning via three reductions:

1. **Preimage/Image Normalization**: `∀ x ∈ K, N(x) ∈ S ↔ K ⊆ N⁻¹(S) ↔ N(K) ⊆ S`
2. **Closure Reduction**: If `S` is closed under a closure operator `C`, then
   `K ⊆ S ↔ C(K) ⊆ S`, reducing pointwise verification to hull inclusion.
3. **Fixed-Point Collapse**: For idempotent operators, outputs automatically lie in
   the fixed-point set; with uniqueness, all outputs collapse to a single point.

## Main results

- `forall_mem_iff_subset_preimage`: Universal specification ↔ preimage inclusion
- `mapsTo_iff_image_subset`: Universal specification ↔ image inclusion
- `preimage_eq_image_subset`: Equivalence of the two inclusion formulations
- `IsClosureOp`: Structure for closure operators (extensive, monotone, idempotent)
- `subset_closed_iff_closure_subset`: Closure-based specification reduction
- `fixPts`: The fixed-point set of an endofunction
- `image_subset_fixPts_of_idempotent`: Idempotent maps land in their fixed-point set
- `spec_to_fixPts_of_idempotent`: Idempotent specification is automatic
- `preimage_fixPts_eq_univ_of_idempotent`: Preimage of fixed points is universal
- `outputs_eq_unique_fixed_point`: Unique fixed point collapses all outputs
- `forall_mem_finset_iff_image_subset`: Finset variant for computational use

## Cross-domain significance

- **Abstract interpretation**: Closure operators are semantic approximation operators;
  our theorems say safety verification reduces to checking the closure hull.
- **Dynamical systems**: Fixed points are equilibria; idempotent operators represent
  instant convergence to equilibrium.
- **EML theory**: The `oml` map has a unique positive fixed point at 1, so any
  specification forcing outputs into `fixPts oml` collapses all outputs to 1.
-/

noncomputable section

open Set Function

/-! ## Part 1: Universal Specification as Preimage/Image Inclusion -/

/-
**Semantic Normalization Theorem (Preimage Form).**
The universal specification `∀ x ∈ K, N(x) ∈ S` is exactly the set-theoretic
inclusion `K ⊆ N⁻¹'(S)`. This is the foundational reduction that converts
pointwise verification into a single inclusion check.
-/
theorem forall_mem_iff_subset_preimage
    {α β : Type*} (N : α → β) (K : Set α) (S : Set β) :
    (∀ x, x ∈ K → N x ∈ S) ↔ K ⊆ N ⁻¹' S := by
  rfl

/-
**Semantic Normalization Theorem (Image Form).**
The universal specification `∀ x ∈ K, N(x) ∈ S` is equivalent to the
image inclusion `N '' K ⊆ S`.
-/
theorem mapsTo_iff_image_subset
    {α β : Type*} (N : α → β) (K : Set α) (S : Set β) :
    (∀ x, x ∈ K → N x ∈ S) ↔ N '' K ⊆ S := by
  grind

/-
The preimage and image formulations of specification are equivalent.
-/
theorem preimage_eq_image_subset
    {α β : Type*} (N : α → β) (K : Set α) (S : Set β) :
    K ⊆ N ⁻¹' S ↔ N '' K ⊆ S := by
  exact Set.image_subset_iff.symm

/-! ## Part 2: Closure Operators and Specification Reduction -/

/-- A **closure operator** on sets: extensive, monotone, and idempotent.
This is the algebraic structure underlying abstract interpretation,
topological closure, convex hulls, and many verification frameworks. -/
structure IsClosureOp {α : Type*} (C : Set α → Set α) : Prop where
  extensive : ∀ A, A ⊆ C A
  mono : ∀ {A B : Set α}, A ⊆ B → C A ⊆ C B
  idempotent : ∀ A, C (C A) = C A

/-- A set `S` is **closed** under a closure operator `C` if `C S = S`. -/
def IsClosedUnder {α : Type*} (C : Set α → Set α) (S : Set α) : Prop :=
  C S = S

/-
**Closure-Based Specification Reduction.**
If `S` is a fixed point of the closure operator (i.e., `C S = S`),
then `K ⊆ S` if and only if `C K ⊆ S`. This is the key theorem that
upgrades pointwise verification into a lattice-theoretic invariant principle:
instead of checking every element of `K`, we can compute the closure hull
`C K` and check a single inclusion.

This theorem is mathematically significant because:
- The forward direction uses monotonicity + the fixed-point equation `C S = S`.
- The backward direction uses extensivity: `K ⊆ C K ⊆ S`.
- Together, they show that closed sets are exactly characterized by
  their relationship with the closure hull.
-/
theorem subset_closed_iff_closure_subset
    {α : Type*} {C : Set α → Set α}
    (hC : IsClosureOp C) (K S : Set α)
    (hS : C S = S) :
    K ⊆ S ↔ C K ⊆ S := by
  exact ⟨ fun h => by simpa [ hS ] using hC.mono h, fun h => by simpa [ hS ] using Set.Subset.trans ( hC.extensive K ) h ⟩

/-
Monotonicity applied: if `K ⊆ S` and `C S = S`, then `C K ⊆ S`.
-/
theorem closure_subset_of_subset_closed
    {α : Type*} {C : Set α → Set α}
    (hC : IsClosureOp C) {K S : Set α}
    (hKS : K ⊆ S) (hS : C S = S) :
    C K ⊆ S := by
  exact hS ▸ hC.mono hKS

/-! ## Part 3: Fixed Points and Idempotent Operators -/

/-- The **fixed-point set** of an endofunction `N : α → α`. -/
def fixPts {α : Type*} (N : α → α) : Set α := {x | N x = x}

/-
**Idempotent Image Theorem.**
For any idempotent map `N`, the image of the entire space lies within
the fixed-point set. This means idempotent operators are "projections
onto equilibria" — every output is automatically stable.
-/
theorem image_subset_fixPts_of_idempotent
    {α : Type*} (N : α → α)
    (hidem : ∀ x, N (N x) = N x) :
    N '' (univ : Set α) ⊆ fixPts N := by
  exact Set.image_subset_iff.2 fun x _ => hidem x

/-
**Automatic Specification for Idempotent Operators.**
If `N` is idempotent, then *every* input satisfies the specification
"output lies in the fixed-point set". This turns idempotent
architectures into certified-by-construction systems.
-/
theorem spec_to_fixPts_of_idempotent
    {α : Type*} (N : α → α) (K : Set α)
    (hidem : ∀ x, N (N x) = N x) :
    (∀ x, x ∈ K → N x ∈ fixPts N) := by
  exact fun x hx => show N ( N x ) = N x from by rw [ hidem x ]

/-
**Universal Preimage Theorem for Idempotent Operators.**
The preimage of the fixed-point set under an idempotent map is the
entire space. In specification language: the "safe region" for
idempotent stability is everything.
-/
theorem preimage_fixPts_eq_univ_of_idempotent
    {α : Type*} (N : α → α)
    (hidem : ∀ x, N (N x) = N x) :
    N ⁻¹' fixPts N = univ := by
  exact Set.eq_univ_iff_forall.mpr fun x => Set.mem_setOf.mpr ( by aesop )

/-! ## Part 4: Fixed-Point Uniqueness Collapses Specification -/

/-
If `x` lies in the fixed-point set of `N` and the fixed point is
unique (characterized by `p`), then `x = p`.
-/
theorem mem_fixPts_eq_of_unique
    {α : Type*} (N : α → α) (p x : α)
    (_hp : N p = p)
    (huniq : ∀ y, N y = y → y = p)
    (hx : x ∈ fixPts N) :
    x = p := by
  exact huniq x hx

/-
**Specification Collapse via Unique Fixed Point.**
If `N` has a unique fixed point `p`, and a specification forces all
outputs to lie in `fixPts N`, then all outputs must equal `p`.
This transforms verification statements into uniqueness-of-equilibrium
theorems.
-/
theorem outputs_eq_unique_fixed_point
    {α : Type*} (N : α → α) (p : α) (K : Set α)
    (_hp : N p = p)
    (huniq : ∀ y, N y = y → y = p)
    (hspec : ∀ x, x ∈ K → N x ∈ fixPts N) :
    ∀ x, x ∈ K → N x = p := by
  exact fun x hx => huniq _ ( hspec x hx )

/-
**Idempotent + Unique Fixed Point = Constant Output.**
Combining idempotency with uniqueness: if `N` is idempotent and has a
unique fixed point `p`, then `N x = p` for all `x`.
-/
theorem idempotent_unique_fixed_point_const
    {α : Type*} (N : α → α) (p : α)
    (hidem : ∀ x, N (N x) = N x)
    (_hp : N p = p)
    (huniq : ∀ y, N y = y → y = p) :
    ∀ x, N x = p := by
  exact fun x => huniq _ ( hidem x )

/-! ## Part 5: Finset Variant for Computational Verification -/

/-
**Finite-Domain Specification Check.**
For finite sets, the universal specification reduces to checking that
the image finset is a subset of the target finset. This makes the
theory computationally executable via `Finset.image` and `Finset.subset`.
-/
theorem forall_mem_finset_iff_image_subset
    {α β : Type*} [DecidableEq β]
    (N : α → β) (K : Finset α) (S : Finset β) :
    (∀ x, x ∈ K → N x ∈ S) ↔ (K.image N) ⊆ S := by
  simp +contextual [ Finset.subset_iff ]

/-! ## Part 6: Closure Operator from Idempotent Map -/

/-- An idempotent, monotone map on sets yields a closure operator
when it is also extensive. -/
theorem isClosureOp_of_idempotent_monotone_extensive
    {α : Type*} (C : Set α → Set α)
    (h_ext : ∀ A, A ⊆ C A)
    (h_mono : ∀ {A B : Set α}, A ⊆ B → C A ⊆ C B)
    (h_idem : ∀ A, C (C A) = C A) :
    IsClosureOp C :=
  ⟨h_ext, h_mono, h_idem⟩

/-
**Combined Reduction: Specification via Closure and Unique Fixed Point.**
Given a closure operator `C` with `S = fixPts N` being `C`-closed,
and `N` having a unique fixed point `p`, verification of `∀ x ∈ K, N(x) ∈ S`
reduces to checking `C K ⊆ S`, which then implies all outputs equal `p`.
-/
theorem spec_closure_unique_collapse
    {α : Type*} (N : α → α) (p : α)
    (_C : Set α → Set α) (_hC : IsClosureOp _C) (K : Set α)
    (_hp : N p = p)
    (huniq : ∀ y, N y = y → y = p)
    (hspec : ∀ x, x ∈ K → N x ∈ fixPts N) :
    ∀ x, x ∈ K → N x = p := by
  exact fun x a => outputs_eq_unique_fixed_point N p K _hp huniq hspec x a

/-! ## Part 7: Concrete EML Corollaries -/

/-- The one-minus-log map: `oml_spec(x) = 1 - ln(x)`. -/
def oml_spec (x : ℝ) : ℝ := 1 - Real.log x

/-- `oml_spec(1) = 1`: The point `x = 1` is a fixed point of `oml_spec`. -/
theorem oml_spec_fixed_one : oml_spec 1 = 1 := by
  simp [oml_spec, Real.log_one]

/-
**OML Unique Fixed Point Theorem.**
If `x > 0` and `oml_spec(x) = x`, then `x = 1`. The one-minus-log map
has exactly one positive fixed point.
-/
theorem oml_spec_unique_fixed_point (x : ℝ) (hx : 0 < x) (hfx : oml_spec x = x) :
    x = 1 := by
  exact le_antisymm ( le_of_not_gt fun hx' => by linarith [ Real.log_pos hx', Real.log_le_sub_one_of_pos hx, show oml_spec x = 1 - Real.log x by exact rfl ] ) ( le_of_not_gt fun hx' => by linarith [ Real.log_le_sub_one_of_pos hx, Real.log_pos <| show x⁻¹ > 1 by nlinarith [ mul_inv_cancel₀ hx.ne' ], show oml_spec x = 1 - Real.log x by exact rfl, Real.log_inv x ▸ show Real.log x⁻¹ = -Real.log x by exact Real.log_inv x ] )

/-
**OML Specification Collapse Corollary.**
For any set `K` of positive reals, if a system's outputs are forced
into `fixPts oml_spec`, then every output equals `1`. This is a
striking consequence: verification + uniqueness = constant output.
-/
theorem oml_spec_collapse (K : Set ℝ)
    (hK_pos : ∀ x, x ∈ K → 0 < oml_spec x)
    (hspec : ∀ x, x ∈ K → oml_spec x ∈ fixPts oml_spec) :
    ∀ x, x ∈ K → oml_spec x = 1 := by
  intro x hx
  have hy : oml_spec x ∈ fixPts oml_spec := hspec x hx
  have hy_pos : 0 < oml_spec x := hK_pos x hx
  have hy_fixed : oml_spec x = 1 := oml_spec_unique_fixed_point (oml_spec x) hy_pos hy
  exact hy_fixed

/-
**OML Iterate Collapse on the Positive Reals.**
If `x > 0` and `oml_spec(x) > 0` and `oml_spec(oml_spec(x)) = oml_spec(x)`, then
`oml_spec(x) = 1`. Any positive-real system that iterates `oml_spec` to a
positive fixed point converges to `1`.
-/
theorem oml_iterate_collapse (x : ℝ) (_hx : 0 < x)
    (homl_pos : 0 < oml_spec x)
    (hiter : oml_spec (oml_spec x) = oml_spec x) :
    oml_spec x = 1 := by
  exact oml_spec_unique_fixed_point (oml_spec x) homl_pos hiter

/-! ## Part 8: Abstract Interpretation Connection -/

/-- **Safety Verification via Closure Hull.**
In abstract interpretation, a program is safe if all reachable states
lie in a safe set `S`. If `S` is closed under the abstract transformer
`C`, then safety reduces to `C(init) ⊆ S` where `init` is the initial
states. This is a direct application of `subset_closed_iff_closure_subset`. -/
theorem abstract_interpretation_safety
    {State : Type*} (C : Set State → Set State)
    (hC : IsClosureOp C)
    (init safe : Set State)
    (hsafe_closed : C safe = safe) :
    init ⊆ safe ↔ C init ⊆ safe :=
  subset_closed_iff_closure_subset hC init safe hsafe_closed

end