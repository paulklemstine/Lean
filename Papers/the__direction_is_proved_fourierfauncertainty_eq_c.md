# Computational evidence

All experiments below were run before/alongside the Lean formalisation, on cyclic groups
`G = ℤ/n` with the standard DFT `f̂(j) = Σ_x f(x) e^{-2πi jx/n}`.  They are *exploratory*
(floating-point, exhaustive over finite alphabets) and are **not** a substitute for the Lean
proofs; every statement asserted as a theorem in `Catalog/Novelty/*.lean` is machine-checked and
sorry-free.

## 1. Exhaustive search: extremals of `|supp f| · |supp f̂| ≥ |G|`

Alphabet `A = {0, 1, −1, i, −i, (1+i)/√2}`, all functions `f : ℤ/n → A`, `f ≠ 0`.

| n | # nonzero functions tested (6ⁿ−1) | # extremals found | all extremal supports a coset? | all spectra a coset? | `|f|` flat on `supp f`? | `|f̂|` flat on `supp f̂`? | `‖f‖₁ = |f(x)|·|supp f|`? |
|---|---|---|---|---|---|---|---|
| 2 | 35 | 19 | yes | yes | yes | yes | yes |
| 3 | 215 | 20 | yes | yes | yes | yes | yes |
| 4 | 1295 | 55 | yes | yes | yes | yes | yes |
| 5 | 7775 | 30 | yes | yes | yes | yes | yes |
| 6 | 46655 | 76 | yes | yes | yes | yes | yes |
| 8 | 1679615 | 127 | yes | yes | yes | yes | yes |

No counterexample was found to any of:

* `|supp f| · |supp f̂| ≥ |G|` (Donoho–Stark; already in the catalog);
* extremal ⇒ `supp f` is a coset of a subgroup (formalised as
  `FourierFA.IsExtremal.mem_supp_iff_sub_mem` / `IsExtremal.card_supp_dvd`);
* extremal ⇒ `supp f̂` is a coset in the dual (formalised as
  `FourierFA.supp_dft_coset_modulation`);
* extremal ⇒ `|f|` constant on `supp f` with `|f(x)|·|supp f| = ‖f‖₁`
  (formalised as `FourierFA.IsExtremal.norm_eq_l1norm`);
* extremal ⇒ `|f̂(ψ)| = ‖f‖₁` on the spectrum
  (formalised as `FourierFA.IsExtremal.norm_dft_eq_l1norm`).

This is precisely the content of the rigidity theorem
`FourierFA.extremal_iff_isCosetModulation`, which is now proved in full generality (arbitrary
finite abelian `G`, not only cyclic).

## 2. Counterexample hunt: is *bi-flatness* sufficient?

Since every extremal is flat on its support **and** has a flat Fourier transform on its
spectrum, one may conjecture the converse.  Exhaustive search over the alphabet
`{0, 1, −1, i, −i}` immediately falsifies it:

| n | # bi-flat functions | # bi-flat but **not** extremal | smallest witness |
|---|---|---|---|
| 2 | 24 | 8 | `f = (1, i)`, `|f̂| = (√2, √2)`, product `4 > 2` |
| 3 | 28 | 12 | `f = (0, 1, −1)`, `|f̂| = (0, √3, √3)`, product `4 > 3` |
| 4 | 112 | 64 | `f = (0, 1, 0, i)`, `|f̂| ≡ √2`, product `8 > 4` |
| 5 | 84 | 60 | `f = (0, 1, −1, −1, 1)`, product `16 > 5` |
| 6 | 312 | 248 | `f = (0,0,0,1,0,−1)`, product `8 > 6` |

So bi-flatness is *far* from sufficient.  The Lean file
`Catalog/Novelty/FourierBiflatCounterexample.lean` upgrades this observation from sporadic
numerical examples to a uniform theorem: on the self-dual group `G = K × K̂` the evaluation
pairing `f(x, ψ) = ψ(x)` is unimodular with unimodular transform (`|f| ≡ 1`, `|f̂| ≡ |K|`) and
has uncertainty product `|G|²`, the *maximum* possible
(`FourierFA.biflat_not_sufficient`).

## 3. The arithmetic dichotomy in prime order

For `n = 2, 3, 5` every extremal found in the search has `|supp f| ∈ {1, n}`, i.e. it is a
scaled Dirac delta or a scaled character — matching
`FourierFA.extremal_classification_of_prime`.  For `n = 4, 6, 8` intermediate support sizes
occur, and they are exactly the divisors of `n` (`2` and `4` for `n = 8`), matching
`FourierFA.IsExtremal.card_supp_dvd` and its sharpness
(`FourierFA.exists_isExtremal_supp_eq`).

## 4. The gap above the extremal locus

For `n = 6` and `|supp f| = 3` the observed uncertainty products are `6` (extremal) and then
`9, 12, …` — never `7` or `8`; for `n = 8`, `|supp f| = 4` gives `8` then `12`.  This is the
integrality phenomenon proved as `FourierFA.uncertainty_gap_of_not_cosetModulation`:
once `|supp f|` divides `|G|`, a non-extremal function must overshoot by at least `|supp f|`.

## 5. OEIS

The counts of extremal functions above are alphabet-dependent (they count representatives with
entries in a finite set of roots of unity) and are therefore not intrinsic sequences; no OEIS
match was sought.  The intrinsic count — the number of *supports* of extremals, i.e. the number
of cosets of subgroups of `ℤ/n`, `Σ_{d | n} d` = `σ(n)` — is OEIS A000203 (`1, 3, 4, 7, 6, 12,
8, 15, …`), which agrees with the classification: supports are exactly cosets
(`FourierFA.exists_isExtremal_supp_eq` together with `IsExtremal.mem_supp_iff_sub_mem`).
