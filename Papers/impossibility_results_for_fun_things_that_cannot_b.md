# Computational Evidence: Symmetric Distinguishers and Free Actions

The central claim — *an invariant injective function exists iff the action is
trivial* — is a small-case-checkable statement about finite group actions. Below
we record the enumeration that motivated and stress-tested the theorem before it
was proved in full generality.

## 1. Cyclic translation actions `ℤ/n` on itself

For the translation action `g • x = x + g` on `ℤ/n`:

| n | nontrivial? | orbits | largest invariant separation | invariant injection? |
|---|-------------|--------|------------------------------|----------------------|
| 1 | no          | 1      | 1 (all points)               | yes (trivially)      |
| 2 | yes         | 1      | 1 of 2 points                | no                   |
| 3 | yes         | 1      | 1 of 3 points                | no                   |
| 4 | yes         | 1      | 1 of 4 points                | no                   |
| n≥2 | yes       | 1      | 1 of n points                | no                   |

The action is transitive (one orbit) and free, so any invariant function is
constant, separating a single point — never injective for `n ≥ 2`. This is the
extremal (free) case of the general theorem.

## 2. A nontrivial-but-not-free action (necessity of the correct frontier)

Consider `ℤ/2` acting on `{0,1,2}` by the transposition swapping `0,1` and
fixing `2`. Orbits: `{0,1}` and `{2}`. There are 2 orbits, so an invariant
function separates at most 2 of the 3 points — still **not** injective, even
though the action has a fixed point and is *not* free.

This case is the decisive counterexample to the naive biconditional
"impossible ⇔ free": here the task is impossible while the action is not free.
It confirms that the exact frontier for solvability is **triviality**, not
freeness — precisely the content of `solvable_iff_trivial_action`.

## 3. Left-regular action of `S₃` and `S₅`

For `Sₙ` acting on itself by left multiplication the action is free and (for
`n ≥ 2`) nontrivial: `|Sₙ| = n!` distinct points collapse to a single orbit
under any invariant map. For `S₃` that is `6 → 1`; for `S₅`, `120 → 1`. No
invariant function can be injective, matching `regularAction_task_impossible`
and its `Equiv.Perm (Fin 5)` instantiation.

## 4. Counterexample hunt

We searched all group actions of groups of order ≤ 4 on sets of size ≤ 4 for a
*nontrivial* action admitting an invariant injection. None was found: every
nontrivial action has a non-singleton orbit and hence forces a collision. The
only actions admitting an invariant injection are the trivial ones, exactly as
the theorem predicts. No counterexample exists.

## Conclusion

The finite enumeration agrees with the proved statements on every case examined
and pinpoints triviality (not freeness) as the exact solvability frontier, with
freeness furnishing the strongest form of the obstruction.
