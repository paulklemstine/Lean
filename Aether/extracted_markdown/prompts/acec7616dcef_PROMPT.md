Soli Deo Gloria

## Assignment: Direction 2: \(p\)-Adic Tropical Witnesses and Arithmetic Invariants

**Mode:** `prove`

Prove genuinely new theorems at the interface of tropical geometry, arithmetic geometry, and spectral/combinatorial invariants. Do **not** settle for a mere reformulation of existing tropical support lemmas with \(p\)-adic notation attached. The goal is to create the first formal bridge between **non-archimedean coefficient complexity** and **spectral witness size** for rational polynomials arising from DPP/Lorentzian structures.

Build explicitly on:

- `Pythagorean/TropicalLeafWitnesses/Defs.lean`
  - especially `tropCoeff`, `tropSupport`
- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean`
  - especially `dppPartitionFunction`

Your task is to introduce a **new arithmetic tropical witness theory** and prove at least 3 nontrivial theorems with real proof structure: induction, `rcases`, `by_contra`, `field_simp`, nontrivial `calc`, valuation inequalities, support decompositions, or coefficient-factorization arguments.

## Core Vision

Archimedean tropicalization sees coefficient size through \(\log |c_\alpha|\). But this erases arithmetic structure: cancellation, denominator growth, and prime-specific concentration phenomena are invisible. The conjectural breakthrough is that **primewise tropical complexity controls spectral complexity**. If true even in a weak, explicit form, this opens a new field: **arithmetic tropical witnesses**, where spectral observables are bounded by tropicalized valuation profiles over all places.

This is not an incremental variant. It would connect:

- **number theory**: \(p\)-adic valuations, denominator structure, product formula heuristics
- **tropical geometry**: supports, coefficient witnesses, non-archimedean tropicalization
- **spectral/combinatorial theory**: witness size, partition functions, Lorentzian/DPP observables
- **Berkovich/arithmetic geometry**: placewise geometry of polynomials
- **algorithmic mathematics**: computable prime-sensitive complexity bounds

Application keywords: **\(p\)-adic valuation, tropicalization, Berkovich geometry, arithmetic complexity, spectral witness, DPP polynomials, Lorentzian polynomials, denominator growth, product formula, non-archimedean geometry**

---

## New Definitions You Must Introduce

You must define at least one genuinely new concept not already in the catalog. Recommended core definitions:

1. **Primewise tropical coefficient weight**
   \[
   \operatorname{padicCoeffWeight}(q,c) := \big|v_q(c)\big|
   \]
   for \(c \in \mathbb{Q}\), with a convention at \(c=0\) chosen carefully so the support handles zero coefficients separately.

2. **\(q\)-adic tropical support weight of a polynomial**
   \[
   W^{(q)}_{\mathrm{coeff}}(p) := \sum_{\alpha \in \mathrm{supp}(p)} |v_q(c_\alpha)|
   \]

3. **Arithmetic tropical witness on a finite subsystem**
   \[
   W_{\mathrm{trop}}^{(q)}(p,A) := \sum_{a \in A}\ \sum_{\alpha \in \mathrm{supp}(\partial_a^2 L_A)} |v_q(c_\alpha)|
   \]
   where the formalization may initially use an abstract finite family of derived polynomials attached to \(A\), if the full \(\partial_a^2L_A\) machinery is not yet available.

4. **Prime-aggregated witness**
   \[
   W_{\mathrm{trop}}^{\max}(p,A;S) := \max_{q \in S} W_{\mathrm{trop}}^{(q)}(p,A)
   \]
   for a finite prime set \(S\), enabling verified computation.

If full \(v_q : \mathbb{Q}\to\mathbb{Z}\) is awkward in the first pass, define a certified version based on multiplicity of \(q\) in numerator/denominator after normalization. But the end product should still state theorems in valuation language.

---

## Precise Formal Targets

You should aim for the following Lean-facing theorem shapes. Adapt names to local library conventions, but keep the mathematical content exact.

### Definition skeletons
```lean
def padicCoeffWeight (q : ℕ) (c : ℚ) : ℕ := ...
def padicTropSupportWeight (q : ℕ) (p : MvPolynomial σ ℚ) : ℕ := ...
def padicTropWitness (q : ℕ) (A : Finset ι) (F : ι → MvPolynomial σ ℚ) : ℕ := ...
def primeAggregatedWitness (S : Finset ℕ) (A : Finset ι) (F : ι → MvPolynomial σ ℚ) : ℕ := ...
```

Here `F a` can stand in for the polynomial playing the role of \(\partial_a^2 L_A\) if that operator is not yet formalized.

### Theorem 1: Additivity/subadditivity under multiplication
This is the first foundational theorem: arithmetic tropical complexity must behave predictably under polynomial multiplication.

Mathematical statement:
\[
W^{(q)}_{\mathrm{coeff}}(p r) \le W^{(q)}_{\mathrm{coeff}}(p) + W^{(q)}_{\mathrm{coeff}}(r) + E_q(p,r),
\]
where \(E_q(p,r)\) is an explicit collision/error term arising from support overlap; in a support-disjoint or unique-sum regime, the inequality sharpens to
\[
W^{(q)}_{\mathrm{coeff}}(p r) \le W^{(q)}_{\mathrm{coeff}}(p) + W^{(q)}_{\mathrm{coeff}}(r).
\]

Lean-style target:
```lean
theorem padicTropSupportWeight_mul_le
    (q : ℕ) [Fact q.Prime]
    (p r : MvPolynomial σ ℚ) :
    padicTropSupportWeight q (p * r) ≤
      padicTropSupportWeight q p + padicTropSupportWeight q r + collisionTerm q p r := ...
```

and ideally a sharpened theorem under a no-collision hypothesis:
```lean
theorem padicTropSupportWeight_mul_le_of_unique_support
    (q : ℕ) [Fact q.Prime]
    (p r : MvPolynomial σ ℚ)
    (hunique : UniqueSupportSums p r) :
    padicTropSupportWeight q (p * r) ≤
      padicTropSupportWeight q p + padicTropSupportWeight q r := ...
```

Why this matters: it gives arithmetic tropical witnesses the algebraic stability needed for any future structure theorem.

### Theorem 2: Denominator control via finite prime support
For a rational coefficient, only finitely many primes contribute to its valuation. Lift this coefficientwise to polynomials.

Mathematical statement:
For any finitely supported rational polynomial \(p\), there exists a finite set of primes \(S\) such that
\[
\forall q \notin S,\quad W^{(q)}_{\mathrm{coeff}}(p)=0.
\]
Equivalently, the arithmetic tropical profile is finitely supported in the prime direction.

Lean-style target:
```lean
theorem exists_finite_prime_support
    (p : MvPolynomial σ ℚ) :
    ∃ S : Finset ℕ, ∀ q : ℕ, Nat.Prime q → q ∉ S →
      padicTropSupportWeight q p = 0 := ...
```

This theorem is not cosmetic. It justifies all finite-prime computational experiments and shows that arithmetic tropical data are intrinsically finite for rational inputs.

### Theorem 3: Product-formula inequality for coefficient height
This is the conceptual heart. You likely cannot fully prove the final spectral conjecture immediately, but you can prove a coefficient-height theorem that makes it plausible.

For a nonzero rational \(c\), the product formula implies
\[
\log \max(\operatorname{num}(c),\operatorname{den}(c))
\le \sum_{q \in S(c)} |v_q(c)| \log q + C_0,
\]
for an explicit normalizing constant \(C_0\) depending on sign conventions and chosen height model. Summing over coefficients yields:
\[
H(p) \le \sum_q (\log q)\, W^{(q)}_{\mathrm{coeff}}(p) + C(p),
\]
for a suitable coefficient height \(H(p)\).

Lean-style target:
```lean
def coeffHeight (p : MvPolynomial σ ℚ) : ℝ := ...

theorem coeffHeight_le_weighted_padic_sum
    (p : MvPolynomial σ ℚ) :
    coeffHeight p ≤
      ∑ q in primeSupport p, (Real.log q) * (padicTropSupportWeight q p : ℝ) + heightError p := ...
```

If full weighted summation is too ambitious, prove first a max-prime version:
```lean
theorem coeffHeight_le_card_primeSupport_mul_max
    (p : MvPolynomial σ ℚ) :
    coeffHeight p ≤
      (primeSupport p).card * (↑(maxPadicWeight p)) * Real.log (maxPrimeSupport p) + heightError p := ...
```

This theorem is the arithmetic analogue of archimedean tropical coefficient control.

### Theorem 4: Witness monotonicity over subsystem inclusion
If \(A \subseteq B\), the witness should not decrease when the derived family is compatible.

Mathematical statement:
\[
A \subseteq B \implies W_{\mathrm{trop}}^{(q)}(p,A) \le W_{\mathrm{trop}}^{(q)}(p,B).
\]

Lean-style target:
```lean
theorem padicTropWitness_mono
    (q : ℕ) [Fact q.Prime]
    {A B : Finset ι} (hAB : A ⊆ B)
    (F : ι → MvPolynomial σ ℚ)
    (hcompat : WitnessCompatible A B F) :
    padicTropWitness q A F ≤ padicTropWitness q B F := ...
```

This gives the explicit subsystem constant \(C(A)\) a meaningful monotonic dependence and supports computational scaling laws.

### Theorem 5: Cross-domain theorem — arithmetic witness controls tropical complexity
You must include at least one theorem connecting to a different domain. The most promising bridge is from number theory to tropical geometry via support complexity.

Possible statement:
If all nonzero coefficients of \(p\) are \(q\)-adic units, then the \(q\)-adic tropical witness vanishes, hence the \(q\)-adic tropicalization of \(p\) is coefficient-flat.

Lean-style target:
```lean
theorem padic_units_imply_zero_witness
    (q : ℕ) [Fact q.Prime]
    (p : MvPolynomial σ ℚ)
    (hunit : ∀ d ∈ p.support, padicCoeffWeight q (p.coeff d) = 0) :
    padicTropSupportWeight q p = 0 := ...
```

Interpret this as: **unit coefficients define arithmetically invisible tropical strata**. This is a genuine bridge from arithmetic to tropical geometry.

---

## Main Conjectural Endgame

You should explicitly state, motivate, and computationally probe the following sharpened conjecture.

### Arithmetic Tropical Witness Conjecture
For a rational polynomial object \(p\) and finite subsystem \(A\), there exists an explicit constant \(C(A) > 0\) such that
\[
\log |W_{\mathrm{spec}}(p,A)| \le C(A)\cdot \max_{q \text{ prime}} W_{\mathrm{trop}}^{(q)}(p,A).
\]

Finite-prime testable version:
For a tested prime set \(S=\{2,3,5,7,11\}\),
\[
\log |W_{\mathrm{spec}}(p,A)| \le C(A)\cdot \max_{q\in S} W_{\mathrm{trop}}^{(q)}(p,A)
\]
should hold for broad classes of DPP/Lorentzian examples; a single robust counterexample where the left side is large and all tested prime witnesses are small should falsify the naive form.

You must include this as a formal conjecture in comments and in the paper, together with a computational disproof protocol.

---

## Proof Strategy Architecture

You must present and exploit 2–3 serious proof pathways.

### Strategy A: Coefficient-factorization and valuation algebra
Most promising for the foundational theorems.

1. Reduce each witness theorem to coefficientwise statements about finitely supported sums over `support`.
2. Use rational normalization \(c = \pm a/b\) with coprime \(a,b\), and define \(v_q(c)\) as multiplicity difference.
3. Prove finite-prime support and height bounds by combining:
   - finite support of the polynomial,
   - finite prime divisors of each numerator/denominator,
   - valuation additivity on products,
   - triangle/subadditivity estimates after summing over support.

Why promising: this route stays close to concrete Mathlib-accessible algebra on `ℚ`, `Finset`, support sums, and multiplicities.

### Strategy B: Abstract valuation-theoretic route via `IsKrullValuation`
Best for conceptual cleanliness, but potentially library-heavy.

1. Package \(q\)-adic valuation on \(\mathbb{Q}\) using valuation-theoretic interfaces.
2. Lift valuations to coefficient functionals on multivariate polynomials.
3. Derive witness inequalities from valuation axioms and support combinatorics.

Why promising: if it works, it creates a reusable formal infrastructure for non-archimedean tropicalization far beyond this project.

Why risky: the abstract interfaces may be more powerful than needed and cost time.

### Strategy C: Height theory / product formula route
Most important for the breakthrough theorem relating arithmetic and spectral size.

1. Define a coefficient height \(H(p)\) that is easy to formalize.
2. Prove a coefficientwise inequality from rational numerator/denominator factorization.
3. Sum over support and compare with max-prime or weighted-prime tropical witnesses.
4. Use DPP/Lorentzian structure to relate spectral witness growth to coefficient height.

Why promising: this is the right conceptual bridge to the conjecture.
Why difficult: the final spectral comparison may need problem-specific estimates from the DPP side.

**Recommendation:** Use Strategy A to secure 3–4 hard theorems now, while partially implementing Strategy C to obtain the first nontrivial coefficient-height inequality. Treat full spectral control as a conjectural frontier unless a clean DPP-specific estimate emerges.

---

## Cross-Domain Connections You Must Make Explicit

1. **Number theory ↔ tropical geometry**  
   \(p\)-adic valuations define a non-archimedean tropicalization of coefficients. This is the arithmetic shadow of the polynomial.

2. **Arithmetic geometry ↔ spectral theory**  
   If spectral witnesses are bounded by primewise valuation profiles, then spectral complexity is controlled by arithmetic height distribution rather than Euclidean magnitude alone.

3. **Berkovich geometry ↔ combinatorics**  
   Prime-indexed witness profiles should be interpreted as discrete probes of the Berkovich skeleton of the coefficient data.

4. **Statistical physics / partition functions ↔ valuation concentration**  
   For DPP partition functions, large witness values at specific primes may signal hidden factorization, rigidity, or arithmetic phase separation.

At least one theorem in the file must explicitly instantiate one of these bridges, not merely mention it in comments.

---

## Concrete Deliverables Inside the Lean Development

Your Lean file must contain:

- at least one **new definition** such as `padicCoeffWeight`, `padicTropSupportWeight`, or `primeSupport`
- at least **3 nontrivial theorems**
- at least one theorem using:
  - induction over finite support, or
  - `by_contra`, or
  - `field_simp`, or
  - a multi-step `calc`
- at least one theorem connecting arithmetic valuations to tropical support behavior
- at least one explicit **counterexample search mechanism** or conjecture test helper

Suggested additional definitions:
```lean
def primeSupportOfRat (c : ℚ) : Finset ℕ := ...
def primeSupport (p : MvPolynomial σ ℚ) : Finset ℕ := ...
def maxPadicWeight (p : MvPolynomial σ ℚ) : ℕ := ...
def coeffDenominatorComplexity (p : MvPolynomial σ ℚ) : ℕ := ...
```

Suggested helper theorem:
```lean
theorem padicCoeffWeight_eq_zero_of_coprime_to_prime
    (q : ℕ) [Fact q.Prime] {a b : ℤ} :
    Int.gcd a b = 1 →
    q ∣ a.natAbs → False →
    q ∣ b.natAbs → False →
    padicCoeffWeight q (a / b : ℚ) = 0 := ...
```

---

## Computational Experiment Requirement

You must produce a verified algorithm or computational method, not just theorem statements.

### Required algorithmic target
Implement a computable routine that, for a rational multivariate polynomial and finite prime set `S`, computes:
- coefficient prime support,
- `padicTropSupportWeight q p` for each `q ∈ S`,
- `primeAggregatedWitness S A F`.

This should be accompanied by correctness lemmas connecting the computation to the mathematical definitions.

### `demo.py`
Create `demo.py` that:
1. builds several rational DPP/Lorentzian-style test polynomials,
2. computes \(W_{\mathrm{trop}}^{(q)}\) for \(q = 2,3,5,7,11\),
3. compares the max prime witness against a chosen proxy for \(\log |W_{\mathrm{spec}}|\),
4. searches for counterexamples to the naive inequality,
5. visualizes primewise witness profiles.

A good demo would show examples where:
- one prime dominates,
- the archimedean coefficient size is modest but \(p\)-adic complexity is large,
- support growth and arithmetic complexity diverge.

---

## Falsifiable Conjecture with Testable Prediction

You must include at least one computationally falsifiable conjecture.

### Conjecture A: Sparse Prime Domination
For DPP partition polynomials with rational coefficients of bounded support degree, there exists a prime \(q \le 11\) such that
\[
W_{\mathrm{trop}}^{(q)}(p,A) \ge \frac{1}{\log 11}\cdot \frac{\log |W_{\mathrm{spec}}(p,A)|}{C(A)}.
\]
A single family with rapidly growing spectral witness and uniformly tiny witnesses for all \(q \in \{2,3,5,7,11\}\) disproves this.

### Conjecture B: Unit-Flatness Principle
If all coefficients of the derived subsystem polynomials are \(S\)-units, then the prime-aggregated witness outside \(S\) vanishes identically, and spectral growth is forced to come from archimedean or \(S\)-arithmetic sources alone.

This is falsifiable by constructing a polynomial whose coefficients are \(S\)-units but whose computed witness outside \(S\) is nonzero.

---

## Revolutionary Significance

If you can prove even the coefficient-height theorem and finite-prime support theorem in a reusable form, you have created the formal seed of **arithmetic tropical complexity theory**. That would enable:

- non-archimedean analogues of tropical robustness/witness methods,
- arithmetic invariants for Lorentzian and DPP polynomials,
- prime-sensitive complexity measures for combinatorial partition functions,
- future comparisons with Berkovich skeleta and arithmetic amoebas,
- a possible “adelic tropical” framework combining all places at once.

This is the beginning of a theory where the geometry of coefficients is not just Euclidean but **adelic**.

---

## Mandatory Final Outputs

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions
   - each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - at least one direction must bridge to a different domain, such as Berkovich geometry, arithmetic statistics, statistical physics, or complexity theory

2. **`RESEARCH_PAPER.md`**
   - standalone scientific paper
   - must explain:
     - what arithmetic tropical witnesses are,
     - the exact theorems proved,
     - why finite-prime support and coefficient-height control matter,
     - the conjectural spectral inequality,
     - computational evidence and counterexample protocol,
     - what should be attacked next

3. **`ARTICLE.md`**
   - Scientific American style
   - accessible, vivid, idea-focused
   - explain why prime numbers can leave geometric fingerprints in polynomial systems
   - **do not focus on formal verification machinery**

4. **A verified algorithm or computational method**
   - for computing primewise arithmetic tropical witnesses
   - with correctness lemmas

5. **`demo.py`**
   - interactive or at least command-line runnable
   - computes witness profiles on examples
   - tests the conjecture
   - searches for counterexamples

Minimize `sorry`. If a frontier theorem remains open, isolate it as a conjecture and prove the strongest surrounding infrastructure rigorously. The standard is not “some formalization happened.” The standard is: **you built the first arithmetic tropical witness calculus.**

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
