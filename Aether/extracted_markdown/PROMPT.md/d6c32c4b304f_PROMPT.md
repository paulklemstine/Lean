
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

**Title**: This cycle delivered `FibCarmichaelStructure.lean`, a **self-contained, `sorry`-
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Fibonacci Primitive Divisors, Fifth Cycle

## Synthesis

This cycle delivered `FibCarmichaelStructure.lean`, a **self-contained, `sorry`-free** root for the
Carmichael primitive-divisor program. It separates the theorem into two genuinely different layers:

1. A **fully general structural core** — strong divisibility (`fib_strong_divisibility`, built on
   Mathlib's `Nat.fib_gcd`), the entry-point / rank-of-apparition calculus
   (`fibEntryPt_dvd_of_fib_dvd`, `primitive_of_entryPt_eq`), and the *constructive criterion*
   `primitive_of_fibCoprimePart_pos`: if the computable witness `fibCoprimePart n` exceeds `1`,
   then `F n` has a primitive prime divisor. None of this needs analytic number theory; it is pure
   strong-divisibility bookkeeping.
2. A **verified finite instance** — `fib_carmichael_bounded`: every `F n` with `13 ≤ n ≤ 10000`
   has a primitive prime divisor, with the finite hypothesis discharged by `native_decide` on the
   computable coprime part, uniformly across primes and composites.

The single remaining input is the **infinite tail** `n > 10000`, which is precisely the analytic
heart of Carmichael/Zsygmondy: a lower bound on the homogeneous cyclotomic factor `Φ_n(α,β)`
that beats the largest "intrinsic" prime of `n`. We did not fake it; we isolated it.

## Results Summary

* `fib_strong_divisibility (m n) : gcd (F m) (F n) = F (gcd m n)` — strong divisibility sequence.
* `fibEntryPt_dvd_of_fib_dvd` — the entry point divides every index it appears in.
* `primitive_of_entryPt_eq` — entry point `= n` ⟺ primitive divisor of `F n`.
* `primitive_of_fibCoprimePart_pos` — constructive sufficient criterion (the program's engine).
* `fib_carmichael_bounded` — Carmichael verified, no `sorry`, on `13 ≤ n ≤ 10000`.

All depend only on `propext / Classical.choice / Quot.sound / Lean.ofReduceBool / Lean.trustCompiler`.

## Research Directions

### 1. Close the infinite tail via a cyclotomic lower bound `Φ_n(α,β) > n`.

State and prove `fibCyclotomic n > n` for `n > 12`, where `fibCyclotomic n = F n / ∏_{d ∣ n, d < n} (primitive part of F d)` is the integer homogeneous-cyclotomic factor. Combined with the
intrinsic-prime lemma (any non-primitive prime of `Φ_n` is the largest prime factor of `n`,
occurring to the first power), `Φ_n > p_max(n)` forces a surviving primitive prime, finishing
`fib_carmichael` for all `n > 12`. **The key insight is** that `|Φ_n(α,β)| ≥ α^{φ(n)} / α` grows
exponentially in `φ(n)`, while the only obstruction `p_max(n) ≤ n` grows linearly, so the inequality
is slack by a doubly-exponential margin for `n > 10000` and the `native_decide` band already
certifies the finitely many tight cases. **Why now?** The constructive criterion
`primitive_of_fibCoprimePart_pos` already reduces existence to "the coprime part is `> 1`"; only a
*size* estimate on that part is missing, turning a deep existence theorem into a clean inequality.

### 2. A decidable entry-point oracle and its complexity.

Replace the classical `fibEntryPt` with a `def`-computable `fibEntryPt? : ℕ → ℕ → Option ℕ` that
returns the rank of apparition of `p` by scanning `F k mod p` over one Pisano period, and prove it
agrees with `fibEntryPt` on primes. **The key insight is** that the entry point of `p` always
divides `p - (5/p)` (the Legendre symbol), so the search space is `O(p)` and bounded *a priori* by a
divisor enumeration rather than an unbounded `Nat.find`. **Why now?** `fibEntryPt_dvd_of_fib_dvd`
gives exactly the divisibility skeleton needed to prove termination and correctness of the bounded
scan, making the oracle a short hop from the present file.

### 3. Multiplicity refinement via lifting-the-exponent (LTE).

Prove the exact-power law `v_p(F n) = v_p(F z) + v_p(n)` for `p` with entry point `z = z(p) ∣ n`
(p ≠ 2, 5), reusing the Tropical p-adic valuation file in the catalog
(`Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors`).
**The key insight is** that `removePrimesOf` in this cycle already *computes* the primitive part, so
LTE is the statement that its `native_decide`-observed behaviour (each non-primitive prime survives
to multiplicity `v_p(n)`) holds symbolically for all `n`. **Why now?** With strong divisibility and
the entry-point divisibility lemma proven, LTE is the one missing multiplicative ingredient, and a
catalog file already targets the valuation bounds it needs.

### 4. Generalize the criterion to arbitrary Lucas / strong-divisibility sequences.

Abstract `primitive_of_fibCoprimePart_pos` from `Nat.fib` to any sequence `a : ℕ → ℕ` satisfying
`gcd (a m) (a n) = a (gcd m n)` and `a 0 = 0`, obtaining a *uniform* primitive-divisor criterion for
all strong divisibility sequences (Lucas `L n`, Mersenne `2^n - 1`, repunits, etc.). **The key
insight is** that every step of the present proof uses only strong divisibility — never a Fibonacci
identity — so the criterion is secretly a theorem about strong divisibility monoids. **Why now?**
The catalog's `StrongDivisibilitySequences` and `RankLatticeMorphism` files supply the exact
abstract interface; lifting this file to that interface unifies several scattered results.

### 5. Push and certify the verified band, then interpolate.

Extend `fib_coprime_part_pos_range` from `10000` to, say, `50000` with a sharded `native_decide`,
and *measure* the smallest observed ratio `Φ_n / p_max(n)` across the band. **The key insight is**
that the empirical minimum ratio is already `> 1` with growing slack, so the band data is not just a
checked instance but *evidence calibrating* the constant in Direction 1's inequality. **Why now?**
The witness `fibCoprimePart` is fully computable and the `native_decide` infrastructure is in place;
extending the band is cheap and directly de-risks the analytic proof before it is attempted.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/StrongDivPrimitiveCriterion.lean
import Mathlib

/-! # A computable primitive-divisor criterion for strong divisibility sequences

Domain: Number Theory / Algebra (Applications) — Adversarial Ground-Truth cycle.

## What this file adds to the catalog

The catalog already contains two complementary strands of the Fibonacci primitive-divisor
program:

* `Catalog/Applications/StrongDivisibilitySequences.lean` (`StrongDivSeq.IsStrongDivSeq`) lifts the
  *structural* primitivity/apparition theory (uniqueness, the meet/join laws, apparition counting)
  to abstract strong divisibility sequences `u (gcd m n) = gcd (u m) (u n)`.
* `Catalog/Speculative/AutoResearch/CarmichaelComposite.lean` contains a *computational* engine —
  the "coprime part" `fibCoprimePart` together with `primitive_of_fibCoprimePart_pos` — but it is
  hard-wired to `Nat.fib` and only ever applied to Fibonacci.

This file fuses the two: it lifts the **computational engine itself** to the abstract
`IsStrongDivSeq` setting.  The single criterion `primitive_of_coprimePart_pos` then specializes,
with *no extra work*, both to

* **Fibonacci** (`fib_carmichael_band` — Carmichael's primitive-divisor theorem, verified uniformly
  over primes and composites on `13 ≤ n ≤ 1000`), and to
* **Mersenne / `aⁿ − 1`** (`mersenne_bang_band` — Bang's primitive-divisor theorem for `2ⁿ − 1`,
  verified on `2 ≤ n ≤ 120`, with the unique exception `n = 6` automatically isolated).

That a *single* `native_decide`-backed inequality on the computable `coprimePart` discharges two
classically separate theorems (Carmichael 1913 for Fibonacci, Bang 1886 for `2ⁿ − 1`) is the
cross-domain payoff: the engine never touches a Fibonacci identity — only strong divisibility.

This realizes **Direction 4** ("Generalize the criterion to arbitrary strong-divisibility
sequences") of the previous cycle's `FUTURE_DIRECTIONS.md`.

## Main results

* `dvd_index_gcd`                 — `p ∣ u m → p ∣ u n → p ∣ u (gcd m n)` from strong divisibility.
* `primitive_of_coprimePart_pos`  — **the engine**: if the computable witness `coprimePart u n > 1`
  then `u n` has a primitive prime divisor (a prime dividing `u n` but no earlier `u k`).
* `fib_carmichael_band`           — Carmichael verified, `sorry`-free, on `13 ≤ n ≤ 1000`.
* `mersenne_bang_band`            — Bang verified, `sorry`-free, on `2 ≤ n ≤ 120`, `n ≠ 6`.
-/

namespace StrongDivCriterion

/-- A **strong divisibility sequence**: `u (gcd m n) = gcd (u m) (u n)`.  This is the *only*
property of the underlying sequence used anywhere below. -/
def IsStrongDivSeq (u : ℕ → ℕ) : Prop :=
  ∀ m n, u (Nat.gcd m n) = Nat.gcd (u m) (u n)

/-! ## §1. The one structural lemma: strong divisibility descends to the gcd of indices -/

/-
!-- Lab Notebook: dvd_index_gcd -- !--
!-- Hypothesis: For a strong divisibility sequence, a common divisor of `u m` and `u n`
already divides `u (gcd m n)`. -- !--
!-- Result: Proved in one line by rewriting with the defining law and `Nat.dvd_gcd`. -- !--
!-- Insight: This is the *entire* number-theoretic content of the primitive-divisor engine;
everything else is computable bookkeeping that is sequence-agnostic. -- !--
!-- Failure analysis: none. -- !--
!-- End Lab Notebook -- !--
-/
-- !-- Rewrite `u (gcd m n) = gcd (u m) (u n)` and apply `Nat.dvd_gcd`. -- !--
theorem dvd_index_gcd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p m n : ℕ}
    (hm : p ∣ u m) (hn : p ∣ u n) : p ∣ u (Nat.gcd m n) := by
  rw [hu m n]; exact Nat.dvd_gcd hm hn

/-! ## §2. The computable "coprime part" and its basic algebra (sequence-independent) -/

/-- `removePrimesOf a b` strips from `a` every prime that it shares with `b`, by repeatedly
dividing out `gcd a b`.  The result divides `a` and is coprime to `b`. -/
def removePrimesOf (a b : ℕ) : ℕ :=
  if ha : a = 0 then 0
  else
    let g := Nat.gcd a b
    if hg : g ≤ 1 then a
    else
      have : a / g < a := Nat.div_lt_self (Nat.pos_of_ne_zero ha) (by omega)
      removePrimesOf (a / g) b
termination_by a

/-- The coprime part of `u n` relative to all *proper* divisors `d ∣ n`: start from `u n` and strip
out every prime shared with any `u d`.  If the result exceeds `1`, a primitive prime survives. -/
def coprimePart (u : ℕ → ℕ) (n : ℕ) : ℕ :=
  let properDivs := (List.range n).filter (fun d => 0 < d && n % d == 0)
  properDivs.foldl (fun acc d => removePrimesOf acc (u d)) (u n)

/-
!-- Lab Notebook: removePrimesOf_* -- !--
!-- Hypothesis: `removePrimesOf a b` divides `a`, is coprime to `b` (for `a > 0`), and stays
positive (for `a > 0`). -- !--
!-- Result: All three proved by strong induction on `a` along the `a / gcd a b` recursion. -- !--
!-- Insight: These facts never mention `u`; the engine is purely about integers, which is exactly
why it transplants from Fibonacci to any sequence. -- !--
!-- Failure analysis: positivity needs `a > 0`; `removePrimesOf 0 b = 0` is the only zero case. -- !--
!-- End Lab Notebook -- !--
-/
-- !-- Strong induction on `a`; the recursive branch divides `a / gcd a b ∣ a`. -- !--
lemma removePrimesOf_dvd (a b : ℕ) : removePrimesOf a b ∣ a := by
  induction' a using Nat.strong_induction_on with a ih generalizing b
  unfold removePrimesOf
  split_ifs <;> simp_all +decide
  split_ifs
  · norm_num
  · exact dvd_trans (ih _ (Nat.div_lt_self (Nat.pos_of_ne_zero ‹_›) (lt_of_not_ge ‹_›)) _)
      (Nat.div_dvd_of_dvd (Nat.gcd_dvd_left _ _))

-- !-- Strong induction on `a`; either `gcd a b ≤ 1` already, or recurse on `a / gcd a b`. -- !--
lemma removePrimesOf_coprime (a b : ℕ) (ha : 0 < a) :
    Nat.Coprime (removePrimesOf a b) b := by
  induction' a using Nat.strong_induction_on with a ih generalizing b
  unfold removePrimesOf
  split_ifs <;> simp_all +decide [Nat.Coprime, Nat.gcd_comm]
  split_ifs
  · exact Nat.Coprime.symm (Nat.le_antisymm ‹_› (Nat.gcd_pos_of_pos_left _ ha))
  · exact ih _ (Nat.div_lt_self ha (lt_of_not_ge ‹_›)) _
      (Nat.div_pos (Nat.le_of_dvd ha (Nat.gcd_dvd_left _ _)) (Nat.gcd_pos_of_pos_left _ ha))

-- !-- A positive divisor of a positive number is positive. -- !--
lemma removePrimesOf_pos (a b : ℕ) (ha : 0 < a) : 0 < removePrimesOf a b :=
  Nat.pos_of_dvd_of_pos (removePrimesOf_dvd a b) ha

-- !-- Fold right-to-left; each step's `removePrimesOf` divides its accumulator, which divides `u n`. -- !--
lemma coprimePart_dvd (u : ℕ → ℕ) (n : ℕ) : coprimePart u n ∣ u n := by
  unfold coprimePart
  induction (List.filter (fun d => decide (0 < d) && n % d == 0) (List.range n))
      using List.reverseRecOn with
  | nil => simp
  | append_singleton l d ih =>
      simp [List.foldl_append]; exact dvd_trans (removePrimesOf_dvd _ _) ih

-- !-- `removePrimesOf 0 _ = 0`, so the whole fold collapses to `0`. -- !--
lemma foldl_removePrimesOf_zero (l : List ℕ) (f : ℕ → ℕ) :
    l.foldl (fun acc d => removePrimesOf acc (f d)) 0 = 0 := by
  induction l with
  | nil => rfl
  | cons d l ih =>
      simp only [List.foldl_cons]
      rw [show removePrimesOf 0 (f d) = 0 from by unfold removePrimesOf; simp]; exact ih

-- !-- If `u n = 0` the fold collapses to `0`, contradicting `coprimePart u n > 1`. -- !--
lemma un_pos_of_coprimePart_pos {u : ℕ → ℕ} {n : ℕ} (hcp : 1 < coprimePart u n) : 0 < u n := by
  by_contra h
  have hz : u n = 0 := by omega
  unfold coprimePart at hcp
  rw [hz, foldl_removePrimesOf_zero] at hcp
  omega

/-! ## §3. The engine: a positive coprime part forces a primitive prime divisor -/

/-
!-- Lab Notebook: primitive_of_coprimePart_pos -- !--
!-- Hypothesis: If the computable `coprimePart u n > 1`, then `u n` has a primitive prime divisor
(a prime `p ∣ u n` with `p ∤ u k` for every `0 < k < n`). -- !--
!-- Result: Proved for ALL strong divisibility sequences. The coprime part is coprime to `u d` for
every proper divisor `d ∣ n`; any prime `p` of it divides `u n` but, were `p ∣ u k`, then
`p ∣ u (gcd n k)` (by `dvd_index_gcd`) with `gcd n k` a proper divisor — contradiction. -- !--
!-- Insight: This is the catalog's `primitive_of_fibCoprimePart_pos` with `Nat.f
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — A Unified Primitive-Divisor Engine, Sixth Cycle

## Synthesis

This cycle delivered `Catalog/Applications/StrongDivPrimitiveCriterion.lean`, a **self-contained,
`sorry`-free** file that fuses two previously separate strands of the catalog's Fibonacci
primitive-divisor program:

1. the **structural** abstraction `StrongDivSeq.IsStrongDivSeq`
   (`Catalog/Applications/StrongDivisibilitySequences.lean`), which lifted uniqueness, the meet/join
   laws, and apparition counting to arbitrary strong divisibility sequences `u (gcd m n) =
   gcd (u m) (u n)`; and
2. the **computational** engine — the "coprime part" `fibCoprimePart` with
   `primitive_of_fibCoprimePart_pos` (`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`),
   which until now was hard-wired to `Nat.fib`.

The new file lifts the *engine itself* to the abstract setting. The single criterion
`primitive_of_coprimePart_pos` then specializes, with no extra mathematical input, to **both**
Carmichael's theorem for Fibonacci (`fib_carmichael_band`, verified uniformly over primes and
composites on `13 ≤ n ≤ 1000`) **and** Bang's theorem for `2ⁿ − 1` (`mersenne_bang_band`, verified
on `2 ≤ n ≤ 120`, with the unique Zsygmondy exception `n = 6` isolated automatically by the
computation). The engine never touches a Fibonacci identity — its only number-theoretic step,
`dvd_index_gcd`, uses strong divisibility alone — which is exactly why one `native_decide`-backed
inequality discharges two classically distinct primitive-divisor theorems.

## Results Summary

* `dvd_index_gcd` — `p ∣ u m → p ∣ u n → p ∣ u (gcd m n)`, the sole structural fact used.
* `primitive_of_coprimePart_pos` — **the engine**: `coprimePart u n > 1` ⟹ `u n` has a primitive
  prime divisor, for every strong divisibility sequence `u`.
* `fib_isStrongDivSeq`, `mersenne_isStrongDivSeq` — the two concrete instances (from `Nat.fib_gcd`
  and `Nat.pow_sub_one_gcd_pow_sub_one`).
* `fib_carmichael_band` — Carmichael, `sorry`-free, on `13 ≤ n ≤ 1000`.
* `mersenne_bang_band` — Bang, `sorry`-free, on `2 ≤ n ≤ 120`, `n ≠ 6`.

All depend only on `propext / Classical.choice / Quot.sound / Lean.ofReduceBool / Lean.trustCompiler`.

## Research Directions

### 1. Make the exceptional set a *theorem*, not an observed artifact.

For Fibonacci the engine's failures are exactly `{1, 2, 6, 12}`; for `2ⁿ − 1` exactly `{1, 6}`.
Prove `coprimePart Nat.fib n = 1 ↔ n ∈ {1,2,6,12}` for `n ≥ 1`, and the analogous statement for base
`2`, turning the empirically isolated exceptions into closed-form characterizations.
**The key insight is** that `coprimePart u n = 1` is equivalent to "every prime of `u n` already
divides some `u d` with `d ∣ n`, `d < n`", a *finite* divisor condition that the strong-divisibility
meet law (`dvd_index_gcd`) reduces to a statement about the maximal-divisor lattice of `n` — so the
exceptions are forced by small-index arithmetic, not by analysis. **Why now?** The criterion already
makes `coprimePart` the ca
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
