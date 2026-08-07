/-
# The six Montgomery models of one `j`-invariant, and the 6-to-3 fibration

`ModularTwoIsogeny` proved two counting *bounds*: a vertex of the 2-isogeny
graph has at most three neighbours, and a `j`-invariant has at most six
Montgomery models.  The previous cycle's Conjecture 2 asserted that both bounds
are attained and that the radical map `jQuot` fibres the six models onto the
three neighbours in pairs.  This file proves that, using the explicit second and
third Montgomery models constructed in `TwoIsogenyNeighbours`.

Given `A` with `A² ≠ 4` and the two roots `u₁ ≠ u₂` of `u² + A²u + A² = 0`, the
six Montgomery models of `E_A` are

  `± A`,  `± A₁`,  `± A₂`,   where `A₁² = tShift A u₁`, `A₂² = tShift A u₂`,

`± A₁` and `± A₂` being the models obtained by moving the two other two-torsion
points to the origin (these live over `K(√(A²-4), √(-A r - 2))`).

* `jMont_of_shift_root` — each `Aᵢ` is indeed a Montgomery model of the *same*
  curve, and is nondegenerate.
* `montgomery_models_complete` — **exactness of the bound `6`**: as soon as the
  six listed parameters are distinct, they are *all* the Montgomery models: any
  `B` with `j(E_B) = j(E_A)` and `B² ≠ 4` is one of them.
* `jQuot_of_shift_root`, `jQuot_image_of_models` — **the 6-to-3 fibration**: the
  radical map `jQuot` sends the six models onto exactly the three neighbours
  `jQuot A`, `jOther A u₁`, `jOther A u₂`, with fibres `{A, -A}`, `{A₁, -A₁}`,
  `{A₂, -A₂}` — the two members of a fibre differing by the sign of the radical,
  i.e. by the quadratic twist of the *model*.
* `two_isogeny_neighbours_card_eq_three` — **exactness of the bound `3`**: the
  vertex `j(E_A)` has exactly three neighbours in the 2-isogeny graph.
-/
import Cryptography.IsogenySIDH.TwoIsogenyNeighbours

set_option maxHeartbeats 1000000

namespace Cryptography.IsogenySIDH

variable {K : Type*} [Field K]

/-! ## The shifted models -/

/-- A square root of `tShift A u` is a Montgomery parameter of the *same* curve
`E_A`. -/
theorem jMont_of_shift_root {A u B : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) (hB : B ^ 2 = tShift A u) : jMont B = jMont A := by
  rw [jMont_eq_jMontSq, hB]
  exact two_torsion_shift_j_invariant hu hd

/-- The shifted models are nondegenerate. -/
theorem shift_root_ne_two {A u B : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) (hB : B ^ 2 = tShift A u) : B ^ 2 - 4 ≠ 0 := by
  rw [hB]
  exact tShift_sub_four_ne_zero hu hd

/-- The radical step applied to a shifted model reaches the corresponding
neighbour `jOther A u`. -/
theorem jQuot_of_shift_root {A u B : K} (hu : u ^ 2 + A ^ 2 * u + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) (hB : B ^ 2 = tShift A u) : jQuot B = jOther A u := by
  rw [jQuot_eq_jQuotSq, hB]
  exact jQuotSq_tShift hu hd

/-! ## Exactness of the bound six -/

/-- The six candidate Montgomery models of `E_A`. -/
def montModels [DecidableEq K] (A A₁ A₂ : K) : Finset K := {A, -A, A₁, -A₁, A₂, -A₂}

/-- Every listed parameter is a nondegenerate Montgomery model of `E_A`. -/
theorem montModels_are_models [DecidableEq K] {A A₁ A₂ u₁ u₂ : K}
    (hu₁ : u₁ ^ 2 + A ^ 2 * u₁ + A ^ 2 = 0) (hu₂ : u₂ ^ 2 + A ^ 2 * u₂ + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) (h1 : A₁ ^ 2 = tShift A u₁) (h2 : A₂ ^ 2 = tShift A u₂) :
    ∀ B ∈ montModels A A₁ A₂, B ^ 2 - 4 ≠ 0 ∧ jMont B = jMont A := by
  intro B hB
  simp only [montModels, Finset.mem_insert, Finset.mem_singleton] at hB
  have hneg : ∀ C : K, (-C) ^ 2 - 4 = C ^ 2 - 4 := by intro C; ring
  rcases hB with rfl | rfl | rfl | rfl | rfl | rfl
  · exact ⟨hd, rfl⟩
  · exact ⟨by rw [hneg]; exact hd, jMont_neg A⟩
  · exact ⟨shift_root_ne_two hu₁ hd h1, jMont_of_shift_root hu₁ hd h1⟩
  · exact ⟨by rw [hneg]; exact shift_root_ne_two hu₁ hd h1,
      by rw [jMont_neg]; exact jMont_of_shift_root hu₁ hd h1⟩
  · exact ⟨shift_root_ne_two hu₂ hd h2, jMont_of_shift_root hu₂ hd h2⟩
  · exact ⟨by rw [hneg]; exact shift_root_ne_two hu₂ hd h2,
      by rw [jMont_neg]; exact jMont_of_shift_root hu₂ hd h2⟩

/-- **Exactness of the bound `6`.**  If the six listed Montgomery parameters are
distinct, then they are all of them: any nondegenerate Montgomery parameter `B`
with the same `j`-invariant is one of the six.  (`montgomery_models_card_le_six`
of `ModularTwoIsogeny` gives the bound; here it is attained.) -/
theorem montgomery_models_complete [DecidableEq K] {A A₁ A₂ u₁ u₂ B : K}
    (htwo : (2 : K) ≠ 0)
    (hu₁ : u₁ ^ 2 + A ^ 2 * u₁ + A ^ 2 = 0) (hu₂ : u₂ ^ 2 + A ^ 2 * u₂ + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) (h1 : A₁ ^ 2 = tShift A u₁) (h2 : A₂ ^ 2 = tShift A u₂)
    (hcard : (montModels A A₁ A₂).card = 6)
    (hB : B ^ 2 - 4 ≠ 0) (hjB : jMont B = jMont A) :
    B ∈ montModels A A₁ A₂ := by
  by_contra hcon
  have hall : ∀ C ∈ insert B (montModels A A₁ A₂), C ^ 2 - 4 ≠ 0 ∧ jMont C = jMont A := by
    intro C hC
    rcases Finset.mem_insert.mp hC with rfl | hC'
    · exact ⟨hB, hjB⟩
    · exact montModels_are_models hu₁ hu₂ hd h1 h2 C hC'
  have hcard' : (insert B (montModels A A₁ A₂)).card = 7 := by
    rw [Finset.card_insert_of_notMem hcon, hcard]
  have := montgomery_models_card_le_six htwo (jMont A) _ hall
  omega

/-! ## The 6-to-3 fibration -/

/-- **The radical map on the six models.**  `jQuot` takes the value `jQuot A` on
`{A, -A}`, the value `jOther A u₁` on `{A₁, -A₁}` and the value `jOther A u₂` on
`{A₂, -A₂}`: the six Montgomery models fibre two-to-one over the three
neighbours, the two members of a fibre differing by the sign of the radical. -/
theorem jQuot_image_of_models [DecidableEq K] {A A₁ A₂ u₁ u₂ : K}
    (hu₁ : u₁ ^ 2 + A ^ 2 * u₁ + A ^ 2 = 0) (hu₂ : u₂ ^ 2 + A ^ 2 * u₂ + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0) (h1 : A₁ ^ 2 = tShift A u₁) (h2 : A₂ ^ 2 = tShift A u₂) :
    (montModels A A₁ A₂).image jQuot = {jQuot A, jOther A u₁, jOther A u₂} := by
  have e1 : jQuot A₁ = jOther A u₁ := jQuot_of_shift_root hu₁ hd h1
  have e2 : jQuot A₂ = jOther A u₂ := jQuot_of_shift_root hu₂ hd h2
  simp only [montModels, Finset.image_insert, Finset.image_singleton, jQuot_neg, e1, e2]
  ext y
  simp only [Finset.mem_insert, Finset.mem_singleton]
  tauto

/-- **Exactness of the bound `3`.**  If the three neighbours are pairwise
distinct, the vertex `j(E_A)` of the 2-isogeny graph has exactly three
neighbours: the bound of `two_isogeny_neighbours_card_le_three` is attained, and
by `two_isogeny_neighbours_complete` nothing else occurs. -/
theorem two_isogeny_neighbours_card_eq_three [DecidableEq K] {A u₁ u₂ : K}
    (hu₁ : u₁ ^ 2 + A ^ 2 * u₁ + A ^ 2 = 0) (hu₂ : u₂ ^ 2 + A ^ 2 * u₂ + A ^ 2 = 0)
    (hd : A ^ 2 - 4 ≠ 0)
    (h01 : jQuot A ≠ jOther A u₁) (h02 : jQuot A ≠ jOther A u₂)
    (h12 : jOther A u₁ ≠ jOther A u₂) :
    ∃ S : Finset K, S.card = 3 ∧ (∀ y, y ∈ S ↔ modPoly2 (jMont A) y = 0) := by
  refine ⟨{jQuot A, jOther A u₁, jOther A u₂}, ?_, ?_⟩
  · rw [Finset.card_insert_of_notMem (by simp [h01, h02]),
      Finset.card_insert_of_notMem (by simp [h12]), Finset.card_singleton]
  · intro y
    constructor
    · intro hy
      simp only [Finset.mem_insert, Finset.mem_singleton] at hy
      rcases hy with rfl | rfl | rfl
      · exact modPoly2_jMont_jQuot hd
      · exact modPoly2_jMont_jOther hu₁ hd
      · exact modPoly2_jMont_jOther hu₂ hd
    · intro hy
      have := two_isogeny_neighbours_complete hu₁ hu₂ hd h01 h02 h12 hy
      simp only [Finset.mem_insert, Finset.mem_singleton]
      exact this

end Cryptography.IsogenySIDH