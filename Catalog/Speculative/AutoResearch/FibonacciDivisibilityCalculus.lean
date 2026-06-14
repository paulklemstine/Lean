/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Fibonacci Divisibility Calculus

This file develops the *divisibility calculus* of the Fibonacci sequence: the
precise dictionary translating the additive/gcd structure of the **indices** into
the multiplicative/divisibility structure of the **values** `F(n)`.

The cornerstone is Mathlib's `Nat.fib_gcd`, which states that `F` is a *strong
divisibility sequence*:

    F(gcd m n) = gcd (F m) (F n).

From this single identity we extract the full calculus:

* `fib_gcd_identity`        — the strong-divisibility law, restated.
* `fib_coprime_of_coprime`  — coprime indices give coprime values.
* `fib_dvd_iff`             — the divisibility *characterization*
                              `F m ∣ F n ↔ m ∣ n` (for `m ≥ 3`), the converse to
                              `Nat.fib_dvd`.
* `prime_dvd_fib_gcd`       — the "rank of apparition" descent lemma underlying
                              Carmichael's primitive-divisor theorem.

## Catalog synthesis

This file is the *foundation* the Carmichael primitive-divisor development rests
on.  `prime_dvd_fib_gcd` is exactly the descent step used (under the names
`fib_prime_dvd_gcd'` / `fib_dvd_gcd_of_dvd`) in
`Catalog/Speculative/CarmichaelPrimitiveDivisor.lean` and
`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`; here it is proved
once, cleanly, as a consequence of `fib_gcd_identity`.  The sharp
characterization `fib_dvd_iff` is the missing converse to `Nat.fib_dvd` and is
the index-level analogue of the entry-point (rank of apparition) theory used
throughout the `FibonacciEntryPoints` catalog files.
-/

import Mathlib

namespace FibonacciDivisibilityCalculus

open Nat

-- !-- Lab Notebook --!--
-- Hypothesis: Fibonacci is a *strong divisibility sequence*, so the entire
--   divisibility lattice of {F(n)} should be a faithful image of the divisibility
--   lattice of ℕ, with the *only* defect coming from the degenerate equality
--   F(1) = F(2) = 1.  We test whether `F m ∣ F n ↔ m ∣ n` holds once we step past
--   that defect (m ≥ 3).
-- Result: Confirmed and proved sorry-free.  The four theorems below give the
--   complete dictionary.  The forward direction of `fib_dvd_iff` is where the
--   strong-divisibility identity does the real work: `F m ∣ F n` forces
--   `gcd(F m, F n) = F m`, hence `F (gcd m n) = F m`, and strict monotonicity of
--   `F` on `[2, ∞)` upgrades this to `gcd m n = m`, i.e. `m ∣ n`.
-- Insight: The hypothesis `m ≥ 3` is exactly sharp: at `m = 1, 2` we have
--   `F m = 1`, which divides every `F n`, so the right-hand side `m ∣ n` would be
--   false in general (e.g. `m = 2`, `n` odd).  The defect of the calculus is a
--   single value, and `m ≥ 3` is the minimal hypothesis erasing it.
-- Failure analysis: A first attempt routed the converse through Pisano
--   periods / entry points directly; this is unnecessary — routing everything
--   through `Nat.fib_gcd` plus `Nat.fib_strictMonoOn` is shorter and avoids any
--   appeal to modular periodicity.
-- !-- Lab Notebook --!--

-- !-- The strong-divisibility law `F(gcd m n) = gcd(F m, F n)`: this is Mathlib's
--     `Nat.fib_gcd`, restated as the foundation of the whole calculus. --!--
theorem fib_gcd_identity (m n : ℕ) :
    Nat.fib (Nat.gcd m n) = Nat.gcd (Nat.fib m) (Nat.fib n) := by
  convert Nat.fib_gcd m n using 1

-- !-- Coprime indices yield coprime Fibonacci values: specialise
--     `fib_gcd_identity` at `gcd m n = 1` and use `F 1 = 1`. --!--
theorem fib_coprime_of_coprime (m n : ℕ) (h : Nat.Coprime m n) :
    Nat.Coprime (Nat.fib m) (Nat.fib n) :=
  (fib_gcd_identity m n).symm.trans (by simp [h])

-- !-- The divisibility characterization (converse to `Nat.fib_dvd`). `(←)` is
--     `Nat.fib_dvd`; `(→)` uses `fib_gcd_identity` to get `F (gcd m n) = F m`,
--     then injectivity of `Nat.fib_strictMonoOn` on `[2,∞)` gives `gcd m n = m`,
--     i.e. `m ∣ n`. --!--
theorem fib_dvd_iff (m n : ℕ) (hm : 3 ≤ m) :
    Nat.fib m ∣ Nat.fib n ↔ m ∣ n := by
  constructor
  · intro h_div
    have h_gcd : Nat.fib (Nat.gcd m n) = Nat.fib m := by
      rw [fib_gcd_identity, Nat.gcd_eq_left h_div]
    have h_gcd_ge_2 : 2 ≤ Nat.gcd m n := by
      contrapose! h_gcd
      interval_cases _ : Nat.gcd m n <;> simp_all +decide
      linarith [Nat.le_fib_add_one m]
    have h_gcd_eq_m : Nat.gcd m n = m :=
      Nat.fib_strictMonoOn.injOn h_gcd_ge_2 (show 2 ≤ m by linarith) h_gcd
    exact h_gcd_eq_m ▸ Nat.gcd_dvd_right _ _
  · exact Nat.fib_dvd m n

-- !-- The rank-of-apparition descent step: a common Fibonacci divisor of two
--     indices already divides the Fibonacci of their gcd.  Rewrite by
--     `fib_gcd_identity` and apply `Nat.dvd_gcd`. --!--
theorem prime_dvd_fib_gcd (p m n : ℕ) (hm : p ∣ Nat.fib m) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd m n) := by
  rw [fib_gcd_identity]
  exact Nat.dvd_gcd hm hn

end FibonacciDivisibilityCalculus