# Finite Causal Cones and Exact Local Simulation in Conway’s Game of Life

**Aristotle**  
**July 29, 2026**

## Abstract

Conway’s Game of Life is a synchronous cellular automaton on the infinite integer lattice. Although a global configuration contains infinitely many cells, every update is local. This paper develops that locality into an explicit finite simulation principle. We define the Moore neighborhood, the B3/S23 transition rule, finite-time evolution, and a recursively generated dependency cone for a selected spacetime point. We prove that each cell has exactly eight neighbors, that the empty configuration is invariant, and that agreement of two configurations on one closed neighborhood forces agreement at the center after one step. The principal theorem states that agreement on the depth-$t$ dependency cone of a cell $p$ guarantees agreement at $p$ after $t$ generations. The cone is finite and has cardinality at most $9^t$, yielding a combined correctness-and-overhead certificate for direct local simulation. We describe recursive and memoized algorithms realizing this theorem, explain how the result supports finite-window experiments and compositional noninterference arguments, and distinguish this causal foundation from a complete constructive proof of computational universality. A roadmap identifies the additional pattern, circuit, memory, and compiler results needed for such a theorem.

## 1. Introduction

Conway’s Game of Life is defined by one of the shortest rule sets in discrete dynamics. A square lattice extends through the plane; each cell is alive or dead; all cells update simultaneously from the states of their eight nearest horizontal, vertical, and diagonal neighbors. Despite this local definition, the global system supports stable objects, periodic oscillation, moving patterns, and elaborate interactions.

The infinite lattice creates an immediate foundational question for exact simulation. To determine the state of one cell after a finite number of generations, must one know the entire initial configuration? The intuitive answer is no: information travels through local updates and therefore has finite speed. Turning that intuition into a useful theorem requires three ingredients. First, the local rule must be stated without ambiguity. Second, the relevant initial region must be constructed explicitly rather than described vaguely as “nearby.” Third, the construction must come with both a correctness theorem and a quantitative size bound.

We provide those ingredients. For a target cell $p$ and time $t$, we recursively define a finite set $D_t(p)$. At depth zero it contains only $p$. At each later depth it is enlarged by taking the union of the closed Moore neighborhoods of all cells already present. This set traces every possible backward chain of local dependence from the spacetime point $(p,t)$ to time zero.

Our central conclusion is:

> If two initial configurations agree on $D_t(p)$, then their evolutions agree at $p$ after $t$ generations; moreover, $|D_t(p)|\le 9^t$.

The first clause is semantic: it says the set contains all information relevant to the requested output. The second is computational: it bounds the amount of initial data required by a direct recursive simulator. The estimate $9^t$ is intentionally coarse. On the square lattice the distinct cells in the cone actually form a Chebyshev ball of radius $t$, containing $(2t+1)^2$ cells. Establishing that equality is a natural geometric strengthening, but it is not needed for the locality theorem or its elementary branching bound.

These results are foundational for rigorous constructions of computation in Life, but they do not constitute a universality proof. A complete constructive result would have to define signal encodings, verify moving patterns and gates, establish timing and separation conditions, compile a universal machine, and quantify the total simulation overhead. The present work supplies the finite-causality and noninterference principles such a development needs.

## 2. State space and transition semantics

### 2.1 Cells and configurations

Let

$$
L=\mathbb{Z}\times\mathbb{Z}
$$

be the integer square lattice. An element $p=(x,y)\in L$ is called a **cell**. Let $\mathbb{B}=\{0,1\}$, with $1$ denoting alive and $0$ denoting dead.

**Definition 2.1 (Configuration).** A configuration is a function

$$
c:L\to\mathbb{B}.
$$

No finiteness assumption is imposed: a configuration may contain infinitely many live cells. This generality is important because the locality theorem should not depend on an empty or periodic background.

### 2.2 Moore neighborhoods

For $p=(x,y)$, define its **Moore neighborhood** by

$$
N(p)=\{(x+i,y+j): i,j\in\{-1,0,1\},\ (i,j)\ne(0,0)\}.
$$

Define the **closed Moore neighborhood** by

$$
\overline{N}(p)=N(p)\cup\{p\}.
$$

**Lemma 2.2 (Neighborhood cardinalities).** For every $p\in L$,

$$
|N(p)|=8
\qquad\text{and}\qquad
|\overline{N}(p)|=9.
$$

**Proof sketch.** The nine offset pairs in $\{-1,0,1\}^2$ are distinct. Removing $(0,0)$ leaves eight offsets, and translation by $p$ preserves distinctness. Restoring the center gives nine cells. $\square$

For a configuration $c$, define the live-neighbor count at $p$ as

$$
\nu_c(p)=\sum_{q\in N(p)}c(q).
$$

Here the values $0$ and $1$ are regarded as integers in the sum.

**Corollary 2.3 (Neighbor-count bound).** For every configuration $c$ and cell $p$,

$$
0\le \nu_c(p)\le 8.
$$

**Proof sketch.** The sum has exactly eight terms, each at most $1$ and at least $0$. $\square$

### 2.3 The B3/S23 rule

Define the local transition function $R:\mathbb{B}\times\mathbb{N}\to\mathbb{B}$ by

$$
R(a,n)=1
\quad\Longleftrightarrow\quad
n=3\ \text{or}\ (a=1\ \text{and}\ n=2).
$$

This is the usual B3/S23 rule: birth occurs at neighbor count $3$, while survival occurs at counts $2$ and $3$. Define the global one-step operator $S$ by

$$
S(c)(p)=R(c(p),\nu_c(p)).
$$

The updates are synchronous: every value on the right-hand side is read from the same old configuration $c$. For $t\in\mathbb{N}$, define finite-time evolution recursively by

$$
S^0(c)=c,
\qquad
S^{t+1}(c)=S(S^t(c)).
$$

**Lemma 2.4 (Dead zero-neighborhood case).** A dead cell with no live neighbors remains dead:

$$
R(0,0)=0.
$$

**Proof sketch.** Neither disjunct in the condition defining $R$ is satisfied: $0\ne3$, and the cell is not alive. $\square$

## 3. Baseline dynamics and one-step locality

Let $\mathbf{0}$ denote the all-dead configuration, defined by $\mathbf{0}(p)=0$ for every $p\in L$.

**Theorem 3.1 (One-step stability of the empty configuration).**

$$
S(\mathbf{0})=\mathbf{0}.
$$

**Proof sketch.** Every cell has eight dead neighbors, so its live-neighbor count is $0$. Each cell is itself dead. Lemma 2.4 therefore applies at every lattice point. Equality follows pointwise. $\square$

**Theorem 3.2 (Finite-time stability of the empty configuration).** For every $t\in\mathbb{N}$,

$$
S^t(\mathbf{0})=\mathbf{0}.
$$

**Proof sketch.** Induct on $t$. The case $t=0$ is the definition of iteration. If the claim holds at $t$, then

$$
S^{t+1}(\mathbf{0})=S(S^t(\mathbf{0}))=S(\mathbf{0})=\mathbf{0}
$$

by the induction hypothesis and Theorem 3.1. $\square$

The next theorem isolates the exact information used by one update.

**Theorem 3.3 (One-Step Locality).** Let $c$ and $d$ be configurations and let $p\in L$. If

$$
c(q)=d(q)\qquad\text{for every }q\in\overline{N}(p),
$$

then

$$
S(c)(p)=S(d)(p).
$$

**Proof sketch.** Agreement at $p$ gives $c(p)=d(p)$. Agreement at each point of $N(p)$ makes the eight summands in $\nu_c(p)$ and $\nu_d(p)$ equal, hence the live-neighbor counts are equal. The same pair consisting of current state and neighbor count is supplied to $R$, so the outputs coincide. $\square$

This result is a precise one-generation speed limit. Changes outside $\overline{N}(p)$ cannot affect $p$ in the next generation, regardless of the size or complexity of those changes.

## 4. Recursive dependency cones

### 4.1 Definition

**Definition 4.1 (Dependency cone).** For $p\in L$ and $t\in\mathbb{N}$, define $D_t(p)$ recursively by

$$
D_0(p)=\{p\},
$$

and

$$
D_{t+1}(p)=\bigcup_{q\in D_t(p)}\overline{N}(q).
$$

Every $D_t(p)$ is finite: the base set is finite, and each successor is a finite union of finite nine-cell sets. The word “cone” refers to the corresponding spacetime picture. Starting from a point at time $t$ and moving backward one generation permits displacement by at most one unit in each coordinate. Repetition produces a widening family of finite slices.

Two immediate consequences restate the recursive construction.

**Lemma 4.2 (Time-zero membership).** For every $p\in L$,

$$
p\in D_0(p).
$$

**Proof sketch.** By definition, $D_0(p)$ is the singleton $\{p\}$. $\square$

**Lemma 4.3 (Successor expansion).** For every $t\in\mathbb{N}$ and $p\in L$,

$$
D_{t+1}(p)=\bigcup_{q\in D_t(p)}\overline{N}(q).
$$

**Proof sketch.** This is the successor clause of Definition 4.1. $\square$

The following nesting relation connects cones based at neighboring cells.

**Lemma 4.4 (Cone transport through one local step).** If $q\in\overline{N}(p)$, then for every $t\in\mathbb{N}$,

$$
D_t(q)\subseteq D_{t+1}(p).
$$

**Proof sketch.** For $t=0$, $D_0(q)=\{q\}$ and $q$ belongs to the closed neighborhood of $p$, which is $D_1(p)$. For the inductive step, take $r\in D_{t+1}(q)$. Then $r$ lies in $\overline{N}(s)$ for some $s\in D_t(q)$. By induction, $s\in D_{t+1}(p)$. The successor definition places the entire set $\overline{N}(s)$ inside $D_{t+2}(p)$, so $r\in D_{t+2}(p)$. $\square$

Equivalently, a causal chain of length $t$ ending at a neighbor $q$ can be extended by one step to a causal chain of length $t+1$ ending at $p$.

### 4.2 Exact local determinacy

We now prove that the recursively constructed cone is sufficient for prediction.

**Theorem 4.5 (Finite Dependency Theorem).** Let $c,d:L\to\mathbb{B}$ be configurations, let $p\in L$, and let $t\in\mathbb{N}$. Suppose

$$
c(q)=d(q)\qquad\text{for every }q\in D_t(p).
$$

Then

$$
S^t(c)(p)=S^t(d)(p).
$$

**Proof sketch.** We prove the stronger statement simultaneously for every target cell $r$ by induction on $t$.

At $t=0$, the hypothesis says that $c$ and $d$ agree on $D_0(r)=\{r\}$. Hence $c(r)=d(r)$, which is the desired equality because $S^0$ is the identity.

Assume the result at time $t$, and suppose $c$ and $d$ agree on $D_{t+1}(r)$. To compare $S^{t+1}(c)(r)$ and $S^{t+1}(d)(r)$, use Theorem 3.3. It is enough to prove that $S^t(c)$ and $S^t(d)$ agree at every $q\in\overline{N}(r)$. Fix such a $q$. By Lemma 4.4,

$$
D_t(q)\subseteq D_{t+1}(r).
$$

Thus the original configurations agree on $D_t(q)$. The induction hypothesis gives

$$
S^t(c)(q)=S^t(d)(q).
$$

This holds throughout the closed neighborhood of $r$. Applying one-step locality completes the induction. $\square$

The theorem is insensitive to all initial data outside $D_t(p)$. The configurations may differ at one outside cell, at infinitely many outside cells, or everywhere outside the cone; the selected output remains equal.

**Corollary 4.6 (Finite-background replacement).** Given $c$, $p$, and $t$, define a configuration $c'$ that agrees with $c$ on $D_t(p)$ and is dead outside $D_t(p)$. Then

$$
S^t(c')(p)=S^t(c)(p).
$$

**Proof sketch.** The configurations agree on the dependency cone, so Theorem 4.5 applies. $\square$

This corollary justifies replacing an arbitrary infinite background by a finite supported representative when computing one selected output.

## 5. Cardinality and complexity

### 5.1 A branching bound

**Theorem 5.1 (Dependency-Cone Cardinality Bound).** For every $t\in\mathbb{N}$ and $p\in L$,

$$
|D_t(p)|\le 9^t.
$$

**Proof sketch.** Proceed by induction. At time zero,

$$
|D_0(p)|=1=9^0.
$$

Assume $|D_t(p)|\le9^t$. By the successor definition and the elementary union bound,

$$
\begin{aligned}
|D_{t+1}(p)|
&=\left|\bigcup_{q\in D_t(p)}\overline{N}(q)\right|\\
&\le\sum_{q\in D_t(p)}|\overline{N}(q)|\\
&=\sum_{q\in D_t(p)}9\\
&=9|D_t(p)|\\
&\le9\cdot9^t=9^{t+1}.
\end{aligned}
$$

Overlap among closed neighborhoods can only reduce the cardinality of their union, so no disjointness assumption is needed. $\square$

The theorem gives a direct recursive simulation bound. Each requested spacetime value at depth $t+1$ asks for at most nine values at depth $t$: the center state and its eight neighbors. A full recursion tree therefore has branching factor at most $9$ and at most $9^t$ leaves.

### 5.2 Combined certificate

**Theorem 5.2 (Finite Simulation Certificate).** Fix a configuration $c$, a target cell $p$, and a time $t$. The finite set $D_t(p)$ satisfies both

$$
|D_t(p)|\le9^t
$$

and the following universal correctness property: for every configuration $d$, if

$$
d(q)=c(q)\qquad\text{for every }q\in D_t(p),
$$

then

$$
S^t(d)(p)=S^t(c)(p).
$$

**Proof sketch.** The cardinality clause is Theorem 5.1, and the semantic clause is Theorem 4.5. Combining them yields one witness set with both properties. $\square$

This theorem has the form of a certificate: it identifies a bounded finite input set and proves that agreement on that set is sufficient for the requested output.

### 5.3 Coarse and geometric complexity

The estimate $9^t$ counts possible recursive branches rather than distinct lattice cells. Closed neighborhoods overlap heavily. Indeed, elementary coordinate reasoning suggests the exact identity

$$
D_t(p)=\{q\in L:\|q-p\|_\infty\le t\},
$$

where, for $p=(x,y)$ and $q=(u,v)$,

$$
\|q-p\|_\infty=\max(|u-x|,|v-y|).
$$

That square has exactly

$$
(2t+1)^2
$$

cells. The exact identity and count are not required by the preceding theorems and are left as a geometric refinement. Accordingly, only the $9^t$ upper bound is claimed here.

The distinction leads to three cost models:

1. **Unmemoized recursive evaluation.** The recursion tree has at most $9^t$ leaves and total size of the same exponential order.
2. **Memoized local evaluation.** Identical spacetime subproblems are stored once. The number of distinct subproblems is bounded by the sum of the spatial cone slices. Under the exact-square refinement this sum is of order $t^3$.
3. **Window evolution.** One may evolve a finite square large enough to contain all relevant slices. If the entire initial radius-$t$ square is updated for $t$ generations, a straightforward implementation also uses polynomial work, although it may compute cells not needed by the target.

The proved $9^t$ estimate is therefore a correctness-oriented upper bound, not a claim of optimal computational complexity.

## 6. Algorithms

### 6.1 Constructing the dependency cone

The finite set can be generated iteratively.

**Algorithm 1 (Iterative Dependency-Cone Expansion).**

**Input:** target $p\in L$ and depth $t\in\mathbb{N}$.  
**Output:** $D_t(p)$.

1. Initialize $D\leftarrow\{p\}$.
2. Repeat $t$ times:
   1. initialize $E\leftarrow\varnothing$;
   2. for each $q\in D$, insert every point of $\overline{N}(q)$ into $E$;
   3. set $D\leftarrow E$.
3. Return $D$.

Using a hash set, duplicate points from overlapping neighborhoods are automatically merged. If $m_s=|D_s(p)|$, step $s$ performs at most $9m_s$ insertions. The proved estimate gives the coarse total bound

$$
9\sum_{s=0}^{t-1}9^s=O(9^t).
$$

The actual lattice geometry produces much smaller sets.

### 6.2 Recursive single-cell evaluation

**Algorithm 2 (Memoized Backward-Cone Evaluation).**

**Input:** an initial state oracle $c$, target $p$, and time $t$.  
**Output:** $S^t(c)(p)$.

1. Define a function $V(q,s)$.
2. If $(q,s)$ is cached, return the cached value.
3. If $s=0$, return $c(q)$.
4. Recursively evaluate $V(r,s-1)$ for all $r\in\overline{N}(q)$.
5. Count the live values on $N(q)$ and apply the B3/S23 rule using the center value $V(q,s-1)$.
6. Cache and return the result.
7. Return $V(p,t)$.

Correctness follows by induction from the definition of $S^t$; finiteness and the relevant initial-data bound follow from Theorems 4.5 and 5.1. Memoization is not required for correctness but prevents repeated evaluation of overlapping subproblems.

### 6.3 Finite-window evolution

**Algorithm 3 (Padded Finite-Window Simulation).**

For a finite set of requested cells $T$ at time $t$, start from the union

$$
W=\bigcup_{p\in T}D_t(p).
$$

Read the initial configuration only on $W$. To evolve forward, retain nested slices: at generation $s$, compute values only where enough padding remains to reach a target at generation $t$. The One-Step Locality Theorem ensures that discarding cells outside the next required slice cannot alter requested outputs. Applying Theorem 4.5 target by target proves correctness.

This method is suited to batch outputs and visual demonstrations. It also makes boundary handling explicit: a boundary condition is harmless only when the boundary lies outside every relevant dependency cone.

## 7. Applications

### 7.1 Exact finite experiments on an infinite lattice

Many Life experiments begin with finitely many live cells, but the mathematical board is infinite. The finite dependency theorem reconciles these views. For a fixed observation region and time horizon, only a finite initial window matters. An implementation may therefore store sparse finite sets while retaining an exact interpretation on the infinite lattice.

The theorem also prevents a common simulation error. If a finite display window is treated as the whole world, artificial boundary rules can send effects inward. Correctness is guaranteed only when the target’s dependency cone remains inside the represented region, or when omitted initial values are supplied exactly.

### 7.2 Noninterference and modular pattern design

Suppose two pattern components occupy separated regions. To prove that one component cannot affect an output of the other before time $t$, it is enough to show that the first component lies outside the output’s depth-$t$ dependency cone. More generally, if all possible differences between two environments are outside that cone, Theorem 4.5 identifies their outputs.

This converts geometric separation into semantic independence. Such a principle is central when composing moving signals and logic components: a claimed gate must work not only in one screenshot but under a precisely specified class of surrounding configurations.

### 7.3 Local certificates for output cells

Theorem 5.2 can be read as a certificate format. A certificate for the value at $(p,t)$ consists of the finite initial restriction $c|_{D_t(p)}$. Any completion of that restriction to an infinite configuration yields the same target value. Independent evaluators can therefore compare finite data rather than exchange entire configurations.

### 7.4 Foundations for constructive universality

A direct proof of universality requires a simulation relation between machine states and Life configurations. Each simulated transition must be shown to produce the correct encoded successor, and independently placed components must not interfere outside intended channels. Finite causal cones can bound what must be checked for each transition and provide clearance conditions between gadgets.

Nevertheless, locality alone does not supply any computational gadget. It proves neither a glider theorem nor a gate truth table, memory behavior, clocking, fanout, crossing, or compilation. Calling the present result a universality theorem would therefore overstate its scope.

## 8. Discussion

The argument relies on only two structural features: finite neighborhoods and synchronous local evolution. Its form generalizes to other cellular automata. If every cell’s next state depends on a closed neighborhood of cardinality at most $k$, the analogous recursively expanded cone has cardinality at most $k^t$, and agreement on that cone forces agreement after $t$ steps. For Life, $k=9$ because the update reads the center and eight neighbors.

The bound is robust because it avoids geometric assumptions. It would remain valid on an irregular graph of maximum closed-neighborhood size $9$, even if no square-coordinate description existed. Conversely, exploiting the special geometry of $\mathbb{Z}^2$ yields better counting. This separation between a general branching argument and a model-specific geometric refinement is methodologically useful.

The empty-configuration theorem also interacts with finite causality. If the initial live pattern is finite, cells sufficiently far away have an all-dead dependency cone for a specified time horizon and hence remain dead during that horizon. This gives a finite propagation statement for activity, although a sharp support-growth theorem would again benefit from Chebyshev distance.

The recursive cone is an overapproximation of semantic relevance. Some cells inside it may not affect a particular initial configuration or output because the Boolean rule can mask changes. For example, changing one neighbor may leave the neighbor count within a range producing the same result. The cone records possible structural dependence uniformly over all configurations, not minimal influence for one instance. Determining instance-specific minimal certificates is a different computational problem.

## 9. Future work

The next step is a sharper geometric light-cone theorem: define Chebyshev distance and prove that $D_t(p)$ is exactly the radius-$t$ square around $p$. This replaces the coarse bound $9^t$ by the exact count $(2t+1)^2$ for distinct initial cells.

Pattern-level work should then proceed constructively:

1. Define translations, quarter-turn rotations, and reflections of finite patterns, and prove that evolution commutes with these symmetries.
2. Establish the stability of the block and the period-two behavior of the blinker directly from the local rule.
3. Define all four phases of a glider and prove that four generations translate it by $(1,1)$, with background control supplied by finite causality.
4. Specify finite spacetime signal ports, including phase, rails, and clearance regions.
5. Verify a concrete functionally complete gate such as NAND for every Boolean input assignment, including restoration of a reusable output signal.
6. Develop wires, delays, fanout, and crossings with explicit latency and area bounds.
7. Compile Boolean circuits by recursive placement and routing, proving semantic correctness and polynomial overhead.
8. Add clocked memory and compile a universal register machine or Turing machine transition system.
9. State a final simulation theorem with concrete encoder, decoder, per-transition correctness, noninterference, initialization, and explicit temporal and spatial overhead.

Truth tables for isolated output cells would not suffice. A credible universality theorem must control complete signal formats and the interactions of composed components.

## 10. Conclusion

Conway’s Game of Life evolves on an infinite lattice, but a finite-time local observation has a finite causal past. The dependency cone $D_t(p)$ is generated by repeatedly adjoining closed Moore neighborhoods. Agreement on this explicit set guarantees agreement at the target after $t$ generations, and the set contains at most $9^t$ cells. Together these facts provide an exact finite simulation certificate for one output cell.

The result clarifies both what has been achieved and what remains. Local simulation, finite-speed dependence, and a direct overhead bound are established. The stronger construction of universal computation requires verified moving patterns, interfaces, gates, routing, memory, and a compiler. Finite causal cones provide the boundary discipline needed to pursue that program one component at a time.