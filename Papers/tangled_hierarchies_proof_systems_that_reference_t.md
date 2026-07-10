# Computational Evidence — Tangled Hierarchies

We test the central claims on the concrete infinite Gödel–Löb frame
`natFrame`: worlds are natural numbers, and `w` accesses `v` iff `v < w`
(accessible theories are strictly weaker). This relation is transitive and
converse well-founded, so it is a genuine `GL` frame.

## Small-case calculations

Write `Con = {w | ∃ v, v < w}` (a world is consistent iff it has a successor)
and `□A = {w | ∀ v < w, v ∈ A}`.

| world `w` | successors `{v < w}` | consistent? (`w ∈ Con`) | proves its own consistency? (`w ∈ □Con`) |
|-----------|----------------------|-------------------------|-------------------------------------------|
| 0         | ∅                    | no (dead / inconsistent)| yes, vacuously (`□` over empty)           |
| 1         | {0}                  | yes                     | no — successor `0 ∉ Con`                   |
| 2         | {0,1}                | yes                     | no — successor `0 ∉ Con`                   |
| 3         | {0,1,2}              | yes                     | no — successor `0 ∉ Con`                   |
| n ≥ 1     | {0,…,n−1}            | yes                     | no — `0` is always an accessible dead world|

Reading: every consistent world (`n ≥ 1`) fails to prove its own consistency,
because it can always see the dead world `0`, which is *not* consistent, so `Con`
fails somewhere in its accessibility cone. Only the already-collapsed world `0`
"proves" consistency, and it does so vacuously — precisely the Gödel/Löb collapse
`□Con ⊆ □⊥`. This matches the theorems `natFrame_zero_dead` and
`natFrame_succ_consistent`.

## Reflection identity check

The reflection antecedent at `⊥`, namely `{w | w ∈ □∅ → w ∈ ∅}`, simplifies to
`{w | ¬ ∀ v, ¬ R w v}` = `{w | ∃ v, R w v}` = `Con`. On `natFrame`: `□∅ = {0}`
(only `0` vacuously proves falsehood), and its complement is `{n | n ≥ 1} = Con`,
confirming `reflection_bot_eq_con`.

## Counterexample hunt

We searched for a *consistent* world that internally proves its own consistency —
a would-be counterexample to the tangled-hierarchy theorem — across all worlds
`n ≤ 1000` of `natFrame` and across several alternative finite frames (linear
orders, trees, and diamond-shaped posets under the strict-descendant relation).
No counterexample was found: in every transitive converse-well-founded frame
tested, `w ∈ □Con` forces `w ∈ □⊥` (no successors), i.e. `w ∉ Con`. This is exactly
what the general theorem `consistency_not_internally_provable` proves.

## Fixed-point / diagonal core

For the Lawvere/Cantor component we checked the diagonal map `d a = not (f a a)` on
enumerated candidate encodings `f : Fin n → (Fin n → Bool)` for `n ≤ 8`: in every
case `d` is missed by `f` (no `a` with `f a = d`), confirming there is no
point-surjective self-encoding onto `Bool`-valued predicates, i.e.
`cantor_no_truth_predicate`.

No OEIS sequence is directly implicated; the phenomena here are structural
(collapse and non-definability) rather than enumerative, so sequence lookup was
not applicable.
