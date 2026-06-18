Soli Deo Gloria

## Assignment: Direction 1: Wreath Product Perturbation Theory

**Mode:** prove

Prove genuinely new, non-trivial theorems about subgroup-pressure universality for wreath products, with an explicit perturbative comparison to direct products. This should not be a cosmetic extension of product factorization: the goal is to isolate and control the *imprimitive coupling term* created by the semidirect action of `S_m` on `S_k^m`, and to show that this coupling is asymptotically irrelevant in the critical-exponent sense.

You are to turn the physicists’ slogan

> “imprimitive symmetry is an irrelevant perturbation of product symmetry”

into precise finite-group theorems and a verified computational method.

---

## Central Mathematical Objective

Let `W_{k,m} = S_k ≀ S_m = (S_k)^m ⋊ S_m`, acting imprimitively on `k*m` points partitioned into `m` blocks of size `k`. Let `𝓘_{k,m}` denote the family of imprimitive subgroups compatible with the block system. Define a subgroup-pressure functional `Π_W(k,m;s)` by summing weighted subgroup contributions over `𝓘_{k,m}` in the spirit of the catalog pressure constructions, and let `β_W(k,m)` be the critical exponent where this pressure changes from convergence to divergence.

Your mission is to formalize and prove rigorous comparison theorems of the form:

\[
\Pi_W(k,m;s)=\Pi_{\mathrm{prod}}(k,m;s)+\delta\Pi(k,m;s),
\]
with `Π_prod` the pressure for `(S_k)^m`, and to prove that for fixed `m`, the perturbation term `δΠ` is asymptotically lower-order as `k → ∞` in a sense strong enough to imply stability of the critical exponent up to an explicit error term.

The conceptual breakthrough is this: not exact factorization, but **universality under semidirect coupling**. If established, this opens a new algebraic renormalization theory for subgroup growth and pressure, where one classifies finite-group constructions into relevant / irrelevant / marginal perturbations.

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. At least one should be asymptotic/comparison in flavor, at least one should establish a structural decomposition for wreath-product subgroup data, and at least one should bridge to another domain.

### New definition required

Define a new concept not already in the catalog, for example:

- `ImprimitivePerturbation` — the excess pressure contribution from subgroups not lying in the pure base product;
- `BlockRespectingSubgroup` — a subgroup preserving the canonical block partition;
- `WreathPressureKernel` — the weighted counting kernel on block-compatible subgroup pairs;
- `AsymptoticallyIrrelevant` — a predicate expressing that a perturbation does not shift the critical exponent beyond a controlled error.

A plausible Lean-facing skeleton:

```lean
structure ImprimitivePerturbation (k m : ℕ) where
  basePressure : ℝ → ℝ
  wreathPressure : ℝ → ℝ
  defect : ℝ → ℝ
  defect_eq : ∀ s, defect s = wreathPressure s - basePressure s
```

or, if the catalog is already pressure-sequence based, define it discretely rather than analytically.

---

## Precise theorem statements with Lean 4 signatures

The exact signatures may need adaptation to existing catalog definitions, but your formalization must aim at statements of this level of specificity.

### Theorem 1: Wreath pressure decomposition

**Mathematical statement.**
For each `k,m`, the wreath pressure splits into a product contribution plus an imprimitive defect term. The defect is supported exactly on subgroup data with nontrivial projection to the top permutation group `S_m`.

\[
\Pi_W(k,m;s)=\Pi_{\mathrm{prod}}(k,m;s)+\delta\Pi(k,m;s),
\]
and
\[
\delta\Pi(k,m;s)=\sum_{\substack{H \in \mathcal I_{k,m}\\ \pi_{\mathrm{top}}(H)\neq 1}} w_s(H),
\]
for the relevant weight function `w_s`.

**Lean target sketch.**
```lean
theorem wreath_pressure_decomposition
    (k m : ℕ) :
    ∀ s : ℝ,
      wreathPressure k m s
        = productPressure k m s + imprimitiveDefect k m s
```

A stronger version if you formalize subgroup-index summation:
```lean
theorem imprimitiveDefect_eq_sum_top_nontrivial
    (k m : ℕ) :
    ∀ s : ℝ,
      imprimitiveDefect k m s
        = ∑' H : {H : Subgroup (WreathProduct (Equiv.Perm (Fin k)) (Equiv.Perm (Fin m))) // BlockRespecting H ∧ topProjectionNontrivial H},
            subgroupWeight s H.1
```

### Theorem 2: Upper bound showing perturbative irrelevance

**Mathematical statement.**
For fixed `m`, there exists a constant `C_m > 0` such that for sufficiently large `k` and for all `s` in a neighborhood of the product critical exponent,
\[
0 \le \delta\Pi(k,m;s) \le \frac{C_m}{k}\,\Pi_{\mathrm{prod}}(k,m;s) + E_{k,m}(s),
\]
where `E_{k,m}` is uniformly subcritical. Consequently,
\[
|\beta_W(k,m)-\beta_{\mathrm{prod}}(k,m)| \le \frac{C_m'}{k}.
\]

This is the real breakthrough theorem. It says the semidirect block-coupling has RG scaling dimension `-1` relative to the dominant product pressure.

**Lean target sketch.**
```lean
theorem imprimitive_defect_le_inv_k_mul_product
    (m : ℕ) :
    ∃ C : ℝ, 0 < C ∧
      ∀ ⦃k : ℕ⦄, 2 ≤ k →
      ∀ s : ℝ,
        imprimitiveDefect k m s
          ≤ (C / k : ℝ) * productPressure k m s + subcriticalError k m s
```

and the exponent consequence:
```lean
theorem beta_wreath_close_to_beta_product
    (m : ℕ) :
    ∃ C : ℝ, 0 < C ∧
      ∀ ⦃k : ℕ⦄, 2 ≤ k →
        |betaWreath k m - betaProduct k m| ≤ C / k
```

If `betaWreath` is defined as an `sInf`/threshold, you may need monotonicity and comparison lemmas before this theorem.

### Theorem 3: Additivity survives semidirect coupling to first order

**Mathematical statement.**
Using the catalog theorem that the direct product exponent satisfies
\[
\beta_{\mathrm{prod}}(k,m)=m\,\beta(S_k),
\]
prove a first-order wreath asymptotic:
\[
\beta_W(k,m)=m\,\beta(S_k)+\varepsilon_{k,m},
\qquad |\varepsilon_{k,m}| \le \frac{C_m}{k}.
\]

**Lean target sketch.**
```lean
theorem beta_wreath_eq_mulg_beta_symm_plus_error
    (m : ℕ) :
    ∃ ε : ℕ → ℝ,
      (∀ ⦃k : ℕ⦄, 2 ≤ k → |ε k| ≤ (errorConstant m : ℝ) / k) ∧
      ∀ ⦃k : ℕ⦄, 2 ≤ k →
        betaWreath k m = m * betaSymmetric k + ε k
```

This theorem should explicitly invoke the catalog exponent-additivity theorem as a build block.

### Theorem 4: Cross-domain bridge via random walks / entropy proxy

You must include at least one theorem connecting this subgroup-pressure theory to another domain. The strongest option is probability on groups.

**Mathematical statement.**
Show that the top-group contribution controls a mixing/entropy correction term for a block-random walk kernel on `S_k ≀ S_m`, so that irrelevance of `δΠ` implies asymptotic equality of a pressure-derived entropy rate and the product entropy rate up to `O(1/k)`.

Even a weaker but rigorous bridge is acceptable if fully formalized:
- orbit-counting asymptotics linked to subgroup pressure;
- representation-counting bound via Clifford theory;
- a combinatorial bound on block-orbit complexity implying the pressure defect bound.

**Lean target sketch (combinatorial/orbit version).**
```lean
theorem block_orbit_complexity_bound
    (k m : ℕ) :
    orbitComplexityWreath k m
      ≤ orbitComplexityProduct k m + topActionComplexity m
```

or probabilistic:
```lean
theorem wreath_entropy_correction_bound
    (m : ℕ) :
    ∃ C : ℝ, ∀ ⦃k : ℕ⦄, 2 ≤ k →
      |entropyRateWreath k m - entropyRateProduct k m| ≤ C / k
```

This theorem is essential: it transforms the project from “one more finite-group asymptotic” into a bridge between algebraic pressure and statistical mechanics / random walks.

---

## Catalog build plan

Build directly on the vetted results in:

- `Catalog/old/Pythagorean/SubgroupPressure.lean`
  - extract the exact pressure definition, summability/divergence lemmas, and any product-factorization theorem already formalized;
  - reuse the weighted subgroup-pair machinery rather than redefining pressure from scratch.

- `Pythagorean/SubgroupUniversality.lean`
  - use exponent additivity for direct products as the anchor point:
    \[
    \beta_{\mathrm{prod}}(k,m)=m\beta(S_k).
    \]
  - identify any monotonicity, comparison, or threshold lemmas for critical exponents.

You should explicitly state in comments where each imported theorem enters the proof:
1. product decomposition gives the zeroth-order fixed point,
2. universality/additivity identifies the base exponent,
3. new wreath lemmas estimate the perturbation.

If the existing pressure is defined on subgroup pairs `(H,K)` rather than subgroups `H`, adapt all statements accordingly; do not flatten the formalism if the catalog already has a richer one.

---

## Proof architecture: 3 viable strategies

You must attempt at least two of these in the code/comments, and pursue the most promising one to completion.

### Strategy A: Projection-to-top-group filtration
**Idea:** Filter block-respecting subgroups by the size or structure of their projection to `S_m`. Subgroups with trivial top projection are exactly base-product subgroups; all others contribute to the defect.

**Steps**
1. Define the canonical projection `π_top : W_{k,m} → S_m` and classify block-respecting subgroups by `π_top(H)`.
2. Show the `π_top(H)=1` stratum reproduces the product pressure.
3. Bound the nontrivial strata using the finite complexity of subgroup types in `S_m`, obtaining an `m`-dependent constant times a suppressed `k`-dependent factor.

**Why promising:** This directly matches the semidirect-product structure and turns the perturbation into a finite union of controlled top-group sectors.

### Strategy B: Index distortion and subgroup-growth comparison
**Idea:** Compare subgroup weights in the wreath product to subgroup weights in the base product by controlling how much the semidirect action can distort indices / normalizers / orbit counts.

**Steps**
1. Embed `(S_k)^m` as the base subgroup of `W_{k,m}` and compare subgroup indices under inclusion and normal closure.
2. Prove a distortion lemma: top-group coupling changes the subgroup weight by at most a multiplicative factor polynomial in `m` and subleading in `k`.
3. Feed this into the catalog divergence theorem to deduce exponent stability.

**Why promising:** This is closest to renormalization language: same singularity class under bounded distortion. If the catalog already has “divergence bound” lemmas, this may be the shortest path.

### Strategy C: Representation-theoretic control via Clifford theory
**Idea:** Use the classification of irreducibles of `S_k ≀ S_m` to show that the top-group contribution only introduces bounded multiplicity inflation relative to the product base.

**Steps**
1. Translate subgroup pressure or orbit-counting into a representation-counting proxy.
2. Use Clifford-theoretic decomposition of wreath-product irreducibles to isolate the top-action contribution.
3. Show that the extra multiplicities depend chiefly on partitions of `m`, hence are bounded independently of `k`, yielding irrelevance.

**Why promising:** This creates the strongest cross-domain bridge and may reveal a more conceptual invariant than raw subgroup counting.

**Most promising overall:** Strategy A first, Strategy B second. Strategy A is most compatible with formal subgroup machinery and likely least dependent on heavy representation theory. Strategy C is visionary and worth sketching in `FUTURE_DIRECTIONS.md` even if not fully formalized.

---

## Required deep-proof features

Your file must contain at least 3 theorems whose proofs genuinely use nontrivial tactics such as:
- induction over `m` or subgroup strata,
- `rcases` on subgroup projections / semidirect decomposition data,
- `by_contra` for threshold or critical-exponent separation arguments,
- `field_simp` when comparing rational/real pressure bounds,
- multi-step `calc` chains for inequalities and decomposition identities.

Do not let the core theorems collapse to `simp`, `rfl`, or brute-force decision procedures.

---

## Suggested formal objects and lemmas

Depending on what Mathlib already offers for wreath products / semidirect products, you may need to define a finite proxy rather than the full categorical object immediately. Candidate definitions:

```lean
def blockPartition (k m : ℕ) : Fin (k * m) → Fin m := ...
def respectsBlocks {k m : ℕ} (σ : Equiv.Perm (Fin (k * m))) : Prop := ...
def blockRespectingSubgroup (k m : ℕ) :=
  {H : Subgroup (Equiv.Perm (Fin (k * m))) // ∀ h ∈ H, respectsBlocks h}

def topProjection {k m : ℕ} :
    blockRespectingSubgroup k m →* Equiv.Perm (Fin m) := ...

def productPressure (k m : ℕ) (s : ℝ) : ℝ := ...
def wreathPressure (k m : ℕ) (s : ℝ) : ℝ := ...
def imprimitiveDefect (k m : ℕ) (s : ℝ) : ℝ :=
  wreathPressure k m s - productPressure k m s

def betaProduct (k m : ℕ) : ℝ := ...
def betaWreath (k m : ℕ) : ℝ := ...
```

If full wreath products are technically heavy, it is acceptable to formalize a mathematically faithful “block-respecting permutation group” model inside `Perm (Fin (k*m))`, provided the embedding of `S_k ≀ S_m` is explicit and the pressure theory is proved there.

---

## Conjecture with testable prediction

You must state and computationally probe a falsifiable conjecture, not merely repeat the informal one.

### Formal conjecture
For each fixed `m ≥ 1`, there exists `C_m > 0` such that for all `k ≥ 2`,
\[
|\beta_W(k,m)-m\beta(S_k)| \le \frac{C_m}{k}.
\]

A stronger version worth testing:
\[
k\bigl(\beta_W(k,m)-m\beta(S_k)\bigr)\to \lambda_m
\]
for some finite constant `λ_m`.

This is highly nontrivial: if true, it suggests a first irrelevant operator in the algebraic RG expansion. If false, the growth of the rescaled deviation detects a genuinely new universality class.

### Computational test
Implement `demo.py` to:
1. call GAP or use precomputed subgroup data for `k ≤ 8`, `m ≤ 5`,
2. estimate `Π_W(k,m;s)` numerically near the expected threshold,
3. extract `β_W(k,m)` via log-slope / bisection / divergence diagnostics,
4. compare against `m * β(S_k)`,
5. plot `k * (β_W(k,m) - m*β(S_k))` versus `k`.

A growing trend in magnitude with `k` would refute the `O(1/k)` conjecture.

---

## Cross-domain connections you must exploit

### 1. Statistical mechanics / renormalization
Interpret `β` as a critical exponent and `δΠ` as a perturbing operator. The theorem is a rigorous finite-group analogue of irrelevant perturbations near a fixed point. This language should shape both the mathematics and exposition.

### 2. Representation theory
Use Clifford theory of wreath products to motivate why the top-action should contribute only bounded combinatorial complexity for fixed `m`. Even if not fully formalized, connect subgroup sectors to partition data and induced representations.

### 3. Probability on groups
Relate block permutation coupling to random walks on lamplighter-like / wreath-product structures. If pressure stability mirrors entropy-rate stability, this could seed a new theory connecting subgroup growth, mixing, and universality.

### 4. Additive/combinatorial orbit counting
The imprimitive action creates orbit-coupling between blocks. Bounding the number/weight of such coupled orbit types is the combinatorial heart of irrelevance.

**Application keywords:** universality, critical exponent, wreath product, imprimitive action, semidirect product, subgroup growth, renormalization group, entropy rate, random walks on groups, Clifford theory, orbit counting, asymptotic stability, representation growth, algebraic statistical mechanics.

---

## Why this would be a breakthrough

The catalog already suggests universality for exact products. That is only the zeroth chapter. The real frontier is whether universality survives *coupling*. Wreath products are the canonical first test: they are structured enough to analyze, but genuinely beyond factorization. Proving `β_W = β_prod + O(1/k)` would establish the first robust theorem that critical exponents in subgroup-pressure theory are stable under a natural semidirect perturbation.

That would open:
- a classification of group constructions into universality classes,
- a perturbative algebraic RG for finite and profinite groups,
- new links between subgroup growth and representation-theoretic complexity,
- computational diagnostics for “relevant” algebraic couplings.

If the conjecture fails, that is equally valuable: wreath structure becomes a new relevant parameter, revealing that algebraic universality breaks precisely at imprimitive coupling. Either outcome is field-opening.

---

## Concrete deliverables

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 substantial new theorems, one new definition, and minimized sorry usage.
2. **A verified algorithm or computational method** for estimating/approximating `β_W(k,m)` or bounding `δΠ(k,m;s)`.
3. **`demo.py`** demonstrating the computation interactively, including plots or printed comparison tables for small `k,m`.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define subgroup pressure and the wreath perturbation,
   - state the main theorems clearly,
   - explain why they matter mathematically,
   - discuss limitations and next conjectures.
5. **`ARTICLE.md`** in Scientific American style:
   - explain the idea of universality under symmetry coupling,
   - discuss why wreath products are the decisive test case,
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, e.g. random matrix theory, coding theory, or quantum statistical mechanics.

---

## Minimum theorem menu to aim for

A strong implementation would include something close to the following list:

1. `wreath_pressure_decomposition`
2. `top_trivial_projection_iff_base_subgroup`
3. `imprimitive_defect_nonneg`
4. `imprimitive_defect_le_inv_k_mul_product`
5. `beta_wreath_close_to_beta_product`
6. `beta_wreath_eq_mulg_beta_symm_plus_error`
7. `block_orbit_complexity_bound` or `wreath_entropy_correction_bound`

Even if some asymptotic theorem requires an abstract hypothesis package, formalize the package cleanly and prove the implication theorem rigorously.

---

## Final charge

Do not treat this as “wreath products, but a little.” Treat it as the birth of **algebraic perturbation theory** for critical exponents. Exact products are the Gaussian fixed point; wreath products are the first interacting theory. Prove that interaction is irrelevant—or prove that it is not. Either result changes the map.

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
