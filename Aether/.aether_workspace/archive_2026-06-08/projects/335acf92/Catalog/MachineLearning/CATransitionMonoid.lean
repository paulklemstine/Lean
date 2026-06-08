/-
# Transition Monoid Exponent for Cellular Automata Column Languages

## Overview

For a nearest-neighbor cellular automaton with update rule `f : α × α → α`,
we define the column-extension DFA whose states track the "right diagonal"
of the spacetime diagram. We prove that the transition monoid satisfies
the aperiodicity identity `m^{h+1} = m^h` for all elements `m`, where `h`
is the strip height.

## Corrected Statement

The originally conjectured bound `m^3 = m^2` (uniform exponent 2) is **false**
for strip heights `h ≥ 3`. The correct bound is `m^{h+1} = m^h` (exponent `h`),
and this is tight: for `f(x,y) = x` and the single-letter transition reading `0`,
the exponent is exactly `h`.

## Key Proof Idea

Each step transition "shifts" the state by one position: coordinate `i` of the
output depends only on coordinates `0, …, i-1` of the input. Reading a word of
length `L` shifts by `L`, so coordinate `i` of the output depends only on
coordinates `0, …, max(-1, i-L)` of the input. For `L ≥ h`, the output is
completely independent of the input — the transition is a constant function.

Since `wordFn w` applied `h` times reads `h·|w| ≥ h` characters, `(wordFn w)^h`
is constant. Then `(wordFn w)^{h+1} = (wordFn w)^h ∘ (wordFn w)` maps every
state through `wordFn w` and then through the constant function, yielding the
same constant. Hence `m^{h+1} = m^h`.
-/

import Mathlib

namespace CellularAutomata

/-! ## Definitions -/

/-- Compute the new diagonal coordinate recursively.
    `diagStep f b a n` gives coordinate `n` of the new state when
    reading cell value `a` from a state whose coordinates are given by `b`.
    - `diagStep f b a 0 = a`
    - `diagStep f b a (n+1) = f (b n, diagStep f b a n)` -/
def diagStep (f : α × α → α) (b : ℕ → α) (a : α) : ℕ → α
  | 0 => a
  | n + 1 => f (b n, diagStep f b a n)

/-- Extend a `Fin h → α` function to `ℕ → α` using a default value. -/
def extendFin {α : Type*} {h : ℕ} (b : Fin h → α) (default : α) : ℕ → α :=
  fun n => if hn : n < h then b ⟨n, hn⟩ else default

/-- Single-letter transition: read cell `a` from state `b : Fin h → α`.
    The default value for out-of-range access is `a` (arbitrary; never used). -/
def stepFn (f : α × α → α) {h : ℕ} (a : α) (b : Fin h → α) : Fin h → α :=
  fun ⟨i, _⟩ => diagStep f (extendFin b a) a i

/-- Word transition: read a list of cell values from left to right. -/
def wordFn (f : α × α → α) (h : ℕ) : List α → (Fin h → α) → (Fin h → α)
  | [] => id
  | a :: w => wordFn f h w ∘ stepFn f a

/-! ## Key Lemma: diagStep depends only on coordinates < n -/

/-
`diagStep` depends only on the first `n` values of `b`.
-/
theorem diagStep_ext (f : α × α → α) (b b' : ℕ → α) (a : α) (n : ℕ)
    (h_eq : ∀ j, j < n → b j = b' j) :
    diagStep f b a n = diagStep f b' a n := by
  induction' n with n ih <;> simp +decide [ *, diagStep ];
  rw [ ih fun j hj => h_eq j ( Nat.lt_succ_of_lt hj ) ]

/-! ## Agreement Lemma -/

/-
If two states agree on coordinates `0, …, k-1`, then after one step
    transition they agree on coordinates `0, …, k`.
-/
theorem stepFn_agreement (f : α × α → α) {h : ℕ} (a : α)
    (b b' : Fin h → α) (k : ℕ)
    (hk : ∀ j : Fin h, (j : ℕ) < k → b j = b' j) :
    ∀ j : Fin h, (j : ℕ) < k + 1 → stepFn f a b j = stepFn f a b' j := by
  intro j hj;
  apply diagStep_ext;
  unfold extendFin;
  grind

/-
Reading a word of length `L` increases agreement by `L`:
    if two states agree on coordinates `0, …, k-1`, then after reading `w`
    they agree on coordinates `0, …, k + |w| - 1`.
-/
theorem wordFn_agreement (f : α × α → α) (h : ℕ) (w : List α)
    (b b' : Fin h → α) (k : ℕ)
    (hk : ∀ j : Fin h, (j : ℕ) < k → b j = b' j) :
    ∀ j : Fin h, (j : ℕ) < k + w.length → wordFn f h w b j = wordFn f h w b' j := by
  induction' w with a w ih generalizing b b' k <;> simp_all +decide [ wordFn ];
  convert ih ( stepFn f a b ) ( stepFn f a b' ) ( k + 1 ) _ using 2 ; simp +arith +decide;
  apply stepFn_agreement f a b b' k hk

/-! ## Constancy Lemma -/

/-
If `|w| ≥ h`, then `wordFn f h w` is a constant function:
    all input states produce the same output.
-/
theorem wordFn_constant (f : α × α → α) (h : ℕ) (w : List α)
    (hw : h ≤ w.length) (b b' : Fin h → α) :
    wordFn f h w b = wordFn f h w b' := by
  exact funext fun j => wordFn_agreement f h w b b' 0 ( by simp +decide ) j ( by linarith [ Fin.is_lt j ] )

/-! ## Composition Lemma -/

/-
`wordFn` is a monoid homomorphism: reading `u ++ v` is the same as
    reading `u` then `v`.
-/
theorem wordFn_append (f : α × α → α) (h : ℕ) (u v : List α) :
    wordFn f h (u ++ v) = wordFn f h v ∘ wordFn f h u := by
  induction' u with a u ih;
  · exact List.map_inj.mp rfl;
  · convert congr_arg ( fun x => x ∘ stepFn f a ) ih using 1

/-! ## Repeat List -/

/-- Repeat a list `n` times: `repeatList w n = w ++ w ++ ⋯ ++ w` (n copies). -/
def repeatList (w : List α) : ℕ → List α
  | 0 => []
  | n + 1 => w ++ repeatList w n

theorem repeatList_length (w : List α) (n : ℕ) :
    (repeatList w n).length = n * w.length := by
  induction' n with n ih;
  · simp [repeatList];
  · rw [ show repeatList w ( n + 1 ) = w ++ repeatList w n from rfl, List.length_append, ih, add_mul, one_mul ];
    ring

/-
`wordFn` of a repeated list equals iteration.
-/
theorem wordFn_repeatList (f : α × α → α) (h : ℕ) (w : List α) (n : ℕ) :
    wordFn f h (repeatList w n) = (wordFn f h w)^[n] := by
  induction' n with n ih;
  · rfl;
  · convert wordFn_append f h w ( repeatList w n ) using 1;
    exact ih.symm ▸ rfl

/-! ## Main Theorem -/

/-
**Main Theorem (Corrected)**: For every word `w`, the transition function
    `wordFn f h w` satisfies `m^{h+1} = m^h`. That is, iterating the transition
    `h+1` times gives the same result as iterating it `h` times.

    The proof uses two facts:
    1. `(wordFn w)^h` is a constant function (since it reads `h·|w| ≥ h` characters).
    2. A constant function composed with any function is still the same constant.
-/
theorem transition_stabilizes (f : α × α → α) (h : ℕ) (w : List α) :
    (wordFn f h w)^[h + 1] = (wordFn f h w)^[h] := by
  by_cases hw : w = [];
  · aesop;
  · -- By the properties of the wordFn function, we can rewrite the goal using the repeatList function.
    have h_repeat : (wordFn f h w)^[h + 1] = wordFn f h (repeatList w (h + 1)) ∧ (wordFn f h w)^[h] = wordFn f h (repeatList w h) := by
      exact ⟨ wordFn_repeatList f h w ( h + 1 ) ▸ rfl, wordFn_repeatList f h w h ▸ rfl ⟩;
    -- Since `repeatList w h` has length `h * w.length ≥ h`, we can apply the `wordFn_constant` lemma.
    have h_const : ∀ (b b' : Fin h → α), wordFn f h (repeatList w h) b = wordFn f h (repeatList w h) b' := by
      apply wordFn_constant;
      rw [ repeatList_length ];
      exact le_mul_of_one_le_right ( Nat.zero_le _ ) ( List.length_pos_iff.mpr hw );
    have h_eq : wordFn f h (repeatList w (h + 1)) = wordFn f h (repeatList w h) ∘ wordFn f h w := by
      rw [ show repeatList w ( h + 1 ) = w ++ repeatList w h from rfl, wordFn_append ];
    exact h_repeat.1.trans ( h_eq.trans ( funext fun x => h_const _ _ ) ) |> Eq.trans <| h_repeat.2.symm

/-- The aperiodicity exponent version: stated in terms of the iterate. -/
theorem transition_aperiodic (f : α × α → α) (h : ℕ) (w : List α)
    (b : Fin h → α) :
    (wordFn f h w)^[h + 1] b = (wordFn f h w)^[h] b := by
  exact congr_fun (transition_stabilizes f h w) b

/-! ## Counterexample: The original claim m³ = m² is false for h ≥ 3

The rule `f(x, y) = x` (left projection) with height `h = 3` provides a
counterexample. The single-letter transition reading `false` acts as a
right shift: `(b₀, b₁, b₂) ↦ (false, b₀, b₁)`. Then:
- `m²(true, false, false) = (false, false, true)`
- `m³(true, false, false) = (false, false, false)`
So `m² ≠ m³`, disproving the original conjecture `m³ = m²` for height 3.
-/

/-- The left-projection rule: `f(x, y) = x`. -/
def leftRule : Bool × Bool → Bool := fun p => p.1

/-
The step transition for the left rule acts as a right shift.
-/
theorem leftRule_step (b : Fin 3 → Bool) :
    stepFn leftRule false b = fun i =>
      match i with
      | ⟨0, _⟩ => false
      | ⟨1, _⟩ => b ⟨0, by omega⟩
      | ⟨2, _⟩ => b ⟨1, by omega⟩
      | ⟨n + 3, h⟩ => absurd h (by omega) := by
  exact funext fun x => by rcases x with ⟨ _ | _ | _ | _, _ | _ | _ | _ ⟩ <;> trivial;

/-
Counterexample: `m² ≠ m³` for height 3 with the left-projection rule.
-/
theorem counterexample_m2_ne_m3 :
    ∃ (b : Fin 3 → Bool),
      (stepFn leftRule false)^[2] b ≠ (stepFn leftRule false)^[3] b := by
  exists fun i => i = 0

end CellularAutomata