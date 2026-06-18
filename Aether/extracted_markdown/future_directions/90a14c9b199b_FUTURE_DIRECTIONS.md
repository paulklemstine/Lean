# Future Directions: Tropical Path Algebra Infrastructure

## Team Directive

Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update knowledge base, and iterate. Each direction below is specific enough for a team to pick up and pursue with clear hypotheses, proof strategies, and cross-domain connections.

---

## 1. Tropical Perron–Frobenius for Finite Weighted Graphs

### Theorem Statement

```
theorem tropical_perron_frobenius {n : ℕ}
    (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    ∃ λ : ℝ, ∀ ε > 0, ∃ N : ℕ, ∀ m ≥ N, ∀ i j : Fin n.succ,
      |tropPow W m i j / (↑(m + 1)) - λ| < ε
```

The tropical eigenvalue λ equals the maximum cycle mean: λ = max over all simple cycles C of (weight(C) / length(C)). This determines the asymptotic growth rate of tropical powers.

### Proof Strategy

1. Define cycle mean: for each simple cycle (given by a cyclic permutation on a subset), compute weight/length.
2. Show that tropPow(W, m) i j grows at most linearly in m, with slope bounded by the maximum cycle mean.
3. Show that the maximum cycle mean is achieved (finite graph → finite number of simple cycles).
4. Prove convergence of tropPow(W, m) / (m+1) to the max cycle mean using the pigeonhole principle: walks of length m must revisit vertices, and the dominant cycles determine the growth rate.

### Cross-Domain Significance

- **Scheduling**: The maximum cycle mean determines the throughput of a cyclic production system. Formalizing this gives certified performance bounds for manufacturing.
- **Control theory**: Max-plus eigenvalues govern the stability of discrete event systems. This is the tropical analogue of spectral stability theory.
- **Game theory**: Connected to mean payoff games, where two players alternately choose edges, and the value equals the max cycle mean of the optimal strategy.

### Key Dependencies

Builds directly on `tropPow_eq_sup_pathWeight` and `tropBellman`. Requires new definitions for simple cycles and cycle weight.

---

## 2. Tropical Kleene Star and All-Pairs Closure

### Theorem Statement

```
def tropStar {n : ℕ} (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    Matrix (Fin n.succ) (Fin n.succ) ℝ :=
  fun i j => Finset.univ.sup' Finset.univ_nonempty
    (fun m : Fin n.succ => tropPow W m i j)

theorem tropStar_eq_optimal_walk {n : ℕ}
    (W : Matrix (Fin n.succ) (Fin n.succ) ℝ)
    (hW : ∀ i j, W i j ≤ 0) (i j : Fin n.succ) :
    tropStar W i j = (pathFinset n.succ n i j).sup'
      (pathFinset_pos_nonempty (n-1) i j)
      (fun f => seqWeight W f)
```

When all edge weights are nonpositive, the Kleene star converges after n−1 iterations and computes all-pairs shortest distances (with negated weights).

### Proof Strategy

1. For nonpositive-weight graphs, show that the optimal walk of any length is a simple path (no vertex repetition).
2. Simple paths have at most n−1 edges, so tropPow(W, m) is non-increasing for m ≥ n−1.
3. The supremum over all m equals the supremum over m = 0, ..., n−1.
4. This is the Floyd–Warshall / Bellman–Ford correctness theorem in tropical form.

### Cross-Domain Significance

- **Certified shortest paths**: Provides machine-verified correctness for the Floyd–Warshall algorithm.
- **Database query optimization**: Transitive closure of relations is a special case.
- **Network analysis**: All-pairs distances are fundamental to centrality measures, community detection, etc.

---

## 3. Tropical Message Passing and Viterbi Decoding

### Theorem Statement

```
def viterbi {n T : ℕ}
    (emission : Fin T.succ → Fin n.succ → ℝ)
    (transition : Matrix (Fin n.succ) (Fin n.succ) ℝ)
    (initial : Fin n.succ → ℝ) :
    Fin n.succ → ℝ :=
  -- max over all state sequences of (initial + sum of transitions + sum of emissions)

theorem viterbi_eq_tropical_matmul {n T : ℕ}
    (emission : Fin T.succ → Fin n.succ → ℝ)
    (transition : Matrix (Fin n.succ) (Fin n.succ) ℝ)
    (initial : Fin n.succ → ℝ) :
    viterbi emission transition initial =
      -- T-fold tropical matrix-vector multiplication
```

The Viterbi algorithm for Hidden Markov Models is equivalent to tropical matrix-vector multiplication iterated over time steps.

### Proof Strategy

1. Define HMM log-likelihood as a sum of log-transition and log-emission terms.
2. Show the Viterbi recursion is exactly the Bellman recurrence with modified weights.
3. Express the modified weights as a time-varying tropical matrix multiplication.
4. Prove the equivalence by induction using `tropBellman`.

### Cross-Domain Significance

- **Speech recognition**: Certified correctness for the core decoding algorithm.
- **Bioinformatics**: Gene finding algorithms use HMMs; tropical certification gives reliable annotations.
- **Error-correcting codes**: BCJR and Viterbi decoders for convolutional codes are tropical computations.

---

## 4. Boolean-Tropical Compression Theorem

### Theorem Statement

```
theorem tropical_compression {n m : ℕ}
    (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) (i j : Fin n.succ) :
    -- The number of walks of length m+1 from i to j is
    -- (n+1)^m (exponential in m),
    -- but tropical aggregation compresses all their weights
    -- into a single optimal value.
    (pathFinset n.succ (m+1) i j).card = (n + 1) ^ m ∧
    tropPow W m i j =
      (pathFinset n.succ (m+1) i j).sup' (pathFinset_pos_nonempty m i j)
        (fun f => seqWeight W f)
```

### Proof Strategy

1. Count the walks: there are (n+1)^m intermediate vertex choices for a length-(m+1) walk.
2. Use `tropPow_eq_sup_pathWeight` for the second conjunct.
3. Combine to show that tropical matrix power performs exponential-to-constant compression.

### Cross-Domain Significance

- **Computational complexity**: Formalizes why dynamic programming is efficient: tropical aggregation compresses exponential search spaces.
- **Information theory**: Connects to rate-distortion theory — the tropical optimum is a lossy compression of path data.
- **Birthday bound connection**: The catalog theorem `birthday_bound_tropical_hash` bounds collision probability in hashing; the compression theorem shows how tropical aggregation relates to hash-like summarization of path spaces.

---

## 5. Tropical Neural Network Equivalence

### Theorem Statement

```
def reluNetwork {layers : List ℕ} -- dimensions of each layer
    (weights : ∀ i : Fin (layers.length - 1),
      Matrix (Fin (layers[i+1])) (Fin (layers[i])) ℝ)
    (input : Fin (layers[0]) → ℝ) :
    Fin (layers.getLast!) → ℝ :=
  -- Iterated tropical matrix-vector multiplication

theorem relu_is_tropical {n₁ n₂ n₃ : ℕ}
    (W₁ : Matrix (Fin n₂.succ) (Fin n₁.succ) ℝ)
    (W₂ : Matrix (Fin n₃.succ) (Fin n₂.succ) ℝ)
    (x : Fin n₁.succ → ℝ) :
    ∀ j : Fin n₃.succ,
      (fun j => Finset.univ.sup' Finset.univ_nonempty
        (fun k => W₂ j k + Finset.univ.sup' Finset.univ_nonempty
          (fun l => W₁ k l + x l))) j =
      Finset.univ.sup' Finset.univ_nonempty
        (fun path : Fin n₂.succ × Fin n₁.succ =>
          W₂ j path.1 + W₁ path.1 path.2 + x path.2)
```

### Proof Strategy

1. Show that each ReLU layer computes a tropical matrix-vector product (max over weighted inputs).
2. Compose layers using tropical matrix multiplication.
3. Apply the path composition theorem to show the full network computes max-weight paths through the network graph.
4. Derive that ReLU network output functions are tropical polynomial functions (piecewise linear).

### Cross-Domain Significance

- **ML interpretability**: Tropical characterization reveals exactly which input features dominate each output, giving interpretable explanations.
- **Robustness certification**: Tropical geometry provides exact characterization of decision boundaries, enabling certified adversarial robustness.
- **Architecture search**: Tropical complexity measures (number of linear regions) inform network design.
- **Catalog connection**: The `tropical_and_distributes` theorem provides the distributive law needed for composing layers.

---

## 6. Tropical Laplacian and Graph Energy

### Theorem Statement

```
def tropicalEnergy {n : ℕ}
    (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty
    (fun cycle : -- encoding of Hamiltonian cycles --
      seqWeight W cycle)

theorem tropical_energy_eq_max_hamiltonian {n : ℕ}
    (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    tropicalEnergy W = -- maximum weight Hamiltonian cycle
```

### Proof Strategy

1. Define tropical energy as the maximum weight over all Hamiltonian cycles.
2. Relate to the diagonal of tropPow(W, n-1) for strongly connected graphs.
3. Prove a tropical min-cut / max-weight duality for special graph classes.

### Cross-Domain Significance

- **Combinatorial optimization**: Connects to the traveling salesman problem (TSP).
- **Physics**: Tropical energy relates to partition functions at zero temperature.
- **Graph theory**: Tropical spectral theory for matrices.

---

## 7. Tropical Semiring Instance and WithBot ℝ Extension

### Theorem Statement

```
instance : Semiring (WithBot ℝ) where
  add := fun a b => max a b  -- tropical addition
  mul := fun a b => a + b    -- tropical multiplication (lifted)
  -- ... all semiring axioms

theorem tropMul_eq_matrix_mul_withbot {n : ℕ}
    (A B : Matrix (Fin n.succ) (Fin n.succ) (WithBot ℝ)) :
    -- tropical matrix multiplication = standard matrix multiplication
    -- over the tropical semiring
```

### Proof Strategy

1. Define the tropical semiring structure on `WithBot ℝ` (or use Mathlib's `Tropical` type).
2. Verify all semiring axioms.
3. Show that tropical matrix multiplication is an instance of standard matrix multiplication over this semiring.
4. Import all standard matrix algebra theorems (associativity, distributivity, etc.) for free.

### Cross-Domain Significance

- **Abstraction**: Enables working at the semiring level, where theorems apply to any semiring (Boolean, min-plus, max-plus, probabilistic, etc.).
- **Generalization**: Many of our path theorems generalize to arbitrary closed semirings.
- **Mathlib integration**: Connects tropical algebra to the existing matrix and linear algebra library.

---

## Summary of Dependencies

```
                    ┌─────────────────────┐
                    │ tropPow_eq_sup_path  │
                    │   Weight (DONE)      │
                    └──────┬──────────────┘
                           │
          ┌────────────────┼────────────────┐
          ▼                ▼                ▼
   ┌──────────┐    ┌──────────────┐  ┌──────────────┐
   │ Perron-  │    │ Kleene Star  │  │ Compression  │
   │ Frobenius│    │ (Direction 2)│  │ (Direction 4)│
   │(Dir. 1)  │    └──────┬───────┘  └──────────────┘
   └──────────┘           │
                          ▼
                   ┌──────────────┐
                   │ Viterbi /    │
                   │ Message Pass │
                   │ (Direction 3)│
                   └──────────────┘

   Independent:
   ┌──────────────┐  ┌──────────────┐
   │ Neural Net   │  │ WithBot ℝ    │
   │ (Direction 5)│  │ (Direction 7)│
   └──────────────┘  └──────────────┘
```

Each direction builds on the infrastructure established in this work and opens connections to multiple application domains. The tropical path composition theorem serves as the foundational node from which all other developments branch.
