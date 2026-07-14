# An Arithmetic Model for the $\mu$-Extension of Matsuno's Sharp/Flat $\lambda$-Difference Formula

## Abstract

Let $E$ be an elliptic curve over $\mathbb{Q}$ with good supersingular reduction at the prime $2$, and let $D$ be a square-free integer with $D \equiv 1 \pmod 4$. When the relevant $2$-adic $\mu$-invariant vanishes, a formula of Matsuno expresses the difference $\lambda^\sharp - \lambda^\flat$ of the Kobayashi–Sprung sharp and flat Iwasawa $\lambda$-invariants of the quadratic twist $E^D$ as a local sum over the primes dividing $D$, each weighted by a power of two determined by a $2$-adic depth. We study, in an explicit and deliberately contrarian arithmetic model, the case of a **non-vanishing** $\mu$-invariant. We posit the corrected quantity
$$
\lambda\text{-diff}_\mu(D) = \lambda\text{-diff}(D) + \mu \cdot \sum_{\ell \mid D} 2^{n_\ell}, \qquad n_\ell = v_2\!\left(\tfrac{\ell^2-1}{8}\right),
$$
and establish its structural properties. We prove: (i) complete additivity over coprime moduli; (ii) an **exact inversion formula** recovering $\mu$ from the twist data whenever $D$ is ramified; (iii) strict monotonicity and injectivity in $\mu$; (iv) strict growth under adjoining a ramified prime; and (v) a $2$-adic depth law $8\cdot 2^{n_\ell} = 2^{v_2(\ell-1)+v_2(\ell+1)}$. We also *refute* three plausible conjectures with explicit counterexamples: the invariant is additive but **not** multiplicative; recovery of $\mu$ **requires** a prime divisor of $D$; and the $\mu$-correction is **not** a lower-order term — it can strictly exceed the entire classical contribution. All results are stated for the natural-number model in which $\mu$, the conductor datum, and the reduction-order data are parameters.

**Keywords:** elliptic curves, quadratic twist, Iwasawa theory, supersingular reduction, $\mu$-invariant, $\lambda$-invariant, Matsuno's formula, $2$-adic valuation.

---

## 1. Introduction

### 1.1 Background

Iwasawa theory studies arithmetic invariants of a $p$-adic Galois module along the cyclotomic $\mathbb{Z}_p$-extension. For an elliptic curve $E/\mathbb{Q}$ and a prime $p$ of good **ordinary** reduction, the $p$-primary Selmer group over the tower is a cofinitely generated cotorsion module over the Iwasawa algebra $\Lambda = \mathbb{Z}_p[[T]]$, whose characteristic ideal has an associated $\mu$-invariant (a power of $p$) and $\lambda$-invariant (a $T$-degree). In the **supersingular** case, the naive Selmer group fails to be cotorsion, and one must instead use the *plus/minus* (Kobayashi) or, more generally for $a_p \neq 0$, the *sharp/flat* (Kobayashi–Sprung) Selmer groups. These produce two $\lambda$-invariants, $\lambda^\sharp$ and $\lambda^\flat$, and correspondingly two $\mu$-invariants.

Matsuno's formula addresses the behavior of these invariants under **quadratic twist**. If $E^D$ is the twist of $E$ by a square-free $D \equiv 1 \pmod 4$, then — under the standing assumption that the pertinent $\mu$-invariant vanishes — the difference $\lambda^\sharp(E^D) - \lambda^\flat(E^D)$ is a sum of purely local contributions, indexed by the primes $\ell \mid D$ and controlled by the $2$-adic depth $n_\ell = v_2((\ell^2-1)/8)$.

### 1.2 The question

The vanishing of $\mu$ is a genuine hypothesis, not a triviality; for supersingular primes it is expected but not known in general. This raises the natural question addressed here:

> **When $\mu \neq 0$, how is Matsuno's formula corrected?**

The physically and arithmetically natural expectation is that the correction is **proportional to $\mu$**, with a local proportionality weight matching the classical $2$-adic depth. We formalize this expectation as an explicit arithmetic model and interrogate it in a contrarian manner: for each structural property one might hope for, we either prove it or exhibit a counterexample.

### 1.3 Contributions

We work with natural-number-valued invariants in which $\mu$, the conductor datum $N_E$, and the reduction-order function are parameters (Section 2). Our results are:

- **(Additivity, Thm. 4.3)** $\lambda\text{-diff}_\mu$ is additive over coprime moduli.
- **(Inversion, Thm. 5.3)** For ramified $D$, $\mu = (\lambda\text{-diff}_\mu(D) - \lambda\text{-diff}(D))/W(D)$.
- **(Monotonicity/Injectivity, Thms. 6.1–6.2)** $\mu \mapsto \lambda\text{-diff}_\mu(D)$ is strictly increasing, hence injective, for ramified $D$.
- **(Growth, Thm. 6.3)** Adjoining a new ramified prime strictly increases the invariant when $\mu > 0$.
- **(Depth law, Thm. 7.1)** $8 \cdot 2^{n_\ell} = 2^{v_2(\ell-1)+v_2(\ell+1)}$ for odd $\ell \geq 3$.
- **(Disproofs, Thms. 8.1–8.3)** Multiplicativity fails; recovery requires a prime divisor; the $\mu$-term is not lower-order.

---

## 2. Definitions

Throughout, $v_2 \colon \mathbb{N} \to \mathbb{N}$ denotes the $2$-adic valuation, and for $D \in \mathbb{N}$ we write $\mathrm{PF}(D)$ for the (finite) set of prime divisors of $D$.

**Definition 2.1 ($2$-adic depth).** For a natural number $\ell$, the *$2$-adic depth* is
$$
n_\ell = v_2\!\left(\frac{\ell^2 - 1}{8}\right).
$$
For odd $\ell$, $8 \mid \ell^2 - 1$, so the argument is a genuine integer and $n_\ell = v_2(\ell^2 - 1) - 3$.

**Definition 2.2 (Classical local term).** Given a conductor datum $N_E \in \mathbb{N}$ and a reduction-order function $\mathrm{ord} \colon \mathbb{N} \to \mathbb{N}$, the local contribution of a prime $\ell$ is
$$
c_\ell = \begin{cases}
2^{n_\ell} & \text{if } \ell \mid N_E,\\[2pt]
2^{n_\ell + 1} & \text{if } \ell \nmid N_E \text{ and } 2 \mid \mathrm{ord}(\ell),\\[2pt]
0 & \text{otherwise.}
\end{cases}
$$
This encodes the three cases of Matsuno's local factor: ramified in $E$, good with even reduction order, or otherwise.

**Definition 2.3 (Classical $\lambda$-difference).** The classical ($\mu = 0$) Matsuno difference is
$$
\lambda\text{-diff}(D) = \sum_{\ell \in \mathrm{PF}(D)} c_\ell.
$$

**Definition 2.4 ($\mu$-weight and total weight).** The local *$\mu$-weight* of a prime $\ell$ is $w_\ell = 2^{n_\ell}$, and the *total $\mu$-weight* of $D$ is
$$
W(D) = \sum_{\ell \in \mathrm{PF}(D)} 2^{n_\ell}.
$$

**Definition 2.5 ($\mu$-correction and corrected invariant).** The *$\mu$-correction* is $\mu\text{-term}(D,\mu) = \mu \cdot W(D)$, and the *$\mu$-corrected $\lambda$-difference* is
$$
\lambda\text{-diff}_\mu(D) = \lambda\text{-diff}(D) + \mu \cdot W(D).
$$

Note that the $\mu$-weight $w_\ell = 2^{n_\ell}$ coincides with the "ramified in $E$" case of the classical local factor $c_\ell$; the correction thus uses the same $2$-adic depth as the classical formula.

---

## 3. Elementary positivity

**Lemma 3.1 (Positivity of weights).** For every $\ell$, $w_\ell = 2^{n_\ell} > 0$.

*Proof.* A power of two is positive. $\qquad\blacksquare$

**Lemma 3.2 (Total weight positivity criterion).** $W(D) > 0$ if and only if $\mathrm{PF}(D) \neq \varnothing$.

*Proof.* If $\mathrm{PF}(D) = \varnothing$ the empty sum is $0$. If $\mathrm{PF}(D) \neq \varnothing$, then $W(D)$ is a nonempty sum of strictly positive terms (Lemma 3.1), hence positive. $\qquad\blacksquare$

**Lemma 3.3 (Weight at a prime).** If $p$ is prime, $W(p) = w_p = 2^{n_p}$.

*Proof.* $\mathrm{PF}(p) = \{p\}$, and the sum over a singleton is its single term. $\qquad\blacksquare$

---

## 4. Additivity over coprime moduli

The classical formula and the weight are both indexed by prime factors, and prime factors distribute over coprime products. This is the engine of all additivity statements.

**Lemma 4.1.** If $\gcd(a,b)=1$ with $a,b \neq 0$, then $\mathrm{PF}(ab) = \mathrm{PF}(a) \sqcup \mathrm{PF}(b)$ (disjoint union).

**Theorem 4.2 (Additivity of classical term and weight).** For coprime $a,b \neq 0$,
$$
\lambda\text{-diff}(ab) = \lambda\text{-diff}(a) + \lambda\text{-diff}(b), \qquad W(ab) = W(a) + W(b).
$$

*Proof.* Both quantities are sums over $\mathrm{PF}(\cdot)$ of a function of $\ell$ alone. By Lemma 4.1 the index set splits into disjoint pieces, and a sum over a disjoint union is the sum of the pieces. $\qquad\blacksquare$

**Theorem 4.3 (Complete additivity of the corrected invariant).** For coprime $a,b \neq 0$ and any $N_E, \mu, \mathrm{ord}$,
$$
\lambda\text{-diff}_\mu(ab) = \lambda\text{-diff}_\mu(a) + \lambda\text{-diff}_\mu(b).
$$

*Proof.* Expand $\lambda\text{-diff}_\mu = \lambda\text{-diff} + \mu W$ and apply Theorem 4.2 to each summand:
$$
\lambda\text{-diff}(ab) + \mu W(ab) = \big(\lambda\text{-diff}(a)+\lambda\text{-diff}(b)\big) + \mu\big(W(a)+W(b)\big),
$$
and regroup. The $\mu$-term preserves additivity. $\qquad\blacksquare$

---

## 5. The $\mu$-contribution and its inversion

**Theorem 5.1 (Base case).** $\lambda\text{-diff}_0(D) = \lambda\text{-diff}(D)$; the model reduces to Matsuno's formula at $\mu = 0$.

*Proof.* The correction is $0 \cdot W(D) = 0$. $\qquad\blacksquare$

**Theorem 5.2 ($\mu$-contribution).** For all $D, N_E, \mu, \mathrm{ord}$,
$$
\lambda\text{-diff}_\mu(D) - \lambda\text{-diff}(D) = \mu \cdot W(D).
$$

*Proof.* Immediate from Definition 2.5. $\qquad\blacksquare$

**Theorem 5.3 (Inversion / exact recovery of $\mu$).** If $\mathrm{PF}(D) \neq \varnothing$, then
$$
\frac{\lambda\text{-diff}_\mu(D) - \lambda\text{-diff}(D)}{W(D)} = \mu.
$$

*Proof.* By Theorem 5.2 the numerator equals $\mu \cdot W(D)$. By Lemma 3.2 the ramification hypothesis gives $W(D) > 0$, so $\mu \cdot W(D)$ divided by $W(D)$ equals $\mu$ exactly. $\qquad\blacksquare$

Theorem 5.3 is the paper's conceptual centerpiece: a non-vanishing $\mu$ is not merely detectable in the sharp/flat twist data — it is *measurable*, as a single exact ratio.

---

## 6. Monotonicity, injectivity, and growth

**Theorem 6.1 (Strict monotonicity in $\mu$).** If $\mathrm{PF}(D) \neq \varnothing$, the map $\mu \mapsto \lambda\text{-diff}_\mu(D)$ is strictly increasing.

*Proof.* For $a < b$, since $W(D) > 0$ (Lemma 3.2) we have $a \cdot W(D) < b \cdot W(D)$; adding the common term $\lambda\text{-diff}(D)$ preserves the strict inequality. $\qquad\blacksquare$

**Theorem 6.2 (Injectivity in $\mu$).** If $\mathrm{PF}(D) \neq \varnothing$, then $\mu \mapsto \lambda\text{-diff}_\mu(D)$ is injective.

*Proof.* A strictly monotone map is injective (Theorem 6.1). $\qquad\blacksquare$

**Theorem 6.3 (Strict growth under a new ramified prime).** If $p$ is prime, $p \nmid D$, $D \neq 0$, and $\mu > 0$, then
$$
\lambda\text{-diff}_\mu(D) < \lambda\text{-diff}_\mu(pD).
$$

*Proof.* Since $p \nmid D$, $\gcd(p,D)=1$; by Theorem 4.3, $\lambda\text{-diff}_\mu(pD) = \lambda\text{-diff}_\mu(p) + \lambda\text{-diff}_\mu(D)$. The added summand $\lambda\text{-diff}_\mu(p) = \lambda\text{-diff}(p) + \mu W(p)$ is strictly positive: by Lemma 3.3, $W(p) = 2^{n_p} > 0$, so $\mu W(p) > 0$ whenever $\mu > 0$. Adding a strictly positive quantity strictly increases the value. $\qquad\blacksquare$

---

## 7. The $2$-adic depth law

The $\mu$-weights are not ad hoc: they obey the same $2$-adic accounting as the classical local factors.

**Lemma 7.1.** For odd $\ell$, $8 \mid \ell^2 - 1$.

*Proof.* Write $\ell^2 - 1 = (\ell-1)(\ell+1)$, a product of consecutive even numbers; one is divisible by $4$ and the other by $2$. $\qquad\blacksquare$

**Lemma 7.2 (Valuation of $\ell^2-1$).** For odd $\ell \geq 3$, $v_2(\ell^2 - 1) = n_\ell + 3$.

*Proof.* By Lemma 7.1, $\ell^2 - 1 = 8 \cdot \frac{\ell^2-1}{8}$, and $v_2(8) = 3$. Since $\frac{\ell^2-1}{8} > 0$ for $\ell \geq 3$, additivity of $v_2$ over products gives $v_2(\ell^2-1) = 3 + v_2\!\left(\frac{\ell^2-1}{8}\right) = 3 + n_\ell$. $\qquad\blacksquare$

**Lemma 7.3 (Split form).** For odd $\ell \geq 3$, $n_\ell + 3 = v_2(\ell-1) + v_2(\ell+1)$.

*Proof.* Combine Lemma 7.2 with $v_2(\ell^2-1) = v_2((\ell-1)(\ell+1)) = v_2(\ell-1)+v_2(\ell+1)$. $\qquad\blacksquare$

**Theorem 7.4 (Depth law).** For odd $\ell \geq 3$,
$$
8 \cdot 2^{n_\ell} = 2^{\,v_2(\ell-1) + v_2(\ell+1)}.
$$

*Proof.* By Lemma 7.3, $v_2(\ell-1)+v_2(\ell+1) = n_\ell + 3$, so the right side is $2^{n_\ell+3} = 8 \cdot 2^{n_\ell}$. $\qquad\blacksquare$

**Corollary 7.5 (Minimal weight).** $w_\ell = 2^{n_\ell} = 1$ exactly when $v_2(\ell-1)+v_2(\ell+1) = 3$, i.e. for $\ell \equiv \pm 3 \pmod 8$.

---

## 8. Disproofs: three plausible conjectures that fail

Contrarian methodology demands that we test — and, where warranted, break — the properties one is tempted to assume.

**Theorem 8.1 (Multiplicativity fails).** There exist coprime $a,b \neq 0$ and parameters $N_E, \mu, \mathrm{ord}$ with
$$
\lambda\text{-diff}_\mu(ab) \neq \lambda\text{-diff}_\mu(a) \cdot \lambda\text{-diff}_\mu(b).
$$

*Proof.* Take $a = 3$, $b = 5$, $N_E = 1$, $\mu = 0$, and $\mathrm{ord}(\ell) = 2$ for $\ell = 5$, $\mathrm{ord}(\ell)=1$ otherwise. Then $3 \nmid N_E$ and $\mathrm{ord}(3)$ is odd, so $c_3 = 0$ and $\lambda\text{-diff}_\mu(3) = 0$; while $5 \nmid N_E$ and $\mathrm{ord}(5)$ is even, so $c_5 = 2^{n_5+1} > 0$ and $\lambda\text{-diff}_\mu(5) > 0$. The product is $0 \cdot (\text{positive}) = 0$, but by additivity (Theorem 4.3) $\lambda\text{-diff}_\mu(15) = 0 + (\text{positive}) > 0$. $\qquad\blacksquare$

The correct compositional law is addition, not multiplication.

**Theorem 8.2 (Recovery requires a prime divisor).** For $D = 1$, the map $\mu \mapsto \lambda\text{-diff}_\mu(1)$ is **not** injective.

*Proof.* $\mathrm{PF}(1) = \varnothing$, so $W(1) = 0$ and $\lambda\text{-diff}_\mu(1) = \lambda\text{-diff}(1)$ for every $\mu$. In particular $\mu = 0$ and $\mu = 1$ give the same value, contradicting injectivity. $\qquad\blacksquare$

Thus the ramification hypothesis in Theorems 5.3, 6.1, and 6.2 is *sharp*, not a convenience.

**Theorem 8.3 (The $\mu$-correction is not lower-order).** There exist $D, N_E, \mu, \mathrm{ord}$ with
$$
\lambda\text{-diff}(D) < \mu \cdot W(D).
$$

*Proof.* Take $D = 3$, $N_E = 1$, $\mu = 1$, $\mathrm{ord} \equiv 1$. Then $3 \nmid N_E$ and $\mathrm{ord}(3)$ is odd, so $c_3 = 0$ and $\lambda\text{-diff}(3) = 0$; whereas $W(3) = 2^{n_3} > 0$, so $\mu W(3) > 0$. Hence $0 < \mu W(3)$. $\qquad\blacksquare$

The correction can strictly exceed the entire classical Matsuno contribution: $\mu$ is a leading-order phenomenon, not a perturbation.

---

## 9. Algorithms

The model is fully effective. We record two algorithms; both are polynomial in the size of $D$ once its factorization is known.

**Algorithm A (Depth and weight).** Given odd $\ell$, compute $n_\ell$ by factoring out powers of $2$ from $\ell^2 - 1$ and subtracting $3$; return $w_\ell = 2^{n_\ell}$. Complexity: $O(\log \ell)$ bit operations after the trivial computation of $\ell^2 - 1$.

**Algorithm B (Corrected invariant and inversion).** Given the factorization of $D$, the parameters $N_E, \mathrm{ord}, \mu$: sum the classical local terms $c_\ell$ to get $\lambda\text{-diff}(D)$; sum the weights $w_\ell$ to get $W(D)$; return $\lambda\text{-diff}(D) + \mu W(D)$. For inversion, given $\lambda\text{-diff}_\mu(D)$ and $\lambda\text{-diff}(D)$ with $W(D) > 0$, return $(\lambda\text{-diff}_\mu(D) - \lambda\text{-diff}(D)) / W(D)$, which equals $\mu$ exactly. Complexity: $O(\omega(D))$ arithmetic operations, where $\omega(D) = |\mathrm{PF}(D)|$.

---

## 10. Applications and discussion

The inversion formula (Theorem 5.3) reframes the central analytic problem — *what is the true proportionality constant of the $\mu$-correction?* — as the determination of a single measurable ratio. If genuine sharp/flat $\lambda$- and $\mu$-invariants are computed for a family of twists $E^D$, and if the true correction has the form $\lambda^\sharp - \lambda^\flat = (\text{classical}) + \mu \cdot C(D)$ for some weight $C(D)$, then $C(D)$ is recovered as $(\text{observed difference} - \text{classical})/\mu$. The model predicts $C(D) = W(D) = \sum_{\ell \mid D} 2^{n_\ell}$; any deviation would be immediately visible.

The additivity theorem constrains the possible shape of any correct correction: because both the classical term and the empirically expected $\mu$-term are local (additive over coprime $D$), any derived $\mu$-correction that is *not* additive would be inconsistent with the local nature of twisting. This is a nontrivial falsifiable prediction.

The disproofs are equally informative for practice. Theorem 8.1 warns against modeling the invariant multiplicatively (a natural but wrong instinct for a factorization-indexed quantity). Theorem 8.2 identifies exactly when the invariant is blind to $\mu$. Theorem 8.3 cautions that in Iwasawa-theoretic estimates the $\mu$-term cannot be discarded as lower-order.

---

## 11. Future directions

**Genuine sharp/flat invariants.** The present work is an arithmetic *model* isolating the combinatorial content of the conjectured $\mu$-term. Constructing Kobayashi–Sprung sharp/flat Selmer groups and their $\Lambda$-module invariants directly — via the Iwasawa algebra, Weierstrass preparation over $\mathbb{Z}_p[[T]]$, and control theorems — would let $\lambda\text{-diff}$, $w_\ell$, and $\lambda\text{-diff}_\mu$ be *derived* rather than posited. The additivity and inversion theorems predict exactly what those derived quantities must satisfy.

**Proportionality constant.** The model uses local weight $2^{n_\ell}$ for the $\mu$-term, matching the classical local depth. Determining whether the true $\mu$-correction uses this weight, or a $\mu$-independent multiple of it, is the central analytic question; the inversion formula turns it into a single measurable ratio.

**The $D \equiv 1 \pmod 4$ and supersingular-at-$2$ hypotheses.** These constrain which primes $\ell$ and residues occur; a refined model tracking $\ell \bmod 8$ (recall $w_\ell = 1 \iff \ell \equiv \pm 3 \pmod 8$) could sharpen the weight law into an exact congruence-indexed formula.

**Higher $\mu$ and layered towers.** Extending injectivity and the inversion formula to layered $\mathbb{Z}_p$-towers, and to higher $\mu$, would test the robustness of the linear-in-$\mu$ ansatz.

---

## References

- K. Matsuno, *Construction of elliptic curves with large Iwasawa $\lambda$-invariants and large Tate–Shafarevich groups* (twist behavior of $\lambda$-invariants), and related work on $\lambda$-invariants under quadratic twist.
- S. Kobayashi, *Iwasawa theory for elliptic curves at supersingular primes*, Invent. Math. 152 (2003).
- F. Sprung, *Iwasawa theory for elliptic curves at supersingular primes: a pair of main conjectures*, J. Number Theory 132 (2012).
- K. Iwasawa, *On $\mathbb{Z}_\ell$-extensions of algebraic number fields*, Ann. of Math. 98 (1973).
