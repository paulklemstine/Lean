/-
# The three 2-isogenous neighbours of a Montgomery curve, explicitly

`ModularTwoIsogeny` computed the neighbour reached by the *radical* step — the
quotient of `E_A : y² = x³ + Ax² + x` by the rational two-torsion point `(0,0)`,
whose `j`-invariant is the rational function `jQuot A = 16(A²+12)³/(A²-4)²` —
and bounded the number of neighbours by three.  It did **not** say what the two
remaining neighbours are, so the possibility remained that the radical formulas
miss some 2-isogenies.  This file removes that gap; it is the previous cycle's
Conjecture 5 ("every Montgomery 2-neighbour arises radically").

The other two two-torsion points of `E_A` are `(r, 0)` with `r² + Ar + 1 = 0`.
Moving `(r,0)` to the origin gives another Montgomery model of the *same* curve,
whose parameter squared is

  `tShift A u = (A² - 3u - 9) / (-(u+2))`,   `u = A·r`,

and `u` is then a root of the *rational* quadratic `u² + A²u + A² = 0` — so the
two extra neighbours are conjugate over `K(√(A²-4))`, exactly as the geometry
predicts.  Feeding that model into the radical formula gives the neighbour

  `jOther A u = 16 (A² - 15u - 33)³ / ((-(u+2)) (A² + u - 1)²)`.

Results:

* `jMontSq`, `jQuotSq` — the observation, used implicitly in `ModularTwoIsogeny`,
  that both `j`-invariants depend on `A` only through `A²`; this is what lets us
  work with the *square* of the shifted Montgomery parameter and thereby avoid
  the square root `√(-Ar-2)` that the shifted model itself requires.
* `two_torsion_shift_j_invariant` — `jMontSq (tShift A u) = jMont A`: the shifted
  model really is a model of the same curve.  (Key identity:
  `(u+2)²(A²+u-1) = A²-4` modulo `u² + A²u + A² = 0`.)
* `modPoly2_jMont_jOther` — `Φ₂(j(E_A), jOther A u) = 0`: the two extra
  neighbours are genuine 2-isogeny neighbours.
* `two_isogeny_neighbours_complete` — **completeness**: if the three exhibited
  neighbours are pairwise distinct, then *every* solution of
  `Φ₂(j(E_A), Y) = 0` is one of them.  So the radical formula together with the
  two-torsion shift generates the whole 2-isogeny neighbourhood, and nothing is
  missed.
* `u_of_two_torsion`, `u_sum`, `u_prod`, `u_exists_iff_sq` — the dictionary
  between the two-torsion abscissa `r` and the parameter `u = A·r`, including
  the fact that the extra neighbours exist over `K` exactly when `A²(A²-4)` is a
  square, i.e. over `K(√(A²-4))`.
-/
import Cryptography.IsogenySIDH.RadicalNonBacktracking

set_option maxHeartbeats 1000000

namespace Cryptography.IsogenySIDH

variable {K : Type*} [Field K]

/-! ## Both `j`-invariants depend only on `A²` -/

/-- The Montgomery `j`-invariant as a function of `A²`. -/
def jMontSq (t : K) : K := 256 * (t - 3) ^ 3 / (t - 4)

/-- The quotient `j`-invariant as a function of `A²`. -/
def jQuotSq (t : K) : K := 16 * (t + 12) ^ 3 / (t - 4) ^ 2

theorem jMont_eq_jMontSq (A : K) : jMont A = jMontSq (A ^ 2) := rfl

theorem jQuot_eq_jQuotSq (A : K) : jQuot A = jQuotSq (A ^ 2) := rfl

/-- The modular identity of `ModularTwoIsogeny`, stated in the variable `t = A²`
in which it is actually a polynomial identity. -/
theorem modPoly2_jMontSq_jQuotSq {t : K} (ht : t - 4 ≠ 0) :
    modPoly2 (jMontSq t) (jQuotSq t) = 0 := by
  simp only [jMontSq, jQuotSq, modPoly2]
  field_simp
  ring

/-! ## The two-torsion shift -/

/-- `u = A·r`, where `r` is the abscissa of one of the two non-rational
two-torsion points of `E_A`, satisfies the *rational* quadratic
`u² + A²u + A² = 0`. -/
theorem u_of_two_torsion {A r : K} (hr : r ^ 2 + A * r + 1 = 0) :
    (A * r) ^ 2 + A ^ 2 * (A * r) + A ^ 2 = 0 := by
  linear_combination A ^ 2 * hr

/-- The two admissible values of `u` sum to `-A²`. -/
theorem u_sum {A u v : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hv : v ^ 2 + A ^ 2 * v + A ^ 2 = 0) (huv : u ≠ v) : u + v = -A ^ 2 := by
  have h : (u - v) * (u + v + A ^ 2) = 0 := by linear_combination hu - hv
  rcases mul_eq_zero.mp h with h1 | h1
  · exact absurd (sub_eq_zero.mp h1) huv
  · linear_combination h1

/-- The two admissible values of `u` multiply to `A²`. -/
theorem u_prod {A u v : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hv : v ^ 2 + A ^ 2 * v + A ^ 2 = 0) (huv : u ≠ v) : u * v = A ^ 2 := by
  have hs2 : u + v + A ^ 2 = 0 := by
    have h := u_sum hu hv huv
    linear_combination h
  linear_combination (u + 1) * hs2 - hu - hs2

/-- The extra neighbours are defined over `K` exactly when `A²(A² - 4)` is a
square in `K`, i.e. after adjoining `√(A²-4)`. -/
theorem u_exists_iff_sq (htwo : (2 : K) ≠ 0) (A : K) :
    (∃ u : K, u ^ 2 + A ^ 2 * u + A ^ 2 = 0) ↔ ∃ s : K, s ^ 2 = A ^ 2 * (A ^ 2 - 4) := by
  have hfour : (4 : K) ≠ 0 := by
    have h : (4 : K) = 2 * 2 := by norm_num
    rw [h]; exact mul_ne_zero htwo htwo
  constructor
  · rintro ⟨u, hu⟩
    exact ⟨2 * u + A ^ 2, by linear_combination 4 * hu⟩
  · rintro ⟨s, hs⟩
    refine ⟨(s - A ^ 2) / 2, ?_⟩
    field_simp
    linear_combination hs

/-- The square of the Montgomery parameter of the model of `E_A` with the
two-torsion point `(r,0)`, `u = A·r`, moved to the origin. -/
def tShift (A u : K) : K := (A ^ 2 - 3 * u - 9) / (-(u + 2))

/-- The `j`-invariant of the other neighbour of `E_A`, reached by the radical
formula applied to the shifted model. -/
def jOther (A u : K) : K :=
  16 * (A ^ 2 - 15 * u - 33) ^ 3 / ((-(u + 2)) * (A ^ 2 + u - 1) ^ 2)

/-- **The key identity.**  Modulo `u² + A²u + A² = 0` one has
`(u+2)²(A² + u - 1) = A² - 4`.  Every nondegeneracy statement below comes from
this. -/
theorem shift_key_identity {A u : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0) :
    (u + 2) ^ 2 * (A ^ 2 + u - 1) = A ^ 2 - 4 := by
  linear_combination (u + 3) * hu

theorem shift_ne_zero_left {A u : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) : u + 2 ≠ 0 := by
  intro h
  apply hd
  rw [← shift_key_identity hu, h]
  ring

theorem shift_ne_zero_right {A u : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) : A ^ 2 + u - 1 ≠ 0 := by
  intro h
  apply hd
  rw [← shift_key_identity hu, h]
  ring

theorem tShift_sub_four {A u : K} (hu2 : u + 2 ≠ 0) :
    tShift A u - 4 = (A ^ 2 + u - 1) / (-(u + 2)) := by
  simp only [tShift]
  field_simp
  ring

theorem tShift_sub_four_ne_zero {A u : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) : tShift A u - 4 ≠ 0 := by
  rw [tShift_sub_four (shift_ne_zero_left hu hd)]
  exact div_ne_zero (shift_ne_zero_right hu hd) (neg_ne_zero.mpr (shift_ne_zero_left hu hd))

/-- **The shifted model is a model of the same curve.**  Moving another
two-torsion point to the origin does not change the `j`-invariant. -/
theorem two_torsion_shift_j_invariant {A u : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) : jMontSq (tShift A u) = jMont A := by
  have hu2 : u + 2 ≠ 0 := shift_ne_zero_left hu hd
  have hu3 : A ^ 2 + u - 1 ≠ 0 := shift_ne_zero_right hu hd
  have e3 : tShift A u - 3 = (A ^ 2 - 3) / (-(u + 2)) := by
    simp only [tShift]; field_simp; ring
  have e4 : tShift A u - 4 = (A ^ 2 + u - 1) / (-(u + 2)) := tShift_sub_four hu2
  simp only [jMontSq, jMont, e3, e4]
  rw [← shift_key_identity hu]
  field_simp

/-- The radical step applied to the shifted model produces `jOther A u`. -/
theorem jQuotSq_tShift {A u : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) : jQuotSq (tShift A u) = jOther A u := by
  have hu2 : u + 2 ≠ 0 := shift_ne_zero_left hu hd
  have hu3 : A ^ 2 + u - 1 ≠ 0 := shift_ne_zero_right hu hd
  have e12 : tShift A u + 12 = (A ^ 2 - 15 * u - 33) / (-(u + 2)) := by
    simp only [tShift]; field_simp; ring
  have e4 : tShift A u - 4 = (A ^ 2 + u - 1) / (-(u + 2)) := tShift_sub_four hu2
  simp only [jQuotSq, jOther, e12, e4]
  field_simp

/-- **The two extra neighbours are genuine 2-isogeny neighbours.**  For each
root `u` of `u² + A²u + A² = 0` — that is, for each of the two non-rational
two-torsion points of `E_A` — the value `jOther A u` is a zero of `Φ₂` against
`j(E_A)`. -/
theorem modPoly2_jMont_jOther {A u : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) : modPoly2 (jMont A) (jOther A u) = 0 := by
  rw [← two_torsion_shift_j_invariant hu hd, ← jQuotSq_tShift hu hd]
  exact modPoly2_jMontSq_jQuotSq (tShift_sub_four_ne_zero hu hd)

/-! ## Completeness of the neighbour list -/

/-- **Completeness (previous cycle's Conjecture 5).**  Let `A` be a Montgomery
parameter with `A² ≠ 4` and let `u₁ ≠ u₂` be the two roots of `u² + A²u + A²`.
If the three exhibited neighbours `jQuot A`, `jOther A u₁`, `jOther A u₂` are
pairwise distinct, then they are *all* the 2-isogeny neighbours of `j(E_A)`:
every `Y` with `Φ₂(j(E_A), Y) = 0` is one of them.  Hence the radical formula,
applied to the three Montgomery models of `E_A`, misses no 2-isogeny. -/
theorem two_isogeny_neighbours_complete [DecidableEq K] {A u₁ u₂ Y : K}
    (hu₁ : u₁ ^ 2 + A ^ 2 * u₁ + A ^ 2 = 0) (hu₂ : u₂ ^ 2 + A ^ 2 * u₂ + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0)
    (h01 : jQuot A ≠ jOther A u₁) (h02 : jQuot A ≠ jOther A u₂)
    (h12 : jOther A u₁ ≠ jOther A u₂)
    (hY : modPoly2 (jMont A) Y = 0) :
    Y = jQuot A ∨ Y = jOther A u₁ ∨ Y = jOther A u₂ := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨hY0, hY1, hY2⟩ := hcon
  set S : Finset K := {jQuot A, jOther A u₁, jOther A u₂, Y} with hSdef
  have hcard : S.card = 4 := by
    rw [hSdef]
    rw [Finset.card_insert_of_notMem (by simp [h01, h02, Ne.symm hY0]),
      Finset.card_insert_of_notMem (by simp [h12, Ne.symm hY1]),
      Finset.card_insert_of_notMem (by simp [Ne.symm hY2]), Finset.card_singleton]
  have hroots : ∀ y ∈ S, modPoly2 (jMont A) y = 0 := by
    intro y hy
    simp only [hSdef, Finset.mem_insert, Finset.mem_singleton] at hy
    rcases hy with rfl | rfl | rfl | rfl
    · exact modPoly2_jMont_jQuot hd
    · exact modPoly2_jMont_jOther hu₁ hd
    · exact modPoly2_jMont_jOther hu₂ hd
    · exact hY
  have := two_isogeny_neighbours_card_le_three (jMont A) S hroots
  omega

/-- The radical target is genuinely different from the two shifted neighbours
whenever the walk is not at a fixed point: a convenient repackaging of
completeness as a three-element description of the neighbourhood. -/
theorem two_isogeny_neighbourhood_eq [DecidableEq K] {A u₁ u₂ : K}
    (hu₁ : u₁ ^ 2 + A ^ 2 * u₁ + A ^ 2 = 0) (hu₂ : u₂ ^ 2 + A ^ 2 * u₂ + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0)
    (h01 : jQuot A ≠ jOther A u₁) (h02 : jQuot A ≠ jOther A u₂)
    (h12 : jOther A u₁ ≠ jOther A u₂) :
    {Y : K | modPoly2 (jMont A) Y = 0} = {jQuot A, jOther A u₁, jOther A u₂} := by
  ext Y
  constructor
  · intro hY
    have := two_isogeny_neighbours_complete hu₁ hu₂ hd h01 h02 h12 hY
    simpa using this
  · intro hY
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hY
    rcases hY with rfl | rfl | rfl
    · exact modPoly2_jMont_jQuot hd
    · exact modPoly2_jMont_jOther hu₁ hd
    · exact modPoly2_jMont_jOther hu₂ hd

end Cryptography.IsogenySIDH