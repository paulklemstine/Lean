# When Geometry Learns to Compress: A New Law for Mathematical Data

## The Surprising Arithmetic of Shape

Imagine you're a cartographer tasked with cataloging every mountain, valley, and river on a newly discovered continent. You have a limited number of survey stations — points from which you can observe the terrain. A natural question arises: how many stations do you need to fully reconstruct the landscape?

Now suppose a second continent is discovered nearby. You need to catalog both. Common sense says you'd need roughly twice the stations — one set for each landmass. But could you do better? Could some stations, cleverly positioned, survey both continents simultaneously?

This seemingly practical question turns out to be a deep mathematical one, and answering it reveals a hidden law governing the structure of geometric data itself — a law that mirrors one of the most fundamental principles in all of science: the subadditivity of entropy.

## The Geometry of Observation

In the late 1950s, Alexander Grothendieck revolutionized mathematics by reimagining geometry. Instead of studying shapes directly, he studied them through the lens of how they could be *observed* — what data you could collect about them from different vantage points. This shift, from objects to observations, birthed the theory of **sheaves** and **sites**, arguably the most powerful framework in modern mathematics.

A **presheaf** is a rule that assigns data to each region of a space, together with instructions for how to restrict data from larger regions to smaller ones. Think of it as a complete atlas: for each patch of terrain, the presheaf tells you every possible map of that patch, and how maps of overlapping patches must agree.

A **Grothendieck topology** specifies which collections of patches constitute a "good cover" — enough local observations to reconstruct the global picture. Together, a space equipped with a topology is called a **site**, and presheaves satisfying a gluing condition (local data determines global data) are called **sheaves**.

For decades, these ideas powered revolutions in algebraic geometry, number theory, and theoretical physics. But one question remained unexplored: **How efficiently can geometric data be compressed?**

## Probes and Compression

Enter **probe complexity**, a new invariant that measures the minimum number of observation points — or *probes* — needed to distinguish all possible data on a site.

Here's the intuition. Suppose you have a presheaf $F$ on a small category (a finite site). Each object in the category can serve as a "probe": you restrict sections of $F$ to that object and examine the results. A set of probes is **separating** if it can distinguish any two distinct sections — like having enough survey stations to tell apart any two possible landscapes.

The **sheaf compression number** $\kappa_{\mathrm{sh}}$ counts the minimum number of probes needed, subject to an additional constraint: the probes must be *compatible* with the site's topology. They must respect the geometric structure of the space, not just its combinatorics.

This number behaves like a **code length** in information theory. Shannon's fundamental theorem says that any message source has a minimum description length — its entropy. The compression number is the geometric analogue: the minimum "observation budget" needed to faithfully encode geometric data.

## The Coproduct Question

In mathematics, combining two data sources is formalized through the **coproduct** — the geometric analogue of a disjoint union. Given presheaves $F$ (data about mountains) and $G$ (data about rivers), their coproduct $F \oplus G$ represents the combined data: at each observation point, you see either mountain data or river data.

The central question is then: **What happens to the compression number when data sources are combined?**

If compression numbers behaved like lengths of physical objects, you'd expect $\kappa_{\mathrm{sh}}(F \oplus G) = \kappa_{\mathrm{sh}}(F) + \kappa_{\mathrm{sh}}(G)$: combining sources just adds costs. But information doesn't work that way. Shannon showed that entropy — the information-theoretic analogue — satisfies a weaker law: **subadditivity**.

$$H(X, Y) \leq H(X) + H(Y)$$

The joint entropy of two sources never exceeds the sum of individual entropies, with equality only when the sources are completely independent. Any shared structure creates savings.

## The Breakthrough

The new theorem establishes that sheaf compression obeys this same law:

$$\kappa_{\mathrm{sh}}(J, F \oplus G) \leq \kappa_{\mathrm{sh}}(J, F) + \kappa_{\mathrm{sh}}(J, G)$$

The proof is both elegant and illuminating. It works by showing that if you have optimal probe families for $F$ and $G$ separately, their union provides a valid probe family for the coproduct. The argument splits into three cases:

1. **Same-source comparison** (both data points from $F$, or both from $G$): the original probes handle this directly.
2. **Cross-source comparison** (one from $F$, one from $G$): these are always distinguishable because they carry different "tags" — like documents printed on different-colored paper. Any probe that reaches the observation point can detect this difference.
3. **Counting**: the union of two probe families has at most as many probes as the two families combined.

The second case contains a subtle but crucial insight. To detect the cross-source difference, you need at least one probe that can *reach* the observation point — that is, there must exist a morphism from some probe to the target object. This is automatically guaranteed by topology compatibility, because every Grothendieck topology declares the maximal sieve (containing all morphisms) to be a covering family. So the topological structure of the site provides exactly the observational access needed to distinguish mixed data.

## Mutual Information for Geometry

The gap between the two sides of the inequality is itself meaningful. Define the **compression defect**:

$$I_{\mathrm{sh}}(F; G) = \kappa_{\mathrm{sh}}(F) + \kappa_{\mathrm{sh}}(G) - \kappa_{\mathrm{sh}}(F \oplus G)$$

By subadditivity, this quantity is always nonnegative. It measures the "savings" from joint compression — exactly analogous to **mutual information** in Shannon's theory.

When $I_{\mathrm{sh}}(F; G) = 0$, the presheaves are "informationally independent" — there's no redundancy between their probe structures. When $I_{\mathrm{sh}}(F; G) > 0$, shared geometric structure allows compression savings.

The theory goes further. A **jointly admissible** probe family — one that simultaneously separates both $F$ and $G$ while remaining topology-compatible — serves as a witness to redundancy. If such a family exists with fewer probes than the sum of optimal individual families, it proves strict subadditivity: the compression defect is strictly positive.

This creates a complete framework: subadditivity as a universal law, mutual information as a measure of shared structure, and jointly admissible families as certificates of redundancy.

## Why This Matters

### A new lens on data

The subadditivity theorem says something profound: **geometric data obeys information-theoretic laws**. The compression number isn't just a combinatorial curiosity — it's a genuine entropy-like measure that satisfies the same fundamental inequalities as Shannon entropy, Rényi entropy, and Kolmogorov complexity.

This opens the door to an entire **geometric information theory**: chain rules, data processing inequalities, rate-distortion theory, and capacity theorems, all translated from classical information theory into the language of sheaves and sites.

### Connections across mathematics

The result sits at a crossroads of several mathematical fields:

- **Category theory**: it shows that complexity is functorial — compatible with the fundamental operations of categorical algebra.
- **Combinatorics**: it generalizes classical results about separating families and test sets to a geometric setting.
- **Algebraic geometry**: it provides quantitative tools for understanding the cost of local-to-global reconstruction.
- **Coding theory**: it gives sheaf-theoretic analogues of source coding bounds.

### Implications for computation

In an era where data increasingly carries geometric structure — networks, sensor arrays, molecular configurations — understanding the fundamental limits of geometric compression has practical value. The compression number provides a lower bound on how much any observation scheme must invest to faithfully represent geometric data.

## The Road Ahead

The subadditivity theorem is a beginning, not an endpoint. Several tantalizing questions emerge:

**When does equality hold?** Under what conditions is the compression of a coproduct exactly the sum of component compressions? The conjecture is that equality holds precisely when optimal probe families for the two presheaves are disjoint — no shared probes contribute to both.

**Is there a chain rule?** In classical information theory, mutual information satisfies a chain rule: $I(X; Y, Z) = I(X; Y) + I(X; Z | Y)$. Does the compression defect satisfy an analogous identity?

**What about products?** The coproduct represents "disjoint choice." The product represents "simultaneous data." Does a dual inequality hold for products?

**Can we define conditional compression?** In Shannon theory, $H(Y|X)$ measures the additional information in $Y$ beyond what $X$ already provides. Is there a sheaf-theoretic analogue?

Each of these questions points toward a richer theory — a full calculus of geometric information, where the ancient study of shape meets the modern science of data.

## A Unification in the Making

Mathematics has a long history of unexpected unifications. Newton showed that the same laws govern falling apples and orbiting planets. Maxwell unified electricity and magnetism. Shannon unified communication engineering with probability theory.

The subadditivity of sheaf compression hints at another such unification — one between the abstract geometry of Grothendieck and the practical science of information. In this new picture, a Grothendieck topology is not just a way to organize geometric locality; it is a *communication channel* through which geometric data flows. Probes are *measurements*. Sections are *signals*. And the compression number is the *minimum cost of faithful observation*.

The message is clear: information is not just about bits and bytes. It lives in the structure of space itself, and the laws it obeys are as geometric as they are statistical. We are just beginning to read those laws.
