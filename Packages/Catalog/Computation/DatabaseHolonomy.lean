import Mathlib
import Geometry.MissingDataCohomology

/-!
# Where a genuine cohomological obstruction to integration lives

`Catalog/Computation/DatabaseCechComplex.lean` shows that the *data sheaf* (raw
records, restriction = forgetting columns) is acyclic: `H¹ = 0` for every cover,
so gluing never fails for cohomological reasons. This file exhibits the exact
opposite situation for the **calibration sheaf**, whose sections over a nonempty
overlap are the additive offsets (unit conversions, per-source biases) rather
than the records themselves. For three sources arranged in a cycle — pairwise
overlaps nonempty, triple overlap empty — the offsets form a `1`-cocycle
automatically, and:

* `realizable_iff_sum_zero` — a family of pairwise offsets can be realised by
  per-source recalibrations **iff its holonomy around the cycle vanishes**;
* `unit_offset_not_realizable` — the offset family `(1,0,0)` is therefore not
  realisable, an explicit unfixable inconsistency in a database integration
  problem whose every pairwise comparison is consistent;
* `finrank_H1_circular` — the corresponding catalog `DataComplex` has
  `dim H¹ = 1`, exactly the first cohomology of a circle.

Together with the acyclicity theorem this gives a sharp dichotomy: cohomological
obstructions to data integration are invisible to the raw data sheaf and are
created solely by the *transformation* (calibration) coefficients, whose
obstruction is the holonomy of the nerve.

-- !-- Lab Notes -- !--
Hypothesis: data integration has a nonzero cohomological obstruction.
Experiment: compute Čech `H¹` for the calibration coefficients on the cyclic
three-source cover, both as an explicit solvability criterion and as a dimension.
Analysis: solvability of `s_a - s_b = t_{ab}` over a cycle is equivalent to the
vanishing of `t₀₁ + t₁₂ + t₂₀`; the quotient is one-dimensional over any field,
in any characteristic, because the kernel of the coboundary is the constants.
Critique: the example is minimal (three sources); larger nerves give
`dim H¹ = ` first Betti number of the nerve, which is a conjecture recorded in
`FUTURE_DIRECTIONS.md` rather than a theorem here.
Synthesis: raw records are flasque and acyclic; calibrations are twisted and
carry the topology of the nerve. The obstruction to data integration is a
holonomy, not a missing rate.
-- !-- Lab Notes -- !--
-/

open MissingDataCohomology

namespace DatabaseHolonomy

variable (𝕜 : Type*) [Field 𝕜]

/-- Coboundary of the cyclic three-source cover: a per-source recalibration
`s` induces the pairwise offsets `(s₀-s₁, s₁-s₂, s₂-s₀)`. -/
def dCirc : (Fin 3 → 𝕜) →ₗ[𝕜] (Fin 3 → 𝕜) where
  toFun s := ![s 0 - s 1, s 1 - s 2, s 2 - s 0]
  map_add' s t := by
    funext i; fin_cases i <;> simp <;> ring
  map_smul' a s := by
    funext i; fin_cases i <;> simp <;> ring

@[simp] lemma dCirc_apply (s : Fin 3 → 𝕜) :
    dCirc 𝕜 s = ![s 0 - s 1, s 1 - s 2, s 2 - s 0] := rfl

/-- **Holonomy criterion for calibration.** Pairwise offsets between three
data sources can be realised by per-source recalibrations if and only if the
offsets sum to zero around the cycle. -/
theorem realizable_iff_sum_zero (t : Fin 3 → 𝕜) :
    t ∈ LinearMap.range (dCirc 𝕜) ↔ t 0 + t 1 + t 2 = 0 := by
  constructor
  · rintro ⟨s, rfl⟩
    simp
  · intro h
    refine ⟨![t 0 + t 1, t 1, 0], ?_⟩
    funext i
    fin_cases i
    · simp
    · simp
    · simp
      linear_combination -h

/-- An explicit unrealisable offset family: every pair of sources is
individually reconcilable, yet no global recalibration exists. -/
theorem unit_offset_not_realizable :
    ![(1 : 𝕜), 0, 0] ∉ LinearMap.range (dCirc 𝕜) := by
  intro h
  rw [realizable_iff_sum_zero] at h
  simp at h

/-- The kernel of the cyclic coboundary is the line of constant
recalibrations. -/
theorem ker_dCirc : LinearMap.ker (dCirc 𝕜) = 𝕜 ∙ (fun _ => (1 : 𝕜)) := by
  apply le_antisymm
  · intro s hs
    have h := LinearMap.mem_ker.1 hs
    have h0 : s 0 - s 1 = 0 := congrFun h 0
    have h1 : s 1 - s 2 = 0 := congrFun h 1
    refine Submodule.mem_span_singleton.2 ⟨s 0, ?_⟩
    funext i
    fin_cases i
    · simp
    · simp
      linear_combination h0
    · simp
      linear_combination h0 + h1
  · rw [Submodule.span_le]
    rintro _ rfl
    apply LinearMap.mem_ker.2
    funext i
    fin_cases i <;> simp

/-- The calibration complex of the cyclic three-source cover: the triple overlap
is empty, so there are no degree-two constraints. -/
def circComplex : DataComplex 𝕜 where
  C0 := Fin 3 → 𝕜
  C1 := Fin 3 → 𝕜
  C2 := Fin 0 → 𝕜
  d0 := dCirc 𝕜
  d1 := 0
  d_sq := by simp

/-- **A one-dimensional obstruction.** The calibration complex of three cyclically
overlapping sources has `dim H¹ = 1` over every field: the first cohomology of
the circle, realised inside a data-integration problem. -/
theorem finrank_H1_circular : Module.finrank 𝕜 (circComplex 𝕜).H1 = 1 := by
  have hker : Module.finrank 𝕜 (LinearMap.ker (dCirc 𝕜)) = 1 := by
    rw [ker_dCirc]
    rw [finrank_span_singleton (by
      intro h
      have := congrFun h 0
      simp at this)]
  have hrn := LinearMap.finrank_range_add_finrank_ker (dCirc 𝕜)
  have hC0 : Module.finrank 𝕜 (Fin 3 → 𝕜) = 3 := by simp
  have hrange : Module.finrank 𝕜 (LinearMap.range (dCirc 𝕜)) = 2 := by
    rw [hker, hC0] at hrn
    omega
  have hform := (circComplex 𝕜).finrank_H1_formula
  have hd1 : Module.finrank 𝕜 (LinearMap.range (circComplex 𝕜).d1) = 0 := by
    simp [circComplex]
  have hC1 : Module.finrank 𝕜 (circComplex 𝕜).C1 = 3 := by simp [circComplex]
  have hd0 : Module.finrank 𝕜 (LinearMap.range (circComplex 𝕜).d0) = 2 := hrange
  rw [hd0, hd1, hC1] at hform
  omega

end DatabaseHolonomy