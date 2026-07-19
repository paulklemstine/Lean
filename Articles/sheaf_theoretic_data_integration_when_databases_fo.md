# When Databases Behave Like Sheaves

## The difference between filling a blank and resolving a contradiction

A hospital combines laboratory results, medication records, and discharge summaries. A climate scientist joins readings from weather stations that overlap in space and time. A retailer reconciles inventories reported by stores, warehouses, and delivery systems. In each case, information arrives in pieces. Some cells are blank, and some pieces cover the same underlying fact.

It is tempting to treat these situations as one problem: “missing data.” But two mathematically different questions are hiding inside that phrase. The first is **completion**: can blank cells be assigned values? The second is **consistency**: can locally reported pieces be made to agree wherever they overlap?

Sheaf theory supplies an elegant vocabulary for the second question. Imagine that every region of a database—perhaps a subset of columns, a group of rows, or a collection of sensors—carries a local record. Whenever one region sits inside another, the larger record can be restricted to the smaller one. A family of local records is **compatible** when any two records give the same answer on their common part. The sheaf principle says that compatible local records glue to one global record, and that this global record is unique.

This perspective is powerful, but it also prevents an attractive mistake. Missingness alone is not generally an obstruction to gluing. If a cell may receive any value from a nonempty set, then every partial table has at least one completion. The interesting mathematics begins not with the blanks themselves, but with restrictions that connect different cells or views.

## A partial table always has a completion

Let $I$ be a set of database cells and let $V$ be a nonempty set of allowed values. A partial database specifies a value for some cells and leaves the rest blank. A **completion** is a total assignment $x:I\to V$ that agrees with every observed entry.

The basic completion theorem is simple and decisive:

**Completion Theorem.** Every partial database with values in a nonempty set has a total completion. If every cell is observed, the completion is unique. If at least one cell is missing and $V$ contains two distinct values, then at least two completions exist.

To see existence, choose any default value $v_0\in V$. Keep each observed value and put $v_0$ into every blank. If no cells are blank, agreement with the observations determines every value, so uniqueness follows. If a cell $i$ is blank and $a\ne b$ are allowed values, make two completions that differ only by assigning $a$ or $b$ at $i$.

This theorem overturns a proposed probability law. Suppose entries are independently missing with rate $r$, and suppose someone claims that the chance of completability is

$$
(1-r)^C,
$$

where $C$ counts overlap constraints. Under the partial-function model just described, the probability of completability is actually $1$ for every missingness pattern. For example, with $r=1/2$ and $C=1$, the proposed expression gives $1/2$, while every partial table still has a completion.

The formula fails because it confuses “this cell was observed” with “these two local reports agree.” Those are different events. A blank creates freedom; a disagreement creates an obstruction.

## Why counting overlaps can exaggerate difficulty

Once genuine equality constraints are introduced, consistency becomes nontrivial. But another trap appears: overlap equations need not be independent.

Consider three Boolean reports $x_1,x_2,x_3\in\{0,1\}$ and impose the triangle constraints

$$
x_1=x_2,\qquad x_2=x_3,\qquad x_1=x_3.
$$

There are three written equations, yet the third follows from the first two. Among the eight Boolean triples, only $(0,0,0)$ and $(1,1,1)$ are consistent, so the consistent fraction is $2/8=1/4$. Treating all three equations as independent events of probability $1/2$ predicts $1/8$, which is wrong.

The triangle illustrates a general root principle.

**Root-Constraint Theorem.** For any nonempty family $(x_i)_{i\in I}$, all pairwise equalities $x_i=x_j$ are equivalent to choosing one root $r\in I$ and requiring only $x_i=x_r$ for every $i\in I$.

One direction is immediate: pairwise equality includes equality with the root. Conversely, if every value equals the root, then $x_i=x_r=x_j$ for any pair $i,j$.

In network language, a connected cluster needs only enough independent equalities to connect all its vertices. Extra edges around cycles repeat information. If values come from a set of size $q$, then a graph with $c$ connected components has $q^c$ consistent assignments: choose one value independently for each component, and every vertex in that component is forced to share it. Thus consistency depends on connectivity or rank, not merely on the raw number of overlaps.

This matters in real data systems. Ten reconciliation rules can represent ten independent checks, or they can be ten ways of restating two underlying requirements. Any probability estimate that multiplies a success probability once per written rule must first justify independence.

## Imputation as constrained optimization

The sheaf viewpoint becomes constructive when observations are noisy or incomplete. Let the database have finitely many cells and a finite value set. Let $E$ be a finite family of equality constraints, each requiring two designated cells to agree. A total assignment is **feasible** if it satisfies every constraint.

Given an observed partial table $y$, define its observed Hamming loss by

$$
L(x;y)=\#\{i:\text{$i$ is observed and }x_i\ne y_i\}.
$$

A sheaf-style imputation seeks a feasible assignment minimizing $L$.

**Finite Constrained-Imputation Theorem.** For finite cells and finite values, provided the value set is nonempty, at least one feasible assignment minimizes observed Hamming loss under any finite family of equality constraints.

Feasibility is guaranteed by constant assignments: choose $v\in V$ and assign $v$ everywhere. Such an assignment satisfies every equality. The feasible set is finite and nonempty, and the integer-valued loss therefore attains a minimum.

This theorem separates two tasks cleanly. The constraints encode structural coherence; the objective measures fidelity to observations. The minimizer balances the two. It may preserve all observations when they are mutually compatible, or alter some observations when that is the least costly way to restore global consistency.

For equality constraints on a graph, the optimizer has a particularly transparent form. Each connected component must receive one common value. Therefore, for each component, count the observed occurrences of each value and select a most frequent one. Components can be processed independently. If there are $N$ cells, $M$ equality edges, and $Q$ possible values, connected components can be found in nearly linear time, and the value counts can be accumulated in $O(N)$ time.

## Why no imputation method wins everywhere

The promise of structural constraints can encourage a second overstatement: that a sheaf-based method must always outperform mean, nearest-neighbor, or other imputation methods whenever the missing rate is below $1/2$ and the feature count exceeds ten.

No distribution-free strict claim of this kind can hold. The reason is the boundary case $r=0$, which lies below $1/2$. With complete data, any observation-preserving method returns the observed truth. If the loss is zero when an estimate equals the truth, then both methods have loss zero and tie.

**No-Uniform-Strict-Superiority Theorem.** On complete data, any two imputation procedures that preserve all observations return the same true table and therefore tie under every loss normalized to vanish at the truth. Consequently, no theorem can assert strict superiority of one such method for every missing rate $r<1/2$ without additional assumptions.

This does not say structural imputation is ineffective. It says performance is a statistical question, not a consequence of terminology. To prove an expected advantage, one must specify how the ground truth is generated, how missingness occurs, how noise enters, and how faithfully the proposed restrictions describe the data. If the true table approximately follows a shared latent structure, consistency constraints may pool information and lower risk. If the constraints are wrong, they may force unrelated values together and increase error.

## A better probability question

The rejected expression $(1-r)^C$ can be replaced by more meaningful questions.

First, distinguish the random objects. Is only the missingness mask random? Are observed values random too? Are local reports noisy copies of a latent global state? Second, represent constraints by a graph or, more generally, by restriction maps. Third, count independent conditions through connected components or algebraic rank.

For a graph of equality constraints with $N$ vertices, $c$ connected components, and $q$ equally likely independent values at the vertices, the probability that a fully sampled assignment is consistent is

$$
\frac{q^c}{q^N}=q^{c-N}.
$$

This formula makes redundancy visible. Adding an edge inside an already connected component changes neither $c$ nor the probability. Adding an edge that joins two components decreases $c$ by one and multiplies the consistency probability by $1/q$. The relevant quantity is the number of independent mergers, $N-c$, not the number of edges.

Missingness then requires a separately specified observation model. If unobserved entries remain freely assignable, missingness may make observed compatibility easier rather than harder. If missing entries hide fixed latent values, the probability concerns recovery of those values, not mere existence of a completion. Precise modeling determines which question is being answered.

## From tables to systems of local knowledge

The sheaf metaphor is most useful when a database is not merely a rectangular array but a system of overlapping viewpoints. A patient’s medication appears in a prescription log, a pharmacy record, and a discharge plan. A city’s traffic state appears in neighboring sensor zones. A company’s revenue appears in product, regional, and consolidated reports. Restrictions describe how each broad view should agree with a narrower overlap.

The central lesson is both encouraging and cautionary. Local-to-global mathematics gives a principled language for consistency and a concrete route to constrained imputation. Yet the number of blanks does not by itself measure obstruction, and the number of written overlap rules does not measure independent information.

A sound workflow is therefore:

1. define the local records and their overlaps;
2. distinguish observed entries from compatibility constraints;
3. reduce redundant constraints using connectivity or rank;
4. optimize fidelity to observations over the feasible global assignments; and
5. compare methods under an explicit stochastic model.

Seen this way, data integration is not the art of pouring averages into empty boxes. It is the study of whether many partial stories can be told as one coherent story—and, when they cannot, of finding the smallest principled revision that makes them agree.
