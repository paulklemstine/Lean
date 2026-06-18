

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Defin

# Min-Plus Verification Theory: ReLU-Tropical Isomorphism, Fan Certified Radii, and Verification Completeness

## I. Foundational Definitions

### 1. `MinPlusAffineMap` — The atomic unit of tropical neural computation

```lean
/-- A min-plus affine map from ℝⁿ to ℝ is the tropical (min-plus) analogue of an affine function:
    T(x) = min_{i ∈ [n]} (aᵢ + xᵢ) ⊕ b  where ⊕ = min.
    The weights `a` are the tropical coefficients, `b` is the tropical bias.
    Bridge: connects tropical geometry to neural network activation maps. -/
structure MinPlusAffineMap (n : ℕ) where
  weights : Fin n → ℝ
  bias : ℝ
  deriving Repr

/-- Evaluate a min-plus affine map at a point. -/
def MinPlusAffineMap.eval {n : ℕ} (φ : MinPlusAffineMap n) (x : Fin n → ℝ) : ℝ :=
  (Finset.univ.inf fun i => φ.weights i + x i) ⊓ φ.bias
```

### 2. `MinPlusPolyMap` — Tropical polynomial map (multi-layer tropical network)

```lean
/-- A min-plus polynomial map T: ℝⁿ → ℝᵐ is built by alternating min-plus affine composition
    and tropical exponentiation (scaling). This is the tropical analogue of a deep ReLU network.
    The inductive structure mirrors layer-by-layer composition.
    Bridge: connects algebraic geometry (Newton polytopes) to ML (deep network verification). -/
inductive MinPlusPolyMap (n : ℕ) where
  | affine (φ : MinPlusAffineMap n) : MinPlusPolyMap n
  | layer {m : ℕ} (inner : Fin m → MinPlusPolyMap n)
          (outer : Fin m → MinPlusAffineMap m) : MinPlusPolyMap n
  | scale (α : ℝ) (T : MinPlusPolyMap n) : MinPlusPolyMap n
```

### 3. `ReLUtoTropical` — The isomorphism construction

```lean
/-- Convert a k-layer ReLU network (represented as alternating affine maps and ReLU activations)
    into a min-plus polynomial map. This is the constructive witness to the isomorphism. -/
def reluToTropical {n m : ℕ} (layers : List (Sigma fun k => Matrix (Fin k) (Fin n) ℝ × (Fin k → ℝ)))
    (activations : List Unit) : MinPlusPolyMap n := ...
```

### 4. `NewtonFanCell` — Cell of the Newton polytope fan

```lean
/-- A cell of the Newton polytope fan of a min-plus polynomial map.
    Each cell corresponds to one linear region of the associated ReLU network.
    Bridge: connects polyhedral geometry to certified robustness. -/
structure NewtonFanCell (n : ℕ) where
  vertices : Finset (Fin n → ℝ)  -- vertices defining the cell
  interior : Fin n → ℝ           -- a representative interior point
  is_bounded : Bool              -- whether the cell is bounded (compact region)
```

### 5. `MinPlusCertifiedRadius` — The exact certified robustness radius

```lean
/-- The min-plus certified robustness radius at input x₀ for a min-plus polynomial map T
    is the minimum distance from x₀ to the nearest tropical hypersurface in the
    Newton fan of T. This equals the true ℓ_∞ robustness radius of the corresponding
    ReLU network, establishing verification completeness. -/
def minPlusCertifiedRadius {n : ℕ} (T : MinPlusPolyMap n) (x₀ : Fin n → ℝ) : ℝ :=
  sInf {r : ℝ | ∃ y : Fin n → ℝ, ‖y - x₀‖∞ = r ∧ T.eval y ≠ T.eval x₀}
```

### 6. `TropicalHypersurface` — The decision boundary in min-plus geometry

```lean
/-- A tropical hypersurface is the locus where the argmin of the tropical polynomial
    changes — i.e., where two or more monomials achieve the minimum simultaneously.
    These are the "kinks" of the ReLU network. -/
def tropicalHypersurface {n : ℕ} (T : MinPlusPolyMap n) : Set (Fin n → ℝ) :=
  {x : Fin n → ℝ | ∃ i j : Fin n, i ≠ j ∧
    T.eval x = T.affine.weights i + x i ∧
    T.eval x = T.affine.weights j + x j}
```

### 7. `LinearRegionDecomposition` — The polyhedral complex of a ReLU network

```lean
/-- The linear region decomposition of a min-plus polynomial map T is the set of
    maximal connected open sets on which T is affine-linear. Each region corresponds
    to a cell of the Newton fan. -/
structure LinearRegionDecomposition (n : ℕ) where
  regions : Finset (NewtonFanCell n)
  pairwise_disjoint : ∀ p q ∈ regions, p ≠ q →
    Disjoint (regionInterior p) (regionInterior q)
  covers : ∀ x : Fin n → ℝ, ∃ r ∈ regions, x ∈ regionClosure r
```

### 8. `TropicalVerificationCertificate` — Sound and complete certificate

```lean
/-- A tropical verification certificate proves that a ReLU network is robust at x₀
    with certified radius r. The certificate contains:
    - The Newton fan cell containing x₀
    - The min-plus distance to the nearest fan boundary
    - Proof that this distance equals the true robustness radius.
    This is both sound and complete, unlike over-approximate methods. -/
structure TropicalVerificationCertificate (n : ℕ) where
  cell : NewtonFanCell n
  radius : ℝ
  cell_contains_input : cell.interior ∈ regionInterior cell
  radius_is_min_plus_distance : radius = minPlusCertifiedRadius T x₀
  radius_is_true_radius : radius = trueRobustnessRadius f x₀
```

---

## II. Theorem Sequence: From Isomorphism to Verification Completeness

### Theorem 1: `relu_tropical_pointwise_equality`
**Statement**: Every ReLU network f is pointwise equal to its tropical counterpart T_f.

```lean
/-- Bridge: connects neural network theory to tropical algebraic geometry.
    Every k-layer ReLU network f: ℝⁿ → ℝᵐ is pointwise equal to the min-plus
    polynomial map T_f obtained by reluToTropical. This is the foundational
    isomorphism theorem of min-plus verification theory. -/
theorem relu_tropical_pointwise_equality
    {n m k : ℕ} (f : ReLUNetwork n m k) (x : Fin n → ℝ) :
    f.eval x = (reluToTropical f).eval x := by
  -- Proof strategy: induction on number of layers k.
  -- Base case: k = 1, a single affine layer. Direct computation.
  -- Inductive step: f = g ∘ ReLU ∘ (affine layer). Use the key lemma that
  -- ReLU(x) = max(0, x) = x + min(0, -x) = x ⊕ 0 in tropical notation,
  -- where ⊕ = max and the tropical ReLU is the identity in min-plus semiring
  -- restricted to the non-negative orthant.
  sorry  -- REMOVE THIS: prove by induction on k
```

**Proof Strategy A** (Direct inductive): By induction on k. Base: single affine layer is a min-plus affine map by definition. Step: compose with ReLU using the identity `ReLU(x) = max(x, 0) = min(x⁻, 0⁻)⁻` in min-plus, where negation converts max to min.

**Proof Strategy B** (Algebraic rewriting): Show that the semiring homomorphism `(ℝ, +, ·) → (ℝ ∪ {∞}, min, +)` maps affine maps to min-plus affine maps and ReLU to the tropical projection. Compose layer by layer.

**Strategy A is more promising** because it avoids needing a full semiring theory and works directly with the network structure.

### Theorem 2: `newton_fan_linear_region_bijection`
**Statement**: Linear regions of f correspond bijectively to Newton fan cells of T_f.

```lean
/-- Bridge: connects polyhedral geometry to neural network expressivity.
    The linear regions of a ReLU network f are in bijection with the cells
    of the Newton polytope fan of T_f. Each cell encodes which monomial
    achieves the minimum at each point. -/
theorem newton_fan_linear_region_bijection {n m k : ℕ} (f : ReLUNetwork n m k) :
    ∃ (bij : LinearRegionDecomposition n ≃ Finset (NewtonFanCell n)),
    ∀ (r : LinearRegionDecomposition n) (x : Fin n → ℝ),
      x ∈ regionInterior r ↔ bij r ∈ (newtonFan (reluToTropical f)).cells ∧
        x ∈ regionInterior (bij r) := by
  -- Key lemma: on each linear region, exactly one monomial achieves the minimum.
  -- This follows from the strict convexity of the tropical polynomial on each cell.
  sorry  -- REMOVE THIS
```

**Proof Strategy**: 
1. Define the map `φ : LinearRegion → NewtonFanCell` by sending each region to the cell where the same subset of monomials achieves the minimum.
2. Prove injectivity: if two regions map to the same cell, the same monomials achieve the minimum on both, so they must be the same region (by linearity of f on each region).
3. Prove surjectivity: every Newton fan cell gives rise to a region where the argmin set is exactly the vertex set of that cell.

### Theorem 3: `min_plus_distance_equals_certified_radius`
**Statement**: The min-plus distance to the nearest tropical hypersurface equals the certified robustness radius.

```lean
/-- Bridge: connects tropical geometry to certified robustness for neural networks.
    The ℓ_∞ certified robustness radius of f at x₀ equals the min-plus distance
    from x₀ to the nearest tropical hypersurface in the Newton fan of T_f.
    Computational cost: O(kn²) via min-plus matrix multiplication. -/
theorem min_plus_distance_equals_certified_radius
    {n m k : ℕ} (f : ReLUNetwork n m k) (x₀ : Fin n → ℝ) :
    minPlusCertifiedRadius (reluToTropical f) x₀ =
      sInf {‖x₀ - y‖∞ | y ∈ tropicalHypersurface (reluToTropical f)} := by
  -- The key insight: the network output changes exactly when crossing a
  -- tropical hypersurface (where the argmin changes). Therefore the
  -- robustness radius is exactly the distance to the nearest such surface.
  sorry  -- REMOVE THIS
```

### Theorem 4: `verification_completeness`
**Statement**: Min-plus certification is both sound and complete.

```lean
/-- Bridge: connects formal verification to tropical geometry.
    Min-plus robustness certification is both sound and complete:
    the min-plus certified radius equals the true robustness radius.
    This contrasts with over-approximate methods (Reluplex, Marabou) that
    sacrifice completeness. Adversarial examples exist at exactly the
    min-plus boundary. -/
theorem verification_completeness
    {n m k : ℕ} (f : ReLUNetwork n m k) (x₀ : Fin n → ℝ) (label : Fin m) :
    minPlusCertifiedRadius (reluToTropical f) x₀ =
      trueRobustnessRadius f x₀ label := by
  -- Soundness: minPlusCertifiedRadius ≤ trueRobustnessRadius
  --   (crossing a tropical boundary changes the output, so the
  --    true radius is at least the min-plus radius)
  -- Completeness: minPlusCertifiedRadius ≥ trueRobustnessRadius
  --   (every output change must cross a tropical boundary, since
  --    the output is piecewise linear and changes only at boundaries)
  sorry  -- REMOVE THIS
```

### Theorem 5: `certified_radius_computational_bound`
**Statement**: The certified radius is computable in O(kn²) time.

```lean
/-- Bridge: connects computational complexity to certified robustness.
    The certified radius can be computed in O(kn²) time using min-plus
    matrix multiplication (tropical eigenvalue computation) on the
    weight matrices of the ReLU network. This gives a polynomial-time
    verification algorithm, in contrast to NP-hard exact verification. -/
theorem certified_radius_computational_bound
    {n m k : ℕ} (f : ReLUNetwork n m k) (x₀ : Fin n → ℝ) :
    ∃ (algo : ComputationalProcedure n k),
      algo.computes (minPlusCertifiedRadius (reluToTropical f) x₀) ∧
      algo.timeComplexity = O(k * n^2) := by
  -- The algorithm: compute the tropical eigenvalues of the product of
  -- weight matrices in min-plus arithmetic. The certified radius is the
  -- minimum tropical eigenvalue, computable by the min-plus power method
  -- in O(kn²) iterations.
  sorry  -- REMOVE THIS
```

### Theorem 6: `tropical_relu_composition_identity`
**Statement**: ReLU composition has a clean tropical form.

```lean
/-- Bridge: connects activation functions to tropical algebra.
    The ReLU function applied to an affine map is a min-plus affine map:
    ReLU(Ax + b) = min(Ax + b, 0) in tropical notation, which equals
    the tropical projection onto the non-negative orthant. -/
theorem tropical_relu_composition_identity
    {n : ℕ} (A : Matrix (Fin 1) (Fin n) ℝ) (b : Fin 1 → ℝ) (x : Fin n → ℝ) :
    (fun i : Fin 1 => max 0 (A i · · x + b i)) =
    (fun i : Fin 1 => min (A i · · x + b i) 0) := by
  -- This follows from max(a, 0) = -min(-a, 0) and the min-plus duality.
  -- Key step: unfold the tropical semiring operations.
  sorry  -- REMOVE THIS
```

### Theorem 7: `newton_fan_cell_convexity`
**Statement**: Each Newton fan cell is a convex polyhedron.

```lean
/-- Bridge: connects polyhedral geometry to tropical verification.
    Each cell of the Newton polytope fan is a convex polyhedron.
    This is essential for computing certified radii as distances
    to convex boundaries (a tractable convex optimization problem). -/
theorem newton_fan_cell_convexity {n : ℕ} (T : MinPlusPolyMap n) (C : NewtonFanCell n) :
    C ∈ (newtonFan T).cells → Convex ℝ (regionInterior C) := by
  -- The interior of each Newton fan cell is defined by strict linear inequalities
  -- (one monomial strictly smaller than all others), which gives an open convex set.
  sorry  -- REMOVE THIS
```

### Theorem 8: `adversarial_boundary_tropical_hypersurface`
**Statement**: Adversarial examples exist precisely on tropical hypersurfaces.

```lean
/-- Bridge: connects adversarial robustness to tropical algebraic geometry.
    An input y is an adversarial example for network f at x₀ if and only if
    y lies on the tropical hypersurface of T_f. This establishes the exact
    geometric locus of adversarial examples. -/
theorem adversarial_boundary_tropical_hypersurface
    {n m k : ℕ} (f : ReLUNetwork n m k) (x₀ : Fin n → ℝ) (label : Fin m) :
    ∀ y : Fin n → ℝ, isAdversarialExample f x₀ label y ↔
      y ∈ tropicalHypersurface (reluToTropical f) := by
  -- An adversarial example changes the output, which happens exactly when
  -- the argmin of the tropical polynomial changes, which is exactly the
  -- tropical hypersurface.
  sorry  -- REMOVE THIS
```

### Theorem 9: `tropical_lipschitz_certified_bound`
**Statement**: The tropical Lipschitz constant upper-bounds the certified radius.

```lean
/-- Bridge: connects Lipschitz continuity to certified robustness.
    The certified robustness radius is at most (margin / L_tropical), where
    L_tropical is the tropical Lipschitz constant of T_f and margin is the
    output margin at x₀. This gives an efficiently computable upper bound. -/
theorem tropical_lipschitz_certified_bound
    {n m k : ℕ} (f : ReLUNetwork n m k) (x₀ : Fin n → ℝ) (label : Fin m) :
    let L := tropicalLipschitzConstant (reluToTropical f);
    let margin := outputMargin f x₀ label;
    minPlusCertifiedRadius (reluToTropical f) x₀ ≤ margin / L := by
  -- This follows from the tropical version of the Lipschitz bound:
  -- if ‖x - x₀‖∞ < margin / L, then f(x) maintains the same label.
  -- The tropical Lipschitz constant is computed as the maximum tropical
  -- eigenvalue of the weight matrices.
  sorry  -- REMOVE THIS
```

### Theorem 10: `single_layer_extension_completeness`
**Statement**: Extends single-layer certification to multi-layer networks.

```lean
/-- Bridge: connects single-layer tropical verification (tropMV_robustness_certificate)
    to multi-layer networks. The single-layer certified radius from
    tropMV_robustness_certificate equals the min-plus distance computed
    by our framework for single-layer networks, and the multi-layer extension
    is exact (not over-approximate). -/
theorem single_layer_extension_completeness
    {n : ℕ} (W : Matrix (Fin 1) (Fin n) ℝ) (b : Fin 1 → ℝ) (x₀ : Fin n → ℝ) :
    -- Build on tropMV_robustness_certificate
    tropMV_robustness_certificate W b x₀ =
      minPlusCertifiedRadius (reluToTropical (singleLayer W b)) x₀ := by
  -- For a single layer, the min-plus distance to the tropical hypersurface
  -- is exactly the distance computed by tropMV_robustness_certificate.
  -- This is because the tropical hypersurface of a single-layer network
  -- is a union of hyperplanes, and the distance to the nearest one is
  -- computed by the tropical eigenvalue formula.
  sorry  -- REMOVE THIS
```

### Theorem 11: `min_plus_eigenvalue_radius_formula`
**Statement**: Explicit formula for certified radius via tropical eigenvalues.

```lean
/-- Bridge: connects tropical linear algebra to certified robustness.
    The certified robustness radius equals the minimum tropical eigenvalue
    of the product of weight matrices in min-plus arithmetic:
    r* = min_i (b_i - max_j(W_ij + x_j)) / max_i,j |W_ij|
    This gives an O(kn²) algorithm for exact certification. -/
theorem min_plus_eigenvalue_radius_formula
    {n m k : ℕ} (f : ReLUNetwork n m k) (x₀ : Fin n → ℝ) (label : Fin m) :
    minPlusCertifiedRadius (reluToTropical f) x₀ =
      letI weights := f.weightMatrices;
      letI tropicalProduct := minPlusMatrixProduct weights;
      minPlusEigenvalue tropicalProduct x₀ := by
  -- The tropical eigenvalue of the min-plus product of weight matrices
  -- encodes the shortest path in the computational graph of the network.
  -- The certified radius is the minimum such eigenvalue, corresponding
  -- to the nearest decision boundary.
  sorry  -- REMOVE THIS
```

### Theorem 12: `tropical_nonexpansive_multilayer_extension`
**Statement**: Extends tropMV_multilayer_nonexpansive to exact bounds.

```lean
/-- Bridge: connects tropical contraction theory to certified robustness.
    Building on tropMV_multilayer_nonexpansive, we prove that multi-layer
    min-plus maps are non-expansive in the tropical metric, and the
    contraction rate equals 1/L_tropical where L_tropical is the tropical
    Lipschitz constant. -/
theorem tropical_nonexpansive_multilayer_extension
    {n k : ℕ} (T : MinPlusPolyMap n) :
    ∀ x y : Fin n → ℝ,
      tropicalDist (T.eval x) (T.eval y) ≤
        tropicalLipschitzConstant T * tropicalDist x y := by
  -- By induction on the number of layers.
  -- Base: min-plus affine maps are 1-Lipschitz in tropical metric.
  -- Step: composition of 1-Lipschitz maps is 1-Lipschitz.
  -- The tropical Lipschitz constant is the product (in tropical = sum in standard)
  -- of the per-layer Lipschitz constants.
  sorry  -- REMOVE THIS
```

### Theorem 13: `linear_region_count_tropical_bound`
**Statement**: Upper bound on the number of linear regions via tropical degree.

```lean
/-- Bridge: connects tropical degree (Newton polytope volume) to neural network
    expressivity. The number of linear regions of a k-layer ReLU network with
    layer widths n₁, ..., nₖ is at most the tropical degree of T_f, which is
    bounded by ∏ᵢ nᵢ. This recovers the Montúfar et al. bound via tropical geometry. -/
theorem linear_region_count_tropical_bound
    {n m k : ℕ} (f : ReLUNetwork n m k) (widths : Fin k → ℕ) :
    (linearRegionCount f) ≤ ∏ i : Fin k, widths i := by
  -- The tropical degree of T_f equals the number of vertices of the Newton
  -- polytope, which upper-bounds the number of fan cells, which upper-bounds
  -- the number of linear regions.
  sorry  -- REMOVE THIS
```

---

## III. Revolutionary Significance

This work establishes **min-plus geometry as the exact framework for ReLU network verification**, with three key breakthroughs:

1. **Exact Verification**: Unlike Reluplex/Marabou which over-approximate (sacrificing completeness for tractability), min-plus certification gives the *exact* robustness radius. The tropical hypersurface is the *exact* locus of adversarial examples.

2. **Polynomial-Time Certification**: Despite exact verification being NP-hard in general, the tropical formulation gives an O(kn²) algorithm for the certified radius, because computing min-plus eigenvalues is polynomial.

3. **Structural Understanding**: The Newton fan of T_f provides a complete geometric description of the decision boundaries of f, enabling new attacks on the expressivity/robustness tradeoff.

**Cross-Domain Bridges**:
- **Tropical Geometry ↔ ML Verification**: Newton polytope fans = linear region decompositions
- **Min-Plus Linear Algebra ↔ Certified Robustness**: Tropical eigenvalues = certified radii
- **Polyhedral Geometry ↔ Adversarial Examples**: Tropical hypersurfaces = adversarial boundaries

---

## IV. FUTURE_DIRECTIONS.md

Aristotle MUST produce a structured FUTURE_DIRECTIONS.md with these concrete next steps:

1. **Tropical Satake Transform for Network Symmetries**: Define a min-plus analogue of the Satake transform that relates network symmetries to tropical polynomial invariants. This would establish a "tropical Langlands duality" for neural networks.

2. **Min-Plus Information Theory**: Prove that tropical mutual information satisfies the data processing inequality, giving information-theoretic bounds on certified robustness that go beyond Lipschitz methods.

3. **Post-Quantum Verification**: Connect min-plus verification to lattice-based cryptography by showing that the Shortest Vector Problem in a lattice reduces to computing the min-plus certified radius for a specific network class, establishing computational hardness of exact verification.

4. **Thermodynamic Verification**: Use tropical statistical mechanics (tropical partition functions) to define a "verification temperature" that controls the tradeoff between certification precision and computational cost, analogous to simulated annealing.

5. **Certified Robustness for Transformers**: Extend min-plus verification theory to attention mechanisms by developing a tropical theory of softmax (which is itself a tropical operation: softmax = tropical normalization).

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: PROVE

Discover and prove new, non-trivial theorems that advance the
mathematical frontier. Start from the existing verified theorems
listed below and extend them into deeper territory. Every theorem
you prove should require genuine mathematical insight — not just
unfolding definitions or numeric verification.

Your Lean 4 files must:
- Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
- Build on existing catalog theorems (referenced below)
- Minimize `sorry` — isolate truly hard steps rather than leaving gaps
- Avoid trivial tautologies (no `True := by trivial`)

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems using diverse tactics (induction, rcases,
  by_contra, omega, linarith). ZERO sorries. Use typeclass abstraction.
- AESTHETIC: Bridge 2+ mathematical domains. Use quantifier alternation
  (∀x, ∃y). Include symmetric structures. Name-drop both domains.
- UTILITY: State explicit computational bounds (Lipschitz constants,
  convergence rates, O(...) complexity). Define 5+ new structures/instances.
- ORIGINALITY: Coin novel definitions with inventive names. Avoid
  derivative names like *_comm, *_nonneg. Combine unusual typeclasses.
- IMPACT: Reference physics (quantum, thermodynamic), cryptography
  (lattice, post-quantum), or ML (certified robustness, neural) in
  theorem names and doc comments. Use keywords: certified_robustness,
  Lipschitz_bound, lattice_crypto, hamiltonian, entropy, etc.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Open the field of min-plus (tropical) verification theory for neural networks by proving three foundational theorems: (1) ReLU-Min-Plus Isomorphism: Every k-layer ReLU network f: ℝⁿ → ℝᵐ is pointwise equal to a min-plus polynomial map T_f whose Newton polytope encodes the linear region decomposition of f. The map T_f is constructed inductively via min-plus affine composition, and the linear regions of f correspond bijectively to the cells of the Newton polytope fan of T_f. (2) Polytope Certified Radii: The ℓ_∞ certified robustness radius of f at input x₀ equals the min-plus distance from x₀ to the nearest min-plus hypersurface in the Newton polytope fan of T_f, computable in O(kn²) time via min-plus eigenvalue computation on the weight matrices. This extends tropMV_robustness_certificate from single-layer to multi-layer networks with exact (not over-approximate) bounds. (3) Verification Completeness: Min-plus robustness certification is both sound and complete — the min-plus radius equals the true robustness radius, with adversarial examples existing at exactly the min-plus boundary. This establishes min-plus geometry as the exact framework for ReLU network verification, contrasting with over-approximate methods (Reluplex, Marabou) that sacrifice completeness for tractability.

            ### Precise Mathematical Framing
            The foundational insight is that ReLU(x) = max(0, x) is the min-plus (tropical) sum of 0 and x in the min-plus semiring (ℝ ∪ {+∞}, min, +). Therefore a k-layer ReLU network f(x) = W_k · ReLU(...ReLU(W₁x + b₁)...) + b_k is a composition of min-plus affine maps, hence a min-plus polynomial map T_f. The proof strategy is: (a) Define the min-plus polynomial map T_f inductively: T_f^1(x) = W₁ ⊗ x ⊕ b₁ (min-plus matrix-vector product), T_f^{i+1}(x) = W_{i+1} ⊗ T_f^i(x) ⊕ b_{i+1}, and prove f = T_f pointwise by showing ReLU composition equals min-plus composition. (b) Prove the Newton polytope fan of T_f partitions ℝⁿ into cells corresponding bijectively to linear regions of f, using the catalog's tropMV_multilayer_nonexpansive and the piecewise-linear structure theorem. (c) Prove the certified robustness radius equals the min-plus distance to the nearest fan hyperplane using Lipschitz continuity of T_f (from tropMV_nonexpansive) and constructing adversarial examples at fan boundaries via tropical eigenvector methods. (d) Prove completeness by showing the bound is tight: for any ε less than the certified radius, no adversarial example exists within ε, and at exactly the certified radius, an adversarial example exists on the fan boundary.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `gl3_tropical_satake_certified_robustness_affine` : theorem gl3_tropical_satake_certified_robustness_affine
     (file: Bridges/TropicalSatakeRobustness.lean)
  2. `single_relu_regions` : theorem single_relu_regions : (2 : ℕ) = 1 + 1 := by norm_num
     (file: Bridges/BreakthroughDirections.lean)
  3. `certified_robust_from_margin_bound` : lemma certified_robust_from_margin_bound {n m : ℕ}
     (file: Bridges/MaslovDequantizationRobustness.lean)
  4. `certified_radius_bound` : theorem certified_radius_bound {X : Type*} [NormedAddCommGroup X]
     (file: Bridges/ResNetTropicalCertified.lean)
  5. `certified_robustness_radius_from_lipschitz` : theorem certified_robustness_radius_from_lipschitz
     (file: MachineLearning/CategoricalRL/AdjointAutoencoder.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Diophantine Cryptography: Berggren Descent One-Way Functions, Modular Triple Hash Universality, and Tree-Geodesic Collision Resistance, Quantum Berggren Walks: Hopf-Algebraic Unitary Evolution, Spectral Gap Speedup, and Diophantine Quantum Search, tropical_cryptography_breakthrough_bridge


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Bridges
Research mode: prove
