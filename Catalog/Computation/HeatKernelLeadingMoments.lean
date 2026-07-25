/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Moment spectrum and the dimension of the leading-term cancellation space

This file **deepens** `Catalog/Novelty/HeatKernelLeadingTerm.lean`.  There the
leading `1/N` correction to a heat-kernel trace,

  `L(t) = ∑ᵢ dᵢ · e^{-t Eᵢ}`,

was shown to vanish for all inverse temperatures `t` **iff** the aggregate
diagonal shift over each degenerate energy level is zero.  Here we push the
analysis to two sharper structural characterisations.

## Main results

* `heatKernelLeading_vanishes_iff_moments` — **(moment spectrum)** the leading
  term cancels for all `t` **iff** every spectral moment `mₖ = ∑ᵢ dᵢ Eᵢᵏ`
  vanishes.  This trades the transcendental family `t ↦ e^{-tEᵢ}` for the
  purely algebraic family of power sums, exposing the cancellation as an
  identity of formal moments.

* `cancellationMap` and `mem_ker_cancellationMap_iff` — the space of shift
  vectors producing identical cancellation is realised as the kernel of a single
  linear *level-aggregation map* `S`, sending `d` to the tuple of its aggregate
  shifts over the distinct energy levels.

* `cancellationSpace_finrank` — **(dimension formula)** the cancellation space
  has dimension exactly `n − (number of distinct energy levels)`.  Cancellation
  freedom is measured precisely by the total spectral degeneracy: each merged
  pair of levels contributes one new independent way to cancel the leading term.

* `exists_nontrivial_cancellation_iff_degenerate` — a corollary: nontrivial
  (i.e. not identically-zero-perturbation) cancellation exists **iff** the
  spectrum is degenerate.

## Tags
heat kernel, spectral moments, power sums, Vandermonde, cancellation space,
kernel dimension, rank–nullity, degeneracy

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).**  The level-by-level characterisation of the
previous cycle suggests two deeper invariants.  (i) The exponential test family
`e^{-tEᵢ}` should be replaceable by power sums `Eᵢᵏ`, since both separate the
distinct levels via a Vandermonde determinant.  (ii) The set of shift vectors
`d` with `L ≡ 0` is a linear subspace whose dimension ought to be governed only
by the *pattern* of degeneracies, namely `n` minus the number of distinct levels.

**Experiment (Experimenter).**  For `E = (a,a)` (one distinct level, `n = 2`) the
cancellation condition is the single equation `d₀ + d₁ = 0`, a line: dimension
`2 − 1 = 1` ✓.  For distinct `E = (0,1)` the condition forces `d = 0`: dimension
`2 − 2 = 0` ✓.  The moment test on `E = (a,a)`, `d = (c,-c)` gives
`mₖ = c·aᵏ − c·aᵏ = 0` for every `k`, matching `L ≡ 0`.

**Analysis (Analyst).**  Both invariants factor through the fibrewise sums over
energy values.  A moment `mₖ` regroups as `∑ᵥ vᵏ sᵥ` with `sᵥ` the aggregate
shift of level `v`; distinctness of the `v` makes the Vandermonde matrix in the
`v` invertible, so `all mₖ = 0 ↔ all sᵥ = 0`.  The same aggregate shifts are the
components of a linear map `S`, whose kernel is the cancellation space and whose
surjectivity (spread any target mass across a nonempty fibre) yields the
dimension via rank–nullity.

**Critique (Critic).**  The moment equivalence is not vacuous: the reverse
direction genuinely needs the Vandermonde nonsingularity, and the forward
direction genuinely needs the level-sum theorem — neither is `simp`.  The
dimension formula is stated with `ℕ` subtraction, which is safe here because the
number of distinct levels never exceeds `n`; the corollary makes the boundary
`card < n` explicit.

**Synthesis (PI).**  Leading-term cancellation is controlled by a single linear
level-aggregation map.  Its kernel is the cancellation space (dimension
`n − #levels`), its vanishing is equivalent to that of every spectral power sum,
and both facts trace back to the invertibility of a Vandermonde system on the
distinct energy values — a clean three-way bridge between spectral analysis,
the combinatorics of degeneracy, and finite-dimensional linear algebra.
-/
import Mathlib
import Novelty.HeatKernelLeadingTerm

open scoped BigOperators
open Matrix Finset

namespace Catalog.Novelty.HeatKernelLeadingTerm

/-
**Vandermonde moment lemma.**  If the sample points `x` are distinct and every
power-sum moment `∑ᵢ cᵢ xᵢᵏ` vanishes, then every coefficient `cᵢ` is zero.
-/
theorem coeffs_zero_of_vanishing_moments {ι : Type*} [Fintype ι] (x c : ι → ℝ)
    (hx : Function.Injective x)
    (h : ∀ k : ℕ, ∑ i, c i * x i ^ k = 0) : ∀ i, c i = 0 := by
  by_contra h_nonzero;
  have h_vandermonde_inv : Matrix.det (Matrix.transpose (Matrix.vandermonde (fun i : Fin (Fintype.card ι) => x (Fintype.equivFin ι |>.symm i)))) ≠ 0 := by
    rw [ Matrix.det_transpose, Matrix.det_vandermonde ];
    simp +decide [ Finset.prod_eq_zero_iff, sub_eq_zero, hx.eq_iff ];
  have h_vandermonde_inv : Matrix.mulVec (Matrix.transpose (Matrix.vandermonde (fun i : Fin (Fintype.card ι) => x (Fintype.equivFin ι |>.symm i)))) (fun i => c (Fintype.equivFin ι |>.symm i)) = 0 := by
    ext k; specialize h k; simp_all +decide [ Matrix.mulVec, dotProduct, mul_comm ] ;
    rw [ ← h, ← Equiv.sum_comp ( Fintype.equivFin ι ) ] ; aesop;
  exact h_nonzero fun i => by simpa [ Fintype.equivFin ] using congr_fun ( Matrix.eq_zero_of_mulVec_eq_zero ‹_› h_vandermonde_inv ) ( Fintype.equivFin ι i ) ;

/-
Fibrewise decomposition of a spectral moment by energy value.
-/
theorem heatKernelMoment_level_decomp {n : ℕ} (E d : Fin n → ℝ) (k : ℕ) :
    ∑ i, d i * (E i) ^ k
      = ∑ v ∈ Finset.univ.image E,
          v ^ k * ∑ j ∈ Finset.univ.filter (fun j => E j = v), d j := by
  simp +decide only [sum_filter];
  simp +decide [ Finset.mul_sum _ _ _, mul_comm ];
  rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop

/-
**Leading-term cancellation, moment form.**  The leading `1/N` term cancels for
every `t` iff every spectral power-sum moment `∑ᵢ dᵢ Eᵢᵏ` vanishes.
-/
theorem heatKernelLeading_vanishes_iff_moments {n : ℕ} (E d : Fin n → ℝ) :
    (∀ t : ℝ, heatKernelLeading E d t = 0) ↔ (∀ k : ℕ, ∑ i, d i * (E i) ^ k = 0) := by
  constructor;
  · intro h k;
    exact ( heatKernelLeading_vanishes_iff_levelSums E d ) |>.1 h |> fun h' => ( heatKernelMoment_level_decomp E d k ) ▸ Finset.sum_eq_zero fun x hx => by aesop;
  · intro h t;
    -- Consider the finite index type `↥(Finset.univ.image E)`, with points `x v = (v : ℝ)` (injective by Subtype.ext) and coefficients `c v = ∑ j ∈ filter (E j = v) univ, d j`.
    set ι := Finset.univ.image E with hι_def
    set x : ι → ℝ := fun v => v.val
    set c : ι → ℝ := fun v => ∑ j ∈ Finset.univ.filter (fun j => E j = v.val), d j;
    have h_coeffs_zero : ∀ k : ℕ, ∑ v : ι, c v * x v ^ k = 0 := by
      intro k
      have h_sum_eq : ∑ v : ι, c v * x v ^ k = ∑ i, d i * E i ^ k := by
        convert heatKernelMoment_level_decomp E d k |> Eq.symm using 1;
        refine' Finset.sum_bij ( fun v hv => v ) _ _ _ _ <;> simp +decide [ mul_comm ];
        · exact fun i => Finset.mem_image_of_mem _ ( Finset.mem_univ _ );
        · grind;
      rw [h_sum_eq, h k];
    have h_coeffs_zero : ∀ v : ι, c v = 0 := by
      convert coeffs_zero_of_vanishing_moments x c _ h_coeffs_zero;
      exact fun a b h => Subtype.ext h;
    convert heatKernelLeading_vanishes_iff_levelSums E d |>.2 _ t;
    exact fun i => h_coeffs_zero ⟨ E i, Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩

/-- The **level-aggregation map**: sends a vector of diagonal shifts to the tuple
of aggregate shifts over each distinct energy level. -/
noncomputable def cancellationMap {n : ℕ} (E : Fin n → ℝ) :
    (Fin n → ℝ) →ₗ[ℝ] (↥(Finset.univ.image E) → ℝ) where
  toFun d := fun v => ∑ j ∈ Finset.univ.filter (fun j => E j = (v : ℝ)), d j
  map_add' d₁ d₂ := by
    funext v; simp [Finset.sum_add_distrib]
  map_smul' a d := by
    funext v; simp [Finset.mul_sum]

/-
The kernel of the level-aggregation map is exactly the leading-term
cancellation space.
-/
theorem mem_ker_cancellationMap_iff {n : ℕ} (E d : Fin n → ℝ) :
    d ∈ LinearMap.ker (cancellationMap E) ↔
      (∀ t : ℝ, heatKernelLeading E d t = 0) := by
  refine' ⟨ _, fun h => _ ⟩;
  · intro h t;
    convert heatKernelLeading_vanishes_iff_levelSums E d |>.2 _ t;
    intro i; specialize h; replace h := congr_fun h ⟨ E i, Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩ ; aesop;
  · convert heatKernelLeading_vanishes_iff_levelSums E d |>.1 h;
    simp +decide [ LinearMap.mem_ker, funext_iff, cancellationMap ];
    exact ⟨ fun h i => h _ _ rfl, fun h a i hi => hi ▸ h i ⟩

/-
The level-aggregation map is surjective: any prescribed collection of level
aggregates is achievable by spreading mass across each (nonempty) level.
-/
theorem cancellationMap_surjective {n : ℕ} (E : Fin n → ℝ) :
    Function.Surjective (cancellationMap E) := by
  intro g
  obtain ⟨d, hd⟩ : ∃ d : Fin n → ℝ, ∀ v : Finset.univ.image E, ∑ j ∈ Finset.univ.filter (fun j => E j = v.val), d j = g v := by
    -- For each $v \in \text{image } E$, choose an index $i_v$ such that $E i_v = v$.
    have h_choose : ∀ v : (Finset.univ.image E), ∃ i : Fin n, E i = v.val := by
      grind;
    choose f hf using h_choose;
    use fun j => ∑ v : (Finset.univ.image E), if j = f v then g v else 0;
    intro v; rw [ Finset.sum_comm ] ; simp +decide [ hf ] ;
  exact ⟨ d, funext hd ⟩

/-
**Dimension of the cancellation space.**  The space of diagonal shift vectors
producing identical leading-term cancellation has dimension exactly
`n − (number of distinct energy levels)`.
-/
theorem cancellationSpace_finrank {n : ℕ} (E : Fin n → ℝ) :
    Module.finrank ℝ (LinearMap.ker (cancellationMap E))
      = n - (Finset.univ.image E).card := by
  rw [ Nat.sub_eq_of_eq_add ];
  have := LinearMap.finrank_range_add_finrank_ker ( cancellationMap E );
  rw [ add_comm, show ( cancellationMap E ).range = ⊤ from _ ] at this;
  · simp_all +decide;
  · exact LinearMap.range_eq_top.mpr ( cancellationMap_surjective E )

/-
Nontrivial leading-term cancellation (a nonzero perturbation with `L ≡ 0`)
exists iff the spectrum is degenerate.
-/
theorem exists_nontrivial_cancellation_iff_degenerate {n : ℕ} (E : Fin n → ℝ) :
    (0 < Module.finrank ℝ (LinearMap.ker (cancellationMap E))) ↔
      (Finset.univ.image E).card < n := by
  rw [ cancellationSpace_finrank, Nat.pos_iff_ne_zero ];
  grind

end Catalog.Novelty.HeatKernelLeadingTerm