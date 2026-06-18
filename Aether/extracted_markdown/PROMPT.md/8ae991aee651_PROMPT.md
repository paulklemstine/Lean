Soli Deo Gloria

## Assignment: Direction 2: CRT Product Bottleneck Theorem

**Mode:** prove

Prove a genuinely new product theorem for the dynamical squaring graph modulo a composite modulus, using CRT to turn arithmetic factorization into a rigorous bottleneck principle in spectral graph theory.

This must not be a cosmetic extension. The target is a theorem that explains, in a precise quantified way, why factorization creates dynamical obstructions: when `n = a * b` with `Nat.Coprime a b`, the squaring dynamics mod `n` inherits basin cuts from each factor, so expansion cannot improve under coprime multiplication. This is the arithmetic analogue of a tensor-product bottleneck principle.

The goal is to formalize the first robust **product-conductance upper bound** for the CRT-decomposed squaring system.

---

## Core Vision

The existing catalog already gives the decisive arithmetic ingredient:

- `Catalog/FINAL/Pythagorean/DynamicalSquaring.lean`:
  - `crt_squaring_equivariant`
- `Pythagorean/SpectralGap.lean`:
  - `arithmetic_fragmentation_theorem`
  - `sqBasin_disjoint_of_ne_idempotent`

Your task is to convert these from structural facts into a **quantitative obstruction theorem**: basin conductance for modulus `ab` is bounded above by a normalized minimum of the conductances for `a` and `b`, because a sparse cut in one factor lifts to a sparse cut in the CRT product.

If this succeeds, it opens a new field line: **arithmetic product expansion theory** for deterministic residue dynamics. It would show that factorization is not merely an algebraic decomposition but a geometric obstruction to mixing. That is a conceptual bridge from elementary number theory to Cheeger-type inequalities, product Markov chains, and statistical mechanics on arithmetic state spaces.

---

## Precise Theorem Targets

You should introduce a new formal object capturing the product-cut mechanism. Do **not** just state an inequality over an opaque existing definition. Define a new concept that makes the theorem natural.

### New definition requirement

Define at least one new concept along the following lines:

- `basinConductance`
- `liftedCut`
- `fiberBoundaryRatio`
- `CRTProductBottleneck`

For example, a promising definition is a normalized edge-boundary ratio for a subset of a squaring basin, with counting measure induced by the finite state space.

A possible Lean-facing shape:

```lean
def basinConductance (n : ℕ) : ℚ := ...
```

or, if the existing graph formalization is more set-theoretic,

```lean
def basin_boundary_ratio (n : ℕ) (S : Finset (ZMod n)) : ℚ := ...
def basinConductance (n : ℕ) : ℚ := sInf {q : ℚ | ∃ S, IsNontrivialBasinCut n S ∧ basin_boundary_ratio n S = q}
```

If `sInf` is too heavy for current infrastructure, use a finite minimum over a finite family of admissible cuts:

```lean
def admissibleBasinCuts (n : ℕ) : Finset (Finset (ZMod n)) := ...
def basinConductance (n : ℕ) : ℚ :=
  (admissibleBasinCuts n).inf' ... (fun S => basin_boundary_ratio n S)
```

The exact implementation may vary, but the concept must be mathematically meaningful and novel relative to the catalog.

---

## Main theorem: CRT bottleneck upper bound

A strong target theorem is:

> **Theorem (CRT Product Bottleneck).**  
> Let `a b : ℕ` with `2 ≤ a`, `2 ≤ b`, and `Nat.Coprime a b`. Then there exists an explicit normalization factor `κ(a,b) > 0` such that
> \[
> h_{\mathrm{basin}}(ab) \le \kappa(a,b)\,\min\big(h_{\mathrm{basin}}(a),\,h_{\mathrm{basin}}(b)\big).
> \]
> Moreover, if the squaring graph degree is preserved exactly under the CRT identification, one can take `κ(a,b)=1`.

A Lean 4 signature target:

```lean
theorem basinConductance_mul_le_norm_min
    {a b : ℕ}
    (ha : 2 ≤ a) (hb : 2 ≤ b) (hcop : Nat.Coprime a b) :
    basinConductance (a * b)
      ≤ normalizationFactor a b * min (basinConductance a) (basinConductance b) := by
  ...
```

and ideally the sharper theorem:

```lean
theorem basinConductance_mul_le_min
    {a b : ℕ}
    (ha : 2 ≤ a) (hb : 2 ≤ b) (hcop : Nat.Coprime a b)
    (hdeg : degree_preserving_under_crt a b) :
    basinConductance (a * b) ≤ min (basinConductance a) (basinConductance b) := by
  ...
```

If exact conductance is technically too ambitious, prove a finite-combinatorial precursor that still has real content:

```lean
theorem exists_product_cut_with_boundary_control
    {a b : ℕ}
    (ha : 2 ≤ a) (hb : 2 ≤ b) (hcop : Nat.Coprime a b) :
    ∀ Sa ∈ admissibleBasinCuts a,
      ∃ Sab ∈ admissibleBasinCuts (a * b),
        basin_boundary_ratio (a * b) Sab
          ≤ normalizationFactor a b * basin_boundary_ratio a Sa := by
  ...
```

This precursor is already nontrivial and enough to derive the global theorem by minimization.

---

## Second theorem: lifted cut theorem via CRT fibers

You need a theorem that explicitly constructs the bottleneck set upstairs from one downstairs.

> **Theorem (Fiber Lift of Basin Cuts).**  
> Under CRT, every admissible basin cut in modulus `a` lifts to an admissible basin cut in modulus `ab` by taking its full preimage under the projection `ZMod (ab) → ZMod a`, and the lifted boundary is controlled multiplicatively by the fiber size.

Lean target:

```lean
def crtLiftLeft {a b : ℕ} (hcop : Nat.Coprime a b) :
    Finset (ZMod a) → Finset (ZMod (a * b)) := ...

theorem boundary_ratio_crtLiftLeft_le
    {a b : ℕ}
    (ha : 2 ≤ a) (hb : 2 ≤ b) (hcop : Nat.Coprime a b) :
    ∀ S, IsAdmissibleBasinCut a S →
      IsAdmissibleBasinCut (a * b) (crtLiftLeft hcop S) ∧
      basin_boundary_ratio (a * b) (crtLiftLeft hcop S)
        ≤ normalizationFactorLeft a b * basin_boundary_ratio a S := by
  ...
```

This theorem is where `crt_squaring_equivariant` should do real work: it should let you identify one-step squaring edges upstairs with coordinatewise squaring downstairs, so boundary edges in the lifted set come only from boundary edges in the chosen factor.

This is not merely technical. It is the arithmetic heart of the product theorem.

---

## Third theorem: fragmentation forces deterioration

Use the spectral-gap side of the catalog to show that nontrivial idempotent decomposition creates multiple disjoint basins, hence canonical cuts with small conductance.

> **Theorem (Arithmetic Fragmentation Implies Bottleneck).**  
> If `n` has at least two distinct CRT idempotent basin components arising from coprime factorization, then `basinConductance n` is bounded above by the boundary ratio of one such component; in particular factorization produces a quantitative obstruction to expansion.

Lean target:

```lean
theorem arithmetic_fragmentation_gives_bottleneck
    {n : ℕ}
    (hn : 2 ≤ n) :
    HasNontrivialIdempotentFragmentation n →
    basinConductance n ≤ explicitFragmentationBound n := by
  ...
```

A stronger version linked directly to the catalog theorem is even better:

```lean
theorem arithmetic_fragmentation_mul_bound
    {a b : ℕ}
    (ha : 2 ≤ a) (hb : 2 ≤ b) (hcop : Nat.Coprime a b) :
    basinConductance (a * b) ≤ explicitFragmentationBound (a * b) := by
  ...
```

This theorem should use `arithmetic_fragmentation_theorem` and `sqBasin_disjoint_of_ne_idempotent` in an essential way, not as decoration. The point is to show that the abstract existence of disjoint basins yields an actual sparse cut.

---

## Optional fourth theorem: exact product formula in a rigid regime

If the finite graph model is sufficiently clean, aim for a breakthrough strengthening:

> **Theorem (Exact Product Conductance Formula, Restricted Regime).**  
> If the admissible basin family is closed under rectangular lifts and the squaring graph on `ZMod (ab)` is CRT-isomorphic to the categorical product of factor squaring graphs, then
> \[
> h_{\mathrm{basin}}(ab)=\min(h_{\mathrm{basin}}(a),h_{\mathrm{basin}}(b)).
> \]

Lean target:

```lean
theorem basinConductance_mul_eq_min
    {a b : ℕ}
    (ha : 2 ≤ a) (hb : 2 ≤ b) (hcop : Nat.Coprime a b)
    (hprod : exact_crt_product_structure a b) :
    basinConductance (a * b) = min (basinConductance a) (basinConductance b) := by
  ...
```

This would be a genuine field-opening result: an exact arithmetic Cheeger law.

---

## Proof Architecture: 3 viable strategies

### Strategy A: Direct lift-of-cuts through CRT equivariance
**Most promising.**

1. Use `crt_squaring_equivariant` to show that under the CRT equivalence, the squaring transition on `ZMod (a*b)` acts coordinatewise on `ZMod a × ZMod b`.
2. Given a low-boundary admissible cut `S` in modulus `a`, define its full preimage `S × univ` upstairs.
3. Prove by explicit boundary counting that boundary size scales by fiber cardinality while volume scales by the same factor, yielding the normalized inequality.

Why this is best:
- It turns the theorem into finite combinatorics rather than delicate spectral theory.
- It leverages exactly the strongest catalog theorem already available.
- It should naturally require `rcases`, multi-step `calc`, finite set cardinality lemmas, and nontrivial rewriting via CRT equivalences.

Key difficult substeps:
- Show admissibility of the lifted set.
- Control edge boundary under coordinatewise squaring.
- Normalize correctly depending on whether conductance is edge-normalized, degree-normalized, or volume-normalized.

### Strategy B: Basin decomposition + canonical sparse cuts from idempotents
1. Use `arithmetic_fragmentation_theorem` to produce nontrivial decomposition data for `a*b`.
2. Use `sqBasin_disjoint_of_ne_idempotent` to build disjoint invariant subsets.
3. Show one basin component itself gives an admissible cut whose conductance is bounded above by an explicit fragmentation ratio.

Why it matters:
- This yields a theorem even if the full product conductance formalism is technically difficult.
- It links arithmetic idempotents directly to sparse cuts, which is conceptually powerful.

Why it is secondary:
- It may produce a weaker explicit bound than the clean `min` inequality.
- It depends on how much quantitative cardinality information the existing fragmentation theorem exposes.

### Strategy C: Operator-theoretic route via product graphs
1. Formalize the squaring graph as a deterministic or regular directed graph operator.
2. Show the adjacency/transition operator on `ab` is conjugate under CRT to a tensor-type product operator.
3. Import a product-graph conductance inequality: the conductance of a Cartesian/tensor product is bounded by the minimum of factor conductances.

Why this is visionary:
- It reframes arithmetic dynamics in the language of Markov products and statistical mechanics.
- It may unlock future spectral-gap theorems, mixing bounds, and entropy inequalities.

Why it is harder:
- Lean infrastructure for general product graph conductance may be heavier than needed.
- Good as a second-phase generalization after Strategy A succeeds.

---

## Required deep-proof tactics

Your file must contain at least 3 theorems whose proofs genuinely use multi-step mathematical reasoning. Suitable proof patterns include:

- `induction` on finite-set cardinality or path length
- `rcases` on CRT decomposition witnesses or admissible-cut existence
- `by_contra` to rule out trivial/full lifts or degenerate boundaries
- `field_simp` when comparing rational boundary ratios
- nontrivial `calc` chains for cardinality and normalization identities

Suggested places where these should appear:

1. In proving that `crtLiftLeft hcop S` is neither empty nor full when `S` is neither empty nor full.
2. In cardinality computations for lifted boundaries and volumes.
3. In deriving the minimization theorem from the lifted-cut theorem.

Do not let the file devolve into a sequence of definitional rewrites. The mathematics must carry the proof.

---

## Cross-domain connections you must explicitly develop

This project is strongest when presented as a three-way bridge:

### 1. Number theory ↔ spectral graph theory
CRT turns factorization of moduli into product structure on finite dynamical graphs. The theorem says arithmetic factorization creates sparse cuts, hence worsens expansion.

### 2. Dynamical systems ↔ combinatorics
The squaring map partitions the finite state space into basins of attraction. Conductance measures how hard it is to escape a basin fragment, making a deterministic modular dynamical system look like an energy landscape with metastable states.

### 3. Statistical mechanics / information flow ↔ arithmetic dynamics
A product bottleneck theorem is analogous to a principle that composite systems inherit the slowest mixing mode of their factors. This is the arithmetic counterpart of “the weakest channel dominates global transport.”

You should mention these explicitly in `RESEARCH_PAPER.md` and `ARTICLE.md`. This is not rhetorical garnish; it identifies the conceptual payload.

---

## Application keywords

Include these keywords where appropriate:

- arithmetic dynamics
- Chinese remainder theorem
- conductance
- bottleneck ratio
- Cheeger inequality
- product graphs
- metastability
- basin decomposition
- spectral deterioration
- finite dynamical systems
- expansion obstruction
- tensorization
- residue dynamics
- modular squaring
- arithmetic fragmentation

---

## Concrete implementation guidance in Lean 4

You should inspect the exact statements in:

- `Catalog/FINAL/Pythagorean/DynamicalSquaring.lean`
- `Pythagorean/SpectralGap.lean`

and align your definitions with the existing graph/basin formalism rather than fighting it.

If there is already a notion close to basin or invariant set, reuse it. If not, define a lightweight finite-combinatorial surrogate sufficient for the theorem.

### Good Lean design pattern
Break the project into lemmas of increasing sophistication:

1. **CRT lift definitions**
   ```lean
   def crtLiftLeft ...
   def crtLiftRight ...
   ```

2. **Cardinality lemmas**
   ```lean
   theorem card_crtLiftLeft ...
   theorem card_boundary_crtLiftLeft_le ...
   ```

3. **Admissibility lemmas**
   ```lean
   theorem crtLiftLeft_admissible ...
   ```

4. **Ratio comparison**
   ```lean
   theorem basin_boundary_ratio_crtLiftLeft_le ...
   ```

5. **Global minimization**
   ```lean
   theorem basinConductance_mul_le_norm_min ...
   ```

This structure naturally forces nontrivial proofs and minimizes downstream brittleness.

---

## Falsifiable conjecture with computational test

You must state at least one explicit conjecture and one test that could fail.

### Recommended conjecture
> **Conjecture (Exact min law).**  
> For all coprime `a,b ≥ 2`,
> \[
> h_{\mathrm{basin}}(ab)=\min(h_{\mathrm{basin}}(a),h_{\mathrm{basin}}(b)).
> \]

This is stronger than the required theorem and absolutely falsifiable.

### Computational test
For all coprime pairs `2 ≤ a ≤ b ≤ 100`:
1. compute the squaring dynamical graph modulo `a`, `b`, and `ab`;
2. enumerate admissible basin cuts;
3. compute `h_basin(a)`, `h_basin(b)`, `h_basin(ab)`;
4. test whether equality or only inequality holds;
5. search for the optimal normalization factor
   \[
   \kappa(a,b)=\frac{h_{\mathrm{basin}}(ab)}{\min(h_{\mathrm{basin}}(a),h_{\mathrm{basin}}(b))}.
   \]

A second conjecture is also worthwhile:

> **Conjecture (Prime-power rigidity).**  
> The strongest failures of expansion occur at highly composite moduli, while prime powers exhibit strictly larger basin conductance than squarefree numbers of comparable size.

Test by comparing `h_basin(n)` across all `n ≤ 200`, grouped by number of distinct prime factors.

---

## Why this would be a breakthrough

If you prove even the inequality theorem cleanly, you will have shown:

- factorization imposes a **universal quantitative obstruction** to mixing in modular squaring dynamics;
- CRT is not just an algebraic decomposition but a **transport law** for dynamical bottlenecks;
- arithmetic state spaces obey a product principle analogous to those in Markov chains, spin systems, and information theory.

That is a real conceptual jump. It creates a program: study arithmetic expansion, arithmetic metastability, and Cheeger-type inequalities for deterministic maps on residue rings. It suggests new invariants of integers measured not by divisibility alone, but by the geometry of induced dynamical landscapes.

This is exactly the kind of theorem that makes mathematicians say: “I knew CRT decomposes rings; I had not realized it forces spectral deterioration in finite dynamics.”

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file(s)** containing:
   - at least 3 nontrivial theorems with deep proof tactics,
   - at least 1 novel definition,
   - the CRT product bottleneck theorem or a strong finite-combinatorial precursor,
   - at least 1 theorem explicitly connecting arithmetic dynamics to graph conductance / combinatorics.

2. **`FUTURE_DIRECTIONS.md`**
   with **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjectural statement,
   - a clear computational or theoretical test,
   - what evidence would refute it.

3. **`RESEARCH_PAPER.md`**
   as a **standalone scientific paper**:
   - motivation,
   - precise statements,
   - proof ideas,
   - significance,
   - relation to catalog theorems,
   - next-step questions.
   Someone reading only this document must understand the discovery.

4. **`ARTICLE.md`**
   in **Scientific American style**:
   - vivid and accessible,
   - focused on the mathematics and significance,
   - **do not emphasize formal verification**,
   - explain how factorization creates bottlenecks in a modular dynamical world.

5. **A verified algorithm or computational method**
   for computing or bounding `basinConductance n`, and for constructing lifted CRT cuts.

6. **`demo.py`**
   that interactively:
   - accepts coprime `a,b`,
   - computes candidate basin conductances for `a`, `b`, and `ab`,
   - displays the lifted cut,
   - reports whether the inequality/equality holds,
   - searches for the best normalization factor on a user-specified range.

---

## Final charge

Do not settle for “there exists some decomposition.” Prove that decomposition has geometric consequences. Turn CRT into a bottleneck machine. Show that arithmetic factorization degrades expansion in a mathematically explicit way.

Build the theorem so that future work can ask sharper questions: exact conductance formulas, spectral-gap comparisons, entropy contraction, and universality across polynomial residue dynamics.

The target is not merely another lemma in modular dynamics. The target is the birth of **arithmetic product spectral theory**.

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
