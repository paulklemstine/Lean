
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

**Title**: This cycle isolated the *rank of apparition* `r(p) = min { k > 0 : p ∣ F(k) }`
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Fibonacci Rank of Apparition and Primitive Divisors

## Synthesis

This cycle isolated the *rank of apparition* `r(p) = min { k > 0 : p ∣ F(k) }`
as the single organizing principle behind the divisibility structure of the
Fibonacci sequence, and proved (in `Shared/FibonacciRankTheory.lean`, `sorry = 0`):

- `fib_coprime_of_coprime_index`: coprime indices give coprime Fibonacci numbers;
- `fib_dvd_iff_rank_dvd`: `p ∣ F(n) ↔ r(p) ∣ n` (no primality needed);
- `fibRank_eq_iff_primitive`: `p` is a primitive divisor of `F(n)` iff `r(p) = n`;
- `carmichael_range`: an algorithmic, `native_decide`-certified proof that every
  `F(n)` for `n ∈ [3,60] \ {6,12}` has a primitive prime divisor, bridged through
  `(F n).primeFactorsList` to the genuine number-theoretic statement.

These are exactly the "key ingredients" the catalog's `Shared/CarmichaelProof.lean`
and `Speculative/AutoResearch/CarmichaelComposite.lean` need: those files reduce
Carmichael's theorem to (i) a finite computational check on a bounded range and
(ii) an *infinite tail* for composite `n > 10000`, which remains the lone `sorry`
in `CarmichaelProof.lean`. The rank/primitivity characterization here is the
clean conceptual core that any honest tail argument must invoke.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_coprime_of_coprime_index` | `Coprime m n → Coprime (F m) (F n)` | proved |
| `fib_dvd_iff_rank_dvd` | `p ∣ F n ↔ r(p) ∣ n` | proved |
| `fibRank_eq_iff_primitive` | primitive at `n` ↔ `r(p) = n` | proved |
| `carmichael_range` | primitive divisor exists for `n ∈ [3,60]\{6,12}` | proved (`native_decide`) |

## Research Directions

### 1. Closing the composite infinite tail of Carmichael's theorem

The outstanding `sorry` in `Shared/CarmichaelProof.lean` asserts that every
composite `n > 10000` yields a Fibonacci number `F(n)` with a primitive prime
divisor. The conjecture to attack constructively: for `n ≥ 13`, the *primitive
part* `Φ_n := F(n) / ∏_{d | n, d < n} gcd(F(n), F(d))` always exceeds `1`, and
moreover `Φ_n` is divisible by a prime `p` with `r(p) = n`.
**The key insight is** that `fibRank_eq_iff_primitive` reduces "primitive divisor
exists" to "some prime has rank exactly `n`", so the tail becomes a statement
about the multiplicative size of the cyclotomic-like factor `Φ_n` versus the
product of intrinsic (non-primitive, i.e. `p ∣ n`) prime powers — a comparison
that admits explicit lower bounds from `F(n) ~ φ^n` growth.
**Why now?** With `fib_dvd_iff_rank_dvd` and `fibRank_eq_iff_primitive` already
formalized, the remaining gap is purely an analytic size estimate; the
combinatorial/divisibility scaffolding no longer has to be reproved.

### 2. Sharp bound on intrinsic primes (a falsifiable size estimate)

Conjecture: the only primes that can divide `F(n)` non-primitively and obstruct a
primitive divisor are those `p` with `p ∣ n`, and their total `p`-adic
contribution to `F(n)` is at most `n · log_φ(n)` in logarithmic size. Concretely,
`∑_{p | n} v_p(F(n)) · log p < log F(n)` for all `n ∉ {1,2,6,12}`.
**The key insight is** Lifting-the-Exponent: `v_p(F(n)) = v_p(F(r(p))) + v_p(n / r(p))`
when `p | n`, so the intrinsic contribution is logarithmic while `log F(n)` is
linear in `n`. **Why now?** The `Algebra/...Lifting_the_Exponent...` catalog file
already states `fib_gcd_identity`; combining it with `fib_dvd_iff_rank_dvd` makes
this a finite-data inequality amenable to `interval_cases` + growth bounds.

### 3. Generalization to Lucas sequences `U_n(P,Q)`

Conjecture: every theorem in `FibonacciRankTheory.lean` holds verbatim for a
nondegenerate Lucas sequence `U_n(P,Q)` with `gcd(P,Q)=1`, with `F` replaced by
`U` and `Nat.fib_gcd` replaced by the strong divisibility `gcd(U_m,U_n)=U_{gcd}`.
**The key insight is** that none of the four proofs used anything specific to
`F` beyond strong divisibility and `U_1 = 1`; the rank machinery is an abstract
consequence of a *divisibility sequence*. **Why now?** Abstracting to a typeclass
`StrongDivisibilitySequence` would let the catalog's many Fibonacci files share a
single proof, eliminating duplication flagged in the catalog-synthesis brief.

### 4. Decidable rank computation and a verified `r(p)` algorithm

Conjecture: there is a `decide`-checkable function `rankBudget : ℕ → ℕ` with
`r(p) ≤ rankBudget p` for all primes `p`, namely `rankBudget p = p + 1` (since
`p ∣ F(p - (5/p))` by the entry-point/Pisano bound). Hence `fibRank` is
computable and `r(p) ∣ p ± 1` for `p ≠ 5`.
**The key insight is** that the rank divides the Pisano period, which divides
`6p` and is bounded by `6p`, giving an a-priori search bound that turns the
noncomputable `fibRank` into an effective algorithm. **Why now?** The
`native_decide` infrastructure in `carmichael_range` shows the kernel can already
evaluate Fibonacci divisibility fast; a proven search bound upgrades `fibRank`
from `noncomputable` to executable.

### 5. Extending the certified Carmichael range and density of primitive primes

Conjecture: `carmichael_range` extends to all `n ≤ N` for any fixed `N` (the
`{6,12}` exceptions never recur), and furthermore the *count* of distinct
primitive prime divisors of `F(n)` grows: `#{ p : r(p) = n } ≥ 1` always, and
`≥ 2` for all `n > 30`.
**The key insight is** that primitive primes of `F(n)` are exactly the prime
factors of the primitive part `Φ_n`, so counting them is counting prime factors
of an explicit integer — fully decidable per `n`. **Why now?** The
`primeFactorsList`-restricted witness search proved here is fast enough to push
`native_decide` verification to much larger ranges, turning the multiplicity
question into reproducible computational data that can seed a general proof.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Shared/StrongDivisibilityRankBridge.lean
import Mathlib

/-! # The abstract rank of apparition for strong divisibility sequences,
and its identification with the multiplicative order

Domain: Number Theory / Algebra (cross-domain bridge).

The catalog develops the *rank of apparition* `r(p) = min { k > 0 : p ∣ F(k) }` for the
Fibonacci sequence (`Catalog/Applications/RankOfApparition.lean`: `fibRank`, the spine
`m ∣ F n ↔ r(m) ∣ n`, `fibRank_fib`, `fib_prime_index_has_primitive`) and separately a
*structure-only* theory of strong divisibility sequences
(`Catalog/Applications/StrongDivisibilitySequences.lean`: `IsStrongDivSeq`, `IsPrimitive`,
`isPrimitive_unique`, `dvd_iff_index_dvd_of_primitive`, the counting laws).  The latter file
has **no rank function** and the former is **Fibonacci-specific**.

This file unifies the two: it equips an *arbitrary* strong divisibility sequence `u` with a
rank-of-apparition function `seqRank u`, proves the spine and the primitivity
characterization at this level of generality (so they specialise to Fibonacci, Mersenne,
Lucas, … verbatim), and then closes a genuinely cross-domain loop:

> **For the Mersenne family `u(n) = aⁿ − 1`, the rank of apparition of `m` is exactly the
> multiplicative order of `a` modulo `m`** (`seqRank_mer_eq_orderOf`).

Thus the divisibility-theoretic invariant `r(m)` and the group-theoretic invariant
`orderOf (a : ZMod m)` are *the same number*.  This realises **Direction 3** ("generalisation
to Lucas / strong divisibility sequences") of the previous cycle's `FUTURE_DIRECTIONS.md`,
and connects it to the order theory of `ZMod m`.

Main results (all `sorry`-free):

* `seqRank_spine`             — `m ∣ u n ↔ seqRank u m ∣ n`, for any strong divisibility
  sequence `u` in which `m` has a rank.  The abstract version of the catalog's Fibonacci spine.
* `isPrimitive_iff_seqRank_eq` — `IsPrimitive u p n ↔ seqRank u p = n` (for `0 < n`):
  a value is a primitive divisor of `u n` iff its rank is exactly `n`.
* `mer_dvd_iff_orderOf_dvd`   — `m ∣ aⁿ − 1 ↔ orderOf (a : ZMod m) ∣ n`.
* `seqRank_mer_eq_orderOf`    — `seqRank (fun n => aⁿ − 1) m = orderOf (a : ZMod m)`
  for `1 ≤ a`, `0 < m`, `Nat.Coprime a m`: rank of apparition = multiplicative order.

-/

namespace StrongDivRankBridge

/-! ## §0. The abstract setting -/

/-- A **strong divisibility sequence**: `u (gcd m n) = gcd (u m) (u n)` for all `m, n`.
Both `Nat.fib` and `n ↦ aⁿ − 1` satisfy this. -/
def IsStrongDivSeq (u : ℕ → ℕ) : Prop := ∀ m n, u (Nat.gcd m n) = Nat.gcd (u m) (u n)

/-- `m` *has a rank* in `u` if it divides some positive-index term. -/
def HasRank (u : ℕ → ℕ) (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ u k

/-- `p` is a *primitive divisor* of `u n`: it divides `u n` but none of `u 1, …, u (n-1)`. -/
def IsPrimitive (u : ℕ → ℕ) (p n : ℕ) : Prop :=
  p ∣ u n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ u k

/-
!-- Lab Notebook: IsStrongDivSeq.dvd_of_dvd -- !--
!-- Hypothesis: A strong divisibility sequence is a divisibility sequence: `m ∣ n → u m ∣ u n`. -- !--
!-- Result: Proved. `m ∣ n` gives `gcd m n = m`, so `u m = gcd (u m) (u n) ∣ u n`. -- !--
!-- Insight: The *weak* law is a free corollary of the *strong* law; this is the only
divisibility fact the backward direction of the spine needs. -- !--
!-- Failure analysis: none. -- !--
!-- End Lab Notebook -- !--
-/
-- !-- `gcd m n = m` (from `m ∣ n`), rewrite the strong law, then `Nat.gcd_dvd_right`. -- !--
theorem IsStrongDivSeq.dvd_of_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m n : ℕ}
    (h : m ∣ n) : u m ∣ u n := by
  have h_gcd : Nat.gcd m n = m := Nat.gcd_eq_left h
  have := hu m n
  rw [h_gcd] at this
  rw [this]
  exact Nat.gcd_dvd_right _ _

/-! ## §1. The abstract rank-of-apparition function -/

open scoped Classical in
/-- The rank of apparition of `m` in the sequence `u`: the least positive `k` with `m ∣ u k`
(or `0` if no such `k` exists). -/
noncomputable def seqRank (u : ℕ → ℕ) (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ u k then Nat.find h else 0

theorem seqRank_pos {u : ℕ → ℕ} {m : ℕ} (hm : HasRank u m) : 0 < seqRank u m := by
  unfold seqRank; split_ifs with h
  · exact (Nat.find_spec h).1
  · exact absurd hm h

theorem dvd_seqRank {u : ℕ → ℕ} {m : ℕ} (hm : HasRank u m) : m ∣ u (seqRank u m) := by
  unfold seqRank; split_ifs with h
  · exact (Nat.find_spec h).2
  · exact absurd hm h

theorem seqRank_min {u : ℕ → ℕ} {m k : ℕ} (hk : 0 < k) (hlt : k < seqRank u m) :
    ¬ m ∣ u k := by
  unfold seqRank at hlt; split_ifs at hlt with h
  · exact fun hd => Nat.find_min h hlt ⟨hk, hd⟩
  · simp at hlt

/-! ## §2. The spine: `m ∣ u n ↔ seqRank u m ∣ n` -/

/-
!-- Lab Notebook: seqRank_spine -- !--
!-- Hypothesis: For any strong divisibility sequence in which `m` has a rank,
`m ∣ u n ↔ seqRank u m ∣ n` (the abstract version of `RankOfApparition.fibRank_dvd_iff`). -- !--
!-- Result: Proved. (←) `seqRank u m ∣ n → u (seqRank) ∣ u n` (`dvd_of_dvd`) and
`m ∣ u (seqRank)`. (→) push `m` into `u (gcd (seqRank) n) = gcd (u …) (u n)` (strong law);
if `seqRank ∤ n` the gcd index is positive and `< seqRank`, contradicting minimality. -- !--
!-- Insight: The proof uses ONLY the strong-divisibility hypothesis — nothing Fibonacci-
specific — so the catalog's whole apparition theory is an instance of this one biconditional. -- !--
!-- Failure analysis: needs `HasRank u m` so the rank is positive. -- !--
!-- End Lab Notebook -- !--
-/
theorem seqRank_spine {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m : ℕ} (hm : HasRank u m) (n : ℕ) :
    m ∣ u n ↔ seqRank u m ∣ n := by
  have hz : 0 < seqRank u m := seqRank_pos hm
  have hmz : m ∣ u (seqRank u m) := dvd_seqRank hm
  constructor <;> intro hn
  · contrapose! hn
    have hgcd_lt : Nat.gcd (seqRank u m) n < seqRank u m :=
      lt_of_le_of_ne (Nat.le_of_dvd hz (Nat.gcd_dvd_left _ _))
        (fun h => hn (h ▸ Nat.gcd_dvd_right _ _))
    refine fun hcontra => seqRank_min (Nat.gcd_pos_of_pos_left _ hz) hgcd_lt ?_
    have := Nat.dvd_gcd hmz hcontra
    rw [← hu] at this
    exact this
  · obtain ⟨k, rfl⟩ := hn
    exact dvd_trans hmz (hu.dvd_of_dvd ⟨k, rfl⟩)

/-! ## §3. Primitivity ⟺ the rank equals the index -/

/-
!-- Lab Notebook: isPrimitive_iff_seqRank_eq -- !--
!-- Hypothesis: `IsPrimitive u p n ↔ seqRank u p = n` for `0 < n`. -- !--
!-- Result: Proved. (→) `p ∣ u n` gives `seqRank ∣ n` (spine), so `seqRank ≤ n`; if it were
`< n`, primitivity would forbid `p ∣ u (seqRank)`, contradicting `dvd_seqRank`. (←) with
`seqRank = n`: `p ∣ u n` is `dvd_seqRank`, and minimality of the rank gives the no-earlier
clause. -- !--
!-- Insight: This is the conceptual core "primitive divisor exists ↔ some value has rank
exactly n", the abstract form of `fibRank_eq_iff_primitive` flagged in the synthesis. -- !--
!-- Failure analysis: index `0` must be excluded; `seqRank u p = 0` would mean no rank. -- !--
!-- End Lab Notebook -- !--
-/
theorem isPrimitive_iff_seqRank_eq {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p n : ℕ}
    (hp : HasRank u p) (hn : 0 < n) : IsPrimitive u p n ↔ seqRank u p = n := by
  constructor
  · rintro ⟨hpn, hmin⟩
    have hle : seqRank u p ≤ n := Nat.le_of_dvd hn ((seqRank_spine hu hp n).1 hpn)
    rcases lt_or_eq_of_le hle with hlt | heq
    · exact absurd (dvd_seqRank hp) (hmin _ (seqRank_pos hp) hlt)
    · exact heq
  · intro heq
    refine ⟨heq ▸ dvd_seqRank hp, fun k hk hkn => ?_⟩
    exact seqRank_min hk (heq ▸ hkn)

/-! ## §4. Instance: the Fibonacci sequence -/

/-
!-- Lab Notebook: fib_isStrongDivSeq -- !--
!-- Hypothesis: `Nat.fib` is a strong divisibility sequence. -- !--
!-- Result: Immediate from `Nat.fib_gcd`. -- !--
!-- Insight: Specialising `seqRank_spine`/`isPrimitive_iff_seqRank_eq` to `Nat.fib` recovers
the catalog's Fibonacci rank theory (`RankOfApparition.fibRank_dvd_iff`); existence of the
rank for every positive modulus is the pigeonhole argument in that file. -- !--
!-- End Lab Notebook -- !--
-/
theorem fib_isStrongDivSeq : IsStrongDivSeq Nat.fib := fun m n => Nat.fib_gcd m n

/-! ## §5. Instance + bridge: the Mersenne family
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Rank of Apparition as a Cross-Domain Invariant

## Synthesis

The previous cycle isolated the *rank of apparition* `r(p) = min { k > 0 : p ∣ F(k) }`
as the organizing principle behind Fibonacci divisibility, and the catalog already
contains two complementary developments: a **Fibonacci-specific** rank theory
(`Catalog/Applications/RankOfApparition.lean`: `fibRank`, the spine
`m ∣ F n ↔ r(m) ∣ n`, `fibRank_fib`, `fib_prime_index_has_primitive`) and a
**structure-only** theory of strong divisibility sequences
(`Catalog/Applications/StrongDivisibilitySequences.lean`: `IsStrongDivSeq`,
`IsPrimitive`, `isPrimitive_unique`, the counting laws) which, crucially, *carried
no rank function at all*.

This cycle (`Catalog/Shared/StrongDivisibilityRankBridge.lean`, `sorry = 0`) fuses
the two strands and pushes them across a domain boundary:

- it equips an **arbitrary** strong divisibility sequence `u` with a rank-of-apparition
  function `seqRank u`, and proves the **spine** `m ∣ u n ↔ seqRank u m ∣ n` and the
  **primitivity characterization** `IsPrimitive u p n ↔ seqRank u p = n` at full
  generality — so the catalog's entire Fibonacci apparition theory becomes a single
  instantiation rather than a parallel re-derivation;
- it then closes a genuinely cross-domain loop on the **Mersenne family** `u(n) = aⁿ − 1`:
  `seqRank (mer a) m = orderOf (a : ZMod m)`. The number-theoretic apparition invariant
  `r(m)` and the group-theoretic invariant *multiplicative order of `a` mod `m`* are
  literally the same natural number.

The decisive realization is that **none of the divisibility scaffolding ever used a
property of Fibonacci beyond the strong-divisibility law `u(gcd m n) = gcd(u m)(u n)`**.
Once that is abstracted, the rank function and its spine are forced, and they specialize
verbatim to Fibonacci, to `aⁿ − 1`, and (with the strong-divisibility input swapped) to
any nondegenerate Lucas sequence.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `seqRank_spine` | `m ∣ u n ↔ seqRank u m ∣ n` for any strong divisibility sequence | proved |
| `isPrimitive_iff_seqRank_eq` | primitive at `n` ↔ `seqRank u p = n` | proved |
| `mer_dvd_iff_orderOf_dvd` | `m ∣ aⁿ − 1 ↔ orderOf (a : ZMod m) ∣ n` | proved |
| `seqRank_mer_eq_orderOf` | rank of apparition `= orderOf (a : ZMod m)` | proved |

Supporting, also proved: `IsStrongDivSeq.dvd_of_dvd`, `mer_isStrongDivSeq`,
`mer_hasRank_of_coprime` (existence via Euler's totient), `fib_isStrongDivSeq`.

## Research Directions

### 1. A typeclass `StrongDivisibilitySequence` that absorbs Fibonacci, Mersenne, and Lucas at once

The four catalog files developing apparition theory each re-prove the same lemmas for
their own sequence. The conjecture is operational: bundling `IsStrongDivSeq u`, `u 0 = 0`,
`u 1 = 1`, and a `HasRank`-totality field into a single typeclass yields an interface from
which `seqRank_spine`, `isPrimitive_iff_seqRank_eq`, the lattice meet/join laws, and the
densit
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
