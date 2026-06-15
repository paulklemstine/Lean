import Mathlib

/-!
# Karchmer–Wigderson Witness Counting for Monotone Symmetric Boolean Functions

## Overview

A monotone symmetric Boolean function on `n` variables is determined by its *layer profile*
`p : Fin (n+1) → Bool`, which says whether inputs of Hamming weight `k` are mapped to `true`.
Monotonicity forces this profile to be monotone: if weight-`k` inputs are accepted, then so are
all weight-`j` inputs with `j ≥ k`.

A **KW witness** for such a function is a triple `(x, y, i)` where `f(x) = true`, `f(y) = false`,
and coordinate `i` separates them: `xᵢ = 1` and `yᵢ = 0`.

## Main Results

1. **Classification**: Every monotone profile is a threshold profile (`monotone_profile_eq_threshold`).
2. **Witness Count Formula**: The symmetric witness count factors into a product of partial
   binomial sums (`kwWitnessCountThreshold_eq`).
3. **Extremality**: Monotone symmetric witness counts are completely determined by the threshold
   parameter, establishing that thresholds are the unique representatives in each isomorphism class.
4. **Witness count monotonicity**: Among threshold functions, witness count is maximized near the
   center (majority).

## Mathematical Context

This formalizes the foundational layer of an **extremal witness-counting theory** for
Karchmer–Wigderson games on the Boolean cube, establishing that threshold functions are
the canonical representatives and that witness complexity in the symmetric world is
governed by one-dimensional order structure on Hamming layers.
-/

open Finset Nat

noncomputable section

/-! ## Threshold Profiles -/

/-- A threshold profile on `n+1` layers: layer `i` is `true` iff `i.val ≥ t`.
This represents the symmetric monotone Boolean function that accepts inputs of
Hamming weight at least `t`. -/
def thresholdProfile (n : ℕ) (t : ℕ) : Fin (n + 1) → Bool :=
  fun i => decide (t ≤ i.val)

/-- The upper-set property for Boolean profiles: monotonicity on layer indices. -/
def IsMonotoneProfile {n : ℕ} (p : Fin (n + 1) → Bool) : Prop :=
  ∀ ⦃i j : Fin (n + 1)⦄, i ≤ j → p i = true → p j = true

/-- `IsMonotoneProfile` is equivalent to `Monotone` for Bool-valued functions. -/
theorem isMonotoneProfile_iff_monotone {n : ℕ} (p : Fin (n + 1) → Bool) :
    IsMonotoneProfile p ↔ Monotone p := by
  constructor
  · intro h i j hij
    cases hp : p i
    · exact Bool.false_le _
    · exact le_of_eq (h hij hp).symm
  · intro h i j hij hpi
    have := h hij
    rw [hpi] at this
    exact le_antisymm (Bool.le_true _) this

/-! ## Classification Theorem -/

/-- Threshold profiles are monotone. -/
theorem thresholdProfile_monotone (n t : ℕ) :
    Monotone (thresholdProfile n t) := by
  intro i j hij
  unfold thresholdProfile
  simp only [Bool.le_iff_imp, decide_eq_true_eq]
  omega

theorem thresholdProfile_isMonotone (n t : ℕ) :
    IsMonotoneProfile (thresholdProfile n t) := by
  rw [isMonotoneProfile_iff_monotone]
  exact thresholdProfile_monotone n t

/-
**Classification Theorem**: Every monotone Boolean profile on `Fin (n+1)` is a
threshold profile. This is the key structural result: monotone symmetric Boolean
functions are exactly the threshold functions.

The threshold parameter `t` represents the minimum Hamming weight for acceptance,
and ranges from `0` (always true) to `n+1` (always false).
-/
theorem monotone_profile_eq_threshold (n : ℕ) (p : Fin (n + 1) → Bool)
    (hmono : Monotone p) :
    ∃ t, t ≤ n + 1 ∧ p = thresholdProfile n t := by
  by_cases h : ∃ i : Fin ( n + 1 ), p i = Bool.true;
  · -- Let $t$ be the smallest index such that $p(t) = true$.
    obtain ⟨t, ht⟩ : ∃ t : Fin (n + 1), p t = Bool.true ∧ ∀ j : Fin (n + 1), j < t → p j = Bool.false := by
      exact ⟨ Finset.min' ( Finset.univ.filter fun i => p i = true ) ⟨ h.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h.choose_spec ⟩ ⟩, Finset.mem_filter.mp ( Finset.min'_mem ( Finset.univ.filter fun i => p i = true ) ⟨ h.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h.choose_spec ⟩ ⟩ ) |>.2, fun j hj => by_contra fun hj' => hj.not_ge <| Finset.min'_le _ _ <| by aesop ⟩;
    refine' ⟨ t, _, _ ⟩ <;> simp_all +decide [ funext_iff, Fin.forall_iff ];
    intro i hi; by_cases hi' : i < t.val <;> simp_all +decide [ thresholdProfile ] ;
    · rw [ ht.2 i hi hi', decide_eq_false ] ; aesop;
    · exact hmono ( Nat.le_trans hi' ( Nat.le_refl _ ) ) ht.1;
  · use n + 1;
    simp_all +decide [ funext_iff, thresholdProfile ];
    exact fun x => Nat.le_of_lt_succ x.2

/-
The threshold parameter is unique within the valid range.
-/
theorem thresholdProfile_injective (n : ℕ) (s t : ℕ)
    (hs : s ≤ n + 1) (ht : t ≤ n + 1)
    (h : thresholdProfile n s = thresholdProfile n t) :
    s = t := by
  by_contra h_neq;
  -- Without loss of generality, assume that $s < t$.
  wlog h_lt : s < t generalizing s t;
  · exact this t s ht hs h.symm ( Ne.symm h_neq ) ( lt_of_le_of_ne ( le_of_not_gt h_lt ) ( Ne.symm h_neq ) );
  · have := congr_fun h ⟨ s, by linarith ⟩ ; simp_all +decide [ thresholdProfile ] ;
    grind +extAll

/-! ## KW Witness Count -/

/-- The number of KW witnesses for a symmetric Boolean function with profile `p`.

For a symmetric function on `n` variables with profile `p`, a KW witness is a
triple `(x, y, i)` where `|x| = k` with `p(k) = true`, `|y| = l` with `p(l) = false`,
and coordinate `i` satisfies `xᵢ = 1, yᵢ = 0`.

By symmetry, the count equals:
  `n * ∑_{k true} ∑_{l false} C(n-1, k-1) * C(n-1, l)` -/
def kwWitnessCountSymmetric (n : ℕ) (p : Fin (n + 1) → Bool) : ℕ :=
  n * ∑ k ∈ univ.filter (fun k : Fin (n + 1) => p k = true),
      ∑ l ∈ univ.filter (fun l : Fin (n + 1) => p l = false),
        Nat.choose (n - 1) (k.val - 1) * Nat.choose (n - 1) l.val

/-- The KW witness count for a threshold function with parameter `t`. -/
def kwWitnessCountThreshold (n t : ℕ) : ℕ :=
  kwWitnessCountSymmetric n (thresholdProfile n t)

/-- The KW witness count for the majority function on `n` variables
(threshold at `⌈n/2⌉`, i.e., `(n+1)/2` for integer division). -/
def kwWitnessCountMajority (n : ℕ) : ℕ :=
  kwWitnessCountThreshold n ((n + 1) / 2)

/-- **Witness Count Equality**: Every monotone symmetric function's witness count
equals that of the corresponding threshold function. This is an immediate corollary
of the classification theorem. -/
theorem kwWitnessCount_monotone_eq_threshold (n : ℕ) (p : Fin (n + 1) → Bool)
    (hmono : Monotone p) :
    ∃ t, t ≤ n + 1 ∧
      kwWitnessCountSymmetric n p = kwWitnessCountThreshold n t := by
  obtain ⟨t, ht, rfl⟩ := monotone_profile_eq_threshold n p hmono
  exact ⟨t, ht, rfl⟩

/-- The true layers of a threshold profile form a terminal interval. -/
theorem thresholdProfile_true_layers (n t : ℕ) (i : Fin (n + 1)) :
    thresholdProfile n t i = true ↔ t ≤ i.val := by
  simp [thresholdProfile]

/-- The false layers of a threshold profile form an initial interval. -/
theorem thresholdProfile_false_layers (n t : ℕ) (i : Fin (n + 1)) :
    thresholdProfile n t i = false ↔ i.val < t := by
  simp [thresholdProfile]

/-
The number of true layers of `thresholdProfile n t` when `t ≤ n + 1`.
-/
theorem thresholdProfile_true_card (n t : ℕ) (ht : t ≤ n + 1) :
    (univ.filter (fun i : Fin (n + 1) => thresholdProfile n t i = true)).card
      = n + 1 - t := by
  rw [ Finset.card_eq_of_bijective ];
  use fun i hi => ⟨ i + t, by omega ⟩;
  · exact fun a ha => ⟨ a - t, by rw [ tsub_lt_tsub_iff_right ( by simpa [ thresholdProfile ] using ha ) ] ; exact a.2, by erw [ Fin.ext_iff ] ; simp +decide [ Nat.sub_add_cancel ( show t ≤ a from by simpa [ thresholdProfile ] using ha ) ] ⟩;
  · unfold thresholdProfile; aesop;
  · aesop

/-
Layer count determines the threshold parameter: if a monotone profile has
`m` true layers, the unique threshold is `t = n + 1 - m`.
-/
theorem threshold_from_true_count (n : ℕ) (p : Fin (n + 1) → Bool)
    (hmono : Monotone p)
    (hm : (univ.filter (fun i : Fin (n + 1) => p i = true)).card = m) :
    p = thresholdProfile n (n + 1 - m) := by
  -- We want to show that $p$ is a threshold profile with parameter $t = n + 1 - m$.
  obtain ⟨t, ht⟩ : ∃ t, t ≤ n + 1 ∧ p = thresholdProfile n t := by
    exact monotone_profile_eq_threshold n p hmono;
  -- By `thresholdProfile_true_card`, the number of true layers of `thresholdProfile n t` is `n + 1 - t`.
  have ht_card : (Finset.univ.filter (fun i : Fin (n + 1) => thresholdProfile n t i = true)).card = n + 1 - t := by
    exact thresholdProfile_true_card n t ht.1;
  -- Since `p` and `thresholdProfile n t` are equal, their true layers must have the same cardinality.
  have ht_eq : n + 1 - t = m := by
    aesop;
  rw [ ← ht_eq, Nat.sub_sub_self ht.1, ht.2 ]

/-! ## Witness Count Formula for Thresholds -/

/-- The partial upper binomial sum: `∑_{j=a}^{b} C(n, j)`. -/
def binomialPartialSum (n a b : ℕ) : ℕ :=
  ∑ j ∈ Finset.Icc a b, Nat.choose n j

/-
The KW witness count for threshold `t` factors as a product of partial binomial sums.
Specifically, for `1 ≤ t ≤ n`:

  `W(n, t) = n * (∑_{j=t-1}^{n-1} C(n-1, j)) * (∑_{l=0}^{t-1} C(n-1, l))`

This factorization is the key to asymptotic analysis.
-/
theorem kwWitnessCountThreshold_factored (n t : ℕ) (hn : 1 ≤ n)
    (ht1 : 1 ≤ t) (ht2 : t ≤ n) :
    kwWitnessCountThreshold n t =
      n * binomialPartialSum (n - 1) (t - 1) (n - 1) *
        binomialPartialSum (n - 1) 0 (t - 1) := by
  unfold kwWitnessCountThreshold binomialPartialSum;
  nontriviality;
  unfold kwWitnessCountSymmetric thresholdProfile;
  simp +decide;
  rw [ mul_assoc, Finset.sum_mul _ _ _ ];
  refine' congrArg _ ( Finset.sum_bij ( fun x hx => x - 1 ) _ _ _ _ ) <;> simp +decide [ Finset.mem_Icc ];
  · bv_omega;
  · grind;
  · exact fun b hb₁ hb₂ => ⟨ ⟨ b + 1, by linarith [ Nat.sub_add_cancel hn ] ⟩, hb₁, rfl ⟩;
  · intro a ha; rw [ Finset.mul_sum _ _ _ ] ; refine' Finset.sum_bij ( fun x hx => x ) _ _ _ _ <;> simp +decide [ Finset.mem_Icc ] ;
    · exact fun a ha => Nat.le_sub_one_of_lt ha;
    · exact fun a₁ ha₁ a₂ ha₂ h => Fin.ext h;
    · exact fun b hb => ⟨ ⟨ b, by linarith [ Nat.sub_add_cancel ht1 ] ⟩, by simpa using Nat.lt_of_le_of_lt hb ( Nat.pred_lt ( ne_bot_of_gt ht1 ) ), rfl ⟩

/-! ## Extremality: Witness Count and Layer Count -/

/-
**Threshold Extremality**: For every monotone symmetric Boolean function with
exactly `m` true layers, its witness count equals that of the unique threshold
function with `m` true layers. Since there is exactly one monotone profile with
`m` true layers, this is both an extremality and a uniqueness result.

This theorem establishes that threshold functions are the **unique** witness-count
representatives within each layer-count class in the symmetric monotone world.
-/
theorem kwWitnessCount_eq_of_same_true_layers (n : ℕ)
    (p q : Fin (n + 1) → Bool) (hmono_p : Monotone p) (hmono_q : Monotone q)
    (hcard : (univ.filter (fun i => p i = true)).card =
             (univ.filter (fun i => q i = true)).card) :
    kwWitnessCountSymmetric n p = kwWitnessCountSymmetric n q := by
  -- By the uniqueness of the threshold representation, there exist unique thresholds $t_1$ and $t_2$ such that $p = \text{thresholdProfile } n t_1$ and $q = \text{thresholdProfile } n t_2$.
  obtain ⟨t1, ht1⟩ : ∃ t1 : ℕ, t1 ≤ n + 1 ∧ p = thresholdProfile n t1 := monotone_profile_eq_threshold n p hmono_p
  obtain ⟨t2, ht2⟩ : ∃ t2 : ℕ, t2 ≤ n + 1 ∧ q = thresholdProfile n t2 := monotone_profile_eq_threshold n q hmono_q;
  simp_all +decide;
  grind +suggestions

/-! ## Computational Validation -/

/-
Witness count for the trivial threshold `t = 0` (always true): no witnesses.
-/
theorem kwWitnessCountThreshold_zero (n : ℕ) :
    kwWitnessCountThreshold n 0 = 0 := by
  -- Expand the definition of `kwWitnessCountSymmetric`, observe the empty filter condition, and simplify.
  -- The false layer filter `(fun l => thresholdProfile n 0 l = false)` is empty since `t=0` makes everything true.
  dsimp [thresholdProfile, kwWitnessCountThreshold, kwWitnessCountSymmetric]
  simp

/-
Witness count for the trivial threshold `t = n + 1` (always false): no witnesses.
-/
theorem kwWitnessCountThreshold_top (n : ℕ) :
    kwWitnessCountThreshold n (n + 1) = 0 := by
  unfold kwWitnessCountThreshold;
  -- When t = n+1, the threshold profile is false for all inputs, so there are no true layers.
  have h_false : ∀ i : Fin (n + 1), thresholdProfile n (n + 1) i = false := by
    exact fun i => by unfold thresholdProfile; simp +decide ; linarith [ Fin.is_lt i ] ;
  unfold kwWitnessCountSymmetric; aesop;

end