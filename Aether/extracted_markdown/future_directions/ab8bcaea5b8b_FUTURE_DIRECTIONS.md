# Future Directions — The Oracle's Burden, after the Model-Theoretic Audit

## Synthesis

The catalog file `Computation/OracleBurden.lean` builds an elegant *conditional* theory of
the oracle jump hierarchy `PA < PA^H < PA^{H^H} < …`: strict hierarchy, consistency
propagation, the soundness barrier, and an order-embedding into a Turing degree chain. Every
one of those theorems, however, is quantified over a hypothesised structure — an
`OracleJumpR`, a `ConsistencyOracle`, a `SoundnessWitness`, or an abstract `power` function.
The natural research question is therefore not "are the theorems true?" (they are) but "are
they about anything?" — i.e. are the hypotheses ever simultaneously satisfiable?

`Computation/OracleBurdenModels.lean` answers this with a model-theoretic audit. Two of the
catalog's central hypotheses turn out to be **over-constrained to the point of vacuity**:

* `oracleJumpR_isEmpty` proves `IsEmpty OracleJumpR`. A single endofunction on the space of
  *all* reflective theories cannot be simultaneously truth-preserving and strictly
  provability-increasing — it collapses against the complete sound theory.
* `no_global_strict_power` proves no `ℕ`-valued function on `Set ℕ` strictly increases along
  every `⊂`, because the tail filter `{s | k ≤ s}` is an infinite `⊂`-descending chain.

The repair is to stop asking for a global *operator* and instead axiomatise a `ℕ`-indexed
*chain* — a `ReflectiveTower`. This is inhabited, and the explicit `standardTower` (level `n`
proves exactly `{0,…,n}`) realizes the *entire* architecture with zero free parameters:
`standardModel_realizes_burden` exhibits a concrete consistency oracle (`Con(T_n) = n+1`) and
soundness witness (`Sound(T_n) = n+2`) that produce the consistency gap and the one-level-up
soundness barrier, and `standardTower_isomorphic_to_degree_chain` matches the order type to a
Turing degree chain.

## Results Summary

| Result | Statement | Status |
|--------|-----------|--------|
| `oracleJumpR_isEmpty` | the universal oracle jump is uninhabited | proved |
| `no_global_strict_power` | the global order-embedding hypothesis is unsatisfiable | proved |
| `ReflectiveTower` + `standardTower` | repaired, inhabited framework | proved |
| `standardModel_realizes_burden` | concrete model realizes consistency gap + soundness barrier | proved |
| `ReflectiveTower.provable_strictMono` / `..._degree_chain` | strict hierarchy of order type `ℕ` | proved |

## Bold, Falsifiable Directions

### 1. A weakest-precondition repair: the largest inhabited fragment of `OracleJumpR`

We showed the *complete* sound theory kills any universal jump. Conjecture: `OracleJumpR`
restricted to the subcategory of **incomplete** sound theories (`true_sentences ⊄ provable`)
*is* inhabited, and the "add the least true-but-unprovable sentence" operator witnesses it.
More sharply: incompleteness of every input is not only sufficient but *necessary* — the
domain of any inhabited universal jump is contained in the incomplete theories.
**The key insight is** that the obstruction in `oracleJumpR_isEmpty` is exactly the empty
incompleteness gap of the complete theory, so quantifying the jump only over theories with
nonempty `incompletenessGap` removes the single counterexample.
**Why now?** `ReflectiveTheory.incompletenessGap` and `incompleteness_gap_nonempty` already
exist in the catalog; the restricted-domain jump can be defined and proved strict directly
against them, making this an immediately attemptable formalization rather than a research
program.

### 2. Transfinite towers and the ordinal order type of the oracle hierarchy

`ReflectiveTower` is `ℕ`-indexed; the genuine Turing jump hierarchy continues into the
transfinite (`0', 0'', …, 0^{(ω)}, …`). Conjecture: replacing `level : ℕ → ReflectiveTheory`
with `level : Ordinal → ReflectiveTheory` plus a *limit-union* axiom yields a structure whose
`provable`-map is a strict-monotone embedding of `(Ordinal, <)` into `(Set ℕ, ⊂)` **only up to
the first non-recursive ordinal** — beyond that, strictness must fail because `Set ℕ` has no
strictly increasing `ω₁`-chain that stays inside the arithmetic sets.
**The key insight is** that `no_global_strict_power`'s descending-chain obstruction has an
ascending dual: cardinality forces every strictly `⊂`-increasing chain of subsets of `ℕ` to
have countable order type, capping the tower length intrinsically.
**Why now?** The finite-level limit machinery (`limitProvable`, `level_subset_limit`,
`limit_escape`) is already proved and generalizes verbatim to successor steps; only the limit
case needs new union axioms, isolating exactly one new lemma to attack.

### 3. Quantitative soundness gap: the barrier widens with the level

In `standardTower`, `Con(T_n) = n+1` is provable one level up but `Sound(T_n) = n+2` is not.
Conjecture: there is a model in which the *minimum level at which `Sound(T_n)` first becomes
provable* grows without bound in `n` (e.g. `Sound(T_n)` first appears at level `2n`), formal-
izing the idea that soundness is not merely one jump harder than consistency but
*unboundedly* harder.
**The key insight is** that the soundness witness's escape clause (`soundness_escapes`) only
constrains level `n+1`; by choosing `snd n` to land in `{s | n < s ≤ f(n)}` for a fast-growing
`f`, the first provable level becomes `f(n)`, turning a qualitative barrier into a measurable
gap function.
**Why now?** `TowerSoundnessWitness` is parameterised exactly by the encoding `snd`, so this
is a drop-in alternative witness over the existing `standardTower`; the proof reduces to
arithmetic over `{s ≤ n}` that `omega` already discharges.

### 4. Categorical universality: `ReflectiveTower` as a colimit, `standardTower` as initial

Conjecture: reflective towers under level-wise inclusion form a category with a terminal
truth object, and the `standardTower` is **initial** among towers whose base proves `{0}` and
whose truth set is `univ` — every such tower receives a unique provability-preserving morphism
from it.
**The key insight is** that `{s ≤ n}` is the *smallest* strictly-growing chain on `ℕ`
starting from a singleton, so any other tower's levels contain the standard ones, giving the
canonical comparison map for free.
**Why now?** `ReflectiveTower.mono` and `provable_strictMono` already package the order data a
morphism must preserve; defining the morphism structure and proving initiality is a finite
diagram chase rather than new mathematics.

### 5. Genuine computability bridge: instantiate the tower from the arithmetical hierarchy

The catalog's `TuringDegreeChain` is abstract. Conjecture: Mathlib's computability layer
(`Nat.Partrec`, `RePred`, many-one reducibility) supports building a *bona fide*
`ReflectiveTower` whose level-`n` provable set is a `Σ⁰_{n+1}`-complete set, so that the
order embedding of `standardTower` becomes an honest reflection of the arithmetical hierarchy
and the jumps are literal halting-problem relativizations.
**The key insight is** that strict containment `Σ⁰_n ⊊ Σ⁰_{n+1}` (a theorem morally available
from the hierarchy theorem) is exactly the `strict` axiom of `ReflectiveTower`, so the entire
abstract apparatus transports onto real Turing degrees once one strictness lemma is supplied.
**Why now?** This is the cross-domain bridge the catalog explicitly wants — it connects the
`Logic` provability files with the `Computation` oracle files — and the abstract target
(`ReflectiveTower`) is now proven inhabited and well-behaved, so only the computability-side
strictness input remains to be formalized.
