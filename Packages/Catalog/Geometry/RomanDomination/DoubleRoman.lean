/-
# The double Roman domination number of the complete bipartite graph

This file computes `γ_dR(K_{m,n})` exactly for all `m, n ≥ 1`.  Writing
`k = min m n`, the answer is

```
γ_dR(K_{m,n}) = 3   if k = 1,
              = 4   if k = 2,
              = 6   if k ≥ 3.
```

Note that this is *not* of the shape `min 6 (k + 2)`: the value jumps from `4`
to `6`, skipping `5`.

The lower bounds are obtained from the local conditions defining a double Roman
dominating function, applied to a `0`-labelled vertex on each side; the upper
bounds come from three explicit labellings (`3` on the unique left vertex,
`2` on both left vertices, and `3` on one vertex of each side).

Along the way we prove the general bound `3 ≤ γ_dR(G)` for every graph with at
least two vertices.
-/

import Mathlib
import Geometry.RomanDomination.Variants
import Geometry.RomanDomination.ConvexBipartite

namespace RomanDomination

open Finset

/-! ### General weight plumbing -/

section Plumbing

variable {α : Type*} [Fintype α] [DecidableEq α] {g : α → ℕ}

/-- Two distinct values bound the sum from below. -/
lemma pair_le_sum {a b : α} (hab : a ≠ b) : g a + g b ≤ ∑ x, g x := by
  rw [← Finset.sum_pair hab]
  exact Finset.sum_le_sum_of_subset (Finset.subset_univ _)

/-- If every value is at least one and one value is at least three, the sum is at
least `card + 2`. -/
lemma card_add_two_le_sum_of_one_le_of_three (h : ∀ a, 1 ≤ g a) {a₀ : α} (h₀ : 3 ≤ g a₀) :
    Fintype.card α + 2 ≤ ∑ a, g a := by
  have hbase : Fintype.card α = ∑ _a : α, 1 := by simp
  have heq : ∑ a : α, (1 + if a = a₀ then 2 else 0) = ∑ _a : α, 1 + 2 := by
    simp [Finset.sum_add_distrib]
  rw [hbase, ← heq]
  apply Finset.sum_le_sum
  intro a _
  split_ifs with ha
  · simp [ha]; linarith [h a₀]
  · simp; linarith [h a]

omit [DecidableEq α] in
/-- If every value is at least two, the sum is at least twice the cardinality. -/
lemma two_mul_card_le_sum (h : ∀ a, 2 ≤ g a) : 2 * Fintype.card α ≤ ∑ a, g a := by
  calc 2 * Fintype.card α = ∑ _a : α, 2 := by simp [mul_comm]
    _ ≤ ∑ a, g a := Finset.sum_le_sum fun a _ => h a

end Plumbing

/-! ### The general lower bound `3 ≤ γ_dR(G)` -/

section GeneralLower

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- A single value bounds the weight from below. -/
lemma le_weight_single (f : V → ℕ) (v : V) : f v ≤ weight f :=
  Finset.single_le_sum (f := f) (fun _ _ => Nat.zero_le _) (Finset.mem_univ v)

omit [DecidableRel G.Adj] in
/-- Two distinct values bound the weight from below. -/
lemma pair_le_weight (f : V → ℕ) {u v : V} (h : u ≠ v) : f u + f v ≤ weight f :=
  pair_le_sum h

omit [DecidableRel G.Adj] in
/-- On a graph with at least two vertices, every double Roman dominating function has
weight at least `3`. -/
lemma three_le_weight_of_isDRDF (hV : 2 ≤ Fintype.card V) {f : V → ℕ} (hf : IsDRDF G f) :
    3 ≤ weight f := by
  have hbound := hf.1
  by_cases hex : ∃ v, f v ≥ 3
  · obtain ⟨v, hv⟩ := hex; exact le_trans hv (le_weight_single f v)
  · push_neg at hex
    -- All values are 0, 1, or 2
    have h0 := hf.2.1
    have h1 := hf.2.2
    by_cases hzero : ∃ v, f v = 0
    · -- There's a 0-vertex, which needs two ≥2 neighbours
      obtain ⟨v, hv⟩ := hzero
      have := h0 v hv
      rcases this with ⟨u, _, hu⟩ | ⟨u, w, hne, huv, hvw, hu, hw⟩
      · linarith [hex u]
      · exact le_trans (by omega : 3 ≤ f u + f w) (pair_le_weight f hne)
    · -- No vertex is labelled 0, so all are 1 or 2
      push_neg at hzero
      by_cases hone : ∃ v, f v = 1
      · -- There's a 1-vertex, which needs a ≥2 neighbour
        obtain ⟨v, hv⟩ := hone
        obtain ⟨u, huv, hu⟩ := h1 v hv
        -- v and u are distinct (adjacent), f v = 1, f u ≥ 2
        have hu_ne_v : u ≠ v := huv.ne.symm
        exact le_trans (by omega : 3 ≤ f u + f v) (pair_le_weight f hu_ne_v)
      · -- All vertices are labelled 2
        push_neg at hone
        -- All values are exactly 2
        have hall : ∀ v, f v = 2 := fun v => by have := hex v; have := hzero v; have := hone v; omega
        have : weight f = 2 * Fintype.card V := by simp [weight, hall]; ring
        linarith

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- Lower bounds on `γ_dR` are proved by bounding the weight of every double Roman
dominating function. -/
lemma le_gammaDR {k : ℕ} (h : ∀ f : V → ℕ, IsDRDF G f → k ≤ weight f) : k ≤ gammaDR G := by
  obtain ⟨f, hf, hw⟩ := exists_gammaDR G
  exact hw ▸ h f hf

omit [DecidableRel G.Adj] in
/-- **`γ_dR(G) ≥ 3`** for every graph with at least two vertices. -/
theorem three_le_gammaDR (hV : 2 ≤ Fintype.card V) : 3 ≤ gammaDR G :=
  le_gammaDR fun _ hf => three_le_weight_of_isDRDF hV hf

end GeneralLower

/-! ### Local consequences of the double Roman conditions on `K_{m,n}` -/

section KLocal

variable {m n : ℕ} {f : Fin m ⊕ Fin n → ℕ}

/-- A `0` on the left forces either a `3` on the right or right weight at least `4`. -/
lemma right_three_or_four_of_left_zero (hf : IsDRDF (K m n) f) {i : Fin m}
    (h0 : f (Sum.inl i) = 0) :
    (∃ j, f (Sum.inr j) = 3) ∨ 4 ≤ ∑ j, f (Sum.inr j) := by
  have hcond := hf.2.1 _ h0
  obtain h3 | ⟨u, w, hne, hu, hw, hu2, hw2⟩ := hcond
  · -- Case: there exists an adjacent vertex with value 3
    obtain ⟨u, hu, hu3⟩ := h3
    cases u with
    | inl u => exact absurd hu (K_not_adj_inl_inl i u)
    | inr j => exact Or.inl ⟨j, hu3⟩
  · -- Case: two distinct adjacent vertices with value ≥ 2
    cases u with
    | inl u => exact absurd hu (K_not_adj_inl_inl i u)
    | inr j =>
      cases w with
      | inl w => exact absurd hw (K_not_adj_inl_inl i w)
      | inr k =>
        right
        have hjk : j ≠ k := Sum.inr_injective.ne_iff.mp hne
        calc 4 = 2 + 2 := by norm_num
          _ ≤ f (Sum.inr j) + f (Sum.inr k) := by linarith
          _ ≤ ∑ l ∈ {j, k}, f (Sum.inr l) := by rw [Finset.sum_pair hjk]
          _ ≤ ∑ l, f (Sum.inr l) := Finset.sum_le_sum_of_subset (Finset.subset_univ _)

/-- A `0` on the right forces either a `3` on the left or left weight at least `4`. -/
lemma left_three_or_four_of_right_zero (hf : IsDRDF (K m n) f) {j : Fin n}
    (h0 : f (Sum.inr j) = 0) :
    (∃ i, f (Sum.inl i) = 3) ∨ 4 ≤ ∑ i, f (Sum.inl i) := by
  obtain h3 | ⟨u, w, hne, hu, hw, hu2, hw2⟩ := hf.2.1 _ h0
  · obtain ⟨u, hu, hu3⟩ := h3
    cases u with
    | inl i => exact Or.inl ⟨i, hu3⟩
    | inr k => exact absurd hu (K_not_adj_inr_inr j k)
  · cases u with
    | inl i =>
      cases w with
      | inl k =>
        right
        have hik : i ≠ k := Sum.inl_injective.ne_iff.mp hne
        calc 4 = 2 + 2 := by norm_num
          _ ≤ f (Sum.inl i) + f (Sum.inl k) := by omega
          _ ≤ ∑ l, f (Sum.inl l) := pair_le_sum (g := fun l => f (Sum.inl l)) hik
      | inr w => exact absurd hw (K_not_adj_inr_inr j w)
    | inr u => exact absurd hu (K_not_adj_inr_inr j u)

/-- A `0` on the left forces right weight at least `3`. -/
lemma three_le_right_sum_of_left_zero (hf : IsDRDF (K m n) f) {i : Fin m}
    (h0 : f (Sum.inl i) = 0) : 3 ≤ ∑ j, f (Sum.inr j) := by
  rcases right_three_or_four_of_left_zero hf h0 with ⟨j, hj⟩ | hsum
  · exact hj ▸ Finset.single_le_sum (f := fun j => f (Sum.inr j))
      (fun _ _ => Nat.zero_le _) (Finset.mem_univ j)
  · omega

/-- A `0` on the right forces left weight at least `3`. -/
lemma three_le_left_sum_of_right_zero (hf : IsDRDF (K m n) f) {j : Fin n}
    (h0 : f (Sum.inr j) = 0) : 3 ≤ ∑ i, f (Sum.inl i) := by
  rcases left_three_or_four_of_right_zero hf h0 with ⟨i, hi⟩ | hsum
  · exact hi ▸ Finset.single_le_sum (f := fun i => f (Sum.inl i))
      (fun _ _ => Nat.zero_le _) (Finset.mem_univ i)
  · omega

/-- A `1` on the left forces right weight at least `2`. -/
lemma two_le_right_sum_of_left_one (hf : IsDRDF (K m n) f) {i : Fin m}
    (h1 : f (Sum.inl i) = 1) : 2 ≤ ∑ j, f (Sum.inr j) := by
  obtain ⟨u, hadj, hu⟩ := hf.2.2 (Sum.inl i) h1
  rcases u with (u | j)
  · exact absurd hadj (K_not_adj_inl_inl i u)
  · exact le_trans hu
      (Finset.single_le_sum (fun j _ => Nat.zero_le (f (Sum.inr j))) (Finset.mem_univ j))

/-- A `1` on the right forces left weight at least `2`. -/
lemma two_le_left_sum_of_right_one (hf : IsDRDF (K m n) f) {j : Fin n}
    (h1 : f (Sum.inr j) = 1) : 2 ≤ ∑ i, f (Sum.inl i) := by
  obtain ⟨u, hadj, hu⟩ := hf.2.2 (Sum.inr j) h1
  rcases u with u | u
  · exact le_trans hu (Finset.single_le_sum (f := fun i => f (Sum.inl i)) (fun _ _ => Nat.zero_le _) (Finset.mem_univ u))
  · exact False.elim (K_not_adj_inr_inr j u hadj)

/-- If the left weight is smaller than `m`, some left vertex is labelled `0`. -/
lemma exists_left_zero_of_sum_lt (h : ∑ i, f (Sum.inl i) < m) : ∃ i, f (Sum.inl i) = 0 := by
  by_contra hc
  push_neg at hc
  have := m_le_left_sum hc
  omega

/-- If the right weight is smaller than `n`, some right vertex is labelled `0`. -/
lemma exists_right_zero_of_sum_lt (h : ∑ j, f (Sum.inr j) < n) : ∃ j, f (Sum.inr j) = 0 := by
  by_contra hc
  push_neg at hc
  have := n_le_right_sum hc
  omega

/-- If no left vertex is labelled `0` and some left vertex is labelled `3`, the left
weight is at least `m + 2`. -/
lemma left_sum_ge_of_three (h : ∀ i, f (Sum.inl i) ≠ 0) {i₀ : Fin m} (h₀ : f (Sum.inl i₀) = 3) :
    m + 2 ≤ ∑ i, f (Sum.inl i) := by
  have h1 : ∀ i, 1 ≤ f (Sum.inl i) := fun i => Nat.one_le_iff_ne_zero.mpr (h i)
  have := card_add_two_le_sum_of_one_le_of_three h1 (by rw [h₀])
  rwa [Fintype.card_fin] at this

/-- If no right vertex is labelled `0` and some right vertex is labelled `3`, the right
weight is at least `n + 2`. -/
lemma right_sum_ge_of_three (h : ∀ j, f (Sum.inr j) ≠ 0) {j₀ : Fin n} (h₀ : f (Sum.inr j₀) = 3) :
    n + 2 ≤ ∑ j, f (Sum.inr j) := by
  have h1 : ∀ j, 1 ≤ f (Sum.inr j) := fun j => Nat.one_le_iff_ne_zero.mpr (h j)
  have := card_add_two_le_sum_of_one_le_of_three h1 (by rw [h₀])
  rwa [Fintype.card_fin] at this

/-- If every left vertex is labelled at least `2`, the left weight is at least `2m`. -/
lemma two_mul_le_left_sum (h : ∀ i, 2 ≤ f (Sum.inl i)) : 2 * m ≤ ∑ i, f (Sum.inl i) := by
  have := two_mul_card_le_sum (g := fun i : Fin m => f (Sum.inl i)) h
  rwa [Fintype.card_fin] at this

/-- If every right vertex is labelled at least `2`, the right weight is at least `2n`. -/
lemma two_mul_le_right_sum (h : ∀ j, 2 ≤ f (Sum.inr j)) : 2 * n ≤ ∑ j, f (Sum.inr j) := by
  have := two_mul_card_le_sum (g := fun j : Fin n => f (Sum.inr j)) h
  rwa [Fintype.card_fin] at this

end KLocal

/-! ### Explicit double Roman dominating functions of `K_{m,n}` -/

section Constructions

variable {m n : ℕ}

/-- `3` on the unique left vertex, `0` on the right. -/
def leftThree (n : ℕ) : Fin 1 ⊕ Fin n → ℕ := Sum.elim (fun _ => 3) (fun _ => 0)

/-- `2` on every left vertex, `0` on the right. -/
def leftTwos (m n : ℕ) : Fin m ⊕ Fin n → ℕ := Sum.elim (fun _ => 2) (fun _ => 0)

/-- `3` on the first vertex of each side, `0` elsewhere. -/
def cornerThree (m n : ℕ) : Fin m ⊕ Fin n → ℕ :=
  Sum.elim (fun i => if i.val = 0 then 3 else 0) (fun j => if j.val = 0 then 3 else 0)

lemma weight_leftThree : weight (leftThree n) = 3 := by
  simp [weight_sum_type, leftThree]

lemma weight_leftTwos : weight (leftTwos m n) = 2 * m := by
  simp [weight_sum_type, leftTwos, mul_comm]

lemma weight_cornerThree (hm : 1 ≤ m) (hn : 1 ≤ n) : weight (cornerThree m n) = 6 := by
  simp [weight_sum_type, cornerThree]
  have hleft : ∑ i : Fin m, (if i.val = 0 then 3 else 0) = 3 := by
    rw [Finset.sum_eq_single ⟨0, hm⟩] <;> simp [Fin.ext_iff]
  have hright : ∑ j : Fin n, (if j.val = 0 then 3 else 0) = 3 := by
    rw [Finset.sum_eq_single ⟨0, hn⟩] <;> simp [Fin.ext_iff]
  omega

lemma isDRDF_leftThree : IsDRDF (K 1 n) (leftThree n) := by
  refine ⟨fun v => by cases v <;> simp [leftThree], fun v h0 => ?_, fun v h1 => ?_⟩
  · cases v with
    | inl i => simp [leftThree] at h0
    | inr j =>
      exact Or.inl ⟨Sum.inl ⟨0, by norm_num⟩, K_adj_inr_inl j ⟨0, by norm_num⟩,
        by simp [leftThree]⟩
  · cases v with
    | inl i => simp [leftThree] at h1
    | inr j => simp [leftThree] at h1

lemma isDRDF_leftTwos (hm : 2 ≤ m) : IsDRDF (K m n) (leftTwos m n) := by
  refine ⟨fun v => by cases v <;> simp [leftTwos], fun v h0 => ?_, fun v h1 => ?_⟩
  · cases v with
    | inl i => simp [leftTwos] at h0
    | inr j =>
      refine Or.inr ⟨Sum.inl ⟨0, by omega⟩, Sum.inl ⟨1, by omega⟩, by simp,
        K_adj_inr_inl j ⟨0, by omega⟩, K_adj_inr_inl j ⟨1, by omega⟩, le_rfl, le_rfl⟩
  · cases v with
    | inl i => simp [leftTwos] at h1
    | inr j => simp [leftTwos] at h1

lemma isDRDF_cornerThree (hm : 1 ≤ m) (hn : 1 ≤ n) : IsDRDF (K m n) (cornerThree m n) := by
  refine ⟨fun v => by cases v <;> simp [cornerThree] <;> split_ifs <;> norm_num,
    fun v _ => ?_, fun v h1 => ?_⟩
  · cases v with
    | inl i => exact Or.inl ⟨Sum.inr ⟨0, hn⟩, K_adj_inl_inr i ⟨0, hn⟩, by simp [cornerThree]⟩
    | inr j => exact Or.inl ⟨Sum.inl ⟨0, hm⟩, K_adj_inr_inl j ⟨0, hm⟩, by simp [cornerThree]⟩
  · cases v with
    | inl i => simp [cornerThree] at h1; (split_ifs at h1; omega)
    | inr j => simp [cornerThree] at h1; (split_ifs at h1; omega)

end Constructions

/-! ### Lower bounds for `K_{m,n}` -/

section KLower

variable {m n : ℕ} {f : Fin m ⊕ Fin n → ℕ}

/-- If both sides have at least two vertices, every double Roman dominating function of
`K_{m,n}` has weight at least `4`. -/
lemma four_le_weight_of_isDRDF_K (hm : 2 ≤ m) (hn : 2 ≤ n) (hf : IsDRDF (K m n) f) :
    4 ≤ weight f := by
  rw [weight_sum_type]
  by_cases hleft : ∃ i, f (Sum.inl i) = 0
  · obtain ⟨i, hi⟩ := hleft
    have hright := three_le_right_sum_of_left_zero hf hi
    by_cases hright : ∃ j, f (Sum.inr j) = 0
    · obtain ⟨j, hj⟩ := hright
      have hleft' := three_le_left_sum_of_right_zero hf hj
      omega
    · push_neg at hright
      -- All right values ≥ 1
      -- By DRDF at inl i = 0, we need a 3 on the right or two ≥2 on the right
      have hcond := hf.2.1 (Sum.inl i) hi
      rcases hcond with ⟨u, hadj, hu⟩ | ⟨u, w, hne, hu, hw, hu2, hw2⟩
      · -- Case: there's a 3 on the right
        cases u with
        | inl u => exact absurd hadj (K_not_adj_inl_inl i u)
        | inr j =>
          -- Since f(inr j) = 3 and all other right vertices ≥ 1, right_sum ≥ 3 + (n-1) ≥ 4
          have hright_sum_ge : ∑ k, f (Sum.inr k) = f (Sum.inr j) + ∑ k ∈ Finset.erase Finset.univ j, f (Sum.inr k) := by
            rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
          have hcard : (Finset.erase Finset.univ j : Finset (Fin n)).card = n - 1 := by simp
          have hother : ∑ k ∈ Finset.erase Finset.univ j, f (Sum.inr k) ≥ n - 1 := by
            have hle : ∀ k ∈ Finset.erase Finset.univ j, 1 ≤ f (Sum.inr k) := fun k _ => Nat.one_le_iff_ne_zero.mpr (hright k)
            calc ∑ k ∈ Finset.erase Finset.univ j, f (Sum.inr k) ≥ ∑ _k ∈ Finset.erase Finset.univ j, 1 := Finset.sum_le_sum hle
              _ = (n - 1 : ℕ) := by simp
          have hright_ge_4 : ∑ k, f (Sum.inr k) ≥ 4 := by omega
          omega
      · -- Case: two right vertices with value ≥ 2
        cases u with
        | inl u => exact absurd hu (K_not_adj_inl_inl i u)
        | inr j =>
          cases w with
          | inl w => exact absurd hw (K_not_adj_inl_inl i w)
          | inr k =>
            have hjk : j ≠ k := Sum.inr_injective.ne_iff.mp hne
            have := Finset.sum_le_sum_of_subset (f := fun l => f (Sum.inr l)) (s := {j, k}) (Finset.subset_univ _)
            calc 4 ≤ f (Sum.inr j) + f (Sum.inr k) := by linarith
              _ = ∑ l ∈ {j, k}, f (Sum.inr l) := by rw [Finset.sum_pair hjk]
              _ ≤ ∑ l, f (Sum.inr l) := this
            omega
  · push_neg at hleft
    by_cases hright : ∃ j, f (Sum.inr j) = 0
    · obtain ⟨j, hj⟩ := hright
      have hleft := three_le_left_sum_of_right_zero hf hj
      -- Either some right vertex is positive, or all right vertices are 0
      -- If all right are 0, each needs a 3 on the left, so left_sum = 3m ≥ 6
      by_cases hall : ∀ k, f (Sum.inr k) = 0
      · -- All right vertices are 0
        -- If all right vertices are 0, left vertices with f = 0 or f = 1 can't be satisfied
        -- So all left vertices have f ∈ {2, 3}, giving left_sum ≥ 2m ≥ 4
        have hind : ∀ i : Fin m, f (Sum.inl i) = 2 ∨ f (Sum.inl i) = 3 := fun i => by
          have hbound := hf.1 (Sum.inl i)
          have h0_ne : f (Sum.inl i) ≠ 0 := fun h0 => by
            have h0cond := hf.2.1 (Sum.inl i) h0
            rcases h0cond with ⟨u, hadj, hu3⟩ | ⟨u, w, _, hu, hw, hu2, hw2⟩
            · cases u with
              | inl u => exact absurd hadj (K_not_adj_inl_inl i u)
              | inr k => exact absurd hu3 (by simp [hall k])
            · cases u with
              | inl u => exact absurd hu (K_not_adj_inl_inl i u)
              | inr k =>
                cases w with
                | inl w => exact absurd hw (K_not_adj_inl_inl i w)
                | inr k' => exact absurd hw2 (by simp [hall k'])
          have h1_ne : f (Sum.inl i) ≠ 1 := fun h1 => by
            have h1cond := hf.2.2 (Sum.inl i) h1
            rcases h1cond with ⟨u, hadj, hu⟩
            cases u with
            | inl u => exact absurd hadj (K_not_adj_inl_inl i u)
            | inr k => exact Nat.not_le.mpr (by simp [hall k] : f (Sum.inr k) < 2) hu
          omega
        -- All left vertices have f = 2 or f = 3, so left_sum ≥ 2m ≥ 4
        have hleft_sum : 2 * m ≤ ∑ i, f (Sum.inl i) := by
          have h : ∀ i, 2 ≤ f (Sum.inl i) := fun i => by rcases hind i with hi | hi <;> omega
          exact two_mul_le_left_sum h
        have hgoal : 4 ≤ ∑ i, f (Sum.inl i) := by omega
        exact le_add_of_le_of_nonneg hgoal (Nat.zero_le _)
      · push_neg at hall
        obtain ⟨k, hk⟩ := hall
        have hright_pos : f (Sum.inr k) ≥ 1 := Nat.one_le_iff_ne_zero.mpr hk
        have hright_sum : ∑ l, f (Sum.inr l) ≥ 1 := by
          have := Finset.single_le_sum (f := fun l => f (Sum.inr l)) (fun _ _ => Nat.zero_le _) (Finset.mem_univ k)
          linarith
        omega
    · push_neg at hright
      -- No zeros anywhere: all values ≥ 1
      have hleft_sum : ∑ i, f (Sum.inl i) ≥ m := m_le_left_sum hleft
      have hright_sum : ∑ j, f (Sum.inr j) ≥ n := n_le_right_sum hright
      omega

/-- Branch of the `6`-bound: the right weight is at most `1`. -/
lemma six_le_weight_of_right_le_one (hm : 3 ≤ m) (hf : IsDRDF (K m n) f)
    (hb : ∑ j, f (Sum.inr j) ≤ 1) : 6 ≤ weight f := by
  -- No left vertex can be 0 (would require right sum ≥ 3)
  have hno_zero : ∀ i, f (Sum.inl i) ≠ 0 := fun i h0 => by
    have := three_le_right_sum_of_left_zero hf h0
    omega
  -- No left vertex can be 1 (would require right sum ≥ 2)
  have hno_one : ∀ i, f (Sum.inl i) ≠ 1 := fun i h1 => by
    have := two_le_right_sum_of_left_one hf h1
    omega
  -- So all left vertices are ≥ 2
  have hall : ∀ i, 2 ≤ f (Sum.inl i) := fun i => by
    have huniv := hf.1 (Sum.inl i)
    have h0 := hno_zero i
    have h1 := hno_one i
    omega
  -- Left sum ≥ 2m ≥ 6
  have hleft : 2 * m ≤ ∑ i, f (Sum.inl i) := two_mul_le_left_sum hall
  rw [weight_sum_type]
  omega

/-- Branch of the `6`-bound: the left weight is at most `1`. -/
lemma six_le_weight_of_left_le_one (hn : 3 ≤ n) (hf : IsDRDF (K m n) f)
    (ha : ∑ i, f (Sum.inl i) ≤ 1) : 6 ≤ weight f := by
  -- No right vertex can be 0 (would require left sum ≥ 3)
  have hno_zero : ∀ j, f (Sum.inr j) ≠ 0 := fun j h0 => by
    have := three_le_left_sum_of_right_zero hf h0
    omega
  -- No right vertex can be 1 (would require left sum ≥ 2)
  have hno_one : ∀ j, f (Sum.inr j) ≠ 1 := fun j h1 => by
    have := two_le_left_sum_of_right_one hf h1
    omega
  -- So all right vertices are ≥ 2
  have hall : ∀ j, 2 ≤ f (Sum.inr j) := fun j => by
    have huniv := hf.1 (Sum.inr j)
    have h0 := hno_zero j
    have h1 := hno_one j
    omega
  -- Right sum ≥ 2n ≥ 6
  have hright : 2 * n ≤ ∑ j, f (Sum.inr j) := two_mul_le_right_sum hall
  rw [weight_sum_type]
  omega

/-- Branch of the `6`-bound: both side weights are at least `2` and some left vertex is
labelled `0`. -/
lemma six_le_weight_of_left_zero (hn : 3 ≤ n) (hf : IsDRDF (K m n) f)
    (ha : 2 ≤ ∑ i, f (Sum.inl i)) (h0 : ∃ i, f (Sum.inl i) = 0) : 6 ≤ weight f := by
  obtain ⟨i, hi⟩ := h0
  have hright := three_le_right_sum_of_left_zero hf hi
  rcases right_three_or_four_of_left_zero hf hi with ⟨j, hj⟩ | hsum4
  · -- Case: some right vertex has value 3
    -- If right sum ≥ 4, we're done immediately
    have hj_le : f (Sum.inr j) ≤ ∑ l, f (Sum.inr l) :=
      Finset.single_le_sum (f := fun x => f (Sum.inr x)) (fun _ _ => Nat.zero_le _) (Finset.mem_univ j)
    by_cases hsum4 : 4 ≤ ∑ j, f (Sum.inr j)
    · calc 6 = 2 + 4 := by norm_num
        _ ≤ ∑ i, f (Sum.inl i) + ∑ j, f (Sum.inr j) := by omega
        _ = weight f := (weight_sum_type f).symm
    · -- Right sum = 3 exactly
      push_neg at hsum4
      have hsum_eq_3 : ∑ j, f (Sum.inr j) = 3 := by omega
      -- Since n ≥ 3, there exists another right vertex k ≠ j
      have hcard : 1 < Fintype.card (Fin n) := by simp; omega
      obtain ⟨k, hk⟩ := Fintype.exists_ne_of_one_lt_card hcard j
      -- k has value 0 (since right sum = 3 and j has value 3)
      have hk0 : f (Sum.inr k) = 0 := by
        have hpair : f (Sum.inr j) + f (Sum.inr k) = ∑ x ∈ ({j, k} : Finset (Fin n)), f (Sum.inr x) := by
          rw [Finset.sum_pair (Ne.symm hk)]
        have hsub : ∑ x ∈ ({j, k} : Finset (Fin n)), f (Sum.inr x) ≤ ∑ x, f (Sum.inr x) :=
          Finset.sum_le_sum_of_subset (Finset.subset_univ _)
        omega
      -- k needs either an adjacent 3 or two adjacent vertices with value ≥ 2
      have hcond := hf.2.1 _ hk0
      obtain h3 | ⟨u, w, hne, hu, hw, hu2, hw2⟩ := hcond
      · -- Some adjacent vertex has value 3
        obtain ⟨u', hadj, hu'⟩ := h3
        cases u' with
        | inl i' =>
          -- u' is on the left
          have hli : f (Sum.inl i') = 3 := hu'
          have hleft_ge_3 : 3 ≤ ∑ i, f (Sum.inl i) := by
            have := Finset.single_le_sum (f := fun x => f (Sum.inl x)) (fun _ _ => Nat.zero_le _) (Finset.mem_univ i')
            linarith
          calc 6 ≤ 3 + 3 := by norm_num
            _ ≤ ∑ i, f (Sum.inl i) + ∑ j, f (Sum.inr j) := by linarith [hsum_eq_3]
            _ = weight f := (weight_sum_type f).symm
        | inr k' => exact absurd hadj (K_not_adj_inr_inr k k')
      · -- Two distinct adjacent vertices with value ≥ 2
        cases u with
        | inl i =>
          cases w with
          | inl i' =>
            have hi_ne_i' : i ≠ i' := Sum.inl_injective.ne_iff.mp hne
            have hleft_ge_4 : 4 ≤ ∑ i, f (Sum.inl i) := by
              have := pair_le_sum hi_ne_i' (g := fun x => f (Sum.inl x))
              linarith
            calc 6 ≤ 2 + 2 + 2 := by norm_num
              _ ≤ ∑ i, f (Sum.inl i) + ∑ j, f (Sum.inr j) := by linarith [hsum_eq_3]
              _ = weight f := (weight_sum_type f).symm
          | inr w => exact absurd hw (K_not_adj_inr_inr k w)
        | inr u => exact absurd hu (K_not_adj_inr_inr k u)
  · -- Case: right sum ≥ 4
    calc 6 = 2 + 4 := by norm_num
      _ ≤ ∑ i, f (Sum.inl i) + ∑ j, f (Sum.inr j) := by omega
      _ = weight f := (weight_sum_type f).symm

/-- Branch of the `6`-bound: both side weights are at least `2` and no left vertex is
labelled `0`. -/
lemma six_le_weight_of_no_left_zero (hm : 3 ≤ m) (hn : 3 ≤ n) (hf : IsDRDF (K m n) f)
    (hb : 2 ≤ ∑ j, f (Sum.inr j)) (h0 : ∀ i, f (Sum.inl i) ≠ 0) : 6 ≤ weight f := by
  have hleft_ge_m : m ≤ ∑ i, f (Sum.inl i) := m_le_left_sum h0
  by_cases hright_ge_4 : 4 ≤ ∑ j, f (Sum.inr j)
  · -- Right sum ≥ 4
    calc 6 ≤ 2 + 4 := by norm_num
      _ ≤ ∑ i, f (Sum.inl i) + ∑ j, f (Sum.inr j) := by omega
      _ = weight f := (weight_sum_type f).symm
  · push_neg at hright_ge_4
    -- Right sum is 2 or 3
    have hright_le_3 : ∑ j, f (Sum.inr j) ≤ 3 := by omega
    -- Check if there's a 0 on the right
    by_cases hright_zero : ∃ j, f (Sum.inr j) = 0
    · -- There's a 0 on the right, so either some left = 3 or left sum ≥ 4
      obtain ⟨j, hj0⟩ := hright_zero
      rcases left_three_or_four_of_right_zero hf hj0 with ⟨i, hi⟩ | hleft_ge_4
      · -- Some left vertex has value 3
        have hleft_ge_5 : m + 2 ≤ ∑ i, f (Sum.inl i) := left_sum_ge_of_three h0 hi
        calc 6 ≤ m + 2 + 2 := by omega
          _ ≤ ∑ i, f (Sum.inl i) + ∑ j, f (Sum.inr j) := by omega
          _ = weight f := (weight_sum_type f).symm
      · -- Left sum ≥ 4
        calc 6 ≤ 4 + 2 := by norm_num
          _ ≤ ∑ i, f (Sum.inl i) + ∑ j, f (Sum.inr j) := by omega
          _ = weight f := (weight_sum_type f).symm
    · -- No 0 on the right, so all right values ≥ 1
      push_neg at hright_zero
      have hright_ge_n : n ≤ ∑ j, f (Sum.inr j) := n_le_right_sum hright_zero
      -- So n = 3 and right sum = 3
      have hn_eq_3 : n = 3 := by omega
      have hright_eq_3 : ∑ j, f (Sum.inr j) = 3 := by omega
      -- Each right vertex has value 1, so each needs a left neighbour with value ≥ 2
      -- Pick any right vertex
      let j₀ : Fin n := ⟨0, by omega⟩
      have hj₀_eq_1 : f (Sum.inr j₀) = 1 := by
        have hge : 1 ≤ f (Sum.inr j₀) := Nat.one_le_iff_ne_zero.mpr (hright_zero j₀)
        by_contra hne
        have hgt : f (Sum.inr j₀) ≥ 2 := by omega
        -- Sum of others ≥ (n-1) * 1 = 2
        have hsum_others : ∑ j ∈ Finset.univ.erase j₀, f (Sum.inr j) ≥ 2 := by
          have h1 : ∀ j ∈ Finset.univ.erase j₀, 1 ≤ f (Sum.inr j) := fun j _ => Nat.one_le_iff_ne_zero.mpr (hright_zero j)
          calc ∑ j ∈ Finset.univ.erase j₀, f (Sum.inr j) ≥ ∑ _j ∈ Finset.univ.erase j₀, 1 := Finset.sum_le_sum h1
            _ = Finset.card (Finset.univ.erase j₀) := by simp
            _ = n - 1 := by simp [Finset.card_erase_of_mem (Finset.mem_univ j₀)]
            _ ≥ 2 := by omega
        have hsum' : ∑ j, f (Sum.inr j) = f (Sum.inr j₀) + ∑ j ∈ Finset.univ.erase j₀, f (Sum.inr j) :=
          (Finset.add_sum_erase _ _ (Finset.mem_univ j₀)).symm
        omega
      -- j₀ needs an adjacent vertex with value ≥ 2
      obtain ⟨u, hadj, hu⟩ := hf.2.2 (Sum.inr j₀) hj₀_eq_1
      cases u with
      | inl i' =>
        -- i' has value ≥ 2
        have hi'_ge_2 : 2 ≤ f (Sum.inl i') := hu
        -- Others sum ≥ m - 1 since each of the m-1 others is ≥ 1
        have hsum_others : ∑ x ∈ Finset.univ.erase i', f (Sum.inl x) ≥ m - 1 := by
          have h1 : ∀ x ∈ Finset.univ.erase i', 1 ≤ f (Sum.inl x) :=
            fun x _ => Nat.one_le_iff_ne_zero.mpr (h0 x)
          calc ∑ x ∈ Finset.univ.erase i', f (Sum.inl x) ≥ ∑ _x ∈ Finset.univ.erase i', 1 := Finset.sum_le_sum h1
            _ = Finset.card (Finset.univ.erase i') := by simp
            _ = m - 1 := by simp [Finset.card_erase_of_mem (Finset.mem_univ i')]
        have hleft_ge_m1 : m + 1 ≤ ∑ x, f (Sum.inl x) := by
          have hsum' : ∑ x, f (Sum.inl x) = f (Sum.inl i') + ∑ x ∈ Finset.univ.erase i', f (Sum.inl x) :=
            (Finset.add_sum_erase _ _ (Finset.mem_univ i')).symm
          omega
        calc 6 ≤ m + 1 + 3 := by omega
          _ ≤ ∑ x, f (Sum.inl x) + ∑ j, f (Sum.inr j) := by omega
          _ = weight f := (weight_sum_type f).symm
      | inr k => exact absurd hadj (K_not_adj_inr_inr j₀ k)

/-- If both sides have at least three vertices, every double Roman dominating function
of `K_{m,n}` has weight at least `6`. -/
lemma six_le_weight_of_isDRDF_K (hm : 3 ≤ m) (hn : 3 ≤ n) (hf : IsDRDF (K m n) f) :
    6 ≤ weight f := by
  by_cases hr : ∑ j, f (Sum.inr j) ≤ 1
  · exact six_le_weight_of_right_le_one hm hf hr
  · push_neg at hr
    by_cases hl : ∑ i, f (Sum.inl i) ≤ 1
    · exact six_le_weight_of_left_le_one hn hf hl
    · push_neg at hl
      -- Both sums are ≥ 2
      by_cases hleft_zero : ∃ i, f (Sum.inl i) = 0
      · exact six_le_weight_of_left_zero hn hf hl hleft_zero
      · have hleft_zero' : ∀ i, f (Sum.inl i) ≠ 0 := fun i hi => hleft_zero ⟨i, hi⟩
        exact six_le_weight_of_no_left_zero hm hn hf hr hleft_zero'

end KLower

/-! ### Exact values -/

section Values

variable {m n : ℕ}

/-- Swapping the two sides turns a double Roman dominating function of `K_{m,n}` into
one of `K_{n,m}`. -/
lemma isDRDF_swap {f : Fin m ⊕ Fin n → ℕ} (hf : IsDRDF (K m n) f) :
    IsDRDF (K n m) (fun x => f x.swap) := by
  have K_adj_swap : ∀ x y : Fin m ⊕ Fin n, (K m n).Adj x y ↔ (K n m).Adj x.swap y.swap := by
    intros; cases ‹Fin m ⊕ Fin n› <;> cases ‹Fin m ⊕ Fin n› <;> simp [K]
  obtain ⟨hbound, hzero, hone⟩ := hf
  refine ⟨fun v => hbound _, fun v hv => ?_, fun v hv => ?_⟩
  · simp only at hv
    rcases hzero (v.swap) hv with h3 | ⟨u, w, hne, hu, hw, hu2, hw2⟩
    · obtain ⟨u', hadj, hu'⟩ := h3
      refine Or.inl ⟨u'.swap, ?_, by simp [hu']⟩
      rw [K_adj_swap] at hadj; simpa only [Sum.swap_swap] using hadj
    · refine Or.inr ⟨u.swap, w.swap, ?_, ?_, ?_, by simp [hu2], by simp [hw2]⟩
      · intro h; apply hne; cases u <;> cases w <;> simp at h <;> cases h <;> trivial
      · rw [K_adj_swap] at hu; simpa only [Sum.swap_swap] using hu
      · rw [K_adj_swap] at hw; simpa only [Sum.swap_swap] using hw
  · simp only at hv
    obtain ⟨u, hadj, hu⟩ := hone (v.swap) hv
    refine ⟨u.swap, ?_, by simp [hu]⟩
    rw [K_adj_swap] at hadj; simpa only [Sum.swap_swap] using hadj

lemma weight_swap (f : Fin m ⊕ Fin n → ℕ) :
    weight (fun x : Fin n ⊕ Fin m => f x.swap) = weight f := by
  simp [weight]
  ring

/-- The double Roman domination number is symmetric in the two sides. -/
theorem gammaDR_K_comm : gammaDR (K m n) = gammaDR (K n m) := by
  refine le_antisymm (le_gammaDR fun f hf => ?_) (le_gammaDR fun f hf => ?_)
  · have hweight := @weight_swap n m f
    simp only at hweight
    exact hweight ▸ gammaDR_le (G := K m n) (@isDRDF_swap n m f hf)
  · exact weight_swap f ▸ gammaDR_le (G := K n m) (isDRDF_swap hf)

/-- **`γ_dR(K_{1,n}) = 3`.** -/
theorem gammaDR_K_one (hn : 1 ≤ n) : gammaDR (K 1 n) = 3 := by
  refine le_antisymm (weight_leftThree ▸ gammaDR_le _ isDRDF_leftThree) (three_le_gammaDR ?_)
  simp [Fintype.card_sum]
  omega

/-- **`γ_dR(K_{2,n}) = 4` for `n ≥ 2`.** -/
theorem gammaDR_K_two (hn : 2 ≤ n) : gammaDR (K 2 n) = 4 := by
  refine le_antisymm ?_ ?_
  · have h : weight (leftTwos (2 : ℕ) n) = 4 := by simp [weight_leftTwos]
    exact h ▸ gammaDR_le _ (isDRDF_leftTwos (by omega))
  · exact le_gammaDR fun f hf => four_le_weight_of_isDRDF_K (by omega : 2 ≤ (2 : ℕ)) hn hf

/-- **`γ_dR(K_{m,n}) = 6` for `m, n ≥ 3`.** -/
theorem gammaDR_K_three (hm : 3 ≤ m) (hn : 3 ≤ n) : gammaDR (K m n) = 6 :=
  le_antisymm
    ((gammaDR_le _ (isDRDF_cornerThree (by omega) (by omega))).trans_eq
      (weight_cornerThree (by omega) (by omega)))
    (le_gammaDR fun _ hf => six_le_weight_of_isDRDF_K hm hn hf)

/-- **The double Roman domination number of the complete bipartite graph.**
With `k = min m n` it equals `3` if `k = 1`, `4` if `k = 2`, and `6` if `k ≥ 3`. -/
theorem gammaDR_K_eq (hm : 1 ≤ m) (hn : 1 ≤ n) :
    gammaDR (K m n) = if min m n = 1 then 3 else if min m n = 2 then 4 else 6 := by
  by_cases h1 : min m n = 1
  · simp [h1]
    have hmn : m = 1 ∨ n = 1 := by omega
    rcases hmn with rfl | rfl
    · exact gammaDR_K_one hn
    · rw [gammaDR_K_comm]; exact gammaDR_K_one hm
  · simp [h1]
    by_cases h2 : min m n = 2
    · simp [h2]
      have hmn : m = 2 ∨ n = 2 := by omega
      rcases hmn with rfl | rfl
      · exact gammaDR_K_two (by omega : 2 ≤ n)
      · rw [gammaDR_K_comm]; exact gammaDR_K_two (by omega : 2 ≤ m)
    · simp [h2]
      have hm3 : 3 ≤ m := by omega
      have hn3 : 3 ≤ n := by omega
      exact gammaDR_K_three hm3 hn3

end Values

end RomanDomination