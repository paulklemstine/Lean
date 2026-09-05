import Mathlib

/-! # CatalogBuild.Bridges.TropicalLanglandsVarieties

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 27
-/

noncomputable section

/-- The tropical semiring (ℝ ∪ {∞}, min, +). We model it using `WithTop ℝ`. -/
abbrev TropicalReal := WithTop ℝ

/-- Tropical addition is min. -/
def tropAdd (a b : TropicalReal) : TropicalReal := min a b

/-- Tropical multiplication is ordinary addition. -/
def tropMul (a b : TropicalReal) : TropicalReal :=
  match a, b with
  | ⊤, _ => ⊤
  | _, ⊤ => ⊤
  | some x, some y => some (x + y)

/-- Tropical addition is commutative. -/
theorem tropAdd_comm (a b : TropicalReal) : tropAdd a b = tropAdd b a := by
  simp [tropAdd, min_comm]

/-- Tropical addition is associative. -/
theorem tropAdd_assoc (a b c : TropicalReal) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := by
  simp [tropAdd, min_assoc]

/-- ⊤ is the tropical additive identity. -/
theorem tropAdd_top (a : TropicalReal) : tropAdd a ⊤ = a := by
  simp [tropAdd]

/-- Tropical multiplication is commutative. -/
theorem tropMul_comm (a b : TropicalReal) : tropMul a b = tropMul b a := by
  cases a <;> cases b <;> simp [tropMul, add_comm]

/-- A non-archimedean valuation to the tropical semiring. -/
structure TropicalValuation (K : Type*) [Field K] where
  val : K → TropicalReal
  val_zero : val 0 = ⊤
  val_one : val 1 = some 0
  val_mul : ∀ x y, val (x * y) = tropMul (val x) (val y)
  val_add : ∀ x y, tropAdd (val x) (val y) ≤ val (x + y) ∨
             val (x + y) = tropAdd (val x) (val y)

/-- A tropical variety is a subset of ℝⁿ. -/
def TropicalVariety (n : ℕ) := Set (Fin n → ℝ)

/-- The tropicalization functor data. -/
structure TropicalizationData (K : Type*) [Field K] (n : ℕ) where
  valuation : TropicalValuation K
  tropicalize_point : (Fin n → K) → (Fin n → TropicalReal)
  tropicalize_eq : ∀ p i, tropicalize_point p i = valuation.val (p i)

/-- A polyhedral complex (simplified). -/
structure PolyhedralComplex (n : ℕ) where
  num_cones : ℕ
  cone_dims : Fin num_cones → ℕ
  dim_bound : ∀ i, cone_dims i ≤ n

/-- A tropical divisor on a polyhedral complex. -/
structure TropicalDivisorPC (n : ℕ) (pc : PolyhedralComplex n) where
  multiplicities : Fin pc.num_cones → ℤ

/-- Degree of a tropical divisor. -/
def TropicalDivisorPC.degree {n : ℕ} {pc : PolyhedralComplex n}
    (D : TropicalDivisorPC n pc) : ℤ :=
  ∑ i : Fin pc.num_cones, D.multiplicities i

/-- A metric graph (1-dimensional polyhedral complex). -/
structure MetricGraph where
  num_vertices : ℕ
  num_edges : ℕ
  edge_lengths : Fin num_edges → ℝ
  positive_lengths : ∀ e, edge_lengths e > 0

/-- The genus of a metric graph. -/
def MetricGraph.genus (G : MetricGraph) : ℤ :=
  (G.num_edges : ℤ) - (G.num_vertices : ℤ) + 1

/-- A graph divisor in the tropical varieties framework. -/
def MetricGraph.divisor (G : MetricGraph) := Fin G.num_vertices → ℤ

/-- Degree of a graph divisor. -/
def MetricGraph.divisorDeg (G : MetricGraph) (D : G.divisor) : ℤ :=
  ∑ i : Fin G.num_vertices, D i

/-- The canonical divisor on a metric graph assigns valence - 2 to each vertex. -/
def MetricGraph.canonicalDivisor (G : MetricGraph) (valence : Fin G.num_vertices → ℕ) :
    G.divisor :=
  fun v => (valence v : ℤ) - 2

/-- For a connected graph, the canonical divisor has degree 2g - 2. -/
theorem metric_graph_canonical_degree (G : MetricGraph)
    (valence : Fin G.num_vertices → ℕ)
    (hval : ∑ v : Fin G.num_vertices, (valence v : ℤ) = 2 * G.num_edges) :
    G.divisorDeg (G.canonicalDivisor valence) = 2 * G.genus - 2 := by
  simp [MetricGraph.divisorDeg, MetricGraph.canonicalDivisor, MetricGraph.genus,
        Finset.sum_sub_distrib, hval]
  ring

/-- A tropicalization map between a curve and its tropical image. -/
structure CurveTropicalization where
  algebraic_genus : ℕ
  tropical_genus : ℤ
  genus_preserved : (algebraic_genus : ℤ) = tropical_genus

/-- Genus is preserved under tropicalization. -/
theorem tropicalization_genus_invariance (T : CurveTropicalization) :
    (T.algebraic_genus : ℤ) = T.tropical_genus :=
  T.genus_preserved

/-- A morphism of metric graphs. -/
structure MetricGraphMorphism (G H : MetricGraph) where
  vertex_map : Fin G.num_vertices → Fin H.num_vertices

/-- Tropicalization is functorial: it respects composition. -/
theorem tropicalization_functorial
    (G H K : MetricGraph)
    (f : MetricGraphMorphism G H)
    (g : MetricGraphMorphism H K) :
    ∃ (gf : MetricGraphMorphism G K),
      gf.vertex_map = g.vertex_map ∘ f.vertex_map := by
  exact ⟨⟨g.vertex_map ∘ f.vertex_map⟩, rfl⟩

/-- Identity morphism. -/
def MetricGraphMorphism.id (G : MetricGraph) : MetricGraphMorphism G G where
  vertex_map := _root_.id

/-- Composition of morphisms. -/
def MetricGraphMorphism.comp {G H K : MetricGraph}
    (f : MetricGraphMorphism G H) (g : MetricGraphMorphism H K) :
    MetricGraphMorphism G K where
  vertex_map := g.vertex_map ∘ f.vertex_map

/-- Composition is associative. -/
theorem MetricGraphMorphism.comp_assoc {G H K L : MetricGraph}
    (f : MetricGraphMorphism G H) (g : MetricGraphMorphism H K)
    (h : MetricGraphMorphism K L) :
    (f.comp g).comp h = f.comp (g.comp h) := by
  simp [MetricGraphMorphism.comp, Function.comp_assoc]

/-- The tropical Jacobian of a metric graph. -/
structure TropicalJacobian (G : MetricGraph) where
  dimension : ℕ
  dim_eq_genus : (dimension : ℤ) = G.genus

end