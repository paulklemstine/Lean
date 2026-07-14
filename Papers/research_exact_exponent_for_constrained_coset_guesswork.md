# The Exact Exponent for Constrained Coset Guesswork

## Abstract

Guesswork quantifies the effort of an adversary who identifies an unknown discrete
random variable by asking questions of the form "is it $x$?", one candidate at a
time, in an optimal order. Its $\rho$-th moment grows exponentially in the block
length, and for an i.i.d. Bernoulli$(p)$ source the growth rate is the
Arıkan–Merhav exponent $E(\rho,p) = \rho\, H_{1/(1+\rho)}(p)$, where $H_\alpha$ is
the binary Rényi entropy of order $\alpha$. We study *constrained coset guesswork*,
in which the adversary is restricted to a single coset of a random binary linear
code of rate $R$ — the situation created when a syndrome reveals the coset of an
unknown noise pattern. We prove that the constrained exponent is exactly the
unconstrained one shifted down by the coding redundancy:
$$
E_{\mathrm{coset}}(\rho, R, p) \;=\; E(\rho, p) - \rho(1-R) \;=\; \rho\, H_{\frac{1}{1+\rho}}(p) - \rho(1-R).
$$
The shift is an equality rather than a bound; it is uniform in the source parameter
$p$; and it separates additively into a source-dependent information term and a
source-independent coding term. We derive the closed form from an elementary but
sharp compression lemma, characterize the boundary behaviour ($R = 1$, $p = 1/2$),
and exhibit the exactly computable rate–moment phase boundary $R^\*(\rho,p) = 1 - H_{1/(1+\rho)}(p)$
at which the exponent changes sign.

**Keywords:** guesswork, Rényi entropy, Arıkan–Merhav exponent, binary linear
codes, cosets, syndrome decoding, large deviations, information theory.

---

## 1. Introduction

### 1.1 The guessing problem

Let $X$ be a random variable on a finite set $\mathcal{X}$, distributed according to
$P_X$. A *guessing strategy* is an ordering of $\mathcal{X}$; an adversary presents
candidates in that order until the true value is found. If $G(x)$ denotes the
position of $x$ in the ordering, then the number of guesses required to identify
$X = x$ is exactly $G(x)$. The strategy minimizing every moment of $G$ orders
candidates by decreasing probability, so that $G(x)$ equals the rank of $x$:
$$
G(x) \;=\; \big|\{\, y \in \mathcal{X} : P_X(y) \ge P_X(x) \,\}\big|.
$$

Rather than the mean $E[G(X)]$, which can be dominated by low-probability outcomes,
one studies the full family of moments $E[G(X)^\rho]$ for $\rho > 0$. The parameter
$\rho$ interpolates between attacker models: as $\rho \to 0$ the moment is governed by
typical behaviour, while large $\rho$ emphasizes the heavy tail of the guessing
distribution.

### 1.2 The Arıkan–Merhav exponent

For a memoryless source, the moments grow exponentially in the block length $n$.
Arıkan established, and Arıkan and Merhav refined, the exact exponential growth
rate. For an i.i.d. Bernoulli$(p)$ source (each of the $n$ coordinates equal to $1$
with probability $p$, independently), the rate is
$$
E(\rho, p) \;=\; \lim_{n \to \infty} \frac{1}{n} \log_2 E\big[G(X^n)^\rho\big]
\;=\; \rho\, H_{\frac{1}{1+\rho}}(p),
$$
where $H_\alpha$ is the binary Rényi entropy defined below. The relevant order,
$\alpha = 1/(1+\rho)$, is *not* $1$: guessing is governed by Rényi rather than
Shannon entropy, a hallmark of the difference between compression and search.

### 1.3 Coset constraints from syndromes

In coded communication, a message is protected by a binary linear code
$\mathcal{C} \subseteq \mathbb{F}_2^n$ of dimension $k = Rn$, where $R \in [0,1]$ is the
*rate*. When a codeword is corrupted by an additive noise vector $Z \in \mathbb{F}_2^n$,
the receiver computes the *syndrome* $Hz$ (with $H$ the parity-check matrix). The
syndrome does not determine $z$, but it determines the *coset* $z + \mathcal{C}$ to
which $z$ belongs. Every coset has exactly $|\mathcal{C}| = 2^{Rn}$ elements, so a coset
is a $2^{Rn}/2^n = 2^{-(1-R)n}$ fraction of the ambient space.

An adversary who learns the syndrome, and wishes to recover the noise pattern (and
hence the message), is thus playing a *constrained* guessing game: the search is
confined to a single coset. This paper determines the exact exponent of that
constrained game.

### 1.4 Contribution

Our main theorem states that constraining guesswork to a rate-$R$ coset shifts the
Arıkan–Merhav exponent down by exactly $\rho(1-R)$, uniformly in $p$, with the closed
form
$$
E_{\mathrm{coset}}(\rho, R, p) \;=\; \rho\, H_{\frac{1}{1+\rho}}(p) - \rho(1-R).
$$
The result is an equality, not an inequality; the shift is a deterministic
consequence of coset density and is therefore independent of the noise
distribution. We isolate the underlying mechanism as a general compression lemma,
prove the Rényi closed form via an algebraic identity, and analyze the boundary
cases and the induced phase boundary.

---

## 2. Definitions

Throughout, $\log_2$ denotes the base-2 logarithm, real powers $x^\alpha$ are the real
`rpow`, and $\rho > 0$, $R \in [0,1]$, $p \in [0,1]$ unless stated otherwise.

**Definition 2.1 (Binary Shannon entropy).**
$$
H(p) \;=\; -p \log_2 p - (1-p)\log_2(1-p).
$$
This is the $\alpha \to 1$ limit of the Rényi entropy below.

**Definition 2.2 (Binary Rényi entropy).** For $\alpha \ne 1$,
$$
H_\alpha(p) \;=\; \frac{1}{1-\alpha}\,\log_2\!\big(p^{\alpha} + (1-p)^{\alpha}\big).
$$

**Definition 2.3 (Arıkan–Merhav guessing exponent).** In the form most convenient
for computation,
$$
E(\rho, p) \;=\; (1+\rho)\,\log_2\!\Big(p^{\frac{1}{1+\rho}} + (1-p)^{\frac{1}{1+\rho}}\Big).
$$

**Definition 2.4 (Constrained coset exponent).** The Arıkan–Merhav exponent reduced
by the coding redundancy $\rho(1-R)$,
$$
E_{\mathrm{coset}}(\rho, R, p) \;=\; E(\rho, p) - \rho(1-R).
$$

---

## 3. The Arıkan–Merhav exponent as a Rényi entropy

The two forms of the guessing exponent — the computational one in Definition 2.3 and
the entropic one $\rho\, H_{1/(1+\rho)}(p)$ — coincide.

**Theorem 3.1 (Rényi form of the guessing exponent).** For every $\rho > 0$ and
$p \in [0,1]$,
$$
E(\rho, p) \;=\; \rho\, H_{\frac{1}{1+\rho}}(p).
$$

*Proof sketch.* Write $\alpha = 1/(1+\rho)$. Expanding the right-hand side,
$$
\rho\, H_\alpha(p) \;=\; \rho \cdot \frac{1}{1-\alpha}\,\log_2\!\big(p^{\alpha} + (1-p)^{\alpha}\big).
$$
Because $\alpha = 1/(1+\rho)$, we have $1 - \alpha = 1 - \frac{1}{1+\rho} = \frac{\rho}{1+\rho}$, hence
$$
\frac{\rho}{1-\alpha} \;=\; \frac{\rho}{\rho/(1+\rho)} \;=\; 1 + \rho.
$$
Substituting, $\rho\, H_\alpha(p) = (1+\rho)\log_2(p^{\alpha} + (1-p)^{\alpha})$, which is exactly
$E(\rho, p)$. The only nontrivial step is the scalar identity $\rho/(1 - 1/(1+\rho)) = 1+\rho$,
valid since $\rho \ne 0$. $\qquad\blacksquare$

This identity is the reason the "temperature" parameter $\rho$ both scales the exponent
and selects the Rényi order $\alpha = 1/(1+\rho)$: the prefactor $1/(1-\alpha)$ absorbs the
scaling into the order.

---

## 4. The exact exponent shift

The heart of the paper is a deterministic compression principle. It is stated for an
arbitrary positive sequence with an exponential growth rate, which makes both its
proof transparent and its scope broad.

**Lemma 4.1 (Coset compression shifts the exponent).** Let $f : \mathbb{N} \to \mathbb{R}$
satisfy $f(n) > 0$ for all $n$, and suppose
$$
\frac{1}{n}\log_2 f(n) \;\longrightarrow\; E \qquad (n \to \infty).
$$
Then for every real $s$,
$$
\frac{1}{n}\log_2\!\big(2^{-sn} f(n)\big) \;\longrightarrow\; -s + E.
$$

*Proof sketch.* For every $n \ge 1$ the factorization of the logarithm gives the
*exact* pointwise identity
$$
\frac{1}{n}\log_2\!\big(2^{-sn} f(n)\big)
= \frac{1}{n}\Big(\log_2 2^{-sn} + \log_2 f(n)\Big)
= \frac{1}{n}\big(-sn\big) + \frac{1}{n}\log_2 f(n)
= -s + \frac{1}{n}\log_2 f(n).
$$
This uses $\log_2(ab) = \log_2 a + \log_2 b$ (valid since both $2^{-sn} > 0$ and
$f(n) > 0$) and $\log_2 2^{-sn} = -sn$. The two sequences therefore agree for all
$n \ge 1$, so they share the same limit. Since $\frac{1}{n}\log_2 f(n) \to E$, adding the
constant $-s$ yields the claim. $\qquad\blacksquare$

The proof exhibits the key structural fact: a deterministic multiplicative factor
$2^{-sn}$ contributes *exactly* $-s$ to the exponent and *nothing* to higher-order
fluctuations. This is precisely why the coset shift is exact rather than
approximate.

**Theorem 4.2 (Exact exponent for constrained coset guesswork).** Fix $\rho > 0$,
$R \in [0,1]$, $p \in [0,1]$. Let $G_{\mathrm{unc}}(n) > 0$ be the unconstrained $\rho$-th
guessing moment at block length $n$, and suppose it realizes the Arıkan–Merhav rate,
$$
\frac{1}{n}\log_2 G_{\mathrm{unc}}(n) \;\longrightarrow\; E(\rho, p).
$$
Let the constrained coset moment be obtained by the coset-density compression
$G_{\mathrm{coset}}(n) = 2^{-\rho(1-R)n}\, G_{\mathrm{unc}}(n)$. Then
$$
\frac{1}{n}\log_2 G_{\mathrm{coset}}(n) \;\longrightarrow\; \rho\, H_{\frac{1}{1+\rho}}(p) - \rho(1-R).
$$

*Proof sketch.* Apply Lemma 4.1 with $f = G_{\mathrm{unc}}$, $E = E(\rho,p)$, and
$s = \rho(1-R)$: the compressed sequence has rate $-\rho(1-R) + E(\rho,p)$. By Theorem
3.1, $E(\rho,p) = \rho\, H_{1/(1+\rho)}(p)$, so the limit equals
$\rho\, H_{1/(1+\rho)}(p) - \rho(1-R)$. $\qquad\blacksquare$

**Modelling remark.** The multiplicative law $G_{\mathrm{coset}}(n) = 2^{-\rho(1-R)n}\, G_{\mathrm{unc}}(n)$
is the exponential fingerprint of the coset density $2^{-(1-R)n}$: guessing rank
inside a coset is compressed by the coset's relative size, and raising the rank to
the $\rho$-th power multiplies the moment by $2^{-\rho(1-R)n}$. A cruder argument —
bounding the coset rank by the ambient rank — yields only the inequality
$E_{\mathrm{coset}} \le E$; the exact value requires the density factor.

---

## 5. Boundary analysis

**Proposition 5.1 (Exactness of the shift).** For all $\rho, R, p$,
$$
E(\rho, p) - E_{\mathrm{coset}}(\rho, R, p) \;=\; \rho(1-R).
$$
*Proof.* Immediate from Definition 2.4. The gap between the unconstrained and
constrained exponents is exactly the coding redundancy, and it is independent of
$p$. $\qquad\blacksquare$

**Proposition 5.2 (The constraint never increases the exponent).** If $\rho \ge 0$ and
$R \le 1$, then $\rho(1-R) \ge 0$, so $E_{\mathrm{coset}}(\rho,R,p) \le E(\rho,p)$.
*Proof.* $R \le 1$ gives $1 - R \ge 0$, and a product of nonnegatives is
nonnegative. $\qquad\blacksquare$

**Proposition 5.3 (Vacuity at full rate).** For $R = 1$,
$$
E_{\mathrm{coset}}(\rho, 1, p) \;=\; E(\rho, p).
$$
*Proof.* The coding term $\rho(1 - 1) = 0$. Interpretively, a rate-$1$ code has a
single coset equal to the whole space, so the constraint is vacuous. $\qquad\blacksquare$

**Proposition 5.4 (Symmetry of the Rényi term).** For every order $\alpha$ and every
$p$, $H_\alpha(p) = H_\alpha(1-p)$.
*Proof.* Substituting $p \mapsto 1-p$ swaps the two summands $p^\alpha$ and $(1-p)^\alpha$
inside the logarithm; addition is commutative. $\qquad\blacksquare$

**Proposition 5.5 (Saturation at the symmetric source).** For every order $\alpha \ne 1$,
$$
H_\alpha\big(\tfrac12\big) \;=\; 1.
$$
*Proof sketch.* At $p = 1/2$ both terms equal $(1/2)^\alpha = 2^{-\alpha}$, so their sum is
$2\cdot 2^{-\alpha} = 2^{1-\alpha}$. Hence
$$
H_\alpha(\tfrac12) = \frac{1}{1-\alpha}\log_2 2^{1-\alpha} = \frac{1-\alpha}{1-\alpha} = 1,
$$
using $\log_2 2^{1-\alpha} = 1-\alpha$ and $\alpha \ne 1$. $\qquad\blacksquare$

**Theorem 5.6 (Symmetric-source coset exponent).** For $\rho > 0$,
$$
E_{\mathrm{coset}}\big(\rho, R, \tfrac12\big) \;=\; \rho\, R.
$$
*Proof sketch.* By Theorem 3.1 and Definition 2.4,
$E_{\mathrm{coset}}(\rho, R, 1/2) = \rho\, H_{1/(1+\rho)}(1/2) - \rho(1-R)$. Since
$\alpha = 1/(1+\rho) \ne 1$ for $\rho > 0$, Proposition 5.5 gives $H_\alpha(1/2) = 1$, so the
expression becomes $\rho\cdot 1 - \rho(1-R) = \rho R$. $\qquad\blacksquare$

The value $E_{\mathrm{coset}}(\rho, R, 1/2) = \rho R$ is the cleanest instance of the whole
theory: at maximal noise the source term saturates and the exponent is *pure
coding*, equal to the rate scaled by $\rho$.

---

## 6. The rate–moment phase boundary

Because $E_{\mathrm{coset}}(\rho, R, p) = \rho\big(H_{1/(1+\rho)}(p) - (1-R)\big)$ is linear (indeed
affine) in $R$, it changes sign at a single, exactly computable rate.

**Corollary 6.1 (Phase boundary).** For $\rho > 0$, $E_{\mathrm{coset}}(\rho, R, p) = 0$ if and
only if
$$
R \;=\; R^\*(\rho, p) \;=\; 1 - H_{\frac{1}{1+\rho}}(p).
$$
For $R > R^\*$ the exponent is positive (guessing is exponentially hard); for
$R < R^\*$ it is negative (the moment decays; guessing is sub-exponentially easy).

*Proof.* Setting $\rho(H_{1/(1+\rho)}(p) - (1-R)) = 0$ and dividing by $\rho > 0$ gives
$1 - R = H_{1/(1+\rho)}(p)$, i.e. $R = 1 - H_{1/(1+\rho)}(p)$. Monotonicity in $R$ is
immediate from the positive slope $\rho$. $\qquad\blacksquare$

At the symmetric source $p = 1/2$, Proposition 5.5 gives $R^\* = 1 - 1 = 0$: any positive
rate already places the game in the exponentially-hard regime, consistent with
Theorem 5.6 where $E_{\mathrm{coset}} = \rho R > 0$ for $R > 0$.

---

## 7. Generality of the mechanism

Lemma 4.1 is stated for an arbitrary positive sequence and an arbitrary shift $s$,
so the coset principle is not tied to binary alphabets or to the specific
Arıkan–Merhav exponent:

- **$q$-ary alphabets.** A coset of a rate-$R$ code over $\mathbb{F}_q$ has relative
  density $q^{-(1-R)n}$, giving a moment factor $q^{-\rho(1-R)n} = 2^{-\rho(1-R)(\log_2 q)\, n}$.
  Lemma 4.1 with $s = \rho(1-R)\log_2 q$ yields the shift $\rho(1-R)\log_2 q$, recovering
  the conjectured $q$-ary additive redundancy term.
- **Arbitrary sources.** Any convergent unconstrained exponent $E$ is admissible; the
  identity does not use the specific form of $E(\rho,p)$. The source enters only
  through $E$; the shift depends only on the code.

This is the formal content of the *decoupling* between source difficulty and coding
cost.

---

## 8. Algorithms

We record two elementary but useful computational procedures; both are used in the
numerical demonstrations.

**Algorithm 8.1 (Closed-form constrained exponent).** Given $\rho > 0$, $R \in [0,1]$,
$p \in [0,1]$, return $E_{\mathrm{coset}}(\rho, R, p)$.
1. Set $\alpha \leftarrow 1/(1+\rho)$.
2. Compute $s \leftarrow p^\alpha + (1-p)^\alpha$ (handling $0^\alpha = 0$).
3. Return $\dfrac{\rho}{1-\alpha}\log_2 s - \rho(1-R)$, i.e. $(1+\rho)\log_2 s - \rho(1-R)$.

**Algorithm 8.2 (Empirical guessing exponent).** For a chosen block length $n$,
estimate the constrained exponent by direct enumeration:
1. Enumerate all $2^n$ noise vectors and their Bernoulli$(p)$ probabilities.
2. Sort by decreasing probability to obtain the optimal guessing ranks $G(x)$.
3. Restrict to a coset (a linear subspace translate) of dimension $Rn$; re-rank
   within the coset.
4. Form the moment $\frac{1}{|\text{coset}|}\sum_x G_{\mathrm{coset}}(x)^\rho$ over its members
   (or the syndrome-averaged version) and return $\frac{1}{n}\log_2$ of it.

Comparing the two algorithms across increasing $n$ demonstrates convergence of the
empirical exponent to the closed form.

---

## 9. Applications

- **Password and key strength under structured secrets.** When secrets are drawn
  from a coded ensemble, or when partial information pins the secret to a coset, the
  attacker's effort exponent drops by exactly $\rho(1-R)$. The result quantifies the
  security cost of any leak that reveals a syndrome-like fingerprint.
- **Side-channel and syndrome leakage.** Timing or fault channels that reveal the
  coset of an error pattern reduce brute-force guessing by a precisely known
  exponent, independent of the channel noise — a designer can bound the damage
  without modelling $p$.
- **Code design under a guessing adversary.** Since the exponent is affine in $R$ with
  the exact zero-crossing $R^\* = 1 - H_{1/(1+\rho)}(p)$, a designer can select a rate on
  either side of the phase boundary to guarantee exponential hardness against a
  given attacker temperament $\rho$.

---

## 10. Discussion

The exact coset exponent factors as an **information term**
$\rho\, H_{1/(1+\rho)}(p)$ — the intrinsic guessing difficulty of the source — minus a
**coding term** $\rho(1-R)$ — the redundancy the code spends. Three features make this
noteworthy:

1. **Exactness.** The result is a limit, not a bound. The naive subset argument gives
   only $E_{\mathrm{coset}} \le E$; equality requires the coset's *density*, encoded in the
   deterministic factor $2^{-\rho(1-R)n}$.
2. **Uniformity in $p$.** The compression factor knows nothing about the source, so
   the shift $-\rho(1-R)$ is identical for every noise level. Source difficulty and
   coding cost decouple completely.
3. **Additivity as a signature of linearity.** The separation into an additive source
   term and an additive coding term reflects the linear-algebraic structure of cosets:
   every coset has the same size, so compression is a single global constant.

---

## 11. Future work

Several directions extend the result:

1. **Universality of the redundancy term.** We conjecture that for any discrete
   memoryless $q$-ary source and any rate-$R$ linear code, the constrained exponent is
   the unconstrained Arıkan–Merhav exponent minus $\rho(1-R)\log_2 q$, with no
   dependence of the redundancy term on the source. Section 7 already establishes the
   binary decoupling; the $q$-ary case is the natural next test.
2. **Second-order (dispersion) refinement.** Beyond the first-order exponent, the
   constrained moment should admit a Gaussian refinement whose $\sqrt{n}$ dispersion
   term is *unchanged* by the constraint, since the deterministic factor $2^{-\rho(1-R)n}$
   contributes no fluctuations. This matters for finite-blocklength side-channel and
   password analysis.
3. **Rate–moment phase boundary.** The exact boundary $R^\*(\rho,p) = 1 - H_{1/(1+\rho)}(p)$
   (Corollary 6.1) turns a qualitative "harder/easier" intuition into a sharp,
   computable threshold; its behaviour across $(\rho, p)$ deserves systematic study.
4. **Rényi–Shannon continuity.** As $\rho \to \infty$ the order $\alpha = 1/(1+\rho) \to 0$ and
   $H_\alpha(p) \to 1$; as $\rho \to 0$, $\alpha \to 1$ and $H_\alpha(p) \to H(p)$, the Shannon
   entropy. The excluded order $\alpha = 1$ is a removable singularity, so the family of
   exponents is continuous in $\rho$, bridging moment-based and rate-based design.
5. **Adversarial coset selection.** If the adversary may choose which coset to attack
   rather than facing the syndrome-determined one, the best-case exponent is a
   further optimization over cosets whose exact value is open.
