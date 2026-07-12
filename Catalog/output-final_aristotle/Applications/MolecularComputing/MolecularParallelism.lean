/-
# Molecular parallelism gives only a constant-factor speedup

A recurring hope for "DNA computers" is that the astronomical number of molecules
in a test tube provides *exponential* parallelism, letting us brute-force
NP-complete problems for free. This file formalizes the elementary but decisive
reason this fails: **molecular parallelism buys at most a factor-`p` speedup,
where `p` is the number of molecules that operate at once — and `p` is bounded by
the available volume.** The work still has to be done, and the molecules still
have to be prepared.

We model a computation abstractly by its **work** `W` (the number of primitive
operations that must be performed) and a **schedule** on `T` time steps, where at
each step at most `p` molecules act, i.e. at most `p` operations happen. The
schedule `ops t` records how many operations happen at step `t`.

Main results:

* `work_time_bound` — with at most `p` operations per step, completing `W`
  operations forces `W ≤ T * p`. (Total throughput is bounded by area of the
  time × parallelism rectangle.)
* `parallel_time_lower_bound` — hence `⌈W / p⌉ ≤ T`; the parallel running time is
  bounded below by the work divided by the parallelism.
* `speedup_at_most_p` — the sequential time `W` satisfies `W ≤ p * T`, i.e. the
  speedup of a `p`-fold parallel machine over the sequential one is at most `p`.
  **Constant factor, never more.**
* `volume_bounded_speedup` — if only `P` molecules fit in the device
  (`p ≤ P`, a volume bound), then `W ≤ P * T`.
* `no_exponential_speedup` — the punchline: for a family of problems with
  *exponential* work `2^n ≤ W n` run on a fixed-volume device (`p ≤ P`), the
  parallel time is **unbounded** — no constant time bound can hold. Molecular
  parallelism does *not* collapse exponential cost to constant time.

These are theorems over `ℕ`; nothing here is asymptotic hand-waving.
-/
import Mathlib

open scoped BigOperators

namespace MolecularComputing

/-- **Work–time bound.** If at each of `T` steps at most `p` operations occur
(`ops t ≤ p`) and the schedule performs at least `W` operations in total, then
`W ≤ T * p`: throughput cannot exceed the time × parallelism budget. -/
theorem work_time_bound (p W T : ℕ) (ops : Fin T → ℕ)
    (hbound : ∀ t, ops t ≤ p) (hdone : W ≤ ∑ t, ops t) : W ≤ T * p := by
  calc W ≤ ∑ t, ops t := hdone
    _ ≤ ∑ _t : Fin T, p := Finset.sum_le_sum (fun t _ => hbound t)
    _ = T * p := by simp [Finset.sum_const, Finset.card_univ, mul_comm]

/-- **Parallel time lower bound.** With `p ≥ 1` molecules operating in parallel,
completing `W` work needs at least `⌈W / p⌉` steps: `W / p ≤ T`. -/
theorem parallel_time_lower_bound (p W T : ℕ) (hp : 0 < p) (ops : Fin T → ℕ)
    (hbound : ∀ t, ops t ≤ p) (hdone : W ≤ ∑ t, ops t) : W / p ≤ T := by
  have h : W ≤ T * p := work_time_bound p W T ops hbound hdone
  have := Nat.div_le_div_right (c := p) h
  rwa [Nat.mul_div_cancel _ hp] at this

/-- **The speedup is at most `p`.** The sequential running time is exactly the
work `W` (one operation per step). A `p`-fold parallel machine needs `T` steps
with `W ≤ p * T`, so the sequential time is at most `p` times the parallel time:
the speedup can never exceed the parallelism `p`. -/
theorem speedup_at_most_p (p W T : ℕ) (ops : Fin T → ℕ)
    (hbound : ∀ t, ops t ≤ p) (hdone : W ≤ ∑ t, ops t) : W ≤ p * T := by
  have h : W ≤ T * p := work_time_bound p W T ops hbound hdone
  rwa [Nat.mul_comm] at h

/-- **Volume-bounded speedup.** If the device holds at most `P` simultaneously
active molecules (`p ≤ P`, a bound proportional to volume), then `W ≤ P * T`. The
achievable parallelism — and hence speedup — is capped by the volume. -/
theorem volume_bounded_speedup (p P W T : ℕ) (hpP : p ≤ P) (ops : Fin T → ℕ)
    (hbound : ∀ t, ops t ≤ p) (hdone : W ≤ ∑ t, ops t) : W ≤ P * T := by
  have h : W ≤ p * T := speedup_at_most_p p W T ops hbound hdone
  calc W ≤ p * T := h
    _ ≤ P * T := Nat.mul_le_mul_right T hpP

/-- **No exponential speedup.** Consider a family of problems indexed by input
size `n` whose *work* is at least `2^n`, run on a device with a fixed volume so
that at most `P` molecules ever act at once (`Tpar n` is the parallel time and
`2^n ≤ P * Tpar n` for every `n`). Then the parallel running time is **unbounded**:
no constant `C` bounds `Tpar n` for all `n`.

Interpretation: molecular parallelism provides a constant-factor (`P`-fold)
speedup at best; it cannot turn exponential work into constant — or even
polynomial — time, because the molecules that would explore the search space
still have to be prepared, and only `P` of them fit. -/
theorem no_exponential_speedup (P : ℕ) (Tpar : ℕ → ℕ)
    (h : ∀ n, 2 ^ n ≤ P * Tpar n) : ¬ ∃ C, ∀ n, Tpar n ≤ C := by
  rintro ⟨C, hC⟩
  obtain ⟨n, hn⟩ := pow_unbounded_of_one_lt (P * C) (by norm_num : (1 : ℕ) < 2)
  have : 2 ^ n ≤ P * C := le_trans (h n) (Nat.mul_le_mul_left P (hC n))
  omega

/-- Quantitative form: with a fixed molecule budget `P ≥ 1` and exponential work,
the parallel time grows at least like `2^n / P`. -/
theorem parallel_time_exponential (P : ℕ) (hP : 0 < P) (Tpar : ℕ → ℕ)
    (h : ∀ n, 2 ^ n ≤ P * Tpar n) (n : ℕ) : 2 ^ n / P ≤ Tpar n := by
  have hn := h n
  have := Nat.div_le_div_right (c := P) hn
  rwa [Nat.mul_div_cancel_left _ hP] at this

end MolecularComputing