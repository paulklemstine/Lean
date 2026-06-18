# Future Directions: Closure–Secret-Sharing Duality

## Research Roadmap for Breakthrough Next Steps

This document outlines five concrete, theorem-grade research directions opened by the closure–secret-sharing duality via idempotent access semimodules.

---

## Direction 1: Complexity Lower Bounds via Semimodule Dimension

### Vision
The semimodule dimension (= number of basis elements = size of the antichain of minimal authorized coalitions) is a natural complexity measure for access structures. Proving that certain access structures require large semimodule dimension would yield lower bounds on secret-sharing scheme sizes — a major open problem in theoretical cryptography.

### Concrete Theorem Targets

**Theorem 1.1 (Dimension Lower Bound for Graph Access Structures).**
For the access structure defined by a graph $G = (V, E)$ where authorized coalitions are edge covers, the semimodule dimension equals $|E|$ (the number of edges).

```
theorem graph_access_semimodule_dimension
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    (minimalAuthorizedBasis ...).ncard = G.edgeFinset.card
```

**Theorem 1.2 (Superpolynomial Dimension Family).**
There exists an explicit family of access structures on $n$ participants whose semimodule dimension is $2^{\Omega(n)}$.

*Strategy:* Use the access structure based on monotone self-dual Boolean functions, which are known to have exponentially many minimal terms.

### Proof Strategy
1. Show the semimodule dimension equals the number of minimal authorized coalitions.
2. Connect to Dedekind numbers (antichains of the Boolean lattice).
3. Use known asymptotic bounds on Dedekind numbers to derive exponential lower bounds.

### Cross-Domain Impact
- Resolves whether idempotent semimodule realization can be polynomially efficient in general.
- Connects secret-sharing complexity to antichain enumeration problems in combinatorics.
- Opens a route to tropical analogues of monotone circuit complexity.

---

## Direction 2: Tropical Monotone Span Program Complexity

### Vision
Classical monotone span programs (MSP) over fields realize access structures via linear algebra. Our idempotent semimodule realization is the tropical/idempotent analogue. Comparing the complexity of realization over fields vs. idempotent semirings would reveal structural differences between linear and tropical geometry relevant to cryptography.

### Concrete Theorem Targets

**Theorem 2.1 (Tropical MSP Simulation).**
Every monotone span program over a field $\mathbb{F}$ can be simulated by an idempotent access semimodule of dimension at most $2^d$, where $d$ is the MSP width.

**Theorem 2.2 (Separation: Tropical vs. Linear).**
There exists an access structure with MSP width $O(\log n)$ but idempotent semimodule dimension $\Omega(n)$.

*Strategy:* The access structure associated with the inner product function has logarithmic MSP width (via XOR computations) but no compact idempotent representation (since OR cannot simulate XOR efficiently).

### Proof Strategy
1. Formalize monotone span programs as matrix factorization problems.
2. Define a "tropical span" notion and compare with linear span.
3. Use the known separation between monotone and general circuit complexity to derive a tropical vs. linear separation.

### Cross-Domain Impact
- First formal comparison of tropical vs. classical secret-sharing complexity.
- Connects to the monotone NC hierarchy and circuit complexity.
- May yield new proof techniques for MSP lower bounds.

---

## Direction 3: Categorical Equivalence of Closure Profiles and Reconstruction Certificates

### Vision
The object-level correspondence (closure ↔ access structure ↔ semimodule ↔ certificate) should lift to a categorical equivalence. This would make the duality functorial, enabling compositional reasoning about combined access structures.

### Concrete Theorem Targets

**Theorem 3.1 (Categorical Equivalence).**
There is an equivalence of categories:
$$\mathbf{FinAccCl} \simeq \mathbf{AntiChain} \simeq \mathbf{IdempSemimod}$$
where:
- $\mathbf{FinAccCl}$ = finite accessible closure profiles with closure morphisms
- $\mathbf{AntiChain}$ = finite antichains of finite sets with containment-preserving maps
- $\mathbf{IdempSemimod}$ = finite idempotent access semimodules with authorization-preserving maps

```
def ClosureAccessCategory : Category where
  Obj := FiniteAccessClosureProfile
  Hom := ClosurePreservingMap
  ...

def AntichainCategory : Category where
  Obj := FiniteAntichain
  Hom := ContainmentPreservingMap
  ...

theorem closure_antichain_equivalence :
    ClosureAccessCategory ≌ AntichainCategory
```

### Proof Strategy
1. Define morphisms in each category (closure-preserving, containment-preserving, authorization-preserving).
2. Show the object-level constructions extend to functors on morphisms.
3. Prove natural isomorphisms for the round-trip compositions.

### Cross-Domain Impact
- Enables compositional security proofs: policies can be combined categorically.
- Connects to formal concept analysis (FCA) and Galois connections.
- Opens a path to higher-categorical generalizations (2-categories of access structures with natural transformations as policy refinements).

---

## Direction 4: Weighted and Probabilistic Access via Valuation Semirings

### Vision
Replace Boolean authorization (yes/no) with quantitative authorization via valuation semirings. This models:
- **Weighted secret sharing:** Different coalitions may have different costs.
- **Probabilistic access:** Authorization with confidence levels.
- **Information-theoretic capacity:** How much information each coalition extracts.

### Concrete Theorem Targets

**Theorem 4.1 (Weighted Closure-Capacity Duality).**
For a closure operator $\text{cl}$ and a monotone capacity $\mu : \mathcal{P}(X) \to \mathbb{R}_{\geq 0}$ with $\mu(A) = \mu(\text{cl}(A))$, the thresholded authorization at level $\tau$ is an access structure whose minimal basis can be computed from the capacity function.

```
theorem weighted_closure_capacity_basis
    {X Y : Type*} [Fintype X] [DecidableEq X]
    (cl : Set Y → Set Y) (μ : Set X → ℝ) (τ : ℝ)
    (hcl : IsClosureOperator cl)
    (hμ_mono : Monotone μ) :
    ∃ B : Set (Finset X),
      (∀ A, τ ≤ μ A ↔ ∃ U ∈ B, ↑U ⊆ A) ∧
      IsAntichain (· ⊆ ·) B
```

**Theorem 4.2 (Tropical Information Duality).**
The closure-capacity realization factors through a tropical information functional, connecting the p-adic closure information duality of `PadicClosureInformationDuality.lean` with the access structure semantics.

### Proof Strategy
1. Extend the `ClosureCapacitySecretSharingDuality` framework with real-valued capacities.
2. Show that capacity thresholding preserves the antichain basis structure.
3. Connect to the existing `TropicalClosureInformation` formalization.

### Cross-Domain Impact
- Bridges secret-sharing with information theory (Shannon entropy, Rényi entropy).
- Connects to optimal transport and Wasserstein distances on access structures.
- Opens applications in differential privacy (access with noise).

---

## Direction 5: Role-Hierarchy Closure Semantics for RBAC Systems

### Vision
Role-Based Access Control (RBAC) is the dominant paradigm in enterprise security. The closure–secret-sharing duality provides a mathematical semantics for RBAC: roles define a closure operator on participants, and the authorization structure is the induced access structure.

### Concrete Theorem Targets

**Theorem 5.1 (RBAC Closure Semantics).**
Every RBAC policy with role hierarchy defines a closure operator whose minimal authorized basis corresponds exactly to the minimal authorized role-sets.

```
structure RBACPolicy (User Role : Type*) where
  has_role : User → Role → Prop
  role_hierarchy : Role → Role → Prop  -- subrole relation
  authorized_roles : Set (Set Role)

theorem rbac_is_closure_access_structure
    (P : RBACPolicy User Role) :
    ∃ cl : Set User → Set User,
      IsClosureOperator cl ∧
      ∀ S : Set User,
        P.isAuthorized S ↔ S ∈ closureAuth ... cl
```

**Theorem 5.2 (Hierarchical Compression).**
For an RBAC policy with $r$ roles arranged in a tree hierarchy of depth $d$, the antichain basis has size at most $r^d$.

**Theorem 5.3 (RBAC Composition).**
The closure semantics of composed RBAC policies (intersection, union, separation of duties) corresponds to lattice operations on the associated antichains.

### Proof Strategy
1. Model the role hierarchy as a partial order.
2. Define the induced closure: $\text{cl}(S) = S \cup \{u \mid u \text{ inherits sufficient roles from } S\}$.
3. Apply the antichain basis theorem to extract minimal authorized user groups.
4. For composition, use the lattice structure of upward-closed families.

### Cross-Domain Impact
- Provides mathematical foundations for RBAC policy analysis.
- Enables formal verification of policy consistency and completeness.
- Connects enterprise security to lattice theory and formal concept analysis.
- Algorithmic: the antichain basis gives the minimal policy description, useful for policy auditing and optimization.

---

## Summary: Priority Ranking

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|--------------|
| 1. Dimension lower bounds | High | Very High | Combinatorics of antichains |
| 2. Tropical MSP complexity | High | High | Circuit complexity connections |
| 3. Categorical equivalence | Medium | High | Category theory in Lean |
| 4. Weighted/probabilistic | Medium | Medium | Existing capacity framework |
| 5. RBAC semantics | Low-Medium | High | Practical applications |

**Recommended order:** Start with Direction 5 (most immediately applicable), then Direction 4 (extends existing formalization), then Direction 3 (foundational), then Directions 1–2 (hard, high-impact).

---

## Technical Prerequisites

All directions benefit from:
- The antichain basis theorem (Theorem B) as the central tool.
- The semimodule realization (Theorem C) as the algebraic bridge.
- The certified reconstruction (Theorem E) as the algorithmic output.

Directions 1–2 additionally require:
- Formalization of monotone Boolean functions and their complexity measures.
- Connection to existing Mathlib results on Dedekind numbers (if available) or combinatorial bounds.

Directions 3–4 additionally require:
- Category theory infrastructure from Mathlib (`CategoryTheory.*`).
- The `PadicClosureInformationDuality` and `ClosureCapacitySecretSharingDuality` formalizations.

Direction 5 requires:
- A formalization of RBAC policy structure (straightforward).
- Connection to practical security policy languages (XACML, Cedar).
