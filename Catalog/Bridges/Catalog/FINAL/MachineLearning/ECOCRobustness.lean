import Mathlib

/-!
# Tropical Certified Robustness for Multiclass ECOC Decoders

This file formalizes certified robustness guarantees for multiclass classifiers
that use Error-Correcting Output Code (ECOC) decoders, combined with
coordinatewise tropical/Lipschitz control of network scores.

## Mathematical Overview

An ECOC decoder assigns class labels by comparing a binary prediction vector
to a codebook of binary codewords via Hamming agreement. Certified robustness
requires showing that small perturbations of the input cannot change the
decoded class.

The proof proceeds in three layers:

1. **Combinatorial layer**: If fewer than half the bits on each pairwise
   disagreement set flip, the decoder output is preserved.
2. **Analytic layer**: Coordinatewise Lipschitz bounds and margin conditions
   guarantee that individual bits don't flip within a ball of radius `r`.
3. **Bridge theorem**: Combining both layers yields a decoder-level certificate
   from coordinatewise tropical margins.

## Main Definitions

* `ECOC.agreement` — Hamming agreement between a bit vector and a codeword
* `ECOC.IsUniqueDecoder` — predicate for unique decoder output
* `ECOC.bitPred` — sign-based bit prediction from real scores
* `ECOC.certRadius` — per-bit certified radius

## Main Theorems

* `ECOC.ecoc_stable_under_flip_budget` — combinatorial robustness (Theorem 1)
* `ECOC.sign_stable_of_abs_lt_margin` — analytic sign stability (Theorem 2)
* `ECOC.ecoc_decoder_robust_of_coordinate_certificates` — main bridge (Theorem 3)
* `ECOC.ecoc_decoder_robust_of_pairwise_radius_count` — certified radius corollary

## References

The tropical approach to certified robustness originates in the analysis of
ReLU networks as tropical rational maps. This formalization extends the program
to structured multiclass ECOC decoders.
-/

noncomputable section

open Finset

namespace ECOC

/-! ## Core Definitions -/

variable {C : Type*} [Fintype C] [DecidableEq C]
variable {m : ℕ}
variable {α : Type*}

/-- Number of bit positions where `b` agrees with `code c`. -/
def agreement (code : C → Fin m → Bool) (b : Fin m → Bool) (c : C) : ℕ :=
  (Finset.univ.filter fun i => b i = code c i).card

/-- Class `c` is the unique decoder output for bit vector `b`:
    it has strictly more agreement than every other class. -/
def IsUniqueDecoder
    (code : C → Fin m → Bool) (b : Fin m → Bool) (c : C) : Prop :=
  ∀ d, d ≠ c → agreement code b c > agreement code b d

/-- Predicted bit from a real-valued score: `true` iff `0 ≤ f x i`. -/
def bitPred (f : α → Fin m → ℝ) (x : α) (i : Fin m) : Bool :=
  decide (0 ≤ f x i)

/-- Per-bit certified radius from margin and Lipschitz constant. -/
def certRadius (f : α → Fin m → ℝ) (K : Fin m → ℝ) (x : α) (i : Fin m) : ℝ :=
  |f x i| / K i

/-! ## Combinatorial ECOC Robustness (Theorem 1) -/

set_option linter.unusedSectionVars false in

/-
The agreement difference can be expressed via the disagreement set.
    Specifically, `agreement c - agreement d` equals the number of bits
    in D(c,d) agreeing with c minus those disagreeing with c.
-/
lemma agreement_diff_eq
    (code : C → Fin m → Bool) (b : Fin m → Bool) (c d : C) :
    (agreement code b c : ℤ) - (agreement code b d : ℤ) =
    ((Finset.univ.filter fun i => code c i ≠ code d i ∧ b i = code c i).card : ℤ)
    - ((Finset.univ.filter fun i => code c i ≠ code d i ∧ b i ≠ code c i).card : ℤ) := by
  unfold agreement;
  simp +decide only [card_filter];
  push_cast [ ← Finset.sum_sub_distrib ];
  exact Finset.sum_congr rfl fun i _ => by cases b i <;> cases code c i <;> cases code d i <;> simp +decide ;

set_option linter.unusedSectionVars false in
/-
The disagreement set D(c,d) partitions into bits agreeing and
    disagreeing with code c.
-/
lemma card_diff_partition
    (code : C → Fin m → Bool) (b : Fin m → Bool) (c d : C) :
    (Finset.univ.filter fun i => code c i ≠ code d i).card =
    (Finset.univ.filter fun i => code c i ≠ code d i ∧ b i = code c i).card +
    (Finset.univ.filter fun i => code c i ≠ code d i ∧ b i ≠ code c i).card := by
  rw [ ← Finset.card_union_of_disjoint ];
  · congr with i ; by_cases hi : b i = code c i <;> aesop;
  · exact Finset.disjoint_filter.mpr ( by aesop )

/-
When b₀ matches code c, disagreeing with code c on D(c,d) is the same
    as having flipped from b₀.
-/
omit [Fintype C] [DecidableEq C] in
lemma filter_disagree_eq_filter_flip
    (code : C → Fin m → Bool) (b₀ b : Fin m → Bool) (c : C) (d : C)
    (hbase : ∀ i, b₀ i = code c i) :
    (Finset.univ.filter fun i => code c i ≠ code d i ∧ b i ≠ code c i) =
    (Finset.univ.filter fun i => b i ≠ b₀ i ∧ code c i ≠ code d i) := by
  grind

/-
**Combinatorial ECOC Robustness Theorem (Theorem 1).**
If `b₀` matches the codeword of `c` exactly, and for every competitor `d`,
fewer than half of the bits in the disagreement set `D(c,d)` have flipped
from `b₀` to `b`, then `c` is the unique decoder output for `b`.
-/
theorem ecoc_stable_under_flip_budget
    {C : Type*} [Fintype C] [DecidableEq C]
    {m : ℕ}
    (code : C → Fin m → Bool)
    (b₀ b : Fin m → Bool)
    (c : C)
    (hbase : ∀ i, b₀ i = code c i)
    (hbudget : ∀ d, d ≠ c →
      2 * ((Finset.univ.filter fun i => b i ≠ b₀ i ∧ code c i ≠ code d i).card)
        < ((Finset.univ.filter fun i => code c i ≠ code d i).card))
    : IsUniqueDecoder code b c := by
  intro d hd; specialize hbudget d hd; contrapose! hbudget
  have h1 := @agreement_diff_eq C _ _ m code b c d
  have h2 := @card_diff_partition C _ _ m code b c d
  simp_all +decide [agreement, and_comm]
  linarith

/-! ## Analytic Sign Stability (Theorem 2) -/

section SignStability

variable [PseudoMetricSpace α]

/-
If `|a - b| < |b|`, then `a` and `b` have the same weak sign.
-/
lemma same_sign_of_abs_sub_lt {a b : ℝ} (h : |a - b| < |b|) : (0 ≤ a) ↔ (0 ≤ b) := by
  constructor <;> intro <;> cases abs_cases ( a - b ) <;> cases abs_cases b <;> linarith

/-
**Scalar sign stability (Theorem 2).**
If `f` is `K`-Lipschitz at `x` and `K * r < |f x|`, then the sign of `f`
is preserved for all `y` with `dist y x ≤ r`.
-/
theorem sign_stable_of_abs_lt_margin
    (f : α → ℝ) (K r : ℝ) (x : α)
    (hLip : ∀ y, |f y - f x| ≤ K * dist y x)
    (hK : 0 ≤ K) (_hr : 0 ≤ r)
    (hmargin : K * r < |f x|)
    : ∀ y, dist y x ≤ r → ((0 ≤ f y) ↔ (0 ≤ f x)) := by
  intro y hy; constructor <;> intro h <;> cases abs_cases ( f x ) <;> cases abs_cases ( f y - f x ) <;> nlinarith [ hLip y ] ;

/-
**Coordinatewise bit preservation.**
If each coordinate is Lipschitz with sufficient margin, all predicted bits
are preserved in the ball.
-/
theorem bitPred_stable_of_coordinate_margin
    (f : α → Fin m → ℝ)
    (K : Fin m → ℝ)
    (x : α) (r : ℝ)
    (hLip : ∀ i y, |f y i - f x i| ≤ K i * dist y x)
    (hK : ∀ i, 0 ≤ K i)
    (_hr : 0 ≤ r)
    (hmargin : ∀ i, K i * r < |f x i|)
    : ∀ y, dist y x ≤ r → ∀ i, bitPred f y i = bitPred f x i := by
  intros y hy i
  simp [bitPred];
  apply same_sign_of_abs_sub_lt;
  exact lt_of_le_of_lt ( hLip i y ) ( lt_of_le_of_lt ( mul_le_mul_of_nonneg_left hy ( hK i ) ) ( hmargin i ) )

/-
A single stable bit doesn't flip under perturbation.
-/
theorem bitPred_eq_of_stable_bit
    (f : α → Fin m → ℝ)
    (K : Fin m → ℝ)
    (x : α) (r : ℝ) (i : Fin m)
    (hLip : ∀ y, |f y i - f x i| ≤ K i * dist y x)
    (hK : 0 ≤ K i)
    (_hr : 0 ≤ r)
    (hmargin : K i * r < |f x i|)
    (y : α) (hy : dist y x ≤ r) :
    bitPred f y i = bitPred f x i := by
  convert decide_eq_decide.mpr ( sign_stable_of_abs_lt_margin ( fun y => f y i ) ( K i ) r x hLip hK _hr hmargin y hy ) using 1

end SignStability

/-! ## Main Bridge Theorem (Theorem 3) -/

section MainTheorem

variable [PseudoMetricSpace α]

/-
If a bit is certified (margin > K*r) but flips, we reach a contradiction.
-/
lemma flip_implies_uncertified
    (f : α → Fin m → ℝ)
    (K : Fin m → ℝ)
    (x : α) (r : ℝ) (i : Fin m)
    (hLip : ∀ y, |f y i - f x i| ≤ K i * dist y x)
    (hK : 0 ≤ K i) (hr : 0 ≤ r)
    (y : α) (hy : dist y x ≤ r)
    (hflip : bitPred f y i ≠ bitPred f x i) :
    ¬(K i * r < |f x i|) := by
  contrapose! hflip; have := bitPred_eq_of_stable_bit f K x r i hLip hK hr hflip y hy; tauto;

/-
Flipped bits on the disagreement set are contained in the uncertified set.
-/
omit [Fintype C] [DecidableEq C] in
lemma flipped_card_le_uncertified
    (code : C → Fin m → Bool)
    (f : α → Fin m → ℝ)
    (K : Fin m → ℝ)
    (x : α) (r : ℝ) (c d : C)
    (hbase : ∀ i, bitPred f x i = code c i)
    (hLip : ∀ i y, |f y i - f x i| ≤ K i * dist y x)
    (hK : ∀ i, 0 ≤ K i) (hr : 0 ≤ r)
    (y : α) (hy : dist y x ≤ r) :
    ((Finset.univ.filter fun i =>
      bitPred f y i ≠ (bitPred f x i) ∧ code c i ≠ code d i).card)
    ≤ ((Finset.univ.filter fun i =>
      code c i ≠ code d i ∧ |f x i| ≤ K i * r).card) := by
  refine Finset.card_mono ?_;
  intro i hi;
  simp_all +decide [ Finset.mem_filter ];
  contrapose! hi;
  exact fun h => False.elim <| h <| by rw [ ← hbase i, bitPred_eq_of_stable_bit f K x r i ( hLip i ) ( hK i ) hr hi y hy ] ;

/-
**Main ECOC Robustness Theorem (Theorem 3).**
If the network output at `x` matches the codeword of class `c`, each score
coordinate is Lipschitz, and for every competing class `d`, strictly fewer
than half of the separating bits are uncertified (margin ≤ K*r), then every
perturbation within radius `r` preserves the unique decoder output `c`.

This bridges local tropical/Lipschitz control, combinatorial Hamming geometry,
and global classification stability.
-/
theorem ecoc_decoder_robust_of_coordinate_certificates
    (code : C → Fin m → Bool)
    (f : α → Fin m → ℝ)
    (K : Fin m → ℝ)
    (x : α) (r : ℝ) (c : C)
    (hbase : ∀ i, bitPred f x i = code c i)
    (hLip : ∀ i y, |f y i - f x i| ≤ K i * dist y x)
    (hK : ∀ i, 0 ≤ K i)
    (hr : 0 ≤ r)
    (hsep : ∀ d, d ≠ c →
      2 * ((Finset.univ.filter fun i => code c i ≠ code d i ∧ |f x i| ≤ K i * r).card)
        < ((Finset.univ.filter fun i => code c i ≠ code d i).card))
    : ∀ y, dist y x ≤ r → IsUniqueDecoder code (bitPred f y) c := by
  intro y hy
  apply ecoc_stable_under_flip_budget;
  exact hbase;
  intro d hd;
  exact lt_of_le_of_lt ( Nat.mul_le_mul_left _ ( flipped_card_le_uncertified code f K x r c d hbase hLip hK hr y hy ) ) ( hsep d hd )

/-
**ECOC Robustness via Certified Radii (Corollary).**
Robustness holds whenever, for every competing class, fewer than half of the
code bits separating it from `c` have certified radius ≤ `r`.
-/
theorem ecoc_decoder_robust_of_pairwise_radius_count
    (code : C → Fin m → Bool)
    (f : α → Fin m → ℝ)
    (K : Fin m → ℝ)
    (x : α) (r : ℝ) (c : C)
    (hbase : ∀ i, bitPred f x i = code c i)
    (hLip : ∀ i y, |f y i - f x i| ≤ K i * dist y x)
    (hK : ∀ i, 0 < K i)
    (hr : 0 ≤ r)
    (hcount : ∀ d, d ≠ c →
      2 * ((Finset.univ.filter fun i => code c i ≠ code d i ∧ certRadius f K x i ≤ r).card)
        < ((Finset.univ.filter fun i => code c i ≠ code d i).card))
    : ∀ y, dist y x ≤ r → IsUniqueDecoder code (bitPred f y) c := by
  convert ecoc_decoder_robust_of_coordinate_certificates code f K x r c hbase hLip ( fun i => ( hK i ).le ) hr _ using 1;
  convert hcount using 6;
  ext i; simp +decide [ certRadius, div_le_iff₀ ( hK i ) ] ;
  exact fun _ => by rw [ mul_comm ] ;

end MainTheorem

end ECOC