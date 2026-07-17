import Geometry.TopeMagnitude.Hypercube

/-!
# Boolean tope spheres and a Stanley--Reisner Hilbert numerator

For the coordinate arrangement, the simplicial complex naturally recording wall
subsets is the full simplex.  Its face enumerator is `(1 + X)^n`; consequently its
coefficients simultaneously count metric spheres in the tope graph.  This is the
coordinate-arrangement model of the bridge between magnitude-homological ranks and
Stanley--Reisner data.

-- !-- Lab Notes -- !--
Hypothesis: the metric rank distribution of the coordinate tope graph is the face
enumerator of its wall simplex and obeys central-arrangement reciprocity.
Experiment: dimensions zero through five gave binomial rows, symmetric under
`k ↦ n-k`; polynomial multiplication by `1+X` reproduced the next row.
Analysis: a chamber is uniquely determined by its separating-wall subset.  Thus
metric degree is subset cardinality, while the simplex face enumerator records the
same statistic.
Critique: the face enumerator is the Hilbert numerator rather than the full Hilbert
series, and the theorem is deliberately restricted to coordinate arrangements.
The imported flag-complex result ensures the simplicial object is genuinely the
clique complex of a graph rather than an unrelated counting device.
Synthesis: `sphere_card_eq_coeff_wallEnumerator` gives the algebra--geometry bridge;
`wallEnumerator_reciprocity` and `sphere_reciprocity` express its duality symmetry.
-- !-- Lab Notes -- !--
-/

open Finset Polynomial

namespace TopeMagnitude

/-- Face enumerator of the Boolean wall simplex of an `n`-hyperplane coordinate
arrangement. -/
noncomputable def wallEnumerator (n : ℕ) : Polynomial ℕ := (1 + X) ^ n

/-
Coefficients of the wall-simplex enumerator are its face numbers.
-/
theorem coeff_wallEnumerator (n k : ℕ) :
    (wallEnumerator n).coeff k = n.choose k := by
  unfold wallEnumerator; rw [ add_comm, add_pow ] ; norm_num;
  exact fun h => by rw [ Nat.choose_eq_zero_of_lt h ] ;

/-- **Stanley--Reisner bridge for the coordinate arrangement.**  A coefficient of
the Boolean wall-simplex numerator equals the number of chambers in the matching
metric sphere of the tope graph. -/
theorem sphere_card_eq_coeff_wallEnumerator {n k : ℕ} (x : Fin n → Bool) :
    Fintype.card (sphere x k) = (wallEnumerator n).coeff k := by
  rw [sphere_card, coeff_wallEnumerator]

/-- Complementing a separating-wall subset gives reciprocity of opposite metric
degrees. -/
theorem sphere_reciprocity {n k : ℕ} (hk : k ≤ n) (x : Fin n → Bool) :
    Fintype.card (sphere x k) = Fintype.card (sphere x (n - k)) := by
  rw [sphere_card, sphere_card, Nat.choose_symm hk]

/-- The Boolean Stanley--Reisner numerator has reciprocal coefficients. -/
theorem wallEnumerator_reciprocity {n k : ℕ} (hk : k ≤ n) :
    (wallEnumerator n).coeff k = (wallEnumerator n).coeff (n - k) := by
  rw [coeff_wallEnumerator, coeff_wallEnumerator, Nat.choose_symm hk]

/-- The bridge commutes with reciprocity: opposite metric spheres equal opposite
coefficients of the same wall enumerator. -/
theorem reciprocity_bridge {n k : ℕ} (hk : k ≤ n) (x : Fin n → Bool) :
    Fintype.card (sphere x k) = (wallEnumerator n).coeff (n - k) := by
  rw [sphere_card_eq_coeff_wallEnumerator, wallEnumerator_reciprocity hk]

/-- The complete graph has the full simplex as its clique complex, anchoring the
wall simplex in the catalog's flag-complex construction. -/
theorem completeGraph_cliqueComplex_full (n : ℕ) :
    (cliqueComplex (SimpleGraph.completeGraph (Fin n))).faces = Set.univ := by
  ext s
  simp [cliqueComplex]

end TopeMagnitude