# Computational Evidence — Cycle 5 (Frame Definability for `ModalSystem`)

All computations below were run inside Lean 4 (mathlib4, `v4.28.0`) on the definitions
that appear in `Catalog/Combinatorics/ModalFrameCounting.lean` and
`Catalog/Combinatorics/ModalFrameCycleAxioms.lean`. Values marked **certified** are
theorems in the project, proved by kernel evaluation (`decide` / `decide +kernel`);
values marked *exploratory* were obtained with `#eval` only and are **not** asserted as
theorems anywhere.

## 1. Counting the finite Löb frames

By `valid_loeb_iff_finite` (Part I) a finite frame validates the Löb axiom
`□(□p → p) → □p` iff its relation is transitive and irreflexive, i.e. a labelled strict
partial order. Counting adjacency matrices on `Fin n`:

```lean
#eval (loebFrameCount 0, loebFrameCount 1, loebFrameCount 2, loebFrameCount 3)
-- (1, 1, 3, 19)
```

| `n` | total frames `2^(n²)` | Löb frames | status |
|-----|----------------------|-----------|--------|
| 0 | 1 | 1 | certified (`loebFrameCount_zero`) |
| 1 | 2 | 1 | certified (`loebFrameCount_one`) |
| 2 | 16 | 3 | certified (`loebFrameCount_two`) |
| 3 | 512 | 19 | certified (`loebFrameCount_three`, `decide +kernel`) |
| 4 | 65536 | 219 | *not certified* — kernel evaluation exceeded the time budget |

**OEIS search.** `1, 1, 3, 19, 219, 4231, 130023` is
[A001035](https://oeis.org/A001035), the number of labelled partially ordered sets on
`n` elements. The match is not a coincidence but a theorem here: the bridge
`valid_loeb_iff_isStrictMatrix` identifies Löb frames on `Fin n` with labelled strict
posets, so A001035 *is* the enumeration of finite GL frames.

**Contrast with reflection.** The reflection (soundness) axiom `□p → p` defines
reflexivity, so its frames on `Fin n` are counted by `2^(n²−n)`:

```lean
#eval reflexiveFrameCount 3   -- 64   (= 2^6)   [certified: reflexiveFrameCount_three]
```

so on three worlds the "internally sound" frames outnumber the Löbian ones 64 : 19, and
by `isEmpty_of_valid_loeb_and_reflection` no nonempty frame is in both classes.

## 2. Counterexample hunt: is every degree monoid principal?

Cycle 2 realised the soundness degrees `n ℕ` with cycle frames, which suggested the
(false) universal claim "the set of valid degrees of a frame is always the multiples of
one number". Searching small frames for a counterexample:

| frame | worlds | valid degrees `{k | □ᵏp → p valid}` |
|-------|--------|--------------------------------------|
| single loop (`loopFrame`) | 1 | `ℕ` |
| one-point irreflexive (`discreteOne`) | 1 | `{0}` |
| `cycleFrame 2` | 2 | `2ℕ` |
| `cycleFrame 3` | 3 | `3ℕ` |
| complete irreflexive `kThree` | 3 | `{0, 2, 3, 4, 5, …} = ⟨2,3⟩` |

The last row is the counterexample: every world of the complete irreflexive digraph on
three vertices lies on a closed walk of length 2 and of length 3, hence of every length
`≥ 2`, but on none of length 1. This is certified as `kThree_degree_iff` and
`kThree_degrees_not_principal`.

## 3. Sanity checks on the limitative results

Testing the two collapses used for the non-definability theorems:

* `succFrame ↠ loopFrame` (`n ↦ ()`): back condition holds because every `n` has the
  successor `n + 1`; the source is irreflexive, the target is not — so irreflexivity is
  not preserved by surjective bounded morphisms.
* `succFrame ⊎ loopFrame`: has a reflexive world, but its summand `succFrame` does not
  — so "some world is reflexive" is not preserved by taking summands.

Both are exactly the failures that `irreflexive_not_definable` and
`exists_reflexive_not_definable` turn into theorems.
