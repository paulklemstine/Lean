# A Rigorous Census Boundary for $L$-Functions: Faithful Arithmetic Coding, Finite-Prefix Ambiguity, and the Dirichlet Model

**Aristotle**  
**18 July 2026**

## Abstract

The proposal that all natural $L$-functions form a countable universe is attractive but requires care: discrete invariants and finitely many Euler factors do not automatically determine an analytic function. This paper separates the coding principle that would prove countability from the rigidity statement needed to apply it. We prove that every family admitting an injective code by finite rational arithmetic packets is countable. Conversely, for every finite cutoff, we construct two normalized coefficient sequences, bounded in modulus by $1$, that agree through the cutoff but define distinct convergent Dirichlet series. Hence there is no universal finite-prefix classifier for bounded Dirichlet series. We then give an unconditional arithmetic model. For each positive modulus, distinct complex Dirichlet characters define distinct $L$-functions and the resulting family is finite; over all moduli, the family of analytic Dirichlet $L$-functions is countable. For coprime moduli, the character census is multiplicative by Chinese-remainder factorization. These results identify the missing bridge in a census of the Selberg class: not finite sampling, but a faithful countable code encoding a global rule. They also explain why a canonical conductor-ordered enumeration cannot yet be asserted without finite conductor fibres and an effective equality criterion.

## 1. Introduction

An $L$-function converts arithmetic data into complex analysis. Its Dirichlet coefficients may describe a character, a modular form, an elliptic curve, or a representation; its Euler factors organize prime-by-prime information; and its functional equation expresses a global symmetry. The same analytic format therefore appears across number theory.

This unity motivates a basic cardinality question: is the collection of natural $L$-functions countable? Since degrees, conductors, signs, and algebraic coefficients are discrete, one may expect an affirmative answer. Yet the expectation conceals a logical gap. A finite amount of discrete metadata is a countable label, but countability of labels proves countability of objects only when the labeling is faithful. Moreover, an analytic function given by a Dirichlet series generally depends on its entire infinite coefficient sequence.

The purpose of this paper is to draw a rigorous census boundary. On the positive side, faithful coding into a countable packet space immediately gives countability. Dirichlet $L$-functions realize this principle unconditionally: at fixed modulus they form a finite faithfully indexed family, and their union over all moduli is countable. On the negative side, no finite coefficient prefix classifies all bounded convergent Dirichlet series. The counterexample is explicit and persists beyond every observational cutoff.

The distinction is between **finite samples** and **finite instructions**. A finite sample records several coefficients and leaves the rest unspecified. A finite instruction, such as a character table together with periodicity and multiplicativity, supplies a rule generating all coefficients. The former cannot support a general census; the latter can, provided different objects receive different instructions.

The paper proceeds as follows. Section 2 defines Dirichlet series, observational agreement, arithmetic packets, countability, and Dirichlet characters. Section 3 proves finite-prefix ambiguity and the impossibility of a universal finite-prefix classifier. Section 4 establishes the conditional coding theorem. Section 5 develops the unconditional Dirichlet census and its multiplicativity across coprime moduli. Section 6 describes explicit algorithms and their complexity. Section 7 discusses scope, applications, and common overstatements, including the arithmetic status of elliptic curves. Section 8 formulates the remaining research program.

## 2. Definitions and census principles

### 2.1. Dirichlet coefficient sequences and series

A **Dirichlet coefficient sequence** is a function $a:\mathbb{N}_{>0}\to\mathbb{C}$. Its Dirichlet series is

$$
L_a(s)=\sum_{n=1}^{\infty}a(n)n^{-s},
$$

for complex $s$ in any half-plane where the series converges. It is occasionally convenient to extend $a$ to index $0$ and impose the harmless normalization $a(0)=0$.

A sequence is **unit bounded** when $|a(n)|\le 1$ for every positive integer $n$. The counterexamples below use finite-support unit-bounded sequences, so their series converge for every $s$ after interpreting $n^{-s}=e^{-s\log n}$.

For a nonnegative integer $N$, two extended coefficient sequences $a,b:\mathbb{N}\to\mathbb{C}$ **agree through $N$** if

$$
a(n)=b(n)\qquad\text{for every }0\le n\le N.
$$

This definition models a finite observation window. It imposes no rule on coefficients after $N$.

### 2.2. Natural $L$-functions and the Selberg framework

The broad term **natural $L$-function** usually signals more than convergence of a Dirichlet series. The Selberg class is a standard axiomatic model: its members have a normalized Dirichlet series, analytic continuation of controlled type, a functional equation with gamma factors and conductor, an Euler product, and a Ramanujan-type coefficient bound. These conditions encode powerful structure, but the present conclusions must distinguish axioms already known to imply classification from those merely expected to do so.

We do not assume that degree, conductor, root number, and finitely many Euler factors determine a Selberg-class function. That assertion is precisely a rigidity theorem requiring proof. Our positive theorem is therefore stated conditionally for any family carrying a faithful code.

### 2.3. Finite arithmetic packets

A **finite rational arithmetic packet** consists of the following data:

1. a degree $d\in\mathbb{N}$;
2. a conductor $Q\in\mathbb{N}$;
3. a root sign $\varepsilon\in\{-1,+1\}$;
4. a finite ordered list of rational gamma shifts;
5. a finite ordered list of exceptional local factors, each represented by a natural-number index and a finite list of rational coefficients.

This is a deliberately discrete model. If an arbitrary complex number were admitted as unrestricted packet data, packet countability would no longer be immediate. The packet need not match every convention for completed $L$-functions; its role is to express the general coding argument with an explicitly countable alphabet.

A packet assignment $c:\mathcal{F}\to\mathcal{P}$ from a family $\mathcal{F}$ to the packet space $\mathcal{P}$ is **faithful** if it is injective:

$$
c(F)=c(G)\Longrightarrow F=G.
$$

Faithfulness says the packet is an identity card rather than a coarse label.

### 2.4. Countability

A set is **countable** if it injects into the natural numbers, equivalently if its elements can be placed in a finite or infinite sequence without omission. The natural numbers, integers, and rationals are countable. Finite products, finite lists, and countable unions of countable sets are countable.

By contrast, the space of all infinite binary sequences is uncountable. Thus a family described by arbitrary infinite coefficient sequences is not countable merely because each coefficient belongs to a finite or countable alphabet. Some restriction tying the infinite data to countably many global descriptions is essential.

### 2.5. Dirichlet characters

Let $q$ be a positive integer. A **complex Dirichlet character modulo $q$** is a function $\chi:\mathbb{Z}\to\mathbb{C}$ that is periodic modulo $q$, completely multiplicative, equals $0$ on integers not coprime to $q$, and restricts to a group homomorphism from the unit group $(\mathbb{Z}/q\mathbb{Z})^\times$ to $\mathbb{C}^\times$. Its $L$-function is

$$
L(s,\chi)=\sum_{n=1}^{\infty}\frac{\chi(n)}{n^s},
$$

initially convergent for $\operatorname{Re}(s)>1$. The coefficient sequence is periodic and is determined by finitely many residue values, but crucially this finite table comes with a global periodic rule.

## 3. The obstruction: finite prefixes do not classify

We begin with the negative result because it prevents an invalid shortcut in any cosmic census.

### Theorem 3.1 (Finite-Prefix Ambiguity)

For every nonnegative integer $N$, there exist sequences $a,b:\mathbb{N}\to\mathbb{C}$ satisfying all of the following:

1. $a(0)=b(0)=0$;
2. $|a(n)|\le 1$ and $|b(n)|\le 1$ for every $n\ge 1$;
3. $a$ and $b$ agree through $N$;
4. the Dirichlet series $L_a$ and $L_b$ are distinct analytic functions.

#### Proof sketch

Define

$$
a(n)=\mathbf{1}_{\{N+1\}}(n),\qquad
b(n)=\mathbf{1}_{\{N+2\}}(n),
$$

where $\mathbf{1}_{\{r\}}$ is $1$ at $r$ and $0$ elsewhere. Both sequences vanish from $0$ through $N$, so they agree throughout the observation window. Their entries belong to $\{0,1\}$ and therefore satisfy the stated bound. Because each sequence has finite support, its Dirichlet series converges everywhere and reduces to one term:

$$
L_a(s)=(N+1)^{-s},\qquad L_b(s)=(N+2)^{-s}.
$$

These functions differ; evaluating at $s=1$ gives unequal positive rational numbers. This proves all four claims. $\square$

The example is minimal: each witness contains exactly one nonzero coefficient. It therefore cannot be dismissed as a pathology caused by difficult convergence or unbounded coefficients.

### Theorem 3.2 (No Universal Finite-Prefix Classifier)

There is no nonnegative integer $N$ with the following property: whenever two normalized unit-bounded coefficient sequences agree through $N$, their Dirichlet series are equal.

#### Proof sketch

Assume such an $N$ exists. Apply Theorem 3.1 at that same cutoff. The two spike sequences satisfy every premise of the proposed classifier, which would force $L_a=L_b$, while the theorem gives $L_a\ne L_b$. This contradiction excludes every universal cutoff. $\square$

### Remark 3.3 (Full-sequence uniqueness versus finite observation)

Classical uniqueness of Dirichlet series says, under standard convergence hypotheses, that equality of the represented functions forces equality of all coefficients. This is a statement about the complete infinite sequence. It does not imply that a fixed finite prefix determines the sequence. Theorems 3.1 and 3.2 expose exactly this quantifier distinction.

### Remark 3.4 (Euler factors)

The same logical warning applies to finitely many initial Euler factors. Without an additional arithmetic rigidity principle, unobserved local factors may vary. A theorem about a restricted family may show that sparse or density-one prime data determine the global object, but such a result uses the special family, not convergence alone.

## 4. The positive boundary: faithful packet coding

### Lemma 4.1 (Countability of the packet space)

The set $\mathcal{P}$ of finite rational arithmetic packets is countable.

#### Proof sketch

Each packet field lies in a countable set. Degrees and conductors lie in $\mathbb{N}$; the root sign lies in a two-element set; rational shifts form a finite list over $\mathbb{Q}$; and exceptional factors form a finite list over $\mathbb{N}\times\mathbb{Q}^{<\omega}$, where $\mathbb{Q}^{<\omega}$ denotes finite rational lists. Finite lists over a countable set are countable, and finite products of countable sets are countable. Therefore $\mathcal{P}$ is countable. $\square$

### Theorem 4.2 (Faithful Arithmetic-Packet Census)

Let $\mathcal{F}$ be any family of mathematical objects. If there is a faithful packet assignment $c:\mathcal{F}\to\mathcal{P}$ into the finite rational arithmetic packets, then $\mathcal{F}$ is countable.

#### Proof sketch

By Lemma 4.1, choose an injection $e:\mathcal{P}\to\mathbb{N}$. Since $c$ is injective, the composite $e\circ c:\mathcal{F}\to\mathbb{N}$ is injective. Hence $\mathcal{F}$ is countable. $\square$

### Corollary 4.3 (Conditional Selberg Census)

If every member of the Selberg class admits a unique finite rational arithmetic packet of the stated kind—or, more generally, an injective finite description over any countable alphabet—then the Selberg class is countable.

#### Proof sketch

Apply Theorem 4.2 to the Selberg class and the assumed faithful assignment. $\square$

The corollary is conditional. The known axioms do not by themselves establish that a finite list of exceptional factors plus standard metadata is faithful. The packet could instead contain a finite effective rule that generates all omitted factors; but then one must prove both that every function has such a rule and that the rule determines it uniquely.

## 5. The unconditional Dirichlet census

Dirichlet characters provide a complete model in which finite arithmetic instructions genuinely govern an infinite coefficient sequence.

### Lemma 5.1 (Finiteness of characters at fixed modulus)

For each positive integer $q$, the set of complex Dirichlet characters modulo $q$ is finite.

#### Proof sketch

A Dirichlet character is determined by its restriction to the finite group $(\mathbb{Z}/q\mathbb{Z})^\times$. The group of complex characters of a finite abelian group is finite and has the same cardinality as the group itself. Thus the number of Dirichlet characters modulo $q$ is

$$
C(q)=\left|(\mathbb{Z}/q\mathbb{Z})^\times\right|=\varphi(q),
$$

where $\varphi$ is Euler’s totient function. $\square$

### Lemma 5.2 (Faithfulness at fixed modulus)

Let $q$ be positive. If $\chi$ and $\psi$ are Dirichlet characters modulo $q$ and

$$
L(s,\chi)=L(s,\psi)
$$

as analytic Dirichlet series, then $\chi=\psi$.

#### Proof sketch

The uniqueness theorem for Dirichlet series recovers the complete coefficient sequence from the analytic function in a common half-plane of convergence. Hence $\chi(n)=\psi(n)$ for every positive integer $n$. Periodicity then gives equality on all integers, so the characters coincide. $\square$

### Theorem 5.3 (Fixed-Modulus Faithful and Finite Census)

For every positive integer $q$, the map

$$
\chi\longmapsto L(s,\chi)
$$

from complex Dirichlet characters modulo $q$ to analytic Dirichlet $L$-functions is injective and has finite image.

#### Proof sketch

Injectivity is Lemma 5.2. The domain is finite by Lemma 5.1, so its image is finite. In fact, the image contains exactly $\varphi(q)$ distinct functions. $\square$

### Theorem 5.4 (Global Countability of Analytic Dirichlet $L$-Functions)

The family of analytic Dirichlet $L$-functions over all positive moduli is countable.

#### Proof sketch

For each $q\ge 1$, Theorem 5.3 gives a finite family $\mathcal{D}_q$. The global family is

$$
\mathcal{D}=\bigcup_{q=1}^{\infty}\mathcal{D}_q.
$$

A countable union of finite sets is countable. Duplicate functions arising from different presentations do not cause difficulty: taking a union can only decrease cardinality. $\square$

### Theorem 5.5 (Multiplicative Character Census)

Let $m$ and $k$ be coprime positive integers. Then

$$
C(mk)=C(m)C(k),
$$

where $C(q)$ is the number of complex Dirichlet characters modulo $q$.

#### Proof sketch

The Chinese remainder theorem gives a group isomorphism

$$
(\mathbb{Z}/mk\mathbb{Z})^\times
\cong
(\mathbb{Z}/m\mathbb{Z})^\times\times
(\mathbb{Z}/k\mathbb{Z})^\times.
$$

A character of a direct product is uniquely the product of one character on each factor. Therefore the character group modulo $mk$ is isomorphic to the product of the character groups modulo $m$ and $k$. Taking cardinalities gives the formula. Equivalently, this is the familiar multiplicativity $\varphi(mk)=\varphi(m)\varphi(k)$ for coprime arguments. $\square$

### Example 5.6

For $m=5$ and $k=8$, one has $\gcd(5,8)=1$, $C(5)=\varphi(5)=4$, and $C(8)=\varphi(8)=4$. Hence

$$
C(40)=C(5)C(8)=16.
$$

For noncoprime moduli the product formula need not apply. For example, $C(4)C(2)=2$, while $C(8)=4$.

## 6. Algorithms and numerical demonstrations

The theorems suggest three transparent computational procedures. These are demonstrations of the proven structure, not a purported enumeration of the Selberg class.

### 6.1. Adversarial finite-prefix construction

Given $N$, create two arrays supported at $N+1$ and $N+2$. To display agreement through the cutoff, inspect entries $0$ through $N$. To distinguish the series, evaluate

$$
(N+1)^{-s}-(N+2)^{-s}
$$

at any convenient real $s>0$. Constructing dense arrays through $N+2$ takes $O(N)$ time and space; a sparse representation takes $O(1)$ space and evaluates either series in $O(1)$ time.

This algorithm is adversarial in the precise sense that it accepts any proposed observation horizon and places all distinguishing information immediately beyond it.

### 6.2. Fixed-modulus character count

The number of complex Dirichlet characters modulo $q$ is $\varphi(q)$. A direct algorithm counts integers $1\le a\le q$ with $\gcd(a,q)=1$, requiring $O(q\log q)$ bit-operation scale under elementary gcd accounting and $O(1)$ auxiliary space. A factorization-based formula,

$$
\varphi(q)=q\prod_{p\mid q}\left(1-\frac1p\right),
$$

can be evaluated after trial division in $O(\sqrt q)$ arithmetic steps. This count determines the size of the faithfully indexed fixed-modulus analytic family.

### 6.3. Coprime multiplicativity audit

Given $m$ and $k$, first compute $\gcd(m,k)$. If it is not $1$, report that Theorem 5.5 does not apply. Otherwise compute $\varphi(m)$, $\varphi(k)$, and $\varphi(mk)$ and verify

$$
\varphi(mk)=\varphi(m)\varphi(k).
$$

With trial-division totients, the running time is $O(\sqrt m+\sqrt k+\sqrt{mk})$ arithmetic steps and memory use is constant. The calculation visualizes the local-to-global factorization of degree-one census data.

## 7. Applications, limitations, and corrected expectations

### 7.1. Database design and equality testing

A mathematical database ordered by conductor needs more than stored metadata. It needs a canonical representation or an equality procedure. Theorem 3.2 says that comparing a universal finite prefix of coefficients cannot provide equality for arbitrary bounded Dirichlet series. A restricted arithmetic class may admit an effective bound, but that bound must be proved from its rigidity.

Faithful packet coding separates storage from observation. A packet that includes a finite algorithm for generating all local factors may be sufficient, whereas a packet containing only the first several factors is not. The census theorem applies only after injectivity has been established.

### 7.2. Elliptic curves and cardinality

Complex elliptic curves are classified up to isomorphism by a complex $j$-invariant, aside from standard stack-theoretic qualifications. Since $\mathbb{C}$ is uncountable, this complex-geometric family is uncountable. It does not follow that arithmetic $L$-functions of elliptic curves over $\mathbb{Q}$ are uncountable. A curve over $\mathbb{Q}$ is given by finitely many rational coefficients, and finite rational tuples form a countable set. Therefore elliptic curves over $\mathbb{Q}$, and consequently their associated $L$-functions, form at most a countable family. Arbitrary complex $j$-invariants do not define elliptic curves over $\mathbb{Q}$.

This distinction illustrates a general rule: the field of definition matters. An uncountable geometric moduli space can contain a countable arithmetic locus.

### 7.3. Why “the first hundred” is premature

A conductor-ordered list of the first hundred Selberg-class members would require several ingredients:

1. finiteness of the relevant family at each bounded conductor and degree;
2. a complete method for generating all candidates;
3. an effective equality test to remove duplicate presentations;
4. a precise decision about primitive versus imprimitive functions;
5. a deterministic tie-breaker among equal-conductor objects.

None follows from the finite packet template alone. The fixed-modulus Dirichlet family supplies a tractable model, but extrapolation to the whole Selberg class is a conjectural research program rather than an established enumeration.

### 7.4. Countability is weaker than finite conductor slices

Even if a family is countable, a fixed conductor slice can be infinite. Countability only supplies a global listing. Finiteness at bounded conductor is a stronger arithmetic assertion, potentially requiring compactness, height bounds, or classification. Similarly, polynomial growth in conductor is stronger still and presupposes finite slices.

### 7.5. Relation to multiplicity one

The finite-prefix obstruction concerns arbitrary bounded Dirichlet series. Arithmetic families may obey strong multiplicity-one principles: equality of local factors on a sufficiently large set of primes can force equality globally. There is no contradiction. Such theorems exploit automorphy, representation theory, bounded degree, or conductor restrictions absent from the general analytic setting.

An effective version would be especially valuable. Under a height constraint, one could seek a finite prime bound $B$ such that equality of Euler factors for $p\le B$ implies equality within the restricted family. Theorem 3.2 shows why the family restrictions are indispensable.

## 8. Future research

The rigorous boundary suggests five directions.

First, one may seek **faithful arithmetic coding of the Selberg class**. A plausible finite packet would have to encode an effective global rule for unrecorded Euler factors, not merely omit them. Countability would then follow from Theorem 4.2.

Second, one may ask for **finite fibres at bounded degree and conductor**. For fixed positive integers $d$ and $Q$, the conjecture is that only finitely many primitive Selberg-class functions have degree $d$ and conductor at most $Q$. The fixed-modulus Dirichlet theorem is a complete degree-one model, but it does not prove higher-degree finiteness.

Third, one may investigate **polynomial conductor growth in fixed degree**. After fixing an equivalence relation and primitive convention, the number of degree-$d$ functions of conductor at most $Q$ might be polynomially bounded in $Q$. The multiplicative character census suggests that local-to-global structure can constrain growth.

Fourth, one may pursue **effective rigidity from sparse prime data**. Within fixed automorphic degree, bounded conductor, and bounded height, equality of Euler factors on a density-one set of primes should force equality, and one may seek an explicit finite verification bound.

Fifth, conditional on finite conductor fibres and effective equality, one may define a **canonical conductor-ordered enumeration**. Such an enumeration would order first by conductor and then by explicitly specified arithmetic data. It would convert a cardinality theorem into an effective census.

## 9. Conclusion

The $L$-function universe cannot be counted by confusing a handful of invariants with a complete identity. Every finite observation horizon admits two bounded coefficient sequences that are indistinguishable within the horizon yet define different convergent Dirichlet series. Thus finite prefixes, by themselves, do not classify.

At the same time, the route to a valid census is exact and simple: construct a countable code and prove it faithful. Dirichlet $L$-functions demonstrate the method. Their fixed-modulus families are finite and faithfully indexed by characters, their global union is countable, and their counts multiply across coprime moduli.

For the Selberg class, countability remains a conditional conclusion until a suitable global coding or rigidity theorem is supplied. The central open bridge is therefore not analytic uniqueness from all coefficients, but arithmetic recovery of all coefficients from finite instructions. A cosmic census becomes rigorous only when every star has a faithful name.