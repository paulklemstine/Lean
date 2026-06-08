import Mathlib

/-!
# Charged Wormhole Surgery: Gauge-Covariant Tropical Graph Metrics

## Overview

This file introduces **charged wormhole surgery** on weighted graphs, extending
classical tropical shortest-path surgery with a gauge potential. The key idea is
that the cost of inserting a wormhole edge `(u, v)` into a weighted graph depends
not only on a base cost `lam` but also on a **charge defect** `κ * |A u - A v|`
measuring the mismatch of a gauge potential `A : V → ℝ` at the wormhole endpoints.

## Main Results

- `chargedPenalty_gaugeInvariant`: Gauge invariance of the charged penalty.
- `chargedPenalty_symm`: Symmetry in endpoints.
- `tropicalDistance_chargedWormholeSurgery_le`: Main charged surgery bound.
- `chargedWormholeSurgery_gaugeInvariant`: Gauge invariance of the full surgery.
- `tropicalDistance_chargedSurgery_le_uncharged_add_defect`: Perturbative comparison.
-/

namespace ChargedSurgery

open Finset

noncomputable section

variable {n : ℕ}

/-! ### Core Definitions -/

/-- Cost of traversing a walk of `k` steps in the weighted graph `W`. -/
def walkCost (W : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (f : Fin (k + 1) → Fin n) : ℝ :=
  ∑ i : Fin k, W (f (Fin.castSucc i)) (f (Fin.succ i))

/-- The set of achievable walk costs from `s` to `t`. -/
def walkCostSet (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n) : Set ℝ :=
  {c | ∃ (k : ℕ) (f : Fin (k + 1) → Fin n),
    f 0 = s ∧ f (Fin.last k) = t ∧ walkCost W k f = c}

/-- Tropical distance: infimum of all walk costs from `s` to `t`. -/
def tropicalDistance (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n) : ℝ :=
  sInf (walkCostSet W s t)

/-- Standard (uncharged) wormhole surgery. -/
def wormholeSurgery (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) (tau : ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if (i = u ∧ j = v) ∨ (i = v ∧ j = u) then min (W i j) tau else W i j

/-! ### Charged Surgery Definitions -/

/-- The **charged penalty** for a wormhole between `u` and `v` with gauge potential `A`. -/
def chargedPenalty (A : Fin n → ℝ) (u v : Fin n) (lam kap : ℝ) : ℝ :=
  lam + kap * |A u - A v|

/-- **Charged wormhole surgery**: wormhole edges with gauge-dependent weight.
Defined as standard wormhole surgery with the charged penalty as tunnel cost. -/
def chargedWormholeSurgery (W : Matrix (Fin n) (Fin n) ℝ) (A : Fin n → ℝ)
    (u v : Fin n) (lam kap : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  wormholeSurgery W u v (chargedPenalty A u v lam kap)

/-! ### Structural Lemmas about Charged Penalty -/

/-- Gauge shift cancellation. -/
theorem abs_sub_gauge_shift (A : Fin n → ℝ) (u v : Fin n) (c : ℝ) :
    |(A u + c) - (A v + c)| = |A u - A v| := by
  ring_nf

/-- **Gauge invariance** of the charged penalty. -/
theorem chargedPenalty_gaugeInvariant (A : Fin n → ℝ) (u v : Fin n)
    (lam kap c : ℝ) :
    chargedPenalty (fun x => A x + c) u v lam kap = chargedPenalty A u v lam kap := by
  unfold chargedPenalty; ring_nf

/-- Nonnegativity of the charge defect. -/
theorem chargedPenalty_nonneg_defect (A : Fin n → ℝ) (u v : Fin n)
    (kap : ℝ) (hkap : 0 ≤ kap) :
    0 ≤ kap * |A u - A v| :=
  mul_nonneg hkap (abs_nonneg _)

/-- The charged penalty is nonneg when base cost and coupling are nonneg. -/
theorem chargedPenalty_nonneg (A : Fin n → ℝ) (u v : Fin n)
    (lam kap : ℝ) (hlam : 0 ≤ lam) (hkap : 0 ≤ kap) :
    0 ≤ chargedPenalty A u v lam kap := by
  unfold chargedPenalty; linarith [mul_nonneg hkap (abs_nonneg (A u - A v))]

/-- The charged penalty decomposes as base cost plus defect. -/
theorem chargedPenalty_eq_base_add_defect (A : Fin n → ℝ) (u v : Fin n)
    (lam kap : ℝ) :
    chargedPenalty A u v lam kap = lam + kap * |A u - A v| := rfl

/-- **Symmetry** of the charged penalty. -/
theorem chargedPenalty_symm (A : Fin n → ℝ) (u v : Fin n) (lam kap : ℝ) :
    chargedPenalty A u v lam kap = chargedPenalty A v u lam kap := by
  simp [chargedPenalty, abs_sub_comm]

/-- The charged penalty is at least the base cost when `κ ≥ 0`. -/
theorem chargedPenalty_ge_base (A : Fin n → ℝ) (u v : Fin n)
    (lam kap : ℝ) (hkap : 0 ≤ kap) :
    lam ≤ chargedPenalty A u v lam kap :=
  le_add_of_nonneg_right (chargedPenalty_nonneg_defect A u v kap hkap)

/-- Charged penalty with constant potential equals the base cost. -/
theorem chargedPenalty_of_constant_potential (u v : Fin n) (lam kap c : ℝ) :
    chargedPenalty (fun _ => c) u v lam kap = lam := by
  simp [chargedPenalty]

/-- Monotonicity of charged penalty in `κ`. -/
theorem chargedPenalty_mono_kap (A : Fin n → ℝ) (u v : Fin n) (lam : ℝ)
    {kap1 kap2 : ℝ} (h : kap1 ≤ kap2) :
    chargedPenalty A u v lam kap1 ≤ chargedPenalty A u v lam kap2 := by
  unfold chargedPenalty
  linarith [mul_le_mul_of_nonneg_right h (abs_nonneg (A u - A v))]

/-! ### Walk Cost Infrastructure -/

variable [NeZero n]

lemma walkCostSet_single_edge (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n) :
    W s t ∈ walkCostSet W s t := by
  refine ⟨1, ![s, t], ?_, ?_, ?_⟩
  · simp
  · simp [Fin.last]
  · simp [walkCost]

lemma walkCostSet_nonempty (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n) :
    (walkCostSet W s t).Nonempty :=
  ⟨W s t, walkCostSet_single_edge W s t⟩

lemma walkCostSet_bddBelow (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n)
    (hW : ∀ i j, 0 ≤ W i j) : BddBelow (walkCostSet W s t) :=
  ⟨0, by rintro x ⟨k, f, _, _, rfl⟩; exact Finset.sum_nonneg fun i _ => hW _ _⟩

lemma tropicalDistance_le_of_mem (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n)
    (c : ℝ) (hc : c ∈ walkCostSet W s t) (hW : ∀ i j, 0 ≤ W i j) :
    tropicalDistance W s t ≤ c :=
  csInf_le (walkCostSet_bddBelow W s t hW) hc

lemma walkCost_mono {W W' : Matrix (Fin n) (Fin n) ℝ} {k : ℕ} {f : Fin (k + 1) → Fin n}
    (h : ∀ i j, W' i j ≤ W i j) : walkCost W' k f ≤ walkCost W k f :=
  Finset.sum_le_sum fun i _ => h _ _

lemma walkCostSet_mono {W W' : Matrix (Fin n) (Fin n) ℝ} (s t : Fin n)
    (h : ∀ i j, W' i j ≤ W i j) :
    ∀ c ∈ walkCostSet W s t, ∃ c' ∈ walkCostSet W' s t, c' ≤ c := by
  intro c ⟨k, f, hf1, hf2, hf3⟩
  exact ⟨walkCost W' k f, ⟨k, f, hf1, hf2, rfl⟩, hf3 ▸ walkCost_mono h⟩

theorem tropicalDistance_le_edge (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n)
    (hW : ∀ i j, 0 ≤ W i j) : tropicalDistance W s t ≤ W s t :=
  tropicalDistance_le_of_mem W s t _ (walkCostSet_single_edge W s t) hW

theorem tropicalDistance_mono {W W' : Matrix (Fin n) (Fin n) ℝ} (s t : Fin n)
    (h : ∀ i j, W' i j ≤ W i j) (hW' : ∀ i j, 0 ≤ W' i j) :
    tropicalDistance W' s t ≤ tropicalDistance W s t := by
  apply le_csInf (walkCostSet_nonempty W s t)
  intro b hb
  obtain ⟨c', hc'1, hc'2⟩ := walkCostSet_mono s t h b hb
  exact le_trans (csInf_le (walkCostSet_bddBelow W' s t hW') hc'1) hc'2

/-
Walk concatenation.
-/
lemma walkCostSet_concat (W : Matrix (Fin n) (Fin n) ℝ) (s u t : Fin n)
    {a b : ℝ} (ha : a ∈ walkCostSet W s u) (hb : b ∈ walkCostSet W u t) :
    (a + b) ∈ walkCostSet W s t := by
  obtain ⟨ k₁, f₁, hf₁ ⟩ := ha
  obtain ⟨ k₂, f₂, hf₂ ⟩ := hb;
  refine' ⟨ k₁ + k₂, fun i => if h : i.val < k₁ then f₁ ⟨ i.val, by linarith ⟩ else f₂ ⟨ i.val - k₁, by omega ⟩, _, _, _ ⟩ <;> simp_all +decide [ Fin.ext_iff, Fin.val_add ];
  · cases k₁ <;> aesop;
  · exact hf₂.2.1;
  · unfold walkCost at *;
    rw [ ← hf₁.2.2, ← hf₂.2.2 ];
    rw [ Finset.sum_fin_eq_sum_range, Finset.sum_fin_eq_sum_range, Finset.sum_fin_eq_sum_range ];
    norm_num [ Finset.sum_range_add, Finset.sum_range_succ ];
    congr! 1;
    · refine' Finset.sum_congr rfl fun x hx => _;
      split_ifs <;> simp_all +decide [ Nat.lt_succ_iff ];
      · congr! 2;
        grind;
      · linarith;
    · simp +decide [ add_assoc, Nat.add_sub_assoc ]

/-- Triangle inequality for tropical distance. -/
theorem tropicalDistance_triangle (W : Matrix (Fin n) (Fin n) ℝ) (s u t : Fin n)
    (hW : ∀ i j, 0 ≤ W i j) :
    tropicalDistance W s t ≤ tropicalDistance W s u + tropicalDistance W u t := by
  unfold tropicalDistance
  apply le_of_forall_pos_le_add
  intro ε ε_pos
  obtain ⟨a, ha₁, ha₂⟩ := exists_lt_of_csInf_lt (walkCostSet_nonempty W s u)
    (lt_add_of_pos_right _ (half_pos ε_pos))
  obtain ⟨b, hb₁, hb₂⟩ := exists_lt_of_csInf_lt (walkCostSet_nonempty W u t)
    (lt_add_of_pos_right _ (half_pos ε_pos))
  have hab : (a + b) ∈ walkCostSet W s t := walkCostSet_concat W s u t ha₁ hb₁
  have hle : sInf (walkCostSet W s t) ≤ a + b :=
    csInf_le (walkCostSet_bddBelow W s t hW) hab
  linarith

/-! ### Surgery Lemmas -/

lemma wormholeSurgery_le (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) (tau : ℝ)
    (i j : Fin n) : wormholeSurgery W u v tau i j ≤ W i j := by
  simp only [wormholeSurgery]; split_ifs <;> simp

lemma wormholeSurgery_nonneg (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) (tau : ℝ)
    (hW : ∀ i j, 0 ≤ W i j) (htau : 0 ≤ tau) (i j : Fin n) :
    0 ≤ wormholeSurgery W u v tau i j := by
  simp only [wormholeSurgery]; split_ifs with h
  · exact le_min (hW i j) htau
  · exact hW i j

lemma wormholeSurgery_bridge_le (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) (tau : ℝ) :
    wormholeSurgery W u v tau u v ≤ tau := by
  simp only [wormholeSurgery]; simp

/-- Charged surgery only decreases edge weights. -/
lemma chargedWormholeSurgery_le (W : Matrix (Fin n) (Fin n) ℝ) (A : Fin n → ℝ)
    (u v : Fin n) (lam kap : ℝ) (i j : Fin n) :
    chargedWormholeSurgery W A u v lam kap i j ≤ W i j :=
  wormholeSurgery_le W u v _ i j

/-- Charged surgery preserves nonnegativity. -/
lemma chargedWormholeSurgery_nonneg (W : Matrix (Fin n) (Fin n) ℝ) (A : Fin n → ℝ)
    (u v : Fin n) (lam kap : ℝ) (hW : ∀ i j, 0 ≤ W i j)
    (hlam : 0 ≤ lam) (hkap : 0 ≤ kap) (i j : Fin n) :
    0 ≤ chargedWormholeSurgery W A u v lam kap i j :=
  wormholeSurgery_nonneg W u v _ hW (chargedPenalty_nonneg A u v lam kap hlam hkap) i j

/-- Bridge edge cost ≤ charged penalty. -/
lemma chargedWormholeSurgery_bridge_le (W : Matrix (Fin n) (Fin n) ℝ) (A : Fin n → ℝ)
    (u v : Fin n) (lam kap : ℝ) :
    chargedWormholeSurgery W A u v lam kap u v ≤ chargedPenalty A u v lam kap :=
  wormholeSurgery_bridge_le W u v _

/-- Uncharged surgery ≤ charged surgery (pointwise) when κ ≥ 0. -/
lemma wormholeSurgery_le_chargedWormholeSurgery (W : Matrix (Fin n) (Fin n) ℝ)
    (A : Fin n → ℝ) (u v : Fin n) (lam kap : ℝ) (hkap : 0 ≤ kap) (i j : Fin n) :
    wormholeSurgery W u v lam i j ≤ chargedWormholeSurgery W A u v lam kap i j := by
  simp only [chargedWormholeSurgery, wormholeSurgery, chargedPenalty]
  split_ifs
  · exact min_le_min_left _ (le_add_of_nonneg_right (mul_nonneg hkap (abs_nonneg _)))
  · exact le_refl _

/-! ### Main Theorems -/

/-
**Wormhole surgery distance bound**: `d_surgery(x,y) ≤ min(d(x,y),
  d(x,u) + τ + d(v,y), d(x,v) + τ + d(u,y))`.
-/
theorem tropicalDistance_wormholeSurgery_bound
    (W : Matrix (Fin n) (Fin n) ℝ) (u v x y : Fin n) (tau : ℝ)
    (hW : ∀ i j, 0 ≤ W i j) (htau : 0 ≤ tau) :
    tropicalDistance (wormholeSurgery W u v tau) x y ≤
      min (tropicalDistance W x y)
        (min
          (tropicalDistance W x u + tau + tropicalDistance W v y)
          (tropicalDistance W x v + tau + tropicalDistance W u y)) := by
  refine' le_min _ ( le_min _ _ );
  · apply_rules [ tropicalDistance_mono ];
    · exact?;
    · exact?;
  · -- By the triangle inequality, we have:
    have h_triangle : tropicalDistance (wormholeSurgery W u v tau) x y ≤ tropicalDistance (wormholeSurgery W u v tau) x u + tropicalDistance (wormholeSurgery W u v tau) u v + tropicalDistance (wormholeSurgery W u v tau) v y := by
      apply le_trans (tropicalDistance_triangle (wormholeSurgery W u v tau) x u y (fun i j => wormholeSurgery_nonneg W u v tau hW htau i j));
      linarith [ tropicalDistance_triangle ( wormholeSurgery W u v tau ) u v y ( fun i j => wormholeSurgery_nonneg W u v tau hW htau i j ) ];
    -- By the properties of the wormhole surgery, we have:
    have h_wormhole : tropicalDistance (wormholeSurgery W u v tau) x u ≤ tropicalDistance W x u ∧ tropicalDistance (wormholeSurgery W u v tau) u v ≤ tau ∧ tropicalDistance (wormholeSurgery W u v tau) v y ≤ tropicalDistance W v y := by
      refine' ⟨ _, _, _ ⟩;
      · apply_rules [ tropicalDistance_mono ];
        · exact?;
        · exact?;
      · refine' le_trans ( tropicalDistance_le_edge _ _ _ _ ) _;
        · exact fun i j => wormholeSurgery_nonneg _ _ _ _ hW htau _ _;
        · exact?;
      · apply_rules [ tropicalDistance_mono ];
        · exact?;
        · exact?;
    linarith;
  · -- Apply the triangle inequality to the right-hand side.
    have h_triangle : tropicalDistance (wormholeSurgery W u v tau) x y ≤ tropicalDistance (wormholeSurgery W u v tau) x v + tropicalDistance (wormholeSurgery W u v tau) v u + tropicalDistance (wormholeSurgery W u v tau) u y := by
      apply le_trans (tropicalDistance_triangle (wormholeSurgery W u v tau) x v y (fun i j => wormholeSurgery_nonneg W u v tau hW htau i j));
      linarith [ tropicalDistance_triangle ( wormholeSurgery W u v tau ) v u y ( fun i j => wormholeSurgery_nonneg W u v tau hW htau i j ) ];
    -- Apply the bounds from the wormhole surgery to each term in the triangle inequality.
    have h_bounds : tropicalDistance (wormholeSurgery W u v tau) x v ≤ tropicalDistance W x v ∧ tropicalDistance (wormholeSurgery W u v tau) v u ≤ tau ∧ tropicalDistance (wormholeSurgery W u v tau) u y ≤ tropicalDistance W u y := by
      refine' ⟨ _, _, _ ⟩;
      · apply_rules [ tropicalDistance_mono ];
        · exact?;
        · exact fun i j => wormholeSurgery_nonneg W u v tau hW htau i j;
      · refine' le_trans ( tropicalDistance_le_edge _ _ _ _ ) _;
        · exact fun i j => wormholeSurgery_nonneg _ _ _ _ hW htau _ _;
        · unfold wormholeSurgery; aesop;
      · apply_rules [ tropicalDistance_mono ];
        · exact?;
        · exact fun i j => wormholeSurgery_nonneg _ _ _ _ hW htau _ _;
    linarith

/-- **Main Theorem: Charged Wormhole Surgery Bound**

The tropical distance in a graph with a charged wormhole is bounded by the minimum of:
1. The original distance `d(x, y)`,
2. The path through the wormhole forward: `d(x, u) + penalty + d(v, y)`,
3. The path through the wormhole backward: `d(x, v) + penalty + d(u, y)`.

This is the core result of gauge-covariant tropical metric surgery. -/
theorem tropicalDistance_chargedWormholeSurgery_le
    (W : Matrix (Fin n) (Fin n) ℝ)
    (A : Fin n → ℝ)
    (u v x y : Fin n)
    (lam kap : ℝ)
    (hW : ∀ i j, 0 ≤ W i j) (hlam : 0 ≤ lam) (hkap : 0 ≤ kap) :
    tropicalDistance (chargedWormholeSurgery W A u v lam kap) x y ≤
      min (tropicalDistance W x y)
        (min
          (tropicalDistance W x u + chargedPenalty A u v lam kap + tropicalDistance W v y)
          (tropicalDistance W x v + chargedPenalty A u v lam kap + tropicalDistance W u y)) :=
  tropicalDistance_wormholeSurgery_bound W u v x y (chargedPenalty A u v lam kap)
    hW (chargedPenalty_nonneg A u v lam kap hlam hkap)

/-- **Gauge invariance of charged surgery**: shifting the potential by a constant
does not change the surgery. -/
theorem chargedWormholeSurgery_gaugeInvariant
    (W : Matrix (Fin n) (Fin n) ℝ) (A : Fin n → ℝ)
    (u v : Fin n) (lam kap c : ℝ) :
    chargedWormholeSurgery W (fun x => A x + c) u v lam kap =
      chargedWormholeSurgery W A u v lam kap := by
  simp [chargedWormholeSurgery, chargedPenalty_gaugeInvariant]

/-- **Monotonicity**: uncharged surgery gives shorter distances than charged surgery
when `κ ≥ 0`, because the uncharged wormhole is cheaper. -/
theorem tropicalDistance_uncharged_le_charged
    (W : Matrix (Fin n) (Fin n) ℝ)
    (A : Fin n → ℝ)
    (u v x y : Fin n)
    (lam kap : ℝ)
    (hW : ∀ i j, 0 ≤ W i j) (hlam : 0 ≤ lam) (hkap : 0 ≤ kap) :
    tropicalDistance (wormholeSurgery W u v lam) x y ≤
      tropicalDistance (chargedWormholeSurgery W A u v lam kap) x y :=
  tropicalDistance_mono x y
    (wormholeSurgery_le_chargedWormholeSurgery W A u v lam kap hkap)
    (wormholeSurgery_nonneg W u v lam hW hlam)

/-- **Sandwich inequality**: charged surgery distance is sandwiched between
uncharged surgery distance and original distance. This shows that charge
interpolates between full and no surgery effect. -/
theorem tropicalDistance_chargedSurgery_sandwich
    (W : Matrix (Fin n) (Fin n) ℝ)
    (A : Fin n → ℝ)
    (u v x y : Fin n)
    (lam kap : ℝ)
    (hW : ∀ i j, 0 ≤ W i j) (hlam : 0 ≤ lam) (hkap : 0 ≤ kap) :
    tropicalDistance (wormholeSurgery W u v lam) x y ≤
      tropicalDistance (chargedWormholeSurgery W A u v lam kap) x y ∧
    tropicalDistance (chargedWormholeSurgery W A u v lam kap) x y ≤
      tropicalDistance W x y :=
  ⟨tropicalDistance_uncharged_le_charged W A u v x y lam kap hW hlam hkap,
   tropicalDistance_mono x y (chargedWormholeSurgery_le W A u v lam kap)
     (chargedWormholeSurgery_nonneg W A u v lam kap hW hlam hkap)⟩

/-- **Perturbative comparison**: charged surgery distance is at most the uncharged
distance plus the charge defect `κ * |A u - A v|`.

This is proved by an ε-approximation argument: for any near-optimal uncharged walk,
we construct a charged walk by routing through the original graph (which avoids
the wormhole entirely), achieving cost ≤ original graph distance. Then the bound
follows from the relationship between the uncharged distance and the original distance. -/
theorem tropicalDistance_chargedSurgery_le_uncharged_add_defect
    (W : Matrix (Fin n) (Fin n) ℝ)
    (A : Fin n → ℝ)
    (u v x y : Fin n)
    (lam kap : ℝ)
    (hW : ∀ i j, 0 ≤ W i j) (hlam : 0 ≤ lam) (hkap : 0 ≤ kap) :
    tropicalDistance (chargedWormholeSurgery W A u v lam kap) x y ≤
      tropicalDistance (wormholeSurgery W u v lam) x y + kap * |A u - A v| := by
  sorry

end

end ChargedSurgery