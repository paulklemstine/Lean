import Algebra.SnakeProduct.Main

/-!
# Small cubes, and the necessity of a positive constant in the conjecture

The conjecture reads: there is an absolute constant `C` with

  `s(m + n) ≥ (L + 1)(K + 1) - C (L + K)`

for all snakes of lengths `L` in `Q_m` and `K` in `Q_n`.  Even the smallest instance
already forces `C ≥ 1`: in `Q_1` there is a snake of length `1`, while `s(2) = 2`, so the
main term `(1+1)(1+1) = 4` overshoots by `2 = C(L + K) = 2C`.

## Main results

* `SnakeProduct.hdist_le_card` : the Hamming distance is at most the number of coordinates.
* `SnakeProduct.snakeNum_zero`, `SnakeProduct.snakeNum_one`, `SnakeProduct.snakeNum_two` :
  `s(0) = 0`, `s(1) = 1`, `s(2) = 2`.
* `SnakeProduct.conjecture_constant_ge_one` : any constant `C` for which the conjectured
  bound holds must satisfy `C ≥ 1`.
-/

namespace SnakeProduct

open Finset

variable {α : Type*} [Fintype α]

lemma hdist_le_card (x y : α → Bool) : hdist x y ≤ Fintype.card α := by
  classical
  simpa [hdist] using Finset.card_filter_le (Finset.univ : Finset α) (fun i => x i ≠ y i)

/-- Two vertices at Hamming distance equal to the dimension are antipodal. -/
lemma forall_ne_of_hdist_eq_card {x y : α → Bool} (h : hdist x y = Fintype.card α) (i : α) :
    x i ≠ y i := by
  classical
  have hfull : (Finset.univ.filter (fun i => x i ≠ y i)) = Finset.univ :=
    Finset.eq_univ_of_card _ h
  have hi : i ∈ Finset.univ.filter (fun i => x i ≠ y i) := by rw [hfull]; exact Finset.mem_univ i
  exact (Finset.mem_filter.mp hi).2

/-! ### The three smallest cubes -/

lemma snakeNum_zero : snakeNum 0 = 0 := by
  obtain ⟨p, hp⟩ := snakeNum_spec 0
  have := hp.length_lt_card
  simp only [Fintype.card_fin, pow_zero] at this
  omega

lemma snakeNum_one : snakeNum 1 = 1 := by
  obtain ⟨p, hp⟩ := snakeNum_spec 1
  have h1 := hp.length_lt_card
  have h2 := one_le_snakeNum (m := 1) le_rfl
  simp only [Fintype.card_fin, pow_one] at h1
  omega

/-- In the square `Q_2` no snake is longer than `2`: a snake of length `3` would force two
distinct vertices to be antipodal to the same vertex. -/
lemma snake_dim_two_le {L : ℕ} {p : ℕ → Fin 2 → Bool} (h : IsSnake (Fin 2) L p) : L ≤ 2 := by
  by_contra hc
  push_neg at hc
  have h02 : 2 ≤ hdist (p 0) (p 2) := h.chord 0 2 (by omega) (by omega) (by omega)
  have h03 : 2 ≤ hdist (p 0) (p 3) := h.chord 0 3 (by omega) (by omega) (by omega)
  have hb2 : hdist (p 0) (p 2) = Fintype.card (Fin 2) := by
    have := hdist_le_card (p 0) (p 2); simp only [Fintype.card_fin] at *; omega
  have hb3 : hdist (p 0) (p 3) = Fintype.card (Fin 2) := by
    have := hdist_le_card (p 0) (p 3); simp only [Fintype.card_fin] at *; omega
  have e23 : p 2 = p 3 := by
    funext i
    have a2 := forall_ne_of_hdist_eq_card hb2 i
    have a3 := forall_ne_of_hdist_eq_card hb3 i
    revert a2 a3
    cases p 0 i <;> cases p 2 i <;> cases p 3 i <;> simp
  have hstep : hdist (p 2) (p (2 + 1)) = 1 := h.step 2 (by omega)
  rw [show (2 : ℕ) + 1 = 3 from rfl, e23, hdist_self] at hstep
  omega

/-- A concrete snake of length `2` in `Q_2`. -/
lemma isSnake_two_dim_two :
    IsSnake (Fin 2) 2 (fun i j => decide (i = 1 ∧ j = 0 ∨ i = 2)) := by
  constructor
  · intro i hi
    interval_cases i <;> · unfold hdist; decide
  · intro i j hi hj hij
    obtain ⟨rfl, rfl⟩ : i = 0 ∧ j = 2 := by omega
    unfold hdist; decide

lemma snakeNum_two : snakeNum 2 = 2 := by
  obtain ⟨p, hp⟩ := snakeNum_spec 2
  have h1 := snake_dim_two_le hp
  have h2 := le_snakeNum isSnake_two_dim_two
  omega

/-- A concrete snake of length `1` in `Q_1`. -/
lemma isSnake_one_dim_one : IsSnake (Fin 1) 1 (fun i _ => decide (i = 1)) := by
  constructor
  · intro i hi
    have : i = 0 := by omega
    subst this
    unfold hdist; decide
  · intro i j hi hj hij; omega

/-- **The constant in the conjecture must be at least `1`.**  If `C` is such that every
pair of snakes of lengths `L` in `Q_m` and `K` in `Q_n` is matched by a snake of length at
least `(L+1)(K+1) - C(L+K)` in `Q_{m+n}`, then `1 ≤ C`.  The instance `m = n = L = K = 1`
already forces it, since `s(2) = 2 < 4`. -/
theorem conjecture_constant_ge_one (C : ℕ)
    (H : ∀ (m n L K : ℕ) (p : ℕ → Fin m → Bool) (q : ℕ → Fin n → Bool),
      IsSnake (Fin m) L p → IsSnake (Fin n) K q →
      (L + 1) * (K + 1) ≤ snakeNum (m + n) + C * (L + K)) :
    1 ≤ C := by
  have h := H 1 1 1 1 _ _ isSnake_one_dim_one isSnake_one_dim_one
  rw [show 1 + 1 = 2 from rfl, snakeNum_two] at h
  omega

end SnakeProduct