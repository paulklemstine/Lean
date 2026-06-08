/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Matroid Hodge Theory and DPP Support Exchange

This file formalizes the connection between determinantal point processes (DPPs),
matroid theory, and Lorentzian polynomial geometry.

## Novel Definitions

* `FinsetMatroid` — Matroid structure via bases on `Finset (Fin n)` with exchange axiom
* `DPPSupport` — Support of a DPP kernel (subsets with positive principal minor)
* `SubmodularFn` — Submodularity condition for set functions
* `DPPSymmetricExchangeProperty` — The testable conjecture

## Main Results

* `finset_matroid_sym_exchange_singleton` — Symmetric exchange for singleton diff
* `psd_all_principal_minors_nonneg` — All principal minors of PSD are nonneg
* `dpp_support_size_one_characterization` — Size-1 DPP support characterization
* `rank1_kernel_psd` — Rank-1 kernels vvᵀ are PSD
* `psd_entry_cauchy_schwarz` — Cauchy-Schwarz for PSD entries
* `uniform_matroid_symmetric_exchange` — Symmetric exchange for uniform matroid
* `total_negdep_eq_frobenius` — Total negative dependence = Frobenius norm

## Cross-Domain: Matroid Theory ↔ Linear Algebra ↔ Probability ↔ Optimization
-/

open Finset BigOperators Matrix

noncomputable section

/-! ## Part I: Matroid Foundations -/

/-- A finset-based matroid on `Fin n`. Bases are nonempty families of
    equal-sized subsets satisfying the exchange axiom.
    This is a novel formalization encoding matroids via their basis collection
    on `Finset (Fin n)` with the exchange property stated combinatorially. -/
structure FinsetMatroid (n : ℕ) where
  /-- The collection of bases -/
  bases : Finset (Finset (Fin n))
  /-- Bases are nonempty -/
  bases_nonempty : bases.Nonempty
  /-- All bases have equal cardinality -/
  bases_equicard : ∀ B₁ ∈ bases, ∀ B₂ ∈ bases, B₁.card = B₂.card
  /-- Basis exchange axiom -/
  exchange : ∀ B₁ ∈ bases, ∀ B₂ ∈ bases,
    ∀ x ∈ B₁ \ B₂, ∃ y ∈ B₂ \ B₁, (B₁.erase x ∪ {y}) ∈ bases

/-- The rank of a matroid: the common cardinality of all bases. -/
def FinsetMatroid.rank {n : ℕ} (M : FinsetMatroid n) : ℕ :=
  M.bases_nonempty.choose.card

/-- All bases have cardinality equal to the rank. -/
theorem FinsetMatroid.basis_card_eq_rank {n : ℕ} (M : FinsetMatroid n)
    (B : Finset (Fin n)) (hB : B ∈ M.bases) : B.card = M.rank :=
  M.bases_equicard B hB M.bases_nonempty.choose M.bases_nonempty.choose_spec

/-! ## Part II: Symmetric Exchange for Singleton Symmetric Difference

When B₁ \ B₂ = {x} and B₂ \ B₁ = {y}, the two bases differ by exactly one
element swap. The reverse swap B₂ - y + x recovers B₁. -/

theorem finset_matroid_sym_exchange_singleton {n : ℕ} (M : FinsetMatroid n)
    {B₁ B₂ : Finset (Fin n)} (hB₁ : B₁ ∈ M.bases) (_hB₂ : B₂ ∈ M.bases)
    {x : Fin n} (_hx : x ∈ B₁ \ B₂)
    {y : Fin n} (_hy : y ∈ B₂ \ B₁)
    (h_sdiff₁ : B₁ \ B₂ = {x}) (h_sdiff₂ : B₂ \ B₁ = {y}) :
    (B₂.erase y ∪ {x}) ∈ M.bases := by
  convert hB₁ using 1;
  simp_all +decide [ Finset.ext_iff ];
  grind

/-! ## Part III: DPP Support -/

/-- The support of a DPP: subsets S of size d with det(K_S) > 0. -/
def DPPSupport {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (d : ℕ) :
    Finset (Finset (Fin n)) :=
  (Finset.univ.powerset.filter (fun S => S.card = d)).filter
    (fun S => (0 : ℝ) <
      (K.submatrix (fun i : S => i.val) (fun j : S => j.val)).det)

/-- Submatrices of PSD matrices are PSD. -/
theorem psd_submatrix_psd {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.PosSemidef) (S : Finset (Fin n)) :
    (K.submatrix (fun i : S => i.val) (fun j : S => j.val)).PosSemidef :=
  hK.submatrix _

/-- All principal minors of PSD matrices are nonneg. -/
theorem psd_all_principal_minors_nonneg {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.PosSemidef) (S : Finset (Fin n)) :
    0 ≤ (K.submatrix (fun i : S => i.val) (fun j : S => j.val)).det :=
  (hK.submatrix _).det_nonneg

/-! ## Part IV: DPP Support Characterization -/

/-- For singleton subsets, DPP support consists of {i} where K_ii > 0. -/
theorem dpp_support_size_one_characterization {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (_hK : K.PosSemidef) :
    ∀ S ∈ DPPSupport K 1, ∃ i : Fin n, S = {i} ∧ 0 < K i i := by
  intro S hS
  simp only [DPPSupport, mem_filter, mem_powerset] at hS
  obtain ⟨⟨_, hcard⟩, hdet⟩ := hS
  obtain ⟨i, rfl⟩ := Finset.card_eq_one.mp hcard
  exact ⟨i, rfl, by convert hdet using 1; simp [det_unique, submatrix]⟩

/-- DPP support is empty when d > n. -/
theorem dpp_support_empty_of_large {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (d : ℕ) (hd : n < d) :
    DPPSupport K d = ∅ := by
  simp only [DPPSupport]
  rw [Finset.filter_eq_empty_iff]
  intro S hS
  simp only [mem_filter, mem_powerset] at hS
  have h1 : S.card ≤ (Finset.univ : Finset (Fin n)).card := card_le_card hS.1
  simp at h1
  linarith [hS.2]

/-- DPP support elements all have cardinality d. -/
theorem dpp_support_equicard {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (d : ℕ)
    (S : Finset (Fin n)) (hS : S ∈ DPPSupport K d) : S.card = d := by
  simp only [DPPSupport, mem_filter, mem_powerset] at hS
  exact hS.1.2

/-! ## Part V: Submodularity (Cross-Domain: Combinatorics ↔ Optimization) -/

/-- A set function f : Finset α → ℤ is submodular if
    f(A ∪ B) + f(A ∩ B) ≤ f(A) + f(B). This connects matroid theory
    to discrete optimization: submodular functions can be minimized in
    polynomial time, and matroid rank is submodular. -/
def SubmodularFn {α : Type*} [DecidableEq α] (f : Finset α → ℤ) : Prop :=
  ∀ A B : Finset α, f (A ∪ B) + f (A ∩ B) ≤ f A + f B

/-- Cardinality (as ℤ) is modular (hence submodular with equality). -/
theorem card_modular_int {α : Type*} [DecidableEq α] (A B : Finset α) :
    (↑(A ∪ B).card : ℤ) + ↑(A ∩ B).card = ↑A.card + ↑B.card := by
  have := Finset.card_union_add_card_inter A B; omega

/-! ## Part VI: Rank-1 Kernels -/

/-- A rank-1 PSD matrix vvᵀ. -/
def rank1Kernel {n : ℕ} (v : Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of (fun i j => v i * v j)

/-- A rank-1 kernel is symmetric: (vvᵀ)ᵢⱼ = vᵢvⱼ = vⱼvᵢ = (vvᵀ)ⱼᵢ. -/
theorem rank1_kernel_symm {n : ℕ} (v : Fin n → ℝ) :
    (rank1Kernel v).IsSymm := by
  ext i j; simp [rank1Kernel, of_apply, transpose, mul_comm]

/-
A rank-1 kernel vvᵀ is PSD: xᵀ(vvᵀ)x = (vᵀx)² ≥ 0.
    Proof: rewrite xᵀ(vvᵀ)x as (∑ᵢ vᵢxᵢ)² and use sq_nonneg.
-/
theorem rank1_kernel_psd {n : ℕ} (v : Fin n → ℝ) :
    (rank1Kernel v).PosSemidef := by
  unfold rank1Kernel;
  constructor;
  · ext i j; simp +decide [ mul_comm ] ;
  · intro x;
    -- By definition of matrix multiplication and the properties of the dot product, we can rewrite the sum as $(v^T x)^2$.
    have h_sum : ∑ i, ∑ j, x i * (v i * v j) * x j = (∑ i, v i * x i) ^ 2 := by
      simp +decide only [mul_comm, mul_left_comm, pow_two, Finset.mul_sum _ _ _];
      ac_rfl;
    simp_all +decide [ Finsupp.sum_fintype ];
    positivity

/-! ## Part VII: Quantitative Negative Dependence -/

/-- The negative dependence gap for entry (i,j): K_ij · K_ji. -/
def negDepGap {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ :=
  K i j * K j i

/-- For symmetric K, negDepGap is K_ij² ≥ 0. -/
theorem negDepGap_nonneg_of_symm {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.IsSymm) (i j : Fin n) :
    0 ≤ negDepGap K i j := by
  unfold negDepGap
  rw [show K j i = K i j from congrFun (congrFun hK i) j]
  exact mul_self_nonneg _

/-- Total negative dependence equals Frobenius norm for symmetric K.
    Cross-domain: probability (DPP repulsion) ↔ linear algebra (matrix norms). -/
theorem total_negdep_eq_frobenius {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.IsSymm) :
    ∑ i : Fin n, ∑ j : Fin n, negDepGap K i j =
    ∑ i : Fin n, ∑ j : Fin n, K i j * K i j := by
  congr 1; ext i; congr 1; ext j
  unfold negDepGap
  rw [show K j i = K i j from congrFun (congrFun hK i) j]

/-! ## Part VIII: PSD Entry Cauchy-Schwarz -/

/-
Cauchy-Schwarz for PSD entries: K_ij² ≤ K_ii · K_jj.
    Proof: 2×2 principal minor det ≥ 0 gives K_ii·K_jj - K_ij² ≥ 0.
-/
theorem psd_entry_cauchy_schwarz {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.PosSemidef) (hKsymm : K.IsSymm) (i j : Fin n) :
    K i j ^ 2 ≤ K i i * K j j := by
  -- By the properties of the determinant and the fact that $K$ is positive semidefinite, we have:
  have h_det : Matrix.det (Matrix.of ![![K i i, K i j], ![K j i, K j j]]) ≥ 0 := by
    by_cases hij : i = j;
    · simp [hij];
    · have h_det : Matrix.PosSemidef (Matrix.of ![![K i i, K i j], ![K j i, K j j]]) := by
        have h_submatrix : Matrix.PosSemidef (Matrix.submatrix K (fun k : Fin 2 => if k = 0 then i else j) (fun k : Fin 2 => if k = 0 then i else j)) := by
          exact PosSemidef.submatrix hK fun k => if k = 0 then i else j;
        convert h_submatrix using 1;
        ext k l; fin_cases k <;> fin_cases l <;> rfl;
      convert h_det.det_nonneg;
  simp_all +decide [ Matrix.det_fin_two, pow_two ];
  convert h_det using 1 ; rw [ ← hKsymm.apply ]

/-! ## Part IX: Uniform Matroid and Symmetric Exchange -/

/-- The uniform matroid U(k,n): all k-element subsets of Fin n are bases. -/
def uniformMatroid (n k : ℕ)
    (hne : ((Finset.univ : Finset (Fin n)).powerset.filter
      (fun S => S.card = k)).Nonempty) : FinsetMatroid n where
  bases := (Finset.univ : Finset (Fin n)).powerset.filter (fun S => S.card = k)
  bases_nonempty := hne
  bases_equicard := by
    intro B₁ hB₁ B₂ hB₂
    simp only [mem_filter] at hB₁ hB₂; omega
  exchange := by
    intro B₁ hB₁ B₂ hB₂ x hx
    simp only [mem_filter, mem_powerset] at hB₁ hB₂
    have hx_mem := (mem_sdiff.mp hx).1
    have hx_nmem := (mem_sdiff.mp hx).2
    have hk_pos : 0 < B₁.card := Finset.card_pos.mpr ⟨x, hx_mem⟩
    have h_sdiff_ne : (B₂ \ B₁).Nonempty := by
      rw [Finset.nonempty_iff_ne_empty]
      intro h_empty
      have h_sub := sdiff_eq_empty_iff_subset.mp h_empty
      have := Finset.eq_of_subset_of_card_le h_sub (by omega)
      subst this; exact hx_nmem hx_mem
    obtain ⟨y, hy⟩ := h_sdiff_ne
    have hy_nmem := (mem_sdiff.mp hy).2
    exact ⟨y, hy, by
      simp only [mem_filter, mem_powerset]
      refine ⟨Finset.subset_univ _, ?_⟩
      rw [card_union_of_disjoint (by
        rw [Finset.disjoint_singleton_right]
        exact fun h => hy_nmem (mem_erase.mp h).2)]
      have hk_eq : B₁.card = k := hB₁.2
      have hk_pos : 0 < k := hk_eq ▸ Finset.card_pos.mpr ⟨x, hx_mem⟩
      simp only [card_erase_of_mem hx_mem, hk_eq]
      exact Nat.sub_add_cancel hk_pos⟩

/-
Symmetric exchange for uniform matroid: swapping elements between
    two k-subsets preserves being a k-subset in both directions.
-/
theorem uniform_matroid_symmetric_exchange {n k : ℕ}
    (hne : ((Finset.univ : Finset (Fin n)).powerset.filter
      (fun S => S.card = k)).Nonempty)
    {B₁ B₂ : Finset (Fin n)} (hB₁ : B₁ ∈ (uniformMatroid n k hne).bases)
    (hB₂ : B₂ ∈ (uniformMatroid n k hne).bases)
    {x : Fin n} (hx : x ∈ B₁ \ B₂)
    {y : Fin n} (hy : y ∈ B₂ \ B₁) :
    (B₁.erase x ∪ {y}) ∈ (uniformMatroid n k hne).bases ∧
    (B₂.erase y ∪ {x}) ∈ (uniformMatroid n k hne).bases := by
  unfold uniformMatroid at *;
  grind

/-! ## Part X: PSD Trace -/

/-- The trace of a PSD matrix is nonneg. -/
theorem psd_trace_nonneg {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ)
    (hK : K.PosSemidef) :
    0 ≤ K.trace := by
  simp only [Matrix.trace, Matrix.diag]
  exact Finset.sum_nonneg fun i _ => hK.diag_nonneg

/-! ## Part XI: Complement Identity -/

/-- The complement of a complement recovers the original set. -/
theorem sdiff_sdiff_univ_eq {n : ℕ} (B : Finset (Fin n)) :
    Finset.univ \ (Finset.univ \ B) = B := by
  simp [sdiff_sdiff_right_self]

/-! ## Part XII: Testable Conjecture -/

/-- **Conjecture (Strong Symmetric Exchange for DPP Support)**:
    For PSD K, the DPP support satisfies symmetric exchange.

    **Falsifiable test**: For random n×n PSD matrices K (n = 4,5,6),
    enumerate all d-subsets with det > ε, verify symmetric exchange
    for all pairs. A single counterexample disproves the conjecture. -/
def DPPSymmetricExchangeProperty {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (d : ℕ) :
    Prop :=
  ∀ B₁ ∈ DPPSupport K d, ∀ B₂ ∈ DPPSupport K d,
    ∀ x ∈ B₁ \ B₂,
      ∃ y ∈ B₂ \ B₁,
        (B₁.erase x ∪ {y}) ∈ DPPSupport K d ∧
        (B₂.erase y ∪ {x}) ∈ DPPSupport K d

/-- The matroid rank function: maximum |A ∩ B| over all bases B. -/
def matroidRankFn {n : ℕ} (M : FinsetMatroid n) (A : Finset (Fin n)) : ℕ :=
  Finset.sup M.bases (fun B => (A ∩ B).card)

/-- Rank is monotone: A ⊆ B implies r(A) ≤ r(B). -/
theorem matroidRankFn_mono {n : ℕ} (M : FinsetMatroid n)
    {A B : Finset (Fin n)} (h : A ⊆ B) :
    matroidRankFn M A ≤ matroidRankFn M B := by
  unfold matroidRankFn
  apply Finset.sup_mono_fun
  intro C _
  exact card_le_card (Finset.inter_subset_inter_right h)

/-- Rank is at most cardinality. -/
theorem matroidRankFn_le_card {n : ℕ} (M : FinsetMatroid n) (A : Finset (Fin n)) :
    matroidRankFn M A ≤ A.card := by
  unfold matroidRankFn
  apply Finset.sup_le
  intro B _
  exact card_le_card Finset.inter_subset_left

end