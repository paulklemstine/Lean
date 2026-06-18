## Assignment: 2. Factored Bellman Residual Tensorization for Structured MDPs

**Mode**: prove

Prove a genuinely new theorem that turns abstract factorwise Bellman-growth machinery into a concrete tensorization principle for finite structured MDPs. The target is not “value iteration converges” — that is old. The target is a **dimension-breaking theorem**: in product-state MDPs with coordinatewise dynamics, Bellman residual control should scale with the number of factors, not with the cardinality of the full product state space. If formalized cleanly, this opens a route to certified dynamic programming on exponentially large state spaces via compositional verification.

### Exact breakthrough target

Let
- `ι : Type` be a finite index set of factors,
- each factor state space be `S i := Fin (n i)`,
- the global state space be `State := ∀ i : ι, S i`,
- rewards and transitions decompose coordinatewise (or admit a factorwise upper bound),
- `γ : ℝ` satisfy `0 ≤ γ ∧ γ < 1`.

Define the Bellman operator `T : (State → ℝ) → (State → ℝ)` for a finite discounted MDP, and define the sup-norm Bellman residual
\[
\mathrm{gap}(V) := \|T V - V\|_\infty.
\]

You should formalize and prove a theorem of the following shape:

> **Tensorized residual decay theorem.**  
> Assume the MDP is factorwise Bellman-improving in the sense that for each factor update operator `U_i`,
> \[
> \|T(U_i V) - U_i V\|_\infty \le \|T V - V\|_\infty - \beta_i
> \]
> whenever `gap V > 0`, for some nonnegative factor gains `β_i`, and assume these factor updates are compatible with the abstract coupling hypotheses of  
> `sum_residual_growth_of_factorwise_bellman_growth`.
> Then for one full sweep `U := U_{i_m} ∘ \cdots ∘ U_{i_1}`,
> \[
> \mathrm{gap}(U V) \le \mathrm{gap}(V) - \sum_i \beta_i,
> \]
> and hence after `t` sweeps,
> \[
> \mathrm{gap}(U^{[t]} V_0) \le \mathrm{gap}(V_0) - t \cdot \sum_i \beta_i
> \]
> until the residual reaches `0`, yielding finite-step convergence if the decrement is uniform.

This is the linear residual-decay form. If the abstract theorem instead gives an additive lower bound only under a positivity threshold, prove the thresholded version precisely and derive a corollary with
\[
\mathrm{gap}(U^{[t]} V_0) \le \max\bigl(0, \mathrm{gap}(V_0) - t\beta\bigr)
\]
for `β := ∑ i, β_i`.

### Stronger concrete finite-MDP specialization

Push beyond the abstract instantiation. Prove a specialization for **fully factorized discounted MDPs**:

- state space `State := ∀ i : ι, Fin (n i)`,
- action space either finite global actions or factorwise actions,
- reward decomposes as
  \[
  r(s,a) = \sum_i r_i(s_i,a_i),
  \]
- transition kernel factorizes as a product
  \[
  P(s' \mid s,a) = \prod_i P_i(s'_i \mid s_i,a_i).
  \]

Under these assumptions, prove that if the initial value function is additively separable,
\[
V_0(s) = \sum_i V_{0,i}(s_i),
\]
then coordinatewise Bellman updates preserve separability and the global residual is controlled by the sum of factor residuals:
\[
\mathrm{gap}(V) \le \sum_i \mathrm{gap}_i(V_i),
\]
with equality or two-sided comparison under stronger assumptions. Then derive a sweep-wise decay bound from factorwise contraction/improvement estimates.

This is the key scientific point: **the residual tensorizes**.

---

## Precise theorem statement candidates with Lean 4 type signatures

You may need to adapt names to existing files and imported APIs, but aim for statements in this shape.

### 1. Residual tensorization for separable values
```lean
theorem bellmanResidual_le_sumFactorResidual
  {ι : Type} [Fintype ι] [DecidableEq ι]
  (n : ι → ℕ)
  (γ : ℝ) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1)
  (R : (∀ i, Fin (n i)) → ℝ)
  (P : ((∀ i, Fin (n i)) × (∀ i, Fin (n i)) → ℝ))
  (T : ((∀ i, Fin (n i)) → ℝ) → ((∀ i, Fin (n i)) → ℝ))
  (Ti : ∀ i, (Fin (n i) → ℝ) → (Fin (n i) → ℝ))
  (V : (∀ i, Fin (n i)) → ℝ)
  (Vi : ∀ i, Fin (n i) → ℝ)
  (hVsep : V = fun s => ∑ i, Vi i (s i))
  (hTsep : ∀ W Wi, W = fun s => ∑ i, Wi i (s i) →
    T W = fun s => ∑ i, Ti i (Wi i) (s i)) :
  ‖fun s => T V s - V s‖∞ ≤ ∑ i, ‖fun si => Ti i (Vi i) si - Vi i si‖∞
```

If `‖·‖∞` is awkward on finite function spaces, define
```lean
def supGap {α : Type} [Fintype α] (f : α → ℝ) : ℝ := Finset.sup Finset.univ (fun a => f a) ...
```
or better, use `sSup` over finite range / `iSup` if a suitable normed instance is already available. A max-based finite definition may be easier in Lean.

### 2. One-sweep additive residual improvement
```lean
theorem factoredSweep_gap_le_gap_sub_sumBeta
  {ι : Type} [Fintype ι] [DecidableEq ι]
  {State : Type}
  (gap : (State → ℝ) → ℝ)
  (U : ι → (State → ℝ) → (State → ℝ))
  (β : ι → ℝ)
  (V : State → ℝ)
  (hβ : ∀ i, 0 ≤ β i)
  (hstep : ∀ i W, 0 < gap W → gap (U i W) ≤ gap W - β i) :
  gap ((Finset.univ.sort (· ≤ ·)).fold (fun W i => U i W) V) ≤
    gap V - ∑ i, β i
```

This may need a fixed list ordering on `ι`; if so, specialize first to `ι = Fin k`, which is perfectly acceptable and often preferable in Lean.

### 3. Iterated linear decay
```lean
theorem factoredSweep_gap_iterate_le
  {State : Type}
  (gap : (State → ℝ) → ℝ)
  (Sweep : (State → ℝ) → (State → ℝ))
  (β : ℝ)
  (V0 : State → ℝ)
  (hβ : 0 ≤ β)
  (hstep : ∀ W, 0 < gap W → gap (Sweep W) ≤ gap W - β) :
  ∀ t : ℕ, gap (Nat.iterate Sweep t V0) ≤ max 0 (gap V0 - t * β)
```

This theorem is likely the cleanest core result. Once proved, instantiate `β = ∑ i, β_i`.

### 4. Finite-step convergence corollary
```lean
theorem factoredSweep_eventually_zero_gap
  {State : Type}
  (gap : (State → ℝ) → ℝ)
  (Sweep : (State → ℝ) → (State → ℝ))
  (β : ℝ)
  (V0 : State → ℝ)
  (hβ : 0 < β)
  (hstep : ∀ W, 0 < gap W → gap (Sweep W) ≤ gap W - β) :
  ∃ t : ℕ, gap (Nat.iterate Sweep t V0) = 0
```

If exact equality to `0` is too strong from your hypotheses, weaken to `gap ≤ β` or derive exact zero under a discreteness/finite-range hypothesis on values.

---

## How to build on catalog theorems

The assignment explicitly points to the abstract Bellman corollary:

- `sum_residual_growth_of_factorwise_bellman_growth`

You should treat this as the primary engine. The mission is to **identify its hypotheses exactly**, then manufacture a concrete finite-MDP interface that satisfies them. Do not merely reprove the corollary in MDP language; instantiate it in a way that exposes new reusable definitions:
- factored state spaces,
- factor update operators,
- Bellman residual,
- sweep operator,
- residual decomposition lemmas.

Even though the listed verified theorems in the prompt are from unrelated files, the real building block is the Bellman residual growth theorem named above. Search for nearby lemmas in the same file:
- monotonicity or subadditivity of residual growth,
- telescoping-sum lemmas,
- iterate bounds,
- factorwise update composition lemmas.

The best result will be a **bridge theorem** from abstract residual algebra to finite MDP semantics.

---

## Proof strategy architecture

### Strategy A: Abstract-first instantiation via residual algebra
This is the most promising path.

1. **Define a finite residual functional**  
   Define `gap : (State → ℝ) → ℝ := max_{s} |T V s - V s|` on finite states. Prove basic facts:
   - `0 ≤ gap V`,
   - if `gap V = 0`, then `V` is a Bellman fixed point,
   - factorwise updates `U i` are well-defined endomorphisms on value functions.

2. **Package factorwise improvement hypotheses**  
   For each coordinate update operator `U i`, prove the exact hypothesis needed by `sum_residual_growth_of_factorwise_bellman_growth`, likely of the form:
   - residual decreases by at least `β i`,
   - or residual growth after composition is bounded by the sum of factor contributions.
   This may require a local lemma:
   ```lean
   theorem coordinate_update_factorwise_bellman_growth ...
   ```

3. **Apply the abstract corollary and derive iterate bounds**  
   Once the hypotheses match, obtain the sweep bound directly. Then prove the iterate theorem by induction on `t`, using a max-truncation lemma:
   \[
   x_{t+1} \le \max(0, x_t - \beta) \implies x_t \le \max(0, x_0 - t\beta).
   \]

**Why this is best:** it creates a reusable API that can later support approximate dynamic programming, block coordinate policy iteration, and compositional RL certificates. It also minimizes low-level probabilistic formalization if the Bellman operator is abstracted.

---

### Strategy B: Separable Bellman operator on product spaces
This is mathematically stronger and more novel if you can make it work.

1. **Formalize separability of rewards, transitions, and values**  
   Introduce a predicate:
   ```lean
   def SeparableValue (V : State → ℝ) : Prop := ∃ Vi, V = fun s => ∑ i, Vi i (s i)
   ```
   and analogous factorization hypotheses for reward/transition semantics.

2. **Prove Bellman preserves separability**  
   Show:
   ```lean
   SeparableValue V → SeparableValue (T V)
   ```
   and identify the induced factor Bellman operators `Ti`.

3. **Tensorize the residual**  
   Prove
   \[
   \mathrm{gap}(V) \le \sum_i \mathrm{gap}_i(V_i),
   \]
   using finite sup bounds and the inequality
   \[
   \max_s \left|\sum_i a_i(s_i)\right| \le \sum_i \max_{s_i} |a_i(s_i)|.
   \]
   Then factorwise decay lifts immediately to global decay.

**Why this is exciting:** it is a bona fide tensorization theorem, not just an instantiation of an abstract update principle. It begins to look like a dynamic-programming analogue of entropy tensorization and Dobrushin uniqueness.

---

### Strategy C: Nearly factored / perturbative theorem
This is riskier but potentially field-opening.

1. Start from a fully factorized MDP and define a perturbation parameter `ε` measuring deviation from product structure in reward or transition.
2. Prove an approximate tensorization:
   \[
   \mathrm{gap}(V) \le \sum_i \mathrm{gap}_i(V_i) + ε C(V),
   \]
   or a sweep bound with error floor:
   \[
   \mathrm{gap}(U^{[t]}V_0) \le \max(εC, \mathrm{gap}(V_0)-tβ).
   \]
3. Interpret this as robustness of compositional planning under weak coupling.

**Why this matters:** this is what applications actually need. Exact product MDPs are rare; weakly coupled systems are everywhere.

---

## Key lemmas Aristotle should likely prove first

1. **Finite sup triangle bound on product decompositions**
```lean
theorem supNorm_sum_le_sum_supNorm
  {ι : Type} [Fintype ι]
  {α : ι → Type} [∀ i, Fintype (α i)]
  (f : ∀ i, α i → ℝ) :
  (supGap fun s : ∀ i, α i => ∑ i, f i (s i))
    ≤ ∑ i, supGap (f i)
```

2. **Bellman residual of separable value equals residual of summed factor operators**
```lean
theorem bellmanResidual_of_separable
  ...
  (hTsep : ...) :
  gap V ≤ ∑ i, gap_i (Vi i)
```

3. **Sweep telescoping lemma**
```lean
theorem fold_updates_gap_le
  ...
  : gap (foldl U order V) ≤ gap V - ∑ i, β i
```

4. **Linear decay under iterate**
```lean
theorem iterate_subtractive_decay_le_max
  (x β : ℝ) (hβ : 0 ≤ β) :
  ...
```

These are reusable across dynamic programming, coordinate descent, and message passing.

---

## Cross-domain connections you should exploit explicitly

This project is bigger than MDPs. Frame and prove it so it becomes a reusable theorem schema.

- **Tensorization in probability / information theory**: The residual decomposition is analogous to tensorization of entropy, Poincaré constants, and transportation inequalities. If formalized well, this could seed a library of compositional inequalities in Lean.
- **Block coordinate descent in optimization**: Coordinatewise Bellman updates are dynamic-programming analogues of Gauss–Seidel / block descent. Your theorem should read like a nonconvex optimization descent theorem over product spaces.
- **Statistical physics / Gibbs systems**: Product-state MDPs with weak interactions resemble spin systems. Nearly factored Bellman decay mirrors correlation decay and Dobrushin-style contraction.
- **Formal verification / certified RL**: A provable residual decay rate depending on factor count rather than state-space cardinality is exactly the kind of certificate needed for scalable planning in compositional systems.
- **Category-theoretic compositionality**: If the theorem is packaged abstractly enough, Bellman operators become compositional morphisms over product objects. Even if you do not formalize the category theory now, structure the definitions so this future lift is possible.

This is the kind of theorem that can make formalized reinforcement learning mathematically respectable: not another implementation of value iteration, but a theorem saying compositional structure really breaks the curse of dimensionality at the proof level.

---

## Application keywords

factored MDPs; Bellman residual; tensorization; coordinate descent; compositional dynamic programming; certified reinforcement learning; product state spaces; Gauss–Seidel value iteration; weakly coupled systems; residual decay; formal verification; curse of dimensionality; entropy-style inequalities; scalable planning

---

## Implementation guidance in Lean 4

- Prefer `ι = Fin k` for the first successful theorem. Generalizing to arbitrary finite `ι` can come later.
- For the state space, `State := ∀ i : Fin k, Fin (n i)` is often easier than nested products.
- Be careful with sup norm formalization. On finite spaces, a custom `max`/`Finset.sup` residual definition may be dramatically easier than importing the full functional analysis stack.
- Separate the project into:
  1. finite function norm / residual utilities,
  2. abstract factor-update decay lemmas,
  3. MDP specialization,
  4. separable/tensorized corollaries.
- Minimize sorry by proving a weaker but clean theorem first:
  - abstract iterate linear decay,
  - then one-sweep additive decrement,
  - then separable MDP specialization.

---

## Concrete deliverables

1. A Lean theorem formalizing one of the precise signatures above, ideally `factoredSweep_gap_iterate_le` plus one MDP-specific instantiation.
2. A reusable definition of finite Bellman residual on finite state spaces.
3. At least one theorem connecting separability of values and factorization of Bellman updates to a sum bound on residuals.
4. Minimal sorry count, with any remaining sorry isolated to auxiliary finite-max lemmas rather than the main theorem.

---

## FUTURE_DIRECTIONS.md requirement

Produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level, not incremental variants. Include items of the following caliber:

1. **Approximate tensorization for weakly coupled MDPs** with explicit `ε`-error floors.
2. **Policy iteration analogue**: factorwise policy improvement with sweep-wise residual or suboptimality decay.
3. **Entropy/Bellman bridge theorem**: formal analogy between Bellman residual tensorization and entropy tensorization.
4. **Compositional POMDP extension**: belief-state factorization and residual decay in partially observed systems.
5. **Mean-field limit theorem**: asymptotic residual laws as the number of factors grows.

Make these specific, with proposed theorem statements, not vague aspirations.

Be bold: the goal is to turn Bellman residual analysis into a compositional science of dynamic programming.

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
