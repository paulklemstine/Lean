## Assignment: Tropical Quadratic Sieve as Min-Plus Dynamic Programming — Formal Core, Corrected Scope, and a Bridge to Idempotent Complexity

Mode: prove

The original vision — “subexponential factoring by tropical min-plus matrix multiplication” — is too optimistic if interpreted as a proof of a new unconditional factoring algorithm. Do **not** spend cycles trying to prove a false complexity breakthrough from idempotent algebra alone. Instead, isolate the mathematically real breakthrough:

> **Formalize the quadratic sieve relation-collection step as a min-plus / tropical dynamic program, prove exact correctness of the smoothness-cost computation, and derive a certified complexity equivalence between the tropical sieve kernel and the classical valuation-based sieve kernel.**

If done cleanly, this opens a new field: **idempotent algorithmics for arithmetic complexity**, where factorization, subset-sum, decoding, and lattice sieving are recast as tropical convolutions and shortest-path computations. The payoff is not merely “another QS formalization.” The payoff is a reusable theorem schema saying:

- smoothness detection is a tropical optimization problem,
- valuation aggregation is min-plus linear algebra,
- arithmetic sieving admits certification in idempotent semirings,
- and complexity transfer theorems can move bounds from classical arithmetic to tropical kernels.

This is the kind of bridge that could seed **tropical analytic number theory**, **idempotent cryptanalysis**, and **formal complexity transport theorems**.

### Immediate correction of scope
Do **not** claim:
- an unconditional new subexponential factoring algorithm from tropical matrix multiplication alone,
- or that min-plus algebra bypasses the linear algebra / relation-dependence bottleneck of classical QS.

Do prove:
1. an **exact equivalence theorem** between a tropical smoothness-cost functional and classical prime-exponent accounting for B-smooth integers,
2. a **tropical convolution theorem** for combining valuation profiles,
3. a **kernel complexity transport theorem** showing the tropical sieve step has the same asymptotic work bound as the already-verified classical/tropical kernel abstraction.

This is still bold: it converts a famous arithmetic algorithm into certified tropical semantics.

## Precise theorem targets

Work with concrete finite prime bases and `Nat`-valued costs first. Only tropicalize to `ℝ∞`, `WithTop ℕ`, or a dedicated min-plus type after the combinatorial theorem is stable.

### Core definitions to introduce
You will likely need definitions along these lines:

- `primeBasis : Finset ℕ`
- `valuationVec : Finset ℕ → ℕ → (ℕ →₀ ℕ)` or a simpler finitely supported encoding
- `smoothCost : Finset ℕ → ℕ → WithTop ℕ`
- `tropicalCombine : WithTop ℕ → WithTop ℕ → WithTop ℕ` using min as addition and ordinary addition as multiplication in min-plus semantics
- `qsKernelInput : ℕ → ℕ → Finset ℤ` for values of `x^2 - N` over a sieving interval
- `primeLogWeight : ℕ → ℕ` or `ℝ` for approximate sieve scoring if you pursue a weighted version

The right first breakthrough is **exact**, not heuristic: count prime exponents, not floating log approximations.

## Theorem 1: Tropical smoothness cost detects B-smoothness exactly

Let `P` be a finite set of primes. Define the tropical cost of `n` relative to `P` by summing the residual exponent cost of prime factors outside `P`, with `∞` if `n = 0` or if sign conventions are mishandled. Then prove:

> `smoothCost P n = 0` if and only if every prime divisor of `n` lies in `P`.

A Lean-oriented signature could look like:

```lean
theorem smoothCost_eq_zero_iff_primeFactors_subset
    (P : Finset ℕ) (n : ℕ) :
    smoothCost P n = 0 ↔
      n ≠ 0 ∧ Nat.primeFactors n ⊆ P
```

If `Nat.primeFactors` is inconvenient, use the divisor formulation:

```lean
theorem smoothCost_eq_zero_iff_BSmooth
    (P : Finset ℕ) (n : ℕ) :
    smoothCost P n = 0 ↔
      n ≠ 0 ∧ ∀ p : ℕ, Nat.Prime p → p ∣ n → p ∈ P
```

This is the conceptual heart. It says tropical cost zero is **exactly** smoothness, not an analogy.

### Why this is a breakthrough
Because it reframes smoothness — a central concept in factoring algorithms — as a zero-energy condition in an idempotent optimization landscape. Once certified, this gives a language for transporting sieve arguments into tropical geometry and dynamic programming.

## Theorem 2: Tropical convolution computes optimal factor support decomposition

Define a cost function `cP : ℕ → WithTop ℕ` measuring residual non-`P` mass. Then define tropical convolution

```lean
def tropConv (f g : ℕ → WithTop ℕ) (n : ℕ) : WithTop ℕ :=
  ⨅ k in Finset.range (n+1), (f k + g (n-k))
```

or, more arithmetically relevant, a divisor convolution:

```lean
def divisorTropConv (f g : ℕ → WithTop ℕ) (n : ℕ) : WithTop ℕ :=
  Finset.inf' (Nat.divisors n) ?h (fun d => f d + g (n / d))
```

Then prove the exact arithmetic additivity theorem:

```lean
theorem smoothCost_mul
    (P : Finset ℕ) (a b : ℕ) :
    smoothCost P (a * b) = smoothCost P a + smoothCost P b
```

or, if zero/overflow issues require a cleaner version:

```lean
theorem smoothCost_mul_of_pos
    (P : Finset ℕ) {a b : ℕ}
    (ha : a ≠ 0) (hb : b ≠ 0) :
    smoothCost P (a * b) = smoothCost P a + smoothCost P b
```

This is the theorem that justifies calling the sieve step a tropical convolution: multiplicative structure in arithmetic becomes additive structure in min-plus cost.

### Stronger matrix form
If you can package candidate relations as rows and prime exponents as columns, prove a min-plus matrix theorem:

```lean
theorem tropical_relation_matrix_mul_correct
    (A B : Matrix (Fin m) (Fin n) (WithTop ℕ)) :
    tropicalMatMul A B = fun i k => ⨅ j, (A i j + B j k)
```

Then instantiate it with valuation/cost matrices arising from QS candidates. This is less number-theoretic but may connect better to existing matrix APIs.

## Theorem 3: Complexity transport for the tropical sieve kernel

You already have:

- `tropical_sieve_kernel_work_bound : theorem tropical_sieve_kernel_work_bound (R B : ℕ) : ...`

Build a theorem that says the exact smoothness computation via your tropical encoding is bounded by the same kernel work model. Something like:

```lean
theorem qs_tropical_relation_collection_work_bound
    (R B : ℕ) :
    relationCollectionWork R B ≤ C * tropicalSieveKernelWork R B
```

or more concretely, if the existing theorem already provides the asymptotic estimate:

```lean
theorem qs_tropical_kernel_matches_classical_bound
    (R B : ℕ) :
    tropicalRelationKernelWork R B = classicalRelationKernelWork R B
```

If exact equality is too rigid, prove sandwich bounds:

```lean
theorem qs_tropical_kernel_work_bound
    (R B : ℕ) :
    tropicalRelationKernelWork R B ≤ polylogFactor R B * classicalRelationKernelWork R B
```

But the strongest realistic target is:

> **the tropical reformulation of the relation-collection kernel preserves the asymptotic work bound already certified for the sieve kernel.**

This is how you truthfully connect to “matching classical QS complexity.”

## Theorem 4: Tropical score monotonicity under enlargement of factor base

A beautiful and useful theorem:

```lean
theorem smoothCost_mono_factorBase
    {P Q : Finset ℕ} (hPQ : P ⊆ Q) (n : ℕ) :
    smoothCost Q n ≤ smoothCost P n
```

And in zero-detection form:

```lean
theorem BSmooth_monotone
    {P Q : Finset ℕ} (hPQ : P ⊆ Q) {n : ℕ}
    (hn : smoothCost P n = 0) :
    smoothCost Q n = 0
```

This is mathematically simple but strategically powerful: it gives a monotonicity principle needed for certified adaptive factor-base enlargement, which is highly relevant to actual QS heuristics.

## Most promising proof architecture

### Strategy A: Prime-valuation exactness via `padicValNat` / factorization
This is the most promising route.

1. Define `smoothCost P n` as the finite sum over prime divisors `p` of `n` with `p ∉ P` of `v_p(n)`.
2. Prove `smoothCost P n = 0` iff no prime divisor outside `P` occurs.
3. Use valuation additivity under multiplication to prove `smoothCost_mul`.

Why this is best:
- It is exact, discrete, and avoids analytic/log approximations.
- Mathlib already supports prime divisibility and factorization machinery more robustly than bespoke tropical real-valued constructions.
- It yields the cleanest correctness theorem.

### Strategy B: Finitely supported exponent vectors as tropical states
Represent each `n` by its exponent vector over primes as a finitely supported function, then define cost by projection outside the factor base.

1. Build `expVec : ℕ → (ℕ →₀ ℕ)`.
2. Show `expVec (ab) = expVec a + expVec b`.
3. Define `smoothCost` as the support-weight outside `P`, and derive exactness.

Why this is elegant:
- It turns arithmetic into linear algebra over `ℕ`.
- It is the right setup for later min-plus matrix theorems.
- It may be easier to compose with `Matrix` and `Finset` APIs than direct factorization lemmas.

Risk:
- More infrastructure overhead in Lean.

### Strategy C: Weighted tropical sieve score using logarithms
This is closest to the classical quadratic sieve heuristic, but should be secondary.

1. Define a score for `n` by subtracting `log p` contributions for `p ∈ P`.
2. Prove upper/lower bounds relating this score to exact smoothness cost.
3. Derive a certified “candidate relation” theorem.

Why it matters:
- It connects formal exact arithmetic with practical QS sieve scoring.
- It is the bridge to analytic number theory and algorithm engineering.

Risk:
- Real logs, rounding, and inequalities create proof friction.
- It is heuristic-adjacent; do this only after the exact theorem is established.

## How to use the catalog theorems

1. `tropical_sieve_kernel_work_bound`
   - This is your anchor for complexity transport.
   - Do not merely cite it; define your relation-collection kernel so that its primitive operations reduce to the kernel counted there.
   - Then prove a refinement theorem: your exact smoothness-cost evaluator is implemented within that bound.

2. `tropical_plus_distributes_over_min`
   - Use this when proving algebraic simplification lemmas for min-plus expressions.
   - In particular, if you define tropical matrix multiplication or convolution over `ℝ`/`WithTop ℕ`, this theorem can certify reassociation/distribution patterns in the dynamic-programming recurrence.

3. `tropical_add_idempotent`
   - Use this to collapse duplicate candidate paths in min-plus DP.
   - This is conceptually important: repeated sightings of the same relation do not improve the minimal cost, which mirrors sieve deduplication.

4. `idempotent_semiring_with_inverses_trivial`
   - This is a warning beacon.
   - It tells you not to force group-like inverses into your tropical semiring formalization.
   - Keep the tropical side semiring/ordered-semiring based, and keep multiplicative inverses on the arithmetic side only.

## Cross-domain connections to make explicit

### 1. Tropical geometry ↔ analytic number theory
B-smoothness becomes a tropical vanishing condition. The factor base defines a tropical hyperplane arrangement in exponent space, and smooth numbers are exactly those whose exponent vectors lie in the coordinate subcone supported on the base. This suggests a future “tropical distribution of smooth numbers” program.

### 2. Shortest paths / dynamic programming ↔ factorization
Your `smoothCost` is an energy functional. Relation collection becomes a shortest-path / min-cost decomposition problem. This makes factoring kernels comparable to Viterbi decoding, weighted automata, and min-plus control theory.

### 3. Cryptography ↔ idempotent semiring complexity
The same formal machinery could classify when cryptanalytic preprocessing steps are fundamentally valuation-aggregation problems. This could seed tropical formulations of NFS filtering, lattice sieving, or syndrome decoding.

### 4. Formal methods ↔ computational number theory
A verified bridge theorem saying “classical sieve accounting = tropical cost semantics” is exactly the kind of artifact that can support future certified cryptanalytic tooling.

## Application keywords
tropical geometry, min-plus algebra, quadratic sieve, B-smooth numbers, valuation theory, idempotent semirings, dynamic programming, shortest paths, cryptanalysis, formalized complexity, arithmetic circuits, divisor convolution, certified algorithms

## Concrete Lean targets

Aim to produce one file centered on exact arithmetic semantics, for example:

- `Cryptography/TropicalQuadraticSieveExact.lean`

with theorem names in this spirit:

```lean
theorem smoothCost_eq_zero_iff_BSmooth ...
theorem smoothCost_mul_of_pos ...
theorem smoothCost_mono_factorBase ...
theorem divisorTropConv_correct ...
theorem qs_tropical_kernel_matches_classical_bound ...
```

If you discover an existing `TropZ` or tropical semiring abstraction is awkward, do not force it. Prove the arithmetic theorem first over `WithTop ℕ` or `ℕ`, then add an interpretation morphism into the tropical structure.

## Suggested execution order

1. Define `smoothCost` over `Nat`.
2. Prove `smoothCost_eq_zero_iff_BSmooth`.
3. Prove `smoothCost_mono_factorBase`.
4. Prove `smoothCost_mul_of_pos`.
5. Package multiplication as divisor tropical convolution.
6. Connect the implementation cost to `tropical_sieve_kernel_work_bound`.
7. Only then consider weighted/logarithmic sieve scores.

## What would make this paradigm-shifting
Not “we tropicalized the quadratic sieve” as rhetoric, but rather:

- a certified equivalence between smoothness and tropical zero-energy,
- a reusable theorem schema for multiplicative arithmetic problems as min-plus convolutions,
- and a formal complexity-transfer principle from classical arithmetic kernels to idempotent kernels.

That is new mathematical infrastructure, not metaphor.

## Deliverables
Required:
- Lean 4 code with minimized sorry usage
- `FUTURE_DIRECTIONS.md`

In `FUTURE_DIRECTIONS.md`, include 3–5 concrete next steps at breakthrough level, for example:
1. tropical number field sieve filtering as a min-plus hypergraph elimination problem,
2. tropical large-sieve inequality for smoothness scoring distributions,
3. certified equivalence between belief propagation and tropical relation scoring,
4. min-plus formulations of lattice sieve collision search,
5. tropical entropy of smooth-number distributions.

Be bold, but be exact: prove the semantic core that makes the vision true.

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

Research domain: Cryptography
Research mode: prove
