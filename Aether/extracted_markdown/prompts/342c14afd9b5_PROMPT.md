## Assignment: Performance envelopes

Mode: **prove**

Prove genuinely new, nontrivial theorems giving **two-sided tropical performance envelopes**. The goal is not a cosmetic variant of one-sided max-plus asymptotics, but a formal bridge theorem showing that **paired min-plus / max-plus certificates produce interval-valued execution laws**
\[
k\cdot \lambda_{\min}+v_{\min}\ \le x_k \le\ k\cdot \lambda_{\max}+v_{\max},
\]
with direct interpretation as **latency lower bounds, throughput upper bounds, schedulability windows, and robust timing envelopes**.

This should become a reusable Lean framework for certifying systems that evolve between two tropical semirings at once.

---

## Research Direction

Construct a formal theory of **tropical interval dynamics**: a sequence `x : ℕ → ℝ` is trapped between a min-plus affine lower certificate and a max-plus affine upper certificate. The revolutionary point is that tropical mathematics usually studies one semiring at a time; here you should prove that the **duality itself becomes a certified envelope principle**.

This opens a path toward:
- real-time systems verification,
- network calculus and queuing bounds,
- discrete event systems,
- adversarial timing analysis,
- tropical control,
- abstract interpretation via affine tropical invariants.

Use the catalog duality lemmas not as decoration, but as the algebraic engine allowing conversion between max and min statements.

---

## Precise Theorem Targets

You should aim to formalize at least one central theorem and ideally a small cluster around it.

### Target 1: Two-sided affine envelope from one-step drift bounds

Let `x : ℕ → ℝ`. Assume every increment is bounded between two constants:
\[
\lambda_{\min} \le x_{n+1}-x_n \le \lambda_{\max}.
\]
Then for all `k`,
\[
x_0 + k\lambda_{\min} \le x_k \le x_0 + k\lambda_{\max}.
\]

This is the atomic theorem from which more tropical-looking corollaries can be derived by renaming intercepts.

A Lean 4 target signature:

```lean
theorem affine_envelope_of_step_bounds
    (x : ℕ → ℝ) (λmin λmax : ℝ)
    (h_lower : ∀ n : ℕ, λmin ≤ x (n+1) - x n)
    (h_upper : ∀ n : ℕ, x (n+1) - x n ≤ λmax) :
    ∀ k : ℕ,
      (x 0) + (k : ℝ) * λmin ≤ x k ∧
      x k ≤ (x 0) + (k : ℝ) * λmax := by
```

This theorem is mathematically elementary but conceptually decisive: it is the certified passage from **local drift inequalities** to **global tropical envelopes**.

### Target 2: Recentered performance-envelope theorem

Package the previous theorem in the exact form suggested by the research direction:

```lean
theorem performance_envelope
    (x : ℕ → ℝ) (λmin λmax vmin vmax : ℝ)
    (h_lower : ∀ k : ℕ, k * λmin + vmin ≤ x k)
    (h_upper : ∀ k : ℕ, x k ≤ k * λmax + vmax) :
    ∀ k : ℕ, k * λmin + vmin ≤ x k ∧ x k ≤ k * λmax + vmax := by
```

This theorem alone is tautological if stated this way, so do **not** stop here. Instead, derive `vmin` and `vmax` from more structural hypotheses, for example `vmin = x 0`, `vmax = x 0`, or from min/max over finite initial windows.

### Target 3: Envelope from bounded tropical recursion

A much more interesting theorem is to assume a recursion with bounded disturbance:
\[
x_{n+1} = \max(x_n + a,\; c_n), \qquad d_{\min} \le c_n - x_n \le d_{\max},
\]
or a min-plus analog, and deduce affine envelopes with slopes determined by the tropical parameters.

A candidate formal statement:

```lean
theorem maxplus_recursion_envelope
    (x c : ℕ → ℝ) (a dmin dmax : ℝ)
    (hrec : ∀ n : ℕ, x (n+1) = max (x n + a) (c n))
    (hcd : ∀ n : ℕ, dmin ≤ c n - x n ∧ c n - x n ≤ dmax) :
    ∀ n : ℕ,
      x 0 + (n : ℝ) * (min a dmin) ≤ x n ∧
      x n ≤ x 0 + (n : ℝ) * (max a dmax) := by
```

You may need to refine this statement if the slope formula is not quite correct. That refinement itself is valuable. The important thing is to prove a genuine recursion-to-envelope theorem, not merely restate hypotheses.

### Target 4: Dualization theorem via negation

Use the existing catalog theorem
- `min_max_duality`
- `negation_max_to_min`

to prove that an upper max-plus envelope for `x` is equivalent to a lower min-plus envelope for `(-x)`.

Candidate signature:

```lean
theorem upper_bound_iff_lower_bound_neg
    (x : ℕ → ℝ) (λ v : ℝ) :
    (∀ k : ℕ, x k ≤ (k : ℝ) * λ + v) ↔
    (∀ k : ℕ, -((k : ℝ) * λ + v) ≤ - x k) := by
```

Then strengthen it into a semiring-interpretation theorem that explicitly uses catalog duality identities to rewrite max-statements as min-statements under negation.

---

## Why this would be a breakthrough

A formal theorem library for one-sided tropical growth is useful. A library for **paired two-sided envelopes** is qualitatively different: it gives a machine-checkable language of **performance contracts**. In applied terms, one affine side controls **best-case service / minimum delay**, the other controls **worst-case delay / maximum backlog growth**. In pure mathematics, this is a first step toward a certified theory of **interval tropical geometry**, where objects are constrained between dual semiring evolutions.

The real breakthrough is not the inequality itself. It is the creation of a reusable theorem schema connecting:
- local drift bounds,
- tropical recursions,
- semiring duality by negation,
- finite-horizon certificates,
- asymptotic rate bounds.

That schema can seed later work on tropical Perron–Frobenius intervals, timed automata abstractions, and tropical Lyapunov theory.

---

## Existing Verified Theorems to Build On

Use these as algebraic infrastructure, not as superficial citations:

1. `min_max_duality`
   ```lean
   theorem min_max_duality (a b : ℝ) : min a b = -(max (-a) (-b)) := by
   ```
   file: `Tropical/Core/FutureDirectionsV2.lean`

   Use this to convert min-plus lower certificates into negated max-plus upper certificates.

2. `negation_max_to_min`
   ```lean
   theorem negation_max_to_min (a b : ℝ) :
   ```
   file: `Tropical/Core/TropicalFrontierResearch.lean`

   This should help normalize expressions involving `- max` into `min` and vice versa. Use it in dualization lemmas.

3. `tropical_lattice_min_max`
   ```lean
   theorem tropical_lattice_min_max (a b c : ℕ) :
   ```
   file: `Tropical/Core/TropicalFactoring.lean`

   Even if on `ℕ`, this may provide a lattice-style pattern for proving monotonicity or interval closure under tropical operations.

4. `bool_and_as_tropical_max`
   file: `Tropical/Core/HashInversion.lean`

5. `trop_min_is_and`
   file: `Tropical/Core/TropicalFutureDirections.lean`

   These boolean/tropical correspondences suggest a cross-domain interpretation: two-sided envelopes behave like conjunction of lower/upper safety predicates.

---

## Lean 4 Formalization Guidance

Prefer concrete, certifiable statements over vague abstractions. Good core types:
- `x : ℕ → ℝ`
- `Finset (Fin n)` if you need finite horizon extrema,
- `Matrix` only if you reach a matrix-driven recurrence,
- `Order` and `Lattice` lemmas from Mathlib for min/max manipulations.

A very promising auxiliary lemma is telescoping via finite sums:

```lean
theorem step_bounds_sum_bounds
    (x : ℕ → ℝ) (λmin λmax : ℝ)
    (h_lower : ∀ n : ℕ, λmin ≤ x (n+1) - x n)
    (h_upper : ∀ n : ℕ, x (n+1) - x n ≤ λmax) :
    ∀ k : ℕ,
      (k : ℝ) * λmin ≤ x k - x 0 ∧
      x k - x 0 ≤ (k : ℝ) * λmax := by
```

Then derive the affine-envelope theorem by `linarith`/ring normalization.

If Mathlib telescoping is awkward, prove by induction on `k`. That may be the cleanest route.

---

## Proof Strategies

### Strategy A: Direct induction on time index
Most promising for a first certified breakthrough.

1. Prove the base case `k = 0`.
2. Assume the envelope at `k`; use the one-step increment bounds to show it at `k+1`.
3. Normalize
   \[
   x_{k+1}=x_k + (x_{k+1}-x_k)
   \]
   and combine inequalities linearly.

Why promising: this avoids heavy finite-sum machinery and will minimize sorry. It is robust and should extend to many recursive variants.

### Strategy B: Telescoping-sum / discrete Grönwall style
More elegant and better for generalization.

1. Rewrite
   \[
   x_k - x_0 = \sum_{i<k} (x_{i+1}-x_i).
   \]
2. Bound each summand below by `λmin` and above by `λmax`.
3. Conclude
   \[
   k\lambda_{\min} \le x_k-x_0 \le k\lambda_{\max}.
   \]

Why promising: once established, this becomes the canonical bridge to matrix and weighted-graph recurrences. It also aligns with network calculus and subadditive methods.

### Strategy C: Dualize upper bounds to lower bounds via negation
Best for the conceptual theorem.

1. Prove the lower-envelope theorem only.
2. Apply it to `-x`.
3. Use `min_max_duality` and `negation_max_to_min` to transport between min-plus and max-plus formulations.

Why promising: this creates the reusable “one proof, two semirings” architecture. It is the right strategy for the field-opening aspect.

Recommended order: **A first, then C, then B**. A gets the theorem into Lean. C gives the conceptual punch. B prepares future scaling.

---

## Cross-Domain Connections

You must connect this work to at least one other domain in a mathematically serious way.

### 1. Network calculus / queueing theory
Interpret `x k` as cumulative departure time or workload. Then:
- lower envelope = guaranteed service floor,
- upper envelope = worst-case delay ceiling.

This gives a path to formalized deterministic QoS verification.

### 2. Control theory / invariant sets
The pair of affine bounds defines a forward invariant interval tube in trajectory space. This is a tropical analog of a Lyapunov envelope or viability kernel.

### 3. Boolean semantics / abstract interpretation
Using `bool_and_as_tropical_max` and `trop_min_is_and`, interpret the conjunction of lower and upper properties as a certified safety contract. This suggests an abstract interpretation semantics where tropical bounds are quantitative truth values.

### 4. Spectral asymptotics
Affine envelopes are finite-time precursors to asymptotic cycle-time results in max-plus linear systems. This could evolve into an interval Perron–Frobenius theorem: uncertain tropical matrices inducing certified growth-rate bands.

### 5. Complexity / scheduling
The theorem can serve as a correctness certificate for greedy schedules or event graphs: every job completion time is trapped in a computable affine band.

---

## Concrete Deliverables

1. A Lean file proving at least one nontrivial theorem of the forms above.
2. Preferably a small supporting API:
   - drift-to-envelope lemma,
   - negation dualization lemma,
   - finite-horizon or recursive corollary.
3. Minimize sorry aggressively.
4. If a target recursion theorem is false as stated, produce a corrected theorem and prove it.
5. Include comments indicating where the catalog theorems enter the proof architecture.

---

## Suggested Lean Targets

Here is a strong minimal package:

```lean
theorem step_lower_to_global_lower
    (x : ℕ → ℝ) (λ : ℝ)
    (h : ∀ n : ℕ, λ ≤ x (n+1) - x n) :
    ∀ k : ℕ, x 0 + (k : ℝ) * λ ≤ x k := by

theorem step_upper_to_global_upper
    (x : ℕ → ℝ) (λ : ℝ)
    (h : ∀ n : ℕ, x (n+1) - x n ≤ λ) :
    ∀ k : ℕ, x k ≤ x 0 + (k : ℝ) * λ := by

theorem affine_envelope_of_step_bounds
    (x : ℕ → ℝ) (λmin λmax : ℝ)
    (h_lower : ∀ n : ℕ, λmin ≤ x (n+1) - x n)
    (h_upper : ∀ n : ℕ, x (n+1) - x n ≤ λmax) :
    ∀ k : ℕ,
      x 0 + (k : ℝ) * λmin ≤ x k ∧
      x k ≤ x 0 + (k : ℝ) * λmax := by

theorem upper_bound_iff_lower_bound_neg
    (x : ℕ → ℝ) (λ v : ℝ) :
    (∀ k : ℕ, x k ≤ (k : ℝ) * λ + v) ↔
    (∀ k : ℕ, -((k : ℝ) * λ + v) ≤ -x k) := by
```

If you can go further, add a recursion theorem with `max`/`min`.

---

## What to avoid

- Do not submit a theorem that merely restates assumptions.
- Do not hide behind abstract classes if a concrete `ℕ → ℝ` proof is available.
- Do not produce only one-sided bounds unless they are clearly stepping stones to the paired envelope theorem.
- Do not ignore the duality lemmas; they are the key to making this a tropical result rather than a generic inequality exercise.

---

## Application Keywords

tropical geometry, max-plus algebra, min-plus algebra, performance envelopes, deterministic network calculus, queueing theory, discrete event systems, schedulability, timed systems, formal verification, abstract interpretation, invariant tubes, tropical duality, affine bounds, throughput guarantees, latency guarantees, certified asymptotics

---

## Team Directive

Create a research team loop:
- one subagent for Lean proof search and induction architecture,
- one subagent for tropical duality and algebraic reformulation,
- one subagent for applications to queues/scheduling,
- one subagent for theorem falsification and counterexample search on proposed recursion statements.

Iterate until you have a clean, reusable theorem cluster.

---

## Required Output Artifacts

- Lean 4 proofs
- `FUTURE_DIRECTIONS.md`

Optional:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `demo.py`
- `diagram.svg`

`FUTURE_DIRECTIONS.md` is critical. It must contain **3–5 concrete next theorems**, each with:
1. exact statement,
2. proof strategy,
3. cross-domain significance.

At least one future direction should be genuinely bold, e.g. an **interval tropical Perron–Frobenius theorem** or a **formal network-calculus backlog bound via tropical envelopes**.

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

Research domain: Tropical
Research mode: prove
