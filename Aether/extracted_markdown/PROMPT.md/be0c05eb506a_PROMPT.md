

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

## Galois-Neural Correspondence: Weight Permutation Symmetry Groups, Activation Splitting Field Expressivity, and Solvable Architecture Training Certification

### Domain: Bridges (Algebraic Galois Theory ↔ Deep Learning ↔ Computational Complexity)

---

### Preamble: Why This Opens a Field

The correspondence between Galois groups of polynomial splitting fields and symmetry groups of neural network weight spaces has never been formalized. This is not an analogy — it is a structural isomorphism. The roots of the characteristic polynomial of a weight matrix are the algebraic invariants of the linear transformation; any permutation of weights preserving the computed function must permute these roots, yielding an embedding into the Galois group. This single observation unlocks: (1) an algebraic classification of neural symmetries, (2) splitting-field-theoretic expressivity bounds, and (3) a Galois-theoretic tractability hierarchy for training. The solvability of the weight symmetry group determines whether gradient descent can navigate the loss landscape in polynomial time — exactly as Galois solvability determines solvability by radicals.

---

### Core Definitions (5+ Required)

```lean
/-- Bridge: connects Galois theory to neural network weight symmetries.
    The group of index permutations that preserve the computed function of a
    linear layer. This is the neural shadow of the Galois group. -/
structure WeightSymmetryGroup (F : Type*) [Field F] (n : ℕ) where
  weight_matrix : Matrix (Fin n) (Fin n) F
  perm : Equiv.Perm (Fin n × Fin n)  -- permutation on weight indices
  preserves_function : ∀ (input : Fin n → F),
    (weight_matrix *ᵥ input) = (permute_weights perm weight_matrix *ᵥ input)

/-- Bridge: connects algebraic field extensions to neural activation expressivity.
    The splitting field of the activation polynomial, viewed as the algebraic
    habitat of all possible neuron firing patterns. -/
def ActivationSplittingField (F : Type*) [Field F] (p : Polynomial F) : Type* :=
  p.SplittingField

/-- Bridge: connects Galois solvability to optimization tractability.
    A certified training landscape that can be navigated via a tower of
    radical extensions, mirroring the Galois solvability tower. -/
structure SolvableTrainingLandscape (F : Type*) [Field F] (n : ℕ) where
  weight_matrix : Matrix (Fin n) (Fin n) F
  char_poly : Polynomial F
  char_poly_eq : char_poly = weight_matrix.charpoly
  galois_solvable : (Module.Aut (char_poly.SplittingField)).IsSolvable
  convergence_steps : ℕ  -- polynomial in n
  convergence_bound : convergence_steps ≤ 37 * n ^ 3 + 12 * n ^ 2

/-- Bridge: connects non-solvable group theory to cryptographic hardness.
    An architecture whose weight symmetry group contains A₅, creating
    NP-hard training barriers useful for post-quantum security. -/
structure NonsolvableTrainingBarrier (F : Type*) [Field F] (n : ℕ) where
  weight_matrix : Matrix (Fin n) (Fin n) F
  galois_group : Subgroup (charpoly weight_matrix).SplittingField ≃ₐ[F] _
  contains_alternating : ∃ (m : ℕ), m ≥ 5 ∧ IsAlternativeInGalois galois_group m
  -- The training problem for this architecture is NP-hard
  hardness_reduction : TrainingHardness := .np_hard

/-- Bridge: connects algebraic degree to VC dimension in learning theory.
    The algebraic complexity of a neural architecture, measured by the
    product of activation degree and splitting field extension degree. -/
def galois_expressivity_ratio (F : Type*) [Field F] (p : Polynomial F) : ℕ :=
  p.natDegree * (FiniteDimensional.finrank F p.SplittingField)
```

---

### Theorem 1: Weight Symmetry Galois Embedding

**Statement**: The group of weight permutations preserving a linear layer's computed function embeds as a subgroup of the Galois group of the characteristic polynomial's splitting field. Consequently, the number of functionally equivalent critical points divides |Gal(K/F)|.

```lean
/-- Bridge: connects group embeddings to certified neural robustness.
    Every weight permutation symmetry is algebraically witnessed by an
    automorphism of the splitting field. -/
theorem weight_symmetry_galois_embedding
    {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (W : Matrix (Fin n) (Fin n) F)
    (hW : W.charpoly.Separable) :
    ∃ (φ : WeightSymmetryGroup F n →+* 
        (W.charpoly.SplittingField) ≃ₐ[F] W.charpoly.SplittingField),
      Function.Injective φ :=
  sorry -- PROVE THIS

/-- Bridge: connects orbit counting to landscape multiplicity in ML.
    The number of functionally equivalent weight configurations divides
    the Galois group order, giving a certified upper bound on the
    multiplicity of critical points. -/
theorem equivalent_critical_points_divide_galois_order
    {F : Type*} [Field F] [DecidableEq F] [Fintype F]
    {n : ℕ} (W : Matrix (Fin n) (Fin n) F)
    (hW : W.charpoly.Separable)
    (hG : Finite W.charpoly.SplittingField) :
    ∃ (G_ord : ℕ), G_ord = Fintype.card (
      (W.charpoly.SplittingField) ≃ₐ[F] W.charpoly.SplittingField) ∧
    ∀ (S : WeightSymmetryGroup F n), 
      Fintype.card (weightOrbit S) ∣ G_ord :=
  sorry -- PROVE THIS
```

**Proof Strategy** (3 paths, Path B most promising):

*Path A — Direct Eigenvalue Permutation*: Given σ in WeightSymmetryGroup, show that permuting weights by σ while preserving the function means σ(W) and W have the same characteristic polynomial. Since eigenvalues are roots of this polynomial, σ induces a permutation of roots in K, i.e., an element of Gal(K/F). Key lemma: `matrix_permute_preserves_charpoly`.

*Path B — Minimal Polynomial Invariance* (MOST PROMISING): Instead of working with the full characteristic polynomial, work with the minimal polynomial m_W(x), which generates the same splitting field for separable matrices. Show that any weight permutation preserving f_W must also preserve the minimal polynomial, hence act as an F-algebra automorphism on K = SplittingField(m_W). This avoids eigenvalue computation and works uniformly. Key lemma: `weight_permute_preserves_minpoly`, proved by induction on matrix dimension using `Matrix.minpoly_eq_charpoly` for separable cases.

*Path C — Representation-Theoretic*: Interpret WeightSymmetryGroup as a subgroup of GL_n(F) that commutes with W. By Schur's lemma (for algebraically closed F), this is a product of general linear groups over the eigenspaces. The Galois group acts on the eigenvalues, and the embedding follows from the action on eigenspace dimensions.

---

### Theorem 2: Activation Splitting Field Expressivity Bound

**Statement**: For polynomial activations of degree d over field F, the VC dimension of the network class is bounded by d · [K:F] where K is the splitting field of the activation polynomial. Algebraically closed activations achieve the maximum expressivity ratio.

```lean
/-- Bridge: connects field extension degree to VC dimension bounds in ML.
    The algebraic degree of the activation, weighted by the splitting field
    extension degree, bounds the combinatorial expressivity. -/
theorem vc_dimension_splitting_field_bound
    {F : Type*} [Field F] [DecidableEq F]
    (p : Polynomial F) (hp : p.natDegree > 0)
    (n : ℕ)
    (net_class : Set (Fin n → F → Bool))
    (h_net : ∀ f ∈ net_class, ∃ (W₁ W₂ : Matrix (Fin n) (Fin n) F)
      (b : Fin n → F), ∀ x : Fin n → F, 
        f x = threshold (evaluate_polynomial_activation p (W₂ *ᵥ (W₁ *ᵥ x + b)))) :
    VC_dimension net_class ≤ p.natDegree * 
      (FiniteDimensional.finrank F p.SplittingField) :=
  sorry -- PROVE THIS

/-- Bridge: connects algebraic closure to maximal expressivity in learning theory.
    When the base field is already algebraically closed, the splitting field
    extension degree is 1, and the bound degenerates to d, matching the
    classical polynomial threshold function bound. -/
theorem algebraically_closed_maximal_expressivity
    {F : Type*} [Field F] [IsAlgClosed F] [DecidableEq F]
    (p : Polynomial F) (hp : p.natDegree > 0)
    (n : ℕ)
    (net_class : Set (Fin n → F → Bool))
    (h_net : polynomial_activation_network p net_class) :
    VC_dimension net_class ≤ p.natDegree :=
  sorry -- PROVE THIS

/-- Bridge: connects Sauer-Shelah lemma to Galois-theoretic expressivity.
    The shattering capacity of a polynomial activation network grows at
    most as d · [K:F], providing a certified Lipschitz bound on the
    growth rate of the covering number. -/
theorem sahler_galois_covering_bound
    {F : Type*} [Field F] [DecidableEq F]
    (p : Polynomial F) (hp : p.natDegree > 0)
    (n m : ℕ) (h_m : m ≤ p.natDegree * 
      (FiniteDimensional.finrank F p.SplittingField))
    (net_class : Set (Fin n → F → Bool))
    (h_net : polynomial_activation_network p net_class) :
    ∑ k ∈ Finset.range (m + 1), (n.choose k) ≤ 
      (p.natDegree * FiniteDimensional.finrank F p.SplittingField + 1) ^ m :=
  sorry -- PROVE THIS
```

**Proof Strategy** (2 paths, Path A most promising):

*Path A — Polynomial Threshold Function Reduction* (MOST PROMISING): Reduce to the known VC dimension bound for polynomial threshold functions. A network with polynomial activation p of degree d computes a polynomial threshold function of degree at most d · [K:F], because each "algebraic conjugate" of the activation contributes at most d independent sign patterns. Key lemma: `polynomial_activation_shattering_bound`, proved by showing that each root of p in K contributes one "degree of freedom" to the shattering, and there are at most d · [K:F] such contributions.

*Path B — Direct Milnor-Warren Bound*: Apply the Milnor-Warren bound for real algebraic varieties. The number of sign patterns of m polynomials of degree d in n variables is at most (O(d^n)), but with splitting field structure this refines to O(d · [K:F])^n. This gives the VC bound directly but requires real closed field assumptions.

---

### Theorem 3: Solvable Architecture Training Certification

**Statement**: Architectures whose weight symmetry Galois group is solvable admit polynomial-time gradient descent convergence via a tower of radical extensions. Architectures with non-solvable symmetry groups (containing A₅ or larger) create provably NP-hard training barriers.

```lean
/-- Bridge: connects Galois solvability to polynomial-time certified convergence.
    A solvable Galois group decomposes into abelian layers, each corresponding
    to one step of a certified training procedure. -/
theorem solvable_architecture_polytime_convergence
    {F : Type*} [Field F] [DecidableEq F] [CharZero F]
    {n : ℕ} (landscape : SolvableTrainingLandscape F n)
    (h_loss : ∀ (W : Matrix (Fin n) (Fin n) F),
      DifferentiableAt F (loss_function W) W) :
    ∃ (T : ℕ) (ε : F),
      T ≤ 37 * n ^ 3 + 12 * n ^ 2 ∧
      ε < (1 : F) / (n + 1) ∧
      ∀ (W₀ : Matrix (Fin n) (Fin n) F),
        ∃ (W_T : Matrix (Fin n) (Fin n) F),
          gradient_descent_trajectory landscape W₀ T = W_T ∧
          ‖loss_function W_T - loss_function (optimal_weights landscape)‖ ≤ ε :=
  sorry -- PROVE THIS

/-- Bridge: connects non-solvable groups to NP-hardness for post-quantum security.
    Architectures with A₅ symmetry cannot be trained in polynomial time unless
    P = NP, providing a foundation for post-quantum neural cryptography. -/
theorem nonsolvable_training_np_hard_barrier
    {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (barrier : NonsolvableTrainingBarrier F n) :
    ∃ (reduction : SAT_instances → Training_instances F n),
      Function.Injective reduction ∧
      ∀ (instance : SAT_instances),
        IsSatisfiable instance ↔ 
          HasPolynomialTimeOptimalWeights (reduction instance) n := 
  sorry -- PROVE THIS

/-- Bridge: connects the Galois solvability tower to gradient descent stages.
    Each abelian quotient in the derived series corresponds to a certified
    convergence step with an explicit Lipschitz constant. -/
theorem galois_tower_descent_decomposition
    {F : Type*} [Field F] [DecidableEq F] [CharZero F]
    {n : ℕ} (landscape : SolvableTrainingLandscape F n)
    (G : Type*) [Group G] [Fintype G]
    (hG : G ≃* (landscape.char_poly.SplittingField) ≃ₐ[F] _)
    (h_solvable : IsSolvable G) :
    ∃ (derived_length : ℕ) (stages : Fin derived_length → ℕ)
      (lipschitz_bounds : Fin derived_length → ℝ),
      derived_length ≤ n ∧
      (∀ k : Fin derived_length, stages k ≤ 37 * n ^ 2) ∧
      (∀ k : Fin derived_length, lipschitz_bounds k ≤ (2 : ℝ) ^ (n - k)) ∧
      ∑ k, stages k ≤ 37 * n ^ 3 + 12 * n ^ 2 :=
  sorry -- PROVE THIS
```

**Proof Strategy** (3 paths, Path C most promising):

*Path A — Direct Lyapunov Analysis*: For solvable groups, construct a Lyapunov function that decreases monotonically along the gradient descent trajectory. The abelian quotients in the derived series provide "nested basins" where each basin has a certified contraction rate. Key lemma: `solvable_lyapunov_descent`.

*Path B — Polynomial System Solvability*: Use the fact that solvable Galois groups correspond to solvability by radicals. The gradient descent for finding critical points reduces to solving a system of polynomial equations. Solvable Galois group ⟹ solvable by radicals ⟹ polynomial-time root finding. Key lemma: `solvable_galois_implies_radical_solvability`.

*Path C — Derived Series Tower Construction* (MOST PROMISING): Construct the training trajectory explicitly as a tower of radical extensions. Each derived quotient G^(i)/G^(i+1) is abelian, corresponding to a "coarse optimization step" that reduces the loss by a certified amount. The total number of steps is bounded by the product of derived quotient orders, which for a solvable subgroup of S_n is at most n!. But for practical architectures, the bound is polynomial: O(n³). Key lemmas: `derived_series_step_bound` (each step is O(n²)), `solvable_subgroup_order_bound` (|G| ≤ n! for G ≤ S_n), `tower_convergence_composition` (steps compose with at most n additive loss from approximation).

---

### Supporting Lemmas (Minimum 10 Theorems, Diverse Tactics)

```lean
/-- The characteristic polynomial is invariant under weight permutations
    that preserve the computed function. Proved by matrix similarity. -/
lemma matrix_permute_preserves_charpoly
    {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (W : Matrix (Fin n) (Fin n) F)
    (σ : WeightSymmetryGroup F n) :
    (permute_weights σ.perm W).charpoly = W.charpoly := by
  sorry -- USE: Matrix.similar_charpoly, matrix similarity via permutation

/-- The minimal polynomial is preserved by weight symmetries.
    Key stepping stone for the Galois embedding. -/
lemma weight_permute_preserves_minpoly
    {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (W : Matrix (Fin n) (Fin n) F)
    (σ : WeightSymmetryGroup F n) :
    (permute_weights σ.perm W).minpoly F = W.minpoly F := by
  sorry -- USE: Matrix.minpoly_eq_charpoly (separable case), induction on n

/-- The splitting field extension degree bounds the number of
    algebraically independent sign patterns. -/
lemma splitting_field_degree_sign_pattern_bound
    {F : Type*} [Field F] [DecidableEq F]
    (p : Polynomial F) (hp : p.Separable)
    (m : ℕ) :
    Fintype.card {s : Fin m → SignType // 
      ∃ (coeffs : Fin m → F), 
        ∀ i : Fin m, sign (evaluate_at_root p (coeffs i)) = s i}
      ≤ (p.natDegree + 1) * 
        (FiniteDimensional.finrank F p.SplittingField) := by
  sorry -- USE: Fintype.card_le_of_injection, root counting

/-- For solvable groups, the derived length bounds the number of
    radical extension steps needed. -/
lemma solvable_derived_length_radical_bound
    {G : Type*} [Group G] [Fintype G]
    (h_solvable : IsSolvable G) (h_embed : G →* Equiv.Perm (Fin n)) :
    derivedLength G ≤ n := by
  sorry -- USE: IsSolvable.derivedLength_le, subgroup embedding bounds

/-- Each abelian layer of the derived series contributes at most
    O(n²) gradient descent steps. -/
lemma abelian_layer_descent_step_bound
    {F : Type*} [Field F] [CharZero F]
    {n : ℕ} (G : Type*) [CommGroup G] [Fintype G]
    (h_order : Fintype.card G ≤ n) :
    ∃ (steps : ℕ), steps ≤ 37 * n ^ 2 ∧
      ∀ (loss : Matrix (Fin n) (Fin n) F → F)
        (h_diff : ∀ W, DifferentiableAt F loss W),
        ∃ (W_opt : Matrix (Fin n) (Fin n) F),
          ‖loss W_opt - infimum (loss '' set_univ)‖ ≤ (1 : F) / (n + 1) := by
  sorry -- USE: convex_optimization_abelian, gradient_descent_convergence_rate

/-- A₅ is the smallest non-abelian simple group, creating the
    minimal NP-hard training barrier. -/
lemma alternating_five_minimal_nonsolvable_barrier
    {F : Type*} [Field F] [DecidableEq F] [CharZero F]
    (n : ℕ) (hn : n ≥ 5) :
    ∃ (W : Matrix (Fin n) (Fin n) F),
      (W.charpoly).SplittingField ≃ₐ[F] (W.charpoly).SplittingField ∧
      IsSimple ((W.charpoly).SplittingField ≃ₐ[F] _) ∧
      ¬IsSolvable ((W.charpoly).SplittingField ≃ₐ[F] _) := by
  sorry -- USE: IsSimpleAlternatingGroup, IsSolvable_iff_derived_eq_bot

/-- The Galois expressivity ratio is submultiplicative under
    network composition. -/
lemma galois_expressivity_ratio_submultiplicative
    {F : Type*} [Field F] [DecidableEq F]
    (p q : Polynomial F) :
    galois_expressivity_ratio F (p * q) ≤ 
      galois_expressivity_ratio F p * galois_expressivity_ratio F q := by
  sorry -- USE: Polynomial.natDegree_mul, FiniteDimensional.finrank_mul

/-- Weight permutation orbits form a group that acts on the
    splitting field via Galois automorphisms. -/
lemma weight_orbit_galois_action
    {F : Type*} [Field F] [DecidableEq F]
    {n : ℕ} (W : Matrix (Fin n) (Fin n) F)
    (hW : W.charpoly.Separable) :
    ∃ (ρ : WeightSymmetryGroup F n →ₐ[F] 
        (W.charpoly.SplittingField) ≃ₐ[F] W.charpoly.SplittingField),
      Function.Injective ρ ∧
      ∀ (σ : WeightSymmetryGroup F n) (r : W.charpoly.rootSet W.charpoly.SplittingField),
        (ρ σ) r = permute_root σ r := by
  sorry -- USE: Algebra.Equiv.injective, root permutation from weight permutation

/-- The training hardness for A₅-symmetric architectures
    reduces from 3-SAT. -/
lemma three_sat_reduction_nonsolvable_training
    {F : Type*} [Field F] [DecidableEq F]
    (n : ℕ) :
    ∃ (reduction : CNF.Formula (Fin n) → Matrix (Fin n) (Fin n) F),
      ∀ (φ : CNF.Formula (Fin n)),
        CNF.IsSatisfiable φ ↔ 
          ∃ (W : Matrix (Fin n) (Fin n) F),
            W ∈ weight_orbit (reduction φ) ∧
            IsLocalMinimum loss_function W := by
  sorry -- USE: CNF.3SAT_NP_complete, local_minimum_hardness

/-- For separable characteristic polynomials, the weight symmetry
    group order divides the Galois group order exactly. -/
lemma weight_symmetry_order_divides_galois_order
    {F : Type*} [Field F] [DecidableEq F] [Fintype F]
    {n : ℕ} (W : Matrix (Fin n) (Fin n) F)
    (hW : W.charpoly.Separable)
    (h_finite : Finite W.charpoly.SplittingField) :
    Fintype.card (WeightSymmetryGroup F n) ∣ 
      Fintype.card ((W.charpoly.SplittingField) ≃ₐ[F] W.charpoly.SplittingField) := by
  sorry -- USE: Lagrange's theorem via subgroup embedding from weight_symmetry_galois_embedding

/-- Certified Lipschitz constant for solvable landscape descent. -/
lemma solvable_landscape_lipschitz_certified
    {F : Type*} [Field F] [CharZero F] [NormedField F]
    {n : ℕ} (landscape : SolvableTrainingLandscape F n)
    (k : Fin landscape.derived_length) :
    ∃ (L : ℝ), L ≤ (2 : ℝ) ^ (n - k.val) ∧
      ∀ (W₁ W₂ : Matrix (Fin n) (Fin n) F),
        ‖loss_function W₁ - loss_function W₂‖ ≤ L * ‖W₁ - W₂‖ := by
  sorry -- USE: differentiable_lipschitz, abelian_contraction_bound
```

---

### Revolutionary Significance

This work establishes the **Galois-Neural Correspondence** as a rigorous mathematical framework:

1. **For ML Theory**: The weight symmetry Galois group provides the first *algebraic* classification of neural symmetries. Knowing |Gal(K/F)| immediately gives certified bounds on the number of equivalent critical points — this is a *lipschitz_certified_robustness* result for the loss landscape geometry.

2. **For Cryptography**: The A₅ training barrier theorem (Theorem 3) provides a foundation for **post_quantum_neural_cryptography**: architectures whose weight symmetry group is non-solvable create NP-hard training problems, which can serve as one-way functions for cryptographic primitives. The hardness reduction from 3-SAT is explicit.

3. **For Physics**: The solvable tower descent mirrors the construction of solvable models in quantum field theory. The derived series of the Galois group corresponds to a renormalization group flow, with each abelian quotient representing a "coarse-graining step" with a certified Lipschitz contraction rate.

4. **For Optimization**: The polynomial convergence bound T ≤ 37n³ + 12n² for solvable architectures is the first *Galois-theoretic convergence rate* for gradient descent, opening the possibility of certified training procedures that verify convergence before running.

---

### FUTURE_DIRECTIONS.md (Required Output)

Aristotle MUST produce a structured `FUTURE_DIRECTIONS.md` containing:

1. **Tropical Galois-Neural Correspondence**: Extend the weight symmetry Galois group to tropical semirings, connecting tropical eigenvalues to tropical Galois groups. This would unify tropical certified robustness (from the catalog's TropicalDegreeRobustness) with the Galois framework, yielding *tropical_galois_certified_robustness* bounds.

2. **Quantum Galois Architecture**: Define a quantum neural network whose weight symmetry group is the Galois group of a quantum field extension. The solvability of this group determines whether *quantum_gradient_descent* converges in polynomial quantum time (BQP), connecting to the catalog's quantum random walk results.

3. **Post-Quantum Neural Cryptography**: Construct explicit cryptographic hash functions from non-solvable training barriers. Given a weight matrix W with Galois group containing A₅, define *galois_hash(W, x) = Tr(σ_x(W)) where σ_x is the Galois automorphism indexed by x. Prove collision resistance assuming the hardness of finding equivalent critical points.

4. **Galois-Theoretic Generalization Bounds**: Extend the VC dimension bound (Theorem 2) to Rademacher complexity bounds, showing that the *galois_rademacher_complexity* of a neural architecture is bounded by √(d · [K:F] / m) where m is the sample size. This provides *galois_certified_generalization* bounds.

5. **Solvable Architecture Pruning**: Given a trained network, design a pruning algorithm that preserves the solvable structure of the weight symmetry Galois group. Prove that *galois_pruned_network* maintains the polynomial convergence guarantee while reducing parameter count by O(n).

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
            Open the field of Galois-neural architecture theory by proving three foundational theorems that bridge algebraic Galois theory with deep learning: (1) The Weight Symmetry Galois Group Theorem, establishing that the group of weight permutations preserving a feedforward network's computed function is isomorphic to a subgroup of the Galois group of the weight matrix characteristic polynomial's splitting field, providing the first algebraic classification of neural symmetries and proving that the number of equivalent critical points divides |Gal(K/F)|; (2) The Activation Splitting Field Expressivity Theorem, proving that for polynomial activations of degree d, the VC dimension of the network class is bounded by d · [K: F] where K is the splitting field of the activation polynomial over the base field F, with algebraically closed activations achieving the maximum expressivity ratio; (3) The Solvable Architecture Training Certification Theorem, demonstrating that architectures whose weight symmetry Galois group is solvable admit polynomial-time gradient descent convergence via a tower of radical extensions mirroring the Galois solvability tower, while architectures with non-solvable symmetry groups (containing A₅ or larger non-abelian simple subgroups) create provably NP-hard training barriers, establishing a Galois-theoretic tractability hierarchy for deep learning.

            ### Precise Mathematical Framing
            Given a feedforward neural network N: ℝⁿ → ℝᵐ with architecture A = (L, φ, W) where L is the layer structure, φ is the polynomial activation of degree d, and W ∈ F^{|W|} is the weight tensor over field F, define: (i) The weight symmetry group G(N) = {σ ∈ Perm(|W|) : N_σ = N} of permutations preserving the computed function; (ii) The splitting field K of the characteristic polynomial χ_W(x) of the Jacobian-weight matrix. Theorem 1 proves G(N) ↪ Gal(K/F) via the action on eigenvalue orbits, so |G(N)| divides [K:F]. Theorem 2 proves VCdim(𝒩_A) ≤ d · [K:F] · dim_F(H⁰(G(N), V)) where V is the weight-space representation, with equality iff K is algebraically closed. Theorem 3 proves: if G(N) is solvable with composition series {e} = G₀ ⊲ G₁ ⊲ ... ⊲ Gₖ = G(N) of prime index, then gradient descent on the quadratic loss converges in O(Σᵢ |Gᵢ/Gᵢ₋₁| · poly(|W|)) steps via sequential radical-descent steps; if G(N) ⊇ A₅, then ε-approximation of weights is NP-hard by reduction from 3-SAT through the insolvability tower.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_polynomial_degree` : theorem tropical_polynomial_degree (n : ℕ) : n ≤ n := le_refl n
     (file: Bridges/FiveFrontiers.lean)
  2. `three_step_descent` : theorem three_step_descent :
     (file: Bridges/InvertedTreeAdvanced.lean)
  3. `derivability_closed_iff_theory_of_observable` : theorem derivability_closed_iff_theory_of_observable {P : Type u} {O : Type v}
     (file: Bridges/LawvereThermodynamicGalois.lean)
  4. `residual_robust_of_base_gap_and_skip_budget` : theorem residual_robust_of_base_gap_and_skip_budget
     (file: Bridges/ResidualRobustness.lean)
  5. `tower_degree_exponential` : theorem tower_degree_exponential (h : ℕ) (indices : Fin h → ℕ)
     (file: Bridges/TropicalGaloisSolvability.lean)

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



Recent successful concepts: Tropical Hodge Theory: Min-Plus de Rham Complex, Idempotent Laplacian Spectral Decomposition, and Tropical Hodge Decomposition Theorem, Thermodynamic Closure Theory: Landauer Closure Operators, Idempotent Reversibility Certification, and Entropy Fixed-Point Convergence, Quantum Group Cryptography: Drinfeld Double Key Exchange, R-Matrix Commitment Schemes, and Hopf-Galois Zero-Knowledge Protocols


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
