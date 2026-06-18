# Future Directions: Provability Logic as a Fixed-Point Theory

## Synthesis

This cycle rebuilt and *deepened* the order-theoretic core of Gödel–Löb provability
logic. The starting point was a dangling dependency: `Catalog/Logic/LobNatModel.lean`
imported a non-existent `Logic/LobFixedPoint`, so the entire concrete `(ℕ, >)` model was
uncompilable. We supplied that missing foundation as a genuine **Gödel–Löb algebra**
typeclass `GLOperator` — a Heyting algebra with a normal box satisfying Löb's axiom
`□(□a ⇨ a) ≤ □a` — and from those three axioms *alone* derived the full structural
skeleton of GL: transitivity `4` (`box_transitive`) is *derivable* from Löb, the equality
form `□(□a ⇨ a) = □a` (`loeb_eq`), Löb's rule `□a ≤ a ⇒ a = ⊤` (`loeb_rule`), the
"only self-provable element is ⊤" corollary, and Gödel's second incompleteness theorem
`consistency_unprovable`. With this in place `LobNatModel.lean` compiles again, so its
computation `□^k⊥ = Iio k` is once more live.

The structural insight that drove the deepening is that **uniqueness of modalised fixed
points is not a fixed-point miracle — it is Löb's *rule* applied to a biimplication.**
After proving the single congruence lemma `□(a ⇨ b) ≤ □a ⇨ □b`, the biimplication
`a ⇔ b` becomes a box-congruence for any operator in which the variable occurs only under
`□`; at two fixed points this yields `□(a ⇔ b) ≤ (a ⇔ b)`, and Löb's rule forces
`a ⇔ b = ⊤`, i.e. `a = b`. We packaged this as the general theorem
`modalised_fixedPoint_unique`, recovering the classical de Jongh–Sambin uniqueness for the
canonical map `p ↦ □p ⇨ c` (with the *explicit* solution `glFix c = □c ⇨ c` and provability
`□(glFix c) = □c`) and — the cycle's headline result — promoting the previously conjectured
**two-parameter uniqueness** for `p ↦ d ⊓ (□p ⇨ c)` (`glFix_two_param_unique`) from `sorry`
to a complete proof, simply by composing three congruence lemmas.

What *failed* is instructive. A first attempt at two-parameter uniqueness tried to re-run
the one-step "`□a = □c`" computation that works for `glFix_unique`; it broke because the
extra meet `d` perturbs the lower bound `c ≤ a`. The biimplication/Löb-rule engine
sidesteps computing `□a` at all, which is exactly why it generalises. The Critic's
contribution sharpened the boundary: `box_ne_id` shows the provability operator is *never*
the identity in a non-trivial algebra, and `identity_violates_loeb` exhibits the explicit
failure of Löb for the naïve "provable = true" operator on `Set ℕ` at `S = ∅`. Löb's
axiom is precisely what forbids the operator that would make every sentence its own fixed
point.

## Results Summary

- `GLOperator.box_transitive`: proved — transitivity axiom `4` (`□a ≤ □□a`) is derivable from Löb, no separate axiom needed.
- `GLOperator.loeb_eq`: proved — the equality form `□(□a ⇨ a) = □a` of Löb's axiom.
- `GLOperator.loeb_rule`: proved — Löb's rule `□a ≤ a ⇒ a = ⊤`, the engine behind every uniqueness result here.
- `GLOperator.box_fixedPoint_eq_top`: proved — the only self-provable element is `⊤`.
- `GLOperator.consistency_unprovable` / `godel_second`: proved — Gödel's second incompleteness theorem in algebraic form.
- `GLOperator.box_himp_le`: proved — `□` half-distributes over implication; the single congruence seed.
- `GLOperator.glFix_box`: proved — the Gödel fixed point's provability is exactly `□c`.
- `GLOperator.loeb_fixed_point` / `glFix_unique` / `glFix_iff`: proved — existence, uniqueness, and characterisation of the Sambin fixed point of `p ↦ □p ⇨ c`.
- `GLOperator.modalised_fixedPoint_unique`: proved — **general** de Jongh–Sambin uniqueness for any box-congruent operator.
- `glFix_two_param_unique`: proved — uniqueness for `p ↦ d ⊓ (□p ⇨ c)` (the conjecture from the seed direction, now closed).
- `box_ne_id`: proved — the provability operator is never the identity in a non-trivial GL algebra (Critic).
- `identity_violates_loeb`: proved — explicit failure of Löb for the identity operator on `Set ℕ`.
- `godel_sentence_natGL` / `godel_sentence_box_natGL` / `godel_sentence_not_provable_natGL`: proved — the Gödel sentence in the canonical `(ℕ,>)` model is `{0}ᶜ`, provable only at world `{0}`, hence unprovable.

## Research Directions

### Direction 1: Explicit normal form for general modalised fixed points
**Hypothesis**: For every box-congruent operator `f` there is an *explicit* term `e_f`
(built from the parameters of `f` by iterated boxing) with `e_f = f e_f`; i.e.
`modalised_fixedPoint_unique` can be upgraded from "at most one fixed point" to "exactly
this one fixed point". For `p ↦ d ⊓ (□p ⇨ c)` we conjecture `e = d ⊓ (□(d ⊓ ¬□⊥ ...) ⇨ c)`
collapses to a finite box-polynomial in `c, d`.
**Test**: Prove `e = f e` for a candidate `e` in the two-parameter case, then for the
general `n`-ary modalised polynomial; disprove by exhibiting a box-congruent `f` whose
fixed point provably is not a finite box-polynomial.
**Why now**: We already have uniqueness and the one-parameter explicit form `glFix c = □c ⇨ c`;
only *existence-with-formula* in the multi-parameter case is missing.
The key insight is that `glFix_box` (`□(glFix c) = □c`) is what makes the one-parameter
formula self-verifying, so the search is for the analogous "`□` of the candidate computes"
identity in the multi-parameter setting.
**If true**: A complete algebraic Sambin algorithm — symbolic fixed points for all of GL.
**If false**: It pinpoints which modalised operators outrun finite box-polynomials,
sharpening the boundary of effective fixed-point elimination.

### Direction 2: Iterated consistency hierarchy meets fixed points
**Hypothesis**: In `NatGL` the Gödel sentence relativised to the `k`-th consistency,
`glFix (natBox^[k] ⊥)`, equals `(Iio k)ᶜ` with provability `Iio k`, giving a *strictly
increasing* spectrum of fixed points mirroring `consistency_strength_strictMono`.
**Test**: Compute `glFix (Set.Iio k)` in `NatGL` and compare with `natBox_iterate_eq_Iio`;
confirm strict monotonicity of `k ↦ □(glFix (natBox^[k] ⊥))`.
**Why now**: `godel_sentence_natGL` already nailed the `k = 1` slice (`{0}ᶜ`) and
`LobNatModel` supplies `natBox^[k] ⊥ = Iio k` for free.
The key insight is that in the canonical model "fixed point of relativised consistency"
and "frame depth" are the same integer, so the abstract `glFix_box` becomes literal
arithmetic on initial segments.
**If true**: A graded de Jongh–Sambin theorem indexed by consistency strength.
**If false**: A level where the fixed point ceases to be an initial-segment complement
would reveal non-uniformity in the canonical frame.

### Direction 3: Completeness of `BoxCongruent` versus syntactic modalisation
**Hypothesis**: An operator `f : H → H` is `BoxCongruent` in *every* GL algebra `H`
simultaneously **iff** it is definable by a formula in which the variable occurs only
within the scope of `□`. (Semantic congruence = syntactic modalisation.)
**Test**: Prove the easy direction (syntactic ⇒ congruent) by induction on formula
structure using `box_biimp_le`, `biimp_himp_const`, `biimp_inf_const`; attempt the
converse, or disprove it with a uniformly-congruent operator that is not modalisable.
**Why now**: This cycle isolated `BoxCongruent` as the exact hypothesis powering
uniqueness, and proved the three structural congruence closure lemmas it needs.
The key insight is that uniqueness never used the *syntax* of `f`, only the single
inequality `□(a ⇔ b) ≤ f a ⇔ f b`, so that inequality is the true semantic content of
"modalised".
**If true**: A clean semantic characterisation of the de Jongh–Sambin side condition.
**If false**: A purely semantic, non-syntactic source of fixed-point uniqueness — a new
class of operators GL did not anticipate.

### Direction 4: Polymodal / graded boxes and simultaneous fixed points
**Hypothesis**: For two commuting Löb operators `□₁, □₂` on the same Heyting algebra
(GLB-style), simultaneous fixed points of jointly-modalised systems
`p = f(□₁p, □₂p), q = g(□₁q, □₂q)` are unique, via a two-variable biimplication argument.
**Test**: Define a `BiGLOperator` class, port `box_himp_le`/`box_biimp_le` to each box,
and prove joint uniqueness; disprove by a frame where `□₁, □₂` interact to create
multiple fixed points.
**Why now**: `modalised_fixedPoint_unique` is stated for an abstract `f : H → H`, so it
already accommodates `f` depending on several boxes once each box contributes its own
congruence lemma; only the bookkeeping is new.
The key insight is that Löb's *rule* (not the axiom) is the sole ingredient of uniqueness,
and the rule survives verbatim for any operator satisfying Löb.
**If true**: The fixed-point core scales to GLP / Japaridze's polymodal logic.
**If false**: It locates exactly where box-interaction breaks the single-box uniqueness
engine.

### Direction 5: Quantitative Gödel II via fixed-point provability degree
**Hypothesis**: In any GL algebra the map `c ↦ □(glFix c) = □c` is a *retraction onto the
boxed elements*, and its fixed points (`□c = c`) are exactly `{⊤}`; consequently the
"distance from provability" `c ⇨ □(glFix c)` measures consistency strength and is strictly
informative in the `NatGL` model.
**Test**: Prove `□ ∘ glFix = □` as functions, characterise its image as `Set.range □`,
and in `NatGL` compute the chain `c ⇨ □(glFix c)` for `c = Iio k`.
**Why now**: `glFix_box` already gives `□(glFix c) = □c` pointwise and
`box_fixedPoint_eq_top` already pins the box-fixed points to `⊤`.
The key insight is that `glFix` linearises the otherwise non-linear Gödel diagonal into a
single retraction, turning "is this consistency statement provable?" into membership in
`range □`.
**If true**: A quantitative refinement of Gödel II as a retraction-theoretic invariant.
**If false**: A failure of the retraction identity would expose box operators that are
"provability-like" yet not idempotent on Gödel fixed points.
