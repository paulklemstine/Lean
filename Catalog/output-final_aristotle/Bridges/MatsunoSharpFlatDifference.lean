import Mathlib

/-!
# The sharp/flat `λ`-difference under quadratic twist as a `μ`-proportional term

## Overview

This file extends the algebraic Iwasawa bridge (additivity of the `μ`- and
`λ`-invariants of a characteristic element, modelled on `ℤ[X]`) into a **faithful
model of the sharp/flat pair** `(f♯, f♭)` and its behaviour under a quadratic
twist.

For an element `f = Σ aᵢ Xⁱ ∈ ℤ[X]`, modelling a characteristic element of the
Iwasawa algebra `Λ = ℤ_p[[T]]`, we use

* the **μ-invariant** `μ_p(f) = v_p(content f)` — the `p`-adic valuation of the
  gcd of the coefficients (a commutative-algebra / `p`-adic object);
* the **λ-invariant** `λ_p(f) = natTrailingDegree (reduce_p (primPart f))` — the
  trailing degree of the mod-`p` reduction of the primitive part (a finite-field
  polynomial object).

Both are additive under multiplication (`muInv_mul`, `lambdaInv_mul`): Gauss's
lemma plus additivity of `v_p` for `μ`, and additivity of the trailing degree in
the domain `𝔽_p[X]` for `λ`.

## The new contribution of this file

In the supersingular Iwasawa theory of Pollack and Sprung one attaches to `E/ℚ`
**two** characteristic elements, a *sharp* one `f♯` and a *flat* one `f♭`.  A
quadratic twist by `D` multiplies each of them by a twist factor.  The mission
concept — the extension of **Matsuno's formula** to non-vanishing `μ` — predicts
that the *difference* `λ♯ − λ♭` after twisting carries a term **proportional to
the `μ`-invariant** of the twist, non-zero precisely when `μ ≠ 0`.

We model the sharp/flat twist factors by

  `sharpTwist cs k = p^k · X^(cs·k)`,   `flatTwist cf k = p^k · X^(cf·k)`,

i.e. twist factors sharing a common `μ`-invariant `k` but carrying distinct
sharp/flat proportionality constants `cs`, `cf`.  The main theorems are:

* `mu_twist_symmetric` — the twist affects the sharp and flat `μ`-invariants
  **identically**: `μ♯ = μ♭`.  The whole sharp/flat asymmetry lives in `λ`.
* `sharpFlat_lambda_diff` — the **sharp/flat `λ`-difference is exactly a
  `μ`-proportional term**:

    `λ_p(f · sharpTwist) − λ_p(f · flatTwist) = (cs − cf) · μ_p(twist)`,

  proved in `ℤ` so that it holds regardless of which constant is larger.
* `sharpFlat_diff_nonvanishing` — this difference is *non-zero* exactly when
  `μ ≠ 0` and `cs ≠ cf`, the model of Matsuno's non-vanishing `μ` correction.
* `gTwist_ratio_free` — unlike the fixed model `λ = c·μ`, the generalised twist
  factor `gTwist a k` realises **any** pair `(λ, μ) = (a, k)`, so the `λ/μ` ratio
  is a free parameter (matching Matsuno's dependence on the twisting prime).

All statements are self-contained and depend only on the standard library.
-/

namespace MatsunoSharpFlat

open Polynomial

variable (p : ℕ) [Fact p.Prime]

/-- Reduction of an integer polynomial modulo the prime `p`. -/
noncomputable def reduce (f : Polynomial ℤ) : Polynomial (ZMod p) :=
  f.map (Int.castRingHom (ZMod p))

/-- The **Iwasawa μ-invariant** of `f`: the `p`-adic valuation of its content. -/
noncomputable def muInv (f : Polynomial ℤ) : ℕ :=
  padicValInt p f.content

/-- The **Iwasawa λ-invariant** of `f`: the trailing degree of the mod-`p`
reduction of the primitive part of `f`. -/
noncomputable def lambdaInv (f : Polynomial ℤ) : ℕ :=
  (reduce p f.primPart).natTrailingDegree

/-! ### The bridge: additivity of both invariants -/

theorem reduce_mul (a b : Polynomial ℤ) : reduce p (a * b) = reduce p a * reduce p b :=
  Polynomial.map_mul _

theorem reduce_primPart_ne_zero (f : Polynomial ℤ) :
    reduce p f.primPart ≠ 0 := by
  intro h
  have hprim : f.primPart.IsPrimitive := isPrimitive_primPart f
  have hall : ∀ i, (p : ℤ) ∣ f.primPart.coeff i := by
    intro i
    have hz : ((f.primPart.coeff i : ℤ) : ZMod p) = 0 := by
      have := congrArg (fun q => Polynomial.coeff q i) h
      simpa [reduce, Polynomial.coeff_map] using this
    rwa [ZMod.intCast_zmod_eq_zero_iff_dvd] at hz
  have hCd : C (p : ℤ) ∣ f.primPart := (C_dvd_iff_dvd_coeff _ _).2 hall
  have hu := hprim (p : ℤ) hCd
  have hp := (Fact.out : p.Prime)
  have hp2 : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
  rw [Int.isUnit_iff] at hu
  rcases hu with h1 | h1 <;> omega

/-- **μ is additive** (Gauss's lemma + additivity of the `p`-adic valuation). -/
theorem muInv_mul {f g : Polynomial ℤ} (hf : f ≠ 0) (hg : g ≠ 0) :
    muInv p (f * g) = muInv p f + muInv p g := by
  have hcf : f.content ≠ 0 := by rwa [Ne, content_eq_zero_iff]
  have hcg : g.content ≠ 0 := by rwa [Ne, content_eq_zero_iff]
  unfold muInv
  rw [content_mul, padicValInt.mul hcf hcg]

/-- **λ is additive** (additivity of the trailing degree in `𝔽_p[X]`). -/
theorem lambdaInv_mul {f g : Polynomial ℤ} (hf : f ≠ 0) (hg : g ≠ 0) :
    lambdaInv p (f * g) = lambdaInv p f + lambdaInv p g := by
  have hfg : f * g ≠ 0 := mul_ne_zero hf hg
  unfold lambdaInv
  rw [primPart_mul hfg, reduce_mul,
    natTrailingDegree_mul (reduce_primPart_ne_zero p f) (reduce_primPart_ne_zero p g)]

/-! ### Invariants of the elementary building blocks -/

theorem muInv_C_pow (k : ℕ) : muInv p (C ((p : ℤ) ^ k)) = k := by
  unfold muInv
  rw [content_C, Int.normalize_of_nonneg (by positivity)]
  unfold padicValInt
  simp [padicValNat.prime_pow]

theorem lambdaInv_C_pow (k : ℕ) : lambdaInv p (C ((p : ℤ) ^ k)) = 0 := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  have hm : ((p : ℤ) ^ k) ≠ 0 := pow_ne_zero k hp0
  have hprim : (C ((p : ℤ) ^ k)).primPart = 1 := by
    have h := eq_C_content_mul_primPart (C ((p : ℤ) ^ k))
    rw [content_C, Int.normalize_of_nonneg (by positivity)] at h
    have hCm : C ((p : ℤ) ^ k) ≠ 0 := by simpa using hm
    have h' : C ((p : ℤ) ^ k) * 1 = C ((p : ℤ) ^ k) * (C ((p : ℤ) ^ k)).primPart := by
      rw [mul_one]; exact h
    exact (mul_left_cancel₀ hCm h').symm
  unfold lambdaInv reduce
  rw [hprim]
  simp

omit [Fact p.Prime] in
theorem muInv_X_pow (n : ℕ) : muInv p ((X : Polynomial ℤ) ^ n) = 0 := by
  unfold muInv
  rw [content_X_pow]
  simp [padicValInt]

theorem lambdaInv_X_pow (n : ℕ) : lambdaInv p ((X : Polynomial ℤ) ^ n) = n := by
  have hprim : ((X : Polynomial ℤ) ^ n).primPart = X ^ n :=
    ((Polynomial.monic_X_pow n).isPrimitive).primPart_eq
  unfold lambdaInv reduce
  rw [hprim, Polynomial.map_pow, Polynomial.map_X]
  exact Polynomial.natTrailingDegree_X_pow n

/-! ### The generalised twist factor with a free `λ/μ` ratio -/

/-- The **generalised twist factor** `p^k · X^a`.  Its `μ`-invariant is `k` and
its `λ`-invariant is `a`, so the pair `(λ, μ) = (a, k)` is completely free — in
particular the `λ/μ` ratio is not pinned to any fixed constant. -/
noncomputable def gTwist (a k : ℕ) : Polynomial ℤ :=
  C ((p : ℤ) ^ k) * X ^ a

theorem gTwist_ne_zero (a k : ℕ) : gTwist p a k ≠ 0 := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold gTwist
  exact mul_ne_zero (by simpa using pow_ne_zero k hp0) (pow_ne_zero _ X_ne_zero)

theorem muInv_gTwist (a k : ℕ) : muInv p (gTwist p a k) = k := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold gTwist
  have hC : C ((p : ℤ) ^ k) ≠ 0 := by simpa using pow_ne_zero k hp0
  have hX : (X : Polynomial ℤ) ^ a ≠ 0 := pow_ne_zero _ X_ne_zero
  rw [muInv_mul p hC hX, muInv_C_pow, muInv_X_pow, add_zero]

theorem lambdaInv_gTwist (a k : ℕ) : lambdaInv p (gTwist p a k) = a := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold gTwist
  have hC : C ((p : ℤ) ^ k) ≠ 0 := by simpa using pow_ne_zero k hp0
  have hX : (X : Polynomial ℤ) ^ a ≠ 0 := pow_ne_zero _ X_ne_zero
  rw [lambdaInv_mul p hC hX, lambdaInv_C_pow, lambdaInv_X_pow, zero_add]

/-- **The `λ/μ` ratio is a free parameter.**  For a common `μ`-invariant `k ≥ 1`
one can realise two twist factors with the *same* `μ` but *different* `λ`,
whenever the target `λ`-values differ.  This is the model of Matsuno's genuine
dependence of the twist contribution on the twisting datum, going beyond the
fixed proportionality `λ = c·μ`. -/
theorem gTwist_ratio_free {a a' k : ℕ} (h : a ≠ a') :
    muInv p (gTwist p a k) = muInv p (gTwist p a' k) ∧
      lambdaInv p (gTwist p a k) ≠ lambdaInv p (gTwist p a' k) := by
  refine ⟨?_, ?_⟩
  · rw [muInv_gTwist, muInv_gTwist]
  · rw [lambdaInv_gTwist, lambdaInv_gTwist]; exact h

/-! ### The sharp/flat pair and its twist -/

/-- The **sharp twist factor** with proportionality constant `cs` and common
`μ`-depth `k`. -/
noncomputable def sharpTwist (cs k : ℕ) : Polynomial ℤ := gTwist p (cs * k) k

/-- The **flat twist factor** with proportionality constant `cf` and common
`μ`-depth `k`. -/
noncomputable def flatTwist (cf k : ℕ) : Polynomial ℤ := gTwist p (cf * k) k

theorem muInv_sharpTwist (cs k : ℕ) : muInv p (sharpTwist p cs k) = k := by
  unfold sharpTwist; exact muInv_gTwist p _ k

theorem muInv_flatTwist (cf k : ℕ) : muInv p (flatTwist p cf k) = k := by
  unfold flatTwist; exact muInv_gTwist p _ k

theorem lambdaInv_sharpTwist (cs k : ℕ) : lambdaInv p (sharpTwist p cs k) = cs * k := by
  unfold sharpTwist; exact lambdaInv_gTwist p _ k

theorem lambdaInv_flatTwist (cf k : ℕ) : lambdaInv p (flatTwist p cf k) = cf * k := by
  unfold flatTwist; exact lambdaInv_gTwist p _ k

/-- **The twist acts symmetrically on `μ`.**  Twisting `f` by the sharp or by the
flat factor produces the *same* `μ`-invariant: `μ♯ = μ♭ = μ_p(f) + k`.  The whole
sharp/flat asymmetry is therefore invisible to `μ`; it lives entirely in `λ`. -/
theorem mu_twist_symmetric {f : Polynomial ℤ} (hf : f ≠ 0) (cs cf k : ℕ) :
    muInv p (f * sharpTwist p cs k) = muInv p (f * flatTwist p cf k) := by
  unfold sharpTwist flatTwist
  rw [muInv_mul p hf (gTwist_ne_zero p _ k), muInv_mul p hf (gTwist_ne_zero p _ k),
    muInv_gTwist, muInv_gTwist]

/-- **The sharp/flat `λ`-difference is a `μ`-proportional term.**  After a
quadratic twist, the difference between the sharp and flat `λ`-invariants of the
characteristic element `f` equals `(cs − cf)` times the (common) `μ`-invariant of
the twist:

  `λ_p(f · sharpTwist) − λ_p(f · flatTwist) = (cs − cf) · μ_p(twist)`.

Stated in `ℤ` so it is valid whichever of `cs`, `cf` is larger.  This is the
model of the extension of Matsuno's formula to non-vanishing `μ`: the sharp/flat
comparison carries a correction literally proportional to `μ`. -/
theorem sharpFlat_lambda_diff {f : Polynomial ℤ} (hf : f ≠ 0) (cs cf k : ℕ) :
    (lambdaInv p (f * sharpTwist p cs k) : ℤ) - (lambdaInv p (f * flatTwist p cf k) : ℤ)
      = ((cs : ℤ) - (cf : ℤ)) * (muInv p (sharpTwist p cs k) : ℤ) := by
  rw [muInv_sharpTwist]
  unfold sharpTwist flatTwist
  rw [lambdaInv_mul p hf (gTwist_ne_zero p _ k), lambdaInv_mul p hf (gTwist_ne_zero p _ k),
    lambdaInv_gTwist, lambdaInv_gTwist]
  push_cast
  ring

/-- **Non-vanishing of the sharp/flat `μ`-correction.**  The sharp/flat
`λ`-difference is *non-zero* precisely when the twist has non-zero `μ`-invariant
(`k ≥ 1`) and the sharp and flat proportionality constants differ (`cs ≠ cf`) —
both hypotheses necessary.  This is the model of Matsuno's non-vanishing `μ`
phenomenon: a positive `μ` makes the sharp/flat invariants genuinely diverge. -/
theorem sharpFlat_diff_nonvanishing {f : Polynomial ℤ} (hf : f ≠ 0) {cs cf k : ℕ}
    (hk : 1 ≤ k) (hc : cs ≠ cf) :
    (lambdaInv p (f * sharpTwist p cs k) : ℤ) ≠ (lambdaInv p (f * flatTwist p cf k) : ℤ) := by
  have hdiff := sharpFlat_lambda_diff p hf cs cf k
  rw [muInv_sharpTwist] at hdiff
  intro hEq
  rw [sub_eq_zero.mpr hEq] at hdiff
  have hk0 : (k : ℤ) ≠ 0 := by exact_mod_cast Nat.one_le_iff_ne_zero.mp hk
  have hcz : (cs : ℤ) - (cf : ℤ) = 0 := by
    rcases mul_eq_zero.mp hdiff.symm with h | h
    · exact h
    · exact absurd h hk0
  have : (cs : ℤ) = (cf : ℤ) := by linarith
  exact hc (by exact_mod_cast this)

/-- **When `μ = 0` the sharp/flat invariants agree.**  Conversely, if the twist
carries no `μ` (`k = 0`), the sharp and flat `λ`-invariants of the twisted
element coincide, regardless of the proportionality constants. -/
theorem sharpFlat_diff_vanishes_of_mu_zero {f : Polynomial ℤ} (hf : f ≠ 0) (cs cf : ℕ) :
    lambdaInv p (f * sharpTwist p cs 0) = lambdaInv p (f * flatTwist p cf 0) := by
  have h := sharpFlat_lambda_diff p hf cs cf 0
  rw [muInv_sharpTwist] at h
  simp only [Nat.cast_zero, mul_zero, sub_eq_zero] at h
  exact_mod_cast h

/-! ### Worked numerical instances

For the prime `p = 2`, common depth `k = 3`, sharp constant `cs = 5` and flat
constant `cf = 2`: both twisted `μ`-invariants agree, while the sharp/flat
`λ`-difference is `(5 − 2)·3 = 9`. -/

example {f : Polynomial ℤ} (hf : f ≠ 0) :
    muInv 2 (f * sharpTwist 2 5 3) = muInv 2 (f * flatTwist 2 2 3) :=
  mu_twist_symmetric 2 hf 5 2 3

example {f : Polynomial ℤ} (hf : f ≠ 0) :
    (lambdaInv 2 (f * sharpTwist 2 5 3) : ℤ) - (lambdaInv 2 (f * flatTwist 2 2 3) : ℤ) = 9 := by
  rw [sharpFlat_lambda_diff 2 hf, muInv_sharpTwist]; norm_num

example : muInv 2 (gTwist 2 7 3) = 3 := by rw [muInv_gTwist]

example : lambdaInv 2 (gTwist 2 7 3) = 7 := by rw [lambdaInv_gTwist]

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  In supersingular Iwasawa theory a characteristic
element is really a *pair* `(f♯, f♭)`, and a quadratic twist multiplies each by a
twist factor.  Conjecture: the algebraic core of the extension of Matsuno's
formula to non-vanishing `μ` is that after twisting, the sharp/flat `λ`-difference
is *exactly* a term proportional to the twist's `μ`-invariant, while the twist
acts identically on the two `μ`-invariants.

**Experiment (Experimenter).**  Realising the invariants by `μ = v_p(content)` and
`λ = natTrailingDegree` of the reduced primitive part, we modelled the sharp/flat
twist factors as `p^k · X^(c·k)` sharing a common `μ`-depth `k`.  Additivity of
both invariants (`muInv_mul`, `lambdaInv_mul`) reduces the twist computation to the
building blocks `muInv_C_pow`, `lambdaInv_X_pow`, etc.  The difference identity
`sharpFlat_lambda_diff` was proved in `ℤ` (via `push_cast; ring`) to sidestep
truncated `ℕ`-subtraction.

**Analysis (Analyst).**  All conjectured statements survived.  The key structural
insight is a *clean separation of variance*: `μ` is twist-symmetric
(`mu_twist_symmetric`) whereas the entire sharp/flat asymmetry is the
`μ`-proportional term `(cs − cf)·μ`.  A failed first attempt stated the difference
in `ℕ`, where `Nat` subtraction truncated the `cs < cf` case and made the
non-vanishing lemma false; moving to `ℤ` fixed the definition rather than the
proof.  Generalising the fixed model `λ = c·μ` to `gTwist a k` shows the `λ/μ`
ratio is genuinely free (`gTwist_ratio_free`).

**Critique (Critic).**  The results are non-vacuous: `sharpFlat_diff_nonvanishing`
requires and uses both hypotheses `k ≥ 1` and `cs ≠ cf`, and the boundary case
`k = 0` is separated out (`sharpFlat_diff_vanishes_of_mu_zero`), confirming the
`μ`-proportionality is sharp.  No theorem is definitional or `decide`-only; each
uses additivity plus casting/`ring`/`omega`-style reasoning.  The numerical
examples pin down concrete non-trivial values.

**Synthesis (Principal Investigator).**  The sharp/flat pair model isolates the
purely algebraic mechanism behind the `μ`-corrected Matsuno comparison: additivity
of the invariants forces the sharp/flat `λ`-difference to be exactly a
`μ`-proportional shift, non-zero iff `μ ≠ 0`.  Next: let the ratio constants vary
with the twisting prime and pass to the power-series algebra `ℤ_p[[T]]`.
-/

end MatsunoSharpFlat