# FUTURE DIRECTIONS — Proof-Theoretic Bridge: Ordinal Analysis Across Systems

File produced this cycle: `Catalog/Logic/OrdinalAnalysisBridge.lean`
(module `Logic.OrdinalAnalysisBridge`). All main results compile with `sorry = 0`
and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Synthesis

This cycle built a concrete, fully verified skeleton of *ordinal analysis* — the
discipline that attaches a proof-theoretic ordinal to a formal system — on top of
Mathlib's Veblen hierarchy (`veblen`, `epsilon = veblen 1`, `gamma`). The guiding
picture is a ladder of three named ordinals: the proof-theoretic ordinal of Peano
Arithmetic `ε₀`, an intermediate collapse value `ψ(Ω^ω)`, and the Feferman–Schütte
ordinal `Γ₀` (the predicative analogue of the proof-theoretic ordinal of
Kripke–Platek set theory `KP`). We modelled the *ordinal collapsing function* as
`psiOmega a := veblen a 0`, read as `ψ(Ω^a)`, and proved it is a normal (hence
strictly order-preserving) function. The two endpoints were characterised dually
as suprema of canonical towers: `ε₀` is the supremum of the ω-towers
`ω, ω^ω, …`, while `Γ₀` is the supremum of the collapse-towers
`veblen 0 0, veblen (veblen 0 0) 0, …`. This dual presentation is the structural
insight of the cycle: PA and predicative-KP differ only in *which* normal operator
generates the tower (`ω^·` versus `veblen · 0`), and the collapsing function is
exactly the bridge that interpolates between those two operators.

The headline inequality `ε₀ < ψ(Ω^ω)` then becomes a one-line consequence of
strict monotonicity once the collapse is anchored at `ψ(Ω¹) = ε₀`, and it extends
to the strict chain `ε₀ < ψ(Ω^ω) < Γ₀`. We made the cross-system bridge concrete
with `paToKp`, an explicit order embedding of the PA segment `{a // a < ε₀}` into
the KP/predicative segment `{a // a < Γ₀}` — this sharpens the catalog file
`Catalog/Pythagorean/ProofTheoreticOrdinalsLattice.lean`, which proved its abstract
`pto` map monotone but *not* an order embedding; between two *named* ordinals a
genuine embedding does exist.

What failed / was redirected: the originally intended impredicative witness used
the uncountable `ω₁` with `Ψ = gamma`, which requires "gamma sends countable
inputs to countable ordinals" — a countability fact not readily available in
Mathlib. The Critic replaced it with a fully constructive witness: take `Ω` to be
the first `gamma`-fixed point above `Γ₀` (via `nfp gamma (succ Γ₀)`). Closure of a
collapse target under the collapsing function (regularity) is *exactly* the
fixed-point property, so a fixed point above `Γ₀` already realises the
impredicative jump `Γ₀ < Ψ Ω` abstractly and without any cardinality input. This
trade — replacing a cardinality hypothesis by a fixed-point construction — is the
reusable lesson for the next cycle.

## Results Summary

- `omegaTower_lt_epsilon_zero`: proved — each finite ω-tower lies strictly below `ε₀`.
- `epsilon_zero_eq_iSup_omegaTower`: proved — PA's ordinal `ε₀` is the supremum of the ω-towers (Gentzen's ordinal, constructively).
- `isNormal_psiOmega`: proved — the collapsing function `ψ(Ω^·)` is a normal function.
- `psiOmega_strictMono`: proved — the collapsing function is order-preserving.
- `psiOmega_one_eq_epsilon_zero`: proved — the collapse anchors at PA: `ψ(Ω¹) = ε₀`.
- `epsilon_zero_lt_psiOmega_omega`: proved — **the central inequality `ε₀ < ψ(Ω^ω)`**.
- `gamma_zero_eq_iSup_collapseTower`: proved — predicative-KP's ordinal `Γ₀` is the supremum of the collapse-towers.
- `psiOmega_omega_lt_gamma_zero`: proved — `ψ(Ω^ω) < Γ₀`.
- `collapse_chain`: proved — the strict hierarchy `ε₀ < ψ(Ω^ω) < Γ₀`.
- `paToKp` / `paToKp_coe`: proved — explicit order embedding `{a // a < ε₀} ↪o {a // a < Γ₀}`, the order-preserving bridge across systems.
- `epsilon_zero_lt_gamma_zero`: proved — `ε₀ < Γ₀` (PA ordinal below predicative-KP ordinal).
- `impredicative_jump_beyond_gamma_zero`: proved — a normal `Ψ` and a target `Ω` closed under `Ψ` with `Γ₀ < Ψ Ω`, the abstract impredicative jump.

## Research Directions

### Direction 1: Order-isomorphism, not just embedding
**Hypothesis**: `paToKp` extends to an order embedding whose image is exactly the
initial segment `{a // a < ε₀}` of `{a // a < Γ₀}`, and more ambitiously the PA
segment is the largest initial segment of the KP segment closed under `a ↦ ω^a`.
**Test**: Prove `(paToKp x).1 = x.1` (already have it) and then that
`range paToKp = {y | y.1 < ε₀}`; attempt `OrderIso` onto that subtype.
**Why now**: We already have the concrete embedding and `paToKp_coe`; only the
range/closure characterisation is missing.
**If true**: It pins down the bridge as canonical (inclusion of initial segments),
turning the qualitative "PA ⊂ KP" into a precise structural statement.
**If false**: The embedding is non-canonical, meaning proof-theoretic strength is
not captured by initial-segment inclusion alone — a signal to track *which* ordinal
notations, not just ordinals, are transported.

### Direction 2: The collapse-tower / ω-tower analogy is a functor
**Hypothesis**: For every normal operator `F`, `nfp F 0` is the proof-theoretic
ordinal of a system whose induction principle is "`F`-recursion", and the map
`F ↦ nfp F 0` is monotone in the pointwise order on normal operators.
**Test**: State `Monotone (fun F : {F // IsNormal F} ↦ nfp F.1 0)` and prove it
from `nfp_monotone`; instantiate at `F = ω^·` (giving `ε₀`) and `F = veblen · 0`
(giving `Γ₀`) to recover this cycle's two characterisations as corollaries.
**Why now**: This cycle proved both endpoints are `nfp`/`iSup` of iterates with the
*same* shape, exposing the common pattern.
**If true**: A single lemma subsumes `epsilon_zero_eq_iSup_omegaTower` and
`gamma_zero_eq_iSup_collapseTower` and gives a uniform "tower ⇒ ordinal" recipe.
**If false**: Proof-theoretic ordinals depend on more than the closure operator
(e.g. on the limit-stage behaviour), refining where the analogy breaks.

### Direction 3: Iterating the collapse to reach the Bachmann–Howard ordinal
**Hypothesis**: Iterating `impredicative_jump_beyond_gamma_zero` along the ordinals
(define `Ω₀ = nfp gamma (succ Γ₀)`, `Ω_{n+1}` the next fixed point) produces a
strictly increasing ω-sequence whose supremum is a normal-function fixed point
strictly above every `Γ_ n`, modelling the first step of the true impredicative
hierarchy.
**Test**: Define the sequence by recursion, prove strict monotonicity from
`strictMono_gamma` and `nfp_fp`, and compute its supremum via `iSup_iterate_eq_nfp`.
**Why now**: We have the single-step jump fully constructive; iteration only needs
recursion plus the fixed-point lemmas already in use.
**If true**: A constructive, cardinality-free path toward Bachmann–Howard-style
ordinals inside Mathlib, sidestepping uncountable `Ω`.
**If false**: The fixed-point surrogate for `Ω` saturates too early, showing that a
genuine uncountable (regular) `Ω` is unavoidable past a definite level.

### Direction 4: Countability of `gamma` on countable inputs
**Hypothesis**: For countable `a`, `Γ_ a` is countable; hence with `Ω = ω₁` the
original witness `Ψ = gamma` satisfies `∀ a < ω₁, gamma a < ω₁`.
**Test**: Prove `a < ω₁ → Γ_ a < ω₁` by transfinite induction using that `ω₁` is
regular and a fixed point of `veblen · 0` is built from countably many countable
ordinals (so countable).
**Why now**: This is the exact lemma the Critic had to route around this cycle;
isolating it makes the uncountable model available to all later cycles.
**If true**: The "honest" uncountable collapsing function `ψ` with `Ω = ω₁` becomes
formalizable, unlocking `ψ(ε_{Ω+1}) = ` Bachmann–Howard.
**If false** (it is true mathematically, so failure would be a Mathlib-API gap):
it pinpoints the missing closure/countability infrastructure to contribute upstream.

### Direction 5: A reverse bridge and strictness of strength
**Hypothesis**: There is *no* order embedding `{a // a < Γ₀} ↪o {a // a < ε₀}`;
equivalently the bridge is strictly one-directional, certifying that KP is
proof-theoretically strictly stronger than PA.
**Test**: Prove non-existence from `ε₀ < Γ₀` and the fact that an order embedding
of a well-order into a strictly shorter initial segment of ordinals is impossible
(an ordinal cannot embed into a smaller ordinal).
**Why now**: We have `epsilon_zero_lt_gamma_zero` and a worked embedding in one
direction; the obstruction in the other direction is a standard well-order fact.
**If true**: Upgrades the qualitative chain into a formal *strict* strength
separation between the two systems.
**If false**: Would contradict basic ordinal theory — so a failed attempt is a
direct test of the embedding/initial-segment lemmas being used.
