import Physics.TernaryPythagoreanTrees.Basic

/-!
# Ternary trees of node preserving maps

A triple `T : Fin 3 → IntMap` is a *ternary Pythagorean tree* if the three maps preserve the
node set, none of them hits the root `(2,1)`, together they hit every non-root node, and they
are jointly injective on nodes.  Equivalently: the node set is the vertex set of a rooted
ternary tree with root `(2,1)` whose edges are the three maps.

This file sets up the definition and the tools used to verify concrete triples.
-/

namespace TernaryTree

/-- A triple of integer maps forming a ternary tree on the node set with root `(2,1)`. -/
structure IsTernaryTree (T : Fin 3 → IntMap) : Prop where
  /-- each map sends nodes to nodes -/
  preserves : ∀ i, Preserves (T i)
  /-- the root has no parent -/
  root_not_hit : ∀ i m n, IsNode m n → (T i).app m n ≠ (2, 1)
  /-- every non-root node has a parent -/
  covers : ∀ m n, IsNode m n → (m, n) ≠ (2, 1) → ∃ i x y, IsNode x y ∧ (T i).app x y = (m, n)
  /-- the parent, and the branch used, are unique -/
  inj : ∀ i j x y u v, IsNode x y → IsNode u v → (T i).app x y = (T j).app u v →
      i = j ∧ x = u ∧ y = v

/-! ### Tools -/

/-- A unimodular change of variables preserves coprimality. -/
lemma isCoprime_of_unimodular {m n x y : ℤ} (h : IsCoprime m n) {α β γ δ : ℤ}
    (hx : x = α * m + β * n) (hy : y = γ * m + δ * n)
    (hdet : α * δ - β * γ = 1 ∨ α * δ - β * γ = -1) : IsCoprime x y := by
  obtain ⟨u, v, huv⟩ := h
  subst hx; subst hy
  rcases hdet with hd | hd
  · exact ⟨u * δ - v * γ, v * α - u * β, by linear_combination (u * m + v * n) * hd + huv⟩
  · exact ⟨-(u * δ - v * γ), -(v * α - u * β), by
      linear_combination (-(u * m + v * n)) * hd + huv⟩

/-- If the determinant is `±1` or `±2` then no odd prime divides it. -/
lemma no_odd_prime_dvd_of_det_small {M : IntMap}
    (h : M.det = 1 ∨ M.det = -1 ∨ M.det = 2 ∨ M.det = -2) :
    ∀ p : ℕ, p.Prime → Odd p → ¬ ((p : ℤ) ∣ M.det) := by
  intro p hp hodd hdvd
  have hp3 : 3 ≤ p := by
    have h2 := hp.two_le
    have : p ≠ 2 := by rintro rfl; simp [Nat.odd_iff] at hodd
    omega
  have hp3' : (3 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp3
  have h2 : (p : ℤ) ∣ 2 := by
    rcases h with h | h | h | h <;> rw [h] at hdvd
    · exact hdvd.trans (by norm_num)
    · exact ((dvd_neg).1 hdvd).trans (by norm_num)
    · exact hdvd
    · exact (dvd_neg).1 hdvd
  have := Int.le_of_dvd (by norm_num) h2
  omega

/-- Coprimality of a node forces `n = 1` when `m = k * n`. -/
lemma eq_one_of_dvd_node {m n k : ℤ} (h : IsNode m n) (hk : m = k * n) : n = 1 := by
  obtain ⟨u, v, huv⟩ := h.cop
  have : n ∣ 1 := ⟨u * k + v, by rw [← huv, hk]; ring⟩
  have := Int.le_of_dvd one_pos this
  have := h.one_le
  omega

end TernaryTree