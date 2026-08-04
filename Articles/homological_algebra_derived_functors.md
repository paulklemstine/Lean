# The Ghost in the Tensor Product

## How two "correction terms" — Ext and Tor — measure everything that goes wrong in algebra

### A subtraction problem that isn't

Here is an innocent-looking computation. Take the integers $\mathbb{Z}$ and multiply them by $2$. The map
$$\mu_2 : \mathbb{Z} \to \mathbb{Z}, \qquad n \mapsto 2n$$
is injective: no two integers get squashed together. Nothing is lost.

Now do something that ought to be harmless. Reduce everything modulo $2$ — that is, apply the operation $-\otimes \mathbb{Z}/2$, which takes an abelian group $A$ and forms $A \otimes \mathbb{Z}/2 \cong A/2A$. The map $\mu_2$ becomes a map
$$\mathbb{Z}/2 \to \mathbb{Z}/2 .$$
What map? It is multiplication by $2$ on $\mathbb{Z}/2$, which is the **zero map**. The element $1 \in \mathbb{Z}/2$ is now in the kernel. Injectivity has evaporated.

Something was destroyed by a process that only ever adds relations, never removes elements. Where did the lost injectivity *go*?

The answer, discovered in the 1940s and 1950s and now one of the load-bearing pillars of modern algebra, geometry, and topology, is that it did not go anywhere. It became a group. It became
$$\operatorname{Tor}_1(\mathbb{Z}/2, \mathbb{Z}/2) \cong \mathbb{Z}/2 \neq 0 .$$
The failure is not an accident to be apologised for. It is a *measurement*, and the measurement is functorial, computable, and obeys exact laws.

This article is about that measurement and its twin. The two functors $\operatorname{Ext}$ and $\operatorname{Tor}$ are the universal bookkeepers of failure in algebra: $\operatorname{Tor}$ records what tensoring breaks, $\operatorname{Ext}$ records what taking homomorphisms breaks. We will compute both completely for abelian groups, and see them force their way into topology through the Universal Coefficient Theorem.

---

## Part I: Resolutions, or how to approximate a bad object by good ones

An abelian group is the same thing as a module over the ring $\mathbb{Z}$, and we will use the two words interchangeably. Some abelian groups are *good* in a precise technical sense.

A module $P$ is **projective** if every surjection onto it splits — informally, $P$ is so free of internal relations that any map into a quotient can be lifted. Over $\mathbb{Z}$, projective is the same as free, so $\mathbb{Z}$, $\mathbb{Z}^n$, and $\bigoplus_{i \in I}\mathbb{Z}$ are the projective abelian groups. Dually, a module $I$ is **injective** if maps *into* it always extend along inclusions. Over $\mathbb{Z}$, injective is the same as *divisible*: every element has an $n$-th "multiple root" for all $n \ge 1$. So $\mathbb{Q}$ and $\mathbb{Q}/\mathbb{Z}$ are injective; $\mathbb{Z}$ itself emphatically is not, since $1$ is not divisible by $2$ inside $\mathbb{Z}$.

The bad object $\mathbb{Z}/k$ is neither projective nor injective. But it can be *resolved*: written as the last term of a complex of good objects. The star of this story is the shortest such resolution imaginable.

> **The free resolution of a cyclic group.** For $k \neq 0$ the sequence
> $$0 \longrightarrow \mathbb{Z} \xrightarrow{\;\cdot k\;} \mathbb{Z} \xrightarrow{\;\bmod k\;} \mathbb{Z}/k \longrightarrow 0$$
> is exact: multiplication by $k$ is injective, reduction mod $k$ is surjective, and an integer reduces to $0$ exactly when it is a multiple of $k$.

Two free groups, one differential, and we have completely captured $\mathbb{Z}/k$. Its mirror image handles $\mathbb{Z}$:

> **The injective resolution of $\mathbb{Z}$.** The sequence
> $$0 \longrightarrow \mathbb{Z} \hookrightarrow \mathbb{Q} \longrightarrow \mathbb{Q}/\mathbb{Z} \longrightarrow 0$$
> is exact, and $\mathbb{Q}$ and $\mathbb{Q}/\mathbb{Z}$ are both divisible, hence injective.

The **derived functors** are obtained by a fixed recipe: to compute $\operatorname{Ext}^n(X,Y)$, replace $X$ by a projective resolution, apply $\operatorname{Hom}(-,Y)$ to the resolution (throwing $X$ itself away), and take cohomology. To compute $\operatorname{Tor}_n(G,M)$, replace $M$ by a projective resolution, tensor with $G$, and take homology. Degree $0$ recovers the original functor — $\operatorname{Tor}_0(G,M) \cong G \otimes M$ — and the higher degrees are the correction terms.

Now the punchline of Part I. If a resolution *stops* after one step, then so do the derived functors, because after the second stage there is nothing left to apply the functor to.

> **Cyclic groups have projective dimension one.** For $k \neq 0$ and any abelian group $Y$,
> $$\operatorname{Ext}^{n}(\mathbb{Z}/k, Y) = 0 \quad \text{for all } n \geq 2 .$$

> **$\mathbb{Z}$ has injective dimension one.** For any abelian group $X$,
> $$\operatorname{Ext}^{n}(X, \mathbb{Z}) = 0 \quad \text{for all } n \geq 2 .$$

> **Higher Tor against cyclic groups vanishes.** For $k \neq 0$ and any abelian group $G$,
> $$\operatorname{Tor}_{n}(G, \mathbb{Z}/k) = 0 \quad \text{for all } n \geq 2 .$$

These are not isolated curiosities. They are the first evidence for a structural fact: **$\mathbb{Z}$ is a hereditary ring**, and over a hereditary ring the entire infinite tower of derived functors collapses into degrees $0$ and $1$. Homological algebra over the integers is a two-storey building.

We can push the collapse to a very large class of groups at once. Every finitely generated abelian group $X$ admits a surjection $\mathbb{Z}^m \twoheadrightarrow X$; the kernel $K$ is a subgroup of a finitely generated free group over a principal ideal domain, and is therefore itself free. So $X$ has a two-step free presentation $0 \to K \to \mathbb{Z}^m \to X \to 0$.

> **Vanishing for finitely generated groups.** If $X$ is a finitely generated abelian group, then for every abelian group $Y$,
> $$\operatorname{Ext}^{n}(X,Y) = 0 \quad \text{for all } n \geq 2 .$$

More abstractly, the same argument shows: whenever $X$ fits in a short exact sequence $0 \to P_1 \to P_0 \to X \to 0$ with $P_0, P_1$ projective, all $\operatorname{Ext}^{n}(X,-)$ vanish for $n \ge 2$.

---

## Part II: The long exact sequence, the engine room

Everything above is powered by a single machine. Suppose you have a short exact sequence of chain complexes
$$0 \to C_\bullet' \to C_\bullet \to C_\bullet'' \to 0 .$$
Homology is not exact — that is the whole problem — but the failure is perfectly organised into an infinite staircase:
$$\cdots \to H_n(C') \to H_n(C) \to H_n(C'') \xrightarrow{\;\partial\;} H_{n-1}(C') \to H_{n-1}(C) \to \cdots$$
which is exact at every spot. The mysterious map $\partial$, the **connecting homomorphism**, is built by the "diagram chase" every algebraist learns once and never forgets: lift a cycle from $C''$ to $C$, take its boundary, observe that it comes from $C'$.

The three local exactness statements — at $H_n(C)$, at $H_n(C'')$, and at $H_{n-1}(C')$ — are what one actually uses, and they have immediate, sharp consequences:

- If $C'$ and $C''$ are both acyclic in degree $n$, so is $C$. (Sandwiched between two zeros.)
- If $C$ is acyclic in two adjacent degrees, the connecting map $\partial : H_n(C'') \to H_{n-1}(C')$ is a **bijection** — the entire homology of the quotient is a shifted copy of the homology of the subcomplex.
- If $H_{n-1}(C'')$ vanishes, the map $H_n(C') \to H_n(C)$ is injective; if $H_{n+1}(C')$ vanishes, $H_n(C) \to H_n(C'')$ is surjective.

For $\operatorname{Ext}$ there are two such staircases, one in each variable. Given $0 \to A \to B \to C \to 0$ and a fixed $Y$:
$$\cdots \to \operatorname{Ext}^n(C,Y) \to \operatorname{Ext}^n(B,Y) \to \operatorname{Ext}^n(A,Y) \to \operatorname{Ext}^{n+1}(C,Y) \to \cdots$$
and dually in the second variable. Feed the resolution $0 \to \mathbb{Z} \to \mathbb{Z} \to \mathbb{Z}/k \to 0$ into this and observe that $\operatorname{Ext}^{n}(\mathbb{Z}, Y) = 0$ for all $n \geq 1$ because $\mathbb{Z}$ is projective: the staircase pinches shut, and the vanishing theorems of Part I fall out.

---

## Part III: $\operatorname{Ext}^1$ is an obstruction group — and you can hold it in your hand

The vanishing theorems say what *isn't* there. The interesting content is degree one. Here is the complete answer for cyclic groups.

> **Computation of the first Ext group.** For $k \neq 0$ and any abelian group $Y$,
> $$\operatorname{Ext}^1(\mathbb{Z}/k, Y) \;\cong\; Y/kY .$$

The isomorphism is not abstract nonsense; it is an explicit formula. The short exact sequence $0 \to \mathbb{Z} \to \mathbb{Z} \to \mathbb{Z}/k \to 0$ has its own class $\varepsilon \in \operatorname{Ext}^1(\mathbb{Z}/k,\mathbb{Z})$. Each element $y \in Y$ determines a homomorphism $\mathbb{Z}\to Y$, $1 \mapsto y$, and pushing $\varepsilon$ forward along it gives a class $\varepsilon_y \in \operatorname{Ext}^1(\mathbb{Z}/k, Y)$. The assignment $y \mapsto \varepsilon_y$ is a group homomorphism; it is **surjective** (every class comes from an element), and its **kernel is exactly $kY$**. Quotient, and you have the isomorphism.

Read the formula slowly and it starts telling you things.

> **Ext detects divisibility.** For $k \neq 0$, $\operatorname{Ext}^1(\mathbb{Z}/k, Y) = 0$ if and only if $Y$ is $k$-divisible, i.e. every $y \in Y$ is of the form $kz$.

Two instances, both immediate:

- $\operatorname{Ext}^1(\mathbb{Z}/k, \mathbb{Q}) = 0$, since one can always divide a rational number by $k$. Interpretation: **every extension of $\mathbb{Z}/k$ by $\mathbb{Q}$ splits.** There is no interesting abelian group containing $\mathbb{Q}$ with cyclic quotient other than $\mathbb{Q}\oplus\mathbb{Z}/k$.
- $\operatorname{Ext}^1(\mathbb{Z}/k, \mathbb{Z}) \cong \mathbb{Z}/k$, which is nonzero for $k \geq 2$. Interpretation: **the extension $0 \to \mathbb{Z} \xrightarrow{\cdot k} \mathbb{Z} \to \mathbb{Z}/k \to 0$ does not split** — and if it did, $1 \in \mathbb{Z}$ would be divisible by $k$ inside $\mathbb{Z}$, which is absurd. This is the primal example. $\operatorname{Ext}^1$ has just detected, in group-theoretic language, that you cannot divide $1$ by $2$ in the integers.

This is what "$\operatorname{Ext}$" is short for: **ext**ensions. $\operatorname{Ext}^1(C,A)$ classifies, up to equivalence, all the ways of fitting $A$ and $C$ into a short exact sequence $0 \to A \to B \to C \to 0$, with the zero class corresponding to the boring direct sum. It is the obstruction group for a splitting problem.

---

## Part IV: Flatness, or which groups are safe to tensor with

Now the other side. Tensoring $-\otimes G$ always preserves surjections but may destroy injections, as our opening example showed. Groups for which nothing is destroyed are called **flat**.

Flatness looks like an infinite condition — a statement about *every* injection. Homological algebra reduces it to a single, finite-flavoured test.

> **The flatness criterion for abelian groups.** For an abelian group $G$, the following are equivalent:
> 1. $G$ is flat;
> 2. $G$ is torsion-free: $kg = 0$ with $k \neq 0$ forces $g = 0$;
> 3. multiplication by $k$ is injective on $G$ for every $k \neq 0$;
> 4. $\operatorname{Tor}_1(G, \mathbb{Z}/k) = 0$ for every $k \neq 0$;
> 5. $\operatorname{Tor}_n(G, M) = 0$ for every $n \geq 1$ and every abelian group $M$.

The chain of implications is a small masterpiece of efficiency. That (1) $\Rightarrow$ (5) is the general theorem *higher Tor against a flat module vanishes*: tensoring with a flat module is exact, hence commutes with taking homology, and a projective resolution has no homology in positive degrees, so nothing survives. That (5) $\Rightarrow$ (4) is trivial. That (4) $\Rightarrow$ (3) $\Rightarrow$ (2) $\Rightarrow$ (1) uses the key computation:

> **The first Tor group against a cyclic group is torsion.** For any abelian group $G$ and any $k$,
> $$\operatorname{Tor}_1(G, \mathbb{Z}/k) \;\cong\; G[k] := \{\, g \in G : kg = 0 \,\},$$
> while in degree zero $G \otimes \mathbb{Z}/k \cong G/kG$.

There is the whole picture in one line: **$\operatorname{Tor}$ is named after torsion because it *is* torsion.** Tensor with $\mathbb{Z}/k$ and you get a quotient, $G/kG$; the correction term is the sub, $G[k]$. The two extreme phenomena of a group — what dies under multiplication by $k$, and what is not hit by it — are exactly the two derived functors in degrees $1$ and $0$.

And the opening puzzle resolves itself. Taking $G = \mathbb{Z}/2$:
$$\operatorname{Tor}_1(\mathbb{Z}/2,\mathbb{Z}/2) \cong (\mathbb{Z}/2)[2] = \mathbb{Z}/2 \neq 0 .$$
The lost injectivity became the $2$-torsion of $\mathbb{Z}/2$. More generally $\operatorname{Tor}_1(\mathbb{Z}/k,\mathbb{Z}/k) \cong \mathbb{Z}/k$, so **$\mathbb{Z}/k$ is not flat for $k \ge 2$** — cyclic groups are exactly the standard counterexamples, and $\operatorname{Tor}$ says precisely how badly they fail.

---

## Part V: The Universal Coefficient Theorem, or why topologists care

Suppose you are a topologist who has computed the integral homology $H_n(X;\mathbb{Z})$ of a space, and someone asks for its homology with coefficients in $\mathbb{Z}/2$ — often much easier to compute with, and better adapted to certain geometric questions. Homology with coefficients in $G$ means: take the chain complex $C_\bullet$ of the space, tensor it with $G$, and take homology of $G \otimes C_\bullet$.

The naive hope is $H_n(G \otimes C) \cong G \otimes H_n(C)$: homology and tensoring commute. When is the hope correct? Precisely when nothing is broken — that is, when $G$ is flat.

> **Universal coefficients, flat case.** If $G$ is a flat module, then for every complex $C$ and every degree $n$,
> $$H_n(G \otimes C) \;\cong\; G \otimes H_n(C) .$$
> In particular, tensoring with a flat module preserves acyclicity.

The proof is a one-liner once you have the right concept: tensoring with a flat module is an exact functor, and exact functors commute with homology. Over $\mathbb{Z}$ this covers $G = \mathbb{Q}$, $G = \mathbb{R}$, and all torsion-free coefficients — which is why rational homology is so much simpler than integral homology, and why one hardly ever hears about Tor terms in the rational setting.

For non-flat $G$ the hope is false, and the failure is again a measurement:
$$0 \longrightarrow G \otimes H_n(C) \longrightarrow H_n(G \otimes C) \longrightarrow \operatorname{Tor}_1\!\big(G, H_{n-1}(C)\big) \longrightarrow 0 .$$
Homology with coefficients has two layers: the expected part in degree $n$, and a ghost of degree $n-1$ that arrived via $\operatorname{Tor}$.

Both layers can be exhibited in isolation, and the smallest possible example does it. Let $C$ be the two-term complex of free groups
$$C : \quad \cdots \to 0 \to \underbrace{\mathbb{Z}}_{\text{degree }1} \xrightarrow{\;\cdot k\;} \underbrace{\mathbb{Z}}_{\text{degree }0},$$
so that $H_0(C) = \mathbb{Z}/k$ and $H_1(C) = 0$. Then for any coefficient group $G$:

> **Degree zero.** There is no homology in degree $-1$, so the $\operatorname{Tor}$-term is absent and
> $$H_0(G \otimes C) \;\cong\; G \otimes H_0(C) \;\cong\; G/kG .$$
> **Degree one.** Here $H_1(C) = 0$, so the tensor term is absent, and the *entire* homology group is the correction term:
> $$H_1(G \otimes C) \;\cong\; \operatorname{Tor}_1\!\big(G, H_0(C)\big) \;\cong\; G[k] .$$

Take $G = \mathbb{Z}/k$ with $k \ge 2$. The complex $C$ is exact in degree $1$ — multiplication by $k$ is injective on $\mathbb{Z}$. After tensoring with $\mathbb{Z}/k$ the complex is **no longer exact in degree one**, and the surviving class is exactly the nonzero element of $\operatorname{Tor}_1(\mathbb{Z}/k,\mathbb{Z}/k) \cong \mathbb{Z}/k$. The correction term is not a bookkeeping convenience. It is a genuine, nonzero, *visible* homology class, and if you drop it from the Universal Coefficient Theorem the theorem becomes false.

This is why, when a topologist computes the mod-$2$ homology of the real projective plane $\mathbb{RP}^2$ and finds a class in degree $2$ that has no integral counterpart, the class is not an error. Its integral homology is $H_0 = \mathbb{Z}$, $H_1 = \mathbb{Z}/2$, $H_2 = 0$; but $H_2(\mathbb{RP}^2;\mathbb{Z}/2) \cong \operatorname{Tor}_1(\mathbb{Z}/2, \mathbb{Z}/2) \cong \mathbb{Z}/2$. The extra class is the $2$-torsion of $H_1$, reappearing one degree up. $\operatorname{Tor}$ predicted it exactly.

---

## Coda: failure as a functor

The intellectual move at the heart of this subject is worth stating baldly, because it recurs everywhere in twentieth-century mathematics. Faced with an operation that *almost* preserves a structure, do not shrug and add a caveat. Instead, name the discrepancy, prove that it is functorial, and study it as an object in its own right.

Do that here and you get a complete two-storey theory of abelian groups: everything is controlled by degrees $0$ and $1$, where $\operatorname{Tor}$ splits any group into its torsion $G[k]$ and its cotorsion $G/kG$, and $\operatorname{Ext}$ splits it into its divisible and non-divisible parts through $Y/kY$. The same move gives sheaf cohomology in algebraic geometry (the failure of global sections to be exact), group cohomology in number theory (the failure of invariants to be exact), and the derived category, which takes the philosophy to its logical conclusion by declaring that a module *is* its resolution.

The subtraction problem we opened with had no answer inside the world of abelian groups. It had an answer one level up. That, in the end, is the whole story: some questions can only be answered by enlarging the category of things that count as answers.
