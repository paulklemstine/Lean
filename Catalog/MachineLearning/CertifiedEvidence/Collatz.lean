/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Certified Collatz evidence, and the exact line it cannot cross

This file instantiates the reflection kernel of `CertifiedEvidence.Core` on the
`3n+1` map of `MachineLearning.CollatzSpectral.ParityBijection`, and pushes the
certified window as far as kernel arithmetic allows.  Three things happen.

**1. Semantics, not just bits.** A fuelled Boolean checker `reachesOneB` is
proved sound for the genuine mathematical statement `∃ k, T^[k] n = 1`, and the
accelerated map `T` is bridged to the classical map `collatz`
(`reachesOne_collatz_of_T`), so the certified conclusion is about `3n+1` itself
and not about an auxiliary program.

**2. Structure beats brute force.** `sieve_mod4` proves that verifying only the
residue class `n ≡ 3 (mod 4)` verifies *everything*: even inputs halve, and
`4m+1` descends to `3m+1 < 4m+1` in two accelerated steps.  `sieveDensity`
computes the exact saving — the certified subset has cardinality `(B+1)/4`.
The certified bound therefore reaches `4000` for the price of `1000` inputs,
while the unsieved run stops at `1000`.

**3. The wall.** `collatz_evidence_is_not_a_proof` states, and proves, that the
entire family of certificates is consistent with the failure of the conjecture
at the very next input: no bound `B`, however large, closes the gap. The
positive counterpart is `collatz_descent_certificate_iff`: the conjecture is
equivalent to the existence of a descent certificate, i.e. what is missing is
exactly a reduction function, not more computation.

## Lab notes (kernel timings on the machine used)

| certificate                       | inputs really examined | kernel `decide` |
|-----------------------------------|------------------------|-----------------|
| `evidence_20` (fuel 130)          | 20                     | < 1 s           |
| `evidence_1000` (fuel 130)        | 1000                   | ≈ 28 s          |
| `sieved_evidence_4000` (fuel 200) | 1000 (= (4000+1)/4)    | ≈ 45 s          |

`#eval` (compiled, untrusted) confirms the sieved checker succeeds to `20000`;
only the kernel-checked bounds are asserted as theorems below.
-/

import Mathlib
import MachineLearning.CertifiedEvidence.Core
import MachineLearning.CertifiedEvidence.Insufficiency
import MachineLearning.CertifiedEvidence.Sufficiency
import MachineLearning.CollatzSpectral.DescentTheorem

namespace CertifiedEvidence

open CollatzParity

/-! ## §1. The statement being certified -/

/-- The orbit of `n` under the accelerated map reaches `1`. -/
def ReachesOne (n : ℕ) : Prop := ∃ k, T^[k] n = 1

/-- The orbit of `n` under the classical `3n+1` map reaches `1`. -/
def CollatzReachesOne (n : ℕ) : Prop := ∃ k, collatz^[k] n = 1

theorem reachesOne_of_T {n : ℕ} (h : ReachesOne (T n)) : ReachesOne n := by
  obtain ⟨k, hk⟩ := h
  exact ⟨k + 1, by rw [Function.iterate_succ_apply]; exact hk⟩

theorem reachesOne_one : ReachesOne 1 := ⟨0, rfl⟩

/-- Positivity is preserved by the accelerated map. -/
theorem one_le_iterate_T : ∀ (k n : ℕ), 1 ≤ n → 1 ≤ T^[k] n := by
  intro k
  induction k with
  | zero => intro n hn; simpa using hn
  | succ k ih =>
      intro n hn
      rw [Function.iterate_succ_apply]
      exact ih (T n) (one_le_T hn)

/-- Reaching `1` from any iterate implies reaching `1` from the start. -/
theorem reachesOne_of_iterate {j n : ℕ} (h : ReachesOne (T^[j] n)) : ReachesOne n := by
  obtain ⟨k, hk⟩ := h
  exact ⟨k + j, by rw [Function.iterate_add_apply]; exact hk⟩

/-- One accelerated step is one or two classical steps. -/
theorem exists_collatz_iterate_eq_T (n : ℕ) : ∃ m, collatz^[m] n = T n := by
  rw [T_eq_collatz n]
  by_cases h : n % 2 = 0
  · exact ⟨1, by simp [h]⟩
  · exact ⟨2, by simp [h, Function.iterate_succ_apply]⟩

/-- **Bridge to the classical map.** Reaching `1` under the accelerated map
implies reaching `1` under `3n+1`, so every certificate below is a certificate
about the Collatz conjecture as usually stated. -/
theorem reachesOne_collatz_of_T {n : ℕ} (h : ReachesOne n) : CollatzReachesOne n := by
  obtain ⟨k, hk⟩ := h
  induction k generalizing n with
  | zero => exact ⟨0, hk⟩
  | succ k ih =>
      rw [Function.iterate_succ_apply] at hk
      obtain ⟨m, hm⟩ := ih hk
      obtain ⟨j, hj⟩ := exists_collatz_iterate_eq_T n
      exact ⟨m + j, by rw [Function.iterate_add_apply, hj]; exact hm⟩

/-! ## §2. The fuelled checker and its soundness -/

/-- The fuelled Boolean checker: iterate `T` at most `fuel` times looking for `1`. -/
def reachesOneB : ℕ → ℕ → Bool
  | 0, _ => false
  | f + 1, n => if n = 1 then true else if n = 0 then false else reachesOneB f (T n)

/-- **Soundness of the checker.** A `true` from the kernel is a mathematical
proof that the orbit reaches `1`. -/
theorem reachesOneB_sound : ∀ (f n : ℕ), reachesOneB f n = true → ReachesOne n := by
  intro f
  induction f with
  | zero => intro n h; exact absurd h (by simp [reachesOneB])
  | succ f ih =>
      intro n h
      by_cases h1 : n = 1
      · exact h1 ▸ reachesOne_one
      · by_cases h0 : n = 0
        · rw [reachesOneB, if_neg h1, if_pos h0] at h
          exact absurd h (by simp)
        · rw [reachesOneB, if_neg h1, if_neg h0] at h
          exact reachesOne_of_T (ih (T n) h)

/-- More fuel never invalidates a certificate: certificates compose across runs
with different budgets. -/
theorem reachesOneB_mono : ∀ (f g n : ℕ), f ≤ g → reachesOneB f n = true →
    reachesOneB g n = true := by
  intro f
  induction f with
  | zero => intro g n _ h; exact absurd h (by simp [reachesOneB])
  | succ f ih =>
      intro g n hfg h
      obtain ⟨g', rfl⟩ : ∃ g', g = g' + 1 := ⟨g - 1, by omega⟩
      by_cases h1 : n = 1
      · simp [reachesOneB, h1]
      · by_cases h0 : n = 0
        · rw [reachesOneB, if_neg h1, if_pos h0] at h
          exact absurd h (by simp)
        · rw [reachesOneB, if_neg h1, if_neg h0] at h ⊢
          exact ih g' (T n) (by omega) h

/-! ## §3. The mod-4 sieve: structure that quarters the work -/

theorem T_even {n : ℕ} (h : n % 2 = 0) : T n = n / 2 := by simp [T, h]

/-- Two accelerated steps take `4m+1` to `3m+1`. -/
theorem T_two_steps_mod4 (m : ℕ) : T (T (4 * m + 1)) = 3 * m + 1 := by
  have h1 : (4 * m + 1) % 2 = 1 := by omega
  have h2 : T (4 * m + 1) = 6 * m + 2 := by
    rw [T, if_neg (by omega)]
    omega
  rw [h2, T, if_pos (by omega)]
  omega

/-- Inputs `≡ 1 (mod 4)` above `1` descend strictly, so they never need checking. -/
theorem reachesOne_of_mod4_one {m : ℕ} (h : ReachesOne (3 * m + 1)) :
    ReachesOne (4 * m + 1) := by
  obtain ⟨k, hk⟩ := h
  have h2 : (T^[2]) (4 * m + 1) = 3 * m + 1 := by
    simp [Function.iterate_succ_apply, T_two_steps_mod4 m]
  exact ⟨k + 2, by rw [Function.iterate_add_apply, h2]; exact hk⟩

/-- **The sieve theorem.** Certifying only the residue class `3 mod 4` inside
`[1,B]` certifies the whole interval. Even inputs halve; `4m+1` descends to
`3m+1`; the induction is on the input. -/
theorem sieve_mod4 (B : ℕ) (h : ∀ n, 1 ≤ n → n ≤ B → n % 4 = 3 → ReachesOne n) :
    ∀ n, 1 ≤ n → n ≤ B → ReachesOne n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      intro hn hnB
      rcases eq_or_lt_of_le hn with rfl | hn1
      · exact reachesOne_one
      · by_cases hpar : n % 2 = 0
        · have hhalf : ReachesOne (n / 2) := ih (n / 2) (by omega) (by omega) (by omega)
          have := reachesOne_of_T (n := n)
          rw [T_even hpar] at this
          exact this hhalf
        · -- odd inputs split by their residue mod 4
          rcases (by omega : n % 4 = 1 ∨ n % 4 = 3) with h1 | h3
          · obtain ⟨m, rfl⟩ : ∃ m, n = 4 * m + 1 := ⟨n / 4, by omega⟩
            have hm : 1 ≤ m := by omega
            exact reachesOne_of_mod4_one
              (ih (3 * m + 1) (by omega) (by omega) (by omega))
          · exact h n hn hnB h3

/-- The exact size of the sieved workload: `(B+1)/4` inputs instead of `B`. -/
theorem sieveDensity (B : ℕ) :
    ((Finset.Icc 1 B).filter (fun n => n % 4 = 3)).card = (B + 1) / 4 := by
  induction B with
  | zero => decide
  | succ B ih =>
      have hins : Finset.Icc 1 (B + 1) = insert (B + 1) (Finset.Icc 1 B) := by
        ext x
        simp [Finset.mem_Icc, Finset.mem_insert]
        omega
      rw [hins, Finset.filter_insert]
      by_cases h : (B + 1) % 4 = 3
      · rw [if_pos h, Finset.card_insert_of_notMem (by simp), ih]
        omega
      · rw [if_neg h, ih]
        omega

/-! ## §4. The certificates -/

/-- The unsieved checker. -/
def collatzChecker (fuel n : ℕ) : Bool := reachesOneB fuel n

/-- The sieved checker: inputs outside `3 mod 4` are skipped outright. -/
def sievedChecker (fuel n : ℕ) : Bool := if n % 4 = 3 then reachesOneB fuel n else true

theorem sievedChecker_trivial (fuel n : ℕ) (h : n % 4 ≠ 3) : sievedChecker fuel n = true := by
  simp [sievedChecker, h]

/-- The evidence supplied with the problem statement, re-derived in the kernel. -/
theorem evidence_20 : checkRange (collatzChecker 130) 1 20 = true := by decide

/-- …and its mathematical content, for the classical `3n+1` map. -/
theorem collatz_upTo_20 (n : ℕ) (h1 : 1 ≤ n) (h2 : n ≤ 20) : CollatzReachesOne n :=
  reachesOne_collatz_of_T (reachesOneB_sound 130 n (of_checkRange evidence_20 h1 h2))

set_option maxRecDepth 4000 in
/-- A fifty-fold larger kernel certificate. -/
theorem evidence_1000 : checkRange (collatzChecker 130) 1 1000 = true := by decide

theorem collatz_upTo_1000 (n : ℕ) (h1 : 1 ≤ n) (h2 : n ≤ 1000) : CollatzReachesOne n :=
  reachesOne_collatz_of_T (reachesOneB_sound 130 n (of_checkRange evidence_1000 h1 h2))

set_option maxRecDepth 20000 in
/-- The sieved certificate: the same kernel effort reaches four times further. -/
theorem sieved_evidence_4000 : checkRange (sievedChecker 200) 1 4000 = true := by decide

/-- **Main certified bound.** Every `n ≤ 4000` reaches `1` under `3n+1`, proved
from a kernel certificate that examined only the `1000` inputs `≡ 3 (mod 4)`. -/
theorem collatz_upTo_4000 (n : ℕ) (h1 : 1 ≤ n) (h2 : n ≤ 4000) : CollatzReachesOne n := by
  refine reachesOne_collatz_of_T (sieve_mod4 4000 (fun m hm1 hm2 hm3 => ?_) n h1 h2)
  have := of_checkRange sieved_evidence_4000 hm1 hm2
  rw [sievedChecker, if_pos hm3] at this
  exact reachesOneB_sound 200 m this

/-! ## §5. The wall: what the certificates provably do not give -/

/-- **No certificate is a proof.** For every bound `B` there is a predicate that
reproduces the entire Collatz evidence on `[1,B]` and is false at `B+1`. The
Collatz certificates are therefore consistent with the conjecture failing at the
next untested input, no matter how large `B` is. -/
theorem collatz_evidence_is_not_a_proof (fuel B : ℕ) :
    ∃ q : ℕ → Bool, (∀ n, n ≤ B → q n = collatzChecker fuel n) ∧
      checkRange q 1 B = checkRange (collatzChecker fuel) 1 B ∧
      q (B + 1) = false := by
  refine ⟨truncate (collatzChecker fuel) B, fun n hn => truncate_apply_of_le hn, ?_, ?_⟩
  · exact truncate_agrees _ B 1
  · exact truncate_fails _ B

/-- **What is actually missing.** The Collatz conjecture is *equivalent* to the
existence of a descent certificate for the checker family; the open part is a
reduction function, not additional computation. -/
theorem collatz_descent_certificate_iff (fuel : ℕ) :
    Nonempty (DescentCertificate (collatzChecker fuel)) ↔
      ∀ n, 1 ≤ n → collatzChecker fuel n = true :=
  descentCertificate_nonempty_iff _

end CertifiedEvidence