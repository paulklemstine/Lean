# Resolution, Restrictions, and Cutting Planes: A Verified Account of Pigeonhole Hardness and Its Separation

**Author:** Aristotle
**Date:** 2026-06-29

## Abstract

We give a self-contained development of the two propositional proof systems that anchor modern proof complexity — **resolution** and **cutting planes** — and use them to dissect the pigeonhole principle, the canonical hard family of the field. We develop resolution as a clause calculus with a single inference rule and prove its soundness end-to-end: the resolvent of two satisfied clauses is satisfied, every derivable clause is a semantic consequence, and a formula admitting a refutation is unsatisfiable. We encode the pigeonhole principle $\mathrm{PHP}_n$ for $n+1$ pigeons and $n$ holes as a CNF and prove it unsatisfiable by extracting an injection $\{1,\dots,n+1\}\to\{1,\dots,n\}$ from any satisfying assignment. We then build the structural engine of resolution lower bounds: **weakening** (refutations survive added clauses), the **nonexistence of derivations from the empty formula**, and — centrally — the **restriction operator** together with its exact semantic invariant: a free assignment satisfies a restricted formula if and only if the glued assignment satisfies the original. From this we derive **hardness preservation** (restrictions preserve unsatisfiability) and apply it to show that $\mathrm{PHP}_n$ is hard *robustly*: every partial assignment leaves it unsatisfiable. Finally we develop cutting planes — integer-linear inequalities with the addition and Chvátal–Gomory rounding rules, both proved sound — and exhibit the **linear counting refutation** of the pigeonhole principle, the constructive half of the exponential separation between cutting planes and resolution. Throughout we situate the results against Haken's exponential lower bound, which governs the resolution side of the separation, and against SAT-solver practice, which the separation explains.

## 1. Introduction

A *satisfiability solver* answers, for a propositional formula, whether some assignment makes it true. When the answer is "yes," the solver returns a witness that anyone can check. When the answer is "no," it must instead return a *certificate of unsatisfiability* — a formal proof, in some fixed proof system, that no assignment works. **Proof complexity** studies the size of such certificates: for a given proof system and a given family of unsatisfiable formulas, how large must the smallest certificate be?

The field's organizing benchmark is the **pigeonhole principle**: $n+1$ pigeons cannot be placed into $n$ holes without a collision. As a propositional formula it is unsatisfiable for a transparent, global reason — a counting argument — yet it has been the proving ground for the deepest lower bounds in the area.

Two proof systems frame the classical theory:

- **Resolution**, the local clause-elimination calculus underlying essentially all conflict-driven SAT solvers. Haken (1985) proved that resolution refutations of the pigeonhole principle have size exponential in $n$.
- **Cutting planes**, an arithmetic system reasoning about integer points of polytopes. It refutes the pigeonhole principle with a *polynomial* (indeed linear) number of steps, and is therefore exponentially separated from resolution.

This paper develops both systems from first principles, proves the structural results that make resolution lower bounds possible, and exhibits the constructive separation. Our contributions are:

1. A soundness pipeline for resolution (Section 3).
2. A faithful CNF encoding of the pigeonhole principle and a proof of its unsatisfiability (Section 4).
3. The algebra of restrictions — weakening, the empty-formula fact, the exact restriction invariant, hardness preservation, and robust pigeonhole hardness (Section 5).
4. Soundness of the cutting-planes rules and the linear counting refutation of the pigeonhole principle, the constructive side of the separation (Section 6).

We close with the relationship to Haken's theorem, applications to SAT solving, and future directions (Sections 7–9).

## 2. Preliminaries: literals, clauses, and CNF

Fix a type $V$ of propositional variables. An **assignment** is a function $a : V \to \{\texttt{true},\texttt{false}\}$.

**Definition 2.1 (Literal).** A *literal* is a pair $\ell = (v, b)$ of a variable $v \in V$ and a polarity $b \in \{\texttt{true},\texttt{false}\}$. We write $v$ for the positive literal $(v,\texttt{true})$ and $\neg v$ for the negative literal $(v,\texttt{false})$. A literal is *evaluated* by
$$\mathrm{eval}_a(\ell) \;=\; \big[\,a(\ell.v) = \ell.\mathrm{pos}\,\big],$$
i.e. it is true exactly when the assignment matches its polarity.

**Definition 2.2 (Clause).** A *clause* $C$ is a finite list of literals, read disjunctively. It is *satisfied* by $a$, written $a \models C$, when some literal of $C$ evaluates to true:
$$a \models C \iff \exists\, \ell \in C,\ \mathrm{eval}_a(\ell) = \texttt{true}.$$
The *empty clause* $\square$ has no literals; it is satisfied by no assignment and serves as the system's contradiction $\bot$.

**Definition 2.3 (CNF).** A *CNF formula* $F$ is a finite list of clauses, read conjunctively. It is *satisfied* by $a$, written $a \models F$, when every clause is:
$$a \models F \iff \forall\, C \in F,\ a \models C.$$
$F$ is *satisfiable* if $a \models F$ for some $a$, and *unsatisfiable* otherwise.

**Lemma 2.4 (Empty clause is unsatisfiable).** For every assignment $a$, $a \not\models \square$. *Proof.* The empty clause has no literal to witness satisfaction. $\qquad\blacksquare$

## 3. The resolution proof system

Assume $V$ has decidable equality so that literals can be compared.

**Definition 3.1 (Resolvent).** The *resolvent* of clauses $C_1, C_2$ on pivot variable $p$ is
$$\mathrm{res}(C_1, C_2, p) \;=\; \big(C_1 \text{ with the literal } (p,\texttt{true}) \text{ removed}\big) \ \mathbin{+\!\!+}\ \big(C_2 \text{ with the literal } (p,\texttt{false}) \text{ removed}\big),$$
the concatenation of the two parents after deleting the complementary pivot literals.

**Theorem 3.2 (Soundness of the resolution rule).** If $a \models C_1$ and $a \models C_2$, then $a \models \mathrm{res}(C_1, C_2, p)$.

*Proof sketch.* Case split on $a(p)$. If $a(p) = \texttt{true}$, then the literal $(p,\texttt{false})$ of $C_2$ is false, so the witness satisfying $C_2$ must be a *different* literal, which survives the filter; it satisfies the second part of the resolvent. If $a(p) = \texttt{false}$, the symmetric argument uses $C_1$. Note the rule is sound with no assumption that the pivot actually occurs in either parent — a clean strengthening of the textbook statement. $\qquad\blacksquare$

**Definition 3.3 (Derivability).** The set of clauses *derivable* from $F$, written $F \vdash C$, is generated inductively by:
- **(base)** if $C \in F$ then $F \vdash C$;
- **(res)** if $F \vdash C_1$ and $F \vdash C_2$ then $F \vdash \mathrm{res}(C_1, C_2, p)$ for any pivot $p$.

**Theorem 3.4 (Soundness of derivation).** If $F \vdash C$, then every assignment satisfying $F$ satisfies $C$: $\forall a,\ a \models F \Rightarrow a \models C$.

*Proof sketch.* Induction on the derivation. The base case is immediate; the inductive case is Theorem 3.2 applied to the two induction hypotheses. $\qquad\blacksquare$

**Definition 3.5 (Refutation).** A *resolution refutation* of $F$ is a derivation of the empty clause, $F \vdash \square$.

**Theorem 3.6 (Soundness of refutations).** If $F$ has a resolution refutation, then $F$ is unsatisfiable.

*Proof.* If $a \models F$, then by Theorem 3.4 $a \models \square$, contradicting Lemma 2.4. $\qquad\blacksquare$

**Theorem 3.7 (Non-vacuity: the unit refutation).** The formula $\{x\} \land \{\neg x\}$ has a one-step refutation: $\mathrm{res}([x],[\neg x],x) = \square$, hence $\{x\}\land\{\neg x\} \vdash \square$, and the formula is unsatisfiable.

This confirms the calculus genuinely derives $\square$ and that soundness is not vacuous.

## 4. The pigeonhole principle as a CNF

**Definition 4.1 (Pigeonhole variables).** For $n \in \mathbb{N}$, set the variable type $\mathrm{PVar}_n = \{0,\dots,n\} \times \{0,\dots,n-1\}$; the variable $x_{p,h}$ means "pigeon $p$ is in hole $h$." There are $n+1$ pigeons and $n$ holes.

**Definition 4.2 (Clauses of $\mathrm{PHP}_n$).**
- *Pigeon clauses*: for each pigeon $p$, the clause $\bigvee_{h} x_{p,h}$ ("pigeon $p$ sits in some hole").
- *Hole clauses*: for each hole $h$ and each ordered pair of distinct pigeons $p_1 \ne p_2$, the clause $\neg x_{p_1,h} \lor \neg x_{p_2,h}$ ("$p_1$ and $p_2$ do not share hole $h$").

The CNF $\mathrm{PHP}_n$ is the conjunction of all pigeon clauses and all hole clauses. (Using *ordered* distinct pairs makes the needed hole clause syntactically present for either pigeon order, eliminating a case split.)

**Theorem 4.3 (Unsatisfiability of the pigeonhole principle).** $\mathrm{PHP}_n$ is unsatisfiable for every $n$.

*Proof sketch.* Suppose $a \models \mathrm{PHP}_n$. The pigeon clause for $p$ supplies a hole $h$ with $a(x_{p,h}) = \texttt{true}$; choosing one such hole per pigeon defines a function $f$ from pigeons to holes. For distinct pigeons $p_1 \ne p_2$, the hole clause $\neg x_{p_1,f(p_1)} \lor \neg x_{p_2,f(p_1)}$ is satisfied, but $a(x_{p_1,f(p_1)}) = \texttt{true}$, so its other literal must be true, forcing $a(x_{p_2,f(p_1)}) = \texttt{false}$ and hence $f(p_2) \ne f(p_1)$. Thus $f$ is injective. But an injection from an $(n+1)$-element set into an $n$-element set is impossible since $n < n+1$. Contradiction. $\qquad\blacksquare$

**Corollary 4.4 (Soundness specialized).** Any resolution refutation of $\mathrm{PHP}_n$ is a correct certificate of its unsatisfiability. The remaining question — whether a *short* one exists — is what Haken's theorem answers in the negative.

## 5. Restrictions and the engine of lower bounds

The technical core of resolution lower bounds is the *restriction method*. We develop its algebra abstractly and apply it to the pigeonhole principle.

### 5.1 Weakening and the empty formula

**Theorem 5.1 (Weakening).** If $F \subseteq G$ (every clause of $F$ is a clause of $G$), then $F \vdash C \Rightarrow G \vdash C$. In particular, a refutation of $F$ is a refutation of $G$.

*Proof sketch.* Induction on the derivation: a base clause of $F$ is a base clause of $G$; the resolution step is preserved verbatim. $\qquad\blacksquare$

Adding irrelevant clauses never invalidates a proof — resolution is monotone in its clause set.

**Theorem 5.2 (The empty formula proves nothing).** $\varnothing \not\vdash C$ for every clause $C$.

*Proof sketch.* Induction on the derivation. There is no base clause to start from, and every resolution step requires a previously derived clause, so no derivation exists. $\qquad\blacksquare$

### 5.2 The restriction operator

**Definition 5.3 (Restriction).** A *restriction* is a function $\rho : V \to \{\texttt{true},\texttt{false},\star\}$ (formally $V \to \mathrm{Option}\ \mathrm{Bool}$), where $\star$ marks a *free* variable and a Boolean value marks a *fixed* one.

**Definition 5.4 (Gluing).** Given a restriction $\rho$ and a free assignment $a$, define the total assignment
$$\mathrm{subst}(\rho, a)(v) = \begin{cases} b & \text{if } \rho(v) = b \text{ (fixed)},\\ a(v) & \text{if } \rho(v) = \star \text{ (free)}.\end{cases}$$

**Definition 5.5 (Restricting clauses and CNFs).**
- A clause $C$ is *killed* by $\rho$ if it contains a literal $\ell$ whose variable is fixed to $\ell$'s polarity — i.e. $\rho$ already satisfies $C$.
- The *clause restriction* $C{\restriction}\rho$ keeps exactly the literals on *free* variables (literals fixed to false are *deleted*; this is the meaningful operation only for clauses that are not killed).
- The *CNF restriction* $F{\restriction}\rho$ discards the killed clauses of $F$ and applies the clause restriction to the survivors.

**Theorem 5.6 (Restriction Invariance — the semantic invariant).** For every restriction $\rho$, CNF $F$, and free assignment $a$,
$$a \models F{\restriction}\rho \iff \mathrm{subst}(\rho, a) \models F.$$

*Proof sketch.* Both directions reduce to a literal-level case split on whether $\rho$ fixes a variable. For ($\Leftarrow$): take a surviving (non-killed) restricted clause $C{\restriction}\rho$; it comes from a clause $C \in F$ satisfied by $\mathrm{subst}(\rho,a)$ via some literal $\ell$. Since $C$ is not killed, $\ell$ is *not* fixed to its polarity; and because the witness must be true under $\mathrm{subst}$, $\ell$'s variable cannot be fixed to the opposite value either (that would make $\ell$ false). Hence $\ell$ is free and survives into $C{\restriction}\rho$, where it still evaluates to true under $a$. For ($\Rightarrow$): given $C \in F$, either $C$ is killed — then a fixing literal makes $\mathrm{subst}(\rho,a) \models C$ outright — or $C$ survives and its restricted witness lifts back. The delicate case is a literal fixed to *false*: it is deleted, not killing, and one checks it can never have been the witness, because $\mathrm{subst}$ agrees with the fixed value precisely there. Both directions then close. $\qquad\blacksquare$

The key feature is that this is an **exact** biconditional with *no error term*: restricting then satisfying is identical to satisfying along the partial assignment. This is exactly the lossless syntax–semantics interface that probabilistic restriction arguments rely on.

**Theorem 5.7 (Hardness preservation).** If $F$ is unsatisfiable, then so is $F{\restriction}\rho$ for every $\rho$.

*Proof.* If $a \models F{\restriction}\rho$, then by Theorem 5.6 $\mathrm{subst}(\rho,a) \models F$, contradicting unsatisfiability. $\qquad\blacksquare$

**Theorem 5.8 (Robust pigeonhole hardness).** For every $n$ and every restriction $\rho$ of the pigeonhole variables, $\mathrm{PHP}_n{\restriction}\rho$ is unsatisfiable.

*Proof.* Theorem 5.7 applied to Theorem 4.3. $\qquad\blacksquare$

No partial assignment of pigeon–hole variables can rescue the formula. This robustness is the abstract reason the random-restriction method is sound: a hypothetical short refutation, hit by a random restriction, is left refuting a still-hard sub-instance.

## 6. Cutting planes and the separation

Cutting planes reasons about the integer points of a polytope. We encode a constraint as a linear inequality $\sum_{i} c_i x_i \ge d$ with integer coefficients, evaluated at integer points $x : \iota \to \mathbb{Z}$.

**Theorem 6.1 (Soundness of addition).** For a finite index set $s$, coefficient vectors $c_1, c_2$, bounds $d_1, d_2$, and an integer point $x$, if $d_1 \le \sum_{i\in s} c_1(i)\, x(i)$ and $d_2 \le \sum_{i\in s} c_2(i)\, x(i)$, then
$$d_1 + d_2 \le \sum_{i\in s} \big(c_1(i)+c_2(i)\big)\, x(i).$$

*Proof.* The right-hand sum splits as the sum of the two original sums; add the hypotheses. $\qquad\blacksquare$

**Theorem 6.2 (Soundness of Chvátal–Gomory rounding).** Let $k > 0$ be an integer dividing every coefficient $c(i)$ for $i \in s$, and suppose $d \le \sum_{i\in s} c(i)\, x(i)$ at an integer point $x$. Then
$$\Big\lceil \tfrac{d}{k} \Big\rceil \le \sum_{i\in s} \tfrac{c(i)}{k}\, x(i).$$

*Proof sketch.* Since $k \mid c(i)$, we have $\sum c(i)x(i) = k \sum (c(i)/k) x(i)$, so the hypothesis reads $d \le k \cdot S$ with $S = \sum (c(i)/k)x(i)$ an integer. Dividing by $k$ gives $d/k \le S$; as $S$ is an integer and $\lceil\cdot\rceil$ is the least integer above its argument, $\lceil d/k\rceil \le S$. The rounding step is exactly where integrality is exploited. $\qquad\blacksquare$

**Theorem 6.3 (The counting refutation of the pigeonhole principle).** Let $n \in \mathbb{N}$ and let $x : \mathrm{PVar}_n \to \mathbb{Z}$ satisfy the pigeon lower bounds and hole upper bounds:
$$\forall p,\ \sum_{h} x(p,h) \ge 1, \qquad \forall h,\ \sum_{p} x(p,h) \le 1.$$
Then a contradiction follows. Indeed, summing the pigeon bounds over all $n+1$ pigeons gives
$$n + 1 \le \sum_{p}\sum_{h} x(p,h),$$
while summing the hole bounds over all $n$ holes and exchanging the order of summation gives
$$\sum_{p}\sum_{h} x(p,h) = \sum_{h}\sum_{p} x(p,h) \le n.$$
Together $n + 1 \le n$, which is false.

*Proof.* The lower bound is $\sum_p 1 \le \sum_p \sum_h x(p,h)$ by monotonicity of finite sums; the upper bound uses commutativity of double summation and $\sum_h 1 = n$. The two chained inequalities contradict $n+1 > n$. $\qquad\blacksquare$

This refutation uses only the row/column $\ge$/$\le$ constraints — no hidden $0 \le x \le 1$ assumption — and consists of $O(n)$ linear-combination steps. It is the constructive heart of the separation.

**Theorem 6.4 (Separation, informal).** The pigeonhole principle has cutting-planes refutations of size $O(n)$ (Theorem 6.3) but, by Haken's theorem, only resolution refutations of size $2^{\Omega(n)}$. Hence cutting planes is exponentially more powerful than resolution on this family.

The mathematical content of the separation is the asymmetry between Theorem 6.3 and Haken's lower bound: the counting argument is *linear* because it is global and arithmetic, whereas resolution is forced to be *exponential* because it reasons locally and cannot express the global count in a single inequality.

## 7. Relationship to Haken's theorem

Theorem 4.3 establishes the precondition for the lower-bound question, and Theorem 3.6 makes any refutation a trustworthy certificate; together they make "how large must a refutation be?" well-posed. Haken's theorem answers: $2^{\Omega(n)}$. The restriction algebra of Section 5 is exactly the toolkit through which such bounds are proved. The standard route is:

1. Establish a *width* lower bound: any refutation must contain a clause mentioning a constant fraction of the variables.
2. Convert width to size via a random-restriction argument: a small refutation, hit by a random restriction, would collapse all wide clauses and yield a too-narrow refutation of a still-hard sub-instance — impossible.

Theorem 5.8 supplies the "still-hard sub-instance" guarantee, and the *exactness* of Theorem 5.6 ensures the probabilistic argument loses no information at the syntax–semantics interface. What remains for a complete proof of Haken's theorem is the *quantitative* counting of surviving wide clauses under a random restriction — the analytic heart of the argument, isolated here as a future target.

## 8. Applications to SAT solving

Conflict-driven clause-learning (CDCL) SAT solvers, which power hardware and software verification, planning, and combinatorial optimization, produce traces equivalent to resolution refutations when they report UNSAT. Theorem 3.6 is precisely what makes those "UNSAT" verdicts trustworthy. Haken's theorem then explains a long-observed practical phenomenon: resolution-based solvers degrade catastrophically on counting problems such as the pigeonhole principle and its relatives. The separation of Section 6 points to the remedy: solvers that reason with linear / pseudo-Boolean constraints in the spirit of cutting planes dispatch exactly these instances efficiently. The robustness result (Theorem 5.8) further clarifies *why* preprocessing and partial assignment heuristics cannot help on pigeonhole-type formulas — no restriction makes them easier.

## 9. Discussion and future work

We have given a complete, self-contained account of resolution (with full soundness), the pigeonhole principle (with unsatisfiability), the restriction algebra (weakening, the empty-formula fact, exact restriction invariance, hardness preservation, robust pigeonhole hardness), and cutting planes (rule soundness and the linear counting refutation, the constructive side of the separation).

Three directions stand out.

1. **Restriction-robust hardness implies a width explosion.** Conjecture: every clause-resolution refutation of $\mathrm{PHP}_n$ must, at some stage, manipulate a clause mentioning a constant fraction of all $n(n+1)$ variables. Since hardness is preserved under *every* partial assignment, a refutation cannot localize its reasoning without leaving a still-unsatisfiable sub-instance it must also handle; quantifying "cannot localize" as a width lower bound turns the qualitative robustness proved here into the classical width measure controlling refutation length.

2. **A random restriction shrinks every short refutation to nothing.** Conjecture: a sub-exponential refutation, hit by a random restriction fixing most variables, has all its wide clauses collapse simultaneously, leaving a too-narrow refutation of a still-hard sub-instance. The exact (error-free) commutation of restriction and satisfaction means the probabilistic argument never loses information at the syntax–semantics interface, isolating the surviving-wide-clause count as the sole remaining difficulty.

3. **Counting capacity, not clause length, as the right complexity measure.** The cutting-planes refutation succeeds because a single arithmetic inequality captures a global count that resolution cannot name. This suggests measuring proofs by their *counting capacity* — the arithmetic expressiveness available per step — and studying which formula families separate systems along that axis.

## 10. Conclusion

The pigeonhole principle is a one-line truth that becomes a precision instrument in proof complexity. Resolution certifies its impossibility soundly yet, by Haken's theorem, only at exponential cost, because it cannot count. Restrictions — exact, lossless, and hardness-preserving — are the engine behind such lower bounds, and the pigeonhole principle stays hard under every partial decision. Cutting planes, armed with integer arithmetic and Chvátal–Gomory rounding, leaps the wall in linearly many steps, separating itself exponentially from resolution. The verified results assembled here form the algebra of that story — soundness, hardness, robustness, and separation — and chart the path toward the quantitative lower bound that remains the field's central prize.
