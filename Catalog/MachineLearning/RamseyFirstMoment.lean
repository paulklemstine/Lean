/-
# First-moment counting for the 3-uniform diagonal hypergraph Ramsey number `R(4,4;3)`

This file formalizes, from scratch and self-containedly, the **first-moment / averaging**
("probabilistic method") lower-bound argument for the 3-uniform diagonal hypergraph Ramsey
number, packaged through an *exact finite counting identity* rather than measure theory.

## Set-up

* `Edge3 n` — the 3-element subsets ("3-edges") of `Fin n`.
* `Quad4 n` — the 4-element subsets ("4-sets") of `Fin n`.
* `Coloring n := Edge3 n → Bool` — a 2-coloring of the 3-edges.
* `MonoOn4 χ Q` — all four 3-edges contained in the 4-set `Q` get the same color.
* `badCount χ` — the number of monochromatic 4-sets of `χ`.

## Pipeline

1. Finite instances are obtained automatically for the subtype representations.
2. Cardinalities: `card_Edge3`, `card_Quad4`, `card_Coloring`.
3. For a fixed 4-set `Q`, the number of colorings with `MonoOn4 χ Q` is
   `2 * 2 ^ (C(n,3) - 4) = 2 ^ (C(n,3) - 3)` (`card_mono_fixed_quad`); the
   "monochromatic probability" is `2 / 2^4 = 1/8`.
4. Exact incidence identity (`sum_badCount`):
   `∑ χ, badCount χ = C(n,4) * 2 ^ (C(n,3) - 3)`.
5. Expectation formula (`expectation_badCount`): the average of `badCount` over the
   uniform finite coloring space equals `C(n,4) / 8`.
6. First-moment existence (`exists_good_of_choose_lt_eight`): whenever the expectation is
   `< 1`, i.e. `C(n,4) < 8`, some coloring has `badCount = 0`.

## IMPORTANT mathematical correction to the requested target

The task statement asks to specialize the argument at `n = 13` and to "prove numerically
that this expectation is `< 1`", concluding `R(4,4;3) > 13`.  **This is mathematically
false.**  The first-moment expectation here is exactly `C(n,4)/8`, so the condition
"expectation `< 1`" is equivalent to `C(n,4) < 8`, which holds only for `n ≤ 5`
(`C(5,4) = 5 < 8`, `C(6,4) = 15`).  For `n = 13` the expectation is
`C(13,4)/8 = 715/8 ≈ 89.4 ≥ 1`, so the first-moment argument yields *nothing* at `n = 13`
(see `expectation_thirteen` and `first_moment_insufficient_thirteen`).

Moreover the conclusion itself is false: the exact value is `R^{(3)}(4,4) = 13`
(McKay–Radziszowski, 1991), meaning **every** 2-coloring of the 3-subsets of a 13-element
set contains a monochromatic tetrahedron; in particular no "good" coloring of `Fin 13`
exists at all, so `R(4,4;3) > 13` cannot be proved by any method.

Accordingly, this file proves the genuinely correct first-moment bound:
`exists_good_coloring_five` / `ramsey_three_four_four_gt_five`, i.e. `R(4,4;3) > 5`,
the strongest diagonal bound the first moment actually delivers, together with the full
exact counting pipeline (steps 1–6) for general `n`.
-/
import Mathlib

open Finset

namespace RamseyFirstMoment

/-! ## 1. Types and finite instances -/

/-- The 3-edges of `Fin n`: 3-element subsets. -/
abbrev Edge3 (n : ℕ) : Type := {s : Finset (Fin n) // s.card = 3}

/-- The 4-sets of `Fin n`: 4-element subsets. -/
abbrev Quad4 (n : ℕ) : Type := {s : Finset (Fin n) // s.card = 4}

/-- A 2-coloring of the 3-edges. -/
abbrev Coloring (n : ℕ) : Type := Edge3 n → Bool

/-! ## 2. Cardinality lemmas -/

theorem card_Edge3 (n : ℕ) : Fintype.card (Edge3 n) = Nat.choose n 3 := by
  simp +decide [ Fintype.card_subtype ]

theorem card_Quad4 (n : ℕ) : Fintype.card (Quad4 n) = Nat.choose n 4 := by
  norm_num

theorem card_Coloring (n : ℕ) : Fintype.card (Coloring n) = 2 ^ Nat.choose n 3 := by
  rw [ ← card_Edge3 ] ; exact Fintype.card_fun;

/-! ## 3. The 3-edges of a 4-set and the monochromatic predicate -/

/-- The four 3-edges contained in a 4-set `Q`. -/
def edgesOf {n : ℕ} (Q : Quad4 n) : Finset (Edge3 n) :=
  Finset.univ.filter (fun e => e.val ⊆ Q.val)

theorem card_edgesOf {n : ℕ} (Q : Quad4 n) : (edgesOf Q).card = 4 := by
  rw [ ← Finset.card_image_of_injective _ Subtype.coe_injective ];
  rw [ show ( image ( fun a : Edge3 n => ( a : Finset ( Fin n ) ) ) ( edgesOf Q ) ) = Finset.powersetCard 3 Q.val from ?_ ] ; simp +decide [ Q.2 ];
  ext; simp [edgesOf, Finset.mem_powersetCard]

theorem edgesOf_nonempty {n : ℕ} (Q : Quad4 n) : (edgesOf Q).Nonempty := by
  rw [← Finset.card_pos, card_edgesOf]; norm_num

/-- `MonoOn4 χ Q`: all 3-edges contained in `Q` receive the same color under `χ`. -/
def MonoOn4 {n : ℕ} (χ : Coloring n) (Q : Quad4 n) : Prop :=
  ∀ e₁ ∈ edgesOf Q, ∀ e₂ ∈ edgesOf Q, χ e₁ = χ e₂

instance {n : ℕ} (χ : Coloring n) (Q : Quad4 n) : Decidable (MonoOn4 χ Q) := by
  unfold MonoOn4; infer_instance

/-- The number of monochromatic 4-sets of a coloring. -/
def badCount {n : ℕ} (χ : Coloring n) : ℕ :=
  (Finset.univ.filter (fun Q : Quad4 n => MonoOn4 χ Q)).card

/-! ## General function-counting lemmas -/

/-- Bijection: functions `α → Bool` agreeing with the constant `c` on `S` are determined
by their values off `S`. -/
def constEquiv {α : Type*} [DecidableEq α] (S : Finset α) (c : Bool) :
    {f : α → Bool // ∀ a ∈ S, f a = c} ≃ ({a : α // a ∉ S} → Bool) where
  toFun f a := f.1 a.1
  invFun g := ⟨fun a => if h : a ∈ S then c else g ⟨a, h⟩, by intro a ha; simp [ha]⟩
  left_inv := by
    rintro ⟨f, hf⟩
    apply Subtype.ext
    funext a
    by_cases h : a ∈ S
    · simp [h, hf a h]
    · simp [h]
  right_inv := by
    intro g
    funext a
    simp [a.2]

/-
The number of functions `α → Bool` that take a *fixed* value `c` on `S` is
`2 ^ (|α| - |S|)`.
-/
theorem card_filter_eq_const {α : Type*} [Fintype α] [DecidableEq α]
    (S : Finset α) (c : Bool) :
    (Finset.univ.filter (fun f : α → Bool => ∀ a ∈ S, f a = c)).card
      = 2 ^ (Fintype.card α - S.card) := by
  convert Fintype.card_congr ( constEquiv S c ) using 1;
  · rw [ Fintype.subtype_card ];
  · simp +decide

/-
The number of functions `α → Bool` that are *constant* on a nonempty `S` is
`2 * 2 ^ (|α| - |S|)`.
-/
theorem card_filter_const_on {α : Type*} [Fintype α] [DecidableEq α]
    (S : Finset α) (hS : S.Nonempty) :
    (Finset.univ.filter (fun f : α → Bool => ∀ a ∈ S, ∀ b ∈ S, f a = f b)).card
      = 2 * 2 ^ (Fintype.card α - S.card) := by
  convert congr_arg₂ ( · + · ) ( card_filter_eq_const S true ) ( card_filter_eq_const S false ) using 1;
  · rw [ ← Finset.card_union_of_disjoint ];
    · congr with f ; by_cases h : ∀ a ∈ S, f a = true <;> simp +decide [ h ]; all_goals grind;
    · exact Finset.disjoint_left.mpr fun f hf₁ hf₂ => by obtain ⟨ a, ha ⟩ := hS; have := Finset.mem_filter.mp hf₁ |>.2 a ha; have := Finset.mem_filter.mp hf₂ |>.2 a ha; aesop;
  · ring

/-! ## 3'. Count of colorings making a fixed 4-set monochromatic -/

theorem card_mono_fixed_quad {n : ℕ} (Q : Quad4 n) :
    (Finset.univ.filter (fun χ : Coloring n => MonoOn4 χ Q)).card
      = 2 ^ (Nat.choose n 3 - 3) := by
  have hM : 4 ≤ Nat.choose n 3 := by
    have h4 : 4 ≤ n := by
      have hle : Q.val.card ≤ n := by simpa using Finset.card_le_univ Q.val
      have := Q.2; omega
    calc 4 = Nat.choose 4 3 := by decide
      _ ≤ Nat.choose n 3 := Nat.choose_le_choose 3 h4
  simp only [MonoOn4]
  rw [card_filter_const_on (edgesOf Q) (edgesOf_nonempty Q), card_Edge3, card_edgesOf,
    show Nat.choose n 3 - 3 = (Nat.choose n 3 - 4) + 1 by omega, pow_succ]
  ring

/-! ## 4. The exact incidence identity -/

theorem sum_badCount (n : ℕ) :
    ∑ χ : Coloring n, badCount χ = Nat.choose n 4 * 2 ^ (Nat.choose n 3 - 3) := by
  -- By definition of badCount, we can rewrite the left-hand side as a double sum.
  have h_double_sum : ∑ χ : Coloring n, badCount χ = ∑ Q : Quad4 n, ∑ χ : Coloring n, if MonoOn4 χ Q then 1 else 0 := by
    rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop;
  convert h_double_sum using 2;
  rw [ Finset.sum_congr rfl fun Q _ => by simpa using card_mono_fixed_quad Q ] ; norm_num [ card_Quad4 ]

/-! ## 5. The expectation formula -/

theorem expectation_badCount {n : ℕ} (hM : 3 ≤ Nat.choose n 3) :
    (∑ χ : Coloring n, (badCount χ : ℚ)) / (Fintype.card (Coloring n) : ℚ)
      = (Nat.choose n 4 : ℚ) / 8 := by
  -- Apply `sum_badCount` and `card_Coloring` to rewrite the LHS.
  have h_sum_badCount : ∑ χ : Coloring n, (badCount χ : ℚ) = Nat.choose n 4 * 2 ^ (Nat.choose n 3 - 3) := by
    rw_mod_cast [ sum_badCount ]
  have h_card_Coloring : (Fintype.card (Coloring n) : ℚ) = 2 ^ Nat.choose n 3 := by
    rw_mod_cast [ card_Coloring ]
  rw [h_sum_badCount, h_card_Coloring];
  rw [ div_eq_div_iff ] <;> first | positivity | rw [ show ( 2 : ℚ ) ^ n.choose 3 = 2 ^ ( n.choose 3 - 3 ) * 2 ^ 3 by rw [ ← pow_add, Nat.sub_add_cancel hM ] ] ; ring;

/-! ## 6. First-moment existence -/

theorem exists_good_of_choose_lt_eight {n : ℕ}
    (hM : 3 ≤ Nat.choose n 3) (h : Nat.choose n 4 < 8) :
    ∃ χ : Coloring n, badCount χ = 0 := by
  have h_card : ∑ χ : Coloring n, badCount χ = Nat.choose n 4 * 2 ^ (Nat.choose n 3 - 3) :=
    sum_badCount n
  contrapose! h_card;
  refine' ne_of_gt ( lt_of_lt_of_le _ ( Finset.sum_le_sum fun χ _ => Nat.one_le_iff_ne_zero.mpr ( h_card χ ) ) ) ; norm_num [ card_Coloring ];
  rw [ show 2 ^ n.choose 3 = 2 ^ ( n.choose 3 - 3 ) * 2 ^ 3 by rw [ ← pow_add, Nat.sub_add_cancel hM ] ] ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) ( n.choose 3 - 3 ) ]

/-! ## 7–8. The correct specialization: `R(4,4;3) > 5` -/

/-- First-moment existence at `n = 5`: there is a coloring of the 3-edges of `Fin 5`
with no monochromatic 4-set incidence (`badCount = 0`). -/
theorem exists_good_coloring_five : ∃ χ : Coloring 5, badCount χ = 0 :=
  exists_good_of_choose_lt_eight (by decide) (by decide)

/-- Repackaged conclusion `R(4,4;3) > 5`: there is a 2-coloring of the 3-subsets of
`Fin 5` with no monochromatic 4-set. -/
theorem ramsey_three_four_four_gt_five :
    ∃ χ : Coloring 5, ∀ Q : Quad4 5, ¬ MonoOn4 χ Q := by
  obtain ⟨χ, hχ⟩ := exists_good_coloring_five
  refine ⟨χ, ?_⟩
  intro Q hQ
  have hmem : Q ∈ Finset.univ.filter (fun Q : Quad4 5 => MonoOn4 χ Q) := by
    simp [hQ]
  rw [badCount, Finset.card_eq_zero] at hχ
  rw [hχ] at hmem
  exact absurd hmem (Finset.notMem_empty Q)

/-! ## The honest situation at `n = 13` -/

/-- The first-moment expectation at `n = 13` is `715/8`, not `< 1`. -/
theorem expectation_thirteen :
    (∑ χ : Coloring 13, (badCount χ : ℚ)) / (Fintype.card (Coloring 13) : ℚ)
      = 715 / 8 := by
  rw [expectation_badCount (by decide)]
  norm_num [show Nat.choose 13 4 = 715 from by decide]

/-- Consequently the first-moment argument is *insufficient* at `n = 13`: its expectation
is `≥ 1`, so it does not produce a good coloring (and indeed none exists, as
`R^{(3)}(4,4) = 13`). -/
theorem first_moment_insufficient_thirteen :
    ¬ ((Nat.choose 13 4 : ℚ) / 8 < 1) := by
  norm_num [show Nat.choose 13 4 = 715 from by decide]

end RamseyFirstMoment