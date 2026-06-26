import Mathlib

/-!
# Tropical Differential Equations II: The Tropical Vanishing / Balancing Lemma

The combinatorial heart of tropical geometry is the **balancing condition**: a tropical
polynomial "vanishes" at a point exactly when the minimum of its monomial valuations is
attained at least twice.  This file proves the power-series incarnation of that principle.

The key analytic fact is `order_sum_eq_of_unique_min`: a finite sum of power series whose
orders have a *unique strict minimum* has order equal to that minimum.  Consequently, a sum
that is *zero* (order `⊤`) can never have a unique strict minimizer among its nonzero terms
(`tropical_balancing`) — the minimum must be attained at least twice.  This is precisely the
"tropical vanishing" condition underlying the tropical fundamental theorem.

## Main results

* `le_order_sum` / `lt_order_sum` — (strict) lower bounds for the order of a finite sum.
* `order_sum_eq_of_unique_min` — unique strict minimum ⟹ order of the sum equals it.
* `tropical_balancing` — a vanishing finite sum forces the minimal order to be non-unique.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Cancellation in `∑ φⱼ = 0` can only happen between terms
  of *equal* order; therefore a vanishing sum must have its lowest order achieved by ≥ 2 terms.
  This is the analytic shadow of the tropical balancing condition.
* **Experiment (Experimenter).**  `min_order_le_order_add` and `order_add_of_order_ne` from
  Mathlib give the two-term case.  Lifting to finite sums needs a strict lower bound
  `lt_order_sum`, proved by induction with a nonemptiness side condition (an empty sum has
  order `⊤`, which would break strictness).
* **Analysis (Analyst).**  The hypothesis `(φ i₀).order ≠ ⊤` in `tropical_balancing` is
  essential, not cosmetic: a single zero term trivially "balances" with nothing, so balancing
  is a statement about the *nonzero* terms.  Dropping it makes the theorem false (take
  `s = {i₀}`, `φ i₀ = 0`).
* **Critique (Critic).**  `tropical_balancing` is genuinely a `by_contra` argument that
  invokes the exact-order computation, not a `simp`/`decide` triviality; it is the lemma that
  converts a *classical* power-series identity into a *tropical* (min-plus) constraint.
-/

open PowerSeries Finset

namespace Tropical.DiffVal

variable {K : Type*} [Field K]

/-- A common order `m` lower-bounding every summand bounds the order of the finite sum. -/
theorem le_order_sum (s : Finset ℕ) (φ : ℕ → K⟦X⟧) (m : ℕ∞)
    (h : ∀ j ∈ s, m ≤ (φ j).order) : m ≤ (∑ j ∈ s, φ j).order := by
  induction s using Finset.induction with
  | empty => simp
  | insert a t ha ih =>
    rw [Finset.sum_insert ha]
    exact le_trans (le_min (h a (mem_insert_self a t))
      (ih (fun j hj => h j (mem_insert_of_mem hj)))) (min_order_le_order_add _ _)

/-- Strict version of `le_order_sum` for a nonempty index set: if every summand has order
strictly above `c`, so does the sum. -/
theorem lt_order_sum (s : Finset ℕ) (hs : s.Nonempty)
    (φ : ℕ → K⟦X⟧) (c : ℕ∞) (h : ∀ j ∈ s, c < (φ j).order) :
    c < (∑ j ∈ s, φ j).order := by
  classical
  induction s using Finset.induction with
  | empty => exact absurd rfl hs.ne_empty
  | insert a t ha ih =>
    rw [Finset.sum_insert ha]
    have ha' : c < (φ a).order := h a (mem_insert_self a t)
    rcases t.eq_empty_or_nonempty with he | hne
    · subst he; simpa using ha'
    · exact lt_of_lt_of_le (lt_min ha' (ih hne (fun j hj => h j (mem_insert_of_mem hj))))
        (min_order_le_order_add _ _)

/-- **Unique strict minimum determines the order of a sum.**  If one summand `φ i₀` has order
strictly below all the others, then the order of `∑ φⱼ` equals `(φ i₀).order`. -/
theorem order_sum_eq_of_unique_min (s : Finset ℕ) (φ : ℕ → K⟦X⟧) (i₀ : ℕ)
    (hi₀ : i₀ ∈ s) (hmin : ∀ j ∈ s, j ≠ i₀ → (φ i₀).order < (φ j).order) :
    (∑ j ∈ s, φ j).order = (φ i₀).order := by
  classical
  rw [← Finset.add_sum_erase s φ hi₀]
  rcases (s.erase i₀).eq_empty_or_nonempty with he | hne
  · simp [he]
  · have hrest : (φ i₀).order < (∑ j ∈ s.erase i₀, φ j).order :=
      lt_order_sum _ hne φ _ (fun j hj =>
        hmin j (Finset.mem_of_mem_erase hj) (Finset.ne_of_mem_erase hj))
    rw [order_add_of_order_ne _ _ (ne_of_lt hrest), min_eq_left (le_of_lt hrest)]

/-- **Tropical balancing / vanishing lemma.**  If a finite sum of power series is zero, then
the minimal order among the terms cannot be uniquely attained: for any nonzero term `φ i₀`
there is a *different* term whose order is `≤ (φ i₀).order`.  In tropical language, the
minimum of the term-valuations is attained at least twice — the tropical vanishing condition. -/
theorem tropical_balancing (s : Finset ℕ) (φ : ℕ → K⟦X⟧)
    (hsum : ∑ j ∈ s, φ j = 0) (i₀ : ℕ) (hi₀ : i₀ ∈ s) (hne : (φ i₀).order ≠ ⊤) :
    ∃ j ∈ s, j ≠ i₀ ∧ (φ j).order ≤ (φ i₀).order := by
  by_contra hcon
  push_neg at hcon
  have huniq : ∀ j ∈ s, j ≠ i₀ → (φ i₀).order < (φ j).order := fun j hj hji => hcon j hj hji
  have hord := order_sum_eq_of_unique_min s φ i₀ hi₀ huniq
  rw [hsum, order_zero] at hord
  exact hne hord.symm

end Tropical.DiffVal