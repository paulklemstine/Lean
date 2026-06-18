# Future Directions: Tropical Duality and String Theory

## 1. Higher-Dimensional Tropical Torus Duality on ℝⁿ

**Hypothesis:** The one-dimensional T-duality identity Φ_{-ρ}(x) = Φ_ρ(−x) extends to n-dimensional tori via the tropical potential Φ_ρ(x) = min_w (⟨w, x⟩ + ⟨w, ρ⟩) over a winding lattice w ∈ ℤⁿ, with duality acting by the full O(n,n;ℤ) T-duality group.

**Proof Strategy:**
1. Define multi-dimensional tropical potential as min over lattice vectors.
2. Show that the O(n,n;ℤ) action on (momentum, winding) lattice induces a tropical coordinate transformation.
3. Prove involutivity of the generalized duality map.
4. Connect to Buscher rules for background fields (B-field, metric).

**Key Lemmas Needed:**
- Lattice dual pairing compatibility with min-plus structure.
- Tropical analogue of Poisson summation for lattice potentials.
- O(n,n;ℤ) factorization into elementary tropical operations.

**Cross-Domain Connections:** Connects to lattice optimization, integer programming duality, and crystallographic symmetry groups.

**Estimated Difficulty:** Medium-high. The algebraic structure is clear, but managing lattice sums in Lean requires careful Finset/Fintype engineering.

## 2. Tropical Hypersurface Models of Calabi-Yau Degenerations

**Hypothesis:** The corner locus characterization (Theorem C) generalizes to tropical hypersurfaces in ℝⁿ, where the corner locus of a multivariable tropical polynomial f(x₁,...,xₙ) = min_i(⟨aᵢ,x⟩ + bᵢ) is a polyhedral complex of codimension 1. This complex is the tropical analogue of a Calabi-Yau degeneration.

**Proof Strategy:**
1. Define tropical polynomials in n variables as min over affine forms on ℝⁿ.
2. Characterize the corner locus as the set where ≥2 branches tie.
3. Show the corner locus has the structure of a polyhedral complex.
4. Prove balancing condition (tropical analog of being Calabi-Yau).
5. Establish dual subdivision correspondence.

**Key Lemmas Needed:**
- Polyhedral complex structure from branch-tie equations.
- Balancing condition as a tropical divergence-free property.
- Connection between Newton polytope and tropical variety.

**Cross-Domain Connections:** Computational algebraic geometry, phylogenetics (tropical Grassmannian), and optimization (linear programming feasibility regions).

**Estimated Difficulty:** High. Polyhedral geometry in Lean is underdeveloped. May need to build infrastructure for polyhedra and fans.

## 3. Sheaf-Theoretic Tropical Mirror Functors

**Hypothesis:** The tropical Legendre transform defines a contravariant functor between categories of tropical potentials that satisfies the axioms of homological mirror symmetry at the tropical level.

**Proof Strategy:**
1. Define a category TropPot whose objects are piecewise-affine convex functions and morphisms are tropical affine maps.
2. Show the Legendre transform is a contravariant endofunctor.
3. Prove the biconjugation natural isomorphism (extending Theorem B).
4. Construct a tropical Fukaya-type category from corner loci.
5. Establish an equivalence or derived equivalence between TropPot and a coherent sheaf analogue.

**Key Lemmas Needed:**
- Functoriality of Legendre transform under composition.
- Natural transformation from identity to biconjugate.
- Tropical sheaf cohomology on polyhedral complexes.

**Cross-Domain Connections:** Homological algebra, derived categories, persistent homology (TDA), and categorical machine learning.

**Estimated Difficulty:** Very high. Requires substantial category theory infrastructure. Best approached incrementally — first prove functoriality, then naturality.

## 4. Certified Algorithms for Singular-Locus Detection in Tropical Potentials

**Hypothesis:** The branch-tie characterization (Theorem C) yields efficient certified algorithms for detecting all singularities (corners) in n-branch tropical polynomials, with complexity O(n² log n) in one variable and O(n^d) in d variables, with correctness certificates generated from formal proofs.

**Proof Strategy:**
1. Implement corner-detection algorithm with exact rational arithmetic.
2. Generate formal certificates for each detected corner (proof that the branch-tie equation holds).
3. Generate non-corner certificates for intervals between corners (proof that one branch strictly dominates).
4. Prove completeness: every corner is detected.
5. Prove soundness: every detected point is a genuine corner.

**Key Lemmas Needed:**
- Decidability of branch-tie for rational coefficients.
- Completeness of pairwise comparison for convex-position branches.
- Interval monotonicity between consecutive corners.

**Cross-Domain Connections:** Certified computing, neural network verification (ReLU decision boundaries), computational geometry (arrangement of hyperplanes), and real algebraic geometry.

**Estimated Difficulty:** Medium. The algorithmic content is straightforward; the main challenge is interfacing Lean proofs with computational certificates.

## 5. Tropical Wall-Crossing and Cluster Transformations

**Hypothesis:** As the parameter ρ varies continuously, the corner locus of Φ_ρ undergoes topological transitions (wall-crossings) that are governed by tropical cluster transformations, connecting to the Kontsevich-Soibelman wall-crossing formula.

**Proof Strategy:**
1. Define a parameterized family of tropical polynomials Φ_ρ with ρ ∈ ℝⁿ.
2. Characterize the "walls" in parameter space where the combinatorial type of the corner locus changes.
3. Show that crossing a wall induces a piecewise-linear transformation on the branch structure.
4. Prove that these transformations satisfy the pentagon identity (cluster mutation consistency).
5. Connect to tropical scattering diagrams à la Gross-Hacking-Keel-Kontsevich.

**Key Lemmas Needed:**
- Continuity of corner location as function of parameters.
- Classification of codimension-1 events (branch creation/annihilation).
- Cluster algebra identities in the tropical setting.
- Consistency (pentagon) relations for tropical mutations.

**Cross-Domain Connections:** Cluster algebras, Donaldson-Thomas invariants, stability conditions in derived categories, and tropical scattering amplitudes in particle physics.

**Estimated Difficulty:** Very high. This connects to deep open problems in algebraic geometry and mathematical physics. Initial formalization should focus on explicit two-parameter examples.

---

## Priority Ordering

1. **Direction 4** (certified algorithms) — most immediately practical, builds directly on current theorems.
2. **Direction 1** (higher-dimensional tori) — natural mathematical generalization, moderate difficulty.
3. **Direction 2** (tropical hypersurfaces) — significant but needs polyhedral infrastructure.
4. **Direction 5** (wall-crossing) — deep and ambitious, start with examples.
5. **Direction 3** (sheaf-theoretic functors) — longest-term, most abstract.

## Team Research Protocol

For each direction:
1. **Formulate** precise conjectures as Lean theorem statements with `sorry`.
2. **Test** on small examples using `#eval` and computational verification.
3. **Decompose** into 5-10 helper lemmas capturing individual proof steps.
4. **Prove** helper lemmas bottom-up, validating with `lean_build` at each stage.
5. **Synthesize** into main theorems and cross-check against known mathematical results.
6. **Document** with doc-strings and markdown explaining the physics-math-CS dictionary.
7. **Iterate** — each completed direction opens new sub-directions.
