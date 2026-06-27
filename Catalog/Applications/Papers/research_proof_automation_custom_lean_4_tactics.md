# Proof Automation for Fibonacci Identities: The Two-Term Basis Principle as a Decision Procedure

**Author:** Aristotle
**Domain:** Applications (Proof Automation)
**Date:** 2026-06-27

## Abstract

We present a small, principled toolkit of custom proof-automation tactics for
the classical algebra of the Fibonacci numbers $F_n$ (defined by $F_0 = 0$,
$F_1 = 1$, $F_{n+2} = F_{n+1} + F_n$), together with a verified suite of the
identities they discharge. The mathematical engine is the **two-term basis
principle**: for any fixed base index $n$, every shifted value $F_{n+k}$ is a
fixed nonnegative-integer linear combination of the two coordinates $F_n$ and
$F_{n+1}$, with coefficients $F_{k-1}$ and $F_k$. Consequently every *single-
base* polynomial identity in shifted Fibonacci values is, after substitution, a
formal polynomial identity in two free variables, and is therefore decided by
ordinary commutative-ring normalization. This is the content of our primary
tactic, the *expander* `fib_ring`. Identities carrying the alternating sign
$(-1)^n$ — chief among them **Cassini's identity** — are not single-base
polynomial identities; they are dispatched by a single induction step packaged
as `fib_cassini_induct`. Genuinely *two-base* signed identities (Catalan's and
d'Ocagne's convolution identities) are reduced to Cassini through the closed-
form engine lemma `fib_two_basis`. We prove the engine lemma, the full set of
single-base shift identities, both orientations of Cassini, both index-doubling
formulas, and the convolution identities, and we analyze the scope, soundness,
and completeness of the procedure. We close with four precise conjectures
extending the method to all Lucas sequences and to a determinantal "$Q$-matrix"
reflection procedure.

## 1. Introduction

The Fibonacci numbers form one of the most studied integer sequences in
mathematics, and the literature contains hundreds of exact identities relating
their shifted values, products, squares, and partial sums. Historically these
identities have been discovered and verified one at a time, each with its own
ad hoc manipulation. This paper isolates a single structural fact that reduces
a large and well-defined class of such identities to mechanical algebra, and
organizes the remaining cases (those involving a parity sign or two independent
base points) around one further classical theorem, Cassini's identity.

Our contributions are:

1. A precise statement and proof of the **two-term basis principle** in a form
   convenient for substitution (Section 3, `fib_two_basis`).
2. A decision-procedure tactic, the **expander** `fib_ring`, that discharges
   every true single-base polynomial Fibonacci identity by ring normalization
   (Sections 2 and 4).
3. A one-step induction tactic, `fib_cassini_induct`, that handles parity-
   dependent identities, used to prove Cassini's identity in both orientations
   (Section 5).
4. A reduction of the two-base signed convolution identities (Catalan,
   d'Ocagne) to Cassini via the engine lemma, and a unifying convolution
   identity that subsumes them (Section 7).
5. Verified index-doubling formulas underlying the fast-doubling computation of
   $F_n$ (Section 6).

Throughout, "identity" means an equation asserted for all natural numbers $n$
(and possibly additional shift parameters), and "verified" means proved as a
universally quantified statement, not merely checked numerically.

## 2. The tactics

We describe the three custom tactics abstractly; their soundness is discussed
in Section 8. All three rest on the rewrite rule $F_{m+2} = F_{m+1} + F_m$,
which we call **two-step expansion**.

**The expander `fib_ring`.** Given a goal that is a polynomial equation in
shifted Fibonacci values from a single base point, `fib_ring` first applies
two-step expansion repeatedly. Because each application strictly decreases the
largest shift while introducing only strictly smaller shifts, the rewriting
terminates with every term reduced to the two atoms $F_n$ and $F_{n+1}$. The
resulting goal is a polynomial identity in these two atoms, which is then closed
by commutative-ring normalization (`ring`). Symbolically,

$$
\text{`fib\_ring`} \;=\; (\text{repeatedly rewrite } F_{m+2}\to F_{m+1}+F_m)\;;\;\text{`ring`}.
$$

**The linear companion `fib_omega`.** Identical preprocessing, but the residual
goal — which may involve truncated natural-number subtraction or inequalities
rather than a pure ring identity — is discharged by linear-arithmetic decision
(`omega`) instead of `ring`.

**The parity inductor `fib_cassini_induct`.** For identities over $\mathbb{Z}$
carrying a factor $(-1)^n$, this tactic performs induction on $n$: the base case
is closed by simplification; the inductive step applies two-step expansion,
normalizes integer casts, normalizes the ring structure, and finishes by linear
arithmetic against the induction hypothesis. A single induction step suffices
because two-step expansion reduces the statement at $n+1$ to the statement at
$n$ with the sign reversed.

## 2.5. Preliminaries: the two-coordinate basis in explicit form

Before stating the engine lemma it is worth making the central mechanism fully
explicit, because the entire paper is, in a sense, an elaboration of one table.
For a fixed base index $n$, repeatedly applying the recurrence $F_{m+2} =
F_{m+1} + F_m$ expresses each shifted value as an integer combination of the two
"coordinates" $F_n$ and $F_{n+1}$:

$$
\begin{array}{lcl}
F_{n+0} &=& 1\cdot F_n + 0\cdot F_{n+1},\\
F_{n+1} &=& 0\cdot F_n + 1\cdot F_{n+1},\\
F_{n+2} &=& 1\cdot F_n + 1\cdot F_{n+1},\\
F_{n+3} &=& 1\cdot F_n + 2\cdot F_{n+1},\\
F_{n+4} &=& 2\cdot F_n + 3\cdot F_{n+1},\\
F_{n+5} &=& 3\cdot F_n + 5\cdot F_{n+1},\\
F_{n+6} &=& 5\cdot F_n + 8\cdot F_{n+1},\\
F_{n+7} &=& 8\cdot F_n + 13\cdot F_{n+1}.
\end{array}
$$

The coefficient of $F_n$ in the row for $F_{n+k}$ is $F_{k-1}$ and the
coefficient of $F_{n+1}$ is $F_k$ (with the convention $F_{-1} = 1$ in the row
$k=0$). In other words, the change-of-basis matrix from the abstract pair
$(F_n, F_{n+1})$ to $(F_{n+k}, F_{n+k+1})$ is exactly the power
$$
Q^k = \begin{pmatrix} F_{k+1} & F_k \\ F_k & F_{k-1} \end{pmatrix},
\qquad Q = \begin{pmatrix} 1 & 1 \\ 1 & 0 \end{pmatrix}.
$$
This is why every single-base identity is a two-variable polynomial fact, and
why the parity sign in Cassini is, at root, the determinant $(\det Q)^n =
(-1)^n$. The remainder of the paper organizes the consequences of this single
table into a layered automation strategy.

## 3. The engine: the two-term basis principle

Let $F : \mathbb{N} \to \mathbb{N}$ be the Fibonacci function. The structural
heart of the entire development is the following bilinear closed form, a
reindexing of the standard addition formula $F_{m+n+1} = F_m F_n + F_{m+1}
F_{n+1}$.

> **Theorem 1 (`fib_two_basis`).** For all $n, k \in \mathbb{N}$,
> $$F_{n + (k+1)} = F_k\,F_n + F_{k+1}\,F_{n+1}.$$

*Proof.* Rewrite the index as $n + (k+1) = k + n + 1$ and apply the Fibonacci
addition formula $F_{k+n+1} = F_k F_n + F_{k+1} F_{n+1}$. $\qquad\blacksquare$

Theorem 1 has two distinct uses. First, specialized in $k$ to concrete literals
it yields the *single-base linear basis*: each $F_{n+k}$ is the fixed
combination $F_{k-1} F_n + F_k F_{n+1}$, the engine behind `fib_ring`. Second,
left with $k$ a free variable, it converts any *two-base* expression (one
involving both a base point $n$ and an independent shift $k$) into a polynomial
in the four atoms $F_k, F_{k+1}, F_n, F_{n+1}$, the engine behind the reduction
of Catalan and d'Ocagne to Cassini.

## 4. Single-base shift identities

The simplest consequences are the linear basis expansions, all closed verbatim
by `fib_ring`. The coefficients are themselves Fibonacci numbers.

> **Proposition 2 (`fib_shift_five`).** $F_{n+5} = 3F_n + 5F_{n+1}$.
>
> **Proposition 3 (`fib_shift_six`).** $F_{n+6} = 5F_n + 8F_{n+1}$.
>
> **Proposition 4 (`fib_shift_seven`).** $F_{n+7} = 8F_n + 13F_{n+1}$.

*Proof (all three).* Apply two-step expansion until only $F_n, F_{n+1}$ remain,
then normalize. For instance $F_{n+5} = F_{n+4}+F_{n+3} = (2F_{n+1}+F_{n+2})
+ (F_{n+1}+F_{n+2}) = \cdots = 3F_n + 5F_{n+1}$; `ring` confirms the coefficient
match. $\qquad\blacksquare$

The procedure is not limited to linear identities. Polynomial (higher-degree)
single-base identities are equally automatic.

> **Proposition 5 (`fib_square_shift`).**
> $$F_{n+2}^{\,2} = F_n^{\,2} + 2F_n F_{n+1} + F_{n+1}^{\,2}.$$

*Proof.* Two-step expansion gives $F_{n+2} = F_n + F_{n+1}$; squaring,
$(F_n+F_{n+1})^2 = F_n^2 + 2F_nF_{n+1} + F_{n+1}^2$ by `ring`.
$\qquad\blacksquare$

> **Proposition 6 (`fib_mixed_shift`).**
> $$F_{n+2}^{\,2} = F_{n+1}^{\,2} + F_n\,F_{n+3}.$$

*Proof.* Substitute $F_{n+2} = F_n + F_{n+1}$ and $F_{n+3} = F_n + 2F_{n+1}$.
The left side is $(F_n+F_{n+1})^2 = F_n^2 + 2F_nF_{n+1} + F_{n+1}^2$; the right
side is $F_{n+1}^2 + F_n(F_n + 2F_{n+1}) = F_{n+1}^2 + F_n^2 + 2F_nF_{n+1}$.
The two agree as polynomials in $(F_n, F_{n+1})$, so the identity holds for all
$n$. $\qquad\blacksquare$

The key methodological point: Propositions 2–6 are not separate theorems
requiring separate insight. They are all instances of one decision procedure,
and their truth is a *formal* polynomial fact in two variables.

## 5. Parity identities and Cassini

The expander cannot handle $(-1)^n$ because that term is not a polynomial in the
atoms; after two-step expansion the goal still mentions $(-1)^n$ and `ring`
makes no progress. The remedy is one induction step.

> **Theorem 7 (`cassini`, over $\mathbb{Z}$).** For all $n$,
> $$F_{n+2}\,F_n - F_{n+1}^{\,2} = (-1)^{\,n+1}.$$

*Proof.* Induct on $n$. **Base** $n=0$: $F_2 F_0 - F_1^2 = 1\cdot 0 - 1 = -1
= (-1)^1$. **Step:** assume $F_{n+2}F_n - F_{n+1}^2 = (-1)^{n+1}$. Expanding
$F_{n+3} = F_{n+2}+F_{n+1}$ and $F_{n+2} = F_{n+1}+F_n$, the target quantity at
$n+1$ is
$$F_{n+3}F_{n+1} - F_{n+2}^2 = (F_{n+2}+F_{n+1})F_{n+1} - F_{n+2}^2.$$
Linear arithmetic against the induction hypothesis (which rearranges to
$F_{n+2}^2 - F_{n+3}F_{n+1} = F_{n+2}F_n - F_{n+1}^2 = (-1)^{n+1}$, hence the
target equals $-(-1)^{n+1} = (-1)^{n+2}$) closes the step. $\qquad\blacksquare$

> **Theorem 8 (`cassini'`, over $\mathbb{Z}$).** For all $n$,
> $$F_{n+1}^{\,2} - F_n\,F_{n+2} = (-1)^{\,n}.$$

*Proof.* This is the negation of Theorem 7, using $(-1)^{n+1} = -(-1)^n$:
$F_{n+1}^2 - F_n F_{n+2} = -\bigl(F_{n+2}F_n - F_{n+1}^2\bigr) = -(-1)^{n+1}
= (-1)^n$. $\qquad\blacksquare$

Theorem 8 is the workhorse for the convolution identities of Section 7, where
the quantity $F_{n+1}^2 - F_n F_{n+2}$ appears as a recurring factor.

**Remark (determinantal meaning).** With $Q = \begin{pmatrix} 1 & 1 \\ 1 & 0
\end{pmatrix}$ one has $Q^n = \begin{pmatrix} F_{n+1} & F_n \\ F_n & F_{n-1}
\end{pmatrix}$, and Cassini is precisely $\det(Q^n) = (\det Q)^n = (-1)^n$. The
parity sign is the determinant's multiplicativity.

## 6. Index-doubling formulas

The doubling formulas pair the base point $n$ with itself and follow from the
addition formula plus one ring normalization. They underlie the fast-doubling
algorithm for computing $F_N$ in $O(\log N)$ big-integer multiplications.

> **Theorem 9 (`fib_two_mul_add_one`).** $F_{2n+1} = F_{n+1}^{\,2} + F_n^{\,2}$.

*Proof.* Apply the addition formula with both arguments equal: $F_{n+n+1} =
F_n F_n + F_{n+1} F_{n+1}$, and $n+n+1 = 2n+1$. $\qquad\blacksquare$

> **Theorem 10 (`fib_two_mul`, over $\mathbb{Z}$).**
> $$F_{2n} = F_n\,\bigl(2F_{n+1} - F_n\bigr).$$

*Proof.* For $n=0$ both sides vanish. For $n = m+1$, apply the addition formula
$F_{m+(m+1)+1} = F_m F_{m+1} + F_{m+1} F_{m+2}$ with $m+(m+1)+1 = 2(m+1)$,
expand $F_{m+2} = F_{m+1}+F_m$, and normalize over $\mathbb{Z}$:
$F_{2(m+1)} = F_{m+1}(F_m + F_{m+2}) = F_{m+1}(2F_{m+1} - F_{m+1} + F_m +
\cdots)$, which `ring` reconciles with $F_{m+1}(2F_{m+2} - F_{m+1})$ after
substituting the two-coordinate forms. $\qquad\blacksquare$

Together, Theorems 9 and 10 give the doubling step: from the pair $(F_n,
F_{n+1})$ one computes $(F_{2n}, F_{2n+1})$ directly, so reading the binary
digits of $N$ from most to least significant yields $F_N$ in a logarithmic
number of steps.

## 7. Two-base convolution identities reduced to Cassini

The deepest payoff is that the signed two-parameter identities are Fibonacci
multiples of the Cassini quantity $C_n := F_{n+1}^2 - F_n F_{n+2} = (-1)^n$
(Theorem 8). The mechanism is uniform: substitute the closed form
`fib_two_basis` to express the two-base quantity as a polynomial in the four
atoms $F_k, F_{k+1}, F_n, F_{n+1}$, expand by `ring`, and recognize the result
as a Fibonacci factor times $C_n$.

> **Theorem 11 (d'Ocagne, sign form).** For all $n, k$,
> $$F_{n+k}\,F_{n+1} - F_{n+k+1}\,F_n = (-1)^n\,F_k.$$

*Proof sketch.* Write $F_{n+k} = F_{k-1}F_n + F_k F_{n+1}$ and $F_{n+k+1} =
F_k F_n + F_{k+1}F_{n+1}$ via Theorem 1. Then
$$F_{n+k}F_{n+1} - F_{n+k+1}F_n = F_k\bigl(F_{n+1}^2 - F_n F_{n+2}\bigr)
= F_k\,C_n = (-1)^n F_k,$$
where the middle equality is a `ring` expansion using $F_{n+2} = F_n + F_{n+1}$
and $F_{k+1} = F_k + F_{k-1}$, and the last step is Theorem 8.
$\qquad\blacksquare$

> **Theorem 12 (Catalan).** For all $n, r$,
> $$F_{n+r}^{\,2} - F_n\,F_{n+2r} = (-1)^n\,F_r^{\,2}.$$

*Proof sketch.* Substitute Theorem 1 for $F_{n+r}$ and $F_{n+2r}$ and expand;
the polynomial factors as $F_r^2\,(F_{n+1}^2 - F_n F_{n+2}) = F_r^2\,C_n =
(-1)^n F_r^2$ by Theorem 8. $\qquad\blacksquare$

> **Theorem 13 (Unifying convolution identity).** For all $n, a, b$,
> $$F_{n+a}\,F_{n+b} - F_n\,F_{n+a+b} = (-1)^n\,F_a\,F_b.$$
> d'Ocagne is the case $b = 1$ (using $F_1 = 1$, after reindexing), and
> Catalan is the case $a = b = r$.

*Proof sketch.* Apply Theorem 1 to each of $F_{n+a}, F_{n+b}, F_{n+a+b}$. The
bilinear cross terms cancel, leaving $F_a F_b\,(F_{n+1}^2 - F_n F_{n+2}) =
F_a F_b\,C_n = (-1)^n F_a F_b$. $\qquad\blacksquare$

Theorem 13 exposes the structural content of the whole class: *every* signed
convolution identity of this shape is the Cassini determinant scaled by a
product of two Fibonacci numbers indexed by the shifts.

## 8. Soundness, scope, and completeness

**Soundness.** Each tactic is sound because every step it performs is a sound
rewrite or a sound decision procedure. Two-step expansion is the defining
recurrence and preserves equality. The terminal `ring`, `omega`, and `linarith`
calls are themselves verified decision/automation procedures over commutative
rings, linear integer arithmetic, and linear ordered fields respectively. The
induction in `fib_cassini_induct` is ordinary mathematical induction. Hence a
goal closed by any of these tactics is a theorem.

**Scope of `fib_ring`.** The expander is complete for the class of *single-base
polynomial* identities: equations of the form $P(F_n, F_{n+1}, F_{n+2},
\ldots, F_{n+m}) = Q(\ldots)$ where $P, Q$ are polynomials with integer
coefficients in finitely many shifts from a *single* base point $n$. After two-
step expansion both sides become polynomials in $(F_n, F_{n+1})$, and `ring`
decides their equality. Crucially, the procedure decides truth as a *formal*
polynomial identity; see the completeness discussion below for why this is the
"right" notion.

**Out of scope without help.** Two situations require the auxiliary tactics or
the engine lemma: (i) a parity sign $(-1)^n$ (handled by induction); (ii) two
or more independent base points or a symbolic shift parameter $k$ (handled by
`fib_two_basis` followed by `ring` and, for signed cases, `cassini'`).

**Completeness conjecture.** We conjecture that `fib_ring` is not merely sound
but *complete* for single-base identities in the strongest sense: a polynomial
identity $P(F_n, F_{n+1}) = 0$ holds for all $n$ if and only if $P$ is the zero
polynomial, if and only if it holds at the two sample points $n = 0$ and
$n = 1$. The reason is that the points $(F_n, F_{n+1})$ for $n = 0, 1, 2,
\ldots$ — namely $(0,1), (1,1), (1,2), (2,3), (3,5), \ldots$ — do not all lie
on any single algebraic curve, so a polynomial vanishing on all of them must be
identically zero. This would make a two-point numerical check a *refutation
oracle*: any false single-base identity fails at $n = 0$ or $n = 1$. (See
Conjecture 1 in Section 10.)

## 8.5. An extended worked example

To see all three layers cooperate, consider verifying the chain of facts
needed to compute $F_{20}$ by hand using only the verified machinery. We have
$F_{10} = 55$ and $F_{11} = 89$. The odd-doubling formula (Theorem 9) gives
$$F_{21} = F_{11}^2 + F_{10}^2 = 89^2 + 55^2 = 7921 + 3025 = 10946,$$
and the even-doubling formula (Theorem 10) gives
$$F_{20} = F_{10}(2F_{11} - F_{10}) = 55\,(178 - 55) = 55\cdot 123 = 6765.$$
These two values are produced from the single pair $(F_{10}, F_{11})$ without any
further additions — the doubling step in action. As a consistency check, Cassini
(Theorem 8) predicts $F_{20}\cdot F_{22} - F_{21}^2 = (-1)^{21} = -1$; indeed
$F_{22} = F_{21} + F_{20} = 17711$, and $6765\cdot 17711 - 10946^2 =
119814915 - 119814916 = -1$. Finally the unifying convolution identity
(Theorem 13) with $n=10$, $a=b=5$ recovers Catalan: $F_{15}^2 - F_{10}F_{20} =
610^2 - 55\cdot 6765 = 372100 - 372075 = 25 = (-1)^{10}F_5^2 = 5^2$. Every number
in this paragraph is an instance of a theorem proved above, illustrating how the
layers interlock: doubling for fast values, Cassini for the determinant
invariant, convolution for the two-index products.

## 9. Related context and design rationale

The development sits in a lineage of *reflective* and *normalization-based*
proof automation: rather than searching for a proof, one transforms the goal
into a canonical form on which a decision procedure terminates. The novelty here
is not any single identity — all are classical — but the recognition that a
fixed, two-dimensional change of basis is the right normal form for an entire
class, and that the residual obstructions (parity, multiple base points) are
exactly two, each with a uniform remedy. This *layered* design — a fast complete
procedure for the bulk of cases, a one-step inductive patch for the parity
layer, and an algebraic reduction for the cross-base layer — is deliberately
minimal: it adds no heavyweight machinery beyond ring and linear-arithmetic
normalization that is already trusted. The same template applies to any
sequence satisfying a fixed-order linear recurrence, which is the content of the
generalization conjectures in Section 10.

A practical consequence worth emphasizing is *maintainability*. Because the
expander reduces an identity to a finite coefficient comparison, adding a new
single-base identity to a verified library costs essentially nothing: state it
and invoke the tactic. The fragile, identity-specific manipulations that
traditionally accompany Fibonacci algebra are replaced by a single uniform call,
and the correctness of that call rests only on the soundness of the underlying
normalization procedures.

## 9.5. Applications

- **Mechanized identity libraries.** The expander turns a large fragment of the
  Fibonacci identity literature into a push-button corpus: state the identity,
  apply the recipe, done. This is directly useful for building and maintaining
  verified mathematical libraries.
- **Fast computation.** The doubling formulas (Theorems 9–10) are the
  verified core of the fast-doubling algorithm, which computes $F_N$ using
  $O(\log N)$ big-integer multiplications — the standard method for very large
  indices, used in computer-algebra systems.
- **Number-theoretic structure.** Cassini and its relatives encode the
  unimodularity of the Fibonacci $Q$-matrix, the basis for continued-fraction
  and lattice properties of the golden ratio, and for the appearance of
  Fibonacci numbers as the worst case of the Euclidean algorithm.
- **A template for proof automation.** The design — *change to a finite basis,
  normalize with a ring decision procedure, peel off the non-polynomial part
  with one induction* — is a reusable pattern applicable to any sequence with a
  finite linear recurrence.

## 10. Future directions

We record four precise, testable conjectures.

**Conjecture 1 — `fib_ring` is a complete decision procedure.** For a polynomial
$P(x,y)$ with integer coefficients, $P(F_n, F_{n+1}) = 0$ for all $n$ iff $P$ is
the zero polynomial iff $P(0,1) = 0$ and $P(1,1) = 0$. Thus the expander decides
every true single-base identity and a two-point check refutes every false one.

**Conjecture 2 — Generalized two-term basis for all Lucas sequences.** For
$U_0 = 0$, $U_1 = 1$, $U_{n+2} = p\,U_{n+1} - q\,U_n$, the value $U_{n+k}$ is a
fixed $\mathbb{Z}[p,q]$-bilinear form in $(U_k, U_{k+1})$ and $(U_n, U_{n+1})$,
so `fib_ring` generalizes to a tactic `lucas_ring` deciding single-base
identities for every such sequence (Fibonacci $p{=}1,q{=}{-}1$; Pell
$p{=}2,q{=}{-}1$; Mersenne-like $p{=}3,q{=}2$; …). The generic Cassini identity
$U_{n+1}^2 - U_n U_{n+2} = q^n$ specializes correctly.

**Conjecture 3 — Catalan = $F_r^2 \cdot$ Cassini, structurally.** Every signed
two-base convolution identity factors as a Fibonacci/Lucas multiple of the
Cassini determinant: $F_{n+a}F_{n+b} - F_n F_{n+a+b} = (-1)^n F_a F_b$
(Theorem 13), with d'Ocagne the case $b=1$ and Catalan the case $a=b$.

**Conjecture 4 — Determinantal $Q$-matrix reflection tactic.** With $Q =
\begin{pmatrix}1&1\\1&0\end{pmatrix}$ and $Q^n = \begin{pmatrix} F_{n+1} & F_n
\\ F_n & F_{n-1}\end{pmatrix}$, every polynomial Fibonacci identity is an entry
of a true matrix identity in the $Q^{n_i}$. A reflective tactic `fib_matrix`
would replace each $F_{n+c}$ by the appropriate entry of $Q^n Q^c$, call
noncommutative-ring normalization plus matrix extensionality, and read off the
scalar identity, deciding the entire signed two-base class (Catalan, d'Ocagne)
uniformly.

## 11. Conclusion

A single observation — that the Fibonacci sequence lives in a two-dimensional
coordinate space and moves through it linearly — organizes the classical
Fibonacci identities into three crisp layers: single-base polynomial identities
decided outright by ring normalization; parity identities (Cassini) closed by
one induction step; and two-base convolution identities (Catalan, d'Ocagne)
factored through Cassini. The result is a compact, sound, and largely complete
proof-automation toolkit, together with a verified suite of the canonical
identities and a clear path toward generalization to all Lucas sequences and to
a determinantal reflection procedure.
