# Computational Evidence — strict alternating cycles in the blown-up crown

Target conjecture: for fixed width `w ≥ 2`, the maximum number of strict
alternating cycles in an `n`-element width-`w` poset is `Θ(n^{2w})`.  The classical
upper bound is `O(n^{2w})`; the open half is the matching lower bound.  We confirm
the lower-bound construction (the **blown-up crown** `Crown w m`) computationally
before proving it.

## 1. Small-case exact counts

We enumerate *all* length-`w` indexed families `p : Fin w → P × P` over
`P = Crown w m` and count those satisfying the strict-alternating-cycle predicate
(`xᵢ ≤ y_j ↔ j = i+1` and `yᵢ ≰ xᵢ`).  These are exact counts obtained by finite
decidable enumeration in Lean (`Finset.filter ... |>.card`), not estimates.

| `w` | `m` | `n = 2wm` | exact #cycles | lower bound `m^{2w}` | ratio |
|-----|-----|-----------|---------------|----------------------|-------|
| 2   | 1   | 4         | 18            | 1                    | 18.0  |
| 2   | 2   | 8         | 200           | 16                   | 12.5  |
| 3   | 1   | 6         | 162           | 1                    | 162.0 |

In every case the exact count exceeds the proved lower bound `m^{2w}`, so the bound
is genuine and non-vacuous (the construction even has spare cycles coming from
column patterns other than the canonical one).

## 2. Why `m^{2w}` and not something larger is the *provable* clean bound

The construction `cyc u v` chooses, in each column `t`, an `a`-clone index `u t`
and a `b`-clone index `v t`.  That is `2w` independent choices from `m` values, i.e.
`m^{2w}` distinct strict alternating cycles, and the map `(u,v) ↦ cyc u v` is
injective.  This is the cleanly-countable injective sub-family; the *total* count
(table above) is larger but messier, so we certify the clean `m^{2w}` lower bound.

## 3. Order-of-growth check

With `n = 2wm`, `m = n/(2w)`, so `m^{2w} = (2w)^{-2w} · n^{2w} = c_w · n^{2w}` with
`c_w = (2w)^{-2w} > 0`.  Thus the construction realises `Ω(n^{2w})`, matching the
`O(n^{2w})` upper bound and confirming `Θ(n^{2w})`.

## 4. Width sanity check

The carrier has `2w` chains, so a naive antichain bound is `2w`.  The cross
relations `a(i,·) ≤ b(i+1,·)` cut this to exactly `w`: the column-folding map
`fold x = if x.side then x.col else x.col+1` is injective on antichains (verified
by `crown_antichain_card_le`), and the all-`a` transversal attains `w`
(`crown_antichain_card_eq`).  Hence width `= w` exactly, so the construction is an
admissible width-`w` poset (not a wider one).

## 5. Conclusion

The computational landscape is consistent with the conjecture: the explicit
construction is a width-`w`, size-`2wm` poset with at least `m^{2w}` strict
alternating cycles.  We proceed to the formal proof in
`AlternatingCyclePosetLowerBound.lean`.
