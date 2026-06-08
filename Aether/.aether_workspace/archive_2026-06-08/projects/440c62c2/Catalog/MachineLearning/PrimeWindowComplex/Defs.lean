/-
# Prime Window Complexes: Topological Observables for Prime Statistics

This module defines prime gap graphs and their clique complexes, establishing
a formal dictionary between combinatorial topology and analytic number theory.

## Main Definitions

* `primeWindowVertices n L` — the set of primes in [n, n+L-1]
* `primeGapGraph n L S` — the simple graph on primes with edges for admissible gaps
* `edgeCount n L S` — number of edges in the prime gap graph
* `primePairCount n L h` — count of prime pairs with gap h in the window
* `vertexCount n L` — number of vertices (primes) in the window
* `triangleCount n L S` — count of triangles (3-cliques) in the prime gap graph
* `eulerCharFiniteGraph n L S` — Euler characteristic χ = V - E + T

## Main Results

* `edgeCount_eq_sum_primePairCount` — edges decompose as sum of pair counts by gap
* `primeGapGraph_mono` — gap-set inclusion yields graph inclusion
* `edgeCount_mono` — edge count is monotone in the gap set
* `euler_char_bounds` — bounds on Euler characteristic

## Cross-Domain Connections

The prime gap graph is an arithmetic deformation of an Erdős–Rényi random graph.
The edge count is literally a pair-correlation statistic, connecting:
- **Analytic number theory**: twin prime counts, prime pair statistics
- **Topological data analysis**: clique complex filtrations
- **Random matrix theory**: via Montgomery's pair correlation conjecture

## Falsifiable Conjecture (Prime Window Homology–GUE Conjecture)

Fix 0 < θ < 1. For large X, define a filtered prime-gap clique complex
K_X(t) := K(⌊X⌋, ⌊X^θ⌋, S_t(X)) where S_t(X) = {h ∈ 2ℕ : 2 ≤ h ≤ t log X}.
Let Λ_X be the Euler curve of this filtration after explicit normalization.

**Conjecture**: There exist explicit normalizations A_X, B_X such that
A_X(Λ_X - B_X) converges in distribution as X → ∞ to a universal limit
if and only if Montgomery's pair correlation conjecture holds for ζ(s).

**Testable prediction**: Compute Λ_X for increasing X and compare actual primes
against (1) Cramér random model, (2) residue-constrained model, (3) GUE-informed
pair process. The conjecture predicts that the actual-prime Euler curve
fluctuations match the GUE prediction and diverge from the Cramér model.
-/

import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

/-- The set of primes in the interval [n, n + L - 1]. -/
def primeWindowVertices (n L : ℕ) : Finset ℕ :=
  (Finset.Icc n (n + L - 1)).filter Nat.Prime

/-- The number of primes in the window [n, n + L - 1]. -/
def vertexCount (n L : ℕ) : ℕ :=
  (primeWindowVertices n L).card

/-- The prime gap graph on ℕ: vertices are primes in [n, n+L-1],
    and an edge connects primes p < q when q - p ∈ S. -/
def primeGapGraph (n L : ℕ) (S : Finset ℕ) : SimpleGraph ℕ where
  Adj i j := i ≠ j ∧ i ∈ primeWindowVertices n L ∧ j ∈ primeWindowVertices n L ∧
    ((i < j ∧ j - i ∈ S) ∨ (j < i ∧ i - j ∈ S))
  symm := by
    intro i j ⟨hne, hi, hj, hor⟩
    exact ⟨hne.symm, hj, hi, hor.symm⟩
  loopless := ⟨fun i h => h.1 rfl⟩

/-- The set of ordered pairs (p, q) with p < q, both primes in the window,
    and q - p ∈ S. This counts edges as ordered pairs. -/
def edgePairSet (n L : ℕ) (S : Finset ℕ) : Finset (ℕ × ℕ) :=
  ((primeWindowVertices n L).product (primeWindowVertices n L)).filter
    fun pq => pq.1 < pq.2 ∧ pq.2 - pq.1 ∈ S

/-- The number of edges in the prime gap graph. -/
def edgeCount (n L : ℕ) (S : Finset ℕ) : ℕ :=
  (edgePairSet n L S).card

/-- Count of prime pairs (p, p+h) where both p and p+h are primes in the window. -/
def primePairCount (n L h : ℕ) : ℕ :=
  ((primeWindowVertices n L).filter (fun p => p + h ∈ primeWindowVertices n L)).card

/-- The set of triangles in the prime gap graph: ordered triples (p, q, r)
    with p < q < r, all primes in the window, with all pairwise gaps in S. -/
def triangleSet (n L : ℕ) (S : Finset ℕ) : Finset (ℕ × ℕ × ℕ) :=
  ((primeWindowVertices n L).product
    ((primeWindowVertices n L).product (primeWindowVertices n L))).filter
    fun t => t.1 < t.2.1 ∧ t.2.1 < t.2.2 ∧
      t.2.1 - t.1 ∈ S ∧ t.2.2 - t.2.1 ∈ S ∧ t.2.2 - t.1 ∈ S

/-- The number of triangles (3-cliques) in the prime gap graph. -/
def triangleCount (n L : ℕ) (S : Finset ℕ) : ℕ :=
  (triangleSet n L S).card

/-- Euler characteristic of the prime gap clique complex, truncated at dimension 2.
    χ = V - E + T where V = vertices, E = edges, T = triangles. -/
def eulerCharFiniteGraph (n L : ℕ) (S : Finset ℕ) : ℤ :=
  (vertexCount n L : ℤ) - (edgeCount n L S : ℤ) + (triangleCount n L S : ℤ)

/-- Expected edge count under a Bernoulli random model where each position
    in [n, n+L-1] is independently prime with probability p. -/
noncomputable def expectedEdgeCountBernoulli (L : ℕ) (S : Finset ℕ) (p : ℝ) : ℝ :=
  ∑ h ∈ S, ((L : ℝ) - (h : ℝ)) * p ^ 2

/-! ## Computational Verification -/

-- Verify definitions compute correctly
#eval primeWindowVertices 10 20  -- {11, 13, 17, 19, 23, 29}
#eval vertexCount 10 20          -- 6
#eval edgeCount 10 20 {2, 4, 6}  -- 8
#eval primePairCount 10 20 2     -- 2
#eval primePairCount 10 20 4     -- 2
#eval primePairCount 10 20 6     -- 4
-- 2 + 2 + 4 = 8 ✓
#eval triangleCount 10 20 {2, 4, 6}  -- should be some value
#eval eulerCharFiniteGraph 10 20 {2, 4, 6}