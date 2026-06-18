
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

**Title**: This cycle formalized the Fibonacci **rank of apparition** as a *local-to-global
**Domain**: Applications
**Mathematical framing**: # FUTURE_DIRECTIONS.md — Fibonacci Apparition as a Local-to-Global Sheaf

## Synthesis

This cycle formalized the Fibonacci **rank of apparition** as a *local-to-global sheaf*
over the divisibility site of moduli, and proved four theorems with **zero `sorry`**
(`Catalog/Shared/FibonacciApparitionSheaf.lean`, axioms: `propext`, `Classical.choice`,
`Quot.sound` only):

1. **`fib_dvd_iff_fibRank_dvd`** — the *law of apparition* `m ∣ F n ↔ rank m ∣ n`, proved
   from scratch. Existence of the rank is obtained not analytically but *structurally*: the
   Fibonacci shift `(a,b) ↦ (b, a+b)` is an honest **permutation** of the finite type
   `(ZMod m)²` (its inverse `(a,b) ↦ (b−a, a)` encodes the reversibility
   `F(k−1) = F(k+1) − F(k)`), so it has finite order and its orbit through `(0,1)` must
   return — forcing some positive `F k ≡ 0 (mod m)`.
2. **`isPrimitive_iff_fibRank_eq`** — the *Carmichael bridge*: a prime `p` is a **primitive
   divisor** of `F n` iff `rank p = n`. This recasts the global primitive-divisor statement
   (`Shared.CarmichaelProof.fib_carmichael_composite`, `bridge_lemma`) as a purely local,
   stalk-level condition: primitivity *is* rank-maximality.
3. **`fibRank_mul_coprime`** — CRT *gluing of stalks*: `rank(ab) = lcm(rank a, rank b)` for
   coprime `a, b`.
4. **`fibRank_eq_factorization_lcm`** — the *full local-to-global reconstruction*:
   `rank n = lcm_{p ∈ supp(n)} rank(p^{v_p(n)})`. The global rank is the section glued from
   the prime-power **stalk** ranks; this strictly generalizes the binary gluing law (3) to
   the entire prime decomposition.

The catalog already records parallel rank developments (`RankOfApparition`,
`FibonacciApparitionLattice`, `FibonacciEntryPoints`, ...). The new layer here is the
explicit **sheaf framing** — primitivity-as-rank-maximality (the bridge to Carmichael) and
the prime-power reconstruction of the global rank — which those threads did not isolate.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_dvd_iff_fibRank_dvd` | `m ∣ F n ↔ rank m ∣ n` (`m>0`) | proved |
| `isPrimitive_iff_fibRank_eq` | `IsPrimitiveDivisor p n ↔ rank p = n` | proved |
| `fibRank_mul_coprime` | `rank(ab) = lcm(rank a, rank b)`, `Coprime a b` | proved |
| `fibRank_eq_factorization_lcm` | `rank n = lcm_{p} rank(p^{v_p(n)})` | proved |

## Research Directions (falsifiable)

### Direction 1 — Close the infinite tail of Fibonacci Carmichael via the stalk bridge.
`Shared.CarmichaelProof.fib_carmichael_composite` proves a primitive divisor exists for
composite `13 ≤ n ≤ 10000` by `native_decide`, and leaves the tail `n > 10000` as `sorry`.
**Conjecture:** for every composite `n ≥ 13` there is a prime `p` with
`isPrimitive_iff_fibRank_eq p n`, i.e. `rank p = n`, and this can be produced *uniformly*
from a Lifting-the-Exponent bound on the primitive part
`primPart n = F n / ∏_{d<n, d∣n} (local factors)`. **The key insight is** that
`isPrimitive_iff_fibRank_eq` converts "primitive divisor exists" into "some prime has rank
exactly `n`", and a prime fails to have rank `n` only if it divides an earlier `F d`
(`d ∣ n`, `d < n`); LTE bounds the total multiplicity those primes can carry, so once
`F n` is large enough the primitive part exceeds 1. **Why now?** The stalk bridge proved
this cycle is exactly the reformulation needed to replace the `native_decide` tail with an
analytic `v_p` estimate, and the catalog already has an LTE-for-Fibonacci file to draw on.

### Direction 2 — The meet (gcd) obstruction is a measurable cohomological defect.
The join law `rank(lcm a b) = lcm(rank a, rank b)` is exact, but the meet law fails:
`rank(gcd a b) ∣ gcd(rank a, rank b)` is strict in general (catalog `a=4, b=6`).
**Conjecture:** the defect `δ(a,b) := gcd(rank a, rank b) / rank(gcd a b)` is *multiplicative
in the prime stalks* and equals `1` exactly when no prime simultaneously sub-divides the two
ranks beyond their gcd — i.e. `δ` is the order of a 1-cocycle obstruction to the rank being a
lattice homomorphism. **The key insight is** that `rank` is a join-morphism but not a
meet-morphism, and the *quotient* `δ` (not the gap) is the natural local invariant, computable
stalk-by-stalk from `fibRank_eq_factorization_lcm`. **Why now?** With the prime-power
reconstruction in hand, `δ(a,b)` reduces to a finite product over `supp(a) ∩ supp(b)`, making
the multiplicativity claim a concrete, decidable target.

### Direction 3 — Rank, Pisano period, and the global "period sheaf".
Let `π(m)` be the Pisano period (period of `F mod m`). Classically `rank m ∣ π m` and
`π m / rank m ∈ {1,2,4}`. **Conjecture:** the assignment `m ↦ π m` is the *global section* of
the same sheaf, with `π(lcm a b) = lcm(π a, π b)` and `π(p^{k+1}) = p · π(p^k)` for `p` not a
Wall–Sun–Sun prime; the ratio `π m / rank m` is locally constant on the prime stalks.
**The key insight is** that the shift permutation `fibStep m` already used to prove existence
has order *exactly* `π m`, so `π` is literally `orderOf (fibStep m)` — the same finite-group
datum that produced `rank`, only read globally instead of at `(0,1)`. **Why now?** `fibStep`
is defined and its order theory is in scope this cycle, so `π m = orderOf (fibStep m)` and the
gluing laws for `π` are immediate corollaries of permutation-group order arithmetic.

### Direction 4 — A presheaf of apparition over an arbitrary Lucas sequence, and its stalks.
Replace `F` by a non-degenerate Lucas sequence `U_n(P,Q)` (so `U_n` is a strong divisibility
sequence whenever `gcd(P,Q)=1`). **Conjecture:** every theorem of this cycle lifts verbatim —
existence via the shift `(a,b) ↦ (b, P·b − Q·a)` (a permutation of `(ZMod m)²` when
`gcd(Q,m)=1`), the law of apparition, the primitivity bridge, and the prime-power
reconstruction — giving a `rank_{P,Q}` presheaf on moduli coprime to `Q`. **The key insight
is** that the *only* property of `F` actually used above is that the recurrence matrix
`[[0,1],[1,1]]` is invertible mod `m`; for general `U`, the matrix `[[0,1],[−Q,P]]` is
invertible mod `m` exactly when `gcd(Q,m)=1`, which pins down the natural site of definition.
**Why now?** The proofs are already factored through `fibStep`'s invertibility and `fib_gcd`;
abstracting the `2×2` companion matrix is a mechanical generalization that immediately
multiplies the catalog's reach across all Lucas sequences.

### Direction 5 — Inverse problem: the fibers of `rank` and the image lattice.
`rank` maps the divisibility lattice of moduli to that of indices. **Conjecture:** for each
index `n` the fiber `{m | rank m = n}` has a maximum element `M(n) = ` the primitive part
`primPart n` of `F n` (every modulus of rank `n` divides `M(n)`), so the fiber is precisely
the divisor set of `M(n)` minus moduli of strictly smaller rank; and `n ↦ M(n)` is itself
multiplicative-up-to-gcd. **The key insight is** that `isPrimitive_iff_fibRank_eq` identifies
the fiber of `rank` at `n` with the divisors of `F n` that avoid all earlier `F d` — exactly
the primitive part — so the inverse image of the sheaf is governed by `primPart`, the object
the Carmichael file already computes. **Why now?** Both endpoints exist in the project this
cycle (`fibRank` here, `primPart` in `CarmichaelProof`), so the fiber description is a
falsifiable bridge between two already-formalized constructions.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Shared/FibonacciApparitionSheaf.lean
import Mathlib

/-! # The Fibonacci rank of apparition as a local-to-global sheaf

Domain: Number Theory / Applications (Duality & Representation).

The *rank of apparition* `rank m = fibRank m` of a modulus `m` is the least positive index
`k` with `m ∣ F k`.  This file develops `rank` as a **local-to-global section** over the
divisibility site of moduli.

Following the catalog convention (`Catalog/Applications/RankOfApparition.lean`,
`Catalog/Novelty/FibApparitionExistence.lean`), the file is **self-contained against Mathlib**:
the short existence/biconditional *spine* (`fibStep`, `hasFibRank_of_pos`, `fibRank`,
`fibRank_dvd_iff`, `IsPrimitive`) is restated here, and the genuinely new layer is built on
top of it.  The four headline results are:

* `fib_dvd_iff_fibRank_dvd` — the **law of apparition** `m ∣ F n ↔ rank m ∣ n` (for `m > 0`),
  the global/local dictionary that drives everything else.
* `isPrimitive_iff_fibRank_eq` — the **Carmichael bridge / stalk condition**: `m` is a
  primitive divisor of `F n` iff `rank m = n`.  Primitivity *is* rank-maximality; this turns
  the global primitive-divisor statement into a purely local condition on a single stalk.
  (Compare `Shared.CarmichaelProof.bridge_lemma`, the global avoidance form.)
* `fibRank_mul_coprime` — **CRT gluing of stalks**: `rank (a*b) = lcm (rank a, rank b)` for
  coprime `a, b`.  (Compare `FibonacciApparitionLattice.fibEntry_lcm`, the join law in the
  parallel `fibEntry` thread.)
* `fibRank_eq_factorization_lcm` — the **full local-to-global reconstruction**:
  `rank n = lcm_{p ∈ supp n} rank (p ^ v_p n)`.  The global rank is the section glued from the
  prime-power stalk ranks; this strictly generalises the binary gluing law.

The unifying principle is *duality*: `rank` is the dictionary between the divisibility lattice
of **moduli** and the divisibility lattice of **indices**; it is an exact join-morphism
(lcm ↦ lcm), and the prime-power decomposition reconstructs the global section from local
stalks.
-/

namespace FibonacciApparitionSheaf

open scoped Classical

/-! ## §0. The spine (restated self-contained against Mathlib) -/

/-- `m` *has a rank of apparition* if it divides some positive-index Fibonacci number. -/
def HasFibRank (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ Nat.fib k

/-- The Fibonacci "shift" permutation on pairs over `ZMod m`: `(a, b) ↦ (b, a + b)`,
with inverse `(a, b) ↦ (b - a, a)`.  Its reversibility is the reason apparition occurs. -/
def fibStep (m : ℕ) : ZMod m × ZMod m ≃ ZMod m × ZMod m where
  toFun p := (p.2, p.1 + p.2)
  invFun p := (p.2 - p.1, p.1)
  left_inv := by intro p; simp
  right_inv := by intro p; simp [add_comm]

-- !-- Iterating the shift from `(0,1)` yields consecutive Fibonacci pairs; induction on `k`
-- using `F (k+2) = F k + F (k+1)`. -- !--
theorem fibStep_iterate (m k : ℕ) :
    (fibStep m)^[k] (0, 1) = ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m)) := by
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ]
  simp +decide [ fibStep, Nat.fib_add_two ]

/-
!-- Lab Notebook: hasFibRank_of_pos -- !--
!-- Hypothesis: Every positive modulus has a rank of apparition (apparition is total). -- !--
!-- Result: Pigeonhole on the finite set `(ZMod m)²`: two indices `i < j` share the pair
`(F·, F·₊₁) mod m`; back-stepping `i` to `0` via the reversible shift gives a positive
`k = j - i` with `m ∣ F k`. -- !--
!-- Insight: Reversibility of the Fibonacci shift (a unit-determinant matrix over `ZMod m`) is
the abstract Pisano-period mechanism; Mathlib has no Pisano theory, so this is built here. -- !--
!-- Failure analysis: the `m = 0` degenerate `ZMod` case must be split off (`cases m`). -- !--
!-- End Lab Notebook -- !--
-/
theorem hasFibRank_of_pos (m : ℕ) (hm : 0 < m) : HasFibRank m := by
  obtain ⟨i, j, hij, h_pair⟩ :
      ∃ i j : ℕ, i < j ∧
        ((Nat.fib i : ZMod m) = (Nat.fib j : ZMod m) ∧
          (Nat.fib (i + 1) : ZMod m) = (Nat.fib (j + 1) : ZMod m)) := by
    have h_pigeonhole :
        ∃ i j : ℕ, i < j ∧
          ((Nat.fib i : ZMod m), (Nat.fib (i + 1) : ZMod m))
            = ((Nat.fib j : ZMod m), (Nat.fib (j + 1) : ZMod m)) := by
      by_contra! h
      have h_finite :
          Set.Finite (Set.range
            (fun n : ℕ => ((Nat.fib n : ZMod m), (Nat.fib (n + 1) : ZMod m)))) := by
        cases m <;> [ aesop; exact Set.toFinite _ ]
      exact h_finite.not_infinite <| Set.infinite_range_of_injective fun i j hij =>
        le_antisymm (le_of_not_gt fun hi => h _ _ hi hij.symm)
          (le_of_not_gt fun hj => h _ _ hj hij)
    aesop
  induction' i with i ih generalizing j
  · exact ⟨ j, hij, by simpa [ ← ZMod.natCast_eq_zero_iff ] using h_pair.1.symm ⟩
  · specialize ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij )
    rcases j <;> simp_all +decide [ Nat.fib_add_two ]
    grind

/-- The Fibonacci rank of apparition of `m`: the least positive `k` with `m ∣ F k`
(or `0` if none exists; for `m ≥ 1` existence is `hasFibRank_of_pos`). -/
noncomputable def fibRank (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ Nat.fib k then Nat.find h else 0

theorem fibRank_pos {m : ℕ} (hm : HasFibRank m) : 0 < fibRank m := by
  unfold fibRank; split_ifs with h
  · exact (Nat.find_spec h).1
  · exact absurd hm h

theorem dvd_fib_fibRank {m : ℕ} (hm : HasFibRank m) : m ∣ Nat.fib (fibRank m) := by
  unfold fibRank; split_ifs with h
  · exact (Nat.find_spec h).2
  · exact absurd hm h

theorem fibRank_min {m k : ℕ} (hk : 0 < k) (hlt : k < fibRank m) : ¬ m ∣ Nat.fib k := by
  unfold fibRank at hlt; split_ifs at hlt with h
  · exact fun hd => Nat.find_min h hlt ⟨hk, hd⟩
  · simp at hlt

/-- The reusable core biconditional (no primitivity hypothesis): `m ∣ F n ↔ rank m ∣ n`. -/
theorem fibRank_dvd_iff {m : ℕ} (hm : HasFibRank m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  have hz : 0 < fibRank m := fibRank_pos hm
  have hmz : m ∣ Nat.fib (fibRank m) := dvd_fib_fibRank hm
  constructor <;> intro hn
  · contrapose! hn
    have hgcd_lt : Nat.gcd (fibRank m) n < fibRank m :=
      lt_of_le_of_ne (Nat.le_of_dvd hz (Nat.gcd_dvd_left _ _))
        (fun h => hn (h ▸ Nat.gcd_dvd_right _ _))
    refine fun hcontra => fibRank_min (Nat.gcd_pos_of_pos_left _ hz) hgcd_lt ?_
    have := Nat.dvd_gcd hmz hcontra
    simpa [Nat.fib_gcd] using this
  · obtain ⟨k, rfl⟩ := hn
    exact dvd_trans hmz (Nat.fib_dvd _ _ ⟨k, rfl⟩)

/-- `q` is a *primitive divisor* of `F n`: it divides `F n` but no earlier positive-index
Fibonacci number. -/
def IsPrimitive (q n : ℕ) : Prop :=
  q ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ q ∣ Nat.fib k

/-- Two naturals that are divisibility-equivalent (`d ∣ k ↔ e ∣ k` for all `k`) coincide. -/
-- !-- Apply the equivalence at `k = e` and `k = d` and use antisymmetry of `∣`. -- !--
lemma nat_eq_of_dvd_iff {d e : ℕ} (h : ∀ k, d ∣ k ↔ e ∣ k) : d = e :=
  Nat.dvd_antisymm ((h e).mpr dvd_rfl) ((h d).mp dvd_rfl)

/-! ## §1. The law of apparition -/

/-
!-- Lab Notebook: fib_dvd_iff_fibRank_dvd -- !--
!-- Hypothesis: For every `m > 0`, `m ∣ F n ↔ rank m ∣ n`. -- !--
!-- Result: Immediate from `fibRank_dvd_iff` once existence of the rank is supplied
unconditionally by `hasFibRank_of_pos`. -- !--
!-- Insight: This is the global/local dictionary — the single fact through which every later
gluing law is proved. -- !--
!-- Failure analysis: needs `0 < m` so the modulus actually has a rank. -- !--
!-- End Lab Notebook -- !--
-/
/-- **Law of apparition.** For `m > 0`, `m ∣ F n ↔ rank m ∣ n`. -/
theorem fib_dvd_iff_fibRank_dvd {m : ℕ} (hm : 0 < m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n :=
  fibRank_dvd_iff (hasFibRank_of_pos m hm) n

/-! ## §2. The Carmichael bridge: primitivity is rank-maximality -/

/-
!-- Lab Notebook: isPrimitive_iff_fibRank_eq -- !--
!-- Hypothesis: `m` is a primitive divisor of `F n` iff `rank m = n` (for `m, n > 0`). -- !--
!-- Result: (→) primitivity gives `m ∣ F n`, so `rank m ∣ n` (law of apparition) hence
`rank m ≤ n`; if `rank m < n` then `m ∣ F (rank m)` at a smaller po
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE_DIRECTIONS.md — Fibonacci Apparition as a Local-to-Global Sheaf

## Synthesis

This cycle formalized the Fibonacci **rank of apparition** as a *local-to-global sheaf* over
the divisibility site of moduli, and proved four theorems with **zero `sorry`** in
`Catalog/Shared/FibonacciApparitionSheaf.lean` (axioms: `propext`, `Classical.choice`,
`Quot.sound` only). The file is self-contained against Mathlib, following the established
catalog convention (`Catalog/Applications/RankOfApparition.lean`,
`Catalog/Novelty/FibApparitionExistence.lean`), restating the short existence/biconditional
*spine* and building the new sheaf layer on top of it.

The guiding theme is **duality and representation**: the rank `rank m = fibRank m` is the
exact dictionary between the divisibility lattice of *moduli* and the divisibility lattice of
*indices*. Its central structural features are:

1. **`fib_dvd_iff_fibRank_dvd`** — the *law of apparition* `m ∣ F n ↔ rank m ∣ n` (for
   `m > 0`). Existence of the rank is obtained not analytically but *structurally*: the
   Fibonacci shift `(a,b) ↦ (b, a+b)` is an honest **permutation** of the finite type
   `(ZMod m)²` (inverse `(a,b) ↦ (b−a, a)`, encoding the reversibility
   `F(k−1) = F(k+1) − F(k)`), so its orbit through `(0,1)` must return — forcing some positive
   `F k ≡ 0 (mod m)`.
2. **`isPrimitive_iff_fibRank_eq`** — the *Carmichael bridge*: `m` is a **primitive divisor**
   of `F n` iff `rank m = n`. This recasts the global primitive-divisor condition (an
   avoidance statement over *all* earlier indices, cf.
   `Shared.CarmichaelProof.bridge_lemma`) as a single local, stalk-level equation:
   primitivity *is* rank-maximality.
3. **`fibRank_mul_coprime`** — CRT *gluing of stalks*: `rank(ab) = lcm(rank a, rank b)` for
   coprime `a, b`.
4. **`fibRank_eq_factorization_lcm`** — the *full local-to-global reconstruction*:
   `rank n = lcm_{p ∈ supp(n)} rank(p^{v_p(n)})`. The global rank is the section glued from the
   prime-power **stalk** ranks; this strictly generalizes the binary gluing law (3) to the
   entire prime decomposition (via the intermediate `fibRank_finset_prod_coprime`, the
   arbitrary coprime-family gluing law).

The catalog already records parallel rank developments (`RankOfApparition`,
`FibonacciApparitionLattice`, `FibonacciEntryPoints`, ...). The new layer here is the explicit
**sheaf framing** — primitivity-as-rank-maximality (the bridge to Carmichael) and the
prime-power reconstruction of the global rank from local stalks — which those threads did not
isolate.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fib_dvd_iff_fibRank_dvd` | `m ∣ F n ↔ rank m ∣ n` (`m > 0`) | proved |
| `isPrimitive_iff_fibRank_eq` | `IsPrimitive m n ↔ rank m = n` (`m,n > 0`) | proved |
| `fibRank_mul_coprime` | `rank(ab) = lcm(rank a, rank b)`, `Coprime a b` | proved |
| `fibRank_finset_prod_coprime` | `rank(∏ f) = Finset.lcm (rank ∘ f)`, pairwise coprime | proved |
| `fibRank_eq_factorizati
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
