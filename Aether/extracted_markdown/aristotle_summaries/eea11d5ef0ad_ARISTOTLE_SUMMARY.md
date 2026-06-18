# Summary of changes for run f3cc6415-029c-4d78-a4fe-14910f82e6f5
# Graph Riemann-Roch: Chip-Firing and the Canonical Divisor

## Lean 4 Formalization (13 theorems, 0 sorries)

**File:** `Catalog/Algebra/GraphRiemannRoch/Defs.lean`

I formalized the Baker-Norine theory of divisors on finite graphs, defining:
- **Divisors** (`V → ℤ`): chip configurations on graph vertices
- **Chip-firing**: the graph Laplacian action (vertex sends one chip per edge)
- **Canonical divisor** K_G: assigns deg(v) − 2 chips to each vertex v
- **Graph genus**: g(G) = |E| − |V| + 1 (cyclomatic number)
- **Linear equivalence**: divisors differing by a Laplacian image

### Key Theorems Proved (all machine-verified, no sorry):

1. **`laplacianVec_sum`** — Laplacian row sums are zero (conservation structure)
2. **`chipFire_preserves_degree`** — Chip-firing conserves total chips (fundamental conservation law)
3. **`canonical_divisor_degree`** — deg(K_G) = 2g − 2 (the graph-theoretic analogue of the classical curve identity, uses the handshaking lemma)
4. **`riemannRoch_canonical_degree_identity`** — deg(K_G) + 1 − g = g − 1 (structural consequence of Riemann-Roch when D = K_G)
5. **`complementary_divisor_degree`** — deg(K_G − D) = 2g − 2 − deg(D) (Baker-Norine duality)
6. **`linearEquiv_preserves_degree`** — Linear equivalence preserves degree (key structural invariant)
7. **`complete_graph_degree`** — Every vertex of K_n has degree n − 1
8. **`complete_graph_edge_count`** — K_n has n(n−1)/2 edges
9. **`complete_graph_genus`** — g(K_n) = (n−1)(n−2)/2
10. **`canonical_complete_uniform`** — K_{K_n}(v) = n − 3 for all v (uniformity)
11. **`canonical_complete_degree`** — deg(K_{K_n}) = n(n−3)
12. **`chipFire_complete_sends_one`** — On K_n, firing sends exactly 1 chip to each neighbor
13. **`chipFire_complete_loses`** — On K_n, the fired vertex loses n−1 chips

All proofs depend only on standard axioms (propext, Classical.choice, Quot.sound).

## Novel Definitions
- `GraphRiemannRoch.Divisor`, `canonicalDivisor`, `chipFire`, `laplacianVec`, `linearEquiv`, `graphGenus`, `edgeWeight` — a complete algebra of graph divisors not previously in the Catalog.

## Falsifiable Conjecture
**Conjecture (stated in FUTURE_DIRECTIONS.md):** For n ≥ 3, the rank r(K_{K_n}) = (n−1)(n−2)/2 − 1. **Test:** Implement Dhar's burning algorithm and compute ranks for K_3 through K_6. Any mismatch disproves the conjecture.

## Other Deliverables

- **ARTICLE.md** — Popular-science article (~2500 words) about chip-firing and the Riemann-Roch theorem for graphs, written for a general audience. No mentions of formal verification.
- **RESEARCH_PAPER.md** — In-depth research paper (~4000 words) with definitions, proof sketches, complete graph analysis, connections to tropical geometry, and future directions.
- **FUTURE_DIRECTIONS.md** — 5 research directions with synthesis, including full Baker-Norine formalization (grand challenge), tropical Riemann-Roch, Jacobian-Kirchhoff connection, parking functions, and gonality-treewidth bounds.
- **demo.py** — Numerical demonstrations of all main theorems (runs successfully).
- **algorithms.py** — Type-hinted Python implementations of chip-firing, Dhar's burning algorithm, rank computation, and Jacobian group via Smith normal form.
- **visualize_chipfiring.py** — Matplotlib visualization of chip-firing dynamics.
- **PACKAGE.json** — Complete package with 3 interactive HTML demos: chip-firing simulator, genus explorer, and conservation law demonstrator.