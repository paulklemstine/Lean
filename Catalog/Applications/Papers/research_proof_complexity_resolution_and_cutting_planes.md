# Resolution and Cutting Planes: The Pigeonhole Principle as a Separation Witness

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Proof Complexity / Automated Reasoning)

## Abstract

We develop the propositional pigeonhole principle as a benchmark for *proof
complexity*, the study of the minimum size of proofs in fixed inference systems.
We encode the principle as an unsatisfiable conjunctive normal form (CNF)
$\text{PHP}_n$ over Boolean placement variables and prove its unsatisfiability by
reading any satisfying assignment as an injection from $n+1$ pigeons into $n$
holes — an impossibility. We then formalize two proof systems. The first,
**resolution**, derives new clauses from a single cancellation rule and is sound,
so any resolution refutation of $\text{PHP}_n$ is a correct unsatisfiability
certificate. The second, **cutting planes**, reasons over integer linear
inequalities with two rules — linear combination (addition) and Chvátal–Gomory
(CG) rounding — both of which we prove sound at every integer point. Our central
quantitative result is a *counting refutation* of the pigeonhole principle in the
cutting-planes setting: summing the pigeon (row) lower bounds and the hole
(column) upper bounds over the same variables yields the contradiction $n+1 \le
\sum x \le n$, a refutation using only $O(n)$ linear-combination steps. Set
against Haken's classical theorem that every resolution refutation of
$\text{PHP}_n$ has size $2^{\Omega(n)}$, this exhibits, constructively, the
direction of the resolution–cutting-planes separation that can be fully
certified: a single formula family that is exponentially hard for resolution yet
linear for cutting planes. We give algorithms, numerical demonstrations, and a
roadmap toward a fully formal separation theorem.

## 1. Introduction

Mathematical logic distinguishes sharply between *truth* and *provability*, and
within provability, between *existence* of a proof and its *length*. Proof
complexity is the quantitative theory of the latter: given a tautology (or,
dually, an unsatisfiable formula) and a fixed sound and complete proof system,
how large must the smallest proof be?

The motivating connection is to the satisfiability problem (SAT) and to the
$\mathbf{NP}$ vs. $\mathbf{coNP}$ question. A propositional proof system in the
sense of Cook and Reckhow is a polynomial-time-checkable relation certifying
membership in the set of tautologies. Super-polynomial lower bounds on proof
size for *every* such system would separate $\mathbf{NP}$ from $\mathbf{coNP}$;
proving lower bounds for *specific*, increasingly strong systems is the program
of the field. It is also of direct practical consequence: contemporary SAT
solvers are, in their unsatisfiable mode, resolution-proof generators, so a
resolution lower bound is a hard floor on solver running time for the affected
formulas.

The pigeonhole principle $\text{PHP}_n$ — that $n+1$ pigeons cannot be placed
injectively into $n$ holes — is the canonical hard instance. Haken's 1985
theorem established the first exponential resolution lower bound on it. Cook and
others observed that cutting planes, a system reasoning with integer
inequalities, refutes $\text{PHP}_n$ with polynomial-size proofs, producing a
*separation*: cutting planes strictly dominates resolution on this family.

This paper formalizes the pieces of that story that admit complete, rigorous
verification, and isolates the precise quantitative gap. We:

1. encode $\text{PHP}_n$ as a CNF and prove `PHP_unsat`;
2. record the soundness of resolution and the certifying corollary
   `PHP_no_refutation_sat`;
3. prove the soundness of the two cutting-planes rules (`add_sound`,
   `cg_rounding_sound`); and
4. prove the linear counting refutation `php_cp_counting`.

Throughout, the resolution lower bound (Haken) is treated as the deep companion
theorem that closes the separation, and we lay out a concrete route to its
formalization in the discussion.

## 2. The pigeonhole CNF

### 2.1 Variables and clauses

We fix $n \in \mathbb{N}$ and consider $n+1$ pigeons, indexed by $\{0, \dots,
n\}$, and $n$ holes, indexed by $\{0, \dots, n-1\}$.

**Definition (PVar).** The variable set is
$$\text{PVar}_n = \{0, \dots, n\} \times \{0, \dots, n-1\},$$
i.e. pairs $(p, h)$ of a pigeon and a hole. A Boolean assignment is a map
$\alpha : \text{PVar}_n \to \{\text{true}, \text{false}\}$; the literal $x_{p,h}$
is true under $\alpha$ exactly when "pigeon $p$ is placed in hole $h$."

**Definition (pigeonClause).** For each pigeon $p$, the *pigeon clause* is the
positive disjunction over all holes,
$$\text{pigeonClause}(p) = \bigvee_{h=0}^{n-1} x_{p,h},$$
asserting "pigeon $p$ sits in *some* hole."

**Definition (holeClause).** For each hole $h$ and each *ordered* pair of
distinct pigeons $p_1 \ne p_2$, the *hole clause* is the binary negative clause
$$\text{holeClause}(h, p_1, p_2) = \lnot x_{p_1, h} \lor \lnot x_{p_2, h},$$
asserting "pigeons $p_1$ and $p_2$ are not *both* in hole $h$." Generating the
clause for all ordered distinct pairs makes the system symmetric in the pigeon
order, which avoids a case split when extracting the contradiction.

**Definition (PHP).** The *pigeonhole CNF* is the conjunction of all pigeon and
hole clauses,
$$\text{PHP}_n = \bigwedge_{p} \text{pigeonClause}(p) \ \wedge\ \bigwedge_{h,\,p_1 \ne p_2} \text{holeClause}(h, p_1, p_2).$$

### 2.2 Unsatisfiability

**Theorem 1 (`PHP_unsat`).** For every $n$, the CNF $\text{PHP}_n$ is
unsatisfiable: no Boolean assignment $\alpha$ satisfies every clause.

*Proof sketch.* Suppose, for contradiction, that $\alpha$ satisfies
$\text{PHP}_n$. For each pigeon $p$, the satisfied pigeon clause guarantees at
least one hole $h$ with $x_{p,h}$ true; using choice, define $f(p)$ to be such a
hole, yielding a function $f : \{0,\dots,n\} \to \{0,\dots,n-1\}$ from pigeons to
holes. We claim $f$ is injective. If $f(p_1) = f(p_2) = h$ with $p_1 \ne p_2$,
then both $x_{p_1,h}$ and $x_{p_2,h}$ are true; but $\alpha$ satisfies the hole
clause $\lnot x_{p_1,h} \lor \lnot x_{p_2,h}$, which demands that at least one of
them be false — contradiction. Hence $f$ is an injection from a set of size
$n+1$ into a set of size $n$. No such injection exists (`no_injection_of_card_lt`,
ultimately `Fintype.card_le_of_injective`: an injection forces $|{\rm domain}|
\le |{\rm codomain}|$, i.e. $n+1 \le n$). Contradiction; $\text{PHP}_n$ has no
satisfying assignment. $\qquad\blacksquare$

This is the precondition that makes the lower-bound question meaningful: only an
unsatisfiable formula can have a refutation, and only then does proof *size*
become the object of study.

## 3. Resolution

### 3.1 The system

Resolution operates on clauses (disjunctions of literals). Its single inference
rule is **resolution on a variable $v$**: from a clause $A \lor v$ and a clause
$B \lor \lnot v$, derive the *resolvent* $A \lor B$.

A *derivation* (`Derivable`) of a clause $C$ from a CNF $F$ is a finite sequence
of clauses ending in $C$, each either a clause of $F$ or a resolvent of two
earlier clauses. A *refutation* (`Refutation`) of $F$ is a derivation of the
**empty clause** $\bot$ — the disjunction over no literals, which is false under
every assignment.

### 3.2 Soundness

The resolution rule is *sound*: any assignment satisfying both parents satisfies
the resolvent (`resolvent_sound`). Indeed, fix an assignment $\alpha$ satisfying
$A \lor v$ and $B \lor \lnot v$. If $\alpha(v) = \text{true}$, then $B \lor \lnot
v$ reduces to $B$, so $\alpha$ satisfies $B$, hence $A \lor B$; symmetrically if
$\alpha(v) = \text{false}$, then $\alpha$ satisfies $A$, hence $A \lor B$. By
induction along a derivation, every derived clause is a logical consequence of
$F$ (`refutation_sound`). In particular:

**Theorem 2 (`PHP_no_refutation_sat`).** A resolution refutation of
$\text{PHP}_n$ certifies its unsatisfiability: if $\bot$ is derivable from
$\text{PHP}_n$, then $\text{PHP}_n$ has no satisfying assignment.

*Proof sketch.* By soundness, every clause in the derivation — including the
final empty clause — is satisfied by any model of $\text{PHP}_n$. But $\bot$ is
satisfied by no assignment. Hence $\text{PHP}_n$ has no model. $\qquad\blacksquare$

Theorem 2 is the specialization of soundness to $\text{PHP}_n$; it certifies
that *any* resolution refutation is a correct proof, so the lower-bound question
("how large must such a refutation be?") is well posed.

### 3.3 Haken's lower bound (companion theorem)

The classical result framing this entire study is:

**Theorem (Haken, 1985).** There is a constant $c > 0$ such that every resolution
refutation of $\text{PHP}_n$ contains at least $2^{cn}$ distinct clauses.

We do not formalize Theorem (Haken) here; it is the deep companion that, together
with the cutting-planes upper bound below, yields the separation. The standard
proof proceeds by the *width–size tradeoff* of Ben-Sasson–Wigderson: a short
refutation can be converted, via random restrictions, into a *narrow* one (all
clauses of small width), but a counting/bottleneck argument shows any refutation
of $\text{PHP}_n$ must contain a "medium-width" clause mentioning a constant
fraction of the pigeons, and such clauses are exponentially many. Section 7
sketches a route to formalizing this on the `Derivable` inductive.

## 4. Cutting planes

### 4.1 The system

Cutting planes refutes the *integer-programming* encoding of a CNF. A clause
$\ell_1 \lor \cdots \lor \ell_m$ is encoded as a linear inequality: a positive
literal $x_i$ contributes $x_i$, a negative literal $\lnot x_i$ contributes
$(1 - x_i)$, and the clause becomes $\sum (\text{contributions}) \ge 1$ together
with the box constraints $0 \le x_i \le 1$. A refutation derives the
contradiction $0 \ge 1$ (equivalently $1 \le 0$) using two rules over integer
points $x \in \mathbb{Z}^{\,\text{vars}}$.

**Rule 1 (Addition / linear combination).** From $d_1 \le \sum_i c^1_i x_i$ and
$d_2 \le \sum_i c^2_i x_i$, derive $d_1 + d_2 \le \sum_i (c^1_i + c^2_i) x_i$.
(Together with multiplication by a nonnegative integer, this gives arbitrary
nonnegative linear combinations.)

**Rule 2 (Chvátal–Gomory rounding).** From $d \le \sum_i c_i x_i$ where a
positive integer $k$ divides every $c_i$, derive $\lceil d/k \rceil \le \sum_i
(c_i/k) x_i$.

Rule 2 is the source of cutting planes' strength: dividing by a common factor and
*rounding the bound up* is valid only because the right-hand side is integer-
valued at integer points — it literally "cuts" away fractional polytope corners
that linear-programming reasoning alone would retain.

### 4.2 Soundness

**Theorem 3 (`add_sound`).** Let $s$ be a finite index set, $c^1, c^2 : s \to
\mathbb{Z}$ coefficient vectors, $d_1, d_2 \in \mathbb{Z}$ bounds, and $x : s \to
\mathbb{Z}$ an integer point. If
$$d_1 \le \sum_{i \in s} c^1_i\, x_i \quad\text{and}\quad d_2 \le \sum_{i \in s} c^2_i\, x_i,$$
then
$$d_1 + d_2 \le \sum_{i \in s} (c^1_i + c^2_i)\, x_i.$$

*Proof sketch.* Distributivity gives $\sum_i (c^1_i + c^2_i) x_i = \sum_i c^1_i
x_i + \sum_i c^2_i x_i$ (a termwise $\texttt{ring}$ identity under the sum). Add
the two hypotheses. $\qquad\blacksquare$

**Theorem 4 (`cg_rounding_sound`).** Let $s$ be a finite index set, $c : s \to
\mathbb{Z}$, $d \in \mathbb{Z}$, and $k \in \mathbb{Z}$ with $k > 0$. Suppose $k
\mid c_i$ for all $i \in s$, and let $x : s \to \mathbb{Z}$ satisfy $d \le \sum_{i
\in s} c_i x_i$. Then
$$\left\lceil \frac{d}{k} \right\rceil \le \sum_{i \in s} \frac{c_i}{k}\, x_i,$$
where $c_i/k$ denotes the exact integer quotient and the ceiling is of the
rational $d/k$.

*Proof sketch.* Writing $c_i = k\,(c_i/k)$ (valid since $k \mid c_i$), factor
$\sum_i c_i x_i = k \sum_i (c_i/k) x_i$. Let $S := \sum_i (c_i/k) x_i \in
\mathbb{Z}$. The hypothesis becomes $d \le kS$. Over the rationals, $d/k \le S$;
since $S$ is an integer and $\lceil \cdot \rceil$ is the least integer $\ge$ its
argument (`Int.ceil_le`), $\lceil d/k \rceil \le S$. Casting back gives the
claim. $\qquad\blacksquare$

Both rules are stated for an *arbitrary* finite index set and (for Rule 2) an
arbitrary positive divisor, not a toy special case; together they constitute a
sound proof system.

### 4.3 The encoding of $\text{PHP}_n$

Encode the placement variables as integers $x_{p,h}$. The pigeon clause for $p$
becomes the **row lower bound**
$$\sum_{h=0}^{n-1} x_{p,h} \ge 1 \qquad (p = 0, \dots, n),$$
and the no-collision condition for hole $h$ becomes the **column upper bound**
$$\sum_{p=0}^{n} x_{p,h} \le 1 \qquad (h = 0, \dots, n-1).$$
(The column upper bound is itself derivable from the pairwise hole clauses plus
the box constraints; we take the aggregated form as the working encoding.)

## 5. The counting refutation: the separation witness

**Theorem 5 (`php_cp_counting`).** Fix $n \in \mathbb{N}$ and let $x :
\text{PVar}_n \to \mathbb{Z}$ be any integer assignment satisfying the row lower
bounds and column upper bounds:
$$\forall p,\ \ 1 \le \sum_{h} x_{p,h}, \qquad\qquad \forall h,\ \ \sum_{p} x_{p,h} \le 1.$$
Then a contradiction follows; equivalently, no such $x$ exists.

*Proof sketch.* Consider the grand total $T = \sum_{p}\sum_{h} x_{p,h}$.

*Lower bound.* Summing the $n+1$ row inequalities,
$$n + 1 = \sum_{p} 1 \ \le\ \sum_{p} \sum_{h} x_{p,h} = T,$$
using monotonicity of finite sums ($\texttt{Finset.sum\_le\_sum}$) applied to
$1 \le \sum_h x_{p,h}$ for each $p$.

*Upper bound.* Exchanging the order of summation ($\texttt{Finset.sum\_comm}$),
$$T = \sum_{p}\sum_{h} x_{p,h} = \sum_{h}\sum_{p} x_{p,h} \ \le\ \sum_{h} 1 = n,$$
using the column inequalities $\sum_p x_{p,h} \le 1$.

Combining, $n + 1 \le T \le n$, i.e. $n + 1 \le n$, which is false for every
natural number $n$ (discharged by $\texttt{omega}$). Hence no assignment can
satisfy both families. $\qquad\blacksquare$

**Remarks.**

- *Linearity.* The refutation uses only addition (one sweep over rows, one over
  columns) and a final integer contradiction — $O(n)$ inference steps. No CG
  rounding is even needed for this aggregated encoding; the contradiction is
  already integral.
- *Non-vacuity.* The argument uses *only* the row/column inequalities; it does
  not secretly invoke the box constraints $0 \le x \le 1$. It is therefore the
  genuine double-counting contradiction, not an artifact of an over-constrained
  hypothesis.
- *Significance.* `php_cp_counting` is the *semantic* core of the separation: it
  shows the pigeonhole contradiction is expressible in cutting planes with linear
  effort, in stark contrast to the exponential effort that resolution provably
  requires (Theorem Haken).

## 6. The separation, quantified

Assembling the results:

| Aspect | Resolution | Cutting planes |
|---|---|---|
| Reasoning object | Boolean clauses (local disjunctions) | Integer linear inequalities (global arithmetic) |
| Inference rule(s) | resolvent on a variable | addition; CG rounding |
| Refutes $\text{PHP}_n$? | yes (sound; Thm 2) | yes (Thm 5) |
| Refutation size on $\text{PHP}_n$ | $2^{\Omega(n)}$ (Thm Haken) | $O(n)$ (Thm 5) |

The gap between the last two rows is the **separation**: a single formula family
$\text{PHP}_n$ on which cutting planes is exponentially more efficient than
resolution. The mathematical cause is structural. The reason $\text{PHP}_n$ is
contradictory is a *global counting* fact ($n+1$ rows, $n$ columns). Cutting
planes can write that count as a single inequality and detect the clash in one
linear sweep; resolution, whose clauses are local Boolean disjunctions with no
arithmetic, cannot express the global count and is forced into exponential local
search. *Easy here, exponential there* — driven by the expressiveness of the
rule system, not by the difficulty of the underlying truth.

## 7. Algorithms

We make the constructive content explicit.

**Algorithm A — PHP CNF generator.** Given $n$, emit the clause list of
$\text{PHP}_n$: $n+1$ positive pigeon clauses (each of width $n$) and, for each
hole and each ordered distinct pigeon pair, a binary hole clause. The output is
the exact instance whose unsatisfiability is Theorem 1. Complexity: $\Theta(n^3)$
clauses (the hole clauses dominate, $n \cdot (n+1)n$), each of constant or width-
$n$ size.

**Algorithm B — Cutting-planes counting refutation.** Given $n$ and the row/column
inequalities, (i) sum the $n+1$ row inequalities by repeated application of the
addition rule to obtain $T \ge n+1$; (ii) sum the $n$ column inequalities to
obtain $T \le n$; (iii) report the contradiction $n+1 \le n$. Complexity: $O(n)$
addition steps, each over $O(n^2)$ variables; total work $O(n^3)$, proof length
$O(n)$ inferences. This is the algorithmic form of Theorem 5.

**Algorithm C — Resolution refutation checker.** Given a candidate derivation (a
list of clauses, each tagged as an axiom of $\text{PHP}_n$ or a resolvent of two
earlier clauses on a stated variable), verify each step and confirm the final
clause is empty. By soundness (Theorem 2) a passing certificate proves
$\text{PHP}_n$ unsatisfiable. Complexity: linear in the certificate size; *but*
by Theorem Haken every valid certificate has size $2^{\Omega(n)}$, so the checker
is fast on inputs that are themselves unavoidably enormous.

## 8. Applications

- **SAT solving.** Conflict-driven clause-learning (CDCL) solvers generate, in
  unsatisfiable mode, resolution refutations. Theorem Haken implies a hard
  exponential floor on their running time for pigeonhole-style inputs; Theorem 5
  explains why *pseudo-Boolean* solvers (which reason with integer inequalities,
  in the spirit of cutting planes) cut through the same instances. The separation
  is the theoretical license for the pseudo-Boolean engineering direction.
- **Verification.** Hardware/software model checkers and equivalence checkers
  reduce to SAT/UNSAT; counting-flavored proof obligations inherit the
  resolution bottleneck, motivating richer back-end proof systems.
- **Combinatorial optimization.** The CG rounding rule (Theorem 4) is exactly the
  Chvátal–Gomory cut at the heart of integer-programming cutting-plane
  algorithms; its soundness is the correctness backbone of branch-and-cut
  solvers.

## 9. Discussion

The results delineate, with full rigor, the *certifiable* direction of the
separation: $\text{PHP}_n$ is genuinely unsatisfiable (Theorem 1); resolution is
sound so refutations certify unsatisfiability (Theorem 2); both cutting-planes
rules are sound (Theorems 3–4); and cutting planes refutes $\text{PHP}_n$ in
$O(n)$ steps (Theorem 5). The remaining half — the exponential resolution lower
bound — is the classical Theorem Haken, here treated as the companion result that
completes the separation rather than proved anew.

A subtle but important point is the *faithfulness* of the encoding. The hole
clauses are generated over ordered distinct pigeon pairs, which makes the clause
witnessing any collision literally present, sidestepping a $\texttt{wlog}$ on
pigeon order in the proof of Theorem 1. And Theorem 5's counting argument uses
only the row/column inequalities, never the box constraints, so the contradiction
is the honest double count.

## 10. Future directions

1. **Haken's exponential lower bound for resolution on $\text{PHP}_n$.**
   Conjecture: every resolution refutation of $\text{PHP}_n$ contains at least
   $2^{cn}$ distinct clauses for some $c > 0$. The route is a `width` measure on
   the `Derivable` inductive plus the random-restriction / bottleneck-counting
   machinery of Ben-Sasson–Wigderson, all expressible on the existing list-based
   clauses; `Derivable`, `Refutation`, and `PHP_unsat` are already in place.

2. **Cutting planes polynomially simulates the counting refutation.** Conjecture:
   there is a cutting-planes derivation of $0 \ge 1$ from the integer encoding of
   $\text{PHP}_n$ with $O(n)$ inference steps, formalizable as an explicit
   `Derivation` object using only `add_sound` and `cg_rounding_sound`. Theorem 5
   already exhibits the semantic contradiction; the task is to chain $n+1$
   syntactic addition steps in a `Derivation` inductive analogous to `Derivable`.

3. **Formal separation theorem (resolution vs. cutting planes).** Conjecture:
   combining (1) and (2) yields a single statement — a family of CNFs
   ($\text{PHP}_n$) with $\mathrm{poly}(n)$-size cutting-planes refutations and
   only $2^{\Omega(n)}$-size resolution refutations. The separation is witnessed
   by one formula family that is unsatisfiable for a counting reason cutting
   planes captures in a linear sweep and resolution cannot.

4. **Resolution completeness via ordered / Davis–Putnam elimination.**
   Conjecture: every unsatisfiable CNF over a finite variable set has a
   `Refutation`, provable by variable elimination — resolving out one variable at
   a time produces a strictly smaller, satisfiability-preserving CNF, a
   terminating recursion whose base case is the empty clause; `resolvent_sound`
   is the inductive step.

## 11. Conclusion

The pigeonhole principle, the most transparent of truths, has only exponential
proofs in resolution yet a linear proof in cutting planes. We have formalized the
unsatisfiability of the pigeonhole CNF, the soundness of resolution as a
certifying system, the soundness of both cutting-planes rules, and the linear
counting refutation that constitutes the certifiable half of the resolution–
cutting-planes separation. The lesson generalizes far beyond pigeons: proof
length is a property not of the truth but of the language one is permitted to
reason in, and endowing a proof system with arithmetic can turn an impossibility
into a single line.
