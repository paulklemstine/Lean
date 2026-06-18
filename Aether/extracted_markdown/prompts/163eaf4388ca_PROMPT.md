## Assignment: Tropical Arithmetic Coding: Shannon-Optimal Min-Plus Compression

Mode: **prove**

Aristotle, this is not a request for another coding-theorem variant. This is a demand to build a new bridge: **idempotent information theory as constructive source coding**. The target is to make tropical probability behave like a genuine coding semantics, not merely an analogy. If done correctly, this opens a field: **tropical source coding**, where min-plus convolution, dynamic programming, entropy bounds, and universal compression become one theorem-schema.

You should aim to prove a formally precise package of results showing that:

1. a tropical code-length functional defined by min-plus aggregation is optimal among prefix-like tropical codes,
2. it saturates the Shannon lower bound up to the classical `+1` discretization effect,
3. min-plus convolution is the algebraic mechanism generating optimal merged code lengths,
4. tropical Huffman merging is not a metaphor but an exact optimizer in the idempotent semiring.

This is the right scale: not “batchnorm for tropical robustness,” but a **new coding theory over min-plus algebra**.

---

## Core theorem package to formalize

Work with a finite alphabet `α` and a probability mass function `μ : FinProbDist α`. Since the exact API of `FinProbDist` may vary, you may need a lightweight wrapper for `μ.prob a : ℝ` with positivity hypotheses.

Define the tropical self-information / ideal real code length by
\[
I_\mu(a) := - \log (\mu(a)).
\]
Define the rounded Shannon code length
\[
L_\mu(a) := \lceil I_\mu(a) \rceil.
\]
Then prove the expected-length upper/lower optimality theorem and the min-plus merge theorem.

### Theorem A: Tropical Shannon code near-optimality

**Mathematical statement**

For every finite source with strictly positive probabilities, the rounded tropical self-information code has expected length between entropy and entropy plus one:
\[
H(\mu) \le \sum_{a} \mu(a)\,L_\mu(a) < H(\mu)+1.
\]

This is the irreducible first bridge: the tropical code-length obtained from min-plus/log geometry is Shannon-optimal up to the unavoidable integrality gap.

### Suggested Lean 4 signature

```lean
theorem tropical_shannon_code_near_optimal
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : FinProbDist α)
    (hpos : ∀ a : α, 0 < μ.prob a) :
    let L : α → ℕ := fun a => Nat.ceil (-Real.log (μ.prob a))
    let EL : ℝ := ∑ a, μ.prob a * (L a : ℝ)
    let H  : ℝ := - ∑ a, μ.prob a * Real.log (μ.prob a)
    H ≤ EL ∧ EL < H + 1
```

If `Nat.ceil : ℝ → ℕ` is awkward in the current environment, use `Int.ceil` and cast, or define `L : α → ℤ` first and prove nonnegativity separately.

### Why this is a breakthrough

This theorem upgrades “tropical information” from slogan to **constructive compressor**. The object `-log μ(a)` is simultaneously:
- the classical information content,
- a tropical weight,
- and the optimizer for code-length assignment after integer rounding.

That unification is exactly the kind of theorem that births a subfield.

---

## Theorem B: Tropical source coding lower/upper sandwich with catalog integration

Build directly on:

- `source_coding_lower_bound`
- `tropical_source_coding_bound`
- `universal_tropical_code_optimal`

You should prove that the tropical Shannon code witnesses the abstract lower bound and is compatible with the existing universal optimality theorem.

### Mathematical statement

For any admissible tropical code-length function `ℓ : α → ℕ` satisfying the relevant prefix/Kraft-style feasibility condition used in your local development,
\[
H(\mu) \le \mathbb E_\mu[\ell].
\]
Moreover, the tropical Shannon assignment `L_\mu(a)=\lceil -\log \mu(a)\rceil` satisfies feasibility and therefore
\[
H(\mu) \le \mathbb E_\mu[L_\mu] < H(\mu)+1.
\]

### Suggested Lean 4 signature

```lean
theorem tropical_code_expected_length_sandwich
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : FinProbDist α)
    (hpos : ∀ a : α, 0 < μ.prob a) :
    ∃ L : α → ℕ,
      TropicalPrefixCode L ∧
      let EL : ℝ := ∑ a, μ.prob a * (L a : ℝ)
      let H  : ℝ := - ∑ a, μ.prob a * Real.log (μ.prob a)
      H ≤ EL ∧ EL < H + 1
```

If `TropicalPrefixCode` does not exist, define it in the minimal mathematically correct way, likely via a Kraft inequality:
\[
\sum_a 2^{-\ell(a)} \le 1.
\]
Then prove the Shannon lengths satisfy it using
\[
2^{-\lceil -\log_2 p\rceil} \le p.
\]
If your entropy theorem uses natural logs, account for the base-change constant explicitly.

### Why this matters

This theorem ties the existing catalog lower bounds to an explicit optimizer. It converts abstract source-coding inequalities into a certified construction. That is the step from theory to architecture.

---

## Theorem C: Tropical Huffman merge optimality via min-plus convolution

This is the genuinely new theorem. The conceptual claim is that the **merge rule in optimal coding is min-plus convolutional**.

For weights \(w_1,\dots,w_n\) representing tropical costs / negative log-probabilities, define a merge operation that replaces two symbols by one super-symbol with weight equal to the tropical-compatible combined cost. In the probability picture, merging probabilities adds probabilities; in the log picture this becomes a log-sum-exp object, whose tropical shadow is min-plus. The formal theorem should isolate a finite combinatorial statement that Lean can certify.

A robust formal target is the dynamic-programming principle:

### Mathematical statement

Let `mergeCost` be the cost of combining two subtrees with weights `x,y`. Define recursively the optimal total code cost of a multiset of symbol weights. Then:
1. the optimal cost is invariant under permutation,
2. it satisfies the Huffman recurrence obtained by merging a pair of minimal weights,
3. in the tropical approximation regime, this recurrence is represented by min-plus convolution of partial cost profiles.

At minimum, prove a finite version for lists of natural or real weights.

### Suggested Lean 4 signatures

A combinatorial recurrence theorem:
```lean
theorem tropical_huffman_recurrence
    (w : List ℝ)
    (h_nonneg : ∀ x ∈ w, 0 ≤ x)
    (h_len : 2 ≤ w.length) :
    optimalTropicalCost w =
      minOverMerges (fun i j =>
        optimalTropicalCost ((mergeWeights i j w)) + mergedPairWeight i j w)
```

A more implementation-friendly DP/convolution theorem:
```lean
theorem tropical_convolution_realizes_merge_step
    (f g : ℕ → ℝ) :
    tropicalConvolution f g =
      fun n => sInf {c | ∃ i j, i + j = n ∧ c = f i + g j}
```

and then a coding-specific specialization:
```lean
theorem optimal_code_profile_eq_tropical_convolution
    (A B : Finset ℕ) :
    codeProfile (A ∪ B) =
      tropicalConvolution (codeProfile A) (codeProfile B)
```

The exact objects may need adaptation, but the theorem must say something unmistakable: **optimal code lengths for combined sources are computed by min-plus convolution**.

### Why this is revolutionary

This theorem says that Huffman coding is not merely greedy combinatorics; it is **tropical algebra in disguise**. That opens:
- tropical dynamic programming,
- idempotent compiler optimization,
- shortest-path interpretations of source coding,
- and a pathway to tropical rate-distortion and tropical channel coding.

This is the field-opening move.

---

## Theorem D: Constructive duality between source distributions and tropical code lengths

Push one step further: characterize optimal code lengths as the tropical Legendre-type dual of source weights.

A lean-formalizable finite statement is:

### Mathematical statement

For a finite source `μ`, define the tropical weight function
\[
w(a) = -\log \mu(a).
\]
Then the optimal admissible integer code length `L(a)` is the least integer majorant of `w(a)` among all feasible code assignments, and any other feasible `ℓ` satisfies
\[
L(a) \le \ell(a) + C
\]
in expectation with `C` minimal equal to the integrality defect. More concretely, `L = ceil ∘ w` is the canonical tropical envelope.

### Suggested Lean 4 signature

```lean
theorem ceil_neglog_is_least_feasible_majorant
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : FinProbDist α)
    (hpos : ∀ a : α, 0 < μ.prob a) :
    let w : α → ℝ := fun a => -Real.log (μ.prob a)
    let L : α → ℕ := fun a => Nat.ceil (w a)
    TropicalPrefixCode L ∧
    ∀ ℓ : α → ℕ, TropicalPrefixCode ℓ →
      (∀ a, w a ≤ ℓ a) →
      ∀ a, L a ≤ ℓ a
```

This theorem is extremely elegant if you can make the feasibility notion line up cleanly.

---

## Proof strategy architecture

You must pursue at least 2–3 proof paths in parallel and choose the one Lean likes best.

### Strategy 1: Entropy sandwich via ceiling inequalities and catalog lower bounds
Most promising for Theorem A and B.

1. Prove the pointwise inequalities
   \[
   -\log p \le \lceil -\log p\rceil < -\log p + 1
   \]
   for `0 < p ≤ 1`.
2. Multiply by `μ(a)` and sum over the finite alphabet.
3. Use `source_coding_lower_bound` and/or `tropical_source_coding_bound` to discharge the lower-bound side abstractly, while the upper bound is elementary.
4. Connect to `universal_tropical_code_optimal` by showing your `L` is one of the admissible universal tropical codes.

Why this is promising: it is analytically straightforward, uses only finite sums and standard log facts, and turns the catalog theorems into immediate leverage.

### Strategy 2: Kraft feasibility from exponential domination
Best for constructing explicit codes.

1. Show
   \[
   2^{-L(a)} \le \mu(a)
   \]
   when `L(a)=⌈-log₂ μ(a)⌉`.
2. Sum over `a` to obtain the Kraft inequality
   \[
   \sum_a 2^{-L(a)} \le \sum_a \mu(a)=1.
   \]
3. Invoke a prefix-code existence theorem if available; otherwise define a tropical feasibility predicate directly by the Kraft inequality and work entirely at that level.
4. Deduce optimality from `source_coding_lower_bound`.

Why this is promising: avoids needing an explicit tree datatype unless you want actual Huffman realizers.

### Strategy 3: Dynamic programming and min-plus convolution
Most promising for Theorem C.

1. Define a cost profile `F : ℕ → ℝ` where `F n` is the optimal cost of encoding a structure of size `n` or with `n` leaves / mass partitions.
2. Show splitting into left and right subproblems yields
   \[
   F(n)=\inf_{i+j=n}(F_1(i)+F_2(j)),
   \]
   which is exactly tropical convolution.
3. Prove associativity using the existing theorem `tropical_min_associative` as a toy model / stepping stone, then lift from `ℕ` to `ℝ`-valued profiles.
4. Use permutation invariance and greedy pair-merging lemmas to connect the DP formula to Huffman recurrence.

Why this is promising: this is where the new algebra lives. Even a clean finite-list version would be publishable-grade mathematically.

---

## How to use the catalog theorems precisely

### `universal_tropical_code_optimal`
File: `Bridges/IdempotentInfoTheory/TropicalArithmeticCoding.lean`

Use this as the endpoint compatibility theorem. Do not merely cite it. Identify its hypotheses and show your Shannon/tropical code lengths satisfy them. If it gives an abstract optimality criterion, instantiate it with `L(a) = ceil (-log μ(a))`.

### `source_coding_lower_bound`
File: `Computation/Entropy.lean`

This should provide the lower half of the coding theorem:
\[
H(\mu)\le E[\ell].
\]
Your job is to convert your explicit `L` into an admissible `ℓ` under its hypotheses.

### `tropical_source_coding_bound`
File: `Bridges/IdempotentInfoTheory/SourceCoding.lean`

This likely already encodes an idempotent/tropical coding inequality. Use it to connect classical entropy language with tropical formulations, ideally proving equivalence or specialization.

### `tropical_min_associative`
File: `Computation/Factoring/FutureResearchTheorems.lean`

This is a toy algebraic seed. Generalize its associative min-structure from simple naturals to convolutional profiles or merge costs. Even if not used directly in the final proof, it can seed auxiliary lemmas:
- associativity of tropical convolution,
- invariance under regrouping of merge steps,
- parenthesization-independence of code profile combination.

### `tropical_and_bound`
Potentially useful as a finite inequality gadget if there are cost lower bounds involving `max/min` style combinators. Inspect it for reusable proof patterns on tropical inequalities.

---

## Cross-domain connections you should explicitly exploit

Do not leave this as isolated coding theory. Tie it to at least one of the following.

### 1. Shortest paths / dynamic programming
Min-plus convolution is the algebra of shortest paths. Your theorem implies:
- optimal code construction is a shortest-path problem in an idempotent semiring,
- tropical coding is a special case of semiring dynamic programming,
- universal coding can be recast as path optimization.

This connection could enable certified compression algorithms via graph methods.

### 2. Statistical mechanics / zero-temperature limits
The passage from log-sum-exp to min-plus is the zero-temperature limit of free energy. That means tropical coding is a **zero-temperature source coding theory**. If formalized carefully, this suggests:
- low-temperature asymptotics of arithmetic coding,
- large deviations interpretations of code lengths,
- a thermodynamic semantics of information compression.

### 3. Category theory / enriched algebra
Min-plus semirings support Lawvere metric enrichment. Code lengths can be seen as costs in an enriched category. A code optimizer then becomes a colimit/infimal convolution mechanism. Even a brief remark in `ARTICLE.md` could seed future formalization.

### 4. Control theory / Bellman operators
Tropical convolution is Bellman composition. Huffman-like merge optimality therefore connects source coding to optimal control. This is not decorative; it suggests future certified algorithms for adaptive coding via value iteration.

---

## Concrete implementation guidance in Lean 4

Use concrete finite objects first. Avoid trying to formalize full arithmetic coding intervals unless the existing file already has them. The immediate high-value target is the **length theorem**, not the interval semantics.

Recommended definitions:
- `tropInfo (μ : FinProbDist α) (a : α) : ℝ := -Real.log (μ.prob a)`
- `shannonLen (μ : FinProbDist α) (a : α) : ℕ := Nat.ceil (tropInfo μ a)`
- `expectedLen (μ) (L) := ∑ a, μ.prob a * (L a : ℝ)`
- `entropy (μ) := -∑ a, μ.prob a * Real.log (μ.prob a)`

Potential helper lemmas:
```lean
lemma neglog_nonneg {p : ℝ} (hp0 : 0 < p) (hp1 : p ≤ 1) : 0 ≤ -Real.log p
lemma le_ceil_neglog {p : ℝ} (hp0 : 0 < p) : -Real.log p ≤ (Nat.ceil (-Real.log p) : ℝ)
lemma ceil_lt_add_one {x : ℝ} : (Nat.ceil x : ℝ) < x + 1
lemma expected_len_def ...
lemma entropy_def ...
```

If `μ.prob a ≤ 1` is not already available, prove it from total mass `∑ a, μ.prob a = 1` and nonnegativity.

For Theorem C, if full Huffman trees are too heavy, formalize the tropical convolution theorem first on functions `ℕ → ℝ∞` or `ℕ → WithTop ℝ`; this can later be specialized to coding.

---

## Minimum nontrivial deliverables

You should not stop at a single inequality lemma. The cycle is successful only if you produce at least:

1. `tropical_shannon_code_near_optimal`
2. one explicit feasibility / Kraft theorem for `ceil (-log μ)`
3. one tropical convolution theorem with genuine algebraic content
4. one bridge theorem instantiating an existing catalog theorem with your new definitions

If a full Huffman optimality proof is too large, prove the DP/min-plus recurrence cleanly and leave the tree-realization as a future direction.

---

## Application keywords

tropical information theory; source coding; arithmetic coding; Huffman coding; min-plus convolution; idempotent semiring; Shannon entropy; Kraft inequality; dynamic programming; shortest paths; Bellman operators; zero-temperature limit; universal compression; semiring algorithms; certified compression

---

## Required output artifacts

1. Lean 4 files with theorems and minimized `sorry`.
2. `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - tropical rate-distortion theorem,
   - tropical mutual information and data processing inequality,
   - tropical channel coding / noisy coding theorem,
   - semiring-generalized arithmetic coding,
   - certified adaptive coding via Bellman iteration.
3. Optional but encouraged: `ARTICLE.md` explaining the conceptual bridge from Huffman/arithmetic coding to min-plus algebra and shortest paths.

Do not be timid. If you can prove that optimal source coding is literally tropical dynamic programming, you have not extended a library—you have created a research program.

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

Research domain: Computation
Research mode: prove
