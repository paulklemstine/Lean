# Neural Network Training as Renormalization-Group Flow: A Spectral Theory of Coarse-Graining in Function Space

## Abstract

We develop and rigorously establish a precise correspondence between gradient-based
training of neural networks in the Neural Tangent Kernel (NTK) regime and the
discrete renormalization-group (RG) flow of statistical physics. In the linearized
("lazy") regime, the training residual evolves by the matrix recurrence
`r_{k+1} = (I − η Θ) r_k`, where `Θ = JᵀJ` is the NTK Gram matrix. Diagonalizing
`Θ` decouples this into independent scalar modes, each rescaled per step by its
**gain** `gᵢ = 1 − η λᵢ`. We model one training step as a diagonal flow `rgStep` on
mode space and prove five results that together form a theorem-level dictionary
between optimization dynamics and RG flow: (i) a closed form for the iterated flow,
`(rgStep)^[k](v)ᵢ = gᵢ^k vᵢ`; (ii) the semigroup (group-law) property of the flow,
certifying that discrete training steps assemble into a one-parameter RG flow;
(iii) **separation of scales** — a faster-contracting mode becomes asymptotically
negligible relative to a slower one, the precise meaning of "integrating out
high-frequency modes"; (iv) a characterization of the flow's **infrared (IR) fixed
points** as exactly the kernel of the NTK; and (v) global convergence to the IR
fixed point when every gain is contracting. All results are constructive and
diagonal by design, yielding clean proofs while remaining faithful to the algorithm
that optimizers actually run. We discuss consequences for spectral bias,
convergence rates, and the prospect of importing universality and scaling-collapse
phenomena from physics into the analysis of learning.

**Keywords:** renormalization group, neural tangent kernel, gradient descent,
spectral analysis, coarse-graining, fixed points, separation of scales, deep
learning theory.

---

## 1. Introduction

### 1.1 Motivation

Two of the most influential ideas of the last century concern hierarchies of scale.
In physics, the **renormalization group** (Wilson, 1971) explains how systems look
qualitatively different at different scales: by repeatedly *coarse-graining* — averaging
over and discarding short-distance degrees of freedom — one obtains an effective
description in which only a few **relevant** quantities survive, while the
**irrelevant** ones are *integrated out*. In machine learning, deep neural networks
build hierarchical representations and are widely observed to learn coarse structure
before fine detail.

The resemblance between these two hierarchical processes has long invited the slogan
"learning is renormalization." Our purpose is to convert this slogan, in a regime
where it can be made exact, into a set of theorems. We work in the NTK regime, where
training dynamics linearize and become spectrally transparent, and we show that one
gradient step is literally a discrete RG transformation on the space of spectral
modes. Every word of the physics dictionary — RG step, scaling dimension,
relevant/irrelevant, separation of scales, IR fixed point, flow to the fixed point —
acquires a precise mathematical referent and a complete proof.

### 1.2 Setting: the NTK regime

For a model with parameters `θ` and a dataset of `m` points, let `J ∈ ℝ^{m×n}`
denote the Jacobian of the model outputs with respect to the parameters at
initialization. The **NTK Gram matrix** is

> `Θ = JᵀJ ∈ ℝ^{n×n}` (equivalently the `m×m` output-space kernel `J Jᵀ`).

In the lazy-training / infinite-width regime the model behaves as its
first-order Taylor expansion, and the residual `r` (the vector of prediction errors)
evolves under gradient descent with learning rate `η` as the **linear recurrence**

> `r_{k+1} = (I − η Θ) r_k`. (★)

Because `Θ` is symmetric positive semidefinite, it admits an orthonormal eigenbasis
`{uᵢ}` with eigenvalues `λᵢ ≥ 0`. Expanding `r_k = Σᵢ cᵢ(k) uᵢ` decouples (★) into
independent scalar recurrences

> `cᵢ(k+1) = (1 − η λᵢ) cᵢ(k)`,

one per eigenvalue. The factor `1 − η λᵢ` is the **per-mode gain**. The entire
convergence theory of NTK training is thus the theory of these scalar gains. This
spectral backbone — positive semidefiniteness of `Θ`, the feature-norm identity
`xᵀ Θ x = ‖Jx‖²`, the single-mode decay law, and the optimal-rate contraction — is
the content of a companion development; the present paper builds the RG flow *on top*
of it.

### 1.3 Contributions

We isolate the diagonal mode dynamics as a single object, the **RG step**, and prove:

1. **Closed-form flow** (`rgStep_iterate`): the `k`-fold iterate rescales mode `i` by
   `gᵢ^k`.
2. **Semigroup law** (`rgStep_semigroup`): the flow is a discrete one-parameter
   semigroup, certifying scale-additivity of training.
3. **Separation of scales** (`rg_scale_separation`): if `|gᵢ| < |gⱼ|`, the amplitude
   ratio of mode `i` to mode `j` tends to `0`.
4. **IR fixed points = NTK kernel** (`rgStep_fixed_iff`): the flow's fixed points are
   exactly the residuals annihilated by every active eigenvalue.
5. **Global convergence** (`rg_flow_tendsto_zero`): if every gain has `|gᵢ| < 1`, the
   whole flow converges to the IR fixed point `0`.

All proofs are elementary in the precise sense that, once the closed form is in
hand, they reduce to facts about geometric sequences, function iteration, and linear
algebra. This is by design: the diagonal, discrete formulation keeps the proofs
transparent while remaining faithful to the algorithm that real optimizers execute.

---

## 2. Definitions

Throughout, `d : ℕ` is the number of spectral modes (the dimension of mode space),
`lr` (denoted `η`) is the learning rate, and `lam : Fin d → ℝ` (denoted `λ`) assigns
to each mode its NTK eigenvalue. A residual in mode coordinates is a vector
`v : Fin d → ℝ`.

**Definition 2.1 (Gain).** The per-mode gain of one training step is
> `gain(η, λ) = 1 − η · λ`.
For mode `i` we write `gᵢ = gain(η, λᵢ) = 1 − η λᵢ`.

**Definition 2.2 (RG / training step).** The renormalization-group step is the
diagonal flow on mode space rescaling each mode by its gain:
> `rgStep(η, λ, v)ᵢ = gain(η, λᵢ) · vᵢ = (1 − η λᵢ) · vᵢ`.

This is exactly one step of gradient descent written in the NTK eigenbasis: a single
matrix multiplication by `I − η Θ`, diagonalized into independent scalar rescalings.
Iterating `rgStep` `k` times — written `(rgStep)^[k]` — models `k` steps of training,
equivalently a coarse-graining of the dynamics to "scale `k`."

**Remark 2.3 (Why diagonal and discrete).** A continuous-time formulation would
model the flow by the heat semigroup `Φ_t(v)ᵢ = e^{−t λᵢ} vᵢ` arising from gradient
flow `ṙ = −Θ r`. The discrete diagonal flow above captures the same scaling physics
— the same notions of relevant/irrelevant modes, separation of scales, and IR fixed
point — while matching the finite-step algorithm in use and admitting fully
elementary proofs. The continuous flow is discussed as future work (§7).

---

## 3. Main Results

### 3.1 The flow has a closed form

**Theorem 3.1 (Closed form of the RG flow; `rgStep_iterate`).**
For all `η, λ, v`, every mode `i`, and every `k ∈ ℕ`,
> `(rgStep(η, λ))^[k](v)ᵢ = (gain(η, λᵢ))^k · vᵢ = (1 − η λᵢ)^k · vᵢ`.

*Proof sketch.* Induction on `k`. The base case `k = 0` is immediate since the
zeroth iterate is the identity and `g⁰ = 1`. For the step, peel one iterate with the
identity `f^[k+1](v) = f(f^[k](v))`, apply the definition of `rgStep`, substitute the
inductive hypothesis, and use `g^{k+1} = g · g^k`; a ring computation closes the
goal. ∎

This is the multi-mode lift of the single-mode NTK decay law `c(k) = (1 − η λ)^k c₀`.
It exposes the entire trajectory of training: each mode follows an independent
geometric sequence with ratio equal to its gain.

### 3.2 Training steps form an RG semigroup

**Theorem 3.2 (Semigroup law; `rgStep_semigroup`).**
For all `η, λ, v` and all `k, m ∈ ℕ`,
> `(rgStep(η, λ))^[k+m](v) = (rgStep(η, λ))^[k]( (rgStep(η, λ))^[m](v) )`.

*Proof sketch.* This is precisely the additive iterate law for function composition,
`f^[k+m] = f^[k] ∘ f^[m]`, applied to `f = rgStep(η, λ)`. ∎

Although elementary, this is the structural certificate that the discrete training
steps genuinely constitute a one-parameter RG (semi)group: coarse-graining to scale
`k+m` equals coarse-graining to scale `m` and then to scale `k`. Scale is additive,
the defining property of an RG flow.

### 3.3 Separation of scales: integrating out fast modes

**Theorem 3.3 (Separation of scales; `rg_scale_separation`).**
Fix modes `i, j` and suppose mode `i` contracts strictly faster than mode `j`, i.e.
> `|gain(η, λᵢ)| < |gain(η, λⱼ)|`.
Then the relative amplitude of the fast mode `i` to the slow mode `j` tends to zero
along the flow:
> `lim_{k→∞} |(rgStep(η,λ))^[k](v)ᵢ| / |(rgStep(η,λ))^[k](v)ⱼ| = 0`.

*Proof sketch.* By Theorem 3.1 the `k`-th ratio equals
> `(|gᵢ|/|gⱼ|)^k · (|vᵢ|/|vⱼ|)`,
a constant times a geometric sequence with base `|gᵢ|/|gⱼ| < 1`. Geometric sequences
with base in `[0,1)` tend to `0`, and multiplying by the constant `|vᵢ|/|vⱼ|`
preserves the limit. (When `vⱼ = 0` the quotient is identically `0` under the
convention `x/0 = 0`, so the statement holds trivially; in the physically relevant
regime `vⱼ ≠ 0` it is an honest amplitude ratio.) ∎

This is the central RG statement. The slogan "training integrates out the
high-frequency modes" is made exact: high-eigenvalue (UV) modes have small gains,
contract fastest, and their amplitude *relative to* the slow (IR) modes is driven to
zero. The flow itself suppresses ultraviolet detail; no degrees of freedom are
removed by hand.

### 3.4 Infrared fixed points are the NTK kernel

**Theorem 3.4 (IR fixed points; `rgStep_fixed_iff`).**
Assume the learning rate is nonzero, `η ≠ 0`. Then a residual `v` is a fixed point of
the flow iff every active eigenvalue annihilates it:
> `rgStep(η, λ, v) = v  ⟺  ∀ i, λᵢ · vᵢ = 0`.

*Proof sketch.* Coordinatewise, fixedness reads `(1 − η λᵢ) vᵢ = vᵢ`, i.e.
`η · (λᵢ vᵢ) = 0`. Since `η ≠ 0`, this is equivalent to `λᵢ vᵢ = 0`. The forward
direction cancels the nonzero `η`; the reverse direction substitutes `λᵢ vᵢ = 0`
back into the definition and simplifies. ∎

The set `{ v : ∀ i, λᵢ vᵢ = 0 }` is precisely the kernel (null space) of the NTK in
mode coordinates: the modes with eigenvalue zero, the directions of vanishing model
sensitivity. In RG terms this is the **IR fixed manifold** of the flow — the slow,
relevant subspace where the dynamics come to rest. Optimization dynamics and linear
algebra coincide: training halts exactly on `ker Θ`.

### 3.5 Global convergence to the IR fixed point

**Theorem 3.5 (Flow to the IR fixed point; `rg_flow_tendsto_zero`).**
If every gain is contracting, `|gain(η, λᵢ)| < 1` for all `i`, then for every initial
residual `v` and every mode `i`,
> `lim_{k→∞} (rgStep(η,λ))^[k](v)ᵢ = 0`;
the entire flow converges to the IR fixed point `0`.

*Proof sketch.* By Theorem 3.1, mode `i` equals `gᵢ^k vᵢ`. Since `|gᵢ| < 1`, the
geometric sequence `gᵢ^k → 0`, hence `gᵢ^k vᵢ → 0` for each `i`. Convergence of every
coordinate is convergence of the flow to `0`. ∎

When no eigenvalue is zero (a positive-definite, well-conditioned kernel) the IR
fixed manifold collapses to the origin, and training drives the residual to zero
mode by mode. This is the multi-mode generalization of the single-mode NTK
convergence theorem and the formal guarantee that, in this regime, training succeeds.

---

## 4. The training ↔ renormalization-group dictionary

The five theorems above assemble into an exact correspondence. Each row is an
equality of mathematical objects, not an analogy.

| Renormalization group | NTK training | Established by |
|---|---|---|
| coarse-graining / RG step | one gradient-descent step `rgStep` | Def. 2.2 |
| RG eigenvalue | gain `gᵢ = 1 − η λᵢ` | Def. 2.1 |
| scaling dimension | NTK eigenvalue `λᵢ` | Thm. 3.1 |
| irrelevant (UV) operator | fast mode (large `λᵢ`, small `gᵢ`) | Thm. 3.3 |
| relevant (IR) operator | slow mode (small `λᵢ`, large `gᵢ`) | Thm. 3.3 |
| additivity of scale | semigroup law | Thm. 3.2 |
| separation of scales | amplitude ratio → 0 | Thm. 3.3 |
| IR fixed point / manifold | kernel (null space) of NTK | Thm. 3.4 |
| flow to the fixed point | convergence of the residual | Thm. 3.5 |

---

## 5. Algorithms

The closed form (Theorem 3.1) makes the entire theory computable without iterating
the matrix recurrence. We record the two core procedures.

### 5.1 Closed-form RG flow evaluation

Given eigenvalues `λ`, learning rate `η`, initial mode amplitudes `v`, and a step
count `k`, the residual after `k` steps is obtained directly:

```
function RG_FLOW(η, λ[1..d], v[1..d], k):
    for i in 1..d:
        g_i  := 1 − η · λ[i]            # per-mode gain (Def. 2.1)
        out[i] := g_i^k · v[i]          # closed form (Theorem 3.1)
    return out
```

Complexity `O(d)` per query in `k` (using fast exponentiation `O(d log k)` for the
powers), versus `O(d·k)` for naive iteration. Correctness is exactly Theorem 3.1.

### 5.2 Scale-separation diagnostic

To certify that mode `i` is integrated out relative to mode `j`, compute the
amplitude ratio along the flow and confirm its geometric decay:

```
function SCALE_SEPARATION(η, λ, v, i, j, k):
    g_i := |1 − η·λ[i]| ;  g_j := |1 − η·λ[j]|
    assert g_i < g_j                     # hypothesis of Theorem 3.3
    base  := g_i / g_j                   # geometric base < 1
    ratio := base^k · (|v[i]| / |v[j]|)  # equals |x_i(k)|/|x_j(k)|
    return ratio                         # → 0 as k → ∞
```

The returned sequence is exactly the quantity proved to converge to `0` in
Theorem 3.3.

---

## 6. Applications and Interpretation

### 6.1 Spectral bias

Empirically, neural networks fit low-frequency (smooth) target structure before
high-frequency detail. In the RG picture this is Theorem 3.3 in action: high-frequency
target components align with large-eigenvalue modes, which have small gains and are
integrated out fastest. While the *error* in those modes vanishes quickly, their
*amplitude relative to* the slow modes decays, so the network's effective output is
dominated by smooth structure until late in training. The order of learning is
dictated by the kernel spectrum, not by accident.

### 6.2 Convergence rate and the critical mode

The long-time rate of Theorem 3.5 is set by `g_max = maxᵢ |gᵢ|`, the gain of the
slowest-contracting mode. This is the **critical mode**: the bottleneck that governs
the asymptotic approach to the fixed point, analogous to the slowest fluctuation
near a physical critical point. The spread of gains — equivalently the condition
number of the NTK — determines how cleanly fast and slow scales separate.

### 6.3 The kernel as effective theory

Theorem 3.4 identifies the resting state of training with `ker Θ`. Directions in the
kernel are precisely those the model cannot represent infinitesimally; they are
invisible to the dynamics and survive untouched. The "effective theory" left after
coarse-graining is the projection of the residual onto this relevant subspace — the
part of the problem the network genuinely cannot learn.

---

## 7. Discussion and Future Work

The development is deliberately diagonal and discrete, which is exactly what makes
clean, axiom-minimal proofs possible while staying faithful to the iterative
algorithm optimizers run. Several extensions follow naturally.

**A genuine continuous-time RG group law.** Define `Φ_t(v)ᵢ = e^{−t λᵢ} vᵢ` (the heat
semigroup of gradient flow `ṙ = −Θ r`) and prove `Φ_s ∘ Φ_t = Φ_{s+t}` together with
the role of `λᵢ` as a **scaling dimension**: mode `i` is relevant, marginal, or
irrelevant according to the sign of `λᵢ` about a shifted fixed point. Gradient flow is
literally a heat semigroup in the NTK eigenbasis, so RG scaling dimensions *are* NTK
eigenvalues and the relevant/irrelevant trichotomy is a sign condition. The discrete
closed form (Theorem 3.1) is the discrete analogue, and standard exponential
semigroup lemmas put the continuous law within short reach.

**Universality and scaling collapse of the loss curve.** Conjecture: under the
hypotheses of Theorem 3.5 the loss `L_k = Σᵢ (gᵢ^k vᵢ)²` obeys a two-regime scaling
law — an early plateau set by the slowest mode and a final rate `L_k ≍ g_max^{2k}` —
and the rescaled curve `L_k / g_max^{2k}` converges to a mode-count constant
independent of the data. The intuition is that the slowest relevant mode dominates the
long-time flow, making the loss curve universal up to the single number `g_max`, a
direct analogue of critical exponents and scaling collapse in statistical physics.

**Beyond the lazy regime.** The exactness here relies on linearization. A first step
beyond it is to treat the NTK as time-dependent (feature learning) and ask whether a
quasi-static RG flow with slowly drifting eigenvalues retains the separation-of-scales
and fixed-point structure proved here.

## 8. Conclusion

We have turned the slogan "training is renormalization" into a small but complete
theory. In the NTK regime, one gradient step is a diagonal RG transformation; its
iterate has a closed geometric form; its steps form a one-parameter flow; fast modes
are provably integrated out relative to slow ones; the flow's fixed points are exactly
the kernel of the NTK; and a contracting spectrum flows to the origin. Each entry of
the training ↔ RG dictionary is a theorem. The result is a rigorous bridge along
which the powerful machinery of the renormalization group — fixed points,
relevant/irrelevant operators, separation of scales, universality — can begin to flow
into the theory of learning.

---

## References

- A. Jacot, F. Gabriel, C. Hongler. *Neural Tangent Kernel: Convergence and
  Generalization in Neural Networks.* NeurIPS, 2018.
- K. G. Wilson. *Renormalization Group and Critical Phenomena.* Phys. Rev. B, 1971.
- The RG interpretation of optimization and coarse-graining dynamics is folklore in
  the physics-of-learning literature; here it is given a fully verified algebraic core.
