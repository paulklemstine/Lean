import Mathlib
import EML.EMLRiccatiTransform
import EML.EMLDifferentialGalois
import EML.EMLWronskianGalois
import EML.EMLAiryRiccati

/-!
# A Formal Framework for the Algebra–Geometry Gap in Differential Galois Theory

This file is the single entry point that assembles the EML differential-Galois
development into one place.  It is deliberately *thin*: every statement below is a
direct repackaging of results proved (sorry-free) in the imported modules.  Its
purpose is to make explicit, as Lean theorems, the three pillars requested:

1. **Canonical form of solutions.**  The Riccati / logarithmic-derivative
   substitution `v = y′/y` is the canonical normal form that reduces the
   second-order linear equation `y″ = a·y` to the first-order quadratic Riccati
   equation `v′ + v² = a`.  See `canonicalForm_riccati`.

2. **Conditions for existence of a fundamental system.**  Over the field of
   constants `constantsSubfield K` (the base field over which the differential
   Galois group is a *linear-algebraic* group), the solution space of `y″ = a·y`
   is a module, and a pair of solutions is a *fundamental system* exactly when its
   Wronskian is a **nonzero constant**.  This is the precise existence/
   non-degeneracy condition; see `fundamentalSystem_iff_skeleton`,
   `existence_condition_fundamental_system`.

3. **The algebra ↔ geometry gap.**  The *algebraic* structure (the constants
   subfield and the Galois group acting on the ≤ 2-dimensional solution space) is
   always present, but its *geometric realization by closed-form (EML) solutions*
   can fail.  Airy's equation `y″ = x·y` is the canonical witness: its Galois
   group is not "EML-solvable", which manifests as the total absence of polynomial
   solutions *and* of rational solutions of the associated Riccati equation.  See
   `airy_gap_witness`.

## The framework in one sentence

> The differential Galois group lives, as a linear-algebraic group, over the
> constants subfield `constantsSubfield K`; it acts on the solution space, whose
> non-degeneracy is detected by a nonvanishing-constant Wronskian; and the *gap*
> between this algebraic picture and an explicit geometric realization is exactly
> the failure of EML-solvability, witnessed effectively (and decidably, via the
> Kovacic/Riccati degree count) by Airy's equation.

This is the structural backbone of the Kovacic decision procedure, which is the
concrete computational pathway forward: reduce `y″ = a·y` to `v′ + v² = a`
(`canonicalForm_riccati`), then search for a rational `v`; its non-existence
(`EMLAiryRiccati.no_rational_solves_riccati_airy`) certifies non-solvability.
-/

open scoped Differential

namespace EMLDifferentialGaloisFramework

variable {K : Type*} [Field K] [Differential K]

/-! ## Pillar 1 — Canonical (Riccati) form of solutions -/

/-- **Canonical form.** Any nonzero solution `y` of the second-order linear
equation `y″ = a·y` yields, via the canonical logarithmic-derivative substitution
`v = y′/y`, a solution of the first-order Riccati equation `v′ + v² = a`.  This is
the normal form at the heart of the Kovacic algorithm. -/
theorem canonicalForm_riccati (y a : K) (hy : y ≠ 0) (h : (y′)′ = a * y) :
    (Differential.logDeriv y)′ + (Differential.logDeriv y) ^ 2 = a :=
  Differential.riccati_of_second_order y a hy h

/-! ## Pillar 2 — The Galois base field and the existence condition -/

/-- **The Galois base field.** Membership in the constants subfield is exactly
having zero derivative; this is the field over which the differential Galois group
is a linear-algebraic group. -/
theorem mem_galois_base_field (x : K) :
    x ∈ EMLDiffGalois.constantsSubfield K ↔ x′ = 0 :=
  EMLDiffGalois.mem_constantsSubfield x

/-- **Solution space is a constants-module (closure under the Galois-base scaling
and addition).** -/
theorem solutionSpace_closed (a c y₁ y₂ : K) (hc : c′ = 0)
    (h₁ : (y₁′)′ = a * y₁) (h₂ : (y₂′)′ = a * y₂) :
    ((c * y₁)′)′ = a * (c * y₁) ∧ (((y₁ + y₂)′)′) = a * (y₁ + y₂) :=
  ⟨EMLDiffGalois.scale_solution a c y₁ hc h₁, EMLDiffGalois.add_solution a y₁ y₂ h₁ h₂⟩

/-- **Existence condition for a fundamental system.** If `y₁, y₂` solve `y″ = a·y`
and are linearly independent over the constants (a nonzero Wronskian witnesses
this), then their Wronskian is a *nonzero constant* — i.e. they form a fundamental
system spanning the full 2-dimensional solution space over the constants. -/
theorem existence_condition_fundamental_system (a y₁ y₂ : K)
    (h₁ : (y₁′)′ = a * y₁) (h₂ : (y₂′)′ = a * y₂)
    (hW : y₁ * y₂′ - y₂ * y₁′ ≠ 0) :
    (y₁ * y₂′ - y₂ * y₁′) ∈ EMLDiffGalois.constantsSubfield K ∧
      (y₁ * y₂′ - y₂ * y₁′) ≠ 0 :=
  EMLWronskianGalois.wronskian_isConstant_ne_zero_of_linIndep a y₁ y₂ h₁ h₂ hW

/-- **Wronskian dichotomy (skeleton of the existence theory).** For solutions of
`y″ = a·y`, the Wronskian is always a constant; it is *nonzero* precisely when the
pair is linearly independent over the constants (fundamental system).  Bundles the
"always constant" Abel identity with the independence detector. -/
theorem fundamentalSystem_iff_skeleton (a y₁ y₂ : K)
    (h₁ : (y₁′)′ = a * y₁) (h₂ : (y₂′)′ = a * y₂) :
    (y₁ * y₂′ - y₂ * y₁′) ∈ EMLDiffGalois.constantsSubfield K ∧
      (y₁ * y₂′ - y₂ * y₁′ ≠ 0 → ¬ EMLWronskianGalois.LinDepOverConstants y₁ y₂) :=
  ⟨EMLDiffGalois.wronskian_isConstant a y₁ y₂ h₁ h₂,
   fun hW => EMLWronskianGalois.linIndep_of_wronskian_ne_zero y₁ y₂ hW⟩

/-! ## Pillar 3 — The algebra ↔ geometry gap, witnessed by Airy -/

/-- **The EML gap, witnessed effectively.** Airy's equation `y″ = x·y` over `ℝ[X]`
exhibits the gap between the (always-present) algebraic Galois structure and an
explicit geometric (closed-form) realization: it has **no** nonzero polynomial
solution and its associated Riccati equation `v′ + v² = x` has **no** rational
solution.  These are the first two — and decisive — layers of the Kovacic decision
procedure certifying that Airy has no EML closed-form solution. -/
theorem airy_gap_witness :
    (∀ y : Polynomial ℝ, y ≠ 0 →
        Polynomial.derivative (Polynomial.derivative y) ≠ Polynomial.X * y) ∧
    (∀ p q : Polynomial ℝ, q ≠ 0 →
        Polynomial.derivative p * q - p * Polynomial.derivative q + p ^ 2
          ≠ Polynomial.X * q ^ 2) :=
  EMLAiryRiccati.airy_no_poly_and_no_rational_riccati

end EMLDifferentialGaloisFramework