Soli Deo Gloria

## Assignment: Direction 1: Spectral-Tropical Entropy Bridge

**Mode:** `prove`

Prove genuinely new theorems at the interface of **spectral graph theory, entropy, and tropical/information-theoretic irregularity**. Build explicitly on the catalog results in:

- `Catalog/Pythagorean/TropicalBridge/Stability.lean`
- `Catalog/Pythagorean/TropicalBridge/TropicalInformationTheory.lean`

and use them as certified infrastructure, not merely as inspiration. Minimize `sorry`. The target is not a small inequality but a new principle: **spectral data controls information-theoretic disorder of combinatorial objects**.

---

## Core Vision

The conjecture below is already compelling, but it should be sharpened into a program that isolates the right entropy functional, proves rigorous lower bounds, and identifies the exact obstruction to equality. The deepest opportunity is this:

> **Degree entropy is not just a combinatorial statistic. It is a spectral potential.**

If formalized correctly, this opens a new field: **spectral-tropical information theory**, where graph spectra provide certified lower bounds on information content, robustness, and irregularity. This is not a routine graph inequality. It is a bridge between:

- **spectral theory**: Perron eigenvalues, Collatz–Wielandt, Rayleigh quotients,
- **information theory**: Shannon entropy, KL divergence, relative entropy,
- **tropical/discrete stability**: degree concentration as a combinatorial analogue of energy landscape flattening.

The right theorem should reveal that the entropy deficit from regularity is controlled by a spectral defect.

---

## Primary Mathematical Target

Let \(G\) be a finite simple connected graph with vertex set \(V\), degree function \(d(v)\), total volume
\[
\mathrm{vol}(G) := \sum_{v \in V} d(v) = 2|E|,
\]
degree distribution
\[
p_v := \frac{d(v)}{\mathrm{vol}(G)},
\]
and degree entropy
\[
H(G) := - \sum_{v \in V} p_v \log p_v.
\]

Let
\[
\Delta := \max_{v \in V} d(v),
\]
and let \(\lambda_1\) denote the largest real eigenvalue of the adjacency matrix of \(G\).

Your starting conjecture is:

\[
H(G) \ge \log(\lambda_1/\Delta).
\]

This is philosophically interesting but likely not the strongest or cleanest formulation, because \(\lambda_1/\Delta \le 1\), hence \(\log(\lambda_1/\Delta)\le 0\), while \(H(G)\ge 0\). So the conjecture as stated is true if entropy nonnegativity is already known. Therefore the real task is to **replace this weak inequality by a nontrivial spectral-entropy theorem**.

---

## Precise Theorem Program

You should introduce a new notion that measures **entropy deficit from regularity**.

### New definition (mandatory novelty)

Define the **regularity deficit entropy**
\[
\mathcal D(G) := \log |V| - H(G).
\]

This vanishes exactly for regular graphs when the degree distribution is uniform. It is the KL divergence of the degree distribution from the uniform distribution:
\[
\mathcal D(G) = D_{\mathrm{KL}}(p \,\|\, u),
\qquad u_v = \frac1{|V|}.
\]

This is the correct object because \(\lambda_1/\Delta\) measures spectral deviation from regularity, and \(\mathcal D(G)\) measures information-theoretic deviation from regularity.

### Theorem 1: spectral upper bound on entropy deficit

For every finite connected graph \(G\) with at least one edge,
\[
\mathcal D(G) \le \log(\Delta/\bar d),
\]
where
\[
\bar d := \frac1{|V|}\sum_{v\in V} d(v) = \frac{\mathrm{vol}(G)}{|V|}.
\]

Equivalently,
\[
H(G) \ge \log |V| - \log(\Delta/\bar d)
= \log\!\left(\frac{|V|\bar d}{\Delta}\right).
\]

Since \(\lambda_1 \ge \bar d\) for every graph, this implies the stronger spectral form

### Theorem 2: spectral-tropical entropy lower bound

\[
H(G) \ge \log\!\left(\frac{|V|\,\lambda_{\mathrm{avg}}}{\Delta}\right)
\quad\text{with } \lambda_{\mathrm{avg}}:=\bar d,
\]
and hence
\[
H(G) \ge \log\!\left(\frac{|V|\,\bar d}{\Delta}\right).
\]

This is already nontrivial: it says entropy cannot collapse unless the graph has a strong degree bottleneck.

But the real breakthrough target is:

### Theorem 3: Perron-strengthened entropy bound

Assume \(G\) is finite, connected, simple, and nonempty. Then
\[
H(G) \ge \log\!\left(\frac{\lambda_1^2}{\Delta\,\bar d}\right).
\]

This is equivalent to
\[
\mathcal D(G) \le \log\!\left(\frac{|V|\,\Delta\,\bar d}{\lambda_1^2}\right).
\]

This theorem is genuinely spectral: it uses the nontrivial inequality
\[
\lambda_1^2 \ge \bar d^2
\]
and, more sharply, the relation between the Perron vector and the degree profile. It is not a corollary of entropy nonnegativity.

### Theorem 4: exact characterization of equality

Prove one or both of the following equality statements:

1. If \(G\) is \(d\)-regular, then
   \[
   H(G)=\log|V|,\qquad \lambda_1=\Delta=d,\qquad \mathcal D(G)=0.
   \]

2. If
   \[
   H(G)=\log|V|,
   \]
   then all non-isolated vertices have equal degree; under connectedness, \(G\) is regular.

This pins down the “zero-temperature” state of your entropy functional and turns the theorem into a rigidity statement.

---

## Lean 4 Formalization Targets

Use concrete finite types and matrices when necessary. A reasonable formalization path is through simple graphs on a finite vertex type.

You should aim for theorem statements along the following lines. Adjust exact namespaces to actual Mathlib APIs.

```lean
import Mathlib
import Catalog.Pythagorean.TropicalBridge.Stability
import Catalog.Pythagorean.TropicalBridge.TropicalInformationTheory

open scoped BigOperators Real Matrix
open Finset

noncomputable section

namespace SpectralTropicalEntropy

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V)

def vol : ℝ := ∑ v : V, (G.degree v : ℝ)

def degreeProb (v : V) : ℝ := (G.degree v : ℝ) / vol G

def degreeEntropy : ℝ :=
  - ∑ v : V, degreeProb G v * Real.log (degreeProb G v)

def maxDegree : ℕ := Finset.univ.sup G.degree

def avgDegree : ℝ := vol G / Fintype.card V

def regularityDeficit : ℝ := Real.log (Fintype.card V) - degreeEntropy G
```

### Suggested theorem signatures

#### Theorem A: entropy lower bound from max/average degree
```lean
theorem degreeEntropy_lower_bound_avg_max
    (hvol : 0 < vol G) :
    Real.log ((Fintype.card V : ℝ) * avgDegree G / maxDegree G) ≤ degreeEntropy G
```

#### Theorem B: regularity deficit upper bound
```lean
theorem regularityDeficit_le_log_max_over_avg
    (hvol : 0 < vol G) :
    regularityDeficit G ≤ Real.log ((maxDegree G : ℝ) / avgDegree G)
```

#### Theorem C: regular graphs maximize degree entropy
```lean
theorem degreeEntropy_eq_log_card_of_regular
    {d : ℕ}
    (hreg : ∀ v : V, G.degree v = d)
    (hd : 0 < d) :
    degreeEntropy G = Real.log (Fintype.card V)
```

#### Theorem D: entropy rigidity
```lean
theorem degreeEntropy_eq_log_card_iff_regular
    (hconn : G.Connected)
    (hvol : 0 < vol G) :
    degreeEntropy G = Real.log (Fintype.card V) ↔
      ∃ d : ℕ, ∀ v : V, G.degree v = d
```

#### Spectral target, if adjacency spectral radius API is available
You may need to define spectral radius of the adjacency matrix over `ℝ` or `ℂ` via `Matrix`. If existing API is awkward, prove an intermediate theorem using any available certified notion of largest eigenvalue.

```lean
def adjacencyMatrix : Matrix V V ℝ := fun i j => if G.Adj i j then 1 else 0

def spectralRadiusAdj : ℝ := sInf {r | ... } -- or use existing API

theorem avgDegree_le_spectralRadius
    (hnonempty : Nonempty V) :
    avgDegree G ≤ spectralRadiusAdj G
```

Then combine with Theorem A to obtain:

```lean
theorem degreeEntropy_lower_bound_spectral
    (hvol : 0 < vol G)
    (hspec : avgDegree G ≤ spectralRadiusAdj G) :
    Real.log ((Fintype.card V : ℝ) * spectralRadiusAdj G / maxDegree G) ≤ degreeEntropy G
```

This is the theorem that actually fulfills the vision: **entropy bounded below by spectral concentration**.

---

## Why this is a breakthrough

If proved, these results would establish that:

1. **Entropy is spectrally constrained.** One cannot have arbitrarily low topological information content unless the graph also exhibits severe spectral irregularity.
2. **Regularity becomes an information-theoretic extremum.** Regular graphs maximize degree entropy among fixed vertex count, turning a combinatorial symmetry principle into a thermodynamic law.
3. **Spectral observables certify information capacity.** This suggests algorithms that estimate entropy lower bounds from eigenvalue computations alone, without enumerating the full degree distribution.

This opens an entirely new direction: **spectral certificates for tropical information landscapes**. Follow-on work could target Laplacian entropy, hypergraph entropy, simplicial complexes, and even neural architecture graphs where spectral radius acts as a proxy for expressive capacity.

---

## Proof Strategy Architecture

You must present at least 2–3 serious proof routes and pursue the most promising one.

### Strategy A: KL divergence + pointwise degree bound + Jensen/Gibbs
**Most promising.**

1. Rewrite
   \[
   \mathcal D(G)=\sum_v p_v \log\!\bigl(p_v |V|\bigr).
   \]
2. Observe
   \[
   p_v = \frac{d(v)}{\mathrm{vol}(G)} \le \frac{\Delta}{|V|\bar d}.
   \]
   Hence
   \[
   p_v |V| \le \frac{\Delta}{\bar d}.
   \]
3. Since \(x \mapsto \log x\) is increasing,
   \[
   \log(p_v |V|) \le \log(\Delta/\bar d).
   \]
   Averaging against \(p_v\) gives
   \[
   \mathcal D(G) \le \log(\Delta/\bar d).
   \]
4. Rearrange to get the entropy lower bound.

Why this is strongest: it is clean, conceptual, and should formalize well in Lean using finite sums, positivity lemmas, and `calc` blocks. It also naturally identifies `regularityDeficit` as the right new structure.

### Strategy B: concavity of log / entropy maximization under box constraints
1. View degree entropy as the entropy of a probability vector \(p\) with coordinates bounded by
   \[
   p_v \le \Delta/\mathrm{vol}(G).
   \]
2. Use the fact that entropy is minimized/maximized under affine and box constraints at extremal distributions.
3. Derive lower bounds by comparing with a truncated extremizer.

Why useful: this could produce sharper piecewise bounds depending on the number of vertices with degree \(\Delta\). It may lead to a stronger theorem than the initial target.

### Strategy C: spectral route through Rayleigh quotient and Perron vector
1. Use
   \[
   \bar d \le \lambda_1 \le \Delta.
   \]
2. Replace \(\bar d\) by \(\lambda_1\) in the lower bound whenever monotonicity permits.
3. If possible, relate the degree distribution to the Perron vector \(x\), exploiting
   \[
   \lambda_1 x_v = \sum_{u\sim v} x_u.
   \]
4. Seek a refined entropy bound involving the Perron vector distribution itself:
   \[
   H_{\mathrm{deg}}(G) \ge H_{\mathrm{Perron}}(G) - \text{error term}.
   \]

Why this matters: this is the route to a genuinely field-opening theorem, connecting stationary measures, eigenvector localization, and entropy concentration. It may be harder in Lean, but even one certified inequality here would be a major contribution.

---

## Required Theorems Beyond the Main Bound

Your file must contain **at least 3 substantial theorems** with nontrivial proofs. Suggested package:

1. **Entropy lower bound from average/max degree**
2. **Regularity deficit upper bound**
3. **Regular graphs maximize degree entropy**
4. **Entropy rigidity under connectedness**
5. **Average degree bounded by spectral radius** or a formalized usable version of this
6. **Cross-domain theorem:** KL divergence interpretation or thermodynamic free-energy style inequality

At least one proof should use:
- induction on a finite sum structure, or
- `rcases` on graph connectedness / nonemptiness cases, or
- `by_contra` for rigidity/equality, or
- `field_simp` for degree-probability normalization, or
- a multi-step `calc` chain using log monotonicity and positivity.

---

## Cross-Domain Connection Theorem

You are required to include at least one theorem explicitly connecting to another domain.

### Recommended connection: information theory
Formalize that the regularity deficit is exactly a KL divergence from the uniform distribution.

Mathematically:
\[
\mathcal D(G) = \sum_v p_v \log\left(\frac{p_v}{1/|V|}\right).
\]

Lean target:
```lean
def uniformProb (v : V) : ℝ := 1 / Fintype.card V

def degreeKLToUniform : ℝ :=
  ∑ v : V, degreeProb G v * Real.log (degreeProb G v / uniformProb v)

theorem regularityDeficit_eq_degreeKLToUniform
    (hvol : 0 < vol G) :
    regularityDeficit G = degreeKLToUniform G
```

This theorem is not cosmetic. It says your graph invariant is a bona fide information divergence, making the whole project part of statistical mechanics and coding theory, not just graph combinatorics.

### Optional second connection: statistical physics
Interpret
\[
F(G) := -H(G) + \beta \log \Delta
\]
as a crude free energy balancing disorder and bottleneck energy. Prove monotonicity in \(\beta\) or an inequality comparing \(F(G)\) across regular vs irregular graphs.

---

## Conjecture with Testable Prediction

The initial conjecture should be replaced by a falsifiable stronger one.

### Strong Conjecture
For every finite connected graph \(G\),
\[
\mathcal D(G) \le \log(\Delta/\lambda_1).
\]
Equivalently,
\[
H(G) \ge \log\!\left(\frac{|V|\lambda_1}{\Delta}\right).
\]

This is far stronger than the trivial \(\log(\lambda_1/\Delta)\) lower bound and would be a true spectral-entropy theorem. It is sharp on regular graphs.

**Testable prediction:** For Erdős–Rényi graphs \(G(n,p)\), the gap
\[
H(G) - \log\!\left(\frac{|V|\lambda_1}{\Delta}\right)
\]
should remain nonnegative and typically small in the dense regime \(p \ge 0.3\), while becoming larger for sparse graphs with stronger degree fluctuations.

### Computational test
Compute for 1000 random graphs with \(n=50\), \(p\in\{0.1,0.3,0.5\}\):
- \(H(G)\),
- \(\Delta\),
- \(\bar d\),
- \(\lambda_1\),
- the quantities
  \[
  H(G)-\log(|V|\bar d/\Delta), \qquad
  H(G)-\log(|V|\lambda_1/\Delta).
  \]
Report empirical validity and distribution of margins.

A single counterexample would refute the strong conjecture; this makes it scientifically meaningful.

---

## Application Keywords

Use and highlight these explicitly in the writeup and demo:

- spectral graph theory
- Shannon entropy
- KL divergence
- Perron–Frobenius
- tropical stability
- irregularity measures
- graph information capacity
- entropy rigidity
- eigenvalue certificates
- combinatorial thermodynamics
- random graph testing
- spectral certification

---

## Implementation Guidance in Lean

1. **Start from entropy infrastructure already in**
   `Catalog/Pythagorean/TropicalBridge/TropicalInformationTheory.lean`.
   Reuse any theorem establishing:
   - nonnegativity of degree entropy,
   - normalization of degree probabilities,
   - positivity lemmas for degrees/volume.

2. **Define `regularityDeficit` and `degreeKLToUniform`** as new objects.
   This satisfies the novelty requirement and creates the correct formal language.

3. **Prove normalization carefully**
   \[
   \sum_v p_v = 1
   \]
   under `hvol : 0 < vol G`.
   This will be used repeatedly.

4. **Use pointwise bounds**
   \[
   d(v) \le \Delta,\qquad
   \mathrm{vol}(G)=|V|\bar d.
   \]
   Then derive
   \[
   p_v |V| \le \Delta/\bar d.
   \]

5. **Turn pointwise log bounds into sum bounds**
   via positivity of \(p_v\) and summation.

6. **For equality cases**, use `by_contra`:
   if entropy is maximal but some degree differs from another, the degree distribution is not uniform, hence KL divergence is positive.

7. **If spectral API is difficult**, first prove the average/max theorem completely and then add a theorem whose hypothesis is an abstract spectral lower bound:
   ```lean
   theorem degreeEntropy_lower_bound_from_spectral_parameter
       {ρ : ℝ}
       (hρ : avgDegree G ≤ ρ)
       (hρΔ : ρ ≤ maxDegree G) :
       Real.log ((Fintype.card V : ℝ) * ρ / maxDegree G) ≤ degreeEntropy G
   ```
   Then instantiate later with `ρ = λ₁`.

This staged approach ensures a substantial verified result even if the final spectral packaging needs API work.

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as:
- quantum information,
- statistical mechanics,
- coding theory,
- simplicial/hypergraph spectra,
- neural architecture graphs.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the new definitions,
- the main theorems,
- why the original conjecture was too weak,
- the corrected spectral-entropy principle,
- proof ideas,
- computational evidence,
- future conjectures.

Someone reading only this paper must understand the mathematics and significance without access to code.

### 3. `ARTICLE.md`
Write in **Scientific American** style. Make it vivid and concept-driven. Explain how eigenvalues can certify how “informationally uneven” a graph is.  
**Taboo:** do not focus on formal verification machinery.

### 4. Verified algorithm / computational method
Implement a certified computation pipeline for:
- degree distribution,
- degree entropy,
- average degree,
- maximum degree,
- the entropy lower bound
  \[
  \log(|V|\bar d/\Delta),
  \]
and, if feasible, spectral-radius-based bounds.

This must be more than a theorem statement: it should be an executable method.

### 5. `demo.py`
Interactive or script-based demonstration that:
- generates random graphs,
- computes entropy and the proposed lower bounds,
- tests the strong conjecture,
- displays examples of regular, near-regular, and highly irregular graphs,
- prints empirical margins and possible counterexamples.

---

## Final Call to Arms

Do not merely prove that \(H(G)\ge 0\) and note that \(\log(\lambda_1/\Delta)\le 0\). That would miss the mathematics entirely. The true problem is to discover the correct inequality in which **spectral regularity quantitatively forces information-theoretic regularity**.

The transformative outcome is a theorem of the form:

\[
\text{spectral regularity} \Longrightarrow \text{entropy floor}.
\]

That is a new law, not a variant. Prove it, formalize it, test it, and expose the next frontier.

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
