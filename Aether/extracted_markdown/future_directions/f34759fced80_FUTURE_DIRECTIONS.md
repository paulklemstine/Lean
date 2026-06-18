# FUTURE DIRECTIONS — Functorial Tropical Automorphic Height on the Berggren Tree

Follow-up conjectures generated from the results in
`Catalog/Bridges/BerggrenTropicalHeight.lean`. Each is stated to be precise and
falsifiable, with a suggested Lean target. Notation: `tropHeight`, `step`, `orbit`,
`PosPythag` refer to that file; `t₀` is a positive-light-cone seed (e.g. `(3,4,5)`).

---

## C1. Sharp two-sided (sandwich) growth and the spectral ratio `3+2√2`

We proved a **lower** sandwich: `tropHeight t < tropHeight (step i t)` (uniform) and
`3 · tropHeight t ≤ tropHeight (step 1 t)` along `B`. Conjecture the matching **upper**
bound and the exact asymptotic ratio.

- **C1a (upper bound).** For every `i` and `PosPythag t`: `tropHeight (step i t) ≤ 7 · tropHeight t`,
  hence `tropHeight (orbit f t₀ n) ≤ 7^n · tropHeight t₀`. (Lean: `step_height_upper`,
  `orbit_height_upper`.) This refines `BerggrenLorentz.hypB_upper_bound`.
- **C1b (spectral ratio).** The all-`B` branch height grows like the dominant eigenvalue
  of `matB`, namely `λ_B = 3 + 2√2`: for some constants `0 < c₁ ≤ c₂`,
  `c₁·λ_B^n ≤ (tropHeight (orbit (fun _=>1) t₀ n) : ℝ) ≤ c₂·λ_B^n`. The lower factor `3`
  proved in `orbitB_exp_lower` is `< λ_B ≈ 5.828`, so this is a strict sharpening.
  **Falsifiable:** if any branch beats `λ_B^n` (resp. lags `3^n`) infinitely often, C1b
  (resp. our theorem) is wrong.

## C2. Boundary ultrametric (bridge to `CategoricalTropicalUltrametric`)

The strictly-monotone height functor (`height_strictMono`) should reconstruct a genuine
**ultrametric** on the boundary `∂T = (Fin 3)^ℕ` of the tree, realizing the functorial
"tropical → ultrametric" transfer of `Bridges/CategoricalTropicalUltrametric.lean`.

- **C2.** Define `d(f,g) = λ_B^{-(length of longest common prefix of f,g)}`. Conjecture
  `d` is an ultrametric, and the height functor is `1`-Lipschitz for `d` in the sense that
  agreement of the first `k` branch-choices forces the first `k` orbit heights to coincide.
  **Falsifiable:** exhibit `f,g` agreeing on a prefix whose orbits diverge earlier than the
  prefix length.

## C3. Height zeta / counting function of the tree

Every depth-`n` level has exactly `3^n` nodes (the tree is freely ternary), and heights
are unbounded and collision-free per branch (`height_injective`, `height_linear_lower`).

- **C3.** The node-counting function `N(X) = #{nodes v : tropHeight v ≤ X}` satisfies
  `N(X) = Θ(X^α)` with `α = log 3 / log λ_B = log 3 / log(3+2√2)`. Equivalently the height
  zeta `Z(s) = Σ_v tropHeight(v)^{-s}` has abscissa of convergence exactly `α`.
  **Falsifiable:** a different measured exponent refutes the predicted `α`.

## C4. Descent: height as a well-founded termination measure to the root

The inverse generators (`invA, invB, invC` in `BerggrenLorentz.Core`) define a parent map.

- **C4.** On `PosPythag` triples other than `(3,4,5)` the (unique) parent map strictly
  **decreases** `tropHeight`, so `tropHeight` is a well-founded measure: every positive
  primitive Pythagorean triple reaches `(3,4,5)` in `O(log (tropHeight))` descent steps.
  (Lean: a `WellFoundedRecursion` / `termination_by tropHeight` Berggren-descent function,
  plus `parent_height_lt`.) **Falsifiable:** a positive triple whose parent has height
  `≥` its own would break well-foundedness.

## C5. Higher Lorentz cones `O(d,1;ℤ)` and other ternary trees

Our height monotonicity used only (i) hypotenuse dominance and (ii) positivity preservation.

- **C5.** The same functorial tropical-height monotonicity holds for any finitely generated
  submonoid of `O(d,1;ℤ)` acting on the positive integral light cone `x₁²+···+x_d² = x_{d+1}²`
  whose generators preserve positivity, with `tropHeight = max_i x_i` again equal to the
  time-like coordinate on the cone. In particular it holds for the Barning–Hall and Price
  ternary trees and for the `d=3` (Eulerian-brick-adjacent) cone.
  **Falsifiable:** a positivity-preserving `O(d,1;ℤ)` generator that fails to raise the
  max-coordinate on some cone point refutes C5.
