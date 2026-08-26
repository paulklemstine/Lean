# Computational Evidence

All numbers below were produced by direct enumeration of the `2^n` cyclic
configurations for each of the 256 elementary cellular automata (ECAs), using
executable Lean definitions (`#eval`) with the same local-rule convention as the
formal development (`localRule rule l c r = rule.testBit (4l + 2c + r)`, ring
indices in `ZMod n`).  Everything that is used in a *claim* has since been
re-proved formally in `Catalog/Novelty/ECA*.lean`; the tables here only served to
choose which statements to prove.

## 1. Fixed-point counts `|V(f)| = |{s : f(s) = s}|`

| rule | n=1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|
| 0 (class 1)   | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 110 (class 4) | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 124, 137, 193 (class 4) | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 30 (class 3)  | 1 | 3 | 1 | 3 | 1 | 3 | 1 | 3 | 1 |
| 45 (class 3)  | 0 | 0 | 3 | 0 | 0 | 3 | 0 | 0 | 3 |
| 90 (class 3)  | 1 | 1 | 4 | 1 | 1 | 4 | 1 | 1 | 4 |
| 150 (class 3) | 2 | 4 | 2 | 4 | 2 | 4 | 2 | 4 | 2 |
| 232 (class 2) | 2 | 2 | 2 | 6 | 12 | 20 | 30 | 46 | 74 |
| 204 (identity)| 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512 |

Observations that drove the formal work:

* The four Turing-complete class-4 rules `{110, 124, 137, 193}` have **exactly
  one** stationary configuration for every `n` — the *minimum* possible for an
  even rule, identical to the class-1 Rule 0.  Formalised as
  `rule110_fixedSet`, `rule124_fixedSet`, `rule137_fixedSet`, `rule193_fixedSet`.
* Rule 204 is the unique rule reaching `2^n`.  Formalised and sharpened to a
  classification in `hasFixedDim_max_iff_eq_204`.
* Rule 30 has `1` fixed point for odd `n` and `3` for even `n`; the three are
  `0` and the two alternating waves.  Formalised as `rule30_fixedSet_of_odd`
  and `rule30_fixedSet_of_even`, giving non-affineness for *all* even `n`.
* Rules 45 and 90 depend on `n mod 3`; Rule 150 on `n mod 2`.  Formalised as
  `rule45_fixedSet_nonempty_iff_three_dvd`,
  `rule90_fixedSet_eq_zero_of_not_three_dvd`, `rule150_fixedSet_of_odd`.

## 2. Counterexample hunt: is `|V(f)|` always a power of two?

At `n = 6`, **112 of the 256 rules** have a fixed-point count that is not a power
of `2`; hence for those rules `V(f)` is not an `𝔽₂`-affine subvariety and no
dimension exists.  Two clean witnesses were selected for formal proof:

* Rule 232 at `n = 4`: `|V| = 6`, and `6 ∤ 16` (`rule232_ncard_four`,
  `rule232_not_affine`).
* Rule 45 at `n = 3`: `|V| = 3`, and `3 ∤ 8` (`rule45_ncard_three`,
  `rule45_not_affine`).

A second, purely structural obstruction was found: `|V| = 0` is possible
(Rule 45, `3 ∤ n`), and every **odd** Wolfram number `r` has `f(0,0,0) = 1`, so
`0 ∉ V(f)`; that is 128 of the 256 rules (`odd_rule_no_fixed_dim`).

## 3. Temporal (periodic-point) counts for Rule 110

`|{s : f^k(s) = s}|` on the ring of size `n`:

| n \ k | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| 1–3 | 1 | 1 | 1 | 1 | 1 | 1 |
| 4 | 1 | 5 | 1 | 5 | 1 | 5 |
| 5–7 | 1 | 1 | 1 | 1 | 1 | 1 |
| 8 | 1 | 5 | 1 | 5 | 1 | 5 |

So Rule 110 does oscillate: on the ring of size 4 there is one `2`-cycle of four
configurations (`1110 ↦ 1011 ↦ 1110`).  This motivated Cycle 2: the *tower*
`k ↦ Per_k` separates Rule 110 from Rule 0 even though the bottom level does
not (`periodicSet_separates_rule110_rule0`).  Note `5 ∤ 16`, so even `Per_2` is
not an affine variety (`rule110_periodicSet_not_affine`).

## 4. OEIS

The Rule 232 sequence `2, 2, 2, 6, 12, 20, 30, 46, 74` (fixed points of the
majority rule on a ring of size `n = 1, 2, …`) was noted during the search; we
make no OEIS identification claim, as none was verified.  It is not used in any
theorem.

## 5. Status of the evidence

Every numerical statement that is *asserted* in the Lean files is proved there,
either structurally or by kernel-checked `decide` over an explicitly finite
configuration space (never `native_decide`).  The tables above are exploratory
data, not verified claims.
