# Future Directions — Braiding Universality (Extensions)

This cycle extended `BraidingUniversality` with a constructive group-theoretic
upgrade of the reduced Burau representation of `B₃` (explicit inverses, the
scalar/central full twist `t³·I`, its Markov trace `2t³`) and the sharp
*order* dichotomy on the maximal torus (rational phase ⇒ finite order;
irrational phase ⇒ injective orbit), complementing the parent file's *density*
dichotomy. Below are five concrete, falsifiable directions that build on this.

## 1. Burau is a genuine group homomorphism `B₃ → GL₂(ℂ)`

We have the braid relation (`burau_braid_relation`) and two-sided invertibility
(`burauSigma₁_mul_inv`, `burau_isUnit₁`). The missing step is to package these
into an actual monoid/group homomorphism out of a presented `B₃` (e.g. via
`PresentedGroup` or `FreeGroup` quotient) into `GL (Fin 2) ℂ`, and prove the
center generator `(σ₁σ₂)³` maps to the scalars (already proved pointwise as
`burau_fullTwist_scalar`). **The key insight is** that all the *relations* needed
for a well-defined homomorphism are already discharged as matrix identities, so
the only remaining work is the universal-property plumbing, not new mathematics.
**Why now?** Mathlib's `PresentedGroup`/`FreeGroup.lift` API is mature, and the
relation lemma is in hand, so this is a self-contained formalization win that
turns scattered matrix facts into a first-class representation object reusable
by every downstream Jones-polynomial result.

## 2. Faithfulness of reduced Burau on `B₃` (the `n=3` Bigelow regime)

Reduced Burau is known to be faithful for `n ≤ 3` and unfaithful for `n ≥ 5`.
Formalize the positive `n=3` case: the homomorphism of Direction 1 is injective.
**The key insight is** that for three strands the image can be analyzed through
the explicit `2×2` matrices and the ping-pong lemma on the action on the
hyperbolic plane / a suitable tree, reducing faithfulness to a free-product
sub-structure already partly visible in the non-commuting generators. **Why
now?** Mathlib has the ping-pong lemma (`FreeGroup`/`PingPongLemma`) and the
matrices are fully explicit here, making `n=3` faithfulness a realistic target
that would be the first formal faithfulness result for any braid representation.

## 3. Specialization to a unitary representation at a root of unity

The Jones representation becomes unitary when `t = e^{2πi/r}` lies on the unit
circle. Formalize: at such `t`, the Burau generators (suitably normalized) are
unitary, so the image lands in `U(2)` and, after fixing determinants, in
`SU(2)`. **The key insight is** that the eigenphase data computed here
(`burau_det₁ = -t`, full twist `= t³·I`) already pins the determinant and global
phase, so unitarity reduces to a single Gram-matrix positivity condition at
`|t|=1`. **Why now?** This is the precise bridge from the algebra we proved to
the still-open `su2_braiding_dense` conjecture in the parent file: it produces
the *concrete* candidate `SU(2)` generators whose density is the missing step.

## 4. Two-phase density and effective Solovay–Kitaev rates on the torus

`irrational_phase_injective` shows a single irrational phase generates a free
`ℤ`; combine two phases `α, β` and characterize when `{nα + mβ mod 1}` is dense
(iff `1, α, β` are `ℚ`-linearly independent), then attach an *effective*
approximation rate via the three-distance / continued-fraction theory. **The key
insight is** that universality is quantitative: density alone is the qualitative
shadow of a `1/N` worst-case approximation rate governed by the continued-fraction
expansion of the phase, which Mathlib's `Real` and `Nat.fib`/convergent API can
express. **Why now?** Effective Solovay–Kitaev bounds are the actually-useful form
of universality for compilation, and the injectivity/finite-order dichotomy proved
here is exactly the qualitative base case to make quantitative.

## 5. Markov trace ⇒ a formal Jones polynomial invariant of closures

`burau_fullTwist_trace = 2t³` is one data point of the (normalized) Markov trace.
Define the normalized trace `V(braid) = (−t)^{−w} · (something) · tr(Burau(braid))`
with writhe `w`, prove Markov-move invariance (conjugation invariance of trace +
stabilization), and obtain a genuine link invariant for closures of `B₃` braids.
**The key insight is** that `trace` is already conjugation-invariant in Mathlib
(`Matrix.trace_mul_comm`), so Markov move I is free; only the stabilization move
needs the explicit `2×2` structure, which the scalar full twist makes tractable.
**Why now?** No formal Jones polynomial exists in Mathlib; restricting to `B₃`
closures via the explicit reduced Burau gives a minimal, fully computable first
formalization, directly extending the trace lemma proved this cycle.
