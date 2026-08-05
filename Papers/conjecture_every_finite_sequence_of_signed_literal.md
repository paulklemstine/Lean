# Computational evidence: revision histories in dream logic

Exploratory enumeration performed *before* formalisation, on the two-atom model
`Atom = {0,1}`, `Literal = Atom × Bool`, with
`revise B l = insert l (B \ {opposite l})` (the operator from
`Catalog/Novelty/DreamLogic.lean`).

All 16 signed states and all 1 + 4 + 16 + 64 = 85 revision histories of length ≤ 3 were
enumerated exhaustively.

> Status note: the enumeration below is *ad-hoc exploratory computation*, not a verified
> artifact. Everything it suggested is proved for arbitrary atom types, arbitrary states
> and arbitrary finite histories in `Catalog/Shared/DreamRevisionNormalForm.lean`, which
> compiles with no `sorry` and no extra axioms.

## 1. Last-occurrence normal form

Prediction tested, for every state `B` and history `ls`:

```
reviseSeq B ls = { p | lastSign ls p.1 = some p.2 } ∪ { p | lastSign ls p.1 = none ∧ p ∈ B }
```

| states × histories checked | mismatches |
|---|---|
| 16 × 85 = 1360 | **0** |

Formalised as `DreamLogic.mem_reviseSeq`.

## 2. Local rewriting rules

Over all 16 states and all 16 ordered pairs of literals:

| rule | failures |
|---|---|
| `l.1 ≠ k.1 → revise (revise B l) k = revise (revise B k) l` (commutation) | **0** |
| `l.1 = k.1 → revise (revise B l) k = revise B k` (last write wins) | **0** |

Formalised as `revise_comm_of_ne_atom`, `revise_revise_of_eq_atom`.

## 3. Strongly connected components of the revision graph

Consistent states over `n` atoms: each atom is unassigned, positive, or negative, so the
count is `3^n` (`n = 2` gives the 9 states found by enumeration; sequence `3^n` is
OEIS A000244).

Mutual reachability was computed by brute force on the 9 consistent two-atom states, using
all histories of length ≤ 3.

| assigned atom set | number of consistent states | mutually reachable class? |
|---|---|---|
| `{}` | 1 | yes |
| `{0}` | 2 | yes |
| `{1}` | 2 | yes |
| `{0,1}` | 4 | yes |

Mismatches between "mutually reachable" and "same assigned set", over all 81 ordered pairs:
**0**. The component containing states with assigned set `S` has `2^|S|` elements — the
vertex set of a `|S|`-cube, matching the cubical picture. Formalised as
`mutually_reachable_iff` (with `assigned_revise` giving the monotone invariant).

## 4. Frame property / persistent non-explosion

For every state `B`, every literal `l ∉ B`, and every history of length ≤ 3 that never
mentions `l`'s atom: **0** violations of `l ∉ reviseSeq B ls` (including the cases where
`B` is contradictory at the other atom and that atom is revised repeatedly).

Formalised as `reviseSeq_frame` and `persistent_nonexplosion`.

## 5. Counterexample hunt on the *uniqueness* statement

The naive reading "the normal form is a unique *list*" is **false**: for
`ls = [(0,true),(1,false)]` the histories `[(0,true),(1,false)]` and `[(1,false),(0,true)]`
have the same last-occurrence record and hence the same action, but are different lists.
They are permutations of each other. Enumeration found no pair of atom-repetition-free
histories with the same action that are *not* permutations. Accordingly the formal
statement `normalForm_unique` concludes uniqueness **up to permutation**, which the
commutation rule shows is optimal.

Sample normal forms (deleting superseded literals):

| history | normal form |
|---|---|
| `[(1,+),(2,−),(1,−)]` | `[(2,−),(1,−)]` |
| `[(1,+),(2,−),(1,−),(3,+),(2,+)]` | `[(1,−),(3,+),(2,+)]` |

The maximal normal-form length for histories over `n` atoms is `n`, independent of the
history length (2 for the two-atom model, already attained at length 2).
