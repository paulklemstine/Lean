# Mode: discover

## Assignment: Vampire Numbers and Other Numerical Monsters: A Bestiary of Arithmetic Oddities

Do not treat this as recreational numerology. Treat it as the seed of a **formal theory of digit-interaction under multiplication**: a finite-combinatorial shadow of multiplicative number theory, automata, and symbolic dynamics. The right result here is not “we found more examples.” The right result is a **structural theorem** that turns folklore definitions into a reusable framework: digit multisets, factorization constraints, and asymptotic obstructions.

Your mission is to build a new Lean 4 theory of **arithmetical monsters** and extract the first genuinely nontrivial theorems about them.

You must produce:
1. a Lean file with **at least 3 substantial theorems** proved by real mathematics,
2. a **verified algorithm** for searching/classifying these monsters,
3. a **demo.py** that interactively explores examples and conjectures,
4. **FUTURE_DIRECTIONS.md** with 3–5 original research directions, each containing the exact sentences:
   - “The key insight is ...”
   - “Why now? ...”
   At least one direction must bridge to a different domain.
5. **RESEARCH_PAPER.md** as a standalone scientific paper explaining definitions, theorems, algorithms, significance, and open problems,
6. **ARTICLE.md** in Scientific American style, focused on the mathematics and why these strange objects reveal hidden structure in arithmetic. Do **not** focus on formal verification.

## Core conceptual upgrade

The naive definitions in base 10 should be reframed in terms of **digit multiset profiles** in an arbitrary base `b ≥ 2`. This is the decisive move: it turns ad hoc examples into a finite invariant.

Define for `n : ℕ` and base `b : ℕ`:
- `digits_b(n)` = the base-`b` digit list of `n`,
- `digitBag_b(n) : Fin b → ℕ` = multiplicity of each digit in `digits_b(n)`,
- `digitOverlap_b(m,n) = ∑ d, min (digitBag_b(m) d) (digitBag_b(n) d)`.

Then define:
- **vampire pair** `(x,y)` for `v` if `v = x*y` and `digitBag_b(v) = digitBag_b(x) + digitBag_b(y)`,
- **werewolf pair** if `digitOverlap_b(v,x) + digitOverlap_b(v,y)` satisfies an exact prescribed value,
- **ghost pair** if `digitOverlap_b(v,x) = 0` and `digitOverlap_b(v,y) = 0`,
- **zombie pattern** if `v` admits two qualitatively distinct factorization profiles, e.g. one with prime/composite asymmetry and one with a digit-bag coincidence.

This gives a formal language in which the decimal folklore becomes a special case.

## Novel definitions you should introduce

At least one of these must be formalized as a new concept.

### 1. Digit bag and overlap profile
A finitely supported digit-count vector for numbers in base `b`. This is the correct abstraction.

Suggested Lean-style signatures:
```lean
def digitBag (b n : ℕ) : Fin b → ℕ := ...
def digitOverlap (b m n : ℕ) : ℕ := ∑ d : Fin b, Nat.min (digitBag b m d) (digitBag b n d)
```

### 2. Monster class relative to a digit relation
Generalize all creatures at once:
```lean
def IsMonsterRel (b : ℕ) (R : (Fin b → ℕ) → (Fin b → ℕ) → (Fin b → ℕ) → Prop)
    (v x y : ℕ) : Prop :=
  v = x * y ∧ R (digitBag b v) (digitBag b x) (digitBag b y)
```

Then specialize:
```lean
def IsVampire (b v x y : ℕ) : Prop := ...
def IsGhost   (b v x y : ℕ) : Prop := ...
def IsWerewolf (b : ℕ) (k v x y : ℕ) : Prop := ...
```

### 3. Digit-disjoint multiplicative pair
This is the most promising new structure:
```lean
def DigitDisjoint (b m n : ℕ) : Prop := digitOverlap b m n = 0
```
Ghost phenomena can then be phrased as `DigitDisjoint b v x ∧ DigitDisjoint b v y`.

This opens the door to graph theory: vertices are integers, edges connect digit-disjoint pairs. Multiplication induces a constrained hypergraph.

---

## Precise theorem targets

You need at least 3 theorems with nontrivial proofs. Below are four strong candidates. Prove at least three.

---

### Theorem 1: Modular digit-sum obstruction for vampire pairs
This is the first serious structural theorem and should be central.

**Mathematical statement.**  
Let `b ≥ 2`. If `v = x*y` and `digitBag b v = digitBag b x + digitBag b y`, then
\[
v \equiv x + y \pmod{b-1}.
\]
Equivalently, since `v = xy`,
\[
xy \equiv x+y \pmod{b-1},
\]
so
\[
(x-1)(y-1) \equiv 1 \pmod{b-1}.
\]

This gives a necessary congruence condition for every vampire pair in every base. In base 10 this becomes
\[
xy \equiv x+y \pmod 9.
\]

**Lean 4 type signature target.**
```lean
theorem IsVampire.modEq_sum
    {b v x y : ℕ}
    (hb : 2 ≤ b)
    (hV : IsVampire b v x y) :
    v % (b - 1) = (x + y) % (b - 1) := ...
```

A stronger formulation via `Nat.ModEq` is preferable:
```lean
theorem IsVampire.modEq_sum'
    {b v x y : ℕ}
    (hb : 2 ≤ b)
    (hV : IsVampire b v x y) :
    Nat.ModEq (b - 1) v (x + y) := ...
```

**Why this matters.**  
This is not a toy fact. It converts a combinatorial digit condition into a multiplicative congruence obstruction. It is the beginning of a sieve theory for vampire numbers.

**Proof strategy options.**
- **Strategy A: digit-sum congruence via base expansion.**  
  Prove a general lemma:
  ```lean
  theorem modEq_digitSum {b n : ℕ} (hb : 2 ≤ b) :
    Nat.ModEq (b - 1) n ((digits b n).sum) := ...
  ```
  because `b ≡ 1 mod (b-1)`. Then use bag equality to identify digit sums:
  `sumDigits(v) = sumDigits(x) + sumDigits(y)`.
  This is the cleanest and most reusable path.
- **Strategy B: bag-to-polynomial evaluation.**  
  Interpret a digit bag as a polynomial in a formal variable and evaluate at `1`. This is conceptually elegant and may generalize to weighted digit statistics. More overhead, but more visionary.
- **Strategy C: induction on digit list.**  
  Build the congruence directly from the recursive base expansion theorem in Mathlib for digits. Less elegant, but robust if `digits` lemmas are available.

**Most promising:** Strategy A.

---

### Theorem 2: Ghost numbers are impossible in base 2
This is an exact theorem, not asymptotic handwaving, and it shows the theory depends sharply on the alphabet size.

**Mathematical statement.**  
In base `2`, no positive integer can be a ghost number. Indeed every positive binary expansion contains the digit `1`, so for `v = x*y` with `x,y,v > 0`, one has `digitOverlap 2 v x ≥ 1` and `digitOverlap 2 v y ≥ 1`.

**Lean 4 type signature target.**
```lean
theorem not_IsGhost_base2
    {v x y : ℕ}
    (hv : 0 < v) (hx : 0 < x) (hy : 0 < y) :
    ¬ IsGhost 2 v x y := ...
```

Or more structurally:
```lean
theorem pos_not_digitDisjoint_base2
    {m n : ℕ}
    (hm : 0 < m) (hn : 0 < n) :
    ¬ DigitDisjoint 2 m n := ...
```

**Why this matters.**  
This is the first “phase transition” theorem: monster species depend on base. It suggests a taxonomy by alphabet size and opens a finite-state viewpoint.

**Proof strategy options.**
- **Strategy A: prove every positive binary number contains a `1`.**  
  Then `digitBag 2 n 1 ≥ 1` for all `n > 0`, hence overlap is nonzero.
- **Strategy B: use highest-set-bit characterization.**  
  Show binary digits of positive numbers are obtained from repeated division by 2 and terminate with a `1`.
- **Strategy C: contradiction from all-zero digits.**  
  If `digitOverlap 2 m n = 0`, then one of the numbers lacks digit `1`, impossible if positive.

**Most promising:** Strategy A.

---

### Theorem 3: Length additivity obstruction for vampire pairs
This theorem ties the digit-bag condition to place-value growth.

Let `len_b(n)` be the number of base-`b` digits of `n` for `n > 0`.

**Mathematical statement.**  
If `IsVampire b v x y`, then
\[
\operatorname{len}_b(v) = \operatorname{len}_b(x) + \operatorname{len}_b(y).
\]
In particular, if `len_b(v)` is odd, then `v` cannot be represented as a vampire number with equal-length fangs.

This follows because digit-bag equality preserves total digit count.

**Lean 4 type signature target.**
```lean
def digitLen (b n : ℕ) : ℕ := ...

theorem IsVampire.digitLen_add
    {b v x y : ℕ}
    (hb : 2 ≤ b)
    (hv : 0 < v) (hx : 0 < x) (hy : 0 < y)
    (hV : IsVampire b v x y) :
    digitLen b v = digitLen b x + digitLen b y := ...
```

**Why this matters.**  
This extracts the familiar “even number of digits” folklore from a theorem that works in every base and every generalized monster class defined by bag conservation.

**Proof strategy options.**
- **Strategy A: total mass of bag.**  
  Prove `∑ d, digitBag b n d = digitLen b n`. Then sum both sides of bag equality.
- **Strategy B: list-length route.**  
  Define digit bag from the digit list and prove bag mass equals list length.
- **Strategy C: multiset cardinality route.**  
  If you package digits as a multiset, cardinality is automatic.

**Most promising:** Strategy B, unless Mathlib support for multisets is especially smooth.

---

### Theorem 4: A graph-theoretic infinitude theorem for digit-disjoint pairs in bases `b ≥ 3`
This is the most cross-domain theorem and could become the paper’s conceptual centerpiece.

**Mathematical statement.**  
For every base `b ≥ 3`, there exist infinitely many pairs of positive integers `m,n` such that `DigitDisjoint b m n`.

A very explicit family should be used. For example, in base `b`, numbers of the form
\[
m_k = \underbrace{11\ldots1}_{k \text{ digits in base } b}, \qquad
n_\ell = \underbrace{22\ldots2}_{\ell \text{ digits in base } b}
\]
are digit-disjoint for all `k, \ell`, provided digits `1` and `2` are distinct in base `b`.

**Lean 4 type signature target.**
```lean
theorem infinitely_many_digitDisjoint_pairs
    {b : ℕ} (hb : 3 ≤ b) :
    Set.Infinite { p : ℕ × ℕ | 0 < p.1 ∧ 0 < p.2 ∧ DigitDisjoint b p.1 p.2 } := ...
```

A simpler existential-family theorem is also acceptable:
```lean
theorem exists_digitDisjoint_pair_ge
    {b N : ℕ} (hb : 3 ≤ b) :
    ∃ m n ≥ N, DigitDisjoint b m n := ...
```

**Why this matters.**  
This reframes ghost-like constraints as an infinite graph problem. The digit-disjointness graph has infinitely many edges for `b ≥ 3` and none for positive numbers when `b = 2`. That is a true structural dichotomy.

**Proof strategy options.**
- **Strategy A: explicit repdigit construction.**  
  Define base-`b` repdigits using finite geometric sums and prove their digit bags are supported on a single digit.
- **Strategy B: automata language approach.**  
  Characterize numbers whose digit strings lie in a one-letter regular language. Overkill, but conceptually beautiful.
- **Strategy C: induction on length of repdigit strings.**  
  Build the family recursively and prove support invariance.

**Most promising:** Strategy A.

---

## Cross-domain theorem requirement

You must include at least one theorem connecting this subject to another domain. The strongest option here is **graph theory / symbolic dynamics / automata**.

### Recommended cross-domain connection: digit-disjointness graph
Define a graph on positive integers:
```lean
def DigitDisjointGraph (b : ℕ) : SimpleGraph ℕ := ...
```
with adjacency given by digit disjointness.

Then prove a theorem such as:
- in base `2`, the positive subgraph has no edges;
- in base `b ≥ 3`, the positive subgraph has infinitely many edges;
- for any fixed digit subset `S ⊂ Fin b`, numbers using only digits in `S` form an induced structured subgraph.

This is a genuine bridge:
- **number theory**: multiplication and congruences,
- **combinatorics/graph theory**: adjacency by disjoint support,
- **automata/language theory**: numbers represented by regular digit languages.

Application keywords: **digit automata, symbolic dynamics, sparse supports, additive combinatorics, congruence sieve, arithmetic graph theory**.

A second possible bridge, if you have time, is to information theory:
- define digit entropy of `n` from normalized `digitBag b n`,
- compare entropy of `v` with those of `x,y` in vampire-like decompositions.
Even one rigorous inequality would be interesting, but only do this if the core theorems are already secure.

---

## Conjectures with computationally testable predictions

At least one falsifiable conjecture must be stated, with a clear search protocol in Lean and Python.

### Conjecture A: Ghost scarcity in base 10
For decimal ghost triples `(v,x,y)` with `v = x*y`, the counting function
\[
G(N) = \#\{v \le N : \exists x,y,\ IsGhost\ 10\ v\ x\ y\}
\]
satisfies
\[
G(N) = o(N^\varepsilon)
\quad\text{for every } \varepsilon > 0.
\]
This is intentionally strong and likely false or difficult — good. It is falsifiable by search.

**Testable prediction:** empirical log-log slope of `G(N)` versus `N` decreases steadily for `N ≤ 10^8`.

### Conjecture B: Congruence-biased vampire scarcity
Among vampire pairs in base 10, the congruence condition
\[
(x-1)(y-1) \equiv 1 \pmod 9
\]
is asymptotically the dominant local obstruction, i.e. after conditioning on digit lengths and trailing-zero exclusions, surviving pairs are equidistributed across admissible residue classes.

**Testable prediction:** the proportion of candidate factor pairs eliminated by the mod-9 obstruction stabilizes near a constant predicted from residue statistics.

### Conjecture C: Interval existence
Every sufficiently large even-digit decade interval
\[
[10^{2k}, 10^{2k+2})
\]
contains a vampire number.

Do **not** claim a proof unless you genuinely have one. Instead:
- state it cleanly,
- build an exhaustive checker up to the largest feasible bound,
- record positive evidence.

---

## Verified algorithmic deliverable

You must implement a verified search/classification method, not just theorem statements.

### Required algorithm
Create a function that, given `b`, `N`, and factor bounds, enumerates all triples `(v,x,y)` with `v ≤ N` satisfying one of the monster predicates.

Suggested Lean interface:
```lean
def classifyMonsterTriples (b N : ℕ) : List (ℕ × ℕ × ℕ × String) := ...
```
Better:
```lean
inductive MonsterKind | vampire | werewolf | ghost | zombie

def classifyMonsterTriples (b N : ℕ) : List (MonsterKind × ℕ × ℕ × ℕ) := ...
```

You must prove at least a **soundness theorem**:
```lean
theorem classifyMonsterTriples_sound
    {b N : ℕ} :
    ∀ t ∈ classifyMonsterTriples b N,
      match t with
      | (MonsterKind.vampire, v, x, y) => IsVampire b v x y
      | (MonsterKind.ghost,   v, x, y) => IsGhost b v x y
      | ...
```

Completeness on a bounded search space is even better if feasible.

### demo.py
The Python demo should:
- enumerate monsters up to a user-specified bound,
- display histogram by number of digits,
- show residue classes mod `9` or mod `b-1`,
- build and visualize the digit-disjointness graph for a small range,
- test the conjectures empirically.

---

## Suggested proof architecture in Lean

### Step 1: Build reusable digit infrastructure
You need general lemmas, not decimal-only hacks.
- define digit bags from base digits,
- prove support/cardinality lemmas,
- prove sum-of-digits congruence modulo `b-1`,
- prove positivity/length facts.

### Step 2: Prove structural theorems
Prioritize:
1. `IsVampire.modEq_sum'`
2. `pos_not_digitDisjoint_base2` / `not_IsGhost_base2`
3. `IsVampire.digitLen_add`
4. infinitude of digit-disjoint pairs for `b ≥ 3`

### Step 3: Implement and verify search
Use the structural theorems as sieves:
- mod `b-1` sieve for vampire candidates,
- base-2 impossibility to eliminate ghost search there,
- length constraints to prune factor pairs.

This turns theorem-proving into algorithmic speedup, which is exactly the right scientific loop.

---

## Concrete 2–3 step proof sketches

### Proof sketch for Theorem 1
1. Prove `n ≡ sumDigits_b(n) [MOD b-1]` by unfolding base expansion and using `b ≡ 1 [MOD b-1]`.
2. Show `sumDigits_b(v) = sumDigits_b(x) + sumDigits_b(y)` from digit-bag equality by summing multiplicities weighted by the digit value.
3. Combine with `v = x*y` to obtain `xy ≡ x+y [MOD b-1]`, then algebraically rewrite to `(x-1)(y-1) ≡ 1 [MOD b-1]`.

### Proof sketch for Theorem 2
1. Prove every positive binary number has at least one digit `1` in its base-2 expansion.
2. Deduce `digitBag 2 n 1 > 0` for every positive `n`.
3. Therefore `digitOverlap 2 m n ≥ 1` for positive `m,n`, contradicting digit-disjointness.

### Proof sketch for Theorem 4
1. Define repdigits `repdigit b d k = d * ∑_{i < k} b^i`.
2. Prove that for `d < b`, the base-`b` digits of `repdigit b d k` are exactly `k` copies of `d`.
3. For `b ≥ 3`, choose `d₁ = 1`, `d₂ = 2`; then all corresponding repdigit pairs are digit-disjoint, yielding infinitely many examples.

---

## What not to do

- Do **not** “prove” existence results by brute-force enumeration inside Lean unless the theorem itself is explicitly bounded and computational.
- Do **not** leave the work at the level of folklore examples.
- Do **not** restrict everything to base 10 unless a theorem truly uses decimal arithmetic.
- Do **not** make density claims without rigorous asymptotic machinery; instead convert them into explicit conjectures plus computational evidence.

---

## Revolutionary significance

If done correctly, this project opens a new microfield: **arithmetic creature theory as digit-constraint number theory**. The breakthrough is not the monsters; it is the realization that digit-factor interactions can be studied with:
- congruence obstructions,
- graph structures,
- regular-language methods,
- entropy/statistical heuristics,
- verified search.

This creates a platform for follow-on work in:
- **automatic sequences and finite automata**,
- **symbolic dynamics of arithmetic maps**,
- **digit-constrained factorization problems**,
- **probabilistic number theory of finite alphabets**,
- **algorithmic sieves for combinatorial factorization classes**.

The playful names are bait. The mathematics should be real enough that, once formalized, others can build on it.

## Application keywords
digit combinatorics, arithmetic automata, symbolic dynamics, congruence sieve, digit multiset invariants, repdigits, arithmetic graph theory, additive combinatorics, computational number theory, factorization constraints, asymptotic rarity, regular languages

## Deliverables checklist

You must deliver all of the following:

- A Lean development with:
  - at least one **new concept/structure** not already in the catalog,
  - at least **3 substantial theorems** with nontrivial proofs,
  - minimal `sorry`,
  - at least one **cross-domain theorem**.
- A **verified algorithm** for monster classification.
- `demo.py` with interactive exploration and empirical conjecture testing.
- `FUTURE_DIRECTIONS.md` with 3–5 directions, each containing:
  - “The key insight is ...”
  - “Why now? ...”
  with at least one direction bridging to another domain.
- `RESEARCH_PAPER.md` as a standalone paper.
- `ARTICLE.md` in Scientific American style, about the mathematical ideas and significance.

Build the theory so that the names vampire, werewolf, ghost, zombie become the visible surface of something much deeper: a rigorous theory of how multiplication rearranges finite symbolic information.

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
