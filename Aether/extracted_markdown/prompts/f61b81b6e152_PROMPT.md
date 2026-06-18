Soli Deo Gloria

## Assignment: Direction 1: Spectral Tropical Stability — From Conjecture to Theorem

Prove a genuinely new spectral stability theorem for tropical persistent homology, not a cosmetic variant of existing edge-perturbation bounds. The target is to convert the current heuristic principle

\[
d_{tb}(F,\tilde F;N)\;\lesssim\; \frac{\varepsilon}{\lambda_*}
\]

into a precise, formally verified theorem with a certified algorithm that predicts tropical barcode stability from spectral data alone.

This is not merely an extension of `tropBarcodeDist_le_edgePerturbation`. The breakthrough is to show that **spectral connectivity acts as a quantitative stiffness parameter for tropical persistence**: highly connected filtration stages are provably resistant to metric perturbation, and the resistance is controlled by the Fiedler gap. If achieved, this opens a new field interface:

- **spectral graph theory ↔ tropical persistent homology**
- **metric geometry ↔ certified topological robustness**
- **Laplacian methods ↔ tropical invariants**
- **topological data analysis ↔ robustness theory for scientific pipelines**

The conceptual prize is large: one could estimate persistence stability **without recomputing the perturbed barcode**, using only graph spectra and perturbation size.

## Core theorem targets

You must prove at least 3 substantial theorems, with multi-step proofs using induction, `rcases`, `by_contra`, `field_simp`, or extended `calc` chains. Avoid trivial proof artifacts.

### New definitions required

Define at least one genuinely new concept not already in the catalog. Recommended core definition:

- `spectralGapFloor` for a finite filtration of graphs, recording the minimum positive Fiedler eigenvalue across connected stages.
- `spectrallyStableFiltration` expressing that barcode variation is bounded by perturbation size divided by this gap floor.
- optionally, `edgeSensitivityIndex`, measuring the maximum number of filtration-edge changes caused by an `ε` metric perturbation.

These definitions should be mathematically meaningful, not just wrappers.

---

## Precise theorem program

### Theorem 1: Spectral gap floor is positive on uniformly connected filtrations

Informal statement:
If every connected stage of a finite filtration has strictly positive algebraic connectivity and there are only finitely many stages, then the minimum positive Fiedler eigenvalue across connected stages is positive.

This is the compactness/finite-minimum lemma needed to make all later estimates non-vacuous.

### Suggested Lean 4 type signature
```lean
def spectralGapFloor
    (Fs : Fin N → SimpleGraph V) [Fintype V] [DecidableEq V] : ℝ :=
  sInf {x : ℝ | ∃ i : Fin N, x = fiedlerValue (Fs i) ∧ (Fs i).Connected}

theorem spectralGapFloor_pos
    (Fs : Fin N → SimpleGraph V) [Fintype V] [DecidableEq V]
    (hconn : ∀ i : Fin N, (Fs i).Connected)
    (hpos : ∀ i : Fin N, 0 < fiedlerValue (Fs i)) :
    0 < spectralGapFloor Fs
```

If `fiedlerValue` is not yet in the catalog, define a suitable surrogate spectral parameter first, possibly via a certified lower bound coming from cut expansion or nullity defect. If full spectral formalization is too heavy, prove the theorem for a new abstract parameter satisfying the spectral axioms, then instantiate it for the available graph Laplacian notion.

Why this matters:
This theorem turns the denominator `λ*` into a certified quantity. Without it, the conjecture is only slogan-level.

---

### Theorem 2: Edge perturbation bound from metric perturbation for Vietoris–Rips stages

Informal statement:
Let `X, X̃ : Fin n → ℝ^d` be finite point clouds with coordinatewise perturbation bounded by `ε`. Then at every threshold `r`, the symmetric difference in edge sets of the corresponding Vietoris–Rips graphs is controlled by the number of pair distances lying in an `ε`-dependent ambiguity window around `r`.

This is the geometric engine that converts metric perturbation into combinatorial perturbation.

### Suggested Lean 4 type signature
```lean
def ambiguousPairCount
    (X Y : Fin n → EuclideanSpace ℝ (Fin d)) (r ε : ℝ) : ℕ :=
  Fintype.card
    {p : Sym2 (Fin n) //
      |dist X p - r| ≤ 2 * ε ∨ |dist Y p - r| ≤ 2 * ε}

theorem vr_edgeSymmDiff_le_ambiguousPairCount
    (X Y : Fin n → EuclideanSpace ℝ (Fin d))
    (r ε : ℝ)
    (hε : 0 ≤ ε)
    (hpert :
      ∀ i : Fin n, ‖X i - Y i‖ ≤ ε) :
    edgeSymmDiffCard (vietorisRipsGraph X r) (vietorisRipsGraph Y r)
      ≤ ambiguousPairCount X Y r ε
```

A stronger theorem is even better:

```lean
theorem vr_edge_flip_of_distance_window
    (X Y : Fin n → EuclideanSpace ℝ (Fin d))
    (r ε : ℝ)
    (hε : 0 ≤ ε)
    (hpert : ∀ i : Fin n, ‖X i - Y i‖ ≤ ε) :
    ∀ p : Sym2 (Fin n),
      edgeMembershipDiff (vietorisRipsGraph X r) (vietorisRipsGraph Y r) p = true →
      |dist X p - r| ≤ 2 * ε
```

Why this matters:
This theorem identifies the exact geometric mechanism of instability: only near-threshold pairs can flip. It is the missing bridge between metric geometry and graph perturbation.

---

### Theorem 3: Spectral tropical barcode stability bound

Informal statement:
Assume a finite Vietoris–Rips filtration `F : Fin N → Graph` and a perturbed filtration `F̃`, and suppose each connected stage satisfies a uniform edge sensitivity estimate
\[
|E(F_i)\Delta E(\tilde F_i)| \le K_i \varepsilon/\lambda_2(F_i).
\]
Then the tropical barcode distance up to stage `N` is bounded by
\[
d_{tb}(F,\tilde F;N)\le \Big(\max_i K_i\Big)\frac{\varepsilon}{\lambda_*},
\qquad
\lambda_*=\min_i \lambda_2(F_i).
\]

This is the formal target that refines the catalog theorem `tropBarcodeDist_le_edgePerturbation`.

### Suggested Lean 4 type signature
```lean
def spectralGapFloorConnected
    (Fs : Fin N → SimpleGraph V) [Fintype V] [DecidableEq V] : ℝ :=
  sInf {x : ℝ | ∃ i : Fin N, (Fs i).Connected ∧ x = fiedlerValue (Fs i)}

theorem tropBarcodeDist_le_spectralPerturbation
    (F Ft : Fin N → SimpleGraph V) [Fintype V] [DecidableEq V]
    (K : Fin N → ℝ)
    (hconn : ∀ i : Fin N, (F i).Connected)
    (hK : ∀ i, 0 ≤ K i)
    (hgap : ∀ i, 0 < fiedlerValue (F i))
    (hedge :
      ∀ i : Fin N,
        edgeSymmDiffCard (F i) (Ft i)
          ≤ K i * ε / fiedlerValue (F i)) :
    tropBarcodeDist F Ft N
      ≤ (Finset.univ.sup K) * ε / spectralGapFloorConnected F
```

If `Finset.univ.sup K` is inconvenient over `ℝ`, use an explicit `Kmax` with hypotheses `∀ i, K i ≤ Kmax`.

A cleaner formal version may be:
```lean
theorem tropBarcodeDist_le_K_eps_div_gap
    (F Ft : Fin N → SimpleGraph V) [Fintype V] [DecidableEq V]
    (Kmax ε λstar : ℝ)
    (hε : 0 ≤ ε)
    (hK : ∀ i : Fin N, edgeSymmDiffCard (F i) (Ft i)
            ≤ Kmax * ε / fiedlerValue (F i))
    (hgap : ∀ i : Fin N, λstar ≤ fiedlerValue (F i))
    (hgap_pos : 0 < λstar)
    (hconn : ∀ i : Fin N, (F i).Connected) :
    tropBarcodeDist F Ft N ≤ Kmax * ε / λstar
```

Why this matters:
This is the actual field-opening theorem. It says spectral connectivity controls tropical topological stability. That principle is new, nontrivial, and reusable.

---

### Theorem 4: Cross-domain bridge via Cheeger-type lower bounds

You must include at least one theorem connecting to another domain. The recommended bridge is:

- **spectral graph theory ↔ isoperimetry / discrete geometric analysis**
- or **spectral graph theory ↔ chip-firing / tropical divisors**

Candidate theorem:
If a connected graph stage has Cheeger constant bounded below by `h`, then any tropical barcode perturbation estimate depending on `1 / λ₂` can be converted into an estimate depending on `1 / h^2` using a Cheeger lower bound.

### Suggested Lean 4 type signature
```lean
theorem tropBarcodeDist_le_cheegerPerturbation
    (F Ft : Fin N → SimpleGraph V) [Fintype V] [DecidableEq V]
    (Kmax ε hmin c : ℝ)
    (hcheeger : ∀ i : Fin N, hmin ≤ cheegerConstant (F i))
    (hcheeger_pos : 0 < hmin)
    (hλ : ∀ i : Fin N, c * hmin^2 ≤ fiedlerValue (F i))
    (hedge :
      ∀ i : Fin N,
        edgeSymmDiffCard (F i) (Ft i)
          ≤ Kmax * ε / fiedlerValue (F i)) :
    tropBarcodeDist F Ft N ≤ Kmax * ε / (c * hmin^2)
```

Alternative cross-domain bridge:
Use `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean` to derive that graphs with larger genus or stronger chip-firing rigidity exhibit constrained tropical nullity variation, then propagate this to barcode stability. Even a one-direction theorem here would be a striking conceptual connection.

Why this matters:
This turns the theorem into a transport principle: one can import lower bounds from geometric analysis or tropical divisor theory into persistence stability.

---

## Recommended proof architecture

### Strategy A: Geometric-to-combinatorial-to-tropical pipeline
Most promising.

1. Prove a **distance perturbation lemma** for pairwise distances under point perturbation:
   \[
   |\|x_i-x_j\|-\|\tilde x_i-\tilde x_j\|| \le 2\varepsilon.
   \]
   This should require triangle inequality and multi-step `calc`.

2. Deduce that an edge can only flip if the original or perturbed pair distance lies in a `2ε` ambiguity window around the VR threshold.

3. Use `tropBarcodeDist_le_edgePerturbation` from `Catalog/Pythagorean/TropicalPersistentHomology.lean` to convert the edge symmetric difference estimate into a tropical barcode estimate.

4. Insert the spectral hypothesis
   \[
   |E\Delta \tilde E| \le K\varepsilon/\lambda_2
   \]
   and minimize over stages using `spectralGapFloor_pos`.

Why this is best:
It directly leverages the catalog and isolates the new contribution in a way Lean can handle modularly.

---

### Strategy B: Isoperimetric route via Cheeger inequality
Potentially more revolutionary.

1. Formalize or abstract a Cheeger-type lower bound:
   \[
   \lambda_2(G)\ge c\, h(G)^2.
   \]

2. Prove that low ambiguity in metric neighborhoods implies bounded cut-instability, hence bounded edge symmetric difference in terms of `1/h(G)^2`.

3. Push this through tropical persistence stability.

Why this is powerful:
It reveals that **topological stability is controlled by discrete geometric expansion**, not just spectral numerics. This is the right route if you want a theorem people will remember.

---

### Strategy C: Tropical divisor / chip-firing route
Most speculative but potentially paradigm-shifting.

1. Use graph Laplacian and chip-firing correspondences from `ChipFiringCorrespondence.lean` to interpret Fiedler positivity as a rigidity property for divisor flow or tropical linear systems.

2. Show that perturbing VR edges changes tropical nullity only when chip-firing classes cross a controlled threshold.

3. Deduce barcode stability through tropical nullity stability.

Why this matters:
If successful, it would connect spectral persistence to tropical Brill–Noether style structures, opening an entirely new interface between TDA and tropical algebraic geometry.

---

## Building blocks from the catalog

Use these explicitly and explain how they enter:

- `Catalog/Pythagorean/TropicalPersistentHomology.lean`
  - `tropNullity_stable_under_edgeSymmDiff`
  - `tropBarcodeDist_le_edgePerturbation`

  These are the key transport lemmas from graph perturbation to tropical persistence. Your theorem should be a strict strengthening by replacing a raw edge perturbation parameter with a **spectrally certified edge perturbation bound**.

- `Catalog/Pythagorean/TropicalBridge/ChipFiringCorrespondence.lean`
  - `graphLap`
  - `genus_nonneg_of_connected`

  At minimum, use `graphLap` as the algebraic object mediating between graph structure and spectral behavior. If possible, define your spectral parameter using this Laplacian. `genus_nonneg_of_connected` can support connected-stage structural lemmas and may help bridge toward tropical divisor interpretations.

Do not merely cite these. Build on them.

---

## Required falsifiable conjecture

State and test at least one conjecture with a clear computational refutation path. Recommended:

### Conjecture: Uniform spectral exponent
There exists a universal exponent `α = 1` and dimension-dependent constant `C_d` such that for all finite point clouds `X, Y ⊂ ℝ^d` with pointwise perturbation at most `ε`, and all finite VR filtrations up to stage `N`,
\[
d_{tb}(F_X,F_Y;N) \le C_d \cdot \frac{\varepsilon}{\lambda_*}.
\]

### Testable prediction
For synthetic point clouds with varying cluster separation and controlled Fiedler floor, the empirical ratio
\[
\frac{d_{tb}(F_X,F_Y;N)\,\lambda_*}{\varepsilon}
\]
remains bounded as `λ* → 0` only if the correct exponent is `α = 1`; if instead this ratio diverges but
\[
\frac{d_{tb}(F_X,F_Y;N)\,\lambda_*^\alpha}{\varepsilon}
\]
stabilizes for some `α ≠ 1`, then the conjecture is false.

Also test a stronger conjecture:
- in random geometric graph regimes, `C(d,n)` grows at most polylogarithmically in `n`.

This is scientifically valuable because it can fail.

---

## New structure suggestions

At least one of these should be introduced:

```lean
structure SpectralStabilityCertificate (V : Type _) [Fintype V] [DecidableEq V] where
  F Ft : Fin N → SimpleGraph V
  ε : ℝ
  λstar : ℝ
  Kmax : ℝ
  hε : 0 ≤ ε
  hλstar : 0 < λstar
  hgap : ∀ i : Fin N, λstar ≤ fiedlerValue (F i)
  hedge : ∀ i : Fin N,
    edgeSymmDiffCard (F i) (Ft i) ≤ Kmax * ε / fiedlerValue (F i)
```

and then prove:

```lean
theorem SpectralStabilityCertificate.bound
    (C : SpectralStabilityCertificate V) :
    tropBarcodeDist C.F C.Ft N ≤ C.Kmax * C.ε / C.λstar
```

This is mathematically clean and computationally useful: it packages the theorem as a reusable certificate.

---

## Cross-domain connections to emphasize

You must explicitly include at least one theorem or discussion point connecting to another domain. Strong options:

- **Spectral graph theory ↔ TDA**: Fiedler gap as a persistence stiffness parameter.
- **Metric geometry ↔ TDA**: pairwise distance ambiguity windows govern topological instability.
- **Discrete geometric analysis ↔ persistence**: Cheeger constants imply barcode robustness.
- **Tropical geometry ↔ spectral theory**: graph Laplacians and tropical nullity interact through chip-firing structures.
- **Physics connection**: interpret `λ₂` as the slowest relaxation mode of a diffusion process; then the theorem says slowly mixing graphs are topologically fragile, while rapidly mixing graphs are topologically rigid under metric noise.
- **Network science**: robust community structure predicts stable topological summaries.
- **Manifold learning**: spectral gaps of neighborhood graphs can certify persistence reliability before full homology computation.

---

## Application keywords

Include these explicitly in your writeup and metadata:

**Application keywords:** tropical persistent homology, spectral graph theory, Fiedler eigenvalue, algebraic connectivity, Vietoris–Rips filtration, metric perturbation, Cheeger inequality, chip-firing, graph Laplacian, certified robustness, topological data analysis, geometric stability, network resilience, manifold learning, diffusion geometry.

---

## Mandatory deliverables

You must produce ALL of the following:

1. **Lean file(s)** with at least 3 nontrivial theorems and at least one novel definition, minimizing `sorry`.
2. **A verified algorithm or computational method**:
   - Given a finite point cloud and perturbation radius `ε`, compute a certified upper bound for tropical barcode drift using either exact or lower-bounded spectral gaps.
   - If exact `λ₂` is unavailable in Lean, implement a provably sound surrogate certificate using lower bounds from connectivity, expansion, or catalog Laplacian data.
3. **`demo.py`**
   - Generate point clouds with tunable cluster separation.
   - Build VR graph stages.
   - Estimate or compute `λ₂`.
   - Perturb the cloud.
   - Compare observed tropical barcode drift against the certified spectral upper bound.
   - Plot the ratio \(d_{tb}\lambda_*/\varepsilon\) and test whether it remains bounded.
4. **`RESEARCH_PAPER.md`**
   - Standalone scientific paper.
   - Must explain the theorem, proof architecture, computational experiments, significance, limitations, and next steps.
   - A reader with no access to the code must understand the discovery.
5. **`ARTICLE.md`**
   - Scientific American style.
   - Focus on the mathematical idea: why spectral connectivity can predict topological stability.
   - Do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions.
   - Each direction must contain the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as diffusion physics, statistical mechanics, or geometric group theory.

---

## Standard of ambition

Do not settle for “edge perturbation plus a renamed constant.” The goal is to show that **spectral information predicts tropical topological stability in a theorem-level way**. If you can prove even a restricted but sharp version—for example, for path-like clustered graphs, random geometric graph regimes, or filtrations with uniform spectral gap lower bounds—you will have created a new conceptual tool.

A successful outcome should make a researcher say:

> I knew barcodes were stable under perturbations, and I knew λ₂ measures connectivity, but I had never imagined that algebraic connectivity could quantitatively certify tropical persistence stability.

That is the bar.

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
