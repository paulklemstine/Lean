# Future Directions: Tropical Matrix Algebra and Graph Semantics

## Research Roadmap for Formally Verified Tropical Mathematics

This document outlines five breakthrough research directions opened by the formal verification of tropical path algebra. Each direction includes precise theorem targets, proof strategies, cross-domain significance, and actionable next steps.

---

## 1. Tropical Perron–Frobenius Theory for Weighted Graphs

### Hypothesis

For a strongly connected weighted graph with weight matrix W, the sequence of normalized tropical powers `(1/m) · tropPow W m` converges entry-wise to a matrix determined by the **maximum cycle mean** — the maximum average edge weight over all directed cycles.

### Theorem Target

```
theorem tropical_perron_frobenius
    {n : ℕ} (W : Matrix (Fin n.succ) (Fin n.succ) ℝ)
    (hW : StronglyConnected W) :
    ∀ (i j : Fin n.succ),
      Filter.Tendsto (fun m => tropPow W m i j / (m + 1))
        Filter.atTop (nhds (maxCycleMean W))
```

where `maxCycleMean W = max { (∑ edges on C) / (length of C) | C is a cycle in W }`.

### Proof Strategy

1. Define `maxCycleMean` as a sup over all cycles (finite set for `Fin n`).
2. Prove the upper bound: every walk of length m has average weight ≤ maxCycleMean (by decomposing walks into cycles and acyclic segments).
3. Prove the lower bound: for large enough m, walks that traverse the optimal cycle ⌊m/|C*|⌋ times achieve average weight approaching maxCycleMean.
4. Use the squeeze theorem to conclude convergence.

### Cross-Domain Significance

- **Discrete event systems**: The maximum cycle mean determines the throughput of a manufacturing system or communication protocol.
- **Control theory**: Asymptotic growth rate of max-plus linear systems governs stability.
- **Economics**: Long-run growth rate in tropical models of production networks.

### Dependencies

Requires: cycle enumeration over `Fin n` graphs, Cesàro mean convergence lemmas.

---

## 2. Min-Plus Duality and Certified Shortest Paths

### Hypothesis

By negating weights, max-plus optimal walks become min-plus optimal walks (shortest paths). This duality, combined with our tropical framework, yields formally verified shortest-path algorithms.

### Theorem Target

```
theorem min_plus_duality
    {n : ℕ} (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) (m : ℕ)
    (i j : Fin n.succ) :
    tropPow (fun a b => -W a b) m i j =
      -(Finset.inf' (pathFinset n.succ (m+1) i j) (pathFinset_pos_nonempty m i j)
          (fun f => seqWeight W f))
```

### Proof Strategy

1. Prove `max_neg = neg_min`: `max (-a) (-b) = -(min a b)`.
2. Show `tropMul(-W₁)(-W₂) i j = -(inf'_k (W₁ i k + W₂ k j))` by pushing negation through.
3. Induct using the existing `tropPow_eq_sup_pathWeight`, applying negation at each step.

### Cross-Domain Significance

- **Verified routing**: Certified shortest-path computation for autonomous vehicles and network protocols.
- **Operations research**: Formally verified solutions to assignment and transportation problems.
- **Algorithm verification**: Foundation for certifying Bellman-Ford, Dijkstra, and Floyd-Warshall algorithms.

### Dependencies

Requires: `Finset.inf'` API in Mathlib, negation compatibility with `sup'`.

---

## 3. Tropical Message Passing and Verified Viterbi Decoding

### Hypothesis

The Viterbi algorithm for Hidden Markov Models is exactly iterated tropical matrix-vector multiplication over log-probability matrices. Formalizing this yields the first verified Viterbi decoder.

### Theorem Target

```
def viterbiStep {n : ℕ}
    (T : Matrix (Fin n.succ) (Fin n.succ) ℝ)  -- log transition probs
    (E : Fin n.succ → ℝ)                       -- log emission probs
    (v : Fin n.succ → ℝ) : Fin n.succ → ℝ :=
  fun j => (Finset.univ.sup' Finset.univ_nonempty (fun i => v i + T i j)) + E j

theorem viterbi_is_tropical_propagation
    {n : ℕ} (T : Matrix (Fin n.succ) (Fin n.succ) ℝ)
    (E : ℕ → Fin n.succ → ℝ)
    (v₀ : Fin n.succ → ℝ) :
    ∀ (m : ℕ) (j : Fin n.succ),
      iterateViterbi T E v₀ m j =
        tropicalPathValue T E v₀ m j
```

### Proof Strategy

1. Define `viterbiStep` as tropical matrix-vector multiplication plus emission.
2. Define `iterateViterbi` by repeated application of `viterbiStep`.
3. Show equivalence to `tropPow` applied to an augmented matrix incorporating emissions.
4. Use `tropPow_eq_sup_pathWeight` to interpret the result as optimal path selection.

### Cross-Domain Significance

- **Verified communication systems**: Certified Viterbi decoders for error-correcting codes.
- **Computational biology**: Verified sequence alignment and gene prediction algorithms.
- **Speech recognition**: Certified decoding in speech-to-text pipelines.
- **AI safety**: Formal guarantees on the correctness of probabilistic inference engines.

### Dependencies

Requires: log-probability framework, emission model formalization.

---

## 4. Tropical Neural Network Expressiveness Bounds

### Hypothesis

A ReLU neural network with L layers, each of width n, computes a piecewise-linear function whose number of linear regions is bounded by the number of "tropical monomials" in the L-fold tropical matrix power. This bound can be formalized using our tropical power infrastructure.

### Theorem Target

```
theorem relu_network_linear_regions_bound
    {n L : ℕ}
    (W : Fin L → Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    numLinearRegions (reluNetwork W) ≤ (n.succ) ^ L
```

### Proof Strategy

1. Formalize the connection: each ReLU layer computes `x ↦ max(0, W · x + b)`, which is a tropical operation.
2. Show that the composition of L layers yields a piecewise-linear function.
3. Count the number of "activation patterns" — binary vectors indicating which neurons are active — as a function of the tropical power structure.
4. Bound using the combinatorics of `Fin n.succ` vertex sequences in walks.

### Cross-Domain Significance

- **Deep learning theory**: Quantitative bounds on network expressiveness.
- **Neural architecture search**: Algebraic guidance for architecture design.
- **Adversarial robustness**: Tropical geometry determines the geometry of decision boundaries.

### Dependencies

Requires: piecewise-linear function formalization, ReLU network model.

---

## 5. Tropical Sheaves and Graph Message Passing

### Hypothesis

Tropical aggregation over graphs can be formalized as a sheaf-theoretic construction, where local tropical computations on neighborhoods are glued into global path-optimal solutions. This provides a formal foundation for graph neural networks and belief propagation.

### Theorem Target

```
structure TropicalPresheaf (G : SimpleGraph (Fin n)) where
  stalk : Fin n → Type
  restrict : ∀ {i j}, G.Adj i j → stalk j → stalk i

theorem tropical_sheaf_global_section
    {n : ℕ} (G : SimpleGraph (Fin n.succ))
    (F : TropicalPresheaf G)
    (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    globalOptimal F W = tropicalClosure W n.succ
```

### Proof Strategy

1. Define tropical presheaves on graphs: assign a "local score" space to each vertex.
2. Define restriction maps as tropical edge operations (add edge weight).
3. Show that the global section (consistent assignment maximizing total score) is computed by the tropical closure.
4. Connect to existing `tropPow_eq_sup_pathWeight` via the walk interpretation.

### Cross-Domain Significance

- **Graph neural networks**: Formal foundation for message-passing architectures (GCN, GAT, GraphSAGE).
- **Distributed optimization**: Certified distributed algorithms for sensor networks and multi-agent systems.
- **Algebraic topology**: Tropical sheaf cohomology as a new invariant for weighted graphs.
- **Bayesian inference**: Belief propagation on factor graphs as tropical sheaf computation.

### Dependencies

Requires: Mathlib sheaf infrastructure, SimpleGraph API, tropical presheaf definition.

---

## Implementation Priority

| Direction | Difficulty | Impact | Dependencies | Suggested Order |
|:-:|:-:|:-:|:-:|:-:|
| 2. Min-Plus Duality | Medium | High | Minimal | **First** |
| 1. Perron–Frobenius | High | Very High | Cycle enumeration | **Second** |
| 3. Viterbi Verification | Medium | High | Log-prob framework | **Third** |
| 4. NN Expressiveness | High | High | PL functions | **Fourth** |
| 5. Tropical Sheaves | Very High | Very High | Sheaf infra | **Fifth** |

---

## Team Directive

Each direction should be pursued by a focused research team with the following workflow:

1. **Formalize definitions** (1–2 days): Write all type signatures and definitions with `sorry` proofs.
2. **Verify skeleton** (1 day): Ensure the overall structure compiles.
3. **Prove lemmas bottom-up** (3–7 days): Start with the simplest supporting lemmas and work toward the main theorem.
4. **Computational validation** (1 day): Write Python scripts verifying the theorem computationally on concrete examples.
5. **Documentation** (1 day): Write detailed docstrings explaining the mathematical significance.
6. **Integration** (1 day): Connect to the existing tropical path algebra infrastructure.

Total estimated time per direction: 1–2 weeks for directions 1–3, 2–4 weeks for directions 4–5.

---

*This roadmap represents the beginning of a formal tropical mathematics library — infrastructure that will support verified algorithms, certified AI systems, and rigorous mathematical research for years to come.*
