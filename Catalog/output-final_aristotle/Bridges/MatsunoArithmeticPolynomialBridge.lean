/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# A connector bridge: the arithmetic μ-corrected Matsuno invariant is a genuine
  polynomial Iwasawa invariant

## Overview

This file builds an explicit **cross-domain bridge** between two *a priori
unrelated* pieces of mathematics that both appear in the study of the
sharp/flat Iwasawa `λ`-invariants of a quadratic twist:

* **(Number theory / `2`-adic combinatorics.)**  The extension of Matsuno's
  formula models the sharp/flat `λ`-difference of the twist `E^D` of an elliptic
  curve with good supersingular reduction at `2` as an explicit *arithmetic*
  quantity
  `lambdaDiffMu D NE μ ord = Σ_{ℓ ∣ D} localTerm ℓ + μ · Σ_{ℓ ∣ D} 2^{n_ℓ}`,
  where `n_ℓ = v₂((ℓ²−1)/8)` is a `2`-adic depth.  This is a finite sum over the
  prime divisors of `D`, a purely arithmetic object.

* **(Commutative algebra of `ℤ[X]`.)**  The two Iwasawa invariants of an actual
  characteristic element `f ∈ Λ = ℤ_p[[T]]`, modelled on the polynomial ring
  `ℤ[X]`, are
  `μ_p(f) = v_p(content f)` (a Gauss's-lemma / `p`-adic-valuation datum) and
  `λ_p(f) = natTrailingDegree (reduce_p (primPart f))` (a `𝔽_p[X]` combinatorial
  datum, the order of vanishing at `0` of the mod-`p` reduction).

The bridge is the **characteristic element** `charElt D NE μ ord`, an explicit
polynomial in `ℤ[X]` built as a product of local factors `X^{localTerm ℓ}` over
the prime divisors of `D` times a μ-factor `(p · X^{Σ 2^{n_ℓ}})^μ`.  The two
main theorems say that its *genuine* polynomial Iwasawa invariants recover the
arithmetic model **on the nose**:

* `muInv_charElt` :  `μ_p(charElt D NE μ ord) = μ`,
* `lambdaInv_charElt` :  `λ_p(charElt D NE μ ord) = lambdaDiffMu D NE μ ord`.

Thus the abstract arithmetic Matsuno invariant *is* the `λ`-invariant of a
concrete polynomial whose `μ`-invariant is exactly the input `μ`.  As corollaries
we obtain the **μ-recovery / inversion formula phrased entirely at the polynomial
level** (`mu_recovery_polynomial`), a **non-vanishing** statement
(`lambdaInv_charElt_gt`), and **additivity of the realised `λ`-invariant over
coprime twisting parameters** (`lambdaInv_charElt_coprime`), which connects the
number-theoretic additivity of `lambdaDiffMu` with the commutative-algebra
additivity of the trailing degree.

All statements are self-contained and depend only on Mathlib; there are no
`sorry`s and no extra axioms.
-/

open Polynomial BigOperators Finset

namespace MatsunoArithPoly

/-! ## Part I. Polynomial Iwasawa invariants -/

variable (p : ℕ) [Fact p.Prime]

/-- Reduction of an integer polynomial modulo the prime `p`. -/
noncomputable def reduce (f : Polynomial ℤ) : Polynomial (ZMod p) :=
  f.map (Int.castRingHom (ZMod p))

/-- The **Iwasawa μ-invariant**: the `p`-adic valuation of the content of `f`. -/
noncomputable def muInv (f : Polynomial ℤ) : ℕ := padicValInt p f.content

/-- The **Iwasawa λ-invariant**: the trailing degree of the mod-`p` reduction of
the primitive part of `f`. -/
noncomputable def lambdaInv (f : Polynomial ℤ) : ℕ :=
  (reduce p f.primPart).natTrailingDegree

theorem reduce_mul (a b : Polynomial ℤ) : reduce p (a * b) = reduce p a * reduce p b :=
  Polynomial.map_mul _

/-- The reduction of a primitive polynomial modulo `p` is nonzero. -/
theorem reduce_primPart_ne_zero (f : Polynomial ℤ) : reduce p f.primPart ≠ 0 := by
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

/-- **μ is additive under multiplication** (Gauss's lemma + additivity of `v_p`). -/
theorem muInv_mul {f g : Polynomial ℤ} (hf : f ≠ 0) (hg : g ≠ 0) :
    muInv p (f * g) = muInv p f + muInv p g := by
  have hcf : f.content ≠ 0 := by rwa [Ne, content_eq_zero_iff]
  have hcg : g.content ≠ 0 := by rwa [Ne, content_eq_zero_iff]
  unfold muInv
  rw [content_mul, padicValInt.mul hcf hcg]

/-- **λ is additive under multiplication** (additivity of the trailing degree in
the domain `𝔽_p[X]`). -/
theorem lambdaInv_mul {f g : Polynomial ℤ} (hf : f ≠ 0) (hg : g ≠ 0) :
    lambdaInv p (f * g) = lambdaInv p f + lambdaInv p g := by
  have hfg : f * g ≠ 0 := mul_ne_zero hf hg
  unfold lambdaInv
  rw [primPart_mul hfg, reduce_mul,
    natTrailingDegree_mul (reduce_primPart_ne_zero p f) (reduce_primPart_ne_zero p g)]

omit [Fact p.Prime] in
theorem muInv_one : muInv p 1 = 0 := by
  unfold muInv; simp [padicValInt]

theorem lambdaInv_one : lambdaInv p 1 = 0 := by
  unfold lambdaInv reduce; simp

/-! ### Invariants of the elementary building blocks -/

/-- The `μ`-invariant of the constant `p^k` is `k`. -/
theorem muInv_C_pow (k : ℕ) : muInv p (C ((p : ℤ) ^ k)) = k := by
  unfold muInv
  rw [content_C, Int.normalize_of_nonneg (by positivity)]
  unfold padicValInt
  simp [padicValNat.prime_pow]

/-- A nonzero constant power `p^k` has `λ`-invariant `0`. -/
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
/-- The `μ`-invariant of `X^n` is `0`. -/
theorem muInv_X_pow (n : ℕ) : muInv p ((X : Polynomial ℤ) ^ n) = 0 := by
  unfold muInv
  rw [content_X_pow]
  simp [padicValInt]

/-- The `λ`-invariant of `X^n` is `n`. -/
theorem lambdaInv_X_pow (n : ℕ) : lambdaInv p ((X : Polynomial ℤ) ^ n) = n := by
  have hprim : ((X : Polynomial ℤ) ^ n).primPart = X ^ n :=
    ((Polynomial.monic_X_pow n).isPrimitive).primPart_eq
  unfold lambdaInv reduce
  rw [hprim, Polynomial.map_pow, Polynomial.map_X]
  exact Polynomial.natTrailingDegree_X_pow n

/-! ### Powers -/

/-- `μ` scales linearly along powers of a nonzero polynomial. -/
theorem muInv_pow {g : Polynomial ℤ} (hg : g ≠ 0) (n : ℕ) :
    muInv p (g ^ n) = n * muInv p g := by
  induction n with
  | zero => simpa using muInv_one p
  | succ k ih =>
      have hgk : g ^ k ≠ 0 := pow_ne_zero k hg
      rw [pow_succ, muInv_mul p hgk hg, ih]
      ring

/-- `λ` scales linearly along powers of a nonzero polynomial. -/
theorem lambdaInv_pow {g : Polynomial ℤ} (hg : g ≠ 0) (n : ℕ) :
    lambdaInv p (g ^ n) = n * lambdaInv p g := by
  induction n with
  | zero => simpa using lambdaInv_one p
  | succ k ih =>
      have hgk : g ^ k ≠ 0 := pow_ne_zero k hg
      rw [pow_succ, lambdaInv_mul p hgk hg, ih]
      ring

/-! ### Finite products -/

/-- `μ` of a finite product of nonzero polynomials is the sum of the `μ`s. -/
theorem muInv_prod {s : Finset ℕ} {g : ℕ → Polynomial ℤ} (hg : ∀ i ∈ s, g i ≠ 0) :
    muInv p (∏ i ∈ s, g i) = ∑ i ∈ s, muInv p (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using muInv_one p
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.sum_insert ha]
      have hga : g a ≠ 0 := hg a (Finset.mem_insert_self a s)
      have hgs : (∏ i ∈ s, g i) ≠ 0 :=
        Finset.prod_ne_zero_iff.2 (fun i hi => hg i (Finset.mem_insert_of_mem hi))
      rw [muInv_mul p hga hgs, ih (fun i hi => hg i (Finset.mem_insert_of_mem hi))]

/-- `λ` of a finite product of nonzero polynomials is the sum of the `λ`s. -/
theorem lambdaInv_prod {s : Finset ℕ} {g : ℕ → Polynomial ℤ} (hg : ∀ i ∈ s, g i ≠ 0) :
    lambdaInv p (∏ i ∈ s, g i) = ∑ i ∈ s, lambdaInv p (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using lambdaInv_one p
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.sum_insert ha]
      have hga : g a ≠ 0 := hg a (Finset.mem_insert_self a s)
      have hgs : (∏ i ∈ s, g i) ≠ 0 :=
        Finset.prod_ne_zero_iff.2 (fun i hi => hg i (Finset.mem_insert_of_mem hi))
      rw [lambdaInv_mul p hga hgs, ih (fun i hi => hg i (Finset.mem_insert_of_mem hi))]

/-! ## Part II. The arithmetic model (extension of Matsuno's formula) -/

/-- The `2`-adic depth `n_ℓ = v₂((ℓ²−1)/8)`. -/
def nEll (ℓ : ℕ) : ℕ := padicValNat 2 ((ℓ ^ 2 - 1) / 8)

/-- The classical local contribution of a prime `ℓ` to the `λ`-difference (μ = 0). -/
def localTerm (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) : ℕ :=
  if ℓ ∣ NE then 2 ^ nEll ℓ
  else if 2 ∣ ord ℓ then 2 ^ (nEll ℓ + 1)
  else 0

/-- The classical (μ = 0) Matsuno `λ`-difference of the twist `E^D`. -/
def lambdaDiff (D NE : ℕ) (ord : ℕ → ℕ) : ℕ :=
  ∑ ℓ ∈ D.primeFactors, localTerm NE ord ℓ

/-- The local `μ`-weight `2^{n_ℓ}` of a prime divisor of `D`. -/
def muWeight (ℓ : ℕ) : ℕ := 2 ^ nEll ℓ

/-- The total local `μ`-weight of `D`. -/
def weightSum (D : ℕ) : ℕ := ∑ ℓ ∈ D.primeFactors, muWeight ℓ

/-- The `μ`-correction: `μ` times the total local `μ`-weight of `D`. -/
def muTerm (D μ : ℕ) : ℕ := μ * weightSum D

/-- The μ-corrected Matsuno `λ`-difference of the twist `E^D`. -/
def lambdaDiffMu (D NE μ : ℕ) (ord : ℕ → ℕ) : ℕ := lambdaDiff D NE ord + muTerm D μ

theorem weightSum_pos_iff (D : ℕ) : 0 < weightSum D ↔ D.primeFactors.Nonempty := by
  unfold weightSum
  constructor
  · intro h
    rcases Finset.eq_empty_or_nonempty D.primeFactors with he | hne
    · simp [he] at h
    · exact hne
  · intro hne
    exact Finset.sum_pos (fun i _ => by unfold muWeight; positivity) hne

theorem lambdaDiffMu_mu_zero (D NE : ℕ) (ord : ℕ → ℕ) :
    lambdaDiffMu D NE 0 ord = lambdaDiff D NE ord := by
  simp [lambdaDiffMu, muTerm]

/-- Additivity of the μ-corrected invariant over coprime moduli. -/
theorem lambdaDiffMu_mul_coprime {a b NE μ : ℕ} {ord : ℕ → ℕ}
    (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    lambdaDiffMu (a * b) NE μ ord = lambdaDiffMu a NE μ ord + lambdaDiffMu b NE μ ord := by
  unfold lambdaDiffMu muTerm lambdaDiff weightSum
  rw [Nat.primeFactors_mul ha hb, Finset.sum_union hab.disjoint_primeFactors,
      Finset.sum_union hab.disjoint_primeFactors]
  ring

/-! ## Part III. The bridge: the characteristic element -/

/-- The local factor at a prime `ℓ`: `X` raised to the classical local term. -/
noncomputable def localFactor (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) : Polynomial ℤ :=
  (X : Polynomial ℤ) ^ (localTerm NE ord ℓ)

/-- The `μ`-factor: `(p · X^{Σ 2^{n_ℓ}})^μ`.  Its `μ`-invariant is `μ` and its
`λ`-invariant is `μ · Σ 2^{n_ℓ} = muTerm D μ`. -/
noncomputable def muFactor (D μ : ℕ) : Polynomial ℤ :=
  (C ((p : ℤ)) * (X : Polynomial ℤ) ^ (weightSum D)) ^ μ

/-- The **characteristic element** realising the μ-corrected Matsuno invariant:
a product of local factors over the prime divisors of `D`, times the `μ`-factor. -/
noncomputable def charElt (D NE μ : ℕ) (ord : ℕ → ℕ) : Polynomial ℤ :=
  (∏ ℓ ∈ D.primeFactors, localFactor NE ord ℓ) * muFactor p D μ

theorem localFactor_ne_zero (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) :
    localFactor NE ord ℓ ≠ 0 := by
  unfold localFactor; exact pow_ne_zero _ X_ne_zero

theorem muFactor_ne_zero (D μ : ℕ) : muFactor p D μ ≠ 0 := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  unfold muFactor
  apply pow_ne_zero
  exact mul_ne_zero (by simpa using hp0) (pow_ne_zero _ X_ne_zero)

omit [Fact p.Prime] in
/-- The `μ`-invariant of the local factor is `0`. -/
theorem muInv_localFactor (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) :
    muInv p (localFactor NE ord ℓ) = 0 := by
  unfold localFactor; exact muInv_X_pow p _

/-- The `λ`-invariant of the local factor is the classical local term. -/
theorem lambdaInv_localFactor (NE : ℕ) (ord : ℕ → ℕ) (ℓ : ℕ) :
    lambdaInv p (localFactor NE ord ℓ) = localTerm NE ord ℓ := by
  unfold localFactor; exact lambdaInv_X_pow p _

/-- The `μ`-invariant of the `μ`-factor is exactly `μ`. -/
theorem muInv_muFactor (D μ : ℕ) : muInv p (muFactor p D μ) = μ := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  have hC : C ((p : ℤ)) ≠ 0 := by simpa using hp0
  have hX : (X : Polynomial ℤ) ^ (weightSum D) ≠ 0 := pow_ne_zero _ X_ne_zero
  unfold muFactor
  rw [muInv_pow p (mul_ne_zero hC hX), muInv_mul p hC hX]
  have : muInv p (C ((p : ℤ))) = 1 := by
    have := muInv_C_pow p 1; simpa using this
  rw [this, muInv_X_pow]
  ring

/-- The `λ`-invariant of the `μ`-factor is exactly `muTerm D μ = μ · Σ 2^{n_ℓ}`. -/
theorem lambdaInv_muFactor (D μ : ℕ) : lambdaInv p (muFactor p D μ) = muTerm D μ := by
  have hp0 : (p : ℤ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).pos.ne'
  have hC : C ((p : ℤ)) ≠ 0 := by simpa using hp0
  have hX : (X : Polynomial ℤ) ^ (weightSum D) ≠ 0 := pow_ne_zero _ X_ne_zero
  unfold muFactor muTerm
  rw [lambdaInv_pow p (mul_ne_zero hC hX), lambdaInv_mul p hC hX]
  have hCz : lambdaInv p (C ((p : ℤ))) = 0 := by
    have := lambdaInv_C_pow p 1; simpa using this
  rw [hCz, lambdaInv_X_pow, zero_add]

/-! ### The two main bridge theorems -/

/-- **The `μ`-invariant of the characteristic element is exactly the input `μ`.** -/
theorem muInv_charElt (D NE μ : ℕ) (ord : ℕ → ℕ) :
    muInv p (charElt p D NE μ ord) = μ := by
  have hprod : (∏ ℓ ∈ D.primeFactors, localFactor NE ord ℓ) ≠ 0 :=
    Finset.prod_ne_zero_iff.2 (fun i _ => localFactor_ne_zero NE ord i)
  unfold charElt
  rw [muInv_mul p hprod (muFactor_ne_zero p D μ),
      muInv_prod p (fun i _ => localFactor_ne_zero NE ord i)]
  simp only [muInv_localFactor, Finset.sum_const_zero, zero_add]
  exact muInv_muFactor p D μ

/-- **The bridge.**  The genuine polynomial `λ`-invariant of the characteristic
element equals the arithmetic μ-corrected Matsuno invariant. -/
theorem lambdaInv_charElt (D NE μ : ℕ) (ord : ℕ → ℕ) :
    lambdaInv p (charElt p D NE μ ord) = lambdaDiffMu D NE μ ord := by
  have hprod : (∏ ℓ ∈ D.primeFactors, localFactor NE ord ℓ) ≠ 0 :=
    Finset.prod_ne_zero_iff.2 (fun i _ => localFactor_ne_zero NE ord i)
  unfold charElt lambdaDiffMu lambdaDiff
  rw [lambdaInv_mul p hprod (muFactor_ne_zero p D μ),
      lambdaInv_prod p (fun i _ => localFactor_ne_zero NE ord i)]
  simp only [lambdaInv_localFactor]
  rw [lambdaInv_muFactor]

/-! ### Corollaries of the bridge -/

/-- At `μ = 0` the realised `λ`-invariant is the classical Matsuno term. -/
theorem lambdaInv_charElt_mu_zero (D NE : ℕ) (ord : ℕ → ℕ) :
    lambdaInv p (charElt p D NE 0 ord) = lambdaDiff D NE ord := by
  rw [lambdaInv_charElt, lambdaDiffMu_mu_zero]

/-- **μ-recovery / inversion, phrased purely at the polynomial level.**  When `D`
has a prime divisor, the `μ`-invariant is recovered from the realised twist data
as the ratio of the `λ`-excess over the classical term by the total μ-weight.
This is `mu_recovery` transported across the bridge onto genuine polynomial
invariants. -/
theorem mu_recovery_polynomial {D NE μ : ℕ} {ord : ℕ → ℕ}
    (hne : D.primeFactors.Nonempty) :
    (lambdaInv p (charElt p D NE μ ord) - lambdaDiff D NE ord) / weightSum D = μ := by
  have hw : 0 < weightSum D := (weightSum_pos_iff D).2 hne
  rw [lambdaInv_charElt]
  have hstep : lambdaDiffMu D NE μ ord - lambdaDiff D NE ord = μ * weightSum D := by
    simp [lambdaDiffMu, muTerm]
  rw [hstep]
  exact Nat.mul_div_cancel _ hw

/-- Consistency check: the recovered `μ` equals the genuine polynomial
`μ`-invariant of the very same characteristic element. -/
theorem mu_recovery_eq_muInv {D NE μ : ℕ} {ord : ℕ → ℕ}
    (hne : D.primeFactors.Nonempty) :
    (lambdaInv p (charElt p D NE μ ord) - lambdaDiff D NE ord) / weightSum D
      = muInv p (charElt p D NE μ ord) := by
  rw [mu_recovery_polynomial p hne, muInv_charElt]

/-- **Non-vanishing μ correction.**  When `D` has a prime divisor and `μ > 0`,
the realised `λ`-invariant strictly exceeds the classical Matsuno term: a
non-vanishing `μ` is visible in the genuine polynomial `λ`-invariant. -/
theorem lambdaInv_charElt_gt {D NE μ : ℕ} {ord : ℕ → ℕ}
    (hne : D.primeFactors.Nonempty) (hμ : 0 < μ) :
    lambdaDiff D NE ord < lambdaInv p (charElt p D NE μ ord) := by
  have hw : 0 < weightSum D := (weightSum_pos_iff D).2 hne
  rw [lambdaInv_charElt]
  have : 0 < muTerm D μ := by unfold muTerm; exact Nat.mul_pos hμ hw
  unfold lambdaDiffMu; omega

/-- **Strict monotonicity of the realised `λ`-invariant in `μ`.**  Distinct
`μ`-invariants produce polynomials with distinct genuine `λ`-invariants. -/
theorem lambdaInv_charElt_strictMono {D NE : ℕ} {ord : ℕ → ℕ}
    (hne : D.primeFactors.Nonempty) :
    StrictMono (fun μ => lambdaInv p (charElt p D NE μ ord)) := by
  have hw : 0 < weightSum D := (weightSum_pos_iff D).2 hne
  intro a b hab
  simp only [lambdaInv_charElt, lambdaDiffMu, muTerm]
  have : a * weightSum D < b * weightSum D := (Nat.mul_lt_mul_right hw).mpr hab
  omega

/-- **Additivity of the realised `λ`-invariant over coprime twisting
parameters.**  This connects the *number-theoretic* additivity of `lambdaDiffMu`
(a sum over prime divisors) with the *commutative-algebra* additivity of the
trailing degree of a polynomial: two entirely different mechanisms give the same
number. -/
theorem lambdaInv_charElt_coprime {a b NE μ : ℕ} {ord : ℕ → ℕ}
    (hab : Nat.Coprime a b) (ha : a ≠ 0) (hb : b ≠ 0) :
    lambdaInv p (charElt p (a * b) NE μ ord)
      = lambdaInv p (charElt p a NE μ ord) + lambdaInv p (charElt p b NE μ ord) := by
  rw [lambdaInv_charElt, lambdaInv_charElt, lambdaInv_charElt,
      lambdaDiffMu_mul_coprime hab ha hb]

/-! ## Part IV. Worked numerical instances (machine-checked, at `p = 2`) -/

/-- With `D = 3`, `NE = 1`, `μ = 1`, and `ord ≡ 1` (so the classical term at `3`
vanishes), the characteristic element has genuine polynomial `μ`-invariant `1`. -/
example : muInv 2 (charElt 2 3 1 1 (fun _ => 1)) = 1 := muInv_charElt 2 3 1 1 _

/-- ... and its genuine `λ`-invariant equals the μ-corrected Matsuno invariant. -/
example : lambdaInv 2 (charElt 2 3 1 1 (fun _ => 1))
    = lambdaDiffMu 3 1 1 (fun _ => 1) := lambdaInv_charElt 2 3 1 1 _

/-- The μ-invariant is recovered from the polynomial twist data. -/
example :
    (lambdaInv 2 (charElt 2 3 1 1 (fun _ => 1)) - lambdaDiff 3 1 (fun _ => 1))
        / weightSum 3 = 1 :=
  mu_recovery_polynomial 2 (by norm_num) (μ := 1)

end MatsunoArithPoly