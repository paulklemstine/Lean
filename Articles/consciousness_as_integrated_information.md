# Consciousness as Integrated Information: A Mathematics of What Cannot Be Cut Apart

## The weakest seam

Imagine a choir singing a chord. If half the singers can leave while the other half continues unchanged, the sound may be rich, but its organization is separable. Now imagine a tightly coordinated ensemble in which every voice changes what every other voice can do. To divide that ensemble is not merely to make it smaller; it is to destroy something carried by the whole.

This contrast motivates a mathematical question often associated with theories of consciousness: how much causal organization survives only because a system is whole? The mathematics developed here does not claim that a number, by itself, settles what consciousness is. Instead, it isolates a precise finite model of *integrated information*: measure the damage caused by every admissible way of cutting a causal system, then judge the system by its least damaging cut.

The emphasis on the least damaging cut is crucial. A chain is only as strong as its weakest link. Likewise, a network is not highly integrated merely because some partitions are devastating. If even one admissible partition separates it almost harmlessly, the whole is only weakly bound together. This leads to a simple but powerful minimization principle.

## Causal structures and cut loss

A **finite causal structure** consists of two ingredients:

1. a finite, nonempty collection $C$ of admissible cuts; and
2. a loss function $L:C\to\mathbb{R}_{\ge 0}$.

For a cut $c\in C$, the number $L(c)$ represents the causal information destroyed by making that intervention. Nonnegativity says that cutting cannot have negative informational cost in this model.

The structure's integrated information is

$$
\Phi(S)=\min_{c\in C}L(c).
$$

Thus $\Phi(S)$ is the loss at the easiest place to split the system. If the losses are $3.2$, $1.4$, and $2.7$, then $\Phi(S)=1.4$. The decisive cut is not the most spectacular intervention but the least destructive one.

Because $C$ is finite and nonempty, this minimum is not a merely hypothetical lower bound. The **Minimum-Cut Attainment Theorem** says that there is an admissible cut $c_*$ satisfying

$$
L(c_*)=\Phi(S).
$$

Moreover, $\Phi(S)\le L(c)$ for every cut $c$. Conversely, if a number $a$ is no larger than every cut loss, then $a\le\Phi(S)$. In other words, $\Phi(S)$ is exactly the greatest common lower bound of the entire loss landscape.

Two immediate consequences give the quantity its basic interpretation. First, $\Phi(S)\ge 0$. Second, the **Zero-Integration Criterion** states

$$
\Phi(S)=0
\quad\Longleftrightarrow\quad
\text{some admissible cut has zero loss}.
$$

So zero integrated information is equivalent to exact reducibility: there is a seam along which the system can be split without destroying any causal information. If every admissible cut has positive cost, then the structure is irreducible in this finite sense.

The proof is transparent. If $\Phi(S)=0$, a minimizing cut attains that value. Conversely, if some cut has loss $0$, then the minimum is at most $0$; nonnegativity forces it to equal $0$.

## Independent systems add

What happens when two systems operate in parallel without interacting? Let $S$ have cut set $C_S$ and loss $L_S$, and let $T$ have cut set $C_T$ and loss $L_T$. A cut of the parallel composite is a pair $(s,t)\in C_S\times C_T$, and independence is represented by additive loss:

$$
L_{S\otimes T}(s,t)=L_S(s)+L_T(t).
$$

The **Parallel Composition Theorem** states

$$
\Phi(S\otimes T)=\Phi(S)+\Phi(T).
$$

This is more than convenient arithmetic. It says that the proposed measure respects a natural operation on independent causal systems. To see why, select minimizing cuts $s_*$ and $t_*$. Their paired loss is $\Phi(S)+\Phi(T)$, so the composite minimum can be no larger. On the other hand, every paired cut obeys

$$
L_S(s)+L_T(t)\ge\Phi(S)+\Phi(T),
$$

so the composite minimum can be no smaller. The two bounds meet.

For example, suppose one subsystem has losses $[2,5]$ and another has losses $[1,4,3]$. Their parallel composite has all pairwise sums:

$$
[3,6,5,6,9,8].
$$

Its minimum is $3$, exactly $2+1$. The theorem works for every finite nonempty loss landscape, not just this example.

The independence assumption matters. If cross-system interactions change the cost of paired cuts, additivity need not survive. This boundary is scientifically useful: deviations from additivity can signal that a purported composite is not truly independent.

## Refinement as a comparison of causal descriptions

A model of a system can be made coarser, finer, or translated into another model. To compare such descriptions, define a **causal refinement from $S$ to $T$** as a map $f:C_T\to C_S$ such that

$$
L_S(f(c))\le L_T(c)
$$

for every cut $c$ of $T$. Each cut in $T$ is represented by a cut in $S$ whose loss is no greater.

Refinements behave like arrows. Every system has an identity refinement, which maps each cut to itself. If $R$ refines $S$ and $S$ refines $T$, the two cut maps compose; the corresponding loss inequalities compose as well. This creates a category-like calculus of causal descriptions.

The central numerical result is the **Refinement Monotonicity Theorem**:

$$
S\longrightarrow T
\quad\Longrightarrow\quad
\Phi(S)\le\Phi(T).
$$

Choose a minimizing cut $c_*$ in $T$. The translated cut $f(c_*)$ is available in $S$, so

$$
\Phi(S)\le L_S(f(c_*))\le L_T(c_*)=\Phi(T).
$$

For two composable refinements $R\to S\to T$, it follows that

$$
\Phi(R)\le\Phi(S)\le\Phi(T),
$$

and hence $\Phi(R)\le\Phi(T)$. Integrated information therefore acts as an order-valued invariant: it converts structured causal comparison into ordinary numerical comparison.

## Exclusion: choosing one complex from many

A larger network may contain many candidate complexes: overlapping regions, different scales, or alternative boundaries. Suppose a finite nonempty index set $I$ labels causal structures $S_i$. Define the family's **exclusion value** by

$$
\widehat{\Phi}=\max_{i\in I}\Phi(S_i).
$$

The **Exclusion Theorem** guarantees a winner: some $i_*\in I$ satisfies

$$
\Phi(S_{i_*})=\widehat{\Phi}.
$$

Every candidate obeys $\Phi(S_i)\le\widehat{\Phi}$. Conversely, any number $a$ that bounds every candidate from above also bounds the exclusion value: if $\Phi(S_i)\le a$ for all $i$, then $\widehat{\Phi}\le a$. Thus the exclusion value is exactly the least upper bound of the finite candidate landscape.

Existence does not imply uniqueness. If two candidates tie, both realize the maximum. But the **Unique Exclusion Theorem** gives a sharp condition: if one candidate $w$ strictly exceeds every other candidate,

$$
\Phi(S_i)<\Phi(S_w)\qquad\text{for all }i\ne w,
$$

then any candidate realizing $\widehat{\Phi}$ must be $w$. A strict summit in the landscape produces a unique selected complex.

Consider candidates with integrated-information values $1.1$, $2.8$, $2.2$, and $1.9$. The exclusion value is $2.8$, and the second candidate wins uniquely. If the list were $1.1$, $2.8$, $2.8$, and $1.9$, exclusion would still have value $2.8$, but the basic rule alone would not choose between the tied candidates. That distinction separates the existence of a maximum from the additional assumptions needed for a unique boundary.

## The combinatorial horizon

The definitions are finite, but exhaustive search can become expensive. For a mechanism with $n$ elements, every subset is a potential side of a cut. There are $2^n$ subsets in total. Restricting to subsets that are nonempty and not the whole mechanism can only reduce the count. Therefore the **Cut-Count Bound** states

$$
N_{\mathrm{nontrivial}}(n)\le 2^n.
$$

The proof is simply that the nontrivial cuts form a filtered subcollection of the power set. Yet the bound carries an important computational warning: doubling the number of elements can roughly square the search space. An exhaustive algorithm that evaluates every represented cut uses $O(2^n)$ loss evaluations in the worst case, followed by a minimum scan.

There are refinements to this count. A subset and its complement often represent the same unordered bipartition, and symmetries may identify further duplicates. But the bound captures the fundamental exponential horizon facing direct computation.

## What the model says—and what it does not

This framework extracts a clean mathematical spine from integrated-information thinking. It establishes five linked ideas:

- integration is the minimum loss over admissible cuts;
- zero integration is exactly the existence of a lossless cut;
- independent parallel composition makes integration additive;
- refinement makes integration monotone; and
- exclusion is finite maximization, with uniqueness under strict dominance.

These conclusions apply to any finite nonempty family of cuts carrying nonnegative real losses. That generality is both a strength and a limitation. It makes the theorems robust, but it leaves open how losses should be derived from actual dynamics. A neural circuit, gene-regulatory network, distributed computer, or social coordination system needs a causal semantics: interventions, transition probabilities, repertoires of effects, and a divergence or distance that quantifies what a cut destroys.

The framework should therefore be read as a scaffold, not a verdict about consciousness. It tells us what follows once a finite causal loss landscape has been specified. It does not assert that every conscious feature is captured by $\Phi$, that a high value is sufficient for experience, or that one particular empirical loss function is correct.

Still, abstraction has value. The same mathematics links several worlds. In network science, $\Phi$ resembles a minimum cut objective. In optimization, exclusion is an outer maximization wrapped around inner minimizations. In category theory, refinements are composable arrows and $\Phi$ is a monotone numerical invariant. In complexity theory, the power set bound explains why exact searches rapidly become costly.

The next frontier is to replace abstract losses with probabilistic causal models and then ask harder questions. How stable is $\Phi$ when measurements are noisy? When do interacting composites become subadditive or superadditive? Can branch-and-bound or symmetry reduction avoid exhaustive enumeration? When several candidates tie, which causal equivalences should identify them?

The guiding image remains simple. A complex system presents many possible seams. We test each seam, record what causal organization would be lost, and look for the gentlest rupture. The number $\Phi$ is the cost of that weakest rupture. It does not describe every feature of the whole, but it makes one profound intuition exact: what is genuinely integrated is what no admissible cut can remove for free.
