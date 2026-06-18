# Future Directions — Arithmetic Universality in Cellular Automata via p-adic Renormalization

## Synthesis

This cycle turned a sprawling physics-flavoured conjecture ("space-time evolution of a
cellular automaton converges, under scale-doubling renormalization, to a unique p-adic
analytic fixed point iff the automaton is computationally universal") into two rigorous,
machine-checked pillars and one explicit bridge between them.

* **Arithmetic pillar** (`Physics/PadicRenormalization.lean`). The scale-doubling
  renormalization step, once block-frequency generating functions are encoded into the
  complete ultrametric ring `ℤ_p`, is an *affine contraction* `R(x) = a + c·x` with
  `‖c‖ < 1`. We proved it is `ContractingWith ‖c‖₊`, that `1 - c` is automatically a
  unit, that the explicit fixed point `x⋆ = (1-c)⁻¹ a` exists *inside* `ℤ_p`, that it is
  unique, that iterates of every seed converge to it, and — sharper than the metric
  statement — that the error obeys the *exact* flow law `Rⁿ x₀ - x⋆ = cⁿ (x₀ - x⋆)`.
  The renormalization-group semigroup property `renorm_comp_self` shows one doubling
  squares the factor (`c ↦ c²`).

* **Dynamical pillar** (`Physics/CellularRenormalization.lean`). Additive (XOR / linear)
  one-dimensional CA — the canonical *non-universal* benchmark family — are closed under
  scale-doubling renormalization (`linStep_comp_self`: the two-step rule is the
  autoconvolution of the one-step rule), and Rule 90 is an *exact* renormalization fixed
  structure: `R90^[2^k] x i = x(i - 2^k) + x(i + 2^k)` (`R90_pow_two_pow`), the rigorous
  Sierpiński self-similarity, powered by the characteristic-2 identity `S_d ∘ S_d = S_{2d}`.

* **The bridge** (`CA_scale_eq_padic_norm_inv`). The CA spatial scale `2^k` produced by
  `2^k` renormalization steps equals the reciprocal of the 2-adic contraction factor
  `‖2^k‖₂ = 2^{-k}`. Discrete dynamics and p-adic arithmetic scale in literal lockstep,
  and `c ↦ c²` (arithmetic) mirrors `S_d ↦ S_{2d}` (dynamics).

## Results Summary

| Theorem | Content | Axioms |
|---|---|---|
| `renorm_contracting` | renormalization step is a Banach contraction | standard |
| `renorm_fixedPoint_isFixedPt` / `_unique` | unique explicit p-adic fixed point `(1-c)⁻¹ a` | standard |
| `renorm_iterate_sub` | exact ultrametric flow law `Rⁿx₀ - x⋆ = cⁿ(x₀-x⋆)` | standard |
| `renorm_tendsto_fixedPoint` / `renorm_p_tendsto` | convergence from every seed (general `c`; `c = p`) | standard |
| `renorm_comp_self` | scale doubling squares the contraction factor | standard |
| `linStep_comp_self` | additive class closed under renormalization (autoconvolution) | standard |
| `R90_pow_two_pow` | Rule 90 is exactly self-similar: `R90^[2^k] = S_{2^k}` | standard |
| `CA_scale_eq_padic_norm_inv` | CA scale `2^k` ↔ 2-adic norm `2^{-k}` (cross-domain) | standard |

No `sorry`, no nonstandard axioms.

## Bold, Falsifiable Research Directions

### 1. The contraction factor as a universality invariant

We proved additive (non-universal) rules are renormalization-closed with a *single*
contraction factor that squares cleanly under doubling. **Conjecture:** for an
elementary CA, encode the radius-`2^k` two-step coefficient vectors into `ℤ_p` and define
`κ(rule) = limsup_k ‖coeff_k‖_p^{1/2^k}` (the asymptotic p-adic contraction rate). Then
`κ < 1` for *every* additive/affine (non-universal) rule, while `κ = 1` (no contraction)
for Rule 110. The key insight is that universality requires *unbounded effective range
growth that is not algebraically self-convolving*, so the p-adic coefficient sequence
cannot contract — non-contraction is the arithmetic signature of computation. **Why now?**
`linStep_comp_self` already gives the exact convolution recursion for the additive case in
Lean; the only missing ingredient is a Lean definition of the general (nonlinear) two-step
coefficient tensor and a `limsup` over `ℤ_p`, both expressible with current Mathlib.

### 2. Characteristic-`p` collapse predicts the convergent class

`Sd_comp_self` works *only* in characteristic 2 (the middle `2·x(i)` term vanishes).
**Conjecture:** a linear CA over `𝔽_p` (alphabet size `p` prime) admits an exact
spacing-doubling self-similarity `S_d ∘ S_d = S_{p·?}`-type collapse iff its rule
coefficients lie in the "annihilated" locus where the autoconvolution middle band is
divisible by `p`; equivalently, the renormalization fixed structure exists iff the rule's
generating polynomial is a `p`-th power up to units in `𝔽_p[t, t^{-1}]`. The key insight
is that Frobenius `f(t) ↦ f(t)^p = f(t^p)` *is* the renormalization operator on additive
rules, so self-similarity is exactly Frobenius-stability. **Why now?** Mathlib has the
Frobenius endomorphism and `𝔽_p[t,t^{-1}]` (Laurent polynomials); `R90_pow_two_pow`
generalizes verbatim to `Rπ^[p^k] = S_{p^k}` once `2` is replaced by `p` and the
characteristic-`p` freshman's-dream lemma is invoked.

### 3. The exact flow law forbids "slow" universal convergence

Our `renorm_iterate_sub` gives error *exactly* `cⁿ` — geometric, never sub- or
super-geometric, a rigidity special to affine ultrametric maps. **Conjecture:** any CA
whose renormalization is genuinely universal cannot have a purely affine p-adic
renormalization; its error sequence `‖Rⁿ x₀ - x⋆‖` must be non-eventually-monotone (it
oscillates), and this oscillation is itself a decidable-in-the-limit certificate of
non-affinity hence of potential universality. The key insight is that affineness ⇒ exact
geometric decay ⇒ predictability, so *unpredictable p-adic error profiles are necessary
for universality*. **Why now?** The exact law is already formalized, so its negation gives
a crisp, testable dichotomy; one can compute the first `N` error norms for benchmark rules
in `ℤ_p` and check monotonicity — a finite, falsifiable experiment.

### 4. p-adic fixed points as conserved "renormalized densities"

`renorm_p_tendsto` produces a canonical limit `(1-p)⁻¹ a ∈ ℤ_p` for the scale-doubling
factor `c = p`. **Conjecture:** for additive CA this p-adic limit equals the p-adic
generating value `∑_n d_n p^n` of the rule's exact orbit-density sequence `d_n` (fraction
of live cells after coarse-graining `n` times), and is therefore a *conserved* arithmetic
invariant of the rule's renormalization-group trajectory — a "renormalized density"
living in `ℤ_p` rather than `[0,1]`. The key insight is that ordinary densities fail to
converge for self-similar CA (they oscillate in `ℝ`) but their `p`-adic generating
functions converge *because* coarse-graining is exactly multiplication by `p`. **Why now?**
The convergence is proved; what remains is to define `d_n` for Rule 90 (computable from
`R90_pow_two_pow`, since the support is explicit) and identify the limit, a concrete `#eval`-
checkable target before formalization.

### 5. Multiplicative renormalization and a Mahler-series spectral test

We used the *additive* affine model; the natural next operator is *multiplicative*,
`M(x) = a · x^{?}` or a Mahler-expansion renormalization on continuous `ℤ_p → ℤ_p`
functions. **Conjecture:** encoding the full local-pattern-count generating function of a
CA as a Mahler series `∑ c_k \binom{x}{k}` and renormalizing by scale doubling, the
Mahler coefficients `c_k` decay p-adically (`‖c_k‖ → 0`, i.e. the function is continuous)
*for all CA*, but they decay at a rate `‖c_k‖ ≤ ‖c‖^{deg(k)}` with a uniform `‖c‖ < 1`
*iff* the CA is non-universal; universal CA have continuous but non-Lipschitz Mahler
profiles. The key insight is that Mahler's theorem makes "p-adic analyticity" precise as
coefficient decay, turning the vague "p-adic analytic fixed point" of the original
conjecture into a measurable decay exponent. **Why now?** Mathlib now has `PadicInt`
continuity and the building blocks for Mahler bases; pairing them with the contraction
theory in `PadicRenormalization.lean` would make the original conjecture's central phrase
("p-adic analytic fixed point") a fully formal, falsifiable object for the next cycle.
