# Chapter 6: The Church–Turing Thesis

## 6.1 The Convergence

In the span of just two years (1935–1936), three independent formalizations of
"computable function" emerged:

1. **λ-definable functions** (Church, 1936): Functions expressible in the lambda calculus.
2. **Turing-computable functions** (Turing, 1936): Functions computable by Turing machines.
3. **General recursive functions** (Gödel–Herbrand–Kleene, 1934–1936): Functions built
   from primitive recursion, composition, and the μ-operator (unbounded search).

These three formalizations were developed independently, with different motivations and
very different mathematical flavors. Lambda calculus is algebraic and functional. Turing
machines are mechanical and operational. Recursive functions are arithmetical and
constructive.

And yet, they define *exactly the same class of functions*.

## 6.2 The Equivalence Proofs

The equivalence of these models was established through a chain of reductions:

- **Church and Kleene** (1936) showed that λ-definable functions = general recursive
  functions.
- **Turing** (1937) showed that Turing-computable functions = λ-definable functions.

Each proof is a simulation: given a lambda term, one constructs a Turing machine that
computes the same function, and vice versa. The proofs are not trivial — Turing's
simulation of the lambda calculus requires careful encoding of terms and reduction steps on
a tape — but they are entirely constructive.

Since then, many other models have been shown equivalent:

- **Post machines** (Emil Post, 1936)
- **Register machines** (Shepherdson–Sturgis, 1963)
- **Markov algorithms** (Andrey Markov, 1960)
- **Cellular automata** (von Neumann, 1966; Conway's Game of Life)
- **Tag systems** (Post, 1943)
- **String rewriting systems**
- **While programs** (various)

Every model of computation that anyone has ever proposed — if it is powerful enough to
simulate basic arithmetic and conditionals — turns out to compute exactly the same class of
functions.

## 6.3 The Thesis

The **Church–Turing thesis** states:

> **The class of functions computable by an effective procedure (algorithm) is exactly the
> class of Turing-computable functions.**

Note that this is *not* a mathematical theorem — it cannot be proved, because "effective
procedure" is an informal notion. It is instead a *thesis*: a claim that connects a formal
concept (Turing-computability) to an informal one (effective computability). Its status is
more like a physical law than a mathematical theorem.

The evidence for the thesis is overwhelming:

1. **Convergence of formalizations**: Every rigorous attempt to formalize "algorithm" has
   produced the same class of functions. This is strong inductive evidence.

2. **Completeness of the model**: No one has ever found a function that is "intuitively
   computable" but not Turing-computable.

3. **Robustness**: The class of Turing-computable functions is extremely robust —
   modifying Turing machines in almost any way (multiple tapes, nondeterminism, two-way
   infinite tape, higher-dimensional tape) does not change it.

4. **Physical realizability**: Every physical computing device ever built computes only
   Turing-computable functions (as far as we know).

## 6.4 What the Thesis Does and Does Not Say

The Church–Turing thesis says:

- ✅ If a function is computable by any algorithm whatsoever, then it is computable by a
  Turing machine.
- ✅ The notion of "computable function" is mathematically robust and well-defined.

The Church–Turing thesis does *not* say:

- ❌ That Turing machines can compute *efficiently*. A function might be Turing-computable
  but require exponential time. The **extended Church–Turing thesis** (that polynomial-time
  computability is robust across models) is a separate, and currently open, question — one
  that quantum computing may refute.
- ❌ That the physical universe is a Turing machine. The thesis is about what *algorithms*
  can compute, not about what *physics* can do.
- ❌ That human minds are Turing machines. This is a separate philosophical question
  (related to the Lucas–Penrose argument and Gödel's theorems).

## 6.5 Challenges and Alternatives

Several challenges to the Church–Turing thesis have been proposed:

### Hypercomputation
Some authors have proposed models that compute functions beyond the Turing-computable
ones:
- **Oracle machines**: TMs augmented with an "oracle" for the halting problem.
- **Infinite time Turing machines**: TMs that can run for transfinitely many steps.
- **Analog computation**: Hypothetical systems using continuous physical processes.

None of these are physically realizable (as far as we know), and most computability
theorists regard them as interesting mathematical objects rather than genuine challenges to
the thesis.

### Quantum Computing
Quantum computers *do* exist and *can* solve some problems faster than classical computers
(e.g., Shor's algorithm for factoring). However, they compute the same *class* of
functions as Turing machines — they are faster, not more powerful. Quantum computing
challenges the *extended* Church–Turing thesis (about polynomial-time computation) but not
the original thesis (about computability).

### Interactive Computation
Goldin and Wegner have argued that interactive computation — computation involving ongoing
interaction with an environment — goes beyond the Turing machine model. However, this can
be modeled by Turing machines with oracle access, and whether it constitutes a genuine
challenge to the thesis depends on how one interprets "effective procedure."

## 6.6 The Thesis in Practice

For working computer scientists, the Church–Turing thesis has a practical consequence: it
doesn't matter which model of computation you use. If you can describe an algorithm in
Python, pseudocode, lambda calculus, or English, it can be implemented on a Turing machine,
and hence on any real computer (given enough time and memory).

This is why computer science courses can freely switch between formalisms — proving a
language undecidable by a reduction argument works regardless of whether we think of our
machines as Turing machines, lambda calculus evaluators, or C++ programs.

## 6.7 Formal Statement in Lean

While the Church–Turing thesis itself cannot be proved (it connects informal and formal
notions), we *can* formalize the equivalence of formal models. For example, we can state
that a function is Turing-computable if and only if it is λ-definable:

```lean
-- Informal statement (not directly formalizable as one side is informal):
-- A function f : ℕ → ℕ is "effectively computable" iff it is Turing-computable.

-- What we CAN formalize is the equivalence of formal models:
-- theorem turing_iff_lambda_definable (f : ℕ → ℕ) :
--   TuringComputable f ↔ LambdaDefinable f

-- And the equivalence of Turing machines with recursive functions:
-- theorem turing_iff_recursive (f : ℕ → ℕ) :
--   TuringComputable f ↔ GeneralRecursive f
```

These equivalences are the formal content behind the informal thesis.

## 6.8 Historical Note

The timing of the convergence is remarkable. Church published his paper in April 1936.
Turing submitted his paper in May 1936 (it appeared in January 1937). Turing learned of
Church's work only after completing his own — the two approached the problem from
completely different directions and arrived at the same answer.

Gödel initially had doubts about Church's thesis, finding the lambda calculus too
restrictive. But when he saw Turing's analysis — which started from the intuitive notion of
a human following a mechanical procedure — he was convinced. In a 1946 address, Gödel said:

> "Turing's work gives an analysis of the concept of 'mechanical procedure' (alias
> 'algorithm' or 'computation procedure' or 'finite combinatorial procedure'). This
> concept is shown to be equivalent with that of a 'Turing machine.' A formal system can
> simply be defined to be any mechanical procedure for producing formulas, called provable
> formulas."

The convergence of independent formalizations remains one of the most striking phenomena
in the foundations of mathematics — and one of the strongest pieces of evidence for the
thesis that bears Church's and Turing's names.

---

*"No attempted definition of effective calculability has turned out to be more
inclusive than another."*
— Stephen Kleene, *Introduction to Metamathematics*, 1952
