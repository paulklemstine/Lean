/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# `n`-variable rank-one EML representations = product separability

`Catalog/Applications/KolmogorovArnoldEMLProduct.lean` shows the `n`-ary product
`∏ xᵢ` collapses to a single outer `exp` of a sum of inner `log`s on positive
inputs.  `Catalog/Applications/KolmogorovArnoldEMLSeparability.lean` characterizes
the two-variable rank-one EML frontier as *multiplicative separability*.

Here we fuse and generalize both: for a target `f : (Fin n → ℝ) → ℝ`, the
following are **equivalent**:

* `RankOneEMLn f` — `f x = exp (∑ i, ψ i (x i))`, a single outer `exp` applied to
  a sum of `n` inner univariate functions (the cleanest possible Kolmogorov–Arnold
  superposition: outer count `1`, inner count `n`);
* `ProdSeparable f` — `f x = ∏ i, a i (x i)` for strictly positive univariate
  factors `a i`.

The bridge is the multiplicativity of `exp` over sums (`Real.exp_sum`): a rank-one
EML target is exactly a product of positive univariate factors, with the inner
functions being the logarithms of the factors.

## Main results
* `rankOneEMLn_iff_prodSeparable` — the characterization (both directions).
* `rankOneEMLn_eml` — the EML-term phrasing via the catalog's `outerExp`.
* `prod_exp_rankOneEMLn` — the canonical instance: `x ↦ ∏ exp (xᵢ)` is rank-one.

## Lab Notes — see `-- !-- Lab Notes -- !--` block below.
-/
import Mathlib
import Catalog.Applications.EMLTermAlgebra
import Catalog.Applications.KolmogorovArnoldEML

open Real Finset

namespace KolmogorovArnoldEMLProdSep

open KolmogorovArnoldEML

variable {n : ℕ}

/-! ### The two `n`-variable predicates -/

/-- `f` is a **product of positive univariate factors**: `f x = ∏ i, a i (x i)`
with each `a i` strictly positive. -/
def ProdSeparable (f : (Fin n → ℝ) → ℝ) : Prop :=
  ∃ a : Fin n → ℝ → ℝ, (∀ i t, 0 < a i t) ∧ ∀ x, f x = ∏ i, a i (x i)

/-- `f` has a **rank-one EML representation**: a single outer `exp` of a sum of
`n` inner univariate functions, `f x = exp (∑ i, ψ i (x i))`. -/
def RankOneEMLn (f : (Fin n → ℝ) → ℝ) : Prop :=
  ∃ ψ : Fin n → ℝ → ℝ, ∀ x, f x = Real.exp (∑ i, ψ i (x i))

/-! ### The characterization -/

/-- A product of positive univariate factors is a rank-one EML target, with inner
functions `ψ i = log ∘ a i`. -/
theorem rankOneEMLn_of_prodSeparable {f : (Fin n → ℝ) → ℝ}
    (h : ProdSeparable f) : RankOneEMLn f := by
  obtain ⟨a, ha_pos, ha⟩ := h
  use fun i => fun t => Real.log (a i t);
  exact fun x => by rw [ ha, Real.exp_sum, Finset.prod_congr rfl fun i _ => Real.exp_log ( ha_pos i _ ) ] ;

/-- A rank-one EML target is a product of positive univariate factors, with
factors `a i = exp ∘ ψ i` (automatically strictly positive). -/
theorem prodSeparable_of_rankOneEMLn {f : (Fin n → ℝ) → ℝ}
    (h : RankOneEMLn f) : ProdSeparable f := by
  obtain ⟨ ψ, hψ ⟩ := h;
  exact ⟨ fun i t => Real.exp ( ψ i t ), fun i t => Real.exp_pos _, fun x => by rw [ hψ, Real.exp_sum ] ⟩

/-- **Characterization.** A rank-one EML representation exists exactly for
products of strictly positive univariate factors. -/
theorem rankOneEMLn_iff_prodSeparable {f : (Fin n → ℝ) → ℝ} :
    RankOneEMLn f ↔ ProdSeparable f :=
  ⟨prodSeparable_of_rankOneEMLn, rankOneEMLn_of_prodSeparable⟩

/-- The rank-one EML representation phrased through the catalog's EML term algebra:
the single outer function is `KolmogorovArnoldEML.outerExp` (`expOf var`). -/
theorem rankOneEMLn_eml {f : (Fin n → ℝ) → ℝ} (h : RankOneEMLn f) :
    ∃ ψ : Fin n → ℝ → ℝ, ∀ x, f x = outerExp.eval (∑ i, ψ i (x i)) := by
  obtain ⟨ψ, hf⟩ := h
  refine ⟨ψ, fun x => ?_⟩
  simp only [outerExp, EMLTerm.eval]
  exact hf x

/-! ### Canonical instance -/

/-- **Canonical rank-one EML target.** The "geometric" functional
`x ↦ ∏ i, exp (xᵢ)` is rank-one EML (with inner functions the identity), since it
equals `exp (∑ i, xᵢ)`. -/
theorem prod_exp_rankOneEMLn :
    RankOneEMLn (fun x : Fin n → ℝ => ∏ i, Real.exp (x i)) := by
  exact ⟨ fun _ => id, fun x => by rw [ Real.exp_sum ] ; rfl ⟩

/-- The canonical instance is also product-separable (factors `a i = exp`). -/
theorem prod_exp_prodSeparable :
    ProdSeparable (fun x : Fin n → ℝ => ∏ i, Real.exp (x i)) :=
  rankOneEMLn_iff_prodSeparable.mp prod_exp_rankOneEMLn

end KolmogorovArnoldEMLProdSep