# Future Directions: Composable Proof Schemata

## Overview

The formal theory of composable proof schemata opens several breakthrough-level research directions. Each direction below identifies specific target definitions, theorems, and cross-domain connections that would constitute genuine advances in formal meta-mathematics.

---

## Direction 1: A Category of Proof Architectures with Functorial Semantics

### Vision
Extend the current monoid of proof schemata on a fixed type to a full **category** where:
- **Objects** are mathematical domains (types equipped with structure)
- **Morphisms** are proof schemata that transform predicates *across* domains
- **Functors** from this category to the category of propositions give semantics

### Target Definitions
```
structure InterSchema (α β : Type*) where
  ReducesTo : (α → Prop) → (β → Prop) → Prop
  sound : ∀ {P Q}, ReducesTo P Q → (∀ y, Q y) → (∀ x, P x)

def InterSchema.comp {α β γ} (S : InterSchema α β) (T : InterSchema β γ) :
    InterSchema α γ
```

### Target Theorems
1. **Functoriality:** Prove that schema composition respects identity and associativity across types.
2. **Natural transformations:** Define schema morphisms (transformations between schemata) and prove they compose.
3. **Adjunctions:** Identify adjoint pairs of schemata (e.g., descent ⊣ lifting).

### Why This Opens a Field
A category of proof architectures would provide:
- A formal language for comparing proof methods across different mathematical domains
- Functorial transfer of proof strategies: a strategy that works for groups automatically transfers to rings via a functor
- A topos-theoretic framework for "proof universes" where logical connectives have geometric meaning

### Cross-Domain Connection
This connects to **categorical logic** (Lawvere, Lambek–Scott) and **institutions** in formal specification theory (Goguen–Burstall). The novel contribution is treating *proof strategies*, not just logical systems, as categorical objects.

---

## Direction 2: Obstruction Theory for Graph Minors and Finite Group Local Data

### Vision
Instantiate the finite core schema on two concrete, deep mathematical domains:
- **Robertson-Seymour theory:** Every minor-closed graph property has a finite obstruction set
- **CFSG local structure:** Local subgroup data determines global group structure

### Target Definitions
```
structure MinorClosedProperty (V : Type*) where
  P : SimpleGraph V → Prop
  minor_closed : ∀ G H, G.IsMinor H → P H → P G
  finite_obstruction : ∃ S : Finset (SimpleGraph V), ∀ G, P G ↔ ∀ H ∈ S, ¬G.IsMinor H

def LocalGroupDatum (G : Type*) [Group G] where
  localSubgroups : Finset (Subgroup G)
  determines_structure : ...
```

### Target Theorems
1. **Finite obstruction schema:** For any minor-closed property, construct a `FiniteCoreSchema` whose core is the obstruction set.
2. **Local-to-global for groups:** Formalize the principle that a finite group is determined by its system of local subgroups (p-local subgroups for each prime p dividing the order).
3. **Composition:** Show that Robertson-Seymour obstruction and group-local analysis are both instances of the same `FiniteCoreSchema` pattern.

### Why This Opens a Field
This would create the first formal bridge between graph minor theory and finite group theory through a common meta-mathematical framework. It would also give a formal foundation for the "finite obstruction" paradigm that appears in topology (forbidden minors for embeddability), algebra (Tits buildings), and combinatorics (Ramsey theory).

### Cross-Domain Connection
- **Topology:** Forbidden surface minors characterize embeddability
- **Complexity theory:** Graph minor theory underlies fixed-parameter tractability (kernelization)
- **AI/ML:** Obstruction sets are analogous to "hard instances" in learning theory

---

## Direction 3: Certified Extraction of ATP Search Strategies from Schema Compositions

### Vision
Use proved schema composition theorems to **automatically generate** search strategies for automated theorem provers. The idea: a composed proof schema provides a certified decomposition of a proof goal into subgoals, which can guide an ATP's search.

### Target Definitions
```
structure SearchStrategy (α : Type*) where
  decompose : (α → Prop) → List (α → Prop)
  certify : ∀ P, (∀ Q ∈ decompose P, ∀ x, Q x) → ∀ x, P x

def fromSchema (S : ProofSchema α) : SearchStrategy α := ...
```

### Target Theorems
1. **Strategy extraction:** Every composition of n schemata yields a search strategy that decomposes goals into ≤ n subgoals.
2. **Completeness:** If the schemata cover all proof patterns in a domain, the extracted strategy is complete for that domain.
3. **Complexity bounds:** The search space reduction from using schema-guided search vs. blind search.

### Why This Opens a Field
Current ATPs use fixed heuristics (e.g., "try induction," "try case analysis"). Schema-guided search would provide *mathematically certified* heuristics that adapt to the problem structure. This is the formal analogue of a mathematician recognizing "this looks like a descent argument" — but with machine-checked guarantees.

### Cross-Domain Connection
- **AI/ML:** Connects to meta-learning and learning-to-prove
- **Program synthesis:** Schema composition as program sketching
- **Planning:** Proof schemata as planning operators with certified preconditions/postconditions

---

## Direction 4: Arithmetic-Geometric Bridge via Descent and Rigidity for Elliptic Curves

### Vision
Instantiate descent and rigidity schemata on a toy model of elliptic curve arithmetic, formalizing the structural skeleton of the Mordell-Weil theorem (finite generation of rational points).

### Target Definitions
```
-- Simplified elliptic curve model
structure EllipticCurveModel where
  a b : ℤ
  discriminant_nonzero : 4 * a^3 + 27 * b^2 ≠ 0

-- Height function (measure for descent)
def naiveHeight (P : ℤ × ℤ) : ℕ := (P.1.natAbs + P.2.natAbs)

-- Descent schema for EC points
def ecDescentSchema (E : EllipticCurveModel) : DescentSchema (ℤ × ℤ) where
  μ := naiveHeight
  step := ... -- 2-descent: every point reduces via isogeny
```

### Target Theorems
1. **Descent on height:** Formalize the key step of Mordell-Weil descent: the quotient E(Q)/2E(Q) is finite.
2. **Rigidity via invariant:** The j-invariant classifies elliptic curves up to isomorphism; formalize this as an instance of `finite_invariant_classification`.
3. **Composition:** The Mordell-Weil proof combines descent (for finite generation) with rigidity (for the structure of the torsion subgroup). Show this composition is an instance of `global_theorem_of_strategy_triad`.

### Why This Opens a Field
This would connect the abstract schema framework to one of the deepest areas of number theory. Even a toy model formalization would demonstrate that the schema framework captures real mathematical content, not just logical trivialities. It would also provide a roadmap for eventually formalizing the full Mordell-Weil theorem as a schema composition.

### Cross-Domain Connection
- **Cryptography:** Elliptic curve cryptography relies on the difficulty of the discrete log problem on EC groups
- **Algebraic geometry:** Descent is the fundamental tool of the Brauer-Manin obstruction
- **Physics:** Elliptic curves appear in string theory and mirror symmetry

---

## Direction 5: Finite-Core Extraction as Kernelization in Parameterized Complexity

### Vision
Formalize the connection between `FiniteCoreSchema` and **kernelization** in parameterized complexity theory. A kernelization reduces a parameterized problem instance to an equivalent instance whose size is bounded by a function of the parameter alone — exactly the "finite core" pattern.

### Target Definitions
```
structure ParameterizedProblem (α : Type*) where
  instance_type : Type*
  parameter : instance_type → ℕ
  solution : instance_type → Prop

structure Kernelization (P : ParameterizedProblem α) where
  kernel : P.instance_type → P.instance_type
  size_bound : ∀ I, sizeOf (kernel I) ≤ f (P.parameter I)
  equivalence : ∀ I, P.solution I ↔ P.solution (kernel I)
```

### Target Theorems
1. **Kernelization as schema:** Every kernelization induces a `FiniteCoreSchema` on the solution space.
2. **Composition of kernelizations:** Composing two kernelizations yields a kernelization with composed size bounds.
3. **Vertex cover kernelization:** Formalize the classical Buss kernelization for vertex cover (kernel size O(k²)) as a concrete instance.

### Why This Opens a Field
This would create a formal bridge between logic (proof schemata) and complexity theory (parameterized algorithms). The connection is deep: both study how infinite problems can be reduced to finite checkable cores. Formalizing this connection would enable:
- Transfer of proof techniques from logic to algorithm design
- Certified correctness proofs for kernelization algorithms
- A unified framework for "finite reducibility" across mathematics and computer science

### Cross-Domain Connection
- **Algorithm design:** FPT algorithms and kernelization are central tools in practical graph algorithms
- **Machine learning:** Sample compression theorems in learning theory have the same "finite core" structure
- **Database theory:** Query optimization via materialized views has a kernelization structure

---

## Implementation Priority

| Direction | Difficulty | Impact | Dependencies | Priority |
|-----------|-----------|--------|-------------|----------|
| 1. Category of Proofs | High | Very High | Current work | Medium-term |
| 2. Graph/Group Obstruction | High | Very High | Mathlib graph theory | Medium-term |
| 3. ATP Strategy Extraction | Medium | High | Current work | Near-term |
| 4. Elliptic Curve Bridge | Very High | Very High | Mathlib number theory | Long-term |
| 5. Kernelization Bridge | Medium | High | Current work | Near-term |

**Recommended starting point:** Direction 3 (ATP extraction) and Direction 5 (kernelization), as they build most directly on the current framework and require the least new mathematical infrastructure. Direction 1 (categorification) should proceed in parallel as a theoretical foundation. Directions 2 and 4 are ambitious but should be explored as long-term goals.

---

## Team Directive

Each direction should be pursued by a team with:
1. **Clear hypotheses** to test (stated as conjectured theorem signatures)
2. **Proof strategies** identified in advance (which schemata to compose)
3. **Cross-domain connections** made explicit (who in adjacent fields should be consulted)
4. **Iteration protocol:** prove the simplest nontrivial instance first, then generalize

The research should iterate continuously: each proved theorem should suggest new directions, each failed proof should identify missing infrastructure, and each cross-domain connection should generate new hypotheses to test.
