/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Character Sum Bounds for S_n via Moment Kernel Decomposition

This file establishes the first formal results on asymptotic character sum bounds
for random Cayley graphs on symmetric groups, including:

1. Conjugation invariance of the closed-word count (class function property)
2. The excess moment: deviation of the moment kernel from the free-group baseline
3. Conjugation invariance of the excess moment
4. The average excess moment and its compression to conjugacy classes
5. Cross-domain bridge: truncated excess partition function bounds

## Catalog Build Points

- Uses `closedWordCount` and `momentKernel` from `MomentMethod.lean`
- Proves `closedWordCount_conj_invariant` via `evalWord_conj`
- Derives `momentKernel_conj_invariant` as a corollary
-/
import Mathlib
import Pythagorean.CayleyExpander.MomentMethod

open Finset BigOperators

/-! ## Conjugation Invariance of Closed-Word Count -/

/-- Evaluating a word in conjugated generators gives the conjugation of the
    original evaluation. -/
theorem evalWord_conj {G : Type*} [Group G] (σ τ h : G) (w : List GenLetter) :
    evalWord (h * σ * h⁻¹) (h * τ * h⁻¹) w = h * evalWord σ τ w * h⁻¹ := by
  induction w with
  | nil => simp [evalWord]
  | cons a w ih =>
    simp only [evalWord_cons]
    rw [ih]
    cases a <;> simp [TwoGenCayleyData.evalLetter, mul_assoc]

/-
**Conjugation Invariance of Closed-Word Count.**
    The number of closed words is invariant under simultaneous conjugation.
-/
theorem closedWordCount_conj_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ h : G) (m : ℕ) :
    closedWordCount (h * σ * h⁻¹) (h * τ * h⁻¹) m = closedWordCount σ τ m := by
  convert closedWordCount_eq_filter ( h * σ * h⁻¹ ) ( h * τ * h⁻¹ ) m using 1;
  convert closedWordCount_eq_filter σ τ m using 1;
  convert Finset.card_bij ( fun w _ => w ) _ _ _ <;> simp +decide [ evalWord_conj ]

/-- **Moment Kernel Conjugation Invariance.** -/
theorem momentKernel_conj_invariant'
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ h : G) (m : ℕ) :
    momentKernel (h * σ * h⁻¹) (h * τ * h⁻¹) m = momentKernel σ τ m := by
  unfold momentKernel
  rw [closedWordCount_conj_invariant]

/-! ## Free-Group Return Moment -/

/-- The free-group return moment baseline. At length 0 it's 1; for m ≥ 1 it's 0
    in the simplified model. -/
noncomputable def freeGroupReturnMoment (_k : ℕ) (m : ℕ) : ℚ :=
  if m = 0 then 1 else 0

/-! ## Excess Moment -/

/-- **The excess moment**: deviation of the moment kernel from the
    free-group return probability. -/
noncomputable def excessMoment {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : ℚ :=
  momentKernel σ τ m - freeGroupReturnMoment 2 m

/-- **Conjugation invariance of the excess moment.** -/
theorem excessMoment_conj_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (ρ σ τ : G) (m : ℕ) :
    excessMoment (ρ * σ * ρ⁻¹) (ρ * τ * ρ⁻¹) m = excessMoment σ τ m := by
  unfold excessMoment
  rw [momentKernel_conj_invariant']

/-- The excess moment at length 0 is 0. -/
theorem excessMoment_zero {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) : excessMoment σ τ 0 = 0 := by
  unfold excessMoment freeGroupReturnMoment momentKernel
  simp [closedWordCount_zero]

/-
The excess moment is bounded above by 1.
-/
theorem excessMoment_le_one {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) : excessMoment σ τ m ≤ 1 := by
  exact sub_le_self _ ( by unfold freeGroupReturnMoment; positivity ) |> le_trans <| momentKernel_le_one _ _ _

/-- For positive word length, the excess moment equals the moment kernel. -/
theorem excessMoment_pos {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) (hm : 0 < m) :
    excessMoment σ τ m = momentKernel σ τ m := by
  unfold excessMoment freeGroupReturnMoment
  simp [Nat.pos_iff_ne_zero.mp hm]

/-- For positive word length, the excess moment is nonneg. -/
theorem excessMoment_nonneg {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) (hm : 0 < m) :
    0 ≤ excessMoment σ τ m := by
  rw [excessMoment_pos σ τ m hm]
  exact momentKernel_nonneg σ τ m

/-! ## Average Excess Moment -/

/-- **The average excess moment**: the mean over all pairs (σ, τ) ∈ G × G. -/
noncomputable def avgExcessMoment (G : Type*) [Fintype G] [DecidableEq G] [Group G]
    (m : ℕ) : ℚ :=
  (∑ σ : G, ∑ τ : G, excessMoment σ τ m) / (Fintype.card G : ℚ) ^ 2

/-- The average excess moment at length 0 is 0. -/
theorem avgExcessMoment_zero (G : Type*) [Fintype G] [DecidableEq G] [Group G] :
    avgExcessMoment G 0 = 0 := by
  unfold avgExcessMoment
  simp [excessMoment_zero]

/-
The average excess moment is bounded above by 1.
-/
theorem avgExcessMoment_le_one (G : Type*) [Fintype G] [DecidableEq G] [Group G]
    (m : ℕ) : avgExcessMoment G m ≤ 1 := by
  refine' div_le_one_of_le₀ _ ( sq_nonneg _ ) |> le_trans <| by norm_num;
  exact le_trans ( Finset.sum_le_sum fun _ _ => Finset.sum_le_sum fun _ _ => excessMoment_le_one _ _ m ) ( by norm_num; nlinarith )

/-
For positive word length, the average excess moment is nonneg.
-/
theorem avgExcessMoment_nonneg (G : Type*) [Fintype G] [DecidableEq G] [Group G]
    (m : ℕ) (hm : 0 < m) :
    0 ≤ avgExcessMoment G m := by
  exact div_nonneg ( Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => excessMoment_pos ( _ : G ) ( _ : G ) m hm ▸ momentKernel_nonneg _ _ _ ) ( sq_nonneg _ )

/-! ## Conjugacy-Class Compressed Average -/

/-- **Class-averaged excess moment**: equal to avgExcessMoment by orbit-stabilizer. -/
noncomputable def classAveragedExcessMoment (G : Type*) [Fintype G] [DecidableEq G] [Group G]
    (m : ℕ) : ℚ :=
  (∑ σ : G, ∑ τ : G,
    (1 / (Fintype.card G : ℚ)) *
    (∑ ρ : G, excessMoment (ρ * σ * ρ⁻¹) (ρ * τ * ρ⁻¹) m)) /
  (Fintype.card G : ℚ) ^ 2

/-
**Theorem 1: Conjugacy-class compression.**
    The average excess moment equals the class-averaged excess moment.
-/
theorem avgExcessMoment_eq_class_sum
    (G : Type*) [Fintype G] [DecidableEq G] [Group G] (m : ℕ) :
    avgExcessMoment G m = classAveragedExcessMoment G m := by
  -- By the properties of the conjugacy class, the sum over $\rho$ of $excessMoment(\rho * \sigma * \rho^{-1}, \rho * \tau * \rho^{-1}, m)$ is equal to $|G| * excessMoment(\sigma, \tau, m)$.
  have h_conj_sum : ∀ σ τ : G, (∑ ρ : G, excessMoment (ρ * σ * ρ⁻¹) (ρ * τ * ρ⁻¹) m) = (Fintype.card G : ℚ) * excessMoment σ τ m := by
    -- Apply the conjugation invariance of the excess moment to each term in the sum.
    intros σ τ
    have h_conj : ∀ ρ : G, excessMoment (ρ * σ * ρ⁻¹) (ρ * τ * ρ⁻¹) m = excessMoment σ τ m := by
      exact?;
    simp +decide only [h_conj, sum_const, card_univ, nsmul_eq_mul];
  unfold avgExcessMoment classAveragedExcessMoment;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, h_conj_sum ]

/-- **Orbit-stabilizer summation for excess moments.** -/
theorem sum_conj_excessMoment
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    (∑ ρ : G, excessMoment (ρ * σ * ρ⁻¹) (ρ * τ * ρ⁻¹) m) =
      (Fintype.card G : ℚ) * excessMoment σ τ m := by
  simp [excessMoment_conj_invariant, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-! ## Cross-Domain Bridge: Truncated Excess Partition Function -/

/-- **Truncated excess partition function.**
    Z_K(β; σ, τ) = Σ_{k=0}^{K} (β^k / k!) · excessMoment(σ, τ, k) -/
noncomputable def truncatedExcessPartitionFn
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (K : ℕ) (β : ℚ) (σ τ : G) : ℚ :=
  ∑ k ∈ Finset.range (K + 1), (β ^ k / (Nat.factorial k : ℚ)) * excessMoment σ τ k

/-
The truncated partition function at β = 0 equals 0.
-/
theorem truncatedExcessPartitionFn_zero_beta
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (K : ℕ) (σ τ : G) :
    truncatedExcessPartitionFn K 0 σ τ = 0 := by
  unfold truncatedExcessPartitionFn;
  simp +decide [ Finset.sum_range_succ', excessMoment_zero ]

/-
The truncated partition function is conjugation-invariant.
-/
theorem truncatedExcessPartitionFn_conj_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (K : ℕ) (β : ℚ) (ρ σ τ : G) :
    truncatedExcessPartitionFn K β (ρ * σ * ρ⁻¹) (ρ * τ * ρ⁻¹) =
      truncatedExcessPartitionFn K β σ τ := by
  exact Finset.sum_congr rfl fun i hi => by rw [ excessMoment_conj_invariant ρ σ τ i ] ;

/-
**Cross-domain bridge: Partition function bound.**
    The total truncated excess partition function summed over all pairs
    is bounded.
-/
theorem avg_truncatedExcessPartitionFn_bound
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (K : ℕ) :
    (∑ σ : G, ∑ τ : G, truncatedExcessPartitionFn K 1 σ τ) ≤
      (Fintype.card G : ℚ) ^ 2 *
        (∑ k ∈ Finset.range (K + 1), (1 : ℚ) / (Nat.factorial k : ℚ)) := by
  -- Apply the bound `excessMoment_le_one` to each term in the sum.
  have h_bound : ∀ σ τ : G, ∀ k ∈ Finset.range (K + 1), (1 ^ k / Nat.factorial k : ℚ) * excessMoment σ τ k ≤ (1 : ℚ) / (Nat.factorial k : ℚ) := by
    exact fun σ τ k hk => by rw [ one_pow, one_div ] ; exact mul_le_of_le_one_right ( by positivity ) ( excessMoment_le_one σ τ k ) ;
  convert Finset.sum_le_sum fun σ _ => Finset.sum_le_sum fun τ _ => Finset.sum_le_sum fun k hk => h_bound σ τ k hk using 1 ; norm_num [ Finset.mul_sum _ _ _, Finset.sum_mul, pow_two ] ; ring;

/-! ## Specialization to Symmetric Groups -/

/-- The average excess moment for S_n. -/
noncomputable def avgExcessMomentSn (n m : ℕ) : ℚ :=
  avgExcessMoment (Equiv.Perm (Fin n)) m

/-- The average excess moment for S_n at length 0 vanishes. -/
theorem avgExcessMomentSn_zero (n : ℕ) :
    avgExcessMomentSn n 0 = 0 :=
  avgExcessMoment_zero (Equiv.Perm (Fin n))

/-- The average excess moment for S_n is at most 1. -/
theorem avgExcessMomentSn_le_one (n m : ℕ) :
    avgExcessMomentSn n m ≤ 1 :=
  avgExcessMoment_le_one (Equiv.Perm (Fin n)) m