# The Trees That Refuse to Agree

## How a question from evolutionary biology turns into a problem about error-correcting codes — and why the answer grows exponentially

### Four species and three stories

Take four species: a human, a chimpanzee, a gorilla, and a chicken. Whatever the true history of life, the evolutionary tree that relates them must look like one of exactly three shapes. Either human and chimp branched off together, leaving gorilla and chicken on the other side; or human went with gorilla; or human went with chicken. There is no fourth possibility, and there is no way to be neutral. A fully resolved evolutionary tree on four labelled tips — biologists call it a **quartet** — always splits them $2+2$, and the split is one of

$$ab|cd, \qquad ac|bd, \qquad ad|bc.$$

That "exactly three" is the seed of everything that follows.

A big tree contains an enormous number of small ones. From a tree on $n$ species you can read off a quartet for every one of the $\binom{n}{4}$ four-element subsets of the tips: delete all the other species, tidy up the leftover branches, and look at which pair went with which. In fact the collection of all these quartets determines the whole tree. Trees are their quartets.

This is more than a curiosity, because in real biology one rarely gets one tree. Different genes, different data sets, different laboratories produce different trees for the same set of species, and the central practical question is: **on what do they agree?** The cleanest possible form of agreement is a common quartet: four species that every one of the trees resolves the same way. If a hundred gene trees all say $\text{human},\text{chimp}\,|\,\text{gorilla},\text{chicken}$, that is a piece of history you can believe in.

So here is the question this article is about.

> **The common-quartet problem.** Let $h(k)$ be the smallest number of species $n$ with the following property: *any* $k$ fully resolved trees on those $n$ species must share a common quartet. How fast does $h(k)$ grow?

Small $k$ makes the question feel innocent. Two trees on five species can already disagree about everything — we will meet an explicit pair in a moment — but on six species two trees of the simple "backbone" shape described below are always forced to agree somewhere. For that class six is both necessary and sufficient, and in general $h(2) \geq 6$. Three trees hold out longer: there are three trees on nine species with no common quartet at all, so $h(3) \geq 10$.

The pattern of these small numbers — $6$, $10$, and then, empirically, around $16$ and $20$ and $30$ — has a suspicious regularity to it. Each additional tree seems to buy you a *multiplicative* amount of extra room, not an additive one. The main theorem below makes that suspicion into a proof: $h(k)$ really does grow at least exponentially in $k$. Adversarial families of trees can be built that agree on nothing, and they can be built on exponentially many species.

The route to that theorem passes through a subject that has nothing to do with biology.

### Trees as words

Here is the change of viewpoint that does all the work. Since every four-element subset of the species gets one of three labels, a tree $T$ on $n$ species can be written down as a long word

$$\sigma(T) \;=\; \bigl(\text{quartet type of } T \text{ on } Q\bigr)_{Q},$$

one letter for each of the $\binom{n}{4}$ four-element subsets $Q$, each letter drawn from a three-letter alphabet $\{0,1,2\}$. Call this word the tree's **quartet signature**. It lives in the ternary cube $\{0,1,2\}^{\binom{n}{4}}$.

Now translate the question. A family of trees $T_1, \dots, T_k$ has a common quartet exactly when their signatures carry the *same letter in some coordinate*. The family agrees on nothing exactly when

$$\text{in every coordinate, at least two of the } k \text{ words disagree.}$$

In other words: **no constant coordinate**. Building large families of mutually disagreeing trees is now a problem about packing words into a ternary cube — the natural habitat of coding theory. And coding theory has a standard tool for showing that large packings exist without ever exhibiting one: the probabilistic method.

Before running it, though, we need a class of trees that is easy to randomise.

### Caterpillars, and the pleasure of an exact answer

The simplest fully resolved trees are the **caterpillars**: a single long path, with species hanging off it one at a time, like legs. A caterpillar is determined by nothing more than the left-to-right order in which its species appear along the path. So a caterpillar on $n$ species *is* a permutation, and choosing a random caterpillar means shuffling a deck of $n$ cards.

Caterpillars have a beautifully simple quartet rule. Fix four species; look at the four positions they occupy along the path; the two that sit at the low end of that stretch pair up, and the two at the high end pair up. If the order along the path is $a$, then $b$, then $c$, then $d$, the quartet is $ab|cd$. Nothing else about the tree matters. In symbols, for four distinct path positions $p,q,r,s$ the type is $0$ (meaning $ab|cd$) precisely when $\max(p,q) < \min(r,s)$ or $\max(r,s) < \min(p,q)$, and the other two types are characterised the same way with the roles of the species permuted.

Now the first real theorem, and it is exact rather than approximate.

> **Ternary balance.** Fix any four distinct species. Of the $n!$ possible caterpillars on $n$ species, exactly $n!/3$ display each of the three quartet types on those four species.

Why is the split *exactly* even? Because there is a symmetry that permutes the three types. Take a caterpillar, and swap the path positions of two of the four chosen species — say the second and the third. This is an involution: do it twice and you are back where you started. And a quick check of the position inequalities shows that it exchanges types $0$ and $1$ while leaving type $2$ alone. A second transposition, of the second and fourth species, exchanges types $0$ and $2$. Two involutions that pair up the classes force all three classes to have the same size, and since they partition all $n!$ caterpillars, each has exactly $n!/3$ members. There is no error term, no asymptotics, no "approximately a third". One third, on the nose.

### The first moment

With exact balance in hand, the probabilistic argument is almost embarrassingly short.

Pick $k = m+1$ caterpillars independently and uniformly at random. Fix four distinct species. The probability that all $k$ trees display the *same* quartet on them is

$$3 \cdot \left(\frac{1}{3}\right)^{k} \;=\; \frac{1}{3^{\,k-1}} \;=\; \frac{1}{3^{m}},$$

— three choices of which type they all agree on, each occurring with probability $3^{-k}$ by balance and independence. Exactly $3^{-m}$; again no error term.

There are fewer than $n^4$ ordered quadruples of species to worry about. So the expected number of quartets on which the whole family agrees is at most $n^4/3^m$. If that is less than $1$, some outcome of the random experiment must have *zero* agreeing quartets. That gives:

> **Exponential lower bound.** If $n^4 < 3^m$, then there exist $m+1$ trees on $n$ species with no common quartet. In particular, for every $v$ there are $4v+2$ trees on $3^{v}$ species that agree on nothing, so
> $$h(k) \;>\; 3^{(k-2)/4}.$$

Read the constant: $3^{1/4} \approx 1.316$. Every extra tree you add to the family lets you keep about $31\%$ more species in play while still agreeing on nothing. The threshold $h(k)$ is at least exponential.

A caveat that is really a feature: the argument produces caterpillars, but caterpillars are perfectly legitimate fully resolved trees, so the lower bound applies to the general problem. To make that airtight one has to check that the ternary letter really is a faithful record of the tree's structure on the four chosen species — that agreement in the strong sense (the two trees restrict to literally the same four-species tree) forces equality of the letter. It does, and the check is a direct comparison of the branch-splits of the two restricted trees.

### The trap: distance is the wrong idea

At this point a coding theorist has a reflex: to build a family of words that never agree, maximise the Hamming distance. Push the codewords as far apart as possible and surely no coordinate will be constant.

This reflex is catastrophically wrong here, and it is worth seeing why, because it explains why the correct formulation of the problem looks slightly unusual.

> **Collapse of the distance formulation.** Over a three-letter alphabet, a family of words that pairwise differ in *every single* coordinate has at most three members — no matter how long the words are.

The proof is one line: look at the first letter of each word. Any two words differ there, so the map "word $\mapsto$ its first letter" is injective on the family, and its target has three elements. Length is no help at all; a million coordinates buy you nothing.

So "maximum distance" caps the family at three trees, while we want families of size growing with the number of species. The right notion is genuinely weaker and genuinely combinatorial: *in each coordinate, somebody disagrees* — not everybody, just somebody. Different pairs of trees may be the ones doing the disagreeing in different coordinates. This is a covering condition, not a packing condition, and it is exactly what the first-moment argument delivers.

### The code has parity checks

There is a second reason the analogy with codes is more than a metaphor. Not every ternary word is the signature of a tree. Signatures satisfy local consistency constraints, the analogue of parity checks in a linear code, and they involve only five species at a time.

The most intuitive is **cherry propagation**: if a tree separates the pair $a,b$ from $c,d$, and also separates $a,b$ from $c,e$, then it separates $a,b$ from $d,e$. In symbols: $ab|cd$ and $ab|ce$ force $ab|de$. Once $a$ and $b$ are joined as a "cherry" at one end, they stay joined. Consequently the configuration $ab|cd$, $ab|ce$, $ad|be$ is *forbidden*: no tree displays it, so the corresponding word is not a codeword. Other rules mix the types: $ab|cd$ together with $ac|be$ forces the resolution $ae|cd$.

How constraining is all this? On five species one can count exhaustively. The ternary cube has $3^5 = 243$ words of the relevant length; exactly $15$ of them are signatures of a tree. That is a code rate of $\log_3(15)/5 \approx 0.49$ — the tree code occupies less than half the "dimensions" available to it. The number $15$ is not arbitrary: it equals $5!/8$, and there are indeed exactly $15$ distinct caterpillar shapes on five species.

Where does the $8$ come from? From the symmetries of a caterpillar. Reading the path backwards gives the same tree. Swapping the two species at the far left end gives the same tree, because they form a cherry and cherries have no internal order. Likewise at the far right end. Those three moves generate a group of order $8$, and it acts on leaf orders without fixed points once there are at least four species. Hence:

> **Packing bound.** The number of distinct quartet signatures of caterpillars on $n$ species is at most $n!/8$.

Exhaustive computation confirms that this is an equality for $n = 4, 5, 6, 7$: there are $3, 15, 90, 630$ distinct signatures, exactly $n!/8$ in each case. The signature map is precisely eight-to-one — which is another way of saying that a caterpillar is completely reconstructible from its quartets, up to relabelling by its own symmetries.

### How far up does the ceiling go?

An exponential lower bound is only half the story. What forces agreement?

For two trees, the classical Erdős–Szekeres theorem does it. Compare two caterpillars by the permutation that carries the first path order to the second. Any injective sequence of more than $9$ terms contains a monotone subsequence of length $4$. Four species that both trees order in the same way — or in exactly opposite ways, which for quartets is the same thing — necessarily carry the same quartet. So any two caterpillars on $10$ or more species share a quartet.

But $10$ is not the truth. Because a quartet letter depends only on the *relative order* of four species, one can restrict a large tree to any six of its species and get an honest six-species tree with the same letters; so a six-species obstruction, once verified, propagates upward to every larger number of species. And the six-species statement can be verified: every pair of caterpillars on six species shares a quartet. (A group-theoretic simplification helps — comparing $\pi$ with $\rho$ is the same as comparing the identity order with $\rho\pi^{-1}$, which cuts $720^2$ pairs down to $720$.) Meanwhile, on five species, the caterpillar with order $a,b,c,d,e$ and the one with order $a,d,c,b,e$ share nothing: the first resolves all five of its quartets as "type $0$", the second resolves them as $2,1,1,1,2$. Hence

$$h(2) = 6 \quad \text{exactly, for caterpillar-shaped trees.}$$

Iterating Erdős–Szekeres across $k$ trees gives an upper bound too — any $k$ caterpillars on more than $3^{2^k}$ species share a quartet — but this is *doubly* exponential, and it is certainly loose. For three caterpillars it yields a threshold of at most $6562$, against a lower bound of $10$ from the explicit nine-species triple. The gap between $3^{(k-2)/4}$ and $3^{2^k}$ is the outstanding question.

Numerical searches suggest strongly that the lower bound is closer to the truth. Local search finds families with no common quartet on $5$, $9$, and about $15$–$16$ species for $k = 2, 3, 4$, and around $20$ and $30$ for $k = 5, 6$: a growth ratio near $1.7$ per additional tree. That is comfortably exponential, comfortably above the certified $1.316$, and nowhere near doubly exponential. The most likely shape of the answer is

$$h(k) = \Theta(c^{k}) \quad \text{for a single constant } c \in [3^{1/4}, 2],$$

with the whole content of the problem being the determination of $c$. And the coding dictionary tells us exactly what $c$ is: it is a packing rate in a constrained ternary code — the largest exponential rate at which one can place codewords of the tree code so that no coordinate is ever constant.

### Why the reformulation matters

The dictionary changes what the problem is *about*. The doubly exponential upper bound comes from a global argument: extract a monotone pattern across all species, then extract again inside it, and again, once per tree. That is a wasteful thing to do, because a common quartet is a purely local object — it needs four species to line up, not a monotone chain through the entire data set. Once you know that agreement is letter-equality in a ternary code on $\binom{n}{4}$ coordinates, the natural tool is a Ramsey-type theorem for $4$-uniform hypergraphs with three colours, and the natural expectation is a single exponential.

There is a broader lesson in the failed reflex, too. Coding theory offers two very different currencies: distance, which is about pairs, and covering, which is about the whole family at once. Agreement among many trees is irreducibly a many-body condition; no amount of pairwise separation captures it, as the three-word collapse shows starkly. The exact ternary balance is what rescues the situation, because it makes the many-body first moment computable to the last digit.

And the biology has not gone away. A family of trees with no common quartet is a data set on which every four-species conclusion is contested — the worst case a phylogeneticist can face. The theorem says such data sets exist on exponentially many species, so the size of a data set is no guarantee of agreement. But it also says the number of *sources* needed to manufacture such total disagreement grows only logarithmically in the number of species. Ten conflicting trees suffice to wreck consensus on nine species; to wreck it on $729$ species, the same construction needs only $26$. Total disagreement is always possible — but the price of manufacturing it climbs only logarithmically with the size of the problem.
