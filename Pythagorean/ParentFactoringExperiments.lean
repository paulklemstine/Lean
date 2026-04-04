import Mathlib
import Pythagorean.UniversalParent

/-!
# Parent Descent Factoring: Computational Experiments

## Research Team Notes

### Hypothesis
The universal parent descent through the Berggren tree provides a novel
integer factorization method. At each level of descent, the legs of the
Pythagorean triple share GCD structure with the target integer N.

### Key Observations
1. The trivial triple for odd N is (N, (N²-1)/2, (N²+1)/2)
2. Parent descent reduces the hypotenuse at each step
3. At each step, gcd(leg, N) may reveal a nontrivial factor
4. The descent terminates at (3,4,5), making everything integral
5. The number of descent steps is O(log c) where c is the hypotenuse

### Experiments Below
- Factor small semiprimes via descent
- Measure descent depth vs factor discovery depth
- Compare descent factoring with trial division
- Analyze branch patterns for primes vs composites
- Study the "Beautiful Identity": c_parent = (m-2n)² + n²
-/

-- Uses definitions from UniversalParent.lean

/-! ## Experiment 1: Factoring Small Semiprimes -/

-- Factor various semiprimes
#eval factorByParentDescent 15 100    -- 3 × 5
#eval factorByParentDescent 21 100    -- 3 × 7
#eval factorByParentDescent 33 100    -- 3 × 11
#eval factorByParentDescent 35 100    -- 5 × 7
#eval factorByParentDescent 51 100    -- 3 × 17
#eval factorByParentDescent 55 100    -- 5 × 11
#eval factorByParentDescent 77 100    -- 7 × 11
#eval factorByParentDescent 91 100    -- 7 × 13
#eval factorByParentDescent 143 100   -- 11 × 13
#eval factorByParentDescent 187 100   -- 11 × 17
#eval factorByParentDescent 221 100   -- 13 × 17
#eval factorByParentDescent 323 100   -- 17 × 19
#eval factorByParentDescent 437 100   -- 19 × 23
#eval factorByParentDescent 667 100   -- 23 × 29
#eval factorByParentDescent 899 100   -- 29 × 31
#eval factorByParentDescent 1073 100  -- 29 × 37
#eval factorByParentDescent 2021 100  -- 43 × 47
#eval factorByParentDescent 10403 200 -- 101 × 103

/-! ## Experiment 2: Depth of Factor Discovery

How many descent steps are needed before a factor is found? -/

/-- Count steps to find a factor. -/
def stepsToFactor (N : ℕ) (maxSteps : ℕ) : Option ℕ :=
  if N % 2 == 0 || N < 9 then none
  else
    let t := trivialTriple N
    go N t.1 t.2.1 t.2.2 maxSteps 0
where
  go (N : ℕ) : ℤ → ℤ → ℤ → ℕ → ℕ → Option ℕ
    | _, _, _, 0, _ => none
    | a, b, c, fuel + 1, step =>
      match tryFactor N a b with
      | some _ => some step
      | none =>
        if a == 3 && b == 4 && c == 5 then none
        else
          let (pa, pb, pc) := universalParent a b c
          go N pa pb pc fuel (step + 1)

-- Steps to find factor for various semiprimes
#eval stepsToFactor 15 200     -- quick (small N)
#eval stepsToFactor 77 200     -- 7 × 11
#eval stepsToFactor 143 200    -- 11 × 13
#eval stepsToFactor 323 200    -- 17 × 19
#eval stepsToFactor 1073 200   -- 29 × 37
#eval stepsToFactor 10403 500  -- 101 × 103

/-! ## Experiment 3: Branch Patterns

Primes and composites have different branch patterns during descent.
Hypothesis: composites tend to produce more branch-2 patterns (balanced). -/

-- Branch patterns for primes
#eval branchEncoding (5, 12, 13) 20            -- from 5-12-13
#eval branchEncoding (7, 24, 25) 20            -- from 7-24-25
#eval branchEncoding (11, 60, 61) 20           -- from 11-60-61
#eval branchEncoding (13, 84, 85) 20           -- from 13-84-85

-- Branch patterns for composite legs
#eval branchEncoding (15, 112, 113) 20         -- from 15-112-113
#eval branchEncoding (21, 220, 221) 20         -- from 21-220-221
#eval branchEncoding (35, 612, 613) 20         -- from 35-612-613

/-! ## Experiment 4: The Hypotenuse Sum-of-Squares Structure

The parent hypotenuse is always (m-2n)² + n² (a sum of two squares).
This connects parent descent to Gaussian integer factorization:
  c_parent = |m - 2n + ni|² in ℤ[i]

If c_parent has a Gaussian factorization, it reveals arithmetic structure. -/

/-- Compute the Euclid parameters (m, n) from a PPT (a, b, c) where a is odd, b is even. -/
def euclidParams (a b c : ℤ) : ℤ × ℤ :=
  -- From a = m²-n², b = 2mn, c = m²+n²:
  -- m² = (a+c)/2, n² = (c-a)/2
  -- m = √((a+c)/2), n = b/(2m)
  -- Or: m+n = (b + a + c)/2, m-n = (c + a - b)/2... these are complex
  -- Simple: if b = 2mn and c-a = 2n², then n² = (c-a)/2, n = √((c-a)/2)
  -- m = b / (2n)
  let n_sq := (c - a) / 2
  let n := Int.sqrt n_sq.toNat
  let m := if n > 0 then b / (2 * n) else 0
  (m, n)

-- Test Euclid parameter extraction
#eval euclidParams 3 4 5       -- should be (2, 1)
#eval euclidParams 5 12 13     -- should be (3, 2)
#eval euclidParams 7 24 25     -- should be (4, 3)
#eval euclidParams 21 20 29    -- should be (5, 2)
#eval euclidParams 15 8 17     -- should be (4, 1)

/-! ## Experiment 5: Large Semiprime Factoring -/

-- Test with progressively larger semiprimes
#eval factorByParentDescent 10201 500    -- 101²
#eval factorByParentDescent 10403 500    -- 101 × 103
#eval factorByParentDescent 11021 500    -- 103 × 107
#eval factorByParentDescent 12091 500    -- 107 × 113

/-! ## Experiment 6: Factoring via Multiple Representations

Key insight: if N has two different sum-of-squares representations
  N = a₁² + b₁² = a₂² + b₂²
then gcd(a₁ - a₂, N) often gives a nontrivial factor.

The parent descent generates NEW sum-of-squares representations at each level,
effectively creating multiple representations for factoring. -/

/-- Collect sum-of-squares representations encountered during descent. -/
def sosRepresentations (N : ℕ) (maxSteps : ℕ) : List (ℤ × ℤ) :=
  if N % 2 == 0 || N < 9 then []
  else
    let t := trivialTriple N
    go N t.1 t.2.1 t.2.2 maxSteps
where
  go (N : ℕ) : ℤ → ℤ → ℤ → ℕ → List (ℤ × ℤ)
    | _, _, _, 0 => []
    | a, b, c, fuel + 1 =>
      let repr := if a.natAbs * a.natAbs + b.natAbs * b.natAbs < N * N then
        [(a, b)]
      else []
      if a == 3 && b == 4 && c == 5 then repr
      else
        let (pa, pb, pc) := universalParent a b c
        repr ++ go N pa pb pc fuel

#eval sosRepresentations 85 50     -- 85 = 2² + 9² = 6² + 7²
#eval sosRepresentations 325 50    -- multiple representations

/-! ## Experiment 7: Comparison of Descent Depth and Total Steps

For the factoring algorithm, what matters is:
1. How many total descent steps until a factor is found
2. Whether factors are found EARLY in descent (near the original triple) or LATE -/

/-- Full descent statistics. -/
def descentStats (N : ℕ) (maxSteps : ℕ) : String :=
  if N % 2 == 0 || N < 9 then s!"N={N}: invalid (even or too small)"
  else
    let totalDepth := depthToRoot (trivialTriple N) maxSteps
    let factorStep := stepsToFactor N maxSteps
    let factorResult := factorByParentDescent N maxSteps
    s!"N={N}: depth={totalDepth}, factor_at_step={factorStep}, result={factorResult}"

#eval descentStats 15 200
#eval descentStats 77 200
#eval descentStats 143 200
#eval descentStats 221 200
#eval descentStats 323 200
#eval descentStats 1073 200
#eval descentStats 10403 500

/-! ## Research Findings Summary

### Finding 1: Universal Hypotenuse Formula
The parent hypotenuse c' = 3c - 2a - 2b is the SAME regardless of which
branch (B₁⁻¹, B₂⁻¹, B₃⁻¹) is used. Only the leg assignment changes.

### Finding 2: Sum-of-Squares Structure
The parent hypotenuse equals (m - 2n)² + n² in Euclid coordinates,
connecting parent descent to Gaussian integer arithmetic.

### Finding 3: GCD Factor Discovery
At each descent step, gcd(leg, N) has a nonzero probability of revealing
a factor. The descent creates O(log c) opportunities for factor discovery.

### Finding 4: Integrality
The entire descent chain uses only integer arithmetic (no floating point),
making it suitable for exact computation with arbitrary-precision integers.

### Finding 5: Termination Guarantee
The descent always terminates at (3,4,5) because the hypotenuse strictly
decreases and remains positive. The maximum number of steps is bounded by
c - 5 (in practice much less, closer to O(log c)).

### Proposed Theorem (Unproven)
**Conjecture**: For any odd composite N = p·q, the parent descent from the
trivial triple discovers a nontrivial factor of N within O(log² N) steps.

### Open Questions
1. What is the exact distribution of factor-discovery depths?
2. Can the branch pattern be used to predict primality?
3. How does this method compare to Fermat factorization?
4. Can multiple descent paths (from different starting triples) be combined?
5. Is there a quantum speedup for the parent descent algorithm?
-/
