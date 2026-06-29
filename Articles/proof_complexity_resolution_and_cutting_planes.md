# The Stubbornness of Pigeons: Why Some Truths Are Hard to Prove

## A puzzle a child can solve

Put eleven pigeons into ten holes. At least two pigeons must share a hole. There is no way around it. This is the **pigeonhole principle**, and in its everyday form it is so obvious that we use it without a second thought: in any group of thirteen people, two share a birth month; in any city of a million residents, two have the same number of hairs on their heads.

The statement is trivial. The *proof* that a machine — or a rigid, mechanical reasoning system — can find is anything but. In fact, the pigeonhole principle sits at the heart of one of the deepest stories in modern logic and computer science: the story of how hard it can be to *certify* that something is impossible. This article is about that story, and about a clean set of mathematical results that explain why pigeons are so stubborn, and how a cleverer kind of reasoning tames them.

## Saying "no" with a certificate

Computers are extraordinarily good at searching. Ask a program whether a giant logical puzzle has a solution — whether a circuit can be made to misbehave, whether a schedule can satisfy every constraint, whether a configuration of millions of switches can be set just so — and modern *satisfiability solvers* will often answer in seconds, even for problems with millions of variables. These solvers run the world's hardware verification, software analysis, and logistics planning.

When such a solver says **"yes, a solution exists,"** it can hand you the solution and you can check it instantly. But what happens when the answer is **"no, this is impossible"**? How do you trust a machine that claims to have searched an astronomically large space and found nothing? The answer is that the solver produces a **certificate of impossibility** — a step-by-step argument that anyone (or any second program) can replay and verify. The proof system underlying virtually every such certificate is called **resolution**.

## Resolution: reasoning by elimination

Resolution is reasoning stripped to its bones. We work with logical formulas in a standard shape called **conjunctive normal form**, or CNF. The pieces are:

- A **literal** is a variable with a sign: either $x$ ("$x$ is true") or $\neg x$ ("$x$ is false").
- A **clause** is a list of literals joined by "or," such as $x \lor \neg y \lor z$. A clause is satisfied if *at least one* of its literals is true.
- A **CNF formula** is a list of clauses joined by "and." It is satisfied only if *every* clause is satisfied at once.

Resolution has exactly one rule. If you have a clause containing the literal $x$ and another containing $\neg x$, you may combine them, cancelling the conflicting pair:

$$\frac{(x \lor A) \qquad (\neg x \lor B)}{A \lor B}.$$

The intuition is airtight: $x$ is either true or false. If $x$ is false, then the first clause forces $A$; if $x$ is true, the second forces $B$. Either way, $A \lor B$ holds. We call $A \lor B$ the **resolvent**, and the pivotal fact — the semantic heart of the whole system — is that *whenever an assignment satisfies both parent clauses, it satisfies the resolvent*. There are no side conditions: the rule is sound even if the pivot variable does not actually appear, a small but clean strengthening of the textbook version.

Now play this game over and over. Start from the clauses of your formula and keep deriving resolvents. The grand prize is the **empty clause** — a clause with no literals at all, which no assignment can ever satisfy. It is the logical symbol of contradiction, the $\bot$ of the system. Deriving it is called a **refutation**, and it constitutes a proof that the original formula has no solution whatsoever.

This is more than a story; it is a theorem with a guarantee. Build up the property step by step — the single-rule soundness, then *every derived clause is a genuine consequence of the formula*, and finally:

> **Soundness of Resolution.** If a CNF formula admits a resolution refutation, then it is unsatisfiable.

That guarantee is exactly what makes a solver's "no" trustworthy. And the system is not vacuous: the tiny contradiction $\{x\} \land \{\neg x\}$ — "$x$ is true" and "$x$ is false" — resolves to the empty clause in a single step, the smallest refutation there is.

## Encoding the pigeons

To study resolution's limits, we turn it loose on the pigeonhole principle. For $n+1$ pigeons and $n$ holes, introduce one variable $x_{p,h}$ for each pigeon $p$ and hole $h$, meaning "pigeon $p$ sits in hole $h$." Two families of clauses capture the rules:

- **Pigeon clauses.** Each pigeon sits *somewhere*: for pigeon $p$, the clause $x_{p,1} \lor x_{p,2} \lor \cdots \lor x_{p,n}$.
- **Hole clauses.** No hole is *shared*: for every hole $h$ and every pair of distinct pigeons $p_1, p_2$, the clause $\neg x_{p_1,h} \lor \neg x_{p_2,h}$, saying they are not both in $h$.

Call this formula $\mathrm{PHP}_n$. It encodes a demand that is impossible to meet, and we can prove that cleanly: a satisfying assignment would let each pigeon *choose* a hole, and the hole clauses would force that choice to be **injective** — no two pigeons land in the same hole. But an injection from $n+1$ things into $n$ things cannot exist, because $n < n+1$. Hence:

> **The pigeonhole formula is unsatisfiable.** No assignment of the variables $x_{p,h}$ can place $n+1$ pigeons into $n$ holes without a collision.

This is the precondition that makes everything interesting. Because $\mathrm{PHP}_n$ truly has no solution, *some* resolution refutation of it must exist. The trillion-dollar question is: **how big must that refutation be?**

## Haken's wall

Here the story takes its dramatic turn. In 1985, Armin Haken proved that resolution refutations of the pigeonhole principle are **exponentially large** — the number of clauses you must write down grows like $2^{cn}$ for some constant $c > 0$. There is no clever shortcut, no compact certificate. A resolution-based solver confronted with the pigeonhole principle on a few hundred holes would need to manipulate more clauses than there are atoms in the observable universe.

This was a landmark: one of the first proofs that a natural, useful reasoning system has an *unavoidable* exponential blow-up on a specific, simple-looking family of problems. It explains a phenomenon practitioners had long observed — that SAT solvers, magnificent as they are, choke on pigeonhole-style counting problems.

Why is resolution so helpless here? The reason is profound and a little poetic: **resolution cannot count.** The pigeonhole principle is false for a global, arithmetic reason — eleven is more than ten — but resolution only ever reasons locally, one variable elimination at a time. It can never write down the single statement "the total number of occupied (pigeon, hole) slots is at least $n+1$ and at most $n$." Forced to rediscover that global fact through purely local moves, it must in effect enumerate an exponential thicket of cases.

## The engine room of lower bounds: restrictions

How does one *prove* a wall like Haken's? The master tool is the **restriction** — and a clean account of its algebra is one of the central contributions explained here.

A restriction is a partial decision. Imagine you walk up to the formula and permanently fix some of the variables — "pigeon 3 is definitely in hole 5, pigeon 7 is definitely not in hole 2" — while leaving the rest free to be decided later. Formally, a restriction assigns to each variable either a fixed value (true or false) or the marker "still free."

Applying a restriction simplifies the formula. A clause that the restriction already makes true is **killed** — discarded, because it is satisfied no matter what. In a surviving clause, any literal pinned to *false* is **deleted** (it can no longer help), while the literals on still-free variables are kept. What remains is a smaller formula on fewer variables.

The reason restrictions are the right tool is captured by an exact bridge between syntax and semantics. Write $F{\restriction}\rho$ for the formula $F$ after applying the restriction $\rho$, and let $\mathrm{subst}(\rho, a)$ be the full assignment that uses $\rho$'s fixed values where it has them and falls back on a free assignment $a$ elsewhere. Then:

> **The Restriction Invariance Theorem.** A free assignment $a$ satisfies the restricted formula $F{\restriction}\rho$ **if and only if** the glued assignment $\mathrm{subst}(\rho, a)$ satisfies the original formula $F$.

This is an *exact* equivalence — no approximation, no error term. Restricting a formula and then satisfying it is precisely the same as satisfying the original along the chosen partial assignment. The subtle point, the one that makes the proof delicate, is the asymmetry between killing and deleting: a literal pinned to *false* is deleted but does not kill its clause, and one has to verify that such a literal could never have been the one that rescued the clause in the first place — because the glued assignment agrees with the fixed value exactly there.

From this single equivalence, an immediately useful consequence drops out for free:

> **Hardness Preservation.** If a formula is unsatisfiable, then *every* restriction of it is unsatisfiable too.

Apply this to the pigeons and you learn something striking: **the pigeonhole principle is hard robustly.** No matter how many pigeon-hole decisions you fix in advance — no matter which partial board you start from — what remains is *still* an unsatisfiable pigeonhole-type instance. You cannot rescue the formula, and you cannot localize its difficulty to a small corner. This robustness is precisely why a random restriction is a sound weapon against short refutations: hit a hypothetical small refutation with a random partial assignment, and you are guaranteed to be left refuting something that is still genuinely hard.

Two further closure properties round out the picture and make resolution a well-behaved system. **Weakening:** a refutation keeps working when you toss extra, irrelevant clauses into the formula — adding hypotheses never invalidates a proof. And a sanity check at the opposite extreme: **the empty formula proves nothing** — with no clauses to start from, you can derive no clause at all, not even by the resolution rule. Together these say that resolution behaves exactly as a sound, monotone proof system should.

## A smarter reasoner: cutting planes

If resolution's blindness is that it cannot count, the natural fix is to give a proof system the power of *arithmetic*. This is the idea behind **cutting planes**, a system that reasons not about clauses but about **linear inequalities** over the integers.

Translate each Boolean variable into a $0/1$ integer. A clause like $x \lor y \lor z$ becomes the inequality $x + y + z \ge 1$ ("at least one is on"). Cutting planes then manipulates such inequalities with two rules, each of them transparently sound:

- **Addition.** If $x$ satisfies $d_1 \le \sum c_i x_i$ and $d_2 \le \sum c'_i x_i$, then it satisfies the sum $d_1 + d_2 \le \sum (c_i + c'_i)\, x_i$. You may add inequalities you already trust.
- **Chvátal–Gomory rounding.** If every coefficient on the left is divisible by a positive integer $k$ and $d \le \sum c_i x_i$, then dividing through by $k$ lets you *round the right-hand bound up*: $\lceil d/k \rceil \le \sum (c_i/k)\, x_i$. This is the genuinely powerful move — it exploits the fact that the variables are *integers*, so a fractional bound can be tightened to the next whole number.

Now watch cutting planes dismantle the pigeons in a single sweep of arithmetic. Encode "each pigeon sits somewhere" as the row sums $\sum_h x_{p,h} \ge 1$, one per pigeon, and "each hole holds at most one pigeon" as the column sums $\sum_p x_{p,h} \le 1$, one per hole. Add up all the row inequalities: the total over all $(p,h)$ slots is at least $n+1$, one for each of the $n+1$ pigeons. Add up all the column inequalities: the very same total is at most $n$, one for each of the $n$ holes. Putting them side by side:

$$n + 1 \;\le\; \sum_{p}\sum_{h} x_{p,h} \;=\; \sum_{h}\sum_{p} x_{p,h} \;\le\; n.$$

That is $n+1 \le n$ — a flat contradiction, reached in a number of steps that grows only *linearly* with $n$.

> **The Counting Refutation.** For any integer assignment in which every pigeon's row sums to at least $1$ and every hole's column sums to at most $1$, summing the inequalities yields $n+1 \le n$, an impossibility. Cutting planes refutes the pigeonhole principle in $O(n)$ steps.

## The separation, and what it means

Stand back and compare. The *same* formula — the pigeonhole principle — costs resolution an exponential mountain of clauses and costs cutting planes a gentle linear stroll. This gap is a **separation** between proof systems: a demonstration that one mode of reasoning is fundamentally, exponentially more powerful than another on a natural problem.

The mathematical content of that separation is exactly the asymmetry made precise above. On the cutting-planes side, the contradiction is *easy* because the argument is global and arithmetic: a single chain of additions expresses the count. On the resolution side, the contradiction is *exponential* because the system is local and combinatorial: it cannot name the count, so Haken's theorem forces it to enumerate. The counting refutation we exhibit is the constructive witness for the easy side; Haken's exponential lower bound governs the hard side.

This is not an academic curiosity. It is the theoretical shadow of a practical reality. The dominant SAT solvers of today are, at heart, resolution engines — which is why they stumble on counting problems. Solvers that incorporate arithmetic or "pseudo-Boolean" reasoning, in the spirit of cutting planes, can sail through exactly those instances. The separation tells engineers *which* tool to reach for and *why*, and it tells theorists where the next frontiers lie.

## The view from here

The pigeonhole principle is a humble fact about pigeons and holes. Examined through the lens of proof complexity, it becomes a measuring instrument — a benchmark that exposes the true power and the true limits of mechanical reasoning. We have seen that resolution is sound, robust, and well-behaved; that it certifies impossibility in a way machines can trust; and yet that it hits an exponential wall on a problem a child can solve, for the deep reason that it cannot count. We have seen that restrictions — exact, lossless, hardness-preserving — are the engine that drives such lower bounds, and that the pigeonhole principle stays hard under every partial decision. And we have seen a smarter system, cutting planes, leap the wall with pure arithmetic, separating itself exponentially from resolution.

There remains the great prize, the quantitative core of Haken's theorem: turning the *qualitative* robustness of the pigeonhole principle under restriction into a sharp lower bound on how *wide* — and therefore how *long* — any resolution refutation must be. The exact, error-free invariance of restrictions is precisely the lever that argument needs. The pigeons, it turns out, have a great deal still to teach us.
