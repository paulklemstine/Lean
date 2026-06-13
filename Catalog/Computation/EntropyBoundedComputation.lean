import Mathlib

/-!
# Entropy-Bounded Computation (EBC)

This file develops a small, fully formal core for the **Entropy-Bounded Computation**
framework, which treats a single deterministic computational step as a function
between finite *state spaces* and measures its information content by the
base-2 logarithm of the number of states (the Shannon entropy of the uniform
distribution over the states, measured in bits).

The guiding physical intuition is **Landauer's principle**: erasing or merging
logical states is necessarily irreversible and carries a nonnegative entropy
cost.  Here we isolate the purely mathematical skeleton of that statement.

## Main results

* `EBC.entropy_nonneg` — entropy of a nonempty finite state space is `≥ 0`.
* `EBC.entropy_eq_zero_of_card_one` — a single-state machine stores no information.
* `EBC.entropy_reversible_invariant` — reversible (bijective) computation
  preserves entropy.
* `EBC.entropy_prod` — entropy is additive over independent (product) state spaces.
* `EBC.entropy_le_of_surjective` — deterministic computation cannot create
  entropy (a data-processing / second-law inequality).
* `EBC.landauer_erasure_pos` — erasing a state space with at least two states
  to a single state has strictly positive entropy cost.
* `EBC.landauer_erasure_eq` — the entropy released by erasure equals the source
  entropy and is nonnegative.

This extends the catalog's `Computation/EntropyBridge.lean`, which bounds
*cardinality* via injective encodings; here we package the log-cardinality as a
genuine real-valued entropy and prove its structural laws.
-/

namespace EBC

open scoped Real

/-- The Shannon entropy, in bits, of the uniform distribution over a finite type
of computational states: the base-2 logarithm of the number of states. -/
noncomputable def entropy (S : Type*) [Fintype S] : ℝ :=
  Real.logb 2 (Fintype.card S)

@[simp] theorem entropy_def (S : Type*) [Fintype S] :
    entropy S = Real.logb 2 (Fintype.card S) := rfl

-- !-- Card of a nonempty fintype is ≥ 1, and logb base 2 of something ≥ 1 is ≥ 0. -- !--
/-- A nonempty finite state space carries nonnegative entropy. -/
theorem entropy_nonneg (S : Type*) [Fintype S] [Nonempty S] : 0 ≤ entropy S :=
  Real.logb_nonneg (by norm_num) (mod_cast Fintype.card_pos)

-- !-- A single-state machine stores no information: card = 1 ⇒ logb 2 1 = 0. -- !--
/-- A state space with exactly one state has zero entropy. -/
theorem entropy_eq_zero_of_card_one (S : Type*) [Fintype S]
    (h : Fintype.card S = 1) : entropy S = 0 := by
  unfold entropy; aesop

-- !-- Bijection preserves cardinality, hence preserves logb of cardinality. -- !--
/-- **Reversibility preserves entropy.** A bijection between finite state spaces
(a reversible computation) leaves the entropy unchanged. -/
theorem entropy_reversible_invariant {S T : Type*} [Fintype S] [Fintype T]
    (e : S ≃ T) : entropy S = entropy T := by
  simp [entropy, Fintype.card_congr e]

-- !-- card (S × T) = card S * card T and logb is additive on positive args. -- !--
/-- **Independent composition is additive.** The entropy of a product state
space is the sum of the component entropies. -/
theorem entropy_prod (S T : Type*) [Fintype S] [Fintype T]
    [Nonempty S] [Nonempty T] :
    entropy (S × T) = entropy S + entropy T := by
  convert Real.logb_mul ?_ ?_ using 1
  · norm_num [entropy]
  · exact Nat.cast_ne_zero.mpr Fintype.card_ne_zero
  · exact Nat.cast_ne_zero.mpr Fintype.card_ne_zero

-- !-- A surjection forces card T ≤ card S; logb base > 1 is monotone. -- !--
/-- **Second law / data-processing inequality.** A deterministic computation
`f : S → T` that hits every output (surjective) cannot increase entropy. -/
theorem entropy_le_of_surjective {S T : Type*} [Fintype S] [Fintype T]
    [Nonempty S] {f : S → T} (hf : Function.Surjective f) :
    entropy T ≤ entropy S := by
  unfold entropy
  gcongr
  · norm_num
  · exact Nat.cast_pos.mpr (Fintype.card_pos_iff.mpr ⟨f (Classical.arbitrary S)⟩)
  · exact Fintype.card_le_of_surjective f hf

-- !-- card ≥ 2 ⇒ logb 2 (card) > logb 2 1 = 0 by strict monotonicity. -- !--
/-- **Landauer cost of erasure.** Resetting a state space with at least two
states to a single fixed state dissipates strictly positive entropy. -/
theorem landauer_erasure_pos (S : Type*) [Fintype S]
    (h : 2 ≤ Fintype.card S) : 0 < entropy S :=
  Real.logb_pos (by norm_num) (mod_cast h)

-- !-- The target T has zero entropy, so the dissipated entropy collapses to entropy S. -- !--
/-- The entropy released by erasing `S` down to one cleared state is exactly
`entropy S`, and it is nonnegative. -/
theorem landauer_erasure_eq {S T : Type*} [Fintype S] [Fintype T]
    [Nonempty S] (h : Fintype.card T = 1) :
    entropy S - entropy T = entropy S ∧ 0 ≤ entropy S - entropy T := by
  have hT : entropy T = 0 := entropy_eq_zero_of_card_one T h
  exact ⟨by rw [hT, sub_zero], by rw [hT, sub_zero]; exact entropy_nonneg S⟩

end EBC