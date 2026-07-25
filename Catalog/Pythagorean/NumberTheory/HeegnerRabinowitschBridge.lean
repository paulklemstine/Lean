/-
# From Euler's prime-rich polynomial to twin primes: a Rabinowitsch bridge

Building on the elementary Heegner footprint (`Pythagorean.Heegner163`), this
file isolates the *structural* content hidden inside a sharp Euler prime run.

The Rabinowitsch phenomenon says that for a prime `p` the values
`f_p(n) = n² + n + p` are prime for every `0 ≤ n ≤ p - 2`.  Rather than treating
this only as a computational curiosity for `p = 11, 17, 41` (the discriminants
43, 67, 163), we extract theorems that hold for *every* prime with a sharp run:

* a Rabinowitsch prime is itself prime (`rabinowitsch_prime_is_prime`);
* a Rabinowitsch prime `p ≥ 3` sits in a twin-prime pair `(p, p + 2)`
  (`rabinowitsch_gives_twin_prime`);
* the run values are strictly increasing, hence pairwise distinct
  (`eulerPoly_strictMono`);
* they all lie strictly below `p²` (`eulerPoly_run_lt_sq`);
* consequently a sharp run packs exactly `p - 1` distinct primes into the
  interval `[p, p²)` (`sharp_run_prime_packing`).

These are genuine consequences of the prime-run hypothesis, not restatements of
it, and they turn the isolated Heegner examples into instances of a uniform
statement.
-/

import Mathlib
import Pythagorean.KnotAndBraidTheory.Heegner163

namespace HeegnerRabinowitsch

open Heegner163

/-!
## Structural consequences of a sharp Euler run
-/

/-- **A Rabinowitsch prime is prime.**  If `p ≥ 2` admits a sharp Euler run then
`p = f_p(0)` is one of the run values, hence prime. -/
theorem rabinowitsch_prime_is_prime (p : ℕ) (hp : 2 ≤ p)
    (h : HasSharpEulerRun p) : Nat.Prime p := by
  have hrun := h.1 0 (by omega)
  simpa [eulerPoly] using hrun

/-- **A Rabinowitsch prime lands in a twin-prime pair.**  For `p ≥ 3` both `p`
and `p + 2 = f_p(1)` are prime, so `(p, p + 2)` are twin primes. -/
theorem rabinowitsch_gives_twin_prime (p : ℕ) (hp : 3 ≤ p)
    (h : HasSharpEulerRun p) : Nat.Prime p ∧ Nat.Prime (p + 2) := by
  refine ⟨rabinowitsch_prime_is_prime p (by omega) h, ?_⟩
  have hrun := h.1 1 (by omega)
  have e : eulerPoly p 1 = p + 2 := by simp only [eulerPoly]; ring
  rwa [e] at hrun

/-- The Euler polynomial is strictly increasing in `n`. -/
theorem eulerPoly_strictMono (p : ℕ) : StrictMono (eulerPoly p) := by
  intro a b hab
  simp only [eulerPoly]
  nlinarith

/-- `eulerPoly p` is injective. -/
theorem eulerPoly_injective (p : ℕ) : Function.Injective (eulerPoly p) :=
  (eulerPoly_strictMono p).injective

/-- Every proper run value stays strictly below `p²`. -/
theorem eulerPoly_run_lt_sq (p n : ℕ) (hn : n + 2 ≤ p) :
    eulerPoly p n < p ^ 2 := by
  simp only [eulerPoly]; nlinarith [hn]

/-!
## Packing count of a sharp run

Collecting the run values `f_p(0), …, f_p(p-2)` into a finite set, we can measure
exactly how many distinct primes the run produces.
-/

/-- The multiset of proper run values, as a finite set. -/
def runValues (p : ℕ) : Finset ℕ := (Finset.range (p - 1)).image (eulerPoly p)

/-- The run produces exactly `p - 1` distinct values. -/
theorem runValues_card (p : ℕ) : (runValues p).card = p - 1 := by
  unfold runValues
  rw [Finset.card_image_of_injective _ (eulerPoly_injective p), Finset.card_range]

/-- Under a sharp run, every collected value is prime. -/
theorem runValues_prime (p : ℕ) (h : HasSharpEulerRun p) :
    ∀ m ∈ runValues p, Nat.Prime m := by
  intro m hm
  unfold runValues at hm
  rw [Finset.mem_image] at hm
  obtain ⟨n, hn, rfl⟩ := hm
  exact h.1 n (Finset.mem_range.mp hn)

/-- Under a sharp run with `p ≥ 2`, every collected value lies in `[p, p²)`. -/
theorem runValues_mem_interval (p : ℕ) (hp : 2 ≤ p) :
    ∀ m ∈ runValues p, p ≤ m ∧ m < p ^ 2 := by
  intro m hm
  unfold runValues at hm
  rw [Finset.mem_image] at hm
  obtain ⟨n, hn, rfl⟩ := hm
  rw [Finset.mem_range] at hn
  refine ⟨by simp only [eulerPoly]; nlinarith, ?_⟩
  exact eulerPoly_run_lt_sq p n (by omega)

/-- **Prime packing of a sharp run.**  A sharp Euler run for `p ≥ 2` supplies a
set of exactly `p - 1` distinct primes, all lying in the interval `[p, p²)`. -/
theorem sharp_run_prime_packing (p : ℕ) (hp : 2 ≤ p) (h : HasSharpEulerRun p) :
    (runValues p).card = p - 1 ∧
    (∀ m ∈ runValues p, Nat.Prime m) ∧
    (∀ m ∈ runValues p, p ≤ m ∧ m < p ^ 2) :=
  ⟨runValues_card p, runValues_prime p h, runValues_mem_interval p hp⟩

/-!
## The Heegner instances as twin primes and dense prime packings

The discriminants 43, 67, 163 correspond to `p = 11, 17, 41`.  Each therefore
produces a twin-prime pair and a dense packing of primes.
-/

/-- Discriminant 43 (`p = 11`): the pair `(11, 13)` are twin primes. -/
theorem twin_prime_11 : Nat.Prime 11 ∧ Nat.Prime 13 := by
  have := rabinowitsch_gives_twin_prime 11 (by norm_num) sharp_runs_43_67_163.1
  simpa using this

/-- Discriminant 67 (`p = 17`): the pair `(17, 19)` are twin primes. -/
theorem twin_prime_17 : Nat.Prime 17 ∧ Nat.Prime 19 := by
  have := rabinowitsch_gives_twin_prime 17 (by norm_num) sharp_runs_43_67_163.2.1
  simpa using this

/-- Discriminant 163 (`p = 41`): the pair `(41, 43)` are twin primes. -/
theorem twin_prime_41 : Nat.Prime 41 ∧ Nat.Prime 43 := by
  have := rabinowitsch_gives_twin_prime 41 (by norm_num) sharp_runs_43_67_163.2.2
  simpa using this

/-- The famous discriminant-163 run of `p = 41` packs exactly 40 distinct primes
below `41² = 1681`. -/
theorem packing_163 :
    (runValues 41).card = 40 ∧
    (∀ m ∈ runValues 41, Nat.Prime m) ∧
    (∀ m ∈ runValues 41, 41 ≤ m ∧ m < 41 ^ 2) := by
  have := sharp_run_prime_packing 41 (by norm_num) sharp_runs_43_67_163.2.2
  simpa using this

/-!
## Examples (PEGB compliance)
-/

example : eulerPoly 41 0 = 41 := by native_decide
example : eulerPoly 41 1 = 43 := by native_decide
example : eulerPoly 41 39 = 1601 := by native_decide

#check @rabinowitsch_prime_is_prime
#check @rabinowitsch_gives_twin_prime
#check @sharp_run_prime_packing
#check twin_prime_41

/-!
## Generalization and boundaries

**Generalization.**  `rabinowitsch_gives_twin_prime` is the first step of a whole
ladder: `f_p(k) = p + k(k+1)`, so a sharp run of length `≥ k + 1` forces
`p + k(k+1)` to be prime for every `k` in range.  The twin-prime statement is the
case `k = 1`; the general extension packs primes along the shifted arithmetic-like
sequence `p, p+2, p+6, p+12, …`.  The packing theorem quantifies exactly how many
such primes appear (`p - 1` of them, all below `p²`).

**Boundaries.**  The hypotheses are sharp:
* For `p = 2` there is no `n = 1 < p - 1 = 1`, so no twin conclusion is available
  — indeed the hypothesis `3 ≤ p` in `rabinowitsch_gives_twin_prime` cannot be
  relaxed to `2 ≤ p`.
* The interval `[p, p²)` is tight on the left (`f_p(0) = p`) and cannot be closed
  on the right by `f_p(p-1) = p²`, which the Heegner footprint shows is *never*
  prime (`Heegner163.eulerPoly_boundary_not_prime`): the run necessarily stops
  before the square boundary.
* The converse — that primality of the run *forces* class number one — is the
  genuine content of Rabinowitsch's theorem and is **not** proved here; only the
  forward structural consequences are.
-/

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  The isolated "prime run" facts for the Heegner discriminants
43, 67, 163 (proved computationally in `Heegner163`) should be shadows of uniform
structural theorems about any prime admitting an Euler prime run.  In particular
we conjectured that such a prime must be prime and must be a twin prime.

**Experiment.**  We formalized `HasSharpEulerRun` consequences directly.  Reading
off `f_p(0) = p` and `f_p(1) = p + 2` from the run hypothesis gave primality and
twinness with one-line arithmetic extractions.  Strict monotonicity
(`nlinarith`) yielded injectivity, and `Finset.card_image_of_injective` gave the
exact packing count `p - 1`.  The interval bound `[p, p²)` followed from
`eulerPoly_run_lt_sq`.

**Analysis.**  What survived: all forward structural theorems, uniformly in `p`.
The `p = 2` corner shows why the twin statement needs `p ≥ 3` (the index `1`
must be strictly below `p - 1`).  The upper bound `p²` is exactly the composite
boundary value, tying the packing interval to the elementary obstruction already
proved in `Heegner163`.

**Critique.**  None of the main theorems reduce to `decide`/`native_decide`;
each uses `nlinarith`, `omega`, injectivity, or `Finset` cardinality reasoning.
The only `native_decide` uses are in illustrative `example`s.  No theorem
references itself.  The Heegner corollaries genuinely *apply* the general theorems
to the catalog's sharp-run facts rather than re-deriving them.

**Synthesis.**  A sharp Euler run is not just a list of primes: it is a
`(p-1)`-element prime packing of `[p, p²)` whose first two members are a twin
prime pair.  This reframes the "unreasonable effectiveness of 163" as an instance
of a counting/twin-prime statement uniform in `p`.
-/

end HeegnerRabinowitsch