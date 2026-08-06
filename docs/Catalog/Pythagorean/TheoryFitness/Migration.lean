/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# Migration graphs: adapter valleys and three-style metastability

Two conjectures about the *shape* of the fitness landscape of formal
developments are made precise and proved here from explicitly stated,
individually measurable hypotheses.

## Adapter valleys

A **migration path** is a finite walk `w : ℕ → Dev` through developments in
which each step is a bounded, semantics-preserving refactoring.

* `exists_boundary_crossing` : if the endpoints use inequivalent abstraction
  layers, some single step crosses the boundary.  (Purely combinatorial.)
* `adapter_valley` : if in addition a crossing state must implement both
  interfaces -- costing at least `(1 + α)` times the intrinsic content -- while
  the endpoints are `(1 + β)`-efficient with `β < α`, then *every* such path
  contains an intermediate state whose source length exceeds the smaller
  endpoint length by at least the fixed positive fraction `(α - β)/(1 + β)`.
  This is the quantitative adapter-valley conjecture, reduced to the single
  measurable class of cross-interface transitions.

## Three-style metastability

* `strictLocalMax_of_style_closed` : a stylewise-optimal development whose
  neighbourhood never leaves its own style is a strict local maximum;
* `strictLocalMax_of_quarantine` : the same holds under the weaker hypothesis
  that boundary-crossing neighbours are strictly less fit;
* `strictLocalMax_of_renaming` : strict local maxima are invariant under
  semantics-preserving renaming, so the notion descends to the quotient;
* `three_style_metastability` : a fully computed nine-development landscape with
  algebraic, analytic and combinatorial styles exhibiting three *distinct*
  strict local maxima, one per style.
-/

import Mathlib

namespace TheoryFitness.Migration

/-! ## Developments and migration paths -/

/-- A development seen by the migration graph: its source length, the principal
interface (abstraction layer) it is written against, and the intrinsic size of
the mathematical content it implements. -/
structure Dev where
  /-- source length -/
  len : ℚ
  /-- identifier of the principal interface / abstraction layer -/
  iface : ℕ
  /-- intrinsic size of the semantic content, invariant along the path -/
  content : ℚ

/-- **Boundary crossing.**  A walk whose endpoints are written against
inequivalent abstraction layers must contain a single step that crosses the
interface boundary. -/
theorem exists_boundary_crossing (w : ℕ → Dev) (n : ℕ)
    (hends : (w 0).iface ≠ (w n).iface) :
    ∃ i < n, (w i).iface ≠ (w (i + 1)).iface := by
  by_contra hcon
  push_neg at hcon
  have hconst : ∀ k ≤ n, (w k).iface = (w 0).iface := by
    intro k hk
    induction k with
    | zero => rfl
    | succ k ih =>
        have hk' : k < n := by omega
        rw [← hcon k hk']
        exact ih (by omega)
  exact hends (hconst n le_rfl).symm

/-- **Quantitative adapter valley.**  Along any semantics-preserving migration
between developments using inequivalent interfaces, some intermediate state
overshoots the smaller endpoint length by at least the fixed positive fraction
`(α - β)/(1 + β)` of that length. -/
theorem adapter_valley (w : ℕ → Dev) (n : ℕ) (α β : ℚ)
    (hC : 0 < (w 0).content) (hβ : 0 ≤ β) (hαβ : β < α)
    (hends : (w 0).iface ≠ (w n).iface)
    -- the migration is semantics preserving: the content never changes
    (hcontent : ∀ i ≤ n, (w i).content = (w 0).content)
    -- a state crossing the interface boundary must carry an adapter
    (hadapter : ∀ i < n, (w i).iface ≠ (w (i + 1)).iface →
      (1 + α) * (w i).content ≤ (w i).len)
    -- the starting point is an efficient implementation of the content
    (heff0 : (w 0).len ≤ (1 + β) * (w 0).content) :
    ∃ i ≤ n, (w i).len - min (w 0).len (w n).len
      ≥ ((α - β) / (1 + β)) * min (w 0).len (w n).len := by
  obtain ⟨i, hi, hcross⟩ := exists_boundary_crossing w n hends
  refine ⟨i, le_of_lt hi, ?_⟩
  set C : ℚ := (w 0).content with hCdef
  set m : ℚ := min (w 0).len (w n).len with hm
  have hmle : m ≤ (1 + β) * C := le_trans (min_le_left _ _) heff0
  have hlow : (1 + α) * C ≤ (w i).len := by
    have h := hadapter i hi hcross
    rwa [hcontent i (le_of_lt hi)] at h
  have hβ1 : (0 : ℚ) < 1 + β := by linarith
  have hγ : ((α - β) / (1 + β)) * ((1 + β) * C) = (α - β) * C := by
    field_simp
  rcases le_or_gt m 0 with hm0 | hm0
  · -- a nonpositive endpoint length makes the claim immediate
    have h1 : 0 ≤ (α - β) / (1 + β) := div_nonneg (by linarith) (by linarith)
    nlinarith [hlow, hC, hαβ, hm0, h1]
  · have hfrac : ((α - β) / (1 + β)) * m ≤ ((α - β) / (1 + β)) * ((1 + β) * C) := by
      have h1 : 0 ≤ (α - β) / (1 + β) := div_nonneg (by linarith) (by linarith)
      exact mul_le_mul_of_nonneg_left hmle h1
    have : ((α - β) / (1 + β)) * m ≤ (α - β) * C := by rw [← hγ]; exact hfrac
    nlinarith [hlow, hmle, this]

/-- The valley depth is a *positive* fraction of the endpoint length whenever
the endpoints are strictly more efficient than the adapter state requires. -/
theorem adapter_fraction_pos {α β : ℚ} (hβ : 0 ≤ β) (hαβ : β < α) :
    0 < (α - β) / (1 + β) :=
  div_pos (by linarith) (by linarith)

/-! ## Metastability of methodological styles -/

variable {S K : Type*}

/-- `b` is a strict local maximum of `fit` for the neighbourhood relation
`adj`. -/
def IsStrictLocalMax (fit : S → ℚ) (adj : S → S → Prop) (b : S) : Prop :=
  ∀ t, adj b t → t ≠ b → fit t < fit b

/-- `b` is strictly optimal inside its own style. -/
def IsStyleOptimal (fit : S → ℚ) (style : S → K) (b : S) : Prop :=
  ∀ t, style t = style b → t ≠ b → fit t < fit b

/-- **Style-centre theorem.**  Stylewise optimality plus a neighbourhood that
never crosses a methodological boundary yields a strict local maximum.  The two
hypotheses are independently measurable, which is exactly what makes the
metastability conjecture falsifiable. -/
theorem strictLocalMax_of_style_closed (fit : S → ℚ) (adj : S → S → Prop)
    (style : S → K) (b : S)
    (hclosed : ∀ x y, adj x y → style x = style y)
    (hopt : IsStyleOptimal fit style b) :
    IsStrictLocalMax fit adj b :=
  fun t hbt hne => hopt t (hclosed b t hbt).symm hne

/-- Weakened, more realistic hypothesis: boundaries *may* be crossed, provided
the cross-style neighbours are strictly less fit ("adapter quarantine"). -/
theorem strictLocalMax_of_quarantine (fit : S → ℚ) (adj : S → S → Prop)
    (style : S → K) (b : S)
    (hopt : IsStyleOptimal fit style b)
    (hquar : ∀ t, adj b t → style t ≠ style b → fit t < fit b) :
    IsStrictLocalMax fit adj b := by
  intro t hbt hne
  by_cases hst : style t = style b
  · exact hopt t hst hne
  · exact hquar t hbt hst

/-- Strict local maxima are invariant under a semantics-preserving renaming:
the notion descends to the quotient by renaming. -/
theorem strictLocalMax_of_renaming (fit : S → ℚ) (adj : S → S → Prop)
    (σ : S ≃ S) (b : S)
    (hfit : ∀ x, fit (σ x) = fit x)
    (hadj : ∀ x y, adj (σ x) (σ y) → adj x y)
    (hb : IsStrictLocalMax fit adj b) :
    IsStrictLocalMax fit adj (σ b) := by
  intro t hbt hne
  have h1 : adj b (σ.symm t) := hadj b (σ.symm t) (by simpa using hbt)
  have h2 : σ.symm t ≠ b := by
    intro h
    exact hne (by rw [← h, Equiv.apply_symm_apply])
  have := hb (σ.symm t) h1 h2
  rw [hfit b]
  calc fit t = fit (σ (σ.symm t)) := by rw [Equiv.apply_symm_apply]
    _ = fit (σ.symm t) := hfit _
    _ < fit b := this

/-! ### A computed three-style landscape

Nine developments of a fixed corpus, three per methodological style
(`0` algebraic, `1` analytic, `2` combinatorial).  Bounded refactorings never
change the style, and each style has a unique fitness maximiser, so the
landscape has exactly three strict local maxima -- one per style. -/

/-- Measured fitness of the nine developments. -/
def styleFit : Fin 9 → ℚ := ![1, 2, 5, 3, 7, 4, 6, 2, 9]

/-- Methodological style of each development: algebraic, analytic,
combinatorial. -/
def styleOf : Fin 9 → ℕ := fun i => (i : ℕ) / 3

/-- Bounded refactorings connect developments of the same style. -/
def styleAdj : Fin 9 → Fin 9 → Prop := fun i j => styleOf i = styleOf j

theorem styleAdj_closed : ∀ x y, styleAdj x y → styleOf x = styleOf y :=
  fun _ _ h => h

/-- **Three-style metastability.**  The landscape has three distinct strict
local maxima, one in each of the algebraic, analytic and combinatorial
styles. -/
theorem three_style_metastability :
    IsStrictLocalMax styleFit styleAdj 2 ∧
      IsStrictLocalMax styleFit styleAdj 4 ∧
      IsStrictLocalMax styleFit styleAdj 8 ∧
      styleOf 2 ≠ styleOf 4 ∧ styleOf 2 ≠ styleOf 8 ∧ styleOf 4 ≠ styleOf 8 := by
  refine ⟨?_, ?_, ?_, by decide, by decide, by decide⟩
  · exact strictLocalMax_of_style_closed styleFit styleAdj styleOf 2
      styleAdj_closed (by unfold IsStyleOptimal; decide)
  · exact strictLocalMax_of_style_closed styleFit styleAdj styleOf 4
      styleAdj_closed (by unfold IsStyleOptimal; decide)
  · exact strictLocalMax_of_style_closed styleFit styleAdj styleOf 8
      styleAdj_closed (by unfold IsStyleOptimal; decide)

/-- None of the three local maxima is global: metastability is genuine, the
landscape is not a single peak. -/
theorem three_style_not_global :
    styleFit 2 < styleFit 8 ∧ styleFit 4 < styleFit 8 := by
  constructor <;> decide

/-! ### A computed adapter valley

A two-step migration `A → adapter → B` between two `1.1`-efficient endpoints of
content `100` across an interface boundary whose adapter state costs `1.5`
times the content.  The guaranteed relative overshoot is
`(0.5 - 0.1)/1.1 = 4/11`. -/

/-- The three states of the computed migration. -/
def valleyWalk : ℕ → Dev := fun i =>
  if i = 0 then ⟨110, 0, 100⟩
  else if i = 1 then ⟨150, 0, 100⟩
  else ⟨110, 1, 100⟩

theorem valley_instance :
    ∃ i ≤ 2, (valleyWalk i).len - min (valleyWalk 0).len (valleyWalk 2).len
      ≥ ((1/2 - 1/10) / (1 + 1/10)) * min (valleyWalk 0).len (valleyWalk 2).len := by
  refine adapter_valley valleyWalk 2 (1/2) (1/10) (by norm_num [valleyWalk])
    (by norm_num) (by norm_num) (by decide) ?_ ?_ (by norm_num [valleyWalk])
  · intro i hi
    interval_cases i <;> norm_num [valleyWalk]
  · intro i hi hcross
    interval_cases i
    · simp [valleyWalk] at hcross
    · norm_num [valleyWalk]

end TheoryFitness.Migration