/-
Copyright (c) 2025. All rights reserved.

# Boolean Degree One Functions on the q-Grassmann Scheme J_q(n,2)

## Overview

The *Grassmann scheme* `J_q(n,2)` (the q-analogue of the Johnson scheme) has as
its vertices the 2-dimensional subspaces ("lines") of the n-dimensional vector
space `F_q^n`, equivalently the lines of the projective space `PG(n-1,q)`.  A
real function on the vertices is **Boolean degree one** when it takes values in
`{0,1}` and lies in the eigenspace `V_0 ⊕ V_1` of the scheme.  For the Grassmann
scheme this top-of-the-spectrum subspace is exactly the span of the constant
function together with the *point-pencil indicators* `1[p ≤ W]` (lines through a
fixed point `p`).  This identification turns the analytic notion of "degree one"
into a purely combinatorial one, which is the form we formalise here.

The driving research question (Filmus–Ihringer 2019, building on Bruen–Drudge
1999 and Gavrilyuk–Mogilnykh 2014) asks **which** Boolean degree one functions
exist.  The *trivial* ones are the constants, the point-pencils `1[p ≤ W]`, the
dual "hyperplane" families `1[W ≤ H]`, and their complements.  The conjecture /
theorem is that for `q ≥ 3` and `n ≥ 4` there are **no others** on `J_q(n,2)`.

This file builds a self-contained, abstract combinatorial model of `J_q(n,2)`
(a finite "linear space": points, lines, `q+1` points per line, two points on a
unique line) and proves, with zero `sorry`s:

* the trivial Boolean degree one functions really are Boolean degree one
  (`const_zero_BDO`, `const_one_BDO`, `pencil_BDO`, `compl_BDO`);
* there are **at least `|P| + 2`** Boolean degree one functions
  (`exists_many_BDO`), via an explicit injection `P ⊕ Bool ↪ {BDO functions}`;
* every *constant-weight* (symmetric) degree-one function is constant
  (`const_weight_is_constant`) — the abstract reason there is no non-trivial
  *symmetric* Boolean degree one function;
* the sum of two distinct point-pencils is degree one but **not** Boolean
  (`two_pencils_not_boolean`) — the basic obstruction to manufacturing new
  Boolean degree one functions out of the trivial ones.

A concrete instance (the Fano plane `PG(2,2) = J_2(3,2)`) is built in `Fano.lean`.

-- !-- Lab Notes -- !--
-- HYPOTHESIS H0 (modelling).  The analytic "degree ≤ 1" subspace of the
--   Grassmann scheme equals span{1} ⊕ span{ point-pencil indicators }.  This is
--   standard (the pencils span V_0 ⊕ V_1).  We TAKE this as the definition of
--   `IsDegLEOne`, which makes every statement below a faithful combinatorial
--   shadow of the scheme-theoretic one while remaining fully elementary.
-- INSIGHT.  With this definition `f` is degree ≤ 1 iff there are a constant `c`
--   and a point-weight `w : P → ℝ` with `f ℓ = c + ∑_{p ∈ ℓ} w p`.  All the
--   spectral content collapses to summing a weight over the `q+1` points of a
--   line; uniformity of the line size `q+1` is exactly the regularity of the
--   scheme and is what powers `const_weight_is_constant`.
-- !-- end Lab Notes -- !--
-/
import Mathlib

namespace Catalog.Applications.BooleanDegreeOne

open scoped BigOperators

variable {q : ℕ} {P L : Type*} [Fintype P] [DecidableEq P] [Fintype L]

/-- The point-pencil indicator of a point `p`: the line `ℓ` is sent to `1` if `p`
lies on `ℓ` and to `0` otherwise.  These are the generators of the degree-one
space coming from "stars" / pencils through a point. -/
def ind (pts : L → Finset P) (p : P) : L → ℝ :=
  fun ℓ => if p ∈ pts ℓ then 1 else 0

/-- `f` has **degree ≤ 1**: it is a constant plus a weighted sum of point-pencil
indicators, equivalently `f ℓ = c + ∑_{p ∈ ℓ} w p` for a constant `c` and a
point-weight `w`. -/
def IsDegLEOne (pts : L → Finset P) (f : L → ℝ) : Prop :=
  ∃ (c : ℝ) (w : P → ℝ), ∀ ℓ, f ℓ = c + ∑ p ∈ pts ℓ, w p

/-- `f` is **Boolean**: it takes only the values `0` and `1`. -/
def IsBoolean (f : L → ℝ) : Prop := ∀ ℓ, f ℓ = 0 ∨ f ℓ = 1

/-- A **Boolean degree one** function: Boolean and of degree ≤ 1. -/
def BooleanDegOne (pts : L → Finset P) (f : L → ℝ) : Prop :=
  IsBoolean f ∧ IsDegLEOne pts f

/-
Reformulation of `BooleanDegOne` purely in terms of the weight description.
-/
omit [Fintype P] [DecidableEq P] [Fintype L] in
theorem BooleanDegOne_iff (pts : L → Finset P) (f : L → ℝ) :
    BooleanDegOne pts f ↔
      (∀ ℓ, f ℓ = 0 ∨ f ℓ = 1) ∧ ∃ (c : ℝ) (w : P → ℝ), ∀ ℓ, f ℓ = c + ∑ p ∈ pts ℓ, w p := by
  rfl

/-! ### The trivial Boolean degree one functions are Boolean degree one. -/

/-
The constant `0` function is Boolean degree one.
-/
omit [Fintype P] [DecidableEq P] [Fintype L] in
theorem const_zero_BDO (pts : L → Finset P) : BooleanDegOne pts (fun _ => 0) := by
  constructor;
  · exact fun _ => Or.inl rfl;
  · exact ⟨ 0, 0, by simp +decide ⟩

/-
The constant `1` function is Boolean degree one.
-/
omit [Fintype P] [DecidableEq P] [Fintype L] in
theorem const_one_BDO (pts : L → Finset P) : BooleanDegOne pts (fun _ => 1) := by
  refine' ⟨ _, _ ⟩;
  · exact fun _ => Or.inr rfl;
  · exact ⟨ 1, 0, by simp +decide ⟩

/-
Every point-pencil indicator `1[p ≤ ℓ]` is Boolean degree one.
-/
omit [Fintype P] [Fintype L] in
theorem pencil_BDO (pts : L → Finset P) (p : P) : BooleanDegOne pts (ind pts p) := by
  refine' ⟨ _, _ ⟩;
  · exact fun _ => by unfold ind; split_ifs <;> norm_num;
  · use 0, fun q => if q = p then 1 else 0;
    simp +decide [ ind ]

/-
The Boolean degree one functions are closed under complementation `f ↦ 1 - f`.
-/
omit [Fintype P] [DecidableEq P] [Fintype L] in
theorem compl_BDO (pts : L → Finset P) {f : L → ℝ} (h : BooleanDegOne pts f) :
    BooleanDegOne pts (fun ℓ => 1 - f ℓ) := by
  refine' ⟨ fun ℓ => _, _ ⟩;
  · cases h.1 ℓ <;> simp +decide [ * ];
  · obtain ⟨ c, w, hw ⟩ := h.2;
    use 1 - c, fun x => -w x;
    simp +decide [ hw, Finset.sum_neg_distrib ] ; intros ; ring

/-! ### Constant-weight (symmetric) degree-one functions are constant. -/

/-
**No non-trivial symmetric degree-one functions.**  If a degree-one function
is described by a *constant* point-weight `a` (the symmetric/automorphism-invariant
case), then because every line carries the same number `q+1` of points the value
`c + (q+1)·a` is the same on every line, so the function is constant.  This is the
abstract reason the only symmetric Boolean degree one functions are the constants.
-/
omit [Fintype P] [DecidableEq P] [Fintype L] in
theorem const_weight_is_constant (pts : L → Finset P)
    (line_size : ∀ ℓ : L, (pts ℓ).card = q + 1) {f : L → ℝ} {c a : ℝ}
    (h : ∀ ℓ, f ℓ = c + ∑ _p ∈ pts ℓ, a) :
    ∀ ℓ ℓ' : L, f ℓ = f ℓ' := by
  aesop

/-! ### Counting: at least `|P| + 2` Boolean degree one functions exist. -/

/-
Under a separation hypothesis the point-pencils are pairwise distinct.
-/
omit [Fintype P] [Fintype L] in
theorem ind_injective (pts : L → Finset P)
    (separating : ∀ p p' : P, p ≠ p' → ∃ ℓ, p ∈ pts ℓ ∧ p' ∉ pts ℓ) :
    Function.Injective (ind pts) := by
  intro p p' h_eq
  by_contra h_neq
  obtain ⟨ℓ, hℓp, hℓp'⟩ := separating p p' h_neq
  have h_eval : (ind pts p) ℓ = 1 ∧ (ind pts p') ℓ = 0 := by
    exact ⟨ if_pos hℓp, if_neg hℓp' ⟩
  have h_contradiction : (ind pts p) ℓ = (ind pts p') ℓ := by
    exact congr_fun h_eq ℓ
  simp [h_eval] at h_contradiction

/-
**Existence of many Boolean degree one functions.**  When every point lies on
some line, every point is avoided by some line, and distinct points can be
separated by a line, the constants `0`, `1` together with the `|P|` point-pencils
are pairwise distinct Boolean degree one functions.  This is packaged as an
injection `P ⊕ Bool ↪ {functions}` all of whose images are Boolean degree one,
witnessing at least `|P| + 2` Boolean degree one functions.
-/
omit [Fintype P] [Fintype L] in
theorem exists_many_BDO [Nonempty L] (pts : L → Finset P)
    (line_through : ∀ p : P, ∃ ℓ, p ∈ pts ℓ)
    (line_avoiding : ∀ p : P, ∃ ℓ, p ∉ pts ℓ)
    (separating : ∀ p p' : P, p ≠ p' → ∃ ℓ, p ∈ pts ℓ ∧ p' ∉ pts ℓ) :
    ∃ g : P ⊕ Bool → (L → ℝ),
      Function.Injective g ∧ ∀ x, BooleanDegOne pts (g x) := by
  refine' ⟨ fun x => x.elim ( ind pts ) fun b => if b then ( fun _ => 1 ) else ( fun _ => 0 ), _, _ ⟩ <;> simp +decide [ Function.Injective ];
  · refine' ⟨ _, _, _, _ ⟩;
    · refine' fun p => ⟨ _, _, _ ⟩;
      · exact fun q h => Classical.not_not.1 fun hq => by obtain ⟨ ℓ, hℓ₁, hℓ₂ ⟩ := separating p q hq; have := congr_fun h ℓ; simp_all +decide [ ind ] ;
      · exact fun h => by obtain ⟨ ℓ, hℓ ⟩ := line_through p; have := congr_fun h ℓ; simp_all +decide [ ind ] ;
      · exact fun h => by obtain ⟨ ℓ, hℓ ⟩ := line_avoiding p; have := congr_fun h ℓ; simp +decide [ hℓ, ind ] at this;
    · simp +decide [ funext_iff, ind ];
      exact line_through;
    · intro p hp; obtain ⟨ ℓ, hℓ ⟩ := line_avoiding p; have := congr_fun hp ℓ; simp +decide [ hℓ, ind ] at this;
    · exact fun h => by have := congr_fun h ( Classical.arbitrary L ) ; norm_num at this;
  · exact ⟨ fun p => pencil_BDO pts p, const_zero_BDO pts, const_one_BDO pts ⟩

/-! ### Obstruction: the sum of two distinct pencils is not Boolean. -/

/-
**The basic obstruction.**  For two distinct points `p ≠ p'`, the degree-one
function `1[p ≤ ℓ] + 1[p' ≤ ℓ]` takes the value `2` on the unique line through
both points, hence is *not* Boolean.  This is the elementary reason one cannot
combine point-pencils additively to obtain new Boolean degree one functions, and
is the seed of the rigidity behind the `q ≥ 3` non-existence phenomenon.
-/
omit [Fintype P] [Fintype L] in
theorem two_pencils_not_boolean (pts : L → Finset P) (p p' : P) (hpp : p ≠ p')
    (two_points : ∀ a b : P, a ≠ b → ∃! ℓ, a ∈ pts ℓ ∧ b ∈ pts ℓ) :
    ¬ IsBoolean (fun ℓ => ind pts p ℓ + ind pts p' ℓ) := by
  obtain ⟨ ℓ, hℓ ⟩ := two_points p p' hpp;
  intro h; have := h ℓ; simp_all +decide [ ind ] ;

end Catalog.Applications.BooleanDegreeOne