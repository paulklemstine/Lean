# Future Directions: Completing the Combinatorial–Categorical Bridge via Species

## Synthesis

The base file `CombinatorialSpecies.lean` opened Joyal's bridge between *combinatorial
species* and *exponential generating functions* (EGFs) by proving that the EGF is additive
over the sum of species (`egf_add`), multiplicative over the structural Day-convolution
product (`egf_mul`, `egf_card_prodSpecies`, resting on the counting identity
`card_prodSpecies`), and sends the species of sets to `exp` and linear orders to `1/(1-X)`.

This cycle's file, `SpeciesAnalyticBridge.lean`, upgrades those isolated homomorphism
identities into the three structural pillars of an *analytic functor*:

1. **Inversion.** `egf` is not merely a homomorphism but a *bijection* `(ℕ → ℚ) ≃ ℚ⟦X⟧`
   (`egfEquiv`) with the explicit inverse `seqOf f n = n!·coeff n f`. Hence the EGF is a
   **complete invariant**: two species share an EGF iff they share a counting sequence
   (`Species.EGF_inj`). Building on `coeff_egf` from the base file, this needed *no* deep
   analysis — the inverse is written down, not conjured.
2. **Differentiation.** The derivative species `F'[n]=F[n+1]` maps to the formal derivative
   `d/dX` (`egf_seqDeriv`); the pointed species `F^•[n]=n·F[n]` maps to `X·d/dX`
   (`egf_seqPoint`). Mathlib's `derivativeFun`/`coeff_derivativeFun` made the analytic side
   free, so each law is a one-line coefficient computation over `coeff_egf`.
3. **Leibniz.** The structural product rule `(F·G)' = F'·G + F·G'` holds at sequence level
   (`binConv_leibniz`). This is the payoff of inversion: an analytic identity
   (`derivativeFun_mul`) is *transported back* through the injective bridge into a
   combinatorial theorem about binomial convolutions with zero index gymnastics.

### Results summary (all `sorry`-free, axioms: propext/Classical.choice/Quot.sound)

| Theorem | Statement |
|---|---|
| `egf_injective`, `egf_surjective`, `egf_bijective` | `egf` is a bijection |
| `egfEquiv` | the bijection `(ℕ → ℚ) ≃ ℚ⟦X⟧` with inverse `seqOf` |
| `Species.EGF_inj` | EGF is a complete invariant for labelled species |
| `egf_seqDeriv` | `EGF(F') = d/dX EGF(F)` |
| `egf_seqPoint` | `EGF(F^•) = X·d/dX EGF(F)` |
| `binConv_leibniz` | `(a⋆b)' = a'⋆b + a⋆b'` |
| `egf_zero`, `egf_binConvOne` | `egf` preserves the rig `0` and `1` |

## Direction 1 — The substitution (composition) law and the Exponential Formula

Define species substitution `(F ∘ G)[n] = Σ_{π ∈ Part(n)} F[π] × ∏_{B∈π} G[B]` over set
partitions, and prove its EGF is the plethystic composition `(EGF F) ∘ (EGF G)` (for `G`
with zero constant term). Specializing `F = E` (sets) yields the **Exponential Formula**:
the EGF of "sets of `G`-structures" is `exp(EGF G)`.

The key insight is that `card_prodSpecies` already isolated the only hard step — counting
subsets by cardinality — so substitution is just iterating that count over a partition,
making `|(F∘G)[n]|` a partition-sum of multinomials times `∏|G[B]|`, which is exactly
plethystic coefficient extraction; and now that `egf` is known *bijective* (`egfEquiv`), the
identity can be checked one coefficient at a time and lifted, exactly as `binConv_leibniz`
lifts the Leibniz rule. Why now? Mathlib's `Finpartition` and `exp`/`log` power-series API,
plus this cycle's inversion theorem, make the Exponential Formula — the single most-used
identity in enumerative combinatorics — the natural next target.

## Direction 2 — `egf` as a bundled semiring isomorphism (`RingEquiv`)

Equip `ℕ → ℚ` with `binConv` as multiplication and `binConvOne` as unit, prove it is a
commutative semiring, and upgrade `egfEquiv` to a `RingEquiv (ℕ → ℚ) ℚ⟦X⟧`.

The key insight is that *every* axiom is already in hand: `egf_add`, `egf_mul`,
`egf_zero`, `egf_binConvOne` are the (semi)ring-hom laws, `egf_injective`/`egf_surjective`
give the equivalence, and associativity/commutativity/distributivity of `binConv` can
themselves be proved by transporting the corresponding power-series laws back through the
bijection (the `binConv_leibniz` trick), so no raw multinomial manipulation is required.
Why now? A bundled `RingEquiv` makes the bridge reusable by `ring`/`simp` automation across
the whole catalog and is the cleanest formal statement of "EGFs *are* counting sequences."

## Direction 3 — Cycle-index series and the unlabelled (Pólya) bridge

Define the cycle-index series `Z_F = Σ_n (1/n!) Σ_{σ∈Sₙ} |Fix(F[σ])| · p_1^{c_1(σ)}⋯` in
symmetric functions, prove `Z_{F+G}=Z_F+Z_G` and `Z_{F·G}=Z_F·Z_F`, and show the
specialization `p_1↦x, p_{k≥2}↦0` recovers our EGF while `p_k↦x^k` gives the ordinary
generating function for *unlabelled* structures.

The key insight is that the `Species.act` field — the symmetric-group action that every EGF
theorem so far ignored — is *precisely* the fixed-point data the cycle index consumes, so
the cycle index is the genuine reason `act` belongs in the definition; and our EGF appears
as the `p_1`-specialization, making `egf_add`/`egf_mul` literal corollaries of the
cycle-index ring laws. Why now? Mathlib's `MvPolynomial`/symmetric-function library and
`Equiv.Perm` fixed-point counting are mature, and this turns the currently-decorative
functorial structure into a load-bearing invariant unifying labelled and unlabelled
enumeration under one definition.

## Direction 4 — Second-order calculus: `binConv_leibniz` ⇒ Faà di Bruno

Iterate the product rule to prove the general Leibniz formula
`(a⋆b)^{(n)} = Σ_k C(n,k) a^{(k)}⋆b^{(n-k)}` and, combined with Direction 1's substitution,
a species-level **Faà di Bruno** formula for the higher derivatives of a composition,
indexed by set partitions.

The key insight is that `binConv_leibniz` is the `n=1` base case of an induction whose
inductive step is again a transport of `derivativeFun`'s higher-order law through
`egf_injective`, so the entire higher calculus of species is reachable without touching a
single binomial coefficient by hand. Why now? With first derivatives, pointing, and the
single-step Leibniz rule already formalized this cycle, the induction is short, and Faà di
Bruno is the keystone linking differentiation (Direction 4) to composition (Direction 1).

## Direction 5 — Skeletal-to-genuine comparison: species as functors on `FintypeCat`

Promote the skeletal `Species` structure to a genuine functor `FinBij ⥤ FintypeCat` on the
groupoid of finite sets and bijections, and prove the restriction-to-skeleton functor is an
equivalence, so that `egf_seqDeriv`, `egf_seqPoint`, `binConv_leibniz`, and `Species.EGF_inj`
all transport to the categorical definition.

The key insight is that the groupoid of finite sets is equivalent to its skeleton
`∐ₙ BSₙ` — one object per cardinality with automorphism group `Sₙ` — which is *exactly* the
`(obj, act)` data of `Species`, so the comparison is an instance of "a functor out of a
groupoid is determined by its values on a skeleton plus the automorphism action." Why now?
Mathlib's `CategoryTheory.Skeleton` and `FintypeCat` are mature, and this is the theorem
that earns the name *analytic functor* in the literal categorical sense, completing the
combinatorial–categorical bridge.
