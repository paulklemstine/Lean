import Mathlib

/-!
# Snakes in hypercubes: basic theory over an arbitrary coordinate type

A *snake* (snake-in-the-box code) of length `L` in the hypercube `Q_n` is an induced
path with `L` edges, i.e. a sequence `v₀, v₁, …, v_L` of vertices such that
consecutive vertices are at Hamming distance `1` and *non*-consecutive vertices are at
Hamming distance `≥ 2` (no "chords").

Since the whole point of this development is a **product construction**, we index the
coordinates of the cube by an arbitrary finite type `α` rather than by `Fin n`; the cube
`Q_{m+n}` is then modelled by the coordinate type `Fin m ⊕ Fin n`, and the transfer back
to `Fin (m+n)` is a purely cosmetic relabelling (`hdist_comp_equiv`).

## Main definitions

* `SnakeProduct.hdist x y` : Hamming distance on `α → Bool`.
* `SnakeProduct.IsSnake α L p` : `p 0, …, p L` is a snake of length `L` in the cube with
  coordinate set `α`.

## Main results

* `SnakeProduct.hdist_sum_elim` : Hamming distance on `α ⊕ β` splits as a sum.
* `SnakeProduct.hdist_comp_equiv` : Hamming distance is invariant under relabelling.
* `SnakeProduct.IsSnake.dist_eq_one` / `IsSnake.dist_ge_two` / `IsSnake.dist_eq_zero_iff` :
  the complete distance dichotomy along a snake — distance `0`, `1` or `≥ 2` according to
  whether the indices are equal, adjacent, or further apart.
* `SnakeProduct.IsSnake.injOn` : a snake visits distinct vertices.
-/

namespace SnakeProduct

open Finset

variable {α β : Type*} [Fintype α] [Fintype β]

/-- The Hamming distance between two vertices of the cube with coordinate set `α`. -/
def hdist (x y : α → Bool) : ℕ := #{i | x i ≠ y i}

lemma hdist_comm (x y : α → Bool) : hdist x y = hdist y x := by
  unfold hdist; congr 1; apply Finset.filter_congr; intro i _; simp [eq_comm]

@[simp] lemma hdist_self (x : α → Bool) : hdist x x = 0 := by simp [hdist]

lemma hdist_eq_zero_iff {x y : α → Bool} : hdist x y = 0 ↔ x = y := by
  unfold hdist
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  constructor
  · intro h; funext i; simpa using h (Finset.mem_univ i)
  · rintro rfl i _; simp

lemma hdist_pos_of_ne {x y : α → Bool} (h : x ≠ y) : 0 < hdist x y := by
  rcases Nat.eq_zero_or_pos (hdist x y) with h0 | h0
  · exact absurd (hdist_eq_zero_iff.mp h0) h
  · exact h0

/-- Hamming distance on a disjoint union of coordinate sets is the sum of the
distances in the two factors.  This is the elementary fact that makes the cube
`Q_{m+n}` the *metric* product of `Q_m` and `Q_n`. -/
lemma hdist_sum_elim (a a' : α → Bool) (b b' : β → Bool) :
    hdist (Sum.elim a b) (Sum.elim a' b') = hdist a a' + hdist b b' := by
  classical
  unfold hdist
  rw [Finset.card_filter, Finset.card_filter, Finset.card_filter, Fintype.sum_sum_type]
  simp

/-- Hamming distance is invariant under a relabelling of the coordinates. -/
lemma hdist_comp_equiv (e : β ≃ α) (x y : α → Bool) :
    hdist (x ∘ e) (y ∘ e) = hdist x y := by
  classical
  unfold hdist
  rw [Finset.card_filter, Finset.card_filter]
  exact Fintype.sum_equiv e _ _ (fun i => rfl)

/-- `p 0, p 1, …, p L` is a snake (induced path) of length `L` in the hypercube whose
coordinates are indexed by `α`: consecutive vertices differ in exactly one coordinate,
and any two vertices at index distance `≥ 2` differ in at least two coordinates. -/
structure IsSnake (α : Type*) [Fintype α] (L : ℕ) (p : ℕ → α → Bool) :
    Prop where
  /-- Consecutive vertices are adjacent in the cube. -/
  step : ∀ i, i < L → hdist (p i) (p (i + 1)) = 1
  /-- Non-consecutive vertices are non-adjacent in the cube: no chords. -/
  chord : ∀ i j, i ≤ L → j ≤ L → i + 1 < j → 2 ≤ hdist (p i) (p j)

namespace IsSnake

variable {L : ℕ} {p : ℕ → α → Bool}

lemma dist_eq_one (h : IsSnake α L p) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L)
    (hij : i + 1 = j ∨ j + 1 = i) : hdist (p i) (p j) = 1 := by
  rcases hij with rfl | rfl
  · exact h.step i (by omega)
  · rw [hdist_comm]; exact h.step j (by omega)

lemma dist_ge_two (h : IsSnake α L p) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L)
    (hij : i + 1 < j ∨ j + 1 < i) : 2 ≤ hdist (p i) (p j) := by
  rcases hij with hij | hij
  · exact h.chord i j hi hj hij
  · rw [hdist_comm]; exact h.chord j i hj hi hij

/-- The full dichotomy: along a snake, the Hamming distance is `≥ 1` whenever the
indices are different. -/
lemma dist_pos (h : IsSnake α L p) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L) (hij : i ≠ j) :
    1 ≤ hdist (p i) (p j) := by
  rcases lt_trichotomy (i + 1) j with h1 | h1 | h1
  · exact le_trans (by norm_num) (h.dist_ge_two hi hj (Or.inl h1))
  · exact le_of_eq (h.dist_eq_one hi hj (Or.inl h1)).symm
  · rcases lt_trichotomy (j + 1) i with h2 | h2 | h2
    · exact le_trans (by norm_num) (h.dist_ge_two hi hj (Or.inr h2))
    · exact le_of_eq (h.dist_eq_one hi hj (Or.inr h2)).symm
    · omega

/-- A snake never repeats a vertex. -/
lemma injOn (h : IsSnake α L p) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L) (hij : p i = p j) :
    i = j := by
  by_contra hne
  have := h.dist_pos hi hj hne
  rw [hij, hdist_self] at this
  omega

/-- Truncating a snake gives a snake. -/
lemma mono (h : IsSnake α L p) {L' : ℕ} (hL : L' ≤ L) : IsSnake α L' p :=
  ⟨fun i hi => h.step i (by omega), fun i j hi hj hij => h.chord i j (by omega) (by omega) hij⟩

/-- Relabelling the coordinates of the cube carries snakes to snakes. -/
lemma comp_equiv (h : IsSnake α L p) (e : β ≃ α) : IsSnake β L (fun i => p i ∘ e) :=
  ⟨fun i hi => by simpa [hdist_comp_equiv e] using h.step i hi,
   fun i j hi hj hij => by simpa [hdist_comp_equiv e] using h.chord i j hi hj hij⟩

end IsSnake

/-- The trivial snake of length `0`. -/
lemma isSnake_zero (p : ℕ → α → Bool) : IsSnake α 0 p :=
  ⟨fun i hi => absurd hi (by omega), fun i j hi hj hij => by omega⟩

end SnakeProduct