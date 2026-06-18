## Assignment: Tropical Quadratic Sieve as Min-Plus Correlation and Valuation Filter

Mode: **prove**

This direction needs one decisive correction before it becomes mathematically real: a genuine integer factoring algorithm cannot be proved subexponential in Lean merely from min-plus matrix multiplication identities. The revolutionary target is therefore not the false statement “tropical arithmetic alone factors integers,” but the deeper and actually defensible bridge theorem:

> **the quadratic sieve admits a tropical shadow**: the smoothness-detection and score-aggregation stages of QS can be encoded as min-plus / max-plus convolutions on valuation vectors, and these tropical operators recover the same candidate relation set as the classical logarithmic sieve up to explicitly bounded discretization error.

That is already field-opening, because it reframes a central algorithm in computational number theory as an idempotent signal-processing problem. If formalized cleanly, it opens a new program: **idempotent cryptanalysis**, where sieving, decoding, shortest-path methods, and tropical linear algebra become one theory.

You should aim for a theorem package, not a single slogan.

---

## Core theorem package to formalize

### 1. Tropical valuation score equals truncated log-sieve score

Let `P = [p₁, …, p_k]` be a factor base, let `v_p(n)` denote the `p`-adic valuation of `n`, and define the truncated smoothness score
\[
S_P(n) := \sum_{p \in P} v_p(n)\,\log p.
\]
For a target interval of sieve values `Q(x+i)` in a quadratic sieve polynomial, define the tropical weight vector
\[
w_P(n) := (v_{p_1}(n),\dots,v_{p_k}(n)).
\]
Then smoothness testing is equivalent to comparing the tropical/log score against `log |n|`, modulo the large-prime remainder.

The precise theorem to formalize should be:

> **Theorem A (exact factor-base score decomposition).**  
> For every nonzero natural number `n` and every finite factor base `P : Finset ℕ` consisting of primes,
> \[
> \sum_{p \in P} (n.factorization p) \cdot \log p \;=\; \log\!\Big(\prod_{p\in P} p^{n.factorization p}\Big).
> \]
> In particular, if every prime divisor of `n` lies in `P`, then
> \[
> \sum_{p \in P} (n.factorization p)\cdot \log p = \log n.
> \]

This is the exact bridge from arithmetic multiplicativity to tropical additivity.

A Lean target could be:

```lean
theorem factor_base_log_score_eq_log_prod_factorization
    (P : Finset ℕ) (n : ℕ)
    (hn : n ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p) :
    (∑ p in P, (n.factorization p : ℝ) * Real.log p) =
      Real.log (∏ p in P, (p : ℝ) ^ (n.factorization p)) := by
  ...
```

and the smooth case:

```lean
theorem smooth_over_factor_base_log_score_eq_log
    (P : Finset ℕ) (n : ℕ)
    (hn : n ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p)
    (hsmooth : ∀ q, Nat.Prime q → q ∣ n → q ∈ P) :
    (∑ p in P, (n.factorization p : ℝ) * Real.log p) = Real.log n := by
  ...
```

This is not cosmetic. It is the rigorous statement that the “log sieve” is already tropicalized by valuation.

---

### 2. Tropical convolution computes aggregate sieve scores

Let `vals : ℕ → ℕ → ℕ` encode `vals i p = v_p(Q(i))`. Let `L(p) = log p`. Define the score
\[
\mathrm{Score}(i) = \sum_{p\in P} \mathrm{vals}(i,p)\,L(p).
\]
This is a matrix-vector product over the ordinary semiring, but because valuation aggregation is additive and thresholding is order-theoretic, the candidate selection step can be expressed via tropical comparison.

The theorem should state that the tropicalized score filter is monotone and exact on smooth values.

A concrete theorem target:

> **Theorem B (tropical score soundness for smoothness).**  
> If `Q(i)` is `P`-smooth, then the tropical score of `Q(i)` equals `log |Q(i)|`. Hence any threshold rule of the form `score(i) ≥ log |Q(i)| - ε` accepts all exact `P`-smooth values with `ε = 0`, and accepts all almost-smooth values with explicitly bounded remainder.

Lean target:

```lean
def tropicalScore (P : Finset ℕ) (Q : ℕ → ℕ) (i : ℕ) : ℝ :=
  ∑ p in P, (Q i).factorization p * Real.log p

theorem tropicalScore_eq_log_of_smooth
    (P : Finset ℕ) (Q : ℕ → ℕ) (i : ℕ)
    (hQnz : Q i ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p)
    (hsmooth : ∀ q, Nat.Prime q → q ∣ Q i → q ∈ P) :
    tropicalScore P Q i = Real.log (Q i) := by
  ...
```

Then prove a remainder decomposition:

```lean
theorem tropicalScore_le_log
    (P : Finset ℕ) (n : ℕ)
    (hn : n ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p) :
    (∑ p in P, (n.factorization p : ℝ) * Real.log p) ≤ Real.log n := by
  ...
```

with equality iff all prime divisors are in `P`.

This gives the exact mathematical content of the sieve filter.

---

### 3. Min-plus kernel formulation of relation search

The truly novel statement is not “factoring is subexponential because tropical multiplication is fast,” which is not justified. The stronger and correct theorem is:

> **Theorem C (relation search as tropical kernel minimization).**  
> Let `M : Matrix ι ι ℕ∞` encode local penalties for selecting offsets in a sieve interval, and let `b : ι → ℕ∞` encode valuation deficit relative to the factor base. Then the min-plus matrix product `M ⊗ b` computes the optimal aggregate deficit profile. Candidate smooth relations correspond to indices where this profile attains `0` (exact smoothness) or a bounded residual (large-prime variant).

You may need to define an abstract min-plus matrix multiplication on `WithTop ℕ` or `ℝ∞`.

Lean sketch:

```lean
open Matrix

def minPlusMul {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n (WithTop ℕ)) : Matrix n n (WithTop ℕ) :=
  fun i k => ⨅ j, A i j + B j k

def deficitVec (P : Finset ℕ) (Q : ℕ → ℕ) (i : ℕ) : ℕ :=
  Nat.log (Q i) - ∑ p in P, (Q i).factorization p * Nat.log p
```

Even if exact `Nat.log` infrastructure is awkward, do it first over `ℝ` as a score defect:
\[
\delta_P(n)= \log n - \sum_{p\in P} v_p(n)\log p \ge 0.
\]
Then show `δ_P(n)=0` iff `n` is `P`-smooth.

Lean target:

```lean
def scoreDefect (P : Finset ℕ) (n : ℕ) : ℝ :=
  Real.log n - ∑ p in P, (n.factorization p : ℝ) * Real.log p

theorem scoreDefect_nonneg
    (P : Finset ℕ) (n : ℕ)
    (hn : n ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p) :
    0 ≤ scoreDefect P n := by
  ...

theorem scoreDefect_eq_zero_iff_smooth
    (P : Finset ℕ) (n : ℕ)
    (hn : n ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p) :
    scoreDefect P n = 0 ↔ ∀ q, Nat.Prime q → q ∣ n → q ∈ P := by
  ...
```

This theorem is the exact idempotent certification principle behind tropical sieving.

---

## Why this is a breakthrough

If you prove these theorems cleanly, you will have done something much better than a dubious complexity claim. You will have established:

- a formal equivalence between **factorization smoothness detection** and **tropical score exactness**;
- a bridge between **analytic number theory**, **idempotent semirings**, and **matrix algorithms**;
- the first Lean-ready foundation for **tropical cryptanalysis** of sieve-based arithmetic tasks.

This opens a new field: algorithms traditionally expressed in rings can be reinterpreted in semiring geometry, where optimization, dynamic programming, and cryptanalysis become interchangeable.

Think of the implications:
- quadratic sieve ↔ tropical convolution;
- large-prime variants ↔ bounded defect states;
- relation collection ↔ low-energy configurations in a valuation landscape;
- sparse linear algebra over `F₂` ↔ phase transition after tropical preselection.

This is the kind of connection that makes people rethink algorithm design itself.

---

## Build explicitly on the catalog theorems

You were given:

1. `tropical_plus_distributes_over_min` in `Cryptography/TropicalPostQuantumPrimitives.lean`
2. `tropical_plus_distributes_over_min` in `Cryptography/TropicalQuadraticSieveExact.lean`
3. `tropical_sieve_kernel_work_bound` in `Cryptography/TropicalQuadraticSieve.lean`
4. `idempotent_semiring_with_inverses_trivial`
5. `tropical_add_idempotent`

Use them intelligently.

### How to use them

- `tropical_plus_distributes_over_min` should justify algebraic normalization of min-plus score propagation. If you define a min-plus kernel for deficits, this theorem will let you rewrite nested score updates into canonical forms.
- `tropical_sieve_kernel_work_bound` should be lifted from a raw kernel bound to a relation-search bound: show that the tropical scoring stage is no worse than the existing kernel complexity. This is the right place for a formal complexity theorem.
- `tropical_add_idempotent` is conceptually crucial: repeated evidence from the same valuation source should not overcount under idempotent aggregation. This helps justify duplicate-candidate collapse or repeated local propagation.
- `idempotent_semiring_with_inverses_trivial` is a warning theorem. Use it to explain why the tropical sieve can only model the **selection/scoring** stage, not the full multiplicative structure needed for exact integer arithmetic. This theorem prevents overclaiming and sharpens the architecture.

That last point is important: the obstruction theorem is not a nuisance; it is the conceptual boundary that makes your result precise and believable.

---

## Precise complexity target

Do **not** claim a full verified subexponential factoring theorem unless you formalize the entire analytic number theory of smooth number density, relation collection, and linear algebra costs. That is too large for this cycle.

Instead prove the following rigorous and meaningful complexity theorem:

> **Theorem D (tropical scoring stage complexity).**  
> For factor-base size `B` and sieve interval length `R`, the tropical valuation-score computation over all sieve positions has work bounded by `O(RB)` in the naive form, and inherits the certified kernel bound already present in `tropical_sieve_kernel_work_bound`. Therefore the tropical reformulation preserves the asymptotic complexity of the classical score accumulation stage.

Lean-style target:

```lean
theorem tropical_scoring_work_bound
    (R B : ℕ) :
    ∃ C : ℕ, tropicalWork R B ≤ C * R * B := by
  ...
```

or, if you already have a concrete function:

```lean
theorem tropical_scoring_work_bound'
    (R B : ℕ) :
    tropicalScoringWork R B ≤ tropicalSieveKernelWork R B := by
  ...
```

where you align names with the existing file.

This is the honest complexity theorem. It is enough to show that the tropical encoding is computationally faithful.

---

## Proof strategies

### Strategy A: valuation-factorization route
Most promising.

1. Use `Nat.factorization`, unique factorization, and prime support lemmas to rewrite `n` as the product of factor-base prime powers times an out-of-base remainder.
2. Apply `Real.log_mul` and `Real.log_rpow`/power-log identities on positive reals to split `log n` into factor-base contribution plus remainder.
3. Deduce nonnegativity and exactness of `scoreDefect`, then characterize smoothness by vanishing remainder.

Why this is strongest: it gives exact equalities, not heuristic approximations, and plugs directly into Mathlib’s arithmetic infrastructure.

### Strategy B: multiset-of-primes / support decomposition
Potentially simpler combinatorially.

1. Express the prime decomposition of `n` via the support of `n.factorization`.
2. Partition support into primes in `P` and primes not in `P`.
3. Sum logs over each part; the second part is the defect term. Vanishing of that part is equivalent to smoothness.

Why useful: this avoids building complicated kernel machinery too early and isolates the arithmetic heart.

### Strategy C: tropical kernel abstraction after arithmetic lemmas
Best for the second half.

1. First prove arithmetic correctness theorems (`scoreDefect_nonneg`, `eq_zero_iff_smooth`).
2. Then define an abstract min-plus propagation operator on defects or penalties.
3. Use `tropical_plus_distributes_over_min` to prove composition laws and invoke `tropical_sieve_kernel_work_bound` for complexity inheritance.

Why staged this way: the tropical matrix theorem becomes easy once the valuation defect is formalized as the invariant.

---

## Cross-domain connections to make explicit

Do not leave the result inside cryptography. Connect it outward.

### 1. Tropical geometry
The score defect
\[
\delta_P(n)=\log n-\sum_{p\in P} v_p(n)\log p
\]
is a distance-to-factor-base quantity in a polyhedral valuation cone. Smooth numbers are exactly the points lying on the factor-base tropical face. This reframes smoothness as tropical membership.

### 2. Statistical mechanics
Interpret `δ_P(n)` as an energy functional:
- exact smoothness = ground state;
- one-large-prime relations = low-energy excitations;
- relation collection = sampling low-energy states in a sieve landscape.

This is not fluff. It suggests importing partition-function and large-deviation ideas into smoothness heuristics.

### 3. Coding theory / belief propagation
The sieve accumulates local prime evidence across positions. That is structurally similar to message passing on a factor graph:
- primes contribute local weights,
- offsets collect aggregate evidence,
- thresholding selects candidate codewords/relations.

A future bridge to LDPC decoding or min-sum algorithms could be enormous.

### 4. Dynamic programming / shortest paths
Min-plus matrix multiplication is the algebra of shortest paths. Your theorem says a relation search can be viewed as path optimization in valuation space. This invites algorithmic acceleration from APSP, semiring convolution, and hardware min-plus primitives.

---

## Concrete file architecture suggestion

Create one or more files such as:

- `Cryptography/TropicalQuadraticSieveShadow.lean`
- `Cryptography/TropicalSmoothnessScore.lean`
- `Cryptography/TropicalRelationKernel.lean`

Suggested progression:

1. Define `tropicalScore`, `scoreDefect`.
2. Prove exact arithmetic lemmas about factorization and logs.
3. Prove `scoreDefect_nonneg` and `scoreDefect_eq_zero_iff_smooth`.
4. Define abstract min-plus kernel operators.
5. Prove tropical composition / monotonicity.
6. Derive work bound using `tropical_sieve_kernel_work_bound`.

Minimize `sorry` by landing the arithmetic core first.

---

## Suggested Lean signatures

Use these as primary targets.

```lean
def tropicalScore (P : Finset ℕ) (n : ℕ) : ℝ :=
  ∑ p in P, (n.factorization p : ℝ) * Real.log p

def scoreDefect (P : Finset ℕ) (n : ℕ) : ℝ :=
  Real.log n - tropicalScore P n
```

```lean
theorem tropicalScore_eq_log_of_smooth
    (P : Finset ℕ) (n : ℕ)
    (hn : n ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p)
    (hsmooth : ∀ q, Nat.Prime q → q ∣ n → q ∈ P) :
    tropicalScore P n = Real.log n := by
  ...
```

```lean
theorem tropicalScore_le_log
    (P : Finset ℕ) (n : ℕ)
    (hn : n ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p) :
    tropicalScore P n ≤ Real.log n := by
  ...
```

```lean
theorem scoreDefect_nonneg
    (P : Finset ℕ) (n : ℕ)
    (hn : n ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p) :
    0 ≤ scoreDefect P n := by
  ...
```

```lean
theorem scoreDefect_eq_zero_iff_smooth
    (P : Finset ℕ) (n : ℕ)
    (hn : n ≠ 0)
    (hPprime : ∀ p ∈ P, Nat.Prime p) :
    scoreDefect P n = 0 ↔ ∀ q, Nat.Prime q → q ∣ n → q ∈ P := by
  ...
```

For the tropical kernel layer:

```lean
def minPlusMatMul {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A B : Matrix ι ι (WithTop ℕ)) : Matrix ι ι (WithTop ℕ) :=
  fun i k => ⨅ j, A i j + B j k
```

```lean
theorem minPlusMatMul_assoc
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A B C : Matrix ι ι (WithTop ℕ)) :
    minPlusMatMul (minPlusMatMul A B) C = minPlusMatMul A (minPlusMatMul B C) := by
  ...
```

```lean
theorem tropical_scoring_stage_refines_kernel_bound
    (R B : ℕ) :
    tropicalScoringWork R B ≤ tropicalSieveKernelWork R B := by
  ...
```

Adjust names to match the imported development.

---

## Important negative result to acknowledge

Use `idempotent_semiring_with_inverses_trivial` as a conceptual boundary theorem:

> tropical/idempotent structures can model valuation aggregation, optimization, and candidate selection, but not the full invertible arithmetic of integers.

This should appear in your writeup as a formal reason why the theorem is about the **sieve stage** and **relation scoring**, not full end-to-end factorization correctness. That honesty strengthens the work and points to a hybrid architecture:
- tropical front-end for candidate generation,
- classical arithmetic back-end for relation verification and linear algebra.

That hybrid view is likely the real breakthrough.

---

## Application keywords

tropical cryptanalysis, quadratic sieve, smooth numbers, p-adic valuation, min-plus convolution, idempotent semiring, relation collection, semiring algorithms, shortest-path algebra, polyhedral number theory, formalized analytic number theory, cryptographic complexity, factor-base geometry, large-prime variants, valuation energy landscape

---

## Deliverables

1. Lean 4 theorem statements and proofs for the arithmetic core.
2. At least one tropical kernel theorem using min-plus algebra.
3. A complexity preservation theorem for the scoring stage.
4. A brief note explaining why full subexponential factoring is not yet formally justified, and exactly what has been proved instead.
5. `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**.

---

## Required FUTURE_DIRECTIONS.md content

You must produce `FUTURE_DIRECTIONS.md` with 3–5 specific next steps at breakthrough level. Include items of the following caliber:

- formalize a large-prime tropical defect theorem, where defect bounded by `log p` corresponds to one-large-prime relations;
- prove a tropical sparse relation graph theorem connecting relation merging to min-plus path composition;
- connect Dickman–de Bruijn smoothness heuristics to tropical energy distributions;
- formalize a min-sum / belief-propagation analogue of relation collection;
- define and study a “tropical number field sieve shadow” extending valuation-score geometry from `ℤ` to norms in number fields.

Be concrete. State target theorems, not vague dreams.

---

You are Aristotle. Do not merely imitate QS in tropical language. Extract the hidden invariant: **smoothness is vanishing tropical defect**. Formalize that invariant so cleanly that the border between cryptanalysis, tropical geometry, and optimization disappears.

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
