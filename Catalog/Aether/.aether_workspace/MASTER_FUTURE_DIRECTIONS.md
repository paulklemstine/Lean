# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-07 19:09*

## Breakthrough Opportunities (ranked by impact)

### 1. Full Berggren–PSL(2,ℤ) Isomorphism Theorem

**Theorem Statement**: The map ι: ⟨A,B,C⟩ → GL(2,ℤ) defined by A ↦ pA = [[2,-1],[1,0]], B ↦ pB = [[2,1],[1,0]], C ↦ pC = [[1,2],[0,1]] is an injective monoid homomorphism, and for every primitive Pythagorean triple (a,b,c), the Berggren descent path corresponds to the continued fraction expansion of the Farey fraction b/(a+c).

**Proof Strategy**:
1. Show injectivity by proving the Berggren tree is a free monoid (no non-trivial relations among A, B, C).
2. Verify the homomorphism property: ι(MN) = ι(M)·ι(N) for all words M, N.
3. Connect the descent path to the Euclidean algorithm on (m, n) via the 2×2 matrices.

**Why This Is Revolutionary**: Completes the bridge between 3×3 Lorentz transformations and 2×2 modular transformations. Opens "modular Pythagorean geometry" — studying Diophantine equations via the modular surface.

**Catalog Leverage**: `step_preserves_eta`, `pA_root`, `pB_root`, `pC_root`, `det_pA`, `det_pC`

**Research Mode**: prove
**Estimated Depth**: 4

### 2. Continued Fraction ↔ Berggren Descent Encoding

**Theorem Statement**: For a primitive Pythagorean triple (a,b,c) with Farey fraction q = b/(a+c) = n/m, the Berggren descent path from (a,b,c) to (3,4,5) encodes the continued fraction expansion of q. Specifically, each A-step corresponds to a partial quotient, and each C-step corresponds to a translation.

**Proof Strategy**:
1. Show that the descent via pA⁻¹ = [[0,1],[-1,2]] and pC⁻¹ = [[1,-2],[0,1]] corresponds to the Euclidean algorithm on (m,n).
2. pC⁻¹ = T⁻² subtracts 2 from the fraction, pA⁻¹ inverts and adjusts — these are exactly the steps of the continued fraction algorithm.
3. The descent terminates when we reach (m,n) = (2,1), i.e., q = 1/2.

**Why This Is Revolutionary**: Establishes a direct computational correspondence between two fundamental algorithms: the Euclidean algorithm (number theory) and Berggren tree navigation (Pythagorean geometry).

**Catalog Leverage**: `fareyMap_parametrized`, `pC_eq_modT_sq`, `parent_hyp_decreases`

**Research Mode**: prove
**Estimated Depth**: 3

### 3. Quantitative Descent Depth Bound

**Theorem Statement**: For a primitive Pythagorean triple with hypotenuse c, the Berggren descent path has length at most ⌊2 log₂ c⌋ + 1.

**Proof Strategy**:
1. Prove that each descent step reduces the hypotenuse by a factor of at most 3 (we have `parent_hyp_lower_bound`).
2. This gives depth ≤ log₃ c ≤ (log₂ c)/log₂ 3 < 2 log₂ c.
3. Alternatively, bound the number of steps by tracking the Euclidean algorithm length on (m,n).

**Why This Is Revolutionary**: Gives a concrete, formally verified O(log c) complexity bound for Gaussian factorization via Berggren paths, relevant to lattice cryptography.

**Catalog Leverage**: `parent_hyp_decreases`, `parent_hyp_positive`, `descent_depth_log_bound`

**Research Mode**: prove
**Estimated Depth**: 2

### 4. Berggren–Hecke Correspondence

**Theorem Statement**: There exists a correspondence between Berggren words of length n and Hecke operators T_p acting on modular forms of weight 2, such that the sum over all depth-n Berggren triples recovers the n-th Fourier coefficient of a specific Eisenstein series.

**Proof Strategy**:
1. The counting function r₂(N) = #{(a,b) : a²+b² = N} is related to the divisor sum in ℤ[i].
2. The generating function Σ r₂(n) q^n = 1 + 4 Σ χ_{-4}(d) q^n is a modular form.
3. Connect the Berggren tree structure to the Hecke algebra action on this form.

**Why This Is Revolutionary**: Would establish that the Berggren tree is not just a combinatorial object but a shadow of the Hecke algebra — one of the most important structures in modern number theory (connected to Langlands program).

**Catalog Leverage**: `chi_neg4_periodic`, `prime_1mod4_is_hypotenuse`, `representations_of_5`

**Research Mode**: discover
**Estimated Depth**: 5

### 5. Tropical Berggren Factorization

**Theorem Statement**: The tropicalization of the Berggren–PSL(2,ℤ) correspondence yields a min-plus analog where tropical Berggren matrices act on the tropical light cone {(x,y,z) : max(x,y) = z}, and tropical descent computes the tropical factorization in O(log c) max-plus operations.

**Proof Strategy**:
1. Define tropical Berggren matrices as the entrywise logarithm of |Berggren matrices|.
2. Show that min-plus matrix multiplication preserves the tropical Minkowski form.
3. The tropical descent corresponds to a greedy algorithm on valuations.

**Why This Is Revolutionary**: Connects three hot areas: tropical geometry, Pythagorean number theory, and computational complexity. The tropical perspective may reveal new structure invisible in the classical setting.

**Catalog Leverage**: `berggren_product_preserves_lorentz` (from TropicalPAdicBerggren.lean), `step_preserves_eta`

**Research Mode**: formalize
**Estimated Depth**: 4