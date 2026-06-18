# Future Directions: p-adic Langlands and Beyond

## Synthesis

This research cycle established machine-verified foundations for the p-adic Langlands correspondence for GL₂(ℚ_p), formalizing the algebraic structures of (φ,Γ)-modules, Newton polygon slope theory, weak admissibility, and the Colmez functor. The key insight is that the slope gap — the difference s₂ - s₁ between the two Newton slopes — serves as a complete invariant (together with the total slope) for the correspondence, and is preserved by both duality and twisting operations. This invariance provides a structural explanation for why the ordinary-supersingular dichotomy persists across all transformations of the representation.

The most promising cross-domain connection from this cycle is the bridge between **Newton polygon slopes** and **tropical geometry**. The Newton polygon is itself a tropical object: it is the tropicalization of the characteristic polynomial of Frobenius. The slope theory we formalized — with its min/max operations in trianguline parameters, its piecewise-linear structure, and its duality — naturally lives in tropical geometry. This connects to the existing Catalog's extensive tropical infrastructure (`TropicalLanglands.lean`, `TropicalGaloisSolvability.lean`), suggesting a deeper synthesis between p-adic Hodge theory and tropical methods.

Among the directions below, Direction 1 (Tropical Newton Polygons) has the highest breakthrough potential because it would bridge the formalized p-adic slope theory with the Catalog's tropical geometry, creating a new axis of investigation where computational tropical methods could yield insights about p-adic Galois representations.

---

### Direction 1: Tropical Newton Polygons and the p-adic Correspondence

**Conjecture**: The Newton polygon functor (from φ-modules to piecewise-linear functions) factors through the tropicalization map, yielding a commutative diagram:

```
{φ-modules} --Newton--> {convex PL functions on [0,n]}
     |                           |
  trop|                      identity|
     v                           v
{tropical modules} --slopes--> {convex PL functions on [0,n]}
```

Concretely: for any rank n φ-module D, the Newton polygon NP(D) equals the tropical eigenvalue polygon of the tropicalization trop(Φ_D) of the Frobenius matrix.

**Test**: Compute tropical eigenvalues of explicit 3×3 Frobenius matrices over Z_p and verify they match the classical Newton polygon slopes. A counterexample with a non-generic Frobenius matrix (e.g., one with repeated tropical eigenvalues but distinct classical slopes) would refute the conjecture.

**Impact**: If true, this would provide a purely combinatorial route to computing Newton polygons, bypassing the need for p-adic linear algebra. If false, the precise failure conditions would reveal which aspects of p-adic geometry resist tropicalization.

**Catalog References**: `Bridges/TropicalLanglands.lean`, `Bridges/TropicalGaloisSolvability.lean`, `Bridges/PadicLanglandsGL2.lean`

**Proof Strategy**: (1) Formalize tropical linear algebra (tropical eigenvalues = optimal assignment problem). (2) Formalize the classical Newton polygon as a function ℕ → ℚ. (3) Prove the commutation for rank 1 (trivial) and rank 2 (using our Rank2Slopes). (4) Attempt rank 3 by case analysis on the tropical matroid structure.

**Domain Bridges**: p-adic Hodge Theory ↔ Tropical Geometry, Number Theory ↔ Combinatorial Optimization

**Lineage**: Builds on this cycle's `Rank2Slopes` formalization and the existing `TropicalLanglands.lean` in the Catalog.

**Ambition**: grand_challenge

---

### Direction 2: Formal Breuil-Mézard Multiplicities for GL₂

**Conjecture**: For crystalline representations of GL₂(ℚ_p) with weight k and lower Frobenius slope a (where 0 ≤ a ≤ (k-1)/2), the multiplicity of the corresponding component in the special fiber of the Galois deformation ring equals exactly k - 1 - 2a. Furthermore, the total multiplicity ∑_{a=0}^{⌊(k-1)/2⌋} (k-1-2a) equals ⌈(k-1)/2⌉² for even k-1 and ⌊(k-1)/2⌋ · ⌈(k-1)/2⌉ for odd k-1.

**Test**: Verify the total multiplicity formula for k = 2, 3, ..., 20 computationally. Check whether the formula extends to non-crystalline (semi-stable, trianguline) cases by computing deformation ring components explicitly for p = 2, 3, 5 and k ≤ 6.

**Impact**: A fully formalized Breuil-Mézard conjecture for GL₂ would be a landmark in formal number theory, connecting deformation theory to representation theory with machine-checked certainty.

**Catalog References**: `Bridges/PadicLanglandsGL2.lean` (this cycle's `crystallineMultiplicity`)

**Proof Strategy**: (1) Define Galois deformation rings formally as quotients of power series rings. (2) Compute special fiber components using Kisin's classification of finite flat group schemes. (3) Relate component multiplicities to representation-theoretic data using Serre weights. (4) Prove the linear formula k-1-2a by induction on k.

**Domain Bridges**: Algebraic Geometry ↔ Representation Theory, Deformation Theory ↔ p-adic Hodge Theory

**Lineage**: Extends this cycle's `crystallineMultiplicity` definition and `WeightData` formalization.

**Ambition**: grand_challenge

---

### Direction 3: Exactness of the Colmez Functor via (φ,Γ)-Module Extensions

**Conjecture**: The space Ext¹ in the category of (φ,Γ)-modules of rank 2 over the Robba ring is one-dimensional when the two rank 1 quotients have distinct slopes (non-split triangulation), and zero-dimensional when they have equal slopes (the supersingular locus). This exactly matches the dimension of the H¹ of the associated Galois cohomology group.

**Test**: Explicitly compute Ext¹ for the (φ,Γ)-modules D(δ₁) and D(δ₂) where δ₁, δ₂ are characters of ℚ_p× with slopes 0 and 1 (the ordinary weight 2 case). The computation reduces to solving a system of linear equations over the Robba ring.

**Impact**: A formal proof of the Ext dimension would give the first machine-verified result about the structure of the p-adic Langlands correspondence beyond slope data, entering the realm of actual representation theory.

**Catalog References**: `Bridges/PadicLanglandsGL2.lean` (this cycle's `PhiGammaModule`, `TriangulineParam`)

**Proof Strategy**: (1) Define Ext¹ for (φ,Γ)-modules as equivalence classes of extensions. (2) Show that the connecting homomorphism in the long exact sequence computes Ext¹. (3) Use the explicit description of rank 1 (φ,Γ)-modules to reduce to cohomology computation. (4) Apply Herr's theorem relating (φ,Γ)-cohomology to Galois cohomology.

**Domain Bridges**: Homological Algebra ↔ p-adic Hodge Theory, Category Theory ↔ Number Theory

**Lineage**: Extends this cycle's `SlopeExactSeq` and `PhiGammaModule` formalizations.

**Ambition**: extension

---

### Direction 4: Slopes and the Eigencurve

**Conjecture**: The Coleman-Mazur eigencurve, viewed as a rigid analytic curve parameterizing overconvergent modular eigenforms, has the property that the slope map (sending an eigenform to its U_p slope) is locally constant on connected components away from the boundary of weight space. Equivalently: the slopes of the Newton polygon are locally constant in families.

**Test**: For p = 5, compute the slopes of U_p on the space of overconvergent modular forms of weight k for k = 2, 4, 6, ..., 50. Verify that slopes (as elements of ℚ) cluster into discrete values that persist across weights in the same connected component.

**Impact**: Local constancy of slopes would provide a p-adic analogue of the "spectral gap" phenomenon in classical harmonic analysis, with applications to the construction of p-adic L-functions.

**Catalog References**: `Bridges/PadicLanglandsGL2.lean`, `Algebra/ArtinConjecture.lean`

**Proof Strategy**: (1) Formalize weight space as the rigid analytic space Hom(ℤ_p×, G_m). (2) Define the eigencurve as a rigid analytic curve over weight space. (3) Use Buzzard's slope bounds and the theory of overconvergent modular symbols. (4) Prove local constancy using the Fredholm determinant of U_p on overconvergent forms.

**Domain Bridges**: Rigid Analytic Geometry ↔ Spectral Theory, p-adic Analysis ↔ Automorphic Forms

**Lineage**: Builds on this cycle's `WeightData` and `Rank2Slopes` formalizations.

**Ambition**: extension

---

### Direction 5: Operadic Structure of (φ,Γ)-Module Categories

**Conjecture**: The category of (φ,Γ)-modules admits an operadic enrichment where the n-ary operations correspond to n-fold tensor products followed by projection to irreducible components, and this operadic structure is compatible with the Colmez functor. Specifically, the composition maps in the operad recover the Clebsch-Gordan decomposition for tensor products of GL₂ representations under the correspondence.

**Test**: For rank 2 (φ,Γ)-modules with slopes (0,1) and (1,2), compute the tensor product and verify that its slope decomposition matches the Clebsch-Gordan decomposition of the corresponding GL₂ representations.

**Impact**: An operadic framework would provide a systematic approach to the n-point correspondence, generalizing the Colmez functor from individual representations to their interactions.

**Catalog References**: `Bridges/OperadicTropicalization.lean`, `Bridges/PadicLanglandsGL2.lean`

**Proof Strategy**: (1) Define the tensor product of (φ,Γ)-modules (Frobenius on D₁ ⊗ D₂ is Φ₁ ⊗ Φ₂). (2) Compute slope data of tensor products (slopes add pairwise). (3) Define the operadic composition as tensor-then-project. (4) Verify compatibility with GL₂ representation theory using the Colmez functor axioms.

**Domain Bridges**: Operad Theory ↔ p-adic Hodge Theory, Category Theory ↔ Representation Theory

**Lineage**: Connects this cycle's `PhiGammaModule` with the Catalog's operadic infrastructure (`OperadicTropicalization.lean`).

**Ambition**: extension
