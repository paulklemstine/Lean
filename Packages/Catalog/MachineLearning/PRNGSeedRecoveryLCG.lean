/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Seed Recovery for Linear Congruential Generators

Second family in the "detect PRNG output and store only the seed" programme
(compare `MachineLearning.PRNGSeedRecoveryLFSR` for shift registers and
`MachineLearning.PRNGCompressionBound` for the counting-side limits).

An LCG over a commutative ring `R` iterates `x ↦ a * x + b`.

## Main results

* `lcgSeq_isLinRec` — **fingerprinting bridge**: *every* LCG stream satisfies the
  order-`2` linear recurrence with taps `(-a, 1 + a)`.  So the Berlekamp–Massey
  machinery of the LFSR file already detects the whole LCG family, and no
  separate detector is needed.
* `lcgUnstep_iterate_seed` — **backward seed recovery**: with an invertible
  multiplier, the seed is recovered from the state at time `n` by `n` inverse
  steps, exactly.
* `lcgStep_bijective`, `exists_lcg_period`, `lcgSeq_add_period` — with an
  invertible multiplier on a finite ring the orbit is *purely* periodic.
* `lcg_seed_reachable_forward` — consequently the seed is recoverable by running
  the generator *forward* from any observed state: no inversion is needed.
* `lcg_prefix_card_le`, `exists_non_lcg_stream` — parameter counting: at most
  `m ^ 3` streams of any length are LCG streams over `ℤ/m`, so LCG-compressible
  data is vanishingly rare and a detector's false-positive budget is `m^{3-N}`.

## Application keywords

linear congruential generator, seed recovery, modular inversion, pure
periodicity, PRNG fingerprinting, compression
-/

import MachineLearning.PRNGSeedRecoveryLFSR

open Finset

namespace PRNGSeed

section CommRing

variable {R : Type*} [CommRing R]

/-- One step of a linear congruential generator. -/
def lcgStep (a b : R) (x : R) : R := a * x + b

/-- The output stream of a linear congruential generator from seed `s`. -/
def lcgSeq (a b s : R) : ℕ → R
  | 0 => s
  | n + 1 => lcgStep a b (lcgSeq a b s n)

@[simp] lemma lcgSeq_zero (a b s : R) : lcgSeq a b s 0 = s := rfl

@[simp] lemma lcgSeq_succ (a b s : R) (n : ℕ) :
    lcgSeq a b s (n + 1) = a * lcgSeq a b s n + b := rfl

lemma lcgSeq_eq_iterate (a b s : R) (n : ℕ) : lcgSeq a b s n = (lcgStep a b)^[n] s := by
  induction n with
  | zero => rfl
  | succ n ih => rw [Function.iterate_succ_apply', ← ih]; rfl

/-- Restarting the generator at a later state continues the same stream. -/
lemma lcgSeq_add (a b s : R) (n k : ℕ) :
    lcgSeq a b (lcgSeq a b s n) k = lcgSeq a b s (n + k) := by
  induction k with
  | zero => rfl
  | succ k ih => rw [lcgSeq_succ, ih, ← lcgSeq_succ, Nat.add_assoc]

/-- **Fingerprinting bridge: every LCG is an order-2 LFSR.**  The additive
constant is eliminated by differencing, so an LCG stream satisfies the linear
recurrence `x (n+2) = (1 + a) * x (n+1) - a * x n`.  Hence the linear-recurrence
detector of `PRNGSeedRecoveryLFSR` fingerprints LCG data as well, and its
uniqueness theory transfers verbatim. -/
theorem lcgSeq_isLinRec (a b s : R) :
    IsLinRec 2 ![-a, 1 + a] (lcgSeq a b s) := by
  intro n
  have h0 : (n : ℕ) + 2 = (n + 1) + 1 := by omega
  rw [h0, lcgSeq_succ, lcgSeq_succ]
  simp [Fin.sum_univ_two]
  ring

/-- Any stream satisfying the LCG recursion *is* the LCG stream from its own
first symbol: exact reproduction from the seed. -/
theorem lcg_seed_recovery {a b : R} {x : ℕ → R} (hx : ∀ n, x (n + 1) = a * x n + b) :
    x = lcgSeq a b (x 0) := by
  funext n
  induction n with
  | zero => rfl
  | succ n ih => rw [hx n, lcgSeq_succ, ih]

end CommRing

section Invertible

variable {R : Type*} [CommRing R] {a b : R}

/-- The inverse of one LCG step, for an invertible multiplier `a` with inverse `ai`. -/
def lcgUnstep (ai b : R) (y : R) : R := ai * (y - b)

lemma lcgUnstep_lcgStep (hai : ai * a = 1) (x : R) :
    lcgUnstep ai b (lcgStep a b x) = x := by
  simp only [lcgUnstep, lcgStep, add_sub_cancel_right, ← mul_assoc, hai, one_mul]

lemma lcgStep_lcgUnstep (hai : a * ai = 1) (y : R) :
    lcgStep a b (lcgUnstep ai b y) = y := by
  simp only [lcgUnstep, lcgStep, ← mul_assoc, hai, one_mul, sub_add_cancel]

/-- With an invertible multiplier the LCG step is a bijection of the state space. -/
theorem lcgStep_bijective {ai : R} (hai : ai * a = 1) :
    Function.Bijective (lcgStep a b) := by
  have h' : a * ai = 1 := by rw [mul_comm]; exact hai
  exact ⟨Function.LeftInverse.injective (lcgUnstep_lcgStep hai),
    Function.RightInverse.surjective (fun y => lcgStep_lcgUnstep h' y)⟩

/-- **Backward seed recovery.**  With an invertible multiplier, applying `n`
inverse steps to the state observed at time `n` returns *exactly* the seed.
This is the solver-based inversion step of the recovery pipeline, and it is
exact — no search and no approximation. -/
theorem lcgUnstep_iterate_seed {ai : R} (hai : ai * a = 1) (s : R) (n : ℕ) :
    (lcgUnstep ai b)^[n] (lcgSeq a b s n) = s := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [Function.iterate_succ_apply]
    have : lcgUnstep ai b (lcgSeq a b s (n + 1)) = lcgSeq a b s n := by
      rw [show lcgSeq a b s (n + 1) = lcgStep a b (lcgSeq a b s n) from rfl,
        lcgUnstep_lcgStep hai]
    rw [this, ih]

/-- Pure periodicity of the output stream, given a return time `p` for states. -/
theorem lcgSeq_add_period (s : R) {p : ℕ}
    (hp : ∀ x : R, (lcgStep a b)^[p] x = x) (n : ℕ) :
    lcgSeq a b s (n + p) = lcgSeq a b s n := by
  rw [lcgSeq_eq_iterate, lcgSeq_eq_iterate, add_comm n p, Function.iterate_add_apply, hp]

/-- Iterating pure periodicity: the stream returns to the seed at every multiple
of the period. -/
lemma lcgSeq_mul_period (s : R) {p : ℕ}
    (hp : ∀ x : R, (lcgStep a b)^[p] x = x) (k : ℕ) :
    lcgSeq a b s (k * p) = s := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hk : (k + 1) * p = k * p + p := by ring
    rw [hk, lcgSeq_add_period s hp, ih]

variable [Fintype R]

/-- On a finite state space an invertible multiplier makes the orbit purely
periodic: some positive `p` returns every state to itself. -/
theorem exists_lcg_period {ai : R} (hai : ai * a = 1) :
    ∃ p : ℕ, 0 < p ∧ ∀ x : R, (lcgStep a b)^[p] x = x := by
  let e : Equiv.Perm R := Equiv.ofBijective _ (lcgStep_bijective (b := b) hai)
  refine ⟨orderOf e, orderOf_pos e, fun x => ?_⟩
  have h1 : e ^ orderOf e = 1 := pow_orderOf_eq_one e
  have h2 : ⇑(e ^ orderOf e) = (⇑e)^[orderOf e] := by simp
  have h3 : (⇑e)^[orderOf e] x = x := by rw [← h2, h1]; rfl
  exact h3

/-- **Forward seed recovery.**  On a finite state space with invertible
multiplier, the seed is reachable from *any* observed state by running the
generator forward: an attacker (or a compressor) never needs the inverse map,
only the generator itself.  This is the constructive core of "recover the seed,
then verify by exact replay". -/
theorem lcg_seed_reachable_forward {ai : R} (hai : ai * a = 1) (s : R) (n : ℕ) :
    ∃ k : ℕ, lcgSeq a b (lcgSeq a b s n) k = s := by
  obtain ⟨p, hp0, hp⟩ := exists_lcg_period (b := b) hai
  refine ⟨n * p - n, ?_⟩
  rw [lcgSeq_add]
  have hle : n ≤ n * p := Nat.le_mul_of_pos_right n hp0
  rw [show n + (n * p - n) = n * p by omega]
  exact lcgSeq_mul_period s hp n

end Invertible

section Counting

variable (m N : ℕ) [NeZero m]

/-- The set of length-`N` prefixes over `ℤ/m` that some LCG can produce. -/
noncomputable def lcgPrefixes : Finset (Fin N → ZMod m) :=
  (Finset.univ : Finset (ZMod m × ZMod m × ZMod m)).image
    fun t => fun i : Fin N => lcgSeq t.1 t.2.1 t.2.2 (i : ℕ)

/-- **Three parameters, three symbols' worth of information.**  Whatever the
length `N`, at most `m ^ 3` streams over `ℤ/m` are LCG streams. -/
theorem lcg_prefix_card_le : (lcgPrefixes m N).card ≤ m ^ 3 := by
  classical
  refine le_trans (Finset.card_image_le) ?_
  simp [Finset.card_univ, ZMod.card, pow_succ, mul_comm]

/-- **Detection is meaningful: most data is not LCG data.**  As soon as
`3 < N` and `2 ≤ m`, some stream over `ℤ/m` is produced by no LCG at all, so a
sound detector must reject it: the `m ^ 3` seed-compressible streams are a
`m ^ (3 - N)` fraction of the `m ^ N` possible ones. -/
theorem exists_non_lcg_stream (hm : 2 ≤ m) (hN : 3 < N) :
    ∃ w : Fin N → ZMod m, w ∉ lcgPrefixes m N := by
  classical
  by_contra hcon
  push_neg at hcon
  have huniv : (Finset.univ : Finset (Fin N → ZMod m)) ⊆ lcgPrefixes m N :=
    fun w _ => hcon w
  have hcard : (m : ℕ) ^ N ≤ m ^ 3 := by
    have := le_trans (Finset.card_le_card huniv) (lcg_prefix_card_le m N)
    simpa [Finset.card_univ, ZMod.card] using this
  have : (m : ℕ) ^ 3 < m ^ N := Nat.pow_lt_pow_right (by omega) hN
  omega

end Counting

end PRNGSeed