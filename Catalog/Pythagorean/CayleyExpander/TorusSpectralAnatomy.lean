/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Anatomy of Augmented Discrete Tori

This file develops the exact spectral theory of Cayley graphs on discrete tori
G_{n,d} = (ℤ/nℤ)^d, with both local generators (standard basis vectors ±eᵢ)
and a hybrid generator set that adds the diagonal ±δ where δ = (1,1,…,1).

## Main Results

* `circEigenvalue_nonneg` — circulant eigenvalues are nonneg
* `circEigenvalue_eq_four_sin_sq` — 2−2cos = 4sin² identity
* `spectralGapLocal_eq` — γ_loc(n,d) = 4sin²(π/n) (Theorem A)
* `hybridEigenvalue_eq_local_plus_diag` — exact hybrid eigenvalue formula (Theorem B)
* `hybridGap_eq_two_localGap` — γ_hyb(n,d) = 2·γ_loc(n,d) (Theorem C, corrected)
* `spectralGapRatio_eq_two` — the ratio is universally 2, independent of d

## Mathematical Context

The original conjecture posited γ_hyb/γ_loc = (d+1)/d. This is TRUE for d=1
(where (d+1)/d = 2) but FALSE for d ≥ 2. The correct universal ratio is 2.

The key insight is that the spectral gap minimizer is always a coordinate frequency
k = eᵢ, at which the diagonal generator δ contributes exactly the same eigenvalue
increment as a single local generator. This produces the universal doubling.
-/
import Mathlib

open Finset BigOperators Real

/-! ## Circulant Eigenvalue: the building block -/

/-- The eigenvalue of the 1D circulant Laplacian on ℤ/nℤ at frequency k:
    λ(k) = 2 − 2cos(2πk/n). -/
noncomputable def circEigenvalue (n : ℕ) (k : ℕ) : ℝ :=
  2 - 2 * Real.cos (2 * Real.pi * k / n)

/-- Circulant eigenvalue in the equivalent sine-squared form. -/
theorem circEigenvalue_eq_four_sin_sq (n : ℕ) (k : ℕ) :
    circEigenvalue n k = 4 * Real.sin (Real.pi * k / n) ^ 2 := by
  unfold circEigenvalue; rw [Real.sin_sq, Real.cos_sq]; ring

/-- Circulant eigenvalue is always nonneg. -/
theorem circEigenvalue_nonneg (n : ℕ) (k : ℕ) :
    0 ≤ circEigenvalue n k :=
  circEigenvalue_eq_four_sin_sq n k ▸ by positivity

/-- Circulant eigenvalue at k=0 is 0. -/
theorem circEigenvalue_zero (n : ℕ) (hn : 0 < n) :
    circEigenvalue n 0 = 0 := by
  simp [circEigenvalue, Real.cos_zero]

/-! ## Torus Eigenvalues -/

/-- The local Laplacian eigenvalue on (ℤ/nℤ)^d at frequency k:
    λ_loc(k) = Σⱼ (2 − 2cos(2πkⱼ/n)). -/
noncomputable def torusLocalEigenvalue (n d : ℕ) (k : Fin d → ZMod n) : ℝ :=
  ∑ i : Fin d, circEigenvalue n (k i).val

/-- The hybrid Laplacian eigenvalue with diagonal generator δ=(1,…,1):
    λ_hyb(k) = λ_loc(k) + (2 − 2cos(2π(k₁+…+k_d)/n)). -/
noncomputable def torusHybridEigenvalue (n d : ℕ) (k : Fin d → ZMod n) : ℝ :=
  torusLocalEigenvalue n d k + circEigenvalue n ((∑ i : Fin d, (k i).val) % n)

/-- The hybrid eigenvalue = local + diagonal (Theorem B). -/
theorem hybridEigenvalue_eq_local_plus_diag (n d : ℕ) (k : Fin d → ZMod n) :
    torusHybridEigenvalue n d k =
      (∑ i : Fin d, circEigenvalue n (k i).val) +
      circEigenvalue n ((∑ i : Fin d, (k i).val) % n) := rfl

/-- Local eigenvalue is nonneg. -/
theorem torusLocalEigenvalue_nonneg (n d : ℕ) (k : Fin d → ZMod n) :
    0 ≤ torusLocalEigenvalue n d k :=
  Finset.sum_nonneg fun i _ => circEigenvalue_nonneg n (k i).val

/-- Hybrid eigenvalue is nonneg. -/
theorem torusHybridEigenvalue_nonneg (n d : ℕ) (k : Fin d → ZMod n) :
    0 ≤ torusHybridEigenvalue n d k :=
  add_nonneg (torusLocalEigenvalue_nonneg n d k) (circEigenvalue_nonneg n _)

/-- Hybrid eigenvalue in sine-squared form (Theorem B, sine form). -/
theorem torusHybridEigenvalue_sin_sq (n d : ℕ) (k : Fin d → ZMod n) :
    torusHybridEigenvalue n d k =
      4 * (∑ i : Fin d, Real.sin (Real.pi * ((k i).val : ℝ) / n) ^ 2) +
      4 * Real.sin (Real.pi * (((∑ i : Fin d, (k i).val) % n : ℕ) : ℝ) / n) ^ 2 := by
  unfold torusHybridEigenvalue torusLocalEigenvalue
  simp only [circEigenvalue_eq_four_sin_sq]
  rw [Finset.mul_sum _ _ _]

/-! ## Spectral Gap Definitions -/

/-- The set of nonzero frequency vectors on (ℤ/nℤ)^d. -/
noncomputable def nonzeroFreqs (n d : ℕ) [NeZero n] : Finset (Fin d → ZMod n) :=
  Finset.univ.filter (· ≠ 0)

/-
The nonzero frequency set is nonempty when n ≥ 2 and d ≥ 1.
-/
theorem nonzeroFreqs_nonempty (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (hd : 1 ≤ d) :
    (nonzeroFreqs n d).Nonempty := by
  -- Since the function that maps everything to 1 is nonzero when n ≥ 2, we can conclude that nonzeroFreqs n d has the element fun _ => 1.
  have h_nonzero : (fun _ : Fin d => 1) ∈ nonzeroFreqs n d := by
    simp +decide [ nonzeroFreqs ];
    simp +decide [ funext_iff ];
    rcases n with ( _ | _ | n ) <;> rcases d with ( _ | _ | d ) <;> norm_num [ Fin.ext_iff, ZMod ] at *;
    · exact ⟨ ⟨ 0 ⟩, by simp +decide [ ZMod ] ⟩;
    · exact ⟨ ⟨ 0 ⟩, by rintro ⟨ ⟩ ⟩;
  exact ⟨ _, h_nonzero ⟩

/-- The spectral gap of the local Laplacian: minimum eigenvalue over nonzero frequencies. -/
noncomputable def spectralGapLocal (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (hd : 1 ≤ d) : ℝ :=
  (nonzeroFreqs n d).inf' (nonzeroFreqs_nonempty n d hn hd) (torusLocalEigenvalue n d)

/-- The spectral gap of the hybrid Laplacian. -/
noncomputable def spectralGapHybrid (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (hd : 1 ≤ d) : ℝ :=
  (nonzeroFreqs n d).inf' (nonzeroFreqs_nonempty n d hn hd) (torusHybridEigenvalue n d)

/-! ## Coordinate Frequencies -/

/-- A coordinate frequency vector: value 1 in position j, 0 elsewhere. -/
noncomputable def coordFreq (n d : ℕ) [NeZero n] (j : Fin d) : Fin d → ZMod n :=
  fun i => if i = j then 1 else 0

/-- A coordinate frequency is nonzero (for n ≥ 2). -/
theorem coordFreq_ne_zero (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (j : Fin d) :
    coordFreq n d j ≠ 0 := by
  intro h; have := congr_fun h j; simp [coordFreq] at this
  rcases n with (_ | _ | n) <;> cases this; contradiction

/-- Coordinate frequency is in the nonzero frequency set. -/
theorem coordFreq_mem_nonzeroFreqs (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (j : Fin d) :
    coordFreq n d j ∈ nonzeroFreqs n d := by
  simp [nonzeroFreqs, coordFreq_ne_zero n d hn j]

/-- The local eigenvalue at a coordinate frequency equals circEigenvalue n 1. -/
theorem localEigenvalue_at_coordFreq (n d : ℕ) [NeZero n] (j : Fin d) :
    torusLocalEigenvalue n d (coordFreq n d j) = circEigenvalue n 1 := by
  unfold torusLocalEigenvalue coordFreq
  erw [Finset.sum_eq_single j] <;> simp +contextual
  · rcases n with (_ | _ | n) <;> norm_num [ZMod.val] at *
    unfold circEigenvalue; norm_num [mul_div]
  · exact fun _ _ => circEigenvalue_zero n (NeZero.pos n)

/-
The hybrid eigenvalue at a coordinate frequency equals 2 · circEigenvalue n 1.
-/
theorem hybridEigenvalue_at_coordFreq (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (j : Fin d) :
    torusHybridEigenvalue n d (coordFreq n d j) = 2 * circEigenvalue n 1 := by
  rw [ torusHybridEigenvalue ];
  -- Since these are all equal to 1, their sum is also 1.
  have h_sum : ∑ i : Fin d, (coordFreq n d j i).val = 1 := by
    rw [ Finset.sum_eq_single j ] <;> simp +decide [ coordFreq ];
    · rcases n with ( _ | _ | n ) <;> norm_cast;
    · aesop;
  rw [ h_sum, Nat.mod_eq_of_lt hn ] ; rw [ localEigenvalue_at_coordFreq ] ; ring;

/-! ## Cosine Minimization Lemma -/

/-
For n ≥ 2, cos(2πk/n) ≤ cos(2π/n) for all k ∈ {1,…,n−1}.
-/
theorem cos_maximized_at_one (n : ℕ) (hn : 2 ≤ n) (k : ℕ)
    (hk : 1 ≤ k) (hk' : k ≤ n - 1) :
    Real.cos (2 * Real.pi * k / n) ≤ Real.cos (2 * Real.pi / n) := by
  by_cases hk'' : k ≤ n / 2;
  · refine' Real.cos_le_cos_of_nonneg_of_le_pi _ _ _ <;> nlinarith [ Real.pi_pos, show ( k : ℝ ) ≥ 1 by norm_cast, show ( n : ℝ ) ≥ k * 2 by norm_cast; linarith [ Nat.div_mul_le_self n 2 ], mul_div_cancel₀ ( 2 * Real.pi * k ) ( by positivity : ( n : ℝ ) ≠ 0 ), mul_div_cancel₀ ( 2 * Real.pi ) ( by positivity : ( n : ℝ ) ≠ 0 ) ];
  · rw [ ← Real.cos_two_pi_sub ];
    refine' Real.cos_le_cos_of_nonneg_of_le_pi _ _ _ <;> nlinarith [ Real.pi_pos, show ( k : ℝ ) ≥ n / 2 + 1 / 2 by exact by rw [ div_add_div, ge_iff_le, div_le_iff₀ ] <;> norm_cast ; linarith [ Nat.div_add_mod n 2, Nat.mod_lt n two_pos ], show ( k : ℝ ) ≤ n - 1 by exact le_tsub_of_add_le_right <| by norm_cast; linarith [ Nat.sub_add_cancel ( by linarith : 1 ≤ n ) ], mul_div_cancel₀ ( 2 * Real.pi * k ) ( by positivity : ( n : ℝ ) ≠ 0 ), mul_div_cancel₀ ( 2 * Real.pi ) ( by positivity : ( n : ℝ ) ≠ 0 ) ] ;

/-- The circulant eigenvalue is minimized at k=1 among nonzero frequencies. -/
theorem circEigenvalue_min_at_one (n : ℕ) (hn : 2 ≤ n) (k : ℕ)
    (hk : 1 ≤ k) (hk' : k ≤ n - 1) :
    circEigenvalue n 1 ≤ circEigenvalue n k := by
  unfold circEigenvalue
  have h := cos_maximized_at_one n hn k hk hk'
  simp only [Nat.cast_one, mul_one] at *
  linarith

/-- For a nonzero ZMod element, the circulant eigenvalue is ≥ circEigenvalue n 1. -/
theorem circEigenvalue_ge_at_nonzero (n : ℕ) [NeZero n] (hn : 2 ≤ n) (a : ZMod n)
    (ha : a ≠ 0) :
    circEigenvalue n 1 ≤ circEigenvalue n a.val := by
  apply circEigenvalue_min_at_one n hn a.val
  · exact Nat.one_le_iff_ne_zero.mpr (mt (ZMod.val_eq_zero a).mp ha)
  · exact Nat.le_sub_one_of_lt (ZMod.val_lt a)

/-! ## Local Eigenvalue Lower Bound -/

/-
Any nonzero frequency has local eigenvalue ≥ circEigenvalue n 1.
-/
theorem torusLocalEigenvalue_ge_circ_one (n d : ℕ) (hn : 2 ≤ n)
    (k : Fin d → ZMod n) (hk : k ≠ 0) :
    circEigenvalue n 1 ≤ torusLocalEigenvalue n d k := by
  -- Since k ≠ 0, there exists j : Fin d such that k j ≠ 0.
  obtain ⟨j, hj⟩ : ∃ j : Fin d, k j ≠ 0 := by
    exact Function.ne_iff.mp hk;
  convert le_trans _ ( Finset.single_le_sum ( fun i _ => circEigenvalue_nonneg n ( k i |> ZMod.val ) ) ( Finset.mem_univ j ) ) using 1;
  convert circEigenvalue_ge_at_nonzero n hn ( k j ) hj using 1;
  exact ⟨ by linarith ⟩

/-! ## Theorem A: Exact Local Spectral Gap -/

/-
**Theorem A**: The spectral gap of the local torus Laplacian is exactly
    4sin²(π/n) = 2 − 2cos(2π/n).
    The minimum is achieved at any coordinate frequency eᵢ.
-/
theorem spectralGapLocal_eq (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (hd : 1 ≤ d) :
    spectralGapLocal n d hn hd = 4 * Real.sin (Real.pi / n) ^ 2 := by
  refine' le_antisymm _ _;
  · refine' le_trans ( Finset.inf'_le _ <| coordFreq_mem_nonzeroFreqs n d hn ⟨ 0, hd ⟩ ) _ ; norm_num [ localEigenvalue_at_coordFreq, circEigenvalue_eq_four_sin_sq ];
  · -- By definition of $spectralGapLocal$, we know that for any $k \in nonzeroFreqs$, $circEigenvalue n 1 \leq torusLocalEigenvalue n d k$.
    have h_le : ∀ k ∈ nonzeroFreqs n d, circEigenvalue n 1 ≤ torusLocalEigenvalue n d k := by
      exact fun k hk => torusLocalEigenvalue_ge_circ_one n d hn k <| Finset.mem_filter.mp hk |>.2;
    convert Finset.le_inf' _ _ h_le using 1;
    convert circEigenvalue_eq_four_sin_sq n 1 |> Eq.symm using 2 ; ring

/-! ## Theorem C: The Corrected Spectral Gap Ratio -/

/-
Key lemma: for any nonzero k, the hybrid eigenvalue is ≥ 2 · circEigenvalue n 1.

    Proof by cases:
    Case 1: Σ kⱼ ≢ 0 (mod n) → diagonal term ≥ circ(1), plus a nonzero coord ≥ circ(1).
    Case 2: Σ kⱼ ≡ 0 (mod n), k ≠ 0 → ≥ 2 coords nonzero, each ≥ circ(1).
-/
theorem hybridEigenvalue_ge_two_circ (n d : ℕ) (hn : 2 ≤ n)
    (k : Fin d → ZMod n) (hk : k ≠ 0) :
    2 * circEigenvalue n 1 ≤ torusHybridEigenvalue n d k := by
  -- By definition of $torusHybridEigenvalue$, we know that
  unfold torusHybridEigenvalue;
  by_cases h_sum : (∑ i, (k i).val) % n = 0;
  · -- Since the sum of the values is 0 modulo n, there must be at least two nonzero coordinates.
    obtain ⟨j₁, j₂, hj₁, hj₂, h_ne⟩ : ∃ j₁ j₂ : Fin d, j₁ ≠ j₂ ∧ (k j₁).val ≠ 0 ∧ (k j₂).val ≠ 0 := by
      by_contra h_contra;
      -- If there are no two distinct indices $j₁$ and $j₂$ such that $(k j₁).val ≠ 0$ and $(k j₂).val ≠ 0$, then there must be exactly one index $j$ such that $(k j).val ≠ 0$.
      obtain ⟨j, hj⟩ : ∃ j : Fin d, (k j).val ≠ 0 ∧ ∀ i : Fin d, i ≠ j → (k i).val = 0 := by
        obtain ⟨j, hj⟩ : ∃ j : Fin d, (k j).val ≠ 0 := by
          contrapose! hk; ext i; simp_all +decide [ ZMod.val_eq_zero ] ;
        exact ⟨ j, hj, fun i hi => Classical.not_not.1 fun hi' => h_contra ⟨ i, j, hi, hi', hj ⟩ ⟩;
      simp_all +decide [ Finset.sum_eq_single j ];
      haveI := Fact.mk ( by linarith : 1 < n ) ; simp_all +decide [ ← ZMod.val_natCast ] ;
    have h_local_ge_two_circ : circEigenvalue n 1 ≤ circEigenvalue n (k j₁).val ∧ circEigenvalue n 1 ≤ circEigenvalue n (k j₂).val := by
      apply And.intro;
      · apply circEigenvalue_min_at_one n hn (k j₁).val;
        · exact Nat.pos_of_ne_zero hj₂;
        · haveI := Fact.mk ( by linarith : 1 < n ) ; exact Nat.le_pred_of_lt ( ZMod.val_lt _ ) ;
      · convert circEigenvalue_min_at_one n hn ( ( k j₂ |> ZMod.val ) ) _ _ using 1;
        · exact Nat.pos_of_ne_zero h_ne;
        · haveI := Fact.mk ( by linarith : 1 < n ) ; exact Nat.le_pred_of_lt ( ZMod.val_lt _ ) ;
    have h_local_ge_two_circ : torusLocalEigenvalue n d k ≥ circEigenvalue n (k j₁).val + circEigenvalue n (k j₂).val := by
      have h_local_ge_two_circ : torusLocalEigenvalue n d k ≥ ∑ i ∈ {j₁, j₂}, circEigenvalue n (k i).val := by
        exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => circEigenvalue_nonneg _ _;
      rwa [ Finset.sum_pair hj₁ ] at h_local_ge_two_circ;
    linarith [ show circEigenvalue n ( ( ∑ i, ( k i |> ZMod.val ) ) % n ) ≥ 0 from circEigenvalue_nonneg n _ ];
  · -- Since $(∑ i, (k i).val) % n ≠ 0$, we have $1 ≤ (∑ i, (k i).val) % n ≤ n - 1$.
    have h_mod_range : 1 ≤ (∑ i, (k i).val) % n ∧ (∑ i, (k i).val) % n ≤ n - 1 := by
      exact ⟨ Nat.pos_of_ne_zero h_sum, Nat.le_pred_of_lt <| Nat.mod_lt _ <| pos_of_gt hn ⟩;
    linarith [ torusLocalEigenvalue_ge_circ_one n d hn k hk, circEigenvalue_min_at_one n hn ( ( ∑ i, ( k i |> ZMod.val ) ) % n ) h_mod_range.1 h_mod_range.2 ]

/-
**Theorem C (corrected)**: γ_hyb(n,d) = 2 · γ_loc(n,d).
    The true ratio is 2, not (d+1)/d.
-/
theorem hybridGap_eq_two_localGap (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (hd : 1 ≤ d) :
    spectralGapHybrid n d hn hd = 2 * spectralGapLocal n d hn hd := by
  refine' le_antisymm ( _ : _ ≤ _ ) ( _ : _ ≥ _ );
  · convert Finset.inf'_le _ ( coordFreq_mem_nonzeroFreqs n d hn ⟨ 0, hd ⟩ ) using 1;
    rw [ spectralGapLocal_eq, hybridEigenvalue_at_coordFreq ];
    · rw [ circEigenvalue_eq_four_sin_sq ] ; ring;
    · linarith;
  · simp_all +decide [ spectralGapLocal, spectralGapHybrid ];
    intros k hk
    apply le_trans _ (hybridEigenvalue_ge_two_circ n d hn k (by
    exact Finset.mem_filter.mp hk |>.2));
    refine' mul_le_mul_of_nonneg_left ( Finset.inf'_le _ <| coordFreq_mem_nonzeroFreqs n d hn ⟨ 0, hd ⟩ ) zero_le_two |> le_trans <| _;
    rw [ localEigenvalue_at_coordFreq ]

/-- The spectral gap ratio is universally 2. -/
theorem spectralGapRatio_eq_two (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (hd : 1 ≤ d)
    (h_pos : 0 < spectralGapLocal n d hn hd) :
    spectralGapHybrid n d hn hd / spectralGapLocal n d hn hd = 2 := by
  rw [hybridGap_eq_two_localGap n d hn hd]
  field_simp

/-- For d ≥ 2, the original conjecture (d+1)/d is strictly wrong. -/
theorem original_conjecture_false_for_d_ge_2 (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (hd : 2 ≤ d)
    (h_pos : 0 < spectralGapLocal n d hn (by omega)) :
    spectralGapHybrid n d hn (by omega) / spectralGapLocal n d hn (by omega) ≠
      ((d : ℝ) + 1) / d := by
  rw [spectralGapRatio_eq_two n d hn (by omega) h_pos]
  rw [Ne, eq_div_iff] <;> norm_cast <;> linarith

/-! ## Theorem D: Spectral Additivity for Graph Unions -/

/-- **Fourier-Sharp Augmentation**: captures spectral additivity of
    Cayley Laplacians on finite abelian groups in the character basis. -/
structure FourierSharpAugmentation (n d : ℕ) where
  eigA : (Fin d → ZMod n) → ℝ
  eigB : (Fin d → ZMod n) → ℝ
  additivity : ∀ k, torusHybridEigenvalue n d k = eigA k + eigB k
  eigA_nonneg : ∀ k, 0 ≤ eigA k
  eigB_nonneg : ∀ k, 0 ≤ eigB k

/-- The torus augmentation is Fourier-sharp. -/
noncomputable def torusFourierSharp (n d : ℕ) : FourierSharpAugmentation n d where
  eigA := torusLocalEigenvalue n d
  eigB k := circEigenvalue n ((∑ i : Fin d, (k i).val) % n)
  additivity _ := rfl
  eigA_nonneg := torusLocalEigenvalue_nonneg n d
  eigB_nonneg _ := circEigenvalue_nonneg n _

/-- Adding generators can only increase eigenvalues. -/
theorem hybridEigenvalue_ge_local (n d : ℕ) (k : Fin d → ZMod n) :
    torusLocalEigenvalue n d k ≤ torusHybridEigenvalue n d k := by
  unfold torusHybridEigenvalue
  linarith [circEigenvalue_nonneg n ((∑ i : Fin d, (k i).val) % n)]

/-! ## Theorem E: Mixing Time Comparison -/

/-- Relaxation time (inverse spectral gap). -/
noncomputable def relaxTime (gap : ℝ) : ℝ := 1 / gap

/-
**Theorem E**: Adding the diagonal generator halves the relaxation time.
-/
theorem relaxTime_hybrid_half (n d : ℕ) [NeZero n] (hn : 2 ≤ n) (hd : 1 ≤ d)
    (_h_pos : 0 < spectralGapLocal n d hn hd) :
    relaxTime (spectralGapHybrid n d hn hd) =
      (1 / 2) * relaxTime (spectralGapLocal n d hn hd) := by
  convert congr_arg ( fun x : ℝ => 1 / x ) ( hybridGap_eq_two_localGap n d hn hd ) using 1 ; norm_num [ relaxTime ] ; ring

/-- For d = 1, the corrected theorem agrees with the original conjecture. -/
theorem d_one_agrees (n : ℕ) [NeZero n] (hn : 2 ≤ n)
    (h_pos : 0 < spectralGapLocal n 1 hn (by omega)) :
    spectralGapHybrid n 1 hn (by omega) / spectralGapLocal n 1 hn (by omega) =
      ((1 : ℝ) + 1) / 1 := by
  rw [spectralGapRatio_eq_two n 1 hn (by omega) h_pos]
  norm_num

/-- A frequency vector is a "coordinate frequency" if it has exactly one nonzero entry. -/
def isCoordinateFrequency (n d : ℕ) (k : Fin d → ZMod n) : Prop :=
  ∃ j : Fin d, k j ≠ 0 ∧ ∀ i, i ≠ j → k i = 0