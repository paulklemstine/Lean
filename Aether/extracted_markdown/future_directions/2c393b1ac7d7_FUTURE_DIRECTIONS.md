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
strictly order-preserving) function (`isNormal_psiOmega`, `psiOmega_strictMono`).
The two endpoints were characterised dually as suprema of canonical towers:
`ε₀` is the supremum of the ω-towers `ω, ω^ω, …`
(`epsilon_zero_eq_iSup_omegaTower`), while `Γ₀` is the supremum of the
collapse-towers `veblen 0 0, veblen (veblen 0 0) 0, …`
(`gamma_zero_eq_iSup_collapseTower`). This dual presentation is the structural
insight of the cycle: PA and predicative-KP differ only in *which* normal operator
generates the tower (`ω^·` versus `veblen · 0`), and the collapsing function is
exactly the bridge that interpolates between those two operators.

The headline inequality `ε₀ < ψ(Ω^ω)` (`epsilon_zero_lt_psiOmega_omega`) becomes a
one-line consequence of strict monotonicity once the collapse is anchored at
`ψ(Ω¹) = ε₀` (`psiOmega_one_eq_epsilon_zero`, which holds *definitionally* because
`epsilon = veblen 1`), and it extends to the strict chain `ε₀ < ψ(Ω^ω) < Γ₀`
(`collapse_chain`). The cross-system bridge is made concrete with `paToKp`, an
explicit order embedding of the PA segment `{a // a < ε₀}` into the
KP/predicative segment `{a // a < Γ₀}` (with `paToKp_coe : (paToKp x).1 = x.1`).
This sharpens the catalog file `Catalog/Logic/StronglyCriticalOrdinals.lean`, whose
flagship `Predicative.veblen_lt_gamma_zero` (predicative closure of `Γ₀`) is reused
here to place the collapse value strictly inside `Γ₀` (`psiOmega_omega_lt_gamma_zero`)
and whose `predicative_tower` chain `ω < ε₀ < Γ₀` we upgrade to a chain that runs
*through* the named collapse value.

What was redirected: the originally intended impredicative witness used the
uncountable `ω₁` with `Ψ = gamma`, which requires "gamma sends countable inputs to
countable ordinals" — a countability fact not readily available in Mathlib. We
replaced it with a fully constructive witness: take `Ω` to be the first
`gamma`-fixed point above `Γ₀` (via `nfp gamma (succ Γ₀)`). Closure of a collapse
target under the collapsing function (regularity) is *exactly* the fixed-point
property, so a fixed point above `Γ₀` already realises the impredicative jump
`Γ₀ < Ψ Ω` abstractly and without any cardinality input
(`impredicative_jump_beyond_gamma_zero`). This trade — replacing a cardinality
hypothesis by a fixed-point construction — is the reusable lesson for the next cycle.

## Results Summary

- `isNormal_psiOmega` — the collapsing function `ψ(Ω^·)` is normal.
- `psiOmega_strictMono` — the collapsing function is strictly order-preserving.
- `psiOmega_one_eq_epsilon_zero` — the collapse anchors at PA: `ψ(Ω¹) = ε₀`.
- `omegaTower_lt_epsilon_zero` — each finite ω-tower lies strictly below `ε₀`.
- `epsilon_zero_eq_iSup_omegaTower` — `ε₀` is the supremum of the ω-towers (Gentzen's ordinal, constructively).
- `gamma_zero_eq_iSup_collapseTower` — `Γ₀` is the supremum of the collapse-towers.
- `epsilon_zero_lt_psiOmega_omega` — **the central inequality `ε₀ < ψ(Ω^ω)`**.
- `psiOmega_omega_lt_gamma_zero` — `ψ(Ω^ω) < Γ₀`.
- `collapse_chain` — the strict hierarchy `ε₀ < ψ(Ω^ω) < Γ₀`.
- `paToKp` / `paToKp_coe` — explicit order embedding `{a // a < ε₀} ↪o {a // a < Γ₀}`.
- `epsilon_zero_lt_gamma_zero` — `ε₀ < Γ₀` (PA ordinal below predicative-KP ordinal).
- `impredicative_jump_beyond_gamma_zero` — a normal `Ψ` and a target `Ω` closed under `Ψ` with `Γ₀ < Ψ Ω`, the abstract impredicative jump.

## Research Directions

### Direction 1: Order-isomorphism, not just embedding
**Hypothesis**: `paToKp` extends to an order embedding whose image is exactly the
initial segment `{a // a < ε₀}` of `{a // a < Γ₀}`, and more ambitiously the PA
segment is the largest initial segment of the KP segment closed under `a ↦ ω^a`.
**Test**: We already have `paToKp_coe : (paToKp x).1 = x.1`; prove
`range paToKp = {y | y.1 < ε₀}` and assemble an `OrderIso` onto that subtype.
The key insight is that the bridge is the *inclusion of initial segments*, so its
range is forced to be the whole source segment viewed inside the target.
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
**Test**: State `Monotone (fun F : {F : Ordinal → Ordinal // IsNormal F} ↦ nfp F.1 0)`
and prove it from monotonicity of `nfp`; instantiate at `F = ω^·` (giving `ε₀`) and
`F = veblen · 0` (giving `Γ₀`) to recover this cycle's two `iSup` characterisations
as corollaries. The key insight is that both `epsilon_zero_eq_iSup_omegaTower` and
`gamma_zero_eq_iSup_collapseTower` are the *same* lemma `nfp F 0 = ⨆ n, F^[n] 0`
specialised to two operators.
**Why now**: This cycle proved both endpoints are `nfp`/`iSup` of iterates with the
*same* shape, exposing the common pattern.
**If true**: A single lemma subsumes both characterisations and gives a uniform
"tower ⇒ ordinal" recipe.
**If false**: Proof-theoretic ordinals depend on more than the closure operator
(e.g. on the limit-stage behaviour), refining where the analogy breaks.

### Direction 3: Iterating the collapse toward the Bachmann–Howard ordinal
**Hypothesis**: Iterating `impredicative_jump_beyond_gamma_zero` along ℕ — define
`Om 0 = nfp gamma (succ Γ₀)` and `Om (n+1) = nfp gamma (succ (Om n))` — produces a
strictly increasing ω-sequence of `gamma`-fixed points, each strictly above the
previous, whose supremum is itself a `gamma`-fixed point modelling the first step of
the impredicative hierarchy. The key insight is that each `nfp gamma (succ x)` is the
*least* fixed point strictly above `x`, so the sequence climbs the fixed-point set of
`gamma` one rung at a time.
**Test**: Define the sequence by recursion over ℕ, prove strict monotonicity from
`le_nfp`, `lt_succ` and `nfp_fp` (all already used in this file), and compute its
supremum via `iSup_iterate_eq_nfp`.
**Why now**: We have the single-step jump fully constructive; iteration only needs
recursion plus the fixed-point lemmas already in use.
**If true**: A constructive, cardinality-free path toward Bachmann–Howard-style
ordinals inside Mathlib, sidestepping uncountable `Ω`.
**If false**: The fixed-point surrogate for `Ω` saturates too early, showing that a
genuine uncountable (regular) `Ω` is unavoidable past a definite level.

### Direction 4: Countability of `gamma` on countable inputs
**Hypothesis**: For countable `a`, `Γ_ a` is countable; hence with `Ω = ω₁` the
"honest" witness `Ψ = gamma` satisfies `∀ a < ω₁, gamma a < ω₁`, recovering a true
uncountable collapsing function. The key insight is that `ω₁` is regular and a
`veblen · 0`-fixed point is assembled from countably many countable ordinals, so it
stays below `ω₁`.
**Test**: Prove `a < ω₁ → Γ_ a < ω₁` by transfinite induction, using regularity of
`ω₁` together with the `nfp`/`iSup` presentation `gamma_zero_eq_iSup_collapseTower`
to bound the iterates.
**Why now**: This is the exact lemma the constructive witness routed around this
cycle; isolating it makes the uncountable model available to all later cycles.
**If true**: The uncountable collapsing function `ψ` with `Ω = ω₁` becomes
formalizable, unlocking `ψ(ε_{Ω+1}) =` Bachmann–Howard.
**If false** (it is true mathematically, so failure would be a Mathlib-API gap):
it pinpoints the missing closure/countability infrastructure to contribute upstream.

### Direction 5: A reverse bridge and strictness of strength
**Hypothesis**: There is *no* order embedding `{a // a < Γ₀} ↪o {a // a < ε₀}`;
equivalently the bridge `paToKp` is strictly one-directional, certifying that KP is
proof-theoretically strictly stronger than PA. The key insight is that an order
embedding of one ordinal segment into a strictly shorter one would force the longer
ordinal to inject order-preservingly into the smaller, contradicting that an ordinal
cannot embed into a smaller ordinal.
**Test**: Derive a contradiction from a hypothetical embedding together with
`epsilon_zero_lt_gamma_zero` and the standard well-order fact (e.g. via
`InitialSeg`/`PrincipalSeg` API or `Ordinal.lt_wf`).
**Why now**: We have `epsilon_zero_lt_gamma_zero` and a worked embedding in one
direction; the obstruction in the other direction is a standard well-order fact.
**If true**: Upgrades the qualitative chain into a formal *strict* strength
separation between the two systems.
**If false**: Would contradict basic ordinal theory — so a failed attempt is a
direct test of the embedding/initial-segment lemmas being used.
