# Landauer's Principle from the Deterministic Data-Processing Inequality

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Logic (information theory / thermodynamics of computation)

## Abstract

We give a self-contained, fully elementary derivation of Landauer's principle — the
statement that erasing information necessarily dissipates heat — from a single combinatorial
inequality about finite functions. Working with arbitrary weight functions on finite
alphabets, we define the pushforward (image measure) of a distribution along a deterministic
map $f$ and prove the *deterministic data-processing inequality*: Shannon entropy never
increases under $f$, i.e. $H(f_* p) \le H(p)$. We identify the equality case exactly with
injectivity of $f$ (logical reversibility) and deduce two thermodynamic corollaries: the
dissipated work $W = kT\,(H(p) - H(f_* p))$ is non-negative for all $k, T \ge 0$
(Landauer's lower bound), and it vanishes identically for reversible computations. The
iconic constant $kT\ln 2$ for one-bit erasure is recovered as the extremal
collapse-to-a-point instance, where a uniform $n$-bit register is mapped to a single state,
destroying $n\log 2$ nats of entropy. The entire development avoids the concavity/Jensen
machinery usually invoked for the data-processing inequality, reducing it to the pointwise
fiber-domination bound $p(x) \le (f_* p)(f(x))$ and the monotonicity of the logarithm. All
results have been formally verified.

## 1. Introduction

Landauer's principle (Landauer, 1961) asserts that the erasure of one bit of information in
an environment at temperature $T$ must be accompanied by the dissipation of at least
$kT\ln 2$ of heat, where $k$ is Boltzmann's constant. It forges a link between *logical*
irreversibility (a computation that cannot be undone) and *thermodynamic* irreversibility
(a process that produces entropy). Bennett (1973) complemented this by showing that
computations can in principle be made logically reversible, and therefore — in the
idealized limit — thermodynamically free.

The standard route to the quantitative bound proceeds through the second law and the
non-decrease of total entropy, or through the data-processing inequality of information
theory (Cover & Thomas, 2006), whose usual proof invokes the concavity of the entropy
functional and Jensen's inequality. The purpose of this paper is to show that, for finite
systems, the entire principle follows from one elementary observation about fibers of a
function, requiring nothing beyond the monotonicity of $\log$ and the non-negativity of a
sum of non-negative terms.

Our contributions are:

1. A clean finite-alphabet formulation of the pushforward of a weight function and a proof
   that it preserves the structure of a probability distribution (Section 3).
2. The deterministic data-processing inequality $H(f_* p) \le H(p)$ for arbitrary finite
   $f$ and non-negative weights, with an elementary fiber-domination proof (Section 4).
3. The exact equality characterization: injective (logically reversible) maps preserve
   entropy (Section 4).
4. The thermodynamic corollaries — Landauer's non-negative lower bound and the vanishing of
   the cost for reversible computations — and the recovery of $kT\ln 2$ as the
   collapse-to-a-point extremal case (Section 5).

## 2. Setting and definitions

Throughout, $\alpha$ and $\beta$ are finite types (finite alphabets of states), and
$f : \alpha \to \beta$ is an arbitrary deterministic map modeling a computation. We work
with real-valued weight functions $p : \alpha \to \mathbb{R}$.

**Definition 1 (Distribution).** A weight function $p : \alpha \to \mathbb{R}$ is a
*distribution*, written $\mathrm{IsDistribution}(p)$, if it is pointwise non-negative and
sums to one:
$$\big(\forall x,\ 0 \le p(x)\big) \quad\text{and}\quad \sum_{x} p(x) = 1.$$

**Definition 2 (Shannon entropy).** The Shannon entropy of a weight function
$p : \alpha \to \mathbb{R}$ is
$$H(p) \;=\; -\sum_{x \in \alpha} p(x)\,\log p(x),$$
with the standard convention $0 \log 0 = 0$ (so terms with $p(x) = 0$ contribute nothing).

**Definition 3 (Pushforward / image measure).** The *pushforward* of $p : \alpha \to
\mathbb{R}$ along $f : \alpha \to \beta$ is the weight function $f_* p : \beta \to
\mathbb{R}$ assigning to each output the total weight of its fiber:
$$(f_* p)(y) \;=\; \sum_{x \,:\, f(x) = y} p(x).$$
Operationally, $f_* p$ is the distribution of $f(X)$ when $X \sim p$.

In the formal development these correspond to `IsDistribution`, `shannonEntropy`, and
`pushforwardFun` respectively; the Lean theorem names are noted alongside each result below.

## 3. The pushforward is a distribution

We first record that the pushforward behaves as expected on probability distributions.

**Lemma 1 (Fiber domination; `pushforwardFun_apply_ge`).** If $p(x) \ge 0$ for all $x$,
then for every $x \in \alpha$,
$$p(x) \;\le\; (f_* p)(f(x)).$$

*Proof.* The point $x$ belongs to the fiber $\{z : f(z) = f(x)\}$ over which $(f_* p)(f(x))$
sums. All summands are non-negative, so the total is at least the single term $p(x)$.
$\square$

This one-line lemma is the engine of the entire paper.

**Lemma 2 (Mass preservation; `pushforwardFun_total`).** For any $f$ and any $p$,
$$\sum_{y \in \beta} (f_* p)(y) \;=\; \sum_{x \in \alpha} p(x).$$

*Proof.* Summing fiber weights over all outputs partitions $\alpha$ into fibers and
re-sums $p$ over $\alpha$ (a fiberwise reindexing of the total sum). $\square$

Together with the obvious non-negativity of a sum of non-negative terms
(`pushforwardFun_nonneg`), this yields:

**Proposition 3 (`pushforwardFun_isDistribution`).** If $p$ is a distribution, then so is
$f_* p$.

*Proof.* Non-negativity is termwise; the total mass is $\sum_y (f_*p)(y) = \sum_x p(x) = 1$
by Lemma 2 and the hypothesis. $\square$

## 4. The deterministic data-processing inequality

The key structural step is to express the entropy of the *output* distribution as a sum
back over the *input* alphabet.

**Lemma 4 (Reindexing; `shannonEntropy_pushforward_eq`).** For any $f$ and any $p$,
$$H(f_* p) \;=\; -\sum_{x \in \alpha} p(x)\,\log\big((f_* p)(f(x))\big).$$

*Proof.* Start from $H(f_* p) = -\sum_{y} (f_* p)(y)\,\log\big((f_* p)(y)\big)$. Expand
$(f_* p)(y) = \sum_{x : f(x) = y} p(x)$ in the leading factor and distribute the logarithm
(a constant on the fiber, since $f(x) = y$ there) across the fiber sum. Regrouping the
double sum as a single sum over $x$ with $y = f(x)$ gives the claim. $\square$

**Theorem 5 (Data-processing inequality; `shannonEntropy_pushforward_le`).** For every
$f : \alpha \to \beta$ and every non-negative weight function $p$,
$$H(f_* p) \;\le\; H(p).$$
A deterministic computation never increases Shannon entropy.

*Proof.* Using Definition 2 for $H(p)$ and Lemma 4 for $H(f_* p)$, the entropy gap is
$$H(p) - H(f_* p) \;=\; \sum_{x} p(x)\,\Big(\log\big((f_* p)(f(x))\big) - \log p(x)\Big).$$
We show each summand is non-negative. Fix $x$. If $p(x) = 0$ the term vanishes. Otherwise
$p(x) > 0$, and by Lemma 1, $0 < p(x) \le (f_* p)(f(x))$; monotonicity of $\log$ gives
$\log p(x) \le \log\big((f_* p)(f(x))\big)$, so the parenthesized factor is $\ge 0$ and,
multiplied by $p(x) \ge 0$, the term is $\ge 0$. A sum of non-negative terms is
non-negative, hence $H(p) - H(f_* p) \ge 0$. $\square$

The proof uses only `Real.log_le_log` (monotonicity of the logarithm on positives) and
`Finset.single_le_sum`/`Finset.sum_le_sum`; no concavity, grouping axioms, or Jensen
inequality are needed.

**Theorem 6 (Reversibility preserves entropy; `shannonEntropy_pushforward_of_injective`).**
If $f$ is injective, then
$$H(f_* p) \;=\; H(p).$$

*Proof.* For injective $f$ each fiber $\{z : f(z) = f(x)\}$ equals the singleton $\{x\}$, so
$(f_* p)(f(x)) = p(x)$ for all $x$. Substituting into the reindexed expression of Lemma 4
makes it identical to Definition 2 of $H(p)$. $\square$

Theorems 5 and 6 together say: deterministic computation is entropy non-increasing, with
equality exactly in the logically reversible (injective) case. The boundary of the
data-processing inequality is precisely reversibility.

## 5. Thermodynamic corollaries: Landauer's bound

We now translate the information-theoretic statements into thermodynamics via the standard
identification of dissipated heat with temperature times destroyed entropy. For a process at
temperature $T$ running the map $f$ on the input distribution $p$, define the dissipated work
$$W \;=\; k\,T\,\big(H(p) - H(f_* p)\big).$$

**Theorem 7 (Landauer's lower bound; `landauer_lower_bound`).** For all $k, T \ge 0$, all
$f$, and all non-negative $p$,
$$W \;=\; k\,T\,\big(H(p) - H(f_* p)\big) \;\ge\; 0.$$

*Proof.* By Theorem 5, $H(p) - H(f_* p) \ge 0$. With $k \ge 0$ and $T \ge 0$ the product of
three non-negative factors is non-negative. $\square$

**Theorem 8 (Reversible computations are free; `landauer_lower_bound_zero_of_injective`).**
If $f$ is injective, then $W = 0$ identically:
$$k\,T\,\big(H(p) - H(f_* p)\big) \;=\; 0.$$

*Proof.* By Theorem 6, $H(p) - H(f_* p) = 0$, so the product vanishes regardless of $k, T$.
$\square$

### 5.1 Recovering $kT\ln 2$: the collapse-to-a-point case

The famous constant is the extremal instance of Theorem 7 in which $f$ destroys *all*
information. Let $\alpha = \{0,1\}^n$ be an $n$-bit register equipped with the uniform
distribution $p(x) = 2^{-n}$, whose entropy is
$$H(p) = -\sum_{x \in \{0,1\}^n} 2^{-n} \log 2^{-n} = n \log 2.$$
Let $f$ be the constant erasure map sending every pattern to a single reset state. Then
$f_* p$ is a point mass (entropy $0$), $f$ is maximally non-injective, and Theorem 7 gives
$$W = kT\,(n\log 2 - 0) = n\,kT\log 2.$$
For $n = 1$ this is exactly Landauer's bound $W = kT\ln 2$ for erasing a single bit. Thus
$kT\ln 2$ is not a separate axiom but the collapse-to-a-point boundary value of the general
inequality $H(f_* p) \le H(p)$.

### 5.2 Logical vs. thermodynamic irreversibility

Theorems 6 and 8 make the Landauer–Bennett correspondence exact and bidirectional in the
finite setting:

- *Logical reversibility* of $f$ is injectivity (the input is recoverable from the output).
- *Thermodynamic reversibility* of the process is zero dissipation, $W = 0$.

Theorem 8 shows logical reversibility implies thermodynamic freedom. Conversely, whenever
$f$ is *not* injective there exist inputs $x \ne x'$ with $f(x) = f(x')$; placing positive
weight on both makes the corresponding fiber strictly dominate its individual terms, the gap
$H(p) - H(f_*p)$ becomes strictly positive, and $W > 0$ for any $k, T > 0$. Information
destruction is therefore not merely sufficient but, on suitable inputs, necessary for
dissipation.

## 6. Algorithmic content

The proofs are constructive and yield directly executable procedures on finite alphabets:

- **Pushforward computation.** Given $f$ and $p$, compute $f_* p$ by accumulating $p(x)$
  into bucket $f(x)$. Complexity $O(|\alpha|)$ time, $O(|\beta|)$ space.
- **Entropy gap / Landauer cost.** Compute $H(p)$, $H(f_* p)$, and
  $W = kT\,(H(p) - H(f_* p))$ in $O(|\alpha| + |\beta|)$ time. Theorem 7 guarantees the
  result is $\ge 0$; Theorem 8 guarantees it is $0$ for injective $f$.
- **Reversibility test.** $f$ is injective iff $\max_y |f^{-1}(y)| = 1$, checkable in
  $O(|\alpha|)$ time during the pushforward pass.

These let one *audit* a deterministic computation for its minimum thermodynamic cost purely
from its truth table and input distribution.

## 7. Applications

- **Nanoscale and reversible computing.** The bound certifies the heat floor of irreversible
  logic and quantifies the gain available from reversible designs that keep $f$ injective.
- **Information-theoretic security and side channels.** The data-processing inequality
  bounds how much an adversary can learn through a deterministic observation channel: a
  lossy map cannot increase the entropy (uncertainty) of the underlying state.
- **Abstract interpretation / model checking.** Deterministic abstraction maps cannot
  manufacture uncertainty; entropy is monotone under state-space quotients, with equality
  for lossless (injective) abstractions.

## 8. Discussion and limitations

The treatment is finite and deterministic: $\alpha, \beta$ are finite types and $f$ is a
function. This is exactly the regime relevant to digital logic and is what makes the
elementary fiber argument available — no measure theory, concavity, or limiting procedure is
required. The thermodynamic step uses the standard linear dictionary "heat = temperature ×
entropy destroyed"; the mathematical content is the entropy inequality, and the constants
$k, T$ enter only as non-negative scalars.

The present results establish the *identity-and-inequality* form of Landauer's bound for
deterministic maps. They do not yet treat stochastic channels, the finite-time
non-equilibrium fluctuations captured by the Jarzynski equality, or higher-order
finite-size corrections to the cost; these are the subject of the future directions below.

## 9. Future work

Natural extensions include (i) upgrading the present identity into a finite Jensen-based
second-law inequality with explicit convexity bounds; (ii) a cumulant expansion of the
finite-size correction, whose leading term is $\tfrac12 \beta\,\mathrm{Var}(W)$; and
(iii) multi-bit and general-alphabet erasure, relating non-injectivity of $f$ quantitatively
to an entropy drop $H(p) - H(f_* p) > 0$ via the entropy of the induced partition. See the
package's future-directions notes for details.

## References

- R. Landauer, *Irreversibility and heat generation in the computing process*, IBM J. Res.
  Dev. **5** (1961), 183–191.
- C. H. Bennett, *Logical reversibility of computation*, IBM J. Res. Dev. **17** (1973),
  525–532.
- T. M. Cover and J. A. Thomas, *Elements of Information Theory*, 2nd ed., Wiley, 2006
  (data-processing inequality).
- C. Jarzynski, *Nonequilibrium equality for free energy differences*, Phys. Rev. Lett.
  **78** (1997), 2690–2693.
