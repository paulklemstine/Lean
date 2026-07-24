/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

open Filter Topology

/-!
# Cybernetic-Symbiosis: convergence bounds of mutual adaptive feedback loops

This file develops, from first principles, an exact convergence theory for the *co-adaptation*
of a biological signal and a synthetic decoder in a brain–computer interface (BCI).

## The model

We model the human motor-cortex signal `h n` and the synthetic decoder output `d n` as a pair of
sequences that mutually adapt towards one another with (constant) adaptation gains `a` (human) and
`b` (decoder):

* `h (n+1) = (1 - a) * h n + a * d n`  — the human nudges their signal towards the decoder;
* `d (n+1) = (1 - b) * d n + b * h n`  — the decoder nudges its output towards the human.

Both updates are encoded jointly by `state a b p0 : ℕ → ℝ × ℝ`, with `hum`, `dec` its two
coordinates and `err a b p0 n = hum n - dec n` the *disagreement* (the tracking error of the loop).

## Main results

* `err_step` / `err_closed`: the disagreement obeys the exact linear recursion
  `err (n+1) = (1 - a - b) * err n`, hence `err n = (1 - a - b)^n * err 0`.
  Thus `q := 1 - a - b` is the **contraction factor** of the co-adaptation loop.
* `err_bound`: the exact geometric envelope `|err n| = |1 - a - b|^n * |h0 - d0|`.
* `err_contract`: the one-step contraction identity `|err (n+1)| = |1 - a - b| * |err n|`.
* `err_tendsto`: **convergence** — if `|1 - a - b| < 1` the loop reaches agreement (`err → 0`).
* `invariant`: the weighted quantity `b * h n + a * d n` is conserved along the dynamics.
* `hum_closed` / `dec_closed`: closed forms of the two channels in terms of the invariant and error.
* `hum_tendsto` / `dec_tendsto`: **consensus** — both channels converge to the common value
  `(b * h0 + a * d0) / (a + b)`, a gain-weighted average of the initial states.
* `critical_one_step` / `critical_agree`: **critical damping** — if the *total* gain satisfies
  `a + b = 1`, the loop reaches exact agreement in a *single* step, regardless of the initial gap.
* `err_diverges`: **contrarian instability** — if `|1 - a - b| > 1` and the parties start in
  disagreement, the loop *diverges*: the disagreement grows without bound.
* `counterexample_abs` / `no_convergence`: an explicit **disproof** of the naive conjecture
  "mutual adaptation always yields agreement": with maximal gains `a = b = 1` the loop oscillates
  forever (`|err n| = 1` for all `n`) and never converges.

Together these show the sharp co-evolution law: the loop converges **iff** the total gain lies in
the open window `0 < a + b < 2`, converges *fastest* (indeed instantly) at the critical value
`a + b = 1`, and becomes unstable once `a + b` leaves `[0, 2]`.
-/

namespace CyberneticSymbiosis

/-- Joint state `(human signal, decoder output)` of the co-adaptation loop after `n` rounds,
started from `p0`, with human gain `a` and decoder gain `b`. -/
def state (a b : ℝ) (p0 : ℝ × ℝ) : ℕ → ℝ × ℝ
  | 0 => p0
  | n+1 => ((1-a) * (state a b p0 n).1 + a * (state a b p0 n).2,
            (1-b) * (state a b p0 n).2 + b * (state a b p0 n).1)

/-- The human motor-cortex signal at round `n`. -/
def hum (a b : ℝ) (p0 : ℝ × ℝ) (n : ℕ) : ℝ := (state a b p0 n).1
/-- The synthetic decoder output at round `n`. -/
def dec (a b : ℝ) (p0 : ℝ × ℝ) (n : ℕ) : ℝ := (state a b p0 n).2
/-- The disagreement (tracking error) between human and decoder at round `n`. -/
def err (a b : ℝ) (p0 : ℝ × ℝ) (n : ℕ) : ℝ := hum a b p0 n - dec a b p0 n

/-- **Error recursion.** The disagreement contracts by the exact factor `q = 1 - a - b`
each round. -/
theorem err_step (a b : ℝ) (p0 : ℝ × ℝ) (n : ℕ) :
    err a b p0 (n+1) = (1 - a - b) * err a b p0 n := by
  simp only [err, hum, dec, state]; ring

/-- **Closed form of the error.** `err n = q^n * err 0` with `q = 1 - a - b`. -/
theorem err_closed (a b : ℝ) (p0 : ℝ × ℝ) (n : ℕ) :
    err a b p0 n = (1 - a - b)^n * err a b p0 0 := by
  induction n with
  | zero => simp
  | succ k ih => rw [err_step, ih]; ring

/-- The initial disagreement is the gap between the two starting states. -/
theorem err0 (a b : ℝ) (p0 : ℝ × ℝ) : err a b p0 0 = p0.1 - p0.2 := rfl

/-- **Exact geometric envelope** of the disagreement. -/
theorem err_bound (a b : ℝ) (p0 : ℝ × ℝ) (n : ℕ) :
    |err a b p0 n| = |1 - a - b|^n * |p0.1 - p0.2| := by
  rw [err_closed, err0, abs_mul, abs_pow]

/-- **One-step contraction identity.** -/
theorem err_contract (a b : ℝ) (p0 : ℝ × ℝ) (n : ℕ) :
    |err a b p0 (n+1)| = |1 - a - b| * |err a b p0 n| := by
  rw [err_step, abs_mul]

/-- **Convergence.** If the contraction factor satisfies `|1 - a - b| < 1`, the loop reaches
agreement: the disagreement tends to `0`. -/
theorem err_tendsto (a b : ℝ) (p0 : ℝ × ℝ) (h : |1 - a - b| < 1) :
    Tendsto (fun n => err a b p0 n) atTop (nhds 0) := by
  have : Tendsto (fun n => (1 - a - b)^n * err a b p0 0) atTop (nhds (0 * err a b p0 0)) :=
    (tendsto_pow_atTop_nhds_zero_of_abs_lt_one h).mul_const _
  simpa only [zero_mul, ← err_closed] using this

/-- **Conservation law.** The gain-weighted combination `b * h n + a * d n` is invariant. -/
theorem invariant (a b : ℝ) (p0 : ℝ × ℝ) (n : ℕ) :
    b * hum a b p0 n + a * dec a b p0 n = b * p0.1 + a * p0.2 := by
  induction n with
  | zero => rfl
  | succ k ih => simp only [hum, dec, state] at *; ring_nf; ring_nf at ih; linarith

/-- Closed form of the human channel in terms of the invariant and the disagreement. -/
theorem hum_closed (a b : ℝ) (p0 : ℝ × ℝ) (hab : a + b ≠ 0) (n : ℕ) :
    hum a b p0 n = (b * p0.1 + a * p0.2 + a * err a b p0 n) / (a + b) := by
  rw [eq_div_iff hab]
  have hinv := invariant a b p0 n
  have herr : err a b p0 n = hum a b p0 n - dec a b p0 n := rfl
  rw [herr]; linear_combination hinv

/-- Closed form of the decoder channel in terms of the invariant and the disagreement. -/
theorem dec_closed (a b : ℝ) (p0 : ℝ × ℝ) (hab : a + b ≠ 0) (n : ℕ) :
    dec a b p0 n = (b * p0.1 + a * p0.2 - b * err a b p0 n) / (a + b) := by
  rw [eq_div_iff hab]
  have hinv := invariant a b p0 n
  have herr : err a b p0 n = hum a b p0 n - dec a b p0 n := rfl
  rw [herr]; linear_combination hinv

/-- **Consensus (human channel).** With a convergent loop and nonzero total gain, the human
signal converges to the gain-weighted average `(b * h0 + a * d0) / (a + b)`. -/
theorem hum_tendsto (a b : ℝ) (p0 : ℝ × ℝ) (hab : a + b ≠ 0) (h : |1 - a - b| < 1) :
    Tendsto (fun n => hum a b p0 n) atTop (nhds ((b * p0.1 + a * p0.2)/(a+b))) := by
  have he := err_tendsto a b p0 h
  have : Tendsto (fun n => (b * p0.1 + a * p0.2 + a * err a b p0 n)/(a+b)) atTop
      (nhds ((b * p0.1 + a * p0.2 + a * 0)/(a+b))) :=
    ((tendsto_const_nhds).add (he.const_mul a)).div_const _
  simp only [mul_zero, add_zero] at this
  simpa only [hum_closed a b p0 hab] using this

/-- **Consensus (decoder channel).** The decoder converges to the *same* gain-weighted average,
so human and decoder reach a common equilibrium. -/
theorem dec_tendsto (a b : ℝ) (p0 : ℝ × ℝ) (hab : a + b ≠ 0) (h : |1 - a - b| < 1) :
    Tendsto (fun n => dec a b p0 n) atTop (nhds ((b * p0.1 + a * p0.2)/(a+b))) := by
  have he := err_tendsto a b p0 h
  have : Tendsto (fun n => (b * p0.1 + a * p0.2 - b * err a b p0 n)/(a+b)) atTop
      (nhds ((b * p0.1 + a * p0.2 - b * 0)/(a+b))) :=
    ((tendsto_const_nhds).sub (he.const_mul b)).div_const _
  simp only [mul_zero, sub_zero] at this
  simpa only [dec_closed a b p0 hab] using this

/-- **Critical damping.** If the total adaptation gain is exactly `1`, the disagreement is wiped out
in a single step: `err (n+1) = 0` for every `n`. This is the fastest possible rate (`q = 0`). -/
theorem critical_one_step (a b : ℝ) (p0 : ℝ × ℝ) (hc : a + b = 1) (n : ℕ) :
    err a b p0 (n+1) = 0 := by
  rw [err_step]; have : (1:ℝ) - a - b = 0 := by linarith
  rw [this]; ring

/-- At the critical total gain `a + b = 1`, human and decoder agree exactly from round one on. -/
theorem critical_agree (a b : ℝ) (p0 : ℝ × ℝ) (hc : a + b = 1) (n : ℕ) :
    hum a b p0 (n+1) = dec a b p0 (n+1) := by
  have := critical_one_step a b p0 hc n
  simp only [err] at this; linarith

/-- **Contrarian instability.** If the contraction factor exceeds `1` in magnitude and the parties
start out disagreeing, the co-adaptation loop *diverges*: the disagreement grows without bound.
Over-aggressive mutual adaptation is destabilising. -/
theorem err_diverges (a b : ℝ) (p0 : ℝ × ℝ) (hr : 1 < |1 - a - b|) (hne : p0.1 ≠ p0.2) :
    Tendsto (fun n => |err a b p0 n|) atTop atTop := by
  simp only [err_bound]
  exact Tendsto.atTop_mul_const (by rw [abs_pos]; exact sub_ne_zero.mpr hne)
    (tendsto_pow_atTop_atTop_of_one_lt hr)

/-- Explicit oscillation: with maximal gains `a = b = 1` and initial gap `1`, the disagreement has
constant magnitude `1` for all rounds. -/
theorem counterexample_abs (n : ℕ) : |err 1 1 (1,0) n| = 1 := by
  rw [err_closed, err0]; norm_num [abs_pow]

/-- **Disproof of the naive convergence conjecture.** The claim "any mutual adaptive feedback loop
reaches agreement" is *false*: at the maximal gains `a = b = 1`, the loop oscillates forever and
`err` does not tend to `0`. -/
theorem no_convergence : ¬ Tendsto (fun n => err 1 1 (1,0) n) atTop (nhds 0) := by
  intro hc
  have h1 : Tendsto (fun n => |err 1 1 ((1:ℝ),0) n|) atTop (nhds 0) := by
    simpa using hc.abs
  have h2 : Tendsto (fun n => |err 1 1 ((1:ℝ),0) n|) atTop (nhds 1) := by
    simp only [counterexample_abs]; exact tendsto_const_nhds
  have := tendsto_nhds_unique h1 h2; norm_num at this

end CyberneticSymbiosis