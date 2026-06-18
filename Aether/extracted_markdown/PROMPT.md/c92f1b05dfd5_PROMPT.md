## Assignment: Automated Lemma Discovery via Communication Bottleneck Detection — An Information-Theoretic Foundation for Proof Search

**Mode:** discover + formalize

### The Grand Vision

Every automated theorem prover wastes computational resources searching through exponentially large proof spaces. This project establishes that **communication complexity provides an information-theoretic lower bound on proof search difficulty**, and more critically, that **the communication bottleneck itself reveals where lemmas must be invented**. This transforms proof search from blind enumeration into a principled, bottleneck-guided process — the foundation of a new class of "communication-aware" theorem provers.

### Precise Theorem Statements with Lean 4 Signatures

**Definition 1 — Identity Family and Coefficient Table:**
```lean
/-- A parameterized family of algebraic identities over a commutative ring,
    together with the dimension of its coefficient table (the number of
    monomials whose coefficients must be verified). -/
structure IdentityFamily (R : Type*) [CommRing R] where
  num_params : ℕ
  lhs : (Fin num_params → R) → Polynomial R
  rhs : (Fin num_params → R) → Polynomial R
  coeff_dim : ℕ
  valid : ∀ p, lhs p = rhs p
  coeff_dim_spec : ∀ p, (lhs p - rhs p).support.card ≤ coeff_dim
```

**Definition 2 — Communication Bottleneck (the key novel structure):**
```lean
/-- The communication bottleneck of an identity family under a bipartition
    of its parameters. The `matrix_rank` is the rank of the coefficient
    matrix when rows correspond to Alice's parameter settings and columns
    to Bob's. By the log-rank inequality, CC ≥ log(matrix_rank). -/
structure CommBottleneck (R : Type*) [Field R] where
  family : IdentityFamily R
  partition : Fin family.num_params ⊕ Fin family.num_params
  coeff_matrix : Matrix (Fin (2 ^ (partition.foldl ...))) 
                         (Fin (2 ^ (partition.foldr ...))) R
  matrix_rank : ℕ
  rank_spec : matrix_rank = coeff_matrix.rank
```

**Theorem 1 — Bottleneck Lower Bound (connecting communication complexity to proof difficulty):**
```lean
/-- For any identity family with coefficient table dimension d(n) and
    bipartition yielding matrix rank r, the deterministic communication
    complexity of structure-blind verification is at least log r.
    This is the log-rank inequality applied to proof verification. -/
theorem comm_lower_bound_of_rank {R : Type*} [Field R]
    (b : CommBottleneck R) :
    log₂ b.matrix_rank ≤ communicationComplexity b.coeff_matrix :=
  by
    -- Apply the log-rank inequality from communication complexity
    sorry
```

**Theorem 2 — Lemma Compression Reduces Communication (the core structural result):**
```lean
/-- If a lemma factorizes the coefficient table of dimension d into
    a product of tables of dimensions d₁ and d₂ (with d₁ * d₂ = d),
    then the communication cost with the lemma is O(log d₁ + log d₂),
    achieving a compression ratio of log d / (log d₁ + log d₂). -/
theorem lemma_compression_ratio {R : Type*} [Field R]
    (f : IdentityFamily R) (d₁ d₂ : ℕ)
    (h_factor : f.coeff_dim = d₁ * d₂)
    (h_lemma : HasFactorizationLemma f d₁ d₂) :
    (log₂ f.coeff_dim : ℝ) / (log₂ d₁ + log₂ d₂) ≥ 1 ∧
    (∃ lemma_cost, lemma_cost ≤ log₂ d₁ + log₂ d₂ ∧
     lemma_cost < log₂ f.coeff_dim) :=
  by
    sorry
```

**Theorem 3 — Powerset Family Has Exponential Bottleneck (connecting to catalog):**
```lean
/-- The powerset expansion identity ∏_{i∈S}(1+x_i) = Σ_{T⊆S} ∏_{i∈T} x_i
    has coefficient table dimension 2^n and matrix rank 2^{n/2} under
    balanced partition, giving communication complexity Ω(2^{n/2}).
    The inductive lemma reduces this to O(n). -/
theorem powerset_exponential_bottleneck {R : Type*} [Field R]
    (n : ℕ) (hn : 0 < n) :
    let d := 2^n
    let r := 2^(n/2)
    log₂ (r : ℝ) ≤ communicationComplexity (powersetCoeffMatrix n (R := R)) ∧
    (log₂ (d : ℝ)) / (n : ℝ) ≥ (2^(n-1) : ℝ) / n :=
  by
    sorry
```

**Theorem 4 — Cross-Domain: Bottleneck Detection Yields Kolmogorov Complexity Bound**
```lean
/-- The communication bottleneck provides a lower bound on the
    Kolmogorov complexity of any proof of the identity: any proof
    must contain at least log₂(rank) bits of information about
    the bipartition. This connects communication complexity to
    algorithmic information theory. -/
theorem bottleneck_bounds_kolmogorov {R : Type*} [Field R]
    (b : CommBottleneck R) (proof : Proof b.family) :
    (proof.kolmogorovComplexity : ℝ) ≥ log₂ (b.matrix_rank : ℝ) :=
  by
    sorry
```

### Proof Strategies

**Strategy A — Direct Linear Algebra (most promising for Theorems 1-3):**
1. Formalize the coefficient matrix construction: given an identity family and bipartition `(A, B)` of parameters, the entry `M[a,b]` is the coefficient of the monomial determined by `(a,b)` in the identity.
2. For the powerset family, compute the rank of `M` explicitly — this is a Vandermonde-type matrix with full rank `2^{n/2}`.
3. Apply the log-rank inequality (Nisan-Wigderson): `D^cc(f) ≥ log₂(rank(M))`.
4. Show that the inductive factorization lemma decomposes `M` into a Kronecker product of `n` matrices of rank 2, giving communication cost `O(n)`.
*Why promising:* The linear algebra is concrete and computable; the powerset family is the canonical example where everything works cleanly.

**Strategy B — Information-Theoretic via Mutual Information:**
1. Define the mutual information `I(A; B | identity_holds)` between the two parties' views.
2. Show that `I(A; B) ≥ log₂(rank(M))` by the data processing inequality applied to the verification protocol.
3. Any proof must convey at least `I(A; B)` bits of information across the bipartition.
4. A lemma reduces mutual information by creating a "sufficient statistic" that summarizes what one party needs to tell the other.
*Why promising:* This connects to the `HasAsymptoticGap` catalog concept naturally and generalizes beyond algebraic identities.

**Strategy C — Combinatorial via Rectangle Covers (classical CC approach):**
1. A deterministic communication protocol partitions the input space into monochromatic rectangles.
2. The number of rectangles needed equals the communication cost.
3. Show that for the powerset family, any rectangle cover of the `0`-region (identity fails) requires `2^{n/2}` rectangles.
4. A lemma corresponds to a structured rectangle decomposition — the inductive lemma gives `n` rectangles of size `2^{n/2}` each.
*Why promising:* Most direct connection to classical communication complexity; allows use of existing results on rectangle covers.

### Cross-Domain Connections

1. **Communication Complexity ↔ Proof Theory**: The log-rank inequality becomes a *proof difficulty lower bound*. This is the first formal connection between Yao's communication model and the complexity of proof search.

2. **Algebraic Combinatorics ↔ Information Theory**: Coefficient tables of identity families are combinatorial objects (e.g., Pascal's triangle for binomial identities). Their rank under bipartition is an information-theoretic property — the *capacity* of the identity to hide information from structure-blind verifiers.

3. **Algorithmic Information Theory ↔ Automated Reasoning**: Theorem 4 connects Kolmogorov complexity to proof compression. A lemma is "useful" precisely when it reduces the Kolmogorov complexity of the proof — and the communication bottleneck quantifies *how much* reduction is possible.

4. **Tropical Geometry ↔ Communication Bottlenecks** (speculative but high-impact): Tropical rank and Kapranov rank of a matrix control its communication complexity. A "tropical bottleneck detector" could work over idempotent semirings, connecting to `Catalog/MachineLearning/ProofCompression/Defs.lean`'s `CompressionInstance` via tropicalization of the coefficient matrix.

### Building on Catalog Theorems

- From `gap_of_linear_vs_exponential`: The existing gap theorem shows linear vs. exponential cost for the powerset family. **Extend this**: prove that the gap *equals* the communication bottleneck, i.e., `gap = log₂(rank) - O(n)`.
- From `subsetExpansion_unbounded_gap`: The unbounded gap for subset expansion is a *consequence* of the `2^{n/2}` rank lower bound. Formalize this implication.
- From `CompressionInstance` and `HasAsymptoticGap`: Define `CommBottleneckCompression` extending `CompressionInstance` with the rank field and prove `HasAsymptoticGap` follows from the rank being exponential.

### Conjecture with Testable Prediction

**Conjecture (Bottleneck-Guided Lemma Completeness):** For any identity family over `ℚ` with coefficient table of rank `r` under balanced bipartition, there exists a lemma of Kolmogorov complexity `O(log r)` that reduces the verification communication cost to `O(log² r)`.

**Computational Test:**
1. Implement `bottleneck_detector(identity) → (rank, suggested_lemma_type)` in Python.
2. Apply to 5 catalog identity families: powerset, Vandermonde, Cauchy-Schwarz expansion, Newton's identities, cyclotomic factorization.
3. For each, verify: (a) the detector's rank output matches manually computed rank, (b) the suggested lemma type matches the known optimal lemma.
4. **Refutation**: If any family has optimal lemma of complexity `ω(log r)`, or if communication cost with best lemma is `ω(log² r)`, the conjecture is false.

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 5 testable hypotheses:
   - H1: The rank of the coefficient matrix for the Vandermonde identity under balanced partition is `2^{n/2}` (test: compute rank for n=4,6,8).
   - H2: For any identity with polynomial coefficient table dimension, the communication bottleneck is polynomial (test: catalog families with polynomial growth).
   - H3: The tropical rank of the coefficient matrix equals the classical rank for fields of characteristic zero (test: compute both ranks for n≤6).
   - H4: Lemma invention guided by bottleneck detection finds optimal lemmas in ≤3 attempts for identities with ≤8 parameters (test: benchmark on catalog families).
   - H5: The communication bottleneck is invariant under automorphisms of the parameter group (test: permute parameters, verify rank unchanged).

(b) **RESEARCH_PAPER.md**: Standalone paper titled "Communication Bottlenecks as Information-Theoretic Guides for Automated Lemma Discovery" with full proofs of Theorems 1-4, the bottleneck detection algorithm, experimental validation, and comparison with existing proof search heuristics.

(c) **ARTICLE.md**: "How Information Theory Could Revolutionize Automated Theorem Proving" — explain how Alice and Bob trying to verify an identity over a phone line reveals where proofs need lemmas, using the binomial theorem as running example.

(d) **Verified Algorithm**: A `bottleneckDetector` function that, given an identity family and parameter count, computes the coefficient matrix rank under balanced partition and returns the communication lower bound with a certificate.

(e) **demo.py**: Interactive demonstration showing (1) the exponential bottleneck for the powerset family, (2) how the inductive lemma compresses it, (3) bottleneck detection on 3-5 identity families with visualization of the rank vs. parameter count curve, and (4) a proof search simulation comparing bottleneck-guided vs. blind search.

### Depth Requirements Checklist

- ✅ No trivial proofs (all theorems require rank computation, log-rank inequality, or induction on family structure)
- ✅ 3+ theorems with deep tactics (Theorem 1: by_contra on rank assumption; Theorem 3: induction on n with matrix rank computation; Theorem 4: calc chain from Kolmogorov to communication)
- ✅ Novel definitions (`CommBottleneck`, `LemmaCompression`, `bottleneckDetector`)
- ✅ Cross-domain connections (CC ↔ proof theory, algebraic combinatorics ↔ information theory, tropical geometry ↔ bottlenecks)
- ✅ Falsifiable conjecture with computational test

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
