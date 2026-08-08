import Mathlib
import MachineLearning.ReLUPartition.DeepBound

/-!
# The geometry of a deep cell: every activation cell is convex

`MachineLearning.ReLUPartition.DeepBound` counts the activation cells of a deep
ReLU network.  This file describes their *shape*.

The cell-wise affinization theorem `act_eq_applyVec` says that, on the cell where
the pattern word is `q`, layer `l`'s pre-activations are computed by a single
affine family `preFamily q l` of the input.  We upgrade this to an exact
description of the cell as a finite intersection,

```
    netCell net L q = ⋂ l < L, { x | (preFamily q l).pattern x = q l } ,
```

`cell_eq_iInter`.  Each set on the right is a cell of one affine family, hence
convex (`AffineFamily.convex_cell`), so:

* `convex_netCell` — **every activation cell of a depth-`L` ReLU network on
  `ℝ^d` is convex**, hence connected.  Note that this is a statement about the
  *pattern* cells, which refine the linear pieces of the computed function;
* `netCell_ordConnected_one` — in dimension one convexity becomes order
  connectedness: a cell is an *interval* of the line.  This is the structural
  input that any exact one-dimensional region count needs, since it says the
  pattern map `ℝ → words` has interval fibres and therefore the cell count is
  one more than the number of its jump points.
-/

namespace ReLUPartition

open Finset

variable {d w : ℕ}

namespace ReLUNet

/-- Extend a length-`L` pattern word to a function on all of `ℕ`, so that it can
be fed to `preFamily`. -/
noncomputable def wordExtend {L : ℕ} (q : Fin L → Finset (Fin w)) : ℕ → Finset (Fin w) :=
  fun l => if h : l < L then q ⟨l, h⟩ else ∅

@[simp] lemma wordExtend_apply {L : ℕ} (q : Fin L → Finset (Fin w)) {l : ℕ} (h : l < L) :
    wordExtend q l = q ⟨l, h⟩ := by
  simp [wordExtend, h]

/-- The cell of the depth-`L` network on which the activation word is `q`. -/
def netCell (net : ReLUNet d w) (L : ℕ) (q : Fin L → Finset (Fin w)) : Set (Fin d → ℝ) :=
  {x | net.netPattern L x = q}

lemma mem_netCell {net : ReLUNet d w} {L : ℕ} {q : Fin L → Finset (Fin w)} {x : Fin d → ℝ} :
    x ∈ net.netCell L q ↔ ∀ l : Fin L, net.layerPattern (l : ℕ) x = q l := by
  constructor
  · intro hx l
    exact congrFun hx l
  · intro h
    funext l
    exact h l

/-- On a cell, every layer's pattern is the pattern of the corresponding
affinized family. -/
lemma layerPattern_eq_of_mem_netCell {net : ReLUNet d w} {L : ℕ}
    {q : Fin L → Finset (Fin w)} {x : Fin d → ℝ} (hx : x ∈ net.netCell L q) (l : Fin L) :
    (net.preFamily (wordExtend q) (l : ℕ)).pattern x = q l := by
  have hall : ∀ i < (l : ℕ), net.layerPattern i x = wordExtend q i := by
    intro i hi
    have hiL : i < L := lt_trans hi l.isLt
    rw [wordExtend_apply q hiL]
    exact mem_netCell.mp hx ⟨i, hiL⟩
  have := net.layerPattern_eq_preFamily_pattern (wordExtend q) x (l : ℕ) hall
  rw [← this]
  exact mem_netCell.mp hx l

/-- **The cell is a finite intersection of affine-family cells.** -/
theorem netCell_eq_iInter (net : ReLUNet d w) (L : ℕ) (q : Fin L → Finset (Fin w)) :
    net.netCell L q
      = ⋂ l : Fin L,
          {x : Fin d → ℝ | (net.preFamily (wordExtend q) (l : ℕ)).pattern x = q l} := by
  ext x
  simp only [Set.mem_iInter, Set.mem_setOf_eq]
  constructor
  · intro hx l
    exact layerPattern_eq_of_mem_netCell hx l
  · intro h
    refine mem_netCell.mpr ?_
    -- strong induction on the layer index
    have key : ∀ n : ℕ, n < L → net.layerPattern n x = wordExtend q n := by
      intro n
      induction n using Nat.strong_induction_on with
      | _ n ih =>
          intro hn
          have hall : ∀ i < n, net.layerPattern i x = wordExtend q i :=
            fun i hi => ih i hi (lt_trans hi hn)
          rw [net.layerPattern_eq_preFamily_pattern (wordExtend q) x n hall,
            wordExtend_apply q hn]
          exact h ⟨n, hn⟩
    intro l
    have := key (l : ℕ) l.isLt
    rwa [wordExtend_apply q l.isLt] at this

/-- **Every activation cell of a deep ReLU network is convex.**  Consequently
each cell is connected, and the pattern word is a genuine geometric label: the
partition it induces is a partition into convex pieces. -/
theorem convex_netCell (net : ReLUNet d w) (L : ℕ) (q : Fin L → Finset (Fin w)) :
    Convex ℝ (net.netCell L q) := by
  rw [netCell_eq_iInter]
  exact convex_iInter fun l => AffineFamily.convex_cell _ _

/-- **In dimension one every cell is an interval.**  If two inputs lie in the
same cell then so does every input between them. -/
theorem netCell_ordConnected_one (net : ReLUNet 1 w) (L : ℕ) (q : Fin L → Finset (Fin w))
    {x y z : Fin 1 → ℝ} (hx : x ∈ net.netCell L q) (hy : y ∈ net.netCell L q)
    (hxz : x 0 ≤ z 0) (hzy : z 0 ≤ y 0) : z ∈ net.netCell L q := by
  have hfun : ∀ v : Fin 1 → ℝ, v = fun _ => v 0 := by
    intro v
    funext i
    congr 1
    omega
  rcases eq_or_lt_of_le (hxz.trans hzy) with hxy | hxy
  · have hz : z = x := by
      rw [hfun z, hfun x]
      have : z 0 = x 0 := le_antisymm (by linarith) hxz
      rw [this]
    rwa [hz]
  · set a : ℝ := (y 0 - z 0) / (y 0 - x 0) with ha
    set b : ℝ := (z 0 - x 0) / (y 0 - x 0) with hb
    have hpos : 0 < y 0 - x 0 := by linarith
    have ha0 : 0 ≤ a := by
      rw [ha]
      apply div_nonneg <;> linarith
    have hb0 : 0 ≤ b := by
      rw [hb]
      apply div_nonneg <;> linarith
    have hab : a + b = 1 := by
      rw [ha, hb]
      field_simp
      ring
    have hcomb := convex_netCell net L q hx hy ha0 hb0 hab
    have hz : a • x + b • y = z := by
      rw [hfun x, hfun y, hfun z]
      funext i
      have : a * x 0 + b * y 0 = z 0 := by
        rw [ha, hb]
        field_simp
        ring
      simpa using this
    rwa [hz] at hcomb

/-! ### Axiom audit -/

#print axioms convex_netCell
#print axioms netCell_ordConnected_one

end ReLUNet

end ReLUPartition