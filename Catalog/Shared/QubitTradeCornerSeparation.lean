import Mathlib
import Shared.QubitTradeResourceSurface

/-!
# The cost band of the resource surface

*(FACT round-25 #3 — QUBIT-TRADE4, companion to `Shared.QubitTradeResourceSurface`.)*

`Shared.QubitTradeResourceSurface` proves that the minimum of the three-axis
resource surface sits at the full-register corner.  This file locates that
minimum on the absolute scale, which is what the round's closure claim needs:

* **Upward.**  Moving off the corner along the width axis does not merely cost
  more, it costs *exponentially* more: the total gate count at a shave of `d`
  bits is bounded below by `(P/q₀)·2^d·(T-d)²`
  (`surface_cost_exponential_in_shave`), a bound that already exceeds the corner
  cost by a factor `2^d/4` for shaves up to half the register.

* **Downward.**  The corner itself stays polynomial, and strictly below the
  cost of a square-root-scale exhaustive search: for a register of full width
  `T = 2M` with `M ≥ 20`, the corner's cubic gate count `3·T³` is strictly less
  than `2^M` (`corner_cost_lt_sqrt_search`).  The engine of that comparison is
  the elementary but genuinely inductive estimate `24·M³ < 2^M`
  (`cube_lt_two_pow`), proved by a ratio argument `(1+1/M)³ ≤ 2`.

Together: the surface has a polynomial floor at the textbook parameterisation
and rises exponentially in every direction in which one tries to economise on
register width.
-/

namespace QubitTradeSurface

/-! ## 1. A cubic-versus-exponential estimate -/

/-- `24 M³ < 2^M` for every `M ≥ 20`.  Proved by induction: the base case is
`192000 < 1048576`, and the inductive step only needs `(1 + 1/M)³ ≤ 2`, which
holds for `M ≥ 4`. -/
theorem cube_lt_two_pow : ∀ M : ℕ, 20 ≤ M → 24 * (M : ℝ) ^ 3 < 2 ^ M := by
  intro M hM
  induction M, hM using Nat.le_induction with
  | base => norm_num
  | succ M hM ih =>
      have hM4 : (4:ℝ) ≤ (M : ℝ) := by
        have : (20:ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
        linarith
      have hstep : 24 * ((M : ℝ) + 1) ^ 3 ≤ 2 * (24 * (M : ℝ) ^ 3) := by
        nlinarith [sq_nonneg ((M:ℝ) - 4), sq_nonneg ((M:ℝ) + 1), hM4]
      have hpow : (2:ℝ) ^ (M + 1) = 2 * 2 ^ M := by ring
      push_cast
      calc 24 * ((M : ℝ) + 1) ^ 3 ≤ 2 * (24 * (M : ℝ) ^ 3) := hstep
      _ < 2 * 2 ^ M := by linarith
      _ = 2 ^ (M + 1) := hpow.symm

/-- **The corner is polynomial, and strictly cheaper than a square-root-scale
search.**  For a full register of width `T = 2M` with `M ≥ 20`, the corner's
cubic gate count `3·T³` is strictly below `2^M`, the cost of an exhaustive
search over the square root of the modulus. -/
theorem corner_cost_lt_sqrt_search {M T : ℕ} (hM : 20 ≤ M) (hT : T = 2 * M) :
    3 * (T : ℝ) ^ 3 < 2 ^ M := by
  subst hT
  have h := cube_lt_two_pow M hM
  push_cast
  nlinarith [h]

/-! ## 2. The exponential wall along the width axis -/

/-- **Exponential cost of economising on width.**  Every configuration that
reaches success probability `P` with a register shaved by `d` bits burns at
least `(P/q₀)·2^d·t²` gates.  The floor grows exponentially in the number of
shaved bits, while the per-shot saving is only quadratic. -/
theorem surface_cost_exponential_in_shave {q₀ P : ℝ} (hq : 0 < q₀) (hq1 : q₀ ≤ 1)
    {d t n : ℕ} (hn : P ≤ succProb (shotProb q₀ d) n) :
    (P / q₀) * 2 ^ d * (t : ℝ) ^ 2 ≤ (gateCost n t : ℝ) := by
  have hfloor : P * 2 ^ d ≤ (n : ℝ) * q₀ := shots_floor hq hq1 hn
  have hdiv : (P / q₀) * 2 ^ d ≤ (n : ℝ) := by
    rw [div_mul_eq_mul_div, div_le_iff₀ hq]
    linarith
  have := mul_le_mul_of_nonneg_right hdiv (by positivity : (0:ℝ) ≤ (t:ℝ) ^ 2)
  simpa [gateCost] using this

/-- **The wall, in comparative form.**  At a shave of `d ≥ 1` bits of a register
of full width `T ≥ 8`, with `2d ≤ T`, every admissible configuration costs at
least `2^d / 4` times the union-bound floor `(P/q₀)·T²` of the corner: the
penalty doubles with every further bit removed. -/
theorem surface_cost_wall {q₀ P : ℝ} (hq : 0 < q₀) (hq1 : q₀ ≤ 1) (hP : 0 < P)
    {T d t n : ℕ} (hT : 8 ≤ T) (hdT : 2 * d ≤ T) (ht : t + d = T)
    (hn : P ≤ succProb (shotProb q₀ d) n) :
    (2 ^ d / 4) * ((P / q₀) * (T : ℝ) ^ 2) ≤ (gateCost n t : ℝ) := by
  have hTR : (8:ℝ) ≤ (T : ℝ) := by exact_mod_cast hT
  have hdTR : 2 * (d : ℝ) ≤ (T : ℝ) := by exact_mod_cast hdT
  have htR : (t : ℝ) = (T : ℝ) - (d : ℝ) := by
    have : ((t : ℝ)) + (d : ℝ) = (T : ℝ) := by exact_mod_cast ht
    linarith
  have hbase := surface_cost_exponential_in_shave (t := t) hq hq1 hn
  have hhalf : (T : ℝ) / 2 ≤ (t : ℝ) := by rw [htR]; linarith
  have hsq : ((T : ℝ) / 2) ^ 2 ≤ (t : ℝ) ^ 2 :=
    pow_le_pow_left₀ (by linarith) hhalf 2
  have hPq : 0 < P / q₀ := div_pos hP hq
  have hpow : (0:ℝ) < 2 ^ d := by positivity
  have hmono : (P / q₀) * 2 ^ d * ((T : ℝ) / 2) ^ 2 ≤ (P / q₀) * 2 ^ d * (t : ℝ) ^ 2 :=
    mul_le_mul_of_nonneg_left hsq (by positivity)
  have hrw : (2 ^ d / 4) * ((P / q₀) * (T : ℝ) ^ 2)
      = (P / q₀) * 2 ^ d * ((T : ℝ) / 2) ^ 2 := by ring
  rw [hrw]
  linarith

/-! ## 3. The measured cells of the round, reproduced inside the model

The round used a full register of width `T = 40` and the cells
`t ∈ {36, 38, 40}`, target `P* = 3/10`, fitted per-shot probability
`q₀ = 1/8`.  The three theorems below are the model's own version of the
corrected cost accounting `G ≈ k·s·t²` reported for those cells: `4800` at the
corner, at least `14440` at `wall − 2`, and at least `50544` at `wall − 4`. -/

/-- Shot-count floor at a shave of `d` bits with `q₀ = 1/8`, `P* = 3/10`,
in integer form. -/
theorem shots_floor_nat {d n c : ℕ} (hn : (3:ℝ)/10 ≤ succProb (shotProb (1/8) d) n)
    (hc : (c : ℝ) - 1 < (3/10) * 2 ^ d * 8) : c ≤ n := by
  have hfloor : (3/10 : ℝ) * 2 ^ d ≤ (n : ℝ) * (1/8) :=
    shots_floor (by norm_num) (by norm_num) hn
  by_contra hcon
  push_neg at hcon
  have h1 : (n : ℝ) ≤ (c : ℝ) - 1 := by
    have h2 : n + 1 ≤ c := hcon
    have h3 : ((n : ℝ)) + 1 ≤ (c : ℝ) := by exact_mod_cast h2
    linarith
  linarith

/-- **Corner cell** `t = 40`: three shots suffice, for a cost of `4800`. -/
theorem cell_wall_cost :
    (3:ℝ)/10 ≤ succProb (shotProb (1/8) 0) 3 ∧ gateCost 3 40 = 4800 :=
  ⟨full_register_suffices, by norm_num [gateCost]⟩

/-- **Cell `wall − 2`** (`t = 38`): every admissible configuration costs at
least `14440`, three times the corner. -/
theorem cell_wall_minus_two_cost {n : ℕ}
    (hn : (3:ℝ)/10 ≤ succProb (shotProb (1/8) 2) n) : 14440 ≤ gateCost n 38 := by
  have h10 : 10 ≤ n := shots_floor_nat hn (by norm_num)
  calc 14440 = 10 * 38 ^ 2 := by norm_num
  _ ≤ n * 38 ^ 2 := Nat.mul_le_mul_right _ h10
  _ = gateCost n 38 := rfl

/-- **Cell `wall − 4`** (`t = 36`): every admissible configuration costs at
least `50544`, more than ten times the corner. -/
theorem cell_wall_minus_four_cost {n : ℕ}
    (hn : (3:ℝ)/10 ≤ succProb (shotProb (1/8) 4) n) : 50544 ≤ gateCost n 36 := by
  have h39 : 39 ≤ n := shots_floor_nat hn (by norm_num)
  calc 50544 = 39 * 36 ^ 2 := by norm_num
  _ ≤ n * 36 ^ 2 := Nat.mul_le_mul_right _ h39
  _ = gateCost n 36 := rfl

end QubitTradeSurface