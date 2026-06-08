/-
# Prime Fractal: Hausdorff Dimension of Prime Distributions — Core Definitions

We define a logarithmic metric on the primes: d(p,q) = |1/log(p) - 1/log(q)|.
This metric compresses large primes and stretches small ones, revealing fractal
structure in the distribution of primes.
-/
import Mathlib

open Real Finset Nat BigOperators

/-- The logarithmic embedding of a natural number into ℝ: n ↦ 1/log(n).
    This maps primes into (0, 1/log 2] and is the foundation of the prime fractal metric. -/
noncomputable def logEmbed (n : ℕ) : ℝ := 1 / Real.log (n : ℝ)

/-- The prime fractal metric: d(p,q) = |1/log(p) - 1/log(q)|.
    This is a pseudometric on ℕ and a metric when restricted to primes ≥ 2. -/
noncomputable def primeFractalDist (p q : ℕ) : ℝ := |logEmbed p - logEmbed q|

/-- A prime pair (p, p+2) where both are prime. -/
structure TwinPrimePair where
  p : ℕ
  hp : Nat.Prime p
  hp2 : Nat.Prime (p + 2)

/-- The box-counting function for the prime fractal up to bound N with resolution ε. -/
noncomputable def boxCount (N : ℕ) (ε : ℝ) : ℕ :=
  ((Finset.range (N + 1)).filter Nat.Prime |>.image
    (fun p => Int.floor (logEmbed p / ε))).card

/-- The box-counting dimension approximant: log(boxCount)/log(1/ε). -/
noncomputable def boxDimApprox (N : ℕ) (ε : ℝ) : ℝ :=
  Real.log (boxCount N ε : ℝ) / Real.log (1 / ε)

/-- Helper: the frequency of primes in a given box b. -/
noncomputable def primeBoxFreq (N : ℕ) (ε : ℝ) (b : ℤ) : ℝ :=
  ((((Finset.range (N + 1)).filter Nat.Prime).filter
    (fun p => Int.floor (logEmbed p / ε) = b)).card : ℝ) /
  (((Finset.range (N + 1)).filter Nat.Prime).card : ℝ)

/-- Shannon entropy term: f · log(f) if f > 0, else 0. -/
noncomputable def entropyTerm (f : ℝ) : ℝ :=
  if f > 0 then f * Real.log f else 0

/-- Information-theoretic entropy of the prime distribution in the logarithmic metric.
    Given primes up to N, partition into intervals of width ε,
    and compute the Shannon entropy of the resulting histogram. -/
noncomputable def primeLogEntropy (N : ℕ) (ε : ℝ) : ℝ :=
  -(((Finset.range (N + 1)).filter Nat.Prime |>.image
    (fun p => Int.floor (logEmbed p / ε))).sum
    (fun b => entropyTerm (primeBoxFreq N ε b)))