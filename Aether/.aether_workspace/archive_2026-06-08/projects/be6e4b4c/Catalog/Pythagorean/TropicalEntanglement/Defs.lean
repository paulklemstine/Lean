/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Entanglement Certificates — Core Definitions

This file introduces the core definitions for **tropical entanglement certificates**,
a new framework connecting tropical geometry and quantum information theory.

The central idea is that multipartite quantum entanglement leaves a detectable
"tropical footprint" in the support and coefficient geometry of the state's
magnitude polynomial. Product states exhibit rectangular support structure that
forces a combinatorial witness to vanish, while genuinely entangled states like
GHZ and W have non-rectangular support yielding strictly positive witnesses.

## Main Definitions

* `TropicalEntanglement.mixConfig` — Mix two configurations along a partition
* `TropicalEntanglement.IsProductAcross` — A state factors across a bipartition
* `TropicalEntanglement.FullySeparable` — A state is a product over all parties
* `TropicalEntanglement.tropicalPartitionWitness` — The tropical partition witness
* `TropicalEntanglement.GenuineTropicalEntangled` — Positive witness on all cuts
* `TropicalEntanglement.ghzState` — The GHZ state on n qubits
* `TropicalEntanglement.wState` — The W state on n qubits
* `TropicalEntanglement.crossSupportCount` — Cross-support combinatorial invariant

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Horodecki et al., "Quantum entanglement", Reviews of Modern Physics, 2009
-/

open Finset BigOperators

noncomputable section

namespace TropicalEntanglement

/-! ## §1. Configuration Mixing -/

/-- Mix two configurations along a partition `A`.
    Takes `A`-components from `s` and `Aᶜ`-components from `t`.

    This is the fundamental operation for partition-based entanglement analysis:
    if a state factors across `A`, then `ψ(mixConfig A s t)` decomposes as
    `φ_A(s) · χ_{Aᶜ}(t)`. -/
def mixConfig {ι : Type*} [DecidableEq ι] {d : Type*}
    (A : Finset ι) (s t : ι → d) : ι → d :=
  fun i => if i ∈ A then s i else t i

@[simp]
theorem mixConfig_mem {ι : Type*} [DecidableEq ι] {d : Type*}
    (A : Finset ι) (s t : ι → d) (i : ι) (hi : i ∈ A) :
    mixConfig A s t i = s i := by
  simp [mixConfig, hi]

@[simp]
theorem mixConfig_not_mem {ι : Type*} [DecidableEq ι] {d : Type*}
    (A : Finset ι) (s t : ι → d) (i : ι) (hi : i ∉ A) :
    mixConfig A s t i = t i := by
  simp [mixConfig, hi]

theorem mixConfig_self {ι : Type*} [DecidableEq ι] {d : Type*}
    (A : Finset ι) (s : ι → d) :
    mixConfig A s s = s := by
  ext i; simp [mixConfig]

/-! ## §2. Product States and Separability -/

/-- A state `ψ` is a **product across partition `A`** if it factors as
    `ψ(s) = φ(s) · χ(s)` where `φ` depends only on coordinates in `A`
    and `χ` depends only on coordinates outside `A`.

    This captures the quantum notion of a state being separable with
    respect to the bipartition `(A, Aᶜ)`. -/
def IsProductAcross {ι : Type*} [DecidableEq ι] {d : Type*}
    (A : Finset ι) (ψ : (ι → d) → ℂ) : Prop :=
  ∃ (φ χ : (ι → d) → ℂ),
    (∀ s, ψ s = φ s * χ s) ∧
    (∀ s t, (∀ i ∈ A, s i = t i) → φ s = φ t) ∧
    (∀ s t, (∀ i, i ∉ A → s i = t i) → χ s = χ t)

/-- A state is **fully separable** if it factors as a product over all parties:
    `ψ(s) = ∏ᵢ φᵢ(sᵢ)`. This is the strongest form of non-entanglement. -/
def FullySeparable {ι : Type*} [Fintype ι] [DecidableEq ι] {d : Type*}
    (ψ : (ι → d) → ℂ) : Prop :=
  ∃ (φ : ι → d → ℂ), ∀ s, ψ s = ∏ i : ι, φ i (s i)

/-! ## §3. The Tropical Partition Witness -/

/-- The **tropical partition witness** for a state `ψ` across bipartition `A`.

    For each pair of configurations `(s, t)`, measures the excess of
    `|ψ(s)| · |ψ(t)|` over `|ψ(mixConfig A s t)| · |ψ(mixConfig A t s)|`,
    clamped to be nonnegative.

    **Key property**: For product states, each term vanishes because
    coefficient factorization across `A` ensures multiplicative compatibility.
    For entangled states like GHZ and W, support non-rectangularity
    forces strictly positive terms.

    This is the central definition of tropical entanglement certificate theory. -/
def tropicalPartitionWitness {ι : Type*} [Fintype ι] [DecidableEq ι]
    (d : Type*) [Fintype d]
    (A : Finset ι) (ψ : (ι → d) → ℂ) : ℝ :=
  ∑ s : ι → d, ∑ t : ι → d,
    max (‖ψ s‖ * ‖ψ t‖ - ‖ψ (mixConfig A s t)‖ * ‖ψ (mixConfig A t s)‖) 0

/-- A state is **genuinely tropical entangled** if the tropical partition witness
    is strictly positive on every nontrivial bipartition.

    **Falsifiable conjecture**: For states with nonneg magnitudes and
    full support-positivity, this condition implies genuine multipartite
    entanglement in the quantum information sense. This is testable on
    GHZ, W, product, and biseparable states for small n. -/
def GenuineTropicalEntangled {ι : Type*} [Fintype ι] [DecidableEq ι]
    (d : Type*) [Fintype d]
    (ψ : (ι → d) → ℂ) : Prop :=
  ∀ A : Finset ι, A.Nonempty → A ≠ Finset.univ →
    0 < tropicalPartitionWitness d A ψ

/-! ## §4. Canonical Quantum States -/

/-- The **GHZ state** on `n` qubits. The state has amplitude 1 on the all-zeros
    and all-ones configurations, and 0 elsewhere.

    For `n ≥ 3`, this is the canonical example of genuine multipartite
    entanglement that is not equivalent to the W state under SLOCC. -/
def ghzState (n : ℕ) : (Fin n → Fin 2) → ℂ :=
  fun s => if (∀ i, s i = 0) ∨ (∀ i, s i = 1) then 1 else 0

/-- The **W state** on `n` qubits. The state has amplitude 1 on configurations
    with exactly one coordinate equal to 1, and 0 elsewhere.

    For `n ≥ 3`, this represents a fundamentally different entanglement class
    from GHZ under stochastic local operations and classical communication. -/
def wState (n : ℕ) : (Fin n → Fin 2) → ℂ :=
  fun s => if (Finset.univ.filter (fun i => s i = 1)).card = 1 then 1 else 0

/-- A product state constructed from local amplitudes. -/
def productState {ι : Type*} [Fintype ι] [DecidableEq ι]
    {d : Type*} (φ : ι → d → ℂ) : (ι → d) → ℂ :=
  fun s => ∏ i : ι, φ i (s i)

/-! ## §5. Cross-Support Combinatorial Invariant -/

/-- The **cross-support count** for a state across partition `A`.

    Counts ordered pairs `(s, t)` in the support of `ψ` where mixing
    configurations across `A` produces at least one element outside the support.
    This measures the failure of support rectangularity across the partition.

    **Cross-domain connection**: This connects quantum entanglement to
    tensor support geometry and algebraic complexity. A positive cross-support
    count implies the state's support is not a Cartesian product when
    projected onto `A` and `Aᶜ`, which is a fundamental obstruction
    to low-rank tensor factorization. -/
def crossSupportCount {ι : Type*} [Fintype ι] [DecidableEq ι]
    {d : Type*} [Fintype d] [DecidableEq d]
    (A : Finset ι) (ψ : (ι → d) → ℂ) : ℕ :=
  Finset.card (Finset.univ.filter (fun p : (ι → d) × (ι → d) =>
    ψ p.1 ≠ 0 ∧ ψ p.2 ≠ 0 ∧
    (ψ (mixConfig A p.1 p.2) = 0 ∨ ψ (mixConfig A p.2 p.1) = 0)))

end TropicalEntanglement
end