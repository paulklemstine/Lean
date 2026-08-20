import Mathlib
import Catalog.NumberTheory.Basic

/-!
# Classification of twists, and the sharp additive obstruction

`Mobius.MInt.no_separable_lift_of_add` (in `DoubleCover.lean`) showed that the
addition of Möbius integers cannot be computed on the cover `ℤ × {±1}` by a pair
of maps, one on magnitudes and one on orientations, whereas multiplication can
(`Mobius.MInt.mul_lifts_to_cover`).  Conjecture 2 of `FUTURE_DIRECTIONS.md`
asked how far this goes.  This file settles two forms of the question.

**1. Which twists exist at all?**  A `ℤ/k`-twist of `ℤ` is an additive
symmetry `ρ : ℤ →+ ℤ` of finite order `k` used as the deck transformation of the
magnitude coordinate.  `Mobius.twist_classification` proves that the only
possibilities are `ρ = id` (no twist) and `ρ = −id` with `k` even (the Möbius
twist): **the Möbius band is the unique nontrivial finite twist of the
integers**, and in particular there is no `ℤ/k`-Möbius arithmetic for odd
`k ≥ 3` (`Mobius.no_odd_twist`).

**2. How strong is the additive obstruction?**  `Mobius.SeparableLift`
formalises "computable separately on magnitudes and orientations" for an
arbitrary binary operation, and `Mobius.SeparableLift.abs_left`/`abs_right`
give a *criterion*: the absolute value of the operation must be invariant under
flipping either argument.  This immediately rules out addition, subtraction and
many other operations (`Mobius.not_separableLift_add`,
`Mobius.not_separableLift_sub`, `Mobius.not_separableLift_add_sq`), while
multiplication passes (`Mobius.separableLift_mul`).  The criterion is *not*
sufficient: `Mobius.abs_criterion_not_sufficient` exhibits an operation with a
completely orientation-blind absolute value that still fails to lift, so the
real obstruction is carried by signs.  Finally
`Mobius.MInt.no_magnitude_lift_of_add` strengthens the original obstruction: even
if the *orientation* of the sum is allowed to depend on everything, its
*magnitude* can never be computed from the two magnitudes alone.
-/

namespace Mobius

/-! ### Classification of finite twists of `ℤ` -/

theorem addHom_apply_eq (ρ : ℤ →+ ℤ) (n : ℤ) : ρ n = ρ 1 * n := by
  have h := map_zsmul ρ n (1 : ℤ)
  simpa [mul_comm] using h

theorem addHom_iterate (ρ : ℤ →+ ℤ) (k : ℕ) (n : ℤ) : ρ^[k] n = (ρ 1) ^ k * n := by
  induction k generalizing n with
  | zero => simp
  | succ m ih =>
    rw [Function.iterate_succ_apply, ih, addHom_apply_eq ρ n]
    ring

/-- **Classification of finite twists.**  If an additive symmetry of the
magnitude line has order dividing `k > 0`, it is either the identity or
negation, and negation only occurs for even `k`.  The Möbius twist `n ↦ −n`
(order two) is therefore the *only* nontrivial finite twist of `ℤ`. -/
theorem twist_classification (ρ : ℤ →+ ℤ) (k : ℕ) (hk : 0 < k) (h : ρ^[k] = id) :
    (∀ n, ρ n = n) ∨ ((∀ n, ρ n = -n) ∧ Even k) := by
  set c := ρ 1 with hc
  have hck : c ^ k = 1 := by
    have := congrFun h 1
    rw [addHom_iterate ρ k 1, mul_one] at this
    exact this
  obtain ⟨m, rfl⟩ : ∃ m, k = m + 1 := ⟨k - 1, by omega⟩
  have hunit : IsUnit c := by
    refine IsUnit.of_mul_eq_one (c ^ m) ?_
    rw [← pow_succ']
    exact hck
  rcases Int.isUnit_iff.1 hunit with h1 | h1
  · left
    intro n
    rw [addHom_apply_eq ρ n, ← hc, h1, one_mul]
  · right
    refine ⟨fun n => by rw [addHom_apply_eq ρ n, ← hc, h1]; ring, ?_⟩
    rw [h1] at hck
    by_contra hodd
    rw [Nat.not_even_iff_odd] at hodd
    rw [hodd.neg_one_pow] at hck
    norm_num at hck

/-- There is no genuine `ℤ/k`-Möbius twist of the integers for odd `k`: any
additive symmetry of odd finite order is the identity. -/
theorem no_odd_twist (ρ : ℤ →+ ℤ) (k : ℕ) (hk : 0 < k) (hodd : Odd k)
    (h : ρ^[k] = id) : ∀ n, ρ n = n := by
  rcases twist_classification ρ k hk h with h1 | ⟨-, heven⟩
  · exact h1
  · exact absurd heven (Nat.not_even_iff_odd.2 hodd)

/-- The Möbius deck transformation really is a twist of order two, and the
classification says it is the only one. -/
theorem deck_is_the_twist : (fun n : ℤ => -n)^[2] = id := by
  funext n
  simp

/-! ### Which binary operations lift separately to the cover? -/

/-- An operation `F` on values *lifts separably* to the oriented cover if its
magnitude can be computed from the two magnitudes and its orientation from the
two orientations. -/
def SeparableLift (F : ℤ → ℤ → ℤ) : Prop :=
  ∃ (g : ℤ → ℤ → ℤ) (h : Bool → Bool → Bool),
    ∀ a b : Oriented, value (g a.1 b.1, h a.2 b.2) = F (value a) (value b)

theorem abs_value (n : ℤ) (e : Bool) : |value (n, e)| = |n| := by
  cases e <;> simp [value]

/-- **Criterion, left argument.**  A separably liftable operation has an
absolute value that is blind to the orientation of its first argument. -/
theorem SeparableLift.abs_left {F : ℤ → ℤ → ℤ} (hF : SeparableLift F) (m n : ℤ) :
    |F (-m) n| = |F m n| := by
  obtain ⟨g, h, hgh⟩ := hF
  have h1 : value (g m n, h true true) = F m n := hgh (m, true) (n, true)
  have h2 : value (g m n, h false true) = F (-m) n := hgh (m, false) (n, true)
  rw [← h1, ← h2, abs_value, abs_value]

/-- **Criterion, right argument.** -/
theorem SeparableLift.abs_right {F : ℤ → ℤ → ℤ} (hF : SeparableLift F) (m n : ℤ) :
    |F m (-n)| = |F m n| := by
  obtain ⟨g, h, hgh⟩ := hF
  have h1 : value (g m n, h true true) = F m n := hgh (m, true) (n, true)
  have h2 : value (g m n, h true false) = F m (-n) := hgh (m, true) (n, false)
  rw [← h1, ← h2, abs_value, abs_value]

/-- Multiplication lifts separably: this is the positive half of the
dichotomy. -/
theorem separableLift_mul : SeparableLift (fun m n => m * n) := by
  refine ⟨fun m n => m * n, fun e f => e == f, ?_⟩
  rintro ⟨m, e⟩ ⟨n, f⟩
  cases e <;> cases f <;> simp [value]

/-- Addition does not lift separably. -/
theorem not_separableLift_add : ¬ SeparableLift (fun m n => m + n) := by
  intro hF
  have h := hF.abs_left 1 1
  norm_num at h

/-- Neither does subtraction. -/
theorem not_separableLift_sub : ¬ SeparableLift (fun m n => m - n) := by
  intro hF
  have h := hF.abs_right 1 1
  norm_num at h

/-- Nor any operation mixing a linear and a quadratic term, such as
`(m, n) ↦ m + n²`: the criterion is a genuine tool, not a one-off computation. -/
theorem not_separableLift_add_sq : ¬ SeparableLift (fun m n => m + n ^ 2) := by
  intro hF
  have h := hF.abs_left 1 1
  norm_num at h

/-- Translation-type operations fail as well: `(m, n) ↦ m + 1` mixes strata. -/
theorem not_separableLift_succ : ¬ SeparableLift (fun m _ => m + 1) := by
  intro hF
  have h := hF.abs_left 1 0
  norm_num at h

/-! ### The absolute-value criterion is necessary but not sufficient -/

/-- A parity-twisted product: multiplicative in absolute value, but its sign
depends on the *magnitude* of the first argument, not only on orientations. -/
def parityTwist (m n : ℤ) : ℤ := if 2 ∣ m then m * n else |m * n|

theorem parityTwist_abs_left (m n : ℤ) : |parityTwist (-m) n| = |parityTwist m n| := by
  unfold parityTwist
  by_cases h : (2:ℤ) ∣ m
  · rw [if_pos h, if_pos ((dvd_neg).2 h)]
    simp [abs_mul]
  · rw [if_neg h, if_neg (fun hc => h ((dvd_neg).1 hc))]
    simp [abs_mul]

theorem parityTwist_abs_right (m n : ℤ) : |parityTwist m (-n)| = |parityTwist m n| := by
  unfold parityTwist
  by_cases h : (2:ℤ) ∣ m <;> simp [h, abs_mul]

/-- `parityTwist` nevertheless has **no** separable lift: the obstruction is a
sign cocycle, not a magnitude condition. -/
theorem not_separableLift_parityTwist : ¬ SeparableLift parityTwist := by
  rintro ⟨g, h, hgh⟩
  have h1 : value (g 1 1, h true true) = 1 := by
    have := hgh (1, true) (1, true)
    simpa [parityTwist, value] using this
  have h2 : value (g 1 1, h false true) = 1 := by
    have := hgh (1, false) (1, true)
    simpa [parityTwist, value] using this
  have h3 : value (g 2 1, h true true) = 2 := by
    have := hgh (2, true) (1, true)
    simpa [parityTwist, value] using this
  have h4 : value (g 2 1, h false true) = -2 := by
    have := hgh (2, false) (1, true)
    norm_num [parityTwist, value] at this ⊢
    omega
  cases ha : h true true <;> cases hb : h false true <;>
    rw [ha] at h1 h3 <;> rw [hb] at h2 h4 <;> simp [value] at h1 h2 h3 h4 <;> omega

/-- **Sharpness of the criterion.**  There is an operation whose absolute value
is completely blind to both orientations — so it satisfies the necessary
conditions `SeparableLift.abs_left` and `SeparableLift.abs_right` — and which
still admits no separable lift. -/
theorem abs_criterion_not_sufficient :
    (∀ m n : ℤ, |parityTwist (-m) n| = |parityTwist m n|) ∧
      (∀ m n : ℤ, |parityTwist m (-n)| = |parityTwist m n|) ∧
      ¬ SeparableLift parityTwist :=
  ⟨parityTwist_abs_left, parityTwist_abs_right, not_separableLift_parityTwist⟩

namespace MInt

/-- **Sharp obstruction theorem.**  Even allowing the orientation of the sum to
be an arbitrary function of *both complete* oriented inputs, the magnitude of a
Möbius sum can never be computed from the two magnitudes alone.  This strictly
strengthens `Mobius.MInt.no_separable_lift_of_add`, in which the orientation was
also required to be separable. -/
theorem no_magnitude_lift_of_add :
    ¬ ∃ (g : ℤ → ℤ → ℤ) (h : Oriented → Oriented → Bool),
        ∀ a b : Oriented, mk (g a.1 b.1, h a b) = mk a + mk b := by
  rintro ⟨g, h, hgh⟩
  have h1 := congrArg toZ (hgh (1, true) (1, true))
  have h2 := congrArg toZ (hgh (1, true) (1, false))
  simp only [toZ_mk, toZ_add] at h1 h2
  have a1 : |g 1 1| = 2 := by
    rw [← abs_value (g 1 1) (h (1, true) (1, true)), h1]
    norm_num [value]
  have a2 : |g 1 1| = 0 := by
    rw [← abs_value (g 1 1) (h (1, true) (1, false)), h2]
    norm_num [value]
  omega

end MInt
end Mobius