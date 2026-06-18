## Assignment: Newton's Inequality via Lorentzian Polynomials — A Grand Challenge Formalization

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

---

### The Breakthrough Theorem

**Conjecture (Brändén–Huh → Newton):** The complete Newton inequality $\tilde{e}_k^2 \geq \tilde{e}_{k-1} \cdot \tilde{e}_{k+1}$ for all $k \in [1, n-1]$ follows from the fact that $\prod_{i=1}^{n}(X_0 + w_i X_1)$ is a Lorentzian polynomial, which forces its coefficient sequence to be ultra-log-concave.

**Precise Theorem Statement (Lean 4 type signatures):**

```lean
-- Core definition: Lorentzian polynomial (Brändén-Huh, 2020)
-- A degree-d homogeneous polynomial f ∈ ℝ[x₀,...,x_{n-1}] is Lorentzian if:
-- (1) all coefficients are non-negative
-- (2) support is M-convex (every exchange axiom holds)
-- (3) for every α with |α| = d-2, the quadratic form ∂^α f has ≤ 1 positive eigenvalue
def IsLorentzian {n : ℕ} (f : MVPolynomial (Fin n) ℝ) (d : ℕ) : Prop :=
  f.IsHomogeneous d ∧
  ∀ α : (Fin n) →₀ ℕ, α.sum = d - 2 →
    (∀ i, (f.coeff α) ≥ 0) ∧
    HasAtMostOnePositiveEigenvalue (hessianQuadraticForm f α)

-- Key structural theorem: products of nonneg linear forms are Lorentzian
theorem prod_linear_lorentzian {m n : ℕ} (w : Fin m → Fin n → ℝ)
    (hw : ∀ i j, w i j ≥ 0) :
    IsLorentzian (∏ i : Fin m, (∑ j, C (w i j) * X j)) m := by
  sorry

-- The deep result: Lorentzian ⟹ ULC coefficient sequence
theorem lorentzian_implies_ulc {n d : ℕ} {f : MVPolynomial (Fin n) ℝ}
    (hL : IsLorentzian f d) :
    UltraLogConcave (lorentzianCoeffSeq f hL) := by
  sorry

-- Crown jewel: Newton's inequality from Lorentzian theory
theorem newton_inequality_lorentzian {n : ℕ} (w : Fin n → ℝ) (hw : ∀ i, w i ≥ 0) :
    ∀ k : Fin (n - 1),
      (normalizedESEq w k)^2 ≥
      (normalizedESEq w (k - 1)) * (normalizedESEq w (k + 1)) := by
  sorry
```

---

### Three Proof Strategies (Ranked by Promise)

**Strategy A — Operator-Theoretic (MOST PROMISING):** Prove that Lorentzian polynomials form a closed cone under three operations: (1) nonneg linear combinations, (2) multiplication of degree-$d_1$ and degree-$d_2$ Lorentzian polynomials yielding a degree-$(d_1+d_2)$ Lorentzian polynomial, and (3) partial differentiation $\partial/\partial x_i$ reducing degree by 1 while preserving the Lorentzian property. Since each linear form $L_i = w_{i0}x_0 + \cdots + w_{i,n-1}x_{n-1}$ with nonneg coefficients is Lorentzian of degree 1 (trivially: M-convex support = single monomial, Hessian condition vacuous at degree $-1$), closure under multiplication immediately gives that $\prod L_i$ is Lorentzian. Then prove the ULC property by induction on degree: the base case $d=2$ is a direct quadratic form eigenvalue computation, and the inductive step uses that $\partial_{x_i} f$ is Lorentzian of degree $d-1$ and applies the induction hypothesis to get log-concavity of the "derivative" coefficients, which transfers to log-concavity of the original coefficients via the identity $e_k = e_{k-1}' + e_k'$ (where primes denote derivatives).

**Strategy B — Direct Hessian Computation:** For $f = \prod_{i=1}^n(X_0 + w_i X_1)$, explicitly compute the Hessian quadratic form at every $\alpha$ with $|\alpha| = n-2$. This polynomial is univariate (in $X_1/X_0$ after dehomogenization), so the Hessian is a $1 \times 1$ matrix — the condition reduces to checking that a single number is nonneg, which follows from the nonnegativity of the $w_i$. This is elegant for the bivariate case but doesn't scale to the general Lorentzian framework. **Use this as a verification lemma, not the main proof path.**

**Strategy C — Matroid-Theoretic:** Prove that the support of $\prod_{i=1}^n(X_0 + w_i X_1)$ corresponds to the matroid $U_{2,n}$ (uniform matroid), which has M-convex base polytope. Then use the Hodge-index-theorem analogy: for matroids, the combinatorial Hodge theorem (proved by Adiprasito-Huh-Katz) implies the log-concavity. This is the deepest route but requires formalizing substantial matroid theory. **Reserve for future work; mention in FUTURE_DIRECTIONS.**

**Recommended path:** Strategy A for the main theorem, Strategy B as a sanity-check lemma, Strategy C as a FUTURE_DIRECTIONS item.

---

### Depth Requirements (MANDATORY)

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define `IsLorentzian`, `MConvexSupport`, and `HasAtMostOnePositiveEigenvalue` — none exist in the catalog.
4. **Cross-domain connections**: Prove at least one theorem connecting Lorentzian polynomials to a different domain (see below).
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

### Cross-Domain Bridges

**Lorentzian Polynomials ↔ Tropical Geometry:** The tropicalization of a Lorentzian polynomial $f$ is the piecewise-linear function $\text{Trop}(f) = \min_\alpha \{\text{val}(c_\alpha) + \alpha \cdot v\}$. Prove the bridge theorem:

```lean
-- Bridge theorem: Lorentzian polynomials have tropicalizations
-- whose Newton polytope is a generalized permutohedron
theorem lorentzian_tropical_permutohedron {n d : ℕ} {f : MVPolynomial (Fin n) ℝ}
    (hL : IsLorentzian f d) :
    IsGeneralizedPermutohedron (newtonPolytope f) := by
  sorry
```

This connects to Postnikov's theory of generalized permutohedra and the catalog's tropical geometry results.

**Lorentzian Polynomials ↔ Information Theory:** ULC sequences satisfy the entropy power inequality. Prove:

```lean
-- ULC sequences satisfy a discrete entropy power inequality
theorem ulc_entropy_power {a : ℕ → ℝ} (ha : UltraLogConcave a) :
    2 * entropy a ≥ entropy (a * a) := by
  sorry
```

**Application Keywords:** `Lorentzian-polynomials`, `Newton-inequalities`, `matroid-Hodge-theory`, `log-concave-sequences`, `combinatorial-Hodge-theory`, `tropical-convex-optimization`, `entropy-power-inequality`, `permutohedra`

---

### Falsifiable Conjecture

**Conjecture (Lorentzian Spectral Gap):** For any Lorentzian polynomial $f$ of degree $d$ in $n$ variables with all coefficients in $[0,1]$, the spectral gap of the Hessian quadratic form $\partial^\alpha f$ satisfies:
$$\lambda_{\max}(\partial^\alpha f) - \lambda_2^+(\partial^\alpha f) \geq \frac{1}{d^2}$$
where $\lambda_2^+$ is the second positive eigenvalue (defined as 0 if there's only one positive eigenvalue).

**Test:** For $n \leq 8$, $d \leq 6$, enumerate all M-convex supports and random nonneg coefficients, compute Hessian eigenvalues numerically, check if the gap bound holds. A single counterexample refutes the conjecture.

---

### Mandatory Deliverables

You MUST produce ALL of:

**(a)** `FUTURE_DIRECTIONS.md` with 3–5 testable scientific hypotheses — each a falsifiable conjecture with a clear computational test.

**(b)** `RESEARCH_PAPER.md` — a standalone scientific document. Someone reading ONLY this paper must understand what was discovered, why it matters, and what to investigate next. No access to code required.

**(c)** `ARTICLE.md` — Scientific American style. Engaging, accessible. **TABOO:** Do NOT focus on formal verification or machine verification — write about the ideas and their significance.

**(d)** A verified algorithm: e.g., `lorentzianCheck(f, d)` that verifies whether a given polynomial is Lorentzian by checking M-convexity and the Hessian condition, with a correctness proof.

**(e)** `demo.py` demonstrating: (1) generate random weight vectors, (2) form $\prod(1 + w_i X)$, (3) verify Lorentzian properties numerically, (4) check Newton's inequality holds, (5) display the spectral gap of Hessians.

---

### Catalog Integration

Build directly on:
- `Pythagorean/UltraLogConcave.lean` — extend `UltraLogConcave` definition and `ultra_log_concavity` theorem
- `Pythagorean/UltraLogConcaveDefs.lean` — use existing `ulc_two_weights` as a base case
- The new `IsLorentzian` definition should be in a new file `Pythagorean/Lorentzian.lean`

---

### Revolutionary Significance

This would be the **first machine-verified proof of Newton's inequality via the Lorentzian polynomial framework**, establishing Brändén–Huh's 2020 breakthrough in a proof assistant. Beyond Newton, this opens:
- **Combinatorial Hodge theory** in Lean (the Adiprasito–Huh–Katz theorem on log-concavity of matroid sequences)
- **Tropical optimization**: Lorentzian polynomials certify convexity of tropical varieties, enabling certified tropical optimization algorithms
- **Information-theoretic inequalities**: ULC ⟹ entropy power inequality, connecting combinatorics to Shannon theory
- **Algebraic statistics**: Lorentzian polynomials characterize strong log-concavity in toric models

This is not incremental — it is importing an entire field into formal mathematics.

---

*Ad maiorem Dei gloriam*

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
