/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# ECOC Robustness for Tropical Satake Score Classifiers — Definitions

This file establishes the core definitions for Error-Correcting Output Code (ECOC)
classifiers built from tropical Satake score gaps. The key objects are:

- `CodeMatrix`: a ±1 code matrix assigning binary codewords to classes
- `SignedBitScore`, `softScore`: the signed bit-gap and aggregate soft-decoding scores
- `disagreeBits`: the Hamming support of the codeword difference between two classes
- `BitGapLipschitzOn`: the per-bit Lipschitz condition abstracting tropical Hecke estimates
- `pairAdvantage`, `certifiedRadius`: the weighted code-distance and explicit robustness radius

These definitions form the foundation for the robustness theorems proved in
`Bridges.ECOCRobustSoft` and `Bridges.ECOCRobustHard`.
-/
import Mathlib

open scoped BigOperators
open Finset

/-! ## Core Definitions -/

/-- A code matrix assigns an integer code value to each (class, bit) pair. -/
def CodeMatrix (n m : ℕ) := Fin n → Fin m → ℤ

/-- A valid code matrix has all entries in {+1, -1}. -/
def ValidCodeMatrix {n m : ℕ} (C : CodeMatrix n m) : Prop :=
  ∀ y j, C y j = 1 ∨ C y j = -1

/-- The signed bit score for class `y` on bit `j` at input `x`. -/
def SignedBitScore {n m : ℕ} {α : Type*}
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y : Fin n) (j : Fin m) (x : α) : ℝ :=
  (C y j : ℝ) * g j x

/-- The set of bit positions where classes `y` and `z` have different codewords. -/
def disagreeBits {n m : ℕ} (C : CodeMatrix n m) (y z : Fin n) : Finset (Fin m) :=
  Finset.univ.filter (fun j => C y j ≠ C z j)

/-- The aggregate soft score for class `y` at input `x`. -/
def softScore {n m : ℕ} {α : Type*}
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y : Fin n) (x : α) : ℝ :=
  ∑ j : Fin m, SignedBitScore C g y j x

/-- The hard bit: whether the signed bit score is positive. -/
noncomputable def hardBit {n m : ℕ} {α : Type*}
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y : Fin n) (j : Fin m) (x : α) : Bool :=
  decide (0 < SignedBitScore C g y j x)

/-- The hard score: number of positive signed bit scores. -/
noncomputable def hardScore {n m : ℕ} {α : Type*}
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y : Fin n) (x : α) : ℕ :=
  (Finset.univ.filter (fun j : Fin m => 0 < SignedBitScore C g y j x)).card

/-- The certified margin at bit `j`: the absolute value of the gap. -/
def certMargin {m : ℕ} {α : Type*} (g : Fin m → α → ℝ) (x : α) (j : Fin m) : ℝ :=
  |g j x|

/-- Per-bit Lipschitz condition on the gap functions. -/
def BitGapLipschitzOn {m : ℕ} {α : Type*} [PseudoMetricSpace α]
    (g : Fin m → α → ℝ) (L : ℝ) : Prop :=
  ∀ j x x', |g j x - g j x'| ≤ L * dist x x'

/-- The pairwise advantage: weighted sum of certified margins on disagreeing bits. -/
def pairAdvantage {n m : ℕ} {α : Type*}
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y z : Fin n) (x : α) : ℝ :=
  (disagreeBits C y z).sum (fun j => (2 : ℝ) * |g j x|)

/-- The number of disagreeing bits between two classes. -/
def pairDisagreeCount {n m : ℕ}
    (C : CodeMatrix n m) (y z : Fin n) : ℕ :=
  (disagreeBits C y z).card

/-- A code matrix is injective if distinct classes have distinct codewords. -/
def CodeInjective {n m : ℕ} (C : CodeMatrix n m) : Prop :=
  Function.Injective C

/-! ## Key algebraic lemmas about ±1 codes -/

/-- For a valid code matrix, |C y j| = 1 as a real number. -/
lemma abs_coe_valid {n m : ℕ} (C : CodeMatrix n m) (hC : ValidCodeMatrix C)
    (y : Fin n) (j : Fin m) : |(C y j : ℝ)| = 1 := by
  rcases hC y j with h | h <;> simp [h]

/-- For a valid code matrix, (C y j : ℝ) ^ 2 = 1. -/
lemma sq_coe_valid {n m : ℕ} (C : CodeMatrix n m) (hC : ValidCodeMatrix C)
    (y : Fin n) (j : Fin m) : (C y j : ℝ) ^ 2 = 1 := by
  rcases hC y j with h | h <;> simp [h]

/-- If two ±1 values are different, one is the negation of the other. -/
lemma neg_of_ne_valid {n m : ℕ} (C : CodeMatrix n m) (hC : ValidCodeMatrix C)
    (y z : Fin n) (j : Fin m) (h : C y j ≠ C z j) :
    (C z j : ℝ) = -(C y j : ℝ) := by
  rcases hC y j with hy | hy <;> rcases hC z j with hz | hz <;> simp_all

/-- On agreeing bits, signed bit scores are equal. -/
lemma signedBitScore_eq_of_agree {n m : ℕ} {α : Type*}
    (C : CodeMatrix n m) (g : Fin m → α → ℝ)
    (y z : Fin n) (j : Fin m) (x : α) (h : C y j = C z j) :
    SignedBitScore C g y j x = SignedBitScore C g z j x := by
  simp [SignedBitScore, h]

/-- On disagreeing bits, the difference of signed bit scores is 2 * (C y j) * g j x. -/
lemma signedBitScore_diff_disagree {n m : ℕ} {α : Type*}
    (C : CodeMatrix n m) (hC : ValidCodeMatrix C) (g : Fin m → α → ℝ)
    (y z : Fin n) (j : Fin m) (x : α) (h : C y j ≠ C z j) :
    SignedBitScore C g y j x - SignedBitScore C g z j x
      = 2 * (C y j : ℝ) * g j x := by
  simp only [SignedBitScore]
  have hne := neg_of_ne_valid C hC y z j h
  rw [hne]
  ring

/-- disagreeBits is nonempty when codewords differ (under injectivity). -/
lemma disagreeBits_nonempty_of_ne {n m : ℕ}
    (C : CodeMatrix n m) (hinj : CodeInjective C)
    (y z : Fin n) (hyz : y ≠ z) :
    (disagreeBits C y z).Nonempty := by
  by_contra h
  rw [Finset.not_nonempty_iff_eq_empty] at h
  have : C y = C z := by
    ext j
    have : j ∉ disagreeBits C y z := by rw [h]; simp
    simp [disagreeBits, Finset.mem_filter] at this
    exact this
  exact hyz (hinj this)