# Computational Evidence — Well-founded frameworks have a unique complete extension

We test the central claim of this cycle:

> **If the attack relation `R` is well-founded, then the argumentation framework
> has a unique complete extension, which is the grounded extension, and it is
> also stable and preferred.**

All frameworks below are finite, so `R` is well-founded iff it has no directed
cycle (in particular no self-attack `R a a`).

## Notation

Arguments are named `0,1,2,…`; `a → b` means `R a b` ("`a` attacks `b`").
Grounded extension is computed as the least fixed point of the defense operator
`charF S = {a | every attacker of a is attacked by S}`, i.e. `⋃ₙ charFⁿ(∅)`
(this ω-formula suffices for finite frameworks).

## Case 1 — empty attack, `A = {0,1}`, no attacks

* `charF(∅) = {0,1}` (vacuously every argument is defended). Fixed point already.
* Grounded = `{0,1}`. It is conflict-free, stable (nothing outside), complete.
* Only complete extension: `{0,1}`. ✔ unique.
* `R` well-founded (empty). Matches `grounded_unique_complete_of_wf`.

## Case 2 — a chain, `A = {0,1,2}`, `0 → 1 → 2`

Well-founded (no cycle).

* `charF(∅)`: an argument is defended by `∅` iff it has no attacker.
  `0` has no attacker ⇒ in. `1` attacked by `0` ⇒ out. `2` attacked by `1` ⇒ out.
  `charF(∅) = {0}`.
* `charF({0})`: `0` in (no attacker); `2`'s attacker `1` is attacked by `0∈S` ⇒ `2` in;
  `1`'s attacker `0` is not attacked ⇒ `1` out. `charF({0}) = {0,2}`.
* `charF({0,2}) = {0,2}` (fixed). Grounded = `{0,2}`.
* `{0,2}` is conflict-free; argument `1 ∉ S` is attacked by `0 ∈ S` ⇒ **stable**.
* Enumerating conflict-free fixed points of `charF` over the 8 subsets: only
  `{0,2}` qualifies. ✔ unique complete extension = grounded = stable.

## Case 3 (contrast) — a 2-cycle, `A = {0,1}`, `0 → 1 → 0`

**Not** well-founded (cycle `… → 0 → 1 → 0 → …`).

* `charF(∅) = ∅` (each of `0,1` has an unattacked-from-∅ attacker).
  Grounded = `∅`.
* But the complete extensions are `∅`, `{0}`, `{1}` — **three** of them, and
  `{0}`, `{1}` are stable. Uniqueness fails.

This is exactly the counterexample the theorem's hypothesis excludes, confirming
well-foundedness is essential (not decorative): dropping it makes
`grounded_unique_complete_of_wf` false.

## Case 4 — `stable ⇒ complete` is proper (no well-foundedness needed)

In Case 3, `{0}` is stable and complete, but the grounded/complete extension `∅`
is complete yet **not** stable (`0 ∉ ∅` is not attacked by `∅`). So the inclusion
`Stable ⊆ Complete` proved in `stable_complete` is strict in general, matching the
file's docstring.

## Intersection characterization (any framework)

Case 3: complete extensions are `∅, {0}, {1}`; their intersection is `∅` =
grounded. ✔ `groundedExt_eq_sInter_complete`.
Case 2: only `{0,2}`; intersection `{0,2}` = grounded. ✔

## Summary

| framework | well-founded | # complete ext. | grounded | stable? |
|-----------|:---:|:---:|:---:|:---:|
| ∅ attacks on {0,1} | yes | 1 | {0,1} | yes |
| chain 0→1→2 | yes | 1 | {0,2} | yes |
| 2-cycle 0⇄1 | no | 3 | ∅ | no |

Every well-founded row has a unique complete extension equal to a stable grounded
extension; the non-well-founded row does not. This matches all theorems proved
in `ArgumentationGroundedUnique.lean`.
