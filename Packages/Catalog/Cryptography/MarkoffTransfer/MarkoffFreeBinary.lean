import Cryptography.MarkoffTransfer.MarkoffCore

/-!
# The Markoff Tree is a Free **Binary** Tree

The Berggren tree of primitive Pythagorean triples is a free **ternary** tree: the three
Berggren moves generate a free monoid of rank `3` (see
`Cryptography/BerggrenTrees/BerggrenFreeMonoid.lean`, `evalPair_injective`).

Here we prove the exact Markoff analogue, which is the "transfer" of that machinery to the
Markoff side — with rank `2` instead of `3`:

* `parent_childL` / `parent_childR` — **unique parent**: the descent map inverts both
  ascending Vieta moves.  This is the Markoff counterpart of `actGen_unique_parent`.
* `childL_ne_childR` — the two children of a strictly ordered node are distinct.
* `mEval_injective` — **freeness**: the evaluation of binary words at the root `(1,2,5)`
  is injective, so the Markoff tree is a free binary tree.
* `mLevel_card` — level `n` of the Markoff tree has exactly `2 ^ n` nodes.

Every node of the tree is a strictly ordered positive Markoff triple (`StrictM`), so the
whole development stays inside the Markoff surface.
-/

namespace MarkoffTransfer

/-! ## Strictly ordered Markoff triples -/

/-- A *node* of the Markoff tree: a strictly increasing positive Markoff triple whose top
entry is at least `5` (equivalently: any Markoff triple other than the three singular ones
`(1,1,1)`, `(1,1,2)`, `(1,2,2)`, up to ordering). -/
def StrictM (t : ℤ × ℤ × ℤ) : Prop :=
  0 < t.1 ∧ t.1 < t.2.1 ∧ t.2.1 < t.2.2 ∧ 5 ≤ t.2.2 ∧ IsMarkoff t.1 t.2.1 t.2.2

/-- The root of the Markoff tree (the smallest non-singular triple). -/
def mRoot : ℤ × ℤ × ℤ := (1, 2, 5)

theorem strictM_mRoot : StrictM mRoot := by
  refine ⟨by norm_num [mRoot], by norm_num [mRoot], by norm_num [mRoot], by norm_num [mRoot], ?_⟩
  rw [isMarkoff_iff]; norm_num [mRoot]

/-! ## The two ascending Vieta moves -/

/-- Left child: apply the Vieta move in the middle coordinate. -/
def childL (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ := (t.1, t.2.2, 3 * t.1 * t.2.2 - t.2.1)

/-- Right child: apply the Vieta move in the first coordinate. -/
def childR (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ := (t.2.1, t.2.2, 3 * t.2.1 * t.2.2 - t.1)

/-- The child selected by a bit. -/
def child : Bool → (ℤ × ℤ × ℤ) → ℤ × ℤ × ℤ
  | false => childL
  | true => childR

/-- The descent (parent) map: apply the Vieta move to the top coordinate and re-sort. -/
def mParent (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  if 3 * t.1 * t.2.1 - t.2.2 ≤ t.1 then (3 * t.1 * t.2.1 - t.2.2, t.1, t.2.1)
  else (t.1, 3 * t.1 * t.2.1 - t.2.2, t.2.1)

/-! ## Children are nodes -/

theorem StrictM.childL {t : ℤ × ℤ × ℤ} (h : StrictM t) : StrictM (childL t) := by
  obtain ⟨h1, h2, h3, h5, hM⟩ := h
  refine ⟨h1, lt_trans h2 h3, ?_, ?_, ?_⟩
  · -- `3 x z - y > z` since `x ≥ 1` and `z > y`
    simp only [MarkoffTransfer.childL]
    nlinarith [h1, h2, h3]
  · simp only [MarkoffTransfer.childL]
    nlinarith [h1, h2, h3, h5]
  · -- Markoff: from `(x, y, z)` swap to `(x, z, y)` then Vieta in the last slot
    have := markoff_vieta (hM.swap₂₃)
    simpa [MarkoffTransfer.childL, vieta] using this

theorem StrictM.childR {t : ℤ × ℤ × ℤ} (h : StrictM t) : StrictM (childR t) := by
  obtain ⟨h1, h2, h3, h5, hM⟩ := h
  refine ⟨lt_trans h1 h2, h3, ?_, ?_, ?_⟩
  · simp only [MarkoffTransfer.childR]
    nlinarith [h1, h2, h3]
  · simp only [MarkoffTransfer.childR]
    nlinarith [h1, h2, h3, h5]
  · have := markoff_vieta ((hM.swap₁₂).swap₂₃)
    simpa [MarkoffTransfer.childR, vieta] using this

theorem StrictM.child {t : ℤ × ℤ × ℤ} (b : Bool) (h : StrictM t) : StrictM (child b t) := by
  cases b
  · exact h.childL
  · exact h.childR

/-! ## Unique parent -/

theorem parent_childL {t : ℤ × ℤ × ℤ} (h : StrictM t) : mParent (childL t) = t := by
  obtain ⟨h1, h2, h3, _, _⟩ := h
  obtain ⟨x, y, z⟩ := t
  simp only [MarkoffTransfer.childL, mParent] at *
  have hval : 3 * x * z - (3 * x * z - y) = y := by ring
  rw [hval]
  rw [if_neg (by omega)]

theorem parent_childR {t : ℤ × ℤ × ℤ} (h : StrictM t) : mParent (childR t) = t := by
  obtain ⟨h1, h2, h3, _, _⟩ := h
  obtain ⟨x, y, z⟩ := t
  simp only [MarkoffTransfer.childR, mParent] at *
  have hval : 3 * y * z - (3 * y * z - x) = x := by ring
  rw [hval]
  rw [if_pos (by omega)]

theorem parent_child {t : ℤ × ℤ × ℤ} (b : Bool) (h : StrictM t) : mParent (child b t) = t := by
  cases b
  · exact parent_childL h
  · exact parent_childR h

/-- Both ascending moves are injective on nodes. -/
theorem child_injOn (b : Bool) {s t : ℤ × ℤ × ℤ} (hs : StrictM s) (ht : StrictM t)
    (h : child b s = child b t) : s = t := by
  rw [← parent_child b hs, ← parent_child b ht, h]

/-- **The two children of a node are distinct**: the Markoff tree branches exactly twice. -/
theorem childL_ne_childR {t : ℤ × ℤ × ℤ} (h : StrictM t) : childL t ≠ childR t := by
  obtain ⟨h1, h2, h3, _, _⟩ := h
  intro hEq
  have hfst := congrArg Prod.fst hEq
  simp only [MarkoffTransfer.childL, MarkoffTransfer.childR] at hfst
  omega

/-- The images of the two ascending moves are disjoint on nodes. -/
theorem childL_ne_childR_of_nodes {s t : ℤ × ℤ × ℤ} (hs : StrictM s) (ht : StrictM t) :
    childL s ≠ childR t := by
  intro h
  have hst : s = t := by
    have h1 : mParent (childL s) = s := parent_childL hs
    have h2 : mParent (childR t) = t := parent_childR ht
    rw [← h1, ← h2, h]
  subst hst
  exact childL_ne_childR hs h

/-! ## Freeness: the tree of binary words -/

/-- Evaluation of a binary word at the root: the Markoff analogue of `evalPair`. -/
def mEval : List Bool → ℤ × ℤ × ℤ
  | [] => mRoot
  | b :: w => child b (mEval w)

theorem strictM_mEval (w : List Bool) : StrictM (mEval w) := by
  induction w with
  | nil => exact strictM_mRoot
  | cons b rest ih => exact ih.child b

/-- A child always has a strictly larger top entry than its parent, hence is never the root. -/
theorem top_lt_child_top {t : ℤ × ℤ × ℤ} (b : Bool) (h : StrictM t) :
    t.2.2 < (child b t).2.2 := by
  obtain ⟨h1, h2, h3, _, _⟩ := h
  cases b <;> simp only [child, MarkoffTransfer.childL, MarkoffTransfer.childR] <;> nlinarith

theorem child_ne_mRoot {t : ℤ × ℤ × ℤ} (b : Bool) (h : StrictM t) : child b t ≠ mRoot := by
  intro hc
  have h5 : (5 : ℤ) ≤ t.2.2 := h.2.2.2.1
  have := top_lt_child_top b h
  rw [hc] at this
  simp only [mRoot] at this
  omega

/-- **Freeness of the Markoff tree.**  Distinct binary words give distinct Markoff triples;
this is the rank-`2` counterpart of the Berggren free monoid of rank `3`. -/
theorem mEval_injective : Function.Injective mEval := by
  intro w₁
  induction w₁ with
  | nil =>
      intro w₂ h
      match w₂ with
      | [] => rfl
      | b :: rest => exact absurd h.symm (child_ne_mRoot b (strictM_mEval rest))
  | cons b₁ rest₁ ih =>
      intro w₂ h
      match w₂ with
      | [] => exact absurd h (child_ne_mRoot b₁ (strictM_mEval rest₁))
      | b₂ :: rest₂ =>
        have hb : b₁ = b₂ := by
          by_contra hne
          have hb' : b₂ = !b₁ := by cases b₁ <;> cases b₂ <;> simp_all
          subst hb'
          cases b₁ with
          | false =>
              exact childL_ne_childR_of_nodes (strictM_mEval rest₁) (strictM_mEval rest₂) h
          | true =>
              exact childL_ne_childR_of_nodes (strictM_mEval rest₂) (strictM_mEval rest₁) h.symm
        subst hb
        have := child_injOn b₁ (strictM_mEval rest₁) (strictM_mEval rest₂) h
        exact congrArg (b₁ :: ·) (ih this)

/-! ## Level counts: `2 ^ n` -/

/-- Level `n` of the Markoff tree, as a finite set of triples. -/
def mLevel : ℕ → Finset (ℤ × ℤ × ℤ)
  | 0 => {mRoot}
  | n + 1 => (mLevel n).image childL ∪ (mLevel n).image childR

theorem mLevel_strict : ∀ (n : ℕ), ∀ t ∈ mLevel n, StrictM t := by
  intro n
  induction n with
  | zero =>
      intro t ht
      simp only [mLevel, Finset.mem_singleton] at ht
      subst ht; exact strictM_mRoot
  | succ n ih =>
      intro t ht
      simp only [mLevel, Finset.mem_union, Finset.mem_image] at ht
      rcases ht with ⟨s, hs, rfl⟩ | ⟨s, hs, rfl⟩
      · exact (ih s hs).childL
      · exact (ih s hs).childR

/-- **The Markoff tree has exactly `2 ^ n` nodes at depth `n`.** -/
theorem mLevel_card : ∀ n : ℕ, (mLevel n).card = 2 ^ n := by
  intro n
  induction n with
  | zero => simp [mLevel]
  | succ n ih =>
      have hL : ((mLevel n).image childL).card = 2 ^ n := by
        rw [Finset.card_image_of_injOn, ih]
        intro a ha b hb hab
        exact child_injOn false (mLevel_strict n a ha) (mLevel_strict n b hb) hab
      have hR : ((mLevel n).image childR).card = 2 ^ n := by
        rw [Finset.card_image_of_injOn, ih]
        intro a ha b hb hab
        exact child_injOn true (mLevel_strict n a ha) (mLevel_strict n b hb) hab
      have hdisj : Disjoint ((mLevel n).image childL) ((mLevel n).image childR) := by
        rw [Finset.disjoint_left]
        rintro t ht ht'
        simp only [Finset.mem_image] at ht ht'
        obtain ⟨a, ha, rfl⟩ := ht
        obtain ⟨b, hb, hbt⟩ := ht'
        exact childL_ne_childR_of_nodes (mLevel_strict n a ha) (mLevel_strict n b hb) hbt.symm
      simp only [mLevel]
      rw [Finset.card_union_of_disjoint hdisj, hL, hR]
      ring

/-- Every node of every level lies on the Markoff surface. -/
theorem mLevel_isMarkoff {n : ℕ} {t : ℤ × ℤ × ℤ} (ht : t ∈ mLevel n) :
    IsMarkoff t.1 t.2.1 t.2.2 := (mLevel_strict n t ht).2.2.2.2

end MarkoffTransfer