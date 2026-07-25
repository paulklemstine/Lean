/-
# Fractal Dimension of Mathematical Truth — Definitions

We model the space of mathematical statements as the Cantor space {0,1}^ℕ,
endowed with the standard ultrametric. A "truth oracle" is a predicate on
finite binary strings. We define the truth density at level n, and the
box-counting (Minkowski) dimension of truth sets.

Key novel concept: TruthDensityProfile — captures how the density of true
statements scales with statement length, and its associated dimension.
-/
import Mathlib

open Finset BigOperators

/-- A binary string of length n, modeled as `Fin n → Bool`. -/
abbrev BinString (n : ℕ) := Fin n → Bool

/-- The number of binary strings of length n satisfying predicate P. -/
noncomputable def truthCount (n : ℕ) (P : BinString n → Prop) [DecidablePred P] : ℕ :=
  (Finset.univ.filter (fun s => P s)).card

/-- Truth density at level n: fraction of length-n strings satisfying P. -/
noncomputable def truthDensity (n : ℕ) (P : BinString n → Prop) [DecidablePred P] : ℚ :=
  (truthCount n P : ℚ) / (2 ^ n : ℚ)

/-
The truth count is bounded above by 2^n.
-/
theorem truthCount_le_two_pow (n : ℕ) (P : BinString n → Prop) [DecidablePred P] :
    truthCount n P ≤ 2 ^ n := by
      exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num [ Finset.card_univ ] )

/-
Truth density is between 0 and 1.
-/
theorem truthDensity_nonneg (n : ℕ) (P : BinString n → Prop) [DecidablePred P] :
    0 ≤ truthDensity n P := by
      exact div_nonneg ( Nat.cast_nonneg _ ) ( by positivity )

theorem truthDensity_le_one (n : ℕ) (P : BinString n → Prop) [DecidablePred P] :
    truthDensity n P ≤ 1 := by
      exact div_le_one_of_le₀ ( mod_cast truthCount_le_two_pow n P ) ( by positivity )

/--
A `TruthDensityProfile` packages a family of decidable predicates
on binary strings of each length, modeling a "truth oracle" that
classifies statements by length.
-/
structure TruthDensityProfile where
  /-- The predicate at each string length -/
  pred : (n : ℕ) → BinString n → Prop
  /-- Decidability at each level -/
  dec : (n : ℕ) → DecidablePred (pred n)

attribute [instance] TruthDensityProfile.dec

/-- Truth count for a profile at level n. -/
noncomputable def TruthDensityProfile.count (T : TruthDensityProfile) (n : ℕ) : ℕ :=
  truthCount n (T.pred n)

/-- Truth density for a profile at level n. -/
noncomputable def TruthDensityProfile.density (T : TruthDensityProfile) (n : ℕ) : ℚ :=
  truthDensity n (T.pred n)

/-- The "all true" profile — every string is true. -/
def allTrueProfile : TruthDensityProfile where
  pred := fun _ _ => True
  dec := fun _ => inferInstance

/-- The "empty" profile — no string is true. -/
def emptyProfile : TruthDensityProfile where
  pred := fun _ _ => False
  dec := fun _ => inferInstance

/-
The empty profile has zero truth count at every level.
-/
theorem emptyProfile_count_zero (n : ℕ) : emptyProfile.count n = 0 := by
  exact Finset.card_eq_zero.mpr <| by aesop;

/-
The all-true profile has truth count 2^n.
-/
theorem allTrueProfile_count (n : ℕ) : allTrueProfile.count n = 2 ^ n := by
  convert Finset.card_univ ( α := Fin n → Bool ) using 1;
  · exact congr_arg Finset.card ( Finset.filter_true_of_mem fun _ _ => trivial );
  · norm_num

/--
Box-counting dimension exponent: if truthCount ~ 2^(d*n) for large n,
then d is the box-counting dimension. We define a lower bound version:
d is a lower density exponent if truthCount n ≥ 2^(d*n) for all large enough n.
-/
noncomputable def isLowerDensityExponent (T : TruthDensityProfile) (d : ℝ) : Prop :=
  ∃ N : ℕ, ∀ n : ℕ, N ≤ n → (T.count n : ℝ) ≥ (2 : ℝ) ^ (d * n)

/--
Upper density exponent: truthCount n ≤ 2^(d*n) for all large enough n.
-/
noncomputable def isUpperDensityExponent (T : TruthDensityProfile) (d : ℝ) : Prop :=
  ∃ N : ℕ, ∀ n : ℕ, N ≤ n → (T.count n : ℝ) ≤ (2 : ℝ) ^ (d * n)

/-
The empty profile has upper density exponent 0.
-/
theorem emptyProfile_upper_exponent_zero :
    isUpperDensityExponent emptyProfile 0 := by
      exact ⟨ 0, fun n hn => by simp +decide [ emptyProfile_count_zero ] ⟩

/-
The all-true profile has upper density exponent 1.
-/
theorem allTrue_upper_exponent_one :
    isUpperDensityExponent allTrueProfile 1 := by
      use 0;
      norm_num [ allTrueProfile_count ]

/-
The all-true profile is NOT an upper density exponent for any d < 1.
-/
theorem allTrue_not_upper_below_one (d : ℝ) (hd : d < 1) :
    ¬ isUpperDensityExponent allTrueProfile d := by
      -- By definition of IsUpperDensityExponent, if d < 1, then for large n, the truth count 2^n must be less than 2^(d*n).
      intro h
      obtain ⟨N, hN⟩ := h
      specialize hN (N + 1) (by linarith)
      have h_exp : (2 : ℝ) ^ (N + 1) ≤ (2 : ℝ) ^ (d * (N + 1)) := by
        convert hN using 1 ; norm_cast ; simp +decide [ allTrueProfile_count ];
        norm_cast
      norm_cast at h_exp
      have h_contra : N + 1 ≤ d * (N + 1) := by
        contrapose! h_exp ; norm_num;
        exact_mod_cast Real.rpow_lt_rpow_of_exponent_lt one_lt_two h_exp
      nlinarith [hd]