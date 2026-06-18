## Assignment: Direction 2: Certificate Density for Symplectic and Orthogonal Groups

Prove new, non-trivial theorems that push the certificate-density paradigm beyond `GL_n` into the geometry of classical groups. The real target is not “another counting lemma,” but a structural theory explaining why regular semisimple elements with irreducible, symmetry-constrained characteristic polynomial form a universal sparse backbone for generation in symplectic and orthogonal groups.

You should treat the `GL_n` density theorem as the zeroth-order model and then discover the genuinely new phenomenon: in self-dual representation settings, irreducibility is no longer enough; one must count **admissible self-reciprocal irreducibles** and identify the corresponding anisotropic maximal tori. This is where the mathematics becomes interesting.

Build on:
- `Algebra/MatrixGroupGeneration.lean` — use its generation/certificate framework as the ambient machine.
- `Pythagorean/CertificateDensity.lean` — extract the asymptotic counting template, but do **not** merely re-run it. The new ingredient is the self-reciprocal constraint and the resulting torus-centralizer geometry.

Minimize sorry. Produce genuine mathematics.

---

## Core Vision

For `Sp₂ₙ(𝔽_q)` and suitable orthogonal analogues, isolate a class of “certificate elements” whose characteristic polynomial is:
1. irreducible in the appropriate reduced variable,
2. self-reciprocal in the ambient degree,
3. compatible with the preserved bilinear form.

Then prove asymptotic density theorems showing that these certificates occur with frequency on the order of `1 / (2n)` rather than `1 / (2n)!` or some vanishingly small artifact. If this works, it reveals a robust mechanism for random generation in classical groups and opens a bridge to:
- arithmetic statistics of self-dual polynomials,
- maximal torus geometry in finite groups of Lie type,
- symplectic structures in quantum stabilizer codes.

This is not just an extension of `GL_n`; it is the first step toward a **uniform certificate theory for self-dual groups**.

---

## Precise Mathematical Targets

### New definition requirement
You must introduce at least one genuinely new definition, for example:

- `IsSelfReciprocal : Polynomial 𝔽q → Prop`
- `IsSymplecticCertificate : Matrix (Fin (2*n)) (Fin (2*n)) 𝔽q → Prop`
- `symplecticCertificateDensity : ℕ → ℕ → ℚ`
- or a structure encoding admissible characteristic polynomials for classical groups.

A promising definition is:

> A polynomial `f : Polynomial K` of degree `2n` is **symplectically admissible** if it is monic, irreducible, nonzero constant term, and satisfies  
> `f.reverse = f`.

Over finite fields, this encodes the reciprocal symmetry `f(x) = x^(2n) f(1/x)`.

---

## Theorem 1: Structural characterization of symplectic certificate polynomials

### Informal statement
Let `K` be a field. If `f ∈ K[X]` is monic of degree `2n`, has nonzero constant coefficient, and satisfies `f.reverse = f`, then its roots occur in inverse pairs. Over finite fields, such an irreducible polynomial defines a semisimple conjugacy class compatible with a symplectic form. Formalize the polynomial side cleanly, and then connect it to the matrix/group side as far as Mathlib permits.

### Lean 4 type signature target
A realistic polynomial theorem target:

```lean
theorem roots_inv_pairing_of_self_reciprocal
    {K : Type*} [Field K] {f : Polynomial K} {n : ℕ}
    (hmonic : f.Monic)
    (hdeg : f.natDegree = 2 * n)
    (hself : f.reverse = f)
    (hconst : f.coeff 0 ≠ 0) :
    ∀ {L : Type*} [Field L] [Algebra K L] {z : L},
      aeval z f = 0 → aeval z⁻¹ f = 0
```

If inversion hypotheses force extra assumptions, refine the statement appropriately, e.g. requiring `z ≠ 0`.

A stronger and more algebraic alternative:

```lean
theorem self_reciprocal_iff_coeff_symmetry
    {K : Type*} [Semiring K] {f : Polynomial K} {d : ℕ}
    (hdeg : f.natDegree = d) :
    f.reverse = f ↔ ∀ i ≤ d, f.coeff i = f.coeff (d - i)
```

This is excellent because it gives a concrete coefficient-level handle used repeatedly later.

### Why this matters
This theorem is the local DNA of the whole program. Without it, “certificate density for symplectic groups” is only a slogan. With it, you can package admissibility in coefficient language and control the passage from polynomial counting to torus counting.

### Proof strategy options
**Strategy A: coefficient symmetry via `reverse`**
1. Expand `coeff` of `f.reverse`.
2. Use `natDegree` control and coefficient vanishing beyond degree.
3. Derive the palindromic coefficient condition and then evaluate at `z` and `z⁻¹`.

**Strategy B: root-theoretic argument**
1. Use the identity relating `f` and `reverse`.
2. Rewrite `aeval z⁻¹ f` in terms of `aeval z f.reverse`.
3. Use `hself` and `hconst` to avoid the zero-root pathology.

**Most promising:** Strategy A first, then derive Strategy B as a corollary. It is more robust in Lean and creates reusable lemmas for the later counting arguments.

---

## Theorem 2: Reduced-variable parametrization of self-reciprocal polynomials

This is the conceptual breakthrough theorem. The folklore map
\[
g(y) \mapsto x^n g(x + x^{-1})
\]
should be turned into a formal theorem about generating self-reciprocal polynomials of even degree. You may need to use a polynomial/Laurent-polynomial surrogate if full Laurent polynomial infrastructure is awkward; a coefficient-defined substitute is acceptable if mathematically sharp.

### Informal statement
Every monic self-reciprocal polynomial of even degree `2n` with nonzero constant term is governed by approximately `n` free parameters, and the irreducible ones are controlled by degree-`n` data after passing through the involution `x ↦ x + x⁻¹`. Formalize at least the constructive direction and preferably a partial converse.

### Lean 4 type signature target
If the exact `x + x⁻¹` transform is too heavy, prove a coefficient-parametrization theorem:

```lean
theorem self_reciprocal_even_degree_determined_by_first_half
    {K : Type*} [Semiring K] {f g : Polynomial K} {n : ℕ}
    (hfdeg : f.natDegree = 2 * n)
    (hgdeg : g.natDegree = 2 * n)
    (hselff : f.reverse = f)
    (hselfg : g.reverse = g)
    (hcoeff :
      ∀ i ≤ n, f.coeff i = g.coeff i) :
    f = g
```

This already proves the “dimension `n`” phenomenon formally.

A stronger existence theorem target:

```lean
theorem exists_unique_self_reciprocal_of_half_data
    {K : Type*} [Semiring K] (n : ℕ)
    (a : Fin (n+1) → K) :
    ∃! f : Polynomial K,
      f.natDegree ≤ 2 * n ∧
      f.reverse = f ∧
      ∀ i : Fin (n+1), f.coeff i = a i
```

### Why this matters
This theorem explains why the count of self-reciprocal polynomials is roughly `q^n`, not `q^{2n}`. That is the hidden reason the certificate density should be `~ 1/(2n)` in `Sp₂ₙ(𝔽_q)`. The entire asymptotic story rests on this compression from `2n` coefficients to `n`.

### Proof strategy options
**Strategy A: coefficient reflection construction**
1. Construct `f` explicitly from half the coefficients.
2. Prove `reverse = f` by coefficient comparison.
3. Prove uniqueness from symmetry.

**Strategy B: induction on degree**
1. Strip outer coefficients using self-reciprocity.
2. Reduce degree `2n` to degree `2(n-1)`.
3. Rebuild recursively.

**Strategy C: linear algebra of coefficient spaces**
1. View degree-`2n` polynomials as a vector space.
2. Identify the fixed space of the reversal involution.
3. Prove its dimension is `n+1`.

**Most promising:** Strategy A for Lean robustness. Strategy C is more revolutionary and should appear in the paper, even if the formal proof uses A.

---

## Theorem 3: Asymptotic count of monic self-reciprocal irreducibles

This is the flagship counting theorem. Even a one-sided asymptotic with explicit constants would already be substantial.

### Informal statement
Let `SRI(q, n)` denote the number of monic irreducible self-reciprocal polynomials of degree `2n` over `𝔽_q` with nonzero constant term. Then
\[
\mathrm{SRI}(q,n) = \frac{q^n}{2n} + O(q^{\lceil n/2 \rceil}),
\]
or at minimum explicit upper/lower bounds of that scale. Use the reduced-variable parametrization and Möbius/necklace-style counting as the model.

### Lean 4 type signature target
If the full asymptotic notation is too heavy, formalize explicit inequalities:

```lean
def selfReciprocalIrreducibleCount (q n : ℕ) : ℕ := ...

theorem self_reciprocal_irreducible_count_bounds
    (q n : ℕ) [Fact q.Prime]
    (hn : 1 ≤ n) :
    ∃ C : ℕ,
      (selfReciprocalIrreducibleCount q n : ℤ) * (2 * n)
        ≤ q^n + C * q^(n / 2 + 1) ∧
      q^n - C * q^(n / 2 + 1)
        ≤ (selfReciprocalIrreducibleCount q n : ℤ) * (2 * n)
```

Or, if you have asymptotic infrastructure available:

```lean
theorem selfReciprocalIrreducibleCount_asymptotic
    (q : ℕ) [Fact q.Prime] :
    Filter.Tendsto
      (fun n : ℕ => ((selfReciprocalIrreducibleCount q n : ℚ) * (2*n)) / q^n)
      Filter.atTop
      (nhds 1)
```

But explicit finite bounds are preferable and more scientifically useful.

### Why this matters
This is the arithmetic engine. Once established, the group-theoretic density follows by identifying each such polynomial with a regular semisimple conjugacy class whose centralizer has anisotropic torus type. It is the self-dual analogue of the irreducible-polynomial count driving `GL_n`.

### Proof strategy options
**Strategy A: reduction to degree-`n` irreducibles**
1. Formalize the self-reciprocal compression.
2. Relate admissible degree-`2n` irreducibles to degree-`n` data.
3. Import the necklace/Möbius count pattern from `Pythagorean/CertificateDensity.lean`.

**Strategy B: Burnside/orbit count under inversion**
1. Count irreducible polynomials modulo the involution on roots `α ↦ α⁻¹`.
2. Isolate fixed orbits corresponding to self-reciprocal irreducibles.
3. Bound exceptional cases.

**Strategy C: field-theoretic norm/trace parametrization**
1. Work in `𝔽_{q^{2n}}`.
2. Characterize self-reciprocal minimal polynomials via Frobenius acting on inversion orbits.
3. Count admissible primitive elements by orbit size.

**Most promising:** Strategy B or C mathematically; Strategy A if catalog infrastructure already contains irreducible polynomial counting lemmas. In the paper, present C as the conceptual explanation even if Lean uses A/B.

---

## Theorem 4: Certificate density theorem for `Sp₍₂ₙ₎(𝔽_q)`

### Informal statement
Define the symplectic certificate density as the proportion of elements in `Sp_{2n}(𝔽_q)` whose characteristic polynomial is monic, irreducible, self-reciprocal, and yields a regular semisimple element. Then this density is asymptotically `1/(2n)` up to lower-order error.

### Lean 4 type signature target
You may need to encode this first as a finite count over a finite subtype or as a theorem comparing counts.

```lean
def IsSymplecticCertificate
    {q n : ℕ}
    (A : Matrix (Fin (2*n)) (Fin (2*n)) (ZMod q)) : Prop :=
    -- preserves standard symplectic form
    -- characteristic polynomial irreducible
    -- self-reciprocal
    -- regular semisimple surrogate

def symplecticCertificateDensity (q n : ℕ) : ℚ := ...

theorem symplectic_certificate_density_main
    (q n : ℕ) [Fact q.Prime] (hn : 1 ≤ n) :
    ∃ C : ℕ,
      |symplecticCertificateDensity q n - (1 : ℚ) / (2*n)| ≤ C / q^n
```

If absolute values in `ℚ` become annoying, use two-sided inequalities.

A weaker but still significant theorem:
```lean
theorem symplectic_certificate_density_lower_upper
    (q n : ℕ) [Fact q.Prime] (hn : 1 ≤ n) :
    ∃ C₁ C₂ : ℕ,
      ((1 : ℚ) / (2*n)) - C₁ / q^n ≤ symplecticCertificateDensity q n ∧
      symplecticCertificateDensity q n ≤ ((1 : ℚ) / (2*n)) + C₂ / q^n
```

### Why this is a breakthrough
This would be the first formalized density theorem for certificate elements in a non-`GL` classical group family. It shows that the generation framework is not an artifact of generic linear algebra but reflects deep self-dual arithmetic geometry. It opens:
- probabilistic generation in groups of Lie type,
- certified random constructions in coding theory,
- arithmetic statistics of self-dual spectral data.

### Proof strategy options
**Strategy A: conjugacy-class transfer from polynomial count**
1. Count admissible self-reciprocal irreducibles.
2. Associate each to a regular semisimple torus class in `Sp_{2n}`.
3. Divide by centralizer size to obtain element density.

**Strategy B: torus geometry first**
1. Identify anisotropic maximal tori of type `𝔽_{q^{2n}}^1`.
2. Count regular generators inside those tori.
3. Average over Weyl-group orbits.

**Strategy C: compare with `GL_{2n}` and impose symplectic constraint**
1. Start from the `GL` certificate density.
2. Restrict to self-dual classes.
3. quantify the codimension/constraint effect.

**Most promising:** Strategy B conceptually, Strategy A formally. Use `Algebra/MatrixGroupGeneration.lean` for the certificate framework and import only the exact torus-counting ingredients needed.

---

## Orthogonal extension target

Do not stop at symplectic groups. At minimum, formulate and partially prove an orthogonal analogue.

### Suggested theorem
For odd orthogonal groups or split even orthogonal groups over `𝔽_q`, define orthogonal certificate polynomials by the same reciprocal symmetry plus discriminant/sign constraints, and prove at least one nontrivial theorem showing that the admissible polynomial set differs from the symplectic one by a parity or spinor-norm condition.

### Lean target
```lean
def IsOrthogonalAdmissiblePolynomial
    {K : Type*} [Field K] (f : Polynomial K) : Prop := ...

theorem orthogonal_admissible_implies_self_reciprocal
    {K : Type*} [Field K] {f : Polynomial K} :
    IsOrthogonalAdmissiblePolynomial f → f.reverse = f
```

A stronger target would distinguish the orthogonal and symplectic cases by an invariant attached to `f(1)` or `f(-1)`.

---

## Cross-domain connection theorem

You are required to include at least one theorem connecting this domain to another.

### Strong recommendation: algebra ↔ quantum computing
The symplectic group over `𝔽₂` governs stabilizer-code commutation relations. A certificate element with irreducible self-reciprocal characteristic polynomial acts as a “maximally mixing” symplectic automorphism on phase space.

Formalize a clean finite-dimensional theorem such as:

```lean
theorem symplectic_certificate_preserves_commutation_form
    {n : ℕ} {A : Matrix (Fin (2*n)) (Fin (2*n)) (ZMod 2)}
    (hA : IsSymplecticCertificate A) :
    ∀ v w, symplecticForm (A.mulVec v) (A.mulVec w) = symplecticForm v w
```

This may look basic, but the point is to connect the certificate notion to the algebra of Pauli/stabilizer commutation. In the paper and article, explain that such elements model highly mixing logical transformations in quantum codes.

### Alternative bridge: algebra ↔ arithmetic statistics
Prove that the coefficient-space dimension drop for self-reciprocal polynomials is exactly the fixed-space dimension of an involution. This connects finite classical groups to invariant theory and random polynomial statistics.

### Application keywords
- finite groups of Lie type
- regular semisimple elements
- self-reciprocal irreducible polynomials
- anisotropic maximal tori
- arithmetic statistics
- probabilistic generation
- quantum stabilizer codes
- symplectic geometry over finite fields
- coding theory
- spectral constraints

---

## Conjecture with testable prediction

You must state at least one falsifiable conjecture and provide a computational test.

### Primary conjecture
For prime powers `q` and `n ≥ 1`, if `SRI(q,n)` denotes the number of monic self-reciprocal irreducible polynomials of degree `2n` over `𝔽_q`, then
\[
\left| SRI(q,n) - \frac{q^n}{2n} \right| \le q^{n/2}
\]
for all odd `q` outside a finite exceptional set depending only on parity data.

### Computational disproof protocol
For `n = 2` (the `Sp₄` case), compute `SRI(q,2)` for `q = 3,5,7`.
- Compare against `q^2/4`.
- If the deviation exceeds `q`, the conjectured error term is false in this regime.
- Then refine the conjecture by parity or torus-type correction.

### Secondary conjecture
The certificate density in `Sp_{2n}(𝔽_q)` equals the proportion of generators of anisotropic maximal tori of type `𝔽_{q^{2n}}^1`, up to an error of order `O(q^{-n})`.

This is stronger and more structural. It predicts that the density theorem is really a torus-generator theorem in disguise.

---

## Concrete proof architecture

### Step 1: Build the polynomial infrastructure
- Define self-reciprocal and admissible polynomials.
- Prove coefficient symmetry lemmas.
- Prove uniqueness from first-half coefficients.
- Develop root inversion lemmas.

### Step 2: Count admissible polynomials
- Reuse irreducible polynomial counting ideas from `Pythagorean/CertificateDensity.lean`.
- Introduce the inversion action on roots or polynomials.
- Derive upper/lower bounds for self-reciprocal irreducibles.

### Step 3: Transfer to symplectic groups
- Define the standard symplectic form matrix.
- Define symplectic certificate elements.
- Show admissible characteristic polynomial implies the right regular-semisimple centralizer shape.
- Deduce density bounds.

### Step 4: Orthogonal comparison
- Introduce an orthogonal admissibility notion.
- Prove at least one theorem distinguishing orthogonal from symplectic behavior.
- Explain in the paper what sign/discriminant corrections should govern the full theory.

---

## Minimum theorem list you should actually formalize

You must prove at least 3 substantial theorems, and they should use deep tactics (`induction`, `rcases`, `by_contra`, `field_simp`, multi-step `calc`, etc.). A good minimal list is:

1. `self_reciprocal_iff_coeff_symmetry`
2. `self_reciprocal_even_degree_determined_by_first_half`
3. `self_reciprocal_irreducible_count_bounds`

And then at least one of:
4. `roots_inv_pairing_of_self_reciprocal`
5. `symplectic_certificate_density_lower_upper`
6. `orthogonal_admissible_implies_self_reciprocal`
7. `symplectic_certificate_preserves_commutation_form`

Do not choose only easy polynomial extensionality lemmas. At least one theorem must involve genuine counting or group structure.

---

## Lean engineering guidance

- Use explicit helper lemmas for `Polynomial.reverse`, `coeff`, and `natDegree`.
- Expect to need careful case splits on `n = 0`.
- Prefer explicit finite-field statements with `ZMod q` and `[Fact q.Prime]` if prime-power fields are cumbersome at first.
- If full `Sp_{2n}(𝔽_q)` subgroup infrastructure is missing, define the predicate “preserves standard symplectic form” directly on matrices and prove density/counting results for that subtype.
- If characteristic polynomial irreducibility is difficult to package, first formalize the polynomial-count theorem independently and then state a group-side theorem conditional on a correspondence lemma.

But do not retreat into purely definitional work. The point is to land at least one asymptotic or explicit quantitative theorem.

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Provide 3–5 original research directions. Each direction must include:
- a sentence beginning exactly with **“The key insight is...”**
- a sentence beginning exactly with **“Why now?”**
At least one direction must bridge to a different domain, such as:
- quantum error correction,
- arithmetic statistics,
- invariant theory,
- expander constructions,
- random matrix theory.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the precise definitions,
- the main theorems,
- why self-reciprocal irreducibles govern classical-group certificates,
- proof ideas,
- computational evidence,
- conjectures and next steps.

Someone reading only this paper must understand the discovery without seeing the code.

### 3. `ARTICLE.md`
Write in Scientific American style.
Do **not** focus on formal verification machinery.
Explain the mathematics, the surprise, and why symplectic/orthogonal symmetry changes the statistics of “good” matrices.

### 4. Verified algorithm or computational method
Implement a verified method to:
- generate monic self-reciprocal degree-`2n` polynomials over `𝔽_q`,
- test irreducibility,
- count admissible examples,
- and estimate certificate density for small `n,q`.

### 5. `demo.py`
Provide an interactive script that:
- computes the `Sp₄(𝔽_q)` self-reciprocal irreducible counts for `q = 3,5,7`,
- compares them to `1/4`,
- prints deviations from the asymptotic prediction,
- and visualizes how coefficient symmetry reduces the search space from `q^(2n)` to roughly `q^n`.

---

## Final ambition

Do not write “the symplectic analogue of the GL theorem.” Write the beginning of a new theory:

> **Certificate density is controlled by the arithmetic of self-dual spectral data and the geometry of anisotropic tori in classical groups.**

If you can make that statement mathematically precise in Lean, even first for `Sp₄` and then abstractly for `Sp₂ₙ`, you will have opened a research corridor connecting finite classical groups, polynomial arithmetic, and quantum information.

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
