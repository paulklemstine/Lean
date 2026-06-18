# Future Directions: Self-Avoiding Walk Research

## Synthesis

This cycle formalized the foundational theory of self-avoiding walks on ℤ² and the hexagonal lattice, establishing the submultiplicativity of SAW counts, the existence of the connective constant via Fekete's lemma, and the algebraic properties of the Nienhuis constant √(2+√2). The most significant cross-domain connection is between combinatorial path-counting (submultiplicativity), real analysis (Fekete's lemma for subadditive sequences), and algebraic number theory (the minimal polynomial of the hexagonal connective constant).

The highest breakthrough potential lies in Direction 1: formalizing discrete holomorphicity on planar graphs, which would open the door not just to the Duminil-Copin–Smirnov theorem but to the entire field of discrete complex analysis and its applications to statistical mechanics. The bridge decomposition (Direction 3) offers a more tractable intermediate step that could yield new rigorous bounds on the square lattice connective constant. The connection to tropical geometry (Direction 5) is speculative but could link SAW theory to the existing Catalog's tropical algebra infrastructure.

---

### Direction 1: Discrete Holomorphicity and the Parafermionic Observable

**Conjecture**: The parafermionic observable F(z) = Σ_{ω: a→z} x_c^{|ω|} e^{-iσθ(ω)} with σ = 5/8 and x_c = 1/√(2+√2) satisfies discrete Cauchy-Riemann equations on the medial lattice of the hexagonal lattice.

**Test**: Formalize the medial lattice of the hexagonal lattice, define F(z) as a sum over walks, and verify the discrete Cauchy-Riemann equations for small domains (say, a 3×3 hexagonal patch) computationally in Lean via `native_decide` or `#eval`. If the equations hold for small patches, proceed to the general proof.

**Impact**: This would be the first step toward a complete formalization of the Duminil-Copin–Smirnov theorem, one of the landmark results in mathematical physics of the 21st century. It would also provide infrastructure for formalizing other results in discrete complex analysis.

**Catalog References**: `Computation/SelfAvoidingWalk/Basic.lean` (hexagonal lattice definitions, HexAdj, HexWalk)

**Proof Strategy**: (1) Define the medial lattice of the hexagonal lattice. Each edge of the hexagonal lattice corresponds to a vertex of the medial lattice. (2) Define the discrete derivative operators ∂_s and ∂̄_s on the medial lattice. (3) Define the parafermionic observable F as a formal sum. (4) Prove that local cancellations in the sum yield the discrete CR equations. The key identity is that for each interior vertex of the medial lattice, the three terms contributing to ∂̄F cancel due to the specific choice of σ = 5/8.

**Domain Bridges**: Complex Analysis <-> Combinatorics <-> Statistical Mechanics

**Lineage**: Builds on HexAdj, HexWalk, nienhuis_algebraic_identity from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Connective Constant Bounds for ℤ²

**Conjecture**: The connective constant μ of the square lattice ℤ² satisfies 2.625 < μ < 2.680, provable using only elementary combinatorial arguments (no analysis or physics).

**Test**: Prove a_lower ≤ c_n for all n ≤ N using explicit constructions (e.g., spiral walks, L-shaped walks), and c_n ≤ a_upper using the tree-like structure of SAWs. Specifically, try to prove c_n ≤ 4 · 3^{n-1} (upper bound from excluded neighbors) and c_n ≥ 2^n (walks along two axes and their reflections) in Lean.

**Impact**: Rigorous, computer-verified bounds on μ(ℤ²) would be a concrete contribution to the open problem. Even crude bounds, if formally verified, have value because they are machine-checked.

**Catalog References**: `Computation/SelfAvoidingWalk/Basic.lean` (sawCount, sawCount_submultiplicative, one_le_sawCount)

**Proof Strategy**: (1) Upper bound: Prove c_n ≤ 4 · 3^{n-1} by induction—at each step after the first, the walker has at most 3 choices (cannot return). This requires showing that for n ≥ 1, each SAW of length n extends to at most 3 SAWs of length n+1 at each step. (2) Lower bound: Construct explicit families of walks—e.g., "staircase" walks alternating between x and y directions, giving c_n ≥ 2^{⌊n/2⌋}. (3) Improved bounds using the Hammersley-Welsh method with bridges.

**Domain Bridges**: Combinatorics <-> Number Theory (growth rates) <-> Analysis (Fekete's lemma)

**Lineage**: Direct extension of sawCount_submultiplicative, walk_coord_bound' from this cycle.

**Ambition**: extension

---

### Direction 3: Bridge Decomposition and Renewal Theory

**Conjecture**: The bridge generating function b(x) = Σ b_n x^n satisfies the identity χ(x) = b(x) / (1 - b(x))² where χ(x) = Σ c_n x^n is the SAW generating function, and this identity can be formalized in Lean using formal power series.

**Test**: Verify the identity numerically for n ≤ 12 by computing bridge counts and SAW counts. Then formalize the renewal equation in Lean using `PowerSeries` from Mathlib.

**Impact**: The bridge decomposition is the standard tool for converting between SAW bounds and bridge bounds. Formalizing it would provide machinery for systematic improvement of connective constant bounds.

**Catalog References**: `Computation/SelfAvoidingWalk/Basic.lean` (Bridge, bridgeCount), `Algebra/Advanced.lean` (algebraic structures)

**Proof Strategy**: (1) Formalize the bridge decomposition theorem: every SAW decomposes uniquely into a sequence of bridges. (2) This gives the generating function identity c_n = Σ_{k≥1} Σ_{n₁+...+n_k=n} b_{n₁} · ... · b_{n_k} for walks that can be decomposed into k bridges. (3) In generating function language: χ(x) = Σ_{k≥1} b(x)^k = b(x)/(1-b(x)) (for one-directional bridges). The full identity accounts for the 2D structure. (4) Use Mathlib's `PowerSeries` for formal manipulation.

**Domain Bridges**: Combinatorics <-> Formal Power Series <-> Renewal Theory

**Lineage**: Builds on Bridge structure from this cycle.

**Ambition**: extension

---

### Direction 4: High-Dimensional SAW and Mean-Field Behavior (Hara-Slade)

**Conjecture**: For self-avoiding walks on ℤ^d with d ≥ 5, the connective constant satisfies μ(ℤ^d) = 2d - 1 - 1/(2d) - O(1/d²), and the critical exponents take their mean-field values γ = 1, ν = 1/2.

**Test**: Formalize SAW on ℤ^d (generalizing from ℤ²), define the lace expansion, and prove the first-order asymptotic μ ≈ 2d-1 for large d. For a concrete test: prove c_1(ℤ^d) = 2d and c_2(ℤ^d) = 2d(2d-1).

**Impact**: The Hara-Slade theorem (1992) is the foundational result establishing mean-field behavior for SAW in high dimensions. Formalizing it would connect the SAW theory to the broader landscape of mean-field critical behavior.

**Catalog References**: `Computation/SelfAvoidingWalk/Basic.lean` (LatticeWalk generalization needed)

**Proof Strategy**: (1) Generalize LatticeWalk to ℤ^d by replacing ℤ × ℤ with ℤ^d (using `Fin d → ℤ`). (2) Define the lace expansion: express c_n as a perturbative series around the simple random walk. (3) For d ≥ 5, show the lace expansion converges, giving precise asymptotics. (4) The first step (μ ≈ 2d-1) follows from elementary counting.

**Domain Bridges**: Combinatorics <-> Analysis (perturbation theory) <-> Probability (random walks)

**Lineage**: Generalizes the ℤ² formalization from this cycle to arbitrary dimension.

**Ambition**: grand_challenge

---

### Direction 5: Tropical Self-Avoiding Walks

**Conjecture**: There exists a meaningful "tropical SAW count" defined over the tropical semiring (ℝ ∪ {∞}, min, +) that encodes extremal properties of self-avoiding paths, and the tropical connective constant equals the logarithm of the classical connective constant: μ_trop = log(μ).

**Test**: Define a tropical weight on SAW paths (e.g., the minimum total displacement or energy), compute the tropical generating function for small n, and check whether the tropical connective constant equals log(2.638...) ≈ 0.970.

**Impact**: This would create a novel bridge between tropical geometry (well-developed in the Catalog) and SAW theory. If the tropical formulation simplifies certain aspects of SAW theory, it could provide new proof techniques for bounding μ.

**Catalog References**: `Tropical/` (tropical algebra infrastructure), `Computation/SelfAvoidingWalk/Basic.lean`

**Proof Strategy**: (1) Define the tropical SAW weight as the min-plus analogue of the counting function: instead of counting walks, take the minimum over all walks of some cost function. (2) Show this satisfies a tropical analogue of submultiplicativity. (3) Prove tropical Fekete's lemma (min-plus subadditivity implies limit existence). (4) Relate the tropical and classical connective constants via the Maslov dequantization: as ℏ → 0, the log of the classical partition function approaches the tropical one.

**Domain Bridges**: Tropical Algebra <-> Combinatorics <-> Statistical Mechanics

**Lineage**: Connects to existing Catalog tropical infrastructure.

**Ambition**: extension
