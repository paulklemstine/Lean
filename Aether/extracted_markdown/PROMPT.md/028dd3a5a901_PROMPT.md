Soli Deo Gloria

## Assignment: Direction 3 — Arithmetic Statistics of Graph Jacobians

**Mode:** `prove` + `discover`

You are to turn a bold probabilistic conjecture into a formal arithmetic-statistical theory of graph Jacobians, with the Smith normal form bridge as the central mechanism. This is not a request for a routine asymptotic or a finite-case computation. The objective is to create the first formal bridge between **random graph Laplacians**, **finite abelian group statistics**, and **Cohen–Lenstra heuristics**, and to do so in a way that yields both rigorous theorems and a verified computational pipeline.

The conjectural horizon is this:

> For Erdős–Rényi graphs \(G(n,p)\) in a suitable regime, the \(p\)-primary invariant-factor statistics of the graph Jacobian \(\mathrm{Jac}(G)\) asymptotically match the Cohen–Lenstra distribution for random finite abelian \(p\)-groups.

The breakthrough is not merely to restate this philosophy. The breakthrough is to identify **provable finite-\(n\) structural theorems** in Lean that make the conjecture mathematically inevitable: exact divisor criteria, monotonicity laws, moment identities, and a random-matrix transfer principle from reduced Laplacians to cokernels of integer matrices.

This would open a new field of **formal arithmetic combinatorics of random discrete geometries**.

---

## Core Mathematical Objects

Build explicitly on:

- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean`
  - especially `SmithNFData.invariantFactors`
- `Catalog/Pythagorean/CohenLenstra/Defs.lean`
  - the existing formalization of Cohen–Lenstra distributions / finite abelian group data

You should introduce at least one genuinely new concept, for example:

- `GraphJacobianStats`
- `ReducedLaplacianModel`
- `PrimePowerMoment`
- `InvariantFactorProfile`
- `JacobianPPart`

These must not be cosmetic wrappers; they should organize theorems and computations in a way the catalog currently does not.

---

## Precise Theorem Targets

You must prove **at least 3 substantial theorems**. At least one should connect graph theory to number theory or random matrix theory in a nontrivial way.

Below are the primary targets. If one asymptotic statement is too ambitious in full generality, prove a finite exact version and then a derived corollary with explicit bounds.

### Theorem A — Divisibility criterion via invariant factors
For a finite connected graph \(G\), let \(L_G^\ast\) be a reduced Laplacian, and let
\[
(d_1,\dots,d_r) = \text{Smith invariant factors of } L_G^\ast,
\]
so that
\[
\mathrm{Jac}(G) \cong \bigoplus_i \mathbb{Z}/d_i\mathbb{Z}.
\]
Then for every prime \(q\) and integer \(k \ge 1\),
\[
q^k \mid \exp(\mathrm{Jac}(G))
\quad\Longleftrightarrow\quad
\exists i,\; q^k \mid d_i.
\]
Moreover, if the invariant factors are in divisibility order, this is equivalent to
\[
q^k \mid d_r.
\]

**Lean 4 target signature sketch:**
```lean
theorem primePow_dvd_exponent_iff_exists_invariantFactor
  {n : ℕ} (S : SmithNFData (Fin n)) (q k : ℕ)
  [Fact q.Prime] :
  q^k ∣ S.exponent ↔ ∃ i, q^k ∣ S.invariantFactors i
```

A graph-specialized version should follow from the SNF correspondence:
```lean
theorem primePow_dvd_graphJacobianExponent_iff
  (G : SimpleGraph (Fin n)) [Fintype (Fin n)]
  (hconn : G.Connected) (q k : ℕ) [Fact q.Prime] :
  q^k ∣ graphJacobianExponent G ↔
    ∃ i, q^k ∣ (graphJacobianSmithData G hconn).invariantFactors i
```

**Why this matters:** This gives the exact arithmetic observable needed for comparing random graphs to Cohen–Lenstra predictions: the exponent and largest invariant factor become computable through SNF data.

---

### Theorem B — Prime-power moment identity for Jacobians
Define the \(q^k\)-torsion count of a finite abelian group \(A\) by
\[
M_{q,k}(A) := \#\{x \in A : q^k x = 0\}.
\]
For a graph Jacobian presented through Smith factors \(d_i\), prove the exact identity
\[
M_{q,k}(\mathrm{Jac}(G))
=
\prod_i \gcd(d_i, q^k).
\]
Equivalently, in valuation form,
\[
M_{q,k}(\mathrm{Jac}(G))
=
q^{\sum_i \min(v_q(d_i),k)}.
\]

**Lean 4 target signature sketch:**
```lean
def primePowerMoment (q k : ℕ) (S : SmithNFData α) : ℕ := ...

theorem primePowerMoment_eq_prod_gcd_invariantFactors
  (S : SmithNFData α) (q k : ℕ) [Fact q.Prime] :
  primePowerMoment q k S =
    ∏ i, Nat.gcd (S.invariantFactors i) (q^k)
```

Graph specialization:
```lean
theorem graphJacobian_primePowerMoment_eq_prod_gcd
  (G : SimpleGraph (Fin n)) (hconn : G.Connected)
  (q k : ℕ) [Fact q.Prime] :
  graphPrimePowerMoment G hconn q k =
    ∏ i, Nat.gcd ((graphJacobianSmithData G hconn).invariantFactors i) (q^k)
```

**Why this matters:** This is the exact finite-\(n\) analog of the moment method behind Cohen–Lenstra. It converts a random graph problem into an expectation over arithmetic functions of SNF data.

---

### Theorem C — Monotonicity / transfer theorem for \(p\)-primary statistics
Define the \(q\)-primary profile of SNF data by the sequence
\[
\lambda_{q,j}(S) := \#\{i : q^j \mid d_i\}.
\]
Prove that the prime-power moments determine this profile, and conversely that the profile determines all moments \(M_{q,k}\).

A precise finite theorem:
\[
M_{q,k}(S) = q^{\sum_{j \ge 1} \min(j,k)\, m_j}
\]
for suitable multiplicities \(m_j\), and from the sequence \(k \mapsto v_q(M_{q,k})\) one can recover the counts \(\lambda_{q,j}\) by discrete differences.

**Lean 4 target signature sketch:**
```lean
def qProfile (q : ℕ) (S : SmithNFData α) (j : ℕ) : ℕ := ...

theorem qProfile_recoverable_from_momentValuations
  (S : SmithNFData α) (q : ℕ) [Fact q.Prime] :
  ∀ j ≥ 1, qProfile q S j =
    momentValuation q S j - momentValuation q S (j - 1)
```

Or an equivalent discrete second-difference statement if that is the correct combinatorial inversion.

**Why this matters:** Cohen–Lenstra predictions are about the entire \(q\)-primary partition type, not just the exponent. This theorem is the finite deterministic skeleton of the asymptotic conjecture.

---

## Ambitious Cross-Domain Theorem

You must include at least one theorem explicitly bridging two domains.

### Theorem D — Random matrix transfer principle
Formulate and prove a theorem of the following type:

> Any statistic of a graph Jacobian that depends only on the Smith invariant factors of the reduced Laplacian factors through the cokernel of the reduced Laplacian as an integer matrix.

This sounds tautological, but formalized correctly it becomes the universal reduction principle needed to import random matrix heuristics.

**Lean 4 target signature sketch:**
```lean
theorem graphJacobian_statistic_factors_through_smithNormalForm
  (Φ : SmithNFData α → β)
  (hΦ : ∀ M N, smithEquivalent M N → Φ (smithData M) = Φ (smithData N))
  (G : SimpleGraph (Fin n)) (hconn : G.Connected) :
  graphJacobianStatistic G hconn = Φ (graphJacobianSmithData G hconn)
```

A more concrete and more useful version is preferable:
```lean
theorem graphJacobian_isomorphic_to_cokernel_reducedLaplacian
  (G : SimpleGraph (Fin n)) (hconn : G.Connected) :
  graphJacobian G ≃+ reducedLaplacianCokernel G hconn
```

**Why this matters:** This is the exact bridge from combinatorial probability to arithmetic statistics. Once formalized, every theorem about cokernels of random integer matrices becomes a candidate theorem about random graph Jacobians.

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture in Lean-adjacent mathematical prose and support it with a computational test.

### Conjecture CL-ER
Fix a prime \(q\) and \(p \in (0,1)\). Let \(G_n \sim G(n,p)\). Then for every finite abelian \(q\)-group \(A\),
\[
\lim_{n\to\infty}
\Pr\big((\mathrm{Jac}(G_n))_{(q)} \cong A\big)
=
\mu_{CL,q}(A),
\]
the Cohen–Lenstra \(q\)-measure.

A weaker but testable prediction:
\[
\lim_{n\to\infty}\mathbb{E}\, M_{q,k}(\mathrm{Jac}(G_n))
=
\mathbb{E}_{CL}[M_{q,k}]
\]
for each fixed \(q,k\).

### Computational falsification test
Generate random graphs \(G(n,1/2)\) for \(n \in \{10,20,50,100\}\), compute reduced Laplacians, their Smith normal forms, and compare:

1. empirical distribution of the largest invariant factor,
2. empirical distribution of the \(q\)-rank,
3. empirical moments \( \mathbb{E}[M_{q,k}] \),

against Cohen–Lenstra predictions for \(q=2,3,5\).

A genuine disproof would be a statistically persistent deviation beyond confidence intervals as \(n\) increases.

---

## Proof Architecture: 3 Strategy Paths

You must discuss and try multiple proof routes. Do not lock into a single path prematurely.

### Strategy A — Exact finite algebra through SNF and finite abelian groups
1. Use `SmithNFData.invariantFactors` to identify the Jacobian as a direct sum of cyclic groups.
2. Prove exact formulas for exponent, torsion counts, and \(q\)-primary profiles by reducing to \(\mathbb{Z}/d\mathbb{Z}\).
3. Assemble product formulas using multi-step `calc`, induction on the number of invariant factors, and divisibility lemmas.

**Why promising:** This is the most certifiable route in Lean. It yields strong deterministic theorems immediately and sets up the statistical layer cleanly.

### Strategy B — Reduced Laplacian cokernel and matrix arithmetic
1. Define the reduced Laplacian cokernel as an explicit quotient of \(\mathbb{Z}^{n-1}\).
2. Prove its equivalence with the graph Jacobian / critical group.
3. Transport arithmetic statistics from matrices to graph invariants and formulate random-matrix analogies.

**Why promising:** This is the conceptual bridge theorem. It is the right route for cross-domain significance and for future import of asymptotic random matrix results.

### Strategy C — Moment inversion and arithmetic statistics
1. Define prime-power moments \(M_{q,k}\) as counting homomorphisms or torsion elements.
2. Express these moments in terms of invariant factors.
3. Prove inversion formulas recovering partition data from moments.

**Why promising:** This mirrors the actual logic of Cohen–Lenstra heuristics. It upgrades “one observable” into a full statistical fingerprint.

**Recommended priority:** A → C → B.  
A establishes exact arithmetic formulas. C turns them into statistics-ready observables. B then universalizes the framework and makes the research program field-opening.

---

## Required New Definitions

You must define at least one novel structure. Strong candidates:

```lean
structure InvariantFactorProfile where
  q : ℕ
  levels : ℕ → ℕ
  monotone : ∀ j, levels (j+1) ≤ levels j
```

```lean
structure GraphJacobianStats (V : Type) [Fintype V] where
  invariantFactors : List ℕ
  exponent : ℕ
  primePowerMoment : ℕ → ℕ → ℕ
```

```lean
def JacobianPPart (q : ℕ) (S : SmithNFData α) : List ℕ := ...
```

These should support theorems, not merely package data.

---

## Expected Deep Proof Techniques

Your file must contain at least 3 theorems whose proofs substantially use:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp` where relevant for rational identities or normalized averages,
- multi-step `calc`,
- careful divisibility reasoning,
- decomposition of finite abelian groups into cyclic summands.

Avoid trivial closure by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is mathematically significant.

---

## Cross-Domain Connections You Must Explicitly Highlight

1. **Combinatorial probability ↔ arithmetic statistics**  
   Random graph Laplacians produce finite abelian groups whose laws resemble class groups.

2. **Graph theory ↔ random matrix theory**  
   Reduced Laplacians are constrained random integer matrices; SNF turns them into cokernel distributions.

3. **Tropical geometry ↔ arithmetic invariants**  
   The Jacobian / critical group is a tropical-harmonic object, yet its invariant factors obey number-theoretic statistics.

4. **Potential physics bridge**  
   The sandpile model and chip-firing dynamics encode the same Jacobian; arithmetic observables may become order parameters in self-organized criticality.

---

## Application Keywords

Include these in the prose, theorem comments, and paper:
- graph Jacobian
- critical group
- Smith normal form
- invariant factors
- Cohen–Lenstra heuristics
- arithmetic statistics
- random graphs
- Erdős–Rényi
- reduced Laplacian
- cokernel distribution
- prime-power moments
- finite abelian groups
- chip-firing
- sandpile dynamics
- random matrix theory
- tropical geometry

---

## Deliverables (ALL mandatory)

1. **Lean file(s)** with at least 3 substantial theorems and at least one new definition.
2. **A verified algorithm / computational method** for:
   - computing reduced Laplacians,
   - extracting Smith invariant factors,
   - computing exponent and prime-power moments,
   - sampling empirical distributions from random graphs.
3. **`demo.py`** demonstrating the result interactively:
   - generate random \(G(n,p)\),
   - compute Jacobian invariant factors,
   - plot empirical histograms,
   - compare to Cohen–Lenstra-inspired reference curves.
4. **`RESEARCH_PAPER.md`** — standalone scientific document explaining:
   - the exact theorems proved,
   - why they matter,
   - how they connect random graphs and arithmetic statistics,
   - what asymptotic conjectures now become plausible.
5. **`ARTICLE.md`** — Scientific American style:
   - vivid explanation of why a random graph secretly carries number-theoretic DNA,
   - no focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.  
   Each direction must include:
   - “The key insight is...”
   - “Why now?”
   At least one direction must bridge to a different domain, such as statistical physics, coding theory, or tropical Hodge theory.

---

## Concrete Suggested File Focus

A strong target would be a new file such as:

`Catalog/Pythagorean/GraphJacobians/ArithmeticStatistics.lean`

with supporting computational infrastructure nearby.

Possible theorem names:
- `primePow_dvd_exponent_iff_exists_invariantFactor`
- `graphJacobian_primePowerMoment_eq_prod_gcd`
- `qProfile_recoverable_from_momentValuations`
- `graphJacobian_isomorphic_to_cokernel_reducedLaplacian`
- `largestInvariantFactor_controls_exponent`
- `primePowerMoment_mul_on_directSum`

---

## Final Objective

Do not merely formalize a known identity. Build the deterministic algebraic backbone of a future theorem stating that **random graph Jacobians obey class-group statistics**. The field-opening move is to show that graph-theoretic randomness flows through Smith normal form into arithmetic laws. If successful, this becomes a new research corridor between **random discrete geometry** and **arithmetic statistics**, with immediate computational experiments and a precise conjectural roadmap.

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
