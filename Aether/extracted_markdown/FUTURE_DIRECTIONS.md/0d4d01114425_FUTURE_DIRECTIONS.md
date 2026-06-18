# Future Directions — Weight-Threshold Profiles & the Codes → Tropical Valuation Functor

Derived from the research cycle recorded in
`Catalog/Novelty/ThresholdDirectSum.lean`, `Catalog/Novelty/ThresholdEnumerator.lean`,
and `Catalog/Novelty/OrderValuation.lean`, which extend
`Catalog/Speculative/AutoResearch/CodeThresholdValuation.lean`.

## What this cycle established (and refuted)

* **Conjecture 4 (direct sum) — corrected and proved.** The naive max-plus law
  `tprof (append a b) = max (tprof a) (m + tprof b)` is **false** at `b = 0`
  (`tprof_append_naive_counterexample`). The corrected law
  `tprof (append a b) = if b = 0 then tprof a else m + tprof b`
  (`tprof_append_eq`, `tprof_append_maxplus`) holds for all blocks, with the laxity
  isolated entirely in the right-block unit.
* **Conjecture 1 (tropical enumerator) — partly refuted.** `maxWtProfile` and
  `thresholdCount` are monotone for every code (`maxWtProfile_mono`,
  `thresholdCount_mono`), but for `hamming` the tropical enumerator is **not concave**
  (`hamming_maxWtProfile_not_concave`) and its breakpoints `{3,7}` are **not** the
  attained `tprof` values `{0,4,6,7,8}` (`hamming_breakpoints_ne_tprofValues`). Only the
  *count* of jumps (`= 2 = 1 + d/4`) survived (`hamming_maxWtProfile_jumpCount`).
* **Conjecture 3 (ultrametric MacWilliams) — refuted.** On the self-dual `hamming`,
  `N_C(r)·N_C(8−r)` is not constant (`hamming_macwilliams_nonconstant`).
* **Conjecture 5 (order valuation) — confirmed.** `ord` is a dual ultrametric valuation
  (`ord_add_ge`) and is multiplicative up to truncation,
  `ord (x·y) = min (ord x + ord y) n` (`ord_cmul`), with the `min … n` shown essential
  (`ord_cmul_truncation_failure`).

---

## Direction 1 — `tprof` is the *initial* lax-monoidal code valuation

**Conjecture.** Among all functors `(FinLinCodes, ⊕) → (ℕ, max, +)` that are additive on
codewords and lax-monoidal with laxity supported only at the unit, `tprof` is initial:
every other such valuation factors uniquely through it.

*The key insight is* that this cycle pinned the laxity of `tprof ⊕` to **exactly the
right-block zero** (`tprof_append_eq`): the lax-monoidal structure map is an isomorphism
away from the unit, which is the categorical signature of an initial object.

*Why now?* We have, for the first time, a closed-form direct-sum law with the corner case
explicitly quantified, so the comparison maps to other valuations are now writable and
mechanically checkable.

*Falsifiable by* exhibiting an additive `ℕ`-valued ultrametric code valuation whose
direct-sum laxity is **not** unit-supported, i.e. that does not factor through `tprof`.

## Direction 2 — `B^{val}` is a genuine multiplicative ultranorm into `ℝ`

**Conjecture.** For any base `B > 1`, the map `x ↦ B^{val x}` with `val x = n − ord x` is a
*multiplicative* nonarchimedean seminorm on `F₂[t]/(tⁿ)`:
`‖x·y‖ = ‖x‖·‖y‖` whenever `ord x + ord y < n`, landing codes in the catalog's full
`CategoricalTropicalUltrametric.UltraNormObj` (the axiom `tprof` could not meet).

*The key insight is* that `ord_cmul` already gives `ord (x·y) = ord x + ord y` below the
truncation length, so the exponential turns the additive `ord` into an exactly
multiplicative norm; the only obstruction is truncation, which `B^{val}` records as a
*sub*multiplicative defect above degree `n`.

*Why now?* `ord_cmul` is the missing multiplicative law identified in the parent file's
failure analysis; with it proved, the bridge into `UltraNormObj`/`valuationReconstruct`
is a finite formalization away.

*Falsifiable by* finding `x, y` with `ord x + ord y < n` and `‖x·y‖ ≠ ‖x‖·‖y‖`, which
`ord_cmul` predicts cannot exist.

## Direction 3 — the true breakpoint invariant is the *weight spectrum*, not `tprof`

**Conjecture.** For every binary code, the number of jumps of the tropical enumerator
`maxWtProfile C` equals `(#distinct nonzero Hamming weights of C)`, and its jump *heights*
are exactly the gaps of the weight spectrum — independent of the `tprof` value set.

*The key insight is* that this cycle showed the extra `tprof` values `6, 7` carry **no new
maximum weight** (`hamming_breakpoints_ne_tprofValues`): the enumerator sees the weight
spectrum, while `tprof` measures degree, so the two filtrations are genuinely different.

*Why now?* The explicit `hamming` profile `0,0,0,0,4,4,4,4,8` (3 distinct values, weight
spectrum `{0,4,8}`) is the first computed witness aligning jumps with weights and divorcing
them from `tprof` values.

*Falsifiable by* a code where the jump count of `maxWtProfile` differs from the number of
distinct nonzero weights.

## Direction 4 — a *degree-graded* duality replaces the failed MacWilliams identity

**Conjecture.** The linear product MacWilliams identity fails for `tprof`
(`hamming_macwilliams_nonconstant`), but the generating function
`Z_C(q) = Σ_{c∈C} q^{tprof c}` satisfies a `q`-MacWilliams transform relating `Z_C` and
`Z_{C⊥}` through the *order* valuation `ord` (degree-from-the-bottom), not `wt`.

*The key insight is* that `tprof` and `ord` are the top/`sup` and bottom/`inf` ends of the
same coordinate filtration; duality should swap the two ends (`tprof ↔ n − ord`), so the
correct dual pairing is degree-reversal, not weight-complementation.

*Why now?* We now possess *both* ends of the filtration as proved valuations
(`tprof_add_le` and `ord_add_ge`/`ord_cmul`), making the conjectured `tprof ↔ ord` duality
concretely testable on `hamming` and `hamming ⊕ hamming`.

*Falsifiable by* computing `Z_C` and `Z_{C⊥}` on a non-self-dual code and checking no
degree-reversal transform links them.

## Direction 5 — laxity-free direct sums characterise *prefix-saturated* codes

**Conjecture.** The corrected direct-sum law degenerates to the *naive* max-plus law
(no `b = 0` correction needed on codewords) **iff** the right summand `D` is
"prefix-saturated": every threshold `t ≤ n` is attained by some codeword of `D`.

*The key insight is* that the laxity in `tprof_append_eq` is triggered only by the zero
codeword of the right block; a code with no "threshold gaps" never exposes the corner case
on its nonzero codewords, so its direct sums look strictly additive.

*Why now?* The explicit corner-case analysis of `tprof_append_eq` lets us state exactly
which codes hide the laxity, turning a definitional subtlety into a structural code
property.

*Falsifiable by* a prefix-saturated code whose direct sum still violates the naive law on a
nonzero codeword, or a non-saturated code that obeys it.
