
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

**Title**: Deepening: This cycle was a cold start on the clique-complex research thread: the catalog c
**Domain**: Novelty
**Mathematical framing**: Building on cycle 21edf563 (Q=0.802), which proved 438 theorems in Applications. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: # Future Directions: Clique Complex Theory in Lean 4

## Synthesis

This cycle was a cold start on the clique-complex research thread: the catalog context
referenced an `ASC'`/`cliqueComplex'`/`vietorisRips`/`isFlag` infrastructure that did not
actually exist in the project. Rather than build on pha
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Novelty/KorseltCarmichael.lean
import Mathlib

/-!
# Korselt's criterion and Carmichael numbers

Domain: Number Theory / Novelty.

A **Carmichael number** is a composite `n` that is a Fermat pseudoprime to *every* base
coprime to it: `n ∣ b ^ (n-1) - 1` for all `b` with `gcd(n,b) = 1`.  Mathlib defines
`Nat.FermatPsp` (pseudoprime to a single base) but explicitly notes that Carmichael numbers
are *"not yet defined"* (see `Mathlib/NumberTheory/FermatPsp.lean`).  This file supplies the
missing structural backbone via **Korselt's criterion** and connects it to Mathlib's
`Nat.FermatPsp`.

We package the *sufficient* half of Korselt's criterion in the predicate `Korselt`:
`n` is squarefree, composite, `> 1`, and `(p - 1) ∣ (n - 1)` for every prime `p ∣ n`.

## Main results

* `Korselt.dvd_pow_sub_self` — the heart: a squarefree `n` whose prime factors `p` all satisfy
  `(p-1) ∣ (n-1)` divides `a ^ n - a` for *every* integer `a` (Fermat's little theorem holds
  universally, not just for coprime bases).
* `Korselt.fermatPsp_of_coprime` — the bridge to Mathlib: a Korselt number is a `Nat.FermatPsp`
  to every coprime base.  This is exactly the Carmichael property.
* `Korselt.odd` — every Korselt number is odd.
* `Korselt.three_le_card_primeFactors` — every Korselt number has at least three distinct prime
  factors.
* `Korselt.korselt_561` / `Korselt.fermatPsp_561` — `561 = 3·11·17` is a Korselt number, hence a
  Carmichael number (the smallest one).

## Catalog synthesis

This extends the catalog's number-theoretic thread (the Fibonacci `gcd`-bridge `Nat.fib_gcd`
used across `Catalog/Applications/FibonacciEntryPoints.lean`, and the Fermat-pseudoprime
direction) by installing the *Korselt* backbone of Carmichael theory, a structure Mathlib
itself flags as missing.  The headline `fermatPsp_of_coprime` is a cross-domain bridge:
finite-field exponentiation in `ZMod p` (`ZMod.pow_card_sub_one_eq_one`) is glued, through the
CRT-style `Finset.prod_dvd_of_coprime` over `Nat.primeFactors`, to Mathlib's `Nat.FermatPsp`.
-/

-- !-- Lab Notebook -- !--
-- Hypothesis: Korselt's criterion (squarefree + `(p-1)∣(n-1)` for all primes `p∣n`) should be
--   formalizable from first principles and yield, for free, the full Carmichael property as a
--   bridge into Mathlib's `Nat.FermatPsp`.
-- Result: Proved the integer identity `n ∣ a^n - a` for all `a`, the bridge to `Nat.FermatPsp`,
--   oddness, the `≥ 3` prime-factor structure theorem, and the canonical instance `561`.
-- Insight: The whole edifice reduces to two clean mechanisms — (1) in each residue field
--   `ZMod p`, `x^n = x` because `(p-1)∣(n-1)`; (2) squarefreeness lets the pairwise-coprime
--   primes recombine via `Finset.prod_dvd_of_coprime`. Compositeness is never needed for the
--   Fermat identity itself; it is only needed for the structural `odd` / `≥3 factors` theorems.
-- Failure analysis: `decide` does NOT evaluate `Squarefree`, `primeFactors`, or bounded `∀ p`
--   prime statements (the `Decidable` instances get stuck on `minSqFac` / `primeFactorsList`).
--   The working route for the `561` instance is `Nat.squarefree_mul_iff` + `Nat.Prime.squarefree`
--   for squarefreeness, and `Nat.Prime.dvd_mul` peeling for the divisor enumeration.
-- !-- end -- !--

open scoped Classical

namespace Korselt

/-- The (sufficient half of) **Korselt's criterion**: `n` is squarefree, composite, exceeds `1`,
and every prime `p` dividing `n` satisfies `(p - 1) ∣ (n - 1)`.  We show below that any such `n`
is a Carmichael number. -/
def IsKorselt (n : ℕ) : Prop :=
  1 < n ∧ ¬ n.Prime ∧ Squarefree n ∧ ∀ p, p.Prime → p ∣ n → (p - 1) ∣ (n - 1)

-- !-- In each prime residue field `ZMod p`, `x^n = x`: if `x = 0` use `n ≥ 1`; otherwise
-- !-- `x^(p-1) = 1` (Fermat) and `(p-1) ∣ (n-1)` collapse `x^(n-1)` to `1`. -- !--
/-- In the field `ZMod p`, every element satisfies `x ^ n = x` once `(p-1) ∣ (n-1)` and `n ≥ 1`. -/
lemma pow_eq_self_zmod {p n : ℕ} [Fact p.Prime] (hpn : (p - 1) ∣ (n - 1)) (hn : 1 ≤ n)
    (x : ZMod p) : x ^ n = x := by
  by_cases hx : x = 0;
  · cases n <;> aesop;
  · obtain ⟨ k, hk ⟩ := hpn; rw [ show n = ( p - 1 ) * k + 1 by linarith [ Nat.sub_add_cancel ( show 1 ≤ n from hn ) ] ] ; simp +decide [ pow_add, pow_mul, ZMod.pow_card_sub_one_eq_one hx ] ;

-- !-- For a single prime `p ∣ n`, reduce `(p:ℤ) ∣ a^n - a` to `(↑a)^n = ↑a` in `ZMod p` via
-- !-- `ZMod.intCast_zmod_eq_zero_iff_dvd`, then apply `pow_eq_self_zmod`. -- !--
/-- For a prime `p` with `(p-1) ∣ (n-1)`, the integer `a ^ n - a` is divisible by `p`. -/
lemma prime_dvd_pow_sub_self {p n : ℕ} (hp : p.Prime) (hpn : (p - 1) ∣ (n - 1)) (hn : 1 ≤ n)
    (a : ℤ) : (p : ℤ) ∣ a ^ n - a := by
  haveI := Fact.mk hp; have h := pow_eq_self_zmod hpn hn; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;

-- !-- Heart of Korselt: write the squarefree `n` as the product of its distinct (hence pairwise
-- !-- coprime) prime factors; each prime divides `a^n - a`, so the product does too via
-- !-- `Finset.prod_dvd_of_coprime`, and the product is `n`. -- !--
/-- **The Korselt identity.** If `n` is squarefree and `(p-1) ∣ (n-1)` for every prime `p ∣ n`,
then `(n : ℤ) ∣ a ^ n - a` for *every* integer `a`. -/
theorem dvd_pow_sub_self {n : ℕ} (hsf : Squarefree n) (hn : 1 ≤ n)
    (hdvd : ∀ p, p.Prime → p ∣ n → (p - 1) ∣ (n - 1)) (a : ℤ) :
    (n : ℤ) ∣ a ^ n - a := by
  convert Finset.prod_dvd_of_coprime _ _;
  rw [ ← Nat.cast_prod, Nat.prod_primeFactors_of_squarefree hsf ];
  · -- Since the prime factors of `n` are distinct, they are pairwise coprime.
    intros p hp q hq hpq;
    simpa using Nat.coprime_primes ( Nat.prime_of_mem_primeFactors hp ) ( Nat.prime_of_mem_primeFactors hq ) |>.2 hpq;
  · exact fun p hp => prime_dvd_pow_sub_self ( Nat.prime_of_mem_primeFactors hp ) ( hdvd p ( Nat.prime_of_mem_primeFactors hp ) ( Nat.dvd_of_mem_primeFactors hp ) ) hn a

-- !-- Bridge to Mathlib: from `n ∣ b^n - b = b·(b^{n-1}-1)` and `gcd(n,b)=1`, cancel the coprime
-- !-- factor `b` to get the `ProbablePrime` condition `n ∣ b^{n-1} - 1`, packaging `Nat.FermatPsp`. -- !--
/-- **Korselt ⟹ Carmichael.** A Korselt number is a Fermat pseudoprime (`Nat.FermatPsp`) to every
base `b ≥ 1` coprime to it. -/
theorem fermatPsp_of_coprime {n b : ℕ} (hk : IsKorselt n) (hb : 1 ≤ b) (hcop : Nat.Coprime n b) :
    Nat.FermatPsp n b := by
  refine' ⟨ _, hk.2.1, _ ⟩;
  · obtain ⟨ h₁, h₂, h₃, h₄ ⟩ := hk;
    -- From `dvd_pow_sub_self`, we have `(n : ℤ) ∣ (b:ℤ)^n - (b:ℤ)`, i.e. `(n : ℤ) ∣ b * (b^(n-1) - 1)`.
    have h_div : (n : ℤ) ∣ b * (b ^ (n - 1) - 1) := by
      convert dvd_pow_sub_self h₃ ( by linarith ) h₄ b using 1 ; cases n <;> simp_all +decide [ pow_succ', mul_sub ];
    exact Int.natCast_dvd_natCast.mp ( by simpa [ Nat.cast_sub ( Nat.one_le_pow _ _ hb ) ] using Int.dvd_of_dvd_mul_right_of_gcd_one h_div <| by simpa [ Int.gcd_natCast_natCast ] using hcop );
  · exact hk.1

-- !-- If `n` were even, squarefree+composite forces an odd prime factor `p`; then `2 ∣ (p-1) ∣ (n-1)`
-- !-- makes `n-1` even, contradicting `n` even. -- !--
/-- Every Korselt number is odd. -/
theorem odd {n : ℕ} (hk : IsKorselt n) : Odd n := by
  rcases hk with ⟨ hn₁, hn₂, hn₃, hn₄ ⟩;
  by_cases h₂ : 2 ∣ n;
  · -- Since n is composite and > 1, it must have at least one prime factor p ≠ 2.
    obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ : ∃ p, Nat.Prime p ∧ p ∣ n ∧ p ≠ 2 := by
      contrapose! hn₂;
      -- If all prime factors of $n$ are $2$, then $n$ must be a power of $2$.
      have h_pow_two : ∃ k, n = 2 ^ k := by
        rw [ ← Nat.prod_primeFactorsList hn₁.ne_bot ] ; rw [ List.prod_eq_pow_single 2 ] ; aesop;
        exact fun p hp₁ hp₂ => False.elim <| hp₁ <| hn₂ p ( Nat.prime_of_mem_primeFactorsList hp₂ ) <| Nat.dvd_of_mem_primeFactorsList hp₂;
      rcases h_pow_two with ⟨ k, rfl ⟩ ; rcases k with ( _ | _ | k ) <;> simp_all +decide [ Nat.squarefree_pow_iff ] ;
    -- Since p is odd, we have 2 ∣ p - 1.
    have h₄ : 2 ∣ p - 1 := by
      exact even_iff_two_dvd.mp ( hp₁.even_sub_one hp₃ );
    exact a
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Korselt's Criterion and Carmichael Numbers in Lean 4

## Synthesis

This cycle installed the structural backbone of **Carmichael number theory** — a topic that
Mathlib's own `Mathlib/NumberTheory/FermatPsp.lean` explicitly flags as *"not yet defined"*.
The new file `Catalog/Novelty/KorseltCarmichael.lean` formalizes the *sufficient half* of
**Korselt's criterion** through the predicate `IsKorselt n` (squarefree, composite, `> 1`, and
`(p - 1) ∣ (n - 1)` for every prime `p ∣ n`) and proves that any such number is a genuine
Carmichael number: a Fermat pseudoprime to **every** coprime base.

The proof is deliberately first-principles and factored into two reusable mechanisms:

1. **Local mechanism (`pow_eq_self_zmod`)**: in each residue field `ZMod p`, the identity
   `x ^ n = x` holds for all `x` precisely because `(p-1) ∣ (n-1)` collapses the unit-group
   exponent via `ZMod.pow_card_sub_one_eq_one`.
2. **Global recombination (`dvd_pow_sub_self`)**: squarefreeness expresses `n` as a product of
   *pairwise coprime* primes, so the local divisibilities glue back together through
   `Finset.prod_dvd_of_coprime`.

These two lemmas are of independent interest and immediately yield three structural theorems —
`odd`, `not_eq_mul_two_primes`, and `three_le_card_primeFactors` (every Carmichael number is odd,
squarefree, and has at least three distinct prime factors) — plus the verified canonical instance
`561 = 3·11·17`. The headline `fermatPsp_of_coprime` is a genuine cross-domain bridge: it connects
finite-field exponentiation to Mathlib's existing `Nat.FermatPsp` API, closing the gap that
Mathlib's documentation names out loud.

## Results Summary

| Theorem | Statement |
|---|---|
| `pow_eq_self_zmod` | In `ZMod p`, `(p-1) ∣ (n-1)` and `n ≥ 1` give `x^n = x` for all `x`. |
| `prime_dvd_pow_sub_self` | For a prime `p` with `(p-1) ∣ (n-1)`, `(p:ℤ) ∣ a^n - a`. |
| `dvd_pow_sub_self` | Squarefree + Korselt divisibility ⟹ `(n:ℤ) ∣ a^n - a` for **all** `a`. |
| `fermatPsp_of_coprime` | A Korselt number is `Nat.FermatPsp n b` for every coprime base `b ≥ 1`. |
| `odd` | Every Korselt number is odd. |
| `not_eq_mul_two_primes` | A Korselt number is never a product of two distinct primes. |
| `three_le_card_primeFactors` | Every Korselt number has `≥ 3` distinct prime factors. |
| `korselt_561` / `fermatPsp_561` | `561` is Korselt, hence the smallest Carmichael number. |

All main results carry `sorry = 0` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Bold, Falsifiable Research Directions

### 1. The converse: Korselt's criterion is an *iff*

Conjecture: if a composite `n` divides `a^(n-1) - 1` for every `a` coprime to `n` (equivalently,
`Nat.FermatPsp n b` for all coprime `b`), then `n` is squarefree and `(p-1) ∣ (n-1)` for every
prime `p ∣ n`. Together with `fermatPsp_of_coprime` this would give the full biconditional
`IsKorselt n ↔ IsCarmichael n`.
The key insight is that the *necessity* directi
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
