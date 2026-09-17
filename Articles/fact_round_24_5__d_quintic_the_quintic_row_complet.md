# The Prime Whisperer: How a Polynomial Leaks Exactly One Bit

## A guessing game played with primes

Here is a game. I hand you a quintic polynomial — say

$$f(x) = x^5 + 20x + 32,$$

and a large prime $p$, say $p = 1{,}000{,}003$. You reduce $f$ modulo $p$ and factor it. Sometimes it splits into five linear factors. Sometimes it stays irreducible. Sometimes it breaks into a linear factor times two quadratics. Those three outcomes — and, for this particular polynomial, *only* those three — are the entire menu.

Now the game: from the factorization shape alone, can you guess something about $p$ itself?

The surprising answer is yes, and the amount you learn is not approximately, not asymptotically, but *exactly* one bit. Not $0.97$ bits, not "about a bit". One. And if instead you ask how many bits of the shape are wasted — how much of the randomness in the factorization pattern is invisible to any question you could ask about $p$ — the answer is also exact:

$$\tfrac{1}{2}\log_2 5 - \tfrac{4}{5} = 0.36096\ldots \text{ bits.}$$

This article is about why those numbers are exact, and about a law that produces them for every quintic polynomial there is.

## Frobenius, or: primes have personalities

The bridge between "how does $f$ factor mod $p$" and "what kind of number is $p$" is one of the great structural facts of number theory. Attached to an irreducible polynomial $f$ of degree $n$ is its **Galois group** $G$, the group of symmetries of its roots: a subgroup of the permutation group $S_n$ that acts transitively on the $n$ roots. For each prime $p$ that does not divide the discriminant of $f$, there is a canonical conjugacy class in $G$, the **Frobenius class of $p$**, and the miracle is this:

> **The factorization of $f$ modulo $p$ has cycle type equal to the cycle type of the Frobenius class of $p$.**

If Frobenius is a 5-cycle, $f$ stays irreducible mod $p$. If Frobenius is the identity, $f$ splits into five linear factors. If Frobenius is a product of two transpositions, $f$ factors as (linear)(quadratic)(quadratic). Factoring polynomials mod $p$ is a *measuring device* pointed at a group.

And that device is well calibrated. The **Chebotarev density theorem** says the Frobenius classes equidistribute: a random prime behaves like a uniformly random element of $G$. So the long-run frequency of each factorization shape is the fraction of $G$ occupied by the corresponding conjugacy classes. The histogram of factorization shapes over many primes *is* a readout of the group.

For $f(x) = x^5 + 20x + 32$, the group is the dihedral group $D_5$ of order 10 — the symmetries of a regular pentagon. It has one identity, four nontrivial rotations, and five reflections. So the prediction is:

| shape | group elements | frequency |
|---|---|---|
| $[1^5]$ (five linear factors) | identity | $1/10$ |
| $[5]$ (irreducible) | four rotations | $4/10$ |
| $[1,2,2]$ | five reflections | $5/10$ |

No other shape ever occurs — never a cubic factor, never a quartic. And that is exactly what a scan of primes finds, to within a fraction of a percent.

## The other observable: what $p$ looks like modulo something

The second half of the game is a question about $p$ as a number. Certain quadratic questions about $p$ — "is $p$ a sum of the form $a^2 + 5b^2$?", equivalently "does $-5$ have a square root mod $p$?" — depend only on $p$ modulo a fixed number, here $20$. Concretely, $-5$ is a square mod $p$ exactly when

$$p \equiv 1, 3, 7, 9 \pmod{20},$$

and not when $p \equiv 11, 13, 17, 19 \pmod{20}$. Call this the **residue dial**: a coin flip determined by $p$'s residue class.

The connection to the group side is the **abelianization**. Inside $G$ sits the commutator subgroup $[G,G]$, and the quotient $A = G/[G,G]$ is the largest abelian group that $G$ maps onto. Class field theory says: the image of the Frobenius class in $A$ is a function of $p$ modulo a fixed conductor. Abelian quotients of Galois groups are exactly the part of the arithmetic that congruences can see.

For $D_5$, the commutator subgroup is the rotation subgroup. This is a pleasantly hands-on fact: with $r$ a rotation by one fifth of a turn and $s$ any reflection, every rotation is a *single* commutator,

$$r^k = s^{-1} r^{-2k} s\, r^{2k} = [\,s,\, r^{2k}\,],$$

because conjugating a rotation by a reflection inverts it, and $2$ is invertible modulo $5$. So $[D_5, D_5]$ is the full group of rotations and

$$D_5^{\mathrm{ab}} \cong C_2 : \quad \text{rotation} \mapsto 0, \qquad \text{reflection} \mapsto 1.$$

There is a subtlety worth savouring. For a generic quintic, the natural $C_2$ is the *sign* character, detected by whether the discriminant is a square mod $p$. But $D_5$ sits inside the alternating group $A_5$: every element is even, the discriminant of $x^5+20x+32$ is a perfect square, and the sign character is trivial. The quadratic character of a $D_5$ quintic is therefore hiding somewhere else — in the **quadratic resolvent field**, the unique quadratic field inside the splitting field. Ramification pins it down: it must be $\mathbb{Q}(\sqrt{d})$ for a squarefree $d$ built from the primes dividing the discriminant of $f$. For $x^5+20x+32$ the candidate search returns a unique match, and it matches perfectly: the field is $\mathbb{Q}(\sqrt{-5})$, of conductor $20$. Comparing the two observables over thousands of primes gives agreement $1.0000$ — not "high correlation", but every single prime, every time.

## Counting the bits

Now we have two observables attached to each prime: its **type** $T$ (the factorization shape) and its **coset** $C$ (the image of Frobenius in the abelian quotient, equivalently the residue dial). Chebotarev tells us their joint distribution: it is the joint distribution of these two functions evaluated at a uniformly random element of $G$.

That makes it a finite probability table, and finite probability tables have entropies. Write $H(T)$ for the Shannon entropy of the shape in bits, $H(C)$ for that of the coset, and $I(T;C) = H(T)+H(C)-H(T,C)$ for their mutual information: the number of bits that watching one observable tells you about the other.

For $D_5$ the shape distribution is $(1/10,\, 4/10,\, 5/10)$, so

$$H(T) = \tfrac{1}{10}\log_2 10 + \tfrac{4}{10}\log_2\tfrac{10}{4} + \tfrac{1}{2}\log_2 2 = \tfrac{1}{5} + \tfrac{1}{2}\log_2 5 = 1.36096\ldots$$

and the coset is a fair coin, $H(C)=1$. The key structural observation is elementary once stated: **a rotation is never a reflection**. The shapes $[1^5]$ and $[5]$ come only from rotations; the shape $[1,2,2]$ comes only from reflections. So the type *determines* the coset, and a determined observable transmits everything:

$$I(T;C) = H(C) = 1 \text{ bit, exactly.}$$

Everything left over is entropy the congruence cannot see:

$$H(T) - I(T;C) = H(T \mid C) = \tfrac{1}{2}\log_2 5 - \tfrac{4}{5} = 0.36096\ldots$$

This is the **gap identity**, and it is the whole program in one line: *the shortfall of the transmitted information below the type entropy is exactly the coset-conditioned type entropy.* Nothing is lost and nothing is unaccounted for — every bit of the factorization histogram is either a bit about $p$'s residue class or a bit about which of several elements inside one coset the Frobenius was.

## The law, in general

Strip away the arithmetic and a clean theorem remains.

> **The Abelianization Law.** Let $G$ be a finite group, $\varphi : G \twoheadrightarrow A$ a surjective homomorphism onto a finite abelian group, and $T$ any function on $G$ (the "type") with the property that elements of equal type have equal image under $\varphi$. Give $G$ the uniform distribution. Then
> $$I(T; \varphi) = \log_2 |A|.$$

The proof is two lines of entropy bookkeeping: if the type determines the coset, the joint entropy collapses to the type entropy, $H(T,C)=H(T)$, so $I = H(T)+H(C)-H(T,C) = H(C)$; and the fibres of a surjective homomorphism all have the same size, so the coset marginal is uniform and $H(C)=\log_2|A|$.

The converse was the more interesting frontier, and it is now closed:

> **Saturation Criterion.** For any finite joint table of types and cosets, $I(T;C) = H(C)$ **if and only if** the type determines the coset — that is, no single type occurs with two different cosets.

The mechanism is a sharpened form of a familiar inequality. For a row of the table with total mass $S$, the sum of $-x\log x$ over the row's cells is at least $-S \log S$, with equality precisely when the row is concentrated in a single cell; split the mass between two cells and the inequality becomes strict. Summing over rows and comparing with the marginal identifies saturating tables exactly. So ambiguity is not merely a failure to prove saturation — it *provably* destroys it.

## The completed quintic row

There are exactly five transitive groups of degree five: the cyclic group $C_5$, the dihedral group $D_5$, the Frobenius group $F_{20}$ of order 20, the alternating group $A_5$, and the full symmetric group $S_5$. Each is realized by concrete polynomials, and each gives a table whose entropies can be evaluated in closed form. Writing $L=\log_2 5$ and $M=\log_2 3$:

| group | example | abelianization | $H(T)$ | $I(T;C)$ | gap $H(T\mid C)$ |
|---|---|---|---|---|---|
| $C_5$ | real subfield of $\mathbb{Q}(\zeta_{11})$ | $C_5$ | $L-\tfrac{8}{5} = 0.7219$ | $L - \tfrac{8}{5} = 0.7219$ | $0$ |
| $D_5$ | $x^5+20x+32$ | $C_2$ | $\tfrac{1}{5}+\tfrac{L}{2} = 1.3610$ | $1$ | $\tfrac{L}{2}-\tfrac{4}{5}=0.3610$ |
| $F_{20}$ | $x^5-2$ | $C_4$ | $\tfrac{11}{10}+\tfrac{L}{4}=1.6805$ | $\tfrac{3}{2}$ | $\tfrac{L}{4}-\tfrac{2}{5}=0.1805$ |
| $A_5$ | $x^5+20x+16$ | trivial | $\tfrac{2}{15}+\tfrac{7M}{20}+\tfrac{5L}{12}=1.6555$ | $0$ | $1.6555$ |
| $S_5$ | $x^5-x-1$ | $C_2$ | $\tfrac{7}{5}+\tfrac{5L}{24}+\tfrac{17M}{40}=2.5574$ | $1$ | $2.5574 - 1$ |

The quintic row is now complete: five groups, one law, no exceptions. Read the table as a story about what congruences can and cannot see.

- **$C_5$** is abelian, so the Frobenius element *is* its coset: the type and the residue class carry identical information, and the gap is exactly zero. The channel is transparent.
- **$D_5$** is our polynomial: one bit through, $0.3610$ bits of residue-invisible pentagon geometry left behind.
- **$A_5$** is perfect — it equals its own commutator subgroup — so it has no abelian quotient at all. Its $1.6555$ bits of factorization entropy are *entirely* invisible to congruences. No arithmetic progression will ever predict how $x^5+20x+16$ factors. This is the group-theoretic reason that non-solvable quintics are outside the reach of reciprocity laws: the failure is not a lack of cleverness but a theorem about entropy.
- **$S_5$** has abelianization $C_2$ via the sign, so exactly one bit gets through — the parity of the Frobenius permutation, detected by whether the discriminant is a square mod $p$. Its remaining $1.5574$ bits are unreachable.
- **$F_{20}$** is the outlier, and the most instructive cell. Its abelianization is the cyclic group $C_4$ of order four, so the coset entropy is $H(C)=2$ bits. But the factorization shape $[4]$ — for $x^5-2$, a linear factor times an irreducible quartic — occurs for *both* generators of $C_4$: two distinct cosets, one shape. By the Saturation Criterion this ambiguity strictly lowers the information, and one computes exactly $I(T;C) = 3/2 < 2$. Half a bit is destroyed by a single ambiguous type.

## The residue dial adds noise, not news

One nagging worry about measurements of this kind: the coset of Frobenius is an idealized object, while the thing you actually observe is the residue $p \bmod 20$, which has eight possible values, not two. The residue is a strictly finer observable — three bits of entropy, not one. Does refining it change the answer?

No, and there is a clean theorem to that effect. Suppose you replace the coset alphabet by a finer alphabet mapping $m$-to-one onto it, spreading each coset's mass uniformly over its refinements. (This is exactly what happens here: the Artin map sends the eight units modulo $20$ onto $C_2$, four-to-one.) Then the type marginal is unchanged, the coset entropy and the joint entropy each increase by precisely $\log_2 m$, and so

$$I(T; \text{residue}) = I(T; \text{coset}).$$

The dial adds entropy but no information. Applied at $m^\ast = 20$: the residue observable carries $\log_2 8 = 3$ bits, of which exactly one is about the factorization type. The measured value $1.0000$ is not a rounded approximation of something messy; it is an exact theorem with the noise cleanly quotiented away.

## Two primes at once, and a wall

Suppose you are handed not a prime but a semiprime $n = pq$, and you may factor $f$ modulo $p$ and modulo $q$. You learn two types. What do they tell you about $n$'s residue class — equivalently, about the *product* of the two cosets?

Again exactly one bit, no more. The reason is that in an abelian group, the product of two independent uniform elements is uniform; if the type determines each coset, the pair of types determines the product coset, and the Abelianization Law applies verbatim with the same $|A|$. Pairing neither gains nor loses. Indeed the same argument runs at any arity: for $k$ independent primes, the vector of $k$ types carries exactly $\log_2|A|$ bits about the coset of the product — the single-prime value is an exact invariant of arity.

And there is a hard wall. The coset of the product of two (or $k$) independent Frobenius classes is *statistically independent* of the coset of any one designated factor: the mutual information is exactly $0$. Knowing the residue of $n$ tells you nothing whatsoever about which of $p$, $q$ contributed which half of it. This "which-factor wall" is structural, not a limitation of the measuring apparatus — it is the same fact that makes a one-time pad perfect: a uniform group element multiplied into anything hides it completely.

## What the table means

It is worth stepping back to see what kind of object has been built. On one side sits a piece of pure number theory — Chebotarev equidistribution, class field theory, quadratic resolvents. On the other sits a piece of Shannon's information theory — entropy, mutual information, channel capacity. The type/coset table is the hinge, and once you have it, questions that sound vague ("how much does factoring $f$ mod $p$ tell you about $p$?") become computations with rational and logarithmic answers.

The answers are pleasingly rigid. Across the whole degree-five landscape the transmitted information is $\log_2 5 - 8/5$, $1$, $3/2$, $0$, $1$: four of the five are rational, and the one irrational value occurs precisely where the type observable and the coset observable coincide. The gaps are always $H(T\mid C)$, exactly. The deficit from saturation is $0$ in four cells and exactly $1/2$ in the fifth, traceable to one ambiguous shape.

Whether that rigidity survives into degree six is an open and testable question. The natural conjecture is that the deficit $\log_2|A| - I(T;C)$ is always a sum of terms $p(t)\log_2 k_t$, where $k_t$ counts how many cosets the shape $t$ straddles — hence dyadic whenever every $k_t$ is a power of two, and irrational the moment some shape straddles three cosets. A single sextic group with a type spread across three cosets of $C_6$ would settle it. That is a cheap experiment with a sharp outcome, which is the best kind.

Meanwhile, next time you factor a quintic modulo a prime, you can put a number on what you just learned. For $x^5+20x+32$, it is one bit — and you now know exactly where the other $0.361$ bits went.
