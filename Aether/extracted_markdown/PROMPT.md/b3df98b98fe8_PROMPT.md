

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## TROPICAL HOLOGRAPHIC DUALITY: Max-Plus Conformal Extension, Berggren Boundary Embedding, and Satake Operator-State Correspondence

### DOMAIN: Physics × Tropical Geometry × Cryptographic Lattice Theory

---

### I. FOUNDATIONAL DEFINITIONS (5+ novel structures required)

Define the following structures with full typeclass infrastructure:

```lean
/-- The tropical upper half-plane: bulk of the holographic duality.
    Bridge: connects tropical geometry to hyperbolic geometry (AdS physics). -/
structure TropicalUpperHalfPlane where
  x : ℝ  -- tropical real coordinate (logarithmic scale)
  y : ℝ  -- height coordinate, strictly positive
  y_pos : 0 < y

namespace TropicalUpperHalfPlane

/-- The max-plus hyperbolic metric on H_trop.
    Analogous to the Poincaré metric ds² = (dx² + dy²)/y² but with
    tropical (ℓ∞) structure: d_trop(P,Q) = max(|x_P - x_Q|, |y_P - y_Q|) / min(y_P, y_Q).
    This is the tropicalization of the Poincaré distance formula.
    Bridge: connects metric geometry to quantum field theory (AdS bulk metric). -/
noncomputable def tropicalHyperbolicDist (P Q : TropicalUpperHalfPlane) : ℝ :=
  max (|P.x - Q.x|) (|P.y - Q.y|) / min P.y Q.y

/-- A piecewise-linear geodesic in H_trop: the tropical analog of a semicircle.
    In classical H, geodesics are semicircles perpendicular to ∂H.
    In H_trop, geodesics are piecewise-linear paths with at most one bend.
    Bridge: connects tropical geometry to optimal transport (ML certified robustness). -/
structure TropicalGeodesic where
  start : TropicalUpperHalfPlane
  bend : Option TropicalUpperHalfPlane  -- at most one corner
  finish : TropicalUpperHalfPlane
  monotone_x : ∀ p q, p ≤ q → ...
  monotone_y : ...

/-- Tropical Möbius transformation: PSL(2, ℝ_trop) element.
    A 2×2 matrix over ℝ with tropical determinant condition:
    max(a+d, b+c) = 0 (the tropical unit).
    Bridge: connects group theory to post-quantum lattice isometries. -/
structure TropicalMöbiusMatrix where
  a b c d : ℝ
  tropical_det : max (a + d) (b + c) = 0  -- tropical det = ⊕(a⊗d, b⊗c) = 0

/-- The extension of a boundary Möbius transformation to a bulk isometry.
    This is the tropical conformal extension: the key step establishing
    that boundary symmetries determine bulk geometry (holographic principle). -/
structure ConformalExtension (T : TropicalMöbiusMatrix) where
  bulk_action : TropicalUpperHalfPlane → TropicalUpperHalfPlane
  is_isometry : ∀ P Q, tropicalHyperbolicDist (bulk_action P) (bulk_action Q)
                  = tropicalHyperbolicDist P Q
  boundary_agreement : ∀ x : ℝ, (bulk_action ⟨x, 1, by linarith⟩).x = tropicalMöbiusAction T x

/-- Hecke eigenfunction on the Berggren boundary: discrete analog of CFT primary.
    Bridge: connects number theory (Pythagorean Hecke theory) to quantum mechanics (normal modes). -/
structure BerggrenEigenfunction where
  toFun : BerggrenTriple → ℝ
  hecke_eigenvalue : ℕ
  eigen_eq : ∀ T : HeckeOperator, T ▷ toFun = hecke_eigenvalue • toFun

/-- Geodesic normal mode in H_trop: bulk dual of a boundary eigenfunction.
    The tropical analog of a bulk field mode in AdS/CFT. -/
structure GeodesicNormalMode where
  frequency : ℝ
  support_geodesic : TropicalGeodesic
  amplitude : TropicalUpperHalfPlane → ℝ
  laplacian_eigenvalue : ℝ
  eigen_eq : tropicalLaplacian amplitude = laplacian_eigenvalue • amplitude

end TropicalUpperHalfPlane
```

---

### II. THEOREM SEQUENCE (10+ theorems, ZERO sorries, diverse tactics)

#### A. Tropical Hyperbolic Geometry (CAT(0) Structure)

**Theorem 1: `tropicalHyperbolicDist_metricSpace`**
```lean
/-- H_trop with the max-plus hyperbolic metric is a metric space.
    Proof strategy: direct verification of three axioms.
    (1) d(P,P) = 0: both numerator terms are |0| = 0, so max = 0.
    (2) d(P,Q) = d(Q,P): symmetry of |·| and min.
    (3) Triangle inequality: key step uses that max(|x_P-x_Q|, |y_P-y_Q|)/min(y_P,y_Q)
        ≤ max(|x_P-x_R|,|y_P-y_R|)/min(y_P,y_R) + max(|x_R-x_Q|,|y_R-y_Q|)/min(y_R,y_Q).
        Split into cases on whether min(y_P,y_Q) = y_P or y_Q.
        Use `linarith` for the arithmetic and `omega` for integer sub-cases. -/
theorem tropicalHyperbolicDist_metricSpace :
    MetricSpace TropicalUpperHalfPlane := ...
```

**Theorem 2: `tropicalHyperbolic_properSpace`**
```lean
/-- H_trop is a proper metric space: closed balls are compact.
    Key insight: the tropical ball B(P,r) = {Q : max(|x_P-x_Q|,|y_P-y_Q|)/min(y_P,y_Q) ≤ r}
    is a rectangle [x_P - r·min_y, x_P + r·min_y] × [y_P/(1+r), y_P·(1+r)].
    This is a closed bounded set in ℝ², hence compact by Heine-Borel.
    Use `IsCompact.closedBall` and `bounded_iff_forall_norm_le`. -/
theorem tropicalHyperbolic_properSpace :
    ProperSpace TropicalUpperHalfPlane := ...
```

**Theorem 3: `tropicalGeodesicExistence`**
```lean
/-- For every pair of points P, Q in H_trop, there exists a tropical geodesic
    connecting them with length = tropicalHyperbolicDist P Q.
    The geodesic has at most one bend point. Two cases:
    Case 1: |x_P - x_Q| ≥ |y_P - y_Q|. Geodesic is horizontal-then-vertical.
    Case 2: |x_P - x_Q| < |y_P - y_Q|. Geodesic is vertical-then-horizontal.
    The bend point is at the transition. Use `rcases` on the comparison.
    Bridge: connects geodesic geometry to tropical convexity (ML optimization). -/
theorem tropicalGeodesicExistence (P Q : TropicalUpperHalfPlane) :
    ∃ γ : TropicalGeodesic, γ.start = P ∧ γ.finish = Q ∧
      γ.length = tropicalHyperbolicDist P Q := ...
```

**Theorem 4: `catZeroTropicalHalfPlane`**
```lean
/-- H_trop is a CAT(0) space: geodesic triangles are no fatter than Euclidean ones.
    Proof strategy: Since geodesics are piecewise-linear with at most one bend,
    any geodesic triangle has at most 3 bend points. Show that the comparison
    triangle in ℝ² (with same side lengths) is always at least as "fat".
    Key lemma: the tropical geodesic between two points lies in the tropical
    convex hull of {P, Q} (a rectangle), which is CAT(0) by `convex_cat_zero`.
    Use `by_contra` to assume violation, derive contradiction via `linarith`.
    Computational bound: the CAT(0) comparison deficit is O(d³) for small d.
    Bridge: connects geometric group theory to quantum gravity (AdS is CAT(-1),
    tropical AdS is CAT(0) — the flat limit). -/
theorem catZeroTropicalHalfPlane :
    CAT0Space TropicalUpperHalfPlane := ...
```

**Theorem 5: `tropicalGeodesicUniqueness`**
```lean
/-- Tropical geodesics are unique when |x_P - x_Q| ≠ |y_P - y_Q|.
    When |x_P - x_Q| = |y_P - y_Q| (measure-zero case), there are exactly two
    geodesics (horizontal-first or vertical-first).
    Proof: by case analysis on the comparison. The unique bend point is determined
    by which coordinate difference dominates. Use `rcases` with `le_total`.
    Bridge: connects Riemannian geometry to tropical uniqueness (cryptographic
    collision resistance — two distinct inputs yield distinct geodesics). -/
theorem tropicalGeodesicUniqueness (P Q : TropicalUpperHalfPlane)
    (h : |P.x - Q.x| ≠ |P.y - Q.y|) :
    ∃! γ : TropicalGeodesic, γ.start = P ∧ γ.finish = Q ∧
      γ.length = tropicalHyperbolicDist P Q := ...
```

#### B. Conformal Extension (Boundary-to-Bulk Isometry)

**Theorem 6: `tropicalMöbiusBoundaryAction`**
```lean
/-- Tropical Möbius matrices act on the boundary ∂H_trop = ℝ ∪ {∞}.
    The action is: T(x) = max(a+x, b) - max(c+x, d) when x ∈ ℝ.
    (This is the tropical version of (ax+b)/(cx+d).)
    Proof that this is well-defined: tropical det = max(a+d, b+c) = 0 ensures
    no degenerate (constant) maps. Use `by_contra` and `omega`.
    Bridge: connects modular forms to tropical signal processing. -/
theorem tropicalMöbiusBoundaryAction (T : TropicalMöbiusMatrix) (x : ℝ) :
    ∃ y : ℝ, y = max (T.a + x) T.b - max (T.c + x) T.d := ...
```

**Theorem 7: `conformalExtensionIsometry`**
```lean
/-- Every boundary Möbius transformation extends uniquely to a bulk isometry.
    The extension acts by: Ĝ_T(P) = (T(P.x), |T(P.y)|) where T acts on each
    coordinate via the tropical fractional linear formula.
    Key proof step: show d_trop(Ĝ_T(P), Ĝ_T(Q)) = d_trop(P,Q) by unfolding
    the metric definition and using the tropical determinant condition.
    Strategy A (direct): Compute both sides, use max(a+d, b+c)=0 to simplify.
    Strategy B (invariance): Show Ĝ_T preserves both max(|Δx|, |Δy|) and min(y₁,y₂).
    Strategy A is more promising because it directly uses the algebraic constraint.
    Use `field_simp` for the rational arithmetic and `linarith` for inequalities.
    Bridge: connects conformal field theory to lattice isometry groups
    (post-quantum cryptography — isometries of H_trop form a lattice-based group). -/
theorem conformalExtensionIsometry (T : TropicalMöbiusMatrix) :
    ∃ G : ConformalExtension T, ∀ P Q : TropicalUpperHalfPlane,
      tropicalHyperbolicDist (G.bulk_action P) (G.bulk_action Q)
        = tropicalHyperbolicDist P Q := ...
```

**Theorem 8: `extensionHomomorphismInjective`**
```lean
/-- The extension map T ↦ Ĝ_T is an injective group homomorphism
    PSL(2, ℝ_trop) ↪ Isom(H_trop).
    Proof of homomorphism: Ĝ_{T₁∘T₂} = Ĝ_{T₁} ∘ Ĝ_{T₂} by direct computation
    of the tropical matrix product (max-plus multiplication).
    Proof of injectivity: if Ĝ_T = id, then T acts trivially on boundary points,
    forcing T = ±I in PSL(2,ℝ_trop). Use `by_contra` and `omega`.
    Bridge: connects representation theory to cryptographic key injection
    (injective homomorphism = no key collisions for lattice-based schemes). -/
theorem extensionHomomorphismInjective :
    Function.Injective (fun T : TropicalMöbiusMatrix => (conformalExtensionIsometry T).choose.bulk_action) ∧
    ∀ T₁ T₂, conformalExtensionIsometry (T₁ * T₂) =
      conformalExtensionIsometry T₁ ∘ conformalExtensionIsometry T₂ := ...
```

#### C. Berggren-Satake Correspondence (Holographic Duality)

**Theorem 9: `berggrenEquivariantBoundaryEmbedding`**
```lean
/-- The Berggren tree embeds PSL(2,ℤ)-equivariantly into ∂H_trop via (a,b,c) ↦ a/b.
    Proof: (1) The map is well-defined: a/b is rational (Pythagorean triple property).
    (2) Equivariance: for γ ∈ PSL(2,ℤ), γ · (a/b) = (γa)/(γb) follows from
    the Berggren matrix action being a restriction of PSL(2,ℤ).
    (3) Injectivity: distinct triples have distinct ratios a/b (use `by_contra`
    and the Pythagorean equation a² + b² = c²).
    Key lemma: `berggren_ratio_injective` — if a₁/b₁ = a₂/b₂ for primitive
    Pythagorean triples, then (a₁,b₁,c₁) = (a₂,b₂,c₂).
    Computational bound: the embedding has O(1) Lipschitz constant with respect
    to the Stern-Brocot metric on the Berggren tree.
    Bridge: connects number theory (Pythagorean triples) to holographic duality
    (boundary = Berggren tree, bulk = H_trop). -/
theorem berggrenEquivariantBoundaryEmbedding :
    ∃ φ : BerggrenTriple → ℝ,
      Function.Injective φ ∧
      ∀ (t : BerggrenTriple) (γ : Matrix (Fin 2) (Fin 2) ℤ),
        γ ∈ PSL2ℤ → φ (berggrenAction γ t) = tropicalMöbiusAction (γ.map (· : ℝ)) (φ t) := ...
```

**Theorem 10: `satakeOperatorStateCorrespondence`**
```lean
/-- The tropical Satake isomorphism induces a bijection between Hecke eigenfunctions
    on the Berggren boundary and geodesic normal modes in H_trop.
    This is the tropical operator-state correspondence: the FIRST rigorous
    mathematical model of AdS/CFT holographic duality on a discrete algebraic structure.
    Proof strategy:
    Step 1: Define the tropical Satake transform S : BerggrenEigenfunction → GeodesicNormalMode.
    Step 2: Show S is well-defined (Hecke eigenfunction → Laplacian eigenfunction).
    Step 3: Construct the inverse S⁻¹ : GeodesicNormalMode → BerggrenEigenfunction
    by restricting to the boundary and verifying the Hecke eigenvalue equation.
    Step 4: Show S ∘ S⁻¹ = id and S⁻¹ ∘ S = id using the boundary-bulk correspondence.
    Key lemma: `tropicalSatakePreservesSpectrum` — the Hecke eigenvalue λ maps to
    the Laplacian eigenvalue λ² (spectral doubling, analogous to AdS/CFT dimension matching).
    Use `induction` on the Berggren tree structure and `field_simp` for spectral relations.
    Bridge: connects quantum field theory (AdS/CFT) to tropical geometry (tropical Satake).
    Application: tropical_holographic_hash — a collision-resistant hash function based
    on the injectivity of the Satake correspondence. -/
theorem satakeOperatorStateCorrespondence :
    ∃ (S : BerggrenEigenfunction → GeodesicNormalMode)
      (Sinv : GeodesicNormalMode → BerggrenEigenfunction),
      Function.Bijective S ∧
      ∀ f : BerggrenEigenfunction, Sinv (S f) = f ∧
      ∀ g : GeodesicNormalMode, S (Sinv g) = g ∧
      S f |>.laplacian_eigenvalue = (f.hecke_eigenvalue : ℝ)² := ...
```

**Theorem 11: `tropicalHolographicEntropyBound`**
```lean
/-- The holographic entropy bound for the tropical upper half-plane:
    for any compact region R ⊆ H_trop with boundary ∂R ∩ ∂H_trop = B,
    the tropical area of R is bounded by the tropical length of B.
    Specifically: area_trop(R) ≤ length_trop(B)² / (4π).
    This is the tropical analog of the Bekenstein bound in quantum gravity.
    Proof: by the CAT(0) property and the isoperimetric inequality.
    The tropical area of a rectangle [x₁,x₂] × [y₁,y₂] is (x₂-x₁)·log(y₂/y₁).
    The boundary length is max(x₂-x₁, y₂-y₁)/min(y₁,y₂).
    Use `linarith` for the isoperimetric comparison.
    Computational bound: the entropy ratio area/length² is Θ(1/log(y)) for thin regions.
    Bridge: connects quantum thermodynamics (Bekenstein bound) to tropical geometry.
    Application: certified_thermodynamic_bound for quantum error correction codes. -/
theorem tropicalHolographicEntropyBound (R : Set TropicalUpperHalfPlane)
    (hR : IsCompact R) (hR_conv : Convex ℝ R) :
    tropicalArea R ≤ (tropicalBoundaryLength (R ∩ ∂TropicalH_trop))² / (4 * π) := ...
```

**Theorem 12: `berggrenSpectralGap`**
```lean
/-- The Berggren tree has a spectral gap: the smallest non-trivial Hecke eigenvalue
    is ≥ 2. This implies exponential decay of correlations on the boundary,
    the tropical analog of the mass gap in quantum field theory.
    Proof: by induction on the Berggren tree depth, using the recursive structure
    of Hecke operators. The key step is showing that T_p acts with eigenvalue ≥ p+1
    for any prime p, via the Pythagorean constraint.
    Computational bound: the spectral gap is exactly 2 (achieved by T₂).
    Use `induction` with `berggrenTreeDepth` as the measure.
    Bridge: connects quantum field theory (mass gap) to number theory (Hecke spectrum).
    Application: post_quantum_spectral_gap for lattice-based security parameters. -/
theorem berggrenSpectralGap :
    ∃ λ₀ : ℕ, λ₀ = 2 ∧
      ∀ f : BerggrenEigenfunction, f.hecke_eigenvalue ≠ 0 → f.hecke_eigenvalue ≥ λ₀ := ...
```

---

### III. PROOF STRATEGIES (Multiple paths per theorem)

For **`catZeroTropicalHalfPlane`**:
- **Strategy A (Convex decomposition)**: Decompose any geodesic triangle into at most 4 convex sub-triangles, each of which is contained in a coordinate rectangle. Rectangles are CAT(0) in the tropical metric. Glue using Reshetnyak's gluing theorem. *Most promising*: the tropical structure makes rectangles natural building blocks.
- **Strategy B (Direct comparison)**: Directly verify the CN inequality of Bruhat-Tits for all triples of points. Reduce to checking finitely many cases by the piecewise-linear nature of geodesics.
- **Strategy C (Gromov link condition)**: Verify that the space has non-positive curvature in the sense of Alexandrov by checking the link condition at every point. The only singular points are the bend points of geodesics, where the link is a circle of length ≥ 2π.

For **`satakeOperatorStateCorrespondence`**:
- **Strategy A (Constructive)**: Define S explicitly via a tropical integral transform (tropical version of the Helgason-Fourier transform). Prove bijectivity by constructing S⁻¹ via boundary restriction. *Most promising*: this mirrors the classical Satake isomorphism construction.
- **Strategy B (Categorical)**: Show that the category of Hecke eigenfunctions and the category of geodesic normal modes are equivalent via a tropical functor. Prove essential surjectivity and fully-faithfulness.
- **Strategy C (Spectral matching)**: Prove that the Hecke spectrum and the Laplacian spectrum are in bijection (spectral doubling λ → λ²), then lift this to an eigenfunction bijection using multiplicity-one results.

---

### IV. SIGNIFICANCE AND APPLICATIONS

This work establishes the **first rigorous mathematical model of holographic duality on a discrete algebraic structure**. The Berggren tree — a number-theoretic object encoding Pythagorean triples — becomes the "conformal boundary" of a tropical analog of Anti-de Sitter space. The implications are:

1. **Quantum gravity**: The tropical holographic entropy bound (Theorem 11) provides a discrete, computable analog of the Bekenstein bound, opening the door to *certified thermodynamic bounds* for quantum error correction.

2. **Post-quantum cryptography**: The injective group homomorphism PSL(2,ℝ_trop) ↪ Isom(H_trop) (Theorem 8) provides a *collision-resistant embedding* that can serve as the foundation for tropical lattice-based hash functions. The spectral gap (Theorem 12) gives explicit security parameters.

3. **Certified robustness in ML**: The CAT(0) structure (Theorem 4) and Lipschitz bounds on the Satake transform provide *certified robustness guarantees* for neural network classifiers based on tropical geometry, with explicit O(d/log(y)) bounds on perturbation radii.

4. **Tropical Langlands program**: This work bridges the tropical Satake isomorphism (already in the catalog) to the full operator-state correspondence, advancing the tropical Langlands program toward a complete duality theory.

---

### V. DELIVERABLES

Produce the following files, each 500+ lines with 20+ theorems:

1. **`TropicalUpperHalfPlane.lean`**: The metric space, geodesic structure, CAT(0) proof, properness. (Theorems 1-5)
2. **`TropicalConformalExtension.lean`**: Möbius transformations, boundary action, isometric extension, injective homomorphism. (Theorems 6-8)
3. **`BerggrenSatakeCorrespondence.lean`**: Equivariant embedding, Satake transform, operator-state bijection, spectral gap, holographic entropy bound. (Theorems 9-12)
4. **`TropicalHolographicApplications.lean`**: Cryptographic hash from Satake injectivity, certified robustness bounds from CAT(0), quantum thermodynamic bounds. (Application theorems)

---

### VI. FUTURE DIRECTIONS (Aristotle MUST produce FUTURE_DIRECTIONS.md)

After completing the above, produce a `FUTURE_DIRECTIONS.md` with 3-5 concrete breakthrough-level next steps, such as:
1. Tropical AdS₃/CFT₂: Extend from H_trop (2D) to the tropical 3D anti-de Sitter space and prove the full Ryu-Takayanagi formula for entanglement entropy.
2. Tropical modular forms: Define tropical analogs of modular forms on H_trop and prove they satisfy a tropical version of the modularity condition under PSL(2,ℤ_trop).
3. Post-quantum tropical hash: Implement the Satake-correspondence-based hash function and prove Ω(2^n) collision resistance.
4. Tropical quantum error correction: Use the holographic entropy bound to construct explicit quantum error correction codes with certified distance bounds.
5. Tropical Langlands for GL_n: Extend the Satake operator-state correspondence from GL₂ to GL_n, establishing the full tropical Langlands duality.

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

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


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
            Open the field of tropical holographic geometry by proving three foundational theorems connecting the Berggren tree (boundary) to the tropical upper half-plane (bulk). (1) TROPICAL UPPER HALF-PLANE: Define H_trop = {(x,y) : x ∈ ℝ_trop, y ∈ ℝ_{>0}} with the max-plus hyperbolic metric d_trop(P,Q) = max(|x_P - x_Q|, |y_P - y_Q|) / min(y_P, y_Q), and prove it is a proper CAT(0) geodesic metric space with piecewise-linear geodesics (tropical semicircles). (2) CONFORMAL EXTENSION: Prove that every tropical Möbius transformation T ∈ PSL(2,ℝ_trop) acting on the boundary ∂H_trop = ℝ_trop ∪ {∞} extends uniquely to an isometry Ĝ_T of H_trop, and the extension map T ↦ Ĝ_T is an injective group homomorphism PSL(2,ℝ_trop) ↪ Isom(H_trop). (3) BERGGREN-SATAKE CORRESPONDENCE: Prove that the Berggren tree embeds PSL(2,ℤ)-equivariantly into ∂H_trop via (a,b,c) ↦ a/b, and the tropical Satake isomorphism induces a bijection between Hecke eigenfunctions on the Berggren boundary and geodesic normal modes in H_trop, establishing the tropical operator-state correspondence — the first rigorous mathematical model of AdS/CFT holographic duality on a discrete algebraic structure.

            ### Precise Mathematical Framing
            Let ℝ_trop = (ℝ ∪ {-∞}, max, +). Define H_trop = {(x,y) ∈ ℝ_trop × ℝ_{>0}} with d_trop((x₁,y₁),(x₂,y₂)) = max(|x₁-x₂|, |y₁-y₂|) / min(y₁,y₂). THEOREM 1 (Tropical Hyperbolic Geometry): (H_trop, d_trop) is a proper geodesic CAT(0) space. Geodesics are piecewise-linear: vertical segments and arcs satisfying max(|x-c|, r) = y (tropical semicircles with center c, radius r). The Gromov boundary of H_trop is ∂H_trop = ℝ_trop ∪ {∞}. THEOREM 2 (Conformal Extension): PSL(2,ℝ_trop) = {x ↦ max(a+x,b) - max(c+x,d) : tropical det = 0} acts on ∂H_trop. Every T extends uniquely to Ĝ_T(x,y) = (T(x), y / max(c+x,d)²) ∈ Isom(H_trop). The extension is an injective homomorphism. THEOREM 3 (Berggren-Satake): The map ι : Berggren → ∂H_trop, (a,b,c) ↦ a/b, is PSL(2,ℤ)-equivariant (Berggren matrix actions ↔ tropical Möbius). The tropical Satake isomorphism S : Ĥ(Berggren) → Geod(H_trop) maps Hecke eigenfunction f_λ to geodesic mode γ_λ with λ(f) = λ(γ), establishing the operator-state correspondence.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_duality_min_to_max` : theorem tropical_duality_min_to_max (a b : ℝ) :
     (file: Tropical/Cryptography/TropicalTrapdoorResearch.lean)
  2. `tropical_interference_min` : theorem tropical_interference_min (S₁ S₂ : ℝ) :
     (file: Physics/Quantum/TropicalFeynman.lean)
  3. `divisor_sum_upper_bound` : theorem divisor_sum_upper_bound (k n : ℕ) (hn : 1 ≤ n) :
     (file: Physics/QuantumE8ModularForms.lean)
  4. `tropical_max_distrib_min` : theorem tropical_max_distrib_min (a b c : ℝ) :
     (file: Speculative/Other/NewTheorems.lean)
  5. `min_max_duality` : theorem min_max_duality (a b : ℝ) : min a b = -(max (-a) (-b)) := by
     (file: Tropical/Core/FutureDirectionsV2.lean)

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



Recent successful concepts: Berggren–Modular Correspondence: Pythagorean Light Cone Geodesics, PSL(2,ℤ) Embedding, and Gaussian Factorization Recovery, Algebraic Neural Architecture: Module-Theoretic Universal Approximation via Prime-Spectral Stratification and Tropical Specialization, Tropical Langlands GL(1): Max-Plus Hecke Eigenfunction Decomposition and Automorphic Correspondence on the Berggren Modular Tree


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

Research domain: Physics
Research mode: formalize
