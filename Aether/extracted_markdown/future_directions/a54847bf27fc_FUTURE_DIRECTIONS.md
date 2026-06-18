# Future Directions

## 1. Weighted Tropical Extension over ℝ

**Goal:** Extend the simulation theorem from `WithTop ℕ` to `WithTop ℝ` or the extended tropical semiring ℝ ∪ {-∞}.

**Theorem target:**
```
theorem weighted_bp_to_tropical_circuit_real
    (w d : ℕ) (P : WeightedBP w d ℝ) :
    ∃ C : TropicalCircuitR,
      C.opCount ≤ 2 * w * w * d + w ∧
      ∀ x, tropEvalCircuit C x = tropEvalBP P x
```

**Strategy:** The algebraic structure of the proof is identical — only the coefficient ring changes. The key challenge is handling `WithTop ℝ` (or `EReal`) arithmetic in Lean, particularly the interaction of `⊤` with addition. Use Mathlib's `EReal` or `WithTop ℝ` infrastructure and verify that `inf` and `+` distribute correctly.

**Cross-domain connection:** This connects to tropical algebraic geometry, where tropical polynomials are piecewise-linear functions over ℝ. The simulation circuit becomes a tropical polynomial circuit, and its Newton polytope encodes the combinatorial structure of the BP.

**Impact:** Enables application to continuous optimization, shortest-path problems with real-valued costs, and connections to linear programming duality via tropical Farkas lemma.

---

## 2. Reverse Simulation: Circuit → Branching Program

**Goal:** Characterize when layered circuits can be compiled back into bounded-width branching programs, with explicit width bounds.

**Theorem target:**
```
theorem circuit_to_bp_reverse
    (n : ℕ) (C : LayeredCircuit n) :
    ∃ w : ℕ, w ≤ 2 ^ C.width ∧
    ∃ P : BP n w C.depth,
      ∀ x, P.Accepts x ↔ C.Accepts x
```

**Strategy:** The reverse simulation encodes the entire state of a circuit layer (w' Boolean gates) as a single state in a branching program of width 2^{w'}. Each transition reads the relevant input bits and updates the state according to the circuit's gate logic. The width bound 2^{w'} is exponential because each BP state must encode all possible valuations of the gates in a single layer.

**Key insight:** This exponential blowup is unavoidable in general (NC¹ vs L separation evidence), but for circuits with special structure (e.g., bounded treewidth, monotone), tighter bounds may hold.

**Connection to existing work:** Barrington's theorem shows that for width 5, this reverse simulation captures exactly NC¹. Understanding the quantitative dependence for arbitrary width is a major open question in circuit complexity.

---

## 3. Lower Bound Transport Theorem (Quantitative)

**Goal:** Prove that specific tropical circuit lower bounds (e.g., for sorting networks, shortest-path problems) yield explicit width-depth tradeoff lower bounds for tropical BPs.

**Theorem target:**
```
theorem sorting_bp_tradeoff (n : ℕ) (hn : 2 ≤ n) :
    ∀ w d : ℕ, (∀ P : TropicalBP w d, computes_sorting P n) →
    n * Nat.log 2 n ≤ 2 * w * w * d + w
```

**Strategy:**
1. Formalize sorting networks as tropical circuits computing the minimum-cost permutation.
2. Prove the Ω(n log n) lower bound for comparison-based sorting circuits.
3. Apply `tropical_lower_bound_transfer` to transport this into a BP tradeoff.

**Cross-domain connections:**
- Connects to the AKS sorting network and its optimality
- Relates to communication complexity lower bounds (information-theoretic)
- Links tropical circuit depth to the algebraic complexity of the sorted output function

---

## 4. Semiring-Parametric Simulation

**Goal:** Abstract the simulation theorem over an arbitrary idempotent semiring, making it a universal transfer principle.

**Theorem target:**
```
theorem semiring_bp_to_circuit [SemiringS : Semiring S] [CompleteLatticeS : CompleteLattice S]
    (w d : ℕ) (P : SemiringBP S w d) :
    ∃ C : SemiringCircuit S,
      C.opCount ≤ 2 * w * w * d + w ∧
      C.output = P.eval
```

**Strategy:** Define `SemiringBP S w d` with edge weights in S. Replace OR with the semiring's addition (join) and AND with multiplication. The reachability recurrence becomes:
```
reach(i+1, v) = Σ_u reach(i, u) * weight(i, u, v)
```
which is exactly matrix-vector multiplication over S. The simulation is the same construction for any S.

**Instances to verify:**
- S = Bool (∨, ∧): original Boolean case
- S = WithTop ℕ (min, +): tropical case
- S = ℝ₊ (+, ·): probabilistic/stochastic case
- S = ℂ (+, ·): quantum amplitude case

**Impact:** A single theorem covering all cases. This is the mathematically cleanest formulation and directly connects to weighted automata theory.

---

## 5. Transfer Operators and Partition Functions

**Goal:** Formalize BP evaluation as a transfer-operator computation and show the circuit is its dynamic-program unfolding.

**Theorem target:**
```
theorem bp_eval_eq_transfer_matrix_product
    (w d : ℕ) (P : TropicalBP w d) :
    P.minCost = (transferProduct P d).apply startVec P.accept

theorem circuit_unrolls_transfer
    (w d : ℕ) (P : TropicalBP w d) :
    tropBPToCircuit P = unfoldTransferProduct (transferMatrices P)
```

**Strategy:**
1. Define `transferMatrix P i` as the w×w tropical matrix for layer i, with entry (u,v) = edgeWeight(i, u, v).
2. Define `transferProduct P d` as the tropical matrix product M₀ ⊗ M₁ ⊗ ... ⊗ M_{d-1}.
3. Show BP.minCost = the (start, accept) entry of the transfer product.
4. Show the circuit evaluation is exactly the iterative computation of this matrix product, column by column.

**Cross-domain connections:**
- **Statistical mechanics:** The transfer matrix method for 1D lattice models (Ising, Potts) is exactly this construction. The circuit computes the partition function.
- **Markov chains:** Replace tropical with probabilistic semiring, and the transfer product is the Chapman-Kolmogorov equation.
- **Quantum walks:** Replace with unitary matrices for quantum branching programs.

**Impact:** Opens a direct channel between formal verification and mathematical physics. Could lead to formally verified computation of partition functions for lattice models.

---

## 6. Tropical Neural Network Connections

**Goal:** Show that ReLU neural networks are tropical circuits, and use the simulation theorem to relate network architecture to branching program complexity.

**Approach:**
1. Formalize that ReLU(x) = max(0, x) is a tropical gate (max-plus operation).
2. Show that a ReLU network with L layers and width W is a tropical circuit of depth L and width W.
3. Apply the reverse simulation to get a tropical BP of width ≤ 2^W and depth L.
4. Conclude: any function computable by a width-W, depth-L ReLU network is computable by a tropical BP of width 2^W and depth L.

**Implication:** Lower bounds on tropical BP width directly translate to lower bounds on ReLU network width, providing a new tool for understanding neural network expressiveness.

---

## 7. Formal Complexity Class Characterizations

**Goal:** Use the simulation theorem to formally characterize complexity classes defined by branching program width.

**Specific targets:**
- Formalize that width-5 polynomial-size BPs = NC¹ (Barrington's theorem)
- Formalize that polynomial-width polynomial-size BPs = L (logspace)
- Use the simulation to show NC¹ ⊆ circuits of size O(n^{10}) (explicit bound from width-5, polynomial-depth BPs)

**Strategy:** These are deep results requiring substantial additional infrastructure (complexity classes, polynomial bounds, uniformity conditions). The simulation theorem provides the "easy direction" of such characterizations; the hard direction (showing the class is not larger) requires separate arguments.
