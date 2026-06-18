
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

**Title**: This cycle treated the rank of apparition `fibRank` not as an ad-hoc arithmetic
**Domain**: Applications
**Mathematical framing**: # Future Directions — The Fibonacci apparition adjunction and the road to Carmichael's tail

## Synthesis

This cycle treated the rank of apparition `fibRank` not as an ad-hoc arithmetic
gadget but as **one half of a Galois adjunction** `fibRank ⊣ fib` between the
divisibility preorder on *moduli* and the divisibility preorder on *indices*.
The spine of the catalog's primitive-divisor program — `m ∣ F n ↔ fibRank m ∣ n`
— is exactly the adjunction inequality, and once it is read this way the
structural theorems become formal consequences of the adjunction rather than
separate computations.

Two concrete payoffs were formalized (sorry-free) this cycle:

* The adjunction itself, with the `HasFibRank` hypothesis **removed**: the spine
  `fibRank m ∣ n ↔ m ∣ F n` holds for *every* `m` (`fibRank_dvd_iff'`).
* The representation consequence that a left adjoint preserves joins: `fibRank`
  is an exact **lcm-homomorphism** `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`
  (`fibRank_lcm`), lifting to arbitrary finite joins (`fibRank_finset_lcm`), while
  meets are preserved only up to divisibility (`fibRank_gcd_dvd`).

In parallel the long-standing structural gap that prevented the whole
Carmichael development from compiling — the missing prime-index case
`fib_primitive_divisor_prime` — was closed by the rank argument: for a prime
index every prime divisor of `F n` is automatically primitive.

## Results summary

| Result | File | Status |
| --- | --- | --- |
| `fib_primitive_divisor_prime` (prime-index Carmichael) | `Catalog/Shared/CarmichaelHelper.lean` | proved, `sorry = 0` |
| `fibRank_dvd_iff'` (Fibonacci Galois adjunction, hypothesis-free) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_lcm` (join / lcm homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_finset_lcm` (finite join homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_mono`, `fibRank_gcd_dvd` (meet sub-law) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |

The single remaining `sorry` in the program is the **composite asymptotic tail**
`fib_carmichael_composite` for `n > 10000` in `Catalog/Shared/CarmichaelProof.lean`
(the finite band `13 ≤ n ≤ 10000` is already certified by `native_decide`).

---

## Direction 1 — Close the composite tail through the cyclotomic value `Φ_n`

State and prove, for composite `n > 12`, that the homogeneous cyclotomic value
`Φ_n = ∏_{d ∣ n} (F d) ^ μ(n/d)` is a positive integer satisfying
`∏_{d ∣ n} Φ_d = F n`, that every prime dividing `Φ_n` with rank a *proper*
divisor of `n` equals the largest prime factor `P` of `n` and divides `Φ_n` to
first power (an LTE corollary of the already-proven `fib_lte`), and finally that
`Φ_n > n`. Then a primitive prime divisor exists.

The key insight is that the existence question collapses to a single scalar
inequality `Φ_n > n`: the reduction `primitive part = F_n / N` with
`N = (F_n/Φ_n)·N₂` and `N₂ ∣ n` shows the primitive part is `> 1` precisely when
`Φ_n` outgrows `n`, so all the number theory is concentrated in one golden-ratio
size bound `Φ_n ≍ α^{φ(n)}`.

Why now? Every analytic ingredient already lives in the catalog sorry-free —
`fib_lte` (lifting the exponent), `fib_exponential_lower_bound`, and the full
entry-point/rank spine — so the remaining work is the Möbius bookkeeping plus one
`φ(n) ≥ c√n` estimate rather than a from-scratch theory.

## Direction 2 — The adjunction is sharp: classify when `fibRank` preserves meets

Conjecture: `fibRank (gcd a b) = gcd (fibRank a) (fibRank b)` holds **iff**
`fibRank a` and `fibRank b` are "rank-coprime in apparition", and fails for the
first time at an explicit small pair; only the divisibility `fibRank_gcd_dvd`
survives in general.

The key insight is that a left adjoint preserves joins but generally not meets,
so the gcd law must degrade exactly where the apparition lattice is not
distributive over the prime-power decomposition — a defect that should be
measurable and pinned to concrete witnesses.

Why now? `fibRank_lcm` and `fibRank_gcd_dvd` are in hand, so the equality
question is a finite search away from a counterexample and a clean
characterization; the falsifiable form (find the least failing `(a,b)`) makes it
immediately testable by `decide`.

## Direction 3 — Lift the adjunction to every strong divisibility sequence

Generalize `fibRank_dvd_iff'` and `fibRank_lcm` from `Nat.fib` to an arbitrary
strong divisibility sequence `u` (the `IsStrongDivSeq` setting already in
`Catalog/Applications/UnifiedRankOfApparition.lean`): prove `rank u ⊣ u` and that
`rank u` is an lcm-homomorphism.

The key insight is that nothing in the join law used Fibonacci-specific identities
— only the meet law `u (gcd m n) = gcd (u m) (u n)` — so the entire adjunction is
a theorem about strong divisibility sequences, with Fibonacci, Lucas, Mersenne
`2^n - 1`, and `q^n - 1` as instances of one engine.

Why now? The `rank u` machinery (`rank_dvd_iff`, `rank_dvd_of_dvd`) is already
proved sorry-free, so the generalization is a re-derivation of this cycle's two
headline theorems one abstraction level up.

## Direction 4 — A Stone-style duality between indices and apparition supports

Define the apparition support functor `n ↦ Supp(n) = { p prime | p ∣ F n }` and
its adjoint `S ↦ ⋂_{p ∈ S} (multiples of fibRank p)`, and prove they form a
Galois connection whose closed indices are exactly the multiples and whose closed
supports are exactly the "rank-saturated" prime sets; primitive divisors are the
points where the support strictly grows.

The key insight is that Carmichael's theorem is precisely the statement that this
Galois connection is *non-degenerate* for `n ∉ {1,2,6,12}` — primitivity is the
order-theoretic assertion that `Supp(n) ⊋ ⋃_{d ∣ n, d < n} Supp(d)`, turning an
analytic divisor question into a duality/closure statement.

Why now? With `fibRank_dvd_iff'` giving `p ∣ F n ↔ fibRank p ∣ n`, the support
functor is already definable and computable, so the connection's unit/counit
laws reduce to the lcm/gcd homomorphism results proved this cycle.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/FibonacciRankDuality.lean
import Mathlib

/-! # The Fibonacci rank of apparition as one half of a Galois adjunction

Domain: Number Theory / Applications (Conceptual Unification).

The *rank of apparition* `fibRank m` of a modulus `m` is the least positive index `k` with
`m ∣ F k`.  The catalog's primitive-divisor program turns on the **spine**
`m ∣ F n ↔ fibRank m ∣ n` (see `Catalog/Applications/RankOfApparition.lean`,
`RankOfApparition.fibRank_dvd_iff`, and the parallel threads
`Catalog/Applications/FibonacciApparitionLattice.lean`,
`Catalog/Applications/FibonacciPrimitiveDivisors.lean`,
`Catalog/Applications/StrongDivisibilitySequences.lean`).

This file recognizes that spine for what it structurally is: the **adjunction inequality of a
Galois connection** `fibRank ⊣ fib` between the divisibility preorder on *moduli* and the
divisibility preorder on *indices*.  Reading it this way turns the structural laws into formal
consequences of the adjunction rather than separate computations:

* `fibRank_dvd_iff'`     — the adjunction `fibRank m ∣ n ↔ m ∣ F n`, **with the existence
  hypothesis `HasFibRank m` removed**: it holds for *every* `m` (including `m = 0`).
* `fibRank_lcm`          — a left adjoint preserves joins: `fibRank` is an exact
  **lcm-homomorphism** `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`.
* `fibRank_finset_lcm`   — the join law lifted to arbitrary finite joins.
* `fibRank_mono`         — `fibRank` is monotone for divisibility (an order morphism),
  again hypothesis-free.
* `fibRank_gcd_dvd`      — meets are preserved only up to divisibility:
  `fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)` (the left adjoint does *not* in general
  preserve meets — this is the structural reason the gcd law degrades).
* `fibRank_prime_index_has_primitive` — the representation payoff: for a **prime** index every
  prime divisor of `F p` is automatically primitive, because its rank divides a prime and
  cannot be `1`.

The file is **self-contained against Mathlib** (the catalog's `import` graph is fragmented and
the `Applications` directory is not a default build target), so the short existence/spine core
is restated here under the `FibRankDuality` namespace before the new adjunction theory.

-- !-- Lab Notebook (file-level) -- !--
-- !-- Hypothesis: the Fibonacci spine `m ∣ F n ↔ fibRank m ∣ n` is the unit/counit of a Galois
--     connection `fibRank ⊣ fib`, so the structural laws of `fibRank` should follow from
--     general adjunction facts (left adjoints preserve joins, are monotone, sub-preserve meets). -- !--
-- !-- Result: all five structural laws (`fibRank_dvd_iff'`, `fibRank_lcm`, `fibRank_finset_lcm`,
--     `fibRank_mono`, `fibRank_gcd_dvd`) are proved sorry-free as one-line consequences of the
--     hypothesis-free spine plus `lcm_dvd_iff` / `dvd_gcd`, exactly mirroring the categorical proofs. -- !--
-- !-- Insight: dropping the `HasFibRank` hypothesis is what makes the adjunction *total*; the
--     `m = 0` boundary works because `fibRank 0 = 0`, `F 0 = 0`, and `0 ∣ x ↔ x = 0` line up. -- !--
-- !-- Failure analysis: meets are genuinely not preserved — only `fibRank_gcd_dvd` holds, matching
--     the categorical fact that a left adjoint need not preserve limits. -- !--
-- !-- End Lab Notebook -- !--
-/

namespace FibRankDuality

open scoped Classical

/-! ## §0. Existence of the rank (restated core: pigeonhole on the Fibonacci shift) -/

/-- `m` *has a rank of apparition* if it divides some positive-index Fibonacci number. -/
def HasFibRank (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ Nat.fib k

/-- The Fibonacci "shift" permutation on pairs over `ZMod m`: `(a, b) ↦ (b, a + b)`. -/
def fibStep (m : ℕ) : ZMod m × ZMod m ≃ ZMod m × ZMod m where
  toFun p := (p.2, p.1 + p.2)
  invFun p := (p.2 - p.1, p.1)
  left_inv := by intro p; simp
  right_inv := by intro p; simp [add_comm]

theorem fibStep_iterate (m k : ℕ) :
    (fibStep m)^[k] (0, 1) = ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m)) := by
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ]
  simp +decide [ fibStep, Nat.fib_add_two ]

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

/-! ## §2. The spine with hypothesis (restated core) -/

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

/-! ## §3. The Galois adjunction `fibRank ⊣ fib`, hypothesis-free -/

/-
-- !-- Lab Notebook: fibRank_dvd_iff' -- !--
-- !-- Hypothesis: the spine holds for *every* `m`, no `HasFibRank` needed. -- !--
-- !-- Result: for `m > 0` it is the existence spine; for `m = 0` both sides say `n = 0`
--     (`fibRank 0 = 0`, `F 0 = 0`, and `0 ∣ x ↔ x = 0`). -- !--
-- !-- Insight: this is the adjunction inequality `fibRank m ∣ n ↔ m ∣ fib n` of `fibRank ⊣ fib`. -- !--
-- !-- Failure analysis: only the `m = 0` corner needs a manual `fib`-vanishing argument. -- !--
-- !-- End Lab Notebook -- !--
-/
theorem fibRank_dvd_iff' (m n : ℕ) : fibRank m ∣ n ↔ m ∣ Nat.fib n := by
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · -- m = 0
    have h0 : fibRank 0 = 0 := by
      unfold fibRank; split_ifs with h
      · obtain ⟨k, hk, hdvd⟩ := h
        exact absurd (Nat.eq_zero_of_zero_dvd hdvd) (Nat.fib_pos.mpr hk).ne'
      · rfl
    rw [h0]
    constructor
    · intro hn
      have : n = 0 := Nat.eq_zero_of_zero_dvd hn
      subst this; simp
    · intro hn
      have : Nat.fib n = 0 := Nat.eq_zero_of_zero_dvd hn
      have : n = 0 := by
        by_contra hne
        exact (Nat.fib_pos.mpr (Nat.pos_of_ne_zero hne)).ne' this
     
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Fibonacci apparition adjunction and the road to Carmichael's tail

## Synthesis

This cycle stopped treating the rank of apparition `fibRank` as an ad-hoc arithmetic
gadget and started treating it as **one half of a Galois adjunction** `fibRank ⊣ fib`
between the divisibility preorder on *moduli* and the divisibility preorder on *indices*.
The spine of the catalog's primitive-divisor program — `m ∣ F n ↔ fibRank m ∣ n` — is
exactly the adjunction inequality, and once it is read this way the structural theorems
become formal consequences of the adjunction rather than separate computations.

Everything is formalized sorry-free in
`Catalog/Applications/FibonacciRankDuality.lean` (self-contained against Mathlib, building
on the spine restated from `Catalog/Applications/RankOfApparition.lean`):

* **The adjunction itself, hypothesis-free.** `fibRank_dvd_iff'` proves
  `fibRank m ∣ n ↔ m ∣ F n` for *every* `m`, dropping the `HasFibRank m` side condition
  that the catalog spine `RankOfApparition.fibRank_dvd_iff` still carried. The `m = 0`
  corner is made to work by the alignment `fibRank 0 = 0`, `F 0 = 0`, `0 ∣ x ↔ x = 0`.
* **A left adjoint preserves joins.** `fibRank_lcm` proves the exact lcm-homomorphism
  `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`, and `fibRank_finset_lcm` lifts it to
  arbitrary finite joins. Both fall out of the adjunction through `lcm_dvd_iff` plus the
  divisibility-extensionality lemma `dvd_ext`.
* **Meets only sub-preserved.** `fibRank_mono` (monotonicity for divisibility) and
  `fibRank_gcd_dvd` (`fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)`) show the meet law
  degrades to a divisibility — the categorical signature of a functor that preserves
  colimits but not limits.
* **Representation payoff.** `fibRank_prime_index_has_primitive` recovers Carmichael's
  prime-index case for every prime `p ≥ 3` purely from the adjunction: a prime divisor of
  `F p` has rank dividing the prime `p`, the rank is not `1`, hence it equals `p`.

## Results summary

| Result | File | Status |
| --- | --- | --- |
| `fibRank_dvd_iff'` (Fibonacci Galois adjunction, hypothesis-free) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_lcm` (join / lcm homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_finset_lcm` (finite join homomorphism) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_mono`, `fibRank_gcd_dvd` (monotone + meet sub-law) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |
| `fibRank_prime_index_has_primitive` (prime-index Carmichael) | `Catalog/Applications/FibonacciRankDuality.lean` | proved, `sorry = 0` |

The single open analytic gap in the broader program remains the **composite asymptotic
tail** `fib_carmichael_composite` for `n > 10000` in `Catalog/Shared/CarmichaelProof.lean`
(the finite band `13 ≤ n ≤ 10000` is already certified by `native_decide`)
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
