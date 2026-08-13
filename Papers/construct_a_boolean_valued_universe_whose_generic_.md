# Computational Evidence — Finite Pre-Boolean Forcing Frames

All numbers below were produced by an *exploratory* enumeration written in Lean and
run with `#eval` (brute-force over all worlds, all accessibility pairs, and — for
the `.2` check — all `2^{|W|}` predicates).  They are exploratory computations, not
proofs; every claim that they support is separately **proved** in the `.lean` files
listed in the last column.

A world of the `n`-button, `m`-switch control frame is a pair `(S, g)` with
`S ⊆ {1,…,n}` the set of pushed buttons and `g : {1,…,m} → Bool` the switch
setting.  Accessibility is `S ⊆ T` (switches may be reset freely).

## 1. Size of the frames

| buttons `n` | switches `m` | worlds | accessibility pairs | `3^n · 4^m` |
|---|---|---|---|---|
| 1 | 1 | 4  | 12  | 12  |
| 2 | 1 | 8  | 36  | 36  |
| 3 | 1 | 16 | 108 | 108 |
| 2 | 2 | 16 | 144 | 144 |

The pattern `|W| = 2^{n+m}`, `|R| = 3^n · 4^m` is **proved** in
`Catalog/Logic/Multiverse/FrameCounting.lean`
(`card_worlds`, `card_cacc_pairs`, via `sum_two_pow_card_powerset : ∑_{t ⊆ s} 2^{|t|} = 3^{|s|}`).
The factor `3^n` is the number of nested pairs of subsets of an `n`-set
(OEIS A000244, `1, 3, 9, 27, 81, …`); `4^m` is A000302.

## 2. Frame-condition checks

| property tested | `n=0` | `n=1` | `n=2` | `n=3` | proved in |
|---|---|---|---|---|---|
| upward directedness | true | true | true | true | `cacc_directed` (BooleanValuedRealization) |
| Euclidean (axiom `5`) | **true** | false | false | — | `cacc_euclidean_iff` (InvariantFragment) |
| axiom `5` on "button unpushed" | true | **false** | false | — | `five_fails`, `five_not_derivable` |
| linearity `.3` on button atoms | true | true (only one button) | **false** | false | `dot3_fails`, `dot3_not_derivable` |
| axiom `.2`, all `2^{\|W\|}` predicates | — | true | true | — | `cacc_dot2`, `S42_sound` |
| CH branch conditions `◇CH ∧ ◇¬CH` at every world | — | true | true | true | `CH_branches_in_frame`, `switch_is_switch` |

Highlights of the counterexample hunt:

* the Euclidean property flips exactly at `n = 1`: **one button already destroys
  `S5`**.  This is the computational shadow of the proved equivalence
  `EuclideanRel cacc ↔ IsEmpty Btn`;
* the linearity axiom `.3` survives with a single button and fails from `n = 2`
  onwards, so **two independent buttons are necessary and sufficient** for the
  `S4.2` / `S4.3` separation;
* the exhaustive `.2` check over *all* predicates (16 predicates for `n=m=1`, 256
  for `n=2, m=1`) found no failure, matching the soundness proof.

## 3. Boolean values

For the powerset algebra `Set (Sw → Bool)` used in the realization, the Boolean
value of the CH switch at stage `S` is the set `{g | g s = true}`; with `m = 1` it
has 1 of the 2 points, so it is neither `⊥` nor `⊤` — the hypothesis of the
branching theorem `branch_of_undecided`, hence the two derived CH branches
(`CH_branches_derived`).  The Boolean value of a *pushed* button atom is the whole
space and of an unpushed one the empty set, which is why button values are monotone
in the stage (`bval_mono_of_pos`) whereas switch values are constant in the stage
and non-constant in the point.
