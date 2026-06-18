Soli Deo Gloria

## Assignment: Direction 1: Dynamical Ramanujan Conjecture for Prime Squaring Graphs

**Mode:** prove

Prove genuinely new, non-trivial theorems about the spectral and dynamical structure of the squaring graph over finite fields and residue rings. Build explicitly on catalog results, especially:

- `Pythagorean/SpectralGap.lean`
  - `prime_sq_idempotents_eq_zero_or_one`
  - `prime_idempotentSubtype_card`

The mission is not to numerically check a folklore pattern. The mission is to extract a new arithmetic-spectral principle: that the dynamics of a single polynomial endomorphism, when restricted to prime fields, generates expansion behavior comparable to classical Ramanujan objects, while composites fail for structural reasons tied to idempotents and basin decomposition.

---

## Core Vision

The naive undirected graph obtained from the functional graph of `x ↦ x^2` is not regular, so the classical Ramanujan inequality for `Δ`-regular graphs cannot be transplanted blindly. The real breakthrough is to identify the **correct regular core** and then prove a sharp spectral comparison theorem showing that the prime case inherits square-root cancellation from multiplicative character theory.

You should therefore formalize a **prime squaring residue graph** capturing the multiplicative dynamical core, and prove that its spectrum is controlled by quadratic character sums. Then connect this to the full undirected squaring graph by a decomposition theorem separating the trivial basin at `0` from the multiplicative part.

This would open a new field: **arithmetic dynamics as a source of expander and near-Ramanujan phenomena**, with direct bridges to character sums, finite field dynamics, and spectral rigidity of algebraically defined graphs.

---

## Precise Mathematical Targets

### New definitions you should introduce

You must define at least one genuinely new structure. The most promising is:

1. **Multiplicative squaring residue graph** on `Units (ZMod p)`:
   - vertices are units mod `p`
   - connect `x ~ y` iff `x^2 = y` or `y^2 = x`

2. **Quadratic-residue quotient graph** on the exponent group `ZMod (p-1)` modulo the involution induced by doubling:
   - this turns the nonlinear map on field elements into a linear map on exponents relative to a primitive root
   - this is the correct algebraic lens for spectral analysis

3. **Prime squaring core**:
   - the induced subgraph of the undirected squaring graph on periodic or preperiodic nonzero points
   - for prime `p`, this should collapse to the multiplicative graph because every nonzero element is periodic/preperiodic under exponent doubling

These definitions are not cosmetic. They isolate the part of the graph where arithmetic, not the sink at zero, governs the spectrum.

---

## Precise theorem statements to aim for

You need at least 3 substantial theorems. Here is the recommended theorem suite.

### Theorem 1: Prime decomposition of the squaring graph
For an odd prime `p`, the undirected squaring graph on `ZMod p` splits as an isolated dynamical basin at `0` plus the multiplicative squaring core on units.

**Mathematical statement**
For odd prime `p`, the adjacency relation on `ZMod p` satisfies:
- `0` is adjacent only to `0` and possibly the idempotent obstructions collapse to `{0,1}` by primality
- all nonzero adjacency is contained in the unit group
- the induced graph on nonzero vertices is exactly the unit squaring graph

This is where you should explicitly use `prime_sq_idempotents_eq_zero_or_one` and `prime_idempotentSubtype_card` to kill composite-style branching caused by nontrivial idempotents.

**Lean 4 target signature sketch**
```lean
theorem prime_sqGraph_nonzero_induced_eq_unitGraph
    {p : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2) :
    inducedSubgraph
      (fun x : ZMod p => x ≠ 0)
      (sqUndirectedAdj (R := ZMod p))
    ≃g
    unitSqGraph (R := ZMod p) := by
  ...
```

If graph isomorphism infrastructure is too heavy, weaken to an adjacency equivalence theorem:

```lean
theorem prime_sqUndirectedAdj_nonzero_iff_unitSqAdj
    {p : ℕ} (hp : Nat.Prime p) {x y : ZMod p}
    (hx : x ≠ 0) (hy : y ≠ 0) :
    sqUndirectedAdj (R := ZMod p) x y ↔
      unitSqAdj (R := ZMod p) ⟨x, isUnit_iff_ne_zero.mpr hx⟩ ⟨y, isUnit_iff_ne_zero.mpr hy⟩ := by
  ...
```

### Theorem 2: Degree classification in the prime core
For odd prime `p`, every nonzero vertex in the multiplicative squaring graph has degree determined by whether it is a quadratic residue and whether loops are counted. In particular, the graph is “almost regular” with a rigid two-level degree pattern.

This theorem is crucial because it replaces the false regularity assumption by an exact degree law.

**Mathematical statement**
For `x ∈ (ZMod p)ˣ`:
- `x` has an outgoing squaring edge to `x^2`
- `x` has two square roots iff `x` is a quadratic residue
- `x` has no square roots iff `x` is a nonresidue
Hence the undirected degree is:
- one value on residues,
- another on nonresidues,
modulo loop conventions and the exceptional vertices `1` and `-1`.

**Lean 4 target signature sketch**
```lean
theorem unit_sq_preimage_card_eq
    {p : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2)
    (x : Units (ZMod p)) :
    Fintype.card {y : Units (ZMod p) // y^2 = x} =
      if IsQuadraticResidue x then 2 else 0 := by
  ...
```

and a degree consequence:
```lean
theorem unitSqGraph_degree_formula
    {p : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2)
    (x : Units (ZMod p)) :
    degree (unitSqGraph (R := ZMod p)) x =
      baseOutDegree + if IsQuadraticResidue x then 2 else 0 - loopCorrection x := by
  ...
```

Even if the exact combinatorial API for graph degree is inconvenient, prove the finite-cardinality version on neighbor sets.

### Theorem 3: Character-sum spectral control / Paley comparison
This is the central breakthrough theorem. Show that the adjacency operator of the multiplicative squaring graph is conjugate, or at least spectrally comparable, to an operator built from the doubling map on the cyclic exponent group. Then derive a nontrivial bound on nontrivial eigenvalues.

There are two acceptable levels of ambition:

#### Strong form
For primes `p ≡ 1 [MOD 4]`, the residue-induced adjacency operator decomposes into quadratic-character eigenspaces, and every nontrivial eigenvalue `λ` satisfies a square-root bound of the form
`|λ| ≤ C * sqrt p`
for an explicit absolute constant `C`.

#### Intermediate form
Prove that the adjacency operator is unitarily equivalent to a sparse convolution-plus-permutation operator on `ZMod (p-1)`, and derive a rigorous spectral inclusion or norm bound sufficient to imply a nontrivial expansion estimate.

**Lean 4 target signature sketch**
```lean
theorem unitSqGraph_secondEigenvalue_bound
    {p : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2) :
    secondEigenvalue (unitSqGraph (R := ZMod p)) ≤ C * Real.sqrt p := by
  ...
```

If full eigenvalue formalization is too ambitious in one cycle, prove an operator norm theorem on the orthogonal complement of constants:

```lean
theorem unitSqAdj_operator_norm_le_sqrt_bound
    {p : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2) :
    ‖restrictToMeanZero (unitSqAdjOperator (R := ZMod p))‖ ≤ C * Real.sqrt p := by
  ...
```

This is mathematically stronger than ad hoc matrix computations and is the right theorem if Mathlib’s spectral API is more mature for linear maps than for graph eigenvalues.

### Theorem 4: Composite obstruction via idempotent fragmentation
You need one theorem that proves primes are structurally exceptional. Show that nontrivial idempotents in `ZMod n` force decomposition or localized low-expansion cuts in the squaring graph.

**Mathematical statement**
If `n` is composite and `ZMod n` has a nontrivial idempotent `e`, then the squaring graph admits a nontrivial invariant or nearly invariant partition induced by `e`, obstructing prime-style spectral expansion.

This theorem converts algebraic ring decomposition into a graph bottleneck statement.

**Lean 4 target signature sketch**
```lean
theorem nontrivial_idempotent_yields_sqGraph_cut
    {n : ℕ} (e : ZMod n)
    (he : e * e = e) (h0 : e ≠ 0) (h1 : e ≠ 1) :
    ∃ S : Finset (ZMod n),
      S.Nonempty ∧
      S.card < Fintype.card (ZMod n) ∧
      sqGraphBoundaryRatio (R := ZMod n) S ≤ compositeCutBound e := by
  ...
```

This theorem is where the catalog prime-idempotent results become a launching pad rather than an endpoint.

---

## Refined Conjecture

Do **not** state the original conjecture in its raw form without qualification, because the full undirected squaring graph is not regular. State the corrected falsifiable conjecture:

### Conjecture A: Prime squaring core is asymptotically Ramanujan
For odd primes `p`, let `G_p^×` be the multiplicative squaring residue graph on `Units (ZMod p)`. Then there exists an explicit normalization under which the nontrivial spectrum of `G_p^×` satisfies the Ramanujan-type bound
\[
|\lambda| \le 2\sqrt{d_p-1} + o(1)
\]
or, in irregular form, satisfies the optimal square-root scale
\[
|\lambda_2| \ll \sqrt{d_p}
\]
with constants independent of `p`.

### Conjecture B: Prime/composite spectral separation
Among all odd `n` of comparable size, primes maximize the normalized spectral gap of the squaring core, while composites with many idempotent factors exhibit systematically smaller gap due to basin fragmentation.

### Computational falsifiability
A conjecture is only scientific if it can fail. Your test must:
- compute adjacency matrices for `n ≤ 10^4`
- isolate the multiplicative core and the full graph separately
- compare:
  - second eigenvalue
  - spectral gap
  - Cheeger proxy
  - connected component profile
- search for a prime violating the square-root bound
- search for composites with unexpectedly large gap

A single prime with `λ₂ > C√p` for the predicted constant disproves Conjecture A.

---

## Proof architecture: 3 viable strategies

You must include 2–3 strategy paths in the writeup and indicate which is most promising.

### Strategy A: Exponent linearization on the cyclic unit group
**Most promising.**

For prime `p`, the multiplicative group `(ZMod p)ˣ` is cyclic of order `p-1`. Choose a primitive root `g`. Write each unit as `g^k`. Then the map `x ↦ x^2` becomes `k ↦ 2k mod (p-1)` on exponents. The undirected adjacency becomes:
\[
k \sim \ell \iff \ell \equiv 2k \pmod{p-1} \text{ or } k \equiv 2\ell \pmod{p-1}.
\]
This converts arithmetic dynamics into a linear graph on a cyclic group.

**Steps**
1. Prove the graph on units is transported by discrete log to a graph on `ZMod (p-1)`.
2. Express adjacency operator as `T = U_2 + U_2^*` or a variant, where `U_2` is the permutation/partial-averaging operator induced by doubling.
3. Diagonalize using additive characters on the cyclic group when possible, or decompose by gcd strata if doubling is not invertible on `p-1`.

**Why promising**
It turns nonlinear dynamics into linear algebra on a finite abelian group. This is the cleanest route to exact or near-exact spectral formulas.

### Strategy B: Quadratic characters and Paley comparison
Use the indicator of the quadratic residues and compare the squaring graph to a Paley-type graph or a sum of multiplicative character kernels. The point is not literal graph equality; the point is that both adjacency operators are controlled by the same character sums.

**Steps**
1. Rewrite square-root counts using the quadratic character `χ`:
   \[
   \#\{y : y^2 = x\} = 1 + \chi(x)
   \]
   on units, up to exceptional conventions.
2. Express adjacency or two-step walk counts in terms of sums involving `χ`.
3. Invoke Weil-style square-root cancellation heuristics, and formalize whatever finite-field character estimate is reachable in Lean.

**Why promising**
This connects the problem to classical spectral graph theory over finite fields and gives the conceptual Ramanujan bridge.

### Strategy C: Two-step walk operator and trace method
Instead of diagonalizing `A`, study `A^2` or higher moments. Count closed walks by solving polynomial congruences. Then bound the nontrivial spectrum using trace inequalities.

**Steps**
1. Compute or bound `tr(A^2)`, `tr(A^4)`, or `tr((A - Π)^2k)`.
2. Translate closed walk counts into congruence counts like `x^{2^m} = x`.
3. Use prime rigidity and cyclicity of units to derive exact formulas or asymptotics.

**Why promising**
This is robust if direct spectral formalization is difficult. It may yield the first rigorous nontrivial eigenvalue bounds even without full diagonalization.

---

## Cross-domain connections you must explicitly develop

You are required to include at least one theorem bridging domains. Here are the strongest bridges.

### 1. Number theory ↔ spectral graph theory
The graph is generated by a polynomial endomorphism over a finite field, but its expansion is governed by multiplicative character cancellation. This is the central bridge.

### 2. Arithmetic dynamics ↔ algebraic geometry
The map `x ↦ x^2` is a dynamical system on the affine line over `F_p`. Closed walk counts correspond to point counts on algebraic correspondences like
\[
y = x^2,\quad x = y^2,\quad x^{2^m} = x.
\]
This suggests a Weil-conjecture viewpoint: spectral cancellation emerges from counting points on iterated correspondence varieties.

A concrete theorem target:
```lean
theorem prime_sq_closed_walks_eq_fixed_points_of_power_map
    {p m : ℕ} (hp : Nat.Prime p) :
    closedWalkCount (sqUndirectedAdj (R := ZMod p)) m =
      fixedPointCount (fun x : ZMod p => x^(2^m)) + correctionTerm p m := by
  ...
```

### 3. Number theory ↔ information flow / mixing
Interpret the normalized adjacency operator as a Markov-type transport on residues. Then prime fields become “high-entropy mixers” while composite rings retain memory because idempotents create hidden coordinates.

Possible theorem:
```lean
theorem idempotent_factor_preserves_memory
    {n : ℕ} (e : ZMod n)
    (he : e * e = e) (h0 : e ≠ 0) (h1 : e ≠ 1) :
    ∃ f : ZMod n → ℝ,
      f ≠ 0 ∧
      meanZero f ∧
      ‖sqTransferOperator (R := ZMod n) f‖ ≥ memoryRetentionBound * ‖f‖ := by
  ...
```

This is a serious cross-domain connection: algebraic decomposition becomes a lower bound on retained information under nonlinear dynamics.

---

## Lean-specific formalization guidance

You asked for precise theorem statements with Lean 4 type signatures. Keep them realistic. If full graph-spectrum APIs become obstructive, formalize the operator-theoretic version first and derive graph corollaries later.

Recommended object hierarchy:

```lean
def sqMap (R) [Monoid R] : R → R := fun x => x^2

def sqUndirectedAdj (R) [Monoid R] : R → R → Prop :=
  fun x y => x^2 = y ∨ y^2 = x

def unitSqAdj (R) [Monoid R] : Units R → Units R → Prop :=
  fun x y => x^2 = y ∨ y^2 = x

def sqPreimages {R} [CommMonoid R] (x : R) := {y : R // y^2 = x}
```

For the prime-field setting:
```lean
def primeSqCore (p : ℕ) := {x : ZMod p // x ≠ 0}
```

For spectral work, likely use finite matrices:
```lean
def adjMatrixSqGraph (p : ℕ) : Matrix (ZMod p) (ZMod p) ℝ := ...
def adjMatrixUnitSqGraph (p : ℕ) : Matrix (Units (ZMod p)) (Units (ZMod p)) ℝ := ...
```

If necessary, define:
```lean
def secondEigenvalue (A : Matrix n n ℝ) : ℝ := ...
```
as a placeholder based on multiset of eigenvalues, then prove lemmas about bounds. Do not get trapped trying to instantiate the most abstract possible spectral framework.

---

## Deep proof tactics requirement

Your file must contain at least 3 theorems whose proofs genuinely use techniques like:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`

Recommended distribution:
1. A decomposition theorem using `rcases` on zero/nonzero and unit structure.
2. A preimage-cardinality theorem using `by_contra` and prime-field quadratic residue dichotomy.
3. A walk-count or operator theorem using multi-step `calc` and induction on iterate length.

Do not waste these on trivial lemmas.

---

## Concrete theorem candidates with proof-shape notes

### Candidate A
```lean
theorem prime_sq_fixed_points_eq_zero_or_one
    {p : ℕ} (hp : Nat.Prime p) {x : ZMod p}
    (hx : x^2 = x) :
    x = 0 ∨ x = 1 := by
  -- build directly on prime_sq_idempotents_eq_zero_or_one
```
Use as an entry lemma, not a flagship theorem.

### Candidate B
```lean
theorem prime_sqMap_preserves_units
    {p : ℕ} (hp : Nat.Prime p) {x : ZMod p} (hx : x ≠ 0) :
    x^2 ≠ 0 := by
  -- by_contra, use domain property of fields / zmod prime
```

### Candidate C
```lean
theorem prime_nonzero_sq_adj_closed
    {p : ℕ} (hp : Nat.Prime p) {x y : ZMod p}
    (hx : x ≠ 0) (hxy : sqUndirectedAdj (R := ZMod p) x y) :
    y ≠ 0 := by
  rcases hxy with h | h
  · ...
  · ...
```

### Candidate D
```lean
theorem sqpow_fixed_points_units_card
    {p m : ℕ} (hp : Nat.Prime p) :
    Fintype.card {x : Units (ZMod p) // x ^ (2^m - 1) = 1} =
      Nat.gcd (2^m - 1) (p - 1) := by
  ...
```
This is excellent: it ties dynamics to finite cyclic group theory and can feed trace bounds.

### Candidate E
```lean
theorem prime_sq_iterate_periodic_point_count
    {p m : ℕ} (hp : Nat.Prime p) :
    periodicPointCount (sqMap (ZMod p)) m =
      1 + Nat.gcd (2^m - 1) (p - 1) := by
  ...
```
This is a major theorem and likely very feasible. It is already nontrivial, arithmetic, and dynamical.

This theorem may become the foundation for spectral estimates via the trace method.

---

## Why this would be a breakthrough

If you prove even the intermediate spectral theorem rigorously, you will have created one of the first formally verified examples where:

- a **single polynomial dynamical system** over finite fields produces a family with expander-like spectral behavior;
- **prime rigidity** manifests not just in fixed points or orbit counts, but in the full operator spectrum;
- **composite failure** is explained structurally via idempotent-induced fragmentation.

This opens an entire program:
- polynomial expander dynamics over finite fields,
- arithmetic analogues of Ramanujan phenomena,
- spectral classification of functional graphs by ring-theoretic decomposition,
- dynamical correspondences analyzed via algebraic-geometric point counts.

This is not an extension. This is a new language for relating arithmetic dynamics to expansion theory.

---

## Application keywords

Include these explicitly in your paper and metadata:

- arithmetic dynamics
- Ramanujan graphs
- spectral graph theory
- finite fields
- quadratic residues
- character sums
- Paley graphs
- Weil bounds
- expander graphs
- nonlinear dynamics on finite rings
- idempotent decomposition
- composite obstruction
- operator norms
- trace method
- discrete logarithm linearization
- algebraic correspondences
- mixing and memory retention

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 substantial theorems, deep proofs, and at least one new definition.
2. **A verified algorithm or computational method**, not just theorem statements:
   - sparse construction of squaring graph adjacency matrices,
   - extraction of multiplicative core,
   - spectrum computation / approximation,
   - prime vs. composite comparison metrics.
3. **`demo.py`**:
   - interactive exploration for `n ≤ 10^4`,
   - plots of `λ₂`, spectral gap, component counts,
   - explicit counterexample search for the corrected conjectures.
4. **`FUTURE_DIRECTIONS.md`** with **3–5 falsifiable scientific hypotheses**.
   Each hypothesis must have:
   - precise statement,
   - what data/theorem would test it,
   - what outcome would refute it.
5. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - problem statement,
   - definitions,
   - main theorems,
   - proof ideas,
   - computational evidence,
   - significance,
   - next questions.
   Someone reading only this document must understand the discovery.
6. **`ARTICLE.md`** in Scientific American style:
   - vivid, accessible,
   - focused on the mathematics and its significance,
   - no emphasis on formal verification machinery.

---

## Nonnegotiable scientific standards

- Do **not** hide behind brute-force finite checks.
- Do **not** formalize only definitions and toy lemmas.
- Do **not** state the original Ramanujan claim naively for a nonregular graph without correcting the framework.
- Do **not** avoid the composite case: prime exceptionalism is only meaningful if you prove an obstruction theorem for composites.

---

## Minimum success criterion

A successful cycle must deliver at least:

1. a rigorous decomposition theorem for the prime squaring graph,
2. a nontrivial periodic-point or walk-count formula such as
   \[
   \#\mathrm{Per}_m(x \mapsto x^2 \text{ on } \mathbb{F}_p) = 1 + \gcd(2^m-1,p-1),
   \]
3. a first genuine spectral theorem: exact formula, operator conjugacy, or nontrivial eigenvalue bound,
4. a computational pipeline testing the corrected Ramanujan-type conjecture against primes and composites.

If you can prove the full square-root spectral bound, this becomes a field-opening result. If not, prove the operator-conjugacy and periodic-point formulas now, because they are the load-bearing beams for the next leap.

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
