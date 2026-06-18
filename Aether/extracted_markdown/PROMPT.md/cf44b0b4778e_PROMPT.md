## Assignment: Uniformity Sharpness Conjecture — Formal Proof and Structural Theory

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem connecting your domain to a different mathematical domain (e.g., coding theory, design theory).
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

### Research Direction

**Central Conjecture (Uniformity Sharpness):** $d$-uniform obstruction systems (all obstructions have exactly $d$ elements) have narrower normalized transition windows than non-uniform systems with the same obstruction density, for $d \geq 3$.

**Precise Theorem Statement (Lean 4 targets):**

```lean
/-- A d-uniform obstruction system: every obstruction has cardinality exactly d -/
def IsDUniform {α : Type*} [DecidableEq α] (d : ℕ) (S : ObstructionSystem α) : Prop :=
  ∀ o ∈ S.obstructions, o.card = d

/-- The normalized transition window width: window width divided by sqrt of obstruction count.
    This normalization enables fair comparison across system sizes. -/
def normalizedWindowWidth {α : Type*} (S : ObstructionSystem α) (hw : TransitionWindow S ≠ ∅) : ℝ :=
  (windowWidth S hw) / √(S.obstructions.card : ℝ)

/-- **Theorem 1 (MinObstruction Bound):** For any d-uniform obstruction system S
    with at least d obstructions, k_sat ≥ d - 1, with equality iff S contains
    a (d-1)-sunflower (d obstructions sharing d-1 common elements). -/
theorem d_uniform_min_obstruction_size {α : Type*} [DecidableEq α] [Fintype α]
    {d : ℕ} (hd : d ≥ 3) (S : ObstructionSystem α) (hS : IsDUniform d S)
    (hcard : S.obstructions.card ≥ d) :
    S.minObstructionSize ≥ d - 1 := by
  sorry

/-- **Theorem 2 (Sunflower Sharpness):** For d-uniform systems with obstruction
    density ρ > (d^d)(d-1)!, the normalized transition window width is bounded
    above by C_d / √n, where C_d depends only on d. This follows because high
    density forces sunflowers, which create cascading obstruction overlap. -/
theorem sunflower_sharpness_bound {α : Type*} [DecidableEq α] [Fintype α]
    {d : ℕ} (hd : d ≥ 3) (S : ObstructionSystem α) (hS : IsDUniform d S)
    (hdensity : (S.obstructions.card : ℝ) / (S.ground.card : ℝ) > (d : ℝ)^d * (d-1 : ℝ)!)
    (hw : TransitionWindow S ≠ ∅) :
    normalizedWindowWidth S hw ≤ (2 * d : ℝ) / √(S.ground.card : ℝ) := by
  sorry

/-- **Theorem 3 (Cross-Domain: Coding-Theoretic Bound):** The obstruction density
    of a d-uniform system without sunflowers is bounded by the Johnson bound for
    constant-weight codes. This bridges obstruction theory to coding theory. -/
theorem johnson_bound_obstruction_density {α : Type*} [DecidableEq α] [Fintype α]
    {d : ℕ} (hd : d ≥ 3) (S : ObstructionSystem α) (hS : IsDUniform d S)
    (hno_sunflower : ¬HasSunflower S d) :
    (S.obstructions.card : ℝ) ≤
      (S.ground.card : ℝ) * (S.ground.card - 1 : ℝ) / (d * (d - 1) : ℝ) := by
  sorry
```

**Proof Strategies:**

*Strategy A (Sunflower Cascade — Most Promising):*
1. Prove `d_uniform_min_obstruction_size` by showing that in a d-uniform system, any two obstructions share at most d-1 elements; if k_sat < d-1, some obstruction must have < d elements, contradicting uniformity.
2. For `sunflower_sharpness_bound`: Apply the Sunflower Lemma to show that density above the Erdős-Rado threshold forces a (d-1)-sunflower. The sunflower creates a "cascade constraint" — obstructing any petal element blocks the entire sunflower, compressing the transition window.
3. For `johnson_bound_obstruction_density`: Encode each obstruction as a binary vector of weight d. The no-sunflower condition implies minimum Hamming distance ≥ 2. Apply the Johnson bound for constant-weight codes.

*Strategy B (Second-Moment / Variance):*
- d-uniformity implies the random variable X = "number of obstructed clauses" has variance Var(X) ≤ E[X] (Poisson-type concentration). Lower variance → sharper threshold. This connects to the Friedgut–Kalai sharp threshold theorem but gives explicit bounds for the uniform case.

*Strategy C (Design-Theoretic):*
- A d-uniform system achieving maximum density without sunflowers is a Steiner system S(2, d, n). These exist only for specific n, and their transition behavior is maximally sharp among d-uniform systems. This gives a structural characterization of the "sharpest possible" transitions.

**Strategy A is most promising** because it directly leverages the catalog's `HasSunflower` infrastructure and produces explicit quantitative bounds.

**Cross-Domain Connections:**

1. **Coding Theory → Obstruction Systems:** The Johnson bound for constant-weight codes (weight d, minimum distance 2) directly bounds obstruction density. This is Theorem 3.

2. **Design Theory → Phase Transitions:** Steiner systems S(2,d,n) are extremal d-uniform obstruction systems. Their existence (only for certain n) explains why sharp thresholds are "fragile" — most parameter values don't admit perfect sharpness.

3. **Statistical Physics → Extremal Combinatorics:** The normalized window width is analogous to the correlation length in statistical mechanics. The sunflower sharpness bound is a discrete analogue of the correlation length bound in mean-field models.

**Testable Prediction (Falsifiable Conjecture):**

```python
# Conjecture: For n=20,30,40 and d=3, the ratio
#   (normalized_window_width_mixed) / (normalized_window_width_uniform)
# exceeds 1.3 with probability > 0.9 over random instances with matched density.
# Test: Generate 50 instances each, compute ratio, check if ≥ 45 exceed 1.3.
```

**Impact:** Explains why the triangle model (3-uniform) shows clean transitions, provides coding-theoretic bounds for certificate design, and opens a new connection between extremal set theory and phase transition sharpness.

**Catalog References:**
- `Pythagorean/CertificatePhaseTransition.lean`: `triangle_obstruction_size`, `exists_transition_window`
- `Catalog/Computation/Hypergraph/Defs.lean`: `HasSunflower` (partial)

**Mandatory Deliverables:**
(a) `FUTURE_DIRECTIONS.md` with 3-5 testable hypotheses
(b) `RESEARCH_PAPER.md` — standalone scientific document
(c) `ARTICLE.md` — Scientific American style
(d) Verified algorithm for computing normalized window widths
(e) `demo.py` demonstrating uniformity sharpness on synthetic instances

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
