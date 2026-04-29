import Mathlib

/-! # Series Convergence Bridge

Proves fundamental series convergence results:
1. Geometric series: Σ r^n converges for |r| < 1
2. Subseries convergence from series convergence

Opens SERIES ANALYSIS as a new direction, connecting to
SubadditiveSequenceBridge and GronwallDiscreteBridge.
-/

namespace SeriesConvergenceBridge

/-! ## Section 1: Geometric Series -/

/-- **Geometric series convergence**: Σ r^n converges when |r| < 1.
    The most fundamental convergence test: all ratio/root tests
    reduce to comparison with a geometric series. -/
theorem geometric_summable {r : ℝ} (hr : |r| < 1) :
    Summable fun n => r ^ n :=
  summable_geometric_of_abs_lt_one hr

/-! ## Section 2: Subseries -/

/-- If Σ aₙ converges, then any subseries converges.
    Formally: Summable f ∧ Injective g ⟹ Summable (f ∘ g). -/
theorem summable_subseries {ι γ : Type*} {f : ι → ℝ}
    (hf : Summable f) {g : γ → ι} (hg : Function.Injective g) :
    Summable (f ∘ g) :=
  Summable.comp_injective hf hg

end SeriesConvergenceBridge
