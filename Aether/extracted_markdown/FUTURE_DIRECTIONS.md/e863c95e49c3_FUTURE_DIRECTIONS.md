# Future Directions: Structural Transcendence Rank

## Conjecture 1: Spectral-Rank Coincidence

**Statement:** For every finite structurally parallel attention model `M` with generators `e₁, …, eₖ`, the spectral witness rank (the minimal number of distinct eigenvalue clusters in the attention spectrum) equals the finite transcendence rank (the maximum cardinality of an independent generator family under the structural closure).

**Test:** Enumerate all attention models on ≤ 8 generators. For each, compute:
- `spectralWitnessRank(M)` by clustering the eigenvalues of the attention weight matrix,
- `finTranscendenceRank(M)` by exhaustive search over the powerset of generators.

A counterexample is any model where these two numbers differ.

**Impact:** If true, this would establish a deep connection between linear-algebraic spectral methods and combinatorial independence, providing a polynomial-time proxy for the NP-hard independence computation.

---

## Conjecture 2: Perturbation Rigidity Threshold

**Statement:** For any closure operator `cop` and finite set `A`, there exists a critical threshold `ε* > 0` such that for all perturbation sets `P` with `|P| < ε* · |A|`, the transcendence rank is unchanged: `finTranscendenceRank cop A = finTranscendenceRank (perturbClosure cop P) A`.

**Test:** For random closure operators on sets of size 10–50, compute the rank for increasing perturbation sizes. Find the exact transition point where rank first decreases. Check whether the threshold is always ≥ 1/|A| (as predicted by the tropical perturbation bound).

**Disproof criterion:** Find a closure operator where rank changes under perturbation by a single element (|P| = 1), which would mean ε* = 0 for some systems.

**Impact:** If a universal positive threshold exists, rank-based complexity certificates would be noise-tolerant, enabling practical applications in machine learning architecture comparison.

---

## Conjecture 3: Tropical Complexity Gap

**Statement:** For tropical matrices of size n × n, the tropical complexity (number of distinct entry values) of any matrix expressible as a product of ≤ k rank-1 tropical matrices satisfies `tropComplexity(A) ≤ 2k - 1`. This would be tight for the "staircase" construction.

**Test:** Enumerate all tropical matrices of size 4 × 4 with entries in {0, 1, 2, 3}. For each, compute the minimal k such that A = A₁ ⊗ A₂ ⊗ ··· ⊗ Aₖ with each Aᵢ having at most 2 distinct values. Check the bound `tropComplexity(A) ≤ 2k - 1`.

**Disproof criterion:** A matrix with tropComplexity > 2k - 1 for its minimal tropical rank factorization.

**Impact:** Would give an exact characterization of tropical computational complexity, with applications to shortest-path algorithms and scheduling theory.

---

## Conjecture 4: Proof Rank Additivity Under Cut Elimination

**Statement:** For any proof tree `pt`, cut elimination produces a cut-free proof `pt'` with `proofRank(pt') = proofRank(pt)`. That is, cut elimination preserves the number of axiom leaves exactly.

**Test:** Implement cut elimination on the `ProofTree` inductive type. For random proof trees of depth ≤ 10, verify that axiom count is preserved.

**Disproof criterion:** A proof tree where cut elimination changes the axiom count. This would happen if cut elimination duplicates or eliminates axiom applications.

**Impact:** If true, this proves that the proof-theoretic transcendence rank is an invariant of the *proposition* being proved, not just the proof. This would be the proof-theoretic analogue of the structural congruence invariance theorem.

---

## Conjecture 5: Rank-Capacity Convergence

**Statement:** For a sequence of closure systems `(M_n)` with increasing state spaces, if the closure capacity (number of Myhill–Nerode equivalence classes) grows as `Θ(f(n))`, then the transcendence rank grows as `Θ(log f(n))`.

**Test:** Construct explicit families:
1. Full binary tree closure systems (capacity 2ⁿ, predicted rank n)
2. Linear chain systems (capacity n, predicted rank log n)
3. Random closure systems on n states

Compute both quantities and test the logarithmic relationship.

**Disproof criterion:** A family where rank grows polynomially with capacity (not logarithmically).

**Impact:** Would establish a universal compression theorem: the "essential dimension" of a system grows logarithmically slower than its apparent complexity, enabling exponential compression of structural representations.
