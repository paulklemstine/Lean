# Chapter 4: The Lambda Calculus

## 4.1 Computation Without Machines

In 1936, Alonzo Church published a paper that would change mathematics forever. Rather than
defining computation in terms of machines, tapes, and symbols, Church defined it in terms
of the most basic operation in all of mathematics: *function application*.

The lambda calculus is startlingly simple. It has only three kinds of expressions:

1. **Variables**: `x`, `y`, `z`, ...
2. **Abstraction**: `λx. M` (a function that takes `x` and returns `M`)
3. **Application**: `M N` (applying function `M` to argument `N`)

That's it. No numbers, no booleans, no data structures, no loops, no if-then-else. And yet
this tiny language can express *every computable function*. The lambda calculus is the
ultimate exercise in minimalism — it proves that computation requires nothing more than
the ability to define and apply functions.

## 4.2 Syntax

We formalize lambda terms as an inductive type. We use de Bruijn indices to avoid the
complexities of variable naming and α-equivalence:

```lean
inductive LambdaTerm : Type where
  | var : Nat → LambdaTerm
  | abs : LambdaTerm → LambdaTerm
  | app : LambdaTerm → LambdaTerm → LambdaTerm
```

With de Bruijn indices, a variable is represented by a natural number indicating how many
binders (λ's) one must cross to reach the binding site. For example:

- The identity function `λx. x` becomes `abs (var 0)`
- The constant function `λx. λy. x` becomes `abs (abs (var 1))`
- Self-application `λx. x x` becomes `abs (app (var 0) (var 0))`

## 4.3 β-Reduction

The sole computational rule of the lambda calculus is **β-reduction**:

> `(λx. M) N →β M[x := N]`

That is, applying an abstraction to an argument substitutes the argument for the bound
variable in the body. This is the entire engine of computation.

For example:
- `(λx. x) y →β y` (the identity applied to `y`)
- `(λx. x x)(λx. x x) →β (λx. x x)(λx. x x)` (infinite loop!)

The second example shows that not all computations terminate — the term `Ω = (λx. x x)(λx. x x)`
reduces to itself forever.

## 4.4 Church Encodings

Despite having no built-in data types, the lambda calculus can encode all of them:

### Booleans
```
TRUE  = λt. λf. t
FALSE = λt. λf. f
IF    = λb. λt. λf. b t f
AND   = λp. λq. p q FALSE
OR    = λp. λq. p TRUE q
NOT   = λp. p FALSE TRUE
```

### Natural Numbers (Church Numerals)
```
0 = λf. λx. x
1 = λf. λx. f x
2 = λf. λx. f (f x)
3 = λf. λx. f (f (f x))
n = λf. λx. fⁿ x
```

A Church numeral `n` is a function that takes a function `f` and a value `x` and applies
`f` to `x` exactly `n` times. Arithmetic operations emerge naturally:

```
SUCC = λn. λf. λx. f (n f x)
PLUS = λm. λn. λf. λx. m f (n f x)
MULT = λm. λn. λf. m (n f)
```

### Pairs
```
PAIR  = λa. λb. λf. f a b
FST   = λp. p TRUE
SND   = λp. p FALSE
```

### Lists
```
NIL   = λc. λn. n
CONS  = λh. λt. λc. λn. c h (t c n)
```

This is the Church encoding of lists as right folds — the list `[1, 2, 3]` is encoded as
`λc. λn. c 1 (c 2 (c 3 n))`.

## 4.5 Recursion and the Y Combinator

How can we define recursive functions in a language with no explicit recursion mechanism?
The answer is one of the most beautiful constructions in all of computer science: the
**fixed-point combinator**.

A fixed-point combinator is a term `Y` such that for all `f`:

> `Y f =β f (Y f)`

That is, `Y f` is a fixed point of `f`. Haskell Curry's Y combinator achieves this:

```
Y = λf. (λx. f (x x))(λx. f (x x))
```

Let's verify: `Y f = (λx. f (x x))(λx. f (x x)) →β f ((λx. f (x x))(λx. f (x x))) = f (Y f)`.

Using `Y`, we can define the factorial function:

```
FACT = Y (λf. λn. IF (ISZERO n) 1 (MULT n (f (PRED n))))
```

The Y combinator "ties the knot" of recursion without any built-in recursive mechanism.
This shows that recursion is not a primitive — it can be derived from pure lambda
abstraction and application.

## 4.6 Confluence and the Church–Rosser Theorem

A natural question arises: if a term has multiple possible reductions, can they lead to
different results? The **Church–Rosser theorem** says no:

**Theorem (Church–Rosser, 1936)**. If `M →*β N₁` and `M →*β N₂`, then there exists a term
`P` such that `N₁ →*β P` and `N₂ →*β P`.

This means that β-reduction is **confluent**: all reduction paths from the same term lead
to the same normal form (if one exists). In particular, if a term has a normal form, it is
unique.

However, not all reduction strategies will find the normal form. **Leftmost-outermost
reduction** (also called *normal order reduction*) is special: it finds the normal form
whenever one exists. This is the computational analogue of lazy evaluation.

## 4.7 Simply Typed Lambda Calculus

The untyped lambda calculus is powerful but dangerous — terms like `Ω` loop forever, and
there is no way to prevent nonsensical applications like applying a number to a boolean.
The **simply typed lambda calculus** (STLC) adds types to tame this chaos:

```
Types:    τ ::= α | τ₁ → τ₂
Terms:    M ::= x | λ(x : τ). M | M N
```

Typing rules ensure that functions are applied only to arguments of the correct type. In
exchange, we get a remarkable guarantee:

**Strong Normalization Theorem**. Every well-typed term in the simply typed lambda calculus
has a normal form. In other words, every computation terminates.

This means the STLC cannot express all computable functions — it sacrifices Turing
completeness for termination. But it is the foundation of modern type theory, and by
carefully extending it (with recursive types, dependent types, or general recursion), we
can recover full expressiveness while retaining useful type-theoretic structure.

## 4.8 The Curry–Howard Correspondence

The most profound connection between logic and computation emerges from the simply typed
lambda calculus. The Curry–Howard correspondence observes that:

- Types correspond to propositions
- Terms correspond to proofs
- The typing judgment `Γ ⊢ M : τ` corresponds to the logical judgment "from assumptions
  `Γ`, we can prove `τ`"
- β-reduction corresponds to proof simplification (cut elimination)

Under this correspondence, the STLC corresponds to propositional intuitionistic logic. The
type `A → B` is both a function type and an implication. A term `λ(x : A). M : A → B` is
both a function and a proof that `A` implies `B`.

This correspondence extends far beyond the STLC:

| Type Theory                    | Logic                           |
|--------------------------------|--------------------------------|
| Simply typed λ-calculus        | Propositional logic            |
| System F (polymorphism)        | Second-order logic             |
| Dependent types (Lean, Coq)    | Higher-order constructive logic |
| Linear types                   | Linear logic                   |

Lean 4 is built on the Calculus of Inductive Constructions, a dependent type theory where
this correspondence reaches its full generality. Every Lean proof is a program; every
program is a proof.

## 4.9 From Lambda Calculus to Lean

Lean 4's core language is a descendant of the lambda calculus, extended with:

- **Dependent types**: Types can depend on values. `(n : Nat) → Vector α n` is the type of
  functions that take a natural number `n` and return a vector of length `n`.
- **Inductive types**: Natural numbers, lists, trees, and other data types are defined by
  their constructors and elimination principles.
- **A universe hierarchy**: `Prop`, `Type 0`, `Type 1`, ... to avoid Russell-style
  paradoxes.
- **Definitional equality**: Lean's kernel reduces terms and checks that two types are
  definitionally equal, automating many computational steps.

When you write `fun x => x + 1` in Lean, you are writing a lambda term. When you write
`theorem foo : P → Q := fun h => ...`, you are constructing a proof-term in the
lambda calculus. The tools have changed since 1936, but the idea is exactly the same.

## 4.10 Universality

Church proved that every computable function (in the intuitive sense) can be represented
in the lambda calculus. More precisely:

**Church's Thesis (Lambda Calculus Version)**. A function `f : ℕ → ℕ` is computable if and
only if there exists a lambda term `F` such that for all `n`, `F n̄ =β f(n)̄`, where `n̄`
is the Church numeral for `n`.

This was the first precise definition of computability, published slightly before Turing's
paper. As we will see in Chapter 6, Church's and Turing's definitions turned out to be
equivalent — a convergence that gives the Church–Turing thesis its force.

---

*"There is a sense in which mathematical logic provides the theoretical
background for the computer programmer in the same way as the calculus provides
the theoretical background for the physicist."*
— Alonzo Church
