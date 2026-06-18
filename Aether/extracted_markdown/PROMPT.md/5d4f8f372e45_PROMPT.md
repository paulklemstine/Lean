## Assignment: **prove**

### Breakthrough Target
Prove the first fully certified infinite Paley-family theorem in Lean 4, and use it as the seed of a formally verified Hadamard/design factory. Do not treat this as “another construction.” Treat it as the moment finite field character theory, matrix certification, and combinatorial design become a single executable formal object.

The central theorem should be stated with exact quantifiers, built to minimize `sorry`, and engineered so that the finite-field character-sum lemma becomes the only genuinely delicate frontier. Everything else should be reduced to reusable matrix identities.

---

# Research Direction: Certified Paley Type I Hadamard Matrices

## Primary Theorem: Paley Type I over `ZMod p`

For every prime `p` with `p % 4 = 3`, construct a matrix
\[
H_p \in M_{p+1}(\mathbb Z)
\]
with entries in `{-1,1}` such that
\[
H_p H_p^\top = (p+1) I_{p+1}.
\]
This is the Paley Type I Hadamard matrix arising from the quadratic character on `𝔽_p`.

### Exact mathematical statement
Let `χ : ZMod p → ℤ` be the quadratic character extended by `χ 0 = 0`, `χ a = 1` if `a` is a nonzero square, `χ a = -1` otherwise. Define the Jacobsthal matrix
\[
Q_{ab} = \chi(a-b), \qquad a,b \in \mathbb F_p.
\]
Let `j` be the all-ones column vector of length `p`. Define
\[
H =
\begin{pmatrix}
1 & j^\top \\
-j & Q + I
\end{pmatrix}.
\]
Then `H` has entries in `{-1,1}` and satisfies
\[
H H^\top = (p+1)I.
\]

The key intermediate identity is:
\[
Q Q^\top = pI - J,
\]
where `J` is the all-ones matrix.

Equivalently, entrywise:
- diagonal entries: \(\sum_t \chi(t-a)^2 = p-1\),
- off-diagonal entries for `a ≠ b`: \(\sum_t \chi(t-a)\chi(t-b) = -1\).

This is the Jacobi-sum/character-correlation heart of the construction.

---

## Lean 4 formalization target

A plausible top-level theorem signature is:

```lean
theorem paley_typeI_hadamard
  (p : ℕ)
  [Fact p.Prime]
  (hp3 : p % 4 = 3) :
  ∃ H : Matrix (Fin (p + 1)) (Fin (p + 1)) ℤ,
    (∀ i j, H i j = 1 ∨ H i j = -1) ∧
    H * H.transpose = (p + 1 : ℤ) • (1 : Matrix (Fin (p + 1)) (Fin (p + 1)) ℤ)
```

A stronger and more reusable decomposition theorem is preferable:

```lean
theorem jacobsthal_gram
  (p : ℕ)
  [Fact p.Prime]
  (hp3 : p % 4 = 3) :
  let Q : Matrix (ZMod p) (ZMod p) ℤ := fun a b => quadCharInt (a - b)
  Q * Q.transpose =
    (p : ℤ) • (1 : Matrix (ZMod p) (ZMod p) ℤ) - allOnes
```

followed by

```lean
theorem paley_block_matrix_hadamard
  (p : ℕ)
  [Fact p.Prime]
  (hp3 : p % 4 = 3) :
  let H : Matrix (Fin (p + 1)) (Fin (p + 1)) ℤ := paleyTypeI p
  H * H.transpose = (p + 1 : ℤ) • (1 : Matrix (Fin (p + 1)) (Fin (p + 1)) ℤ)
```

If Mathlib’s current quadratic-character API is not exactly in this shape, define a local helper:

```lean
def quadCharInt {p : ℕ} [Fact p.Prime] : ZMod p → ℤ
```

with proofs:
- `quadCharInt 0 = 0`
- `quadCharInt x = 1 ∨ quadCharInt x = -1` for `x ≠ 0`
- multiplicativity on nonzero inputs
- `quadCharInt (-x) = - quadCharInt x` when `p % 4 = 3`.

That last antisymmetry is what forces `Qᵀ = -Q` off diagonal and gives the Paley sign pattern its rigidity.

---

## The theorem that actually opens the field

Do not stop at existence. Prove the bridge theorem that turns certified Hadamards into certified designs.

## Secondary Theorem: Hadamard → symmetric BIBD bridge

From any normalized Hadamard matrix `H` of order `4n`, extract the core incidence matrix `A` of size `(4n-1) × (4n-1)` by
\[
A_{ij} = \frac{1 - H_{i+1,j+1}}{2}.
\]
Then `A` is the incidence matrix of a symmetric BIBD with parameters
\[
(v,k,\lambda) = (4n-1,\, 2n-1,\, n-1).
\]

### Exact identities to prove
Let `v = 4n - 1`. Then:
- each row sum of `A` is `2n - 1`,
- each column sum is `2n - 1`,
- for distinct rows `r ≠ s`, their dot product is `n - 1`,
- hence
\[
A A^\top = n I_v + (n-1)J_v.
\]

This is the exact algebraic design certificate, and it transforms matrix orthogonality into finite geometry.

### Lean target
```lean
theorem hadamard_core_is_symmetric_BIBD
  (n : ℕ)
  (hn : 0 < n)
  (H : Matrix (Fin (4*n)) (Fin (4*n)) ℤ)
  (hH : isNormalizedHadamard H) :
  let A : Matrix (Fin (4*n - 1)) (Fin (4*n - 1)) ℤ := hadamardCoreIncidence H
  rowSumConst A (2*n - 1) ∧
  A * A.transpose =
    (n : ℤ) • (1 : Matrix (Fin (4*n - 1)) (Fin (4*n - 1)) ℤ) +
    ((n - 1 : ℤ) • allOnes)
```

This theorem is not a side quest. It is how a formal Hadamard library becomes a formal design-theory engine.

---

# Proof Strategy Architecture

## Strategy A: Character-correlation first, then block algebra
This is the most promising route.

### Step 1: Formalize the quadratic-character correlation
Prove
\[
\sum_{t \in \mathbb F_p} \chi(t)\chi(t+a)=
\begin{cases}
p-1 & a=0,\\
-1 & a\neq 0.
\end{cases}
\]
For `a ≠ 0`, reduce by translation/scaling to
\[
\sum_t \chi(t)\chi(t+1) = -1.
\]
This is the finite-field Jacobi sum `J(χ,χ) = -χ(-1)` specialized to `p ≡ 3 mod 4`, or directly a classical quadratic character identity.

### Step 2: Convert the sum identity into `Q * Qᵀ = pI - J`
Expand matrix multiplication entrywise:
\[
(QQ^\top)_{ab} = \sum_t \chi(a-t)\chi(b-t).
\]
Then apply the correlation theorem with shift `a-b`.

### Step 3: Verify the Paley block matrix
Use explicit block multiplication:
\[
H =
\begin{pmatrix}
1 & j^\top\\
-j & Q+I
\end{pmatrix}.
\]
Show:
- top-left block is `1 + jᵀj = p+1`,
- off-diagonal blocks vanish because row/column sums of `Q` are `0`,
- bottom-right block reduces to
  \[
  jj^\top + QQ^\top + Q + Q^\top + I.
  \]
  Since `Q + Qᵀ = 0` for `p ≡ 3 mod 4` and `QQᵀ = pI - J`, this becomes `(p+1)I`.

Why this route is strongest: it isolates all number theory into one reusable correlation lemma and lets the rest be pure matrix algebra, exactly the kind Lean can scale.

---

## Strategy B: Group-ring / convolution proof
This is conceptually deeper and may yield cleaner reusable lemmas.

### Step 1
View `χ` as an element of the group ring `ℤ[𝔽_p^+]`, and `Q` as the convolution kernel
\[
K(a,b)=\chi(a-b).
\]

### Step 2
Show the autocorrelation of `χ` is
\[
(\chi * \widetilde{\chi})(x)=
\begin{cases}
p-1 & x=0,\\
-1 & x\neq 0.
\end{cases}
\]
This is a spectral statement: the additive Fourier transform of `χ` has flat magnitude.

### Step 3
Interpret `Q` as the matrix of convolution by `χ`; then `QQᵀ` is convolution by the autocorrelation kernel, immediately giving `pI - J`.

Why this is revolutionary: it recasts Paley matrices as a finite harmonic-analysis theorem, opening a route to generalized conference matrices, difference sets, and spectral combinatorics. If manageable in Lean, this becomes a whole platform rather than a one-off proof.

---

## Strategy C: Difference-set route through skew Hadamard sets
Use the set of nonzero quadratic residues in `𝔽_p` as a skew Hadamard difference set in the additive group.

### Step 1
Formalize the residue set `D ⊂ 𝔽_p` and prove:
- `|D| = (p-1)/2`,
- `D ∩ (-D) = ∅`,
- `D ∪ (-D) = 𝔽_p \ {0}` for `p ≡ 3 mod 4`.

### Step 2
Build the ±1 incidence matrix from membership in `D`, and derive the correlation counts from difference-set multiplicities.

### Step 3
Package the resulting matrix as the Paley matrix.

This route may avoid some explicit character-sum API friction if Mathlib’s finite-set counting is currently more mature than its Jacobi-sum library.

---

# Catalog-Building Lemmas You Should Create

These are the reusable bricks that matter more than the final theorem count.

1. **Quadratic character range**
   ```lean
   theorem quadCharInt_eq_zero_or_sign ...
   theorem quadCharInt_ne_zero_iff ...
   ```

2. **Oddness at `p ≡ 3 mod 4`**
   ```lean
   theorem quadCharInt_neg
     (hp3 : p % 4 = 3) :
     quadCharInt (-x) = - quadCharInt x
   ```

3. **Row/column sum vanishing**
   ```lean
   theorem jacobsthal_row_sum_zero ...
   theorem jacobsthal_col_sum_zero ...
   ```

4. **Character correlation**
   ```lean
   theorem quadChar_correlation
     (a : ZMod p) :
     ∑ t, quadCharInt t * quadCharInt (t + a) =
       if a = 0 then (p - 1 : ℤ) else -1
   ```

5. **Skewness of Jacobsthal**
   ```lean
   theorem jacobsthal_transpose
     (hp3 : p % 4 = 3) :
     Q.transpose = -Q
   ```

6. **Block Hadamard certification**
   ```lean
   theorem paley_entries_sign ...
   theorem paley_mul_transpose ...
   ```

7. **Core extraction to BIBD**
   ```lean
   theorem hadamard_core_row_sum ...
   theorem hadamard_core_gram ...
   ```

These lemmas are the actual infrastructure the next cycle will live on.

---

# Cross-Domain Connections You Should Exploit

## 1. Finite harmonic analysis
The Paley theorem is not merely combinatorics; it is a finite analogue of flat-spectrum phenomena. The matrix `Q` is a convolution operator whose autocorrelation is a delta-plus-constant kernel. This is the discrete seed of pseudorandomness, coding, and expander-like behavior.

## 2. Additive combinatorics and difference sets
Quadratic residues here act as a difference set. Formalizing this opens the door to Singer difference sets, projective planes, and strongly regular graphs. A single successful architecture can propagate into finite geometry.

## 3. Signal processing / compressed sensing
Hadamard and Paley matrices are deterministic sensing matrices with low correlation and fast transforms. A certified family in Lean means one can reason about coherence bounds and exact recovery certificates with machine-checked foundations.

## 4. Quantum information
Hadamard-like structures encode mutually unbiased phenomena, phase patterns, and highly symmetric sign matrices. A formally certified supply of such matrices invites exact verification of small quantum protocols and combinatorial state constructions.

## 5. Statistical design and experimental planning
The Hadamard-to-BIBD bridge turns matrix orthogonality into optimal balanced designs. This is not just pure math formalization: it creates a verified pipeline from number theory to experiment design.

---

# Why this would be a breakthrough

A Lean proof of Paley Type I is not “formalizing a classical theorem.” It would certify an infinite family of Hadamard orders via nontrivial finite-field character theory, then—through the core extraction theorem—generate an infinite family of formally certified symmetric BIBDs. That is a qualitative jump from isolated matrices to a verified combinatorial universe.

This opens at least four fields at once:
- certified finite harmonic analysis,
- certified difference-set theory,
- certified design theory,
- certified deterministic sensing constructions.

And once Paley Type I is in place, Kronecker closure explodes the catalog of certified Hadamard orders immediately.

---

# Concrete subgoals in Lean

## Phase 1: Test cases
Do `p = 3` and `p = 7` explicitly.
- Build `Q`
- compute `QQᵀ`
- build `H`
- verify `HHᵀ = (p+1)I`

This de-risks the indexing and coercion story before touching the general proof.

## Phase 2: General Jacobsthal theorem
Prove `Q * Qᵀ = pI - J` over `ℤ`.

## Phase 3: General Paley block theorem
Assemble the full Hadamard proof.

## Phase 4: Core extraction theorem
Prove the BIBD bridge for any normalized Hadamard.

## Phase 5: Certified order engine
Use Sylvester + Paley Type I + existing constructions + Kronecker closure to generate certified orders up to large bounds.

---

# Application Keywords
Hadamard matrices; Paley construction; quadratic character; Legendre symbol; Jacobi sums; finite fields; `ZMod p`; difference sets; symmetric BIBD; strongly regular graphs; finite harmonic analysis; pseudorandomness; deterministic sensing matrices; combinatorial design theory; certified algebra; formal finite geometry; spectral combinatorics; block matrix identities; Lean 4; Mathlib.

---

# Required FUTURE_DIRECTIONS.md

Produce a structured `FUTURE_DIRECTIONS.md` with 3–5 falsifiable hypotheses. They must be testable and framed so the next cycle can decisively confirm or refute them.

At minimum include hypotheses of the following form:

1. **Paley Type II formalization hypothesis**  
   Conjecture: for every prime power `q ≡ 1 mod 4`, the Paley Type II construction yields a certified Hadamard matrix of order `2(q+1)` in Lean.  
   Test: formalize one non-prime case such as `q = 9` using finite fields beyond `ZMod p`.

2. **Difference-set generalization hypothesis**  
   Conjecture: the formal machinery built for quadratic residues extends to a generic theorem converting skew Hadamard difference sets into Hadamard matrices.  
   Test: instantiate on the Paley residue set and one non-Paley toy example.

3. **Strongly regular graph extraction hypothesis**  
   Conjecture: the Paley Jacobsthal matrix canonically yields a formally certified strongly regular graph package.  
   Test: derive and verify the adjacency eigenvalue relations for `p = 7, 11`.

4. **Density hypothesis for certified orders**  
   Conjecture: Sylvester + Paley I + Paley II + Kronecker closure certify a positive lower density of Hadamard orders among multiples of `4`.  
   Test: compute exact coverage up to `10^4` and `10^5` and compare against a stated numerical threshold.

5. **Finite harmonic-analysis hypothesis**  
   Conjecture: the quadratic-character correlation lemma can be abstracted to a general theorem on multiplicative characters over finite fields with constant off-origin additive autocorrelation.  
   Test: recover the quadratic case from the abstraction and identify the first obstruction for higher-order characters.

Make these hypotheses crisp enough that failure is informative. The goal is not optimism; it is scientific traction.

---

# Final mandate

Prove the Paley Type I theorem in a way that leaves behind a reusable finite-field/character-sum matrix toolkit, then prove the Hadamard-to-BIBD bridge so the result propagates into design theory. If a bottleneck appears, isolate it as a named lemma with the smallest possible interface and push everything else through. The breakthrough is not one matrix; it is a certified algebraic manufacturing process.

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
