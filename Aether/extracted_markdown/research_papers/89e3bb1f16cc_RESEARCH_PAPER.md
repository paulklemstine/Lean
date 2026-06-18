# The Elementary Theory of Willmore Energy Lower Bounds: A Measure-Theoretic Account

## Abstract

The Willmore energy `W = ∫ H² dA` of a closed surface is a conformally
invariant bending functional whose sharp lower bounds have driven decades of
geometric analysis, culminating in the Marques–Neves resolution of the Willmore
conjecture. We isolate and rigorously develop the *elementary* portion of this
theory in a deliberately minimal abstraction: a finite measure space `(X, μ)`
equipped with two measurable "principal curvature" functions `κ₁, κ₂ : X → ℝ`,
with no smooth manifold, immersion, or tensorial second fundamental form. Within
this setting we show that the entire elementary chain of Willmore inequalities
descends from a *single algebraic identity*,

> `H² − K = ((κ₁ − κ₂)/2)²`,    where `H = (κ₁+κ₂)/2` and `K = κ₁κ₂`,

together with the nonnegativity of integrals of squares. We obtain: the pointwise
domination `K ≤ H²` and its pointwise rigidity `H² = K ↔ κ₁ = κ₂`; the integral
balance identity `W − ∫K = ∫((κ₁−κ₂)/2)²`; the integral inequality `∫K ≤ W`;
integral rigidity `W = ∫K ↔ κ₁ = κ₂` almost everywhere; the Gauss–Bonnet bound
`2π·χ ≤ W`; the sharp genus-zero floor `4π ≤ W`; a set-integral degree mechanism
yielding `W ≥ 4π` from a single `4π`-curvature region; a Li–Yau-style
multiplicity bound `W ≥ 4πn` from `n` disjoint sheets; and a precise account of
*why* the elementary method degenerates for genus `g ≥ 1`, where the floor
`4π(1−g)` becomes vacuous and decays by exactly `4π` per unit genus. All results
are fully formalized and machine-checked, depending only on the standard
foundational axioms. We delineate exactly where the elementary theory ends and
the deep min-max input of Marques–Neves must begin.

**Keywords.** Willmore energy, mean curvature, Gaussian curvature, Gauss–Bonnet,
umbilic points, Li–Yau inequality, Willmore conjecture, rigidity, measure theory.

---

## 1. Introduction

For a smoothly immersed closed surface `Σ ⊂ ℝ³` with principal curvatures
`κ₁, κ₂`, mean curvature `H = (κ₁+κ₂)/2` and Gaussian curvature `K = κ₁κ₂`, the
**Willmore energy** is

> `W(Σ) = ∫_Σ H² dA`.

It is invariant under conformal transformations of `ℝ³ ∪ {∞}` (Blaschke,
Thomsen) and measures the total "bending" of the surface. Three classical facts
form the elementary backbone of its theory:

1. **Willmore's bound.** `W(Σ) ≥ 4π` for every closed surface, with equality iff
   `Σ` is a round sphere.
2. **The Li–Yau inequality.** If `Σ` has a point of multiplicity `n`, then
   `W(Σ) ≥ 4πn`; in particular `W < 8π` forces embeddedness.
3. **The Willmore conjecture (now theorem).** For genus-one surfaces (tori),
   `W ≥ 2π²`, attained by the Clifford torus. This was open for nearly five
   decades and resolved by Marques and Neves (2012) via Almgren–Pitts min-max
   theory.

The first two are *elementary* in a strong sense: once one extracts the right
algebraic skeleton, they require nothing beyond pointwise nonnegativity and
integration. The third is genuinely deep and provably out of reach of the
elementary machinery. The purpose of this paper is to make this trichotomy
mathematically precise.

Our strategy is to strip away all smooth-manifold scaffolding and retain only the
data that the elementary arguments actually consume. A closed surface becomes a
**finite measure space** `(X, μ)` together with two measurable functions
`κ₁, κ₂ : X → ℝ` playing the role of pointwise principal curvatures. The area
form is `μ`; integration is Lebesgue integration; "almost everywhere" is with
respect to `μ`. We do not assume the existence of any embedding into `ℝ³`, nor
that `κ₁, κ₂` arise from a genuine second fundamental form. Remarkably, the entire
elementary theory survives this abstraction intact, which both clarifies its
logical content and exposes precisely the one external input (a Gauss–Bonnet
total, or a Gauss-map degree) that connects it to topology.

---

## 2. Definitions

Throughout, `X` is a type, `κ₁, κ₂ : X → ℝ`, and (from §4 on) `(X, μ)` is a
measure space with a measure `μ`.

**Definition 2.1 (Pointwise invariants).** For each `x ∈ X`:

- **Mean curvature** `H(x) := (κ₁(x) + κ₂(x))/2`.
- **Willmore density** `𝒲(x) := H(x)² = ((κ₁(x)+κ₂(x))/2)²`.
- **Gaussian curvature** `K(x) := κ₁(x)·κ₂(x)`.
- **Umbilic defect** `𝒟(x) := ((κ₁(x) − κ₂(x))/2)²`.

**Definition 2.2 (Global invariants).** With respect to a measure `μ`:

- **Willmore energy** `W := ∫_X 𝒲 dμ = ∫_X ((κ₁+κ₂)/2)² dμ`.
- **Total Gaussian curvature** `𝒦 := ∫_X K dμ = ∫_X κ₁κ₂ dμ`.
- **Total umbilic defect** `𝔇 := ∫_X 𝒟 dμ = ∫_X ((κ₁−κ₂)/2)² dμ`.

**Definition 2.3 (Topological data).** The **Euler characteristic** `χ ∈ ℤ` and
**genus** `g ∈ ℕ` of a closed orientable surface are related by `χ = 2 − 2g`.
A round sphere has `χ = 2`, `g = 0`; a torus has `χ = 0`, `g = 1`. These integers
enter the theory through a single external hypothesis, the Gauss–Bonnet total
`𝒦 = 2π·χ` (§5), which in the catalog's discrete-topology layer is supplied by
the combinatorial Gauss–Bonnet identity `∑_v K(v) = 2π(2 − 2g)`.

A point `x` with `κ₁(x) = κ₂(x)` is called **umbilic**; a configuration with
`κ₁ = κ₂` `μ`-almost everywhere is **totally umbilic** and models the round
sphere.

---

## 3. The pointwise theory: one square identity

The whole development rests on a single line of algebra.

**Theorem 3.1 (Square identity).** For every `x ∈ X`,
> `𝒲(x) − K(x) = 𝒟(x)`,   i.e.   `((κ₁+κ₂)/2)² − κ₁κ₂ = ((κ₁−κ₂)/2)²`.

*Proof.* Expand both sides:
`((κ₁+κ₂)/2)² = (κ₁² + 2κ₁κ₂ + κ₂²)/4` and
`((κ₁−κ₂)/2)² = (κ₁² − 2κ₁κ₂ + κ₂²)/4`; their difference is
`(4κ₁κ₂)/4 = κ₁κ₂ = K`. This is the polarization identity
`(a+b)² − 4ab = (a−b)²` rescaled by `1/4`. ∎

**Corollary 3.2 (Nonnegativity).** `𝒟(x) ≥ 0` and `𝒲(x) ≥ 0` for all `x`, since
each is a square.

**Corollary 3.3 (Pointwise domination).** `K(x) ≤ 𝒲(x)` for all `x`.

*Proof.* By Theorem 3.1, `𝒲(x) − K(x) = 𝒟(x) ≥ 0`. ∎

**Theorem 3.4 (Pointwise rigidity).** `𝒲(x) = K(x)` if and only if
`κ₁(x) = κ₂(x)`.

*Proof.* By Theorem 3.1, `𝒲(x) = K(x) ⟺ 𝒟(x) = 0 ⟺ ((κ₁(x)−κ₂(x))/2)² = 0
⟺ κ₁(x) = κ₂(x)`, the last step because the only real square root of `0` is `0`. ∎

These four statements are the formal nuclei `willmoreDensity_sub_gaussCurv`,
`umbilicDefect_nonneg` / `willmoreDensity_nonneg`, `gaussCurv_le_willmoreDensity`
and `willmoreDensity_eq_gaussCurv_iff`. Everything in §§4–6 is obtained by
integrating them.

---

## 4. The integral theory and rigidity

We now fix a measure space `(X, μ)`. To integrate the pointwise identity we
require only the integrability of the density and the curvature; integrability of
the defect then follows from Theorem 3.1.

**Theorem 4.1 (Integral balance identity).** If `𝒲` and `K` are `μ`-integrable,
then
> `W − 𝒦 = 𝔇`,   i.e.   `∫((κ₁+κ₂)/2)² dμ − ∫κ₁κ₂ dμ = ∫((κ₁−κ₂)/2)² dμ`.

*Proof.* By linearity of the integral (`integral_sub`, valid since both `𝒲` and
`K` are integrable), `W − 𝒦 = ∫(𝒲 − K) dμ`. By Theorem 3.1 the integrand equals
`𝒟` pointwise, so `W − 𝒦 = ∫𝒟 dμ = 𝔇`. ∎

**Corollary 4.2 (Nonnegative slack).** `𝔇 ≥ 0`, since `𝒟 ≥ 0` pointwise and the
integral of a nonnegative function is nonnegative.

**Theorem 4.3 (Integral inequality).** Under the hypotheses of Theorem 4.1,
> `𝒦 ≤ W`.

*Proof.* `W − 𝒦 = 𝔇 ≥ 0` by Theorem 4.1 and Corollary 4.2. ∎

The balance identity 4.1 is strictly stronger than the inequality 4.3: it
identifies the *exact* energy gap as the `L²`-norm of the traceless second
fundamental form, `𝔇 = ∫ ((κ₁−κ₂)/2)² dμ`. This upgrade — from a bound to an
equality-with-remainder — is what powers the rigidity theorem.

**Theorem 4.4 (Integral rigidity).** Under the hypotheses of Theorem 4.1,
> `W = 𝒦`   if and only if   `κ₁ = κ₂` `μ`-almost everywhere.

*Proof.* By Theorem 4.1, `W = 𝒦 ⟺ 𝔇 = 0 ⟺ ∫𝒟 dμ = 0`. The integrand `𝒟` is
nonnegative and (a.e.-strongly) measurable, so by the vanishing criterion for
nonnegative integrands (`MeasureTheory.integral_eq_zero_iff_of_nonneg_ae`),
`∫𝒟 dμ = 0 ⟺ 𝒟 = 0` `μ`-a.e. Finally `𝒟(x) = 0 ⟺ κ₁(x) = κ₂(x)` pointwise
(Theorem 3.4), so `𝒟 = 0` a.e. `⟺ κ₁ = κ₂` a.e. ∎

Geometrically, Theorem 4.4 says the elementary energy floor is attained *only* by
totally umbilic configurations — the abstract avatar of "only the round sphere
minimizes among spheres."

These are `willmoreEnergy_sub_gauss_eq_defect`, `totalDefect_nonneg`,
`gauss_le_willmore`, and `willmore_eq_gauss_iff_umbilic_ae`.

---

## 5. Topology enters: Gauss–Bonnet and the sphere floor

The integral inequality `𝒦 ≤ W` becomes a *topological* lower bound the moment
one supplies the Gauss–Bonnet total as an external hypothesis.

**Theorem 5.1 (Gauss–Bonnet bound).** Suppose `𝒦 = 2π·χ` for an integer
Euler characteristic `χ` (the Gauss–Bonnet input), and that `𝒲, K` are
integrable. Then
> `2π·χ ≤ W`.

*Proof.* Substitute `𝒦 = 2π·χ` into Theorem 4.3. ∎

**Theorem 5.2 (Sharp genus-zero floor).** For a genus-zero configuration
(`χ = 2`, supplied as `𝒦 = 4π`), with `𝒲, K` integrable,
> `W ≥ 4π`,

with equality iff `κ₁ = κ₂` `μ`-a.e.

*Proof.* Apply Theorem 5.1 with `χ = 2`: `4π = 2π·2 ≤ W`. The equality case is
exactly `W = 𝒦 = 4π`, which by Theorem 4.4 is total umbilicity. ∎

The Gauss–Bonnet hypothesis `𝒦 = 2π·χ` is not proved here; it is the contract
with the topology layer. In the companion development `DiscreteGaussBonnet.lean`
the discrete totals `∑_v K(v) = 2π(2 − 2g)` (`total_curvature_eq_genus`),
`χ = 2 − 2g` (`eulerChar_eq_two_sub_two_mul_genus`) and `χ = 2` for the sphere
(`sphere_euler_char`) supply exactly these inputs, so the two files compose into a
single curvature → topology → energy pipeline.

These are `gaussBonnet_bound` and `willmore_ge_fourPi_genus_zero`.

---

## 6. The degree mechanism: universal `4π` and Li–Yau multiplicity

Gauss–Bonnet is a *global* route to `4π`. A second, *local* route uses only the
Gauss-map degree on a region, and it generalizes to multiplicities.

**Theorem 6.1 (Universal `4π` from a degree region).** Suppose `A ⊆ X` is a
measurable set on which the positive part of the Gaussian curvature integrates to
at least `4π`, i.e. `∫_A K⁺ dμ ≥ 4π` (the Gauss-map covers the sphere at least
once over `A`), and `𝒲` is integrable. Then
> `W ≥ 4π`.

*Proof sketch.* On `A`, `𝒲 ≥ K⁺ ≥ K` pointwise (Corollary 3.3 plus
`K ≤ K⁺`). Restricting the integral to `A` and using
`setIntegral_le_integral` (monotonicity of the integral under restriction to a
subset for the nonnegative integrand `𝒲`),
`W = ∫_X 𝒲 dμ ≥ ∫_A 𝒲 dμ ≥ ∫_A K⁺ dμ ≥ 4π`. ∎

**Theorem 6.2 (Li–Yau multiplicity bound).** Suppose `A₁, …, A_n ⊆ X` are
pairwise disjoint measurable sets, each a "`4π`-sheet" with
`∫_{A_i} K⁺ dμ ≥ 4π`, and `𝒲` is integrable and nonnegative. Then
> `W ≥ 4π·n`.

*Proof sketch.* By finite additivity of the integral over the disjoint union
`A = ⨆_i A_i`, and `𝒲 ≥ K⁺ ≥ 0` on each sheet,
`W ≥ ∫_A 𝒲 dμ = ∑_{i=1}^{n} ∫_{A_i} 𝒲 dμ ≥ ∑_{i=1}^{n} ∫_{A_i} K⁺ dμ
≥ ∑_{i=1}^{n} 4π = 4π·n`. The first inequality is monotonicity under restriction
(nonnegativity of `𝒲`); the equality is countable/finite additivity of the
set integral over disjoint measurable pieces; the induction over `n` adds one
sheet at a time. ∎

Theorem 6.2 is the elementary skeleton of the Li–Yau inequality: a point of
multiplicity `n` produces `n` disjoint sheets, each contributing an independent
`4π` of Gauss-map degree. Its most consequential corollary: `W < 8π` forbids
self-intersection (`n ≥ 2` would force `W ≥ 8π`), so low-energy surfaces are
automatically embedded — the embeddedness gateway used in the deep theory.

These are `willmore_ge_fourPi_of_setGauss` and
`willmore_ge_fourPi_mul_of_disjoint_sheets`.

---

## 7. The boundary of the elementary world

The elementary method is sharp for genus zero and silent for higher genus. We
make the silence precise.

**Definition 7.1 (Elementary floor).** For genus `g ∈ ℕ`, the Gauss–Bonnet
floor produced by Theorem 5.1 with `χ = 2 − 2g` is
> `b(g) := 2π·(2 − 2g) = 4π(1 − g)`.

**Theorem 7.2 (Vacuity for high genus).** For every `g ≥ 1`, `b(g) ≤ 0`.

*Proof.* `g ≥ 1 ⟹ 1 − g ≤ 0 ⟹ 4π(1 − g) ≤ 0` since `4π > 0`. ∎

Thus for `g ≥ 1` the bound `b(g) ≤ W` is implied by the trivial `0 ≤ W`
(Corollary 3.2 integrated) and carries no new information.

**Theorem 7.3 (Step law).** `b(g+1) = b(g) − 4π` for all `g`.

*Proof.* `b(g+1) = 4π(1 − (g+1)) = 4π(1 − g) − 4π = b(g) − 4π`. ∎

**Corollary 7.4 (Strict antitonicity).** `b` is strictly decreasing in `g`; each
unit of genus costs the elementary method exactly `4π` of detectable energy.

These are `gaussBonnet_bound_vacuous_high_genus`, `elementary_bound_step`, and
`elementary_bound_antitone`.

**The genuine genus-one floor.** The true infimum of `W` over tori is *not*
`b(1) = 0` but
> `2π² ≈ 19.74`,

attained by the **Clifford torus** (the conformal image of the flat square torus,
with generating-circle radius ratio `1 : √2`). The statement `W ≥ 2π²` for genus
one is the Willmore conjecture, recorded in the development as an explicit open
target (`willmore_torus_conjecture`, left as `sorry`). Theorem 7.2 explains
structurally *why* it must remain open to elementary methods: Gauss–Bonnet alone
cannot distinguish a torus from a flat configuration, because both have
`𝒦 = 0`. Detecting the `2π²` floor requires genuinely non-elementary input — the
Almgren–Pitts min-max theory deployed by Marques and Neves — which is absent from
the elementary abstraction by design.

---

## 8. Algorithms

The pointwise and integral invariants are immediately computable, and on a
discretized (triangulated) surface the entire pipeline becomes a finite
calculation. We summarize the two principal procedures.

**Algorithm 8.1 (Discrete Willmore pipeline).** Given a triangulated surface with
per-vertex principal curvatures `(κ₁, κ₂)` and area weights `w`:

1. For each vertex `v`: `H ← (κ₁+κ₂)/2`, `𝒲 ← H²`, `K ← κ₁κ₂`,
   `𝒟 ← ((κ₁−κ₂)/2)²`.
2. Verify the square identity `𝒲 − K = 𝒟` per vertex (a finite check of
   Theorem 3.1).
3. Accumulate `W ← ∑_v w_v 𝒲_v`, `𝒦 ← ∑_v w_v K_v`, `𝔇 ← ∑_v w_v 𝒟_v`.
4. Assert the balance identity `W − 𝒦 = 𝔇` (Theorem 4.1) and the inequality
   `𝒦 ≤ W` (Theorem 4.3).
5. From the topology `χ = 2 − 2g`, report the floor `b(g) = 2π·χ` and compare to
   `W` (Theorem 5.1). For `g = 0` the floor is the sharp `4π`.

Complexity: `O(V)` time, `O(1)` extra space, where `V` is the vertex count.

**Algorithm 8.2 (Li–Yau sheet accumulation).** Given disjoint vertex sets
`A₁, …, A_n` (the sheets) with positive curvature mass `m_i = ∑_{v∈A_i} w_v K⁺_v`:

1. Check each sheet has `m_i ≥ 4π`.
2. The energy on the union is at least `∑_i m_i ≥ 4π·n` (Theorem 6.2), giving the
   lower bound `W ≥ 4π·n`.

Complexity: `O(∑_i |A_i|)` time.

---

## 9. Applications

- **Optimal shape certification.** The balance identity 4.1 turns the bound
  `𝒦 ≤ W` into a computable *certificate*: the umbilic defect `𝔇` is the exact
  distance (in energy) from optimality, so a numerical surface can be certified
  near-spherical by measuring `𝔇` directly.
- **Embeddedness tests.** The multiplicity bound 6.2 gives the rule "`W < 8π`
  ⟹ embedded," a practical screen in geometric modeling and biomembrane
  simulation, where the Helfrich/Willmore energy governs equilibrium shapes of
  vesicles and red blood cells.
- **Rigidity diagnostics.** Theorem 4.4 provides a clean criterion: equality in
  the elementary bound is *equivalent* to total umbilicity a.e., so any
  deviation is detectable and quantifiable through `𝔇`.
- **Topology–energy coupling.** Composed with the discrete Gauss–Bonnet layer,
  the pipeline reads a triangulated mesh's genus and outputs the corresponding
  energy floor, linking combinatorial topology directly to a physical bending
  budget.

---

## 10. Discussion

The principal conceptual contribution is *minimality*: the elementary Willmore
inequalities require none of the apparatus usually invoked (immersions, the
second fundamental form as a tensor, smoothness). They are statements about two
measurable functions and the act of squaring and integrating. This has two
benefits. First, it isolates the logical content with surgical clarity: a single
identity (3.1) plus nonnegativity is *necessary and sufficient* for the entire
elementary chain. Second, it pinpoints the exact external inputs that couple the
algebra to geometry and topology — the Gauss–Bonnet total `𝒦 = 2π·χ` (Theorem
5.1) and the Gauss-map degree mass `∫_A K⁺ ≥ 4π` (Theorem 6.1) — making the
seam between elementary and deep mathematics explicit.

The boundary analysis of §7 is, we believe, the most instructive part. A mature
elementary theory should know its own limits, and here it does so quantitatively:
the floor `b(g) = 4π(1−g)` is exactly `4π` lower per unit genus (Theorem 7.3) and
becomes vacuous for every `g ≥ 1` (Theorem 7.2). This is not a defect of the
formalization but a faithful reflection of mathematical reality — Gauss–Bonnet
cannot see the `2π²` torus floor because it cannot distinguish surfaces of equal
total curvature.

---

## 11. Future work

A detailed program is recorded in the package's *Future Directions*. In brief:

1. **Quantitative umbilic-defect bounds.** Upgrade `𝒦 ≤ W` to
   `W ≥ 2π·χ + c·(spread of the second fundamental form)²`, using the explicit
   remainder `𝔇` already isolated by Theorem 4.1.
2. **Sharper integral rigidity.** Extend Theorem 4.4 to almost-equality
   stability statements: small `𝔇` forces closeness to total umbilicity in a
   quantitative norm.
3. **Genus-monotonicity of the obstruction.** Formalize the increasing gap
   between the elementary floor `b(g)` and the true floor `β(g)` (with
   `β(1) = 2π²`), on top of Theorems 7.2–7.4.
4. **General Li–Yau.** Promote Theorem 6.2 to the full multiplicity statement
   `W ≥ 4πk` for a point of multiplicity `k` via finite additivity and induction.
5. **The Marques–Neves target `2π² ≤ W` for tori.** Prototype a width functional
   on the abstract measure-space model satisfying axiomatized
   monotonicity/normalization, reducing the deep theorem to a finite
   combinatorial-analytic core — the open target recorded as
   `willmore_torus_conjecture`.

---

## 12. Conclusion

We have given a complete, self-contained, machine-checked account of the
elementary theory of Willmore energy lower bounds inside a minimal
measure-theoretic abstraction. From the single square identity
`H² − K = ((κ₁−κ₂)/2)²` flow the pointwise domination `K ≤ H²`, the integral
balance `W − ∫K = ∫((κ₁−κ₂)/2)²`, the inequality `∫K ≤ W`, integral rigidity, the
Gauss–Bonnet bound `2π·χ ≤ W`, the sharp sphere floor `4π ≤ W`, the universal
`4π` degree bound, and the Li–Yau multiplicity bound `W ≥ 4πn`. We have also made
the limits of the method exact: for genus `g ≥ 1` the elementary floor
`4π(1−g)` is vacuous and decays by `4π` per hole, leaving the true torus floor
`2π²` as the precisely located gateway to the deep theory. The whole edifice
rests on the observation that a square is never negative — integrated.

---

## References

- T. J. Willmore, *Note on embedded surfaces*, An. Şti. Univ. "Al. I. Cuza" Iaşi,
  1965.
- P. Li and S.-T. Yau, *A new conformal invariant and its applications to the
  Willmore conjecture and the first eigenvalue of compact surfaces*, Invent.
  Math. 69 (1982).
- F. C. Marques and A. Neves, *Min-max theory and the Willmore conjecture*, Ann.
  of Math. 179 (2014).
