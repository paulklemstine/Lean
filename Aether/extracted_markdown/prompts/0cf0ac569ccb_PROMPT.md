## Assignment: Symmetric Group Generation Probability

Mode: **prove + formalize + discover**

You are not being asked for a routine counting exercise. You are being asked to formalize one of the central probabilistic phenomena in finite group theory: that “almost every” pair of permutations generates either `S_n` or `A_n`, and that the obstruction to generating `S_n` is governed by parity plus a thin layer of primitive/imprimitive exceptional subgroups. The breakthrough is to turn this narrative into Lean-certified theorems at multiple scales:

1. **exact finite formulas for small/structured cases,**
2. **uniform upper/lower bounds for all `n`,**
3. **asymptotic convergence statements for generation probability,**
4. **a bridge to random permutation statistics and computational experimentation.**

This opens a formal interface between **probabilistic group theory**, **random combinatorial structures**, and **certified asymptotic reasoning in Lean**.

---

## Core Research Goal

Let `S_n = Equiv.Perm (Fin n)`. Define the probability that two independent uniformly random permutations generate the full symmetric group:
\[
p_n := \frac{|\{(\sigma,\tau)\in S_n\times S_n : Subgroup.closure(\{\sigma,\tau\})=\top\}|}{|S_n|^2}.
\]

Your mission is to formalize precise versions of the following hierarchy of results:

### Target Theorem A: Exact finite counting identity
For every `n : ℕ`,
\[
p_n = \frac{1}{(n!)^2}
\sum_{(\sigma,\tau)\in S_n^2}
\mathbf{1}\big[\langle \sigma,\tau\rangle = S_n\big].
\]
This is definitional mathematically, but in Lean it should become the canonical object from which all later bounds are derived.

### Target Theorem B: Parity obstruction upper bound
For every `n ≥ 2`,
\[
p_n \le \frac{3}{4}.
\]
Reason: if both generators are even, they lie in `A_n`, hence cannot generate `S_n`; asymptotically this is the dominant elementary obstruction.

A sharper version should also be pursued:
\[
p_n \le 1 - \frac{|A_n|^2}{|S_n|^2} = \frac34
\quad (n\ge 2).
\]

### Target Theorem C: Exact value in the smallest nontrivial case
For `n = 3`,
\[
p_3 = \frac12.
\]
This is an ideal first nontrivial theorem: explicit, exact, and a model for later computational certification.

### Target Theorem D: Event decomposition through transitivity/primitivity
Prove a structural theorem of the form:
if `σ, τ ∈ S_n` generate `S_n`, then the generated subgroup is transitive, not contained in `A_n`, and contains an odd permutation. Formalize the implication chain
\[
\langle \sigma,\tau\rangle = S_n \implies
\text{Transitive}(\langle \sigma,\tau\rangle)\wedge
\langle \sigma,\tau\rangle \not\le A_n.
\]
Then define the corresponding random events and derive probability inequalities:
\[
p_n \le \Pr[\text{transitive and not contained in }A_n].
\]
This is the bridge theorem that connects exact generation to random permutation theory.

### Target Theorem E: Certified asymptotic scaffold
You may not be able in one cycle to fully formalize Dixon’s theorem
\[
\Pr[\langle \sigma,\tau\rangle \in \{A_n,S_n\}] \to 1,
\]
but you should build the Lean infrastructure so that the asymptotic statement becomes reachable. At minimum, prove one or more certified asymptotic-form statements such as:

- the parity obstruction contributes exactly `1/4`,
- any pair generating `S_n` must avoid intransitivity,
- the probability of both permutations fixing a point is at most `1/n^2` times a combinatorial factor,
- union-bound style estimates over point stabilizers.

A strong intermediate theorem would be:
\[
p_n \ge 1 - \frac14 - \frac{C}{n}
\]
for some explicit `C : ℝ`, if you can derive enough subgroup-cover estimates. Even a weaker explicit bound is valuable if fully formalized.

---

## Precise Lean 4 Formalization Targets

Use concrete finite types and finite counting. Suggested definitions and theorem signatures:

```lean
open scoped BigOperators
open Finset

def symmGroup (n : ℕ) := Equiv.Perm (Fin n)

def generatesTop {n : ℕ} (σ τ : symmGroup n) : Prop :=
  Subgroup.closure ({σ, τ} : Set (symmGroup n)) = ⊤

def genPairFinset (n : ℕ) : Finset (symmGroup n × symmGroup n) :=
  (Fintype.elems (symmGroup n)).product (Fintype.elems (symmGroup n))

def genPairCount (n : ℕ) : ℕ :=
  ((genPairFinset n).filter (fun p => generatesTop p.1 p.2)).card

def genProb (n : ℕ) : ℚ :=
  genPairCount n / ((Fintype.card (symmGroup n)) ^ 2)
```

Primary theorem statements to aim for:

```lean
theorem symmetric_group_card (n : ℕ) :
    Fintype.card (symmGroup n) = Nat.factorial n
```

This should explicitly build on the catalog theorem `symmetric_group_order`.

```lean
theorem genProb_def (n : ℕ) :
    genProb n =
      genPairCount n / ((Nat.factorial n) ^ 2)
```

```lean
def alternatingSubgroup (n : ℕ) : Subgroup (symmGroup n) :=
  Equiv.Perm.sign.ker
```

```lean
theorem even_even_not_generate_symm {n : ℕ} (hn : 2 ≤ n)
    {σ τ : symmGroup n}
    (hσ : σ ∈ alternatingSubgroup n)
    (hτ : τ ∈ alternatingSubgroup n) :
    ¬ generatesTop σ τ
```

```lean
theorem genProb_le_three_quarters {n : ℕ} (hn : 2 ≤ n) :
    (genProb n : ℝ) ≤ (3 : ℝ) / 4
```

For exact small-`n` certification:

```lean
theorem genPairCount_three :
    genPairCount 3 = 18

theorem genProb_three :
    genProb 3 = 1 / 2
```

Since `|S_3| = 6`, this means exactly `18` generating ordered pairs out of `36`.

Structural event theorem:

```lean
def IsTransitiveSubgroup {n : ℕ} (H : Subgroup (symmGroup n)) : Prop :=
  ∀ i j : Fin n, ∃ g : H, g.1 i = j

theorem generatesTop_implies_transitive {n : ℕ} {σ τ : symmGroup n}
    (hgen : generatesTop σ τ) :
    IsTransitiveSubgroup (Subgroup.closure ({σ, τ} : Set (symmGroup n)))
```

```lean
theorem generatesTop_not_le_alternating {n : ℕ} (hn : 2 ≤ n) {σ τ : symmGroup n}
    (hgen : generatesTop σ τ) :
    ¬ Subgroup.closure ({σ, τ} : Set (symmGroup n)) ≤ alternatingSubgroup n
```

If asymptotic infrastructure is feasible, define:

```lean
def fixesPoint {n : ℕ} (σ : symmGroup n) (i : Fin n) : Prop := σ i = i
```

and derive bounds for the probability a random pair lies in a point stabilizer. This can support explicit intransitivity bounds.

---

## Why This Would Be a Breakthrough

A Lean formalization of random generation of `S_n` is not merely “group theory in a proof assistant.” It creates a certified platform for theorems at the interface of:

- **probabilistic group theory**,
- **random permutation statistics**,
- **asymptotic combinatorics**,
- **finite model verification**, and
- **algorithmic algebra**.

Once the event structure is formalized, one can ask certified questions about:
- random Cayley graph expansion,
- mixing of random walks on `S_n`,
- generation of primitive groups,
- average-case complexity of permutation group algorithms,
- and even analogies with threshold phenomena in random graph theory.

This is the seed of a **formal probabilistic theory of finite groups**.

---

## Building on Catalog Theorems

You must explicitly use:

1. `symmetric_group_order`  
   This is the obvious foundational bridge: convert group-cardinality statements into factorial identities. Every probability denominator should reduce to `(Nat.factorial n)^2` through this theorem.

2. `smooth_probability_bound`  
   Even though it originates elsewhere, use it conceptually as a template for **explicit finite probability bounds** with arithmetic denominators and error terms. The style of theorem is relevant: derive usable explicit inequalities, not merely existential asymptotics.

The circuit complexity theorems
- `degreeBound_le_two_pow_depth`
- `degreeBound_le_two_pow_mulGates`

suggest a second, more speculative bridge: represent the indicator function
\[
(\sigma,\tau)\mapsto \mathbf 1[\langle \sigma,\tau\rangle = S_n]
\]
or simpler obstruction indicators as Boolean/algebraic functions on permutation encodings. This opens a complexity-theoretic interpretation of generation probability.

Do not force this if it slows core proofs, but mention it in `FUTURE_DIRECTIONS.md` as a certified average-case complexity program.

---

## Proof Strategy Architecture

### Strategy A: Exact finite counting via subgroup structure of `S_3` and `S_4`
Most promising for immediate success.

1. **Define generating pairs and brute-force finite count**  
   Use `Fintype.elems` for `Equiv.Perm (Fin 3)` and filter by `generatesTop`.  
   Then normalize using `symmetric_group_order`.

2. **Exploit subgroup classification only where tiny**  
   For `S_3`, use the explicit classification:
   proper subgroups have orders `1,2,3`; a pair fails to generate iff both lie in a common proper subgroup.  
   This can be proved directly or computationally by finite enumeration.

3. **Derive exact probability**  
   Show `genPairCount 3 = 18`, hence `18 / 36 = 1/2`.

Why promising: tiny finite groups are tractable in Lean, and exact certification gives a concrete theorem immediately.

---

### Strategy B: Universal upper bound via parity and the alternating subgroup
This should definitely be completed.

1. **Define `A_n` as the kernel of sign**  
   `alternatingSubgroup n := Equiv.Perm.sign.ker`.

2. **Show closure stays inside `A_n` if generators are even**  
   Since `A_n` is a subgroup, if `σ, τ ∈ A_n`, then `Subgroup.closure {σ,τ} ≤ A_n`.

3. **Count even-even ordered pairs**  
   For `n ≥ 2`, `|A_n| = |S_n| / 2`.  
   Therefore at least `1/4` of all ordered pairs cannot generate `S_n`, yielding
   \[
   p_n \le 3/4.
   \]

Why promising: conceptually clean, mathematically nontrivial, and likely formalizable with existing sign machinery.

---

### Strategy C: Asymptotic scaffolding through obstruction events
This is the visionary path.

1. **Formalize transitivity obstructions**  
   If the generated subgroup is intransitive, then there exists a nontrivial subset preserved by both permutations. Start with the easier event “both fix a point.”

2. **Union-bound over stabilizers**  
   For each `i : Fin n`, count permutations fixing `i`; this subgroup is isomorphic to `S_{n-1}` and has size `(n-1)!`.  
   Thus the probability both random permutations fix a given point is `1/n^2`; summing over points gives a crude `1/n` obstruction estimate.

3. **Combine with parity**  
   This yields explicit upper/lower bounds around the expected asymptotic constant `3/4` for generating `S_n` specifically, and around `1` for generating `A_n` or `S_n`.

Why promising: this is the first genuine bridge from exact counting to asymptotic probabilistic group theory, and it mirrors how a future formal Dixon theorem would be built.

---

## Cross-Domain Connections You Must Exploit

### 1. Random permutation theory
Generation is controlled by cycle statistics, fixed points, and transitivity.  
A random permutation has approximately Poisson(1) fixed points; this suggests that intransitivity obstructions should be rare and quantifiable. Formalize at least the finite exact fixed-point counting for one point.

### 2. Probabilistic combinatorics
Treat “fails to generate `S_n`” as a union of structured bad events:
- both even,
- both in a point stabilizer,
- both in an imprimitive subgroup,
- both in a primitive proper subgroup.

Even if only the first two are fully formalized now, this decomposition is the scientifically important architecture.

### 3. Computational group theory
Exact certified counts for `S_3`, `S_4`, maybe `S_5` can be compared with GAP/Sage experiments.  
This creates a reproducible loop between theorem proving and symbolic computation.

### 4. Average-case complexity
Generation testing for permutation groups is algorithmic. The distribution of random generating pairs affects average-case runtime of Schreier–Sims style procedures. This is where the catalog’s complexity themes can become unexpectedly relevant.

### 5. Statistical mechanics / threshold phenomena
There is a “phase transition” flavor: random pairs rapidly move from nongenerating to almost generating as subgroup obstructions become sparse with `n`. This analogy can inspire future formal work on sharp thresholds in algebraic generation problems.

---

## Concrete Milestones

### Milestone 1
Formalize:
- `symmGroup`,
- `generatesTop`,
- `genPairCount`,
- `genProb`,
- `alternatingSubgroup`,
- cardinality reduction via `symmetric_group_order`.

### Milestone 2
Prove:
- `even_even_not_generate_symm`,
- `genProb_le_three_quarters`.

### Milestone 3
Certify exact finite case:
- `genPairCount_three`,
- `genProb_three`.

### Milestone 4
Define subgroup transitivity and prove:
- `generatesTop_implies_transitive`,
- `generatesTop_not_le_alternating`.

### Milestone 5
Prove at least one explicit intransitivity probability bound using point stabilizers.

---

## Experimental / Computational Companion

If Lean exact counting becomes cumbersome for `n = 4,5`, create `demo.py` or a small external script to compute:
\[
\#\{(\sigma,\tau)\in S_n^2 : \langle \sigma,\tau\rangle = S_n\}
\]
for small `n`, then use the data to guide theorem selection. But the final theorem statements must be Lean-certified, not merely experimentally observed.

Suggested empirical targets:
- `p_2 = 1/2`,
- `p_3 = 1/2`,
- estimate `p_4`, `p_5`,
- compare with probability of generating either `A_n` or `S_n`.

---

## What to Avoid

- Do **not** stop at a definition-only formalization.
- Do **not** merely restate `|S_n| = n!`.
- Do **not** pursue only computational enumeration without structural theorems.
- Do **not** drift into generic finite group generation with no symmetric-group specificity.

The point is to produce a certified theory of **why** random pairs generate `S_n` with high probability.

---

## Deliverables

Required:
- Lean 4 file(s) with new definitions and proofs.
- `FUTURE_DIRECTIONS.md`.

Optional:
- `ARTICLE.md`,
- `RESEARCH_PAPER.md`,
- `demo.py`.

Minimize `sorry`. If one deep asymptotic theorem remains out of reach, leave only the highest-value gap and fully prove the finite and structural scaffolding around it.

---

## Required FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each with a clear test. They must be precise conjectures, not vague ideas. Include items of the following flavor:

### [Exact Generation Probability for Small n]
Conjecture: `genPairCount 4 = ...` and `genProb 4 = ...`.
Test: certify by finite enumeration in Lean and cross-check with GAP.

### [Dixon-Style Certified Bound]
Conjecture: there exists an explicit constant `C : ℝ` such that for all `n ≥ 5`,
\[
\Pr[\langle \sigma,\tau\rangle \in \{A_n,S_n\}] \ge 1 - C/n.
\]
Test: formalize point-stabilizer and block-system obstruction bounds sufficient to derive an explicit `C`.

### [Point-Stabilizer Dominance]
Conjecture: among intransitive maximal subgroups of `S_n`, point stabilizers give the asymptotically largest contribution to nongeneration probability by random pairs.
Test: compare explicit subgroup-size-squared contributions for `S_k × S_{n-k}` across `k`.

### [Average-Case Schreier–Sims]
Conjecture: the expected number of stabilizer-chain refinement steps for two random generators of `S_n` is bounded by a polylogarithmic or low-degree polynomial function with high probability.
Test: implement experiments for random pairs and correlate with certified generation probabilities.

### [Circuit Complexity of Generation Predicates]
Conjecture: the Boolean predicate “two encoded permutations generate a transitive subgroup” admits algebraic circuits of significantly lower degree/size than the exact predicate “generate `S_n`”.
Test: encode obstruction predicates and compare degree bounds using catalog complexity lemmas.

---

## Application Keywords

probabilistic group theory; random permutations; symmetric group; alternating group; subgroup growth; transitivity; primitive groups; Dixon theorem; finite asymptotics; certified counting; computational group theory; average-case algebra; Schreier–Sims; random Cayley graphs; formalized mathematics; Lean 4; Mathlib

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

Research domain: Algebra
Research mode: prove
