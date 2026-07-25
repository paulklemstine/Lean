/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Converse Discrete Noether Theorem: Symmetry Rigidity

This file establishes a **converse** to the discrete Noether theorem for variational
integrators, together with the forward direction, yielding a complete bidirectional
characterization: conservation ↔ symmetry.

## Mathematical Overview

In discrete mechanics, a **discrete Lagrangian** `Ld : Q → Q → ℝ` generates dynamics
through the **discrete Euler–Lagrange (DEL) equations**. A **momentum observable**
`p : Q → Q → ℝ` is conserved when `p(qₖ, qₖ₊₁) = p(qₖ₋₁, qₖ)` on DEL triples.

The **forward** Noether theorem says: if `Ld` is invariant under a symmetry
(encoded by `V ≡ 0`), then momentum is conserved.

Our **converse** says: if momentum is conserved on all DEL trajectories and the
flow is rich (every pair is realized in some trajectory), then `Ld` must be invariant.

The core argument:
1. The first-variation identity: `V(q₁, q₂) = p(q₁, q₂) - p(q₀, q₁)` on shell
2. Conservation forces `V = 0` on all on-shell pairs
3. Richness extends this to all pairs

## Main definitions

* `DiscreteNoether.MomentumConservedOnTrajectories` — momentum is constant on DEL orbits
* `DiscreteNoether.InfinitesimallyInvariant` — pairwise symmetry variation vanishes
* `DiscreteNoether.RichDiscreteFlow` — every pair appears in some DEL triple
* `DiscreteNoether.symmetryDefect` — momentum drift at a triple
* `DiscreteNoether.FirstVariationIdentity` — link between variation and momentum drift

## Main results

* `DiscreteNoether.discrete_momentum_conserved` — forward Noether
* `DiscreteNoether.converse_discrete_noether` — **converse** Noether (main theorem)
* `DiscreteNoether.discrete_noether_iff_conservation` — bidirectional iff
* `DiscreteNoether.momentum_drift_bound_of_perturbation` — quantitative perturbation bound
* `DiscreteNoether.diagnostic_completeness` — non-invariance ⟹ drift witness

## References

* Marsden, West: *Discrete mechanics and variational integrators*, Acta Numerica 10 (2001)
-/

namespace DiscreteNoether

variable {Q : Type*}

/-! ### Core Definitions -/

/-- The discrete momentum observable `p : Q → Q → ℝ` is conserved along
all discrete Euler–Lagrange trajectories. -/
def MomentumConservedOnTrajectories (DEL : Q → Q → Q → Prop) (p : Q → Q → ℝ) : Prop :=
  ∀ ⦃q₀ q₁ q₂ : Q⦄, DEL q₀ q₁ q₂ → p q₁ q₂ = p q₀ q₁

/-- The pairwise first-order variation of the discrete Lagrangian under
the infinitesimal generator vanishes on all pairs. -/
def InfinitesimallyInvariant (V : Q → Q → ℝ) : Prop :=
  ∀ q₀ q₁ : Q, V q₀ q₁ = 0

/-- A discrete flow is *rich* if every pair `(q₀, q₁)` appears in some DEL triple. -/
def RichDiscreteFlow (DEL : Q → Q → Q → Prop) : Prop :=
  ∀ q₀ q₁ : Q, ∃ qprev, DEL qprev q₀ q₁

/-- The symmetry defect vanishes on all DEL trajectory segments. -/
def SymmetryDefectZeroOnTrajectories (DEL : Q → Q → Q → Prop) (D : Q → Q → Q → ℝ) : Prop :=
  ∀ ⦃q₀ q₁ q₂ : Q⦄, DEL q₀ q₁ q₂ → D q₀ q₁ q₂ = 0

/-- The **symmetry defect** at a triple: measures momentum drift. -/
def symmetryDefect (p : Q → Q → ℝ) (q₀ q₁ q₂ : Q) : ℝ :=
  p q₁ q₂ - p q₀ q₁

/-- The **first-variation identity**: variation equals momentum drift on DEL triples. -/
def FirstVariationIdentity (DEL : Q → Q → Q → Prop) (p V : Q → Q → ℝ) : Prop :=
  ∀ ⦃q₀ q₁ q₂ : Q⦄, DEL q₀ q₁ q₂ → V q₁ q₂ = p q₁ q₂ - p q₀ q₁

/-! ### Forward Discrete Noether Theorem -/

/-- **Forward discrete Noether theorem.** Invariance implies conservation.
If `V ≡ 0` and `V(q₁, q₂) = p(q₁, q₂) - p(q₀, q₁)` on shell,
then `p(q₁, q₂) = p(q₀, q₁)` on shell. -/
theorem discrete_momentum_conserved
    (DEL : Q → Q → Q → Prop) (p V : Q → Q → ℝ)
    (hvar : FirstVariationIdentity DEL p V)
    (hinv : InfinitesimallyInvariant V) :
    MomentumConservedOnTrajectories DEL p := by
  intro q₀ q₁ q₂ hdel
  have hv := hvar hdel
  rw [hinv q₁ q₂] at hv
  linarith

/-- **Forward Noether for trajectory ranges.** Momentum is constant along
any finite trajectory chain. -/
theorem discrete_momentum_conserved_range
    (DEL : Q → Q → Q → Prop) (p : Q → Q → ℝ)
    (hcons : MomentumConservedOnTrajectories DEL p)
    (q : ℕ → Q) (hq : ∀ k, DEL (q k) (q (k + 1)) (q (k + 2)))
    (n : ℕ) : p (q n) (q (n + 1)) = p (q 0) (q 1) := by
  induction n with
  | zero => rfl
  | succ n ih =>
    have h := hcons (hq n)
    linarith

/-! ### Converse Noether: Main Results -/

/-- **Zero defect from conservation.** Conservation forces the symmetry defect
to zero on all DEL triples. -/
theorem defect_zero_of_momentum_conserved
    (DEL : Q → Q → Q → Prop) (p : Q → Q → ℝ)
    (hcons : MomentumConservedOnTrajectories DEL p) :
    SymmetryDefectZeroOnTrajectories DEL (symmetryDefect p) := by
  intro q₀ q₁ q₂ hdel
  unfold symmetryDefect
  have h := hcons hdel
  linarith

/-- **Variation vanishes on-shell.** First-variation identity + conservation
forces `V = 0` on all on-shell pairs. -/
theorem variation_zero_on_shell
    (DEL : Q → Q → Q → Prop) (p V : Q → Q → ℝ)
    (hvar : FirstVariationIdentity DEL p V)
    (hcons : MomentumConservedOnTrajectories DEL p)
    ⦃q₀ q₁ q₂ : Q⦄ (hdel : DEL q₀ q₁ q₂) :
    V q₁ q₂ = 0 := by
  have hv := hvar hdel
  have hc := hcons hdel
  linarith

/-- **Converse discrete Noether theorem.** If:
1. The first-variation identity links momentum drift to variation `V`,
2. Momentum is conserved on all DEL trajectories,
3. The discrete flow is rich,
then `V ≡ 0` (infinitesimal invariance).

This is the main result: conservation *characterizes* symmetry. -/
theorem converse_discrete_noether
    (DEL : Q → Q → Q → Prop) (p V : Q → Q → ℝ)
    (hvar : FirstVariationIdentity DEL p V)
    (hcons : MomentumConservedOnTrajectories DEL p)
    (hrich : RichDiscreteFlow DEL) :
    InfinitesimallyInvariant V := by
  intro q₀ q₁
  obtain ⟨qprev, hdel⟩ := hrich q₀ q₁
  exact variation_zero_on_shell DEL p V hvar hcons hdel

/-! ### Bidirectional Characterization -/

/-- **Noether iff conservation.** Under first-variation identity and richness,
invariance ↔ conservation. This is the complete bidirectional theorem. -/
theorem discrete_noether_iff_conservation
    (DEL : Q → Q → Q → Prop) (p V : Q → Q → ℝ)
    (hvar : FirstVariationIdentity DEL p V)
    (hrich : RichDiscreteFlow DEL) :
    InfinitesimallyInvariant V ↔ MomentumConservedOnTrajectories DEL p :=
  ⟨discrete_momentum_conserved DEL p V hvar,
   fun hcons => converse_discrete_noether DEL p V hvar hcons hrich⟩

/-! ### Contrapositive: Non-invariance Implies Drift Witness -/

/-- **Symmetry-breaking witness.** If the Lagrangian is not invariant, then
some DEL trajectory has nonzero momentum drift. -/
theorem symmetry_defect_contrapositive
    (DEL : Q → Q → Q → Prop) (p V : Q → Q → ℝ)
    (hvar : FirstVariationIdentity DEL p V)
    (hrich : RichDiscreteFlow DEL)
    (hnotinv : ¬ InfinitesimallyInvariant V) :
    ¬ MomentumConservedOnTrajectories DEL p :=
  fun hcons => hnotinv (converse_discrete_noether DEL p V hvar hcons hrich)

/-! ### Quantitative Perturbative Bounds -/

/-- **Perturbative drift bound.** For `p_ε = p₀ + ε · Δp` where `p₀` has
exact symmetry and the perturbation defect is bounded by `C`, the total
drift is bounded by `|ε| · C`. -/
theorem momentum_drift_bound_of_perturbation
    (p₀ Δp : Q → Q → ℝ) (ε C : ℝ)
    (hbase : ∀ q₀ q₁ q₂ : Q, symmetryDefect p₀ q₀ q₁ q₂ = 0)
    (hbound : ∀ q₀ q₁ q₂ : Q, |symmetryDefect Δp q₀ q₁ q₂| ≤ C)
    (q₀ q₁ q₂ : Q) :
    |symmetryDefect (fun a b => p₀ a b + ε * Δp a b) q₀ q₁ q₂| ≤ |ε| * C := by
  unfold symmetryDefect at *
  have hb := hbase q₀ q₁ q₂
  have hbd := hbound q₀ q₁ q₂
  have key : p₀ q₁ q₂ + ε * Δp q₁ q₂ - (p₀ q₀ q₁ + ε * Δp q₀ q₁)
           = (p₀ q₁ q₂ - p₀ q₀ q₁) + ε * (Δp q₁ q₂ - Δp q₀ q₁) := by ring
  rw [key, hb, zero_add, abs_mul]
  exact mul_le_mul_of_nonneg_left hbd (abs_nonneg ε)

/-- **Step-scaled drift bound.** When perturbation defect scales with timestep `h`,
drift is bounded by `|ε| · C · h`. -/
theorem momentum_drift_bound_step_scaled
    (p₀ Δp : Q → Q → ℝ) (ε C h : ℝ)
    (hbase : ∀ q₀ q₁ q₂ : Q, symmetryDefect p₀ q₀ q₁ q₂ = 0)
    (hbound : ∀ q₀ q₁ q₂ : Q, |symmetryDefect Δp q₀ q₁ q₂| ≤ C * h)
    (q₀ q₁ q₂ : Q) :
    |symmetryDefect (fun a b => p₀ a b + ε * Δp a b) q₀ q₁ q₂| ≤ |ε| * C * h := by
  unfold symmetryDefect at *
  have hb := hbase q₀ q₁ q₂
  have hbd := hbound q₀ q₁ q₂
  have key : p₀ q₁ q₂ + ε * Δp q₁ q₂ - (p₀ q₀ q₁ + ε * Δp q₀ q₁)
           = (p₀ q₁ q₂ - p₀ q₀ q₁) + ε * (Δp q₁ q₂ - Δp q₀ q₁) := by ring
  rw [key, hb, zero_add, abs_mul]
  calc |ε| * |Δp q₁ q₂ - Δp q₀ q₁|
      ≤ |ε| * (C * h) := mul_le_mul_of_nonneg_left hbd (abs_nonneg ε)
    _ = |ε| * C * h := by ring

/-! ### Diagnostic Completeness -/

/-- **Diagnostic completeness.** If the variation is not identically zero,
there exists a DEL triple witnessing nonzero drift. -/
theorem diagnostic_completeness
    (DEL : Q → Q → Q → Prop) (p V : Q → Q → ℝ)
    (hvar : FirstVariationIdentity DEL p V)
    (hrich : RichDiscreteFlow DEL)
    (hnotinv : ¬ InfinitesimallyInvariant V) :
    ∃ q₀ q₁ q₂, DEL q₀ q₁ q₂ ∧ symmetryDefect p q₀ q₁ q₂ ≠ 0 := by
  by_contra h
  push_neg at h
  have hcons : MomentumConservedOnTrajectories DEL p := by
    intro q₀ q₁ q₂ hdel
    have := h q₀ q₁ q₂ hdel
    unfold symmetryDefect at this
    linarith
  exact hnotinv (converse_discrete_noether DEL p V hvar hcons hrich)

/-- **Diagnostic soundness.** If conservation holds on all DEL triples and the
flow is rich, then the Lagrangian is invariant. -/
theorem diagnostic_soundness
    (DEL : Q → Q → Q → Prop) (p V : Q → Q → ℝ)
    (hvar : FirstVariationIdentity DEL p V)
    (hrich : RichDiscreteFlow DEL)
    (hcons : MomentumConservedOnTrajectories DEL p) :
    InfinitesimallyInvariant V :=
  converse_discrete_noether DEL p V hvar hcons hrich

end DiscreteNoether