# The Dream of a Universal Reciprocity: From Roots of Unity to Class Numbers

## A hundred-year-old wish

At the dawn of the twentieth century, the mathematician David Hilbert stood before the International Congress of Mathematicians in Paris and read out a list of twenty-three problems that he believed would shape the century to come. The twelfth of these was, on its surface, deceptively concrete. It asked for an *explicit* recipe: a way to build, one by one, all the "abelian" number systems that sit on top of a given field of numbers, using special values of well-understood functions.

To feel the pull of Hilbert's twelfth problem, we first need to appreciate the one gleaming example that already existed — a theorem so beautiful it made mathematicians believe a grand generalization *had* to be true.

## The one perfect example: roots of unity

Start with the ordinary rational numbers $\mathbb{Q}$ — fractions, nothing more. Now imagine you want to enrich this world by adjoining a new number. A wonderfully symmetric choice is a **root of unity**: a complex number $\zeta_n$ satisfying $\zeta_n^n = 1$, sitting like a bead on the unit circle at angle $2\pi/n$. Adjoining it produces the *cyclotomic field* $\mathbb{Q}(\zeta_n)$ — literally, the "circle-dividing" field, because the powers of $\zeta_n$ chop the circle into $n$ equal arcs.

These cyclotomic fields are the most symmetric enlargements of the rationals imaginable. And the celebrated **Kronecker–Weber theorem** says something staggering: *every* abelian extension of $\mathbb{Q}$ — every enlargement whose symmetry group is commutative — lives inside one of these circle-dividing fields. Roots of unity alone generate the entire abelian universe over $\mathbb{Q}$. Hilbert's twelfth problem is the dream of finding the analogous "roots of unity" for every other number field.

## Counting the symmetries

Before we chase the generalization, let us pin down exactly how symmetric a cyclotomic field is, because the answer is the seed of everything that follows.

The symmetries of $\mathbb{Q}(\zeta_n)$ that fix the rationals form a group, the *Galois group* $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$. Each such symmetry must send $\zeta_n$ to another primitive root of unity $\zeta_n^k$, and the only $k$ that work are those with no common factor with $n$. In other words, the symmetries are labelled by the integers modulo $n$ that are *coprime* to $n$ — the multiplicative group $(\mathbb{Z}/n\mathbb{Z})^\times$.

This correspondence is not a loose analogy; it is an *isomorphism* of groups, the humblest instance of what is called **Artin reciprocity**:
$$(\mathbb{Z}/n\mathbb{Z})^\times \;\xrightarrow{\ \sim\ }\; \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}).$$
A purely arithmetic object on the left — remainders coprime to $n$ — is matched perfectly with a geometric-algebraic object on the right — the symmetries of a field.

Once you have this dictionary, arithmetic facts translate instantly into structural facts about fields. Here are the two cleanest.

**The degree is Euler's totient.** The number of integers between $1$ and $n$ coprime to $n$ is the famous *Euler totient* $\varphi(n)$. Since the isomorphism above is a bijection, the number of symmetries of the cyclotomic field equals this count:
$$\#\,\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) = \varphi(n).$$
Equivalently, the *degree* of the extension $\mathbb{Q}(\zeta_n)$ over $\mathbb{Q}$ — how many dimensions it spans as a vector space — is exactly $\varphi(n)$. For example, $\mathbb{Q}(\zeta_5)$ has degree $\varphi(5)=4$, and $\mathbb{Q}(\zeta_{12})$ has degree $\varphi(12)=4$.

**Primes give cyclic symmetry.** When $n=p$ is a prime, the coprime remainders are simply $1,2,\dots,p-1$, and this group $(\mathbb{Z}/p\mathbb{Z})^\times$ has a remarkable feature: it is *cyclic*, meaning a single remainder (a "primitive root") generates all the others by repeated multiplication. Through the reciprocity dictionary, this cyclicity transfers verbatim to the field:
$$\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q}) \text{ is cyclic of order } p-1.$$
So the symmetries of $\mathbb{Q}(\zeta_7)$, say, can all be obtained by iterating one master symmetry six times.

It is worth noting where this stops. For $n=8$, the coprime remainders are $\{1,3,5,7\}$, and multiplying any of them by itself gives $1$ modulo $8$. There is no single generator; the group is $C_2\times C_2$, the symmetry of a rectangle rather than a clock. So the crisp "cyclic" statement is genuinely special to prime moduli — a subtlety that matters when one tries to generalize.

## The leap: what plays the role of roots of unity elsewhere?

Now comes Hilbert's real question. Replace $\mathbb{Q}$ by a more elaborate number field $K$ — say $\mathbb{Q}(\sqrt{-5})$, obtained by adjoining $\sqrt{-5}$. What are the "roots of unity" for $K$? What generates its abelian extensions, and can we count and describe them as cleanly as $\varphi(n)$ counts the cyclotomic ones?

The first landmark on this road is not a field built from exotic functions but a canonical field attached to $K$ by pure thought: the **Hilbert class field** $H$. It is the *largest* abelian extension of $K$ that is *unramified* everywhere — a technical way of saying it enlarges $K$ without introducing any new "arithmetic singularities" at the primes. It is, in a precise sense, the most efficient possible abelian enlargement of $K$.

What makes $H$ so beloved is that its symmetry group is not a mysterious new object at all. It equals a quantity number theorists already care about deeply: the **ideal class group** $\mathrm{Cl}(\mathcal{O}_K)$ of $K$. This class group measures the failure of unique factorization in $K$: in the ordinary integers every number factors uniquely into primes, but in fields like $\mathbb{Q}(\sqrt{-5})$ this breaks down (famously, $6 = 2\cdot 3 = (1+\sqrt{-5})(1-\sqrt{-5})$), and the class group is exactly the bookkeeping device recording how badly. Its size is the **class number** $h_K$, and $h_K=1$ precisely when factorization *is* unique.

The higher analogue of Artin reciprocity states that the symmetries of the Hilbert class field *are* the class group:
$$\mathrm{Gal}(H/K)\;\xrightarrow{\ \sim\ }\;\mathrm{Cl}(\mathcal{O}_K).$$
This is a profound upgrade of the cyclotomic story. Over $\mathbb{Q}$ the reciprocity partner was the concrete group of coprime remainders; over a general $K$ it is the class group, an invariant that senses the very arithmetic of factorization.

## The payoff: degree equals class number

From this single reciprocity isomorphism, a clean and useful law follows, mirroring "degree $=\varphi(n)$" from the cyclotomic case. Because the symmetry group of a well-behaved (finite Galois) extension has exactly as many elements as the extension has dimensions, and because reciprocity identifies that group with the class group, we obtain:

**Theorem (Degree of the Hilbert class field).** *The degree of the Hilbert class field over $K$ equals the class number:*
$$[H:K] = h_K.$$

This is the arithmetic heart of the theory made tangible. The size of the most efficient abelian enlargement of $K$ is dictated by a single integer measuring how far $K$ is from unique factorization. And it has an immediate, satisfying corollary:

**Corollary (Class number one).** *If $h_K = 1$, then $[H:K]=1$; that is, $K$ is its own Hilbert class field.*

In plain terms: a number field with unique factorization admits no nontrivial unramified abelian enlargement. There is nothing to build — the field is already complete in this sense. This dovetails perfectly with the ordinary rationals: $\mathbb{Q}$ has class number one, its Hilbert class field is $\mathbb{Q}$ itself, and indeed $[\mathbb{Q}:\mathbb{Q}]=1$. The general theorem contains this basic sanity check as a special case, confirming the statements are not empty formalities but genuinely describe reality.

## Why this matters

There is a unifying thread here that reaches far beyond number theory's inner sanctum. Time and again, mathematics discovers that a hard, structural question ("what are all the symmetric extensions of this field?") is secretly controlled by a soft, countable invariant ("how do coprime remainders behave?", "how badly does factorization fail?"). Reciprocity laws are the bridges that carry us across this divide, and they are the ancestors of the sprawling modern edifice known as the Langlands program — a web of conjectures proposing that such bridges exist in vast generality, linking symmetry groups to objects from analysis and geometry.

The results assembled here are the first, load-bearing rungs of that ladder in the setting of Hilbert's twelfth problem. The cyclotomic degree $\varphi(n)$ and the prime-case cyclicity are the numerical fingerprints of reciprocity over $\mathbb{Q}$; the equation $[H:K]=h_K$ is its shadow one level up, over an arbitrary number field. Each is a place where an abstract isomorphism has been sharpened into an exact, computable integer.

Roots of unity taught us to divide the circle. The class number teaches us to measure the arithmetic of a field. Hilbert's twelfth problem is the century-long project of learning to build every abelian world from such simple, explicit ingredients — and these theorems mark honest, hard-won progress along that road.
