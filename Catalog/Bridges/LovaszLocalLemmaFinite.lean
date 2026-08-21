/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge: the Lovász Local Lemma as finite counting/summation

The Lovász Local Lemma (LLL) is the second pillar of the probabilistic method.  Its usual
statement lives in measure theory; here it is developed in a **finite weighted probability
space** — a finite type `Ω` with nonnegative weights summing to `1` — so that every probability
is a finite sum and every step is elementary algebra.  No measure theory, no `MeasureTheory`
imports, no limits.

## Main results

* `FinProbSpace` : finite weighted probability space, `prob` = a `Finset` sum.
* `avoid A S` : the event "none of the bad events `A j`, `j ∈ S`, occurs".
* `prob_avoid_lower` : the *denominator* estimate
  `∏_{j ∈ S₁} (1 - x j) · P(avoid S₂) ≤ P(avoid (S₁ ∪ S₂))`, relative to an induction hypothesis.
* `prob_inter_avoid_le` : the heart of the Erdős–Lovász induction,
  `P(A i ∩ avoid S) ≤ x i · P(avoid S)` for `i ∉ S`, proved by induction on `#S`.
* `lovasz_local_lemma` : the **general (asymmetric, lopsided) LLL**: if
  `P(A i) ≤ x i ∏_{j ∈ Γ i}(1 - x j)` and `A i` satisfies the one-sided independence bound
  `P(A i ∩ ⋂_{j ∈ S}(A j)ᶜ) ≤ P(A i)·P(⋂_{j ∈ S}(A j)ᶜ)` for every `S` disjoint from `Γ i`, then
  `0 < P(⋂ i, (A i)ᶜ)`; in fact `∏ i (1 - x i) ≤ P(⋂ i, (A i)ᶜ)`.  Only this inequality (not
  genuine independence) is used anywhere in the induction, so the *lopsided* LLL comes for free.
* `exists_avoiding_all` : the constructive payoff — an explicit point `ω` of the sample space
  avoiding **all** bad events (existence of a "satisfying assignment").
* `lovasz_local_lemma_symmetric` : the classical symmetric form: `P(A i) ≤ p`, `#(Γ i) ≤ d` and
  `e · p · (d+1) ≤ 1` imply a satisfying assignment exists.  The Euler constant enters through
  `(1 + 1/d)^d ≤ e`, proved from `Real.add_one_le_exp`.

## Catalog connections
* `Bridges/ErdosProbabilisticRamsey.lean`, `Bridges/TuranExplicitCount.lean` : the other two
  pillars of the probabilistic method, likewise reduced to finite algebra.
-/
import Mathlib

open Finset

namespace LovaszLocalLemmaFinite

/-- A finite weighted probability space: nonnegative weights on a finite type summing to `1`. -/
structure FinProbSpace (Ω : Type*) [Fintype Ω] where
  /-- The weight (point mass) of each sample point. -/
  weight : Ω → ℝ
  /-- Weights are nonnegative. -/
  weight_nonneg : ∀ ω, 0 ≤ weight ω
  /-- Weights sum to one. -/
  weight_total : ∑ ω, weight ω = 1

namespace FinProbSpace

variable {Ω : Type*} [Fintype Ω] (μ : FinProbSpace Ω)

/-- The probability of a finite event. -/
def prob (E : Finset Ω) : ℝ := ∑ ω ∈ E, μ.weight ω

lemma prob_nonneg (E : Finset Ω) : 0 ≤ μ.prob E :=
  Finset.sum_nonneg fun ω _ => μ.weight_nonneg ω

lemma prob_mono {E F : Finset Ω} (h : E ⊆ F) : μ.prob E ≤ μ.prob F :=
  Finset.sum_le_sum_of_subset_of_nonneg h fun ω _ _ => μ.weight_nonneg ω

@[simp] lemma prob_univ : μ.prob (univ : Finset Ω) = 1 := μ.weight_total

@[simp] lemma prob_empty : μ.prob (∅ : Finset Ω) = 0 := by simp [prob]

lemma prob_eq_zero_of_empty {E : Finset Ω} (h : E = ∅) : μ.prob E = 0 := by simp [h]

/-- Probability of a set difference. -/
lemma prob_sdiff [DecidableEq Ω] (E F : Finset Ω) :
    μ.prob (E \ F) = μ.prob E - μ.prob (E ∩ F) := by
  rw [← Finset.sdiff_inter_self_left E F]
  exact Finset.sum_sdiff_eq_sub Finset.inter_subset_left

end FinProbSpace

open FinProbSpace

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω] {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- `avoid A S` is the event that none of the bad events `A j` with `j ∈ S` occurs. -/
def avoid (A : ι → Finset Ω) (S : Finset ι) : Finset Ω :=
  univ.filter (fun ω => ∀ j ∈ S, ω ∉ A j)

@[simp] lemma mem_avoid {A : ι → Finset Ω} {S : Finset ι} {ω : Ω} :
    ω ∈ avoid A S ↔ ∀ j ∈ S, ω ∉ A j := by simp [avoid]

@[simp] lemma avoid_empty (A : ι → Finset Ω) : avoid A (∅ : Finset ι) = univ := by
  ext ω; simp

lemma avoid_mono {A : ι → Finset Ω} {S T : Finset ι} (h : S ⊆ T) : avoid A T ⊆ avoid A S := by
  intro ω hω
  rw [mem_avoid] at hω ⊢
  exact fun j hj => hω j (h hj)

lemma avoid_insert (A : ι → Finset Ω) (j : ι) (S : Finset ι) :
    avoid A (insert j S) = avoid A S \ A j := by
  ext ω
  simp only [mem_avoid, Finset.mem_insert, Finset.mem_sdiff]
  constructor
  · intro h
    exact ⟨fun i hi => h i (Or.inr hi), h j (Or.inl rfl)⟩
  · rintro ⟨h1, h2⟩ i (rfl | hi)
    · exact h2
    · exact h1 i hi

/-! ## The Erdős–Lovász induction -/

variable (μ : FinProbSpace Ω) (A : ι → Finset Ω) (x : ι → ℝ)

/-- **Denominator estimate.**  Relative to an induction hypothesis bounding
`P(A i ∩ avoid T)` for all `T` of size at most `m`, peeling the elements of `S₁` one at a time
gives `∏_{j ∈ S₁}(1 - x j) · P(avoid S₂) ≤ P(avoid (S₁ ∪ S₂))`. -/
lemma prob_avoid_lower (hx1 : ∀ i, x i < 1) {m : ℕ}
    (hIH : ∀ T : Finset ι, #T ≤ m → ∀ i, i ∉ T →
      μ.prob (A i ∩ avoid A T) ≤ x i * μ.prob (avoid A T)) :
    ∀ S₁ S₂ : Finset ι, Disjoint S₁ S₂ → #S₁ + #S₂ ≤ m + 1 →
      (∏ j ∈ S₁, (1 - x j)) * μ.prob (avoid A S₂) ≤ μ.prob (avoid A (S₁ ∪ S₂)) := by
  intro S₁
  induction S₁ using Finset.induction_on with
  | empty => intro S₂ _ _; simp
  | insert j S₁' hj ih =>
    intro S₂ hdisj hcard
    have hjS₂ : j ∉ S₂ := by
      intro hmem
      exact (Finset.disjoint_left.1 hdisj (Finset.mem_insert_self j S₁')) hmem
    have hdisj' : Disjoint S₁' S₂ :=
      Finset.disjoint_of_subset_left (Finset.subset_insert j S₁') hdisj
    have hcard' : #S₁' + #S₂ ≤ m + 1 := by
      rw [Finset.card_insert_of_notMem hj] at hcard; omega
    have hTcard : #(S₁' ∪ S₂) ≤ m := by
      have h1 : #(S₁' ∪ S₂) ≤ #S₁' + #S₂ := Finset.card_union_le _ _
      rw [Finset.card_insert_of_notMem hj] at hcard
      omega
    have hjT : j ∉ S₁' ∪ S₂ := by
      simp only [Finset.mem_union]
      rintro (h | h)
      · exact hj h
      · exact hjS₂ h
    -- peel off `j`
    have hset : avoid A (insert j S₁' ∪ S₂) = avoid A (S₁' ∪ S₂) \ A j := by
      rw [Finset.insert_union, avoid_insert]
    have hpeel : (1 - x j) * μ.prob (avoid A (S₁' ∪ S₂)) ≤ μ.prob (avoid A (insert j S₁' ∪ S₂)) := by
      rw [hset, μ.prob_sdiff]
      have hbound := hIH (S₁' ∪ S₂) hTcard j hjT
      have hcomm : avoid A (S₁' ∪ S₂) ∩ A j = A j ∩ avoid A (S₁' ∪ S₂) := Finset.inter_comm _ _
      rw [hcomm]
      nlinarith [hbound]
    have hrec := ih S₂ hdisj' hcard'
    have hfac : (0 : ℝ) ≤ 1 - x j := by linarith [hx1 j]
    calc (∏ i ∈ insert j S₁', (1 - x i)) * μ.prob (avoid A S₂)
        = (1 - x j) * ((∏ i ∈ S₁', (1 - x i)) * μ.prob (avoid A S₂)) := by
          rw [Finset.prod_insert hj]; ring
      _ ≤ (1 - x j) * μ.prob (avoid A (S₁' ∪ S₂)) := by
          exact mul_le_mul_of_nonneg_left hrec hfac
      _ ≤ μ.prob (avoid A (insert j S₁' ∪ S₂)) := hpeel

/-- **The heart of the LLL.**  Under the (lopsided) independence hypothesis and the weight condition
`P(A i) ≤ x i ∏_{j ∈ Γ i}(1 - x j)`, one has `P(A i ∩ avoid S) ≤ x i · P(avoid S)` for `i ∉ S`.
Proved by induction on `#S`, using `prob_avoid_lower` for the conditional denominator. -/
theorem prob_inter_avoid_le (Γ : ι → Finset ι)
    (hindep : ∀ (i : ι) (S : Finset ι), i ∉ S → Disjoint S (Γ i) →
      μ.prob (A i ∩ avoid A S) ≤ μ.prob (A i) * μ.prob (avoid A S))
    (hx0 : ∀ i, 0 ≤ x i) (hx1 : ∀ i, x i < 1)
    (hA : ∀ i, μ.prob (A i) ≤ x i * ∏ j ∈ Γ i, (1 - x j)) :
    ∀ (m : ℕ) (S : Finset ι), #S ≤ m → ∀ i, i ∉ S →
      μ.prob (A i ∩ avoid A S) ≤ x i * μ.prob (avoid A S) := by
  have hfac : ∀ j, (0 : ℝ) ≤ 1 - x j := fun j => by linarith [hx1 j]
  intro m
  induction m with
  | zero =>
    intro S hS i _
    have hS0 : S = ∅ := Finset.card_eq_zero.1 (Nat.le_zero.1 hS)
    subst hS0
    have hprod : (∏ j ∈ Γ i, (1 - x j)) ≤ 1 :=
      Finset.prod_le_one (fun j _ => hfac j) (fun j _ => by linarith [hx0 j])
    have h1 : μ.prob (A i ∩ avoid A (∅ : Finset ι)) ≤ μ.prob (A i) := by
      exact μ.prob_mono Finset.inter_subset_left
    calc μ.prob (A i ∩ avoid A (∅ : Finset ι)) ≤ μ.prob (A i) := h1
      _ ≤ x i * ∏ j ∈ Γ i, (1 - x j) := hA i
      _ ≤ x i * 1 := mul_le_mul_of_nonneg_left hprod (hx0 i)
      _ = x i * μ.prob (avoid A (∅ : Finset ι)) := by simp
  | succ m ih =>
    intro S hS i hi
    classical
    set S₁ : Finset ι := S ∩ Γ i with hS₁
    set S₂ : Finset ι := S \ Γ i with hS₂
    have hunion : S₁ ∪ S₂ = S := by
      ext a
      simp only [hS₁, hS₂, Finset.mem_union, Finset.mem_inter, Finset.mem_sdiff]
      tauto
    have hdisj : Disjoint S₁ S₂ := by
      rw [Finset.disjoint_left]
      intro a ha ha'
      simp only [hS₁, Finset.mem_inter] at ha
      simp only [hS₂, Finset.mem_sdiff] at ha'
      exact ha'.2 ha.2
    have hcard : #S₁ + #S₂ ≤ m + 1 := by
      have : #S₁ + #S₂ = #S := by
        rw [← Finset.card_union_of_disjoint hdisj, hunion]
      omega
    have hi2 : i ∉ S₂ := fun h => hi (Finset.mem_sdiff.1 h).1
    have hdisj2 : Disjoint S₂ (Γ i) := Finset.sdiff_disjoint
    have hS₂sub : S₂ ⊆ S := Finset.sdiff_subset
    have step1 : μ.prob (A i ∩ avoid A S) ≤ μ.prob (A i ∩ avoid A S₂) :=
      μ.prob_mono (Finset.inter_subset_inter_left (avoid_mono hS₂sub))
    have step2 : μ.prob (A i ∩ avoid A S₂) ≤ μ.prob (A i) * μ.prob (avoid A S₂) :=
      hindep i S₂ hi2 hdisj2
    have hsub1 : S₁ ⊆ Γ i := Finset.inter_subset_right
    have step3 : μ.prob (A i) ≤ x i * ∏ j ∈ S₁, (1 - x j) := by
      have hle : (∏ j ∈ Γ i, (1 - x j)) ≤ ∏ j ∈ S₁, (1 - x j) := by
        have h1 : (∏ j ∈ Γ i \ S₁, (1 - x j)) ≤ 1 :=
          Finset.prod_le_one (fun j _ => hfac j) (fun j _ => by linarith [hx0 j])
        have h2 : (0 : ℝ) ≤ ∏ j ∈ S₁, (1 - x j) :=
          Finset.prod_nonneg (fun j _ => hfac j)
        calc (∏ j ∈ Γ i, (1 - x j))
            = (∏ j ∈ Γ i \ S₁, (1 - x j)) * ∏ j ∈ S₁, (1 - x j) :=
              (Finset.prod_sdiff hsub1).symm
          _ ≤ 1 * ∏ j ∈ S₁, (1 - x j) := mul_le_mul_of_nonneg_right h1 h2
          _ = ∏ j ∈ S₁, (1 - x j) := one_mul _
      calc μ.prob (A i) ≤ x i * ∏ j ∈ Γ i, (1 - x j) := hA i
        _ ≤ x i * ∏ j ∈ S₁, (1 - x j) := mul_le_mul_of_nonneg_left hle (hx0 i)
    have step4 : (∏ j ∈ S₁, (1 - x j)) * μ.prob (avoid A S₂) ≤ μ.prob (avoid A S) := by
      have := prob_avoid_lower μ A x hx1 (m := m) ih S₁ S₂ hdisj hcard
      rwa [hunion] at this
    have hprobnn : 0 ≤ μ.prob (avoid A S₂) := μ.prob_nonneg _
    calc μ.prob (A i ∩ avoid A S) ≤ μ.prob (A i) * μ.prob (avoid A S₂) := step1.trans step2
      _ ≤ (x i * ∏ j ∈ S₁, (1 - x j)) * μ.prob (avoid A S₂) :=
          mul_le_mul_of_nonneg_right step3 hprobnn
      _ = x i * ((∏ j ∈ S₁, (1 - x j)) * μ.prob (avoid A S₂)) := by ring
      _ ≤ x i * μ.prob (avoid A S) := mul_le_mul_of_nonneg_left step4 (hx0 i)

/-! ## The general Lovász Local Lemma -/

/-- **General (asymmetric, lopsided) Lovász Local Lemma.**  If each bad event `A i` satisfies the
one-sided independence bound `P(A i ∩ ⋂_{j ∈ S} (A j)ᶜ) ≤ P(A i)·P(⋂_{j ∈ S} (A j)ᶜ)` for every
family `S` of indices outside its dependency set `Γ i` (in particular if `A i` is genuinely
independent of those events), and
`P(A i) ≤ x i ∏_{j ∈ Γ i}(1 - x j)` with `0 ≤ x i < 1`, then the probability that no bad event
occurs is at least `∏ i (1 - x i) > 0`. -/
theorem lovasz_local_lemma (Γ : ι → Finset ι)
    (hindep : ∀ (i : ι) (S : Finset ι), i ∉ S → Disjoint S (Γ i) →
      μ.prob (A i ∩ avoid A S) ≤ μ.prob (A i) * μ.prob (avoid A S))
    (hx0 : ∀ i, 0 ≤ x i) (hx1 : ∀ i, x i < 1)
    (hA : ∀ i, μ.prob (A i) ≤ x i * ∏ j ∈ Γ i, (1 - x j)) :
    (∏ i, (1 - x i)) ≤ μ.prob (avoid A (univ : Finset ι)) ∧
      0 < μ.prob (avoid A (univ : Finset ι)) := by
  classical
  have hmain := prob_inter_avoid_le μ A x Γ hindep hx0 hx1 hA
  have hkey : (∏ j ∈ (univ : Finset ι), (1 - x j)) * μ.prob (avoid A (∅ : Finset ι)) ≤
      μ.prob (avoid A ((univ : Finset ι) ∪ (∅ : Finset ι))) := by
    refine prob_avoid_lower μ A x hx1 (m := Fintype.card ι)
      (fun T hT i hi => hmain (Fintype.card ι) T hT i hi) univ ∅ (by simp) ?_
    simp [Finset.card_univ]
  simp only [Finset.union_empty, avoid_empty, prob_univ, mul_one] at hkey
  refine ⟨hkey, lt_of_lt_of_le ?_ hkey⟩
  exact Finset.prod_pos (fun i _ => by linarith [hx1 i])

/-- **The constructive payoff.**  Under the hypotheses of the LLL there is an explicit sample
point avoiding every bad event. -/
theorem exists_avoiding_all (Γ : ι → Finset ι)
    (hindep : ∀ (i : ι) (S : Finset ι), i ∉ S → Disjoint S (Γ i) →
      μ.prob (A i ∩ avoid A S) ≤ μ.prob (A i) * μ.prob (avoid A S))
    (hx0 : ∀ i, 0 ≤ x i) (hx1 : ∀ i, x i < 1)
    (hA : ∀ i, μ.prob (A i) ≤ x i * ∏ j ∈ Γ i, (1 - x j)) :
    ∃ ω : Ω, ∀ i, ω ∉ A i := by
  obtain ⟨-, hpos⟩ := lovasz_local_lemma μ A x Γ hindep hx0 hx1 hA
  have hne : avoid A (univ : Finset ι) ≠ ∅ := by
    intro h
    rw [μ.prob_eq_zero_of_empty h] at hpos
    exact lt_irrefl 0 hpos
  obtain ⟨ω, hω⟩ := Finset.nonempty_iff_ne_empty.2 hne
  exact ⟨ω, fun i => (mem_avoid.1 hω) i (Finset.mem_univ i)⟩

/-! ## Erdős' existence proof is an algorithm: exhaustive search always succeeds -/

/-- Exhaustive search of the (finite) sample space for a point avoiding all bad events. -/
noncomputable def searchAvoiding (A : ι → Finset Ω) : Option Ω :=
  (avoid A (univ : Finset ι)).toList.head?

/-- The search is sound: whatever it returns really avoids every bad event. -/
lemma searchAvoiding_sound {A : ι → Finset Ω} {ω : Ω} (h : searchAvoiding A = some ω) :
    ∀ i, ω ∉ A i := by
  have hmem : ω ∈ (avoid A (univ : Finset ι)).toList := List.mem_of_mem_head? h
  rw [Finset.mem_toList] at hmem
  exact fun i => (mem_avoid.1 hmem) i (Finset.mem_univ i)

/-- The search is complete under the LLL hypotheses: it never fails.  This is the sense in which
the probabilistic existence proof "is an algorithm in disguise" — the LLL certifies that a finite
deterministic search terminates successfully. -/
theorem searchAvoiding_isSome (Γ : ι → Finset ι)
    (hindep : ∀ (i : ι) (S : Finset ι), i ∉ S → Disjoint S (Γ i) →
      μ.prob (A i ∩ avoid A S) ≤ μ.prob (A i) * μ.prob (avoid A S))
    (hx0 : ∀ i, 0 ≤ x i) (hx1 : ∀ i, x i < 1)
    (hA : ∀ i, μ.prob (A i) ≤ x i * ∏ j ∈ Γ i, (1 - x j)) :
    (searchAvoiding A).isSome := by
  obtain ⟨ω, hω⟩ := exists_avoiding_all μ A x Γ hindep hx0 hx1 hA
  have hmem : ω ∈ avoid A (univ : Finset ι) := mem_avoid.2 (fun i _ => hω i)
  have hlist : ω ∈ (avoid A (univ : Finset ι)).toList := Finset.mem_toList.2 hmem
  unfold searchAvoiding
  cases hl : (avoid A (univ : Finset ι)).toList with
  | nil => rw [hl] at hlist; simp at hlist
  | cons a t => simp

/-! ## The symmetric form, with the Euler constant -/

/-- `(1 + 1/d)^d ≤ e` for every positive natural `d`: the inequality through which the Euler
constant enters the symmetric LLL. -/
lemma one_add_inv_pow_le_exp_one (d : ℕ) (hd : 0 < d) :
    (1 + 1 / (d : ℝ)) ^ d ≤ Real.exp 1 := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have h1 : (1 : ℝ) + 1 / d ≤ Real.exp (1 / d) := by
    have := Real.add_one_le_exp (1 / (d : ℝ))
    linarith
  have h2 : ((1 : ℝ) + 1 / d) ^ d ≤ (Real.exp (1 / d)) ^ d :=
    pow_le_pow_left₀ (by positivity) h1 d
  have h3 : (Real.exp (1 / (d : ℝ))) ^ d = Real.exp 1 := by
    rw [← Real.exp_nat_mul]
    congr 1
    field_simp
  linarith [h2, h3.le, h3.ge]

/-- The symmetric weight condition.  With `D = max d 1`, the uniform weight `1/(D+1)` satisfies
`p ≤ (1/(D+1)) · (D/(D+1))^d` whenever `e·p·(d+1) ≤ 1`.  (Taking `D = max d 1` rather than `d`
handles the degenerate case `d = 0`, where the weight `1/(d+1) = 1` is not admissible.) -/
lemma symmetric_weight_bound {p : ℝ} {d : ℕ} (hp : 0 ≤ p)
    (hepd : Real.exp 1 * p * (d + 1) ≤ 1) :
    p ≤ (1 / (((max d 1 : ℕ) : ℝ) + 1)) * ((((max d 1 : ℕ)) : ℝ) / (((max d 1 : ℕ) : ℝ) + 1)) ^ d := by
  have hepos : (0 : ℝ) < Real.exp 1 := Real.exp_pos 1
  have he2 : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
  rcases Nat.eq_zero_or_pos d with hd | hd
  · subst hd
    norm_num at hepd ⊢
    nlinarith [hepd, hp, he2]
  · have hmax : max d 1 = d := max_eq_left hd
    rw [hmax]
    have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
    have hd1 : (0 : ℝ) < (d : ℝ) + 1 := by positivity
    have hbase : ((d : ℝ) / ((d : ℝ) + 1)) = (1 + 1 / (d : ℝ))⁻¹ := by
      field_simp
    have hkey : (Real.exp 1)⁻¹ ≤ ((d : ℝ) / ((d : ℝ) + 1)) ^ d := by
      rw [hbase, inv_pow]
      have h := one_add_inv_pow_le_exp_one d hd
      have hpos : (0 : ℝ) < (1 + 1 / (d : ℝ)) ^ d := by positivity
      exact inv_anti₀ hpos h
    have hple : p ≤ 1 / (Real.exp 1 * ((d : ℝ) + 1)) := by
      rw [le_div_iff₀ (by positivity)]
      nlinarith [hepd]
    calc p ≤ 1 / (Real.exp 1 * ((d : ℝ) + 1)) := hple
      _ = (1 / ((d : ℝ) + 1)) * (Real.exp 1)⁻¹ := by field_simp
      _ ≤ (1 / ((d : ℝ) + 1)) * ((d : ℝ) / ((d : ℝ) + 1)) ^ d :=
          mul_le_mul_of_nonneg_left hkey (by positivity)

/-- **Symmetric Lovász Local Lemma.**  If every bad event has probability at most `p`, every
dependency set has at most `d` elements, each event satisfies the one-sided (lopsided)
independence bound with respect to the events outside its dependency set, and
`e · p · (d + 1) ≤ 1`, then some sample point avoids all bad events. -/
theorem lovasz_local_lemma_symmetric (Γ : ι → Finset ι) {p : ℝ} {d : ℕ}
    (hindep : ∀ (i : ι) (S : Finset ι), i ∉ S → Disjoint S (Γ i) →
      μ.prob (A i ∩ avoid A S) ≤ μ.prob (A i) * μ.prob (avoid A S))
    (hp : 0 ≤ p) (hprob : ∀ i, μ.prob (A i) ≤ p) (hdeg : ∀ i, #(Γ i) ≤ d)
    (hepd : Real.exp 1 * p * (d + 1) ≤ 1) :
    ∃ ω : Ω, ∀ i, ω ∉ A i := by
  classical
  set D : ℕ := max d 1 with hD
  have hD1 : 1 ≤ D := le_max_right d 1
  have hDR : (1 : ℝ) ≤ (D : ℝ) := by exact_mod_cast hD1
  set y : ℝ := 1 / ((D : ℝ) + 1) with hy
  have hpos : (0 : ℝ) < (D : ℝ) + 1 := by linarith
  have hy0 : 0 ≤ y := by positivity
  have hy1 : y < 1 := by
    rw [hy, div_lt_one hpos]
    linarith
  have hfacval : (1 : ℝ) - y = (D : ℝ) / ((D : ℝ) + 1) := by
    rw [hy]
    field_simp
    ring
  refine exists_avoiding_all μ A (fun _ => y) Γ hindep (fun _ => hy0) (fun _ => hy1) ?_
  intro i
  have hprod : (∏ _j ∈ Γ i, (1 - y)) = ((D : ℝ) / ((D : ℝ) + 1)) ^ (#(Γ i)) := by
    rw [Finset.prod_const, hfacval]
  have hmono : ((D : ℝ) / ((D : ℝ) + 1)) ^ d ≤ ((D : ℝ) / ((D : ℝ) + 1)) ^ (#(Γ i)) := by
    refine pow_le_pow_of_le_one (by positivity) ?_ (hdeg i)
    rw [div_le_one hpos]
    linarith
  calc μ.prob (A i) ≤ p := hprob i
    _ ≤ (1 / ((D : ℝ) + 1)) * ((D : ℝ) / ((D : ℝ) + 1)) ^ d := symmetric_weight_bound hp hepd
    _ ≤ y * ((D : ℝ) / ((D : ℝ) + 1)) ^ (#(Γ i)) := by
        rw [hy]
        exact mul_le_mul_of_nonneg_left hmono (by positivity)
    _ = y * ∏ _j ∈ Γ i, (1 - y) := by rw [hprod]

/-! ## A concrete instance (non-vacuity check)

The hypotheses above are not vacuous: here is a fully explicit finite probability space in which
they hold. -/

/-- The uniform distribution on four points. -/
noncomputable def uniform4 : FinProbSpace (Fin 4) where
  weight := fun _ => 1 / 4
  weight_nonneg := by intro _; norm_num
  weight_total := by simp

/-- A worked instance of the symmetric LLL: one bad event of probability `1/4` with empty
dependency set (`d = 0`), where `e · (1/4) · 1 ≤ 1`. -/
example : ∃ ω : Fin 4, ∀ i : Fin 1, ω ∉ (fun _ => ({0} : Finset (Fin 4))) i := by
  refine lovasz_local_lemma_symmetric uniform4 (fun _ => ({0} : Finset (Fin 4)))
    (fun _ => (∅ : Finset (Fin 1))) (p := 1 / 4) (d := 0) ?_ (by norm_num) ?_ (by simp) ?_
  · intro i S hiS _
    have hS : S = ∅ :=
      Finset.eq_empty_of_forall_notMem (fun j hj => hiS (by rwa [Subsingleton.elim i j]))
    subst hS
    simp
  · intro i
    simp [FinProbSpace.prob, uniform4]
  · have h := Real.exp_one_lt_d9
    norm_num
    linarith

end LovaszLocalLemmaFinite