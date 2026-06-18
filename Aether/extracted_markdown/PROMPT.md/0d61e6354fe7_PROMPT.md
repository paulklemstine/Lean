
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

**Title**: Combinatorial species exponential generating functions as a tropical valuation profile bridge
**Domain**: Applications
**Mathematical framing**: 
Research domain: Applications
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: 14435cc3_retry3_aristotle/Catalog/Applications/SpeciesTropicalProfile.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical extremal-support profiles of finitely supported rational sequences

**The core of this file is about finitely supported sequences `f : ℕ →₀ ℚ`.**  The
species / EGF interpretation appears only at the very end as a *downstream corollary*
(`binConv_extremal_profile`), and introduces no new species abstractions.

For a finitely supported sequence `f : ℕ →₀ ℚ` we define two extremal-support indices:

* `ord f : WithTop ℕ` — the least index in `f.support` (`ord 0 = ⊤`);
* `deg f : WithBot ℕ` — the greatest index in `f.support` (`deg 0 = ⊥`).

These are the *valuation* (lowest order term) and *degree* (highest order term) of `f`
viewed as a polynomial / Laurent-style profile.  The main results say that these extremal
indices behave **tropically**:

* under addition they only satisfy inequalities (`ord_add_ge`, `deg_add_le`):
  `min (ord f) (ord g) ≤ ord (f + g)` and `deg (f + g) ≤ max (deg f) (deg g)`;
* under the ordinary finitely-supported Cauchy convolution `cconv` they add **exactly**:
  `ord (cconv f g) = ord f + ord g` and `deg (cconv f g) = deg f + deg g`.

The exact convolution laws are proved through the **unique extremal contributing pair**:
at the index `ord f + ord g` only the summand `(ord f, ord g)` survives, and it is nonzero
because `ℚ` is an integral domain; dually for `deg`.

## Main results
* `ord`, `deg`               — extremal-support indices.
* `ord_eq_of`, `deg_eq_of`   — extremal-characterisation lemmas (the workhorses).
* `ord_add_ge`, `deg_add_le` — the tropical (inequality) laws for addition.
* `cconv`                    — finitely supported Cauchy convolution.
* `cconv_apply`              — its coefficientwise formula.
* `ord_cconv`, `deg_cconv`   — exact additivity of extremal indices under convolution.
* `binConv_extremal_profile` — downstream species/EGF corollary (binomial convolution).
-/
import Mathlib
import Catalog.Applications.CombinatorialSpecies

open scoped BigOperators
open Finset

namespace SpeciesTropicalProfile

/-! ### Extremal-support indices `ord` and `deg` -/

/-- The **order / valuation** of `f`: the least index in `f.support`, with `ord 0 = ⊤`. -/
def ord (f : ℕ →₀ ℚ) : WithTop ℕ := f.support.min

/-- The **degree** of `f`: the greatest index in `f.support`, with `deg 0 = ⊥`. -/
def deg (f : ℕ →₀ ℚ) : WithBot ℕ := f.support.max

@[simp] lemma ord_zero : ord (0 : ℕ →₀ ℚ) = ⊤ := by
  convert Finset.min_empty

@[simp] lemma deg_zero : deg (0 : ℕ →₀ ℚ) = ⊥ := by
  convert Finset.max_empty

/-! #### Basic support API -/

/--
If `f n ≠ 0`, then `ord f ≤ n`.
-/
lemma ord_le_of_ne_zero {f : ℕ →₀ ℚ} {n : ℕ} (h : f n ≠ 0) : ord f ≤ (n : WithTop ℕ) := by
  exact Finset.min_le ( by aesop )

/--
If `f n ≠ 0`, then `n ≤ deg f`.
-/
lemma le_deg_of_ne_zero {f : ℕ →₀ ℚ} {n : ℕ} (h : f n ≠ 0) : (n : WithBot ℕ) ≤ deg f := by
  exact Finset.le_max ( Finsupp.mem_support_iff.mpr h )

/--
Coefficients strictly below `ord f` vanish.
-/
lemma coeff_eq_zero_of_lt_ord {f : ℕ →₀ ℚ} {n : ℕ} (h : (n : WithTop ℕ) < ord f) : f n = 0 := by
  contrapose! h;
  exact Finset.min_le ( by aesop )

/--
Coefficients strictly above `deg f` vanish.
-/
lemma coeff_eq_zero_of_deg_lt {f : ℕ →₀ ℚ} {n : ℕ} (h : deg f < (n : WithBot ℕ)) : f n = 0 := by
  exact Classical.not_not.1 fun hn => h.not_ge <| le_deg_of_ne_zero hn

/--
If `ord f = n` then the `n`-th coefficient is nonzero.
-/
lemma coeff_ne_zero_of_ord_eq {f : ℕ →₀ ℚ} {n : ℕ} (h : ord f = (n : WithTop ℕ)) : f n ≠ 0 := by
  exact Finsupp.mem_support_iff.mp ( Finset.mem_of_min h )

/--
If `deg f = n` then the `n`-th coefficient is nonzero.
-/
lemma coeff_ne_zero_of_deg_eq {f : ℕ →₀ ℚ} {n : ℕ} (h : deg f = (n : WithBot ℕ)) : f n ≠ 0 := by
  convert Finsupp.mem_support_iff.mp ( Finset.mem_of_max h ) using 1

/--
For `f ≠ 0` the order is realised by an actual index.
-/
lemma exists_ord_eq {f : ℕ →₀ ℚ} (hf : f ≠ 0) : ∃ n : ℕ, ord f = (n : WithTop ℕ) ∧ f n ≠ 0 := by
  obtain ⟨n, hn⟩ : ∃ n, f n ≠ 0 ∧ ∀ m < n, f m = 0 := by
    exact ⟨ Nat.find ( show ∃ n, f n ≠ 0 from not_forall.mp fun h => hf <| Finsupp.ext h ), Nat.find_spec ( show ∃ n, f n ≠ 0 from not_forall.mp fun h => hf <| Finsupp.ext h ), fun m mn => by aesop ⟩;
  use n; simp_all +decide [ ord ] ;
  exact le_antisymm ( Finset.min_le <| by aesop ) ( Finset.le_min fun m hm => Nat.cast_le.mpr <| le_of_not_gt fun hnm => by aesop )

/--
For `f ≠ 0` the degree is realised by an actual index.
-/
lemma exists_deg_eq {f : ℕ →₀ ℚ} (hf : f ≠ 0) : ∃ n : ℕ, deg f = (n : WithBot ℕ) ∧ f n ≠ 0 := by
  have := Finset.max_of_nonempty ( show f.support.Nonempty from Finset.nonempty_of_ne_empty ( by aesop ) );
  exact ⟨ this.choose, this.choose_spec, Finsupp.mem_support_iff.mp ( Finset.mem_of_max this.choose_spec ) ⟩

/--
**Extremal characterisation of `ord`.** A nonzero coefficient at `n` whose strictly
smaller coefficients all vanish realises the order.
-/
lemma ord_eq_of {f : ℕ →₀ ℚ} {n : ℕ} (hmem : f n ≠ 0) (hbelow : ∀ m, m < n → f m = 0) :
    ord f = (n : WithTop ℕ) := by
      refine' le_antisymm ( ord_le_of_ne_zero hmem ) _;
      exact Finset.le_min fun m hm => Nat.cast_le.mpr <| le_of_not_gt fun hnm => by aesop;

/--
**Extremal characterisation of `deg`.** A nonzero coefficient at `n` whose strictly
larger coefficients all vanish realises the degree.
-/
lemma deg_eq_of {f : ℕ →₀ ℚ} {n : ℕ} (hmem : f n ≠ 0) (habove : ∀ m, n < m → f m = 0) :
    deg f = (n : WithBot ℕ) := by
      refine' le_antisymm _ _;
      · exact Finset.max_le fun m hm => WithBot.coe_le_coe.mpr <| le_of_not_gt fun hnm => by aesop;
      · exact Finset.le_max ( by aesop )

/-! ### The tropical laws for addition -/

/--
**Tropical law for `ord` under addition.** `min (ord f) (ord g) ≤ ord (f + g)`.
-/
lemma ord_add_ge (f g : ℕ →₀ ℚ) : min (ord f) (ord g) ≤ ord (f + g) := by
  -- By definition of `ord`, we know that `ord (f + g) = (f + g).support.min`.
  unfold ord;
  simp +decide [ Finset.min ];
  grind

/--
**Tropical law for `deg` under addition.** `deg (f + g) ≤ max (deg f) (deg g)`.
-/
lemma deg_add_le (f g : ℕ →₀ ℚ) : deg (f + g) ≤ max (deg f) (deg g) := by
  unfold deg;
  simp +decide [ Finset.max ];
  grind

/-! ### Finitely supported Cauchy convolution -/

/-- Coefficient function of the Cauchy convolution. -/
def cconvFun (f g : ℕ →₀ ℚ) (n : ℕ) : ℚ := ∑ i ∈ Finset.range (n + 1), f i * g (n - i)

/--
The Cauchy convolution is supported below `(sup f.support) + (sup g.support)`.
-/
lemma cconvFun_mem_support (f g : ℕ →₀ ℚ) :
    ∀ n, cconvFun f g n ≠ 0 →
      n ∈ Finset.range (f.support.sup id + g.support.sup id + 1) := by
        intro n hn;
        contrapose! hn;
        refine Finset.sum_eq_zero fun i hi => ?_;
        simp +zetaDelta at *;
        exact Classical.or_iff_not_imp_left.2 fun h => Classical.not_not.1 fun h' => not_le_of_gt hn <| by linarith [ show f.support.sup id ≥ i from Finset.le_sup ( f := id ) <| by aesop, show g.support.sup id ≥ n - i from Finset.le_sup ( f := id ) <| by aesop, Nat.sub_add_cancel hi ] ;

/-- **Ordinary finitely supported Cauchy convolution.** Its `n`-th coefficient is the finite
sum `∑_{i=0}^{n} fᵢ · g_{n-i}` (see `cconv_apply`). -/
noncomputable def cconv (f g : ℕ →₀ ℚ) : ℕ →₀ ℚ :=
  Finsupp.onFinset (Finset.range (f.support.sup id + g.support.sup id + 1))
    (cconvFun f g) (cconvFun_mem_support f g)

/--
**Coefficient formula** for the Cauchy convolution.
-/
@[simp] lemma cconv_apply (f g : ℕ →₀ ℚ) (n : ℕ) :
    cconv f g n = ∑ i ∈ Finset.range (n + 1), f i * g (n - i) := by
  unfold cconv;
  simp +decide [ Finsupp.onFinset, cconvFun ]

/--
`cconv 0 g = 0`.
-/
@[simp] lemma cconv_zero_left (g : ℕ →₀ ℚ) : cconv 0 g = 0 := by
  convert Finsupp.ext fun n => ?_;
  simp +decide [ cconv_apply ]

/--
`cconv f 0 = 0`.
-/
@[simp] lemma cconv_zero_right (f : ℕ →₀ ℚ) : cconv f 0 = 0 := by
  ext n; simp [cconv_apply]

/-! #### The unique extremal contributing pai
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE DIRECTIONS — Species EGFs as a Tropical Valuation Profile Bridge

Follow-up conjectures generated by the cycle that produced
`Catalog/Bridges/SpeciesTropicalValuation.lean`.  That file established the dictionary

* structural product of species ↦ tropical product of valuations (`tropVal_mul`, `tropVal_card_prodSpecies`),
* disjoint sum ↦ tropical `min`-superadditivity (`tropVal_add_le`),
* valuation = minimal structure size (`Species.order_EGF_eq_nat`, `Species.one_le_order_EGF_iff`),
* differential calculus ↦ shift by `trop 1` (`Species.order_pointed`, `Species.tropVal_pointed`),
* reconstruction into an ultrametric absolute value (`specAbs_mul`, `specAbs_add_le`).

Each conjecture below is precise and testable (statable directly in Lean over `ℚ⟦X⟧` /
`CombinatorialSpecies`), ordered roughly by increasing difficulty.

---

## C1 — Sharp ultrametric equality at distinct leading orders (TESTABLE, likely provable)

The proved law `tropVal_add_le` is an *inequality*; standard nonarchimedean theory predicts
**equality whenever the two orders differ**:

> **Conjecture.** For `f g : ℚ⟦X⟧`, if `f.order ≠ g.order` then `(f + g).order = min f.order g.order`,
> equivalently `tropVal (f + g) = tropVal f + tropVal g` (tropical `+ = min`).

Consequence for species: the disjoint union of two species with distinct minimal structure
sizes has minimal size the smaller of the two. This upgrades `tropVal` to an exact tropical
semiring valuation off the "diagonal" `f.order = g.order`.

## C2 — Substitution / composition is tropically multiplicative (BOLD)

Species composition `F ∘ G` (`G` with no empty structure) has EGF the substitution
`EGF(F∘G) = (EGF F) ∘ (EGF G)`. We conjecture the valuation multiplies:

> **Conjecture.** If `g : ℚ⟦X⟧` has `1 ≤ g.order` (constant term `0`), then for every `f`,
> `(PowerSeries.subst g f).order = f.order * g.order` (with the `ℕ∞` convention `n * ⊤ = ⊤` for `n ≠ 0`).
> Hence for species, `Species.tropVal (F ∘ G) = Species.tropVal F * Species.tropVal G` in the
> tropical *power* sense — minimal structure size of a composite is the product of minimal sizes.

This would extend the bridge from the additive (`+`, `×`, `d/dX`) operators to the *plethystic*
operator, the last of Joyal's four basic constructions.

## C3 — The prime-indexed valuation profile (BOLD, cross-file)

The X-adic order is the `X`-place valuation. Each prime `p` gives another valuation
`n ↦ v_p(F.coeffSeq n)` of the *integer* counting sequence, producing a **profile**
`(v_X, (v_p)_p)` — a genuinely tropical (multi-place) object linking to
`Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_*`.

> **Conjecture.** For the species of *sets* `E` (`coeffSeq ≡ 1`) every `v_p` profile is flat `0`,
> while for the species of *cyclic orders* `C` (`coeffSeq n = (n-1)!` for `n ≥ 1`) the profile obeys
> a Legendre/Lifting-the-Exponent law `v_p((n-1)!) = (n-1 - s_p(n-1))/(p-1)` (digit-sum `s_p`).
> The X-adic place and the `p`-adic places j
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
