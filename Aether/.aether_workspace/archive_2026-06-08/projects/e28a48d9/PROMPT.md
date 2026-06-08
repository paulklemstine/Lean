## Assignment: Birch and Swinnerton-Dyer Conjecture — Formalize the Algebraic Shadow Before the Analytic Mountain

**Mode:** `prove` + `formalize`

Do not merely restate BSD. Carve out a formally robust **BSD scaffold** in Lean 4 that isolates the exact algebraic and local factors, proves unconditional finite-level identities, and prepares the analytic statement as a precise theorem interface. The goal is not to “solve BSD in Lean” in one leap; the goal is to build the first serious **machine-verifiable architecture** in which BSD can live, and to prove nontrivial theorems that make the full conjecture a finite list of remaining analytic obligations.

This is a cold start. The catalog theorems listed are not directly on BSD, so use them only opportunistically:
- `hasse_bound_implies_group_order` is relevant as a toy local-factor sanity check: it can inspire finite-field point-count interfaces and Frobenius-trace abstractions.
- `rank_apparition` may suggest arithmetic-statistical experimentation around Mordell–Weil growth.
- The remaining catalog results are structurally unrelated; do not force them. Instead, build genuine bridge theorems.

## Breakthrough Objective

Construct a formal BSD framework around the following principle:

> For an elliptic curve `E` over `ℚ`, the BSD statement decomposes into:
> 1. an algebraic rank statement,
> 2. a local Euler/Tamagawa package,
> 3. a regulator-height package,
> 4. a finite Sha package,
> 5. an analytic leading-term package at `s = 1`.

The breakthrough is to make these pieces **independently formalizable and interoperable** in Lean, with exact theorem statements and reduction lemmas. This opens a new field: **machine-checked arithmetic geometry interfaces** for conjectures of motivic type.

## Primary Theorem Targets

You should define an abstract `EllipticCurveBSDData` interface if Mathlib does not already provide the exact notions needed. Work with `E : Type*` only if forced by abstraction; otherwise prefer a concrete structure representing elliptic curves over `ℚ`.

### Target 1: Formal BSD statement as an exact equivalence schema

Define the algebraic and analytic sides separately, then state BSD as a precise proposition.

Suggested Lean-facing declarations:

```lean
-- skeletal interface; adapt to Mathlib realities
structure BSDData where
  E              : Type
  rankMW         : ℕ
  ordVanishing   : ℕ
  regulator      : ℝ
  shaOrder       : ℕ
  tamagawa       : ℕ
  torsionOrder   : ℕ
  realPeriod     : ℝ
  leadingCoeff   : ℝ

def BSDRankStatement (B : BSDData) : Prop :=
  B.rankMW = B.ordVanishing

def BSDLeadingTermStatement (B : BSDData) : Prop :=
  B.leadingCoeff =
    (B.realPeriod * B.regulator * B.shaOrder * B.tamagawa) /
      (B.torsionOrder ^ 2)

def BSDStatement (B : BSDData) : Prop :=
  BSDRankStatement B ∧ BSDLeadingTermStatement B
```

This is not yet deep mathematics, but it is the indispensable formal contract. Then prove nontrivial reduction theorems about this contract.

### Target 2: Invariance of the BSD formula under isogeny, at the level of abstract data

This is a major theorem direction because isogeny invariance is one of the deepest structural sanity checks of BSD.

**Precise theorem statement:**

> If `E` and `E'` are isogenous elliptic curves over `ℚ`, and the algebraic/local/height data are related by the standard isogeny transformation laws, then `BSDStatement E ↔ BSDStatement E'`.

Suggested Lean shape:

```lean
structure IsogenyBSDRel (B₁ B₂ : BSDData) : Prop where
  rank_eq         : B₁.rankMW = B₂.rankMW
  ord_eq          : B₁.ordVanishing = B₂.ordVanishing
  leading_eq      : B₁.leadingCoeff = B₂.leadingCoeff
  period_reg_sha_tam_torsion_eq :
    (B₁.realPeriod * B₁.regulator * B₁.shaOrder * B₁.tamagawa) /
        (B₁.torsionOrder ^ 2 : ℝ)
    =
    (B₂.realPeriod * B₂.regulator * B₂.shaOrder * B₂.tamagawa) /
        (B₂.torsionOrder ^ 2 : ℝ)

theorem bsd_isogeny_invariant
    {B₁ B₂ : BSDData}
    (h : IsogenyBSDRel B₁ B₂) :
    BSDStatement B₁ ↔ BSDStatement B₂ := by
  sorry
```

Why this matters: even before formalizing full L-functions, this theorem captures the **motivic invariance architecture** of BSD. It is a serious theorem, not a toy.

### Target 3: Rank-zero and rank-one BSD reduction theorem

Do not attempt full BSD immediately. Prove that if the analytic order of vanishing is `0` or `1`, then the full rank statement reduces to a finite verification interface. In other words, formalize the **Kolyvagin/Gross–Zagier-style reduction pattern** abstractly.

**Mathematical statement:**

> For an elliptic curve `E/ℚ`, if one assumes a theorem package:
> - nonvanishing (or simple vanishing) of `L(E,s)` at `s=1`,
> - finiteness of `Sha(E/ℚ)`,
> - nondegeneracy of the Néron–Tate height pairing in the relevant rank,
> then the rank part of BSD follows in analytic rank `0` or `1`.

Suggested Lean skeleton:

```lean
structure RankZeroOneHypotheses (B : BSDData) : Prop where
  h_ord_zero_or_one : B.ordVanishing = 0 ∨ B.ordVanishing = 1
  h_sha_finite      : 0 < B.shaOrder
  h_reg_nonneg      : 0 ≤ B.regulator
  h_period_pos      : 0 < B.realPeriod
  h_tamagawa_pos    : 0 < B.tamagawa
  h_torsion_pos     : 0 < B.torsionOrder

theorem bsd_rank_zero_one_reduction
    (B : BSDData)
    (h : RankZeroOneHypotheses B)
    (hMain : BSDLeadingTermStatement B) :
    BSDRankStatement B ∨ B.rankMW ≤ 1 := by
  sorry
```

This exact statement may need refinement, but the goal is to prove a **nontrivial reduction theorem**: in low analytic rank, positivity and leading-term data force sharp algebraic constraints. Even a weaker theorem is valuable if formally clean.

### Target 4: Local factor product positivity theorem

Formalize that the local arithmetic factors appearing in the BSD quotient are positive, so the leading-term formula has correct sign behavior whenever the regulator and period are positive.

```lean
theorem bsd_rhs_nonnegative
    (B : BSDData)
    (hreg : 0 ≤ B.regulator)
    (hΩ   : 0 ≤ B.realPeriod)
    (hSha : 0 ≤ (B.shaOrder : ℝ))
    (hc   : 0 ≤ (B.tamagawa : ℝ))
    (ht   : 0 < (B.torsionOrder : ℝ)) :
    0 ≤ (B.realPeriod * B.regulator * B.shaOrder * B.tamagawa) /
          (B.torsionOrder ^ 2 : ℝ) := by
  sorry
```

This looks elementary, but it is foundational for any later sign-sensitive leading coefficient formalization.

### Target 5: Finite-field Frobenius trace bridge theorem

Use the existing `hasse_bound_implies_group_order` as a seed. Build a theorem saying that if a local factor is encoded by `a_p`, then the cardinality of reduction modulo `p` determines the Euler factor coefficient. This creates a bridge from finite combinatorial data to global BSD ingredients.

```lean
theorem frobenius_trace_of_point_count
    (p N : ℕ) (hp : Nat.Prime p) :
    ∃ a_p : ℤ, N = p + 1 - a_p.natAbs := by
  sorry
```

This exact signature will likely need improvement, but the real target is stronger:

> define a local-good-prime package and prove uniqueness/recoverability of `a_p` from `#E(𝔽_p)`.

This is a bridge theorem from arithmetic geometry to explicit computation and experimental mathematics.

## Most Promising Proof Strategies

### Strategy A: Build an abstract BSD interface first, then prove invariance and reduction lemmas
1. Define a structure encapsulating rank, order of vanishing, regulator, Sha order, Tamagawa product, torsion order, and leading coefficient.
2. Prove algebraic lemmas about equality transfer, positivity, multiplicativity, and isogeny invariance under explicitly stated hypotheses.
3. Package BSD as a proposition over this structure, so later analytic formalization can plug in without rewriting everything.

**Why promising:** this is the best route for Lean. It isolates the currently unformalized analytic depth from the already formalizable algebraic architecture. It produces publishable infrastructure even before full BSD.

### Strategy B: Low-rank reduction via abstract positivity and dimension arguments
1. Introduce a finite-rank Mordell–Weil proxy and a regulator matrix over `Matrix (Fin n) (Fin n) ℝ`.
2. Define regulator as determinant of the Néron–Tate pairing matrix in an abstract positive-semidefinite setting.
3. Prove that in ranks `0` and `1`, nonvanishing of the leading term plus positivity of local factors constrains the algebraic rank sharply.

**Why promising:** rank `0/1` is where actual BSD evidence is strongest mathematically. Even if you cannot formalize Gross–Zagier/Kolyvagin, you can formalize the exact linear-algebraic shell their theorems would inhabit.

### Strategy C: Computational-experimental bridge through finite fields and local factors
1. Define local Euler factor data from point counts modulo good primes.
2. Prove consistency lemmas using Hasse bounds and uniqueness of the trace parameter.
3. Use this to create a verified computational front-end for experimental BSD numerics.

**Why promising:** this creates immediate executable mathematics in Lean and Python, and it cross-links with the existing finite-field catalog theorem. It is the best path to testable hypotheses in `FUTURE_DIRECTIONS.md`.

## Cross-Domain Connections You Must Exploit

### 1. Linear algebra / spectral theory
The regulator is a determinant of a Gram matrix from the Néron–Tate height pairing. Treat BSD partly as a **spectral theorem problem**:
- positivity,
- nondegeneracy,
- determinant control,
- rank detection.

This opens connections to formalized matrix analysis and certified numerical linear algebra.

### 2. Analytic number theory / asymptotic analysis
The order of vanishing at `s=1` is an asymptotic invariant. Even if the full L-function is not yet in Mathlib, define a generic notion:
- `ordAtOne : (ℂ → ℂ) → ℕ`
- leading coefficient extraction
- equivalence under multiplication by nonvanishing analytic functions.

This turns BSD into a theorem schema in analytic geometry.

### 3. Computational arithmetic geometry
Local point counts over `𝔽_p` determine Euler factors. This is where the theorem `hasse_bound_implies_group_order` can inspire interfaces. Build a verified path from finite field data to candidate L-series coefficients.

### 4. Information theory / complexity
A revolutionary angle: view the Euler factors as compressed local summaries of global arithmetic complexity. Formulate testable hypotheses about whether low-height generators correlate with low-complexity local trace patterns. This is speculative but scientifically fertile and ideal for `FUTURE_DIRECTIONS.md`.

### 5. Physics-style renormalization viewpoint
The BSD quotient is a product of local corrections times a global geometric invariant. Treat Tamagawa numbers as local defect terms and the regulator as a global energy determinant. This perspective may suggest multiplicative factorization theorems and formal interfaces akin to partition functions.

## Concrete Lean 4 Type Signatures to Aim For

These should be treated as targets, not rigid requirements.

```lean
structure BSDData where
  rankMW       : ℕ
  ordVanishing : ℕ
  regulator    : ℝ
  shaOrder     : ℕ
  tamagawa     : ℕ
  torsionOrder : ℕ
  realPeriod   : ℝ
  leadingCoeff : ℝ

def BSDRankStatement (B : BSDData) : Prop :=
  B.rankMW = B.ordVanishing

def BSDLeadingTermStatement (B : BSDData) : Prop :=
  B.leadingCoeff =
    (B.realPeriod * B.regulator * B.shaOrder * B.tamagawa) /
      (B.torsionOrder ^ 2)

def BSDStatement (B : BSDData) : Prop :=
  BSDRankStatement B ∧ BSDLeadingTermStatement B

theorem bsd_isogeny_invariant
    {B₁ B₂ : BSDData}
    (h : IsogenyBSDRel B₁ B₂) :
    BSDStatement B₁ ↔ BSDStatement B₂ := by
  sorry

theorem bsd_rhs_nonnegative
    (B : BSDData)
    (hreg : 0 ≤ B.regulator)
    (hΩ : 0 ≤ B.realPeriod)
    (hSha : 0 ≤ (B.shaOrder : ℝ))
    (hc : 0 ≤ (B.tamagawa : ℝ))
    (ht : 0 < (B.torsionOrder : ℝ)) :
    0 ≤ (B.realPeriod * B.regulator * B.shaOrder * B.tamagawa) /
      (B.torsionOrder ^ 2 : ℝ) := by
  sorry

structure LocalEulerData where
  p          : ℕ
  ap         : ℤ
  pointCount : ℕ

def goodEulerConsistency (L : LocalEulerData) : Prop :=
  L.pointCount = L.p + 1 - Int.toNat L.ap

theorem local_trace_determined_by_point_count
    (L₁ L₂ : LocalEulerData)
    (h₁ : goodEulerConsistency L₁)
    (h₂ : goodEulerConsistency L₂)
    (hp : L₁.p = L₂.p)
    (hN : L₁.pointCount = L₂.pointCount) :
    L₁.ap = L₂.ap := by
  sorry
```

If Mathlib’s elliptic curve API is insufficient, define a minimal layer with explicit acknowledgement of abstraction gaps. That itself is valuable.

## What Would Count as a Genuine Breakthrough Here

Not “formalize a definition of BSD.” That is too small.

A genuine breakthrough would be one of the following:
1. **A machine-checked isogeny-invariance theorem for abstract BSD data.**
2. **A formal low-rank reduction theorem that isolates exactly what deep analytic input remains.**
3. **A verified local-to-global coefficient pipeline from finite-field point counts to BSD-compatible Euler data.**
4. **A regulator formalization using positive semidefinite Gram determinants, reusable across arithmetic geometry.**

Any of these would be field-opening because they convert a legendary conjecture into a modular formal research program rather than an untouchable monolith.

## Implementation Discipline

- Prefer small composable lemmas over one giant theorem.
- Minimize `sorry` by first proving algebraic positivity, determinant, and equivalence-transfer results.
- Use concrete types whenever possible: `ℕ`, `ℤ`, `ℝ`, `Matrix`, `Fin n`, `Finset`.
- If direct formalization of elliptic curves over `ℚ` is blocked, work abstractly but name every missing analytic/arithmetic axiom explicitly.
- Separate:
  - `Definitions.lean`
  - `LocalFactors.lean`
  - `Regulator.lean`
  - `BSDStatement.lean`
  - `IsogenyInvariant.lean`
  - `Experiments/` for computational validation

## Application Keywords

Birch–Swinnerton-Dyer, elliptic curves, arithmetic geometry, L-functions, Mordell–Weil rank, regulator, Tate–Shafarevich group, Tamagawa numbers, isogeny invariance, formal verification, Lean 4, Mathlib, spectral Gram determinants, finite-field point counts, local-to-global principles, analytic rank, certified arithmetic computation

## Required Deliverables

1. Lean files proving the strongest unconditional theorems above.
2. Definitions for all BSD factors with explicit abstraction boundaries.
3. At least one bridge theorem connecting finite-field point counts to local Euler data.
4. A `FUTURE_DIRECTIONS.md` with **3–5 testable scientific hypotheses**, each a falsifiable conjecture with a clear computational or formal test.

## Mandatory FUTURE_DIRECTIONS.md Content

Include entries of the following form:

### [Direction Title]
**Conjecture.** Precise falsifiable statement.  
**Test.** Exact Lean/computational experiment that could confirm or refute it.  
**Why it matters.** How it advances the BSD formalization program.

You must include at least:
1. one hypothesis about low-rank curves,
2. one about local Euler factors from point-count data,
3. one about regulator positivity/nondegeneracy,
4. one cross-domain hypothesis linking arithmetic complexity to another domain.

Be bold. The aim is to create the first serious formal **BSD operating system** in Lean.

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
