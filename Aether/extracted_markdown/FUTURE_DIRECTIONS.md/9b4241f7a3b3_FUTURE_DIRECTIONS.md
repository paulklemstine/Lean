# Future Directions: Collatz Parity Contraction Theory

## What We Proved

This cycle formalized four key results about Collatz orbit structure in `Catalog/Computation/CollatzParityContraction.lean`:

1. **Parity Exclusion** — after an odd Collatz step (3n+1), the result is always even, so consecutive odd steps are impossible.
2. **Power Comparison** — 3^j < 2^k whenever 2j < k (j ≥ 1), the arithmetic engine behind density contraction.
3. **Parity Density Bound** — at most ⌈k/2⌉ of the first k orbit values can be odd, a quantitative consequence of parity exclusion.
4. **Orbit Determinism** — if two Collatz trajectories meet, they agree on all subsequent iterates.

---

## Direction 1: Sharp Contraction Threshold via Real Logarithms

The current power comparison requires 2j < k (odd density < 1/2), but the optimal threshold is j/k < log(2)/log(3) ≈ 0.6309. The key insight is that the real-valued inequality j · log(3) < (k−j) · log(2) is equivalent to 3^j < 2^(k−j), which transfers to ℕ via Nat.cast_lt. This would give the tightest formal contraction criterion known.

**Why now?** Mathlib's `Real.log` API is mature enough to formalize this chain: define the contraction condition as `j * Real.log 3 < (k - j) * Real.log 2`, prove equivalence with `(3 : ℝ)^j < (2 : ℝ)^(k-j)` via `Real.exp_log` and monotonicity, then transfer to ℕ. The `pow3_le_pow4` and `pow3_lt_pow2_of_two_mul_lt` lemmas from this cycle provide the integer-side infrastructure.

**Testable claim**: For k = 100 and j = 63 (density 0.63 < log2/log3), one should be able to prove 3^63 < 2^37 using the real logarithm path, while 2·63 = 126 > 100 means the integer-only path fails.

---

## Direction 2: Orbit Affine Upper Bound

After j odd steps and e even steps in a Collatz orbit starting at n, the orbit value is bounded above by (n · 3^j + 2 · 3^j) / 2^e. The key insight is that each odd step multiplies by at most 3 and adds at most 1 (contributing the +2·3^j error term from geometric series), while each even step divides by 2. Combined with `pow3_lt_pow2_of_two_mul_lt`, this gives an explicit contraction criterion: if 2j < e, the orbit value after j+e steps is less than n for sufficiently large n.

**Why now?** The parity exclusion bound `oddCount_le_half_ceil` guarantees that e ≥ j (at least as many even steps as odd steps), and the power comparison lemma handles the 3^j vs 2^e comparison. The missing piece is formalizing the affine recurrence T(n) ≤ (3n+1)/2 for odd-then-even steps.

**Testable claim**: For n = 27 (111-step orbit), with j = 41 odd steps and e = 70 even steps, verify that 27 · 3^41 / 2^70 < 27.

---

## Direction 3: Residue Class Descent Automation

The file `Catalog/Algebra/ResidueDescent.lean` proves that a finite residue-class descent certificate would imply the Collatz conjecture. The key insight is that combining parity exclusion with modular arithmetic can automatically generate descent certificates for small moduli. For modulus 2^M, each residue class mod 2^M determines exactly M steps of the Collatz orbit, and parity exclusion constrains which step sequences are realizable.

**Why now?** The `collatz_odd_step_yields_even` theorem eliminates half the candidate step sequences, making certificate search tractable. For M = 8, one needs to check 256 residue classes, but parity exclusion reduces the number of realizable 8-step parity words from 256 to at most 55 (Fibonacci number F_10, counting binary words with no consecutive 1s).

**Testable claim**: Formally verify descent certificates for all residue classes mod 2^4 (16 classes) and mod 2^6 (64 classes), using `oddCount_le_half_ceil` to bound the number of odd steps and `pow3_lt_pow2_of_two_mul_lt` to verify contraction.

---

## Direction 4: Fibonacci Connection to Parity Words

The number of valid parity words of length k (binary strings with no consecutive 1s) is the Fibonacci number F_{k+2}. The key insight is that `oddCount_le_half_ceil` is a corollary of a deeper structural fact: the set of realizable Collatz parity words is a subset of the Fibonacci-counted set of "no two consecutive ones" binary strings. This Fibonacci structure connects Collatz dynamics to the theory of independent sets in path graphs.

**Why now?** Mathlib has `Nat.fib` and basic Fibonacci identities. The combinatorial claim that |{w ∈ {0,1}^k : no consecutive 1s}| = F_{k+2} is provable by strong induction (the same structure used in `oddCount_le_half_ceil`). Connecting this to the actual Collatz parity constraint would upgrade the density bound from ⌈k/2⌉ to a precise count.

**Testable claim**: Prove that `Finset.card ((Finset.range (2^k)).filter (fun w => ∀ i < k-1, ¬(Nat.testBit w i = true ∧ Nat.testBit w (i+1) = true))) = Nat.fib (k+2)` for k ≤ 10 by computation, then prove it in general.

---

## Direction 5: Parity Exclusion in Generalized Collatz Systems

For a generalized Collatz system with modulus m (where the standard Collatz has m = 2), define the step function T_m and study which residue classes force consecutive applications of the same branch. The key insight is that parity exclusion generalizes: for the standard system, the "odd branch" maps odd numbers to even numbers, but for m = 3 (the "3n+1 mod 3" system), the branch structure is richer and may or may not have exclusion properties.

**Why now?** The GCS framework in `Catalog/Bridges/Defs.lean` defines generalized systems. Extending `collatz_odd_step_yields_even` to GCS would characterize which systems have automatic density bounds on branch usage, potentially distinguishing "tame" GCS (with exclusion, hence bounded density) from "wild" GCS (without exclusion, potentially undecidable).

**Testable claim**: For the GCS with modulus 3 and rules {0 ↦ n/3, 1 ↦ (2n+1)/3, 2 ↦ (4n+1)/3}, determine whether any branch-exclusion property holds by checking all residue classes mod 9.
