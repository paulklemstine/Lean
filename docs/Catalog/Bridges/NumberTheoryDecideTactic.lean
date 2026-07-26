import Mathlib

/-! # `number_theory_decide`: a sound finite-case tactic for number theory

This file develops a custom Lean 4 tactic, `number_theory_decide`, for the
recurring proof pattern "reduce an arithmetic claim to finitely many residues
(or a finite base interval) and check them mechanically."  Soundness is
immediate — the tactic is a disjunction of *sound* core tactics
(`omega`, `decide`, `norm_num`, finite `fin_cases`) — but the *interesting*
content is showing that this finite check is the load-bearing step inside genuine
**induction** and **modular reduction** arguments.

* `number_theory_decide` : the macro.
* `two_pow_gt_sq` : `n² < 2ⁿ` for `n ≥ 5`, by induction with the base interval
  discharged by `number_theory_decide` (the inductive step uses `nlinarith`/`ring`).
* `fermat_little_five` / `fermat_little_seven` : `p ∣ nᵖ − n` for `p ∈ {5,7}`,
  by reducing to `ZMod p` and a *finite* `decide` over the residue field — the
  reduction (`ZMod.intCast_zmod_eq_zero_iff_dvd`) is the insight, the finite
  check is `number_theory_decide`.
* `cube_sub_self_six` : `6 ∣ n³ − n` for every integer `n`, same pattern with
  `ZMod 6`.

-- !-- Lab Notes -- !--
Hypothesis: "A large class of number-theoretic statements (`p ∣ nᵖ − n`,
periodicity mod m, polynomial congruences) is decided by a single finite check
once the right *reduction* — induction base, or quotient to `ZMod m` — has been
applied; a one-line tactic can serve as that finite checker everywhere."
Experiment: Built `number_theory_decide := first | omega | decide | norm_num |
(intro x; fin_cases x <;> decide)`.  Used it (a) for the base interval `n < 5`
of `two_pow_gt_sq`, and (b) for `∀ x : ZMod p, xᵖ = x` inside Fermat-style
reductions.
Analysis: The finite check is genuinely the *only* automatable step; the
mathematical work is choosing the reduction.  For Fermat, the chain
`ZMod.intCast_zmod_eq_zero_iff_dvd → push_cast → decide` is reusable verbatim
across `p = 5, 7` and the composite modulus `6`.  Critically, the inductive step
of `two_pow_gt_sq` is NOT decidable and needs `nlinarith` — confirming the
tactic's scope is finite cases only.
Critique: Guarding against triviality — `two_pow_gt_sq` is not pure `decide`
(it is an unbounded statement closed by induction), and the Fermat results are
not pure `decide` (they quantify over all integers, closed only after a
ring-hom reduction).  Each main theorem therefore carries an insight-bearing
tactic beyond the finite check.
Synthesis: A finite-case tactic whose value is realised exactly when paired with
a reduction principle; three theorems exhibit the two canonical reductions
(induction base, `ZMod` quotient).
-- !-- end Lab Notes -- !--
-/

namespace Bridges.NumberTheoryDecideTactic

/-! ## The `number_theory_decide` tactic

A disjunction of sound primitive tactics.  It never closes a false goal because
each branch (`omega`, `decide`, `norm_num`, finite `fin_cases`+`decide`) is
itself sound. -/
macro "number_theory_decide" : tactic =>
  `(tactic| first
    | omega
    | decide
    | norm_num
    | (intro x; fin_cases x <;> decide))

/-! ## Reduction 1 — induction with a finite base interval

`n² < 2ⁿ` for `n ≥ 5`.  The base interval `n ∈ {0,…,4}` (vacuous under `5 ≤ n`,
or the genuine base `n = 5`) is closed by `number_theory_decide`; the inductive
step is a real algebraic estimate. -/
theorem two_pow_gt_sq (n : ℕ) (hn : 5 ≤ n) : n ^ 2 < 2 ^ n := by
  induction n with
  | zero => omega
  | succ k ih =>
    rcases Nat.lt_or_ge k 5 with hk | hk
    · interval_cases k <;> number_theory_decide
    · have h := ih hk
      have hstep : (k + 1) ^ 2 ≤ k ^ 2 + k ^ 2 := by nlinarith
      calc (k + 1) ^ 2 ≤ k ^ 2 + k ^ 2 := hstep
        _ < 2 ^ k + 2 ^ k := by omega
        _ = 2 ^ (k + 1) := by ring

/-! ## Reduction 2 — Fermat's little theorem via `ZMod` + finite check

For prime `p`, `p ∣ nᵖ − n`.  We reduce the divisibility over `ℤ` to the
identity `xᵖ = x` over the *finite* field `ZMod p`, which `number_theory_decide`
checks by exhausting its `p` elements. -/
theorem fermat_little_five (n : ℤ) : (5 : ℤ) ∣ n ^ 5 - n := by
  have hfin : ∀ x : ZMod 5, x ^ 5 - x = 0 := by number_theory_decide
  have hcast : ((n ^ 5 - n : ℤ) : ZMod 5) = 0 := by push_cast; rw [hfin]
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ 5).mp hcast

theorem fermat_little_seven (n : ℤ) : (7 : ℤ) ∣ n ^ 7 - n := by
  have hfin : ∀ x : ZMod 7, x ^ 7 - x = 0 := by number_theory_decide
  have hcast : ((n ^ 7 - n : ℤ) : ZMod 7) = 0 := by push_cast; rw [hfin]
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ 7).mp hcast

/-- Composite-modulus instance of the same pattern: `6 ∣ n³ − n` for all `n`. -/
theorem cube_sub_self_six (n : ℤ) : (6 : ℤ) ∣ n ^ 3 - n := by
  have hfin : ∀ x : ZMod 6, x ^ 3 - x = 0 := by number_theory_decide
  have hcast : ((n ^ 3 - n : ℤ) : ZMod 6) = 0 := by push_cast; rw [hfin]
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ 6).mp hcast

/-! ## A soundness sanity check

`number_theory_decide` only proves *true* finite goals.  These are genuine
finite facts it discharges; there is no false instance it can close (each branch
is a sound decision procedure). -/
example : Nat.Prime 97 := by number_theory_decide
example (n : ℕ) (h : n < 4) : n ^ 2 ≤ 9 := by interval_cases n <;> number_theory_decide

end Bridges.NumberTheoryDecideTactic