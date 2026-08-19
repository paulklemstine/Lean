/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality XII: zero parse defect *is* sufficiency

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

The chain rule of the previous file prices a parse: `D(p‖q)` exceeds the parsed
divergence `D(f_*p‖f_*q)` by the within-fibre defect `condKlDiv`.  Here the
converse is proved: **the defect vanishes only for a sufficient parse.**

`cond_eq_of_condKlDiv_eq_zero` shows a zero defect forces the within-fibre
conditional laws of `p` and `q` to coincide (strict Gibbs, applied fibre by
fibre through the subtype of a fibre), and
`factorizes_of_condKlDiv_eq_zero` turns that into the Fisher–Neyman
factorization `p_θ(x) = g_θ(f x) · m(x)` with the explicit
`g_θ(y) = f_*p_θ(y) / f_*m(y)`.  Together with
`condKlDiv_eq_zero_of_factorizes` this is an exact characterisation:

  **a front end loses no bits ⇔ it computes a sufficient statistic.**

That is the test a compressor designer wants: it decides whether a proposed
parse (histogram, token stream, match/literal split) can be used without paying
for it.

## Main results

* `sum_fibre_eq` — a fibre sum as a sum over the fibre's subtype
* `condKlDiv_fibre_nonneg` — each fibre contributes nonnegatively
* `cond_eq_of_condKlDiv_eq_zero` — zero defect forces equal conditional laws
* `factorizes_of_condKlDiv_eq_zero` — zero defect forces Fisher–Neyman
* `condKlDiv_eq_zero_iff_factorizes` — the characterisation

## Application keywords

universal compression, minimax redundancy, sufficiency, Fisher–Neyman
factorization, conditional divergence, strict Gibbs inequality, parsing
-/

import Bridges.UniversalRedundancyCapacityParse
import Bridges.UniversalRedundancyCapacityStructure

open Finset Real

namespace UniversalRedundancy

variable {X : Type*} [Fintype X] {Y : Type*} [Fintype Y] [DecidableEq Y]

omit [Fintype Y] in
/-- A sum over a fibre of `f` is a sum over the fibre's subtype. -/
lemma sum_fibre_eq (f : X → Y) (y : Y) (F : X → ℝ) :
    ∑ x ∈ univ.filter (fun x => f x = y), F x = ∑ z : {x : X // f x = y}, F z.1 :=
  Finset.sum_subtype _ (fun x => by simp) F

/-- The conditional law of `p` inside the fibre over `y`. -/
noncomputable def fibreCond (f : X → Y) (p : X → ℝ) (y : Y) :
    {x : X // f x = y} → ℝ := fun z => p z.1 / pushMeasure f p y

omit [Fintype Y] in
lemma fibreCond_pos {f : X → Y} {p : X → ℝ} (hp : ∀ x, 0 < p x) {y : Y}
    (hy : 0 < pushMeasure f p y) (z : {x : X // f x = y}) : 0 < fibreCond f p y z :=
  div_pos (hp z.1) hy

omit [Fintype Y] in
lemma fibreCond_sum_one {f : X → Y} {p : X → ℝ} {y : Y}
    (hy : 0 < pushMeasure f p y) : ∑ z, fibreCond f p y z = 1 := by
  unfold fibreCond
  rw [← Finset.sum_div, ← sum_fibre_eq]
  exact div_self (ne_of_gt hy)

omit [Fintype Y] in
/-- The contribution of one fibre to the parse defect is `f_*p(y)` times the
divergence of the conditional laws inside the fibre. -/
lemma condKlDiv_fibre_eq (f : X → Y) {p q : X → ℝ} {y : Y}
    (hy : 0 < pushMeasure f p y) :
    ∑ x ∈ univ.filter (fun x => f x = y),
        p x * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y))
      = pushMeasure f p y * klDiv (fibreCond f p y) (fibreCond f q y) := by
  rw [sum_fibre_eq]
  unfold klDiv fibreCond
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun z _ => ?_
  field_simp

omit [Fintype Y] in
/-- Every fibre contributes nonnegatively to the parse defect. -/
lemma condKlDiv_fibre_nonneg (f : X → Y) {p q : X → ℝ} (hp : ∀ x, 0 < p x)
    (hq : ∀ x, 0 < q x) (y : Y) :
    0 ≤ ∑ x ∈ univ.filter (fun x => f x = y),
        p x * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y)) := by
  rcases Finset.eq_empty_or_nonempty (univ.filter (fun x => f x = y)) with hemp | ⟨x₀, hx₀⟩
  · rw [hemp]; simp
  · have hP : 0 < pushMeasure f p y :=
      Finset.sum_pos' (fun x' _ => (hp x').le) ⟨x₀, hx₀, hp x₀⟩
    have hQ : 0 < pushMeasure f q y :=
      Finset.sum_pos' (fun x' _ => (hq x').le) ⟨x₀, hx₀, hq x₀⟩
    rw [condKlDiv_fibre_eq f hP]
    refine mul_nonneg hP.le ?_
    exact klDiv_nonneg (fun z => (fibreCond_pos hp hP z).le) (fun z => fibreCond_pos hq hQ z)
      (fibreCond_sum_one hP) (le_of_eq (fibreCond_sum_one hQ))

/-- **Zero parse defect forces equal conditional laws.**  If a front end loses
nothing, then inside every fibre the two laws are proportional. -/
theorem cond_eq_of_condKlDiv_eq_zero (f : X → Y) {p q : X → ℝ} (hp : ∀ x, 0 < p x)
    (hq : ∀ x, 0 < q x) (h0 : condKlDiv f p q = 0) (x : X) :
    p x / pushMeasure f p (f x) = q x / pushMeasure f q (f x) := by
  set y := f x with hy
  have hx₀ : x ∈ univ.filter (fun x' => f x' = y) := by simp [hy]
  have hP : 0 < pushMeasure f p y :=
    Finset.sum_pos' (fun x' _ => (hp x').le) ⟨x, hx₀, hp x⟩
  have hQ : 0 < pushMeasure f q y :=
    Finset.sum_pos' (fun x' _ => (hq x').le) ⟨x, hx₀, hq x⟩
  -- every fibre contributes zero
  have hzero : ∑ x ∈ univ.filter (fun x' => f x' = y),
      p x * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y)) = 0 := by
    by_contra hne
    have hpos : 0 < ∑ x ∈ univ.filter (fun x' => f x' = y),
        p x * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y)) :=
      lt_of_le_of_ne (condKlDiv_fibre_nonneg f hp hq y) (Ne.symm hne)
    have hsum : 0 < condKlDiv f p q := by
      unfold condKlDiv
      exact Finset.sum_pos' (fun y' _ => condKlDiv_fibre_nonneg f hp hq y')
        ⟨y, Finset.mem_univ y, hpos⟩
    rw [h0] at hsum
    exact lt_irrefl 0 hsum
  rw [condKlDiv_fibre_eq f hP] at hzero
  have hkl : klDiv (fibreCond f p y) (fibreCond f q y) = 0 := by
    rcases mul_eq_zero.mp hzero with h | h
    · exact absurd h (ne_of_gt hP)
    · exact h
  have heq : fibreCond f p y = fibreCond f q y := by
    by_contra hne
    have := klDiv_pos_of_ne (fun z => (fibreCond_pos hp hP z).le)
      (fun z => fibreCond_pos hq hQ z) (fibreCond_sum_one hP) (fibreCond_sum_one hQ) hne
    rw [hkl] at this
    exact lt_irrefl 0 this
  exact congrFun heq ⟨x, hy.symm⟩

/-- **Zero parse defect is the Fisher–Neyman factorization.**  If a front end
computing `f` discards nothing relative to the coding distribution `m`, then
every source of the class factors through `f`. -/
theorem factorizes_of_condKlDiv_eq_zero {Θ : Type*} (f : X → Y) (p : Θ → X → ℝ)
    {m : X → ℝ} (hp : ∀ θ x, 0 < p θ x) (hm : ∀ x, 0 < m x)
    (h0 : ∀ θ, condKlDiv f (p θ) m = 0) :
    ∃ g : Θ → Y → ℝ, ∀ θ x, p θ x = g θ (f x) * m x := by
  refine ⟨fun θ y => pushMeasure f (p θ) y / pushMeasure f m y, fun θ x => ?_⟩
  have hM : 0 < pushMeasure f m (f x) := by
    refine Finset.sum_pos' (fun x' _ => (hm x').le) ⟨x, ?_, hm x⟩
    simp
  have hP : 0 < pushMeasure f (p θ) (f x) := by
    refine Finset.sum_pos' (fun x' _ => (hp θ x').le) ⟨x, ?_, hp θ x⟩
    simp
  have hkey := cond_eq_of_condKlDiv_eq_zero f (hp θ) hm (h0 θ) x
  rw [div_eq_div_iff (ne_of_gt hP) (ne_of_gt hM)] at hkey
  field_simp
  linarith [hkey]


/-- **A front end loses no bits iff it computes a sufficient statistic.**  The
parse defect of `f` relative to the coding distribution `m` vanishes for every
source of the family exactly when the family admits the Fisher–Neyman
factorization through `f`. -/
theorem condKlDiv_eq_zero_iff_factorizes {Θ : Type*} [Fintype Θ] (f : X → Y)
    (p : Θ → X → ℝ) {m : X → ℝ} (hp : ∀ θ x, 0 < p θ x) (hm : ∀ x, 0 < m x) :
    (∀ θ, condKlDiv f (p θ) m = 0) ↔ ∃ g : Θ → Y → ℝ, ∀ θ x, p θ x = g θ (f x) * m x := by
  constructor
  · intro h0
    exact factorizes_of_condKlDiv_eq_zero f p hp hm h0
  · rintro ⟨g, hg⟩ θ
    have hpf : ∀ x, 0 < g θ (f x) * m x := fun x => by rw [← hg θ x]; exact hp θ x
    have hqf : ∀ x, 0 < (fun _ : Y => (1 : ℝ)) (f x) * m x := fun x => by
      simpa using hm x
    have h := SourceClass.condKlDiv_eq_zero_of_factorizes (Θ := Θ) (θ := θ) f
      (g := g) (h := m) (G := fun _ : Y => (1 : ℝ)) hpf hqf (fun x => (hm x).le)
    have hp' : (fun x => g θ (f x) * m x) = p θ := funext fun x => (hg θ x).symm
    have hq' : (fun x => (fun _ : Y => (1 : ℝ)) (f x) * m x) = m := funext fun x => one_mul (m x)
    rw [hp', hq'] at h
    exact h

end UniversalRedundancy