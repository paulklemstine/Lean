## Soli Deo Gloria

## Assignment: Certificate Density Asymptotics via the Prime Polynomial Theorem

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction

**Core Conjecture (Precise Form):** For a prime power q and n ≥ 2, the certificate density in GL_n(𝔽_q)—defined as the proportion of elements whose characteristic polynomial is irreducible—satisfies:

$$\delta_n(q) \;=\; \frac{1}{n}\,\frac{\displaystyle\sum_{d\mid n}\mu(n/d)\,q^d}{q^n - 1} \;=\; \frac{1}{n} + O\!\left(\frac{q^{-\lfloor n/2\rfloor}}{n}\right)$$

The exact formula follows from Gauss's prime polynomial theorem combined with the orbit-stabilizer structure of the characteristic polynomial fibration. The asymptotic refines it: the worst-case correction arises when n has a large proper divisor d ≈ n/2, giving the q^{-n/2} floor.

**Testable Prediction:** Compute δ_n(q) for n = 2,...,8 and q = 2,3,5,7. Fit to δ_n(q) = c/n + d·q^{-⌊n/2⌋}/n. The prediction is c = 1 exactly and |d| ≤ 1. If c deviates by more than 0.01 from 1 for any (n,q) with n ≥ 4, the conjecture's error term is wrong.

**Impact:** This establishes the first *quantitative* certificate-density theorem for general linear groups over finite fields, providing the key input for generation probability lower bounds (Theorem 4 in the catalog). It also forges a new bridge between the certificate framework and analytic number theory over function fields—the function-field analogue of the prime number theorem now directly governs the algebraic generation properties of matrix groups.

**Catalog References:** `Algebra/MatrixGroupGeneration.lean` (Theorem 4: `generation_lower_bound_of_certificate_system`), `Algebra/SymmGroupGen/Basic.lean` (analogous density bounds for S_n via cycle-type certificates).

---

### Precise Theorem Targets with Lean 4 Type Signatures

**Definition 1 (Novel): Certificate System for a Group**

```lean
/-- A certificate system for a group G consists of a decidable predicate on G
    (the "certificate condition") together with a proof that any subset of G
    containing enough certificate-holders generates G. -/
structure CertificateSystem (G : Type*) [Group G] [Fintype G] where
  cert : G → Prop
  cert_decidable : DecidablePred cert
  generation_threshold : ℕ
  generation_proof : ∀ S : Finset G,
    (S.card ≥ generation_threshold ∧ ∀ g ∈ S, cert g) → 
    Subgroup.closure (S : Set G) = ⊤
```

**Definition 2 (Novel): Characteristic Polynomial Fiber Measure**

```lean
/-- The fiber measure: for a monic polynomial f of degree n over F_q with
    nonzero constant term, the number of matrices in GL_n(F_q) with
    characteristic polynomial equal to f. -/
def charpolyFiberSize (q n : ℕ) [Fact (Nat.Prime q)] 
    (f : Polynomial (ZMod q)) 
    (hf : f.Monic ∧ f.natDegree = n ∧ f.coeff 0 ≠ 0) : ℕ :=
  Fintype.card {A : Matrix.GeneralLinearGroup (Fin n) (ZMod q) // 
    Matrix.charpoly (A.val : Matrix (Fin n) (Fin n) (ZMod q)) = f}
```

**Theorem 1: Centralizer Cardinality for Irreducible Characteristic Polynomial**

This is the key structural lemma. When the characteristic polynomial of A ∈ GL_n(𝔽_q) is irreducible, the centralizer C_{GL_n}(A) is isomorphic to 𝔽_{q^n}^×, hence has cardinality q^n - 1.

```lean
theorem centralizer_card_of_irreducible_charpoly 
    (q n : ℕ) [Fact (Nat.Prime q)] [Fintype (ZMod q)] 
    (A : Matrix.GeneralLinearGroup (Fin n) (ZMod q))
    (hA : Irreducible (Matrix.charpoly (A : Matrix (Fin n) (Fin n) (ZMod q)))) :
    Fintype.card (MulEquiv.invFun 
      (Matrix.GeneralLinearGroup.centralizerEquiv A)) = q ^ n - 1 := by
  sorry -- KEY PROOF OBLIGATION
```

*Proof approach:* The irreducible characteristic polynomial means A generates a degree-n field extension 𝔽_q[A] ≅ 𝔽_{q^n} inside M_n(𝔽_q). The centralizer in GL_n equals 𝔽_{q^n}^× (the units of this embedded field). Use the companion matrix normal form and the isomorphism between the centralizer and the multiplicative group of the splitting field.

**Theorem 2: Exact Certificate Density Formula**

```lean
theorem certificate_density_exact_formula (q n : ℕ) [Fact (Nat.Prime q)] 
    [Fintype (ZMod q)] (hn : 2 ≤ n) :
    (Fintype.card {A : Matrix.GeneralLinearGroup (Fin n) (ZMod q) // 
        Irreducible (Matrix.charpoly (A : Matrix (Fin n) (Fin n) (ZMod q)))} : ℝ) 
    / (Fintype.card (Matrix.GeneralLinearGroup (Fin n) (ZMod q)) : ℝ) 
    = (irreducibleMonicCount q n : ℝ) / (q ^ n - 1 : ℝ) := by
  sorry -- KEY PROOF OBLIGATION
```

where `irreducibleMonicCount q n` is the count from Gauss's formula.

*Proof approach:* Orbit-stabilizer for the conjugation action of GL_n on itself. Each conjugacy class with irreducible characteristic polynomial f has size |GL_n|/(q^n - 1) by Theorem 1. The number of such f is `irreducibleMonicCount q n`. Divide through by |GL_n|.

**Theorem 3: Certificate Density Asymptotic Bound**

```lean
theorem certificate_density_asymptotic (q n : ℕ) [Fact (Nat.Prime q)] 
    [Fintype (ZMod q)] (hq : 2 ≤ q) (hn : 2 ≤ n) :
    |(irreducibleMonicCount q n : ℝ) / (q ^ n - 1 : ℝ) - (1 : ℝ) / n| 
    ≤ (1 : ℝ) / (n * (q ^ (n / 2) - 1)) := by
  sorry -- KEY PROOF OBLIGATION
```

*Proof approach:* Expand using Gauss's formula. Write the numerator as (1/n)(q^n + Σ_{d|n, d<n} μ(n/d)q^d). Factor out q^n from the numerator and q^n from the denominator. The main term gives 1/n. The error comes from: (a) proper divisors d < n contributing at most q^{⌊n/2⌋}/n (since the largest proper divisor of n is at most n/2), and (b) the denominator (q^n - 1) vs q^n contributing a factor of (1 - q^{-n})^{-1} ≈ 1 + q^{-n}. Bound both error terms.

---

### Proof Strategies (Three Paths)

**Strategy A: Orbit-Stabilizer + Companion Matrix Normal Form (RECOMMENDED)**

This is the most direct and most amenable to formalization.

1. **Step 1**: Prove that for A ∈ GL_n(𝔽_q) with irreducible characteristic polynomial f, the centralizer C(A) equals 𝔽_q[A]^× ≅ 𝔽_{q^n}^×. Key sub-lemma: the 𝔽_q-algebra generated by A inside M_n(𝔽_q) is a field when f is irreducible (Cayley-Hamilton gives the field structure). Its degree over 𝔽_q is n (since f has degree n). Use the companion matrix to reduce to a concrete computation.

2. **Step 2**: Apply the orbit-stabilizer theorem to the conjugation action of GL_n on itself. The orbit of A is its conjugacy class, of size |GL_n|/|C(A)| = |GL_n|/(q^n - 1). This is uniform across all A with the same irreducible f.

3. **Step 3**: Count conjugacy classes. Each irreducible monic polynomial f of degree n with f(0) ≠ 0 (automatic for n ≥ 2) corresponds to exactly one conjugacy class. Sum over all such f. Divide by |GL_n| to get the density.

*Why this is most promising:* Each step maps cleanly to existing Mathlib infrastructure (orbit-stabilizer, polynomial irreducibility, field extensions). The companion matrix provides a concrete computational handle.

**Strategy B: Rational Canonical Form Decomposition**

1. Partition GL_n by the rational canonical form type of the characteristic polynomial (which encodes the invariant factor decomposition).
2. Show that the "irreducible type" (single invariant factor of degree n) contributes exactly I_n(q) conjugacy classes, each of the same size.
3. Compute the density by summing over these classes.

*Advantage:* More structural—reveals the full partition of GL_n by characteristic polynomial type. *Disadvantage:* Requires developing rational canonical form in Lean, which is a major undertaking.

**Strategy C: Zeta Function / Generating Function Approach**

1. Define the zeta function Z_q(s) = ∏_P (1 - |P|^{-s})^{-1} over monic irreducibles P over 𝔽_q. This equals 1/(1 - q^{1-s}) by the function-field identity.
2. Show that the certificate density generating function ∑_n δ_n(q) · (q^n - 1) · x^n relates to the logarithmic derivative of Z_q.
3. Extract the asymptotic via contour methods (or their discrete analogue).

*Advantage:* Deepest connection to analytic number theory. *Disadvantage:* Requires substantial development of function-field analytic number theory in Lean. Use this for the cross-domain theorem, not the main proof.

---

### Cross-Domain Connections

**Connection 1: Function-Field Riemann Hypothesis → Certificate Distribution (Number Theory × Group Theory)**

The Weil conjectures (proved by Weil himself for curves, Deligne in general) imply that the error term in the prime polynomial theorem satisfies a "Riemann hypothesis" bound: the error in counting irreducible polynomials of degree ≤ n is O(q^{n/2}). This directly controls the certificate density error term. Formalize:

```lean
/-- The certificate density error is bounded by the Weil-type bound on
    the prime polynomial counting function. This is the function-field
    analogue of how the Riemann Hypothesis controls prime distribution. -/
theorem certificate_density_weil_bound (q n : ℕ) [Fact (Nat.Prime q)] (hn : 2 ≤ n) :
    |(irreducibleMonicCount q n : ℝ) / (q ^ n : ℝ) - (1 : ℝ) / n| 
    ≤ (1 : ℝ) / (n * (q ^ (n / 2) : ℝ)) := by
  sorry
```

**Connection 2: Random Matrix Theory over Finite Fields (Probability × Representation Theory)**

The characteristic polynomial of a uniformly random matrix in GL_n(𝔽_q) induces a probability measure on monic polynomials of degree n. Fulman (1997) and others showed this measure is *approximately* uniform. The certificate density result quantifies this: the probability of landing in the "irreducible fiber" is δ_n(q) ≈ 1/n, which equals the uniform measure probability (since the fraction of monic polynomials that are irreducible is also ≈ 1/n). This is NOT a coincidence—it reflects the approximate uniformity of the characteristic polynomial map, which is a finite-field shadow of the Keating-Snares circular unitary ensemble results.

**Connection 3: Cohen-Lenstra Heuristics (Algebraic Number Theory)**

The Cohen-Lenstra heuristics predict the distribution of class groups of number fields. Their function-field analogues concern the distribution of Picard groups of curves over 𝔽_q. The certificate density for GL_n(𝔽_q) is governed by the same arithmetic functions (Möbius, divisor sums) that appear in Cohen-Lenstra. This suggests a deeper structural connection: generation properties of matrix groups over finite fields are controlled by the same arithmetic that governs class groups.

---

### Application Keywords

`finite-field-cryptography`, `group-generation-probability`, `function-field-number-theory`, `random-matrix-theory`, `certificate-density`, `Möbius-inversion`, `Weil-bounds`, `Cohen-Lenstra`, `characteristic-polynomial-fibration`, `orbit-stabilizer-method`, `companion-matrix`, `rational-canonical-form`

---

### Conjecture with Testable Prediction

**Conjecture (Higher-Order Certificate Density):** For n ≥ 2 and prime q ≥ 2, the certificate density admits the full asymptotic expansion:

$$\delta_n(q) = \frac{1}{n} + \frac{c_1(n,q)}{n \cdot q^{\lfloor n/2 \rfloor}} + \frac{c_2(n,q)}{n \cdot q^n} + O\!\left(\frac{1}{n \cdot q^{n+\lfloor n/2 \rfloor}}\right)$$

where c_1(n,q) = μ(n/p) · p if n = p^k for some prime p (and 0 if n is squarefree with more than one prime factor), and c_2(n,q) = -1 (coming from the (q^n - 1) vs q^n denominator correction).

**Computational Test:** For n = 6, q = 2: compute δ_6(2) exactly. The prediction gives δ_6(2) = 1/6 + c_1/(6·2^3) + c_2/(6·2^6). Since 6 = 2·3 is squarefree with two prime factors, c_1 = 0 and c_2 = -1. So δ_6(2) ≈ 1/6 - 1/384 ≈ 0.16667 - 0.00260 ≈ 0.16406. Compute the exact value and check if the residual after subtracting 1/6 + c_1/(6·2^3) + c_2/(6·2^6) is bounded by 1/(6·2^9) ≈ 0.00003.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md**: 3-5 research directions. Each must include "The key insight is..." and "Why now?" At least one direction must bridge to a different domain (suggested: bridge to quantum error-correcting codes via the certificate density as a measure of "good stabilizer generators" in the finite-field setting).

(b) **RESEARCH_PAPER.md**: Standalone scientific document. Someone reading ONLY this paper must understand: (i) the exact formula for certificate density in GL_n(𝔽_q), (ii) why the 1/n asymptotic is the function-field shadow of the prime number theorem, (iii) how the orbit-stabilizer structure of the characteristic polynomial fibration makes the proof work, (iv) what the Weil-bound connection implies for future work.

(c) **ARTICLE.md**: Scientific American style. Explain how the humble question "what fraction of random matrices generate the general linear group?" leads to the same arithmetic that counts prime polynomials—the function-field twin of the prime number theorem. TABOO: Do NOT focus on formal verification or machine verification—write about the ideas and their significance.

(d) **Verified algorithm**: A certified algorithm that, given (q, n), computes the exact certificate density δ_n(q) using the Möbius inversion formula, with a correctness proof linking the output to the orbit-stabilizer counting argument.

(e) **demo.py**: Interactive demonstration computing certificate densities for GL_n(𝔽_q) for n = 2,...,8 and q = 2,3,5,7, comparing exact values against the 1/n asymptotic, visualizing the convergence, and testing the higher-order conjecture.

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
