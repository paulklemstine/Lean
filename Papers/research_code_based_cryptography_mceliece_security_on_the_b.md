# McEliece Security Through Hamming Geometry, Game Hopping, and Quadratic Search

**Aristotle**  
**July 25, 2026**

## Abstract

This paper isolates a rigorous, assumption-transparent chain of results for code-based public-key encryption. First, additive encryption is interpreted as translation in a Hamming space. Translation invariance identifies ciphertext-to-codeword distance with error weight, and minimum separation of $2t+1$ yields uniqueness of every encoded word within decoding radius $t$; injectivity of the encoder then gives message recovery. Second, an indistinguishability-under-chosen-plaintext-attack analysis is expressed as a two-hop argument. If replacement of a disguised Goppa-derived public key by a random linear-code key changes an adversary's success probability by at most $\varepsilon_{\mathrm{key}}$, and the random-code experiment differs from an ideal fair-bit experiment by at most $\varepsilon_{\mathrm{decode}}$, then real advantage is at most $\varepsilon_{\mathrm{key}}+\varepsilon_{\mathrm{decode}}$. Third, a general estimate $b^t\le\binom nt$ under $(b+1)t\le n+1$ proves that the weight-$119$ error layer in length $6960$ contains at least $2^{256}$ vectors. Hence, in the explicitly delimited quadratic-search model $q^2<N$, fewer than $2^{128}$ queries cannot cover this certified search space. These statements do not establish NP-hardness of distinguishing binary Goppa codes from random linear codes. Instead, they distinguish unconditional metric and combinatorial results from the computational assumptions required by the security reduction.

## 1. Introduction

The McEliece cryptosystem turns the theory of error-correcting codes into public-key encryption. A message is encoded as a codeword and then perturbed by a low-weight error. The secret key exposes enough algebraic structure to decode efficiently, while the public key is transformed to conceal that structure. Security is consequently governed by two broad computational problems: recognizing the hidden structured code and decoding noisy words without the secret description.

This architecture has long attracted attention as a candidate for security in the presence of quantum computation. Unlike integer factorization and discrete logarithms, general decoding problems are not known to admit polynomial-time quantum algorithms. Nevertheless, a mathematically careful account must avoid two common leaps. Worst-case NP-hardness of generic syndrome decoding is not automatically an average-case security proof for cryptographic instances. Likewise, it does not imply that a public key derived from a binary Goppa code is NP-hard to distinguish from a random linear code.

The purpose of this paper is therefore not to assert an unconditional complexity classification that the argument does not supply. It is to establish three exact layers that can be combined without conflation:

1. a metric correctness theorem for additive noisy encoding;
2. a quantitative two-hop security theorem with its assumptions displayed; and
3. a conservative combinatorial and quantum-search estimate for the parameter pair $(n,t)=(6960,119)$.

The first layer is independent of efficient decoding: it says that a bounded-radius answer, if found, is unique. The second is an elementary but essential game-hopping calculation: the distance from the real game to the ideal game is no larger than the sum of the two intermediate distances. The third gives a reusable binomial lower bound and translates a certified $2^{256}$ error space into a $2^{128}$ floor under a quadratic-search premise.

The contribution is thus an explicit bridge among coding geometry, real-valued security advantages, and combinatorial search spaces. Its main methodological feature is scope control. Unconditional statements are proved unconditionally; computational conclusions are stated conditionally and quantitatively.

## 2. Algebraic and metric setting

### 2.1 Words, weight, and distance

Let $K$ be a finite field and let $K^n$ denote the set of length-$n$ words. For $x,y\in K^n$, the **Hamming distance** is

$$
d_H(x,y)=\bigl|\{i\in\{1,\ldots,n\}:x_i\ne y_i\}\bigr|.
$$

The **Hamming weight** of $e\in K^n$ is

$$
\operatorname{wt}(e)=\bigl|\{i\in\{1,\ldots,n\}:e_i\ne0\}\bigr|.
$$

Thus $\operatorname{wt}(e)=d_H(e,0)$. Hamming distance is a metric, so it is symmetric, vanishes exactly on equal words, and satisfies the triangle inequality

$$
d_H(x,z)\le d_H(x,y)+d_H(y,z).
$$

It is also translation invariant.

**Lemma 2.1 (Translation invariance).** For all $x,y,a\in K^n$,

$$
d_H(x+a,y+a)=d_H(x,y).
$$

**Proof sketch.** At coordinate $i$, the equality $x_i+a_i=y_i+a_i$ holds if and only if $x_i=y_i$, because addition by $a_i$ is a bijection of the field. The sets of differing coordinates are therefore identical. $\square$

Taking $x=e$, $y=0$, and $a=E(m)$ gives the identity central to encryption correctness.

### 2.2 Encoders and separated images

Let $\mathcal M$ be a message set and let

$$
E:\mathcal M\longrightarrow K^n
$$

be an encoder. No linearity assumption is required for the metric theorems below. We say that the encoded image has minimum separation at least $2t+1$ if, whenever $E(m_1)\ne E(m_2)$,

$$
d_H(E(m_1),E(m_2))\ge2t+1.
$$

For a center $x\in K^n$, define the closed Hamming ball of radius $t$ by

$$
B_t(x)=\{y\in K^n:d_H(x,y)\le t\}.
$$

**Lemma 2.2 (Disjoint decoding balls).** If $d_H(x,y)\ge2t+1$, then $B_t(x)\cap B_t(y)=\varnothing$.

**Proof sketch.** If $z$ belonged to both balls, then the triangle inequality would give

$$
d_H(x,y)\le d_H(x,z)+d_H(z,y)\le2t,
$$

contradicting $d_H(x,y)\ge2t+1$. $\square$

The integer offset $+1$ is essential: since distances are integral, it is exactly the condition that excludes distance at most $2t$.

### 2.3 Additive noisy encryption

Define additive encryption by

$$
\operatorname{Enc}_E(m;e)=E(m)+e,
$$

where $e\in K^n$ is an error vector. In a cryptosystem, $e$ is sampled from a prescribed low-weight distribution; for correctness, only its weight bound matters.

**Proposition 2.3 (Encryption distance identity).** For every message $m$ and error vector $e$,

$$
d_H(\operatorname{Enc}_E(m;e),E(m))=\operatorname{wt}(e).
$$

**Proof sketch.** Translation invariance yields

$$
d_H(E(m)+e,E(m))=d_H(e,0)=\operatorname{wt}(e).
$$

$\square$

## 3. Correctness from Hamming-ball packing

The preceding identity places the ciphertext inside a known geometric neighborhood of the transmitted codeword. Minimum separation then rules out every other encoded word.

**Theorem 3.1 (Unique encoded word under bounded noise).** Let $E:\mathcal M\to K^n$ have minimum separation at least $2t+1$. Let

$$
c=\operatorname{Enc}_E(m;e)=E(m)+e
$$

with $\operatorname{wt}(e)\le t$. If a message $m'$ satisfies

$$
d_H(c,E(m'))\le t,
$$

then

$$
E(m')=E(m).
$$

**Proof sketch.** Proposition 2.3 gives $d_H(c,E(m))\le t$, so $c\in B_t(E(m))$. The hypothesis on $m'$ gives $c\in B_t(E(m'))$. If the two encoded words were distinct, their distance would be at least $2t+1$, and Lemma 2.2 would say their radius-$t$ balls are disjoint. This contradicts the membership of $c$ in both balls. Hence the encoded words coincide. $\square$

This theorem proves uniqueness at the level of codewords. To infer equality of messages, collisions of the encoder must be excluded.

**Corollary 3.2 (Message recovery).** Under the hypotheses of Theorem 3.1, suppose additionally that $E$ is injective. Then every $m'$ satisfying $d_H(c,E(m'))\le t$ obeys

$$
m'=m.
$$

**Proof sketch.** Theorem 3.1 gives $E(m')=E(m)$, and injectivity gives $m'=m$. $\square$

### 3.1 Interpretation and limitation

The theorem is a uniqueness result, not an algorithmic construction. It guarantees that a bounded-distance decoder cannot return a wrong nearby codeword. It does not, by itself, produce an efficient function that finds the nearby word. In McEliece encryption, the secret Goppa structure is what enables efficient decoding. The theorem separates that algorithmic role from the metric fact that the answer is unique.

The proof also applies beyond binary codes. It uses only coordinatewise addition over a field and Hamming geometry. Binary Goppa codes are a principal cryptographic instance, but the correctness mechanism belongs to a broader family of noisy-codeword encryption schemes.

## 4. Security experiments and advantage

### 4.1 The chosen-plaintext challenge

In an indistinguishability-under-chosen-plaintext-attack experiment, an adversary supplies two messages and receives an encryption of one selected by a hidden uniform bit. It outputs a guess for that bit. If its success probability in an experiment is $p$, define its distinguishing advantage by

$$
\operatorname{Adv}(p)=\left|p-\frac12\right|.
$$

This normalization assigns zero advantage to fair guessing. The results below concern the success probabilities of a fixed adversarial procedure across related experiments. A full asymptotic treatment would additionally quantify over adversary families, running times, key generation, encryption randomness, and security parameters.

### 4.2 Three games

Consider three conceptual experiments:

- **Real game.** The public key is derived from a disguised structured code, such as a binary Goppa code. Let success probability be $p_{\mathrm{real}}$.
- **Random-code game.** The structured public key is replaced by a key sampled from a suitable random linear-code distribution. Let success probability be $p_{\mathrm{rand}}$.
- **Ideal game.** The challenge bit is information-theoretically hidden, so success probability is $1/2$.

The first transition asks whether the public key distribution reveals its structured origin. Assume the quantitative bound

$$
|p_{\mathrm{real}}-p_{\mathrm{rand}}|\le\varepsilon_{\mathrm{key}}.
$$

The second asks whether ciphertexts in the random-code setting hide the selected message. Assume

$$
\left|p_{\mathrm{rand}}-\frac12\right|\le\varepsilon_{\mathrm{decode}}.
$$

The symbols $\varepsilon_{\mathrm{key}}$ and $\varepsilon_{\mathrm{decode}}$ may depend on a security parameter and adversarial resources. The following theorem is pointwise and remains valid for each such choice.

**Theorem 4.1 (Two-hop IND-CPA reduction).** If

$$
|p_{\mathrm{real}}-p_{\mathrm{rand}}|\le\varepsilon_{\mathrm{key}}
$$

and

$$
\left|p_{\mathrm{rand}}-\frac12\right|\le\varepsilon_{\mathrm{decode}},
$$

then

$$
\operatorname{Adv}(p_{\mathrm{real}})
\le\varepsilon_{\mathrm{key}}+\varepsilon_{\mathrm{decode}}.
$$

**Proof sketch.** Insert and subtract $p_{\mathrm{rand}}$:

$$
p_{\mathrm{real}}-\frac12
=(p_{\mathrm{real}}-p_{\mathrm{rand}})
+\left(p_{\mathrm{rand}}-\frac12\right).
$$

Taking absolute values and applying the triangle inequality gives

$$
\left|p_{\mathrm{real}}-\frac12\right|
\le |p_{\mathrm{real}}-p_{\mathrm{rand}}|
+\left|p_{\mathrm{rand}}-\frac12\right|.
$$

Substitution of the two hypotheses completes the bound. $\square$

**Corollary 4.2 (Perfect random-code hiding).** If

$$
|p_{\mathrm{real}}-p_{\mathrm{rand}}|\le\varepsilon_{\mathrm{key}}
$$

and $p_{\mathrm{rand}}=1/2$, then

$$
\operatorname{Adv}(p_{\mathrm{real}})\le\varepsilon_{\mathrm{key}}.
$$

**Proof sketch.** Set $\varepsilon_{\mathrm{decode}}=0$ in Theorem 4.1, or directly substitute $p_{\mathrm{rand}}=1/2$ into the key-replacement inequality. $\square$

### 4.3 Why the two terms must remain separate

The theorem does not identify $\varepsilon_{\mathrm{key}}$ with decoding hardness. The key term concerns distinguishability of distributions over public descriptions. The decoding term concerns message hiding after the structured distribution has already been replaced. An algorithm might exploit visible key structure without decoding, or decode better than expected without first classifying the key. Treating the two transitions separately prevents one assumption from silently standing in for the other.

The theorem also makes no unconditional claim that either error term is negligible. Such a claim requires explicit computational assumptions or reductions. What is unconditional is the composition law: once the two transition bounds are established, their sum bounds real advantage.

## 5. A reusable lower bound for constant-weight error spaces

For binary errors of exact weight $t$ in length $n$, the search-space cardinality is

$$
N(n,t)=\binom nt.
$$

We next establish a convenient exponential lower bound. It is weaker than entropy estimates but requires only integer arithmetic and is well suited to conservative certification.

**Theorem 5.1 (Exponential binomial lower bound).** Let $b,t,n$ be nonnegative integers. If

$$
(b+1)t\le n+1,
$$

then

$$
b^t\le\binom nt.
$$

**Proof sketch.** The argument proceeds by induction on $t$. For $t=0$, both sides equal $1$. For the inductive step, use the ratio identity

$$
\binom n{t+1}=\binom nt\frac{n-t}{t+1},
$$

or its denominator-free equivalent

$$
(t+1)\binom n{t+1}=(n-t)\binom nt.
$$

The condition $(b+1)(t+1)\le n+1$ implies

$$
b(t+1)\le n-t.
$$

It also implies the corresponding condition needed to invoke the inductive hypothesis for $t$. Thus $\binom nt\ge b^t$, and multiplication by the displayed factor gives

$$
\binom n{t+1}
=\binom nt\frac{n-t}{t+1}
\ge b^t\,b=b^{t+1}.
$$

All quantities are nonnegative integers, so the denominator-free identity gives the same conclusion without division concerns. $\square$

### 5.1 Application to length $6960$ and weight $119$

Set $b=5$, $t=119$, and $n=6960$. The theorem's premise holds because

$$
(5+1)\cdot119=714\le6961.
$$

Therefore,

$$
5^{119}\le\binom{6960}{119}.
$$

A direct comparison of integer powers gives

$$
2^{256}\le5^{119}.
$$

For intuition, taking base-$2$ logarithms yields $119\log_2 5\approx276.31$, already comfortably above $256$.

**Corollary 5.2 (Certified error-space size).** The number of binary length-$6960$ errors of weight exactly $119$ satisfies

$$
2^{256}\le\binom{6960}{119}.
$$

**Proof sketch.** Chain the inequalities $2^{256}\le5^{119}$ and $5^{119}\le\binom{6960}{119}$. $\square$

The exact value is much larger than the certified threshold. Direct arbitrary-precision evaluation shows

$$
\left\lfloor\log_2\binom{6960}{119}\right\rfloor=863.
$$

This numerical observation is useful for scale, while Corollary 5.2 is the conservative result needed below.

## 6. A qualified quantum-search floor

### 6.1 Abstract quadratic-search model

Suppose a search process using $q$ queries can cover no more than a quantity quadratic in $q$. The exact lower-bound condition is expressed as

$$
q^2<N,
$$

where $N$ is the candidate-space size. This abstraction reflects the square-root relationship associated with unstructured quantum search, but it is intentionally not a model of every possible quantum code attack.

**Theorem 6.1 (Quadratic-search exponent halving).** Let $N$ and $q$ be nonnegative integers. If

$$
2^{256}\le N
$$

and

$$
q<2^{128},
$$

then

$$
q^2<N.
$$

**Proof sketch.** Since multiplication is strictly monotone on positive natural numbers,

$$
q^2<(2^{128})^2=2^{256}.
$$

Combining this strict inequality with $2^{256}\le N$ gives $q^2<N$. $\square$

**Corollary 6.2 (Weight-$119$ quadratic-search floor).** If $q<2^{128}$, then

$$
q^2<\binom{6960}{119}.
$$

**Proof sketch.** Apply Theorem 6.1 with $N=\binom{6960}{119}$ and use Corollary 5.2. $\square$

### 6.2 Scope of the conclusion

Corollary 6.2 is a conditional statement about a specified cost model. It does not prove that every quantum cryptanalytic algorithm is an unstructured search. Attacks on code-based systems may exploit parity-check structure, information sets, collision techniques, amplitude amplification around nontrivial subroutines, time-memory tradeoffs, or weaknesses in parameter and implementation choices. A complete concrete-security estimate must analyze the best relevant attack algorithms and their resource costs.

The corollary nevertheless provides a rigorous baseline. Any attack genuinely constrained by $q^2<N$ cannot span the certified error layer below $2^{128}$ queries. The qualification protects the result from overinterpretation while retaining its exact mathematical content.

## 7. Algorithms and reproducible calculations

### 7.1 Bounded-distance candidate verification

Given an encoder, a ciphertext $c$, a radius $t$, and a candidate message $m'$, compute $E(m')$, count differing coordinates, and accept exactly when the distance is at most $t$. If the hypotheses of Theorem 3.1 hold, no two distinct encoded words can pass this test for the same ciphertext. The procedure costs $O(n)$ field comparisons after encoding. It verifies a candidate but does not solve the potentially hard task of finding one.

### 7.2 Security-hop accounting

Given empirical or analytic bounds $\varepsilon_{\mathrm{key}}$ and $\varepsilon_{\mathrm{decode}}$, report their sum as an upper bound on real distinguishing advantage. The calculation is constant time. Its substantive inputs are the proofs or measurements establishing the hop bounds, not the addition itself.

### 7.3 Error-space certification

For parameters $n,t$, one may compute $\binom nt$ exactly using the multiplicative recurrence

$$
C_0=1,
\qquad
C_k=C_{k-1}\frac{n-k+1}{k}
$$

for $1\le k\le t$. Each division is exact. With arbitrary-precision arithmetic this uses $O(t)$ large-integer operations and avoids factorials. Separately, one can search for a small base $b$ satisfying $(b+1)t\le n+1$ and compare $b^t$ against a desired power-of-two threshold. The latter gives a concise certificate even when the exact coefficient is enormous.

## 8. Cryptographic interpretation

The mathematical chain can be read as three interfaces.

The **correctness interface** accepts a separation parameter and a noise bound. It outputs uniqueness of the decoded codeword, and with injectivity, uniqueness of the message. This interface is unconditional and geometric.

The **security interface** accepts two quantitative game-transition bounds. It outputs an IND-CPA advantage bound equal to their sum. This interface is unconditional as a composition theorem, but its cryptographic strength is conditional on the supplied bounds.

The **post-quantum baseline interface** accepts a certified candidate-space lower bound and the quadratic-search premise. It outputs a query floor. The binomial estimate is unconditional; the interpretation as an attack lower bound is limited to the declared model.

Together these interfaces describe a defensible way to reason about McEliece encryption without turning related complexity results into unsupported security claims.

## 9. The NP-hardness boundary

The assertion that distinguishing binary Goppa codes from random linear codes is NP-hard is not established by the results in this paper. It should not be inferred from worst-case NP-completeness of generic syndrome decoding.

Several logical gaps separate those claims. First, a distinguishing problem and a decoding problem have different outputs. Second, worst-case hardness does not imply hardness on the key and ciphertext distributions generated by a cryptosystem. Third, an NP-hardness reduction must preserve the relevant parameters and run in polynomial time. Fourth, even a hardness result for one task would need an explicit reduction to IND-CPA advantage, including runtime and advantage loss.

For these reasons, Theorem 4.1 exposes rather than conceals its premises. A future complete reduction should define probabilistic key generation and encryption, define classes of classical or quantum adversaries, state code-indistinguishability and random-decoding assumptions with security parameters, and transform any successful IND-CPA adversary into a distinguisher or decoder with explicit costs.

## 10. Applications

The correctness theorem applies to any cryptographic or communication system that adds bounded Hamming noise to separated codewords. It can serve as a modular specification for decoder correctness: an implementation need only establish that its output lies within radius $t$, after which uniqueness follows from code separation.

The game-hop theorem applies well beyond McEliece. Hybrid arguments throughout cryptography replace one distribution or primitive at a time. Whenever success probabilities are real numbers, a chain of transitions yields a sum of absolute differences. For multiple games $p_0,p_1,\ldots,p_k$, repeated use of the triangle inequality gives

$$
|p_0-p_k|\le\sum_{i=0}^{k-1}|p_i-p_{i+1}|.
$$

The binomial estimate applies to constant-weight sampling, combinatorial designs, sparse recovery, and brute-force baselines. It offers a simple certificate when a full entropy calculation is unnecessary.

## 11. Discussion

The strongest feature of the development is not a single large inequality but the alignment of assumptions with conclusions. Correctness needs no hardness assumption. Security composition needs no coding theorem beyond the numerical hop bounds. The search-space estimate needs no cryptographic assumption. Only when the pieces are interpreted as resistance to particular attacks do computational premises enter.

The estimate $\binom{6960}{119}\ge2^{256}$ is intentionally loose. Exact counting gives substantially more than $256$ bits of raw combinatorial entropy, but raw entropy is not equivalent to cryptographic security. Conservative thresholds are useful when they are paired with explicit attack models; exact counts are useful for comparison and parameter exploration.

Likewise, the two-hop theorem does not claim that random-code hiding is perfect. Corollary 4.2 merely records what follows if it is perfect. In realistic analyses, both terms are nonzero functions of parameters and resources.

## 12. Future work

A complete probabilistic treatment should define key generation, encryption randomness, and adversarial coins as finite distributions, then state IND-CPA as an experiment over probabilistic algorithms. The game transitions could be justified through couplings, statistical distance, or explicit computational reductions.

On the coding side, one should define binary Goppa codes from supports in finite extension fields and square-free Goppa polynomials, prove the relevant minimum-distance bounds, and construct an actual bounded-distance decoder whose output satisfies the geometric hypotheses of Theorem 3.1.

On the complexity side, Goppa-code indistinguishability and random syndrome-decoding assumptions should be parameterized by adversarial runtime. A reduction should transform an IND-CPA adversary into a key distinguisher or decoder and track both runtime overhead and advantage loss.

For quantum analysis, the abstract condition $q^2<N$ should be replaced by a precise quantum query model with a proved lower bound for unstructured search. Structured quantum algorithms should be analyzed separately. Finally, complexity claims concerning syndrome decoding should clearly distinguish worst-case NP-completeness, parameter-preserving reductions, average-case assumptions, and the public-key distributions actually used by McEliece encryption.

## 13. Conclusion

Additive noisy encoding, game hopping, and constant-weight counting provide three clean mathematical foundations for McEliece analysis. Translation invariance and disjoint Hamming balls prove unique recovery under errors of weight at most $t$ when encoded words are separated by $2t+1$. The real triangle inequality proves that key-distribution replacement and random-code message hiding contribute additively to IND-CPA advantage. A general binomial estimate certifies at least $2^{256}$ weight-$119$ errors in length $6960$, which yields a $2^{128}$ floor in the stated quadratic-search model.

The results are useful precisely because their scope is explicit. They support a rigorous conditional security narrative while declining to claim an unproved NP-hardness theorem for Goppa-code distinguishing. This separation of geometry, assumptions, and attack models is the appropriate basis for further analysis of code-based cryptography.
