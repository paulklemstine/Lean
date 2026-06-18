# Parametric Fixed-Point Theory: A Quantitative Stability Engine and Its Corollaries

## Abstract

The Banach contraction principle guarantees that a `K`-contraction on a complete
metric space has a unique fixed point. In applications, however, one rarely studies
a single contraction in isolation: the relevant object is a *family* of
contractions, indexed by a parameter (model weights, a discount factor, market
conditions, a time index), and the question of interest is how the fixed point
*depends* on that parameter. We isolate a single quantitative inequality — the
**fixed-point stability bound**

> `d(x_f, x_g) ≤ d(f(x_g), g(x_g)) / (1 − K)` —

that controls the distance between the fixed points of a `K`-contraction `f` and an
*arbitrary* map `g`, and we show that the principal questions of parametric
fixed-point theory reduce to one-step substitutions into this bound. From it we
derive: (i) a **Lipschitz parametric Banach theorem** with the explicit, sharp
constant `L/(1−K)`; (ii) an **equivariance principle** stating that intertwining
symmetries of a contraction family are inherited by the fixed point, as a forced
consequence of uniqueness; and (iii) a **non-autonomous composition rate**, showing
that a composition of `n` contractions with constants `K_i` contracts at the product
rate `∏ K_i`, generalizing the two-map composition law. We complement these positive
results with a **sharpness theorem**: the isometry `x ↦ x + 1` on `ℝ` is a
`1`-Lipschitz map with no fixed point, certifying that the hypothesis `K < 1` (and
the divergence of `1/(1−K)` as `K → 1`) is essential rather than artefactual. All
results have been formally verified in the Lean 4 proof assistant atop a
from-scratch development of the quantitative Banach theory.

**Keywords.** Banach fixed-point theorem; contraction mapping; parametric
stability; Lipschitz dependence; equivariance; non-autonomous dynamics; formal
verification.

---

## 1. Introduction

### 1.1 Motivation

Fixed-point equations `x = f(x)` are the lingua franca of self-consistency across
the quantitative sciences. They encode market-clearing prices in economics,
Bellman-optimal value functions in reinforcement learning, steady states of
recurrent computations, and the equilibria of iterative numerical solvers. The
Banach contraction principle provides a powerful and constructive existence-and-
uniqueness theorem: if `f` shrinks distances by a uniform factor `K < 1`, then `f`
has exactly one fixed point, and Picard iteration from any starting point converges
to it geometrically.

Yet the static theorem answers only half the practitioner's question. In every
realistic setting the contraction `f` is one member of a *family* `{F_t}` indexed by
a parameter `t`. The decisive questions are quantitative and parametric:

1. **Sensitivity.** How far does the fixed point `x*(t)` move when the parameter `t`
   is perturbed?
2. **Symmetry.** If the family respects a symmetry, does the fixed point respect it
   too?
3. **Non-stationarity.** If the rule changes at every step (an adaptive schedule),
   does the iteration still converge, and at what rate?
4. **Sharpness.** Exactly where does the theory fail as the contraction degenerates?

### 1.2 Contribution

We answer all four questions by isolating a single inequality and reducing the rest
to corollaries. Our central observation is that the distance between the fixed points
of a contraction `f` and an *arbitrary* map `g` admits a closed-form bound depending
only on (a) the disagreement of `f` and `g` at one point and (b) the contraction
margin `1 − K`. We call this the **fixed-point stability bound**
(`contraction_fixedPoint_stability`). Its proof is a single triangle inequality, and
its asymmetry — only `f` need contract — is precisely what makes it reusable across
all the parametric phenomena above.

The remaining results are then one-line specializations:

- **Lipschitz parametric Banach theorem** (`lipschitz_parametric_fixedPoint`):
  substitute a uniform Lipschitz hypothesis on the family into the stability bound to
  obtain an `L/(1−K)`-Lipschitz fixed-point map with the *exact* advertised constant.
- **Equivariance** (`equivariant_fixedPoint`): combine the intertwining relation with
  uniqueness of fixed points to force the fixed point to transform covariantly.
- **Non-autonomous composition rate** (`iteratedComp_contraction`): an induction over
  the number of maps generalizes the two-map composition law to the product `∏ K_i`.
- **Sharpness** (`contraction_K_eq_one_no_fixedPoint`): an explicit `K = 1`
  counterexample showing the strict inequality `K < 1` cannot be relaxed.

Every statement has been formally proved in Lean 4, building on a self-contained
development of the quantitative Banach theory (geometric decay of iterates,
uniqueness, Cauchy iterates, existence, and the convergence rate).

### 1.3 Organization

Section 2 fixes notation and recalls the foundational quantitative Banach results.
Section 3 states and proves the stability bound. Sections 4–7 derive the four
corollaries. Section 8 gives algorithms and numerical validation. Section 9 discusses
applications, and Section 10 lists future directions.

---

## 2. Preliminaries

Throughout, `(α, d)` denotes a metric space; completeness and nonemptiness are
assumed only where existence of fixed points is invoked.

**Definition 2.1 (Contraction).** A map `f : α → α` is a *`K`-contraction* (with
`0 ≤ K < 1`) if
```
∀ x y,  d(f(x), f(y)) ≤ K · d(x, y).
```

**Definition 2.2 (Fixed point).** A point `x ∈ α` is a *fixed point* of `f` if
`f(x) = x`.

We recall four foundational results, each formally verified, that underpin the
parametric theory.

**Lemma 2.3 (Geometric decay of iterates).** If `f` is a `K`-contraction with
`0 ≤ K`, then for all `n` and all `x, y`,
```
d(f^[n](x), f^[n](y)) ≤ Kⁿ · d(x, y).
```
*Proof sketch.* Induction on `n`: the base case is trivial, and the inductive step
applies the contraction inequality to `f^[n]` and then multiplies by `K`. ∎

**Lemma 2.4 (Uniqueness).** If `f` is a `K`-contraction with `K < 1` and `f(x) = x`,
`f(y) = y`, then `x = y`.
*Proof sketch.* If `x ≠ y` then `d(x, y) > 0`, but `d(x, y) = d(f(x), f(y)) ≤
K · d(x, y) < d(x, y)`, a contradiction. ∎

**Theorem 2.5 (Banach existence, quantitative).** On a nonempty complete metric
space, every `K`-contraction (`K < 1`) has a unique fixed point `x*`, and Picard
iterates `f^[n](x₀)` converge to `x*` for every `x₀`.
*Proof sketch.* The iterates form a Cauchy sequence (their consecutive gaps are
bounded by a convergent geometric series), hence converge by completeness; the limit
is fixed by continuity of `f`; uniqueness is Lemma 2.4. ∎

**Theorem 2.6 (Convergence rate).** With `x*` the fixed point,
`d(f^[n](x₀), x*) ≤ Kⁿ · d(x₀, x*)`.
*Proof sketch.* Apply Lemma 2.3 with `y = x*` and use `f^[n](x*) = x*`. ∎

These results are the qualitative and rate-theoretic backbone. The contribution of
the present paper is the *parametric* layer built on top of them.

---

## 3. The Fixed-Point Stability Bound

The following is the quantitative engine of the entire development.

**Theorem 3.1 (Fixed-point stability).** Let `f` be a `K`-contraction with `K < 1`
and fixed point `x_f` (`f(x_f) = x_f`). Let `g : α → α` be *any* map with a fixed
point `x_g` (`g(x_g) = x_g`). Then
```
d(x_f, x_g) ≤ d(f(x_g), g(x_g)) / (1 − K).
```

*Proof.* Apply the triangle inequality through the intermediate point `f(x_g)` and
use the fixed-point equations `x_f = f(x_f)`, `x_g = g(x_g)`:
```
d(x_f, x_g) = d(f(x_f), g(x_g))
            ≤ d(f(x_f), f(x_g)) + d(f(x_g), g(x_g))
            ≤ K · d(x_f, x_g)  +  d(f(x_g), g(x_g)).
```
The first inequality is the triangle inequality; the second uses that `f` is a
`K`-contraction on the first term. Rearranging,
```
(1 − K) · d(x_f, x_g) ≤ d(f(x_g), g(x_g)),
```
and dividing by `1 − K > 0` gives the claim. ∎

**Remarks.**

- **Asymmetry is the point.** Only `f` is required to be a contraction; `g` is
  arbitrary. This makes the bound applicable to comparisons between an idealized
  contracting model and an unstructured real-world process that merely happens to
  possess a fixed point.
- **Minimal hypotheses.** Neither `0 ≤ K` nor a two-sided contraction is needed —
  only `K < 1` (to make `1 − K` positive) and the single-sided contraction of `f`.
- **The denominator is the margin.** As `K → 1⁻`, the factor `1/(1−K) → ∞`. Theorem
  7.1 shows this divergence is genuine, not an artefact.

---

## 4. Lipschitz Parametric Banach Theorem

We now let the contraction vary over a parameter space.

**Theorem 4.1 (Lipschitz parametric fixed point, explicit constant).** Let
`(β, d_β)` be a (pseudo)metric parameter space and `F : β → (α → α)` a family such
that:

1. each `F(t)` is a `K`-contraction (`K < 1`): `d(F(t)(x), F(t)(y)) ≤ K · d(x, y)`;
2. the family is uniformly `L`-Lipschitz in the parameter:
   `d(F(s)(x), F(t)(x)) ≤ L · d_β(s, t)` for all `x`;
3. `x*(t)` is a fixed point of `F(t)` for each `t`.

Then the fixed-point map `t ↦ x*(t)` is `(L/(1−K))`-Lipschitz:
```
d(x*(s), x*(t)) ≤ (L / (1 − K)) · d_β(s, t).
```

*Proof sketch.* Apply Theorem 3.1 with `f := F(s)` (fixed point `x*(s)`) and
`g := F(t)` (fixed point `x*(t)`). The disagreement term is evaluated at `x*(t)`:
```
d(F(s)(x*(t)), F(t)(x*(t))) ≤ L · d_β(s, t)
```
by hypothesis (2). Substituting into the stability bound yields
```
d(x*(s), x*(t)) ≤ d(F(s)(x*(t)), F(t)(x*(t))) / (1 − K) ≤ (L/(1−K)) · d_β(s, t). ∎
```

**Sharpness of the constant.** The constant `L/(1−K)` is attained. Take `α = β = ℝ`,
`F(t)(x) = K·x + t`. Each `F(t)` is a `K`-contraction; the family is `1`-Lipschitz in
`t` (so `L = 1`); and `x*(t) = t/(1−K)`. Then
```
|x*(s) − x*(t)| = |s − t| / (1 − K) = (L/(1−K)) · |s − t|,
```
with equality. Numerically (Section 8) the measured amplification ratio equals
`1/(1−K)` to machine precision.

**Interpretation.** The equilibrium responds to parameter changes with amplification
factor at most `L/(1−K)`: linear in the family's parameter-Lipschitz constant `L` and
inversely proportional to the contraction margin `1 − K`. This is the precise robust-
ness budget of the system.

---

## 5. Equivariance of Fixed Points

Symmetries of a contraction family are inherited by the fixed point — not by
assumption, but by force of uniqueness.

**Theorem 5.1 (Equivariance).** Let `f, f', φ : α → α`. Suppose:

1. `f'` is a `K`-contraction (`0 ≤ K`, `K < 1`);
2. `φ` intertwines `f` and `f'`: `φ(f(x)) = f'(φ(x))` for all `x`;
3. `f(x) = x` and `f'(x') = x'`.

Then `φ(x) = x'`.

*Proof.* Evaluate the intertwining relation at the fixed point `x`:
```
f'(φ(x)) = φ(f(x)) = φ(x),
```
using `f(x) = x`. Hence `φ(x)` is a fixed point of `f'`. But `f'` is a `K`-contraction
with `K < 1`, so by Lemma 2.4 it has a unique fixed point. Since both `φ(x)` and `x'`
are fixed points of `f'`, they coincide: `φ(x) = x'`. ∎

**Remarks.**

- Equivariance is a *consequence*, not a hypothesis. One does not assume the fixed
  point respects the symmetry; uniqueness compels it.
- The formulation via a bare intertwining map `φ` is lighter than, and subsumes, a
  `MulAction`-based formulation: a group element `g` acting on both spaces with an
  equivariant family `F(g·t)(g·x) = g·F(t)(x)` is the special case `φ = (g·)`,
  `f = F(t)`, `f' = F(g·t)`.
- **Example.** With `f'(y) = K·y + b`, `φ(x) = a·x + c` (`a ≠ 0`), and `f` the
  conjugate `f = φ⁻¹ ∘ f' ∘ φ`, the intertwining holds identically and `φ` carries
  the fixed point of `f` to that of `f'` (verified numerically in Section 8: the
  symmetry `φ(x) = 2x + 5` sends `0 ↦ 5`).

---

## 6. Non-Autonomous Composition Rate

Adaptive algorithms apply a *schedule* of distinct maps. We bound the contraction
factor of an arbitrary finite composition.

**Definition 6.1 (Iterated composition).** For a sequence `g : ℕ → (α → α)` define
```
iteratedComp(g, 0)     = id,
iteratedComp(g, n + 1) = g(n) ∘ iteratedComp(g, n),
```
i.e. `iteratedComp(g, n) = g(n−1) ∘ ⋯ ∘ g(0)`.

**Theorem 6.2 (Non-autonomous composition rate).** Let `g : ℕ → (α → α)` and
`K : ℕ → ℝ` with `K(i) ≥ 0`, and suppose each `g(i)` is a `K(i)`-contraction:
`d(g(i)(x), g(i)(y)) ≤ K(i) · d(x, y)`. Then for all `n`,
```
d(iteratedComp(g, n)(x), iteratedComp(g, n)(y)) ≤ (∏_{i=0}^{n−1} K(i)) · d(x, y).
```

*Proof sketch.* Induction on `n`. For `n = 0`, `iteratedComp(g, 0) = id` and the
empty product is `1`, giving `d(x, y) ≤ 1 · d(x, y)`. For the inductive step, write
`iteratedComp(g, n+1) = g(n) ∘ iteratedComp(g, n)`. Apply the `K(n)`-contraction of
`g(n)` to the pair `iteratedComp(g, n)(x)`, `iteratedComp(g, n)(y)`, then the
induction hypothesis, and multiply by `K(n) ≥ 0`:
```
d(g(n)(u), g(n)(v)) ≤ K(n) · d(u, v) ≤ K(n) · (∏_{i<n} K(i)) · d(x, y)
                    = (∏_{i<n+1} K(i)) · d(x, y),
```
where `u = iteratedComp(g, n)(x)`, `v = iteratedComp(g, n)(y)`. ∎

**Remarks.**

- This generalizes the two-map composition law `d((f∘g)(x), (f∘g)(y)) ≤
  (K_f · K_g) · d(x, y)` to arbitrary finite schedules.
- **Convergence under degenerating factors.** If each `K(i) < 1` but `sup_i K(i) = 1`,
  the stationary bound `Kⁿ` is unavailable; nonetheless, whenever the shortfalls
  diverge, `∑_i (1 − K(i)) = ∞`, the product `∏_i K(i) → 0`, so the composed dynamics
  still drive any two trajectories together. This is the rigorous basis for the
  convergence of adaptive schedules (e.g. decaying learning rates) in which no single
  step is strongly contracting.
- Numerically (Section 8), constants `(0.5, 0.8, 0.3, 0.9)` give combined factor
  `0.108 = ∏ K_i`, attained with equality for affine maps.

---

## 7. Sharpness: Failure at `K = 1`

The contraction hypothesis `K < 1` is indispensable.

**Theorem 7.1 (No fixed point at `K = 1`).** The translation `T : ℝ → ℝ`, `T(x) =
x + 1`, satisfies `|T(x) − T(y)| = |x − y|` (it is a `1`-Lipschitz isometry, i.e. a
`K`-contraction with `K = 1`) and has no fixed point: there is no `x ∈ ℝ` with
`T(x) = x`.

*Proof.* For all `x, y`, `|T(x) − T(y)| = |(x+1) − (y+1)| = |x − y|`, so `T` is
`1`-Lipschitz. If `T(x) = x` then `x + 1 = x`, i.e. `1 = 0`, impossible. ∎

**Consequences.**

- The strict inequality `K < 1` in Banach's theorem cannot be weakened to `K ≤ 1`.
- The divergence of `1/(1−K)` in Theorems 3.1 and 4.1 as `K → 1⁻` reflects a real
  loss of control, not a defect of the proof: the limiting object can fail to have a
  fixed point altogether.
- The example also shows that completeness alone does not rescue the `K = 1` case;
  `ℝ` is complete, yet `T` has no fixed point.

---

## 8. Algorithms and Numerical Validation

We summarize the computational counterparts of the theory; full code accompanies
this paper.

**Algorithm A (Picard fixed-point solver).** Given a `K`-contraction `f`, a start
`x₀`, and a tolerance `ε`, iterate `x ← f(x)`; by Theorem 2.6 the error after `n`
steps is at most `Kⁿ · d(x₀, x*)`, so `n ≥ log(ε / d(x₀,x*)) / log K` steps suffice.
Complexity: `O(n)` map evaluations, each step geometrically reducing the error.

**Algorithm B (Stability/sensitivity certificate).** Given two maps `f` (a
`K`-contraction) and `g`, with fixed points `x_f`, `x_g` obtained from Algorithm A,
output the certified bound `d(f(x_g), g(x_g)) / (1 − K)` from Theorem 3.1 and verify
`d(x_f, x_g)` does not exceed it.

**Algorithm C (Schedule contraction factor).** Given constants `K_0, …, K_{n−1}`,
return `∏_i K_i` (Theorem 6.2) as the certified contraction factor of the composed
schedule `g_{n-1} ∘ ⋯ ∘ g_0`.

**Numerical results.** Across affine test families we observe:

| Result | Setup | Predicted | Measured |
|---|---|---|---|
| Stability (Thm 3.1) | `K = 0.6`, distinct fixed points | bound `2.0` | `d(x_f,x_g) = 2.0` |
| Lipschitz param. (Thm 4.1) | `K = 0.5, L = 1` | const `2.0` | ratio `2.0` (attained) |
| Equivariance (Thm 5.1) | `φ(x) = 2x+5` | `φ(0) = 5` | `5.0` |
| Composition (Thm 6.2) | `K = (0.5,0.8,0.3,0.9)` | `0.108` | `0.108` (attained) |
| Sharpness (Thm 7.1) | `T(x) = x+1` | no fixed point | iterates → ∞ |

In every case the measured quantity matches the theoretical bound, and the Lipschitz
and composition bounds are attained with equality for affine maps, confirming
sharpness of the constants.

---

## 9. Applications

- **Reinforcement learning.** The Bellman operator is a `γ`-contraction in the
  sup-norm (`γ` the discount factor). Theorem 4.1 bounds how much the optimal value
  function drifts under perturbations of the reward model or transition kernel by
  `L/(1−γ)`; Theorem 6.2 underwrites convergence of value iteration under changing
  operators (e.g. evolving function approximators).
- **Numerical analysis.** Theorem 3.1 certifies that a solver's computed equilibrium
  cannot deviate from the true equilibrium of a perturbed (e.g. rounded) operator by
  more than `(\text{operator perturbation})/(1−K)`.
- **Economics and game theory.** Market- and best-response equilibria defined as
  fixed points respond Lipschitz-continuously to shocks, with the explicit
  amplification budget `L/(1−K)` quantifying systemic fragility.
- **Physics and dynamical systems.** Theorem 5.1 formalizes the principle that
  symmetries of the dynamical law are inherited by self-consistent steady states.
- **Implicit function theorem.** The parametric contraction-mapping route to the
  implicit function theorem is exactly Theorem 4.1; the explicit constant `L/(1−K)`
  yields quantitative bounds on the implicitly defined solution map.

---

## 10. Discussion and Future Directions

The organizing lesson of this work is *centralization*: by isolating a single
stability inequality requiring only one-sided contraction, every parametric
phenomenon becomes a substitution rather than a fresh triangle-inequality argument.
Uniqueness, in turn, performs the algebra for free, converting symmetry hypotheses
into equivariance conclusions. We highlight five directions for extension.

1. **Lipschitz parametric theorem with explicit constants (consolidation).** Theorem
   4.1 already realizes the explicit `L/(1−K)` constant; the natural next step is to
   package it as the quantitative core of a parametric contraction-mapping proof of
   the implicit function theorem.

2. **Hölder fixed points for degenerating factors.** When the contraction factor
   itself varies, `K(t) < 1` for each `t` but `sup_t K(t) = 1`, Lipschitz regularity
   is lost. Conjecture: if `K(t) ≤ 1 − c · d(t, t₀)^β` for `β, c > 0`, then `t ↦
   x*(t)` is Hölder continuous near `t₀` with exponent determined by `β`. The
   denominator `1 − K(t)` in Theorem 3.1 degenerates as `K(t) → 1`, creating a
   singularity that Hölder regularity can still control; this bridges the sharp
   `K = 1` failure with the smooth `K < 1` theory (target API: `HolderWith`).

3. **Equivariant fixed points for group-parametrized families.** Promote Theorem 5.1
   to a genuine group action: if `G` acts on both parameter and state spaces and the
   family is equivariant (`F(g·t)(g·x) = g·F(t)(x)`), then `x*(g·t) = g·x*(t)`. The
   proof is the `φ = (g·)` instance of Theorem 5.1, connecting to the `MulAction`
   framework.

4. **Nadler's theorem (set-valued contractions).** For `F : α → Closeds(α)`
   contracting under the Hausdorff metric, a fixed point `x ∈ F(x)` exists. The
   Picard iteration adapts by choosing, at each step, a nearest point in the image;
   the Hausdorff contraction makes the resulting sequence Cauchy. The formalization
   challenge is the "choose nearest point" step against `EMetric.hausdorffDist`.

5. **Rate-optimal non-autonomous iteration.** Theorem 6.2 gives the finite product
   `∏ K_i` as the base case; extending to infinite products via the `HasProd` API,
   one obtains convergence guarantees precisely when `∑_i (1 − K_i) = ∞`, supplying
   rigorous foundations for adaptive learning-rate and warm-up/cool-down schedules.

---

## 11. Conclusion

A single inequality — the fixed-point stability bound — organizes the quantitative
theory of how self-consistent solutions depend on the systems that define them. It
delivers an explicit, sharp Lipschitz sensitivity constant `L/(1−K)`; it forces
equivariance under symmetries through uniqueness; and, generalized by induction, it
yields the product contraction rate `∏ K_i` for non-autonomous schedules. A minimal
counterexample, the isometry `x ↦ x + 1`, marks the exact boundary `K = 1` at which
the theory must fail. Together these results form a compact, fully formalized, and
broadly applicable account of parametric fixed-point stability.
