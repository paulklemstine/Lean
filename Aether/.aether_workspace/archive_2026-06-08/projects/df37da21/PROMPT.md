Soli Deo Gloria

## Assignment: Tropical Brill–Noether Theory at Full Strength

**Mode:** prove

Build a genuinely new Lean 4 development around tropical Brill–Noether existence phenomena for metric graphs, with a sharp eye toward the classical algebraic-geometric correspondence. Do **not** settle for toy graph lemmas or finite enumeration. The goal is to formalize a mathematically meaningful bridge: chip-firing and divisor rank on tropical curves as a combinatorial shadow of Brill–Noether theory.

You should treat the headline theorem not as a slogan but as a program to isolate the first formally tractable, nontrivial, breakthrough-grade cases and the structural machinery that makes the full theorem believable.

## Core Vision

The classical Brill–Noether theorem says that a general smooth algebraic curve of genus `g` admits a linear series `g^r_d` iff
\[
\rho(g,r,d) := g - (r+1)(g-d+r) \ge 0.
\]
The tropical analogue replaces curves by metric graphs and linear series by divisors modulo chip-firing. A full formal proof for all general tropical curves is likely too large for one cycle unless substantial infrastructure already exists, so your mission is to formalize **the first deep nontrivial Brill–Noether zone**:

1. define a robust tropical Brill–Noether framework in Lean;
2. prove sharp existence/nonexistence theorems for explicit general families (especially chains of loops / rank-determining models);
3. prove at least one theorem that connects the tropical criterion to a classical-geometric or combinatorial invariant;
4. formulate the full tropical Brill–Noether theorem as a precise conjectural endpoint, together with computational evidence.

This is not incremental graph theory. This is the formal birth of tropical linear series.

---

## Precise Mathematical Targets

### New definitions you should introduce

At minimum define the following concepts, even if initially on a simplified combinatorial model of tropical curves such as finite weighted graphs or chains of loops:

- `brillNoetherNumber : ℕ → ℕ → ℕ → ℤ`
- a structure representing a tropical curve/model (likely a finite connected graph with genus)
- divisors on a tropical curve
- linear equivalence / chip-firing reachability
- rank of a divisor
- existence of a divisor of degree `d` and rank at least `r`
- a family of “general” tropical curves that is actually formalizable, e.g. generic chain of loops with irrationally independent edge lengths, or a combinatorial proxy sufficient for a first theorem

You may need a staged architecture:
- **Stage A:** finite graph divisors and chip-firing;
- **Stage B:** genus and degree/rank;
- **Stage C:** explicit family theorem;
- **Stage D:** bridge theorem toward classical Brill–Noether.

### Lean 4 theorem signatures to target

These signatures may need adaptation to available infrastructure, but the mathematical content should remain intact.

```lean
def brillNoetherNumber (g r d : ℕ) : ℤ :=
  (g : ℤ) - ((r + 1 : ℕ) : ℤ) * ((g - d + r : ℕ) : ℤ)
```

If subtraction on naturals is too lossy, replace with an integer-native version:

```lean
def brillNoetherNumberZ (g r d : ℤ) : ℤ :=
  g - (r + 1) * (g - d + r)
```

A divisor-existence predicate:
```lean
def ExistsDivisorOfDegreeRank
  (C : TropicalCurve) (d r : ℕ) : Prop :=
  ∃ D : Divisor C, D.degree = d ∧ r ≤ divisorRank D
```

A first major existence theorem for a formalizable generic family:
```lean
theorem chainOfLoops_exists_divisor_of_rank
  (g d r : ℕ)
  (hρ : 0 ≤ brillNoetherNumber g r d)
  (hgen : GenericChainOfLoops g L) :
  ExistsDivisorOfDegreeRank (chainOfLoopsCurve g L) d r
```

A complementary nonexistence theorem:
```lean
theorem chainOfLoops_no_divisor_of_rank
  (g d r : ℕ)
  (hρ : brillNoetherNumber g r d < 0)
  (hgen : GenericChainOfLoops g L) :
  ¬ ExistsDivisorOfDegreeRank (chainOfLoopsCurve g L) d r
```

A combined iff theorem:
```lean
theorem chainOfLoops_brillNoether_iff
  (g d r : ℕ)
  (hgen : GenericChainOfLoops g L) :
  ExistsDivisorOfDegreeRank (chainOfLoopsCurve g L) d r ↔
    0 ≤ brillNoetherNumber g r d
```

A bridge theorem to classical geometry, phrased in a form you can actually support:
```lean
theorem specialization_preserves_rank_lower_bound
  {X : ClassicalCurve} {C : TropicalCurve}
  (hspec : SpecializesTo X C) (D : ClassicalDivisor X) :
  divisorRank (specializeDivisor hspec D) ≥ classicalDivisorRank D
```

or, if classical objects are too ambitious this cycle, a certified combinatorial shadow:
```lean
theorem tropical_BN_implies_classical_numerology
  (g d r : ℕ)
  (hex : ∃ C : TropicalCurve, Genus C = g ∧ ExistsDivisorOfDegreeRank C d r) :
  0 ≤ brillNoetherNumber g r d ∨ ExceptionalLocusNonempty g d r
```

A cross-domain theorem connecting tropical divisors to matroid/combinatorial optimization data:
```lean
theorem rank_determining_set_controls_divisor_rank
  (C : TropicalCurve) (S : Finset C.Vertices)
  (hS : RankDeterminingSet C S) (D : Divisor C) :
  divisorRank D =
    restrictedDivisorRank C S D
```

This theorem is important because it converts a geometric rank problem into a finite optimization problem.

---

## Theorems You Must Actually Prove

You must prove **at least 3 substantial theorems**, each requiring genuine reasoning. A suggested package:

### Theorem 1: Brill–Noether numerology controls existence on an explicit generic family
For a formalizable family `ChainOfLoops g`, prove one direction or the full iff:
\[
\text{ExistsDivisorOfDegreeRank}(C,d,r) \leftrightarrow \rho(g,r,d)\ge 0.
\]
If the full iff is too large, prove:
- existence for `ρ ≥ 0`, and
- nonexistence for `ρ < 0`
as separate theorems.

This is the centerpiece.

### Theorem 2: Monotonicity / semicontinuity of divisor rank under chip-firing or specialization
Prove a structural theorem such as:
- linear equivalence preserves degree,
- rank is invariant under linear equivalence,
- specialization does not decrease tropical rank relative to classical rank,
- rank can be tested on a rank-determining set.

These are not auxiliary facts; they are the geometry engine.

### Theorem 3: Cross-domain connection
Prove one theorem linking tropical Brill–Noether to another domain. Strong candidates:

- **Combinatorics / Young tableaux:** for chains of loops, divisor classes of degree `d`, rank `r` correspond to lattice paths or tableaux satisfying a Brill–Noether shape condition.
- **Optimization:** divisor rank equals feasibility of a chip-firing linear inequality system.
- **Automata / tropical logic:** use the catalog’s definability theorems to show that a bounded chip-firing reachability predicate on finite graph models is recognizable/derivative-closed in a tropical formal language encoding.
- **Matroid theory:** rank-determining subsets behave like bases for a tropical independence system.

A model theorem:
```lean
theorem divisor_rank_feasible_iff_integer_potential_solution
  (C : TropicalCurve) (D : Divisor C) (r : ℕ) :
  r ≤ divisorRank D ↔
  ∀ E : EffectiveDivisor C, E.degree = r →
    ∃ f : VertexPotential C, Effective (D - E + laplacian f)
```
This is a bridge to integer linear optimization.

---

## Proof Strategy Architecture

You must include and pursue 2–3 serious proof pathways. The development should not depend on a single brittle idea.

### Strategy A: Explicit generic family via reduced divisors and lattice paths
**Most promising.**

1. Formalize divisors and chip-firing on a chain of loops graph family.
2. Define reduced divisors relative to a basepoint and prove a uniqueness or normal-form theorem.
3. Translate existence of degree `d`, rank `r` divisors into a constrained lattice path / tableau condition.
4. Show that the lattice path condition is feasible iff `ρ ≥ 0`.

Why this is most promising: it avoids the full moduli space of tropical curves while still capturing the genuine Brill–Noether threshold. It is deep, explicit, and historically central.

### Strategy B: Rank-determining sets and finite optimization
1. Prove a finite criterion reducing divisor rank to testing finitely many effective divisors supported on a rank-determining set.
2. Encode chip-firing via graph Laplacians and integer potentials.
3. Derive existence/nonexistence from solvability of a family of integer linear inequalities depending on `g,d,r`.
4. For chains of loops, solve these inequalities structurally to recover `ρ`.

Why this matters: it turns tropical geometry into certified discrete optimization, opening algorithmic applications.

### Strategy C: Specialization bridge from classical to tropical
1. Formalize a minimal abstraction of specialization from algebraic curves to tropical curves.
2. Prove rank comparison under specialization.
3. Use known classical Brill–Noether numerology as an external mathematical guide, then certify tropical consequences in explicit cases.
4. State the full tropical-classical correspondence as a conjectural next theorem, supported by proved special cases.

Why this is powerful: it positions the development as a foundation for future formalized degeneration arguments rather than an isolated graph computation.

---

## How to Use Existing Verified Theorems

The current catalog is not directly Brill–Noether-specific, so use it creatively as infrastructure for a cross-domain theorem rather than forcing irrelevant dependencies.

### Relevant catalog leverage

1. `FINAL/Tropical/FormulaDefinability.lean`
   - `tropical_formula_iff_recognizable_and_deriv_closed`
   - Use this to encode bounded chip-firing reachability or bounded rank-feasibility predicates for finite graph divisor configurations as a tropical recognizable language.
   - Vision: finite-support divisor evolution under chip-firing becomes a formal-language object. This is a surprising bridge between tropical geometry and automata theory.

2. `FINAL/Tropical/RankOneFactorization.lean`
   - `tropical_rank_one_iff_additive_separable`
   - Use as inspiration for “rank” notions in tropical settings: distinguish matrix tropical rank from divisor rank, and prove a theorem clarifying the analogy or non-equivalence on incidence matrices/Laplacians associated to tropical curves.

3. `FINAL/Tropical/FactorRank.lean`
   - `tropFactorRank_bound_via_tropical_rank`
   - Potential application: derive complexity bounds for optimization encodings of divisor rank via tropical matrix representations of chip-firing systems.

4. `FINAL/Tropical/OracleApplicationsFrontier.lean`
   - `tropical_and_bound`
   - Potentially useful for combining tropical inequality certificates if you encode rank feasibility as a conjunction of local tropical constraints.

Do not shoehorn these into the main theorem. Use them to produce one authentic cross-domain theorem or algorithmic certification layer.

---

## Concrete Cross-Domain Connections to Include

You must include at least one theorem and one discussion thread from another field.

### Option 1: Algebraic geometry
Show that tropical divisor rank behaves as a specialization shadow of classical linear series. Even if you cannot formalize all of classical geometry, define an abstract `SpecializesTo` relation and prove rank monotonicity in that abstract setting.

### Option 2: Combinatorics
Relate divisors on chains of loops to standard Young tableaux / lattice paths. This is likely the richest explicit bridge.

### Option 3: Optimization / theoretical computer science
Express divisor rank as a chip-firing feasibility problem over graph Laplacians. Then prove a theorem reducing geometric existence to an algorithmically checkable certificate.

### Option 4: Automata / formal languages
Encode bounded chip-firing transition systems as tropical recognizable predicates using the catalog theorem on formula definability. This would be a field-opening connection: tropical Brill–Noether meets automata theory.

---

## Falsifiable Conjecture with Computational Test

State at least one conjecture that can fail and provide a test.

### Suggested conjecture
For every finite trivalent graph model `G` of genus `g`, if `ρ(g,r,d) ≥ 0`, then for a Zariski-open / generic choice of positive edge lengths on `G`, there exists a divisor of degree `d` and rank at least `r`.

Possible Lean-adjacent formulation:
```lean
conjecture generic_metric_realization_brillNoether
  (G : GraphModel) (g d r : ℕ)
  (hg : graphGenus G = g)
  (hρ : 0 ≤ brillNoetherNumber g r d) :
  ∃ L : EdgeLengths G, GenericLengths L ∧
    ExistsDivisorOfDegreeRank (metricRealization G L) d r
```

### Computational test
Implement `demo.py` to:
1. generate random chain-of-loops or trivalent graph metrics,
2. compute candidate divisors and chip-firing moves,
3. estimate divisor rank by finite search,
4. compare empirical existence with the sign of `ρ(g,r,d)`.

A single counterexample would refute the conjecture on that graph family, making it genuinely falsifiable.

---

## Algorithmic Deliverable

You must produce a verified computational method, not just theorems.

### Required algorithm
Implement and verify an algorithm of the following kind:

- input: a finite graph/tropical curve model `C`, divisor `D`, and integer `r`;
- output: either
  - a certificate that `r ≤ rank(D)`, or
  - a witness effective divisor `E` of degree `r` such that no chip-firing move makes `D - E` effective.

Suggested Lean signature:
```lean
def certifyDivisorRank
  (C : TropicalCurve) (D : Divisor C) (r : ℕ) :
  RankCertificate C D r
```

and a correctness theorem:
```lean
theorem certifyDivisorRank_correct
  (C : TropicalCurve) (D : Divisor C) (r : ℕ) :
  soundCertificate (certifyDivisorRank C D r)
```

For explicit families like chains of loops, an even stronger algorithm is possible:
```lean
def chainOfLoopsBNDecision (g d r : ℕ) : Bool
```
with theorem:
```lean
theorem chainOfLoopsBNDecision_spec
  (g d r : ℕ) (hgen : GenericChainOfLoops g L) :
  chainOfLoopsBNDecision g d r = true ↔
    ExistsDivisorOfDegreeRank (chainOfLoopsCurve g L) d r
```
and ideally a simplification:
```lean
theorem chainOfLoopsBNDecision_rho
  (g d r : ℕ) :
  chainOfLoopsBNDecision g d r = true ↔ 0 ≤ brillNoetherNumber g r d
```

---

## File and Formalization Expectations

Your Lean file should contain:
- at least one new structure,
- at least 3 substantial theorems,
- nontrivial proofs using induction, `rcases`, `by_contra`, `field_simp` where relevant, and multi-step `calc`,
- minimal sorrys, and any remaining sorry must be strategically isolated in the most difficult infrastructure lemma rather than in the main statements.

Good candidate file names:
- `Tropical/BrillNoether/Core.lean`
- `Tropical/BrillNoether/ChainOfLoops.lean`
- `Tropical/BrillNoether/Specialization.lean`

If you can only complete one file, prioritize `ChainOfLoops.lean` with enough local definitions to make the theorem package self-contained.

---

## Revolutionary Significance

If you pull this off, you will have formalized the first serious segment of tropical linear series theory in Lean. That opens several fields at once:

- **Tropical algebraic geometry:** a foundation for formalized moduli of divisors and linear systems.
- **Algebraic geometry:** a certified degeneration interface from classical curves to combinatorial shadows.
- **Combinatorics:** explicit bijections between divisor classes, lattice paths, and tableaux.
- **Optimization and algorithms:** divisor rank as a certified graph-Laplacian feasibility problem.
- **Theoretical computer science:** tropical geometric predicates as recognizable formal languages.

This is the kind of development that changes what people think can be formalized.

---

## Application Keywords

tropical Brill–Noether theory, metric graphs, chip-firing, divisor rank, reduced divisors, rank-determining sets, graph Laplacian, specialization of divisors, algebraic curves, linear series, lattice paths, Young tableaux, tropical optimization, recognizable tropical languages, combinatorial moduli, degeneration, certified algorithms

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as optimization, automata, or classical algebraic geometry.

2. **`RESEARCH_PAPER.md`**
   - A standalone scientific paper.
   - A reader with no access to the code must understand:
     - the theorem statements,
     - why they matter,
     - the proof ideas,
     - what remains open.

3. **`ARTICLE.md`**
   - Scientific American style.
   - Engaging and accessible.
   - Do **not** focus on formal verification machinery.
   - Focus on tropical curves, chip-firing, linear series, and why this combinatorial geometry is profound.

4. **A verified algorithm or computational method**
   - For divisor-rank certification or Brill–Noether decision on a graph family.

5. **`demo.py`**
   - Interactive demonstration.
   - It should let a user input `g,d,r`, generate examples, compute `ρ`, and test divisor existence heuristically or exactly on the implemented family.

---

## Final Charge

Do not merely restate Baker–Norine folklore. Build the formal language of tropical linear series, prove a sharp theorem on a meaningful generic family, and create the bridge theorem that makes this feel like the first chapter of a much larger story. The target is not “some Lean code about graphs.” The target is a new formal beachhead in Brill–Noether theory.

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

Research domain: Tropical
Research mode: prove
