## Assignment: Hadamard Matrix Conjecture — A Formal Blueprint for a Breakthrough Program

**Mode:** `prove`

You are not being asked for a routine formalization of folklore. You are being asked to turn the Hadamard conjecture into a **structured Lean 4 research platform** that can certify infinite families, expose genuine obstructions, and create a bridge from discrete matrix theory to design theory, coding theory, and harmonic/signal analysis.

The central ambition is to formalize a theorem-complex around the statement:

> **Hadamard Conjecture.** For every positive integer `n`, if `4 ∣ n`, then there exists an `n × n` Hadamard matrix.

You will almost certainly not settle the full conjecture in one cycle. So the goal is more ambitious in a different sense: **build a mathematically deep, extensible, machine-verified theory that captures the best known infinite constructions, derives structural consequences, and produces computationally testable frontier conjectures.**

---

## Core Formal Target

Introduce a robust Lean notion of Hadamard matrix over `ℤ` or `ℝ` with entries `±1` and orthogonal rows.

A recommended definition:

```lean
def IsHadamard {n : Type*} [Fintype n] (H : Matrix n n ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * Hᵀ = (Fintype.card n : ℤ) • (1 : Matrix n n ℤ)
```

If this exact signature is inconvenient because of scalar coercions or matrix libraries, use a variant over `ℝ`:

```lean
def IsHadamard {n : Type*} [Fintype n] (H : Matrix n n ℝ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * Hᵀ = (Fintype.card n : ℝ) • (1 : Matrix n n ℝ)
```

You may also want a bundled structure:

```lean
structure HadamardMatrix (n : Type*) [Fintype n] where
  toMatrix : Matrix n n ℤ
  entries_pm_one : ∀ i j, toMatrix i j = 1 ∨ toMatrix i j = -1
  orthogonal : toMatrix * toMatrixᵀ = (Fintype.card n : ℤ) • (1 : Matrix n n ℤ)
```

This is your foundational new concept. It is not enough to merely restate existing examples.

---

## Precise Theorem Targets

You must prove **at least 3 deep theorems**, and they should not be toy lemmas. At minimum, target the following theorem cluster.

### Theorem 1: Necessary divisibility obstruction
For every Hadamard matrix of order greater than `2`, the order is divisible by `4`.

Mathematical statement:
> If `H` is a Hadamard matrix of order `n` and `n > 2`, then `4 ∣ n`.

Suggested Lean-style signature:
```lean
theorem hadamard_order_mod_four
    {n : ℕ} (hn : 2 < n)
    (H : Matrix (Fin n) (Fin n) ℤ)
    (hH : IsHadamard H) :
    4 ∣ n
```

Why this matters:
This is the first genuine arithmetic obstruction and turns the conjecture into a sharp existence problem rather than a vague search. It also forces you to formalize the classical normalization-and-parity argument, which is mathematically nontrivial and proof-rich.

### Theorem 2: Sylvester infinite family
Construct Hadamard matrices of order `2^k` for all `k`.

Mathematical statement:
> For every `k : ℕ`, there exists a Hadamard matrix of order `2^k`.

Suggested Lean signature:
```lean
def sylvesterMatrix : ℕ → Matrix (Fin (2^k)) (Fin (2^k)) ℤ := ...

theorem exists_hadamard_pow_two (k : ℕ) :
    ∃ H : Matrix (Fin (2^k)) (Fin (2^k)) ℤ, IsHadamard H
```

More implementation-friendly recursive version:
```lean
def Sylvester : ℕ → Type
| 0 => Fin 1
| k+1 => Fin (2^(k+1))

theorem sylvester_isHadamard (k : ℕ) :
    IsHadamard (sylvesterMatrix k)
```

Why this matters:
This is the canonical infinite family and the backbone of recursive formalization. It is the gateway to tensor methods, Walsh transforms, and coding-theoretic applications.

### Theorem 3: Tensor closure
The Kronecker product of Hadamard matrices is Hadamard.

Mathematical statement:
> If `H₁` and `H₂` are Hadamard, then `H₁ ⊗ H₂` is Hadamard.

Suggested Lean signature:
```lean
theorem IsHadamard.kronecker
    {m n : ℕ}
    {H₁ : Matrix (Fin m) (Fin m) ℤ}
    {H₂ : Matrix (Fin n) (Fin n) ℤ}
    (h₁ : IsHadamard H₁)
    (h₂ : IsHadamard H₂) :
    IsHadamard (Matrix.kroneckerMap (fun a b => a * b) H₁ H₂)
```

If `Matrix.kroneckerMap` is awkward, define your own tensor/block matrix operator.

Why this matters:
This theorem transforms isolated examples into a multiplicative existence engine. It is the key mechanism behind large-order construction and links directly to signal processing via tensorized Walsh systems.

### Theorem 4: Hadamard code distance theorem
Associate a binary code to a normalized Hadamard matrix and prove its minimum distance.

Mathematical statement:
> A normalized Hadamard matrix of order `n` yields a binary code of length `n`, size `n`, and pairwise distance `n/2`.

Suggested Lean-style signature:
```lean
def hadamardCode {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Fin n → Fin n → Bool := ...

theorem hadamard_code_distance
    {n : ℕ}
    (H : Matrix (Fin n) (Fin n) ℤ)
    (hH : IsHadamard H)
    (h_norm : NormalizedHadamard H) :
    ∀ i j, i ≠ j → hammingDist (hadamardCode H i) (hadamardCode H j) = n / 2
```

Why this matters:
This is your required **cross-domain theorem**. It connects combinatorics and matrix theory to coding theory and information transmission. It is not a decorative remark; it is a formal theorem with downstream algorithmic use.

### Theorem 5: Design-theoretic bridge
Show that a normalized Hadamard matrix of order `4t` induces a symmetric `2-(4t-1, 2t-1, t-1)` design (or a formalized incidence-structure shadow of this statement if full design theory infrastructure is unavailable).

Suggested Lean target:
```lean
structure IncidenceStructure (α β : Type*) :=
  (inc : α → β → Prop)

theorem normalized_hadamard_gives_design
    {t : ℕ} (ht : 0 < t)
    (H : Matrix (Fin (4*t)) (Fin (4*t)) ℤ)
    (hH : IsHadamard H)
    (h_norm : NormalizedHadamard H) :
    ∃ D : IncidenceStructure (Fin (4*t - 1)) (Fin (4*t - 1)), IsSymmetricBIBD D (4*t - 1) (2*t - 1) (t - 1)
```

If `IsSymmetricBIBD` does not exist, define the exact counting predicates you need.

Why this matters:
This opens a route from Hadamard existence to combinatorial design classification. It also gives a mathematically rich reason to care about normalization, row/column deletion, and incidence encoding.

---

## New Definitions You Should Introduce

You are required to define at least one novel concept. Define several, because the area demands infrastructure.

### 1. Normalized Hadamard matrices
A Hadamard matrix whose first row and first column are all `1`.

```lean
def NormalizedHadamard {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  IsHadamard H ∧
  (∀ j, H 0 j = 1) ∧
  (∀ i, H i 0 = 1)
```

Then prove normalization by row/column sign flips:

```lean
theorem exists_normalized_of_isHadamard
    {n : ℕ}
    {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) :
    ∃ H' : Matrix (Fin n) (Fin n) ℤ, NormalizedHadamard H'
```

This is a deep structural theorem and should require multi-step reasoning, not automation.

### 2. Hadamard equivalence
Matrices equivalent up to row/column permutations and sign changes.

```lean
def HadamardEquivalent {n : ℕ}
    (H K : Matrix (Fin n) (Fin n) ℤ) : Prop := ...
```

Prove invariance:
```lean
theorem hadamard_equiv_preserves
    {n : ℕ} {H K : Matrix (Fin n) (Fin n) ℤ} :
    HadamardEquivalent H K → (IsHadamard H ↔ IsHadamard K)
```

This is mathematically essential for classification and computational search.

### 3. Excess / row-sum invariant
Define the excess:
```lean
def hadamardExcess {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : ℤ :=
  ∑ i, ∑ j, H i j
```

Prove a bound, or at least derive exact excess for Sylvester matrices after normalization. This gives an analytic invariant useful in signal and combinatorial optimization contexts.

---

## Proof Strategy Architecture

You must include proof scripts with real structure: induction, `rcases`, contradiction, `field_simp`, matrix extensionality, and `calc` chains. Avoid low-value proofs.

### Strategy A: Normalization + parity obstruction
Best for Theorem 1.

1. Prove every Hadamard matrix is equivalent to a normalized one by multiplying rows/columns by `-1`.
2. In a normalized matrix of order `n > 2`, each non-first row has exactly `n/2` entries equal to `1` and `n/2` equal to `-1`, because orthogonality with the first row forces row sum zero.
3. Compare two non-first rows: among columns excluding the first, partition positions by sign agreement/disagreement. Orthogonality and parity imply `n/2` is even, hence `4 ∣ n`.

Why promising:
This is the classical route, conceptually clean, and formalizes well using finite sums and parity lemmas. It naturally produces intermediate lemmas valuable for later code/design constructions.

### Strategy B: Tensor-recursive construction
Best for Theorems 2 and 3.

1. Define the `2 × 2` seed matrix `[[1,1],[1,-1]]`.
2. Define `sylvesterMatrix (k+1)` recursively as the block matrix
   \[
   \begin{pmatrix}
   H_k & H_k \\
   H_k & -H_k
   \end{pmatrix}.
   \]
3. Prove orthogonality recursively, either directly by block multiplication or by identifying the recursion with Kronecker product by the seed matrix.

Why promising:
This approach gives both the concrete family and a reusable tensor theorem. It also interfaces naturally with Walsh transforms and fast algorithms.

### Strategy C: Finite-field/Paley route
Most visionary, but likely technically heavier.

1. Define a Paley matrix using the quadratic character over `𝔽_q` for `q ≡ 3 (mod 4)` or a conference-matrix variant for `q ≡ 1 (mod 4)`.
2. Prove character sum orthogonality using finite-field sums.
3. Deduce existence of Hadamard matrices of order `q+1` or `2(q+1)` in the relevant cases.

Suggested theorem target:
```lean
theorem exists_hadamard_paley_typeI
    {q : ℕ} (hq_prime : Nat.Prime q) (hq_mod : q % 4 = 3) :
    ∃ H : Matrix (Fin (q+1)) (Fin (q+1)) ℤ, IsHadamard H
```

Why promising:
If successful, this is the leap from “formalize a known recursion” to “build a serious number-theoretic existence engine.” It creates a bridge to finite fields, character sums, and additive combinatorics. Even partial formalization here is high-value.

---

## Cross-Domain Connections You Must Make Explicit

This project should not remain trapped inside matrix combinatorics. Make at least one theorem and one algorithmic artifact that touch another field.

### 1. Coding theory
A normalized Hadamard matrix gives an equidistant binary code. This supports robust communication and error detection.

**Keywords:** Hamming distance, equidistant code, binary code, error-correcting codes, coding gain.

### 2. Signal processing / harmonic analysis
Sylvester Hadamard matrices generate Walsh functions and fast transform architectures.

Formal direction:
- Define the Walsh-Hadamard transform.
- Prove energy preservation up to scaling:
```lean
theorem walsh_energy_identity
    {k : ℕ} (x : Fin (2^k) → ℝ) :
    ‖(sylvesterMatrix k).mulVec x‖^2 = (2^k : ℝ) * ‖x‖^2
```
or an equivalent finite-sum identity.

This is a profound cross-domain theorem: orthogonal combinatorial objects become computational harmonic transforms.

**Keywords:** Walsh transform, orthogonality, spectral methods, compressed sensing, fast transforms.

### 3. Design theory
Normalized Hadamard matrices induce balanced incomplete block designs. This is a major bridge to finite geometry and statistical experiment design.

**Keywords:** BIBD, incidence geometry, symmetric design, finite geometry, experimental design.

### 4. Number theory
Paley constructions connect Hadamard existence to quadratic residues over finite fields.

**Keywords:** quadratic character, Gauss sums, finite fields, arithmetic combinatorics.

---

## How to Use Existing Verified Theorems

The catalog context is sparse, but still useful as infrastructure rather than as direct content.

- `not_every_hadamard_symmetric` from `Algebra/Hadamard/Examples.lean` should be used to avoid overconstraining your structures. In particular, do **not** define Hadamard matrices with unnecessary symmetry assumptions. Include a theorem or remark showing your definitions properly encompass non-symmetric examples.
- `exists_nonzero_row_of_matrix_ne_zero` from `FINAL/Algebra/Basic.lean` can support auxiliary arguments about nonzero rows in matrix constructions or normalization steps when proving certain rows remain nontrivial after transformations.
- `tensor_gap_bound` may suggest existing tensor infrastructure or naming conventions. If there is already a Kronecker/tensor API in your environment, build on that instead of reimplementing blindly.

You should inspect the final vetted paths first:
- `FINAL/Algebra/Basic.lean`
- `FINAL/Algebra/FreivaldsVerification.lean`
- `Algebra/Hadamard/Examples.lean`

The point is not to shoehorn these theorems into the story, but to **anchor your new work in verified infrastructure and avoid duplicating machinery unnecessarily**.

---

## Minimum Theorem Portfolio for This Cycle

Your Lean development should contain at least these kinds of results:

1. **A structural theorem**  
   Example: normalization exists up to equivalence.

2. **An obstruction theorem**  
   Example: order of nontrivial Hadamard matrix is divisible by `4`.

3. **A construction theorem**  
   Example: Sylvester family exists for all powers of `2`.

4. **A closure theorem**  
   Example: tensor product preserves Hadamard property.

5. **A cross-domain theorem**  
   Example: Hadamard code has distance `n/2`, or Walsh transform preserves energy up to scaling.

At least 3 of these must involve nontrivial proof patterns such as induction, `rcases`, contradiction, `field_simp`, matrix extensionality, finite-sum manipulations, or long `calc` chains.

---

## Frontier Conjectures With Testable Predictions

You are required to state at least one falsifiable conjecture with a clear computational disproof protocol. Include it in both Lean comments and `FUTURE_DIRECTIONS.md`.

Here are strong candidates.

### Conjecture A: Minimal excess rigidity in normalized equivalence classes
> For every normalized Hadamard matrix `H` of order `4t`, the absolute excess is maximized by matrices equivalent to Sylvester-type constructions only in dyadic orders.

Test:
- Enumerate known equivalence classes up to feasible order.
- Compute `hadamardExcess`.
- Search for counterexamples at non-dyadic orders.

### Conjecture B: Tensor-factor detectability
> If a Hadamard matrix of order `mn` has row-sum and block-correlation statistics matching a Kronecker product profile, then it is Hadamard-equivalent to a tensor product of orders `m` and `n`.

Test:
- Compute block correlation invariants on known databases.
- Attempt decomposition search.
- A single indecomposable counterexample falsifies the conjecture.

### Conjecture C: Paley–Sylvester spectral separation
> For orders where both Sylvester and Paley constructions exist, the associated binary codes have distinguishable second-order correlation spectra.

Test:
- Generate both constructions.
- Compute pair-correlation or Walsh spectra.
- Equality of spectra at one order would refute the conjecture.

These are not vague “future work” slogans. They are computationally meaningful and can guide your `demo.py`.

---

## Verified Algorithm / Computational Method Requirement

You must produce a verified algorithm, not just theorem statements.

Recommended algorithmic target:

### Algorithm 1: Recursive constructor for Sylvester Hadamard matrices
Input: `k : ℕ`  
Output: matrix `H_k` of order `2^k` with certified proof `IsHadamard H_k`.

This should be formally verified in Lean and exported conceptually to Python.

### Algorithm 2: Hadamard code generator
Input: normalized Hadamard matrix `H`  
Output: binary codewords obtained by mapping `1 ↦ 0`, `-1 ↦ 1` (or the reverse), together with a certified theorem on pairwise Hamming distance.

### Algorithm 3: Equivalence-normalization procedure
Input: Hadamard matrix `H`  
Output: equivalent normalized matrix `H'`.

This is particularly valuable because it turns existential structure into a canonical computational workflow.

---

## demo.py Requirement

Your `demo.py` must do more than print a matrix.

It should:
1. Generate Sylvester matrices for several `k`.
2. Verify orthogonality numerically.
3. Convert them into binary Hadamard codes.
4. Compute pairwise Hamming distances and display the equidistant property.
5. Optionally compare spectral behavior or row-sum/excess statistics.
6. If you implement Paley constructions, compare Sylvester vs Paley examples at the same order.

An excellent demo would let the user choose:
- construction type (`sylvester`, `tensor`, maybe `paley`)
- order
- whether to view code metrics, transform behavior, or design incidence data

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorem proofs.
2. **FUTURE_DIRECTIONS.md** containing **3–5 falsifiable scientific hypotheses**, each with:
   - exact conjecture statement,
   - why it matters,
   - explicit computational or theoretical test that could disprove it.
3. **RESEARCH_PAPER.md** as a standalone scientific paper:
   - define Hadamard matrices,
   - state what was formalized,
   - explain the significance to combinatorics, coding, and signal processing,
   - describe open problems and your conjectures,
   - readable without access to the code.
4. **ARTICLE.md** in Scientific American style:
   - explain why matrices filled with `±1` can organize communication, geometry, and computation,
   - make the formal breakthrough accessible to a broad audience.
5. **A verified algorithm or computational method**:
   - e.g. Sylvester constructor, normalization procedure, or certified code generator.
6. **demo.py** demonstrating the constructions interactively.

---

## Application Keywords

Hadamard conjecture, orthogonal matrices, combinatorial design, BIBD, finite geometry, Walsh-Hadamard transform, coding theory, equidistant codes, Hamming distance, tensor product, Kronecker construction, quadratic residues, finite fields, spectral methods, compressed sensing, signal processing, experimental design, arithmetic combinatorics, formal verification, Lean 4, Mathlib.

---

## Final Call to Action

Do not write a museum exhibit of classical facts. Build a **formal theory of Hadamard universes**:

- arithmetic obstructions,
- recursive and tensorial existence engines,
- equivalence and normalization machinery,
- bridges to codes, designs, and transforms,
- computational conjectures that can actually fail.

The breakthrough is not merely “formalizing Hadamard matrices.” The breakthrough is to create a verified platform where existence, structure, and applications become one theorem ecosystem.

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
