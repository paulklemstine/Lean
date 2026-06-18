
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

**Title**: This cycle isolated the *entry point* (rank of apparition) `z(p) = ` least `k > 
**Domain**: Applications
**Mathematical framing**: # Future Directions — Fibonacci Entry Points and Carmichael's Theorem

## Synthesis

This cycle isolated the *entry point* (rank of apparition) `z(p) = ` least `k > 0`
with `p ∣ F(k)` as the single organizing object behind the catalog's scattered
Carmichael/primitive-divisor reasoning. The new file
`FibonacciEntryPoint.lean` proves, with `sorry = 0` and only the standard
axioms, a small but complete theory:

* `fibEntryPt_dvd` — `z(p) ∣ n` whenever `p ∣ F(n)` (no primality needed);
* `fib_dvd_of_fibEntryPt_dvd` — the converse, via `Nat.fib_dvd`;
* `dvd_fib_iff_fibEntryPt_dvd` — the clean equivalence `p ∣ F(n) ↔ z(p) ∣ n`;
* `primitive_iff_fibEntryPt_eq` — `p` is a primitive divisor of `F(n)` iff `z(p) = n`;
* `fib12_no_primitive` — the sharp counterexample explaining the bound `n ≥ 13`.

The deliberate gap is the *existence* of a primitive divisor for every composite
`n > 50000` (the lone genuine `sorry` left in `Shared/CarmichaelProof.lean`'s
`fib_carmichael_composite`). Everything below is a roadmap toward closing it, plus
adjacent conjectures the entry-point lens makes newly tractable.

## Results Summary

A self-contained, axiom-clean entry-point calculus now exists over Mathlib. It
recasts "primitive divisor" as the purely order-theoretic statement `z(p) = n`,
which is exactly the certificate a future LTE/growth argument must produce. The
catalog files that previously asserted these facts ad hoc (and did not build, due
to a missing `Shared.CarmichaelHelper`) can be retargeted at this reusable theory.

---

## Direction 1 — Fibonacci Lifting-the-Exponent (the keystone)

**Conjecture.** For an odd prime `p` with entry point `z(p) = m` and `p ≠ 5`,
the `p`-adic valuation satisfies `v_p(F(m·k)) = v_p(F(m)) + v_p(k)` for all
`k ≥ 1`; for `p = 5`, `v_5(F(k)) = v_5(k)`.

**The key insight is** that `F(mk)/F(m)` expands, via the companion matrix
`V = [[1,1],[1,0]]` diagonalized over `ℤ_p[√5]`, as a binomial sum whose
leading nontrivial term is `k · r^{k-1}` modulo the maximal ideal, so the
valuation is *additive* in `k` exactly like the classical `padicValNat.pow_sub_pow`
LTE for `a^n - b^n`.

**Why now?** `primitive_iff_fibEntryPt_eq` reduces "primitive divisor of `F(n)`"
to producing a prime with `z(p) = n`; LTE is the precise tool that controls how
`z(p)` propagates to multiples, so this conjecture is the missing multiplicative
half of the already-proven divisibility half.

## Direction 2 — Cyclotomic / Möbius primitive part grows past every index

**Conjecture.** Define `Φ_n := ∏_{d ∣ n} F(d)^{μ(n/d)}` (the Möbius "primitive
part"). Then `log Φ_n = φ(n) · log φ_golden + o(n)`, and for all `n > 50000`
the integer `Φ_n` has a prime factor `q` with `z(q) = n`; consequently
`fib_carmichael_composite` holds for all such `n`, closing the open `sorry`.

**The key insight is** that the only obstructions to a prime factor of `Φ_n`
being primitive are the finitely many "intrinsic" primes dividing `n` itself
(the Zsygmondy exceptions), and a counting bound `Φ_n > n · ∏_{p ∣ n} p`
forces a genuinely new prime once `φ(n) log φ_golden` dominates `log n`.

**Why now?** Direction 1 supplies the valuation identity that turns the divisor
product into a telescoping estimate; combined with Mathlib's
`Nat.fib` growth lemmas this becomes an effective inequality verifiable above an
explicit threshold, matching the computational `native_decide` range below it.

## Direction 3 — Entry points realize a uniform-distribution / density law

**Conjecture.** The set `{p prime : z(p) = n}` is nonempty for every `n ∉ {1,2,6,12}`,
and the counting function `#{p ≤ x : z(p) ∣ n}` satisfies an asymptotic of
Chebotarev type governed by the splitting of `x² - x - 1` in `ℚ(√5)`.

**The key insight is** that `z(p)` equals the multiplicative order of the golden
ratio mod `p` (when `5` is a QR) or twice the order of `-φ̄/φ` otherwise, so the
entry-point distribution is an Artin-style primitive-root problem in disguise.

**Why now?** `dvd_fib_iff_fibEntryPt_dvd` already expresses divisibility purely
through `z`, so density statements about primitive divisors translate directly
into statements about orders mod `p`, where Mathlib's `ZMod` and `orderOf` API
gives a concrete formal target.

## Direction 4 — Transfer the entry-point calculus to all Lucas sequences

**Conjecture.** For any nondegenerate Lucas sequence `U_n(P,Q)` with
`gcd(P,Q)=1`, the analogue `z_U(p)` satisfies the same three pillars proven here
(`z ∣ n` ⇔ `p ∣ U_n`, primitivity ⇔ `z = n`), and Carmichael's theorem holds
with a finite, explicitly computable exceptional set depending only on `(P,Q)`.

**The key insight is** that the proofs in `FibonacciEntryPoint.lean` used *only*
strong divisibility `U_{gcd(m,n)} = gcd(U_m,U_n)` and `m ∣ n → U_m ∣ U_n`, both
of which hold for every Lucas sequence — so the entire file generalizes with the
Fibonacci-specific lemmas swapped for their Lucas counterparts.

**Why now?** The current proofs are deliberately written against the two abstract
divisibility facts, making the generalization a refactor (introduce a typeclass
`StrongDivisibilitySequence`) rather than new mathematics.

## Direction 5 — A formal Zsygmondy theorem for `aⁿ − bⁿ`

**Conjecture.** For coprime `a > b ≥ 1`, `aⁿ − bⁿ` has a primitive prime divisor
for all `n` outside an explicit finite set, and the *same* entry-point machinery
(`z(p) =` order of `a/b` mod `p`) yields the proof, unifying Bang–Zsygmondy and
Carmichael under one Lean development.

**The key insight is** that primitive-divisor existence for `aⁿ−b⁛` and for `F(n)`
are the two faces of order theory in `(ℤ/p)^×`; the entry point is the order, and
"primitive" is "the order is exactly `n`" — verbatim our `primitive_iff_fibEntryPt_eq`.

**Why now?** Mathlib already contains `padicValNat.pow_sub_pow` (LTE for `aⁿ−bⁿ`)
and `ZMod.orderOf` theory, so the `aⁿ−bⁿ` case is *closer* to formalization than
Fibonacci — proving it first would give a template (and the missing LTE input) for
finishing Direction 2.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/StrongDivisibilityEntryPoint.lean
import Mathlib

/-! # Entry points for strong divisibility sequences: a dual/representation unifier

## Overview

The *entry point* (rank of apparition) of `p` in a sequence `a : ℕ → ℕ` is the least
`k > 0` with `p ∣ a k`.  For Fibonacci numbers this is the classical organizing object
behind Carmichael's primitive-divisor theorem (see the catalog file
`Catalog/Applications/FibonacciEntryPoints.lean`, with `entryPoint`,
`dvd_fib_iff_entry_dvd`, `primitive_iff_entry_eq`, `fib_twelve_no_primitive`).

This file isolates the **only** structural fact those proofs used — *strong
divisibility*

  `a (gcd m n) = gcd (a m) (a n)`

— and rebuilds the entire entry-point calculus over it.  The payoff is a genuine
*conceptual unification*: the very same three theorems

  * `dvd_iff_entryPoint_dvd`        : `p ∣ a n ↔ z(p) ∣ n`
  * `primitive_iff_entryPoint_eq`   : `p` is primitive for `a n` ↔ `z(p) = n`
  * `entryPoint` minimality package

now apply *verbatim* to two a-priori unrelated families:

  * **Fibonacci** `Nat.fib`            (strong divisibility = `Nat.fib_gcd`), and
  * **`b`-Mersenne / Bang–Zsygmondy** `n ↦ b^n - 1`
    (strong divisibility = `Nat.pow_sub_one_gcd_pow_sub_one`).

This is the order-theoretic *duality* advertised in the research direction: a
primitive divisor of `a n` is exactly a prime whose entry point equals `n`, i.e. a
prime whose "order" in the dual index lattice is maximal.  Fibonacci primitivity and
`b^n - 1` primitivity are then two faces of one statement about the divisor lattice
`(ℕ, ∣)` pulled back along `a`.

## Main results (`sorry`-free)

* `StrongDiv.dvd_of_index_dvd`   — `m ∣ n → a m ∣ a n` from strong divisibility alone.
* `dvd_iff_entryPoint_dvd`        — `p ∣ a n ↔ entryPoint a p ∣ n`.
* `primitive_iff_entryPoint_eq`   — primitivity ⇔ `entryPoint a p = n`.
* `fib_strongDiv`, `mersenne_strongDiv` — the two instances.
* `fib_dvd_iff_entryPoint_dvd`, `mersenne_dvd_iff_entryPoint_dvd` — specializations.

-/

/-
!-- Lab Notebook -- !--
Hypothesis: The Fibonacci entry-point theory (catalog: FibonacciEntryPoints) never
  touches Fibonacci-specific facts beyond `Nat.fib_gcd`; therefore it should lift to
  any sequence with `a (gcd m n) = gcd (a m) (a n)` (strong divisibility), unifying
  Fibonacci with the classical `b^n - 1` (Mersenne / Bang–Zsygmondy) family.
Result: Confirmed. The abstract `StrongDiv` predicate suffices to reprove the
  divisibility bridge `p ∣ a n ↔ z(p) ∣ n` and the primitivity characterization
  `IsPrimitive ↔ z(p) = n`. Both Fibonacci (`Nat.fib_gcd`) and `b^n - 1`
  (`Nat.pow_sub_one_gcd_pow_sub_one`) are instances obtained for free.
Insight: "Strong divisibility" is the *dual* incarnation of the index gcd-lattice:
  `a` is a lattice (anti)morphism `(ℕ, gcd) → (ℕ, gcd)`, and the entry point is the
  pullback of `p ∣ −` to a single generator. Primitivity = maximal order = the
  generator is hit for the first time exactly at `n`.
Failure analysis: The `b^n - 1` family genuinely needs `b ≥ 2` and `n` interaction
  only through the gcd lemma; no monotonicity or growth estimate is used here, which
  is exactly why the *existence* of primitive divisors (Carmichael/Zsygmondy) stays
  open — that requires growth, the missing multiplicative half (see FUTURE_DIRECTIONS).
-/

namespace EntryPointCalculus

/-- A `ℕ`-indexed `ℕ`-valued sequence is a **strong divisibility sequence** when the
value at a gcd of indices is the gcd of the values:
`a (gcd m n) = gcd (a m) (a n)`. -/
def StrongDiv (a : ℕ → ℕ) : Prop := ∀ m n, a (Nat.gcd m n) = Nat.gcd (a m) (a n)

variable {a : ℕ → ℕ}

/-
!-- If `m ∣ n` then `gcd m n = m`, so strong divisibility reads `a m = gcd (a m) (a n)`,
giving `a m ∣ a n`. -- !--
-/
theorem StrongDiv.dvd_of_index_dvd (h : StrongDiv a) {m n : ℕ} (hmn : m ∣ n) :
    a m ∣ a n := by
  have hg : Nat.gcd m n = m := Nat.gcd_eq_left hmn
  have hmn' := h m n
  rw [hg] at hmn'
  rw [hmn']
  exact Nat.gcd_dvd_right _ _

/-
!-- The gcd bridge: if `p` divides `a m` and `a n` then it divides `a (gcd m n)`,
because `a (gcd m n) = gcd (a m) (a n)`. -- !--
-/
theorem StrongDiv.dvd_gcd (h : StrongDiv a) {p m n : ℕ} (hm : p ∣ a m) (hn : p ∣ a n) :
    p ∣ a (Nat.gcd m n) := by
  rw [h m n]; exact Nat.dvd_gcd hm hn

open Classical in
/-- The **entry point** (rank of apparition) of `p` in the sequence `a`: the least
`k > 0` with `p ∣ a k`, or `0` if no such `k` exists. -/
noncomputable def entryPoint (a : ℕ → ℕ) (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ a k then Nat.find h else 0

/-
!-- Positivity, witness, and minimality of the entry point read directly off `Nat.find`. -- !--
-/
theorem entryPoint_pos (p : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    0 < entryPoint a p := by
  unfold entryPoint; rw [dif_pos hex]; exact (Nat.find_spec hex).1

theorem dvd_a_entryPoint (p : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    p ∣ a (entryPoint a p) := by
  unfold entryPoint; rw [dif_pos hex]; exact (Nat.find_spec hex).2

theorem entryPoint_min (p m : ℕ) (hm : 0 < m) (hlt : m < entryPoint a p) :
    ¬ p ∣ a m := by
  intro hdvd
  unfold entryPoint at hlt
  by_cases hex : ∃ k, 0 < k ∧ p ∣ a k
  · rw [dif_pos hex] at hlt
    exact Nat.find_min hex hlt ⟨hm, hdvd⟩
  · rw [dif_neg hex] at hlt; exact absurd hlt (by omega)

/-
!-- `p ∣ a n ↔ z(p) ∣ n`. (←) is `StrongDiv.dvd_of_index_dvd` from `z(p) ∣ n`.
(→) is the contrapositive: if `z(p) ∤ n` then `gcd z(p) n < z(p)` is a smaller index
at which `p` divides `a`, contradicting minimality via the gcd bridge. -- !--
-/
theorem dvd_iff_entryPoint_dvd (h : StrongDiv a) (p n : ℕ)
    (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    p ∣ a n ↔ entryPoint a p ∣ n := by
  set e := entryPoint a p with he
  have he_pos : 0 < e := entryPoint_pos p hex
  have he_div : p ∣ a e := dvd_a_entryPoint p hex
  constructor
  · intro hn
    by_contra hcon
    have h_gcd_lt_e : Nat.gcd e n < e :=
      lt_of_le_of_ne (Nat.le_of_dvd he_pos (Nat.gcd_dvd_left _ _))
        (fun hh => hcon (hh ▸ Nat.gcd_dvd_right _ _))
    exact entryPoint_min p (Nat.gcd e n) (Nat.gcd_pos_of_pos_left _ he_pos) h_gcd_lt_e
      (h.dvd_gcd he_div hn)
  · intro hdvd
    exact dvd_trans he_div (h.dvd_of_index_dvd hdvd)

/-- `p` is a **primitive divisor** of `a n`: it divides `a n` but none of `a k` for
`0 < k < n`. -/
def IsPrimitive (a : ℕ → ℕ) (p n : ℕ) : Prop :=
  p ∣ a n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ a k

/-
!-- Primitivity ⇔ `z(p) = n`. (→) `z(p) ≤ n` by minimality of `Nat.find` and `n ≥ z(p)`
since `p ∣ a n` and nothing smaller works; (←) `p ∣ a (z(p))` and minimality kill all
earlier indices.  Notably this direction needs *no* strong-divisibility assumption:
primitivity is a statement about the entry point alone. -- !--
-/
theorem primitive_iff_entryPoint_eq (p n : ℕ) (hn : 0 < n)
    (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    IsPrimitive a p n ↔ entryPoint a p = n := by
  constructor
  · intro hp
    apply le_antisymm
    · unfold entryPoint; rw [dif_pos hex]; exact Nat.find_min' hex ⟨hn, hp.1⟩
    · exact le_of_not_gt fun h' =>
        hp.2 _ (entryPoint_pos p hex) h' (dvd_a_entryPoint p hex)
  · intro hz
    refine ⟨hz ▸ dvd_a_entryPoint p hex, fun k hk₁ hk₂ => ?_⟩
    exact entryPoint_min p k hk₁ (by omega)

/-! ## Instance 1 — Fibonacci numbers -/

/-
!-- Fibonacci is a strong divisibility sequence: this is exactly `Nat.fib_gcd`. -- !--
-/
theorem fib_strongDiv : StrongDiv Nat.fib := fun m n => Nat.fib_gcd m n

/-- Fibonacci entry-point divisibility bridge, recovered from the abstract theory. -/
theorem fib_dvd_iff_entryPoint_dvd (p n : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib n ↔ entryPoint Nat.fib p ∣ n :=
  dvd_iff_entryPoint_dvd fib_strongDiv p n hex

/-- Fibonacci primitivity characterization, recovered from the abstract theory. -/
theorem fib_primitive_iff_entryPoint_eq (p n : ℕ) (hn : 0 < n)
    (hex : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    IsPrimitive Nat.fib p n ↔ entryPoint Nat.fib p = n :=
  primitive_iff_entryPoint_eq p n hn hex

/-! ## Instance 2 — `b`-Mersenne sequenc
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Entry Points as a Cross-Family Duality

## Synthesis

This cycle isolated the *entry point* (rank of apparition) `z(p) =` least `k > 0`
with `p ∣ a k` as a **structure-free** organizing object. The new file
`Catalog/Applications/StrongDivisibilityEntryPoint.lean` proves, with `sorry = 0`
and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`), that the
*entire* entry-point calculus rests on a single dual property — **strong
divisibility**

> `a (gcd m n) = gcd (a m) (a n)`   (`EntryPointCalculus.StrongDiv`)

— i.e. `a` is a lattice (anti)morphism from the index gcd-lattice `(ℕ, gcd)` to the
value gcd-lattice. Over this one hypothesis we obtain:

* `StrongDiv.dvd_of_index_dvd` — `m ∣ n → a m ∣ a n`;
* `dvd_iff_entryPoint_dvd`      — the clean bridge `p ∣ a n ↔ z(p) ∣ n`;
* `primitive_iff_entryPoint_eq` — primitivity ⇔ `z(p) = n` (needs *no* hypothesis at all);
* two instances obtained **for free**:
  * Fibonacci `Nat.fib` via `Nat.fib_gcd` (`fib_strongDiv`), and
  * the `b`-Mersenne / Bang–Zsygmondy family `n ↦ b^n − 1` via
    `Nat.pow_sub_one_gcd_pow_sub_one` (`mersenne_strongDiv`).

This realizes the duality advertised in the previous cycle's roadmap (Directions 4
and 5): Fibonacci primitive divisors and `b^n − 1` primitive divisors are now
*literally the same theorem*, `primitive_iff_entryPoint_eq`, applied to two lattice
morphisms. The catalog's scattered Carmichael reasoning
(`Catalog/Applications/FibonacciEntryPoints.lean`,
`Catalog/Shared/CarmichaelProof.lean`) can be retargeted at this reusable theory.

## Results Summary

A self-contained, axiom-clean, *family-agnostic* entry-point calculus now exists
over Mathlib. It recasts "primitive divisor of `a n`" as the order-theoretic
statement `z(p) = n`. The deliberate gap remains *existence* of a primitive divisor
for large `n` (the genuine `sorry` in `fib_carmichael_composite`'s infinite tail):
the divisibility/order *half* is now fully abstract, while the *growth* half — the
only place a specific family's size estimate enters — is what the directions below
attack.

---

## Direction 1 — A `StrongDiv` typeclass with a growth field closes Carmichael abstractly

**Conjecture.** Augment `StrongDiv a` with a single quantitative field
`hgrow : ∀ n, n * (∏ p ∈ n.primeFactors, p) < a n / (a 1)^{...}` (an effective
"the value outgrows its intrinsic divisors" bound). Then a *family-independent*
theorem yields: for every `n` outside an explicit finite exceptional set, `a n` has
a prime `p` with `z(p) = n`. Specializing the growth field to `Nat.fib`
(`Nat.fib` ~ `φ^n/√5`) closes `fib_carmichael_composite`; specializing to `b^n − 1`
reproves Bang–Zsygmondy.

**The key insight is** that `dvd_iff_entryPoint_dvd` already forces every
*non-primitive* prime factor of `a n` to have `z(p)` a *proper* divisor of `n`, so
the non-primitive part divides `∏_{d∣n, d<n} a d`; a strong-divisibility telescoping
bounds that product, and any genuine excess in `a n` must come from 
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
