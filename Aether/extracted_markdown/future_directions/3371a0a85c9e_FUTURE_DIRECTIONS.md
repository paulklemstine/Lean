# Future Directions — Mathematics as an Evolving Ecosystem

Derived from the Phase A cycle that produced `Fitness.lean`,
`CompetitiveExclusion.lean`, and `Evolution.lean`.  Each direction is a bold,
falsifiable conjecture about the fitness model
`f(T) = connections(T) · proofDensity(T) / axiomCount(T)`.

---

## 1. Selection pressure toward *primitive* (irreducible) theories

**Conjecture.** Under any fitness-improving evolution, the long-run population is
dominated by theories that are not Rankin–Selberg-type products of smaller
theories; composite theories are an evolutionary dead end.

The key insight is that `selberg_product_fitness_subadditive` shows the conductor
(axiomatic cost) *multiplies* under composition while the degree (connection
count) only *adds*, so `f(S₁ × S₂) ≤ f(S₁) + f(S₂)` with strict loss whenever both
factors are non-trivial — composition can never create fitness, only dilute it.

Why now? We already have the Selberg census `product` operation formalized and the
subadditivity inequality proved, so the next step (defining a primitivity
predicate and proving products are strictly sub-apex) is directly within reach
rather than speculative.

---

## 2. A carrying capacity for foundational theories

**Conjecture.** For any finite niche space `N`, every ecosystem at equilibrium has
at most `card N` theories, and this bound is *tight*: there exist equilibria
realizing exactly `card N` distinct foundational theories.

The key insight is that `niche_packing` already proves the upper bound
`card E ≤ card N` from injectivity alone; tightness would follow from exhibiting a
section of the niche map, turning the inequality into an exact carrying-capacity
law for mathematics' foundational layer.

Why now? The pigeonhole half is done and axiom-checked; only the constructive
(surjective-section) half remains, which is a finite combinatorial construction.

---

## 3. A phase transition in the value of new axioms

**Conjecture.** Along a family of extensions `T ⊆ T₊` that add `a` axioms and gain
`c` connections at proof density `d`, fitness increases **iff**
`c·d·axioms(T) > connections(T)·proofDensity(T)·(axioms(T)+a)` — there is a sharp
threshold separating "fertile" axioms (large cardinals) from "sterile" ones.

The key insight is that `fitness_lt_iff_cross` is an *exact* characterization
(an iff, not a one-sided bound), so the boundary case is a genuine equality
hyperplane, and `zfc_lc_strictly_fitter` is one verified point strictly on the
fertile side.

Why now? The cross-multiplication criterion is proven and reusable, so quantifying
the threshold for concrete extension families (ZFC + CH, ZFC + PD, ZFC + I0) is a
matter of plugging in trait estimates rather than new theory.

---

## 4. Open-endedness: no bounded "final theory"

**Conjecture.** There is no theory of maximal fitness; equivalently, every
fitness-improving lineage is cofinal in fitness, so mathematics has no
fitness-saturating "theory of everything".

The key insight is that `evolution_escapes_finite` proves a fitness-improving
trajectory cannot be confined to any finite ecosystem, because the trajectory is
injective (`evolution_injective`) and ℕ does not inject into a finite set —
unbounded ascent is forced, not assumed.

Why now? The injectivity and finite-escape theorems are already axiom-clean;
upgrading "escapes every finite set" to "fitness → ∞" only needs an
Archimedean/cofinality argument over ℚ, which Mathlib supports directly.

---

## 5. Foundational monism under niche injectivity

**Conjecture.** If the foundational ecosystem ever reaches a state where all
fitnesses are distinct, then it has a unique apex theory, and that apex is a global
attractor of fitness-improving dynamics.

The key insight is that `fitness_max_unique` already gives uniqueness of the
fitness-maximizer under `Set.InjOn fitness`; combining it with the monotone,
acyclic trajectory of `evolution_strictMono` suggests the apex is not merely unique
but dynamically selected.

Why now? Both ingredients — apex uniqueness and strictly monotone evolution — are
proved in this cycle, so the attractor claim is the natural synthesis to test
next, e.g. by formalizing convergence of trajectories that stay within a finite
equilibrium.
