import Mathlib

/-!
# GL₃ Finite Test Family for Tropical Satake Injectivity

## Overview

This file establishes a finite-determinacy theorem for bounded-support dominant GL₃
tropical Hecke data. We prove that on a bounded dominant region, the full tropical
Satake transform is determined by the two simple-coroot edge restrictions together
with one mixed rank-2 Levi moment per adjacent slice, **provided the support parameter
N ≤ 3**.

We also construct an explicit counterexample demonstrating that the one-moment-per-slice
condition is insufficient for N ≥ 4, and prove a correct generalization for all N using
full row/column vanishing data.

## Mathematical Model

Dominant coweights for GL₃ are pairs `(a, b) : ℕ × ℕ` representing the dominant
coweight `(a+b, b, 0)`. The two chamber edges are `b = 0` and `a = 0`.

Functions are supported in the "box" `{(a,b) : a + b ≤ N}`, which is the dominant
Weyl chamber truncated at height N.

## Main Results

- `finite_test_family_zero_GL3`: For N ≤ 3, edges + one mixed moment per slice
  force a bounded-support function to vanish.
- `finite_test_family_injective_GL3`: Injectivity version of the above.
- `cex4_nonzero`: Explicit counterexample for N = 4.
- `finite_test_family_zero_GL3_general`: Correct general version for all N using
  full interior vanishing.
-/

noncomputable section

open Finset

/-! ## Basic Definitions -/

/-- Dominant coweights for GL₃, represented as pairs (a,b) encoding (a+b, b, 0). -/
abbrev DomGL3 := ℕ × ℕ

/-- Tropical Hecke functions on the dominant cone. -/
abbrev TropFn := DomGL3 → ℝ

/-- A tropical function is supported in box N if it vanishes outside the triangle a + b ≤ N. -/
def SupportedInBox (N : ℕ) (f : TropFn) : Prop :=
  ∀ p : DomGL3, N < p.1 + p.2 → f p = 0

/-- First simple-coroot edge restriction: fix b = 0 (the edge where the second
    simple coroot vanishes). -/
def edge₁ (f : TropFn) (a : ℕ) : ℝ := f (a, 0)

/-- Second simple-coroot edge restriction: fix a = 0 (the edge where the first
    simple coroot vanishes). -/
def edge₂ (f : TropFn) (b : ℕ) : ℝ := f (0, b)

/-- Left slice: fix the second coordinate b and vary a. -/
def sliceLeft (f : TropFn) (b : ℕ) : ℕ → ℝ := fun a => f (a, b)

/-- Right slice: fix the first coordinate a and vary b. -/
def sliceRight (f : TropFn) (a : ℕ) : ℕ → ℝ := fun b => f (a, b)

/-- Left mixed moment: the first weighted moment on the left slice at b. This is
    the rank-2 Levi mixed statistic transverse to the first chamber facet. -/
def mixedMomentLeft (N : ℕ) (f : TropFn) (b : ℕ) : ℝ :=
  ∑ a ∈ Finset.range (N + 1), (a : ℝ) * f (a, b)

/-- Right mixed moment: the first weighted moment on the right slice at a. This is
    the rank-2 Levi mixed statistic transverse to the second chamber facet. -/
def mixedMomentRight (N : ℕ) (f : TropFn) (a : ℕ) : ℝ :=
  ∑ b ∈ Finset.range (N + 1), (b : ℝ) * f (a, b)

/-! ## Infrastructure Lemmas -/

/-
Support condition is preserved under subtraction.
-/
lemma supportedInBox_sub (N : ℕ) {f g : TropFn}
    (hf : SupportedInBox N f) (hg : SupportedInBox N g) :
    SupportedInBox N (fun p => f p - g p) := by
  exact fun p hp => by simp +decide [ hf p hp, hg p hp ] ;

/-
Edge₁ difference vanishes when edges agree.
-/
lemma edge₁_zero_of_eq {N : ℕ} {f g : TropFn}
    (h : ∀ a ≤ N, edge₁ f a = edge₁ g a) :
    ∀ a ≤ N, (fun p => f p - g p) (a, 0) = 0 := by
  exact fun a ha => sub_eq_zero.mpr ( h a ha )

/-
Edge₂ difference vanishes when edges agree.
-/
lemma edge₂_zero_of_eq {N : ℕ} {f g : TropFn}
    (h : ∀ b ≤ N, edge₂ f b = edge₂ g b) :
    ∀ b ≤ N, (fun p => f p - g p) (0, b) = 0 := by
  intro b hb; specialize h b hb; unfold edge₂ at h; aesop;

/-! ## Key Technical Lemma: Interior Vanishing for N ≤ 3

The proof proceeds by analyzing each possible interior point `(a,b)` with `a > 0`,
`b > 0`, and `a + b ≤ N ≤ 3`. For such small N, each row/column of the triangular
support region contains at most one interior point, so the single mixed moment
condition suffices to pin down each value.

### Proof outline for N = 3:
- **h(1,2) = 0**: Row b=2 has one interior entry (a=1), since h(2,2) = 0 by support
  (2+2 > 3). The left moment at b=2 gives h(1,2) = 0.
- **h(2,1) = 0**: Column a=2 has one interior entry (b=1), since h(2,2) = 0 by
  support. The right moment at a=2 gives h(2,1) = 0.
- **h(1,1) = 0**: Row b=1 now has one unknown (a=1), since h(2,1) = 0 was just
  proved and h(3,1) = 0 by support. The left moment at b=1 gives h(1,1) = 0.
-/

/-
For N ≤ 3, all interior points of a bounded-support function vanish under the
    edge and mixed moment conditions. This is the core technical content.
-/
lemma zero_at_interior_le3 (N : ℕ) (hN : N ≤ 3) (h : TropFn)
    (hsupp : SupportedInBox N h)
    (hedge₁ : ∀ a ≤ N, h (a, 0) = 0)
    (hedge₂ : ∀ b ≤ N, h (0, b) = 0)
    (hmixL : ∀ b ≤ N, mixedMomentLeft N h b = 0)
    (hmixR : ∀ a ≤ N, mixedMomentRight N h a = 0)
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (hab : a + b ≤ N) :
    h (a, b) = 0 := by
  interval_cases N <;> simp_all +arith +decide only;
  · linarith;
  · linarith;
  · rcases a with ( _ | _ | a ) <;> rcases b with ( _ | _ | b ) <;> simp_all +arith +decide only;
    unfold mixedMomentLeft at hmixL; norm_num [ Finset.sum_range_succ ] at hmixL; linarith! [ hedge₁ 0 ( by norm_num ), hedge₁ 1 ( by norm_num ), hedge₁ 2 ( by norm_num ), hedge₂ 0 ( by norm_num ), hedge₂ 1 ( by norm_num ), hedge₂ 2 ( by norm_num ), hsupp ( 2, 1 ) ( by norm_num ), hsupp ( 1, 2 ) ( by norm_num ), hmixL 0 ( by norm_num ), hmixL 1 ( by norm_num ), hmixL 2 ( by norm_num ) ] ;
  · rcases a with ( _ | _ | _ | _ | a ) <;> rcases b with ( _ | _ | _ | _ | b ) <;> simp_all +arith +decide only;
    · unfold mixedMomentLeft mixedMomentRight at *; simp_all +decide [ Finset.sum_range_succ ] ;
      linarith [ hmixL 1 ( by norm_num ), hmixR 1 ( by norm_num ), hmixL 2 ( by norm_num ), hmixR 2 ( by norm_num ), hmixL 3 ( by norm_num ), hmixR 3 ( by norm_num ), hsupp ( 1, 3 ) ( by norm_num ), hsupp ( 2, 2 ) ( by norm_num ), hsupp ( 2, 3 ) ( by norm_num ), hsupp ( 3, 1 ) ( by norm_num ), hsupp ( 3, 2 ) ( by norm_num ), hsupp ( 3, 3 ) ( by norm_num ) ];
    · unfold mixedMomentLeft at hmixL; unfold mixedMomentRight at hmixR; simp_all +decide [ Finset.sum_range_succ ] ;
      linarith [ hmixL 2 ( by norm_num ), hmixR 1 ( by norm_num ), hsupp ( 2, 2 ) ( by norm_num ), hsupp ( 3, 2 ) ( by norm_num ), hsupp ( 1, 3 ) ( by norm_num ), hsupp ( 2, 3 ) ( by norm_num ), hsupp ( 3, 3 ) ( by norm_num ) ];
    · have := hmixR 2 ( by decide ) ; simp_all +decide [ Finset.sum_range_succ, mixedMomentRight ] ;
      linarith! [ hsupp ( 2, 2 ) ( by decide ), hsupp ( 2, 3 ) ( by decide ), hsupp ( 3, 1 ) ( by decide ), hsupp ( 3, 2 ) ( by decide ), hsupp ( 3, 3 ) ( by decide ), hmixR 2 ( by decide ), hmixR 3 ( by decide ) ]

/-! ## Main Theorems -/

/-
**Main Zero Theorem (N ≤ 3)**: A bounded-support tropical function that vanishes
    on both chamber edges and has vanishing mixed moments on every slice must be
    identically zero, provided the support parameter N ≤ 3.
-/
theorem finite_test_family_zero_GL3
    (N : ℕ) (hN : N ≤ 3) (h : TropFn)
    (hsupp : SupportedInBox N h)
    (hedge₁ : ∀ a ≤ N, h (a, 0) = 0)
    (hedge₂ : ∀ b ≤ N, h (0, b) = 0)
    (hmixL : ∀ b ≤ N, mixedMomentLeft N h b = 0)
    (hmixR : ∀ a ≤ N, mixedMomentRight N h a = 0) :
    h = 0 := by
  ext ⟨ a, b ⟩;
  by_cases ha : a = 0 <;> by_cases hb : b = 0 <;> simp_all +decide;
  · exact if hb' : b ≤ N then hedge₂ b hb' else hsupp ( 0, b ) ( by linarith );
  · exact if h : a ≤ N then hedge₁ a h else hsupp _ ( by linarith );
  · by_cases hab : a + b ≤ N;
    · exact zero_at_interior_le3 N hN h hsupp hedge₁ hedge₂ hmixL hmixR a b ( Nat.pos_of_ne_zero ha ) ( Nat.pos_of_ne_zero hb ) hab;
    · exact hsupp _ ( not_le.mp hab )

/-
**Injectivity Theorem (N ≤ 3)**: Two bounded-support tropical functions that
    agree on both chamber edges and have the same mixed moments on every slice must
    be equal, provided N ≤ 3.
-/
theorem finite_test_family_injective_GL3
    (N : ℕ) (hN : N ≤ 3) (f g : TropFn)
    (hf : SupportedInBox N f) (hg : SupportedInBox N g)
    (hedge₁ : ∀ a ≤ N, edge₁ f a = edge₁ g a)
    (hedge₂ : ∀ b ≤ N, edge₂ f b = edge₂ g b)
    (hmixL : ∀ b ≤ N,
      mixedMomentLeft N (fun p => f p - g p) b = 0)
    (hmixR : ∀ a ≤ N,
      mixedMomentRight N (fun p => f p - g p) a = 0) :
    f = g := by
  -- Apply the lemma finite_test_family_zero_GL3 with N ≤ 3 to the difference function h := fun p => f p - g p.
  have h_diff_zero : (fun p => f p - g p) = 0 := by
    apply_rules [ finite_test_family_zero_GL3 ];
    · exact supportedInBox_sub N hf hg;
    · exact fun a ha => edge₁_zero_of_eq hedge₁ a ha;
    · exact fun b hb => sub_eq_zero.mpr ( hedge₂ b hb );
  exact funext fun p => sub_eq_zero.mp <| congr_fun h_diff_zero p

/-! ## Counterexample for N = 4

The function `cex4` defined below satisfies all hypotheses of the zero theorem
(supported in box 4, vanishes on both edges, all mixed moments vanish) but is
nonzero. This shows the one-moment-per-slice condition is insufficient for N ≥ 4.

The counterexample arises because for N = 4, the row b = 2 has two interior
entries (a = 1 and a = 2), and a single moment equation cannot determine both.
The moment system becomes underdetermined with a 1-dimensional kernel.
-/

/-- Explicit counterexample for N = 4: a nonzero function satisfying all conditions. -/
def cex4 : TropFn := fun p =>
  match p.1, p.2 with
  | 1, 1 => 4
  | 1, 2 => -2
  | 2, 1 => -2
  | 2, 2 => 1
  | _, _ => 0

lemma cex4_supported : SupportedInBox 4 cex4 := by
  intro p hp; rcases p with ⟨ a, b ⟩ ; rcases a with ( _ | _ | _ | _ | _ | a ) <;> rcases b with ( _ | _ | _ | _ | _ | b ) <;> trivial;

lemma cex4_edge₁ : ∀ a ≤ 4, cex4 (a, 0) = 0 := by
  intro a ha; interval_cases a <;> rfl;

lemma cex4_edge₂ : ∀ b ≤ 4, cex4 (0, b) = 0 := by
  intro b hb; interval_cases b <;> rfl;

lemma cex4_mixedMomentLeft : ∀ b ≤ 4, mixedMomentLeft 4 cex4 b = 0 := by
  unfold mixedMomentLeft;
  intro b hb; interval_cases b <;> norm_num [ Finset.sum_range_succ, cex4 ] ;

lemma cex4_mixedMomentRight : ∀ a ≤ 4, mixedMomentRight 4 cex4 a = 0 := by
  intro a ha;
  interval_cases a <;> unfold mixedMomentRight <;> norm_num [ Finset.sum_range_succ, cex4 ]

/-
The counterexample is genuinely nonzero.
-/
lemma cex4_nonzero : cex4 ≠ 0 := by
  -- By definition of `cex4`, we know that it is nonzero.
  intro h_zero
  have := congr_fun h_zero (1, 1)
  simp [cex4] at this

/-! ## Correct General Version

For arbitrary N, we can recover full determination by strengthening the hypothesis
from "one mixed moment per slice" to "full knowledge of each interior slice."
This corresponds to using the complete rank-2 Levi profile rather than a single
mixed statistic. -/

/-
**General Zero Theorem**: A bounded-support function vanishing on edges and
    at all interior points must be zero. This version works for all N.
-/
theorem finite_test_family_zero_GL3_general
    (N : ℕ) (h : TropFn)
    (hsupp : SupportedInBox N h)
    (hedge₁ : ∀ a, h (a, 0) = 0)
    (hedge₂ : ∀ b, h (0, b) = 0)
    (hinterior : ∀ a b, 0 < a → 0 < b → a + b ≤ N → h (a, b) = 0) :
    h = 0 := by
  -- By definition of $h$, we know that for any $(a, b)$, if $a + b > N$ or $a = 0$ or $b = 0$, then $h(a, b) = 0$.
  funext ⟨a, b⟩; by_cases hab : a + b > N <;> by_cases ha : a = 0 <;> by_cases hb : b = 0 <;> simp_all +decide [ SupportedInBox ];
  exact hinterior a b ( Nat.pos_of_ne_zero ha ) ( Nat.pos_of_ne_zero hb ) hab

end