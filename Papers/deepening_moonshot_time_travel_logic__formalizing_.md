# Computational Evidence: Time-Travel Causal Consistency

The formal development in `Catalog/Logic/TimeTravelCausalConsistency.lean` models a
**causal loop** by a state space `X`, a loop `length` `n > 0`, and causal steps
`step i : X → X` (indices mod `n`). The **round-trip map** is
`G = step (n-1) ∘ ⋯ ∘ step 0`. A **consistent history** is a periodic assignment of
states respecting every causal step. The core claim (Novikov self-consistency
principle) is:

> a consistent history exists **iff** `G` has a fixed point.

## 1. Small-case calculations

* **Grandfather paradox** (`n = 1`, `X = Bool`, `step = ¬`): `G = ¬`, so `G b = b`
  forces `¬b = b`, impossible. No fixed point ⇒ no consistent history. Confirmed
  formally (`grandfather_paradox`) and by direct enumeration: `¬false = true ≠ false`,
  `¬true = false ≠ true`.

* **Identity loop** (`step i = id`): `G = id`, every state is a fixed point, and every
  constant history is consistent. Consistent.

* **Length-2 swap on `Bool`** (`step 0 = ¬`, `step 1 = id`): `G = id ∘ ¬ = ¬`, no
  fixed point ⇒ inconsistent, matching intuition.

## 2. Fixed points of `G` vs. consistent histories (bijection check)

For a finite `X` and any loop, enumerating histories `h : {0,…,n-1} → X` that satisfy
the causal step and periodicity reproduces exactly the fixed-point set of `G`, since a
history is determined by `h 0` and consistency pins `h 0 = G(h 0)`. This is the finite
shadow of the type-level equivalence `consistentHistoryEquivFixedPoint` and the count
identity `card_consistentHistory_eq_card_fixedPoint`.

Example (`X = Fin 3`, `n = 1`, `step = (·+1)`): `G = (·+1)` is a 3-cycle with no fixed
point ⇒ 0 consistent histories. Iterating the loop `3` times gives `G^[3] = id`, whose
fixed points are all of `Fin 3` ⇒ the tripled loop has `3` consistent histories.

## 3. "Consistency in the limit" (finite state spaces)

On a finite non-empty `X`, the sequence `x, G x, G² x, …` must repeat, so some
`G^[k] x = x` with `k > 0`. Hence the loop **traversed `k` times** always admits a
consistent history even when a single traversal does not — verified for the 3-cycle
above (`k = 3`) and formalized as `finite_pow_consistent`, using
`roundTrip_iterate : G^[k] = trajectory over k·n steps`.

## 4. Counterexample hunt

The universal claim "every causal loop on a finite non-empty space is self-consistent"
is **false** (grandfather / cycle counterexamples above). The *corrected* universal claim
— "some repetition of the loop is self-consistent" — survives all tested cases and is
proved in general. No counterexample to the proved statements was found.

## OEIS

The number of consistent histories of the loop equals the number of fixed points of a
composite self-map; for a random loop this is governed by fixed-point statistics of
random maps rather than a single canonical integer sequence, so no specific OEIS entry
is claimed.
