# Future Directions

## Synthesis

This research cycle established the foundational formalization of Baker-Norine graph divisor theory, proving the core structural identities: chip-firing preserves degree, the canonical divisor has degree 2g − 2, and the complete graph K_n has genus (n−1)(n−2)/2. These results constitute the algebraic backbone on which the full Riemann-Roch theorem rests.

The most promising cross-domain connection is the bridge between **chip-firing on graphs** and **tropical geometry** — specifically, the Catalog's existing Tropical library (`Tropical/BrillNoether/`) which develops Brill-Noether theory for tropical curves. Our formalization of the divisor group, canonical divisor, and rank function provides the discrete foundation that could directly feed into tropical Brill-Noether computations. The genus formula and degree conservation we proved are prerequisites for any tropical specialization argument.

The highest breakthrough potential lies in Direction 1 (Dhar's Burning Algorithm), because it would unlock the full Baker-Norine theorem — the only missing piece between our structural framework and the complete Riemann-Roch formula. The algorithm is constructive and inherently formalizable, making it an ideal target for machine verification. Directions 2 and 3 offer high-value extensions that would connect our work to coding theory and spectral graph theory respectively.

---

### Direction 1: Dhar's Burning Algorithm and the Full Baker-Norine Riemann-Roch Theorem

**Conjecture**: For any connected graph G with adjacency function adj (symmetric, loopless) and any divisor D on G, the rank r(D) can be computed by Dhar's burning algorithm, and the Baker-Norine Riemann-Roch identity r(D) − r(K_G − D) = deg(D) + 1 − g(G) holds.

**Test**: Implement Dhar's burning algorithm for K_4 and verify that for every divisor D of degree 0, 1, 2, 3, 4 on K_4, the Riemann-Roch formula holds with the algorithmically computed rank. Specifically, test on D = (2, 0, −1, −1) where r(D) should equal 0, and verify r(K − D) = 0 − (0 + 1 − 3) = 2.

**Impact**: This would complete the formalization of the Baker-Norine theorem, one of the landmark results of 21st-century combinatorics. It would be the first machine-verified proof of the graph Riemann-Roch theorem.

**Catalog References**: `Tropical/BrillNoether/`, `Pythagorean/ChipFiringRiemannRoch.lean`

**Proof Strategy**:
1. Define q-reduced divisors: a divisor D is q-reduced if (a) D(v) ≥ 0 for all v ≠ q, and (b) for every nonempty subset S ⊆ V \ {q}, there exists v ∈ S with D(v) < |{edges from v to V \ S}|.
2. Prove that every divisor has a unique q-reduced representative in its linear equivalence class (using the theory of G-parking functions).
3. Prove Dhar's burning test: a divisor is q-reduced iff the "burning" process from q reaches all vertices.
4. Prove the duality lemma: D is q-reduced of degree g − 1 iff K − D is q-reduced of degree g − 1.
5. Derive Riemann-Roch from the duality lemma.

Key lemma needed: The script-firing algorithm terminates and produces the q-reduced representative.

**Domain Bridges**: Chip-firing (discrete geometry) ↔ Tropical Brill-Noether theory (algebraic geometry)

**Lineage**: Builds on `chipFire_preserves_deg`, `canonical_deg_genus`, `linEquiv_preserves_deg`, `zero_divisor_rank_nonneg` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: The Graph Jacobian and Chip-Firing as Group Theory

**Conjecture**: The Jacobian group Jac(G) = Div⁰(G) / Prin(G) (degree-zero divisors modulo principal divisors) of the complete graph K_n has order n^(n−2) (the number of spanning trees, by Kirchhoff's theorem). For general graphs, |Jac(G)| equals the number of spanning trees.

**Test**: Compute the Jacobian of K_4 explicitly as ℤ/4ℤ × ℤ/4ℤ (since K_4 has 4² = 16 spanning trees), and verify that the Smith normal form of the reduced Laplacian is diag(4, 4).

**Impact**: This would connect chip-firing to the rich theory of sandpile groups and prove a discrete analogue of the Abel-Jacobi theorem. The connection between the Jacobian order and spanning tree count (the Matrix-Tree theorem) is one of the deepest results in algebraic graph theory.

**Catalog References**: `Pythagorean/ChipFiringRiemannRoch.lean`, `Algebra/Advanced.lean`

**Proof Strategy**:
1. Define Prin(G) as the image of the Laplacian map V → Div(G).
2. Define Div⁰(G) as the kernel of the degree map.
3. Prove Jac(G) = ℤ^(|V|−1) / L(ℤ^(|V|−1)) where L is the reduced Laplacian.
4. Show |Jac(G)| = det(reduced Laplacian) = number of spanning trees (Matrix-Tree theorem).
5. For K_n, compute det explicitly using the Cayley formula.

**Domain Bridges**: Graph combinatorics ↔ Group theory ↔ Linear algebra (Smith normal form)

**Lineage**: Extends the `linEquiv` definition and `divisorDeg` framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Spectral Chip-Firing and the Laplacian Eigenvalue Connection

**Conjecture**: For a d-regular graph G on n vertices, the rank of the canonical divisor K_G = (d−2)·(1,1,...,1) satisfies r(K_G) ≥ n − 1 − ⌈n/λ₂⌉ where λ₂ is the second-smallest eigenvalue of the graph Laplacian. In particular, for Ramanujan graphs (λ₂ ≥ d − 2√(d−1)), the canonical rank is close to the genus g − 1.

**Test**: For K_5 (d = 4, λ₂ = 5, g = 6), check that r(K_{K_5}) = 5 ≥ 5 − 1 − ⌈5/5⌉ = 3. The bound gives 3, actual value is 5, so the bound holds but is not tight. Test on the Petersen graph (d = 3, n = 10, λ₂ = 2, g = 6) to check tightness.

**Impact**: This would establish a spectral lower bound on divisor ranks, connecting chip-firing theory to spectral graph theory and Ramanujan graph constructions. It could provide new bounds on error-correcting codes derived from graph divisors.

**Catalog References**: `Pythagorean/ChipFiringRiemannRoch.lean`, `Pythagorean/BerggrenRamanujanExpander.lean`, `Pythagorean/Sp2nHigherRankExpanders.lean`

**Proof Strategy**:
1. Express the rank in terms of the lattice structure of the Laplacian.
2. Use the spectral decomposition of the Laplacian to bound the number of "independent chip removals" that can be absorbed.
3. The key insight: λ₂ controls how quickly information (chips) can spread through the graph, which directly bounds the rank.

**Domain Bridges**: Chip-firing ↔ Spectral graph theory ↔ Ramanujan graphs (number theory)

**Lineage**: Bridges `canonical_deg_genus` with the spectral theory in `BerggrenRamanujanExpander.lean`.

**Ambition**: extension

---

### Direction 4: Tropical Riemann-Roch and Metric Graph Interpolation

**Conjecture**: The Baker-Norine rank function on a graph G equals the tropical rank function on the corresponding metric graph Γ (with all edge lengths 1). Moreover, for a family of metric graphs Γ_ε with edge lengths ε → 0, the tropical rank converges to the algebraic rank on the associated algebraic curve (Baker's specialization lemma).

**Test**: For the metric graph corresponding to K_4 with unit edge lengths, compute the tropical rank of the divisor D = (2, 0, 1, 0) and verify it equals the graph-theoretic rank computed by Dhar's algorithm.

**Impact**: This would formalize the bridge between discrete and continuous Riemann-Roch theory, establishing the metric graph as the interpolating object. Combined with the Catalog's tropical Brill-Noether machinery, this could yield new results on linear series on algebraic curves.

**Catalog References**: `Tropical/BrillNoether/`, `Pythagorean/ChipFiringRiemannRoch.lean`

**Proof Strategy**:
1. Define the tropical divisor theory on metric graphs (piecewise-linear functions).
2. Show that for integer edge lengths, the tropical rank equals the graph rank.
3. Prove Baker's specialization lemma: r_alg(D) ≥ r_trop(D).
4. Connect to the existing tropical Brill-Noether bounds in the Catalog.

**Domain Bridges**: Graph chip-firing ↔ Tropical geometry ↔ Algebraic geometry

**Lineage**: Extends the divisor rank framework from this cycle; connects to `Tropical/BrillNoether/`.

**Ambition**: extension

---

### Direction 5: Gonality and Graph Complexity

**Conjecture**: The gonality of K_n (the minimum degree of a divisor of rank ≥ 1) equals 2. More precisely, for any graph G with genus g ≥ 1, the gonality γ(G) satisfies 2 ≤ γ(G) ≤ g + 1, and γ(G) = 2 iff G has a divisor of degree 2 and rank 1 (a "graph-theoretic g¹₂").

**Test**: For K_4 (genus 3), verify that the divisor D = (1, 1, 0, 0) has rank 1, proving γ(K_4) ≤ 2. Then verify that no divisor of degree 1 has rank 1, proving γ(K_4) = 2.

**Impact**: Gonality is the graph-theoretic analogue of the gonality of a curve and controls the complexity of expressing the graph as a branched cover. Understanding gonality of complete graphs and random graphs is an active area of research.

**Catalog References**: `Pythagorean/ChipFiringRiemannRoch.lean`

**Proof Strategy**:
1. Define gonality as min{deg(D) : r(D) ≥ 1}.
2. For K_n, construct a degree-2 divisor of rank 1 (place 1 chip on two vertices).
3. Prove no degree-1 divisor has rank ≥ 1 using degree conservation.
4. Generalize: relate gonality to graph connectivity and expansion.

**Domain Bridges**: Chip-firing ↔ Graph connectivity ↔ Algebraic curve theory

**Lineage**: Builds on `divisorRank`, `chipFire_preserves_deg`, `complete_graph_genus`.

**Ambition**: extension
