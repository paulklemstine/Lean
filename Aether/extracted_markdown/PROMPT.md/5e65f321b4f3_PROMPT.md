Soli Deo Gloria

## Assignment: Direction 1: Depth Rigidity of Recursive Majority (Grand Challenge)

**Mode:** prove

Prove a genuinely new theorem package around **depth rigidity for recursive ternary majority**, with exact formal statements, a verified search procedure, and a cross-domain lower-bound mechanism. This should not be a cosmetic extension of catalog transfer theorems: the target is to isolate a natural Boolean function family where **DAG sharing fails to buy parallel depth**.

The scientific objective is to force a decisive answer to the following rigidity phenomenon:

> For recursive ternary majority, does monotone circuit depth coincide with monotone formula depth up to an additive constant, and in fact equal the recursion depth on the nose or within a universal constant?

If true, this would give a canonical, explicit family witnessing that **reusability does not accelerate monotone parallel computation**. If false, the counterexample would be equally revolutionary: it would exhibit a concrete boundary where the transfer principle from formulas to circuits breaks at the finest scale.

---

## Core Mathematical Objects

Work with the ternary majority gate
\[
\operatorname{Maj}_3(a,b,c) := (a\wedge b)\vee(a\wedge c)\vee(b\wedge c),
\]
and define recursively the \(n\)-level recursive majority function
\[
\operatorname{RecMaj}_0(x)=x,\qquad
\operatorname{RecMaj}_{n+1}(x_{1},\dots,x_{3^{n+1}})
=
\operatorname{Maj}_3\big(
\operatorname{RecMaj}_n(\text{block}_1),
\operatorname{RecMaj}_n(\text{block}_2),
\operatorname{RecMaj}_n(\text{block}_3)\big).
\]

You should introduce at least one **new formal notion** not already in the catalog, for example:

- `MonotoneKWCost f` : the minimum communication cost of the monotone Karchmer–Wigderson game for a monotone Boolean function `f`;
- `RecursiveMajorityProfile n` : a structure encoding recursion level, arity, variable partition, and canonical formula depth;
- `BlockSensitivityTree n` or `MajCertificateRank n` : a combinatorial invariant designed to lower-bound KW cost.

At least one of these must be used nontrivially in a theorem.

---

## Precise Target Theorems

You must prove at least **3 substantial theorems** with nontrivial proofs. At least one should use induction over recursion depth, and at least one should use contradiction / minimal-counterexample / multi-step `calc` style reasoning.

### Theorem A: Exact recursive formula depth upper bound
Construct the canonical monotone formula and prove it has depth exactly `n` (or `n + 1`, depending on your depth convention — but fix conventions explicitly and use them consistently).

A possible Lean 4 target:

```lean
def recMaj : ℕ → List Bool → Bool
def formulaDepthRecMaj : ℕ → ℕ

theorem recMaj_formula_depth_upper :
  ∀ n : ℕ, MonotoneFormulaDepth (recMaj n) ≤ n
```

and ideally the matching lower bound:

```lean
theorem recMaj_formula_depth_lower :
  ∀ n : ℕ, n ≤ MonotoneFormulaDepth (recMaj n)
```

hence:

```lean
theorem recMaj_formula_depth_exact :
  ∀ n : ℕ, MonotoneFormulaDepth (recMaj n) = n
```

If the catalog already contains formula-depth machinery for recursive compositions, specialize it sharply here and make the proof exact, not asymptotic.

### Theorem B: KW lower bound for recursive majority
Define the monotone KW game associated to `recMaj n` and prove that its communication cost is at least `n`. The strongest target is exact equality.

Suggested Lean target:

```lean
def MonotoneKWCost (f : List Bool → Bool) : ℕ

theorem recMaj_kw_lower_bound :
  ∀ n : ℕ, n ≤ MonotoneKWCost (recMaj n)
```

and, if you can complete the protocol construction:

```lean
theorem recMaj_kw_exact :
  ∀ n : ℕ, MonotoneKWCost (recMaj n) = n
```

This is the conceptual heart of the project. It should not be a black-box import of a transfer theorem; prove a recursive adversary/game decomposition specific to recursive majority.

### Theorem C: Circuit-depth rigidity via transfer
Using the catalog transfer theorems together with Theorem B, prove a depth lower bound for monotone circuits computing `recMaj n`.

Suggested Lean target:

```lean
theorem recMaj_circuit_depth_lower :
  ∀ n : ℕ, n ≤ MonotoneCircuitDepth (recMaj n)
```

and combine with the explicit recursive circuit upper bound:

```lean
theorem recMaj_circuit_depth_upper :
  ∀ n : ℕ, MonotoneCircuitDepth (recMaj n) ≤ n
```

to conclude exact rigidity:

```lean
theorem recMaj_circuit_depth_exact :
  ∀ n : ℕ, MonotoneCircuitDepth (recMaj n) = n
```

If exact equality is blocked by a convention mismatch or an unavoidable constant from catalog APIs, prove the strongest formally precise version available:

```lean
theorem recMaj_depth_rigidity_additive :
  ∃ C : ℕ, ∀ n : ℕ,
    MonotoneCircuitDepth (recMaj n) ≤ MonotoneFormulaDepth (recMaj n) + C ∧
    MonotoneFormulaDepth (recMaj n) ≤ MonotoneCircuitDepth (recMaj n) + C
```

But exact equality is the real target.

---

## Stronger Breakthrough Variant

If the formal infrastructure permits, generalize from ternary majority to odd arity majority:

\[
\operatorname{Maj}_{2k+1}(x_1,\dots,x_{2k+1}) = 1
\iff \sum_i x_i \ge k+1,
\]
and define recursive \((2k+1)\)-ary majority trees. Then prove that for each fixed odd arity, recursive majority has depth exactly equal to recursion depth in monotone circuits.

Potential Lean target:

```lean
def oddMaj (k : ℕ) : List Bool → Bool
def recOddMaj (k n : ℕ) : List Bool → Bool

theorem recOddMaj_circuit_depth_exact :
  ∀ k n : ℕ, MonotoneCircuitDepth (recOddMaj k n) = n
```

Even a theorem for `k = 1` with a clear path to fixed `k` would already be important.

---

## Lean 4 Type Signature Guidance

You may need to adapt to existing catalog APIs, but the intended formal shape should look like this:

```lean
def maj3 : Bool → Bool → Bool → Bool :=
  fun a b c => (a && b) || (a && c) || (b && c)

def recMajVec : ℕ → {m : ℕ // m = 3^n} → (Fin m → Bool) → Bool
-- or a simpler list-based encoding if catalog infrastructure is list-centric

def MonotoneFormulaDepth : ((α → Bool) → Bool) → ℕ
def MonotoneCircuitDepth : ((α → Bool) → Bool) → ℕ
def MonotoneKWCost : ((α → Bool) → Bool) → ℕ

theorem recMaj_formula_depth_exact :
  ∀ n : ℕ, MonotoneFormulaDepth (recMaj n) = n

theorem recMaj_kw_exact :
  ∀ n : ℕ, MonotoneKWCost (recMaj n) = n

theorem recMaj_circuit_depth_exact :
  ∀ n : ℕ, MonotoneCircuitDepth (recMaj n) = n
```

If dependent vector encodings become too heavy, use `Fin (3^n) → Bool` as the semantic domain. If catalog objects are list-based, prove extensional equivalence lemmas to bridge representations.

---

## Required Proof Architecture: 2–3 Serious Strategies

You must pursue at least two proof paths in the code/comments/notes, and explain which one succeeds best.

### Strategy 1: Recursive monotone KW game decomposition
Most promising.

1. Define the monotone KW relation for `recMaj n`: given `x,y` with `recMaj n x = true` and `recMaj n y = false`, find an index `i` with `x_i = true`, `y_i = false`.
2. Prove a **one-level decomposition lemma**: any valid protocol for `recMaj (n+1)` induces a protocol that must first identify a winning top-level block among the three recursive subinstances.
3. Show the cost adds by at least 1 at each recursive layer:
   \[
   \mathrm{KW}(\operatorname{RecMaj}_{n+1}) \ge \mathrm{KW}(\operatorname{RecMaj}_n)+1.
   \]
4. Construct the matching protocol recursively to obtain equality.

This route is powerful because it converts a circuit-depth statement into a communication invariant with a clean recursive structure.

### Strategy 2: Certificate / adversary / block-sensitivity invariant
Potentially easier to formalize than full KW exactness.

1. Define a new combinatorial invariant, e.g. `MajCertificateRank n`, measuring the number of recursively forced branching decisions.
2. Prove it is at least `n` for `recMaj n` by induction.
3. Show any monotone circuit of depth `d` computing `f` must satisfy `MajCertificateRank f ≤ d`.
4. Deduce `n ≤ MonotoneCircuitDepth (recMaj n)`.

This route may avoid full protocol formalization while still yielding a genuine lower bound. It is especially attractive if the catalog already has decision-tree or certificate-complexity inequalities.

### Strategy 3: Hypergraph coloring / combinatorial obstruction
Cross-domain and high-risk.

1. Associate to each protocol/circuit a layered hypergraph encoding distinguishable 1-input / 0-input pairs.
2. Show recursive majority induces a ternary product hypergraph whose chromatic obstruction grows linearly in recursion depth.
3. Prove that depth-`d` circuits would force a coloring with too few colors, contradicting the obstruction.

This path is more speculative but could produce a beautiful cross-domain theorem connecting monotone complexity with extremal combinatorics.

**Recommendation:** Prioritize Strategy 1 for the main theorem, use Strategy 2 as a backup or auxiliary theorem, and include Strategy 3 in `FUTURE_DIRECTIONS.md` if not completed.

---

## Catalog Building Blocks You Must Exploit

Use the catalog references concretely, not decoratively.

### `Pythagorean/MonotoneCircuitComplexity.lean`
Use Theorems 2 and 4 as transfer machinery:
- one theorem should turn circuit depth into a communication/protocol or formula upper bound;
- the other should transfer lower bounds from structural invariants to monotone circuits.

Do not merely cite them. State exactly which inequality each theorem gives and compose them with your new recursive-majority-specific invariant.

### `Catalog/Pythagorean/DagDepthHierarchy/Theorems.lean`
Mine the analogous depth rigidity theorem for EML:
- extract the proof pattern showing that DAG sharing cannot collapse depth for a recursively defined function family;
- adapt the architecture, not the statement, to recursive majority;
- identify which ingredients are domain-independent and which must be rebuilt for majority.

A strong result would explicitly show that recursive majority and EML share a common rigidity schema:
\[
\text{self-similar obstruction} + \text{transfer theorem} \Longrightarrow \text{DAG depth rigidity}.
\]

If possible, package that schema as a reusable lemma.

---

## Cross-Domain Connections You Must Include

At least one theorem and all narrative documents must make explicit contact with another domain.

### 1. Communication complexity
This is the main bridge. Recursive majority should become a benchmark where **monotone circuit depth = KW communication complexity** exactly.

### 2. Combinatorics / hypergraph theory
Interpret each recursive layer as a 3-way branching obstruction. If formalization permits, prove a theorem relating recursive-majority distinguishing complexity to a coloring or covering number of an associated hypergraph.

Example theorem shape:

```lean
theorem recMaj_hypergraph_obstruction :
  ∀ n : ℕ, n ≤ HypergraphBranchDepth (recMajHypergraph n)
```

Even if auxiliary, this is valuable because it reframes circuit lower bounds as combinatorial coloring obstructions.

### 3. Optimization / SAT / algorithm design
Build a verified search procedure for small `n`:
- exhaustive or symmetry-reduced search for monotone circuits of depth `< n`;
- CNF encoding of gate semantics and monotonicity;
- a checker proving that any returned witness indeed computes `recMaj n`.

This computational component is mandatory and scientifically crucial: it gives empirical traction on tightness and on possible finite-depth anomalies.

### 4. Statistical physics / renormalization perspective
Recursive majority is a canonical hierarchical model. In `RESEARCH_PAPER.md` and `ARTICLE.md`, explain the analogy:
- each majority layer is a coarse-graining step;
- depth rigidity says each renormalization layer carries irreducible information-processing cost;
- DAG sharing fails to bypass scale-by-scale information flow.

This is exactly the kind of cross-pollination that can open a new subfield.

---

## Required New Definitions

You must introduce at least one new structure with mathematical bite. Strong candidates:

```lean
structure RecursiveMajorityProfile where
  level : ℕ
  arity : ℕ
  inputCount : ℕ
  canonicalDepth : ℕ
  blockPartition : Fin inputCount → Fin 3
```

```lean
def MonotoneKWCost (f : (Fin n → Bool) → Bool) : ℕ := ...
```

```lean
def MajCertificateRank : ((Fin n → Bool) → Bool) → ℕ := ...
```

```lean
def RecMajHypergraph (n : ℕ) : Hypergraph ...
```

At least one theorem must show your new notion is nontrivially equivalent to or bounds an existing complexity measure.

---

## Computational Test and Falsifiable Conjecture

You must state and investigate at least one falsifiable conjecture with a clear computational test.

### Primary conjecture
\[
\forall n,\quad \operatorname{MonotoneCircuitDepth}(\operatorname{RecMaj}_n)=n.
\]

### Tight finite-instance test
Search for a monotone circuit computing `RecMaj 3` on \(27\) inputs with depth `< 3`. If found, the exact conjecture fails immediately.

Then test `n = 4` with symmetry breaking and pruning. The computational test should be described so that a negative result is meaningful.

A formal conjecture statement for `FUTURE_DIRECTIONS.md`:

```lean
conjecture recMaj_depth_rigidity :
  ∀ n : ℕ, MonotoneCircuitDepth (recMaj n) = n
```

A stronger falsifiable hypothesis:

> **Hypothesis RM-SAT-3.** No monotone circuit of depth 2 computes `RecMaj 3`.
>
> **Test:** Encode all depth-2 monotone circuits with bounded fan-in over 27 variables as SAT; if SAT returns a witness and the checker validates it, the hypothesis is false.

A second hypothesis:

> **Hypothesis RM-KW-Exact.** `MonotoneKWCost (recMaj n) = n` for all `n ≤ 6`.
>
> **Test:** brute-force/adversarial protocol search or exact lower-bound enumeration for small `n`.

A third hypothesis:

> **Hypothesis RM-Arity.** For every fixed odd arity `2k+1`, recursive majority of arity `2k+1` has exact monotone circuit depth `n`.
>
> **Test:** verify small cases `k ∈ {1,2}`, `n ∈ {1,2,3}` by SAT/enumeration.

---

## Verified Algorithm / Computational Method

You must produce a verified algorithm, not just theorem statements.

Required deliverable:
1. A monotone circuit search engine for bounded depth and bounded fan-in.
2. A certified evaluator that checks whether a candidate circuit computes `recMaj n`.
3. Symmetry reduction exploiting:
   - permutation symmetry among the three top-level blocks,
   - monotonicity,
   - isomorphism rejection for gate relabelings.
4. A `demo.py` that:
   - constructs `recMaj n`,
   - searches for shallow monotone circuits,
   - displays search statistics,
   - if a candidate is found, verifies it independently,
   - otherwise reports lower-bound evidence.

This algorithmic side is not peripheral. It is part of the science.

---

## Why This Would Be a Breakthrough

If you prove exact depth rigidity for recursive majority, you open a new line of research at the intersection of:

- **monotone circuit complexity**
- **communication complexity**
- **hierarchical Boolean dynamics**
- **combinatorial obstructions**
- **algorithmic lower-bound search**

This would provide a benchmark family as canonical as parity is for non-monotone complexity, but for a subtler phenomenon: **whether shared subcomputation actually speeds up monotone parallel computation**.

A successful theorem here would make possible:

1. A general theory of **self-similar rigidity families**.
2. Transfer of renormalization-style ideas from statistical physics into complexity lower bounds.
3. SAT-guided discovery of sharp finite-depth obstructions.
4. A unifying schema relating EML-style DAG hierarchy results to recursive threshold functions.

If the conjecture fails, that is no less profound: it would pinpoint a natural setting where monotone DAG structure genuinely compresses depth, forcing a revision of current transfer heuristics.

---

## Mandatory Deliverables

You must produce **all** of the following.

### 1. Lean development
A file containing:
- the new definitions,
- at least 3 nontrivial theorems,
- proofs using induction / `rcases` / contradiction / `calc` / other serious tactics,
- minimal `sorry`,
- explicit reuse of the catalog theorems above.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 falsifiable scientific hypotheses**, each with:
- a precise conjecture,
- why it matters,
- a computational or mathematical test that could disprove it.

These must be genuine hypotheses, not vague “explore X” prompts.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the exact problem,
- the definitions,
- the main theorems,
- the proof architecture,
- computational experiments,
- significance and future work.

A reader with no access to the code must still understand the discovery.

### 4. `ARTICLE.md`
Write in Scientific American style:
- broad audience,
- vivid explanation,
- focus on ideas and significance,
- **do not focus on formal verification machinery**.

Explain recursive majority, why sharing might help, and why it astonishingly does not—or what counterexample was found.

### 5. Verified algorithm / computational method
As above: a certified bounded-depth search or protocol search procedure.

### 6. `demo.py`
Interactive demonstration of:
- recursive-majority construction,
- shallow monotone circuit search,
- verification of candidates,
- summary tables / visualizations.

---

## Application Keywords

monotone circuit complexity, recursive majority, Karchmer–Wigderson games, communication complexity, formula-vs-circuit separation, DAG depth rigidity, hypergraph coloring, SAT-based lower bounds, hierarchical computation, renormalization, threshold logic, extremal combinatorics, parallel complexity, self-similar obstructions, certified search

---

## Non-Negotiable Quality Bar

Do not settle for a vacuous upper bound or a brute-force finite case unless it is embedded in a theorem with conceptual content. The aim is a theorem package that a complexity theorist would recognize as a real advance:

\[
\text{recursive self-similarity} \;\Longrightarrow\; \text{exact communication cost} \;\Longrightarrow\; \text{exact monotone circuit depth}.
\]

Either prove this, or isolate the precise obstruction and produce the strongest counterexample framework. The result should feel like the first page of a new chapter, not the last page of an exercise set.

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
