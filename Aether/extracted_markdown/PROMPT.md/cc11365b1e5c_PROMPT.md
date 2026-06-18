Soli Deo Gloria

## Mode: prove

## Assignment: EML Algebraic Independence and Certified Transcendence Proxies

You should **not** aim to formalize the full transcendence-theory conjecture directly, because the stated “n=1 follows from Lindemann–Weierstrass + Gelfond–Schneider” is mathematically too optimistic in full generality and likely not available in Mathlib in a form strong enough to discharge the claim. Instead, turn this into a **field-opening formal program**: isolate a rigorously formalizable algebraic framework for EML-type expressions, prove structural no-go theorems for algebraic collapse, and build a verified computational search for polynomial relations that yields falsifiable evidence for or against the EML-Schanuel specialization.

The breakthrough is to create the first Lean-certified **algebraic-independence proxy theory** for expressions of the form
\[
\mathrm{EML}(a) := \exp(a)\,\log(1+a),
\]
showing that many classes of polynomial/algebraic relations are impossible for structural reasons, and reducing genuine transcendence questions to finite certificates or symbolic normal forms. This opens a new interface between **transcendence theory, symbolic algebra, analytic inequalities, and computational number theory**.

## Core Vision

Define a formal EML expression language and prove theorems showing that if an algebraic relation among EML values exists, then it must descend to a sharply constrained relation among exponentials and logarithms separately. This does **not** solve Schanuel, but it creates a new certified reduction theory. The conceptual leap is:

- not “prove transcendence from unavailable deep theorems,”
- but “prove that any counterexample must have a rigid algebraic skeleton,”
- and accompany this with a verified algorithm that searches for low-degree polynomial relations and returns certificates of non-existence within a bounded class.

This is the right kind of theorem for Lean 4 + Mathlib: deep, structural, extensible, and scientifically useful.

---

## Precise theorem targets

You must produce at least **3 substantial theorems** with multi-step proofs. At least one theorem must connect to a different domain.

### New definitions to introduce

You must define at least one genuinely new concept. Suggested definitions:

```lean
/-- The basic EML operator on a field/normed algebra where `exp` and `log` make sense. -/
def eml (z : ℂ) : ℂ := Complex.exp z * Complex.log (1 + z)

/-- A bounded-degree polynomial relation certificate for a tuple of complex numbers. -/
def HasPolyRel (d : ℕ) (v : Fin n → ℂ) : Prop :=
  ∃ P : MvPolynomial (Fin n) ℚ, P.totalDegree ≤ d ∧ aeval v P = 0 ∧ P ≠ 0

/-- A structural separation property saying that an EML relation factors through
    independent exponential and logarithmic monomials only trivially. -/
def EMLSeparated (s : Fin n → ℂ) : Prop :=
  ∀ P : MvPolynomial (Fin n) ℚ,
    aeval (fun i => eml (s i)) P = 0 →
    P = 0

/-- A finite-search witness that no polynomial relation of degree ≤ d exists. -/
def NoPolyRelUpTo (d : ℕ) (v : Fin n → ℂ) : Prop :=
  ∀ P : MvPolynomial (Fin n) ℚ, P.totalDegree ≤ d → aeval v P = 0 → P = 0
```

You may adjust exact signatures to match available Mathlib APIs, but preserve the mathematical content.

---

## Theorem 1: Degree-1 rigidity for EML values

This is the minimal nontrivial structural theorem and should be fully formalizable.

### Mathematical statement
For complex numbers \(z_1,\dots,z_n\), if the values \(\exp(z_i)\) are pairwise distinct and each \(\log(1+z_i)\neq 0\), then no nontrivial **degree-1** rational relation among \(\mathrm{EML}(z_i)\) can arise from coefficient separation unless the corresponding weighted exponential/logarithmic combination already vanishes.

A more formal and certifiable version:

\[
\left(\sum_{i=1}^n q_i \exp(z_i)\log(1+z_i)=0\right)
\Longrightarrow
\text{a constrained linear relation between the exponential-log factors.}
\]

In Lean, target a theorem that gives a usable reduction lemma, e.g.

```lean
theorem eml_linear_relation_restricts
    {n : ℕ} {z : Fin n → ℂ} {q : Fin n → ℚ}
    (hz : ∀ i, z i ≠ -1)
    (hlin : ∑ i, (q i : ℂ) * eml (z i) = 0) :
    ∑ i, (q i : ℂ) * Complex.exp (z i) * Complex.log (1 + z i) = 0
```

This first statement is tautological if written this way, so you must strengthen it into a genuinely informative theorem. One good target is to package coefficients by equal logarithmic values or equal exponential values and prove a regrouping identity that forces cancellation to occur only inside collision classes:

```lean
theorem eml_linear_relation_partition
    {n : ℕ} {z : Fin n → ℂ} {q : Fin n → ℚ}
    (hz : ∀ i, z i ≠ -1) :
    ∑ i, (q i : ℂ) * eml (z i)
      =
    ∑ L in (Finset.univ.image (fun i => Complex.log (1 + z i))),
      L * (∑ i in Finset.univ.filter (fun i => Complex.log (1 + z i) = L),
            (q i : ℂ) * Complex.exp (z i))
```

This is a real theorem: a decomposition principle for linear EML relations. It becomes the basis for later no-go criteria.

### Why this matters
It creates the first formal **separation-of-variables** theorem for EML expressions. This is the algebraic backbone needed before any transcendence argument can even be stated precisely.

---

## Theorem 2: Polynomial relation reduction to monomial support constraints

### Mathematical statement
Let \(v_i = \exp(a_i)\log(1+a_i)\). Any polynomial relation
\[
P(v_1,\dots,v_n)=0
\]
expands into a finite sum of terms
\[
c_m \exp\!\left(\sum_i m_i a_i\right)\prod_i \log(1+a_i)^{m_i}.
\]
Prove formally that the support of this expansion is controlled by the monomial support of \(P\), and that bounded-degree relation search reduces to finite support checking.

This is not transcendence, but it is the exact reduction needed for certified computation.

### Lean 4 target
Define a support-expansion map from multivariate polynomials to finite sums of “exp-log monomials” and prove correctness.

```lean
/-- Formal EML monomial associated to an exponent vector. -/
def emlMonomial {n : ℕ} (a : Fin n → ℂ) (m : Fin n → ℕ) : ℂ :=
  Complex.exp (∑ i, (m i : ℂ) * a i) *
    ∏ i, (Complex.log (1 + a i)) ^ (m i)

/-- Expansion of a polynomial in EML variables into exp-log monomials. -/
def expandEML {n : ℕ} (a : Fin n → ℂ) :
    MvPolynomial (Fin n) ℚ → ℂ := fun P =>
  ∑ m in P.support, (P.coeff m : ℂ) * emlMonomial a m

theorem aeval_eml_eq_expandEML
    {n : ℕ} (a : Fin n → ℂ) :
    ∀ P : MvPolynomial (Fin n) ℚ,
      aeval (fun i => eml (a i)) P = expandEML a P
```

This theorem is deep enough because it will require:
- induction on polynomials,
- careful handling of support,
- multi-step `calc`,
- interaction of `aeval`, products, and exponent sums.

### Why this matters
This is the certified symbolic engine for EML transcendence heuristics. It converts a vague transcendence problem into a finite combinatorial object. That is a serious conceptual advance.

---

## Theorem 3: Cross-domain theorem — EML relation search as sparse phase-collision detection

You must include a theorem bridging to another domain. The strongest available cross-domain bridge is to **harmonic analysis / mathematical physics**: when \(a_i\) are purely imaginary, \(\exp(a_i)\) are unit complex phases, so EML relations become sparse interference sums.

### Mathematical statement
For \(a_i = i\theta_i\) with \(\theta_i \in \mathbb{R}\),
\[
\mathrm{EML}(i\theta_i) = e^{i\theta_i}\log(1+i\theta_i),
\]
and polynomial relations among these values induce finite trigonometric interference identities. Prove a formal norm bound:
\[
\left|\sum_i c_i\,\mathrm{EML}(i\theta_i)\right|
\le \sum_i |c_i|\,|\log(1+i\theta_i)|.
\]
This is elementary analytically, but conceptually important: it turns algebraic dependence search into a **phase-cancellation problem**.

### Lean 4 target

```lean
theorem norm_sum_eml_mul_I_le
    {n : ℕ} (θ : Fin n → ℝ) (c : Fin n → ℂ) :
    ‖∑ i, c i * eml (θ i * Complex.I)‖
      ≤ ∑ i, ‖c i‖ * ‖Complex.log (1 + θ i * Complex.I)‖
```

using `‖Complex.exp (θ i * Complex.I)‖ = 1`.

A stronger variant if available:

```lean
theorem norm_eml_mul_I
    (t : ℝ) :
    ‖eml (t * Complex.I)‖ = ‖Complex.log (1 + t * Complex.I)‖
```

### Why this matters
This links transcendence-inspired algebra to **wave interference, quantum phases, and sparse Fourier cancellation**. It opens a route to importing tools from analysis and signal processing into transcendence heuristics.

---

## Theorem 4: Certified nonexistence of low-degree relations from separation hypotheses

This is the most ambitious theorem and the one most likely to feel like a breakthrough.

### Mathematical statement
Assume a tuple \(a : \mathrm{Fin}\,n \to \mathbb{C}\) satisfies a finite separation property:
distinct monomials \(m \neq m'\) up to degree \(d\) yield distinct pairs
\[
\left(\sum_i m_i a_i,\; \prod_i \log(1+a_i)^{m_i}\right).
\]
Then there is no nonzero polynomial relation of degree \(\le d\) among \(\mathrm{EML}(a_i)\).

This is a **conditional algebraic independence criterion**, but crucially one that is finitely checkable and can be paired with a verified algorithm.

### Lean target
You may encode the separation hypothesis in any tractable form, e.g.

```lean
def EMLMonomialSeparatedUpTo (d : ℕ) (a : Fin n → ℂ) : Prop :=
  ∀ m m : Fin n → ℕ,
    (∑ i, m i) ≤ d →
    (∑ i, m' i) ≤ d →
    emlMonomial a m = emlMonomial a m' →
    m = m'

theorem no_poly_relation_of_separated
    {n d : ℕ} {a : Fin n → ℂ}
    (hsep : EMLMonomialSeparatedUpTo d a) :
    NoPolyRelUpTo d (fun i => eml (a i))
```

This is a genuine theorem: under a concrete combinatorial hypothesis, polynomial relations are impossible.

### Why this matters
This is the exact formal analog of “algebraic independence by monomial separation,” and it yields a practical certificate-producing method. It is a new theorem schema with computational content.

---

## Correcting the original conjectural framing

You should explicitly state in `RESEARCH_PAPER.md` that the original claim

> “for algebraic \(a \neq 0\), \(\exp(a)\log(1+a)\) is transcendental, following from Lindemann–Weierstrass and Gelfond–Schneider”

is **not** something to treat as settled in this project without a precise theorem chain. The product of transcendental numbers need not be transcendental, and the interaction with \(\log(1+a)\) is subtle. This is not a weakness; it is the opening. Your formal work should sharpen the conjecture into mathematically responsible statements.

A refined conjecture to state:

### EML-Schanuel Conjecture
Let \(a_1,\dots,a_n \in \overline{\mathbb{Q}}\setminus\{-1\}\) be linearly independent over \(\mathbb{Q}\). Then
\[
\mathrm{trdeg}_{\mathbb{Q}}
\mathbb{Q}\big(\exp(a_1)\log(1+a_1),\dots,\exp(a_n)\log(1+a_n)\big) = n.
\]

You will not prove this. You will build the first formal reduction framework and bounded-degree evidence engine around it.

---

## Proof strategy architecture

You must present at least 2–3 proof paths and choose the most promising.

### Strategy A: Polynomial expansion and monomial support control
1. Define `eml`, `emlMonomial`, `expandEML`, and bounded relation predicates.
2. Prove `aeval_eml_eq_expandEML` by induction on `MvPolynomial`, with key lemmas for monomials and multiplication.
3. Deduce `no_poly_relation_of_separated` from uniqueness of monomial support under the separation hypothesis.

**Why promising:** This is the cleanest route in Lean. It uses algebraic combinatorics and Mathlib’s polynomial APIs rather than unavailable transcendence libraries.

### Strategy B: Linear relation partition via logarithmic collision classes
1. For linear combinations, partition indices by equal `Complex.log (1 + z i)`.
2. Rewrite the sum as a sum over collision classes.
3. Prove that cancellation must occur within classes, yielding structural rigidity.

**Why promising:** Good for a first theorem and gives conceptual clarity. It may be easier than full polynomial support arguments and provides useful intermediate lemmas.

### Strategy C: Analytic norm inequalities for imaginary inputs
1. Specialize to `z = t * I`.
2. Use `‖Complex.exp (t * I)‖ = 1`.
3. Derive triangle-inequality bounds for linear and polynomial EML sums.

**Why promising:** This supplies the cross-domain bridge and a verified computational filter: any candidate polynomial relation violating the norm lower bound is impossible.

**Most promising overall:** Strategy A, supported by B and C. Strategy A yields the strongest formal artifact: a reduction engine and no-relation certificate theorem.

---

## Lean 4 implementation notes

You should likely work with:
- `Complex.exp`, `Complex.log`
- `MvPolynomial`
- `aeval`
- `Finset` sums/products
- coefficient/support lemmas
- norm inequalities on `ℂ`

Potential theorem signatures to aim for:

```lean
def eml (z : ℂ) : ℂ := Complex.exp z * Complex.log (1 + z)

def emlMonomial {n : ℕ} (a : Fin n → ℂ) (m : Fin n → ℕ) : ℂ :=
  Complex.exp (∑ i, (m i : ℂ) * a i) *
    ∏ i, (Complex.log (1 + a i)) ^ (m i)

def expandEML {n : ℕ} (a : Fin n → ℂ) (P : MvPolynomial (Fin n) ℚ) : ℂ :=
  ∑ m in P.support, (P.coeff m : ℂ) * emlMonomial a m

theorem aeval_eml_eq_expandEML
    {n : ℕ} (a : Fin n → ℂ) (P : MvPolynomial (Fin n) ℚ) :
    aeval (fun i => eml (a i)) P = expandEML a P
```

```lean
def NoPolyRelUpTo {n : ℕ} (d : ℕ) (v : Fin n → ℂ) : Prop :=
  ∀ P : MvPolynomial (Fin n) ℚ, P.totalDegree ≤ d → aeval v P = 0 → P = 0

def EMLMonomialSeparatedUpTo {n : ℕ} (d : ℕ) (a : Fin n → ℂ) : Prop :=
  ∀ m m' : Fin n → ℕ,
    m ∈ (Finset.univ.pi fun _ => Finset.range (d + 1)) →
    m' ∈ (Finset.univ.pi fun _ => Finset.range (d + 1)) →
    emlMonomial a m = emlMonomial a m' →
    m = m'

theorem no_poly_relation_of_separated
    {n d : ℕ} {a : Fin n → ℂ}
    (hsep : EMLMonomialSeparatedUpTo d a) :
    NoPolyRelUpTo d (fun i => eml (a i))
```

```lean
theorem norm_eml_mul_I (t : ℝ) :
    ‖eml (t * Complex.I)‖ = ‖Complex.log (1 + t * Complex.I)‖
```

```lean
theorem norm_sum_eml_mul_I_le
    {n : ℕ} (θ : Fin n → ℝ) (c : Fin n → ℂ) :
    ‖∑ i, c i * eml (θ i * Complex.I)‖
      ≤ ∑ i, ‖c i‖ * ‖Complex.log (1 + θ i * Complex.I)‖
```

Do not settle for trivial rewrites. Ensure at least 3 proofs genuinely use:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp` where relevant,
- multi-step `calc`.

---

## Computational method requirement

You must deliver a **verified algorithm**, not just theorems.

### Required algorithm
Implement a bounded-degree search for polynomial relations among finitely many approximate EML values.

Suggested structure:
1. Enumerate all monomials in \(n\) variables up to degree \(d\).
2. Evaluate the corresponding `emlMonomial` numerically.
3. Search for approximate linear dependencies over rationals with bounded coefficients.
4. Return either:
   - a candidate polynomial relation, or
   - a certificate that no relation exists within the prescribed search bounds.

This should be accompanied by a theorem proving that if the algorithm returns a certified “no relation” under exact separation hypotheses, then `NoPolyRelUpTo d ...` holds.

### demo.py
The demo must:
- let the user choose sample tuples such as `[(√2), (√3)]` approximated numerically,
- choose degree and coefficient bounds,
- display candidate polynomial relations or a “none found” certificate,
- visualize monomial phase separation for imaginary inputs.

This is not decorative. It is the experimental arm of the project.

---

## Conjecture with testable prediction

State at least one falsifiable conjecture and make it computational.

### Suggested conjecture
For \(a_1 = \sqrt{2}\), \(a_2 = \sqrt{3}\), there is no nonzero polynomial
\[
P \in \mathbb{Z}[X,Y]
\]
of total degree \(\le 4\) and coefficients of absolute value \(\le 20\) such that
\[
P(\mathrm{EML}(a_1), \mathrm{EML}(a_2)) = 0.
\]

Formalize a bounded version as a decidable search statement and test it computationally.

A second, cross-domain conjecture:
For distinct nonzero real \(\theta_1,\dots,\theta_n\), the values
\[
\mathrm{EML}(i\theta_j)
\]
exhibit generic bounded-degree monomial separation, so low-degree polynomial relations are absent except on a thin resonance set.

This is falsifiable by searching for collisions in `emlMonomial`.

---

## Cross-domain connections to emphasize

You must explicitly develop at least one of these in the writeup and theorem statements:

- **Transcendence theory ↔ symbolic algebra**: polynomial relation reduction via `MvPolynomial`.
- **Transcendence theory ↔ harmonic analysis**: imaginary inputs turn exponentials into phases.
- **Transcendence theory ↔ quantum/wave interference**: cancellation among EML values becomes a phase-collision phenomenon.
- **Transcendence theory ↔ computational number theory**: bounded-degree search for algebraic relations.
- **Transcendence theory ↔ period heuristics**: EML values resemble mixed exponential-logarithmic periods.

---

## Application keywords

Include these keywords in the paper and article:
**transcendence theory, algebraic independence, Schanuel conjecture, exponential-logarithmic values, symbolic computation, sparse polynomial relations, harmonic analysis, phase cancellation, certified algorithms, special values, period heuristics**

---

## Deliverables (ALL mandatory)

1. **Lean file(s)** with at least 3 substantial theorems and minimal sorry usage.
2. **A new definition** such as `EMLMonomialSeparatedUpTo`, `NoPolyRelUpTo`, or `expandEML`.
3. **A verified algorithm or computational method** for bounded-degree relation search.
4. **demo.py** demonstrating the search and/or phase-separation visualization.
5. **RESEARCH_PAPER.md** as a standalone scientific document:
   - define EML values,
   - explain the refined conjecture,
   - state and interpret the formal theorems,
   - explain why the original naive n=1 claim is subtle,
   - present the computational evidence program.
6. **ARTICLE.md** in Scientific American style:
   - explain the idea of hidden algebraic relations among exotic numbers,
   - describe EML as a new hybrid exponential-logarithmic object,
   - discuss significance and future possibilities,
   - **do not focus on verification machinery**.
7. **FUTURE_DIRECTIONS.md** with 3–5 original directions, each including:
   - “The key insight is...”
   - “Why now?”
   At least one direction must bridge to a different domain.

---

## Standard of ambition

Do not write a small library about `Complex.exp`. Build a **new formal language for EML algebraic dependence**. The result should make a mathematician say:

> “This doesn’t prove Schanuel — it does something more surprising: it builds a rigorous reduction-and-search theory for a transcendence problem that previously lived only as folklore intuition.”

That is the bar.

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

Research domain: EML
Research mode: prove
