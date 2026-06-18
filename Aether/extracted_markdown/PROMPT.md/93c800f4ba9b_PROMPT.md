
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

**Title**: Korselt's Criterion Completion and Multiplicative Group Order Bridge to Cryptographic Pseudoprimality
**Domain**: Shared
**Mathematical framing**: 
Research domain: Shared
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: 4e6dc59b_retry3_aristotle/Catalog/Algebra/KorseltUnitsBridge.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# An arithmetic bridge toward Korselt's criterion

This file isolates one precise arithmetic step that occurs in the proof of
Korselt's criterion: if every unit modulo `n` is killed by the exponent
`n - 1`, then for each prime divisor `p` of `n` we have `(p - 1) ∣ (n - 1)`.

The argument is purely group-theoretic once the right reduction map is in place:

* `orderOf_dvd_of_forall_pow_eq_one` — a uniform `pow = 1` hypothesis bounds
  every order by `m`.
* `orderOf_map_dvd_of_surjective` — a monoid hom never increases orders.
* The reduction map `(ZMod n)ˣ →* (ZMod p)ˣ` (`ZMod.unitsMap`) is surjective.
* `(ZMod p)ˣ` is cyclic of order `p - 1`, so it contains an element of order
  exactly `p - 1`; that order divides `n - 1`.

These combine in `prime_sub_one_dvd_of_forall_units_pow_eq_one`.
-/
import Mathlib

namespace KorseltUnitsBridge

/-- If `g ^ m = 1` for every `g` in a monoid, then `orderOf g ∣ m` for every `g`.
No finiteness assumption is needed. -/
theorem orderOf_dvd_of_forall_pow_eq_one {G : Type*} [Monoid G]
    (m : ℕ) (h : ∀ g : G, g ^ m = 1) (g : G) : orderOf g ∣ m :=
  orderOf_dvd_of_pow_eq_one (h g)

/-- A group homomorphism never increases the order of an element:
`orderOf (φ g) ∣ orderOf g`.

The surjectivity hypothesis `hφ` is part of the intended interface (it is used at
the call site to transport the `pow = 1` hypothesis), but it is not needed for
this particular inequality. -/
theorem orderOf_map_dvd_of_surjective {G H : Type*} [Group G] [Group H]
    (φ : G →* H) (_hφ : Function.Surjective φ) (g : G) :
    orderOf (φ g) ∣ orderOf g := by
  apply orderOf_dvd_of_pow_eq_one
  rw [← map_pow, pow_orderOf_eq_one, map_one]

/-- **The arithmetic bridge toward Korselt's criterion.**

Let `n` be squarefree, `p` a prime divisor of `n`, and suppose every unit modulo
`n` satisfies `u ^ (n - 1) = 1`. Then `(p - 1) ∣ (n - 1)`.

(Squarefreeness is used only to guarantee `n ≠ 0`, i.e. `NeZero n`.) -/
theorem prime_sub_one_dvd_of_forall_units_pow_eq_one
    {n p : ℕ} (hn : Squarefree n) (hp : p.Prime) (hpn : p ∣ n)
    (h : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) : (p - 1) ∣ (n - 1) := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero n := ⟨hn.ne_zero⟩
  -- The reduction map on units `(ZMod n)ˣ →* (ZMod p)ˣ`, which is surjective.
  set f := ZMod.unitsMap (n := p) (m := n) hpn
  have hsurj : Function.Surjective f := ZMod.unitsMap_surjective hpn
  -- Every unit modulo `p` is killed by `n - 1`, by lifting along `f`.
  have hpow : ∀ v : (ZMod p)ˣ, v ^ (n - 1) = 1 := by
    intro v
    obtain ⟨u, rfl⟩ := hsurj v
    rw [← map_pow, h u, map_one]
  -- `(ZMod p)ˣ` is cyclic of order `p - 1`, so it has an element of order `p - 1`.
  obtain ⟨g, hg⟩ := IsCyclic.exists_ofOrder_eq_natCard (α := (ZMod p)ˣ)
  have hord : orderOf g = p - 1 := by
    rw [hg, Nat.card_eq_fintype_card, ZMod.card_units p]
  -- That order divides `n - 1`.
  rw [← hord]
  exact orderOf_dvd_of_pow_eq_one (hpow g)

end KorseltUnitsBridge
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Korselt's Criterion & the Multiplicative-Order Bridge

Derived from the v16b research cycle that produced
`Catalog/Shared/KorseltCriterion.lean` and
`Catalog/Cryptography/KorseltGroupActionBridge.lean`.

This cycle proved, unconditionally, the *constructive* direction of Korselt's
criterion (squarefree + `(p-1) ∣ (n-1)` ⇒ absolute Fermat pseudoprime) and lifted
its conclusion to an order-divisibility condition on `(ℤ/nℤ)ˣ`, then bridged it into
the `CryptoGroupAction` framework. The cycle's analysis (the converse is "true but
harder"; `n-1` is not special to the proof; freeness recovers the order condition)
suggests the following falsifiable conjectures.

## C1 — Korselt's criterion is an iff (the hard converse)

**Conjecture.** If `n > 1` is composite and `a^(n-1) ≡ 1 [MOD n]` for every `a`
coprime to `n` (i.e. `IsFermatPsp n`), then `IsKorselt n`: `n` is squarefree and
`(p-1) ∣ (n-1)` for every prime `p ∣ n`.

**The key insight is** that the converse is forced by the *existence of a primitive
root mod each prime power factor*: if `p^2 ∣ n`, a generator of `(ℤ/p^2ℤ)ˣ` has order
`p(p-1) ∤ n-1`, contradicting the pseudoprime property; and a primitive root mod `p`
shows `(p-1) ∣ n-1`. Formalizing this needs only `ZMod.instIsCyclicUnits` (cyclicity
of `(ℤ/p^kℤ)ˣ` for odd `p`) plus a CRT splitting, both available in Mathlib.

**Why now?** The forward direction and the CRT reassembly lemma
(`dvd_of_squarefree_forall_prime_dvd`) are already proved in this cycle; the converse
reuses the same decomposition machinery in reverse, so the marginal cost is a single
cyclic-group lemma rather than a new theory.

## C2 — Generalized Korselt with an arbitrary exponent

**Conjecture.** For squarefree `n` and any `e ≥ 1`, `a^e ≡ 1 [MOD n]` for all `a`
coprime to `n` **iff** `(p-1) ∣ e` for every prime `p ∣ n`. The classical Korselt
criterion is the case `e = n-1`.

**The key insight is** that the value `n-1` plays *no role* in the forward proof:
`pow_modEq_one_of_prime_factor` only consumes `(p-1) ∣ e`. The exponent `n-1` is a
historical artifact of the Fermat test, not a mathematical necessity — so the true
invariant is the universal exponent `λ(n) = lcm{p-1}` (Carmichael's lambda).

**Why now?** `korselt_imp_fermatPsp` is already parametric in the divisibility
hypothesis; abstracting `n-1` to a free `e` is a direct generalization that
immediately connects to `Nat.Carmichael`-style universal-exponent results.

## C3 — Order spectrum collapse is detectable by a single random base

**Conjecture.** For a Korselt number `n` with `k` distinct prime factors, the
fraction of bases `a ∈ (ℤ/nℤ)ˣ` whose order is a *proper* divisor of `n-1` is at
least `1 - 2^{-(k-1)}`; hence a single uniformly random Fermat–Miller–Rabin witness
already exposes the order collapse with probability bounded away from `0`.

**The key insight is** that `korselt_orderOf_dvd` says *every* unit has order dividing
`n-1`, so the Miller–Rabin refinement detects compositeness preci
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
