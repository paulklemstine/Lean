/-
# Perfect and unique response Roman domination of the complete bipartite graph

This file computes exactly the two "uniqueness flavoured" Roman-type domination
parameters of the complete bipartite graph `K_{m,n}` for all `m, n ≥ 1`:

```
γ_p(K_{m,n}) = min 4 (min (m+1) (n+1))     (perfect Roman domination)
u  (K_{m,n}) = min (m+1) (n+1)             (unique response Roman domination)
```

The perfect Roman value coincides with the ordinary Roman domination number
`γ_R(K_{m,n})`, computed in `Geometry.RomanDomination.ConvexBipartite`: the lower
bound is inherited from `γ_R ≤ γ_p`, and the three optimal Roman dominating
functions of `K_{m,n}` happen to be *perfect*.

The unique response value is genuinely different, and is *not* bounded by `4`: a
vertex labelled `2` in a complete bipartite graph forbids every vertex on the
opposite side from carrying a positive label, so one whole side must be labelled
`0` and the other side must avoid `0` entirely.  Consequently the gap
`u(K_{m,n}) - γ_p(K_{m,n}) = min m n - 3` is unbounded.
-/

import Mathlib
import Geometry.RomanDomination.Variants
import Geometry.RomanDomination.ConvexBipartite

namespace RomanDomination

open Finset

/-! ### Lower-bound helpers for `γ_p` and `u` -/

section LowerBoundHelpers

variable {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- Lower bounds on `γ_p` are proved by bounding the weight of every perfect Roman
dominating function. -/
lemma le_gammaPR {k : ℕ} (h : ∀ f : V → ℕ, IsPRDF G f → k ≤ weight f) : k ≤ gammaPR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaPR G
  exact hw ▸ h f hf

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- Lower bounds on `u` are proved by bounding the weight of every unique response
Roman dominating function. -/
lemma le_gammaUR {k : ℕ} (h : ∀ f : V → ℕ, IsURRDF G f → k ≤ weight f) : k ≤ gammaUR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaUR G
  exact hw ▸ h f hf

end LowerBoundHelpers

/-! ### The three optimal labellings are perfect and (partly) unique response -/

section Witnesses

variable {m n : ℕ}

/-- The corner labelling (`2` on the first vertex of each side, `0` elsewhere) is a
*perfect* Roman dominating function of `K_{m,n}`. -/
lemma isPRDF_cornerTwo (hm : 1 ≤ m) (hn : 1 ≤ n) : IsPRDF (K m n) (cornerTwo m n) := by
  constructor
  · intro v
    cases v <;> (simp [cornerTwo]; try (split_ifs <;> norm_num))
  · intro v _
    cases v with
    | inl i =>
      refine ⟨Sum.inr ⟨0, hn⟩, ⟨K_adj_inl_inr i _, by simp [cornerTwo]⟩, ?_⟩
      rintro (u | u) ⟨hadj, hu⟩
      · exact absurd hadj (K_not_adj_inl_inl i u)
      · simp only [cornerTwo, Sum.elim_inr] at hu
        have : (u : ℕ) = 0 := by by_contra h; simp [h] at hu
        simp [Fin.ext_iff, this]
    | inr j =>
      refine ⟨Sum.inl ⟨0, hm⟩, ⟨K_adj_inr_inl j _, by simp [cornerTwo]⟩, ?_⟩
      rintro (u | u) ⟨hadj, hu⟩
      · simp only [cornerTwo, Sum.elim_inl] at hu
        have : (u : ℕ) = 0 := by by_contra h; simp [h] at hu
        simp [Fin.ext_iff, this]
      · exact absurd hadj (K_not_adj_inr_inr j u)

/-- The left-heavy labelling (`2` on the first left vertex, `1` on the other left
vertices, `0` on the right) is a *unique response* Roman dominating function of
`K_{m,n}`. -/
lemma isURRDF_leftHeavy (hm : 1 ≤ m) : IsURRDF (K m n) (leftHeavy m n) := by
  refine ⟨?_, ?_, ?_⟩
  · intro v
    cases v <;> (simp [leftHeavy]; try (split_ifs <;> norm_num))
  · intro v hv
    cases v with
    | inl i =>
      exfalso
      simp only [leftHeavy, Sum.elim_inl] at hv
      split_ifs at hv
    | inr j =>
      refine ⟨Sum.inl ⟨0, hm⟩, ⟨K_adj_inr_inl j _, by simp [leftHeavy]⟩, ?_⟩
      rintro (u | u) ⟨hadj, hu⟩
      · simp only [leftHeavy, Sum.elim_inl] at hu
        have : (u : ℕ) = 0 := by by_contra h; simp [h] at hu
        simp [Fin.ext_iff, this]
      · exact absurd hadj (K_not_adj_inr_inr j u)
  · intro v hv u hadj
    cases v with
    | inl i =>
      cases u with
      | inl i' => exact absurd hadj (K_not_adj_inl_inl i i')
      | inr j => simp [leftHeavy]
    | inr j =>
      exfalso
      simp only [leftHeavy, Sum.elim_inr] at hv
      omega

/-- The right-heavy labelling is a unique response Roman dominating function of
`K_{m,n}`. -/
lemma isURRDF_rightHeavy (hn : 1 ≤ n) : IsURRDF (K m n) (rightHeavy m n) := by
  refine ⟨?_, ?_, ?_⟩
  · intro v
    cases v <;> (simp [rightHeavy]; try (split_ifs <;> norm_num))
  · intro v hv
    cases v with
    | inr j =>
      exfalso
      simp only [rightHeavy, Sum.elim_inr] at hv
      split_ifs at hv
    | inl i =>
      refine ⟨Sum.inr ⟨0, hn⟩, ⟨K_adj_inl_inr i _, by simp [rightHeavy]⟩, ?_⟩
      rintro (u | u) ⟨hadj, hu⟩
      · exact absurd hadj (K_not_adj_inl_inl i u)
      · simp only [rightHeavy, Sum.elim_inr] at hu
        have : (u : ℕ) = 0 := by by_contra h; simp [h] at hu
        simp [Fin.ext_iff, this]
  · intro v hv u hadj
    cases v with
    | inr j =>
      cases u with
      | inr j' => exact absurd hadj (K_not_adj_inr_inr j j')
      | inl i => simp [rightHeavy]
    | inl i =>
      exfalso
      simp only [rightHeavy, Sum.elim_inl] at hv
      omega

end Witnesses

/-! ### The perfect Roman domination number of `K_{m,n}` -/

section PerfectValue

variable {m n : ℕ}

/-- **Exact perfect Roman domination number of the complete bipartite graph.**
It coincides with the Roman domination number: the three optimal Roman dominating
functions of `K_{m,n}` are perfect. -/
theorem gammaPR_K (hm : 1 ≤ m) (hn : 1 ≤ n) :
    gammaPR (K m n) = min 4 (min (m + 1) (n + 1)) := by
  refine le_antisymm (le_min ?_ (le_min ?_ ?_)) ?_
  · exact (gammaPR_le _ (isPRDF_cornerTwo hm hn)).trans_eq (weight_cornerTwo hm hn)
  · exact (gammaPR_le _ (isPRDF_of_isURRDF _ (isURRDF_leftHeavy hm))).trans_eq
      (weight_leftHeavy hm)
  · exact (gammaPR_le _ (isPRDF_of_isURRDF _ (isURRDF_rightHeavy hn))).trans_eq
      (weight_rightHeavy hn)
  · exact (gammaR_K hm hn) ▸ gammaR_le_gammaPR (K m n)

/-- On complete bipartite graphs the perfect Roman and the ordinary Roman domination
numbers agree. -/
theorem gammaPR_K_eq_gammaR_K (hm : 1 ≤ m) (hn : 1 ≤ n) :
    gammaPR (K m n) = gammaR (K m n) := by
  rw [gammaPR_K hm hn, gammaR_K hm hn]

end PerfectValue

/-! ### The unique response Roman domination number of `K_{m,n}` -/

section UniqueValue

variable {m n : ℕ} {f : Fin m ⊕ Fin n → ℕ}

/-- In a unique response Roman dominating function of `K_{m,n}`, a left vertex
labelled `2` forces the entire right side to be labelled `0`. -/
lemma right_zero_of_left_two (hf : IsURRDF (K m n) f) {i₀ : Fin m}
    (h₀ : f (Sum.inl i₀) = 2) : ∀ j, f (Sum.inr j) = 0 := by
  intro j
  by_contra h
  exact hf.2.2 (Sum.inr j) (Nat.pos_of_ne_zero h) (Sum.inl i₀) (K_adj_inr_inl j i₀) h₀

/-- In a unique response Roman dominating function of `K_{m,n}`, a right vertex
labelled `2` forces the entire left side to be labelled `0`. -/
lemma left_zero_of_right_two (hf : IsURRDF (K m n) f) {j₀ : Fin n}
    (h₀ : f (Sum.inr j₀) = 2) : ∀ i, f (Sum.inl i) = 0 := by
  intro i
  by_contra h
  exact hf.2.2 (Sum.inl i) (Nat.pos_of_ne_zero h) (Sum.inr j₀) (K_adj_inl_inr i j₀) h₀

/-- If no right vertex is labelled `2`, no left vertex may be labelled `0`. -/
lemma left_ne_zero_of_no_right_two (hf : IsURRDF (K m n) f) (h : ∀ j, f (Sum.inr j) ≠ 2) :
    ∀ i, f (Sum.inl i) ≠ 0 := by
  intro i hi
  obtain ⟨u, ⟨hadj, hu⟩, -⟩ := hf.2.1 (Sum.inl i) hi
  match u with
  | Sum.inl i' => exact absurd hadj (K_not_adj_inl_inl i i')
  | Sum.inr j => exact h j hu

/-- If no left vertex is labelled `2`, no right vertex may be labelled `0`. -/
lemma right_ne_zero_of_no_left_two (hf : IsURRDF (K m n) f) (h : ∀ i, f (Sum.inl i) ≠ 2) :
    ∀ j, f (Sum.inr j) ≠ 0 := by
  intro j hj
  obtain ⟨u, ⟨hadj, hu⟩, -⟩ := hf.2.1 (Sum.inr j) hj
  match u with
  | Sum.inr j' => exact absurd hadj (K_not_adj_inr_inr j j')
  | Sum.inl i => exact h i hu

/-- Every unique response Roman dominating function of `K_{m,n}` has weight at least
`min (m+1) (n+1)`.  (Only `m ≥ 1` is needed.) -/
lemma min_succ_le_weight_of_isURRDF_K (hm : 1 ≤ m) (hf : IsURRDF (K m n) f) :
    min (m + 1) (n + 1) ≤ weight f := by
  rw [weight_sum_type]
  by_cases hA : ∃ i, f (Sum.inl i) = 2
  · obtain ⟨i₀, h₀⟩ := hA
    have hB0 := right_zero_of_left_two hf h₀
    have hAne : ∀ i, f (Sum.inl i) ≠ 0 :=
      left_ne_zero_of_no_right_two hf (fun j => by rw [hB0 j]; omega)
    have := m_succ_le_left_sum hAne h₀
    omega
  · push_neg at hA
    by_cases hB : ∃ j, f (Sum.inr j) = 2
    · obtain ⟨j₀, h₀⟩ := hB
      have hA0 := left_zero_of_right_two hf h₀
      have hBne : ∀ j, f (Sum.inr j) ≠ 0 :=
        right_ne_zero_of_no_left_two hf (fun i => by rw [hA0 i]; omega)
      have := n_succ_le_right_sum hBne h₀
      omega
    · push_neg at hB
      have h1 := m_le_left_sum (left_ne_zero_of_no_right_two hf hB)
      have h2 := n_le_right_sum (right_ne_zero_of_no_left_two hf hA)
      omega

/-- **Exact unique response Roman domination number of the complete bipartite graph.**
Unlike `γ_R` and `γ_p`, this parameter is unbounded on complete bipartite graphs. -/
theorem gammaUR_K (hm : 1 ≤ m) (hn : 1 ≤ n) :
    gammaUR (K m n) = min (m + 1) (n + 1) := by
  refine le_antisymm (le_min ?_ ?_)
    (le_gammaUR _ fun f hf => min_succ_le_weight_of_isURRDF_K hm hf)
  · exact (gammaUR_le _ (isURRDF_leftHeavy hm)).trans_eq (weight_leftHeavy hm)
  · exact (gammaUR_le _ (isURRDF_rightHeavy hn)).trans_eq (weight_rightHeavy hn)

/-- The gap between the unique response and the perfect Roman domination numbers is
unbounded on complete bipartite graphs: for `m, n ≥ 3` the perfect value is `4`
while the unique response value is `min m n + 1`. -/
theorem gammaUR_sub_gammaPR_K (hm : 3 ≤ m) (hn : 3 ≤ n) :
    gammaPR (K m n) = 4 ∧ gammaUR (K m n) = min m n + 1 ∧
      gammaUR (K m n) - gammaPR (K m n) = min m n - 3 := by
  have h1 : gammaPR (K m n) = 4 := by
    rw [gammaPR_K (by omega) (by omega)]
    omega
  have h2 : gammaUR (K m n) = min m n + 1 := by
    rw [gammaUR_K (by omega) (by omega)]
    omega
  exact ⟨h1, h2, by omega⟩

end UniqueValue

end RomanDomination