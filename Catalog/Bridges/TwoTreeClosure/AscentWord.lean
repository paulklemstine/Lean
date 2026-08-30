import Mathlib
import Bridges.TwoTreeClosure.TreeCore

/-!
# The ascent word is a normal form

`Bridges.TwoTreeClosure.TreeCore` proves that every arithmetic node is reachable
from the root and that each node remembers the branch that produced it
(`parentP_child*`, `letterOf_child*`).  Here that is upgraded to a **normal form**:

* `follow` reads a word in `{A, B, C}` as a descent from a node;
* `follow_injective` : distinct words reach distinct nodes, for every starting node;
* `ascent_word_normal_form` : words in `{A, B, C}` are in bijection with the nodes of
  the subtree below a fixed node, so every node of the Berggren/Price tree carries a
  unique ascent word — the tree is free on its three generators.

This is the structural statement behind the "positional content" of the two-tree
question: the letters of the word are exactly the information that the blindness
theorems of `TreeCore` show to be unreadable from `N`.
-/

namespace TwoTreeClosure

/-- Apply the branch named by a letter. -/
def childOf : Letter → ℕ × ℕ → ℕ × ℕ
  | Letter.A, p => childA p.1 p.2
  | Letter.B, p => childB p.1 p.2
  | Letter.C, p => childC p.1 p.2

/-- Read a word as a descent starting from a node. -/
def follow : List Letter → ℕ × ℕ → ℕ × ℕ
  | [], v => v
  | l :: ls, v => follow ls (childOf l v)

theorem childOf_isNode {p : ℕ × ℕ} (l : Letter) (h : IsNode p.1 p.2) :
    IsNode (childOf l p).1 (childOf l p).2 := by
  cases l
  · exact isNode_childA h
  · exact isNode_childB h
  · exact isNode_childC h

theorem letterOf_childOf {p : ℕ × ℕ} (l : Letter) (h : IsNode p.1 p.2) :
    letterOf (childOf l p).1 (childOf l p).2 = l := by
  cases l
  · exact letterOf_childA h
  · exact letterOf_childB h
  · exact letterOf_childC h

theorem parentP_childOf {p : ℕ × ℕ} (l : Letter) (h : IsNode p.1 p.2) :
    parentP (childOf l p) = p := by
  cases l
  · simpa using parentP_childA h
  · simpa using parentP_childB h
  · simpa using parentP_childC h

/-- Each branch strictly increases the leading coordinate. -/
theorem fst_lt_childOf {p : ℕ × ℕ} (l : Letter) (h : IsNode p.1 p.2) :
    p.1 < (childOf l p).1 := by
  obtain ⟨hn, hnm, -, -⟩ := h
  cases l <;> simp only [childOf, childA, childB, childC] <;> omega

theorem follow_isNode {v : ℕ × ℕ} (h : IsNode v.1 v.2) :
    ∀ w : List Letter, IsNode (follow w v).1 (follow w v).2 := by
  intro w
  induction w generalizing v with
  | nil => exact h
  | cons l ls ih => exact ih (childOf_isNode l h)

theorem follow_append (v : ℕ × ℕ) (w : List Letter) (l : Letter) :
    follow (w ++ [l]) v = childOf l (follow w v) := by
  induction w generalizing v with
  | nil => rfl
  | cons a as ih => simpa [follow] using ih (childOf a v)

theorem fst_le_follow {v : ℕ × ℕ} (h : IsNode v.1 v.2) :
    ∀ w : List Letter, v.1 ≤ (follow w v).1 := by
  intro w
  induction w generalizing v with
  | nil => exact le_rfl
  | cons l ls ih =>
      have h1 : v.1 < (childOf l v).1 := fst_lt_childOf l h
      have h2 := ih (childOf_isNode l h)
      simp only [follow]
      omega

/-- **Distinct words reach distinct nodes.** -/
theorem follow_injective {v : ℕ × ℕ} (h : IsNode v.1 v.2) :
    ∀ w w' : List Letter, follow w v = follow w' v → w = w' := by
  intro w
  induction w using List.reverseRecOn with
  | nil =>
      intro w' hw
      rcases List.eq_nil_or_concat w' with rfl | ⟨u, l, rfl⟩
      · rfl
      · exfalso
        rw [List.concat_eq_append, follow_append] at hw
        have h1 : v.1 ≤ (follow u v).1 := fst_le_follow h u
        have h2 : (follow u v).1 < (childOf l (follow u v)).1 :=
          fst_lt_childOf l (follow_isNode h u)
        have : (follow [] v).1 = v.1 := rfl
        rw [← hw] at h2
        simp only [follow] at h2
        omega
  | append_singleton u a ih =>
      intro w' hw
      rcases List.eq_nil_or_concat w' with rfl | ⟨u', l', rfl⟩
      · exfalso
        rw [follow_append] at hw
        have h1 : v.1 ≤ (follow u v).1 := fst_le_follow h u
        have h2 : (follow u v).1 < (childOf a (follow u v)).1 :=
          fst_lt_childOf a (follow_isNode h u)
        rw [hw] at h2
        simp only [follow] at h2
        omega
      · rw [List.concat_eq_append] at hw ⊢
        rw [follow_append, follow_append] at hw
        have hu : IsNode (follow u v).1 (follow u v).2 := follow_isNode h u
        have hu' : IsNode (follow u' v).1 (follow u' v).2 := follow_isNode h u'
        have hletter : a = l' := by
          have e1 := letterOf_childOf a hu
          have e2 := letterOf_childOf l' hu'
          rw [hw, e2] at e1
          exact e1.symm
        have hparent : follow u v = follow u' v := by
          have e1 := parentP_childOf a hu
          have e2 := parentP_childOf l' hu'
          rw [← e1, hw, e2]
        rw [hletter, ih u' hparent]

/-- **Ascent-word normal form.**  For a fixed node, reading words as descents is an
injective map from `{A,B,C}`-words to nodes; combined with `IsNode.inTree` (every
node is reachable from the root) this says the Berggren/Price tree is the free
ternary tree on its three branch letters, and every node has a unique ascent word. -/
theorem ascent_word_normal_form {v : ℕ × ℕ} (h : IsNode v.1 v.2) :
    Function.Injective (fun w : List Letter => follow w v) ∧
      ∀ w : List Letter, IsNode (follow w v).1 (follow w v).2 :=
  ⟨fun w w' hww => follow_injective h w w' hww, fun w => follow_isNode h w⟩

/-- The word length is recoverable: descending `w` from a node increases the leading
coordinate by at least `w.length`, so words of different lengths land at different
depths. -/
theorem length_le_fst_follow {v : ℕ × ℕ} (h : IsNode v.1 v.2) :
    ∀ w : List Letter, v.1 + w.length ≤ (follow w v).1 := by
  intro w
  induction w generalizing v with
  | nil => simp [follow]
  | cons l ls ih =>
      have h1 : v.1 < (childOf l v).1 := fst_lt_childOf l h
      have h2 := ih (childOf_isNode l h)
      simp only [follow, List.length_cons]
      omega

/-! ### Depth versus magnitude: the tree is extremely unbalanced

Each branch multiplies the leading coordinate by at most `3`, so a word of length
`L` cannot reach beyond `3 ^ L`.  In the opposite direction the pure `A`-spine
increases the leading coordinate by exactly one per letter, so its depth grows like
the square root of the hypotenuse — the depth of a node is *not* logarithmic in `N`
in general.
-/

/-- Each branch at most triples the leading coordinate. -/
theorem fst_childOf_le {p : ℕ × ℕ} (l : Letter) (h : IsNode p.1 p.2) :
    (childOf l p).1 ≤ 3 * p.1 := by
  obtain ⟨hn, hnm, -, -⟩ := h
  cases l <;> simp only [childOf, childA, childB, childC] <;> omega

/-- A word of length `L` reaches at most `3 ^ L` times the leading coordinate. -/
theorem fst_follow_le {v : ℕ × ℕ} (h : IsNode v.1 v.2) :
    ∀ w : List Letter, (follow w v).1 ≤ v.1 * 3 ^ w.length := by
  intro w
  induction w generalizing v with
  | nil => simp [follow]
  | cons l ls ih =>
      have h1 : (childOf l v).1 ≤ 3 * v.1 := fst_childOf_le l h
      have h2 := ih (childOf_isNode l h)
      simp only [follow, List.length_cons]
      calc (follow ls (childOf l v)).1 ≤ (childOf l v).1 * 3 ^ ls.length := h2
        _ ≤ (3 * v.1) * 3 ^ ls.length := by
            exact Nat.mul_le_mul_right _ h1
        _ = v.1 * 3 ^ (ls.length + 1) := by ring

/-- The pure `A`-spine: applying `A` `k` times to `(m+1, m)` gives `(m+1+k, m+k)`. -/
theorem follow_replicate_A (k m : ℕ) :
    follow (List.replicate k Letter.A) (m + 1, m) = (m + 1 + k, m + k) := by
  induction k generalizing m with
  | zero => simp [follow]
  | succ k ih =>
      have hstep : childOf Letter.A ((m + 1 : ℕ), m) = ((m + 1) + 1, m + 1) := by
        simp only [childOf, childA, Prod.mk.injEq]
        refine ⟨by omega, ?_⟩
        trivial
      rw [List.replicate_succ]
      simp only [follow, hstep, ih (m + 1), Prod.mk.injEq]
      exact ⟨by omega, by omega⟩

/-- **Depth is not logarithmic in the hypotenuse.**  Along the `A`-spine from the root
the word of length `k` lands on the node `(k + 2, k + 1)`, whose hypotenuse is
`2k² + 6k + 5`: the depth grows like the square root of the hypotenuse, whereas a
balanced ternary tree would need only `log₃` many letters. -/
theorem spine_depth_sqrt (k : ℕ) :
    follow (List.replicate k Letter.A) (2, 1) = (k + 2, k + 1) ∧
      hyp (k + 2) (k + 1) = 2 * k ^ 2 + 6 * k + 5 ∧
      IsNode (k + 2) (k + 1) := by
  refine ⟨?_, by simp only [hyp]; ring, ⟨by omega, by omega, ?_, by omega⟩⟩
  · have h := follow_replicate_A k 1
    rw [show ((1 : ℕ) + 1, (1 : ℕ)) = ((2 : ℕ), (1 : ℕ)) from by norm_num] at h
    rw [h, Prod.mk.injEq]
    exact ⟨by omega, by omega⟩
  · have hco : Nat.Coprime (k + 1 + 1) (k + 1) := by simp
    have : k + 2 = k + 1 + 1 := by omega
    rw [this]
    exact hco

/-- **Depth bracket from the root.**  A word of length `L` read from the root lands on
a node whose leading coordinate lies between `2 + L` and `2 · 3 ^ L`.  Both sides are
attained: the upper bound by the `C`-spine growth rate, the lower bound exactly by the
`A`-spine of `spine_depth_sqrt`.  Hence the depth of a node with leading coordinate `m`
is between `log₃ (m / 2)` and `m - 2`. -/
theorem depth_bracket (w : List Letter) :
    2 + w.length ≤ (follow w (2, 1)).1 ∧ (follow w (2, 1)).1 ≤ 2 * 3 ^ w.length := by
  have hroot : IsNode ((2, 1) : ℕ × ℕ).1 ((2, 1) : ℕ × ℕ).2 := by
    refine ⟨by norm_num, by norm_num, ?_, by norm_num⟩
    simp [Nat.Coprime]
  exact ⟨length_le_fst_follow hroot w, fst_follow_le hroot w⟩

end TwoTreeClosure