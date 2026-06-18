
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

**Title**: This cycle isolated the *primitivity* layer of Fibonacci divisibility theory and
**Domain**: Algebra
**Mathematical framing**: # Future Directions — Fibonacci primitive divisors and apparition

## Synthesis

This cycle isolated the *primitivity* layer of Fibonacci divisibility theory and showed
that almost all of its structural content flows from a single elementary fact: the
Fibonacci sequence is a **strong divisibility sequence** (`Nat.fib_gcd`,
`Nat.fib_dvd`).  The catalog already develops the *rank of apparition* (`entryPoint`)
via `Nat.find` and studies its lattice behaviour over moduli
(`Catalog/Applications/FibonacciEntryPoints.lean`,
`Catalog/Applications/FibonacciApparitionLattice.lean`).  We deliberately took the
*opposite* route: a fully self-contained file
(`Catalog/Applications/FibonacciPrimitiveDivisors.lean`) that never computes an entry
point and instead reasons directly with `gcd`/`lcm` of indices.  The pay-off is that the
key rigidity theorem — a value is a primitive divisor of at most one positive index —
collapses to a one-line minimality clash (`isPrimitive_unique`), and the law that a
primitive divisor pins the whole divisibility set to the multiples of its index
(`dvd_fib_iff_index_dvd_of_primitive`) follows straight from the sharp meet law
`fib_dvd_gcd_iff` (`d ∣ F_{gcd m n} ↔ d ∣ F_m ∧ d ∣ F_n`, valid for *any* divisor `d`).

From these we obtained the "join" law: the common-apparition set of two primitive
divisors is itself an apparition class governed by the lcm of their indices
(`simultaneous_apparition`), and — beyond the originally-planned conjecture — its full
finite-family generalization `simultaneous_apparition_finset`, proved by `Finset`
induction.  The structural insight is that the map *modulus ↦ {indices where it divides
`F`}* is an isomorphism from the divisibility lattice of "active" moduli onto a sublattice
of `(ℕ, gcd, lcm)`; primitivity is exactly the property of sitting at a *generator* of
such a multiples-ideal.

What did *not* get done: the genuinely deep gap in the catalog remains the infinite tail
of Carmichael's primitive-divisor theorem (`Catalog/Shared/CarmichaelProof.lean` discharges
`13 ≤ n ≤ 10000` by `native_decide` but leaves composite `n > 10000` as `sorry`).  Our
results are precisely the *combinatorial backbone* such a proof needs (they reduce
"`p` is primitive for `F_n`" to a clean statement about indices), but the analytic
existence step — that a primitive divisor *exists* for every `n ≥ 13` except `n ∈ {1,2,6,12}`
— is not addressed here and is the natural next target.

## Results Summary

- `fib_dvd_gcd_iff`: proved — the sharp strong-divisibility meet law `d ∣ F_{gcd m n} ↔ d ∣ F_m ∧ d ∣ F_n` for an arbitrary divisor `d`.
- `isPrimitive_zero_everything`: proved — boundary fact that every modulus is vacuously primitive at index `0`, pinning down why positivity is required elsewhere.
- `isPrimitive_unique`: proved — a value is a primitive divisor of at most one positive index, so the rank of apparition is a well-defined labelling.
- `dvd_fib_iff_index_dvd_of_primitive`: proved — a primitive divisor `p` of `F_n` divides exactly the Fibonacci numbers at multiples of `n` (`p ∣ F_m ↔ n ∣ m`).
- `simultaneous_apparition`: proved — the join law `(p ∣ F_n ∧ q ∣ F_n) ↔ lcm a b ∣ n` for primitive divisors of `F_a`, `F_b`.
- `simultaneous_apparition_finset`: proved — finite-family generalization of the join law via `Finset` induction.

## Research Directions

### Direction 1: Existence of primitive divisors (the Carmichael tail)
**Hypothesis**: For every `n ≥ 13`, `F_n` has a primitive prime divisor (equivalently, the
`sorry` for composite `n > 10000` in `Catalog/Shared/CarmichaelProof.lean` is true).
**Test**: Prove it by bounding the primitive part `Φ_n` (the product of primitive prime
powers) from below using the Lucas/cyclotomic factorization `F_n = ∏_{d ∣ n} Φ_d` and the
fact that intrinsic (non-primitive) prime factors are bounded; then `Φ_n > 1` forces a
primitive divisor.  A disproof would be a single counterexample `n` with `Φ_n = 1`.
**Why now**: Our `dvd_fib_iff_index_dvd_of_primitive` and `isPrimitive_unique` already
reduce "primitive divisor of `F_n`" to "prime with entry point exactly `n`", so the missing
ingredient is purely the size estimate, not the divisibility bookkeeping.
**If true**: closes the headline open `sorry` in the catalog and yields the classical
Carmichael theorem in full.
**If false**: would contradict known mathematics, so any "counterexample" instead pinpoints
a modelling error in the formal statement — valuable as a correctness check.

### Direction 2: Entry point divides `p − (5/p)` (the quadratic-residue law)
**Hypothesis**: For a prime `p ≠ 5`, the entry point `e(p)` divides `p − (5/p)`, where
`(5/p)` is the Legendre symbol; in particular `e(p) ≤ p + 1`.
**Test**: Formalize `F_p ≡ (5/p) (mod p)` and `F_{p−(5/p)} ≡ 0 (mod p)` via the
matrix/`Nat.fib` doubling identities, then apply `dvd_fib_iff_index_dvd_of_primitive` to
convert the congruence into `e(p) ∣ p − (5/p)`.
**Why now**: `dvd_fib_iff_index_dvd_of_primitive` is exactly the converter from "`p ∣ F_k`"
to "`e(p) ∣ k`"; once the single congruence `p ∣ F_{p−(5/p)}` is in hand, the divisibility
of the entry point is immediate.
**If true**: gives an effective upper bound on entry points and a fast primality-style test.
**If false**: would expose a missing hypothesis (e.g. excluding `p = 5`), refining the law.

### Direction 3: Abstract strong divisibility sequences
**Hypothesis**: Every theorem in `FibonacciPrimitiveDivisors` holds verbatim for *any*
sequence `u : ℕ → ℕ` satisfying `u (gcd m n) = gcd (u m) (u n)` (a strong divisibility
sequence), e.g. `u n = a^n − 1` or general Lucas sequences `U_n`.
**Test**: Abstract `Nat.fib` to a hypothesis `StrongDiv u` and re-derive `fib_dvd_gcd_iff`,
`isPrimitive_unique`, `dvd_fib_iff_index_dvd_of_primitive`, and the join laws; check the
`a^n − 1` instance against Mathlib's `Nat.sub_one_dvd_sub_of_dvd_sub`-style lemmas.
**Why now**: our proofs already use *only* `Nat.fib_gcd`/`Nat.fib_dvd`, so the generalization
is a mechanical replacement of one lemma by a typeclass/hypothesis — the math is done.
**If true**: a single reusable module subsumes Fibonacci, Mersenne, and Lucas apparition
theory, a genuine cross-domain consolidation of the catalog.
**If false** (some instance breaks): identifies exactly which extra axiom (e.g. `u 1 = 1`,
or strict monotonicity) the Fibonacci proofs silently relied on.

### Direction 4: The apparition lattice is an order isomorphism
**Hypothesis**: The map `Φ : a ↦ entryPoint a`, restricted to moduli that divide some `F_k`,
is an injective lattice homomorphism for the *join* (`lcm`) but only a lax morphism for the
*meet* (`gcd`), and its image is exactly the set of `n` such that `F_n` has a primitive
divisor with that entry point.
**Test**: Combine the catalog's `fibEntry_lcm` and `fibEntry_gcd_not_exact`
(`FibonacciApparitionLattice.lean`) with our `isPrimitive_unique` to prove injectivity on
the relevant domain and characterize the image; the boundary case `a = 4, b = 6` already
witnesses meet-failure.
**Why now**: the join law is proved here and the meet counterexample is proved in the
catalog; `isPrimitive_unique` supplies the injectivity that ties them into a single
structural statement.
**If true**: a clean categorical description of the rank of apparition as a lattice map.
**If false**: the failure locates a second exceptional index beyond `12` where injectivity
or surjectivity breaks.

### Direction 5: Counting simultaneous apparitions (density)
**Hypothesis**: For fixed primitive divisors `p` of `F_a` and `q` of `F_b`, the number of
indices `n ≤ N` with `p ∣ F_n ∧ q ∣ F_n` is exactly `⌊N / lcm(a,b)⌋`, and more generally the
density of common-apparition indices of a finite family equals `1 / lcm(g i)`.
**Test**: Turn `simultaneous_apparition` / `simultaneous_apparition_finset` into a counting
statement via `Nat.Ioc`/`Finset.filter` cardinalities of multiples of a fixed modulus
(`Nat.card_multiples`-style lemmas), then take the limit.
**Why now**: the iff with `lcm a b ∣ n` reduces the count to "multiples of a fixed number in
`[1, N]`", which Mathlib counts exactly — so this is a packaging of an already-proved
equivalence into quantitative form.
**If true**: gives explicit densities for joint Fibonacci divisibility, connecting the
apparition lattice to analytic number theory.
**If false**: a discrepancy would reveal an off-by-one in how the empty family or `n = 0` is
counted, sharpening the statement.

Research domain: Algebra
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/StrongDivisibilitySequences.lean
import Mathlib

/-! # Strong divisibility sequences: abstract primitive divisors and apparition

Domain: Algebra / Number Theory (Applications).

This file **generalizes** the Fibonacci-specific results of
`Catalog/Applications/FibonacciPrimitiveDivisors.lean` to *arbitrary strong divisibility
sequences*.  A sequence `u : ℕ → ℕ` is a **strong divisibility sequence** (`IsStrongDivSeq`)
when `u (gcd m n) = gcd (u m) (u n)` for all `m, n`.  The Fibonacci file used **only** the
two facts `Nat.fib_gcd` and `Nat.fib_dvd`; both are instances of this single hypothesis, so
the entire primitivity/apparition theory lifts verbatim.  This realizes **Direction 3** of the
previous cycle's `FUTURE_DIRECTIONS.md` ("Abstract strong divisibility sequences") and, via the
counting corollaries, **Direction 5** ("Counting simultaneous apparitions / density").

Two concrete instances are recorded:

* `fib_isStrongDivSeq`     — the Fibonacci sequence `Nat.fib` (from `Nat.fib_gcd`); this
  recovers every result of `FibonacciPrimitiveDivisors`.
* `mersenne_isStrongDivSeq`— the sequence `n ↦ a ^ n - 1` (from
  `Nat.pow_sub_one_gcd_pow_sub_one`), i.e. the Mersenne / `aⁿ−1` family.

Main results (all stated for an arbitrary `u`):

* `IsStrongDivSeq.dvd_of_dvd`         — `m ∣ n → u m ∣ u n` (the weak divisibility law).
* `IsStrongDivSeq.dvd_gcd_index_iff`  — the sharp meet law `d ∣ u (gcd m n) ↔ d ∣ u m ∧ d ∣ u n`.
* `isPrimitive_unique`                — a value is primitive for at most one positive index.
* `dvd_iff_index_dvd_of_primitive`    — a primitive divisor pins divisibility to multiples of its index.
* `simultaneous_apparition`           — the join law `(p ∣ u n ∧ q ∣ u n) ↔ lcm a b ∣ n`.
* `simultaneous_apparition_finset`    — the finite-family generalization.
* `apparition_count`                  — `#{e < N : p ∣ u (e+1)} = N / n` (density `1/n`).
* `simultaneous_apparition_count`     — `#{e < N : p ∣ u(e+1) ∧ q ∣ u(e+1)} = N / lcm a b`.
-/

namespace StrongDivSeq

/-- A **strong divisibility sequence**: `u (gcd m n) = gcd (u m) (u n)` for all `m, n`.
Both `Nat.fib` and `n ↦ aⁿ − 1` satisfy this. -/
def IsStrongDivSeq (u : ℕ → ℕ) : Prop :=
  ∀ m n, u (Nat.gcd m n) = Nat.gcd (u m) (u n)

/-- `p` is a *primitive divisor* of `u n`: it divides `u n` but none of `u 1, …, u (n-1)`. -/
def IsPrimitive (u : ℕ → ℕ) (p n : ℕ) : Prop :=
  p ∣ u n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ u k

/-! ## §1. Elementary consequences of the strong-divisibility law -/

/-
!-- Lab Notebook: IsStrongDivSeq.dvd_of_dvd -- !--
!-- Hypothesis: A strong divisibility sequence is in particular a divisibility sequence:
`m ∣ n → u m ∣ u n` (generalizing `Nat.fib_dvd`). -- !--
!-- Result: Proved. `m ∣ n` gives `gcd m n = m`, so `u m = u (gcd m n) = gcd (u m) (u n)`
divides `u n` by `Nat.gcd_dvd_right`. -- !--
!-- Insight: The *weak* law (Mathlib's `Nat.fib_dvd`) is a free corollary of the *strong* law;
no extra hypothesis is needed. -- !--
!-- Failure analysis: none. -- !--
!-- End Lab Notebook -- !--
-/
theorem IsStrongDivSeq.dvd_of_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m n : ℕ}
    (h : m ∣ n) : u m ∣ u n := by
      -- Since m divides n, we know that gcd m n = m (by Nat.gcd_eq_left h).
      have h_gcd : Nat.gcd m n = m := by
        exact Nat.gcd_eq_left h;
      convert hu m n ▸ Nat.gcd_dvd_right _ _ using 1 ; aesop

/-
!-- Lab Notebook: IsStrongDivSeq.dvd_gcd_index_iff -- !--
!-- Hypothesis: For ANY divisor `d`, `d ∣ u (gcd m n) ↔ d ∣ u m ∧ d ∣ u n`
(generalizing `FibonacciPrimitiveDivisors.fib_dvd_gcd_iff`). -- !--
!-- Result: Proved by rewriting with the strong-divisibility law and `Nat.dvd_gcd_iff`. -- !--
!-- Insight: This is the lattice "meet" law at the level of raw divisors, valid in every
strong divisibility sequence. -- !--
!-- Failure analysis: none. -- !--
!-- End Lab Notebook -- !--
-/
theorem IsStrongDivSeq.dvd_gcd_index_iff {u : ℕ → ℕ} (hu : IsStrongDivSeq u) (d m n : ℕ) :
    d ∣ u (Nat.gcd m n) ↔ d ∣ u m ∧ d ∣ u n := by
      rw [ hu m n, Nat.dvd_gcd_iff ]

/-! ## §2. Rigidity: a value is primitive for at most one index -/

/-
!-- Lab Notebook: isPrimitive_zero_everything -- !--
!-- Hypothesis: Every modulus is vacuously primitive at index `0`. -- !--
!-- Result: Proved: `p ∣ u 0 ... ` need not hold for general `u`! Instead the minimality
clause is vacuous; but `p ∣ u 0` requires `u 0 = 0`. We therefore require `u 0 = 0`. -- !--
!-- Insight: For Fibonacci `u 0 = 0` automatically; in the abstract setting the boundary
fact needs `u 0 = 0` as a hypothesis, pinning down why positivity is required elsewhere. -- !--
!-- Failure analysis: dropping `u 0 = 0` makes index-0 primitivity fail. -- !--
!-- End Lab Notebook -- !--
-/
theorem isPrimitive_zero_everything {u : ℕ → ℕ} (h0 : u 0 = 0) (p : ℕ) :
    IsPrimitive u p 0 := by
      exact ⟨ h0.symm ▸ dvd_zero _, by intros; linarith ⟩

/-
!-- Lab Notebook: isPrimitive_unique -- !--
!-- Hypothesis: A value cannot be a primitive divisor of two different positive indices. -- !--
!-- Result: Proved by a direct minimality clash; NO strong-divisibility hypothesis needed.
If `m < n`, primitivity at `n` forbids `p ∣ u m`, contradicting primitivity at `m`. -- !--
!-- Insight: Primitivity is so rigid that uniqueness is immediate from the definition. -- !--
!-- Failure analysis: index 0 must be excluded (see isPrimitive_zero_everything). -- !--
!-- End Lab Notebook -- !--
-/
theorem isPrimitive_unique {u : ℕ → ℕ} {p m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hpm : IsPrimitive u p m) (hpn : IsPrimitive u p n) : m = n := by
      grind +locals

/-! ## §3. A primitive divisor pins down the divisibility set -/

/-
!-- Lab Notebook: dvd_iff_index_dvd_of_primitive -- !--
!-- Hypothesis: If `p` is primitive for `u n` then `p ∣ u m ↔ n ∣ m`
(generalizing `FibonacciPrimitiveDivisors.dvd_fib_iff_index_dvd_of_primitive`). -- !--
!-- Result: Proved. Backward: `n ∣ m → u n ∣ u m` (`dvd_of_dvd`), and `p ∣ u n`.
Forward: from `p ∣ u m, u n` get `p ∣ u (gcd n m)` (meet law); minimality forces
`gcd n m = n`, i.e. `n ∣ m`. -- !--
!-- Insight: Primitivity upgrades the abstract apparition law to a concrete divisibility
test, derived straight from the meet law. -- !--
!-- Failure analysis: needs the strong-divisibility hypothesis (for the meet law) and `0<n`. -- !--
!-- End Lab Notebook -- !--
-/
theorem dvd_iff_index_dvd_of_primitive {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p n : ℕ}
    (hn : 0 < n) (hp : IsPrimitive u p n) (m : ℕ) :
    p ∣ u m ↔ n ∣ m := by
      constructor;
      · intro hpm
        have h_gcd : p ∣ u (Nat.gcd n m) := by
          exact hu.dvd_gcd_index_iff p n m |>.2 ⟨ hp.1, hpm ⟩
        have h_gcd_eq : Nat.gcd n m = n := by
          exact Classical.not_not.1 fun h => hp.2 _ ( Nat.gcd_pos_of_pos_left _ hn ) ( lt_of_le_of_ne ( Nat.le_of_dvd hn ( Nat.gcd_dvd_left _ _ ) ) h ) h_gcd
        exact h_gcd_eq ▸ Nat.gcd_dvd_right _ _;
      · exact fun h => dvd_trans hp.1 ( hu.dvd_of_dvd h )

/-! ## §4. Simultaneous apparition: the join law -/

/-
!-- Lab Notebook: simultaneous_apparition -- !--
!-- Hypothesis: For primitive divisors `p` (of `u a`) and `q` (of `u b`), both divide `u n`
exactly at the multiples of `lcm a b`. -- !--
!-- Result: Proved: rewrite each conjunct via `dvd_iff_index_dvd_of_primitive`, then
`Nat.lcm_dvd_iff`. -- !--
!-- Insight: The common-apparition set of two primitive divisors is itself an apparition
class governed by the lcm of the two indices. -- !--
!-- Failure analysis: both indices must be positive. -- !--
!-- End Lab Notebook -- !--
-/
theorem simultaneous_apparition {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p q a b n : ℕ}
    (ha : 0 < a) (hb : 0 < b) (hp : IsPrimitive u p a) (hq : IsPrimitive u q b) :
    (p ∣ u n ∧ q ∣ u n) ↔ Nat.lcm a b ∣ n := by
      grind +suggestions

/-
!-- Lab Notebook: simultaneous_apparition_finset -- !--
!-- Hypothesis: For a finite family with each `f i` primitive for `u (g i)`, all `f i`
divide `u n` iff the lcm of the indices `g i` divides `n`
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Strong divisibility sequences, primitive divisors, and apparition density

## Synthesis

This cycle executed **Direction 3** ("Abstract strong divisibility sequences") and
**Direction 5** ("Counting simultaneous apparitions / density") of the previous Fibonacci
cycle, and showed that the entire primitivity/apparition layer of Fibonacci divisibility
theory depends on *one* algebraic axiom, not on Fibonacci at all. We isolated the property
`IsStrongDivSeq u : u (gcd m n) = gcd (u m) (u n)` and re-derived, verbatim and for an
arbitrary `u : ℕ → ℕ`, the whole structural backbone of
`Catalog/Applications/FibonacciPrimitiveDivisors.lean`: the weak divisibility law
(`IsStrongDivSeq.dvd_of_dvd`, a *free corollary* of the strong law that recovers Mathlib's
`Nat.fib_dvd`), the sharp meet law (`IsStrongDivSeq.dvd_gcd_index_iff`), rigidity of
primitive divisors (`isPrimitive_unique`), the pinning law
(`dvd_iff_index_dvd_of_primitive`), and the join laws
(`simultaneous_apparition`, `simultaneous_apparition_finset`). The new file is
`Catalog/Applications/StrongDivisibilitySequences.lean`.

The structural insight is sharper than expected: the *only* place Fibonacci-specific input
ever enters is the two-line instance `fib_isStrongDivSeq` (from `Nat.fib_gcd`). Swapping it
for `mersenne_isStrongDivSeq` (from `Nat.pow_sub_one_gcd_pow_sub_one`) instantly transports
every theorem to the `aⁿ − 1` family — a genuine cross-domain consolidation that subsumes
Fibonacci and Mersenne apparition theory under a single signature. A subtle boundary
emerged at index `0`: `isPrimitive_zero_everything` now requires an explicit `u 0 = 0`
hypothesis, because the abstract setting cannot assume the Fibonacci coincidence `F₀ = 0`.
This pins down precisely the extra fact the original Fibonacci proofs silently used.

Beyond Direction 3 we also realized Direction 5 quantitatively: `apparition_count` proves
that exactly `N / n` of the first `N` positive indices are apparition indices of a primitive
divisor of index `n`, and `simultaneous_apparition_count` gives `N / lcm a b` for the joint
case — both by converting the divisibility predicate to a multiples-count via
`Nat.card_multiples`. This turns the qualitative iff `lcm a b ∣ n` into an exact lattice-point
count, the natural bridge from the apparition lattice to analytic density. What remains
untouched is still the deep analytic core: the *existence* of primitive divisors (the
Carmichael tail) is a size estimate, not a divisibility fact, and none of the abstract
machinery here produces it.

## Results Summary

- `IsStrongDivSeq` (def): proved/defined — the single axiom `u (gcd m n) = gcd (u m) (u n)` from which all results below flow.
- `IsStrongDivSeq.dvd_of_dvd`: proved — `m ∣ n → u m ∣ u n`; the weak divisibility law is a free corollary of the strong one.
- `IsStrongDivSeq.dvd_gcd_index_iff`: proved — the sharp meet law `d ∣ u (gcd m n) ↔ d ∣ u m ∧ d ∣ u n` for arbitrary divisor `d`.
- `isPrimitive_zero_everythin
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
