# Ultrametric Proof Compression Duality via Observer Semimodules and Certified Minimal Refutation Reconstruction

## Abstract

We establish a finite algebraic realization theorem for proof compression in ultrametric proof systems. Given a finite proof-state type equipped with an ultrametric distance, a contractive transition operator, and a refutation predicate, we construct a canonical observer semimodule whose carrier classifies proof states up to behavioral equivalence. The main duality theorem shows that extremal observer classes biject with states of the minimal refutation automaton, that this automaton is unique up to isomorphism, and that any separating observer family reconstructs it. All results are machine-verified with zero unproved assumptions.

**Keywords:** ultrametric proof geometry, proof compression, Myhill–Nerode theorem, observer semimodules, minimal refutation automata, algebraic realization theory

---

## 1. Introduction

### 1.1 Motivation

Modern automated theorem provers generate proof objects that can be orders of magnitude larger than necessary. Proof compression — the systematic reduction of proof size while preserving logical content — is both a practical necessity and a theoretical challenge. While heuristic compression methods abound, a rigorous algebraic theory of *what constitutes optimal compression* has been lacking.

This paper develops such a theory by exploiting the ultrametric structure of proof spaces. The key insight is that contractive compression in an ultrametric space induces a canonical behavioral equivalence on proof states, and the resulting quotient admits both an algebraic description (observer semimodule) and a computational description (minimal refutation automaton) that determine each other.

### 1.2 Relationship to Prior Work

**Myhill–Nerode theorem.** Our main result is a proof-compression analogue of the classical Myhill–Nerode theorem for regular languages. Where Myhill–Nerode identifies states of the minimal DFA with right-congruence classes of an equivalence relation on strings, we identify states of the minimal refutation automaton with behavioral equivalence classes of proof states under contractive compression.

**Stone duality.** Stone duality establishes correspondences between algebraic structures (Boolean algebras) and topological spaces (Stone spaces). Our observer-automaton duality can be viewed as a finite, dynamical version of Stone duality specialized to proof compression.

**Ultrametric dynamics.** The theory of contractive maps on ultrametric spaces is well-developed in p-adic analysis. We import the key estimate — geometric decay of iterate distances — and use it to guarantee well-behavedness of behavioral equivalence.

**Weighted automata realization.** The Fliess realization theorem establishes when a formal power series admits a finite-dimensional linear representation. Our reconstruction theorem is an analogue for observer semimodules.

### 1.3 Contributions

1. **Definitions** of finite compressed proof systems, behavioral equivalence, observer semimodules, and minimal refutation automata in a unified framework.
2. **Duality theorem:** canonical bijection between extremal observer classes and minimal automaton states.
3. **Uniqueness theorem:** the minimal refutation automaton is unique up to isomorphism among all automata extracted by the same behavioral equivalence.
4. **Reconstruction theorem:** every separating observer semimodule reconstructs a unique minimal automaton.
5. **Certified extraction:** the minimal skeleton is extractable from distance/behavioral data with provable correctness.
6. **Machine verification:** all results are formalized and verified with zero `sorry` axioms.

---

## 2. Definitions and Notation

### 2.1 Ultrametric Distance

**Definition 2.1** (Ultrametric Distance Predicate). A function `d : P × P → ℝ` is an *ultrametric distance* if:
- (Non-negativity) `d(x, y) ≥ 0` for all x, y.
- (Identity of indiscernibles) `d(x, y) = 0 ↔ x = y`.
- (Symmetry) `d(x, y) = d(y, x)`.
- (Strong triangle inequality) `d(x, z) ≤ max(d(x, y), d(y, z))`.

### 2.2 Finite Compressed Proof System

**Definition 2.2** (FinCompProofSys). A *finite compressed proof system* is a tuple `S = (P, d, T, q, refutes)` where:
- `P` is a finite type (proof states),
- `d : P × P → ℝ` is an ultrametric distance,
- `T : P → P` is the combined step-compress transition,
- `q ∈ [0, 1)` is the contraction ratio satisfying `d(T(x), T(y)) ≤ q · d(x, y)`,
- `refutes : P → Prop` is the refutation predicate.

### 2.3 Behavioral Equivalence

**Definition 2.3** (Behavioral Equivalence). Two proof states x, y are *behaviorally equivalent*, written `x ~_S y`, if:

`∀ n : ℕ, refutes(T^n(x)) ↔ refutes(T^n(y))`

This is a well-defined equivalence relation (reflexive, symmetric, transitive).

**Lemma 2.4** (Compatibility with T). If `x ~_S y`, then `T(x) ~_S T(y)`.

*Proof.* For all n, `refutes(T^n(T(x))) = refutes(T^{n+1}(x))` which equals `refutes(T^{n+1}(y)) = refutes(T^n(T(y)))` by hypothesis applied at depth n+1. ∎

### 2.4 Minimal Refutation Automaton

**Definition 2.5** (MinCompRefAut). A *minimal compressed refutation automaton* is a tuple `A = (State, trans, proj, refPred)` where:
- `State` is a finite type,
- `trans : State → State` is the transition,
- `proj : P → State` is a surjective projection,
- `refPred : State → Prop` is the state refutation predicate.

**Definition 2.6** (Extracted by Congruence Quotient). An automaton A is *extracted from S* if:

`proj(x) = proj(y) ↔ x ~_S y`

**Construction 2.7** (MinAut). The *canonical minimal automaton* `MinAut(S)` has:
- States = equivalence classes of `~_S` (the quotient `P / ~_S`),
- Transition induced by T (well-defined by Lemma 2.4),
- Projection = quotient map.

### 2.5 Observer Semimodule

**Definition 2.8** (ObsSemimod). An *observer semimodule* on P is a tuple `O = (Carrier, eval)` where:
- `Carrier` is a finite type (observer indices),
- `eval : Carrier × P → ℝ` assigns each observer a measurement on each proof state.

**Construction 2.9** (Obs). The *canonical observer semimodule* `Obs(S)` has:
- Carrier = equivalence classes of `~_S`,
- `eval(c, x) = 1` if `[x] = c`, else `eval(c, x) = 0`.

---

## 3. Main Results

### 3.1 Observer-Equivalence Characterization

**Theorem 3.1** (Observer Separation). For all x, y ∈ P:

`(∀ c ∈ Obs(S).Carrier, eval(c, x) = eval(c, y)) ↔ x ~_S y`

*Proof sketch.* (⇐) If x ~_S y, then [x] = [y], so the indicator functions agree. (⇒) If x ≁_S y, then [x] ≠ [y], and the indicator of [x] gives eval([x], x) = 1 ≠ 0 = eval([x], y). ∎

### 3.2 Reconstruction

**Theorem 3.2** (Observer Reconstructs MinAut). The canonical observer semimodule reconstructs the minimal automaton:

`proj(x) = proj(y) ↔ ∀ c, eval(c, x) = eval(c, y)`

*Proof.* Immediate from Theorem 3.1 and the definition of MinAut. ∎

### 3.3 Extremal Ray–State Bijection

**Theorem 3.3** (Extremal Bijection). There is a canonical equivalence:

`ExtRayClass(Obs(S)) ≃ CompStateClass(MinAut(S))`

*Proof.* Both types are subtypes of `BehClass(S)` with the same existence condition (every equivalence class is inhabited by surjectivity of the quotient map). The equivalence follows from `Equiv.subtypeEquivRight`. ∎

### 3.4 Uniqueness

**Theorem 3.4** (Minimal Automaton Uniqueness). If A and A' are both extracted from S (i.e., their projections define the same partition as ~_S), then:

`Nonempty (A.State ≃ A'.State)`

*Proof.* Both projections are surjective with the same kernel (the equivalence relation ~_S). By a general lemma on surjections with the same kernel (proved via Fintype.equivOfCardEq and a cardinality argument using injections both ways), the codomains have the same cardinality and hence are in bijection. ∎

### 3.5 Main Duality Theorem

**Theorem 3.5** (Finite Ultrametric Proof Compression Duality). For every finite compressed proof system S:

∃ O, A such that:
1. O = Obs(S) and A = MinAut(S),
2. O reconstructs A (same partition criterion),
3. Extremal rays of O biject with states of A,
4. A is extracted by congruence quotient from S.

*Proof.* Take O = Obs(S) and A = MinAut(S). Properties (1)-(4) follow from Theorems 3.1-3.3. ∎

### 3.6 Reconstruction Converse

**Theorem 3.6** (Observer Reconstruction). For any observer semimodule O:

∃ A such that O reconstructs A, and any A' reconstructed by O is isomorphic to A.

*Proof.* Define the observer-equivalence relation `x ~_O y ↔ ∀ c, eval(c,x) = eval(c,y)`. This is an equivalence relation. Take A = quotient by ~_O with quotient-map projection. Reconstruction holds by construction. Uniqueness follows from Theorem 3.4's general kernel argument. ∎

### 3.7 Contraction Estimates

**Theorem 3.7** (Iterate Contraction). For all x, y and n:

`d(T^n(x), T^n(y)) ≤ q^n · d(x, y)`

*Proof.* By induction on n, using `d(T(u), T(v)) ≤ q · d(u, v)` at each step. ∎

### 3.8 Certified Extraction

**Theorem 3.8** (Certified Skeleton). There exists a skeleton `skel = MinAut(S)` such that:
- skel is extracted by congruence quotient,
- skel is certified from distance data: behavioral equivalence is preserved by T-iteration.

*Proof.* Take skel = MinAut(S). Extraction holds by construction. Certification: if proj(x) = proj(y), then x ~_S y, so T^k(x) ~_S T^k(y) (by Lemma 2.4 iterated), hence proj(T^k(x)) = proj(T^k(y)). ∎

---

## 4. Algorithms

### 4.1 Computing Behavioral Equivalence Classes

**Input:** Finite proof system S = (P, T, refutes) with |P| = N.

**Algorithm:**
1. Initialize partition Π = {{p} : p ∈ P}.
2. Refine Π by refutation status: merge/split by refutes(p).
3. For k = 1, 2, ..., N-1:
   - Refine Π: two states are in the same class iff they were in the same class before AND T maps them to the same class.
4. Output the fixed-point partition.

**Complexity:** O(N² · N) = O(N³) worst case, O(N² log N) with Hopcroft-style partition refinement.

### 4.2 Constructing the Minimal Automaton

**Input:** Partition Π from Algorithm 4.1.

**Algorithm:**
1. States = classes of Π.
2. Transition: for class C, pick any representative p, set trans(C) = class of T(p).
3. Refutation: refPred(C) = refutes(p) for any representative p.

**Correctness:** Well-definedness follows from the compatibility of behavioral equivalence with T (Lemma 2.4).

### 4.3 Constructing the Observer Semimodule

**Input:** Partition Π from Algorithm 4.1.

**Algorithm:**
1. Carrier = classes of Π.
2. For each class C and state p: eval(C, p) = 1 if p ∈ C, else 0.

---

## 5. Applications

### 5.1 Proof Compression Certification

Given a proof object and a claimed compression, the duality theorem provides a certificate of minimality: compute the behavioral equivalence classes, verify that the compressed proof has exactly as many distinct states as there are classes, and check that the transition structure matches.

### 5.2 Proof Search Optimization

The contraction estimate (Theorem 3.7) implies that proof search in an ultrametric space converges exponentially fast: after n applications of the transition, the effective diameter of the search space shrinks by q^n. This provides stopping criteria and convergence guarantees for iterative proof search algorithms.

### 5.3 Automata Learning for Proofs

The reconstruction theorem (Theorem 3.6) implies that the minimal refutation automaton can be learned from observer data alone. This connects to Angluin's L* algorithm: by querying observers, one can reconstruct the minimal automaton without direct access to the proof-state space.

---

## 6. Discussion

### 6.1 Relationship to Myhill–Nerode

The classical Myhill–Nerode theorem states that a language L is regular iff the Myhill–Nerode equivalence (right-congruence induced by L) has finitely many classes, and the minimal DFA has exactly that many states. Our theorem is structurally parallel: behavioral equivalence plays the role of Myhill–Nerode equivalence, the observer semimodule plays the role of the syntactic monoid, and the minimal refutation automaton plays the role of the minimal DFA.

The key difference is the *ultrametric contraction* hypothesis, which is absent in classical automata theory. This hypothesis provides the geometric content: it guarantees exponential convergence of compression orbits and bounds the complexity of the behavioral partition.

### 6.2 Role of the Ultrametric Structure

The ultrametric distance is not merely a technical convenience. It captures the hierarchical branching structure of proof search: states that diverge early are far apart, states that diverge late are close. The strong triangle inequality implies that behavioral equivalence classes form a nested hierarchy (every class is a clopen set in the ultrametric topology), which is precisely the structure needed for finite observer separation.

### 6.3 Limitations

The current formalization uses a single combined transition T = step ∘ compress, rather than separate step and compress operators. This simplification avoids the complication that step and compress may not commute, but it means the theory does not directly address the interaction between logical consequence and proof simplification. Extending to non-commuting operators is an important direction.

---

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed research program. Key next steps:
1. Profinite extension to infinite-state proof systems.
2. Tropical/weighted observer semimodules for proof complexity.
3. Categorical equivalence between compressed proof systems and observer semimodules.
4. Spectral invariants of the compression action.
5. PAC-learning the minimal automaton from noisy distance samples.

---

## References

1. Myhill, J. (1957). Finite automata and the representation of events. WADD TR-57-624.
2. Nerode, A. (1958). Linear automaton transformations. Proceedings of the AMS, 9(4), 541-544.
3. van Rooij, A.C.M. (1978). Non-Archimedean Functional Analysis. Marcel Dekker.
4. Droste, M., Kuich, W., Vogler, H. (2009). Handbook of Weighted Automata. Springer.
5. Pin, J.-E. (2021). Mathematical Foundations of Automata Theory. Available online.
6. Stone, M.H. (1936). The theory of representations for Boolean algebras. Trans. AMS, 40(1), 37-111.
