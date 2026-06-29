# When the Obvious Two Answers Are Both Wrong: A Hidden Network That Beats the Envelope

## A puzzle about how often a pattern appears

Imagine you are handed an enormous social network — millions of people, with friendships drawn between some of them. You are told just one fact about it: a fixed fraction $\beta$ of all *possible* friendships actually exist. We call $\beta$ the **density**. If $\beta = 0.5$, then half of all possible friendships are real.

Now you are asked a deceptively simple question. Pick a person at random and look at a small local pattern around them — say, a person who has **two friends and one non-friend** among three particular acquaintances. How *rare* can such a pattern be made? Across all the ways you could possibly wire up a network of density $\beta$, what is the smallest possible frequency of this little "two-friends-and-a-stranger" configuration?

This kind of question — *how scarce can a tiny pattern be, given a fixed overall density?* — is the beating heart of a field called **extremal graph theory**. It is the mathematics of pushing structure to its limits. And the surprising answer we tell here is this: the two most "natural" networks you would reach for — the ones almost everyone guesses — are *both* the wrong answer. A stranger, lopsided construction does better, and it does so in a precise window of densities centered on the most symmetric value of all, $\beta = 1/2$.

## The star at the center of the story

Let us name our pattern precisely. We study a small labeled configuration called a **semi-induced star**, written $S_{k,1}$. It has one special vertex — the **center** — together with $k+1$ neighbors. Of the $k+1$ edges leaving the center, exactly $k$ are required to be **present** (call them "red") and exactly $1$ is required to be **absent** (call it "blue"). The leaves themselves are otherwise unconstrained: we only police the edges that touch the center. That is what "semi-induced" means — we fix the local picture at the hub, and let the rest of the world go free.

For $k = 2$ this is exactly the "two friends and one stranger" pattern. The general $S_{k,1}$ asks for $k$ confirmed friendships and one confirmed non-friendship around a single person.

To make "how often does this pattern appear" into clean mathematics, we pass to the language of **graphons**. A graphon is the limit object of a sequence of larger and larger graphs — think of it as an infinitely fine network, described by a symmetric function $W(x,y) \in [0,1]$ giving the "probability" or weight of an edge between abstract points $x$ and $y$. For each point $x$ there is a **degree density**

$$d(x) = \int_0^1 W(x,y)\, dy,$$

the local fraction of the world that $x$ is connected to. A short calculation shows that the frequency of the semi-induced star $S_{k,1}$ — choosing $k$ neighbors that *are* connected and one that is *not* — is captured by the clean integral

$$I(W) = \int_0^1 d(x)^k \,\bigl(1 - d(x)\bigr)\, dx.$$

The factor $d(x)^k$ rewards a vertex for having many connections (the $k$ red edges); the factor $1 - d(x)$ rewards it for having a missing connection (the lone blue edge). Our constraint is simply that the average degree equals the prescribed density:

$$\int_0^1 d(x)\, dx = \beta.$$

The question becomes purely about *how the degrees are distributed*: given that they average to $\beta$, how small can the average of $d^k(1-d)$ be made? This is an optimization over all possible "degree landscapes."

## The two natural guesses

Confronted with such a problem, an experienced mathematician reaches instinctively for two extreme constructions.

**The quasi-clique.** Make everybody equal. Every vertex has exactly degree $\beta$. The landscape is flat. Then the value is simply

$$\text{cliqueTerm} = \beta^k (1-\beta).$$

This is the "egalitarian" network: a uniform random-like graph where everyone is equally well connected.

**The quasi-star.** Take the complementary view — a few hyper-connected hubs joined to a sea of sparse vertices, arranged so the average degree is still $\beta$. By a symmetry between edges and non-edges, this construction yields

$$\text{starTerm} = \beta (1-\beta)^k.$$

These two constructions are the workhorses of extremal combinatorics; they are the first and second things anyone tries. Together they form what we call the **envelope**:

$$\text{envelope}(\beta) = \min\bigl(\beta^k(1-\beta),\; \beta(1-\beta)^k\bigr).$$

For decades, the working assumption in many such problems is that one of these two endpoint constructions is optimal — that the true minimum simply *is* the envelope. The story of this article is that, for the semi-induced star, **it is not**.

## The intruder: a split network

Here is the construction that breaks the pattern. We call it the **split graphon**, and it has a vivid combinatorial meaning: it is a **dominating clique joined to an independent set**.

Picture the population divided into two groups:

- **Group $A$ (the clique-core):** a fraction $a$ of the population. Everyone in $A$ is connected to *everyone* — to each other and to all of group $B$. They are the universal hubs.
- **Group $B$ (the independent set):** the remaining fraction $1-a$. Members of $B$ have *no* connections among themselves. They are connected only upward, to the hubs in $A$.

In graphon terms this is a two-class step function with internal densities $p = 1$ within $A$, $q = 1$ between $A$ and $B$, and $r = 0$ within $B$. The two degree values are strikingly clean. Every hub in $A$ is connected to everyone, so its degree is

$$d_1 = 1.$$

Every member of $B$ is connected only to the hubs, so its degree is

$$d_2 = a.$$

Now comes the magic. The overall density of this network is $a \cdot 1 + (1-a)\cdot a = 2a - a^2 = 1 - (1-a)^2$. To make this equal $\beta$, we solve and find

$$a = 1 - \sqrt{1-\beta}.$$

And the value of our star functional? The hubs contribute *nothing*, because their degree is exactly $1$ and the factor $(1 - d_1) = 0$ wipes them out — a vertex connected to everyone can never be the center of a star with a missing edge. All the cost is paid by group $B$ alone:

$$I = (1-a)\, a^k (1 - a) = (1-a)^2 a^k.$$

Substituting $1 - a = \sqrt{1-\beta}$, so $(1-a)^2 = 1-\beta$, gives the elegant closed form

$$\boxed{\;\text{splitVal}(k,\beta) = (1-\beta)\,\bigl(1 - \sqrt{1-\beta}\,\bigr)^k.\;}$$

This is the value achieved by a genuine, valid network of exactly the right density. So it is an honest *upper bound* on the true minimum. The question is whether it beats the envelope — whether this lopsided clique-plus-independent-set construction is genuinely better than both natural guesses.

## The verdict, in two clean inequalities

It is. And the proof reduces to two transparent facts about the square root.

**It always beats the quasi-clique.** Compare the split value with $\text{cliqueTerm} = \beta^k(1-\beta)$. Cancel the common factor $1-\beta$. What remains is the comparison

$$\bigl(1 - \sqrt{1-\beta}\,\bigr)^k \;<\; \beta^k,$$

which holds precisely when $1 - \sqrt{1-\beta} < \beta$, i.e. when $1 - \beta < \sqrt{1-\beta}$. Writing $s = \sqrt{1-\beta}$, this is just $s^2 < s$, true for every $s$ in $(0,1)$ — that is, for *every* density $\beta \in (0,1)$. So the split network beats the egalitarian one **everywhere**.

**It beats the quasi-star on an interval.** Comparing with $\text{starTerm} = \beta(1-\beta)^k$ turns out to require

$$\sqrt{1-\beta} > \beta,$$

which, squaring, is $1 - \beta > \beta^2$, i.e. $\beta^2 + \beta - 1 < 0$. The boundary is the root of $\beta^2 + \beta - 1 = 0$, namely the famous **golden ratio conjugate**

$$\beta^\star = \frac{\sqrt 5 - 1}{2} \approx 0.618.$$

So the split network beats the quasi-star exactly when $\beta < \beta^\star$.

Put the two together. On the open interval $(0, \beta^\star)$ — which comfortably contains the most symmetric density $\beta = 1/2$ — the split construction beats *both* terms simultaneously, and therefore beats the envelope:

$$\text{splitVal}(k,\beta) \;<\; \text{envelope}(k,\beta) \qquad \text{for all } k \ge 1,\ \beta \in (0, \tfrac{\sqrt5 - 1}{2}).$$

This is the main theorem, which in the formal development bears the name **`splitVal_lt_envelope`**, with its companion **`min_semiInducibility_lt_envelope`** packaging the conclusion as an explicit witness: there really exists a valid graphon of density $\beta$ whose star value falls below the envelope. The supporting facts — that the split graphon is a legitimate network (`splitConstruction_valid`), that its density is exactly $\beta$ (`splitConstruction_density`), that it realizes the closed form $\text{splitVal}$ (`splitConstruction_starVal`), and that it beats the clique term everywhere (`splitVal_lt_cliqueTerm`) — are each established rigorously.

## Why the golden ratio?

It is delightful and not accidental that the boundary of this phenomenon is the golden ratio. The threshold $\beta^\star = (\sqrt5 - 1)/2$ is the exact point where $\sqrt{1-\beta}$ and $\beta$ trade places. Below it, "there is more room in the non-edges than in the edges," and the asymmetric split exploits that imbalance. Above it, the balance tips, and for large $k$ the quasi-star endpoint reclaims its crown. The number that governs sunflower spirals, pinecones, and the proportions of classical architecture turns out to also mark the phase boundary of a combinatorial optimization. The same root, $\beta^2 + \beta - 1 = 0$, separates two qualitatively different optimal worlds.

## The bigger picture: never trust the envelope

This result is a single, sharply proven instance of a recurring theme in modern combinatorics: **the two obvious extremal constructions are often not the truth.** For the semi-induced star $S_{k,1}$, the egalitarian quasi-clique and its mirror-image quasi-star feel canonical, and yet a third, asymmetric design — concentrate connectivity into a saturated core, and starve an independent fringe — quietly does better across a whole interval of densities.

The intuition is worth keeping. The star functional $d^k(1-d)$ has a built-in escape hatch: it vanishes when $d = 1$. A vertex connected to everyone is *free* — it can never be the center of our pattern. The split graphon weaponizes this: it pushes one entire class all the way to degree $1$, paying zero there, and concentrates all the remaining cost into a single, carefully sized independent group. The egalitarian network, by spreading the burden evenly, can never access this free lunch.

For the original case $k = 2$, the full story is even richer: the true minimizer is a *three-class* "complement-split" family. The work described here shows that the core phenomenon — the envelope is beatable — survives for *every* $k$, with an explicit, closed-form witness whose value matches numerical minimizers to three decimal places. Numerical experiments suggest the optimal network needs at most $k+1$ classes, growing more intricate as the pattern grows, and that above the golden ratio the optimal structure changes combinatorial type entirely.

There is a moral here for anyone who models networks — epidemiologists tuning contact graphs, engineers laying out communication topologies, social scientists fitting structure to data. When you ask "what is the rarest a local motif can be?", do not assume the answer is uniform, and do not assume it is a single dominant hub. Sometimes the extremal world is a society split sharply into a fully-connected elite and an isolated periphery — and that split, not the comfortable middle, is what the mathematics demands. The obvious two answers can both be wrong, and the truth can be hiding in a golden-ratio-sized window right under the most symmetric point of all.
