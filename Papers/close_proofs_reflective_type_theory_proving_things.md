# Computational Evidence — Reflective Type Theory II (Correspondence & Limits)

Before formalizing, we checked the conjectured correspondence dictionary and the
limiting phenomena on small explicit provability steps.

## 1. Small-case check of the correspondence dictionary

We interpret a proposition as the set of stages at which it holds, and `□P` as
"all one-step successors satisfy `P`". On a finite stage set the schemata below can
be checked by brute force over all subsets `P`.

Frames tested (worlds `{0,1,2}`):

| frame `R` | reflexive | transitive | serial | symmetric | euclidean |
|---|---|---|---|---|---|
| empty step (no edges)            | no  | yes | no  | yes | yes |
| identity step (`i→i`)            | yes | yes | yes | yes | yes |
| chain `2→1→0`                    | no  | no  | no  | no  | no  |
| full step (all edges)            | yes | yes | yes | yes | yes |

For each frame we enumerated all `P ⊆ {0,1,2}` (8 subsets) and confirmed:

- `∀P. □P ⊆ P` held **iff** the step was reflexive.
- `∀P. □P ⊆ □□P` held **iff** the step was transitive.
- `∀P. □P ⊆ ◇P` held **iff** the step was serial.
- `∀P. P ⊆ □◇P` held **iff** the step was symmetric.
- `∀P. ◇P ⊆ □◇P` held **iff** the step was euclidean.

No frame in the sample violated any equivalence — consistent with the general
theorems `T_iff_reflexive`, `four_iff_transitive`, `D_iff_serial`,
`B_iff_symmetric`, `five_iff_euclidean`.

## 2. "Provable but not provably provable" and non-transitivity

On the chain `2→1→0` with `P = {1}`:

- `□P` at stage `2`: the only successor of `2` is `1 ∈ P`, so `2 ∈ □P`. ✓
- `□□P` at stage `2`: requires `1 ∈ □P`, i.e. `0 ∈ P`; but `0 ∉ P`, so `2 ∉ □□P`. ✓

Thus stage `2` witnesses `□P ∧ ¬□□P`. A search over the four sample frames found
such a witness **only** on the non-transitive chain — matching
`not_transitive_of_witness` (any such witness forces non-transitivity).

## 3. Gödel–Löb limit

On the chain `2→1→0` (transitive closure would be needed for a true GL frame; we use
the strict-order step `i→j` iff `i>j`, which is transitive and converse
well-founded):

- `□∅` = stages with no successor = `{0}`.
- `(□∅)ᶜ` = `{1,2}`.
- `□((□∅)ᶜ)` = stages all of whose successors lie in `{1,2}` = `{2}` (since `2→1` only;
  `1→0` fails as `0 ∉ {1,2}`).
- `□∅` again = `{0}`.
- Check `□((□∅)ᶜ) ⊆ □∅`: is `{2} ⊆ {0}`? **No** — but note this step is *not*
  converse well-founded-consistent with the naive reading; recomputing on the genuine
  GL frame `i→j ⇔ i>j` over `{0,1,2}`:
  - `□∅` = `{0}` (only `0` has no successor).
  - `(□∅)ᶜ = {1,2}`; `□(□∅)ᶜ` = stages whose successors ⊆ `{1,2}` = `{1}` (successors
    of `1` are `{0}`? no: with `>`, successors of `1` are `{0}`, so `1 ∉`; successors of
    `2` are `{0,1}`, `0 ∉ {1,2}` so `2 ∉`). Hence `□(□∅)ᶜ = ∅ ⊆ □∅`. ✓

The corrected computation confirms `goedel_two` on the genuine GL step: provable
consistency is empty, hence trivially below `□∅`. The subtlety (empty-step vs strict
order) is exactly why the formal statement quantifies over transitive, converse
well-founded steps.

## Conclusion

All computational checks are consistent with the formalized theorems. No
counterexample was found; the only apparent discrepancy (Section 3) resolved once the
frame was required to be genuinely Gödel–Löb (transitive **and** converse
well-founded), which is precisely the hypothesis of `goedel_two`.
