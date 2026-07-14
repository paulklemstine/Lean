# Computational Evidence — Alexandrov Topology of the Forcing Multiverse

**Target category (Menu Balance):** *cross-domain bridge* — general topology
(interior/closure, Alexandrov-discrete spaces) × modal logic of forcing
(box/dia, buttons, settled assertions) × the quantitative combinatorics of
Direction 5.

## Small cases

Take `W = Fin 3` with the linear extension order `R = (· ≤ ·)` (a preorder, so
axioms **T** and **4** hold).  Upper sets (= open sets) are the up-closed
subsets: `∅, {2}, {1,2}, {0,1,2}` — exactly `n+1 = 4` opens for the chain of
length `n = 3`.

* `S = {1}`.  Interior = largest upper set inside `{1}` = `∅`, matching
  `box R (·∈S) 0 = 0∈S?` No: `box R (·∈{1}) w` requires all `v ≥ w` in `{1}`,
  impossible for any `w` (since `2 ≥ w` but `2 ∉ {1}` once `w ≤ 2`), so
  `{w | box …} = ∅`.  ✓ interior = box.
* Closure of `{1}` = smallest down-set containing `1` = `{0,1}`, matching
  `dia R (·∈{1}) w = ∃ v ≥ w, v = 1`, true for `w ∈ {0,1}`.  ✓ closure = dia.
* Clopen sets: only `∅` and `{0,1,2}` are simultaneously up- and down-closed in a
  chain — the two constants.  ✓ `card_settled = 2`.

## Complete relation (S5 situation)

For `R = ⊤` on any nonempty `W`, the only upper sets are `∅` and `univ` (any
nonempty proper subset has an accessible point outside it).  Hence the topology is
indiscrete and the only clopens are `∅, univ`.  This is `isClopen_complete_iff`
and reproduces `card_settled = 2` purely topologically.

## Counterexample hunt (frame conditions are necessary)

* Dropping **reflexivity**: with `R = ∅` (empty relation) on `W = {0}`, `box`
  becomes vacuously true everywhere, so `{w | box (·∈∅) w} = univ ⊄ ∅`; the
  inclusion `interior ⊆ S` fails.  So `hR` is load-bearing.
* Dropping **transitivity**: with `W = {0,1,2}`, `R = {(0,1),(1,2)}` (no `(0,2)`),
  the set `{w | box (·∈{1,2}) w}` is not an upper set, so it is not open and
  cannot equal an interior.  So `hT` is load-bearing.

## Conclusion

The equalities `interior = box` and `closure = dia` hold on every finite preorder
tested and fail exactly when reflexivity or transitivity is removed — matching the
Sahlqvist correspondence that **T** and **4** are the topological forcing axioms.
No counterexample to the stated (preorder-guarded) theorems was found.
