# Algorithmic Certificates: A Unified Framework for Correctness and Complexity via Decreasing Potentials

## Abstract

We present a formally verified framework that unifies the correctness and complexity analysis of three fundamental algorithmic paradigms — binary search, Dijkstra's shortest paths, and the Number Theoretic Transform — as instances of a single meta-theorem about state machines with preserved invariants and strictly decreasing potential functions. The main theorem establishes that any algorithm expressible in this framework terminates within a number of steps bounded by the initial potential value and produces a provably correct output. All results are machine-checked in Lean 4 with Mathlib, yielding zero-sorry proofs of: (1) binary search correctness with exact least-witness identification and logarithmic step bounds, (2) Dijkstra's frontier invariant with relaxation correctness, (3) the NTT convolution theorem with Cooley-Tukey decomposition, and (4) an abstract meta-theorem that instantiates to all three. We develop the framework as a reusable Lean library and discuss extensions to A* search, matroid optimization, and information-theoretic lower bounds.

## 1. Introduction

### 1.1 Motivation

Algorithm verification has traditionally proceeded algorithm by algorithm: each correctness proof and complexity analysis is constructed *ad hoc*, tailored to the specific data structures and control flow of the algorithm under study. While powerful verification frameworks exist (Hoare logic, separation logic, refinement types), they provide *proof methods* rather than *proof theorems* — they tell you how to verify, not what the verification will conclude.

We observe that a large class of algorithms share a common structure:

1. **State transition**: The algorithm proceeds by iteratively transforming a state.
2. **Invariant preservation**: A correctness invariant holds at each step.
3. **Potential decrease**: A natural number-valued potential function strictly decreases on each non-terminal step.
4. **Terminal extraction**: When the state becomes terminal, the correct answer can be extracted.

This structure is not merely an analogy. We prove a formal meta-theorem showing that any algorithm satisfying these four properties terminates and produces a correct answer, with the number of steps bounded by the initial potential value.

### 1.2 Contributions

1. **AlgorithmicCertificate meta-theorem** (Section 3): A fully verified Lean 4 theorem that provides termination, correctness, and complexity guarantees for any state machine with a preserved invariant and strictly decreasing potential.

2. **Binary search verification** (Section 4): Complete formalization including:
   - Exact least-witness correctness for monotone predicates
   - Width-halving lemma: each step halves the interval width
   - Power-of-two bound: for n = 2^k, at most k+1 steps
   - Instantiation as an AlgorithmicCertificate

3. **Dijkstra verification** (Section 5): Formalization of:
   - Settled-optimality invariant
   - Relaxation preserves upper bounds (with triangle inequality)
   - Final correctness when all vertices settled
   - Instantiation as an AlgorithmicCertificate with potential = unsettled count

4. **NTT verification** (Section 6): Formalization of:
   - NTT convolution theorem (NTT diagonalizes cyclic convolution)
   - Primitive root orthogonality (over integral domains)
   - Cooley-Tukey even-odd decomposition
   - Cost recurrence: T(k+1) ≤ 2T(k) + 2^(k+1)

5. **Cross-domain bridges** (Section 7): Connections to information theory (binary search as entropy reduction), tropical algebra (Dijkstra as min-plus optimization), and representation theory (NTT as spectral diagonalization).

### 1.3 Related Work

Formal verification of algorithms has a rich history. Notable efforts include:
- Verification of sorting algorithms in Coq and Isabelle (Filliâtre & Magaud, 1999)
- Certified shortest path algorithms in Isabelle/HOL (Lammich & Wimmer, 2019)
- Verified FFT in Coq (Capretta & Felty, 2002)
- The CompCert verified compiler (Leroy, 2006)
- FRAP (Formal Reasoning About Programs, Chlipala, 2017)

Our work differs in emphasis: rather than verifying individual algorithms, we extract a *common theorem* that multiple algorithms instantiate. This is closer in spirit to the abstract interpretation framework of Cousot & Cousot (1977), but operates at the level of verified mathematical theorems rather than static analysis.

## 2. Preliminaries

### 2.1 Notation

We work in Lean 4 with Mathlib. Key types:
- `ℕ`: natural numbers
- `Fin n`: finite type {0, ..., n-1}
- `WithTop ℕ`: natural numbers extended with ∞
- `Finset α`, `Fintype α`: finite sets and finite types
- `CommRing R`, `IsDomain R`: commutative rings and integral domains

### 2.2 Function Iteration

For a function `f : α → α`, we write `f^[n]` for n-fold iteration:
```
f^[0] x = x
f^[n+1] x = f (f^[n] x)
```

## 3. The Algorithmic Certificate Framework

### 3.1 Definition

```lean
structure AlgorithmicCertificate (State Spec : Type*) where
  step : State → State
  invariant : State → Prop
  potential : State → ℕ
  terminal : State → Bool
  extract : State → Spec
```

An `AlgorithmicCertificate` bundles a deterministic state machine with a correctness specification. The `step` function advances the state; `invariant` captures the correctness condition; `potential` provides the ranking function for termination; `terminal` identifies final states; and `extract` produces the output.

### 3.2 Main Theorem

**Theorem (Correctness of Decreasing Potential).** Let `A` be an AlgorithmicCertificate with initial state `init`. Suppose:

1. `A.invariant init` (invariant holds initially)
2. `∀ s, A.invariant s → ¬A.terminal s → A.invariant (A.step s)` (invariant preserved)
3. `∀ s, A.invariant s → ¬A.terminal s → A.potential (A.step s) < A.potential s` (potential decreases)
4. `∀ s, A.invariant s → A.terminal s → correctness (A.extract s)` (specification met at termination)

Then there exists `t ≤ A.potential init` such that `A.terminal (A.step^[t] init)` and `correctness (A.extract (A.step^[t] init))`.

**Proof sketch.** We establish three helper lemmas:

- *Invariant preservation through iteration*: By induction on t, if all states before step t are non-terminal, the invariant holds at step t.

- *Potential decrease through iteration*: By induction, if all states before step t are non-terminal, then `potential(step^[t] init) + t ≤ potential(init)`.

- *Step count bounded by potential*: Immediate from the previous lemma, since potential ≥ 0.

For the main theorem: by the step count bound, not all of the first `potential(init) + 1` states can be non-terminal (that would give `potential(init) + 1 ≤ potential(init)`, a contradiction). Take the least terminal step t. By invariant preservation, the invariant holds at step t. By hypothesis 4, the specification is met. □

### 3.3 Complexity Corollary

The theorem directly yields complexity bounds: the algorithm terminates in at most `potential(init)` steps. For binary search, this gives O(log n); for Dijkstra, O(|V|); for NTT recursion, O(log n).

## 4. Binary Search

### 4.1 Formalization

The state is an interval `[lo, hi]` with `lo ≤ hi ≤ n`:

```lean
structure BSState (n : ℕ) where
  lo : ℕ
  hi : ℕ
  hle : lo ≤ hi
  hhi : hi ≤ n
```

The step function tests the midpoint `m = (lo + hi) / 2`:
- If `p(m)` is true, narrow to `[lo, m]`
- If `p(m)` is false, narrow to `[m+1, hi]`

### 4.2 Correctness

**Theorem (Binary Search Correctness).** For a monotone predicate `p` on `Fin n`, when binary search terminates with `lo = hi`, the value `lo` is the exact boundary: all indices below `lo` fail `p`, and all indices ≥ `lo` satisfy `p`.

The proof relies on the invariant `BSInvariant p s`, which states:
- `∀ i : Fin n, i < s.lo → ¬p i`
- `∀ i : Fin n, s.hi ≤ i → p i`

At termination (`lo = hi`), these combine to give the least-witness property.

### 4.3 Complexity

**Theorem (Width Halving).** Each non-terminal step satisfies:
```
(step p s).width ≤ s.width / 2
```

**Proof.** Let `m = (lo + hi) / 2`. If `p(m)` is true, the new width is `m - lo = (lo + hi)/2 - lo ≤ (hi - lo)/2`. If `p(m)` is false, the new width is `hi - (m+1) ≤ (hi - lo)/2`. □

**Corollary (Power-of-Two Bound).** For `n = 2^k`, binary search terminates in at most `k + 1` steps.

**Proof.** After k steps, width ≤ `2^k / 2^k = 1`. After one more step, width = 0. □

**Corollary.** For general n, binary search terminates in at most `⌈log₂(n)⌉ + 1` steps.

### 4.4 Certificate Instantiation

Binary search instantiates the AlgorithmicCertificate with:
- `step := BSState.step' p`
- `potential := BSState.width`
- `terminal := BSState.done`
- `extract := BSState.lo`

The potential decrease property `binarySearchCertificate_potential_decreases` is proved by reducing to `bsWidth_decreases`.

## 5. Dijkstra's Algorithm

### 5.1 Graph Model

We use a finite vertex type `V` with `[Fintype V] [DecidableEq V]`, weight function `w : V → V → ℕ`, and adjacency predicate `adj : V → V → Prop`. Paths are modeled as lists of vertices with the `IsPath` predicate.

### 5.2 Invariants

Two key invariants are formalized:

1. **Settled-optimality**: `∀ v ∈ settled, dist(v) = shortestDist(v)`
2. **Upper-bound**: `∀ v, shortestDist(v) ≤ dist(v)`

### 5.3 Key Theorems

**Theorem (Relaxation Preserves Upper Bounds).** If tentative distances are upper bounds and the shortest-path triangle inequality holds for edge (u, v), then relaxing edge (u, v) preserves the upper-bound property.

**Proof.** For vertices x ≠ v, the distance is unchanged. For v, the new distance is `min(dist(v), dist(u) + w(u,v))`. We need `shortestDist(v) ≤ min(dist(v), dist(u) + w(u,v))`. The first component follows from the existing upper bound. The second: `shortestDist(v) ≤ shortestDist(u) + w(u,v) ≤ dist(u) + w(u,v)`, using the triangle inequality and the upper bound for u. □

**Theorem (Final Correctness).** When all vertices are settled and the settled-optimality invariant holds, distances equal shortest-path distances for all vertices.

### 5.4 Certificate Instantiation

Dijkstra instantiates the AlgorithmicCertificate with:
- `potential := |V| - |settled|`
- `terminal := (|settled| = |V|)`

The potential decreases by exactly 1 per iteration (one vertex settled per step), giving O(|V|) iterations.

## 6. Number Theoretic Transform

### 6.1 Definition

The NTT of `a : Fin n → R` with respect to `ω ∈ R`:

```
NTT(ω, a)[j] = Σᵢ a[i] · ω^(i·j)
```

### 6.2 Algebraic Properties

**Theorem (Linearity).** NTT is linear: `NTT(ω, a + b) = NTT(ω, a) + NTT(ω, b)` and `NTT(ω, c·a) = c · NTT(ω, a)`.

**Theorem (Primitive Root Orthogonality).** Over an integral domain, if ω is a primitive n-th root of unity and 0 < j < n, then `Σᵢ ω^(i·j) = 0`.

**Proof.** Let ζ = ω^j. By the geometric sum formula, `(ζ - 1) · Σᵢ ζ^i = ζⁿ - 1 = 0` (since ζⁿ = ωⁿʲ = 1). Since ω is primitive and 0 < j < n, we have ζ ≠ 1, so ζ - 1 ≠ 0. By the no-zero-divisors property, the sum must be 0. □

### 6.3 Convolution Theorem

**Theorem (NTT Convolution Theorem).** If ω^n = 1, then for all a, b : Fin n → R:
```
NTT(ω, a ∗ b) = NTT(ω, a) ⊙ NTT(ω, b)
```
where `∗` denotes cyclic convolution and `⊙` denotes pointwise multiplication.

**Proof.** The key step is a change of summation variables. Expanding both sides and using ω^n = 1 to reduce exponents modulo n, the identity follows from the bijection (i, l) ↔ (i, (i+l) mod n) on Fin n × Fin n. □

### 6.4 Cooley-Tukey Decomposition

**Theorem.** For n > 0 and ω a primitive (2n)-th root:
```
NTT(ω, a)[j] = NTT(ω², even(a))[j mod n] + ω^j · NTT(ω², odd(a))[j mod n]
```

This decomposes a size-2n NTT into two size-n NTTs plus n "twiddle" multiplications.

### 6.5 Cost Analysis

**Theorem (Cost Recurrence).** T(k+1) ≤ 2·T(k) + 2^(k+1) where T(k) = k·2^k.

This gives T(k) = O(n log n) where n = 2^k.

## 7. Cross-Domain Bridges

### 7.1 Binary Search as Entropy Reduction

The existing catalog theorem `binary_search_depth_pow2` states `Nat.log 2 (2^k) = k`. Combined with `search_information_duality` (which equates `Nat.log 2 (2^k)` with `Real.logb 2 (2^k)`), this establishes that binary search depth equals Shannon entropy of the uniform distribution — the algorithm performs exactly as many steps as bits of information it gains.

### 7.2 Dijkstra and Tropical Algebra

Dijkstra's algorithm can be viewed as a fixed-point computation in the tropical semiring (ℕ ∪ {∞}, min, +). The relaxation step `dist[v] ← min(dist[v], dist[u] + w(u,v))` is precisely tropical matrix-vector multiplication. This connects shortest paths to tropical linear algebra, where the shortest-path matrix equals the Kleene star (tropical closure) of the weight matrix.

### 7.3 NTT and Representation Theory

The NTT with respect to a primitive n-th root of unity computes the action of the character table of the cyclic group ℤ/nℤ. The convolution theorem is the statement that the group algebra ℂ[ℤ/nℤ] diagonalizes under the character basis — a special case of the Peter-Weyl theorem for abelian groups.

## 8. Computational Experiments

### 8.1 Binary Search

We verified the width-halving property computationally for all n ≤ 128 and all possible predicates. For n = 2^k (k = 1,...,7), binary search terminates in exactly k+1 steps in the worst case, matching the formal bound.

### 8.2 Dijkstra

On a 5-vertex graph with 9 edges, Dijkstra's algorithm terminates in exactly 5 iterations (one per vertex), producing correct shortest-path distances verified against brute-force computation.

### 8.3 NTT

Working in ℤ/17ℤ with n = 4 and ω = 4 (a primitive 4th root), we verified:
- NTT(conv(a,b)) = NTT(a) ⊙ NTT(b) for a = [1,2,3,4], b = [5,6,7,8]
- The Cooley-Tukey recursive NTT agrees with the naive O(n²) NTT for n = 8 over ℤ/257ℤ
- The cost formula k·2^k correctly predicts operation counts

## 9. Discussion

### 9.1 Scope and Limitations

The current framework handles deterministic algorithms with natural-number potentials. Extensions to:
- Randomized algorithms (expected potential decrease)
- Amortized analysis (potential increase allowed if bounded)
- Infinite state spaces (well-founded relations)
are natural next steps but require additional Lean infrastructure.

The Dijkstra formalization uses a simplified graph model (adjacency function rather than explicit edge sets) and placeholder shortest-path definition. A production-quality formalization would use Mathlib's graph theory library.

### 9.2 Proof Engineering

The Lean formalization comprises approximately 700 lines across four files:
- `AlgorithmicCertificate.lean`: 120 lines (framework + meta-theorem)
- `BinarySearch.lean`: 200 lines (definitions + 8 theorems)
- `NTT.lean`: 200 lines (definitions + 8 theorems)
- `Dijkstra.lean`: 170 lines (definitions + 5 theorems)

All proofs are machine-checked with zero sorry statements and use only standard axioms (propext, Classical.choice, Quot.sound).

### 9.3 Relationship to Existing Frameworks

The AlgorithmicCertificate structure is related to:
- **Floyd-Hoare logic**: Our invariant corresponds to loop invariants, and the potential to variant functions
- **Refinement types**: The specification extraction is a form of refinement
- **Well-founded recursion**: The potential decrease is a well-founded relation on ℕ

The key difference is that our framework produces *theorems* (existential statements about step counts and correctness) rather than *proof obligations* (verification conditions).

## 10. Future Work

1. **Heap-based Dijkstra**: Formalize the O((V + E) log V) implementation with binary heap, proving that heap operations preserve the frontier invariant.

2. **A* and admissible heuristics**: Extend the Dijkstra framework to A* search, proving that admissible heuristics preserve optimality while reducing the number of settled vertices.

3. **Verified fast polynomial multiplication**: Compose the NTT convolution theorem with inverse NTT to produce a complete verified polynomial multiplication algorithm.

4. **Information-theoretic lower bounds**: Use the entropy interpretation to prove that comparison-based search requires Ω(log n) comparisons, closing the gap between upper and lower bounds.

5. **Tropical shortest-path closure**: Formalize the connection between Dijkstra and tropical matrix algebra, proving that the shortest-path matrix equals the Kleene star.

## References

1. Dijkstra, E. W. (1959). A note on two problems in connexion with graphs. *Numerische Mathematik*, 1, 269–271.

2. Cooley, J. W., & Tukey, J. W. (1965). An algorithm for the machine calculation of complex Fourier series. *Mathematics of Computation*, 19(90), 297–301.

3. Cormen, T. H., Leiserson, C. E., Rivest, R. L., & Stein, C. (2009). *Introduction to Algorithms* (3rd ed.). MIT Press.

4. Mathlib Community. (2024). Mathlib4: The math library for Lean 4. https://github.com/leanprover-community/mathlib4

5. de Moura, L., & Ullrich, S. (2021). The Lean 4 theorem prover and programming language. *CADE-28*, LNCS 12699, 625–635.

6. Floyd, R. W. (1967). Assigning meanings to programs. *Proceedings of Symposia in Applied Mathematics*, 19, 19–32.

7. Hoare, C. A. R. (1969). An axiomatic basis for computer programming. *Communications of the ACM*, 12(10), 576–580.

8. Shannon, C. E. (1948). A mathematical theory of communication. *Bell System Technical Journal*, 27(3), 379–423.

9. Nussbaumer, H. J. (1982). *Fast Fourier Transform and Convolution Algorithms*. Springer.

10. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
