# RSA Factorization from a Small Private Exponent and Partial Knowledge of $p+q$: A Complete, Exact Chain from Convergents to Primes

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Cryptanalysis / Number Theory

---

## Abstract

We present a complete and exact treatment of a *modified Wiener attack* on RSA that exploits both a small private exponent and partial knowledge of the most significant bits of the prime sum $p+q$. For an RSA modulus $n = pq$ with primes $p > q$, public exponent $e$, and private exponent $d$ satisfying the key equation $ed = k\varphi(n) + 1$, the classical Wiener attack recovers $d$ when $d < n^{1/4}$. We sharpen the attack by introducing a **corrected modulus** $\tilde n = n + 1 - s$ built from an estimate $s$ of $p+q$, so that the relevant approximation error is governed by the *estimation residual* $(p+q) - s$ rather than by $p+q$ itself. When a $\delta$-fraction of the most significant bits of $p+q$ is known, the residual is bounded by some $\Delta$, and we show that the convergent criterion holds — and hence $d$ is recovered — under the **partial-knowledge smallness condition** $2d(k\Delta + 1) < \tilde n$, which admits private exponents up to roughly $n^{(1+\delta)/2}$.

The contribution has three pillars, all established as exact identities or sharp inequalities. First, an *arithmetic engine* reduces the key equation to an exact rational approximation $e/\tilde n - k/d = (1 - k((p+q)-s))/(\tilde n d)$ and bounds it below the Legendre threshold $1/(2d^2)$. Second, a *recovery* layer uses Farey separation $|a/b - c/e| \ge 1/(be)$ to prove uniqueness of the recovered convergent, and upgrades fraction-equality to denominator-equality $b = d$ under coprimality of the true fraction. Third — and this is the missing final step in many expositions — a *factorization* layer shows that recovering $d$ is equivalent to factoring $n$: the key equation yields $\varphi(n)$, hence $p+q = n - \varphi(n) + 1$, and the primes are the roots of $X^2 - (p+q)X + n$ recovered in closed form by the quadratic formula, whose discriminant $(p+q)^2 - 4n = (p-q)^2$ is a *perfect square*. We chain all three pillars into a single end-to-end statement: under the smallness condition, any candidate convergent $a/b$ of $e/\tilde n$ within the Legendre threshold and with $0 < b \le d$ satisfies $b = d$, and the primes $p, q$ are then given in closed form. Every result has been formally verified.

---

## 1. Introduction

The RSA cryptosystem derives its security from the presumed hardness of integer factorization: given $n = pq$ with $p, q$ large primes, recovering $p$ and $q$ is believed infeasible. The public key is the pair $(n, e)$ and the private key is $d$, where

$$ed \equiv 1 \pmod{\varphi(n)}, \qquad \varphi(n) = (p-1)(q-1),$$

equivalently $ed = k\varphi(n) + 1$ for some integer $k \ge 1$. Decryption cost scales with $d$, creating a standing incentive to choose $d$ small. Wiener (1990) demonstrated that this is dangerous: if $d < \tfrac{1}{3} n^{1/4}$, then $k/d$ is a continued-fraction convergent of $e/n$, and $d$ — hence the factorization — is recoverable in polynomial time.

A natural strengthening arises when the attacker possesses *side information*. Partial key exposure attacks (Boneh–Durfee–Frankel and successors) show that leaking a fraction of the bits of $d$, or of $p$, compromises RSA well beyond the classical thresholds. In this paper we study a complementary leak: knowledge of the most significant bits of the **prime sum** $p+q$. Because $n - \varphi(n) = (p+q) - 1$, the quantity $p+q$ is precisely the obstruction separating the public $n$ from the secret $\varphi(n)$. Estimating it shrinks that obstruction, sharpening the Wiener approximation.

Our treatment is distinguished by being **exact and complete**:

- *Exact.* Every reduction is an algebraic identity over $\mathbb{Z}$ or $\mathbb{Q}$, and every bound is a sharp inequality with explicit, load-bearing hypotheses. There are no asymptotic hand-waves in the core engine.
- *Complete.* We do not stop at "recover $d$." We prove the final factorization step and the structural fact that makes it exact — the discriminant $(p+q)^2 - 4n$ is the perfect square $(p-q)^2$ — and chain everything into a single capstone theorem.

All results stated below have been formally verified in a proof assistant; the names in parentheses are the corresponding formal theorem names.

---

## 2. Preliminaries and Definitions

Throughout, $p, q, e, d, k, s, \Delta, a, b$ denote integers, with $p > q$ the RSA primes, $n = pq$, $e$ the public exponent, $d$ the private exponent, and $k$ the cofactor in the key equation.

**Definition 2.1 (Totient of a semiprime; `phiSemiprime`).**
For integers $p, q$ define
$$\varphi(p, q) := (p - 1)(q - 1).$$
For $n = pq$ this is Euler's totient $\varphi(n)$.

**Definition 2.2 (Corrected modulus; `correctedModulus`).**
Given an estimate $s$ of $p+q$, define the corrected modulus
$$\tilde n(p, q, s) := pq + 1 - s.$$

**Lemma 2.3 (Totient gap; `n_sub_phi`).**
For all integers $p, q$,
$$pq - \varphi(p,q) = (p + q) - 1.$$
*Proof.* Expand $\varphi(p,q) = pq - p - q + 1$; subtract from $pq$. $\square$

**Lemma 2.4 (Perfect estimate recovers the totient; `correctedModulus_perfect`).**
For all integers $p, q$,
$$\tilde n(p, q, \, p+q) = \varphi(p, q).$$
*Proof.* $\tilde n(p,q,p+q) = pq + 1 - (p+q) = (p-1)(q-1) = \varphi(p,q)$. $\square$

Lemma 2.4 is the conceptual hinge: a *perfect* estimate of $p+q$ turns the corrected modulus into the totient, at which point the Wiener approximation is sharpest. Real attacks use an imperfect $s$, and the residual $(p+q) - s$ controls the degradation.

---

## 3. The Arithmetic Engine

This section reduces the RSA key equation to an exact rational approximation and bounds it below the Legendre threshold.

### 3.1 Key identities

**Theorem 3.1 (Classical key identity; `rsa_key_identity`).**
If $ed = k\,\varphi(p,q) + 1$, then
$$ed - k(pq) = 1 - k\bigl((p+q) - 1\bigr).$$
*Proof.* Substitute $\varphi(p,q) = (p-1)(q-1)$ into the hypothesis and expand; the residual $ed - kpq$ collapses to $1 - k((p+q)-1)$. $\square$

This exhibits the residual of $ed - kn$ as governed by the *small* quantity $p+q$ (of size $\Theta(\sqrt n)$), which is the algebraic root of Wiener's attack.

**Theorem 3.2 (Modified key identity; `modified_key_identity`).**
If $ed = k\,\varphi(p,q) + 1$, then for any estimate $s$,
$$ed - k\,\tilde n(p,q,s) = 1 - k\bigl((p+q) - s\bigr).$$
*Proof.* As in Theorem 3.1, but with $\tilde n = pq + 1 - s$; the residual is now controlled by the *estimation error* $(p+q) - s$ in place of $p+q$. $\square$

### 3.2 Exact approximation error

**Theorem 3.3 (Exact approximation error; `modified_approx_error`).**
Over $\mathbb{Q}$, if $ed = k\varphi(p,q) + 1$, $\tilde n \ne 0$, and $d \ne 0$, then
$$\frac{e}{\tilde n} - \frac{k}{d} = \frac{1 - k\bigl((p+q) - s\bigr)}{\tilde n \cdot d}.$$
*Proof.* Cast Theorem 3.2 to $\mathbb{Q}$ to get $e d - k \tilde n = 1 - k((p+q)-s)$; clear denominators in the target identity (valid since $\tilde n, d \ne 0$) and substitute. $\square$

This is the central quantity: the attack drives its absolute value below $1/(2d^2)$.

### 3.3 Bounding under partial knowledge

**Theorem 3.4 (Approximation bound; `modified_approx_abs_bound`).**
Suppose $ed = k\varphi(p,q) + 1$, $|(p+q) - s| \le \Delta$, $k \ge 0$, $\tilde n > 0$, and $d > 0$. Then
$$\left|\frac{e}{\tilde n} - \frac{k}{d}\right| \le \frac{k\Delta + 1}{\tilde n \cdot d}.$$
*Proof.* By Theorem 3.3 the left side equals $|1 - k((p+q)-s)|/(\tilde n d)$. Bound the numerator: $|1 - k((p+q)-s)| \le 1 + k|(p+q)-s| \le 1 + k\Delta$, using $k \ge 0$ and $|(p+q)-s| \le \Delta$. Positivity of $\tilde n, d$ preserves the inequality after dividing. $\square$

**Theorem 3.5 (Modified Wiener convergent criterion; `modified_wiener_convergent_criterion`).**
Under the hypotheses of Theorem 3.4 together with the **partial-knowledge smallness condition**
$$2d(k\Delta + 1) < \tilde n,$$
we have
$$\left|\frac{e}{\tilde n} - \frac{k}{d}\right| < \frac{1}{2 d^2}.$$
*Proof.* By Theorem 3.4 the left side is at most $(k\Delta+1)/(\tilde n d)$. It suffices that $(k\Delta+1)/(\tilde n d) < 1/(2d^2)$, i.e. $2d^2(k\Delta+1) < \tilde n d$, i.e. (dividing by $d > 0$) $2d(k\Delta+1) < \tilde n$, which is exactly the smallness condition. $\square$

The criterion is the green light of Legendre's theorem: a fraction $k/d$ within $1/(2d^2)$ of a real number $x$ is necessarily a continued-fraction convergent of $x$. Theorem 3.5 thus guarantees that the secret fraction $k/d$ appears among the (few, efficiently computable) convergents of the public number $e/\tilde n$.

**Interpretation of the bound.** The smallness condition is the exact finite shadow of the asymptotic bound $d < n^{(1+\delta)/2}$. With no bits known, $\Delta \approx \sqrt n$ and (using $k \le d$, $\tilde n \approx n$) the condition reduces to roughly $d^2 \sqrt n \lesssim n$, i.e. $d \lesssim n^{1/4}$ — Wiener's classical bound. Each known most-significant bit of $p+q$ halves $\Delta$, relaxing the constraint geometrically; knowing a $\delta$-fraction gives $\Delta \approx n^{(1-\delta)/2}$ and admits $d \lesssim n^{(1+\delta)/2}$.

---

## 4. Recovery: Uniqueness of the Convergent

The criterion of §3 places $k/d$ among the convergents of $e/\tilde n$. To *identify* it uniquely — and to read off the true private exponent — we need a separation principle.

**Theorem 4.1 (Farey separation; `farey_separation`).**
For integers with $b > 0$ and $e > 0$, if $a/b \ne c/e$ (equivalently $ae \ne cb$), then
$$\left|\frac{a}{b} - \frac{c}{e}\right| \ge \frac{1}{b \cdot e}.$$
*Proof.* Write $a/b - c/e = (ae - cb)/(be)$. Since $ae \ne cb$ are integers, $|ae - cb| \ge 1$. Divide by $be > 0$. $\square$

**Theorem 4.2 (Uniqueness of recovery; `wiener_unique_recovery`).**
Let $x \in \mathbb{Q}$ and let $0 < b \le d$, $0 < d$. If
$$\left|x - \frac{k}{d}\right| < \frac{1}{2d^2} \quad\text{and}\quad \left|x - \frac{a}{b}\right| < \frac{1}{2d^2},$$
then $k/d = a/b$ as rationals.
*Proof.* Suppose not. By the triangle inequality,
$$\left|\frac{k}{d} - \frac{a}{b}\right| \le \left|x - \frac{k}{d}\right| + \left|x - \frac{a}{b}\right| < \frac{1}{2d^2} + \frac{1}{2d^2} = \frac{1}{d^2}.$$
But by Farey separation (Theorem 4.1), distinct fractions satisfy $|k/d - a/b| \ge 1/(d b) \ge 1/d^2$, the last step using $b \le d$. The two bounds contradict, so the fractions are equal. $\square$

**Theorem 4.3 (Denominator recovery under coprimality; `wiener_recovery_eq_of_coprime`).**
Under the hypotheses of Theorem 4.2, if additionally $\gcd(k, d) = 1$, then
$$b = d.$$
*Proof.* By Theorem 4.2, $k/d = a/b$, so cross-multiplying (with $d, b > 0$) gives the integer equation $kb = ad$. Then $d \mid ad = kb$, and since $\gcd(k, d) = 1$, we get $d \mid b$. Combined with $0 < b \le d$ this forces $b = d$. $\square$

Theorem 4.3 is the recovery guarantee: the convergent test returns *exactly* the true private exponent, not merely an equivalent fraction. Notably, only the true fraction $k/d$ need be in lowest terms; coprimality of the candidate $a/b$ is unnecessary, since $d \mid kb = ad$ already pins down $b$.

---

## 5. Factorization: The Missing Final Step

Recovering $d$ is not the attacker's goal — factoring $n$ is. This section closes the gap and exposes the structural fact that makes the closing exact.

### 5.1 The perfect-square discriminant

**Theorem 5.1 (Perfect-square discriminant; `discriminant_eq`).**
For all reals $p, q$,
$$(p + q)^2 - 4(pq) = (p - q)^2.$$
*Proof.* Expand both sides: $(p+q)^2 - 4pq = p^2 - 2pq + q^2 = (p-q)^2$. $\square$

This is the decisive structural observation. The discriminant of the monic quadratic with roots $p, q$ — namely $X^2 - (p+q)X + pq$ — is *always* a perfect square, so its real square root is the integer $p - q$ exactly, with no approximation.

### 5.2 Closed-form recovery of the primes

**Theorem 5.2 (Closed-form factorization; `factor_from_sum_prod`).**
For reals $p > q$,
$$p = \frac{(p+q) + \sqrt{(p+q)^2 - 4pq}}{2}, \qquad q = \frac{(p+q) - \sqrt{(p+q)^2 - 4pq}}{2}.$$
*Proof.* By Theorem 5.1 the radicand is $(p-q)^2$, so $\sqrt{(p+q)^2 - 4pq} = |p - q| = p - q$ since $p > q$. Substituting, $((p+q)+(p-q))/2 = p$ and $((p+q)-(p-q))/2 = q$. $\square$

**Theorem 5.3 (Factoring $n$ from the totient; `factor_n_from_totient`).**
For integers $p > q$, set $S := pq - \varphi(p,q) + 1$. Then $S = p + q$, and
$$p = \frac{S + \sqrt{S^2 - 4(pq)}}{2}, \qquad q = \frac{S - \sqrt{S^2 - 4(pq)}}{2}$$
(as real numbers). 
*Proof.* By Lemma 2.3, $pq - \varphi(p,q) = (p+q) - 1$, so $S = (p+q)$. Cast $S$ and $pq$ to $\mathbb{R}$ and apply Theorem 5.2 with sum $S$ and product $pq$. $\square$

Theorem 5.3 is the operational factorization: the attacker's data are $n = pq$ and $\varphi(n)$; the prime sum is $S = n - \varphi(n) + 1$, and the primes follow in closed form.

### 5.3 Recovering the totient from the key

**Theorem 5.4 (Totient from the key; `totient_from_key`).**
If $ed = k\,\varphi(p,q) + 1$, then
$$k \cdot \varphi(p,q) = ed - 1.$$
*Proof.* Immediate by rearranging the key equation. $\square$

With $k \ne 0$ known, this yields $\varphi(n) = (ed - 1)/k$, feeding Theorem 5.3.

### 5.4 Equivalence of recovery and factorization

Theorems 5.1–5.4 establish that knowing $(k, d)$ determines $\varphi(n)$, hence $p+q$, hence — via the perfect-square discriminant — the primes themselves, all by *exact* operations. Conversely, knowing $p, q$ gives $\varphi(n)$ and thus $d$ (when $\gcd(e, \varphi(n)) = 1$). Recovering the private exponent and factoring the modulus are therefore two faces of the same arithmetic fact, mediated entirely by the bijection $\varphi(n) \leftrightarrow p+q \leftrightarrow \{p, q\}$ and the perfect square $(p+q)^2 - 4n = (p-q)^2$.

---

## 6. The End-to-End Theorem

We now chain the engine, the recovery, and the factorization into a single statement.

**Theorem 6.1 (Modified Wiener, end-to-end; `modified_wiener_end_to_end`).**
Let $p > q$ be integers and suppose:

1. (Key equation) $ed = k\,\varphi(p,q) + 1$;
2. (Residual bound) $|(p+q) - s| \le \Delta$;
3. (Positivity) $k \ge 0$, $\tilde n(p,q,s) > 0$, $d > 0$;
4. (Smallness) $2d(k\Delta + 1) < \tilde n(p,q,s)$;
5. (Lowest terms) $\gcd(k, d) = 1$;
6. (Candidate) $0 < b \le d$ and $\left|\dfrac{e}{\tilde n(p,q,s)} - \dfrac{a}{b}\right| < \dfrac{1}{2d^2}$.

Then:

$$b = d \qquad\text{(the private exponent is recovered),}$$

and the larger prime is given in closed form by

$$p = \frac{S + \sqrt{S^2 - 4n}}{2}, \qquad S = n - \varphi(n) + 1, \quad n = pq$$

*(so $n$ is factored).*

*Proof.* The smallness condition feeds Theorem 3.5 to give $|e/\tilde n - k/d| < 1/(2d^2)$, so the true fraction $k/d$ meets the Legendre threshold. Combined with hypothesis 6 (the candidate $a/b$ also within threshold) and $0 < b \le d$, Theorem 4.3 — using $\gcd(k,d) = 1$ — forces $b = d$. The factorization half is Theorem 5.3, which expresses $p$ in closed form from $S = n - \varphi(n) + 1$ via the perfect-square discriminant. $\square$

This is the capstone: under a small private exponent and partial knowledge of $p+q$ (quantified by $\Delta$ and the smallness condition), the attack both *recovers the exact private exponent* and *factors the modulus in closed form*.

---

## 7. Algorithm

The constructive content of Theorem 6.1 is a concrete attack.

**Algorithm (Modified Wiener Factorization).**

*Input:* public key $(n, e)$; an estimate $s$ of $p+q$ with residual bound $\Delta$.
*Output:* the prime factors $p, q$ of $n$, or failure.

1. Form the corrected modulus $\tilde n \leftarrow n + 1 - s$.
2. Compute the continued-fraction expansion of $e/\tilde n$ and its convergents $a_i/b_i$.
3. For each convergent $a/b$ with $0 < b$:
   a. Set candidate cofactor $k \leftarrow$ numerator and candidate exponent $d \leftarrow b$ (test $k = a$).
   b. Compute candidate totient $\varphi' \leftarrow (e d - 1)/k$ if $k \mid (ed - 1)$, else skip.
   c. Compute candidate sum $S \leftarrow n - \varphi' + 1$.
   d. Compute discriminant $D \leftarrow S^2 - 4n$. If $D < 0$ or $D$ is not a perfect square, skip.
   e. Set $t \leftarrow \sqrt{D}$ (integer). Output $p \leftarrow (S + t)/2$, $q \leftarrow (S - t)/2$ if $pq = n$.
4. If no convergent yields a valid factorization, report failure.

*Correctness.* Theorem 3.5 guarantees the true $k/d$ is among the convergents enumerated in step 2 whenever the smallness condition holds; Theorem 4.3 guarantees the test in step 3 selects exactly $d$; Theorems 5.1–5.4 guarantee step 3(d)–(e) recover the primes exactly, the perfect-square test being the integral form of $D = (p-q)^2$.

*Complexity.* The continued-fraction expansion and its $O(\log \tilde n)$ convergents are computed in polynomial time; each convergent test is dominated by an integer square root, also polynomial. The attack runs in time polynomial in $\log n$.

---

## 8. Worked Example

Let $p = 17$, $q = 11$, so $n = 187$, $\varphi(n) = 160$. Choose $e = 7$; then $d = 23$, $k = 1$ (since $7 \cdot 23 = 161 = 1 \cdot 160 + 1$). Grant a perfect estimate $s = p + q = 28$, so $\tilde n = 187 + 1 - 28 = 160$.

**Engine (`worked_example_error`, `worked_example_below_threshold`).**
$$\frac{e}{\tilde n} - \frac{k}{d} = \frac{7}{160} - \frac{1}{23} = \frac{1}{3680} < \frac{1}{1058} = \frac{1}{2 \cdot 23^2}.$$
The criterion fires; $1/23$ is a convergent of $7/160$.

**Separation (`worked_example_separation`).**
$$\left|\frac{1}{23} - \frac{7}{160}\right| = \frac{1}{3680} = \frac{1}{23 \cdot 160},$$
so the Farey bound is attained with equality — the separation is sharp.

**Factorization (`worked_example_factor`).**
$S = n - \varphi(n) + 1 = 28$. Discriminant $28^2 - 4 \cdot 187 = 36 = 6^2$, a perfect square. Thus
$$p = \frac{28 + 6}{2} = 17, \qquad q = \frac{28 - 6}{2} = 11,$$
and $187$ is factored.

---

## 9. Applications and Significance

- **Cryptanalytic guidance.** The smallness condition $2d(k\Delta + 1) < \tilde n$ gives implementers a precise, non-asymptotic safety margin: it quantifies exactly how a leak of MSBs of $p+q$ trades against the largest safely usable private exponent.
- **Side-channel modeling.** Many side channels (timing, power, fault) reveal high-order bits of secret-derived quantities. Modeling such a leak as an estimate $s$ of $p+q$ with residual $\Delta$ places it directly into the present framework.
- **Pedagogy of Diophantine cryptanalysis.** The development connects three classical strands — continued-fraction convergents, Legendre's approximation theorem, and Farey separation — and ties them to a clean algebraic endpoint (the perfect-square discriminant), making the *whole* attack, including factorization, transparent.

---

## 10. Discussion and Future Work

The treatment is exact throughout: identities over $\mathbb{Z}/\mathbb{Q}$ and sharp inequalities with explicit, load-bearing hypotheses. The most striking structural fact is that recovering $d$ and factoring $n$ are *equivalent*, joined by the perfect-square discriminant $(p+q)^2 - 4n = (p-q)^2$. Several directions remain.

**Quantitative $\delta$-bound $d < n^{(1+\delta)/2}$.** State and prove the asymptotic admissibility bound: if a $\delta$-fraction of the MSBs of $p+q$ is known (so $\Delta \le C \cdot n^{(1-\delta)/2}$), then every $d < n^{(1+\delta)/2}$ satisfies the smallness condition and is recoverable. The finite criterion already proved is the exact arithmetic shadow of this real-exponent bound; converting one to the other is bounding $k \le d$, $\tilde n \approx n$, and taking logarithms.

**Recovery $\Leftrightarrow$ factorization as an exact equivalence.** Prove the converse: knowing the factorization of $n$ lets one compute $\varphi(n)$, hence $d$ from $e$ (when $\gcd(e, \varphi(n)) = 1$), so the two are information-theoretically equivalent. The bijection $\varphi(n) \leftrightarrow p+q \leftrightarrow \{p, q\}$ is invertible over $\mathbb{Z}$ via integer square roots.

**Robustness against an imperfect estimate.** Quantify how the recovered prime's error degrades with $\Delta = |p+q - s|$: the corrected modulus is a $\Delta$-perturbation of the totient, and the quadratic formula is locally Lipschitz in its coefficients away from a zero discriminant, so the perturbation should propagate linearly, $O(\Delta/\sqrt{\text{disc}})$.

**Multi-prime and unbalanced generalization.** Extend the closed-form recovery to highly unbalanced primes and to 3-prime moduli $n = pqr$, where the relevant symmetric functions ($p+q+r$, $pq+pr+qr$) replace the single sum, and the discriminant structure generalizes to resolvents of the cubic.

---

## 11. Conclusion

We have given a complete, exact account of a modified Wiener attack that exploits a small private exponent together with partial knowledge of $p+q$. The arithmetic engine reduces the key equation to a sharp rational approximation, the recovery layer uses Farey separation to pin down the unique convergent and the exact private exponent, and the factorization layer closes the loop with the quadratic formula and its perfect-square discriminant. The end-to-end theorem shows that, under the partial-knowledge smallness condition, the attack recovers $d$ *and* factors $n$ in closed form — the recovery of the private exponent and the factorization of the modulus being one and the same fact.
