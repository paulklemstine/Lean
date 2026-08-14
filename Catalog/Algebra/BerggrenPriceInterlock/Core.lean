import Mathlib

/-!
# Berggren–Price interlock, Part I: an abstract ternary descent framework

Both classical trees of primitive Pythagorean triples (Barning–Hall–Berggren and Price)
become, in the *Euclid parameter* coordinates `(m, n)`, ternary trees on the set

  `Node = {(m,n) : 1 ≤ n < m, gcd(m,n) = 1, m + n odd}`

rooted at `(2,1)`.  This file isolates the purely combinatorial content that makes such a
family of three maps a *tree*: every node is `applyWord w root` for a **unique** word `w`.

The five hypotheses are: the maps preserve nodes, strictly increase the size `m + n`,
are injective, have pairwise disjoint images on nodes, and every non-root node has a
parent.  Both concrete trees are shown to satisfy them in
`Algebra.BerggrenPriceInterlock.Trees`.

## Main results

* `IsNode.size_ge` — every node has size `≥ 3`, with equality only at the root.
* `exists_word` — existence of a root-to-node word (Fermat descent).
* `word_unique` — uniqueness of that word (disjointness of the three subtrees).
* `exists_unique_word` — the two combined: the tree is a bijection `words ≃ nodes`.
-/

namespace BerggrenPrice

/-- A node of either Pythagorean tree, in Euclid parameters `(m, n)`. -/
abbrev Node := ℤ × ℤ

/-- Valid Euclid parameters: `1 ≤ n < m`, coprime, of opposite parity. -/
def IsNode (v : Node) : Prop :=
  1 ≤ v.2 ∧ v.2 < v.1 ∧ IsCoprime v.1 v.2 ∧ Odd (v.1 + v.2)

/-- The root `(2,1)` of both trees, i.e. the triple `(3,4,5)`. -/
def root : Node := (2, 1)

/-- The size of a node, the quantity that strictly increases along every tree edge. -/
def size (v : Node) : ℤ := v.1 + v.2

theorem isNode_root : IsNode root := by
  refine ⟨le_refl 1, by norm_num [root], ?_, ?_⟩
  · exact ⟨1, -1, by norm_num [root]⟩
  · exact ⟨1, by norm_num [root]⟩

theorem IsNode.size_ge {v : Node} (h : IsNode v) : 3 ≤ size v := by
  obtain ⟨h1, h2, -, -⟩ := h
  simp only [size]
  omega

theorem size_root : size root = 3 := rfl

/-- A node of size `3` is the root. -/
theorem eq_root_of_size_eq {v : Node} (h : IsNode v) (hs : size v = 3) : v = root := by
  obtain ⟨h1, h2, -, -⟩ := h
  simp only [size] at hs
  have e1 : v.1 = 2 := by omega
  have e2 : v.2 = 1 := by omega
  exact Prod.ext e1 e2

section Abstract

variable (f : Fin 3 → Node → Node)

/-- Apply a word of tree letters, the head letter acting **last** (outermost). -/
def applyWord : List (Fin 3) → Node → Node
  | [], v => v
  | i :: w, v => f i (applyWord w v)

@[simp] theorem applyWord_nil (v : Node) : applyWord f [] v = v := rfl

@[simp] theorem applyWord_cons (i : Fin 3) (w : List (Fin 3)) (v : Node) :
    applyWord f (i :: w) v = f i (applyWord f w v) := rfl

variable (hmap : ∀ i v, IsNode v → IsNode (f i v))

include hmap in
/-- Every word applied to a node yields a node. -/
theorem isNode_applyWord (w : List (Fin 3)) {v : Node} (hv : IsNode v) :
    IsNode (applyWord f w v) := by
  induction w with
  | nil => exact hv
  | cons i w ih => exact hmap i _ ih

variable (hsize : ∀ i v, IsNode v → size v < size (f i v))
variable (hparent : ∀ v, IsNode v → v ≠ root → ∃ i u, IsNode u ∧ f i u = v)

include hsize hparent in
/-- **Descent / completeness.**  Every node is reached from the root by some word. -/
theorem exists_word : ∀ (v : Node), IsNode v → ∃ w : List (Fin 3), applyWord f w root = v := by
  intro v
  induction hn : (size v).toNat using Nat.strong_induction_on generalizing v with
  | _ k ih =>
    intro hv
    by_cases hr : v = root
    · exact ⟨[], by simp [hr]⟩
    · obtain ⟨i, u, hu, hfu⟩ := hparent v hv hr
      have hlt : size u < size v := by
        have := hsize i u hu
        rw [hfu] at this; exact this
      have h3u : 3 ≤ size u := hu.size_ge
      have hkey : (size u).toNat < k := by
        subst hn; omega
      obtain ⟨w, hw⟩ := ih (size u).toNat hkey u rfl hu
      exact ⟨i :: w, by simp [hw, hfu]⟩

variable (hinj : ∀ i u v, f i u = f i v → u = v)
variable (hdisj : ∀ i j u v, IsNode u → IsNode v → f i u = f j v → i = j)

include hmap hsize hinj hdisj in
/-- **Uniqueness.**  Distinct words give distinct nodes. -/
theorem word_unique : ∀ (w w' : List (Fin 3)),
    applyWord f w root = applyWord f w' root → w = w' := by
  have hroot : IsNode root := isNode_root
  have hne : ∀ (i : Fin 3) (u : Node), IsNode u → f i u ≠ root := by
    intro i u hu h
    have := hsize i u hu
    rw [h] at this
    have := hu.size_ge
    simp [size_root] at *
    omega
  intro w
  induction w with
  | nil =>
    intro w' h
    cases w' with
    | nil => rfl
    | cons j w' =>
      exact absurd (h.symm) (hne j _ (isNode_applyWord f hmap w' hroot))
  | cons i w ih =>
    intro w' h
    cases w' with
    | nil => exact absurd h (hne i _ (isNode_applyWord f hmap w hroot))
    | cons j w' =>
      have hij : i = j :=
        hdisj i j _ _ (isNode_applyWord f hmap w hroot) (isNode_applyWord f hmap w' hroot) h
      subst hij
      have := hinj i _ _ h
      rw [ih w' this]

include hmap hsize hinj hdisj hparent in
/-- **The tree theorem.**  Every node is `applyWord w root` for exactly one word `w`. -/
theorem exists_unique_word (v : Node) (hv : IsNode v) :
    ∃! w : List (Fin 3), applyWord f w root = v := by
  obtain ⟨w, hw⟩ := exists_word f hsize hparent v hv
  exact ⟨w, hw, fun w' hw' => word_unique f hmap hsize hinj hdisj w' w (by rw [hw, hw'])⟩

end Abstract

end BerggrenPrice