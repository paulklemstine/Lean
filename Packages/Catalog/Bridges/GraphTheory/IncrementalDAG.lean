/-
# Incremental Recomputation on Dependency DAGs

A certified locality theorem: when a new node is inserted into a finite DAG,
the recursively defined "level" (longest incoming path length) changes only
within the forward reachability cone of the new node.

## Main results

* `level_eq_of_not_reaches` — levels are unchanged outside the forward cone
* `recomputation_support_subset_forward_cone` — the set of changed vertices
  is contained in the forward cone
-/
import Mathlib

open Finset

variable {V : Type*} [DecidableEq V] [Fintype V]

/-- A predecessor function: `pred v` is the set of immediate predecessors of `v`. -/
abbrev PredFn (V : Type*) [DecidableEq V] := V → Finset V

/-- The relation `u ≺ v` iff `u ∈ pred v` (u is a predecessor of v). -/
def predRel (pred : PredFn V) (u v : V) : Prop := u ∈ pred v

instance (pred : PredFn V) : DecidableRel (predRel pred) :=
  fun u v => Finset.decidableMem u (pred v)

/-- A predecessor function is acyclic if the predecessor relation is well-founded. -/
def DAGAcyclic (pred : PredFn V) : Prop :=
  WellFounded (predRel pred)

/-- The level of a vertex: 0 if it has no predecessors, otherwise
    1 + max over predecessor levels. Defined by well-founded recursion on
    the acyclic predecessor relation. -/
noncomputable def level (pred : PredFn V) (hacyc : DAGAcyclic pred) : V → ℕ :=
  hacyc.fix (fun v ih =>
    if h : (pred v).Nonempty then
      ((pred v).attach).sup' (h.attach) (fun u => ih u.1 u.2 + 1)
    else 0)

/-- Unfolding lemma for `level`. -/
theorem level_unfold (pred : PredFn V) (hacyc : DAGAcyclic pred) (v : V) :
    level pred hacyc v =
      if h : (pred v).Nonempty then
        ((pred v).attach).sup' (h.attach) (fun u => level pred hacyc u.1 + 1)
      else 0 := by
  unfold level
  rw [WellFounded.fix_eq]

/-- Reachability: `Reaches pred u v` means there is a directed path from `u` to `v`
    following edges forward (predecessor → successor direction). -/
inductive Reaches (pred : PredFn V) : V → V → Prop
  | refl : Reaches pred v v
  | step {u w v : V} : Reaches pred u w → w ∈ pred v → Reaches pred u v

theorem Reaches.trans {pred : PredFn V} {u v w : V}
    (h1 : Reaches pred u v) (h2 : Reaches pred v w) : Reaches pred u w := by
  induction h2
  case refl => exact h1
  case step x y z ha hb ih => exact Reaches.step ih hb

/-! ## Main locality theorem -/

/-
**Key locality lemma**: If `predOld v = predNew v` and the levels of all
    predecessors of `v` agree between old and new, then `level v` also agrees.
-/
theorem level_eq_of_pred_eq_and_levels_eq
    (predOld predNew : PredFn V)
    (hacycOld : DAGAcyclic predOld) (hacycNew : DAGAcyclic predNew)
    (v : V)
    (hpred : predOld v = predNew v)
    (hlevels : ∀ u ∈ predOld v, level predOld hacycOld u = level predNew hacycNew u) :
    level predOld hacycOld v = level predNew hacycNew v := by
  rw [ level_unfold, level_unfold, hpred ];
  grind

/-
**Main theorem**: If `v` is not reachable from `new` in the new graph,
    and the predecessor function is unchanged outside the forward cone of `new`,
    then the level of `v` is unchanged.

    This formalizes the principle that incremental recomputation after inserting
    a new node into a dependency DAG need only visit the forward cone of
    that node.
-/
theorem level_eq_of_not_reaches
    (predOld predNew : PredFn V)
    (new : V)
    (hacycOld : DAGAcyclic predOld) (hacycNew : DAGAcyclic predNew)
    (hlocal : ∀ v, ¬ Reaches predNew new v → predOld v = predNew v)
    (v : V)
    (hv : ¬ Reaches predNew new v) :
    level predOld hacycOld v = level predNew hacycNew v := by
  -- Apply well-founded induction on the new predecessor relation.
  have h_ind : ∀ v, ¬Reaches predNew new v → ∀ u, Reaches predNew u v → ¬Reaches predNew new u := by
    intro v hv u hu huv
    have h_contra : Reaches predNew new v := by
      exact Reaches.trans huv hu
    contradiction;
  have h_ind : ∀ v, ¬Reaches predNew new v → level predOld hacycOld v = level predNew hacycNew v := by
    intro v hv
    induction' v using hacycNew.induction with v ih;
    apply level_eq_of_pred_eq_and_levels_eq predOld predNew hacycOld hacycNew v (hlocal v hv);
    intro u hu;
    apply ih u;
    · unfold predRel; specialize hlocal v hv; aesop;
    · apply h_ind v hv u;
      exact Reaches.step ( Reaches.refl ) ( hlocal v hv ▸ hu );
  exact h_ind v hv

/-
**Support theorem**: The set of vertices whose level changes is contained
    in the forward reachability cone of the new node. This is the theorem that
    says: the recomputation set is contained in the forward dependency cone.
-/
theorem recomputation_support_subset_forward_cone
    (predOld predNew : PredFn V)
    (new : V)
    (hacycOld : DAGAcyclic predOld) (hacycNew : DAGAcyclic predNew)
    (hlocal : ∀ v, ¬ Reaches predNew new v → predOld v = predNew v) :
    {v | level predOld hacycOld v ≠ level predNew hacycNew v}
      ⊆ {v | Reaches predNew new v} := by
  intro v hv;
  exact Classical.not_not.1 fun h => hv ( level_eq_of_not_reaches predOld predNew new hacycOld hacycNew hlocal v h )

/-! ## Level characterization -/

/-
The level of a source (no predecessors) is 0.
-/
theorem level_eq_zero_of_source (pred : PredFn V) (hacyc : DAGAcyclic pred)
    (v : V) (h : ¬(pred v).Nonempty) : level pred hacyc v = 0 := by
  convert level_unfold pred hacyc v using 1;
  aesop

/-
The level is always at least `level u + 1` for any predecessor `u`.
-/
theorem level_ge_succ_of_pred (pred : PredFn V) (hacyc : DAGAcyclic pred)
    (v u : V) (h : u ∈ pred v) : level pred hacyc v ≥ level pred hacyc u + 1 := by
  -- By definition of level, we have:
  have h_def : level pred hacyc v = if h : (pred v).Nonempty then ((pred v).attach).sup' (h.attach) (fun u => level pred hacyc u.1 + 1) else 0 := by
    exact level_unfold pred hacyc v;
  split_ifs at h_def <;> simp_all +decide [ Finset.le_sup' ];
  exact ⟨ u, h, le_rfl ⟩

/-
Level is monotone along edges: if `u ∈ pred v` then `level u < level v`.
-/
theorem level_strict_mono_of_pred (pred : PredFn V) (hacyc : DAGAcyclic pred)
    (v u : V) (h : u ∈ pred v) : level pred hacyc u < level pred hacyc v := by
  exact Nat.lt_of_succ_le ( level_ge_succ_of_pred pred hacyc v u h )

/-
The complement of the forward cone is the maximal region where levels
    are guaranteed unchanged by any localized update.
-/
theorem unchanged_on_complement_of_forward_cone
    (predOld predNew : PredFn V)
    (new : V)
    (hacycOld : DAGAcyclic predOld) (hacycNew : DAGAcyclic predNew)
    (hlocal : ∀ v, ¬ Reaches predNew new v → predOld v = predNew v) :
    ∀ v, v ∈ ({v | Reaches predNew new v} : Set V)ᶜ →
      level predOld hacycOld v = level predNew hacycNew v := by
  -- Apply the `level_eq_of_not_reaches` theorem to conclude the proof.
  apply level_eq_of_not_reaches;
  assumption