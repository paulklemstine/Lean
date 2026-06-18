# One Operation, One Seed, All the Reals: Density of the EML Closure

## Abstract

We introduce the **EML operation** $\text{EML}(a, b) = e^a - \ln b$ and study the closure
of the singleton set $\{1\}$ under repeated application of this binary operation. We prove
that the resulting countable set is **dense** in $\mathbb{R}$, meaning every real number
can be approximated to arbitrary precision by EML expressions built from the single
seed value 1. All results have been formally verified in the Lean 4 theorem prover with the
Mathlib library.

**Keywords:** definability, density, transcendental operations, formal verification, Lean 4

---

## 1. Introduction

How many operations and starting values does one need to "reach" every corner of the
real line? In classical computability theory, this question is explored through
computable reals and definability — but here we ask a simpler, more algebraic question.

**Definition 1.1.** The *EML operation* (Exp Minus Log) is the binary function
$$\text{EML}(a, b) = e^a - \ln b.$$

**Definition 1.2.** The *EML closure* of a set $S \subseteq \mathbb{R}$ at depth $n$ is
defined recursively:
$$C_0(S) = S, \quad C_{n+1}(S) = C_n(S) \cup \{\text{EML}(a,b) : a, b \in C_n(S)\}.$$
The *full EML closure* is $C(S) = \bigcup_{n=0}^{\infty} C_n(S)$.

Our main result is:

**Theorem 1.3 (Main Theorem).** *The full EML closure of $\{1\}$ is dense in $\mathbb{R}$.*

This theorem demonstrates a striking phenomenon: from a single rational seed and a single
transcendental-arithmetic operation, one generates a countable set dense in the reals.

---

## 2. Algebraic Structure of EML

The EML operation has remarkably rich algebraic structure, which we exploit throughout.

**Proposition 2.1** (Specializations).
- $\text{EML}(x, 1) = e^x$ (exponentiation)
- $\text{EML}(0, x) = 1 - \ln x$ (log complement)

**Proposition 2.2** (Log-split).
For $y, z > 0$: $\text{EML}(x, yz) = \text{EML}(x, y) - \ln z.$

**Proposition 2.3** (Shift identity).
$\text{EML}(x + c, 1) = e^c \cdot e^x.$

**Proposition 2.4** (Scaled inversion).
For $x > 0$: $\text{EML}(\text{EML}(0, x), 1) = e/x.$

**Proposition 2.5** (Double negation).
$\text{EML}(0, e^{\text{EML}(0, e^x)}) = x.$

These identities show that EML subsumes exponentiation, logarithm, and scaled inversion
as special cases, explaining its expressiveness.

---

## 3. Derived Operations in the Full Closure

The key to our density proof is establishing that $C(\{1\})$ supports a rich collection
of derived operations.

### 3.1. Exponentiation and Log-Complement

Since $1 \in C(\{1\})$, for any $x \in C(\{1\})$:
$$e^x = \text{EML}(x, 1) \in C(\{1\}).$$

Once $0 \in C(\{1\})$ (proved in §3.3), for any $x \in C(\{1\})$:
$$1 - \ln x = \text{EML}(0, x) \in C(\{1\}).$$

### 3.2. The "1 minus" Operation

For any $x \in C(\{1\})$:
$$1 - x = \text{EML}(0, e^x) = 1 - \ln(e^x) \in C(\{1\}).$$

This is the composition of exponentiation (§3.1) with log-complement.

### 3.3. Zero Enters the Closure

$0 \in C_3(\{1\})$, constructed as:
1. $e = \text{EML}(1, 1) \in C_1$
2. $e^e = \text{EML}(e, 1) \in C_2$
3. $0 = \text{EML}(1, e^e) = e - \ln(e^e) = e - e = 0 \in C_3$

### 3.4. Logarithm

For any $x \in C(\{1\})$:
$$\ln x = 1 - (1 - \ln x) \in C(\{1\}),$$
using the log-complement $1 - \ln x \in C(\{1\})$ and the "1 minus" operation.

### 3.5. Subtraction from Positive Elements

For $x > 0$ with $x \in C(\{1\})$ and any $y \in C(\{1\})$:
$$x - y = \text{EML}(\ln x, e^y) = e^{\ln x} - \ln(e^y) = x - y \in C(\{1\}).$$

### 3.6. Addition — The Key Construction

**Proposition 3.1.** *For any $x, y \in C(\{1\})$, $x + y \in C(\{1\})$.*

*Proof.* Choose $N \in \mathbb{N}$ large enough that $e^N > x$ and $e^N > y$ (possible since
$e^N \to \infty$ and $\mathbb{N} \subset C(\{1\})$ by §4). Then:

1. $e^N \in C(\{1\})$ and $e^N > 0$
2. $e^N - x \in C(\{1\})$ by subtraction (§3.5), with $e^N - x > 0$
3. $(e^N - x) - y \in C(\{1\})$ by subtraction again
4. $x + y = e^N - ((e^N - x) - y) \in C(\{1\})$ by subtraction from $e^N > 0$.  $\square$

---

## 4. The Closure Contains All Integers

**Theorem 4.1.** $\mathbb{Z} \subset C(\{1\})$.

*Proof.* We first prove $\mathbb{N} \subset C(\{1\})$ by induction. The base cases
$0, 1 \in C(\{1\})$ follow from §3.3 and the seed. For the inductive step, assume
$n \geq 1$ and $n \in C(\{1\})$. Then:

1. $e - 1 \in C(\{1\})$ (subtract 1 from $e > 0$)
2. $e - 2 = (e-1) - 1 \in C(\{1\})$ (subtract 1 from $e-1 > 0$)
3. $n - (e - 2) \in C(\{1\})$ (subtract $e-2$ from $n > 0$)
4. $1 - (n - (e-2)) \in C(\{1\})$ (the "1 minus" operation)
5. $n + 1 = e - (1 - (n - (e-2))) \in C(\{1\})$ (subtract from $e > 0$)

For negative integers: $-(n+1) = 1 - (n+2) \in C(\{1\})$. $\square$

---

## 5. Irrationality of $e$

**Theorem 5.1.** *The number $e = \exp(1)$ is irrational.*

*Proof.* We use the classical factorial series argument. Suppose $e = p/q$ with $p, q$
positive integers. Consider the series $e = \sum_{k=0}^{\infty} 1/k!$. Multiplying by $q!$:
$$q! \cdot e = \underbrace{\sum_{k=0}^{q} \frac{q!}{k!}}_{\text{integer}} + \underbrace{\sum_{k=1}^{\infty} \frac{q!}{(q+k)!}}_{\text{tail}}.$$
The tail series is bounded by a geometric series: $\text{tail} \leq \frac{1}{q+1} \cdot \frac{1}{1 - 1/(q+2)} < 1$.
Since the tail is also positive (each term is positive), we have $0 < \text{tail} < 1$.
But $q! \cdot e = q! \cdot p/q$ is an integer minus another integer, hence itself an integer.
This contradicts $0 < \text{tail} < 1$. $\square$

**Corollary 5.2.** $e - 2$ is irrational.

---

## 6. The Density Theorem

**Theorem 6.1 (Main Theorem).** *The full EML closure $C(\{1\})$ is dense in $\mathbb{R}$.*

*Proof.* Consider the set $G = \{m + n(e-2) : m, n \in \mathbb{Z}\}$. We have shown:

1. $\mathbb{Z} \subset C(\{1\})$ (Theorem 4.1)
2. $e - 2 \in C(\{1\})$ (subtraction from $e > 0$)
3. $C(\{1\})$ is closed under addition (Proposition 3.1)

Therefore $G \subseteq C(\{1\})$.

The set $G$ is an additive subgroup of $(\mathbb{R}, +)$. By Kronecker's theorem
(formalized in Mathlib as `AddSubgroup.dense_or_cyclic`), every additive subgroup of
$\mathbb{R}$ is either dense or cyclic (generated by a single element).

If $G$ were cyclic, generated by some $a \in \mathbb{R}$, then $1 = ka$ and $e - 2 = ma$
for some $k, m \in \mathbb{Z}$, giving $e - 2 = m/k \in \mathbb{Q}$. This contradicts
the irrationality of $e - 2$ (Corollary 5.2).

Therefore $G$ is dense, and since $G \subseteq C(\{1\})$, the closure $C(\{1\})$
is also dense. $\square$

---

## 7. Discussion: One Operation to Name Them All

### For the General Reader

Imagine you have a calculator with only one button: it takes two numbers $a$ and $b$
and returns $e^a - \ln b$, where $e \approx 2.718$ is Euler's number. You start with
just the number 1 on your display. Can you approximate $\pi$? Can you get close to
$\sqrt{2}$? What about -7.777?

The answer, perhaps surprisingly, is **yes** — you can approximate *any* real number
to any desired precision, using nothing but this one operation and the starting value 1.

This is what our density theorem says mathematically: the set of all numbers you can
produce is "dense" in the real line, meaning it fills up every interval, no matter
how tiny. Between any two real numbers, no matter how close, there's always an EML
expression that lands between them.

### Why This Matters

**Minimality and universality.** We've shown that a single binary operation over a
single seed generates a dense subset of $\mathbb{R}$. This is a kind of "universality"
result — the EML operation is expressive enough, through iteration alone, to approximate
all of analysis.

**The role of transcendence.** The proof crucially depends on the *irrationality of $e$*.
If $e$ were rational, the subgroup $\{m + n(e-2)\}$ would be cyclic and hence discrete,
not dense. The transcendental nature of $\exp$ and $\ln$ — built into EML — is what
breaks the barrier between the countable and the continuous.

**Connections to logic and definability.** In mathematical logic, a fundamental question
is: which real numbers can be "named" or "defined" by finite expressions in a given
language? Our result provides a concrete answer for the EML language: while only countably
many reals have EML names, they are distributed densely enough to approximate every real.

### Historical Context

The density of $\{m + n\alpha : m, n \in \mathbb{Z}\}$ for irrational $\alpha$
is a classical result in number theory, often attributed to Kronecker (1884) and closely
related to Weyl's equidistribution theorem (1916). Our contribution is to show that
this classical density arises naturally from a single algebraic-transcendental operation.

The irrationality of $e$ was first proved by Euler (1737). Our formal proof in Lean 4
follows the standard factorial series argument, providing a machine-verified
reconstruction of this 288-year-old result.

### Future Directions

1. **Measure theory.** The EML closure is countable, hence has Lebesgue measure zero.
   What are its topological properties beyond density? Is it a $G_\delta$-dense set?

2. **Complexity.** Given a target real $r$ and precision $\varepsilon$, what is the
   minimum depth $n$ such that $C_n(\{1\})$ contains an $\varepsilon$-approximation to $r$?

3. **Other operations.** What other single binary operations $f(a,b)$ have the property
   that $C_f(\{1\})$ is dense? We conjecture that $f(a,b) = a^b - b$ also works, but
   $f(a,b) = a + b$ clearly does not (the closure is $\{n : n \in \mathbb{Z}\}$).

4. **Constructive aspects.** Our density proof is non-constructive (via Kronecker's
   theorem). Can one give explicit bounds on the depth needed to $\varepsilon$-approximate
   a given target?

---

## 8. Formal Verification

All results in this paper have been formally verified in **Lean 4** (version 4.28.0)
using the **Mathlib** library. The formalization consists of approximately 350 lines
of Lean code and includes:

- 12 algebraic identities for the EML operation
- The irrationality of $e$ via the factorial series method
- Closure under EMLd, exponentiation, logarithm, subtraction, and addition
- All integers belong to the full closure
- The density theorem via `AddSubgroup.dense_or_cyclic`

The complete formalization is in `Logic/EMLDensityTheory.lean`.

---

## References

1. L. Euler, *De fractionibus continuis dissertatio*, 1737.
2. L. Kronecker, *Näherungsweise ganzzahlige Auflösung linearer Gleichungen*, 1884.
3. H. Weyl, *Über die Gleichverteilung von Zahlen mod. Eins*, Math. Ann. 77 (1916), 313–352.
4. The Mathlib Community, *Mathlib: a unified library of mathematics formalized in Lean 4*, 2024.
