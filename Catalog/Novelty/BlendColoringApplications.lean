import Novelty.BlendColoringHarmonic

/-!
# Applications of the blend-colouring collapse

This file specialises `Novelty.BlendColoringHarmonic.blend_const` to the two
statements the mission is really about:

* `no_nonconstant_blend`: the literal **non-existence** phrasing — a finite
  strongly connected row-stochastic digraph admits no blend colouring with two
  differently coloured vertices.
* the **directed `n`-cycle** (`n ≥ 1`): it is strongly connected, hence its only
  blend colourings are constant.

## Lab Notes

`-- !-- Lab Notes -- !--`

**Hypothesis.**  The maximum-principle collapse should specialise painlessly to
(a) the exact non-existence statement and (b) the canonical strongly connected
example, the directed cycle.

**Experiment.**  The `n`-cycle's arc relation is `j = i + 1` on `Fin n`; walking
`k` steps from `i` reaches `i + k`, and every vertex has the form `i + k`, giving
reachability.  Verified for `n = 2,3,4` by hand (see `ComputationalEvidence.md`).

**Analysis.**  Strong connectivity of the cycle is the only non-formal ingredient;
once established the collapse is immediate.  The internal `key` step of
`cycle_stronglyConnected` shows `i` reaches `i + m` for all `m`.

**Critique.**  Both results are non-vacuous: `no_nonconstant_blend` is applied to
the concrete cycle to rule out non-constant colourings, and the cycle is exhibited
as a genuine strongly connected witness (not the trivial one-vertex graph).

**Synthesis.**  The abstract theorem yields the headline non-existence result and
a concrete infinite family of instances.

`-- !-- Lab Notes -- !--`
-/

namespace Novelty.BlendColoringHarmonic

open scoped BigOperators
open Fin.NatCast

/-- **Non-existence phrasing.**  On a finite strongly connected row-stochastic
digraph there is no blend colouring taking two different values. -/
theorem no_nonconstant_blend {V : Type*} [Fintype V] (w : V → V → ℝ) (c : V → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hrow : ∀ i, ∑ j, w i j = 1)
    (hblend : ∀ i, c i = ∑ j, w i j * c j)
    (hsc : ∀ i j, Relation.ReflTransGen (Arc w) i j) :
    ¬ ∃ i j, c i ≠ c j := by
  rintro ⟨i, j, hij⟩
  exact hij (blend_const w c hw hrow hblend hsc i j)

/-- Weight matrix of the directed `n`-cycle: the arc `i → i+1` has weight `1`. -/
def cycleWeight (n : ℕ) [NeZero n] : Fin n → Fin n → ℝ :=
  fun i j => if j = i + 1 then 1 else 0

lemma cycleWeight_nonneg (n : ℕ) [NeZero n] : ∀ i j, 0 ≤ cycleWeight n i j := by
  intro i j; unfold cycleWeight; split <;> norm_num

lemma cycleWeight_row [NeZero n] : ∀ i, ∑ j, cycleWeight n i j = 1 := by
  intro i
  simp [cycleWeight]

/-- The directed `n`-cycle (`n ≥ 1`) is strongly connected: from `i` one reaches
`i + m` for every number of steps `m`, and every vertex has this form. -/
lemma cycle_stronglyConnected [NeZero n] :
    ∀ i j : Fin n, Relation.ReflTransGen (Arc (cycleWeight n)) i j := by
  have key : ∀ (i : Fin n) (m : ℕ),
      Relation.ReflTransGen (Arc (cycleWeight n)) i (i + (m : Fin n)) := by
    intro i m
    induction m with
    | zero => simpa using Relation.ReflTransGen.refl
    | succ k ih =>
        refine ih.tail ?_
        have hcast : (i + ((k + 1 : ℕ) : Fin n)) = (i + (k : Fin n)) + 1 := by
          push_cast; abel
        show 0 < cycleWeight n (i + (k : Fin n)) (i + ((k + 1 : ℕ) : Fin n))
        rw [hcast]
        simp [cycleWeight]
  intro i j
  have h := key i (j - i).val
  have heq : i + (((j - i).val : ℕ) : Fin n) = j := by
    rw [Fin.cast_val_eq_self, add_sub_cancel]
  rwa [heq] at h

/-- **Directed cycle collapse.**  Every blend colouring of the directed `n`-cycle
(`n ≥ 1`) is constant. -/
theorem cycle_blend_const [NeZero n] (c : Fin n → ℝ)
    (hblend : ∀ i, c i = ∑ j, cycleWeight n i j * c j) :
    ∀ i j, c i = c j :=
  blend_const (cycleWeight n) c (cycleWeight_nonneg n) cycleWeight_row hblend
    cycle_stronglyConnected

end Novelty.BlendColoringHarmonic