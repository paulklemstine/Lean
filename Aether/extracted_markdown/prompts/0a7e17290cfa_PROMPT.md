## Assignment: Direction 2: Algorithmic Overlap-Adaptive Rounding

Prove a genuinely new theorem package around **data-driven rounding for bounded-overlap hypergraph transversals**, where the algorithm does **not** take the overlap bound `K` as input but **extracts an effective overlap parameter from the LP optimum itself**. The goal is not to repackage known threshold rounding, but to create a new formal bridge between **combinatorial optimization**, **energy methods**, and **instance-optimal approximation**.

You should treat this as a **prove + discover** project: prove the strongest theorem you can, but also isolate the right new definitions so that the theory becomes extensible.

---

## Central Vision

The classical bounded-codegree story says: if a `d`-uniform hypergraph has pairwise overlap at most `K`, then one can do better than naive `d`-approximation. But real instances rarely come with `K` written on them. The mathematically bolder question is:

> Can the LP solution itself reveal how aggressively we are allowed to round?

This is the conceptual leap. The fractional optimum is not just a lower bound; it is a **measurement device**. Its pair-overlap energy should act as a self-calibrating statistic that detects latent sparsity/overlap structure. If formalized correctly, this yields one of the first **overlap-adaptive approximation guarantees** for hypergraph transversal.

This would open a new line of work: **approximation algorithms whose guarantees are certified by low-order energy observables of the LP optimum**, rather than by external structural parameters.

---

## Precise Mathematical Target

Let `H = (V, E)` be a finite `d`-uniform hypergraph, and let `x* : V → ℝ≥0` be an optimal fractional transversal:
- `∀ e ∈ E, ∑ v∈e, x*(v) ≥ 1`,
- `τ*(H) = ∑ v, x*(v)`.

Let the **pair-overlap energy** of a fractional vector `x` be
\[
\mathcal E_H(x) := \sum_{\{u,v\}\subseteq V} c_H(u,v)\, x(u)x(v),
\]
where `c_H(u,v)` is the number of edges containing both `u` and `v)`.

Define the **normalized overlap diagnostic**
\[
\rho_H(x) := \frac{\mathcal E_H(x)}{\left(\sum_v x(v)\right)^2},
\]
when `∑ v x(v) > 0`.

The breakthrough theorem you should aim for is a rigorous version of:

> **Adaptive Rounding Theorem.**  
> There exist absolute constants `c, C > 0` and a deterministic polynomial-time rounding algorithm `A` such that for every finite `d`-uniform hypergraph `H` and every optimal fractional transversal `x*`, if `Δ₂(H) ≤ K`, then `A(H, x*)` outputs an integral transversal `T ⊆ V` satisfying
> \[
> |T| \le \left(d - c \cdot \Phi(\rho_H(x^*))\right)\tau^*(H) + C\Psi(\rho_H(x^*)),
> \]
> for explicit monotone functions `Φ, Ψ`, and in particular
> \[
> |T| \le \left(d - \Omega(1/K)\right)\tau^*(H) + O(K).
> \]
> Moreover, `A` does not take `K` as input; it computes its threshold directly from `x*` and `\rho_H(x*)`.

A strong and more Lean-friendly first target is to prove a theorem with a concrete but perhaps weaker bound, e.g.
\[
|T| \le d\,\tau^*(H) - c\cdot \frac{\tau^*(H)}{1+\widehat K(x^*)} + C(1+\widehat K(x^*)),
\]
where `\widehat K(x*)` is an algorithmically extracted overlap estimator derived from the energy bound. Then derive the `Δ₂(H) ≤ K` corollary using the catalog theorem controlling energy by codegree.

---

## Lean 4 Formalization Targets

You should introduce a new definition encapsulating the adaptive statistic and the algorithmic threshold choice.

Possible Lean-facing signatures, to be adapted to actual catalog structures:

```lean
def pairOverlapDiagnostic
  (H : WeightedHypergraph α) (x : α → ℚ) : ℚ := ...

def adaptiveThreshold
  (d : ℕ) (ρ : ℚ) : ℚ := ...

def adaptiveRoundedSet
  (H : WeightedHypergraph α) (x : α → ℚ) : Finset α := ...

def IsTransversal
  (H : WeightedHypergraph α) (T : Finset α) : Prop := ...

theorem adaptiveRoundedSet_isTransversal
  (H : WeightedHypergraph α) (x : α → ℚ)
  (hx : IsFractionalTransversal H x)
  (h_unif : H.IsUniform d)
  :
  IsTransversal H (adaptiveRoundedSet H x) := ...

theorem pairOverlapDiagnostic_le_of_pairCodegreeBounded
  (H : WeightedHypergraph α) (x : α → ℚ)
  (hK : H.PairCodegreeBounded K)
  (hx_nonneg : ∀ a, 0 ≤ x a)
  :
  pairOverlapDiagnostic H x ≤ K := ...

theorem adaptive_rounding_bound
  (H : WeightedHypergraph α) (x : α → ℚ)
  (hx : IsOptimalFractionalTransversal H x)
  (h_unif : H.IsUniform d)
  :
  (adaptiveRoundedSet H x).card
    ≤ d * fractionalWeight x
      - improvementTerm d (pairOverlapDiagnostic H x)
      + additiveSlack (pairOverlapDiagnostic H x) := ...

theorem adaptive_rounding_bound_of_pairCodegreeBounded
  (H : WeightedHypergraph α) (x : α → ℚ)
  (hx : IsOptimalFractionalTransversal H x)
  (h_unif : H.IsUniform d)
  (hK : H.PairCodegreeBounded K)
  :
  (adaptiveRoundedSet H x).card
    ≤ d * fractionalWeight x
      - improvementTerm d K
      + additiveSlack K := ...
```

If the catalog uses `ℝ`, `NNReal`, or finitely supported functions instead of `α → ℚ`, follow the local architecture. The important point is to formalize the **diagnostic**, the **adaptive threshold rule**, and the **guarantee** as separate reusable objects.

---

## New Definitions You Must Introduce

At least one of the following should be created as a novel concept:

1. **Overlap diagnostic**
   ```lean
   def pairOverlapDiagnostic ...
   ```
   A normalized energy statistic extracted from a fractional solution.

2. **Adaptive threshold policy**
   ```lean
   def adaptiveThreshold ...
   ```
   A threshold chosen from the diagnostic, interpolating between conservative and aggressive rounding.

3. **Certified adaptive rounding output**
   ```lean
   def adaptiveRoundedSet ...
   ```
   The deterministic rounded transversal built from the threshold.

4. **Effective overlap parameter**
   ```lean
   def effectiveOverlap ...
   ```
   A quantity inferred from energy and LP mass that acts as a surrogate for unknown `K`.

These are not cosmetic. They are the conceptual nucleus of the project.

---

## Theorems to Prove

You must prove at least **3 substantial theorems** with real proof structure. Suggested theorem package:

### Theorem 1: Diagnostic upper bound from codegree control
A formal extension of the catalog energy inequality to the normalized diagnostic.

**Statement**
If `H` has pair codegree bounded by `K`, then every nonnegative fractional vector satisfies
\[
\mathcal E_H(x) \le K \Big(\sum_v x(v)\Big)^2,
\qquad
\rho_H(x) \le K.
\]

**Lean sketch**
```lean
theorem pairOverlapDiagnostic_le_of_pairCodegreeBounded
  ...
```

**Why it matters**
This theorem turns a structural hypothesis into a quantity the algorithm can estimate directly from the LP optimum. It is the certification layer that allows the algorithm to be oblivious to `K`.

---

### Theorem 2: Adaptive threshold yields a valid transversal
Prove that your threshold choice always covers every edge.

A model deterministic rule is:
- include all vertices with `x(v) ≥ θ`,
- then greedily patch uncovered edges.

Or, if catalog machinery supports it, define a two-phase procedure:
1. threshold at `θ = adaptiveThreshold d ρ`,
2. augment by choosing one vertex from each uncovered edge.

**Statement**
For every fractional transversal `x`, the adaptively rounded set is a transversal.

**Lean sketch**
```lean
theorem adaptiveRoundedSet_isTransversal
  ...
```

**Expected proof style**
Not trivial: unpack uncovered-edge contradiction, use the LP covering inequality on each edge, and show the threshold/patching rule eliminates all failures.

---

### Theorem 3: Quantitative adaptive approximation bound
This is the main event.

Prove a theorem of the form:
\[
|T_{\mathrm{ad}}| \le d\,\tau^*(H) - \Gamma(d,\rho_H(x^*)) + \Lambda(d,\rho_H(x^*)),
\]
with explicit formulas.

A very plausible first formal target is a piecewise theorem:
- if `ρ_H(x*) ≤ ρ₀`, aggressive thresholding gives improved multiplicative constant,
- otherwise conservative thresholding still gives the baseline bound.

For example:
\[
|T| \le
\begin{cases}
(d-\eta)\tau^*(H) + C & \text{if } \rho_H(x^*) \le \rho_0,\\
d\,\tau^*(H) & \text{otherwise.}
\end{cases}
\]
Then use `ρ_H(x*) ≤ K` to rewrite the first branch as a `K`-dependent improvement when `K` is small.

**Lean sketch**
```lean
theorem adaptive_rounding_piecewise_bound
  ...
```

This theorem should require nontrivial inequalities, case splits, and multi-step estimates.

---

### Theorem 4: Corollary with unknown-K guarantee
Derive the external-parameter-free guarantee:

```lean
theorem adaptive_rounding_bound_of_pairCodegreeBounded
  ...
```

This is the theorem that expresses the project’s philosophical core: the algorithm never receives `K`, but still earns a guarantee in terms of `K`.

---

### Theorem 5: Cross-domain theorem
You are required to include at least one theorem bridging to another domain.

A particularly natural bridge is to **operations research / online optimization** via integrality-gap certification:

> The adaptive overlap diagnostic gives an a posteriori certificate on instance difficulty: lower diagnostic implies smaller integrality gap for the threshold-plus-patching family.

Formal target:
\[
\rho_H(x^*) \le \rho_0 \implies \tau(H) \le (d-\eta)\tau^*(H)+C.
\]

This is a theorem in approximation theory, but conceptually it bridges to **algorithm selection** and **instance-sensitive optimization**.

An even bolder bridge is to **statistical physics**:
interpret `\mathcal E_H(x)` as a two-body interaction energy, and prove a monotonicity theorem that lower interaction energy improves deterministic rounding efficiency. Even if only formalized combinatorially, this language opens a bridge to mean-field methods.

Possible Lean theorem:
```lean
theorem low_energy_improves_integrality_gap
  ...
```

---

## Proof Strategy Architecture

You must present and pursue at least 2–3 proof paths. Here are the most promising ones.

### Strategy A: Threshold + patching via edge deficit accounting
1. Define `Tθ := {v | x(v) ≥ θ}`.
2. Show every uncovered edge must have all vertex weights `< θ`, so its total LP mass is `< dθ`.
3. Choose `θ < 1/d` so uncovered edges are quantitatively constrained.
4. Bound the number or structure of uncovered edges using pair-overlap energy.
5. Patch uncovered edges greedily and control patch cost by the energy diagnostic.

**Why promising**
This is the cleanest route to a deterministic algorithm and aligns directly with the catalog threshold machinery.

---

### Strategy B: Charge uncovered edges to pair interactions
1. Associate to each uncovered edge a deficit `1 - ∑_{v∈e∩Tθ} x(v)` or a witness pair.
2. Use bounded pair codegree to prevent too many uncovered edges from charging the same pair.
3. Sum these charges and compare with `\mathcal E_H(x)`.
4. Convert the energy bound into an additive patch-cost estimate.

**Why promising**
This directly leverages `pairOverlapEnergy_le_of_pairCodegreeBounded` and is likely the best path to the adaptive guarantee. It turns overlap energy into a **budget** that pays for the repair phase.

---

### Strategy C: Potential-minimization / primal-dual reinterpretation
1. Define a potential combining selected mass and residual uncovered-edge penalty.
2. Show the adaptive threshold approximately minimizes this potential among a family of thresholds.
3. Use energy bounds to show the chosen threshold lies in an improvement regime.
4. Extract a deterministic approximation theorem.

**Why promising**
This is conceptually deepest and best for the paper, because it reframes the algorithm as a principled optimization rule rather than a hand-tuned threshold. It may be harder to formalize fully, but even a partial theorem here would be field-opening.

**Recommendation**
Use **Strategy B** as the formal backbone, with **Strategy A** as the implementation layer and **Strategy C** as the conceptual narrative in the paper.

---

## Catalog Building Blocks

You should explicitly build on:

- `Catalog/Pythagorean/QuantitativeCodegreeGap.lean`
  - especially the energy inequality and threshold-gap estimates;
  - use the theorem analogous to `pairOverlapEnergy_le_of_pairCodegreeBounded` as the core certification step;
  - if there is a threshold theorem already there, abstract its constants and replace external `K` by your inferred diagnostic.

- `Catalog/Pythagorean/WeightedHypergraphTransversal.lean`
  - use weighted fractional-transversal infrastructure;
  - if weighted threshold rounding exists, lift it to an adaptive threshold policy;
  - reuse any existing notions of feasible cover/transversal rather than rebuilding them.

Do not merely cite these files. Explain in code comments and in the paper exactly how the catalog theorem is transformed:
- structural bound on codegree
  → energy bound,
- energy bound
  → overlap diagnostic upper bound,
- diagnostic
  → threshold choice,
- threshold choice
  → approximation guarantee.

---

## Cross-Domain Connections

You must explicitly emphasize at least one of these bridges.

### 1. Operations Research
The diagnostic is an **instance-sensitive certificate** for set cover / hitting set difficulty. This suggests LP-driven solver policies for column generation and branch-and-price.

### 2. Online Scheduling
Bounded overlap models shared resource contention. The adaptive threshold becomes a static analog of **load-aware admission control**.

### 3. Statistical Physics
`pairOverlapEnergy` behaves like a two-body interaction Hamiltonian; low interaction energy corresponds to weakly coupled constraints. Adaptive rounding then resembles a deterministic low-temperature selection rule.

### 4. Learning Theory / Algorithm Selection
The diagnostic is a low-dimensional feature of the LP optimum that predicts algorithmic performance. This opens a route toward **provably justified per-instance algorithm configuration**.

At least one theorem or formal remark should make one of these bridges mathematically explicit.

---

## Computational Deliverable: Verified Algorithm

You must implement a deterministic adaptive algorithm, not just prove existential statements.

Suggested algorithm:

1. Solve or receive a fractional transversal `x`.
2. Compute
   \[
   M := \sum_v x(v), \qquad
   E := \mathcal E_H(x), \qquad
   \rho := E / M^2.
   \]
3. Set threshold
   \[
   \theta(\rho) := \max\!\left(\frac{1}{d}-\frac{c}{1+\rho},\, \theta_{\min}\right)
   \]
   or a piecewise simpler variant justified by your proofs.
4. Select `T₀ = {v : x(v) ≥ θ(\rho)}`.
5. Patch uncovered edges greedily or by selecting a heaviest residual vertex.
6. Return `T`.

The exact formula may change based on what you can prove cleanly in Lean. But the algorithm must be:
- explicit,
- deterministic,
- polynomial-time,
- accompanied by a formal guarantee.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture in the code comments and in the paper.

### Conjecture: Smooth adaptive improvement law
There exists an absolute constant `c > 0` such that for every `d`-uniform hypergraph and every optimal fractional transversal `x*`,
\[
\tau_{\mathrm{ad}}(H;x^*) \le \left(d - \frac{c}{1+\rho_H(x^*)}\right)\tau^*(H) + O(1+\rho_H(x^*)).
\]

This is falsifiable computationally:
- generate random `d`-uniform hypergraphs with controlled pair codegree,
- compute LP optimum,
- run adaptive rounding,
- fit empirical approximation ratio against `1/(1+\rho)`.

A disproof would appear as a family where the ratio fails to improve as `ρ` decreases.

A second, sharper conjecture if your experiments support it:

### Conjecture: Monotone diagnostic-performance principle
Among random `d`-uniform instances with fixed `|V|, |E|`, the approximation ratio of adaptive rounding is stochastically nonincreasing as `ρ_H(x*)` decreases.

This would be a new algorithmic law: **energy predicts integrality gap**.

---

## Demo / Experimental Requirements

Implement `demo.py` to compare:
- adaptive rounding,
- classical threshold rounding,
- randomized rounding,
- LP optimum.

Test on random instances with:
- `K = 1, 2, 5, 10`,
- `d = 3, 4, 5`.

Report:
- average ratio `|T| / τ*(H)`,
- variance,
- frequency adaptive beats baseline threshold,
- frequency adaptive beats randomized,
- empirical correlation between `ρ_H(x*)` and approximation ratio.

The conjecture predicts:
- strongest gains for small `K`,
- but more importantly, stronger gains for small **measured** `ρ_H(x*)`, even when `K` is hidden.

---

## Mandatory Deliverables

You must produce all of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- statistical physics of constraint systems,
- learning-guided algorithm selection,
- online resource allocation.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document that explains:
- the new adaptive diagnostic,
- the algorithm,
- the formal theorems,
- why instance-sensitive approximation is a new paradigm,
- what comes next.

Someone reading only this paper must understand the discovery without any access to code.

### 3. `ARTICLE.md`
Write in Scientific American style:
- vivid,
- idea-driven,
- broad-audience accessible.

Do **not** focus on formal verification machinery. Focus on the mathematical idea that an optimization problem can “measure its own hidden geometry” and adapt accordingly.

### 4. Verified algorithm / computational method
Not just theorem statements. Provide the actual adaptive rounding procedure and prove its key guarantees.

### 5. `demo.py`
Interactive or script-based demonstration comparing adaptive and baseline methods on random instances.

---

## Application Keywords

Use these throughout the paper and metadata:
- instance-optimal approximation
- hypergraph transversal
- overlap-adaptive rounding
- LP-guided algorithms
- pair-overlap energy
- codegree diagnostics
- deterministic approximation
- integrality gap certification
- operations research
- online scheduling
- statistical physics
- algorithm selection
- combinatorial optimization

---

## Standard of Ambition

Do not settle for “a variant of threshold rounding.” The point is to formalize a new principle:

> **Low-order energy statistics of the LP optimum can drive deterministic approximation algorithms with structural guarantees, even when the structural parameter itself is unknown.**

If you can make that principle precise in Lean, with a working algorithm and experiments, this is not just a good extension. It is the beginning of a new language for approximation theory.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
