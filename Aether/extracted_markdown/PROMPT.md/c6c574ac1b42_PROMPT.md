Soli Deo Gloria

## Assignment: Direction 1: Quantum 2-Designs from Certified Unitary Expanders

**Mode:** prove

Aristotle, do not treat this as a modest extension of finite group expansion. The real target is to **turn certified generation and expansion in finite classical groups into deterministic quantum pseudorandomness**. If this works, it opens a new route to explicit approximate unitary designs that does not pass through random circuits or Clifford-specific technology. The breakthrough is the bridge:

\[
\text{certified Cayley expansion in } SU_n(\mathbb F_{q^2})
\quad\Longrightarrow\quad
\text{rapid convergence of the second moment operator}
\quad\Longrightarrow\quad
\text{explicit approximate unitary 2-designs.}
\]

This is not merely “another expander theorem.” It is a deterministic architecture for quantum randomness built from deep finite group theory.

---

## Precise Research Goal

Build on:

- `Catalog/Algebra/ClassicalGroupExpanders.lean`
  - especially `ClassicalGenCertificate`, `HasVertexExpansion`
- `Catalog/Algebra/MatrixGroupGeneration.lean`
  - especially `eq_bot_or_top_of_charpoly_irreducible`

to define and certify a **quantum certificate** for special unitary groups over finite fields, then prove that the associated averaging operator on the tensor-square representation contracts to the Haar projector at an exponential rate.

The conceptual theorem you should aim for is:

> **Main Theorem (informal).**  
> Let \(q\) be a prime power and \(n \ge 2\). Suppose \(s,t \in SU_n(\mathbb F_{q^2})\) satisfy a certified generation hypothesis strong enough to imply:
> 1. \(\langle s,t\rangle = SU_n(\mathbb F_{q^2})\),
> 2. the symmetric generating set \(S=\{s,s^{-1},t,t^{-1}\}\) has a uniform spectral gap on the nontrivial part of the regular representation.
>
> Then the associated moment operator on \(\operatorname{End}(V^{\otimes 2})\), where \(V=(\mathbb F_{q^2})^n\) or its complex lift through a chosen unitary model, satisfies
> \[
> \|M_S^k-\Pi_2\| \le C \lambda^k
> \]
> for some \(0<\lambda<1\), where \(\Pi_2\) is the projector onto the \(SU_n\)-invariant subspace of the second tensor moment. Consequently, the \(k\)-step Cayley walk defines an \(\varepsilon\)-approximate unitary 2-design for
> \[
> k \ge \frac{\log(C/\varepsilon)}{-\log \lambda}.
> \]

The formal Lean version will likely need a finite-group / averaging-operator formulation before the full analytic “unitary 2-design” language is expressed. That is acceptable, but the mathematical content must genuinely target the theorem above.

---

## New Definitions You Must Introduce

You are required to define at least one genuinely new concept. Do not merely rename an existing structure.

### 1. Quantum certificate for unitary generators
Define a structure expressing the extra conditions needed to pass from group-generation to second-moment mixing.

A plausible Lean 4 sketch:

```lean
structure QuantumGenCertificate
    (q : ℕ) [Fact q.PrimePower]
    (n : ℕ)
    (G : Type*) [Group G] where
  s t : G
  symmetric_generators : Finset G
  hs_mem : s ∈ symmetric_generators
  ht_mem : t ∈ symmetric_generators
  inv_closed : ∀ g ∈ symmetric_generators, g⁻¹ ∈ symmetric_generators
  generates_top : Subgroup.closure ({s, t} : Set G) = ⊤
  charpoly_irred_witness : Prop
  hermitian_compatible : Prop
  second_moment_gap : ℝ
  gap_pos : 0 < second_moment_gap
```

This should not remain a dummy container: at least one theorem must use it nontrivially.

### 2. Second-moment averaging operator
Define a finite averaging operator attached to a symmetric generating multiset/finset.

Possible signature:

```lean
def secondMomentOperator
    {G : Type*} [Fintype G] [Group G]
    (S : Finset G) :
    End ℂ (Matrix (Fin n × Fin n) (Fin n × Fin n) ℂ) := ...
```

If full matrix-analytic formalization is too heavy, first define a finite averaging operator on functions:

```lean
def cayleyAverage
    {G : Type*} [Fintype G] [Group G]
    (S : Finset G) (f : G → ℂ) : G → ℂ :=
  fun x => ((S.card : ℂ)⁻¹) * ∑ s in S, f (s * x)
```

and then define a “second-moment class function” or “tensor-square observable” as the domain on which contraction is studied.

### 3. Frame potential surrogate
If the exact quantum-information frame potential is technically expensive in Lean, define a certified surrogate that is mathematically tied to the second moment operator.

Example:

```lean
def framePotential₂Bound
    {G : Type*} [Fintype G] [Group G]
    (μ : G → ℝ) : ℝ := ...
```

Then prove it decays under spectral gap assumptions. This is acceptable if the `RESEARCH_PAPER.md` explains clearly how the surrogate corresponds to the usual 2-design criterion.

---

## Precise Theorem Statements to Target

You need **at least 3 nontrivial theorems**, with real proofs using multi-step reasoning. Here are the right targets.

### Theorem 1: Certified generation for special unitary groups
This is the algebraic backbone.

> **Theorem 1.** Let \(q\) be a prime power, \(n \ge 2\), and let \(s,t \in SU_n(\mathbb F_{q^2})\). Assume:
> - one of \(s,t\) has irreducible characteristic polynomial over \(\mathbb F_{q^2}\),
> - the pair preserves the defining Hermitian form,
> - the subgroup they generate acts absolutely irreducibly,
> - the certificate excludes containment in the standard maximal geometric subgroups.
>
> Then \(\langle s,t\rangle = SU_n(\mathbb F_{q^2})\).

A Lean-style target:

```lean
theorem quantum_certificate_generates_top
    {q n : ℕ} [Fact q.PrimePower]
    (s t : SUGroup q n)
    (hcert : IsQuantumCertifiedPair q n s t) :
    Subgroup.closure ({s, t} : Set (SUGroup q n)) = ⊤
```

You may need to define `SUGroup q n` if the exact object is not already in Mathlib/catalog form. If a full formal `SUGroup` is too heavy, formulate first for a finite subgroup type equipped with hypotheses modeling \(SU_n(\mathbb F_{q^2})\), but the mathematical intent must remain explicit.

**Why this matters:** this is the deterministic algebraic input. Without this, the quantum pseudorandomness statement floats without a structural source.

---

### Theorem 2: Spectral gap transfers to second-moment contraction
This is the central bridge theorem.

> **Theorem 2.** Let \(G\) be a finite group and \(S\subseteq G\) a symmetric generating set. Suppose the averaging operator on every nontrivial irreducible constituent of the tensor-square representation has operator norm at most \(\lambda < 1\). Then the \(k\)-step second-moment operator satisfies
> \[
> \|M_S^k - \Pi_2\| \le \lambda^k.
> \]

Lean-style target:

```lean
theorem second_moment_contraction
    {G : Type*} [Fintype G] [Group G]
    (S : Finset G)
    (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
    (hgap : secondMomentSpectralRadius S < 1)
    (k : ℕ) :
    ‖(secondMomentOperator S)^k - secondMomentProjector G‖ ≤
      (secondMomentSpectralRadius S) ^ k
```

If operator norms are too ambitious in current infrastructure, replace by a finite-dimensional matrix norm or an inequality for a scalar “energy” functional monotone under averaging. But the theorem must still encode **exponential contraction to the invariant projector**.

**Why this matters:** this is the exact place where expander theory becomes quantum design theory.

---

### Theorem 3: Approximate 2-design criterion via frame potential surrogate
This is the quantum-information output.

> **Theorem 3.** Under the hypotheses of Theorem 2, for every \(\varepsilon>0\), if
> \[
> k \ge \left\lceil \frac{\log(C/\varepsilon)}{-\log \lambda} \right\rceil,
> \]
> then the \(k\)-step Cayley distribution has frame-potential error at most \(\varepsilon\), hence is an \(\varepsilon\)-approximate unitary \(2\)-design.

Lean-style target:

```lean
theorem approx_two_design_of_gap
    {G : Type*} [Fintype G] [Group G]
    (S : Finset G)
    (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
    (hgap : secondMomentSpectralRadius S < 1)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ k : ℕ,
      framePotential₂Bound (cayleyDistribution S k) ≤ ε
```

A stronger version with an explicit logarithmic bound on `k` is preferable.

**Why this matters:** this is the theorem that quantum information people will actually care about.

---

### Theorem 4: Cross-domain theorem — quasirandomness forces tomography efficiency
You must include at least one theorem crossing domains. Here is the right one:

> **Theorem 4.** If a finite group action yields an \(\varepsilon\)-approximate unitary 2-design, then the empirical second moments of orbit measurements give a stable estimator for quadratic observables, with error controlled by \(\varepsilon\) and sample size.

This bridges:
- finite group theory,
- representation theory,
- quantum tomography / statistical estimation.

Lean-style target, in a finite surrogate form:

```lean
theorem design_implies_second_moment_estimation
    {G : Type*} [Fintype G] [Group G]
    (μ : G → ℝ)
    (hμ : IsApproxTwoDesign μ ε) :
    ∀ obs ∈ quadraticObservables n,
      estimationErrorBound μ obs ≤ C * ε
```

If the statistics formalization is too much, formulate instead as a deterministic variance bound for averaging quadratic class functions over the Cayley walk. The key is that the theorem must genuinely connect algebraic pseudorandomness to a quantitative statement from another domain.

---

## Proof Strategy Architecture

Do not give one route. Pursue multiple routes and decide which is most promising.

### Strategy A: Algebraic certification → representation decomposition → moment contraction
This is the most promising route.

1. **Certified generation.**  
   Use `ClassicalGenCertificate` and `eq_bot_or_top_of_charpoly_irreducible` to prove that the subgroup generated by the certified pair is all of \(SU_n\) or a modeled special unitary subgroup. The irreducible characteristic polynomial is the mechanism that rules out reducible subgroup actions.

2. **Symmetric averaging operator.**  
   Define the Cayley averaging operator attached to \(S=\{s,s^{-1},t,t^{-1}\}\). Show it preserves invariant subspaces and acts as identity on the trivial constituent.

3. **Nontrivial constituent contraction.**  
   Transfer expansion/quasirandomness to a spectral bound on the orthogonal complement of the invariant second-moment space. Then iterate:
   \[
   M^k - \Pi_2 = (M-\Pi_2)^k
   \]
   on the complement, obtaining exponential decay.

**Why this is best:** it aligns directly with the catalog’s certified-generation infrastructure and only adds one new conceptual layer: the tensor-square/moment operator.

---

### Strategy B: Character-theoretic route via class functions
This may be more formalization-friendly if full operator theory is cumbersome.

1. Replace the full second-moment operator by a finite-dimensional space of class functions encoding second moments.
2. Express convergence in terms of Fourier coefficients on irreducible characters.
3. Use a bound of the form
   \[
   \max_{\rho \ne 1} \left\| \frac{1}{|S|}\sum_{s\in S}\rho(s)\right\| \le \lambda
   \]
   and conclude geometric decay of nontrivial character mass.

**Why useful:** finite character manipulations may be easier in Lean than full complex Hilbert-space operator theory.

---

### Strategy C: Energy dissipation / combinatorial surrogate
This is a fallback, but still scientifically meaningful.

1. Define a “second-moment energy” functional \(E_k\) measuring deviation from uniformity.
2. Prove a one-step contraction
   \[
   E_{k+1} \le \lambda E_k.
   \]
3. Show that small energy implies small frame-potential surrogate error.

**Why useful:** if spectral operator formalism hits infrastructure limits, this still yields a rigorous design-quality theorem.

---

## How to Use the Catalog Precisely

Do not cite the catalog vaguely. Use it structurally.

### From `Catalog/Algebra/MatrixGroupGeneration.lean`
Leverage `eq_bot_or_top_of_charpoly_irreducible` as follows:

- the theorem is a certified dichotomy mechanism;
- once you establish that the subgroup generated by your pair acts irreducibly because one generator has irreducible characteristic polynomial, you can rule out the “bot” case and force top-generation inside the ambient certified group;
- extend this logic to the unitary setting by adding **Hermitian compatibility** and exclusion of improper form-preserving subgroups.

### From `Catalog/Algebra/ClassicalGroupExpanders.lean`
Use `ClassicalGenCertificate` and `HasVertexExpansion` as the combinatorial-expansion backbone:

- `ClassicalGenCertificate` should be adapted or wrapped to a unitary-specific certificate;
- `HasVertexExpansion` supplies the graph-theoretic expansion statement for the Cayley graph;
- then you must prove the nontrivial new theorem that this expansion controls a second-moment averaging process relevant to 2-designs.

The key new science is **not** the expander itself, but the theorem that this expander is already a quantum pseudorandom object.

---

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem must bridge domains, but the paper should develop several bridges.

### 1. Finite group theory ↔ quantum information theory
Certified generators in \(SU_n(\mathbb F_{q^2})\) become deterministic approximate unitary 2-designs. This is the headline bridge.

### 2. Representation theory ↔ randomized numerical linear algebra
Approximate 2-designs derandomize second-moment estimation. This connects to trace estimation, shadow tomography, and pseudorandom measurement ensembles.

### 3. Expander graphs ↔ many-body physics
The second-moment contraction theorem can be interpreted as rapid thermalization in a finite algebraic toy model of local randomization. Even if not fully formalized, this belongs in the paper and future directions.

### 4. Finite geometry ↔ coding theory
Unitary groups over finite fields naturally act on Hermitian polar spaces. If your certified generators produce designs, this may lead to deterministic constructions relevant to quantum error-correcting codes and stabilizer-like measurement schemes.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture and implement a computational test.

### Conjecture: Uniform second-moment gap for certified SU₂ pairs
For \(q\) odd and \(G = SU_2(\mathbb F_{q^2}) \cong SL_2(\mathbb F_q)\), there exists a family of certified symmetric generating pairs \(S_q\) of size 4 such that
\[
\sup_q \operatorname{secondMomentSpectralRadius}(S_q) < 1.
\]
Equivalently, the second-moment mixing time is \(O(\log |G|)\) with constants independent of \(q\).

This is falsifiable: compute the second-moment operator numerically for \(q=3,5,7\), estimate the largest nontrivial eigenvalue, and see whether it drifts toward 1 or remains bounded away from 1.

A Lean-facing declaration sketch:

```lean
conjecture uniform_SU2_second_moment_gap :
  ∃ (C : ℝ), C < 1 ∧
    ∀ q : ℕ, Odd q → IsPrimePower q →
      ∃ S : Finset (SL2 q),
        IsCertifiedSU2Generator q S ∧
        secondMomentSpectralRadius S ≤ C
```

If `SL2 q` is the practical formal target in Lean, state the conjecture there and explain in the paper the \(SU_2(\mathbb F_{q^2}) \cong SL_2(\mathbb F_q)\) identification.

---

## Computational / Algorithmic Deliverable

You must produce a verified algorithm, not just theorems.

### Required algorithm
Implement a certificate-checking and design-quality pipeline for \(SU_2(\mathbb F_{q^2}) \cong SL_2(\mathbb F_q)\), for \(q=3,5,7\):

1. Enumerate candidate pairs \((s,t)\).
2. Check:
   - determinant condition,
   - irreducibility / characteristic polynomial criterion,
   - generation of the full group,
   - symmetry of \(S=\{s,s^{-1},t,t^{-1}\}\).
3. Construct the Cayley walk.
4. Compute the empirical second-moment operator or frame potential surrogate after \(k\) steps.
5. Compare convergence rate against random circuits of matching depth.

This algorithm must be reflected in the theorem statements: prove at least one correctness theorem about the certificate checker or the computed surrogate.

Possible correctness target:

```lean
theorem certificate_checker_sound
    (q : ℕ) [Fact q.PrimePower] :
    ∀ pair,
      certificateCheck q pair = true →
      IsQuantumCertifiedPair q 2 pair.1 pair.2
```

and, if possible,

```lean
theorem design_estimator_sound
    (S : Finset (SL2 q)) :
    estimatorOutput S k ≤ B →
    framePotential₂Bound (cayleyDistribution S k) ≤ B
```

---

## Demo Requirements

Your `demo.py` must be interactive and scientifically meaningful. It should:

- allow the user to choose \(q=3,5,7\),
- display candidate certified pairs,
- show the Cayley graph degree and group size,
- compute and plot:
  - frame potential surrogate vs. walk length,
  - spectral estimate vs. walk length,
  - comparison with random circuits of the same depth,
- print the predicted logarithmic mixing threshold and the observed threshold.

The demo is not decoration. It is part of the conjecture-testing loop.

---

## Application Keywords

Include these explicitly in the paper, article, and code documentation:

- approximate unitary 2-designs
- deterministic quantum pseudorandomness
- finite special unitary groups
- Cayley graph expansion
- spectral gap
- frame potential
- randomized benchmarking
- quantum state tomography
- quantum error correction
- quasirandom groups
- representation-theoretic mixing
- explicit derandomization
- second-moment method
- tensor-square representation

---

## Deliverables You Must Produce

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
- at least one direction must bridge to a different domain, such as coding theory, many-body physics, or randomized numerical linear algebra.

Possible future directions you should consider:
- unitary \(t\)-designs for \(t>2\),
- deterministic shadow tomography ensembles,
- expansion in other finite groups of Lie type,
- design constructions from polar spaces and finite geometries,
- algebraic pseudorandomness for fault-tolerant quantum protocols.

### 2. `RESEARCH_PAPER.md`
This must be a standalone scientific paper. A reader with no access to the code must understand:
- the exact problem,
- the main theorem,
- why certified unitary expanders matter,
- how the proof works at a high level,
- what was computed experimentally,
- what new research avenues this opens.

### 3. `ARTICLE.md`
Write this in **Scientific American** style. It must be engaging and broad.  
**Taboo:** do **not** focus on formal verification, proof assistants, or machine checking. Focus on the mathematics, the quantum-information significance, and why deterministic quantum randomness is surprising.

### 4. Verified algorithm or computational method
As above: certificate checker + second-moment / frame-potential computation, with at least one soundness theorem.

### 5. `demo.py`
Interactive, visual, and directly tied to the conjecture test.

---

## Standards for the Lean File

You are under explicit depth constraints:

- no trivial enumeration-only theorems,
- at least 3 theorems with genuine proof structure,
- use induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc` where appropriate,
- define at least one new structure/concept,
- include at least one cross-domain theorem,
- minimize `sorry`.

A good file would contain:

1. a new definition of `QuantumGenCertificate` or equivalent,
2. a theorem proving generation from the certificate,
3. a theorem proving contraction of a second-moment functional,
4. a theorem connecting contraction to a frame-potential or estimation bound,
5. a soundness theorem for the computational checker.

---

## Final Scientific Vision

If you succeed, the result will say something genuinely new:

**finite simple-group expansion can be converted into deterministic quantum randomness with explicit certification.**

That would open a field:
- deterministic replacements for random circuit designs,
- new tools for tomography and benchmarking,
- algebraic design theory beyond Clifford constructions,
- a representation-theoretic bridge between finite groups of Lie type and quantum information.

Do not aim for a toy theorem. Aim for the first rigorous blueprint for **certified algebraic quantum designs**.

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
