# Future Directions: Tropical Obstruction Theory

## Research Roadmap

This document outlines five breakthrough-level research directions opened by the tropical cycle-gap lower bound framework.

---

## Direction 1: Tropical Cycle Mean and Min-Plus Collatz–Wielandt Theory

### Goal
Formalize the tropical eigenvalue (minimum cycle mean) for finite weighted digraphs and prove a min-plus analogue of the Collatz–Wielandt theorem.

### Background
In classical linear algebra, the Perron–Frobenius theorem characterizes the dominant eigenvalue of non-negative matrices. The tropical analogue — due to Karp (1978) and further developed by Gaubert and others — characterizes the minimum cycle mean as the tropical eigenvalue.

### Specific Targets
1. **Define the tropical eigenvalue**: For a weight matrix $W$ on $n$ vertices, the tropical eigenvalue is $\lambda(W) = \min_{c \text{ cycle}} \text{cost}(c) / \text{length}(c)$.
2. **Prove the Karp characterization**: $\lambda(W) = \min_v \max_{0 \leq k < n} (d_n(v) - d_k(v)) / (n - k)$ where $d_k(v)$ is the minimum $k$-step cost to reach $v$ from a fixed source.
3. **Prove the Collatz–Wielandt bound**: $\lambda(W) = \max \{ \lambda : \exists x, W \otimes x \leq x + \lambda \mathbf{1} \}$ where $\otimes$ is tropical multiplication.
4. **Connect to the cycle-gap theorem**: Show that $g \geq n \cdot \lambda(W)$ and derive tighter lower bounds using the eigenvalue.

### Proof Strategy
- Build on the existing `tropPow` and `tropMul` definitions.
- Formalize strongly connected components and per-SCC eigenvalues.
- Use the existing pigeonhole machinery for cycle decomposition.

### Cross-domain Impact
- Weighted automata theory (quantitative model checking)
- Network optimization (critical cycle identification)
- Tropical algebraic geometry (valuations and Newton polytopes)

---

## Direction 2: Width-Depth Tropical Tradeoffs for Branching Programs

### Goal
Extend the cycle-gap framework from paths (linear programs) to branching programs (DAG-structured computation), proving width-depth tradeoffs.

### Background
Branching programs are a model of computation where the program is a layered DAG. The width corresponds to space, and the depth corresponds to time. Classical width-depth tradeoffs (Borodin-Cook, Ajtai) are proved using communication complexity arguments. The tropical framework offers an algebraic alternative.

### Specific Targets
1. **Define tropical branching programs**: A weighted DAG on $[w] \times [d]$ (width $w$, depth $d$) with min-plus path costs.
2. **Prove the bottleneck lemma**: Any path through a width-$w$ branching program of depth $d > w$ must contain a cycle within some layer, contributing cost $\geq g$.
3. **Derive width-depth tradeoff**: If the branching program has minimum intralayer cycle cost $g$, then the minimum path cost is $\geq g \cdot \lfloor d/w \rfloor$.
4. **Apply to specific problems**: Show that certain functions (e.g., element distinctness, graph connectivity) require super-linear tropical cost in bounded-width branching programs.

### Proof Strategy
- Generalize the layered system framework from `Obstruction.lean`.
- Use the block cost lemma within each layer.
- Combine with the existing `layered_no_shortcut` theorem.

### Cross-domain Impact
- Circuit complexity (lower bounds for restricted circuits)
- Streaming algorithms (space-bounded computation)
- VLSI design (area-time tradeoffs)

---

## Direction 3: Tropical Communication Complexity via Min-Plus Protocol Cost

### Goal
Define communication complexity over the min-plus semiring and prove direct-sum lower bounds using the cycle-gap framework.

### Background
In classical communication complexity, Alice and Bob each hold part of an input and must compute a joint function with minimum communication. In the tropical version, each message has a cost, and the goal is to minimize total cost. This models scenarios like distributed optimization and multi-agent planning.

### Specific Targets
1. **Define tropical protocols**: A protocol tree where each leaf has a value in $\mathbb{N} \cup \{\infty\}$ and each edge has a communication cost.
2. **Prove the rectangle bound**: If the communication matrix has minimum cycle cost $g$ (viewing Alice's states as rows and Bob's as columns), then any protocol has cost $\geq g \cdot \lfloor R/n \rfloor$ where $R$ is the number of rounds and $n$ is the number of distinct messages.
3. **Prove direct-sum**: For $k$ independent instances, the tropical communication cost is $\geq k$ times the single-instance cost.
4. **Formalize the connection**: Show that tropical communication complexity lower bounds imply branching program lower bounds via standard simulation.

### Proof Strategy
- Define protocols as trees with tropical edge costs.
- Apply the cycle-gap bound to the protocol state trajectory.
- Use the product structure for direct-sum arguments.

### Cross-domain Impact
- Distributed computing (message complexity lower bounds)
- Database theory (query complexity)
- Information theory (rate-distortion theory over semirings)

---

## Direction 4: Bridge Theorem Between Spectral Gaps and Tropical Cycle Gaps

### Goal
Prove a formal bridge theorem connecting the spectral gap of a transition matrix (in the classical linear-algebraic sense) to the tropical cycle gap of the associated weighted graph.

### Background
The spectral gap of a stochastic matrix controls mixing time: larger gap means faster mixing. The tropical cycle gap controls cost growth: larger gap means faster cost accumulation. These are structurally analogous — both measure how quickly a system "forgets" its initial state. A formal bridge theorem would allow importing spectral gap lower bounds into the tropical world and vice versa.

### Specific Targets
1. **Define the comparison framework**: Given a stochastic matrix $P$ and a weight matrix $W$ on the same graph, define the spectral gap $\gamma(P)$ and tropical cycle gap $g(W)$.
2. **Prove the entropic bound**: $g(W) \geq \gamma(P) \cdot \min_{ij} W_{ij}$ under appropriate conditions.
3. **Prove the converse**: Under reversibility conditions, $\gamma(P) \geq g(W) / (n \cdot \max_{ij} W_{ij})$.
4. **Apply to mixing lower bounds**: Use tropical cycle gaps to give new proofs of mixing time lower bounds for Markov chains.

### Proof Strategy
- Build on the existing `spectral_moment_gap` theorem.
- Use log-Sobolev inequality techniques adapted to the tropical setting.
- Formalize the connection via a shared abstract semiring framework.

### Cross-domain Impact
- Markov chain Monte Carlo (mixing time analysis)
- Quantum computing (quantum walk analysis)
- Statistical physics (phase transition detection)

---

## Direction 5: Certified Algorithms for Tropical Spectral Gap Computation

### Goal
Develop algorithms that compute tropical spectral gaps of finite machines and output machine-checkable lower-bound certificates.

### Background
The tropical cycle gap is computable (via Karp's algorithm for minimum cycle mean), but the output is just a number. A *certified* algorithm would produce not just the number but a formal proof that the number is correct. This enables automated generation of verified lower bounds for specific systems.

### Specific Targets
1. **Implement Karp's algorithm in Lean**: Compute minimum cycle cost with a correctness proof.
2. **Generate certificates**: For a given $W$ and computed $g$, output a proof term of type `MinCycleCost n W g`.
3. **Build a verified checker**: A Lean program that reads a weight matrix and outputs a verified lower bound.
4. **Optimize for large systems**: Use sparse matrix representations and incremental algorithms for systems with millions of states.

### Proof Strategy
- Implement the algorithm as a Lean `def` with a correctness theorem.
- Use `Decidable` instances and `native_decide` for computational verification.
- Export certificates as `.olean` files for independent checking.

### Cross-domain Impact
- Formal verification (verified optimization bounds)
- Model checking (certified complexity analysis)
- Compiler optimization (verified loop bound analysis)

---

## Timeline and Dependencies

```
Direction 5 (Certified Algorithms)  ←  Direction 1 (Cycle Mean Theory)
        ↑                                       ↑
Direction 2 (Branching Programs)    ←  Current Work (Cycle-Gap Bound)
        ↑                                       ↑
Direction 3 (Communication)         ←  Direction 4 (Spectral Bridge)
```

Direction 1 and Direction 5 can proceed in parallel. Direction 2 builds on Direction 1. Directions 3 and 4 are relatively independent and can proceed concurrently.

## Team Directive

Each direction should be pursued by a team with:
- **Hypothesis**: A specific conjecture or theorem statement to prove.
- **Proof strategy**: A concrete approach with identified helper lemmas.
- **Validation plan**: Computational experiments to test conjectures before formalization.
- **Cross-domain expert**: A collaborator from the relevant application domain.
- **Iteration protocol**: Weekly review of formalization progress, with pivot criteria if the approach stalls.
