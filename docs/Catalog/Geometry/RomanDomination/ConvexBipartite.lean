/-
# Convex bipartite graphs and exact Roman-type domination numbers of `K_{m,n}`

A bipartite graph with parts `A` and `B` is **convex** (with respect to a linear
order on `A`) when the neighbourhood of every vertex of `B` is an order-convex
subset of `A`, i.e. an interval.  This interval structure is exactly what makes the
left-to-right dynamic programming algorithms for Roman-type domination possible on
this graph class.

Here we

* define `IsConvexBipartite` for graphs on `Fin m ⊕ Fin n`,
* show that a convex bipartite graph is `2`-colourable,
* show that the complete bipartite graph `K_{m,n}` is convex bipartite, and
* compute *exactly* the Roman domination number and the Italian (Roman-`{2}`)
  domination number of `K_{m,n}`:

```
γ_R(K_{m,n}) = min 4 (min (m+1) (n+1))     (m, n ≥ 1)
γ_I(K_{m,n}) = min 4 (min m n)             (m, n ≥ 2)
```
-/

import Mathlib
import Geometry.RomanDomination.Variants

namespace RomanDomination

open Finset

/-! ### Convex bipartite graphs -/

/-- A graph on `Fin m ⊕ Fin n` is *convex bipartite* when all its edges join the two
sides and, for every right vertex `b`, the set of left neighbours of `b` is an
interval in the natural order on `Fin m`. -/
def IsConvexBipartite {m n : ℕ} (G : SimpleGraph (Fin m ⊕ Fin n)) : Prop :=
  (∀ u v, G.Adj u v → (u.isLeft ∧ v.isRight) ∨ (u.isRight ∧ v.isLeft)) ∧
  ∀ (b : Fin n) (i j k : Fin m), i ≤ j → j ≤ k →
    G.Adj (Sum.inl i) (Sum.inr b) → G.Adj (Sum.inl k) (Sum.inr b) →
    G.Adj (Sum.inl j) (Sum.inr b)

/-- A convex bipartite graph is bipartite: the map sending a vertex to its side is a
proper `2`-colouring. -/
theorem colorable_two_of_isConvexBipartite {m n : ℕ} {G : SimpleGraph (Fin m ⊕ Fin n)}
    (h : IsConvexBipartite G) : G.Colorable 2 := by
  let color : Fin m ⊕ Fin n → Fin 2 := fun v => if v.isLeft then 0 else 1
  exact ⟨color, by
    intro a b hab
    unfold SimpleGraph.completeGraph
    simp
    obtain hcase | hcase := h.1 a b hab
    · obtain ⟨ha, hb⟩ := hcase
      simp [ha, hb, color]
    · obtain ⟨ha, hb⟩ := hcase
      simp [ha, hb, color]⟩

section CompleteBipartite

variable (m n : ℕ)

/-- The complete bipartite graph `K_{m,n}`. -/
abbrev K : SimpleGraph (Fin m ⊕ Fin n) := completeBipartiteGraph (Fin m) (Fin n)

instance : DecidableRel (K m n).Adj := fun u v =>
  decidable_of_iff ((u.isLeft ∧ v.isRight) ∨ (u.isRight ∧ v.isLeft)) Iff.rfl

variable {m n}

lemma K_adj_inl_inr (i : Fin m) (j : Fin n) : (K m n).Adj (Sum.inl i) (Sum.inr j) :=
  Or.inl ⟨rfl, rfl⟩

lemma K_adj_inr_inl (j : Fin n) (i : Fin m) : (K m n).Adj (Sum.inr j) (Sum.inl i) :=
  Or.inr ⟨rfl, rfl⟩

lemma K_not_adj_inl_inl (i i' : Fin m) : ¬ (K m n).Adj (Sum.inl i) (Sum.inl i') := by
  simp

lemma K_not_adj_inr_inr (j j' : Fin n) : ¬ (K m n).Adj (Sum.inr j) (Sum.inr j') := by
  simp [K, completeBipartiteGraph]

variable (m n)

/-- `K_{m,n}` is convex bipartite: each right vertex is adjacent to all of `Fin m`. -/
theorem isConvexBipartite_K : IsConvexBipartite (K m n) := by
  constructor
  · intro u v hab
    match u, v with
    | Sum.inl i, Sum.inl j => exact absurd hab (K_not_adj_inl_inl i j)
    | Sum.inl i, Sum.inr j => exact Or.inl ⟨rfl, rfl⟩
    | Sum.inr j, Sum.inl i => exact Or.inr ⟨rfl, rfl⟩
    | Sum.inr j, Sum.inr j' => exact absurd hab (K_not_adj_inr_inr j j')
  · intro b i j k _ _ hi hk
    exact K_adj_inl_inr i b

end CompleteBipartite

/-! ### Splitting weights over the two sides -/

section Weights

variable {m n : ℕ}

/-- The weight of a labelling of `Fin m ⊕ Fin n` splits as the sum of the two side
weights. -/
lemma weight_sum_type (f : Fin m ⊕ Fin n → ℕ) :
    weight f = (∑ i, f (Sum.inl i)) + ∑ j, f (Sum.inr j) := by
  simp [weight]

/-- The neighbourhood sum of a left vertex of `K_{m,n}` is the right side weight. -/
lemma K_neighbor_sum_inl (f : Fin m ⊕ Fin n → ℕ) (i : Fin m) :
    ∑ u ∈ (K m n).neighborFinset (Sum.inl i), f u = ∑ j, f (Sum.inr j) := by
  have h : (K m n).neighborFinset (Sum.inl i) = Finset.univ.map ⟨Sum.inr, Sum.inr_injective⟩ := by
    ext u
    simp [K, completeBipartiteGraph_adj]
    rcases u with ⟨⟩ <;> simp
  rw [h, Finset.sum_map]
  simp

/-- The neighbourhood sum of a right vertex of `K_{m,n}` is the left side weight. -/
lemma K_neighbor_sum_inr (f : Fin m ⊕ Fin n → ℕ) (j : Fin n) :
    ∑ u ∈ (K m n).neighborFinset (Sum.inr j), f u = ∑ i, f (Sum.inl i) := by
  have h : (K m n).neighborFinset (Sum.inr j) = Finset.univ.map ⟨Sum.inl, Sum.inl_injective⟩ := by
    ext u
    simp [K, completeBipartiteGraph_adj]
    rcases u with ⟨⟩ <;> simp
  rw [h, Finset.sum_map]
  simp

/-- If every value of a family indexed by a finite type is at least one, the sum is at
least the cardinality. -/
lemma card_le_sum_of_one_le {α : Type*} [Fintype α] {g : α → ℕ} (h : ∀ a, 1 ≤ g a) :
    Fintype.card α ≤ ∑ a, g a := by
  calc Fintype.card α = ∑ a : α, 1 := by simp
    _ ≤ ∑ a : α, g a := Finset.sum_le_sum fun a _ => h a

/-- If every value is at least one and some value is at least `2`, the sum is at least
`card + 1`. -/
lemma card_succ_le_sum_of_one_le_of_two {α : Type*} [Fintype α] [DecidableEq α] {g : α → ℕ}
    (h : ∀ a, 1 ≤ g a) {a₀ : α} (h₀ : 2 ≤ g a₀) : Fintype.card α + 1 ≤ ∑ a, g a := by
  have h₁ : ∑ a, g a = g a₀ + ∑ a ∈ Finset.univ.erase a₀, g a := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ a₀)]
  rw [h₁]
  have h₂ : ∑ a ∈ Finset.univ.erase a₀, g a ≥ Fintype.card α - 1 := by
    calc ∑ a ∈ Finset.univ.erase a₀, g a ≥ ∑ _a ∈ Finset.univ.erase a₀, 1 :=
           Finset.sum_le_sum fun a _ => h a
      _ = (Finset.univ.erase a₀).card := by simp
      _ = Fintype.card α - 1 := by simp [Finset.card_erase_of_mem (Finset.mem_univ a₀)]
  omega

/-- A single value bounds the sum from below. -/
lemma le_sum_of_le {α : Type*} [Fintype α] {g : α → ℕ} {a₀ : α} {c : ℕ} (h : c ≤ g a₀) :
    c ≤ ∑ a, g a := by
  exact le_trans h (Finset.single_le_sum (fun _ _ => Nat.zero_le _) (Finset.mem_univ a₀))

end Weights

/-! ### Roman dominating functions of `K_{m,n}`: structure -/

section KStructure

variable {m n : ℕ} {f : Fin m ⊕ Fin n → ℕ}

/-- A left vertex labelled `0` forces a right vertex labelled `2`. -/
lemma exists_right_two (hf : IsRDF (K m n) f) {i : Fin m} (h0 : f (Sum.inl i) = 0) :
    ∃ j, f (Sum.inr j) = 2 := by
  obtain ⟨u, hadj, hu⟩ := hf.2 (Sum.inl i) h0
  match u with
  | Sum.inl j => exact absurd hadj (K_not_adj_inl_inl i j)
  | Sum.inr j => exact ⟨j, hu⟩

/-- A right vertex labelled `0` forces a left vertex labelled `2`. -/
lemma exists_left_two (hf : IsRDF (K m n) f) {j : Fin n} (h0 : f (Sum.inr j) = 0) :
    ∃ i, f (Sum.inl i) = 2 := by
  obtain ⟨u, hadj, hu⟩ := hf.2 (Sum.inr j) h0
  match u with
  | Sum.inr i => exact absurd hadj (K_not_adj_inr_inr j i)
  | Sum.inl i => exact ⟨i, hu⟩

/-- If no left vertex is labelled `0`, the left side weight is at least `m`. -/
lemma m_le_left_sum (h : ∀ i, f (Sum.inl i) ≠ 0) : m ≤ ∑ i, f (Sum.inl i) := by
  have := card_le_sum_of_one_le (fun i => Nat.pos_of_ne_zero (h i))
  rwa [Fintype.card_fin] at this

/-- If no right vertex is labelled `0`, the right side weight is at least `n`. -/
lemma n_le_right_sum (h : ∀ j, f (Sum.inr j) ≠ 0) : n ≤ ∑ j, f (Sum.inr j) := by
  have := card_le_sum_of_one_le (fun j => Nat.pos_of_ne_zero (h j))
  rwa [Fintype.card_fin] at this

/-- If no left vertex is labelled `0` and some left vertex is labelled `2`, the left
side weight is at least `m + 1`. -/
lemma m_succ_le_left_sum (h : ∀ i, f (Sum.inl i) ≠ 0) {i₀ : Fin m} (h₀ : f (Sum.inl i₀) = 2) :
    m + 1 ≤ ∑ i, f (Sum.inl i) := by
  have := card_succ_le_sum_of_one_le_of_two (fun i => Nat.pos_of_ne_zero (h i)) h₀.ge
  rwa [Fintype.card_fin] at this

/-- If no right vertex is labelled `0` and some right vertex is labelled `2`, the right
side weight is at least `n + 1`. -/
lemma n_succ_le_right_sum (h : ∀ j, f (Sum.inr j) ≠ 0) {j₀ : Fin n} (h₀ : f (Sum.inr j₀) = 2) :
    n + 1 ≤ ∑ j, f (Sum.inr j) := by
  have := card_succ_le_sum_of_one_le_of_two (fun j => Nat.pos_of_ne_zero (h j)) h₀.ge
  rwa [Fintype.card_fin] at this

end KStructure

/-! ### The Roman domination number of `K_{m,n}` -/

section RomanValue

variable {m n : ℕ}

/-- `2` on the first left vertex, `1` on the other left vertices, `0` on the right. -/
def leftHeavy (m n : ℕ) : Fin m ⊕ Fin n → ℕ :=
  Sum.elim (fun i => if i.val = 0 then 2 else 1) (fun _ => 0)

/-- `2` on the first right vertex, `1` on the other right vertices, `0` on the left. -/
def rightHeavy (m n : ℕ) : Fin m ⊕ Fin n → ℕ :=
  Sum.elim (fun _ => 0) (fun j => if j.val = 0 then 2 else 1)

/-- `2` on the first vertex of each side, `0` elsewhere. -/
def cornerTwo (m n : ℕ) : Fin m ⊕ Fin n → ℕ :=
  Sum.elim (fun i => if i.val = 0 then 2 else 0) (fun j => if j.val = 0 then 2 else 0)

/-- `1` on every left vertex, `0` on the right. -/
def leftOnes (m n : ℕ) : Fin m ⊕ Fin n → ℕ := Sum.elim (fun _ => 1) (fun _ => 0)

/-- `1` on every right vertex, `0` on the left. -/
def rightOnes (m n : ℕ) : Fin m ⊕ Fin n → ℕ := Sum.elim (fun _ => 0) (fun _ => 1)

lemma weight_leftHeavy (hm : 1 ≤ m) : weight (leftHeavy m n) = m + 1 := by
  unfold weight leftHeavy
  simp
  rw [Finset.sum_ite]
  simp [Finset.sum_const, smul_eq_mul]
  have h1 : #{x : Fin m | (x : ℕ) = 0} = 1 := by
    rw [Finset.card_eq_one]
    use ⟨0, hm⟩
    ext x
    simp [Fin.ext_iff]
  have h2 : #{x : Fin m | ¬(x : ℕ) = 0} = m - 1 := by
    rw [show (Finset.univ.filter fun x : Fin m => ¬(x : ℕ) = 0) = Finset.univ \ Finset.univ.filter (fun x : Fin m => (x : ℕ) = 0) by ext; simp]
    rw [Finset.card_sdiff]
    simp [h1]
  omega

lemma weight_rightHeavy (hn : 1 ≤ n) : weight (rightHeavy m n) = n + 1 := by
  unfold weight rightHeavy
  simp
  rw [Finset.sum_ite]
  simp [Finset.sum_const, smul_eq_mul]
  have h1 : #{x : Fin n | (x : ℕ) = 0} = 1 := by
    rw [Finset.card_eq_one]
    use ⟨0, hn⟩
    ext x
    simp [Fin.ext_iff]
  have h2 : #{x : Fin n | ¬(x : ℕ) = 0} = n - 1 := by
    rw [show (Finset.univ.filter fun x : Fin n => ¬(x : ℕ) = 0) = Finset.univ \ Finset.univ.filter (fun x : Fin n => (x : ℕ) = 0) by ext; simp]
    rw [Finset.card_sdiff]
    simp [h1]
  omega

lemma weight_cornerTwo (hm : 1 ≤ m) (hn : 1 ≤ n) : weight (cornerTwo m n) = 4 := by
  unfold cornerTwo
  rw [weight_sum_type]
  have left_sum : ∑ i : Fin m, (if i.val = 0 then 2 else 0) = 2 := by
    rw [Finset.sum_ite]
    simp [Finset.sum_const, smul_eq_mul]
    have h1 : #{x : Fin m | (x : ℕ) = 0} = 1 := by
      rw [Finset.card_eq_one]
      use ⟨0, hm⟩
      ext x
      simp [Fin.ext_iff]
    omega
  have right_sum : ∑ j : Fin n, (if j.val = 0 then 2 else 0) = 2 := by
    rw [Finset.sum_ite]
    simp [Finset.sum_const, smul_eq_mul]
    have h1 : #{x : Fin n | (x : ℕ) = 0} = 1 := by
      rw [Finset.card_eq_one]
      use ⟨0, hn⟩
      ext x
      simp [Fin.ext_iff]
    omega
  simp_all

lemma weight_leftOnes : weight (leftOnes m n) = m := by
  simp [weight_sum_type, leftOnes]

lemma weight_rightOnes : weight (rightOnes m n) = n := by
  simp [weight_sum_type, rightOnes]

lemma isRDF_leftHeavy (hm : 1 ≤ m) : IsRDF (K m n) (leftHeavy m n) := by
  constructor
  · -- all values ≤ 2
    intro v
    unfold leftHeavy
    cases v <;> (simp; try (split_ifs <;> norm_num))
  · -- every 0-vertex is adjacent to a 2-vertex
    intro v hv
    unfold leftHeavy at hv
    cases v with
    | inl i =>
      simp at hv
      split_ifs at hv
    | inr j =>
      refine ⟨Sum.inl ⟨0, hm⟩, ?_, ?_⟩
      · simp [K, completeBipartiteGraph_adj]
      · unfold leftHeavy; simp

lemma isRDF_rightHeavy (hn : 1 ≤ n) : IsRDF (K m n) (rightHeavy m n) := by
  constructor
  · -- all values ≤ 2
    intro v
    unfold rightHeavy
    cases v <;> (simp; try (split_ifs <;> norm_num))
  · -- every 0-vertex is adjacent to a 2-vertex
    intro v hv
    unfold rightHeavy at hv
    cases v with
    | inl i =>
      refine ⟨Sum.inr ⟨0, hn⟩, ?_, ?_⟩
      · simp [K, completeBipartiteGraph_adj]
      · unfold rightHeavy; simp
    | inr j =>
      simp at hv
      split_ifs at hv

lemma isRDF_cornerTwo (hm : 1 ≤ m) (hn : 1 ≤ n) : IsRDF (K m n) (cornerTwo m n) := by
  constructor
  · -- all values ≤ 2
    intro v
    unfold cornerTwo
    cases v <;> (simp; try (split_ifs <;> norm_num))
  · -- every 0-vertex is adjacent to a 2-vertex
    intro v hv
    unfold cornerTwo at hv
    cases v with
    | inl i =>
      simp at hv
      refine ⟨Sum.inr ⟨0, hn⟩, ?_, ?_⟩
      · simp [K, completeBipartiteGraph_adj]
      · unfold cornerTwo; simp
    | inr j =>
      simp at hv
      refine ⟨Sum.inl ⟨0, hm⟩, ?_, ?_⟩
      · simp [K, completeBipartiteGraph_adj]
      · unfold cornerTwo; simp

variable {f : Fin m ⊕ Fin n → ℕ}

/-- Case both sides contain a `0`-vertex: the weight is at least `4`. -/
lemma four_le_weight_of_zero_both (hf : IsRDF (K m n) f)
    (hA : ∃ i, f (Sum.inl i) = 0) (hB : ∃ j, f (Sum.inr j) = 0) : 4 ≤ weight f := by
  obtain ⟨i, hi⟩ := hA
  obtain ⟨j, hj⟩ := hB
  obtain ⟨j', hj'⟩ := exists_right_two hf hi
  obtain ⟨i', hi'⟩ := exists_left_two hf hj
  rw [weight_sum_type]
  have hleft : 2 ≤ ∑ i, f (Sum.inl i) := le_sum_of_le hi'.ge
  have hright : 2 ≤ ∑ j, f (Sum.inr j) := le_sum_of_le hj'.ge
  omega

/-- Case a `0` on the left but none on the right: the weight is at least `n + 1`. -/
lemma succ_n_le_weight_of_zero_left (hf : IsRDF (K m n) f)
    (hA : ∃ i, f (Sum.inl i) = 0) (hB : ∀ j, f (Sum.inr j) ≠ 0) : n + 1 ≤ weight f := by
  obtain ⟨i, hi⟩ := hA
  obtain ⟨j, hj⟩ := exists_right_two hf hi
  rw [weight_sum_type]
  exact le_trans (n_succ_le_right_sum hB hj) (le_add_of_nonneg_left (Finset.sum_nonneg (fun _ _ => Nat.zero_le _)))

/-- Case a `0` on the right but none on the left: the weight is at least `m + 1`. -/
lemma succ_m_le_weight_of_zero_right (hf : IsRDF (K m n) f)
    (hA : ∀ i, f (Sum.inl i) ≠ 0) (hB : ∃ j, f (Sum.inr j) = 0) : m + 1 ≤ weight f := by
  obtain ⟨j, hj⟩ := hB
  obtain ⟨i₀, hi₀⟩ := exists_left_two hf hj
  rw [weight_sum_type]
  have := m_succ_le_left_sum hA hi₀
  exact le_trans this (le_add_of_nonneg_right (Nat.zero_le _))

/-- Case no `0` at all: the weight is at least `m + n`. -/
lemma add_le_weight_of_no_zero (hA : ∀ i, f (Sum.inl i) ≠ 0) (hB : ∀ j, f (Sum.inr j) ≠ 0) :
    m + n ≤ weight f := by
  rw [weight_sum_type]
  exact add_le_add (m_le_left_sum hA) (n_le_right_sum hB)

/-- Lower bound: every Roman dominating function of `K_{m,n}` has weight at least
`min 4 (min (m+1) (n+1))`. -/
lemma min_le_weight_of_isRDF_K (hm : 1 ≤ m) (hn : 1 ≤ n) (hf : IsRDF (K m n) f) :
    min 4 (min (m + 1) (n + 1)) ≤ weight f := by
  by_cases hA : ∃ i, f (Sum.inl i) = 0
  case pos =>
    by_cases hB : ∃ j, f (Sum.inr j) = 0
    case pos =>
      exact le_trans (min_le_left _ _) (four_le_weight_of_zero_both hf hA hB)
    case neg =>
      push_neg at hB
      have := succ_n_le_weight_of_zero_left hf hA hB
      omega
  case neg =>
    by_cases hB : ∃ j, f (Sum.inr j) = 0
    case pos =>
      push_neg at hA
      have := succ_m_le_weight_of_zero_right hf hA hB
      omega
    case neg =>
      push_neg at hA hB
      have := add_le_weight_of_no_zero hA hB
      omega

/-- **Exact Roman domination number of the complete bipartite graph.** -/
theorem gammaR_K (hm : 1 ≤ m) (hn : 1 ≤ n) :
    gammaR (K m n) = min 4 (min (m + 1) (n + 1)) := by
  refine le_antisymm (le_min ?_ (le_min ?_ ?_))
    (le_gammaR _ fun f hf => min_le_weight_of_isRDF_K hm hn hf)
  · exact (gammaR_le _ (isRDF_cornerTwo hm hn)).trans_eq (weight_cornerTwo hm hn)
  · exact (gammaR_le _ (isRDF_leftHeavy hm)).trans_eq (weight_leftHeavy hm)
  · exact (gammaR_le _ (isRDF_rightHeavy hn)).trans_eq (weight_rightHeavy hn)

end RomanValue

/-! ### The Italian domination number of `K_{m,n}` -/

section ItalianValue

variable {m n : ℕ}

lemma isIDF_cornerTwo (hm : 1 ≤ m) (hn : 1 ≤ n) : IsIDF (K m n) (cornerTwo m n) := by
  constructor
  · -- all values ≤ 2
    intro v
    unfold cornerTwo
    cases v <;> (simp; try (split_ifs <;> norm_num))
  · -- every 0-vertex has neighbor sum ≥ 2
    intro v hv
    unfold cornerTwo at hv
    cases v with
    | inl i =>
      simp at hv
      rw [K_neighbor_sum_inl]
      simp [cornerTwo]
      rw [Finset.sum_ite]
      simp [Finset.sum_const, smul_eq_mul]
      exact ⟨⟨0, hn⟩, by simp⟩
    | inr j =>
      simp at hv
      rw [K_neighbor_sum_inr]
      simp [cornerTwo]
      rw [Finset.sum_ite]
      simp [Finset.sum_const, smul_eq_mul]
      exact ⟨⟨0, hm⟩, by simp⟩

lemma isIDF_leftOnes (hm : 2 ≤ m) : IsIDF (K m n) (leftOnes m n) := by
  constructor
  · -- all values ≤ 2
    intro v
    unfold leftOnes
    cases v <;> simp
  · -- every 0-vertex has neighbour sum ≥ 2
    intro v hv
    unfold leftOnes at hv
    cases v with
    | inl i => simp at hv
    | inr j =>
      simp [K_neighbor_sum_inr, leftOnes]
      omega

lemma isIDF_rightOnes (hn : 2 ≤ n) : IsIDF (K m n) (rightOnes m n) := by
  constructor
  · -- all values ≤ 2
    intro v
    unfold rightOnes
    cases v <;> simp
  · -- every 0-vertex has neighbour sum ≥ 2
    intro v hv
    unfold rightOnes at hv
    cases v with
    | inl i =>
      simp at hv
      simp [K_neighbor_sum_inl, rightOnes]
      omega
    | inr j => simp at hv

variable {f : Fin m ⊕ Fin n → ℕ}

/-- For an Italian dominating function of `K_{m,n}`, a `0` on each side forces total
weight at least `4`. -/
lemma four_le_weight_of_isIDF_zero_both (hf : IsIDF (K m n) f)
    (hA : ∃ i, f (Sum.inl i) = 0) (hB : ∃ j, f (Sum.inr j) = 0) : 4 ≤ weight f := by
  obtain ⟨i₀, hi₀⟩ := hA
  obtain ⟨j₀, hj₀⟩ := hB
  have hright : ∑ j, f (Sum.inr j) ≥ 2 := by
    have := hf.2 (Sum.inl i₀) hi₀
    rw [K_neighbor_sum_inl] at this
    exact this
  have hleft : ∑ i, f (Sum.inl i) ≥ 2 := by
    have := hf.2 (Sum.inr j₀) hj₀
    rw [K_neighbor_sum_inr] at this
    exact this
  rw [weight_sum_type]
  omega

/-- If no left vertex is labelled `0`, the total weight is at least `m`. -/
lemma m_le_weight_of_no_zero_left (h : ∀ i, f (Sum.inl i) ≠ 0) : m ≤ weight f := by
  rw [weight_sum_type]
  have := m_le_left_sum h
  omega

/-- If no right vertex is labelled `0`, the total weight is at least `n`. -/
lemma n_le_weight_of_no_zero_right (h : ∀ j, f (Sum.inr j) ≠ 0) : n ≤ weight f := by
  rw [weight_sum_type]
  have := n_le_right_sum h
  omega

/-- Lower bound: every Italian dominating function of `K_{m,n}` has weight at least
`min 4 (min m n)`. -/
lemma min_le_weight_of_isIDF_K (hf : IsIDF (K m n) f) : min 4 (min m n) ≤ weight f := by
  by_cases hA : ∃ i, f (Sum.inl i) = 0
  case pos =>
    by_cases hB : ∃ j, f (Sum.inr j) = 0
    case pos =>
      exact le_trans (min_le_left _ _) (four_le_weight_of_isIDF_zero_both hf hA hB)
    case neg =>
      push_neg at hB
      rw [weight_sum_type]
      have hright : 2 ≤ ∑ j, f (Sum.inr j) := by
        obtain ⟨i₀, hi₀⟩ := hA
        have := hf.2 (Sum.inl i₀) hi₀
        rw [K_neighbor_sum_inl] at this
        exact this
      have hright' : n ≤ ∑ j, f (Sum.inr j) := n_le_right_sum hB
      omega
  case neg =>
    by_cases hB : ∃ j, f (Sum.inr j) = 0
    case pos =>
      push_neg at hA
      rw [weight_sum_type]
      have hleft : 2 ≤ ∑ i, f (Sum.inl i) := by
        obtain ⟨j₀, hj₀⟩ := hB
        have := hf.2 (Sum.inr j₀) hj₀
        rw [K_neighbor_sum_inr] at this
        exact this
      have hleft' : m ≤ ∑ i, f (Sum.inl i) := m_le_left_sum hA
      omega
    case neg =>
      push_neg at hA hB
      have h1 := m_le_weight_of_no_zero_left hA
      omega

/-- **Exact Italian (Roman-`{2}`) domination number of the complete bipartite graph.** -/
theorem gammaI_K (hm : 2 ≤ m) (hn : 2 ≤ n) :
    gammaI (K m n) = min 4 (min m n) := by
  refine le_antisymm (le_min ?_ (le_min ?_ ?_)) (le_gammaI _ fun f hf => min_le_weight_of_isIDF_K hf)
  · exact (gammaI_le _ (isIDF_cornerTwo (by omega) (by omega))).trans_eq
      (weight_cornerTwo (by omega) (by omega))
  · exact (gammaI_le _ (isIDF_leftOnes hm)).trans_eq weight_leftOnes
  · exact (gammaI_le _ (isIDF_rightOnes hn)).trans_eq weight_rightOnes

end ItalianValue

end RomanDomination