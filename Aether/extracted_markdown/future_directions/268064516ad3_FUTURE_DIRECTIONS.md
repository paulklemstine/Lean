# Future Directions: Automatic Sequences and Kernel Orbit Theory

## Synthesis

This cycle established the Kernel Orbit as a novel mathematical structure unifying three perspectives on automatic sequences: automata theory (DFAOs), algebraic kernel theory, and dynamical systems. The key technical achievement was a complete formal proof of the digit decomposition lemma for LSF representations, which enabled the kernel finiteness theorem with an explicit |Q|² bound. This bound raises an immediate question: is it tight, or does deeper structure force the kernel to be smaller?

The most promising cross-domain connection is to the existing `finite_memory_is_lossy` result in the Computation catalog, which establishes that finite-state systems necessarily forget information. Our kernel finiteness theorem is the *positive* counterpart: it shows exactly *what* finite-state systems can remember — the entire structure of the sequence is captured by finitely many kernel elements. This duality (lossy memory ↔ finite kernel) could be made precise via a categorical framework connecting the two results.

The highest breakthrough potential lies in extending the kernel orbit approach to morphic sequences. If the morphic kernel can be shown to be effectively finite (even if not uniformly bounded), the decidability of the zero-in-sequence problem for morphic sequences would follow — settling a long-standing open question in combinatorics on words.

---

### Direction 1: Tight Kernel Bounds via State Minimization

**Conjecture**: For a minimal DFAO (all states reachable, no two states output-equivalent) over base k with |Q| states, the k-kernel size equals exactly |Q| when the DFAO reads digits MSF, and at most |Q| · min(|Γ|, |Q|) when reading LSF.

**Test**: Enumerate all minimal DFAOs with ≤ 6 states over alphabet {0, 1} for k = 2. For each, compute the exact kernel size (via the kernel computation algorithm with sufficiently large depth). Compare with |Q| and |Q|². If the bound |Q| always holds for MSF-DFAOs, this strongly supports the conjecture. If a counterexample is found for LSF with kernel size > |Q|, characterize when the extra factor is needed.

**Impact**: If true, this gives the optimal bound on kernel size and reveals a fundamental asymmetry between MSF and LSF representations. If false, the counterexample would expose new structure in how digit reading order affects the kernel.

**Catalog References**: `Novelty/AutoSeq/KernelTheory.lean` (dfao_kernel_finite), `Computation/InfoEfficientAlgorithms.lean` (BSState, information efficiency)

**Proof Strategy**: (1) For MSF, show that each kernel element determines a unique reachable state. This requires proving the MSF digit decomposition: digits_MSF(k^e·n+r) = digits_MSF(n) ++ padded(r, e). (2) For LSF, characterize when two kernel elements with different q₀-values but same q_{e,r}-values can agree.

**Domain Bridges**: Computation (information theory) ↔ Novelty (automatic sequences): the kernel bound is an information-theoretic statement about the compression achievable by finite-state transducers.

**Lineage**: Extends dfao_kernel_finite and the |Q|² bound from this cycle.

**Ambition**: extension

---

### Direction 2: Decidability for Morphic Sequences

**Conjecture**: The zero-in-sequence problem for morphic sequences is decidable. Specifically: given a morphism σ on a finite alphabet A, a coding τ : A → Γ, and a target c ∈ Γ, it is decidable whether c appears in the sequence τ(σ^ω(a)) for any starting letter a.

**Test**: Formalize the morphic kernel (analogous to the k-kernel but using the morphism's iteration structure) and prove it is effectively finite. Then implement the decidability algorithm and test on 50 morphic sequences including: (a) the Fibonacci word, (b) the period-doubling sequence, (c) the Chacon sequence, (d) arbitrarily constructed non-automatic morphic sequences. Any failure case would disprove the conjecture.

**Impact**: This would settle one of the major open problems in combinatorics on words. The morphic-to-automatic reduction (via Cobham's theorem) provides a potential pathway, but the general case is much harder because morphic sequences can have infinite k-kernel for every k.

**Catalog References**: `Novelty/AutoSeq/KernelTheory.lean` (kernel orbit, kernel step closure), `Computation/GravityOracle.lean` (decidability hierarchies)

**Proof Strategy**: (1) Define the morphic kernel using the substitution structure rather than base-k decimation. (2) Show that the morphic kernel, while potentially infinite, is *effectively enumerable* with a decidable equality test. (3) Prove that the value-at-0 function on the morphic kernel has finite image. (4) Combine to get decidability via a bounded search.

**Domain Bridges**: Novelty (automatic sequences) ↔ Logic (decidability theory): the morphic case is the boundary between decidable and undecidable sequence problems.

**Lineage**: Extends the decidability results and kernel orbit structure from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Christol's Theorem via Kernel Orbits

**Conjecture**: The Kernel Orbit provides a constructive proof of Christol's theorem: a formal power series f(x) = Σ aₙ xⁿ over 𝔽_p is algebraic over 𝔽_p(x) if and only if the sequence (aₙ) is p-automatic. Moreover, the degree of the minimal polynomial of f(x) equals the size of the p-kernel of (aₙ).

**Test**: (1) Formalize 𝔽_p-valued DFAOs and their connection to formal power series. (2) Prove that the kernel orbit of a p-automatic sequence over 𝔽_p encodes the coefficients of the minimal polynomial. (3) Verify computationally for p = 2, 3, 5 and all automatic sequences with ≤ 4 states.

**Impact**: Christol's theorem is one of the deepest results in automatic sequence theory. A kernel-orbit proof would be more constructive than the standard algebraic proof and would directly compute the minimal polynomial from the DFAO.

**Catalog References**: `Novelty/AutoSeq/Closure.lean` (isKAutomatic_pointwise — closure under field operations), `FINAL/MachineLearning/UltrametricKLDivergence.lean` (power_series_partial_sum_bound — p-adic power series)

**Proof Strategy**: (1) Show that the kernel step operation on formal power series corresponds to the Cartier operator on 𝔽_p[[x]]. (2) Use the kernel orbit to construct the minimal polynomial: the orbit's transition matrix encodes the coefficients. (3) Prove that the minimal polynomial has degree ≤ |kernel| using the Cayley-Hamilton theorem on the transition matrix.

**Domain Bridges**: Novelty (automatic sequences) ↔ Algebra (algebraic number theory over finite fields) ↔ MachineLearning (p-adic analysis)

**Lineage**: Extends the kernel orbit structure and the closure under pointwise operations from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Kernel Orbit Graph Invariants

**Conjecture**: The diameter of the kernel orbit graph of a k-automatic sequence equals ⌈log_k(period)⌉ for eventually periodic sequences and equals the "complexity exponent" (a new invariant we define) for non-periodic sequences. The chromatic number of the undirected kernel orbit graph is at most k for k ≥ 2.

**Test**: Compute kernel orbit graphs for all 2-automatic sequences with ≤ 5 states. Measure diameter, chromatic number, and cycle structure. Test whether diameter correlates with known complexity measures (subword complexity, factor complexity).

**Impact**: If the diameter conjecture holds, it provides a new way to measure the "complexity" of automatic sequences that is both algebraically meaningful (via the kernel) and computationally efficient (graph diameter is polynomial-time computable). The chromatic number bound would reveal hidden structure in how kernel elements can be "colored" by their digit-transition relationships.

**Catalog References**: `Novelty/AutoSeq/KernelTheory.lean` (KernelOrbit structure), `Bridges/TropicalFeedback.lean` (graph-theoretic methods in algebraic settings)

**Proof Strategy**: (1) Define the complexity exponent as the maximum depth in the kernel orbit tree. (2) For eventually periodic sequences, show the period determines the depth via the pumping lemma. (3) For the chromatic number, show that kernel elements reached by different digits from the same parent never conflict.

**Domain Bridges**: Novelty (kernel orbits) ↔ Bridges (tropical graph theory): the kernel orbit is a finite graph with algebraic structure, naturally connecting to tropical methods.

**Lineage**: Extends the KernelOrbit structure from this cycle.

**Ambition**: extension

---

### Direction 5: Automatic Sequences and Symbolic Dynamics

**Conjecture**: The shift orbit closure of a k-automatic sequence (viewed as a symbolic dynamical system) has topological entropy 0, and the Kernel Orbit is isomorphic (as a directed graph) to the syntactic monoid of the subshift's language.

**Test**: (1) Compute the subword complexity function p(n) for 10 automatic sequences and verify it grows at most linearly (entropy 0). (2) Compute the syntactic monoid of the subshift language and compare with the kernel orbit graph.

**Impact**: This would establish a deep connection between automatic sequence theory and symbolic dynamics, providing a bridge between two major areas of mathematics that have developed largely independently.

**Catalog References**: `Novelty/AutoSeq/KernelTheory.lean` (kernel orbit), `Shared/CellularAutomata.lean` (dynamical systems on symbolic spaces)

**Proof Strategy**: (1) Linear subword complexity follows from the kernel finiteness: the number of distinct factors of length n grows with the kernel size. (2) The syntactic monoid isomorphism follows from showing that two words are syntactically equivalent iff they induce the same kernel element transition.

**Domain Bridges**: Novelty (automatic sequences) ↔ Shared (cellular automata / symbolic dynamics): automatic sequences are 1D symbolic dynamical systems with finite-state structure.

**Lineage**: Extends the kernel orbit structure and closure properties from this cycle.

**Ambition**: extension
