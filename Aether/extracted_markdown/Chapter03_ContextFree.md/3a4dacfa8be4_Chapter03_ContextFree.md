# Chapter 3: Context-Free Languages

## 3.1 Beyond Regularity

Regular languages, for all their elegance, cannot express even the simplest forms of
nesting. The language of matched parentheses — `{()`, `(())`, `((()))`, ...} — is beyond
the reach of any finite automaton. This is because matching requires *counting*, and
counting requires memory that grows with the input.

Context-free languages (CFLs) remedy this by adding a single, powerful resource: a *stack*.
A machine with a finite control and an unbounded stack — a *pushdown automaton* (PDA) — can
recognize matched parentheses, balanced brackets, and many other structured languages that
appear throughout computer science.

But context-free languages are most naturally described not by machines but by *grammars* —
recursive rules for generating strings. This duality between generation (grammars) and
recognition (automata) is one of the recurring themes of computation theory.

## 3.2 Context-Free Grammars

A context-free grammar (CFG) is a 4-tuple `(V, Σ, R, S)` where:

- `V` is a finite set of **variables** (or nonterminals)
- `Σ` is a finite set of **terminals** (disjoint from `V`)
- `R` is a finite set of **production rules**, each of the form `A → w` where `A ∈ V` and
  `w ∈ (V ∪ Σ)*`
- `S ∈ V` is the **start variable**

A grammar *derives* a string by starting with `S` and repeatedly replacing variables
according to the production rules. The language of the grammar is the set of all terminal
strings derivable from `S`.

**Example**. The grammar with rules `S → aSb | ε` generates the language `{aⁿbⁿ : n ≥ 0}`.

In Lean, we can represent grammars inductively:

```lean
inductive Symbol (V Σ : Type) where
  | var : V → Symbol V Σ
  | terminal : Σ → Symbol V Σ

structure CFG (V Σ : Type) where
  start : V
  rules : V → List (List (Symbol V Σ))
```

## 3.3 Parse Trees and Ambiguity

A *parse tree* (or derivation tree) for a string `w` in grammar `G` is a tree whose:

- Root is labeled with the start variable `S`
- Internal nodes are labeled with variables, and their children correspond to a production
  rule
- Leaves, read left to right, spell out `w`

A grammar is **ambiguous** if some string has two or more distinct parse trees. Ambiguity
matters enormously in practice — the syntax of programming languages must be unambiguous
(or at least disambiguated by precedence rules) for parsing to be deterministic.

Some languages are *inherently ambiguous*: every grammar that generates them is ambiguous.
The classic example is `{aⁱbʲcᵏ : i = j or j = k}`.

## 3.4 Chomsky Normal Form

Every context-free grammar can be converted to **Chomsky Normal Form** (CNF), where every
rule has one of two forms:

- `A → BC` (two variables)
- `A → a` (a single terminal)

(Plus `S → ε` if the empty string is in the language, with `S` not appearing on the right
side of any rule.)

CNF is useful because it guarantees that every derivation of a string of length `n` has
exactly `2n - 1` steps (for `n ≥ 1`), which enables the CYK parsing algorithm to run in
`O(n³)` time.

## 3.5 Pushdown Automata

A **pushdown automaton** (PDA) is a 6-tuple `(Q, Σ, Γ, δ, q₀, F)` where:

- `Q` is a finite set of states
- `Σ` is the input alphabet
- `Γ` is the stack alphabet
- `δ : Q × (Σ ∪ {ε}) × (Γ ∪ {ε}) → P(Q × (Γ ∪ {ε}))` is the transition function
- `q₀` is the start state
- `F ⊆ Q` is the set of accept states

At each step, a PDA reads an input symbol (or makes an ε-transition), pops a symbol from
the stack (or reads nothing), and pushes a symbol onto the stack (or pushes nothing),
transitioning to a new state.

**Theorem**. A language is context-free if and only if some pushdown automaton recognizes
it.

Unlike the DFA/NFA equivalence, deterministic PDAs (DPDAs) are *strictly weaker* than
nondeterministic PDAs. The language `{wwᴿ : w ∈ {a,b}*}` (palindromes over `{a,b}`) is
context-free but not recognizable by any DPDA.

## 3.6 The Pumping Lemma for CFLs

Just as the pumping lemma for regular languages shows that certain languages are not
regular, there is a pumping lemma for context-free languages.

**Pumping Lemma for CFLs**. If `L` is context-free, then there exists `p ≥ 1` such that
every `w ∈ L` with `|w| ≥ p` can be written as `w = uvxyz` where:

1. `|vy| ≥ 1`
2. `|vxy| ≤ p`
3. For all `i ≥ 0`, `uvⁱxyⁱz ∈ L`

Note that now we pump *two* substrings (`v` and `y`) simultaneously — this reflects the
tree structure of context-free derivations.

**Example**. The language `{aⁿbⁿcⁿ : n ≥ 0}` is not context-free.

## 3.7 Closure Properties

Context-free languages are closed under:

| Operation       | Closed? |
|-----------------|---------|
| Union           | Yes     |
| Concatenation   | Yes     |
| Kleene star     | Yes     |
| Intersection    | **No**  |
| Complement      | **No**  |

The failure of closure under intersection and complement is a fundamental difference from
regular languages, and it makes many questions about CFLs undecidable.

## 3.8 Decidability Results for CFLs

For context-free languages, some questions are decidable and some are not:

| Question                          | Decidable? |
|-----------------------------------|-----------|
| Is `w ∈ L(G)`? (membership)      | Yes (CYK algorithm) |
| Is `L(G) = ∅`?                    | Yes       |
| Is `L(G)` finite?                 | Yes       |
| Is `L(G₁) = L(G₂)`?              | **No**    |
| Is `L(G₁) ⊆ L(G₂)`?              | **No**    |
| Is `G` ambiguous?                 | **No**    |
| Is `L(G₁) ∩ L(G₂) = ∅`?          | **No**    |

These undecidability results reflect the inherent complexity of context-free languages and
will be better understood after we develop the theory of Turing machines.

## 3.9 The Chomsky Hierarchy

We can now place our language classes in a hierarchy:

```
Regular ⊂ Context-Free ⊂ Context-Sensitive ⊂ Recursively Enumerable
```

This is the **Chomsky hierarchy**, named after Noam Chomsky, who introduced it in the
context of natural language linguistics:

| Type | Grammar                | Automaton              | Example                |
|------|------------------------|------------------------|------------------------|
| 3    | Regular (A → aB, A → a)| Finite automaton       | `a*b*`                 |
| 2    | Context-free (A → γ)   | Pushdown automaton     | `{aⁿbⁿ}`              |
| 1    | Context-sensitive      | Linear-bounded automaton| `{aⁿbⁿcⁿ}`            |
| 0    | Unrestricted           | Turing machine         | Any r.e. language      |

Each level strictly contains the previous one. The Chomsky hierarchy is one of the
organizing principles of formal language theory.

## 3.10 Applications

Context-free grammars are ubiquitous in computer science:

- **Programming language syntax**: Almost every programming language has a context-free
  grammar (or a mildly context-sensitive one). Parsers — LL, LR, LALR, Earley — are all
  based on CFG theory.
- **Natural language processing**: Chomsky originally developed CFGs to model the syntax
  of natural languages. While natural languages are not purely context-free, CFGs remain
  a central tool in computational linguistics.
- **XML and HTML**: Document markup languages have a natural tree structure that is
  essentially context-free.
- **RNA secondary structure**: The folding patterns of RNA molecules can be described by
  context-free grammars, leading to important algorithms in computational biology.

---

*"Colorless green ideas sleep furiously."*
— Noam Chomsky, *Syntactic Structures*, 1957
(A grammatically correct but semantically meaningless sentence, illustrating the
distinction between syntax and semantics.)
