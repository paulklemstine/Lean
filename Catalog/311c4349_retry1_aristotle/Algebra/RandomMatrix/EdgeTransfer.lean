import Mathlib

open Filter MeasureTheory
open scoped Topology

noncomputable section

namespace RandomMatrix

variable {Ω : Type*} [MeasurableSpace Ω]

/-- Convergence of edge distribution functions at every threshold.  This is a
lightweight formulation of convergence in distribution suitable for stating a
Tracy--Widom transfer principle without presupposing a construction of the
Tracy--Widom measure. -/
def EdgeCDFConverges (X : ℕ → Ω → ℝ) (μ : Measure Ω) (F : ℝ → ℝ) : Prop :=
  ∀ s : ℝ, Tendsto (fun n => μ.real {ω | X n ω ≤ s}) atTop (𝓝 (F s))

/-- A deterministic rescaling of edge statistics. -/
def rescaleEdge (scale center : ℕ → ℝ) (X : ℕ → Ω → ℝ) : ℕ → Ω → ℝ :=
  fun n ω => scale n * (X n ω - center n)

/-- If two edge statistics have identical threshold events at every size, then
convergence of one family to a limiting distribution function transfers to the
other.  This isolates the final universality step after a coupling or comparison
argument has established event equality. -/
theorem edgeCDFConverges_of_event_eq (X Y : ℕ → Ω → ℝ) (μ : Measure Ω)
    (F : ℝ → ℝ) (hXY : ∀ n s, {ω | X n ω ≤ s} = {ω | Y n ω ≤ s})
    (hX : EdgeCDFConverges X μ F) :
    EdgeCDFConverges Y μ F := by
  intro s
  simp_rw [EdgeCDFConverges] at hX ⊢
  convert hX s using 1
  ext n
  rw [hXY n s]

/-- A squeeze transfer theorem for edge distributions.  If the CDF of a target
ensemble is eventually bracketed by two comparison ensembles with the same
pointwise limit, then the target has that limit as well.  This is the abstract
order-theoretic core of comparison-based edge universality proofs. -/
theorem edgeCDFConverges_of_sandwich (lower target upper : ℕ → Ω → ℝ)
    (μ : Measure Ω) (F : ℝ → ℝ)
    (hlower : EdgeCDFConverges lower μ F)
    (hupper : EdgeCDFConverges upper μ F)
    (hlo : ∀ s, ∀ᶠ n in atTop,
      μ.real {ω | lower n ω ≤ s} ≤ μ.real {ω | target n ω ≤ s})
    (hhi : ∀ s, ∀ᶠ n in atTop,
      μ.real {ω | target n ω ≤ s} ≤ μ.real {ω | upper n ω ≤ s}) :
    EdgeCDFConverges target μ F := by
  intro s
  apply tendsto_of_tendsto_of_tendsto_of_le_of_le' (hlower s) (hupper s)
  · exact hlo s
  · exact hhi s

omit [MeasurableSpace Ω] in
/-- Rescaling commutes with pointwise equality of the underlying edge statistic. -/
theorem rescaleEdge_congr (scale center : ℕ → ℝ) (X Y : ℕ → Ω → ℝ)
    (hXY : ∀ n ω, X n ω = Y n ω) :
    rescaleEdge scale center X = rescaleEdge scale center Y := by
  funext n ω
  simp [rescaleEdge, hXY n ω]

end RandomMatrix