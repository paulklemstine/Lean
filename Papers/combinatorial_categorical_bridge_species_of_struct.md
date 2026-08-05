# Computational evidence

All numbers below were produced by a short Python script (exact integer / rational
arithmetic) *before* the Lean formalisation, to check that the intended statements are
true and correctly normalised.  They are evidence only; the authoritative statements are
the machine-checked theorems in `Bridges/SpeciesAnalyticBridge.lean`,
`Bridges/SpeciesAnalyticBridgeExtras.lean`, `Bridges/SpeciesUnlabelled.lean` and
`Bridges/SpeciesPartitions.lean`.

Throughout, `a_n = |F[n]|` is the number of `F`-structures on an `n`-element set and

    egf F = ∑ₙ a_n Xⁿ / n!.

## 1. Product rule (binomial convolution)

Claim (`Species.card_mul`): `|(F·G)[n]| = ∑_{k≤n} C(n,k)·|F[k]|·|G[n-k]|`, and hence
(`Species.egf_mul`) `egf (F·G) = egf F · egf G`.

| species            | a_0..a_7 (computed by convolution)     | closed form            | OEIS    |
|--------------------|----------------------------------------|------------------------|---------|
| `E` (sets)         | 1, 1, 1, 1, 1, 1, 1, 1                 | 1                      | A000012 |
| `S` (permutations) | 1, 1, 2, 6, 24, 120, 720, 5040         | n!                     | A000142 |
| `E·E` (subsets)    | 1, 2, 4, 8, 16, 32, 64, 128            | 2ⁿ                     | A000079 |
| `E·S`              | 1, 2, 5, 16, 65, 326, 1957, 13700      | ∑ C(n,k) k!            | A000522 |
| `E³`               | 1, 3, 9, 27, 81, 243, 729              | 3ⁿ                     | A000244 |

The `E·E` row is exactly the binomial identity `∑ₖ C(n,k) = 2ⁿ`
(`Species.sum_choose_eq`), and the `E^k` row is `∑ᵢ C(n,i) jⁱ k^{n-i} = (j+k)ⁿ`
(`Species.sum_choose_mul_pow`) and `exp(X)^k = exp(kX)` (`Species.exp_pow_eq_rescale`);
the rational coefficients `k^n/n!` were checked exactly for `k ≤ 4`, `n ≤ 7`.

## 2. Pointing and the derivative

Claim (`Species.card_pointing`): `|(X·F′)[n]| = n·|F[n]|`.

For `F = S`: computed `0, 1, 4, 18, 96, 600, 4320`, matching `n·n!` = `0, 1, 4, 18, 96,
600, 4320` (A001563).

## 3. Leibniz rule (`Species.card_deriv_mul`)

`|(F·G)′[n]| = |(F′·G)[n]| + |(F·G′)[n]|`.  For `F = S`, `G = E`, `n = 0..5` both sides
give `2, 5, 16, 65, 326, 1957`.

## 4. Unlabelled structures and Burnside

Claim (`Species.burnside`): `n! · u_n = ∑_{σ∈Sym(n)} |Fix F(σ)|`, where `u_n` is the
number of orbits.

For the species of permutations the action is conjugation, so `u_n` is the number of
conjugacy classes of `Sym(n)`, i.e. the partition numbers
`p(n) = 1, 1, 2, 3, 5, 7, 11, 15, 22` (A000041) — proved as
`Species.unlabelled_perm_eq_partitions`.  Burnside then reads
`∑_{σ∈Sym(n)} |centraliser(σ)| = n!·p(n)`
(`Species.sum_card_centralizer_eq`), e.g. for `n = 3`: `6 + 2 + 2 + 2 + 3 + 3 = 18 =
6·3`.

For the species `E` of sets every `Fix` is a singleton, so Burnside reads `n! = n!·1`,
consistent with `Species.unlabelled_set`.

## 5. Colourings, multisets and cycles

The species `colour k` (`A ↦ (A → Fin k)`) has `kⁿ` labelled structures, and its
unlabelled structures are multisets of colours, counted by `C(k+n-1,n)`
(`Species.unlabelled_colour_eq_choose`).  Burnside then gives the cycle-counting
identity `∑_{σ∈Sym(n)} k^{c(σ)} = C(k+n-1,n)·n!` (`Species.sum_pow_cycleCount`),
checked by brute force over all permutations for `n ≤ 6`, `k ≤ 3`:

| n | k | ∑_σ k^{c(σ)} | C(k+n-1,n)·n! |
|---|---|--------------|----------------|
| 2 | 2 | 6            | 3·2 = 6        |
| 3 | 2 | 24           | 4·6 = 24       |
| 3 | 3 | 60           | 10·6 = 60      |
| 4 | 3 | 360          | 15·24 = 360    |

## 6. Equipotent but non-isomorphic species

Linear orders `L` and permutations `S` both have `n!` structures, so
`egf L = egf S = 1/(1-X)`.  Their unlabelled counts differ already at `n = 2`:
`Sym(2)` acts transitively on the two linear orders of a 2-set (1 orbit), while it acts
trivially by conjugation on the two permutations (2 orbits).  Hence they are not
isomorphic (`Species.linOrd_not_iso_perm`).

## 7. Counterexample hunt

Two natural-looking but *false* variants were discarded early:

* `|F(X)|` for a finite set `X` is **not** given by the exponential generating series:
  for `X` a one-point set the analytic functor returns the *unlabelled* count
  (`∑ₙ u_n`), not `∑ₙ a_n/n!`.  This is why the bridge is formalised as an identity of
  formal power series (`egf`) and, separately, as the orbit-counting statement
  (`burnside`), rather than as a cardinality of an evaluated functor.
* The naive "derivative rule" `|F′[n]| = n·|F[n]|` is false (`|F′[n]| = |F[n+1]|`);
  the correct pointing statement needs the factor species `X`.

## 8. New species added in the follow-up work

The numbers in this section were obtained with Lean's evaluator (`#eval`) on Mathlib's
computable `numDerangements`, or are standard OEIS entries; as in the rest of this file
they are evidence only.  The authoritative statements are the machine-checked theorems in
`Bridges/SpeciesDerangements.lean`, `Bridges/SpeciesDerangementsUnlabelled.lean`,
`Bridges/SpeciesCycles.lean` and `Bridges/SpeciesPointing.lean`.

| species                     | a_0..a_8                                   | closed form  | OEIS    |
|-----------------------------|--------------------------------------------|--------------|---------|
| `D` (derangements)          | 1, 0, 1, 2, 9, 44, 265, 1854, 14833        | `D_n`        | A000166 |
| `C` (cycles)                | 0, 1, 1, 2, 6, 24, 120, 720, 5040          | `(n-1)!`     | A000142 |
| `D·E`                       | 1, 1, 2, 6, 24, 120, 720, 5040, 40320      | `n!`         | A000142 |

The third row is the binomial convolution `∑ₖ C(n,k)·D_k = n!`, checked by `#eval` for
`n ≤ 8` before being proved (`Species.sum_choose_numDerangements`); it is the counting
shadow of the species isomorphism `D · E ≅ S` (`Species.derangMulSetIso`), which gives
`egf D · exp X · (1-X) = 1`.

Unlabelled derangements are the partitions of `n` with no part equal to `1`
(`Species.unlabelled_derang`), i.e. `1, 0, 1, 1, 2, 2, 4, 4, 7, …` (A002865), while the
unlabelled cycles are `0, 1, 1, 1, 1, …` (all `n`-cycles are conjugate,
`Species.unlabelled_cyc`), giving the type generating series `X/(1-X)`.

## 9. Composition of species and the exponential formula

Before formalising `Species.comp` (substitution of species) and the exponential formula,
the recurrences that the formalisation produces were checked numerically with `#eval`
on Mathlib's computable `Nat.bell`, `Nat.factorial` and `numDerangements`
(`n ≤ 6` in each case).  These are evidence only; the machine-checked statements live in
`Bridges/SpeciesComposition.lean`, `Bridges/SpeciesExponentialFormula.lean` and
`Bridges/SpeciesCyclesDerangements.lean`.

| composite | `a_0 … a_7` | closed form | OEIS |
|-----------|-------------|-------------|------|
| `E ∘ E` (partitions) | 1, 1, 2, 5, 15, 52, 203, 877 | Bell numbers | A000110 |
| `E ∘ C` (sets of cycles) | 1, 1, 2, 6, 24, 120, 720, 5040 | `n!` | A000142 |
| `E ∘ C₂` (sets of long cycles) | 1, 0, 1, 2, 9, 44, 265, 1854 | derangements | A000166 |
| `E ∘ X` | 1, 1, 1, 1, 1, 1, 1, 1 | `1` | A000012 |

The recurrence produced by the derivative bijection,

    a_{n+1} = ∑_{k=0}^{n} C(n,k) · g_{k+1} · a_{n-k},

was checked in the three interesting cases:

* `g ≡ 1` (blocks are plain sets): `Bell(n+1) = ∑ₖ C(n,k) Bell(k)`, verified for `n ≤ 6`;
* `g_{k+1} = k!` (blocks are cycles): `∑ₖ C(n,k)·k!·(n-k)! = (n+1)!`, verified for `n ≤ 6`;
* `g_{k+1} = k!` for `k ≥ 1` and `g_1 = 0` (cycles of length ≥ 2):
  `D_{n+1} = ∑_{k≥1} C(n,k)·k!·D_{n-k}`, verified for `n ≤ 6`.

No counterexample was found, and each of the three identities is now a theorem
(`bell_succ_choose`, `card_comp_set_cyc`, `card_comp_set_cycGe2`).
