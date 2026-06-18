# Future Directions: Tropical Certificate Complexity and Branching Program Lower Bounds

This document outlines concrete, actionable research directions opened by the formalization of tropical certificate lower bounds for nondeterministic branching programs.

---

## Direction 1: Exponential Lower Bounds for Layered Branching Programs

**Hypothesis:** For layered (oblivious) nondeterministic branching programs of width W reading n variables, every accepting path certificate has tropical cost at most O(W · log₂(n·W)), yielding exponential lower bounds for functions with high tropical certificate complexity.

**Proof Strategy:**
- Define layered NBPs where states are organized in n+1 layers, with each layer querying a fixed variable.
- Show that at each layer, the program's state encodes at most log₂(W) bits of information about the input.
- Prove that the total information along any path is at most n · log₂(W).
- When the tropical cost of every certificate exceeds n · log₂(W), derive that W must be exponential in the certificate cost divided by n.

**Key Lemma to Formalize:**
```
theorem layered_path_cost_le_log_width (B : LayeredNBP n) (p : AcceptingPath B) :
    tropicalCost w (pathCert p) ≤ n * Nat.log 2 (B.width + 1)
```

**Cross-Domain Connections:** Communication complexity (rectangle covers), OBDD lower bounds, streaming algorithms.

**Estimated Difficulty:** Medium. The layered structure simplifies the analysis considerably.

---

## Direction 2: Tropical Rectangle Cover Lower Bounds

**Hypothesis:** The accepting set of a Boolean function can be decomposed into "tropical rectangles" indexed by NBP states. If every such rectangle has bounded tropical certificate complexity, the number of rectangles (= states) must be large.

**Proof Strategy:**
- For each state q in an NBP, define the set of inputs reaching q (the "left rectangle") and the set of accepting continuations from q (the "right rectangle").
- Show that the intersection of a left rectangle and a right rectangle forms a monochromatic set for f.
- Prove that covering the accepting set requires at least 2^{TropCert(f,w)/C} tropical rectangles.
- Conclude that the NBP must have at least that many states.

**Key Definitions Needed:**
- Tropical rectangle: a set of inputs definable by a partial assignment with bounded tropical cost
- Rectangle cover number: minimum number of tropical rectangles covering the accepting set

**Cross-Domain Connections:** Communication complexity (Yao's rectangle method), proof complexity (extension complexity), information complexity.

**Estimated Difficulty:** Hard. This would create an entirely new lower-bound method.

---

## Direction 3: Explicit Hard Function Families

**Hypothesis:** For explicit function families (pointer chasing, tribes, address functions), the tropical certificate complexity under anisotropic weights grows linearly in n, yielding super-polynomial branching program lower bounds.

**Concrete Targets:**

### 3a. Tribes Function
- Define tribes_k(x) = OR of k groups, each an AND of n/k variables.
- Weight the i-th variable with w(i) = 2^{group(i)}, creating exponentially weighted groups.
- Prove TropCert(tribes_k, w) ≥ 2^k, forcing any NBP to have Ω(2^k) states.

### 3b. Pointer Chasing
- Define a pointer-chasing function on blocks of variables.
- Show that any certificate must resolve an entire chain of pointers.
- Derive tropical certificate cost Ω(n) under uniform weights.

### 3c. Address Function
- Define addr(x, y) = y_{x} where x encodes an index into y.
- Show tropical certificate cost Ω(n) under any weight function with w(i) ≥ 1.

**Cross-Domain Connections:** Circuit complexity, decision tree complexity, quantum query complexity.

**Estimated Difficulty:** Medium for specific families; the key challenge is computing tight tropical certificate complexity bounds.

---

## Direction 4: Tropical Information Theory for Computation

**Hypothesis:** There exists a "tropical data processing inequality" stating that tropical information content cannot increase along computation paths, providing a principled framework for space complexity lower bounds.

**Proof Strategy:**
- Define tropical mutual information between input sets using min-plus operations.
- Prove that passing through a bottleneck state can only reduce tropical information.
- Formalize: if a computation path passes through a set of k states, the tropical information transmitted is at most k · log₂(k).
- Derive that high tropical information requirements force large state spaces.

**Key Theorem to Target:**
```
theorem tropical_data_processing_inequality
    (f : BoolFun n) (w : Fin n → ℕ) (B : NBP S n)
    (hcomp : B.Computes f) :
    TropicalMutualInfo f w ≤ S * Nat.log 2 S
```

**Cross-Domain Connections:** Shannon theory, quantum information theory, Kolmogorov complexity, information complexity in communication.

**Estimated Difficulty:** Very hard. This would be a foundational result bridging information theory and tropical algebra.

---

## Direction 5: Transfer to OBDD and Proof Complexity Lower Bounds

**Hypothesis:** Tropical certificate complexity provides lower bounds for ordered binary decision diagrams (OBDDs) and decomposable negation normal form (DNNF) representations, with implications for knowledge compilation and SAT solving.

**Proof Strategy:**
- Show that OBDDs are special cases of read-once NBPs where each variable is queried exactly once.
- Prove that for OBDDs, the path certificate cost equals the sum of weights of critical variables.
- Use the tropical certificate lower bound to derive OBDD width lower bounds.
- Extend to DNNF by showing that DNNF decomposition nodes correspond to tropical certificate composition.

**Key Applications:**
- Lower bounds on the size of DNNF compilations of specific CNF formulas
- New lower-bound techniques for resolution-based proof systems
- Connections to extension complexity of polytopes (via tropical geometry)

**Cross-Domain Connections:** SAT solving, knowledge compilation, proof complexity, polytope theory.

**Estimated Difficulty:** Medium to hard. The OBDD connection is immediate; DNNF extension requires more work.

---

## Meta-Direction: Semiring Complexity Theory

All five directions above are instances of a broader program: developing complexity lower bounds parameterized by algebraic semirings. The tropical (min-plus) semiring is the first case; future work could systematically explore:

- **Boolean semiring** → classical certificate complexity (recovering known results)
- **Tropical semiring** → weighted certificate complexity (this work)  
- **Probabilistic semiring** → randomized certificate complexity
- **Quantum semiring** → quantum certificate complexity

A unified "semiring complexity theory" would provide a common framework for all these models, with tropical algebra serving as the bridge between Boolean and quantitative settings.

---

## Team Organization Suggestion

| Team | Focus | First Milestone |
|------|-------|-----------------|
| A | Layered NBP bounds (Dir 1) | Formalize LayeredNBP and prove width-based cost bound |
| B | Rectangle covers (Dir 2) | Define tropical rectangles; prove cover lower bound for OR |
| C | Hard functions (Dir 3) | Compute TropCert for tribes and address functions |
| D | Information theory (Dir 4) | Formalize tropical entropy and prove DPI for paths |
| E | Applications (Dir 5) | Reduce OBDD size bounds to tropical certificate bounds |

Each team should maintain a shared knowledge base of formalized lemmas and work in 2-week sprint cycles, with cross-team reviews.
