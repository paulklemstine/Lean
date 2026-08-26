/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# When finite computation *does* prove a universal statement

`CertifiedEvidence.Insufficiency` shows that a finite certificate alone never
entails a universal claim.  The remedy is not more computation but *structure*:
a finite window plus a proof that every larger input reduces to a smaller one.
This file isolates that pattern as a first-class object, proves it is both sound
and — the point of the file — **complete**:

* `DescentCertificate` — a finite verified window `[1,N]` together with a
  reduction `r` that strictly decreases above `N` and transports truth upwards.
* `DescentCertificate.sound` — strong induction turns such a certificate into
  the universal statement.
* `descentCertificate_nonempty_iff` — *every* true universal statement of this
  form admits a descent certificate.  So "finite check + descent" is a complete
  proof system for `∀ n ≥ 1, p n`, in exact contrast with the incompleteness of
  "finite check" alone.
* `periodic_certifies`, `shift_certifies` — the two structural hypotheses that
  occur in practice (periodicity, closure under adding a fixed step) are
  instances of descent.
* Two fully certified universal theorems obtained from tiny kernel checks:
  `pow_five_mod_ten` (period-10 certificate, 10 checked inputs) and
  `mcnugget_ge_eight` with `mcnugget_seven` (a 3-input window plus `+3`-closure
  gives the numerical-semigroup statement and its sharp Frobenius boundary).
-/

import Mathlib
import MachineLearning.CertifiedEvidence.Core

namespace CertifiedEvidence

/-! ## §1. Descent certificates -/

/-- A **descent certificate** for `p`: a kernel-checked initial window `[1,N]`
together with a reduction `reduce` which, above `N`, produces a strictly smaller
positive input whose success implies success at the original input. -/
structure DescentCertificate (p : ℕ → Bool) where
  /-- The size of the finite window that is checked by computation. -/
  bound : ℕ
  /-- The reduction used above the window. -/
  reduce : ℕ → ℕ
  /-- The kernel-checked evidence. -/
  base : checkRange p 1 bound = true
  /-- The reduction stays in the domain of the statement. -/
  reduce_pos : ∀ n, bound < n → 1 ≤ reduce n
  /-- The reduction strictly decreases, so the induction is well founded. -/
  reduce_lt : ∀ n, bound < n → reduce n < n
  /-- Truth is transported from the reduced input back to the original one. -/
  step : ∀ n, bound < n → p (reduce n) = true → p n = true

/-- **Soundness.** A descent certificate proves the universal statement. -/
theorem DescentCertificate.sound {p : ℕ → Bool} (c : DescentCertificate p) :
    ∀ n, 1 ≤ n → p n = true := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      intro hn
      by_cases h : n ≤ c.bound
      · exact of_checkRange c.base hn h
      · push_neg at h
        exact c.step n h (ih (c.reduce n) (c.reduce_lt n h) (c.reduce_pos n h))

/-- **Completeness.** Conversely, every true universal statement has a descent
certificate — a trivial one, but its existence is what makes "finite check plus
descent" a complete proof system, unlike bare finite checking, which by
`finite_check_not_sound` is not even sound. -/
theorem descentCertificate_nonempty_iff (p : ℕ → Bool) :
    Nonempty (DescentCertificate p) ↔ ∀ n, 1 ≤ n → p n = true := by
  constructor
  · rintro ⟨c⟩
    exact c.sound
  · intro h
    refine ⟨{ bound := 1, reduce := fun _ => 1
              base := checkRange_of p 1 1 fun k hk hk' => by
                have : k = 1 := by omega
                exact this ▸ h 1 le_rfl
              reduce_pos := fun _ _ => le_rfl
              reduce_lt := fun n hn => by omega
              step := fun n hn _ => h n (by omega) }⟩

/-! ## §2. Structural hypotheses that yield descent -/

/-- **Periodic certificate.** If `p` has period `T > 0`, checking one full period
proves the universal statement. -/
theorem periodic_certifies {p : ℕ → Bool} {T : ℕ} (hT : 0 < T)
    (hper : ∀ n, p (n + T) = p n) (hbase : checkRange p 1 T = true) :
    ∀ n, 1 ≤ n → p n = true := by
  refine DescentCertificate.sound
    { bound := T, reduce := fun n => n - T, base := hbase
      reduce_pos := fun n hn => by omega
      reduce_lt := fun n hn => by omega
      step := fun n hn h => ?_ }
  have hn' : n - T + T = n := by omega
  rw [← hn', hper]
  exact h

/-- **Shift certificate.** If `p` is closed under adding a fixed step `a` above
`N`, then checking the single window `[N, N+a-1]` of length `a` proves `p` for
all `n ≥ N`.  This is the certification pattern behind numerical semigroups. -/
theorem shift_certifies {p : ℕ → Bool} {N a : ℕ} (ha : 0 < a)
    (hbase : checkRange p N (N + a - 1) = true)
    (hclosed : ∀ n, N ≤ n → p n = true → p (n + a) = true) :
    ∀ n, N ≤ n → p n = true := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
      intro hn
      by_cases h : n ≤ N + a - 1
      · exact of_checkRange hbase hn h
      · push_neg at h
        have hsub : N ≤ n - a := by omega
        have hlt : n - a < n := by omega
        have hback : n - a + a = n := by omega
        have := hclosed (n - a) hsub (ih (n - a) hlt hsub)
        rwa [hback] at this

/-! ## §3. Certified universal theorem I: a period-10 certificate -/

/-- The checker for the last digit of a fifth power. -/
def lastDigitPow5 (n : ℕ) : Bool := decide (n ^ 5 % 10 = n % 10)

theorem lastDigitPow5_periodic (n : ℕ) : lastDigitPow5 (n + 10) = lastDigitPow5 n := by
  have h2 : (n + 10) % 10 = n % 10 := by omega
  have h1 : (n + 10) ^ 5 % 10 = n ^ 5 % 10 := by
    rw [Nat.pow_mod, h2, ← Nat.pow_mod]
  simp [lastDigitPow5, h1, h2]

/-- Ten kernel-checked inputs, plus periodicity, prove a genuinely universal
statement: `n^5` always ends in the same digit as `n`. -/
theorem pow_five_mod_ten (n : ℕ) : n ^ 5 % 10 = n % 10 := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · rfl
  · have := periodic_certifies (T := 10) (by norm_num) lastDigitPow5_periodic (by decide) n hn
    simpa [lastDigitPow5] using this

/-! ## §4. Certified universal theorem II: the numerical semigroup `⟨3,5⟩` -/

/-- The checker for representability as `3x + 5y`: a bounded search over the
possible values of `y`, evaluable by the kernel. -/
def repr35 (n : ℕ) : Bool :=
  (List.range (n + 1)).any (fun y => decide (5 * y ≤ n ∧ (n - 5 * y) % 3 = 0))

theorem repr35_iff (n : ℕ) : repr35 n = true ↔ ∃ x y : ℕ, n = 3 * x + 5 * y := by
  rw [repr35, List.any_eq_true]
  constructor
  · rintro ⟨y, -, hy⟩
    rw [decide_eq_true_iff] at hy
    exact ⟨(n - 5 * y) / 3, y, by omega⟩
  · rintro ⟨x, y, h⟩
    refine ⟨y, List.mem_range.mpr (by omega), ?_⟩
    rw [decide_eq_true_iff]
    omega

theorem repr35_closed (n : ℕ) (h : repr35 n = true) : repr35 (n + 3) = true := by
  obtain ⟨x, y, hxy⟩ := (repr35_iff n).mp h
  exact (repr35_iff (n + 3)).mpr ⟨x + 1, y, by omega⟩

/-- **Chicken McNugget, certified.** Three kernel-checked inputs (`8, 9, 10`)
plus closure under `+3` prove that every `n ≥ 8` is a non-negative integer
combination of `3` and `5`. -/
theorem mcnugget_ge_eight (n : ℕ) (hn : 8 ≤ n) : ∃ x y : ℕ, n = 3 * x + 5 * y :=
  (repr35_iff n).mp (shift_certifies (N := 8) (a := 3) (by norm_num) (by decide)
    (fun m _ hm => repr35_closed m hm) n hn)

/-- The boundary is sharp: `7` is the Frobenius number of `⟨3,5⟩`. -/
theorem mcnugget_seven : ¬ ∃ x y : ℕ, 7 = 3 * x + 5 * y := by
  intro h
  have h7 : repr35 7 = true := (repr35_iff 7).mpr h
  have hf : repr35 7 = false := by decide
  rw [hf] at h7
  exact Bool.noConfusion h7

/-- The complete picture for `⟨3,5⟩`: the set of gaps is exactly `{1,2,4,7}`,
so certification above the Frobenius number is not merely sufficient but sharp. -/
theorem mcnugget_gaps (n : ℕ) :
    (∃ x y : ℕ, n = 3 * x + 5 * y) ↔ n ∉ ({1, 2, 4, 7} : Finset ℕ) := by
  simp only [Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨x, y, rfl⟩ hmem
    rcases hmem with h | h | h | h <;> omega
  · intro hmem
    push_neg at hmem
    rcases Nat.lt_or_ge n 8 with hlt | hge
    · have hn : n = 0 ∨ n = 3 ∨ n = 5 ∨ n = 6 := by omega
      rcases hn with rfl | rfl | rfl | rfl
      exacts [⟨0, 0, rfl⟩, ⟨1, 0, rfl⟩, ⟨0, 1, rfl⟩, ⟨2, 0, rfl⟩]
    · exact mcnugget_ge_eight n hge

end CertifiedEvidence