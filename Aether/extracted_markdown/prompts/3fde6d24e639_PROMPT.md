Soli Deo Gloria

## Assignment: Direction 5: Tropical Margin for Structured (Non-Independent) Matrices

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, `rcases`, `by_contra`, `field_simp`,
   or multi-step `calc` reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your
   domain to a different mathematical domain (e.g., number theory + tropical
   geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

---

## Mode: prove

## Title
**Tropical Margin Universality for Symmetric Wigner-Type Matrices**

## Vision

Push tropical universality beyond the independent-entry world into the first truly structured random-matrix regime: **symmetric Wigner-type matrices**. This is not a cosmetic extension. It is the point where tropical optimization, extreme-value theory, and random matrix physics first genuinely meet.

The core scientific claim is that the tropical margin does **not care** about full entrywise independence; it is governed by a more robust local exchange geometry. If this is true, then tropical phase transitions belong to the same universality culture as classical spectral statistics: symmetry constraints alter centering constants, but not the leading-order scale.

That would open a new field: **tropical random matrix theory** for dependent ensembles.

---

## Core mathematical object to introduce

Define a new structure capturing symmetric matrices together with their exchange-slack geometry.

### New definition 1: symmetric exchange slack
For a real symmetric matrix `W : Matrix (Fin n) (Fin n) ℝ`, define
\[
\operatorname{diagExSlack}(W,i,j) := 2W_{ij} - W_{ii} - W_{jj}.
\]
This is the primitive local quantity governing whether the tropical diagonal dominates the transposition `(i j)`.

### New definition 2: tropical symmetric margin
Define
\[
\operatorname{tropSymMargin}(W) := \min_{i<j} \bigl( W_{ii}+W_{jj}-2W_{ij}\bigr),
\]
equivalently the minimum negative exchange slack over unordered pairs. This is the symmetric analogue of the catalog tropical margin and should be formalized as a distinct notion, not merely a special case.

### New definition 3: pair-replacement distance
For symmetric matrices `W, W'`, define a “pair replacement seminorm” measuring the maximal perturbation of one diagonal pair and one off-diagonal symmetric pair:
\[
d_{\mathrm{pair}}(W,W') := \sup_{i\le j} |W_{ij}-W'_{ij}|.
\]
The key insight is that `tropSymMargin` depends on each unordered pair through at most **three scalar coordinates**: `W i i`, `W j j`, `W i j = W j i`.

These definitions are novel enough to support nontrivial theorems and algorithms.

---

## Precise theorem targets

You should prove at least the following 3 substantial theorems.

### Theorem 1: Lipschitz stability under symmetric perturbations
**Mathematical statement.**
For every `n ≥ 2` and symmetric real matrices `W, W'`,
\[
\bigl|\operatorname{tropSymMargin}(W)-\operatorname{tropSymMargin}(W')\bigr|
\le 4\, d_{\mathrm{pair}}(W,W').
\]
A sharper constant `≤ 4` is acceptable; if you can optimize to `≤ 4` or `≤ 2` depending on normalization, do so.

**Lean 4 target signature (suggested):**
```lean
theorem tropSymMargin_lipschitz
    {n : ℕ} (hn : 2 ≤ n)
    (W W' : Matrix (Fin n) (Fin n) ℝ)
    (hW : W.IsSymm) (hW' : W'.IsSymm) :
    |tropSymMargin W - tropSymMargin W'| ≤
      4 * pairReplacementDist W W' := by
  ...
```

A more local theorem should also be proved:

```lean
theorem diagExSlack_lipschitz
    {n : ℕ} (W W' : Matrix (Fin n) (Fin n) ℝ)
    {i j : Fin n} :
    |diagExSlack W i j - diagExSlack W' i j| ≤
      4 * pairReplacementDist W W' := by
  ...
```

This is the deterministic backbone of the whole project and should use `abs_sub_le_iff`, triangle inequalities, and multi-step `calc`.

---

### Theorem 2: Pairwise telescoping replacement bound for symmetric ensembles
This is the conceptual breakthrough theorem. Adapt the catalog entrywise replacement theorem to **simultaneous replacement of symmetric pairs**.

Let `W^(0), ..., W^(m)` be a chain of symmetric matrices where each step replaces exactly one unordered pair `(i,j)` with `i<j` together with its mirror entry, and possibly diagonal terms under a coupling rule. Then
\[
\bigl|\mathbb E[f(\operatorname{tropSymMargin}(W^{(m)}))]
      -\mathbb E[f(\operatorname{tropSymMargin}(W^{(0)}))]\bigr|
\le \sum_{k=0}^{m-1} \Delta_k
\]
for any 1-Lipschitz test function `f`, where each `Δ_k` is controlled by the local replacement size via Theorem 1.

This should be stated abstractly enough to instantiate Gaussian ↔ Rademacher ↔ uniform symmetric models.

**Lean 4 target signature (deterministic telescoping skeleton):**
```lean
theorem telescoping_bound_symm
    {α : Type*} [PseudoMetricSpace α]
    {m : ℕ} (F : Fin (m+1) → α) :
    dist (F 0) (F (Fin.last m)) ≤
      ∑ k : Fin m, dist (F (Fin.castSucc k)) (F (Fin.succ k)) := by
  ...
```

Then specialize to tropical margin:
```lean
theorem tropSymMargin_telescoping_bound
    {n m : ℕ} (hn : 2 ≤ n)
    (W : Fin (m+1) → Matrix (Fin n) (Fin n) ℝ)
    (hsymm : ∀ k, (W k).IsSymm) :
    |tropSymMargin (W 0) - tropSymMargin (W (Fin.last m))| ≤
      ∑ k : Fin m,
        |tropSymMargin (W (Fin.castSucc k)) -
         tropSymMargin (W (Fin.succ k))| := by
  ...
```

If probability-theory infrastructure is too heavy for full expectation statements, prove the deterministic telescoping theorem in full and provide a verified computational surrogate that numerically estimates the replacement bound for sampled ensembles.

---

### Theorem 3: Graph-theoretic characterization of nonnegative tropical symmetric margin
For a symmetric matrix `W`, define the weighted complete graph on vertices `Fin n` with edge weight
\[
c_{ij} := W_{ii}+W_{jj}-2W_{ij}.
\]
Then
\[
\operatorname{tropSymMargin}(W)\ge 0
\quad\Longleftrightarrow\quad
\forall i<j,\; 2W_{ij}\le W_{ii}+W_{jj}.
\]
This may look elementary, but the breakthrough is to interpret it as a **global graph cut / edge-positivity condition** and connect tropical diagonal optimality to a weighted graph metric defect.

Prove a sharpened version:
\[
\operatorname{tropSymMargin}(W) =
\min_{i<j} c_{ij}.
\]

**Lean 4 target signature (suggested):**
```lean
theorem tropSymMargin_eq_iInf_pairSlack
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (hW : W.IsSymm) :
    tropSymMargin W =
      sInf {x : ℝ | ∃ i j : Fin n, i < j ∧ x = (W i i + W j j - 2 * W i j)} := by
  ...
```

and the positivity criterion:
```lean
theorem tropSymMargin_nonneg_iff
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (hW : W.IsSymm) :
    0 ≤ tropSymMargin W ↔
      ∀ i j : Fin n, i < j → 2 * W i j ≤ W i i + W j j := by
  ...
```

This should require `rcases` on minimizing pairs, order arguments on finite sets, and nontrivial use of `Finset` minima / `sInf`.

---

## Stretch breakthrough theorem

If you can go further, prove the symmetric analogue of entrywise replacement universality:

### Theorem 4 (stretch): universality under pair-matched moments
Let `W^G_n`, `W^R_n`, `W^U_n` be symmetric ensembles with centered variance-1 sub-Gaussian upper-triangular entries, matched to second moment. Then for Lipschitz test functions `f`,
\[
\Bigl|\mathbb E f\!\left(\frac{\operatorname{tropSymMargin}(W_n)-a_n}{b_n}\right)
-\mathbb E f\!\left(\frac{\operatorname{tropSymMargin}(W'_n)-a'_n}{b_n}\right)\Bigr|
\to 0
\]
with \(b_n \asymp \sqrt{\log n}\).

Even a weaker formal theorem is acceptable:
- deterministic pairwise replacement bound,
- explicit centering candidate,
- verified simulation showing empirical collapse after `√(log n)` scaling.

That combination would already be scientifically meaningful.

---

## Why this is a breakthrough

The catalog result for independent matrices suggests tropical margins are controlled by local exchange slacks. The symmetric Wigner regime tests whether this mechanism survives **correlation imposed by physical symmetry**.

If successful, this says:

- tropical phase transitions are **universal under dependence constraints**;
- tropical optimization has a natural home in **random matrix theory**;
- the correct extreme-value objects are not arbitrary entries, but **pairwise exchange defects**;
- tropical diagonal dominance becomes a mathematically clean observable for **time-reversal invariant systems**.

This is the first step toward a full tropical analogue of Wigner’s universality program.

---

## Catalog building blocks to use explicitly

Use and cite the following as the starting spine:

- `Pythagorean/TropicalUniversality.lean`
  - `tropMargin_entrywise_replacement_bound`
  - `telescoping_bound`

Your task is not to rename these. It is to **lift** them to the structured symmetric setting:
- replace entrywise perturbation by **unordered-pair perturbation**;
- replace independent-coordinate telescoping by **pairwise telescoping**;
- isolate the exact local quantity `diagExSlack` that only touches three coordinates.

The key mathematical insight is that symmetry creates global dependence, but each exchange slack remains **locally low-complexity**.

---

## Proof strategy architecture

### Strategy A: Deterministic finite-dimensional geometry first, then probabilistic interpretation
This is the most promising route.

1. **Define `diagExSlack`, `tropSymMargin`, and `pairReplacementDist`.**
   Prove exact formulas expressing `tropSymMargin` as a finite minimum over unordered pairs.
2. **Prove local Lipschitz bounds** for `diagExSlack`, then pass to minima using finite-set infimum inequalities.
3. **Build telescoping replacement** for chains of symmetric pair updates.
4. **Only then** formulate probabilistic corollaries and simulation-based universality tests.

Why this is best: Lean handles deterministic inequalities and finite minima robustly; once these are certified, the probabilistic story can be layered on top without fighting measure-theoretic complexity too early.

---

### Strategy B: Encode symmetric matrices via upper-triangular coordinates
1. Represent a symmetric matrix as data on `{(i,j) | i ≤ j}`.
2. Define `tropSymMargin` as a function on this coordinate space.
3. Prove it is Lipschitz with respect to the sup norm on upper-triangular coordinates.
4. Pull back the theorem to symmetric matrices.

Why this is powerful: it exposes the true dimension of the randomness and makes “independent above the diagonal” mathematically native. It may also simplify the algorithmic side and simulation.

Risk: more setup overhead in Lean.

---

### Strategy C: Graph-theoretic reformulation
1. Associate to `W` a weighted graph with edge weights `c_{ij} = W_{ii}+W_{jj}-2W_{ij}`.
2. Show `tropSymMargin` is the minimum edge weight.
3. Prove perturbation and replacement results as graph edge-weight stability theorems.
4. Interpret symmetric random matrices as random weighted complete graphs.

Why this matters: this creates the cross-domain bridge and may reveal stronger statements, such as monotonicity under graph operations or connections to cut metrics and Euclidean negative type.

Most likely use this as a companion viewpoint to Strategy A, not as the sole proof path.

---

## Cross-domain connections you must develop

At least one theorem must bridge to a different domain. Here are the strongest options.

### 1. Random matrix theory + physics
Symmetric matrices model **time-reversal invariant systems**. The theorem says tropical phase transitions persist under the same symmetry that defines GOE/Wigner ensembles. This is a physics-facing universality claim.

Possible formal theorem:
```lean
theorem diagExSlack_depends_on_three_coordinates
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) {i j : Fin n} :
    diagExSlack W i j =
      2 * W i j - W i i - W j j := by
  ...
```
Then explain scientifically that despite global symmetry constraints, each local instability remains a 3-variable observable.

### 2. Graph theory
Interpret `tropSymMargin ≥ 0` as nonnegativity of all edge defects in a weighted complete graph. This connects tropical diagonal dominance to graph edge potentials.

Possible theorem:
```lean
theorem tropSymMargin_nonneg_iff_all_edgeWeights_nonneg
    {n : ℕ} (hn : 2 ≤ n)
    (W : Matrix (Fin n) (Fin n) ℝ) (hW : W.IsSymm) :
    0 ≤ tropSymMargin W ↔
      ∀ e : Sym2 (Fin n), 0 ≤ edgeDefect W e := by
  ...
```
If `Sym2` is too cumbersome, use ordered pairs with `i < j`.

### 3. Metric geometry / kernel methods
The quantity `W_{ii}+W_{jj}-2W_{ij}` is the squared-distance polarization formula. If `W` is a Gram matrix, then
\[
W_{ii}+W_{jj}-2W_{ij} = \|x_i-x_j\|^2.
\]
Hence `tropSymMargin(W)` becomes the minimum pairwise squared distance.

This is a beautiful bridge: **tropical margin = geometric separation radius** for Gram matrices.

A powerful theorem target:
```lean
theorem tropSymMargin_of_gram_eq_min_sqDist
    {n d : ℕ} (X : Fin n → EuclideanSpace ℝ (Fin d)) :
    tropSymMargin (gramMatrix X) =
      sInf {r : ℝ | ∃ i j : Fin n, i < j ∧
        r = ‖X i - X j‖^2 } := by
  ...
```
Even a weaker finite-minimum version would be outstanding. This is the strongest cross-domain theorem in the brief.

---

## Conjecture with testable prediction

### Main conjecture
For Wigner-type symmetric matrices `W_n` with centered variance-1 sub-Gaussian upper-triangular entries,
\[
\mathbb P\!\left(\operatorname{tropSymMargin}(W_n)\ge 0\right)
\]
has a phase transition after centering by `a_n` and scaling by `b_n ~ √(log n)`, and the limiting transition curve is universal across Gaussian, Rademacher, and uniform laws.

### Falsifiable computational prediction
For `n = 8, 12, 16`, simulate:
- symmetric Gaussian,
- symmetric Rademacher,
- symmetric uniform (variance matched),

and plot
\[
\mathbb P(\operatorname{tropSymMargin}(W_n)\ge t)
\]
against the rescaled threshold `(t-a_n)/√(log n)`.

**Prediction:** the three curves collapse to a common profile up to finite-size error; if they do not, the conjecture is false.

A second, sharper prediction:
- the centering sequence differs from the independent-entry case by a symmetry-induced correction,
- but the scale remains `√(log n)`.

This is genuinely falsifiable.

---

## Verified algorithm / computational method required

You must implement a verified computational method, not just prove theorems.

### Algorithm target
Implement an algorithm that computes `tropSymMargin` of a symmetric matrix by scanning unordered pairs:
```python
def trop_sym_margin(W):
    # return min_{i<j} (W[i,i] + W[j,j] - 2*W[i,j])
```

Then:
1. generate symmetric Gaussian / Rademacher / uniform matrices,
2. estimate empirical survival curves,
3. compare under `√(log n)` scaling,
4. display collapse plots interactively.

In Lean, certify the deterministic core:
- correctness of the pair-scan formula,
- perturbation bound under pair replacement,
- optional correctness of a finite minimum implementation.

In `demo.py`, include:
- sliders or CLI options for `n`, ensemble, trials,
- empirical histograms of `tropSymMargin`,
- rescaled curve comparison,
- optional display of the minimizing pair `(i,j)`.

---

## File-level theorem suggestions

You should aim for theorem names along the lines of:

```lean
def diagExSlack ...
def tropSymMargin ...
def pairReplacementDist ...

theorem diagExSlack_symm ...
theorem diagExSlack_lipschitz ...
theorem tropSymMargin_eq_finset_inf ...
theorem tropSymMargin_nonneg_iff ...
theorem tropSymMargin_lipschitz ...
theorem tropSymMargin_pair_update_bound ...
theorem tropSymMargin_telescoping_bound ...
theorem tropSymMargin_of_gram_eq_min_sqDist ...
```

At least 3 of these should involve nontrivial proofs with:
- `rcases` over minimizing witnesses,
- `by_contra` for positivity/negativity equivalences,
- `field_simp` if you normalize distances or variances,
- multi-step `calc` inequalities,
- induction for telescoping chains.

---

## Application keywords

**tropical geometry, random matrix theory, Wigner ensembles, universality, extreme-value theory, graph theory, weighted complete graphs, kernel methods, Gram matrices, metric geometry, time-reversal symmetry, sub-Gaussian concentration, pairwise exchange defects, phase transition, tropical optimization**

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean code** with the new definitions and at least 3 substantial theorems as above, minimizing sorry.
2. **A verified algorithm or computational method** for computing `tropSymMargin` and testing the conjecture.
3. **`demo.py`** demonstrating the result interactively on symmetric Gaussian/Rademacher/uniform ensembles.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining:
   - the new symmetric tropical margin,
   - deterministic stability theorems,
   - universality conjecture and evidence,
   - why symmetry changes centering but plausibly not scaling,
   - future mathematical consequences.
5. **`ARTICLE.md`** in Scientific American style, focused on the mathematical ideas and significance, not on formal verification.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as kernel methods, statistical physics, or random graphs.

---

## Final charge

Do not merely adapt a proof line-by-line from the independent case. Isolate the true invariant: **the tropical margin is controlled by local exchange defects, not by global independence assumptions**. If you can make that precise, you will have created the first rigorous bridge between tropical optimization and symmetric random matrix universality.

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
