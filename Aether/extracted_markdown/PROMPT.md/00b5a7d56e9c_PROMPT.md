
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
3. **RESEARCH_PAPER.tex** (NEW) — A clean, compilable LaTeX version of
   the paper that mirrors the content of RESEARCH_PAPER.md. Use standard
   amsmath/amsart or article class, define all theorems inline, and make
   it suitable for direct PDF compilation with `pdflatex`. This is the
   publishable artifact.
4. **demo.py** — Numerical examples demonstrating the key results.
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
  "research_paper_tex": "RESEARCH_PAPER.tex",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
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

**Title**: This cycle delivered `Catalog/Logic/FibonacciPrimitiveDivisorBounded.lean`, a
**Domain**: Applications
**Mathematical framing**: # FUTURE DIRECTIONS — Fibonacci Primitive Divisors / Carmichael's Theorem

This cycle delivered `Catalog/Logic/FibonacciPrimitiveDivisorBounded.lean`, a
self-contained, `sorry`-free verification of Carmichael's primitive-divisor
theorem on the range `13 ≤ n ≤ 10000`, together with:

* `fib_primitive_divisor_prime` — an *unconditional* proof for all prime indices
  `n ≥ 3` (every prime factor of `F(n)` is primitive);
* `fib_gcd_identity` — the strong-divisibility identity underpinning the theory;
* `fib_exceptional_no_primitive` — sharpness: `F(n)` has no primitive prime
  divisor for `n ∈ {1, 2, 6, 12}`, so `13` is the sharp threshold.

The genuinely open formalization target is the **unbounded composite tail**.
The conjectures below are stated so they can be transcribed almost verbatim into
Lean statements and attacked in follow-up cycles.

---

## Conjecture 1 (PRIORITY): Fibonacci Lifting-the-Exponent

For an odd prime `p` whose Fibonacci entry point is `z(p) = m` (i.e. `m` is least
with `p ∣ F(m)`), and any `k ≥ 1`:

```
padicValNat p (Nat.fib (m * k)) = padicValNat p (Nat.fib m) + padicValNat p k.
```

**Why it matters.** This is the single missing analytic ingredient for the
unbounded tail. It controls exactly how much of `F(n)` is "imprimitive", and
combined with `F(n) ≥ φ^{n-2}` it forces a primitive factor for large `n`.

**Falsifiable test.** Check numerically for `p ∈ {3,7,11,...}`, `k ≤ 20`; a single
counterexample refutes it. (None expected — this is classical, but unformalized.)

---

## Conjecture 2: Primitive part dominates the index

Define the Möbius-cyclotomic primitive part
`Φ(n) = ∏_{d ∣ n} F(d) ^ μ(n/d)` (a positive integer). Then for every
`n ≥ 13`:

```
Φ(n) > n.
```

**Why it matters.** `Φ(n) > 1` already implies a primitive prime divisor; the
strict bound `Φ(n) > n` is the clean inequality that removes the `native_decide`
range cap entirely and yields the full theorem for ALL `n ≥ 13` (prime or
composite) in one stroke.

**Falsifiable test.** `Φ(12) = 144 / (F(6)·F(4)·F(2)... )` collapses to a
non-dominant value — verify the bound first fails exactly inside `{1,2,6,12}`.

---

## Conjecture 3: Entry point divides `p − (5|p)`

For a prime `p ≠ 5`, the Fibonacci entry point `z(p)` satisfies

```
z(p) ∣ (p - legendreSym p 5),   i.e. z(p) ∣ p - 1  or  z(p) ∣ p + 1,
```

according to whether `5` is a quadratic residue mod `p`.

**Why it matters.** This gives an *a priori* upper bound `z(p) ≤ p + 1`, the key
to proving that an imprimitive prime `p ∣ F(n)` must satisfy `p ∣ n` with
multiplicity one — the combinatorial half of the tail argument.

**Falsifiable test.** Tabulate `z(p)` vs `p ± 1` for primes `p < 200`.

---

## Conjecture 4: Lucas-number analogue

The Lucas numbers `L(n)` (`L 0 = 2`, `L 1 = 1`, `L(n+2) = L(n+1)+L(n)`) have a
primitive prime divisor for every `n ∉ {1, 6}`.

**Why it matters.** Lucas and Fibonacci sequences share companion-matrix
eigenvalues; a uniform "Lucas-sequence primitive divisor" lemma would let both
theorems be derived from one abstract result, generalizing the catalog's
`FibonacciLucasBridge`.

**Falsifiable test.** `native_decide` a bounded Lucas range exactly as done here
for Fibonacci; check the exceptional set is `{1,6}`.

---

## Conjecture 5: Multiplicity-one imprimitivity

If a prime `p` divides `F(n)` but is NOT a primitive divisor of `F(n)`, and `p`
is the largest such imprimitive prime, then `p ∣ n` and

```
padicValNat p (Nat.fib n) = padicValNat p (Nat.fib (z(p))) + padicValNat p n.
```

**Why it matters.** This is the precise quantitative form of "the only new prime
factors at level `n` beyond the divisor-levels are primitive", and is the direct
corollary of Conjectures 1 + 3 needed to finish Carmichael's tail.

**Falsifiable test.** Specialize to `n` with a known repeated prime (e.g. study
`p = 2` across `n`, where `z(2) = 3`) and compare `v_2(F n)` against the formula.

Research domain: Applications
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: 8a8b0554_retry3_aristotle/Catalog/Geometry/HopfFibration/Algebra.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Algebraic Exactness Lemmas for Low-Dimensional Homotopy Computations

This file contains purely algebraic results about exact sequences that are used
to derive homotopy group computations from long exact sequences. The key result
is that in a four-term exact sequence A → B → C → D where A and D vanish,
the middle map B → C is bijective (and hence an isomorphism).

This is the algebraic engine behind the computation π₃(S²) ≅ ℤ via the Hopf
fibration: the vanishing of π₃(S¹), π₂(S¹), and π₂(S³) forces the map
π₃(S³) → π₃(S²) to be an isomorphism.
-/

import Mathlib

/-! ## Exactness-Forces-Isomorphism Lemma

The central algebraic fact: in a four-term exact sequence with vanishing ends,
the middle map is bijective.
-/

/-
In an exact sequence `A →[f] B →[g] C` where `A` is subsingleton (trivial group),
exactness implies `g` is injective. This is because exactness says `ker g = im f`,
and when `A` is trivial, `im f = {0}`, so `ker g = {0}`.
-/
theorem injective_of_exact_of_subsingleton_left
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    (f : A →+ B) (g : B →+ C)
    (hex : Function.Exact f g)
    (hA : Subsingleton A) :
    Function.Injective g := by
  intro a₁ a₂ h; have := hex ( a₁ - a₂ ) ; simp_all +decide;
  obtain ⟨ y, hy ⟩ := this; simp_all +decide [ eq_sub_iff_add_eq ];
  rw [ ← hy, Subsingleton.elim y 0, map_zero, zero_add ]

/-
In an exact sequence `B →[g] C →[h] D` where `D` is subsingleton (trivial group),
exactness implies `g` is surjective. This is because exactness says `ker h = im g`,
and when `D` is trivial, `ker h = C`, so `im g = C`.
-/
theorem surjective_of_exact_of_subsingleton_right
    {B C D : Type*} [AddCommGroup B] [AddCommGroup C] [AddCommGroup D]
    (g : B →+ C) (h : C →+ D)
    (hex : Function.Exact g h)
    (hD : Subsingleton D) :
    Function.Surjective g := by
  intro c
  by_contra hc_not_mem_range_g
  have h_contra : h c ≠ 0 := by
    exact fun h' => hc_not_mem_range_g <| hex _ |>.1 h'
  exact h_contra (by
  exact Subsingleton.elim _ _)

/-
**Exactness-Forces-Isomorphism.** In a four-term exact sequence
`A →[f] B →[g] C →[h] D` with `A` and `D` both trivial (subsingleton),
the middle map `g : B →+ C` is bijective.

This is the algebraic core of the Hopf fibration computation:
from the exact sequence `π₃(S¹) → π₃(S³) → π₃(S²) → π₂(S¹)`,
the vanishing of `π₃(S¹)` and `π₂(S¹)` gives bijectivity of `π₃(S³) → π₃(S²)`.
-/
theorem bijective_of_exact_of_vanishing_ends
    {A B C D : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C] [AddCommGroup D]
    (f : A →+ B) (g : B →+ C) (h : C →+ D)
    (hex_fg : Function.Exact f g)
    (hex_gh : Function.Exact g h)
    (hA : Subsingleton A) (hD : Subsingleton D) :
    Function.Bijective g := by
  exact ⟨ injective_of_exact_of_subsingleton_left f g hex_fg hA, surjective_of_exact_of_subsingleton_right g h hex_gh hD ⟩

/-
The main algebraic derivation: in a four-term exact sequence
`A → B → C → D` with A, D trivial and `B ≃+ ℤ`, we get `C ≃+ ℤ`.
-/
theorem equiv_int_from_exact_sequence
    {A B C D : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C] [AddCommGroup D]
    (f : A →+ B) (g : B →+ C) (h : C →+ D)
    (hex_fg : Function.Exact f g)
    (hex_gh : Function.Exact g h)
    (hA : Subsingleton A) (hD : Subsingleton D)
    (eB : Nonempty (B ≃+ ℤ)) :
    Nonempty (C ≃+ ℤ) := by
  -- By bijective_of_exact_of_vanishing_ends, we get g bijective.
  have hg_bijective : Function.Bijective g := by
    exact bijective_of_exact_of_vanishing_ends f g h hex_fg hex_gh hA hD
  exact ⟨ ( AddEquiv.ofBijective g hg_bijective ).symm.trans eB.some ⟩


-- NEW_FILE: 8a8b0554_retry3_aristotle/Catalog/Geometry/InformationGeometry/Defs.lean
/-
  Information Geometry: Core Definitions
  ======================================

  This file defines the foundational structures for information geometry
  on finite sample spaces with finite-dimensional parameter spaces.

  Key definitions:
  - `FiniteStatModel`: A parametric family of probability distributions on a finite sample space
  - `scoreVec`: The score vector (gradient of log-likelihood)
  - `fisherMatrix`: The Fisher information matrix
  - `varianceAt`, `covarianceAt`: Weighted variance and covariance
  - `ExponentialFamily`: Exponential family structure
  - `logPartition`: Log-partition (cumulant generating) function
  - `amariChentsovTensor`, `alphaChristoffel`: Alpha-connection geometry
-/

import Mathlib

open Finset BigOperators Matrix

noncomputable section

/-! ## Core Statistical Model -/

/-- A finite parametric statistical model: a family of probability mass functions
    indexed by a parameter `θ ∈ Θ`, over a finite sample space `Ω`. -/
structure FiniteStatModel (Θ Ω : Type*) [Fintype Ω] where
  /-- The log-likelihood function -/
  logLik    : Θ → Ω → ℝ
  /-- The probability mass function -/
  pmf       : Θ → Ω → ℝ
  /-- Probabilities are nonneg -/
  pmf_nonneg : ∀ θ ω, 0 ≤ pmf θ ω
  /-- Probabilities sum to 1 -/
  pmf_sum_one : ∀ θ, ∑ ω : Ω, pmf θ ω = 1
  /-- Log-likelihood is consistent with pmf where pmf is nonzero -/
  logLik_spec : ∀ θ ω, pmf θ ω ≠ 0 → logLik θ ω = Real.log (pmf θ ω)

variable {n : ℕ} {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

/-! ## Score and Fisher Information -/

/-- The Fisher information matrix: I_{ij}(θ) = 𝔼_θ[sᵢ(θ,X) sⱼ(θ,X)]
    = ∑_ω p(ω;θ) sᵢ(θ,ω) sⱼ(θ,ω).
    Here `dlogp` represents the score function (partial derivatives of log p). -/
def fisherMatrix (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ) (θ : Fin n → ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => ∑ ω : Ω, M.pmf θ ω * dlogp θ ω i * dlogp θ ω j

/-! ## Expectation, Variance, Covariance -/

/-- Expectation of a real-valued function under the model at parameter θ. -/
def expectationAt {Θ : Type*} (M : FiniteStatModel Θ Ω) (θ : Θ) (f : Ω → ℝ) : ℝ :=
  ∑ ω : Ω, M.pmf θ ω * f ω

/-- Variance of a real-valued function under the model at parameter θ. -/
def varianceAt {Θ : Type*} (M : FiniteStatModel Θ Ω) (θ : Θ) (f : Ω → ℝ) : ℝ :=
  expectationAt M θ (fun ω => (f ω - expectationAt M θ f) ^ 2)

/-- Covariance of two real-valued functions under the model at parameter θ. -/
def covarianceAt {Θ : Type*} (M : FiniteStatModel Θ Ω) (θ : Θ) (f g : Ω → ℝ) : ℝ :=
  expectationAt M θ (fun ω => (f ω - expectationAt M θ f) * (g ω - expectationAt M θ g))

/-! ## Regularity and Unbiasedness -/

/-- Regularity hypotheses for a finite statistical model with score function. -/
structure RegularityHypotheses (M : FiniteStatModel (Fin n → ℝ) Ω)
    (dlogp : (Fin n → ℝ) → Ω → Fin n → ℝ) : Prop where
  /-- All probabilities are strictly positive -/
  pmf_pos : ∀ θ ω, 0 < M.pmf θ ω
  /-- The score has mean zero: ∑_ω p(ω;θ) sᵢ(θ,ω) = 0 for all i. -/
  score_mean_zero : ∀ θ (i : Fin n), ∑ ω : Ω, M.pmf θ ω * dlogp θ ω i = 0

/-- Directional derivative of g at θ in direction v, defined via Fréchet derivative. -/
def directionalDeriv (g : (Fin n → ℝ) → ℝ) (θ v : Fin n → ℝ) : ℝ :=
  (fderiv ℝ g θ) v

/-! ## Exponential Families -/

/-- An exponential family on a finite sample space: p_θ(ω) = exp(⟨θ, T(ω)⟩ - ψ(θ) + k(ω))
    where T is the sufficient statistic, ψ is the log-partition function, and k is the
    base measure log-density. -/
structure ExponentialFamily (n : ℕ) (Ω : Type*) [Fintype Ω] where
  /-- Sufficient statistic T : Ω → ℝⁿ -/
  suffStat : Ω → Fin n → ℝ
  /-- Base measure log-density k : Ω → ℝ -/
  baseMeasure : Ω → ℝ
  /-- Normalizing condition: the partition function is finite and positive -/
  partition_pos : ∀ θ : Fin n → ℝ,
    0 < ∑ ω : Ω, Real.exp (∑ i, θ i * suffStat ω i + baseMeasure ω)

/-- The log-partition (cumulant generating) function ψ(θ) = log ∑_ω exp(⟨θ,T(ω)⟩ + k(ω)). -/
def logPartition (E : ExponentialFamily n Ω) (θ : Fin n → ℝ) : ℝ :=
  Real.log (∑ ω : Ω, Real.exp (∑ i, θ i * E.suffStat ω i + E.baseMeasure ω
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Primitive Divisors of Strong Divisibility Sequences

This cycle delivered `Catalog/Applications/StrongDivPrimitiveCertificate.lean`, which
abstracts the Fibonacci-only Carmichael primitive-divisor certificate (GCD "strip the
imprimitive part" algorithm) to **arbitrary strong divisibility sequences** `u : ℕ → ℕ`.
The soundness theorem `StrongDivSeq.primPart_sound` reduces *existence of a primitive prime
divisor of `u n`* to the single computable check `1 < primPart u n`, valid for every strong
divisibility sequence at once. It was instantiated to:

* `fib_has_primitive_divisor` — Carmichael's theorem on `13 ≤ n ≤ 2000` (one uniform
  application, no prime/composite split, since `primPart Nat.fib n > 1` throughout);
* `mersenne_two_has_primitive_divisor` — a **bounded Zsygmondy theorem for `2ⁿ − 1`** on
  `2 ≤ n ≤ 120`, `n ≠ 6`, plus the sharpness witness `mersenne_two_six_no_primitive`.

All results are `sorry`-free; the only nonstandard axioms are the `native_decide` ones
(`Lean.ofReduceBool`, `Lean.trustCompiler`) used in the bounded reflection checks.

Below are bold, testable conjectures for follow-up cycles.

## Direction 1 — Unbounded Zsygmondy for `2ⁿ − 1` via order/cyclotomic LTE
**Conjecture.** For every `n ∉ {1, 6}`, `2ⁿ − 1` has a primitive prime divisor.
**Plan.** Replace the bounded `mersenne_two_primPart_check` by an asymptotic argument:
the primitive part of `2ⁿ − 1` is governed by the cyclotomic value `Φ_n(2)`, and
`Φ_n(2) > n` for `n` large. The arithmetic core is the Lifting-the-Exponent lemma for
`aⁿ − 1` (`multiplicity`/`padicValNat` of `2ⁿ − 1` at a prime `p` with multiplicative order
`d | n` equals `v_p(2^d − 1) + v_p(n/d)`). Mathlib has `multiplicity` and
`Nat.sub_one_pow_totient`-style cyclotomic facts; the gap is `Φ_n(2) > n` for `n > N₀` plus
a finite check below `N₀`. **Falsifiable:** any `n ∉ {1,6}` with no primitive divisor refutes it.

## Direction 2 — Unbounded Carmichael (the catalog's open `sorry`)
**Conjecture.** `Catalog/Shared/CarmichaelProof.lean : fib_carmichael_composite` holds for all
`n > 10000` (the deliberately-sorried tail), completing Carmichael's 1913 theorem.
**Plan.** This is the Fibonacci instance of Direction 1's LTE program: the primitive part
`Φ_n^{F}` of `F(n)` satisfies `Φ_n^{F} ≈ φ^{ϕ(n)}` (golden ratio `φ`, Euler totient `ϕ`),
which exceeds `n` for `n` large. Bridge `primPart_sound` (now sequence-agnostic) to a *growth*
lower bound `n < primPart Nat.fib n` for `n > N₀`, eliminating the `native_decide` ceiling.
**Falsifiable:** a Fibonacci index `> 10000` with `primPart Nat.fib n = 1` refutes it.

## Direction 3 — A general Zsygmondy certificate for Lucas sequences `U_n(P,Q)`
**Conjecture.** For a nondegenerate Lucas sequence `U_n(P,Q)` with `gcd(P,Q)=1`, the abstract
certificate applies: `1 < primPart U n` certifies a primitive divisor, and the exceptional set
is finite and explicitly computable (Bilu–Hanrot–Voutier).
**Plan.** Prove `IsStrongDivSeq (U · (P,Q))` from the
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
