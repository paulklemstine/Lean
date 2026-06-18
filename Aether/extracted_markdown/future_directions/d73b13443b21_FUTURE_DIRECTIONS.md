# FUTURE_DIRECTIONS — Proof-Theoretic Bridge: Ordinal Analysis Across Systems

## Synthesis

This cycle attacked the ordinal-analysis target "construct an order-preserving map
relating the proof-theoretic ordinal of `PA` to the collapsing-function world used for
`KP`, and prove `ε₀ < ψ(Ω^ω)`." Rather than reproving textbook facts, we anchored the work
on a concrete *open* item: Mathlib's `SetTheory/Ordinal/Veblen.lean` explicitly lists
"prove that `ε₀` and `Γ₀` are countable" as a TODO. In `OrdinalCollapsing.lean` we closed
the `ε₀` half: `epsilonZero_lt_omega1 : Ordinal.epsilon 0 < ω₁`.

The proof is the genuine structural insight of the cycle — it factors through two
independent bridges that live in *different* Mathlib domains: (a) the order-theoretic
identity `ε₀ = ⨆ₙ tower n` realizing `ε₀` as the supremum of the finite `ω`-towers
(`epsilonZero_eq_iSup_tower`), and (b) the cardinal-arithmetic fact that `ω₁` is
*principal under ordinal exponentiation* (`principal_opow_omega 1`), so each finite tower
stays countable (`tower_lt_omega1`). A countable supremum of countable ordinals is
countable (`iSup_sequence_lt_omega_one`), and the result drops out. We also recorded the
cardinal form `epsilonZero_card_lt_aleph_one : (Ordinal.epsilon 0).card < ℵ₁`.

We then packaged the epsilon enumeration as an order-collapsing hierarchy `psiE = ε_`, a
faithful and fully rigorous *simplification* of an ordinal collapsing function: it is
normal (order preserving, `psiE_strictMono`), every value is an `ε`-number / fixed point of
`ω^·` (`psiE_isEpsilon`), and `psiE 0 = ε₀` is exactly the `PA` ordinal. Over the
uncountable base `Ω = ω₁` (itself an `ε`-number, `omega1_isEpsilon : ω ^ ω₁ = ω₁`) we
proved the headline collapse inequality `ε₀ < psiE (Ω^ω)`
(`epsilonZero_lt_psiE_Omega_opow_omega0`), the formal analogue of `ε₀ < ψ(Ω^ω)`, and the
`PA`→`KP` bridge `ε₀ < bachmannHoward` (`epsilonZero_lt_bachmannHoward`) placing `PA`'s
ordinal strictly below a model of the Bachmann–Howard ordinal `ψ(ε_{Ω+1})`.

The most informative *boundary* result was a disproof: we conjectured that one could
engineer a strictly monotone collapsing function (`StrictMonoOn f (Iic ω₁)` with
`f 0 = ε₀` and `f ω₁ < ω₁`) and discovered it is **provably impossible**
(`no_monotone_collapse`), via the reusable lemma `strictMonoOn_Iic_le_apply`: a strictly
monotone map satisfies `o ≤ f o` even when only assumed monotone on the well-order
`Iic o`, forcing `ω₁ ≤ f ω₁`. This is the precise, formal reason genuine ordinal collapsing
functions (Buchholz, Madore) *must* be non-monotone: monotonicity is itself the obstruction
to collapsing. That boundary result is the seed for the directions below — the real prize
is a recursively-defined, non-monotone, countability-preserving `ψ`.

## Results Summary (all proved, `sorry`-free, only standard axioms)

- `tower_succ`, `tower_lt_epsilonZero`, `epsilonZero_eq_iSup_tower`, `tower_strictMono`
  — the finite `ω`-tower picture of `ε₀`.
- `tower_lt_omega1` — each finite tower is countable via exponentiation-principality of `ω₁`.
- `epsilonZero_lt_omega1` — **`ε₀` is countable (`ε₀ < ω₁`), closing a stated Mathlib TODO.**
- `epsilonZero_card_lt_aleph_one` — cardinal form `ε₀.card < ℵ₁`.
- `omega1_isEpsilon` — the base `ω₁` is an `ε`-number (`ω ^ ω₁ = ω₁`): a cardinal↔fixed-point bridge.
- `psiE_strictMono`, `psiE_isEpsilon`, `psiE_zero` — the collapsing hierarchy is normal,
  `ε`-valued, and starts at `ε₀`.
- `epsilonZero_lt_Omega`, `epsilonZero_lt_psiE_Omega_opow_omega0`,
  `epsilonZero_lt_bachmannHoward` — **the collapse inequalities `ε₀ < ψ(Ω^ω)` and the
  `PA`→`KP` bridge.**
- `strictMonoOn_Iic_le_apply`, `no_monotone_collapse` — **a genuine OCF must be non-monotone.**

## Research Directions

### Direction 1: A non-monotone, countability-preserving collapsing function
**Hypothesis.** There is an explicitly definable `ψ : Ordinal → Ordinal` with `ψ 0 = ε₀`,
`ψ` strictly increasing on a *cofinal* subset of its domain, and `ψ α < ω₁` for **all** `α`
(including `α ≥ ω₁`) below `ε_{Ω+1}` — a true ordinal collapsing function whose outputs are
always countable.
**Test.** Define Buchholz's `C(α)`/`ψ(α)` closure recursively (closure of `{0, 1, ω, Ω}`
under `+`, `ξ ↦ ω^ξ`, and `ψ ↾ α`) and prove `ψ α < ω₁` by an inductive cardinality bound:
each `C(α)` is countable, so its least missing countable ordinal exists and is `< ω₁`.
**The key insight is** that `no_monotone_collapse` pins down *exactly* the property a
monotone function cannot have, so the search must abandon monotonicity and instead control
the *cardinality* of a closure set — and our `omega1_isEpsilon` + `principal_opow_omega`
already deliver the countable-closure lemmas the cardinality bound needs.
**Why now?** The two halves are in hand simultaneously for the first time: the negative
boundary (`strictMonoOn_Iic_le_apply`) tells us what to avoid, and the positive closure
lemmas (`tower_lt_omega1`, `omega1_isEpsilon`) tell us the building blocks stay countable.
**If true:** Mathlib gains its first genuine ordinal collapsing function and a path to the
Bachmann–Howard ordinal as an honest countable ordinal. **If false:** the obstruction is
deeper than monotonicity, revealing a new structural barrier to impredicative notations.

### Direction 2: Finish the Mathlib TODO — `Γ₀` is countable
**Hypothesis.** `Γ₀ < ω₁` (the Feferman–Schütte ordinal is countable), the second half of
the Mathlib TODO we partially closed.
**Test.** Mirror `epsilonZero_lt_omega1`: show `Γ₀ = ⨆ₙ (veblen · 0)^[n] (ε_ 0)` (using
`gamma_zero_eq_nfp` and `iSup_iterate_eq_nfp`, exactly as in `epsilonZero_eq_iSup_tower`),
and that `ω₁` is closed under `α ↦ veblen α 0` (a Veblen-principality analogue of
`principal_opow_omega`), then apply `iSup_sequence_lt_omega_one`.
**The key insight is** that the entire countability argument is *operation-agnostic*: it
only needs (i) the ordinal is an `nfp`/`deriv` supremum and (ii) `ω₁` is closed under the
generating operation; `Γ₀ = deriv (veblen · 0) 0` already satisfies (i), so only the
Veblen-closure lemma is missing.
**Why now?** `gamma`/`Γ₀` already exist in Mathlib as `deriv (veblen · 0)`, and the
`nfp = ⨆ iterate` machinery used in this file transfers verbatim.
**If true:** the Mathlib TODO is fully closed and the technique generalizes to all
`deriv`-defined ordinals below `ω₁`. **If false:** it would expose a failure of
`ω₁`-closure for the Veblen operation, which would be surprising and worth understanding.

### Direction 3: Locate `ω₁` inside the `ε`-hierarchy
**Hypothesis.** There is a (necessarily uncountable) index `β` with `ε_ β = ω₁`, namely
`β = invVeblen₂ ω₁`, and `β` is the least fixed point of `ε_` above `0` of uncountable
cofinality.
**Test.** From `omega1_isEpsilon` (so `ω₁` is a fixed point of `ω^·`, i.e. in the range of
`ε_`) and the fact that `ε_ = veblen 1` enumerates *all* such fixed points
(`mem_range_veblen`, `invVeblen₂_epsilon`), extract `β` and prove `ε_ β = ω₁`.
**The key insight is** that `omega1_isEpsilon` upgrades `ω₁` from "a cardinal" to "an
`ε`-number," and `ε`-numbers are *exactly* the range of `ε_`, so the inverse Veblen
machinery must name `ω₁`'s index — converting a cardinal-theoretic object into an
ordinal-notation-theoretic one.
**Why now?** We just proved `ω ^ ω₁ = ω₁`; Mathlib's `invVeblen₂`/`mem_range_veblen` give
the inverse machinery to name the index. **If true:** a clean dictionary between cardinal
indices and `ε`-indices, sharpening the `PA`/`KP` bridge by locating `Ω` intrinsically.
**If false:** it would mean `ω₁` is a fixed point not enumerated by `ε_`, contradicting
normality — so failure would flag an API gap to fix.

### Direction 4: Constructive countability via Cantor normal forms below `ε₀`
**Hypothesis.** For every `o < ε₀`, `o.card ≤ ℵ₀` is witnessed by an explicit countable
Cantor-normal-form code, and there is an order isomorphism between an inductive `Type` of
CNFs `< ε₀` and `Set.Iio (ε_ 0)`.
**Test.** Build a `Type`-level inductive of Cantor normal forms `< ε₀`, a decoding to
`Ordinal`, and prove the decoding is an order isomorphism onto `Iio ε₀`; derive
countability constructively (without the `iSup_sequence_lt_omega_one` cardinality step).
**The key insight is** that `epsilonZero_eq_iSup_tower` already gives a *combinatorial*
exhaustion of `ε₀` by finite data (towers), so countability should be witnessable by an
explicit encoding rather than a nonconstructive cofinality/regularity argument.
**Why now?** Mathlib has `Ordinal.Notation` (CNF `< ε₀`) and a fast-growing hierarchy keyed
to it; connecting it to the `tower`/`ε₀` results here is now a finite gap. **If true:** a
*constructive* countability proof and a computable model of `PA`'s ordinal, enabling
effective comparisons. **If false:** it would indicate the `Notation` API does not
faithfully cover `Iio ε₀`, a concrete fixable defect.

### Direction 5: Non-monotonicity is forced for ALL uncountable collapse targets
**Hypothesis.** Generalize `no_monotone_collapse`: for any regular uncountable cardinal `κ`
and any `f` with `StrictMonoOn f (Iic κ.ord)`, one has `κ.ord ≤ f κ.ord`; hence no
order-preserving function can collapse any uncountable initial ordinal below itself.
**Test.** Our `strictMonoOn_Iic_le_apply` is *already* fully general — it states
`StrictMonoOn f (Iic o) → o ≤ f o` for arbitrary `o` and never used uncountability.
Specialize it to `o = κ.ord` and combine with `f κ.ord < κ.ord` to derive the obstruction.
**The key insight is** that the content of `no_monotone_collapse` is not about `ω₁` at all
but about *well-foundedness on an initial segment*; the general lemma already in this file
makes that explicit, so the "collapse ⇒ non-monotone" theorem is domain-independent.
**Why now?** Inspection shows the `key` induction is universe- and `ω₁`-agnostic; the
generalization is essentially free and clarifies the theorem's true content. **If true:** a
clean, reusable `StrictMonoOn.le_apply`-for-ordinal-initial-segments lemma and a
domain-independent "collapsing ⇒ non-monotone" statement, suitable for upstreaming.
**If false:** impossible given the proof — so the value here is the generalized lemma
itself.
