# FUTURE DIRECTIONS — Functorial tropical valuation profiles of topological CSS codes

Follow-up conjectures arising from `Catalog/Applications/SmoothPoincare/TropicalCSSProfiles.lean`,
which proved (sorry-free):

- the two-line law `twe C t = min ((minWt C)·t) ((maxWt C)·t)` and its max-plus dual;
- the profile gap `twePlus C t − twe C t = (maxWt C − minWt C)·|t|`;
- concavity of `twe` / convexity of `twePlus`;
- functoriality `minWt (C ⊕c D) = minWt C + minWt D`, `maxWt (C ⊕c D) = maxWt C + maxWt D`
  (the profile `C ↦ (minWt C, maxWt C)` is a monoid hom `(codes, ⊕c) → (ℕ², +)`);
- CSS commutation closure `appendCode_crossOrthogonal` and the redundancy product law
  `cssRedundancy (CX ⊕c DX) (CZ ⊕c DZ) = cssRedundancy CX CZ · cssRedundancy DX DZ`;
- the `hamming`–`hamming` CSS code (mod-2 shadow of `E8`) with redundancy `2^8`.

The following are precise, testable conjectures for the next cycle.

## Conjecture 1 (Tensor multiplicativity of the valuation profile)
Define a tensor (Kronecker) product of binary codes `C ⊗ D ⊆ (Fin (m·n) → ZMod 2)`
whose codewords are the outer products of codewords. Then the valuation profile is
*multiplicative* under `⊗`, complementing its additivity under `⊕c`:
`minWt (C ⊗ D) = minWt C · minWt D` and `maxWt (C ⊗ D) = maxWt C · maxWt D`.
Consequently the profile `C ↦ (minWt C, maxWt C)` upgrades from a `(⊕c, +)`-monoid
homomorphism to a *semiring* homomorphism `(codes, ⊕c, ⊗) → (ℕ, +, ·)`, i.e. a genuine
tropical valuation functor. Falsifiable: exhibit codes with
`minWt (C ⊗ D) ≠ minWt C · minWt D`.

## Conjecture 2 (Saturation rigidity of `maxWt`)
For a nonempty binary code `C ⊆ (Fin n → ZMod 2)`, `maxWt C = n` **iff** the all-ones
word `ones n ∈ C`. In particular, for a self-dual code, `maxWt C = n` iff `C` is
self-complementary (closed under adding `ones n`), which by `selfDual_doublyEven` forces
`4 ∣ n`. This pins the upper slope of the tropical profile to a single membership test.

## Conjecture 3 (CSS quantum distance is a tropical-min invariant)
Define the CSS quantum distance of a commuting pair `(CX, CZ)` as the least weight of a
nonzero element of `CZ^⊥ \ CX` together with its `X/Z` mirror. Conjecture: under direct
sum the CSS distance obeys the tropical-min law
`cssDistance (CX ⊕c DX, CZ ⊕c DZ) = min (cssDistance (CX, CZ)) (cssDistance (DX, DZ))`,
exactly as `minDist_append` does for classical codes. For the `hamming`–`hamming` pair
this should certify the parameters `[[8, 0, 4]]` (distance `4`), so that the direct sum
`[[16, 0, 4]]` does **not** improve distance — the quantum analogue of `hamming16_minDist`.

## Conjecture 4 (Gleason saturation ⇒ length divisibility)
If a commuting CSS pair `(CX, CZ)` on `n` qubits saturates redundancy,
`cssRedundancy CX CZ = 2^n` (i.e. `k = 0` logical qubits), and both `CX, CZ` are
doubly even, then `8 ∣ n`. This is the CSS-level lift of Gleason's theorem
(`doublyEven_selfDual_length_div_eight`): saturation forces each code to be self-dual,
so the existing Gleason machinery applies. Falsifiable by any `k = 0` doubly-even CSS
code of length not divisible by `8`.

## Conjecture 5 (Profile collapses the Newton polygon; `minDist` is irrecoverable)
The map `C ↦ (twe C, twePlus C)` factors through `(minWt C, maxWt C)` (proved), hence is
*blind* to every interior weight stratum. Conjecture: there exist two doubly-even
self-dual codes `C, C'` of the same length with identical tropical profiles
`(minWt, maxWt) = (0, n)` but different minimum distances `minDist C ≠ minDist C'`. This
would prove the tropical valuation profile is strictly coarser than the weight
distribution `wexact`, making precise that `minDist`/`wexact` are not functions of the
profile — the quantitative statement of the "information loss" observed for `hamming`.
