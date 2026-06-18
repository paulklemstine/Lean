## Assignment: Erdős–Straus Conjecture as a Formal Egyptian-Fraction Program

Mode: **prove** + **formalize** + **discover**

You are not being asked for a routine restatement of a famous open problem. You are being asked to carve out a formally verified frontier around it: exact infinite families, modular reduction principles, certified computational verification, and a structural theory of three-term Egyptian decompositions of `4 / n`. The goal is to produce theorems that are genuinely non-trivial, mathematically meaningful, and Lean-native, while creating infrastructure that could support a future assault on the full conjecture.

Prove what is actually within reach, but prove it in a way that changes the landscape.

---

## Core Vision

The full Erdős–Straus conjecture states:

> For every integer `n ≥ 2`, there exist positive integers `x y z` such that
> `4 / n = 1 / x + 1 / y + 1 / z`.

This remains open in mathematics. Therefore, the breakthrough target in Lean is **not** “solve the conjecture” unless you truly can. The correct research program is:

1. **Formalize exact algebraic equivalences** between the unit-fraction identity and Diophantine equations.
2. **Prove infinite parametric families** of solutions for large natural classes of `n`.
3. **Prove modular closure / reduction theorems** showing that it suffices to check certain residue classes or prime cases.
4. **Implement and verify a bounded search procedure** and connect it to theorem statements.
5. **Build a reusable Egyptian-fraction API** over `ℕ`, `ℤ`, and `ℚ`.
6. **Extract falsifiable hypotheses** from the data and from the algebra.

This is a bridge between additive number theory, Diophantine geometry, computational verification, and certified search.

Application keywords: **Diophantine equations, Egyptian fractions, certified computation, modular arithmetic, residue class reduction, formal verification, additive number theory, algorithmic search, arithmetic geometry, symbolic computation**

---

## Primary Formal Targets

### 1. Define the predicate of Erdős–Straus representability

Use a positivity-preserving integer formulation instead of raw rational arithmetic whenever possible.

Suggested Lean definitions:

```lean
def ErdosStrausRep (n x y z : ℕ) : Prop :=
  0 < x ∧ 0 < y ∧ 0 < z ∧
    (4 : ℤ) * x * y * z = (n : ℤ) * (x * y + x * z + y * z)

def ErdosStrausSolvable (n : ℕ) : Prop :=
  ∃ x y z : ℕ, ErdosStrausRep n x y z
```

Also prove equivalence with the rational statement, under positivity assumptions:

```lean
theorem erdos_straus_rep_iff_rat
    {n x y z : ℕ} (hn : 0 < n) (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    ErdosStrausRep n x y z ↔
      ((4 : ℚ) / n = (1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z) := by
  sorry
```

This equivalence is foundational. It lets you move between algebraic and analytic views.

---

## Precise Theorem Statements to Target

### Theorem A: Even-denominator family

This is the cleanest universal infinite family and should be formalized first.

Mathematical statement:
> For every `k ≥ 1`,  
> `4 / (2k) = 1 / k + 1 / (2k) + 1 / (2k)`.

Lean target:

```lean
theorem erdos_straus_even (k : ℕ) (hk : 1 ≤ k) :
    ErdosStrausSolvable (2 * k) := by
  refine ⟨k, 2 * k, 2 * k, ?_⟩
  sorry
```

This is elementary but essential infrastructure and sanity-checking.

---

### Theorem B: Family `n ≡ 3 mod 4`

Classical identity:
For `n = 4k + 3`,
\[
\frac{4}{4k+3} = \frac{1}{k+1} + \frac{1}{(k+1)(4k+3)} + \frac{1}{(k+1)(4k+3)}.
\]

Check and formalize carefully. Equivalent denominator form:
for `n ≡ 3 [MOD 4]`, with `x = (n+1)/4`, `y = x*n`, `z = x*n`.

Lean target:

```lean
theorem erdos_straus_mod4_eq3 (n : ℕ)
    (hn : 2 ≤ n) (hmod : n % 4 = 3) :
    ErdosStrausSolvable n := by
  let x := (n + 1) / 4
  refine ⟨x, x * n, x * n, ?_⟩
  sorry
```

This is a genuinely meaningful infinite family theorem.

---

### Theorem C: Family `n ≡ 2 mod 3`

Use the identity:
If `n = 3k + 2`, then
\[
\frac{4}{n} = \frac{1}{k+1} + \frac{1}{n(k+1)} + \frac{1}{n(k+1)}.
\]
Indeed,
\[
\frac{1}{k+1} + \frac{2}{n(k+1)}
= \frac{n+2}{n(k+1)}
= \frac{3k+4}{(3k+2)(k+1)}
= \frac{4}{3k+2}.
\]

Lean target:

```lean
theorem erdos_straus_mod3_eq2 (n : ℕ)
    (hn : 2 ≤ n) (hmod : n % 3 = 2) :
    ErdosStrausSolvable n := by
  let x := n / 3 + 1
  refine ⟨x, n * x, n * x, ?_⟩
  sorry
```

You will need to extract `n = 3k + 2` from the modulus hypothesis and normalize arithmetic carefully.

This theorem matters because it covers another positive-density set of integers and shows the problem is naturally modular.

---

### Theorem D: Prime reduction theorem

A key structural theorem:

> If every prime `p ≥ 2` admits an Erdős–Straus decomposition, then every integer `n ≥ 2` admits one.

This is not the deepest known reduction, but it is conceptually powerful and formally tractable.

Use the divisor-lifting identity:
If `m ∣ n` and `4 / m = 1/a + 1/b + 1/c`, then
\[
\frac{4}{n}
=
\frac{1}{a(n/m)} + \frac{1}{b(n/m)} + \frac{1}{c(n/m)}.
\]

Lean target:

```lean
theorem erdos_straus_of_dvd
    {m n : ℕ} (hmn : m ∣ n) (hm : 1 ≤ m)
    (hsol : ErdosStrausSolvable m) :
    ErdosStrausSolvable n := by
  sorry

theorem erdos_straus_reduced_to_primes
    (hprime : ∀ p : ℕ, Nat.Prime p → ErdosStrausSolvable p) :
    ∀ n : ℕ, 2 ≤ n → ErdosStrausSolvable n := by
  sorry
```

This theorem turns the conjecture into a prime-only problem inside Lean, which is mathematically important and computationally decisive.

---

### Theorem E: Search completeness for bounded verification

Construct a verified decision procedure:

```lean
def searchErdosStraus (n B : ℕ) : Bool := ...
```

Then prove:

```lean
theorem searchErdosStraus_sound
    {n B : ℕ} :
    searchErdosStraus n B = true →
    ErdosStrausSolvable n := by
  sorry
```

And, if your search enumerates all triples up to bound `B`, prove the exact completeness statement relative to the bound:

```lean
theorem searchErdosStraus_complete_bounded
    {n B : ℕ} :
    (∃ x ≤ B, ∃ y ≤ B, ∃ z ≤ B, ErdosStrausRep n x y z) →
    searchErdosStraus n B = true := by
  sorry
```

Then package a theorem for explicit verified ranges, e.g. all `n ≤ N` for some feasible `N`:

```lean
theorem erdos_straus_verified_upto (N : ℕ) :
    ∀ n, 2 ≤ n → n ≤ N → ErdosStrausSolvable n := by
  sorry
```

If full proof by computation is too expensive in kernel, certify via reflection or generate certificates externally and verify them internally.

---

### Theorem F: Algebraic classification lemma

Derive a useful normal form:
\[
(4x-n)yz = nxy + nxz
\]
and related rearrangements. In particular, prove equivalence between the three-unit-fraction identity and a factorization-style equation that can guide search.

Suggested target:

```lean
theorem erdos_straus_rearrange
    {n x y z : ℕ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    ErdosStrausRep n x y z ↔
      ((4 : ℤ) * x - n) * y * z = (n : ℤ) * x * (y + z) := by
  sorry
```

This is the kind of theorem that opens algorithmic and structural avenues.

---

## Most Promising Proof Strategies

### Strategy 1: Integer-clearing and semiring normalization
This is the most promising for Lean.

1. Define representability via the cleared equation in `ℤ`.
2. Prove positivity lemmas allowing safe transport from `ℕ` to `ℤ` to `ℚ`.
3. Use `ring_nf`, `nlinarith`, `omega`, and modular arithmetic lemmas to discharge explicit parametric families.

Why this is strongest:
- It avoids fragile rational denominator manipulations.
- It is compatible with search certificates.
- It gives a reusable Diophantine interface.

---

### Strategy 2: Residue-class parametrization
Attack positive-density congruence classes systematically.

1. For each residue pattern (`n ≡ 0 mod 2`, `n ≡ 2 mod 3`, `n ≡ 3 mod 4`, possibly `n ≡ 5 mod 6`, etc.), derive explicit formulas for `x,y,z`.
2. Encode these as theorem schemas.
3. Combine them to obtain a large coverage theorem:
   “all `n` outside a sparse exceptional set satisfy `ErdosStrausSolvable n`.”

Why this matters:
- It transforms the conjecture into a covering problem in modular arithmetic.
- It produces actual number theory, not just brute force.
- It can be tested experimentally and refined.

---

### Strategy 3: Certified search + reduction to primes / residue exceptions
Blend theorem proving with finite verification.

1. Prove divisor-lifting and prime reduction.
2. Prove several congruence-family theorems to eliminate most integers.
3. Search only the remaining exceptional prime classes up to a large bound and verify the certificates.

Why this is scientifically powerful:
- It creates a formal experimental platform.
- It yields falsifiable hypotheses about exceptional residue patterns.
- It mirrors how modern computational number theory actually advances.

---

## Cross-Domain Connections You Must Exploit

### 1. Additive combinatorics / modular obstruction theory
The catalog theorem `zmod3_vec_three_mul` signals available infrastructure around arithmetic mod `3`. Use modular arithmetic aggressively: classify denominator families by congruence classes, and seek finite covering systems of the integers by parametric solution identities. This is a number-theoretic analogue of covering arguments in additive combinatorics.

### 2. Certified computation and proof by reflection
Your bounded search theorems should be architected like a mini proof-reflection engine. This connects the Erdős–Straus program to formal methods and certified symbolic computation. The real deliverable is not just a theorem but a framework for verified arithmetic experimentation.

### 3. Arithmetic geometry viewpoint
The equation
\[
4xyz = n(xy + xz + yz)
\]
defines an affine surface over the integers. Parametric families are rational curves on this surface. State this viewpoint explicitly in comments or documentation and use it to motivate constructions. Even if the formalization stays elementary, the mathematical interpretation is deeper: you are studying rational points on a family of cubic surfaces.

### 4. Complexity-theoretic angle
The search problem “find `x,y,z` for a given `n`” is an algorithmic witness problem. Formalizing sound and complete bounded search creates a certified NP-style witness framework for Egyptian fractions. This opens future work on witness-size bounds and search complexity.

---

## How to Use the Catalog Theorems

The listed catalog theorems are not directly about Egyptian fractions, but you should still mine them for reusable proof patterns and infrastructure:

- `sum_product` may offer generic multiplicative/additive inequality or factorization scaffolding. Inspect whether it can simplify algebraic decompositions or witness construction.
- `zmod3_vec_three_mul` suggests active modular arithmetic infrastructure with `ZMod 3`; leverage similar techniques for residue-class reasoning in `mod 3`.
- `gradient_sum_bound` and `ultrametric_sum_zero_dominant_bound` are likely not directly applicable, but they may reveal tactics or normalization patterns for handling structured sums.
- `exists_refinement_cell_for_pair` hints at decomposition strategies: imitate the philosophy by decomposing integers into arithmetic cells / congruence classes and proving a local theorem on each cell.

Do not force irrelevant citations. Instead, explicitly state when a theorem inspired a proof architecture rather than serving as a direct lemma.

---

## Concrete Milestones

1. **Core definitions**
   - `ErdosStrausRep`
   - `ErdosStrausSolvable`
   - rational/integer equivalence theorem

2. **Infinite families**
   - even numbers
   - `n ≡ 2 mod 3`
   - `n ≡ 3 mod 4`

3. **Structural reductions**
   - divisor-lifting
   - reduction to primes

4. **Algorithmics**
   - bounded search
   - soundness/completeness
   - explicit verified range theorem

5. **Synthesis theorem**
   Prove a coverage result such as:
   ```lean
   theorem erdos_straus_large_covered_set (n : ℕ) (hn : 2 ≤ n)
       (h : n % 2 = 0 ∨ n % 3 = 2 ∨ n % 4 = 3) :
       ErdosStrausSolvable n := by
     sorry
   ```

This is not the conjecture, but it is mathematically substantial and a strong formal foothold.

---

## Stretch Targets

If the above is completed, push further toward genuinely surprising theorems:

### Stretch 1: Two-parameter family theorem
Search for and prove a family of the form
\[
n = f(a,b) \implies \frac{4}{n} = \frac1{X(a,b)} + \frac1{Y(a,b)} + \frac1{Z(a,b)}.
\]
The goal is to discover a new rational-surface parametrization, not merely repackage a standard congruence class.

### Stretch 2: Minimal witness bounds
Prove a theorem of the form:
```lean
theorem exists_small_x_for_family ...
```
For certain congruence classes, show one denominator can always be chosen below an explicit linear bound in `n`. This connects to algorithmic complexity.

### Stretch 3: Symmetry and normalization
Prove that every solution can be reordered with `x ≤ y ≤ z`, and derive search reductions from that ordering. This dramatically improves computational verification.

---

## Lean 4 Type Signature Suggestions

Use these or close variants:

```lean
def ErdosStrausRep (n x y z : ℕ) : Prop :=
  0 < x ∧ 0 < y ∧ 0 < z ∧
    (4 : ℤ) * x * y * z = (n : ℤ) * (x * y + x * z + y * z)

def ErdosStrausSolvable (n : ℕ) : Prop :=
  ∃ x y z : ℕ, ErdosStrausRep n x y z

theorem erdos_straus_even (k : ℕ) (hk : 1 ≤ k) :
    ErdosStrausSolvable (2 * k) := by
  sorry

theorem erdos_straus_mod3_eq2 (n : ℕ)
    (hn : 2 ≤ n) (hmod : n % 3 = 2) :
    ErdosStrausSolvable n := by
  sorry

theorem erdos_straus_mod4_eq3 (n : ℕ)
    (hn : 2 ≤ n) (hmod : n % 4 = 3) :
    ErdosStrausSolvable n := by
  sorry

theorem erdos_straus_of_dvd
    {m n : ℕ} (hmn : m ∣ n) (hm : 1 ≤ m)
    (hsol : ErdosStrausSolvable m) :
    ErdosStrausSolvable n := by
  sorry

theorem erdos_straus_reduced_to_primes
    (hprime : ∀ p : ℕ, Nat.Prime p → ErdosStrausSolvable p) :
    ∀ n : ℕ, 2 ≤ n → ErdosStrausSolvable n := by
  sorry

def searchErdosStraus (n B : ℕ) : Bool := ...

theorem searchErdosStraus_sound
    {n B : ℕ} :
    searchErdosStraus n B = true →
    ErdosStrausSolvable n := by
  sorry

theorem searchErdosStraus_complete_bounded
    {n B : ℕ} :
    (∃ x ≤ B, ∃ y ≤ B, ∃ z ≤ B, ErdosStrausRep n x y z) →
    searchErdosStraus n B = true := by
  sorry
```

---

## What Would Count as a Breakthrough Here

A real breakthrough in this cycle would be one of:

1. A formally verified modular covering theorem that proves `ErdosStrausSolvable n` for all integers in a union of congruence classes of density close to `1`.
2. A prime-reduction plus certified-search theorem that yields a machine-checked verification to a serious bound.
3. A new parametric family not already standard in elementary expositions, derived from the cubic-surface viewpoint.
4. A polished Lean library for Egyptian fraction identities that others could use immediately.

Any one of these would open a formal research lane rather than merely checking examples.

---

## Required Deliverables

- Lean 4 files with minimal `sorry`
- Explicit theorem statements as above
- At least one nontrivial modular family theorem
- At least one certified search theorem
- Documentation comments explaining the Diophantine-surface viewpoint
- `FUTURE_DIRECTIONS.md`

---

## FUTURE_DIRECTIONS.md Requirements

You must produce `FUTURE_DIRECTIONS.md` with **3–5 precise, falsifiable conjectures**, each with a clear computational or formal test.

Use this exact style:

### [Direction Title]
**Conjecture.** ...
**Test.** ...

Your conjectures should be scientific, not vague. Strong candidate hypotheses include:

### Residue Covering Density
**Conjecture.** There exists a finite set of explicit parametric identities whose associated congruence classes cover all integers `n ≥ 2` except possibly primes in finitely many residue classes modulo `840`.
**Test.** Enumerate the induced residue classes in Lean or externally, verify exact coverage modulo `840`, and check whether every covered class admits a certified formula.

### Small-Denominator Witness Bound
**Conjecture.** For every `n ≥ 2` with `n % 3 = 2` or `n % 4 = 3`, there exists a solution `(x,y,z)` with `x ≤ (n+1)/3`.
**Test.** Prove this for the known parametric families and search for counterexamples outside them up to a large bound.

### Prime Exceptional Pattern
**Conjecture.** For primes `p`, every minimal solution under ordering `x ≤ y ≤ z` satisfies `x = ⌈p/4⌉` for a density-1 subset of primes.
**Test.** Compute minimal ordered solutions for primes up to a large bound and compare `x` with `⌈p/4⌉`.

### Search Complexity Threshold
**Conjecture.** Every solvable `n ≤ N` has a witness with `x ≤ n`, `y ≤ n^2`, `z ≤ n^2`.
**Test.** Prove the claim for the explicit families and verify it computationally for remaining `n` up to increasing `N`.

### Rational-Surface Parametrization
**Conjecture.** The affine surface `4xyz = n(xy+xz+yz)` admits a two-parameter rational parametrization on each residue class `n ≡ 2 (mod 3)` and `n ≡ 3 (mod 4)` compatible with the known one-parameter formulas.
**Test.** Derive candidate formulas symbolically, then verify them in Lean by ring normalization.

Make these hypotheses sharp enough that the next cycle can decisively confirm or refute them.

Go build the formal Egyptian-fraction engine that the full conjecture deserves.

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
