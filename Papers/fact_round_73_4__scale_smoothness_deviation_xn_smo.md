# Computational evidence — QR dial statistics of `x² − N`

All computations below were run in Lean 4 (`#eval`, exact `ℚ`/`ℕ` arithmetic) before
the corresponding theorems were formalised.  Each is a small-case check of a claim
that is *proved* in `Catalog/NumberTheory/*.lean`; the Lean proofs, not these
evaluations, are the evidence of record.

## 1. The dial itself

`dial p N = #{x ∈ ZMod p : x² = N}`.

```lean
#eval (List.range 7).map (fun N => dialN 7 N)   -- [1, 2, 2, 0, 2, 0, 0]
```

Reading: `N = 0` has dial `1`; the quadratic residues `1, 2, 4` have dial `2`; the
nonresidues `3, 5, 6` have dial `0`.  Exactly `(p−1)/2 = 3` residues in each class.
Formalised as `dial_of_sq`, `dial_eq_two_iff`, `two_mul_card_dial_two_add_one`,
`two_mul_card_dial_zero_add_one`.

## 2. Moments of the dial (p = 11, 13)

| quantity | computed | theorem |
|---|---|---|
| `∑_N dial 11 N` | `11` | `sum_dial` (`= p`) |
| `∑_N (dial 11 N)²` | `21` | `sum_dial_sq` (`= 2p − 1`) |
| `∑_N localFactor 13 N` | `13` | `sum_localFactor` (mean exactly `1`) |
| `∑_N (localFactor 13 N − 1)²` | `1/12` | `sum_localFactor_centred_sq` (`= 1/(p−1)`) |

So the QR dial has mean exactly `1` — the same local density as a random integer —
and per-prime variance exactly `1/(p(p−1))`.

## 3. The dispersion ceiling `∏_{2 < p ≤ B} (1 + 1/(p(p−1)))`

```lean
def disp (B : ℕ) : ℚ :=
  ((Finset.range (B+1)).filter (fun p => Nat.Prime p ∧ p ≠ 2)).prod
    (fun p => 1 + 1/((p:ℚ)*((p:ℚ)-1)))
```

| `B` | `disp B` |
|---|---|
| 7 | `301/240 = 1.254166…` |
| 30 | `1.286217…` |
| 100 | `1.293363…` |
| 1000 | `1.295566…` |
| 10000 | `1.295718…` |

The product converges rapidly; the value at the experiment's smoothness bound
`B = 1000` is `E[C²] ≈ 1.2956`, i.e. a structure-correction variance of
`≈ 0.2956`.  The proved uniform ceiling is `2`
(`dispersionBound_le_two`), and the exact value at `{3,5,7}` is proved to be
`301/240` (`Example357.dispersionBound_eq`).

## 4. Consistency with the reported experiment

* Reported null: `r(u) ∈ {1.011, 0.949, 0.900, 1.200}`, all CIs covering `1`,
  tightest `|r − 1| ≤ 0.217`.  The exact theorem `sum_structureCorrection` says
  the ensemble mean of the structure correction is `1` *identically*, for every
  prime family and hence for every `u` — consistent with a flat, null trend.
* Reported per-`N` overdispersion at the low-`u` face: `D = 1.61 [1.50, 1.73]`.
  The mixture identity `mixVar_eq` gives `D = 1 + λ(E[C²] − 1) − q E[C²]`.
  With `E[C²] − 1 ≈ 0.2956` (row `B = 1000` above) this matches `D ≈ 1.6` at an
  event rate `λ ≈ 2` per cluster, and forces `D ≈ 1.00` at the bins 7–8 rates
  (`λ ≈ 18/4000 ≈ 0.005`).  The death of the clustering above `u ≈ 7` is
  therefore a counting effect, not an arithmetic one: the arithmetic input
  `E[C²]` is `u`-independent by construction.

## 5. Counterexample hunt

We searched for a prime family for which the ensemble mean of the structure
correction differs from `1` (which would be an `O(1)` smoothness edge).  None
exists: the mean is exactly `1` for every finite family of odd primes
(`sum_structureCorrection`), so the hunt is closed by proof rather than by
sampling.  Similarly no family can push the second moment past `2`
(`dispersionBound_le_two`), while every nonempty family has second moment
strictly above `1` (`one_lt_dispersionBound`) — the clustering is real but
capped.

## 6. OEIS

The dial sequence for a fixed prime is the classical `1 + χ_p` pattern of
quadratic residues; the numerators/denominators of the partial products in §3 are
not a recognisable OEIS entry and no OEIS identification is claimed.
