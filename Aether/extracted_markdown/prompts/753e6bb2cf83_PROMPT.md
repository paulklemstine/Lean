## Soli Deo Gloria

## Assignment: Direction 1: Spectral Fingerprints for Classical Subgroups

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

**Core Vision**: The characteristic polynomial of a random matrix is not just a combinatorial object — it is a *group-theoretic spectral invariant* that encodes the ambient symmetry group's type. Just as Wigner demonstrated that GOE/GUE/GSE ensembles are distinguished by their level-spacing statistics over ℝ, we establish that the classical families GL_n, SL_n, Sp_{2n}, O_n over finite fields are distinguished by their characteristic polynomial statistics over F_q. This is the finite-field analogue of Wigner's classification — and it yields a *computational group recognition* tool of unprecedented power.

---

### Precise Theorem Targets

**Theorem 1 — Palindromic Characteristic Polynomial of Symplectic Matrices (Structural Foundation)**

If A ∈ Sp_{2n}(F_q) (the symplectic group preserving the standard alternating form J), then the characteristic polynomial of A is self-reciprocal: f(x) = x^{2n} · f(1/x). Equivalently, the coefficient sequence is palindromic.

Lean 4 type signature:
```lean
theorem symplectic_charpoly_self_reciprocal
    {R : Type*} [CommRing R] [IsDomain R]
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin (2 * n)) (Fin (2 * n)) R)
    (hA : A ∈ Matrix.symplecticGroup (Fin (2 * n)) R) :
    ∀ i : Fin (2 * n + 1),
      (A.charpoly : R[X]).coeff i = (A.charpoly : R[X]).coeff (2 * n - i) :=
  by
  -- Key insight: A ∈ Sp means AᵀJA = J, so A⁻¹ = J⁻¹AᵀJ.
  -- Then charpoly(A⁻¹) = charpoly(J⁻¹AᵀJ) = charpoly(Aᵀ) = charpoly(A).
  -- But charpoly(A⁻¹)(x) = x^{2n} · charpoly(A)(1/x) (up to unit).
  -- Combining: charpoly(A)(x) = x^{2n} · charpoly(A)(1/x).
```

*Proof Strategy A (Recommended — conjugation-invariance path)*:
1. Prove `symplectic_inv_transpose`: For A ∈ Sp_{2n}, A⁻¹ = J⁻¹ · Aᵀ · J (from the defining relation AᵀJA = J).
2. Prove `charpoly_conj_eq`: charpoly(P⁻¹AP) = charpoly(A) for any invertible P (already in Mathlib as `Matrix.charpoly_similar`).
3. Chain: charpoly(A⁻¹) = charpoly(J⁻¹AᵀJ) = charpoly(Aᵀ) = charpoly(A) (transpose invariance).
4. Prove `charpoly_inv_reverse`: charpoly(A⁻¹)(x) = (det A)⁻¹ · x^{2n} · charpoly(A)(1/x) for any invertible A. Since det(A) = 1 for symplectic matrices, this gives the result.

*Proof Strategy B (Direct coefficient computation)*:
1. Expand charpoly(A) = det(xI - A) using cofactor expansion.
2. Use the symplectic constraint to show each 2×2 block contributes symmetrically.
3. This is more computational but avoids needing the inverse-transpose identity.

Strategy A is strongly preferred: it is conceptual, generalizes immediately, and the key lemma `charpoly_inv_reverse` is itself a fundamental result worth having.

---

**Theorem 2 — Constant Term Constraint for SL_n (Determinant Fingerprint)**

If A ∈ SL_n(F_q), then the constant term of charpoly(A) equals (-1)^n. This restricts the polynomial space by a factor of (1 - 1/q) compared to GL_n.

Lean 4 type signature:
```lean
theorem sl_charpoly_constant_term
    {R : Type*} [CommRing R]
    {n : ℕ} (A : Matrix (Fin n) (Fin n) R)
    (hA : A ∈ Matrix.SpecialLinearGroup (Fin n) R) :
    (A.charpoly : R[X]).coeff 0 = (-1 : R) ^ n :=
  by
  -- The constant term of det(xI - A) is det(-A) = (-1)^n det(A) = (-1)^n.
```

*Proof*: This follows from `Matrix.charpoly_coeff_zero_eq_neg_det` or similar, which should give coeff 0 = (-1)^n · det(A). Since det(A) = 1 in SL_n, the result is immediate. While the proof may be short, the *consequence* is profound: it constrains the polynomial space for the counting arguments that follow.

---

**Theorem 3 — Distinct Irreducible Rates for SL_2 vs GL_2 (The Separation Result)**

For any prime power q ≥ 3, the fraction of elements in SL_2(F_q) with irreducible characteristic polynomial differs from the fraction in GL_2(F_q). Concretely:

- ρ_irr(GL_2, q) = q / (2(q + 1))
- ρ_irr(SL_2, q) = (q - 1) / (2q)  [for odd q]

These are equal iff q² - q - 2 = 0, i.e., q ≈ 2.41, which has no prime power solution.

Lean 4 type signature:
```lean
theorem sl2_gl2_irreducible_rate_separate
    (q : ℕ) (hq : 3 ≤ q) (hq_prime : Nat.Prime q) :
    irreducibleRateGL 2 q ≠ irreducibleRateSL 2 q :=
  by
  -- Compute both rates exactly using conjugacy class counting,
  -- then show the rational numbers differ.
```

*Proof Strategy A (Conjugacy class counting — Recommended)*:
1. Count irreducible monic polynomials of degree 2 over F_q: there are q(q-1)/2.
2. For GL_2: each irreducible charpoly f has centralizer ≅ F_{q²}^* of order q²-1. Elements with irreducible charpoly = (q(q-1)/2) × |GL_2|/(q²-1) = q²(q-1)²/2. Rate = q/(2(q+1)).
3. For SL_2: irreducible charpoly must have constant term 1. Count irreducible monic polynomials of degree 2 with constant term 1 using multiplicative character sums over F_q^*. The centralizer in SL_2 is ker(N : F_{q²}^* → F_q^*) of order q+1. Rate = (q-1)/(2q).
4. Show q/(2(q+1)) ≠ (q-1)/(2q) by cross-multiplying: q² ≠ (q-1)(q+1) = q²-1, which holds for all q ≥ 2.

*Proof Strategy B (Character sum method — generalizes to higher n)*:
1. Use the orthogonality relation for multiplicative characters: 𝟙_{f(0)=c} = (1/(q-1)) Σ_χ χ(f(0)·c⁻¹).
2. Apply to the count of irreducible polynomials with prescribed constant term.
3. The main term gives (1/(q-1)) of all irreducible polynomials; error terms vanish for degree 2 by direct computation.
4. This method scales to SL_n for general n using Weil's Riemann hypothesis for curves.

---

### Novel Definitions Required

**Definition 1 — Self-Reciprocal Polynomial** (new to catalog):
```lean
/-- A polynomial f of degree d is self-reciprocal if f(x) = x^d · f(1/x),
    i.e., its coefficient sequence is palindromic: coeff i = coeff (d - i). -/
def Polynomial.IsSelfReciprocal {R : Type*} [Semiring R] (f : R[X]) : Prop :=
  f = f.reverse ∧ f.Monic

/-- The set of self-reciprocal monic polynomials of degree d over F_q. -/
def selfReciprocalPolys (q d : ℕ) : Finset (ZMod q)[X] :=
  {f : (ZMod q)[X] | f.Monic ∧ f.natDegree = d ∧ f.IsSelfReciprocal}
```

**Definition 2 — Irreducible Rate** (extends catalog fingerprint framework):
```lean
/-- The fraction of elements in a finite matrix group G ⊆ GL_n(F_q)
    whose characteristic polynomial is irreducible over F_q. -/
def irreducibleRate (G : Subgroup (GL (Fin n) (ZMod q))) : ℚ :=
  (Finset.filter (fun A => Irreducible (A.val.charpoly : (ZMod q)[X]))
    G.carrier.toFinset).card / |G|
```

Build on `Catalog/Algebra/CharpolyRecognition.lean` by extending the `Fingerprint` structure with a `groupType : ClassicalGroupFamily` field and a `spectralProfile : SpectralProfile` containing the irreducible and split rates.

---

### Cross-Domain Connections

**Connection 1 — Functional Equations of L-functions (Number Theory ↔ Group Theory)**

The self-reciprocity constraint f(x) = x^d f(1/x) for symplectic characteristic polynomials is the *exact polynomial analogue* of the functional equation Λ(s) = ε · Λ(1-s) satisfied by L-functions. Just as the sign ε in the functional equation distinguishes orthogonal from symplectic automorphic representations (by the work of Arthur), the self-reciprocity constraint distinguishes Sp_{2n} from GL_n at the level of characteristic polynomials.

Formalize this connection:
```lean
/-- Bridge theorem: A polynomial f is self-reciprocal iff its "L-analogue"
    L_f(s) = Σ a_n n^{-s} (from coefficients of f) satisfies a functional equation
    with sign ε = +1. This connects group type to automorphic sign. -/
theorem self_reciprocal_iff_functional_equation_sign_positive
    {R : Type*} [Field R] [CharZero R]
    {f : R[X]} (hf : f.Monic) (hd : f.natDegree > 0) :
    f.IsSelfReciprocal ↔ functionalEquationSign f = 1 :=
  by sorry  -- Requires building the L-analogue dictionary
```

This is the bridge theorem that translates between "symplectic group" and "self-dual automorphic representation with trivial central character."

**Connection 2 — Wigner-Dyson Classification (Random Matrix Theory ↔ Finite Group Theory)**

Over ℝ, Wigner showed that GOE, GUE, GSE ensembles are distinguished by their eigenvalue spacing statistics (Poisson vs. GSE repulsion). Our result is the finite-field, characteristic-polynomial analogue: the "spacing statistics" are replaced by irreducibility/splitting rates, and the ensemble type (GOE/GUE/GSE) is replaced by the classical group family (O/GL/Sp). The deep reason both classifications work is the same: the group's symmetry type constrains the spectral measure.

**Connection 3 — Coding Theory (Self-reciprocal polynomials = Self-dual cyclic codes)**

A self-reciprocal polynomial f over F_q is the generator polynomial of a self-dual cyclic code. The irreducible rate for Sp_{2n}(F_q) thus equals the probability that a random self-dual cyclic code of length 2n is generated by an irreducible polynomial. This bridges group recognition to coding-theoretic questions about the structure of self-dual codes.

---

### Testable Conjecture

**Conjecture (Spectral Separation for All Classical Families)**: For any two distinct classical group families G, G' ∈ {GL_n, SL_n, Sp_{2n}, O_n, SO_n, SU_n} over F_q (where both are defined with the same dimension parameter), and any prime power q ≥ 3, the irreducible rates satisfy:

ρ_irr(G, n, q) ≠ ρ_irr(G', n, q)

**Computational test (falsifiable)**: For n = 2, q = 3, enumerate ALL elements of each group and compute the exact irreducible rate:

| Group | Size | Predicted ρ_irr | Computation |
|-------|------|-----------------|-------------|
| GL_2(F_3) | 48 | 3/8 = 0.375 | Count irreducible charpolys |
| SL_2(F_3) | 24 | 1/4 = 0.250 | Count irreducible charpolys with const=1 |
| Sp_2(F_3) ≅ SL_2(F_3) | 24 | same as SL_2 | Verify Sp_2 ≅ SL_2 for n=1 |

For n = 4, q = 5 (where Sp_4 ≠ SL_4):
| Group | Size | Key constraint | Predicted difference |
|-------|------|----------------|---------------------|
| GL_4(F_5) | ~13.5M | none | baseline |
| Sp_4(F_5) | ~1.3M | palindromic charpoly | ρ_irr(Sp_4) < ρ_irr(GL_4) |

If any pair gives the same irreducible rate (to floating-point precision from 10,000 random samples), the conjecture is falsified.

**Stronger test**: The split rate (fraction of elements with all eigenvalues in F_q) should also separate families. For Sp_{2n}, eigenvalue λ forces eigenvalue λ⁻¹, so the split rate is constrained differently than for GL_n.

---

### Proof Architecture Summary

```
Theorem 1: symplectic_charpoly_self_reciprocal
  ↳ Lemma: A⁻¹ = J⁻¹AᵀJ for A ∈ Sp
  ↳ Lemma: charpoly_transpose_eq (Mathlib)
  ↳ Lemma: charpoly_conj_eq (Mathlib: Matrix.charpoly_similar)
  ↳ Lemma: charpoly_inv_reverse (NEW — fundamental, reusable)

Theorem 2: sl_charpoly_constant_term
  ↳ Lemma: coeff_zero_eq_neg_det (derive from charpoly definition)
  ↳ Lemma: det_eq_one_in_SL (Mathlib: SpecialLinearGroup)

Theorem 3: sl2_gl2_irreducible_rate_separate
  ↳ Theorem 1 + Theorem 2 (structural constraints)
  ↳ Counting: irreducible polys of degree 2 (number theory)
  ↳ Counting: irreducible polys with prescribed constant term (character sums)
  ↳ Centralizer orders in GL_2 vs SL_2 (group theory)
  ↳ Algebraic inequality: q/(2(q+1)) ≠ (q-1)/(2q) for q ≥ 3
```

---

### Catalog Integration

Build directly on:
- `Catalog/Algebra/CharpolyRecognition.lean`: Extend the `Fingerprint` structure with a `groupType` field and `spectralProfile` containing `{irreducibleRate, splitRate, selfReciprocalRate}`. The existing `fingerprintLoss` function should be extended to penalize incorrect group-type identification.
- `Catalog/Algebra/MatrixGroupGeneration.lean`: The `GenerationCertificate` should include a `spectralFingerprint : SpectralProfile` field, enabling group recognition from characteristic polynomial statistics alone.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions. Each must include "The key insight is..." and "Why now?" At least one direction must bridge to a different domain (suggested: L-function functional equations or quantum error-correcting codes).

(b) **RESEARCH_PAPER.md**: Standalone scientific document. Must contain: (1) precise statements of all theorems, (2) complete proof sketches with lemma dependencies, (3) the self-reciprocity ↔ functional-equation dictionary as a conceptual contribution, (4) computational verification data for q ≤ 7, n ≤ 4, (5) the Wigner-Dyson analogy as motivation.

(c) **ARTICLE.md**: Scientific American style. Focus on the *idea* that "the symmetry group of a matrix leaves a fingerprint in its characteristic polynomial — like how the species of a creature is encoded in its DNA." TABOO: Do NOT focus on formal verification or machine proofs. Write about the mathematical discovery and its implications for recognizing hidden symmetries in data.

(d) **Verified algorithm**: A `spectralFingerprint` function that, given a finite matrix group (as a finset of matrices), computes the irreducible rate, split rate, and self-reciprocal rate of characteristic polynomials. Must be proven correct against the formal definitions.

(e) **demo.py**: Sample 10,000 random elements from SL_3(F_7) and Sp_4(F_5), compute characteristic polynomial statistics, and perform chi-squared tests against the GL_n baseline. Display results as a bar chart comparing irreducible rates across group families. Include the exact theoretical predictions for n=2, q=3 as a validation check.

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
