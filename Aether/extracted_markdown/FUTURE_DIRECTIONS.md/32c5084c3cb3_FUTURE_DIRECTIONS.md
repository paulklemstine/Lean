# Future Directions: Normalization Cost as Bisimulation Distance

## Synthesis

The formal development of `eqPathDist` as a pseudometric on lambda terms opens a quantitative interface between proof complexity, coalgebraic semantics, and metric geometry of programs. The key insight—that β-reduction step counts induce a well-behaved distance function with nonexpansive syntactic operations—creates a foundation for five interrelated research directions. Each builds on the verified Lean 4 theorems (pseudometric axioms, bridge theorem, context nonexpansiveness) and extends them toward deeper mathematical structure, computational applications, and connections to other fields. The directions range from concrete extensions of the current formalization (Directions 2–3) to paradigm-shifting conjectures (Directions 1 and 4) that would fundamentally change how we think about programs as geometric objects.

---

## Direction 1: Contractivity of Evaluation Strategies

**Conjecture**: For simply-typed lambda terms, the leftmost-outermost (call-by-name) evaluation strategy is *strictly contractive* with respect to `eqPathDist`: there exists a constant `c < 1` such that for all β-equivalent simply-typed terms `t, u` with `eqPathDist t u > 0`,

```
eqPathDist (eval₁(t)) (eval₁(u)) ≤ c · eqPathDist t u
```

where `eval₁` denotes one step of leftmost-outermost reduction.

**Test**: Enumerate simply-typed terms up to size 12. For each β-equivalent pair `(t, u)`, compute `eqPathDist(t, u)` and `eqPathDist(eval₁(t), eval₁(u))`. Plot the ratio. If the supremum of ratios is bounded below 1, the conjecture holds empirically. A single pair with ratio ≥ 1 disproves it.

**Impact**: If true, this would establish evaluation as a *contraction mapping* on equivalence classes, giving Banach-style fixed-point theorems for program transformations. It would connect lambda calculus to dynamical systems theory and provide convergence rates for iterative program optimization.

**Catalog References**: `Catalog/Pythagorean/NormalizationBisimDistance.lean` (eqPathDist, nonexpansiveness), `Catalog/Pythagorean/BoundedBetaDefs.lean` (BetaStep, ReachableWithin)

**Proof Strategy**: Prove by induction on simply-typed derivations. The key is showing that leftmost-outermost reduction strictly decreases the step count for at least one of the two paths in the BetaEqIn derivation.

**Domain Bridges**: Dynamical systems (contraction mappings), metric fixed-point theory, quantitative type theory

**Lineage**: Extends `eqPathDist_app_left_le`, `eqPathDist_app_right_le`, `eqPathDist_lam_le`

**Ambition**: Grand challenge — would create a new theory of "computational dynamics"

---

## Direction 2: Church-Rosser via de Bruijn Indices

**Conjecture**: With a capture-avoiding substitution (de Bruijn indices), the full Church-Rosser theorem is provable, and the `subst_subst_parBeta` sorry in `ChurchRosserBisimulation.lean` can be eliminated. Moreover, Church-Rosser gives uniqueness of normal forms, which upgrades `eqPathDist_le_normCost_sum` to an unconditional theorem: for all β-equivalent normalizing terms, `d(t, u) ≤ normCost(t) + normCost(u)`.

**Test**: Implement de Bruijn lambda terms in Lean 4, prove `subst_subst_parBeta`, and verify the full proof chain compiles without sorry.

**Impact**: Removes the one remaining sorry in the ChurchRosserBisimulation development and closes the gap between the quantitative pseudometric and the full normalization cost bound.

**Catalog References**: `Catalog/Speculative/AutoResearch/ChurchRosserBisimulation.lean` (subst_subst_parBeta, church_rosser), `Catalog/Pythagorean/NormalizationBisimDistance.lean` (eqPathDist_le_normCost_sum)

**Proof Strategy**: Define de Bruijn terms, lift/shift operations, capture-avoiding substitution. Prove the substitution lemma by mutual induction on parallel reduction and de Bruijn index structure.

**Domain Bridges**: Type theory, proof engineering, formal verification

**Lineage**: Directly extends `ChurchRosserBisimulation.lean`

**Ambition**: Solid extension — standard but essential infrastructure

---

## Direction 3: Quantitative Full Abstraction

**Conjecture**: For the simply-typed lambda calculus, the `eqPathDist` pseudometric is *fully abstract* with respect to a natural observational preorder: `eqPathDist(t, u) = 0` if and only if `t` and `u` are observationally equivalent in all contexts of bounded observation depth.

**Test**: For simply-typed terms up to size 10, enumerate all contexts of depth ≤ 5. Check whether `eqPathDist(t, u) = 0` implies identical observations in all tested contexts, and conversely whether any observational distinction implies `eqPathDist > 0`.

**Impact**: Full abstraction results connect operational and denotational semantics. A quantitative full abstraction theorem would be the first of its kind for lambda calculus: not just "same behavior iff same denotation" but "behavioral distance equals semantic distance."

**Catalog References**: `Catalog/Pythagorean/NormalizationBisimDistance.lean` (eqPathDist), `Catalog/Pythagorean/BoundedBetaTheorems.lean` (WeakBisimilar, modal invariance)

**Proof Strategy**: Define observational distance as supremum over context depths at which observations diverge. Show this equals `eqPathDist` on simply-typed terms using the bridge theorem and modal invariance.

**Domain Bridges**: Denotational semantics, game semantics, program equivalence

**Lineage**: Extends `weakBisimilar_of_joinBudget`, `eqPathDist_triangle`

**Ambition**: Grand challenge — would bridge operational and denotational worlds

---

## Direction 4: Metric Completion and Infinite-Type Spaces

**Conjecture**: The metric completion of the space of lambda terms under `eqPathDist` is isomorphic to a Scott domain, and the completed metric structure is a quantitative domain in the sense of Lawvere.

Specifically, define `d̂(t, u) = eqPathDist(t, u) / (1 + eqPathDist(t, u))` to normalize to [0, 1]. The Cauchy completion of this space should recover the standard domain-theoretic denotation as a metric limit.

**Test**: For simply-typed terms of increasing complexity, compute `d̂` values and check whether Cauchy sequences of terms converge to semantic objects that match known domain-theoretic interpretations.

**Impact**: This would create a bridge between domain theory (Scott, Abramsky) and metric semantics (Lawvere, de Bakker), unifying two major traditions in programming language semantics through an explicitly computable metric.

**Catalog References**: `Catalog/Pythagorean/NormalizationBisimDistance.lean` (eqPathDist, pseudometric axioms)

**Proof Strategy**: Use the triangle inequality and completeness of ℝ. The key is showing that `eqPathDist` separates points on the quotient by β-equivalence (making it a proper metric, not just pseudometric).

**Domain Bridges**: Domain theory, Lawvere metric spaces, quantitative algebraic topology

**Lineage**: Extends `eqPathDist_self`, `eqPathDist_comm`, `eqPathDist_triangle`

**Ambition**: Grand challenge — paradigm shift

---

## Direction 5: Substitution Lipschitz Bound

**Conjecture**: Substitution is *Lipschitz* with respect to `eqPathDist`:

```
eqPathDist(t[x := s₁], t[x := s₂]) ≤ occ(x, t) · eqPathDist(s₁, s₂)
```

where `occ(x, t)` is the number of free occurrences of `x` in `t`. For *affine* terms (at most one occurrence of each variable), substitution is nonexpansive.

**Test**: For terms of size ≤ 8, compute `eqPathDist(t[x := s₁], t[x := s₂])` and `occ(x, t) · eqPathDist(s₁, s₂)` for various substitution targets. Any violation disproves the bound.

**Impact**: A Lipschitz bound on substitution would make the pseudometric compositional: the distance between two programs could be computed from the distances of their subterms. This is the key property needed for compositional verification.

**Catalog References**: `Catalog/Pythagorean/NormalizationBisimDistance.lean` (eqPathDist, BetaEqIn, context nonexpansiveness), `Catalog/Pythagorean/BoundedBetaDefs.lean` (Lam.subst)

**Proof Strategy**: Induction on `t`, using the fact that each occurrence of `x` contributes one copy of the BetaEqIn derivation for `(s₁, s₂)` through the substitution. The affine case follows immediately; the general case requires bounding the interaction between copies.

**Domain Bridges**: Program analysis, differential privacy (sensitivity analysis), quantitative information flow

**Lineage**: Extends `eqPathDist_app_left_le`, `eqPathDist_app_right_le`, `eqPathDist_lam_le`

**Ambition**: Solid extension with high practical impact
