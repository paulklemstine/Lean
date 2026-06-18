# Future Directions: Machine-Verified Monotone Circuit Complexity

## Synthesis

The five directions below form a coherent research program that extends the machine-verified monotone lower-bound framework in three dimensions: **depth** (sharper bounds via entropy), **breadth** (new functions and computational models), and **connections** (bridges to proof complexity, learning theory, and non-monotone barriers). Each direction builds on the verified theorems in this project—the approximation sandwich engine, the KW transport theorem, and the compression barriers—and proposes concrete, testable hypotheses. The unifying theme is that **information-theoretic structure determines computational complexity**, and that this determination can be made *formal* and *automatic*.

---

## Direction 1: Entropy-Tight Monotone KW Barrier

**Conjecture:** For monotone graph properties `f_n` with symmetric witness distributions (e.g., CLIQUE, MATCHING, CONNECTIVITY), the monotone KW communication complexity is asymptotically lower bounded by the Shannon entropy of the witness relation:

$$CC_{\text{mono}}(f_n) \geq \Omega(H(\text{KW witnesses of } f_n))$$

up to universal constants.

**Test:**
- Enumerate KW witnesses for small n (n ≤ 6) for CLIQUE, MATCHING, and CONNECTIVITY.
- Compute Shannon entropy of the witness distribution over distinguishing coordinates.
- Compare empirical transcript lengths of heuristic KW protocols against the entropy lower bound.
- If the gap is consistently small (< 2× for all tested functions), the conjecture gains evidence.
- If any function shows a large gap, investigate whether the distribution is far from uniform.

**Impact:** If true, this establishes Shannon entropy as a *native complexity measure* for monotone computation, enabling automated lower bounds from distributional data alone.

**Catalog References:**
- `Computation/CircuitComplexity/Monotone/ApproximationMethod.lean` → `kw_log_entropy_lower_bound`
- `Catalog/FINAL/Computation/Entropy.lean` → `source_coding_lower_bound`
- `Catalog/FINAL/Computation/BarrierFramework.lean` → `kw_witness_compression_lower_bound`

**Proof Strategy:** Use `source_coding_lower_bound` to convert witness distributions into expected code length bounds, then connect to KW protocol transcripts via the formula-to-protocol correspondence (`monotone_formula_protocol_cost_le_depth`).

**Domain Bridges:** Information theory ↔ Communication complexity ↔ Circuit complexity

**Lineage:** Extends Karchmer-Wigderson (1988) and Shannon (1948); builds on the cross-domain bridge theorems in our formalization.

**Ambition:** ★★★★☆ — Would establish a new paradigm for proving monotone lower bounds through entropy computation.

---

## Direction 2: Approximation-Sandwich Universality

**Conjecture:** Every known monotone circuit lower bound for a natural graph property can be refactored through a certified `ApproximationSandwich`. Specifically, for every monotone function `f` with a known super-polynomial monotone circuit lower bound, there exists an approximation sandwich `(P, N)` of polynomial size such that every circuit of size ≤ s fails on some test point.

**Test:**
- Implement search procedures for candidate positive/negative test families for:
  - 3-CLIQUE on 5-8 vertices
  - Perfect MATCHING on 6-8 vertices  
  - s-t CONNECTIVITY on 5-7 vertices
- For each function, enumerate all monotone circuits of size ≤ s (for small s ≤ 10).
- Verify that for each small circuit, at least one test instance exposes an error.
- If successful for all three functions, the conjecture is supported.

**Impact:** Would prove that the approximation sandwich is a *complete* method for monotone lower bounds, not just a sufficient one.

**Catalog References:**
- `Computation/CircuitComplexity/Monotone/ApproximationMethod.lean` → `approximation_sandwich_lower_bound`
- `Computation/CircuitComplexity/Monotone/CliqueLowerBound.lean` → `clique_monotone_size_lower_bound_of_approximation`

**Proof Strategy:** For each function, construct the sandwich explicitly using random test families and verify the approximation property computationally. Then formalize the construction for small cases.

**Domain Bridges:** Combinatorics ↔ Circuit complexity ↔ Proof theory (sandwich certificates as proofs)

**Lineage:** Directly extends Razborov (1985); would resolve an open question about the scope of the approximation method.

**Ambition:** ★★★★★ — Grand challenge. Completeness of the approximation method is a major open question.

---

## Direction 3: Compression Obstruction Predicts Formula Depth Better Than Raw KW Size

**Conjecture:** For small n, the best lower bounds on monotone formula depth come from witness incompressibility (via `kw_witness_compression_lower_bound`) rather than from direct KW protocol analysis. Specifically, for n ≤ 8 and threshold, clique, and connectivity functions, the compression-based depth bound is within a factor of 2 of the true optimal depth.

**Test:**
- For each function and small n:
  1. Enumerate the full KW witness space and compute `d_comp = ⌈log₂ |W|⌉`.
  2. Find the optimal monotone formula depth `d_opt` by exhaustive search over small formulas.
  3. Compare `d_comp` to `d_opt`.
- If `d_comp ≥ d_opt / 2` for all tested functions, the compression bound is "good."
- If `d_comp < d_opt / 3` for some function, the compression approach needs strengthening.

**Impact:** Would establish compression/entropy methods as the primary tool for monotone depth lower bounds, simplifying the proof methodology.

**Catalog References:**
- `Computation/CircuitComplexity/Monotone/ApproximationMethod.lean` → `kw_compression_implies_depth_lower_bound`, `monotone_formula_depth_ge_of_witness_incompressibility`
- `Catalog/FINAL/Computation/Compression.lean` → `no_injective_compression`, `incompressible_strings_lower_bound`

**Proof Strategy:** The key formal step is strengthening `kw_witness_compression_lower_bound` to use entropy rather than raw cardinality, via `source_coding_lower_bound`.

**Domain Bridges:** Compression theory ↔ Circuit complexity ↔ Formula complexity

**Lineage:** Extends the compression-to-depth chain in our formalization; connects to Kolmogorov complexity approaches.

**Ambition:** ★★★☆☆ — Solid extension with clear computational tests.

---

## Direction 4: Monotone Span Programs and the Approximation Method

**Conjecture:** The approximation sandwich framework extends to monotone span programs (MSPs), yielding lower bounds on MSP size. Specifically, define an `ApproximationSandwich` for the span program model and prove an analogue of `approximation_sandwich_lower_bound` for MSP size.

**Test:**
- Define `MonotoneSpanProfile` analogous to `MonotoneCircuitProfile` but with a linear-algebraic evaluation function.
- Implement span program evaluation for small instances.
- Construct approximation sandwiches for CLIQUE and test against small span programs.
- If sandwiches defeat all span programs of size ≤ s for some meaningful s, the framework transfers.

**Impact:** Would extend machine-verified lower bounds to a strictly more powerful model than monotone circuits, with implications for secret sharing and proof complexity.

**Catalog References:**
- `Computation/CircuitComplexity/Monotone/ApproximationMethod.lean` → `MonotoneCircuitProfile`, `ApproximationSandwich`, `approximation_sandwich_lower_bound`

**Proof Strategy:** The abstract theorem `approximation_sandwich_lower_bound` already works for any `MonotoneCircuitProfile`. The key is defining span program evaluation as a `MonotoneCircuitProfile` instance.

**Domain Bridges:** Linear algebra ↔ Circuit complexity ↔ Cryptography (secret sharing schemes)

**Lineage:** Extends Karchmer-Wigderson to span programs (Babai-Gál-Wigderson, 1999).

**Ambition:** ★★★★☆ — Would be the first formalized span program lower bound.

---

## Direction 5: Natural Proofs Barrier Interaction

**Conjecture:** The approximation sandwich method, when applied to pseudo-random functions, yields sandwiches that are computationally hard to certify. Specifically, if f is a pseudo-random function, then any approximation sandwich that defeats circuits of size s must have |pos ∪ neg| ≥ s^ω(1).

**Test:**
- For small n, construct approximation sandwiches for pseudo-random-like functions (e.g., functions with high circuit complexity but simple algebraic structure).
- Measure the minimum |pos ∪ neg| needed to defeat all circuits of size s.
- If this grows faster than polynomially in s, the natural proofs barrier is operative.
- Compare against non-pseudo-random functions (e.g., CLIQUE) where polynomial-size sandwiches suffice.

**Impact:** Would formalize the interaction between Razborov-Rudich natural proofs and the approximation method, clarifying which lower-bound techniques survive the barrier.

**Catalog References:**
- `Computation/CircuitComplexity/Monotone/ApproximationMethod.lean` → `approximation_sandwich_lower_bound`
- `Catalog/FINAL/Computation/BarrierFramework.lean` → `natural_proof_distinguisher`, `no_relativizing_equivalence`

**Proof Strategy:** Use the existing natural proofs skeleton to formalize the connection. The key insight is that the approximation sandwich *is* a natural proof in the Razborov-Rudich sense: it's large (applies to many functions) and useful (defeats small circuits).

**Domain Bridges:** Circuit complexity ↔ Cryptography ↔ Proof complexity

**Lineage:** Connects Razborov (1985) with Razborov-Rudich (1997); would be the first formal analysis of their interaction.

**Ambition:** ★★★★★ — Grand challenge connecting two of the deepest results in complexity theory.
