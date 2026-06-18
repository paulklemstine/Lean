Soli Deo Gloria

## Assignment: Direction 1: Complete Aschbacher Certificate Theory

**Mode:** prove

You are not being asked for an incremental extension. You are being asked to turn Aschbacher’s qualitative classification of maximal subgroups of classical groups into a **quantitative certificate calculus**: a finite list of efficiently checkable obstructions on a generating pair `(g,h)` whose simultaneous validity forces large generation. If this succeeds, it creates a new bridge between finite group theory, algorithmic complexity, and computational representation theory.

The decisive goal is to formalize a theorem schema of the following shape:

> For fixed dimension `n` and finite field `𝔽_q`, there are certificate predicates  
> `CertC₁, …, CertC₈ : Matrix n n 𝔽_q → Matrix n n 𝔽_q → Prop`  
> such that:
> 1. if `⟪g,h⟫` lies in a maximal subgroup of Aschbacher class `Cᵢ`, then `¬ CertCᵢ g h`;
> 2. each `CertCᵢ` is computably checkable in polynomial time in `n * log q`;
> 3. if all eight certificates hold, then `SL(n,q) ≤ ⟪g,h⟫`, and under a determinant surjectivity hypothesis, `⟪g,h⟫ = GL(n,q)`.

This is the right level of ambition because Aschbacher’s theorem is a classification theorem, but what computational group theory needs is a **recognition-by-obstruction theorem**.

---

## Core theorem targets

You must prove at least 3 substantial theorems, and they must not be shallow decidability wrappers. At least one must use multi-step `calc`, at least one must use contradiction or structural decomposition (`by_contra`, `rcases`), and at least one must use induction or a nontrivial recursive argument over dimension / decomposition data.

### New definitions you should introduce

You need at least one genuinely new definition absent from the current catalog. I recommend introducing the following.

```lean
/-- A certificate predicate excluding containment in an Aschbacher class. -/
structure AschbacherCertificate
    (n : Type) [Fintype n] [DecidableEq n]
    (F : Type) [Field F] where
  cert : Matrix n n F → Matrix n n F → Prop
  sound :
    ∀ {g h : Matrix n n F}, ¬ IsInAschbacherClass certClass ⟪g, h⟫
  polytime_checkable : Prop
```

This is schematic; you will likely want a finite index type for the eight classes and a separate semantic predicate
`IsInAschbacherClass : AschbacherClass → MatrixGroup → Prop`.

A more immediately useful mathematical definition is:

```lean
/-- A pair `(g,h)` is certificate-complete if it passes every class-exclusion certificate. -/
def CertificateComplete
    {n : Type} [Fintype n] [DecidableEq n]
    {F : Type} [Field F]
    (C : AschbacherClass → Matrix n n F → Matrix n n F → Prop)
    (g h : Matrix n n F) : Prop :=
  ∀ c : AschbacherClass, C c g h
```

And for the extension-field and tensor-product classes, define explicit witness-free obstruction predicates such as:

```lean
/-- `g` has no proper extension-field model if its minimal polynomial degree
    is incompatible with any proper divisor of `n`. -/
def ExcludesExtensionFieldClass
    {n : ℕ} {F : Type} [Field F]
    (g : Matrix (Fin n) (Fin n) F) : Prop := 
  ∀ d : ℕ, d ∣ n → 1 < d → d < n →
    ¬ CompatibleWithExtensionFieldDegree g d
```

```lean
/-- A spectral obstruction to tensor-induced structure:
    eigenvalue ratios fail the multiplicative rank constraints forced by tensor decompositions. -/
def ExcludesTensorProductClass
    {n : ℕ} {F : Type} [Field F]
    (g h : Matrix (Fin n) (Fin n) F) : Prop := 
  ¬ HasTensorProductSpectralPattern g h
```

These are not merely implementation devices; they encode the research contribution: replacing existential subgroup geometry by explicit invariants.

---

## Precise theorem statements with Lean 4 targets

Below are theorem statements you should aim to formalize. The exact typeclasses may need adjustment depending on the matrix-group API in Mathlib, but the mathematical content should remain unchanged.

### Theorem 1: Certificate completeness excludes reducible and imprimitive containment

This theorem should combine catalog results for `C₁` and partial `C₂` into a stronger pair-level exclusion theorem.

**Mathematical statement.**  
Let `G = ⟪g,h⟫ ≤ GL(V)` over `𝔽_q`. If the characteristic polynomial of `g` is irreducible of degree `n` and no nontrivial block-system compatibility condition holds simultaneously for `g` and `h`, then `G` is neither reducible nor imprimitive.

**Lean target.**
```lean
theorem irreducible_charpoly_and_block_obstruction_exclude_C1_C2
    {q n : ℕ}
    (F : Type) [Field F] [Fintype F]
    [DecidableEq (Fin n)]
    (g h : Matrix (Fin n) (Fin n) F)
    (hg_inv : IsUnit g.det)
    (hh_inv : IsUnit h.det)
    (hirr : Irreducible (charpoly g))
    (hblock : BlockSystemObstructed g h) :
    ¬ IsInAschbacherClass AschbacherClass.C1 (MatrixGroup.closure ({g, h} : Set (Matrix (Fin n) (Fin n) F))) ∧
    ¬ IsInAschbacherClass AschbacherClass.C2 (MatrixGroup.closure ({g, h} : Set (Matrix (Fin n) (Fin n) F))) := by
  ...
```

**Why this matters.**  
This upgrades isolated irreducibility tests into a compositional recognition principle. It is the first nontrivial step from subgroup classification toward certificate logic.

---

### Theorem 2: Minimal-polynomial degree obstruction excludes extension-field subgroups (`C₃`)

**Mathematical statement.**  
Suppose `n > 1`. If `g ∈ GL(n,q)` has minimal polynomial degree `n`, and `n` admits no proper divisor `d` compatible with a semilinear extension-field realization of `⟪g,h⟫`, then `⟪g,h⟫` is not contained in any class `C₃` subgroup.

The key insight is that extension-field subgroups force the representation to descend to dimension `n/d` over `𝔽_{q^d}`. This imposes rigid divisibility constraints on the degree of the minimal polynomial when viewed over the base field.

**Lean target.**
```lean
theorem minpoly_degree_excludes_extension_field_class
    {q n : ℕ}
    (F : Type) [Field F] [Fintype F]
    [DecidableEq (Fin n)]
    (g h : Matrix (Fin n) (Fin n) F)
    (hg_inv : IsUnit g.det)
    (hh_inv : IsUnit h.det)
    (hdeg : MatrixMinpolyDegree g = n)
    (hext : ExcludesExtensionFieldClass g) :
    ¬ IsInAschbacherClass AschbacherClass.C3
      (MatrixGroup.closure ({g, h} : Set (Matrix (Fin n) (Fin n) F))) := by
  ...
```

**Proof architecture.**
1. Assume by contradiction containment in a `C₃` subgroup.
2. `rcases` the extension-field structure to obtain a proper divisor `d ∣ n` and a model over `𝔽_{q^d}`.
3. Derive a degree bound or divisibility constraint on `MatrixMinpolyDegree g`.
4. Contradict `hdeg = n` together with `hext`.

This theorem is conceptually central because `C₃` is the first genuinely semilinear obstruction class; solving it means the certificate framework is not just about invariant subspaces.

---

### Theorem 3: Tensor-factor spectral obstruction excludes tensor product class (`C₄`)

**Mathematical statement.**  
If `g` and `h` preserve no spectral multiplicative pattern compatible with a nontrivial tensor decomposition `V ≅ V₁ ⊗ V₂`, then `⟪g,h⟫` is not contained in a class `C₄` subgroup.

In tensor-product subgroups, eigenvalues of pure tensors factor multiplicatively. Therefore traces, determinant profiles, and eigenvalue-ratio sets satisfy algebraic identities absent in generic pairs.

**Lean target.**
```lean
theorem spectral_obstruction_excludes_tensor_product_class
    {q a b : ℕ}
    (F : Type) [Field F] [Fintype F]
    [DecidableEq (Fin (a*b))]
    (g h : Matrix (Fin (a*b)) (Fin (a*b)) F)
    (ha : 1 < a) (hb : 1 < b)
    (hobs : ExcludesTensorProductClass g h) :
    ¬ IsInAschbacherClass AschbacherClass.C4
      (MatrixGroup.closure ({g, h} : Set (Matrix (Fin (a*b)) (Fin (a*b)) F))) := by
  ...
```

**Most promising proof path.**
- Formalize a necessary condition for tensor-product containment: if `g = g₁ ⊗ g₂`, then the multiset of eigenvalues of `g` is pairwise multiplicative from those of the factors.
- Show that your obstruction predicate negates this necessary condition.
- Use `by_contra` and `rcases` on the tensor decomposition witness.

If full eigenvalue formalization over finite fields becomes too heavy, use trace identities or rank-one commutator constraints as a surrogate certificate. A weaker but formalizable invariant is still valuable if it is mathematically honest and computationally testable.

---

### Theorem 4: Global certificate completeness implies large generation

This is the flagship theorem.

**Mathematical statement.**  
Let `G = ⟪g,h⟫ ≤ GL(n,q)` with `n ≥ 3`. Assume `G` satisfies all class-exclusion certificates `C₁`–`C₈`, and assume `G` is not one of the finitely many almost simple exceptional subgroups outside the geometric Aschbacher families. Then `SL(n,q) ≤ G`; if moreover the determinants of `g,h` generate `𝔽_qˣ`, then `G = GL(n,q)`.

**Lean target.**
```lean
theorem certificate_complete_implies_large_generation
    {q n : ℕ}
    (F : Type) [Field F] [Fintype F]
    [DecidableEq (Fin n)]
    (g h : Matrix (Fin n) (Fin n) F)
    (hn : 3 ≤ n)
    (hcert : CertificateComplete AschbacherCert g h)
    (hexcept : ¬ IsExceptionalAlmostSimple
      (MatrixGroup.closure ({g, h} : Set (Matrix (Fin n) (Fin n) F))))
    (hdet : DeterminantSurjectivePair g h) :
    Matrix.SpecialLinearGroup (Fin n) F ≤
      MatrixGroup.closure ({g, h} : Set (Matrix (Fin n) (Fin n) F)) ∧
    MatrixGroup.closure ({g, h} : Set (Matrix (Fin n) (Fin n) F)) =
      Matrix.GeneralLinearGroup (Fin n) F := by
  ...
```

You may need to split this into two theorems:
1. certificate completeness excludes all geometric maximal subgroups;
2. then invoke an Aschbacher-style maximal subgroup theorem already encoded or partially formalized.

If the full exceptional subgroup theorem is out of reach, prove a dimension-specific version for `n = 3, 4`. That is still a major advance if the certificates are genuinely uniform and algorithmic.

---

## Proof strategy options

You must include 2–3 strategy pathways in your work and explicitly choose one as primary.

### Strategy A: Direct Aschbacher-by-class obstruction synthesis
For each class `Cᵢ`, define a necessary invariant pattern and prove:
`IsInAschbacherClass Cᵢ G → ¬ CertCᵢ g h`.

- **Step 1:** Reuse catalog results for `C₁` and partial `C₂`.
- **Step 2:** Introduce new obstruction predicates for `C₃` and `C₄`, ideally via minimal polynomial degree and tensor spectral constraints.
- **Step 3:** Build a theorem assembling all classwise exclusions into a global noncontainment result.

**Why promising:** This mirrors the structure of Aschbacher’s theorem and is modular. It gives immediate computational semantics.

### Strategy B: Primitive irreducible large-order criterion
Instead of excluding each class independently, prove a meta-theorem:
irreducible + primitive + presence of an element with “generic” arithmetic data forces large generation.

- **Step 1:** Show your certificates imply irreducibility and primitivity.
- **Step 2:** Prove that an element with sufficiently large minimal polynomial degree / order excludes semilinear and tensor classes simultaneously.
- **Step 3:** Use a large-subgroup theorem to conclude `SL(n,q) ≤ G`.

**Why promising:** Fewer separate definitions; more conceptual.  
**Why risky:** Requires a strong finite-group theorem formalization.

### Strategy C: Dimension-specific complete certification for `GL(3,q)` and `GL(4,q)`
Prove a full certificate-completeness theorem for small dimensions first, then extract the pattern.

- **Step 1:** Enumerate the Aschbacher classes that actually occur in dimensions 3 and 4.
- **Step 2:** For each occurring class, define explicit polynomial-time tests.
- **Step 3:** Prove a complete recognition theorem for those dimensions and backfill the general abstractions.

**Why promising:** Most feasible path to a complete theorem in Lean this cycle.  
**Best recommendation:** **Use Strategy C as the execution path and Strategy A as the architectural framing.** This gives a theorem that is complete, testable, and mathematically significant, while laying the groundwork for full generality.

---

## How to build on catalog theorems

Use the catalog references as actual load-bearing lemmas, not decorative citations.

- From `Catalog/Algebra/MatrixGroupGeneration.lean`, use  
  `eq_bot_or_top_of_charpoly_irreducible`  
  as the seed for your `C₁` certificate. Explain explicitly that irreducible characteristic polynomial rules out proper invariant subspaces and therefore excludes reducible maximal subgroups.

- From `Pythagorean/CertificateComplexity.lean`, use  
  `irreducible_charpoly_excludes_invariant_direct_summand`  
  as a partial `C₂` obstruction. Then strengthen it by defining a block-system obstruction predicate for imprimitive actions. The conceptual move is:
  **replace “no invariant direct summand” by “no invariant block decomposition.”**

- If available in Mathlib, exploit:
  - facts on `minpoly`, `charpoly`, and divisibility of degrees;
  - tensor product linear algebra;
  - subgroup closure and generation APIs;
  - determinant and special linear group lemmas.

You should also search for any existing formalization of:
- irreducible modules,
- semilinear actions,
- tensor decompositions of finite-dimensional spaces,
- finite field extension degree lemmas.

If semilinear structure is not formalized enough, define a weaker but rigorous certificate based on degree/divisibility of characteristic or minimal polynomials. The theorem can still be groundbreaking if it isolates a genuine obstruction class.

---

## Cross-domain connections you must include

At least one theorem must explicitly connect this project to another domain.

### Cross-domain theorem option 1: Complexity-theoretic soundness
Prove that each certificate predicate is invariant under conjugation and computable from polynomially many field operations. Then state a theorem linking the mathematical certificate to algorithmic complexity.

```lean
theorem certificate_check_polynomial_invariant
    {n q : ℕ} ... :
    ConjugacyInvariant (AschbacherCert c) ∧ PolynomialTimeCheckable (AschbacherCert c) := by
  ...
```

This connects **finite group theory + computational complexity**.

### Cross-domain theorem option 2: Spectral graph / expander connection
For pairs `(g,h)` passing all certificates, define the Cayley graph on `GL(n,q)` generated by `{g,h,g⁻¹,h⁻¹}` and prove a preliminary structural theorem: certificate-complete pairs generate non-bipartite, connected Cayley graphs, or satisfy a lower bound on orbit growth in projective space. This connects **group recognition + combinatorics / expander theory**.

### Cross-domain theorem option 3: Cryptographic relevance
Formalize that if a protocol assumes hardness of distinguishing generating from nongenerating pairs in matrix groups, then certificate-complete pairs are efficiently recognizable as “large.” This connects **group theory + cryptography**. Even a theorem about deterministic rejection of structured trapdoor subgroups would be valuable.

Recommended keywords to surface in your paper and code:
**computational group theory, finite classical groups, Aschbacher classification, polynomial-time recognition, matrix group generation, subgroup certificates, minimal polynomial, tensor decomposition, semilinear groups, Cayley graphs, cryptography, representation theory, complexity theory.**

---

## Conjecture with testable prediction

You must state a falsifiable conjecture and implement a computational test capable of disproving it.

### Primary conjecture
> **Conjecture (Certificate Completeness for Small Dimensions).**  
> For `n = 3,4` and every finite field `𝔽_q` with `q ≤ 100`, there exist explicit certificate predicates `CertC₁, …, CertC₈` such that for every invertible pair `(g,h)`, if all certificates hold then `⟪g,h⟫ ⊇ SL(n,q)`.

### Testable prediction
For random pairs `(g,h)` in `GL(3,q)` and `GL(4,q)`, the conjunction of the certificates will agree with exact subgroup generation on a density tending rapidly to 1 as `q` grows, while every hand-constructed pair lying in a known Aschbacher maximal subgroup fails at least one certificate.

### Possible disproof mode
A single explicit family of pairs contained in a `Cᵢ` subgroup but passing your `CertCᵢ` falsifies soundness.  
A single family of pairs passing all certificates but not generating a large subgroup falsifies completeness.

This is excellent science because it is mathematically sharp and computationally falsifiable.

---

## Concrete implementation agenda

1. **Create a new Lean file** centered on certificate definitions and soundness theorems, likely something like:
   - `Aschbacher/CertificateTheory.lean`
   - and, if needed, `Aschbacher/CertificateExamples.lean`

2. **Formalize the eight classes as an index type** even if not all semantic content is completed uniformly:
```lean
inductive AschbacherClass
| C1 | C2 | C3 | C4 | C5 | C6 | C7 | C8
deriving DecidableEq, Fintype
```

3. **Define explicit certificate predicates** for at least `C₁`–`C₄`, with placeholders or conjectural interfaces for `C₅`–`C₈` only if mathematically honest. But do not hide missing mathematics behind trivial defs.

4. **Prove at least 3 deep theorems**:
   - one combining `C₁` and `C₂`,
   - one excluding `C₃`,
   - one cross-domain theorem on polynomial-time checkability or conjugacy invariance.

5. **Implement computational verification** for `GL(3,q)` and `GL(4,q)` with `q ≤ 100` where feasible:
   - explicit subgroup examples for each occurring class,
   - random pair tests,
   - logging of certificate failures and successes.

6. **Minimize sorry aggressively.**  
   If one theorem remains partially blocked by library gaps, isolate the gap into a named lemma with exact mathematical content and prove all surrounding infrastructure.

---

## Deliverables you must produce

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. Each direction must include the exact phrases:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, for example:
- Aschbacher certificates and black-box group recognition,
- certificate completeness and expander constructions,
- subgroup certificates and post-quantum cryptographic auditing.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. A reader with no code access must understand:
- the precise problem,
- the theorem statements,
- the new certificate definitions,
- the proof ideas,
- the computational experiments,
- why this changes the landscape of matrix group recognition,
- what comes next.

This paper should emphasize the shift from subgroup enumeration to obstruction-based certification.

### 3. `ARTICLE.md`
Write this in **Scientific American** style. It must be engaging and broad-audience.  
**Taboo:** do not focus on formal verification machinery. Focus on the mathematics, the algorithmic leap, and why recognizing hidden symmetry structures quickly matters.

### 4. A verified algorithm or computational method
Not just theorem statements. You must implement a real certificate-checking pipeline:
- input: pair `(g,h)` in `GL(n,q)`,
- output: which Aschbacher certificates pass/fail,
- plus a verdict: “certified large” / “obstructed by class `Cᵢ`” / “undetermined”.

### 5. `demo.py`
An interactive demonstration that:
- constructs sample pairs in `GL(3,q)` and `GL(4,q)`,
- tests all available certificates,
- shows examples from known Aschbacher classes,
- highlights a pair that passes all implemented certificates,
- prints interpretable diagnostics.

---

## Final scientific objective

Do not merely formalize isolated lemmas. Build the first rigorous **certificate architecture for Aschbacher exclusion**. The breakthrough is not “one more theorem about matrix groups.” The breakthrough is a new paradigm:

**large subgroup recognition by explicit, local, polynomial-time obstructions.**

If you can make this work even completely for `GL(3,q)` and `GL(4,q)`, with convincing abstractions for higher dimension, you will have opened a field-sized door.

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
