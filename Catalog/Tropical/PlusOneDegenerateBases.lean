import Mathlib
import Tropical.PlusOneWilliamsCore

/-!
# Which bases can the Williams method use at all?

The experiment flagged `P = 2` as the *degenerate base* (`D = 0`): the Lucas
sequence is constant, so `gcd(V_M - 2, N) = N` and nothing is ever split. This
file determines the full list of such useless bases and shows there are no
others.

A base `P ∈ ℤ` is **universally degenerate** if `V_k(P) = 2` for some `k ≥ 1`
*as an integer identity*; then the gcd step returns `N` for every `N` and every
exponent divisible by `k`, whatever the factors are.

* `lucasV_periodic`, `lucasV_eq_two_of_period` — a return to the initial state
  `(2, P)` makes the sequence periodic, hence `V_M = 2` on all multiples.
* `degenerate_base_*` — the bases `-2, -1, 0, 1, 2` are universally degenerate,
  with periods `2, 3, 4, 6, 1`; these are exactly the `P = 2cos θ` with `a` a
  root of unity of order `1, 2, 3, 4, 6`.
* `lucasV_three_le` — for `P ≥ 3` the sequence is strictly increasing from
  `V₁ = P` on and stays `≥ 3`, so it never returns to `2`.
* `exists_lucasV_eq_two_iff_abs_le_two` — **the classification**: a base is
  universally degenerate if and only if `|P| ≤ 2`. This is why the classical
  algorithm starts its base search at `P = 3`.
-/

namespace PlusOneDegenerateBases

open PlusOneWilliams

/-! ## 1. Periodicity -/

/-- If the sequence returns to its initial state `(2, P)` at index `k`, it is
periodic with period `k`. -/
lemma lucasV_periodic {R : Type*} [CommRing R] (P : R) (k : ℕ) (h0 : lucasV P k = 2)
    (h1 : lucasV P (k + 1) = P) (n : ℕ) : lucasV P (n + k) = lucasV P n := by
  induction n using Nat.twoStepInduction with
  | zero => simpa using h0
  | one => simpa [add_comm] using h1
  | more n ih1 ih2 =>
      rw [show n + 2 + k = (n + k) + 2 by ring, lucasV_succ_succ, lucasV_succ_succ,
        show (n + k) + 1 = (n + 1) + k by ring, ih1, ih2]

/-- A period `k` forces `V_M = 2` on every multiple of `k`. -/
lemma lucasV_eq_two_of_period {R : Type*} [CommRing R] (P : R) (k : ℕ) (h0 : lucasV P k = 2)
    (h1 : lucasV P (k + 1) = P) {M : ℕ} (hM : k ∣ M) : lucasV P M = 2 := by
  obtain ⟨j, rfl⟩ := hM
  induction j with
  | zero => simp
  | succ j ih =>
      have hidx : k * (j + 1) = k * j + k := by ring
      rw [hidx, lucasV_periodic P k h0 h1 (k * j), ih]

/-! ## 2. The five degenerate bases -/

theorem degenerate_base_two {M : ℕ} : lucasV (2 : ℤ) M = 2 := lucasV_two_eq_two M

theorem degenerate_base_neg_two {M : ℕ} (hM : 2 ∣ M) : lucasV (-2 : ℤ) M = 2 :=
  lucasV_eq_two_of_period (-2 : ℤ) 2 (by decide) (by decide) hM

theorem degenerate_base_neg_one {M : ℕ} (hM : 3 ∣ M) : lucasV (-1 : ℤ) M = 2 :=
  lucasV_eq_two_of_period (-1 : ℤ) 3 (by decide) (by decide) hM

theorem degenerate_base_zero {M : ℕ} (hM : 4 ∣ M) : lucasV (0 : ℤ) M = 2 :=
  lucasV_eq_two_of_period (0 : ℤ) 4 (by decide) (by decide) hM

theorem degenerate_base_one {M : ℕ} (hM : 6 ∣ M) : lucasV (1 : ℤ) M = 2 :=
  lucasV_eq_two_of_period (1 : ℤ) 6 (by decide) (by decide) hM

/-- A universally degenerate base makes the gcd step return the modulus itself:
no factor is ever produced, for any `N`. -/
theorem gcd_eq_of_lucasV_eq_two {P : ℤ} {M N : ℕ} (h : lucasV P M = 2) :
    Int.gcd (lucasV P M - 2) (N : ℤ) = N := by
  rw [h, sub_self]
  simp

/-! ## 3. Bases `|P| ≥ 3` never degenerate -/

/-- For `P ≥ 3` the Lucas sequence is `≥ 3` and strictly increasing from index
`1` on. -/
theorem lucasV_three_le {P : ℤ} (hP : 3 ≤ P) :
    ∀ n : ℕ, 3 ≤ lucasV P (n + 1) ∧ lucasV P (n + 1) < lucasV P (n + 2) := by
  intro n
  induction n with
  | zero =>
      constructor
      · simpa using hP
      · have h : lucasV P 2 = P * P - 2 := by
          rw [lucasV_succ_succ, lucasV_one, lucasV_zero]
        rw [h]
        rw [lucasV_one]
        nlinarith
  | succ n ih =>
      obtain ⟨hge, hlt⟩ := ih
      have hge2 : 3 ≤ lucasV P (n + 2) := le_trans hge (le_of_lt hlt)
      refine ⟨hge2, ?_⟩
      have h : lucasV P (n + 3) = P * lucasV P (n + 2) - lucasV P (n + 1) := by
        rw [show n + 3 = (n + 1) + 2 by ring, lucasV_succ_succ]
      rw [h]
      nlinarith

/-- Consequently `V_M(P) ≠ 2` for every `M ≥ 1` when `P ≥ 3`: the base is
usable. -/
theorem lucasV_ne_two_of_three_le {P : ℤ} (hP : 3 ≤ P) {M : ℕ} (hM : 1 ≤ M) :
    lucasV P M ≠ 2 := by
  obtain ⟨n, rfl⟩ : ∃ n, M = n + 1 := ⟨M - 1, by omega⟩
  have h := (lucasV_three_le hP n).1
  omega

/-- Sign symmetry of the Lucas sequence in the base. -/
theorem lucasV_neg (P : ℤ) (n : ℕ) : lucasV (-P) n = (-1) ^ n * lucasV P n := by
  induction n using Nat.twoStepInduction with
  | zero => simp
  | one => simp
  | more n ih1 ih2 =>
      rw [lucasV_succ_succ, lucasV_succ_succ, ih1, ih2]
      ring

/-! ## 4. The classification -/

/-- **Classification of degenerate bases.** The Lucas sequence with base `P`
returns to the value `2` at some positive index — making the Williams gcd
vacuous for every modulus — if and only if `|P| ≤ 2`. Equivalently: the root
`a` of `x² - Px + 1` is a root of unity exactly for `P ∈ {-2,-1,0,1,2}`, and
these are precisely the bases the classical algorithm must avoid. -/
theorem exists_lucasV_eq_two_iff_abs_le_two (P : ℤ) :
    (∃ k : ℕ, 1 ≤ k ∧ lucasV P k = 2) ↔ |P| ≤ 2 := by
  constructor
  · rintro ⟨k, hk, hV⟩
    by_contra habs
    rw [not_le] at habs
    rcases abs_cases P with ⟨heq, hsign⟩ | ⟨heq, hsign⟩
    · -- `P ≥ 3`
      have hP3 : 3 ≤ P := by omega
      exact lucasV_ne_two_of_three_le hP3 hk hV
    · -- `P ≤ -3`
      have hP3 : 3 ≤ -P := by omega
      have hsym : lucasV P k = (-1) ^ k * lucasV (-P) k := by
        have := lucasV_neg (-P) k
        rw [neg_neg] at this
        rw [this]
      rw [hsym] at hV
      rcases Nat.even_or_odd k with hk2 | hk2
      · rw [hk2.neg_one_pow, one_mul] at hV
        exact lucasV_ne_two_of_three_le hP3 hk hV
      · rw [hk2.neg_one_pow, neg_one_mul, neg_eq_iff_eq_neg] at hV
        have h := (lucasV_three_le hP3 (k - 1)).1
        rw [show k - 1 + 1 = k by omega] at h
        omega
  · intro habs
    obtain ⟨h1, h2⟩ := abs_le.mp habs
    interval_cases P
    · exact ⟨2, by norm_num, degenerate_base_neg_two ⟨1, rfl⟩⟩
    · exact ⟨3, by norm_num, degenerate_base_neg_one ⟨1, rfl⟩⟩
    · exact ⟨4, by norm_num, degenerate_base_zero ⟨1, rfl⟩⟩
    · exact ⟨6, by norm_num, degenerate_base_one ⟨1, rfl⟩⟩
    · exact ⟨1, by norm_num, degenerate_base_two⟩

end PlusOneDegenerateBases