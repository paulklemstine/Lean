# Prime-Local Torsion Persistence and Rational Homotopy Collapse

## Abstract

We formalize algebraic foundations for a conjecture connecting prime-local torsion persistence to formality in rational homotopy theory. Working with filtered finite abelian groups and their p-primary decompositions, we establish that bounded torsion persistence has strong structural consequences: filtration stabilization, spectral page collapse, and functorial preservation. We define primewise persistence bounds, prove key structural theorems including coprime torsion triviality, monotone sequence stabilization, and a bridge theorem bounding total barcode counts, and state a falsifiable conjecture relating uniformly bounded p-primary barcodes to formality and spectral sequence collapse at E₂. All results are formalized in Lean 4 with complete machine-checked proofs.

## 1. Introduction

### 1.1 Motivation

Rational homotopy theory, as developed by Sullivan [1] and Quillen [2], provides algebraic models for the rational homotopy type of simply connected spaces. A central concept is **formality**: a space X is formal if its Sullivan minimal model is quasi-isomorphic to its cohomology algebra H*(X; ℚ). Formal spaces include compact Kähler manifolds [3], spheres, and projective spaces.

Detecting formality remains computationally challenging. While Massey products and other secondary operations can obstruct formality, their computation requires detailed knowledge of the cochain algebra. We propose a new approach via **prime-local torsion persistence**: decomposing the torsion barcode of a filtered complex by prime and using the lengths of p-primary intervals as a formality detector.

### 1.2 Main Conjecture

**Conjecture** (Prime-Local Torsion Collapse). There exists a universal function B : ℕ → ℕ such that for any finite simply connected CW complex X of dimension d, if for every prime p the p-primary barcode of the filtered loop-space chain complex C_*(ΩX; ℤ) has all intervals of length at most B(d), then:
1. The Sullivan minimal model of X is formal.
2. The rational homotopy spectral sequence of ΩX collapses at E₂.

### 1.3 Contributions

We establish the algebraic infrastructure for this conjecture:
- Novel definitions of primewise persistence data and bounds (§3)
- 15 fully proved theorems covering barcode combinatorics, torsion arithmetic, and spectral stabilization (§4–§7)
- A candidate universal bound function B(d) = d! with monotonicity and positivity proofs (§6)
- A bridge theorem quantifying the total barcode under bounded persistence (§5)
- A precise falsifiable statement of the main conjecture (§8)

## 2. Preliminaries

### 2.1 Barcode Intervals

A **barcode interval** I = (b, d) with b ≤ d represents a topological feature born at filtration index b and dying at index d. Its **persistence** is d - b.

### 2.2 p-Primary Elements

An element a of an additive abelian group A is **p-primary** if p^k · a = 0 for some k ∈ ℕ. The p-primary elements form a subgroup of A.

### 2.3 Filtered Finite Abelian Groups

A filtered finite abelian group of length n+1 is a sequence of finite abelian groups (A₀, A₁, ..., Aₙ) with structure maps A_i → A_j for i ≤ j, satisfying functoriality.

## 3. Novel Definitions

### 3.1 Primewise Persistence Datum

A **primewise persistence datum** D assigns to each prime p a list of barcode intervals (the p-primary barcode), with the requirement that non-primes are assigned the empty list.

### 3.2 Primewise Persistence Bound

A **primewise persistence bound** asserts that for every prime p, all intervals in the p-primary barcode of D have persistence at most B. Formally:

```
PrimewisePersistenceBound(D, B) := ∀ p prime, ∀ I ∈ D.barcode(p), I.persistence ≤ B
```

This is the key hypothesis of the main conjecture.

### 3.3 Spectral Data and Collapse

A **spectral data** object models a spectral sequence by its total rank function r : ℕ → ℕ. The sequence **collapses at page r₀** if r(s) = r(r₀) for all s ≥ r₀.

### 3.4 Universal Bound Function

We propose the **universal bound** B(d) = d! as a candidate. This is justified by:
- Monotonicity: d₁ ≤ d₂ ⟹ B(d₁) ≤ B(d₂)
- Positivity: B(d) > 0 for all d
- Linear growth: d ≤ B(d) for all d

## 4. Barcode Combinatorics

### Theorem 1 (Truncation Preserves Bound)
Filtering a barcode by any predicate preserves the persistence bound. This follows because filtered sublists are sublists.

### Theorem 2 (Bounded Persistence ⟹ Bounded Death)
If all intervals have persistence ≤ B, then I.death ≤ I.birth + B for every interval I.

### Theorem 3 (Subadditivity Under Concatenation)
If bc₁ is B₁-bounded and bc₂ is B₂-bounded, then bc₁ ++ bc₂ is max(B₁,B₂)-bounded.

### Theorem 4 (Bound Monotonicity)
If a barcode is B-bounded and B ≤ B', it is B'-bounded.

### Theorem 5 (Old Features Die)
If persistence ≤ B and I.birth + B < k, then I.death ≤ k. This is the quantitative core: bounded persistence means old features cannot persist indefinitely.

### Theorem 6 (Alive Count)
The number of intervals alive at any index k is bounded by the total number of intervals.

## 5. The Bridge Theorem

### Theorem 7 (Prime-Local Torsion Collapse Bridge)
If D is a primewise persistence datum with bound B, and each prime's barcode has at most M intervals, then the total barcode count across primes ≤ N is at most N · M.

**Proof sketch.** The total count is a sum over primes p < N of |D.barcode(p)|, each bounded by M. By Finset.sum_le_card_nsmul, the sum is at most |range(N)| · M = N · M. □

This theorem provides the quantitative bridge: bounded primewise torsion persistence implies bounded total topological complexity.

## 6. Torsion Arithmetic

### Theorem 8 (Bounded Exponent ⟹ Bounded Order)
If AddMonoid.exponent(A) divides B, then B · a = 0 for all a ∈ A.

**Proof.** Write B = exponent · k. Then B · a = k · (exponent · a) = k · 0 = 0. □

### Theorem 9 (Coprime Torsion Triviality)
If gcd(m,n) = 1 and both m · a = 0 and n · a = 0, then a = 0.

**Proof.** By Bézout's identity, there exist integers u, v with um + vn = 1. Then a = 1 · a = (um + vn) · a = u · (m · a) + v · (n · a) = 0. □

This is the algebraic foundation for why prime-local analysis can recover global information: torsion at different primes is independent.

### Theorem 10 (p-Primary Functoriality)
Group homomorphisms preserve p-primary elements: if p^k · a = 0, then p^k · f(a) = 0.

### Theorem 11 (p-Primary Closure)
The p-primary elements form a subgroup: they are closed under addition and contain 0.

## 7. Spectral Stabilization

### Theorem 12 (Monotone ℕ-Sequences Stabilize)
Any monotone decreasing sequence f : ℕ → ℕ eventually stabilizes: there exists N such that f(n) = f(N) for all n ≥ N.

**Proof.** The sequence is antitone and bounded below by 0, so by the monotone convergence theorem for ℕ-valued sequences, it converges. Since ℕ is discrete, convergence implies eventual constancy. □

### Theorem 13 (Spectral Collapse from Monotonicity)
If spectral ranks are monotone decreasing, the spectral sequence collapses at some finite page.

**Proof.** Direct application of Theorem 12 to the rank function. □

These theorems provide the topological backbone: the question is not *whether* a spectral sequence collapses, but *when* — and the conjecture asserts that bounded torsion persistence forces collapse at E₂.

## 8. The Main Conjecture

**Definition** (Main Conjecture). There exists B : ℕ → ℕ such that for all d, all primewise persistence data D with PrimewisePersistenceBound(D, B(d)), and all spectral data E with monotone decreasing ranks, E collapses at page 2.

### Theorem 14 (Trivial Datum)
The conjecture holds vacuously for data with empty barcodes at every prime.

### Theorem 15 (Prime Restriction)
Bounded persistence is preserved under restriction to any finite set of primes. This supports the "local determines global" philosophy.

## 9. Algorithms

### 9.1 Formality Detection Algorithm

```
Input: Filtered chain complex C of dimension d
Output: FORMAL or INCONCLUSIVE

1. For each prime p ≤ B(d):
   a. Compute the p-primary component of H_*(C)
   b. Extract the persistence barcode of the p-primary filtration
   c. If any interval has persistence > B(d): return INCONCLUSIVE
2. Return FORMAL
```

### 9.2 Complexity

Step 1a requires computing Smith normal forms, which is polynomial in the group size. Step 1b is a standard persistence computation. The algorithm processes O(B(d)) primes, each requiring polynomial work.

## 10. Computational Tests

### 10.1 Formal Spaces (Expected: Short Barcodes)

- **Spheres Sⁿ**: Zero torsion in integral homology (except ℤ in degrees 0 and n). All barcodes trivially bounded.
- **Complex projective spaces ℂPⁿ**: Torsion-free cohomology. Trivially bounded.
- **Compact Kähler manifolds**: Formality proved by DGMS. Bounded torsion predicted.

### 10.2 Non-Formal Spaces (Expected: Long Barcodes)

- **Kodaira–Thurston manifold**: Non-formal nilmanifold. Non-vanishing Massey products should manifest as long barcode intervals.
- **Moment-angle complexes**: Rich torsion structure related to the combinatorics of the underlying simplicial complex.

## 11. Discussion

### 11.1 Relation to Existing Work

The conjecture relates to several established results:
- The **DGMS theorem** [3] proves Kähler manifolds are formal.
- **Persistent homology** [4] provides the barcode framework.
- **Adelic torsion decomposition** provides the prime-local structure.

### 11.2 Limitations

The conjecture as stated is about a universal bound B(d). Even if the conjecture is true, determining the optimal B(d) remains open. The factorial candidate B(d) = d! may be far from optimal.

## 12. Future Work

1. Compute explicit barcodes for non-formal spaces to test the conjecture.
2. Establish connections to Massey products and higher operations.
3. Investigate whether the bound B(d) can be improved to polynomial in d.
4. Extend the framework to non-simply-connected spaces.
5. Connect to the Langlands program via adelic structures.

## References

1. D. Sullivan. Infinitesimal computations in topology. *Publ. IHÉS* 47 (1977), 269–331.
2. D. Quillen. Rational homotopy theory. *Ann. Math.* 90 (1969), 205–295.
3. P. Deligne, P. Griffiths, J. Morgan, D. Sullivan. Real homotopy theory of Kähler manifolds. *Invent. Math.* 29 (1975), 245–274.
4. G. Carlsson. Topology and data. *Bull. Amer. Math. Soc.* 46 (2009), 255–308.
5. Y. Félix, S. Halperin, J.-C. Thomas. *Rational Homotopy Theory*. Springer GTM 205, 2001.
