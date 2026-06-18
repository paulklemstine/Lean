Soli Deo Gloria

## Assignment: Direction 3 — Certified Expanders for Classical Groups, Recast as a Representation-Theoretic Expansion Program

You should not treat this as a routine extension of `GL₂`. The real opportunity is to isolate **formal, checkable generation certificates** for finite classical groups that force **quasirandomness-driven spectral expansion** of Cayley graphs, and then to turn those certificates into a verified computational pipeline. The breakthrough is not “another expander family”; it is a **uniform certification principle** for major Lie-type families that connects finite group generation, maximal tori, character bounds, and algorithmic graph expansion.

Build on:

- `Catalog/Algebra/MatrixGroupGeneration.lean`

especially any invariant-subspace or irreducibility criteria already certified there. The crucial move is to replace ad hoc matrix calculations by a **certificate architecture**:

1. a structural certificate proving the subgroup generated is not trapped in a proper geometric subgroup;
2. a noncommutativity / non-normalization certificate excluding toral collapse;
3. a representation-theoretic transfer from generation to spectral gap for the averaging operator.

Your target is a theorem package with at least one new definition, at least three genuinely nontrivial theorems, and a verified algorithm for testing certificates in small cases.

---

## Core Vision

For classical groups, “Singer-like” should mean: an element whose action is irreducible or torally regular in the natural module, so that its centralizer is as small as possible (typically a maximal torus or close to one). The second generator should violate all obvious geometric stabilizers. If you can formalize a criterion saying:

> a regular semisimple toral element together with a certificate-breaking element generates a Zariski-dense-style finite subgroup, hence in the finite classical setting the whole derived classical group or a large canonical subgroup,

then the averaging operator on the resulting Cayley graph should inherit a provable spectral gap from quasirandomness and explicit character bounds in small certified examples.

This opens a route to **uniform certified expanders across Lie type**, with applications to coding theory, pseudorandom network design, and verified symbolic computation in finite groups.

---

## Precise Formalization Targets

### New definitions you should introduce

At least one of the following must be formalized as a genuinely new concept.

1. **Certificate predicate for classical generators**
```lean
def ClassicalCertificate
    {F : Type*} [Field F]
    {V : Type*} [AddCommGroup V] [Module F V]
    (G : Type*) [Group G] [SetLike G]
    (ρ : G →* Module.End F V)
    (s t : G) : Prop := ...
```

Interpretation: `s` is a regular-semisimple / Singer-like element for the given classical action, `t` breaks all invariant decompositions compatible with the form, and `⟨s,t⟩` is not contained in a designated family of geometric subgroups.

2. **Certified spectral gap for a symmetric generating set**
```lean
def HasCertifiedGap
    (G : Type*) [Fintype G] [Group G]
    (S : Finset G) (ε : ℝ) : Prop := ...
```

Interpretation: the normalized averaging operator on functions `G → ℂ` has second largest operator norm at most `1 - ε`.

3. **Regular toral element in a classical action**
```lean
def IsRegularToral
    {F : Type*} [Field F]
    {V : Type*} [AddCommGroup V] [Module F V]
    (u : Module.End F V) : Prop := ...
```

A useful implementation may be “minimal polynomial equals characteristic polynomial and is separable,” or any equivalent certified condition available in Mathlib.

---

## Exact theorem statements to aim for

You do **not** need to formalize all classical groups at once. It is better to prove one clean abstract theorem and then instantiate it for one or two concrete families (`Sp₄(𝔽₃)`, `SO₃(𝔽₅)`), with a roadmap for `SU_n`.

### Theorem 1 — Irreducibility / no-invariant-subspace generation criterion

This should be your foundational structural theorem.

**Mathematical statement**

Let `F` be a finite field, `V` a finite-dimensional `F`-vector space equipped with a classical form, and `G ≤ GL(V)` the corresponding classical group (symplectic, orthogonal, or unitary where formalizable). Suppose `s ∈ G` is regular toral, and `t ∈ G` does not preserve any proper nontrivial `s`-stable form-compatible subspace decomposition. Then the subgroup `H = ⟨s,t⟩` acts irreducibly on `V`.

A Lean target could look like:
```lean
theorem classical_certificate_irreducible
    {F : Type*} [Field F] [Fintype F]
    {V : Type*} [AddCommGroup V] [Module F V] [FiniteDimensional F V]
    (G : Type*) [Group G]
    (ρ : G →* Module.End F V)
    (s t : G)
    (hcert : ClassicalCertificate G ρ s t) :
    Irreducible F (Subgroup.closure ({s, t} : Set G)).toModule ?_ := ...
```

If this exact `Irreducible` packaging is awkward in Lean, replace by an equivalent theorem:

```lean
theorem classical_certificate_no_proper_invariant_submodule
    ...
    (hcert : ClassicalCertificate G ρ s t) :
    ¬ ∃ W : Submodule F V,
        W ≠ ⊥ ∧ W ≠ ⊤ ∧
        ∀ g ∈ Subgroup.closure ({s, t} : Set G), ∀ w ∈ W, ρ g w ∈ W := ...
```

This theorem should use the catalog invariant-subspace theorem as a major building block.

### Theorem 2 — Generation upgrade inside a finite classical group

**Mathematical statement**

Let `G` be a finite classical group in its natural module. If `s,t ∈ G` satisfy the classical certificate and additionally fail all scalar/center obstructions, then `⟨s,t⟩` is not contained in any proper geometric maximal subgroup of Aschbacher type relevant to the chosen family. In small rank cases this implies `⟨s,t⟩ = G` (or at least contains the derived subgroup).

Suggested Lean target:
```lean
theorem classical_certificate_generates_large_subgroup
    {G : Type*} [Group G] [Fintype G]
    (s t : G)
    (hcert : ClassicalCertificate G ρ s t)
    (hcenter : ¬ Subgroup.closure ({s, t} : Set G) ≤ center G) :
    IsLargeClassicalSubgroup (Subgroup.closure ({s, t} : Set G)) := ...
```

For a concrete family:
```lean
theorem certified_pair_generates_Sp4_F3
    (s t : Sp4F3)
    (hcert : Sp4Certificate s t) :
    Subgroup.closure ({s, t} : Set Sp4F3) = ⊤ := ...
```

If a full `Sp4F3` concrete type is too expensive, define the finite matrix group directly as a subtype of `Matrix (Fin 4) (Fin 4) (ZMod 3)` preserving a fixed symplectic form.

### Theorem 3 — Spectral gap transfer from certified generators

This is the cross-domain theorem linking group theory to spectral graph theory / random walks.

**Mathematical statement**

For a finite group `G` and symmetric generating set `S = {s, s⁻¹, t, t⁻¹}`, if every nontrivial irreducible representation of `G` has dimension at least `m` and the character ratios of `s,t` satisfy an explicit bound, then the second eigenvalue of the normalized Cayley averaging operator is bounded by `1 - ε(m,s,t)`.

Lean-style target:
```lean
theorem certified_gap_of_quasirandomness
    {G : Type*} [Group G] [Fintype G]
    (s t : G) (ε : ℝ)
    (hsym : s ≠ 1 ∧ t ≠ 1)
    (hgen : Subgroup.closure ({s, t} : Set G) = ⊤)
    (hqr : QuasirandomnessLowerBound G m)
    (hchar : CharacterRatioBound G s t ε) :
    HasCertifiedGap G ({s, s⁻¹, t, t⁻¹}.toFinset) ε := ...
```

If a full character-theoretic theorem is too ambitious in first pass, prove a concrete finite version by direct operator estimates for enumerated groups:
```lean
theorem certified_gap_Sp4_F3
    (s t : Sp4F3)
    (hcert : Sp4Certificate s t) :
    ∃ ε > 0, HasCertifiedGap Sp4F3 ({s, s⁻¹, t, t⁻¹}.toFinset) ε := ...
```

This is already scientifically meaningful if accompanied by a verified computation of the gap.

### Theorem 4 — Cross-domain bridge to coding theory or geometry

You are required to include at least one theorem connecting to a different domain. The cleanest route is coding theory or algebraic geometry.

#### Option A: Coding theory bridge
Show that expansion of the Cayley graph yields a combinatorial boundary inequality relevant to expander codes.

```lean
theorem cayley_expansion_implies_vertex_boundary
    {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (ε : ℝ)
    (hgap : HasCertifiedGap G S ε) :
    ∀ A : Finset G, A.card ≤ Fintype.card G / 2 →
      ∃ c > 0, c = ε / 2 ∧
      c * A.card ≤ (vertexBoundary S A).card := ...
```

#### Option B: Algebraic-geometry bridge
Formalize that regular toral elements correspond to rational points on a dense open subset of a torus parameter space. Even a finite-field counting lemma here would be a strong conceptual bridge.

```lean
theorem regular_toral_elements_form_dense_open_counting_set
    ...
```

Option A is more likely to be tractable and has immediate applications.

---

## Recommended proof strategies

You asked for 2–3 proof strategy steps; here are three distinct routes. Use at least two in your development.

### Strategy A — Invariant-subspace exclusion via toral eigenspaces
**Most promising for the structural theorem.**

1. Use the catalog theorem from `Catalog/Algebra/MatrixGroupGeneration.lean` to reduce generation questions to exclusion of proper invariant subspaces.
2. Show that a regular toral / Singer-like element `s` has a rigid decomposition of `V` into minimal `s`-stable pieces.
3. Prove that if `t` does not preserve any union of those pieces compatible with the classical form, then no proper nontrivial `⟨s,t⟩`-stable subspace exists.

Why this is promising: it converts a group-generation problem into linear algebra over finite fields, which Lean handles much better than deep subgroup classification.

### Strategy B — Geometric subgroup exclusion in the style of Aschbacher classes
**Best for the generation upgrade theorem in small rank.**

1. Define a finite list of “forbidden certificates”: reducible, imprimitive, extension-field, form-decomposition, scalar-normalizer.
2. Prove your `ClassicalCertificate` excludes each forbidden class by contradiction (`by_contra` will be useful).
3. In concrete groups (`Sp₄(𝔽₃)`, `SO₃(𝔽₅)`), finish by finite classification of maximal subgroups or direct enumeration.

Why this is promising: you can avoid formalizing the full Aschbacher theorem while still capturing its logic in the low-rank cases that matter computationally.

### Strategy C — Averaging operator / representation-theoretic spectral estimate
**Best for the expander theorem and cross-domain bridge.**

1. Define the normalized adjacency / averaging operator on `ℂ`-valued functions on `G`.
2. Split the regular representation into constants plus orthogonal complement.
3. Bound the operator norm on the orthogonal complement using either:
   - explicit enumeration in small groups, or
   - a quasirandomness lower bound plus character ratio estimates.

Why this is promising: it yields a verified algorithm and gives the project scientific weight beyond pure generation.

---

## Concrete implementation milestones

### Phase I — Abstract certificate layer
Formalize:

- `IsRegularToral`
- `ClassicalCertificate`
- `HasCertifiedGap`

Prove at least one theorem using:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp`,
- and multi-step `calc`.

These should not be cosmetic; they should be mathematically essential.

### Phase II — Two explicit case studies
Implement and test at least:

- `Sp₄(𝔽₃)`
- `SO₃(𝔽₅)`

For each:

1. define the group concretely as a matrix-preserving subtype;
2. enumerate candidate certified pairs;
3. build the symmetric Cayley graph;
4. compute eigenvalues of the normalized adjacency matrix;
5. extract a certified numerical spectral gap.

### Phase III — Comparison theorem with `GL₂`
Prove or computationally verify a theorem/lemma comparing certificate density or average gap between your classical-group examples and the existing `GL₂` family.

A useful target:
```lean
theorem exists_certified_pair_with_positive_gap_compare_GL2 :
  ∃ ε₁ ε₂ > 0, ε₁ ≤ ε₂ := ...
```
But better is a substantive statement about certificate frequency or lower bounds on gap.

---

## Suggested falsifiable conjecture

You are required to state a conjecture with a computational disproof route. Here is the right one:

### Conjecture: Uniform low-rank certified expansion
For every odd prime power `q`, there exists `ε > 0` independent of `q` such that `Sp₄(𝔽_q)` admits a certified pair `(s,t)` with symmetric generating set `S = {s,s⁻¹,t,t⁻¹}` satisfying
\[
\lambda_2(\mathrm{Cay}(Sp_4(\mathbb F_q),S)) \le 1 - \varepsilon.
\]

A Lean-adjacent declaration:
```lean
conjecture uniform_certified_gap_Sp4_odd_q :
  ∃ ε : ℝ, ε > 0 ∧
    ∀ q : ℕ, Odd q → IsPrimePower q →
      ∃ (G : Type) (_ : Group G) (_ : Fintype G),
        IsSp4Over q G ∧
        ∃ s t : G, HasCertifiedGap G ({s, s⁻¹, t, t⁻¹}.toFinset) ε
```

**Testable prediction:** enumerate certified pairs for `q = 3,5,7,9` and compute the second eigenvalue. The conjecture is falsified if the best certified gap tends toward `0` or if no certified pair exists for some tested `q`.

This is scientifically valuable because it predicts a **uniform expander mechanism from intrinsic group certificates**, not from random generation alone.

---

## Cross-domain connections you must explicitly develop

1. **Finite group theory ↔ spectral graph theory**  
   Certified generation gives explicit expander Cayley graphs.

2. **Finite classical groups ↔ coding theory**  
   Expanders from symplectic/orthogonal groups can feed into Tanner-code constructions and robust network topologies.

3. **Finite groups of Lie type ↔ algebraic geometry**  
   Regular semisimple / toral elements are shadows of maximal tori and Deligne–Lusztig geometry. Even if you do not formalize Deligne–Lusztig theory, explain in `RESEARCH_PAPER.md` how your certificates are finite, checkable avatars of geometric genericity.

4. **Representation theory ↔ algorithm design**  
   Spectral-gap certification becomes a verified computational primitive for constructing pseudorandom objects.

---

## Application keywords

Use these explicitly in the paper and article:

- finite classical groups
- Cayley expanders
- certified generation
- regular semisimple elements
- maximal tori
- quasirandom groups
- spectral gap
- random walks on groups
- coding theory
- network design
- pseudorandomness
- Deligne–Lusztig philosophy
- representation growth
- verified algorithms

---

## Deliverables — all mandatory

You must produce **all** of the following.

### 1. Lean development
A Lean 4 file proving at least 3 substantial theorems, with minimal sorry usage, and including at least one novel definition not already in the catalog.

The proofs must genuinely use deep tactics / methods such as:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp`,
- multi-step `calc`,
- structural subgroup arguments,
- invariant-subspace reasoning.

No trivial theorem padding.

### 2. Verified algorithm or computational method
Implement a verified method that:

1. enumerates candidate pairs `(s,t)` in `Sp₄(𝔽₃)` and `SO₃(𝔽₅)`,
2. checks the certificate predicate,
3. constructs the Cayley graph,
4. computes or bounds the spectral gap.

This must be more than a theorem statement; it should be executable mathematics.

### 3. `demo.py`
An interactive demonstration script that:

- constructs the example groups or loads their multiplication tables,
- searches for certified pairs,
- prints certificate diagnostics,
- computes adjacency spectra,
- compares outcomes with a `GL₂` baseline,
- optionally visualizes gap histograms or generator statistics.

### 4. `RESEARCH_PAPER.md`
A standalone scientific paper that someone can read **without any access to code**. It must explain:

- the problem,
- the new certificate concept,
- the main theorems,
- why this is a breakthrough beyond `GL₂`,
- computational evidence,
- limitations,
- what to investigate next.

This paper must read like actual mathematics, not project notes.

### 5. `ARTICLE.md`
Write this in **Scientific American** style for a broad audience. Do **not** talk about formal verification machinery. Talk about the mathematics:

- why symmetry groups can create highly connected sparse networks,
- why classical groups are richer than the linear groups previously studied,
- why certified expanders matter,
- what this could mean for communication, coding, and randomness.

### 6. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact sentences:

- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a genuinely different domain, such as:
- quantum information,
- arithmetic geometry,
- statistical mechanics,
- topological data analysis.

Do not write placeholders; write persuasive mathematical prose.

---

## Standard of ambition

Do **not** frame this as “extend GL₂ to other groups.” That is too small. The real target is:

> a verified theory of **certificate-driven expansion in finite groups of Lie type**, with concrete low-rank theorems and an algorithmic pipeline that makes new expander families discoverable.

If successful, this creates a new methodology:
- identify toral/generic certificates,
- prove they force generation,
- transfer generation to expansion,
- deploy the result in coding and pseudorandomness.

That is a field-opening blueprint.

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
