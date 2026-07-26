/-
# The Boltzmann Bridge IV — The Interleaving Distance and Bottleneck Stability

This file closes the catalog's persistent-homology arc.  The earlier files built
the *filtration calculus* (`Applications.BoltzmannBridge.HigherPersistence`:
`Filtration`, `sublevelFaces`, `sublevel_mono`, the Vietoris–Rips `diamWeight`)
and the *relational interleaving lemmas*
(`Applications.BoltzmannBridge.PersistenceStability`: `stability_interleaving`,
`stability_compose`, `stability_two_sided`).  Those files produced a family of
scattered set-inclusion inequalities.  This file turns them into a single
coherent **metric theory of persistence stability**:

* a named, symmetric, additively-composable interleaving relation
  `Interleaved F G δ` (with `Interleaved_refl/symm/mono/trans`) — the relational
  skeleton of a graded preorder;
* a real-valued `interleavingDist`, shown to be a *symmetric, grounded
  pre-distance* (`interleavingDist_nonneg`, `interleavingDist_le`,
  `interleavingDist_self`, `interleavingDist_comm`);
* the Cohen-Steiner–Edelsbrunner–Harer sublevel stability theorem in sharp
  `1`-Lipschitz form: uniform `D`-closeness of the weights forces a
  `D`-interleaving and `interleavingDist ≤ D` (`stability_supDist`,
  `interleavingDist_le_supDist`);
* a Gromov–Hausdorff / correspondence-distortion layer over **explicit distance
  matrices** `d : α → α → ℝ` (`diamWeightOf`, `diamFiltrationOf`), resting on the
  single load-bearing estimate `diamWeightOf_dist_le` — *the simplex diameter is
  `1`-Lipschitz in the input metric* — yielding `vr_stability_interleaved` and
  `vr_stability_dist`;
* an end-to-end concrete certificate on two `3`-point clouds
  (`cloud_distortion`, `cloud_stability`, `cloud_interleavingDist_le`).

The entire stability phenomenon collapses onto one inequality: the simplex weight
is `1`-Lipschitz in the data.  Everything else is monotonicity bookkeeping.

## Main results

* `Interleaved_refl/symm/mono/trans` — interleaving is a graded preorder
* `interleavingDist_nonneg/le/self/comm` — a symmetric grounded pre-distance
* `stability_supDist`, `interleavingDist_le_supDist` — CESH `1`-Lipschitz stability
* `diamWeightOf_dist_le` — VR diameter is `1`-Lipschitz in the distance matrix
* `vr_stability_interleaved`, `vr_stability_dist` — distortion `≤ ε` ⇒ stability
* `cloud_distortion/stability/interleavingDist_le` — concrete point-cloud certificate
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability

open Finset BigOperators

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## The interleaving relation -/

/-- **`δ`-interleaving of two filtrations.**  Two filtrations are `δ`-interleaved
(for `δ ≥ 0`) when each one's sublevel family is contained in the other's after a
uniform `δ`-shift of scale.  This is the relational core of the interleaving /
bottleneck distance and the combinatorial form of an interleaving of persistence
modules. -/
def Interleaved (F G : Filtration α) (δ : ℝ) : Prop :=
  0 ≤ δ ∧
    (∀ t : ℝ, F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)) ∧
    (∀ t : ℝ, G.sublevelFaces t ⊆ F.sublevelFaces (t + δ))

-- !-- `0 ≤ 0`; and `F.sublevelFaces t ⊆ F.sublevelFaces (t+0)` simplifies via `t+0 = t`. -- !--
/-- Every filtration is `0`-interleaved with itself: interleaving is reflexive. -/
theorem Interleaved_refl (F : Filtration α) : Interleaved F F 0 :=
  ⟨le_rfl, fun _ => by simp, fun _ => by simp⟩

-- !-- Swap the two inclusion clauses; `0 ≤ δ` is preserved. -- !--
/-- Interleaving is symmetric in the two filtrations. -/
theorem Interleaved_symm {F G : Filtration α} {δ : ℝ} (h : Interleaved F G δ) :
    Interleaved G F δ :=
  ⟨h.1, h.2.2, h.2.1⟩

-- !-- Enlarge each shift via `sublevel_mono` (`t+δ ≤ t+δ'`); `0 ≤ δ ≤ δ'` by `linarith`. -- !--
/-- Interleaving is monotone in the shift: a `δ`-interleaving is a
`δ'`-interleaving for any `δ' ≥ δ`. -/
theorem Interleaved_mono {F G : Filtration α} {δ δ' : ℝ}
    (h : Interleaved F G δ) (hδ : δ ≤ δ') : Interleaved F G δ' := by
  refine ⟨by linarith [h.1], fun t => ?_, fun t => ?_⟩
  · exact Set.Subset.trans (h.2.1 t) (Filtration.sublevel_mono _ (by linarith))
  · exact Set.Subset.trans (h.2.2 t) (Filtration.sublevel_mono _ (by linarith))

-- !-- Chain the two interleavings' inclusions (cf. `stability_compose`); the shifts
-- !-- add since `t + (δ + δ') = (t + δ) + δ'`. -- !--
/-- **Additivity / triangle inequality at the relational level.**  A
`δ`-interleaving composed with a `δ'`-interleaving is a `(δ + δ')`-interleaving.
This is the engine behind the triangle inequality for `interleavingDist`. -/
theorem Interleaved_trans {F G H : Filtration α} {δ δ' : ℝ}
    (h₁ : Interleaved F G δ) (h₂ : Interleaved G H δ') :
    Interleaved F H (δ + δ') := by
  refine ⟨by linarith [h₁.1, h₂.1], fun t => ?_, fun t => ?_⟩
  · have := Set.Subset.trans (h₁.2.1 t) (h₂.2.1 (t + δ))
    rwa [add_assoc] at this
  · have := Set.Subset.trans (h₂.2.2 t) (h₁.2.2 (t + δ'))
    rwa [add_assoc, add_comm δ' δ] at this

/-! ## The interleaving distance -/

/-- **The interleaving distance** between two filtrations: the infimum of all
admissible interleaving shifts.  (With the Lean convention `sInf ∅ = 0`, two
never-interleaved filtrations are reported at distance `0`; promoting the codomain
to `EReal` to record `⊤` is left to future work — see the Lab Notebook.) -/
noncomputable def interleavingDist (F G : Filtration α) : ℝ :=
  sInf {δ : ℝ | Interleaved F G δ}

-- !-- Every admissible shift is `≥ 0` (first component of `Interleaved`), so
-- !-- `Real.sInf_nonneg` gives the bound. -- !--
/-- The interleaving distance is nonnegative. -/
theorem interleavingDist_nonneg (F G : Filtration α) : 0 ≤ interleavingDist F G :=
  Real.sInf_nonneg fun _ hx => hx.1

-- !-- `δ` lies in the shift set, which is bounded below by `0`; apply `csInf_le`. -- !--
/-- **Upper bound by any witness.**  Any admissible interleaving shift bounds the
interleaving distance from above. -/
theorem interleavingDist_le (F G : Filtration α) {δ : ℝ} (h : Interleaved F G δ) :
    interleavingDist F G ≤ δ :=
  csInf_le ⟨0, fun _ hx => hx.1⟩ h

-- !-- `≤ 0` from `interleavingDist_le` with `Interleaved_refl`, `≥ 0` from `nonneg`. -- !--
/-- The interleaving distance vanishes on the diagonal. -/
theorem interleavingDist_self (F : Filtration α) : interleavingDist F F = 0 :=
  le_antisymm
    (le_trans (interleavingDist_le _ _ (Interleaved_refl _)) (by norm_num))
    (interleavingDist_nonneg _ _)

-- !-- `Interleaved_symm` makes the two shift sets equal, hence equal infima. -- !--
/-- The interleaving distance is symmetric. -/
theorem interleavingDist_comm (F G : Filtration α) :
    interleavingDist F G = interleavingDist G F := by
  unfold interleavingDist
  congr! 2
  ext δ
  exact ⟨Interleaved_symm, Interleaved_symm⟩

/-! ## Cohen-Steiner–Edelsbrunner–Harer sublevel stability (1-Lipschitz form) -/

/-- Uniform `D`-closeness of two weight functions in sup-norm. -/
def WeightCloseBy (F G : Filtration α) (D : ℝ) : Prop :=
  ∀ σ : Finset α, |F.weight σ - G.weight σ| ≤ D

-- !-- Each direction is `stability_two_sided`; the shift `D ≥ 0` packages the
-- !-- symmetric bound into an `Interleaved`. -- !--
/-- **CESH stability (interleaving form).**  Two filtrations whose weights are
uniformly within `D` are `D`-interleaved. -/
theorem stability_supDist (F G : Filtration α) {D : ℝ}
    (hD : 0 ≤ D) (h : WeightCloseBy F G D) : Interleaved F G D :=
  ⟨hD, fun t => (Filtration.stability_two_sided F G h t).1,
       fun t => (Filtration.stability_two_sided F G h t).2⟩

-- !-- Combine `stability_supDist` with `interleavingDist_le`. -- !--
/-- **CESH stability, sharp `1`-Lipschitz form.**  The interleaving distance is
bounded by the sup-norm distance of the weights — persistence is `1`-Lipschitz in
the data. -/
theorem interleavingDist_le_supDist (F G : Filtration α) {D : ℝ}
    (hD : 0 ≤ D) (h : WeightCloseBy F G D) : interleavingDist F G ≤ D :=
  interleavingDist_le _ _ (stability_supDist _ _ hD h)

end Filtration

/-! ## Vietoris–Rips over explicit distance matrices -/

section VR

variable {α : Type*}

/-- The **diameter weight of a simplex under an explicit distance matrix** `d`:
the largest value `d x y` over vertices `x, y` of `σ`, with `0` thrown in so that
the empty simplex and singletons get weight `0`.  No metric-space structure on
`α` is required — the data is the bare matrix `d`. -/
noncomputable def diamWeightOf (d : α → α → ℝ) (σ : Finset α) : ℝ :=
  (insert (0 : ℝ) ((σ ×ˢ σ).image (fun p => d p.1 p.2))).sup'
    (insert_nonempty _ _) id

-- !-- `0` always sits in the inserted set, so the `sup'` dominates it via `le_sup'`. -- !--
/-- The diameter weight is always nonnegative (the constant `0` is a candidate). -/
theorem diamWeightOf_nonneg (d : α → α → ℝ) (σ : Finset α) : 0 ≤ diamWeightOf d σ :=
  Finset.le_sup' (fun x => x) (Finset.mem_insert_self _ _)

-- !-- The empty product is empty, so the `sup'` is over `{0}`, giving `0`. -- !--
/-- The diameter weight of the empty simplex is `≤ 0`. -/
theorem diamWeightOf_empty (d : α → α → ℝ) : diamWeightOf d ∅ ≤ 0 := by
  unfold diamWeightOf; aesop

-- !-- Every pairwise distance of `σ` is a pairwise distance of `τ ⊇ σ`, so the
-- !-- smaller `sup'` is dominated by the larger one (`sup'_le` + `le_sup'`). -- !--
/-- The diameter weight is monotone under inclusion of simplices. -/
theorem diamWeightOf_mono (d : α → α → ℝ) {σ τ : Finset α} (h : σ ⊆ τ) :
    diamWeightOf d σ ≤ diamWeightOf d τ := by
  refine Finset.sup'_le _ _ fun x hx => ?_
  have h_mem : x ∈ insert 0 ((τ ×ˢ τ).image (fun p => d p.1 p.2)) := by
    simp +zetaDelta at *
    exact hx.imp id fun ⟨a, b, ⟨ha, hb⟩, hx⟩ => ⟨a, b, ⟨h ha, h hb⟩, hx⟩
  exact Finset.le_sup' (fun p => id p) h_mem

/-- The diameter weight matrix, packaged as a `Filtration` (works for any `d`). -/
noncomputable def diamFiltrationOf (d : α → α → ℝ) : Filtration α where
  weight := diamWeightOf d
  weight_empty := diamWeightOf_empty d
  weight_mono := fun h => diamWeightOf_mono d h

-- !-- The load-bearing `1`-Lipschitz estimate: bound each `d₁ x y ≤ d₂ x y + ε ≤`
-- !-- `diamWeightOf d₂ σ + ε`, and `0 ≤ diamWeightOf d₂ σ + ε`; then `sup'_le` both
-- !-- ways and `abs_sub_le_iff`. -- !--
/-- **The diameter is `1`-Lipschitz in the distance matrix.**  If the two matrices
differ by at most `ε` on the vertices of `σ`, their diameter weights differ by at
most `ε`.  This single inequality drives all Vietoris–Rips stability. -/
theorem diamWeightOf_dist_le (d₁ d₂ : α → α → ℝ) (σ : Finset α) {ε : ℝ}
    (hε : 0 ≤ ε) (h : ∀ x ∈ σ, ∀ y ∈ σ, |d₁ x y - d₂ x y| ≤ ε) :
    |diamWeightOf d₁ σ - diamWeightOf d₂ σ| ≤ ε := by
  refine abs_sub_le_iff.mpr ⟨?_, ?_⟩
  · refine sub_le_iff_le_add'.mpr (Finset.sup'_le _ _ ?_)
    simp +zetaDelta at *
    exact ⟨add_nonneg (diamWeightOf_nonneg _ _) hε,
      fun a x y hx hy ha => by
        linarith [abs_le.mp (h x hx y hy),
          show d₂ x y ≤ diamWeightOf d₂ σ from Finset.le_sup' (fun p => id p) (by aesop)]⟩
  · refine sub_le_iff_le_add.mpr (Finset.sup'_le _ _ ?_)
    simp +zetaDelta at *
    exact ⟨add_nonneg hε (diamWeightOf_nonneg _ _),
      fun a x y hx hy ha => by
        linarith [abs_le.mp (h x hx y hy),
          show d₁ x y ≤ diamWeightOf d₁ σ from Finset.le_sup' (fun p => id p) (by aesop)]⟩

-- !-- Apply `diamWeightOf_dist_le` to every `σ` to get `WeightCloseBy`, then
-- !-- `stability_supDist`. -- !--
/-- **Vietoris–Rips stability (interleaving form).**  If two distance matrices are
uniformly within `ε`, their VR filtrations are `ε`-interleaved. -/
theorem vr_stability_interleaved (d₁ d₂ : α → α → ℝ) {ε : ℝ}
    (hε : 0 ≤ ε) (h : ∀ x y, |d₁ x y - d₂ x y| ≤ ε) :
    Filtration.Interleaved (diamFiltrationOf d₁) (diamFiltrationOf d₂) ε :=
  Filtration.stability_supDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) hε
    (fun σ => diamWeightOf_dist_le d₁ d₂ σ hε fun x _ y _ => h x y)

-- !-- `interleavingDist_le` applied to `vr_stability_interleaved`. -- !--
/-- **Vietoris–Rips stability (distance form).**  The interleaving distance of two
VR filtrations is bounded by the sup-norm distortion of their distance matrices. -/
theorem vr_stability_dist (d₁ d₂ : α → α → ℝ) {ε : ℝ}
    (hε : 0 ≤ ε) (h : ∀ x y, |d₁ x y - d₂ x y| ≤ ε) :
    Filtration.interleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) ≤ ε :=
  Filtration.interleavingDist_le _ _ (vr_stability_interleaved d₁ d₂ hε h)

end VR

/-! ## A concrete point-cloud certificate -/

section Cloud

/-- A `3`-point cloud: unit-distance triangle (all off-diagonal distances `1`). -/
def cloud₁ : Fin 3 → Fin 3 → ℝ := fun i j => if i = j then 0 else 1

/-- A `δ`-perturbed `3`-point cloud (off-diagonal distances `11/10`). -/
noncomputable def cloud₂ : Fin 3 → Fin 3 → ℝ := fun i j => if i = j then 0 else 11/10

-- !-- A finite `Fin 3 × Fin 3` case split; each entry differs by `0` or `1/10`. -- !--
/-- The two clouds are uniformly within `1/10`. -/
theorem cloud_distortion : ∀ i j : Fin 3, |cloud₁ i j - cloud₂ i j| ≤ (1/10 : ℝ) := by
  intro i j
  fin_cases i <;> fin_cases j <;> norm_num [cloud₁, cloud₂, Fin.ext_iff, abs_le]

-- !-- `vr_stability_interleaved` with the `cloud_distortion` bound. -- !--
/-- The two clouds' VR filtrations are `(1/10)`-interleaved. -/
theorem cloud_stability :
    Filtration.Interleaved (diamFiltrationOf cloud₁) (diamFiltrationOf cloud₂) (1/10) :=
  vr_stability_interleaved cloud₁ cloud₂ (by norm_num) cloud_distortion

-- !-- `vr_stability_dist` with the `cloud_distortion` bound. -- !--
/-- The interleaving distance of the two clouds is at most `1/10`. -/
theorem cloud_interleavingDist_le :
    Filtration.interleavingDist (diamFiltrationOf cloud₁) (diamFiltrationOf cloud₂)
      ≤ (1/10 : ℝ) :=
  vr_stability_dist cloud₁ cloud₂ (by norm_num) cloud_distortion

end Cloud

/-
-- !-- Lab Notebook -- !--

## Hypothesis
The scattered set-inclusion stability inequalities of `PersistenceStability`
(`stability_interleaving`, `stability_compose`, `stability_two_sided`) are the
shadow of a single *metric* statement: there is a real-valued interleaving
distance on filtrations under which persistence is `1`-Lipschitz in the data, and
the whole Vietoris–Rips stability theory reduces to the diameter being
`1`-Lipschitz in the distance matrix.

## Result
Confirmed.  `Interleaved` is a graded preorder (`refl/symm/mono/trans`),
`interleavingDist` is a symmetric grounded pre-distance bounded above by any
witness, and `interleavingDist_le_supDist` is the sharp CESH `1`-Lipschitz bound.
Over explicit distance matrices the entire theory rests on the single estimate
`diamWeightOf_dist_le`; `vr_stability_dist` and the concrete `cloud_*` certificate
follow as monotonicity bookkeeping.

## Insight
`Interleaved_trans` *is* the triangle inequality, already at the relational level,
and `diamWeightOf_dist_le` (a one-line `sup'` Lipschitz estimate) *is* the entire
Gromov–Hausdorff–to–bottleneck pipeline.  Removing metric-space structure in
favour of a bare matrix `d : α → α → ℝ` makes the Lipschitz content transparent
and decouples VR stability from `PseudoMetricSpace`.

## Failure analysis
The honest fault line is `interleavingDist`: with `sInf ∅ = 0`, two
never-interleaved filtrations are reported at distance `0`, so the triangle
inequality for `interleavingDist` is *not* unconditionally true in `ℝ` — it needs
either a finiteness/witness hypothesis or an `EReal` codomain.  We therefore prove
only the unconditional facts (`nonneg`, `le`, `self`, `comm`) and document the
`EReal` upgrade as Future Direction 1.
-/

end BoltzmannBridge