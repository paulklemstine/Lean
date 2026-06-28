/-
# The contragredient sign `(-1)^{b(F,n)}` and its dependence on `n mod 4`

This file analyses the **explicit integer sign** appearing in the Betti–Whittaker contragredient
period relation for `GL(n)` over a number field `F` with `r₁` real and `r₂` complex places
(see `NumberTheory/BettiWhittakerContragredientFormal.lean` for the structural period statement):

  `p^b(π∨) = (-1)^{b(F,n)} · p^b(π)`,    where    `b(F,n) = r₁·⌊n²/4⌋ + r₂·n(n-1)/2`.

That companion file states the relation with an abstract quadratic character `ε(disc k)^{b(F,n)}`.
Here we compute the *concrete* sign `(-1)^{b(F,n)}` and prove that it depends on `n`
**only through `n mod 4`**:

* `n ≡ 0, 1 (mod 4)` : the sign is `+1` for **every** number field — the period is
  contragredient-invariant;
* `n ≡ 3 (mod 4)`    : the sign is `(-1)^{r₂}`, depending **only on the number of complex
  places** (the real places drop out);
* `n ≡ 2 (mod 4)`    : the sign is `(-1)^{r₁ + r₂}`.

The mechanism is two parity laws:
  `⌊n²/4⌋` is odd  ⟺  `n ≡ 2 (mod 4)`,
  `n(n-1)/2` is odd ⟺  `n ≡ 2` or `3 (mod 4)`.

This file is self-contained (`import Mathlib`): it re-introduces the bottom degree `bDeg` of the
companion catalog file inside the dedicated namespace `BettiWhittaker.Sign`, and builds the new
sign theory on top of it.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the sign `(-1)^{b(F,n)}` cannot be arbitrary; the floor and triangular
contributions are each periodic mod 4, so the whole sign should be a function of
`(n mod 4, r₁ mod 2, r₂ mod 2)`.  Surprising sub-claim: for `n ≡ 3 (mod 4)` the real places `r₁`
make *no* contribution to the sign.

Experiment (Experimenter): computed `⌊n²/4⌋ mod 2` and `T_{n-1} = n(n-1)/2 mod 2` for `n = 0..11`:
  ⌊n²/4⌋   : 0 0 1 2 4 6 9 12 16 20 25 30  → parity 0 0 1 0 0 0 1 0 0 0 1 0   (odd ⟺ n≡2 mod 4)
  n(n-1)/2 : 0 0 1 3 6 10 15 21 28 36 45 55 → parity 0 0 1 1 0 0  1  1 0 0  1  1 (odd ⟺ n≡2,3 mod 4)
Both confirmed period-4.  Proved both with a `n = 4q+r` decomposition + `interval_cases r`.

Analysis (Analyst): the `n ≡ 3` case is genuinely asymmetric — `⌊n²/4⌋` is even but `T_{n-1}` is
odd, so `b(F,n) ≡ r₂ (mod 2)` and `r₁` cancels.  This asymmetry is invisible from the abstract
`ε(disc)^{b}` statement; it requires the parity computation done here.

Critique (Critic): is the `n ≡ 0,1` invariance vacuous?  No — it holds for ALL fields and strictly
strengthens the period relation by removing the discriminant character entirely.  Adversarial
counterexample hunt: every `(n,r₁,r₂)` with `n ≤ 40, r₁,r₂ ≤ 6` satisfies the characterization
(checked computationally before formalizing); `contraSign_indep_of_real_places_mod4_eq3` records
the most counterintuitive consequence as a theorem rather than a claim.

Synthesis (PI): the boundary is `n mod 4`.  The clean trichotomy is packaged in `contraSign_*`
below, with `contraSign_sq` certifying these are honest square roots of unity.
-/
import Mathlib

open scoped BigOperators

namespace BettiWhittaker.Sign

/-! ## The bottom cohomological degree -/

/-- The **bottom (cohomological) degree** `b(F,n) = r₁·⌊n²/4⌋ + r₂·n(n-1)/2` of the locally
symmetric space of `GL(n)` over a number field with `r₁` real and `r₂` complex places, written in
integer-floor form. -/
def bDeg (n r₁ r₂ : ℕ) : ℕ :=
  r₁ * (n / 2) * ((n + 1) / 2) + r₂ * n * (n - 1) / 2

/-- Closed form for the real contribution: `⌊n²/4⌋ = (n/2)·((n+1)/2)`. -/
theorem floor_sq_div_four (n : ℕ) : n ^ 2 / 4 = (n / 2) * ((n + 1) / 2) := by
  rcases Nat.even_or_odd' n with ⟨k, rfl | rfl⟩
  · rw [show (2 * k) ^ 2 = 4 * (k * k) by ring, Nat.mul_div_cancel_left _ (by norm_num),
      Nat.mul_div_cancel_left _ (by norm_num), show (2 * k + 1) / 2 = k by omega]
  · rw [show (2 * k + 1) ^ 2 = 4 * (k * k + k) + 1 by ring, show (2 * k + 1) / 2 = k by omega,
      show 2 * k + 1 + 1 = 2 * (k + 1) by ring, Nat.mul_div_cancel_left _ (by norm_num),
      show k * (k + 1) = k * k + k by ring]
    omega

/-- `b(F,n)` written as `r₁·⌊n²/4⌋ + r₂·(n(n-1)/2)`, separating the two place contributions. -/
theorem bDeg_eq_floor_tri (n r₁ r₂ : ℕ) :
    bDeg n r₁ r₂ = r₁ * (n ^ 2 / 4) + r₂ * (n * (n - 1) / 2) := by
  rw [bDeg]; congr 1
  · rw [mul_assoc, ← floor_sq_div_four]
  · rw [mul_assoc, Nat.mul_div_assoc r₂ (Nat.even_mul_pred_self n).two_dvd]

/-! ## Parity of the two contributions -/

/-- The real (floor) contribution `⌊n²/4⌋` is odd **iff** `n ≡ 2 (mod 4)`. -/
theorem floorSq_odd_iff (n : ℕ) : (n ^ 2 / 4) % 2 = 1 ↔ n % 4 = 2 := by
  obtain ⟨q, r, hr, rfl⟩ : ∃ q r, r < 4 ∧ n = 4 * q + r :=
    ⟨n / 4, n % 4, Nat.mod_lt _ (by norm_num), by omega⟩
  have hsq : (4 * q + r) ^ 2 = 16 * (q * q) + 8 * (q * r) + r * r := by ring
  interval_cases r <;> simp only [hsq] <;> omega

/-- The complex (triangular) contribution `n(n-1)/2` is odd **iff** `n ≡ 2` or `3 (mod 4)`. -/
theorem triangular_odd_iff (n : ℕ) :
    (n * (n - 1) / 2) % 2 = 1 ↔ (n % 4 = 2 ∨ n % 4 = 3) := by
  obtain ⟨q, r, hr, rfl⟩ : ∃ q r, r < 4 ∧ n = 4 * q + r :=
    ⟨n / 4, n % 4, Nat.mod_lt _ (by norm_num), by omega⟩
  have divcancel : ∀ a b : ℕ, (4 * a) * b / 2 = 2 * (a * b) := by
    intro a b
    rw [show (4 * a) * b = 2 * (2 * (a * b)) by ring, Nat.mul_div_cancel_left _ (by norm_num)]
  have divcancel2 : ∀ a b : ℕ, (2 * a) * b / 2 = a * b := by
    intro a b
    rw [show (2 * a) * b = 2 * (a * b) by ring, Nat.mul_div_cancel_left _ (by norm_num)]
  interval_cases r
  · have h : (4 * q + 0) * (4 * q + 0 - 1) / 2 = 2 * (q * (4 * q - 1)) := by
      rw [show (4 * q + 0) * (4 * q + 0 - 1) = (4 * q) * (4 * q - 1) by ring_nf, divcancel]
    rw [h]; constructor
    · intro hh; simp at hh
    · intro hh; omega
  · have e1 : 4 * q + 1 - 1 = 4 * q := by omega
    have h : (4 * q + 1) * (4 * q + 1 - 1) / 2 = 2 * (q * (4 * q + 1)) := by
      rw [e1, show (4 * q + 1) * (4 * q) = (4 * q) * (4 * q + 1) by ring, divcancel]
    rw [h]; constructor
    · intro hh; simp at hh
    · intro hh; omega
  · have e1 : 4 * q + 2 - 1 = 4 * q + 1 := by omega
    have h : (4 * q + 2) * (4 * q + 2 - 1) / 2 = (2 * q + 1) * (4 * q + 1) := by
      rw [e1, show (4 * q + 2) * (4 * q + 1) = (2 * (2 * q + 1)) * (4 * q + 1) by ring, divcancel2]
    rw [h]; refine ⟨fun _ => Or.inl (by omega), fun _ => ?_⟩
    have ha : (2 * q + 1) % 2 = 1 := by omega
    have hb : (4 * q + 1) % 2 = 1 := by omega
    simp [Nat.mul_mod, ha, hb]
  · have e1 : 4 * q + 3 - 1 = 4 * q + 2 := by omega
    have h : (4 * q + 3) * (4 * q + 3 - 1) / 2 = (4 * q + 3) * (2 * q + 1) := by
      rw [e1, show (4 * q + 3) * (4 * q + 2) = 2 * ((4 * q + 3) * (2 * q + 1)) by ring,
        Nat.mul_div_cancel_left _ (by norm_num)]
    rw [h]; refine ⟨fun _ => Or.inr (by omega), fun _ => ?_⟩
    have ha : (4 * q + 3) % 2 = 1 := by omega
    have hb : (2 * q + 1) % 2 = 1 := by omega
    simp [Nat.mul_mod, ha, hb]

/-! ## Parity of the bottom degree `b(F,n)` -/

/-- `n ≡ 0` or `1 (mod 4)` forces `b(F,n)` to be **even** — for every field. -/
theorem bDeg_even_of_mod4_lt2 (n r₁ r₂ : ℕ) (h : n % 4 = 0 ∨ n % 4 = 1) :
    Even (bDeg n r₁ r₂) := by
  have hA : (n ^ 2 / 4) % 2 = 0 := by have := floorSq_odd_iff n; omega
  have hB : (n * (n - 1) / 2) % 2 = 0 := by have := triangular_odd_iff n; omega
  rw [Nat.even_iff, bDeg_eq_floor_tri, Nat.add_mod, Nat.mul_mod, Nat.mul_mod r₂, hA, hB]; simp

/-- For `n ≡ 2 (mod 4)`: `b(F,n) ≡ r₁ + r₂ (mod 2)`. -/
theorem bDeg_mod_two_of_mod4_eq2 (n r₁ r₂ : ℕ) (h : n % 4 = 2) :
    bDeg n r₁ r₂ % 2 = (r₁ + r₂) % 2 := by
  have hA : (n ^ 2 / 4) % 2 = 1 := (floorSq_odd_iff n).mpr h
  have hB : (n * (n - 1) / 2) % 2 = 1 := (triangular_odd_iff n).mpr (Or.inl h)
  rw [bDeg_eq_floor_tri, Nat.add_mod, Nat.mul_mod, Nat.mul_mod r₂, hA, hB, Nat.add_mod r₁ r₂]
  simp

/-- For `n ≡ 3 (mod 4)`: `b(F,n) ≡ r₂ (mod 2)` — the real places `r₁` **drop out**. -/
theorem bDeg_mod_two_of_mod4_eq3 (n r₁ r₂ : ℕ) (h : n % 4 = 3) :
    bDeg n r₁ r₂ % 2 = r₂ % 2 := by
  have hA : (n ^ 2 / 4) % 2 = 0 := by have := floorSq_odd_iff n; omega
  have hB : (n * (n - 1) / 2) % 2 = 1 := (triangular_odd_iff n).mpr (Or.inr h)
  rw [bDeg_eq_floor_tri, Nat.add_mod, Nat.mul_mod, Nat.mul_mod r₂, hA, hB]; simp

/-! ## The concrete contragredient sign `(-1)^{b(F,n)}` -/

/-- The **contragredient period sign** `(-1)^{b(F,n)} ∈ {±1} ⊂ ℤ`, the explicit constant in the
title formula `p^b(π∨) = (-1)^{b(F,n)} · p^b(π)`. -/
def contraSign (n r₁ r₂ : ℕ) : ℤ := (-1) ^ bDeg n r₁ r₂

/-- Powers of `-1` agree whenever the exponents agree mod `2`. -/
theorem negOnePow_congr {a b : ℕ} (h : a % 2 = b % 2) : (-1 : ℤ) ^ a = (-1) ^ b := by
  rcases Nat.even_or_odd a with ha | ha
  · have hb : Even b := by rw [Nat.even_iff] at ha ⊢; omega
    rw [ha.neg_one_pow, hb.neg_one_pow]
  · have hb : Odd b := by rw [Nat.odd_iff] at ha ⊢; omega
    rw [ha.neg_one_pow, hb.neg_one_pow]

/-- The sign is genuinely a square root of unity. -/
theorem contraSign_sq (n r₁ r₂ : ℕ) : contraSign n r₁ r₂ ^ 2 = 1 := by
  rw [contraSign, ← pow_mul, mul_comm, pow_mul]; simp

/-- **`n ≡ 0` or `1 (mod 4)`: the sign is `+1` for every number field.**  The Betti–Whittaker
period is contragredient-invariant in these degrees, for all `r₁, r₂`. -/
theorem contraSign_eq_one_of_mod4_lt2 (n r₁ r₂ : ℕ) (h : n % 4 = 0 ∨ n % 4 = 1) :
    contraSign n r₁ r₂ = 1 := by
  rw [contraSign, (bDeg_even_of_mod4_lt2 n r₁ r₂ h).neg_one_pow]

/-- **`n ≡ 2 (mod 4)`: the sign is `(-1)^{r₁ + r₂}`.** -/
theorem contraSign_of_mod4_eq2 (n r₁ r₂ : ℕ) (h : n % 4 = 2) :
    contraSign n r₁ r₂ = (-1) ^ (r₁ + r₂) :=
  negOnePow_congr (bDeg_mod_two_of_mod4_eq2 n r₁ r₂ h)

/-- **`n ≡ 3 (mod 4)`: the sign is `(-1)^{r₂}` — independent of the number of real places.** -/
theorem contraSign_of_mod4_eq3 (n r₁ r₂ : ℕ) (h : n % 4 = 3) :
    contraSign n r₁ r₂ = (-1) ^ r₂ :=
  negOnePow_congr (bDeg_mod_two_of_mod4_eq3 n r₁ r₂ h)

/-- **The real places are irrelevant when `n ≡ 3 (mod 4)`**: changing `r₁` does not change the
sign.  This is the counterintuitive asymmetry highlighted in the Lab Notes. -/
theorem contraSign_indep_of_real_places_mod4_eq3 (n r₁ r₁' r₂ : ℕ) (h : n % 4 = 3) :
    contraSign n r₁ r₂ = contraSign n r₁' r₂ := by
  rw [contraSign_of_mod4_eq3 n r₁ r₂ h, contraSign_of_mod4_eq3 n r₁' r₂ h]

/-- Over a **totally real** field (`r₂ = 0`) with `n ≡ 3 (mod 4)`, the sign is always `+1`. -/
theorem contraSign_totallyReal_mod4_eq3 (n r₁ : ℕ) (h : n % 4 = 3) :
    contraSign n r₁ 0 = 1 := by
  rw [contraSign_of_mod4_eq3 n r₁ 0 h, pow_zero]

end BettiWhittaker.Sign