# Computational Evidence — Sperner ⇒ Nash (combinatorial fixed points)

All computations below were run in Lean (`#eval` / `decide`) and subsequently turned
into formally verified theorems in the accompanying `.lean` files.

## 1. One-dimensional Sperner parity (`SpernerOneDim.lean`)

Model a Sperner colouring of the path on vertices `0,…,n` as `c : ℕ → Bool`, and let
`flips c n` be the number of bichromatic edges. Endpoints chosen to differ.

| colouring `c` on `[0,5]` | endpoints differ? | `flips c 5` | odd? |
|---|---|---|---|
| `fun i => decide (i ≥ 3)` (one jump) | yes | 1 | yes |
| `fun i => i % 2 == 0` (alternating)  | yes | 5 | yes |

Observation: whenever the endpoints differ, `flips` is **odd**, hence ≥ 1.
This is the parity law `flips_odd_iff` and the existence corollary
`exists_bichromatic_edge`.

Counterexample hunt: we searched for a colouring with differing endpoints and an
**even** (in particular zero) door count. None exists — the parity law forbids it.
This robustness is recorded as `flips_pos`.

## 2. Matching Pennies has no pure Nash equilibrium (`PureNashBoundary.lean`)

Players `ι = Bool`, strategies `Bool`. Payoffs: player `false` (matcher) gets `+1`
on agreement, player `true` (mismatcher) gets `+1` on disagreement.

Brute-force over all 4 pure profiles `p : Bool → Bool`, testing the Nash predicate
`∀ i s, u i (update p i s) ≤ u i p`:

```
profiles (p false, p true) = (F,F) (F,T) (T,F) (T,T)
isNash?                     = false false false false
```

Every profile admits a profitable unilateral deviation ⇒ **no pure Nash
equilibrium**. Formalised as `matchingPennies_no_pureNash`, and combined with the
potential-games existence theorem to deduce `matchingPennies_no_exactPotential`.

## 3. Potential games always have a pure equilibrium (`FinitePotentialGames.lean`)

For an exact potential `Φ`, a profile maximising `Φ` is a Nash equilibrium
(`isNash_of_maximizer`); maximisers exist over the finite profile space
(`Finite.exists_max`), giving `exists_pureNash_of_potential`. Common-interest games
are the canonical instance (`exists_pureNash_commonInterest`); the all-`true`
profile of the coordination game is an explicit witness (`coordination_pureNash`).

## OEIS note

The door-count parity invariant ("odd iff endpoints differ") is the 1-D instance
of the general Sperner mod-2 count; no single integer sequence is being conjectured,
so no OEIS lookup applies. The relevant phenomenon is a parity (mod 2) invariant,
not a growth sequence.
