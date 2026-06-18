## Assignment: Conjecture 2: Positive Density of Admissible Integers, Zero Density of Representability Obstructions

**Mode:** `prove` + `discover`

You should not treat this as a toy density computation. The real target is to formalize a **local-to-global obstruction framework** for the sum-of-three-cubes problem, prove the exact density of the local admissibility set, and then push beyond elementary modular arithmetic toward a mathematically serious architecture for studying the sparse exceptional set. The breakthrough is not “7/9 is easy”; the breakthrough is to create a Lean-ready theory in which **congruence obstructions, asymptotic counting, and computational evidence for global representability** coexist in one verified pipeline.

Build a new file around the sum-of-three-cubes admissibility problem, with a genuine asymptotic counting theorem, a new obstruction structure, and a bridge theorem connecting modular arithmetic to analytic-density language.

## Core Mathematical Objective

Let
\[
\mathrm{Adm} := \{k \in \mathbb Z : k \bmod 9 \notin \{4,5\}\},
\qquad
\mathrm{Rep} := \{k \in \mathbb Z : \exists x\,y\,z \in \mathbb Z,\ x^3+y^3+z^3 = k\}.
\]

You should formalize and prove exact theorems showing:

1. **Local obstruction theorem mod 9**: every sum of three integer cubes avoids residues \(4,5 \pmod 9\).
2. **Exact residue-count theorem**: the admissible set has exactly \(7/9\) natural density.
3. **Asymptotic counting theorem with explicit error term**: the counting function of admissible integers in \([0,N)\) differs from \((7/9)N\) by a bounded periodic error.
4. **Containment theorem**: \(\mathrm{Rep} \subseteq \mathrm{Adm}\).
5. **Computational research layer**: define a bounded-search representability predicate and verify that it is sound; use it to generate lower bounds on empirical representability ratios among admissible integers.

The nontrivial vision is this: formalize the **difference between local permissibility and global representability** as an object of study. This is the seed of a much larger formal theory of exceptional sets in Diophantine problems.

---

## Precise Theorem Statements

You must include at least 3 substantial theorems with real proofs. At least one should use contradiction or residue classification, and at least one should use a multi-step asymptotic/counting argument.

### New definitions to introduce

Define at least one genuinely new concept, for example:

```lean
def CubeSumAdmissible (k : ℤ) : Prop :=
  k % 9 ≠ 4 ∧ k % 9 ≠ 5

def SumThreeCubes (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x^3 + y^3 + z^3 = k

def admissibleCount (N : ℕ) : ℕ :=
  ((Finset.range N).filter (fun n => CubeSumAdmissible (n : ℤ))).card

def boundedSumThreeCubes (B : ℕ) (k : ℤ) : Prop :=
  ∃ x y z : ℤ,
    |x| ≤ B ∧ |y| ≤ B ∧ |z| ≤ B ∧ x^3 + y^3 + z^3 = k
```

Even better: package the local obstruction as a structure.

```lean
structure LocalObstruction where
  modulus : ℕ
  forbidden : Finset ℤ
  admissible : ℤ → Prop
  admissible_iff : ∀ k : ℤ, admissible k ↔ k % modulus ∈ forbiddenᶜ
```

Then instantiate it for the three-cubes problem with modulus 9 and forbidden residues `{4,5}`. This is mathematically valuable because it generalizes immediately to other additive Diophantine representation problems.

---

## Lean 4 Type Signatures to Target

These are suggested formal targets; refine to actual Mathlib syntax as needed.

### Theorem 1: cube residues mod 9 are only 0, ±1

```lean
theorem int_cube_mod_nine_mem
    (x : ℤ) :
    x^3 % 9 = 0 ∨ x^3 % 9 = 1 ∨ x^3 % 9 = 8 := by
```

A stronger variant via residue classes is also excellent:

```lean
theorem int_cube_mod_nine_eq_of_residue
    (x : ℤ) :
    ∃ r ∈ ({0,1,8} : Finset ℤ), x^3 % 9 = r := by
```

### Theorem 2: local obstruction for sums of three cubes

```lean
theorem sum_three_cubes_not_four_five_mod_nine
    {k : ℤ} (hk : SumThreeCubes k) :
    CubeSumAdmissible k := by
```

Equivalently:

```lean
theorem sum_three_cubes_mod_nine_ne_four_five
    {x y z k : ℤ}
    (h : x^3 + y^3 + z^3 = k) :
    k % 9 ≠ 4 ∧ k % 9 ≠ 5 := by
```

### Theorem 3: exact counting formula for admissible residues

A strong finite counting statement is better than a vague density statement:

```lean
theorem admissibleCount_eq
    (q r : ℕ) (hr : r < 9) :
    admissibleCount (9*q + r)
      = 7*q + ((Finset.range r).filter (fun n => CubeSumAdmissible (n : ℤ))).card := by
```

This is a major formal theorem because it gives exact periodic decomposition.

### Theorem 4: asymptotic bounded error / natural density 7/9

You may formulate one of the following depending on available analysis library support.

A bounded-error arithmetic version:

```lean
theorem admissibleCount_error_bound
    (N : ℕ) :
    |(admissibleCount N : ℤ) * 9 - 7 * N| ≤ 2 := by
```

This is extremely elegant and powerful: it implies density \(7/9\) immediately.

Or a direct real-valued limit statement if convenient:

```lean
theorem tendsto_admissible_density :
    Filter.Tendsto
      (fun N : ℕ => (admissibleCount N : ℝ) / N)
      Filter.atTop
      (nhds (7 / 9 : ℝ)) := by
```

If the direct limit proof is cumbersome, prove the bounded-error theorem and derive the limit as a corollary.

### Theorem 5: soundness of bounded search

```lean
theorem boundedSumThreeCubes_sound
    {B : ℕ} {k : ℤ} :
    boundedSumThreeCubes B k → SumThreeCubes k := by
```

This theorem matters because it turns computational experiments into certified lower bounds.

### Theorem 6: monotonicity of bounded search counts

```lean
theorem boundedSumThreeCubes_mono
    {B₁ B₂ : ℕ} (hB : B₁ ≤ B₂) {k : ℤ} :
    boundedSumThreeCubes B₁ k → boundedSumThreeCubes B₂ k := by
```

This gives a verified algorithmic scaffold for experimental mathematics.

---

## 2–3 Proof Strategy Paths

### Strategy A: Residue classification + exact periodic counting
**Most promising.** This is the core route and should definitely be completed.

1. Prove every integer cube modulo 9 lies in `{0,1,8}` by reducing \(x \bmod 9\) and checking the 9 residue classes.
2. Enumerate all sums of three elements of `{0,1,8}` modulo 9 and show the result never equals 4 or 5.
3. For counting, partition `range (9*q + r)` into `q` complete blocks of length 9 plus a tail of length `r`; show each full block contributes exactly 7 admissible integers.
4. Deduce the bounded error estimate
   \[
   |9\,\mathrm{admissibleCount}(N)-7N|\le 2
   \]
   from the tail term.
5. Convert bounded error to natural density \(7/9\).

Why this is strong: it upgrades a congruence observation into an exact asymptotic theorem with machine-verifiable error term.

### Strategy B: Build a general “periodic admissibility” framework
This is more visionary and reusable.

1. Define a predicate `PeriodicPred m P` expressing that membership depends only on residue mod `m`.
2. Prove a general theorem: if exactly `a` residues modulo `m` satisfy `P`, then the counting function up to `N` is `a/m * N + O(1)`, with explicit finite-tail formula.
3. Instantiate this framework with `m = 9` and `P(k) := CubeSumAdmissible k`.

This is powerful because it opens a library for **natural density of periodic Diophantine local conditions**, reusable in sums of powers, polygonal numbers, local solubility, and sieve-theoretic formalization.

### Strategy C: Contrapositive obstruction theory + computational certification
Use this to make the file scientifically richer.

1. Define `LocalObstruction` and prove that `SumThreeCubes k → admissible k`.
2. Define bounded-search representability and prove soundness/monotonicity.
3. Build a verified procedure that computes a lower bound on the number of representable admissible integers up to `N`.
4. Use this to formulate falsifiable conjectures about exceptional-set sparsity.

This is not a proof of the global conjecture, but it creates a formal bridge between theorem proving and computational number theory.

---

## Cross-Domain Connections You Must Explicitly Exploit

Do not keep this isolated within elementary number theory. Include at least one theorem or discussion connecting to another domain.

### 1. Number theory + dynamical / ergodic viewpoint
The exact \(7/9\) density is a finite periodic model of an invariant frequency statement. The admissible set is the pullback of a cylinder set in the dynamical system \(\mathbb Z/9\mathbb Z\). Formalizing the exact block decomposition is a discrete analogue of equidistribution.

**Possible theorem framing:** periodic predicates have exact Cesàro averages.  
This ties additive number theory to ergodic-style averaging.

### 2. Number theory + computer science / certified search
Your bounded-search predicate is a verified semidecision procedure for representability. This is a formal complexity object: local obstructions are constant-time modular filters; global representability is an exponentially expanding search problem.

**Application keywords:** certified computation, semidecision procedures, verified exhaustive search, arithmetic complexity.

### 3. Number theory + analytic density / sieve theory
The admissible set is a local sieve condition with exact local density \(1 - 2/9\). This is the finite toy model of a sieve: local constraints define a density, but global representation may remove a thin exceptional set. This is philosophically aligned with Hardy–Littlewood heuristics and exceptional-set theory.

**Application keywords:** local-global principle, sieve heuristics, exceptional sets, asymptotic density, modular obstruction.

### 4. Optional bold connection: statistical physics
Representability by \(x^3+y^3+z^3\) can be viewed as the existence of an integer microstate with fixed energy \(k\). The admissible set gives local conservation-law constraints, while the conjectural density-1 representability among admissible integers resembles a high-entropy accessibility principle.

If you include this, do it carefully and mathematically, not poetically.

---

## Breakthrough Significance

If executed well, this project does something deeper than proving a modular fact. It establishes a **formal obstruction calculus** for Diophantine representation problems:

- local congruence constraints can be represented as periodic predicates;
- periodic predicates admit exact counting formulas and therefore exact densities;
- representability can be approximated by verified bounded search;
- the gap between local density and global density becomes a formal exceptional-set object.

This is the beginning of a Lean-native framework for **local-to-global heuristics in additive number theory**. Once built, the same machinery can attack:
- sums of four cubes,
- sums of three \(d\)-th powers,
- polygonal number representability,
- local solubility for diagonal forms,
- formalized sieve heuristics.

That is field-opening. It turns informal “obviously mod 9” folklore into a reusable formal language for asymptotic arithmetic phenomena.

---

## Required Theorems Beyond the Basic Claim

You must prove at least 3 substantial theorems. A recommended package:

1. `int_cube_mod_nine_mem`
2. `sum_three_cubes_not_four_five_mod_nine`
3. `admissibleCount_eq`
4. `admissibleCount_error_bound`
5. `boundedSumThreeCubes_mono`
6. `boundedSumThreeCubes_sound`

At least three of these should involve real proof structure: `rcases`, induction on blocks / decomposition of `N = 9q + r`, contradiction on forbidden residues, and multi-step `calc`.

---

## Falsifiable Conjectures and Computational Tests

You must state at least one clear, falsifiable conjecture. Better: include 3–5 in `FUTURE_DIRECTIONS.md`.

Recommended hypotheses:

1. **Admissible-density exactness**
   \[
   \forall N,\quad |9\,\mathrm{admissibleCount}(N)-7N|\le 2.
   \]
   This should be proved, not conjectured.

2. **Exceptional set sparsity conjecture**
   Let
   \[
   E(N) := \#\{1 \le k \le N : k \in \mathrm{Adm},\ \neg \mathrm{Rep}(k)\}.
   \]
   Conjecture:
   \[
   \frac{E(N)}{N} \to 0.
   \]
   **Test:** using known databases and bounded search, compute empirical lower/upper surrogate ratios up to \(10^3,10^4,10^5\).

3. **Empirical admissible saturation**
   Define
   \[
   R_B(N) := \#\{1 \le k \le N : \texttt{boundedSumThreeCubes}\ B\ k\}.
   \]
   Conjecture: for suitably growing \(B\), the ratio \(R_B(N)/\mathrm{admissibleCount}(N)\) increases with \(B\) and appears to approach 1 for tested ranges.
   **Test:** compute for several \(B,N\).

4. **Periodic obstruction universality**
   For any finite set of forbidden residues modulo \(m\), the associated periodic predicate has rational natural density equal to `card(allowed)/m`.
   This should be proved in a general framework if possible.

---

## Algorithmic Deliverable

Do not stop at theorem statements. Produce a verified computational method.

Implement a procedure in Lean and expose it in `demo.py`:

- input: `N`, optional search bound `B`
- output:
  - number of admissible integers in `[1,N]`
  - exact ratio `admissibleCount(N) / N`
  - list/count of `k ≤ N` found by bounded search to satisfy `x^3+y^3+z^3 = k`
  - ratio among admissible integers found representable
  - residues mod 9 of missing cases

This is scientifically important: it turns formal proofs into an experimental platform for studying the exceptional set.

---

## Deliverables (ALL MANDATORY)

You must produce all of the following:

1. **Lean formalization** with minimized sorrys and at least 3 substantial theorem proofs.
2. **A structured `FUTURE_DIRECTIONS.md`** containing 3–5 testable scientific hypotheses, each falsifiable with a clear computational or formal test.
3. **A standalone `RESEARCH_PAPER.md`** explaining the theorem, the obstruction framework, the exact density result, the computational representability experiments, and the significance for local-global principles in additive number theory.
4. **An accessible `ARTICLE.md`** in Scientific American style, explaining why two missing residues mod 9 shape one of the most famous unsolved Diophantine problems.
5. **A verified algorithm or computational method** for admissibility counting and bounded representability search.
6. **A `demo.py`** that interactively demonstrates the theorem and computational experiments.

---

## Application Keywords

sum of three cubes; local-global principle; modular obstruction; natural density; periodic set; asymptotic counting; exceptional set; additive Diophantine equations; certified search; verified computation; sieve heuristics; analytic number theory; formalized mathematics; Lean 4; Mathlib.

---

## Final Research Standard

Do not submit a file whose main achievement is merely “the set of integers not congruent to 4 or 5 mod 9 has density \(7/9\).” That is the entry point, not the destination. The destination is a reusable formal framework for **periodic local obstructions and their asymptotic densities**, instantiated in the sum-of-three-cubes problem and connected to a verified computational investigation of the global exceptional set.

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
