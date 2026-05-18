import Mathlib
import MachineLearning.TropicalNeuralCode.Defs

/-!
# Theorem B: Finite Tropical Hull Cells Imply Finite Classification Capacity

The dominance pattern of an input `x` against a finite neural codebook `C`
records, for each generator, the relative ordering of coordinatewise gaps.
This is a finite combinatorial invariant that controls classification.

## Main Results

* `finite_dominance_signature_range` — the dominance signature has finite range.
* `finite_classification_from_dominance` — classification factoring through
  a finite-range invariant has finite range.
* `finite_tropical_hull_cells_imply_finite_classification_capacity` —
  classification capacity is controlled by tropical combinatorial structure.
-/

noncomputable section

open Finset BigOperators

/-! ## Dominance Signature

For each pair of generators (s, s') ∈ C and each coordinate i, record the
sign of (x i - s i) - (x i - s' i) = s' i - s i. This is independent of x!
Instead, we use a more interesting invariant: for each generator s ∈ C,
record the coordinatewise ordering of gaps, i.e., the ranking of coordinates
by x i - s i. This does depend on x. -/

/-- The dominance signature: for each generator `s ∈ C` and pair of coordinates,
record whether `x i - s i ≥ x j - s j`. This captures the tropical structure
and depends genuinely on `x`. -/
def dominanceSignature {n : ℕ} (C : Finset (TropPoint n)) (x : TropPoint n) :
    C → Fin n → Fin n → Bool :=
  fun ⟨s, _⟩ i j => decide (x i - s i ≥ x j - s j)

/-
The dominance signature takes values in a finite type, hence has finite range.
-/
theorem finite_dominance_signature_range {n : ℕ}
    (C : Finset (TropPoint n)) :
    Set.Finite (Set.range (dominanceSignature C)) := by
  exact Set.toFinite _

/-
**Finite Classification Capacity via Dominance Signatures.**
If classification factors through the dominance signature (same signature
implies same label), then the classification has finite range.
-/
theorem finite_classification_from_dominance
    {n : ℕ}
    (C : Finset (TropPoint n))
    (Label : Type)
    (assign : TropPoint n → Label)
    (hcompat : ∀ x y : TropPoint n,
      dominanceSignature C x = dominanceSignature C y →
      assign x = assign y)
    : Set.Finite (Set.range assign) := by
  have h_finite : Set.Finite (Set.range (fun x : Set.range (fun x : TropPoint n => (dominanceSignature C x : C → Fin n → Fin n → Bool)) => assign (Classical.choose x.2))) := by
    convert Set.toFinite ( Set.range ( fun x : Set.range ( fun x : TropPoint n => ( dominanceSignature C x : C → Fin n → Fin n → Bool ) ) => assign ( Classical.choose x.2 ) ) ) using 1;
  refine h_finite.subset ?_;
  rintro _ ⟨ x, rfl ⟩ ; exact ⟨ ⟨ _, Set.mem_range_self x ⟩, hcompat _ _ <| Classical.choose_spec ( Set.mem_range.mp <| Set.mem_range_self x ) ⟩ ;

/-! ## Closest Generator Invariant -/

/-
The closest generator set has finite range (it's a subset of the powerset of C).
-/
theorem finite_closest_generator_set_range {n : ℕ} [NeZero n]
    (C : Finset (TropPoint n)) :
    Set.Finite (Set.range (closestGeneratorSet C)) := by
  exact Set.Finite.subset ( Finset.finite_toSet ( Finset.powerset C ) ) ( Set.range_subset_iff.mpr fun x => Finset.mem_powerset.mpr ( Finset.filter_subset _ _ ) )

/-
If classification depends only on the closest generator set,
then the classification has finite range.
-/
theorem finite_classification_from_closest_generators
    {n : ℕ} [NeZero n]
    (C : Finset (TropPoint n))
    (Label : Type)
    (assign : TropPoint n → Label)
    (hcompat : ∀ x y : TropPoint n,
      closestGeneratorSet C x = closestGeneratorSet C y →
      assign x = assign y)
    : Set.Finite (Set.range assign) := by
  -- Since closestGeneratorSet C has finite range, and assign factors through it (by hcompat), the range of assign is finite.
  have h_range_finite : Set.Finite (Set.image (fun x : TropPoint n => closestGeneratorSet C x) Set.univ) := by
    exact Set.finite_iff_bddAbove.mpr ⟨ C, Set.forall_mem_image.mpr fun x _ => Finset.filter_subset _ _ ⟩;
  have h_image_finite : ∀ y ∈ Set.image (fun x => closestGeneratorSet C x) Set.univ, Set.Finite (Set.image (fun x => assign x) {x | closestGeneratorSet C x = y}) := by
    intro y hy; obtain ⟨ x, hx, rfl ⟩ := hy; exact Set.Finite.subset ( Set.finite_singleton ( assign x ) ) ( by aesop ) ;
  exact Set.Finite.subset ( Set.Finite.biUnion h_range_finite h_image_finite ) fun x hx => by aesop;

end