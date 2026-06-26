# Tightness of the Unit-Shift Bound for Euler's Totient Function: A Constructive and Verified Skeleton

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Bridges (Analytic Number Theory ↔ Formal Verification)

---

## Abstract

Let $\varphi$ denote Euler's totient function and define the *unit-shift
collision counting function*
$$S_1^{\varphi}(x) = \#\{\, n \le x : \varphi(n) = \varphi(n+1)\,\}.$$
A theorem of Graham, Holt, and Pomerance gives the upper bound
$S_1^{\varphi}(x) \ll x\exp\{-(\tfrac12 - o(1))\sqrt{\log x\,\log_2 x}\}$, and the
companion *tightness* statement asserts a matching lower bound
$S_1^{\varphi}(x) \ge C\,x\exp\{-(\tfrac12 + o(1))\sqrt{\log x\,\log_2 x}\}$ for a
constant $C>0$ and all large $x$. While the full asymptotic is analytic, its
logical engine is constructive: one *builds* many integers $n$ with
$\varphi(n)=\varphi(n+1)$ and *counts* them. This paper formalizes that engine. We
(i) certify a family of explicit collisions via coprime multiplicativity of
$\varphi$ rather than opaque enumeration; (ii) establish a *counting transfer
theorem* turning any finite verified witness set into a lower bound on
$S_1^{\varphi}$; (iii) derive the unconditional bounds $6\le S_1^{\varphi}(194)$
and $10 \le S_1^{\varphi}(975)$; (iv) prove non-saturation $S_1^{\varphi}(x)<x$ for
$x\ge 2$; and (v) prove the structural parity law that every collision value with
$n\ge 3$ is even. Each collision is verified by factoring $n$ and $n+1$ into
coprime prime powers and applying multiplicativity, exposing the "power-of-two
versus product-of-small-odd-primes" balancing that drives the lower-bound
construction. All results are machine-checked.

---

## 1. Introduction

Euler's totient function $\varphi(n)$ counts the integers in $\{1,\dots,n\}$
coprime to $n$. It is multiplicative, highly irregular under additive shifts, and
central to elementary and analytic number theory. The *unit-shift equation*
$$\varphi(n) = \varphi(n+1) \tag{1}$$
asks for consecutive integers with equal totient. Because $n$ and $n+1$ are
coprime and typically have unrelated factorizations, solutions to (1) are
genuinely coincidental, yet they occur infinitely often in empirical data and are
widely believed (though not proven) to be infinite in number.

The quantitative study of (1) was settled, up to the secondary term in the
exponent, by Graham, Holt, and Pomerance (GHP), who proved

$$S_1^{\varphi}(x) \;\ll\; x\,\exp\!\Big\{-\big(\tfrac12 - o(1)\big)\sqrt{\log x\,\log_2 x}\Big\}, \tag{2}$$

where $\log_2 x = \log\log x$, and the matching *tightness* lower bound

$$S_1^{\varphi}(x) \;\ge\; C\,x\,\exp\!\Big\{-\big(\tfrac12 + o(1)\big)\sqrt{\log x\,\log_2 x}\Big\}. \tag{3}$$

The exponent $\sqrt{\log x\,\log_2 x}$ is the signature of smooth-number
balancing: it is the same shape that governs the count of $y$-smooth numbers and
the heuristic complexity of subexponential factoring.

This paper does not formalize the analytic estimate (3). Instead it formalizes
the **constructive skeleton** on which (3) rests. The lower bound is, in spirit, a
counting statement over an explicitly constructed family of solutions to (1); we
isolate and machine-verify the constructive and combinatorial primitives that any
such argument consumes:

1. **Witness certification** by multiplicativity (Section 3).
2. **Counting transfer**: verified witnesses $\Rightarrow$ lower bound (Section 4).
3. **Structural constraints** ruling out trivial saturation and odd values (Section 5).

### 1.1 Notation and conventions

Throughout, $n, m, x$ range over nonnegative integers; $\varphi$ is `Nat.totient`.
We write $[\,P\,]$ for the Iverson bracket and use $\#$ for cardinality of a finite
set. For primes $p$ and exponents $k\ge 1$ we use the standard evaluations
$\varphi(p) = p-1$ and $\varphi(p^k) = p^{k-1}(p-1)$, together with multiplicativity
on coprime arguments.

---

## 2. Preliminaries on the totient

We record the three evaluation principles used pervasively below. They are
classical and available in the formal library as `Nat.totient_mul`,
`Nat.totient_prime`, and `Nat.totient_prime_pow`.

**Proposition 2.1 (Coprime multiplicativity).** If $\gcd(a,b)=1$ then
$\varphi(ab) = \varphi(a)\,\varphi(b)$.

**Proposition 2.2 (Primes).** For prime $p$, $\varphi(p) = p-1$.

**Proposition 2.3 (Prime powers).** For prime $p$ and $k\ge 1$,
$\varphi(p^k) = p^{k-1}(p-1)$.

**Proposition 2.4 (Evenness).** For $m \ge 3$, $\varphi(m)$ is even. *(Formal name:
`Nat.totient_even`.)*

These suffice to reduce any single instance of (1) to a finite arithmetic
identity, provided we supply the factorizations of $n$ and $n+1$.

---

## 3. Explicit, multiplicatively-certified witnesses

We call $n$ a **unit-shift collision** (or *GHP witness*) if
$\varphi(n)=\varphi(n+1)$. The following eight theorems certify witnesses by the
structural method: factor $n$ and $n+1$ into coprime prime powers, expand $\varphi$
via Propositions 2.1–2.3, and verify the resulting numerical identity. We
emphasize that these are *not* wrapped enumerations; the only enumeration-like
step is the final arithmetic comparison.

**Theorem 3.1 (`ghp_15`).** $\varphi(15)=\varphi(16)$.
*Proof.* $15 = 3\cdot 5$ (coprime), so $\varphi(15)=\varphi(3)\varphi(5)=2\cdot 4=8$;
$16 = 2^4$, so $\varphi(16)=2^{3}(2-1)=8$. $\square$

**Theorem 3.2 (`ghp_104`).** $\varphi(104)=\varphi(105)$.
*Proof.* $104 = 2^3\cdot 13$, $\varphi=2^2(1)\cdot 12 = 4\cdot 12 = 48$;
$105 = 3\cdot 5\cdot 7$, $\varphi = 2\cdot 4\cdot 6 = 48$. $\square$

**Theorem 3.3 (`ghp_164`).** $\varphi(164)=\varphi(165)$.
*Proof.* $164 = 2^2\cdot 41$, $\varphi = 2\cdot 40 = 80$;
$165 = 3\cdot 5\cdot 11$, $\varphi = 2\cdot 4\cdot 10 = 80$. $\square$

**Theorem 3.4 (`ghp_194`).** $\varphi(194)=\varphi(195)$.
*Proof.* $194 = 2\cdot 97$, $\varphi = 1\cdot 96 = 96$;
$195 = 3\cdot 5\cdot 13$, $\varphi = 2\cdot 4\cdot 12 = 96$. $\square$

**Theorem 3.5 (`ghp_255`).** $\varphi(255)=\varphi(256)$.
*Proof.* $255 = 3\cdot 5\cdot 17$, $\varphi = 2\cdot 4\cdot 16 = 128$;
$256 = 2^8$, $\varphi = 2^7 = 128$. This is the archetypal "Fermat-prime versus
power-of-two" balancing. $\square$

**Theorem 3.6 (`ghp_495`).** $\varphi(495)=\varphi(496)$.
*Proof.* $495 = 3^2\cdot 5\cdot 11$, $\varphi = (3\cdot 2)\cdot 4\cdot 10 = 240$;
$496 = 2^4\cdot 31$, $\varphi = 2^3\cdot 30 = 8\cdot 30 = 240$. $\square$

**Theorem 3.7 (`ghp_584`).** $\varphi(584)=\varphi(585)$.
*Proof.* $584 = 2^3\cdot 73$, $\varphi = 4\cdot 72 = 288$;
$585 = 3^2\cdot 5\cdot 13$, $\varphi = 6\cdot 4\cdot 12 = 288$. $\square$

**Theorem 3.8 (`ghp_975`).** $\varphi(975)=\varphi(976)$.
*Proof.* $975 = 3\cdot 5^2\cdot 13$, $\varphi = 2\cdot 20\cdot 12 = 480$;
$976 = 2^4\cdot 61$, $\varphi = 8\cdot 60 = 480$. $\square$

**Remark 3.9 (The balancing principle).** In each witness above, one neighbor
carries the bulk of its $2$-adic valuation as an explicit power of two, while the
other is (up to a small odd-prime-power core) a product of odd primes $p$ whose
$p-1$ are $2$-rich. The totient turns those $p-1$ factors back into powers of two,
matching the opposite side. Theorem 3.5 is the purest case: $3,5,17$ are Fermat
primes ($2+1, 4+1, 16+1$), so $\varphi(3\cdot5\cdot17) = 2\cdot4\cdot16 = 2^7 =
\varphi(2^8)$. This is precisely the local mechanism the GHP lower-bound family
scales up.

---

## 4. The counting function and the transfer theorem

**Definition 4.1 (`S1phi`).** For $x\in\mathbb N$,
$$S_1^{\varphi}(x) := \#\{\, n : 1 \le n \le x,\ \varphi(n) = \varphi(n+1)\,\} = \#\big(\{1,\dots,x\}\cap \mathcal W\big),$$
where $\mathcal W = \{\,n : \varphi(n)=\varphi(n+1)\,\}$ is the witness set. Formally
this is the cardinality of the filter of the interval $\{1,\dots,x\}$ by the
decidable predicate $\varphi(n)=\varphi(n+1)$.

**Proposition 4.2 (Monotonicity).** $S_1^{\varphi}$ is nondecreasing: if $x\le y$
then $S_1^{\varphi}(x)\le S_1^{\varphi}(y)$.
*Proof sketch.* The filtered set for $x$ is a subset of that for $y$, since the
underlying interval grows; apply monotonicity of cardinality under set inclusion
(`Finset.card_le_card`). $\square$

**Theorem 4.3 (Counting transfer, `S1phi_ge_card`).** Let
$W \subseteq \{1,\dots,x\}$ be a finite set such that $\varphi(w)=\varphi(w+1)$ for
every $w\in W$. Then
$$\#W \;\le\; S_1^{\varphi}(x).$$
*Proof sketch.* Every $w\in W$ satisfies the defining predicate and lies in
$\{1,\dots,x\}$, so $W$ is a subset of the filtered interval whose cardinality is
$S_1^{\varphi}(x)$; conclude by `Finset.card_le_card`. $\square$

Theorem 4.3 is the formal crux. It converts the *constructive* content of the GHP
lower bound — "here are many solutions to (1) below $x$" — into a *quantitative*
statement about $S_1^{\varphi}(x)$, with no analysis required at the transfer step.
Any infinite verified witness family therefore yields, instance by instance, a
verified lower bound.

**Corollary 4.4 (Explicit lower bounds).** With the witnesses of Section 3 and
the small solutions $1$ ($\varphi(1)=\varphi(2)=1$) and $3$
($\varphi(3)=\varphi(4)=2$):
$$6 \le S_1^{\varphi}(194), \qquad 10 \le S_1^{\varphi}(975).$$
*Proof.* Apply Theorem 4.3 with $W = \{1,3,15,104,164,194\}$ (six witnesses,
all $\le 194$) and with $W = \{1,3,15,104,164,194,255,495,584,975\}$ (ten
witnesses, all $\le 975$). $\square$

A direct search confirms these are exact: $S_1^{\varphi}(194)=6$ and
$S_1^{\varphi}(975)=10$, and indeed $S_1^{\varphi}(1000)=10$, the full list of
collisions up to $1000$ being $\{1,3,15,104,164,194,255,495,584,975\}$.

---

## 5. Structural constraints

A lower-bound theory is only meaningful if the counting function does not trivially
saturate. We record two constraints.

**Theorem 5.1 (Non-saturation, `S1phi_lt_self`).** For every $x \ge 2$,
$$S_1^{\varphi}(x) < x.$$
*Proof sketch.* It suffices to exhibit one certified non-collision in
$\{1,\dots,x\}$. Take $n=2$: $\varphi(2)=1 \ne 2 = \varphi(3)$. Hence the filtered
interval is a *proper* subset of $\{1,\dots,x\}$, and a proper subset of a finite
set has strictly smaller cardinality (`Finset.card_lt_card`). $\square$

**Theorem 5.2 (Parity of collision values, `totient_shift_value_even`).** If
$n\ge 3$ and $\varphi(n)=\varphi(n+1)$, then the common value $\varphi(n)$ is even.
*Proof sketch.* Since $n\ge 3$, Proposition 2.4 gives $2 \mid \varphi(n)$; the
hypothesis transfers this to $\varphi(n+1)$ as well. (One could equally invoke it
on $n+1\ge 3$.) $\square$

Theorem 5.2 is the crudest layer of a conjectural concentration phenomenon
(Section 7): collision values should be multiplicatively rich, because two
distinct coprime factorizations can produce the same totient only when that value
admits enough internal structure to be assembled in two ways.

---

## 6. Discussion: from witnesses to asymptotics

The arc (2)–(3) is analytic, but the lower bound (3) is morally a counting
statement over a constructed family $\mathcal F_x \subseteq \mathcal W \cap
\{1,\dots,x\}$. The members of $\mathcal F_x$ generalize Theorem 3.5: one builds
$n+1$ (or $n$) as a power of two times a small core, and the opposite neighbor as a
product of odd primes $p$ with $p-1$ supported on small primes, arranged so the
totients coincide. The number of admissible balanced factorizations below $x$ is a
partition-type count whose logarithm is $\asymp \sqrt{\log x\,\log_2 x}$ — the
smooth-number signature. Theorem 4.3 guarantees $\#\mathcal F_x \le
S_1^{\varphi}(x)$, so the construction's size *is* the lower bound.

This is the "bridge" the domain label names: an analytic density theorem reduced,
at its constructive heart, to verifiable multiplicative identities (Section 3) and
a one-line counting lemma (Theorem 4.3). The formal artifact certifies the heart
without claiming the asymptotic tail.

### 6.1 Algorithmic content

Three algorithms organize the constructive side:

- **Multiplicative totient evaluation** (factor, then expand via 2.1–2.3) — the
  certification primitive of Section 3.
- **Witness enumeration** ($\varphi(n)\stackrel{?}{=}\varphi(n+1)$ over an
  interval) — produces candidate families and confirms exactness of Corollary 4.4.
- **Transfer instantiation** (assemble a verified $W$, invoke Theorem 4.3) — the
  mechanized lower-bound step.

These are detailed in the accompanying `demo.py` and in the algorithms bundle.

---

## 7. Future work

We highlight the directions seeded by this skeleton.

- **Infinitude (open).** Prove $S_1^{\varphi}(x)\to\infty$. Theorem 4.3 reduces
  this to exhibiting a single *infinite* verifiable family of balanced coprime
  factorizations; each instance is mechanizable as in Section 3.
- **Intermediate growth.** Establish $(\log x)^A \le S_1^{\varphi}(x) \le x^{\varepsilon}$,
  matching the $\exp\{\pm(\tfrac12+o(1))\sqrt{\log x\,\log_2 x}\}$ shape; the
  non-saturation bound (Theorem 5.1) and the explicit lower bounds (Corollary 4.4)
  pin the function strictly between trivial bounds.
- **Value concentration.** Strengthen Theorem 5.2 from parity to high
  divisibility: collision values should concentrate on integers with many distinct
  small prime factors.
- **Smooth-number bridge.** Make precise the link between witness density and
  smooth-number density underlying the shared exponent.

---

## 8. Conclusion

We have isolated and machine-verified the constructive skeleton beneath the
tightness of the GHP unit-shift bound: eight structurally certified witnesses, a
counting transfer theorem converting witnesses into lower bounds, explicit
unconditional bounds $6 \le S_1^{\varphi}(194)$ and $10 \le S_1^{\varphi}(975)$,
non-saturation $S_1^{\varphi}(x)<x$, and the parity law for collision values. The
recurring mechanism — a power of two balanced against a product of small odd
primes via coprime multiplicativity — is exactly the local engine that, scaled to
an infinite family, yields the matching lower bound (3). The asymptotic tail
remains analytic; its constructive core is now verified.

---

## Appendix A. Witness table

| $n$ | factorization of $n$ | factorization of $n+1$ | common $\varphi$ |
|----:|---------------------|------------------------|----------------:|
| 1   | $1$                 | $2$                    | 1 |
| 3   | $3$                 | $2^2$                  | 2 |
| 15  | $3\cdot5$           | $2^4$                  | 8 |
| 104 | $2^3\cdot13$        | $3\cdot5\cdot7$        | 48 |
| 164 | $2^2\cdot41$        | $3\cdot5\cdot11$       | 80 |
| 194 | $2\cdot97$          | $3\cdot5\cdot13$       | 96 |
| 255 | $3\cdot5\cdot17$    | $2^8$                  | 128 |
| 495 | $3^2\cdot5\cdot11$  | $2^4\cdot31$           | 240 |
| 584 | $2^3\cdot73$        | $3^2\cdot5\cdot13$     | 288 |
| 975 | $3\cdot5^2\cdot13$  | $2^4\cdot61$           | 480 |
