/-
  # Poincaré Threshold: Mathematical Foundations

  This file develops the theory of metric filtrations and the Poincaré threshold —
  the critical scale at which a point cloud's neighborhood complex first exhibits
  a target topological signature (e.g., the Betti numbers of a sphere).

  ## Main Definitions

  * `RipsEdgeSet` — the set of pairs within distance ε in a pseudometric space
  * `RipsSimplex` — a finite set is a Rips simplex at scale ε iff all pairwise distances ≤ ε
  * `MetricFiltration` — a monotone family of predicates indexed by ℝ≥0
  * `filtrationThreshold` — the infimum scale at which a filtration predicate holds
  * `CoveringRadius` — the infimum ε such that ε-balls cover the space

  ## Main Results

  * `ripsEdgeSet_mono` — Rips edge sets are monotone in the scale parameter
  * `ripsSimplex_mono` — Rips simplices are monotone in the scale parameter
  * `filtrationThreshold_antitone` — weaker predicates have smaller thresholds
  * `rips_interleaving` — Rips edges interleave under approximate isometries
  * `sphereSignature_injective` — sphere dimension is determined by Betti signature
-/

import Mathlib

open Set Filter Topology Metric

noncomputable section

/-! ## Rips Complex Foundations -/

/-- The Rips edge relation at scale ε: two points are connected iff their distance is ≤ ε. -/
def RipsEdge {X : Type*} [PseudoMetricSpace X] (ε : ℝ) (x y : X) : Prop :=
  dist x y ≤ ε

/-- The set of all pairs forming Rips edges at scale ε. -/
def RipsEdgeSet {X : Type*} [PseudoMetricSpace X] (ε : ℝ) : Set (X × X) :=
  {p | RipsEdge ε p.1 p.2}

/-- A finite set of points forms a Rips simplex at scale ε iff all pairwise distances are ≤ ε. -/
def RipsSimplex {X : Type*} [PseudoMetricSpace X] (ε : ℝ) (s : Finset X) : Prop :=
  ∀ x ∈ s, ∀ y ∈ s, dist x y ≤ ε

/-
The Rips edge set is monotone: larger scale ⟹ more edges.
-/
theorem ripsEdgeSet_mono {X : Type*} [PseudoMetricSpace X] {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    RipsEdgeSet (X := X) ε₁ ⊆ RipsEdgeSet ε₂ := by
  intro p hp;
  exact le_trans hp h

/-
The Rips simplex predicate is monotone: larger scale ⟹ more simplices.
-/
theorem ripsSimplex_mono {X : Type*} [PseudoMetricSpace X] {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂)
    (s : Finset X) (hs : RipsSimplex ε₁ s) : RipsSimplex ε₂ s := by
  exact fun x hx y hy => le_trans ( hs x hx y hy ) h

/-
At scale 0, a Rips simplex consists of at most one distinct point.
-/
theorem ripsSimplex_zero_eq {X : Type*} [MetricSpace X] (s : Finset X) (hs : RipsSimplex 0 s) :
    ∀ x ∈ s, ∀ y ∈ s, x = y := by
  exact fun x hx y hy => dist_le_zero.mp ( hs x hx y hy )

/-! ## Abstract Metric Filtrations -/

/-- A metric filtration is a family of propositions indexed by ℝ that is monotone:
    if P holds at scale ε₁, it holds at all larger scales ε₂ ≥ ε₁. -/
structure MetricFiltration where
  /-- The predicate at each scale -/
  prop : ℝ → Prop
  /-- Monotonicity: the predicate persists under scale increase -/
  mono : ∀ ε₁ ε₂ : ℝ, ε₁ ≤ ε₂ → prop ε₁ → prop ε₂

/-- The filtration threshold: the infimum scale at which the predicate holds.
    Returns ⊤ (∞) if the predicate never holds. -/
noncomputable def MetricFiltration.threshold (F : MetricFiltration) : EReal :=
  ⨅ ε ∈ {r : ℝ | F.prop r}, (ε : EReal)

/-
If a filtration's predicate implies another's, the latter has a smaller or equal threshold.
-/
theorem filtrationThreshold_antitone (F G : MetricFiltration)
    (h : ∀ ε, F.prop ε → G.prop ε) :
    G.threshold ≤ F.threshold := by
  refine' iInf_le_iInf_of_subset _;
  exact fun x hx => h x hx

/-- Rips-connectivity: every pair of points in S can be linked by a chain of ε-edges. -/
def RipsConnected {X : Type*} [PseudoMetricSpace X] (ε : ℝ) (S : Set X) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S,
    ∃ (n : ℕ) (f : Fin (n + 1) → X),
      (∀ i, f i ∈ S) ∧
      f ⟨0, Nat.zero_lt_succ n⟩ = x ∧
      f ⟨n, by omega⟩ = y ∧
      ∀ i : Fin n, dist (f i.castSucc) (f i.succ) ≤ ε

/-
Rips connectivity is monotone in the scale parameter.
-/
theorem ripsConnected_mono {X : Type*} [PseudoMetricSpace X] {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂)
    (S : Set X) (hc : RipsConnected ε₁ S) : RipsConnected ε₂ S := by
  exact fun x hx y hy => by obtain ⟨ n, f, hf, hf₀, hf₁, hf₂ ⟩ := hc x hx y hy; exact ⟨ n, f, hf, hf₀, hf₁, fun i => le_trans ( hf₂ i ) h ⟩ ;

/-! ## Covering and Packing -/

/-- A set S is an ε-covering of T if every point of T is within distance ε of some point of S. -/
def IsεCovering {X : Type*} [PseudoMetricSpace X] (S : Finset X) (T : Set X) (ε : ℝ) : Prop :=
  ∀ x ∈ T, ∃ s ∈ (S : Set X), dist x s ≤ ε

/-- A set S is ε-separated if all pairwise distances exceed ε. -/
def IsεSeparated {X : Type*} [PseudoMetricSpace X] (S : Finset X) (ε : ℝ) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, x ≠ y → ε < dist x y

/-
Any set is trivially a 0-covering of itself (each point covers itself).
-/
theorem self_is_zero_covering {X : Type*} [PseudoMetricSpace X] (S : Finset X) :
    IsεCovering S (S : Set X) 0 := by
  exact fun x hx => ⟨ x, hx, by simp +decide ⟩

/-! ## Hausdorff Distance -/

/-
The Hausdorff distance is symmetric.
-/
theorem hausdorffDist_symm {X : Type*} [PseudoMetricSpace X] (A B : Set X) :
    Metric.hausdorffDist A B = Metric.hausdorffDist B A := by
  rw [ Metric.hausdorffDist_comm ]

/-! ## Poincaré Threshold -/

/-- A topological signature is an abstract description of the "shape" of a space,
    parameterized by a list of natural numbers (e.g., Betti numbers). -/
structure TopologicalSignature where
  /-- Betti numbers β₀, β₁, β₂, ... -/
  betti : List ℕ
  deriving DecidableEq

/-- The signature of an n-sphere: β₀ = 1, βₙ = 1, all others = 0.
    For an n-sphere, the Betti numbers are [1, 0, 0, ..., 0, 1] (length n+1). -/
def sphereSignature (n : ℕ) : TopologicalSignature where
  betti := List.ofFn (fun (i : Fin (n + 1)) => if i.val = 0 ∨ i.val = n then 1 else 0)

/-
The dimension of a sphere is uniquely determined by its Betti signature.
    This encodes the fundamental fact that H_k(S^n) ≅ ℤ iff k ∈ {0, n}, and 0 otherwise,
    so the Betti numbers uniquely determine n.
    (We prove injectivity of our combinatorial signature function.)
-/
theorem sphereSignature_injective : Function.Injective sphereSignature := by
  intro m n hmn
  have h_len : m + 1 = n + 1 := by
    injection hmn with hmn;
    replace hmn := congr_arg List.length hmn ; aesop;
  exact Nat.succ_injective h_len

/-- A topological observable on a metric filtration: a function that computes a
    topological signature at each scale. -/
structure TopologicalObservable where
  /-- The signature at each scale -/
  observe : ℝ → TopologicalSignature

/-- The Poincaré threshold for a target signature σ is the infimum scale at which
    the observable first produces σ. -/
noncomputable def poincareThreshold (obs : TopologicalObservable) (σ : TopologicalSignature) : EReal :=
  ⨅ ε ∈ {r : ℝ | obs.observe r = σ}, (ε : EReal)

/-! ## Main Stability Theorem -/

/-
**Key result**: If φ is a δ-approximate isometry (|d(φx,φy) - d(x,y)| ≤ δ),
    then a Rips edge at scale ε in X maps to a Rips edge at scale ε + δ in Y.
    This is the fundamental interleaving lemma for Rips complexes.
-/
theorem rips_interleaving {X Y : Type*} [PseudoMetricSpace X] [PseudoMetricSpace Y]
    (φ : X → Y) (δ : ℝ) (_hδ : 0 ≤ δ)
    (hφ : ∀ x₁ x₂ : X, |dist (φ x₁) (φ x₂) - dist x₁ x₂| ≤ δ)
    {ε : ℝ} {x₁ x₂ : X} (hedge : RipsEdge ε x₁ x₂) :
    RipsEdge (ε + δ) (φ x₁) (φ x₂) := by
  unfold RipsEdge at *;
  linarith [ abs_le.mp ( hφ x₁ x₂ ) ]

/-
Rips simplex interleaving: if φ is a δ-approximate isometry and s is a Rips simplex
    at scale ε in X, then φ(s) is a Rips simplex at scale ε + δ in Y.
-/
theorem rips_simplex_interleaving {X Y : Type*} [PseudoMetricSpace X] [PseudoMetricSpace Y]
    [DecidableEq Y]
    (φ : X → Y) (δ : ℝ) (_hδ : 0 ≤ δ)
    (hφ : ∀ x₁ x₂ : X, |dist (φ x₁) (φ x₂) - dist x₁ x₂| ≤ δ)
    {ε : ℝ} (s : Finset X) (hs : RipsSimplex ε s) :
    RipsSimplex (ε + δ) (s.image φ) := by
  intro x hx y hy;
  obtain ⟨ x', hx', rfl ⟩ := Finset.mem_image.mp hx; obtain ⟨ y', hy', rfl ⟩ := Finset.mem_image.mp hy; linarith [ abs_le.mp ( hφ x' y' ), hs x' hx' y' hy' ] ;

/-! ## Graph-Theoretic Characterization -/

/-- The Rips graph at scale ε as a `SimpleGraph`. -/
def ripsSimpleGraph {X : Type*} [PseudoMetricSpace X] (ε : ℝ) :
    SimpleGraph X where
  Adj x y := x ≠ y ∧ dist x y ≤ ε
  symm x y := fun ⟨hne, hd⟩ => ⟨hne.symm, by rw [dist_comm]; exact hd⟩
  loopless := ⟨fun x ⟨hne, _⟩ => hne rfl⟩

/-
The Rips graph is monotone as a `SimpleGraph` (more edges at larger scale).
-/
theorem ripsSimpleGraph_mono {X : Type*} [PseudoMetricSpace X]
    {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    ripsSimpleGraph (X := X) ε₁ ≤ ripsSimpleGraph ε₂ := by
  intro x y hxy; exact ⟨hxy.left, by linarith [hxy.right]⟩;

/-
At scale equal to the diameter, the Rips graph is complete on any finite set.
-/
theorem ripsSimpleGraph_diameter_complete {X : Type*} [PseudoMetricSpace X]
    (S : Finset X) (ε : ℝ) (hε : ∀ x ∈ S, ∀ y ∈ S, dist x y ≤ ε) :
    ∀ x ∈ S, ∀ y ∈ S, x ≠ y → (ripsSimpleGraph ε).Adj x y := by
  exact fun x hx y hy hxy => ⟨ hxy, hε x hx y hy ⟩

/-! ## Betti Number Properties -/

/-
The sphere signature for dimension ≥ 1 starts with 1 (β₀ = 1).
-/
theorem sphere_betti_zero (n : ℕ) (_hn : 0 < n) :
    (sphereSignature n).betti.head? = some 1 := by
  unfold sphereSignature; simp +decide ;

/-
The sphere signature has length n + 1.
-/
theorem sphereSignature_length (n : ℕ) :
    (sphereSignature n).betti.length = n + 1 := by
  unfold sphereSignature; aesop;

/-
The last Betti number of the n-sphere signature is 1 (βₙ = 1).
-/
theorem sphere_betti_top (n : ℕ) :
    (sphereSignature n).betti.getLast? = some 1 := by
  unfold sphereSignature;
  grind

end