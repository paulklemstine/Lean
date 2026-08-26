/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality X: curvature versus total variation

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A.

Companion to `Cryptography.UniversalRedundancyCurvature`, which defines the
curvature `κ(Ω)` of a pool of models for the Shtarkov price functional.  This
file settles the relation between the curvature and the statistical spread of
the pool, measured by pairwise total-variation distance `δ`.

## Main results

* `Library.one_sub_tv_le_curvature` — `κ ≥ 1 − (|Ω| − 1)·δ`: pools of nearly
  identical sources are *maximally* curved;
* `Library.curvature_eq_one_of_duplicate`, `Library.curvature_eq_one_of_card_lt`
  — duplicated models, and pools larger than the message alphabet, force
  `κ = 1` (pigeonhole curvature saturation);
* `Library.not_curvature_le_tv_mul_card` — the **refutation** of the conjecture
  `κ ≤ δ·|Ω|`, by the pool of two identical fair coins;
* `Library.curvature_pair` — for a two-source pool the curvature is *exactly*
  `1 − δ`, so the inequality `κ ≥ 1 − (|Ω| − 1)·δ` is sharp;
* `Library.exists_pool_curvature_eq` — every `κ₀ ∈ [0,1]` is the curvature of an
  explicit pool of two biased coins, so the curvature-indexed greedy guarantees
  are non-degenerate over the whole range.

## Application keywords

universal compression, Shtarkov sum, total curvature, total variation,
greedy approximation, model libraries
-/

import Cryptography.UniversalRedundancyCurvature

open Finset Real

namespace UniversalRedundancy

namespace Library

variable {X : Type*} {ι : Type*} (P : ι → X → ℝ)

/-! ## Nearly identical pools have curvature close to `1` -/

section TotalVariation

variable [Fintype X] [DecidableEq ι]

/-- For probability mass functions the positive part of the difference computes
the total-variation distance. -/
lemma sum_posPart_eq_totalVariation {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    ∑ x, max (p x - q x) 0 = totalVariation p q := by
  have hpt : ∀ x : X, max (p x - q x) 0 = (|p x - q x| + (p x - q x)) / 2 := by
    intro x
    rcases lt_or_ge (p x - q x) 0 with h | h
    · rw [max_eq_right (le_of_lt h), abs_of_neg h]; ring
    · rw [max_eq_left h, abs_of_nonneg h]; ring
  calc ∑ x, max (p x - q x) 0 = ∑ x, (|p x - q x| + (p x - q x)) / 2 :=
        Finset.sum_congr rfl fun x _ => hpt x
    _ = ((∑ x, |p x - q x|) + ((∑ x, p x) - ∑ x, q x)) / 2 := by
        rw [← Finset.sum_div, Finset.sum_add_distrib, Finset.sum_sub_distrib]
    _ = totalVariation p q := by rw [hp, hq]; unfold totalVariation; ring

omit [Fintype X] in
/-- The envelope of a nonempty library of nonnegative models is attained. -/
lemma exists_envelope_eq (hP0 : ∀ i, ∀ x, 0 ≤ P i x) {A : Finset ι} (hA : A.Nonempty)
    (x : X) : ∃ i ∈ A, envelope P A x = P i x := by
  induction hA using Finset.Nonempty.cons_induction with
  | singleton a =>
      exact ⟨a, Finset.mem_singleton_self a, by
        rw [envelope_singleton]; exact max_eq_left (hP0 a x)⟩
  | cons a A ha hA ih =>
      obtain ⟨i, hi, hEq⟩ := ih
      rw [Finset.cons_eq_insert, envelope_insert]
      rcases le_total (P a x) (envelope P A x) with h | h
      · exact ⟨i, Finset.mem_insert_of_mem hi, by rw [max_eq_right h]; exact hEq⟩
      · exact ⟨a, Finset.mem_insert_self a A, max_eq_left h⟩

/-- **Nearly identical pools are maximally curved.**  If the sources of the pool
are pairwise at total-variation distance at most `δ`, then the curvature is at
least `1 − (|Ω| − 1)·δ`.  This is the exact *opposite* of the naive guess
`κ ≤ δ·|Ω|`: redundancy in the pool *raises* the curvature. -/
theorem one_sub_tv_le_curvature {Ω : Finset ι} (hcard : 2 ≤ Ω.card) {delta : ℝ}
    (hP0 : ∀ i, ∀ x, 0 ≤ P i x) (hP1 : ∀ i ∈ Ω, ∑ x, P i x = 1)
    (hTV : ∀ i ∈ Ω, ∀ j ∈ Ω, totalVariation (P i) (P j) ≤ delta) :
    1 - ((Ω.card : ℝ) - 1) * delta ≤ curvature P Ω := by
  obtain ⟨j, hj⟩ : Ω.Nonempty := Finset.card_pos.1 (by omega)
  have herase : (Ω.erase j).Nonempty := by
    rw [← Finset.card_pos, Finset.card_erase_of_mem hj]
    omega
  -- the solo price of a probability mass function is `1`
  have hsolo : shtarkov P {j} = 1 := by
    rw [shtarkov_singleton]
    calc ∑ x, max (P j x) 0 = ∑ x, P j x :=
          Finset.sum_congr rfl fun x _ => max_eq_left (hP0 j x)
      _ = 1 := hP1 j hj
  -- the marginal value of `j` in the pool
  have hnum : shtarkov P Ω - shtarkov P (Ω.erase j)
      = ∑ x, max (P j x - envelope P (Ω.erase j) x) 0 := by
    have h := shtarkov_insert_sub P j (Ω.erase j)
    rwa [Finset.insert_erase hj] at h
  -- pointwise, `j` can only beat the others by what it beats each of them by
  have hpt : ∀ x : X, max (P j x - envelope P (Ω.erase j) x) 0
      ≤ ∑ i ∈ Ω.erase j, max (P j x - P i x) 0 := by
    intro x
    obtain ⟨i, hi, hEq⟩ := exists_envelope_eq P hP0 herase x
    have hterm : max (P j x - envelope P (Ω.erase j) x) 0 ≤ max (P j x - P i x) 0 := by
      rw [hEq]
    refine le_trans hterm ?_
    refine Finset.single_le_sum (f := fun i => max (P j x - P i x) 0) ?_ hi
    intro i _
    exact le_max_right _ _
  have hswap : ∑ x, ∑ i ∈ Ω.erase j, max (P j x - P i x) 0
      = ∑ i ∈ Ω.erase j, ∑ x, max (P j x - P i x) 0 := Finset.sum_comm
  have hTVsum : ∑ i ∈ Ω.erase j, ∑ x, max (P j x - P i x) 0
      ≤ ((Ω.card : ℝ) - 1) * delta := by
    have hbound : ∀ i ∈ Ω.erase j, ∑ x, max (P j x - P i x) 0 ≤ delta := by
      intro i hi
      have hiΩ : i ∈ Ω := Finset.mem_of_mem_erase hi
      rw [sum_posPart_eq_totalVariation (hP1 j hj) (hP1 i hiΩ)]
      exact hTV j hj i hiΩ
    calc ∑ i ∈ Ω.erase j, ∑ x, max (P j x - P i x) 0
        ≤ ∑ _i ∈ Ω.erase j, delta := Finset.sum_le_sum hbound
      _ = ((Ω.erase j).card : ℝ) * delta := by rw [Finset.sum_const, nsmul_eq_mul]
      _ = ((Ω.card : ℝ) - 1) * delta := by
          rw [Finset.card_erase_of_mem hj]
          have : ((Ω.card - 1 : ℕ) : ℝ) = (Ω.card : ℝ) - 1 := by
            have h1 : (1 : ℕ) ≤ Ω.card := by omega
            push_cast [Nat.cast_sub h1]
            ring
          rw [this]
  have hratio : marginalRatio P Ω j ≤ ((Ω.card : ℝ) - 1) * delta := by
    unfold marginalRatio
    rw [hsolo, div_one, hnum]
    calc ∑ x, max (P j x - envelope P (Ω.erase j) x) 0
        ≤ ∑ x, ∑ i ∈ Ω.erase j, max (P j x - P i x) 0 := Finset.sum_le_sum fun x _ => hpt x
      _ = ∑ i ∈ Ω.erase j, ∑ x, max (P j x - P i x) 0 := hswap
      _ ≤ ((Ω.card : ℝ) - 1) * delta := hTVsum
  have hfold : Ω.fold min 1 (marginalRatio P Ω) ≤ ((Ω.card : ℝ) - 1) * delta :=
    (Finset.fold_min_le _).2 (Or.inr ⟨j, hj, hratio⟩)
  unfold curvature
  linarith

/-- If deleting one pool member does not change the price of the pool, the
curvature is exactly `1`. -/
theorem curvature_eq_one_of_erase_eq {Ω : Finset ι} {j : ι} (hj : j ∈ Ω)
    (heq : shtarkov P Ω = shtarkov P (Ω.erase j)) : curvature P Ω = 1 := by
  have hratio : marginalRatio P Ω j = 0 := by
    unfold marginalRatio
    rw [heq, sub_self, zero_div]
  have hle : Ω.fold min 1 (marginalRatio P Ω) ≤ 0 :=
    (Finset.fold_min_le _).2 (Or.inr ⟨j, hj, le_of_eq hratio⟩)
  have hge : 0 ≤ Ω.fold min 1 (marginalRatio P Ω) :=
    (Finset.le_fold_min _).2 ⟨zero_le_one, fun k _ => marginalRatio_nonneg P Ω k⟩
  unfold curvature
  rw [le_antisymm hle hge]
  ring

/-- **Pigeonhole curvature saturation.**  A pool with more models than the
alphabet has curvature exactly `1`: some model is never the maximum-likelihood
explanation of any message, so deleting it costs nothing.  Curvature is
therefore an informative parameter only for pools smaller than the message
space — a purely combinatorial obstruction to low-curvature pools. -/
theorem curvature_eq_one_of_card_lt {Ω : Finset ι} (hP0 : ∀ i, ∀ x, 0 ≤ P i x)
    (hcard : Fintype.card X < Ω.card) : curvature P Ω = 1 := by
  have hΩ : Ω.Nonempty := Finset.card_pos.1 (by omega)
  choose f hf hfeq using fun x : X => exists_envelope_eq P hP0 hΩ x
  have hTcard : (Finset.image f Finset.univ).card ≤ Fintype.card X := by
    calc (Finset.image f Finset.univ).card ≤ (Finset.univ : Finset X).card :=
          Finset.card_image_le
      _ = Fintype.card X := Finset.card_univ
  obtain ⟨j, hj, hjT⟩ : ∃ j ∈ Ω, j ∉ Finset.image f Finset.univ := by
    by_contra hcon
    push_neg at hcon
    have hsub : Ω ⊆ Finset.image f Finset.univ := fun j hj => hcon j hj
    have := Finset.card_le_card hsub
    omega
  have henv : ∀ x, envelope P Ω x = envelope P (Ω.erase j) x := by
    intro x
    refine le_antisymm ?_ (envelope_mono P (Finset.erase_subset j Ω) x)
    rw [hfeq x]
    refine le_envelope P (Finset.mem_erase.2 ⟨?_, hf x⟩) x
    intro hEq
    exact hjT (hEq ▸ Finset.mem_image_of_mem f (Finset.mem_univ x))
  refine curvature_eq_one_of_erase_eq P hj ?_
  unfold shtarkov
  exact Finset.sum_congr rfl fun x _ => henv x

/-- **Duplicated models force maximal curvature.**  If the pool contains two
copies of the same source, its curvature is exactly `1`, the worst possible
value: the greedy guarantee degrades to the bare `1 − 1/e`. -/
theorem curvature_eq_one_of_duplicate {Ω : Finset ι} {i j : ι} (hi : i ∈ Ω) (hj : j ∈ Ω)
    (hij : i ≠ j) (hdup : ∀ x, P i x = P j x) : curvature P Ω = 1 := by
  have hienv : i ∈ Ω.erase j := Finset.mem_erase.2 ⟨hij, hi⟩
  have henv : ∀ x, envelope P Ω x = envelope P (Ω.erase j) x := by
    intro x
    refine le_antisymm ?_ (envelope_mono P (Finset.erase_subset j Ω) x)
    refine envelope_le P (envelope_nonneg P (Ω.erase j) x) fun k hk => ?_
    by_cases hkj : k = j
    · subst hkj
      rw [← hdup x]
      exact le_envelope P hienv x
    · exact le_envelope P (Finset.mem_erase.2 ⟨hkj, hk⟩) x
  refine curvature_eq_one_of_erase_eq P hj ?_
  unfold shtarkov
  exact Finset.sum_congr rfl fun x _ => henv x

end TotalVariation

/-! ## Refutation of the conjecture `κ ≤ δ·|Ω|` -/

section Refutation

/-- The pool of two identical fair coins: a pool of two sources at pairwise
total-variation distance `0`. -/
noncomputable def twinCoins : Fin 2 → Fin 2 → ℝ := fun _ _ => 1 / 2

@[simp] lemma twinCoins_apply (i x : Fin 2) : twinCoins i x = 1 / 2 := rfl

lemma twinCoins_nonneg (i x : Fin 2) : 0 ≤ twinCoins i x := by norm_num

lemma twinCoins_sum (i : Fin 2) : ∑ x, twinCoins i x = 1 := by
  simp [twinCoins]

lemma twinCoins_totalVariation (i j : Fin 2) :
    totalVariation (twinCoins i) (twinCoins j) = 0 := by
  simp [totalVariation, twinCoins]

/-- The curvature of the twin-coin pool is `1`. -/
theorem twinCoins_curvature : curvature twinCoins (Finset.univ : Finset (Fin 2)) = 1 :=
  curvature_eq_one_of_duplicate twinCoins (i := 0) (j := 1) (Finset.mem_univ 0)
    (Finset.mem_univ 1) (by decide) (fun _ => rfl)

/-- **Refutation of the conjecture `κ ≤ δ·|Ω|`.**  There is a pool of two
probability mass functions at pairwise total-variation distance `δ = 0` whose
curvature is `1 > 0 = δ·|Ω|`.  Pools of *nearly identical* sources are therefore
not low-curvature pools; by `one_sub_tv_le_curvature` they are in fact the
maximally curved ones. -/
theorem not_curvature_le_tv_mul_card :
    ∃ (Q : Fin 2 → Fin 2 → ℝ) (Ω : Finset (Fin 2)) (delta : ℝ),
      (∀ i x, 0 ≤ Q i x) ∧ (∀ i ∈ Ω, ∑ x, Q i x = 1) ∧
      (∀ i ∈ Ω, ∀ j ∈ Ω, totalVariation (Q i) (Q j) ≤ delta) ∧
      delta = 0 ∧ ¬ curvature Q Ω ≤ delta * Ω.card := by
  refine ⟨twinCoins, Finset.univ, 0, twinCoins_nonneg, fun i _ => twinCoins_sum i,
    fun i _ j _ => le_of_eq (twinCoins_totalVariation i j), rfl, ?_⟩
  rw [twinCoins_curvature]
  norm_num

end Refutation

/-! ## Two-source pools: curvature is exactly `1 − δ` -/

section Pairs

variable [Fintype X] [DecidableEq ι]

/-- The Shtarkov sum of a two-source library is `1 + δ`. -/
lemma sum_max_eq_one_add_tv {p q : X → ℝ} (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) :
    ∑ x, max (p x) (q x) = 1 + totalVariation p q := by
  have h : ∀ x : X, max (p x) (q x) = (p x + q x + |p x - q x|) / 2 := by
    intro x
    rcases le_total (p x) (q x) with hx | hx
    · rw [max_eq_right hx, abs_of_nonpos (by linarith)]; ring
    · rw [max_eq_left hx, abs_of_nonneg (by linarith)]; ring
  calc ∑ x, max (p x) (q x) = ∑ x, (p x + q x + |p x - q x|) / 2 :=
        Finset.sum_congr rfl fun x _ => h x
    _ = ((∑ x, p x) + (∑ x, q x) + ∑ x, |p x - q x|) / 2 := by
        rw [← Finset.sum_div, Finset.sum_add_distrib, Finset.sum_add_distrib]
    _ = 1 + totalVariation p q := by rw [hp, hq]; unfold totalVariation; ring

/-- The total-variation distance between probability mass functions is at most `1`. -/
lemma totalVariation_le_one {p q : X → ℝ} (hp0 : ∀ x, 0 ≤ p x) (hq0 : ∀ x, 0 ≤ q x)
    (hp : ∑ x, p x = 1) (hq : ∑ x, q x = 1) : totalVariation p q ≤ 1 := by
  rw [← sum_posPart_eq_totalVariation hp hq, ← hp]
  exact Finset.sum_le_sum fun x _ => max_le (by linarith [hq0 x]) (hp0 x)

/-- **The curvature of a two-source pool is exactly `1 − δ`.**  Together with
`one_sub_tv_le_curvature` (which for `|Ω| = 2` reads `κ ≥ 1 − δ`) this shows the
total-variation bound is *sharp*: for pairs the curvature is a strictly
decreasing affine function of the total-variation distance, so low curvature
requires *far apart* sources — the exact reverse of the conjecture `κ ≤ δ·|Ω|`. -/
theorem curvature_pair {a b : ι} (hab : a ≠ b) (hP0 : ∀ i, ∀ x, 0 ≤ P i x)
    (ha : ∑ x, P a x = 1) (hb : ∑ x, P b x = 1) :
    curvature P {a, b} = 1 - totalVariation (P a) (P b) := by
  have hsolo : ∀ c : ι, ∑ x, P c x = 1 → shtarkov P {c} = 1 := by
    intro c hc
    rw [shtarkov_singleton]
    calc ∑ x, max (P c x) 0 = ∑ x, P c x :=
          Finset.sum_congr rfl fun x _ => max_eq_left (hP0 c x)
      _ = 1 := hc
  have hpairEnv : ∀ x, envelope P {a, b} x = max (P a x) (P b x) := by
    intro x
    have hins : ({a, b} : Finset ι) = insert a {b} := rfl
    rw [hins, envelope_insert, envelope_singleton, max_eq_left (hP0 b x)]
  have hpair : shtarkov P {a, b} = 1 + totalVariation (P a) (P b) := by
    unfold shtarkov
    rw [Finset.sum_congr rfl fun x _ => hpairEnv x]
    exact sum_max_eq_one_add_tv ha hb
  have heb : ({a, b} : Finset ι).erase b = {a} := by
    ext c
    simp only [Finset.mem_erase, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨hcb, rfl | rfl⟩
      · rfl
      · exact absurd rfl hcb
    · rintro rfl
      exact ⟨hab, Or.inl rfl⟩
  have hea : ({a, b} : Finset ι).erase a = {b} := by
    ext c
    simp only [Finset.mem_erase, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨hca, rfl | rfl⟩
      · exact absurd rfl hca
      · rfl
    · rintro rfl
      exact ⟨fun h => hab h.symm, Or.inr rfl⟩
  have hra : marginalRatio P {a, b} a = totalVariation (P a) (P b) := by
    unfold marginalRatio
    rw [hea, hpair, hsolo b hb, hsolo a ha, div_one]
    ring
  have hrb : marginalRatio P {a, b} b = totalVariation (P a) (P b) := by
    unfold marginalRatio
    rw [heb, hpair, hsolo a ha, hsolo b hb, div_one]
    ring
  have hTV1 : totalVariation (P a) (P b) ≤ 1 :=
    totalVariation_le_one (hP0 a) (hP0 b) ha hb
  have hfold : ({a, b} : Finset ι).fold min 1 (marginalRatio P {a, b})
      = totalVariation (P a) (P b) := by
    have hins : ({a, b} : Finset ι) = insert a {b} := rfl
    rw [hins, Finset.fold_insert (by simpa using hab), Finset.fold_singleton, hra, hrb,
      min_eq_left hTV1, min_self]
  unfold curvature
  rw [hfold]

end Pairs

/-! ## Every curvature value is realised -/

section Realisation

/-- A pool of two coins with bias gap `d`: source `i` puts mass `(1 + d)/2` on
the message `i` and `(1 - d)/2` on the other one. -/
noncomputable def biasedPair (d : ℝ) : Fin 2 → Fin 2 → ℝ :=
  fun i x => if i = x then (1 + d) / 2 else (1 - d) / 2

lemma biasedPair_nonneg {d : ℝ} (h0 : 0 ≤ d) (h1 : d ≤ 1) (i x : Fin 2) :
    0 ≤ biasedPair d i x := by
  unfold biasedPair
  split <;> linarith

lemma biasedPair_sum (d : ℝ) (i : Fin 2) : ∑ x, biasedPair d i x = 1 := by
  fin_cases i <;> · rw [Fin.sum_univ_two]; norm_num [biasedPair]; ring

lemma biasedPair_totalVariation {d : ℝ} (h0 : 0 ≤ d) :
    totalVariation (biasedPair d 0) (biasedPair d 1) = d := by
  have e1 : (1 + d) / 2 - (1 - d) / 2 = d := by ring
  have e2 : (1 - d) / 2 - (1 + d) / 2 = -d := by ring
  rw [totalVariation, Fin.sum_univ_two]
  norm_num [biasedPair]
  rw [e1, e2, abs_neg, abs_of_nonneg h0]
  ring

/-- The pool of two `d`-biased coins has curvature exactly `1 - d`. -/
theorem biasedPair_curvature {d : ℝ} (h0 : 0 ≤ d) (h1 : d ≤ 1) :
    curvature (biasedPair d) (Finset.univ : Finset (Fin 2)) = 1 - d := by
  have huniv : (Finset.univ : Finset (Fin 2)) = {0, 1} := by decide
  rw [huniv, curvature_pair (biasedPair d) (by decide) (biasedPair_nonneg h0 h1)
    (biasedPair_sum d 0) (biasedPair_sum d 1), biasedPair_totalVariation h0]

/-- **The curvature parameter is non-degenerate.**  Every value `κ₀ ∈ [0,1]` is
the curvature of an explicit pool of two probability mass functions whose
pairwise total-variation distance is exactly `1 - κ₀`.  Hence the whole family
of curvature-indexed greedy guarantees of this file is realised, and the bound
`κ ≥ 1 - (|Ω| - 1)·δ` of `one_sub_tv_le_curvature` is attained. -/
theorem exists_pool_curvature_eq {kappa : ℝ} (h0 : 0 ≤ kappa) (h1 : kappa ≤ 1) :
    ∃ Q : Fin 2 → Fin 2 → ℝ,
      (∀ i x, 0 ≤ Q i x) ∧ (∀ i, ∑ x, Q i x = 1) ∧
      totalVariation (Q 0) (Q 1) = 1 - kappa ∧
      curvature Q (Finset.univ : Finset (Fin 2)) = kappa := by
  refine ⟨biasedPair (1 - kappa), biasedPair_nonneg (by linarith) (by linarith),
    biasedPair_sum _, biasedPair_totalVariation (by linarith), ?_⟩
  rw [biasedPair_curvature (by linarith) (by linarith)]
  ring

end Realisation

end Library

end UniversalRedundancy