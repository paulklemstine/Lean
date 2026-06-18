# Future Directions — PAC-Bayes / Generalization Bounds

## Synthesis

This cycle attacked the *foundations* of machine-learning generalization bounds rather
than their decorative consequences. The catalog already contained
`MachineLearning/PACBayes/Bounds.lean` (the McAllester and Catoni risk bounds), but
every one of those theorems was stated *conditionally*: the probabilistic heart of the
argument was smuggled in as an unproven hypothesis (`h_change_of_measure`,
`h_exp_moment`). In other words, the catalog proved the easy algebra and assumed the
hard inequality.

The new file `Catalog/MachineLearning/PACBayes/DonskerVaradhan.lean` removes that
crutch on a finite hypothesis space. It proves, from `import Mathlib` alone and with
zero `sorry`:

* `kl_nonneg` — Gibbs' inequality (KL divergence is nonnegative);
* `gibbs_decomposition` — the exact identity
  `E_q[f] − KL(q‖p) = log Z − KL(q‖q*)`;
* `gibbs_variational_le` — the Donsker–Varadhan upper bound, i.e. *the* PAC-Bayes
  change-of-measure inequality that `Bounds.lean` had merely assumed;
* `gibbs_posterior_attains` — the Gibbs posterior `q* ∝ p·e^f` makes the bound tight;
* `donsker_varadhan` — the variational principle in `IsGreatest` form: the
  log-partition function is the *greatest* value of the PAC-Bayes objective;
* `pac_bayes_change_of_measure` — the rearranged inequality directly consumable by the
  catalog's Catoni/McAllester machinery.

The unifying discovery is that the *slack* in every PAC-Bayes bound is literally a KL
divergence against the Gibbs posterior. Optimality and KL-nonnegativity are the same
theorem viewed from two sides.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `kl_nonneg` | `0 ≤ KL(q‖p)` for distributions `p,q` | proved |
| `gibbs_decomposition` | `E_q[f] − KL(q‖p) = log Z − KL(q‖q*)` | proved |
| `gibbs_variational_le` | `E_q[f] − KL(q‖p) ≤ log Z` | proved |
| `gibbs_posterior_attains` | equality at `q*` | proved |
| `donsker_varadhan` | `IsGreatest` characterization | proved |
| `pac_bayes_change_of_measure` | `E_q[f] ≤ KL(q‖p) + log Z` | proved |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Falsifiable Research Directions

### 1. Discharge the assumed `h_exp_moment`: a *fully unconditional* Catoni bound

Conjecture: by composing `gibbs_variational_le` with a finite-sample sub-Gaussian
concentration lemma for the per-sample loss gap (a Hoeffding-style bound on
`log E_P[e^{λ·gap}]`), the hypothesis `h_exp_moment` in
`PACBayes.pac_bayes_catoni_bound` becomes a *theorem*, yielding a Catoni risk bound
with no probabilistic side conditions left unproven. The key insight is that
`log Z` in our development is exactly the cumulant generating function whose only
remaining ingredient is a one-dimensional Hoeffding lemma — everything else (the
change of measure, the optimal posterior) is now formally in hand. Why now? The
variational core is proved and the McAllester/Catoni *algebra* already exists in
`Bounds.lean`, so the only missing brick is a scalar concentration inequality, which
Mathlib's `MeasureTheory` and `Probability` libraries can now supply.

### 2. Compression ⇒ small KL ⇒ sample complexity

Conjecture: if a predictor is `k`-compressible (its Gibbs posterior `q*` is supported,
up to `ε`, on a sub-family of size `2^k`), then `KL(q*‖p) ≤ k·log 2 + o(1)`, and hence
`pac_bayes_change_of_measure` gives a generalization gap of order `√((k·log 2)/n)`.
The key insight is that compression and PAC-Bayes are not two competing bound families
but one: a compression scheme *is* a low-entropy posterior, and our
`gibbs_decomposition` measures that entropy as a KL term exactly. Why now? With
`kl_nonneg` and the decomposition identity proved, a compression bound reduces to a
clean upper estimate on a single KL divergence over a finite support — no new analytic
machinery required, only counting.

### 3. Overparameterization helps via posterior concentration

Conjecture: in a width-`m` linear/NTK model, as `m → ∞` the optimal Gibbs posterior
`q*` concentrates on the interpolating manifold while `KL(q*‖p)` stays *bounded*
(independent of `m`), so by `pac_bayes_change_of_measure` the generalization gap does
**not** grow with width — overparameterized nets provably generalize. The key insight
is that width inflates the *prior* and the *posterior* in lockstep, so their KL
difference, the only quantity that controls the bound, is width-stable. Why now? The
catalog's `NTKSpectral` file supplies the spectral description of the infinite-width
kernel, and our DV principle supplies the exact complexity functional; bridging them
turns an empirical folklore claim into a falsifiable, formal statement.

### 4. Uniqueness and strict tightness of the variational principle

Conjecture: `donsker_varadhan` can be sharpened to a *uniqueness* statement — the
maximizer of `E_q[f] − KL(q‖p)` is the Gibbs posterior and is unique, because
`KL(q‖q*) = 0 ⇔ q = q*`. The key insight is that strict convexity of `x ↦ x log x`
makes Gibbs' inequality an *equality* exactly at coincidence, so the PAC-Bayes optimum
is a single point, not a face. Why now? `kl_nonneg` is already proved by a pointwise
`log x ≤ x − 1` estimate; upgrading the pointwise inequality to its strict form
(`<` unless `x = 1`) immediately yields the equality-characterization and hence
uniqueness.

### 5. From finite Ω to general measure spaces

Conjecture: the entire development lifts verbatim from `Fintype Ω` to a probability
space `(Ω, μ)` using Mathlib's `MeasureTheory.integral` and Radon–Nikodym derivatives,
recovering the classical Donsker–Varadhan formula
`log ∫ e^f dμ = sup_ν (∫ f dν − KL(ν‖μ))`. The key insight is that every step here is
already measure-theoretic in spirit: `∑` becomes `∫`, `gibbsPosterior` becomes a
tilted measure with density `e^f / Z`, and `gibbs_decomposition` is an identity about
densities that does not use finiteness. Why now? Mathlib's KL-divergence
(`MeasureTheory.klDiv` / `Measure.rnDeriv`) reached maturity in recent versions, so the
finite proof can serve as a checked blueprint for the continuous theorem.
