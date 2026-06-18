## Assignment: Computational Validation as Theorem Discovery — from Python Experiments to Certified Arithmetic Structure

Mode: **prove**

You are not being asked to “use the Python demo framework” as a convenience script. You are being asked to turn computation into a mathematically disciplined discovery engine: formulate conjectures from experiments, then extract certified theorems in Lean 4 that reveal hidden structure across arithmetic, information-theoretic feasibility, and dynamical contraction. The breakthrough is not a one-off lemma. The breakthrough is a reusable pattern: **computationally generated conjectures whose proof architecture is formalized and transported across domains**.

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Research Direction
Use the Python demo framework to generate arithmetic and discrete-structural conjectures, then formalize the strongest surviving statements in Lean 4. The first target should be a theorem that converts computational evidence about factor pairs into a certified rigidity principle. The second target should connect this arithmetic structure to one of the bridge theorems already in the catalog, so that “experiment → invariant → proof” becomes a genuine cross-domain methodology rather than isolated numerology.

### Mathematical Framing
The catalog already contains a seed of arithmetic structure:

- `smaller_factor_sqrt_bound` gives the classical but foundational principle that in a factorization `N = p*q` with `p ≤ q`, the smaller factor is bounded by `√N`.
- `iterate_contraction_bound` suggests a general paradigm of repeated refinement under contraction.
- `feasibleChannelSet_bounded` encodes a bounded feasible region principle from rate-distortion/information geometry.
- `krull_height_key_dimension_bound` hints that algebraic complexity is controlled by dimension-like invariants.

The visionary move is to fuse these into a single theme:

> **Computational conjecture validation should produce certified bounded search theorems and uniqueness/rigidity theorems, which then serve as the arithmetic analogue of compact feasible regions and contraction-driven convergence.**

In plain terms: if Python finds a pattern in divisors, gcds, or recurrence data, Lean should prove that the search space is intrinsically bounded and that the observed extremal structure is mathematically forced.

---

## Primary Theorem Target A: Canonical Small Factor from a Nontrivial Divisor

Prove a clean arithmetic theorem that upgrades `smaller_factor_sqrt_bound` from a statement about an already-given factor pair to a theorem of computational consequence: any discovered nontrivial divisor yields a canonical bounded complementary factor.

### Precise theorem statement
For every natural number `N ≥ 2`, every nontrivial divisor `p` of `N` determines a complementary factor `q = N / p`, and one of the two factors is bounded by `Nat.sqrt N`.

A strong formal target is:

```lean
theorem exists_factor_le_sqrt_of_dvd
    (N p : ℕ)
    (hN : 2 ≤ N)
    (hp1 : 2 ≤ p)
    (hpdvd : p ∣ N) :
    ∃ q : ℕ, N = p * q ∧ 1 ≤ q ∧ (p ≤ q → p ≤ Nat.sqrt N) ∧ (q ≤ p → q ≤ Nat.sqrt N)
```

An even sharper and more computationally useful corollary target is:

```lean
theorem exists_small_factor_of_composite
    (N : ℕ)
    (hN : 2 ≤ N)
    (hcomp : ¬ Nat.Prime N) :
    ∃ d : ℕ, 2 ≤ d ∧ d ∣ N ∧ d ≤ Nat.sqrt N
```

This is not merely elementary. In the context of computational validation, it is the theorem that certifies **finite bounded search** for compositeness witnesses. It converts experimentation into a proof-relevant search principle.

### Why this is a breakthrough
Because it establishes a formal bridge between:
- brute-force computational search,
- certified search-space reduction,
- and proof extraction.

This is the seed of a general theorem-discovery architecture: observed witnesses can be normalized into bounded canonical witnesses. That idea scales far beyond divisors.

### Lean 4 proof architecture
Build explicitly on `smaller_factor_sqrt_bound`.

Likely auxiliary lemmas:
```lean
theorem dvd_gives_quotient_factorization
    (N p : ℕ) (hpdvd : p ∣ N) :
    ∃ q, N = p * q := by
  ...
```

```lean
theorem composite_has_nontrivial_divisor
    (N : ℕ) (hN : 2 ≤ N) (hcomp : ¬ Nat.Prime N) :
    ∃ d, 2 ≤ d ∧ d ∣ N ∧ d < N := by
  ...
```

Then use quotient factorization plus ordering on the pair `(p,q)`.

### Proof strategies
**Strategy A: direct factor-pair normalization**
1. From `p ∣ N`, obtain `q` with `N = p*q`.
2. Compare `p` and `q`.
3. Apply `smaller_factor_sqrt_bound` to the ordered pair, swapping roles if necessary.

This is the most promising strategy because it directly leverages the catalog theorem with minimal new machinery.

**Strategy B: minimal divisor argument**
1. Let `d` be the least divisor of `N` greater than `1`.
2. Show `d ≤ N / d`, else `N < d*d` contradicts minimality/compositeness structure.
3. Conclude `d ≤ Nat.sqrt N`.

This is conceptually elegant and closer to computational practice, where one searches for the first witness. It is more powerful if you want future primality-search theorems.

**Strategy C: contradiction via square bound**
1. Assume both factors exceed `Nat.sqrt N`.
2. Derive `N < p*q = N` using monotonicity properties of `Nat.sqrt`.
3. Contradiction.

This may require more delicate arithmetic lemmas around `Nat.sqrt`, but it yields a very reusable pattern for later bounded-search arguments.

---

## Secondary Theorem Target B: Certified Finite Search for Composite Detection

Turn the previous theorem into a theorem about algorithmic validation. This is where the Python framework becomes mathematically meaningful.

### Precise theorem statement
If `N` is composite and at least `2`, then searching divisors only up to `Nat.sqrt N` is complete.

```lean
theorem composite_iff_exists_divisor_le_sqrt
    (N : ℕ) (hN : 2 ≤ N) :
    (¬ Nat.Prime N) ↔ ∃ d : ℕ, 2 ≤ d ∧ d ≤ Nat.sqrt N ∧ d ∣ N
```

You may need to adjust the left side to exclude `1` and handle the standard definition of primality carefully; a robust variant is:

```lean
theorem not_prime_iff_exists_dvd_le_sqrt
    (N : ℕ) (hN : 2 ≤ N) :
    (¬ Nat.Prime N) ↔ ∃ d : ℕ, 2 ≤ d ∧ d < N ∧ d ∣ N ∧ d ≤ Nat.sqrt N
```

### Why this matters
This theorem is the certified arithmetic analogue of `feasibleChannelSet_bounded`: a potentially infinite-looking search is reduced to a bounded feasible set. It is also the arithmetic analogue of `iterate_contraction_bound`: repeated testing converges because the search domain is intrinsically finite and sharply controlled.

This opens a new direction: **formal complexity-aware theorem proving**, where computational experiments are justified by exact boundedness theorems before any implementation claim is trusted.

### Proof strategies
**Strategy A: derive from Target A**
1. Prove the forward direction using `exists_small_factor_of_composite`.
2. Prove the reverse direction from the existence of a proper nontrivial divisor.
3. Package as an iff theorem for direct use in future demos.

Most promising because it modularizes the work and creates a reusable theorem stack.

**Strategy B: prove both directions via factorization theory**
1. Expand `Nat.Prime`.
2. Handle the witness and non-witness cases explicitly.
3. Use `smaller_factor_sqrt_bound` only in the forward direction.

This is lower-level but may align better with available Mathlib lemmas on `Nat.Prime`.

---

## Cross-Domain Bridge Target C: Bounded Feasibility as a Universal Discovery Principle

Do not stop at arithmetic. Prove a theorem whose statement explicitly mirrors the boundedness theorem from information theory.

### Conceptual theorem
A computational search problem with witness-monotonicity and a size bound admits certified truncation to a finite search region.

You can instantiate this in arithmetic first using divisibility, but formulate the pattern abstractly enough to later reuse it in finite rate-distortion and contraction systems.

A concrete finite-set arithmetic instantiation:

```lean
theorem composite_detection_complete_on_Icc
    (N : ℕ) (hN : 2 ≤ N) :
    (¬ Nat.Prime N) ↔
      ∃ d ∈ Finset.Icc 2 (Nat.sqrt N), d ∣ N
```

This theorem is computationally actionable: it says Python experiments only need to scan `Finset.Icc 2 (Nat.sqrt N)`.

### Why this is revolutionary
Because it identifies a common skeleton behind:
- divisor search in arithmetic,
- bounded feasible regions in information theory,
- and convergence regions in iterative dynamics.

That common skeleton is: **global property ↔ witness in a certified finite region**.

This can become a new formal research program: theorem discovery by bounded witness extraction.

### Cross-domain connections
1. **Information theory**  
   `feasibleChannelSet_bounded` already says a structural set is bounded. Your arithmetic theorem says the witness set for compositeness is bounded. This suggests a unifying notion of **formal feasibility truncation**.

2. **Dynamical systems / fixed-point iteration**  
   `iterate_contraction_bound` controls long-term behavior by contraction. In arithmetic, `Nat.sqrt N` plays the role of a one-step contraction of the search universe from `[2, N-1]` to `[2, √N]`.

3. **Algebraic geometry / invariant complexity**  
   `krull_height_key_dimension_bound` signals that complexity can be governed by dimension/height. Here, search complexity is governed by a “dimension-one” square-root boundary. This is the computational shadow of a more general invariant-boundedness philosophy.

4. **Formal methods / certified computation**  
   Python proposes candidates; Lean proves that the candidate region is complete. This is a prototype of trustworthy conjecture pipelines.

### Application keywords
certified search, bounded witness extraction, computational number theory, formal verification, theorem discovery pipeline, proof-relevant experimentation, finite feasibility, arithmetic complexity, compositeness certification, Lean-Python integration

---

## Optional Higher-Risk Theorem Target D: GCD/Fibonacci Bridge if momentum permits

The assignment mentions `Fib_gcd_identity` as a priority target. If the relevant file contains sorrys, attack it. If not, prove a clean bounded-search analogue for gcd-recursive structure.

A strong target:

```lean
theorem gcd_of_factor_pair
    (N p q : ℕ)
    (hN : N = p * q) :
    Nat.gcd p q ∣ N
```

Then escalate toward Fibonacci if infrastructure exists:

```lean
theorem fib_gcd_dvd_fib_gcd_indices
    (m n : ℕ) :
    Nat.fib (Nat.gcd m n) ∣ Nat.gcd (Nat.fib m) (Nat.fib n)
```

This would be a powerful cross-domain bridge between recurrence computation and arithmetic witness extraction. But only pursue this if the divisor-search program is stabilized first.

---

## Concrete implementation plan

### Step 1: Use Python as conjecture generator, not oracle
Write or adapt a `demo.py` that:
- enumerates composite numbers `N`,
- finds the least divisor `d`,
- checks empirically that `d ≤ isqrt(N)`,
- records patterns for complementary factors,
- optionally compares search lengths before and after square-root truncation.

The point is to expose candidate lemmas, edge cases, and best formal statements.

### Step 2: Formalize the arithmetic kernel in Lean
Create a file focused on certified bounded divisor search. Candidate theorem stack:
1. `dvd_gives_quotient_factorization`
2. `exists_small_factor_of_composite`
3. `composite_iff_exists_divisor_le_sqrt`
4. `composite_detection_complete_on_Icc`

### Step 3: Build the bridge theorem
Add a short section or theorem commentary connecting your bounded search theorem to:
- `feasibleChannelSet_bounded`
- `iterate_contraction_bound`

Even if the final bridge is conceptual rather than fully abstract, make the analogy explicit in comments or in `ARTICLE.md`.

---

## If sorry_fill opportunities exist
Priority targets mentioned in the assignment:
- `CarmichaelComposite`
- `Fib_gcd_identity`

If these are actual sorrys in the repository, inspect the exact file path and theorem statement first. If one is close to completion, fill it. But do not let this derail the larger program: the main mission is to establish a computational-validation theorem pipeline, not merely patch a local hole.

---

## Deliverables
Required:
- Lean 4 proofs of the strongest theorem(s) above
- `FUTURE_DIRECTIONS.md`

Optional but highly encouraged:
- `demo.py` showing conjecture generation and witness search
- `ARTICLE.md` explaining the bounded-witness paradigm
- `diagram.svg` showing the analogy:
  `global property → bounded witness region → finite certified search`

---

## FUTURE_DIRECTIONS.md requirements
This is critical. Include 3–5 specific next steps with exact theorem statements, proof strategies, and cross-domain significance. At least three of the following should appear:

1. **Abstract bounded-witness schema**
   Formalize a typeclass or theorem pattern saying that a global predicate is equivalent to existence of a witness in a bounded finite set.

2. **Least-witness correctness theorem**
   Prove that the least divisor found by a search procedure is prime, or satisfies a stronger minimality invariant.

3. **Certified complexity upper bound**
   Formalize that divisor search up to `Nat.sqrt N` uses at most `Nat.sqrt N - 1` tests, connecting arithmetic proof to resource-bounded verification.

4. **Bridge to finite feasibility**
   Generalize from divisor search to finite feasible sets modeled by `Finset`, inspired by `feasibleChannelSet_bounded`.

5. **Recurrence-search analogue**
   Develop a Fibonacci/Lucas or linear recurrence theorem where computationally observed gcd/divisibility behavior is reduced to a bounded canonical witness.

Be bold: the real result is not “a theorem about divisors.” The real result is a new formal science of **certified computational conjecture validation**.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Speculative
Research mode: prove
