# The Multipliers That Make Lattice Cryptography Move

## Why composite moduli change the search-to-decision story

Modern cryptography often hides a secret in a cloud of almost-correct linear equations. Each equation is accurate enough to carry information, but noisy enough that extracting the hidden vector appears difficult. This is the Learning with Errors problem, or LWE, one of the central mathematical foundations of lattice-based cryptography.

Fix a positive integer modulus $q$ and a dimension $n$. The secret is a vector $s\in(\mathbb Z/q\mathbb Z)^n$. A sample consists of a uniformly chosen vector $u\in(\mathbb Z/q\mathbb Z)^n$ and a value

$$
v=\langle u,s\rangle+e\pmod q,
$$

where $e$ is a small random error. The **search problem** asks for $s$. The **decision problem** asks only whether a stream of pairs $(u,v)$ comes from this rule or is uniformly random. Search sounds harder: identifying a hidden object should require more information than recognizing that some hidden structure exists. A search-to-decision reduction turns that intuition around by using a decision procedure repeatedly to recover the secret.

For prime $q$, the algebra behind this strategy is exceptionally smooth. Every nonzero residue has a multiplicative inverse. But practical cryptosystems often favor moduli such as $2^k$, where arithmetic is fast and binary hardware is at home. Composite moduli contain nonzero elements that are not invertible. That small distinction is exactly where a naive extension of the prime-modulus argument breaks.

The repair is both simple and far-reaching: **replace “nonzero multiplier” by “unit multiplier.”** From that correction flow a precise permutation theorem, an invariance principle for averages, an exact count given by Euler’s totient function, a Chinese-remainder decomposition, and the quantitative pigeonhole step used by hybrid reductions.

## A four-point warning

Consider arithmetic modulo $4$. Multiplication by $2$ sends

$$
0,1,2,3\longmapsto 0,2,0,2.
$$

The multiplier $2$ is nonzero, but the map destroys half the information. Adding a shift cannot repair the collision: for any residue $b$, the affine map $x\mapsto 2x+b$ still has only two outputs. By contrast, multiplication by $1$ or $3$ merely permutes the four residues.

This example identifies the right definition. A residue $a\in\mathbb Z/q\mathbb Z$ is a **unit** if there exists $a^{-1}$ with $aa^{-1}=1$. For an integer representative, this is equivalent to

$$
\gcd(a,q)=1.
$$

Units are not merely convenient multipliers. They are exactly the multipliers for which affine rerandomization loses no information.

**Affine Permutation Theorem.** Let $q>0$ and let $a,b\in\mathbb Z/q\mathbb Z$. The map

$$
T_{a,b}(x)=ax+b
$$

is a bijection of $\mathbb Z/q\mathbb Z$ if and only if $a$ is a unit. Equivalently, if $a$ is represented by an integer, $T_{a,b}$ is bijective if and only if $\gcd(a,q)=1$.

The proof exposes why translation is harmless. Adding $b$ is always reversible by adding $-b$. Thus $T_{a,b}$ is bijective precisely when multiplication by $a$ is bijective. If $a$ has an inverse, multiplication by $a^{-1}$ supplies the inverse map. Conversely, if multiplication by $a$ is onto, some $x$ satisfies $ax=1$, so $a$ is a unit.

This is the algebraic hinge of arbitrary-modulus rerandomization. A transformation used inside a cryptographic reduction must move samples around without collapsing distinct possibilities. The theorem says exactly which transformations qualify.

## Uniformity survives a permutation

A uniformly random residue remains uniform after any permutation. The affine theorem therefore has an immediate statistical consequence.

**Affine Average Invariance.** If $a$ is a unit modulo $q$, then for every real-valued statistic $f$ on $\mathbb Z/q\mathbb Z$,

$$
\sum_{x\in\mathbb Z/q\mathbb Z} f(ax+b)
=
\sum_{x\in\mathbb Z/q\mathbb Z} f(x).
$$

Dividing both sides by $q$ shows that the corresponding averages are equal.

The proof is a change of variables: because $x\mapsto ax+b$ is a permutation, the left side visits every residue exactly once. This elementary identity is the “uniformity engine” in a hybrid argument. If a guessed secret coordinate makes a transformed sample land in the correct affine form, then averaging over the rerandomizing residue introduces no statistical bias. A decision oracle can therefore be queried on transformed data without an accidental distortion caused by the transformation itself.

The conclusion is stronger than preservation of one specially chosen test. It holds for **every** statistic $f$. Indicators show that every event keeps the same probability; bounded scoring functions show that every expected score is preserved.

## How many safe multipliers exist?

Once units replace nonzero residues, an algorithmic question appears: how often does a randomly chosen multiplier work? Euler’s totient function $\varphi(q)$ counts integers in $\{0,1,\ldots,q-1\}$ that are coprime to $q$. Consequently:

**Totient Count Theorem.** Exactly $\varphi(q)$ residues modulo $q$ are valid affine multipliers.

For prime $p$, this gives $\varphi(p)=p-1$, recovering the familiar rule that every nonzero residue works. For $q=8$, the valid multipliers are $1,3,5,7$, so four of eight choices work. For $q=12$, only $1,5,7,11$ work. The density of admissible choices is

$$
\frac{\varphi(q)}{q}.
$$

A rejection sampler that repeatedly chooses a uniform residue until it finds a unit succeeds with this probability on each trial and therefore uses an expected $q/\varphi(q)$ trials. Thus the totient is not just a counting curiosity: it measures the cost of safe rerandomization.

For a prime power $q=p^k$,

$$
\varphi(p^k)=p^k-p^{k-1}=p^k\left(1-\frac1p\right).
$$

The acceptance probability is the constant $1-1/p$, independent of $k$. Powers of two, ubiquitous in implementations, therefore accept exactly half of all multipliers.

## Breaking a modulus into independent pieces

Composite arithmetic becomes clearer through the Chinese Remainder Theorem. If $m$ and $n$ are coprime, then

$$
\mathbb Z/(mn)\mathbb Z\cong \mathbb Z/m\mathbb Z\times\mathbb Z/n\mathbb Z.
$$

A residue modulo $mn$ is thus a pair of residues, one modulo $m$ and one modulo $n$. Invertibility also splits componentwise.

**Chinese-Remainder Unit Theorem.** When $\gcd(m,n)=1$, a residue $a$ is a unit modulo $mn$ if and only if its images are units modulo both $m$ and $n$.

**Totient Factorization Theorem.** Under the same assumption,

$$
\varphi(mn)=\varphi(m)\varphi(n).
$$

The first statement follows because a pair in a product ring has a multiplicative inverse exactly when each coordinate does. The second follows by counting the resulting pairs of units. Repeating the decomposition splits any modulus into coprime prime-power components.

Take $q=15=3\cdot5$. A multiplier works modulo $15$ precisely when it works modulo $3$ and modulo $5$. There are $2$ choices in the first component and $4$ in the second, giving $8$ units in total. Indeed, $\varphi(15)=8$.

For cryptographic reductions this decomposition is structural, not cosmetic. It says that the obstruction at a complicated modulus can be inspected one prime-power component at a time. The affine transformation is safe globally exactly when it is safe everywhere locally.

## Where the distinguishing advantage must go

Search-to-decision arguments usually compare a chain of intermediate distributions. The total distinguishing gap is divided among several steps. A finite averaging principle guarantees that some step carries a detectable share.

**Advantage Pigeonhole Theorem.** Let $I$ be a nonempty finite set, let $A(i)$ be a real contribution assigned to each $i\in I$, and suppose

$$
\delta\leq\sum_{i\in I}A(i).
$$

Then some $i\in I$ satisfies

$$
A(i)\geq\frac{\delta}{|I|}.
$$

If every contribution were smaller than $\delta/|I|$, summing the strict inequalities would make the total smaller than $\delta$, a contradiction.

Apply this theorem to the $q$ possible values of one secret coordinate. If their contributions sum to at least a decision advantage $\delta$, then at least one residue contributes at least

$$
\frac{\delta}{q}.
$$

This does not by itself construct the full oracle reduction: a complete reduction must specify the sample distributions, the error law, and how oracle calls realize each contribution. What it does provide is the exact finite quantitative step. The unit criterion identifies which affine tests are valid, while the pigeonhole theorem guarantees that a total gap cannot disappear uniformly among all candidate residues.

## The prime case reappears, rather than being replaced

When $p$ is prime, every nonzero residue is a unit. The Affine Permutation Theorem immediately specializes to the classical statement: if $a\neq0$ in $\mathbb Z/p\mathbb Z$, then $x\mapsto ax+b$ is a bijection. The arbitrary-modulus theory therefore does not discard the prime argument. It explains it as the unusually generous case in which “nonzero” and “invertible” coincide.

That perspective is useful beyond LWE. Any randomized algorithm over a finite ring must distinguish transformations that merely look nontrivial from transformations that genuinely preserve information. In a field, the distinction is invisible. In a ring with zero divisors, it is essential.

## A map for the road ahead

The algebra now points toward three natural extensions. First, a distributional hybrid can replace Chinese-remainder components one at a time, forcing one prime-power component to retain at least a proportional share of a global distinguishing gap. Second, for $q=p^e$, the chain of powers of $p$ suggests recovering a secret coordinate digit by digit in base $p$. Third, the density $\varphi(q)/q$ determines the true sampling cost; moduli with many small prime factors are the hardest cases, whereas fixed-prime powers have constant expected cost.

The central lesson is compact enough to remember: over a composite modulus, being nonzero is not enough. The transformations that preserve uniformity are the units; their number is $\varphi(q)$; and the Chinese Remainder Theorem reveals how they assemble. That trio—units, totients, and coprime components—provides the correct algebraic language for carrying the search-to-decision program beyond prime fields and into the moduli used by contemporary lattice cryptography.
