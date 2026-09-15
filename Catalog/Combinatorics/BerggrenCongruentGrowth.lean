import Combinatorics.BerggrenCongruentMain

/-!
# Structure of the area function: growth, the Pell spine, and properness

Having identified the squarefree parts of Berggren node areas with the congruent numbers,
this file studies the *statistics* of the area function itself.

## Main results

* `euclidArea_lt_A`, `euclidArea_lt_B`, `euclidArea_lt_C` — the area strictly increases
  along each of the three branches, so the area is a strictly monotone tree function.
* `euclidArea_B_growth` — the `B` branch multiplies the area by at least `6`.
* `spine_area_silver` — along the Pell (`B`) spine the area obeys the **silver law**
  `A_d = 2 t_d² + (−1)^{d+1} t_d` with `t_d = m_d n_d`, a consequence of the Pell identity
  `m² − 2mn − n² = (−1)^{d+1}`.
* `spine_area_growth` — the spine areas grow at least like `6^{d+1}`.
* `sq_lt_euclidArea`, `finite_params_area_le` — the area function is *proper*: only
  finitely many nodes have area below a given bound.
* Lab notes: `six_congruent`, `five_congruent`, `seven_congruent`, … — explicit tree
  witnesses for the first congruent numbers.
-/

namespace BerggrenCongruent

open BerggrenStars

/-! ### Monotonicity along the three branches -/

/-- The `A` branch `(m, n) ↦ (2m − n, m)` strictly increases the area. -/
theorem euclidArea_lt_A {m n : ℤ} (h : IsParam m n) :
    euclidArea m n < euclidArea (2 * m - n) m := by
  have hn := h.npos
  have hlt := h.lt
  have hm := h.mpos
  have key : euclidArea (2 * m - n) m = euclidArea m n + 6 * m ^ 2 * (m - n) ^ 2 := by
    simp only [euclidArea]; ring
  have hpos : 0 < 6 * m ^ 2 * (m - n) ^ 2 :=
    mul_pos (by positivity) (pow_pos (sub_pos.mpr hlt) 2)
  linarith [key, hpos]

/-- The `B` branch `(m, n) ↦ (2m + n, m)` multiplies the area by at least `6`. -/
theorem euclidArea_B_growth {m n : ℤ} (h : IsParam m n) :
    6 * euclidArea m n < euclidArea (2 * m + n) m := by
  have hn := h.npos
  have hlt := h.lt
  have hm := h.mpos
  have key : euclidArea (2 * m + n) m
      = 6 * euclidArea m n + m * (m + n) * (6 * m ^ 2 - m * n + 7 * n ^ 2) := by
    simp only [euclidArea]; ring
  have h1 : 0 < m * (m + n) := mul_pos hm (by linarith)
  have h2 : 0 < 6 * m ^ 2 - m * n + 7 * n ^ 2 := by nlinarith [hm, hn, hlt]
  linarith [key, mul_pos h1 h2]

/-- The `B` branch strictly increases the area. -/
theorem euclidArea_lt_B {m n : ℤ} (h : IsParam m n) :
    euclidArea m n < euclidArea (2 * m + n) m := by
  have hpos : 0 < euclidArea m n := euclidArea_pos h.npos h.lt
  have := euclidArea_B_growth h
  linarith

/-- The `C` branch `(m, n) ↦ (m + 2n, n)` strictly increases the area. -/
theorem euclidArea_lt_C {m n : ℤ} (h : IsParam m n) :
    euclidArea m n < euclidArea (m + 2 * n) n := by
  have hn := h.npos
  have hlt := h.lt
  have hm := h.mpos
  have key : euclidArea (m + 2 * n) n = euclidArea m n + 6 * n ^ 2 * (m + n) ^ 2 := by
    simp only [euclidArea]; ring
  have hpos : 0 < 6 * n ^ 2 * (m + n) ^ 2 :=
    mul_pos (by positivity) (pow_pos (by linarith) 2)
  linarith [key, hpos]

/-! ### The Pell spine -/

/-- The `B`-branch (Pell) spine of Euclid parameters, starting at the root seed `(2, 1)`:
`(2,1), (5,2), (12,5), (29,12), …` — consecutive Pell numbers. -/
def spine : ℕ → ℤ × ℤ
  | 0 => (2, 1)
  | d + 1 => (2 * (spine d).1 + (spine d).2, (spine d).1)

@[simp] theorem spine_zero : spine 0 = (2, 1) := rfl

theorem spine_succ (d : ℕ) :
    spine (d + 1) = (2 * (spine d).1 + (spine d).2, (spine d).1) := rfl

/-- Every spine node is an admissible Euclid seed, i.e. a node of the tree. -/
theorem spine_isParam (d : ℕ) : IsParam (spine d).1 (spine d).2 := by
  induction d with
  | zero => exact param_root
  | succ d ih =>
      rw [spine_succ]
      exact param_B ih

/-- **The Pell (silver) identity along the spine**: `m² − 2mn − n² = (−1)^{d+1}`.
This is the arithmetic shadow of the silver ratio `1 + √2`. -/
theorem spine_silver (d : ℕ) :
    (spine d).1 ^ 2 - 2 * (spine d).1 * (spine d).2 - (spine d).2 ^ 2 = (-1) ^ (d + 1) := by
  induction d with
  | zero => norm_num
  | succ d ih =>
      rw [spine_succ]
      simp only
      have : (2 * (spine d).1 + (spine d).2) ^ 2
          - 2 * (2 * (spine d).1 + (spine d).2) * (spine d).1 - (spine d).1 ^ 2
          = -((spine d).1 ^ 2 - 2 * (spine d).1 * (spine d).2 - (spine d).2 ^ 2) := by ring
      rw [this, ih]
      ring

/-- **The silver law for spine areas**: with `t = mn` the area of the `d`-th spine node is
`2t² + (−1)^{d+1} t`. -/
theorem spine_area_silver (d : ℕ) :
    euclidArea (spine d).1 (spine d).2
      = 2 * ((spine d).1 * (spine d).2) ^ 2
        + (-1) ^ (d + 1) * ((spine d).1 * (spine d).2) := by
  have h := spine_silver d
  have hmn : (spine d).1 ^ 2 - (spine d).2 ^ 2
      = 2 * ((spine d).1 * (spine d).2) + (-1) ^ (d + 1) := by linarith
  simp only [euclidArea]
  rw [hmn]
  ring

/-- The spine areas grow at least like `6^{d+1}`. -/
theorem spine_area_growth (d : ℕ) :
    (6 : ℤ) ^ (d + 1) ≤ euclidArea (spine d).1 (spine d).2 := by
  induction d with
  | zero => norm_num [euclidArea]
  | succ d ih =>
      have hstep := euclidArea_B_growth (spine_isParam d)
      rw [spine_succ]
      calc (6 : ℤ) ^ (d + 1 + 1) = 6 * 6 ^ (d + 1) := by ring
        _ ≤ 6 * euclidArea (spine d).1 (spine d).2 := by linarith
        _ ≤ euclidArea (2 * (spine d).1 + (spine d).2) (spine d).1 := by linarith

/-! ### Properness of the area function -/

/-- A node's area exceeds the square of its first Euclid parameter. -/
theorem sq_lt_euclidArea {m n : ℤ} (h : IsParam m n) : m ^ 2 < euclidArea m n := by
  have hn := h.npos
  have hlt := h.lt
  have hm := h.mpos
  have expand : euclidArea m n = m * n * (m - n) * (m + n) := by
    simp only [euclidArea]; ring
  have hA : m ≤ m * n := le_mul_of_one_le_right hm.le hn
  have hmn0 : 0 ≤ m * n := mul_nonneg hm.le hn.le
  have hB : m * n ≤ m * n * (m - n) := le_mul_of_one_le_right hmn0 (by omega)
  have hC0 : 0 ≤ m * n * (m - n) := mul_nonneg hmn0 (by omega)
  have hC : m * n * (m - n) * (m + 1) ≤ m * n * (m - n) * (m + n) :=
    mul_le_mul_of_nonneg_left (by omega) hC0
  have hm1 : m * (m + 1) ≤ m * n * (m - n) * (m + 1) :=
    mul_le_mul_of_nonneg_right (le_trans hA hB) (by omega)
  rw [expand]
  nlinarith [hC, hm1]

/-- **The area function is proper**: only finitely many nodes have area at most `X`. -/
theorem finite_params_area_le (X : ℤ) :
    {p : ℤ × ℤ | IsParam p.1 p.2 ∧ euclidArea p.1 p.2 ≤ X}.Finite := by
  apply Set.Finite.subset ((Set.finite_Icc (1 : ℤ) X).prod (Set.finite_Icc (1 : ℤ) X))
  rintro ⟨m, n⟩ ⟨hpar, hle⟩
  have hm : 0 < m := hpar.mpos
  have hn : 0 < n := hpar.npos
  have hlt : n < m := hpar.lt
  have hsq : m ^ 2 < euclidArea m n := sq_lt_euclidArea hpar
  have hmX : m ≤ X := by nlinarith [hsq, hle, hm]
  exact ⟨⟨hm, hmX⟩, ⟨hn, by linarith⟩⟩

/-! ### Lab notes: explicit congruent numbers with tree witnesses -/

private theorem squarefree_ofNat {k : ℕ} (h : Squarefree k) : Squarefree ((k : ℕ) : ℤ) :=
  Int.squarefree_natCast.mpr h

/-- `6` is a congruent number: the root `(3,4,5)` of the tree has area `6`. -/
theorem six_congruent : IsCongruentNumber (6 : ℚ) := by
  have hpar : IsParam 2 1 := param_root
  have hcong := isCongruentNumber_euclidArea hpar
  norm_num [euclidArea] at hcong
  exact hcong

/-- Helper: a tree node of area `s k²` exhibits `s` as a congruent number. -/
private theorem congruent_of_node {s m n k : ℤ} (hs : Squarefree s)
    (hpar : IsParam m n) (hk : 0 < k) (harea : euclidArea m n = s * k ^ 2) :
    IsCongruentNumber (s : ℚ) :=
  (congruent_iff_exists_param hs).mpr ⟨m, n, k, hpar, hk, harea⟩

/-- `5` is a congruent number: the node with Euclid seed `(5,4)` — the triple
`(9, 40, 41)` — has area `180 = 5 · 6²`. -/
theorem five_congruent : IsCongruentNumber (5 : ℚ) := by
  have hs : Squarefree (5 : ℤ) := by
    have := squarefree_ofNat (k := 5) (by decide +kernel)
    exact_mod_cast this
  have hpar : IsParam 5 4 := ⟨by norm_num, by norm_num, by decide, by decide⟩
  have := congruent_of_node hs hpar (k := 6) (by norm_num)
    (by norm_num [euclidArea])
  exact_mod_cast this

/-- `7` is a congruent number: the node with Euclid seed `(16,9)` has area
`25200 = 7 · 60²`. -/
theorem seven_congruent : IsCongruentNumber (7 : ℚ) := by
  have hs : Squarefree (7 : ℤ) := by
    have := squarefree_ofNat (k := 7) (by decide +kernel)
    exact_mod_cast this
  have hpar : IsParam 16 9 := ⟨by norm_num, by norm_num, by decide, by decide⟩
  have := congruent_of_node hs hpar (k := 60) (by norm_num)
    (by norm_num [euclidArea])
  exact_mod_cast this

/-- `14` is a congruent number: the node with Euclid seed `(8,1)` has area
`504 = 14 · 6²`. -/
theorem fourteen_congruent : IsCongruentNumber (14 : ℚ) := by
  have hs : Squarefree (14 : ℤ) := by
    have := squarefree_ofNat (k := 14) (by decide +kernel)
    exact_mod_cast this
  have hpar : IsParam 8 1 := ⟨by norm_num, by norm_num, by decide, by decide⟩
  have := congruent_of_node hs hpar (k := 6) (by norm_num)
    (by norm_num [euclidArea])
  exact_mod_cast this

/-- `15` is a congruent number: the node with Euclid seed `(4,1)` — the triple
`(15, 8, 17)` — has area `60 = 15 · 2²`. -/
theorem fifteen_congruent : IsCongruentNumber (15 : ℚ) := by
  have hs : Squarefree (15 : ℤ) := by
    have := squarefree_ofNat (k := 15) (by decide +kernel)
    exact_mod_cast this
  have hpar : IsParam 4 1 := ⟨by norm_num, by norm_num, by decide, by decide⟩
  have := congruent_of_node hs hpar (k := 2) (by norm_num)
    (by norm_num [euclidArea])
  exact_mod_cast this

/-- `21` is a congruent number: the node with Euclid seed `(4,3)` — the triple
`(7, 24, 25)` — has area `84 = 21 · 2²`. -/
theorem twentyone_congruent : IsCongruentNumber (21 : ℚ) := by
  have hs : Squarefree (21 : ℤ) := by
    have := squarefree_ofNat (k := 21) (by decide +kernel)
    exact_mod_cast this
  have hpar : IsParam 4 3 := ⟨by norm_num, by norm_num, by decide, by decide⟩
  have := congruent_of_node hs hpar (k := 2) (by norm_num)
    (by norm_num [euclidArea])
  exact_mod_cast this

/-- `30` is a congruent number: the node with Euclid seed `(3,2)` — the triple
`(5, 12, 13)` — has area `30`. -/
theorem thirty_congruent : IsCongruentNumber (30 : ℚ) := by
  have hs : Squarefree (30 : ℤ) := by
    have := squarefree_ofNat (k := 30) (by decide +kernel)
    exact_mod_cast this
  have hpar : IsParam 3 2 := ⟨by norm_num, by norm_num, by decide, by decide⟩
  have := congruent_of_node hs hpar (k := 1) (by norm_num)
    (by norm_num [euclidArea])
  exact_mod_cast this

/-- `34` is a congruent number: the node with Euclid seed `(9,8)` has area
`1224 = 34 · 6²`. -/
theorem thirtyfour_congruent : IsCongruentNumber (34 : ℚ) := by
  have hs : Squarefree (34 : ℤ) := by
    have := squarefree_ofNat (k := 34) (by decide +kernel)
    exact_mod_cast this
  have hpar : IsParam 9 8 := ⟨by norm_num, by norm_num, by decide, by decide⟩
  have := congruent_of_node hs hpar (k := 6) (by norm_num)
    (by norm_num [euclidArea])
  exact_mod_cast this

/-- `210` is a congruent number: it is the area of the first `B`-spine node `(5,2)`. -/
theorem twohundredten_congruent : IsCongruentNumber (210 : ℚ) := by
  have hs : Squarefree (210 : ℤ) := by
    have := squarefree_ofNat (k := 210) (by decide +kernel)
    exact_mod_cast this
  have hpar : IsParam 5 2 := ⟨by norm_num, by norm_num, by decide, by decide⟩
  have := congruent_of_node hs hpar (k := 1) (by norm_num)
    (by norm_num [euclidArea])
  exact_mod_cast this

end BerggrenCongruent