# Future Directions — Species Generating Functions ↔ Probability Laws

Derived from this cycle's findings in `Probability/SpeciesBoltzmannBridge.lean` and
`Probability/SpeciesGeometricBridge.lean`, which established the **Boltzmann functor**
`species → EGF → (evaluate at x, normalize) → probability law` and pinned down two of its
values:

* species of **sets** `E` (EGF `exp`)            ↦ **Poisson** `poissonPMFReal x`,   mean `x`;
* species of **linear orders** `L` (EGF `1/(1-X)`) ↦ **Geometric** `geometricPMFReal (1-x)`, mean `x/(1-x)`.

The general normalization (`boltzmann_tsum_eq_one`), `[0,1]` bounds, and the
**pointing ↔ mean** identity (`boltzmannMean_eq`, the probabilistic shadow of the catalog's
Euler operator `X·d/dX` from `EGF_pointedSpecies`) are all proved `sorry`-free.

---

## Conjecture 1 — Cycles ↦ logarithmic / Ewens family

The species of **cyclic permutations** `C` has counting sequence `(n-1)!` and EGF
`log(1/(1-X))`.  Conjecture: its Boltzmann size law is the **logarithmic distribution**
`P_x(N=n) = xⁿ / (n · (-log(1-x)))`, with mean `x / ((1-x)·(-log(1-x)))`, and the
composite `E ∘ C` (sets of cycles = permutations) realizes the **Ewens sampling formula**
at `θ = 1`.

* **The key insight is** that exponentiating an EGF (`E ∘ F`, the "sets-of-`F`"
  construction) is exactly the *compound-Poissonization* of the Boltzmann law of `F`: the
  number of `F`-components is Poisson, so the species exponential formula `exp(F̂)` *is* the
  probabilistic compounding `E[ s^{ΣᵢXᵢ} ] = exp(F̂(s)−F̂(1))`.
* **Why now?** The two base cases (`E`, `L`) are already formalized here, and Mathlib has
  `Real.log`, its power-series expansion, and `tsum` machinery — the only new analytic input
  is `Σ xⁿ/n = −log(1−x)`, which is in reach.

## Conjecture 2 — The exponential formula is compound Poissonization (PGF form)

For any species `F` with partition function `F̂`, the Boltzmann law of `E ∘ F` ("sets of
`F`-structures") has **probability generating function** `exp(F̂(xs) − F̂(x)) `, i.e. the size
is a Poisson(`F̂(x)`)-compound of the `F`-component-size law.

* **The key insight is** that the catalog's *multiplicative* EGF bridge `egf_mul`
  (binomial convolution ↦ product) becomes, after normalization, the *convolution of
  independent random variables* — so the species product is probabilistic independence and
  the species exponential is i.i.d. compounding.
* **Why now?** `egf_mul` and `egf_card_prodSpecies` are already proved in the catalog;
  upgrading "product of EGFs" to "independent sum of Boltzmann variables" only needs the
  `tsum`-level Cauchy-product/`Summable.mul` lemmas already in Mathlib.

## Conjecture 3 — Boltzmann means are exactly logarithmic derivatives

For every species `F` with positive radius of convergence, the Boltzmann mean is
`x · (d/dx) log F̂(x) = x·F̂′(x)/F̂(x)` on the whole convergence interval, and the *variance*
is `x·(d/dx)(x·F̂′(x)/F̂(x))`.

* **The key insight is** that `boltzmannMean_eq` already identifies the mean with
  `(pointed EGF)/EGF`; recognizing the numerator `Σ n aₙ xⁿ/n!` as `x·F̂′(x)` turns the mean
  into a logarithmic derivative, so *all* Boltzmann moments are read off cumulants of `log F̂`.
* **Why now?** We proved the `n=1` (mean) case unconditionally up to a summability side
  condition; Mathlib's `HasSum`/term-by-term differentiation of power series
  (`HasDerivAt` for `tsum`) makes the general logarithmic-derivative statement attackable.

## Conjecture 4 — Critical Boltzmann samplers and heavy tails

At the radius of convergence `ρ` of `F̂`, whenever `F̂(ρ) < ∞` but `F̂′(ρ) = ∞` (the
"critical" case), the Boltzmann law at `x = ρ` is a genuine PMF whose **mean is infinite**;
for `L` this is the boundary `x → 1⁻` where `x/(1-x) → ∞`.

* **The key insight is** that the convergence of `F̂` and the divergence of its derivative
  decouple — finiteness of the partition function (a PMF exists) does *not* imply finite
  expectation, exactly the heavy-tail phenomenon driving polynomial-size random structures.
* **Why now?** `partition_linOrdLike` and `boltzmannMean_linOrdLike` already exhibit the
  finite-`F̂` / blowing-up-mean dichotomy explicitly on `[0,1)`; the critical statement is the
  limit of theorems we have in hand.

## Conjecture 5 — Maximum-entropy characterization of the Boltzmann law

Among all probability laws on `ℕ` with a fixed expected size `m = Σ n·pₙ` and weights
proportional to `aₙ/n!`, the Boltzmann law `boltzmannPMFReal a x` (with `x` chosen so the
mean equals `m`) is the **unique maximizer of the (relative) entropy** `−Σ pₙ log(pₙ·n!/aₙ)`.

* **The key insight is** that the `xⁿ` factor is precisely the Gibbs/Lagrange exponential
  weight enforcing the mean constraint, so the Boltzmann sampler is the categorified
  max-entropy (Gibbs) measure — explaining *why* uniform-by-size generation factors through it.
* **Why now?** Mathlib's convexity and `Real.log` infrastructure (Jensen, `inner_le_nnorm`,
  strict concavity of `log`) suffices to run the standard Gibbs variational argument against
  the normalization identity `boltzmann_tsum_eq_one` proved this cycle.
