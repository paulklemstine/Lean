import Mathlib

/-!
# The Jarzynski Equality and the Finite-Size Landauer Bound

This file develops, from first principles over a finite probability space, the
relationship between the (nonequilibrium) **Jarzynski equality** and **Landauer's
principle** for the erasure of a one-bit memory.

The development is split into two independent parts that are only combined in the
final specialization:

* **Information-theoretic part.** We compute the Shannon entropy of the uniform
  distribution and of a (deterministically) erased distribution on `Bool`, observe
  that the erasure map is not injective, and read off the entropy loss `log 2`.

* **Thermodynamic part.** From the finite Jarzynski equality
  `E[exp(-α W)] = exp(-α ΔF)` we derive the exact fluctuation correction
  `E[W] = ΔF + α⁻¹ · log E[exp(-α (W - E[W]))]` (`jarzynski_correction`).

* **Specialization.** Substituting the free-energy difference `ΔF = log 2 / α`
  (equivalently, the entropy loss `log 2` divided by the inverse temperature `α`)
  gives the finite-size Landauer identity for a one-bit memory
  (`landauer_identity`).

## Main definitions

* `expect` — expectation of an observable with respect to a weight function.
* `IsPMF` — predicate that a weight function is a probability mass function.
* `JarzynskiCondition` — the finite Jarzynski equality.
* `shannonEntropy` — Shannon entropy with the convention `0 * log 0 = 0`.

## Main results

* `entropy_uniformBool` — the uniform bit has entropy `log 2`.
* `entropy_erasedBool` — a fully erased bit has entropy `0`.
* `erasure_not_injective` — the erasure map `Bool → Bool` is not injective.
* `entropy_loss` — the entropy lost in erasing a uniform bit is `log 2`.
* `jarzynski_correction` — the fluctuation correction to the mean work.
* `landauer_identity` — the finite-size Landauer bound for a one-bit memory.
-/

noncomputable section

open Finset BigOperators Real

namespace JarzynskiLandauer

variable {Ω : Type*} [Fintype Ω]

/-- Expectation of an observable `f` with respect to a weight function `p`. -/
def expect (p : Ω → ℝ) (f : Ω → ℝ) : ℝ := ∑ ω, p ω * f ω

/-- `p` is a probability mass function: nonnegative and summing to one. -/
def IsPMF (p : Ω → ℝ) : Prop := (∀ ω, 0 ≤ p ω) ∧ ∑ ω, p ω = 1

/-- The finite **Jarzynski equality**: `E[exp(-α W)] = exp(-α ΔF)`. -/
def JarzynskiCondition (p : Ω → ℝ) (W : Ω → ℝ) (α ΔF : ℝ) : Prop :=
  expect p (fun ω => Real.exp (-α * W ω)) = Real.exp (-α * ΔF)

/-- **Shannon entropy** of a weight function, using `Real.negMulLog` which encodes
the convention `0 * log 0 = 0`. -/
def shannonEntropy (p : Ω → ℝ) : ℝ := ∑ ω, Real.negMulLog (p ω)

/-! ### Information-theoretic part: entropy of a single bit -/

/-- The uniform distribution on a bit. -/
def uniformBool : Bool → ℝ := fun _ => 1 / 2

/-- A fully erased bit: all the mass sits on `false`. -/
def erasedBool : Bool → ℝ := fun b => if b then 0 else 1

/-- The (deterministic) erasure map collapses every bit to `false`. -/
def erasure : Bool → Bool := fun _ => false

/-- The uniform bit has Shannon entropy `log 2`. -/
theorem entropy_uniformBool : shannonEntropy uniformBool = Real.log 2 := by
  simp [shannonEntropy, uniformBool, Real.negMulLog, one_div, Real.log_inv]

/-- A fully erased bit has zero Shannon entropy. -/
theorem entropy_erasedBool : shannonEntropy erasedBool = 0 := by
  -- The Shannon entropy of the erased bit is zero because there is no uncertainty about the outcome.
  simp [shannonEntropy, erasedBool]

/-- The erasure map `Bool → Bool` is not injective. -/
theorem erasure_not_injective : ¬ Function.Injective erasure := by
  decide +kernel

/-- The entropy lost in erasing a uniform bit equals `log 2`. -/
theorem entropy_loss :
    shannonEntropy uniformBool - shannonEntropy erasedBool = Real.log 2 := by
  rw [ entropy_uniformBool, entropy_erasedBool, sub_zero ]

/-! ### Thermodynamic part: the Jarzynski fluctuation correction -/

/-- **Jarzynski fluctuation correction.** From the finite Jarzynski equality one
derives the exact relation between the mean work, the free-energy difference, and
the fluctuations of the work:
`E[W] = ΔF + α⁻¹ · log E[exp(-α (W - E[W]))]`. -/
theorem jarzynski_correction (p : Ω → ℝ) (W : Ω → ℝ) (α ΔF : ℝ) (hα : α ≠ 0)
    (hJ : JarzynskiCondition p W α ΔF) :
    expect p W = ΔF +
      α⁻¹ * Real.log (expect p (fun ω => Real.exp (-α * (W ω - expect p W)))) := by
  -- Factor the work fluctuation `exp(-α (W - E[W]))` into a constant times `exp(-α W)`.
  have hfun : (fun ω => Real.exp (-α * (W ω - expect p W)))
      = (fun ω => Real.exp (α * expect p W) * Real.exp (-α * W ω)) := by
    funext ω; rw [← Real.exp_add]; ring_nf
  -- Pull the constant out of the expectation and apply the Jarzynski equality.
  have h_exp : expect p (fun ω => Real.exp (-α * (W ω - expect p W)))
      = Real.exp (α * expect p W) * Real.exp (-α * ΔF) := by
    rw [hfun]
    rw [show expect p (fun ω => Real.exp (α * expect p W) * Real.exp (-α * W ω))
        = Real.exp (α * expect p W) * expect p (fun ω => Real.exp (-α * W ω)) by
      simp only [expect, Finset.mul_sum]; exact Finset.sum_congr rfl (fun ω _ => by ring)]
    rw [hJ]
  rw [h_exp, ← Real.exp_add, Real.log_exp]
  field_simp
  ring

/-! ### Specialization: the finite-size Landauer bound -/

/-- **Finite-size Landauer identity for a one-bit memory.** Substituting the
free-energy difference `ΔF = (H(uniform) - H(erased)) / α = log 2 / α` into the
Jarzynski correction yields the exact relation between the mean dissipated work,
the Landauer free-energy cost, and the work fluctuations. -/
theorem landauer_identity (p : Ω → ℝ) (W : Ω → ℝ) (α : ℝ) (hα : α ≠ 0)
    (hJ : JarzynskiCondition p W α
      ((shannonEntropy uniformBool - shannonEntropy erasedBool) / α)) :
    expect p W = (shannonEntropy uniformBool - shannonEntropy erasedBool) / α +
      α⁻¹ * Real.log (expect p (fun ω => Real.exp (-α * (W ω - expect p W)))) :=
  jarzynski_correction p W α _ hα hJ

end JarzynskiLandauer

end