## Assignment: Shadow Profile Convolution and Circuit Complexity Bounds

Soli Deo Gloria

### The Vision

Algebraic circuit lower bounds are the deepest open problem in complexity theory. The permanent versus determinant question has stood for over 50 years. This project opens a new front: **shadow complexity** — a combinatorial invariant of polynomial supports that constrains what small circuits can compute. The key discovery is that the shadow profile satisfies a *convolution inequality* under Minkowski sum, which means multiplication gates in circuits impose multiplicative constraints on shadow growth. This transforms circuit analysis from algebraic combinatorics into a quantitative shadow geometry problem.

### Precise Theorem Targets

**Definition (Shadow Profile).** For $S \subseteq \mathbb{N}^n$ finite, define the *lower shadow* $\partial(S) = \{v' \in \mathbb{N}^n : \exists v \in S,\; v' \leq v \text{ coord-wise},\; |v'| = |v| - 1\}$ where $|v| = \sum_i v_i$. The *shadow profile* is $a_k^S = |\partial^k(S)|$. The *shadow complexity* is $\Sigma(S) = \sum_{k \geq 0} a_k^S$.

**Theorem 1 (Shadow Convolution — Minkowski Sub-multiplicativity).** For finite sets $A, B \subseteq \mathbb{N}^n$:
$$\partial^k(A + B) \subseteq \bigcup_{i=0}^{k}\left(\partial^i(A) + \partial^{k-i}(B)\right)$$
Consequently: $a_k^{A+B} \leq \sum_{i=0}^{k} a_i^A \cdot a_{k-i}^B$ (convolution bound) and $\Sigma(A+B) \leq \Sigma(A) \cdot \Sigma(B)$ (sub-multiplicativity of shadow complexity).

```lean
theorem shadow_minkowski_convolution {n : ℕ} (A B : Finset (Fin n → ℕ))
    (hA : A.Nonempty) (hB : B.Nonempty) (k : ℕ) :
    shadow_iter (minkowskiSum A B) k ⊆
      (Finset.biUnion (Finset.range (k+1)) fun i =>
        minkowskiSum (shadow_iter A i) (shadow_iter B (k - i))) := by
  sorry -- Prove by induction on k using the gate-by-gate shadow inclusion

theorem shadow_complexity_submultiplicative {n : ℕ} (A B : Finset (Fin n → ℕ))
    (hA : A.Nonempty) (hB : B.Nonempty) :
    shadowComplexity (minkowskiSum A B) ≤
    shadowComplexity A * shadowComplexity B := by
  sorry -- Follows from convolution bound by summing over k
```

**Theorem 2 (Shadow Complexity Circuit Upper Bound).** If polynomial $f \in K[x_1, \ldots, x_n]$ is computed by an algebraic formula of size $s$, then $\Sigma(\mathrm{Supp}(f)) \leq 2^s$.

```lean
theorem shadow_complexity_formula_bound {K : Type*} [Field K]
    {n : ℕ} (f : Polynomial (Fin n → K))
    (s : ℕ) (h : IsComputedByFormula f s) :
    shadowComplexity (supportAsFinset f) ≤ 2^s := by
  sorry -- Induction on formula structure; addition ≤ add, multiplication ≤ multiply
```

**Theorem 3 (Shadow Sub-additivity for Addition).** For finite $A, B \subseteq \mathbb{N}^n$: $\Sigma(A \cup B) \leq \Sigma(A) + \Sigma(B)$.

```lean
theorem shadow_complexity_subadditive {n : ℕ} (A B : Finset (Fin n → ℕ)) :
    shadowComplexity (A ∪ B) ≤ shadowComplexity A + shadowComplexity B := by
  sorry -- Shadow of union is subset of union of shadows
```

### Novel Definition: Shadow Complexity

```lean
/-- The shadow complexity: total mass of the shadow profile. Measures how
    "spread out" a support is through its iterated lower shadows. -/
def shadowComplexity {n : ℕ} (S : Finset (Fin n → ℕ)) : ℕ :=
  (Finset.range (maxDegree S + 1)).sum fun k => (shadow_iter S k).card

/-- Effective shadow rate: the exponential decay rate of the shadow profile.
    Analogous to entropy rate in information theory. -/
def shadowRate {n : ℕ} (S : Finset (Fin n → ℕ)) : ℝ :=
  -Real.log (shadowComplexity S) / Real.log (shadowComplexity (shadow_iter S 1) + 1)
```

### Proof Strategies

**Strategy A: Direct Induction on Shadow Iteration (MOST PROMISING).** 
Prove $\partial^k(A+B) \subseteq \bigcup_{i+j=k} \partial^i(A) + \partial^j(B)$ by induction on $k$. Base case $k=0$ is trivial. Inductive step: take $c \in \partial^{k+1}(A+B)$, so $c \in \partial(\partial^k(A+B))$. By IH, $\partial^k(A+B) \subseteq \bigcup_{i+j=k} \partial^i(A) + \partial^j(B)$. Then $c$ is in the shadow of some $\partial^i(A) + \partial^j(B)$ with $i+j=k$. Apply the key lemma: $\partial(X+Y) \subseteq (\partial(X)+Y) \cup (X+\partial(Y))$ (proved by case analysis on which summand contributed the reduced coordinate). This gives $c \in \partial^{i+1}(A) + \partial^j(B)$ or $c \in \partial^i(A) + \partial^{j+1}(B)$, completing the induction. This strategy is most promising because the key lemma is a clean combinatorial fact with a natural case analysis proof.

**Strategy B: Tropical Projection Characterization.** 
Reinterpret shadows via tropical geometry: $\partial(S) = \{v' : \exists v \in S, \; v' = v - e_i \text{ for some } i \text{ with } v_i > 0\}$. The shadow profile becomes the sequence of tropical fiber cardinalities. Use the catalog's tropical support compression results (`Catalog/Bridges/Catalog/Pythagorean/SupportCompression.lean`) to bound shadow evolution under tropical operations. This bridges to tropical geometry but requires more machinery.

**Strategy C: Information-Theoretic Entropy Argument.**
Define $H_S(k) = -\log_2(a_k^S / \Sigma(S))$ as a "shadow entropy." The convolution bound becomes a sub-additivity of entropy: $H_{A+B}(k) \geq \min_i(H_A(i) + H_B(k-i))$, analogous to the entropy power inequality. Prove via log-sum inequality applied to the convolution. This is elegant but harder to formalize in Lean 4.

### Critical Counterexample and Refined Conjecture

**The original conjecture fails.** The polynomial $f = x_1^d$ is computed by a circuit of size $s = O(\log d)$ (repeated squaring), yet has shadow profile $a_k = 1$ for all $k \leq d$. The conjectured bound $a_k \geq (s/d)^{-k} = (d/\log d)^k$ is violated for $k \geq 1$.

**Refined Conjecture (Shadow Profile Lower Bound for Multi-linear Polynomials):** If $f \in K[x_1, \ldots, x_n]$ is a *multi-linear* polynomial (each variable appears with degree $\leq 1$) computed by a formula of size $s$, and $f$ depends on all $n$ variables, then:
$$a_k^{\mathrm{Supp}(f)} \geq \binom{n}{k} \cdot \left(\frac{|\mathrm{Supp}(f)|}{2^n}\right)^{s/n}$$

**Testable Prediction:** For the determinant polynomial $\det_n$ (multi-linear, depends on all $n^2$ variables): compute shadow profiles for $n = 2, 3, 4$ and verify that the profile decay rate matches $\binom{n^2}{k}$ scaling modulated by a factor depending on circuit size. A disproof would find a multi-linear polynomial with small circuit but shadow profile decaying faster than the bound.

```lean
/-- Testable conjecture: shadow profile of multi-linear polynomials
    with full variable dependence cannot decay too rapidly. -/
theorem shadow_profile_multilinear_bound {K : Type*} [Field K] {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (h_ml : ∀ i, MvPolynomial.degree f (MvPolynomial.var i) ≤ 1)
    (h_dep : ∀ i, MvPolynomial.degree f (MvPolynomial.var i) = 1)
    (s : ℕ) (h_circuit : IsComputedByFormula f s)
    (k : ℕ) :
    (shadow_iter (supportAsFinset f) k).card ≥
      (Nat.choose n k) * |supportAsFinset f| / 2^n := by
  sorry -- Open conjecture; prove for small cases or establish weaker bound
```

### Cross-Domain Connections

1. **Algebraic Complexity ↔ Tropical Geometry:** The shadow operation $\partial$ is the combinatorial shadow of the tropical projection map. The convolution inequality $a_k^{A+B} \leq \sum_i a_i^A \cdot a_{k-i}^B$ is the combinatorial analog of the tropical convolution of Newton polytope fibers. Build on `Catalog/Speculative/AutoResearch/IteratedShadowGeometry.lean`.

2. **Shadow Complexity ↔ Information Theory:** The shadow rate $\Sigma(S)$ plays the role of entropy: sub-additive under union ("addition gates"), sub-multiplicative under Minkowski sum ("multiplication gates"). The convolution bound is the shadow analog of the entropy power inequality. This opens a "shadow information theory" connecting circuit complexity to statistical mechanics.

3. **Combinatorics ↔ Complexity:** The Kruskal-Katona theorem gives optimal shadow sizes for uniform subsets. Our convolution bound constrains shadows of Minkowski sums. The gap between Kruskal-Katona and our bound measures the "circuit overhead" — how much shadow structure multiplication gates destroy.

### Application Keywords
`circuit-lower-bounds`, `shadow-complexity`, `algebraic-complexity`, `minkowski-convolution`, `tropical-fibers`, `profile-entropy`, `newton-polytope`, `multilinear-polynomials`, `formula-complexity`

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 directions including: (1) Shadow complexity for algebraic branching programs — the key insight is that ABPs impose linear-algebraic structure on shadow profiles that formulas do not; why now: we have the convolution bound for formulas, extending to ABPs requires trace-shadow duality. (2) Shadow entropy and the entropy power inequality — the key insight is that shadow complexity satisfies the same axioms as Shannon entropy under Minkowski sum; why now: the convolution bound is precisely the log-sum inequality in disguise. (3) Tropical Langlands for Newton polytopes — bridge to representation theory: the key insight is that shadow profiles classify irreducible representations of the min-plus Hecke algebra on polytope faces; why now: the catalog's tropical framework makes this concrete.

(b) **RESEARCH_PAPER.md** — standalone paper with: Introduction (circuit lower bounds via shadow geometry), Section 2 (shadow profiles and their basic properties), Section 3 (the convolution theorem and its proof), Section 4 (shadow complexity and circuit upper bounds), Section 5 (the counterexample and refined conjecture), Section 6 (computational experiments and open problems).

(c) **ARTICLE.md** — Scientific American style: "The Shadow of Computation" — explain how every polynomial casts a shadow, and small circuits cannot hide from their shadows. The shadow profile is a fingerprint that reveals computational complexity. No mention of formal verification.

(d) **Verified algorithm:** Implement shadow profile computation and shadow complexity calculation. Include a decision procedure that, given a polynomial support and a circuit size bound, either certifies the bound is achievable or proves the shadow complexity exceeds $2^s$.

(e) **demo.py:** Interactive demonstration: (1) compute shadow profiles for $\prod(1+x_i)$, permanent, determinant; (2) visualize shadow profile decay; (3) attempt to find counterexamples to the refined conjecture via random multi-linear polynomial sampling; (4) show the $x^d$ counterexample to the original conjecture.

### Depth Requirements

- At least 3 theorems with deep proof tactics (induction on shadow iteration for Theorem 1, induction on formula structure for Theorem 2, case analysis on coordinate reduction for the key lemma).
- Novel structure: `shadowComplexity`, `shadowRate`, `shadowProfile`, `minkowskiSum` on finsets.
- Cross-domain theorem connecting shadow complexity to tropical geometry (using catalog's `certified_radius_inequality` or support compression bounds).
- The refined conjecture is falsifiable: compute shadow profiles for all multi-linear polynomials in $\leq 4$ variables with circuit size $\leq 6$ and check the bound.

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
