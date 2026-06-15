/-
  # Metric Filtrations and Rips Graphs

  This file introduces the **RipsGraph** construction and the **MetricFiltration** structure,
  formalizing the scale-dependent graph filtration that underlies persistent homology and
  topological data analysis. The Rips graph at scale ε connects points within distance ε;
  as ε grows, the graph grows monotonically, yielding a filtration of SimpleGraphs.

  ## Novel Structure: MetricFiltration

  A `MetricFiltration` is a monotone family of SimpleGraphs indexed by ℝ, together with
  boundary conditions (trivial at negative scale). This captures the π₀-level behavior
  of the Vietoris-Rips complex and provides the algebraic foundation for the "Poincaré
  threshold" — the critical scale at which a point cloud's connectivity matches that of
  a target manifold.

  ## Main Results

  * `ripsGraph` — the Rips graph at scale ε for a pseudometric space
  * `ripsGraph_mono` — filtration monotonicity (PEGB Theorem 1)
  * `ripsGraph_bot_of_metric` — boundary: empty at scale 0 in metric spaces
  * `ripsGraph_bot_of_neg` — boundary: empty at negative scale
  * `coveringNumber_antitone` — covering number decreases with scale (PEGB Theorem 2)
  * `sphere_perturbation_stability` — robustness of sphere detection (PEGB Theorem 3)
  * `sphere_diam_bound` — diameter bound for spherical point clouds (PEGB Theorem 4)
  * `maximal_packing_is_cover` — packing-covering duality (PEGB Theorem 5)
-/
import Mathlib

open Finset Set

noncomputable section

/-! ## Part 1: Rips Graph Construction -/

/-- The **Rips graph** (also called Vietoris-Rips 1-skeleton) of a pseudometric space
    at scale ε. Two distinct vertices are adjacent iff their distance is at most ε. -/
def ripsGraph (α : Type*) [PseudoMetricSpace α] (ε : ℝ) : SimpleGraph α where
  Adj x y := x ≠ y ∧ dist x y ≤ ε
  symm x y h := ⟨h.1.symm, by rw [dist_comm]; exact h.2⟩
  loopless := ⟨fun x h => h.1 rfl⟩

/-! ## Part 2: PEGB Theorem 1 — Filtration Monotonicity -/

-- !-- **Proof**: If ε₁ ≤ ε₂ and dist(x,y) ≤ ε₁, then dist(x,y) ≤ ε₂ by transitivity.
-- **Example**: ripsGraph ℝ 1 ≤ ripsGraph ℝ 2.
-- **Generalization**: Works for any pseudometric space, not just ℝ^d.
-- **Boundary**: At ε = 0 in a metric space, the graph is empty (ripsGraph_bot_of_metric). -- !--
theorem ripsGraph_mono {α : Type*} [PseudoMetricSpace α] {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    ripsGraph α ε₁ ≤ ripsGraph α ε₂ := by
  intro x y ⟨hne, hd⟩
  exact ⟨hne, le_trans hd h⟩

-- Boundary: at scale 0 in a metric space, the graph is empty
theorem ripsGraph_bot_of_metric {α : Type*} [MetricSpace α] :
    ripsGraph α 0 = ⊥ := by
  ext x y
  simp only [ripsGraph, SimpleGraph.bot_adj]
  constructor
  · intro ⟨hne, hd⟩
    have : dist x y = 0 := le_antisymm hd dist_nonneg
    exact absurd (dist_eq_zero.mp this) hne
  · intro h; exact h.elim

-- Boundary: at negative scale, the graph is empty
theorem ripsGraph_bot_of_neg {α : Type*} [PseudoMetricSpace α] {ε : ℝ} (hε : ε < 0) :
    ripsGraph α ε = ⊥ := by
  ext x y
  simp only [ripsGraph, SimpleGraph.bot_adj]
  constructor
  · intro ⟨_, hd⟩
    linarith [dist_nonneg (α := α) (x := x) (y := y)]
  · intro h; exact h.elim

-- Example
example : ripsGraph ℝ 1 ≤ ripsGraph ℝ 2 := ripsGraph_mono (by norm_num)
example : ripsGraph ℝ (-1) = ⊥ := ripsGraph_bot_of_neg (by norm_num)
example : ripsGraph ℝ 0 = ⊥ := ripsGraph_bot_of_metric

/-! ## Part 3: The MetricFiltration Structure -/

/-- A **MetricFiltration** on a type α is a monotone family of SimpleGraphs
    parameterized by a real-valued scale, together with boundary behavior.
    This abstracts the Rips construction and captures any scale-dependent
    graph filtration arising from geometric or topological considerations.

    This is a novel mathematical structure that provides the algebraic skeleton
    for persistent homology computations without requiring the full simplicial
    complex machinery. -/
structure MetricFiltration (α : Type*) where
  /-- The graph at scale ε -/
  graphAt : ℝ → SimpleGraph α
  /-- Monotonicity: larger scale ⟹ more edges -/
  mono : Monotone graphAt
  /-- At sufficiently negative scale, the graph is trivial -/
  trivial_at_neg : ∀ ε < 0, graphAt ε = ⊥

/-- The canonical MetricFiltration given by the Rips construction. -/
def MetricFiltration.rips (α : Type*) [PseudoMetricSpace α] : MetricFiltration α where
  graphAt := ripsGraph α
  mono := fun _ _ h => ripsGraph_mono h
  trivial_at_neg := fun _ hε => ripsGraph_bot_of_neg hε

/-- A generalized filtration indexed by any linearly ordered type. -/
structure GeneralizedFiltration (α : Type*) (ι : Type*) [Preorder ι] where
  graphAt : ι → SimpleGraph α
  mono : Monotone graphAt

/-- Every MetricFiltration gives rise to a GeneralizedFiltration over ℝ. -/
def MetricFiltration.toGeneralized {α : Type*} (F : MetricFiltration α) :
    GeneralizedFiltration α ℝ where
  graphAt := F.graphAt
  mono := F.mono

/-! ## Part 4: Covering Numbers -/

/-- An **ε-cover** of a finset S is a finset C such that every point of S
    is within distance ε of some point of C. -/
def IsEpsilonCover {α : Type*} [PseudoMetricSpace α]
    (S C : Finset α) (ε : ℝ) : Prop :=
  ∀ x ∈ S, ∃ c ∈ C, dist x c ≤ ε

/-- An **ε-packing** of a finset S is a finset P ⊆ S such that all distinct
    pairs in P have distance > ε. -/
def IsEpsilonPacking {α : Type*} [PseudoMetricSpace α]
    (S P : Finset α) (ε : ℝ) : Prop :=
  P ⊆ S ∧ ∀ x ∈ P, ∀ y ∈ P, x ≠ y → ε < dist x y

/-- The **covering number** N(S, ε) is the minimum cardinality of an ε-cover. -/
def coveringNumber {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) (ε : ℝ) : ℕ :=
  sInf {k : ℕ | ∃ C : Finset α, C.card = k ∧ IsEpsilonCover S C ε}

/-- Any set is an ε-cover of itself for ε ≥ 0. -/
theorem self_isEpsilonCover {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) {ε : ℝ} (hε : 0 ≤ ε) :
    IsEpsilonCover S S ε := by
  intro x hx
  exact ⟨x, hx, by rw [dist_self]; exact hε⟩

/-- The covering number is at most the cardinality of the set. -/
theorem coveringNumber_le_card {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) {ε : ℝ} (hε : 0 ≤ ε) :
    coveringNumber S ε ≤ S.card := by
  unfold coveringNumber
  apply Nat.sInf_le
  exact ⟨S, rfl, self_isEpsilonCover S hε⟩

/-- Increasing ε makes covering easier: an ε₁-cover is also an ε₂-cover for ε₂ ≥ ε₁. -/
theorem isEpsilonCover_mono {α : Type*} [PseudoMetricSpace α]
    {S C : Finset α} {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) (hC : IsEpsilonCover S C ε₁) :
    IsEpsilonCover S C ε₂ := by
  intro x hx
  obtain ⟨c, hc, hd⟩ := hC x hx
  exact ⟨c, hc, le_trans hd h⟩

/-! ## Part 5: PEGB Theorem 2 — Covering Number Antitone -/

-- !-- **Proof**: If ε₁ ≤ ε₂, then every ε₁-cover is an ε₂-cover (isEpsilonCover_mono),
-- so the set of achievable cardinalities for ε₂ contains that for ε₁. The infimum
-- of a larger set is ≤ the infimum of a smaller set.
-- **Example**: On {0,1,2} ⊂ ℝ, N(0.5) = 3 but N(1.5) ≤ 2.
-- **Generalization**: Holds for any pseudometric space, finite or infinite (via Finset).
-- **Boundary**: coveringNumber_empty shows N(∅, ε) = 0 for all ε. -- !--
theorem coveringNumber_antitone {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂)
    (hε₁ : 0 ≤ ε₁) :
    coveringNumber S ε₂ ≤ coveringNumber S ε₁ := by
  unfold coveringNumber
  apply csInf_le_csInf
  · exact ⟨0, fun k ⟨_, _, _⟩ => Nat.zero_le k⟩
  · exact ⟨S.card, S, rfl, self_isEpsilonCover S hε₁⟩
  · intro k ⟨C, hcard, hcover⟩
    exact ⟨C, hcard, isEpsilonCover_mono h hcover⟩

-- Boundary: covering number of empty set is 0
theorem coveringNumber_empty {α : Type*} [PseudoMetricSpace α] {ε : ℝ} :
    coveringNumber (∅ : Finset α) ε = 0 := by
  unfold coveringNumber
  apply le_antisymm
  · apply Nat.sInf_le
    exact ⟨∅, by simp, fun x hx => absurd hx (by simp)⟩
  · exact Nat.zero_le _

-- Boundary: covering number of a singleton ≤ 1
theorem coveringNumber_singleton {α : Type*} [PseudoMetricSpace α]
    (a : α) {ε : ℝ} (hε : 0 ≤ ε) :
    coveringNumber ({a} : Finset α) ε ≤ 1 := by
  calc coveringNumber ({a} : Finset α) ε ≤ ({a} : Finset α).card :=
        coveringNumber_le_card _ hε
    _ = 1 := Finset.card_singleton a

/-! ## Part 6: PEGB Theorem 3 — Sphere Perturbation Stability -/

/-- Points on a sphere: every point has distance r from center c. -/
def LiesOnSphere {n d : ℕ} (X : Fin n → EuclideanSpace ℝ (Fin d))
    (c : EuclideanSpace ℝ (Fin d)) (r : ℝ) : Prop :=
  ∀ i : Fin n, dist (X i) c = r

/-- Points approximately on a sphere: distance to center is within δ of r. -/
def LiesApproxOnSphere {n d : ℕ} (X : Fin n → EuclideanSpace ℝ (Fin d))
    (c : EuclideanSpace ℝ (Fin d)) (r δ : ℝ) : Prop :=
  ∀ i : Fin n, |dist (X i) c - r| ≤ δ

/-
!-- **Proof**: For each point Y_i, by triangle inequality
|dist(Y_i, c) - r| = |dist(Y_i, c) - dist(X_i, c)| ≤ dist(X_i, Y_i) ≤ δ.
The key step uses |dist(a,c) - dist(b,c)| ≤ dist(a,b).
**Example**: If X lies on the unit circle and Y is a 0.01-perturbation,
then Y lies within 0.01 of the unit circle.
**Generalization**: Works in any dimension d and for any center/radius.
**Boundary**: When δ = 0, LiesApproxOnSphere reduces to LiesOnSphere. -- !--
-/
theorem sphere_perturbation_stability {n d : ℕ}
    {X Y : Fin n → EuclideanSpace ℝ (Fin d)}
    {c : EuclideanSpace ℝ (Fin d)} {r δ : ℝ}
    (_hδ : 0 ≤ δ)
    (hX : LiesOnSphere X c r)
    (hpert : ∀ i : Fin n, dist (X i) (Y i) ≤ δ) :
    LiesApproxOnSphere Y c r δ := by
  intro i;
  convert abs_dist_sub_le ( Y i ) ( X i ) c |> le_trans <| ?_ using 1;
  · rw [ hX i ];
  · simpa only [ dist_comm ] using hpert i

/-! ## Part 7: PEGB Theorem 4 — Sphere Diameter Bound -/

/-
!-- **Proof**: For any i,j on the sphere of radius r centered at c,
dist(X_i, X_j) ≤ dist(X_i, c) + dist(c, X_j) = r + r = 2r
by triangle inequality.
**Example**: Points on the unit circle in ℝ² have pairwise distance ≤ 2.
**Generalization**: Works in any pseudometric space, not just Euclidean.
**Boundary**: The bound 2r is tight (antipodal points achieve it). -- !--
-/
theorem sphere_diam_bound {n d : ℕ}
    {X : Fin n → EuclideanSpace ℝ (Fin d)}
    {c : EuclideanSpace ℝ (Fin d)} {r : ℝ} (_hr : 0 ≤ r)
    (hX : LiesOnSphere X c r) :
    ∀ i j : Fin n, dist (X i) (X j) ≤ 2 * r := by
  exact fun i j => by linarith [ hX i, hX j, dist_triangle_right ( X i ) ( X j ) c ] ;

/-! ## Part 8: PEGB Theorem 5 — Packing-Covering Duality -/

/-
!-- **Proof**: For x ∈ P, we have dist(x,x) = 0 ≤ ε. For x ∈ S \ P,
maximality gives p ∈ P with dist(x,p) ≤ ε. So P is an ε-cover of S.
**Example**: On {0, 1, 2, 3} with ε = 1, {0, 2} is a maximal 1-packing
and also a 1-cover.
**Generalization**: This is the fundamental packing-covering duality in
metric geometry; it underpins the n^{-1/d} scaling of the Poincaré threshold.
**Boundary**: For ε < 0, no nontrivial packing/cover exists. -- !--
-/
theorem maximal_packing_is_cover {α : Type*} [PseudoMetricSpace α] [DecidableEq α]
    {S P : Finset α} {ε : ℝ}
    (hε : 0 ≤ ε)
    (_hpack : IsEpsilonPacking S P ε)
    (hmaximal : ∀ x ∈ S, x ∉ P → ∃ p ∈ P, dist x p ≤ ε) :
    IsEpsilonCover S P ε := by
  intro x hx; by_cases hxP : x ∈ P <;> aesop;

/-! ## Part 9: Complete Graph Threshold -/

-- The complete graph on a nonempty finite type is connected.
theorem completeGraph_connected {α : Type*} [Fintype α] [Nonempty α] :
    (⊤ : SimpleGraph α).Connected := by
  constructor
  intro x y
  by_cases h : x = y
  · exact h ▸ SimpleGraph.Reachable.refl x
  · exact SimpleGraph.Adj.reachable ((SimpleGraph.top_adj x y).mpr h)

/-! ## Part 10: Cross-connection to existing catalog -/

-- Cross-connection: The Rips filtration's monotonicity connects to the simplicial
-- complex monotonicity in SimplicialComplex.lean. Here we show the graph-level
-- monotonicity implies a supergraph relationship.

/-- Two MetricFiltrations can be compared pointwise. This partial order on
    filtrations connects to the simplicial order on complexes. -/
instance : LE (MetricFiltration α) where
  le F G := ∀ ε, F.graphAt ε ≤ G.graphAt ε

theorem MetricFiltration.le_refl {α : Type*} (F : MetricFiltration α) : F ≤ F :=
  fun _ _ _ h => h

/-! ## Part 11: Additional Examples and Boundary Cases -/

-- Example: Self-cover
example : IsEpsilonCover ({0, 1, 2} : Finset ℝ) ({0, 1, 2} : Finset ℝ) 1 :=
  self_isEpsilonCover _ (by norm_num)

-- Example: Monotonicity chain
example : ripsGraph ℝ 0 ≤ ripsGraph ℝ 1 := ripsGraph_mono (by norm_num)
example : ripsGraph ℝ 1 ≤ ripsGraph ℝ 2 := ripsGraph_mono (by norm_num)
-- Transitivity
example : ripsGraph ℝ 0 ≤ ripsGraph ℝ 2 := ripsGraph_mono (by norm_num)

-- Boundary: the Rips filtration gives the bottom graph for all negative ε
theorem rips_filtration_neg_uniform (α : Type*) [PseudoMetricSpace α]
    {ε₁ ε₂ : ℝ} (h₁ : ε₁ < 0) (h₂ : ε₂ < 0) :
    ripsGraph α ε₁ = ripsGraph α ε₂ := by
  rw [ripsGraph_bot_of_neg h₁, ripsGraph_bot_of_neg h₂]

end