# Future Directions — EML Special Functions (Gamma, Zeta, Hypergeometric)

Derived from the verified results in `GammaEML.lean`, `ZetaEML.lean`, and
`HypergeometricEML.lean`. Each conjecture is falsifiable in Lean against the
existing Mathlib special-function API.

## 1. Singular-set cardinality is the EML/non-EML separator

**Conjecture.** For the classical meromorphic special functions, "EML-likeness"
is governed not by *whether* singularities exist but by the *cardinality and
arithmetic regularity* of the singular set: `Γ` (singular set `{-n : n ∈ ℕ}`,
infinite but arithmetic-progression-regular) and `ζ` (singular set `{1}`,
finite) are both meromorphic, but no entire reciprocal exists for `ζ` of the
`Γ`-type "all-pole" form.

*The key insight is...* that `gamma_recip_entire` together with
`zeta_singular_set_eq_singleton` shows the discriminating invariant is the zero
locus of the reciprocal germ, not the presence/absence of singularities — the
mission's "essential singularity" framing for `ζ` is simply false.

*Why now?* Mathlib now has `Meromorphic.Gamma`, `differentiable_one_div_Gamma`,
and `differentiableAt_riemannZeta`, so the comparison is fully formalizable
without re-deriving analytic continuation.

## 2. Termination ⇒ entirety, formalized as a decision procedure

**Conjecture.** `₂F₁(a,b;c;z)` is entire (as a function of `z`) **iff** at least
one of `a,b` is a non-positive integer (the series terminates). The forward
direction is `hgCoeff_terminates`; the converse (non-termination forces a
genuine `z=1` singularity) is the open half.

*The key insight is...* that `ascPochhammer_eval_neg_nat_eq_zero` makes
termination a purely algebraic, decidable condition on the numerator
Pochhammer, decoupled from convergence analysis.

*Why now?* The Pochhammer-based coefficient definition (`hgCoeff`) reduces an
analytic dichotomy to a finite vanishing test that Lean's `ring`/`omega`
machinery can certify.

## 3. The coefficient recurrence characterizes the Gauss operator's kernel

**Conjecture.** A formal power series `∑ aₙ zⁿ` is annihilated by the Gauss
operator `z(1-z)D² + (c-(a+b+1)z)D - ab` **iff** its coefficients satisfy the
recurrence proved in `hgCoeff_recurrence`; hence the kernel of the Gauss
operator inside `ℂ[[z]]` is at most 1-dimensional once `a₀` is fixed and
`c ∉ ℤ_{≤0}`.

*The key insight is...* that `hgCoeff_recurrence` is not merely *a* solution but
the *defining* two-term-to-one-term contraction, so uniqueness of the
holomorphic solution is a corollary of recurrence uniqueness.

*Why now?* With the recurrence verified denominator-free (`field_simp`+`ring`),
the uniqueness statement is a clean induction that needs no new analytic input.

## 4. EML-chain realizability of contiguous closed forms

**Conjecture.** Every Gauss-contiguous closed form of `₂F₁` that reduces to a
power `(1-z)^{-a}`, a logarithm, or a product thereof is realizable as a finite
EML chain (`Catalog/EML/KolmogorovArnoldEMLDeep.lean`), and the minimal chain
depth equals the number of independent transcendental factors.

*The key insight is...* `hypergeometric_powerChain_repr` shows the prototypical
closed form `(1-z)^{-a}` is *exactly* the depth-2 power chain; depth should then
be an additive invariant over contiguous products.

*Why now?* The catalog already proves `power_chain_eval`/`power_chain_depth`, so
depth lower bounds reduce to counting `exp`/`log` occurrences — a combinatorial,
formalizable quantity.

## 5. A reciprocal-entirety test for "no algebraic singularities"

**Conjecture.** A meromorphic `f : ℂ → ℂ` "has no algebraic singularities" in
the EML sense iff `1/f` extends to an entire function whose zero set is exactly
the pole set of `f` (as for `Γ` via `gamma_recip_vanishes_at_poles`). This fails
for `ζ` (its reciprocal is *not* entire near `1` in the all-pole sense), giving a
sharp algebraic separator.

*The key insight is...* entirety of the reciprocal is a single global
`Differentiable` statement, far more tractable in Lean than local branch-cut
non-existence, yet logically equivalent for meromorphic germs.

*Why now?* `differentiable_one_div_Gamma` is the only nontrivial ingredient and
is already in Mathlib; the conjecture turns a vague analytic slogan into a
checkable `Differentiable ℂ (f⁻¹)` proposition.
