import Cryptography.GravityQECC.SingletonGeometry
import Mathlib.Combinatorics.SimpleGraph.Metric

/-!
# Code Distance and Finite Geodesic Models

This study separates three claims that are sometimes conflated in code-based models
of geometry.  A code distance may be represented by a graph geodesic; the quantum
Singleton inequality then becomes a geometric inequality after an explicit metric
dictionary is supplied.  Neither fact identifies a Tanner graph with a spacetime,
and neither turns the inequality into an entropy equality without a saturation
hypothesis.

A finite radial model for the `[[5,1,3]]` parameters is constructed from the path on
four vertices.  Its two endpoints are at distance three, exactly matching the code
distance.  This is an existence result for a metric realization, not an identification
of the code's Tanner graph with a Penrose diagram.  Indeed, the standard bipartite
Tanner presentation has five variable vertices and four check vertices, so it cannot
even be isomorphic to this four-vertex radial path.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Seven falsifiable claims were ranked by potential impact.
(H1) Every Singleton-valid code admits a graph-geodesic dictionary under which the
Singleton bound becomes a geometric capacity bound.  (H2) Singleton saturation is
exactly the condition that turns that bound into an area-like equality.  (H3) The
`[[5,1,3]]` distance is realized by a minimal radial chain of length three.  (H4) The
five-qubit Tanner graph is literally that radial chain.  (H5) bounded excess of
boundary size over twice the geodesic length forces bounded logical capacity.
(H6) positive asymptotic logical rate forces extensive geometric excess.  (H7) code
incidence data alone canonically determines a Lorentzian bulk geometry.  H2, H6, and
H7 are the boldest structural claims.

Experiment (Experimenter): H1 and H2 were reduced to a metric-realization structure
that records the otherwise hidden dictionary.  H3 was tested by constructing an
explicit three-edge walk and proving, by induction over arbitrary walks, that no
shorter endpoint walk exists.  H4 was tested by vertex cardinality.  H5 was connected
to the existing defect-capacity law.

Analysis (Analyst): H1 survives conditionally: the geometric inequality follows once
`graph distance = code distance` is supplied.  H2 survives precisely with Singleton
saturation.  H3 survives.  H4 fails for the finite radial interpretation because the
Tanner presentation has nine vertices while the chain has four.  H6 survives as a
parameter obstruction through the bounded-defect results.  H7 needs a different
definition: incidence and distance do not specify causal order, metric signature, or
continuum limits.

Critique (Critic): The path construction is not claimed to be a Penrose diagram.
The distance-three computation uses both an explicit upper-bound walk and a lower
bound for every walk, rather than finite enumeration.  The geometric conclusions
retain the realization and saturation assumptions visibly.  The classical bound
`d ≤ n-k+1` is not substituted for the quantum stabilizer bound
`2d+k ≤ n+2`.

Synthesis (Principal Investigator): The verified bridge is an implication, not an
unqualified equivalence: a metric dictionary transports quantum Singleton to a
geodesic capacity inequality, and saturation upgrades it to equality.  The five-qubit
parameters have a length-three radial realization, while a cardinality obstruction
rules out literal identification of its Tanner graph with that chain.
-- !--
-/

namespace GravityQECC

open QuantumStabilizer SimpleGraph

/-- A graph realizes code distance when two distinguished bulk-boundary locations
are separated by exactly the code's minimum distance. -/
structure MetricRealization {V : Type*} (p : CodeParams) (G : SimpleGraph V)
    (source target : V) : Prop where
  distance_eq : G.dist source target = p.d

/-- Transport of the quantum Singleton bound through an explicit metric dictionary. -/
theorem geometric_singleton_bound {V : Type*} (p : CodeParams) (G : SimpleGraph V)
    (source target : V) (hcode : SingletonValidCode p)
    (hmetric : MetricRealization p G source target) :
    2 * G.dist source target + p.k ≤ p.n + 2 := by
  rw [hmetric.distance_eq]
  exact hcode.singleton

/-- Singleton saturation is transported to an exact geodesic-capacity identity. -/
theorem saturated_geodesic_capacity {V : Type*} (p : CodeParams)
    (G : SimpleGraph V) (source target : V)
    (hmetric : MetricRealization p G source target)
    (hsat : 2 * p.d + p.k = p.n + 2) :
    2 * G.dist source target + p.k = p.n + 2 := by
  rw [hmetric.distance_eq]
  exact hsat

/-- Conversely, an exact geodesic identity implies Singleton saturation when the
metric dictionary is exact.  Thus equality, unlike the bound alone, is equivalent
to saturation relative to a fixed realization. -/
theorem geodesic_identity_iff_saturation {V : Type*} (p : CodeParams)
    (G : SimpleGraph V) (source target : V)
    (hmetric : MetricRealization p G source target) :
    2 * G.dist source target + p.k = p.n + 2 ↔
      2 * p.d + p.k = p.n + 2 := by
  rw [hmetric.distance_eq]

/-- Along every walk in a finite path graph, the terminal index is at most the
initial index plus the walk length. -/
lemma pathGraph_terminal_le_start_add_length {n : ℕ} {u v : Fin n}
    (w : (SimpleGraph.pathGraph n).Walk u v) :
    v.val ≤ u.val + w.length := by
  induction w with
  | nil => simp
  | @cons a b c hab w ih =>
      rw [SimpleGraph.pathGraph_adj] at hab
      rw [SimpleGraph.Walk.length_cons]
      rcases hab with hab | hab
      · omega
      · omega

/-- The endpoint geodesic of the four-vertex radial chain has length three. -/
theorem radial_chain_endpoint_distance :
    (SimpleGraph.pathGraph 4).dist (0 : Fin 4) (3 : Fin 4) = 3 := by
  let v0 : Fin 4 := ⟨0, by omega⟩
  let v1 : Fin 4 := ⟨1, by omega⟩
  let v2 : Fin 4 := ⟨2, by omega⟩
  let v3 : Fin 4 := ⟨3, by omega⟩
  have h01 : (SimpleGraph.pathGraph 4).Adj v0 v1 := by
    rw [SimpleGraph.pathGraph_adj]
    exact Or.inl rfl
  have h12 : (SimpleGraph.pathGraph 4).Adj v1 v2 := by
    rw [SimpleGraph.pathGraph_adj]
    exact Or.inl rfl
  have h23 : (SimpleGraph.pathGraph 4).Adj v2 v3 := by
    rw [SimpleGraph.pathGraph_adj]
    exact Or.inl rfl
  let w : (SimpleGraph.pathGraph 4).Walk v0 v3 :=
    .cons h01 (.cons h12 (.cons h23 .nil))
  have hw : w.length = 3 := by simp [w]
  apply Nat.le_antisymm
  · simpa [v0, v3, hw] using (SimpleGraph.dist_le w)
  · have hreach : (SimpleGraph.pathGraph 4).Reachable (0 : Fin 4) (3 : Fin 4) :=
      (SimpleGraph.pathGraph_preconnected 4) _ _
    obtain ⟨shortest, hshortest⟩ := hreach.exists_walk_length_eq_dist
    have hdisp := pathGraph_terminal_le_start_add_length shortest
    simpa [hshortest] using hdisp

/-- The five-qubit parameters are realized by the endpoint metric of the radial chain. -/
theorem five_qubit_radial_metric_realization :
    MetricRealization (⟨5, 1, 3⟩ : CodeParams) (SimpleGraph.pathGraph 4)
      (0 : Fin 4) (3 : Fin 4) := by
  constructor
  exact radial_chain_endpoint_distance

/-- For the five-qubit realization, geodesic length, code distance, and the saturated
quantum Singleton budget agree in one nontrivial finite model. -/
theorem five_qubit_geodesic_singleton_saturation :
    (SimpleGraph.pathGraph 4).dist (0 : Fin 4) (3 : Fin 4) = 3 ∧
    2 * (SimpleGraph.pathGraph 4).dist (0 : Fin 4) (3 : Fin 4) + 1 = 5 + 2 := by
  constructor
  · exact radial_chain_endpoint_distance
  · have hmetric := five_qubit_radial_metric_realization
    exact saturated_geodesic_capacity (⟨5, 1, 3⟩ : CodeParams)
      (SimpleGraph.pathGraph 4) (0 : Fin 4) (3 : Fin 4) hmetric
      QuantumStabilizer.five_qubit_mds

/-- Vertices in the standard five-qubit Tanner presentation: five variable nodes
and four stabilizer-check nodes. -/
abbrev FiveQubitTannerVertex := Fin 5 ⊕ Fin 4

/-- A literal identification of the nine Tanner vertices with the four radial-chain
vertices is impossible, independently of the chosen incidence relation. -/
theorem no_five_qubit_tanner_equiv_radial_chain :
    ¬ Nonempty (FiveQubitTannerVertex ≃ Fin 4) := by
  intro h
  obtain ⟨e⟩ := h
  have hcard := Fintype.card_congr e
  simp at hcard

/-- Any proposed graph isomorphism from a five-qubit Tanner graph to the radial chain
would induce an impossible vertex equivalence. -/
theorem no_five_qubit_tanner_graph_iso_radial_chain
    (T : SimpleGraph FiveQubitTannerVertex) :
    ¬ Nonempty (T ≃g SimpleGraph.pathGraph 4) := by
  intro h
  obtain ⟨e⟩ := h
  exact no_five_qubit_tanner_equiv_radial_chain ⟨e.toEquiv⟩

/-- A bounded geometric defect still bounds logical capacity after replacing code
distance by its realized graph geodesic. -/
theorem geodesic_defect_bounds_capacity {V : Type*} (p : CodeParams)
    (G : SimpleGraph V) (source target : V) (hcode : SingletonValidCode p)
    (hmetric : MetricRealization p G source target) (delta : ℕ)
    (hgeom : p.n = 2 * G.dist source target + delta) :
    p.k ≤ delta + 2 := by
  apply logical_capacity_le_defect p hcode delta
  unfold HasGeometricDefect
  rw [← hmetric.distance_eq]
  exact hgeom

end GravityQECC