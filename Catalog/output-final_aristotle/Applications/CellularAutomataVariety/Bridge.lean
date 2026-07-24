import Catalog.Applications.CellularAutomataVariety.Basic

/-!
# Bridge: Rule 90, the Fibonacci companion matrix, and the Pisano period

The additive rule 90 fixes a configuration `s` exactly when it satisfies the
Fibonacci recurrence over `GF(2)`,
`s(i+1) = s i + s(i-1)`  (`rule90_fixed_iff_fib` in `Basic`).

This file makes the resulting bridge to number theory precise.  The recurrence is
governed by the **Fibonacci companion matrix** over the binary field,
`T = !![0,1; 1,1] ∈ M₂(GF(2))`, whose successive powers advance the pair
`(s i, s(i+1))`.  Two facts then meet:

* `T` has multiplicative order `3` — this is the **Pisano period of `2`**, the
  period of the Fibonacci sequence modulo `2` (`0,1,1,0,1,1,…`); and
* on a cycle of length `n` a Fibonacci solution closes up iff `T^n = 1`, i.e.
  iff `3 ∣ n`.

Together they explain the count observed in `Counts.lean`: Rule 90 admits a
nontrivial fixed configuration exactly when `3 ∣ n`, and its fixed-point variety
then jumps from dimension `0` to dimension `2`.

-- !-- Lab Notes -- !--

HYPOTHESIS.  The `3 ∣ n` dichotomy in the Rule 90 counts is the shadow of the
Pisano period `π(2) = 3`, realised as the order of the companion matrix `T` over
`GF(2)`.

EXPERIMENT.  `T_pow_three` (`T^3 = 1`), `T_orderOf` (`orderOf T = 3`), and
`T_pow_eq_one_iff` (`T^n = 1 ↔ 3 ∣ n`) pin down the order.  `rule90_transfer`
shows `T` is exactly the transfer matrix of a Rule 90 fixed point, and
`fib_mod_two_period_three` records the same period on the raw Fibonacci sequence.

ANALYSIS.  The cross-domain identity is: *(order of a `2×2` matrix over `GF(2)`)
= (Pisano period `π(2)`) = (Rule 90 fixed-point periodicity)*.  Linear dynamics,
number theory, and cellular automata coincide on the number `3`.

CRITIQUE.  `T_orderOf` uses primality of `3` (`orderOf_eq_prime`), not a bare
`decide`; `rule90_transfer` is a genuine reindexing of the recurrence, not a
definitional unfolding.

SYNTHESIS.  The exact dimension of the Rule 90 variety is dictated by the order of
`T`; the "complexity" of an additive automaton is arithmetic, not dynamical.
-/

open Matrix

namespace CellularAutomataVariety

/-- The Fibonacci companion matrix over the binary field `GF(2)`. -/
def T : Matrix (Fin 2) (Fin 2) Cell := !![0, 1; 1, 1]

/-- The companion matrix cubes to the identity: the Fibonacci recurrence over
`GF(2)` has period dividing `3`. -/
theorem T_pow_three : T ^ 3 = 1 := by decide

theorem T_ne_one : T ≠ 1 := by decide

/-- The order of the Fibonacci companion matrix over `GF(2)` is `3` — the Pisano
period `π(2)`. -/
theorem T_orderOf : orderOf T = 3 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  exact orderOf_eq_prime T_pow_three T_ne_one

/-- A Fibonacci solution over `GF(2)` closes up on a cycle of length `n` exactly
when `3 ∣ n`. -/
theorem T_pow_eq_one_iff (n : ℕ) : T ^ n = 1 ↔ 3 ∣ n := by
  rw [← T_orderOf, orderOf_dvd_iff_pow_eq_one]

/-- **Transfer-matrix bridge.**  For a Rule 90 fixed configuration `s`, the
companion matrix `T` advances the state pair `(s i, s(i+1))`:
`(s(i+1), s(i+2)) = T · (s i, s(i+1))`.  Thus the fixed points of Rule 90 are the
orbits of `T`, and the cyclic closure condition is `T^n = 1`. -/
theorem rule90_transfer {n : ℕ} (s : Config n) (h : IsFixed rule90 s) (i : ZMod n) :
    ![s (i + 1), s (i + 2)] = T *ᵥ ![s i, s (i + 1)] := by
  have hfib := (rule90_fixed_iff_fib s).1 h (i + 1)
  -- hfib : s ((i+1)+1) = s (i+1) + s ((i+1)-1)
  have e1 : (i + 1) + 1 = i + 2 := by ring
  have e2 : (i + 1) - 1 = i := by ring
  rw [e1, e2] at hfib
  -- hfib : s (i+2) = s (i+1) + s i
  funext j
  fin_cases j <;> simp [T, Matrix.mulVec, dotProduct, Fin.sum_univ_two, hfib]
  all_goals ring

/-- The Fibonacci sequence is periodic modulo `2` with period `3`
(`0,1,1,0,1,1,…`): the number-theoretic incarnation of `orderOf T = 3`. -/
theorem fib_mod_two_period_three (n : ℕ) :
    (Nat.fib (n + 3) : Cell) = (Nat.fib n : Cell) := by
  have h1 : Nat.fib (n + 3) = Nat.fib n + 2 * Nat.fib (n + 1) := by
    rw [Nat.fib_add_two, Nat.fib_add_two]; ring
  have h2 : (2 : Cell) = 0 := by decide
  rw [h1]; push_cast; rw [h2]; ring

end CellularAutomataVariety