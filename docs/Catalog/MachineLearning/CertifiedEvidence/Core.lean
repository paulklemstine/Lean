/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A verified reflection kernel for bounded universal statements

Certified computation in a proof assistant proceeds in two steps: a *checker*
`c : ℕ → Bool` is evaluated by the kernel on a finite window, and a *soundness
theorem* converts the resulting `true` into a mathematical statement.  This file
builds the reflection layer once and for all, with every law an efficient
implementation needs:

* `checkFrom` / `checkRange` — the bounded conjunction `⋀_{lo ≤ k ≤ hi} p k`,
  written as a structurally recursive `Bool` program the kernel can evaluate.
* `checkRange_eq_true_iff` — the soundness *and* completeness bridge.
* `checkFrom_add`, `checkRange_glue` — the composition law that makes
  divide-and-conquer (chunked, parallel, or resumable) certification correct:
  a certificate for `[lo, hi]` is exactly a pair of certificates for
  `[lo, mid]` and `[mid+1, hi]`.
* `checkFrom_eq_listAll`, `checkFrom_eq_arrayAll` — the same predicate computed
  by `List.range'`/`Array` traversal, so a fast array implementation can be
  substituted for the naive recursion without enlarging the trusted base.
* `firstFail` — certificate *extraction*: a failing check returns an explicit
  counterexample together with a proof that it is one.

Nothing here is specific to a particular conjecture; the files
`CertifiedEvidence.Insufficiency`, `CertifiedEvidence.Sufficiency` and
`CertifiedEvidence.Collatz` use this kernel to delimit exactly what finite
computation can and cannot prove.
-/

import Mathlib

namespace CertifiedEvidence

/-! ## §1. The bounded conjunction -/

/-- `checkFrom p lo n` is `true` iff `p` holds at each of `lo, lo+1, …, lo+n-1`.
Structural recursion on the *length* `n` keeps kernel reduction linear. -/
def checkFrom (p : ℕ → Bool) (lo : ℕ) : ℕ → Bool
  | 0 => true
  | n + 1 => p lo && checkFrom p (lo + 1) n

/-- `checkRange p lo hi` is `true` iff `p` holds on the closed window
`[lo, hi]`. For `hi < lo` the window is empty and the check succeeds. -/
def checkRange (p : ℕ → Bool) (lo hi : ℕ) : Bool := checkFrom p lo (hi + 1 - lo)

@[simp] theorem checkFrom_zero (p : ℕ → Bool) (lo : ℕ) : checkFrom p lo 0 = true := rfl

theorem checkFrom_succ (p : ℕ → Bool) (lo n : ℕ) :
    checkFrom p lo (n + 1) = (p lo && checkFrom p (lo + 1) n) := rfl

/-! ## §2. Soundness and completeness of the checker -/

/-- The reflection bridge for `checkFrom`: kernel evaluation of the `Bool`
program is *equivalent* to the bounded universal statement. -/
theorem checkFrom_eq_true_iff (p : ℕ → Bool) :
    ∀ (n lo : ℕ), checkFrom p lo n = true ↔ ∀ k, lo ≤ k → k < lo + n → p k = true := by
  intro n
  induction n with
  | zero =>
      intro lo
      simp only [checkFrom_zero, true_iff]
      intro k hk hk'
      omega
  | succ n ih =>
      intro lo
      rw [checkFrom_succ, Bool.and_eq_true, ih (lo + 1)]
      constructor
      · rintro ⟨h0, h1⟩ k hk hk'
        rcases Nat.eq_or_lt_of_le hk with rfl | hlt
        · exact h0
        · exact h1 k hlt (by omega)
      · intro h
        refine ⟨h lo le_rfl (by omega), fun k hk hk' => h k (by omega) (by omega)⟩

/-- The reflection bridge for a closed window. -/
theorem checkRange_eq_true_iff (p : ℕ → Bool) (lo hi : ℕ) :
    checkRange p lo hi = true ↔ ∀ k, lo ≤ k → k ≤ hi → p k = true := by
  rw [checkRange, checkFrom_eq_true_iff]
  constructor
  · intro h k hk hk'
    exact h k hk (by omega)
  · intro h k hk hk'
    exact h k hk (by omega)

/-- Soundness: a kernel-checked window yields the bounded universal statement. -/
theorem of_checkRange {p : ℕ → Bool} {lo hi : ℕ} (h : checkRange p lo hi = true)
    {k : ℕ} (h1 : lo ≤ k) (h2 : k ≤ hi) : p k = true :=
  (checkRange_eq_true_iff p lo hi).mp h k h1 h2

/-- Completeness: a true bounded statement is always certified by the checker. -/
theorem checkRange_of (p : ℕ → Bool) (lo hi : ℕ) (h : ∀ k, lo ≤ k → k ≤ hi → p k = true) :
    checkRange p lo hi = true :=
  (checkRange_eq_true_iff p lo hi).mpr h

/-! ## §3. The composition law: chunked and resumable certification -/

/-- Splitting the length of a check. This is the law that makes chunked,
resumable, or parallel certification correct. -/
theorem checkFrom_add (p : ℕ → Bool) (lo m n : ℕ) :
    checkFrom p lo (m + n) = (checkFrom p lo m && checkFrom p (lo + m) n) := by
  induction m generalizing lo with
  | zero => simp
  | succ m ih =>
      have : lo + (m + 1) = lo + 1 + m := by omega
      rw [show m + 1 + n = (m + n) + 1 by omega, checkFrom_succ, checkFrom_succ,
        ih (lo + 1), this, Bool.and_assoc]

/-- Gluing two adjacent certified windows. -/
theorem checkRange_glue (p : ℕ → Bool) {lo mid hi : ℕ} (h1 : lo ≤ mid + 1) (h2 : mid ≤ hi) :
    checkRange p lo hi = (checkRange p lo mid && checkRange p (mid + 1) hi) := by
  rcases Nat.lt_or_ge hi lo with hlo | hlo
  · have hm : mid + 1 - lo = 0 := by omega
    have hm2 : hi + 1 - lo = 0 := by omega
    have hm3 : hi + 1 - (mid + 1) = 0 := by omega
    simp [checkRange, hm, hm2, hm3]
  · have key : hi + 1 - lo = (mid + 1 - lo) + (hi + 1 - (mid + 1)) := by omega
    have key2 : lo + (mid + 1 - lo) = mid + 1 := Nat.add_sub_cancel' h1
    rw [checkRange, key, checkFrom_add, key2]
    rfl

/-- Certificates restrict to sub-windows. -/
theorem checkRange_mono {p : ℕ → Bool} {lo hi lo' hi' : ℕ} (h : checkRange p lo hi = true)
    (h1 : lo ≤ lo') (h2 : hi' ≤ hi) : checkRange p lo' hi' = true :=
  checkRange_of p lo' hi' fun _ hk hk' => of_checkRange h (le_trans h1 hk) (le_trans hk' h2)

/-- Extending a certificate one step to the right. -/
theorem checkRange_succ_right {p : ℕ → Bool} {lo hi : ℕ} (h : checkRange p lo hi = true)
    (h2 : p (hi + 1) = true) : checkRange p lo (hi + 1) = true := by
  refine checkRange_of p lo (hi + 1) fun k hk hk' => ?_
  rcases Nat.lt_or_ge k (hi + 1) with hlt | hge
  · exact of_checkRange h hk (by omega)
  · have : k = hi + 1 := by omega
    exact this ▸ h2

/-! ## §4. Alternative implementations: list and array traversal -/

/-- The recursion agrees with a `List.range'` traversal. -/
theorem checkFrom_eq_listAll (p : ℕ → Bool) :
    ∀ (n lo : ℕ), checkFrom p lo n = (List.range' lo n).all p := by
  intro n
  induction n with
  | zero => intro lo; simp
  | succ n ih => intro lo; simp [checkFrom_succ, List.range'_succ, ih]

/-- The recursion agrees with an `Array` traversal, so the fast implementation
used for large certificates computes exactly the certified predicate. -/
theorem checkFrom_eq_arrayAll (p : ℕ → Bool) (n lo : ℕ) :
    checkFrom p lo n = (Array.range' lo n).all p := by
  rw [checkFrom_eq_listAll, ← Array.toList_range' (start := lo) (size := n), Array.all_toList]

/-! ## §5. Certificate extraction: explicit counterexamples -/

/-- The first failure of `p` in the window of length `n` starting at `lo`. -/
def firstFail (p : ℕ → Bool) (lo : ℕ) : ℕ → Option ℕ
  | 0 => none
  | n + 1 => if p lo then firstFail p (lo + 1) n else some lo

/-- `firstFail` returns `none` exactly when the window is certified. -/
theorem firstFail_eq_none_iff (p : ℕ → Bool) :
    ∀ (n lo : ℕ), firstFail p lo n = none ↔ checkFrom p lo n = true := by
  intro n
  induction n with
  | zero => intro lo; simp [firstFail]
  | succ n ih =>
      intro lo
      by_cases h : p lo = true
      · simp [firstFail, h, checkFrom_succ, ih (lo + 1)]
      · simp [firstFail, h, checkFrom_succ]

/-- Anything `firstFail` returns really is a counterexample inside the window. -/
theorem firstFail_spec (p : ℕ → Bool) :
    ∀ (n lo k : ℕ), firstFail p lo n = some k → lo ≤ k ∧ k < lo + n ∧ p k = false := by
  intro n
  induction n with
  | zero => intro lo k h; simp [firstFail] at h
  | succ n ih =>
      intro lo k h
      by_cases hp : p lo = true
      · rw [firstFail, if_pos hp] at h
        obtain ⟨h1, h2, h3⟩ := ih (lo + 1) k h
        exact ⟨by omega, by omega, h3⟩
      · rw [firstFail, if_neg hp] at h
        have hk : k = lo := by simpa using h.symm
        subst hk
        exact ⟨le_rfl, by omega, by simpa using hp⟩

/-- A failing check produces an explicit counterexample. -/
theorem exists_counterexample_of_checkRange_false {p : ℕ → Bool} {lo hi : ℕ}
    (h : checkRange p lo hi = false) : ∃ k, lo ≤ k ∧ k ≤ hi ∧ p k = false := by
  by_contra hc
  push_neg at hc
  have : checkRange p lo hi = true := by
    refine checkRange_of p lo hi fun k hk hk' => ?_
    have := hc k hk hk'
    simpa using this
  rw [this] at h
  exact Bool.noConfusion h

end CertifiedEvidence