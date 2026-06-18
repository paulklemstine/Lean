# FUTURE_DIRECTIONS — Willmore Energy Lower Bounds by Genus

## Synthesis

This cycle attacked the Willmore-conjecture-by-genus theme from the only angle that is
currently rigorous in Lean/Mathlib. Mathlib has no immersions, no mean curvature, and no
Willmore functional, so a literal "prove `W ≥ 2π²` for tori" is not yet formalizable. The
structural insight that made progress possible is that *the entire genus-by-genus story is
organized by three real constants and one decay law*: the universal sphere bound `4π`, the
Marques–Neves torus value `2π²`, and the Kuwert–Li–Schätzle asymptotic supremum `8π`,
together with the empirical fact that the infima `β_g` increase monotonically and converge
to `8π`. We isolated this arithmetic/analytic skeleton and proved it completely: the three
thresholds are genuinely strictly ordered (`4π < 2π² < 8π`), an explicit calibrated model
sequence `willmoreBound g = 8π − 4π·(2/5)^g` reproduces every known structural constraint
(value `4π` at genus 0, strict monotonicity, staying below `8π`, convergence to `8π`, and
the genus-1 consistency `≥ 2π²`), and the Li–Yau multiplicity inequality is captured in its
exact arithmetic form — the gateway `4πk < 8π ⟹ k = 1` that Marques–Neves use to reduce to
the embedded case.

What failed first was the naive decay ratio `1/2`: it gives `willmoreBound 1 = 6π ≈ 18.85`,
which violates the Marques–Neves consistency requirement `β_1 ≥ 2π² ≈ 19.74`. This forced a
quantitative discovery — the decay ratio `r` must satisfy `r ≤ 2 − π/2 ≈ 0.429`. Choosing
`r = 2/5` is the cleanest rational ratio below that ceiling, and it ties the torus value and
the asymptotic value together in a single formula. That tiny constraint is the cycle's most
transferable lesson: any honest interpolating model of `β_g` is *not* free; it is pinned at
both ends and at genus 1, and the genus-1 pin is the binding one.

The directions below push two ways: (i) toward making the model less ad hoc by deriving the
admissible decay-ratio window from the known geometric data, and (ii) toward importing more
of the genuine Li–Yau / area-comparison content as the supporting Mathlib analysis matures.

## Results Summary

- `sphere_lt_clifford`: proved — `4π < 2π²`, the genus-0 bound is strictly below the torus bound.
- `clifford_lt_asymptotic`: proved — `2π² < 8π`, the torus bound is strictly below the asymptotic supremum.
- `willmore_threshold_chain`: proved — the full ordering `4π < 2π² < 8π` of the three Willmore thresholds.
- `willmoreBound_zero`: proved — the model attains the universal bound `4π` at genus 0.
- `willmoreBound_strictMono`: proved — the model is strictly increasing in genus (monotone Willmore-by-genus).
- `willmoreBound_lt_asymptotic`: proved — the model stays strictly below `8π` for every genus.
- `willmoreBound_ge_sphere`: proved — every genus has model energy at least `4π`.
- `willmoreBound_genus_one_ge_clifford`: proved — model genus-1 energy respects the Marques–Neves bound `2π²`.
- `willmoreBound_increment`: proved — the per-genus energy gain equals `4π·(2/5)^g·(3/5)`, positive and geometrically decaying.
- `willmoreBound_tendsto`: proved — the model converges to `8π` as genus `→ ∞`.
- `liYau_embedded`: proved — Li–Yau energy below `8π` forces multiplicity `1`, i.e. embeddedness.
- `liYau_high_multiplicity`: proved — a multiplicity `≥ 2` point has Li–Yau energy bound `≥ 8π`.
- `willmoreBound_pos_genus_ge_clifford`: proved — model energy is `≥ 2π²` for all positive genus (higher-genus Marques–Neves, model form).

## Research Directions

### Direction 1: Characterize the admissible decay-ratio window
**Hypothesis**: For a one-parameter model `β_r(g) = 8π − 4π·r^g` with `0 < r < 1`, the
constraints `β_r(0) = 4π`, `β_r(g) → 8π`, strict monotonicity, and `β_r(1) ≥ 2π²` hold
simultaneously **iff** `0 < r ≤ 2 − π/2`. Moreover `2 − π/2` is the unique ratio for which
the genus-1 constraint is an equality (the Clifford torus is exactly hit).
**Test**: Formalize `β_r` as a function of a real parameter `r` and prove the iff, plus the
equality-case statement `β_(2−π/2)(1) = 2π²`. Both reduce to the inequalities already used
here (`Real.pi_lt_d2`, `Real.pi_gt_three`) plus a monotonicity-in-`r` argument.
**Why now**: This cycle already discovered the numerical ceiling `2 − π/2 ≈ 0.429` as the
binding constraint; turning that observation into a theorem removes the arbitrariness of the
choice `2/5` and yields a *characterization* rather than an example.
**If true**: The model becomes canonical up to the single free parameter `r`, and any future
geometric input (e.g. a proven value of `β_1` or `β_2`) pins `r` uniquely.
**If false**: Some constraint is not monotone in `r`, revealing that the four constraints are
not jointly captured by a single geometric decay — a signal to use a richer model family.

### Direction 2: Genus-additivity (connect-sum) lower bound
**Hypothesis**: The Willmore infima satisfy a strict subadditivity gap
`β_{g+h} < β_g + β_h − 4π` for all `g, h ≥ 1` (reflecting that connect-summing two surfaces
"shares" one `4π` sphere's worth of energy), and the model `willmoreBound` satisfies the
corresponding inequality `willmoreBound (g+h) < willmoreBound g + willmoreBound h − 4π`.
**Test**: Prove the model inequality directly from `willmoreBound g = 8π − 4π(2/5)^g`; it
reduces to `(2/5)^(g+h) > (2/5)^g + (2/5)^h − 1`, an elementary real inequality for
`0 < 2/5 < 1` and `g,h ≥ 1`. Then record the geometric version as a `conjecture`.
**Why now**: We have the closed form and `willmoreBound_increment` showing the energy gains
decay geometrically; subadditivity is the natural next structural law and is provable for the
model with the same toolkit (`pow_add`, `nlinarith`).
**If true**: Provides a recursive lower-bound scaffold for high genus from low genus, the
discrete analogue of the connect-sum constructions used to build Willmore competitors.
**If false (for the model)**: Indicates the geometric connect-sum sharing is *not* captured by
pure geometric decay, pointing toward an additive-correction term in the model.

### Direction 3: Quantitative Li–Yau staircase
**Hypothesis**: The Li–Yau bound refines to a staircase: for energy in the half-open window
`[4πk, 4π(k+1))` the maximal point-multiplicity is exactly `k`. The arithmetic core is: for
`W : ℝ`, `k : ℕ` with `4π·k ≤ W` and `W < 4π·(k+1)`, the multiplicity is `k`.
**Test**: Generalize `liYau_embedded` (the `k=1` instance) to arbitrary `k` by replacing the
threshold `8π = 4π·2` with `4π·(k+1)`; the proof is the same cast-and-`omega` argument with
`Real.pi_pos`.
**Why now**: `liYau_embedded` and `liYau_high_multiplicity` already bracket the `k = 1` step;
the general staircase is a one-parameter lift of an argument we have fully in hand.
**If true**: Gives the complete arithmetic backbone of the Li–Yau multiplicity theory in Lean,
reusable wherever multiplicity bounds gate a min–max or area-comparison argument.
**If false**: Only possible if the energy windows overlap — they cannot, since `4π > 0` — so a
failure would indicate a formalization bug rather than mathematical content.

### Direction 4: Toward a genuine functional — discrete Willmore energy on triangulated surfaces
**Hypothesis**: A combinatorial Willmore energy `W_Δ(M) = Σ_v (angle defect / area)²`-type
functional on a triangulated surface `M` satisfies a discrete Gauss–Bonnet-linked lower bound
`W_Δ(M) ≥ 4π` with a genus correction, mirroring the smooth `W ≥ 4π`.
**Test**: Build on the catalog's `Geometry/DiscreteGaussBonnet.lean` (angle-defect Gauss–Bonnet
`Σ defect = 2π·χ`) to define `W_Δ` and prove the `≥ 4π` bound via Cauchy–Schwarz against the
total angle defect. This is a real (non-model) theorem because the discrete functional *is*
fully definable in Mathlib.
**Why now**: The catalog already contains a proven discrete Gauss–Bonnet theorem; pairing it
with Cauchy–Schwarz is exactly the discrete analogue of the smooth `∫H² ≥ (1/4)(∫|H|)² ≥ 4π`
chain, and Cauchy–Schwarz is in Mathlib (`inner_mul_le_norm_mul_norm`, `Finset.inner_mul_le_nnorm`).
**If true**: Upgrades the project from *modeling* Willmore bounds to *proving* a genuine
Willmore-type inequality for an honest geometric object — a cross-domain bridge from the
combinatorics of triangulations to curvature energy.
**If false**: The Cauchy–Schwarz step needs a sign/normalization hypothesis on the defects,
teaching us exactly which curvature-positivity assumption the smooth proof secretly uses.

### Direction 5: Spectral lower bound via the Hersch/Li–Yau conformal volume
**Hypothesis**: For the model thresholds there is a spectral reformulation: `4π` equals the
Hersch bound `λ_1(S²)·Area/2` for the round sphere, and `2π²` equals the conformal-volume
bound for the Clifford torus, giving identities `sphereBound = 2·π·(λ₁·A)`-style closed forms.
**Test**: State the two identities as equalities between the constants defined here and the
relevant spectral quantities; prove the sphere identity (a clean closed form `λ₁ = 2`,
`Area = 4π`) numerically, and record the torus identity as a `conjecture` pending the conformal
volume API.
**Why now**: The threshold constants are now first-class defined objects (`sphereBound`,
`cliffordValue`); attaching their spectral meaning is the natural way to connect this file to
the catalog's analysis/spectral material and to explain *why* these specific constants appear.
**If true**: Links the Willmore thresholds to eigenvalue optimization, opening the door to the
Yang–Yau and Nadirashvili max-`λ₁` results as future formalization targets.
**If false**: A mismatch would expose a normalization convention difference (factor of `2π`)
between the Willmore and spectral literatures — worth pinning down explicitly in Lean.
