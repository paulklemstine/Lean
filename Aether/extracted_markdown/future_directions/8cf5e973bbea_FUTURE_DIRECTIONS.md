# Future Directions: Maslov Dequantization of ReLU / Softmax Networks

This cycle delivered `TropicalMaslovDequantization.lean`, which upgrades the
two-element Maslov bridge of `TropicalNNBridge.lean`
(`maslov_dequantization_lower_two`, `maslov_dequantization_upper_two`) to the
full *n*-element finite setting:

```
  max_{i∈s} aᵢ  ≤  ε·log Σ_{i∈s} exp(aᵢ/ε)  ≤  max_{i∈s} aᵢ + ε·log |s|
```

with the exact error band (`maslov_gap`) and the low-temperature limit
(`maslov_tendsto`): `ε·log Σ exp(aᵢ/ε) → max aᵢ` as `ε → 0⁺`. Together these
make precise the folklore that *softmax aggregation is a smoothing of tropical
(max-plus) aggregation*, and that the smoothing error is controlled linearly by
the temperature times the log of the number of competing units. The directions
below extend this quantitative dictionary.

---

## Direction 1 — Optimal-temperature certified rounding

**Conjecture.** For a fixed activation vector `a : ι → ℝ` over a finite set `s`
and a target additive tolerance `τ > 0`, the softmax aggregate `ε·log Σ exp(aᵢ/ε)`
is within `τ` of the tropical maximum for *every* `ε ≤ τ / log|s|`, and this
threshold is order-optimal: there exist activation vectors for which the error
exceeds `τ` once `ε > c·τ / log|s|` for an absolute constant `c`.

The key insight is that `maslov_gap` already proves the upper half exactly
(`error ≤ ε·log|s|`), so the *only* missing ingredient is a matching family of
hard instances — and the hardest instances are the *flat* ones where all `aᵢ`
are equal, for which the gap is identically `ε·log|s|`. This converts a
qualitative limit into a deployable, certified rounding rule.

Why now? `maslov_gap` and `maslov_tendsto` are in place, so the lower-bound
construction (a single `example` with `a = const`) is the last brick; it is a
finite computation rather than a new analytic theory.

---

## Direction 2 — Lipschitz stability of the smoothed aggregator in the activations

**Conjecture.** The map `a ↦ ε·log Σ_{i∈s} exp(aᵢ/ε)` is `1`-Lipschitz in the
`ℓ∞` norm on `ι → ℝ`, uniformly in `ε > 0`, and this constant is exactly the
same as the (trivially `1`-Lipschitz) tropical `max`. Hence dequantization
**never amplifies** input perturbations.

The key insight is that both endpoints of the `maslov_gap` band — the tropical
max and `max + ε·log|s|` — are `1`-Lipschitz in `a`, and the smoothed quantity
lives between two translates of the same `1`-Lipschitz function, so a sandwich
argument transfers the modulus of continuity without recomputing derivatives.

Why now? Robustness certificates for ReLU/attention layers (cf.
`Tropical/Tropical_Certified_Robustness_for_Multi_Class_ReLU_Networks.lean`)
need exactly a temperature-independent Lipschitz bound on the aggregator; the
finite-`n` lower/upper bounds proved this cycle make the sandwich rigorous.

---

## Direction 3 — Compositional dequantization for deep stacks

**Conjecture.** Composing `L` softmax/log-sum-exp layers, each over at most `w`
units at temperature `ε`, approximates the corresponding `L`-fold tropical
(max-plus) composition with total additive error at most `L · ε · log w`,
i.e. the per-layer gap of `maslov_upper` adds rather than multiplies.

The key insight is that `1`-Lipschitzness from Direction 2 makes the per-layer
errors compose additively: a layer cannot blow up the error inherited from the
layer below, so the global gap is the sum of `L` copies of the single-layer
`ε·log w` bound — connecting directly to the depth–width counting bounds
`depth_width_asymmetry` and `region_bound_product` of `TropicalNNBridge.lean`.

Why now? With the single-layer gap (`maslov_gap`) and the prospective Lipschitz
bound (Direction 2), the induction on depth is mechanical, and it would yield
the first end-to-end smooth-vs-tropical error bound for a *whole* network rather
than a single neuron.

---

## Direction 4 — Entropic correction term and the exact second-order expansion

**Conjecture.** As `ε → 0⁺`, the dequantization gap has the exact first-order
expansion
```
  ε·log Σ exp(aᵢ/ε) − max aᵢ  =  ε · log m + o(ε),
```
where `m = |argmax_{i∈s} aᵢ|` is the multiplicity of the maximizer (so the gap
vanishes faster, with leading coefficient `0`, precisely when the argmax is
unique).

The key insight is that only the maximizing summands survive the `ε → 0⁺` limit
after factoring out `exp(max/ε)`; the surviving sum is exactly `m`, refining the
coarse `ε·log|s|` upper bound of `maslov_upper` into a sharp `ε·log m`.

Why now? `maslov_tendsto` pins down the zeroth-order limit; the natural next
question — *the rate* — is now well-posed, and the multiplicity-`m` refinement
is the cleanest possible sharpening of the bound proved this cycle.

---

## Direction 5 — Tropical Jensen / concavity of the temperature profile

**Conjecture.** For fixed activations, the function `ε ↦ ε·log Σ exp(aᵢ/ε)` is
**nonincreasing** and **convex** on `(0, ∞)`, decreasing monotonically from
`max aᵢ + ` (its `ε→∞` linear growth) down to the tropical limit `max aᵢ` as
`ε → 0⁺`.

The key insight is that this is the `ε`-scaled cumulant generating function of a
finite measure, whose convexity in the inverse-temperature `β = 1/ε` is the
classical Hölder/Jensen inequality; reparametrising through `ε·log` preserves
the monotone descent witnessed by `maslov_tendsto`.

Why now? Monotonicity in `ε` would make `maslov_gap` a *telescoping* family of
bounds (smaller temperature ⇒ provably tighter), turning the single-temperature
estimate proved this cycle into a one-parameter certified annealing schedule.
