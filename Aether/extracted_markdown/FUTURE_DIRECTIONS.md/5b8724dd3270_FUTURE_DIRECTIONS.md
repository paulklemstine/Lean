# FUTURE_DIRECTIONS — Proof-Theoretic Bridge: Ordinal Analysis Across Systems

## Synthesis

This cycle attacked the ordinal-analysis target "construct an order-preserving
map relating the proof-theoretic ordinal of `PA` to the collapsing-function
world used for `KP`, and prove `ε₀ < ψ(Ω^ω)`." Rather than reproving textbook
facts, we anchored the work on a concrete *open* item: Mathlib's
`SetTheory/Ordinal/Veblen.lean` explicitly lists "prove that `ε₀` and `Γ₀` are
countable" as a TODO. We closed the `ε₀` half: `epsilonZero_lt_omega1 : ε₀ < ω₁`.
The proof is the genuine structural insight of the cycle — it factors through two
independent bridges that live in *different* Mathlib domains: (a) the
order-theoretic identity `ε₀ = ⨆ₙ tower n` realizing `ε₀` as the supremum of the
finite `ω`-towers (`epsilonZero_eq_iSup_tower`), and (b) the cardinal-arithmetic
fact that `ω₁` is *principal under ordinal exponentiation*
(`principal_opow_omega`), so each finite tower stays countable. A countable
supremum of countable ordinals is countable (`iSup_sequence_lt_omega_one`), and
the result drops out.

We then packaged the epsilon enumeration as an order-collapsing hierarchy
`psiE = ε_`, a faithful and fully rigorous *simplification* of an ordinal
collapsing function: it is normal (order preserving, `psiE_strictMono`), every
value is an `ε`-number / fixed point of `ω^·` (`psiE_isEpsilon`), and
`psiE 0 = ε₀` is exactly the `PA` ordinal. Over the uncountable base `Ω = ω₁`
(itself an `ε`-number, `omega1_isEpsilon`) we proved the headline collapse
inequality `ε₀ < psiE (Ω^ω)` (`epsilonZero_lt_psiE_Omega_opow_omega0`), the
formal analogue of `ε₀ < ψ(Ω^ω)`, and the `PA`→`KP` bridge
`ε₀ < bachmannHoward` placing `PA`'s ordinal strictly below a model of the
Bachmann–Howard ordinal.

The most informative *failure* was the Critic's: we conjectured that one could
engineer a strictly monotone collapsing function (`StrictMonoOn f (Iic ω₁)` with
`f 0 = ε₀` and `f ω₁ < ω₁`) and discovered it is **provably impossible**
(`no_monotone_collapse`). A strictly monotone map satisfies `a ≤ f a` even when
restricted to the well-order `Iic ω₁`, forcing `ω₁ ≤ f ω₁`. This is the precise,
formal reason genuine ordinal collapsing functions (Buchholz, Madore) *must* be
non-monotone: monotonicity is itself the obstruction to collapsing. That
boundary result is the seed for the directions below — the real prize is a
recursively-defined, non-monotone, countability-preserving `ψ`.

## Results Summary

- `tower_succ`: proved — the finite `ω`-tower satisfies `tower (n+1) = ω ^ tower n`.
- `tower_lt_epsilonZero`: proved — every finite `ω`-tower lies below `ε₀`.
- `epsilonZero_eq_iSup_tower`: proved — `ε₀` is exactly the supremum of the finite `ω`-towers (Cantor picture).
- `tower_strictMono`: proved — the `ω`-tower is a strictly increasing copy of `ℕ` inside `ε₀` (strictness uses the least-fixed-point property of `ε₀`).
- `tower_lt_omega1`: proved — each finite `ω`-tower is countable, via `ω₁` being exponentiation-principal.
- `epsilonZero_lt_omega1`: proved — **`ε₀` is countable (`ε₀ < ω₁`), closing a stated Mathlib TODO.**
- `epsilonZero_card_lt_aleph_one`: proved — cardinal form `ε₀.card < ℵ₁`.
- `omega1_isEpsilon`: proved — the uncountable base `ω₁` is an `ε`-number (`ω ^ ω₁ = ω₁`), a cardinal↔fixed-point bridge.
- `psiE_strictMono`: proved — the collapsing hierarchy `psiE` is order preserving.
- `psiE_isEpsilon`: proved — every `psiE` value is a fixed point of `ω^·`.
- `epsilonZero_lt_Omega`: proved — `PA`'s ordinal `ε₀` lies strictly below the uncountable collapse base `Ω = ω₁`.
- `epsilonZero_lt_psiE_Omega_opow_omega0`: proved — **the collapse inequality `ε₀ < ψ(Ω^ω)`** (formal analogue, `ψ = psiE`, `Ω = ω₁`).
- `epsilonZero_lt_bachmannHoward`: proved — **`PA`→`KP` bridge:** `ε₀` is strictly below a Bachmann–Howard model.
- `no_monotone_collapse`: proved (disproof) — **no order-preserving `f` can collapse `ω₁` below itself**, i.e. a genuine OCF must be non-monotone.

## Research Directions

### Direction 1: A non-monotone, countability-preserving collapsing function
**Hypothesis**: There is an explicitly definable `ψ : Ordinal → Ordinal` with
`ψ 0 = ε₀`, `ψ` strictly increasing on a *cofinal* subset of its domain, and
`ψ α < ω₁` for **all** `α` (including `α ≥ ω₁`) below `ε_{Ω+1}` — i.e. a true
ordinal collapsing function whose outputs are always countable.
**Test**: Define Buchholz's `C(α)`/`ψ(α)` closure recursively (closure of
`{0, 1, ω, Ω}` under `+`, `ξ ↦ ω^ξ`, and `ψ ↾ α`) and prove `ψ α < ω₁` by an
inductive cardinality bound: each `C(α)` is countable, so its least missing
countable ordinal exists and is `< ω₁`.
**Why now**: `no_monotone_collapse` pins down *exactly* the property a monotone
function cannot have, and `omega1_isEpsilon` + `principal_opow_omega` already give
the countable-closure lemmas needed for the cardinality bound.
**If true**: Mathlib gains its first genuine ordinal collapsing function and a
path to the Bachmann–Howard ordinal as an honest countable ordinal.
**If false**: The obstruction is deeper than monotonicity and would reveal a
new structural barrier to formalizing impredicative ordinal notations.

### Direction 2: Finish the Mathlib TODO — `Γ₀` is countable
**Hypothesis**: `Γ₀ < ω₁` (the Feferman–Schütte ordinal is countable), the
second half of the Mathlib TODO we partially closed.
**Test**: Mirror `epsilonZero_lt_omega1`: show `Γ₀ = ⨆ₙ (veblen · 0)^[n] (ε_ 0)`
and that `ω₁` is closed under `α ↦ veblen α 0` (a Veblen-principality lemma), then
apply `iSup_sequence_lt_omega_one`.
**Why now**: `gamma`/`Γ₀` already exist in Mathlib as `deriv (veblen · 0)`, and
the `nfp = ⨆ iterate` machinery used in `epsilonZero_eq_iSup_tower` transfers
verbatim; only a Veblen-closure analogue of `principal_opow_omega` is missing.
**If true**: The Mathlib TODO is fully closed and the countability technique
generalizes to all `deriv`-defined ordinals below `ω₁`.
**If false**: Would expose a failure of `ω₁`-closure for the Veblen operation,
which would be surprising and worth understanding.

### Direction 3: Identify `ω₁` inside the `ε`-hierarchy
**Hypothesis**: There is a (necessarily uncountable) index `β` with `ε_ β = ω₁`,
and `β` is the least fixed point of `ε_` above `0` of uncountable cofinality.
**Test**: From `omega1_isEpsilon` (so `ω₁ ∈ range (ω^·)` fixed points) and the
fact that `ε_` enumerates *all* such fixed points (`epsilon`/`veblen` surjectivity
onto fixed points), extract `β = invVeblen₂ ω₁` and prove `ε_ β = ω₁`.
**Why now**: We already proved `ω ^ ω₁ = ω₁`; Mathlib's `invVeblen₂_epsilon` /
`mem_range_veblen` give the inverse machinery to name the index.
**If true**: Gives a clean dictionary between cardinal indices and `ε`-indices,
sharpening the `PA`/`KP` bridge by locating `Ω` intrinsically.
**If false**: Would mean `ω₁` is a fixed point not enumerated by `ε_`,
contradicting normality — so failure would indicate an API gap to fix.

### Direction 4: Quantitative collapse — `ε₀` is the *first* uncountable-free level
**Hypothesis**: `ε₀ = sup { o | o is reachable from below by `+`, `·`, and `ω^·`
in finitely many steps from `0` }`, and this sup is strictly the least ordinal
closed under `ω^·`; moreover for every `o < ε₀`, `o.card ≤ ℵ₀` is witnessed by an
explicit countable Cantor-normal-form code.
**Test**: Build a `Type`-level inductive of Cantor normal forms `< ε₀`, a decoding
to `Ordinal`, and prove the decoding is an order isomorphism onto `Iio ε₀`; derive
countability constructively (without `iSup_sequence_lt_omega_one`).
**Why now**: Mathlib has `Ordinal.Notation` (CNF `< ε₀`) and a fast-growing
hierarchy keyed to it; connecting it to our `tower`/`ε₀` results is now a finite
gap.
**If true**: Yields a *constructive* countability proof and a computable model of
`PA`'s ordinal, enabling effective comparisons in the catalog's `Computation` and
`Logic` domains.
**If false**: Would indicate the existing `Notation` API does not faithfully cover
`Iio ε₀`, a concrete fixable defect.

### Direction 5: Non-monotonicity is forced for ALL collapse targets
**Hypothesis**: Generalize `no_monotone_collapse`: for any regular uncountable
`κ` and any `f` with `StrictMonoOn f (Iic κ.ord)`, one has `κ.ord ≤ f κ.ord`;
hence no order-preserving function can collapse any uncountable initial ordinal
below itself.
**Test**: Re-run the `le_of_forall_lt` induction with `ω₁` replaced by an
arbitrary `o : Ordinal` (the proof never used uncountability!), obtaining the
fully general `StrictMonoOn f (Iic o) → o ≤ f o`, then specialize to `κ.ord`.
**Why now**: Inspection shows `no_monotone_collapse`'s `key` lemma is universe-
and `ω₁`-agnostic; the generalization is essentially free and clarifies the
theorem's true content.
**If true**: A clean, reusable Mathlib lemma `StrictMonoOn.le_apply` for ordinal
initial segments, and a domain-independent statement of "collapsing ⇒ non-
monotone."
**If false**: Impossible given the proof — so the value here is the generalized
lemma itself, which should be contributed upstream.
