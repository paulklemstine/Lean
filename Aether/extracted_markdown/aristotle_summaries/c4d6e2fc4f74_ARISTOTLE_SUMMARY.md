# Summary of changes for run 9f59b45d-362c-421f-ba1a-b7cf8d541f3d
## GL₃ Tropical Satake Mixed Levi Separation — Complete Results

### Key Mathematical Discovery

Through rigorous analysis formalized in Lean 4, I discovered that **the proposed separation theorem is false for N ≥ 2**. The mixed rank-1/rank-2 Levi test family (edge₁, edge₂, levi₁₂, levi₂₃) provides only O(N) independent linear constraints for O(N²) unknowns, making separation information-theoretically impossible for large N.

### Formally Verified Results (Lean 4, zero sorries)

**File: `Tropical/Langlands/GL3SatakeMixedLeviSeparation.lean`** (400 lines, 34 theorems/lemmas, all proved)

1. **`levi12_eq_levi23`**: The two Levi profile families are identical by reindexing — `levi23` provides zero additional information beyond `levi12`. This immediately shows that having "both maximal parabolic families" is illusory.

2. **`mixed_tests_zero_implies_zero_le_one`**: The separation theorem IS true for N ≤ 1. For N = 0, `edge1(0)` determines the single coefficient. For N = 1, the four test equations form a determined system.

3. **`mixed_test_injective_rect_le_one`**: Injectivity form: if two functions agree on all tests and N ≤ 1, they are equal.

4. **`separation_fails_N2`**: An explicit counterexample proves the theorem fails for N = 2. The "circulation" function h = δ(0,2) − δ(1,2) − δ(2,0) + δ(2,1) is nonzero, supported in [0,2]², and satisfies ALL edge and Levi test conditions. This is a discrete analog of a curl — invisible to all divergence-type tests.

5. **`prefixSum_vanishing` / `prefixSum_injective`**: The 1D analog (GL₂ case) works for ALL N. Prefix sums form a lower-triangular invertible system.

6. **`prefixRectSum_separation`**: A corrected 2D separation theorem using 2D cumulative rectangle sums works for ALL N via Möbius inversion. This uses (N+1)² tests — exactly the minimum needed.

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

### Supporting Materials

- **`demos/gl3_satake_separation.py`**: Python demonstration with 6 interactive demos showing the Levi redundancy, small-N separation, the N=2 counterexample, kernel dimension analysis, 1D prefix sum recovery, and 2D Möbius inversion recovery. Generates two visualizations.

- **`demos/gl3_satake_separation.png`**: Visualization of the counterexample, test functional structure, and kernel dimension growth.

- **`demos/gl3_2d_recovery.png`**: Visualization of the corrected 2D prefix rectangle sum recovery.

- **`paper/gl3_satake_separation.md`**: Research paper with full mathematical exposition, including a Scientific American-style discussion section explaining the results via a CT scan / medical imaging analogy.

### Why the Original Theorem Fails

The kernel dimension table tells the story:

| N | Unknowns | Independent tests | Kernel dim | Separates? |
|---|----------|-------------------|------------|------------|
| 0 | 1 | 1 | 0 | ✓ |
| 1 | 4 | 4 | 0 | ✓ |
| 2 | 9 | 8 | 1 | ✗ |
| 3 | 16 | 13 | 3 | ✗ |
| 4 | 25 | 17 | 8 | ✗ |

The root cause is fundamental: the 4 test families (edge₁, edge₂, levi₁₂, levi₂₃) are really only 3 families (since levi₁₂ = levi₂₃), providing at most 4N+3 test values for (N+1)² unknowns.