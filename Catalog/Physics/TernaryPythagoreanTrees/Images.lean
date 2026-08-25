import Physics.TernaryPythagoreanTrees.Mixed
import Physics.TernaryPythagoreanTrees.Rigidity

/-!
# Exact images of the six classical branches

For the classification we need to know exactly which nodes lie in the image of each of the
classical branches.  The images are cut out by simple *regions* of the node cone:

| branch | matrix | image |
|---|---|---|
| `bergA` | `(2,-1;1,0)` | `m < 2n` |
| `bergB` | `(2,1;1,0)`  | `2n < m < 3n` |
| `bergC` | `(1,2;0,1)`  | `3n < m` |
| `priceP0` | `(1,1;0,2)` | `n` even |
| `priceP1` | `(2,0;1,-1)` | `m` even and `2n < m` |
| `priceP2` | `(2,0;1,1)` | `m` even and `m < 2n` |
| `mixF0` | `(1,3;0,2)` | `n` even and `2n < m` |

We prove both inclusions for each region that the classification argument uses.
-/

namespace TernaryTree

/-! ### Berggren branches -/

lemma bergA_image_lt {x y : ℤ} (h : IsNode x y) :
    (bergA.app x y).1 < 2 * (bergA.app x y).2 := by
  have := h.one_le
  simp [bergA, IntMap.app]
  omega

lemma bergA_mem_image {m n : ℤ} (h : IsNode m n) (hlt : m < 2 * n) :
    ∃ x y, IsNode x y ∧ bergA.app x y = (m, n) := by
  have h1 := h.one_le
  have h2 := h.lt
  obtain ⟨t, ht⟩ := h.odd
  refine ⟨n, 2 * n - m, ⟨by omega, by omega, ?_, ⟨2 * n - t - 1, by omega⟩⟩, ?_⟩
  · exact isCoprime_of_unimodular h.cop (α := 0) (β := 1) (γ := -1) (δ := 2)
      (by ring) (by ring) (by norm_num)
  · simp [bergA, IntMap.app]

lemma bergB_image_between {x y : ℤ} (h : IsNode x y) :
    2 * (bergB.app x y).2 < (bergB.app x y).1 ∧
      (bergB.app x y).1 < 3 * (bergB.app x y).2 := by
  have h1 := h.one_le
  have h2 := h.lt
  simp [bergB, IntMap.app]
  omega

lemma bergB_mem_image {m n : ℤ} (h : IsNode m n) (h1 : 2 * n < m) (h2 : m < 3 * n) :
    ∃ x y, IsNode x y ∧ bergB.app x y = (m, n) := by
  obtain ⟨t, ht⟩ := h.odd
  refine ⟨n, m - 2 * n, ⟨by omega, by omega, ?_, ⟨t - n, by omega⟩⟩, ?_⟩
  · exact isCoprime_of_unimodular h.cop (α := 0) (β := 1) (γ := 1) (δ := -2)
      (by ring) (by ring) (by norm_num)
  · simp [bergB, IntMap.app]

lemma bergC_image_gt {x y : ℤ} (h : IsNode x y) :
    3 * (bergC.app x y).2 < (bergC.app x y).1 := by
  have := h.lt
  simp [bergC, IntMap.app]
  omega

lemma bergC_mem_image {m n : ℤ} (h : IsNode m n) (hgt : 3 * n < m) :
    ∃ x y, IsNode x y ∧ bergC.app x y = (m, n) := by
  have h1 := h.one_le
  obtain ⟨t, ht⟩ := h.odd
  refine ⟨m - 2 * n, n, ⟨by omega, by omega, ?_, ⟨t - n, by omega⟩⟩, ?_⟩
  · exact isCoprime_of_unimodular h.cop (α := 1) (β := -2) (γ := 0) (δ := 1)
      (by ring) (by ring) (by norm_num)
  · simp [bergC, IntMap.app]

/-! ### Price branches -/

lemma priceP0_image_even {x y : ℤ} : Even (priceP0.app x y).2 := by
  simp [priceP0, IntMap.app]

lemma priceP0_mem_image {m n : ℤ} (h : IsNode m n) (he : Even n) :
    ∃ x y, IsNode x y ∧ priceP0.app x y = (m, n) := by
  have h1 := h.one_le
  have h2 := h.lt
  obtain ⟨t, ht⟩ := h.odd
  obtain ⟨k, hk⟩ := he
  have hn2 : n = 2 * k := by omega
  have hcop : IsCoprime m k := by rw [hn2] at h; exact h.cop.of_mul_right_right
  refine ⟨m - k, k, ⟨by omega, by omega, ?_, ⟨t - k, by omega⟩⟩, ?_⟩
  · exact isCoprime_of_unimodular hcop (α := 1) (β := -1) (γ := 0) (δ := 1)
      (by ring) (by ring) (by norm_num)
  · simp [priceP0, IntMap.app, hn2]

lemma priceP1_image_even_fst {x y : ℤ} : Even (priceP1.app x y).1 := by
  simp [priceP1, IntMap.app]

lemma priceP1_image_gt {x y : ℤ} (h : IsNode x y) :
    2 * (priceP1.app x y).2 < (priceP1.app x y).1 := by
  have := h.one_le
  simp [priceP1, IntMap.app]
  omega

lemma priceP1_mem_image {m n : ℤ} (h : IsNode m n) (he : Even m) (hgt : 2 * n < m) :
    ∃ x y, IsNode x y ∧ priceP1.app x y = (m, n) := by
  have h1 := h.one_le
  obtain ⟨t, ht⟩ := h.odd
  obtain ⟨j, hj⟩ := he
  have hm2 : m = 2 * j := by omega
  have hcop : IsCoprime j n := by rw [hm2] at h; exact h.cop.of_mul_left_right
  refine ⟨j, j - n, ⟨by omega, by omega, ?_, ⟨2 * j - t - 1, by omega⟩⟩, ?_⟩
  · exact isCoprime_of_unimodular hcop (α := 1) (β := 0) (γ := 1) (δ := -1)
      (by ring) (by ring) (by norm_num)
  · simp [priceP1, IntMap.app, hm2]

lemma priceP2_image_even_fst {x y : ℤ} : Even (priceP2.app x y).1 := by
  simp [priceP2, IntMap.app]

lemma priceP2_image_lt {x y : ℤ} (h : IsNode x y) :
    (priceP2.app x y).1 < 2 * (priceP2.app x y).2 := by
  have := h.one_le
  simp [priceP2, IntMap.app]
  omega

lemma priceP2_mem_image {m n : ℤ} (h : IsNode m n) (he : Even m) (hlt : m < 2 * n) :
    ∃ x y, IsNode x y ∧ priceP2.app x y = (m, n) := by
  have h1 := h.one_le
  have h2 := h.lt
  obtain ⟨t, ht⟩ := h.odd
  obtain ⟨j, hj⟩ := he
  have hm2 : m = 2 * j := by omega
  have hcop : IsCoprime j n := by rw [hm2] at h; exact h.cop.of_mul_left_right
  refine ⟨j, n - j, ⟨by omega, by omega, ?_, ⟨t - j, by omega⟩⟩, ?_⟩
  · exact isCoprime_of_unimodular hcop (α := 1) (β := 0) (γ := -1) (δ := 1)
      (by ring) (by ring) (by norm_num)
  · simp [priceP2, IntMap.app, hm2]

/-! ### The mixed branch -/

lemma mixF0_image_even_snd {x y : ℤ} : Even (mixF0.app x y).2 := by
  simp [mixF0, IntMap.app]

/-! ### Small nodes -/

/-- The nodes with `m ≤ 5` are exactly `(2,1), (3,2), (4,1), (4,3), (5,2), (5,4)`.
Parity alone rules out all other candidates. -/
lemma isNode_le_five {m n : ℤ} (h : IsNode m n) (h5 : m ≤ 5) :
    (m = 2 ∧ n = 1) ∨ (m = 3 ∧ n = 2) ∨ (m = 4 ∧ n = 1) ∨ (m = 4 ∧ n = 3) ∨
      (m = 5 ∧ n = 2) ∨ (m = 5 ∧ n = 4) := by
  have h1 := h.one_le
  have h2 := h.lt
  obtain ⟨t, ht⟩ := h.odd
  omega

/-- The only node with `m = 2` is the root, and the only node with `m = 3` is `(3,2)`. -/
lemma isNode_eq_two_or_three {m n : ℤ} (h : IsNode m n) (h3 : m ≤ 3) :
    (m = 2 ∧ n = 1) ∨ (m = 3 ∧ n = 2) := by
  have h1 := h.one_le
  have h2 := h.lt
  obtain ⟨t, ht⟩ := h.odd
  omega

/-- `(8,3)` is a node. -/
lemma isNode_eight_three : IsNode 8 3 :=
  ⟨by norm_num, by norm_num, ⟨-1, 3, by ring⟩, ⟨5, by ring⟩⟩

/-- `(9,4)` is a node. -/
lemma isNode_nine_four : IsNode 9 4 :=
  ⟨by norm_num, by norm_num, ⟨1, -2, by ring⟩, ⟨6, by ring⟩⟩

/-- `(7,2)` is a node. -/
lemma isNode_seven_two : IsNode 7 2 :=
  ⟨by norm_num, by norm_num, ⟨1, -3, by ring⟩, ⟨4, by ring⟩⟩

/-- `(5,2)` is a node. -/
lemma isNode_five_two : IsNode 5 2 :=
  ⟨by norm_num, by norm_num, ⟨1, -2, by ring⟩, ⟨3, by ring⟩⟩

/-- `(4,1)` is a node. -/
lemma isNode_four_one : IsNode 4 1 :=
  ⟨by norm_num, by norm_num, ⟨0, 1, by ring⟩, ⟨2, by ring⟩⟩

/-- `(4,3)` is a node. -/
lemma isNode_four_three : IsNode 4 3 :=
  ⟨by norm_num, by norm_num, ⟨1, -1, by ring⟩, ⟨3, by ring⟩⟩

end TernaryTree