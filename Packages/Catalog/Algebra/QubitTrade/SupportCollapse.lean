import Mathlib
import Algebra.QubitTrade.Resolution

/-!
# QUBIT-TRADE II: classical collapse of a truncated register

A `t`-bit truncated phase register reports, for an order-`r` Shor sample with
numerator `k`, the integer

  `truncOutcome t r k = ⌊2^t · k / r⌋ = (2^t * k) / r`  (natural division).

This file proves the **collapse** half of the experiment: once `2^t ≤ r`, the
outcome map is *onto* the whole outcome alphabet `{0, …, 2^t - 1}`, so the set of
observable records is `{0, …, 2^t-1}` **independently of `r`**.  Consequently:

* `QubitTrade.truncOutcome_surjective` — surjectivity onto the alphabet;
* `QubitTrade.outcomes_eq_alphabet` — the outcome set does not depend on `r`;
* `QubitTrade.outcome_lists_coincide` — every *record* (list of samples, of any
  length) achievable at order `r` is achievable at order `r'`;
* `QubitTrade.samples_do_not_help` — hence **no** estimator, with **any** number
  of samples, can be correct for two distinct orders `r, r' ≥ 2^t`;
* `QubitTrade.collapse_cardinality` — the collapse is massive: all
  `R - 2^t + 1` orders in `[2^t, R]` share one and the same outcome set.

This is the sample-independent lower bound `t > log₂ r`.  It is strictly weaker
than the resolution threshold `t ≈ 2 log₂ r` of `Resolution.lean`, and the two
together bracket the measured `t_min`.
-/

namespace QubitTrade

/-- The outcome of a `t`-bit truncated register on the exact phase `k / r`. -/
def truncOutcome (t r k : ℕ) : ℕ := 2 ^ t * k / r

/-- The truncated outcome really is the floor of `2^t` times the order fraction. -/
theorem truncOutcome_eq_floor (t r k : ℕ) :
    truncOutcome t r k = ⌊(2 ^ t : ℝ) * ((orderFrac k r : ℚ) : ℝ)⌋₊ := by
  unfold truncOutcome orderFrac
  rw [show ((2:ℝ) ^ t * (((k : ℚ) / (r : ℚ) : ℚ) : ℝ)) = ((2 ^ t * k : ℕ) : ℝ) / (r : ℕ) by
    push_cast; ring]
  exact (Nat.floor_div_eq_div (2 ^ t * k) r).symm

/-- Outcomes live in the `t`-bit alphabet. -/
theorem truncOutcome_lt {t r k : ℕ} (hk : k < r) : truncOutcome t r k < 2 ^ t := by
  have hr : 0 < r := lt_of_le_of_lt (Nat.zero_le k) hk
  unfold truncOutcome
  rw [Nat.div_lt_iff_lt_mul hr]
  exact (Nat.mul_lt_mul_left (Nat.two_pow_pos t)).mpr hk

/-- **Surjectivity of the truncated outcome map.**  As soon as the register is at
most as fine as the order (`2^t ≤ r`), *every* symbol of the `t`-bit alphabet is
produced by some numerator `k < r`. -/
theorem truncOutcome_surjective {t r : ℕ} (h : 2 ^ t ≤ r) {m : ℕ} (hm : m < 2 ^ t) :
    ∃ k < r, truncOutcome t r k = m := by
  set D : ℕ := 2 ^ t with hD
  have hDpos : 0 < D := Nat.two_pow_pos t
  have hrpos : 0 < r := lt_of_lt_of_le hDpos h
  obtain ⟨q, s, hs, ha⟩ : ∃ q s, s < D ∧ m * r = D * q + s :=
    ⟨(m * r) / D, (m * r) % D, Nat.mod_lt _ hDpos, (Nat.div_add_mod _ _).symm⟩
  -- the ceiling `k = ⌈m r / D⌉` lands in the window `[m r, m r + r)` because `D ≤ r`
  obtain ⟨k, hk1, hk2⟩ : ∃ k, m * r ≤ D * k ∧ D * k < m * r + r := by
    rcases eq_or_ne s 0 with hs0 | hs0
    · exact ⟨q, by omega, by omega⟩
    · have hmul : D * (q + 1) = D * q + D := by ring
      exact ⟨q + 1, by omega, by omega⟩
  have hkr : k < r := by
    have h5 : (m + 1) * r ≤ D * r := Nat.mul_le_mul_right r hm
    have h6 : (m + 1) * r = m * r + r := by ring
    have : D * k < D * r := by omega
    exact lt_of_mul_lt_mul_left this (Nat.zero_le D)
  refine ⟨k, hkr, ?_⟩
  unfold truncOutcome
  rw [← hD]
  have h1 : m ≤ D * k / r := (Nat.le_div_iff_mul_le hrpos).mpr hk1
  have h2 : D * k / r < m + 1 := by
    refine (Nat.div_lt_iff_lt_mul hrpos).mpr ?_
    have : (m + 1) * r = m * r + r := by ring
    omega
  omega

/-- The set of records a `t`-bit register can produce at order `r`. -/
def outcomes (t r : ℕ) : Set ℕ := {m | ∃ k < r, truncOutcome t r k = m}

/-- **The observable alphabet does not depend on the order.**  For every order
`r ≥ 2^t` the outcome set is the full `t`-bit alphabet. -/
theorem outcomes_eq_alphabet {t r : ℕ} (h : 2 ^ t ≤ r) :
    outcomes t r = {m | m < 2 ^ t} := by
  ext m
  constructor
  · rintro ⟨k, hk, rfl⟩
    exact truncOutcome_lt hk
  · intro hm
    exact truncOutcome_surjective h hm

/-- **Records coincide.**  Any list of samples observable at order `r` is
observable at order `r'`, whenever both orders exceed the register resolution. -/
theorem outcome_lists_coincide {t r r' : ℕ} (h : 2 ^ t ≤ r) (h' : 2 ^ t ≤ r')
    (L : List ℕ) :
    (∀ m ∈ L, m ∈ outcomes t r) ↔ (∀ m ∈ L, m ∈ outcomes t r') := by
  constructor <;> intro hL m hm
  · rw [outcomes_eq_alphabet h'] at *
    have := hL m hm
    rwa [outcomes_eq_alphabet h] at this
  · rw [outcomes_eq_alphabet h] at *
    have := hL m hm
    rwa [outcomes_eq_alphabet h'] at this

/-- Every record over the `t`-bit alphabet is realizable at every order `r ≥ 2^t`. -/
theorem records_realizable {t r : ℕ} (h : 2 ^ t ≤ r) {L : List ℕ} (hL : ∀ m ∈ L, m < 2 ^ t) :
    ∀ m ∈ L, m ∈ outcomes t r := by
  intro m hm
  rw [outcomes_eq_alphabet h]
  exact hL m hm

/-- **Any sample budget is useless.**  For every number `n` of samples there is a
record of length `n` which is realizable at both orders, so the estimator's answer
`A L` is wrong for at least one of them. -/
theorem samples_do_not_help_any_budget {t r r' : ℕ} (h : 2 ^ t ≤ r) (h' : 2 ^ t ≤ r')
    (hne : r ≠ r') (A : List ℕ → ℕ) (n : ℕ) :
    ∃ L : List ℕ, L.length = n ∧ (∀ m ∈ L, m ∈ outcomes t r) ∧
      (∀ m ∈ L, m ∈ outcomes t r') ∧ (A L ≠ r ∨ A L ≠ r') := by
  refine ⟨List.replicate n 0, List.length_replicate .., ?_, ?_, ?_⟩
  · refine records_realizable h ?_
    intro m hm
    rw [List.eq_of_mem_replicate hm]
    exact Nat.two_pow_pos t
  · refine records_realizable h' ?_
    intro m hm
    rw [List.eq_of_mem_replicate hm]
    exact Nat.two_pow_pos t
  · by_cases hA : A (List.replicate n 0) = r
    · exact Or.inr (by rw [hA]; exact hne)
    · exact Or.inl hA

/-- **Classical collapse: samples do not help.**  If two distinct orders both
exceed the register resolution (`2^t ≤ r, r'`), then no estimator `A` — a function
of an *arbitrary* list of truncated samples — can be correct for both.  In
particular no amount of repetition rescues a register with `t ≤ log₂ r`. -/
theorem samples_do_not_help {t r r' : ℕ} (h : 2 ^ t ≤ r) (h' : 2 ^ t ≤ r')
    (hne : r ≠ r') (A : List ℕ → ℕ) :
    ¬ ((∀ L : List ℕ, (∀ m ∈ L, m ∈ outcomes t r) → A L = r) ∧
       (∀ L : List ℕ, (∀ m ∈ L, m ∈ outcomes t r') → A L = r')) := by
  rintro ⟨hA, hA'⟩
  -- a record of any length made of genuine samples of *both* orders
  obtain ⟨k, hk, hk0⟩ := truncOutcome_surjective h (m := 0) (Nat.two_pow_pos t)
  set L : List ℕ := [0] with hL
  have hLr : ∀ m ∈ L, m ∈ outcomes t r := by
    intro m hm
    simp only [hL, List.mem_singleton] at hm
    subst hm
    exact ⟨k, hk, hk0⟩
  have hLr' : ∀ m ∈ L, m ∈ outcomes t r' := (outcome_lists_coincide h h' L).mp hLr
  exact hne ((hA L hLr).symm.trans (hA' L hLr'))

/-- **The collapse is massive.**  Every order in the window `[2^t, R]` produces
exactly the same set of truncated records; there are `R - 2^t + 1` of them. -/
theorem collapse_cardinality {t R : ℕ} :
    ∀ r ∈ Finset.Icc (2 ^ t) R, outcomes t r = {m | m < 2 ^ t} := by
  intro r hr
  rw [Finset.mem_Icc] at hr
  exact outcomes_eq_alphabet hr.1

/-- The collapse window is non-degenerate: it contains at least two orders as soon
as `2^t < R`, so `samples_do_not_help` applies inside it. -/
theorem collapse_window_card {t R : ℕ} (h : 2 ^ t ≤ R) :
    (Finset.Icc (2 ^ t) R).card = R - 2 ^ t + 1 := by
  rw [Nat.card_Icc]
  omega

end QubitTrade