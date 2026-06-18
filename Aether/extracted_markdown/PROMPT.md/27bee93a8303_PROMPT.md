Soli Deo Gloria

## Assignment: Direction 2 — Exceptional Groups and Character-Sheaf Certificates

**Mode:** `prove`

Aristotle, do not treat this as a finite-group exercise. Treat it as the first rigorous bridge from exceptional Lie theory to certified expansion. The decisive move is to isolate a **character-sheaf certificate**: a formal object encoding the data needed to turn explicit character bounds on regular toral elements into uniform spectral gaps. If this succeeds for \(G_2(\mathbb F_q)\), it creates a blueprint for \(F_4,E_6,E_7,E_8\), where explicit but underused character-theoretic data has been waiting for a theorem that can consume it.

The breakthrough is not “another spectral gap.” The breakthrough is:

> **exceptional groups admit low-complexity representation-theoretic certificates for expansion**, and these certificates are stable enough to be formalized, computed, and transferred.

This would open a new field of **exceptional expander engineering**.

---

## Core Theorem Target

Let \(G = G_2(\mathbb F_q)\), let \(S \subset G\) be a symmetric union of conjugacy classes of regular semisimple toral elements, and let
\[
\mu_S = \frac{1}{|S|}\sum_{s\in S}\delta_s
\]
be the corresponding random-walk measure. Suppose every nontrivial irreducible character \(\chi\) of \(G\) satisfies
\[
\left|\frac{\chi(s)}{\chi(1)}\right| \le \frac{C}{q}
\quad\text{for every } s \in S
\]
for some constant \(C\) depending only on the \(G_2\) root datum and not on \(q\). Then the second eigenvalue of the averaging operator \(T_{\mu_S}\) is \(O(1/q)\), hence for \(q\) sufficiently large the Cayley graphs \(\mathrm{Cay}(G,S)\) form a uniform expander family.

This is the mathematical heart. But you must go further: formalize the certificate that packages this hypothesis.

---

## Precise Formalization Targets

You should introduce a new structure capturing “exceptional character-ratio certificates.”

### New definition (mandatory novelty)
Define a structure along the following lines:

```lean
structure CharacterRatioCertificate (G : Type*) [Finite G] where
  support : Finset G
  symmetric : ∀ g ∈ support, g⁻¹ ∈ support
  nonempty : support.Nonempty
  regular_toral : G → Prop
  support_regular : ∀ g ∈ support, regular_toral g
  C : ℝ
  q : ℕ
  q_pos : 0 < q
  ratio_bound :
    ∀ χ : Irr G, χ ≠ 1 →
      ∀ g ∈ support, ‖χ g‖ / (χ.degree : ℝ) ≤ C / q
```

You may need to adapt this to actual Mathlib APIs for finite groups, class functions, operator norms, and irreducible characters. The point is conceptual: a **certificate** is finite, checkable, and sufficient to imply expansion.

Also define a derived spectral object:

```lean
def certifiedSpectralRadius
    (G : Type*) [Finite G] [Fintype G] [Group G]
    (cert : CharacterRatioCertificate G) : ℝ := ...
```

The theorem should show this radius is bounded by `cert.C / cert.q`.

---

## Theorems to Prove

You must prove at least 3 substantial theorems, with real proof architecture. The following are the minimum targets.

### Theorem 1: Character-ratio certificate implies spectral gap
This should build directly on the catalog transference theorems in
`Pythagorean/Sp4SpectralGap.lean`, especially the analogue of
`character_ratio_to_spectral_gap` and then `cheeger_from_spectral_gap`.

**Mathematical statement**
For any finite group \(G\), if \(S\) is symmetric and all nontrivial irreducible characters satisfy the uniform ratio bound on \(S\), then the normalized averaging operator on mean-zero functions has operator norm at most the same bound.

**Lean-style target**
```lean
theorem certificate_spectral_radius_le
    (G : Type*) [Fintype G] [Group G]
    (cert : CharacterRatioCertificate G) :
    certifiedSpectralRadius G cert ≤ cert.C / cert.q := by
  ...
```

A strengthened version should then derive a positive spectral gap:

```lean
theorem certificate_spectral_gap_pos
    (G : Type*) [Fintype G] [Group G]
    (cert : CharacterRatioCertificate G)
    (hsmall : cert.C / cert.q < 1) :
    0 < 1 - certifiedSpectralRadius G cert := by
  ...
```

**Why this matters**
This theorem turns exceptional character theory into a reusable computational interface. Once the certificate exists, expansion follows automatically. That is the consumption mechanism the field lacks.

---

### Theorem 2: Averaging over conjugacy-stable toral support collapses to class-function control
Exploit the fact that if \(S\) is a union of conjugacy classes, the averaging operator is central and therefore diagonalized by irreducible characters.

**Mathematical statement**
Let \(S\) be a symmetric conjugacy-stable subset of a finite group. Then the convolution operator by the uniform measure on \(S\) acts on each irreducible representation \(\pi\) by a scalar
\[
\lambda_\pi = \frac{1}{|S|}\sum_{s\in S}\frac{\chi_\pi(s)}{\chi_\pi(1)}.
\]
Hence
\[
|\lambda_\pi| \le \sup_{s\in S}\left|\frac{\chi_\pi(s)}{\chi_\pi(1)}\right|.
\]

**Lean-style target**
```lean
theorem central_average_eigenvalue_eq_charRatioAvg
    (G : Type*) [Fintype G] [Group G]
    (S : Finset G)
    (hconj : IsConjStable (↑S : Set G))
    (hsymm : ∀ g ∈ S, g⁻¹ ∈ S)
    (π : IrrRep ℂ G) :
    ∃ λ : ℂ,
      centralAverageOperator G S π = λ • LinearMap.id := by
  ...
```

and the scalar estimate:

```lean
theorem central_average_eigenvalue_bound
    (G : Type*) [Fintype G] [Group G]
    (S : Finset G)
    (hconj : IsConjStable (↑S : Set G))
    (π : IrrRep ℂ G) :
    ‖eigenvalueOfCentralAverage G S π‖
      ≤ supCharRatioOn G S π := by
  ...
```

**Why this matters**
This theorem is the representation-theoretic hinge. It isolates the exact point where Deligne–Lusztig / Green-function input enters. Everything else is abstract harmonic analysis.

---

### Theorem 3: Certified expansion from \(G_2\)-type toral data
You may not be able to formalize all of Deligne–Lusztig theory in one cycle. That is fine. Instead, formalize a theorem that says: **if** a finite group carries a \(G_2\)-style toral certificate with bounded torus-type complexity, then one gets a uniform expander family.

Abstract the key combinatorics of \(G_2\): there are finitely many torus types, independent of \(q\), and regular semisimple support can be chosen from them.

**Mathematical statement**
Suppose \(G_q\) is a family of finite groups indexed by \(q\), and for each \(q\) there is a certificate with constant \(C\) independent of \(q\). Then for all sufficiently large \(q\), the corresponding Cayley graphs have Cheeger constant bounded below by a positive constant depending only on \(C\) and the transference theorem.

**Lean-style target**
```lean
theorem uniform_expansion_of_certified_family
    (G : ℕ → Type*)
    [∀ q, Fintype (G q)] [∀ q, Group (G q)]
    (cert : ∀ q, CharacterRatioCertificate (G q))
    (hC : ∃ C0 : ℝ, ∀ q, (cert q).C ≤ C0)
    (hq : ∀ q, 0 < (cert q).q)
    (hlarge : ∀ᶠ q in Filter.atTop, ((cert q).C / (cert q).q : ℝ) < 1/2) :
    ∀ᶠ q in Filter.atTop,
      cheegerConstant (G q) (cert q).support ≥ 1/4 := by
  ...
```

You should adapt the conclusion to the exact catalog theorem available; the point is eventual uniform positivity.

**Why this matters**
This is the theorem that converts one-off exceptional calculations into a family theorem. It is the first step from isolated estimates to a genuine expansion theory for exceptional groups.

---

## G₂-Specific Mathematical Ambition

You should explicitly formulate, even if only partially formalized, the central conjectural theorem:

### Conjectural theorem
There exists a constant \(C_{G_2} > 0\) such that for every finite field \(\mathbb F_q\) of good characteristic and every regular semisimple element \(s \in G_2(\mathbb F_q)\) contained in a maximal torus,
\[
\max_{\chi \in \mathrm{Irr}(G_2(\mathbb F_q)),\ \chi \neq 1}
\left|\frac{\chi(s)}{\chi(1)}\right|
\le \frac{C_{G_2}}{q}.
\]

Formalize a testable placeholder interface:

```lean
def G2_character_ratio_conjecture (q : ℕ) : Prop :=
  ∃ C : ℝ, 0 < C ∧
    ∀ s : G2q q, RegularToral s →
      ∀ χ : Irr (G2q q), χ ≠ 1 →
        ‖χ s‖ / (χ.degree : ℝ) ≤ C / q
```

Then prove that this conjecture implies expansion via your certificate theorems.

---

## Proof Strategy Architecture

You asked for 2–3 proof strategy steps. Here are three routes; pursue at least two in the file comments or paper, and implement the most promising one formally.

### Strategy A: Central-convolution to spectral-gap transference
1. **Centralize the walk**: choose \(S\) as a union of regular semisimple conjugacy classes from toral elements. Show convolution by \(\mu_S\) lies in the center of the group algebra.
2. **Diagonalize via irreducibles**: use Schur’s lemma to identify the scalar on each irreducible with the average character ratio.
3. **Transfer to expansion**: apply the catalog theorem analogous to `character_ratio_to_spectral_gap`, then `cheeger_from_spectral_gap`.

**Why promising:** This is the cleanest path and leverages the existing catalog. It minimizes dependence on the full structure theory of \(G_2\).

---

### Strategy B: Torus-type decomposition and finite complexity
1. Define a finite index type of torus types for \(G_2\) (split, anisotropic, mixed forms as available in your abstraction).
2. Express the support \(S\) as a disjoint union over torus types and regular loci.
3. Bound the global average by the maximum over torus types; because the number of types is uniformly bounded, all constants remain \(q\)-independent.

**Why promising:** This isolates the exceptional phenomenon: unlike growing-rank classical groups, \(G_2\) has bounded toral complexity. This is the conceptual novelty and should appear explicitly in your paper.

---

### Strategy C: Character-sheaf certificate abstraction
1. Package the ratio bounds, symmetry, and regularity into a finite certificate.
2. Prove certificate stability under support unions, inverse-closure, and conjugacy closure.
3. Derive a compositional theorem: if each torus type yields a certificate with the same \(C\), their union does too.

**Why promising:** This creates reusable infrastructure for \(F_4\), \(E_6\), and beyond. It is the right long-term architecture even if Strategy A gives the first theorem fastest.

**Most promising overall:** combine **A + C**. A gives the shortest path to a theorem; C makes the result scalable and field-opening.

---

## Cross-Domain Connections

You are required to include at least one theorem connecting this domain to another. Do not make it ornamental. Make it structural.

### Bridge 1: Exceptional groups ↔ spectral graph theory
This is the primary bridge:
- irreducible character bounds become eigenvalue bounds,
- eigenvalue bounds become Cheeger inequalities,
- Cheeger inequalities become explicit expanders.

This is already deep, but go further.

### Bridge 2: Exceptional groups ↔ mathematical physics
The Weyl group of \(G_2\) governs hexagonal symmetry and appears in scattering / symmetry models. A theorem showing that bounded toral complexity implies controlled mixing can be framed as a finite analogue of **symmetry-driven equilibration**.

Possible formal theorem:
```lean
theorem entropy_decay_from_spectral_gap
    ...
```
showing that your spectral gap implies \(L^2\)-mixing or entropy contraction for the random walk. This connects representation theory to statistical mechanics / Markov semigroups.

### Bridge 3: Exceptional groups ↔ Langlands-style harmonic analysis
Character-sheaf data is a finite-group shadow of geometric representation theory. Your certificate formalism can be presented as a finite, computable analogue of extracting spectral data from sheaf-theoretic packets.

Include this in the paper even if not fully formalized:
- Deligne–Lusztig characters as geometric input,
- spectral certification as combinatorial output.

---

## Suggested Additional Theorem for Cross-Domain Requirement

Prove one theorem of the following flavor.

```lean
theorem l2_mixing_time_bound_of_certificate
    (G : Type*) [Fintype G] [Group G]
    (cert : CharacterRatioCertificate G)
    (hsmall : certifiedSpectralRadius G cert < 1) :
    ∃ K : ℝ, ∀ n : ℕ,
      l2DistanceAfterNSteps G cert.support n ≤
        K * (certifiedSpectralRadius G cert) ^ n := by
  ...
```

This connects finite Lie theory to Markov-chain mixing, statistical mechanics, and theoretical computer science.

---

## Computational / Experimental Program

You must not stop at theorem statements. Produce a verified computational method.

### Verified algorithm
Implement an algorithm that, given:
- a finite group \(G\),
- a symmetric conjugacy-stable support \(S\),
- a table of irreducible character values on \(S\),

computes the certified upper bound
\[
\max_{\chi\neq 1}\sup_{s\in S}\left|\frac{\chi(s)}{\chi(1)}\right|
\]
and returns the induced spectral-gap / Cheeger certificate.

This can be abstract if full \(G_2(\mathbb F_q)\) group objects are unavailable in Lean, but it must be formally verified as a correct consumer of tabulated character data.

Possible target:
```lean
def computeCertificateBound ... : ℝ := ...

theorem computeCertificateBound_correct ... :
  certifiedSpectralRadius G cert ≤ computeCertificateBound ... := by
  ...
```

### demo.py
Your Python demo must:
1. encode sample character tables for \(G_2(\mathbb F_q)\) at \(q=3,5,7\) from literature or mock structured input if full tables are not yet embedded;
2. compute maximal character ratios on regular toral classes;
3. plot \(q \cdot \max |\chi(s)/\chi(1)|\) versus \(q\);
4. report whether the data is consistent with a uniform constant \(C\).

The demo should make falsification possible, not merely illustration.

---

## Conjecture with Testable Prediction

State this explicitly in the code and paper:

### Conjecture: Uniform toral character-ratio bound for \(G_2\)
There exists \(C_{G_2}\) independent of \(q\) such that for every good prime power \(q\),
\[
\max_{\substack{s \in G_2(\mathbb F_q)\\ s\ \mathrm{regular\ toral}}}
\max_{\substack{\chi\in \mathrm{Irr}(G_2(\mathbb F_q))\\ \chi\neq 1}}
\left|\frac{\chi(s)}{\chi(1)}\right|
\le \frac{C_{G_2}}{q}.
\]

### Testable prediction
The quantity
\[
M(q) := q \cdot \max_{s,\chi\neq 1}\left|\frac{\chi(s)}{\chi(1)}\right|
\]
remains bounded for \(q=3,5,7,\dots\), and clusters by torus type rather than drifting upward.

### Falsification criterion
If \(M(q)\) grows systematically with \(q\), or if some torus type exhibits recurrent spikes incompatible with a common constant \(C_{G_2}\), the conjecture fails.

Formal placeholder:
```lean
def maxCharacterRatio (q : ℕ) : ℝ := ...
def scaledMaxCharacterRatio (q : ℕ) : ℝ := q * maxCharacterRatio q

conjecture uniform_bounded_scaledMaxCharacterRatio :
  ∃ C : ℝ, ∀ q, GoodPrimePower q → scaledMaxCharacterRatio q ≤ C
```

---

## Catalog Integration

You must explicitly build on:
- `Pythagorean/Sp4SpectralGap.lean`
  - especially theorems analogous to `character_ratio_to_spectral_gap`
  - and `cheeger_from_spectral_gap`.

Do not merely cite them. Refactor your certificate theorem so that these results are used as the final transfer step. The ideal architecture is:

1. prove abstract central-average / character-ratio lemmas in your new file;
2. instantiate the catalog spectral-gap theorem;
3. derive a Cheeger lower bound.

If useful, create an intermediate theorem translating your `CharacterRatioCertificate` into the hypotheses expected by the catalog theorem.

---

## Lean 4 File Design

Suggested file:
`Exceptional/G2CharacterSheafCertificate.lean`

Suggested theorem names:
- `certificate_spectral_radius_le`
- `certificate_spectral_gap_pos`
- `central_average_eigenvalue_eq_charRatioAvg`
- `central_average_eigenvalue_bound`
- `uniform_expansion_of_certified_family`
- `l2_mixing_time_bound_of_certificate`

Use substantial proofs. At least 3 theorems must genuinely require induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`.

---

## Revolutionary Significance

If you succeed, the result says something larger than “\(G_2\) expands.”

It says:

- **exceptional groups are computationally accessible through bounded toral complexity;**
- **character-theoretic data can be turned into certified combinatorial expansion by a formal transference interface;**
- **geometric representation theory can produce explicit finite algorithms for expansion certificates.**

That is a new paradigm. It suggests:
- exceptional-family expanders for computer science,
- new mixing constructions in finite symmetric systems,
- a finite-group shadow of geometric Langlands data becoming algorithmically consumable.

Application keywords:
**exceptional Lie groups, \(G_2(\mathbb F_q)\), Deligne–Lusztig characters, Green functions, character sheaves, spectral gap, Cheeger inequality, expander graphs, random walks, mixing time, harmonic analysis on finite groups, geometric representation theory, Langlands shadows, mathematical physics, symmetry-driven equilibration, certified computation**

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as mathematical physics, coding theory, or geometric Langlands.

2. **`RESEARCH_PAPER.md`** as a standalone scientific paper.
   - A reader with no code access must understand:
     - the certificate formalism,
     - why \(G_2\) is the first exceptional test case,
     - how character-ratio bounds imply expansion,
     - what the conjecture predicts,
     - and what comes next for \(F_4,E_6,E_7,E_8\).

3. **`ARTICLE.md`** in Scientific American style.
   - Make it vivid and idea-driven.
   - **Do not focus on formal verification machinery.**
   - Focus on exceptional symmetry, hidden randomness, and why rare algebraic objects can generate robust networks.

4. **A verified algorithm or computational method**
   - not just theorem statements,
   - but a certified consumer of character-table data producing spectral / Cheeger bounds.

5. **`demo.py`**
   - interactive or script-based,
   - demonstrating the computation of maximal character ratios and the resulting certified expansion indicators for \(q=3,5,7\).

Minimize sorry. If a deep external theorem is needed, isolate it as a clearly named axiom/interface and prove everything downstream from it with full rigor. The ideal outcome is not complete Deligne–Lusztig formalization; it is a new architecture that makes exceptional expansion inevitable once the character data is supplied.

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
