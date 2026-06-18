## Assignment: Proof Complexity Beyond Syntax — Resolution Width, Cutting-Planes Rank, and Information Bottlenecks

You are not being asked to encode a textbook proof system. You are being asked to create a formal bridge between **proof complexity, information theory, circuit lower bounds, and SAT search dynamics**. The target is not a routine formalization of clauses and derivations; the target is a Lean development that makes it possible to *certify impossibility phenomena* in propositional proof systems and to expose structural reasons why modern search procedures succeed or fail.

The classical slogan “resolution is weak on pigeonhole principle” is not enough. The breakthrough direction is:

> **recast proof lower bounds as information bottlenecks and combinatorial expansion barriers, then formally separate proof systems by a certified resource invariant.**

This lets you connect:
- **resolution width/size** ↔ communication bottlenecks / Karchmer–Wigderson style complexity,
- **cutting planes rank/length** ↔ arithmetic compression of counting contradictions,
- **SAT solver behavior** ↔ proof search trajectories and certificate extraction,
- **entropy/compression lower bounds** ↔ unavoidable proof complexity.

Your file must contain at least **3 substantial theorems**, with real proof architecture, not definitional cleanup.

---

## Core Vision

Formalize a minimal but mathematically expressive framework for CNFs, resolution derivations, and cutting-planes derivations, then prove **nontrivial lower and upper bounds** around the pigeonhole principle and related counting principles.

The decisive idea is to avoid trying to formalize all of Haken’s theorem in one leap if the library infrastructure is not ready. Instead, formalize a chain of theorems that culminates in a **certified exponential lower bound once a width-growth lemma is established**, while also proving an explicit **cutting-planes short refutation** of the same principle. This already yields a genuine separation theorem in Lean.

---

## Precise Formalization Targets

### New definitions you should introduce
At least one must be novel relative to the current catalog.

1. `Clause n := Finset (Lit n)` where literals are signed variables.
2. `CNF n := Finset (Clause n)`.
3. `ResDerivation F C` — inductive derivability relation from CNF `F`.
4. `Clause.width : Clause n → ℕ`.
5. `ResProofSize F := infimum/minimum length of derivation of ⊥`.
6. `PHP_CNF m n` encoding injective map from `m` pigeons to `n` holes.
7. `CP_Ineq n` and `CPDerivation A b` for cutting planes over Boolean variables.
8. **Novel concept:** `ProofInformation n` or `WidthEntropyProfile F`, measuring how much combinatorial information a clause/proof state captures. This is where you create new science.

A good Lean-facing structure for the novel invariant is:
```lean
def ClauseBoundary {n : ℕ} (C : Clause n) (Ω : Finset (Assignment n)) : ℕ := ...
def WidthEntropyProfile {n : ℕ} (F : CNF n) : ℕ → ℕ := ...
```
or
```lean
def ProofInformation {n : ℕ} (D : List (Clause n)) : ℕ := ...
```
The point is to connect width growth to information compression impossibility.

---

## Breakthrough Theorem Package

You should aim for the following theorem package. Even if the full strongest asymptotic statement requires auxiliary lemmas and a carefully chosen encoding, the statements themselves should be explicit and formalization-driven.

### Theorem 1: Width lower bound for pigeonhole clauses
Prove that any resolution refutation of the pigeonhole CNF must contain a clause of large width.

A Lean-target statement could be:

```lean
theorem php_resolution_width_lower_bound
    (n : ℕ) (hn : 1 ≤ n) :
    ∀ D, ResRefutation (PHP_CNF (n+1) n) D →
      ∃ C ∈ D.clauses, n ≤ Clause.width C
```

A stronger asymptotic version, if your definitions support it:

```lean
theorem php_resolution_width_linear
    (n : ℕ) (hn : 1 ≤ n) :
    min_res_width (PHP_CNF (n+1) n) ≥ n
```

This is the combinatorial heart. If full Haken is too large, this theorem is still deep and field-opening because it turns the lower bound into a width obstruction.

---

### Theorem 2: Width-to-size lower bound for resolution
Prove a generic theorem converting width lower bounds into proof size lower bounds.

Suggested Lean type signature:

```lean
theorem resolution_size_lower_bound_of_width
    {n : ℕ} (F : CNF n) :
    min_res_width F > initial_width F →
    exp_lower_bound_from_width F ≤ min_res_size F
```

A more concrete, finite combinatorial version:

```lean
theorem resolution_size_ge_two_pow_width_gap
    {n : ℕ} (F : CNF n) (w0 w : ℕ)
    (hinit : initial_width F ≤ w0)
    (hwidth : w ≤ min_res_width F) :
    2 ^ (w - w0) ≤ min_res_size F
```

This theorem is revolutionary because it extracts **exponential proof complexity from a structural invariant**. It is also the right place to connect to existing catalog results like:
- `kw_witness_compression_lower_bound`
- `KW_lower_bound_implies_formula_depth_lower_bound`
- `incompressible_strings_lower_bound`
- `source_coding_lower_bound`

Interpretation: a narrow proof would compress the witness/search space too much.

---

### Theorem 3: Exponential lower bound for resolution on PHP
Combine Theorem 1 and Theorem 2.

```lean
theorem php_resolution_size_exponential
    (n : ℕ) (hn : 1 ≤ n) :
    ∃ c : ℕ, 2 ^ (c * n) ≤ min_res_size (PHP_CNF (n+1) n)
```

Or, if constants are awkward in Lean, use a cleaner linear exponent lower bound:
```lean
theorem php_resolution_size_explicit
    (n : ℕ) (hn : 1 ≤ n) :
    2 ^ (n - 1) ≤ min_res_size (PHP_CNF (n+1) n)
```

This is the formal crown jewel. A verified exponential lower bound for a canonical proof system is a major achievement even if your proof path is width-based rather than a direct formalization of every historical detail of Haken.

---

### Theorem 4: Short cutting-planes refutation of pigeonhole principle
Formalize counting inequalities and prove that cutting planes refutes PHP efficiently.

```lean
theorem php_cutting_planes_short_refutation
    (n : ℕ) :
    ∃ P, CPRefutation (PHP_CP (n+1) n) P ∧ poly_size_refutation n P
```

A more rank-oriented version:
```lean
theorem php_cutting_planes_rank_bound
    (n : ℕ) :
    min_cp_rank (PHP_CP (n+1) n) ≤ 2
```

This gives the separation:
- Resolution requires exponential size.
- Cutting planes has polynomial-size / constant-rank refutations.

---

### Theorem 5: Separation theorem
```lean
theorem cutting_planes_separates_from_resolution_on_php
    (n : ℕ) (hn : 1 ≤ n) :
    min_cp_size (PHP_CP (n+1) n) ≤ polynomial_bound n ∧
    2 ^ (n - 1) ≤ min_res_size (PHP_CNF (n+1) n)
```

This is the exact statement that opens the field inside the repository: **formal proof-system separation**.

---

### Theorem 6: Cross-domain theorem linking proof width to information/compression
This is where you must be bold. Use catalog lower bounds as actual building blocks.

Possible statement:
```lean
theorem narrow_resolution_induces_witness_compression
    {n : ℕ} (F : CNF n) :
    has_narrow_refutation F →
    ∃ enc : SatisfyingWitnessSpace F → BitVec k,
      k < critical_information_dimension F
```

Then derive contradiction from:
- `kw_witness_compression_lower_bound`
- or `incompressible_strings_lower_bound`
- or `source_coding_lower_bound`

A more Lean-manageable theorem:
```lean
theorem proof_information_lower_bound_of_kw
    {n : ℕ} [NeZero n] (F : CNF n) :
    KW_complexity F ≤ proof_information F →
    formula_depth_lower_bound F ≤ proof_information F
```

using
`KW_lower_bound_implies_formula_depth_lower_bound`.

This is the cross-domain contribution that makes the development paradigm-shifting rather than archival.

---

## Recommended Lean 4 Type Signatures

These are not mandatory exact names, but your file should contain statements at this level of precision.

```lean
inductive Sign | pos | neg

structure Lit (n : ℕ) where
  var : Fin n
  sign : Sign

abbrev Clause (n : ℕ) := Finset (Lit n)
abbrev CNF (n : ℕ) := Finset (Clause n)

def Clause.width {n : ℕ} (C : Clause n) : ℕ := C.card

inductive ResDerivable {n : ℕ} (F : CNF n) : Clause n → Type
| axiom {C} : C ∈ F → ResDerivable F C
| weaken {C D} : ResDerivable F C → C ⊆ D → ResDerivable F D
| resolve {C D : Clause n} {x : Fin n} :
    ResDerivable F (insert ⟨x, Sign.pos⟩ C) →
    ResDerivable F (insert ⟨x, Sign.neg⟩ D) →
    ResDerivable F (C ∪ D)  -- with side conditions excluding complementary literals

def ResRefutable {n : ℕ} (F : CNF n) : Prop :=
  ResDerivable F (∅)

def min_res_width {n : ℕ} (F : CNF n) : ℕ := ...
def min_res_size {n : ℕ} (F : CNF n) : ℕ := ...

theorem php_resolution_width_lower_bound
    (n : ℕ) (hn : 1 ≤ n) :
    n ≤ min_res_width (PHP_CNF (n+1) n) := ...

theorem resolution_size_ge_two_pow_width_gap
    {n : ℕ} (F : CNF n) :
    2 ^ (min_res_width F - initial_width F) ≤ min_res_size F := ...

theorem php_resolution_size_explicit
    (n : ℕ) (hn : 1 ≤ n) :
    2 ^ (n - 1) ≤ min_res_size (PHP_CNF (n+1) n) := ...

theorem php_cutting_planes_rank_bound
    (n : ℕ) :
    min_cp_rank (PHP_CP (n+1) n) ≤ 2 := ...

theorem cutting_planes_separates_from_resolution_on_php
    (n : ℕ) (hn : 1 ≤ n) :
    min_cp_rank (PHP_CP (n+1) n) ≤ 2 ∧
    2 ^ (n - 1) ≤ min_res_size (PHP_CNF (n+1) n) := ...
```

---

## Proof Strategy Architecture

You must provide at least 2–3 viable proof pathways in the code comments or accompanying paper. Here are the strongest candidates.

### Strategy A: Width method → size lower bound → PHP lower bound
**Most promising.**

1. **Define width formally** and prove that every resolution derivation can be normalized into a DAG/list derivation with width tracked monotonically enough for induction.
2. **Prove a width lower bound for PHP** using partial assignments / bottleneck counting:
   - show clauses of width `< n` cannot eliminate all injective assignments,
   - use `rcases` on unresolved pigeons/holes and a combinatorial extension lemma.
3. **Convert width to size** by bounding the number of width-`w` clauses and showing a refutation of width `w` needs at least exponentially many derivation states.

Why this is best: it avoids the full technical burden of Haken’s original switching-style proof while still yielding the canonical exponential lower bound.

Key tactics likely needed:
- induction on derivations,
- `rcases` on literals and assignments,
- `by_contra` for lower-bound contradiction,
- multi-step `calc`,
- careful finite counting with `Finset.card`, injections, and inequalities.

---

### Strategy B: Information-compression barrier via KW and entropy
**Most visionary.**

1. Associate to each narrow clause a compressed description of the witness/search partition it induces.
2. Use `kw_witness_compression_lower_bound` and/or `incompressible_strings_lower_bound` to show this compression is impossible below a threshold.
3. Deduce a width lower bound, then bootstrap to size lower bound.

Why this matters: it transforms proof complexity into an information-theoretic obstruction, connecting SAT refutations to compression impossibility and communication complexity.

This is where the catalog results can become genuine engines rather than decorative references:
- `kw_witness_compression_lower_bound`
- `KW_lower_bound_implies_formula_depth_lower_bound`
- `incompressible_strings_lower_bound`
- `source_coding_lower_bound`

Even a partial theorem here is high-value if cleanly formalized.

---

### Strategy C: Explicit cutting-planes derivation by summing constraints
**Most implementable for the separation half.**

1. Encode PHP as Boolean inequalities:
   - each pigeon chooses at least one hole,
   - each hole receives at most one pigeon.
2. Sum all pigeon constraints to get total occupancy `≥ n+1`.
3. Sum all hole constraints to get total occupancy `≤ n`.
4. Derive contradiction by arithmetic and a cutting-planes rule.

Why this is excellent: it gives a short, elegant, certifiable proof that cutting planes exploits counting globally while resolution must discover contradiction locally.

This part should be fully formalized and executable.

---

## How to Build on Existing Catalog Theorems

Do not merely cite them. Use them structurally.

### 1. `kw_witness_compression_lower_bound`
Use this as the formal obstruction to any attempt to encode the search space navigated by a narrow proof. If your `ProofInformation` invariant yields a witness compressor, this theorem should kill low-information refutations.

### 2. `KW_lower_bound_implies_formula_depth_lower_bound`
This gives a bridge from search/communication complexity to formula depth. Use it to argue that proof-search trees extracted from resolution derivations inherit depth barriers, which in turn force large size or width.

### 3. `incompressible_strings_lower_bound`
Model families of partial assignments or refutation branches as strings. A narrow proof canonically labels only a limited family of coordinates; use incompressibility to force many branches or high information content.

### 4. `source_coding_lower_bound`
This is your entropy lever. If a proof partitions assignments into too few clause-induced classes, then one obtains a code violating source-coding lower bounds.

### 5. `density_exponential_bound`
Potentially useful as a generic “growth barrier” theorem if you package derivation layers as a depth-stratified system.

This is exactly the kind of cross-pollination the project needs: **proof complexity lower bounds as coding theorems**.

---

## Cross-Domain Connections You Must Make Explicit

At least one theorem and one section of the paper should articulate these links.

1. **Proof Complexity ↔ Information Theory**
   - resolution clauses as lossy summaries of assignment space,
   - narrow proofs as forbidden compression schemes,
   - lower bounds via entropy/incompressibility.

2. **Proof Complexity ↔ Circuit Complexity**
   - resolution search trees and KW games,
   - depth/communication bottlenecks imply proof bottlenecks.

3. **Proof Complexity ↔ Integer Optimization**
   - cutting planes as arithmetic reasoning over 0–1 polytopes,
   - resolution as purely combinatorial local elimination,
   - the separation explains why pseudo-Boolean solvers can crush SAT encodings of counting constraints.

4. **Proof Complexity ↔ SAT Solver Dynamics**
   - CDCL learns clauses, approximating resolution,
   - pseudo-Boolean and CP-style reasoning capture global counting constraints,
   - your formal theorem predicts solver performance gaps on PHP and related benchmarks.

5. **Proof Complexity ↔ Statistical Physics / Energy Landscapes**
   - local clause propagation corresponds to local energy descent,
   - cutting planes introduces global conservation laws,
   - this suggests a new language for “frustrated” CNFs.

---

## Suggested Nontrivial Theorems for the “at least 3 deep theorems” requirement

You need at least 3, but ideally prove 4–6.

1. `resolution_sound`
   ```lean
   theorem resolution_sound {n : ℕ} {F : CNF n} {C : Clause n} :
     ResDerivable F C → F ⊨ C
   ```
   Deep proof by induction on derivation, with semantic case splits on resolved variable.

2. `php_no_small_width_clause_refutes`
   ```lean
   theorem php_no_small_width_clause_refutes
       (n : ℕ) :
       ∀ C, Clause.width C < n →
       satisfiable_with_clause (PHP_CNF (n+1) n) C
   ```
   Deep combinatorial proof using extension of partial injective assignments.

3. `php_resolution_width_lower_bound`
   As above, deduced from soundness and extension lemma.

4. `resolution_size_ge_two_pow_width_gap`
   Counting proof with finite clause spaces.

5. `php_cutting_planes_rank_bound`
   Arithmetic derivation with `calc`, summation lemmas, and contradiction.

6. `cutting_planes_separates_from_resolution_on_php`
   Final synthesis theorem.

---

## A Falsifiable Conjecture with Clear Computational Test

You must include at least one conjecture that can be disproved by computation.

### Conjecture: Width predicts CDCL difficulty on counting contradictions
```text
Conjecture (Width–Runtime Correlation for PHP):
For the family PHP(n+1,n), the median runtime of clause-learning SAT solvers restricted to clause width ≤ w
grows exponentially once w < min_res_width(PHP(n+1,n)).
```

**Computational test:**  
Generate PHP instances for `n = 2..10`. Run:
- a bounded-width resolution simulator or width-restricted CDCL,
- a pseudo-Boolean / cutting-planes capable solver.

Measure:
- runtime,
- learned clause width distribution,
- proof size proxy.

A single family of instances where bounded-width CDCL stays polynomial below the predicted threshold would falsify the conjecture.

### Stronger conjecture
```text
Conjecture (Entropy Barrier for Resolution):
For every unsatisfiable CNF family F_n with bounded initial width, if the satisfying partial assignments of F_n admit no code below entropy H_n, then every resolution refutation of F_n has size at least 2^{Ω(H_n)}.
```

**Computational test:**  
Estimate empirical assignment entropy and compare against extracted proof traces from SAT solvers on benchmark families.

---

## Verified Algorithm / Computational Method Required

You must produce not just theorems, but a verified computational artifact.

### Required algorithm
Implement a certified procedure that:
1. constructs `PHP_CNF (n+1) n`,
2. computes initial width,
3. searches for bounded-width resolution refutations up to a width cutoff,
4. constructs the canonical cutting-planes refutation,
5. reports the predicted separation.

A Lean-facing API could be:
```lean
def searchBoundedWidthResolution (n w : ℕ) :
  Option (ResRefutationTrace (PHP_CNF (n+1) n))

def explicitPHPCPRefutation (n : ℕ) :
  CPRefutationTrace (PHP_CP (n+1) n)
```

Correctness theorems:
```lean
theorem searchBoundedWidthResolution_sound
    (n w : ℕ) :
    match searchBoundedWidthResolution n w with
    | some tr => valid_res_refutation_trace (PHP_CNF (n+1) n) tr
    | none => True

theorem explicitPHPCPRefutation_correct
    (n : ℕ) :
    valid_cp_refutation_trace (PHP_CP (n+1) n) (explicitPHPCPRefutation n)
```

This algorithmic component is essential because it turns the theory into an experimental platform for proof complexity.

---

## Demo Requirements

Your `demo.py` should:
1. generate PHP instances for small `n`,
2. display clause counts, widths, and assignment-space statistics,
3. simulate bounded-width resolution search,
4. display the explicit cutting-planes certificate,
5. compare empirical SAT/pseudo-Boolean solver behavior if external solvers are available.

A compelling demo:
- `n=2,3,4,5`
- visualize width growth vs proof search explosion,
- print the short arithmetic contradiction for cutting planes.

---

## Deliverables You Must Produce

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 falsifiable scientific hypotheses**, each with:
- precise conjecture,
- what data/theorem would refute it,
- computational test protocol.

Suggested topics:
- entropy lower bounds imply resolution lower bounds,
- KW complexity predicts clause-learning depth,
- pseudo-Boolean reasoning simulates low-rank CP on counting principles,
- proof-width profiles classify SAT benchmark hardness.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper containing:
- formal definitions of resolution and cutting planes,
- statement and proof sketches of the main theorems,
- explanation of why PHP separates local and global reasoning,
- relation to Haken, Ben-Sasson–Wigderson, KW, and SAT solvers,
- discussion of your new invariant (`ProofInformation` / `WidthEntropyProfile`),
- next-step research agenda.

Someone reading only this document must understand the discovery and its significance.

### 3. `ARTICLE.md`
Scientific American style:
- “Why some contradictions are invisible to local logic”
- explain pigeons and holes,
- why arithmetic sees what clause elimination cannot,
- how this predicts solver behavior in practice.

### 4. Verified algorithm / computational method
As above: bounded-width resolution search and explicit CP certificate construction.

### 5. `demo.py`
Interactive or command-line demonstration of the separation and the conjectural runtime consequences.

---

## Application Keywords

proof complexity, resolution, cutting planes, pigeonhole principle, Haken theorem, Ben-Sasson–Wigderson width method, Karchmer–Wigderson games, SAT solvers, CDCL, pseudo-Boolean optimization, communication complexity, information theory, entropy lower bounds, witness compression, combinatorial counting, Boolean proof systems, formal verification, Lean 4, Mathlib

---

## Final Call to Action

Do not settle for a toy encoding of clauses. Build the first real **formal proof-complexity laboratory** in Lean around the pigeonhole principle:

- a semantic resolution framework,
- a width-based lower-bound engine,
- a certified cutting-planes counting refutation,
- and a cross-domain invariant explaining why local proof systems fail on global counting contradictions.

If you can certify even a clean width lower bound plus a short CP refutation and tie it to compression/KW barriers, you will have done more than formalize folklore: you will have created a reusable foundation for **machine-checked lower bounds in proof complexity**.

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

Research domain: Computation
Research mode: prove
