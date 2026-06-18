# Future Directions: Tropical Energy Semantics for Normalization

## Synthesis

The tropical potential framework establishes a new bridge between proof theory, tropical algebra, and discrete dynamical systems. Our formally verified results cover the affine fragment of STLC — the regime without duplication. The five directions below form a coherent research program to extend this framework: (1) breaking the duplication barrier to cover full STLC, (2) leveraging tropical profile vectors for finer structural analysis, (3) connecting to linear logic where affinity is built in, (4) exploring phase transitions at the boundary of dissipativity, and (5) transferring the energy semantics to richer calculi. Each direction builds on the verified compositional substitution theorem and the product potential construction.

---

## Direction 1: Breaking the Duplication Barrier

**Conjecture.** There exists a (possibly non-compositional) ℕ-valued potential Ψ : Tm → ℕ such that for ALL β-steps (not just affine) in the simply-typed lambda calculus, Ψ(u) < Ψ(t) whenever Step t u.

**Test.** Implement a candidate Ψ that includes a "duplication penalty" proportional to occN(0, body) · Φ(arg) for each redex (λ.body) arg. Enumerate all well-typed STLC terms up to size 12 and check strict decrease. If the penalty-based Ψ fails, try multiset-valued potentials encoded as ℕ via Cantor pairing.

**Impact.** Resolving this would provide the first explicit ℕ-valued Lyapunov function for full STLC normalization, unifying the affine and non-affine cases under a single energy principle.

**Catalog References.** `Tropical/TropicalEnergy/Theorems.lean` — tropicalPotential_beta_decrease, tropicalPotential_substN_le_mul

**Proof Strategy.** The substitution energy bound fails when occN ≥ 2 because the parameterized potential becomes quadratic in v. A duplication-aware potential would need to pre-charge for duplication at the lambda node, using type-depth information to bound the maximum duplication factor. Define Ψ(lam t) = Φ(t) · 2^{occN(0,t)} and verify computationally.

**Domain Bridges.** Connects to termination orderings in term rewriting theory (Dershowitz-Manna), multiset path orderings, and semantic methods in denotational semantics.

**Lineage.** Direct extension of the compositional substitution theorem (Theorem 3).

**Ambition.** Grand challenge — would resolve a 50+ year open formalization problem.

---

## Direction 2: Tropical Profile Vectors

**Conjecture.** Define tropicalProfile(t) = (Φ₀(t), Φ₁(t), ..., Φ_d(t)) where Φᵢ counts application nodes at type-depth i, weighted by 2^i. Then for every β-step (including non-affine), tropicalProfile(u) <_lex tropicalProfile(t) under lexicographic ordering.

**Test.** Implement the profile vector and compute it for all well-typed STLC terms up to size 16. Verify lexicographic decrease for all β-redexes. If scalar decrease fails for some step, check whether the profile still decreases lexicographically.

**Impact.** Would provide a finer-grained energy analysis that captures the tropical geometry of the reduction landscape, potentially extending beyond the affine barrier.

**Catalog References.** `Tropical/TropicalEnergy/Defs.lean` — typeDepth, tropicalPotential

**Proof Strategy.** The key observation is that β-reduction can only create new redexes at strictly lower type-depth than the fired redex. A type-depth-stratified potential should decrease in the highest affected component, with lower components potentially increasing but bounded.

**Domain Bridges.** Tropical geometry (Newton polytopes, tropical varieties), combinatorial optimization (min-plus semiring), weighted automata theory.

**Lineage.** Combines typeDepth analysis with the compositional substitution theorem.

**Ambition.** Grand challenge — would open a new tropical-geometric perspective on normalization.

---

## Direction 3: Linear Logic Transfer

**Conjecture.** The tropical potential extends naturally to multiplicative linear logic (MLL) proof nets, where the affine restriction is built into the logic. Every cut-elimination step in MLL strictly decreases the tropical potential adapted to proof nets.

**Test.** Formalize MLL proof nets in Lean 4. Define tropical potential for proof nets (nodes weighted by formula depth, multiplicative linking). Verify decrease for all cut-elimination steps on proof nets up to 20 nodes.

**Impact.** Would establish tropical energy semantics as a universal principle for resource-sensitive logics, connecting to Girard's geometry of interaction and quantitative semantics.

**Catalog References.** `Tropical/TropicalEnergy/Theorems.lean` — affineTropicalModel, TropicalEnergyModel

**Proof Strategy.** MLL is inherently linear (each hypothesis used exactly once), so the affine substitution bound should hold directly. The challenge is adapting the product interpretation from tree-structured terms to graph-structured proof nets.

**Domain Bridges.** Linear logic, proof nets, geometry of interaction, categorical semantics, quantum computing (linear type systems).

**Lineage.** Natural extension of the affine fragment results.

**Ambition.** Solid extension — leverages existing affine results in a new setting.

---

## Direction 4: Phase Transition in Weight Space

**Conjecture.** For the parameterized family of potentials Φ_w(var) = w, Φ_w(lam t) = Φ_w(t) + 1, Φ_w(app f a) = Φ_w(f) · Φ_w(a), there exists a critical weight w₀ = 2 such that:
- For w ≥ w₀: Φ_w is universally dissipative for affine β (as proved).
- For w = 1: Φ_w fails for some affine β-redexes.
- The transition is sharp: at w = w₀, all affine redexes satisfy strict decrease, and at w = w₀ - 1, there exist counterexamples.

**Test.** For w ∈ {1, 2, 3, 4, 5}, enumerate all affine β-redexes up to size 10 and count violations. Plot violation rate vs. w. Identify the exact critical w₀ and characterize the first counterexample at w₀ - 1.

**Impact.** Would reveal the precise mathematical threshold for dissipativity, connecting to phase transition phenomena in combinatorial optimization and statistical physics.

**Catalog References.** `Tropical/TropicalEnergy/Theorems.lean` — potentialWith_ge_two, tropicalPotential_substN_le_mul

**Proof Strategy.** The substitution energy bound Φ(subst) ≤ Φ(t) · Φ(s) relies on Φ(s) ≥ 2 (from w ≥ 2). For w = 1, Φ(var) = 1, and the bound Φ(subst t s) ≤ Φ(t) · 1 = Φ(t) requires Φ(subst t s) ≤ Φ(t), which fails when var 0 is substituted by a term with potential > 1.

**Domain Bridges.** Statistical physics (phase transitions), random constraint satisfaction, computational complexity thresholds.

**Lineage.** Parametric variation of the core product potential.

**Ambition.** Solid extension — computationally tractable with clear theoretical implications.

---

## Direction 5: Differential Lambda Calculus

**Conjecture.** The tropical potential extends to the differential lambda calculus (Ehrhard-Regnier), where differentiation of functions is a primitive operation. The Taylor expansion of a function's tropical potential converges, and each expansion step (differential substitution) decreases the potential.

**Test.** Implement the differential lambda calculus with de Bruijn indices. Define an adapted tropical potential that accounts for differential nodes. Verify decrease for β-reduction and differential reduction rules on terms up to size 8.

**Impact.** Would connect tropical energy semantics to the rapidly growing field of differentiable programming and automatic differentiation, with potential applications in machine learning foundations.

**Catalog References.** `Tropical/TropicalEnergy/Defs.lean` — TropicalEnergyModel, tropicalPotential

**Proof Strategy.** The differential lambda calculus has a linear substitution rule (the derivative is linear), so the affine energy bound should apply to the differential component. The challenge is handling the interaction between ordinary β-reduction and differential reduction.

**Domain Bridges.** Differentiable programming, automatic differentiation, quantitative semantics, smooth analysis, machine learning theory.

**Lineage.** Extension of the energy model to a richer calculus.

**Ambition.** Grand challenge — would bridge formal verification and machine learning foundations.
