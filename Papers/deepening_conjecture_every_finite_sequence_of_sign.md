# Computational evidence

All numbers below were produced by `#eval` inside Lean 4 (Mathlib v4.28.0), using the
definitions `DreamLogic.lastSign` and `DreamLogic.normalForm` from
`Catalog/Shared/DreamRevisionNormalForm.lean` together with the new file
`Catalog/Shared/RevisionHistoryMonoid.lean`.  Every claim listed here is *also* proved
formally in that file; the evaluations were exploratory sanity checks run before and while
the proofs were written.

## 1. How many distinct revision behaviours are there?

For an atom set of size `n`, enumerate every revision history of length `≤ k` over the
`2n` literals and count the distinct last-occurrence records.

| atoms `n` | `k = 0` | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| 2 | 1 | 5 | 9 | 9 | 9 |
| 3 | 1 | 7 | 19 | 27 | 27 |

The counts stabilise at `3 ^ n` (9 and 27), and stabilisation happens exactly at `k = n`:
each atom is either untouched, set positive, or set negative.  The partial sums are
`∑_{j ≤ k} C(n, j) 2^j` — the number of partial sign assignments of support size `≤ k`.
The stabilised value `3 ^ n` is the content of `card_partialAssign`; the fact that length
`n` suffices is `normalForm_length_eq_card_support`.

The triangle `C(n,j) 2^j` is the standard "signed subsets" triangle (row sums `3^n`,
OEIS A013609 / A038207 for the `2^j` binomial transform); no new sequence appears here, so
no further OEIS lookup was needed.

## 2. Minimality of the normal form

For all histories of length `≤ 4` over 2 atoms and over 3 atoms:

```
|normalForm ls|  =  #{ a : lastSign ls a ≠ none }      -- evaluated: true
max |normalForm ls| over all ls (2 atoms, length ≤ 4)  -- evaluated: 2
```

i.e. the normal form is exactly as long as the number of atoms mentioned, never longer.
Formalised as `normalForm_length_eq_card_support` and `normalForm_length_le`.

## 3. Counterexample hunt for the uniqueness/completeness claim

For every pair `(ls, ms)` of histories of length `≤ 3` (over 2 atoms: `85² = 7225` pairs;
over 3 atoms: `259² = 67081` pairs) we tested

```
lastSign ls = lastSign ms   ⟹   (normalForm ls).Perm (normalForm ms)
```

Both exhaustive tests evaluated to `true`; no counterexample exists in that range.  This is
the finite shadow of `normalForm_unique` (already available) and of the new completeness
theorem `histEq_iff_lastSign`, which upgrades "same record" to "connected by the two local
rewrite rules".

## 4. Non-commutativity and irreversibility

Evaluating the two composites of the records of `[(a,true)]` and `[(a,false)]` gives
`some false` versus `some true` at `a`: the monoid is non-commutative for every non-empty
atom set (`PartialAssign.not_commutative`).  No non-empty history ever has an inverse,
since composition never decreases the support (`PartialAssign.support_mul`,
`PartialAssign.isUnit_iff`).
