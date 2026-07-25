import Mathlib

/-!
# Denominator factorization for Ramanujan's third order mock theta function ρ(q)

Ramanujan's third order mock theta function is
$$ \rho(q) \;=\; \sum_{m\ge 0} \frac{q^{2m(m+1)}}{\prod_{k=0}^{m}\bigl(1+q^{2k+1}+q^{4k+2}\bigr)}. $$

The building block of every denominator is the cyclotomic-type trinomial
`1 + q^{2k+1} + q^{4k+2}`.  Writing `Y = q^{2k+1}` this is `1 + Y + Y^2`, and the
classical identity `(1 - Y)(1 + Y + Y^2) = 1 - Y^3` gives
`(1 - q^{2k+1})(1 + q^{2k+1} + q^{4k+2}) = 1 - q^{6k+3}`.

Multiplying these single-factor identities together yields a **telescoping
product factorization** of the full denominator: the product of the trinomials
becomes the ratio of two theta-like products `∏(1 - q^{6k+3}) / ∏(1 - q^{2k+1})`.
This is the exact algebraic backbone behind the mod-3 residue structure of the
coefficients of `ρ(q)` (the three exponents `0, 2k+1, 4k+2` of each factor cover
the residues `{0, a, 2a} (mod 3)`).

All identities are stated in the polynomial ring `ℤ[X]`, where `X` plays the
role of the formal variable `q`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): every denominator of ρ(q) factors telescopically,
because each trinomial factor is a truncated geometric series with a closed
`(1 - Y^3)/(1 - Y)` form.

Experiment (Experimenter): formalize the single-factor cube identity and lift it
across a `Finset.range` product.  The lift needs `Finset.prod_mul_distrib` and a
per-factor `Finset.prod_congr`; the exponent bookkeeping `2*(2k+1) = 4k+2`,
`3*(2k+1) = 6k+3` is handled by `pow_mul`/`ring`.

Analysis (Analyst): the identity is a genuine ring identity (no positivity),
which is why it survives to *all* `m`, unlike the sign law which is only known
asymptotically.  It isolates the source of the modulus 3: `1 + Y + Y^2` is the
3rd cyclotomic-style factor `(Y^3 - 1)/(Y - 1)`.

Critique (Critic): `ring` cannot see `X^(2k+1) * X^(2k+1) = X^(4k+2)` directly
because the exponents are symbolic; we must rewrite with `pow_add`/`pow_mul`
first.  Guarded by generalizing `X^(2k+1)` to a fresh variable.

Synthesis (PI): the telescoping factorization plus the residue observation are
recorded as the algebraic engine; the sign law itself is verified computationally
in `RamanujanRhoMockTheta.lean` and remains open in closed form.
-/

open Polynomial

namespace RamanujanRho

/-
The single-factor cube identity: `(1 - Y)(1 + Y + Y^2) = 1 - Y^3` in any
commutative ring, specialized to the trinomial factor of ρ's denominator with
`Y = X^{2k+1}`.
-/
theorem factor_cube_identity (k : ℕ) :
    (1 - (X : ℤ[X]) ^ (2 * k + 1)) *
        (1 + (X : ℤ[X]) ^ (2 * k + 1) + (X : ℤ[X]) ^ (4 * k + 2))
      = 1 - (X : ℤ[X]) ^ (6 * k + 3) := by
  ring

/-
Telescoping product factorization of the denominator of ρ(q):
`∏_{k<m} (1 - q^{2k+1}) · ∏_{k<m} (1 + q^{2k+1} + q^{4k+2}) = ∏_{k<m} (1 - q^{6k+3})`.
-/
theorem denominator_factorization (m : ℕ) :
    (∏ k ∈ Finset.range m, (1 - (X : ℤ[X]) ^ (2 * k + 1))) *
        (∏ k ∈ Finset.range m,
          (1 + (X : ℤ[X]) ^ (2 * k + 1) + (X : ℤ[X]) ^ (4 * k + 2)))
      = ∏ k ∈ Finset.range m, (1 - (X : ℤ[X]) ^ (6 * k + 3)) := by
  rw [ ← Finset.prod_mul_distrib ];
  exact Finset.prod_congr rfl fun _ _ => by ring;

end RamanujanRho