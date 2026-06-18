## Assignment: Frankl's Union-Closed Conjecture: Partial Results, Structural Reductions, and Entropic Certificates

**Mode:** `prove`

You are not being asked for a routine formalization of a famous conjecture. You are being asked to carve out a certified theory of **why Frankl’s conjecture is true in meaningful regimes**, and to do so in a way that opens a new bridge between **extremal set theory, finite lattices, and entropy/information theory**.

The central ambition is to formalize a mathematically serious fragment of the following program:

1. define union-closed families and their frequency statistics cleanly in Lean 4;
2. prove nontrivial verified cases of Frankl-type statements;
3. build a lattice-theoretic interface so the conjecture can be transported to finite join-semilattices;
4. introduce an **entropic potential** or averaging invariant that acts as a computational certificate;
5. extract a verified algorithm that searches for heavy elements and tests conjectural strengthening patterns.

The result should feel like the beginning of a genuine formal research area, not a one-off file.

---

## Core theorem targets

You should formalize Frankl’s conjecture for finite set families over a finite ground type `α` with `F : Finset (Finset α)` or an equivalent finite family representation. If a `Finset`-of-`Finset` encoding becomes awkward because of extensionality/coercions, it is acceptable to define a custom structure for finite families with explicit carrier and closure property.

### New definition 1: union-closed family
Introduce a novel structure if needed, e.g.

```lean
structure UnionClosedFamily (α : Type*) [DecidableEq α] :=
(sets : Finset (Finset α))
(nonempty : sets.Nonempty)
(union_closed :
  ∀ {A B : Finset α}, A ∈ sets → B ∈ sets → A ∪ B ∈ sets)
```

Define the frequency of an element:

```lean
def elemFreq {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) (a : α) : ℕ :=
  ((F.sets.filter fun s => a ∈ s).card)
```

Define the Frankl witness predicate:

```lean
def HasFranklWitness {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) : Prop :=
  ∃ a, 2 * elemFreq F a ≥ F.sets.card
```

A weighted/averaged variant should also be introduced; this is where the work becomes conceptually deeper.

### New definition 2: average set size / total incidence
```lean
def totalIncidence {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) : ℕ :=
  ∑ s in F.sets, s.card
```

This is the key combinatorial energy. Prove the double-counting identity relating `totalIncidence` to the sum of element frequencies over the ground union of the family.

Suggested theorem signature:

```lean
theorem totalIncidence_eq_sum_elemFreq
    {α : Type*} [Fintype α] [DecidableEq α]
    (F : UnionClosedFamily α) :
    totalIncidence F
      = ∑ a : α, elemFreq F a
```

If summing over all `α` is awkward due to elements outside the support, replace by the union-support finite set:
```lean
def ground {α : Type*} [DecidableEq α] (F : UnionClosedFamily α) : Finset α := ...
```

and prove
```lean
theorem totalIncidence_eq_sum_elemFreq_ground
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) :
    totalIncidence F
      = ∑ a in F.ground, elemFreq F a
```

This theorem is not Frankl itself, but it is the engine behind all averaging arguments.

---

## Precise breakthrough theorem statements

You must prove at least **3 substantial theorems**, and they should be organized around the following targets.

### Theorem A: 3-element universe case
Formalize and prove the conjecture for any union-closed family on a universe of cardinality at most 3.

A precise Lean-friendly statement:

```lean
theorem frankl_universe_card_le_three
    {α : Type*} [Fintype α] [DecidableEq α]
    (F : UnionClosedFamily α)
    (hα : Fintype.card α ≤ 3) :
    HasFranklWitness F
```

If the direct universe-card statement is too coarse because some elements of `α` may not appear, use the support:
```lean
theorem frankl_ground_card_le_three
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α)
    (h : F.ground.card ≤ 3) :
    HasFranklWitness F
```

**Why this matters:** this is the first nontrivial exact regime where the conjecture becomes structurally visible rather than brute-force enumerable. A good proof will expose the combinatorial mechanisms Lean can reuse later for cardinality 4, separation reductions, and entropy bounds.

---

### Theorem B: abundance criterion via average set size
Prove a criterion showing that if the average set size is at least half the ground size, then Frankl holds.

Suggested statement:

```lean
theorem frankl_of_average_card_large
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α)
    (havg : 2 * F.ground.card * F.sets.card ≤ 2 * totalIncidence F * 2) :
    HasFranklWitness F
```

But this statement should be cleaned into a mathematically natural form. Better is to define a rational average if convenient, or phrase it as:

```lean
theorem exists_element_large_freq_of_average_card_ge_half_ground
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α)
    (h :
      F.ground.card * F.sets.card ≤ 2 * totalIncidence F) :
    HasFranklWitness F
```

Interpretation: if
\[
\frac{1}{|F|}\sum_{A\in F}|A| \ge \frac{|ground(F)|}{2},
\]
then some element lies in at least half the sets.

**Why this matters:** this is the exact point where Frankl becomes an information/energy principle. It reframes the conjecture as a lower bound on average occupancy and opens the door to entropic proofs.

---

### Theorem C: lattice-theoretic reformulation
Define a finite join-semilattice version of the witness property and prove that the powerset-union model recovers the set-family formulation.

A possible abstraction:

```lean
structure FiniteJoinFamily (α : Type*) [DecidableEq α] :=
(carrier : Finset α)
(nonempty : carrier.Nonempty)
(join : α → α → α)
(...)
```

But a cleaner route is likely to use existing order-theoretic typeclasses if available in Mathlib for finite semilattices. The minimum acceptable deliverable is a formal theorem showing equivalence between the set-family Frankl statement and a join-irreducible-heavy reformulation in the finite lattice generated by the family.

Example target:

```lean
theorem frankl_set_family_equiv_lattice_form
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) :
    HasFranklWitness F ↔
      ∃ a in F.ground, 2 * elemFreq F a ≥ F.sets.card
```

This is a weak starting point. A stronger target, preferred if feasible, is:

```lean
theorem frankl_via_join_irreducibles
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) :
    HasFranklWitness F ↔
      ∃ j, IsJoinIrreducibleInGeneratedLattice F j ∧
        2 * upperConeCard F j ≥ F.sets.card
```

You may need to invent and formalize `IsJoinIrreducibleInGeneratedLattice` and `upperConeCard`. That is desirable: it creates new reusable infrastructure.

**Why this matters:** it changes Frankl from “a weird set-family conjecture” into “a universal heavy-generator principle” in finite closure systems. That is conceptually field-opening.

---

### Theorem D: verified small-family bound inspired by Bošnjak–Marković
The assignment mentions “families of size ≤ 50.” You should **not** settle for raw exhaustive enumeration inside Lean unless you can extract a structural lemma. The worthy target is a reduction theorem plus a verified checker.

A realistic formal target is:

```lean
theorem frankl_of_card_le_bound_and_separated
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α)
    (hcard : F.sets.card ≤ 50)
    (hsep : IsSeparatedFamily F) :
    HasFranklWitness F
```

If proving the exact `≤ 50` theorem is too ambitious in pure theorem mode, then prove a structurally meaningful bound for a subclass such as:
- atomistic / generated by small sets,
- separating families,
- families with bounded ground size implied by size bound,
- families with minimum density.

But if you invoke Bošnjak–Marković, be explicit: the formal result should be a theorem reducing the problem to finitely many canonical configurations and a verified algorithm that discharges them. The breakthrough is not “Lean checked 50 by brute force”; it is “Lean certified a reduction architecture for finite counterexample search.”

---

## Lean 4 theorem signature suggestions

These are templates, not constraints. Use whichever representation makes the development cleanest.

```lean
structure UnionClosedFamily (α : Type*) [DecidableEq α] where
  sets : Finset (Finset α)
  nonempty : sets.Nonempty
  union_closed : ∀ {A B}, A ∈ sets → B ∈ sets → A ∪ B ∈ sets

def elemFreq {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) (a : α) : ℕ := ...

def ground {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) : Finset α := ...

def totalIncidence {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) : ℕ := ...

def HasFranklWitness {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) : Prop := ...

theorem totalIncidence_eq_sum_elemFreq_ground
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) :
    totalIncidence F = ∑ a in ground F, elemFreq F a := ...

theorem exists_heavy_element_of_average_card_ge_half_ground
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α)
    (h : ground F.card * F.sets.card ≤ 2 * totalIncidence F) :
    HasFranklWitness F := ...

theorem frankl_ground_card_le_three
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α)
    (h : (ground F).card ≤ 3) :
    HasFranklWitness F := ...
```

You may need to correct the exact syntax around `ground F.card`; do so carefully.

---

## Proof architecture: 3 viable strategies

You must include **2–3 proof strategy paths** in your implementation notes or paper, and actually realize at least one in Lean.

### Strategy 1: Double-counting + pigeonhole (most promising for Theorem B)
1. Prove the incidence identity:
   \[
   \sum_{A\in F}|A| = \sum_{a\in ground(F)} \mathrm{freq}(a).
   \]
   This should require nontrivial `Finset` combinatorics, likely induction on `F.sets` or a filtered-sum argument with `calc`.
2. Assume every element occurs in fewer than half the sets; then sum frequencies to derive
   \[
   \sum_a \mathrm{freq}(a) < \frac{|ground(F)|\,|F|}{2},
   \]
   contradicting the average-size hypothesis.
3. Conclude existence of a heavy element.

**Why promising:** This is robust, elegant, and reusable for many density criteria. It is the formal combinatorial spine of the project.

---

### Strategy 2: Structural decomposition on a 3-element ground set
1. Let `ground(F) = {a,b,c}` up to relabeling. Use `rcases` on cardinality cases `0,1,2,3`.
2. In the 3-element case, exploit union-closure to show that the presence/absence pattern of singletons and doubletons forces one element to appear in at least half the family.
3. Use contradiction (`by_contra`) with all frequencies `< |F|/2`; derive forbidden configurations by closure under unions.

**Why promising:** It avoids brute-force enumeration of all union-closed subfamilies of `𝒫({a,b,c})`, and instead extracts reusable structural lemmas. This is exactly the kind of small-case theorem that scales conceptually.

---

### Strategy 3: Entropic potential / Reimer-style energy functional
1. Define a formal “incidence distribution” on `ground(F)` or on the family itself, perhaps as integer-valued counts if real entropy is too heavy at first.
2. Prove a monotonicity or convexity-style inequality for this potential under adjoining unions or under averaging over principal up-sets.
3. Derive a Frankl witness criterion from positivity of the potential or from a lower bound on average set size.

**Why promising:** This is the bridge to Reimer’s entropy approach. Even if you do not formalize full Shannon entropy initially, a combinatorial proxy can seed future formalization of true information-theoretic arguments.

This is the strategy with the greatest long-term payoff, even if Strategy 1 is the one most likely to close cleanly in the current cycle.

---

## Required cross-domain connections

You must include at least one theorem or definition explicitly linking Frankl’s conjecture to another field.

### Cross-domain direction A: information theory
Define an incidence random variable heuristically/formally:
- choose a set uniformly from `F`,
- choose an element from `ground(F)`,
- study occupancy frequencies.

Then prove a combinatorial shadow of an information inequality, e.g.:
- average set size bound implies a heavy coordinate;
- concentration of incidence counts forces a witness;
- a “binary entropy upper bound” on family complexity in terms of frequencies.

Even if full probability spaces are cumbersome, a finite counting surrogate is acceptable.

**Suggested theorem form:**
```lean
theorem mean_frequency_ge_average_incidence
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) :
    ∃ a ∈ ground F,
      ground F.card * elemFreq F a ≥ totalIncidence F := ...
```
This is a finite averaging theorem, but conceptually it is the discrete expectation-maximization principle.

### Cross-domain direction B: lattice/order theory
Formalize closure systems / join-semilattices and show that union-closed families are finite join-subsemilattices of powersets. Then formulate heavy join-irreducible elements or upper-cone counts.

### Cross-domain direction C: algorithms / complexity
Define a verified search procedure:
```lean
def findFranklWitness? {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) : Option α := ...
```
and prove:
```lean
theorem findFranklWitness?_correct
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) (a : α) :
    findFranklWitness? F = some a → 2 * elemFreq F a ≥ F.sets.card := ...
```

Then give complexity commentary using catalog inspiration such as `bounded_circuit_depth_size` as a model for how certified combinatorial procedures can carry quantitative bounds. Do not force irrelevant use of catalog theorems; instead emulate their style: explicit size bounds, verified finite search, and complexity-aware theorem statements.

---

## How to build on existing verified theorems

The catalog items listed are not directly about union-closed families, but they suggest a methodology:
- `bounded_circuit_depth_size` demonstrates **verified quantitative bounds on finite combinatorial objects**. Your search/certification algorithm for Frankl witnesses should imitate this style: state complexity or search-space bounds explicitly.
- `sumset_size_upper_bound` is especially suggestive: it is a **set-combinatorial cardinality theorem**. Use its proof style and finitary cardinality management as a model for proving incidence and averaging inequalities over finite set systems.
- the lattice-themed theorems (`lattice_element_radius_pos`) indicate there is already some tolerance in the codebase for **novel lattice structures**. Leverage that cultural precedent to define a closure/lattice object for union-closed families rather than avoiding abstraction.

You are not required to use these theorems literally if they are mathematically orthogonal; but you should consciously mirror their formal design pattern:
1. define the right invariant,
2. prove monotonicity/positivity/cardinality bounds,
3. package a certified algorithm.

---

## Nontrivial theorem requirements

Your Lean file must contain at least **3 theorems with genuinely multi-step proofs**, using tools like:
- induction on `Finset`,
- `rcases` on cardinality cases,
- `by_contra`,
- `calc`,
- arithmetic manipulation (`linarith`/`omega` if available, but not as a substitute for structure),
- careful use of filtered sums and cardinal identities.

Avoid vacuous theorem inflation. The proofs should have real internal structure.

A good minimum theorem set is:

1. `totalIncidence_eq_sum_elemFreq_ground`
2. `exists_heavy_element_of_average_card_ge_half_ground`
3. `frankl_ground_card_le_three`

A strong fourth theorem would be:

4. `findFranklWitness?_correct` or a lattice-reformulation theorem.

---

## Conjectures with falsifiable computational tests

You must include at least one explicit conjecture with a clear disproof protocol.

### Conjecture 1: entropy-gap strengthening
For every finite union-closed family `F`,
\[
2 \cdot \max_a \mathrm{freq}(a) - |F|
\]
is bounded below by a monotone function of the average set size excess
\[
2\cdot totalIncidence(F) - |ground(F)|\,|F|.
\]

Formal sketch:
```lean
conjecture frankl_gap_lower_bound
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) :
    ∃ C : ℕ, ...
```

**Test:** enumerate canonical union-closed families up to isomorphism for small ground sizes `n ≤ 6`, compute both sides, and search for counterexamples.

### Conjecture 2: join-irreducible witness principle
Every finite union-closed family has a Frankl witness among its join-irreducible generators.

**Test:** compute the generated lattice of each family up to small support size and check whether every witness can be chosen join-irreducible. A single family where only non-join-irreducibles are heavy refutes it.

### Conjecture 3: small-family certificate compression
Every separating union-closed family of size `m` has a Frankl witness certifiable by checking only a subfamily of size `O(log m)` determined by maximal generators.

**Test:** implement a search over small families and compare full witness search against certificate-restricted search.

These are scientifically valuable because they generate immediate computational experiments and clear failure modes.

---

## Verified algorithm requirement

Produce a verified algorithm, not just theorems.

Minimum acceptable deliverable:
- a function that computes element frequencies,
- a function that returns a candidate heavy element if one exists,
- correctness theorem for returned witnesses.

Preferred stronger deliverable:
- a checker for the average-cardinality criterion;
- a canonical reduction/checker for ground size ≤ 3;
- optional search over all elements of `ground`.

Example:
```lean
def heavyElements {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) : Finset α := ...

theorem mem_heavyElements_iff
    {α : Type*} [DecidableEq α]
    (F : UnionClosedFamily α) (a : α) :
    a ∈ heavyElements F ↔ a ∈ ground F ∧ 2 * elemFreq F a ≥ F.sets.card := ...
```

This directly supports `demo.py`.

---

## Demo and computational experiment expectations

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable hypotheses.
   - each must include:
     - precise statement,
     - why it might be true,
     - exact computational test,
     - what a counterexample would look like.

2. **`RESEARCH_PAPER.md`**
   - standalone scientific document;
   - explain union-closed families, Frankl’s conjecture, your formal theorem statements, proof ideas, algorithmic certificate, and significance;
   - no code access should be needed to understand the discoveries.

3. **`ARTICLE.md`**
   - Scientific American style;
   - explain why “one element appears in half the sets” is a deep law of organization;
   - connect to data compression, social networks, concept lattices, or information flow.

4. **A verified algorithm or computational method**
   - e.g. `findFranklWitness?`, heavy-element checker, average-cardinality certificate, or canonical small-family reducer.

5. **`demo.py`**
   - interactively build sample union-closed families,
   - display frequencies,
   - test theorems on examples,
   - run conjecture checks on small universes.

---

## Application keywords

Use and emphasize these in your paper and article:

- union-closed families
- Frankl conjecture
- extremal combinatorics
- finite lattices
- join-semilattices
- closure systems
- information theory
- entropy method
- incidence geometry
- certified search
- formal verification
- combinatorial optimization
- discrete averaging
- witness extraction
- algorithmic mathematics

---

## Standard of ambition

Do **not** be satisfied with a file that merely states Frankl’s conjecture and proves toy lemmas. The target is a coherent mini-theory with:
- a serious finite combinatorial identity,
- a nontrivial exact case (`ground.card ≤ 3`),
- a density/entropy criterion,
- a lattice or information-theoretic bridge,
- and a certified computational witness extractor.

If you can make the theorem for `|F| ≤ 50` precise and structural, do it. But if forced to choose, prioritize **deep reusable theory over brute-force finite verification**. The breakthrough is to formalize the *architecture* of Frankl reasoning so later cycles can attack the real conjecture.

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

Research domain: Algebra
Research mode: prove
