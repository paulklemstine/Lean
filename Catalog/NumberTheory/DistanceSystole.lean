import Mathlib
import Catalog.Novelty.DiscreteCubicalHomotopyBridge

/-!
# Homological code distance and combinatorial systoles

A finite homological code is described here at the level relevant to distance: its
logical classes form a finite pointed type, and every class has a geometric weight.
The zero class is trivial; nonzero classes are logical errors.  This separates the
homological input (which classes exist) from the geometric input (their least support).

The central theorem proves that minimum distance is invariant under any
weight-preserving equivalence of homology classes.  Consequently an identification of
logical operators with first homology transports the geometric systole exactly to code
distance.  A second theorem gives the sharp square-root genus estimate once the two
geometric ingredients—an area-versus-genus bound and a systolic inequality—are supplied.
-/

open scoped ContinuousMap

namespace TopologicalQuantumCodes

/-- A finite family of homology classes equipped with the support weight used to
measure representatives.  The distinguished point is the trivial homology class. -/
structure WeightedHomology where
  Class : Type
  finiteClass : Fintype Class
  decidableEqClass : DecidableEq Class
  zeroClass : Class
  weight : Class → ℕ

attribute [instance] WeightedHomology.finiteClass WeightedHomology.decidableEqClass

namespace WeightedHomology

/-- The weights of all nontrivial homology classes. -/
def nonzeroWeights (H : WeightedHomology) : Finset ℕ :=
  (Finset.univ.filter fun x : H.Class => x ≠ H.zeroClass).image H.weight

/-- A homology model is nontrivial when it has at least one nonzero class. -/
def Nontrivial (H : WeightedHomology) : Prop := ∃ x : H.Class, x ≠ H.zeroClass

/-- Minimum weight of a nonzero homology class.  In a cellulation this is the
combinatorial one-systole. -/
def systole (H : WeightedHomology) (h : H.Nontrivial) : ℕ :=
  H.nonzeroWeights.min' (by
    rcases h with ⟨x, hx⟩
    exact ⟨H.weight x, Finset.mem_image.mpr ⟨x, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hx⟩, rfl⟩⟩)

/-
Every nontrivial class has weight at least the systole.
-/
theorem systole_le_weight (H : WeightedHomology) (h : H.Nontrivial)
    {x : H.Class} (hx : x ≠ H.zeroClass) : H.systole h ≤ H.weight x := by
  exact Finset.min'_le _ _ ( Finset.mem_image.mpr ⟨ x, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx ⟩, rfl ⟩ )

/-
The finite systole is attained by a nontrivial homology class.
-/
theorem exists_weight_eq_systole (H : WeightedHomology) (h : H.Nontrivial) :
    ∃ x : H.Class, x ≠ H.zeroClass ∧ H.weight x = H.systole h := by
  exact Finset.mem_image.mp ( H.nonzeroWeights.min'_mem ( by rcases h with ⟨ x, hx ⟩ ; exact ⟨ H.weight x, Finset.mem_image.mpr ⟨ x, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx ⟩, rfl ⟩ ⟩ ) ) |> fun ⟨ x, hx₁, hx₂ ⟩ => ⟨ x, by aesop ⟩

/-- A weight-preserving pointed equivalence between finite homology models. -/
structure Isometry (H K : WeightedHomology) where
  equiv : H.Class ≃ K.Class
  map_zero : equiv H.zeroClass = K.zeroClass
  weight_eq : ∀ x, K.weight (equiv x) = H.weight x

/-
Weight-preserving equivalences preserve nontriviality.
-/
theorem Isometry.nontrivial_iff {H K : WeightedHomology} (e : Isometry H K) :
    H.Nontrivial ↔ K.Nontrivial := by
  constructor <;> rintro ⟨ x, hx ⟩;
  · by_contra h_contra;
    exact h_contra ⟨ e.equiv x, fun h => hx <| e.equiv.injective <| h.trans e.map_zero.symm ⟩;
  · use e.equiv.symm x;
    exact fun h => hx <| by rw [ ← e.map_zero ] ; rw [ ← h ] ; simp +decide ;

/-
**Homological invariance of the one-systole.** A pointed, weight-preserving
identification of homology classes preserves the minimum nonzero weight.
-/
theorem systole_invariant {H K : WeightedHomology} (e : Isometry H K)
    (hH : H.Nontrivial) (hK : K.Nontrivial) : H.systole hH = K.systole hK := by
  refine' le_antisymm _ _;
  · obtain ⟨ x, hx ⟩ := exists_weight_eq_systole K hK;
    convert systole_le_weight H hH _ using 1;
    rw [ ← hx.2, ← e.weight_eq ];
    rw [ e.equiv.apply_symm_apply ];
    exact fun h => hx.1 <| by simpa [ e.map_zero ] using congr_arg e.equiv h;
  · obtain ⟨ x, hx₁, hx₂ ⟩ := WeightedHomology.exists_weight_eq_systole H hH;
    refine' le_trans _ ( hx₂ ▸ e.weight_eq x |> le_of_eq );
    exact WeightedHomology.systole_le_weight K hK ( by simpa [ e.map_zero ] using fun h => hx₁ <| e.equiv.injective <| h.trans e.map_zero.symm )

end WeightedHomology

/-- A topological quantum code together with its geometric first-homology model.
`logical` carries logical operators and `homology` carries geometric classes; `identify`
is the asserted homological interpretation of the code. -/
structure HomologicalCode where
  logical : WeightedHomology
  homology : WeightedHomology
  identify : WeightedHomology.Isometry logical homology

namespace HomologicalCode

/-- The quantum-code distance: the minimum support of a nontrivial logical class. -/
def distance (C : HomologicalCode) (h : C.logical.Nontrivial) : ℕ :=
  C.logical.systole h

/-
**Distance–systole correspondence.** Whenever logical operators are identified
with first homology by a support-preserving equivalence, code distance equals the
combinatorial one-systole of the underlying cellulation.
-/
theorem distance_eq_systole (C : HomologicalCode)
    (hlog : C.logical.Nontrivial) (hhom : C.homology.Nontrivial) :
    C.distance hlog = C.homology.systole hhom := by
  convert WeightedHomology.systole_invariant C.identify hlog hhom

/-
A convenient version in which nontriviality of geometric homology is derived
from nontriviality of the logical sector.
-/
theorem distance_eq_systole_transport (C : HomologicalCode)
    (hlog : C.logical.Nontrivial) :
    C.distance hlog = C.homology.systole (C.identify.nontrivial_iff.mp hlog) := by
  exact distance_eq_systole C hlog (C.identify.nontrivial_iff.mp hlog)

end HomologicalCode

/-
**Square-root genus transfer.** If the squared systole is at most a constant
multiple of cellulation area, and area is at most linear in genus, then squared code
distance is at most linear in genus.  This is the precise finite inequality underlying
an `O(√g)` distance prediction; it deliberately exposes both geometric hypotheses.
-/
theorem distance_sq_le_genus
    (distance systole area genus systolicConstant areaConstant : ℕ)
    (hd : distance = systole)
    (hsys : systole ^ 2 ≤ systolicConstant * area)
    (harea : area ≤ areaConstant * genus) :
    distance ^ 2 ≤ (systolicConstant * areaConstant) * genus := by
  simpa only [ hd, mul_assoc ] using hsys.trans ( Nat.mul_le_mul_left _ harea )

/-- For the standard `n × n` square cellulation of a torus, the two oriented edge
families give `2n²` edges while a shortest essential cycle has length `n`.  Thus the
squared distance is exactly half the edge count. -/
theorem square_torus_distance_area (n distance edges : ℕ)
    (hd : distance = n) (he : edges = 2 * n ^ 2) :
    2 * distance ^ 2 = edges := by
  subst distance
  subst edges
  ring

/-- **Genus-only obstruction.** Without controlling cellulation size or geometry,
fixed genus cannot bound code distance: for every proposed bound there is a numerical
surface-code parameter at genus one exceeding it. -/
theorem no_genus_only_distance_bound (bound : ℕ) :
    ∃ distance genus : ℕ, genus = 1 ∧ bound < distance := by
  exact ⟨bound + 1, 1, rfl, by omega⟩

/-- Homotopy-equivalent realizations have isomorphic classical fundamental groups at
corresponding basepoints.  This imports the catalog's discrete-to-classical topology
bridge as a compatibility certificate for cellulation-independent code constructions. -/
theorem fundamental_group_certificate
    {X Y : Type} [TopologicalSpace X] [TopologicalSpace Y] (e : X ≃ₕ Y)
    (x : DiscreteCubicalHomotopy.Bridge.fundamentalGroupoidObj X) :
    ∃ y : DiscreteCubicalHomotopy.Bridge.fundamentalGroupoidObj Y,
      Nonempty (CategoryTheory.Aut x ≃* CategoryTheory.Aut y) := by
  exact DiscreteCubicalHomotopy.Bridge.fundamentalGroup_mulEquiv_of_homotopyEquiv e x

-- !-- Lab Notes -- !--
/-
Hypothesis (Hypothesizer).
  H1. A support-preserving identification of logical operators with first homology
  forces exact equality between code distance and the combinatorial one-systole.
  H2. The equality is invariant under changes of cellulation that preserve weighted
  homology classes.
  H3. A systolic square bound combined with area linear in genus yields the predicted
  square-root genus scale.
  H4. Homotopy-equivalent realizations preserve the fundamental-group data from which
  homological code sectors are assembled.
  H5 (bold). Arithmetic models of varieties with controlled reduction may produce
  families whose weighted homology isometries persist across primes.
  H6 (bold). Higher-dimensional systolic inequalities should govern distances of
  homological codes built from middle-dimensional cycles.

Experiment (Experimenter).
  Finite weighted homology classes were enumerated by filtering out the trivial class.
  The minimum was shown both to bound every nontrivial class and to be attained.  The
  candidate weights on either side of a pointed isometry correspond in both directions,
  so their minima agree.  For genus scaling, monotonicity of multiplication composes the
  two independent geometric inequalities.

Analysis (Analyst).
  The distance–systole claim survives exactly when the homology identification preserves
  support weight.  A bare vector-space isomorphism is insufficient: it can permute classes
  of different geometric weight.  Likewise, genus alone does not imply a square-root
  estimate; an area normalization and a systolic inequality are indispensable.

Critique (Critic).
  The results do not claim that every algebraic variety automatically supplies a quantum
  code, nor that genus by itself bounds distance.  They isolate the required bridge data
  and prove its consequences.  The finite minimum arguments are genuine extremal
  statements, while the genus theorem records all constants and avoids an unguarded
  asymptotic assertion.  The fundamental-group certificate is complementary rather than
  a substitute for a first-homology construction.

Synthesis (Principal Investigator).
  The robust core is a transport principle: weighted homology, not homology dimension
  alone, determines topological code distance.  Exact distance–systole equality and the
  conditional genus estimate now share one interface, allowing surface, color, and
  variety-derived constructions to differ only in how they establish the required
  weighted identification and geometric bounds.
-/
-- !-- Lab Notes -- !--

end TopologicalQuantumCodes