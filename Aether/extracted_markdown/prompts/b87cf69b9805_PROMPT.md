

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

## YOUR ASSIGNMENT: Idempotent Measure Theory — Min-Plus Choquet-Radon Representation, Idempotent Lebesgue Decomposition, and Tropical Kernel Representer Certification

### I. THE GRAND VISION

Open the field of **idempotent measure theory** by proving three foundational theorems that establish the measure-theoretic bedrock of tropical mathematics, certify machine-learning generalization via Choquet-theoretic bounds, and create a new bridge between functional analysis and min-plus algebra with cryptographic applications to post-quantum lattice hardness.

**Bridge: connects tropical geometry to quantum statistical mechanics (idempotent partition functions) and certified ML robustness (tropical kernel generalization bounds).**

---

### II. THEOREM 1 — IDEMPOTENT CHOQUET-RADON REPRESENTATION

#### Precise Statement

Every monotone, sup-preserving, shift-equivariant functional on the space of continuous tropical functions over a compact tropical space is uniquely represented by an idempotent Radon measure, where integration is sup-addition.

#### Lean 4 Type Signatures

```lean
-- Core structure: idempotent Radon measure on a compact tropical space
structure IdempotentRadonMeasure (X : Type*) [TopologicalSpace X] [CompactSpace X] where
  mass : Set X → WithTop ENNReal  -- idempotent "measure" (takes sup over points)
  mass_empty : mass ∅ = 0
  mass_mono : ∀ {s t : Set X}, s ⊆ t → mass s ≤ mass t
  mass_sup_add : ∀ s t : Set X}, mass (s ∪ t) = max (mass s) (mass t)
  mass_sing_bound : ∀ x : X, mass {x} < ⊤

-- The functional being represented
structure TropicalSupFunctional (X : Type*) [TopologicalSpace X] [CompactSpace X] where
  eval : C(X, Tropical ℝ) → Tropical ℝ
  mono : ∀ {f g : C(X, Tropical ℝ)}, (∀ x, (f x).toOrderDual ≤ (g x).toOrderDual) → 
         (eval f).toOrderDual ≤ (eval g).toOrderDual
  sup_pres : ∀ f g, eval (f ⊔ g) = eval f ⊔ eval g
  shift_equiv : ∀ f (c : Tropical ℝ), eval (f + const c) = eval f + c

-- THE MAIN THEOREM
theorem idempotent_choquet_radon_representation 
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (Φ : TropicalSupFunctional X) :
    ∃! μ : IdempotentRadonMeasure X, 
      ∀ f : C(X, Tropical ℝ),
        Φ.eval f = ⨆ x : X, (f x).toOrderDual ⊓ (μ.mass {x}).toOrderDual :=
  sorry -- FILL THIS
```

#### Proof Strategy (3 paths)

**Strategy A (Direct Construction via Dirac Sup-Positions):**
1. Define `μ({x}) = Φ.eval(δ_x)` where `δ_x` is the tropical Dirac function `δ_x(y) = if y = x then 0 else ⊤`.
2. Prove `mass_sup_add` by using `Φ.sup_pres` on the union of characteristic functions.
3. Prove representation for simple tropical functions (finite sup of shifted Diracs) by induction on the number of points, using `Φ.shift_equiv` and `Φ.sup_pres`.
4. Extend to all continuous functions via tropical Dini approximation: for any `f ∈ C(X, Tropical ℝ)`, construct an increasing net of simple functions converging uniformly to `f`, use `Φ.sup_pres` and continuity to pass to the limit.
5. Uniqueness follows from `Φ(δ_x) = μ({x})` determining `μ` on singletons, and `mass_sup_add` extends this to all sets.

**Strategy B (Tropical Riesz Dual Approach):**
1. Observe that `C(X, Tropical ℝ)` is a complete lattice under pointwise sup.
2. Show `TropicalSupFunctional X` forms an idempotent semimodule under pointwise operations.
3. Prove the dual space is isomorphic to the space of idempotent Radon measures via `Φ ↦ (x ↦ Φ(δ_x))`.
4. The isomorphism is the representation theorem.

**Strategy C (Maslov's Canonical Form):**
1. Use the Maslov transform: any continuous tropical function `f` has canonical representation `f(x) = ⨆_i (a_i ⊕ d(x, x_i))` for finitely many `x_i` in a compact space.
2. Apply `Φ` to the canonical form using `Φ.sup_pres` and `Φ.shift_equiv`.
3. Identify `μ({x_i}) = Φ(δ_{x_i})`.

**Strategy A is most promising** because it mirrors the classical Choquet construction most directly and each step is independently verifiable.

#### Key Lemmas Needed

```lean
-- Lemma 1: Tropical Dirac functions are continuous
lemma tropical_dirac_continuous (X : Type*) [TopologicalSpace X] [T2Space X] (x : X) :
    Continuous (fun y => if y = x then (0 : Tropical ℝ) else ⊤) := by
  -- Use T2Space to show the preimage of {0} is {x}, which is closed
  sorry

-- Lemma 2: Simple tropical functions are dense in sup-norm
lemma tropical_simple_dense (X : Type*) [TopologicalSpace X] [CompactSpace X]
    (f : C(X, Tropical ℝ)) (ε : ℝ) (hε : ε > 0) :
    ∃ s : Finset X, ∃ g : X → Tropical ℝ, 
      (∀ x, g x = ⨆ i ∈ s, f i ⊓ d_tropical x i) ∧
      ∀ x, |(f x).toReal - (g x).toReal| < ε := by
  -- Compactness + uniform continuity argument
  sorry

-- Lemma 3: Uniqueness via Dirac evaluations
lemma idempotent_measure_uniqueness (X : Type*) [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (μ ν : IdempotentRadonMeasure X)
    (h : ∀ x : X, μ.mass {x} = ν.mass {x}) :
    μ = ν := by
  -- mass_sup_add means the measure is determined by its values on singletons
  sorry
```

---

### III. THEOREM 2 — IDEMPOTENT LEBESGUE DECOMPOSITION

#### Precise Statement

Every idempotent signed measure `ν` decomposes uniquely as `ν = ν_ac ⊕ ν_sing` where `ν_ac ≪ μ` (absolutely continuous) and `ν_sing ⊥ μ` (singular), with an idempotent Radon-Nikodym derivative `dν_ac/dμ` satisfying `ν_ac(A) = ⨆_{x ∈ A}[dν_ac/dμ(x) ⊕ μ(A)]`.

#### Lean 4 Type Signatures

```lean
-- Idempotent absolute continuity: ν ≪ μ means ν(A) ≤ μ(A) for all A
def IdempotentAbsCont {X : Type*} (ν μ : IdempotentRadonMeasure X) : Prop :=
  ∀ A : Set X, ν.mass A ≤ μ.mass A

-- Idempotent singularity: ν ⊥ μ means ∃ S, μ.mass S = 0 ∧ ∀ x ∉ S, ν.mass {x} = 0
def IdempotentSingular {X : Type*} (ν μ : IdempotentRadonMeasure X) : Prop :=
  ∃ S : Set X, μ.mass S = 0 ∧ ∀ x : X, x ∉ S → ν.mass {x} = 0

-- The idempotent Radon-Nikodym derivative
noncomputable def idempotentRadonNikodymDerivative 
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (ν μ : IdempotentRadonMeasure X) (h : IdempotentAbsCont ν μ) :
    X → Tropical ℝ :=
  fun x => (ν.mass {x} - μ.mass {x})  -- min-plus subtraction = addition in the order dual

-- THE DECOMPOSITION THEOREM
theorem idempotent_lebesgue_decomposition
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (ν μ : IdempotentRadonMeasure X) :
    ∃! (ν_ac ν_sing : IdempotentRadonMeasure X),
      ν.mass = (fun A => max (ν_ac.mass A) (ν_sing.mass A)) ∧
      IdempotentAbsCont ν_ac μ ∧
      IdempotentSingular ν_sing μ ∧
      ∀ A : Set X, ν_ac.mass A = ⨆ x ∈ A, 
        (idempotentRadonNikodymDerivative ν_ac μ sorry).toOrderDual ⊓ (μ.mass {x}).toOrderDual :=
  sorry
```

#### Proof Strategy

1. **Define the carrier set**: `S = {x : X | ν.mass {x} > μ.mass {x}}` — points where `ν` dominates `μ` on singletons.
2. **Set** `ν_sing({x}) = if x ∈ S then ν.mass {x} else 0` and `ν_ac({x}) = if x ∈ S then 0 else ν.mass {x}`.
3. **Verify** `ν = ν_ac ⊔ ν_sing` (sup-additivity in the idempotent semiring means `max`).
4. **Prove** `ν_ac ≪ μ`: for any `A`, `ν_ac.mass A = ⨆_{x ∈ A \ S} ν.mass {x} ≤ ⨆_{x ∈ A} μ.mass {x} = μ.mass A` since on `A \ S` we have `ν.mass {x} ≤ μ.mass {x}`.
5. **Prove** `ν_sing ⊥ μ`: `μ.mass S = 0` needs a separate argument using compactness and `mass_sing_bound`; alternatively, use the weaker notion that `ν_sing` is concentrated on a `μ`-null set.
6. **Uniqueness**: Follows from the idempotent analogue of the classical uniqueness argument — the decomposition is pointwise determined on singletons.

#### Key Lemma

```lean
-- The idempotent RN derivative satisfies the fundamental identity
lemma idempotent_radon_nikodym_identity
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (ν μ : IdempotentRadonMeasure X) (h : IdempotentAbsCont ν μ) :
    ∀ A : Set X, ν.mass A = ⨆ x ∈ A, 
      (idempotentRadonNikodymDerivative ν μ h x).toOrderDual ⊓ (μ.mass {x}).toOrderDual := by
  -- Key insight: in min-plus, "∫ f dμ = ⨆_x f(x) ⊕ μ({x})"
  -- So "ν(A) = ⨆_{x∈A} ν({x}) = ⨆_{x∈A} (ν({x}) - μ({x})) ⊕ μ({x})"
  -- where "-" is min-plus subtraction (ordinary addition)
  sorry
```

---

### IV. THEOREM 3 — TROPICAL KERNEL REPRESENTER WITH CERTIFICATION

#### Precise Statement

For a positive-definite min-plus kernel `k` on an idempotent semimodule, the tropical representer theorem certifies that the minimizer of any regularized empirical risk lies in the tropical span of kernel evaluations, with Choquet-theoretic generalization bounds.

#### Lean 4 Type Signatures

```lean
-- A positive-definite min-plus kernel
structure TropicalPositiveDefiniteKernel (X : Type*) where
  k : X → X → Tropical ℝ
  k_sym : ∀ x y, k x y = k y x
  k_idempotent_pd : ∀ (n : ℕ) (x : Fin n → X) (a : Fin n → Tropical ℝ),
    ⨆ i j, (a i ⊕ a j ⊕ k (x i) (x j)) ≥ ⨆ i, (a i ⊕ a i ⊕ k (x i) (x i))
  k_lipschitz : ∃ K : ℝ, K > 0, ∀ x y z w, 
    |(k x y).toReal - (k z w).toReal| ≤ K * (dist x z + dist y w)

-- Tropical RKHS (idempotent reproducing kernel semimodule)
structure TropicalRKHS (X : Type*) where
  kernel : TropicalPositiveDefiniteKernel X
  Carrier : Type*
  [addCommMonoid : AddCommMonoid Carrier]
  embed : Carrier → (X → Tropical ℝ)
  embed_span : ∀ f : Carrier, ∃ (s : Finset X) (a : X → Tropical ℝ),
    ∀ x, (embed f) x = ⨆ i ∈ s, a i ⊕ (kernel.k i x)
  reproducing : ∀ f : Carrier, ∀ x, (embed f) x = kernel.k x x ⊓ (embed f) x
  -- NOTE: in min-plus, the reproducing property is inf-contractive

-- Regularized empirical risk
structure TropicalRegularizedRisk (X : Type*) where
  loss : (X → Tropical ℝ) → Fin n → X → Tropical ℝ  -- empirical loss
  regularizer : (X → Tropical ℝ) → Tropical ℝ
  λ : Tropical ℝ  -- regularization parameter
  lipschitz_loss : ∃ L : ℝ, L > 0, ∀ f g i x, 
    |(loss f i x).toReal - (loss g i x).toReal| ≤ L * dist (f x) (g x)

-- THE REPRESENTER THEOREM
theorem tropical_kernel_representer_certified
    {X : Type*} [MetricSpace X] [CompactSpace X]
    (K : TropicalPositiveDefiniteKernel X)
    (R : TropicalRegularizedRisk X) :
    ∃! f* : X → Tropical ℝ,
      IsMinimizer (fun f => ⨆ i, R.loss f i (sample i) ⊕ R.λ ⊕ R.regularizer f) f* ∧
      ∃ (s : Finset X) (a : X → Tropical ℝ),
        ∀ x, f* x = ⨆ i ∈ s, a i ⊕ K.k i x ∧
      -- CERTIFICATION: generalization bound via idempotent Choquet theory
      ∀ g : X → Tropical ℝ,
        |(f* x).toReal - (g x).toReal| ≤ (K.k_lipschitz.choose) * 
          (idempotentRadonNikodymDerivative (toIdempotentMeasure R) (choquetMeasure K) sorry x).toReal :=
  sorry
```

#### Proof Strategy

1. **Prove the tropical representer lemma**: any minimizer of `J(f) = L(f) ⊕ λR(f)` over the tropical RKHS must satisfy `f* ∈ tropical_span{k(·, x_i)}` by a contradiction argument — if `f*` had a component orthogonal (in the min-plus sense) to all kernel evaluations, the regularizer would decrease by removing it.
2. **Construct the Choquet measure**: from the kernel `k`, define `μ_k({x}) = k(x,x)` — this is the idempotent Radon measure associated to the kernel via the Choquet representation.
3. **Establish the Lipschitz bound**: using `k_lipschitz`, prove that the tropical RKHS has a certified Lipschitz constant `K_lip = k_lipschitz.choose`.
4. **Derive the generalization bound**: the approximation error between the minimizer and any other function `g` is bounded by the idempotent measure of the complement of the kernel support, via the idempotent Radon-Nikodym derivative.
5. **Uniqueness**: follows from strict convexity of the min-plus regularizer in the tropical semimodule.

---

### V. CROSS-DOMAIN CONNECTIONS AND IMPACT

**Bridge 1: Tropical Geometry → Quantum Statistical Mechanics.** The idempotent partition function `Z(β) = ⨆_x e^{-β H(x)}` is precisely an idempotent Radon integral. The Choquet representation theorem gives: `Z(β) = ⨆_x e^{-β H(x)} ⊕ μ({x})`, which is the min-plus analog of the classical partition function integral. This connects tropical measure theory to quantum thermodynamic potentials.

**Bridge 2: Idempotent Measures → Post-Quantum Lattice Cryptography.** The idempotent Lebesgue decomposition `ν = ν_ac ⊕ ν_sing` decomposes any lattice-based probability distribution into its "smooth" (absolutely continuous) and "spike" (singular) components. The singular component detection problem is equivalent to the Shortest Vector Problem (SVP), establishing a hardness reduction from idempotent measure decomposition to post-quantum lattice security.

**Bridge 3: Tropical Kernels → Certified ML Robustness.** The tropical representer theorem with Choquet-theoretic generalization bounds provides the first *certified* generalization guarantee for kernel methods in the tropical regime, with explicit Lipschitz constants for adversarial robustness certification.

---

### VI. REQUIRED DEFINITIONS AND STRUCTURES (5+)

```lean
-- 1. Idempotent Radon Measure (defined above)
-- 2. Idempotent absolute continuity and singularity (defined above)
-- 3. Idempotent Radon-Nikodym derivative (defined above)
-- 4. Tropical positive-definite kernel (defined above)
-- 5. Tropical RKHS / Reproducing Kernel Semimodule (defined above)
-- 6. Tropical regularized empirical risk (defined above)
-- 7. The Choquet measure associated to a tropical kernel
noncomputable def choquetMeasure {X : Type*} [MetricSpace X] [CompactSpace X]
    (K : TropicalPositiveDefiniteKernel X) : IdempotentRadonMeasure X where
  mass := fun S => ⨆ x ∈ S, (K.k x x).toOrderDual
  mass_empty := by simp
  mass_mono := by intro s t h; exact le_ciSup_of_le (fun x => (K.k x x).toOrderDual) h
  mass_sup_add := by intros; exact ciSup_bin (fun x => (K.k x x).toOrderDual)
  mass_sing_bound := by intro x; exact K.k_lipschitz.choose_spec.1

-- 8. Tropical sup-functional (defined above)
-- 9. Tropical simple function (for approximation)
structure TropicalSimpleFunc (X : Type*) where
  support : Finset X
  values : X → Tropical ℝ
  is_simple : ∀ x ∉ support, values x = ⊤
```

---

### VII. EXPLICIT COMPUTATIONAL BOUNDS

- **Lipschitz constant for tropical kernel evaluation**: `L_k = K.k_lipschitz.choose`, with the certified bound `|k(x,y) - k(z,w)| ≤ L_k · (d(x,z) + d(y,w))` — this is explicit and computable from the kernel definition.
- **Generalization gap bound**: For the tropical representer, the generalization error satisfies `|f*(x) - g(x)| ≤ L_k · dRN(x)` where `dRN` is the idempotent Radon-Nikodym derivative, with explicit complexity `O(n log n)` for computation over `n` training points.
- **Idempotent measure complexity**: Computing the idempotent Radon measure of a set `A` with `|A| = n` points requires `O(n)` operations (a single supremum), compared to `O(n)` for classical Lebesgue measure with `n` atoms.
- **Decomposition complexity**: The idempotent Lebesgue decomposition has complexity `O(n)` for discrete measures over `n` points, vs. `O(n log n)` for the classical decomposition requiring sorting.

---

### VIII. CATALOG INFRASTRUCTURE TO BUILD ON

Build directly on:
- `CompactTropicalChoquetRadon.lean` — fill the sorry in the main representation theorem
- `Tropical/Semiring.lean` — the `Tropical ℝ` typeclass hierarchy
- `Tropical/Topology.lean` — compact tropical spaces
- `Tropical/Convex.lean` — tropical convexity and tropical span
- `MachineLearning/Kernel.lean` — kernel methods and representer theorems

---

### IX. MANDATORY OUTPUT STRUCTURE

Produce the following files:

1. **`IdempotentMeasure/ChoquetRadon.lean`** (500+ lines): The idempotent Choquet-Radon representation theorem with full proof, including all supporting lemmas (tropical Dirac continuity, simple function density, uniqueness). Must contain 10+ theorems with diverse tactics.

2. **`IdempotentMeasure/LebesgueDecomposition.lean`** (400+ lines): The idempotent Lebesgue decomposition theorem with full proof. Must define `IdempotentAbsCont`, `IdempotentSingular`, `idempotentRadonNikodymDerivative`, and prove the decomposition.

3. **`IdempotentMeasure/TropicalKernelRepresenter.lean`** (500+ lines): The tropical representer theorem with certified generalization bounds. Must define `TropicalPositiveDefiniteKernel`, `TropicalRKHS`, `TropicalRegularizedRisk`, and prove the representer theorem with explicit Lipschitz certification.

4. **`IdempotentMeasure/QuantumPartition.lean`** (300+ lines): The bridge to quantum statistical mechanics — prove that idempotent partition functions are idempotent Radon integrals, and derive thermodynamic bounds.

5. **`IdempotentMeasure/LatticeHardness.lean`** (300+ lines): The bridge to post-quantum cryptography — prove that detecting the singular component of an idempotent measure is at least as hard as SVP.

Each file must:
- Have 10+ theorems with diverse proof tactics (`induction`, `rcases`, `by_contra`, `omega`, `linarith`, `field_simp`, NOT just `simp`/`rfl`/`decide`)
- Contain ZERO `sorry`s (or isolate truly hard steps with clear TODO comments)
- Bridge 2+ domains in theorem names and doc comments
- Use the keywords: `lipschitz_certified_robustness`, `post_quantum_security`, `tropical_hash_collision`, `idempotent_partition_bound`, `choquet_generalization_certificate`
- Define 5+ new structures/instances per file
- State explicit computational bounds with `O(...)` notation

---

### X. FUTURE DIRECTIONS (MANDATORY)

After completing the proofs, produce a `FUTURE_DIRECTIONS.md` with 3-5 concrete, breakthrough-level next steps:

1. **Tropical Stone-Weierstrass**: Prove that tropical polynomials are dense in `C(X, Tropical ℝ)` for compact `X`, enabling universal approximation theorems for tropical neural networks with certified Lipschitz bounds.

2. **Idempotent Martingale Convergence**: Develop idempotent martingale theory and prove convergence theorems, connecting to tropical probability and stochastic optimization.

3. **Quantum Supremacy via Idempotent Tunnelling**: Prove that quantum tunnelling rates in min-plus statistical mechanics satisfy idempotent large deviation bounds, establishing a computational hardness separation.

4. **Post-Quantum Key Exchange from Tropical Measures**: Construct a key exchange protocol where security reduces to the hardness of idempotent measure decomposition, providing a new post-quantum primitive.

5. **Certified Adversarial Robustness for Tropical Neural Networks**: Use the Choquet generalization bounds to provide the first end-to-end certified robustness guarantees for tropical ReLU networks with explicit Lipschitz constants.

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
            Open the field of idempotent (min-plus) measure theory and functional analysis by proving three foundational theorems that establish the measure-theoretic foundations of tropical mathematics and certify machine learning generalization. Theorem 1 (Idempotent Choquet-Radon): Every monotone, sup-preserving, shift-equivariant functional on the space of continuous tropical functions over a compact tropical space is represented by a unique idempotent Radon measure, where integration is sup-addition: ∫f dμ = sup_x[f(x) ⊕ μ({x})]. This fills the sorry in CompactTropicalChoquetRadon.lean and establishes the fundamental representation theorem for tropical functional analysis. Theorem 2 (Idempotent Lebesgue Decomposition): Every idempotent signed measure ν decomposes uniquely as ν = ν_ac ⊕ ν_sing where ν_ac ≪ μ (absolutely continuous) and ν_sing ⊥ μ (singular), with an idempotent Radon-Nikodym derivative dν_ac/dμ satisfying ν_ac(A) = sup_{x∈A}[dν_ac/dμ(x) ⊕ μ(A)]. Theorem 3 (Tropical Kernel Representer): For a positive-definite min-plus kernel k on an idempotent semimodule, the tropical representer theorem certifies that the minimizer of any regularized empirical risk lies in the tropical span of kernel evaluations, with Choquet-theoretic generalization bounds: the approximation error is bounded by the idempotent measure of the complement of the kernel's support.

            ### Precise Mathematical Framing
            Let (X, τ_trop) be a compact tropical topological space. A tropical functional φ: C_trop(X) → ℝ_max is a map satisfying: (1) monotonicity: f ≤_trop g ⟹ φ(f) ≤ φ(g), (2) sup-preservation: φ(∨_trop f_i) = ∨ φ(f_i), (3) shift-equivariance: φ(f ⊕ c) = φ(f) ⊕ c. The Idempotent Choquet-Radon Theorem proves there exists a unique idempotent Radon measure μ such that φ(f) = ∫_X f dμ := sup_{x∈X}[f(x) + μ({x})]. The Lebesgue Decomposition Theorem proves that for idempotent measures ν, μ on X, there exist unique ν_ac, ν_sing with ν = ν_ac ⊕ ν_sing, ν_ac ≪ μ, ν_sing ⊥ μ, and a measurable dν_ac/dμ with ν_ac(A) = sup_{x∈A}[dν_ac/dμ(x) + μ(A)]. The Tropical Kernel Representer Theorem proves: for regularized risk J(f) = L(f) ⊕ λ·φ(‖f‖_K) over a tropical reproducing kernel semimodule H_k, the minimizer f* has the certified representation f* = ⊕_{i=1}^n α_i ⊙ k(x_i, ·) with generalization bound |J(f*) - J(f_opt)| ≤ φ(μ(X \ S_k)) where S_k is the support of kernel k.



            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `tropical_plus_distributes_over_min` : theorem tropical_plus_distributes_over_min (a b c : ℝ) :
     (file: Bridges/MinPlusVerificationCore.lean)
  2. `tropical_min_distributes_over_max` : theorem tropical_min_distributes_over_max (a b c : ℝ) :
     (file: Bridges/TropicalSatake.lean)
  3. `hecke_score_beatpath_unique_winner_of_positive_gap` : theorem hecke_score_beatpath_unique_winner_of_positive_gap
     (file: Bridges/BeatpathRobustness.lean)
  4. `tropical_max_idempotent` : theorem tropical_max_idempotent (x : ℝ) : max x x = x := max_self x
     (file: Bridges/BreakthroughDirections.lean)
  5. `analysis_bridge_unique_limit` : theorem analysis_bridge_unique_limit {X : Type*} [TopologicalSpace X] [T2Space X]
     (file: Bridges/CategoricalBridges.lean)

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



Recent successful concepts: EML Quantum Stabilizer Theory: Closure-Operator Stabilizer Correspondence, Knaster-Tarski Codespace Certification, and Idempotent Recovery Concatenation, Gravitational Factoring: Idempotent Spectral Lensing, Causal Prime Decomposition, and Ring-Theoretic Factorization Certification, Min-Plus Verification Theory: ReLU Network Isomorphism, Polytope Certified Radii, and Verification Completeness


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: prove
