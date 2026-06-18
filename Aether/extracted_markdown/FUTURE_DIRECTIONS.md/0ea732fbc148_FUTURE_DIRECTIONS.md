# Future Directions: Moonshine Trace Dominance and the Monster Modular Weight

The new file `Computation/MoonshineMonsterProduct.lean` turns the catalog's
*unproven* predicate `MoonshineDatum.traceDominance` (from
`Physics/MonstrousMoonshine.lean`) into a **theorem**: under the single
representation-theoretic input `|χ_i(g)| ≤ χ_i(1) = dim ρ_i`, the identity
McKay–Thompson series `T_e(q)` dominates every twisted series `T_g(q)`
coefficient-by-coefficient (`traceDominance_of_charBound`). Alongside it we
proved the moonshine L²-identity `∑_j |C_j| a_m(g_j)² = |G| ∑_i mult(i,m)²`
(`mckay_coeff_sq_sum`), the Cauchy–Schwarz bound
`gradedDim(m)² ≤ |G| · ∑_i mult(i,m)²` (`gradedDim_sq_le_order_mul_sumSq`),
and the integrality of the conjectural Monster modular weight `|M|/24`
(`monsterOrder_eq_24_mul_weight`). The following directions extend this work;
each is concrete, testable, and falsifiable.

## 1. Strict trace dominance and the spectral gap

Conjecture: trace dominance is **strict** away from the identity class —
`|a_m(g)| < a_m(e)` for every non-identity `g` and every grade `m` with
`a_m(e) > 0`, provided some irrep `ρ_i` with `mult(i,m) > 0` is *faithful*
(so `|χ_i(g)| < dim ρ_i`). The key insight is that the equality case of the
triangle inequality used in `abs_mckayCoeff_le_gradedDim` forces every active
character value `χ_i(g)` to lie on the same ray as `dim ρ_i`, which a faithful
character forbids; the deficit is governed by `dim ρ_i − |χ_i(g)|`. Why now? The
non-strict bound is already formalized as `abs_mckayCoeff_le_gradedDim`, so the
strict refinement is a localized upgrade of one inequality step — no new theory
is required, only a quantitative version of `Finset.abs_sum_le_sum_abs`.

## 2. A Plancherel-type lower bound on the group order

Conjecture: combining the L²-identity with positivity gives, for every grade `m`
with at least one nonzero multiplicity, the order bound
`|G| ≥ gradedDim(m)² / ∑_i mult(i,m)²`, with equality iff exactly one irrep
occurs in `V_m`. The key insight is that `gradedDim_sq_le_order_mul_sumSq` is the
identity-class term of `mckay_coeff_sq_sum`, so the *gap* between the two sides is
exactly `∑_{g ≠ e} |C_g| a_m(g)²` — a manifestly non-negative "off-identity
energy" whose vanishing pins down the single-irrep case. Why now? Both sides are
already proven; the remaining work is to divide by `∑_i mult(i,m)²` under a
positivity hypothesis and characterize the equality locus via
`Finset.sum_eq_zero_iff`.

## 3. Formal-power-series packaging of the McKay–Thompson family

Conjecture: assembling the coefficients `a_m(g)` into `PowerSeries ℚ` makes
`g ↦ T_g` a ring homomorphism-compatible family for which `T_e` coefficient-wise
dominates the absolute value of every `T_g`, and the "graded character"
`m ↦ (a_m(g))_g` is a class function for each `m`. The key insight is that all
the finite-sum identities proved here are *grade-local*, so they lift verbatim to
`PowerSeries.coeff`-level statements without any analytic convergence input. Why
now? Mathlib's `PowerSeries` API (`PowerSeries.coeff`, `PowerSeries.ext`) lets us
restate `traceDominance` and `mckay_coeff_sq_sum` as series-level theorems by
quantifying the existing lemmas over `m`, giving a clean algebraic skeleton for
the eventual Hauptmodul story.

## 4. The "Monster product" weight from the class-number identity

Conjecture: for any moonshine system the formal product `∏_g T_g(q)^{1/|C(g)|}`
has a well-defined leading weight equal to `|G|/24` **exactly when** `24 ∣ |G|`,
and for the Monster this weight is the natural number `monsterModularWeight`
proven here. The key insight is that the weight is additive over the product and
the exponent bookkeeping reduces to the single divisibility
`monsterOrder = 24 · monsterModularWeight`, already established
(`monsterOrder_eq_24_mul_weight`). Why now? With the integrality lemma in hand,
the next concrete step is purely combinatorial: define the weight as a `ℚ`-linear
functional on the multiset of conjugacy-class data and prove it lands in `ℕ`
under the `24 ∣ |G|` hypothesis, with the Monster as the headline instance.

## 5. Generalizing the character bound to virtual and graded characters

Conjecture: trace dominance survives for *virtual* characters
`χ = ∑ n_i χ_i` (with `n_i ∈ ℤ`) precisely when the positive part dominates,
i.e. `∑_i max(n_i, 0)·dim ρ_i` controls `|χ(g)|`; and it fails as soon as a
negative multiplicity makes the identity coefficient smaller than a twisted one.
The key insight is that the proof of `abs_mckayCoeff_le_gradedDim` only used
`mult(i,m) ≥ 0`, so replacing `ℕ`-multiplicities by `ℤ`-multiplicities isolates
exactly which sign patterns preserve dominance — a sharp boundary case. Why now?
The current `mult : Fin n → ℕ → ℕ` field can be relaxed to `ℤ` with a single
positivity hypothesis, making this a minimal structural perturbation of the
existing development that immediately exposes the counterexample boundary
(a system with one negative multiplicity violating dominance).
