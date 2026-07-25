import Physics.QuantumLatinSquaresOrderSix.SchurBound
import Physics.PosetTheory.LatinPatternCount

/-!
# Cardinality certificates for the 19, 21, and 23 constructions

This chapter expresses the finite combinatorial certificates behind the three order-six
cardinalities.  The nineteen-ray certificate isolates the triple coincidence at unordered
positions `(0,1)`, `(2,5)`, and `(3,4)`.  The twenty-one-ray certificate records injectivity
on all unordered positions.  The twenty-three-ray certificate is the disjoint-union count
arising from the decomposition into four- and two-dimensional summands.
-/

open Finset

namespace QuantumLatinOrderSix

/-
A classical Latin square of order six uses exactly six symbols.  Thus cardinalities
nineteen, twenty-one, and twenty-three measure behavior unavailable to computational-basis
Latin squares.
-/
theorem classical_orderSix_range_card
    (L : Fin 6 → Fin 6 → Fin 6) (hL : LatinPatternCount.IsLatin L) :
    (Finset.univ.image (fun p : Fin 6 × Fin 6 => L p.1 p.2)).card = 6 := by
  refine' le_antisymm _ _;
  · exact Finset.card_le_univ _;
  · exact le_trans ( by simp +decide [ Finset.card_image_of_injective _ ( hL.1 0 ) ] ) ( Finset.card_le_card ( show Finset.image ( fun p => L 0 p ) Finset.univ ⊆ Finset.image ( fun p : Fin 6 × Fin 6 => L p.1 p.2 ) Finset.univ from Finset.image_subset_iff.mpr fun p _ => Finset.mem_image.mpr ⟨ ( 0, p ), Finset.mem_univ _, rfl ⟩ ) )

/-- The three upper-triangular positions participating in the reported nontrivial
coincidence. -/
def coincidence01 : Fin 6 × Fin 6 := (0, 1)
def coincidence25 : Fin 6 × Fin 6 := (2, 5)
def coincidence34 : Fin 6 × Fin 6 := (3, 4)

/-- Keep one representative of the triple coincidence and remove the other two. -/
def nineteenRepresentatives : Finset (Fin 6 × Fin 6) :=
  ((upperPairs 6).erase coincidence25).erase coincidence34

/-- The proposed representative set really has nineteen positions. -/
theorem nineteenRepresentatives_card : nineteenRepresentatives.card = 19 := by
  native_decide

/-
A labeling with exactly the stated triple coincidence and no collision among the
remaining representatives has cardinality nineteen.
-/
theorem cardinality_nineteen_of_unique_triple {R : Type*} [DecidableEq R]
    (A : Fin 6 → Fin 6 → R)
    (hsym : ∀ i j, A i j = A j i)
    (h25 : A 2 5 = A 0 1)
    (h34 : A 3 4 = A 0 1)
    (hinj : Set.InjOn (fun p : Fin 6 × Fin 6 => A p.1 p.2) nineteenRepresentatives) :
    (Finset.univ.image (fun p : Fin 6 × Fin 6 => A p.1 p.2)).card = 19 := by
  -- By the hypothesis `h25` and `h34`, the range of `A` is equal to the image of `nineteenRepresentatives`.
  have h_image_eq : Finset.image (fun p : Fin 6 × Fin 6 => A p.1 p.2) Finset.univ = Finset.image (fun p : Fin 6 × Fin 6 => A p.1 p.2) nineteenRepresentatives := by
    ext x;
    constructor <;> simp +decide [ Finset.mem_image ];
    · intro i j hx
      by_cases h_cases : (i, j) = (2, 5) ∨ (i, j) = (5, 2) ∨ (i, j) = (3, 4) ∨ (i, j) = (4, 3);
      · use 0, 1; simp_all +decide [ nineteenRepresentatives ] ;
        grind +ring;
      · use if i ≤ j then i else j, if i ≤ j then j else i;
        split_ifs <;> simp_all +decide [ nineteenRepresentatives ];
        · exact ⟨ by rintro ⟨ rfl, rfl ⟩ ; exact h_cases.2.2.1 rfl rfl, by rintro ⟨ rfl, rfl ⟩ ; exact h_cases.1 rfl rfl, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by assumption ⟩ ⟩;
        · fin_cases i <;> fin_cases j <;> trivial;
    · exact fun i j hij hx => ⟨ i, j, hx ⟩;
  rw [ h_image_eq, Finset.card_image_of_injOn ] <;> aesop

/-
If all unordered Schur-product labels are inequivalent, the symmetric range reaches
the upper bound twenty-one.
-/
theorem cardinality_twentyOne_of_upper_injective {R : Type*} [DecidableEq R]
    (A : Fin 6 → Fin 6 → R)
    (hsym : ∀ i j, A i j = A j i)
    (hinj : Set.InjOn (fun p : Fin 6 × Fin 6 => A p.1 p.2) (upperPairs 6)) :
    (Finset.univ.image (fun p : Fin 6 × Fin 6 => A p.1 p.2)).card = 21 := by
  rw [ ← upperPairs_six_card, ← Finset.card_image_of_injOn hinj ];
  rw [ ← range_symmetric_eq_upper A hsym ]

/-- Disjoint finite ray families of cardinalities nineteen and four have a union of
cardinality twenty-three.  This is the cardinal arithmetic used by the direct-sum
construction, where nonzero rays in complementary summands are automatically disjoint. -/
theorem cardinality_twentyThree_of_disjoint_union {R : Type*} [DecidableEq R]
    (raysFour raysTwo : Finset R)
    (hFour : raysFour.card = 19) (hTwo : raysTwo.card = 4)
    (hdisj : Disjoint raysFour raysTwo) :
    (raysFour ∪ raysTwo).card = 23 := by
  rw [Finset.card_union_of_disjoint hdisj, hFour, hTwo]

/-- A subspace tag gives a canonical combinatorial model of complementary summands: the
nineteen four-dimensional labels and four two-dimensional labels cannot collide. -/
theorem tagged_directSum_cardinality
    (raysFour : Finset (Fin 19)) (raysTwo : Finset (Fin 4))
    (hFour : raysFour = Finset.univ) (hTwo : raysTwo = Finset.univ) :
    ((raysFour.image Sum.inl) ∪ (raysTwo.image Sum.inr)).card = 23 := by
  subst raysFour
  subst raysTwo
  have hd : Disjoint (Finset.univ.image (Sum.inl : Fin 19 → Sum (Fin 19) (Fin 4)))
      (Finset.univ.image (Sum.inr : Fin 4 → Sum (Fin 19) (Fin 4))) := by
    refine Finset.disjoint_left.2 ?_
    intro z hzL hzR
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hzL hzR
    rcases hzL with ⟨a, rfl⟩
    rcases hzR with ⟨b, h⟩
    simp at h
  apply cardinality_twentyThree_of_disjoint_union _ _
  · rw [Finset.card_image_of_injective _ Sum.inl_injective, Finset.card_univ, Fintype.card_fin]
  · rw [Finset.card_image_of_injective _ Sum.inr_injective, Finset.card_univ, Fintype.card_fin]
  · exact hd

-- !-- Lab Notes -- !--
/-
Hypothesis: the three reported cardinalities admit short independent certificates: one
controlled triple fiber, complete injectivity on unordered pairs, and a disjoint 19+4 split.

Experiment: deleting `(2,5)` and `(3,4)` from the twenty-one-element upper triangle leaves
nineteen representatives. Tagged enumeration of complementary summands gives nineteen plus
four labels with no possible cross-tag equality.

Analysis: cardinalities nineteen and twenty-one are two fiber patterns of the same symmetric
index map. Cardinality twenty-three is qualitatively different: it escapes the symmetric
bound by assembling label families from complementary summands.

Critique: these theorems certify cardinality once the numerical inner-product and ray-
inequivalence checks for a concrete matrix are supplied. They do not replace those explicit
coordinate checks, and they do not infer orthogonality from cardinality data.

Synthesis: the three examples are organized by reusable finite certificates that separate
geometric verification from exact range counting.
-/
-- !-- Lab Notes -- !--

end QuantumLatinOrderSix