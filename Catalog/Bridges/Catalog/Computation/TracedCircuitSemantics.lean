import Mathlib
import Logic.KleeneFixedPoint

/-! # Traced Circuit Semantics: Lawvere–Kleene Stratification

This file connects the abstract Kleene fixed-point theory to traced monoidal
category semantics for reversible temporal circuits.

## Main results

* `iSup_unroll_eq_trace`: The trace of a guarded circuit equals the ω-supremum
  of its finite causal unrollings.
* `trace_eq_approx_of_stabilization`: If unrollings stabilize at stage N,
  the trace equals the N-th unrolling — the **collapse theorem** for
  reversible temporal circuits.
* `trace_is_least_causal_invariant`: The traced invariant is the least
  causally generated fixed point.

## Architecture

We work at two levels:

1. **Hom-set level**: A `GuardedTrace` instance on a complete lattice α
   captures the Kleene chain and its supremum.
2. **Circuit level**: Parametric definitions of temporal categories, tensor,
   trace, and unroll, with a `GuardedCircuit` structure bridging the two.
-/

open Set Function

noncomputable section

/-! ## Guarded trace structure on a single hom-set -/

/-- A guarded trace structure on a type α with complete lattice structure.
The trace operator is characterized as the supremum of iterating a `step`
function from ⊥. This is the Lawvere–Kleene normal form. -/
class GuardedTrace (α : Type*) [CompleteLattice α] where
  /-- The one-step feedback transformer. -/
  step : α → α
  /-- The step function is monotone. -/
  step_mono : Monotone step
  /-- The step function is Scott-continuous. -/
  step_cont : OmegaScottContinuous step
  /-- The trace operator. -/
  traceOp : α
  /-- **Defining axiom**: the trace is the ω-supremum of the Kleene chain. -/
  trace_eq_iSup : traceOp = sSup (range (fun n : ℕ => step^[n] (⊥ : α)))

/-! ## Main theorems in the single hom-set setting -/

variable {α : Type*} [CompleteLattice α] [gt : GuardedTrace α]

/-- **Theorem 1 (Monotonicity)**: Finite unrollings form a non-decreasing chain. -/
theorem unroll_mono :
    Monotone (fun n : ℕ => gt.step^[n] (⊥ : α)) :=
  kleene_chain_mono gt.step_mono

/-- **Theorem 2 (Trace = Supremum of Unrollings)**: The trace equals the
ω-supremum of finite causal approximants. This is the Lawvere–Kleene
normal form theorem for guarded trace semantics. -/
theorem iSup_unroll_eq_trace :
    sSup (range (fun n : ℕ => gt.step^[n] (⊥ : α))) = gt.traceOp :=
  gt.trace_eq_iSup.symm

/-- The trace is a fixed point of the step function. -/
theorem trace_is_fixed_point :
    gt.step gt.traceOp = gt.traceOp := by
  rw [gt.trace_eq_iSup]
  exact kleene_fixed_point gt.step_cont

/-- **Theorem 3a (Least Pre-Fixed Point)**: The traced invariant is the least
causally generated fixed point. If `step x ≤ x`, then `traceOp ≤ x`. -/
theorem trace_le_of_prefixed
    {x : α} (hx : gt.step x ≤ x) :
    gt.traceOp ≤ x := by
  rw [gt.trace_eq_iSup]
  exact sSup_kleene_le_of_prefixed gt.step_mono hx

/-- The traced invariant equals `sInf {x | step x ≤ x}`. -/
theorem trace_eq_sInf_prefixed :
    gt.traceOp = sInf {x : α | gt.step x ≤ x} := by
  rw [gt.trace_eq_iSup]
  exact kleene_lfp gt.step_cont

/-- The full Lawvere–Kleene theorem: trace is the least pre-fixed point of step,
and in particular any pre-fixed point dominates it. -/
theorem trace_is_least_causal_invariant
    {x : α} (hx : gt.step x ≤ x) :
    gt.traceOp ≤ x :=
  trace_le_of_prefixed hx

/-- **Theorem 3b (Collapse)**: If the unrolling chain stabilizes at stage N,
the trace collapses to the N-th approximant. -/
theorem trace_eq_approx_of_stabilization
    {N : ℕ} (hstab : gt.step^[N + 1] (⊥ : α) = gt.step^[N] ⊥) :
    gt.traceOp = gt.step^[N] ⊥ := by
  rw [gt.trace_eq_iSup]
  exact sSup_kleene_eq_of_stabilization gt.step_mono hstab

/-! ## Temporal category infrastructure -/

/-- A temporal category: objects with typed morphism sets. -/
class TemporalCategory (Obj : Type*) where
  Hom : Obj → Obj → Type*

/-- Tensor (monoidal) product on objects. -/
class TensorHom (Obj : Type*) where
  tensorObj : Obj → Obj → Obj

/-- Trace operator on a temporal category: the abstract feedback combinator. -/
class TemporalTrace (Obj : Type*) [TemporalCategory Obj] [TensorHom Obj] where
  trace :
    ∀ {X A B : Obj},
      TemporalCategory.Hom (TensorHom.tensorObj X A) (TensorHom.tensorObj X B) →
      TemporalCategory.Hom A B

/-- Finite unrolling of a traced circuit: n steps of feedback from ⊥. -/
class TemporalUnroll (Obj : Type*) [TemporalCategory Obj] [TensorHom Obj] where
  unroll :
    ∀ {X A B : Obj},
      ℕ →
      TemporalCategory.Hom (TensorHom.tensorObj X A) (TensorHom.tensorObj X B) →
      TemporalCategory.Hom A B

/-! ## Circuit-level bridge

We bundle the connection between the abstract Kleene theory and a
concrete circuit as a structure `GuardedCircuit`, avoiding the need to
register `CompleteLattice` instances on Hom-types via type classes.
-/

/-- A guarded circuit bundles the data needed to apply the Kleene fixed-point
theory to a specific morphism in a temporal category. -/
structure GuardedCircuit
    {Obj : Type*} [TemporalCategory Obj] [TensorHom Obj]
    [TemporalUnroll Obj] [TemporalTrace Obj]
    {X A B : Obj}
    (f : TemporalCategory.Hom (TensorHom.tensorObj X A) (TensorHom.tensorObj X B))
    (HomLat : CompleteLattice (TemporalCategory.Hom A B)) where
  /-- The feedback step function on `Hom A B`. -/
  feedbackStep : TemporalCategory.Hom A B → TemporalCategory.Hom A B
  /-- The step is Scott-continuous. -/
  step_cont : @OmegaScottContinuous _ HomLat feedbackStep
  /-- Unrollings match the Kleene chain. -/
  unroll_eq : ∀ n, TemporalUnroll.unroll n f =
    feedbackStep^[n] (@Bot.bot _ HomLat.toBot)
  /-- The trace matches the Kleene fixed point. -/
  trace_eq : TemporalTrace.trace f =
    @sSup _ HomLat.toSupSet
      (range (fun n : ℕ => feedbackStep^[n] (@Bot.bot _ HomLat.toBot)))

variable {Obj : Type*} [TemporalCategory Obj] [TensorHom Obj]
  [TemporalUnroll Obj] [TemporalTrace Obj]

/-- **Circuit Corollary 1 (Monotonicity)**: Unrollings of a guarded circuit
form a non-decreasing chain. -/
theorem guarded_unroll_mono {X A B : Obj}
    {f : TemporalCategory.Hom (TensorHom.tensorObj X A) (TensorHom.tensorObj X B)}
    {HomLat : CompleteLattice (TemporalCategory.Hom A B)}
    (gc : GuardedCircuit f HomLat)
    {m n : ℕ} (hmn : m ≤ n) :
    @LE.le _ HomLat.toLattice.toLE
      (TemporalUnroll.unroll m f) (TemporalUnroll.unroll n f) := by
  simp only [gc.unroll_eq]
  have := @kleene_chain_mono _ HomLat (f := gc.feedbackStep) gc.step_cont.mono
  exact this hmn

/-- **Circuit Corollary 2 (Trace = sSup unrollings)**. -/
theorem iSup_unroll_eq_trace_circuit {X A B : Obj}
    {f : TemporalCategory.Hom (TensorHom.tensorObj X A) (TensorHom.tensorObj X B)}
    {HomLat : CompleteLattice (TemporalCategory.Hom A B)}
    (gc : GuardedCircuit f HomLat) :
    @sSup _ HomLat.toSupSet
      (range (fun n => TemporalUnroll.unroll (X := X) n f)) =
    TemporalTrace.trace f := by
  conv_rhs => rw [gc.trace_eq]
  congr 1; ext x; simp only [Set.mem_range]
  exact ⟨fun ⟨n, h⟩ => ⟨n, h ▸ (gc.unroll_eq n).symm⟩,
         fun ⟨n, h⟩ => ⟨n, h ▸ gc.unroll_eq n⟩⟩

/-- **Circuit Corollary 3 (Collapse)**: If unrollings of a guarded circuit
stabilize at stage N, the trace equals the N-th unrolling.
This is the collapse theorem for reversible temporal circuits. -/
theorem trace_eq_unroll_of_stabilization_circuit {X A B : Obj}
    {f : TemporalCategory.Hom (TensorHom.tensorObj X A) (TensorHom.tensorObj X B)}
    {HomLat : CompleteLattice (TemporalCategory.Hom A B)}
    (gc : GuardedCircuit f HomLat)
    {N : ℕ}
    (hstab : TemporalUnroll.unroll (X := X) (N + 1) f =
             TemporalUnroll.unroll (X := X) N f) :
    TemporalTrace.trace f = TemporalUnroll.unroll (X := X) N f := by
  rw [gc.trace_eq, gc.unroll_eq N]
  apply @sSup_kleene_eq_of_stabilization _ HomLat gc.feedbackStep gc.step_cont.mono
  rw [← gc.unroll_eq (N + 1), ← gc.unroll_eq N]
  exact hstab

/-- **Reversible temporal trace theorem**: For a guarded circuit f,
its trace equals the ω-supremum of finite causal unrollings. -/
theorem reversible_temporal_trace_eq_iSup_unroll {X A B : Obj}
    {f : TemporalCategory.Hom (TensorHom.tensorObj X A) (TensorHom.tensorObj X B)}
    {HomLat : CompleteLattice (TemporalCategory.Hom A B)}
    (gc : GuardedCircuit f HomLat) :
    TemporalTrace.trace f =
      @sSup _ HomLat.toSupSet
        (range (fun n => TemporalUnroll.unroll (X := X) n f)) :=
  (iSup_unroll_eq_trace_circuit gc).symm

end