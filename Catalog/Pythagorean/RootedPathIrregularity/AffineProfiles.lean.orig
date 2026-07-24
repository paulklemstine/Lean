import Logic.RootedPathIrregularity.Contrarian

/-!
# Rooted-path profiles and affine separation

A recurring mechanism in constructions of path-irregular graphs is that every
rooted or ordinary path count becomes an affine function of a large construction
parameter.  The results below isolate the finite-family separation principle:
pairwise distinct slopes force all the profiles to separate simultaneously once
the parameter exceeds every intercept.

The local `P₃` identities are then used to expose the exceptional central-root
obstruction and the compensation forced between ordinary and end-rooted counts.

-- !-- Lab Notes -- !--
HYPOTHESIS (ranked by expected impact).
1. A finite collection of path-count statistics with injective leading
   coefficients becomes simultaneously irregular for every sufficiently large
   parameter.
2. The same principle should extend from affine profiles to polynomial profiles
   ordered by their first unequal coefficient.
3. Graph families formed by attaching parametrized asymmetric branches should
   have uniform polynomial count profiles for every bounded path length.
4. Ordinary `P₃` irregularity should force end-root separation on every collision
   class of the degree statistic.
5. Central-rooted `P₃` irregularity should fail for every nontrivial finite simple
   graph, independently of connectedness.
6. A broader extension should replace paths by rooted trees whose embedding
   counts have distinct leading terms.

EXPERIMENT.
The concrete six-vertex graph imported from the catalog has ordinary counts
`[6,3,7,5,1,2]` and end-rooted counts `[3,2,4,4,1,2]`.  Thus ordinary
irregularity alone does not imply end-rooted irregularity.  The affine examples
below test simultaneous separation for two statistics and three vertices.

ANALYSIS.
Conjectures 1, 4, and 5 survive.  Conjecture 1 follows from an ordered-slope
argument, while 4 follows from the exact decomposition ordinary = central + end.
The six-vertex counterexample defeats the unguarded converse from ordinary to
end-rooted irregularity.  Conjectures 2, 3, and 6 require additional polynomial
and graph-attachment infrastructure.

CRITIQUE.
The affine theorem is a sufficient criterion, not an existence theorem for the
paper's graph family.  Its strict threshold is essential: at the boundary an
intercept can cancel a one-unit slope gap.  No headline result is a definitional
identity or a finite computation.  The imported finite example is used only as
a boundary witness.

SYNTHESIS.
The verified core has two layers: a general algebraic separation theorem for any
finite list of statistics, and a graph-counting consequence explaining exactly
how equal degrees constrain the two kinds of `P₃` counts.  This identifies
injective leading coefficients as a reusable target for future graph
constructions.
-/

namespace RootedPathIrregularity

/-- An affine count profile with intercept `c` and slope `m`. -/
def affineProfile (c m t : ℕ) : ℕ := c + t * m

/-- If the intercepts are bounded by `B`, a strict slope inequality determines
an affine profile inequality for every parameter strictly larger than `B`.
-/
lemma affineProfile_lt_of_slope_lt
    {c₁ c₂ m₁ m₂ t B : ℕ} (hc₁ : c₁ ≤ B) (ht : B < t) (hm : m₁ < m₂) :
    affineProfile c₁ m₁ t < affineProfile c₂ m₂ t := by
  contrapose! hm with h;
  unfold affineProfile at h; nlinarith;

/-- **Simultaneous affine separation.**  Suppose `I` indexes finitely many
rooted and ordinary path statistics.  If every statistic has vertexwise
injective slopes and all intercepts have a common bound, then every parameter
above that bound makes every count profile vertexwise injective.
-/
theorem simultaneous_affine_profile_irregular
    {I V : Type*} [Fintype I] [Fintype V]
    (intercept slope : I → V → ℕ) (B t : ℕ)
    (hbound : ∀ i v, intercept i v ≤ B)
    (hslope : ∀ i, Function.Injective (slope i))
    (ht : B < t) :
    ∀ i, Function.Injective (fun v => affineProfile (intercept i v) (slope i v) t) := by
  intro i v w h
  by_contra hvw;
  exact hvw ( hslope i ( by have := hbound i v; have := hbound i w; have := ht; have := h; unfold affineProfile at this; nlinarith ) )

/-- Equality of degrees makes the central-root contributions equal, so ordinary
`P₃` irregularity forces the end-root contributions to differ.
-/
theorem ordinary_irregular_forces_end_distinct_on_degree_collision
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : FinGraph V) (hirr : FinGraph.Irregular G.ordinaryP3Count)
    {v w : V} (hvw : v ≠ w) (hdeg : G.degree v = G.degree w) :
    G.endP3Count v ≠ G.endP3Count w := by
  exact fun h => hvw ( hirr ( by unfold FinGraph.ordinaryP3Count; simp +decide [ *, FinGraph.centerP3Count ] ) )

/-- Every ordinary-`P₃`-irregular graph with at least two vertices contains a
pair that has equal central-root count but distinct end-root count.
-/
theorem ordinary_irregular_has_compensating_pair
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : FinGraph V) (hcard : 2 ≤ Fintype.card V)
    (hirr : FinGraph.Irregular G.ordinaryP3Count) :
    ∃ v w : V, v ≠ w ∧ G.centerP3Count v = G.centerP3Count w ∧
      G.endP3Count v ≠ G.endP3Count w := by
  obtain ⟨ v, w, hvw, hdeg ⟩ := FinGraph.exists_distinct_equal_degree G hcard;
  refine' ⟨ v, w, hvw, _, _ ⟩ <;> simp_all +decide [ FinGraph.centerP3Count, FinGraph.endP3Count ];
  convert ordinary_irregular_forces_end_distinct_on_degree_collision G hirr hvw hdeg using 1

/-- Boundary witness: the catalog's six-vertex graph is ordinary irregular but
not end-root irregular. -/
example :
    FinGraph.Irregular sixVertexGraph.ordinaryP3Count ∧
      ¬ FinGraph.Irregular sixVertexGraph.endP3Count :=
  ordinary_does_not_force_end_rooted

/-- A concrete affine family: two statistics separate three vertices
simultaneously for every parameter above `5`. -/
example (t : ℕ) (ht : 5 < t) :
    ∀ i : Fin 2, Function.Injective (fun v : Fin 3 =>
      affineProfile ((i : ℕ) + (v : ℕ)) (2 * (v : ℕ) + (i : ℕ)) t) := by
  apply simultaneous_affine_profile_irregular (I := Fin 2) (V := Fin 3)
      (intercept := fun i v => (i : ℕ) + (v : ℕ))
      (slope := fun i v => 2 * (v : ℕ) + (i : ℕ)) (B := 5)
  · intro i v
    omega
  · intro i v w h
    simp only at h
    omega
  · exact ht

end RootedPathIrregularity