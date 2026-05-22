/-
# Reversible Computing: Garbage Compression and Complexity Bounds

This file formalizes the principle that **predictable garbage is cheap to erase**:
if a function's range can be injectively compressed, the erasure cost (measured
as log of the range size) is bounded by the compressed target size.

## Main Results

* `entropyDefect_le_log_card_codomain` — entropy defect ≤ log(card α)
* `entropyDefect_eq_log_div` — entropy defect = log(card α / card range)
* `erasure_cost_compression_bound` — log|range g| ≤ log|δ| when range g ↪ δ
* `compression_strict_improvement` — strict log improvement for nonempty types
* `parity_range_card` — parity has exactly 2 outputs for n ≥ 1
* `parity_entropyDefect` — entropy defect of parity is (n-1) * log 2

## Mathematical Significance

Not all ancilla are equal: structured garbage has lower effective thermodynamic cost.
-/

import Mathlib
import Speculative.RankEntropy

open Real Set Fintype

noncomputable section

/-! ## Entropy Defect Bounds -/

/-- The entropy defect of any function is at most log(card α). -/
theorem entropyDefect_le_log_card_codomain
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    [Nonempty α]
    (f : α → β) :
    entropyDefectFn f ≤ Real.log (Fintype.card α) := by
  exact sub_le_self _ (Real.log_nonneg (mod_cast Fintype.card_pos_iff.mpr
    (by exact ⟨_, Set.mem_range_self (Classical.arbitrary α)⟩)))

/-- The entropy defect equals log of the ratio card(α)/card(range f). -/
theorem entropyDefect_eq_log_div
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    [Nonempty α]
    (f : α → β) :
    entropyDefectFn f = Real.log ((Fintype.card α : ℝ) / (Fintype.card (Set.range f) : ℝ)) := by
  unfold entropyDefectFn
  rw [Real.log_div (Nat.cast_ne_zero.mpr Fintype.card_ne_zero)
    (Nat.cast_ne_zero.mpr (Nat.ne_of_gt (Fintype.card_pos_iff.mpr
      ⟨_, Set.mem_range_self (Classical.arbitrary α)⟩)))]

/-! ## Garbage Compression -/

/-
**Erasure cost compression bound.** If the range of `g` can be injectively
    embedded into `δ`, then the erasure cost `log|range g|` is at most `log|δ|`.
    This is the key insight: compressible garbage has lower erasure cost.
-/
theorem erasure_cost_compression_bound
    {α γ δ : Type*} [Fintype α] [Fintype γ] [Fintype δ]
    [DecidableEq γ] [DecidableEq δ]
    (g : α → γ)
    (C : Set.range g ↪ δ) :
    Real.log (Fintype.card (Set.range g)) ≤ Real.log (Fintype.card δ) := by
  have h_card_range : (Fintype.card (Set.range g) : ℝ) ≤ (Fintype.card δ : ℝ) := by
    exact_mod_cast Fintype.card_le_of_injective C C.injective;
  by_cases h : 0 < Fintype.card (Set.range g) <;> simp_all +decide +decide [ Real.log_le_log ];
  exact Real.log_natCast_nonneg _

/-
**Strict compression improvement.** If δ is nonempty and strictly smaller than γ,
    log|δ| < log|γ|.
-/
theorem compression_strict_improvement
    {γ δ : Type*} [Fintype γ] [Fintype δ]
    [Nonempty δ]
    (hlt : Fintype.card δ < Fintype.card γ) :
    Real.log (Fintype.card δ) < Real.log (Fintype.card γ) := by
  exact Real.log_lt_log ( Nat.cast_pos.mpr <| Fintype.card_pos ) ( Nat.cast_lt.mpr hlt )

/-! ## Parity Example -/

/-- XOR/parity function on `Fin n → Bool`: returns whether the number of
    `true` values is even. -/
def parityFn (n : ℕ) : (Fin n → Bool) → Bool :=
  fun v => (Finset.univ.filter (fun i => v i = true)).card % 2 == 0

/-
For n ≥ 1, the parity function is surjective onto Bool.
-/
theorem parityFn_surjective (n : ℕ) (hn : 1 ≤ n) :
    Function.Surjective (parityFn n) := by
  intro b;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ parityFn ];
  · native_decide +revert;
  · cases b <;> [ refine' ⟨ fun i => if i = ⟨ 0, Nat.zero_lt_succ _ ⟩ then Bool.true else Bool.false, _ ⟩ ; refine' ⟨ fun _ => Bool.false, _ ⟩ ] <;> simp +decide;
    simp +decide [ Finset.filter_eq' ]

/-
For n ≥ 1, card(range(parityFn n)) = 2.
-/
theorem parity_range_card (n : ℕ) (hn : 1 ≤ n) :
    Fintype.card (Set.range (parityFn n)) = 2 := by
  -- Apply the fact that the image of a surjective function over a finite set has the same cardinality as the codomain.
  have h_card : Fintype.card (Set.range (parityFn n)) = Fintype.card Bool := by
    apply Fintype.card_congr;
    exact Equiv.ofBijective ( fun x => x.val ) ⟨ fun x y h => by aesop, fun x => by have := parityFn_surjective n hn x; aesop ⟩;
  convert h_card using 1

/-
Entropy defect of parity on n bits equals (n-1) * log 2.
-/
theorem parity_entropyDefect (n : ℕ) (hn : 1 ≤ n) :
    entropyDefectFn (parityFn n) = (n - 1 : ℝ) * Real.log 2 := by
  -- Apply the definition of entropy defect.
  unfold entropyDefectFn;
  rw [ show card ( range ( parityFn n ) ) = 2 from parity_range_card n hn ] ; norm_num ; ring

end