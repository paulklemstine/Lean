## Assignment: Frankl’s Union-Closed Conjecture as a Lattice–Entropy–Closure Program

You are not being asked to restate the conjecture. You are being asked to build a formal research nucleus around it that could become a genuine platform for future attacks. The target is a Lean 4 development that isolates structural invariants of finite union-closed families, proves nontrivial partial theorems, and forges a new bridge between extremal set theory, finite lattice theory, and information/closure dynamics.

The central vision is this: treat a finite union-closed family not merely as a combinatorial object, but as a finite join-semilattice equipped with an element-frequency functional. Frankl’s conjecture then becomes a statement about the existence of a “heavy atom” in a finite closure universe. The breakthrough opportunity is to formalize a reusable theory of **frequency potentials on finite closure systems**, prove sharp partial results, and connect them to lattice-theoretic and entropy-like monotonicity principles.

## Core theorem target

Formalize the classical statement in a mathematically robust way, then prove deep partial results around it.

### Precise theorem statement
For every finite union-closed family `F` of finite subsets of a finite ground type `α`, if `∅ ∈ F` and `F` contains some nonempty set, then there exists an element `a : α` that belongs to at least half of the members of `F`.

A Lean-friendly formulation should quantify over a finite family of finite sets represented by `Finset (Finset α)`.

### Lean 4 type signature target
Use a finite decidable ground type to keep cardinality arguments canonical.

```lean
theorem frankl_exists_frequent_element
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α))
  (h_empty : ∅ ∈ F)
  (h_uc : ∀ A ∈ F, ∀ B ∈ F, A ∪ B ∈ F)
  (h_nontrivial : ∃ A ∈ F, A.Nonempty) :
  ∃ a : α, 2 * ((F.filter fun s => a ∈ s).card) ≥ F.card
```

This is the north star, but unless the catalog theorem `Speculative/Frankl/Conjecture.lean::frankl_union_closed_conjecture` is already fully verified in a strong form, do **not** waste the cycle reproving the full conjecture by brittle case analysis. Instead, create a theory that makes the conjecture structurally tractable and proves substantial certified cases.

## Mandatory new definitions

Define at least one genuinely new concept not already in the catalog. I recommend introducing all three below.

### 1. Abundance / frequency of an element in a family
```lean
def elemFreq {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (a : α) : ℕ :=
  (F.filter fun s => a ∈ s).card
```

### 2. Frankl witness
```lean
def IsFranklWitness {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (a : α) : Prop :=
  2 * elemFreq F a ≥ F.card
```

### 3. Average set size / weight potential
This is the key bridge object.
```lean
def totalWeight {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) : ℕ :=
  ∑ s in F, s.card
```

Then prove the double-counting identity:
```lean
theorem totalWeight_eq_sum_elemFreq
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α)) :
  totalWeight F = ∑ a : α, elemFreq F a
```

This theorem is foundational: it turns Frankl into a statement about the maximum coordinate of a frequency vector, and opens an information-theoretic interpretation.

### 4. Lattice/closure reformulation
Define a predicate expressing that `F` is union-closed and contains bottom:
```lean
def IsUnionClosedFamily {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) : Prop :=
  ∅ ∈ F ∧ ∀ A ∈ F, ∀ B ∈ F, A ∪ B ∈ F
```

Optionally define a closure operator induced by `F`:
```lean
def ucClosure {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (s : Finset α) : Finset α :=
  F.fold (· ∩ ·) univ ? -- or define as intersection of members of F containing s
```

If you can make this precise cleanly, prove that members of `F` are exactly fixed points of the closure operator. This would be a major formal bridge to the catalog’s closure theorems.

## At least 3 deep theorems to prove

You must include at least 3 genuinely nontrivial theorems with multi-step proofs. The strongest and most realistic targets are these:

---

### Theorem 1: Double-counting identity for finite families
This is not trivial bookkeeping; prove it by induction on `F`, using finset extensionality, membership splitting, and a careful interchange of sums.

```lean
theorem totalWeight_eq_sum_elemFreq
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α)) :
  totalWeight F = ∑ a : α, elemFreq F a
```

#### Why this matters
This is the formal “mass conservation law” of the theory. It converts set-system combinatorics into an additive potential. It is the gateway to average-frequency bounds, entropy analogies, and algorithmic witness search.

#### Proof strategy options
- **Strategy A: induction on `F` as a finset**
  1. Prove the statement for `∅`.
  2. Insert a set `s`, split whether `a ∈ s`, and rewrite filtered cardinals.
  3. Use `Finset.sum_add_distrib` and cardinal lemmas for filters.
  This is the most Lean-realistic path.

- **Strategy B: incidence bipartite graph**
  1. Define the incidence relation between elements and sets.
  2. Count edges by summing over sets and by summing over elements.
  3. Translate edge counts back to `totalWeight` and `elemFreq`.
  This is conceptually cleaner and creates a graph-theoretic bridge.

- **Strategy C: matrix viewpoint**
  1. Associate a `0-1` incidence matrix.
  2. Show row-sum equals total weight and column-sum equals total frequency.
  3. Use finite sum commutation.
  Best if you want a linear-algebraic paper narrative, but heavier in Lean.

---

### Theorem 2: Average-size criterion implies Frankl witness
Prove a sufficient condition: if the average set size is at least half the ground-set size, then some element is frequent in the Frankl sense.

A precise arithmetic version:

```lean
theorem exists_frequent_of_large_average
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α))
  (h_avg :
    F.card * Fintype.card α ≤ 2 * totalWeight F)
  (hF : F.Nonempty) :
  ∃ a : α, IsFranklWitness F a
```

Interpretation: if the average set in `F` contains at least half the ground elements, then some element lies in at least half the sets.

#### Why this matters
This gives a powerful certified partial result independent of union-closure. It reframes the Frankl search as an extremal averaging problem. In practice, many structured union-closed families satisfy this criterion.

#### Proof strategy options
- **Strategy A: contradiction via total frequency bound**
  1. Assume every element appears in fewer than half the sets.
  2. Sum over all elements to get `2 * totalWeight F < F.card * |α|`.
  3. Contradict `h_avg` using Theorem 1.
  This is the cleanest and should be the primary route.

- **Strategy B: maximal-frequency element**
  1. Choose `a` maximizing `elemFreq F a`.
  2. Show if `a` were below half, then all frequencies are below half.
  3. Contradict the average lower bound.
  This may require `Fintype.exists_max_image`; good if you want an optimization flavor.

---

### Theorem 3: Frankl holds for families with a universal element or top-rich generators
Prove a genuine nontrivial certified case.

Universal-element version:
```lean
theorem frankl_of_universal_element
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α)) (a : α)
  (h_half :
    2 * ((F.filter fun s => a ∈ s).card) ≥ F.card) :
  ∃ b : α, IsFranklWitness F b
```
This is tautological and not enough alone.

Instead prove a structural sufficient condition such as:

```lean
theorem frankl_of_all_nonempty_contain_fixed
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α)) (a : α)
  (h_empty : ∅ ∈ F)
  (h_fixed : ∀ s ∈ F, s ≠ ∅ → a ∈ s)
  (h_nontrivial : ∃ s ∈ F, s.Nonempty) :
  IsFranklWitness F a
```

This is easy but legitimate only as a base case.

Push further with a genuinely structural theorem:

```lean
theorem frankl_of_pairwise_disjoint_generators
  {α : Type*} [Fintype α] [DecidableEq α]
  (G : Finset (Finset α))
  (hG_nonempty : G.Nonempty)
  (h_disj : ∀ A ∈ G, ∀ B ∈ G, A ≠ B → Disjoint A B)
  (h_noempty : ∀ A ∈ G, A.Nonempty)
  :
  let F := G.powerset.image (fun H => H.biUnion id)
  ∃ a : α, IsFranklWitness F a
```

This says: if a union-closed family is generated by pairwise disjoint nonempty blocks, then Frankl holds. In fact each block element appears in exactly half the unions containing its block, giving a clean witness.

#### Why this matters
This theorem isolates a large algebraically natural class where the conjecture is provable by explicit combinatorial symmetry. It creates a bridge to product measures, Boolean algebras, and coding theory.

#### Proof strategy options
- **Strategy A: explicit counting by powerset symmetry**
  1. Build the family from unions of generators.
  2. Fix an element in a generator block.
  3. Count subsets of generators that include that block: exactly half.
  This is likely the most elegant.

- **Strategy B: semilattice product decomposition**
  1. Show the generated family is isomorphic to a Boolean lattice on `G`.
  2. Translate membership of `a` to the event “chosen subset contains the generator of `a`.”
  3. Use Boolean-lattice cardinality symmetry.
  This is more conceptual and strengthens the lattice narrative.

---

### Theorem 4: Lattice-theoretic reformulation
This is the cross-domain theorem you should definitely include.

Prove that a finite union-closed family under inclusion forms a finite join-semilattice with bottom, and that Frankl’s conjecture becomes a statement about join-irreducible support frequencies.

A Lean-level theorem could be:

```lean
theorem unionClosed_induces_joinSemilattice
  {α : Type*} [DecidableEq α]
  (F : Finset (Finset α))
  (hF : IsUnionClosedFamily F) :
  ∀ A ∈ F, ∀ B ∈ F, A ∪ B ∈ F
```

But that is only unpacking a definition. Go deeper:

```lean
theorem mem_fixedPoints_ucClosure_iff
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α))
  (hF : IsUnionClosedFamily F)
  (s : Finset α) :
  s ∈ F ↔ ucClosure F s = s
```

If closure formalization becomes too heavy, then prove a theorem about principal filters or maximal elements in the inclusion poset. The point is to connect to closure/lattice objects already present in the catalog.

#### Why this matters
This turns Frankl from an isolated set-family conjecture into a theorem about finite closure spaces and semilattice dynamics. That opens direct lines to abstract convexity, formal concept analysis, and causal closure systems.

## Cross-domain connection theorem

You are required to include at least one theorem connecting union-closed families to another domain. The best option here is an information-theoretic or closure-theoretic bridge.

### Option A: Information/entropy-style inequality
Interpret `elemFreq F a / F.card` as the empirical marginal probability that a random set from `F` contains `a`. Then Theorem 1 implies:
the average set size equals `∑_a P(a ∈ S)` times `|F|`.

Formal arithmetic version:
```lean
theorem average_card_eq_sum_marginals
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α)) :
  totalWeight F = ∑ a : α, elemFreq F a
```
In `RESEARCH_PAPER.md`, explain this as a zero-order entropy balance law.

### Option B: Closure-system bridge using catalog theorems
Build explicitly on:
- `cl_empty_closed`
- `closed_union_closure_closed`

These suggest a closure-theoretic environment where empty-set closure and closure under unions are already formalized. Your task is to explain and, if possible, formalize that a finite union-closed family is a finite closure system of fixed points of a suitable closure operator. Then use the catalog closure lemmas as proof scaffolding for fixed-point stability under unions.

### Option C: Causal/Zariski analogy
The theorem `finite_causal_union_is_zariski_closed` is not directly about Frankl, but conceptually it says “finite unions preserve closedness” in a geometric closure regime. Use this in the paper and comments to motivate a unification:
- union-closed families as discrete closure spaces,
- Zariski-closed unions as algebraic closure spaces,
- Frankl witnesses as heavy atoms in a finite closure universe.

This is the kind of cross-pollination that can open a new field: **extremal closure theory**.

## Recommended file-level theorem package

Your Lean file should contain at minimum:

1. `elemFreq`
2. `IsFranklWitness`
3. `totalWeight`
4. `IsUnionClosedFamily`
5. `totalWeight_eq_sum_elemFreq`
6. `exists_frequent_of_large_average`
7. one structural Frankl theorem:
   - `frankl_of_all_nonempty_contain_fixed`, or preferably
   - `frankl_of_pairwise_disjoint_generators`
8. one closure/lattice bridge theorem:
   - `mem_fixedPoints_ucClosure_iff`, or another substantial reformulation

## How to build on the catalog

### Existing theorem: `frankl_union_closed_conjecture`
File: `Speculative/Frankl/Conjecture.lean`

First inspect whether this theorem is:
- fully proved,
- stated in too weak/too specialized a form,
- or present only speculatively.

If it is already fully formalized in the exact finite-set form, then your mission is **not** to duplicate it. Instead:
- derive corollaries from it in the frequency-potential language,
- prove equivalence with your lattice/closure reformulation,
- build an algorithm that finds a witness element from the certified proof structure,
- compare direct combinatorial witnesses with closure-theoretic witnesses.

### Existing closure theorems
- `cl_empty_closed`
- `closed_union_closure_closed`

Use these as conceptual and possibly technical support for showing that the “closed objects” viewpoint is not ad hoc. If their ambient structures differ from `Finset (Finset α)`, abstract your union-closed family into a closure-style object and prove transfer lemmas.

## Proof architecture guidance

### Most promising overall route
The strongest path is:

1. Develop the frequency potential formalism (`elemFreq`, `totalWeight`).
2. Prove the double-counting theorem.
3. Derive average-based sufficient conditions for Frankl witnesses.
4. Prove one substantial structural class theorem via explicit combinatorial symmetry.
5. Formalize a closure/lattice reformulation and explain how it changes the attack surface of the conjecture.

This yields a coherent mini-theory rather than disconnected lemmas.

### Tactics you should visibly use
Because trivial proofs are forbidden, aim for proofs featuring:
- induction on finite families,
- `rcases` decomposition of witnesses/nonempty hypotheses,
- `by_contra` for average-frequency contradiction arguments,
- `calc` chains for arithmetic transformations,
- `field_simp` if you choose a rational average formulation,
- finite sum rewrites and filter-cardinality manipulations.

## Falsifiable conjecture with computational test

You must state at least one clear conjecture and give a disproof protocol.

### Conjecture A: Average-threshold strengthening for union-closed families
For every finite union-closed family `F` with `∅ ∈ F`, if `F` is not a chain under inclusion, then
```text
totalWeight F ≥ F.card * (|supp F| / 2)
```
where `supp F = ⋃₀ F` is the active ground support.

Equivalent prediction: every non-chain union-closed family has average set size at least half the support size.

This is falsifiable by exhaustive search over finite families on small ground sets.

### Lean-facing definition
```lean
def support {α : Type*} [DecidableEq α] (F : Finset (Finset α)) : Finset α :=
  F.biUnion id
```

### Computational test
Enumerate all union-closed families on `n ≤ 6` labeled elements; for each:
- verify union-closedness,
- compute `support F`,
- compute `2 * totalWeight F` and compare to `F.card * support F.card`,
- record counterexamples.

If false, isolate the minimal counterexample and formalize its structure. If true for small `n`, use this as evidence for a stronger average-based route to Frankl.

## Verified algorithm / computational method

You must provide a certified algorithm, not just existence theorems.

### Algorithm target: witness search by frequency maximization
Define an algorithm that returns an element of maximum frequency on the support of `F`:
```lean
def argmaxElemFreq {α : Type*} [Fintype α] [DecidableEq α]
    (F : Finset (Finset α)) : α := ...
```

Then prove:
```lean
theorem argmaxElemFreq_spec
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α)) :
  ∀ a : α, elemFreq F a ≤ elemFreq F (argmaxElemFreq F)
```

And derive:
```lean
theorem argmax_is_witness_of_large_average
  {α : Type*} [Fintype α] [DecidableEq α]
  (F : Finset (Finset α))
  (h_avg : F.card * Fintype.card α ≤ 2 * totalWeight F)
  (hF : F.Nonempty) :
  IsFranklWitness F (argmaxElemFreq F)
```

This turns the theory into an executable search procedure with a certified correctness theorem under verifiable hypotheses.

## demo.py requirements

Your `demo.py` must:
- enumerate union-closed families on small ground sets,
- compute `elemFreq`, `totalWeight`, `support`,
- find `argmaxElemFreq`,
- test the average-threshold conjecture,
- display examples where the certified theorem proves Frankl,
- visualize the family as a join-semilattice / Hasse diagram if feasible.

Interactive features:
- user chooses `n`,
- user selects a generating family,
- script forms its union-closure,
- script highlights frequent elements and verifies theorems numerically.

## RESEARCH_PAPER.md requirements

Your paper must be standalone and explain:

1. The classical Frankl conjecture.
2. Why the frequency-potential formalism is a new angle.
3. The exact formal definitions and verified theorems.
4. The double-counting theorem as the backbone.
5. The structural classes where Frankl is certified.
6. The closure/lattice reinterpretation.
7. The algorithmic witness-search method.
8. The conjecture and experimental protocol.

The paper should read like a real research note in extremal combinatorics with formal methods, not a code dump.

## FUTURE_DIRECTIONS.md requirements

You must include 3–5 falsifiable hypotheses with explicit tests. Recommended list:

1. **Average-threshold conjecture**  
   Test by exhaustive enumeration on supports up to size 6 or 7.

2. **Disjoint-generator exact-half phenomenon**  
   In every family generated by `k` pairwise disjoint nonempty blocks, each block element occurs in exactly `2^(k-1)` sets.  
   Test by generator enumeration.

3. **Closure-fixed-point strengthening**  
   Every finite closure system arising from a union-closed family admits a join-irreducible whose upper cone has size at least half the lattice.  
   Test by finite lattice enumeration.

4. **Support-compression heuristic**  
   Compression operations that preserve union-closure never decrease maximal element frequency.  
   Test by implementing random compressions and tracking `max_a elemFreq F a`.

5. **Entropy surrogate monotonicity**  
   The variance of element frequencies decreases under closure completion from a generating family to its union-closure.  
   Test experimentally on random generators.

## ARTICLE.md requirements

Write it in Scientific American style. Explain the conjecture as:
- a simple problem about collections of sets,
- unexpectedly linked to lattices, closure systems, and information balance,
- now equipped with certified algorithms and experimentally testable hypotheses.

The article should communicate wonder, not just correctness.

## Application keywords

Frankl conjecture; union-closed families; finite lattices; join-semilattices; closure operators; extremal combinatorics; formal verification; Lean 4; double counting; incidence geometry; entropy methods; algorithmic witness search; closure systems; formal concept analysis; Boolean symmetry; exhaustive enumeration; certified computation.

## Final directive

Do not spend the cycle on cosmetic reformulations. Build a compact but deep Lean theory around `elemFreq`, `totalWeight`, structural Frankl classes, and closure/lattice reformulation. The real prize is not merely one more theorem about union-closed families; it is a new verified language in which the conjecture becomes attackable from combinatorics, lattice theory, and information flow all at once.

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
