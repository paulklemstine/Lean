# Future Directions — Idempotent Probability: an Exact Large Deviation Theory

## Synthesis

This cycle built, from first principles, the backbone of an **exact (limit-free) large
deviation theory for max-plus (idempotent) probability measures**, in
`Catalog/Logic/IdempotentProbabilityLDP.lean`. An idempotent measure is a finite pair
`(pts, pot) : ι → ℝ`, where expectation is `sup`, multiplication is `+`, and the
idempotent cumulant generating function is `Λ(s) = supᵢ (potᵢ + s·ptsᵢ)` (`cumulant`).

The single structural mechanism that powers the whole theory is **distributivity of the
finite supremum over addition**: `sup'(x + y) = sup' x + sup' y` over a product index
(`sup'_prod_add`) and its iterated form `sup'_pi_sum` (sum-of-maxes equals max-of-sums,
witnessed by the *constant argmax trajectory*). Independence, in idempotent probability,
*is* this distributivity.

### Results summary (all proved, `sorry`-free, only standard axioms)

* `freeEnergy_bounds` — the uniform two-sided sandwich
  `max a ≤ t⁻¹·log ∑ exp(t·a) ≤ max a + t⁻¹·log(card)` for `t > 0`, built on the
  log-sum-exp toolkit of `Catalog/Logic/LogSumExp.lean` (`sup'_le_log_sum_exp`,
  `log_sum_exp_le_sup'_add_log_card`).
* `tropical_laplace_limit` — the semiclassical bridge: the free energy converges to the
  idempotent expectation `max a` as the inverse temperature `t → ∞`, by a pure squeeze
  with no probabilistic input.
* `cumulant_convexOn` — convexity of `Λ` (a finite sup of affine functions).
* `cumulant_conv` — exact additivity of `Λ` under max-plus convolution: `Λ_{μ⋆ν} = Λ_μ + Λ_ν`.
* `cumulant_convPow` — the **exact finite-`n` Cramér scaling** `Λ_{Sₙ} = n·Λ`.
* `fenchel_young` and `cumulant_eq_legendre` — the Fenchel–Young inequality and the
  discrete Legendre representation `Λ = I*` of the rate function `I = -pot`.

The following directions each extend this frontier and are concrete enough to refute
with a single counterexample or settle with a single Lean theorem.

## 1. Fenchel–Moreau biconjugation: the rate function is its own convex hull

Define the biconjugate `I**(z) = sup_s (s·z − Λ(s))`. Conjecture that `I**` equals the
lower convex hull of the discrete rate values `I(i) = -pot(i)` placed at the abscissae
`pts(i)`, and that `I**(pts i) = I(i)` *exactly* when the support point `(ptsᵢ, potᵢ)`
lies on the upper boundary of the Newton-style polygon of the atoms. Equality in
`fenchel_young` at a support atom should characterize the **exposed** atoms.

The key insight is that in idempotent probability the Fenchel–Moreau theorem is not an
asymptotic statement but a finite combinatorial fact about which atoms survive on the
upper convex boundary of the point cloud `(ptsᵢ, potᵢ)`. Why now? `cumulant_eq_legendre`
gives `Λ = I*` and `fenchel_young` gives the forward inequality; the only missing piece
is the reverse `sup`-over-`s` direction, which reduces to a finite convex-hull
extremality argument of exactly the shape the prover already discharged for the forward
bounds.

## 2. A Gärtner–Ellis theorem for the semiclassical limit

`tropical_laplace_limit` handles a *fixed* family. The Gärtner–Ellis upgrade replaces it
by a triangular array `a^{(t)} : ι → ℝ` with `a^{(t)}_i → a_i`, and conjectures that the
free energies converge to `max_i a_i`, i.e. `Tendsto (fun t => freeEnergy t a^{(t)})
atTop (𝓝 (max a))` whenever each entry converges and the temperature scales suitably.

The key insight is that the `log ∑ exp / max` sandwich in `freeEnergy_bounds` is
**uniform in the entries**, so convergence of the entries transfers directly to
convergence of the free energy with no probabilistic machinery. Why now? The two-sided
estimate is already isolated as `freeEnergy_bounds`; a uniform-in-`t` version is a
routine `Filter`-level strengthening of the squeeze already used in
`tropical_laplace_limit`.

## 3. Varadhan's lemma in the idempotent semiring

Conjecture the exact idempotent analogue of Varadhan's lemma: for a max-plus measure
`(pts, pot)` and any bounded test function `g : ℝ → ℝ`, the idempotent integral
`supᵢ (potᵢ + g(ptsᵢ))` equals `t → ∞` limit of `t⁻¹·log ∑ᵢ exp(t·(potᵢ + g(ptsᵢ)))`
**with no error term**, and equals `sup_x (g(x) − I(x))` over the support.

The key insight is that Varadhan's lemma *collapses*, in the `(max, +)` semiring, to the
defining property of `sup'`: the asymptotic integral literally **is** the idempotent
integral, so the variational formula becomes a definitional identity rather than a
theorem. Why now? `cumulant` is exactly the special case `g(x) = s·x`, and
`tropical_laplace_limit` already proves the `t → ∞` collapse for that `g`; generalizing
the test function reuses the same `freeEnergy_bounds` sandwich verbatim with `c_i =
pot_i + g(pts_i)`.

## 4. Contraction principle under affine push-forward

For an affine map `T(x) = scale·x + shift`, conjecture the exact cumulant transformation
`Λ_{T_* μ}(s) = Λ_μ(scale·s) + s·shift`, where `T_* μ` has atoms `T(ptsᵢ)` and the same
potentials. A clean falsifiable corollary: the empirical-mean map `Sₙ ↦ Sₙ/n` sends the
`n`-fold cumulant `n·Λ` (from `cumulant_convPow`) back to `Λ`, recovering an
`n`-independent rate.

The key insight is that contraction in idempotent probability is functoriality of `sup'`
under reindexing, so inf-convolution of rate functions corresponds to addition of
cumulants — exactly the additivity already proved in `cumulant_conv`. Why now? The hard
half (two-fold and `n`-fold additivity) is done in `cumulant_conv` and
`cumulant_convPow`; the affine push-forward is a one-line reparametrization of
`cumulant`.

## 5. Tropical Cramér rate for the empirical mean, with a sharp scaling law

Combining directions 1 and 4, conjecture the headline idempotent Cramér theorem: the
empirical mean of `n` i.i.d. max-plus steps has rate function `I = Λ_X*` **exactly for
every `n`**, and the deviation cost of observing mean `z` is `n·I(z)`, realized by the
constant argmax trajectory. The falsifiable sharpness claim: no trajectory achieves mean
`z` at cost strictly below `n·I(z)`, and the bound is attained, so the inequality in
`fenchel_young` becomes equality precisely on the convex hull of the support.

The key insight is that the linear scaling `Λ_{Sₙ} = n·Λ_X` from `cumulant_convPow`
forces the per-step rate to be `n`-independent, turning the classical *asymptotic* Cramér
statement into an *exact finite-`n`* law — the defining miracle of idempotent
probability. Why now? `cumulant_convPow` already delivers the exact `n`-scaling, and
`sup'_pi_sum` already exhibits the optimal constant-argmax trajectory, so the extremal
(attainment) half of Cramér is essentially constructed and only needs to be packaged as a
standalone optimality theorem.
