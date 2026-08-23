/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Known versus unresolved cards — V. The learning-theoretic incarnation

The deck of `d` known and `u` unresolved cards has an exact analogue in learning
theory.  Fix a finite domain `X` and let the *target* `f : X → Bool` be uniformly
random.  A learner sees the labels on a training set `T` and outputs a hypothesis
`L f`.  Then:

* the points of `T` are the **known cards** — a consistent learner reproduces
  their labels with certainty;
* the points outside `T` are the **unresolved cards** — and, scored at fair odds,
  each of them has *exactly* zero expected value.

The second statement is Wolpert's No-Free-Lunch phenomenon, and the proof here is
the sharpest possible one: the label-flip at an off-training point is a
fixed-point-free involution of the space of targets which preserves the
hypothesis and negates the score.  The `k`-ary version replaces the involution by
the free action of the cyclic group `ZMod k`.

## Main results

* `sum_offTraining_score_eq_zero` — the involution argument (binary labels).
* `no_free_lunch_expected_score` — **`E[total ±1 score] = |T|` exactly**: the
  learning-theoretic form of "expected payoff is exactly `d`".
* `expected_correct_count` — equivalently, expected accuracy is
  `|T| + (|X| - |T|)/2`: chance level off the training set.
* `training_dependence_is_necessary` — sharpness: a learner allowed to peek at
  off-training labels achieves the maximal score, so the hypothesis that `L`
  depends only on the training labels cannot be dropped.
* `sum_offTraining_kary_score_eq_zero`, `no_free_lunch_kary_expected_score` —
  the `ZMod k` generalisation, with fair odds `(k-1) : 1`.

All of these are instances of the splitting theorem
`expected_total_eq_certain_sum` of `Basic.lean`.
-/

import MachineLearning.KnownUnresolvedCards.Basic

namespace KnownUnresolvedCards

open Finset

variable {X : Type*} [Fintype X] [DecidableEq X]

/-! ## Binary labels: the flip involution -/

/-- Flip the label of the single point `x`. -/
def flipAt (x : X) (f : X → Bool) : X → Bool := Function.update f x (!(f x))

omit [Fintype X] in
lemma flipAt_involutive (x : X) : Function.Involutive (flipAt (X := X) x) := by
  intro f
  funext y
  by_cases h : y = x
  · subst h; simp [flipAt]
  · simp [flipAt, Function.update_of_ne h]

omit [Fintype X] in
@[simp] lemma flipAt_apply_self (x : X) (f : X → Bool) : flipAt x f x = !(f x) := by
  simp [flipAt]

omit [Fintype X] in
lemma flipAt_apply_ne {x y : X} (h : y ≠ x) (f : X → Bool) : flipAt x f y = f y := by
  simp [flipAt, Function.update_of_ne h]

/-- **The No-Free-Lunch involution.**  If the learner `L` depends on the target
only through its labels on `T`, then at any point `x ∉ T` the `±1` score sums to
zero over all targets: flipping the label at `x` leaves the hypothesis unchanged
and negates the score. -/
theorem sum_offTraining_score_eq_zero (T : Finset X) (x : X) (hx : x ∉ T)
    (L : (X → Bool) → (X → Bool))
    (hL : ∀ f g : X → Bool, (∀ y ∈ T, f y = g y) → L f = L g) :
    ∑ f : X → Bool, (if L f x = f x then (1 : ℚ) else -1) = 0 := by
  set p : (X → Bool) → ℚ := fun f => if L f x = f x then (1 : ℚ) else -1 with hp
  have key : ∀ f : X → Bool, p (flipAt x f) = -p f := by
    intro f
    have hLe : L (flipAt x f) = L f := by
      refine hL _ _ ?_
      intro y hy
      refine flipAt_apply_ne ?_ f
      intro h; subst h; exact hx hy
    simp only [hp, hLe, flipAt_apply_self]
    cases hb : L f x <;> cases hb2 : f x <;> simp
  have h1 : ∑ f : X → Bool, p (flipAt x f) = ∑ f : X → Bool, p f :=
    Fintype.sum_bijective (flipAt x) (flipAt_involutive x).bijective _ _ (fun _ => rfl)
  have h2 : ∑ f : X → Bool, p (flipAt x f) = -∑ f : X → Bool, p f := by
    rw [← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun f _ => key f
  have h3 := h1.symm.trans h2
  linarith

/-- Off the training set, the `±1` score is a *fair* card. -/
theorem offTraining_fair (T : Finset X) (x : X) (hx : x ∉ T)
    (L : (X → Bool) → (X → Bool))
    (hL : ∀ f g : X → Bool, (∀ y ∈ T, f y = g y) → L f = L g) :
    Fair (fun f : X → Bool => if L f x = f x then (1 : ℚ) else -1) := by
  rw [Fair, E_def, sum_offTraining_score_eq_zero T x hx L hL, zero_div]

/-- **No Free Lunch, deck form.**  A learner that is consistent on the training
set `T` and that depends on the target only through the training labels has
expected total `±1` score exactly `|T|`, whatever the algorithm: the `|T|`
resolved points pay one unit each and the unresolved points pay nothing on
average. -/
theorem no_free_lunch_expected_score (T : Finset X) (L : (X → Bool) → (X → Bool))
    (hL : ∀ f g : X → Bool, (∀ y ∈ T, f y = g y) → L f = L g)
    (hT : ∀ f : X → Bool, ∀ y ∈ T, L f y = f y) :
    E (fun f : X → Bool => ∑ y : X, (if L f y = f y then (1 : ℚ) else -1)) = (T.card : ℚ) := by
  have hres : ∀ y ∈ T, Resolved (fun f : X → Bool => if L f y = f y then (1 : ℚ) else -1) 1 := by
    intro y hy f
    exact if_pos (hT f y hy)
  have hfair : ∀ y ∉ T, Fair (fun f : X → Bool => if L f y = f y then (1 : ℚ) else -1) :=
    fun y hy => offTraining_fair T y hy L hL
  have := expected_total_eq_certain_sum (Ω := X → Bool)
    (fun y f => if L f y = f y then (1 : ℚ) else -1) T (fun _ => 1) hres hfair
  simpa using this

/-- **Expected accuracy is chance level off the training set.**  The expected
number of correctly predicted points is `(|T| + |X|)/2`, i.e. all of `T` plus
exactly half of the rest. -/
theorem expected_correct_count (T : Finset X) (L : (X → Bool) → (X → Bool))
    (hL : ∀ f g : X → Bool, (∀ y ∈ T, f y = g y) → L f = L g)
    (hT : ∀ f : X → Bool, ∀ y ∈ T, L f y = f y) :
    E (fun f : X → Bool => ∑ y : X, (if L f y = f y then (1 : ℚ) else 0))
      = ((T.card : ℚ) + (Fintype.card X : ℚ)) / 2 := by
  have hpt : ∀ f : X → Bool,
      ∑ y : X, (if L f y = f y then (1 : ℚ) else 0)
        = (∑ y : X, (if L f y = f y then (1 : ℚ) else -1) + (Fintype.card X : ℚ)) / 2 := by
    intro f
    have : ∀ y : X, (if L f y = f y then (1 : ℚ) else 0)
        = ((if L f y = f y then (1 : ℚ) else -1) + 1) / 2 := by
      intro y; by_cases h : L f y = f y <;> simp [h]
    rw [Finset.sum_congr rfl (fun y _ => this y)]
    rw [← Finset.sum_div, Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul, mul_one]
  have hfun : (fun f : X → Bool => ∑ y : X, (if L f y = f y then (1 : ℚ) else 0))
      = fun f : X → Bool =>
          (1 / 2 : ℚ) * (∑ y : X, (if L f y = f y then (1 : ℚ) else -1))
            + (1 / 2 : ℚ) * (Fintype.card X : ℚ) := by
    funext f; rw [hpt f]; ring
  rw [hfun, E_add, E_smul, E_const, no_free_lunch_expected_score T L hL hT]
  ring

/-- **Sharpness.**  The requirement that the learner see only the training labels
is load-bearing: with an empty training set, the "learner" that copies the target
scores the maximum `|X|`, not `0`. -/
theorem training_dependence_is_necessary [Nonempty X] :
    ∃ L : (X → Bool) → (X → Bool),
      (∀ f : X → Bool, ∀ y ∈ (∅ : Finset X), L f y = f y)
      ∧ E (fun f : X → Bool => ∑ y : X, (if L f y = f y then (1 : ℚ) else -1))
          = (Fintype.card X : ℚ)
      ∧ ((∅ : Finset X).card : ℚ) ≠ (Fintype.card X : ℚ) := by
  refine ⟨id, by simp, ?_, ?_⟩
  · have : (fun f : X → Bool => ∑ _y : X, (1 : ℚ)) =
        fun _ : X → Bool => (Fintype.card X : ℚ) := by
      funext f; rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
    simp only [id_eq, if_pos]
    rw [this, E_const]
  · have : 0 < Fintype.card X := Fintype.card_pos
    simp only [Finset.card_empty, Nat.cast_zero]
    exact fun h => by
      have : (Fintype.card X : ℚ) = 0 := h.symm
      exact absurd (by exact_mod_cast this) (by omega)

/-! ## `k`-ary labels: the cyclic action -/

variable {k : ℕ} [NeZero k]

/-- Add the constant `t` to the label of the single point `x`. -/
def shiftBy (x : X) (t : ZMod k) (f : X → ZMod k) : X → ZMod k :=
  Function.update f x (f x + t)

omit [Fintype X] [NeZero k] in
@[simp] lemma shiftBy_apply_self (x : X) (t : ZMod k) (f : X → ZMod k) :
    shiftBy x t f x = f x + t := by simp [shiftBy]

omit [Fintype X] [NeZero k] in
lemma shiftBy_apply_ne {x y : X} (h : y ≠ x) (t : ZMod k) (f : X → ZMod k) :
    shiftBy x t f y = f y := by simp [shiftBy, Function.update_of_ne h]

omit [Fintype X] [NeZero k] in
lemma shiftBy_bijective (x : X) (t : ZMod k) :
    Function.Bijective (shiftBy (X := X) (k := k) x t) := by
  have hinv : ∀ f, shiftBy x (-t) (shiftBy x t f) = f := by
    intro f; funext y
    by_cases h : y = x
    · subst h; simp [shiftBy]
    · simp [shiftBy, Function.update_of_ne h]
  have hinv2 : ∀ f, shiftBy x t (shiftBy x (-t) f) = f := by
    intro f; funext y
    by_cases h : y = x
    · subst h; simp [shiftBy]
    · simp [shiftBy, Function.update_of_ne h]
  exact ⟨Function.LeftInverse.injective hinv, Function.RightInverse.surjective hinv2⟩

/-- Along a single orbit of the cyclic shift the fair-odds score cancels
exactly: one of the `k` shifts is a hit worth `k - 1`, the other `k - 1` are
misses worth `-1`. -/
lemma sum_orbit_kary (b c : ZMod k) :
    ∑ t : ZMod k, (if b = c + t then ((k : ℚ) - 1) else -1) = 0 := by
  have h : ∀ t : ZMod k, (if b = c + t then ((k : ℚ) - 1) else -1)
      = -1 + (if t = b - c then (k : ℚ) else 0) := by
    intro t
    by_cases h : t = b - c
    · subst h
      rw [if_pos (by ring), if_pos rfl]
      ring
    · have hne : ¬(b = c + t) := by
        intro hc; exact h (by rw [hc]; ring)
      rw [if_neg hne, if_neg h, add_zero]
  rw [Finset.sum_congr rfl (fun t _ => h t), Finset.sum_add_distrib, Finset.sum_const,
    Finset.sum_ite_eq' Finset.univ (b - c) (fun _ => (k : ℚ))]
  simp [ZMod.card k]

/-- **No-Free-Lunch for `k`-ary labels.**  At fair odds `(k-1) : 1`, an
off-training point has zero expected value for every learner that sees only the
training labels. -/
theorem sum_offTraining_kary_score_eq_zero (T : Finset X) (x : X) (hx : x ∉ T)
    (L : (X → ZMod k) → (X → ZMod k))
    (hL : ∀ f g : X → ZMod k, (∀ y ∈ T, f y = g y) → L f = L g) :
    ∑ f : X → ZMod k, (if L f x = f x then ((k : ℚ) - 1) else -1) = 0 := by
  classical
  set p : (X → ZMod k) → ℚ := fun f => if L f x = f x then ((k : ℚ) - 1) else -1 with hp
  have hshift : ∀ (t : ZMod k) (f : X → ZMod k),
      p (shiftBy x t f) = (if L f x = f x + t then ((k : ℚ) - 1) else -1) := by
    intro t f
    have hLe : L (shiftBy x t f) = L f := by
      refine hL _ _ ?_
      intro y hy
      refine shiftBy_apply_ne ?_ t f
      intro h; subst h; exact hx hy
    rw [hp]
    simp only [hLe, shiftBy_apply_self]
  have hcol : ∀ t : ZMod k, ∑ f : X → ZMod k, p (shiftBy x t f) = ∑ f : X → ZMod k, p f :=
    fun t => Fintype.sum_bijective (shiftBy x t) (shiftBy_bijective x t) _ _ (fun _ => rfl)
  have hk : ((k : ℚ)) ≠ 0 := by
    have : 0 < k := Nat.pos_of_ne_zero (NeZero.ne k)
    positivity
  have hmain : (k : ℚ) * (∑ f : X → ZMod k, p f) = 0 := by
    have h1 : ∑ _t : ZMod k, (∑ f : X → ZMod k, p f) = (k : ℚ) * ∑ f : X → ZMod k, p f := by
      rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, ZMod.card k]
    rw [← h1]
    rw [Finset.sum_congr rfl (fun t (_ : t ∈ (univ : Finset (ZMod k))) => (hcol t).symm)]
    rw [Finset.sum_comm]
    refine Finset.sum_eq_zero fun f _ => ?_
    rw [Finset.sum_congr rfl (fun t (_ : t ∈ (univ : Finset (ZMod k))) => hshift t f)]
    exact sum_orbit_kary (L f x) (f x)
  rcases mul_eq_zero.mp hmain with h | h
  · exact absurd h hk
  · exact h

/-- **No Free Lunch, `k`-ary deck form.**  A consistent learner over a `k`-letter
label alphabet has expected fair-odds score exactly `(k - 1) * |T|`: each of the
`|T|` resolved points pays the full `k - 1`, and the unresolved points pay
nothing on average. -/
theorem no_free_lunch_kary_expected_score (T : Finset X) (L : (X → ZMod k) → (X → ZMod k))
    (hL : ∀ f g : X → ZMod k, (∀ y ∈ T, f y = g y) → L f = L g)
    (hT : ∀ f : X → ZMod k, ∀ y ∈ T, L f y = f y) :
    E (fun f : X → ZMod k => ∑ y : X, (if L f y = f y then ((k : ℚ) - 1) else -1))
      = ((k : ℚ) - 1) * (T.card : ℚ) := by
  have hres : ∀ y ∈ T,
      Resolved (fun f : X → ZMod k => if L f y = f y then ((k : ℚ) - 1) else -1) ((k : ℚ) - 1) := by
    intro y hy f
    exact if_pos (hT f y hy)
  have hfair : ∀ y ∉ T,
      Fair (fun f : X → ZMod k => if L f y = f y then ((k : ℚ) - 1) else -1) := by
    intro y hy
    rw [Fair, E_def, sum_offTraining_kary_score_eq_zero T y hy L hL, zero_div]
  have := expected_total_eq_certain_sum (Ω := X → ZMod k)
    (fun y f => if L f y = f y then ((k : ℚ) - 1) else -1) T (fun _ => (k : ℚ) - 1) hres hfair
  rw [this, Finset.sum_const, nsmul_eq_mul]
  ring

end KnownUnresolvedCards