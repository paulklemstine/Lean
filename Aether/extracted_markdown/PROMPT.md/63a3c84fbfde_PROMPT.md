
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

**Title**: Close Proofs: Arithmetic Universality in Cellular Automata via p-adic Renormalizatio
**Domain**: Novelty
**Mathematical framing**: Cycle 24eec4d0 (Q=0.530) proved 963 theorems in Physics but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Conjecture: There exists a nontrivial class of one-dimensional nearest-neighbor cellular automata over finite alphabets whose space-time evolution, when encoded as local pattern-count generating funct
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Novelty/AdditiveCAPadicRenorm.lean
import Mathlib

/-!
# Arithmetic Universality in Additive Cellular Automata via p-adic Renormalization

We model a one-dimensional, nearest-neighbour **additive** cellular automaton (CA)
over the finite alphabet `ZMod p` (the field `𝔽_p`, `p` prime) as multiplication
inside the Laurent polynomial ring `(ZMod p)[T; T⁻¹]`.

A bi-infinite configuration `s : ℤ → ZMod p` of finite support is encoded as a
Laurent polynomial `∑ₓ s(x) · Tˣ`.  The local rule of the additive
nearest-neighbour CA (the `𝔽_p` analogue of Wolfram's *Rule 90*) sends a cell to
the sum of its two neighbours, i.e. it acts as multiplication by the operator

  `caOp p = T + T⁻¹`.

Time-`t` evolution is therefore multiplication by `(caOp p) ^ t`, and the entire
space-time diagram is governed by the powers of a single ring element.

The central phenomenon is **p-adic renormalization**: although the binomial
space-time diagram (Pascal's triangle mod `p`) is intricate, at time `p^k` the
operator collapses to a *pure pair of light-cone rays*

  `(caOp p) ^ (p^k) = T^(p^k) + T^(−p^k)`,

a direct consequence of the Frobenius / "freshman's dream" identity in
characteristic `p`.  This is the algebraic heart of the self-similar Sierpiński
structure of these automata and of their arithmetic universality.

## Main results
* `caEvolve_add`, `caEvolve_smul` — the CA evolution operator is `𝔽_p`-linear.
* `caOp_pow_char` — the one-step renormalization `(caOp)^p = T^p + T^(−p)`.
* `caOp_renorm` — the renormalization tower `(caOp)^(p^k) = T^(p^k) + T^(−p^k)`.
* `caOp_renorm_seed` — translation-covariant evolution of a single-cell seed:
  `(caOp)^(p^k) * Tᵃ = T^(a+p^k) + T^(a−p^k)`.
* `caOp_binomial` — the generating-function closed form
  `(caOp)^n = ∑_{k≤n} C(n,k) · T^(2k−n)` (Pascal's triangle mod `p`).

## Catalog synthesis
This file develops a self-contained algebraic theory complementary to the
project's number-theoretic `p`-adic strand (e.g. the lifting-the-exponent and
entry-point machinery in
`Catalog/Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean`,
in particular `add_pow_char`-style Frobenius arguments used there for matrices
over `ZMod p`).  Here the same Frobenius mechanism is repackaged as a
*renormalization-group* statement about cellular automata, bridging the
dynamical-systems and number-theoretic domains of the catalog.
-/

open LaurentPolynomial

noncomputable section

namespace AdditiveCA

variable (p : ℕ) [Fact p.Prime]

/-- The Laurent polynomial ring `(ZMod p)[T; T⁻¹]` is our state space:
a configuration `s : ℤ → ZMod p` of finite support corresponds to `∑ₓ s(x)·Tˣ`. -/
abbrev State (p : ℕ) := LaurentPolynomial (ZMod p)

/-- `(ZMod p)[T; T⁻¹]` inherits characteristic `p` from its field of coefficients,
since the structural map `ZMod p → (ZMod p)[T; T⁻¹]` is injective. -/
instance : CharP (State p) p :=
  charP_of_injective_algebraMap
    (FaithfulSMul.algebraMap_injective (ZMod p) (LaurentPolynomial (ZMod p))) p

/-- The additive nearest-neighbour CA operator over `𝔽_p` (the `Rule 90` analogue):
each cell becomes the sum of its two neighbours, i.e. multiplication by `T + T⁻¹`. -/
def caOp (p : ℕ) : State p := T 1 + T (-1)

-- !-- Lab Notebook -- !--
-- Hypothesis: A nearest-neighbour additive CA over 𝔽_p is "linear" in the strong
--   algebraic sense: its time evolution is multiplication by a fixed ring element,
--   hence an 𝔽_p-module endomorphism of the configuration space.
-- Result: `caEvolve_add` / `caEvolve_smul` confirm additivity and 𝔽_p-homogeneity
--   for every power (every time step) of the operator.
-- Insight: Encoding configurations as Laurent polynomials turns "superposition of
--   initial conditions" into the distributive law, so linearity is free.
-- Failure analysis: A naive `ℤ → ZMod p` pointwise model would force manual
--   convolution bookkeeping; the Laurent-polynomial encoding sidesteps it entirely.

-- !-- The CA evolution operator is additive: evolving a superposition of two
-- configurations equals the superposition of the evolutions (left-distributivity). -- !--
omit [Fact p.Prime] in
theorem caEvolve_add (t : ℕ) (s₁ s₂ : State p) :
    (caOp p) ^ t * (s₁ + s₂) = (caOp p) ^ t * s₁ + (caOp p) ^ t * s₂ :=
  mul_add _ _ _

-- !-- The CA evolution operator is 𝔽_p-homogeneous: scaling the initial
-- configuration by a constant scales the whole space-time diagram. -- !--
theorem caEvolve_smul (t : ℕ) (c : ZMod p) (s : State p) :
    (caOp p) ^ t * (c • s) = c • ((caOp p) ^ t * s) := by
  rw [mul_smul_comm]

-- !-- Lab Notebook -- !--
-- Hypothesis: At time exactly p the elaborate Pascal-mod-p diagram should collapse,
--   because (a+b)^p = a^p + b^p in characteristic p (Frobenius / freshman's dream).
-- Result: `caOp_pow_char` proves (T + T⁻¹)^p = T^p + T^(−p): a clean pair of rays.
-- Insight: This is the renormalization-group fixed point of the automaton — the
--   p-step map IS the one-step map rescaled spatially by p.  This single identity
--   is the algebraic source of Sierpiński self-similarity.
-- Failure analysis: Needed the `CharP (State p) p` instance; it is not found by
--   default and is supplied above via `charP_of_injective_algebraMap`.

-- !-- One-step p-adic renormalization: by the Frobenius identity in characteristic
-- p, the time-p evolution operator is exactly two light-cone rays T^p + T^(−p). -- !--
theorem caOp_pow_char : (caOp p) ^ p = T (p : ℤ) + T (-(p : ℤ)) := by
  unfold caOp
  rw [add_pow_char, T_pow, T_pow]
  norm_num

-- !-- Renormalization tower: iterating the Frobenius collapse, the time-p^k operator
-- is two rays at distance p^k, exhibiting exact discrete scale invariance. -- !--
theorem caOp_renorm (k : ℕ) :
    (caOp p) ^ (p ^ k) = T ((p : ℤ) ^ k) + T (-((p : ℤ) ^ k)) := by
  unfold caOp
  rw [add_pow_char_pow, T_pow, T_pow]
  norm_num

-- !-- Translation-covariant seed evolution: a single live cell at position a evolves,
-- after p^k steps, into exactly two live cells at a ± p^k (the renormalized light cone). -- !--
theorem caOp_renorm_seed (k : ℕ) (a : ℤ) :
    (caOp p) ^ (p ^ k) * T a = T (a + (p : ℤ) ^ k) + T (a - (p : ℤ) ^ k) := by
  rw [caOp_renorm, add_mul, ← T_add, ← T_add]
  congr 2 <;> ring

-- !-- Lab Notebook -- !--
-- Hypothesis: The full space-time diagram of the additive CA is governed by binomial
--   coefficients mod p (this is the precise sense in which it computes Pascal's
--   triangle / is "arithmetically universal").
-- Result: `caOp_binomial` gives the exact generating function
--   (T+T⁻¹)^n = ∑_{k≤n} C(n,k)·T^(2k−n).
-- Insight: Combined with `caOp_renorm`, this recovers Lucas-style mod-p structure:
--   the interior binomials vanish at the renormalized scales p^k, leaving only the
--   two extreme terms — exactly the rays of `caOp_renorm`.
-- Failure analysis: The ℕ-subtraction exponent (n−k) needed a guarded cast
--   `((n-k:ℕ):ℤ) = n - k` valid because k ≤ n on the summation range.

-- !-- Generating-function closed form: the time-n diagram is the n-th row of
-- Pascal's triangle mod p, placed on the even/odd sublattice via the binomial theorem. -- !--
theorem caOp_binomial (n : ℕ) :
    (caOp p) ^ n = ∑ k ∈ Finset.range (n + 1), (n.choose k) • T (2 * (k : ℤ) - n) := by
  unfold caOp
  rw [add_pow]
  apply Finset.sum_congr rfl
  intro k hk
  simp only [Finset.mem_range, Nat.lt_succ_iff] at hk
  rw [T_pow, T_pow, ← T_add, nsmul_eq_mul, mul_comm]
  congr 2
  have : ((n - k : ℕ) : ℤ) = (n : ℤ) - k := by omega
  rw [this]; ring

/-! ## Computational corollaries (concrete renormalization instances) -/

-- !-- Rule 90 over 𝔽₂: after 4 = 2² steps a single cell becomes two cells at ±4,
-- a concrete instance of the renormalization tower (Sierpiński self-similarity). -- !--
theorem rule90_scale_four : (caOp 2) ^ 4 = T (4 : ℤ) + T (-4 : ℤ) := by
  have h := caOp_renorm 2 2
  norm_num at h
  exact h

-- !-- Additive CA over 𝔽₃: after 3 steps a single cell becomes two cells at ±3. -- !--
theor
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Arithmetic Universality in Additive Cellular Automata via p-adic Renormalization

## Synthesis

This cycle established a compact algebraic engine for one-dimensional additive
cellular automata (CAs) over the finite field `𝔽_p`. The decisive move is to
encode a bi-infinite, finite-support configuration `s : ℤ → 𝔽_p` as a Laurent
polynomial `∑ₓ s(x)·Tˣ ∈ 𝔽_p[T; T⁻¹]`, so that the nearest-neighbour additive
rule (the `𝔽_p` analogue of Wolfram's Rule 90) becomes multiplication by the
single ring element `caOp = T + T⁻¹`, and time-`t` evolution becomes
`(caOp)^t`. The whole space-time diagram is thereby reduced to the powers of one
element of one ring.

Two facts then do all the work. First (`caOp_binomial`), the binomial theorem
gives the exact generating function `(caOp)^n = ∑_{k≤n} C(n,k)·T^{2k−n}`: the
time-`n` row is literally the `n`-th row of Pascal's triangle reduced mod `p`,
placed on an even/odd sublattice. Second (`caOp_pow_char`, `caOp_renorm`,
`caOp_renorm_seed`), the Frobenius / freshman's-dream identity collapses the
diagram at the renormalized times `p^k` to a clean pair of light-cone rays
`(caOp)^{p^k} = T^{p^k} + T^{−p^k}`. The interplay is exactly the discrete
renormalization group behind the Sierpiński self-similarity of these automata,
and it is the algebraic core of what we call *arithmetic universality*: the CA's
trajectory computes binomial coefficients mod `p`, and its scale-`p` coarse
graining is a fixed point.

## Results summary (file `AdditiveCAPadicRenorm.lean`, `sorry`-free)

- `caEvolve_add`, `caEvolve_smul`: the evolution operator is `𝔽_p`-linear for every time step.
- `caOp_pow_char`: `(T+T⁻¹)^p = T^p + T^{−p}` (one-step p-adic renormalization).
- `caOp_renorm`: `(T+T⁻¹)^{p^k} = T^{p^k} + T^{−p^k}` (the renormalization tower).
- `caOp_renorm_seed`: translation-covariant seed evolution `(caOp)^{p^k}·T^a = T^{a+p^k} + T^{a−p^k}`.
- `caOp_binomial`: the exact Pascal-mod-`p` generating function for every time `n`.
- `rule90_scale_four`, `ca_p3_scale_three`: concrete renormalization instances over `𝔽₂`, `𝔽₃`.

All results depend only on `propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — Exact light-cone sparsity at renormalized times (Sierpiński count)

Conjecture: for every prime `p` and every `k`, the number of nonzero cells in the
configuration `(caOp p)^t` is multiplicative in the base-`p` digits of `t`,
namely `∏_i (d_i + 1)` where `t = ∑_i d_i p^i`; in particular it equals exactly
`2` precisely when `t` is a power of `p`, and the support of `(caOp p)^{p^k}` is
exactly `{−p^k, p^k}`.

The key insight is that `caOp_binomial` reduces cell-occupancy to the
non-vanishing of `C(t,k) mod p`, which Lucas' theorem turns into a digit-wise
product — so the *combinatorial* sparsity of the space-time diagram is a purely
*arithmetic* statement about carries in base `p`. Why now? We already have the
generating function (`caOp_binomial`) and the renormalization collapse
(`caOp_renorm`) in `𝔽_p`
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
