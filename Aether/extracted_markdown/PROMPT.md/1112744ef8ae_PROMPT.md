
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Formalize the Paley construction: for any prime power q ≡ 3 (mod 4), there exist
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Hadamard Matrix Theory in Lean 4

## 1. Paley Construction and Quadratic Residues

Formalize the Paley construction: for any prime power q ≡ 3 (mod 4), there exists a Hadamard matrix of order q + 1. This requires formalizing Jacobi matrices from quadratic residue characters over finite fields and proving the resulting conference matrix satisfies the Hadamard orthogonality condition.

The key insight is that the quadratic residue character χ of GF(q) naturally produces a conference matrix C with C·Cᵀ = (q-1)I + J, and the bordered matrix [1 jᵀ; j C+I] is Hadamard of order q+1.

Why now? Mathlib already has substantial finite field theory (`ZMod`, `legendreSym`, `quadraticChar`) and the Hadamard infrastructure (definitions, tensor closure, obstruction) is fully formalized in this project. The Paley construction would be the first non-power-of-two infinite family of Hadamard orders, dramatically expanding the set of proven Hadamard orders beyond the Sylvester family.

## 2. Hadamard Maximal Determinant Bound

Prove the full Hadamard bound: for any n×n matrix M with |M_{ij}| ≤ 1, we have |det M| ≤ n^(n/2), with equality if and only if M is a (real) Hadamard matrix. We already proved det(H)² = n^n for ±1 Hadamard matrices. The converse direction — that equality in the determinant bound forces the Hadamard orthogonality condition — would complete the characterization.

The key insight is that the AM-GM inequality applied to the Gram matrix eigenvalues gives det(MMᵀ) ≤ (tr(MMᵀ)/n)^n = n^n, with equality iff all eigenvalues are equal (i.e., MMᵀ = nI).

Why now? The forward direction (det² = n^n) is already proved in `Spectral.lean`. Formalizing the bound requires Mathlib's spectral theory for Hermitian matrices and eigenvalue inequalities, which are increasingly available.

## 3. Equivalence Classification for Small Orders

Formalize the classification of Hadamard equivalence classes for small orders. For n = 1, 2, 4, 8, there is exactly one equivalence class; for n = 12, there are exactly 1 class; for n = 16, there are exactly 5 inequivalent Hadamard matrices. Prove the uniqueness results for n ≤ 12 by exhaustive case analysis on normalized forms.

The key insight is that after normalization (first row and column all 1s), the remaining (n-1)×(n-1) submatrix has very constrained structure: its rows must be orthogonal ±1 vectors that are all orthogonal to the all-ones vector, and for small n this forces a unique solution up to equivalence.

Why now? The `HadamardEquivalent` relation and `IsNormalizedHadamard` are already defined. For n = 4, the proof is a finite computation; `native_decide` or `Decidable` instances could handle it. This would be the first verified classification result in Hadamard theory.

## 4. Hadamard–BIBD Bridge Theorem

Complete the bridge between Hadamard matrices and symmetric balanced incomplete block designs. We have the counting lemmas (row-pair intersection counts). The missing piece is constructing the actual BIBD: from a normalized Hadamard matrix of order 4t, extract the incidence matrix of a symmetric 2-(4t-1, 2t-1, t-1) design and verify all BIBD axioms.

The key insight is that the ±1 → {0,1} conversion of the non-trivial rows/columns of a normalized Hadamard matrix directly yields the incidence matrix, and the Hadamard orthogonality conditions translate exactly into the BIBD pair-counting condition.

Why now? The `SymmetricBIBD` structure and the `normalized_row_pair_ones` theorem (showing the intersection count is n/4) are already formalized in `Design.lean`. The construction of the actual BIBD instance is the natural next step.

## 5. Williamson Construction and Circulant Hadamard Matrices

Formalize the Williamson construction: given four symmetric circulant ±1 matrices A, B, C, D of order n satisfying AᵀA + BᵀB + CᵀC + DᵀD = 4nI, construct a Hadamard matrix of order 4n. This construction covers many orders not reachable by Sylvester or Paley alone.

The key insight is that the block matrix [[A B C D]; [-B A -D C]; [-C D A -B]; [-D -C B A]] is Hadamard whenever the Williamson equation holds, because the block structure ensures row orthogonality via the four-square identity.

Why now? The tensor product infrastructure (Kronecker product, `hadamardOrder'_mul`) provides the algebraic foundation. Formalizing circulant matrices and the Williamson equation would open the door to verifying Hadamard existence for specific orders like 12, 20, 28, 36 — filling gaps in the construction landscape beyond powers of two.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/Hadamard/Paley.lean
/-
  # Skew Conference Matrices and the Paley Construction Core

  This file formalizes the algebraic heart of the **Paley I construction** for
  Hadamard matrices: the order-preserving passage between *skew conference
  matrices* and *skew-Hadamard matrices*.

  A skew conference matrix `C` of order `n` has zero diagonal, ±1 off-diagonal
  entries, satisfies `Cᵀ = -C`, and the conference identity `C Cᵀ = (n-1) I`.
  The Jacobsthal (quadratic residue) matrix over `GF(q)` for `q ≡ 3 (mod 4)` is
  the canonical example; this file isolates the construction step that turns such
  a `C` into a genuine Hadamard matrix `I + C`, *without* yet building the
  quadratic-residue matrix itself.

  Main results:
  * `skewConference_mulSelf`                  — `C * C = (1 - n) • I`  (algebraic core)
  * `skewConference_add_one_isSkewHadamard`   — `I + C` is skew-Hadamard
  * `skewConference_hadamardOrder`            — a skew conference matrix of order
                                                `n` yields a Hadamard order `n`
  * `isSkewHadamard_sub_one_skewConference`   — the converse: `H - I` recovers a
                                                skew conference matrix

  These extend the catalog's Hadamard development (`IsHadamard'`,
  `HadamardOrder'`, `hadamardOrder'_mul`, the Sylvester family in
  `Algebra/Hadamard/Constructions.lean`) by adding the first construction
  yielding orders that are NOT forced to be powers of two: skew conference
  matrices exist e.g. for every `n = q + 1` with `q ≡ 3 (mod 4)` prime power.

  All predicates are redefined self-containedly (matching the catalog's
  `IsHadamard'` verbatim) so the file compiles against `import Mathlib` alone,
  consistent with every other file in `Algebra/Hadamard/`.
-/
import Mathlib

open Matrix Finset BigOperators

/-! ## Core predicates (self-contained; `IsHadamardP` matches catalog `IsHadamard'`) -/

/-- A matrix is Hadamard if all entries are ±1 and `H * Hᵀ = n • I`.
    Identical to the catalog's `IsHadamard'` / `IsHadamard`. -/
def IsHadamardP {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- An order `n` admits a Hadamard matrix (matches catalog `HadamardOrder'`). -/
def HadamardOrderP (n : ℕ) : Prop :=
  ∃ H : Matrix (Fin n) (Fin n) ℤ, IsHadamardP H

/-- A **skew conference matrix** of order `n`: zero diagonal, ±1 off the
    diagonal, antisymmetric (`Cᵀ = -C`), and satisfying the conference identity
    `C Cᵀ = (n - 1) • I`. -/
def IsSkewConference {n : ℕ} (C : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i, C i i = 0) ∧
  (∀ i j, i ≠ j → C i j = 1 ∨ C i j = -1) ∧
  C.transpose = -C ∧
  C * C.transpose = ((n : ℤ) - 1) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- A **skew-Hadamard matrix**: a Hadamard matrix `H` whose "skew part" is
    trivial, i.e. `H + Hᵀ = 2 • I`. Equivalently `H - I` is antisymmetric. -/
def IsSkewHadamardP {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  IsHadamardP H ∧ H + H.transpose = (2 : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-! ## Algebraic core -/

-- !-- Lab Notebook: skewConference_mulSelf -- !--
-- !-- Hypothesis: antisymmetry + the conference identity should pin down C*C exactly -- !--
-- !-- Result: C*C = (1-n)•I, obtained by substituting Cᵀ = -C into C*Cᵀ = (n-1)•I -- !--
-- !-- Insight: this single identity is the engine; everything downstream is bookkeeping -- !--
-- !-- Failure analysis: stating it with (1-n) rather than -(n-1) avoids smul_neg friction -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: from Cᵀ = -C, C*Cᵀ = C*(-C) = -(C*C); equate with (n-1)•I and negate. -- !--
/-- The defining square of a skew conference matrix: `C * C = (1 - n) • I`. -/
theorem skewConference_mulSelf {n : ℕ} {C : Matrix (Fin n) (Fin n) ℤ}
    (hC : IsSkewConference C) :
    C * C = ((1 : ℤ) - n) • (1 : Matrix (Fin n) (Fin n) ℤ) := by
  convert congr_arg Neg.neg hC.2.2.2 using 1 <;> norm_num [ mul_neg, neg_mul ];
  rw [ hC.2.2.1, Matrix.mul_neg, neg_neg ]

/-! ## Forward construction: skew conference ⟹ skew-Hadamard -/

-- !-- Lab Notebook: skewConference_add_one_isSkewHadamard -- !--
-- !-- Hypothesis: I + C is Hadamard of the same order n (the Paley I core step) -- !--
-- !-- Result: (I+C)(I+C)ᵀ = (I+C)(I-C) = I - C*C = I + (n-1)I = nI; diagonal entries are 1 -- !--
-- !-- Insight: skewness makes the cross terms -C + C cancel, leaving only I - C*C -- !--
-- !-- Failure analysis: entries are ±1 even on the diagonal (1+0=1), so no order hypothesis is needed -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: diagonal of I+C is 1 (=1), off-diagonal is C i j (=±1); product collapses via skewConference_mulSelf. -- !--
/-- **Paley I core (forward).** If `C` is a skew conference matrix of order `n`,
    then `I + C` is a skew-Hadamard matrix of order `n`. -/
theorem skewConference_add_one_isSkewHadamard {n : ℕ}
    {C : Matrix (Fin n) (Fin n) ℤ} (hC : IsSkewConference C) :
    IsSkewHadamardP (1 + C) := by
  constructor;
  · constructor;
    · intro i j; by_cases hij : i = j <;> simp_all +decide [ IsSkewConference ] ;
    · obtain ⟨ h₁, h₂, h₃, h₄ ⟩ := hC;
      simp_all +decide [ Matrix.add_mul, Matrix.mul_add ];
      abel1;
  · simp_all +decide [ IsSkewConference, two_smul ];
    abel1

-- !-- Sketch: forgetting the skew refinement gives a plain Hadamard matrix. -- !--
/-- A skew conference matrix of order `n` yields a Hadamard matrix of order `n`. -/
theorem skewConference_isHadamard {n : ℕ}
    {C : Matrix (Fin n) (Fin n) ℤ} (hC : IsSkewConference C) :
    IsHadamardP (1 + C) :=
  (skewConference_add_one_isSkewHadamard hC).1

-- !-- Lab Notebook: skewConference_hadamardOrder -- !--
-- !-- Hypothesis: existence of a skew conference matrix forces the Hadamard order -- !--
-- !-- Result: immediate from the forward construction by exhibiting 1 + C -- !--
-- !-- Insight: this is the bridge to non-power-of-two orders (n = q+1, q ≡ 3 mod 4) -- !--
-- !-- Failure analysis: none; pure existential introduction over skewConference_isHadamard -- !--
-- !-- End Lab Notebook -- !--

/-- **Existence corollary.** If a skew conference matrix of order `n` exists,
    then `n` is a Hadamard order. -/
theorem skewConference_hadamardOrder {n : ℕ}
    (h : ∃ C : Matrix (Fin n) (Fin n) ℤ, IsSkewConference C) :
    HadamardOrderP n := by
  exact ⟨ _, skewConference_isHadamard h.choose_spec ⟩

/-! ## Converse: skew-Hadamard ⟹ skew conference -/

-- !-- Lab Notebook: isSkewHadamard_sub_one_skewConference -- !--
-- !-- Hypothesis: subtracting I from a skew-Hadamard matrix recovers a skew conference matrix -- !--
-- !-- Result: C := H - I has zero diagonal (H i i = 1), ±1 off-diagonal, Cᵀ = -C, C Cᵀ = (n-1)I -- !--
-- !-- Insight: the correspondence C ↔ H = I+C is a bijection between the two classes -- !--
-- !-- Failure analysis: H i i = 1 needs H + Hᵀ = 2I read on the diagonal, not Hadamard-ness alone -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: C Cᵀ = (H-I)(Hᵀ-I) = HHᵀ - (H+Hᵀ) + I = nI - 2I + I = (n-1)I. -- !--
/-- **Converse.** If `H` is a skew-Hadamard matrix of order `n`, then `H - I`
    is a skew conference matrix. Together with the forward direction this gives
    a bijective correspondence between skew conference and skew-Hadamard
    matrices of order `n`. -/
theorem isSkewHadamard_sub_one_skewConference {n : ℕ}
    {H : Matrix (Fin n) (Fin n) ℤ} (hH : IsSkewHadamardP H) :
    IsSkewConference (H - 1) := by
  obtain ⟨hH1, hH2⟩ := hH;
  refine' ⟨ _, _, _, _ ⟩;
  · intro i; have := congr_fun ( congr_fun hH2 i ) i; norm_num at *; linarith;
  · intro i j hij; have := hH1.1 i j; aesop;
  · exact eq_of_sub_eq_zero ( by ext i j; have := congr_fun ( congr_fun hH2 i ) j; norm_num at *; linarith );
  · simp_all +decide [ mul_sub, sub_mul ];
    rw [ hH1.2 ] ; abel_nf;
    convert congr_arg ( fun x : Matrix ( Fin n ) ( Fin n ) ℤ => -x + ( n : ℤ ) • 1 + 1 ) hH2 using 1 <;> abel_nf;
    ext i j ; norm_num ; ring;
    erw [ show ( 2 : Ma
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Skew Conference Matrices and the Paley Construction

## Synthesis

This cycle isolated and fully formalized the *order-preserving algebraic core* of
the Paley I construction for Hadamard matrices, the single most tractable slice of
the proposed "Paley construction and quadratic residues" research direction. Rather
than attempting the full quadratic-residue (Jacobsthal) matrix over `GF(q)` in one
leap — which couples finite-field character theory, antisymmetry, and a delicate
order-`q+1` bordering argument — we factored out the *purely matrix-algebraic*
statement that drives the whole construction: a **skew conference matrix** `C`
(zero diagonal, ±1 off-diagonal, `Cᵀ = -C`, `C Cᵀ = (n-1)I`) yields a genuine
Hadamard matrix `I + C` of the *same* order `n`. The proof reduces, after
substituting antisymmetry, to the one-line identity `C * C = (1-n)I`, from which the
Hadamard relation `(I+C)(I+C)ᵀ = I - C·C = nI` follows by cancellation of the cross
terms `-C + C`. This is the structural insight of the cycle: **skewness is exactly
the hypothesis that makes bordering unnecessary** — the order is preserved, not
doubled, because the antisymmetric cross terms vanish.

We also proved the converse, establishing a *bijective correspondence* `C ↦ I + C`
between skew conference matrices and skew-Hadamard matrices of order `n` (the inverse
being `H ↦ H - I`). This converse is what upgrades a one-way construction into a
genuine classification statement, and it required reading the skew condition
`H + Hᵀ = 2I` on the diagonal to force `H i i = 1` — a step that Hadamard-ness alone
does not give. The forward and converse together connect three catalog domains:
the linear-algebraic Hadamard predicate (`IsHadamard'`), the additive/antisymmetric
matrix structure, and — via the Jacobsthal example flagged below — number theory.

What did *not* close this cycle: the symmetric (Paley II) case. We discovered the
sharp boundary that `I + C` is Hadamard **iff** `C` is skew; for a *symmetric*
conference matrix `I + C` fails and one must double the order via a `2×2` block
matrix. We recorded this as the conjecture `symmetricConference_hadamardOrder_two_mul`
and as Direction 1 below — its failure mode (the cross terms no longer cancel) is
precisely what teaches us why two genuinely different Paley constructions exist.

## Results Summary

- `skewConference_mulSelf`: **proved** — the algebraic engine `C * C = (1-n)I` that every downstream result reduces to.
- `skewConference_add_one_isSkewHadamard`: **proved** — Paley I core: `I + C` is skew-Hadamard of order `n` whenever `C` is a skew conference matrix.
- `skewConference_isHadamard`: **proved** — forgetful corollary: `I + C` is a Hadamard matrix.
- `skewConference_hadamardOrder`: **proved** — existence bridge: a skew conference matrix of order `n` certifies `n` as a Hadamard order (the route to non-power-of-two orders `q+1`).
- `isSkewHadamard_sub_one_skewConference`: **proved** — converse: `H - I` recovers
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
