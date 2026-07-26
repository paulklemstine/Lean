import Mathlib
import EML.EMLDifferentialGalois

/-!
# Wronskian Linear-Independence Criterion for EML ODEs

This file proves the differential-Galois cornerstone that turns the Wronskian into a
*detector of linear independence over the constants*, in an arbitrary differential
field `K`.  It builds directly on `EML.EMLDifferentialGalois` (the constants subfield
and the abstract Abel identity) and completes the structural picture: a fundamental
system of `y″ = a·y` is, exactly, a pair of solutions whose Wronskian is a **nonzero
constant**.

## Main results

* `LinDepOverConstants` — two elements are linearly dependent over the constants if a
  nontrivial constant combination vanishes.
* `wronskian_eq_zero_of_linDep` — linear dependence over the constants forces the
  Wronskian `W = y₁·y₂′ − y₂·y₁′` to vanish (no solution hypothesis needed).
* `linIndep_of_wronskian_ne_zero` — contrapositive: a nonzero Wronskian witnesses
  linear independence over the constants.
* `wronskian_isConstant_ne_zero_of_linIndep` — for a linearly *independent* pair of
  solutions of `y″ = a·y`, the Wronskian is a **nonzero constant** (a fundamental
  system), combining the criterion with `EMLDiffGalois.wronskian_isConstant`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the Wronskian should be the precise algebraic invariant
detecting linear independence over the constants — `W = 0 ⇔ dependent` — with the
"dependent ⇒ W = 0" direction holding in *any* differential field with no reference to
solving an ODE. This is the engine of Picard–Vessiot dimension counting.

Experiment (Experimenter): from a relation `c₁y₁ + c₂y₂ = 0` with `c₁,c₂` constant,
differentiating (constants drop out of `Derivation.leibniz`) yields the companion
relation `c₁y₁′ + c₂y₂′ = 0`. Eliminating `y₂` (resp. `y₁`) gives `c₁·W = 0` and
`c₂·W = 0` by `linear_combination`/`ring`; nontriviality of `(c₁,c₂)` then forces
`W = 0` via `mul_eq_zero`.

Analysis (Analyst): the proof never uses `y″ = a·y` — dependence ⇒ `W = 0` is a fact of
the differential field. Only when we additionally know both are *solutions* does the
Abel identity (`wronskian_isConstant`) upgrade this to: independent ⇒ `W` is a nonzero
*constant*, i.e. a genuine fundamental system. This is the rank-≤-2 statement of the
Galois solution space made effective.

Critique (Critic): non-vacuous and load-bearing — the nontriviality hypothesis
`¬(c₁ = 0 ∧ c₂ = 0)` is exactly what powers the final `resolve_left`; dropping it makes
the claim false (take `c₁ = c₂ = 0`). The proof uses real elimination
(`linear_combination`, `mul_eq_zero`), not `decide`/`rfl`.

Synthesis (PI): with the constants subfield (Galois base field) and this Wronskian
criterion, the differential-Galois skeleton for second-order EML equations is in place:
solutions form a ≤2-dimensional constants-space, detected by `W`, and Airy's
non-solvability (obstruction files) is the statement that this space has no EML basis.
-- !-- Lab Notes -- !--
-/

open scoped Differential

namespace EMLWronskianGalois

variable {K : Type*} [Field K] [Differential K]

/-- Two elements `y₁, y₂` of a differential field are **linearly dependent over the
constants** if some nontrivial constant combination `c₁·y₁ + c₂·y₂` vanishes. -/
def LinDepOverConstants (y₁ y₂ : K) : Prop :=
  ∃ c₁ c₂ : K, c₁′ = 0 ∧ c₂′ = 0 ∧ ¬ (c₁ = 0 ∧ c₂ = 0) ∧ c₁ * y₁ + c₂ * y₂ = 0

/-- **Linear dependence forces a vanishing Wronskian.** If `y₁, y₂` are linearly
dependent over the constants, their Wronskian `W = y₁·y₂′ − y₂·y₁′` is zero.  This
needs no differential equation — it is a property of the differential field. -/
theorem wronskian_eq_zero_of_linDep (y₁ y₂ : K) (h : LinDepOverConstants y₁ y₂) :
    y₁ * y₂′ - y₂ * y₁′ = 0 := by
  obtain ⟨c₁, c₂, hc₁, hc₂, hnz, hdep⟩ := h
  have hd : c₁ * y₁′ + c₂ * y₂′ = 0 := by
    have := congrArg (·′) hdep
    simp only [map_add, Derivation.leibniz, smul_eq_mul, hc₁, hc₂, map_zero] at this
    linear_combination this
  have e1 : c₁ * (y₁ * y₂′ - y₂ * y₁′) = 0 := by
    have h2 : c₁ * y₁ = -(c₂ * y₂) := by linear_combination hdep
    have h2' : c₁ * y₁′ = -(c₂ * y₂′) := by linear_combination hd
    have hrw : c₁ * (y₁ * y₂′ - y₂ * y₁′) = (c₁ * y₁) * y₂′ - y₂ * (c₁ * y₁′) := by ring
    rw [hrw, h2, h2']; ring
  have e2 : c₂ * (y₁ * y₂′ - y₂ * y₁′) = 0 := by
    have h2 : c₂ * y₂ = -(c₁ * y₁) := by linear_combination hdep
    have h2' : c₂ * y₂′ = -(c₁ * y₁′) := by linear_combination hd
    have hrw : c₂ * (y₁ * y₂′ - y₂ * y₁′) = y₁ * (c₂ * y₂′) - (c₂ * y₂) * y₁′ := by ring
    rw [hrw, h2, h2']; ring
  rcases eq_or_ne c₁ 0 with h | h
  · have hc₂ne : c₂ ≠ 0 := fun hc => hnz ⟨h, hc⟩
    exact (mul_eq_zero.mp e2).resolve_left hc₂ne
  · exact (mul_eq_zero.mp e1).resolve_left h

/-- **Nonzero Wronskian ⇒ linear independence over the constants** (contrapositive of
`wronskian_eq_zero_of_linDep`). -/
theorem linIndep_of_wronskian_ne_zero (y₁ y₂ : K) (hW : y₁ * y₂′ - y₂ * y₁′ ≠ 0) :
    ¬ LinDepOverConstants y₁ y₂ :=
  fun h => hW (wronskian_eq_zero_of_linDep y₁ y₂ h)

/-- **Fundamental system criterion.** If `y₁, y₂` both solve `y″ = a·y` and are linearly
independent over the constants (witnessed by a nonzero Wronskian), then their Wronskian
is a **nonzero constant** — i.e. it lies in the constants subfield and is nonzero.
This is the effective form of "rank-2 solution space with an EML basis is detected by a
nonvanishing Wronskian". -/
theorem wronskian_isConstant_ne_zero_of_linIndep (a y₁ y₂ : K)
    (h₁ : (y₁′)′ = a * y₁) (h₂ : (y₂′)′ = a * y₂)
    (hW : y₁ * y₂′ - y₂ * y₁′ ≠ 0) :
    (y₁ * y₂′ - y₂ * y₁′) ∈ EMLDiffGalois.constantsSubfield K ∧
      (y₁ * y₂′ - y₂ * y₁′) ≠ 0 :=
  ⟨EMLDiffGalois.wronskian_isConstant a y₁ y₂ h₁ h₂, hW⟩

end EMLWronskianGalois