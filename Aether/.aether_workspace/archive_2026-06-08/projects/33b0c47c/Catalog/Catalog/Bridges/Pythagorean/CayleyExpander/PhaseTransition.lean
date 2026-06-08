/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Phase Transition for Augmented Cayley Walks on (ℤ/nℤ)²

This file develops the Fourier-analytic spectral theory of augmented Cayley
walks on the finite torus (ℤ/nℤ)², establishing foundational results for
the spectral phase transition under growing augmentation.

## Main Definitions

* `eigTerm` — single-generator Laplacian eigenvalue contribution at a character
* `laplaceEig` — total Laplacian eigenvalue of a generating set at a character
* `charCosSum` — character cosine sum (real part of Fourier coefficient)
* `nontrivChars` — the set of nontrivial characters on (ℤ/nℤ)²
* `spectralGap` — minimum nontrivial Laplacian eigenvalue
* `localGens` — standard local generators {(±1,0),(0,±1)}
* `fourierBias` — maximum nontrivial character sum magnitude
* `gapRatio` — spectral gap ratio measuring augmentation effect
* `SubcriticalGrowth` — the condition k³ ≤ C·n² (Lean-friendly n^{2/3} threshold)

## Main Results

* `laplaceEig_mono` — **Theorem 1**: Eigenvalue monotonicity under augmentation
* `spectralGap_mono` — **Theorem 2**: Spectral gap monotonicity (S ⊆ T → gap(S) ≤ gap(T))
* `gapRatio_ge_one` — Augmentation can only help: ratio ≥ 1
* `laplaceEig_eq_card_sub_charCosSum` — Structural: λ_S(k) = |S| - Σcos
* `laplaceEig_ge_card_sub_fourierBias` — **Theorem 3**: Fourier bias controls eigenvalue
* `spectralGap_disjoint_union_ge` — **Theorem 4**: Gap of union ≥ sum of gaps
* `spectralGap_boost_of_low_bias` — **Theorem 5**: Pseudorandom augmentation → gap boost
* `localGap_pos` — Local spectral gap is positive for n ≥ 2
* `laplaceEig_le_two_card` — Upper bound: eigenvalue ≤ 2|S|
* `gapRatio_le_of_augSize` — Upper bound on ratio from augmentation size

## Mathematical Context

On the abelian group (ℤ/nℤ)², the random walk Laplacian diagonalizes in
the character basis. The eigenvalue at character k = (k₁,k₂) for generating
set S is λ_S(k) = Σ_{s∈S} (1 - cos(2π⟨k,s⟩/n)). This explicit formula
enables precise spectral analysis of augmentation effects.

The conjectural critical augmentation scale is n^{2/3}, encoded as k³ ≤ C·n²
to avoid irrational exponents.
-/
import Mathlib

open Finset BigOperators Real

namespace SpectralPhaseTransition

/-! ## Section 1: Core Definitions -/

variable {n : ℕ} [NeZero n]

/-- A finset of group elements is symmetric: s ∈ S implies -s ∈ S. -/
def SymmFinset (S : Finset ((ZMod n) × (ZMod n))) : Prop :=
  ∀ s ∈ S, -s ∈ S

/-- Single-generator Laplacian eigenvalue contribution at character k from generator s.
    This equals 1 - Re(χ_k(s)) = 1 - cos(2π · val(k₁s₁ + k₂s₂) / n). -/
noncomputable def eigTerm (k s : (ZMod n) × (ZMod n)) : ℝ :=
  1 - Real.cos (2 * π * ((k.1 * s.1 + k.2 * s.2 : ZMod n).val : ℝ) / (n : ℝ))

/-- The Laplacian eigenvalue of generating set S at character k:
    λ_S(k) = Σ_{s ∈ S} (1 - cos(2π · val(k₁s₁ + k₂s₂) / n)). -/
noncomputable def laplaceEig (S : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) : ℝ :=
  ∑ s ∈ S, eigTerm k s

/-- The character cosine sum: Σ_{s ∈ S} cos(2π · val(k₁s₁ + k₂s₂) / n). -/
noncomputable def charCosSum (S : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) : ℝ :=
  ∑ s ∈ S, Real.cos (2 * π * ((k.1 * s.1 + k.2 * s.2 : ZMod n).val : ℝ) / (n : ℝ))

/-- Nontrivial characters on (ℤ/nℤ)². -/
def nontrivChars : Finset ((ZMod n) × (ZMod n)) :=
  Finset.univ.filter (· ≠ (0, 0))

/-- An admissible augmentation is a symmetric finset. -/
def IsAdmissibleAug (A : Finset ((ZMod n) × (ZMod n))) : Prop :=
  SymmFinset A

/-- Subcritical growth condition: k³ ≤ C · n².
    This encodes the n^{2/3} threshold in Lean-friendly integer arithmetic. -/
def SubcriticalGrowth (k C m : ℕ) : Prop := k ^ 3 ≤ C * m ^ 2

/-- Supercritical growth condition: C · n² ≤ k³. -/
def SupercriticalGrowth (k C m : ℕ) : Prop := C * m ^ 2 ≤ k ^ 3

/-! ## Section 2: Nontrivial Characters -/

/-- (1, 0) is a nontrivial character when n ≥ 2. -/
theorem one_zero_nontrivial (hn : 2 ≤ n) :
    ((1 : ZMod n), (0 : ZMod n)) ≠ (0, 0) := by
  intro h
  have h1 : (1 : ZMod n) = 0 := congr_arg Prod.fst h
  haveI : Fact (1 < n) := ⟨by omega⟩
  exact one_ne_zero h1

/-- Nontrivial characters are nonempty for n ≥ 2. -/
theorem nontrivChars_nonempty (hn : 2 ≤ n) :
    (nontrivChars (n := n)).Nonempty :=
  ⟨((1 : ZMod n), (0 : ZMod n)),
   Finset.mem_filter.mpr ⟨Finset.mem_univ _, one_zero_nontrivial hn⟩⟩

/-- The spectral gap: minimum Laplacian eigenvalue over nontrivial characters. -/
noncomputable def spectralGap (hn : 2 ≤ n)
    (S : Finset ((ZMod n) × (ZMod n))) : ℝ :=
  (nontrivChars (n := n)).inf' (nontrivChars_nonempty hn) (laplaceEig S)

/-- Standard local generators on (ℤ/nℤ)²: {(1,0), (-1,0), (0,1), (0,-1)}. -/
def localGens : Finset ((ZMod n) × (ZMod n)) :=
  {((1 : ZMod n), (0 : ZMod n)), ((-1 : ZMod n), (0 : ZMod n)),
   ((0 : ZMod n), (1 : ZMod n)), ((0 : ZMod n), (-1 : ZMod n))}

/-- The spectral gap ratio: gap(T) / gap(S). -/
noncomputable def gapRatio (hn : 2 ≤ n)
    (S T : Finset ((ZMod n) × (ZMod n))) : ℝ :=
  spectralGap hn T / spectralGap hn S

/-- Fourier bias: max_{k ≠ 0} |charCosSum(A, k)|. -/
noncomputable def fourierBias (hn : 2 ≤ n)
    (A : Finset ((ZMod n) × (ZMod n))) : ℝ :=
  (nontrivChars (n := n)).sup' (nontrivChars_nonempty hn) (fun k => |charCosSum A k|)

/-! ## Section 3: Basic Properties of eigTerm -/

/-- Each eigenvalue contribution is nonneg: 1 - cos(θ) ≥ 0. -/
theorem eigTerm_nonneg (k s : (ZMod n) × (ZMod n)) : 0 ≤ eigTerm k s :=
  sub_nonneg.mpr (Real.cos_le_one _)

/-- Each eigenvalue contribution is at most 2: 1 - cos(θ) ≤ 2. -/
theorem eigTerm_le_two (k s : (ZMod n) × (ZMod n)) : eigTerm k s ≤ 2 := by
  unfold eigTerm; linarith [Real.neg_one_le_cos
    (2 * π * ((k.1 * s.1 + k.2 * s.2 : ZMod n).val : ℝ) / (n : ℝ))]

/-- At the trivial character (0,0), every eigenvalue contribution is 0. -/
theorem eigTerm_zero_char (s : (ZMod n) × (ZMod n)) :
    eigTerm ((0 : ZMod n), (0 : ZMod n)) s = 0 := by
  unfold eigTerm
  simp [ZMod.val_zero, Real.cos_zero]

/-! ## Section 4: Properties of laplaceEig -/

/-- The Laplacian eigenvalue is nonneg (sum of nonneg terms). -/
theorem laplaceEig_nonneg (S : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) : 0 ≤ laplaceEig S k :=
  Finset.sum_nonneg fun s _ => eigTerm_nonneg k s

/-- The Laplacian eigenvalue is at most 2|S|. -/
theorem laplaceEig_le_two_card (S : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) :
    laplaceEig S k ≤ 2 * (S.card : ℝ) := by
  unfold laplaceEig
  calc ∑ s ∈ S, eigTerm k s
      ≤ ∑ s ∈ S, (2 : ℝ) := Finset.sum_le_sum fun s _ => eigTerm_le_two k s
    _ = 2 * S.card := by simp [Finset.sum_const, nsmul_eq_mul]; ring

/-- At the trivial character, the eigenvalue is 0. -/
theorem laplaceEig_zero_char (S : Finset ((ZMod n) × (ZMod n))) :
    laplaceEig S (0, 0) = 0 := by
  simp [laplaceEig, eigTerm_zero_char]

/-- **Theorem 1: Eigenvalue Monotonicity.**
    Adding generators can only increase the Laplacian eigenvalue at any character.
    S ⊆ T implies λ_S(k) ≤ λ_T(k) for all characters k.

    This is the algebraic backbone: augmentation is a perturbation that
    can only help mixing, because each new generator contributes a
    nonneg term (1 - cos) to the eigenvalue sum. -/
theorem laplaceEig_mono {S T : Finset ((ZMod n) × (ZMod n))}
    (hST : S ⊆ T) (k : (ZMod n) × (ZMod n)) :
    laplaceEig S k ≤ laplaceEig T k :=
  Finset.sum_le_sum_of_subset_of_nonneg hST fun s _ _ => eigTerm_nonneg k s

/-- Eigenvalue decomposition for disjoint union.
    If S and A are disjoint, λ_{S∪A}(k) = λ_S(k) + λ_A(k). -/
theorem laplaceEig_disjoint_union {S A : Finset ((ZMod n) × (ZMod n))}
    (hd : Disjoint S A) (k : (ZMod n) × (ZMod n)) :
    laplaceEig (S ∪ A) k = laplaceEig S k + laplaceEig A k :=
  Finset.sum_union hd

/-- Eigenvalue of union = eigenvalue of first + eigenvalue of sdiff.
    λ_{S∪A}(k) = λ_S(k) + λ_{A∖S}(k). -/
theorem laplaceEig_union (S A : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) :
    laplaceEig (S ∪ A) k = laplaceEig S k + laplaceEig (A \ S) k := by
  unfold laplaceEig
  rw [← Finset.union_sdiff_self_eq_union (s := S) (t := A)]
  exact Finset.sum_union Finset.disjoint_sdiff

/-! ## Section 5: Structural Identity: Eigenvalue = Card - CosineSum -/

/-- **Key structural identity**: the Laplacian eigenvalue equals
    the cardinality minus the cosine character sum.
    λ_S(k) = |S| - Σ_{s∈S} cos(2π⟨k,s⟩/n).

    This identity is the bridge between spectral graph theory
    and Fourier analysis on finite abelian groups. -/
theorem laplaceEig_eq_card_sub_charCosSum (S : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) :
    laplaceEig S k = (S.card : ℝ) - charCosSum S k := by
  unfold laplaceEig charCosSum eigTerm
  simp [Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul]

/-- The cosine sum is bounded above by the cardinality. -/
theorem charCosSum_le_card (S : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) :
    charCosSum S k ≤ (S.card : ℝ) := by
  linarith [laplaceEig_nonneg S k, laplaceEig_eq_card_sub_charCosSum S k]

/-- The absolute value of the cosine sum is bounded by the cardinality. -/
theorem abs_charCosSum_le_card (S : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) :
    |charCosSum S k| ≤ (S.card : ℝ) := by
  rw [abs_le]
  exact ⟨by linarith [laplaceEig_le_two_card S k, laplaceEig_eq_card_sub_charCosSum S k],
         charCosSum_le_card S k⟩

/-! ## Section 6: Spectral Gap Monotonicity -/

/-- Helper: pointwise inequality implies inf' inequality. -/
theorem inf'_le_inf'_of_le {s : Finset ((ZMod n) × (ZMod n))}
    (hs : s.Nonempty) (f g : (ZMod n) × (ZMod n) → ℝ)
    (h : ∀ x ∈ s, f x ≤ g x) :
    s.inf' hs f ≤ s.inf' hs g :=
  Finset.le_inf' hs g fun b hb => le_trans (Finset.inf'_le f hb) (h b hb)

/-- **Theorem 2: Spectral Gap Monotonicity.**
    If S ⊆ T, then gap(S) ≤ gap(T). Adding generators can only improve
    the spectral gap, which is the minimum nontrivial eigenvalue.

    Combined with the eigenvalue monotonicity (Theorem 1), this shows that
    augmentation is universally beneficial for mixing. -/
theorem spectralGap_mono {S T : Finset ((ZMod n) × (ZMod n))}
    (hn : 2 ≤ n) (hST : S ⊆ T) :
    spectralGap hn S ≤ spectralGap hn T := by
  exact inf'_le_inf'_of_le (nontrivChars_nonempty hn) _ _
    fun k _ => laplaceEig_mono hST k

/-- The spectral gap ratio is ≥ 1 when S ⊆ T and gap(S) > 0. -/
theorem gapRatio_ge_one {S T : Finset ((ZMod n) × (ZMod n))}
    (hn : 2 ≤ n) (hST : S ⊆ T) (hpos : 0 < spectralGap hn S) :
    1 ≤ gapRatio hn S T := by
  unfold gapRatio
  rw [le_div_iff₀ hpos]
  linarith [spectralGap_mono hn hST]

/-- The spectral gap of S is at most the eigenvalue at any nontrivial character. -/
theorem spectralGap_le_laplaceEig (hn : 2 ≤ n)
    (S : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) (hk : k ≠ (0, 0)) :
    spectralGap hn S ≤ laplaceEig S k := by
  unfold spectralGap
  exact Finset.inf'_le (laplaceEig S) (Finset.mem_filter.mpr ⟨Finset.mem_univ k, hk⟩)

/-- The spectral gap is nonneg. -/
theorem spectralGap_nonneg (hn : 2 ≤ n)
    (S : Finset ((ZMod n) × (ZMod n))) :
    0 ≤ spectralGap hn S := by
  unfold spectralGap
  exact Finset.le_inf' _ _ fun k hk => laplaceEig_nonneg S k

/-! ## Section 7: Fourier Bias and Spectral Lower Bounds -/

/-- **Theorem 3 (per-character): Fourier bias controls eigenvalue from below.**
    λ_A(k) ≥ |A| - |charCosSum(A, k)|.

    This follows directly from λ = |A| - cos_sum and |x| ≥ x. -/
theorem laplaceEig_ge_card_sub_abs_charCosSum
    (A : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) :
    (A.card : ℝ) - |charCosSum A k| ≤ laplaceEig A k := by
  rw [laplaceEig_eq_card_sub_charCosSum]
  linarith [le_abs_self (charCosSum A k)]

/-
**Theorem 3 (uniform): Fourier bias controls eigenvalue from below.**
    For any nontrivial character k: λ_A(k) ≥ |A| - fourierBias(A).

    This is the quantitative bridge between additive combinatorics
    and spectral graph theory: if A is pseudorandom (low bias),
    then it contributes uniformly to all nontrivial eigenvalues.
-/
theorem laplaceEig_ge_card_sub_fourierBias (hn : 2 ≤ n)
    (A : Finset ((ZMod n) × (ZMod n)))
    (k : (ZMod n) × (ZMod n)) (hk : k ≠ (0, 0)) :
    (A.card : ℝ) - fourierBias hn A ≤ laplaceEig A k := by
  -- By definition of fourierBias, we know that for any nontrivial character k, |charCosSum A k| ≤ fourierBias hn A.
  have h_fourierBias_le : ∀ k ∈ nontrivChars (n := n), |charCosSum A k| ≤ fourierBias hn A := by
    exact fun k hk => Finset.le_sup' ( fun k => |charCosSum A k| ) hk;
  linarith [ laplaceEig_eq_card_sub_charCosSum A k, abs_le.mp ( h_fourierBias_le k ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hk ⟩ ) ) ]

/-
The fourierBias is nonneg.
-/
theorem fourierBias_nonneg (hn : 2 ≤ n)
    (A : Finset ((ZMod n) × (ZMod n))) : 0 ≤ fourierBias hn A := by
  exact Finset.le_sup' ( fun k => |charCosSum A k| ) ( nontrivChars_nonempty hn |> Classical.choose_spec ) |> le_trans ( abs_nonneg _ )

/-
The fourierBias is bounded by |A|.
-/
theorem fourierBias_le_card (hn : 2 ≤ n)
    (A : Finset ((ZMod n) × (ZMod n))) :
    fourierBias hn A ≤ (A.card : ℝ) := by
  exact Finset.sup'_le _ _ fun x hx => le_trans ( abs_charCosSum_le_card A x ) ( by norm_num ) ;

/-! ## Section 8: Gap of Union — The Fundamental Bound -/

/-
Helper: inf' distributes over addition as a lower bound.
    min_{k} (f(k) + g(k)) ≥ min_{k} f(k) + min_{k} g(k).
-/
theorem inf'_add_ge {s : Finset ((ZMod n) × (ZMod n))} (hs : s.Nonempty)
    (f g : (ZMod n) × (ZMod n) → ℝ) :
    s.inf' hs f + s.inf' hs g ≤ s.inf' hs (fun k => f k + g k) := by
  simp +zetaDelta at *;
  exact fun a b hab => add_le_add ( Finset.inf'_le _ hab ) ( Finset.inf'_le _ hab )

/-
**Theorem 4: Gap of disjoint union ≥ sum of individual gaps.**
    spectralGap(S ∪ A) ≥ spectralGap(S) + spectralGap(A) when S ∩ A = ∅.

    This is the quantitative foundation for the phase transition:
    each augmentation set contributes independently to the spectral gap,
    and the contributions are additive (at least as a lower bound).
-/
theorem spectralGap_disjoint_union_ge (hn : 2 ≤ n)
    {S A : Finset ((ZMod n) × (ZMod n))} (hd : Disjoint S A) :
    spectralGap hn S + spectralGap hn A ≤ spectralGap hn (S ∪ A) := by
  convert inf'_add_ge _ _ _ using 2;
  · exact congr_arg _ ( funext fun k => laplaceEig_disjoint_union hd k );
  · grind +splitIndPred

/-
**Theorem 5: Pseudorandom augmentation boosts the spectral gap.**
    If A \ S has small Fourier bias (≤ ε), then:
      gap(S ∪ A) ≥ gap(S) + |A \ S| - ε.

    This is the cross-domain bridge connecting:
    • Markov chain mixing (spectral gap)
    • Fourier analysis on finite groups (character sums)
    • Additive combinatorics (pseudorandomness/bias)

    The key insight is that pseudorandom subsets of (ℤ/nℤ)²
    act as "spectral equalizers," boosting ALL nontrivial eigenvalues
    nearly uniformly.
-/
theorem spectralGap_boost_of_low_bias (hn : 2 ≤ n)
    (S A : Finset ((ZMod n) × (ZMod n)))
    (ε : ℝ)
    (hbias : fourierBias hn (A \ S) ≤ ε) :
    spectralGap hn S + ((A \ S).card : ℝ) - ε ≤ spectralGap hn (S ∪ A) := by
  -- Applying the definition of spectral gap, we have:
  have h_gap_union : spectralGap hn (S ∪ A) ≥ spectralGap hn S + spectralGap hn (A \ S) := by
    convert spectralGap_disjoint_union_ge hn ( Finset.disjoint_sdiff ) |> le_trans <| ?_;
    rw [ Finset.union_sdiff_self_eq_union ];
  -- By definition of $spectralGap$, we know that
  have h_spectralGap_def : spectralGap hn (A \ S) ≥ (A \ S).card - fourierBias hn (A \ S) := by
    -- By definition of $spectralGap$, we know that for any nontrivial character $k$, $laplaceEig (A \ S) k \geq |A \ S| - fourierBias hn (A \ S)$.
    have h_laplaceEig_ge : ∀ k : (ZMod n) × (ZMod n), k ≠ (0, 0) → laplaceEig (A \ S) k ≥ (A \ S).card - fourierBias hn (A \ S) :=
      fun k hk => laplaceEig_ge_card_sub_fourierBias hn (A \ S) k hk
    refine' le_trans _ ( inf'_le_inf'_of_le _ _ _ _ );
    rotate_left;
    use fun k => ( A \ S |> Finset.card : ℝ ) - fourierBias hn ( A \ S );
    · exact fun k hk => h_laplaceEig_ge k <| Finset.mem_filter.mp hk |>.2;
    · simp +decide [ Finset.inf'_le ];
  linarith

/-! ## Section 9: Upper Bound on Spectral Gap Ratio -/

/-
The spectral gap of S ∪ A is at most gap(S) + 2|A|.
    This provides the complementary upper bound: augmentation
    helps, but its benefit is bounded by twice the number of
    added generators.
-/
theorem spectralGap_union_le (hn : 2 ≤ n)
    (S A : Finset ((ZMod n) × (ZMod n))) :
    spectralGap hn (S ∪ A) ≤ spectralGap hn S + 2 * (A.card : ℝ) := by
  -- By definition of spectral gap, we have:
  have h_spectralGap : ∀ k : (ZMod n) × (ZMod n), k ≠ (0, 0) → laplaceEig (S ∪ A) k ≤ laplaceEig S k + 2 * (A.card : ℝ) := by
    intros k hk_ne_zero
    have h_laplaceEig_union : laplaceEig (S ∪ A) k = laplaceEig S k + laplaceEig (A \ S) k := by
      exact laplaceEig_union S A k
    linarith [ laplaceEig_le_two_card ( A \ S ) k, show ( A \ S |> Finset.card : ℝ ) ≤ A.card by exact_mod_cast Finset.card_le_card fun x hx => by aesop ];
  have h_inf : (nontrivChars (n := n)).inf' (nontrivChars_nonempty  hn) (fun k => laplaceEig (S ∪ A) k) ≤ (nontrivChars (n := n)).inf' (nontrivChars_nonempty  hn) (fun k => laplaceEig S k + 2 * (A.card : ℝ)) := by
    apply inf'_le_inf'_of_le;
    exact fun k hk => h_spectralGap k <| Finset.mem_filter.mp hk |>.2;
  convert h_inf using 1;
  refine' le_antisymm _ _ <;> simp_all +decide [ spectralGap ];
  · exact fun a b hab => ⟨ a, b, hab, le_rfl ⟩;
  · have := Finset.exists_min_image ( nontrivChars ( n := n ) ) ( fun k => laplaceEig S k ) ( nontrivChars_nonempty hn ) ; aesop;

/-
Upper bound on spectral gap ratio from augmentation size:
    ratio ≤ 1 + 2|A|/gap(S).

    Together with the lower bound gapRatio ≥ 1, this sandwiches
    the ratio and shows the augmentation effect is controlled.
-/
theorem gapRatio_le_of_augSize (hn : 2 ≤ n)
    (S A : Finset ((ZMod n) × (ZMod n)))
    (hpos : 0 < spectralGap hn S) :
    gapRatio hn S (S ∪ A) ≤ 1 + 2 * (A.card : ℝ) / spectralGap hn S := by
  rw [ add_div', le_div_iff₀ ];
  · unfold gapRatio; nlinarith [ spectralGap_union_le hn S A, mul_div_cancel₀ ( spectralGap hn ( S ∪ A ) ) hpos.ne' ] ;
  · grobner;
  · positivity

/-! ## Section 10: Local Gap Positivity -/

/-
For 0 < θ < 2π, we have cos(θ) < 1, hence 1 - cos(θ) > 0.
-/
theorem cos_lt_one_of_pos_lt_two_pi {θ : ℝ} (h1 : 0 < θ) (h2 : θ < 2 * π) :
    Real.cos θ < 1 := by
  by_cases h_eq : θ = Real.pi;
  · norm_num [ h_eq ];
  · by_cases h_pi : θ < Real.pi;
    · nlinarith [ Real.sin_sq_add_cos_sq θ, Real.sin_pos_of_pos_of_lt_pi h1 h_pi ];
    · rw [ ← Real.cos_two_pi_sub ] ; exact by rw [ ← Real.cos_zero ] ; exact Real.cos_lt_cos_of_nonneg_of_le_pi ( by linarith ) ( by linarith ) ( by contrapose! h_eq; linarith ) ;

/-
**The local spectral gap is positive for n ≥ 2.**
    This ensures the spectral gap ratio is well-defined and meaningful.

    The gap is achieved at a coordinate frequency (1,0) or (0,1),
    where the eigenvalue equals 2(1 - cos(2π/n)) > 0.
-/
theorem localGap_pos (hn : 2 ≤ n) :
    0 < spectralGap hn (localGens (n := n)) := by
  -- By definition of $spectralGap$, we know that
  have h_spectralGap_def : ∀ (k : (ZMod n) × (ZMod n)), k ≠ (0, 0) → laplaceEig localGens k > 0 := by
    intro k hk_ne
    have h_eigenvalue_pos : eigTerm k ((1 : ZMod n), (0 : ZMod n)) > 0 ∨ eigTerm k ((0 : ZMod n), (1 : ZMod n)) > 0 := by
      by_cases hk1 : k.1 = 0 <;> by_cases hk2 : k.2 = 0 <;> simp_all +decide [ eigTerm ];
      · exact hk_ne ( Prod.ext hk1 hk2 );
      · have h_cos_lt_one : 0 < 2 * Real.pi * (k.2.val : ℝ) / n ∧ 2 * Real.pi * (k.2.val : ℝ) / n < 2 * Real.pi := by
          have h_cos_lt_one : 0 < k.2.val ∧ k.2.val < n := by
            exact ⟨ Nat.pos_of_ne_zero ( by simpa [ ZMod.val_eq_zero ] using hk2 ), ZMod.val_lt _ ⟩;
          exact ⟨ div_pos ( mul_pos ( mul_pos two_pos Real.pi_pos ) ( Nat.cast_pos.mpr h_cos_lt_one.1 ) ) ( Nat.cast_pos.mpr ( by linarith ) ), by rw [ div_lt_iff₀ ( Nat.cast_pos.mpr ( by linarith ) ) ] ; nlinarith [ Real.pi_pos, show ( k.2.val : ℝ ) < n by exact_mod_cast h_cos_lt_one.2 ] ⟩;
        convert cos_lt_one_of_pos_lt_two_pi h_cos_lt_one.1 h_cos_lt_one.2 using 1;
        rcases n with ( _ | _ | n ) <;> norm_cast;
      · -- Since $k.1 \neq 0$, we have $0 < k.1.val < n$, thus $0 < 2\pi k.1.val / n < 2\pi$.
        have h_angle_pos : 0 < 2 * Real.pi * k.1.val / n ∧ 2 * Real.pi * k.1.val / n < 2 * Real.pi := by
          have h_angle_pos : 0 < k.1.val ∧ k.1.val < n := by
            exact ⟨ Nat.pos_of_ne_zero ( by simpa [ ZMod.val_eq_zero ] using hk1 ), ZMod.val_lt _ ⟩;
          exact ⟨ div_pos ( mul_pos ( mul_pos two_pos Real.pi_pos ) ( Nat.cast_pos.mpr h_angle_pos.1 ) ) ( Nat.cast_pos.mpr ( pos_of_gt hn ) ), by rw [ div_lt_iff₀ ( Nat.cast_pos.mpr ( pos_of_gt hn ) ) ] ; nlinarith [ Real.pi_pos, show ( k.1.val : ℝ ) < n by exact_mod_cast h_angle_pos.2 ] ⟩;
        have := cos_lt_one_of_pos_lt_two_pi h_angle_pos.1 h_angle_pos.2; aesop;
      · refine' Or.inl ( cos_lt_one_of_pos_lt_two_pi _ _ ) <;> norm_num [ hk1, hk2, NeZero.pos ];
        · rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod ];
          exact mul_pos ( by positivity ) ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero ( by simpa [ ZMod.natCast_eq_zero_iff ] using hk1 ) ) );
        · rw [ div_lt_iff₀ ( by positivity ) ];
          gcongr;
          rcases n with ( _ | _ | n ) <;> norm_cast;
          exact Nat.cast_lt.mpr ( Fin.is_lt _ );
    cases h_eigenvalue_pos <;> [ exact lt_of_lt_of_le ‹_› ( Finset.single_le_sum ( fun x _ => eigTerm_nonneg k x ) ( by simp +decide [ localGens ] ) ) ; exact lt_of_lt_of_le ‹_› ( Finset.single_le_sum ( fun x _ => eigTerm_nonneg k x ) ( by simp +decide [ localGens ] ) ) ];
  -- Since the infimum is taken over a finite set, it is attained.
  obtain ⟨k, hk⟩ : ∃ k ∈ nontrivChars (n := n), laplaceEig localGens k = spectralGap hn localGens := by
    have h_inf_achieved : ∃ k ∈ nontrivChars (n := n), ∀ j ∈ nontrivChars (n := n), laplaceEig localGens k ≤ laplaceEig localGens j := by
      exact Finset.exists_min_image _ _ ⟨ _, Finset.mem_filter.mpr ⟨ Finset.mem_univ ( 1, 0 ), one_zero_nontrivial hn ⟩ ⟩;
    obtain ⟨ k, hk₁, hk₂ ⟩ := h_inf_achieved;
    exact ⟨ k, hk₁, le_antisymm ( Finset.le_inf' _ _ fun x hx => hk₂ x hx ) ( Finset.inf'_le _ hk₁ ) ⟩;
  exact hk.2 ▸ h_spectralGap_def k ( Finset.mem_filter.mp hk.1 |>.2 )

/-! ## Section 11: Phase Transition Framework -/

/-- **Subcritical ratio bound (from eigenvalue upper bound):**
    When the ratio 2|A|/gap(S) is bounded by K,
    the spectral gap ratio is bounded by 1 + K.

    This is the quantitative version of "bounded augmentation
    preserves local spectral scaling." -/
theorem subcritical_ratio_from_upper_bound (hn : 2 ≤ n)
    (S A : Finset ((ZMod n) × (ZMod n)))
    (K : ℝ) (hK : 2 * (A.card : ℝ) / spectralGap hn S ≤ K)
    (hpos : 0 < spectralGap hn S) :
    gapRatio hn S (S ∪ A) ≤ 1 + K :=
  le_trans (gapRatio_le_of_augSize hn S A hpos) (by linarith)

/-
**Supercritical acceleration (from Fourier bias bound):**
    If the augmentation is large and pseudorandom (small bias),
    the gap ratio grows proportionally to the augmentation size.

    gap(S ∪ A) / gap(S) ≥ 1 + (|A \ S| - ε) / gap(S).

    This shows universality genuinely breaks: with enough pseudorandom
    generators, the bounded-ratio phenomenon is overwhelmed.
-/
theorem supercritical_from_bias (hn : 2 ≤ n)
    (S A : Finset ((ZMod n) × (ZMod n)))
    (ε : ℝ)
    (hpos : 0 < spectralGap hn S)
    (hbias : fourierBias hn (A \ S) ≤ ε) :
    1 + ((A \ S).card - ε) / spectralGap hn S ≤ gapRatio hn S (S ∪ A) := by
  convert div_le_div_of_nonneg_right ( spectralGap_boost_of_low_bias hn S A ε hbias ) hpos.le using 1;
  rw [ add_div' ] <;> ring ; positivity

/-! ## Section 12: Falsifiable Conjecture -/

/-- **Phase Transition Conjecture (formal statement):**
    For the torus (ℤ/nℤ)², the critical augmentation scale is n^{2/3},
    encoded as k³ ≤ C·n² in integer arithmetic.

    Below this scale: the spectral gap ratio remains uniformly bounded
    for ALL admissible augmentations.

    Above this scale: there EXIST augmentations making the ratio arbitrarily large.

    This is stated as a definition rather than a theorem, since it remains
    a conjecture. The theorems above provide partial evidence:
    - Theorem 2 shows the ratio is always ≥ 1
    - Theorem 5 shows pseudorandom augmentation can boost the gap
    - The upper bound shows the ratio is controlled by augmentation size -/
def PhaseTransitionConjecture : Prop :=
  ∃ (c C : ℕ), 0 < c ∧ 0 < C ∧
    -- Subcritical: ratio bounded for ALL augmentations
    (∃ K : ℝ, 0 < K ∧
      ∀ (n : ℕ) [NeZero n] (hn : 2 ≤ n)
        (A : Finset ((ZMod n) × (ZMod n))),
        IsAdmissibleAug A →
        SubcriticalGrowth A.card c n →
        gapRatio hn (localGens) (localGens ∪ A) ≤ K) ∧
    -- Supercritical: ratio unbounded for SOME augmentations
    (∀ M : ℝ, ∃ (n : ℕ), ∃ (_ : NeZero n), ∃ (hn : 2 ≤ n),
      ∃ (A : Finset ((ZMod n) × (ZMod n))),
        IsAdmissibleAug A ∧
        SupercriticalGrowth A.card C n ∧
        M ≤ gapRatio hn (localGens) (localGens ∪ A))

end SpectralPhaseTransition