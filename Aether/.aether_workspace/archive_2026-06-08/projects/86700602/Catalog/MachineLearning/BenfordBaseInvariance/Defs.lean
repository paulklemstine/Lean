import Mathlib

/-! # Benford Base Invariance: Definitions and Foundations

This file formalizes the key definitions for studying base-invariant Benford behavior
of positive real sequences. The central insight is that Benford's law in a given base
is equivalent to equidistribution modulo 1 of the logarithmic sequence, and that
multiplicative independence of bases corresponds to irrationality of their log ratios.

## Main Definitions

* `EquidistributedModOne` - A sequence is equidistributed mod 1 if the Cesàro averages
  of fractional parts converge to uniform measure on [0,1).
* `BenfordInBase` - A positive sequence satisfies Benford's law in base b.
* `BenfordBaseInvariant` - A sequence has base-invariant Benford behavior across all
  admissible bases.
* `MultiplicativelyIndependent` - Two natural numbers share no nontrivial power relation.

## References

* Diaconis, P. (1977). The distribution of leading digits and uniform distribution mod 1.
* Berger, A. & Hill, T. P. (2015). An Introduction to Benford's Law.
-/

open Real Filter Topology

noncomputable section

/-! ## Equidistribution modulo 1

We define equidistribution modulo 1 via interval frequencies: a sequence `x : ℕ → ℝ`
is equidistributed mod 1 if for every subinterval `[a, b) ⊆ [0, 1)`, the proportion
of indices `k < N` with `Int.fract (x k) ∈ [a, b)` converges to `b - a` as `N → ∞`.
-/

/-- Count the number of indices `k < N` satisfying a predicate. -/
def countSat (P : ℕ → Prop) [DecidablePred P] (N : ℕ) : ℕ :=
  (Finset.range N).filter P |>.card

/-- The frequency of indices `k < N` with `Int.fract (x k) ∈ [a, b)`. -/
noncomputable def fracFreq (x : ℕ → ℝ) (a b : ℝ) (N : ℕ) : ℝ :=
  ((Finset.range N).filter (fun k => a ≤ Int.fract (x k) ∧ Int.fract (x k) < b)).card / (N : ℝ)

/-- A sequence `x : ℕ → ℝ` is **equidistributed modulo 1** if for every subinterval
`[a, b) ⊆ [0, 1)`, the proportion of indices with fractional part in `[a, b)`
converges to `b - a`. This is the standard definition from uniform distribution theory. -/
def EquidistributedModOne (x : ℕ → ℝ) : Prop :=
  ∀ a b : ℝ, 0 ≤ a → a < b → b ≤ 1 →
    Filter.Tendsto (fun N => fracFreq x a b N) Filter.atTop (nhds (b - a))

/-! ## Benford's Law -/

/-- The **leading significand** of a positive real number `x` in base `b ≥ 2` is the
unique value `s ∈ [1, b)` such that `x = s · b^k` for some integer `k`.
Equivalently, `s = b^{frac(log_b x)}`. -/
noncomputable def significand (b : ℕ) (x : ℝ) : ℝ :=
  (b : ℝ) ^ Int.fract (Real.log x / Real.log b)

/-- The **leading digit** of `x > 0` in base `b ≥ 2` is `⌊significand b x⌋`. -/
noncomputable def leadingDigit (b : ℕ) (x : ℝ) : ℕ :=
  ⌊significand b x⌋₊

/-- A positive sequence `u` satisfies **Benford's law in base `b`** if the sequence
`n ↦ log(u n) / log b` is equidistributed modulo 1. This is the analytic formulation
equivalent to the classical digit-frequency definition. -/
def BenfordInBase (u : ℕ → ℝ) (b : ℕ) : Prop :=
  2 ≤ b ∧
  (∀ n, 0 < u n) ∧
  EquidistributedModOne (fun n => Real.log (u n) / Real.log b)

/-- A positive sequence `u` is **Benford base-invariant** if Benford's law holds
in every pair of admissible bases (those with irrational log-ratio to 2). -/
def BenfordBaseInvariant (u : ℕ → ℝ) : Prop :=
  ∀ b₁ b₂ : ℕ,
    2 ≤ b₁ →
    2 ≤ b₂ →
    Irrational (Real.log b₁ / Real.log 2) →
    Irrational (Real.log b₂ / Real.log 2) →
    (BenfordInBase u b₁ ↔ BenfordInBase u b₂)

/-! ## Multiplicative Independence -/

/-- Two natural numbers `a, b` are **multiplicatively independent** if
`a^m = b^n` implies `m = 0` and `n = 0`. This is the key number-theoretic condition
that controls base-transfer for Benford's law. -/
def MultiplicativelyIndependent (a b : ℕ) : Prop :=
  ∀ m n : ℕ, a ^ m = b ^ n → m = 0 ∧ n = 0

/-! ## Prime-indexed dynamical sequences -/

/-- The prime enumeration sequence: `primeSeq k` is the k-th prime (0-indexed). -/
noncomputable def primeSeq : ℕ → ℕ := Nat.nth Nat.Prime

/-- A simple dynamical map `T_c(x) = x^2 + c` for integer dynamics. -/
def T_c (c : ℤ) (x : ℤ) : ℤ := x ^ 2 + c

/-- The `n`-fold iterate of `T_c`. -/
def T_c_iter (c : ℤ) : ℕ → ℤ → ℤ
  | 0, x => x
  | n + 1, x => T_c c (T_c_iter c n x)

end