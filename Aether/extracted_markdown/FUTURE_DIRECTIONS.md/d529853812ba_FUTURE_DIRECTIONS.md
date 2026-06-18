# Future Directions: Falsifiable Hypotheses for Formal Prime Gap Infrastructure

## Hypothesis 1: Multiplicativity of Survivor Counts for Arbitrary Squarefree Moduli

**Conjecture.** For any admissible tuple H and any squarefree integer M = p₁ · p₂ · … · pₙ (distinct primes), the number of survivor residues modulo M factors as a product of local survivor counts:

$$|\{a \in [0, M) : \forall h \in H,\ \gcd(a + h, M) = 1\}| = \prod_{i=1}^{n} (p_i - \nu_{p_i}(H))$$

where ν_p(H) = |H mod p|.

**Test.** Formalize the theorem `card_survivors_mul_of_coprime` asserting that for coprime moduli m, n, the survivor count modulo m·n equals the product of survivor counts modulo m and n. Then specialize to primorials. A computational sweep over all squarefree moduli up to 10⁵ with tuples of size ≤ 10 confirms or refutes the formula.

**Infrastructure needed.** A formal CRT bijection theorem at the level of finite sets (not just existence), proving that the map ℤ/mnℤ → ℤ/mℤ × ℤ/nℤ restricts to a bijection on survivor sets. This requires `ZMod.chineseRemainder` from Mathlib composed with set-level bijection lemmas.

**Impact if true.** This would complete the combinatorial foundation of sieve theory: the exact survivor count is a multiplicative function of the modulus, yielding a formal Euler product for the sieve density. It would also give the first machine-verified derivation of the Hardy–Littlewood singular series.

---

## Hypothesis 2: Tight Diameter Bounds for Optimal Admissible k-Tuples

**Conjecture.** For every k ≥ 2, the minimal diameter D(k) of an admissible k-tuple satisfies

$$D(k) \leq k \cdot (\ln k + \ln \ln k + 6)$$

This is sharper than the Hensley–Richards bound D(k) ~ k log k and matches computational data for k ≤ 342.

**Test.** Implement a certified exhaustive search for D(k) up to k = 20, verify the bound computationally for k ≤ 1000 using greedy algorithms, and formalize the inequality D(k) < k · (ln k + ln ln k + 6) for all k ≤ N where N is the search frontier. Any counterexample immediately refutes the conjecture.

**Infrastructure needed.** A formalized greedy admissible tuple construction algorithm with a verified upper bound on its output diameter. This requires decidable admissibility (already achieved) plus an inductive bound on the next admissible offset.

**Impact if true.** This would give the tightest known formal upper bound on prime gap sizes achievable by the Maynard–Tao method. Combined with the threshold existence theorem, it would yield an explicit computable function k ↦ D(k) bounding the gap between consecutive primes infinitely often.

---

## Hypothesis 3: Exact Comparison Between Survivor Density and Inclusion-Exclusion Truncations

**Conjecture.** For any admissible k-tuple H and bound B, the exact survivor density equals the full inclusion-exclusion sum, and the Bonferroni truncations provide rigorous alternating bounds:

$$\sum_{S \subseteq \text{Primes}_{\leq B},\ |S| \leq 2m} (-1)^{|S|} \frac{|\bigcap_{p \in S} F_p|}{M} \leq \frac{|\text{Survivors}|}{M} \leq \sum_{S \subseteq \text{Primes}_{\leq B},\ |S| \leq 2m+1} (-1)^{|S|} \frac{|\bigcap_{p \in S} F_p|}{M}$$

where F_p is the set of residues forbidden by prime p and M = primorial(B).

**Test.** For H = {0, 2, 6} and B = 11, compute all Bonferroni truncation levels (there are only π(11) = 5 primes, so 32 subsets) and verify the alternating bounds hold with equality at the final level. Formalize the identity for the full inclusion-exclusion case (all subsets).

**Infrastructure needed.** A formal Bonferroni inequality over finite sets with the independence structure provided by CRT. This connects to `Finset.sum_indicator_subset` and Möbius inversion infrastructure in Mathlib.

**Impact if true.** This would formalize the exact relationship between the sieve of Eratosthenes (inclusion-exclusion), the Selberg sieve (optimized quadratic forms), and the CRT product formula (exact count). It is the missing link between elementary and analytic sieve theory.

---

## Hypothesis 4: Formal Selberg Sieve Quadratic Forms in Finite Dimension

**Conjecture.** The Selberg sieve upper bound in finite dimension can be expressed as a positive-definite quadratic form optimization. Specifically, for a finite set of primes P and admissible tuple H of size k, there exists a positive-definite matrix Q of size |P| × |P| such that the Selberg sieve upper bound for prime k-tuples up to N equals

$$\frac{N}{\mathbf{1}^T Q^{-1} \mathbf{1}} + O(N^{1/2+\epsilon})$$

and the optimal Selberg weights are λ_d = (Q^{-1} · 1)_d / (1^T Q^{-1} 1).

**Test.** For H = {0, 2} and P = {2, 3, 5, 7, 11}, construct Q explicitly as the matrix Q_{d,e} = ∑_{[d,e]|n ≤ N} 1 (where [d,e] is the lcm), verify it is positive definite, compute the Selberg bound, and compare with the exact prime pair count up to N = 10⁶.

**Infrastructure needed.** Formalization of the Selberg sieve requires:
- Positive-definite matrices over ℝ (available in Mathlib)
- Möbius function and multiplicative function infrastructure
- The Selberg symmetry condition λ_d = λ_d' when d, d' have the same prime factors
- Connection between the quadratic form minimum and the CRT survivor count

**Impact if true.** This would be the first formal connection between the finite combinatorial infrastructure (admissibility, CRT survivors) and the analytic sieve machinery. It would open the door to formalizing Zhang's theorem on bounded gaps.

---

## Hypothesis 5: Entropy-Optimal Admissible Tuples Minimize the Singular Series

**Conjecture.** Among all admissible k-tuples of a given diameter D, the tuple minimizing the "local obstruction entropy"

$$E(H) = -\sum_{p \leq k} \frac{\nu_p(H)}{p} \log \frac{\nu_p(H)}{p}$$

also minimizes the singular series constant 𝔖(H). In other words, the most "uniformly spread" tuples in residue-class space are the ones with the smallest Hardy–Littlewood constant.

**Test.** For k = 5 and D ≤ 20, enumerate all admissible 5-tuples, compute both E(H) and 𝔖(H, B=100), and test whether the Spearman rank correlation between E and 𝔖 is negative. A single tuple pair where the entropy ordering disagrees with the singular series ordering would refute the conjecture.

**Infrastructure needed.** Formalized real-valued entropy function over finite distributions, singular series partial products (already computable), and a comparison theorem relating the two. The entropy function requires `Real.log` and `Finset.sum` over prime residue distributions.

**Impact if true.** This would provide a computationally cheap proxy for the singular series (which requires computing many local factors). Tuple optimization for prime gap searches could use entropy minimization instead of full singular series computation, dramatically speeding up the search for optimal tuples in large databases.
