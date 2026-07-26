# McEliece Security Through Geometry, Game Hops, and Combinatorics

## The shape of a secret hidden in noise

Public-key cryptography usually begins with an operation that is easy to perform and difficult to reverse. In the McEliece cryptosystem, that operation is built from an error-correcting code. A sender turns a message into a long binary word, deliberately flips a small number of its coordinates, and publishes the noisy result. The legitimate receiver possesses hidden algebraic structure that makes correction efficient. An outsider sees what is intended to resemble a generic decoding problem.

This idea is especially compelling in the search for post-quantum cryptography. Quantum computers dramatically weaken familiar number-theoretic systems, but no comparably devastating general quantum method is known for decoding random-looking linear codes. Still, careful security analysis must separate what is proved from what is assumed. Three parts of the McEliece story can be stated with complete mathematical precision:

1. bounded noise is correctable because separated codewords have disjoint Hamming balls;
2. two changes of security experiment produce an additive bound on distinguishing advantage; and
3. for the parameter pair of length $6960$ and error weight $119$, the number of possible errors exceeds $2^{256}$, giving a $2^{128}$ floor in an explicitly quadratic search model.

These results form a bridge from geometry to probability to combinatorics. They do not prove that binary Goppa codes are NP-hard to distinguish from random linear codes. That claim is neither needed nor smuggled into the argument. Instead, code indistinguishability and random-code message hiding appear openly as quantitative assumptions.

## A cube with an enormous number of corners

A binary word of length $n$ is a point of the Hamming cube $\{0,1\}^n$. The Hamming distance $d_H(x,y)$ counts the coordinates at which $x$ and $y$ differ. The Hamming weight $\operatorname{wt}(e)$ counts the nonzero coordinates of $e$, so it is simply the distance from $e$ to the all-zero word.

Let $E$ encode messages as words of length $n$. McEliece encryption has the simple additive form

$$
c=E(m)+e,
$$

where addition is coordinatewise over a finite field and $e$ is a randomly selected error. Translation does not alter Hamming geometry. Consequently,

$$
d_H(c,E(m))=d_H(E(m)+e,E(m))=\operatorname{wt}(e).
$$

This identity is the entire geometric heart of correctness. The ciphertext lies exactly as far from the transmitted codeword as the error is heavy.

Imagine placing a ball of radius $t$ around every valid codeword. If any two distinct encoded words are at distance at least $2t+1$, these balls cannot overlap. Indeed, a point lying within distance $t$ of two different codewords would put those codewords at distance at most $2t$ by the triangle inequality, contradicting their separation.

This gives the **Noisy-Encoding Uniqueness Theorem**. Let $E$ be an encoder whose distinct outputs satisfy

$$
d_H(E(m_1),E(m_2))\ge 2t+1.
$$

If $c=E(m)+e$ with $\operatorname{wt}(e)\le t$, and if some encoded word $E(m')$ satisfies $d_H(c,E(m'))\le t$, then

$$
E(m')=E(m).
$$

If the encoder is injective, the stronger conclusion $m'=m$ follows. Thus a bounded-distance decoder, whenever it returns a codeword within radius $t$, cannot return the wrong message.

The result is universal: it depends only on Hamming distance, not on the private algebra used to find the nearby word. The hidden Goppa structure concerns efficient decoding; the impossibility of two answers is pure metric geometry.

## Security as a journey through neighboring worlds

Correct decryption is not the same as secrecy. To discuss chosen-plaintext security, imagine an adversary challenged to identify which of two messages was encrypted. Let $p_{\mathrm{real}}$ be its probability of guessing correctly in the real system. Its advantage over a fair coin is

$$
\operatorname{Adv}_{\mathrm{IND}}=\left|p_{\mathrm{real}}-\frac12\right|.
$$

A standard security argument does not leap directly from the real world to a perfect one. It moves through a neighboring experiment. Replace the disguised Goppa public key by a random linear-code key, and call the adversary's success probability $p_{\mathrm{rand}}$.

Suppose the key replacement changes success probability by at most $\varepsilon_{\mathrm{key}}$:

$$
|p_{\mathrm{real}}-p_{\mathrm{rand}}|\le \varepsilon_{\mathrm{key}}.
$$

Suppose also that in the random-code experiment the encrypted message is hidden up to $\varepsilon_{\mathrm{decode}}$:

$$
\left|p_{\mathrm{rand}}-\frac12\right|\le \varepsilon_{\mathrm{decode}}.
$$

The real-line triangle inequality then yields the **Two-Hop IND-CPA Bound**:

$$
\left|p_{\mathrm{real}}-\frac12\right|
\le
\varepsilon_{\mathrm{key}}+\varepsilon_{\mathrm{decode}}.
$$

The proof is just the decomposition

$$
p_{\mathrm{real}}-\frac12
=(p_{\mathrm{real}}-p_{\mathrm{rand}})
+(p_{\mathrm{rand}}-\tfrac12).
$$

This modest-looking inequality encodes an important discipline. One term measures whether public keys reveal their structured origin. The other measures whether decoding or message recovery remains hard after structure has been replaced by randomness. These are different cryptographic questions, and the bound refuses to blur them together.

In the special case of perfect random-code hiding, $p_{\mathrm{rand}}=1/2$, so the second term vanishes and

$$
\operatorname{Adv}_{\mathrm{IND}}\le \varepsilon_{\mathrm{key}}.
$$

The reduction is conditional, as cryptographic reductions normally are. It says exactly how strong the final guarantee is if the two intermediate bounds hold.

## Counting the storm of possible errors

For a binary word of length $n$, exactly $\binom nt$ errors have weight $t$. At the parameter pair $n=6960$ and $t=119$, this number is immense. A reusable combinatorial estimate makes that scale transparent.

The **Exponential Binomial Lower Bound** says that for natural numbers $b,t,n$, if

$$
(b+1)t\le n+1,
$$

then

$$
b^t\le \binom nt.
$$

One way to understand the estimate is through the recurrence relating neighboring binomial coefficients. The available coordinate range is large enough that each additional selected position supplies an effective multiplicative factor of at least $b$. Induction on $t$ turns those factors into $b^t$.

Choose $b=5$. The condition becomes

$$
6\cdot119\le6961,
$$

which is easily satisfied. Therefore

$$
5^{119}\le\binom{6960}{119}.
$$

A direct integer comparison also gives

$$
2^{256}\le5^{119}.
$$

Combining the two proves the **Error-Space Bound**:

$$
2^{256}\le\binom{6960}{119}.
$$

The exact binomial coefficient is far larger still: it has $864$ binary digits, or approximately $2^{863.98}$. The certified $2^{256}$ inequality is deliberately conservative. It is sufficient for the next conclusion without pretending that raw counting alone captures the best known attacks.

## What a quadratic quantum speedup does—and does not—say

Unstructured quantum search can turn a search over $N$ possibilities into a task on the order of $\sqrt N$ queries. A clean abstract model captures this by saying that $q$ queries cannot cover a space of size $N$ when

$$
q^2<N.
$$

If $N\ge2^{256}$ and $q<2^{128}$, then

$$
q^2<2^{256}\le N.
$$

Applied to the weight-$119$ error space, this proves the **Quadratic-Search Floor**:

$$
q<2^{128}
\quad\Longrightarrow\quad
q^2<\binom{6960}{119}.
$$

The qualification matters. This is not a theorem that every quantum attack must inspect errors one by one, nor is it a complete security estimate for a deployed cryptosystem. Code-based cryptanalysis exploits structure, information-set techniques, memory tradeoffs, and many other ideas. The result says something narrower and exact: in a model where the attack's reach after $q$ queries is bounded quadratically by $q^2$, fewer than $2^{128}$ queries do not span even the conservatively certified error space.

That distinction is a strength rather than a weakness. Post-quantum claims should identify their model, quantify their premise, and resist turning a useful lower bound into a universal slogan.

## The missing NP-hardness shortcut

It is tempting to reason as follows: generic syndrome decoding is NP-hard, McEliece uses decoding, therefore distinguishing McEliece keys or breaking average-case encryption must also be NP-hard. The conclusion does not follow. Worst-case hardness of a generic decoding problem does not automatically establish average-case hardness for the cryptographic distribution. Nor does it prove that a structured binary Goppa public key is hard to distinguish from a random linear code.

Accordingly, the central security theorem is stated with two explicit premises: a bound for replacing the Goppa-derived key and a bound for hiding the message in the random-code game. Establishing those premises for concrete adversary classes is a separate research program. Honesty about this boundary keeps the proved chain useful: every link says precisely what it contributes.

## One architecture, three kinds of reasoning

The full picture is now visible. Geometry says bounded errors cannot create ambiguous nearby codewords. Probability says the cost of two game transitions adds. Combinatorics says the relevant error layer is enormous, while the quadratic model translates an exponent of $256$ into a query floor of $128$ bits.

These arguments illuminate why McEliece remains a central post-quantum design. Its correctness is rooted in a rigid packing law. Its security analysis naturally separates public-key disguise from decoding hardness. Its parameter sizes create vast combinatorial spaces even after allowing a quadratic search advantage.

There is also a practical lesson in this layered view. Parameters should not be judged by a single number detached from its origin. A decoding radius belongs to the geometry of the code; a distinguishing advantage belongs to a specified experiment; and a query exponent belongs to a model of attack. Keeping those quantities attached to their definitions makes comparisons meaningful and exposes exactly where new cryptanalysis can improve understanding.

Just as importantly, the mathematics teaches restraint. A secure design is not certified by one dramatic complexity label. It is understood by assembling local statements—geometric, probabilistic, and computational—whose assumptions and conclusions align. In McEliece cryptography, the noise that looks like disorder is carefully bounded, the hidden structure that enables correction must remain inconspicuous, and the immense cube of possible errors supplies the scale on which attacks must operate.
