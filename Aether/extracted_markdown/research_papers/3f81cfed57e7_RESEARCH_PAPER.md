# Hodge–Laplacian Message Passing: Exact Mode Dynamics and Polynomial Filters

## Abstract

We give an exact, two-sided spectral theory for linear message passing driven by a
symmetric positive-semidefinite operator `L` on a real inner-product space — the
abstract setting that contains graph Laplacians, up/down Hodge Laplacians `L = BᵀB`,
and the full Hodge Laplacian `Δ = d*d + e e*`. The basic layer is the gradient step
`mpStep(L, α) = 1 - αL`. Prior work established a *one-sided* upper bound on the rate
at which depth-`k` message passing converges to the harmonic (cohomology) subspace
`ker L`: the residual energy is at most `ρ^k` times its initial value. We sharpen this
into an exact, modewise dynamical theory. On a genuine eigenvector `L v = ν v`, the
layer acts as scalar multiplication by `1 - αν`; iterating yields the closed-form
geometric orbit `(1-αν)^k v`, with energy *exactly* `(1-αν)^{2k}⟨v,v⟩`. Specializing
to the slowest nonzero mode `ν = μ` (the spectral gap), the distance-to-harmonic
energy equals `σ^k⟨v,v⟩` with `σ = (1-αμ)²`, proving the earlier upper bound is
attained; inverting the equality shows that reaching a tolerance `ε` *forces*
`σ^k < ε/⟨v,v⟩`, a quantitative oversmoothing lower bound (logarithmic depth is
necessary). We then generalize from a single step to an arbitrary degree-`m`
polynomial filter `p(L) = ∏ᵢ(1 - αᵢL)` with `p(0)=1`, modeled as a composition of
gradient steps, and show that the entire structural calculus transfers verbatim:
harmonics remain exact fixed points, the filter acts on a mode as the scalar `p(ν)`,
and energy scales by `p(ν)²`. The degree-two (heavy-ball) filter is exhibited as the
explicit quadratic `1 - (α+β)L + αβL²`. All results are stated for a general
symmetric PSD `L` and are fully constructive. The upshot is a clean separation: the
operator-level dynamics are settled with equalities, and filter design reduces to a
classical Chebyshev extremal problem for real polynomials on `[μ, λ]`.

**Keywords.** Hodge Laplacian, message passing, oversmoothing, spectral graph
filters, Chebyshev acceleration, harmonic projection, cohomology, geometric decay.

---

## 1. Introduction

### 1.1 Motivation

Message-passing architectures dominate learning on relational and geometric data.
Their elementary operation diffuses information along the edges of a graph or the
faces of a complex, and their depth — the number of stacked layers — is the primary
lever of expressivity. Yet on graphs, depth is treacherous: beyond a modest number
of layers, node representations contract toward a low-dimensional, often
one-dimensional, subspace, a phenomenon known as **oversmoothing**. The network
forgets local structure and outputs a near-constant signal. This is widely
attributed to the spectral properties of the underlying Laplacian, but the folklore
is mostly one-sided ("blur is no worse than rate `ρ`") and qualitative.

The cleanest mathematical home for the surviving signal is **Hodge theory**. For a
symmetric positive-semidefinite operator `L` — paradigmatically `L = BᵀB` for a
boundary operator `B`, or the full Hodge Laplacian `Δ = d*d + e e*` — the kernel
`ker L` is the space of **harmonic** elements, isomorphic to a cohomology group and
hence a topological invariant of the underlying complex. The natural questions are:

1. *Exactly* how fast does depth-`k` message passing converge to `ker L`, and is the
   spectral rate necessary, not merely sufficient?
2. Does the structural picture (harmonics fixed, residual contracted) survive the
   passage from a single gradient step to the higher-order **polynomial / Chebyshev
   filters** used in practice?

### 1.2 Contributions

We answer both affirmatively and constructively. Working entirely at the level of a
symmetric PSD operator `L` on a real inner-product space `E`, we prove:

- **Exact modewise dynamics.** On an eigenvector `L v = ν v`, `mpStep(L,α)` is scalar
  multiplication by `1-αν` (Theorem 3.1); the depth-`k` orbit is the closed form
  `(1-αν)^k v` (Theorem 3.2); the energy is exactly `(1-αν)^{2k}⟨v,v⟩` (Theorem 3.3).
- **Tight oversmoothing.** On the slowest nonzero mode the distance-to-harmonic
  energy equals `σ^k⟨v,v⟩` with `σ=(1-αμ)²` (Theorem 4.1) — the prior upper bound is
  *attained* — and sub-tolerance accuracy forces `σ^k < ε/⟨v,v⟩` (Theorem 4.2), a
  logarithmic-depth lower bound.
- **Polynomial filters.** Modeling a degree-`m` filter as a composition of gradient
  steps (Definition 5.1), harmonics remain exact fixed points (Theorem 5.2), the
  filter acts on a mode as the scalar `p(ν)=∏(1-αᵢν)` (Theorem 5.3), energy scales by
  `p(ν)²` (Theorem 5.4), and the heavy-ball filter is the explicit quadratic
  `1-(α+β)L+αβL²` (Theorem 5.5).

The results form a *two-sided* theory: combined with the previously known upper
bound they pin the convergence rate exactly on the extremal mode, and they reduce
accelerated-filter design to a finite real-analysis problem on `[μ,λ]`.

### 1.3 Relation to prior convergence theory

A companion development established the *upper* side of the picture for the single
gradient step. We recall its key facts because our results sit precisely against
them; all are properties of `mpStep(L,α) = 1 - αL` viewed as an element of the
endomorphism algebra `End(E)`:

- **Linearity / harmonic fixing.** `mpStep` is linear, and if `L h = 0` then
  `mpStep(L,α) h = h`, hence `(mpStep(L,α))^k h = h` for all `k`.
- **Additive transport.** For `L h = 0`, `(mpStep(L,α))^k (h + r) = h + (mpStep(L,α))^k r`.
- **Per-layer contraction.** From Rayleigh bounds `μ⟨x,x⟩ ≤ ⟨x,Lx⟩` and
  `⟨Lx,Lx⟩ ≤ λ⟨x,Lx⟩`, one layer satisfies
  `⟨mpStep(L,α)x, mpStep(L,α)x⟩ ≤ (1 - αμ(2-αλ))⟨x,x⟩` for `0 ≤ α`, `αλ ≤ 2`.
- **Geometric decay & convergence.** If each layer contracts energy by `ρ∈[0,1)`,
  then `⟨(mpStep)^k r, (mpStep)^k r⟩ ≤ ρ^k⟨r,r⟩`, and the distance from
  `(mpStep)^k(h+r)` to `h` is below any `ε>0` for sufficiently large depth.
- **Optimal step.** The factor `1-αμ(2-αλ)` is minimized at `α=1/λ`, where it equals
  `1-μ/λ`; the identity `(1-αμ(2-αλ)) - (1-μ/λ) = μ(αλ-1)²/λ ≥ 0` is a perfect square.

The present paper turns the inequality `≤ ρ^k⟨r,r⟩` into an equality on each mode and
extends every structural lemma to polynomial filters.

---

## 2. Setting and notation

Throughout, `E` is a real inner-product space (`NormedAddCommGroup` with a real
`InnerProductSpace` structure), `⟨·,·⟩` is its inner product, and `⟨v,v⟩ ≥ 0` is the
*energy* of `v`. We write `L : E → E` for a linear operator that we take to be
**symmetric** (`⟨Lx,y⟩ = ⟨x,Ly⟩`) and **positive semidefinite** (`⟨Lx,x⟩ ≥ 0`).
Canonical instances:

- The **graph Laplacian** `L = D - A` (degrees minus adjacency), symmetric PSD.
- The **up/down Hodge Laplacian** `L = BᵀB`, where `B` is a discrete boundary /
  coboundary operator; `ker L = ker B` is the harmonic subspace.
- The **full Hodge Laplacian** `Δ = d*d + e e* = up + down`, with `up`, `down`
  symmetric PSD and `ker Δ = ker up ∩ ker down` the space of closed-and-coclosed
  (harmonic) elements, isomorphic to cohomology.

We denote by `0 < μ ≤ λ` the smallest nonzero and largest eigenvalues of `L` on the
orthogonal complement of `ker L`. The quantity `μ` is the **spectral gap**.

> **Definition 2.1 (message-passing layer).** For `α ∈ ℝ`, the layer is
> $$ \mathrm{mpStep}(L,\alpha) := 1 - \alpha\,L \in \mathrm{End}(E), \qquad \mathrm{mpStep}(L,\alpha)\,x = x - \alpha\,(L\,x). $$
> Depth-`k` message passing is the `k`-fold composition `(\mathrm{mpStep}(L,\alpha))^k`.

Because `mpStep(L,α)` is an endomorphism, every power `(mpStep)^k` is automatically
linear; this is the structural backbone that makes all proofs short inductions.

---

## 3. Exact action on a spectral mode

The starting observation is that on an eigendirection the affine machinery of
message passing collapses to scalar multiplication.

> **Theorem 3.1 (exact action on a mode, `mpStep_eigenvector`).** If `L v = ν v`,
> then `mpStep(L,α) v = (1 - αν) v`.

*Proof sketch.* Unfold the definition: `mpStep(L,α) v = v - α(Lv) = v - α(νv) =
(1-αν)v`, using `Lv = νv` and `α(νv) = (αν)v`. The Lean proof is `simp [mpStep, hv,
smul_smul]` followed by `sub_smul`/`one_smul` to combine `1·v - (αν)·v = (1-αν)·v`. ∎

Iterating and using the closed multiplicativity of scalars gives the orbit.

> **Theorem 3.2 (closed-form orbit, `mpStep_iterate_eigenvector`).** If `L v = ν v`,
> then for all `k ∈ ℕ`,
> $$ (\mathrm{mpStep}(L,\alpha))^k\, v = (1-\alpha\nu)^k\, v. $$

*Proof sketch.* Induction on `k`. Base case `k=0`: both sides are `v`. Step: apply
one more layer to the inductive hypothesis,
`(mpStep)^{k+1} v = mpStep((1-αν)^k v) = (1-αν)^k·mpStep(v)` (by linearity)
`= (1-αν)^k·(1-αν)v = (1-αν)^{k+1}v`, using Theorem 3.1 and `smul_smul`. ∎

Energy then follows by sesquilinearity of the inner product, with no inequality.

> **Theorem 3.3 (exact energy, `mpStep_iterate_eigenvector_energy`).** If `L v = ν v`,
> then for all `k`,
> $$ \big\langle (\mathrm{mpStep}(L,\alpha))^k v,\ (\mathrm{mpStep}(L,\alpha))^k v\big\rangle = (1-\alpha\nu)^{2k}\,\langle v,v\rangle. $$

*Proof sketch.* Substitute Theorem 3.2 and pull scalars out of both arguments via
`⟨c·u, c·w⟩ = c²⟨u,w⟩` (real `inner_smul_left`/`inner_smul_right`); then
`(1-αν)^k·(1-αν)^k = (1-αν)^{2k}`. ∎

The conceptual content: **every mode is an independent geometric sequence.** The
harmonic modes (`ν = 0`) have factor `1`, so are invariant at every depth; all other
modes contract or expand by `|1-αν|`. For `0 < α < 2/λ` every nonzero mode strictly
contracts, and the network drives the state to `ker L`.

---

## 4. Tight oversmoothing on the slowest nonzero mode

Specialize Theorem 3.3 to the *slowest* nonzero mode, `ν = μ`. Its harmonic
component is zero, so the residual energy *is* the full energy, and the decay rate is
exact.

> **Theorem 4.1 (tight oversmoothing, `oversmoothing_exact`).** If `L v = μ v`, then
> for all `k`,
> $$ \big\langle (\mathrm{mpStep}(L,\alpha))^k v,\ (\mathrm{mpStep}(L,\alpha))^k v\big\rangle = \sigma^k\,\langle v,v\rangle, \qquad \sigma := (1-\alpha\mu)^2. $$

*Proof sketch.* Theorem 3.3 gives `(1-αμ)^{2k}⟨v,v⟩`; rewrite `(1-αμ)^{2k} =
((1-αμ)^2)^k = σ^k` by `pow_mul`. ∎

This matches the *shape* of the previously known upper bound `ρ^k⟨r,r⟩` and shows it
is **attained**: the geometric convergence rate is not an artifact of a loose
estimate but the exact dynamics of the extremal mode. Because the relation is an
equality, it can be inverted into a depth lower bound.

> **Theorem 4.2 (logarithmic depth is necessary, `oversmoothing_depth_necessary`).**
> Suppose `L v = μ v` and `⟨v,v⟩ > 0`. If, at depth `k`, the energy of the iterate is
> below `ε`, then necessarily
> $$ \sigma^k < \frac{\varepsilon}{\langle v,v\rangle}, \qquad \sigma = (1-\alpha\mu)^2. $$

*Proof sketch.* By Theorem 4.1 the hypothesis `⟨(mpStep)^k v, (mpStep)^k v⟩ < ε`
reads `σ^k⟨v,v⟩ < ε`. Divide by `⟨v,v⟩ > 0` (`lt_div_iff₀`) to obtain
`σ^k < ε/⟨v,v⟩`. ∎

Taking logarithms (valid whenever `0 ≤ σ < 1`, i.e. `0 < α < 2/μ`) gives the
operational reading
$$ k \;>\; \frac{\log(\langle v,v\rangle/\varepsilon)}{\log(1/\sigma)} \;=\; \frac{\log(\langle v,v\rangle/\varepsilon)}{-2\log|1-\alpha\mu|}. $$
At the optimal step `α = 1/λ`, `σ = (1-μ/λ)^2`, so the required depth is
`Θ(log(1/ε) / log(1/(1-μ/λ)))`, scaling like `λ/μ · log(1/ε)` when `μ ≪ λ`. **A small
spectral gap forces deep networks.** This is the rigorous lower-bound counterpart to
the convergence (upper-bound) story, completing a two-sided depth law.

---

## 5. Polynomial (Chebyshev-type) filters

A practical layer is rarely a single gradient step. Spectral graph networks use
**polynomial filters**: a degree-`m` polynomial `p(L)` of the operator. We model
such a filter as a *composition of single steps*, which keeps every proof a one-line
induction in the endomorphism monoid.

> **Definition 5.1 (polynomial filter, `mpFilter`).** For a list of step sizes
> `αs = [α₁, …, α_m]`,
> $$ \mathrm{mpFilter}(L, \alpha s) := \prod_{i=1}^{m} \mathrm{mpStep}(L, \alpha_i) = \prod_{i=1}^m (1 - \alpha_i L) \in \mathrm{End}(E), $$
> realized as the `List.prod` of the mapped steps. Two definitional reductions hold:
> `mpFilter(L, [\,]) = 1` (`mpFilter_nil`) and
> `mpFilter(L, a::αs) = mpStep(L,a)·mpFilter(L,αs)` (`mpFilter_cons`).

Expanding the product shows `mpFilter` is literally a polynomial `p(L)` with the
normalization `p(0) = ∏(1 - αᵢ·0) = 1`. The normalization is exactly what protects
the harmonics.

> **Theorem 5.2 (harmonics are fixed by every filter, `mpFilter_harmonic_fixed`).**
> If `L h = 0`, then `mpFilter(L, αs) h = h` for every list `αs`.

*Proof sketch.* Induction on `αs`. Empty list: `1·h = h`. Cons: by `mpFilter_cons`,
`mpFilter(L,a::αs)h = mpStep(L,a)(mpFilter(L,αs)h) = mpStep(L,a)h = h`, using the
inductive hypothesis and `mpStep` fixing harmonics (`mpStep(L,a)h = h - a(Lh) = h`
since `Lh = 0`). ∎

> **Theorem 5.3 (filter acts as a scalar polynomial, `mpFilter_eigenvector`).** If
> `L v = ν v`, then
> $$ \mathrm{mpFilter}(L, \alpha s)\,v = \Big(\prod_{i} (1-\alpha_i\nu)\Big) v = p(\nu)\,v. $$

*Proof sketch.* Induction on `αs`. Empty: `1·v = v` matches the empty product `1`.
Cons: `mpFilter(L,a::αs)v = mpStep(L,a)(mpFilter(L,αs)v) = mpStep(L,a)((∏ᵢ(1-αᵢν))v)
= (∏ᵢ(1-αᵢν))·mpStep(L,a)v = (∏ᵢ(1-αᵢν))·(1-aν)v`, by linearity and Theorem 3.1,
which is `(∏ over a::αs)·v`. ∎

> **Theorem 5.4 (filter energy, `mpFilter_eigenvector_energy`).** If `L v = ν v`,
> then
> $$ \big\langle \mathrm{mpFilter}(L,\alpha s)\,v,\ \mathrm{mpFilter}(L,\alpha s)\,v\big\rangle = p(\nu)^2\,\langle v,v\rangle, \qquad p(\nu) = \prod_i (1-\alpha_i\nu). $$

*Proof sketch.* Substitute Theorem 5.3 and pull the scalar `p(ν)` out of both inner
arguments (`inner_smul_left`/`inner_smul_right`), giving `p(ν)²⟨v,v⟩`. ∎

Finally, the degree-two filter exhibits the polynomial structure explicitly. The
*heavy-ball* method composes two steps with sizes `α`, `β`.

> **Theorem 5.5 (heavy-ball quadratic, `mpStep_comp_eq`).** As endomorphisms,
> $$ \mathrm{mpStep}(L,\alpha)\,\mathrm{mpStep}(L,\beta) = 1 - (\alpha+\beta)\,L + \alpha\beta\,L^2. $$

*Proof sketch.* Expand `(1-αL)(1-βL) = 1 - βL - αL + αβL·L = 1 - (α+β)L + αβL²` in the
ring `End(E)`, where `L² = L·L`. ∎

### 5.1 Consequence: filter design is a scalar Chebyshev problem

Theorems 5.2–5.4 say that *every* `p(0)=1` polynomial filter is, modewise, scalar
multiplication by `p(ν)`, leaving harmonics (`ν=0`) fixed. The operator-level
bookkeeping is therefore complete, and accelerating convergence reduces to choosing a
real polynomial `p` with `p(0)=1` minimizing the worst-case contraction over the
active band `[μ, λ]`:
$$ \rho_m := \min_{\substack{\deg p = m \\ p(0)=1}}\ \max_{\nu \in [\mu, \lambda]} |p(\nu)|. $$
This is the classical Chebyshev minimax problem; its solution is the shifted
Chebyshev polynomial, with optimal value
$$ \rho_m = \frac{\big((\sqrt{\lambda}-\sqrt{\mu})/(\sqrt{\lambda}+\sqrt{\mu})\big)^m}{T_m\!\big((\lambda+\mu)/(\lambda-\mu)\big)}, $$
where `T_m` is the degree-`m` Chebyshev polynomial of the first kind. The asymptotic
rate per unit degree improves from `1 - μ/λ` (plain step) to `1 - 2\sqrt{μ/λ}`
(Chebyshev) — a quadratic speedup in the dependence on the spectral gap.

---

## 6. Algorithms

We summarize the computational content as three algorithms (Python implementations
accompany this paper).

**Algorithm A — Exact modewise oversmoothing trace.** Given `L`, step `α`, a target
mode `v` with eigenvalue `ν`, and depth `K`, return both the *measured* energies
`⟨(mpStep)^k v, (mpStep)^k v⟩` (by iterating the layer) and the *predicted* energies
`(1-αν)^{2k}⟨v,v⟩` (Theorem 3.3), confirming the equality numerically. Cost: `O(K·c)`
where `c` is the cost of one matrix-vector product with `L`.

**Algorithm B — Necessary-depth oracle.** Given the spectral gap `μ`, step `α`, mode
energy `⟨v,v⟩`, and tolerance `ε`, return the exact minimal depth
`k* = ⌈log(⟨v,v⟩/ε)/log(1/σ)⌉` with `σ=(1-αμ)²` (the inversion of Theorem 4.2), and
verify `σ^{k*}⟨v,v⟩ < ε ≤ σ^{k*-1}⟨v,v⟩`. Cost: `O(1)`.

**Algorithm C — Polynomial-filter evaluation and Chebyshev comparison.** Given `L`
and step sizes `[α₁,…,α_m]`, build `mpFilter` either as the operator
`∏(1-αᵢL)` or, on a mode, as the scalar `∏(1-αᵢν)` (Theorem 5.3), and compare the
worst-case band contraction `max_{ν∈[μ,λ]}|p(ν)|` of a plain repeated step against
the shifted-Chebyshev optimum. Cost: `O(m·c)` for operator application; `O(m)` for
the scalar evaluation.

---

## 7. Applications

**Graph and simplicial neural networks.** The exact mode dynamics quantify
oversmoothing precisely: a deep network is a harmonic projector with a known,
spectral-gap-controlled rate. Theorem 4.2 gives an honest *lower* bound on the depth
needed to suppress a given low-frequency mode, useful for diagnosing when a graph's
small spectral gap (bottlenecks, long chains) makes plain message passing
impractical, and Theorem 5.4 prescribes the polynomial-filter remedy.

**Topological signal processing.** When `L = BᵀB` is a Hodge Laplacian, the harmonic
survivors are representatives of (co)homology — flows with no source or sink,
circulation around the holes of a complex. Deep message passing computes these
representatives, and the polynomial-filter framework lets one shape the spectral
response (e.g. extract a chosen frequency band) while leaving the topological content
untouched, since every `p(0)=1` filter fixes `ker L` (Theorem 5.2).

**Accelerated linear solvers.** The heavy-ball identity (Theorem 5.5) and the
Chebyshev reduction (§5.1) place momentum and Chebyshev semi-iteration in one frame:
both are `p(0)=1` polynomials of `L`, and their convergence is governed exactly by
the modewise factor `p(ν)`. The framework thus connects deep-network depth to
classical iterative-solver acceleration.

---

## 8. Discussion

The technical lever throughout is to treat the layer as an element of the
endomorphism algebra `End(E)`, so that powers and products are *automatically*
linear; convergence and filter facts then reduce to scalar recursions on the factor
`1-αν`. The decisive conceptual step is to state the dynamics on a *genuine
eigenvector* rather than against an abstract contraction hypothesis: that single
change turns the prior `≤ ρ^k⟨r,r⟩` into an exact `= σ^k⟨v,v⟩`, and an equality —
unlike an inequality — can be inverted into a depth lower bound. The polynomial-filter
results show the calculus is robust: nothing about harmonic fixing or modewise
scaling depends on the *degree* of the filter, only on the normalization `p(0)=1`.

The separation of concerns is the practical payoff. The infinite-dimensional,
operator-level part — *harmonics fixed exactly, each mode a scalar, energy tracked
with equality* — is fully discharged. What remains for accelerated design is a
finite, classical extremal problem for real polynomials on `[μ,λ]`, where the
Chebyshev optimum and its quadratic speedup are well understood.

---

## 9. Future directions

**1. Two-sided `Θ(log(1/ε)/log(1/σ))` depth law.** Fuse the known upper bound with
the new lower bound (Theorems 4.1–4.2) into a single closed-form depth law: the
minimal depth with residual energy below `ε` is exactly
`⌈log(⟨v,v⟩/ε)/log(1/σ)⌉` on the extremal mode. The remaining ingredient is the
monotone inversion of the geometric law (`Real.logb`/`Nat.ceil`), turning the
one-line division of Theorem 4.2 into a sharp two-sided count.

**2. Chebyshev optimality of the degree-`m` filter.** Prove the conjectured optimum
`ρ_m = ((√λ-√μ)/(√λ+√μ))^m / T_m((λ+μ)/(λ-μ))` for the worst-case band contraction
`max_{ν∈[μ,λ]}|p(ν)|` over `p(0)=1` of degree `m`. The operator work is finished
(Theorem 5.3), so this is the classical minimax problem; the degree-two (heavy-ball)
case `min_{α,β} max_{[μ,λ]}|1-(α+β)ν+αβν²|` is a two-variable optimization amenable to
direct algebraic attack, validating the pattern.

**3. The limit is the orthogonal projection onto `ker L`.** Upgrade the single-mode
limit to the global statement `(mpStep(L,α))^k x → proj_{ker L} x` in norm. Additive
transport already splits `x = h + r` with `h` fixed and `r` contracted; for symmetric
PSD `L`, `r ∈ (ker L)^⊥ = range L`, so the split is the orthogonal decomposition and
uniqueness forces `h = proj x`.

**4. Unconditional contraction for `L = BᵀB` via the spectral theorem.** Replace the
per-layer contraction *hypothesis* by a *theorem* for concrete coboundaries: with `μ`
the smallest nonzero and `λ` the largest eigenvalue, every step `α∈(0,2/λ)` yields
`ρ = 1 - αμ(2-αλ) < 1` on `(ker L)^⊥`. Expanding `x` in an eigenbasis, the modewise
energy (Theorem 3.3) sums termwise to the global bound, making the pipeline
unconditional.

**5. Full Hodge Laplacian `Δ = d*d + e e*`.** Extend every result to the full Hodge
Laplacian, with the limit the projection onto `ker Δ` (the Betti space) and the rate
set by the smallest nonzero eigenvalue of `Δ`, the exact and coexact residuals
contracted simultaneously. Since `Δ` is symmetric PSD with `ker Δ = ker d ∩ ker e*`
fixed by `1-αΔ`, Theorems 3.1 and 5.2 apply unchanged once `Δ` replaces `L`; only the
spectral bounds (Direction 4) remain.

---

## 10. Conclusion

Deep linear message passing on a symmetric PSD operator is, mode by mode, a family of
independent geometric sequences: the harmonic core is fixed exactly, every other
frequency decays as a fixed power, and the slowest nonzero mode — governed by the
spectral gap — sets an exact, invertible clock. This equality-level control proves
that oversmoothing is a quantitative law (logarithmic depth is *necessary*, not just
sufficient), and it survives verbatim the generalization from a single gradient step
to any `p(0)=1` polynomial filter. The result is a clean factorization of the
problem: the operator dynamics are settled with equalities, and accelerated filter
design becomes a classical Chebyshev problem on the spectral band `[μ, λ]`.
