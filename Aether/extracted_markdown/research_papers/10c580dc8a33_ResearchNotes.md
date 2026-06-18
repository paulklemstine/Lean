# Research Notes: Universal Parent Equation & Factoring via Pythagorean Triple Trees

## Team Research Log

---

### Session 1: Mathematical Foundations

#### Goal
Derive a universal parent equation for the Berggren Pythagorean triple tree that works across all three known tree generators (Berggren, Price, Euclid-parameter).

#### Key Insight #1: Universal Hypotenuse
While examining the three inverse Berggren matrices, we noticed that all three produce the SAME hypotenuse for the parent triple:
- B₁⁻¹ · (a,b,c) → hypotenuse = -2a - 2b + 3c
- B₂⁻¹ · (a,b,c) → hypotenuse = -2a - 2b + 3c
- B₃⁻¹ · (a,b,c) → hypotenuse = -2a - 2b + 3c

This is **c_parent = 3c - 2a - 2b** regardless of branch.

**Why?** Looking at the inverse matrices:
```
B₁⁻¹ = [[1,  2, -2],    B₂⁻¹ = [[1,  2, -2],    B₃⁻¹ = [[-1, -2,  2],
         [-2, -1,  2],             [2,  1, -2],             [ 2,  1, -2],
         [-2, -2,  3]]             [-2, -2,  3]]             [-2, -2,  3]]
```

The THIRD ROW is identical: [-2, -2, 3] for all three matrices!
This is not a coincidence — it follows from the Lorentz structure.

#### Key Insight #2: Sign-Based Branch Selection
The branch is determined by which of three values is positive:
- L₁ = a + 2b - 2c (first leg of B₁⁻¹ and B₂⁻¹)
- L₂ = -2a - b + 2c (second leg of B₁⁻¹)
- L₃ = 2a + b - 2c (second leg of B₂⁻¹ and B₃⁻¹)

Note: L₂ = -L₃, so they can't both be positive. And the first leg of B₃⁻¹ is -L₁.

Branch selection:
- If L₂ > 0 (equivalently L₃ < 0): Branch 1
- If -L₁ > 0 (equivalently L₁ < 0): Branch 3
- Otherwise: Branch 2

#### Key Insight #3: Sum-of-Squares Identity
In Euclid coordinates (m, n):
```
c_parent = 3(m²+n²) - 2(m²-n²) - 2(2mn)
         = 3m² + 3n² - 2m² + 2n² - 4mn
         = m² - 4mn + 5n²
         = (m-2n)² + n²
```

This is beautiful! The parent hypotenuse is always a sum of two squares: (m-2n)² + n².

**Implications:**
1. Every parent hypotenuse factors over ℤ[i]
2. The Gaussian integer z = (m-2n) + ni has norm equal to c_parent
3. This connects tree descent to Gaussian integer arithmetic

---

### Session 2: Recursive Parent Function

#### Definition
```
f⁽⁰⁾(a,b,c) = (a,b,c)
f⁽¹⁾(a,b,c) = universalParent(a,b,c)
f⁽ⁿ⁾(a,b,c) = f⁽¹⁾(f⁽ⁿ⁻¹⁾(a,b,c))
```

#### Verified Properties
1. **Pythagorean preservation**: f⁽ⁿ⁾ maps PPTs to PPTs ✓
2. **Hypotenuse decrease**: each step reduces c ✓
3. **Positivity**: c remains positive throughout ✓
4. **Termination**: chain reaches (3,4,5) ✓
5. **Integrality**: all operations are ℤ → ℤ ✓

#### Ancestry Chains (Computed)
```
(7, 24, 25) → (5, 12, 13) → (3, 4, 5)     [depth 2]
(119, 120, 169) → (21, 20, 29) → (3, 4, 5)  [depth 2]
(697, 696, 985) → (119, 120, 169) → ...      [depth 3+]
```

---

### Session 3: Factoring Experiments

#### Hypothesis
For an odd composite N, the parent descent from the trivial triple (N, (N²-1)/2, (N²+1)/2) will encounter a leg whose GCD with N is nontrivial.

#### Experimental Results

| N | Factorization | Total Depth | Factor Step | Factor |
|---|---|---|---|---|
| 15 | 3 × 5 | 6 | 1 | (3, 5) |
| 21 | 3 × 7 | 9 | 1 | (3, 7) |
| 35 | 5 × 7 | 16 | 2 | (5, 7) |
| 77 | 7 × 11 | 37 | 3 | (7, 11) |
| 91 | 7 × 13 | 44 | 4 | (7, 13) |
| 143 | 11 × 13 | 70 | 5 | (11, 13) |
| 221 | 13 × 17 | 109 | 6 | (13, 17) |
| 323 | 17 × 19 | 160 | 8 | (17, 19) |
| 1073 | 29 × 37 | 200+ | 14 | (29, 37) |
| 10403 | 101 × 103 | 500+ | 50 | (101, 103) |

#### Analysis
- Factor discovery is much faster than total descent depth
- Factor step ≈ O(√N) empirically
- 100% success rate on all tested composites
- Algorithm uses only integer arithmetic

#### Why It Works: The GCD Mechanism
At each descent level k, we have a triple (aₖ, bₖ, cₖ). The odd leg factors as:
```
aₖ = mₖ² - nₖ² = (mₖ - nₖ)(mₖ + nₖ)
```

If N = p · q and N | aₖ, then p · q | (mₖ - nₖ)(mₖ + nₖ). Unless the factorization is trivial (mₖ - nₖ = 1 and mₖ + nₖ = N), gcd(aₖ, N) ∈ {p, q, pq}.

But we don't need N | aₖ — we only need gcd(aₖ, N) > 1, which happens whenever p | (mₖ - nₖ) or p | (mₖ + nₖ).

The descent generates a sequence of (mₖ, nₖ) values. As k increases, these sample different arithmetic structures, increasing the probability that p divides one of the factors.

---

### Session 4: Three Tree Generators

#### Generator 1: Berggren (1934)
Matrices: B₁, B₂, B₃ (3×3, acting on triples)
- B₁ produces triples where the odd leg is small
- B₂ produces balanced triples
- B₃ produces triples where the even leg is small

#### Generator 2: Euclid Parameters (2×2)
Matrices: E₁ = [[2,-1],[1,0]], E₂ = [[2,1],[1,0]], E₃ = [[1,2],[0,1]]
- Act on (m,n) parameter space
- E₁, E₃ ∈ SL(2,ℤ); E₂ has det = -1
- E₁ and E₃ generate the theta group Γ_θ (index-3 in SL(2,ℤ))

#### Generator 3: Price Tree (2008)
Uses alternative free generators for the same group in O(2,1;ℤ).
These are products/conjugates of Berggren matrices, giving a different
tree enumeration order but covering the same set of PPTs.

#### Relationship
All three generators produce free groups of rank 3 that are conjugate
within O(2,1;ℤ). The universal parent equation (with its branch-independent
hypotenuse formula) is specific to the Berggren basis, but analogous
formulas exist for each basis.

---

### Session 5: Hypotheses and Conjectures

#### Hypothesis 1: Factor Discovery Depth
**Claim**: For N = p·q with p < q, the factor is discovered at step d where:
```
d ≈ C · √N / (q - p)
```
for some constant C ≈ 0.5.

**Evidence**: The data shows d grows as √N. When factors are close (like 101 × 103), the step count is relatively lower compared to when factors are far apart.

**Status**: Unproven. Need more data points.

#### Hypothesis 2: Branch Pattern Primality Test
**Claim**: The branch encoding during descent distinguishes primes from composites.

**Evidence**: Composites tend to show more branch-2 patterns. But sample size is small.

**Status**: Speculative. Need systematic analysis.

#### Hypothesis 3: Gaussian Integer Speedup
**Claim**: Using Gaussian integer GCD (gcd in ℤ[i]) at each descent step would discover factors faster than ordinary integer GCD, because the sum-of-squares structure of c_parent provides additional factorization data.

**Evidence**: Theoretical plausibility based on the identity c_parent = |z|² where z ∈ ℤ[i].

**Status**: Not yet tested computationally.

#### Hypothesis 4: Quantum Acceleration
**Claim**: A quantum computer could perform the branch selection in superposition, exploring all 3^d ancestry paths simultaneously and collapsing to a factor-revealing one.

**Evidence**: Theoretical. The tree structure is naturally suited to quantum walk algorithms.

**Status**: Highly speculative.

#### Hypothesis 5: Multi-Start Improvement
**Claim**: Starting from multiple initial triples (not just the trivial one) and descending in parallel improves factor discovery rate.

**Evidence**: Different starting triples sample different regions of the (m,n) parameter space.

**Status**: Not yet tested.

---

### Session 6: Formal Verification Results

All key theorems verified in Lean 4 with Mathlib:

✅ `universalParent_preserves_pyth` — Parent is Pythagorean
✅ `universalParent_hyp_decreases` — c' < c
✅ `universalParent_hyp_pos` — c' > 0
✅ `universal_hypotenuse_formula` — c' = 3c - 2a - 2b
✅ `invB1_lorentz_invariant` — Lorentz form preserved (Branch 1)
✅ `invB2_lorentz_invariant` — Lorentz form preserved (Branch 2)
✅ `invB3_lorentz_invariant` — Lorentz form preserved (Branch 3)
✅ `roundTrip_B1` — Forward ∘ Inverse = Identity (Branch 1)
✅ `roundTrip_B2` — Forward ∘ Inverse = Identity (Branch 2)
✅ `roundTrip_B3` — Forward ∘ Inverse = Identity (Branch 3)
✅ `parent_hyp_euclid_simplified` — c' = (m-2n)² + n²
✅ `parent_hyp_sum_of_squares` — ∃ u v, c' = u² + v²
✅ `ppt_triangle_ineq` — a + b > c for PPTs
✅ `descent_at_least_2` — c - c' ≥ 2
✅ `ppt_parity_sum` — a+b+c ≡ 0 (mod 2)
✅ `fermat_at_each_step` — m² - n² = (m-n)(m+n)
✅ `euclid_is_pyth` — Euclid parametrization gives PPTs

**Zero** `sorry` statements remain. All proofs compile cleanly.

---

### Session 7: Knowledge Upgrades

#### What We Learned
1. The third row of all inverse Berggren matrices is [-2, -2, 3] — this is the "universal" part
2. Parent hypotenuse = (m-2n)² + n² connects to Gaussian integers
3. Factor discovery via descent is empirically O(√N) steps
4. The integrality guarantee (everything stays in ℤ) is crucial for exact computation
5. Lorentz invariance provides geometric insight into why descent works

#### What Changed Our Thinking
- Initially expected the three tree generators to produce different parent equations, but they all use the same underlying group, just with different bases
- The sum-of-squares identity was unexpected and opens connections to algebraic number theory
- The factoring algorithm works better than expected for small numbers but likely doesn't beat NFS for large ones

#### Open Questions Remaining
1. Exact complexity of factor discovery depth
2. Whether Gaussian integer methods can improve the GCD step
3. Whether multi-start descent improves performance
4. Connection to lattice reduction methods
5. Potential for quantum speedup

---

### Summary of Deliverables

1. **Lean formalization**: `Pythagorean/UniversalParent.lean` (572 lines, 0 sorries)
2. **Experiments**: `Pythagorean/ParentFactoringExperiments.lean` (compiled, all experiments run)
3. **Research paper**: `Papers/PythagoreanParentTree/ResearchPaper.md`
4. **Scientific American article**: `Papers/PythagoreanParentTree/ScientificAmerican.md`
5. **Research notes**: `Papers/PythagoreanParentTree/ResearchNotes.md` (this file)
