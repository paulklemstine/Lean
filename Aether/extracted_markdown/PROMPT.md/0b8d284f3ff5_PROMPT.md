
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

**Title**: This cycle consolidated the *rank of apparition* (the Fibonacci entry point) int
**Domain**: Algebra
**Mathematical framing**: # Future Directions — The Rank of Apparition as the Spine of Carmichael's Theorem

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
  only the forward direction (`Nat.fib_dvd`); the biconditional was absent (`exact?` fails).
- **`fib_prime_index_has_primitive`** — Carmichael's prime case for **every** prime `p ≥ 3`
  (the catalog's `fib_prime_has_primitive` needs `p ≥ 5`): the chosen prime divisor of `F p` has
  rank exactly `p`, so it cannot divide any earlier `F k`.

## Research Directions

### 1. A primitivity-free Carmichael composite case via a primitive-part lower bound

The catalog's composite case is a `native_decide` check up to `n ≤ 50000`
(`FibPrimitive.fib_primitive_le_50000`) plus an analytic tail. The spine reframes the problem:
`F n` has a primitive divisor iff its "primitive part" `Π(n) := F n / ∏_{d ∣ n, d < n} F d^{…}`
exceeds `1`, which is governed by the cyclotomic value `Φ_n(φ, ψ)`. **The key insight is** that
the non-primitive part of `F n` is supported on at most the single prime dividing `n / fibRank`,
so a uniform lower bound `|Φ_n(φ, ψ)| > n` — provable from `φ^{totient n}` growth — forces a
primitive divisor for *all* large `n` at once, eliminating the numeric cutoff. **Why now?** The
spine `fibRank_dvd_iff` together with `fibRank_dvd_of_dvd` already supplies the exact
divisor-lattice bookkeeping the cyclotomic argument needs; the only missing ingredient is the
totient growth bound, which Mathlib supports (`Nat.totient`, `Nat.totient_lt`, real-power estimates).

### 2. `fibRank` as an exact join-morphism, transported to the new spine

`Catalog/Applications/FibonacciApparitionLattice.lean` already proves the unrestricted join law
`fibEntry (lcm a b) = lcm (fibEntry a) (fibEntry b)` and the strictness of the meet bound for
the *old* `fibEntry`. Conjecture the same laws hold verbatim for the primitivity-free `fibRank`,
and combine with `fibRank_fib` to compute `fibRank` on any `lcm` of Fibonacci numbers in closed
form. **The key insight is** that `fibRank_dvd_iff` makes `lcm a b ∣ F n` equivalent to the
system `fibRank a ∣ n ∧ fibRank b ∣ n`, whose least solution is `lcm (fibRank a) (fibRank b)` —
so the join law is a one-line consequence of the spine plus `Nat.lcm_dvd_iff`, with no case
analysis. **Why now?** Re-deriving the lattice laws on the `fibRank` spine merges the catalog's
two parallel rank objects (`fibEntry`, `apparitionRank`/`fibRank`) into one, and `fibRank_fib`
turns the abstract laws into concrete evaluations.

### 3. Prime-power ranks and a Lifting-the-Exponent law for `fibRank`

Reduce rank computation to prime powers: conjecture `fibRank (p^(e+1)) = p · fibRank (p^e)` for
`e ≥ E₀(p)` (a Wall–Sun–Sun threshold), with exceptional behaviour at the base. **The key insight
is** that `v_p(F (fibRank p · t))` increases by exactly one each time `t` gains a factor of `p` —
the Fibonacci instance of Lifting-the-Exponent — and the catalog already hosts an LTE-for-Fibonacci
file (`Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors.lean`) to plug in. **Why
now?** With `fibRank_fib` giving exact apparition indices and the spine decoupling the combinatorics
from the analytic estimates, the `v_p` recursion becomes a statement purely about `fibRank`, making
it a tractable next target.

### 4. Transport the entire spine to all strong divisibility sequences

`Catalog/Applications/StrongDivisibilitySequences.lean` abstracts the gcd law as `IsStrongDivSeq`.
Conjecture that for **any** `u` with `IsStrongDivSeq u` and `u 0 = 0`, every modulus dividing some
`u k` has a rank `rank_u m` with `m ∣ u n ↔ rank_u m ∣ n`, and that `rank_u (u k) = k` whenever
`u` is eventually strictly monotone. **The key insight is** that the proof of `fibRank_dvd_iff` and
`fibRank_fib` used only the strong-divisibility law and strict monotonicity — never anything
Fibonacci-specific — so the whole spine is sequence-agnostic. **Why now?** The catalog already
proves `mersenne_isStrongDivSeq` and `fib_isStrongDivSeq`; abstracting the spine immediately yields
Bang–Zsygmondy entry-point theory for `aⁿ − 1` and Lucas sequences for free, a genuine cross-domain
unification of the number-theory files.

### 5. Exact arithmetic-progression density of apparition indices

For fixed `m`, `fibRank_dvd_iff` makes `{ n ≤ N | m ∣ F n }` a literal arithmetic progression of
step `fibRank m`, so its count is exactly `⌊N / fibRank m⌋` and its natural density is `1 / fibRank m`
(the finite version is `StrongDivSeq.apparition_count`). Conjecture the coprime refinement: the joint
apparition density of coprime `m₁, m₂` is `1 / lcm (fibRank m₁) (fibRank m₂)`, and that averaging
`1 / fibRank p` over primes `p` connects to the Fibonacci analogue of Artin's constant. **The key
insight is** that the spine makes the apparition set an *exact* progression (not merely asymptotic),
so densities multiply across coprime moduli with no error term. **Why now?** The exact-progression
structure is already proved; only the (independent) prime-averaging heuristic remains, making the
conditional density statements fully falsifiable against computed `fibRank` tables.

Research domain: Algebra
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- DIFF: Catalog/Applications/RankOfApparition.lean
--- a/Applications/RankOfApparition.lean
+++ b/Applications/RankOfApparition.lean
@@ -239,4 +239,103 @@
                                 exact ⟨ p, by linarith, hqdvd ⟩ ) ; simp_all +decide [ Nat.fib_one ];
   · exact ⟨ q, hq_prime, hqdvd, fun k hk hk' hk'' => by have := fibRank_min ( show 0 < k from hk ) ( by linarith ) hk''; aesop ⟩
 
+/-! ## §7. The rank as a lattice (join) morphism, and exact apparition density
+
+The spine `fibRank_dvd_iff` makes `fibRank` a **join (lcm) morphism** of divisibility
+lattices, and turns the apparition index set into an *exact* arithmetic progression — so its
+finite count is the literal integer division `N / fibRank m`, with no error term.  All of the
+following build directly on the spine and on `fibRank_fib`. -/
+
+/-
+!-- Lab Notebook: fibRank_eq_of_forall -- !--
+!-- Hypothesis: The spine determines the rank uniquely: if `0 < d` and `d`'s multiples are
+exactly the apparition indices of `m`, then `fibRank m = d`. -- !--
+!-- Result: `m ∣ F d` (since `d ∣ d`) gives `HasFibRank m`; the spine yields
+`∀ n, m ∣ F n ↔ fibRank m ∣ n`, so `∀ n, d ∣ n ↔ fibRank m ∣ n`; evaluating at `n = d` and
+`n = fibRank m` forces mutual divisibility, hence equality (`Nat.dvd_antisymm`). -- !--
+!-- Insight: This is the universal property of the rank — every lattice law below is just this
+uniqueness applied to a chosen `d`. -- !--
+!-- Failure analysis: needs `0 < d` so `m` provably has a rank and `d ∣ ·` is non-degenerate. -- !--
+!-- End Lab Notebook -- !--
+-/
+theorem fibRank_eq_of_forall {m d : ℕ} (hd : 0 < d)
+    (h : ∀ n, m ∣ Nat.fib n ↔ d ∣ n) : fibRank m = d := by
+  have hr : HasFibRank m := ⟨d, hd, (h d).2 dvd_rfl⟩
+  have hsp := fibRank_dvd_iff hr
+  have heq : ∀ n, d ∣ n ↔ fibRank m ∣ n := fun n => (h n).symm.trans (hsp n)
+  exact Nat.dvd_antisymm ((heq d).1 dvd_rfl) ((heq (fibRank m)).2 dvd_rfl)
+
+/-
+!-- Lab Notebook: fibRank_lcm -- !--
+!-- Hypothesis: `fibRank` is a join morphism: `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`
+for `0 < a, 0 < b`. -- !--
+!-- Result: Apply `fibRank_eq_of_forall` with `d = lcm (fibRank a) (fibRank b)`:
+`lcm a b ∣ F n ↔ a ∣ F n ∧ b ∣ F n` (`Nat.lcm_dvd_iff`) `↔ fibRank a ∣ n ∧ fibRank b ∣ n`
+(spine, twice) `↔ lcm (fibRank a) (fibRank b) ∣ n` (`Nat.lcm_dvd_iff`). -- !--
+!-- Insight: The spine turns `lcm a b ∣ F n` into a *system* of two index-divisibilities whose
+least common solution is the lcm of the ranks — the join law is one line, no cases. -- !--
+!-- Failure analysis: rhs positivity needs both ranks positive, i.e. both moduli positive. -- !--
+!-- End Lab Notebook -- !--
+-/
+theorem fibRank_lcm {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
+    fibRank (Nat.lcm a b) = Nat.lcm (fibRank a) (fibRank b) := by
+  have hra : HasFibRank a := hasFibRank_of_pos a ha
+  have hrb : HasFibRank b := hasFibRank_of_pos b hb
+  have hpos : 0 < Nat.lcm (fibRank a) (fibRank b) :=
+    Nat.pos_of_ne_zero fun h => by
+      rcases Nat.eq_zero_of_lcm_eq_zero h with h0 | h0
+      · exact (fibRank_pos hra).ne' h0
+      · exact (fibRank_pos hrb).ne' h0
+  refine fibRank_eq_of_forall hpos (fun n => ?_)
+  rw [Nat.lcm_dvd_iff, fibRank_dvd_iff hra, fibRank_dvd_iff hrb, Nat.lcm_dvd_iff]
+
+/-
+!-- Lab Notebook: fibRank_lcm_fib -- !--
+!-- Hypothesis: `fibRank (lcm (F a) (F b)) = lcm a b` for `a, b ≥ 3`. -- !--
+!-- Result: Apply `fibRank_lcm` (both `F a, F b > 0`), then rewrite each `fibRank (F ·)` with
+`fibRank_fib`. -- !--
+!-- Insight: Merges the catalog's two parallel rank objects into a single concrete value — the
+abstract join law becomes an explicit computation thanks to `fibRank_fib`. -- !--
+!-- Failure analysis: needs `a, b ≥ 3` exactly because `fibRank_fib` is sharp there. -- !--
+!-- End Lab Notebook -- !--
+-/
+theorem fibRank_lcm_fib {a b : ℕ} (ha : 3 ≤ a) (hb : 3 ≤ b) :
+    fibRank (Nat.lcm (Nat.fib a) (Nat.fib b)) = Nat.lcm a b := by
+  have hfa : 0 < Nat.fib a := Nat.fib_pos.mpr (by linarith)
+  have hfb : 0 < Nat.fib b := Nat.fib_pos.mpr (by linarith)
+  rw [fibRank_lcm hfa hfb, fibRank_fib ha, fibRank_fib hb]
+
+/-
+!-- Lab Notebook: fib_lcm_dvd_fib_lcm -- !--
+!-- Hypothesis: `lcm (F a) (F b) ∣ F (lcm a b)` for all `a, b`. -- !--
+!-- Result: `a ∣ lcm a b` and `b ∣ lcm a b`, so `F a ∣ F (lcm a b)` and `F b ∣ F (lcm a b)` by
+`Nat.fib_dvd`; conclude by `Nat.lcm_dvd`. -- !--
+!-- Insight: The forward Fibonacci-divisibility direction already makes the index-lcm an upper
+bound for the value-lcm — a clean monotonicity fact needing no hypotheses. -- !--
+!-- Failure analysis: none; holds for all `a, b`. -- !--
+!-- End Lab Notebook -- !--
+-/
+theorem fib_lcm_dvd_fib_lcm (a b : ℕ) :
+    Nat.lcm (Nat.fib a) (Nat.fib b) ∣ Nat.fib (Nat.lcm a b) :=
+  Nat.lcm_dvd (Nat.fib_dvd _ _ (Nat.dvd_lcm_left a b))
+    (Nat.fib_dvd _ _ (Nat.dvd_lcm_right a b))
+
+/-
+!-- Lab Notebook: card_apparition_Ioc -- !--
+!-- Hypothesis: For `0 < m`, the apparition indices in `(0, N]` number exactly `N / fibRank m`. -- !--
+!-- Result: By the spine, `{ n ∈ Ioc 0 N | m ∣ F n }` equals `{ n ∈ Ioc 0 N | fibRank m ∣ n }`
+(filter congruence), whose card is `N / fibRank m` by `Nat.Ioc_filter_dvd_card_eq_div`. -- !--
+!-- Insight: The apparition set is a literal arithmetic progression of step `fibRank m`, so the
+count is exact for every cutoff `N`, not merely asymptotic. -- !--
+!-- Failure analysis: needs `0 < m` so `m` has a rank and the spine applies. -- !--
+!-- End Lab Notebook -- !--
+-/
+theorem card_apparition_Ioc {m : ℕ} (hm : 0 < m) (N : ℕ) :
+    ((Finset.Ioc 0 N).filter (fun n => m ∣ Nat.fib n)).card = N / fibRank m := by
+  have hr : HasFibRank m := hasFibRank_of_pos m hm
+  have : (Finset.Ioc 0 N).filter (fun n => m ∣ Nat.fib n)
+        = (Finset.Ioc 0 N).filter (fun n => fibRank m ∣ n) :=
+    Finset.filter_congr (fun n _ => by rw [fibRank_dvd_iff hr])
+  rw [this, Nat.Ioc_filter_dvd_card_eq_div]
+
 end RankOfApparition


-- NEW_FILE: Catalog/Physics/KolmogorovAxioms.lean
import Mathlib

/-!
# Hilbert's Sixth Problem: An Axiomatic Foundation for Probability

This file gives a fully self-contained, abstract formalization of Kolmogorov's
axiomatization of probability — the probabilistic half of Hilbert's sixth problem
("the axiomatization of those physical sciences in which mathematics plays an
important role").  Rather than reusing Mathlib's measure-theoretic
`MeasureTheory.IsProbabilityMeasure`, we axiomatize a *finitely additive*
probability assignment directly on the Boolean algebra of subsets of a sample
space `Ω`, and derive the classical laws of probability purely from the axioms.

The point of this exercise is foundational: we exhibit the minimal set of axioms
(non-negativity, normalization, finite additivity on disjoint events) and show
that the entire elementary calculus of probability — the complement rule,
monotonicity, the modular / valuation law, and Boole's inequality for arbitrary
finite families of events — follows.  We also prove the axiom system is
*consistent* by exhibiting an explicit model (the Dirac point mass).

## Main definitions
- `KolmogorovSpace Ω`: a finitely additive probability assignment on `Set Ω`.
- `KolmogorovAxioms.diracSpace ω₀`: the Dirac point-mass model.

## Main theorems
- `KolmogorovSpace.prob_empty`: the impossible event has probability 0.
- `KolmogorovSpace.prob_compl`: the complement rule `P Aᶜ = 1 - P A`.
- `KolmogorovSpace.prob_mono`: monotonicity of probability.
- `KolmogorovSpace.prob_le_one`: every event has probability at most 1.
- `KolmogorovSpace.prob_modular`: the modular / valuation law
  `P (A ∪ B) + P (A ∩ B) = P A + P B`, the bridge to lattice-theoretic and
  topos-theoretic valuations.
- `KolmogorovSpace.prob_union_le`: two-event Boole inequality (subadditivity).
- `KolmogorovSpace.prob_biUnion_le`: Boole's inequality for an arbitrary finite
  family of events.
- `KolmogorovAxioms.kolmogorov_consistent`: consistency — the axiom system is
  inhabited for nonempty `Ω` via the Dirac mod
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Rank of Apparition as a Lattice Morphism

## Synthesis

The previous cycle distilled Fibonacci apparition theory down to a single **spine**,
`RankOfApparition.fibRank_dvd_iff : m ∣ F n ↔ fibRank m ∣ n` (primitivity-free), together with
the exact rigidity `fibRank_fib : fibRank (F k) = k` for `k ≥ 3`. This cycle exploits the spine
in two new directions, both proved from scratch in `Catalog/Applications/RankOfApparition.lean`
(§7), with `sorry = 0` and axioms restricted to `propext / Classical.choice / Quot.sound`:

* **The rank is a join (lcm) morphism of divisibility lattices.** The keystone is a *universal
  property*, `fibRank_eq_of_forall`: any positive `d` whose multiples are exactly the apparition
  indices of `m` equals `fibRank m`. From it the join law `fibRank_lcm`,
  `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` for positive `a, b`, falls out by feeding
  `Nat.lcm_dvd_iff` through the spine twice — no case analysis. Combined with `fibRank_fib` this
  gives the closed-form evaluation `fibRank_lcm_fib : fibRank (lcm (F a) (F b)) = lcm a b` for
  `a, b ≥ 3`, collapsing the catalog's two parallel rank objects (`fibEntry`, `fibRank`) into one
  concrete computation, plus the hypothesis-free divisibility law
  `fib_lcm_dvd_fib_lcm : lcm (F a) (F b) ∣ F (lcm a b)`.

* **Apparition indices form an exact arithmetic progression.** `card_apparition_Ioc` proves that
  the apparition indices of `m` in `(0, N]` number *exactly* `N / fibRank m` — an equality for
  every cutoff, not an asymptotic estimate, obtained by transporting the count of multiples
  (`Nat.Ioc_filter_dvd_card_eq_div`) across the spine.

The unifying lesson: the spine is not merely a biconditional but a faithful order/lattice
embedding of moduli (under divisibility) into indices (under divisibility). Everything Fibonacci
about apparition is a corollary of that embedding.

## Results Summary (`Catalog/Applications/RankOfApparition.lean`, §7)

- `fibRank_eq_of_forall` — universal property: the rank is the unique positive `d` with
  `∀ n, m ∣ F n ↔ d ∣ n`.
- `fibRank_lcm` — join law: `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` for `0 < a, 0 < b`.
- `fibRank_lcm_fib` — `fibRank (lcm (F a) (F b)) = lcm a b` for `a, b ≥ 3`.
- `fib_lcm_dvd_fib_lcm` — `lcm (F a) (F b) ∣ F (lcm a b)` for all `a, b`.
- `card_apparition_Ioc` — exact density: `#{ n ∈ Ioc 0 N | m ∣ F n } = N / fibRank m` for `0 < m`.

## Research Directions

### 1. The meet (gcd) law and exactly when it is strict

`fibRank_dvd_of_dvd` already forces `fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)` (apply
monotonicity to `gcd a b ∣ a` and `gcd a b ∣ b`). The dual of the clean join law would be
equality, `fibRank (gcd a b) = gcd (fibRank a) (fibRank b)`, but this *fails* in general (the
spine only linearizes lcm, not gcd, because two moduli can share an apparition index without
sharing a common divisor). The falsifiable conjecture is a precise strictness criterion: equality
holds iff `gcd (F (f
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
