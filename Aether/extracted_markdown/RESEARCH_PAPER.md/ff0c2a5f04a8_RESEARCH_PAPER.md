# Shannon Entropy on Finite Probability Distributions: A First-Principles Formalization via the Surprise Function

## Abstract

We present a self-contained, first-principles development of Shannon entropy for
probability distributions on finite types. The central design decision is to
express entropy entirely through the *surprise function*
`s(x) = −x · log x`, with the convention `s(0) = 0` built into the function rather
than patched on as a side condition. This single choice eliminates the
`0 · log 0` indeterminate form that has historically been the most error-prone
point in rigorous treatments of entropy. On this foundation we establish four
cornerstone theorems of information theory: (i) **non-negativity** of entropy on
sub-distributions; (ii) **additivity** `H(p ⊗ q) = H(p) + H(q)` over independent
(product) distributions; (iii) the **uniform entropy** identity `H(uniform) =
log n`; and (iv) the **maximum entropy theorem** `H(p) ≤ log n`, obtained by
feeding the concavity of the surprise function into Jensen's inequality with
uniform weights. The pairing of (iii) and (iv) renders precise the slogan
"uniform = maximal uncertainty." We give complete proof sketches, discuss the
algorithmic content, present numerical demonstrations, and outline a research
program — conditional entropy and the chain rule, KL divergence, mutual
information, and integrated-information measures — that builds directly on the
lemmas established here.

**Keywords:** Shannon entropy, information theory, concavity, Jensen's inequality,
maximum entropy principle, surprise function, finite probability distributions.

---

## 1. Introduction

Shannon's entropy `H(p) = −Σₓ p(x) log p(x)` is the quantitative cornerstone of
information theory. It measures the average uncertainty of a random variable,
quantifies the ultimate limit of lossless compression, and underlies the
operational notions of channel capacity, mutual information, and statistical
inference. Despite its centrality, a fully rigorous, modular development of
entropy must contend with a stubborn analytic wrinkle: the term `p(x) log p(x)`
is an indeterminate form `0 · (−∞)` when `p(x) = 0`. The conventional remedy is to
*define* `0 · log 0 = 0` (justified as the limit `lim_{t→0⁺} t log t = 0`) and
then verify that this convention is consistent with every subsequent manipulation.
In practice this verification is the single most common source of gaps and errors.

This paper adopts a structural solution. We never write `−p log p` directly.
Instead, every term is routed through the **surprise function**

> `s(x) := −x · log x,   s(0) := 0,`

a function that already carries — as established facts — continuity on `[0, ∞)`,
non-negativity on `[0, 1]`, the multiplicative identity `s(ab) = b·s(a) + a·s(b)`,
and concavity. Because `s(0)` is *defined* to be `0`, the indeterminate form never
arises; the `0 · log 0` convention is absorbed into the definition of `s` and never
needs to be invoked again. Entropy is then simply the finite sum of surprises,

> `H(p) := Σₓ s(p(x)).`

The remainder of the paper develops four cornerstone theorems on this foundation
and surveys the research program they enable.

### 1.1 Contributions

1. A formalization of finite Shannon entropy as `H(p) = Σₓ s(p(x))` with the
   `0·log 0` convention dissolved into the surprise function `s`.
2. **Non-negativity:** `0 ≤ H(p)` for any `p : α → [0,1]`.
3. **Additivity:** `H(p ⊗ q) = H(p) + H(q)` for product distributions, reduced to
   the algebraic identity `s(ab) = b·s(a) + a·s(b)`.
4. **Uniform entropy:** `H(uniform_n) = log n` on an `n`-element type.
5. **Maximum entropy:** `H(p) ≤ log n`, a one-line consequence of concave Jensen
   on `s` with uniform weights; equality holds for the uniform distribution by (4).

---

## 2. Definitions

Throughout, `α` and `β` denote finite, inhabited types, and `n := |α|` denotes the
cardinality of `α`. All logarithms are natural logarithms; results transfer to any
base by the change-of-base constant, which only rescales `H`.

### Definition 2.1 (Surprise function)

The **surprise function** `s : ℝ → ℝ` is

> `s(x) = −x · log x` for `x > 0`,  and  `s(0) = 0`.

We record the four properties of `s` that the development uses, each a standard
fact of real analysis:

- **(S1) Non-negativity on the unit interval.** If `0 ≤ x ≤ 1` then `s(x) ≥ 0`,
  because `log x ≤ 0` there, so `−x log x ≥ 0`.
- **(S2) Multiplicativity.** For all `a, b ≥ 0`, `s(a·b) = b·s(a) + a·s(b)`. This
  follows from `log(ab) = log a + log b` and distributing `−ab`.
- **(S3) Concavity.** `s` is concave on `[0, ∞)` (its second derivative is
  `−1/x < 0` on the interior, and it is continuous up to `0`).
- **(S4) Value at zero.** `s(0) = 0`, by definition; this is the dissolved
  `0·log 0` convention.

### Definition 2.2 (Entropy)

For a finite type `α` and a weight function `p : α → ℝ`, the **entropy** of `p` is

> `H(p) := Σ_{x ∈ α} s(p(x)).`

We do not require `p` to be a probability distribution to *define* `H`; the
constraints enter only where individual theorems need them.

### Definition 2.3 (Probability distribution)

A weight function `p : α → ℝ` is a **probability distribution** if

> `p(x) ≥ 0` for all `x`,  and  `Σ_{x ∈ α} p(x) = 1.`

A **sub-distribution** is a `p` with `0 ≤ p(x) ≤ 1` for all `x` (the mass may be
less than one).

### Definition 2.4 (Product distribution)

Given `p : α → ℝ` and `q : β → ℝ`, the **product distribution**
`p ⊗ q : α × β → ℝ` is `(p ⊗ q)(x, y) := p(x) · q(y)`. If `p` and `q` are
probability distributions, so is `p ⊗ q`, since
`Σ_{(x,y)} p(x)q(y) = (Σ_x p(x))(Σ_y q(y)) = 1·1 = 1`.

### Definition 2.5 (Uniform distribution)

On an inhabited finite type `α` with `n = |α| ≥ 1`, the **uniform distribution** is
the constant `u(x) := 1/n`. It is a probability distribution: `Σ_x (1/n) = n·(1/n)
= 1`.

---

## 3. Main Results

### Theorem 3.1 (Non-negativity of entropy)

> If `p : α → ℝ` satisfies `0 ≤ p(x) ≤ 1` for every `x`, then `H(p) ≥ 0`.

**Proof sketch.** By (S1), each summand `s(p(x))` is non-negative because
`p(x) ∈ [0,1]`. A finite sum of non-negative reals is non-negative, hence
`H(p) = Σ_x s(p(x)) ≥ 0`. ∎

*Remark.* The hypothesis is the sub-distribution condition; it does not require the
masses to sum to one. Equality `H(p) = 0` occurs precisely when every `p(x)` is
`0` or `1`, i.e. the distribution is a point mass (deterministic).

### Theorem 3.2 (Additivity over independent distributions)

> Let `p : α → ℝ` and `q : β → ℝ` satisfy `Σ_x p(x) = 1` and `Σ_y q(y) = 1`. Then
> for the product distribution `(p ⊗ q)(x,y) = p(x) q(y)`,
> `H(p ⊗ q) = H(p) + H(q).`

**Proof sketch.** Expand the joint entropy and apply (S2) termwise:

```
H(p ⊗ q) = Σ_{(x,y)} s(p(x) q(y))
         = Σ_x Σ_y [ q(y)·s(p(x)) + p(x)·s(q(y)) ]      (by S2)
         = Σ_x s(p(x)) · (Σ_y q(y))  +  Σ_y s(q(y)) · (Σ_x p(x))
         = Σ_x s(p(x)) · 1           +  Σ_y s(q(y)) · 1   (by Σq = Σp = 1)
         = H(p) + H(q).
```

The double sum is reorganized using Fubini for finite sums and the distributive law
`Σ (a + b) = Σ a + Σ b`; the marginal normalizations collapse the cross-factors. ∎

*Remark.* Additivity is the structural reason entropy is logarithmic: `s` converts
the multiplicative composition of independent probabilities into an additive
composition of information. Theorem 3.2 is the special, fully-factored case of the
general chain rule (Section 6.1).

### Theorem 3.3 (Entropy of the uniform distribution)

> On an inhabited finite type `α` with `n = |α| ≥ 1`, the uniform distribution
> `u(x) = 1/n` satisfies `H(u) = log n.`

**Proof sketch.** Each summand is `s(1/n) = −(1/n) log(1/n) = (1/n) log n`, using
`log(1/n) = −log n`. There are exactly `n` summands, so
`H(u) = n · (1/n) log n = log n`. The hypothesis `n ≥ 1` (i.e. `α` inhabited)
ensures `n ≠ 0` so that `1/n` and `log n` are well defined. ∎

### Theorem 3.4 (Maximum entropy theorem)

> Let `p : α → ℝ` be a probability distribution on an inhabited finite type `α`
> with `n = |α| ≥ 1`. Then `H(p) ≤ log n`, with equality when `p` is uniform.

**Proof sketch.** The surprise function `s` is concave (S3). Jensen's inequality
for a concave function `f` with non-negative weights `w_i` summing to `1` states

> `Σ_i w_i · f(t_i)  ≤  f( Σ_i w_i · t_i ).`

Apply this with `f = s`, weights `w_x = 1/n` (which are non-negative and sum to
`1`), and points `t_x = p(x)`:

```
Σ_x (1/n)·s(p(x))  ≤  s( Σ_x (1/n)·p(x) )
                    =  s( (1/n)·Σ_x p(x) )
                    =  s( (1/n)·1 )            (since p is a distribution)
                    =  s(1/n)
                    =  (1/n) log n.            (as in Theorem 3.3)
```

The left-hand side is `(1/n)·H(p)`. Multiplying the inequality through by `n > 0`
gives `H(p) ≤ log n`. Equality in Jensen for the strictly concave `s` forces all
`p(x)` equal, i.e. `p` uniform; conversely Theorem 3.3 shows the uniform
distribution attains `log n`. ∎

*Remark.* Theorems 3.3 and 3.4 jointly establish that the uniform distribution is
the unique maximizer of entropy on a finite type — the precise content of "uniform
= maximal uncertainty," and the finite-alphabet form of the maximum-entropy
principle.

---

## 4. Discussion of the Proof Architecture

The development is deliberately *thin* at every step, and this thinness is the
result of pushing all analytic content into the surprise function `s`.

- **The `0·log 0` convention is dissolved, not patched.** Because `s(0) = 0` is
  part of the definition of `s` (S4), no theorem ever encounters an indeterminate
  form. Distributions with zero-probability outcomes are handled identically to
  those without. This is the single most important simplification.

- **Additivity is pure algebra.** Theorem 3.2 needs no analysis at all beyond the
  identity (S2); it is finite-sum bookkeeping. This isolates the *combinatorial*
  content of additivity from the *analytic* content of the bound.

- **The maximum-entropy bound is exactly Jensen.** Theorem 3.4 invokes precisely
  one nontrivial analytic input — the concavity (S3) of `s` — and threads it
  through Jensen's inequality with uniform weights. No bespoke calculus, no
  Lagrange multipliers, no manual optimization: the prepackaged concavity does all
  the work.

This modularity matters because the four theorems are intended as *infrastructure*.
A later result that needs, say, the chain rule can reuse the additivity algebra
verbatim; a result needing tightness of a bound can reuse the Jensen step. The
cost of each new theorem is small precisely because the analytic substrate is
factored cleanly into `s`.

---

## 5. Algorithms

Although the theorems are analytic, they have direct computational content. We
describe the principal algorithm and its complexity.

### Algorithm 5.1 (Entropy evaluation)

**Input.** A finite list of weights `p = (p_1, …, p_n)`.
**Output.** `H(p) = Σ_i s(p_i)` where `s(x) = −x log x` and `s(0) = 0`.

```
function ENTROPY(p):
    H ← 0
    for each weight x in p:
        if x = 0:
            term ← 0                # the dissolved 0·log 0 convention
        else:
            term ← −x · log(x)
        H ← H + term
    return H
```

**Complexity.** `Θ(n)` arithmetic operations and `n` logarithm evaluations for an
`n`-outcome distribution. Numerically stable provided weights are clamped at `0`
for the surprise term, exactly mirroring `s(0) = 0`.

### Algorithm 5.2 (Maximum-entropy certificate)

Given a distribution `p` on `n` outcomes, certify the bound `H(p) ≤ log n` of
Theorem 3.4 and report the *entropy gap* `log n − H(p) ≥ 0`, which equals the
Kullback–Leibler divergence from `p` to the uniform distribution. A zero gap
certifies `p` is uniform.

```
function MAXENT_GAP(p):
    n   ← length(p)
    H   ← ENTROPY(p)
    gap ← log(n) − H
    assert gap ≥ −ε              # Theorem 3.4, up to floating tolerance
    return gap
```

---

## 6. Applications and Future Directions

The four theorems are the computational substrate for a broader information-theory
program. We outline the immediate next steps; each builds directly on the lemmas
above.

### 6.1 Conditional entropy and the chain rule

Define, for an arbitrary joint distribution `r : α × β → ℝ` (not necessarily a
product), the marginal `p(x) = Σ_y r(x,y)` and the conditional entropy
`H(Y | X) = Σ_x p(x) · H( r(x, ·)/p(x) )`. The **chain rule**

> `H(X, Y) = H(X) + H(Y | X)`

is `s(ab) = b·s(a) + a·s(b)` applied *pointwise before* marginalization: writing
`r(x,y) = p(x)·(r(x,y)/p(x))` turns each joint term into a marginal term plus a
conditional term. Theorem 3.2 is exactly the degenerate, fully-factored instance
in which `r` factors as `p ⊗ q`, so its proof skeleton transfers directly; the
only new ingredient is the support where `p(x) = 0`, again neutralized by
`s(0) = 0`.

### 6.2 Gibbs' inequality and KL divergence

Define the Kullback–Leibler divergence `KL(p ‖ q) = Σ_x p(x) log(p(x)/q(x))`.
**Gibbs' inequality** `KL(p ‖ q) ≥ 0` is again concave Jensen, now applied to the
logarithm with weights `p(x)`. The maximum-entropy gap of Algorithm 5.2 is the
special case `KL(p ‖ uniform) = log n − H(p)`, so Theorem 3.4 is literally
non-negativity of a divergence.

### 6.3 Mutual information

Mutual information `I(X; Y) = H(X) + H(Y) − H(X, Y)` measures shared information;
it is non-negative by the chain rule and Gibbs' inequality, and zero exactly for
independent variables — precisely the regime of Theorem 3.2.

### 6.4 Integrated information and the partition lattice

Information-theoretic measures of integration — including the Φ measure proposed
in integrated information theory — quantify how much a system's joint entropy
exceeds the sum of its parts' entropies across a partition. The minimum over the
finite lattice of bipartitions exists by finiteness, and the additive baseline is
exactly the product case of Theorem 3.2. The entropy substrate established here is
the prerequisite for formalizing such measures.

### 6.5 Convergence and fixed-point themes

In adjacent work, monotone iteration on finite lattices stabilizes within the
lattice height (a Knaster–Tarski–style convergence bound), and contractive
self-maps on metric spaces converge geometrically to unique fixed points (Banach).
Entropy provides a natural Lyapunov-type potential for several such dynamics, and
the maximum-entropy bound supplies the coercive ceiling that makes convergence
arguments well posed.

---

## 7. Conclusion

By routing every term of Shannon entropy through the surprise function
`s(x) = −x log x` with `s(0) = 0`, the historically delicate `0·log 0` convention
dissolves and the foundational theorems of finite information theory become short,
modular consequences: non-negativity from positivity of `s` on `[0,1]`; additivity
from the algebraic identity `s(ab) = b·s(a) + a·s(b)`; the uniform entropy
`log n` by direct evaluation; and the maximum-entropy bound `H(p) ≤ log n` from a
single application of concave Jensen. Together the last two pin down the uniform
distribution as the unique entropy maximizer. The resulting toolkit is exactly the
substrate needed for conditional entropy, KL divergence, mutual information, and
integration measures — a clean foundation on which a much larger edifice of
information theory can be assembled with confidence.

---

## Appendix A: Notation

| Symbol | Meaning |
|---|---|
| `s(x)` | surprise function `−x log x`, with `s(0) = 0` |
| `H(p)` | entropy `Σ_x s(p(x))` |
| `p ⊗ q` | product distribution `(x,y) ↦ p(x) q(y)` |
| `u`, uniform | constant distribution `x ↦ 1/n` |
| `n = |α|` | cardinality of the (finite, inhabited) outcome type |
| `KL(p ‖ q)` | Kullback–Leibler divergence `Σ_x p(x) log(p(x)/q(x))` |

## Appendix B: Summary of results

| Theorem | Statement | Engine |
|---|---|---|
| 3.1 Non-negativity | `0 ≤ H(p)` for `p : α → [0,1]` | sum of non-negatives, (S1) |
| 3.2 Additivity | `H(p ⊗ q) = H(p) + H(q)` | identity (S2) + double-sum factoring |
| 3.3 Uniform | `H(uniform) = log n` | direct evaluation, `log(1/n) = −log n` |
| 3.4 Maximum entropy | `H(p) ≤ log n` | concave Jensen (S3) on `s`, uniform weights |
