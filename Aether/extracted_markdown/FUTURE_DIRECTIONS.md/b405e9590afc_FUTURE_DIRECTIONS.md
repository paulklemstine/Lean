# Future Directions: Parametric Continuity of Self-Consistent Timelines

## Synthesis

This cycle closed the first conjecture of the seed *Novikov Self-Consistency as
Fixed-Point Theory* program. The seed asked: *if `{f_t}_{t ∈ [0,1]}` is a continuous
family of contractions, do the self-consistent timelines (their fixed points) vary
continuously?* The new module `MachineLearning/FixedPoint/ParametricContinuity.lean`
answers **yes**, and extracts the full topological consequence stack from a single
algebraic seed already in the catalog — the stability estimate

```
dist (xstar s) (xstar t) ≤ dist (F s (xstar t)) (F t (xstar t)) / (1 - K)
```

of `ParametricFixedPoint.contraction_fixedPoint_stability`
(`MachineLearning/FixedPoint/Parametric.lean`). The conceptual unification is that
*every* qualitative regularity of the fixed-point map is a shadow of this one
quantitative inequality: where `Parametric.lean` pushed it to extract **Lipschitz**
dependence from **Lipschitz** data, this cycle pushes it to extract **continuous**,
**connected**, and **path** structure from merely **continuous** data — strictly
weaker hypotheses (only *separate* continuity `t ↦ F t x`, no joint continuity, no
modulus in `t`).

## Results Summary

All results are in `ParametricContinuity.lean`, `sorry = 0`, axioms limited to
`propext, Classical.choice, Quot.sound`.

1. `tendsto_parametric_fixedPoint` — the filter-level engine: convergence of the
   family at the single reference fixed point forces convergence of the whole
   fixed-point map. (Squeeze against the stability bound.)
2. `continuous_parametric_fixedPoint` — the main theorem: pointwise-continuous
   parameter dependence ⇒ continuous timeline map. This is the seed conjecture.
3. `isConnected_range_parametric_fixedPoint` — over a connected parameter space the
   set of self-consistent solutions is connected: no isolated causal branches.
4. `parametric_fixedPoint_path` — over `[0,1]` the timelines assemble into an honest
   `Path` from `xstar 0` to `xstar 1`: the literal homotopy form of the conjecture.

These extend, rather than reprove, `MachineLearning/FixedPoint/Core.lean`
(existence/uniqueness of each timeline) and `Parametric.lean` (Lipschitz/equivariance),
and bridge into the Novikov-consistency vocabulary of
`Bridges/TemporalFixedPointSemantics.lean`.

## Bold, Falsifiable Directions

### 1. Homotopy invariance of the timeline winding class

Conjecture: for a continuous loop of contractions `F : S¹ → α → α` on a (path-)connected
metric space `α`, the induced loop of fixed points `t ↦ xstar t` represents a
well-defined class in `π₁(α, xstar t₀)`, and this class is invariant under homotopies
of the loop of contractions through contractions of uniformly bounded constant `K < 1`.
**The key insight is** that `parametric_fixedPoint_path` already produces the path
functorially from the seed inequality, so a homotopy of the *input* family yields a
homotopy of *output* paths by the very same squeeze with a parameterized bound — turning
a dynamical deformation into an algebraic-topology invariant. **Why now?** The path
constructor exists and is `sorry`-free; the only missing ingredient is upgrading the
single-parameter squeeze to a two-parameter (homotopy) squeeze, which reuses
`contraction_fixedPoint_stability` verbatim.

### 2. Quantitative modulus of continuity from a modulus on the family

Conjecture: if `t ↦ F t x` admits a common modulus of continuity `ω` (i.e.
`dist (F s x) (F t x) ≤ ω (dist s t)` for all `x`), then `xstar` admits modulus
`ω(·)/(1 - K)`; in particular Hölder-`γ` parameter dependence yields Hölder-`γ`
timelines with the *same* exponent and an explicit constant. **The key insight is**
that the stability denominator `1 - K` is exponent-agnostic: it scales the numerator's
modulus without touching its shape, so regularity classes transfer intact. **Why now?**
`lipschitz_parametric_fixedPoint` is the `ω(r) = L·r` instance already in the catalog;
generalizing `L·r` to an abstract subadditive `ω` is a direct, falsifiable refactor
(falsified the moment a family with modulus `ω` produces a timeline rougher than
`ω/(1-K)`).

### 3. Failure boundary at the contraction threshold `K → 1⁻`

Conjecture: continuity of `xstar` degrades *predictably* as `K → 1⁻` — specifically,
there is a family with `K_t → 1` along `t → t₀` whose timeline map is continuous but
not Hölder of any positive exponent at `t₀`, while for any family with
`sup_t K_t < 1` the timeline is automatically locally Lipschitz wherever the data is.
**The key insight is** that `contraction_K_eq_one_no_fixedPoint` (catalog) already
pinpoints `x ↦ x+1` as the `K = 1` obstruction; perturbing it to `x ↦ K_t·x + 1` makes
the fixed point `1/(1-K_t)` blow up at an explicit rate, converting the qualitative
"`K < 1` is necessary" into a quantitative continuity-modulus phase transition. **Why
now?** Both the positive theory (`continuous_parametric_fixedPoint`) and the sharp
counterexample are in hand, so the boundary between them is a concrete, computable
target.

### 4. Continuity of the closed consistent-history set in `TemporalFixedPointSemantics`

Conjecture: in `Bridges/TemporalFixedPointSemantics.lean`, parameterize the reversible
step `r_t` (or the constraint set `C_t`) continuously; then the `loopClosure r_t C_t`,
viewed through a suitable metric on its finite Nerode quotient signatures, varies
continuously (no signature appears/disappears discontinuously) on the locus where the
induced selection map is a contraction. **The key insight is** that `loopClosure` is a
genuine closure (fixed point of a monotone operator), so the lattice-theoretic fixed
point should obey the *same* parametric-continuity principle as the metric one — a
cross-domain transport of `continuous_parametric_fixedPoint` from metric to order-
theoretic fixed points. **Why now?** The metric prototype is proved; restating it for
the Knaster–Tarski fixed point of `loopClosure` tests whether the unification is
genuinely structural rather than metric-specific.

### 5. Sequential / net continuity over non-metrizable parameter spaces

Conjecture: `continuous_parametric_fixedPoint` holds verbatim with `β` an arbitrary
topological space (already true in the current statement), and moreover the fixed-point
map is continuous *iff* it is continuous along nets, with no metrizability assumption on
`β` — and this is the maximal generality: there is a non-first-countable `β` and a
separately-continuous family whose timeline map is sequentially continuous but not
continuous, exactly when separate continuity fails to be joint. **The key insight is**
that `tendsto_parametric_fixedPoint` is stated on an *arbitrary filter* `l`, so it
already covers nets; the open question is whether separate continuity of `t ↦ F t x`
can ever be strengthened for free to the joint continuity that nets detect. **Why now?**
The filter-level lemma is deliberately general and `sorry`-free, making the
sequential-vs-net gap a precise, falsifiable question rather than a vague one.
