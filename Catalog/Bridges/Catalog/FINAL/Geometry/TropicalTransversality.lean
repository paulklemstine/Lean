/-
# Tropical Transversality: Corner Loci of Max-Affine Functions

This file formalizes a finite-dimensional, piecewise-linear transversality principle
for max-affine (tropical) functions. For a finite family of affine functions
  ℓ_i(x) = ⟨w_i, x⟩ + b_i
we study the "corner locus" where at least two pieces tie for the maximum,
and prove that under natural nondegeneracy hypotheses the tie strata are
affine subspaces of the expected codimension.

## Main results

* `tieSet_eq_preimage` — the tie set for an index set `s` equals the preimage
  of a constant under a linear map built from difference vectors.
* `tieSet_direction_eq_iInf_ker` — the direction of the tie set is the
  intersection of kernels of the difference functionals.
* `finrank_tieSet_direction` — under linear independence of the difference
  vectors, the direction has finrank `n - (s.card - 1)`.
* `cornerLocus_subset_biUnion` — the corner locus is contained in a finite
  union of pairwise tie hyperplanes.

## References

This formalizes the "combinatorial-linear transversality" principle underlying
tropical hypersurface stratifications and polyhedral Morse theory.
-/
import Mathlib

noncomputable section

open Module Finset

/-! ## Basic definitions -/

/-- The ambient Euclidean space ℝⁿ. -/
abbrev E (n : ℕ) := EuclideanSpace ℝ (Fin n)

/-- The affine function ℓ_i(x) = ⟨w_i, x⟩ + b_i. -/
def affineFun {n : ℕ} {α : Type*}
    (w : α → E n) (b : α → ℝ) (i : α) (x : E n) : ℝ :=
  @inner ℝ _ _ (w i) x + b i

/-- The tie set for an index set `s`: all x where the affine functions
    indexed by `s` take a common value. -/
def tieSet {n : ℕ} {α : Type*} [DecidableEq α]
    (w : α → E n) (b : α → ℝ) (s : Finset α) : Set (E n) :=
  {x | ∀ i ∈ s, ∀ j ∈ s, affineFun w b i x = affineFun w b j x}

/-- The corner locus: points where at least two indices achieve the maximum. -/
def cornerLocus {n : ℕ} {α : Type*} [Fintype α]
    (w : α → E n) (b : α → ℝ) : Set (E n) :=
  {x | ∃ i j, i ≠ j ∧
    (∀ k, affineFun w b k x ≤ affineFun w b i x) ∧
    (∀ k, affineFun w b k x ≤ affineFun w b j x)}

/-- The pairwise tie hyperplane for indices i and j. -/
def tieHyperplane {n : ℕ} {α : Type*}
    (w : α → E n) (b : α → ℝ) (i j : α) : Set (E n) :=
  {x | affineFun w b i x = affineFun w b j x}

/-! ## The difference linear map -/

/-- The linear map sending x to the vector of inner products ⟨w_i - w_{i0}, x⟩
    for i ∈ s \ {i0}. This encodes the tie conditions relative to a pivot. -/
def diffMap {n : ℕ} {α : Type*} [DecidableEq α]
    (w : α → E n) (s : Finset α) (i0 : α) :
    E n →ₗ[ℝ] ({i // i ∈ s.erase i0} → ℝ) where
  toFun x i := @inner ℝ _ _ (w i.1 - w i0) x
  map_add' x y := by ext i; simp [inner_add_right]
  map_smul' r x := by ext i; simp [inner_smul_right]

/-- The constant vector of bias differences. -/
def biasDiffVec {α : Type*} [DecidableEq α]
    (b : α → ℝ) (s : Finset α) (i0 : α) :
    {i // i ∈ s.erase i0} → ℝ :=
  fun i => b i0 - b i.1

/-! ## Tie set characterization -/

/-
The tie set equals the preimage of the bias-difference vector under the
    difference linear map. That is, x ∈ tieSet w b s iff for all i ∈ s \ {i0},
    ⟨w_i - w_{i0}, x⟩ = b_{i0} - b_i.
-/
theorem tieSet_eq_preimage {n : ℕ} {α : Type*} [DecidableEq α]
    (w : α → E n) (b : α → ℝ) (s : Finset α)
    (i0 : α) (hi0 : i0 ∈ s) :
    tieSet w b s = {x | diffMap w s i0 x = biasDiffVec b s i0} := by
  ext x;
  constructor <;> intro hx <;> simp_all +decide [ funext_iff, Finset.ext_iff ];
  · intro a ha hq; have := hx a hq i0 hi0; simp_all +decide [ diffMap, biasDiffVec ] ;
    unfold affineFun at this; simp_all +decide [ inner_sub_left ] ; linarith;
  · intro i hi j hj; by_cases hi0 : i = i0 <;> by_cases hj0 : j = i0 <;> simp_all +decide [ diffMap, biasDiffVec ] ;
    · unfold affineFun; specialize hx j hj0 hj; simp_all +decide [ inner_sub_left ] ; linarith;
    · unfold affineFun; specialize hx i hi0 hi; simp_all +decide [ inner_sub_left ] ; linarith;
    · unfold affineFun; have := hx i hi0 hi; have := hx j hj0 hj; simp_all +decide [ inner_sub_left ] ;
      linarith [ hx i hi0 hi, hx j hj0 hj ]

/-! ## Direction of the tie set -/

/-
The direction of the tie set (the homogeneous part) equals the kernel
    of the difference linear map.
-/
theorem tieSet_direction_eq_ker {n : ℕ} {α : Type*} [DecidableEq α]
    (w : α → E n) (_b : α → ℝ) (s : Finset α)
    (i0 : α) (_hi0 : i0 ∈ s) :
    {v : E n | ∀ i : {i // i ∈ s.erase i0},
      @inner ℝ _ _ (w i.1 - w i0) v = 0} =
    ↑(LinearMap.ker (diffMap w s i0)) := by
  simp +decide [Set.ext_iff, diffMap, funext_iff]

/-! ## Finrank computation via rank-nullity -/

/-
The finrank of the EuclideanSpace ℝ (Fin n) is n.
-/
theorem finrank_E (n : ℕ) : finrank ℝ (E n) = n :=
  finrank_euclideanSpace_fin

/-
Under linear independence of the difference vectors {w_i - w_{i0} : i ∈ s\{i0}},
    the kernel of the difference map has finrank n - (s.card - 1).
-/
theorem finrank_ker_diffMap {n : ℕ} {α : Type*} [DecidableEq α]
    (w : α → E n) (s : Finset α) (i0 : α) (hi0 : i0 ∈ s)
    (h_ind : LinearIndependent ℝ
      (fun i : {i // i ∈ s.erase i0} => w i.1 - w i0)) :
    finrank ℝ (LinearMap.ker (diffMap w s i0)) = n - (s.card - 1) := by
  -- The range of the difference map is spanned by the images of the basis vectors.
  have h_range : LinearMap.range (diffMap w s i0) = ⊤ := by
    refine' Submodule.eq_top_of_finrank_eq _;
    have h_range : LinearIndependent ℝ (fun i : {i // i ∈ s.erase i0} => (innerSL ℝ (w i.1 - w i0)).toLinearMap) := by
      rw [ Fintype.linearIndependent_iff ] at *;
      intro g hg i;
      apply h_ind g;
      refine' ext_inner_right ℝ _;
      intro v; replace hg := congr_arg ( fun f => f v ) hg; simp_all +decide;
      simp_all +decide [ sum_inner ];
      convert hg using 2 ; simp +decide [ inner_smul_left, inner_sub_left ];
    have h_range : Submodule.span ℝ (Set.range (fun i : {i // i ∈ s.erase i0} => (innerSL ℝ (w i.1 - w i0)).toLinearMap)) = LinearMap.range (diffMap w s i0).dualMap := by
      refine' le_antisymm _ _;
      · rw [ Submodule.span_le ];
        rintro _ ⟨ i, rfl ⟩;
        refine' ⟨ _, _ ⟩;
        exact ( LinearMap.proj i );
        ext; simp +decide [ diffMap ];
        rw [ inner_sub_left ];
      · rintro _ ⟨ f, rfl ⟩;
        -- By definition of $f$, we can write it as a linear combination of the basis elements.
        obtain ⟨c, hc⟩ : ∃ c : {i // i ∈ s.erase i0} → ℝ, f = ∑ i, c i • (LinearMap.proj i) := by
          use fun i => f ( Pi.single i 1 );
          ext x; simp +decide [ Pi.single_apply ] ;
        simp +decide [ hc, LinearMap.dualMap ];
        refine' Submodule.sum_mem _ fun i _ => Submodule.smul_mem _ _ _;
        refine' Submodule.subset_span ⟨ i, _ ⟩;
        ext; simp +decide [ diffMap ];
        simp +decide [ Dual.transpose, LinearMap.proj ];
        rw [ inner_sub_left ];
    have h_range : Module.finrank ℝ (↥(LinearMap.range (diffMap w s i0).dualMap)) = Module.finrank ℝ (↥(Submodule.span ℝ (Set.range (fun i : {i // i ∈ s.erase i0} => (innerSL ℝ (w i.1 - w i0)).toLinearMap)))) := by
      rw [h_range];
    rw [ finrank_span_eq_card ] at h_range <;> aesop;
  have := LinearMap.finrank_range_add_finrank_ker ( diffMap w s i0 );
  rw [ h_range, finrank_top, finrank_E ] at this;
  simp_all +decide [ Finset.card_erase_of_mem hi0 ];
  exact eq_tsub_of_add_eq ( by rw [ add_comm, this ] )

/-! ## Main theorem: tie stratum has expected codimension -/

/-
**Tie Stratum Codimension Theorem.**
Under linear independence of the difference weight vectors,
the tie set for an index set s is an affine subspace whose
direction has finrank n - (|s| - 1), i.e., codimension |s| - 1.
-/
theorem tie_stratum_affine_finrank {n : ℕ} {α : Type*} [DecidableEq α]
    (w : α → E n) (b : α → ℝ) (s : Finset α) (_hs : s.Nonempty)
    (i0 : α) (hi0 : i0 ∈ s)
    (h_ind : LinearIndependent ℝ
      (fun i : {i // i ∈ s.erase i0} => w i.1 - w i0)) :
    ∃ S : Submodule ℝ (E n),
      (∀ x y, (x ∈ tieSet w b s ∧ y ∈ tieSet w b s) →
        x - y ∈ S) ∧
      finrank ℝ S = n - (s.card - 1) := by
  refine' ⟨ _, _, finrank_ker_diffMap w s i0 hi0 h_ind ⟩;
  simp +contextual [LinearMap.mem_ker, tieSet_eq_preimage w b s i0 hi0]

/-! ## Corner locus decomposition -/

/-
The corner locus is contained in the union of pairwise tie hyperplanes.
-/
theorem cornerLocus_subset_biUnion {n : ℕ} {α : Type*} [Fintype α] [DecidableEq α]
    (w : α → E n) (b : α → ℝ) :
    cornerLocus w b ⊆
      ⋃ (p : α × α) (_ : p.1 ≠ p.2), tieHyperplane w b p.1 p.2 := by
  intro x hx;
  -- By definition of corner locus, there exist i and j such that i ≠ j and both achieve the maximum value of the affine functions at x.
  obtain ⟨i, j, hij, h_max⟩ := hx;
  simp +decide [tieHyperplane];
  exact ⟨ i, j, hij, le_antisymm ( h_max.2 i ) ( h_max.1 j ) ⟩

/-! ## Linear functional non-constancy on strata -/

/-
A linear functional c is not constant on the tie set (when c is not
    orthogonal to the direction) — i.e., the tie set is not contained
    in a level set of c, unless c lies in the orthogonal complement
    of the direction.
-/
theorem linear_not_constant_on_tieSet {n : ℕ} {α : Type*} [DecidableEq α]
    (w : α → E n) (b : α → ℝ)
    (s : Finset α) (i0 : α) (hi0 : i0 ∈ s)
    (c : E n)
    (_h_ind : LinearIndependent ℝ
      (fun i : {i // i ∈ s.erase i0} => w i.1 - w i0))
    (hc : ∃ v ∈ LinearMap.ker (diffMap w s i0),
      @inner ℝ _ _ c v ≠ 0)
    (_hne : ∃ x, x ∈ tieSet w b s) :
    ∀ x ∈ tieSet w b s,
      ∃ y ∈ tieSet w b s, @inner ℝ _ _ c y ≠ @inner ℝ _ _ c x := by
  -- By tieSet_eq_preimage, x ∈ tieSet means diffMap w s i0 x = biasDiffVec b s i0.
  intro x hx
  obtain ⟨v, hv_ker, hv_ne⟩ := hc
  have hx_diffMap : diffMap w s i0 x = biasDiffVec b s i0 := by
    exact Set.ext_iff.mp ( tieSet_eq_preimage w b s i0 hi0 ) x |>.1 hx;
  refine' ⟨ x + v, _, _ ⟩ <;> simp_all +decide;
  · exact (tieSet_eq_preimage w b s i0 hi0).symm ▸ by aesop
  · rw [inner_add_right]; aesop

end