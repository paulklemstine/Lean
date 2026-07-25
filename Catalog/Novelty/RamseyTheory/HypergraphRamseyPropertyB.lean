import Mathlib
import Novelty.RamseyTheory.PropertyBSparseHypergraph

/-!
# Hypergraph Ramsey Avoidance as Property B

A two-colouring of the `r`-subsets of an `n`-set avoids monochromatic
`k`-sets precisely when it properly colours an auxiliary hypergraph.  The
vertices of the auxiliary hypergraph are themselves subsets of `Fin n`, and
its edges are the families of all `r`-subsets lying in a fixed `k`-set.
This incidence transformation connects diagonal Ramsey avoidance to Property B.

The main consequence transfers the sparse-hypergraph theorem
`PropertyB.twoColorable_of_card_lt`: if the number of candidate `k`-sets is
smaller than `2^(C(k,r)-1)`, then a monochromatic `k`-set can be avoided.
-/

open scoped Classical
open Finset

namespace HypergraphRamseyPropertyB

/-- A set is homogeneous when all its `r`-subsets receive the same colour. -/
def IsHomogeneous {n : ℕ} (r : ℕ) (c : Finset (Fin n) → Bool)
    (S : Finset (Fin n)) (b : Bool) : Prop :=
  ∀ T ∈ S.powersetCard r, c T = b

/-- The diagonal, two-colour `r`-uniform Ramsey property on `Fin n`. -/
def DiagonalRamsey (n r k : ℕ) : Prop :=
  ∀ c : Finset (Fin n) → Bool,
    ∃ S : Finset (Fin n), S.card = k ∧
      (IsHomogeneous r c S true ∨ IsHomogeneous r c S false)

/-- The auxiliary Property-B hypergraph: one edge for every `k`-set, consisting
of all `r`-subsets of that set. -/
def cliqueIncidenceHypergraph (n r k : ℕ) :
    Finset (Finset (Finset (Fin n))) :=
  (Finset.univ : Finset (Finset (Fin n))).filter (fun S => S.card = k)
    |>.image (fun S => S.powersetCard r)

/-
!-- Lab Notes -- !--

Hypothesis: Ramsey avoidance is not merely analogous to Property B; it is
literally Property B after passing to the incidence hypergraph whose vertices
are `r`-sets and whose edges encode candidate cliques.

Experiment: encode the red colour class as a finite set of subsets.  Properness
then says that every candidate clique has both a red and a blue `r`-edge.

Analysis: the incidence transformation separates the probabilistic argument
into two reusable facts: every incidence edge has size `C(k,r)`, and there are
at most `C(n,k)` such edges.

Critique: values of the colouring away from `r`-subsets are irrelevant, but do
not create a hidden assumption: the auxiliary edges contain only `r`-subsets.
The counting estimate is deliberately an upper bound because the image may
identify candidate sets in degenerate parameter ranges.

Synthesis: transfer sparse Property B through the incidence construction to
obtain a general finite lower-bound criterion for diagonal hypergraph Ramsey
numbers.

Every edge in the incidence hypergraph has the expected binomial size.
-/
theorem incidence_uniform {n r k : ℕ} :
    ∀ e ∈ cliqueIncidenceHypergraph n r k, e.card = Nat.choose k r := by
  intro e he;
  obtain ⟨ S, hS₁, rfl ⟩ := Finset.mem_image.mp he;
  aesop

/-
The incidence hypergraph has at most as many edges as there are `k`-sets.
-/
theorem incidence_card_le (n r k : ℕ) :
    (cliqueIncidenceHypergraph n r k).card ≤ Nat.choose n k := by
  convert Finset.card_image_le;
  rw [ show Finset.filter ( fun S => Finset.card S = k ) Finset.univ = Finset.powersetCard k Finset.univ by ext; simp +decide [ Finset.mem_powersetCard ], Finset.card_powersetCard, Finset.card_fin ]

/-
A proper Property-B colouring of the incidence hypergraph induces a
Ramsey-avoiding red/blue colouring of the original `r`-subsets.
-/
theorem not_diagonalRamsey_of_twoColorable {n r k : ℕ}
    (hB : PropertyB.TwoColorable (cliqueIncidenceHypergraph n r k)) :
    ¬ DiagonalRamsey n r k := by
  obtain ⟨ R, hR ⟩ := hB;
  intro h;
  obtain ⟨ S, hS₁, hS₂ ⟩ := h ( fun T => T ∈ R );
  have := hR ( S.powersetCard r ) ?_ <;> simp_all +decide [ IsHomogeneous ];
  · cases hS₂ <;> simp_all +decide [ Finset.subset_iff, Finset.disjoint_left ];
  · unfold cliqueIncidenceHypergraph; aesop;

/-
The incidence construction is an exact bridge: it has Property B if and
only if the corresponding diagonal Ramsey property fails.
-/
theorem incidence_twoColorable_iff {n r k : ℕ} :
    PropertyB.TwoColorable (cliqueIncidenceHypergraph n r k) ↔
      ¬ DiagonalRamsey n r k := by
  refine' ⟨ not_diagonalRamsey_of_twoColorable, _ ⟩;
  intro h_not_diagonalRamsey
  obtain ⟨c, hc⟩ : ∃ c : Finset (Fin n) → Bool, ∀ S : Finset (Fin n), S.card = k → ¬(IsHomogeneous r c S true ∨ IsHomogeneous r c S false) := by
    unfold DiagonalRamsey at h_not_diagonalRamsey; aesop;
  use Finset.univ.filter (fun T => c T = true);
  intro e he;
  unfold cliqueIncidenceHypergraph at he; simp_all +decide [ Finset.subset_iff ] ;
  rcases he with ⟨ S, hS₁, rfl ⟩ ; specialize hc S hS₁; simp_all +decide [ Finset.disjoint_left, IsHomogeneous ] ;
  grind

/-
**Property-B transfer bound.** If `C(n,k) < 2^(C(k,r)-1)`, there is a
red/blue colouring of the `r`-subsets of `Fin n` with no monochromatic `k`-set.
-/
theorem ramsey_avoidance_of_choose_lt {n r k : ℕ}
    (hcount : Nat.choose n k < 2 ^ (Nat.choose k r - 1)) :
    ¬ DiagonalRamsey n r k := by
  contrapose! hcount;
  have := @PropertyB.twoColorable_of_card_lt;
  exact le_of_not_gt fun h => absurd ( @not_diagonalRamsey_of_twoColorable _ _ _ <| this _ _ ( incidence_uniform ) <| lt_of_le_of_lt ( incidence_card_le _ _ _ ) h ) ( by tauto )

/-
Every diagonal Ramsey property forces the numerical obstruction opposite
to the Property-B avoidance criterion.
-/
theorem choose_threshold_of_diagonalRamsey {n r k : ℕ}
    (hRamsey : DiagonalRamsey n r k) :
    2 ^ (Nat.choose k r - 1) ≤ Nat.choose n k := by
  grind +suggestions

/-
More structurally, a Ramsey property forces its incidence hypergraph to
have at least the Property-B threshold number of edges.
-/
theorem incidence_card_threshold_of_diagonalRamsey {n r k : ℕ}
    (hRamsey : DiagonalRamsey n r k) :
    2 ^ (Nat.choose k r - 1) ≤ (cliqueIncidenceHypergraph n r k).card := by
  convert PropertyB.card_ge_of_not_twoColorable ( Nat.choose k r ) ( cliqueIncidenceHypergraph n r k ) ( fun e he => incidence_uniform e he ▸ rfl ) _ using 1;
  convert incidence_twoColorable_iff.not.mpr _;
  exact Classical.not_not.2 hRamsey

/-
In the 3-uniform case, the transfer criterion excludes a monochromatic
5-set on eleven vertices.
-/
theorem no_monochromatic_five_on_eleven :
    ¬ DiagonalRamsey 11 3 5 := by
  convert HypergraphRamseyPropertyB.ramsey_avoidance_of_choose_lt _;
  native_decide

end HypergraphRamseyPropertyB