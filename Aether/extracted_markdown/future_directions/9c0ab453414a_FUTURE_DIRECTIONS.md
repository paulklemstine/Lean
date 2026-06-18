# Future Directions — Functorial Tropical Certificate for the Berggren–Lorentz Monoid

This cycle established a **functorial tropical (min-plus) growth certificate** for the
Berggren monoid action on positive Pythagorean triples
(`Catalog/Algebra/BerggrenLorentz/TropicalCertificate.lean`):

- a monoid homomorphism `tropCert : (List (Fin 3), ++, []) → (Tropical (WithTop ℕ), *, 1)`
  whose underlying value is the `B`-count (`tropCert_append`, `tropCert_untrop`);
- the certified lower bound `3 ^ (Bcount w) · c ≤ hyp (applyWord w (a,b,c))` for every
  positive Pythagorean seed (`applyWord_hyp_growth`), with exponential corollaries
  (`seed_hyp_growth`, `pureB_exponential`).

The following conjectures are concrete, falsifiable targets for the next cycle. Each is
stated so that it can be entered as a Lean `theorem ... := by sorry` and attacked
directly.

## Conjecture 1 (Two-sided tropical certificate / matching upper bound)
There is a *universal per-step expansion ceiling*: for every positive Pythagorean `t`
and every letter `k`, `(childGen k t).2.2 ≤ 7 * t.2.2`. Consequently the certificate is
two-sided:
`hyp (applyWord w t) ≤ 7 ^ (w.length) * t.2.2`.
Sharper: replacing the crude `7^length` by a tropical product that distinguishes
`B` (ceiling `7`) from `A,C` (ceiling growing only additively) should give
`hyp (applyWord w t) ≤ C · (1 + w.length) ^ 2 · 3 ^ (Bcount w) · t.2.2`
for an absolute constant `C`, matching the lower bound up to a polynomial factor.
*Test:* prove the `≤ 7 * c` per-step bound (likely `nlinarith`), then the
`7 ^ length` corollary by the same telescoping induction used for the lower bound.

## Conjecture 2 (Exact tropical eigenvalue / Lyapunov exponent)
Define the tropical (max-plus) growth rate of a word `w` as
`ρ(w) = log (hyp (applyWord w (3,4,5))) / w.length`. Then along any *periodic* word
`w = u^n` the limit `lim_{n→∞} ρ(u^n)` exists and equals `log λ(u)`, where `λ(u)` is the
spectral radius of the real matrix product `wordMatrix u`. For the pure `B`-word,
`λ = 3 + 2√2`. *Test (Lean-friendly discretization):* prove the rational two-sided
bound `3 ^ (n·Bcount u) ≤ hyp((u^n) · seed) / hyp(seed) ≤ 7 ^ (n·u.length)` and that the
`B`-only normalized rate is squeezed into `[log 3, log 7]`; refine toward `3+2√2`.

## Conjecture 3 (Certificate determines coarse orbit geometry)
The tropical certificate is a *complete* coarse invariant of hypotenuse growth: if two
words `w₁, w₂` satisfy `tropCert w₁ = tropCert w₂` (equal `B`-count) **and** equal length,
then for every positive Pythagorean seed the two hypotenuses are within a bounded ratio:
`hyp(applyWord w₁ t) / hyp(applyWord w₂ t) ∈ [r, 1/r]` for an absolute `r > 0` depending
only on the common length. *Test:* establish the per-letter commensurability
`c ≤ (childGen k t).2.2 ≤ 7c` (Conj. 1) and deduce the ratio bound `7^(-length)` by
telescoping; then try to improve the exponent.

## Conjecture 4 (Functoriality lifts to all coordinates, not just the hypotenuse)
Extend the certificate from the hypotenuse to the full triple in the `ℓ¹` size
`N(t) = t.1 + t.2.1 + t.2.2`. Conjecture: `3 ^ (Bcount w) · N(t) ≤ N(applyWord w t)` for
all positive Pythagorean `t`. (The Lab Notes record that the *perimeter* attempt was
abandoned for the hypotenuse; the conjecture is that with the correct constant the
perimeter/`ℓ¹`-size bound is in fact recoverable, just with a messier per-step proof.)
*Test:* prove the per-step facts `N(t) ≤ N(childGen k t)` for all `k` and
`3·N(t) ≤ N(childGen 1 t)`, then telescoping gives the result verbatim.

## Conjecture 5 (Tropical certificate as a faithful monoid grading ⇒ word-problem hardness)
The pair `(parity, tropCert)` — the `ℤ/2` determinant grading from `Core.lean` together
with the tropical `B`-count — refines to a *faithful* invariant on the abelianization:
two words have the same image under `w ↦ (wordParity w, Bcount w, w.length)` iff their
matrices `wordMatrix` are equal modulo the (conjectured free) relations of the monoid.
Equivalently, the Berggren monoid is free on `{A,B,C}` and the tropical certificate is
the canonical grading by the `B`-generator. *Test:* (a) prove freeness by exhibiting a
faithful action / ping-pong on the light cone; (b) prove the certificate is invariant
under the (empty) relation set, hence well defined on the monoid, giving an
`ML`-flavoured **hardness certificate**: recovering `w` from `wordMatrix w` costs
`Ω(3 ^ Bcount w)` orbit work.
