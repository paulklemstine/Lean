
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

**Title**: This cycle isolated the *rank of apparition* (the Fibonacci entry point) as the 
**Domain**: Bridges
**Mathematical framing**: # Future Directions — The Rank of Apparition as the Spine of Carmichael's Theorem

## Synthesis

This cycle isolated the *rank of apparition* (the Fibonacci entry point) as the genuine
load-bearing object of the catalog's Carmichael / primitive-divisor program, and gave it a
clean, fully-proved, self-contained foundation in `Catalog/Applications/RankOfApparition.lean`.

The catalog had accumulated several parallel threads — `FibonacciPrimitiveDivisors`
(`dvd_fib_iff_index_dvd_of_primitive`), the abstract `StrongDivisibilitySequences`
(`IsStrongDivSeq`, `fib_isStrongDivSeq`), `FibonacciApparitionLattice`, and the Carmichael
program in `Shared.CarmichaelProof` / `Speculative.CarmichaelPrimitiveDivisor` — each of which
secretly turns on the *same* fact: the set `{ n | m ∣ F n }` is exactly the set of multiples
of one number. We named that number `fibRank m` and proved the biconditional that makes it the
spine of everything else.

The key conceptual move was to drop the hypothesis of *primitivity*. The catalog's pinning
lemma `dvd_fib_iff_index_dvd_of_primitive` assumes `p` is already a primitive divisor; our
`fibRank_dvd_iff` holds for **every** modulus `m` with a rank, and primitivity reappears as the
boundary special case `fibRank m = n`. With that single biconditional in hand, Carmichael's
prime case, the order-morphism structure of `fibRank`, and the exact evaluation
`fibRank (F k) = k` all fall out cheaply.

## Results Summary (`Catalog/Applications/RankOfApparition.lean`, 0 sorry, axioms = propext/Classical.choice/Quot.sound)

- **`hasFibRank_of_pos`** — every positive modulus has a rank of apparition. Apparition always
  occurs: the pair sequence `n ↦ (F n, F (n+1)) mod m` lives in the finite set `(ZMod m)²`, and
  the Fibonacci shift is reversible, so a repeated pair is back-stepped to a zero of `F mod m`.
- **`fibRank_dvd_iff`** *(the spine)* — `m ∣ F n ↔ fibRank m ∣ n`. The `←` direction is pure
  `Nat.fib_dvd`; the `→` direction pushes `m` into `F (gcd (fibRank m) n)` via `Nat.fib_gcd` and
  closes by minimality of the rank. This generalizes `dvd_fib_iff_index_dvd_of_primitive` by
  removing the primitivity hypothesis entirely.
- **`fibRank_dvd_of_dvd`** — `fibRank` is an order morphism `(ℕ, ∣) → (ℕ, ∣)`: `b ∣ a` implies
  `b` has a rank and `fibRank b ∣ fibRank a`.
- **`fibRank_fib`** — `fibRank (F k) = k` for `k ≥ 3`; the rank pins the Fibonacci values
  exactly, with strict monotonicity ruling out earlier apparition.
- **`fib_prime_index_has_primitive`** — Carmichael's prime case, derived in a few lines from the
  spine: for prime `p ≥ 3`, `F p` has a primitive prime divisor (its rank equals `p`, forced
  because the rank divides the prime `p` and cannot be `1`).

Together with the existing computational composite case, these close the *prime* half of the
Carmichael program on a primitivity-free footing and supply reusable infrastructure for the
composite half.

## Research Directions

### 1. A primitivity-free Carmichael composite case via a primitive-part lower bound

The catalog's composite case is currently a `native_decide` check up to `n ≤ 10000` plus an
unfilled tail for `n > 10000`. The spine reframes the problem: `F n` has a primitive divisor iff
the "primitive part" `Π(n) := F n / ∏_{d | n, d < n, fibRank-compatible} (...)` exceeds `1`,
which is governed by the cyclotomic value `Φ_n(φ, ψ)`. **The key insight is** that the
non-primitive part of `F n` is supported on at most the single prime dividing `n / fibRank`,
so a lower bound `|Φ_n(φ, ψ)| > n` (provable from `φ^{totient n}` growth) forces a primitive
divisor for all large `n` *uniformly*, eliminating the `10000` cutoff. **Why now?** The
spine `fibRank_dvd_iff` plus `fibRank_dvd_of_dvd` already give the exact divisor-lattice
bookkeeping the cyclotomic argument needs; the only missing analytic ingredient is the totient
growth bound, which Mathlib supports (`Nat.totient`, `Nat.totient_lt`, real-power estimates).

### 2. The rank is multiplicative-by-lcm: `fibRank (a*b) = lcm` under coprimality

`fibRank_dvd_of_dvd` shows `fibRank` respects divisibility; conjecture the sharper
`fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` and, for coprime `a, b`,
`fibRank (a*b) = lcm (fibRank a) (fibRank b)`. **The key insight is** that
`m ∣ F n ↔ fibRank m ∣ n` turns `lcm a b ∣ F n` into the simultaneous system
`fibRank a ∣ n ∧ fibRank b ∣ n`, whose least solution is `lcm (fibRank a) (fibRank b)` — exactly
the `FibonacciApparitionLattice` join law, now provable without case analysis. **Why now?** This
is the missing bridge that upgrades the catalog's `FibonacciApparitionLattice` join bound (proved
only as a divisibility, with strictness examples) into an equality on the coprime sublattice, and
reduces all rank computation to prime-power moduli.

### 3. Prime-power ranks and a Lifting-the-Exponent law for `fibRank`

Building on Direction 2, reduce to prime powers: conjecture `fibRank (p^(e+1)) = p · fibRank(p^e)`
for `e ≥ E_0(p)` (a Wall–Sun–Sun threshold), with the exceptional "Wall–Sun–Sun" behavior at the
base. **The key insight is** that `v_p(F (fibRank p · t))` grows by exactly one each time `t`
gains a factor of `p`, the Fibonacci instance of Lifting-the-Exponent — and the catalog already
hosts an LTE-for-Fibonacci file
(`Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors`)
to plug in. **Why now?** With `fibRank_fib` and the spine giving exact apparition indices, the
`v_p` recursion becomes a statement purely about `fibRank`, decoupled from the analytic estimates,
making it a tractable next target.

### 4. Transport the spine to all strong divisibility sequences (Lucas, Mersenne, ...)

`StrongDivisibilitySequences.IsStrongDivSeq` already abstracts the gcd law; conjecture that for
**any** `u` with `IsStrongDivSeq u` and `u 0 = 0`, every modulus dividing some `u k` has a rank
`rank_u m` with `m ∣ u n ↔ rank_u m ∣ n`. **The key insight is** that the entire proof of
`fibRank_dvd_iff` used only `Nat.fib_gcd` and `Nat.fib_dvd`, both of which are *exactly* the
`IsStrongDivSeq` hypotheses — so the spine is not about Fibonacci at all. **Why now?** The catalog
proves `mersenne_isStrongDivSeq` and `fib_isStrongDivSeq`; abstracting the spine instantly yields
Carmichael/Bang–Zsygmondy entry-point theory for `a^n - 1` and Lucas sequences for free, a genuine
cross-domain unification of the number-theory files.

### 5. Density and equidistribution of apparition indices

For fixed `m`, the apparition set `{ n ≤ N | m ∣ F n }` has size `⌊N / fibRank m⌋`, so its natural
density is `1 / fibRank m` (the catalog's `apparition_count` is the finite version). Conjecture the
two-modulus refinement: the joint apparition density of coprime `m₁, m₂` is
`1 / lcm (fibRank m₁) (fibRank m₂)`, and that averaging `1/fibRank p` over primes `p` connects to
the Fibonacci analogue of Artin's constant. **The key insight is** that `fibRank_dvd_iff` makes the
apparition set a literal arithmetic progression, so density is exact (not asymptotic) and stacks
multiplicatively across coprime moduli. **Why now?** The exact-progression structure is already
proved here; only the (independent) prime-averaging heuristic remains, making the conditional
density statements fully falsifiable by computation against `fibRank` tables.

Research domain: Bridges
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/RankOfApparition.lean
import Mathlib

/-! # The rank of apparition as the spine of Fibonacci primitive-divisor theory

Domain: Number Theory / Applications (Bridges).

The *rank of apparition* (Fibonacci entry point) of a modulus `m` is the least positive
index `k` with `m ∣ F k`.  The catalog already contains several **parallel** developments of
this object, each turning on the same biconditional `m ∣ F n ↔ rank ∣ n`:

* `Catalog/Novelty/FibApparitionExistence.lean`
  (`FibApparition.apparitionRank`, `fib_apparition_exists`, `fib_dvd_iff_apparitionRank_dvd`);
* `Catalog/Applications/FibonacciEntryPoints.lean`
  (`FibonacciEntryPoints.entryPoint`, `dvd_fib_iff_entry_dvd`, `primitive_iff_entry_eq`);
* `Catalog/Applications/FibonacciApparitionLattice.lean`
  (`fibEntry_lcm`, `fibEntry_monotone`, `fibEntry_gcd_dvd`);
* `Catalog/Applications/FibonacciPrimitiveDivisors.lean`
  (`dvd_fib_iff_index_dvd_of_primitive`, `simultaneous_apparition`);
* `Catalog/Applications/StrongDivisibilitySequences.lean`
  (`IsStrongDivSeq`, `dvd_iff_index_dvd_of_primitive`, `apparition_count`);
* `Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean`
  (`fib_prime_has_primitive` for primes `p ≥ 5`).

This file is **self-contained against Mathlib** (the catalog's `import` graph is currently
fragmented, so we restate the short existence/biconditional core rather than depend on a
non-default build target), and it adds the results the parallel threads were missing:

* `fibRank_fib`            — *new*: `fibRank (F k) = k` for `k ≥ 3`.  The rank pins the
  Fibonacci values **exactly**; not present anywhere in the catalog or in Mathlib.
* `fib_dvd_fib_iff`        — *new corollary*: `F a ∣ F b ↔ a ∣ b` for `a ≥ 3`.  Mathlib has
  only the forward implication `Nat.fib_dvd`; the biconditional is absent (`exact?` fails).
* `fib_prime_index_has_primitive` — Carmichael's prime case for **all** primes `p ≥ 3`
  (the catalog's `fib_prime_has_primitive` requires `p ≥ 5`), derived in a few lines from the
  spine: the chosen prime divisor of `F p` has rank exactly `p`.
* `fibRank_dvd_of_dvd`     — the order-morphism law packaged with existence:
  `b ∣ a → 0 < a → fibRank b ∣ fibRank a`.

The reusable core (`hasFibRank_of_pos`, `fibRank_dvd_iff`) is stated *without* any
primitivity hypothesis, generalizing `FibonacciPrimitiveDivisors.dvd_fib_iff_index_dvd_of_primitive`.
-/

namespace RankOfApparition

open scoped Classical

/-- `m` *has a rank of apparition* if it divides some positive-index Fibonacci number. -/
def HasFibRank (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ Nat.fib k

/-! ## §0. Existence of the rank (pigeonhole on the Fibonacci shift) -/

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
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ];
  simp +decide [ fibStep, Nat.fib_add_two ]

/-
!-- Lab Notebook: hasFibRank_of_pos -- !--
!-- Hypothesis: Every positive modulus has a rank of apparition (apparition is total). -- !--
!-- Result: Proved by pigeonhole on the finite set `(ZMod m)²`: two indices `i < j` share
the pair `(F·, F·₊₁) mod m`; back-stepping `i` to `0` via the reversible shift produces a
positive `k = j - i` with `m ∣ F k`. -- !--
!-- Insight: Reversibility of the Fibonacci shift (a unit determinant matrix over `ZMod m`)
is the abstract Pisano-period mechanism; Mathlib has no Pisano theory, so this is built here. -- !--
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

/-! ## §1. The rank function and its defining properties -/

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

/-! ## §2. The spine: `m ∣ F n ↔ fibRank m ∣ n` -/

/-
!-- Lab Notebook: fibRank_dvd_iff -- !--
!-- Hypothesis: For any modulus with a rank, `m ∣ F n ↔ fibRank m ∣ n`. -- !--
!-- Result: Proved with NO primitivity hypothesis (generalizing the catalog's
`dvd_fib_iff_index_dvd_of_primitive`). (←) `fibRank m ∣ n → F (fibRank m) ∣ F n` (`Nat.fib_dvd`)
and `m ∣ F (fibRank m)`. (→) push `m` into `F (gcd (fibRank m) n) = gcd (F …) (F n)`
(`Nat.fib_gcd`); minimality of the rank forces `gcd (fibRank m) n = fibRank m`, i.e. divisibility. -- !--
!-- Insight: This single biconditional is the load-bearing fact behind every parallel
apparition thread in the catalog; dropping primitivity makes it the genuine spine. -- !--
!-- Failure analysis: needs `HasFibRank m` so the rank is positive; for `m = 0` it is vacuous. -- !--
!-- End Lab Notebook -- !--
-/
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

/-! ## §3. Order-morphism law (with existence) -/

/-
!-- Lab Notebook: fibRank_dvd_of_dvd -- !--
!-- Hypothesis: `fibRank` is an order morphism of divisibility posets:
`b ∣ a → fibRank b ∣ fibRank a` (for `a > 0`). -- !--
!-- Result: Proved from the spine: `b ∣ a ∣ F (fibRank a)`, so `b ∣ F (fibRank a)`, and the
spine for `b` gives `fibRank b ∣ fibRank a`. -- !--
!-- Insight: Packages monotonicity together with existence of 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Rank of Apparition as the Spine of Carmichael's Theorem

## Synthesis

This cycle consolidated the *rank of apparition* (the Fibonacci entry point) into a single,
self-contained, fully-proved foundation in `Catalog/Applications/RankOfApparition.lean`, and used
it to prove results that the catalog's many parallel apparition threads were all missing.

The catalog had accumulated several overlapping developments of the same object — the existence
proof and biconditional in `Catalog/Novelty/FibApparitionExistence.lean`
(`apparitionRank`, `fib_apparition_exists`, `fib_dvd_iff_apparitionRank_dvd`); the entry-point
calculus of `Catalog/Applications/FibonacciEntryPoints.lean` (`entryPoint`,
`primitive_iff_entry_eq`); the lattice laws of `Catalog/Applications/FibonacciApparitionLattice.lean`
(`fibEntry_lcm`, `fibEntry_monotone`, `fibEntry_gcd_dvd`); the primitivity calculus of
`Catalog/Applications/FibonacciPrimitiveDivisors.lean` (`dvd_fib_iff_index_dvd_of_primitive`,
`simultaneous_apparition`); the abstract `Catalog/Applications/StrongDivisibilitySequences.lean`
(`IsStrongDivSeq`, `dvd_iff_index_dvd_of_primitive`, `apparition_count`); and the analytic
Carmichael program in `Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean`
(`fib_prime_has_primitive`, restricted to primes `p ≥ 5`). Every one of these secretly turns on
the same fact: `{ n | m ∣ F n }` is exactly the set of multiples of one number, `fibRank m`.

The conceptual move was to make that biconditional, `fibRank_dvd_iff`, primitivity-free and then
read everything off it. With the spine in hand, the genuinely new facts of this cycle — that the
rank pins Fibonacci values *exactly* (`fibRank_fib`), that this upgrades Mathlib's one-way
`Nat.fib_dvd` to a full biconditional (`fib_dvd_fib_iff`), and that Carmichael's prime case holds
for *all* primes `p ≥ 3` (`fib_prime_index_has_primitive`) — each fall out in a few lines.

## Results Summary (`Catalog/Applications/RankOfApparition.lean`, 0 sorry; axioms = propext / Classical.choice / Quot.sound)

- **`hasFibRank_of_pos`** — every positive modulus has a rank of apparition. The pair sequence
  `n ↦ (F n, F (n+1)) mod m` lives in the finite set `(ZMod m)²`, and the Fibonacci shift is a
  permutation (unit-determinant), so a repeated pair back-steps to a zero of `F mod m`.
- **`fibRank_dvd_iff`** *(the spine)* — `m ∣ F n ↔ fibRank m ∣ n`, with **no primitivity
  hypothesis**, generalizing `FibonacciPrimitiveDivisors.dvd_fib_iff_index_dvd_of_primitive`.
- **`fibRank_dvd_of_dvd`** — the order-morphism law packaged with existence:
  `b ∣ a → 0 < a → fibRank b ∣ fibRank a`.
- **`fibRank_fib`** *(new)* — `fibRank (F k) = k` for `k ≥ 3`. The rank pins the Fibonacci
  values exactly; this appears nowhere in the catalog or in Mathlib.
- **`fib_dvd_fib_iff`** *(new corollary)* — `F a ∣ F b ↔ a ∣ b` for `a ≥ 3`. Mathlib provides
  only the forward direction (`Nat.fib_dvd`); the biconditional was absent (`exact?` fails)
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
