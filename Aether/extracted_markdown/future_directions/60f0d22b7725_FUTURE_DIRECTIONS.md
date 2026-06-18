# Future Directions in Formal Meta-Complexity

## Summary

This document identifies five falsifiable scientific hypotheses extending the formal meta-complexity framework established in this cycle. Each hypothesis is concrete enough to be tested computationally and proved or disproved in a formal proof assistant.

---

## Hypothesis 1: Exact Symmetric Witness Formula

**Conjecture:** For any symmetric Boolean function `f : (Fin n → Bool) → Bool` with profile `p : Fin (n+1) → Bool`, the KW witness cardinality is exactly:

```
|KWWitness(f)| = Σ_{k=0}^{n} Σ_{l=0}^{n} [p(k)=true ∧ p(l)=false] · C(n,k) · C(n,l) · |k-l|
```

**Lean objects involved:** `MetaComplexity.KWWitness`, `MetaComplexity.hammingWeight`, `MetaComplexity.IsSymmetric`, `Nat.choose`, `Nat.dist`.

**Test:** Compute both sides for all symmetric functions on n ≤ 8 variables. The formula should match the brute-force count in every case. A formal proof would proceed by partitioning `KWWitness(f)` by Hamming weight pairs (k,l) and showing each pair (x,y) of weights (k,l) contributes exactly |k-l| witnesses.

**Refutation criterion:** A single symmetric function where the formula gives a different value from the brute-force count would refute this. Computational evidence (verified for n ≤ 8 in this cycle's Python demos) strongly supports the conjecture.

**Impact:** Would convert the qualitative lower bound `C(n,t)·C(n,t-1) ≤ |KWWitness|` into an exact enumerative invariant. All lower bounds for symmetric functions would become bookkeeping.

---

## Hypothesis 2: Entropy Gap is O(log n) for Monotone Functions

**Conjecture:** For every monotone Boolean function `f : (Fin n → Bool) → Bool`,

```
log₂ |KWWitness(f)| - KWComplexityExact(f) ≤ C · log₂(n+1)
```

for a universal constant `C` (conjectured: `C ≤ 2`).

Here `KWComplexityExact(f) = inf {d | ∃ P : KWProtocol f d}`.

**Lean objects involved:** `MetaComplexity.KWWitness`, `CircuitComplexity.KWProto.cost`, `Nat.log`.

**Test:** For threshold functions `Thresh_{n,t}` with n ≤ 15, compute `log₂|KWWitness|` and compare with the minimum protocol cost (exhaustive search over small protocol trees). The gap should be ≤ 2·log₂(n+1).

**Refutation criterion:** A monotone function family where the gap grows as ω(log n) would refute this. A candidate refutation family: monotone functions with many isolated true vectors.

**Impact:** Would establish that witness entropy is essentially equivalent to communication complexity for monotone functions, up to a logarithmic correction — making witness counting a complete complexity measure.

---

## Hypothesis 3: Boundary Dominance for Monotone Symmetric Functions

**Conjecture:** For every monotone symmetric function `f` with threshold `t`, the witness count satisfies:

```
|KWWitness(f)| ≤ poly(n) · C(n,t) · C(n,t-1)
```

where `poly(n) ≤ n²`.

That is, the adjacent boundary layers `(t, t-1)` dominate the total witness count up to polynomial factors.

**Lean objects involved:** `MetaComplexity.card_KWWitness_threshold_ge_choose`, `MetaComplexity.layer_card_eq_choose`.

**Test:** For threshold functions with n ≤ 30 and various thresholds t, compute the ratio `|KWWitness| / (C(n,t)·C(n,t-1))`. The conjecture predicts this ratio is ≤ n².

**Refutation criterion:** If the ratio grows faster than n² for some threshold family, the conjecture fails. Based on computational evidence, the ratio appears to grow as roughly Θ(n) for central thresholds.

**Impact:** Would show that the boundary-layer lower bound proved in this cycle captures the dominant term, justifying its use as a practical complexity estimator.

---

## Hypothesis 4: Majority Maximizes Witness Entropy Among Monotone Symmetric Functions

**Conjecture:** Among all monotone symmetric Boolean functions on n variables, the majority function `Maj_n` maximizes `|KWWitness(f)|`.

Formally:
```
∀ f : SymmetricBoolFn n, IsMonotone f →
  |KWWitness(f)| ≤ |KWWitness(Maj_n)|
```

**Lean objects involved:** `MetaComplexity.KWWitness`, `MetaComplexity.majorityFn`, `MetaComplexity.thresholdFn`.

**Test:** For n ≤ 12, enumerate all monotone symmetric profiles (there are n+1 of them, one per threshold) and verify that the central threshold maximizes the witness count.

**Refutation criterion:** A non-majority monotone symmetric function with larger witness count would refute this. Based on computational evidence for n ≤ 30, majority always wins.

**Impact:** Would establish majority as the canonical "hardest" function in the symmetric monotone world, connecting to noise stability (majority maximizes noise sensitivity) and providing a tight benchmark for the entropy lower bound method.

---

## Hypothesis 5: Rectangle Rigidity for Low-Cost Majority Protocols

**Conjecture:** Every KW protocol for `Maj_n` of cost d partitions the witness relation into at most `2^d` monochromatic rectangles, and the largest rectangle contains at most `|KWWitness(Maj_n)| / 2^{d/2}` witnesses.

More precisely: if a protocol has cost d, then no single transcript (leaf of the protocol tree) can be reached by more than `|KWWitness(Maj_n)| · 2^{-d/2}` true/false input pairs.

**Lean objects involved:** `CircuitComplexity.KWProto`, `MetaComplexity.KWWitness`, `MetaComplexity.majorityFn`.

**Test:** For n ≤ 7, exhaustively search over all KW protocols of minimal cost and verify the rectangle density bound. This requires enumerating protocols, which is computationally expensive but feasible for small n.

**Refutation criterion:** A low-cost protocol with a highly concentrated rectangle (density exceeding `2^{-d/2}`) would refute this. The conjecture predicts that efficient protocols must distribute witnesses relatively uniformly.

**Impact:** Would provide a structural explanation for why majority is hard: not only are there many witnesses, but they resist concentration into compact combinatorial rectangles. This connects to the Razborov–Wigderson paradigm of approximation methods and would open a path to superlogarithmic formula depth lower bounds via witness geometry.

---

## Experimental Validation Plan

All five hypotheses can be partially validated computationally using the Python code provided in this cycle:

1. **Hypothesis 1:** Run `symmetric_kw_witness_count` against `exact_kw_witness_count` for all 2^(n+1) symmetric profiles, n ≤ 8.
2. **Hypothesis 2:** Implement protocol search and compare with `compression_lower_bound`.
3. **Hypothesis 3:** Run `witness_entropy_analysis` for all thresholds, check ratio bound.
4. **Hypothesis 4:** Run `symmetric_kw_count` for all monotone symmetric profiles, compare.
5. **Hypothesis 5:** Requires protocol enumeration infrastructure (next cycle target).

Each hypothesis failing would redirect the research program: failures in Hypotheses 1 or 3 would suggest the symmetric case is more subtle than expected; failure in Hypothesis 4 would reveal a surprising extremal structure; failure in Hypothesis 5 would suggest efficient protocols can exploit geometric concentration.
