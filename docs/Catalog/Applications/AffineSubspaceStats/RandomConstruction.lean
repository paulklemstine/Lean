/-
# Affine subspace statistics in `𝔽₂ⁿ`: the random construction for `s = 1`

This file continues the development of
`Catalog/Applications/AffineSubspaceStats/AffineStats.lean`, where the model
(random affine `d`-cubes in `𝔽₂ⁿ`, the statistic `cnt`, the probability `flatProb`)
is set up.

The paper's `s = 1` regime is governed by a *random* construction: keep each point of
`𝔽₂ⁿ` independently with probability `p`.  A `d`-flat `F` has `2^d` points, so it meets
such a random set in exactly one point with probability `2^d · p · (1-p)^{2^d - 1}`,
which is maximised at `p = 2^{-d}`, giving `(1 - 2^{-d})^{2^d - 1} → e^{-1}`.

We formalise this as a *counting* argument (no measure theory): instead of a random
subset we average over the `(m+1)^{2ⁿ}` colourings `g : 𝔽₂ⁿ → Fin (m+1)` and take
`A = g⁻¹(0)`, which realises `p = 1/(m+1)` exactly.  The combinatorial heart is
`AffineStats.card_exactly_one`: for a fixed set `T` of `t` points, exactly
`t · m^{t-1} · (m+1)^{|α| - t}` colourings vanish at exactly one point of `T`.

The main results are

* `AffineStats.exists_flatProb_one_ge` :
  `∃ A, λ(d+1,1) ≥ (2^{d+1}·m^{2^{d+1}-1} / (m+1)^{2^{d+1}}) · (1 - (2^{d+1}-1)/2ⁿ)`
  for every `m`;
* `AffineStats.exists_flatProb_one_ge_opt` : the choice `m + 1 = 2^{d+1}`, giving
  `λ(d+1,1) ≥ (1 - 2^{-(d+1)})^{2^{d+1}-1} · (1 - (2^{d+1}-1)/2ⁿ)`;
* `AffineStats.maxFlatProb_one_ge_limit` : hence
  `λ*(d+1,1) ≥ (1 - 2^{-(d+1)})^{2^{d+1}-1}`, which for `d = 0` is the exact value `1/2`
  and for every `d` beats the algebraic construction of
  `Catalog/Applications/AffineSubspaceStats/ExactProduct.lean` (e.g. `27/64` versus
  `3/8` for `2`-flats).
-/
import Mathlib
import Applications.AffineSubspaceStats.AffineStats
import Applications.AffineSubspaceStats.ExactProduct

namespace AffineStats

open Finset

section Counting

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The product of the local factors `1` (at `x₀`), `m` (on `T \ {x₀}`) and `m+1`
(off `T`). -/
lemma prod_local_values (T : Finset α) (m : ℕ) {x₀ : α} (hx₀ : x₀ ∈ T)
    (h : α → ℕ) (hh : ∀ x, h x = if x = x₀ then 1 else if x ∈ T then m else m + 1) :
    (∏ x : α, h x) = m ^ (T.card - 1) * (m + 1) ^ (Fintype.card α - T.card) := by
  classical
  rw [← Finset.prod_mul_prod_compl T h]
  congr 1
  · rw [← Finset.prod_erase_mul T h hx₀, hh x₀, if_pos rfl, mul_one]
    rw [Finset.prod_congr rfl (fun x hx => by
      rw [hh x, if_neg (Finset.mem_erase.mp hx).1, if_pos (Finset.mem_erase.mp hx).2])]
    rw [Finset.prod_const, Finset.card_erase_of_mem hx₀]
  · rw [Finset.prod_congr rfl (fun x hx => by
      have hxT : x ∉ T := Finset.mem_compl.mp hx
      rw [hh x, if_neg (by rintro rfl; exact hxT hx₀), if_neg hxT])]
    rw [Finset.prod_const, Finset.card_compl]

/-- The number of colourings `g : α → Fin (m+1)` whose zero set meets `T` in the single
point `x₀` is `m^{|T|-1} (m+1)^{|α|-|T|}`. -/
lemma card_zero_at_singleton (T : Finset α) (m : ℕ) {x₀ : α} (hx₀ : x₀ ∈ T) :
    (univ.filter fun g : α → Fin (m + 1) => T.filter (fun x => g x = 0) = {x₀}).card
      = m ^ (T.card - 1) * (m + 1) ^ (Fintype.card α - T.card) := by
  classical
  set f : α → Fin (m + 1) → ℕ := fun x a =>
    if x = x₀ then (if a = 0 then 1 else 0) else if x ∈ T then (if a = 0 then 0 else 1) else 1
    with hf
  -- the defining condition is a product of local indicators
  have hind : ∀ g : α → Fin (m + 1),
      (if T.filter (fun x => g x = 0) = {x₀} then 1 else 0) = ∏ x, f x (g x) := by
    intro g
    have hiff : T.filter (fun x => g x = 0) = {x₀} ↔
        (g x₀ = 0 ∧ ∀ x ∈ T, x ≠ x₀ → g x ≠ 0) := by
      constructor
      · intro h
        refine ⟨?_, ?_⟩
        · have hmem : x₀ ∈ T.filter (fun x => g x = 0) := by rw [h]; simp
          exact (mem_filter.mp hmem).2
        · intro x hx hne hg
          have hmem : x ∈ T.filter (fun x => g x = 0) := mem_filter.mpr ⟨hx, hg⟩
          rw [h, mem_singleton] at hmem
          exact hne hmem
      · rintro ⟨h1, h2⟩
        ext x
        simp only [mem_filter, mem_singleton]
        constructor
        · rintro ⟨hx, hgx⟩
          by_contra hne
          exact h2 x hx hne hgx
        · rintro rfl; exact ⟨hx₀, h1⟩
    by_cases hP : T.filter (fun x => g x = 0) = {x₀}
    · rw [if_pos hP]
      rw [hiff] at hP
      symm
      refine Finset.prod_eq_one (fun x _ => ?_)
      by_cases hx : x = x₀
      · subst hx; simp [hf, hP.1]
      · by_cases hxT : x ∈ T
        · simp [hf, hx, hxT, hP.2 x hxT hx]
        · simp [hf, hx, hxT]
    · rw [if_neg hP]
      rw [hiff] at hP
      push_neg at hP
      symm
      by_cases h1 : g x₀ = 0
      · obtain ⟨x, hxT, hne, hgx⟩ := hP h1
        exact Finset.prod_eq_zero (mem_univ x) (by simp [hf, hne, hxT, hgx])
      · exact Finset.prod_eq_zero (mem_univ x₀) (by simp [hf, h1])
  have hsum : (univ.filter fun g : α → Fin (m + 1) => T.filter (fun x => g x = 0) = {x₀}).card
      = ∑ g : α → Fin (m + 1), ∏ x, f x (g x) := by
    rw [Finset.card_filter]
    exact Finset.sum_congr rfl (fun g _ => hind g)
  have hswap := Finset.prod_univ_sum (ι := α) (R := ℕ) (κ := fun _ => Fin (m + 1))
    (fun _ => (univ : Finset (Fin (m + 1)))) f
  rw [Fintype.piFinset_univ] at hswap
  rw [hsum, ← hswap]
  -- evaluate the local sums
  refine prod_local_values T m hx₀ _ (fun x => ?_)
  by_cases hx : x = x₀
  · simp [hf, hx]
  · by_cases hxT : x ∈ T
    · simp only [hf, if_neg hx, if_pos hxT]
      rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
      simp [Finset.filter_ne']
    · simp [hf, hx, hxT]

/-- **The basic count.** Exactly `|T| · m^{|T|-1} · (m+1)^{|α|-|T|}` colourings
`g : α → Fin (m+1)` vanish at exactly one point of `T`. -/
theorem card_exactly_one (T : Finset α) (m : ℕ) :
    (univ.filter fun g : α → Fin (m + 1) => (T.filter fun x => g x = 0).card = 1).card
      = T.card * (m ^ (T.card - 1) * (m + 1) ^ (Fintype.card α - T.card)) := by
  classical
  have hbi : (univ.filter fun g : α → Fin (m + 1) => (T.filter fun x => g x = 0).card = 1)
      = T.biUnion (fun x₀ => univ.filter fun g : α → Fin (m + 1) =>
          T.filter (fun x => g x = 0) = {x₀}) := by
    ext g
    simp only [mem_filter, mem_univ, true_and, mem_biUnion]
    constructor
    · intro h
      obtain ⟨a, ha⟩ := Finset.card_eq_one.mp h
      refine ⟨a, ?_, ha⟩
      have hmem : a ∈ T.filter (fun x => g x = 0) := by rw [ha]; simp
      exact (mem_filter.mp hmem).1
    · rintro ⟨a, _, ha⟩
      rw [ha]; simp
  rw [hbi, Finset.card_biUnion]
  · rw [Finset.sum_congr rfl (fun x₀ hx₀ => card_zero_at_singleton T m hx₀),
      Finset.sum_const, smul_eq_mul]
  · intro a _ b _ hab
    simp only [Finset.disjoint_left, mem_filter, mem_univ, true_and]
    rintro g h1 h2
    rw [h1] at h2
    exact hab (by simpa using h2)

end Counting

section RandomSet

variable {n d : ℕ}

/-- The subset of `𝔽₂ⁿ` cut out by a colouring: the fibre over `0`. -/
def colSet (m : ℕ) (g : Vec n → Fin (m + 1)) : Finset (Vec n) :=
  univ.filter fun x => g x = 0

/-- The point set of the affine cube with parameters `(c, v)`. -/
def cubeSet (c : Vec n) (v : Fin d → Vec n) : Finset (Vec n) :=
  univ.image (pt c v)

lemma card_cubeSet {c : Vec n} {v : Fin d → Vec n} (hv : Indep v) :
    (cubeSet c v).card = 2 ^ d := by
  rw [cubeSet, Finset.card_image_of_injective _ (pt_injective c hv), Finset.card_univ]
  simp

/-- The cube meets `g⁻¹(0)` in exactly the points of its point set where `g` vanishes. -/
lemma cnt_colSet (m : ℕ) (g : Vec n → Fin (m + 1)) (c : Vec n) {v : Fin d → Vec n}
    (hv : Indep v) :
    cnt (colSet m g) c v = ((cubeSet c v).filter fun x => g x = 0).card := by
  classical
  rw [cnt]
  refine Finset.card_nbij (fun y => pt c v y) ?_ ?_ ?_
  · intro y hy
    have hy' : pt c v y ∈ colSet m g := (mem_filter.mp hy).2
    have hg0 : g (pt c v y) = 0 := by
      simpa [colSet] using hy'
    simp only [Finset.coe_filter, Set.mem_setOf_eq]
    exact ⟨Finset.mem_image_of_mem _ (mem_univ y), hg0⟩
  · intro y _ y' _ h
    exact pt_injective c hv h
  · intro x hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, cubeSet, Finset.mem_image, mem_univ,
      true_and] at hx
    obtain ⟨⟨y, hy⟩, hgx⟩ := hx
    refine ⟨y, ?_, hy⟩
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and, colSet, mem_filter]
    rw [hy]
    exact hgx

/-- For a nondegenerate cube, the number of colourings for which the cube meets `g⁻¹(0)`
in exactly one point is `2^d · m^{2^d-1} · (m+1)^{2ⁿ-2^d}`. -/
lemma card_colourings_cnt_one (m : ℕ) (c : Vec n) {v : Fin d → Vec n} (hv : Indep v) :
    (univ.filter fun g : Vec n → Fin (m + 1) => cnt (colSet m g) c v = 1).card
      = 2 ^ d * (m ^ (2 ^ d - 1) * (m + 1) ^ (2 ^ n - 2 ^ d)) := by
  classical
  have hcong : (univ.filter fun g : Vec n → Fin (m + 1) => cnt (colSet m g) c v = 1)
      = (univ.filter fun g : Vec n → Fin (m + 1) =>
          ((cubeSet c v).filter fun x => g x = 0).card = 1) := by
    refine Finset.filter_congr (fun g _ => ?_)
    rw [cnt_colSet m g c hv]
  rw [hcong, card_exactly_one, card_cubeSet hv, card_Vec]

end RandomSet

section Averaging

/-- Averaging over all colourings: some colouring gives a set whose one-point-intersection
count is at least the average. -/
lemma exists_colouring_hitSet_ge (n d m : ℕ) :
    ∃ g : Vec n → Fin (m + 1),
      (univ.filter fun p : Param n (d + 1) => Indep p.2).card *
          (2 ^ (d + 1) * (m ^ (2 ^ (d + 1) - 1) * (m + 1) ^ (2 ^ n - 2 ^ (d + 1))))
        ≤ (m + 1) ^ (2 ^ n) * (hitSet n (d + 1) (colSet m g) 1).card := by
  classical
  set C := 2 ^ (d + 1) * (m ^ (2 ^ (d + 1) - 1) * (m + 1) ^ (2 ^ n - 2 ^ (d + 1))) with hC
  set IP := (univ.filter fun p : Param n (d + 1) => Indep p.2).card with hIP
  set K := (m + 1) ^ (2 ^ n) with hK
  have hKcard : Fintype.card (Vec n → Fin (m + 1)) = K := by
    rw [hK, Fintype.card_fun, card_Vec]
    simp
  by_contra hcon
  push_neg at hcon
  -- double counting
  have hdc : ∑ g : Vec n → Fin (m + 1), (hitSet n (d + 1) (colSet m g) 1).card
      = ∑ p : Param n (d + 1),
          (univ.filter fun g : Vec n → Fin (m + 1) => cnt (colSet m g) p.1 p.2 = 1).card := by
    simp only [hitSet, Finset.card_filter]
    exact Finset.sum_comm
  have hlow : IP * C ≤ ∑ p : Param n (d + 1),
      (univ.filter fun g : Vec n → Fin (m + 1) => cnt (colSet m g) p.1 p.2 = 1).card := by
    calc IP * C = ∑ _p ∈ univ.filter (fun p : Param n (d + 1) => Indep p.2), C := by
          rw [Finset.sum_const, smul_eq_mul, hIP]
      _ = ∑ p ∈ univ.filter (fun p : Param n (d + 1) => Indep p.2),
            (univ.filter fun g : Vec n → Fin (m + 1) => cnt (colSet m g) p.1 p.2 = 1).card := by
          refine Finset.sum_congr rfl (fun p hp => ?_)
          rw [hC, card_colourings_cnt_one m p.1 (Finset.mem_filter.mp hp).2]
      _ ≤ ∑ p : Param n (d + 1),
            (univ.filter fun g : Vec n → Fin (m + 1) => cnt (colSet m g) p.1 p.2 = 1).card :=
          Finset.sum_le_sum_of_subset (Finset.filter_subset _ _)
  have hup : ∑ g : Vec n → Fin (m + 1), K * (hitSet n (d + 1) (colSet m g) 1).card
      < ∑ _g : Vec n → Fin (m + 1), IP * C :=
    Finset.sum_lt_sum_of_nonempty ⟨fun _ => 0, mem_univ _⟩ (fun g _ => hcon g)
  rw [Finset.sum_const, Finset.card_univ, hKcard, smul_eq_mul, ← Finset.mul_sum, hdc] at hup
  exact absurd (Nat.mul_le_mul_left K hlow) (not_le.mpr hup)

/-- The number of parameters with independent directions is at least
`2^{n(d+2)} - (2^{d+1}-1)·2^{n(d+1)}`. -/
lemma card_indepParams_ge (n d : ℕ) :
    2 ^ (n * (d + 1 + 1)) ≤ (univ.filter fun p : Param n (d + 1) => Indep p.2).card
      + (2 ^ (d + 1) - 1) * 2 ^ (n * (d + 1)) := by
  have h1 := card_indep_ge n d
  have h2 := card_indepParams n d
  have h4 : 2 ^ n * 2 ^ (n * (d + 1)) = 2 ^ (n * (d + 1 + 1)) := by
    rw [← pow_add]; congr 1; ring
  have h5 : 2 ^ n * ((2 ^ (d + 1) - 1) * 2 ^ (n * d))
      = (2 ^ (d + 1) - 1) * 2 ^ (n * (d + 1)) := by
    rw [show (2 : ℕ) ^ (n * (d + 1)) = 2 ^ (n * d) * 2 ^ n from by
      rw [← pow_add, Nat.mul_succ]]
    ring
  calc 2 ^ (n * (d + 1 + 1)) = 2 ^ n * 2 ^ (n * (d + 1)) := h4.symm
    _ ≤ 2 ^ n * ((univ.filter fun v : Fin (d + 1) → Vec n => Indep v).card
          + (2 ^ (d + 1) - 1) * 2 ^ (n * d)) := Nat.mul_le_mul_left _ h1
    _ = 2 ^ n * (univ.filter fun v : Fin (d + 1) → Vec n => Indep v).card
          + 2 ^ n * ((2 ^ (d + 1) - 1) * 2 ^ (n * d)) := by ring
    _ = (univ.filter fun p : Param n (d + 1) => Indep p.2).card
          + (2 ^ (d + 1) - 1) * 2 ^ (n * (d + 1)) := by rw [h5, h2]

end Averaging

section MainBound

/-- A convenient algebraic identity: `((a-1)/a)^t = a(a-1)^t / a^{t+1}`. -/
lemma div_pow_shift (a : ℚ) (t : ℕ) (ha : a ≠ 0) :
    ((a - 1) / a) ^ t = a * (a - 1) ^ t / a ^ (t + 1) := by
  rw [div_pow, pow_succ]
  field_simp

/-- **The random construction.** For every `m`, some `A ⊆ 𝔽₂ⁿ` satisfies
`P[|F ∩ A| = 1] ≥ 2^{d+1}·p·(1-p)^{2^{d+1}-1}·(1 - (2^{d+1}-1)/2ⁿ)` with `p = 1/(m+1)`,
where `F` is a uniformly random affine `(d+1)`-cube. -/
theorem exists_flatProb_one_ge (n d m : ℕ) (hdn : d + 1 ≤ n) :
    ∃ A : Finset (Vec n),
      ((2 : ℚ) ^ (d + 1) * m ^ (2 ^ (d + 1) - 1) / (m + 1) ^ (2 ^ (d + 1)))
          * (1 - (2 ^ (d + 1) - 1) / 2 ^ n) ≤ flatProb n (d + 1) A 1 := by
  classical
  obtain ⟨g, hg⟩ := exists_colouring_hitSet_ge n d m
  refine ⟨colSet m g, ?_⟩
  set X := ((hitSet n (d + 1) (colSet m g) 1).card : ℚ) with hX
  set IP := ((univ.filter fun p : Param n (d + 1) => Indep p.2).card : ℚ) with hIP
  set R := (2 : ℚ) ^ (d + 1) * (m : ℚ) ^ (2 ^ (d + 1) - 1)
      / ((m : ℚ) + 1) ^ (2 ^ (d + 1)) with hR
  set K := ((m : ℚ) + 1) ^ (2 ^ n) with hK
  have hRnonneg : 0 ≤ R := by rw [hR]; positivity
  have hKpos : (0 : ℚ) < K := by rw [hK]; positivity
  have hpowsplit : K = ((m : ℚ) + 1) ^ (2 ^ n - 2 ^ (d + 1)) * ((m : ℚ) + 1) ^ (2 ^ (d + 1)) := by
    rw [hK, ← pow_add, Nat.sub_add_cancel (Nat.pow_le_pow_right (by norm_num) hdn)]
  -- the counting inequality, cast to `ℚ`
  have hcast : IP * ((2 : ℚ) ^ (d + 1)
      * ((m : ℚ) ^ (2 ^ (d + 1) - 1) * ((m : ℚ) + 1) ^ (2 ^ n - 2 ^ (d + 1)))) ≤ K * X := by
    have h := (Nat.cast_le (α := ℚ)).mpr hg
    push_cast at h
    rw [hX, hIP, hK]
    exact h
  have hCRK : ((2 : ℚ) ^ (d + 1)
      * ((m : ℚ) ^ (2 ^ (d + 1) - 1) * ((m : ℚ) + 1) ^ (2 ^ n - 2 ^ (d + 1)))) = R * K := by
    rw [hR, hpowsplit]
    have hne : (((m : ℚ) + 1) ^ (2 ^ (d + 1))) ≠ 0 := by positivity
    field_simp
  rw [hCRK] at hcast
  have hXge : IP * R ≤ X := by
    refine le_of_mul_le_mul_left ?_ hKpos
    calc K * (IP * R) = IP * (R * K) := by ring
      _ ≤ K * X := hcast
  -- the fraction of nondegenerate parameters
  have hcastsub : ((2 ^ (d + 1) - 1 : ℕ) : ℚ) = (2 : ℚ) ^ (d + 1) - 1 := by
    rw [Nat.cast_sub Nat.one_le_two_pow]; push_cast; ring
  have hIPge : (2 : ℚ) ^ (n * (d + 1 + 1)) - ((2 : ℚ) ^ (d + 1) - 1) * 2 ^ (n * (d + 1)) ≤ IP := by
    have h := (Nat.cast_le (α := ℚ)).mpr (card_indepParams_ge n d)
    push_cast [hcastsub] at h
    rw [hIP]
    linarith
  -- assemble
  rw [flatProb, ← hX]
  have hPpos : (0 : ℚ) < 2 ^ (n * (d + 1 + 1)) := by positivity
  rw [le_div_iff₀ hPpos]
  have hsplit : (2 : ℚ) ^ (n * (d + 1 + 1)) = 2 ^ (n * (d + 1)) * 2 ^ n := by
    rw [← pow_add]; congr 1
  have hEeq : R * (1 - ((2 : ℚ) ^ (d + 1) - 1) / 2 ^ n) * 2 ^ (n * (d + 1 + 1))
      = R * (2 ^ (n * (d + 1 + 1)) - ((2 : ℚ) ^ (d + 1) - 1) * 2 ^ (n * (d + 1))) := by
    rw [mul_assoc]
    congr 1
    rw [hsplit]
    field_simp
  rw [hEeq]
  calc R * ((2 : ℚ) ^ (n * (d + 1 + 1)) - ((2 : ℚ) ^ (d + 1) - 1) * 2 ^ (n * (d + 1)))
      ≤ R * IP := mul_le_mul_of_nonneg_left hIPge hRnonneg
    _ = IP * R := by ring
    _ ≤ X := hXge

/-- **The optimal choice `p = 2^{-(d+1)}`.** Taking `m + 1 = 2^{d+1}` gives
`λ(d+1, 1) ≥ (1 - 2^{-(d+1)})^{2^{d+1}-1}·(1 - (2^{d+1}-1)/2ⁿ)`. -/
theorem exists_flatProb_one_ge_opt (n d : ℕ) (hdn : d + 1 ≤ n) :
    ∃ A : Finset (Vec n),
      (((2 : ℚ) ^ (d + 1) - 1) / 2 ^ (d + 1)) ^ (2 ^ (d + 1) - 1)
          * (1 - (2 ^ (d + 1) - 1) / 2 ^ n) ≤ flatProb n (d + 1) A 1 := by
  obtain ⟨A, hA⟩ := exists_flatProb_one_ge n d (2 ^ (d + 1) - 1) hdn
  refine ⟨A, le_trans (le_of_eq ?_) hA⟩
  congr 1
  have hc : ((2 ^ (d + 1) - 1 : ℕ) : ℚ) = (2 : ℚ) ^ (d + 1) - 1 := by
    rw [Nat.cast_sub Nat.one_le_two_pow]; push_cast; ring
  rw [hc, show ((2 : ℚ) ^ (d + 1) - 1) + 1 = (2 : ℚ) ^ (d + 1) from by ring]
  set t := 2 ^ (d + 1) - 1 with ht
  have h1 : (1 : ℕ) ≤ 2 ^ (d + 1) := Nat.one_le_two_pow
  have hpow : (2 : ℕ) ^ (d + 1) = t + 1 := by omega
  rw [hpow]
  exact div_pow_shift _ t (by positivity)

/-- **`λ*(d+1, 1) ≥ (1 - 2^{-(d+1)})^{2^{d+1}-1}`.** The random construction's value is a
lower bound for the limit: for every `ε > 0` all large `n` admit a set `A ⊆ 𝔽₂ⁿ` whose
one-point-intersection probability exceeds `(1 - 2^{-(d+1)})^{2^{d+1}-1} - ε`. -/
theorem maxFlatProb_one_ge_limit (d : ℕ) {ε : ℝ} (hε : 0 < ε) :
    ∃ N : ℕ, ∀ n ≥ N, ∃ A : Finset (Vec n),
      ((((2 : ℝ) ^ (d + 1) - 1) / 2 ^ (d + 1)) ^ (2 ^ (d + 1) - 1) : ℝ) - ε
        ≤ ((flatProb n (d + 1) A 1 : ℚ) : ℝ) := by
  set L := ((((2 : ℝ) ^ (d + 1) - 1) / 2 ^ (d + 1)) ^ (2 ^ (d + 1) - 1) : ℝ) with hL
  have hbase : (0 : ℝ) ≤ ((2 : ℝ) ^ (d + 1) - 1) / 2 ^ (d + 1) := by
    apply div_nonneg _ (by positivity)
    have : (1 : ℝ) ≤ 2 ^ (d + 1) := one_le_pow₀ (by norm_num)
    linarith
  have hL0 : 0 ≤ L := by rw [hL]; positivity
  have hL1 : L ≤ 1 := by
    rw [hL]
    refine pow_le_one₀ hbase ?_
    rw [div_le_one (by positivity)]
    linarith
  -- choose `N` so that `(2^{d+1}-1)/2ᴺ < ε`
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ((2 : ℝ) ^ (d + 1) - 1) / 2 ^ N < ε := by
    have hzero : Filter.Tendsto (fun n : ℕ => ((2 : ℝ) ^ (d + 1) - 1) / 2 ^ n)
        Filter.atTop (nhds 0) := by
      have hgeom : Filter.Tendsto (fun n : ℕ => ((1 : ℝ) / 2) ^ n) Filter.atTop (nhds 0) :=
        tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
      have hrw : (fun n : ℕ => ((2 : ℝ) ^ (d + 1) - 1) / 2 ^ n)
          = fun n : ℕ => ((2 : ℝ) ^ (d + 1) - 1) * ((1 / 2) ^ n) := by
        funext n; rw [div_pow, one_pow]; field_simp
      rw [hrw]
      simpa using hgeom.const_mul ((2 : ℝ) ^ (d + 1) - 1)
    exact (hzero.eventually (gt_mem_nhds hε)).exists
  refine ⟨max N (d + 1), fun n hn => ?_⟩
  have hdn : d + 1 ≤ n := le_trans (le_max_right _ _) hn
  have hNn : N ≤ n := le_trans (le_max_left _ _) hn
  obtain ⟨A, hA⟩ := exists_flatProb_one_ge_opt n d hdn
  refine ⟨A, ?_⟩
  have hAR := (Rat.cast_le (K := ℝ)).mpr hA
  push_cast at hAR
  have hd1 : (1 : ℝ) ≤ 2 ^ (d + 1) := one_le_pow₀ (by norm_num)
  have herr : ((2 : ℝ) ^ (d + 1) - 1) / 2 ^ n ≤ ((2 : ℝ) ^ (d + 1) - 1) / 2 ^ N := by
    refine div_le_div_of_nonneg_left (by linarith) (by positivity) ?_
    exact pow_le_pow_right₀ (by norm_num) hNn
  have herr2 : (0 : ℝ) ≤ ((2 : ℝ) ^ (d + 1) - 1) / 2 ^ n := by
    apply div_nonneg _ (by positivity)
    linarith
  nlinarith [hAR, hL0, hL1, herr, herr2]

end MainBound

section Comparison

/-- **The random construction strictly beats the algebraic one.** For `2`-flats and `n ≥ 5`,
some subset of `𝔽₂ⁿ` has a strictly larger one-point-intersection probability than the
codimension-`2` subspace, whose probability is exactly `3/8`; the random construction gives
at least `27/64·(1 - 3/2ⁿ) ≥ 783/2048 > 3/8`. -/
theorem random_beats_codimSub (n : ℕ) (hn : 5 ≤ n) :
    ∃ A : Finset (Vec n),
      flatProb n 2 (codimSub (m := 2) n (by omega)) 1 < flatProb n 2 A 1 := by
  obtain ⟨A, hA⟩ := exists_flatProb_one_ge_opt n 1 (by omega)
  refine ⟨A, lt_of_lt_of_le ?_ hA⟩
  rw [flatProb_one_eq_prod (d := 2) (n := n) (by omega)]
  have hprod : (∏ i : Fin 2, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ 2)) = 3 / 8 := by
    rw [Fin.prod_univ_two]
    norm_num
  rw [hprod]
  have hpow : (2 : ℚ) ^ 5 ≤ 2 ^ n := by
    exact pow_le_pow_right₀ (by norm_num) hn
  have hpos : (0 : ℚ) < 2 ^ n := by positivity
  have herr : ((2 : ℚ) ^ (1 + 1) - 1) / 2 ^ n ≤ 3 / 32 := by
    rw [div_le_div_iff₀ hpos (by norm_num : (0:ℚ) < 32)]
    norm_num at hpow ⊢
    linarith
  have hval : (((2 : ℚ) ^ (1 + 1) - 1) / 2 ^ (1 + 1)) ^ (2 ^ (1 + 1) - 1) = 27 / 64 := by
    norm_num
  rw [hval]
  nlinarith [herr]

end Comparison

section Asymptotics

open Filter

/-- `((N-1)/N)^{N-1} → e^{-1}`. -/
lemma tendsto_one_sub_inv_pow_pred :
    Tendsto (fun N : ℕ => (((N : ℝ) - 1) / N) ^ (N - 1)) atTop (nhds (Real.exp (-1))) := by
  have h1 : Tendsto (fun N : ℕ => (1 + (-1 : ℝ) / N) ^ N) atTop (nhds (Real.exp (-1))) :=
    Real.tendsto_one_add_div_pow_exp (-1)
  have h2 : Tendsto (fun N : ℕ => (1 + (-1 : ℝ) / N)) atTop (nhds 1) := by
    have h0 : Tendsto (fun N : ℕ => (-1 : ℝ) / N) atTop (nhds 0) :=
      tendsto_const_div_atTop_nhds_zero_nat (-1)
    simpa using (tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).add h0
  have h3 := h1.div h2 one_ne_zero
  rw [div_one] at h3
  refine h3.congr' ?_
  filter_upwards [eventually_ge_atTop 2] with N hN
  have hN0 : (0 : ℝ) < (N : ℝ) := by
    have hpos : 0 < N := by omega
    exact_mod_cast hpos
  have h2N : (2 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  have hne : ((N : ℝ) - 1) / N ≠ 0 := div_ne_zero (by linarith) (ne_of_gt hN0)
  have heq : (1 + (-1 : ℝ) / N) = ((N : ℝ) - 1) / N := by field_simp; ring
  simp only [Pi.div_apply, heq]
  rw [div_eq_iff hne, ← pow_succ]
  congr 1
  omega

/-- **The limit of the construction is `e^{-1}`.** The lower bounds
`(1 - 2^{-(d+1)})^{2^{d+1}-1}` of `AffineStats.maxFlatProb_one_ge_limit` converge to
`1/e`, so `liminf_{d} λ*(d,1) ≥ e^{-1}`. -/
theorem tendsto_randomBound_exp :
    Tendsto (fun d : ℕ => ((((2 : ℝ) ^ (d + 1) - 1) / 2 ^ (d + 1)) ^ (2 ^ (d + 1) - 1))) atTop
      (nhds (Real.exp (-1))) := by
  have hpow : Tendsto (fun d : ℕ => 2 ^ (d + 1)) atTop atTop := by
    refine tendsto_atTop_mono (fun d => ?_) tendsto_id
    calc d ≤ 2 ^ d := Nat.le_of_lt Nat.lt_two_pow_self
      _ ≤ 2 ^ (d + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  refine (tendsto_one_sub_inv_pow_pred.comp hpow).congr (fun d => ?_)
  simp only [Function.comp_apply]
  push_cast
  ring_nf

end Asymptotics

end AffineStats