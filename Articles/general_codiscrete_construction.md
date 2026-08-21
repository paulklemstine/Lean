# The Arithmetic of Broken Rules

## How a bookkeeping trick turns algebraic chaos into perfect coherence — and how to count exactly what was broken

### A multiplication that does not care

Almost every multiplication you have ever met obeys the associative law: $(a\cdot b)\cdot c = a\cdot(b\cdot c)$. Adding numbers, multiplying matrices, composing functions, concatenating strings — all associative. The law is so ubiquitous that it is easy to forget it is a *law*, an extra assumption, and not a fact of nature.

Plenty of natural operations break it. Subtraction: $(5-3)-1 = 1$ but $5-(3-1)=3$. Exponentiation: $(2^2)^3 = 64$ while $2^{(2^3)} = 256$. The cross product of vectors, the commutator of matrices, the "average" $a\ast b = (a+b)/2$, the octonions, the moves of a Rubik's-cube solver who sometimes forgets which sub-sequence he grouped — none of these are associative. In combinatorics one meets finite multiplication tables produced by search, by random generation, or by a physical process, and there is no reason for such a table to obey any law at all.

The most permissive structure of all is a **magma**: a set $M$ with *any* binary operation $\ast : M\times M \to M$. Not a single axiom. If we also fix a distinguished element $1 \in M$ — not assumed to do anything, just chosen — we get a **pointed magma**. A multiplication table with one row circled. That is the raw material of this article.

Two questions organise everything that follows.

1. **Can a lawless multiplication be repaired?** Not by changing it, but by adding a layer of structure in which the failures of the law become legitimate, controlled, invertible *transformations*.
2. **How badly broken is a given table?** Can we measure the failure with a number, and how large can that number possibly be?

The answers turn out to fit together. The first question has an answer that is almost embarrassingly complete: *every* pointed magma can be repaired, canonically, with no hypotheses whatsoever, and the repair is automatically coherent. The second question has a sharp combinatorial answer: the maximum possible breakage of a table with $n$ entries and a genuine unit is exactly $(n-1)^3$, and this is attained. And the bridge between them is an exact equality: the number that measures breakage is the number of genuinely non-trivial transformations the repair has to supply.

---

### Repair by promotion: from equations to arrows

Here is the idea in one sentence: **when an equation refuses to hold, stop demanding equality and supply an arrow instead.**

This move is one of the great organising principles of modern mathematics. In topology, two loops are rarely *equal*, but they can be *homotopic*, and the homotopy is a thing in its own right, with its own life. In category theory, two functors are rarely equal, but they can be *naturally isomorphic*. The pattern is called **categorification**: replace an assertion of equality by a specified isomorphism, and then ask that these isomorphisms fit together consistently.

For a magma, the plan is as follows. Build a world with a single point $\star$. The *arrows* from $\star$ to itself will be the elements of $M$; composing the arrow named $a$ with the arrow named $b$ means multiplying, giving the arrow named $a\ast b$; and the arrow named $1$ plays the role of the identity. So far this is the classical dictionary between monoids and one-object categories — except that our multiplication does not satisfy the axioms a category demands, so this is not yet a category.

The trick is to add one more level. Between two arrows we allow *2-arrows*, and we make the choice that looks like cheating and turns out to be exactly right: **between any two arrows there is exactly one 2-arrow.** This is the *codiscrete* (or *indiscrete*, or *chaotic*) structure: total connectivity, zero information. Everything is uniquely isomorphic to everything.

Now the failure of associativity is not a failure. The arrows $(a\ast b)\ast c$ and $a\ast(b\ast c)$ may well be different arrows, but there is a canonical 2-arrow between them:
$$\alpha_{a,b,c} : (a\ast b)\ast c \;\xrightarrow{\ \sim\ }\; a\ast(b\ast c),$$
and it is invertible, because its inverse is the unique 2-arrow going the other way. The same for the unit: even if $1\ast a \neq a$, there is a canonical invertible
$$\lambda_a : 1\ast a \xrightarrow{\ \sim\ } a, \qquad \rho_a : a\ast 1 \xrightarrow{\ \sim\ } a .$$

A structure of exactly this shape — one object, arrows, invertible 2-arrows repairing associativity and units — is called a **bicategory**, and bicategories are the standard home for "associative up to specified isomorphism". Monoidal categories, spans, bimodules, and the 2-category of categories all live there.

### The coherence problem, and why it evaporates

There is a catch to categorification, and it is the serious part of the theory. Once associativity is repaired by an isomorphism rather than an equation, one must ask whether the repairs are *consistent*. Re-bracketing a product of four elements can be done along two different routes through five bracketings; the resulting composite isomorphisms must agree. That requirement is Mac Lane's **pentagon axiom**. A similar compatibility between the associator and the unitors is the **triangle axiom**. In general these are real conditions: they can fail, and verifying them for a proposed structure is genuine work. Mac Lane's coherence theorem says that if the pentagon and the triangle hold, then *all* diagrams built from associators and unitors commute — a spectacular payoff for two axioms.

In our construction the axioms are free. Both sides of the pentagon are 2-arrows between the same pair of arrows, and in a codiscrete world there is only one such 2-arrow. So the two sides are equal because there is nothing else they could be. The same argument disposes of the triangle, and of every other coherence condition that might ever be demanded.

We can now state the first main theorem.

> **Theorem (Codiscrete repair).** Let $M$ be a set with an arbitrary binary operation $\ast$ and an arbitrary distinguished element $1$. Then there is a bicategory $\mathcal{B}(M)$ with a single object, whose arrows are the elements of $M$ with horizontal composition $\ast$ and identity $1$, and whose 2-arrows are given by the codiscrete structure: exactly one 2-arrow between any two arrows. All of its 2-arrows are invertible, any two parallel 2-arrows are equal, and the associator and unitors satisfy every coherence law automatically.

No hypotheses. Total breakage is no obstacle at all.

### Is this cheating?

The natural objection: if coherence comes for free, has anything been achieved, or have we merely thrown the information away?

The honest answer is *both*, and the interesting content of the theory is precisely the boundary between the two. Four results mark that boundary.

**First: the repair is genuinely needed exactly when the algebra is broken.** A bicategory is called *strict* — a 2-category — when the associator and unitors are identities rather than merely isomorphisms, i.e. when the equations really do hold on the nose.

> **Theorem (Strictness criterion).** $\mathcal{B}(M)$ is strict if and only if $M$ is a monoid: $(a\ast b)\ast c = a\ast(b\ast c)$ for all $a,b,c$, and $1\ast a = a = a \ast 1$ for all $a$.

So weakness is not an artefact of the encoding. If your table has a single associativity failure, the resulting bicategory is provably not strict; if your table is a monoid, the construction reproduces the classical one-object 2-category and nothing more.

**Second: at the 2-arrow level, invertibility becomes free.** In a bicategory, an arrow $f$ is an *equivalence* if there is $g$ with $f\ast g$ and $g \ast f$ merely *isomorphic* to identities. In $\mathcal{B}(M)$ this is automatic and dramatically so: for *any* two elements $a$ and $b$ of $M$, with no relation between them at all, the arrows they name form an adjoint equivalence. Every element is invertible up to 2-arrows, and every element is an inverse of every element.

**Third: at the arrow level, the algebra survives intact.** Ask for *strict* invertibility — $a \ast g = 1$ and $g\ast a = 1$ as equations — and the collapse stops dead:

> **Theorem (The arrow layer remembers).** The arrow named $a$ has a strict two-sided inverse in $\mathcal{B}(M)$ if and only if the element $a$ has a two-sided inverse in $M$.

The slogan is: **coherence is free; information is not.** Passing to 2-isomorphism classes forgets $M$ entirely — one can collapse $\mathcal{B}(M)$ onto the bicategory of the one-point magma and come back, returning every arrow to something canonically isomorphic to itself. But that round trip returns the *same arrow* only for the unit. The two levels tell complementary stories.

**Fourth: the construction is absurdly functorial.** A homomorphism between magmas must respect the operation. Between codiscrete bicategories, *any* function $f: M \to N$ whatsoever — respecting nothing — induces a structure-preserving map (a pseudofunctor) $\mathcal{B}(M) \to \mathcal{B}(N)$, because the required comparison 2-arrows $f(a\ast b) \cong f(a)\ast f(b)$ and $f(1)\cong 1$ exist uniquely and cohere automatically. Identity maps and composites are respected. And the converse pins down the classical notion: the induced pseudofunctor is *strictly* multiplicative precisely when $f$ is a homomorphism.

---

### Counting the damage

Coherence, then, is free. What is *not* free is the amount of breakage, and that can be measured exactly. For a finite magma $M$ with $n$ elements define the **associativity defect**
$$D(M) \;=\; \#\{(a,b,c)\in M^3 : (a\ast b)\ast c \neq a\ast(b\ast c)\}.$$
Out of $n^3$ triples, $D(M)$ is the number that go wrong. Clearly $D(M)=0$ exactly for semigroups.

The bridge to the first half of the story is an exact identity: *$D(M)$ is the number of triples at which the associator of $\mathcal{B}(M)$ is a non-identity 2-arrow.* The combinatorial defect and the categorical weakness are literally the same count. And for a unital magma, the bicategory is strict if and only if $D(M) = 0$.

The defect behaves well. It is unchanged by isomorphism and by reversing the multiplication ($a \ast^{\mathrm{op}} b = b \ast a$). Writing $A(M) = n^3 - D(M)$ for the number of *good* triples, the good count is **multiplicative**: $A(M\times N) = A(M)\,A(N)$, since a triple in a product is associative exactly when both of its components are. In terms of the associativity *density* $d(M) = D(M)/n^3$, this says $1-d(M\times N) = (1-d(M))(1-d(N))$ — take a product of two 90%-associative tables and you get an 81%-associative one.

How broken can a table get? If we insist only that $1$ be a genuine two-sided unit — the minimal assumption anyone would make of a "pointed" structure — then no defect triple can involve $1$: if any of $a,b,c$ equals $1$, both bracketings collapse to the same product. So the defect lives on the $(n-1)^3$ triples of non-units, giving $D(M)\le (n-1)^3$.

This bound is **sharp**, and there is a clean construction attaining it. Take any set $S$ and a self-map $\sigma : S\to S$ with no fixed point. Let $M = S \cup \{1\}$ and define
$$1 \ast x = x \ast 1 = x, \qquad a \ast b = \sigma(b) \quad (a, b \in S).$$
This is the **shift magma**. Both bracketings of a non-unit triple are easy: $(a\ast b)\ast c = \sigma(c)$, whereas $a\ast(b\ast c) = a \ast \sigma(c) = \sigma(\sigma(c))$. These differ for *every* triple, precisely because $\sigma$ has no fixed point. Hence $D = (n-1)^3$: every triple that is allowed to fail, fails. Since a fixed-point-free self-map of a set of size $m\ge 2$ always exists (a cyclic shift), the bound is attained for every $n\ge 3$.

Commutativity changes the answer, and the mechanism is a parity argument of the kind combinatorialists love. Reversal, $(a,b,c)\mapsto(c,b,a)$, maps defect triples to defect triples when $\ast$ is commutative. Its fixed points are the *palindromic* triples $(a,b,a)$ — and those are never defective, because $(a\ast b)\ast a = a\ast (b\ast a)$ is forced by commutativity alone. So reversal is a fixed-point-free involution of the defect set:

> **Theorem (Parity).** The associativity defect of a finite commutative magma is even. In particular, a commutative magma never has exactly one bad triple.

Removing the $(n-1)^2$ palindromic triples from the $(n-1)^3$ available ones gives the commutative bound $D(M)\le (n-1)^3 - (n-1)^2$, and this too is sharp. The extremal example is the **negation magma** of an abelian group $G$ with no $2$-torsion: adjoin a unit to $G$ and set $a\ast b = -(a+b)$. Then $(a\ast b)\ast c = a+b-c$ and $a\ast(b\ast c) = -a+b+c$, so the triple fails exactly when $2a \neq 2c$, i.e. exactly when $a\neq c$: every non-palindromic triple is bad. For $G = \mathbb{Z}/m$ with $m$ odd we get a commutative unital magma on $n = m+1$ elements with $D = m^3 - m^2$.

One more structural fact keeps the theory tidy: freely adjoining a unit to an arbitrary magma changes no defect at all. So the restriction to unital magmas costs nothing — every defect profile that occurs at all occurs for a unital magma.

### The view from small tables

Exhaustive enumeration of small unital tables fills in the picture and, pleasingly, punctures a plausible conjecture. Over the $4^9 = 262\,144$ unital multiplication tables on four labelled elements, exactly $84$ attain the maximum $D=27$, and exactly $84$ have $D=1$ — none of the latter commutative, exactly as the parity theorem demands. On three elements the maximum $D=8$ is attained by exactly $2$ tables and no table has $D=1$ at all. The natural guess from the three-element case — that a unital magma can never be broken in *exactly one* place — is therefore false; the honest statement is the parity theorem, which only forbids it in the commutative world.

The maximisers are also more plentiful than the shift construction alone explains: of the $84$ order-four maximisers, only eight arise as shift magmas, and sixteen if one also counts their mirror images $a\ast b = \sigma(a)$. Characterising the extremal tables in general is an appealing open problem, and the shape of the answer is suggested by the proof: maximality is a purely *local* condition — every single non-unit triple must fail — so one expects a forbidden-pattern description of the extremal tables rather than a global identity.

---

### Why it matters

The two halves of this story illustrate a division of labour that recurs across mathematics. Categorification is a *universal* technology: it will absorb any amount of algebraic misbehaviour, and the codiscrete construction is the extreme demonstration — no axioms in, full coherence out. But universality has a price, and the price is measured by combinatorics. The defect $D(M)$ counts, precisely and sharply, how much repair work the categorical layer is silently doing; the $(n-1)^3$ bound says how much work can possibly be needed; the parity theorem says that symmetry constrains the pattern of failures; and the arrow-level results say what the repair does not destroy.

Anyone who has worked with a non-associative operation — floating-point addition, whose failures of associativity are the daily bread of numerical analysis; the concatenation of parsed expressions; the fusion rules of a physical system known only approximately — is implicitly living in a magma with a defect. This work says: the defect never obstructs a coherent higher-categorical description, it can be counted, its maximum is known exactly, and in the presence of symmetry it obeys a parity law.

Broken rules, it turns out, have an arithmetic of their own.
