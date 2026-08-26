/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Efficient reflection: balanced evaluation and the drop-below checker

Two independent bottlenecks limit how far a *kernel-checked* certificate can
reach, and this file removes both, with soundness proofs for each.

**Bottleneck 1 — evaluation shape.** `checkFrom` recurses linearly, so the
kernel's evaluation stack grows with the window and overflows well before
`10^5` inputs.  `checkPow2` evaluates the same conjunction by balanced binary
splitting: `2^d` inputs at stack depth `d`.  `checkPow2_eq_checkFrom` proves the
two agree, so nothing is added to the trusted base;
`checkPow2_eq_arrayAll` exhibits the same value as an `Array.range'` traversal.

**Bottleneck 2 — work per input.** Running each orbit all the way to `1` costs
`≈ 10^2` accelerated steps.  `dropsBelow` instead stops as soon as the orbit
falls below its starting point, which by strong induction is all that is needed
— `≈ 4` steps on average.  `dropsBelow_sound` proves the reduction legitimate
and `dropsBelowAux_complete` proves the cheap checker never loses a certificate
the expensive one would have found (relative completeness).

Combining the two with the mod-4 sieve of `CertifiedEvidence.Collatz` gives
`collatz_upTo_131072`: every `n ≤ 131072` reaches `1` under `3n+1`, kernel
verified, from a single `decide +kernel` call — a bound `6553×` the `1..20`
evidence this project started from, and `32×` the reach of the naive checker of
`CertifiedEvidence.Collatz`.

## Lab notes (kernel timings on the machine used)

| checker                              | window       | kernel time |
|--------------------------------------|--------------|-------------|
| `collatzChecker` (orbit to 1, linear) | `[1,1000]`   | ≈ 28 s      |
| `sievedChecker` (mod 4, linear)       | `[1,4000]`   | ≈ 45 s      |
| `sievedDrop` + `checkPow2`            | `[1,131072]` | ≈ 150 s     |

Linear evaluation overflows the kernel stack at roughly `2·10^4` inputs
regardless of the time budget; balanced evaluation does not.
-/

import Mathlib
import MachineLearning.CertifiedEvidence.Collatz

namespace CertifiedEvidence

open CollatzParity

/-! ## §1. Balanced evaluation of a window of length `2^d` -/

/-- Balanced binary evaluation of the bounded conjunction over `2^d` inputs.
Kernel stack depth is `d`, not `2^d`. -/
def checkPow2 (p : ℕ → Bool) (lo : ℕ) : ℕ → Bool
  | 0 => p lo
  | d + 1 => checkPow2 p lo d && checkPow2 p (lo + 2 ^ d) d

/-- Balanced evaluation computes exactly the linear bounded conjunction. -/
theorem checkPow2_eq_checkFrom (p : ℕ → Bool) :
    ∀ (d lo : ℕ), checkPow2 p lo d = checkFrom p lo (2 ^ d) := by
  intro d
  induction d with
  | zero =>
      intro lo
      show p lo = checkFrom p lo 1
      rw [checkFrom_succ, checkFrom_zero, Bool.and_true]
  | succ d ih =>
      intro lo
      rw [checkPow2, ih lo, ih (lo + 2 ^ d),
        show (2 : ℕ) ^ (d + 1) = 2 ^ d + 2 ^ d by ring, checkFrom_add]

/-- The same value, as an array traversal. -/
theorem checkPow2_eq_arrayAll (p : ℕ → Bool) (d lo : ℕ) :
    checkPow2 p lo d = (Array.range' lo (2 ^ d)).all p := by
  rw [checkPow2_eq_checkFrom, checkFrom_eq_arrayAll]

/-- Soundness of a balanced certificate. -/
theorem of_checkPow2 {p : ℕ → Bool} {lo d k : ℕ} (h : checkPow2 p lo d = true)
    (h1 : lo ≤ k) (h2 : k < lo + 2 ^ d) : p k = true := by
  rw [checkPow2_eq_checkFrom] at h
  exact (checkFrom_eq_true_iff p (2 ^ d) lo).mp h k h1 h2

/-! ## §2. The drop-below checker -/

/-- Iterate `T` from `x`, succeeding as soon as the orbit falls below `n`. -/
def dropsBelowAux : ℕ → ℕ → ℕ → Bool
  | 0, _, _ => false
  | f + 1, n, x => if x < n then true else dropsBelowAux f n (T x)

/-- `dropsBelow fuel n` succeeds when the orbit of `n` falls back below `n`. -/
def dropsBelow (fuel n : ℕ) : Bool := dropsBelowAux fuel n (T n)

theorem dropsBelowAux_sound : ∀ (f n x : ℕ), dropsBelowAux f n x = true → ∃ j, T^[j] x < n := by
  intro f
  induction f with
  | zero => intro n x h; exact absurd h (by simp [dropsBelowAux])
  | succ f ih =>
      intro n x h
      by_cases hx : x < n
      · exact ⟨0, by simpa using hx⟩
      · rw [dropsBelowAux, if_neg hx] at h
        obtain ⟨j, hj⟩ := ih n (T x) h
        exact ⟨j + 1, by rwa [Function.iterate_succ_apply]⟩

/-- **Soundness of the cheap checker**: success produces a genuine strict descent
of the orbit after at least one step. -/
theorem dropsBelow_sound {fuel n : ℕ} (h : dropsBelow fuel n = true) :
    ∃ j, 1 ≤ j ∧ T^[j] n < n := by
  obtain ⟨j, hj⟩ := dropsBelowAux_sound fuel n (T n) h
  exact ⟨j + 1, by omega, by rwa [Function.iterate_succ_apply]⟩

/-- **Relative completeness**: whenever a descent exists within the budget, the
cheap checker finds it. Nothing certifiable by the expensive orbit-to-`1`
checker is lost by switching to `dropsBelow`. -/
theorem dropsBelowAux_complete : ∀ (f n x j : ℕ), j < f → T^[j] x < n →
    dropsBelowAux f n x = true := by
  intro f
  induction f with
  | zero => intro n x j hj _; omega
  | succ f ih =>
      intro n x j hj hlt
      by_cases hx : x < n
      · simp [dropsBelowAux, hx]
      · rw [dropsBelowAux, if_neg hx]
        obtain ⟨j', rfl⟩ : ∃ j', j = j' + 1 := by
          cases j with
          | zero => exact absurd (by simpa using hlt) hx
          | succ j' => exact ⟨j', rfl⟩
        exact ih n (T x) j' (by omega) (by rwa [Function.iterate_succ_apply] at hlt)

/-! ## §3. The sieved drop-below certificate -/

/-- The production checker: skip everything outside `3 mod 4`, and on the
remaining quarter only look for a drop below the starting point. -/
def sievedDrop (fuel n : ℕ) : Bool := if n % 4 = 3 then dropsBelow fuel n else true

/-- **Soundness of the production checker.** Its success on `[1,B]` proves that
every `n ≤ B` reaches `1`: even inputs halve, `4m+1` descends to `3m+1`, and
inputs `≡ 3 (mod 4)` descend by the certified drop. -/
theorem sievedDrop_certifies (fuel B : ℕ)
    (h : ∀ n, 1 ≤ n → n ≤ B → sievedDrop fuel n = true) :
    ∀ n, 1 ≤ n → n ≤ B → ReachesOne n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      intro hn hnB
      rcases eq_or_lt_of_le hn with rfl | hn1
      · exact reachesOne_one
      · by_cases hpar : n % 2 = 0
        · have hhalf : ReachesOne (n / 2) := ih (n / 2) (by omega) (by omega) (by omega)
          have hstep := reachesOne_of_T (n := n)
          rw [T_even hpar] at hstep
          exact hstep hhalf
        · rcases (by omega : n % 4 = 1 ∨ n % 4 = 3) with h1 | h3
          · obtain ⟨m, rfl⟩ : ∃ m, n = 4 * m + 1 := ⟨n / 4, by omega⟩
            exact reachesOne_of_mod4_one (ih (3 * m + 1) (by omega) (by omega) (by omega))
          · have hchk : dropsBelow fuel n = true := by
              have := h n hn hnB
              rwa [sievedDrop, if_pos h3] at this
            obtain ⟨j, -, hj⟩ := dropsBelow_sound hchk
            exact reachesOne_of_iterate
              (ih (T^[j] n) hj (one_le_iterate_T j n hn) (le_trans hj.le hnB))

set_option maxRecDepth 10000 in
/-- The kernel certificate: `2^17 = 131072` inputs, balanced evaluation, cheap
per-input test. -/
theorem fast_evidence : checkPow2 (sievedDrop 400) 1 17 = true := by decide +kernel

/-- **The strengthened certified bound.** Every `n ≤ 131072` reaches `1` under
the classical `3n+1` map, kernel verified. -/
theorem collatz_upTo_131072 (n : ℕ) (h1 : 1 ≤ n) (h2 : n ≤ 131072) : CollatzReachesOne n := by
  refine reachesOne_collatz_of_T (sievedDrop_certifies 400 131072 (fun m hm1 hm2 => ?_) n h1 h2)
  exact of_checkPow2 fast_evidence hm1 (by norm_num; omega)

/-- The certified bound of this file strictly extends every earlier one in the
project, and all of them remain, by `collatz_evidence_is_not_a_proof`, evidence
rather than proof. -/
theorem certified_bounds_chain :
    (∀ n, 1 ≤ n → n ≤ 20 → CollatzReachesOne n) ∧
      (∀ n, 1 ≤ n → n ≤ 4000 → CollatzReachesOne n) ∧
      (∀ n, 1 ≤ n → n ≤ 131072 → CollatzReachesOne n) :=
  ⟨collatz_upTo_20, collatz_upTo_4000, collatz_upTo_131072⟩

end CertifiedEvidence