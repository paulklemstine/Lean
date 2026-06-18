# Future Directions

## Synthesis

This cycle established the **category EML_Comp** of EML-computable maps as a rigorous mathematical object with finite products, a terminal object, a retraction pair (exp/log), currying, and a derivation depth hierarchy. The key insight is that the EML functional closure—previously studied only as a closure operator (extensivity, monotonicity, idempotence)—has rich *compositional* structure that the lattice-theoretic perspective misses.

The most promising cross-domain connection is between EML_Comp and **tropical geometry**. The log-affine fragment of EML_Comp (functions of the form $\exp(\sum w_i \log x_i + c)$) corresponds exactly to the "dequantization" of tropical polynomials: as a temperature parameter $t \to 0$, the log-sum-exp operation $t \log(\sum \exp(a_i/t))$ converges to $\max(a_i)$, recovering tropical algebra. This suggests that EML_Comp contains a continuous deformation from classical algebra to tropical algebra, and that the category itself might be a "master category" interpolating between the two.

The depth hierarchy (Theorem 3.15, 3.16) opens a new complexity-theoretic direction. The strict inclusion $D_0 \subsetneq D_1$ is just the beginning; establishing separation at all levels would give a hierarchy theorem analogous to the polynomial hierarchy in computational complexity, but for transcendental computation.

---

### Direction 1: Tropical Deformation Functor from EML_Comp

**Conjecture**: There exists a one-parameter family of functors $F_t : \text{EML\_Comp} \to \text{Trop}$ (parameterized by $t > 0$) from EML_Comp to the tropical semiring category, such that for each morphism $f$ in EML_Comp, $\lim_{t \to 0^+} F_t(f)$ recovers the tropicalization of $f$. The log-sum-exp functor $\text{LSE}_t(a_1, \ldots, a_n) = t \cdot \log(\sum_i \exp(a_i / t))$ should be the key component.

**Test**: Define $F_t$ explicitly on objects and morphisms. Verify that $F_t$ preserves composition (functoriality) for the log-affine fragment. Compute $\lim_{t \to 0} F_t(\text{addMor})$ and verify it equals the tropical addition (max operation).

**Impact**: If true, this would establish EML_Comp as a *deformation* of the tropical category, providing a smooth bridge between classical and tropical algebra. This would connect the EML framework to Viro's patchworking, Mikhalkin's curve counting, and the broader tropical algebraic geometry program.

**Catalog References**: `Tropical/` directory, `EML/OISCC.lean`, `EML/CategoryDefs.lean`

**Proof Strategy**: Define $F_t$ using the log-sum-exp operation. Prove functoriality by showing that $F_t(g \circ f) = F_t(g) \circ F_t(f)$ using the associativity of log-sum-exp composition. The limit computation uses dominated convergence or direct analysis of the exponential scaling.

**Domain Bridges**: EML <-> Tropical (dequantization bridge), Bridges <-> EML (log-affine normalization)

**Lineage**: Builds on this cycle's EMLMor.comp_assoc, EMLMor.fst_pair, and the log-affine subcategory results.

**Ambition**: grand_challenge

---

### Direction 2: EML Depth Separation at All Levels

**Conjecture**: For all $k \geq 0$, the depth class $D_k(1)$ is strictly contained in $D_{k+1}(1)$. The witness function for $D_{k+1} \setminus D_k$ is the $(k+1)$-fold iterated exponential $\exp^{(k+1)}(x) = \exp(\exp(\cdots\exp(x)\cdots))$.

**Test**: Prove that $\exp^{(k+1)}(x)$ has a derivation of depth $k+1$ (easy, by construction). Then prove that no derivation of depth $\leq k$ can compute $\exp^{(k+1)}(x)$. The key difficulty is the lower bound: showing that depth $k$ is genuinely insufficient.

**Impact**: A full depth hierarchy theorem would give the first complexity-theoretic stratification of transcendental computation, analogous to the time/space hierarchies in classical complexity theory. It would show that EML_Comp has "genuine depth"—deeper nesting produces strictly more computational power.

**Catalog References**: `EML/EMLCategory.lean` (EMLDeriv, EMLDepthClass), `Computation/PadicValuationDepth.lean`

**Proof Strategy**: The upper bound is trivial. For the lower bound, consider a normal form argument: any depth-$k$ derivation can be written as a composition of depth-1 operations, and the resulting function has a specific analytic structure (e.g., bounded tower height in the Hardy field hierarchy). Show that $\exp^{(k+1)}$ exceeds this tower height. This connects to the theory of Hardy fields and o-minimal structures.

**Domain Bridges**: EML <-> Computation (complexity hierarchies), EML <-> Logic (o-minimality)

**Lineage**: Builds on this cycle's `EMLDeriv.depth_le_size`, `EMLDepthClass_mono`, and `exp_in_depth_one`.

**Ambition**: grand_challenge

---

### Direction 3: Symmetric Monoidal Structure of EML_Comp

**Conjecture**: EML_Comp is a symmetric monoidal category with tensor product $n \otimes m = n + m$ and unit $I = 0$. The swap morphism $\sigma_{n,m} : \mathbb{R}^{n+m} \to \mathbb{R}^{m+n}$ satisfies $\sigma_{m,n} \circ \sigma_{n,m} = \text{id}$, and the associator $\alpha : \mathbb{R}^{(n+m)+k} \to \mathbb{R}^{n+(m+k)}$ is an EML isomorphism.

**Test**: Prove that the swap morphism is involutive ($\sigma \circ \sigma = \text{id}$). Construct the associator and prove the pentagon and triangle coherence diagrams commute. The swap involution was stated as a sorry in this cycle—completing it is the first step.

**Impact**: Symmetric monoidal structure would enable the definition of EML string diagrams, providing a graphical calculus for EML computations. It would also allow the application of coherence theorems (Mac Lane's coherence theorem) to simplify categorical proofs about EML.

**Catalog References**: `EML/EMLCategory.lean` (EMLMor.swap, EMLMor.pair, EMLMor.fst, EMLMor.snd)

**Proof Strategy**: For the swap involution, unfold the definitions and show that reindexing $\text{Fin}(n+m)$ via castAdd and natAdd, then swapping, gives the identity. The associator uses the canonical bijection $\text{Fin}((n+m)+k) \cong \text{Fin}(n+(m+k))$ from `Fin.addAssoc`. Coherence may follow from the fact that EML_Comp is a full subcategory of Set with the same monoidal structure.

**Domain Bridges**: EML <-> Algebra (monoidal categories), EML <-> Physics (string diagrams in quantum field theory)

**Lineage**: Builds on this cycle's `EMLMor.swap`, `EMLMor.pair`, `EMLMor.fst_pair`, `EMLMor.snd_pair`.

**Ambition**: extension

---

### Direction 4: EML_Comp as a Subcategory of Smooth Manifolds

**Conjecture**: There exists a faithful functor $U : \text{EML\_Comp} \to \text{Diff}$ from EML_Comp to the category of smooth manifolds and smooth maps, sending $n$ to $\mathbb{R}^n$ and each EML morphism to its underlying smooth map. Moreover, this functor preserves finite products.

**Test**: Prove that every ScalarEML function is smooth (infinitely differentiable). This requires showing that exp, log, +, × are smooth, and that smoothness is preserved under composition. Then verify that the product structure is preserved (the pairing of smooth maps is smooth, and projections are smooth).

**Impact**: This would embed EML_Comp into the rich world of differential geometry, allowing the use of tangent spaces, differential forms, and curvature on EML-computable maps. It would also connect to the Jacobian theory of EML maps (relevant for change-of-variables in integration and for backpropagation in neural networks).

**Catalog References**: `EML/EMLCategory.lean`, `Geometry/` directory, Mathlib's `Analysis.SpecialFunctions.ExpDeriv`

**Proof Strategy**: Define the functor on objects and morphisms. Smoothness of EML functions follows by induction on the ScalarEML derivation, using that exp, log are smooth (on their domains), and that smooth functions compose smoothly. Product preservation is automatic since the pairing of smooth maps is smooth.

**Domain Bridges**: EML <-> Geometry (differential structure), EML <-> MachineLearning (backpropagation as tangent functor)

**Lineage**: Builds on this cycle's `EMLMor`, `VecEMLComp`, and the product structure.

**Ambition**: extension

---

### Direction 5: Information Geometry of the Log-Affine Subcategory

**Conjecture**: The log-affine subcategory of EML_Comp (morphisms of the form $f(x) = \exp(\sum w_i \log x_i + c)$) is equivalent, as a category, to the category of affine maps between finite-dimensional real vector spaces. Under this equivalence, the Fisher information metric on exponential families corresponds to the Euclidean metric in the log-coordinate system.

**Test**: Construct the functor $\Phi$ that sends a log-affine morphism to the affine map $(w, c)$ and prove it is an equivalence of categories. Then define the Fisher information metric on the space of log-affine morphisms and show it equals the pulled-back Euclidean metric.

**Impact**: This would connect EML computation to information geometry (Amari's framework), providing a geometric interpretation of the log-affine fragment as the "flat" subspace of EML_Comp. The curvature of the full EML_Comp relative to this flat subspace would measure "non-log-affinity"—a new complexity measure for EML functions.

**Catalog References**: `EML/LogAffineNormal.lean`, `Shared/EML/` (Fisher information results), `EML/CategoryDefs.lean` (LogAffine)

**Proof Strategy**: The functor $\Phi$ maps objects to objects (same dimensions), and morphisms to the weight-constant pairs $(w, c)$. Faithfulness and fullness follow from the uniqueness of the log-affine representation (normalization theorem from `LogAffineNormal.lean`). The Fisher metric computation uses the standard formula for exponential families.

**Domain Bridges**: EML <-> Shared (information geometry), EML <-> MachineLearning (exponential families)

**Lineage**: Builds on this cycle's log-affine definitions and the existing `posEML_is_logAffine` and `evalPosEML_eq_logAffine` from the catalog.

**Ambition**: extension
