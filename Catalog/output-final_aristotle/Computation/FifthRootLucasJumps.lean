import Mathlib

/-!
# Fibonacci–Lucas structure of the jump positions of `σ₅`

For the minimal-absolute-value function `σ₅` of non-vanishing sums of fifth roots of
unity (developed in `Catalog/Computation/FifthRootMinimalValue.lean`), the strict
decreases `σ₅(n) > σ₅(n+5)` occur exactly at positions `n+5 ∈ {5Fₘ, Lₘ, 2Lₘ : m ≥ 1}`,
where `F` is the Fibonacci and `L` the Lucas sequence.  This file develops the
purely number-theoretic backbone of that characterization.

The Lucas sequence is redefined here locally (`lucasNum`, with `L 0 = 2`, `L 1 = 1`,
`L (n+2) = L n + L (n+1)`), mirroring `Catalog/Applications/FibonacciLucasBridge.lean`
(the catalog build graph does not expose cross-library `olean`s, so the sequence is
restated self-containedly against Mathlib's `Nat.fib`).

## Main results

* `lucasNum_succ_eq` — the Fibonacci bridge `L (n+1) = Fₙ + Fₙ₊₂`.
* `lucasNum_not_dvd_five` — **no Lucas number is divisible by `5`** (period-4 argument
  modulo `5`).  This is the arithmetic reason the three jump families are *disjoint by
  residue*: the Lucas-type positions `Lₘ, 2Lₘ` are never multiples of `5`.
* `jump_dvd_five_is_fib` — **structure theorem**: a jump position divisible by `5` must
  belong to the Fibonacci family, i.e. equal `5Fₘ`.  Hence the residue-`0` jump family is
  exactly `{5Fₘ}`, matching the computational evidence `{10,15,25,40} = {5F₃,…,5F₆}`.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): the mod-5 residue of a jump position determines which family
--   it can belong to; in particular multiples of 5 can only be `5Fₘ`.
-- Experiment (Experimenter): `L mod 5 = 2,1,3,4,2,1,3,4,…` (period 4) — never 0; likewise
--   `2L mod 5 = 4,2,1,3,…` never 0.  Confirmed for m ≤ 20 numerically.
-- Analysis (Analyst): the disjointness-by-residue is exactly `¬ 5 ∣ Lₘ`, proved by a
--   period-4 induction in `ZMod 5`.  The Fibonacci bridge `L(n+1)=Fₙ+Fₙ₊₂` links the two
--   sequences and is the algebraic engine of the classical doubling identity.
-- Critique (Critic): must guard `m ≥ 1` in `isJumpPos` (the position 0 is excluded, and
--   `5F₁ = 5F₂ = 5` corresponds to the boundary `n = 0` where σ₅ is undefined/0).
-- !-- End Lab Notes -- !--
-/

namespace FifthRootLucasJumps

/-- The Lucas numbers: `L 0 = 2`, `L 1 = 1`, `L (n+2) = L n + L (n+1)`. -/
def lucasNum : ℕ → ℕ
  | 0 => 2
  | 1 => 1
  | (n + 2) => lucasNum n + lucasNum (n + 1)

@[simp] lemma lucasNum_zero : lucasNum 0 = 2 := rfl
@[simp] lemma lucasNum_one : lucasNum 1 = 1 := rfl
lemma lucasNum_add_two (n : ℕ) : lucasNum (n + 2) = lucasNum n + lucasNum (n + 1) := rfl

/--
The Fibonacci bridge: `L (n+1) = Fₙ + Fₙ₊₂`.
-/
theorem lucasNum_succ_eq (n : ℕ) : lucasNum (n + 1) = Nat.fib n + Nat.fib (n + 2) := by
  -- We proceed by induction on $n$.
  induction' n using Nat.twoStepInduction with n ih₁ ih₂;
  · rfl;
  · decide
  · simp_all +arith +decide [ lucasNum_add_two, Nat.fib_add_two ]

/--
Four-step recurrence `L (n+4) = 2 L n + 3 L (n+1)` (used for the period-4 mod-5 argument).
-/
theorem lucasNum_add_four (n : ℕ) : lucasNum (n + 4) = 2 * lucasNum n + 3 * lucasNum (n + 1) := by
  grind +locals

/--
**No Lucas number is divisible by `5`.**  Modulo `5` the sequence is periodic with
period `4`, cycling through `2, 1, 3, 4`, none of which is `0`.
-/
theorem lucasNum_not_dvd_five (n : ℕ) : ¬ (5 ∣ lucasNum n) := by
  rcases n with ( _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ Nat.dvd_iff_mod_eq_zero ];
  have h_period : ∀ n, lucasNum n % 5 = [2, 1, 3, 4].getD (n % 4) 0 := by
    intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ Nat.dvd_iff_mod_eq_zero ] ;
    rw [ lucasNum_add_four ] ; norm_num [ Nat.add_mod, Nat.mul_mod, ih ] ;
    have := Nat.mod_lt n zero_lt_four; interval_cases n % 4 <;> trivial;
  norm_num [ Nat.add_mod, Nat.mul_mod, h_period ] ; have := Nat.mod_lt n zero_lt_four; interval_cases n % 4 <;> trivial;

/-- A position is a *jump position* if it is `5Fₘ`, `Lₘ`, or `2Lₘ` for some `m ≥ 1`. -/
def isJumpPos (N : ℕ) : Prop :=
  ∃ m, 1 ≤ m ∧ (N = 5 * Nat.fib m ∨ N = lucasNum m ∨ N = 2 * lucasNum m)

/-- **Structure theorem for multiple-of-five jumps.**  A jump position divisible by `5`
must be of Fibonacci type `5Fₘ`; the Lucas families `Lₘ` and `2Lₘ` contribute no multiples
of `5`. -/
theorem jump_dvd_five_is_fib {N : ℕ} (hj : isJumpPos N) (h5 : 5 ∣ N) :
    ∃ m, 1 ≤ m ∧ N = 5 * Nat.fib m := by
  obtain ⟨m, hm, hcase⟩ := hj
  rcases hcase with h | h | h
  · exact ⟨m, hm, h⟩
  · exact absurd (h ▸ h5) (lucasNum_not_dvd_five m)
  · exfalso
    rw [h] at h5
    have hco : Nat.Coprime 5 2 := by decide
    exact lucasNum_not_dvd_five m (hco.dvd_of_dvd_mul_left h5)

/-- Sanity: `6 = 2·L₂` is a jump position (residue `1` mod `5`). -/
example : isJumpPos 6 := ⟨2, by norm_num, Or.inr (Or.inr (by decide))⟩

/-- Sanity: `10 = 5·F₃` is a jump position (residue `0` mod `5`). -/
example : isJumpPos 10 := ⟨3, by norm_num, Or.inl (by decide)⟩

/-- Sanity: `7 = L₄` is a jump position (residue `2` mod `5`). -/
example : isJumpPos 7 := ⟨4, by norm_num, Or.inr (Or.inl (by decide))⟩

end FifthRootLucasJumps