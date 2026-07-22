# The Last Theorem Is Never Tomorrow

## Counting the mathematics of an intelligence explosion

Imagine a civilization so old that stars are raw material and centuries feel like clock cycles. Its archives swell with proofs. Each generation of thinkers builds faster machines, sharper languages, and better methods of discovery. At first the number of new results doubles from era to era. Later it grows like $2^{2^n}$ at stage $n$: not merely exponential, but double-exponential. This is the mathematical silhouette of an “intelligence explosion”—a process whose output accelerates beyond familiar scales.

Could such a civilization finish mathematics?

The tempting answer is yes. A rate such as $2^{2^n}$ quickly outruns every quantity that fits comfortably in the imagination. At stage $5$, it is already $2^{32}$; at stage $10$, it is $2^{1024}$. Surely, one might think, there must be some finite morning on which every theorem has entered the library.

That conclusion is wrong. The error is subtle but fundamental: **arbitrarily large finite output is still finite output**. Yet this does not mean that some coded theorem must remain undiscovered forever. A library can fail to be complete at every finite moment while eventually receiving each individual book. The distinction between “all by one deadline” and “each at some time” is the key to reasoning clearly about unlimited intellectual growth.

This article develops a precise model of that distinction, adds a physical ceiling, and then locates a genuine barrier—not among countably many written formulas, but in the vastly larger world of all yes-or-no properties of the natural numbers.

## A library built in finite batches

Represent every possible written theorem, proof, or sentence by a natural-number code. This is not a claim that the numbers capture meaning; it is simply a filing system for finite strings. Since every finite text can be encoded by a natural number, the set of possible documents is countable.

A **discovery schedule** assigns to each stage $n=0,1,2,\ldots$ a finite set $S_n$ of codes discovered at that stage. The cumulative archive by deadline $N$ is

$$
D_N=\bigcup_{n=0}^{N}S_n.
$$

A code $a$ is **eventually discovered** if $a\in S_n$ for at least one stage $n$. A **rate bound** is a function $r(n)$ such that

$$
|S_n|\le r(n)
$$

at every stage. Dyson’s illustrative high-growth profile is

$$
r(n)=2^{2^n}.
$$

These definitions separate rate, cumulative output, and eventual coverage. That separation prevents enormous numbers from doing logical work they cannot do.

## The finite-horizon counting theorem

The first result is elementary and decisive.

**Finite-Horizon Counting Theorem.** For every discovery schedule and every finite deadline $N$,

$$
|D_N|\le \sum_{n=0}^{N}|S_n|.
$$

The inequality, rather than equality, allows the same code to be rediscovered at different stages. Each distinct item in the archive must have appeared in at least one batch, so the union cannot contain more items than the batches contain altogether.

Suppose physics imposes a uniform cap of $C$ recorded discoveries per stage. Then the theorem immediately yields

$$
|D_N|\le (N+1)C.
$$

Call this the **Physical-Cap Corollary**. Even if $C$ were around $10^{120}$ operations or records per stage, the right-hand side would remain finite for every finite $N$. The number $10^{120}$ is spectacularly large, but multiplication by a finite number of stages never turns it into infinity.

This gives a clean way to discuss Bekenstein-style limits without overclaiming. A physical cap controls finite-horizon throughput. To turn it into a realistic theory of discovery, one would still need to say how many operations a proof search costs, how much memory is available, how long a stage lasts, and whether the cap is instantaneous or cumulative. Counting outputs alone is only the first layer.

## Why no finite deadline can finish a countable archive

Now comes the result that punctures the most extravagant version of the intelligence-explosion story.

**No-Universal-Deadline Theorem.** If every stage contributes only finitely many natural-number codes, then for every finite deadline $N$ there is a code absent from $D_N$. Consequently, no finite $N$ can satisfy $D_N=\mathbb N$.

The proof needs almost no machinery. The archive $D_N$ is a finite union of finite sets and is therefore finite. The natural numbers are infinite, so at least one natural number lies outside it. One can even exhibit a missing code: take

$$
m_N=\sum_{x\in D_N}(x+1).
$$

If $m_N$ belonged to $D_N$, then its own contribution $m_N+1$ would be one of the positive summands defining $m_N$, forcing $m_N+1\le m_N$, an impossibility.

Notice what the theorem does **not** depend on. It does not matter whether $|S_n|$ is bounded by $2^n$, by $2^{2^n}$, or by a tower of exponents whose height increases with $n$. Every fixed deadline includes only finitely many finite batches. Superexponential acceleration therefore cannot produce a common finite completion time for an infinite coded language.

This is not a statement about one code being eternally inaccessible. It says only that whenever the librarian announces, “We are finished now,” there remains a missing catalogue entry.

## Slow can still be complete

Consider the simplest possible schedule:

$$
S_n=\{n\}.
$$

At stage $0$ it records code $0$; at stage $1$, code $1$; and so on. Exactly one new code appears at every stage.

**Unit-Rate Completeness Theorem.** The schedule $S_n=\{n\}$ eventually discovers every natural-number code.

Indeed, code $k$ appears at stage $k$. The schedule is also bounded by the exponential profile $2^n$, because $1\le 2^n$ for all $n$, and by the double-exponential profile $2^{2^n}$. Thus a schedule described merely as “at most exponential” can cover every code eventually.

This corrects a second tempting claim: that a merely exponential rate must leave some syntactic theorem undiscovered forever. A rate bound alone says how many items may appear at a stage; it says nothing about whether the choices are fair, repetitive, or comprehensive. A civilization could spend every stage rediscovering the same theorem, or it could enumerate all codes methodically at rate one.

Gödel’s incompleteness phenomenon cannot be inferred from throughput alone. Incompleteness requires a specific effective theory, sufficient arithmetic strength, and hypotheses such as consistency or soundness. It concerns what follows from a chosen axiom system, not how quickly a schedule prints numbered strings.

The lesson is striking: **speed is neither necessary for eventual syntactic coverage nor sufficient for finite completion**.

## When a common deadline does exist

There is one important finite version of the completion dream.

**Finite-Corpus Common-Deadline Theorem.** Let $F$ be a finite set of items. If every $a\in F$ is eventually discovered, then there is one finite deadline $N$ by which every member of $F$ has been discovered.

For each $a\in F$, choose a stage $n_a$ at which it appears. Since $F$ is finite, the finite collection of times $\{n_a:a\in F\}$ has a maximum. Taking

$$
N=\max_{a\in F}n_a
$$

produces the desired common deadline.

The word “finite” carries the entire argument. For an infinite corpus, individual discovery times need not have a finite maximum. In the unit-rate schedule, every code has a discovery time, but the set of times is unbounded. This is why “each theorem eventually” cannot be compressed into “all theorems eventually” when the latter means one shared finite date.

## A real barrier: semantic diagonalization

If all finite texts can be numbered, where could genuinely unenumerable mathematics hide? The answer appears when we move from syntax to semantics.

A **predicate on the natural numbers** is a yes-or-no property $P(n)$. Mathematically, it is a function

$$
P:\mathbb N\to\{\text{true},\text{false}\}.
$$

Suppose someone claims to have listed all such predicates:

$$
P_0,P_1,P_2,\ldots.
$$

Construct a new predicate $Q$ by looking down the diagonal and reversing each answer:

$$
Q(n)=\neg P_n(n).
$$

**Semantic Diagonal Barrier.** For every countable list $P_0,P_1,P_2,\ldots$ of predicates on $\mathbb N$, the diagonal predicate $Q$ differs from every entry. Therefore no map from $\mathbb N$ onto the set of all predicates on $\mathbb N$ is surjective.

To prove it, compare $Q$ with the $k$th listed predicate at input $k$. By definition,

$$
Q(k)=\neg P_k(k).
$$

So $Q$ and $P_k$ disagree at $k$. Since this works for every $k$, $Q$ is absent from the entire list.

Here, at last, is an unavoidable expressibility barrier for every countable discovery stream. It is not caused by inadequate speed. Even infinitely patient enumeration cannot list an uncountable semantic universe.

But care is essential. The diagonal predicate need not correspond to a theorem expressible in a particular formal language, and this argument alone says nothing about which arithmetic predicates are computable or definable. Finite strings remain countable. The barrier arises because the collection of all semantic predicates is larger than every countable language of finite descriptions.

## What survives the moonshot

The mathematics leaves us with a more nuanced vision than “fast intelligence finishes everything” or “slow intelligence must miss something forever.” Four principles survive:

1. By any finite time, finite batches yield only finitely many distinct discoveries.
2. No finite deadline can cover all natural-number codes, regardless of superexponential growth.
3. Every code can nevertheless be discovered eventually, even at one code per stage.
4. No countable schedule can exhaust all predicates on the natural numbers, because diagonalization explicitly creates an omitted predicate.

An intelligence explosion may transform which questions are tractable, how quickly proofs are found, and how large a finite corpus can be mastered. It may make today’s impossible calculations routine. Yet the arithmetic of infinity does not yield to scale. A tower of exponents is still a finite tower at each finite stage.

The deepest frontier is therefore not simply faster search. It is the boundary among written formulas, provable theorems, true statements, computable predicates, and arbitrary semantic properties. Those categories are easy to blur in futuristic stories, but mathematics insists that they remain distinct.

A civilization can keep opening doors forever. It can eventually open every numbered door. What it cannot do is stand at one finite moment before an infinite corridor and truthfully declare that every door is already open. And beyond the numbered corridor lies a larger landscape for which no numbered list can even supply all the doors.
