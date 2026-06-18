# Future Directions: Formal Additive Prime Decomposition Theory

## Overview

This document identifies five falsifiable scientific hypotheses emerging from
our formalization of Goldbach-type additive prime decompositions. Each conjecture
is precise enough to confirm or refute computationally or proof-theoretically.

---

## Hypothesis 1: Universal Goldbach Multiplicity Lower Bound

**Conjecture:** For every even integer n ≥ 8, the ordered Goldbach representation
count satisfies r₂(n) ≥ 2. Equivalently, 4 = 2+2 and 6 = 3+3 are the only even
numbers with a unique ordered Goldbach representation.

**Precise statement:**
```
∀ n : ℕ, 8 ≤ n → Even n → 2 ≤ (goldbachWitnesses n).card
```

**Test:** Extend the certified verification (currently [8, 100]) to [8, 10⁵] using
optimized native computation. A structural proof may be possible by combining:
(1) the symmetry argument (if p ≠ q then (p,q) and (q,p) are distinct), with
(2) the parity theorem (both primes are odd for n > 4), and
(3) finite case analysis on the diagonal cases (n = 2p with p prime).

**Falsifier:** An even n ≥ 8 with r₂(n) < 2 (i.e., n = 2p with p prime and
no other Goldbach pair exists).

**Impact:** This would upgrade Goldbach from an existence result to a multiplicity
rigidity theorem—the first formal proof that the prime self-convolution never
attains its minimal nontrivial value beyond threshold.

---

## Hypothesis 2: k-ary Parity Census Law

**Conjecture:** For any k-ary prime decomposition a₁ + a₂ + ⋯ + aₖ = n, the
number of summands equal to 2 satisfies:

  #{i : aᵢ = 2} ≡ n + k (mod 2)

That is, the count of 2s has the same parity as n + k.

**Precise statement (k = 4):**
```
∀ n a b c d : ℕ, Prime a → Prime b → Prime c → Prime d →
  a + b + c + d = n →
  (count_twos [a,b,c,d]) % 2 = (n + 4) % 2
```

which simplifies to: the count of 2s has the same parity as n.

**Test:** Verify computationally for k = 4, 5, 6 on ranges [1, 1000].
Prove structurally by induction on k using the parity of odd primes.

**Falsifier:** A k-ary prime decomposition where the count of 2s violates
the predicted parity constraint.

**Impact:** This would establish a universal parity conservation law for additive
prime decompositions of arbitrary arity—a structural theorem that constrains all
prime decompositions simultaneously, analogous to charge conservation in physics.

---

## Hypothesis 3: Weak Chen Prevalence with Explicit Bounds

**Conjecture:** Every even integer n ≥ 4 admits a weak Chen decomposition
n = p + s where p is prime and s is either prime or semiprime. Moreover, the
number of such decompositions grows at least linearly in n.

**Precise statement:**
```
∀ n : ℕ, 4 ≤ n → Even n → HasWeakChenDecomposition n
```

**Test:** Extend the certified verification (currently [4, 100]) to [4, 10⁴]
using the decidability pipeline. Separately, count weak Chen witnesses for each
even n and verify growth trends. Compare with pure Goldbach counts to quantify
the "safety net" provided by semiprimes.

**Falsifier:** An even n ≥ 4 with no prime + (prime-or-semiprime) decomposition.

**Impact:** A verified weak Chen prevalence theorem would be a formal shadow of
Chen's theorem—not asymptotic but explicit and witness-bearing. It would create
infrastructure for formal sieve theory and demonstrate that semiprimes provide
genuine additive redundancy beyond primes alone.

---

## Hypothesis 4: Convolution Growth and Average Monotonicity

**Conjecture:** The average Goldbach count over even integers up to B,
```
  avg_r₂(B) = (1/⌊B/2⌋) · Σ_{even n ≤ B} r₂(n)
```
is eventually nondecreasing in B.

**Precise certified version:**
```
∀ B₁ B₂ : ℕ, 8 ≤ B₁ → B₁ ≤ B₂ → B₂ ≤ 10000 →
  B₂ * (Σ_{even n ≤ B₁} r₂(n)) ≤ B₁ * (Σ_{even n ≤ B₂} r₂(n))
```
(denominator-cleared to avoid rationals)

**Test:** Compute avg_r₂(B) for B = 100, 200, ..., 10000 and verify monotonicity.
If monotonicity fails at some point, identify the smallest B where it fails and
characterize the local "dip." Use the convolution identity
r₂(n) = (1_P * 1_P)(n) to study whether spectral properties of the prime
indicator explain the growth.

**Falsifier:** A pair B₁ < B₂ in the tested range with avg_r₂(B₂) < avg_r₂(B₁).

**Impact:** Certified monotonicity of average Goldbach counts would be a
prototype for machine-checked experimental analytic number theory. It would
connect the convolution identity to growth phenomena and provide formal evidence
for the Hardy-Littlewood asymptotic r₂(n) ~ C · n / (log n)².

---

## Hypothesis 5: Bounded Witness Transport Between Consecutive Even Numbers

**Conjecture:** For every even n ∈ [8, B], there exist Goldbach witnesses
(p, n-p) for n and (p', n+2-p') for n+2 with |p - p'| ≤ K, where K is
a universal constant (conjectured to be ≤ 30 based on computational evidence).

**Precise statement:**
```
def HasNearbyGoldbachTransfer (n K : ℕ) : Prop :=
  ∃ p q p' q' : ℕ,
    Prime p ∧ Prime q ∧ Prime p' ∧ Prime q' ∧
    p + q = n ∧ p' + q' = n + 2 ∧
    |p' - p| ≤ K ∧ |q' - q| ≤ K

∀ n, 8 ≤ n → n + 2 ≤ B → Even n → HasNearbyGoldbachTransfer n K
```

**Test:** Compute the minimum transport gap for all consecutive even pairs
in [8, 10000]. Determine the empirical distribution of minimum gaps and
identify the optimal K. Verify the finite theorem for the discovered K.

**Falsifier:** An even n in the tested range where no witness of n matches
any witness of n+2 within the claimed bound K.

**Impact:** This would reframe Goldbach theory dynamically, showing that
decompositions vary "continuously" across the even lattice. It would define
a Goldbach witness transport graph with edges representing bounded perturbation,
opening connections to graph connectivity, expansion, and topological persistence.

---

## Implementation Priorities

1. **Prove Hypothesis 2** for k = 4 structurally (extends our k = 3 results)
2. **Extend certified ranges** for Hypotheses 1, 3, and 4 using optimized computation
3. **Build witness transport infrastructure** for Hypothesis 5
4. **Develop convolution algebra** for Hypothesis 4 (Fourier-analytic approach)
5. **Connect to Hardy-Littlewood heuristics** through formal asymptotic estimates

---

## Methodology

All hypotheses should be tested via:
1. **Computational exploration** in Python to discover patterns and bounds
2. **Formal statement** in Lean 4 with precise types
3. **Certified computation** using `native_decide` for finite ranges
4. **Structural proof** where possible, using parity, symmetry, and convolution
5. **Documentation** of results in the formal library with cross-references
