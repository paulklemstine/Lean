
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: We formalized the **Causal Integration Algebra** in two Lean 4 files (`Shared/Ca
**Domain**: Physics
**Mathematical framing**: # Future Directions: Causal Integration Algebra

## What We Built

We formalized the **Causal Integration Algebra** in two Lean 4 files (`Shared/CausalIntegration/Core.lean` and `Shared/CausalIntegration/Composition.lean`), establishing a rigorous lattice-theoretic foundation connecting Integrated Information Theory (IIT) to minimum cuts of weighted directed graphs. The framework defines:

- `CausalSystem n`: weighted directed graphs on `Fin n` with nonneg edge weights
- `crossInfo C S`: total weight crossing a bipartition (cut value)
- `phi C hn`: integrated information Φ as the minimum cut over nontrivial bipartitions

We proved **11 theorems** with zero sorries:
1. `crossInfo_nonneg` — cut values are nonneg
2. `phi_nonneg` — Φ ≥ 0
3. `phi_le_crossInfo` — Φ ≤ any specific cut
4. `phi_zero_of_disconnected` — disconnected ⟹ Φ = 0
5. `crossInfo_scale` / `phi_scale` — Φ scales linearly with weights
6. `crossInfo_mono` / `phi_mono_of_weight_le` — monotonicity under pointwise weight increase
7. `crossInfo_le_totalWeight` / `phi_le_totalWeight` — upper bound by total weight
8. `symmetrize_crossInfo` — symmetrization decomposes into two directed cuts
9. `crossInfo_pos_of_stronglyPositive` / `phi_pos_of_stronglyPositive` — strongly positive systems have Φ > 0

---

## Direction 1: Spectral Lower Bound via Cheeger Inequality

The Fiedler value λ₂ (second-smallest eigenvalue of the graph Laplacian) provides a spectral lower bound on the minimum cut. For a symmetric causal system, the Cheeger inequality gives λ₂/2 ≤ h(G) where h(G) is the Cheeger constant (normalized minimum cut). The key insight is that our `phi` is closely related to the unnormalized Cheeger constant, so formalizing the graph Laplacian and its spectral gap would yield a computable lower bound on Φ — avoiding exponential brute-force enumeration. Why now? We have `phi_mono_of_weight_le` and `symmetrize_crossInfo` as the foundation; the missing piece is the Rayleigh quotient characterization of λ₂, which requires formalizing inner products on `Fin n → ℝ` and the Laplacian as a linear map.

## Direction 2: Converse of Disconnectedness — Characterizing Φ = 0

We proved `phi_zero_of_disconnected`: if a zero-weight cut exists, Φ = 0. The converse — Φ = 0 implies disconnectedness — is more subtle and amounts to showing that the minimum of a finite set of nonneg reals is zero iff some element is zero. The key insight is that this follows from `Finset.inf'` equaling zero in a linearly ordered type with no infinitesimals, which is elementary but requires careful handling of the `inf'` API. Why now? The proof is a direct corollary of our existing `phi_nonneg` and `phi_le_crossInfo`, combined with the fact that ℝ has no positive infinitesimals — the minimum of finitely many nonneg reals is zero iff at least one is zero.

## Direction 3: Subadditivity and the Exclusion Postulate

IIT's exclusion postulate states that Φ picks out a unique "grain" of causal structure. Formally, if C has a k-partition P = {P₁, ..., Pₖ}, then Φ(C) ≤ Σᵢ Φ(C|Pᵢ) + cross-terms. The key insight is that restricting a causal system to a subset S induces a sub-system, and the global minimum cut either aligns with the partition (giving a cross-term) or cuts through some part (giving a term bounded by that part's Φ). Why now? Our `crossInfo_mono` and monotonicity infrastructure provide the inequalities needed to relate restricted and global cuts; the missing formalization is the notion of restriction `C.restrict S` and its interaction with `crossInfo`.

## Direction 4: Compositional Φ for Direct Sums

For two causal systems C₁ on n₁ nodes and C₂ on n₂ nodes, the direct sum C₁ ⊕ C₂ on n₁ + n₂ nodes (with zero cross-weights) should satisfy Φ(C₁ ⊕ C₂) = 0, since the natural bipartition has zero cross-info. More interestingly, for a "weakly coupled" direct sum with small cross-weights ε, one expects Φ(C₁ ⊕ε C₂) = O(ε). The key insight is that `phi_mono_of_weight_le` already gives Φ(C₁ ⊕ε C₂) ≤ Φ(C₁ ⊕0 C₂) + O(ε·n²), but the tight bound requires analyzing which cut achieves the minimum — if ε is small enough, the minimum cut is the natural partition. Why now? The `scale` and `mono` theorems provide the analytical tools; formalizing `directSum` on `Fin (n₁ + n₂)` using `Fin.addCases` would make this immediately accessible.

## Direction 5: Information-Theoretic Interpretation via Mutual Information

When edge weights represent conditional mutual information I(Xᵢ; Xⱼ | X_rest), the cross-info of a bipartition S measures the total information flow between S and Sᶜ. Under this interpretation, Φ becomes the minimum information bottleneck. The key insight is that mutual information satisfies submodularity, which would strengthen our monotonicity results to give a submodular Φ function on the lattice of partitions — connecting to the extensive theory of submodular optimization. Why now? Our `crossInfo` is defined abstractly enough that any interpretation of weights applies; the missing piece is formalizing the submodularity inequality crossInfo(S ∪ T) + crossInfo(S ∩ T) ≤ crossInfo(S) + crossInfo(T) and showing it holds when weights satisfy the triangle inequality.

**Concept description**: # Future Directions: Causal Integration Algebra

## What We Built

We formalized the **Causal Integration Algebra** in two Lean 4 files (`Shared/CausalIntegration/Core.lean` and `Shared/CausalIntegration/Composition.lean`), establishing a rigorous lattice-theoretic foundation connecting Integrated Information Theory (IIT) to minimum cuts of weighted directed graphs. The framework defines:

- `CausalSystem n`: weighted directed graphs on `Fin n` with nonneg edge weights
- `crossInfo C S`: total weight crossing a bipartition (cut value)
- `phi C hn`: integrated information Φ as the minimum cut over nontrivial bipartitions

We proved **11 theorems** with zero sorries:
1. `crossInfo_nonneg` — cut values are nonneg
2. `phi_nonneg` — Φ ≥ 0
3. `phi_le_crossInfo` — Φ ≤ any specific cut
4. `phi_zero_of_disconnected` — disconnected ⟹ Φ = 0
5. `crossInfo_scale` / `phi_scale` — Φ scales linearly with weights
6. `crossInfo_mono` / `phi_mono_of_weight_le` — monotonicity under pointwise weight increase
7. `crossInfo_le_totalWeight` / `phi_le_totalWeight` — upper bound by total weight
8. `symmetrize_crossInfo` — symmetrization decomposes into two directed cuts
9. `crossInfo_pos_of_stronglyPositive` / `phi_pos_of_stronglyPositive` — strongly positive systems have Φ > 0

---

## Direction 1: Spectral Lower Bound via Cheeger Inequality

The Fiedler value λ₂ (second-smallest eigenvalue of the graph Laplacian) provides a spectral lower bound on the minimum cut. For a symmetric causal system, the Cheeger inequality gives λ₂/2 ≤ h(G) where h(G) is the Cheeger constant (normalized minimum cut). The key insight is that our `phi` is closely related to the unnormalized Cheeger constant, so formalizing the graph Laplacian and its spectral gap would yield a computable lower bound on Φ — avoiding exponential brute-force enumeration. Why now? We have `phi_mono_of_weight_le` and `symmetrize_crossInfo` as the foundation; the missing piece is the Rayleigh quotient characterization of λ₂, which requires formalizing inner products on `Fin n → ℝ` and the Laplacian as a linear map.

## Direction 2: Converse of Disconnectedness — Characterizing Φ = 0

We proved `phi_zero_of_disconnected`: if a zero-weight cut exists, Φ = 0. The converse — Φ = 0 implies disconnectedness — is more subtle and amounts to showing that the minimum of a finite set of nonneg reals is zero iff some element is zero. The key insight is that this follows from `Finset.inf'` equaling zero in a linearly ordered type with no infinitesimals, which is elementary but requires careful handling of the `inf'` API. Why now? The proof is a direct corollary of our existing `phi_nonneg` and `phi_le_crossInfo`, combined with the fact that ℝ has no positive infinitesimals — the minimum of finitely many nonneg reals is zero iff at least one is zero.

## Direction 3: Subadditivity and the Exclusion Postulate

IIT's exclusion postulate states that Φ picks out a unique "grain" of causal structure. Formally, if C has a k-partition P = {P₁, ..., Pₖ}, then Φ(C) ≤ Σᵢ Φ(C|Pᵢ) + cross-terms. The key insight is that restricting a causal system to a subset S induces a sub-system, and the global minimum cut either aligns with the partition (giving a cross-term) or cuts through some part (giving a term bounded by that part's Φ). Why now? Our `crossInfo_mono` and monotonicity infrastructure provide the inequalities needed to relate restricted and global cuts; the missing formalization is the notion of restriction `C.restrict S` and its interaction with `crossInfo`.

## Direction 4: Compositional Φ for Direct Sums

For two causal systems C₁ on n₁ nodes and C₂ on n₂ nodes, the direct sum C₁ ⊕ C₂ on n₁ + n₂ nodes (with zero cross-weights) should satisfy Φ(C₁ ⊕ C₂) = 0, since the natural bipartition has zero cross-info. More interestingly, for a "weakly coupled" direct sum with small cross-weights ε, one expects Φ(C₁ ⊕ε C₂) = O(ε). The key insight is that `phi_mono_of_weight_le` already gives Φ(C₁ ⊕ε C₂) ≤ Φ(C₁ ⊕0 C₂) + O(ε·n²), but the tight bound requires analyzing which cut achieves the minimum — if ε is small enough, the minimum cut is the natural partition. Why now? The `scale` and `mono` theorems provide the analytical tools; formalizing `directSum` on `Fin (n₁ + n₂)` using `Fin.addCases` would make this immediately accessible.

## Direction 5: Information-Theoretic Interpretation via Mutual Information

When edge weights represent conditional mutual information I(Xᵢ; Xⱼ | X_rest), the cross-info of a bipartition S measures the total information flow between S and Sᶜ. Under this interpretation, Φ becomes the minimum information bottleneck. The key insight is that mutual information satisfies submodularity, which would strengthen our monotonicity results to give a submodular Φ function on the lattice of partitions — connecting to the extensive theory of submodular optimization. Why now? Our `crossInfo` is defined abstractly enough that any interpretation of weights applies; the missing piece is formalizing the submodularity inequality crossInfo(S ∪ T) + crossInfo(S ∩ T) ≤ crossInfo(S) + crossInfo(T) and showing it holds when weights satisfy the triangle inequality.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Physics
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
