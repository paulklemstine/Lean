# Chapter 2: Finite Automata and Regular Languages

## 2.1 The Simplest Machines

Imagine a machine with no memory — or rather, a machine whose entire memory consists of a
single pointer into a finite set of states. The machine reads its input one symbol at a
time, from left to right, and at each step, it transitions from one state to another based
on the current symbol and its current state. When the input is exhausted, the machine
either accepts or rejects based on which state it occupies.

This is a *deterministic finite automaton* (DFA), and despite its severe limitations, it is
a surprisingly powerful model of computation. DFAs recognize exactly the *regular
languages* — a class that includes many practically important pattern languages (think
regular expressions in programming) and that serves as the foundation for lexical analysis
in compilers.

## 2.2 Formal Definition

A DFA is a 5-tuple `(Q, Σ, δ, q₀, F)` where:

- `Q` is a finite set of **states**
- `Σ` is a finite **alphabet** (set of input symbols)
- `δ : Q × Σ → Q` is the **transition function**
- `q₀ ∈ Q` is the **start state**
- `F ⊆ Q` is the set of **accept states** (or final states)

In Lean, we can represent this cleanly using structures:

```lean
structure DFA (Q : Type) (Σ : Type) where
  start : Q
  transition : Q → Σ → Q
  accept : Q → Prop
```

The finiteness of `Q` and `Σ` is captured by `[Fintype Q]` and `[Fintype Σ]` instances.

## 2.3 The Run of a DFA

Given an input word `w = a₁a₂...aₙ`, the DFA starts in state `q₀` and computes:

```
q₁ = δ(q₀, a₁)
q₂ = δ(q₁, a₂)
...
qₙ = δ(qₙ₋₁, aₙ)
```

The machine accepts `w` if and only if `qₙ ∈ F`. In Lean:

```lean
def DFA.run (M : DFA Q Σ) (w : List Σ) : Q :=
  w.foldl M.transition M.start

def DFA.accepts (M : DFA Q Σ) (w : List Σ) : Prop :=
  M.accept (M.run w)
```

The language recognized by `M` is the set of all words it accepts:

```lean
def DFA.language (M : DFA Q Σ) : Set (List Σ) :=
  { w | M.accepts w }
```

## 2.4 Nondeterministic Finite Automata

A *nondeterministic* finite automaton (NFA) is like a DFA, but the transition function
maps each state-symbol pair to a *set* of possible next states. Additionally, the NFA may
make *ε-transitions* — transitions that consume no input.

```lean
structure NFA (Q : Type) (Σ : Type) where
  start : Set Q
  transition : Q → Σ → Set Q
  accept : Q → Prop
```

An NFA accepts a word if *there exists* a sequence of transitions leading from a start
state to an accept state. Nondeterminism is existential: the machine accepts if any
computational path leads to acceptance.

## 2.5 The Subset Construction

One of the earliest and most elegant theorems in automata theory is that DFAs and NFAs
recognize exactly the same class of languages. The proof is constructive: given an NFA with
states `Q`, we build a DFA whose states are *subsets* of `Q` (hence the name "subset
construction" or "powerset construction").

**Theorem (Rabin–Scott, 1959)**. For every NFA `N`, there exists a DFA `D` such that
`L(D) = L(N)`.

The key insight is that the DFA simulates the NFA by tracking *all possible states* the
NFA could be in simultaneously. If the NFA has `n` states, the DFA has at most `2ⁿ`
states. This exponential blowup is sometimes unavoidable — there exist families of
languages where the minimal DFA is exponentially larger than the minimal NFA.

## 2.6 Regular Expressions

Regular expressions provide an alternative, algebraic characterization of regular
languages. A regular expression over alphabet `Σ` is built from:

- `∅` (the empty language)
- `ε` (the language containing only the empty string)
- `a` for each `a ∈ Σ` (the language containing only the single-character string `a`)
- `r₁ ∪ r₂` (union)
- `r₁ · r₂` (concatenation)
- `r*` (Kleene star — zero or more repetitions)

In Lean, we define this as an inductive type:

```lean
inductive RegExp (Σ : Type) where
  | empty : RegExp Σ
  | epsilon : RegExp Σ
  | char : Σ → RegExp Σ
  | union : RegExp Σ → RegExp Σ → RegExp Σ
  | concat : RegExp Σ → RegExp Σ → RegExp Σ
  | star : RegExp Σ → RegExp Σ
```

**Kleene's Theorem (1956)**. A language is regular if and only if it is described by a
regular expression.

## 2.7 The Pumping Lemma

Not all languages are regular. The *pumping lemma* gives a necessary condition for
regularity that can be used to show specific languages are non-regular.

**Pumping Lemma for Regular Languages**. If `L` is a regular language, then there exists a
constant `p ≥ 1` (the "pumping length") such that every string `w ∈ L` with `|w| ≥ p` can
be divided into three parts `w = xyz` satisfying:

1. `|y| ≥ 1` (the pumped portion is non-empty)
2. `|xy| ≤ p` (the pumped portion occurs within the first `p` characters)
3. For all `i ≥ 0`, `xy^iz ∈ L` (pumping `y` preserves membership)

**Example**. The language `L = {aⁿbⁿ : n ≥ 0}` is not regular. If it were, we could pump
the string `aᵖbᵖ`. Any decomposition with `|xy| ≤ p` gives `y = aᵏ` for some `k ≥ 1`.
Pumping gives `aᵖ⁺ᵏbᵖ ∈ L`, which is false since `p + k ≠ p`.

## 2.8 Closure Properties

Regular languages are closed under a remarkable number of operations:

| Operation       | Closed? | Proof Method          |
|-----------------|---------|----------------------|
| Union           | Yes     | NFA construction     |
| Intersection    | Yes     | Product construction |
| Complement      | Yes     | Swap accept/reject   |
| Concatenation   | Yes     | NFA construction     |
| Kleene star     | Yes     | NFA construction     |
| Reversal        | Yes     | Reverse the NFA      |
| Homomorphism    | Yes     | Replace transitions  |

These closure properties make regular languages a Boolean algebra — a fact that has deep
connections to the algebraic theory of finite monoids (the Myhill–Nerode theorem and
Eilenberg's variety theorem).

## 2.9 The Myhill–Nerode Theorem

The Myhill–Nerode theorem provides a beautiful characterization of regular languages in
terms of equivalence relations. Define the relation `≡_L` on strings by:

> `x ≡_L y` if and only if for all strings `z`, `xz ∈ L ↔ yz ∈ L`.

**Theorem (Myhill–Nerode)**. A language `L` is regular if and only if `≡_L` has finitely
many equivalence classes. Moreover, the number of equivalence classes equals the number of
states in the minimal DFA for `L`.

This theorem is remarkable because it characterizes regularity without mentioning automata
at all — it is a purely language-theoretic condition.

## 2.10 Looking Ahead

Finite automata are the simplest model in our hierarchy. They cannot count (as the pumping
lemma shows), they cannot match nested parentheses, and they cannot recognize palindromes.
In the next chapter, we will add a stack to our machines, obtaining *pushdown automata*,
which can handle these tasks and more.

---

*"A finite automaton is a device with a finite number of internal states. It reads input
symbols one by one and changes state accordingly."* — Michael Sipser, *Introduction to the
Theory of Computation*
