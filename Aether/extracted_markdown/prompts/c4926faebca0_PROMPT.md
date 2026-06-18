## Assignment: Algebraic Coding Theory Beyond Textbook Formalization — BCH, Reed–Solomon, and Verified Decoding Dynamics

**Mode:** `prove` + `formalize` + `discover`

Prove genuinely new, structurally important theorems in algebraic coding theory over finite fields, using Lean 4 + Mathlib, and **treat the existing BCH/RS distance results as base camp, not summit**. The goal is not merely to restate classical facts, but to build a verified theory of **algebraic decoding invariants**: how root constraints, linear recurrences, and syndrome dynamics interact to force unique reconstruction.

You should formalize BCH and Reed–Solomon codes over finite fields, prove strengthened structural forms of the BCH bound, construct a verified Berlekamp–Massey decoding framework, and connect coding theory to at least one other domain in a mathematically nontrivial way.

---

## Core Breakthrough Targets

The catalog already contains:

- `bch_bound` in `Algebra/Basic.lean`
- `reed_solomon_min_distance` in `FINAL/Algebra/RootBound.lean`
- `rs_distance_lower_bound` in `FINAL/Algebra/Distance.lean`

These should be used as **building blocks**. The breakthrough is to prove that **syndrome vanishing patterns and recurrence complexity are equivalent certificates of decodability**, and to do so in a way that supports a verified decoding algorithm.

### Central vision

Show that BCH/RS decoding is not just “an algorithm that works,” but a theorem saying:

> **small Hamming weight error patterns are exactly those whose syndrome streams admit a low-complexity annihilating recurrence, and the minimal recurrence determines the error locator polynomial uniquely below the half-distance threshold.**

This is the algebraic heart of modern coding, cryptography, streaming algorithms, and symbolic signal processing.

---

## Precise Theorem Targets

You must include at least **3 substantial theorems** with nontrivial proofs. At least one should be stronger than the currently listed catalog theorems in structure, not just notation.

### Theorem 1: Consecutive-root BCH distance theorem in a reusable structural form

Strengthen the catalog’s `bch_bound` into a theorem that explicitly packages the root-set hypothesis as a definable structure.

#### New definition requirement
Define a new concept, for example:

```lean
structure ConsecutiveRootSet (K : Type*) [Field K] :=
  (n : ℕ)
  (α : K)
  (offset designedDistance : ℕ)
  (h_primitive : IsPrimitiveRoot α n)
```

and a predicate expressing that a polynomial vanishes on a consecutive block of powers:

```lean
def HasConsecutiveRoots {K : Type*} [Field K] (f : K[X])
    (α : K) (offset δ : ℕ) : Prop :=
  ∀ j : Fin (δ - 1), Polynomial.eval (α ^ (offset + j.1)) f = 0
```

Then prove a theorem of the form:

```lean
theorem bch_bound_structural
  {K : Type*} [Field K] [DecidableEq K]
  {n δ b : ℕ} {α : K} {g c : K[X]}
  (hprim : IsPrimitiveRoot α n)
  (hroots : HasConsecutiveRoots g α b δ)
  (hdiv : g ∣ c)
  (hmod : c.natDegree < n) :
  hammingWeight (polyToWord n c) = 0 ∨ δ ≤ hammingWeight (polyToWord n c)
```

or an equivalent formulation in your chosen code model.

#### Why this matters
The existing `bch_bound` likely proves a distance lower bound abstractly. This strengthened version makes the root geometry **first-class**, allowing later theorems to reason about shifts, narrow-sense BCH codes, shortening, and designed-distance transformations.

---

### Theorem 2: Uniqueness of the error locator polynomial below half the BCH/RS distance

Formalize a theorem stating that if an error pattern has weight at most `t`, then its syndrome sequence has a unique minimal annihilating polynomial of degree at most `t`, and this polynomial coincides with the error locator polynomial.

A Lean-shaped target:

```lean
theorem errorLocator_unique_of_weight_le
  {K : Type*} [Field K] [DecidableEq K]
  {n t : ℕ} {α : K}
  (hprim : IsPrimitiveRoot α n)
  (e : Fin n → K)
  (hw : hammingWeight e ≤ t)
  (hdist : 2 * t < n) :
  ∃! Λ : K[X],
    Λ.Monic ∧
    Λ.natDegree ≤ t ∧
    annihilatesSyndromeSequence α e Λ ∧
    Λ = errorLocatorPolynomial α e
```

You may need to adapt the exact threshold assumptions depending on your code model, but the theorem should assert **existence and uniqueness** of the locator polynomial from syndrome data under a correctable error bound.

#### Why this is a breakthrough
This is the theorem that turns “Berlekamp–Massey computes something” into “Berlekamp–Massey computes the mathematically forced object.” It bridges finite-field algebra, linear recurrence theory, and decoding correctness.

---

### Theorem 3: Correctness of Berlekamp–Massey as a verified synthesis algorithm

Define the algorithm and prove it outputs a minimal recurrence / locator polynomial for syndrome streams arising from bounded-weight errors.

A Lean target could be:

```lean
theorem berlekampMassey_correct
  {K : Type*} [Field K] [DecidableEq K]
  (s : ℕ → K) (N : ℕ) :
  let Λ := berlekampMassey (K := K) N s
  in Λ.Monic ∧
     annihilatesPrefix s N Λ ∧
     ∀ Γ : K[X], Γ.Monic → annihilatesPrefix s N Γ →
       Λ.natDegree ≤ Γ.natDegree
```

Then connect it to decoding:

```lean
theorem berlekampMassey_decodes_bch
  {K : Type*} [Field K] [DecidableEq K]
  {n t : ℕ} {α : K}
  (hprim : IsPrimitiveRoot α n)
  (r c e : Fin n → K)
  (hr : r = c + e)
  (hcode : IsBCHCodeword α n (2 * t + 1) c)
  (hw : hammingWeight e ≤ t) :
  decodeWithBM α t r = some c
```

You may split this into locator correctness + evaluator correctness + final decoding correctness if needed.

#### Why this matters
This is a certified decoding pipeline. It opens the door to verified communication stacks, fault-tolerant storage proofs, and algebraic cryptanalysis tools.

---

## Additional Strong Theorem: Cross-domain connection

You must include at least one theorem connecting coding theory to another domain.

### Recommended connection: linear recurrence / Hankel rank / control theory

Define the syndrome Hankel matrix and prove that bounded error weight implies bounded Hankel rank.

```lean
def syndromeHankelMatrix {K : Type*} [Field K] (s : ℕ → K) (m : ℕ) :
    Matrix (Fin m) (Fin m) K := ...

theorem hankelRank_le_weight
  {K : Type*} [Field K] [DecidableEq K]
  {n : ℕ} {α : K} (e : Fin n → K) :
  Matrix.rank (syndromeHankelMatrix (syndromeSeq α e) n)
    ≤ hammingWeight e
```

This is a deep cross-domain bridge:
- coding theory ↔ linear systems / realization theory
- decoding ↔ sparse exponential interpolation
- syndrome complexity ↔ structured low-rank recovery

If full rank formalization is too heavy, prove a kernel/dependence version:
there exists a nontrivial linear dependence among `t+1` consecutive syndrome windows whenever `hammingWeight e ≤ t`.

#### Revolutionary significance
This reframes algebraic decoding as **structured low-rank inference**. It connects BCH/RS codes to signal processing, Prony’s method, compressed sensing, and system identification.

---

## Lean 4 Type Signature Suggestions

You do not need to use these exact names, but your final file should contain theorem statements with this level of precision.

```lean
def hammingWeight {α : Type*} [Zero α] [DecidableEq α] {n : ℕ} (x : Fin n → α) : ℕ := ...

def polyToWord {K : Type*} [Zero K] (n : ℕ) (f : K[X]) : Fin n → K := ...

def syndromeSeq {K : Type*} [Field K] {n : ℕ} (α : K) (e : Fin n → K) : ℕ → K := ...

def annihilatesPrefix {K : Type*} [Field K] (s : ℕ → K) (N : ℕ) (Λ : K[X]) : Prop := ...

def annihilatesSyndromeSequence {K : Type*} [Field K] (α : K) (e : Fin n → K) (Λ : K[X]) : Prop := ...

def errorLocatorPolynomial {K : Type*} [Field K] [DecidableEq K]
    {n : ℕ} (α : K) (e : Fin n → K) : K[X] := ...

def berlekampMassey {K : Type*} [Field K] [DecidableEq K] :
    ℕ → (ℕ → K) → K[X]
```

Suggested theorem signatures:

```lean
theorem bch_bound_structural
  {K : Type*} [Field K] [DecidableEq K]
  {n δ b : ℕ} {α : K} {g c : K[X]} :
  IsPrimitiveRoot α n →
  HasConsecutiveRoots g α b δ →
  g ∣ c →
  c.natDegree < n →
  hammingWeight (polyToWord n c) = 0 ∨ δ ≤ hammingWeight (polyToWord n c)
```

```lean
theorem locator_annihilates_syndrome
  {K : Type*} [Field K] [DecidableEq K]
  {n : ℕ} {α : K} (e : Fin n → K) :
  annihilatesSyndromeSequence α e (errorLocatorPolynomial α e)
```

```lean
theorem errorLocator_unique_of_weight_le
  {K : Type*} [Field K] [DecidableEq K]
  {n t : ℕ} {α : K} (e : Fin n → K) :
  hammingWeight e ≤ t →
  ∃! Λ : K[X],
    Λ.Monic ∧ Λ.natDegree ≤ t ∧ annihilatesSyndromeSequence α e Λ
```

```lean
theorem berlekampMassey_correct
  {K : Type*} [Field K] [DecidableEq K]
  (s : ℕ → K) (N : ℕ) :
  let Λ := berlekampMassey (K := K) N s
  in Λ.Monic ∧
     annihilatesPrefix s N Λ ∧
     ∀ Γ : K[X], Γ.Monic → annihilatesPrefix s N Γ → Λ.natDegree ≤ Γ.natDegree
```

```lean
theorem hankelRank_le_weight
  {K : Type*} [Field K] [DecidableEq K]
  {n : ℕ} {α : K} (e : Fin n → K) :
  Matrix.rank (syndromeHankelMatrix (syndromeSeq α e) n) ≤ hammingWeight e
```

---

## Proof Architecture: 3 Possible Routes

You must not rely on trivial automation. Use induction, `rcases`, contradiction, polynomial algebra, matrix reasoning, and multi-step `calc`.

### Strategy A: Vandermonde / root-evaluation route for BCH bound
Most promising for the BCH theorem.

1. Express a nonzero codeword polynomial `c` with support of size `w`.
2. Assume `w < δ`; evaluate `c` at consecutive roots `α^(b+i)` for `i = 0, …, δ-2`.
3. Build a Vandermonde-type linear system on the nonzero coefficient positions and prove invertibility using distinctness of powers from `IsPrimitiveRoot α n`.
4. Derive all supported coefficients vanish, contradiction.

Why promising:
- It directly generalizes the standard BCH proof.
- Mathlib’s polynomial evaluation and primitive root infrastructure should support the distinctness arguments.
- It naturally yields a reusable lemma: sparse polynomials cannot vanish on too many consecutive primitive powers.

### Strategy B: Linear recurrence / syndrome synthesis route for BM correctness
Most promising for the decoding theorem.

1. Define syndrome sequence as a finite sum of exponentials indexed by error locations:
   `s_i = ∑_{j in supp(e)} E_j * X_j^i`.
2. Define the locator polynomial `Λ(z) = ∏ (1 - X_j z)` and prove via expansion that the coefficients of `Λ` induce a recurrence annihilating `s`.
3. Prove minimality: any monic annihilator of smaller degree would imply a shorter recurrence for a sum of `w` distinct exponentials, contradicting linear independence.
4. Show Berlekamp–Massey computes the minimal monic annihilator on long enough prefixes.

Why promising:
- This route reveals the actual mathematics behind BM.
- It creates the cross-domain bridge to sparse interpolation and structured linear algebra.
- It supports both existence/uniqueness and algorithm correctness in one framework.

### Strategy C: Hankel matrix / low-rank structured algebra route
Most promising for the cross-domain theorem.

1. Build the Hankel matrix `H[i,j] = s_(i+j)` from the syndrome sequence.
2. Express `H` as a sum of rank-1 matrices corresponding to error locations:
   `H = Σ_u v_u ⊗ w_u`.
3. Conclude `rank(H) ≤ weight(e)`.
4. Use a kernel vector of `H` to obtain an annihilating polynomial; then connect the nullspace relation to Berlekamp–Massey.

Why promising:
- This is conceptually powerful and modern.
- It links coding theory to control theory and signal processing.
- Even a finite-prefix version is already a substantial theorem.

---

## How to Build on Catalog Theorems

Do not reprove Reed–Solomon minimum distance from scratch unless needed as an internal lemma. Instead:

- Use `FINAL/Algebra/RootBound.lean : reed_solomon_min_distance`
  to transfer root-count arguments into distance lower bounds for evaluation codes.
- Use `FINAL/Algebra/Distance.lean : rs_distance_lower_bound`
  as the evaluation-code analogue when proving correctness of RS decoding.
- Use `Algebra/Basic.lean : bch_bound`
  as the seed theorem, then **refactor upward** into a structural theorem with explicit consecutive-root data and codeword representation.

Concrete upgrade path:
1. Extract from `bch_bound` the key lemma that many consecutive roots force large support.
2. Package that lemma using your new `HasConsecutiveRoots` / `ConsecutiveRootSet`.
3. Reuse the support bound in the proof that two candidate decoded codewords within radius `t` must coincide.
4. Feed this uniqueness theorem into the correctness proof of your decoding algorithm.

---

## Concrete Nontrivial Formalization Components

You should formalize at least one genuinely new mathematical structure. Recommended options:

1. `ConsecutiveRootSet`
2. `SyndromeStream`
3. `LocatorPolynomialData`
4. `LinearRecurrenceCertificate`
5. `DecodingCertificate`

For example:

```lean
structure LinearRecurrenceCertificate (K : Type*) [Field K] where
  poly : K[X]
  monic' : poly.Monic
  annihilates' : Prop
  minimal' : ∀ q : K[X], q.Monic → annihilatesPrefix s N q → poly.natDegree ≤ q.natDegree
```

This is not just bureaucracy: it gives you a reusable theorem interface for algorithm correctness.

---

## Cross-Domain Connections You Should Explicitly Develop

At least one theorem and part of the prose in `RESEARCH_PAPER.md` must make one of these bridges explicit:

1. **Coding theory ↔ linear systems / control theory**
   - Minimal annihilating polynomial of syndromes = minimal realization order.
   - BM = system identification on a finite field signal.

2. **Coding theory ↔ sparse exponential interpolation / Prony’s method**
   - Syndrome sequence is a finite sum of exponentials.
   - Error location recovery is discrete spectral estimation.

3. **Coding theory ↔ structured low-rank matrix recovery**
   - Hankel rank detects sparsity of the error pattern.
   - Decoding becomes exact recovery from a structured matrix factorization.

4. **Coding theory ↔ computational complexity / verified algorithms**
   - Certified decoder correctness is a theorem about feasible algebraic recovery.
   - This opens a path to trustworthy storage, communications, and post-quantum infrastructure.

---

## Application Keywords

Include these explicitly in your writeup and theorem framing:

**application keywords:** error-correcting codes, finite fields, syndrome decoding, Berlekamp–Massey, linear recurrence, Hankel matrices, structured low-rank recovery, sparse interpolation, reliable communication, storage systems, cryptography, formal verification, certified algorithms, algebraic signal processing

---

## Concrete Deliverables

You must produce **all** of the following:

### 1. Lean development
A file with:
- at least **3 deep theorems**
- at least **1 novel definition**
- no dependence on trivial proof-by-enumeration
- minimized `sorry`
- at least one theorem using induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 falsifiable scientific hypotheses**, each with a clear computational test.

Example hypotheses you may refine:

- **Hypothesis 1:** For BCH/RS syndrome streams from error weight `t`, the minimal annihilator degree equals the Hankel rank on any prefix of length at least `2t`.
  - **Test:** compute syndrome prefixes for random finite-field error patterns and compare BM degree to Hankel rank.

- **Hypothesis 2:** For random sparse error patterns over sufficiently large finite fields, the locator polynomial is recovered uniquely from fewer than `2t` syndromes with probability approaching 1.
  - **Test:** Monte Carlo over finite fields of increasing size.

- **Hypothesis 3:** The verified BM decoder can be generalized to alternant/Goppa-style parity-check structures by replacing primitive-power syndromes with rational evaluation syndromes.
  - **Test:** implement small alternant instances and check whether the recurrence framework still identifies correct locator polynomials.

- **Hypothesis 4:** The syndrome Hankel rank profile detects burst errors differently from random sparse errors, enabling formally verified error-shape classification.
  - **Test:** compare rank-growth curves for burst vs random support patterns.

### 3. `RESEARCH_PAPER.md`
A **standalone scientific document** explaining:
- the exact new theorems
- how they build on the catalog
- why the structural BCH and BM results matter
- the cross-domain significance
- the algorithmic implications
- open problems and next experiments

Someone reading only this paper must understand the discovery without opening the Lean files.

### 4. `ARTICLE.md`
Write this in **Scientific American style**:
- explain what BCH and RS codes do
- explain why proving decoder correctness formally is important
- describe the surprising bridge to linear recurrences / Hankel matrices / signal reconstruction
- make the result exciting and accessible

### 5. Verified algorithm
Implement a verified computational method:
- Berlekamp–Massey on finite syndrome prefixes, or
- a syndrome-to-locator reconstruction procedure with correctness theorem

### 6. `demo.py`
Provide an interactive demo that:
- constructs a finite-field RS or BCH-style example
- injects errors
- computes syndromes
- runs the decoder
- displays the recovered locator polynomial / corrected word
- optionally visualizes Hankel rank versus error weight

---

## Standards of Depth

Do not settle for:
- mere restatement of `reed_solomon_min_distance`
- trivial finite examples
- theorem statements with proofs by computation only
- definitions with no structural role

Instead, aim for this conceptual chain:

> consecutive roots ⇒ distance lower bound  
> bounded error weight ⇒ low-complexity syndrome recurrence  
> minimal recurrence ⇒ unique locator polynomial  
> verified algorithm computes this polynomial ⇒ certified decoding

That chain is the real theorem.

If possible, end with a theorem showing **unique decoding radius** as a formal corollary of your distance and locator results:

```lean
theorem unique_decode_of_lt_half_distance
  {K : Type*} [Field K] [DecidableEq K]
  {n : ℕ} {C : Set (Fin n → K)} {r c₁ c₂ : Fin n → K} {t d : ℕ} :
  (∀ c ∈ C, d ≤ hammingDist c 0 ∨ c = 0) →
  hammingDist r c₁ ≤ t →
  hammingDist r c₂ ≤ t →
  c₁ ∈ C →
  c₂ ∈ C →
  2 * t < d →
  c₁ = c₂
```

This would connect your algebraic distance theorems to the operational meaning of decoding.

Be ambitious: the right result here is not “BCH exists in Lean,” but **a verified theory of algebraic recovery from structured finite-field signals**.

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
