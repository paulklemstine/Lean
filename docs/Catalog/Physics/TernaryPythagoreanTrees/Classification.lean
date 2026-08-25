import Physics.TernaryPythagoreanTrees.RootChildren

/-!
# Classification of the ternary Pythagorean trees

**Main theorem** (`TernaryTree.tree_classification`): a triple of integer linear maps acting as
a ternary tree on the node set `{1 ≤ n < m, gcd(m,n) = 1, m + n odd}` with root `(2,1)` is,
up to relabelling, one of exactly three triples:

* the **Berggren** tree `{(2,-1;1,0), (2,1;1,0), (1,2;0,1)}`, determinants `1, -1, 1`;
* the **Price** tree `{(1,1;0,2), (2,0;1,-1), (2,0;1,1)}`, determinants `2, -2, 2`;
* the **mixed** tree `{(1,3;0,2), (2,-1;1,0), (2,0;1,-1)}`, determinants `2, 1, -2`.

In particular the conjecture that only the Berggren and the Price triples occur is false, and
the corrected statement is that there are exactly three.  All six matrices occurring have
`|det| ≤ 2`, so no ternary tree has a branch of determinant `|det| ≥ 3`
(`TernaryTree.no_branch_det_ge_three`).

The proof is a forcing argument:

1. `(3,2)` is always a child of the root, and the branch realising it is `bergA` or `priceP0`
   (`root_child_cases_32`).
2. Knowing one branch pins down the region left for the others, because the image of each
   classical branch is an explicit region of the node cone (`Images.lean`).
3. Root minimality (`Preserves.root_le_image_fst`) plus the list of nodes with `m ≤ 5` forces
   the root image of the next branch, and `RootChildren.lean` turns that into a short list of
   matrices; the extra candidates `exotic32`, `exotic52` are eliminated by exhibiting a node
   they cannot cover.
-/

namespace TernaryTree

lemma exotic52_image_even_snd {x y : ℤ} : Even (exotic52.app x y).2 := by
  simp [exotic52, IntMap.app]
  exact ⟨x - y, by ring⟩

/-- Given two distinct indices in `Fin 3` there is a third one. -/
lemma exists_third (i0 j : Fin 3) (h : j ≠ i0) :
    ∃ k : Fin 3, k ≠ i0 ∧ k ≠ j ∧ ∀ i : Fin 3, i = i0 ∨ i = j ∨ i = k := by
  revert h; revert i0 j; decide

namespace IsTernaryTree

variable {T : Fin 3 → IntMap}

/-- Root minimality, in the form used below. -/
lemma root_le (hT : IsTernaryTree T) (i : Fin 3) {x y : ℤ} (hxy : IsNode x y) :
    ((T i).app 2 1).1 ≤ ((T i).app x y).1 := by
  have h := (hT.preserves i).root_le_image_fst hxy
  simp only [IntMap.app_fst] at h ⊢
  omega

/-- The image of the root under any branch is a node different from the root, so its first
coordinate is at least `3`. -/
lemma three_le_root_image (hT : IsTernaryTree T) (i : Fin 3) :
    3 ≤ ((T i).app 2 1).1 := by
  have hnode := hT.preserves i 2 1 isNode_root
  have hne := hT.root_not_hit i 2 1 isNode_root
  by_contra hlt
  push_neg at hlt
  rcases isNode_eq_two_or_three hnode (by omega) with ⟨h1, h2⟩ | ⟨h1, _⟩
  · exact hne (Prod.ext_iff.2 ⟨h1, h2⟩)
  · omega

end IsTernaryTree

/-- Every ternary tree contains `bergA` or `priceP0`: the branch that produces the child
`(3,2)` of the root. -/
theorem exists_bergA_or_priceP0 {T : Fin 3 → IntMap} (hT : IsTernaryTree T) :
    ∃ i, T i = bergA ∨ T i = priceP0 := by
  obtain ⟨i, hi, -⟩ := hT.exists_root_child_three_two
  exact ⟨i, root_child_cases_32 (hT.preserves i) hi⟩

/-- **Classification, case `bergA`.** -/
theorem classification_of_bergA {T : Fin 3 → IntMap} (hT : IsTernaryTree T) {i0 : Fin 3}
    (hi0 : T i0 = bergA) :
    (∀ i, T i = bergA ∨ T i = bergB ∨ T i = bergC) ∨
      (∀ i, T i = bergA ∨ T i = priceP1 ∨ T i = mixF0) := by
  -- outside the `bergA` region every other branch has `2n < m`
  have hregion : ∀ j : Fin 3, j ≠ i0 → ∀ x y : ℤ, IsNode x y →
      2 * ((T j).app x y).2 < ((T j).app x y).1 := by
    intro j hj x y hxy
    have hnode := hT.preserves j x y hxy
    rcases lt_trichotomy ((T j).app x y).1 (2 * ((T j).app x y).2) with hlt | heq | hgt
    · obtain ⟨u, v, huv, himg⟩ := bergA_mem_image hnode hlt
      rw [← hi0] at himg
      exact absurd (hT.inj i0 j u v x y huv hxy (by rw [himg])).1 (Ne.symm hj)
    · exfalso
      have hn1 := eq_one_of_dvd_node hnode (k := 2) (by omega)
      exact hT.root_not_hit j x y hxy (Prod.ext_iff.2 ⟨by omega, by omega⟩)
    · exact hgt
  -- the node `(4,1)` is covered by a branch different from `i0`
  obtain ⟨j, x, y, hxy, himg⟩ := hT.covers 4 1 isNode_four_one (by simp)
  have hj : j ≠ i0 := by
    rintro rfl
    rw [hi0] at himg
    have h := bergA_image_lt hxy
    rw [himg] at h
    simp at h
  -- its root image is `(4,1)`
  have hroot41 : (T j).app 2 1 = (4, 1) := by
    have hle : ((T j).app 2 1).1 ≤ 4 := by
      have h := hT.root_le j hxy
      rw [himg] at h
      exact h
    have hge := hT.three_le_root_image j
    have hnode := hT.preserves j 2 1 isNode_root
    have hreg := hregion j hj 2 1 isNode_root
    have hpq : ((T j).app 2 1).1 = 4 ∧ ((T j).app 2 1).2 = 1 := by
      rcases isNode_le_five hnode (by omega) with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ |
        ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
    exact Prod.ext_iff.2 ⟨hpq.1, hpq.2⟩
  obtain ⟨k, hk0, hkj, hall⟩ := exists_third i0 j hj
  rcases root_child_cases_41 (hT.preserves j) hroot41 with hjC | hjP1
  · -- Berggren
    left
    have hregionk : ∀ x y : ℤ, IsNode x y →
        2 * ((T k).app x y).2 < ((T k).app x y).1 ∧
          ((T k).app x y).1 < 3 * ((T k).app x y).2 := by
      intro x y hxy'
      refine ⟨hregion k hk0 x y hxy', ?_⟩
      have hnode := hT.preserves k x y hxy'
      rcases lt_trichotomy ((T k).app x y).1 (3 * ((T k).app x y).2) with hlt | heq | hgt
      · exact hlt
      · exfalso
        have hn1 := eq_one_of_dvd_node hnode (k := 3) (by omega)
        rcases isNode_eq_two_or_three hnode (by omega) with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
      · exfalso
        obtain ⟨u, v, huv, himg'⟩ := bergC_mem_image hnode hgt
        rw [← hjC] at himg'
        exact hkj (hT.inj k j x y u v hxy' huv (by rw [himg'])).1
    -- `(5,2)` must be covered by `k`
    obtain ⟨l, u, v, huv, himg5⟩ := hT.covers 5 2 isNode_five_two (by simp)
    have hlk : l = k := by
      rcases hall l with rfl | rfl | rfl
      · exfalso
        rw [hi0] at himg5
        have h := bergA_image_lt huv
        rw [himg5] at h
        simp at h
      · exfalso
        rw [hjC] at himg5
        have h := bergC_image_gt huv
        rw [himg5] at h
        simp at h
      · rfl
    subst hlk
    have hroot52 : (T l).app 2 1 = (5, 2) := by
      have hle : ((T l).app 2 1).1 ≤ 5 := by
        have h := hT.root_le l huv
        rw [himg5] at h
        exact h
      have hge := hT.three_le_root_image l
      have hnode := hT.preserves l 2 1 isNode_root
      obtain ⟨hr1, hr2⟩ := hregionk 2 1 isNode_root
      have hpq : ((T l).app 2 1).1 = 5 ∧ ((T l).app 2 1).2 = 2 := by
        rcases isNode_le_five hnode (by omega) with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ |
          ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
      exact Prod.ext_iff.2 ⟨hpq.1, hpq.2⟩
    -- the node `(8,3)` must be covered by `l` as well, which rules out the exotic candidates
    obtain ⟨l', u', v', huv', himg8⟩ := hT.covers 8 3 isNode_eight_three (by simp)
    have hl' : l' = l := by
      rcases hall l' with rfl | rfl | rfl
      · exfalso
        rw [hi0] at himg8
        have h := bergA_image_lt huv'
        rw [himg8] at h
        simp at h
      · exfalso
        rw [hjC] at himg8
        have h := bergC_image_gt huv'
        rw [himg8] at h
        simp at h
      · rfl
    subst hl'
    have hlB : T l' = bergB := by
      rcases root_child_cases_52 (hT.preserves l') hroot52 with h | h | h
      · exfalso
        rw [h] at himg8
        have hev := mixF0_image_even_snd (x := u') (y := v')
        rw [himg8] at hev
        simp [Int.even_iff] at hev
      · exact h
      · exfalso
        rw [h] at himg8
        have hev := exotic52_image_even_snd (x := u') (y := v')
        rw [himg8] at hev
        simp [Int.even_iff] at hev
    intro i
    rcases hall i with rfl | rfl | rfl
    · exact Or.inl hi0
    · exact Or.inr (Or.inr hjC)
    · exact Or.inr (Or.inl hlB)
  · -- mixed tree
    right
    have hoddk : ∀ x y : ℤ, IsNode x y → ¬ Even ((T k).app x y).1 := by
      intro x y hxy' heven
      have hnode := hT.preserves k x y hxy'
      obtain ⟨u, v, huv, himg'⟩ :=
        priceP1_mem_image hnode heven (hregion k hk0 x y hxy')
      rw [← hjP1] at himg'
      exact hkj (hT.inj k j x y u v hxy' huv (by rw [himg'])).1
    obtain ⟨l, u, v, huv, himg5⟩ := hT.covers 5 2 isNode_five_two (by simp)
    have hlk : l = k := by
      rcases hall l with rfl | rfl | rfl
      · exfalso
        rw [hi0] at himg5
        have h := bergA_image_lt huv
        rw [himg5] at h
        simp at h
      · exfalso
        rw [hjP1] at himg5
        have h := priceP1_image_even_fst (x := u) (y := v)
        rw [himg5] at h
        simp [Int.even_iff] at h
      · rfl
    subst hlk
    have hroot52 : (T l).app 2 1 = (5, 2) := by
      have hle : ((T l).app 2 1).1 ≤ 5 := by
        have h := hT.root_le l huv
        rw [himg5] at h
        exact h
      have hge := hT.three_le_root_image l
      have hnode := hT.preserves l 2 1 isNode_root
      have hreg := hregion l hk0 2 1 isNode_root
      obtain ⟨s, hs⟩ := Int.not_even_iff_odd.1 (hoddk 2 1 isNode_root)
      have hpq : ((T l).app 2 1).1 = 5 ∧ ((T l).app 2 1).2 = 2 := by
        rcases isNode_le_five hnode (by omega) with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ |
          ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
      exact Prod.ext_iff.2 ⟨hpq.1, hpq.2⟩
    -- `(9,4)` must be covered by `l`, ruling out `exotic52`; `bergB` is ruled out because it
    -- produces the even node `(8,3)`
    obtain ⟨l', u', v', huv', himg9⟩ := hT.covers 9 4 isNode_nine_four (by simp)
    have hl' : l' = l := by
      rcases hall l' with rfl | rfl | rfl
      · exfalso
        rw [hi0] at himg9
        have h := bergA_image_lt huv'
        rw [himg9] at h
        simp at h
      · exfalso
        rw [hjP1] at himg9
        have h := priceP1_image_even_fst (x := u') (y := v')
        rw [himg9] at h
        simp [Int.even_iff] at h
      · rfl
    subst hl'
    have hlF : T l' = mixF0 := by
      rcases root_child_cases_52 (hT.preserves l') hroot52 with h | h | h
      · exact h
      · exfalso
        have hb := hoddk 3 2 isNode_three_two
        rw [h] at hb
        simp [bergB, IntMap.app, Int.even_iff] at hb
      · exfalso
        rw [h] at himg9
        simp [exotic52, IntMap.app, Prod.ext_iff] at himg9
        omega
    intro i
    rcases hall i with rfl | rfl | rfl
    · exact Or.inl hi0
    · exact Or.inr (Or.inl hjP1)
    · exact Or.inr (Or.inr hlF)

/-- **Classification, case `priceP0`.** -/
theorem classification_of_priceP0 {T : Fin 3 → IntMap} (hT : IsTernaryTree T) {i0 : Fin 3}
    (hi0 : T i0 = priceP0) :
    ∀ i, T i = priceP0 ∨ T i = priceP1 ∨ T i = priceP2 := by
  -- outside the `priceP0` region every other branch has odd second coordinate
  have hodd : ∀ j : Fin 3, j ≠ i0 → ∀ x y : ℤ, IsNode x y → ¬ Even ((T j).app x y).2 := by
    intro j hj x y hxy heven
    have hnode := hT.preserves j x y hxy
    obtain ⟨u, v, huv, himg⟩ := priceP0_mem_image hnode heven
    rw [← hi0] at himg
    exact absurd (hT.inj i0 j u v x y huv hxy (by rw [himg])).1 (Ne.symm hj)
  obtain ⟨j, x, y, hxy, himg⟩ := hT.covers 4 1 isNode_four_one (by simp)
  have hj : j ≠ i0 := by
    rintro rfl
    rw [hi0] at himg
    have h := priceP0_image_even (x := x) (y := y)
    rw [himg] at h
    simp [Int.even_iff] at h
  have hx3 : x ≤ 3 := by
    have h := hT.lt_image_fst j hxy
    rw [himg] at h
    simp at h
    omega
  have hle : ((T j).app 2 1).1 ≤ 4 := by
    have h := hT.root_le j hxy
    rw [himg] at h
    exact h
  have hge := hT.three_le_root_image j
  have hnodej := hT.preserves j 2 1 isNode_root
  obtain ⟨s, hs⟩ := Int.not_even_iff_odd.1 (hodd j hj 2 1 isNode_root)
  have hroot41 : (T j).app 2 1 = (4, 1) := by
    have hpq : ((T j).app 2 1).1 = 4 ∧ ((T j).app 2 1).2 = 1 := by
      rcases isNode_le_five hnodej (by omega) with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ |
        ⟨h1, h2⟩ | ⟨h1, h2⟩
      · exact absurd h1 (by omega)
      · exact absurd h2 (by omega)
      · exact ⟨h1, h2⟩
      · -- root image `(4,3)`: forces `T j ∈ {priceP2, exotic32}`, neither of which maps a node
        -- with `x ≤ 3` to `(4,1)`
        exfalso
        have hroot43 : (T j).app 2 1 = (4, 3) := Prod.ext_iff.2 ⟨h1, h2⟩
        rcases isNode_eq_two_or_three hxy hx3 with ⟨hx2, hy1⟩ | ⟨hx3', hy2⟩
        · rw [hx2, hy1] at himg
          rw [himg] at hroot43
          simp [Prod.ext_iff] at hroot43
        · rcases root_child_cases_43 (hT.preserves j) hroot43 with hP2 | hE
          · rw [hx3', hy2, hP2] at himg
            simp [priceP2, IntMap.app, Prod.ext_iff] at himg
          · rw [hx3', hy2, hE] at himg
            simp [exotic32, IntMap.app, Prod.ext_iff] at himg
      · exact absurd h1 (by omega)
      · exact absurd h1 (by omega)
    exact Prod.ext_iff.2 ⟨hpq.1, hpq.2⟩
  have hjP1 : T j = priceP1 := by
    rcases root_child_cases_41 (hT.preserves j) hroot41 with hC | hP1
    · exfalso
      have hb := hodd j hj 3 2 isNode_three_two
      rw [hC] at hb
      simp [bergC, IntMap.app] at hb
    · exact hP1
  obtain ⟨k, hk0, hkj, hall⟩ := exists_third i0 j hj
  -- the third branch lives in `m < 2n`
  have hregionk : ∀ x y : ℤ, IsNode x y → ((T k).app x y).1 < 2 * ((T k).app x y).2 := by
    intro x y hxy'
    have hnode := hT.preserves k x y hxy'
    obtain ⟨r, hr⟩ := Int.not_even_iff_odd.1 (hodd k hk0 x y hxy')
    obtain ⟨t, ht⟩ := hnode.odd
    have heven : Even ((T k).app x y).1 := ⟨t - r, by omega⟩
    rcases lt_trichotomy ((T k).app x y).1 (2 * ((T k).app x y).2) with hlt | heq | hgt
    · exact hlt
    · exfalso
      have hn1 := eq_one_of_dvd_node hnode (k := 2) (by omega)
      exact hT.root_not_hit k x y hxy' (Prod.ext_iff.2 ⟨by omega, by omega⟩)
    · exfalso
      obtain ⟨u, v, huv, himg'⟩ := priceP1_mem_image hnode heven hgt
      rw [← hjP1] at himg'
      exact hkj (hT.inj k j x y u v hxy' huv (by rw [himg'])).1
  -- `(4,3)` is covered by the third branch
  obtain ⟨l, u, v, huv, himg43⟩ := hT.covers 4 3 isNode_four_three (by simp)
  have hlk : l = k := by
    rcases hall l with rfl | rfl | rfl
    · exfalso
      rw [hi0] at himg43
      have h := priceP0_image_even (x := u) (y := v)
      rw [himg43] at h
      simp [Int.even_iff] at h
    · exfalso
      rw [hjP1] at himg43
      have h := priceP1_image_gt huv
      rw [himg43] at h
      simp at h
    · rfl
  subst hlk
  have hroot43 : (T l).app 2 1 = (4, 3) := by
    have hle' : ((T l).app 2 1).1 ≤ 4 := by
      have h := hT.root_le l huv
      rw [himg43] at h
      exact h
    have hge' := hT.three_le_root_image l
    have hnodel := hT.preserves l 2 1 isNode_root
    obtain ⟨r, hr⟩ := Int.not_even_iff_odd.1 (hodd l hk0 2 1 isNode_root)
    have hregl := hregionk 2 1 isNode_root
    have hpq : ((T l).app 2 1).1 = 4 ∧ ((T l).app 2 1).2 = 3 := by
      rcases isNode_le_five hnodel (by omega) with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ |
        ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
    exact Prod.ext_iff.2 ⟨hpq.1, hpq.2⟩
  have hlP2 : T l = priceP2 := by
    rcases root_child_cases_43 (hT.preserves l) hroot43 with h | h
    · exact h
    · exfalso
      have hb := hodd l hk0 3 2 isNode_three_two
      rw [h] at hb
      simp [exotic32, IntMap.app, Int.even_iff] at hb
  intro i
  rcases hall i with rfl | rfl | rfl
  · exact Or.inl hi0
  · exact Or.inr (Or.inl hjP1)
  · exact Or.inr (Or.inr hlP2)

/-- **Classification of the ternary Pythagorean trees.**  Up to relabelling there are exactly
three: Berggren's, Price's and the mixed one. -/
theorem tree_classification {T : Fin 3 → IntMap} (hT : IsTernaryTree T) :
    (∀ i, T i = bergA ∨ T i = bergB ∨ T i = bergC) ∨
      (∀ i, T i = priceP0 ∨ T i = priceP1 ∨ T i = priceP2) ∨
      (∀ i, T i = bergA ∨ T i = priceP1 ∨ T i = mixF0) := by
  obtain ⟨i0, hA | hP⟩ := exists_bergA_or_priceP0 hT
  · rcases classification_of_bergA hT hA with h | h
    · exact Or.inl h
    · exact Or.inr (Or.inr h)
  · exact Or.inr (Or.inl (classification_of_priceP0 hT hP))

/-- **No branch of a ternary Pythagorean tree has `|det| ≥ 3`.**  This is the precise form of
the `±2` obstruction for trees: all six matrices occurring have determinant `±1` or `±2`. -/
theorem no_branch_det_ge_three {T : Fin 3 → IntMap} (hT : IsTernaryTree T) (i : Fin 3) :
    (T i).det.natAbs ≤ 2 := by
  rcases tree_classification hT with h | h | h <;> rcases h i with h' | h' | h' <;>
    rw [h'] <;> simp [bergA, bergB, bergC, priceP0, priceP1, priceP2, mixF0, IntMap.det]

/-- The three branches of a ternary tree are pairwise distinct maps. -/
theorem branches_injective {T : Fin 3 → IntMap} (hT : IsTernaryTree T) :
    Function.Injective T := by
  intro i j hij
  exact (hT.inj i j 2 1 2 1 isNode_root isNode_root (by rw [hij])).1

/-- **Classification, set form.**  The *set* of branches of a ternary Pythagorean tree is
exactly one of the three admissible triples; combined with `branches_injective` this says the
tree is one of the three, up to relabelling of the branches. -/
theorem tree_classification_set {T : Fin 3 → IntMap} (hT : IsTernaryTree T) :
    ({T 0, T 1, T 2} : Set IntMap) = {bergA, bergB, bergC} ∨
      ({T 0, T 1, T 2} : Set IntMap) = {priceP0, priceP1, priceP2} ∨
      ({T 0, T 1, T 2} : Set IntMap) = {bergA, priceP1, mixF0} := by
  have hinj := branches_injective hT
  have h01 : T 0 ≠ T 1 := fun h => by simpa using hinj h
  have h02 : T 0 ≠ T 2 := fun h => by simpa using hinj h
  have h12 : T 1 ≠ T 2 := fun h => by simpa using hinj h
  rcases tree_classification hT with h | h | h
  · refine Or.inl ?_
    rcases h 0 with e0 | e0 | e0 <;> rcases h 1 with e1 | e1 | e1 <;>
      rcases h 2 with e2 | e2 | e2 <;> simp only [e0, e1, e2] at h01 h02 h12 ⊢ <;>
      first
        | exact absurd rfl h01
        | exact absurd rfl h02
        | exact absurd rfl h12
        | (ext x; simp; tauto)
  · refine Or.inr (Or.inl ?_)
    rcases h 0 with e0 | e0 | e0 <;> rcases h 1 with e1 | e1 | e1 <;>
      rcases h 2 with e2 | e2 | e2 <;> simp only [e0, e1, e2] at h01 h02 h12 ⊢ <;>
      first
        | exact absurd rfl h01
        | exact absurd rfl h02
        | exact absurd rfl h12
        | (ext x; simp; tauto)
  · refine Or.inr (Or.inr ?_)
    rcases h 0 with e0 | e0 | e0 <;> rcases h 1 with e1 | e1 | e1 <;>
      rcases h 2 with e2 | e2 | e2 <;> simp only [e0, e1, e2] at h01 h02 h12 ⊢ <;>
      first
        | exact absurd rfl h01
        | exact absurd rfl h02
        | exact absurd rfl h12
        | (ext x; simp; tauto)

end TernaryTree