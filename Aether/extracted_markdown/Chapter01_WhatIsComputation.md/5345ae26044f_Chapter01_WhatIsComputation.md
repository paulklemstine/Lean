# Chapter 1: What Is Computation?

## 1.1 The Question

Before there were computers, there was computation. The word itself derives from the Latin
*computare* — to reckon, to settle accounts. For millennia, computation meant arithmetic:
adding columns of numbers, multiplying quantities, dividing estates. It was the work of
human computers, people (often women) employed to carry out tedious but essential
calculations by hand.

But computation is far more than arithmetic. When Euclid described his algorithm for
finding the greatest common divisor of two numbers around 300 BCE, he was not merely
performing a calculation — he was specifying a *procedure*, a finite sequence of
unambiguous instructions that, given any two positive integers, would terminate with their
GCD. This is the essence of an algorithm, and algorithms are the atoms of computation.

The question "What is computation?" can be asked at many levels:

- **Mechanically**: What physical processes can carry out computations?
- **Mathematically**: What functions can be computed by an algorithm?
- **Philosophically**: Is the universe itself a computation?

This book is primarily concerned with the mathematical question, though the others will
make occasional appearances. We will build a precise, formal theory of what it means to
compute — a theory that was forged in the 1930s by a remarkable group of logicians and
mathematicians, and that remains the foundation of computer science today.

## 1.2 Algorithms Before Computers

The history of algorithms predates the history of the word "algorithm" itself. Euclid's
algorithm, the Sieve of Eratosthenes, al-Khwarizmi's procedures for solving quadratic
equations — these are all algorithms, even though their creators never used the term.

What these procedures share is a set of properties that we now recognize as essential:

1. **Finiteness**: The procedure consists of a finite number of instructions.
2. **Definiteness**: Each instruction is precise and unambiguous.
3. **Input**: The procedure receives some input data.
4. **Output**: The procedure produces some output data.
5. **Effectiveness**: Each instruction can be carried out in a finite amount of time using
   basic operations.

These informal properties were sufficient for centuries. But in the early twentieth
century, a crisis in the foundations of mathematics forced logicians to ask: can we make
these notions *perfectly* precise? And if so, are there problems that *no* algorithm can
solve?

## 1.3 Hilbert's Program and the Decision Problem

In 1928, David Hilbert and Wilhelm Ackermann posed the *Entscheidungsproblem* (decision
problem): is there an algorithm that takes as input a statement of first-order logic and
decides whether or not it is universally valid?

This question presupposes that we know what an "algorithm" is. In 1928, that notion was
still informal. But within a decade, three independent formalizations emerged:

- **Alonzo Church's lambda calculus** (1936): Computation as function abstraction and
  application.
- **Alan Turing's machines** (1936): Computation as the mechanical manipulation of symbols
  on a tape.
- **Kurt Gödel and Jacques Herbrand's recursive functions** (1934): Computation as the
  construction of functions from primitive operations by recursion and minimization.

The remarkable fact — and we will see why it is remarkable — is that all three
formalizations turned out to define exactly the same class of computable functions. This
convergence is the empirical foundation of the Church–Turing thesis.

And the answer to Hilbert's question? It was *no*. Church and Turing independently proved
that the Entscheidungsproblem is unsolvable: no algorithm can decide the universal validity
of first-order logic. This negative result, far from being a defeat, opened up an entirely
new field of mathematics — the theory of computation.

## 1.4 Computation as a Mathematical Object

In this book, we will treat computation as a mathematical object, subject to the same
rigorous analysis as groups, topological spaces, or measure spaces. Our tool for this
analysis is Lean 4, a dependently typed programming language and proof assistant.

Lean 4 is uniquely suited to this task because it embodies a deep connection between
computation and logic known as the *Curry–Howard correspondence*:

| Logic                  | Computation              |
|------------------------|--------------------------|
| Proposition            | Type                     |
| Proof                  | Program (term)           |
| Implication A → B      | Function type A → B      |
| Conjunction A ∧ B      | Product type A × B       |
| Disjunction A ∨ B      | Sum type A ⊕ B           |
| Universal ∀ x, P x     | Dependent function (x : α) → P x |
| Existential ∃ x, P x   | Dependent pair ⟨x, h⟩   |

In Lean, writing a proof *is* writing a program, and type-checking a proof *is* verifying
its correctness. This is not a metaphor — it is a precise mathematical identity.

## 1.5 A First Taste: The GCD

Let us begin where computation began: with Euclid's algorithm. In Lean 4, we can define
the GCD by well-founded recursion on the second argument:

```lean
def gcd : Nat → Nat → Nat
  | m, 0     => m
  | m, n + 1 => gcd (n + 1) (m % (n + 1))
```

This definition is *total* — Lean verifies that the recursion terminates for all inputs,
because `m % (n + 1) < n + 1`. We can then *prove* properties of this function:

```lean
theorem gcd_dvd_left (m n : Nat) : gcd m n ∣ m := by
  ...

theorem gcd_dvd_right (m n : Nat) : gcd m n ∣ n := by
  ...

theorem dvd_gcd (d m n : Nat) (hm : d ∣ m) (hn : d ∣ n) : d ∣ gcd m n := by
  ...
```

The fact that we can both *compute* and *prove* within the same language is the central
miracle of dependent type theory, and the animating idea of this book.

## 1.6 What Lies Ahead

In the chapters that follow, we will build the theory of computation from the ground up:

- **Chapters 2–3** introduce the simplest models of computation — finite automata and
  pushdown automata — and the languages they recognize.
- **Chapters 4–5** present the two great formalizations of general computation: the lambda
  calculus and Turing machines.
- **Chapter 6** discusses the Church–Turing thesis and what it means.
- **Chapters 7–10** explore the boundary between the decidable and the undecidable.
- **Chapters 11–15** examine computational complexity, from P vs NP to quantum computation.

Throughout, we will formalize key definitions and theorems in Lean 4, building a library
that is both a reference and a proof of concept — computation studying itself.

---

*"The Entscheidungsproblem is considered the main problem of mathematical logic."*
— David Hilbert and Wilhelm Ackermann, *Grundzüge der theoretischen Logik*, 1928
