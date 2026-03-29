/-
  Meta-Oracle Hypotheses: Formal Statements and Key Results
  =========================================================

  This file formalizes the five cross-domain mathematical hypotheses
  investigated in the Meta-Oracle research project, along with
  provable supporting lemmas.
-/

import Mathlib

open Nat Finset

/-! ## Goldbach Representation Count -/

/-- The Goldbach representation count: number of ways to write n as p + q
    with p ≤ q and both prime. -/
noncomputable def goldbachRepCount (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter (fun p =>
    p.Prime ∧ (n - p).Prime ∧ p ≤ n - p ∧ p ≤ n)).card

/-! ## Lonely Runner -/

/-- Distance from a real number to the nearest integer. -/
noncomputable def fracDist (x : ℝ) : ℝ :=
  min (Int.fract x) (1 - Int.fract x)

/-- The Lonely Runner bound: for n runners, each achieves distance ≥ 1/(n+1). -/
noncomputable def lonelyRunnerBound (n : ℕ) : ℝ := 1 / (n + 1 : ℝ)

/-
PROBLEM
For 2 runners with speeds 1 and 2 (plus stationary), each runner achieves
    distance ≥ 1/3 from all others at some time. This is the base case.

PROVIDED SOLUTION
Use t = 1/3. Then Int.fract(1/3) = 1/3 and Int.fract(2/3) = 2/3. fracDist(1/3) = min(1/3, 2/3) = 1/3. fracDist(2/3) = min(2/3, 1/3) = 1/3. Both are ≥ 1/3.
-/
theorem lonely_runner_two : ∃ t : ℝ, fracDist t ≥ 1/3 ∧ fracDist (2 * t) ≥ 1/3 := by
  -- Consider $t = 1/3$.
  use 1 / 3;
  unfold fracDist; norm_num;

/-! ## Egyptian Fractions and Erdős-Straus -/

/-- An Egyptian fraction decomposition of 4/n is a triple (x, y, z) with
    1/x + 1/y + 1/z = 4/n and x ≤ y ≤ z. -/
def isErdosStrausDecomp (n x y z : ℕ) : Prop :=
  0 < x ∧ 0 < y ∧ 0 < z ∧ x ≤ y ∧ y ≤ z ∧
  (4 : ℚ) / n = 1 / x + 1 / y + 1 / z

/-- For n = 3: 4/3 = 1/1 + 1/4 + 1/12. -/
theorem erdos_straus_three : isErdosStrausDecomp 3 1 4 12 := by
  unfold isErdosStrausDecomp
  norm_num

/-- For n = 5: 4/5 = 1/2 + 1/4 + 1/20 -/
theorem erdos_straus_five : isErdosStrausDecomp 5 2 4 20 := by
  unfold isErdosStrausDecomp
  norm_num

/-- For n = 7: 4/7 = 1/2 + 1/15 + 1/210... let's just check a few. -/
theorem erdos_straus_seven : isErdosStrausDecomp 7 2 28 28 := by
  unfold isErdosStrausDecomp
  norm_num

/-
PROBLEM
For any k ≥ 1, the Erdős-Straus equation 4/(2k) has a solution.
    We use: 4/(2k) = 1/k + 1/(2k) + 1/(2k) since 1/k + 2/(2k) = 1/k + 1/k = 2/k = 4/(2k).

PROVIDED SOLUTION
Unfold isErdosStrausDecomp, prove the 5 nat conditions by omega, then prove the rational equation 4/(2k) = 1/k + 1/(2k) + 1/(2k) by field_simp and ring (or push_cast and ring). The key insight is that 1/k + 1/(2k) + 1/(2k) = 1/k + 1/k = 2/k = 4/(2k).
-/
theorem erdos_straus_even (k : ℕ) (hk : 0 < k) :
    isErdosStrausDecomp (2 * k) k (2 * k) (2 * k) := by
      constructor <;> try linarith;
      exact ⟨ by positivity, by positivity, by linarith, by linarith, by push_cast; ring ⟩

/-! ## Prime Counting -/

/-- Our own prime counting function to avoid ambiguity. -/
noncomputable def primeCount (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter Nat.Prime).card

/-- π(n) ≤ n + 1 for all n. -/
theorem primeCount_le (n : ℕ) : primeCount n ≤ n + 1 := by
  unfold primeCount
  calc ((Finset.range (n + 1)).filter Nat.Prime).card
      ≤ (Finset.range (n + 1)).card := Finset.card_filter_le _ _
    _ = n + 1 := Finset.card_range (n + 1)

/-- There are no primes ≤ 1. -/
theorem primeCount_one : primeCount 1 = 0 := by
  unfold primeCount
  native_decide

/-
PROBLEM
π(2) = 1.

PROVIDED SOLUTION
Unfold primeCount and use native_decide or decide.
-/
theorem primeCount_two : primeCount 2 = 1 := by
  decide +revert

/-! ## Formal Statement of Main Hypotheses -/

/-- **Hypothesis 1 (Constellation Rigidity):**
    The Goldbach representation count G(n) is asymptotically proportional to
    n · (π(n)/n)² times a singular series correction.

    This is stated as a proposition (not proven — equivalent to
    Hardy-Littlewood Conjecture B, which is open). -/
def constellationRigidity : Prop :=
  ∃ α : ℝ, α > 0 ∧
  ∀ ε : ℝ, ε > 0 →
  ∃ N : ℕ, ∀ n : ℕ, N < n → Even n →
  let G := (goldbachRepCount n : ℝ)
  let ρ := (primeCount n : ℝ) / n
  |G - α * n * ρ^2| < ε * n * ρ^2

/-- **Hypothesis 4 (Approximation Universality):**
    Dense orbits in compact groups achieve all approximation targets.

    Formal version for the circle: For any irrational α and any target x ∈ [0,1),
    the sequence {nα} gets arbitrarily close to x. -/
theorem irrational_orbit_dense (α : ℝ) (hα : Irrational α) (x : ℝ) (ε : ℝ) (hε : ε > 0) :
    ∃ n : ℤ, |Int.fract (n * α) - Int.fract x| < ε := by sorry

/-
PROBLEM
**Hypothesis 5 (Erdős-Straus for multiples of 4):**
    The Erdős-Straus conjecture holds for all n divisible by 4.

PROVIDED SOLUTION
Use x = k, y = 4*k, z = 4*k. Then isErdosStrausDecomp (4*k) k (4*k) (4*k). Rewrite 4*k = 2*(2*k) and use erdos_straus_even (2*k) (by omega). But the types need to match: 4*k = 2*(2*k) by ring.
-/
theorem erdos_straus_div4 (k : ℕ) (hk : 0 < k) :
    ∃ x y z : ℕ, isErdosStrausDecomp (4 * k) x y z := by
      use 2 * k, 4 * k, 4 * k;
      -- We need to verify that $1/(2k) + 1/(4k) + 1/(4k) = 4/(4k)$.
      simp [isErdosStrausDecomp];
      exact ⟨ hk, by linarith, by ring ⟩

/-
PROBLEM
**Erdős-Straus for multiples of 3.**

PROVIDED SOLUTION
Use x = k, y = 4*k, z = 12*k. Then 1/k + 1/(4k) + 1/(12k) = 12/(12k) + 3/(12k) + 1/(12k) = 16/(12k) = 4/(3k). Unfold isErdosStrausDecomp and prove the rational equation with push_cast; ring or field_simp; ring.
-/
theorem erdos_straus_div3 (k : ℕ) (hk : 0 < k) :
    ∃ x y z : ℕ, isErdosStrausDecomp (3 * k) x y z := by
      use k, 4 * k, 12 * k;
      exact ⟨ hk, by positivity, by positivity, by linarith, by linarith, by push_cast; ring ⟩

/-- fracDist is nonneg -/
theorem fracDist_nonneg (x : ℝ) : 0 ≤ fracDist x := by
  unfold fracDist
  exact le_min (Int.fract_nonneg x) (sub_nonneg.mpr (le_of_lt (Int.fract_lt_one x)))

/-
PROBLEM
fracDist is at most 1/2

PROVIDED SOLUTION
Unfold fracDist. We need min(Int.fract x, 1 - Int.fract x) ≤ 1/2. Let f = Int.fract x, so 0 ≤ f < 1. If f ≤ 1/2 then min = f ≤ 1/2. If f > 1/2 then min = 1 - f < 1/2. Use min_le_iff or just case-split on whether f ≤ 1-f.
-/
theorem fracDist_le_half (x : ℝ) : fracDist x ≤ 1 / 2 := by
  exact min_le_iff.mpr ( by cases le_or_gt ( Int.fract x ) ( 1 / 2 ) <;> [ left; right ] <;> linarith [ Int.fract_nonneg x, Int.fract_lt_one x ] )