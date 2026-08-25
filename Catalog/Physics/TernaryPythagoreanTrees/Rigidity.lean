import Physics.TernaryPythagoreanTrees.Tree

/-!
# Structural rigidity of ternary Pythagorean trees

Whatever the triple, a ternary tree of integer maps on the node set is forced to have a lot of
structure.  This file proves, for an *arbitrary* tree triple `T`:

* `TernaryTree.Preserves.a_pos`, `TernaryTree.Preserves.a_add_b_pos` : a node preserving map
  has `a ≥ 1` and `a + b ≥ 1`; so the first coordinate is monotone along the cone.
* `TernaryTree.Preserves.root_le_image_fst` : `2a + b ≤ a m + b n` on every node, i.e. the
  root minimises the first coordinate of the image.
* `TernaryTree.IsTernaryTree.lt_image_fst` : **every branch strictly increases `m`**, so the
  tree is graded by the first Euclid parameter.
* `TernaryTree.IsTernaryTree.exists_root_child_three_two` : in *every* ternary tree exactly one
  branch maps the root `(2,1)` to `(3,2)` — the node `(3,2)` is always a child of the root.
* `TernaryTree.IsTernaryTree.reach_all` : **generation theorem** — every node is obtained from
  the root by a finite word in the three branches.
* `TernaryTree.IsTernaryTree.det_natAbs_eq_two_pow` : each branch has determinant `±2^k`.
-/

namespace TernaryTree

/-- A node preserving map has positive `(1,1)` entry. -/
lemma Preserves.a_pos {M : IntMap} (hM : Preserves M) : 1 ≤ M.a := by
  have hc := hM.c_nonneg
  have hac := hM.a_sub_c_nonneg
  have hdet := hM.det_ne_zero
  by_contra h
  push_neg at h
  have ha : M.a = 0 := by omega
  have hc0 : M.c = 0 := by omega
  exact hdet (by simp [IntMap.det, ha, hc0])

/-- A node preserving map has `a + b ≥ 1`: the image of the "spine" direction `(1,1)` is
strictly inside the cone. -/
lemma Preserves.a_add_b_pos {M : IntMap} (hM : Preserves M) : 1 ≤ M.a + M.b := by
  have ha := hM.a_pos
  have hcd := hM.c_add_d_nonneg
  have hac := hM.a_sub_c_nonneg
  have hdiff := hM.diff_add_nonneg
  have hdet := hM.det_ne_zero
  have hab0 : 0 ≤ M.a + M.b := by omega
  by_contra h
  push_neg at h
  have hb : M.b = -M.a := by omega
  -- the spine nodes `(m, m-1)` all have image first coordinate `a`
  have hcd0 : M.c + M.d = 0 := by
    by_contra hcd1
    have hcd1' : 1 ≤ M.c + M.d := by omega
    have habs : (0 : ℤ) ≤ |M.d| := abs_nonneg M.d
    have hdle : M.d ≤ |M.d| := le_abs_self M.d
    have hm2 : (2 : ℤ) ≤ M.a + |M.d| + 2 := by omega
    have hkey := (hM (M.a + |M.d| + 2) (M.a + |M.d| + 2 - 1) (isNode_spine hm2)).lt
    simp only [IntMap.app_fst, IntMap.app_snd] at hkey
    have hstep : 1 * (M.a + |M.d| + 2) ≤ (M.c + M.d) * (M.a + |M.d| + 2) :=
      mul_le_mul_of_nonneg_right hcd1' (by omega)
    nlinarith [hkey, hstep]
  exact hdet (by simp only [IntMap.det, hb]; linear_combination M.a * hcd0)

/-- The root minimises the first coordinate of the image. -/
lemma Preserves.root_le_image_fst {M : IntMap} (hM : Preserves M) {m n : ℤ}
    (hnode : IsNode m n) : 2 * M.a + M.b ≤ (M.app m n).1 := by
  have ha := hM.a_pos
  have hab := hM.a_add_b_pos
  have h1 := hnode.one_le
  have h2 := hnode.lt
  simp only [IntMap.app_fst]
  rcases le_or_gt 0 M.b with hb | hb
  · nlinarith
  · nlinarith

/-- The identity is the only node preserving map with first row `(1, 0)`. -/
lemma Preserves.eq_id_of_row {M : IntMap} (hM : Preserves M) (ha : M.a = 1) (hb : M.b = 0) :
    M.c = 0 ∧ M.d = 1 := by
  obtain ⟨k, hk⟩ := hM.parity.1
  have hc0 : M.c = 0 := by
    have hc := hM.c_nonneg
    have hac := hM.a_sub_c_nonneg
    omega
  refine ⟨hc0, ?_⟩
  have hd1 : 1 ≤ M.d := by
    have := hM.c_add_d_nonneg
    have := hM.cd_ne_zero
    rcases eq_or_lt_of_le (show (0:ℤ) ≤ M.d by omega) with h | h
    · exact absurd ⟨hc0, h.symm⟩ this
    · omega
  obtain ⟨l, hl⟩ := hM.parity.2
  obtain ⟨j, hj⟩ := hM.det_natAbs_eq_two_pow
  have hdet : M.det = M.d := by simp [IntMap.det, ha, hb, hc0]
  have hodd : M.d = 2 * l + 1 := by omega
  rcases Nat.eq_zero_or_pos j with hj0 | hj0
  · subst hj0
    simp only [pow_zero] at hj
    omega
  · exfalso
    have : (2 : ℕ) ∣ M.det.natAbs := hj ▸ dvd_pow_self 2 (by omega)
    rw [hdet] at this
    omega

namespace IsTernaryTree

variable {T : Fin 3 → IntMap}

/-- No branch of a ternary tree is the identity-like map with first row `(1,0)`. -/
lemma not_row_one_zero (hT : IsTernaryTree T) (i : Fin 3) : ¬((T i).a = 1 ∧ (T i).b = 0) := by
  rintro ⟨ha, hb⟩
  obtain ⟨hc, hd⟩ := (hT.preserves i).eq_id_of_row ha hb
  exact hT.root_not_hit i 2 1 isNode_root (by simp [IntMap.app, ha, hb, hc, hd])

/-- **Every branch of a ternary tree strictly increases the first Euclid parameter.** -/
theorem lt_image_fst (hT : IsTernaryTree T) (i : Fin 3) {m n : ℤ} (hnode : IsNode m n) :
    m < ((T i).app m n).1 := by
  have hM := hT.preserves i
  have ha := hM.a_pos
  have hab := hM.a_add_b_pos
  have hne := hT.not_row_one_zero i
  have h1 := hnode.one_le
  have h2 := hnode.lt
  simp only [IntMap.app_fst]
  rcases le_or_gt 0 (T i).b with hb | hb
  · rcases eq_or_lt_of_le ha with ha1 | ha2
    · have hb1 : 1 ≤ (T i).b := by
        rcases eq_or_lt_of_le hb with hb0 | hb0
        · exact absurd ⟨ha1.symm, hb0.symm⟩ hne
        · omega
      nlinarith
    · nlinarith
  · nlinarith

/-- Every branch has determinant `±2^k` (the odd prime obstruction). -/
theorem det_natAbs_eq_two_pow (hT : IsTernaryTree T) (i : Fin 3) :
    ∃ k : ℕ, (T i).det.natAbs = 2 ^ k :=
  (hT.preserves i).det_natAbs_eq_two_pow

/-- **`(3,2)` is a child of the root in every ternary tree**, via a unique branch. -/
theorem exists_root_child_three_two (hT : IsTernaryTree T) :
    ∃! i : Fin 3, (T i).app 2 1 = (3, 2) := by
  have hnode : IsNode 3 2 := isNode_three_two
  have hne : ((3 : ℤ), (2 : ℤ)) ≠ (2, 1) := by simp
  obtain ⟨i, x, y, hxy, himg⟩ := hT.covers 3 2 hnode hne
  have hgrow := hT.lt_image_fst i hxy
  rw [himg] at hgrow
  have hx1 := hxy.one_le
  have hx2 := hxy.lt
  have hx : x = 2 := by simp at hgrow; omega
  have hy : y = 1 := by omega
  subst hx; subst hy
  refine ⟨i, himg, ?_⟩
  intro j hj
  exact ((hT.inj j i 2 1 2 1 isNode_root isNode_root (by rw [hj, himg])).1)

/-- Reachability from the root by finitely many branch applications. -/
inductive Reach (T : Fin 3 → IntMap) : ℤ → ℤ → Prop
  | root : Reach T 2 1
  | step (i : Fin 3) (m n : ℤ) : Reach T m n →
      Reach T ((T i).app m n).1 ((T i).app m n).2

/-- **Generation theorem**: in any ternary tree, every node is reached from the root `(2,1)`
by a finite word in the three branches. -/
theorem reach_all (hT : IsTernaryTree T) : ∀ m n : ℤ, IsNode m n → Reach T m n := by
  have key : ∀ k : ℕ, ∀ m n : ℤ, m.toNat ≤ k → IsNode m n → Reach T m n := by
    intro k
    induction k with
    | zero =>
      intro m n hk hnode
      have h1 := hnode.one_le
      have h2 := hnode.lt
      omega
    | succ k ih =>
      intro m n hk hnode
      by_cases hroot : ((m, n) : ℤ × ℤ) = (2, 1)
      · have hm : m = 2 := congrArg Prod.fst hroot
        have hn : n = 1 := congrArg Prod.snd hroot
        subst hm; subst hn
        exact Reach.root
      · obtain ⟨i, x, y, hxy, himg⟩ := hT.covers m n hnode hroot
        have hgrow := hT.lt_image_fst i hxy
        rw [himg] at hgrow
        have hx1 := hxy.one_le
        have hx2 := hxy.lt
        have hstep := Reach.step i x y (ih x y (by simp at hgrow; omega) hxy)
        rw [himg] at hstep
        exact hstep
  intro m n hnode
  exact key m.toNat m n le_rfl hnode

end IsTernaryTree

end TernaryTree