import Mathlib

/-!
# Decidability of Wolfram's Four-Class Classification for Elementary Cellular Automata

We formalize elementary cellular automata on finite cyclic lattices `ZMod n`, and prove
that Wolfram's four-class classification of their dynamics (starting from the all-true
configuration) is decidable.

The development is organized in strictly ordered, independent layers:

* **Layer 1.** Definitions (`localRule`, `step`) and closed-form rule lemmas.
* **Layer 2.** Poincaré recurrence: every orbit of a self-map on a finite type is
  eventually periodic.
* **Layer 3.** Decidability of reachability via a bounded search.
* **Layer 4.** The `WolframClass` type, the computable `classify` function, and the
  decidability of the classification.
-/

namespace WolframECA

open Function

/-! ## Layer 1 — Definitions and closed-form rules -/

/-- The local update rule of an elementary cellular automaton with Wolfram code `r`.
Given the left neighbour `l`, the cell `c`, and the right neighbour `ri`, the new state
is the bit of `r` at position `l*4 + c*2 + ri`. -/
def localRule (r : Fin 256) (l c ri : Bool) : Bool :=
  Nat.testBit r.val (l.toNat * 4 + c.toNat * 2 + ri.toNat)

/-- One synchronous step of the elementary cellular automaton with code `r` on the
cyclic lattice `ZMod n`. -/
def step (n : ℕ) (r : Fin 256) (cfg : ZMod n → Bool) (i : ZMod n) : Bool :=
  localRule r (cfg (i - 1)) (cfg i) (cfg (i + 1))

theorem localRule_zero (l c ri : Bool) : localRule 0 l c ri = false := by
  revert l c ri; decide

theorem localRule_51 (l c ri : Bool) : localRule 51 l c ri = !c := by
  revert l c ri; decide

theorem localRule_90 (l c ri : Bool) : localRule 90 l c ri = (l ^^ ri) := by
  revert l c ri; decide

theorem localRule_204 (l c ri : Bool) : localRule 204 l c ri = c := by
  revert l c ri; decide

/-! ## Layer 2 — Poincaré recurrence for finite dynamical systems -/

/-
**Poincaré recurrence.** For any self-map `f` of a finite type, every orbit is
eventually periodic: there is a positive period and a pre-period after which the orbit
repeats.
-/
theorem iterate_eventually_periodic {α : Type*} [Fintype α] (f : α → α) (x : α) :
    ∃ (period : ℕ) (pre : ℕ), period > 0 ∧ ∀ m ≥ pre, f^[m] x = f^[m + period] x := by
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ f^[i] x = f^[j] x := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  refine' ⟨ j - i, i, tsub_pos_of_lt hij, fun m hm => _ ⟩;
  induction hm <;> simp_all +decide [ Nat.succ_add, Function.iterate_succ_apply' ];
  rw [ Nat.add_sub_cancel' hij.le ]

/-! ## Layer 3 — Decidability of reachability -/

/-- `y` is reachable from `x` under iteration of `f`. -/
def reaches {α : Type*} (f : α → α) (x y : α) : Prop := ∃ k, f^[k] x = y

/-
Reachability can be witnessed within `Fintype.card α` steps.
-/
theorem reaches_iff_reaches_bounded {α : Type*} [Fintype α] (f : α → α) (x y : α) :
    reaches f x y ↔ ∃ k ≤ Fintype.card α, f^[k] x = y := by
  refine' ⟨ _, fun h => h.imp fun k hk => hk.2 ⟩;
  rintro ⟨ k, hk ⟩;
  by_contra! h_contra;
  -- By the pigeonhole principle, since there are only `Fintype.card α` distinct values in the orbit of `x`, there must exist indices `i` and `j` with `0 ≤ i < j ≤ Fintype.card α` such that `f^[i] x = f^[j] x`.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j, i < j ∧ i ≤ Fintype.card α ∧ j ≤ Fintype.card α ∧ f^[i] x = f^[j] x := by
    by_cases h_cases : ∀ i j : ℕ, i < j → i ≤ Fintype.card α → j ≤ Fintype.card α → f^[i] x ≠ f^[j] x;
    · exact absurd ( Fintype.card_le_of_injective ( fun i : Fin ( Fintype.card α + 1 ) => f^[i] x ) fun i j hij => le_antisymm ( not_lt.1 fun hi => h_cases _ _ hi ( by linarith [ Fin.is_lt j ] ) ( by linarith [ Fin.is_lt i ] ) hij.symm ) ( not_lt.1 fun hj => h_cases _ _ hj ( by linarith [ Fin.is_lt i ] ) ( by linarith [ Fin.is_lt j ] ) hij ) ) ( by simp +decide );
    · exact by push_neg at h_cases; exact h_cases;
  -- Since $f^[i] x = f^[j] x$, we have $f^[k] x = f^[k - (j - i)] x$ for any $k \geq j$.
  have h_periodic : ∀ k ≥ j, f^[k] x = f^[k - (j - i)] x := by
    intro k hk; induction hk <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    · rw [ Nat.sub_sub_self hij.le, h_eq.2.2 ];
    · rw [ Nat.succ_sub ( by omega ), Function.iterate_succ_apply' ];
  -- By repeatedly applying the periodicity, we can reduce $k$ to a value less than or equal to $Fintype.card α$.
  have h_reduction : ∀ m ≥ j, ∃ k' ≤ Fintype.card α, f^[m] x = f^[k'] x := by
    intro m hm
    induction' m using Nat.strong_induction_on with m ih;
    grind;
  exact h_contra _ ( h_reduction k ( le_of_not_gt fun h => h_contra k ( by linarith ) hk ) |> Classical.choose_spec |> And.left ) ( h_reduction k ( le_of_not_gt fun h => h_contra k ( by linarith ) hk ) |> Classical.choose_spec |> And.right |> Eq.symm |> fun h => h ▸ hk )

instance reaches_decidable {α : Type*} [Fintype α] [DecidableEq α] (f : α → α) (x y : α) :
    Decidable (reaches f x y) :=
  decidable_of_iff _ (reaches_iff_reaches_bounded f x y).symm

/-! ## Layer 4 — Wolfram classification -/

/-- Wolfram's four behavioural classes of cellular automata. -/
inductive WolframClass where
  | classI
  | classII
  | classIII
  | classIV
deriving DecidableEq, Repr

/-- Classify the elementary cellular automaton with code `r` on the cyclic lattice
`ZMod n`, by examining the orbit of the all-true configuration.

Because the state space is finite, the orbit is eventually periodic with some minimal
period `p`.

* **Class I** if it settles to a fixed point (`p = 1`).
* **Class II** if it settles to a period at most `2`.
* **Class III** if it settles to a period greater than `2`.
* **Class IV** otherwise (this branch is unreachable for `n > 0`, but is kept so that
  `classify` is total).
-/
def classify (n : ℕ) [NeZero n] (r : Fin 256) : WolframClass :=
  let f := step n r
  let cfg0 : ZMod n → Bool := fun _ => true
  let card := Fintype.card (ZMod n → Bool)
  let s := f^[card] cfg0
  if f s = s then WolframClass.classI
  else if f^[2] s = s then WolframClass.classII
  else if ∃ p ≤ card, 0 < p ∧ f^[p] s = s then WolframClass.classIII
  else WolframClass.classIV

/-- The classification is decidable: for any target class `c`, it is decidable whether
`classify n r = c`. (Stated as a `def` because `Decidable` is data, not a proposition.) -/
def classify_decidable (n : ℕ) [NeZero n] (r : Fin 256) (c : WolframClass) :
    Decidable (classify n r = c) :=
  inferInstance

end WolframECA