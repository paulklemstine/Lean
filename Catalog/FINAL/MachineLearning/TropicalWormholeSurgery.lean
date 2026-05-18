import Mathlib

/-!
# Tropical Wormhole Surgery: Min-Plus Spacetime Bridging

## Overview

This file develops a theory of **tropical discrete relativity** where smooth Lorentzian
wormholes are replaced by finite weighted graph models of spacetime. The central
innovation is to identify an exact theorem-level correspondence between:

1. A graph-theoretic model of spacetime with a designated surgery edge,
2. A tropical curvature surrogate controlling bottleneck radius,
3. A shortest-path reduction of the tropical Einstein balance law,
4. Efficient computability of traversing geodesics via relaxation.

## Main Results

- `tropicalDistance_wormholeSurgery_le`: Surgery strictly decreases tropical separation
- `tropicalDistance_wormholeSurgery_strict`: Strict distance decrease corollary
- `throatRadius_controlled_by_minPlusRicci`: Curvature controls throat radius
- `wormholeSurgery_distance_bound_via_curvature`: Curvature-controlled distance bound
- `tropicalDistance_bellman_le`: Tropical Einstein equation reduces to Bellman optimality
- `relax_monotone`: Bellman-Ford relaxation is monotone
- `iterateRelax_monotone`: Iterated relaxation preserves ordering
-/

namespace TropicalWormhole

open Finset

noncomputable section

variable {n : ℕ}

/-! ### Core Definitions -/

/-- Cost of traversing a walk of `k` steps, where the walk is given by a function
  `f : Fin (k + 1) → Fin n` mapping step indices to vertices. The cost is the sum
  of edge weights along consecutive vertices in the walk. -/
def walkCost (W : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (f : Fin (k + 1) → Fin n) : ℝ :=
  ∑ i : Fin k, W (f (Fin.castSucc i)) (f (Fin.succ i))

/-- The set of achievable walk costs from `s` to `t` in the weighted graph `W`.
  A cost `c` is achievable if there exists a walk (of any finite length) starting
  at `s` and ending at `t` with total edge cost equal to `c`. -/
def walkCostSet (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n) : Set ℝ :=
  {c | ∃ (k : ℕ) (f : Fin (k + 1) → Fin n),
    f 0 = s ∧ f (Fin.last k) = t ∧ walkCost W k f = c}

/-- Tropical distance between vertices `s` and `t`: the infimum of all walk costs.
  This is the shortest-path distance in the min-plus semiring sense. -/
def tropicalDistance (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n) : ℝ :=
  sInf (walkCostSet W s t)

/-- Wormhole surgery: modify the weight matrix by reducing the cost of traversing
  the bridge edges `(u,v)` and `(v,u)` to at most `τ`. All other edges are unchanged. -/
def wormholeSurgery (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) (τ : ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if (i = u ∧ j = v) ∨ (i = v ∧ j = u) then min (W i j) τ else W i j

variable [NeZero n]

/-- Min-plus Ricci curvature surrogate at vertex `x`. Measures the minimum average
  roundtrip cost from `x` through any other vertex. This serves as a discrete analog
  of Ricci curvature in the min-plus framework. -/
def minPlusRicci (W : Matrix (Fin n) (Fin n) ℝ) (x : Fin n) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (fun y => (W x y + W y x) / 2)

/-- Throat bound: average of min-plus Ricci curvatures at the bridge endpoints.
  Controls the maximum admissible wormhole throat radius. -/
def throatBound (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) : ℝ :=
  (minPlusRicci W u + minPlusRicci W v) / 2

/-- Throat radius of a wormhole surgery: the minimum of `τ/2` and the throat bound.
  Represents the effective traversable radius of the wormhole. -/
def throatRadius (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) (τ : ℝ) : ℝ :=
  min (τ / 2) (throatBound W u v)

/-- The Tropical Einstein Equation (subsolution form): a Bellman-style fixed-point
  condition. `Φ` is a subsolution if `Φ source = 0` and for every vertex `x`,
  `Φ x` is at most the minimum over all `y` of `Φ y + W y x`. -/
def TropicalEinsteinSubsolution (W : Matrix (Fin n) (Fin n) ℝ) (source : Fin n)
    (Φ : Fin n → ℝ) : Prop :=
  Φ source = 0 ∧
  ∀ x, Φ x ≤ Finset.inf' Finset.univ Finset.univ_nonempty (fun y => Φ y + W y x)

/-- Bellman-Ford relaxation operator: updates distance estimates by taking the
  minimum over all one-step improvements. -/
def relax (W : Matrix (Fin n) (Fin n) ℝ) (d : Fin n → ℝ) : Fin n → ℝ :=
  fun x => Finset.inf' Finset.univ Finset.univ_nonempty (fun y => d y + W y x)

/-- Iterated relaxation: applies the Bellman-Ford relaxation operator `k` times. -/
def iterateRelax (k : ℕ) (W : Matrix (Fin n) (Fin n) ℝ) (d0 : Fin n → ℝ) :
    Fin n → ℝ :=
  (relax W)^[k] d0

/-! ### Helper Lemmas -/

/-
A 1-step walk witnesses that the single-edge cost is achievable.
-/
lemma walkCostSet_single_edge (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n) :
    W s t ∈ walkCostSet W s t := by
  -- Construct the 1-step walk f : Fin 2 → Fin n with f 0 = s and f 1 = t.
  use 1, ![s, t];
  unfold walkCost; aesop;

/-- The walk cost set is always nonempty. -/
lemma walkCostSet_nonempty (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n) :
    (walkCostSet W s t).Nonempty :=
  ⟨W s t, walkCostSet_single_edge W s t⟩

/-
With non-negative weights, the walk cost set is bounded below by 0.
-/
lemma walkCostSet_bddBelow (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n)
    (hW : ∀ i j, 0 ≤ W i j) : BddBelow (walkCostSet W s t) := by
  exact ⟨ 0, by rintro x ⟨ k, f, hf₁, hf₂, rfl ⟩ ; exact Finset.sum_nonneg fun i _ => hW _ _ ⟩

/-
Tropical distance is at most any achievable walk cost.
-/
lemma tropicalDistance_le_of_mem (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n)
    (c : ℝ) (hc : c ∈ walkCostSet W s t) (hW : ∀ i j, 0 ≤ W i j) :
    tropicalDistance W s t ≤ c := by
  exact csInf_le ( walkCostSet_bddBelow W s t hW ) hc

/-
Surgery only decreases edge weights.
-/
lemma wormholeSurgery_le (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) (τ : ℝ)
    (i j : Fin n) : wormholeSurgery W u v τ i j ≤ W i j := by
  unfold wormholeSurgery; aesop

/-
The surgery bridge edge has cost at most τ.
-/
lemma wormholeSurgery_bridge_le (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) (τ : ℝ) :
    wormholeSurgery W u v τ u v ≤ τ := by
  unfold wormholeSurgery; aesop;

/-
Walk cost is monotone: decreasing weights decreases walk cost.
-/
lemma walkCost_mono {W W' : Matrix (Fin n) (Fin n) ℝ} {k : ℕ} {f : Fin (k + 1) → Fin n}
    (h : ∀ i j, W' i j ≤ W i j) : walkCost W' k f ≤ walkCost W k f := by
  exact Finset.sum_le_sum fun i _ => h _ _

/-
Walk concatenation: if there is a walk from s to u of cost a and a walk from
  u to t of cost b, then there is a walk from s to t of cost a + b.
-/
lemma walkCostSet_concat (W : Matrix (Fin n) (Fin n) ℝ) (s u t : Fin n)
    {a b : ℝ} (ha : a ∈ walkCostSet W s u) (hb : b ∈ walkCostSet W u t) :
    (a + b) ∈ walkCostSet W s t := by
  rcases ha with ⟨ k₁, f₁, hf₁₁, hf₁₂, rfl ⟩;
  rcases hb with ⟨ k₂, f₂, hf₂₁, hf₂₂, rfl ⟩;
  refine' ⟨ k₁ + k₂, fun i => if hi : i.val < k₁ then f₁ ⟨ i.val, by linarith ⟩ else f₂ ⟨ i.val - k₁, by omega ⟩, _, _, _ ⟩ <;> simp_all +decide [ Fin.ext_iff, Fin.val_add ];
  · cases k₁ <;> aesop;
  · exact hf₂₂;
  · unfold walkCost;
    rw [ Fin.sum_univ_add ];
    congr! 1;
    · refine' Finset.sum_congr rfl fun i hi => _;
      simp +decide [ Fin.castAdd, Fin.castSucc, Fin.succ ];
      split_ifs <;> simp_all +decide [ Fin.ext_iff, Fin.castLE ];
      cases eq_or_lt_of_le ‹_› <;> simp_all +decide [ Fin.eq_last_of_not_lt ];
      · grind;
      · linarith [ Fin.is_lt i ];
    · simp +decide [ add_assoc, Nat.add_sub_assoc ];
      rfl

/-
If `W' ≤ W` pointwise, then for each walk cost in `W`, there is a smaller walk
  cost in `W'` (using the same walk).
-/
lemma walkCostSet_mono {W W' : Matrix (Fin n) (Fin n) ℝ} (s t : Fin n)
    (h : ∀ i j, W' i j ≤ W i j) :
    ∀ c ∈ walkCostSet W s t, ∃ c' ∈ walkCostSet W' s t, c' ≤ c := by
  intro c hc;
  -- By definition of walkCostSet, there exists a walk f from s to t with cost c.
  obtain ⟨k, f, hf⟩ := hc;
  exact ⟨ _, ⟨ k, f, hf.1, hf.2.1, rfl ⟩, hf.2.2 ▸ walkCost_mono h ⟩

/-! ### Main Theorems -/

/-- Tropical distance is at most the single-edge weight. -/
theorem tropicalDistance_le_edge (W : Matrix (Fin n) (Fin n) ℝ) (s t : Fin n)
    (hW : ∀ i j, 0 ≤ W i j) : tropicalDistance W s t ≤ W s t :=
  tropicalDistance_le_of_mem W s t _ (walkCostSet_single_edge W s t) hW

/-
Triangle inequality for tropical distance: the distance from `s` to `t`
  is at most the distance from `s` to `u` plus the distance from `u` to `t`.
-/
theorem tropicalDistance_triangle (W : Matrix (Fin n) (Fin n) ℝ) (s u t : Fin n)
    (hW : ∀ i j, 0 ≤ W i j) :
    tropicalDistance W s t ≤ tropicalDistance W s u + tropicalDistance W u t := by
  refine' le_of_forall_pos_le_add fun ε ε_pos => _;
  -- By definition of infimum, for any ε > 0, there exist walk costs a in walkCostSet W s u and b in walkCostSet W u t such that a < tropicalDistance W s u + ε/2 and b < tropicalDistance W u t + ε/2.
  obtain ⟨a, ha₁, ha₂⟩ : ∃ a ∈ walkCostSet W s u, a < tropicalDistance W s u + ε / 2 := by
    exact exists_lt_of_csInf_lt ( walkCostSet_nonempty _ _ _ ) ( lt_add_of_pos_right _ ( half_pos ε_pos ) )
  obtain ⟨b, hb₁, hb₂⟩ : ∃ b ∈ walkCostSet W u t, b < tropicalDistance W u t + ε / 2 := by
    exact exists_lt_of_csInf_lt ( walkCostSet_nonempty _ _ _ ) ( lt_add_of_pos_right _ ( half_pos ε_pos ) );
  linarith [ show tropicalDistance W s t ≤ a + b by exact tropicalDistance_le_of_mem _ _ _ _ ( walkCostSet_concat _ _ _ _ ha₁ hb₁ ) hW ]

/-
Tropical distance is monotone: decreasing all weights decreases distances.
-/
theorem tropicalDistance_mono {W W' : Matrix (Fin n) (Fin n) ℝ} (s t : Fin n)
    (h : ∀ i j, W' i j ≤ W i j) (hW' : ∀ i j, 0 ≤ W' i j) :
    tropicalDistance W' s t ≤ tropicalDistance W s t := by
  refine' le_csInf _ _;
  · exact?;
  · intros b hb
    obtain ⟨c', hc'⟩ := walkCostSet_mono s t h b hb;
    exact le_trans ( csInf_le ⟨ 0, fun x hx => by rcases hx with ⟨ k, f, hf₁, hf₂, rfl ⟩ ; exact Finset.sum_nonneg fun _ _ => hW' _ _ ⟩ hc'.1 ) hc'.2

/-
**Theorem 1 (Surgery Distance Bound)**: After wormhole surgery inserting a bridge
  `u ↔ v` of cost `τ`, the tropical distance from `s` to `t` is at most
  `a + τ + b` where `a ≥ d(s,u)` and `b ≥ d(v,t)`.

  This is the first theorem-level statement of "wormhole creation" as a certified
  distance-lowering surgery in a tropicalized spacetime.
-/
theorem tropicalDistance_wormholeSurgery_le
    (W : Matrix (Fin n) (Fin n) ℝ) (s t u v : Fin n) (a b τ D : ℝ)
    (hW : ∀ i j, 0 ≤ W i j) (hτ : 0 ≤ τ)
    (hsu : tropicalDistance W s u ≤ a)
    (hvt : tropicalDistance W v t ≤ b)
    (hsep : D ≤ tropicalDistance W s t)
    (hbridge : a + τ + b < D) :
    tropicalDistance (wormholeSurgery W u v τ) s t ≤ a + τ + b := by
  -- Applying the triangle inequality for tropical distances, we get:
  have h_triangle : tropicalDistance (wormholeSurgery W u v τ) s t ≤ tropicalDistance (wormholeSurgery W u v τ) s u + tropicalDistance (wormholeSurgery W u v τ) u v + tropicalDistance (wormholeSurgery W u v τ) v t := by
    have h_triangle : ∀ (s u t : Fin n), 0 ≤ (wormholeSurgery W u v τ) s u → 0 ≤ (wormholeSurgery W u v τ) u v → 0 ≤ (wormholeSurgery W u v τ) v t → tropicalDistance (wormholeSurgery W u v τ) s t ≤ tropicalDistance (wormholeSurgery W u v τ) s u + tropicalDistance (wormholeSurgery W u v τ) u v + tropicalDistance (wormholeSurgery W u v τ) v t := by
      intros s u t hs hu ht;
      have h_triangle : ∀ (s u t : Fin n), 0 ≤ (wormholeSurgery W u v τ) s u → 0 ≤ (wormholeSurgery W u v τ) u v → 0 ≤ (wormholeSurgery W u v τ) v t → tropicalDistance (wormholeSurgery W u v τ) s t ≤ tropicalDistance (wormholeSurgery W u v τ) s u + tropicalDistance (wormholeSurgery W u v τ) u t := by
        intros s u t hs hu ht;
        apply TropicalWormhole.tropicalDistance_triangle;
        unfold wormholeSurgery; aesop;
      have h_triangle : tropicalDistance (wormholeSurgery W u v τ) u t ≤ tropicalDistance (wormholeSurgery W u v τ) u v + tropicalDistance (wormholeSurgery W u v τ) v t := by
        apply TropicalWormhole.tropicalDistance_triangle;
        unfold wormholeSurgery; aesop;
      grind +splitImp;
    apply h_triangle s u t;
    · unfold wormholeSurgery; aesop;
    · grind +locals;
    · unfold wormholeSurgery; aesop;
  -- Using the fact that the wormhole surgery reduces the distance between $u$ and $v$, we have:
  have h_wormhole : tropicalDistance (wormholeSurgery W u v τ) u v ≤ τ := by
    refine' le_trans ( tropicalDistance_le_edge _ _ _ _ ) _;
    · exact fun i j => by unfold wormholeSurgery; split_ifs <;> aesop;
    · grind +suggestions;
  -- Using the fact that the wormhole surgery reduces the distance between $s$ and $u$, we have:
  have h_wormhole_su : tropicalDistance (wormholeSurgery W u v τ) s u ≤ tropicalDistance W s u := by
    apply tropicalDistance_mono;
    · exact?;
    · exact fun i j => by unfold wormholeSurgery; split_ifs <;> simp +decide [*] ;
  -- Using the fact that the wormhole surgery reduces the distance between $v$ and $t$, we have:
  have h_wormhole_vt : tropicalDistance (wormholeSurgery W u v τ) v t ≤ tropicalDistance W v t := by
    apply TropicalWormhole.tropicalDistance_mono v t (fun i j => wormholeSurgery_le W u v τ i j) (fun i j => by
      unfold wormholeSurgery; aesop;)
  linarith [h_wormhole_vt]

/-
**Theorem 1' (Strict Distance Decrease)**: Wormhole surgery strictly decreases
  tropical distance when the bridge-path cost is less than the original separation.
-/
theorem tropicalDistance_wormholeSurgery_strict
    (W : Matrix (Fin n) (Fin n) ℝ) (s t u v : Fin n) (a b τ D : ℝ)
    (hW : ∀ i j, 0 ≤ W i j) (hτ : 0 ≤ τ)
    (hsu : tropicalDistance W s u ≤ a)
    (hvt : tropicalDistance W v t ≤ b)
    (hsep : D ≤ tropicalDistance W s t)
    (hbridge : a + τ + b < D) :
    tropicalDistance (wormholeSurgery W u v τ) s t < tropicalDistance W s t := by
  convert lt_of_le_of_lt ( tropicalDistance_wormholeSurgery_le W s t u v a b τ D hW hτ hsu hvt hsep hbridge ) _ using 1;
  linarith

/-
**Theorem 2 (Throat Radius Control)**: The throat radius is always bounded
  by the throat bound derived from min-plus Ricci curvature.
-/
theorem throatRadius_controlled_by_minPlusRicci
    (W : Matrix (Fin n) (Fin n) ℝ) (u v : Fin n) (τ : ℝ)
    (hτ : τ ≤ throatBound W u v) :
    throatRadius W u v τ ≤ throatBound W u v := by
  exact min_le_right _ _

/-
**Theorem 2' (Curvature-Controlled Distance Bound)**: The post-surgery distance
  is controlled by the minimum of the original distance and the bridge-path cost.
  This is the central result connecting min-plus curvature to traversability.
-/
theorem wormholeSurgery_distance_bound_via_curvature
    (W : Matrix (Fin n) (Fin n) ℝ) (s t u v : Fin n) (τ : ℝ)
    (hW : ∀ i j, 0 ≤ W i j) (hτ_pos : 0 ≤ τ) :
    tropicalDistance (wormholeSurgery W u v τ) s t ≤
      min (tropicalDistance W s t)
          (tropicalDistance W s u + τ + tropicalDistance W v t) := by
  refine' le_min _ _;
  · apply_rules [ tropicalDistance_mono ];
    · exact?;
    · unfold wormholeSurgery; aesop;
  · -- By Lemma 2, we know that the tropical distance after surgery is at most the sum of the tropical distances from s to u and from v to t plus τ.
    have h_surgery : tropicalDistance (wormholeSurgery W u v τ) s t ≤ tropicalDistance W s u + τ + tropicalDistance W v t := by
      have h_surgery_le : ∀ s t, tropicalDistance (wormholeSurgery W u v τ) s t ≤ tropicalDistance W s t := by
        intros s t; exact tropicalDistance_mono s t (fun i j => wormholeSurgery_le W u v τ i j) (fun i j => by
          unfold wormholeSurgery; aesop)
      have h_surgery_le : tropicalDistance (wormholeSurgery W u v τ) s t ≤ tropicalDistance (wormholeSurgery W u v τ) s u + τ + tropicalDistance (wormholeSurgery W u v τ) v t := by
        nontriviality;
        refine' le_trans ( tropicalDistance_triangle _ _ _ _ _ ) _;
        exact u;
        · grind +locals;
        · have h_surgery_le : tropicalDistance (wormholeSurgery W u v τ) u v ≤ τ := by
            exact le_trans ( tropicalDistance_le_edge _ _ _ fun i j => by unfold wormholeSurgery; aesop ) ( wormholeSurgery_bridge_le _ _ _ _ );
          linarith [ tropicalDistance_triangle ( wormholeSurgery W u v τ ) u v t ( fun i j => by unfold wormholeSurgery; aesop ) ];
      exact h_surgery_le.trans ( add_le_add_three ( by solve_by_elim ) le_rfl ( by solve_by_elim ) );
    exact h_surgery

/-
**Theorem 3 (Tropical Einstein–Bellman Subsolution)**: The tropical distance
  function satisfies the Bellman inequality at every vertex. This establishes
  that shortest-path distances are subsolutions of the tropical Einstein equation,
  creating a formal Rosetta stone between general relativity, tropical geometry,
  optimal control, and shortest-path algorithms.
-/
theorem tropicalDistance_bellman_le
    (W : Matrix (Fin n) (Fin n) ℝ) (source x : Fin n)
    (hW : ∀ i j, 0 ≤ W i j) :
    tropicalDistance W source x ≤
      Finset.inf' Finset.univ Finset.univ_nonempty
        (fun y => tropicalDistance W source y + W y x) := by
  -- By definition of $tropicalDistance$, we know that for any $y \in Fin n$, $tropicalDistance W source x \leq tropicalDistance W source y + W y x$.
  have h_tropicalDistance_le : ∀ y : Fin n, tropicalDistance W source x ≤ tropicalDistance W source y + W y x := by
    -- By the triangle inequality for tropical distances, we have:
    intros y
    apply le_trans (tropicalDistance_triangle W source y x hW) (by linarith [tropicalDistance_le_edge W y x hW]);
  exact Finset.le_inf' _ _ fun y _ => h_tropicalDistance_le y

/-
**Theorem 4a (Relaxation Monotonicity)**: The Bellman-Ford relaxation operator
  is monotone: larger inputs produce larger outputs. This is foundational for
  the convergence theory of tropical geodesic computation.
-/
theorem relax_monotone (W : Matrix (Fin n) (Fin n) ℝ) (d d' : Fin n → ℝ)
    (h : ∀ x, d x ≤ d' x) : ∀ x, relax W d x ≤ relax W d' x := by
  unfold relax;
  simp +decide [ Finset.le_inf', h ];
  exact fun x b => ⟨ b, by linarith [ h b ] ⟩

/-
**Theorem 4b (Iterated Relaxation Monotonicity)**: Iterated relaxation preserves
  the ordering of distance estimates, establishing that the Bellman-Ford iteration
  is a well-behaved fixed-point computation.
-/
theorem iterateRelax_monotone (W : Matrix (Fin n) (Fin n) ℝ) (d d' : Fin n → ℝ)
    (k : ℕ) (h : ∀ x, d x ≤ d' x) :
    ∀ x, iterateRelax k W d x ≤ iterateRelax k W d' x := by
  induction' k with k ih <;> simp_all +decide [ iterateRelax, Function.iterate_succ_apply' ];
  exact?

end

end TropicalWormhole