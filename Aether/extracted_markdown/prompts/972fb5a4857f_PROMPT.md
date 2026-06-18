
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **lean files (count chosen by the Plan)**
2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
   conjectures as a freeform narrative (NOT a form). Each direction MUST
   include a "The key insight is..." sentence and a "Why now?" justification.
   This file drives the next research cycle — make it count.

### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
- NO `ARTICLE.md`
- NO `RESEARCH_PAPER.md`
- NO `demo.py` / `algorithms.py`
- NO HTML widgets
- NO `PACKAGE.json`
- NO prose for human readers (except FUTURE_DIRECTIONS.md)

### WHY THIS NARROW:
The Lean 4 file IS the deliverable. A self-contained Lean file with
3-5 world-class theorems is worth more than 30K characters of prose
about trivial results. Focus 100% of your compute on the math.
If your work is genuinely world-class, the packaging step is dispatched
automatically and cheaply.


## Concept

**Title**: This document describes five research conjectures extending the
**Domain**: Pythagorean
**Mathematical framing**: # Future Directions: Model Theory–Algebra Bridge

This document describes five research conjectures extending the
Ax-Kochen–Morley bridge formalized in `Bridges/AxKochenMorleyBridge.lean`.

---

## 1. Full Morley Categoricity Theorem

**Conjecture.** If `L` is a countable first-order language and `T` is a
complete `L`-theory that is categorical in some uncountable cardinal
`κ ≥ ℵ₁`, then `T` is categorical in every uncountable cardinal.

The key insight is that categoricity at one uncountable cardinal forces
the theory to have no Vaughtian pairs, which in turn forces every model
to be "geometrically controlled" by a strongly minimal set. The proof
passes through the Baldwin–Lachlan characterization: a countable complete
theory is uncountably categorical iff it has no Vaughtian pairs and every
model is prime over a strongly minimal set.

**Why now?** Mathlib already has `Cardinal.Categorical`, `IsComplete`,
and `ElementarilyEquivalent`. Our bridge file proves that categoricity
implies elementary equivalence via completeness — the first link in the
Morley chain. The next step is formalizing strongly minimal sets and
Vaughtian pairs. The statement is already present (with sorry) as
`morley_categoricity_statement` in the bridge file.

---

## 2. Ax-Kochen Transfer Principle for p-adic Fields

**Conjecture.** For all but finitely many primes `p`, the p-adic field
`ℚ_p` is elementarily equivalent to the Laurent series field `𝔽_p((t))`.
More precisely, if `v₁ : ValuedField K₁` and `v₂ : ValuedField K₂` are
henselian valued fields of equicharacteristic zero with elementarily
equivalent residue fields and value groups, then `K₁` and `K₂` are
elementarily equivalent.

The key insight is that Ax-Kochen-Ershov reduces the model theory of
henselian valued fields to the model theory of their residue fields and
value groups, which are much simpler objects. For equicharacteristic zero,
the transfer is unconditional; for mixed characteristic, it holds for
all sufficiently large residue characteristics.

**Why now?** Mathlib has `HenselianLocalRing`, `ValuationSubring`, and
we proved `root_unique_of_simple` establishing the uniqueness complement
to Hensel's lemma. The valued field language needs to be defined as a
`FirstOrder.Language` extending the ring language, which is a concrete
next step given Mathlib's `FirstOrder.Language.Theory.field`.

---

## 3. Henselian Lifting for Multivariate Systems

**Conjecture.** Let `R` be a henselian local ring with maximal ideal `m`,
and let `f₁, …, fₙ ∈ R[X₁, …, Xₙ]`. If `a₀ = (a₀₁, …, a₀ₙ) ∈ Rⁿ`
satisfies `fᵢ(a₀) ∈ m` for all `i` and `det(∂fᵢ/∂Xⱼ)(a₀)` is a unit
in `R`, then there exists a unique `a ∈ Rⁿ` with `fᵢ(a) = 0` and
`a - a₀ ∈ mⁿ`.

The key insight is that the univariate case (our `root_unique_of_simple`)
extends to multivariate systems via the Newton–Raphson iteration in the
m-adic topology. The Jacobian determinant condition replaces the
derivative unit condition, and the contraction mapping principle in the
m-adic complete case gives both existence and uniqueness.

**Why now?** Our theorem `root_unique_of_simple` provides the univariate
uniqueness foundation. Mathlib has `MvPolynomial` and `Matrix.det`.
The multivariate generalization connects to deformation theory and
smooth morphisms in algebraic geometry.

---

## 4. Completeness of ACF via Categoricity

**Conjecture.** The theory ACF_p (algebraically closed fields of
characteristic p, for p = 0 or p prime) is complete. This follows from
the Łoś–Vaught test: ACF_p is categorical in every uncountable cardinal
(by the transcendence degree classification), has only infinite models,
and the language is countable.

The key insight is that our `Categorical.models_elementarilyEquivalent`
theorem, combined with Mathlib's existing `FirstOrder.Language.Theory.ACF`,
provides a direct path to proving completeness of ACF. The categoricity
of ACF in uncountable cardinals follows from the fact that algebraically
closed fields of the same characteristic and transcendence degree are
isomorphic.

**Why now?** Mathlib defines `Theory.ACF` and has extensive infrastructure
for algebraically closed fields (`IsAlgClosed`). Our bridge theorem
reduces completeness to categoricity. The missing piece is formally
establishing uncountable categoricity of ACF, which requires connecting
`IsAlgClosed` with the first-order `Theory.ACF` and proving the
transcendence degree classification.

---

## 5. Elementary Equivalence and Ultraproducts

**Conjecture.** Two structures `M` and `N` are elementarily equivalent if
and only if there exists an ultrafilter `U` on some index set `I` such
that the ultrapower `M^I/U` is isomorphic to `N^I/U`.

The key insight is that Keisler's theorem provides a semantic
characterization of elementary equivalence via ultrapowers, giving a
"geometric" proof technique for showing elementary equivalence without
checking every sentence. This is the model-theoretic analogue of the
Yoneda lemma: structures are determined by their relationship to
ultraproducts.

**Why now?** Mathlib has `Filter.Ultrafilter` and product types.
Defining ultraproducts as quotients of product structures by an
ultrafilter equivalence relation is a natural formalization target.
Combined with our bridge theorems connecting elementary equivalence
to completeness and categoricity, this would provide a complete
toolkit for model-theoretic transfer arguments.

**Concept description**: # Future Directions: Model Theory–Algebra Bridge

This document describes five research conjectures extending the
Ax-Kochen–Morley bridge formalized in `Bridges/AxKochenMorleyBridge.lean`.

---

## 1. Full Morley Categoricity Theorem

**Conjecture.** If `L` is a countable first-order language and `T` is a
complete `L`-theory that is categorical in some uncountable cardinal
`κ ≥ ℵ₁`, then `T` is categorical in every uncountable cardinal.

The key insight is that categoricity at one uncountable cardinal forces
the theory to have no Vaughtian pairs, which in turn forces every model
to be "geometrically controlled" by a strongly minimal set. The proof
passes through the Baldwin–Lachlan characterization: a countable complete
theory is uncountably categorical iff it has no Vaughtian pairs and every
model is prime over a strongly minimal set.

**Why now?** Mathlib already has `Cardinal.Categorical`, `IsComplete`,
and `ElementarilyEquivalent`. Our bridge file proves that categoricity
implies elementary equivalence via completeness — the first link in the
Morley chain. The next step is formalizing strongly minimal sets and
Vaughtian pairs. The statement is already present (with sorry) as
`morley_categoricity_statement` in the bridge file.

---

## 2. Ax-Kochen Transfer Principle for p-adic Fields

**Conjecture.** For all but finitely many primes `p`, the p-adic field
`ℚ_p` is elementarily equivalent to the Laurent series field `𝔽_p((t))`.
More precisely, if `v₁ : ValuedField K₁` and `v₂ : ValuedField K₂` are
henselian valued fields of equicharacteristic zero with elementarily
equivalent residue fields and value groups, then `K₁` and `K₂` are
elementarily equivalent.

The key insight is that Ax-Kochen-Ershov reduces the model theory of
henselian valued fields to the model theory of their residue fields and
value groups, which are much simpler objects. For equicharacteristic zero,
the transfer is unconditional; for mixed characteristic, it holds for
all sufficiently large residue characteristics.

**Why now?** Mathlib has `HenselianLocalRing`, `ValuationSubring`, and
we proved `root_unique_of_simple` establishing the uniqueness complement
to Hensel's lemma. The valued field language needs to be defined as a
`FirstOrder.Language` extending the ring language, which is a concrete
next step given Mathlib's `FirstOrder.Language.Theory.field`.

---

## 3. Henselian Lifting for Multivariate Systems

**Conjecture.** Let `R` be a henselian local ring with maximal ideal `m`,
and let `f₁, …, fₙ ∈ R[X₁, …, Xₙ]`. If `a₀ = (a₀₁, …, a₀ₙ) ∈ Rⁿ`
satisfies `fᵢ(a₀) ∈ m` for all `i` and `det(∂fᵢ/∂Xⱼ)(a₀)` is a unit
in `R`, then there exists a unique `a ∈ Rⁿ` with `fᵢ(a) = 0` and
`a - a₀ ∈ mⁿ`.

The key insight is that the univariate case (our `root_unique_of_simple`)
extends to multivariate systems via the Newton–Raphson iteration in the
m-adic topology. The Jacobian determinant condition replaces the
derivative unit condition, and the contraction mapping principle in the
m-adic complete case gives both existence and uniqueness.

**Why now?** Our theorem `root_unique_of_simple` provides the univariate
uniqueness foundation. Mathlib has `MvPolynomial` and `Matrix.det`.
The multivariate generalization connects to deformation theory and
smooth morphisms in algebraic geometry.

---

## 4. Completeness of ACF via Categoricity

**Conjecture.** The theory ACF_p (algebraically closed fields of
characteristic p, for p = 0 or p prime) is complete. This follows from
the Łoś–Vaught test: ACF_p is categorical in every uncountable cardinal
(by the transcendence degree classification), has only infinite models,
and the language is countable.

The key insight is that our `Categorical.models_elementarilyEquivalent`
theorem, combined with Mathlib's existing `FirstOrder.Language.Theory.ACF`,
provides a direct path to proving completeness of ACF. The categoricity
of ACF in uncountable cardinals follows from the fact that algebraically
closed fields of the same characteristic and transcendence degree are
isomorphic.

**Why now?** Mathlib defines `Theory.ACF` and has extensive infrastructure
for algebraically closed fields (`IsAlgClosed`). Our bridge theorem
reduces completeness to categoricity. The missing piece is formally
establishing uncountable categoricity of ACF, which requires connecting
`IsAlgClosed` with the first-order `Theory.ACF` and proving the
transcendence degree classification.

---

## 5. Elementary Equivalence and Ultraproducts

**Conjecture.** Two structures `M` and `N` are elementarily equivalent if
and only if there exists an ultrafilter `U` on some index set `I` such
that the ultrapower `M^I/U` is isomorphic to `N^I/U`.

The key insight is that Keisler's theorem provides a semantic
characterization of elementary equivalence via ultrapowers, giving a
"geometric" proof technique for showing elementary equivalence without
checking every sentence. This is the model-theoretic analogue of the
Yoneda lemma: structures are determined by their relationship to
ultraproducts.

**Why now?** Mathlib has `Filter.Ultrafilter` and product types.
Defining ultraproducts as quotients of product structures by an
ultrafilter equivalence relation is a natural formalization target.
Combined with our bridge theorems connecting elementary equivalence
to completeness and categoricity, this would provide a complete
toolkit for model-theoretic transfer arguments.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Pythagorean
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
