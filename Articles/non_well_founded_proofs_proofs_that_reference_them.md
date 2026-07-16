# When a Proof Bites Its Own Tail

## Infinite objects are not automatically infinite proofs

A serpent eating its tail is one of humanity’s oldest images of eternity. Mathematics has its own versions: a recursive program calls itself, a fractal contains smaller copies of itself, and a periodic decimal repeats forever. It is tempting to add proofs to this list. Why should a proof not refer back to itself, provided the loop somehow “converges”?

That question sounds philosophical, but it becomes precise once we separate three objects that are easy to confuse. The first is an **ordinary hypothetical proof**, in which a proposition is temporarily assumed while proving an implication. The second is an **infinite proof-shaped tree**, which can be understood through all of its finite portions. The third is a **cyclic dependency graph**, in which a purported proof eventually relies on itself. These three may look similar on paper. Mathematically, however, they behave very differently.

The central lesson is both constructive and cautionary. Infinite trees can be perfectly legitimate mathematical objects, and increasingly informative finite observations possess canonical limits. Yet a rule requiring proof dependencies to descend strictly through ordinal ranks cannot justify a cycle. It does exactly the opposite: it excludes every cycle. Meanwhile, the familiar statement $P\to P$ needs no circularity at all, and a precise version of the liar cannot coexist with exact reflection between truth and provability.

## The ordinary proof hiding inside $P\to P$

Begin with a language containing atomic propositions and implications. A **sequent** consists of a finite list of available assumptions, called its context, together with a conclusion. We need only two rules.

1. **Hypothesis rule.** If $A$ occurs in the context, conclude $A$.
2. **Implication introduction.** If $B$ can be derived while $A$ is added to the context, conclude $A\to B$ after discharging that temporary assumption.

Define the height of a derivation as the number of inference edges on its longest branch. A hypothesis leaf has height $0$, and applying implication introduction adds $1$.

**Identity Theorem.** For every proposition $P$, there is a derivation of $P\to P$ of height exactly $1$.

The proof is almost a sentence: assume $P$, use that assumption to conclude $P$, and discharge it. The hypothesis leaf has height $0$; the implication step raises the height to $1$.

This matters because “assume $P$ while proving $P\to P$” can sound self-referential. It is not. The temporary assumption is $P$, whereas the theorem being established is $P\to P$. There is no arrow from the proof back to itself. Ordinary hypothetical reasoning already explains the argument completely.

## Seeing an infinite tree one finite horizon at a time

Now consider a genuinely non-well-founded object. Give every possible node an **address**, represented by a finite list of natural numbers. The empty list names the root. Appending a child number moves one step downward. A labelled tree assigns either a label or “no node” to every address.

For a tree $T$ and depth $n$, its **truncation** $T_{\le n}$ keeps exactly the information at addresses of length at most $n$ and hides everything deeper. This simple operation gives an important stabilization law.

**Eventual Visibility Theorem.** If an address $p$ has length $|p|$, then truncating at depth $|p|$ already reveals exactly what the full tree says at $p$:

$$
T_{\le |p|}(p)=T(p).
$$

So every fixed node, however deep, becomes visible after finitely many approximation stages.

A one-node cyclic graph supplies the cleanest example. Imagine a single node labelled $a$ whose only child points back to itself. Unravelling that graph produces an infinite unary spine. Its nodes have addresses

$$
(),\quad (0),\quad (0,0),\quad (0,0,0),\quad \ldots
$$

and every one carries the label $a$.

**Unbounded Unravelling Theorem.** For every natural number $n$, the unravelling contains a node labelled $a$ at depth $n$.

The witness is the address consisting of $n$ copies of $0$. Its length is $n$, and it lies on the unary spine. Thus a finite cyclic description can denote a genuine infinite object. This phenomenon is familiar from recurring decimals and finite-state machines: finite syntax can generate infinite behavior.

But an infinite object is not thereby a valid proof. A wallpaper pattern may repeat forever without establishing a theorem. To talk about proof validity, one must add local inference rules and a global soundness condition.

## The information landscape has limits

The finite-viewpoint idea has an elegant order theory. An **observation** is a set of pairs $(p,a)$ saying that address $p$ has been observed with label $a$. Order observations by inclusion: $X\subseteq Y$ means that $Y$ contains at least as much information as $X$.

Suppose observations arrive in stages $C_0,C_1,C_2,\ldots$. Define their limit by union:

$$
C_\infty=\bigcup_{n\in\mathbb N} C_n.
$$

**Least-Upper-Bound Theorem.** The union $C_\infty$ is an upper bound of every stage, and it is contained in every other common upper bound. Explicitly,

$$
C_n\subseteq C_\infty\quad\text{for every }n,
$$

and if $C_n\subseteq U$ for every $n$, then $C_\infty\subseteq U$.

The proof follows element by element. Anything observed at stage $n$ belongs to the union. Conversely, anything in the union came from some stage, so every set containing all stages must contain it.

If the sequence is increasing, meaning $C_n\subseteq C_{n+1}$ for every $n$, then information never disappears. A short induction yields the further monotonicity fact that $C_m\subseteq C_n$ whenever $m\le n$.

This gives the ambient space of observations the structure needed for approximation: increasing countable chains have least upper bounds. Indeed, because arbitrary unions and intersections exist, the full observation space is a complete lattice.

There is an essential warning. The ambient lattice includes inconsistent observations—for example, two different labels assigned to the same address. The existence of limits therefore solves an information-assembly problem, not a soundness problem. A separate correctness predicate must say which labelled trees obey the intended inference rules and whether correctness survives passage to limits.

## Why descending ordinals destroy the loop

Ordinals extend the natural numbers far beyond the finite while retaining a strict, well-founded order. This makes them powerful progress measures. Assign each proof node $x$ an ordinal rank $\rho(x)$. Suppose every dependency edge from $x$ to a premise $y$ must strictly decrease rank:

$$
x\mathrel{D}y\quad\Longrightarrow\quad \rho(y)<\rho(x).
$$

At first glance, one might hope this condition makes self-reference safe. It does not.

**No Self-Reference Theorem.** No node can depend directly on itself under a strictly decreasing ordinal ranking.

A self-loop would require $\rho(x)<\rho(x)$, contradicting irreflexivity of strict order.

**No Ranked Cycle Theorem.** More generally, a dependency graph whose every edge strictly decreases ordinal rank contains no finite directed cycle.

Suppose a cycle visits $v_0,v_1,\ldots,v_n$ and returns to $v_0$. Following its edges gives

$$
\rho(v_1)<\rho(v_0),\quad \rho(v_2)<\rho(v_1),\quad\ldots,\quad
\rho(v_0)<\rho(v_n).
$$

Transitivity then yields $\rho(v_0)<\rho(v_0)$, impossible. The argument works for a loop of any finite length.

This reverses the proposed intuition. “Every reference goes to a smaller ordinal” is not a convergence test for circular proofs. It is an acyclicity certificate. Ordinal descent is useful precisely because it prevents a dependency from returning to where it began.

## The liar is an equation with no solution

The liar phenomenon can also be stripped to its mathematical core. Let $L$ be a proposition intended to say “I am not provable,” and let $Q$ stand for “$L$ is provable.” Demand two exact equivalences:

$$
Q\leftrightarrow L
$$

for perfect reflection between provability and truth in this instance, and

$$
L\leftrightarrow \neg Q
$$

for the liar equation itself.

**Liar Impossibility Theorem.** No pair of ordinary propositions $Q$ and $L$ satisfies both equivalences.

To see why, combine them to obtain $Q\leftrightarrow\neg Q$. If $Q$ holds, then it does not hold. If $Q$ does not hold, the reverse implication gives $Q$. Either case is contradictory.

The obstacle is therefore sharper than an undefined ordinal height. Under exact reflection and the negating fixed-point equation, there is no model at all. One of the demanded principles must be weakened, stratified, or interpreted in a richer semantics.

## A better road to disciplined circularity

None of this says that cyclic proof methods are hopeless. It says that the soundness condition must genuinely accommodate delay or progress rather than disguise acyclicity as circularity.

One promising idea is a **later modality**. A back-reference may be used at stage $n+1$ only if it was justified at the smaller stage $n$. The graph may be cyclic while semantic evaluation advances through finite indices. Another is a **global trace condition**: not every edge must decrease, but every infinite branch must encounter genuine progress infinitely often.

The observation lattice provides a natural stage on which to develop such ideas. Finite approximations can accumulate by union; locally correct finite evidence may converge to an infinite tree. The unresolved question is exactly when correctness is preserved by that limit.

The serpent, then, is not banished. It simply needs rules. An infinite unravelling can be mathematically real. A chain of observations can converge. But repetition alone does not certify truth, and strict ordinal descent cannot close a loop. The productive frontier lies between these facts: finding global conditions under which circular syntax earns a sound, non-circular meaning.
