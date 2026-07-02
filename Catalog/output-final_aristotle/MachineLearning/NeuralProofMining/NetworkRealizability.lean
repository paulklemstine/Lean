/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Exact Realizability of Logical Concepts by Single-Activation Networks

This file is the *NeuralProofMining* bridge between **MachineLearning** and
**Logic**.  Building on the EML universal-approximation backbone
(`EML.ExponentialPolynomialDensity`) and the exact interpolation principle of
`SeparatingInterpolation.lean`, we show that a *single-neuron network with a
polynomial read-out* is not only a universal approximator but an **exact
finite realizer**:

* it interpolates any finite dataset exactly (`net_interpolates`), and
* it realizes **every Boolean concept** (logical decision function) on a finite
  set of distinct inputs *exactly*, with a guaranteed unit classification
  margin (`net_classifies_boolean`).

The Boolean-concept theorem is the concrete ML ↔ Logic bridge: any
`ℓ : Fin n → Bool` — i.e. an arbitrary logical predicate on the sample points —
is reproduced by the *sign* of a single-activation network, with margin `1`.

## Main results

* `net_separatesPoints` — a single-activation network subalgebra separates
  points as soon as the composed feature `σ ∘ g` is injective (uses the catalog
  result `EMLExpFeature.separatesPoints_of_injective_mem`).
* `net_interpolates` — exact finite interpolation by a single-activation network.
* `net_realizes_boolean` — a network hits the prescribed `±1` targets of any
  Boolean labeling exactly.
* `net_classifies_boolean` — the sign of the network reproduces the Boolean
  concept with unit margin.
* `exp_net_classifies_Icc` — concrete instantiation on a compact interval using
  the catalog exponential feature `exp ∘ (coordinate on [a,b])`.

-- !-- Lab Notes -- !--
HYPOTHESIS (R1). The universality of single-activation networks
(`EMLActivationDensity`) is *approximate*; but the underlying point separation
is strong enough to make finite realizability *exact* — an arbitrary Boolean
concept on distinct points is realized on the nose, not merely up to ε.

EXPERIMENT. Compose two catalog facts. (a) `separatesPoints_of_injective_mem`:
the network subalgebra `adjoin ℝ {σ ∘ g}` separates points because it contains
the injective generator `σ ∘ g`. (b) `exists_mem_interp_of_separatesPoints`
(this cycle): separation forces exact interpolation. Feeding `±1` targets from a
Boolean labeling yields exact `±1` outputs, whose sign is the label and whose
absolute value (the classification margin) is exactly `1`.
OUTCOME: R1 confirmed for every injective composed feature, in particular the
catalog exponential feature on `[a,b]`.

INSIGHT. "Universal approximator" is a topological statement; "exact finite
realizer with margin" is an algebraic one. Point separation is the common cause,
so the same injectivity hypothesis that powers density also powers exact logical
realizability — no extra analytic assumption is needed.

CRITIQUE. The margin here is measured in the *output* coordinate (unit margin in
value space), not an input-space geometric margin; the latter needs a metric and
Lipschitz control and is recorded as a future direction. The result is vacuous
only if the input family is empty (`n = 0`), in which case all statements hold
trivially and truthfully.
-/
import Mathlib
import EML.ExponentialPolynomialDensity
import MachineLearning.NeuralProofMining.SeparatingInterpolation

open ContinuousMap

namespace NeuralProofMining

variable {X : Type*} [TopologicalSpace X]

/-- The subalgebra of `C(X, ℝ)` realized by a **single-activation network**:
polynomial read-outs of the composed feature `σ ∘ g` (one neuron with activation
`σ` on the feature map `g`). -/
def netAlg (σ : C(ℝ, ℝ)) (g : C(X, ℝ)) : Subalgebra ℝ C(X, ℝ) :=
  Algebra.adjoin ℝ {σ.comp g}

/-- A single-activation network subalgebra separates points whenever the composed
feature `σ ∘ g` is injective. Uses the catalog lemma
`EMLExpFeature.separatesPoints_of_injective_mem`. -/
theorem net_separatesPoints (σ : C(ℝ, ℝ)) (g : C(X, ℝ))
    (hinj : Function.Injective (σ.comp g)) :
    (netAlg σ g).SeparatesPoints :=
  EMLExpFeature.separatesPoints_of_injective_mem _ (σ.comp g)
    (Algebra.self_mem_adjoin_singleton ℝ _) hinj

/-- **Exact finite interpolation by a single-activation network.**
If the composed feature `σ ∘ g` is injective, then for any finite family of
distinct inputs and arbitrary targets there is a single network function hitting
all targets exactly. -/
theorem net_interpolates (σ : C(ℝ, ℝ)) (g : C(X, ℝ))
    (hinj : Function.Injective (σ.comp g))
    {n : ℕ} (x : Fin n → X) (hx : Function.Injective x) (t : Fin n → ℝ) :
    ∃ f ∈ netAlg σ g, ∀ i, f (x i) = t i :=
  exists_mem_interp_of_separatesPoints _ (net_separatesPoints σ g hinj) x hx t

/-- **Exact `±1` realization of a Boolean concept.**
For any Boolean labeling `ℓ` of distinct inputs, a single-activation network hits
`+1` on the `true`-labeled points and `-1` on the `false`-labeled points, exactly. -/
theorem net_realizes_boolean (σ : C(ℝ, ℝ)) (g : C(X, ℝ))
    (hinj : Function.Injective (σ.comp g))
    {n : ℕ} (x : Fin n → X) (hx : Function.Injective x) (ℓ : Fin n → Bool) :
    ∃ f ∈ netAlg σ g, ∀ i, f (x i) = (if ℓ i then (1 : ℝ) else -1) :=
  net_interpolates σ g hinj x hx (fun i => if ℓ i then 1 else -1)

/-- **ML ↔ Logic bridge: exact Boolean classification with unit margin.**
The *sign* of a single-activation network reproduces any Boolean concept `ℓ` on a
finite set of distinct inputs, and the classification margin (absolute output
value) is at least `1` at every sample point. -/
theorem net_classifies_boolean (σ : C(ℝ, ℝ)) (g : C(X, ℝ))
    (hinj : Function.Injective (σ.comp g))
    {n : ℕ} (x : Fin n → X) (hx : Function.Injective x) (ℓ : Fin n → Bool) :
    ∃ f ∈ netAlg σ g, ∀ i, (0 < f (x i) ↔ ℓ i = true) ∧ 1 ≤ |f (x i)| := by
  obtain ⟨f, hf, hval⟩ := net_realizes_boolean σ g hinj x hx ℓ
  refine ⟨f, hf, fun i => ?_⟩
  rw [hval i]
  cases ℓ i <;> simp

/-- **Concrete instantiation on a compact interval.**
Using the catalog exponential feature `exp ∘ (coordinate on [a,b])`, every Boolean
concept on distinct sample points of `[a,b]` is exactly classified with unit
margin by an exponential single-activation network. -/
theorem exp_net_classifies_Icc (a b : ℝ)
    {n : ℕ} (x : Fin n → Set.Icc a b) (hx : Function.Injective x) (ℓ : Fin n → Bool) :
    ∃ f ∈ netAlg EMLExpFeature.expCM (EMLExpFeature.iccCoord a b),
      ∀ i, (0 < f (x i) ↔ ℓ i = true) ∧ 1 ≤ |f (x i)| :=
  net_classifies_boolean EMLExpFeature.expCM (EMLExpFeature.iccCoord a b)
    (EMLExpFeature.injective_expCM_comp _ (EMLExpFeature.injective_iccCoord a b)) x hx ℓ

end NeuralProofMining