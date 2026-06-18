# Future Directions — The Ordinal Collapsing Bridge, Cycle 3

## Synthesis

This cycle deepened the predicative-ordinal-analysis fragment by mining the *arithmetic
content* hidden inside the single defining equation of a strongly critical ordinal,
`veblen o 0 = o`. The catalog file `StronglyCriticalOrdinals.lean` had already proven the
order-theoretic closure `StronglyCritical.veblen_lt` (full binary Veblen closure). We
observed that this same equation is *self-feeding*: `StronglyCritical.veblen_eq` says every
lower Veblen function fixes `o`, and the two lowest Veblen functions are ordinary
arithmetic — `veblen 0 = (ω ^ ·)` and `veblen 1 = Ordinal.epsilon`. Specializing the
catalog closure at indices `0` and `1` therefore hands us, with no new fixed-point
analysis, the facts that every strongly critical ordinal is an `ε`-number
(`ω ^ o = o`), is a fixed point of the entire `epsilon` enumeration
(`Ordinal.epsilon o = o`), and is both additively and multiplicatively principal. We then
turned the catalog's *static* tower `ω < ε₀ < Γ₀` into a *dynamic* unboundedness theorem
via the normal function `Γ_`, and pushed that across the cross-domain bridge to the
catalog's proof-theoretic-strength order, proving `no_strongest_predicative_system`.

## Results Summary

New file `Logic/StronglyCriticalArithmetic.lean` (imports `Logic.StronglyCriticalOrdinals`):

- `StronglyCritical.one_lt` — strongly critical ⟹ `1 < o`.
- `StronglyCritical.omega_opow_eq` — `ω ^ o = o` (`ε`-number).
- `StronglyCritical.epsilon_fixed` — `Ordinal.epsilon o = o` (fixed point of the whole
  `ε`-enumeration).
- `StronglyCritical.principal_add`, `StronglyCritical.principal_mul` — additive and
  multiplicative principality.
- `stronglyCritical_unbounded` — the strongly critical ordinals are an unbounded class.
- `no_strongest_predicative_system` — every ordinal-analyzed system is dominated by one
  whose proof-theoretic ordinal is strongly critical.

All six results compile with `sorry = 0` and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### 1. The closure (continuity) half of "club"

We proved the strongly critical ordinals are *unbounded*; the natural companion is that
they are also *closed*: the supremum of a set of strongly critical ordinals (when it is a
limit) is again strongly critical, making the class a genuine club. **The key insight is**
that closure is exactly the statement that `fun o => veblen o 0` is a normal (continuous)
function, which Mathlib already records as `isNormal_veblen_zero`, so the supremum of
fixed points is a fixed point by `Order.IsNormal.map_iSup`/`apply_of_isSuccLimit`. *Why
now?* With unboundedness in hand from this cycle, closure is the one remaining ingredient
to characterize strong criticality as a derivative/enumeration, and the normality lemma is
already imported — this is a short, high-yield extension.

### 2. Range-of-`Γ` characterization

Conjecture: `StronglyCritical o ↔ ∃ β, Γ_ β = o`; i.e. the strongly critical ordinals are
*exactly* the values of Mathlib's `gamma`. We have the easy direction
(`gamma_stronglyCritical`); the converse needs that `Γ_` enumerates *all* fixed points of
`veblen · 0`. **The key insight is** that `Γ_` is by construction the order-isomorphism
onto the fixed-point class of the normal function `veblen · 0`, so the converse should
follow from the enumeration/`enumOrd` API once closure (Direction 1) is available. *Why
now?* This converts the predicate `StronglyCritical` into a constructive parametrization,
which is the prerequisite for any *effective* (computable normal-form) treatment of the
fragment below `Γ₀`.

### 3. A predicative Cantor normal form below `Γ₀`

Every ordinal `< Γ₀` has a unique representation as a finite descending Veblen-term sum
with arguments `< Γ₀`. **The key insight is** that `veblen_lt_gamma_zero` (catalog) plus
the principality results proven this cycle (`principal_add`) give precisely the closure
conditions needed for an inductive normal-form/decidability argument on the term algebra of
`veblen`/`+` below `Γ₀`. *Why now?* The principality and closure lemmas assembled here are
exactly the algebraic invariants a normal-form induction consumes, and a decidable normal
form would let `#eval`/`decide` operate on a concrete model of the fragment — the
algorithmic-engine objective.

### 4. Strict monotonicity of strength along the predicative hierarchy

Iterating `no_strongest_predicative_system` yields, for each system, an explicit strictly
increasing sequence of strongly critical proof-theoretic ordinals. **The key insight is**
that the witness `Γ_ (o+1)` built in `stronglyCritical_unbounded` is *constructive*, so the
"no strongest system" theorem upgrades to an explicit function `ℕ → OrdAnalyzedSystem`
producing an infinite strictly ascending strength tower — the exact mirror image of the
catalog's `no_infinite_consistency_descent`. *Why now?* Pairing the new ascending
construction with the existing descending-impossibility theorem characterizes predicative
strength as an order of type exactly `Ordinal` restricted to the club, a clean structural
classification.

### 5. Separating `ε`-numbers from strongly critical ordinals computationally

`epsilon_zero_not_stronglyCritical` (catalog) shows `ε₀` is an `ε`-number but not strongly
critical, while this cycle shows every strongly critical ordinal *is* an `ε`-number. The
conjecture is a sharp quantitative gap: there are strongly-critically-many `ε`-numbers
strictly between consecutive strongly critical ordinals. **The key insight is** that
between `Γ_ β` and `Γ_ (β+1)` the function `veblen 1 = epsilon` is still normal and
unbounded, so its fixed points (the `ε`-numbers) form their own club inside each
strongly-critical gap. *Why now?* This pinpoints exactly *where* predicative closure
strictly strengthens being an `ε`-number, sharpening the boundary result already in the
catalog into a density statement.
