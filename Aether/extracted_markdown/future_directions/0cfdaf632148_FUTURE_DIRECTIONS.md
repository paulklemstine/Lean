# Future Directions: Certified Sandwich Families

## Synthesis

The certified sandwich family framework established in this work opens a network of interconnected research directions spanning circuit complexity, combinatorics, proof theory, and computational learning. The central theme is *compositionality*: the framework's explicit certificate structure enables operations (union, refinement, pullback) that the classical approximation method does not support. Each direction below builds on verified theorems from the Catalog, extends the theory in a testable way, and connects to at least one adjacent mathematical domain.

The five directions form a progression:
1. **Composition** (the core open problem — enables modular lower bounds)
2. **Minimum certificates** (optimize the framework's output)
3. **Sunflower extraction** (connect to classical combinatorics)
4. **Depth-bounded certificates** (extend beyond size to depth)
5. **Certificate learning** (automate the construction)

---

## Direction 1: Sandwich Composition Theorem

**Conjecture**: If $f : \{0,1\}^n \to \{0,1\}$ has a complete sandwich family $\mathcal{S}_f$ with bound $s_1$ and $g : \{0,1\}^m \to \{0,1\}$ has $\mathcal{S}_g$ with bound $s_2$, then the block composition $f \diamond g$ (where each variable of $f$ is replaced by a copy of $g$) has a complete sandwich family with bound $\Omega(s_1 \cdot s_2 / \max(n, m))$.

**Test**: Compute sandwich families for OR₂ and AND₂. Form the composition OR₂(AND₂, AND₂). Enumerate all monotone functions on 4 variables (Dedekind number D(4) = 168). Verify whether the product bound $s_1 \cdot s_2 / 2$ holds for every non-computing function. Repeat for OR₃ ∘ AND₂ (D(6) ≈ 7581 — computationally intensive but feasible).

**Impact**: Would provide the first *modular* approach to monotone circuit lower bounds. Currently, every lower bound must be proved monolithically. A composition theorem would allow building lower bounds for complex functions from lower bounds for simple components, analogous to how NP-hardness reductions compose.

**Catalog References**:
- `Pythagorean/RazborovSandwich.lean` — `sandwichUnion_complete`, `sandwich_composition_conjecture`
- `Catalog/FINAL/Computation/ApproximationMethod.lean` — `approximation_sandwich_lower_bound`

**Proof Strategy**: The key difficulty is constructing witnesses for $f \diamond g$ from witnesses for $f$ and $g$. Strategy A: For each positive witness $x$ of $\mathcal{S}_f$, substitute the positive witnesses of $\mathcal{S}_g$ into the "active" coordinates and negative witnesses into the "inactive" coordinates. Strategy B: Use the KW-game interpretation: a protocol for $f \diamond g$ decomposes into a protocol for $f$ interleaved with protocols for $g$.

**Domain Bridges**: Circuit complexity → Game theory (KW games) → Communication complexity

**Lineage**: Extends `sandwichUnion_complete` from union (trivial composition) to block composition (non-trivial).

**Ambition**: Grand challenge — would transform the field if proven, but the natural proofs barrier (Razborov-Rudich) suggests the bound cannot be too tight.

---

## Direction 2: Minimum Certificate Problem

**Conjecture**: The problem of finding the minimum-size complete sandwich family for a given monotone function $f$ and bound $s$ is NP-hard (as a function of the domain size), but admits an $O(\log n)$-approximation via greedy set cover.

**Test**: For all 20 monotone functions on 3 variables, compute the exact minimum sandwich family size by brute force. Compare with the greedy algorithm output. Measure the approximation ratio. For $n = 4$ (168 functions), run the greedy algorithm and spot-check against exact solutions for a random sample.

**Impact**: Understanding the complexity of certificate construction separates the "how hard is the lower bound" question from "how hard is finding the proof." If minimum certificates are NP-hard to find, this explains why lower bound proofs are difficult — even when certificates exist.

**Catalog References**:
- `Pythagorean/RazborovSandwich.lean` — `sandwich_complete_iff_no_small_circuit`, `witness_count_le_domain_size`

**Proof Strategy**: Reduction from Set Cover. The universe is the set of non-computing circuits; each potential witness defines a set of circuits it refutes. Finding the minimum sandwich family is finding the minimum set cover. The $O(\log n)$ bound follows from the standard greedy analysis.

**Domain Bridges**: Circuit complexity → Computational complexity → Approximation algorithms

**Lineage**: Builds on `witness_count_le_domain_size` (upper bound) and asks for tight lower bounds.

**Ambition**: Solid extension — connects two well-studied areas with a concrete reduction.

---

## Direction 3: Sunflower-Based Certificate Extraction

**Conjecture**: For any monotone function $f$ with minterms of size $\le k$, if the family of minterms is $(r, k)$-sunflower-free, then there exists a complete sandwich family with at most $(r-1)^k \cdot k!$ positive witnesses and at most $(r-1)^k \cdot k!$ negative witnesses, achieving bound $s = 2^{\Omega(k)}$.

**Test**: Enumerate all monotone functions on 4 variables whose minterms have size $\le 2$. For each, extract the minterm family, check sunflower-freeness for $r = 3$, and verify whether the Erdős-Rado bound $(r-1)^k \cdot k!$ correctly predicts the witness count. The sunflower-free condition can be checked by brute force for small families.

**Impact**: Would make the sunflower-sandwich connection (currently stated as a definition in our formalization) into a fully proved bridge theorem. This connects the Erdős-Rado sunflower lemma — a fundamental result in extremal combinatorics — directly to circuit lower bound certificates.

**Catalog References**:
- `Pythagorean/RazborovSandwich.lean` — `IsSunflower`, `sunflower_erdos_rado_bound`
- `Catalog/FINAL/Computation/ApproximationMethod.lean` — `ApproximationSandwich`

**Proof Strategy**: The key step is formalizing the Erdős-Rado sunflower lemma in Lean. The lemma is provable by induction on $k$ with a pigeonhole argument. Once formalized, the connection to sandwich families follows by interpreting minterms as positive witnesses and maxterm complements as negative witnesses.

**Domain Bridges**: Extremal combinatorics → Circuit complexity → Formal verification

**Lineage**: Extends the sunflower connection from definition (`IsSunflower`) to theorem.

**Ambition**: Solid extension — the sunflower lemma is well-understood but not yet in Mathlib.

---

## Direction 4: Depth-Bounded Sandwich Families

**Conjecture**: There exists a "depth-aware" sandwich family framework where witnesses are annotated with the minimum depth of any circuit they refute. For the connectivity function on $n$-vertex graphs, this yields a $\Omega(\log^2 n)$ depth lower bound matching Karchmer-Wigderson.

**Test**: For $n = 4$ (6 edges), enumerate all monotone circuits of depth $\le 2$ on 6 variables. For each, check which witnesses refute it. Annotate the sandwich family with depth information and verify that the depth-aware completeness condition holds.

**Impact**: Would extend the sandwich family framework from *size* lower bounds to *depth* lower bounds. The Karchmer-Wigderson theorem already establishes a connection between depth and communication complexity; depth-bounded sandwich families would make this connection certificate-based.

**Catalog References**:
- `Pythagorean/RazborovSandwich.lean` — `CertifiedSandwichFamily`, `MonoCircuit`
- `Catalog/FINAL/Computation/ApproximationMethod.lean` — `MonoFormula`, `monotone_formula_protocol_cost_le_depth`

**Proof Strategy**: Define `DepthBoundedSandwichFamily` with an additional field `depth_bound`. The completeness condition becomes: every circuit of size $\le s$ AND depth $\le d$ is hit. Prove that formula-to-protocol conversion (already in the Catalog) yields depth-bounded witnesses.

**Domain Bridges**: Circuit complexity → Communication complexity → Protocol trees

**Lineage**: Extends `CertifiedSandwichFamily` with a depth dimension, building on `KWProto` in the Catalog.

**Ambition**: Grand challenge — depth lower bounds are harder than size lower bounds, but the KW infrastructure already exists.

---

## Direction 5: Certificate Learning via SAT/SMT

**Conjecture**: For monotone functions on $n \le 10$ variables, a SAT solver can find complete sandwich families of near-optimal size in polynomial time (in the encoding size), despite the NP-hardness of the general problem.

**Test**: Encode the minimum sandwich family problem as a SAT instance: Boolean variables for witness membership, clauses for completeness (every non-computing circuit is hit). Run a modern SAT solver (e.g., CaDiCaL) on instances with $n = 4, 5$. Compare solving time and certificate size with the greedy algorithm.

**Impact**: Would provide an *automated* pipeline: (1) specify a function, (2) run SAT solver, (3) obtain a certified lower bound. This bypasses the need for mathematical insight in constructing witnesses. If practical for moderate $n$, it could discover new lower bounds that humans have missed.

**Catalog References**:
- `Pythagorean/RazborovSandwich.lean` — `sandwich_complete_iff_no_small_circuit`

**Proof Strategy**: No formal proof needed — this is a computational/engineering direction. The theoretical guarantee is that the SAT encoding is correct (follows from `sandwich_complete_iff_no_small_circuit`), and any solution returned by the solver is a valid certificate.

**Domain Bridges**: Circuit complexity → SAT solving → Automated reasoning

**Lineage**: Operationalizes `sandwich_complete_iff_no_small_circuit` as a computational tool.

**Ambition**: Solid extension — SAT solvers are powerful on structured instances, and the encoding is natural.
