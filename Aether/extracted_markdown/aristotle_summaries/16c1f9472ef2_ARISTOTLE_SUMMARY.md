# Summary of changes for run fb1fed52-3986-4562-8921-d0362718083c
## Completed: Berggren Semigroup Anti-Involution Rigidity

### Formal Mathematics (Lean 4)

Created `Cryptography/BerggrenAntiRigidity.lean` — a fully verified, self-contained formalization proving that the Berggren free semigroup in GL₂(ℤ) is **completely disjoint from its image under the adjugate anti-involution**.

The Berggren generators are the three 2×2 integer matrices A = !![2,-1;1,0], B = !![2,1;1,0], C = !![1,2;0,1] from the classical Pythagorean triple tree. The adjugate of M = !![a,b;c,d] is adj(M) = !![d,-b;-c,a], the matrix anti-involution satisfying adj(MN) = adj(N)·adj(M) and M·adj(M) = det(M)·I. For det = ±1 matrices, adj(M) = ±M⁻¹.

**Key theorems proved (all sorry-free, verified with `#print axioms`):**

1. **Entry Bounds** (`evalBergWord_entry_bounds`): Every Berggren word matrix has M₀₀ ≥ 1, M₁₀ ≥ 0, and M₀₀ ≥ M₁₀.

2. **Main Theorem** (`adjugate2_not_in_BergSemigroup`): For any nonempty Berggren word w, adj(eval(w)) is NOT in the Berggren semigroup. The proof splits on M₁₀: if positive, adj has negative (1,0) entry (impossible in the semigroup); if zero, the matrix must be !![1,b;0,1] with b≥1 and the adjugate's pair invariant is invalid.

3. **Anti-Collision** (`evalBergWord_ne_adjugate`): No word in the semigroup equals the adjugate of any nonempty word's evaluation.

4. **No Scalar Products** (`berggren_no_scalar_product`): Products of nonempty Berggren words never equal scalar matrices c·I.

5. **Finite Ball Version** (`berggren_ball_anti_collision_free`): Within any ball {w : |w| ≤ N}, evaluation is injective AND separated from the adjugate.

6. **Reverse-Adjugate Rigidity** (`berggren_reverse_adjugate_rigidity`): The adjugate of reversed words is also never in the semigroup.

Also proved foundational results: adjugate anti-homomorphism (`adjugate2_anti_hom`), M·adj(M) = det(M)·I (`mul_adjugate2`), and the free monoid theorem (`evalBergWord_injective`) via pair-based evaluation.

### Python Demonstrations

Created `python_demo/berggren_anti_rigidity_demo.py` with five demonstrations:
- Entry bounds verification for all words up to length 4
- Adjugate anti-rigidity verification for all words up to length 5
- Scalar product impossibility check for all pairs up to length 3
- Cryptographic transcript canonicalization scenario
- Visualization of semigroup vs. adjugate separation in entry and pair spaces (saves to `python_demo/berggren_anti_rigidity.png`)

### Research Paper

Created `research_paper.md` covering the mathematical content, proof architecture, formal verification details, cryptographic applications, a Scientific American-style discussion section explaining the intuition ("the lock that can't be picked backwards"), and future directions.