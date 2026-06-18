Soli Deo Gloria

## Assignment: Direction 4 — Operator-Norm Optimization for Concrete Parameters

**Mode:** `prove`

You are not being asked for a routine parameter check. You are being asked to formalize a new bridge between **operator theory, finite-dimensional Euclidean geometry, and concrete post-quantum cryptographic design**: show that the generic linear-noise bound used in ML-KEM compression analysis is not merely sound, but structurally improvable in the concrete module setting, and characterize when the improvement is optimal.

The catalog already gives correctness transfer principles such as:

- `Cryptography/ModuleLWE/Compression.lean`
  - `decode_correct_of_linear_noise_bound`
  - `decode_correct_of_composed_compression`

Your task is to build a new layer **above** these results: a theory of **sharp amplification constants** for concrete compression maps, together with optimization principles for choosing compression operators under rank / ratio constraints.

This should not be a cosmetic refinement of Theorem C. The goal is to isolate a mathematically meaningful invariant that controls decryption robustness more tightly than the raw operator norm, prove structural inequalities for it, and connect that invariant to concrete optimization over ML-KEM-style compression matrices.

---

## Core Vision

The existing correctness argument uses a bound of the form
\[
\|f(e)\| \le \|f\|_{\mathrm{op}} \cdot \|e\|,
\]
hence for \(\|e\|\le \delta\),
\[
\|f(e)\| \le \|f\|_{\mathrm{op}} \delta.
\]

That is worst-case sharp over all vectors in Euclidean space, but cryptographic module structure and concrete compression architectures may force the relevant noise directions to live in a smaller or more isotropic class. The breakthrough is to formalize a **structured amplification constant** and prove that for module rank \(k\), the naive operator-norm upper bound is universally within a factor \(\sqrt{k}\) of the true concrete amplification, with equality characterized by maximally anisotropic compression.

If successful, this opens a new design paradigm:

- **cryptographic correctness margins as spectral optimization problems**
- **compression design as constrained operator synthesis**
- **security/efficiency tradeoffs as finite-dimensional functional analysis**

This is exactly the kind of result that can influence future standardization: not “ML-KEM but with one more lemma,” but “compression in lattice cryptography has a hidden spectral geometry.”

---

## Precise Formal Targets

You should introduce at least one genuinely new definition, such as a structured amplification constant for a linear map under module-block constraints.

### New definition to introduce

Let \(f : (Fin\ k \to \mathbb R) \toₗ[\mathbb R] (Fin\ m \to \mathbb R)\). Define the **block-balanced amplification constant** or **rank-normalized amplification ratio** by
\[
\mathrm{ampRatio}(f) := \frac{\|f\|_{\mathrm{op}}}{A(f)},
\]
where \(A(f)\) is a new formally defined quantity representing the actual maximal amplification over a cryptographically relevant constrained family of error vectors, or alternatively the RMS amplification
\[
A_{\mathrm{rms}}(f)^2 := \frac{1}{k}\operatorname{trace}(f^\ast f).
\]
The second option is especially promising in Lean because it avoids measure theory and still gives a mathematically deep spectral quantity.

A highly viable path is to define:
\[
\operatorname{rmsAmplification}(f) := \sqrt{\frac{\sum_i \|f(e_i)\|^2}{k}},
\]
for the standard orthonormal basis \((e_i)\). Then prove
\[
\operatorname{rmsAmplification}(f) \le \|f\|_{\mathrm{op}} \le \sqrt{k}\,\operatorname{rmsAmplification}(f).
\]
This is nontrivial, sharp, and exactly expresses the \(\sqrt{k}\)-gap phenomenon.

That theorem is both formally accessible and scientifically meaningful: it says the worst singular value is at most \(\sqrt{k}\) times the average singular value.

---

## Exact Theorem Statements to Formalize

You need at least 3 substantial theorems. The following package is recommended.

### Theorem 1: RMS amplification is bounded by operator norm, with √k reverse inequality

For finite-dimensional Euclidean spaces over `ℝ`, define
\[
\mathrm{rmsAmp}(f)^2 = \frac{1}{\#\alpha}\sum_{i\in \alpha}\|f(e_i)\|^2
\]
for an orthonormal basis indexed by `α = Fin k`.

Then prove:

\[
\mathrm{rmsAmp}(f) \le \|f\| \le \sqrt{k}\,\mathrm{rmsAmp}(f).
\]

This is the formal core of the “overestimation by at most \(\sqrt{k}\)” principle.

### Suggested Lean 4 type signature

```lean
theorem rmsAmp_le_opNorm_le_sqrt_card_mul_rmsAmp
  {k m : ℕ} [NeZero k]
  (f : (EuclideanSpace ℝ (Fin k)) →L[ℝ] (EuclideanSpace ℝ (Fin m))) :
  rmsAmp f ≤ ‖f‖ ∧ ‖f‖ ≤ Real.sqrt k * rmsAmp f
```

If `Real.sqrt k` causes coercion friction, use:

```lean
theorem opNorm_le_sqrt_finrank_mul_rmsAmp
  {k m : ℕ} [NeZero k]
  (f : (EuclideanSpace ℝ (Fin k)) →L[ℝ] (EuclideanSpace ℝ (Fin m))) :
  ‖f‖ ≤ Real.sqrt (k : ℝ) * rmsAmp f
```

and separately

```lean
theorem rmsAmp_le_opNorm
  {k m : ℕ} [NeZero k]
  (f : (EuclideanSpace ℝ (Fin k)) →L[ℝ] (EuclideanSpace ℝ (Fin m))) :
  rmsAmp f ≤ ‖f‖
```

### Why this is a breakthrough

This converts a cryptographic folklore heuristic into a precise spectral theorem. It says the standard correctness bound is never arbitrarily pessimistic in rank-\(k\) module settings: the pessimism is quantitatively bounded by geometry alone.

---

### Theorem 2: Sharpness / equality construction

Prove that the \(\sqrt{k}\) factor is best possible by constructing a rank-one map \(f\) for which
\[
\|f\| = \sqrt{k}\,\mathrm{rmsAmp}(f).
\]

Concretely, let \(u : \mathbb R^k \to \mathbb R\) be the summation functional
\[
u(x)=\sum_i x_i,
\]
embedded into a one-dimensional codomain. Then \(\|u\|=\sqrt{k}\) while the RMS image of basis vectors is \(1\).

### Suggested Lean signature

```lean
theorem exists_map_realizing_sqrt_card_gap
  {k : ℕ} [NeZero k] :
  ∃ f : (EuclideanSpace ℝ (Fin k)) →L[ℝ] ℝ,
    rmsAmp f ≠ 0 ∧ ‖f‖ = Real.sqrt (k : ℝ) * rmsAmp f
```

or a more explicit theorem for a named construction:

```lean
def sumLin
  {k : ℕ} :
  (EuclideanSpace ℝ (Fin k)) →L[ℝ] ℝ := ...

theorem norm_sumLin_eq_sqrt_card
  {k : ℕ} :
  ‖sumLin‖ = Real.sqrt (k : ℝ)

theorem rmsAmp_sumLin
  {k : ℕ} [NeZero k] :
  rmsAmp sumLin = 1

theorem sumLin_attains_sqrt_gap
  {k : ℕ} [NeZero k] :
  ‖sumLin‖ = Real.sqrt (k : ℝ) * rmsAmp sumLin
```

### Why this matters

Without a sharpness theorem, the \(\sqrt{k}\) bound is just an estimate. With sharpness, you have identified the exact geometric obstruction: concentration of all singular mass in one direction. This is exactly the anisotropy cryptographic engineers should avoid.

---

### Theorem 3: Composition theorem for cryptographic correctness using RMS amplification

Using catalog theorem(s) on decode correctness, prove a strengthened correctness criterion replacing a raw operator norm hypothesis by an RMS-based sufficient condition plus a \(\sqrt{k}\)-inflation term.

A representative theorem:

If a linear compression map \(f\) satisfies
\[
\sqrt{k}\,\mathrm{rmsAmp}(f)\cdot \delta \le B,
\]
then decryption succeeds under the same correctness threshold \(B\) used in the catalog theorem.

### Suggested Lean shape

```lean
theorem decode_correct_of_rmsAmp_bound
  {k m : ℕ} [NeZero k]
  (f : (EuclideanSpace ℝ (Fin k)) →L[ℝ] (EuclideanSpace ℝ (Fin m)))
  {δ B : ℝ}
  (hδ : 0 ≤ δ)
  (hB : 0 ≤ B)
  (hamp : Real.sqrt (k : ℝ) * rmsAmp f * δ ≤ B) :
  decode_correct ... := ...
```

You will need to adapt the exact target to the API of
`decode_correct_of_linear_noise_bound` and
`decode_correct_of_composed_compression`.

### Why this matters

This is the theorem that turns spectral insight into cryptographic engineering. It says the new invariant is not just mathematically elegant: it can replace the old one in concrete correctness arguments.

---

### Theorem 4: Optimization principle for minimizers under fixed Frobenius energy

This is the most visionary theorem in the package.

For linear maps with fixed Frobenius norm / fixed total squared column norm,
\[
\mathrm{rmsAmp}(f) \text{ fixed},
\]
the operator norm is minimized exactly when singular values are all equal (isotropic case), and then
\[
\|f\| = \mathrm{rmsAmp}(f).
\]

A fully general singular-value theorem may be too heavy for one cycle, but a tractable finite-dimensional version is still profound:

- prove for diagonal maps \(D = \mathrm{diag}(d_i)\),
  \[
  \max_i |d_i| \ge \sqrt{\frac{1}{k}\sum_i d_i^2},
  \]
  with equality iff all \(|d_i|\) are equal;
- interpret this as “balanced compression minimizes worst-case amplification at fixed average distortion.”

### Suggested Lean signature

```lean
theorem opNorm_diag_ge_rms_entries
  {k : ℕ} [NeZero k] (d : Fin k → ℝ) :
  Real.sqrt ((∑ i, (d i)^2) / k) ≤ ‖diagLin d‖
```

and an equality characterization:

```lean
theorem opNorm_diag_eq_rms_entries_iff
  {k : ℕ} [NeZero k] (d : Fin k → ℝ) :
  ‖diagLin d‖ = Real.sqrt ((∑ i, (d i)^2) / k) ↔
    ∀ i j, |d i| = |d j|
```

### Why this is revolutionary

This turns compression-matrix search into a theorem-guided optimization problem: **spread spectral mass evenly**. That is a design principle, not a post hoc estimate.

---

## Lean 4 Formalization Guidance

You should target finite-dimensional Euclidean spaces where Mathlib is strongest:

- `EuclideanSpace ℝ (Fin k)`
- continuous linear maps `→L[ℝ]`
- basis vectors via `Pi.single`
- norm identities for finite sums
- operator norm inequalities
- `LinearIsometry`, `ContinuousLinearMap.opNorm_le_iff`, or basis-coordinate estimates
- finite sums over `Fin k`

If singular values / SVD machinery is too expensive in current Mathlib, do **not** stall. The RMS route above is stronger as a formal research strategy because it is basis-computable and still captures the spectral story.

---

## Proof Strategy Architecture

You must give Aristotle multiple viable proof paths and choose the best one.

### Strategy A: Basis-energy / Frobenius route — most promising

1. **Define `rmsAmp` from basis images**:
   \[
   \mathrm{rmsAmp}(f)^2 = \frac{1}{k}\sum_i \|f(e_i)\|^2.
   \]

2. **Prove lower bound** `rmsAmp f ≤ ‖f‖`:
   each basis vector has norm 1, so \(\|f(e_i)\| \le \|f\|\); square, sum, divide by \(k\), take square roots.

3. **Prove upper bound** `‖f‖ ≤ √k * rmsAmp f`:
   write \(x=\sum_i x_i e_i\), use triangle/Cauchy–Schwarz to show
   \[
   \|f(x)\|
   \le \sum_i |x_i|\,\|f(e_i)\|
   \le \Big(\sum_i x_i^2\Big)^{1/2}\Big(\sum_i \|f(e_i)\|^2\Big)^{1/2}
   = \sqrt{k}\,\mathrm{rmsAmp}(f)\,\|x\|.
   \]
   Then conclude by `ContinuousLinearMap.opNorm_le_iff`.

**Why most promising:** no SVD, no heavy spectral theorem imports, entirely finite-dimensional, and the proof naturally uses `calc`, `field_simp`, finite-sum inequalities, and basis decomposition.

---

### Strategy B: Matrix / Frobenius norm route

1. Represent `f` by a matrix \(A\) in the standard basis.
2. Show
   \[
   \|A\|_{2\to 2} \le \|A\|_F.
   \]
3. Observe
   \[
   \|A\|_F = \sqrt{k}\,\mathrm{rmsAmp}(f).
   \]

**Why useful:** gives conceptual clarity and aligns with engineering literature.  
**Why less promising:** matrix/operator-norm interoperability in Lean may be more laborious than basis-image estimates.

---

### Strategy C: Singular-value route

1. Define singular values \(\sigma_i\).
2. Identify
   \[
   \|f\|=\max_i \sigma_i,\qquad
   \mathrm{rmsAmp}(f)=\sqrt{\frac{1}{k}\sum_i \sigma_i^2}.
   \]
3. Conclude by elementary inequalities between `max` and `ℓ²` average.

**Why conceptually strongest:** directly matches the conjecture’s SVD framing.  
**Why risky:** dependent on available spectral API and likely too expensive for one cycle.

---

## Required Deep Proof Tactics

Your file must visibly contain nontrivial proof architecture. At least three theorems should use combinations of:

- `induction` on `Finset`
- `rcases` on basis decompositions / existential equality conditions
- `by_contra` for equality characterizations
- `field_simp` in RMS normalization formulas
- multi-step `calc`
- Cauchy–Schwarz / sum-of-squares manipulations

Do **not** let this degenerate into trivial norm simplifications.

---

## Cross-Domain Connections You Must Make Explicit

At least one theorem and the surrounding exposition must connect this work to another mathematical domain.

### Connection 1: Functional analysis ↔ Cryptographic engineering
The operator norm is a Banach-space object; the correctness threshold is a cryptographic object. Your theorem says decryption robustness is controlled by spectral anisotropy, not just map size.

### Connection 2: Optimization ↔ Information geometry
The isotropy-minimizes-worst-case-amplification principle mirrors variance-spreading phenomena in statistics and coding theory: balanced directions minimize adversarial concentration.

### Connection 3: Mathematical physics ↔ Compression design
Interpreting \(\sum_i \|f(e_i)\|^2\) as an “energy budget,” the optimal design principle is equipartition: distributing energy evenly across modes minimizes peak excitation. This is the same geometry that appears in statistical mechanics and wave localization.

You should include at least one theorem or corollary that explicitly encodes this equipartition principle for diagonal or block-diagonal maps.

---

## Concrete New Definitions to Introduce

You must define at least one novel concept not already in the catalog. Recommended options:

```lean
def rmsAmp
  {k m : ℕ} (f : (EuclideanSpace ℝ (Fin k)) →L[ℝ] (EuclideanSpace ℝ (Fin m))) : ℝ := ...
```

```lean
def anisotropyRatio
  {k m : ℕ} [NeZero k]
  (f : (EuclideanSpace ℝ (Fin k)) →L[ℝ] (EuclideanSpace ℝ (Fin m))) : ℝ :=
  ‖f‖ / rmsAmp f
```

```lean
def balancedCompression
  {k : ℕ} (d : Fin k → ℝ) : Prop :=
  ∀ i j, |d i| = |d j|
```

These are mathematically meaningful and support several deep theorems.

---

## Computational / Algorithmic Deliverable

You must not stop at theorem statements. Produce a verified computational method.

### Verified algorithm target

Implement an algorithm that, for a finite family of candidate diagonal or block compression maps:

1. computes `rmsAmp`,
2. computes the exact basis-image energy,
3. computes / bounds the operator norm,
4. ranks candidates by anisotropy ratio,
5. identifies those minimizing worst-case amplification at fixed RMS budget.

This can first be done for diagonal maps, where exact formulas are tractable and formally provable.

### Demo target

`demo.py` should:

- instantiate small analogues of ML-KEM-style compression matrices,
- display operator norm vs RMS amplification,
- show examples approaching the \(\sqrt{k}\) gap,
- show balanced matrices achieving minimal anisotropy,
- test the falsifiable conjecture below on random structured matrices.

---

## Falsifiable Conjectures and Testable Predictions

You must include a `FUTURE_DIRECTIONS.md` with 3–5 falsifiable hypotheses. At least one should directly extend this project.

### Conjecture A: Structured ML-KEM anisotropy gap
For the concrete NTT-domain compression operators used in ML-KEM-768, the anisotropy ratio
\[
\frac{\|f\|}{\mathrm{rmsAmp}(f)}
\]
is strictly smaller than \(\sqrt{k}\), and in fact bounded by a constant \(< 1.3\) for the relevant block structure.

**Test:** compute the exact ratio for all concrete compression blocks; disprove by exhibiting one block exceeding the threshold.

### Conjecture B: Balanced block compression is optimal
Among block-diagonal compression operators with fixed compression ratio and fixed RMS energy, the minimum operator norm is achieved by equal singular values on each block.

**Test:** brute-force / continuous optimization over low-dimensional blocks; disprove by finding a lower-operator-norm unbalanced block.

### Conjecture C: Catalog-correctness can be improved in practice
Replacing the raw operator norm by the RMS-based \(\sqrt{k}\)-bound yields a strictly better decryption margin for concrete ML-KEM parameters.

**Test:** instantiate the catalog theorem numerically on concrete parameter sets; disprove if all resulting thresholds are identical.

### Conjecture D: Noise-distribution alignment beats worst-case geometry
For subgaussian error distributions relevant to Module-LWE, typical amplification is controlled by `rmsAmp` rather than `‖f‖`.

**Test:** Monte Carlo compare empirical amplification quantiles to both bounds; disprove if empirical tails track operator norm sharply.

---

## Building Directly on Catalog Theorems

You must explicitly explain how the new theory plugs into:

- `decode_correct_of_linear_noise_bound`
- `decode_correct_of_composed_compression`

The architecture should be:

1. prove a new generic inequality giving a linear noise bound from `rmsAmp`;
2. package it as a lemma consumable by the catalog theorem;
3. derive a new decode-correctness theorem with a more interpretable amplification constant;
4. specialize to candidate concrete matrices.

This is how you turn abstract analysis into usable cryptographic mathematics.

---

## Suggested File Structure

A plausible file could include:

1. `rmsAmp` definition
2. basic lemmas: nonnegativity, scaling, zero iff images vanish
3. theorem `rmsAmp_le_opNorm`
4. theorem `opNorm_le_sqrt_card_mul_rmsAmp`
5. sharpness construction `sumLin`
6. diagonal-map exact formulas
7. equality characterization for balanced diagonal maps
8. cryptographic corollary via catalog decode theorems
9. computational ranking algorithm for candidate maps

---

## Application Keywords

operator norm, Frobenius norm, RMS amplification, anisotropy ratio, spectral optimization, Module-LWE, ML-KEM-768, NTT compression, decryption correctness, finite-dimensional functional analysis, matrix balancing, equipartition, coding theory, subgaussian noise, post-quantum cryptography, robust parameter design

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean development** with at least 3 nontrivial theorems using deep proof tactics, and with minimal `sorry`.
2. **A structured `FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses with explicit computational tests.
3. **A `RESEARCH_PAPER.md`** that is fully standalone: a reader with no code access must understand the definitions, main theorems, proof ideas, significance, and next questions.
4. **An `ARTICLE.md`** in Scientific American style, engaging and accessible, focused on the mathematics and cryptographic significance — **do not** focus on formal verification machinery.
5. **A verified algorithm or computational method**, not merely theorem statements.
6. **A `demo.py`** that interactively demonstrates the spectral gap, optimization principle, and concrete candidate comparisons.

This project is successful only if it produces a new scientific object: a theory of **spectrally optimized cryptographic compression**. The formal theorems are the skeleton; the real result is the design principle they reveal.

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
