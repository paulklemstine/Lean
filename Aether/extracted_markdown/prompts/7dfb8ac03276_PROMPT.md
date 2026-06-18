
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
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
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
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
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: Goldbach Conjecture
**Domain**: Algebra
**Mathematical framing**: Prove that every even integer greater than 2 is the sum of two primes. Formalize partial results such as Vinogradov's theorem for sufficiently large odd integers, or Chen's theorem that every sufficiently large even number is the sum of a prime and a semiprime. Explore connections to sieve methods and the circle method.
Research domain: Algebra
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/AffineWords.lean
import Mathlib
import Collatz.ParityCylinders

/-!
# Affine Iteration Formula and Descent Theory

This file develops the affine structure of Collatz iterates along parity words.
The key insight is that the k-step Collatz iterate along a parity word w is an
affine function of the starting value: D · x_k = A · n + B, where A = 3^(oddCount)
and D = 2^(evenCount).

## Main results

* `v2_mod_preserved_on_odd`: The 2-adic structure of 3n+1 is determined by n mod 2^k.
* `iterate_congr_mod`: The j-th iterate mod 2^(k-j) is determined by n mod 2^k.
* `parityWord_eq_of_residue`: The parity word factors through ℤ/2^kℤ.
* `parityCylinder_partition`: Parity cylinders partition ℕ.
* `countUpTo_partition`: Total count across all cylinders equals N+1.
* `exists_descent_word`: For k ≥ 1, at least one descent word exists.
-/

namespace Collatz

/-
============================================================================
§ 1. The 2-adic structure of 3n+1 is locally determined
============================================================================

For any numbers, 3n+1 mod 2^k depends only on n mod 2^k.
    This is the foundation of 2-adic local analysis for Collatz dynamics.
-/
theorem v2_mod_preserved_on_odd (n m k : ℕ)
    (h : n % 2 ^ k = m % 2 ^ k) :
    (3 * n + 1) % 2 ^ k = (3 * m + 1) % 2 ^ k := by
  exact Nat.ModEq.add ( Nat.ModEq.mul_left _ h ) rfl

/-
============================================================================
§ 2. Iterate congruence — strengthened version
============================================================================

The j-th Collatz iterate mod 2^(k-j) is determined by n mod 2^k.
    This is the quantitative backbone of the parity cylinder theorem.
-/
theorem iterate_congr_mod (k : ℕ) (n m : ℕ) (j : ℕ) (hj : j ≤ k)
    (h : n % 2 ^ k = m % 2 ^ k) :
    step^[j] n % 2 ^ (k - j) = step^[j] m % 2 ^ (k - j) := by
  induction' j with j ih generalizing n m;
  · exact h;
  · have := step_congr_mod ( step^[j] n ) ( step^[j] m ) ( 2 ^ ( k - j - 1 ) ) ?_ ?_ <;> simp_all +decide [ Nat.pow_succ', Nat.mul_mod_mul_left ];
    · erw [ Function.iterate_succ_apply', Function.iterate_succ_apply' ] at * ; aesop;
    · convert ih n m hj.le h using 1;
      · rw [ ← pow_succ', Nat.sub_add_cancel ( Nat.sub_pos_of_lt hj ) ];
      · rw [ ← pow_succ', Nat.sub_add_cancel ( Nat.sub_pos_of_lt hj ) ]

-- ============================================================================
-- § 3. Parity word as a well-defined function on ℤ/2^k ℤ
-- ============================================================================

/-- The parity word map factors through ℤ/2^kℤ: it defines a well-posed
    function on residue classes. -/
def parityWordOfResidue (k : ℕ) (a : Fin (2 ^ k)) : Fin k → Bool :=
  parityWord k a.val

/-
Any natural number's parity word equals that of its residue class representative.
-/
theorem parityWord_eq_of_residue (k : ℕ) (n : ℕ) :
    parityWord k n = parityWordOfResidue k ⟨n % 2 ^ k, Nat.mod_lt _ (by positivity)⟩ := by
  -- By definition of `parityWord`, we know that `parityWord k n` depends only on `n % 2^k`.
  have h_parityWord_mod : ∀ n, parityWord k n = parityWord k (n % 2 ^ k) := by
    exact fun n => parityWord_determined_by_residue k n ( n % 2 ^ k ) ( by simp +decide );
  convert h_parityWord_mod n using 1

-- ============================================================================
-- § 4. Parity cylinders partition ℕ
-- ============================================================================

/-- A parity cylinder is the preimage of a parity word under the parityWord map. -/
def parityCylinder (k : ℕ) (w : Fin k → Bool) : Set ℕ :=
  {n | parityWord k n = w}

instance parityCylinder_decidable (k : ℕ) (w : Fin k → Bool) :
    DecidablePred (· ∈ parityCylinder k w) :=
  fun n => decidable_of_iff (parityWord k n = w) Iff.rfl

/-
The parity cylinders partition ℕ: every natural number belongs to exactly
    one cylinder.
-/
theorem parityCylinder_partition (k : ℕ) (n : ℕ) :
    ∃! w : Fin k → Bool, n ∈ parityCylinder k w := by
  refine' ⟨ parityWord k n, _, _ ⟩ <;> simp +decide [ parityCylinder ]

-- ============================================================================
-- § 5. Density framework
-- ============================================================================

/-- Count of naturals up to N in a decidable set. -/
def countUpTo (N : ℕ) (S : Set ℕ) [DecidablePred (· ∈ S)] : ℕ :=
  ((Finset.range (N + 1)).filter (· ∈ S)).card

/-
The total count across all parity cylinders equals N+1.
    This is the partition-of-unity property for Collatz parity cylinders.
-/
theorem countUpTo_partition (k N : ℕ) :
    ∑ w : Fin k → Bool, countUpTo N (parityCylinder k w) = N + 1 := by
  simp +decide only [countUpTo, parityCylinder];
  convert Finset.card_range ( N + 1 ) using 1;
  rw [ ← Finset.card_biUnion ];
  · congr with x ; aesop;
  · exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun z hz₁ hz₂ => hxy <| by aesop;

/-
Each parity cylinder's count is at most N + 1.
-/
theorem countUpTo_cylinder_le (k : ℕ) (w : Fin k → Bool) (N : ℕ) :
    countUpTo N (parityCylinder k w) ≤ N + 1 := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-
============================================================================
§ 6. Descent word existence
============================================================================

For k ≥ 1, at least one descent word exists.
    The all-false word (all even steps) has oddCount = 0 and evenCount = k,
    so 3^0 = 1 < 2^k.
-/
theorem exists_descent_word (k : ℕ) (hk : 1 ≤ k) :
    ∃ w : Fin k → Bool, isDescentWord k w := by
  -- By definition of `isDescentWord`, we need to show that for the word `w` consisting of all false values, `3^(oddCount k w) < 2^(evenCount k w)`.
  unfold isDescentWord;
  use fun _ => false;
  unfold oddCount evenCount; norm_num;
  linarith

end Collatz


-- NEW_FILE: Catalog/Algebra/ArrowCurvatureBridge/Arrow.lean
/-
# Arrow's Impossibility Theorem via Ultrafilters

This file formalizes the algebraic core of Arrow's impossibility theorem:
the decisive coalitions of any social welfare function satisfying Independence
of Irrelevant Alternatives (IIA) and the Pareto condition form an ultrafilter
on the set of voters. Since every ultrafilter on a finite set is principal,
there must exist a dictator.

## Main Results

* `DecisiveFamily` — the family of decisive coalitions for a SWF
* `decisive_family_is_ultrafilter` — decisive coalitions form an ultrafilter
* `arrow_impossibility` — Arrow's impossibility theorem for ≥ 3 alternatives
* `ultrafilter_finite_principal` — every ultrafilter on a finite type is principal

## References

* Arrow, K. J. (1951). Social Choice and Individual Values.
* Barberá, S. (1980). Pivotal voters: A new proof of Arrow's theorem.
-/
import Mathlib

open Finset Filter Set

/-! ## Preference Relations and Social Welfare Functions -/

/-- A strict preference relation on alternatives: irreflexive and transitive. -/
structure StrictPref (A : Type*) where
  rel : A → A → Prop
  irrefl : ∀ a, ¬ rel a a
  trans : ∀ a b c, rel a b → rel b c → rel a c

/-- A preference profile assigns a strict preference to each voter. -/
def PrefProfile (V A : Type*) := V → StrictPref A

/-- A social welfare function maps preference profiles to a social preference. -/
def SWF (V A : Type*) := PrefProfile V A → StrictPref A

/-- The Pareto condition: if all voters prefer a to b, so does society. -/
def Pareto {V A : Type*} (f : SWF V A) : Prop :=
  ∀ (P : PrefProfile V A) (a b : A),
    (∀ v : V, (P v).rel a b) → (f P).rel a b

/-- Independence of Irrelevant Alternatives: the social ranking of a vs b
    depends only on how each voter ranks a vs b. -/
def IIA {V A : Type*} (f : SWF V A) : Prop :=
  ∀ (P Q : PrefProfile V A) (a b : A),
    (∀ v : V, (P v).rel a b ↔ (Q v).rel a b) →
    ((f P).rel a b ↔ (f Q).rel a b)

/-- A coalition S is decisive for a over b if: whenever all voters in S
    pref
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Goldbach Representation Theory

## 1. Computational Verification of Goldbach up to Large Bounds

Extend the `goldbachCount` framework to computationally verify Goldbach's conjecture for all even integers up to 10^6 or beyond, using efficient sieve-based methods formalized in Lean. The key insight is that `native_decide` combined with a computable `goldbachCount` function allows us to bootstrap verified computation: we can prove `∀ n, Even n → 4 ≤ n → n ≤ N → HasGoldbachRep n` for concrete N by showing `goldbachCount n > 0` for each such n. Why now? Lean 4's compiler and `native_decide` are now fast enough that verification up to substantial bounds is feasible, and the computable `goldbachCount` we defined provides the necessary infrastructure. The challenge is scaling — a direct `native_decide` over all even numbers up to N requires careful batching to avoid timeout.

## 2. Goldbach Counting Function Asymptotics

Formalize the Hardy–Littlewood conjecture on the asymptotic density of Goldbach representations: that the number of representations of 2n as a sum of two primes is asymptotically `C₂ · 2n / (log 2n)² · ∏_{p|n, p odd} (p-1)/(p-2)`, where C₂ is the twin prime constant. The key insight is that the Goldbach counting function `goldbachCount` already provides the left-hand side; formalizing the singular series and proving even partial results (e.g., that `goldbachCount(2n) → ∞`) would connect our combinatorial framework to analytic number theory. Why now? Recent Mathlib additions around the prime number theorem and Dirichlet series bring the analytic prerequisites closer to what's needed, though significant infrastructure building remains.

## 3. Chen's Theorem: Every Large Even Number is P₁ + P₂

Formalize Chen's 1973 result that every sufficiently large even integer can be written as the sum of a prime and a number with at most two prime factors (a P₂ number). Our `HasChenRep` and `IsSemiprime` definitions provide the statement framework. The key insight is that the weighted sieve of Rosser–Iwaniec, when formalized, provides a lower bound on the number of Chen representations that exceeds the upper bound on the error term for sufficiently large n. Why now? The structural groundwork — semiprime characterization, the Goldbach-implies-Chen hierarchy, and the separation theorem `semiprime_not_prime` — is now in place, making the sieve theory the remaining bottleneck rather than the combinatorial framework.

## 4. Parity Barrier and Selberg Sieve Formalization

Formalize the "parity problem" in sieve theory: prove that no sieve of dimension 1 (in the Selberg–Iwaniec sense) can distinguish between numbers with an even vs. odd number of prime factors. The key insight is that this impossibility result explains precisely why Goldbach's conjecture cannot be resolved by sieve methods alone, and formalizing it would be the first machine-verified proof of a fundamental limitation theorem in analytic number theory. Why now? The parity
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
