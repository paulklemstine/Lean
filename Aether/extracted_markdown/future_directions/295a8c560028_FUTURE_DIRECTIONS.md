# Future Directions: Orbit Cost and Symmetry-Reduced Transport

This document outlines concrete next steps opened by the formalization of the orbit-cost triangle inequality.

---

## 1. Orbit Pseudometric Package

### Goal
Prove that under reflexivity, symmetry, nonnegativity, and diagonal invariance, the orbit cost is a pseudometric on the orbit space `α / G`.

### Theorem Signatures

```lean
/-- Orbit cost is nonneg if the base cost is. -/
theorem orbitCost_nonneg
    (G : Type*) {α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ)
    (hnn : ∀ x y, 0 ≤ Wc x y)
    (hbd : ∀ μ ν, BddBelow (Set.range fun g : G => Wc μ (g • ν))) :
    ∀ μ ν, 0 ≤ orbitCost G Wc μ ν

/-- Orbit cost is symmetric if Wc is symmetric and the action is bi-invariant. -/
theorem orbitCost_symm
    (G : Type*) {α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ)
    (hsymm : ∀ x y, Wc x y = Wc y x)
    (hinv : ∀ x y g, Wc (g • x) (g • y) = Wc x y)
    (hbd : ∀ μ ν, BddBelow (Set.range fun g : G => Wc μ (g • ν))) :
    ∀ μ ν, orbitCost G Wc μ ν = orbitCost G Wc ν μ

/-- Package: orbit cost as a PseudoMetricSpace on the quotient. -/
instance orbitCostPseudoMetric
    (G : Type*) {α : Type*} [Group G] [MulAction G α]
    (Wc : α → α → ℝ)
    (htri : ∀ x y z, Wc x z ≤ Wc x y + Wc y z)
    (hinv : ∀ x y g, Wc (g • x) (g • y) = Wc x y)
    (hrefl : ∀ x, Wc x x = 0)
    (hsymm : ∀ x y, Wc x y = Wc y x)
    (hnn : ∀ x y, 0 ≤ Wc x y)
    (hbd : ∀ μ ν, BddBelow (Set.range fun g : G => Wc μ (g • ν))) :
    PseudoMetricSpace (Quotient (MulAction.orbitRel G α))
```

### Proof Strategy
- Nonnegativity: the infimum of nonnegative values is nonneg.
- Symmetry: for each `g`, find `g'` such that `Wc μ (g • ν) = Wc ν (g' • μ)`, using invariance and symmetry of `Wc`. The key is `g' = g⁻¹` with the rewrite `Wc μ (g • ν) = Wc (g⁻¹ • μ) ν = Wc ν (g⁻¹ • μ)`.
- Reflexivity and triangle: already proved.
- Package as `PseudoMetricSpace` on the quotient type.

### Significance
Provides a plug-and-play pseudometric construction for any isometric group action — useful in shape analysis, gauge theory, and moduli spaces.

---

## 2. Permutation-Invariant Transport on Finite Arrays

### Goal
Instantiate the abstract theorem to `G = Equiv.Perm (Fin n)` acting on `Fin n → ℝ` by coordinate permutation. This yields a metric for comparing unordered collections (multisets, point clouds, spectra).

### Theorem Signatures

```lean
/-- The permutation group acts on functions by precomposition. -/
instance : MulAction (Equiv.Perm (Fin n)) (Fin n → ℝ) where
  smul σ f := f ∘ σ.symm
  ...

/-- L^p cost is permutation-invariant. -/
theorem lp_cost_perm_invariant (p : ℝ) (hp : 1 ≤ p) :
    ∀ (f g : Fin n → ℝ) (σ : Equiv.Perm (Fin n)),
    (∑ i, |σ • f i - σ • g i| ^ p) = (∑ i, |f i - g i| ^ p)

/-- Triangle inequality for permutation orbit cost on finite arrays. -/
theorem perm_orbitCost_triangle (n : ℕ) :
    ∀ f g h : Fin n → ℝ,
    orbitCost (Equiv.Perm (Fin n)) (fun f g => ∑ i, |f i - g i|) f h ≤
    orbitCost (Equiv.Perm (Fin n)) (fun f g => ∑ i, |f i - g i|) f g +
    orbitCost (Equiv.Perm (Fin n)) (fun f g => ∑ i, |f i - g i|) g h
```

### Proof Strategy
- Define the permutation action on `Fin n → ℝ`.
- Prove L¹ (or Lᵖ) cost invariance under permutation.
- Apply `orbitCost_triangle_fintype`.

### Significance
This is the formal backbone for comparing unordered data: spectra in chemistry, feature sets in ML, sorted statistics in data science. The triangle inequality certifies that nearest-neighbor queries and clustering on such data are well-founded.

---

## 3. Graph Matching Pseudometric

### Goal
Define orbit cost on adjacency matrices under conjugation by permutation matrices. This gives a pseudometric on isomorphism classes of graphs.

### Theorem Signatures

```lean
/-- Adjacency matrix type. -/
def AdjMatrix (n : ℕ) := Fin n → Fin n → ℝ

/-- Permutation group acts on matrices by conjugation. -/
instance : MulAction (Equiv.Perm (Fin n)) (AdjMatrix n) where
  smul σ A i j := A (σ.symm i) (σ.symm j)
  ...

/-- Frobenius norm is invariant under permutation conjugation. -/
theorem frobenius_perm_invariant (n : ℕ) :
    ∀ (A B : AdjMatrix n) (σ : Equiv.Perm (Fin n)),
    ‖σ • A - σ • B‖ = ‖A - B‖

/-- Graph matching orbit cost satisfies triangle inequality. -/
theorem graph_orbitCost_triangle (n : ℕ) :
    ∀ A B C : AdjMatrix n,
    orbitCost (Equiv.Perm (Fin n)) (fun A B => ‖A - B‖) A C ≤
    orbitCost (Equiv.Perm (Fin n)) (fun A B => ‖A - B‖) A B +
    orbitCost (Equiv.Perm (Fin n)) (fun A B => ‖A - B‖) B C
```

### Proof Strategy
- Define conjugation action.
- Show Frobenius norm invariance (permuting rows/columns doesn't change Frobenius norm of difference).
- Apply `orbitCost_triangle_fintype`.

### Significance
Graph isomorphism is computationally hard, but approximate graph comparison via orbit cost is tractable. A certified triangle inequality enables metric indexing (VP-trees, ball trees) for efficient graph retrieval in databases, drug discovery, social network analysis.

---

## 4. Quotient Wasserstein on Probability Measures

### Goal
Specialize the orbit cost to a bona fide Wasserstein cost on probability measures, with a group acting on the underlying space.

### Theorem Signatures

```lean
/-- Wasserstein-1 distance is invariant under isometric group action. -/
theorem wasserstein_action_invariant
    {G X : Type*} [Group G] [MulAction G X] [PseudoMetricSpace X]
    (hinv : ∀ x y g, dist (g • x) (g • y) = dist x y) :
    ∀ (μ ν : MeasureTheory.Measure X) (g : G),
    wasserstein (g • μ) (g • ν) = wasserstein μ ν

/-- Orbit Wasserstein triangle inequality. -/
theorem orbit_wasserstein_triangle
    {G X : Type*} [Group G] [MulAction G X] [PseudoMetricSpace X]
    (hinv : ∀ x y g, dist (g • x) (g • y) = dist x y) :
    ∀ μ ν ρ : MeasureTheory.Measure X,
    orbitCost G wasserstein μ ρ ≤
    orbitCost G wasserstein μ ν + orbitCost G wasserstein ν ρ
```

### Proof Strategy
- Formal Wasserstein distance is partially available in Mathlib (`MeasureTheory.Measure.WassersteinDist`). Verify API status.
- Prove invariance of Wasserstein under measure pushforward by isometry.
- Apply `orbitCost_triangle`.

### Significance
This is the theoretical foundation for symmetry-aware generative models: comparing probability distributions modulo symmetry. Applications to equivariant diffusion models, invariant GANs, and physics-informed neural networks.

---

## 5. Gauge/Orbit Distance for Physics-Inspired State Spaces

### Goal
Formalize the construction where `G` is a gauge group, `α` is a configuration space (e.g., connections on a bundle), and the orbit cost defines gauge-invariant distances on the moduli space.

### Theorem Signatures

```lean
/-- Gauge orbit cost on a principal bundle connection space. -/
noncomputable def gaugeCost
    (G : Type*) [Group G] {X : Type*} [MulAction G X]
    (energy : X → X → ℝ) : X → X → ℝ :=
  orbitCost G energy

/-- The gauge cost is gauge-invariant and satisfies the triangle inequality,
    hence defines a pseudometric on the moduli space G \ X. -/
theorem gauge_triangle
    (G : Type*) [Group G] {X : Type*} [MulAction G X]
    (energy : X → X → ℝ)
    (htri : ∀ x y z, energy x z ≤ energy x y + energy y z)
    (hinv : ∀ x y g, energy (g • x) (g • y) = energy x y)
    (hbd : ∀ μ ν, BddBelow (Set.range fun g : G => energy μ (g • ν))) :
    ∀ A B C : X, gaugeCost G energy A C ≤
      gaugeCost G energy A B + gaugeCost G energy B C
```

### Proof Strategy
- Direct application of `orbitCost_triangle`.
- The mathematical content is in establishing that specific gauge theories satisfy the invariance and triangle hypotheses.

### Significance
Formal certification of distance structures on moduli spaces. Relevant to lattice gauge theory computations, topological data analysis of physical systems, and mathematical verification in quantum field theory.

---

## Cross-Cutting Themes

All five directions share a common mechanism: **the orbit-cost construction is functorial**. Given:
- A category of "cost spaces" (objects with a cost function satisfying triangle inequality),
- A group acting by cost-preserving maps,

the orbit cost is a functor to the category of "quotient cost spaces." Future work should formalize this categorical perspective, potentially using Mathlib's category theory library.

### Keywords
Quotient optimal transport, orbit pseudometric, symmetry-reduced Wasserstein distance, equivariant metric learning, group action invariance, registration metric, moduli-space geometry, gauge-invariant distance, graph matching, shape analysis, canonicalization-free comparison, transport on quotient spaces.
