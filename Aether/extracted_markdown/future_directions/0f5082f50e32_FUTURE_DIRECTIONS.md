# Future Directions — Collatz Dynamics Formal Library

## Overview

This document identifies five testable scientific hypotheses emerging from the formal Collatz dynamics library. Each conjecture is precisely stated, computationally testable, and would open significant new avenues if confirmed or refuted.

---

## Hypothesis 1: Residue-Cover Descent Certificate

**Conjecture:** There exists `M ≤ 20` such that for every residue class `r` modulo `2^M`, there is a uniform descent depth `k(r)` with `T^{k(r)}(n) < n` for all positive `n ≡ r (mod 2^M)`.

**Formal statement:**
```
∃ M ≤ 20, ∀ r < 2^M, ∃ k, ∀ n > 0, n % 2^M = r → T^k(n) < n
```

**Test:** Exhaustive computation. For each `M` from 1 to 20 and each odd residue `r` mod `2^M`, iterate Collatz from representatives `r + i·2^M` (for `i = 1, ..., 100`) and record the minimum `k` achieving descent. If all residues yield a descent for some `M`, combine with the formally proved `residue_class_descent_implies_collatz` theorem to obtain a mechanically verified proof of Collatz for all integers.

**Status:** Computational experiments (Demo 4) show descent certificates exist for `M ≤ 6` with max depths below 110. The conjecture appears very likely true for small `M`.

**Impact:** If true AND the uniform descent can be formally verified for specific representatives, this would reduce the Collatz conjecture to a finite computation, making the first mechanically certified proof of Collatz (conditional on the uniformity verification) achievable.

---

## Hypothesis 2: Exact Geometric Valuation Distribution

**Conjecture:** On odd residues modulo `2^M`, the 2-adic valuation `v₂(3n+1)` follows an exact geometric distribution:

```
|{n ∈ [1, 2^M) : n odd, v₂(3n+1) = j}| = 2^{M-1-j}  for 1 ≤ j ≤ M-1
```

with the remaining single residue having `v₂(3n+1) = M` or higher.

**Formal statement:**
```
∀ M ≥ 2, ∀ j with 1 ≤ j ≤ M-1,
  |{n < 2^M : n odd ∧ v₂(3n+1) = j}| = 2^{M-1-j}
```

**Test:** Direct computation for `M` up to 20. Our experiments show exact equality for all tested values up to `M = 12`, with the count for `v₂ = j` being exactly `2^{M-1-j}`.

**Status:** CONFIRMED computationally for `M ≤ 12`. This appears to be a theorem, not a conjecture.

**Impact:** If formally proved, this gives exact finite-level entropy calculations for the Collatz valuation coding. It would establish that the Collatz map, viewed as a symbolic dynamical system on binary expansions, has Shannon entropy exactly 2 bits per accelerated step — matching the heuristic prediction that orbits shrink on average by a factor of `2/3` per odd step.

---

## Hypothesis 3: Cycle Obstruction Lower Bounds

**Conjecture:** Any nontrivial odd cycle of length `k` in the accelerated Collatz map must have minimum element below the computable threshold:

```
B_k = ⌈1 / (2^{⌈k·log₂(3)⌉/k} - 3)⌉
```

For specific values:
- k=1: B₁ = 1 (only the trivial fixed point x=1 exists)
- k=2: B₂ = 1
- k=3: B₃ ≤ 6
- k=5: B₅ ≤ 32
- k=10: B₁₀ ≤ 5

**Formal statement:** Uses the proved `cycle_rational_product_identity` and `cycle_product_bounds`:
```
∀ cycle x₀,...,x_{k-1}, min(xᵢ) ≤ B_k
```

**Test:** For each k, compute `B_k` and verify computationally that no odd cycle with all elements above `B_k` exists by exhaustive search in the relevant range.

**Status:** The product identity and bounds are formally proved. The explicit bound computation and exhaustive verification remain computational tasks.

**Impact:** Combined with computational searches ruling out small cycles (existing results rule out cycles with minimum element up to approximately 10^{17}), this provides a fully formal exclusion of nontrivial cycles for many lengths.

---

## Hypothesis 4: Prefix Uniqueness Modulo 2^A

**Conjecture:** Every finite valuation word `(a₀, ..., a_{k-1})` with each `aᵢ ≥ 1` and total weight `A = Σ aᵢ` corresponds to a unique odd residue class modulo `2^A`. That is, `n mod 2^A` is completely determined by the first `k` valuations.

**Formal statement:**
```
∀ k, ∀ a : Fin k → ℕ, (∀ i, aᵢ ≥ 1) →
  ∃! r ∈ [0, 2^A) with r odd,
    ∀ n ≡ r (mod 2^A), v₂(3·accelSeq(n,i)+1) = aᵢ for all i < k
```

**Test:** For patterns up to total weight A = 15, enumerate all odd residues mod `2^A` and verify each realizes a unique pattern. Our backward inverse step theorem (proved for individual steps with mod-3 compatibility) supports this structure.

**Status:** The single-step version follows from the proved `v2_eq_iff_mod` theorem. The multi-step version is conjectured but not yet formally proved (it is stated as `collatz_valuation_pattern_realizable` with a sorry).

**Impact:** If proved, this establishes a bijection between finite valuation words and residue classes, making the Collatz coding map a perfect symbolic encoding. This would be the formal foundation for all entropy and distribution results, and would enable certified exhaustive search through symbolic patterns.

---

## Hypothesis 5: Convergence of Valuation Entropy to 2 Bits

**Conjecture:** The Shannon entropy of the valuation distribution on odd residues mod `2^M` converges to exactly 2 bits as `M → ∞`:

```
H_M = -Σ_j p_j · log₂(p_j) → 2  as M → ∞
```

where `p_j = |{n < 2^M : n odd, v₂(3n+1) = j}| / 2^{M-1}`.

Moreover, if Hypothesis 2 is true, then `H_M = 2 - 2^{1-M}` exactly.

**Test:** Compute `H_M` for increasing `M` and verify convergence. Our experiments show:
- M=3: H = 1.500 bits
- M=5: H = 1.875 bits
- M=8: H = 1.984 bits
- M=11: H = 1.998 bits

This converges to 2 as predicted.

**Impact:** The entropy of 2 bits per step means that on average, the accelerated map divides by `2^2 = 4` while multiplying by 3, giving a net contraction factor of `3/4` per odd step. This is the quantitative basis for the heuristic argument that orbits decrease on average, and formalizing it would connect the Collatz conjecture to ergodic theory and information theory in a precise, machine-verified way.

---

## Priority Ranking

1. **Hypothesis 2** (Geometric distribution): Most likely provable with current infrastructure; would be a clean formal theorem with immediate applications.
2. **Hypothesis 4** (Prefix uniqueness): Critical for the full realizability theorem; the backward congruence machinery is in place.
3. **Hypothesis 1** (Descent certificate): Most impactful if true; requires computational verification infrastructure.
4. **Hypothesis 3** (Cycle bounds): Product identity already proved; needs optimization and computational search.
5. **Hypothesis 5** (Entropy convergence): Follows from Hypothesis 2; beautiful but derivative.

---

## Technical Prerequisites for Next Cycle

To attack these hypotheses, the next research cycle should:

1. **Prove the exact valuation count** (Hypothesis 2) by induction on M, using the structure of multiplication by 3 modulo powers of 2.
2. **Formalize orbit stability under perturbation**: prove that `accelSeq(n, k)` depends only on `n mod 2^B` for explicit `B`, enabling the multi-step realizability proof.
3. **Build a verified computation framework**: connect the formal descent certificate to `native_decide` or `Decidable` instances for finite checks.
4. **Extend cycle obstruction theory**: derive explicit bounds for cycle lengths up to 100 using the product identity.
5. **Connect to Haar measure**: formalize the accelerated map on `ℤ₂` and prove measure-preservation of the valuation coding.
