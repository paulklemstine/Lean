# Future Directions: Higher-Rank Defect Spectrum Theory

## Synthesis

The higher-degree structural defect theory establishes that the defect spectrum d ↦ δ_d(G,q,S) is exactly affine with slope β₁(G[S]) and intercept κ(G,q,S) − 1. This creates a *discrete Hilbert polynomial* framework for rooted graph divisors. The five future directions below form a coherent program: Direction 1 validates the theory against actual chip-firing rank (ground truth), Direction 2 extends the structural recursion to full deletion–contraction, Direction 3 lifts the scalar degree to a vector-valued rank parameter (the heart of higher-rank theory), Direction 4 connects to tropical moduli spaces, and Direction 5 applies the invariant to concrete computational problems. Together, they aim to establish a complete **discrete higher-rank Brill–Noether theory** grounded in machine-verified proofs.

---

## Direction 1: Chip-Firing Rank Validation at Higher Degrees

**Conjecture:** For every finite connected graph G, root q, subset S with q ∉ S, and degree d ≥ 1, define the higher-degree rooted divisor D_d = d · D_S (the d-fold scaling of the rooted subset divisor). Then the *actual* rank defect — defined as (expected naive rank) − r(D_d) — equals the higher structural defect δ_d(G,q,S) = d · β₁(G[S]) + κ(G,q,S) − 1.

**Test:** Implement chip-firing rank computation (using Dhar's burning algorithm or Baker–Norine's q-reduced forms) for divisors d · D_S on all connected graphs with up to 7 vertices. Compare computed rank against the topological prediction. A single mismatch falsifies the conjecture.

**Impact:** This would establish the higher structural defect as a *theorem* about divisor rank, not merely a definition. It would give a closed-form, O(|V|+|E|)-time algorithm for computing divisor rank of scaled rooted divisors — dramatically faster than chip-firing.

**Catalog References:**
- `Pythagorean/TropicalBridge/DefectTheory.lean` — degree-1 structural defect
- `Pythagorean/TropicalBridge/HigherDefectTheory.lean` — higher-degree invariant definitions and algebraic properties

**Proof Strategy:** Induction on β₁ using the cycle-extension recursion (Theorem 4.8). Base case: trees, where the degree-1 validation is already in the catalog. Inductive step: show that adding one cycle-creating edge changes both the actual rank defect and the structural prediction by exactly d.

**Domain Bridges:** Baker–Norine theory, Dhar's algorithm, tropical linear series

**Lineage:** Extends the degree-1 defect validation from DefectTheory.lean to all degrees.

**Ambition:** 🟡 Solid extension — requires significant but feasible computational infrastructure.

---

## Direction 2: Full Deletion–Contraction Recursion

**Conjecture:** For any edge e in G[S] that lies on a cycle, let G−e denote the graph with e deleted. Then:

    δ_d(G, q, S) = δ_d(G−e, q, S) + d

Moreover, the root component count κ is preserved by such deletions: κ(G−e, q, S) = κ(G, q, S).

**Test:** For all connected graphs on up to 6 vertices, identify all cycle edges in G[S] for each (q, S) pair. Delete each and verify the recursion computationally.

**Impact:** A full deletion–contraction law would enable inductive proofs on arbitrary graphs, reducing any defect computation to the tree case. Combined with tree stability (Theorem 4.3), this would give a complete inductive proof of the main formula.

**Catalog References:**
- `Pythagorean/TropicalBridge/HigherDefectTheory.lean` — IsSingleCycleExtension, cycle-extension recursion
- `Pythagorean/TropicalBridge/DefectTheory.lean` — structural defect definition

**Proof Strategy:** Define `IsCycleDeletion` as the inverse of `IsSingleCycleExtension`. Show that deleting a cycle edge decreases β₁ by exactly 1 (standard graph theory) and preserves κ (requires showing cycle edges don't affect root component structure). The defect change follows algebraically.

**Domain Bridges:** Tutte polynomial, matroid theory (cycle matroid), topological graph theory

**Lineage:** Strengthens Theorem 4.8 from cycle extension to full deletion–contraction.

**Ambition:** 🟡 Solid extension — the key difficulty is the κ-preservation lemma.

---

## Direction 3: Multi-Degree Defect and Vector Bundle Analogues (Grand Challenge)

**Conjecture:** Define a **multi-degree defect** indexed by a tuple (d₁, ..., d_k) of degree parameters, corresponding to k-fold tensor products of rooted divisors. The multi-degree defect satisfies:

    δ_{(d₁,...,d_k)}(G, q, S₁, ..., S_k) = Σᵢ dᵢ · β₁(G[Sᵢ]) + correction terms

where the correction terms depend on the intersection pattern of the subsets Sᵢ.

**Test:** For k = 2 and small graphs, compute rank of divisors d₁·D_{S₁} + d₂·D_{S₂} and compare to the multi-degree prediction. Test whether the correction terms involve β₁ of intersections S₁ ∩ S₂.

**Impact:** This would create a graph-theoretic analogue of **higher-rank vector bundles**, where the degree parameter is a vector rather than a scalar. The multi-degree Hilbert polynomial would encode richer topological information (intersection Betti numbers) and connect to K-theory of graphs.

**Catalog References:**
- `Pythagorean/TropicalBridge/HigherDefectTheory.lean` — single-degree defect spectrum
- `Pythagorean/TropicalBridge/Defs.lean` — rooted subset divisor definition

**Proof Strategy:** Start with k = 2 and subsets S₁, S₂ that are disjoint (simplest case). Show that the defects add: δ_{(d₁,d₂)} = d₁·β₁(G[S₁]) + d₂·β₁(G[S₂]) + κ_joint − 1. Then handle overlapping subsets via inclusion-exclusion on Betti numbers.

**Domain Bridges:** Vector bundles, K-theory, multi-graded Hilbert series, intersection theory

**Lineage:** Lifts the scalar spectrum to a multi-parameter family.

**Ambition:** 🔴 Grand challenge — would open a new subfield of discrete higher-rank theory.

---

## Direction 4: Tropical Moduli and Piecewise-Linearity

**Conjecture:** The defect spectrum, viewed as a function on the moduli space of rooted graphs (parameterized by edge weights), is piecewise linear in the weights. The chambers of linearity correspond to combinatorial types of q-reduced divisors, and the walls correspond to chip-firing transitions.

**Test:** For a fixed graph topology (e.g., cycle C₅), vary edge weights continuously and track the defect. Identify whether the defect changes at specific threshold weights, creating a tropical hypersurface.

**Impact:** Would connect the defect spectrum to **tropical moduli spaces** and the theory of tropical linear series. The piecewise-linear structure would give the defect a tropical geometric interpretation as a section of a tropical line bundle on the moduli space.

**Catalog References:**
- `Pythagorean/TropicalBridge/HigherDefectTheory.lean` — exact affinity (Theorem 4.7)
- `Pythagorean/TropicalBridge/Defs.lean` — graph Laplacian

**Proof Strategy:** Extend the graph model to weighted graphs. Show that the induced Betti number β₁ is constant under weight variation (topological invariance), making the defect spectrum weight-independent for fixed topology. For varying topology (edge collapses), analyze the tropical degeneration.

**Domain Bridges:** Tropical geometry, Berkovich spaces, combinatorial moduli, min-plus algebra

**Lineage:** Connects the affinity theorem to tropical geometric structure.

**Ambition:** 🔴 Grand challenge — requires developing weighted-graph defect theory from scratch.

---

## Direction 5: Spectral Fingerprinting for Graph Classification

**Conjecture:** The defect spectrum pair (slope, intercept) = (β₁, κ−1) provides a linear-time computable graph invariant that distinguishes more graph pairs than the degree sequence alone. Specifically, for random graphs G(n, p) with p near the connectivity threshold, the (β₁, κ) distribution over all (q, S) pairs is a high-entropy fingerprint.

**Test:** Generate 1000 random connected graphs on 10 vertices. For each, compute the multiset of (β₁, κ) values over all (q, S) pairs. Measure collision rates and compare to collision rates of degree sequence and other standard invariants.

**Impact:** Would provide a practical, fast graph invariant for database indexing, graph similarity, and isomorphism pre-filtering. The defect fingerprint captures both cycle complexity and fragmentation structure in a single pair of numbers.

**Catalog References:**
- `Pythagorean/TropicalBridge/HigherDefectTheory.lean` — computeHigherDefect (verified algorithm)
- `Pythagorean/TropicalBridge/DefectTheory.lean` — inducedCycleRank, rootComponentCount

**Proof Strategy:** Implement the fingerprinting algorithm in Python. Benchmark against the Weisfeiler–Leman graph invariant and the degree sequence. Prove (or disprove) that the full (q, S)-multiset of defect spectra is a complete invariant for trees.

**Domain Bridges:** Graph isomorphism, database indexing, network science, machine learning on graphs

**Lineage:** Applications of the verified algorithm from HigherDefectTheory.lean.

**Ambition:** 🟢 Immediately testable — computational infrastructure already exists.
