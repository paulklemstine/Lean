# Future Directions: Tropical Amortization Research Program

## Overview

The tropical amortization framework establishes that amortized complexity analysis is tropical semiring algebra. This opens at least five concrete research programs, each formalization-ready and building directly on the verified results.

---

## Direction 1: Automated Potential Synthesis via Tropical Linear Programming

### Hypothesis
Given a cost function `c : ℕ → ℤ` and a target amortized bound `B`, the tightest potential function `Φ` satisfying `c(i) + Φ(i+1) − Φ(i) ≤ B` for all `i` can be computed by solving a tropical linear program. The accounting–potential duality theorem (Theorem 2) guarantees that such a potential exists iff prefix domination holds.

### Proof Strategy
1. Formalize tropical linear programming over finite horizons: variables `Φ(0), ..., Φ(N)`, constraints `Φ(0) = 0`, `Φ(i) ≥ 0`, `c(i) + Φ(i+1) − Φ(i) ≤ B`.
2. Show this is a standard LP in disguise (the tropical structure reduces to ordinary linear constraints over ℤ).
3. Prove that the canonical potential `Φ(n) = nB − Σc` is optimal (minimizes max potential).
4. Implement a solver that, given a cost sequence, outputs the minimum valid amortized bound B and the corresponding potential.

### Cross-Domain Connections
- **Integer programming:** Potential synthesis as an IP feasibility problem.
- **Compiler optimization:** Automatic resource bound inference for programs.
- **Machine learning:** Learning potential functions from observed cost traces.

### Expected Deliverables
- Lean formalization of tropical LP feasibility ↔ potential existence.
- Python implementation of potential synthesis for arbitrary finite cost sequences.
- Application to automatic complexity analysis of sorting algorithms.

---

## Direction 2: Tropical Hoare Logic for Resource Verification

### Hypothesis
The step inequality `c(i) + Φ(i+1) − Φ(i) ≤ a(i)` is a Hoare-style resource invariant. A tropical Hoare logic can be constructed where:
- Pre/postconditions are potential values.
- The frame rule corresponds to tropical convolution.
- Sequential composition telescopes via the potential method.

### Proof Strategy
1. Define a tropical resource triple `{Φ_pre} cmd {Φ_post, cost}` meaning: if the potential before executing `cmd` is `Φ_pre`, then after execution the potential is `Φ_post` and the cost is bounded by `Φ_pre − Φ_post + amortized_charge`.
2. Prove the sequential composition rule using `potential_method_telescoping`.
3. Prove a frame rule using `tropicalConv_assoc` and distributivity.
4. Demonstrate on a loop invariant for dynamic array insertion.

### Cross-Domain Connections
- **Separation logic with time credits** (Charguéraud & Pottier): tropical potentials as credits.
- **Iris framework:** Tropical ghost state for resource invariants.
- **Certified compilers:** Resource-aware compilation passes verified by tropical Hoare triples.

### Expected Deliverables
- Lean formalization of tropical Hoare triples and composition rules.
- Proof of soundness: valid triples imply amortized cost bounds.
- Case study: verified amortized bound for a binary counter.

---

## Direction 3: Verified Amortized Bounds for Concrete Data Structures

### Hypothesis
The framework can produce machine-verified amortized bounds for classical data structures by instantiating the potential method with specific cost and potential functions.

### Proof Strategy
1. **Dynamic array (doubling):** `c(i) = 1` normally, `c(i) = n+1` on resize. Potential `Φ(n) = 2n − capacity`. Prove amortized cost = 3 per insertion.
2. **Binary counter:** `c(i) = 1 + (number of trailing 1-bits)`. Potential `Φ(n) = popcount(n)`. Prove amortized cost = 2 per increment.
3. **Splay tree:** Potential `Φ = Σ log(size of subtree)`. Prove O(log n) amortized access.
4. **Union-find with path compression:** Potential based on rank function. Prove O(α(n)) amortized.

For each, the proof reduces to:
- Defining `c`, `a`, `Φ` concretely.
- Verifying `c(i) + Φ(i+1) − Φ(i) ≤ a(i)` for each operation type.
- Applying `potential_method_amortized_bound`.

### Cross-Domain Connections
- **Verified data structure libraries:** Integration with Lean's standard library.
- **Competitive programming:** Machine-verified complexity guarantees.
- **Database systems:** Verified B-tree and LSM-tree amortized analysis.

### Expected Deliverables
- Lean formalizations of amortized bounds for ≥ 3 data structures.
- Reusable proof patterns that reduce future verifications to algebraic instantiation.
- Documentation of proof effort reduction vs. ad hoc approaches.

---

## Direction 4: Tropical Convexity of the Potential Space

### Hypothesis
For a fixed cost function `c` and amortized bound `B`, the set of valid potentials
```
P = {Φ : ℕ → ℤ | Φ(0) = 0 ∧ Φ(n) ≥ 0 ∧ c(i) + Φ(i+1) − Φ(i) ≤ B ∀i}
```
forms a tropical polyhedron. Its geometry encodes the space of all valid amortized analyses and reveals fundamental limits.

### Proof Strategy
1. Show P is a classical (ordinary) polyhedron in ℤ^N (the constraints are linear).
2. Characterize its vertices — these are the "extremal" potential functions.
3. Show that the canonical potential (cumulative slack) is a distinguished vertex.
4. Interpret faces of P as tropical half-spaces, connecting to tropical convexity theory.
5. Prove that optimizing over P (e.g., minimizing maximum potential) is a linear program.

### Cross-Domain Connections
- **Tropical geometry:** P as a tropical polytope; Newton polygon analogies.
- **Parametric complexity:** How the potential space changes as cost parameters vary.
- **Optimal algorithm design:** The vertices of P correspond to fundamentally different amortized analyses.

### Expected Deliverables
- Lean formalization of the potential polyhedron and its basic properties.
- Characterization of extremal potentials for simple cost sequences.
- Visualization of 2D/3D projections of the potential space.

---

## Direction 5: Semiring Structure and Weighted Automata

### Hypothesis
The associativity of tropical convolution implies that amortized cost sequences form a module over the tropical semiring. This connects to the theory of weighted automata and formal power series, suggesting:
- Amortized cost functions are tropical formal power series.
- Data structure operations are weighted transducers.
- Composition of data structures is semiring multiplication.

### Proof Strategy
1. Formalize the tropical semiring (ℕ ∪ {∞}, min, +) in Lean with its algebraic structure.
2. Show that `tropicalConv` is the multiplication operation for tropical formal power series.
3. Prove that tropical power series form a semiring (requiring commutativity and unit elements in addition to the established associativity).
4. Define weighted automata over the tropical semiring and show that their behavior corresponds to amortized cost analysis.
5. Connect to Mohri's framework for weighted finite-state transducers.

### Cross-Domain Connections
- **Formal language theory:** Weighted automata computing amortized bounds.
- **Speech recognition / NLP:** Tropical semiring algorithms (Viterbi, forward-backward).
- **Algebraic graph theory:** Tropical adjacency matrices and path algebras.
- **Quantum computing:** Connections to tropical quantum mechanics (dequantization).

### Expected Deliverables
- Lean formalization of the tropical formal power series semiring.
- Proof that convolution unit exists (the "tropical Dirac delta" δ₀).
- Connection theorems linking weighted automaton acceptance to amortized cost bounds.
- Implementation of tropical automaton composition for multi-phase algorithm analysis.

---

## Priority and Dependencies

```
Direction 3 (Data Structures) ← depends on → Direction 1 (Synthesis)
     ↓                                              ↓
Direction 2 (Hoare Logic) ← builds on → Direction 4 (Convexity)
                    ↘                        ↙
                  Direction 5 (Semiring / Automata)
```

**Recommended execution order:**
1. Direction 3 first (most immediately impactful, validates framework).
2. Direction 1 in parallel (automation enables Direction 3).
3. Direction 2 next (bridges to program verification community).
4. Directions 4 and 5 as longer-term theory development.

---

## Success Metrics

- **Direction 1:** Automatic synthesis of valid potentials for cost sequences of length ≤ 10⁶.
- **Direction 2:** Verified amortized bound for a non-trivial imperative program (≥ 50 LOC).
- **Direction 3:** Machine-verified O(1) amortized bound for ≥ 3 classical data structures.
- **Direction 4:** Complete characterization of the potential polytope for sequences of length ≤ 20.
- **Direction 5:** Tropical formal power series semiring fully formalized with convolution, identity, and distributivity.
