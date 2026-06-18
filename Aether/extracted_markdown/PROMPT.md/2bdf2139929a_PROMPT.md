
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

**Title**: This cycle delivered `Catalog/Bridges/ApparitionOrderBridge.lean`, a self-contai
**Domain**: Novelty
**Mathematical framing**: # Future Directions — The Apparition–Order Bridge (Local-to-Global / Sheaves cycle)

## Synthesis

This cycle delivered `Catalog/Bridges/ApparitionOrderBridge.lean`, a self-contained,
`sorry`-free file that **reduces a global arithmetic invariant to a single stalk-level
group computation**. Concretely, for the Mersenne / Bang–Zsygmondy family
`a(n) = bⁿ − 1`, the *entry point* (rank of apparition) of a prime `p` — defined globally
as `Nat.find` over **all** indices `k` with `p ∣ a(k)` — is proven equal to the
*multiplicative order of `b` in the residue field* `ZMod p`:

> `mersenne_entryPoint_eq_orderOf : entryPoint (bⁿ−1) p = orderOf (b : ZMod p)`  (for `p ∤ b`).

This is the local-to-global program in miniature: the apparition data forms a "support
sheaf" `n ↦ {p : p ∣ a(n)}` over the index semigroup `(ℕ, +)`, and the bridge shows the
sheaf's global sections are completely determined by the *stalk order* at each prime. Two
global theorems fall out for free — `support_eq_multiples` (the support is the principal
arithmetic progression generated by the entry point) and `mersenne_entryPoint_dvd_sub_one`
(Fermat descent: the entry point divides `p − 1`). The Fibonacci specialization
`fib_support_eq_multiples` ties the result back to the catalog's Carmichael
primitive-divisor program (`StrongDivisibilityEntryPoint.lean`,
`StrongDivPrimitiveCriterion.lean`, `CarmichaelProof.lean`).

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `dvd_iff_entryPoint_dvd` | `p ∣ a n ↔ entryPoint a p ∣ n` for strong divisibility sequences | proved |
| `support_eq_multiples` | apparition support = principal progression generated by entry point | proved |
| `pow_sub_one_dvd_iff_orderOf` | `p ∣ bⁿ − 1 ↔ (b : ZMod p)ⁿ = 1` (stalk reduction) | proved |
| `mersenne_entryPoint_eq_orderOf` | **entry point = `orderOf (b : ZMod p)`** | proved |
| `mersenne_entryPoint_dvd_sub_one` | entry point divides `p − 1` (Fermat descent) | proved |
| `fib_support_eq_multiples` | Fibonacci specialization of the gluing theorem | proved |

All results are `sorry`-free and depend only on `Mathlib` (axioms: `propext`,
`Classical.choice`, `Quot.sound`).

---

## Direction 1 — The Fibonacci stalk: entry point = order of the companion matrix mod p

**Conjecture.** For a prime `p` with `p ∤ 5`, `entryPoint Nat.fib p` equals the
multiplicative order of the Fibonacci companion matrix `Q = !![1,1;1,0]` in
`GL₂(ZMod p)` (equivalently, the order of the golden-ratio image in `(ZMod p)[x]/(x²−x−1)`).

The key insight is that the Apparition–Order Bridge proved here for `bⁿ − 1` is the
*rank-1* shadow of a *rank-2* phenomenon: Fibonacci is the (1,2)-entry of `Qⁿ`, so
`p ∣ Fₙ ↔ Qⁿ ≡ (scalar) (mod p)`, turning the global Fibonacci entry point into the order
of a single matrix in a finite group — the stalk at `p` is now `GL₂(ZMod p)` rather than
`(ZMod p)ˣ`. Why now? The present file already supplies every abstract lemma
(`dvd_iff_entryPoint_dvd`, `support_eq_multiples`) over arbitrary strong divisibility
sequences; only the *stalk identification* `pow_sub_one_dvd_iff_orderOf` needs a 2×2
analogue, which Mathlib's `Matrix.GeneralLinearGroup` and `ZMod` field structure make
directly reachable. Falsifiable: a single counterexample prime `p` where the matrix order
and `entryPoint Nat.fib p` disagree refutes it.

## Direction 2 — CRT gluing: composite-modulus entry points are local lcm's

**Conjecture.** For `m` coprime to `b`, `entryPoint (bⁿ − 1) m = Nat.lcm` over the prime
powers `q ∥ m` of the *local* entry points `entryPoint (bⁿ − 1) q`, and the latter equals
`orderOf (b : ZMod q)` = the multiplicative order modulo `q` (Carmichael's `λ`-function
controlling the maximum).

The key insight is that the support sheaf glues across the prime stalks of `Spec ℤ` exactly
as the Chinese Remainder Theorem decomposes `ZMod m ≃ ∏ ZMod qᵢ`: a global apparition index
must be a common period of all local orders, i.e. their lcm. Why now? `support_eq_multiples`
already exhibits each local support as a principal progression; gluing principal progressions
under intersection is precisely `lcm`, and Mathlib's `ZMod.chineseRemainder` provides the
ring isomorphism needed to push `mersenne_entryPoint_eq_orderOf` through each factor.
Falsifiable: check `entryPoint (2ⁿ−1) 15` against `lcm (orderOf (2:ZMod 3)) (orderOf (2:ZMod 5))`.

## Direction 3 — A cohomological obstruction class for Zsygmondy exceptions

**Conjecture.** The finite exceptional sets of the primitive-divisor theorems — `{1,2,6,12}`
for Fibonacci, `{6}` for `2ⁿ − 1`, `{1,2}`-type sets for general `bⁿ − 1` — are exactly the
support of a degree-1 obstruction class in a Čech-style `H¹` of the apparition presheaf:
the class vanishes iff `aₙ` has a prime whose stalk order is *maximal* (equals `n`).

The key insight is that "having a primitive divisor at `n`" is a *local-to-global lifting*
problem — a prime with `entryPoint = n` is a global section restricting correctly at every
proper divisor stalk — and its failure is measured cohomologically rather than case-by-case.
Why now? The catalog already isolates the exceptions computationally
(`mersenne_bang_band` flags `n = 6`; `fib_twelve_no_primitive` flags `12`), and
`support_eq_multiples` provides the restriction maps `n ↦ d` for `d ∣ n`; assembling these
into a presheaf and proving the vanishing criterion is now a finite, mechanizable bookkeeping
task. Falsifiable: the conjecture predicts **no** exception with two distinct prime stalk
orders both maximal — exhibiting such an `n` would refute the `H¹` interpretation.

## Direction 4 — Primitive divisors of `bⁿ − 1` are ≡ 1 (mod n), with a quantitative floor

**Conjecture.** Every primitive prime divisor `p` of `bⁿ − 1` satisfies `n ∣ p − 1` (hence
`p ≡ 1 mod n` and `p ≥ n + 1`), and the *smallest* primitive divisor is `O(n log n)` for
fixed `b`.

The key insight is an immediate consequence of this cycle's `mersenne_entryPoint_dvd_sub_one`
combined with `primitive ↔ entryPoint = n`: primitivity forces `entryPoint = n`, and Fermat
descent forces `entryPoint ∣ p − 1`, so `n ∣ p − 1` is a one-line corollary waiting to be
stated. Why now? Both ingredients are already proven in the file; the qualitative half
(`n ∣ p − 1`) is essentially free, and only the quantitative floor needs analytic number
theory (Linnik-type bounds) to attack. Falsifiable: search any primitive divisor `p` of
`2ⁿ − 1` with `n ∤ p − 1`.

## Direction 5 — Closing the infinite tail of Fibonacci–Carmichael

**Conjecture.** The open `sorry` in `Catalog/Shared/CarmichaelProof.lean`
(`fib_carmichael_composite` for composite `n > 10000`) is provable `sorry`-free by combining
(a) the cyclotomic factorization `Fₙ = ∏_{d∣n} Φ_d` of the "primitive part", (b) a
lifting-the-exponent bound on the unique non-primitive prime power, and (c) the growth bound
`Φ_n ≥ φ^{ϕ(n)/2}` which exceeds `n` for `n > 12`.

The key insight is that the Apparition–Order Bridge reduces "primitive divisor exists" to
"the primitive part `Φ_n` is not a prime-power dividing `n`", a purely *size* comparison once
the order-theoretic structure is in place — the global existence statement becomes a local
inequality at the single ramified prime. Why now? The catalog already discharges the entire
band `13 ≤ n ≤ 10000` by `native_decide` (`primPart_check`), so only the asymptotic tail
remains; with `support_eq_multiples` and `mersenne_entryPoint_dvd_sub_one` formalized, the
remaining work is a self-contained growth estimate that does not require importing Zsygmondy
wholesale. Falsifiable: any composite `n > 12` for which `Φ_n` is a power of a prime dividing
`n` would break the argument (none is conjectured to exist).

Research domain: Novelty
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
# Future Directions — The Apparition–Order Bridge (Local-to-Global / Duality cycle)

## Synthesis

This cycle delivered `Catalog/Bridges/ApparitionOrderBridge.lean`, a `sorry`-free file that
**represents a global arithmetic invariant as a single stalk-level group computation**. It is
the duality/representation companion to the existing
`Catalog/Bridges/StrongDivisibilitySequences.lean`, which it imports and extends rather than
reproves.

For the Mersenne / repunit family `a(n) = bⁿ − 1` (the `mersenneSDS b` instance of the
catalog's `StrongDivSeq`), the *entry point* (rank of apparition) of a prime `p` — defined
globally by `StrongDivSeq.entryPoint` as `Nat.find` over **all** indices `k > 0` with
`p ∣ a k` — is proven equal to the *multiplicative order of `b` in the residue field*
`ZMod p`:

> `mersenne_entryPoint_eq_orderOf : (mersenneSDS b).entryPoint p = orderOf (b : ZMod p)` (for `p ∤ b`).

This is the local-to-global program in miniature. The apparition data forms a "support sheaf"
`n ↦ {p : p ∣ a n}` over the additive index semigroup `(ℕ, +)`, and the bridge shows the
sheaf's global sections are completely determined by the *stalk order* at each prime. Two
global theorems fall out for free: `support_eq_multiples` (the support is the principal
arithmetic progression generated by the entry point) and `mersenne_entryPoint_dvd_sub_one`
(Fermat descent: the entry point divides `p − 1`). The Fibonacci specialization
`fib_support_eq_multiples` ties the result back to the catalog's Carmichael primitive-divisor
program (`Shared.CarmichaelProof`, `Shared.FibonacciApparitionSheaf`).

The unifying dual translation is: `entryPoint` is the dictionary between the divisibility
lattice of **indices** `n` and divisibility on the integer side, and the *bridge* identifies
its value at a prime stalk with a purely *multiplicative* invariant — the group order in
`(ZMod p)ˣ`. Global divisibility data ⟷ local representation-theoretic order data.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `support_eq_multiples` | `{n \| p ∣ s.a n} = {n \| entryPoint p ∣ n}` for any `StrongDivSeq` | proved |
| `pow_sub_one_dvd_iff_pow_eq_one` | `p ∣ bⁿ − 1 ↔ (b : ZMod p)ⁿ = 1` (stalk reduction) | proved |
| `mersenne_entryPoint_eq_orderOf` | **entry point = `orderOf (b : ZMod p)`** | proved |
| `mersenne_entryPoint_dvd_sub_one` | entry point divides `p − 1` (Fermat descent) | proved |
| `fib_support_eq_multiples` | Fibonacci specialization of the gluing theorem | proved |

All results are `sorry`-free and depend only on `Mathlib` (plus the imported catalog file);
axioms used are exactly `propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — The Fibonacci stalk: entry point = order of the companion matrix mod p

**Conjecture.** For a prime `p` with `p ∤ 5`, `fibSDS.entryPoint p` equals the multiplicative
order of the Fibonacci companion matrix `Q = !![1,1;1,0]` in `GL₂(ZMod p)` (equivalently, the
order of the golden-ratio image in `(ZMod p)[x]/(
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
