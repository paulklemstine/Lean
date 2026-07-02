import Mathlib

/-! # Fermat's Little Theorem for `p = 5` — an elementary, self-contained proof

The target conjecture:

> For every integer `a`, the number `a⁵ − a` is an integer multiple of `5`.

This file gives a proof that does **not** appeal to the theory of finite fields
or to a residue-class case check.  Instead it is fully elementary: the identity

  `(n+1)⁵ − (n+1) = (n⁵ − n) + 5·(n⁴ + 2n³ + 2n² + n)`

shows that the "defect" `a⁵ − a` changes by an explicit multiple of `5` when `a`
is incremented, so an integer induction (base `a = 0`, positive step, negative
step) propagates divisibility across all of `ℤ`.  The load-bearing content is the
ring identity, discharged by `ring`, together with `Int.induction_on`.

A companion factorisation `a⁵ − a = (a−1)·a·(a+1)·(a²+1)` is also recorded; it
exposes the three consecutive integers `a−1, a, a+1` hidden inside `a⁵ − a`, and
is reused in `FermatFiveGeneralizations.lean` to sharpen `5 ∣ ·` to `30 ∣ ·`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Ranked conjectures about `a⁵ − a`:
  (H1) `5 ∣ a⁵ − a` for all `a : ℤ`  [the target — high confidence].
  (H2) `30 ∣ a⁵ − a` for all `a : ℤ`  [surprising strengthening: also 2·3].
  (H3) `a⁵ − a = (a−1)a(a+1)(a²+1)`  [structural factorisation].
  (H4) For every prime `p`, `p ∣ aᵖ − a`  [the general law; p=5 is an instance].
  (H5, counter-intuitive) The step `(n+1)⁵ − (n+1) − (n⁵ − n)` is *always* a
      multiple of 5 with no remainder, i.e. divisibility is preserved additively.
  (H6, counter-intuitive) `a⁵ ≡ a (mod 10)`, so `a⁵` always ends in the same
      decimal digit as `a`  [follows from H2 since 10 ∣ 30-adjacent reasoning /
      2 and 5 both divide].
Experiment (Experimenter): Computed `a⁵ − a` for `a = 0..8`:
  0, 0, 30, 240, 1020, 3120, 7770, 16800, 32760 — every entry divisible by 30,
  hence by 5 (supports H1, H2). Digit check: `2⁵=32`, `3⁵=243`, `7⁵=16807`,
  `8⁵=32768` all share last digit with base (supports H6).
Analysis (Analyst): H5 is the engine of the elementary induction and is exactly
  the identity `ring` verifies. H1 survives via induction; H3 via `ring`.
Critique (Critic): The proof must not collapse to `decide` over `ZMod 5` (that
  is the pre-existing catalog proof). We deliberately use integer induction so
  the argument is a genuine inductive propagation, not a finite residue check.
Synthesis (PI): `five_dvd_pow_five_sub_self` (induction) + `pow_five_sub_self_factor`.
-/

namespace Bridges.FermatFivePrimary

/-- **Key inductive identity.** Incrementing the argument changes `a⁵ − a` by an
explicit multiple of `5`.  This is the additive-preservation fact (H5) that
drives the induction. -/
theorem step_identity (n : ℤ) :
    (n + 1) ^ 5 - (n + 1) = (n ^ 5 - n) + 5 * (n ^ 4 + 2 * n ^ 3 + 2 * n ^ 2 + n) := by
  ring

/-- **Factorisation of `a⁵ − a`.**  The defect splits off three consecutive
integers `a−1, a, a+1` together with the factor `a²+1`.  Proven purely by `ring`;
it is reused to obtain divisibility by `2` and `3` (and hence `30`). -/
theorem pow_five_sub_self_factor (a : ℤ) :
    a ^ 5 - a = (a - 1) * a * (a + 1) * (a ^ 2 + 1) := by
  ring

/-- **Fermat's Little Theorem for `p = 5` (target conjecture).**
For every integer `a`, `a⁵ − a` is an integer multiple of `5`.

The proof is an integer induction: the base case `a = 0` is immediate, and both
the ascending and descending steps rewrite via `step_identity`, peeling off an
explicit `5·(…)` and appealing to the induction hypothesis with
`dvd_add` / `dvd_sub`. -/
theorem five_dvd_pow_five_sub_self (a : ℤ) : (5 : ℤ) ∣ a ^ 5 - a := by
  induction a using Int.induction_on with
  | zero => decide
  | succ n ih =>
      -- `(n+1)⁵ − (n+1) = (n⁵ − n) + 5·(…)`
      rw [step_identity n]
      exact dvd_add ih ⟨n ^ 4 + 2 * n ^ 3 + 2 * n ^ 2 + n, rfl⟩
  | pred n ih =>
      -- descending step: subtract the explicit multiple of 5 instead
      have h : (-(n : ℤ) - 1) ^ 5 - (-(n : ℤ) - 1)
          = (((-n : ℤ) ^ 5) - (-n)) - 5 * (n ^ 4 + 2 * n ^ 3 + 2 * n ^ 2 + n) := by
        ring
      rw [h]
      exact dvd_sub ih ⟨n ^ 4 + 2 * n ^ 3 + 2 * n ^ 2 + n, rfl⟩

/-- Restatement as a congruence: `a⁵ ≡ a (mod 5)`. -/
theorem pow_five_congr (a : ℤ) : a ^ 5 ≡ a [ZMOD 5] :=
  (Int.modEq_iff_dvd.mpr (by simpa using (five_dvd_pow_five_sub_self a))).symm

end Bridges.FermatFivePrimary