
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

**Title**: Close Proofs: The Boltzmann Bridge arc has, over several cycles, reduced the entire 
**Domain**: Combinatorics
**Mathematical framing**: Cycle 47be570a (Q=0.579) proved 52 theorems in Novelty but left 5 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — Boltzmann Bridge IX: Persistence as a Geodesic Path Space

## Synthesis

The Boltzmann Bridge arc has, over several cycles, reduced the entire metric theory
of persistence stabil
Research domain: Combinatorics
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/ApparitionOrderBridge.lean
import Mathlib
import Bridges.StrongDivisibilitySequences

/-! # The Apparition–Order Bridge: a local-to-global / duality dictionary

Domain: Bridges / Conceptual unification (number theory ↔ representation theory).

This file is the **stalk-level** companion to `Catalog/Bridges/StrongDivisibilitySequences.lean`.
That file develops, over an arbitrary `StrongDivSeq`, the *global* apparition theory:
the **entry point** `entryPoint p` (the rank of apparition, `Nat.find` over **all** indices
`k > 0` with `p ∣ s k`) and the law of apparition `dvd_iff_entryPoint_dvd`
(`p ∣ s n ↔ entryPoint p ∣ n`).

Here we add the **duality / representation** layer for the Mersenne family `a(n) = bⁿ − 1`.
The global, order-theoretic invariant `entryPoint` of a prime `p` is *represented* as a single
**stalk computation in the residue field** `ZMod p`:

> `mersenne_entryPoint_eq_orderOf : entryPoint (mersenneSDS b) p = orderOf (b : ZMod p)`  (p ∤ b).

This is the local-to-global program in miniature.  The "support sheaf" `n ↦ {p : p ∣ a n}`
over the additive index semigroup `(ℕ, +)` is, at each prime stalk, completely determined by
the multiplicative order of `b` in `(ZMod p)ˣ`.  Two consequences fall out:

* `support_eq_multiples` — the apparition support is the principal arithmetic progression
  generated by the entry point (the global sections of the support sheaf);
* `mersenne_entryPoint_dvd_sub_one` — Fermat descent: the entry point divides `p − 1`,
  hence the smallest local period is bounded by the size of the unit group.

The Fibonacci specialization `fib_support_eq_multiples` ties the gluing statement back to the
catalog's Fibonacci–Carmichael primitive-divisor program
(`Shared.CarmichaelProof`, `Shared.FibonacciApparitionSheaf`).

-- !-- Lab Notebook -- !--
Hypothesis: the global arithmetic invariant `entryPoint` of `bⁿ − 1` at a prime `p` is a
  shadow of a purely local group-order computation in the residue field `ZMod p`.
Result: confirmed.  `entryPoint (mersenneSDS b) p = orderOf (b : ZMod p)` for `p ∤ b`, with
  `entryPoint ∣ p − 1` as a free corollary of Fermat's little theorem, and the support of the
  apparition sheaf is exactly the principal progression of multiples of `entryPoint`.
Insight: the dictionary is `dvd_iff_entryPoint_dvd` (global) ∘ `orderOf_dvd_iff_pow_eq_one`
  (local), glued by the natural-cast reduction `p ∣ bⁿ − 1 ↔ (b : ZMod p)ⁿ = 1`.  Two divisors
  that have identical multiples-sets are equal, which pins `entryPoint = orderOf`.
Failure analysis: the cast reduction needs `1 ≤ b` (so that `bⁿ − 1` is a genuine subtraction
  in ℕ); `p ∤ b` already forces `b ≠ 0` since `p ∣ 0`, so no extra hypothesis is required.
-/

namespace ApparitionOrderBridge

open StrongDivSeq

/-! ## §1. The support sheaf: global sections are a principal progression -/

/-
**Global sections of the apparition support sheaf.**  For a strong divisibility sequence,
the set of indices at which `p` divides `s` is exactly the principal arithmetic progression
generated by the entry point.  This is the global-section description that
`dvd_iff_entryPoint_dvd` packages pointwise.

!-- Pointwise this is exactly `StrongDivSeq.dvd_iff_entryPoint_dvd`; `Set.ext` repackages it
as the equality of the support set with the multiples of `entryPoint p`. -- !--
-/
theorem support_eq_multiples (s : StrongDivSeq) {p : ℕ}
    (hex : ∃ k, 0 < k ∧ p ∣ s.a k) :
    {n | p ∣ s.a n} = {n | s.entryPoint p ∣ n} := by
  exact Set.ext fun n => StrongDivSeq.dvd_iff_entryPoint_dvd s hex n

/-! ## §2. The stalk reduction: divisibility in ℕ becomes a power identity in `ZMod p` -/

/-
**Stalk reduction.**  Dividing `bⁿ − 1` by `p` is the same as the power `(b : ZMod p)ⁿ`
being the identity.  This is the natural-cast dictionary between the integer side and the
residue-field side.

!-- `Nat.cast_sub` (valid since `1 ≤ bⁿ`) turns `↑(bⁿ − 1) = 0` into `(b:ZMod p)ⁿ - 1 = 0`,
then `ZMod.natCast_zmod_eq_zero_iff_dvd` and `sub_eq_zero` finish. -- !--
-/
theorem pow_sub_one_dvd_iff_pow_eq_one {b : ℕ} (hb : 1 ≤ b) (p n : ℕ) [NeZero p] :
    p ∣ b ^ n - 1 ↔ (b : ZMod p) ^ n = 1 := by
  rw [ ← ZMod.natCast_eq_zero_iff, Nat.cast_sub ] <;> norm_num;
  · rw [ sub_eq_zero ];
  · exact Nat.one_le_pow _ _ hb

/-! ## §3. The Apparition–Order Bridge -/

/-
**The Apparition–Order Bridge.**  For a prime `p` not dividing `b`, the entry point of `p`
in the Mersenne sequence `bⁿ − 1` equals the multiplicative order of `b` in the residue field
`ZMod p`.  The global rank of apparition is represented by a single stalk-level group order.

!-- For every `n`, `entryPoint p ∣ n ↔ p ∣ bⁿ−1 ↔ (b:ZMod p)ⁿ=1 ↔ orderOf (b:ZMod p) ∣ n`
(chaining `dvd_iff_entryPoint_dvd`, the stalk reduction, `orderOf_dvd_iff_pow_eq_one`);
two naturals with identical multiple-sets are equal. -- !--
-/
theorem mersenne_entryPoint_eq_orderOf {b p : ℕ} [Fact p.Prime] (hb : ¬ p ∣ b) :
    (mersenneSDS b).entryPoint p = orderOf (b : ZMod p) := by
  refine' le_antisymm ( Nat.le_of_dvd _ _ ) ( Nat.le_of_dvd _ _ );
  · exact Nat.pos_of_dvd_of_pos ( orderOf_dvd_iff_pow_eq_one.mpr ( by rw [ ZMod.pow_card_sub_one_eq_one ] ; rw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; aesop ) ) ( Nat.sub_pos_of_lt ( Nat.Prime.one_lt Fact.out ) );
  · refine' StrongDivSeq.dvd_iff_entryPoint_dvd _ _ _ |>.1 _;
    · refine' ⟨ p - 1, _, _ ⟩;
      · exact Nat.sub_pos_of_lt ( Nat.Prime.one_lt Fact.out );
      · simp +decide [ ← ZMod.natCast_eq_zero_iff, mersenneSDS ];
        rw [ Nat.cast_sub <| Nat.one_le_pow _ _ <| Nat.pos_of_ne_zero <| by rintro rfl; simp_all +decide [ ← ZMod.natCast_eq_zero_iff ] ] ; simp +decide [ ZMod.pow_card_sub_one_eq_one <| show ( b : ZMod p ) ≠ 0 from by rwa [ Ne, ZMod.natCast_eq_zero_iff ] ];
    · simp_all +decide [ ← ZMod.natCast_eq_zero_iff, mersenneSDS ];
      rw [ Nat.cast_sub <| Nat.one_le_pow _ _ <| Nat.pos_of_ne_zero <| by aesop ] ; simp +decide [ pow_orderOf_eq_one ];
  · refine' pos_iff_ne_zero.mpr _;
    intro h; simp_all +decide [ StrongDivSeq.entryPoint ] ;
    contrapose! h; simp_all +decide [ mersenneSDS ] ;
    exact ⟨ p - 1, Nat.sub_pos_of_lt ( Nat.Prime.one_lt Fact.out ), by rw [ ← ZMod.natCast_eq_zero_iff ] ; simp +decide [ Nat.cast_sub ( Nat.one_le_pow _ _ ( Nat.pos_of_ne_zero ( by aesop_cat : b ≠ 0 ) ) ), ZMod.pow_card_sub_one_eq_one ( by rwa [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ) ] ⟩;
  · -- By definition of entry point, we know that p divides b^entryPoint p - 1.
    have h_div : p ∣ b ^ (mersenneSDS b).entryPoint p - 1 := by
      by_cases h : ∃ k > 0, p ∣ b ^ k - 1;
      · convert StrongDivSeq.entryPoint_isPrimitive ( mersenneSDS b ) h |>.1 using 1;
      · simp_all +decide [ mersenneSDS, StrongDivSeq.entryPoint ];
        split_ifs <;> aesop;
    rw [ orderOf_dvd_iff_pow_eq_one ];
    simp_all +decide [ ← ZMod.natCast_eq_zero_iff, Nat.cast_sub ( Nat.one_le_pow _ _ ( Nat.pos_of_ne_zero ( by aesop_cat : b ≠ 0 ) ) ) ];
    exact eq_of_sub_eq_zero h_div

/-
**Fermat descent.**  The entry point of `p` in `bⁿ − 1` divides `p − 1`; the smallest
local period is bounded by the order of the unit group `(ZMod p)ˣ`.

!-- Rewrite via `mersenne_entryPoint_eq_orderOf`, then `orderOf (b:ZMod p) ∣ p − 1` follows
from `ZMod.pow_card_sub_one_eq_one` and `orderOf_dvd_of_pow_eq_one`. -- !--
-/
theorem mersenne_entryPoint_dvd_sub_one {b p : ℕ} [Fact p.Prime] (hb : ¬ p ∣ b) :
    (mersenneSDS b).entryPoint p ∣ p - 1 := by
  rw [ mersenne_entryPoint_eq_orderOf hb ];
  exact orderOf_dvd_iff_pow_eq_one.mpr ( by rw [ ZMod.pow_card_sub_one_eq_one ] ; rwa [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] )

/-! ## §4. Fibonacci specialization (catalog gluing) -/

/-
**Fibonacci specialization of the gluing theorem.**  The set of indices `n` with
`p ∣ Fₙ` is the principal progression of multiples of the Fibonacci entry point of `p`.
This is the global-section form of the rank-of-apparition law underlying
`Shared.CarmichaelProof`.

!-- Direct specialization of `support_eq_multiples` to `fibSDS` (whose underlying s
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Boltzmann Bridge X: Primitive Divisors as a Strong-Divisibility Phenomenon

## Synthesis

The Carmichael arc of this catalog set out to prove that every Fibonacci number `F(n)`
with `n ≥ 13` carries a *primitive prime divisor* — a prime dividing `F(n)` but no earlier
term. Two cycles back this was split into a prime-index case and a composite-index case,
with the prime case delegated to a file `Shared.CarmichaelHelper` that **was never written**
(the catalog imported a phantom lemma `fib_primitive_divisor_prime`), and the composite case
delegated to `Shared.CarmichaelProof.fib_carmichael_composite`, whose *infinite tail*
(`n > 10000`, beyond the `native_decide` window) was left as `sorry`.

This cycle closes the prime case **honestly and at full generality**, and in doing so
discovers that the prime case is not a Fibonacci fact at all — it is a fact about *every
strong divisibility sequence normalized by `u 1 = 1`*. The catalog's generic
rank-of-apparition engine (`Applications.UnifiedRankOfApparition`: `IsStrongDivSeq`, `rank`,
`HasRank`, the spine `rank_dvd_iff`, `rank_min`, `dvd_rank`) turns out to be exactly the
machine needed: a prime `q ∣ u(p)` has rank dividing the prime `p`, and the rank cannot be
`1` (else `q ∣ u(1) = 1`), so the rank equals `p` and `q` is primitive. The *same* one-line
engine call yields the Fibonacci/Carmichael prime case **and** Bang's theorem at prime
exponents (`2^p − 1` has a primitive prime divisor). The two classical theorems are facets of
one truth.

What remains genuinely open is the *composite* case for large `n`. That is where the "every
prime divisor is automatically primitive" miracle breaks: a prime dividing `u(mk)` may have
rank a proper divisor of `mk`. This is the true mathematical content of Carmichael/Zsygmondy,
and it is the spine of the next cycle.

## Results Summary (this cycle, all `sorry = 0`, axioms = {propext, Classical.choice, Quot.sound})

- `Shared/CarmichaelHelper.lean`
  - `fib_primitive_divisor_prime` — the previously-phantom prime case of Carmichael, now a
    real theorem. Restores compilation of both `Shared.CarmichaelProof` and
    `Speculative.AutoResearch.CarmichaelComposite`.
  - Supporting entry-point (rank of apparition) API: `entryPt`, `entryPt_dvd`, `entryPt_min`,
    `entryPt_ne_one`, `dvd_fib_gcd`.
- `Novelty/PrimitiveDivisorEntryLaw.lean`
  - `sds_primitive_divisor_prime` — primitive prime divisor at prime index for **any** strong
    divisibility sequence with `u 1 = 1`. Generalizes the Fibonacci result.
  - `sds_primitive_divisor_apparition` — sharp form: the primitive prime's apparition set is
    exactly the multiples of `p` (`q ∣ u n ↔ p ∣ n`).
  - `fib_primitive_at_prime` — Fibonacci/Carmichael prime case, re-derived from the engine.
  - `mersenne_primitive_at_prime` — Bang's theorem at prime exponents (`2^p − 1`), a
    cross-domain corollary of the *same* abstract theorem.
- Infrastructure: registered the orphaned `Applications` and `Novelty` s
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
