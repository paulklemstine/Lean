import Combinatorics.BerggrenCongruentDescent
import Combinatorics.BerggrenCongruentElliptic
import Combinatorics.BerggrenCongruentFermat

/-!
# The Berggren tree's area function *is* the congruent number problem

Main theorem: for a squarefree positive integer `s`,

```
s is a congruent number  ↔  s is the squarefree part of the area of a node of the
                            Berggren tree (grown from the two seeds (3,4,5), (4,3,5))
                         ↔  E_s : y² = x³ − s²x has a rational point with x > 0, y ≠ 0.
```

Together with `euclidArea_ne_sq` (Fermat's right triangle theorem in Euclid coordinates)
this gives the first unconditional entry of the "tree laboratory": `1` is not a congruent
number, i.e. no node of the tree has square area.
-/

namespace BerggrenCongruent

open BerggrenStars

/-! ### The main equivalence -/

/-- **Areas of Euclid seeds are exactly the congruent numbers, up to square factors.** -/
theorem congruent_iff_exists_param {s : ℤ} (hs : Squarefree s) :
    IsCongruentNumber (s : ℚ) ↔
      ∃ m n k : ℤ, IsParam m n ∧ 0 < k ∧ euclidArea m n = s * k ^ 2 := by
  constructor
  · intro h
    obtain ⟨x, y, z, k, hx, hy, hz, hpy, hcop, hk, harea⟩ :=
      exists_primitive_of_congruent hs h
    have hppt : IsPPT x y z := ⟨hx, hy, hz, hpy, hcop⟩
    have hnode := (isPPT_iff_node_or_swap x y z).mp hppt
    -- in either tree, the underlying triple has Euclid parameters (legs may be swapped)
    obtain ⟨m, n, hpar, hv⟩ : ∃ m n : ℤ, IsParam m n ∧
        ((x, y, z) = euclidTriple m n ∨ (y, x, z) = euclidTriple m n) := by
      rcases hnode with hn | hn
      · obtain ⟨m, n, hpar, hv⟩ := isNode_param hn
        exact ⟨m, n, hpar, Or.inl hv⟩
      · obtain ⟨m, n, hpar, hv⟩ := isNode_param (isNodeSwap_iff_isNode.mp hn)
        exact ⟨m, n, hpar, Or.inr hv⟩
    refine ⟨m, n, k, hpar, hk, ?_⟩
    have hxy : x * y = (m ^ 2 - n ^ 2) * (2 * m * n) := by
      rcases hv with hv | hv
      · have h1 : x = m ^ 2 - n ^ 2 := congrArg Prod.fst hv
        have h2 : y = 2 * m * n := congrArg (fun p : Vec => p.2.1) hv
        rw [h1, h2]
      · have h1 : y = m ^ 2 - n ^ 2 := congrArg Prod.fst hv
        have h2 : x = 2 * m * n := congrArg (fun p : Vec => p.2.1) hv
        rw [h1, h2]; ring
    have hdouble : (m ^ 2 - n ^ 2) * (2 * m * n) = 2 * euclidArea m n := by
      simp only [euclidArea]; ring
    have : 2 * euclidArea m n = 2 * (s * k ^ 2) := by rw [← hdouble, ← hxy, harea]; ring
    linarith
  · rintro ⟨m, n, k, hpar, hk, harea⟩
    have hcong : IsCongruentNumber ((euclidArea m n : ℤ) : ℚ) := isCongruentNumber_euclidArea hpar
    rw [harea] at hcong
    have hcast : (((s * k ^ 2 : ℤ)) : ℚ) = (s : ℚ) * (k : ℚ) ^ 2 := by push_cast; ring
    rw [hcast] at hcong
    exact (isCongruentNumber_mul_sq_iff (s : ℚ) (t := (k : ℚ))
      (by exact_mod_cast hk.ne')).mp hcong

/-- **The tree form of the main theorem.**  A squarefree positive integer `s` is a
congruent number exactly when some node of one of the two Berggren trees has area
`s k²`. -/
theorem congruent_iff_tree_node {s : ℤ} (hs : Squarefree s) :
    IsCongruentNumber (s : ℚ) ↔
      ∃ v : Vec, (IsNode v ∨ IsNodeSwap v) ∧
        ∃ k : ℤ, 0 < k ∧ triArea v = (s : ℚ) * (k : ℚ) ^ 2 := by
  constructor
  · intro h
    obtain ⟨m, n, k, hpar, hk, harea⟩ := (congruent_iff_exists_param hs).mp h
    refine ⟨euclidTriple m n, Or.inl (param_isNode hpar), k, hk, ?_⟩
    rw [triArea_euclidTriple, harea]
    push_cast
    ring
  · rintro ⟨v, hv, k, hk, harea⟩
    obtain ⟨a, b, c⟩ := v
    have hppt : IsPPT a b c := (isPPT_iff_node_or_swap a b c).mpr hv
    obtain ⟨ha, hb, hc, hpy, -⟩ := hppt
    have hcong : IsCongruentNumber (triArea (a, b, c)) :=
      isCongruentNumber_of_intTriple ha hb hc hpy
    rw [harea] at hcong
    exact (isCongruentNumber_mul_sq_iff (s : ℚ) (t := (k : ℚ))
      (by exact_mod_cast hk.ne')).mp hcong

/-- **The three-way equivalence**: triangles, tree nodes, and the congruent number
curve. -/
theorem tree_node_iff_curve {s : ℤ} (hs : Squarefree s) (h0 : 0 < s) :
    (∃ v : Vec, (IsNode v ∨ IsNodeSwap v) ∧
        ∃ k : ℤ, 0 < k ∧ triArea v = (s : ℚ) * (k : ℚ) ^ 2) ↔
      ∃ x y : ℚ, 0 < x ∧ y ≠ 0 ∧ OnCongruentCurve (s : ℚ) x y := by
  rw [← congruent_iff_tree_node hs]
  exact isCongruentNumber_iff_curve (by exact_mod_cast h0)

/-! ### Squarefree parts of node areas -/

/-- Every node area has a squarefree part, and that squarefree part is a congruent
number. -/
theorem exists_sqfreePart_area_congruent {m n : ℤ} (h : IsParam m n) :
    ∃ s k : ℤ, 0 < s ∧ Squarefree s ∧ 0 < k ∧ euclidArea m n = s * k ^ 2 ∧
      IsCongruentNumber (s : ℚ) := by
  have hpos : 0 < euclidArea m n := euclidArea_pos h.npos h.lt
  obtain ⟨a, b, hab, ha⟩ := Nat.sq_mul_squarefree (euclidArea m n).toNat
  have htoNat : ((euclidArea m n).toNat : ℤ) = euclidArea m n := Int.toNat_of_nonneg hpos.le
  have hnat : (b : ℤ) ^ 2 * (a : ℤ) = euclidArea m n := by
    have : ((b ^ 2 * a : ℕ) : ℤ) = ((euclidArea m n).toNat : ℤ) := by exact_mod_cast hab
    rw [htoNat] at this
    push_cast at this
    linarith [this]
  have ha0 : 0 < a := by
    rcases Nat.eq_zero_or_pos a with rfl | h'
    · simp at hnat; omega
    · exact h'
  have hb0 : 0 < b := by
    rcases Nat.eq_zero_or_pos b with rfl | h'
    · simp at hnat; omega
    · exact h'
  refine ⟨(a : ℤ), (b : ℤ), by exact_mod_cast ha0, ?_, by exact_mod_cast hb0, by linarith, ?_⟩
  · exact Int.squarefree_natCast.mpr ha
  · have hcong := isCongruentNumber_euclidArea h
    rw [← hnat] at hcong
    have hcast : (((b : ℤ) ^ 2 * (a : ℤ) : ℤ) : ℚ) = (a : ℚ) * ((b : ℤ) : ℚ) ^ 2 := by
      push_cast; ring
    rw [hcast] at hcong
    have := (isCongruentNumber_mul_sq_iff ((a : ℤ) : ℚ) (t := ((b : ℤ) : ℚ))
      (by exact_mod_cast hb0.ne')).mp hcong
    exact_mod_cast this

/-! ### Fermat's right triangle theorem: the first unconditional tree law -/

/-- **`1` is not a congruent number** — equivalently, no node of the Berggren tree has
square area. -/
theorem one_not_congruentNumber : ¬ IsCongruentNumber (1 : ℚ) := by
  intro h
  have hs : Squarefree (1 : ℤ) := squarefree_one
  obtain ⟨m, n, k, hpar, hk, harea⟩ :=
    (congruent_iff_exists_param hs).mp (by simpa using h)
  exact euclidArea_ne_sq hpar k (by simpa using harea)

/-- No perfect square is a congruent number. -/
theorem sq_not_congruentNumber {t : ℚ} (ht : t ≠ 0) : ¬ IsCongruentNumber (t ^ 2) := by
  intro h
  have : IsCongruentNumber (1 * t ^ 2) := by simpa using h
  exact one_not_congruentNumber ((isCongruentNumber_mul_sq_iff 1 ht).mp this)

end BerggrenCongruent