/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Proof Automation IV: `fib_ring` / `fib_cassini_induct` for Fibonacci identities

Domain: Applications (Proof Automation for the Catalog).

This is the fourth entry in the Catalog's proof-automation series, after
`tropical_simp` (min-plus), `number_theory_decide` (small-case closer) and
`spectral_bound` (Gershgorin).  It targets the algebra of `Nat.fib`.

This file develops a small *proof-automation* toolkit (custom `macro`-based tactics)
that mechanises large families of identities for the Fibonacci numbers `Nat.fib`,
and then uses it to prove a verified suite of classical identities (Cassini,
Catalan, d'Ocagne, doubling formulas, partial-sum formulas, the gcd identity).

The mathematical engine is the *two-term basis principle*: for a fixed base point
`n`, every shifted value `Nat.fib (n + k)` is a fixed `ℕ`-linear combination of the
two "coordinates" `Nat.fib n` and `Nat.fib (n+1)`.  Consequently any *single-base*
polynomial identity in shifted Fibonacci values is a formal polynomial identity in
two free variables and can be decided by `ring` after expansion. This is exactly
what the tactic `fib_ring` does.

Identities that depend on parity (the sign `(-1)^n`) are not formal single-base
identities; they require one induction step, packaged by the tactic
`fib_cassini_induct`.  Genuinely *two-base* identities (d'Ocagne, Catalan) are
reduced to Cassini via the closed-form engine lemma `fib_two_basis`.
-/

namespace Catalog.ProofAutomation.Fibonacci

open Nat Finset

/-! ### Custom tactics -/

/--
`fib_ring` decides a *single-base* polynomial Fibonacci shift identity.

It rewrites every occurrence of `Nat.fib (· + 2)` via `Nat.fib_add_two`
(`simp only` recursively reduces `fib (n + k)` for any literal `k` down to the
two atoms `fib n` and `fib (n+1)`) and then closes the resulting polynomial
identity with `ring`.
-/
macro "fib_ring" : tactic =>
  `(tactic| (simp only [Nat.fib_add_two]; ring))

/--
`fib_omega` is the linear/`ℕ`-subtraction companion of `fib_ring`: it expands all
`fib (· + 2)` and discharges the remaining *linear* goal (including truncated `ℕ`
subtraction and inequalities) with `omega`.
-/
macro "fib_omega" : tactic =>
  `(tactic| (simp only [Nat.fib_add_two]; omega))

/--
`fib_cassini_induct x` performs the one-step Fibonacci induction (on `x`) used for
parity-dependent identities over `ℤ`: base case by `simp`, and inductive step by
expanding `fib (· + 2)`, normalising the casts and ring structure, and finishing
with `linarith` against the induction hypothesis.
-/
macro "fib_cassini_induct" n:ident : tactic =>
  `(tactic|
    (induction $n:ident with
     | zero => simp
     | succ k ih =>
        simp only [Nat.fib_add_two] at *
        push_cast at *
        ring_nf at ih ⊢
        linarith [ih]))

/-! ### The engine: the two-term basis principle -/

-- !-- Lab Notes -- !--
-- HYPOTHESIS: every `fib (n + (k+1))` is a fixed bilinear expression in
-- `(fib k, fib (k+1))` and `(fib n, fib (n+1))`.  This is the content of Mathlib's
-- `Nat.fib_add`, reindexed below into a form convenient for substitution.
-- OUTCOME: `fib_two_basis` is the single rewrite that turns every two-base identity
-- into a polynomial identity in the four atoms `fib k, fib (k+1), fib n, fib (n+1)`.

/-- **Two-term basis principle** (reindexed `Nat.fib_add`).
For all `n k`, `fib (n + (k+1))` is the bilinear form
`fib k * fib n + fib (k+1) * fib (n+1)`. -/
theorem fib_two_basis (n k : ℕ) :
    Nat.fib (n + (k + 1)) = Nat.fib k * Nat.fib n + Nat.fib (k + 1) * Nat.fib (n + 1) := by
  rw [show n + (k + 1) = k + n + 1 from by ring]
  exact Nat.fib_add k n

/-! ### Single-base shift identities (closed by `fib_ring`) -/

-- !-- Lab Notes -- !--
-- EXPERIMENT: feed `fib_ring` a battery of single-base identities of increasing
-- degree.  RESULT: every formal identity in the two atoms is decided instantly.
-- The Fibonacci coefficients (3,5,8,13,...) appear automatically through `ring`.

/-- Linear shift by 5: `fib (n+5) = 3 fib n + 5 fib (n+1)`. -/
theorem fib_shift_five (n : ℕ) :
    Nat.fib (n + 5) = 3 * Nat.fib n + 5 * Nat.fib (n + 1) := by fib_ring

/-- Linear shift by 6: `fib (n+6) = 5 fib n + 8 fib (n+1)`. -/
theorem fib_shift_six (n : ℕ) :
    Nat.fib (n + 6) = 5 * Nat.fib n + 8 * Nat.fib (n + 1) := by fib_ring

/-- Linear shift by 7: `fib (n+7) = 8 fib n + 13 fib (n+1)`. -/
theorem fib_shift_seven (n : ℕ) :
    Nat.fib (n + 7) = 8 * Nat.fib n + 13 * Nat.fib (n + 1) := by fib_ring

/-- A degree-2 single-base identity: a perfect-square expansion. -/
theorem fib_square_shift (n : ℕ) :
    Nat.fib (n + 2) * Nat.fib (n + 2)
      = Nat.fib n * Nat.fib n + 2 * Nat.fib n * Nat.fib (n + 1)
        + Nat.fib (n + 1) * Nat.fib (n + 1) := by fib_ring

/-- A degree-2 mixed identity decided by `fib_ring`:
`fib (n+2)^2 = fib (n+1)^2 + fib n * fib (n+3)` as a *formal* polynomial identity
in the two atoms `fib n`, `fib (n+1)`. -/
theorem fib_mixed_shift (n : ℕ) :
    Nat.fib (n + 2) ^ 2
      = Nat.fib (n + 1) ^ 2 + Nat.fib n * Nat.fib (n + 3) := by fib_ring

/-! ### Parity identities (closed by `fib_cassini_induct`) -/

-- !-- Lab Notes -- !--
-- HYPOTHESIS: `fib_ring` CANNOT prove Cassini's identity, because its right-hand
-- side `(-1)^n` is not a polynomial in `(fib n, fib (n+1))`.  Confirmed: after
-- `simp only [Nat.fib_add_two]` the goal still mentions `(-1)^n`, on which `ring`
-- makes no progress.  FIX: one induction step (`fib_cassini_induct`) suffices,
-- since the sign flips and the polynomial part is handled by `ring_nf`/`linarith`.

/-- **Cassini's identity** over `ℤ`:
`fib (n+2) * fib n - fib (n+1)^2 = (-1)^(n+1)`. -/
theorem cassini (n : ℕ) :
    (Nat.fib (n + 2) : ℤ) * Nat.fib n - (Nat.fib (n + 1)) ^ 2 = (-1) ^ (n + 1) := by
  fib_cassini_induct n

/-- Cassini in the equivalent "squared minus product" orientation:
`fib (n+1)^2 - fib n * fib (n+2) = (-1)^n`. -/
theorem cassini' (n : ℕ) :
    (Nat.fib (n + 1) : ℤ) ^ 2 - (Nat.fib n) * (Nat.fib (n + 2)) = (-1) ^ n := by
  have h := cassini n
  have : ((-1 : ℤ)) ^ (n + 1) = -(-1) ^ n := by ring
  nlinarith [h, this]

/-! ### Doubling formulas (via the engine lemma) -/

-- !-- Lab Notes -- !--
-- EXPERIMENT: the index-doubling formulas are two-base identities (`fib (2n+1)`
-- pairs the base point `n` with itself).  RESULT: a single application of
-- `Nat.fib_add` / `fib_two_basis` followed by `ring` (or `fib_ring`) suffices.

/-- **Doubling (odd):** `fib (2n+1) = fib (n+1)^2 + fib n ^2`. -/
theorem fib_two_mul_add_one (n : ℕ) :
    Nat.fib (2 * n + 1) = Nat.fib (n + 1) ^ 2 + Nat.fib n ^ 2 := by
  have h := Nat.fib_add n n
  rw [show n + n + 1 = 2 * n + 1 from by ring] at h
  rw [h]; ring

/-- **Doubling (even):** `fib (2n) = fib n * (2 fib (n+1) - fib n)` over `ℤ`. -/
theorem fib_two_mul (n : ℕ) :
    (Nat.fib (2 * n) : ℤ) = Nat.fib n * (2 * Nat.fib (n + 1) - Nat.fib n) := by
  cases n with
  | zero => simp
  | succ m =>
    have h := Nat.fib_add m (m + 1)
    rw [show m + (m + 1) + 1 = 2 * (m + 1) from by ring] at h
    rw [h]; push_cast; simp only [Nat.fib_add_two]; push_cast; ring

/-! ### Two-base parity identities (reduced to Cassini) -/

-- !-- Lab Notes -- !--
-- HYPOTHESIS: every signed two-base identity equals a Fibonacci multiple of
-- Cassini.  WORKED EXAMPLES (algebra over the two-term basis):
--   d'Ocagne:  F_{n+k} F_{n+1} - F_{n+k+1} F_n = F_k · (F_{n+1}^2 - F_n F_{n+2})
--                                              = (-1)^n F_k.
--   Catalan:   F_{n+r}^2 - F_n F_{n+2r}        = F_r^2 · (F_{n+1}^2 - F_n F_{n+2})
--                                              = (-1)^n F_r^2.
-- STRATEGY: substitute the closed form `fib_two_basis`, expand with `ring`, and
-- finish with `cassini'`.  These are handed to the automation as the hard cases.

/-- **d'Ocagne's identity** (shifted, sign form):
`fib (n+k) * fib (n+1) - fib (n+k+1) * fib n = (-1)^n * fib k`.

Proof: reduce to Cassini.  For `k = j+1`, substitute the closed form
`fib_two_basis` for both `fib (n+(j+1))` and `fib (n+(j+1)+1)`; the result is
`fib (j+1)` times the Cassini expression `fib (n+1)^2 - fib n * fib (n+2)`. -/
theorem dOcagne (n k : ℕ) :
    (Nat.fib (n + k) : ℤ) * Nat.fib (n + 1) - Nat.fib (n + k + 1) * Nat.fib n
      = (-1) ^ n * Nat.fib k := by
  cases k with
  | zero => simp; ring
  | succ j =>
    have h1 := fib_two_basis n j
    have h2 := fib_two_basis n (j + 1)
    rw [show n + (j + 1 + 1) = n + (j + 1) + 1 from by ring] at h2
    have hj2 : Nat.fib (j + 2) = Nat.fib j + Nat.fib (j + 1) := Nat.fib_add_two
    have hn2 : (Nat.fib (n + 2) : ℤ) = Nat.fib n + Nat.fib (n + 1) := by
      exact_mod_cast (Nat.fib_add_two (n := n))
    have hc := cassini' n
    rw [hn2] at hc
    rw [h1, h2]
    push_cast [hj2]
    linear_combination (Nat.fib (j + 1) : ℤ) * hc

/-- **Catalan's identity** (shifted, sign form):
`fib (n+r)^2 - fib n * fib (n+2r) = (-1)^n * fib r ^2`.

Proof: reduce to Cassini.  For `r = s+1`, substitute the closed form
`fib_two_basis`, the odd doubling `fib (2s+1) = fib (s+1)^2 + fib s^2` and the even
doubling `fib (2s+2) = fib (s+1) * (2 fib s + fib (s+1))`; the result is
`fib (s+1)^2` times the Cassini expression. -/
theorem catalan_identity (n r : ℕ) :
    (Nat.fib (n + r) : ℤ) ^ 2 - Nat.fib n * Nat.fib (n + 2 * r)
      = (-1) ^ n * (Nat.fib r) ^ 2 := by
  cases r with
  | zero => simp; ring
  | succ s =>
    have h1 := fib_two_basis n s
    have h2 := fib_two_basis n (2 * s + 1)
    rw [show n + (2 * s + 1 + 1) = n + 2 * (s + 1) from by ring] at h2
    have hd1 : Nat.fib (2 * s + 1) = Nat.fib (s + 1) ^ 2 + Nat.fib s ^ 2 := by
      have h := Nat.fib_add s s
      rw [show s + s + 1 = 2 * s + 1 from by ring] at h; rw [h]; ring
    have hd2 : Nat.fib (2 * s + 1 + 1)
        = Nat.fib (s + 1) * (2 * Nat.fib s + Nat.fib (s + 1)) := by
      have h := Nat.fib_add s (s + 1)
      rw [show s + (s + 1) + 1 = 2 * s + 1 + 1 from by ring] at h
      rw [h]; simp only [Nat.fib_add_two]; ring
    have hn2 : (Nat.fib (n + 2) : ℤ) = Nat.fib n + Nat.fib (n + 1) := by
      exact_mod_cast (Nat.fib_add_two (n := n))
    have hc := cassini' n
    rw [hn2] at hc
    rw [h1, h2, hd1, hd2]
    push_cast
    linear_combination (Nat.fib (s + 1) : ℤ) ^ 2 * hc

/-! ### Partial-sum identities -/

-- !-- Lab Notes -- !--
-- EXPERIMENT: telescoping sums.  RESULT: `Finset.sum_range_succ` + the basis
-- expansion (`simp only [Nat.fib_add_two]`) reduces each inductive step to a
-- linear `ℕ` goal (`omega`) or a polynomial goal (`ring`).

/-- **Sum of Fibonacci numbers:** `∑_{i<n} fib i = fib (n+1) - 1`. -/
theorem sum_fib (n : ℕ) :
    ∑ i ∈ Finset.range n, Nat.fib i = Nat.fib (n + 1) - 1 := by
  induction n with
  | zero => decide
  | succ k ih =>
    rw [Finset.sum_range_succ, ih]
    have h1 : 1 ≤ Nat.fib (k + 1) := Nat.fib_pos.mpr (Nat.succ_pos k)
    fib_omega

/-- **Sum of squares:** `∑_{i ≤ n} fib i ^ 2 = fib n * fib (n+1)`. -/
theorem sum_fib_sq (n : ℕ) :
    ∑ i ∈ Finset.range (n + 1), Nat.fib i ^ 2 = Nat.fib n * Nat.fib (n + 1) := by
  induction n with
  | zero => decide
  | succ k ih =>
    rw [Finset.sum_range_succ, ih]
    fib_ring

/-! ### The gcd identity (priority target `Fib_gcd_identity`) -/

-- !-- Lab Notes -- !--
-- The "strong divisibility" property of the Fibonacci sequence:
-- gcd (fib m) (fib n) = fib (gcd m n).  Mathlib provides `Nat.fib_gcd`; we expose
-- it here under the catalog's priority name and orientation.

/-- **Fibonacci gcd identity:** `gcd (fib m) (fib n) = fib (gcd m n)`. -/
theorem Fib_gcd_identity (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

end Catalog.ProofAutomation.Fibonacci