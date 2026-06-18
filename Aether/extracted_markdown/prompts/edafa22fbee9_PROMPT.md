Soli Deo Gloria

## Assignment: Direction 2: Assignment Gap Extension (All Permutations)

**Mode:** `prove`

Prove genuinely new, non-trivial theorems in Lean 4, building explicitly on catalog results around `signalGap`, `tropMargin`, and the robustness lemmas in `Pythagorean/TropicalUniversality.lean`. The goal is not to repackage the transposition-based story, but to open a full **tropical assignment-complexity theory**: show that the local tropical margin already captures the global assignment landscape on a generic locus, and isolate the exceptional geometry where longer cycles matter.

This is worth doing because it would turn a seemingly ad hoc statistic (`tropMargin`) into a mathematically canonical quantity: the true gap between the identity assignment and the best competing permutation, except on a lower-dimensional exceptional set. That would connect tropical robustness, random assignment, and discriminantal geometry in a single formal framework.

## Core Definitions to Introduce

You must define at least one genuinely new concept. The central one should be the **full assignment gap**.

Suggested Lean-level definitions:

```lean
import Mathlib
import Pythagorean.TropicalUniversality

open BigOperators
open Finset

noncomputable section

/-- Weight of a permutation against a square matrix `W`. -/
def permWeight {n : ℕ} (W : Fin n → Fin n → ℝ) (σ : Equiv.Perm (Fin n)) : ℝ :=
  ∑ i : Fin n, W i (σ i)

/-- The identity assignment weight. -/
def idWeight {n : ℕ} (W : Fin n → Fin n → ℝ) : ℝ :=
  permWeight W (Equiv.refl _)

/-- The set of non-identity permutations. -/
def nonIdPerms (n : ℕ) : Finset (Equiv.Perm (Fin n)) :=
  (Fintype.elems (Equiv.Perm (Fin n))).filter fun σ => σ ≠ Equiv.refl _

/-- Full assignment gap: identity weight minus best non-identity competitor. -/
def assignmentGap {n : ℕ} (W : Fin n → Fin n → ℝ) : ℝ :=
  idWeight W - (nonIdPerms n).sup' (by
    classical
    have h : (nonIdPerms n).Nonempty := by
      -- only expected to be used for `n ≥ 2`; package a separate lemma
      sorry) (permWeight W)

/-- A permutation is a transposition if it swaps exactly two points. -/
def IsTranspositionPerm {α : Type*} [Fintype α] [DecidableEq α] (σ : Equiv.Perm α) : Prop :=
  ∃ a b : α, a ≠ b ∧ σ a = b ∧ σ b = a ∧ ∀ c, c ≠ a → c ≠ b → σ c = c

/-- The best transposition-only competitor weight. -/
def bestTranspositionWeight {n : ℕ} (W : Fin n → Fin n → ℝ) : ℝ :=
  ((Fintype.elems (Equiv.Perm (Fin n))).filter IsTranspositionPerm).sup' (by
    classical
    -- nonempty when `n ≥ 2`
    sorry) (permWeight W)

/-- Exceptional locus where some non-transposition permutation ties or beats all transpositions. -/
def LongCycleExceptional {n : ℕ} (W : Fin n → Fin n → ℝ) : Prop :=
  ∃ σ : Equiv.Perm (Fin n),
    σ ≠ Equiv.refl _ ∧ ¬ IsTranspositionPerm σ ∧
    bestTranspositionWeight W ≤ permWeight W σ
```

If the existing catalog already defines `tropMargin` in a way equivalent to the best transposition deficit, do **not** duplicate it; instead prove an exact bridge theorem from your new `assignmentGap` to the catalog notion.

## Precise Theorem Targets

You must prove at least 3 substantial theorems with multi-step arguments. The following are the right targets.

### Theorem 1: Transpositions realize the full assignment gap under strict diagonal dominance

This is the mathematically strongest clean theorem likely to be formalizable now, and it should be the backbone of the file.

**Mathematical statement.**  
Let `W : Fin n → Fin n → ℝ` with `n ≥ 2`. Assume
\[
\forall i \neq j,\quad W(i,i)+W(j,j) > W(i,j)+W(j,i).
\]
Then every non-identity permutation `σ` satisfies
\[
\sum_i W(i,\sigma(i))
\le
\max_{\tau \text{ transposition}} \sum_i W(i,\tau(i)),
\]
hence
\[
assignmentGap(W)=tropMargin(W)
\]
provided `tropMargin` is the identity-minus-best-transposition gap from the catalog.

This is a breakthrough because it says a purely **local 2-cycle inequality** globally controls the entire assignment polytope. In other words: if every pair prefers staying put to swapping, then no 3-cycle, 4-cycle, or more exotic permutation can do better than the best swap. This is exactly the kind of phenomenon that can seed a formal tropical theory of combinatorial optimization.

**Suggested Lean signature:**
```lean
theorem permWeight_le_bestTransposition_of_pairwise_diag_dom
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (hdom : ∀ i j : Fin n, i ≠ j → W i i + W j j > W i j + W j i) :
    ∀ σ : Equiv.Perm (Fin n), σ ≠ Equiv.refl _ →
      permWeight W σ ≤ bestTranspositionWeight W := by
  sorry

theorem assignmentGap_eq_tropMargin_of_pairwise_diag_dom
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (hdom : ∀ i j : Fin n, i ≠ j → W i i + W j j > W i j + W j i) :
    assignmentGap W = tropMargin W := by
  sorry
```

### Theorem 2: Cycle decomposition inequality

This theorem is the engine behind Theorem 1 and is independently valuable.

**Mathematical statement.**  
For any permutation `σ`, decompose `σ` into disjoint cycles. If every nontrivial cycle `C = (i₁ i₂ ... i_k)` satisfies
\[
\sum_{r=1}^k W(i_r,i_r) > \sum_{r=1}^k W(i_r,i_{r+1}),
\]
then the identity beats `σ`. In particular, under pairwise diagonal dominance, every cycle of length `k ≥ 2` is dominated by a sum of transposition inequalities.

This theorem is where combinatorics meets tropical linear inequalities. It reframes assignment competition as a cycle-energy decomposition, reminiscent of statistical mechanics and graph potentials.

**Suggested Lean signature:**
```lean
/-- Weight contribution of a cycle support; formulate as needed. -/
def cycleWeightContribution {n : ℕ} (W : Fin n → Fin n → ℝ)
    (s : Finset (Fin n)) (e : Fin n → Fin n) : ℝ := sorry

theorem idWeight_gt_permWeight_of_cyclewise_dom
    {n : ℕ} (W : Fin n → Fin n → ℝ) (σ : Equiv.Perm (Fin n))
    (hcycle : ∀ c, IsCycle c σ → 2 ≤ c.length →
      -- encode the strict cycle inequality in your chosen representation
      True) :
    permWeight W σ < idWeight W := by
  sorry
```

If direct use of `Equiv.Perm.IsCycle` becomes awkward, you may instead prove a finite-support version for permutations whose moved points are partitioned into cyclic orbits. The theorem must still be mathematically meaningful, not a coding artifact.

### Theorem 3: Generic equality outside an exceptional hyperplane arrangement

You likely cannot formalize “measure zero” cleanly in one cycle, but you can absolutely formalize a sharp algebraic proxy: the bad locus is contained in a finite union of affine hyperplanes where two permutation weights coincide.

**Mathematical statement.**  
For fixed `n`, define the exceptional set
\[
\mathcal E_n = \bigcup_{\sigma \neq id,\ \tau \text{ transposition}}
\{W : \mathrm{permWeight}(W,\sigma)=\mathrm{permWeight}(W,\tau)\}.
\]
Then outside `\mathcal E_n`, the best non-identity permutation is unique; moreover if every maximizer among non-identity permutations is a transposition, then
\[
assignmentGap(W)=tropMargin(W).
\]

Even better: prove that `LongCycleExceptional W` implies membership in one of finitely many equality hyperplanes between a long-cycle permutation and a transposition. This gives the exact tropical-discriminantal geometry of failure.

**Suggested Lean signature:**
```lean
def PermTieHyperplane {n : ℕ} (σ τ : Equiv.Perm (Fin n))
    (W : Fin n → Fin n → ℝ) : Prop :=
  permWeight W σ = permWeight W τ

theorem assignmentGap_eq_tropMargin_of_unique_nonId_maximizer_transposition
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (huniq : ∃! σ : Equiv.Perm (Fin n),
      σ ≠ Equiv.refl _ ∧
      ∀ τ : Equiv.Perm (Fin n), τ ≠ Equiv.refl _ → permWeight W τ ≤ permWeight W σ)
    (htrans : IsTranspositionPerm (Classical.choose huniq)) :
    assignmentGap W = tropMargin W := by
  sorry

theorem longCycleExceptional_implies_tie_hyperplane
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (hE : LongCycleExceptional W) :
    ∃ σ τ : Equiv.Perm (Fin n),
      σ ≠ Equiv.refl _ ∧ ¬ IsTranspositionPerm σ ∧
      IsTranspositionPerm τ ∧
      PermTieHyperplane σ τ W := by
  sorry
```

If the final hyperplane theorem needs a slightly weaker conclusion, that is acceptable, but it must still isolate the exceptional set by explicit linear equalities.

## Most Promising Proof Architecture

You must include at least 2–3 proof strategy paths in the file comments or paper, and then execute the strongest one in Lean.

### Strategy A: Cycle decomposition + pairwise domination (most promising)

1. **Decompose any permutation into disjoint cycles.**  
   The permutation weight splits as a sum over moved cycles plus fixed points.

2. **Reduce each cycle to local inequalities.**  
   For a cycle `(i₁ ... i_k)`, compare
   \[
   \sum_r W(i_r,i_r) - W(i_r,i_{r+1}).
   \]
   Show that if all pairwise transposition deficits are positive, then the cycle deficit is positive. For `k=2` this is exactly the transposition inequality; for `k≥3`, telescope or average pairwise inequalities carefully.

3. **Conclude no long cycle beats the best transposition.**  
   Since every nontrivial cycle loses to identity by a positive amount, the least-loss competitor must be supported on one 2-cycle, hence a transposition.

**Why this is most promising:** it converts the global optimization problem over `n!` permutations into an additive structure over cycles, which is exactly what permutations naturally provide and what Lean can handle with induction over finite moved supports.

### Strategy B: Assignment polytope / linear functional geometry

1. Identify each permutation with a vertex of the Birkhoff polytope.  
2. Show that pairwise diagonal dominance defines a cone of linear functionals whose second-best vertex adjacent to the identity is always a transposition vertex.  
3. Translate adjacency in the polytope to cycle exchanges.

**Why it is powerful:** conceptually elegant and connects to optimization and polyhedral geometry.  
**Why it is less promising in Lean now:** heavy infrastructure for Birkhoff polytope may not be catalog-ready.

### Strategy C: Graph-theoretic potential method

1. Regard `Δ(i,j) = W(i,i)-W(i,j)` as an edge penalty in a complete directed graph.  
2. Then the deficit of a permutation is the sum of penalties along its cycle cover.  
3. Under positive 2-cycle penalties, prove every cycle cover has total penalty at least the minimum 2-cycle penalty.

**Why it matters:** this creates a bridge to random assignment, min-cost cycle covers, and even statistical mechanics via cycle gases.  
**Why it may help formalization:** finite sums over cycle covers may be easier than full permutation algebra in some lemmas.

## Cross-Domain Connections You Must Surface

At least one theorem and the accompanying prose must explicitly bridge to another domain.

1. **Combinatorial optimization:**  
   `assignmentGap` is the energy barrier between the identity matching and the best alternative perfect matching. This ties directly to the random assignment problem and near-optimal matchings.

2. **Tropical / algebraic geometry:**  
   Equalities of permutation weights define a finite arrangement of affine hyperplanes. The locus where a long cycle competes with transpositions is a tropical discriminant-type exceptional set.

3. **Probability / universality:**  
   If `assignmentGap = tropMargin` on a generic locus, then universality results already proved for `tropMargin` should transfer to the full assignment landscape. This is a formal route from local perturbation statistics to global optimization statistics.

4. **Statistical mechanics:**  
   Permutations decompose into cycles, and weights define a cycle-cover energy. The theorem says the low-energy excitations are generically 2-cycles, analogous to a theory where pair excitations dominate over long collective rearrangements.

5. **Algorithmic complexity:**  
   A quantity defined a priori by scanning all `n!` permutations collapses generically to a quadratic-size transposition search. This is an algorithmic phase simplification theorem.

## Application Keywords

Include these in `RESEARCH_PAPER.md`, theorem docstrings, or `ARTICLE.md` where natural:

- tropical universality
- assignment problem
- Birkhoff polytope
- cycle cover energy
- affine hyperplane arrangement
- discriminant locus
- genericity
- random matrix phase transition
- combinatorial optimization
- low-energy excitations
- universality class
- tropical margin
- perfect matching stability
- permutation statistics

## Concrete Lean Guidance

Build directly on catalog statements such as:

- `signalGap`
- `tropMargin_nonneg_of_signalGap_large`
- `tropMargin_nonpos_of_noise_overwhelms`

Do not merely cite them: explain and prove bridge lemmas of the form

```lean
theorem assignmentGap_nonneg_of_signalGap_large
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (h : signalGap W ≤ ... ) :
    0 ≤ assignmentGap W := by
  ...
```

or, more realistically, use the catalog theorem to infer nonnegativity of `tropMargin`, then transfer it to `assignmentGap` under your new structural hypotheses.

Possible bridge theorem:

```lean
theorem assignmentGap_nonneg_of_pairwise_dom
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ)
    (hdom : ∀ i j : Fin n, i ≠ j → W i i + W j j ≥ W i j + W j i) :
    0 ≤ assignmentGap W := by
  sorry
```

This is not deep enough by itself; it should support the stronger equality theorem.

## Required Conjecture with Computational Test

State a falsifiable conjecture and make it testable in `demo.py`.

### Conjecture: Generic transposition dominance
For i.i.d. continuous random matrices `W_n : Fin n → Fin n → ℝ`,
\[
\Pr[assignmentGap(W_n)=tropMargin(W_n)] \to 1 \quad \text{as } n\to\infty.
\]

Equivalent testable prediction for experiments:
- Sample random `n×n` matrices for `n = 3,4,5,6,7`.
- Enumerate all permutations for small `n`.
- Compute:
  - `idWeight`
  - best non-identity permutation weight
  - best transposition weight
  - whether equality holds.
- Plot disagreement frequency versus `n`.

A stronger falsifiable variant:
- The disagreement probability decays at least polynomially in `n^{-1}` for Gaussian matrices.

If experiments refute this, that is scientifically valuable: it means longer cycles survive generically and the tropical transposition picture is incomplete.

## Demo / Algorithm Requirement

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement a Lean definition and supporting lemmas for computing `assignmentGap` by exhaustive permutation search for small `n`, and a Python demo that:
1. generates random matrices,
2. computes `tropMargin`,
3. computes `assignmentGap`,
4. identifies the maximizing competitor permutation,
5. classifies it as transposition / long cycle,
6. estimates disagreement probability.

Suggested verified algorithm theorem:
```lean
theorem assignmentGap_spec
    {n : ℕ} (W : Fin n → Fin n → ℝ) :
    assignmentGap W =
      idWeight W - ∃? -- replace by exact `Finset.sup'` characterization
    := by
  sorry
```

More useful:
```lean
theorem bestCompetitor_exists
    {n : ℕ} (hn : 2 ≤ n) (W : Fin n → Fin n → ℝ) :
    ∃ σ : Equiv.Perm (Fin n), σ ≠ Equiv.refl _ ∧
      ∀ τ : Equiv.Perm (Fin n), τ ≠ Equiv.refl _ →
        permWeight W τ ≤ permWeight W σ := by
  sorry
```

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean file** with at least 3 substantial theorems, using deep proof tactics (`induction`, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, etc.), and minimizing `sorry`.
2. **A new definition** not already in the catalog, such as `assignmentGap`, `IsTranspositionPerm`, or `LongCycleExceptional`.
3. **A cross-domain theorem** explicitly linking assignment gaps to hyperplane arrangements / cycle energies / optimization.
4. **A falsifiable conjecture** with a clear computational disproof criterion.
5. **A verified algorithm or computational method** for finding the best competitor permutation.
6. **`demo.py`** showing the phenomenon interactively on random matrices.

And also explicitly provide:

### (a) `FUTURE_DIRECTIONS.md`
Give 3–5 genuinely new research directions. Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**
At least one direction must bridge to a different domain, such as statistical mechanics, random matrix theory, or algebraic geometry.

### (b) `RESEARCH_PAPER.md`
A standalone scientific paper. Someone reading only this paper must understand:
- the definition of `assignmentGap`,
- why reducing from all permutations to transpositions is surprising,
- what was proved,
- what remains conjectural,
- why the exceptional locus matters,
- and what the next experiments should test.

### (c) `ARTICLE.md`
Write in **Scientific American** style. Make it vivid and idea-driven.  
**Taboo:** do **not** focus on formal verification, proof assistants, or mechanization. Focus on the mathematics, the optimization picture, the geometry of exceptions, and why pairwise swaps might secretly control a huge combinatorial universe.

### (d) Verified algorithm / computational method
Not optional.

### (e) `demo.py`
Interactive, visual if possible. Show random matrices, maximizing permutations, and disagreement statistics.

## Final Scientific Aim

Do not settle for “here is another gap statistic.” The real target is:

> Show that the tropical margin is not merely a local proxy but the generic first-order law of the full assignment landscape.

If you can formalize that even under a strong structural hypothesis such as pairwise diagonal dominance, you will have created the first rigorous bridge from tropical robustness observables to the full geometry of permutation competition. That opens a field: **tropical assignment universality**.

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
