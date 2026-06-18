## Mode: prove / discover

## Title
**The Prime Number Crossword: Local Admissibility, Forcing Patterns, and a Verified Prime-Gap Dynamics**

You should **not** try to formalize the full Hardy–Littlewood asymptotic. That would be scientifically attractive but currently too analytically heavy for a breakthrough Lean cycle. Instead, attack the **structural core** of the “prime crossword” idea: prove that local congruence constraints already create a rigorous theory of **forced gap patterns**, define a new combinatorial-dynamical object capturing this phenomenon, and verify an algorithm that detects forcing patterns and predicts admissible next gaps. This is a field-opening bridge between **prime number theory, symbolic dynamics, finite automata, and constraint satisfaction**.

The breakthrough is to recast prime gaps not as isolated arithmetic accidents but as trajectories in a **modular exclusion dynamical system**. If done cleanly, this creates a new formal language for “prime gap grammar”: what finite patterns are admissible, which patterns force the next move, and how local sieve constraints propagate.

---

## Precise formal target

Define a new notion of **prime-gap crossword state** at modulus `M`, encoding which residues in a local window are ruled out by small prime divisibility. Then prove that certain finite gap words are **forcing**: once a prefix occurs in an admissible state, the next gap is uniquely determined by modular constraints.

The key point is that this is a genuine theorem schema, not heuristic numerology.

### New definitions to introduce

Let `gaps : List ℕ` be a finite list of positive even numbers. Let its cumulative offsets be
`0, g₁, g₁+g₂, ..., g₁+...+gₖ`.

For a modulus `M`, call a gap word `gaps` **M-admissible** if there exists a residue class `a mod M` such that:
- every cumulative prime position `a + partialSum` is **not divisible by any prime dividing `M`**, and
- every intermediate location strictly between consecutive cumulative sums is divisible by **some** prime dividing `M`.

This is a finite, exact, modular model of a prime cluster/gap pattern.

Then define `M-forcingNext gaps g` to mean:
- `g` is an admissible next gap after `gaps`, and
- every admissible extension of `gaps` by one gap has next gap equal to `g`.

This gives a mathematically clean notion of “the crossword forces the next answer.”

---

## Lean 4 formalization target

You should create a file along the lines of:

`PrimeCrossword/ForcingPatterns.lean`

with a new structure and theorem suite around modular admissibility.

Here is the kind of Lean signature to aim for. Adjust names to actual Mathlib conventions as needed, but keep the mathematical content exact.

```lean
import Mathlib.Data.Nat.Prime
import Mathlib.Data.Nat.ModEq
import Mathlib.Data.List.Basic
import Mathlib.NumberTheory.ArithmeticFunction
import Mathlib.Algebra.BigOperators.Basic

open scoped BigOperators
open Nat

namespace PrimeCrossword

def partialSums : List ℕ → List ℕ
| [] => [0]
| g :: gs =>
  let ps := partialSums gs
  0 :: (ps.map (fun n => g + n))  -- or define more cleanly via scanl

def squarefreeKernel (M : ℕ) : ℕ := Nat.squarefreeKernel M

def primeDivisors (M : ℕ) : Finset ℕ :=
  ((Nat.factors (squarefreeKernel M)).toFinset)

def avoidsPrimeDivisors (M n : ℕ) : Prop :=
  ∀ q ∈ primeDivisors M, ¬ q ∣ n

def hitByPrimeDivisors (M n : ℕ) : Prop :=
  ∃ q ∈ primeDivisors M, q ∣ n

def gapWordPositions (gaps : List ℕ) : List ℕ :=
  -- cumulative sums including 0
  gaps.scanl (fun s g => s + g) 0

def interiorPositions (gaps : List ℕ) : Finset ℕ :=
  -- all strict interior points between consecutive cumulative sums
  sorry

def ModAdmissible (M : ℕ) (gaps : List ℕ) : Prop :=
  ∃ a : ℕ,
    (∀ t ∈ (gapWordPositions gaps), avoidsPrimeDivisors M (a + t)) ∧
    (∀ u ∈ interiorPositions gaps, hitByPrimeDivisors M (a + u))

def NextGapAdmissible (M : ℕ) (gaps : List ℕ) (g : ℕ) : Prop :=
  ModAdmissible M (gaps ++ [g])

def ForcingNext (M : ℕ) (gaps : List ℕ) (g : ℕ) : Prop :=
  NextGapAdmissible M gaps g ∧
  ∀ h : ℕ, NextGapAdmissible M gaps h → h = g
```

You may find it cleaner to define admissibility relative to a finite set of sieving primes `S : Finset ℕ` instead of a modulus `M`; in fact that may be mathematically superior. If so, define both and prove equivalence when `S = primeDivisors M`.

---

## Core theorem statements to prove

You need **at least 3 substantial theorems**, with real proofs using induction / `rcases` / contradiction / structured `calc`.

### Theorem 1: Evenness of genuine prime gaps beyond 3
This is classical, but here it should be proved as a building block in a way that feeds the crossword formalism.

```lean
theorem prime_gap_even
  {p q : ℕ}
  (hp : Nat.Prime p) (hq : Nat.Prime q)
  (h3 : 3 ≤ p) (hpq : p < q)
  (hnext : ∀ n, p < n → n < q → ¬ Nat.Prime n) :
  Even (q - p)
```

**Meaning:** any genuine consecutive prime gap after 3 is even.

**Why this matters:** it is the first grammar rule of the crossword. It upgrades “observed pattern” into a theorem usable inside later admissibility proofs.

---

### Theorem 2: Shift-invariance of modular admissibility
The crossword is about local residue constraints, so admissibility should depend only on residue class mod `M`.

```lean
theorem modAdmissible_iff_residue
  {M : ℕ} (hM : 2 ≤ M) (gaps : List ℕ) :
  ModAdmissible M gaps ↔
  ∃ a : ZMod M,
    (∀ t ∈ gapWordPositions gaps, ∀ q ∈ primeDivisors M,
      (t + a.val) % q ≠ 0) ∧
    (∀ u ∈ interiorPositions gaps, ∃ q ∈ primeDivisors M,
      (u + a.val) % q = 0)
```

You may need to formulate this more naturally in `ZMod M` or keep it in `ℕ` with `Nat.ModEq`. The exact implementation can vary.

**Meaning:** admissibility is finite-state. This turns the problem into a combinatorial automaton.

**Why this is a breakthrough:** it opens the door to algorithmic classification of prime-gap patterns by finite modular state spaces. This is the first rigorous “crossword board” theorem.

---

### Theorem 3: Monotonicity under strengthening the sieve
If more small primes are used as constraints, admissibility can only decrease and forcing can only strengthen.

For a version using finite prime sets:

```lean
def AdmissibleOver (S : Finset ℕ) (gaps : List ℕ) : Prop := sorry
def ForcingNextOver (S : Finset ℕ) (gaps : List ℕ) (g : ℕ) : Prop := sorry

theorem admissible_mono
  {S T : Finset ℕ} {gaps : List ℕ}
  (hST : S ⊆ T) :
  AdmissibleOver T gaps → AdmissibleOver S gaps

theorem forcing_mono
  {S T : Finset ℕ} {gaps : List ℕ} {g : ℕ}
  (hST : S ⊆ T) :
  ForcingNextOver S gaps g → ForcingNextOver T gaps g → True
```

The second statement should likely be sharpened into a more informative theorem, for example:
- if `T` strengthens `S` and `gaps` has exactly one `T`-admissible extension, then every actual prime realization compatible with `T` must use that gap;
- or characterize when uniqueness at level `T` implies uniqueness among bounded candidates.

**Why this matters:** forcing is a sieve-theoretic phenomenon. This theorem lets you move from coarse to fine crossword boards.

---

### Theorem 4: Existence of forcing patterns for a finite sieve
This is the centerpiece.

Prove that for some explicit finite sieving set, there exists a nontrivial forcing pattern. For example, using primes `{2,3,5}` or `{2,3,5,7}`, search computationally for a short word `w` and a gap `g` such that `ForcingNextOver S w g`.

A target signature:

```lean
theorem exists_forcing_pattern :
  ∃ (S : Finset ℕ) (w : List ℕ) (g : ℕ),
    (∀ q ∈ S, Nat.Prime q) ∧
    ForcingNextOver S w g
```

This is already nontrivial, but you should go further and make it **explicit** if possible:

```lean
theorem explicit_forcing_pattern :
  ForcingNextOver ({2,3,5,7} : Finset ℕ) [6,4,2,6] 4
```

Do **not** fake this theorem. First let `demo.py` search for true examples; then formalize one that is actually correct. If `[6,4,2,6] -> 4` fails, replace it with a verified pattern.

**Why this would be a breakthrough:** it transforms a poetic metaphor into theorem: some local prime-gap words genuinely have deterministic continuation in a finite sieve model.

---

### Theorem 5: Chinese remainder realization of admissible states
This connects local constraints to global arithmetic progressions.

```lean
theorem admissible_infinite_realizations
  {S : Finset ℕ} {gaps : List ℕ}
  (hprime : ∀ q ∈ S, Nat.Prime q)
  (hadm : AdmissibleOver S gaps) :
  ∃ a M, M > 0 ∧
    ∀ k : ℕ,
      let n := a + k * M
      (∀ t ∈ gapWordPositions gaps, ∀ q ∈ S, ¬ q ∣ (n + t)) ∧
      (∀ u ∈ interiorPositions gaps, ∃ q ∈ S, q ∈ S ∧ q ∣ (n + u))
```

This theorem should be proved via CRT / modular periodicity, possibly in a weakened but formalizable form.

**Why this matters:** admissible crossword patterns are not isolated—they recur periodically in the finite sieve world. This is the symbolic dynamics / automata bridge.

---

## Most promising proof strategies

### Strategy A: Finite-sieve symbolic dynamics
**Best overall strategy.**

1. Replace the full prime problem by a finite sieving set `S`.
2. Encode a state by a residue class modulo `M = ∏ q∈S q`.
3. Show admissibility and next-gap admissibility are decidable finite predicates on `ZMod M`.
4. Prove existence/uniqueness of next gaps by finite reasoning over residues, but the theorems themselves should be structural, not brute-force tautologies.

**Why this is most promising:** it converts the informal crossword metaphor into a precise automaton with rigorous transition rules, while staying fully within Lean + Mathlib’s strengths.

---

### Strategy B: CRT plus interval covering
1. Define the prime positions and interior positions of a gap word.
2. Express admissibility as a conjunction of congruence avoidance and congruence hitting conditions.
3. Use CRT to show any consistent modular pattern lifts to infinitely many integers.
4. Derive forcing from uniqueness of compatible residue classes or uniqueness of admissible extension lengths.

**Why it is strong:** this gives the cleanest number-theoretic interpretation and yields the “periodic realization” theorem naturally.

---

### Strategy C: Graph/automaton formulation
1. Define a directed graph whose vertices are admissible residues mod `M`.
2. An edge labeled `g` means “gap `g` is a legal next move.”
3. Forcing means out-degree one for a given word/state.
4. Prove structural theorems about this graph: nonemptiness, periodicity, monotonicity under enlarging `S`.

**Why this is exciting:** this is the cross-domain leap to symbolic dynamics and theoretical computer science. It suggests entropy, mixing, forbidden-word complexity, and automata learning of prime constraints.

---

## Cross-domain connections you must include

### 1. Number theory × symbolic dynamics
The admissible gap language over alphabet `{2,4,6,...}` forms a subshift of finite type once a sieve set is fixed. Prove at least one theorem phrased in this language:
- forbidden finite words,
- deterministic transitions,
- periodic points,
- finite-state recognizability.

### 2. Number theory × constraint satisfaction / SAT
A gap word is admissible iff a finite family of modular clauses is satisfiable. This is a genuine CSP viewpoint:
- “prime positions” are avoidance clauses,
- “interior positions” are covering clauses.

Formalize at least one theorem interpreting admissibility as satisfiability of a finite modular instance.

### 3. Number theory × statistical physics
Use language of exclusion processes / hard-core systems in `RESEARCH_PAPER.md` and `ARTICLE.md`. The small primes act like local exclusion fields. Even if the formal theorem is purely arithmetic, this conceptual bridge is powerful and original.

### 4. Optional: number theory × tropical/combinatorial geometry
The set of admissible residues can be viewed as a finite arrangement complement in the discrete torus `∏_{q∈S} Z/qZ`. If possible, define a “crossword polytope” or “admissibility complex” as a finite combinatorial object.

---

## Catalog-building expectations

Build on existing Mathlib facts about:
- `Nat.Prime`
- divisibility and parity
- `Nat.ModEq`
- finite products over `Finset`
- `ZMod`
- CRT-related lemmas where available
- list cumulative sums (`List.scanl`)
- decidability of finite predicates

If the live catalog contains number theory or combinatorics files about residues, finite automata, or arithmetic progressions, explicitly leverage them. Do not reinvent standard parity or CRT machinery if Mathlib already has it.

---

## Conjecture with testable prediction

You must state at least one falsifiable conjecture, and `demo.py` must test it.

A strong candidate:

> **Conjecture (Finite-sieve forcing density).**  
> For every sufficiently rich finite prime set `S = {2,3,5,...,p_k}`, there exists a forcing word `w` over even gaps with positive frequency in the `S`-admissible symbolic dynamics.

A more computationally precise version:

> **Conjecture (Exponential decay of ambiguity).**  
> Fix `S`. Let `A_S(L)` be the proportion of admissible words of length `L` with more than one admissible next gap. Then `A_S(L)` decays exponentially in `L`.

This is falsifiable by exhaustive finite-state computation.

Another arithmetic-facing conjecture:

> **Conjecture (Sieve-to-prime transfer heuristic).**  
> If a word is forcing for `S = {2,3,5,...,p_k}` with large `p_k`, then among actual consecutive prime gaps up to `X`, the empirical conditional distribution of the next gap given that word concentrates on the forced gap as `k` and `X` grow.

This is heuristic but computationally testable.

---

## Verified algorithm / computational method

You must produce a **verified algorithm**, not just theorem statements.

### Required algorithm
Implement a function that, given:
- a finite prime set `S`,
- a max gap bound `B`,
- a word length bound `L`,

enumerates all admissible words up to length `L`, computes admissible next gaps up to `B`, and identifies forcing patterns.

Possible Lean-facing spec:

```lean
def nextGapsOver (S : Finset ℕ) (B : ℕ) (w : List ℕ) : Finset ℕ := sorry

def isForcingOver (S : Finset ℕ) (B : ℕ) (w : List ℕ) : Bool := sorry
```

Then prove a correctness theorem:

```lean
theorem mem_nextGapsOver_iff
  {S : Finset ℕ} {B g : ℕ} {w : List ℕ} :
  g ∈ nextGapsOver S B w ↔ g ≤ B ∧ NextGapAdmissibleOver S w g
```

and

```lean
theorem isForcingOver_correct
  {S : Finset ℕ} {B : ℕ} {w : List ℕ} :
  isForcingOver S B w = true ↔
    ∃ g ≤ B, NextGapAdmissibleOver S w g ∧
      ∀ h ≤ B, NextGapAdmissibleOver S w h → h = g
```

This is scientifically crucial: it turns the theory into an experiment engine.

---

## demo.py requirements

`demo.py` must:
1. Enumerate prime gaps from actual primes up to a substantial bound.
2. Compute empirical frequencies of next gaps after short words.
3. Search for forcing patterns in the finite sieve model for several `S`.
4. Compare sieve-forced next gaps against actual prime data.
5. Output a ranked table:
   - word,
   - sieve-forced next gap(s),
   - empirical prime-data next-gap distribution,
   - agreement score.

If feasible, include a small interactive prompt:
- user enters a gap word,
- script reports admissible next gaps in the finite sieve model,
- and empirical next-gap frequencies from prime data.

---

## Deliverables you must produce

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to another domain, for example:
- symbolic dynamics / entropy of prime-gap languages,
- SAT/CSP phase transitions for modular crossword instances,
- statistical mechanics of sieve exclusion systems,
- coding theory for admissible prime constellations.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the prime crossword idea,
- the new definitions,
- the main theorems,
- explicit forcing patterns found,
- the algorithmic search method,
- what this says about prime gaps structurally,
- and what remains conjectural.

This paper must be understandable without access to the code.

### 3. `ARTICLE.md`
Write in **Scientific American** style. Explain:
- why prime gaps look random but obey hidden local rules,
- how modular arithmetic acts like a crossword constraint system,
- why forcing patterns are surprising,
- what broader scientific ideas this connects to.

**Taboo:** do **not** focus on formal verification machinery. Focus on the mathematics and significance.

### 4. Verified algorithm
As above: admissibility / forcing detector with correctness theorem(s).

### 5. `demo.py`
As above: interactive exploration and empirical comparison against prime data.

---

## Application keywords

Include these ideas explicitly in the paper and metadata:
**prime gaps, Hardy–Littlewood heuristic, finite sieve, modular constraints, symbolic dynamics, subshift of finite type, Chinese remainder theorem, constraint satisfaction, automata, admissibility, forcing pattern, arithmetic combinatorics, empirical mathematics, predictive number theory**

---

## Final scientific ambition

Do not present this as “we proved a cute fact about prime gaps.” Present it as the beginning of a new program:

> **Prime gaps admit a rigorous local grammar.**  
> Finite sieves generate a deterministic symbolic dynamics with forbidden words and forcing transitions. This does not solve the primes globally—but it creates a new intermediate theory between raw primality and probabilistic heuristics.

That is the right level of ambition: not a minor extension, but a new mathematical language for the local structure of the primes.

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
