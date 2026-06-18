## Assignment: Gauge Invariance for Charged Tropical Distances

**Mode:** prove

Prove a genuinely new gauge-invariance theorem for charged tropical path metrics on weighted directed graphs, and formalize it in Lean 4 with statements strong enough to become the backbone of a future tropical electromagnetic geometry library.

The core phenomenon is simple and profound: a discrete gauge field of the form
\[
A(i,j)=\varphi(j)-\varphi(i)
\]
should contribute zero net circulation along every path, so the charged tropical action differs from the uncharged one only by endpoint terms. This is the tropical/discrete analogue of exact 1-forms in gauge theory, and once formalized cleanly it opens an entire field: tropical gauge geometry, tropical Hamilton–Jacobi theory on graphs, magnetic shortest-path dualities, and categorical transport laws under graph transformations.

You should aim not merely to prove “some invariance lemma,” but to establish the exact endpoint-shift law and its metric corollaries.

---

## Precise Theorem Target

Let `V` be a finite vertex type, `w : V → V → ℝ` a base edge weight, `A : V → V → ℝ` a charge/potential term, and let the charged edge weight be
\[
w_A(i,j)=w(i,j)+A(i,j).
\]
Assume `A` is pure gauge:
\[
\forall i j,\quad A(i,j)=\varphi(j)-\varphi(i).
\]
Then for every finite path `p` from `s` to `t`, the charged path weight satisfies
\[
\mathrm{weight}_{w_A}(p)=\mathrm{weight}_w(p)+\varphi(t)-\varphi(s).
\]
Consequently, the tropical charged distance satisfies
\[
d_{w_A}(s,t)=d_w(s,t)+\varphi(t)-\varphi(s),
\]
and in particular the gauge-invariant loop distance is unchanged:
\[
d_{w_A}(v,v)=d_w(v,v).
\]

If your current library defines charged distance using a `chargedWeight` construction, formulate the theorem directly through that API rather than rebuilding infrastructure.

### Lean 4 type-signature target

Adapt names to the actual library, but the intended shape should be as close as possible to:

```lean
theorem charged_pathWeight_pureGauge
    {V : Type*} [Fintype V] [DecidableEq V]
    (w A : V → V → ℝ) (φ : V → ℝ)
    (p : List V)
    (hp : p ≠ [])
    (hA : ∀ i j, A i j = φ j - φ i) :
    pathWeight (fun i j => w i j + A i j) p
      = pathWeight w p + φ p.getLast hp - φ p.head! := by
  ...

theorem chargedDist_pureGauge
    {V : Type*} [Fintype V] [DecidableEq V]
    (w A : V → V → ℝ) (φ : V → ℝ)
    (hA : ∀ i j, A i j = φ j - φ i)
    (s t : V) :
    chargedDist w A s t = dist w s t + φ t - φ s := by
  ...

theorem chargedDist_pureGauge_loop
    {V : Type*} [Fintype V] [DecidableEq V]
    (w A : V → V → ℝ) (φ : V → ℝ)
    (hA : ∀ i j, A i j = φ j - φ i)
    (v : V) :
    chargedDist w A v v = dist w v v := by
  ...
```

If your path objects are not `List V` but a bespoke structure of composable edges, strengthen the theorem accordingly:
- first a path-level telescoping identity,
- then an infimum/minimum-over-paths theorem,
- then corollaries for loops, geodesics, and tropical Einstein equations.

---

## Stronger Breakthrough Variant

If the definitions in the catalog permit, prove the following more conceptual theorem:

```lean
theorem chargedDist_eq_dist_conjugatedByPotential
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℝ) (φ : V → ℝ) (s t : V) :
    chargedDist w (fun i j => φ j - φ i) s t
      = dist w s t + φ t - φ s := by
  ...
```

This is the discrete tropical analogue of gauge conjugation. It says the charged semigroup is not merely invariant in some weak sense; it is *cohomologically trivial* when the field is exact. That is the theorem that changes the vocabulary of the subject.

---

## Why This Is a Breakthrough

This result is not just a path-sum identity. It establishes the first rigorous bridge between:

- **tropical shortest-path geometry** and **discrete gauge theory**,
- **exact 1-forms / pure gauges** and **endpoint renormalization of tropical actions**,
- **magnetic graph operators** and **min-plus transport semigroups**.

Once formalized, this theorem becomes the normal form reduction principle for charged tropical systems:
every exact field can be eliminated globally, reducing analysis to the uncharged problem plus a boundary term. That immediately suggests a decomposition of charged tropical geometry into:
1. exact/gauge-trivial fields, and
2. genuine cohomological obstructions carried by cycle holonomies.

That is a field-opening dichotomy.

---

## Proof Strategy Architecture

### Strategy A: Direct path telescoping, then infimum transfer
This is the most promising route.

1. **Path-level telescoping identity.**  
   Expand the charged path weight:
   \[
   \sum_k \bigl(w(v_k,v_{k+1}) + \varphi(v_{k+1})-\varphi(v_k)\bigr).
   \]
   Rearrange into
   \[
   \sum_k w(v_k,v_{k+1}) + \sum_k(\varphi(v_{k+1})-\varphi(v_k)),
   \]
   then prove the second sum telescopes to `φ t - φ s`.

2. **Transport through tropical minimization.**  
   Since the endpoint correction is path-independent for fixed endpoints, pull it out of the infimum/minimum over all `s → t` paths:
   \[
   \inf_p \bigl(\mathrm{weight}_w(p)+\varphi(t)-\varphi(s)\bigr)
   = \inf_p \mathrm{weight}_w(p)+\varphi(t)-\varphi(s).
   \]

3. **Loop and geodesic corollaries.**  
   Set `s = t` to get loop invariance. Then derive that minimizing charged geodesics are exactly minimizing uncharged geodesics after gauge correction.

Why this is best: it is robust, transparent, and likely closest to existing definitions built from `chargedWeight` substitution.

---

### Strategy B: Algebraic conjugation of tropical linear operators
This is more conceptual and could produce stronger follow-up theorems.

1. Define the tropical transfer operator
   \[
   (T_A f)(i)=\inf_j \bigl(w(i,j)+A(i,j)+f(j)\bigr).
   \]

2. For pure gauge `A(i,j)=φ(j)-φ(i)`, prove the conjugation identity
   \[
   T_A f = -\varphi + T_0(f+\varphi)
   \]
   in pointwise tropical notation.

3. Deduce distance/generator invariance by iterating the operator and evaluating on boundary conditions.

Why it matters: this upgrades path combinatorics into a semigroup statement, connecting directly to dynamic programming, Bellman equations, and tropical spectral theory.

---

### Strategy C: Cohomological formulation via vanishing cycle holonomy
This is the boldest route if the graph/cycle API already exists.

1. Define the circulation of `A` around a cycle and prove exact fields have zero circulation.

2. Show that if all circulations vanish, path integrals depend only on endpoints, hence define a potential difference.

3. Specialize to pure gauge and recover charged distance invariance.

Why this matters: it sets up the next theorem beyond this one — classification of gauge equivalence classes by tropical graph cohomology / cycle holonomy. This is the path to genuinely new mathematics, but it may require more infrastructure.

---

## Build Explicitly on Existing Infrastructure

The prompt says most results reduce to the standard tropical Einstein equation via `chargedWeight` substitution. Use that aggressively.

You should search for and exploit:
- any theorem stating that charged constructions are definitional rewrites of uncharged ones under `chargedWeight`,
- path-sum lemmas over lists/finsets that can telescope,
- lemmas about `inf`, `sInf`, `iInf`, or `min` commuting with addition by a constant,
- any previously certified shortest-path or tropical Einstein identities.

Even though the currently listed verified theorems are from distant parts of the catalog, use their *style* as guidance: prove a structural theorem, not a one-off computation. In particular, `tropical_security_from_norm_bound` and `tropical_add_not_cancellative` indicate the library is comfortable with nonclassical algebraic phenomena; your theorem should likewise isolate a structural invariant of the min-plus world.

---

## Formalization Targets

Prioritize the following theorem stack.

### 1. Telescoping lemma for pure gauges
A reusable summation lemma, independent of distances.

Possible shape:
```lean
theorem sum_pureGauge_along_path
    {V : Type*} [DecidableEq V]
    (φ : V → ℝ) (p : List V) (hp : p ≠ []) :
    gaugeSum (fun i j => φ j - φ i) p
      = φ p.getLast hp - φ p.head! := by
  ...
```

This lemma should become a library primitive.

### 2. Charged path weight decomposition
```lean
theorem pathWeight_add_pureGauge
    ...
    :
    pathWeight (chargedWeight w (fun i j => φ j - φ i)) p
      = pathWeight w p + φ ... - φ ... := by
  ...
```

### 3. Distance-level gauge law
```lean
theorem chargedDist_pureGauge
    ...
```

### 4. Gauge invariance of tropical Einstein/min-plus Bellman equations
If a theorem already expresses the charged tropical Einstein equation in terms of charged distances or transfer operators, prove that pure gauge transforms conjugate solutions.

A model statement:
```lean
theorem pureGauge_transforms_einstein_solution
    ...
```

This would be especially strong: it says the PDE/dynamic-programming content is preserved under gauge.

---

## Cross-Domain Connections You Should Make Explicit in the Development

Do not leave these as motivational remarks; shape the theorem statements and corollaries so they visibly support these interpretations.

### 1. Electromagnetic geodesics in discrete/tropical relativity
Pure electromagnetic gauge transformations do not alter physical path comparisons except through endpoint phase/potential shifts. Your theorem is the tropical counterpart of gauge-invariant action principles.

### 2. Financial networks with transaction potentials
If `φ(v)` is a node potential encoding local accounting convention, credit offset, or tax basis, then edge charges of the form `φ(j)-φ(i)` are bookkeeping artifacts. The theorem proves that arbitrage-adjusted transport costs are invariant up to endpoint normalization.

### 3. Routing with toll offsets
If tolls are imposed as entering-minus-leaving terminal surcharges, shortest routes do not change internally; only source/target labels shift. This gives an exact theorem for when “dynamic tolling” is operationally fake.

### 4. Magnetic Laplacians and exact discrete connections
In ordinary spectral graph theory, exact magnetic potentials are gauge-trivial. Your theorem is the min-plus analogue and should be presented as such. This creates a bridge between tropical analysis and magnetic operator theory.

### 5. Cohomology of graph 1-forms
Exact forms are invisible to tropical distances except at endpoints. This is the first step toward a tropical Hodge-type decomposition on graphs: exact, coexact, and harmonic charged fields.

---

## Application Keywords

Include these in theorem docs/comments and FUTURE_DIRECTIONS:

- tropical gauge theory
- min-plus electromagnetism
- charged tropical distance
- discrete gauge invariance
- graph cohomology
- magnetic shortest paths
- tropical Hamilton–Jacobi
- Bellman operator conjugation
- exact 1-forms on graphs
- tropical transport geometry
- network pricing invariance
- min-plus magnetic Laplacian

---

## Concrete Deliverables

1. **A clean Lean theorem proving path telescoping for pure gauges.**
2. **A distance-level gauge invariance theorem with endpoint correction.**
3. **At least one corollary for loops or geodesics.**
4. **Minimize sorry** by proving helper lemmas instead of bypassing them.
5. **Document all theorem names and file paths clearly.**
6. **Produce `FUTURE_DIRECTIONS.md`** with 3–5 concrete next-step theorems.

---

## Required FUTURE_DIRECTIONS.md Content

Your `FUTURE_DIRECTIONS.md` must include 3–5 specific next targets, such as:

1. **Gauge classification by cycle holonomy**  
   Prove that two charge fields give the same charged tropical distances up to endpoint potential iff their difference has zero circulation on every cycle.

2. **Functoriality under graph surgeries**  
   Formalize how edge insertion/deletion and weight updates act on charged tropical distance operators, and identify which surgeries preserve gauge classes.

3. **Tropical magnetic Bellman theory**  
   Show pure gauge conjugation for the full min-plus transfer semigroup and deduce invariance of value functions.

4. **Cohomological obstruction theorem**  
   Define a first tropical graph cohomology class for charge fields and prove that gauge-triviality is equivalent to vanishing class.

5. **Spectral/tropical bridge theorem**  
   Relate exact magnetic perturbations of graph Laplacians to pure-gauge perturbations of tropical shortest-path operators.

---

## Final Instruction

Be bold: prove the endpoint-shift theorem in its strongest natural form, not a weak special case. The real target is to establish that exact gauge fields are cohomologically trivial for tropical transport. Once this is formalized, the next generation of results — holonomy, tropical electromagnetism, graph cohomology, and categorical graph surgery functors — becomes inevitable.

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

Research domain: Tropical
Research mode: prove
