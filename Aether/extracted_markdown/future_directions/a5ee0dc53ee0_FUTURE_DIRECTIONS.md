# Future Directions: Closure-Capacity Cryptography

This document outlines concrete research opportunities opened by the formalization of closure-capacity secret-sharing duality.

---

## Direction 1: Submodular/Entropy Strengthening to Polymatroid Secret Sharing

**Goal**: Strengthen the monotone capacity assumption to full submodularity and derive polymatroid-based bounds on information rates of secret-sharing schemes.

**Concrete theorem target**:
```
theorem polymatroid_rate_bound
    (cl : Set α → Set α) (cap : Set α → ℝ)
    (hsub : ∀ A B, cap(cl(A ∪ B)) + cap(cl(A ∩ B)) ≤ cap(cl A) + cap(cl B))
    (hcap_mono : Monotone cap) :
    ∀ M, MinimalAuthorized cl cap t M →
      |M| ≤ cap(cl M) / (t - max_{B ⊂ M} cap(cl B))
```

**Proof strategy**: Use the submodularity inequality iteratively on chains of proper subsets. This yields a telescoping bound connecting the size of a minimal authorized set to the capacity gap at threshold. The key insight is that submodularity forces the "marginal capacity gain" from each new element to decrease, producing a polymatroid rank bound.

**Cross-domain connection**: This connects directly to the entropy method in combinatorics (Shearer's lemma, Han's inequality) and to the information-theoretic bounds on secret-sharing due to Capocelli–De Santis–Gargano–Vaccaro.

**Impact**: Would provide the first formalized bridge between closure-theoretic secret sharing and information-theoretic lower bounds on share size.

---

## Direction 2: Tropical Linear Secret Sharing over Idempotent Semirings

**Goal**: Realize closure-capacity access structures as tropical linear algebra objects, where shares are elements of a min-plus semimodule and reconstruction is a tropical matrix equation.

**Concrete theorem target**:
```
theorem tropical_linear_realization
    (𝒜 : FiniteAccessStructure α)
    (h_matroidal : IsMatroidalAccessStructure 𝒜) :
    ∃ (M : Matrix (Fin n) (Fin m) (Tropical ℕ)),
      ∀ A, A ∈ 𝒜.auth ↔ tropicalRank (M.submatrix A id) ≥ 1
```

**Proof strategy**: For matroidal access structures (those arising from matroids), the representation matrix can be constructed from the matroid's tropical Grassmannian coordinates. The key step is showing that the tropical rank of the restriction to columns indexed by a coalition equals 1 iff the coalition is authorized. Use the Dress–Wenzel theory of valuated matroids as the algebraic bridge.

**Cross-domain connection**: Links to tropical geometry (tropical Grassmannians), coding theory (MDS codes as threshold schemes), and the Beimel–Livne–Padró characterization of ideal secret-sharing matroids.

**Impact**: Would create a new "tropical cryptography" where secret-sharing synthesis reduces to tropical linear algebra.

---

## Direction 3: Categorical Equivalence with Monotone Span Programs

**Goal**: Prove that the category of finite closure-capacity systems (with appropriate morphisms) is equivalent to a category of monotone span programs, providing a dictionary between closure semantics and linear-algebraic secret sharing.

**Concrete theorem target**:
```
theorem closure_capacity_span_program_equivalence :
    ClosureCapacityCat ≌ MonotoneSpanProgramCat
```

**Proof strategy**: The forward functor sends a closure-capacity system to its "linearization" — a span program whose target vector is the capacity function viewed as a linear functional. The inverse functor extracts a closure operator from the span program's kernel structure. Fully faithful follows from the reconstruction theorem (Theorem 3): closure-capacity morphisms are determined by their action on minimal authorized sets, and span program morphisms are determined by their action on generators.

**Cross-domain connection**: Monotone span programs are the standard model for linear secret-sharing schemes (Karchmer–Wigderson). This equivalence would formalize the folk wisdom that "closure = span" in secret-sharing theory.

**Impact**: Provides a formal bridge enabling automatic translation of results between the closure-theoretic and linear-algebraic approaches to secret sharing.

---

## Direction 4: Complexity Lower Bounds from Closure-Basis Spectra

**Goal**: Extract circuit complexity lower bounds from the structure of the closure-basis spectrum (the family of all minimal authorized sets viewed as a hypergraph).

**Concrete theorem target**:
```
theorem closure_basis_complexity_bound
    (𝒜 : FiniteAccessStructure (Fin n))
    (h : ∀ M ∈ minimals 𝒜, |M| = k) :
    monotoneCircuitComplexity 𝒜 ≥ n * (n - 1) / (k * (k - 1))
```

**Proof strategy**: Use the Friedman–Wigderson entropy argument: the number of minimal authorized sets of uniform size k in an n-element access structure gives a lower bound on the monotone circuit complexity via a counting argument on edge-disjoint paths in the circuit DAG. The closure-basis characterization (Theorem 1b) provides the geometric interpretation: each minimal authorized set corresponds to an independent basis in the closure lattice, and the independence structure constrains the circuit topology.

**Cross-domain connection**: Links closure-capacity duality to monotone circuit complexity, the Razborov–Alon–Boppana lower bounds, and the Jukna–Sergeev approach via hypergraph coloring.

**Impact**: Would provide a new proof technique for monotone complexity lower bounds grounded in closure geometry rather than communication complexity.

---

## Direction 5: Quantum and Noncommutative Closure-Capacity Analogues

**Goal**: Extend closure-capacity duality to quantum secret sharing, where the closure operator acts on subspaces of a Hilbert space and capacity is replaced by von Neumann entropy.

**Concrete theorem target**:
```
theorem quantum_closure_capacity_authorized_monotone
    (H : HilbertSpace) (cl : Subspace H → Subspace H)
    (S : DensityOperator H)
    (cap : Subspace H → ℝ := vonNeumannEntropy ∘ partialTrace S)
    (t : ℝ) :
    ∀ V W : Subspace H, V ≤ W → cap (cl V) ≤ cap (cl W) →
      Authorized cl cap t V → Authorized cl cap t W
```

**Proof strategy**: The quantum case requires replacing set-theoretic closure with subspace closure (the generated operator algebra) and monotone capacity with a conditional entropy function derived from partial traces. The key technical challenge is proving that partial trace preserves the submodularity structure needed for the exchange theorem. Use the strong subadditivity of von Neumann entropy (Lieb–Ruskai) as the quantum analogue of submodularity.

**Cross-domain connection**: Connects to quantum error correction (the Knill–Laflamme conditions as closure-capacity thresholds), topological quantum computing (anyonic fusion as a closure operation), and the theory of quantum Markov chains.

**Impact**: Would provide the first formal framework unifying classical and quantum secret sharing through closure-capacity semantics, potentially enabling quantum-to-classical reduction theorems for access structure realizability.

---

## Summary of Priority Ordering

| Priority | Direction | Estimated Difficulty | Mathlib Readiness |
|----------|-----------|---------------------|-------------------|
| 1 | Submodular/Entropy bounds | Medium | High (basic order theory present) |
| 2 | Tropical linear realization | High | Medium (tropical semirings exist) |
| 3 | Span program equivalence | High | Low (needs MSP formalization) |
| 4 | Complexity lower bounds | Medium | Low (needs circuit complexity) |
| 5 | Quantum analogues | Very High | Low (needs quantum formalism) |

Direction 1 is the most immediately actionable: it requires only strengthening the existing monotonicity assumption to submodularity and proving the resulting combinatorial bounds. Directions 2-3 would create the most impact by connecting to existing algebraic and computational frameworks. Directions 4-5 are the most ambitious but offer the deepest new insights.
