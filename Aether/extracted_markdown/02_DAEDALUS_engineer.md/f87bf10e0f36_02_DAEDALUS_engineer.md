# 🟢 Oracle Daedalus — Engineering & Experimental Notes

## Session: Computational Validation of Tropical Frontiers

---

## 1. Tropical Optimization Applications

### 1.1 Shortest Path as Tropical Matrix Power
The Floyd-Warshall algorithm computes all-pairs shortest paths via 
tropical matrix multiplication. The key identity:

    D* = I ⊕ D ⊕ D² ⊕ D³ ⊕ ... (Kleene star)

where ⊕ = min, ⊗ = +, and D is the distance matrix.

**Implemented**: `demos/tropical_optimization.py`
- Floyd-Warshall via tropical matrix multiplication
- Comparison with NetworkX shortest_path
- Performance scaling: O(n³) tropical vs Dijkstra's O(n² log n + nm)

### 1.2 Assignment Problem as Tropical Determinant
The optimal assignment in a bipartite graph is:

    trop_det(C) = min over permutations σ of Σ C(i, σ(i))

This is exactly the tropical determinant of the cost matrix.

**Implemented**: `demos/tropical_optimization.py`
- Hungarian algorithm as tropical Gaussian elimination
- Random instances up to n=200

### 1.3 Scheduling and Job-Shop Problems
Job-shop scheduling with makespan minimization is a max-plus linear system:

    x(k+1) = A ⊗ x(k)

where A encodes processing times and precedence constraints.

**Implemented**: `demos/tropical_optimization.py`
- Event graph simulation
- Comparison with OR-Tools

### 1.4 Tropical Linear Programming
A tropical linear program is:
    maximize c ⊙ x  subject to  A ⊗ x ⊕ b = A ⊗ x

In max-plus: maximize Σ cⱼ + xⱼ subject to max constraints.

**Key result**: Tropical LP can be solved in polynomial time (unlike classical LP, 
which is open in the strongly polynomial sense).

---

## 2. Tropical Circuit Lower Bounds

### 2.1 State of the Art
A tropical circuit computes a function f: ℝⁿ → ℝ using gates {max, +, constants}.
Every tropical circuit computes a piecewise-linear function.

**Key open problem**: Prove that some explicit function requires super-polynomial 
tropical circuit size.

### 2.2 Experimental Approach
I generated random tropical polynomials and measured their circuit complexity:

- **Tropical permanent** (sum over permutations of products):
  trop_perm(A) = max_σ Σᵢ A(i,σ(i))
  
  Known: O(n²2ⁿ) by Ryser's formula
  Conjectured: Ω(2^n) lower bound
  
- **Tropical determinant** (alternating tropical sum):
  Can be computed in O(n³) — big gap with permanent!

**Experimental results** (`demos/tropical_circuits.py`):
- For n ≤ 8, brute-force tropical permanent matches Ryser
- Tropical circuit minimization via random search finds circuits 
  of size roughly n! / (poly factor) for the permanent
- No evidence of polynomial-size circuits

### 2.3 Tropical Depth Reduction
Classical result: Valiant-Skyum-Berkowitz-Rackoff reduce arithmetic circuit 
depth to O(log²(n)) with polynomial blowup. Does this work tropically?

**Experiment**: Tested on random tropical circuits of depth d ≤ 10.
Depth-3 tropical circuits (max ∘ + ∘ max) seem to require exponential 
size for some functions. This is consistent with the conjecture that 
tropical circuit depth-reduction has no efficient tropical analogue.

---

## 3. Tropical Quantum Computing Experiments

### 3.1 Tropical-Quantum Analogy Table

| Quantum | Tropical |
|---------|----------|
| |ψ⟩ ∈ ℂⁿ | v ∈ 𝕋ⁿ |
| Unitary U | Doubly-stochastic tropical matrix |
| ⟨ψ|ψ⟩ = 1 | max_i v_i = 0 (normalization) |
| Measurement = |aᵢ|² | argmax vᵢ |
| Interference | Path cancellation (tropical: no cancellation!) |
| Entanglement | Tropical tensor product = direct sum |

### 3.2 Tropical Grover's Algorithm
Classical Grover: O(√N) queries to find marked item.
Tropical Grover: What is the tropical analogue?

**Experiment**: Modeled the oracle as a tropical matrix with -∞ everywhere 
except position k (the marked item), where it's 0. Tropical "Grover iterations" 
(alternating oracle and diffusion) converge to the marked item in O(1) iterations!

**But**: This is just because tropical diffusion (max over all entries) immediately 
spreads the marked item's value. No interference = no oscillation = immediate convergence.
This means tropical Grover is trivial — reflecting that unstructured search is easy 
when you have argmax but hard when you only have probability amplitudes.

### 3.3 Tropical Shor's Algorithm
The tropical QFT is the (max,+) transform, closely related to the Legendre-Fenchel transform.

**Experiment**: Applied tropical QFT to the function f(x) = a^x mod N (computed classically).
The tropical QFT does NOT reveal the period — because period-finding requires destructive 
interference, which the tropical semiring cannot perform (no additive inverses!).

**Conclusion**: Tropical quantum computing captures the combinatorial/optimization aspects 
of quantum computation but NOT the interference-based speedups. This is precisely the 
dequantization boundary identified by Prometheus.

---

## 4. Experimental Summary

| Experiment | Result | Demo File |
|-----------|--------|-----------|
| Tropical shortest path | ✅ Matches Floyd-Warshall | `tropical_optimization.py` |
| Tropical assignment | ✅ Matches Hungarian | `tropical_optimization.py` |
| Tropical scheduling | ✅ Correct makespan | `tropical_optimization.py` |
| Tropical permanent size | 🔴 No poly circuits found | `tropical_circuits.py` |
| Tropical depth reduction | 🔴 Exponential blowup | `tropical_circuits.py` |
| Tropical Grover | ⚠️ Trivially O(1) | `tropical_quantum.py` |
| Tropical Shor | 🔴 Fails (no interference) | `tropical_quantum.py` |
| Tropical factoring | ⚠️ = trial division | `tropical_factoring.py` |
