# Future Directions: Categorification of Entropy

## Synthesis

This research cycle established **functorial entropy** as a rigorous, machine-verified theory connecting category theory to information theory and thermodynamics. The central achievement is the **Zero Characterization Theorem**: a function between finite types has zero functorial entropy if and only if it is injective — providing a precise, quantitative bridge between algebraic properties (injectivity) and analytic properties (zero entropy). The **Composition Monotonicity Theorem** (Data Processing Inequality), **Upper Bound**, and **Landauer Bridge** complete the basic theory.

The most promising cross-domain connection from this cycle is the **entropy-thermodynamics-computation triangle**: functorial entropy simultaneously measures information loss (information theory), thermodynamic cost (Landauer's principle), and computational irreversibility. This connects to the Catalog's existing work on tropical geometry and reversible computing (`Computation/ReversibleTropicalMachine.lean`), which already proves `zero_uniform_entropy_loss_iff_bijective` — our Zero Characterization extends this from bijective/surjective to the general injective case. The bridge between algebraic fiber structure and physical energy cost opens territory for neural architecture analysis, privacy engineering, and compiler optimization.

The highest breakthrough potential lies in **Direction 1 (Composition Superadditivity)**, because proving it would establish functorial entropy as a true *measure of compositional information loss* — where the whole exceeds the sum of parts — with immediate applications in privacy analysis and data pipeline optimization. Direction 2 (Weighted Entropy) extends the theory to non-uniform distributions, which is essential for practical ML applications. Direction 3 (Tropical-Entropy Duality) could unify two independent strands of the Catalog.

---

### Direction 1: Composition Superadditivity Conjecture

**Conjecture**: For f : α → β surjective and g : β → γ arbitrary, the functorial entropy of the composition satisfies H(g ∘ f) ≥ H(f) + H(g). That is, composing functions creates *more* information loss than the sum of individual losses.

**Test**: Enumerate all surjective f : Fin n → Fin m and all g : Fin m → Fin k for small values (n ≤ 8, m ≤ 5, k ≤ 4). Compute H(g ∘ f), H(f), and H(g) numerically. If any triple satisfies H(g ∘ f) < H(f) + H(g), the conjecture is refuted. Initial testing (n=4, m=3, k=2: all 2592 pairs) shows no violations.

**Impact**: If true, functorial entropy becomes a *superadditive* invariant under composition — a strong structural property with deep implications. It would mean that composing lossy functions amplifies information destruction, providing fundamental limits on multi-stage data processing. If false, the counterexample would reveal a subtle interaction between fiber structures that constrains the theory.

**Catalog References**: `Computation/ReversibleTropicalMachine.lean` (zero_uniform_entropy_loss_iff_bijective), `Algebra/FunctorialEntropy.lean` (functorialEntropy_comp_mono, superadditivity_conjecture)

**Proof Strategy**: The key challenge is bounding Σ_a log|fiber(g∘f, a)| from below by Σ_a log|fiber(f, a)| + Σ_a log|fiber(g, f(a))|. The fibers of g∘f decompose as: (g∘f)⁻¹(c) = ∪_{b ∈ g⁻¹(c)} f⁻¹(b). The log of the union size relates to the sum of log-fiber-sizes through the AM-GM inequality or Jensen's inequality applied to the concavity/convexity of the relevant function. The surjectivity of f is needed to ensure that every fiber of g is "reached."

**Domain Bridges**: Algebra <-> Information Theory, Algebra <-> Computation

**Lineage**: Builds directly on functorialEntropy_comp_mono (this cycle) and the superadditivity_conjecture definition.

**Ambition**: grand_challenge

---

### Direction 2: Weighted Functorial Entropy for Non-Uniform Distributions

**Conjecture**: Define the weighted functorial entropy H_μ(f) = Σ_{a ∈ α} μ(a) · log(Σ_{x: f(x)=f(a)} μ(x) / μ(a)), where μ is a probability measure on α. Then the Zero Characterization generalizes: H_μ(f) = 0 for all μ if and only if f is injective. Moreover, for fixed μ, H_μ(f) = 0 if and only if f is injective on the support of μ.

**Test**: Implement weighted entropy computation and verify the zero characterization on all functions Fin 4 → Fin 3 with at least 10 different probability distributions (uniform, geometric, concentrated). Check that H_μ(f) = 0 exactly when f is injective on supp(μ).

**Impact**: This extends functorial entropy from a purely combinatorial theory to a measure-theoretic one, enabling applications to neural network training (where activations are not uniform), statistical inference, and information-theoretic cryptography. The weighted version would also connect to the Catalog's measure-theoretic infrastructure.

**Catalog References**: `Algebra/FunctorialEntropy.lean`, `EML/EMLv17Core.lean` (for measure-theoretic foundations)

**Proof Strategy**: Define fiberMeasure(f, a, μ) = μ(f⁻¹(f(a))) and H_μ(f) = Σ_a μ(a) · log(fiberMeasure(f, a, μ) / μ(a)). The key lemma is: if H_μ(f) = 0 and μ(a) > 0, then fiberMeasure(f, a, μ) = μ(a), which forces the fiber of f(a) to consist solely of {a} within the support. Use Finset.sum_eq_zero_iff with the non-negativity of KL divergence.

**Domain Bridges**: Algebra <-> Probability Theory, Algebra <-> MachineLearning

**Lineage**: Extends functorialEntropy_eq_zero_iff_injective from uniform to general measures.

**Ambition**: extension

---

### Direction 3: Tropical-Entropy Duality

**Conjecture**: There exists a natural "tropicalization" functor from the entropy category (finite types with entropy morphisms) to a tropical semiring, where the entropy of a morphism corresponds to the tropical weight of the corresponding tropical morphism. Specifically, define the tropical entropy T(f) = max_{a ∈ α} log(fiberCard(f, a)) (the max-plus entropy). Then T satisfies a tropical analog of the Zero Characterization: T(f) = 0 ⟺ f is injective, and T(g ∘ f) ≥ T(f) for composition.

**Test**: Verify T(f) = 0 ⟺ f injective computationally for all Fin 5 → Fin 4. Verify T(g ∘ f) ≥ T(f) for all compositions. Compare T(f) with H(f) across all functions and check whether the ratio T(f)/H(f) is bounded.

**Impact**: This would unify the Catalog's tropical geometry strand (`Tropical/OrbitComplexity.lean`, `Bridges/OperadicTropicalization.lean`) with the entropy strand, creating a single framework that captures both average-case (H) and worst-case (T) information loss. The tropical perspective would connect to optimization (tropical convexity), phylogenetics (tropical tree spaces), and algebraic geometry.

**Catalog References**: `Tropical/OrbitComplexity.lean` (orbit_entropy_upper_bound_zero), `Bridges/OperadicTropicalization.lean` (tropical_profile_complete_for_bounded_architecture_congruence), `Algebra/FunctorialEntropy.lean`

**Proof Strategy**: Define T(f) = Finset.sup' univ ⟨a₀⟩ (fun a => Real.log(fiberCard f a)). The zero characterization follows from max of non-negative values being zero iff all are zero. Composition monotonicity follows from fiberCard_comp_ge. The key new result would be a *duality theorem* relating H(f) and T(f): H(f) ≤ T(f) ≤ |image(f)| · H(f) or similar bounds.

**Domain Bridges**: Algebra <-> Tropical Geometry, Information Theory <-> Algebraic Geometry

**Lineage**: Builds on orbit_entropy_upper_bound_zero and tropical_profile_complete_for_bounded_architecture_congruence.

**Ambition**: grand_challenge

---

### Direction 4: Entropy Bounds for Algebraic Circuits

**Conjecture**: For an algebraic circuit C of depth d computing a polynomial p : Fin n → Fin m, the functorial entropy satisfies H(p) ≤ d · log(fan_in), where fan_in is the maximum fan-in of any gate. This would give an entropy-based lower bound on circuit depth: d ≥ H(p) / log(fan_in).

**Test**: Compute H(p) for specific polynomial functions (multiplication mod m, exponentiation mod m, etc.) and compare with known circuit depth lower bounds. Check whether the entropy bound is ever tighter than existing bounds.

**Impact**: If the entropy bound on circuit depth is sometimes tighter than existing lower bounds, it would provide a new tool in computational complexity theory. Even if it's weaker, the connection between entropy and circuit complexity opens a new avenue for lower bound proofs.

**Catalog References**: `Algebra/AlgebraicCircuitComplexity.lean` (depth_lower_bound_from_degree), `Algebra/FunctorialEntropy.lean`

**Proof Strategy**: Model each gate as a function with bounded fiber sizes (fan-in k means fibers ≤ k). By composition monotonicity and the upper bound per gate (H ≤ log k), the total entropy after d stages is ≤ d · log(k). Formalize this using induction on circuit depth, with the base case being a single gate and the inductive step using composition monotonicity.

**Domain Bridges**: Algebra <-> Computation, Information Theory <-> Complexity Theory

**Lineage**: Builds on depth_lower_bound_from_degree and functorialEntropy_comp_mono.

**Ambition**: extension

---

### Direction 5: Entropy of Group Homomorphisms

**Conjecture**: For a group homomorphism φ : G → H between finite groups, H(φ) = log(|ker(φ)|). That is, the functorial entropy of a group homomorphism is exactly the logarithm of the kernel size. This would make functorial entropy a complete invariant of the kernel, and the first isomorphism theorem G/ker(φ) ≅ im(φ) would correspond to an entropy decomposition.

**Test**: Verify H(φ) = log(|ker(φ)|) computationally for: (1) the projection ℤ/12 → ℤ/4, (2) the sign homomorphism S₄ → ℤ/2, (3) the determinant GL₂(𝔽₃) → 𝔽₃*.

**Impact**: This would establish that functorial entropy, when restricted to group homomorphisms, captures exactly the kernel size — the most fundamental algebraic invariant of a homomorphism. It would connect functorial entropy to the rich theory of group extensions, exact sequences, and cohomology.

**Catalog References**: `Algebra/FunctorialEntropy.lean`, `Algebra/AlgebraicTheoryOfAlgebra.lean`

**Proof Strategy**: By Lagrange's theorem, each fiber of φ is a coset of ker(φ) and has size |ker(φ)|. Therefore fiberCard(φ, g) = |ker(φ)| for all g, and H(φ) = (1/|G|) · |G| · log(|ker(φ)|) = log(|ker(φ)|). This should be a straightforward computation using `Subgroup.card_eq_card_quotient_mul_card_subgroup` or similar Mathlib results.

**Domain Bridges**: Algebra <-> Group Theory, Information Theory <-> Abstract Algebra

**Lineage**: Builds on functorialEntropy definition and the group theory in Mathlib.

**Ambition**: extension
