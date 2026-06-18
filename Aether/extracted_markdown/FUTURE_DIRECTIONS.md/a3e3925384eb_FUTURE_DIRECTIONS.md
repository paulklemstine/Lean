# Future Research Directions: Computational Complexity of Recipes

## Synthesis

This cycle established the algebraic foundations of recipe complexity theory, proving that the creation–verification gap behaves as a well-structured linear functional under composition, iteration, and parallelization. The most significant discovery is the tight connection between recipe scheduling and tropical algebra: the max-plus semiring provides both the theoretical framework and the practical algorithms for critical path computation in kitchen scheduling.

The strongest cross-domain connection emerging from this work is the bridge between **tropical algebra and computation theory**. The existing catalog contains substantial tropical infrastructure (`Catalog/Bridges/AlgebraTropicalGeometry/`, `Tropical/`) and computation theory (`Catalog/Computation/`), but no direct bridge between scheduling complexity and tropical semiring structure. Our recipe framework provides exactly this bridge — and it is ripe for generalization. The tropical distributive law (Theorem 5.3) is the algebraic foundation not just of kitchen scheduling but of project management, circuit timing analysis, and network flow optimization.

The direction with the highest breakthrough potential is **Direction 1 (Tropical Complexity Classes)**, which would formalize a hierarchy of computational hardness using tropical algebra. This could connect the existing `InfoEfficientAlgorithm` framework (`Catalog/Computation/InfoEfficientAlgorithms.lean`) with tropical scheduling theory, potentially yielding a new characterization of complexity classes via semiring structure.

---

### Direction 1: Tropical Complexity Classes

**Conjecture**: There exists a faithful functor from the category of recipe compositions (with sequential and parallel as morphisms) to the category of tropical matrices (with max-plus multiplication), such that the complexity class of a recipe is determined by the spectral radius of its associated tropical matrix.

**Test**: Construct the tropical adjacency matrix for a recipe DAG with n steps. Compute its tropical eigenvalue (the maximum cycle mean). Test whether recipes with tropical eigenvalue > 1 are exactly the NP-recipes, and those with eigenvalue ≥ 2 are the HARD-recipes. Verify on 50+ recipes from the classification database.

**Impact**: If true, this provides a purely algebraic characterization of computational difficulty — the spectral theory of tropical matrices becomes a complexity-theoretic tool. This would open a new approach to P vs NP via tropical algebraic geometry. If false, it reveals which structural properties of recipes are *not* captured by tropical algebra.

**Catalog References**: `Catalog/Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm framework), `Catalog/Bridges/AlgebraTropicalGeometry/` (tropical algebra infrastructure), `tropical_sort_complexity_bound` from `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean`

**Proof Strategy**: (1) Define the tropical adjacency matrix of a RecipeDAG. (2) Prove that the makespan equals the (1,n) entry of the tropical matrix power. (3) Define the tropical eigenvalue as the maximum cycle mean. (4) Prove eigenvalue > 1 ↔ gap > 0 for single-cycle DAGs. (5) Extend to general DAGs using the tropical spectral theorem.

**Domain Bridges**: Tropical ↔ Computation, Algebra ↔ Scheduling

**Lineage**: Builds directly on `seqPlus_distrib_maxPlus`, `pipeline_makespan_le_total`, and the RecipeDAG infrastructure from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Stochastic Recipe Complexity

**Conjecture**: For a recipe R with stochastic cooking time C ~ μ_C and verification time V ~ μ_V, the expected gap E[gap(R^(k+1))] = (k+1) · E[gap(R)], but the variance Var[gap(R^(k+1))] grows as (k+1) · Var[gap(R)] (independent steps) or (k+1)² · Var[gap(R)] (correlated steps).

**Test**: Define a stochastic Recipe structure with probability distributions on cook_time and verify_time. Simulate 10,000 iterations of soufflé-making with Gaussian noise (μ_C=45, σ_C=5, μ_V=5, σ_V=1). Measure whether the gap variance grows linearly or quadratically with k.

**Impact**: If linear, independent noise is the correct model — recipes don't accumulate systematic errors. If quadratic, correlations between cooking attempts exist (e.g., oven temperature drift), requiring a richer stochastic framework. Either result constrains the space of valid recipe complexity models.

**Catalog References**: `Catalog/EML/AdvancedTheory.lean` (ensemble complexity, which models stochastic ensembles), `Speculative/RecipeComplexity.lean` (gap_scales_with_composition)

**Proof Strategy**: (1) Define `StochasticRecipe` with `MeasureTheory.ProbabilityMeasure` on cook/verify times. (2) Prove the expected gap additivity using linearity of expectation. (3) For variance, use independence assumptions and Bienaymé's identity. (4) For the correlated case, model correlation via a shared latent variable.

**Domain Bridges**: Computation ↔ MachineLearning (probability), EML ↔ Computation

**Lineage**: Extends `gap_scales_with_composition` and `iter_seq_cook_time` from this cycle to the stochastic setting.

**Ambition**: extension

---

### Direction 3: Recipe Completeness and Universal Recipes

**Conjecture**: There exists a "universal recipe" U such that every recipe R with n steps can be reduced to U with overhead O(n). That is, U is NP-complete in the recipe reduction preorder: every other recipe reduces to it.

**Test**: Define U as a "molecular gastronomy kit" — a recipe with maximum flexibility (sous vide at any temperature, any ingredient combination). Formally show that for any R with n steps, there is a RecipeReduction from U to R with overhead ≤ c·n for some constant c.

**Impact**: If such a universal recipe exists, it proves the recipe reduction preorder has a maximum element — a "hardest possible recipe." This mirrors the existence of NP-complete problems in complexity theory. If no universal recipe exists, it means recipe complexity has an infinitely ascending chain — no finite recipe can simulate all others.

**Catalog References**: `Catalog/Computation/GravityOracle.lean` (oracle idempotency and fixed points), `Speculative/RecipeComplexity.lean` (RecipeReduction, recipe_reduction_transitive)

**Proof Strategy**: (1) Formalize a "universal ingredient set" as a Recipe with parametric cook_time. (2) Define simulation: R₂ simulates R₁ if there's a mapping of ingredients and steps. (3) Prove the transitive closure of simulation equals the reduction preorder. (4) Construct U explicitly as a recipe with max(steps(R)) steps and show the reduction exists.

**Domain Bridges**: Computation ↔ Logic (completeness), Algebra ↔ Computation

**Lineage**: Extends `recipe_reduction_transitive` and `recipe_reduction_refl` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Learning Curves and Amortized Complexity

**Conjecture**: When a chef practices recipe R repeatedly, the cooking time decreases as C_k(R) = C(R) · k^(-α) for some learning rate α ∈ (0, 1), while V(R) remains constant. The gap therefore converges to -V(R) after sufficiently many repetitions — every recipe eventually becomes a P-recipe through practice.

**Test**: Collect real-world timing data from 10 amateur cooks making the same recipe 20 times each. Fit the power law C_k = C · k^(-α). Test whether α is consistent across recipes (universal learning rate) or recipe-dependent. Verify that V stays approximately constant.

**Impact**: If α is universal, there is a single "human learning constant" governing skill acquisition in cooking. This would connect recipe complexity to Wright's Law and experience curves in manufacturing economics. If recipe-dependent, different recipes have fundamentally different learning profiles — some skills plateau faster than others.

**Catalog References**: `Catalog/MachineLearning/` (learning theory infrastructure), `Speculative/RecipeComplexity.lean` (iter_seq_cook_time, gap_scales_with_composition)

**Proof Strategy**: (1) Define `AmortizedRecipe` with a decreasing cook_time function. (2) Prove that for α > 0, there exists k₀ such that C_{k₀}(R) < V(R) — the "mastery threshold." (3) Show k₀ = ⌈(C/V)^(1/α)⌉. (4) Prove the total gap over k iterations is Θ(k^(1-α)) for α < 1.

**Domain Bridges**: Computation ↔ MachineLearning, Algebra ↔ Physics (power laws)

**Lineage**: Extends the scaling theorems from this cycle to a non-linear (decaying) regime.

**Ambition**: extension

---

### Direction 5: Compositional Verification and the Soufflé Problem

**Conjecture**: There exist "destructive verification" recipes where verification itself has side effects — checking the soufflé destroys it (cutting it open releases the air). Formally: for destructive-verification recipes, there is no reduction to any P-recipe, even with unbounded overhead.

**Test**: Define a `DestructiveRecipe` where `verify` is a function that modifies the recipe's outcome. Prove that the reduction preorder restricted to destructive recipes has no P elements — destructive recipes form an upward-closed ideal in the hardness preorder.

**Impact**: If true, this gives a formal proof that certain types of creation are *inherently* unverifiable without destruction — a mathematical foundation for the uncertainty principle in cooking (and by analogy, in quantum measurement). If false, there always exists a non-destructive verification method, and the soufflé problem is an artifact of insufficient technology.

**Catalog References**: `Speculative/RecipeComplexity.lean` (RecipeReduction, hard_implies_NP), `Catalog/Logic/` (logical foundations for non-constructive proofs)

**Proof Strategy**: (1) Extend Recipe with a `destructive : Bool` field. (2) Define: a verification is non-destructive if it commutes with re-verification (idempotent, cf. `geodesic_oracle_idempotent`). (3) Prove that destructive verification is non-idempotent. (4) Show non-idempotent verification cannot reduce to idempotent verification.

**Domain Bridges**: Computation ↔ Physics (measurement theory), Logic ↔ Computation

**Lineage**: Extends the recipe reduction framework from this cycle. Connects to `Catalog/Computation/GravityOracle.lean` (oracle idempotency as a model for non-destructive verification).

**Ambition**: extension
