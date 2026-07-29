# When a Research Process Rewrites Its Own Questions

## A mathematical story of reflection, finite progress, and convergence

Imagine a research team at the end of a long day. It does not merely update a spreadsheet of answers. It changes its vocabulary, replaces its instruments, revises what counts as evidence, and redesigns tomorrow’s experiment. The next question is shaped by today’s answer. A negative result may eliminate an entire family of tests; a new theory may make previously meaningless measurements relevant. The process is not just learning within a fixed framework. It is rewriting the framework itself.

That kind of self-modification appears difficult to analyze. Ordinary iterative models assume that every step has the same form: choose a point from one fixed space, apply one fixed rule, repeat. Reflective research violates that picture. The evidence available tomorrow depends on the state reached today. Yet a clean mathematical principle shows that such a process can still be forced to settle down.

The key is to separate two layers. The **rich layer** records the full research state: hypotheses, methods, conventions, unresolved questions, and admissible evidence. The **coarse layer** assigns each state a finite, integer-valued quality rank. If revisions never lower rank, rank is bounded by a fixed capacity, and any revision that fails to raise rank leaves the entire state unchanged, then every possible run eventually becomes constant. Once constant, it converges in the strongest possible sense for a discrete state space.

This is a theorem about why open-ended reflection can terminate without pretending that research states are simple numbers.

## States whose evidence changes with them

Let $C$ be a collection of possible research cycles. For each cycle $c\in C$, let $E(c)$ be the collection of outcomes or evidence admissible at that cycle. The notation matters: there is not one universal evidence set $E$. There is a family $E(c)$ indexed by the current cycle.

A revision rule takes a current cycle and evidence appropriate to that cycle and returns a new cycle:

$$
R(c,e)\in C \qquad \text{for } e\in E(c).
$$

A run consists of cycles $c_0,c_1,c_2,\ldots$ and selected outcomes $e_0,e_1,e_2,\ldots$ satisfying

$$
e_n\in E(c_n), \qquad c_{n+1}=R(c_n,e_n).
$$

This small change from a fixed evidence space to the indexed family $E(c)$ captures genuine self-modification. A cycle devoted to geometric conjectures may admit diagrams and incidence data; after revision into an algebraic cycle, its admissible evidence may instead consist of symbolic identities. The model does not force these outcomes into an artificial common format.

Now assign each cycle a quality rank

$$
q:C\to \mathbb{N}.
$$

The rank is not meant to describe everything about a cycle. It is a progress certificate. Assume there is a finite capacity $K\in\mathbb{N}$ such that every cycle satisfies $q(c)\le K$. Assume also that revision never decreases quality:

$$
q(c)\le q(R(c,e))
$$

for every $c\in C$ and every $e\in E(c)$.

The decisive assumption concerns plateaus:

$$
q(R(c,e))=q(c) \quad\Longrightarrow\quad R(c,e)=c.
$$

In words, a rank-neutral revision is not allowed to rearrange the system invisibly. If the measured quality does not rise, the whole cycle must remain unchanged. This is the bridge from a coarse numerical score back to the full reflective state.

## The staircase that cannot rise forever

Along any run, define $a_n=q(c_n)$. Monotonicity of revision gives

$$
a_0\le a_1\le a_2\le \cdots\le K.
$$

This is a staircase with only finitely many possible heights. It cannot rise strictly forever. More precisely, the set of attained values is a nonempty subset of $\{0,1,\ldots,K\}$, so it has a largest value $L$. Choose a time $N$ at which that value is attained: $a_N=L$.

For any later time $n\ge N$, monotonicity gives $a_N\le a_n$, while maximality gives $a_n\le L=a_N$. Hence $a_n=L$. The quality rank is constant from time $N$ onward.

A constant score alone would normally prove little. Two radically different theories might receive the same rating. But the plateau condition rules out motion at equal rank. Since

$$
q(c_{n+1})=q(c_n)
$$

for every $n\ge N$, it follows that $c_{n+1}=c_n$. Induction now yields

$$
c_n=c_N \qquad \text{for every } n\ge N.
$$

This is the **Eventual Stabilization and Convergence Theorem**: every dependent reflective run satisfying monotone bounded quality and plateau stability reaches a cycle after which no selected revision changes anything.

There is also an immediate **Selected-Outcome Fixed-Point Theorem**. For all sufficiently late $n$,

$$
R(c_n,e_n)=c_n.
$$

Thus every outcome actually selected after stabilization acts as a fixed-point witness for the limiting cycle.

## Why topology appears

Convergence is usually associated with distances: points get closer and closer to a limit. But a collection of symbolic research states may have no natural distance. The appropriate basic model is the discrete topology, in which every individual state is an open neighborhood of itself.

In a discrete space, a sequence converges to $c_*$ precisely when it is eventually equal to $c_*$. The theorem above provides exactly that. Once $c_n=c_N$ for all $n\ge N$, every neighborhood of $c_N$ contains every sufficiently late term. Therefore

$$
c_n\longrightarrow c_N.
$$

This topological conclusion does not add a hidden metric. It says that stabilization is already the strongest convergence notion naturally available for sharply distinguishable states.

## A concrete miniature

Suppose cycles have ranks from $0$ through $8$. At rank $r$, the admissible outcomes are integers from $0$ through $8-r$. Let an outcome $g$ propose a quality gain, and define the revision to increase rank by $\min(g,8-r)$. To make plateau stability hold, the full state is identified by its rank; a zero gain leaves it unchanged.

Starting at rank $1$ and selecting gains $2,1,3,4,0,2$ gives

$$
1,3,4,7,8,8,8,\ldots.
$$

Notice how the outcome type contracts: at rank $1$, gains as large as $7$ are admissible; at rank $7$, only $0$ or $1$ is admissible; at rank $8$, only $0$ remains. The process changes not only its state but also the menu of meaningful next observations. Nevertheless, the bounded staircase reaches $8$, and plateau stability freezes the cycle.

A more realistic model could let a cycle contain a theory, a dataset, and a protocol, while the rank measures validated milestones. The theorem would not say which outcome appears, whether revisions are efficient, or whether the rank captures scientific truth. It says something conditional and exact: if every allowed revision respects the progress certificate and rank-neutral changes are impossible, endless self-rewriting cannot occur.

## Where the assumptions do real work

Each hypothesis blocks a distinct failure mode.

Without monotonicity, a process may oscillate forever between high and low quality. Without a finite bound, it may improve forever through ranks $0,1,2,\ldots$ and never settle. Without plateau stability, quality may become constant while the underlying cycle alternates between two equally ranked states. The last counterexample is especially important. A bounded score does not by itself control a rich state; equality of score must have structural force.

The result also makes a careful distinction between selected and unselected outcomes. After stabilization, the outcomes that the run actually chooses leave the cycle fixed. This does **not** automatically imply that every conceivable element of $E(c_N)$ would do so. To reach that stronger conclusion one needs an exploration or fairness assumption ensuring that relevant outcomes are eventually tested, or a uniform property of the revision rule.

Nor does the theorem provide a universal bound on the time index $N$. There can be arbitrarily long stretches only if the state remains unchanged, because a rank-neutral step is fixed. If one stops at the first unchanged state, then the number of strict changes is at most $K-q(c_0)$. But a run may continue listing the same stabilized cycle forever, as a mathematical sequence naturally does.

## Connections beyond research teams

The same architecture appears in software that updates its own policy, theorem-discovery systems that change their conjecture language, adaptive experimental design, and organizations that rewrite their decision procedures. In each case the next action belongs to a menu determined by the current state. A scalar potential or ranking function then acts as a termination certificate.

In program analysis, such a rank resembles a variant used to prove termination. In order theory, bounded natural ranks satisfy an ascending-chain condition: no infinite strictly increasing chain exists. In dynamical systems, the rank resembles a Lyapunov function, except that it increases rather than decreases. In topology, eventual equality produces convergence in a discrete space. The reflective model joins these ideas without flattening its state-dependent evidence into a fixed input alphabet.

That combination suggests a design principle. If we want a self-revising process to converge, we should not merely reward improvement. We should choose a bounded progress measure and require **extensional honesty at plateaus**: a claimed no-gain revision must truly make no change. The rank need not encode the state, but equality across a revision must certify identity.

## The frontier: softer notions of settling

Exact stabilization is powerful, but it is also rigid. Real research may continue making tiny changes after major progress has saturated. A natural extension gives cycles a metric $d$ and replaces exact plateau stability with an estimate such as

$$
d(R(c,e),c)\le \phi\bigl(q(R(c,e))-q(c)\bigr),
$$

where small gains force small revisions. If total gains are summable in a richer real-valued model, one may hope to prove that the cycles form a Cauchy sequence even when they never become literally identical.

Another extension replaces natural ranks by a partially ordered set with no infinite ascending chains. A third introduces fair exploration, seeking a limiting cycle fixed under every admissible outcome rather than only those selected by one run. Transfinite time could model revision processes with limit stages. Logical interpretations could treat cycles as theories and outcomes as certificates or countermodels.

The central insight survives all these directions. Reflection looks unruly because it changes the rules of its own next step. But dependent evidence and global convergence are compatible. Once the changing process casts a bounded, monotone shadow—and once a stationary shadow forces a stationary object—the apparent maze collapses into a finite staircase. The system may rewrite its questions, its evidence, and its methods. It cannot climb forever, and when climbing stops, so does the rewriting.
