import Mathlib
import Algebra.QubitTrade.SupportCollapse

/-!
# QUBIT-TRADE V: the capacity of a truncated register, and divisor ambiguity

Two sharper facts about the truncated outcome map `k ↦ ⌊2^t k / r⌋`.

## Capacity

`QubitTrade.card_outcomeFinset` computes the exact number of distinct records a
`t`-bit register can emit at order `r`:

  `#{⌊2^t k / r⌋ : k < r} = min (2^t) r`.

Below the collapse threshold (`2^t ≤ r`) the register is saturated and the answer
`2^t` does not depend on `r` at all — one sample carries `min (t, log₂ r)` bits
about the phase, never more.  Above it the map is injective and the register sees
the full order.

## Divisor ambiguity — an obstruction at *every* register size

`QubitTrade.outcomes_subset_of_dvd`: if `r ∣ r'` (and `r' > 0`) then every record achievable at
order `r` is achievable at order `r'`, *for every `t`*, because `k/r = (sk)/(sr)`
exactly.  Consequently (`QubitTrade.no_support_only_estimator`) no estimator that
reads only which outcomes occurred — as opposed to how often — can distinguish
`r` from any proper multiple of it.  This is the support-level shadow of the
`gcd (k, r) > 1` obstruction repaired, statistically, in `SampleFungibility.lean`:
adding qubits never removes it; only the *frequencies* of the samples do.
-/

namespace QubitTrade

/-- The record alphabet actually realised at order `r`, as a `Finset`. -/
def outcomeFinset (t r : ℕ) : Finset ℕ := (Finset.range r).image (truncOutcome t r)

theorem mem_outcomeFinset {t r m : ℕ} :
    m ∈ outcomeFinset t r ↔ ∃ k < r, truncOutcome t r k = m := by
  simp [outcomeFinset, Finset.mem_image, Finset.mem_range]

/-- Above the collapse threshold the outcome map separates all numerators. -/
theorem truncOutcome_injOn {t r : ℕ} (h : r ≤ 2 ^ t) (hr : 0 < r) :
    Set.InjOn (truncOutcome t r) (Set.Iio r) := by
  have mono : ∀ k k' : ℕ, k < k' → truncOutcome t r k < truncOutcome t r k' := by
    intro k k' hkk
    unfold truncOutcome
    have h1 : 2 ^ t * k + r ≤ 2 ^ t * k' := by
      have : 2 ^ t * (k + 1) ≤ 2 ^ t * k' := Nat.mul_le_mul_left _ hkk
      have hexp : 2 ^ t * (k + 1) = 2 ^ t * k + 2 ^ t := by ring
      omega
    have h2 : (2 ^ t * k + r) / r = 2 ^ t * k / r + 1 := Nat.add_div_right _ hr
    calc 2 ^ t * k / r < 2 ^ t * k / r + 1 := Nat.lt_succ_self _
      _ = (2 ^ t * k + r) / r := h2.symm
      _ ≤ 2 ^ t * k' / r := Nat.div_le_div_right h1
  intro a _ b _ hab
  by_contra hne
  rcases Nat.lt_or_ge a b with h' | h'
  · exact absurd hab (mono a b h').ne
  · have : b < a := lt_of_le_of_ne h' (Ne.symm hne)
    exact absurd hab (mono b a this).ne'

/-- **Capacity of a truncated register.**  The number of distinct outcomes at
order `r` is exactly `min (2^t) r`: the register is saturated below the collapse
threshold and faithful above it. -/
theorem card_outcomeFinset {t r : ℕ} (hr : 0 < r) :
    (outcomeFinset t r).card = min (2 ^ t) r := by
  rcases le_or_gt (2 ^ t) r with h | h
  · -- saturated: the image is the whole alphabet
    have himg : outcomeFinset t r = Finset.range (2 ^ t) := by
      ext m
      rw [mem_outcomeFinset, Finset.mem_range]
      constructor
      · rintro ⟨k, hk, rfl⟩
        exact truncOutcome_lt hk
      · intro hm
        exact truncOutcome_surjective h hm
    rw [himg, Finset.card_range, min_eq_left h]
  · -- faithful: the map is injective on `range r`
    have hinj : Set.InjOn (truncOutcome t r) (Finset.range r : Finset ℕ) := by
      intro a ha b hb hab
      simp only [Finset.coe_range, Set.mem_Iio] at ha hb
      exact truncOutcome_injOn (le_of_lt h) hr ha hb hab
    rw [outcomeFinset, Finset.card_image_of_injOn hinj, Finset.card_range,
      min_eq_right (le_of_lt h)]

/-- The saturated regime, restated: below the collapse threshold the *capacity*
`min (2^t) r` equals `2^t` and is independent of the order. -/
theorem capacity_saturated {t r : ℕ} (h : 2 ^ t ≤ r) (hr : 0 < r) :
    (outcomeFinset t r).card = 2 ^ t := by
  rw [card_outcomeFinset hr, min_eq_left h]

/-! ## Divisor ambiguity, at every register size -/

/-- **Multiples swallow their divisors.**  If `r ∣ r'` then every record of order
`r` also occurs at order `r'`, at *every* register size `t`. -/
theorem outcomes_subset_of_dvd {t r r' : ℕ} (hr' : 0 < r') (hdvd : r ∣ r') :
    outcomes t r ⊆ outcomes t r' := by
  obtain ⟨s, rfl⟩ := hdvd
  rintro m ⟨k, hk, rfl⟩
  have hs : 0 < s := by
    rcases Nat.eq_zero_or_pos s with rfl | hs
    · simp at hr'
    · exact hs
  refine ⟨s * k, ?_, ?_⟩
  · calc s * k < s * r := (Nat.mul_lt_mul_left hs).mpr hk
      _ = r * s := mul_comm s r
  · unfold truncOutcome
    rw [show 2 ^ t * (s * k) = (2 ^ t * k) * s by ring, Nat.mul_div_mul_right _ _ hs]

/-- **No support-only estimator exists.**  An estimator that sees only *which*
outcomes occurred cannot distinguish an order `r` from a proper multiple `r * s`,
no matter how many qubits `t` it is given and how many samples it collects. -/
theorem no_support_only_estimator {t r s : ℕ} (hr : 0 < r) (hs : 1 < s)
    (A : List ℕ → ℕ) :
    ¬ ((∀ L : List ℕ, (∀ m ∈ L, m ∈ outcomes t r) → A L = r) ∧
       (∀ L : List ℕ, (∀ m ∈ L, m ∈ outcomes t (r * s)) → A L = r * s)) := by
  rintro ⟨hA, hA'⟩
  have hsub : outcomes t r ⊆ outcomes t (r * s) :=
    outcomes_subset_of_dvd (Nat.mul_pos hr (by omega)) ⟨s, rfl⟩
  set L : List ℕ := [truncOutcome t r 0] with hL
  have hLr : ∀ m ∈ L, m ∈ outcomes t r := by
    intro m hm
    simp only [hL, List.mem_singleton] at hm
    subst hm
    exact ⟨0, hr, rfl⟩
  have hLr' : ∀ m ∈ L, m ∈ outcomes t (r * s) := fun m hm => hsub (hLr m hm)
  have h1 := hA L hLr
  have h2 := hA' L hLr'
  have : r = r * s := h1.symm.trans h2
  nlinarith

end QubitTrade