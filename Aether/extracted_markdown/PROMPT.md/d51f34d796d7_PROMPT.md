## Assignment: Proofs

Prove new, non-trivial theorems in Lean 4, bottom-up from helper lemmas that actually compose into a field-opening bridge theorem. Minimize sorry. Do not settle for isolated inequalities; extract a structural principle that links prediction, evidence aggregation, coherence, and nonlocality.

### Mode
**prove**

### Research Direction
Build a **cross-domain impossibility/compatibility theorem** showing that bounded classical evidence/coherence mechanisms cannot simulate Bell-CHSH level nonlocal correlations beyond the classical threshold. The point is not physics alone: it is to formalize, in one Lean development, that three seemingly separate notions already present in the catalog — evidence bounds, regret/coherence bounds, and Bell locality bounds — are facets of a single “classical information budget.”

This is the kind of theorem that opens a new formal field: **resource-bounded logical foundations of nonlocality**.

### Mathematical Framing
You already have:

- `evidence_upper_bound` in `Logic/AdvancedTheorems.lean`
- `expert_regret_bound_nonneg` in `Logic/AdversarialPrediction.lean`
- `coherence_bounded` in `Logic/CoherenceStratification.lean`
- `info_lower_bound` in `Logic/CoherenceStratified.lean`
- `bell_chsh_bound` in `Logic/EntanglementNetwork.lean`

The breakthrough move is to prove that these are not unrelated estimates, but instances of a common monotonicity principle: **classical bounded resources induce classical correlation ceilings**.

You should formalize this through a new layer of definitions and bridge lemmas, culminating in a theorem of the following flavor:

> Any local model whose effective evidence/coherence score is classically bounded cannot exceed the CHSH classical limit, and any attempt to exceed that limit forces a lower bound on information/coherence resources incompatible with the bounded regime.

That is stronger and more visionary than just reproving `bell_chsh_bound`: it turns Bell locality into a theorem about information budgets and online prediction structure.

---

## Primary Target Theorem

Define a classical resource score combining evidence and coherence. The exact definition may vary depending on the existing structures, but it should be concrete and Lean-friendly.

A recommended path is to introduce:

```lean
def classicalResourceScore (H : ℝ) (k n : ℕ) : ℝ :=
  H + (Nat.log 2 (2 ^ k) : ℝ) + n
```

or a normalized variant if cleaner for inequalities. Then prove a theorem showing that if coherence and information are bounded in the catalog sense, then Bell-CHSH remains classically bounded.

### Precise theorem statement
A clean first bridge theorem should be:

```lean
theorem classical_resource_controls_chsh
    {n k : ℕ} (H : ℝ) (hn : 0 < n)
    (L : LocalModel n) (i j : Fin n) :
    H ≤ 1 →
    (coherence_bounded H n hn) →
    (k : ℝ) ≤ (Nat.log 2 (2 ^ k) : ℝ) + 1 →
    |L.chsh i j| ≤ 2 := by
```

This exact signature may need adaptation to the actual API of `LocalModel` and the output type of `bell_chsh_bound`, but the mathematical content should be preserved:

- hypotheses express bounded coherence/information,
- conclusion is the classical CHSH ceiling.

If `bell_chsh_bound` already directly gives `|L.chsh i j| ≤ 2`, then the real theorem should package the bridge:

```lean
theorem bounded_coherence_implies_classical_chsh
    {n : ℕ} (H : ℝ) (hn : 0 < n)
    (L : LocalModel n) (i j : Fin n)
    (hcoh : H ≤ 1) :
    |L.chsh i j| ≤ 2 := by
```

with proof explicitly routed through `coherence_bounded` and `bell_chsh_bound`, not merely calling the latter. The theorem should expose a conceptual dependency, even if technically the final Bell step is immediate.

---

## Stronger Secondary Target

Prove a contrapositive/incompatibility theorem. This is likely the most conceptually important statement.

### Precise theorem statement
```lean
theorem chsh_violation_requires_resource_escape
    {n k : ℕ} (H : ℝ) (hn : 0 < n)
    (L : LocalModel n) (i j : Fin n) :
    2 < |L.chsh i j| →
    ¬ (H ≤ 1 ∧ (k : ℝ) ≤ (Nat.log 2 (2 ^ k) : ℝ) + 1) := by
```

Interpretation: super-classical CHSH violation forces escape from the jointly bounded classical evidence/coherence/information regime.

If `LocalModel` by definition already forbids CHSH violation, then you should instead formulate the theorem abstractly over any candidate score `s : ℝ` and show that **assuming locality plus bounded resources yields contradiction with CHSH violation**. The point is to formalize the incompatibility theorem, not to get trapped by a too-rigid existing structure.

---

## Bottom-Up Helper Lemmas

You were instructed to prove helper lemmas bottom-up. Do that aggressively. The bridge theorem should rest on a ladder like this:

### Arithmetic / coercion lemmas
These are often what make ambitious Lean developments succeed.

```lean
lemma nat_log_pow_two_real_upper (k : ℕ) :
    (k : ℝ) ≤ (Nat.log 2 (2 ^ k) : ℝ) + 1 := by
  exact_mod_cast info_lower_bound k
```

or a variant with explicit coercion management.

```lean
lemma coherence_real_upper (H : ℝ) (n : ℕ) (hn : 0 < n) :
    H ≤ 1 := by
  -- derive from coherence_bounded if that theorem returns an upper bound of this form
```

### Structural packaging lemmas
Introduce a predicate:

```lean
def ClassicallyBounded (H : ℝ) (k n : ℕ) : Prop :=
  H ≤ 1 ∧ (k : ℝ) ≤ (Nat.log 2 (2 ^ k) : ℝ) + 1
```

Then prove:

```lean
lemma classicallyBounded_of_catalog
    (H : ℝ) (k n : ℕ) (hn : 0 < n) :
    ClassicallyBounded H k n := by
```

if derivable, or a weaker existential/conditional form if not.

### Bell bridge lemma
```lean
lemma classicallyBounded_implies_chsh_bound
    {n k : ℕ} (H : ℝ) (L : LocalModel n) (i j : Fin n)
    (hcb : ClassicallyBounded H k n) :
    |L.chsh i j| ≤ 2 := by
  exact bell_chsh_bound L i j
```

This may look simple, but it is the semantic hinge: package the resource side and Bell side into one theorem so future cycles can generalize from local models to approximate-local or adversarial models.

---

## Lean 4 Type Signature Guidance

Because the catalog theorem signatures are partially hidden, write definitions and theorems in a way that is robust to API variation. Prefer concrete signatures like:

```lean
def ClassicallyBounded (H : ℝ) (k n : ℕ) : Prop :=
  H ≤ 1 ∧ k ≤ Nat.log 2 (2 ^ k) + 1
```

Then derive real-valued versions only when needed:

```lean
lemma ClassicallyBounded.real_info
    {H : ℝ} {k n : ℕ} (h : ClassicallyBounded H k n) :
    (k : ℝ) ≤ (Nat.log 2 (2 ^ k) : ℝ) + 1 := by
  exact_mod_cast h.2
```

If `bell_chsh_bound` is stated without absolute values or with a specific CHSH expression, adapt by proving a wrapper theorem with the desired semantic statement. That wrapper itself is a valuable catalog contribution.

---

## Proof Strategies

### Strategy A: Direct bridge through packaged predicates
1. Define `ClassicallyBounded` from coherence/information inequalities.
2. Prove helper lemmas converting `coherence_bounded` and `info_lower_bound` into membership in `ClassicallyBounded`.
3. Use `bell_chsh_bound` to conclude the CHSH ceiling under that packaged assumption.

**Why this is promising:** it is the cleanest Lean architecture and creates reusable interfaces for later work on approximate locality, adversarial prediction, and resource theories.

### Strategy B: Contrapositive impossibility theorem
1. Assume a CHSH violation `2 < |...|`.
2. Use `bell_chsh_bound` to derive contradiction under locality.
3. Reframe contradiction as failure of bounded classical resource assumptions.

**Why this is promising:** contrapositive statements are often more scientifically meaningful. They turn an upper bound into a no-go theorem, which is exactly the sort of result that can seed a new formal subfield.

### Strategy C: Prediction-theoretic reinterpretation
1. Define a “classical prediction score” using evidence/regret/coherence data.
2. Show this score is bounded using `evidence_upper_bound`, `expert_regret_bound_nonneg`, and `coherence_bounded`.
3. Prove that any local Bell strategy induces such a bounded score, hence obeys the CHSH ceiling.

**Why this is most revolutionary:** it connects online learning and Bell nonlocality. Even if the first Lean theorem is modest, this is the direction with the highest scientific upside. It suggests that nonlocality can be understood as failure of classical regret-minimizing prediction architectures.

---

## Cross-Domain Connections

You must explicitly build at least one of these into the file comments and theorem naming:

### 1. Online learning ↔ quantum nonlocality
`expert_regret_bound_nonneg` suggests a resource monotonicity principle from adversarial prediction. A local hidden-variable model can be viewed as a classical expert ensemble; the CHSH bound then becomes a regret-limited prediction ceiling. This is conceptually fresh and formalization-ready.

### 2. Information theory ↔ coherence stratification
`info_lower_bound` and `coherence_bounded` together hint at a stratified resource theory: coherence controls admissible information compression, and Bell violation requires escaping that compression regime.

### 3. Logic/evidence aggregation ↔ foundations of physics
`evidence_upper_bound` can be interpreted as a logical evidence budget. A major theorem here would say: **bounded logical evidence aggregation is incompatible with super-classical correlation synthesis**. That is a new bridge between epistemic logic and nonlocality.

### 4. Complexity theory keywords
If you can define a finite search space of classical strategies using `Fin n`, there is a latent computational interpretation: Bell locality as a bounded certificate system, with coherence/information bounds acting like proof-length constraints.

---

## Application Keywords

Include these in comments, documentation, or `FUTURE_DIRECTIONS.md`:

- formalized nonlocality
- Bell inequalities
- online learning
- adversarial prediction
- information budget
- coherence resource theory
- epistemic logic
- hidden-variable models
- proof complexity
- computational foundations of quantum theory

---

## Concrete Work Plan

### Phase 1: Catalog digestion and wrapper lemmas
Inspect the exact conclusions of:

- `evidence_upper_bound`
- `coherence_bounded`
- `bell_chsh_bound`

Then prove wrapper lemmas with standardized inequality forms and explicit coercions. This phase should eliminate friction later.

### Phase 2: Define the bridge predicate
Introduce one or both:

```lean
def ClassicallyBounded (H : ℝ) (k n : ℕ) : Prop := ...
def ResourceCompatibleCHSH {n : ℕ} (L : LocalModel n) : Prop := ...
```

The definition should be simple enough to use now, but expressive enough to support later generalization.

### Phase 3: Main theorem and contrapositive
Prove:

- `bounded_coherence_implies_classical_chsh`
- `chsh_violation_requires_resource_escape`

If one direction is blocked by the existing API, prove the strongest formally correct variant and document the stronger conjectural statement in `FUTURE_DIRECTIONS.md`.

### Phase 4: Optional strengthening
Try to integrate `evidence_upper_bound` and `expert_regret_bound_nonneg` into a single theorem asserting nonnegativity/boundedness of a composite classical score. Even a first theorem here could be very valuable:

```lean
theorem classical_prediction_score_nonnegative
    (n T : ℕ) (hn : 0 < n) (hT : 0 < T) :
    0 ≤ classicalPredictionScore n T := by
```

with the score built from existing catalog quantities.

---

## Standards for Non-Triviality

Do **not** stop at proving a theorem that is merely a direct restatement of `bell_chsh_bound`. The non-triviality requirement is met only if you do at least one of:

1. Introduce a new predicate/structure linking catalog domains.
2. Prove a contrapositive impossibility theorem.
3. Derive a new wrapper theorem whose statement exposes a new scientific interpretation.
4. Combine at least two catalog theorems in one proof chain.

---

## Deliverables

1. Lean 4 file(s) with:
   - new definitions,
   - helper lemmas,
   - one main bridge theorem,
   - one stronger corollary or contrapositive theorem.

2. Minimized `sorry`s; if blocked by exact API mismatches, isolate them in the thinnest possible wrappers.

3. `FUTURE_DIRECTIONS.md` with **3–5 concrete next theorems**, each including:
   - precise theorem statement,
   - likely Lean definitions needed,
   - 2 proof strategies,
   - cross-domain significance.

---

## Required FUTURE_DIRECTIONS.md Content

You must propose specific next steps at breakthrough level, for example:

1. **Approximate locality theorem**  
   Formalize an `ε`-local model and prove a quantitative bound
   `|CHSH| ≤ 2 + C*ε`.

2. **Prediction/nonlocality equivalence theorem**  
   Define a finite expert class associated to a local model and prove that Bell locality implies a regret bound, or conversely that regret-optimal classical predictors induce Bell-classical correlations.

3. **Information lower bound for CHSH violation**  
   Prove that any abstract strategy family achieving `2 < |CHSH|` requires information budget strictly above a classically bounded threshold.

4. **Coherence stratification of correlation models**  
   Define levels of coherence and prove monotonicity of attainable correlation strength across strata.

5. **Proof-complexity interpretation**  
   Encode local hidden-variable assignments as certificates and prove that bounded certificate complexity implies Bell-classical behavior.

Make these theorem statements as explicit as possible.

---

## Final Directive

Think like a founder of a new subject, not a maintainer of old lemmas. The target is a formal theorem schema saying:

> bounded classical evidence + bounded coherence + bounded information ⇒ classical correlation ceiling.

If proved cleanly in Lean, this becomes a seed for a formal resource theory of nonlocality, with direct extensions to learning theory, logic, and computational complexity.

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

Research domain: Logic
Research mode: prove
