# Future Directions: Random Generation in Finite Permutation Groups

## Conjecture 1: Quantitative Dixon Residual Bound

**Conjecture**: For all n ≥ 8, the residual proper transitive probability satisfies

δ_n := P(⟨σ,τ⟩ transitive, ⟨σ,τ⟩ ∋ odd perm, ⟨σ,τ⟩ ≠ S_n) ≤ 3/n²

**Test**: Compute δ_n exactly for n = 5, 6, 7, 8, 9, 10 using GAP or exhaustive enumeration. For each n, enumerate all pairs (σ,τ) ∈ S_n², compute the generated subgroup, check if it is transitive, proper, and contains an odd permutation. Compare with 3(n!)²/n².

**What would confirm**: If all computed values satisfy δ_n ≤ 3/n², the conjecture gains strong evidence. The key test cases are n = 6 (where PGL(2,5) ≅ S_5 creates a large transitive subgroup) and n = 8 (where primitive groups are most abundant relative to n).

**What would refute**: Finding any n ≥ 8 with δ_n > 3/n². The most likely counterexample would involve n where an exceptionally large transitive primitive subgroup exists.

**Impact**: If true, combined with our formal bounds, this would yield the machine-verified estimate P_n ≥ 3/4 − 4/n − 3/n², completing the formal Dixon decomposition.

---

## Conjecture 2: Monotone Convergence of P_n

**Conjecture**: For all n ≥ 5, P_n < P_{n+1}, and lim_{n→∞} P_n = 3/4.

**Test**: Compute exact P_n for n = 2, 3, 4, 5, 6, 7, 8 and check monotonicity. For larger n, use Monte Carlo with 10⁶ samples per value of n.

**What would confirm**: Strict monotonicity in all computed values and convergence behavior consistent with P_n = 3/4 − c/n + O(1/n²) for some constant c.

**What would refute**: Finding consecutive n with P_n ≥ P_{n+1}. The most likely place for a violation is small n (e.g., n = 3, 4) where the alternating group is small and exotic subgroups create irregularities.

**Impact**: Monotonicity would imply P_n < 3/4 for all finite n, strengthening the interpretation of 3/4 as a strict upper limit.

---

## Conjecture 3: Generation Probability for A_n Tends to 1

**Conjecture**: The probability that two random elements of the alternating group A_n generate A_n tends to 1 as n → ∞.

**Test**: Compute exact values for n = 5, 6, 7, 8 using GAP. For larger n, sample random even permutations and check generation.

**What would confirm**: Computed probabilities increasing toward 1, with the complement bounded by O(1/n).

**What would refute**: The probability stabilizing at some value < 1, which would indicate a structural obstruction analogous to parity but within A_n.

**Impact**: This would establish that the parity obstruction is the *only* reason P_n doesn't tend to 1, and that within the alternating group, random generation is essentially guaranteed.

---

## Conjecture 4: Primitive-but-Proper Obstruction is Exponentially Small

**Conjecture**: The probability that ⟨σ,τ⟩ is a primitive but proper subgroup of S_n (or A_n) is at most C · r^n for some constants C > 0, 0 < r < 1.

**Test**: Using the O'Nan-Scott theorem and known bounds on maximal subgroups, enumerate the possible primitive proper subgroups of S_n for n ≤ 50. For each, bound the probability that a random pair lands in it. Sum the bounds.

**What would confirm**: The sum of probabilities decreasing exponentially in n.

**What would refute**: Finding infinite families of primitive subgroups whose generation probability decays only polynomially (e.g., wreath products with specific parameters).

**Impact**: An exponential bound on primitive obstruction would immediately give P_n = 3/4 − 2/n + O(e^{−cn}) and would extend to all classical groups via similar methods.

---

## Conjecture 5: Three Random Permutations Generate S_n with Probability → 1

**Conjecture**: If σ, τ, ρ are three independent uniformly random elements of S_n, then P(⟨σ,τ,ρ⟩ = S_n) → 1 as n → ∞. Moreover, the rate of convergence is P_n^{(3)} ≥ 1 − C/n² for some explicit constant C.

**Test**: Compute P_n^{(3)} exactly for n = 3, 4, 5, 6. For larger n, estimate via Monte Carlo with 10⁵ samples. Compare with the two-generator probability.

**What would confirm**: P_n^{(3)} ≥ 1 − C/n² for all tested n with C ≤ 10.

**What would refute**: P_n^{(3)} bounded away from 1, which would require three permutations to all have correlated parity constraints beyond the simple product.

**Impact**: This would establish a sharp threshold: two generators give probability 3/4 (due to parity), but three generators eliminate the parity obstruction (probability that all three are even is 1/8, but the parity constraint becomes less rigid) and achieve probability → 1. This has direct implications for randomized algorithms that use three random permutations as building blocks.

---

## Experimental Infrastructure Needed

To test these conjectures, the following computational tools are needed:

1. **GAP scripts** for exact subgroup generation in S_n for n ≤ 12
2. **High-performance Monte Carlo** sampling of random permutations for n ≤ 10⁵
3. **Subgroup lattice enumeration** using the O'Nan-Scott classification
4. **Lean 4 formalization** of the orbit-stabilizer theorem connecting orbits to preserved subsets
5. **Spectral methods** for bounding mixing times of random walks on Cayley graphs of S_n
