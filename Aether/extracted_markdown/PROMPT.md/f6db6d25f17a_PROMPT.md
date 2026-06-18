## Assignment: **prove**

Aristotle, aim directly at the combinatorial core that can make tropical Brill–Noether theory genuinely machine-native:

# Program: Formal Tropical Brill–Noether via Lattice Paths, Tableaux, and Chip-Firing

The breakthrough target is not “some formalization of CDPR.” It is this:

> **Extract the metric-free combinatorial engine behind the Cools–Draisma–Payne–Robeva theorem and prove, in Lean 4, a sharp existence theorem for rank-`r` divisors on a chain of `g` loops by reducing divisor existence to a Weyl-chamber lattice-path problem equivalent to a tableau existence criterion.**

If successful, this opens a new field of **certified tropical representation theory**: divisor rank on graphs becomes expressible in the same formal language as tableaux, highest-weight constraints, and tropical linear algebra.

---

## Precise theorem target

There are really two theorems to prove, one structural and one existential. The structural theorem is the key abstraction barrier.

### Theorem A: CDPR states are equivalent to Weyl-chamber lattice paths

Define a combinatorial “CDPR state path” for parameters `g r d : ℕ` as a sequence
\[
p_0, p_1, \dots, p_g \in \mathbb{Z}^{r+1}
\]
such that:

1. `p_0 = (d-r, d-r-1, ..., d-2r)`,
2. each step `p_{i+1} - p_i` is either:
   - one of the standard basis vectors `e_j` for some `j : Fin (r+1)`, or
   - the all-ones-negative correction determined by a “lingering” move, depending on your chosen encoding,
3. each `p_i` lies in the open Weyl chamber
   \[
   p_i(0) > p_i(1) > \cdots > p_i(r) > 0.
   \]

Then prove:

> **Theorem A.** For every `g d r : ℕ`, the following are equivalent:
> 1. there exists a CDPR state path of length `g`,
> 2. there exists a displacement tableau of shape `(r+1) × (g-d+r)` satisfying the CDPR compatibility rules,
> 3. there exists a semistandard tableau in an explicitly defined rectangular/staircase region encoding the same data.

This is the formal bridge theorem. It converts tropical Brill–Noether existence into finite combinatorics.

### Theorem B: Existence iff Brill–Noether number is nonnegative

Let
\[
\rho(g,r,d) := g - (r+1)(g-d+r).
\]

Then prove:

> **Theorem B.** For all `g d r : ℕ`, if `r ≤ d` and `d ≤ 2*g` (or whatever natural range your encoding requires), then
> \[
> (\exists \text{ combinatorial CDPR path/tableau of type } (g,d,r)) \iff 0 \le \rho(g,r,d).
> \]

This is the machine-checkable combinatorial heart of CDPR.

### Stronger graph-theoretic formulation

Once Theorem B is established, push to the graph statement:

> **Theorem C.** For the combinatorial chain-of-loops graph `ChainLoop g`, there exists a divisor `D` of degree `d` with Baker–Norine rank at least `r` if and only if `0 ≤ ρ(g,r,d)`.

This is only believable if your reduction from divisors to paths is completely formalized. The real theorem is not just existence—it is the equivalence between rank conditions and path constraints.

---

## Suggested Lean 4 theorem signatures

You will need to adjust names to actual Mathlib conventions, but aim for something as sharp as the following.

```lean
def brillNoetherNumber (g r d : ℕ) : ℤ :=
  g - (r + 1) * (g - d + r)

def IsCDPRPath (g r d : ℕ) (p : Fin (g + 1) → Fin (r + 1) → ℤ) : Prop := 
  -- initial condition, allowed steps, Weyl chamber positivity
  sorry

def HasDisplacementTableau (g r d : ℕ) : Prop :=
  ∃ T : DisplacementTableau g r d, True

def HasSSYTEncoding (g r d : ℕ) : Prop :=
  ∃ T : SSYTEncoding g r d, True

theorem cdprPath_iff_displacementTableau
    (g r d : ℕ) :
    (∃ p, IsCDPRPath g r d p) ↔ HasDisplacementTableau g r d := by
  sorry

theorem displacementTableau_iff_ssyt
    (g r d : ℕ) :
    HasDisplacementTableau g r d ↔ HasSSYTEncoding g r d := by
  sorry

theorem exists_cdpr_object_iff_brillNoether_nonneg
    (g r d : ℕ) :
    ((∃ p, IsCDPRPath g r d p) ↔ 0 ≤ brillNoetherNumber g r d) := by
  sorry
```

For the graph-theoretic endpoint:

```lean
def ChainOfLoops (g : ℕ) := -- combinatorial multigraph with g loops in chain
  sorry

def HasDivisorOfDegreeRank (G : Type _) [GraphLike G] (d r : ℕ) : Prop :=
  ∃ D : Divisor G, D.degree = d ∧ r ≤ bakerNorineRank D

theorem chainOfLoops_brillNoether
    (g r d : ℕ) :
    HasDivisorOfDegreeRank (ChainOfLoops g) d r ↔ 0 ≤ brillNoetherNumber g r d := by
  sorry
```

And for the tropical linear algebra bridge:

```lean
def divisorToTropMatrix {g : ℕ} (D : Divisor (ChainOfLoops g)) :
    Fin (g + 1) → Fin (g + 1) → Tropical ℤ := 
  sorry

theorem bakerNorineRank_le_barvinokRank
    {g : ℕ} (D : Divisor (ChainOfLoops g)) :
    bakerNorineRank D ≤ barvinokRank (divisorToTropMatrix D) := by
  sorry
```

Even if the last theorem needs revision, make it a serious formal target: either prove it or kill it with a counterexample.

---

## Why this would be a breakthrough

The classical CDPR theorem is one of the signature results of tropical Brill–Noether theory because it translates an algebro-geometric existence problem into a combinatorial one. But current formal mathematics typically stops at either chip-firing basics or isolated tropical computations. What is missing is a **certified equivalence of worlds**:

- divisors on graphs,
- Weyl-chamber lattice paths,
- displacement tableaux,
- semistandard tableau combinatorics.

That equivalence is revolutionary because it makes tropical Brill–Noether theory interoperable with existing formal ecosystems in:
- Young tableau combinatorics,
- Coxeter/Weyl chamber machinery,
- tropical linear algebra,
- algorithmic rank certification.

A full Lean proof here would not be “another formalization.” It would establish a **formal transfer principle** between divisor theory and representation-theoretic combinatorics.

---

## Proof strategy architecture

You need multiple routes, because one of them will likely collapse under definitional friction.

### Strategy 1: Direct path-counting via Weyl chamber invariants
**Most promising for Lean.**

1. **Define the CDPR path model first**, not tableaux.  
   Paths are easier to encode than semistandard objects because:
   - state = finite vector of integers,
   - legality = local step predicate,
   - admissibility = pointwise inequalities.

2. **Prove path existence iff a linear inequality holds.**  
   Show that the total “budget” of positive moves minus chamber constraints is exactly governed by
   \[
   \rho = g - (r+1)(g-d+r).
   \]
   The core lemma should identify the minimal path length needed to reach and stay in the Weyl chamber.

3. **Then construct the tableau bijection as a second-layer theorem.**  
   Once existence is settled path-theoretically, the tableau equivalence becomes a structural embellishment rather than the main burden.

Why this is promising: Lean handles local recursion, finite sums, and inequality invariants well. This route minimizes reliance on sophisticated preexisting tableau libraries.

---

### Strategy 2: Bijection to semistandard Young tableaux inside a box
**Most conceptually elegant.**

1. Encode displacement tableaux as semistandard tableaux with an extra residue/displacement compatibility condition.
2. Prove that for the chain-of-loops parameters, the compatibility condition is vacuous or canonically absorbed into the shape/content constraints in the generic combinatorial regime.
3. Reduce existence to the positivity of a shape parameter:
   - a rectangle/staircase has an SSYT iff the shape is valid,
   - validity simplifies to `ρ ≥ 0`.

This route is powerful if Mathlib already has enough finite-function and order-theoretic support for tableaux-like structures. It gives a beautiful representation-theoretic interpretation: the Brill–Noether number becomes the slack parameter of a highest-weight feasibility region.

---

### Strategy 3: Chip-firing first, then extract paths from reduced divisors
**Best for the graph-theoretic theorem, but technically heavier.**

1. Formalize `v₀`-reduced divisors on the chain-of-loops graph.
2. Prove every divisor class has a unique reduced representative with a state vector recording chips on bridges/loops.
3. Show that rank-`r` is equivalent to the existence of a sequence of legal reductions that exactly traces a Weyl-chamber path.

This route gives the deepest theorem because it connects the abstract Baker–Norine rank directly to the path combinatorics. But it is also the most technically demanding: you must formalize Dhar-style reduction, reducedness, and rank.

**Recommendation:** use Strategy 1 to secure the existence theorem, then Strategy 3 to lift it to graph theory.

---

## Key intermediate lemmas to target

These are the real formal bottlenecks.

### 1. Chamber initialization lemma
Show that the initial state
\[
(d-r, d-r-1, \dots, d-2r)
\]
lies in the Weyl chamber iff the natural positivity constraint is satisfied.

```lean
theorem initialState_inWeylChamber
    (d r : ℕ) :
    InWeylChamber (initialState d r) ↔ r ≤ d := by
  sorry
```

### 2. Step preservation lemma
A legal CDPR move preserves strict coordinate separation under explicit hypotheses.

```lean
theorem legalStep_preserves_chamber
    {g r d : ℕ} {p q : Fin (r + 1) → ℤ} :
    InWeylChamber p →
    IsLegalCDPRStep p q →
    StepSideConditions p q →
    InWeylChamber q := by
  sorry
```

### 3. Budget lemma
The total number of non-lingering moves available over `g` steps is controlled exactly by `ρ`.

```lean
theorem moveBudget_eq_brillNoether
    (g r d : ℕ) :
    moveBudget g r d = brillNoetherNumber g r d := by
  sorry
```

### 4. Existence by greedy path construction
If `0 ≤ ρ`, construct a legal path explicitly.

```lean
theorem exists_cdprPath_of_brillNoether_nonneg
    (g r d : ℕ)
    (hρ : 0 ≤ brillNoetherNumber g r d) :
    ∃ p, IsCDPRPath g r d p := by
  sorry
```

### 5. Necessity by deficit argument
If a legal path exists, then `ρ ≥ 0`.

```lean
theorem brillNoether_nonneg_of_exists_cdprPath
    (g r d : ℕ)
    (hp : ∃ p, IsCDPRPath g r d p) :
    0 ≤ brillNoetherNumber g r d := by
  sorry
```

These five lemmas together already constitute a publishable formal theorem package.

---

## Deeper mathematical insight: what is really happening

The quantity
\[
\rho(g,r,d)=g-(r+1)(g-d+r)
\]
should be treated not merely as a dimension count, but as a **combinatorial slack variable** measuring the codimension gap between:

- the ambient path length `g`, and
- the minimal number of chamber-preserving updates required to sustain `r+1` ordered coordinates.

This interpretation is important because it suggests a much broader paradigm:

> **Brill–Noether numbers are tropical feasibility margins.**

That perspective can unify:
- divisor existence on graphs,
- tropical rank feasibility,
- Weyl chamber reachability,
- semistandard tableau occupancy constraints.

If formalized properly, this is the seed of a general theory of **tropical moduli via certified discrete feasibility**.

---

## Cross-domain connections to exploit

### 1. Representation theory
The Weyl chamber inequalities are type `A_r` highest-weight constraints.  
A CDPR path is morally a walk in a crystal-like combinatorial state space. This suggests:
- crystal operators,
- Gelfand–Tsetlin patterns,
- semistandard tableaux,
- Littelmann path models.

A spectacular follow-up theorem would identify CDPR paths with a restricted Littelmann path model for `sl_{r+1}`.

### 2. Tropical linear algebra
Hypothesis 2 is not a side quest. If divisor rank can be bounded by tropical matrix rank, then Brill–Noether feasibility becomes an instance of tropical factorization complexity. This would connect:
- Baker–Norine rank,
- Barvinok rank,
- tropical convexity,
- min-plus linear algebra.

Even a one-sided inequality would be a conceptual breakthrough.

### 3. Discrete optimization and formal algorithms
The existence theorem is equivalent to feasibility of an integer path in an ordered polyhedral region. That means:
- dynamic programming,
- shortest-path certificates,
- SMT-style proof witnesses,
- certified enumeration.

This is exactly the kind of theorem that can become both mathematics and verified algorithmics.

### 4. Algebraic geometry
The chain-of-loops graph is the tropical shadow of degenerating curves. A machine-checked theorem here is not merely graph theory: it is a certified tropical avatar of Brill–Noether existence. That creates a route toward eventual formal interactions with:
- specialization of linear series,
- limit linear series,
- tropicalization of moduli problems.

---

## Guidance on Hypothesis 2: be bold but scientific

The proposed bound
\[
r(D) \le \operatorname{BarvinokRank}(M(D))
\]
is visionary, but it may fail in naive form. Do not force a false theorem. Instead:

1. Define several candidate matrices:
   - pairwise chip-distance matrix,
   - effective resistance variant,
   - reduced-divisor transition-cost matrix,
   - tropical Laplacian minor matrix.

2. Test each for small `g ≤ 6`.
3. If the original conjecture fails, pivot to a corrected theorem:
   - upper bound after normalization,
   - upper bound for `v₀`-reduced divisors only,
   - upper bound up to additive constant,
   - equality for rank `0` or `1`,
   - monotonicity under chip-firing.

A good counterexample here would be as valuable as a proof, because it would identify the right tropical linear algebra invariant.

---

## Guidance on Hypothesis 3: the metric-free theorem

This is potentially field-opening. The central question is:

> Is the CDPR existence criterion fundamentally metric, or is it already encoded in the combinatorics of chip-firing on the abstract chain-of-loops graph?

There are two possibilities, both scientifically excellent:

- **If true:** you prove the tropical Brill–Noether existence theorem is secretly combinatorial at the existence level.
- **If false:** you isolate the exact metric obstruction and formulate a corrected theorem, e.g. “existence iff `ρ ≥ 0` for generic metric chains, but combinatorial chains satisfy a weakened threshold characterized by ...”

Either outcome is a contribution. If the pure combinatorial statement fails, produce the smallest explicit counterexample in Lean.

Suggested formal target:

```lean
theorem combinatorial_chainOfLoops_counterexample_or_theorem :
  (∀ g r d, HasDivisorOfDegreeRank (ChainOfLoops g) d r ↔ 0 ≤ brillNoetherNumber g r d)
  ∨
  (∃ g r d, HasDivisorOfDegreeRank (ChainOfLoops g) d r ∧ brillNoetherNumber g r d < 0)
  ∨
  (∃ g r d, ¬ HasDivisorOfDegreeRank (ChainOfLoops g) d r ∧ 0 ≤ brillNoetherNumber g r d) := by
  sorry
```

That statement is awkward as mathematics but excellent as a research forcing function: it demands either theorem or counterexample.

---

## Build explicitly on catalog theorems

Use any existing catalog results on:
- finite paths / walks on graphs,
- chip-firing and divisor degree lemmas,
- tropical semiring or tropical matrix rank,
- Young diagram / finite function combinatorics,
- monotone lattice path counting,
- integer vector majorization.

Do not merely cite them; repurpose them:
- If you have a theorem controlling finite sums over `Fin n`, use it to make the budget argument exact.
- If there is a certified monotonicity lemma for tropical matrix rank, combine it with chip-firing normalization to seek rank invariance.
- If there are graph divisor lemmas, isolate the chain-of-loops special case and turn global rank definitions into local recurrence.

The crucial design principle: **every hard tropical statement should be reduced to a finite combinatorial invariant already natural in Lean.**

---

## Concrete deliverables

1. A Lean file formalizing:
   - `brillNoetherNumber`,
   - CDPR path states,
   - Weyl chamber admissibility,
   - legal steps,
   - existence iff `ρ ≥ 0`.

2. A second Lean file giving either:
   - displacement tableau ↔ path equivalence, or
   - semistandard tableau ↔ path equivalence.

3. A third Lean file proving either:
   - graph divisor existence theorem for chain-of-loops, or
   - a minimal explicit counterexample to the metric-free version.

4. Computational verification for all small cases:
   - `g ≤ 12`, `r ≤ 4` for path/tableau existence,
   - `g ≤ 6`, `d ≤ 2g` for tropical matrix-rank experiments.

5. A structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable hypotheses**, each with:
   - exact conjecture,
   - smallest nontrivial test range,
   - what data would refute it,
   - what theorem it would imply if true.

---

## Required FUTURE_DIRECTIONS.md hypotheses

Include at least these kinds of hypotheses:

1. **Crystal-model hypothesis**  
   CDPR paths for rank `r` are equivalent to a restricted `sl_{r+1}` Littelmann path model.  
   **Test:** construct explicit bijection for `r ≤ 3`, `g ≤ 8`.

2. **Tropical rank bound hypothesis**  
   A normalized tropical matrix attached to a reduced divisor satisfies  
   `bakerNorineRank D ≤ tropicalRank (M D) + C_r` for a universal constant.  
   **Test:** exhaustive search for `g ≤ 6`.

3. **Metric-independence threshold hypothesis**  
   The existence half of CDPR is metric-free, but uniqueness/enumeration is metric-sensitive.  
   **Test:** compare combinatorial vs metric models for smallest genera.

4. **Tableau counting hypothesis**  
   The number of divisor classes of degree `d` and rank `r` on a chain-of-loops is given by a tableau count matching a Kostka/LR-type coefficient in the generic regime.  
   **Test:** compute both sides for `g ≤ 9`.

5. **Algorithmic certification hypothesis**  
   Baker–Norine rank on chain-of-loops admits a polynomial-time certified decision procedure via Weyl-chamber dynamic programming.  
   **Test:** implement and benchmark on random instances.

These must be written as testable scientific statements, not vague aspirations.

---

## Application keywords

tropical Brill–Noether theory; Baker–Norine rank; chip-firing; chain of loops; Cools–Draisma–Payne–Robeva theorem; Weyl chamber lattice paths; semistandard Young tableaux; displacement tableaux; tropical linear algebra; Barvinok rank; crystal combinatorics; Littelmann paths; verified combinatorics; formal algebraic geometry; certified discrete moduli

---

## Final charge

Do not settle for a local patch. Extract the theorem that makes the subject interoperable.

If you can prove
\[
\exists \text{ rank-}r \text{ divisor of degree } d \iff \rho(g,r,d)\ge 0
\]
through a formally certified equivalence with tableau/path combinatorics, you will have built the first real bridge between tropical divisor theory and formal representation-theoretic combinatorics.

That is not a formalization exercise. That is the creation of a new language for machine-checked geometry.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
