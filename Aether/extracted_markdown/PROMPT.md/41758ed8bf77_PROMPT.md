# Mode: prove

## Assignment: Motivic Persistence Spectrum for Point Counts Across Extension Towers

You are not being asked for a modest extension of arithmetic statistics. You are being asked to create a new extraction principle: recover motivic information from the *shape* of point-count data viewed through a persistence-theoretic lens. The goal is to turn the sequence
\[
r \mapsto |X(\mathbf F_{q^r})|
\]
into a filtered object whose barcode detects Frobenius slope data and, in favorable families, separates motivic constituents. If this works even in a mathematically controlled prototype, it opens a field: **arithmetic topological signal processing for motives**.

Your task is to prove rigorous theorems for a formalized prototype of this program in Lean 4, using catalog results wherever available, and to build a verified computational pipeline that tests the conjectural vision on explicit families.

---

## Core Vision

For a smooth projective variety \(X/\mathbf F_q\), the Weil zeta function packages point counts:
\[
Z_X(T)=\exp\!\left(\sum_{r\ge1}\frac{|X(\mathbf F_{q^r})|}{r}T^r\right),
\]
and the logarithmic derivatives encode power sums of Frobenius eigenvalues. Persistence theory, by contrast, extracts stable qualitative structure from filtered data. The breakthrough target is to define a filtered chain complex or persistence module from truncated point-count sequences whose interval structure recovers, or at least rigidly constrains, the Frobenius slope multiset.

The formalized first breakthrough should not try to solve the full conjecture at once. Instead, isolate a mathematically sharp prototype in which:

1. point-count sequences are converted into explicit filtered algebraic objects;
2. equality or separation of resulting barcodes implies equality or separation of spectral data;
3. the construction is algorithmic and verified;
4. the theory reaches across domains: arithmetic geometry, linear recurrences, spectral reconstruction, persistence, and statistical identifiability.

---

## Precise formal target

Define a new structure encoding arithmetic counting data and its persistence profile. At minimum, introduce a novel object along the following lines.

### New definition target
A finite arithmetic spectral model over a commutative ring \(R\):

- a finite multiset of weights/eigenvalues \(\alpha_i\),
- a count sequence \(N_r = \sum_i \alpha_i^r\),
- a filtration extracted from valuation growth, finite differences, Hankel ranks, or thresholded amplitudes.

A promising formal prototype is a **Hankel persistence profile** built from a sequence \(a : \mathbb N \to R\), where the \(n\)-th stage is the span/rank/kernel data of the Hankel matrix
\[
H_n(a) = (a_{i+j})_{0\le i,j < n}.
\]
This is already mathematically deep: finite sums of exponentials are characterized by finite Hankel rank, and the annihilating polynomial recovers the underlying spectral data.

You should define something like:

```lean
structure ArithmeticSignal (R : Type*) [CommRing R] where
  coeff : ℕ → R

def hankelMatrix {R : Type*} [CommRing R] (a : ℕ → R) (n : ℕ) : Matrix (Fin n) (Fin n) R :=
  fun i j => a (i.1 + j.1)

def hankelRankProfile {R : Type*} [Field R] (a : ℕ → R) : ℕ → ℕ :=
  fun n => Module.finrank R <| Matrix.colSpace (hankelMatrix a n)

def powerSumSignal {R : Type*} [CommRing R] (α : Fin m → R) : ℕ → R :=
  fun r => ∑ i, (α i)^r
```

If finite-dimensional rank is technically awkward, use kernel stabilization, linear dependence of shifted windows, or existence of linear recurrences. The key is to define a genuine new concept, not merely repackage an existing one.

---

## Exact theorem statements to target

You need at least 3 substantial theorems. Here is a coherent package that would already be field-opening if formalized cleanly.

### Theorem 1: Finite spectral signals satisfy a canonical linear recurrence
For a finite family of scalars \(\alpha_1,\dots,\alpha_m\), the power-sum sequence \(a_r=\sum_i \alpha_i^r\) satisfies a linear recurrence whose characteristic polynomial is \(\prod_i (T-\alpha_i)\).

**Mathematical statement**
Let \(R\) be a field, \(\alpha : \mathrm{Fin}\,m \to R\), and let
\[
P(T)=\prod_{i=0}^{m-1}(T-\alpha_i).
\]
Writing
\[
P(T)=\sum_{k=0}^m c_k T^k,
\]
the sequence \(a_n=\sum_i \alpha_i^n\) satisfies
\[
\sum_{k=0}^m c_k\, a_{n+k}=0 \qquad \forall n\in\mathbb N.
\]

**Lean-style target**
```lean
theorem powerSum_satisfies_charpoly_recurrence
  {R : Type*} [Field R] {m : ℕ} (α : Fin m → R) :
  ∃ c : Fin (m+1) → R,
    (∀ n : ℕ, ∑ k : Fin (m+1), c k * powerSumSignal α (n + k.1) = 0)
    ∧ Polynomial.natDegree
        (∑ k : Fin (m+1), Polynomial.C (c k) * Polynomial.X^(k.1)) = m
```

A more realistic formal version may package the coefficients via `Polynomial` and use a theorem about a root annihilating geometric progressions.

**Why it matters**
This is the arithmetic-signal analogue of “spectral support implies finite complexity.” It is the algebraic hinge connecting point counts to persistence via finite-dimensional reconstruction.

---

### Theorem 2: Hankel rank is bounded by spectral support, with equality under distinctness
If \(a_n=\sum_{i=1}^m \alpha_i^n\), then the Hankel rank is at most \(m\); if the \(\alpha_i\) are pairwise distinct, then for sufficiently large truncation the rank is exactly the number of distinct eigenvalues.

**Mathematical statement**
Let \(R\) be a field and \(a_n=\sum_i \alpha_i^n\). Then:
1. \(\operatorname{rank}(H_n(a)) \le m\) for all \(n\).
2. If the \(\alpha_i\) are pairwise distinct, then for all \(n \ge m\),
   \[
   \operatorname{rank}(H_n(a)) = m.
   \]

This is essentially a Vandermonde factorization:
\[
H_n(a)=V_n D V_n^\top,
\]
where \(V_n=(\alpha_j^i)\).

**Lean-style target**
```lean
theorem hankelRank_le_card_spectral
  {R : Type*} [Field R] {m n : ℕ} (α : Fin m → R) :
  hankelRankProfile (powerSumSignal α) n ≤ m

theorem hankelRank_eq_card_of_pairwiseDistinct
  {R : Type*} [Field R] {m n : ℕ} (α : Fin m → R)
  (hα : Function.Injective α) (hn : m ≤ n) :
  hankelRankProfile (powerSumSignal α) n = m
```

You may need to express rank as `Matrix.rank` instead of `finrank colSpace`, depending on available Mathlib lemmas.

**Why it matters**
This is the first rigorous “barcode detects spectrum size” theorem. Even before slopes, it says that a persistence-like rank profile extracts spectral complexity from arithmetic counts.

---

### Theorem 3: Equality of sufficiently long power sums implies equality of spectral multisets
If two finite multisets of pairwise distinct eigenvalues give the same power sums for enough consecutive indices, then the multisets are equal.

**Mathematical statement**
Let \(R\) be a characteristic-zero field. Suppose \(\alpha_1,\dots,\alpha_m\) and \(\beta_1,\dots,\beta_m\) are pairwise distinct families in \(R\), and
\[
\sum_i \alpha_i^r = \sum_i \beta_i^r \qquad \text{for } r=0,1,\dots,2m-1.
\]
Then the multisets \(\{\alpha_i\}\) and \(\{\beta_i\}\) are equal.

This is Newton/Vandermonde/Prony identifiability.

**Lean-style target**
```lean
theorem powerSums_determine_multiset
  {R : Type*} [Field R] [CharZero R] {m : ℕ}
  (α β : Fin m → R)
  (hα : Function.Injective α) (hβ : Function.Injective β)
  (hEq : ∀ r < 2*m, powerSumSignal α r = powerSumSignal β r) :
  α '' Set.univ = β '' Set.univ
```

If image-set equality is awkward because of cardinality/multiplicity, use equality of root multisets of the corresponding characteristic polynomials.

**Why it matters**
This is the identifiability theorem that makes the whole program scientifically serious. It says finite arithmetic data can reconstruct spectral content.

---

### Theorem 4: Arithmetic persistence separation theorem
Define a persistence profile \(P_a(n)\) from the Hankel ranks or from stabilization of recurrence spaces. Prove that if two finite spectral signals have different numbers of distinct eigenvalues, then their profiles differ; more strongly, if their spectral multisets differ under the identifiability hypotheses, then the profiles differ at some stage \(n\le 2m\).

**Lean-style target**
```lean
def arithmeticPersistenceProfile {R : Type*} [Field R] (a : ℕ → R) : ℕ → ℕ :=
  hankelRankProfile a

theorem persistenceProfile_separates_distinct_spectra
  {R : Type*} [Field R] [CharZero R] {m : ℕ}
  (α β : Fin m → R)
  (hα : Function.Injective α) (hβ : Function.Injective β)
  (hne : α '' Set.univ ≠ β '' Set.univ) :
  ∃ n ≤ m, arithmeticPersistenceProfile (powerSumSignal α) n ≠
           arithmeticPersistenceProfile (powerSumSignal β) n
```

If this exact statement is too strong, prove a weaker but rigorous substitute:
- distinct support cardinalities imply profile inequality;
- equal profiles up to stage \(m\) imply equal recurrence order;
- profile + initial values determine the signal.

**Why it matters**
This is the first genuine bridge from persistence-style invariants to arithmetic spectral reconstruction.

---

## Arithmetic specialization target

After proving the abstract spectral theorems, instantiate them for arithmetic point-count models of low-dimensional varieties where the count formula is explicit.

### Elliptic curve prototype
For an elliptic curve \(E/\mathbf F_q\),
\[
|E(\mathbf F_{q^r})| = q^r + 1 - \alpha^r - \beta^r,
\quad \alpha\beta=q.
\]
Formally, define the normalized middle signal
\[
M_E(r)=q^{-r/2}(q^r+1-|E(\mathbf F_{q^r})|),
\]
or simply abstract the middle term \(a_r=\alpha^r+\beta^r\) over a field extension. Prove the recurrence and rank statements for this arithmetic signal.

**Lean-style target**
```lean
def ellipticMiddleSignal {R : Type*} [CommRing R] (q α β : R) : ℕ → R :=
  fun r => α^r + β^r

theorem ellipticMiddleSignal_recurrence
  {R : Type*} [Field R] (q α β : R) (hq : α * β = q) :
  ∀ n : ℕ,
    ellipticMiddleSignal q α β (n+2)
      - (α + β) * ellipticMiddleSignal q α β (n+1)
      + q * ellipticMiddleSignal q α β n = 0
```

This is a concrete arithmetic theorem with nontrivial algebraic proof. It becomes a certified algorithmic extractor of the Frobenius trace from counts.

---

## Most promising proof strategies

You must provide and pursue 2–3 strategies, not just one. Here are the right ones.

### Strategy A: Vandermonde/Hankel factorization
**Best overall strategy.**

1. Define \(V_n(i,j)=\alpha_j^i\) and show
   \[
   H_n(a)=V_n \, D \, V_n^\top
   \]
   where \(D\) is diagonal with entries \(1\) or multiplicities.
2. Deduce rank bounds from rank submultiplicativity.
3. Under pairwise distinctness and \(n\ge m\), use invertibility/full column rank of the Vandermonde matrix to get exact rank.

Why this is most promising:
- It naturally connects spectral data to a persistence invariant.
- It yields both upper and lower rank bounds.
- It is computationally meaningful and aligns with the demo pipeline.

Likely Lean ingredients:
- `Matrix.mul_apply`, `Fin.sum_univ_*`, `pow_add`,
- rank lemmas for matrix products,
- determinant/non-singularity of Vandermonde matrices if available, or a custom injectivity proof for columns.

### Strategy B: Linear recurrence / annihilating polynomial / Newton identities
1. Form the polynomial \(P(T)=\prod_i (T-\alpha_i)\).
2. Use \(P(\alpha_i)=0\) to derive
   \[
   \sum_k c_k \alpha_i^{n+k}=0
   \]
   for each \(i\), then sum over \(i\).
3. Show the recurrence order is minimal under distinctness, then identify the spectral multiset from the minimal polynomial or from Newton identities.

Why it is strong:
- It directly formalizes “point counts determine spectral data.”
- It can avoid heavy matrix rank machinery if rank becomes difficult.
- It is ideal for proving identifiability from finitely many moments/power sums.

Likely Lean ingredients:
- polynomial evaluation,
- `Finset` products and sums,
- induction on degree or cardinality,
- `calc` chains and `field_simp` in characteristic zero settings.

### Strategy C: Shift-invariant subspace / persistence via stabilization
1. Consider the span of shifted windows
   \[
   W_n = \mathrm{span}\{(a_k,\dots,a_{k+n-1}) : k\ge 0\}.
   \]
2. Show \(W_n\) stabilizes exactly at the recurrence order.
3. Define the persistence profile by \(n \mapsto \dim W_n\), and prove separation/identifiability theorems from stabilization behavior.

Why it is valuable:
- It is conceptually closer to persistent homology and filtered complexes.
- It avoids some low-level matrix details by using submodule spans.
- It may be easier to phrase functorially.

Why it is probably second-best:
- More abstract linear algebra can become cumbersome in Lean.
- Rank/Hankel matrices likely give cleaner computation and easier demos.

---

## Cross-domain connections you must explicitly build into the development

At least one theorem must connect this domain to another field in a mathematically real way, not by analogy.

### 1. Arithmetic geometry + signal processing / system identification
Finite sums of Frobenius eigenvalue powers are exactly exponential sums, the same objects reconstructed by Prony’s method in inverse problems. Formalize this bridge:
- point counts \(\leftrightarrow\) moments,
- Frobenius eigenvalues \(\leftrightarrow\) spectral frequencies,
- Hankel rank \(\leftrightarrow\) model order.

A theorem of identifiability from truncated counts is simultaneously an arithmetic theorem and a theorem in sparse spectral recovery.

### 2. Arithmetic geometry + topological data analysis
Your persistence profile is not metaphorical: it is a filtered invariant extracted from arithmetic data. Even if you use rank profiles rather than full homology barcodes, prove a theorem showing monotonicity/stabilization:
```lean
theorem arithmeticPersistenceProfile_monotone ...
theorem arithmeticPersistenceProfile_eventually_constant_iff_linearRecurrence ...
```
This is the conceptual seed of “motivic persistence.”

### 3. Arithmetic geometry + statistical physics / random matrix heuristics
State and computationally probe a conjecture that in natural random families the persistence profile separates non-isogenous factors with probability tending to \(1\). You need not formalize random matrix theory, but you should articulate the bridge:
- Frobenius spectra in families behave statistically like eigenvalue ensembles;
- persistence collisions should be rare because moment collisions define thin algebraic conditions.

This belongs in `FUTURE_DIRECTIONS.md` and in the conjectural section of `RESEARCH_PAPER.md`.

---

## Conjecture with falsifiable computational prediction

You must state and test at least one explicit conjecture.

### Conjecture: finite-window arithmetic persistence identifies simple spectral support generically
For each \(m\), there exists \(R(m)\) such that if \(\alpha,\beta\) are pairwise distinct \(m\)-tuples in a characteristic-zero field and
\[
\operatorname{arithmeticPersistenceProfile}( \sum_i \alpha_i^\bullet )
=
\operatorname{arithmeticPersistenceProfile}( \sum_i \beta_i^\bullet )
\quad \text{for all } n \le R(m),
\]
then generically the multisets \(\{\alpha_i\}\) and \(\{\beta_i\}\) agree.

**Testable prediction**
For random tuples over \(\mathbb Q\), finite fields lifted to characteristic zero, or explicit Frobenius polynomials from elliptic curves/abelian surfaces/K3 toy models, collisions of profiles without spectral equality should become exponentially rare as \(R\) grows.

**Refutation criterion**
An infinite explicit family of distinct spectral multisets with identical persistence profiles up to all truncation levels relevant to the reconstruction theorem refutes the generic identifiability claim.

You should implement a computational search for such collisions in `demo.py`.

---

## Lean 4 formalization guidance

You must include precise theorem statements with plausible Lean signatures. Adjust names/types to Mathlib realities, but keep the mathematical content.

Useful design choices:
- Work over a field first, especially `ℚ`, `Rat`, or an abstract `Field R`.
- Separate abstract spectral theorems from arithmetic instantiations.
- If direct matrix rank is difficult, define profile via “least recurrence length”:
  ```lean
  def recurrenceOrder {R : Type*} [Field R] (a : ℕ → R) : ℕ := ...
  ```
  Then prove:
  ```lean
  theorem recurrenceOrder_powerSum_le ...
  theorem recurrenceOrder_powerSum_eq_of_injective ...
  theorem equal_powerSums_up_to_bound_implies_equal_charpoly ...
  ```
- Use `Multiset` or root multisets of polynomials if direct equality of indexed families is awkward.

---

## Expected nontrivial proof tactics

Your file must contain at least 3 deep theorems using real proof architecture. Aim to visibly use:
- induction on `m` or polynomial degree,
- `rcases` for decomposition of finite families or recurrence witnesses,
- `by_contra` for minimality or injectivity/rank arguments,
- `field_simp` for Vandermonde determinant or rational-function manipulations,
- multi-step `calc` blocks for recurrence derivations.

Do not hide the mathematics behind automation.

---

## Suggested file architecture

Create a focused development, e.g.
- `MotivicPersistenceSpectrum/ArithmeticSignal.lean`
- `MotivicPersistenceSpectrum/HankelProfile.lean`
- `MotivicPersistenceSpectrum/PowerSumReconstruction.lean`
- `MotivicPersistenceSpectrum/EllipticPrototype.lean`

Possible definition roster:
```lean
structure ArithmeticSignal (R : Type*) [CommRing R] where
  seq : ℕ → R

def powerSumSignal ...
def hankelMatrix ...
def hankelRankProfile ...
def recurrenceOrder ...
def arithmeticPersistenceProfile ...
def ellipticMiddleSignal ...
```

Possible theorem roster:
```lean
theorem powerSum_satisfies_charpoly_recurrence ...
theorem hankelRank_le_card_spectral ...
theorem hankelRank_eq_card_of_pairwiseDistinct ...
theorem powerSums_determine_charpoly ...
theorem powerSums_determine_multiset ...
theorem arithmeticPersistenceProfile_monotone ...
theorem arithmeticPersistenceProfile_eventually_constant ...
theorem ellipticMiddleSignal_recurrence ...
```

---

## Application keywords

Include these explicitly in the paper and article:
- arithmetic geometry
- Weil zeta function
- Frobenius eigenvalues
- Hankel matrix
- Prony reconstruction
- persistence barcode
- topological data analysis
- spectral identifiability
- motivic decomposition
- isogeny detection
- random matrix heuristics
- inverse problems
- exponential sums
- linear recurrence
- arithmetic signal processing

---

## Revolutionary significance

If you can prove even the prototype theorems above, you will have formalized the first rigorous corridor between point-count arithmetic and persistence-style spectral extraction. This would not merely organize known facts. It would suggest a new doctrine:

> arithmetic data can be processed as a filtered topological signal whose stable features encode motivic structure.

That doctrine opens several fields at once:
- scalable arithmetic signatures for isogeny and motive comparison,
- persistence-inspired invariants of zeta functions,
- certified spectral reconstruction algorithms for arithmetic datasets,
- new interactions between TDA, number theory, and inverse spectral methods.

This is exactly the kind of result that makes other mathematicians say, “I did not know those subjects could talk to each other.”

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean code** with the new definitions and at least 3 substantial theorems proven with nontrivial tactics, minimizing `sorry`.
2. **A verified algorithm or computational method**:
   - implement spectral reconstruction from initial power sums or Hankel data,
   - prove correctness for the formal model under explicit hypotheses.
3. **`demo.py`**:
   - compute count-derived sequences for explicit toy families (at least elliptic-curve-style sequences, and if feasible abelian-surface or K3-inspired synthetic data),
   - build the persistence/rank profile,
   - compare profiles against known spectral parameters,
   - search for collisions and display them interactively.
4. **`RESEARCH_PAPER.md`**:
   - standalone scientific exposition,
   - state the definitions, main theorems, proof ideas, computational experiments, significance, and limitations,
   - understandable without reading code.
5. **`ARTICLE.md`**:
   - Scientific American style,
   - explain the ideas, why converting arithmetic counts into topological signatures is surprising, and what it could enable,
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`**:
   include 3–5 original research directions, each with:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   At least one direction must bridge to a different domain, such as inverse problems, random matrix theory, or topological signal processing.

Be bold. The prototype is enough if it is mathematically sharp, formally real, algorithmically verified, and conceptually unmistakable. The right result here is not “some point-count lemma.” It is the birth of **motivic persistence theory** in a form that can grow.

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

Research domain: Speculative
Research mode: prove
