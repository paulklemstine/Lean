# Computational Evidence — `transEndo` and its rank profile

The objects here live over an *abstract* field `K` and module `V`, so direct
`#eval` enumeration is not meaningful. Instead we record the small-window
sanity checks that pin down the definition; each is a definitional/inductive
identity that is also discharged inside the Lean files.

## Small-window calculations
- Empty window: `transEndo f i i = id` (`transEndo_self`). Window `[i,i)` is empty,
  so the ordered product is the identity. ✔ proved.
- Degenerate window: `transEndo f i j = id` whenever `j ≤ i`
  (`transEndo_eq_id_of_le`). ✔ proved.
- Single step: `transEndo f i (i+1) = (f i).comp id = f i`
  (special case of `transEndo_succ_of_le`). ✔ proved.
- Two steps: `transEndo f i (i+2) = (f (i+1)).comp (f i)`, the ordered composite.
  ✔ follows from `transEndo_succ_of_le` twice.
- Concatenation: `transEndo f 0 2 = (transEndo f 1 2).comp (transEndo f 0 1)
  = (f 1).comp (f 0)`, matching `transEndo_comp`. ✔ proved (general law).

## Rank-profile observations
- For a constant stream `fun _ => g`, `transEndo (fun _ => g) 0 n = g ^ n`
  (`transEndo_const`), so `rankSeq (fun _ => g) 0 n = (g ^ n).rank.toNat`, the
  classical descending chain of iterate-image dimensions.
- The chain `rankSeq f 0 0 ≥ rankSeq f 0 1 ≥ rankSeq f 0 2 ≥ …` is non-increasing
  (`rankSeq_zero_antitone`) and bounded by `finrank K V` (`rankSeq_le_finrank`),
  hence eventually constant (`rankSeq_eventually_const`). For a nilpotent `g` of
  index `d` the floor is `0`; for invertible `g` the chain is constantly
  `finrank K V`.

## Counterexample hunt
- "Rank could increase along the window" — refuted in general by
  `rank_transEndo_succ_le` (a one-step rank increase is impossible because the new
  map factors through the old one).
- "The rank sequence might never stabilize" — refuted by
  `rankSeq_eventually_const`, since a bounded antitone `ℕ → ℕ` sequence must flatten.

No counterexample to any stated theorem was found; the universal claims are proved
with `0` sorries (only the standard `propext`, `Classical.choice`, `Quot.sound`
axioms).
