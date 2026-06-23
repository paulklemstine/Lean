/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.LWE.SearchDecisionCore
import Cryptography.HardnessHierarchy

/-!
# Regev-Style LWE Hardness Reductions: Quantitative Certificate Interface

This file formalizes the *quantitative interface* for Regev-style worst-case to
average-case reductions for the Learning with Errors (LWE) problem.

## Scope

**This file does not formalize Regev's quantum reduction; it formalizes the
certificate interface and proves the parameter algebra and reduction-composition
consequences.**

Regev's theorem reduces worst-case lattice problems (e.g. `GapSVP`, `SIVP`) to
decision-LWE via a quantum algorithm and analytic Gaussian-measure arguments.
That analytic/quantum ingredient is *assumed* here, packaged as an explicit
field (`quantumReduction`) of a `RegevReductionCertificate`. Everything that is
*deterministic algebra* downstream of that assumption is proved completely:

* the parameter-feasibility algebra relating the noise rate `α`, modulus `q`,
  dimension `n`, and approximation factor `γ`;
* the composition of the assumed worst-case→decision reduction with the
  catalog's search-to-decision reduction, yielding a worst-case→search-LWE
  reduction with multiplicatively composed advantage loss.

## What is proved

* `approx_factor_boundary_identity` — at the feasibility boundary `αq = 2√n`,
  the approximation factor `n/α` equals `q√n/2`.
* `approx_factor_upper_bound` — under `αq ≥ 2√n`, we have `n/α ≤ q√n/2`.
* `noise_feasible_of_dimension_ge_one` — `1 ≤ n` and `αq ≥ 2√n` give `2 ≤ αq`.
* `feasibility_mono_modulus` — feasibility is monotone in the modulus `q`.
* `feasibility_mono_noise` — feasibility is monotone in the noise rate `α`.
* `RegevReductionCertificate.approx_factor_le` — a certificate's approximation
  factor `γ` is bounded by `q√n/2`.
* `regev_certificate_gives_worst_case_to_search_lwe` — the main theorem:
  from a `RegevReductionCertificate`, the catalog search-to-decision reduction,
  and the corresponding advantage hypotheses, one obtains the approximation
  factor bound `γ ≤ q√n/2` together with a composed worst-case→search-LWE
  advantage loss equal to the product of the two loss factors.

## What is assumed

* The Regev quantum/analytic worst-case→decision-LWE reduction, abstracted as the
  `quantumReduction : CryptoReduction` field together with the advantage
  hypothesis supplied to the main theorem. No claim is made that this reduction
  is itself proved here.

## Notes on hypotheses

The lemmas `approx_factor_boundary_identity` and `approx_factor_upper_bound`
include the hypothesis `0 < q` because it is part of the standard LWE
parameter-feasibility setting requested for this interface; the final proofs do
not actually need it (positivity of `α` and nonnegativity of `n` suffice), but it
is retained for faithfulness to the intended statement.

## Catalog dependencies

There is no dedicated `WorstCaseLattice` module in this catalog, so the
worst-case-lattice → decision-LWE reduction is modelled abstractly through the
`CryptoReduction` structure of `Cryptography.HardnessHierarchy` (a reduction
bundled with its multiplicative advantage-loss factor), composed via that file's
`reduction_compose_loss`. The search-to-decision ingredient corresponds to
`Cryptography.LWE.SearchDecisionCore`.
-/

open Real

namespace Cryptography.LWE.RegevCertificate

/-! ## Section 1: Parameter algebra over `ℝ`

These lemmas are pure real-analysis facts about the LWE parameters; they make no
reference to the cryptographic abstractions and are reused by the main theorem. -/

/-- **Boundary identity for the approximation factor.**
At the feasibility boundary `α q = 2 √n`, the approximation factor `n/α`
coincides with `q √n / 2`. -/
theorem approx_factor_boundary_identity
    (n q α : ℝ) (hn : 0 ≤ n) (hα : 0 < α) (hq : 0 < q)
    (hbdry : α * q = 2 * Real.sqrt n) :
    n / α = q * Real.sqrt n / 2 := by
  have hsqrt : (Real.sqrt n) ^ 2 = n := Real.sq_sqrt hn
  have hα' : α ≠ 0 := ne_of_gt hα
  have hm : α * q * Real.sqrt n = 2 * Real.sqrt n * Real.sqrt n := by rw [hbdry]
  field_simp
  nlinarith [hsqrt, hm]

/-- **Upper bound for the approximation factor.**
Under the feasibility condition `α q ≥ 2 √n`, the approximation factor `n/α`
is bounded above by `q √n / 2`. -/
theorem approx_factor_upper_bound
    (n q α : ℝ) (hn : 0 ≤ n) (hα : 0 < α) (hq : 0 < q)
    (hfeas : α * q ≥ 2 * Real.sqrt n) :
    n / α ≤ q * Real.sqrt n / 2 := by
  rw [div_le_iff₀ hα]
  nlinarith [Real.sq_sqrt hn, Real.sqrt_nonneg n, hfeas, hα]

/-- **Noise feasibility in dimension `≥ 1`.**
If `1 ≤ n` and the feasibility condition `α q ≥ 2 √n` holds, then `2 ≤ α q`. -/
theorem noise_feasible_of_dimension_ge_one
    (n q α : ℝ) (hn : 1 ≤ n)
    (hfeas : α * q ≥ 2 * Real.sqrt n) :
    2 ≤ α * q := by
  have h1 : (1 : ℝ) ≤ Real.sqrt n := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt hn
  linarith

/-- **Feasibility is monotone in the modulus.**
Increasing the modulus from `q` to `q' ≥ q` preserves feasibility. -/
theorem feasibility_mono_modulus
    (n q q' α : ℝ) (hα : 0 ≤ α) (hqq' : q ≤ q')
    (hfeas : α * q ≥ 2 * Real.sqrt n) :
    α * q' ≥ 2 * Real.sqrt n := by
  nlinarith [mul_le_mul_of_nonneg_left hqq' hα, hfeas]

/-- **Feasibility is monotone in the noise rate.**
Increasing the noise rate from `α` to `α' ≥ α` preserves feasibility. -/
theorem feasibility_mono_noise
    (n q α α' : ℝ) (hq : 0 ≤ q) (hαα' : α ≤ α')
    (hfeas : α * q ≥ 2 * Real.sqrt n) :
    α' * q ≥ 2 * Real.sqrt n := by
  nlinarith [mul_le_mul_of_nonneg_right hαα' hq, hfeas]

/-! ## Section 2: The certificate interface

We reuse the catalog's `CryptoReduction` abstraction (a reduction together with
its multiplicative advantage-loss factor) from `Cryptography.HardnessHierarchy`.
The Regev quantum/analytic reduction is *assumed* and stored as the
`quantumReduction` field; this file does not prove it. -/

/-- A **Regev reduction certificate** for parameters `(n, q, α, γ)`.

The fields record the parameter-feasibility hypotheses together with the
*assumed* worst-case-lattice → decision-LWE reduction (`quantumReduction`).
The certificate deliberately does **not** assert that Regev's theorem has been
proved; `quantumReduction` is an external assumption that downstream theorems
consume. -/
structure RegevReductionCertificate (n q α γ : ℝ) where
  /-- The dimension is nonnegative. -/
  n_nonneg : 0 ≤ n
  /-- The noise rate is positive. -/
  α_pos : 0 < α
  /-- The modulus is positive. -/
  q_pos : 0 < q
  /-- LWE noise feasibility: `α q ≥ 2 √n`. -/
  noise_feasible : α * q ≥ 2 * Real.sqrt n
  /-- The approximation factor equals `n/α` (Regev's `Õ(n/α)` relation). -/
  approx_eq : γ = n / α
  /-- The *assumed* worst-case-lattice → decision-LWE reduction with its
  advantage-loss factor. This is the external (quantum/analytic) ingredient. -/
  quantumReduction : CryptoReduction

/-- The approximation factor recorded by a certificate is bounded by `q √n / 2`. -/
theorem RegevReductionCertificate.approx_factor_le
    {n q α γ : ℝ} (cert : RegevReductionCertificate n q α γ) :
    γ ≤ q * Real.sqrt n / 2 := by
  rw [cert.approx_eq]
  exact approx_factor_upper_bound n q α cert.n_nonneg cert.α_pos cert.q_pos cert.noise_feasible

/-! ## Section 3: Composition with search-to-decision

The catalog's `reduction_compose_loss` lemma composes two `CryptoReduction`s with
multiplicative loss. Here we instantiate it with the certificate's assumed
worst-case→decision reduction and the catalog search-to-decision reduction. -/

/-- **Main theorem: a Regev certificate yields a worst-case → search-LWE
reduction.**

Given:
* a `RegevReductionCertificate n q α γ`,
* the catalog search-to-decision reduction `searchToDecision` (a `CryptoReduction`),
* the advantage hypothesis of the assumed quantum reduction
  (`adv_decision ≤ quantumReduction.lossFactor * adv_worstcase`), and
* the advantage hypothesis of the search-to-decision reduction
  (`adv_search ≤ searchToDecision.lossFactor * adv_decision`),

one obtains:
* the approximation-factor bound `γ ≤ q √n / 2`, and
* the composed worst-case → search-LWE advantage loss
  `adv_search ≤ (quantumReduction.compose searchToDecision).lossFactor * adv_worstcase`.

No part of Regev's quantum reduction is reproved here: it enters only through the
certificate field and the `h_quantum` hypothesis. -/
theorem regev_certificate_gives_worst_case_to_search_lwe
    {n q α γ : ℝ}
    (cert : RegevReductionCertificate n q α γ)
    (searchToDecision : CryptoReduction)
    (adv_worstcase adv_decision adv_search : ℚ)
    (h_quantum : adv_decision ≤ cert.quantumReduction.lossFactor * adv_worstcase)
    (h_s2d : adv_search ≤ searchToDecision.lossFactor * adv_decision) :
    γ ≤ q * Real.sqrt n / 2 ∧
      adv_search ≤
        (cert.quantumReduction.compose searchToDecision).lossFactor * adv_worstcase :=
  ⟨cert.approx_factor_le,
   reduction_compose_loss cert.quantumReduction searchToDecision
     adv_worstcase adv_decision adv_search h_quantum h_s2d⟩

end Cryptography.LWE.RegevCertificate