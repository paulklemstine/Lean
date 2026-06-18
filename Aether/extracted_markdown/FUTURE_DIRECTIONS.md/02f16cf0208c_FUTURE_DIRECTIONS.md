# Future Directions: Multi-Step Filtration Obstruction Calculus

## Synthesis

The three-step composition law `min(a, c-a) = min(a, b-a) + min(a ∸ (b-a), c-b)` established in this work reveals that filtered extension theory carries genuine higher coherence data beyond pairwise obstruction classes. The correction term `min(a ∸ (b-a), c-b)` — proved to be prime-independent, monotone, and precisely characterized by a vanishing criterion — opens five research directions connecting homological algebra to persistence theory, number theory, and compositional invariants. Each direction below is grounded in the proved theorems and suggests specific, falsifiable extensions that would deepen the theory or connect it to new domains.

---

## Direction 1: Higher-Step Recursive Obstruction Tower

**Conjecture.** For any finite filtration 0 ⊆ Z/p^{e_0} ⊆ Z/p^{e_1} ⊆ … ⊆ Z/p^{e_n}, the total obstruction exponent min(e_0, e_n - e_0) decomposes uniquely as

  min(e_0, e_1 - e_0) + Σ_{k=2}^{n} min(max(e_0 - (e_{k-1} - e_0), 0), e_k - e_{k-1})

and this decomposition is independent of all refinements: inserting intermediate levels does not change the total, only redistributes corrections among the tower.

**Test.** Computationally verify the decomposition for all filtrations with n ≤ 10 steps and exponents ≤ 20. Formally prove the n-step composition law by induction on n, using `cyclic_composition_law` as the base case. The four-step case (`four_step_decomposition`) is already proved.

**Impact.** This would give a complete recursive obstruction calculus for arbitrary finite filtrations, providing the algebraic foundation for spectral-sequence-style convergence in computational contexts. It would also yield an O(n) algorithm for total obstruction computation.

**Catalog References.** `Pythagorean/FiltrationObstruction.lean`: `cyclic_composition_law`, `four_step_decomposition`.

**Proof Strategy.** Induction on n. The inductive step uses `cyclic_composition_law` applied to the triple (e_0, e_{n-1}, e_n), decomposing the (n-1)-step total into the (n-2)-step total plus a new correction.

**Domain Bridges.** Persistent homology (multi-scale barcodes), spectral sequence differentials (d_r pages as iterated corrections), hierarchical data analysis.

**Lineage.** Direct extension of `four_step_decomposition` and `cyclic_composition_law`.

**Ambition.** Solid extension — the four-step case is proved; the general case follows the same pattern.

---

## Direction 2: Non-Cyclic Filtrations and Direct Sum Decomposition

**Conjecture (Additivity on Primary Decomposition).** For a three-step filtration of finitely generated abelian groups A ⊆ B ⊆ C, the correction term decomposes additively over the primary decomposition:

  correction(A, B, C) = Σ_p correction(A_p, B_p, C_p)

where A_p, B_p, C_p are the p-primary components. Each primary correction is computed by the cyclic formula on the invariant factor exponents.

**Test.** (a) Formalize direct sum filtrations in Lean and prove additivity of the obstruction profile. (b) Compute corrections for filtrations of groups like Z/12 ⊆ Z/60 ⊆ Z/360 by decomposing into 2-primary, 3-primary, and 5-primary parts. (c) Verify computationally for groups with rank ≤ 3 and orders ≤ 1000.

**Impact.** Would extend the theory from cyclic to arbitrary finitely generated abelian groups, covering all cases relevant to computational topology and algebraic number theory.

**Catalog References.** `Catalog/Algebra/Homology/DerivedFunctors/ExtTorBasic.lean`: `Ext1_ZMod_ZMod_equiv`, `Tor1_ZMod_ZMod_equiv`.

**Proof Strategy.** Use the fact that Ext commutes with finite direct products, so the obstruction profile of a direct sum is the sum of profiles. Requires formalizing the Ext computation for products of cyclic groups.

**Domain Bridges.** Algebraic number theory (ideal class group filtrations), crystallography (space group extensions), coding theory (linear code hierarchies).

**Lineage.** Builds on `Ext1_ZMod_ZMod_equiv` and `cyclicObstructionProfile`.

**Ambition.** Solid extension — the mathematical content is classical, but the formal verification would be novel.

---

## Direction 3: Derived Persistence Detectability

**Conjecture (Grand Challenge).** There exist filtered chain complexes C_* with identical pairwise persistence barcodes (over any field) but distinct triple correction profiles. Specifically, for two three-step filtrations of chain complexes whose homology groups have the same pairwise Betti numbers at every scale, the correction terms can differ.

**Test.** Construct explicit filtered chain complexes over Z with torsion in homology. Compute persistence barcodes over Q, F_2, F_3 and show they agree, then compute the correction terms and show they differ. A concrete candidate: two filtered simplicial complexes with H_1 filtrations Z/4 ⊆ Z/8 ⊆ Z/16 vs Z/4 ⊆ Z/16 ⊆ Z/64 — same pairwise Betti numbers but different corrections (min(2,2)=2 vs min(2,4)=2... need to find separating examples with different gap structures).

**Impact.** Would prove that obstruction calculus captures genuinely new topological information invisible to standard persistent homology, establishing it as a necessary complement to barcode invariants.

**Catalog References.** `Catalog/Algebra/Homology/DerivedFunctors/TorsionDetection.lean`: `torsion_persistence_functorial`, `prime_selectivity`.

**Proof Strategy.** Construct filtrations with matching field-coefficient persistence but differing integer-coefficient torsion structure. Use `correction_vanishes_iff` to identify the distinguishing criterion.

**Domain Bridges.** Topological data analysis (beyond barcodes), materials science (multi-scale defect detection), computational biology (hierarchical shape analysis).

**Lineage.** Extends `torsion_persistence_functorial` from detection to quantitative discrimination.

**Ambition.** Grand challenge — requires bridging abstract algebra with computational topology constructions.

---

## Direction 4: Valuation-Theoretic Generalization to Number Rings

**Conjecture.** For filtrations of modules over the ring of integers O_K of a number field K, the correction exponent at each prime ideal p generalizes to min(v_p(|A|) ∸ v_p(|Q_1|), v_p(|Q_2|)), where v_p is the p-adic valuation. The global correction is determined by local corrections at each prime, recovering the cyclic formula at each localization.

**Test.** Formalize the correction for Z[i]-modules (Gaussian integers) and verify that the local-global principle holds for small examples. Compute corrections for filtrations of Z[√-5]-modules where unique factorization fails and check whether the formula still applies.

**Impact.** Would connect filtration obstruction theory to algebraic number theory, potentially giving new invariants for ideal class filtrations and Iwasawa-theoretic towers.

**Catalog References.** `Pythagorean/FiltrationObstruction.lean`: `correction_eq_gap_invariant`, `three_step_obstruction_functorial`.

**Proof Strategy.** Use localization to reduce to the local case (PIDs), where the cyclic computation applies. The global assembly uses the Chinese Remainder Theorem structure.

**Domain Bridges.** Algebraic number theory (Iwasawa theory, ideal class groups), arithmetic geometry (filtrations on étale cohomology), cryptography (lattice-based constructions).

**Lineage.** Generalizes `correction_eq_gap_invariant` from Z to O_K.

**Ambition.** Grand challenge — requires significant new algebraic infrastructure.

---

## Direction 5: Obstruction Stability Under Perturbation

**Conjecture.** For a continuous family of filtrations (parameterized by a real parameter t) where the exponent triple (a(t), b(t), c(t)) varies, the correction exponent is piecewise constant with jumps occurring precisely at the critical surfaces 2a = b and a = c - a. The jump sizes are always integers, giving a discrete invariant of continuous deformations.

**Test.** (a) Define a one-parameter family of filtrations and track the correction as the parameter varies. (b) Prove that the correction function t ↦ min(a(t) ∸ (b(t)-a(t)), c(t)-b(t)) is piecewise constant when the exponents are piecewise constant (obvious) and piecewise linear when the exponents are piecewise linear (requires checking critical loci). (c) Count the number of distinct correction values for random filtrations with bounded exponents.

**Impact.** Would establish stability properties essential for applications to noisy data (TDA) and approximate computations. The critical surfaces where corrections jump are the "phase boundaries" of filtered extension theory.

**Catalog References.** `Pythagorean/FiltrationObstruction.lean`: `correction_vanishes_iff`, `correction_monotone_in_right_gap`.

**Proof Strategy.** Use `correction_monotone_in_right_gap` and the explicit formula to analyze level sets. The critical locus is where `a = b - a` (equivalently `2a = b`), which is a codimension-1 surface in parameter space.

**Domain Bridges.** Topological data analysis (stability theorems), dynamical systems (bifurcation theory analogy), signal processing (multi-resolution analysis).

**Lineage.** Extends `correction_monotone_in_right_gap` and `correction_vanishes_iff`.

**Ambition.** Solid extension — the piecewise-constant case is straightforward; the continuous generalization requires care with floor/ceiling functions.
