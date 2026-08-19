/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality XI: the exact price of a parse

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

`capacity_pushforward_le` says a coarse-graining `f` never costs the universal
coder anything, and `capacity_pushforward_eq_of_factorizes` says a *sufficient*
`f` costs nothing.  What does a non-sufficient one cost?  Exactly the divergence
that lives **inside the fibres** of `f`.

`klDiv_eq_add_condKlDiv` is a chain rule: for strictly positive `p, q`

  `D(p‖q) = D(f_*p ‖ f_*q) + D(p‖q | f)`,

where the conditional term `condKlDiv` compares the *within-fibre* conditional
laws.  It is nonnegative (`condKlDiv_nonneg`, from the log-sum inequality), which
re-proves data processing as a corollary, and it is zero exactly when the parse
keeps everything the coder needs.  Cashing the identity in at the capacity level
gives the two-sided estimate

  `C(f_*S) ≤ C(S) ≤ C(f_*S) + (average within-fibre divergence)`
  (`capacity_pushforward_le`, `capacity_le_capacity_pushforward_add`),

so the price of a parse — the bits a front end throws away — is an explicit,
computable quantity rather than an inequality.

## Main results

* `condKlDiv` — the within-fibre (conditional) divergence of a parse
* `klDiv_eq_add_condKlDiv` — exact chain rule for a coarse-graining
* `condKlDiv_nonneg` — the parse defect is nonnegative
* `condKlDiv_eq_zero_of_factorizes` — a sufficient parse has zero defect
* `capacity_le_capacity_pushforward_add` — the price of a parse, at the capacity
  level

## Application keywords

universal compression, minimax redundancy, capacity, data processing, chain
rule, conditional divergence, parsing, sufficient statistic
-/

import Bridges.UniversalRedundancyCapacitySufficiency

open Finset Real

namespace UniversalRedundancy

variable {X : Type*} [Fintype X] {Y : Type*} [Fintype Y] [DecidableEq Y]
variable {Θ : Type*} [Fintype Θ]

/-- The **within-fibre divergence** of the parse `f`: the divergence between the
conditional laws of `p` and `q` inside the fibres of `f`, averaged over the
fibres.  This is the information a front end computing `f` discards. -/
noncomputable def condKlDiv (f : X → Y) (p q : X → ℝ) : ℝ :=
  ∑ y, ∑ x ∈ univ.filter (fun x => f x = y),
    p x * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y))

omit [Fintype Y] in
private lemma pushMeasure_pos_of_mem {f : X → Y} {p : X → ℝ} (hp : ∀ x, 0 < p x)
    {y : Y} {x : X} (hx : x ∈ univ.filter (fun x => f x = y)) :
    0 < pushMeasure f p y := by
  refine Finset.sum_pos' (fun x' _ => (hp x').le) ⟨x, hx, hp x⟩

/-- **The chain rule for a coarse-graining.**  The divergence splits exactly into
the divergence of the parsed data and the divergence discarded inside the
fibres. -/
theorem klDiv_eq_add_condKlDiv (f : X → Y) {p q : X → ℝ} (hp : ∀ x, 0 < p x)
    (hq : ∀ x, 0 < q x) :
    klDiv p q = klDiv (pushMeasure f p) (pushMeasure f q) + condKlDiv f p q := by
  have hsplit : ∀ y : Y,
      ∑ x ∈ univ.filter (fun x => f x = y), p x * logb 2 (p x / q x)
        = pushMeasure f p y * logb 2 (pushMeasure f p y / pushMeasure f q y)
          + ∑ x ∈ univ.filter (fun x => f x = y),
              p x * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y)) := by
    intro y
    rcases Finset.eq_empty_or_nonempty (univ.filter (fun x => f x = y)) with hemp | ⟨x₀, hx₀⟩
    · have hP : pushMeasure f p y = 0 := by unfold pushMeasure; rw [hemp]; simp
      have hQ : pushMeasure f q y = 0 := by unfold pushMeasure; rw [hemp]; simp
      rw [hemp, hP, hQ]
      simp
    · have hP : 0 < pushMeasure f p y := pushMeasure_pos_of_mem hp hx₀
      have hQ : 0 < pushMeasure f q y := pushMeasure_pos_of_mem hq hx₀
      have hterm : ∀ x ∈ univ.filter (fun x => f x = y),
          p x * logb 2 (p x / q x)
            = p x * logb 2 (pushMeasure f p y / pushMeasure f q y)
              + p x * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y)) := by
        intro x _
        have h1 : (0 : ℝ) < pushMeasure f p y / pushMeasure f q y := div_pos hP hQ
        have h2 : (0 : ℝ) < (p x / pushMeasure f p y) / (q x / pushMeasure f q y) :=
          div_pos (div_pos (hp x) hP) (div_pos (hq x) hQ)
        have hmul : (pushMeasure f p y / pushMeasure f q y)
            * ((p x / pushMeasure f p y) / (q x / pushMeasure f q y)) = p x / q x := by
          field_simp
        rw [← mul_add, ← Real.logb_mul (ne_of_gt h1) (ne_of_gt h2), hmul]
      rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.sum_mul]
      rfl
  unfold klDiv condKlDiv
  calc ∑ x, p x * logb 2 (p x / q x)
      = ∑ y, ∑ x ∈ univ.filter (fun x => f x = y), p x * logb 2 (p x / q x) :=
        (Finset.sum_fiberwise _ _ _).symm
    _ = ∑ y, (pushMeasure f p y * logb 2 (pushMeasure f p y / pushMeasure f q y)
          + ∑ x ∈ univ.filter (fun x => f x = y),
              p x * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y))) :=
        Finset.sum_congr rfl fun y _ => hsplit y
    _ = _ := Finset.sum_add_distrib

/-- **The parse defect is nonnegative**: a front end can only lose information. -/
theorem condKlDiv_nonneg (f : X → Y) {p q : X → ℝ} (hp : ∀ x, 0 < p x)
    (hq : ∀ x, 0 < q x) : 0 ≤ condKlDiv f p q := by
  unfold condKlDiv
  refine Finset.sum_nonneg fun y _ => ?_
  rcases Finset.eq_empty_or_nonempty (univ.filter (fun x => f x = y)) with hemp | ⟨x₀, hx₀⟩
  · rw [hemp]; simp
  · have hP : 0 < pushMeasure f p y := pushMeasure_pos_of_mem hp hx₀
    have hQ : 0 < pushMeasure f q y := pushMeasure_pos_of_mem hq hx₀
    -- the fibrewise conditional laws are probability vectors
    have hsumP : ∑ x ∈ univ.filter (fun x => f x = y), p x / pushMeasure f p y = 1 := by
      rw [← Finset.sum_div]
      exact div_self (ne_of_gt hP)
    have hsumQ : ∑ x ∈ univ.filter (fun x => f x = y), q x / pushMeasure f q y = 1 := by
      rw [← Finset.sum_div]
      exact div_self (ne_of_gt hQ)
    have hlog := logb_sum_le (univ.filter (fun x => f x = y))
      (fun x => p x / pushMeasure f p y) (fun x => q x / pushMeasure f q y)
      (fun x _ => (div_pos (hp x) hP).le) (fun x _ => div_pos (hq x) hQ)
    rw [hsumP, hsumQ] at hlog
    simp only [div_one, Real.logb_one, one_mul] at hlog
    have hscale : ∑ x ∈ univ.filter (fun x => f x = y),
        p x * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y))
          = pushMeasure f p y * ∑ x ∈ univ.filter (fun x => f x = y),
              (p x / pushMeasure f p y)
                * logb 2 ((p x / pushMeasure f p y) / (q x / pushMeasure f q y)) := by
      rw [Finset.mul_sum]
      refine Finset.sum_congr rfl fun x _ => ?_
      field_simp
    rw [hscale]
    exact mul_nonneg hP.le hlog

/-- Data processing, re-proved from the chain rule. -/
theorem klDiv_pushMeasure_le' (f : X → Y) {p q : X → ℝ} (hp : ∀ x, 0 < p x)
    (hq : ∀ x, 0 < q x) :
    klDiv (pushMeasure f p) (pushMeasure f q) ≤ klDiv p q := by
  rw [klDiv_eq_add_condKlDiv f hp hq]
  linarith [condKlDiv_nonneg f hp hq]

namespace SourceClass

variable (S : SourceClass X Θ)

omit [Fintype Θ] in
/-- **A sufficient parse has zero defect.**  Under the Fisher–Neyman
factorization nothing at all is discarded inside the fibres. -/
theorem condKlDiv_eq_zero_of_factorizes (f : X → Y) {g : Θ → Y → ℝ} {h : X → ℝ}
    {θ : Θ} {G : Y → ℝ} (hp : ∀ x, 0 < g θ (f x) * h x) (hq : ∀ x, 0 < G (f x) * h x)
    (hh : ∀ x, 0 ≤ h x) :
    condKlDiv f (fun x => g θ (f x) * h x) (fun x => G (f x) * h x) = 0 := by
  have hchain := klDiv_eq_add_condKlDiv f hp hq
  have hsuff := klDiv_pushMeasure_eq_of_factorizes f (g := g) (h := h) hh (θ := θ) (G := G)
  linarith [hchain, hsuff]

/-- **The price of a parse.**  The capacity lost by a front end computing `f` is
at most the average within-fibre divergence at a capacity-achieving prior; with
`capacity_pushforward_le` this brackets the price of universality of the parsed
class exactly. -/
theorem capacity_le_capacity_pushforward_add [Nonempty Θ] (f : X → Y)
    (hpos : ∀ θ x, 0 < S.prob θ x) :
    ∃ w ∈ stdSimplex ℝ Θ, S.capacity ≤ (S.pushforward f).capacity
      + ∑ θ, w θ * condKlDiv f (S.prob θ) (S.mix w) := by
  obtain ⟨w, hw, hcap, -⟩ := S.exists_capacity_prior hpos
  refine ⟨w, hw, ?_⟩
  have hmpos : ∀ x, 0 < S.mix w x := S.mix_pos_of_mem_stdSimplex hpos hw
  have hsplit : S.mutualInfo w
      = (S.pushforward f).mutualInfo w + ∑ θ, w θ * condKlDiv f (S.prob θ) (S.mix w) := by
    unfold mutualInfo
    rw [← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun θ _ => ?_
    rw [S.mix_pushforward f w, S.pushforward_prob f θ, ← mul_add]
    exact congrArg (fun t => w θ * t) (klDiv_eq_add_condKlDiv f (hpos θ) hmpos)
  have hle : (S.pushforward f).mutualInfo w ≤ (S.pushforward f).capacity := by
    have hbdd : ((S.pushforward f).mutualInfo w) ∈
        ((fun w => (S.pushforward f).mutualInfo w) '' stdSimplex ℝ Θ) := ⟨w, hw, rfl⟩
    refine le_csSup ⟨S.capacity, ?_⟩ hbdd
    rintro _ ⟨w', hw', rfl⟩
    exact le_trans (S.mutualInfo_pushforward_le f hw'.1 hpos hw'.2)
      (S.mutualInfo_le_capacity hpos hw')
  rw [← hcap, hsplit]
  linarith

end SourceClass

end UniversalRedundancy