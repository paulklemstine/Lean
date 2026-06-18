# Future Directions

## Synthesis

This research cycle established the **category EMLCat** of EML-computable maps, proving it has finite products, currying, and a strict depth hierarchy. The most significant finding is the interplay between the *categorical* structure (products, composition) and the *complexity-theoretic* structure (depth, node count, the size-depth inequality). The depth hierarchy theorem — that iterated exponentials have depth exactly k — provides the first formal evidence that EML computation has genuine complexity stratification, analogous to circuit depth separation in Boolean complexity theory.

The most promising cross-domain connection is between the **log-affine subcategory** and **tropical geometry**. Log-affine maps, which form a multiplicative monoid, become affine maps under the logarithm functor. This is precisely the transition from "ordinary" to "tropical" geometry, where multiplication becomes addition and addition becomes max. The existing catalog results on EML closure operators (`eml_closure_closed_under_comp`, `hardyLevel_closed_under_eml`) provide the compositional backbone, while the new categorical framework gives it semantic content.

The highest breakthrough potential lies in Direction 1 (depth separation lower bounds), which would transform the upper-bound hierarchy result into a true separation theorem — a result of circuit-complexity-level significance for continuous computation.

---

### Direction 1: EML Depth Separation Lower Bounds

**Conjecture**: For every k ≥ 1, there is no ScalarEMLTree of depth < k that computes the function x ↦ exp^[k](x) = exp(exp(...exp(x)...)). That is, the canonical iterExpTree' construction is depth-optimal.

**Test**: Fix k = 2. Enumerate all EML trees of depth ≤ 1 in one variable (these are trees built from coord, const, with at most one layer of add/mul/exp/log). Show that none of them equal x ↦ exp(exp(x)) on all of ℝ. This can be done by computing Taylor coefficients or by evaluating at specific points and checking for contradictions.

**Impact**: A positive answer would establish a **strict depth hierarchy** for continuous computation, analogous to the AC⁰ vs TC⁰ separation in Boolean circuits. This would be a fundamental result in computational complexity for real-valued functions. If false (i.e., if there are clever depth-reducing identities), that would reveal unexpected algebraic structure in the exp/log system.

**Catalog References**: `EML.EMLCategoryFull.lean` (iterExpTree', depth hierarchy), `EML.CategoryDefs.lean` (ScalarEML)

**Proof Strategy**: 
1. Classify all depth-1 ScalarEMLTree in 1 variable: they are of the form op(coord 0) or op(const c) or op₂(coord 0, const c), etc.
2. Show each such tree defines a function in a specific analytic class (e.g., x ↦ a·exp(x) + b is the most complex depth-1 function with one exp).
3. Prove that exp(exp(x)) is not in this class by comparing growth rates or Taylor coefficients.

**Domain Bridges**: EML complexity <-> Boolean circuit complexity (depth hierarchy analogy); EML depth <-> neural network depth efficiency (practical implications for architecture design)

**Lineage**: Builds on `iterExpTree_depth'` and `ScalarEMLTree.depth_lt_nodeCount'` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: The Tropical Limit Functor on EMLCat

**Conjecture**: The "tropical limit" construction — replacing log-sum-exp with max — defines a functor from a subcategory of EMLCat to the category of tropical polynomial maps (piecewise-linear maps with integer slopes). Specifically, for any family of EML maps fₜ(x) = t⁻¹ · log(∑ exp(t · gᵢ(x))), the limit as t → ∞ is max(g₁(x),...,gₙ(x)), and this limit operation preserves composition.

**Test**: 
1. Verify computationally: for gᵢ(x) = aᵢx + bᵢ, compute fₜ(x) for increasing t and check convergence to max(aᵢx + bᵢ).
2. Prove in Lean: if g₁, g₂ are affine (hence EML-computable), then lim_{t→∞} t⁻¹ log(exp(t·g₁(x)) + exp(t·g₂(x))) = max(g₁(x), g₂(x)) pointwise.

**Impact**: This would formalize the deep connection between smooth EML computation and tropical geometry, providing a categorical explanation for why neural networks with softmax activations approximate piecewise-linear classifiers. It would also connect the EML catalog to the Tropical domain catalog.

**Catalog References**: `EML.EMLCategoryFull.lean` (category structure), `Tropical/` domain (tropical semiring), `EML.MaxPlusStoneWeierstrass.lean` (max-plus approximation)

**Proof Strategy**: Use dominated convergence or direct epsilon-delta analysis. The key lemma is that log(exp(a) + exp(b)) = max(a,b) + log(1 + exp(-|a-b|)), and the error term vanishes as the arguments are scaled by t → ∞.

**Domain Bridges**: EML <-> Tropical geometry (tropicalization functor); smooth computation <-> piecewise-linear computation (neural network approximation theory)

**Lineage**: Builds on `logAffine_log_is_affine'` (log functor) and the log-affine multiplicative closure from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: EML Complexity Functor

**Conjecture**: Define the *EML complexity* of a vector map f : ℝⁿ → ℝᵐ as the minimum total node count over all derivation trees. Then complexity is sub-multiplicative under composition: C(g ∘ f) ≤ C(g) · C(f). Furthermore, the complexity function defines a functor from EMLCat to (ℕ, ≤) (the poset of natural numbers) that is lax monoidal with respect to the product structure.

**Test**: 
1. Verify computationally for specific maps: compute C(f), C(g), C(g ∘ f) for small examples.
2. Prove the sub-multiplicativity bound using the `ScalarEMLTree.subst` construction from this cycle.

**Impact**: A complexity functor would give EMLCat the structure of a "resource category" where morphisms carry quantitative cost information. This connects to resource-sensitive type theory and the semantics of complexity-bounded computation.

**Catalog References**: `EML.EMLCategoryFull.lean` (ScalarEMLTree.subst, nodeCount), `Computation.PadicValuationDepth.lean` (ValuationDepthMeasure — analogous complexity measure)

**Proof Strategy**: Use ScalarEMLTree.subst to compose trees. In the worst case, each coordinate reference in g's tree is replaced by a copy of the corresponding fᵢ tree, giving nodeCount(g ∘ f) ≤ nodeCount(g) · max(nodeCount(fᵢ)). The sub-multiplicativity bound C(g ∘ f) ≤ C(g) · C(f) follows by optimizing over tree choices.

**Domain Bridges**: EML complexity <-> algebraic circuit complexity; resource categories <-> linear logic (Girard's resource management)

**Lineage**: Builds on ScalarEMLTree.subst and the nodeCount/depth measures from this cycle.

**Ambition**: extension

---

### Direction 4: EML Exponential Approximation via Finite-Complexity Slices

**Conjecture**: For each complexity bound B ∈ ℕ, the set EML≤B of EML maps ℝⁿ → ℝᵐ with node count ≤ B forms a finite-dimensional manifold (with singularities at parameter boundaries). The dimension of this manifold grows polynomially in B and n, and the union ∪_B EML≤B is dense in C(K, ℝᵐ) for compact K ⊂ ℝⁿ.

**Test**: 
1. For n=m=1, B=3: enumerate all ScalarEMLTree with ≤ 3 nodes. Count the continuous parameters (constants). This gives the dimension of EML≤3.
2. Check density: for specific continuous f ∈ C([0,1], ℝ), find EML≤B approximations for increasing B.

**Impact**: This would give EML the flavor of an "approximation theory" with explicit parameter counting — analogous to how neural networks of width w have O(w²) parameters. It would provide the finite-dimensional approximation to the exponential object that EMLCat's non-Cartesian-closure prevents from existing exactly.

**Catalog References**: `EML.EMLCategoryFull.lean` (ScalarEMLTree, nodeCount), `EML.StoneWeierstrassApprox.lean` (density results), `EML.VecEML.lean` (vector EML density)

**Proof Strategy**: 
1. Count parameters: each tree topology has a fixed number of constant nodes, each contributing one real parameter. The number of tree topologies with ≤ B nodes is a Catalan-like number.
2. For density, use the existing Stone-Weierstrass results for EML (from the catalog) and show that complexity-bounded subsets eventually cover the space.

**Domain Bridges**: EML parameter counting <-> neural network parameter counting; approximation theory <-> learning theory (VC dimension bounds)

**Lineage**: Builds on the depth hierarchy and non-Cartesian-closure observations from this cycle.

**Ambition**: extension

---

### Direction 5: Hardy Hierarchy Integration

**Conjecture**: The Hardy level of an EML-computable function (as defined in `Speculative.HardyHierarchy.Theorems`) is bounded by the depth of its minimal derivation tree. Specifically, if f has an EML tree of depth d, then f has Hardy level ≤ ω·d (where ω is the first infinite ordinal).

**Test**: Verify for exp^[k]: the k-fold iterated exponential has depth k and Hardy level approximately ω·k (it grows like the Hardy hierarchy at level ω·k).

**Impact**: This would connect EML complexity to the Hardy hierarchy, a fundamental tool in proof theory and computability. It would show that EML depth is a "geometric" measure of growth rate, bridging analytic complexity to ordinal analysis.

**Catalog References**: `Speculative.HardyHierarchy.Theorems` (`hardyLevel_closed_under_eml`), `EML.EMLCategoryFull.lean` (depth hierarchy)

**Proof Strategy**: By induction on tree structure. Constants and projections have Hardy level 0. Addition and multiplication preserve Hardy level. Exp increases Hardy level by ω (since exp grows faster than any polynomial). So depth d with d exp operations gives Hardy level ≤ ω·d.

**Domain Bridges**: EML depth <-> ordinal analysis (Hardy hierarchy); analytic complexity <-> proof-theoretic ordinals (fundamental sequences)

**Lineage**: Builds on `hardyLevel_closed_under_eml` from the existing catalog and the depth hierarchy from this cycle.

**Ambition**: extension
