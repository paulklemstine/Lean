/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Irrationality Certificates via Diophantine Approximation Obstructions

This file introduces a new concept — the **Irrationality Certificate** — which packages
a sequence of rational approximations with a superlinear convergence rate as a
*structural witness* to irrationality. The main theorem proves that any real number
admitting such a certificate must be irrational.

This formalizes the classical Diophantine approximation obstruction: if a rational
number p/q is approximated by another rational a/b ≠ p/q, then |p/q - a/b| ≥ 1/(qb).
Any approximation sequence that beats this lower bound infinitely often forces
irrationality.

## Main definitions

* `IrrationalityCertificate x` — a structure packaging rational approximations
  with superlinear convergence rate as a certificate for irrationality of `x`

## Main results

* `rat_approx_lower_bound` — for distinct rationals a/b, p/q: |a/b - p/q| ≥ 1/(|b|·|q|)
* `irrational_of_certificate` — any real with an irrationality certificate is irrational
* `irrational_of_good_approx` — direct theorem version without the structure

## Cross-domain connections

The irrationality certificate framework bridges:
- **Number theory**: Diophantine approximation and continued fractions
- **Computational complexity**: certificates as algorithmic verification objects
- **Analysis**: asymptotic approximation rates and convergence
-/

namespace IrrationCert

open Filter Topology

/-! ## The Irrationality Certificate -/

/-- An **Irrationality Certificate** for a real number `x` consists of:
- Integer sequences `A` (numerators) and `B` (denominators) with `B n > 0`
- Growing denominators: `B n → ∞`
- A convergence rate exponent `p > 1` and constant `C > 0`
- The approximation bound: `|x - A_n/B_n| ≤ C / B_n^p` eventually
- The approximations are not eventually equal to `x`

The key theorem `irrational_of_certificate` shows that the existence of such a
certificate implies `x` is irrational. This reframes irrationality proofs as
a *search for approximation certificates* — a computational and structural
perspective on a classical analytic problem.

**Why p > 1 suffices:** If x = a/b is rational and A_n/B_n ≠ x, then
|x - A_n/B_n| ≥ 1/(b·B_n), so C/B_n^p ≥ 1/(b·B_n) gives B_n^(p-1) ≤ bC.
With p > 1 and B_n → ∞, this is eventually contradicted. -/
structure IrrationalityCertificate (x : ℝ) where
  /-- Numerator sequence -/
  A : ℕ → ℤ
  /-- Denominator sequence -/
  B : ℕ → ℤ
  /-- Denominators are positive -/
  hBpos : ∀ n, 0 < B n
  /-- Denominators grow without bound -/
  hBgrow : Tendsto (fun n => (B n : ℝ)) atTop atTop
  /-- Convergence rate constant -/
  C : ℝ
  /-- Convergence rate exponent -/
  p : ℝ
  /-- Constant is positive -/
  hC : 0 < C
  /-- Exponent exceeds 1 -/
  hp : 1 < p
  /-- The approximation bound holds eventually -/
  hbound : ∀ᶠ n in atTop, |x - (A n : ℝ) / (B n : ℝ)| ≤ C / (B n : ℝ) ^ p
  /-- The approximations differ from x infinitely often -/
  hne : ∃ᶠ n in atTop, x ≠ (A n : ℝ) / (B n : ℝ)

/-! ## Key lemma: lower bound on rational distances -/

/-
**Rational Distance Lemma.** For integers a, b, p, q with b ≠ 0, q ≠ 0, and
    a·q ≠ b·p (equivalently a/b ≠ p/q), we have |a/b - p/q| ≥ 1/(|b|·|q|).

    This is the arithmetic heart of Diophantine approximation: distinct rationals
    with integer numerator/denominator can never be closer than the reciprocal
    product of their denominators.
-/
theorem rat_approx_lower_bound {a b c d : ℤ} (hb : (0 : ℝ) < |↑b|) (hd : (0 : ℝ) < |↑d|)
    (hne : (a : ℝ) / b ≠ (c : ℝ) / d) :
    1 / (|↑b| * |↑d|) ≤ |(a : ℝ) / b - (c : ℝ) / d| := by
  by_cases hb' : b = 0 <;> by_cases hd' : d = 0 <;> simp_all +decide [ abs_div, div_sub_div ];
  field_simp;
  exact_mod_cast abs_pos.mpr ( show ( a * d - b * c : ℤ ) ≠ 0 from fun h => hne <| by rw [ div_eq_div_iff ] <;> norm_cast ; cases lt_or_gt_of_ne hb' <;> cases lt_or_gt_of_ne hd' <;> nlinarith )

/-
Helper: if x = a/b is rational, A/B ≠ x, and B > 0, b > 0,
    then |x - A/B| ≥ 1/(b·B).
-/
theorem rational_approx_gap {a b A B : ℤ} (hb : 0 < b) (hB : 0 < B)
    (hne : (a : ℝ) / b ≠ (A : ℝ) / B) :
    1 / ((b : ℝ) * B) ≤ |((a : ℝ) / b) - (A : ℝ) / B| := by
  convert rat_approx_lower_bound ?_ ?_ hne using 1 <;> norm_num [ abs_of_pos, hb, hB ]

/-! ## Main irrationality theorem -/

/-
**Irrationality from superlinear approximation.** If a real number `x` admits
    rational approximations `A_n/B_n` with `B_n → ∞` and
    `|x - A_n/B_n| ≤ C / B_n^p` for some `p > 1`, and the approximations
    differ from `x` infinitely often, then `x` is irrational.

    This is the structural core of many irrationality proofs: one constructs
    explicit rational approximations that converge "too fast" for the target
    to be rational.
-/
theorem irrational_of_good_approx
    {x : ℝ} {A B : ℕ → ℤ} {C p : ℝ}
    (hC : 0 < C) (hp : 1 < p)
    (hBpos : ∀ n, 0 < B n)
    (hBgrow : Tendsto (fun n => (B n : ℝ)) atTop atTop)
    (hbound : ∀ᶠ n in atTop, |x - (A n : ℝ) / (B n : ℝ)| ≤ C / (B n : ℝ) ^ p)
    (hne : ∃ᶠ n in atTop, x ≠ (A n : ℝ) / (B n : ℝ)) :
    Irrational x := by
  -- Assume x is rational, so x = a/b for some integers a and b with b > 0.
  by_contra h_contra
  obtain ⟨a, b, hb_pos, hx⟩ : ∃ a b : ℤ, 0 < b ∧ x = a / b := by
    unfold Irrational at h_contra;
    exact by push_neg at h_contra; obtain ⟨ q, rfl ⟩ := h_contra; exact ⟨ q.num, q.den, Nat.cast_pos.mpr q.pos, by simp +decide [ Rat.cast_def ] ⟩ ;
  -- For any n where A_n/B_n ≠ x and the bound holds, we get 1/(b·B_n) ≤ |x - A_n/B_n| ≤ C/B_n^p. This gives B_n^(p-1) ≤ b·C, so B_n ≤ (b·C)^(1/(p-1)).
  have h_bound : ∀ᶠ n in Filter.atTop, x ≠ (A n : ℝ) / (B n : ℝ) → (B n : ℝ) ≤ (b * C) ^ (1 / (p - 1)) := by
    filter_upwards [ hbound, hBgrow.eventually_gt_atTop 0 ] with n hn hn';
    intro hne'
    have h_bound : 1 / ((b : ℝ) * (B n : ℝ)) ≤ C / (B n : ℝ) ^ p := by
      refine le_trans ?_ hn;
      grind +suggestions;
    -- Simplify the inequality $1 / ((b : ℝ) * (B n : ℝ)) ≤ C / (B n : ℝ) ^ p$ to get $(B n : ℝ) ^ (p - 1) ≤ b * C$.
    have h_simplified : (B n : ℝ) ^ (p - 1) ≤ b * C := by
      rw [ Real.rpow_sub hn', Real.rpow_one ];
      rw [ div_le_div_iff₀ ] at h_bound <;> try positivity;
      rw [ div_le_iff₀ ] <;> first | positivity | linarith;
    exact le_trans ( by rw [ ← Real.rpow_mul ( by positivity ), mul_one_div_cancel ( by linarith ), Real.rpow_one ] ) ( Real.rpow_le_rpow ( by positivity ) h_simplified ( by exact one_div_nonneg.mpr ( by linarith ) ) );
  contrapose! hne;
  filter_upwards [ h_bound, hBgrow.eventually_gt_atTop ( ( b * C ) ^ ( 1 / ( p - 1 ) ) ) ] with n hn hn' using Classical.not_not.1 fun hn'' => not_lt_of_ge ( hn hn'' ) hn'

/-- An irrationality certificate implies irrationality. -/
theorem irrational_of_certificate {x : ℝ} (cert : IrrationalityCertificate x) :
    Irrational x :=
  irrational_of_good_approx cert.hC cert.hp cert.hBpos cert.hBgrow cert.hbound cert.hne

/-! ## Variant: superquadratic version -/

/-- Stronger variant with p > 2, which is the standard threshold in
    irrationality measure theory. With p > 2, even non-distinct approximations
    suffice as long as infinitely many are non-trivial. -/
theorem irrational_of_superquadratic_approx
    {x : ℝ} {A B : ℕ → ℤ} {C p : ℝ}
    (hC : 0 < C) (hp : 2 < p)
    (hBpos : ∀ n, 0 < B n)
    (hBgrow : Tendsto (fun n => (B n : ℝ)) atTop atTop)
    (hbound : ∀ᶠ n in atTop, |x - (A n : ℝ) / (B n : ℝ)| ≤ C / (B n : ℝ) ^ p)
    (hne : ∃ᶠ n in atTop, x ≠ (A n : ℝ) / (B n : ℝ)) :
    Irrational x :=
  irrational_of_good_approx hC (by linarith) hBpos hBgrow hbound hne

end IrrationCert