Soli Deo Gloria

## Assignment: Direction 4 — Lorentzian Anti-Cancellation in Statistical Physics

**Mode:** `prove`

Aristotle, aim for a genuine bridge theorem between **equilibrium statistical physics**, **Lorentzian polynomial theory**, and **combinatorial Hodge structures**. Do not settle for a toy reformulation of known Lee–Yang facts. The goal is to isolate a mathematically robust ferromagnetic partition polynomial whose coefficients encode correlation structure, prove Lorentzianity in a nontrivial regime, and then force an anti-cancellation principle for susceptibilities. If this works, it opens a new formal language for “no hidden correlations” in positive-temperature systems.

Build explicitly on:

- `Pythagorean/LorentzianAggregateAntiCancel.lean`
- `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`

Use these not as decorative citations but as load-bearing infrastructure:
- extract the exact anti-cancellation statement already formalized for Lorentzian coefficient arrays / aggregate shadows,
- identify the strongest existing closure theorem for Lorentzianity under the operations appearing in the partition polynomial,
- then lift the statistical-mechanical observable you define into that framework.

---

## Core Mathematical Program

Let `G = (V,E)` be a finite simple graph, with ferromagnetic couplings `J_e ≥ 0`, inverse temperature `β > 0`, and external field variables attached to vertices. Introduce a **new formal object**:

### New definition: ferromagnetic subset partition polynomial
For a finite graph `G` with edge weights `J : E → ℝ≥0`, define
\[
\Phi_G^\beta(\mathbf z)
\;:=\;
\sum_{S \subseteq V}
\exp\!\Bigl(\beta \sum_{\{i,j\}\in E} J_{ij}\,\mathbf 1_{[i,j \in S \text{ or } i,j\notin S]}\Bigr)
\prod_{i\in S} z_i.
\]
Equivalently, `S` records the `+1` spin set. This is the multiaffine generating polynomial of spin-up subsets weighted by Ising energy.

This is the right object because:
- it is **multiaffine** in the field variables,
- its coefficients are manifestly positive for ferromagnetic couplings,
- first and second logarithmic derivatives recover magnetizations and susceptibilities after specialization,
- and it is the natural candidate on which stability/Lorentzian methods can act.

You should formalize a Lean definition along the lines of:

```lean
def isingSubsetWeight
  {V : Type} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (J : Sym2 V → ℝ) (β : ℝ) (S : Finset V) : ℝ :=
Real.exp (β * ∑ e in G.edgeFinset, J e *
  if Quotient.out e ∈ S ∧ Quotient.out (Sym2.swapRep e) ∈ S
     ∨ Quotient.out e ∉ S ∧ Quotient.out (Sym2.swapRep e) ∉ S
  then 1 else 0)

def isingPartitionPoly
  {V : Type} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (J : Sym2 V → ℝ) (β : ℝ) :
  MvPolynomial V ℝ :=
∑ S in Finset.powers (Finset.univ : Finset V),
  MvPolynomial.C (isingSubsetWeight G J β S) *
    ∏ i in S, MvPolynomial.X i
```

If the exact edge API is awkward in Mathlib, define an equivalent weight via an auxiliary edge-incidence summation that is Lean-friendly. Precision matters more than cosmetic faithfulness.

---

## Target Theorems

You must prove at least **3 substantial theorems**, each using real proof architecture: induction, `rcases`, `by_contra`, `field_simp`, nontrivial `calc`, or structural decomposition. Avoid theorem statements whose only proof is computation.

### Theorem 1 — Two-spin ferromagnetic Lorentzianity
Prove the first nontrivial base case completely and structurally.

#### Mathematical statement
For the graph on two vertices with one edge of nonnegative coupling `J ≥ 0` and `β ≥ 0`, the multiaffine partition polynomial
\[
\Phi(z_1,z_2)=e^{\beta J}(1+z_1z_2)+z_1+z_2
\]
is Lorentzian.

This is not just a sanity check: it is the atomic interaction from which all ferromagnetic systems are assembled. You should prove it by explicit Hessian/signature or by stable multiaffine criteria, not by brute force.

#### Lean 4 target signature
A plausible formal target is:

```lean
theorem isingPartitionPoly_edge_lorentzian
  (β J : ℝ) (hβ : 0 ≤ β) (hJ : 0 ≤ J) :
  Lorentzian
    (C (Real.exp (β * J)) * (1 + X (0 : Fin 2) * X (1 : Fin 2))
      + X (0 : Fin 2) + X (1 : Fin 2) : MvPolynomial (Fin 2) ℝ)
```

If the catalog’s `Lorentzian` predicate is stated on coefficient functions or homogeneous polynomials, homogenize this polynomial with an auxiliary variable and prove the corresponding homogeneous statement instead.

### Theorem 2 — Closure under ferromagnetic edge multiplication
Show that Lorentzianity is preserved when adding a ferromagnetic edge factor in the multiaffine homogenized model.

A natural homogenized local factor is
\[
f_{ij}(x_0,\mathbf x)
=
x_0^2 + x_0x_i + x_0x_j + e^{2\beta J_{ij}}x_ix_j
\]
or an equivalent normalization. Prove that this factor is Lorentzian for `J_{ij} ≥ 0`, and then prove that under the catalog’s closure theorem, products / polarized compositions of such factors remain Lorentzian.

#### Breakthrough statement
For every finite graph `G` with nonnegative couplings, the homogenized ferromagnetic partition polynomial obtained by multiplying local edge factors and extracting the multiaffine vertex-sector is Lorentzian.

#### Lean 4 target signature
Something of the form:

```lean
def isingHomogenizedPoly
  {V : Type} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (J : Sym2 V → ℝ) (β : ℝ) :
  MvPolynomial (Option V) ℝ := ...

theorem isingHomogenizedPoly_lorentzian
  {V : Type} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (J : Sym2 V → ℝ) (β : ℝ)
  (hferro : ∀ e, 0 ≤ J e) (hβ : 0 ≤ β) :
  Lorentzian (isingHomogenizedPoly G J β)
```

If the full theorem is too ambitious in one cycle, prove a sharp intermediate theorem for:
- forests,
- a single-edge extension step,
- or graphs obtained by clique-sums preserving the closure hypotheses.

But the statement should still be nontrivial and reusable.

### Theorem 3 — Anti-cancellation for positive susceptibilities
Define a mathematically precise “susceptibility support” and prove a support-exactness theorem using the anti-cancellation machinery from the catalog.

Let
\[
\chi_{ij}(\mathbf z)
=
\partial_i\partial_j \log \Phi_G^\beta(\mathbf z)
=
\frac{\partial_i\partial_j \Phi}{\Phi}
-
\frac{(\partial_i\Phi)(\partial_j\Phi)}{\Phi^2}.
\]
The theorem should be framed in polynomial/support language before analytic specialization.

#### New definition: aggregate susceptibility shadow
Define a support-valued object built from second derivatives or the Hessian numerator
\[
N_{ij} = \Phi\,\partial_i\partial_j \Phi - (\partial_i\Phi)(\partial_j\Phi).
\]
Then prove that if the partition polynomial is Lorentzian and coefficients are positive, the support of any positive aggregate susceptibility operator equals its aggregate shadow: no monomial support disappears by cancellation.

#### Lean 4 target signature
For a support notion `monomialSupport : MvPolynomial σ ℝ → Finset (σ →₀ ℕ)` and a suitable positivity hypothesis:

```lean
def susceptibilityNumerator
  {σ : Type} [DecidableEq σ]
  (p : MvPolynomial σ ℝ) (i j : σ) : MvPolynomial σ ℝ :=
p * pderiv i (pderiv j p) - pderiv i p * pderiv j p

theorem support_susceptibilityNumerator_eq_shadow
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ)
  (hpL : Lorentzian p)
  (hppos : PositiveCoefficients p)
  (hOp : PositiveSecondOrderObservable p) :
  monomialSupport (aggregateObservable p ...)
    = aggregateShadow p ...
```

Use the exact catalog theorem from `LorentzianAggregateAntiCancel.lean` to avoid reproving the anti-cancellation engine. Your work is to instantiate it correctly for a physically meaningful operator.

### Theorem 4 — Cross-domain theorem: negative dependence / covariance control
You must include at least one theorem that bridges into **probability theory**.

After specializing `z_i = 1`, the Gibbs measure on subsets is
\[
\mu_\beta(S) = \Phi_G^\beta(\mathbf 1)^{-1} w_\beta(S).
\]
Prove a theorem connecting Lorentzianity to probabilistic correlation structure, for example:
- a negative dependence statement for a transformed variable family,
- an ultra-log-concavity statement for magnetization level counts,
- or a Newton inequality for the total-spin distribution.

A concrete and formalizable option:

#### Mathematical statement
Let
\[
a_k = \sum_{|S|=k} w_\beta(S).
\]
If `Φ_G^β` is Lorentzian, then the sequence `(a_k)_k` is log-concave:
\[
a_k^2 \ge a_{k-1}a_{k+1}.
\]

This is a real bridge: **statistical mechanics ↔ combinatorial Hodge theory ↔ probability**.

#### Lean 4 target signature
```lean
def levelWeight
  {V : Type} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (J : Sym2 V → ℝ) (β : ℝ) (k : ℕ) : ℝ := ...

theorem ising_levelWeights_logConcave
  {V : Type} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) (J : Sym2 V → ℝ) (β : ℝ)
  (hL : Lorentzian (isingHomogenizedPoly G J β)) :
  ∀ k, levelWeight G J β k ^ 2
      ≥ levelWeight G J β (k-1) * levelWeight G J β (k+1)
```

If the exact indexing at boundaries is annoying, state the theorem for `1 ≤ k` and `k+1 ≤ Fintype.card V`.

---

## Proof Architecture: 3 Viable Strategies

You asked for deeper proof insight. Here are three serious routes. Use at least two in the file if possible.

### Strategy A — Stability → Lorentzian via Lee–Yang / multiaffine closure
**Most revolutionary if it closes.**

1. **Encode ferromagnetic partition polynomial as a multiaffine stable polynomial** using the Lee–Yang theorem or Asano contraction framework.
2. **Invoke Brändén–Huh style implication**: homogeneous stable polynomials with nonnegative coefficients are Lorentzian.
3. **Apply catalog anti-cancellation theorem** to the resulting coefficient/support data.

Why promising:
- It gives a conceptual proof, not a graph-by-graph verification.
- It explains *why* ferromagnetic physics should satisfy anti-cancellation: stability is the analytic avatar, Lorentzianity the combinatorial one.

Lean risk:
- full Lee–Yang may be too large to formalize from scratch. If so, formalize a restricted closure theorem for the specific local factors needed.

### Strategy B — Edge-factor decomposition + closure under Lorentzian operations
**Most practical for this cycle.**

1. Define a local ferromagnetic edge polynomial and prove it Lorentzian by explicit Hessian/signature analysis.
2. Show the global homogenized partition polynomial is built from these local factors via operations already known to preserve Lorentzianity: products, polarization, diagonal specialization, coefficient extraction, or contraction.
3. Push anti-cancellation on the final polynomial.

Why promising:
- Modular.
- Closest to existing catalog closure lemmas.
- Avoids importing the entire analytic Lee–Yang apparatus while still capturing the same phenomenon algebraically.

This is likely the best path.

### Strategy C — Induction on graph structure
**Best if closure lemmas are incomplete.**

1. Prove the theorem for the empty graph and one-edge graph.
2. Add one edge at a time, expressing the new partition polynomial as a positive combination or structured transform of the old one.
3. Prove Lorentzianity and support exactness are preserved under that transform.

Why promising:
- Excellent for Lean induction.
- Naturally yields at least one deep theorem with `induction` and multi-step `calc`.

Risk:
- The preservation transform may be technically subtle.

---

## Concrete Lean Work Plan

1. **Inspect catalog theorem statements** in:
   - `Pythagorean/LorentzianAggregateAntiCancel.lean`
   - `Catalog/Speculative/AutoResearch/LorentzianGlauberMixing.lean`

2. **Define new objects**:
   - `isingSubsetWeight`
   - `isingPartitionPoly`
   - `isingHomogenizedPoly`
   - `susceptibilityNumerator`
   - `aggregateShadow` or a specialization of the catalog’s shadow notion
   - `levelWeight`

3. **Prove at least 3 deep theorems**, such as:
   - one-edge Lorentzianity,
   - edge-extension closure,
   - susceptibility support exactness,
   - level-weight log-concavity.

4. **Use deep tactics**:
   - `induction` on edge set or graph size,
   - `rcases` on subset membership cases,
   - `by_contra` for support nonvanishing contradiction,
   - `field_simp` in logarithmic derivative manipulations,
   - nontrivial `calc` chains for coefficient identities.

5. **Minimize `sorry` aggressively.**
   If one theorem depends on a difficult missing closure lemma, isolate that lemma clearly and prove all surrounding infrastructure.

---

## Falsifiable Conjecture with Computational Test

State and test the following:

### Conjecture: strict Lorentzian ferromagnetism off critical degeneracy
For every connected finite graph `G` with strictly positive couplings `J_e > 0` and `β > 0`, the homogenized partition polynomial `isingHomogenizedPoly G J β` is **strictly Lorentzian**, and for every nonzero positive second-order observable `O` built from susceptibility numerators, the support of `O` is exactly its aggregate shadow with no boundary degeneracy.

This is falsifiable:
- compute the coefficient arrays for `K₄`, `K₅`, Petersen graph,
- test all principal Hessian signatures / Newton inequalities on coordinate slices,
- compute susceptibility numerators and compare support with shadow,
- search for a monomial present in the shadow but absent in the observable.

A single counterexample disproves it.

---

## Demo / Algorithm Requirement

You must produce a **verified computational method**, not just theorem statements.

### Required algorithm
Implement a procedure that:
1. constructs `isingPartitionPoly` for a finite graph,
2. computes coefficient slices by cardinality / directional specialization,
3. checks log-concavity / Newton inequalities on all one- and two-dimensional slices,
4. computes susceptibility numerators
   \[
   N_{ij} = \Phi \partial_i\partial_j \Phi - (\partial_i\Phi)(\partial_j\Phi),
   \]
5. compares actual support with aggregate shadow.

This should be reflected both in Lean (core verified routines where feasible) and in `demo.py` for experimentation.

**Suggested Python demo targets:**
- `K4`, `K5`, Petersen graph,
- several values of `β`,
- uniform couplings `J=1` and random positive couplings,
- output: pass/fail for slice inequalities, support exactness tables, and visualization of susceptibility support.

---

## Why This Would Be a Breakthrough

If successful, this would create a rigorous pathway from:

- **Lee–Yang stability** in statistical mechanics  
to
- **Lorentzian geometry of coefficients** in combinatorial Hodge theory  
to
- **anti-cancellation of observables** in thermal physics.

That is not an incremental extension. It would say that ferromagnetic equilibrium systems possess a hidden geometric rigidity preventing accidental disappearance of positive susceptibility signals under thermal averaging. In physical language: **thermal noise may blur correlations, but in the Lorentzian regime it cannot erase them by algebraic coincidence**.

This opens several fields at once:
- a Lorentzian theory of partition functions,
- new tools for susceptibility inequalities,
- a combinatorial-Hodge lens on phase transitions,
- possible analogues for Potts models, random cluster models, and determinantal measures.

---

## Cross-Domain Connections to Make Explicit

You must articulate at least one theorem or discussion point in each bridge:

- **Statistical physics ↔ Combinatorial Hodge theory**  
  Partition polynomials as Lorentzian objects; susceptibilities as shadow-preserving operators.

- **Statistical physics ↔ Probability theory**  
  Log-concavity / negative dependence / concentration for magnetization level weights.

- **Statistical physics ↔ Complex analysis**  
  Lee–Yang zero geometry as the analytic precursor of Lorentzianity.

- **Statistical physics ↔ Algorithms**  
  Lorentzian structure as a certificate for nonvanishing observables and potentially faster correlation screening.

**Application keywords:** ferromagnetic Ising model, Lorentzian polynomial, Lee–Yang theorem, susceptibility, anti-cancellation, combinatorial Hodge theory, log-concavity, negative dependence, partition function geometry, thermal correlations, stable polynomial, Gibbs measure, Hessian shadow, observable support exactness.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
- at least **one direction bridging to a different domain** such as quantum many-body systems, information theory, or matroid theory.

Possible next directions include:
- Potts/random-cluster Lorentzianity,
- strict Lorentzianity as a precursor to uniqueness/mixing,
- phase-transition signatures via degeneration of Hessian rank,
- information-geometric meaning of susceptibility shadows.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper containing:
- precise definitions,
- theorem statements,
- proof ideas,
- computational experiments,
- significance and limitations,
- future work.

Someone reading only this file must understand the discovery and why it matters.

### 3. `ARTICLE.md`
Write in **Scientific American style**:
- engaging,
- idea-centered,
- accessible to broad scientific readers.

**Taboo:** do **not** focus on formal verification machinery. Focus on the mathematics and physics.

### 4. Verified algorithm / computational method
Not just theorem statements. Include a real method for constructing and testing the partition polynomial and susceptibility shadow.

### 5. `demo.py`
Interactive or script-based demonstration that:
- builds example graphs,
- computes partition polynomials,
- tests Lorentzian slice inequalities,
- computes susceptibility numerators,
- checks support exactness,
- prints or plots informative diagnostics.

---

## Standard of Ambition

Do not merely verify small examples. Use them to guide and stress-test a theorem. The true target is a structural result of the form:

> **Ferromagnetic multiaffine partition polynomials lie in the Lorentzian world, and therefore positive second-order thermal observables obey anti-cancellation support exactness.**

That is a theorem family worthy of opening a new subfield.

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
