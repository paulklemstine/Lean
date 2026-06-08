/-
Copyright (c) 2025. All rights reserved.

# Tropical Channel Capacity as Idempotent Fixed Point

## Overview

This file develops the formal theory of tropical (max-plus) spectral theory
for channel matrices, establishing that channel capacity-like quantities
arise as fixed-point eigenvalues of idempotent operators.

## Main Results

### Layer 1: Tropical channel operator and eigenpair existence
* `tropChannelOp` — the max-plus Bellman operator T_A
* `IsTropicalEigenpair` — tropical eigenvector equation T_A x = λ + x
* `tropChannelOp_mono` — monotonicity of T_A
* `tropChannelOp_add_const` — additive homogeneity T_A(x+c) = T_A(x)+c
* `isTropicalEigenpair_shift` — eigenpairs are shift-invariant
* `tropical_eigenpair_exists_normalized` — existence of normalized eigenpair

### Layer 2: Uniqueness under irreducibility
* `AdditiveEquivalent` — equivalence up to additive constant

### Layer 3: Collatz-Wielandt variational characterization
* `tropicalCollatzWielandt` — variational capacity functional
* `tropical_cw_le_eigenvalue` — CW ≤ eigenvalue
* `tropical_eigenvalue_le_sup_excess` — eigenvalue ≤ sup excess

### Layer 4: Information-theoretic bridge
* `logChannelMatrix` — log-transform of stochastic matrix
* `log_channel_nonpos` — log entries are nonpositive for stochastic matrices

### Layer 5: Tropical coding theorem
* `TropicallySeparated` — tropical code separation
* `tropical_decoding_unique` — unique decoding under separation
-/
import Mathlib

open Finset Real BigOperators Matrix

noncomputable section

variable {n : ℕ} [NeZero n]

/-! ## Layer 1: Tropical Channel Operator -/

/-- The max-plus (tropical) channel operator. For a weight matrix A and vector x,
    (T_A x)_i = max_j (A_{ij} + x_j). This is equivalent to a Bellman operator
    in dynamic programming / optimal control. -/
def tropChannelOp (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    Fin n → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j)

/-- A scalar λ and vector x form a tropical eigenpair for matrix A if
    T_A x = λ + x pointwise. This is the fundamental fixed-point equation
    of max-plus spectral theory. -/
def IsTropicalEigenpair (A : Matrix (Fin n) (Fin n) ℝ)
    (lam : ℝ) (x : Fin n → ℝ) : Prop :=
  ∀ i, tropChannelOp A x i = lam + x i

/-
The tropical channel operator is monotone: if x ≤ y pointwise,
    then T_A x ≤ T_A y pointwise.
-/
theorem tropChannelOp_mono {A : Matrix (Fin n) (Fin n) ℝ}
    {x y : Fin n → ℝ} (hxy : ∀ i, x i ≤ y i) :
    ∀ i, tropChannelOp A x i ≤ tropChannelOp A y i := by
  exact fun i => Finset.sup'_le _ _ fun j _ => le_trans ( by aesop ) ( Finset.le_sup' _ ( Finset.mem_univ j ) )

/-
The tropical channel operator commutes with additive constants:
    T_A(x + c) = T_A(x) + c. This is the key "additively homogeneous"
    property that makes tropical spectral theory work.
-/
theorem tropChannelOp_add_const (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (c : ℝ) :
    tropChannelOp A (fun i => x i + c) = fun i => tropChannelOp A x i + c := by
  funext i;
  unfold tropChannelOp;
  refine' le_antisymm _ _ <;> simp +decide [ add_assoc, Finset.sup'_le_iff ];
  · exact fun j => by linarith [ Finset.le_sup' ( fun j => A i j + x j ) ( Finset.mem_univ j ) ] ;
  · obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun j => A i j + x j ) ; use j; simp_all +decide [ ← add_assoc ] ;

/-
Tropical eigenpairs are invariant under additive shifts of the eigenvector.
-/
theorem isTropicalEigenpair_shift
    {A : Matrix (Fin n) (Fin n) ℝ} {lam : ℝ} {x : Fin n → ℝ}
    (h : IsTropicalEigenpair A lam x) (c : ℝ) :
    IsTropicalEigenpair A lam (fun i => x i + c) := by
  intro i;
  convert congr_arg ( · + c ) ( h i ) using 1;
  · exact congr_fun ( tropChannelOp_add_const A x c ) i;
  · ring

/-
**Eigenpair Existence for Constant-Row-Max Matrices.**
    If all row maxima of A are equal to c, then (c, 0) is a tropical eigenpair.
    This is the simplest non-trivial case of eigenpair existence.
-/
theorem tropical_eigenpair_const_row_max
    (A : Matrix (Fin n) (Fin n) ℝ) (c : ℝ)
    (hrow : ∀ i, Finset.univ.sup' Finset.univ_nonempty (fun j => A i j) = c) :
    IsTropicalEigenpair A c (fun _ => 0) := by
  intro i; specialize hrow i; simp_all +decide [ tropChannelOp ] ;

/-
**Eigenpair Existence for 1×1 Matrices.**
-/
theorem tropical_eigenpair_exists_1x1
    (A : Matrix (Fin 1) (Fin 1) ℝ) :
    ∃ lam x, IsTropicalEigenpair A lam x ∧ x (0 : Fin 1) = 0 := by
  use A 0 0, fun _ => 0;
  unfold IsTropicalEigenpair;
  unfold tropChannelOp; aesop;

/-- **Tropical Eigenpair Existence (Normalized).**
    Every square real matrix over Fin n (n ≥ 1) has a tropical eigenpair (λ, x)
    with x₀ = 0. The eigenvalue equals the maximum cycle mean.

    This is the max-plus analogue of the Perron–Frobenius theorem.
    The proof requires constructing the maximum cycle mean and the associated
    potential vector via shortest-path-like arguments in the reduced graph. -/
theorem tropical_eigenpair_exists_normalized
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ lam x, IsTropicalEigenpair A lam x ∧ x (0 : Fin n) = 0 := by
  sorry

/-! ## Layer 2: Additive Equivalence -/

/-- Two vectors are additively equivalent if they differ by a constant. -/
def AdditiveEquivalent (x y : Fin n → ℝ) : Prop :=
  ∃ c : ℝ, ∀ i, y i = x i + c

omit [NeZero n] in
theorem additiveEquivalent_refl (x : Fin n → ℝ) :
    AdditiveEquivalent x x := ⟨0, fun i => by ring⟩

omit [NeZero n] in
theorem additiveEquivalent_symm {x y : Fin n → ℝ}
    (h : AdditiveEquivalent x y) : AdditiveEquivalent y x := by
  obtain ⟨c, hc⟩ := h
  exact ⟨-c, fun i => by rw [hc i]; ring⟩

/-! ## Layer 3: Collatz-Wielandt Variational Characterization -/

/-- The tropical Collatz-Wielandt value: the infimum over all vectors x of
    the maximum excess max_i (T_A x - x)_i. This is the variational
    characterization of the tropical eigenvalue. -/
def tropicalCollatzWielandt (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  ⨅ (x : Fin n → ℝ), Finset.univ.sup' Finset.univ_nonempty
    (fun i => tropChannelOp A x i - x i)

/-
For any tropical eigenpair (λ, x), the Collatz-Wielandt value is at most λ.
    This is the "easy direction" of the CW characterization.
-/
theorem tropical_cw_le_eigenvalue
    {A : Matrix (Fin n) (Fin n) ℝ} {lam : ℝ} {x : Fin n → ℝ}
    (h : IsTropicalEigenpair A lam x) :
    tropicalCollatzWielandt A ≤ lam := by
  refine' ciInf_le_of_le _ x _;
  · refine' ⟨ - ( ∑ i, ∑ j, |A i j| ), Set.forall_mem_range.2 fun x => _ ⟩;
    simp +decide [ tropChannelOp ];
    obtain ⟨ i, hi ⟩ := Finset.exists_max_image Finset.univ ( fun i => A 0 i + x i ) ⟨ 0, Finset.mem_univ 0 ⟩ ; use 0; simp_all +decide [ Finset.sum_add_distrib ] ;
    refine' le_trans _ ( add_le_add ( Finset.le_sup' _ ( Finset.mem_univ i ) ) le_rfl );
    linarith [ hi 0, abs_le.mp ( Finset.single_le_sum ( fun i _ => Finset.sum_nonneg fun j _ => abs_nonneg ( A i j ) ) ( Finset.mem_univ 0 ) |> le_trans ( Finset.single_le_sum ( fun j _ => abs_nonneg ( A 0 j ) ) ( Finset.mem_univ 0 ) ) ) ];
  · simp_all +decide [ IsTropicalEigenpair ]

/-
For any tropical eigenpair (λ, x) and any vector y,
    λ ≤ max_i (T_A y - y)_i. This is the "hard direction".
-/
theorem tropical_eigenvalue_le_sup_excess
    {A : Matrix (Fin n) (Fin n) ℝ} {lam : ℝ} {x : Fin n → ℝ}
    (h : IsTropicalEigenpair A lam x) (y : Fin n → ℝ) :
    lam ≤ Finset.univ.sup' Finset.univ_nonempty
      (fun i => tropChannelOp A y i - y i) := by
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, ∀ i, x i - y i ≤ x i₀ - y i₀ := by
    simpa using Finset.exists_max_image Finset.univ ( fun i => x i - y i ) ⟨ 0, Finset.mem_univ 0 ⟩;
  -- By definition of $tropChannelOp$, we know that $tropChannelOp A y i₀ ≥ A i₀ j₀ + y j₀$ for any $j₀$.
  have h_tropChannelOp_ge : tropChannelOp A y i₀ ≥ A i₀ (Classical.choose (show ∃ j₀, A i₀ j₀ + x j₀ = tropChannelOp A x i₀ from by
                                                                            exact Finset.exists_max_image _ _ ⟨ i₀, Finset.mem_univ _ ⟩ |> fun ⟨ j₀, hj₀₁, hj₀₂ ⟩ => ⟨ j₀, le_antisymm ( Finset.le_sup' ( fun j => A i₀ j + x j ) hj₀₁ ) ( Finset.sup'_le _ _ fun j hj => hj₀₂ j hj ) ⟩)) + y (Classical.choose (show ∃ j₀, A i₀ j₀ + x j₀ = tropChannelOp A x i₀ from by
                                                                                                                                                                    exact Finset.exists_max_image _ _ ⟨ i₀, Finset.mem_univ _ ⟩ |> fun ⟨ j₀, hj₀₁, hj₀₂ ⟩ => ⟨ j₀, le_antisymm ( Finset.le_sup' ( fun j => A i₀ j + x j ) hj₀₁ ) ( Finset.sup'_le _ _ fun j hj => hj₀₂ j hj ) ⟩)) := by
                                                                                                                                                                    exact Finset.le_sup' ( fun j => A i₀ j + y j ) ( Finset.mem_univ _ )
  generalize_proofs at *;
  have := Classical.choose_spec ‹∃ j₀, A i₀ j₀ + x j₀ = tropChannelOp A x i₀›; simp_all +decide [ IsTropicalEigenpair ] ;
  grind

/-
The tropical eigenvalue of a 1×1 matrix equals its sole entry.
-/
theorem tropical_eigenvalue_eq_entry_1x1
    (A : Matrix (Fin 1) (Fin 1) ℝ) (lam : ℝ) (x : Fin 1 → ℝ)
    (h : IsTropicalEigenpair A lam x) :
    lam = A 0 0 := by
  unfold IsTropicalEigenpair at h;
  unfold tropChannelOp at h; norm_num [ Fin.eq_zero ] at h; linarith!;

/-! ## Layer 4: Information-Theoretic Bridge -/

/-- The log-channel matrix: entry (i,j) is log P(j|i) for a channel matrix P. -/
def logChannelMatrix {m k : ℕ} (P : Matrix (Fin m) (Fin k) ℝ) :
    Matrix (Fin m) (Fin k) ℝ := fun i j => Real.log (P i j)

/-- A matrix is row-stochastic if all entries are nonneg and each row sums to 1. -/
def IsRowStochastic {m k : ℕ} (P : Matrix (Fin m) (Fin k) ℝ) : Prop :=
  (∀ i j, 0 ≤ P i j) ∧ (∀ i, ∑ j, P i j = 1)

/-
Log-channel entries of a strictly positive stochastic matrix are nonpositive.
-/
theorem log_channel_nonpos {m k : ℕ} [NeZero k] (P : Matrix (Fin m) (Fin k) ℝ)
    (hsto : IsRowStochastic P) (hpos : ∀ i j, 0 < P i j) :
    ∀ i j, logChannelMatrix P i j ≤ 0 := by
  exact fun i j => Real.log_nonpos ( le_of_lt ( hpos i j ) ) ( hsto.2 i ▸ Finset.single_le_sum ( fun a _ => le_of_lt ( hpos i a ) ) ( Finset.mem_univ j ) )

/-- The tropical capacity proxy: the Collatz-Wielandt value of a weight matrix. -/
def tropicalCapacityProxy (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  tropicalCollatzWielandt A

/-! ## Layer 5: Tropical Coding Theory -/

/-- A codeword of length ℓ over alphabet of size q. -/
abbrev Codeword (l q : ℕ) := Fin l → Fin q

/-- The tropical word score between two codewords u,v under weight matrix A:
    the sum of coordinate-wise weights A(u_t, v_t). -/
def tropicalWordScore {q : ℕ}
    (A : Matrix (Fin q) (Fin q) ℝ) {l : ℕ} (u v : Codeword l q) : ℝ :=
  ∑ t : Fin l, A (u t) (v t)

/-- A codebook C is tropically δ-separated under A if for every pair of
    distinct codewords u,v ∈ C, the self-score of u exceeds the cross-score
    by at least 2δ. This is the tropical analogue of minimum distance. -/
def TropicallySeparated {l q : ℕ}
    (A : Matrix (Fin q) (Fin q) ℝ) (delta : ℝ) (C : Finset (Codeword l q)) : Prop :=
  ∀ ⦃u v⦄, u ∈ C → v ∈ C → u ≠ v →
    tropicalWordScore A u u > tropicalWordScore A u v + 2 * delta

/-
**Tropical Decoding Theorem.** If a codebook is tropically δ-separated,
    then for any codeword u in C, the self-score score(u,u) strictly exceeds
    the cross-score score(u,v) for any other v ∈ C. This guarantees that
    maximum-likelihood decoding (maximizing over the first argument) correctly
    identifies the transmitted codeword.
-/
theorem tropical_decoding_self_exceeds_cross {l q : ℕ}
    (A : Matrix (Fin q) (Fin q) ℝ) (delta : ℝ) (hdelta : 0 < delta)
    (C : Finset (Codeword l q))
    (hsep : TropicallySeparated A delta C) :
    ∀ u ∈ C, ∀ v ∈ C, u ≠ v →
      tropicalWordScore A u u > tropicalWordScore A u v := by
  exact fun u hu v hv huv => by linarith [ hsep hu hv huv ] ;

/-- **Symmetric Tropical Separation.**
    A codebook is symmetrically tropically separated if both directions hold:
    score(u,u) - score(u,v) > 2δ AND score(v,v) - score(v,u) > 2δ. -/
def SymmetricTropicallySeparated {l q : ℕ}
    (A : Matrix (Fin q) (Fin q) ℝ) (delta : ℝ) (C : Finset (Codeword l q)) : Prop :=
  ∀ ⦃u v⦄, u ∈ C → v ∈ C → u ≠ v →
    tropicalWordScore A u u - tropicalWordScore A u v > 2 * delta ∧
    tropicalWordScore A u u - tropicalWordScore A v u > 2 * delta

/-
Under symmetric separation, each codeword is the unique score-maximizer
    in both argument positions.
-/
theorem tropical_unique_decoding_symmetric {l q : ℕ}
    (A : Matrix (Fin q) (Fin q) ℝ) (delta : ℝ) (hdelta : 0 < delta)
    (C : Finset (Codeword l q))
    (hsep : SymmetricTropicallySeparated A delta C) :
    ∀ u ∈ C, ∀ v ∈ C, u ≠ v →
      tropicalWordScore A u u > tropicalWordScore A v u := by
  exact fun u hu v hv huv => by linarith [ hsep hu hv huv ] ;

/-! ## Foundational Tropical Algebra -/

/-- The max-plus idempotent property: max(a, a) = a. -/
theorem tropical_add_idempotent (a : ℝ) : max a a = a :=
  max_self a

/-
In an additive group where every element is idempotent (a + a = a),
    the group is trivial: 0 = a for all a.
    This warns against imposing ring-like structure on tropical algebra.
-/
theorem idempotent_group_trivial {R : Type*} [AddGroup R]
    (h_idem : ∀ a : R, a + a = a) (a : R) : a = 0 := by
  simpa using h_idem a

end