# Chapter 5: Turing Machines

## 5.1 The Machine That Changed Everything

In 1936, a 23-year-old Alan Turing, working toward his PhD at King's College, Cambridge,
published "On Computable Numbers, with an Application to the Entscheidungsproblem." In this
paper, Turing introduced a mathematical model of computation so intuitive, so convincing,
and so powerful that it became the standard by which all other models are measured.

Turing's insight was to imagine a human computer — a person performing a calculation with
pencil and paper — and to ask: what are the essential operations this person performs? He
identified four:

1. Reading a symbol from the paper
2. Writing a symbol on the paper
3. Moving attention to an adjacent position
4. Changing the "state of mind" that determines the next action

A Turing machine mechanizes exactly these operations. It consists of an infinite tape
divided into cells, a head that reads and writes symbols on the tape, and a finite-state
control that determines the machine's behavior.

## 5.2 Formal Definition

A Turing machine is a 7-tuple `(Q, Σ, Γ, δ, q₀, q_accept, q_reject)` where:

- `Q` is a finite set of states
- `Σ` is the input alphabet (not containing the blank symbol)
- `Γ` is the tape alphabet, with `Σ ⊂ Γ` and `blank ∈ Γ \ Σ`
- `δ : Q × Γ → Q × Γ × {L, R}` is the transition function
- `q₀ ∈ Q` is the start state
- `q_accept ∈ Q` is the accept state
- `q_reject ∈ Q` is the reject state, with `q_accept ≠ q_reject`

In Lean, we might represent this as:

```lean
inductive Direction where
  | left : Direction
  | right : Direction

structure TuringMachine (Q Γ : Type) where
  blank : Γ
  start : Q
  accept : Q
  reject : Q
  transition : Q → Γ → Q × Γ × Direction
```

## 5.3 Configurations and Computation

A **configuration** of a Turing machine captures its complete state at a moment in time:
the current state, the tape contents, and the position of the head.

```lean
structure Configuration (Q Γ : Type) where
  state : Q
  tape : Int → Γ     -- The tape, indexed by integers
  head : Int          -- Current head position
```

The machine starts with the input written on the tape (one symbol per cell), the head on
the leftmost input symbol, and all other cells blank. At each step, it reads the symbol
under the head, consults the transition function, writes a new symbol, moves the head left
or right, and enters a new state. The machine halts if it enters `q_accept` or `q_reject`.

A Turing machine **accepts** an input if, starting from the initial configuration, it
eventually enters `q_accept`. It **rejects** if it enters `q_reject`. It may also **loop**
— running forever without halting.

## 5.4 Recognizers and Deciders

This three-way behavior (accept, reject, loop) leads to two important distinctions:

- A language `L` is **Turing-recognizable** (or **recursively enumerable**) if there
  exists a TM that accepts exactly the strings in `L`. The machine may loop on strings not
  in `L`.

- A language `L` is **decidable** (or **recursive**) if there exists a TM that accepts
  strings in `L` and rejects strings not in `L` — it always halts.

Every decidable language is recognizable, but not vice versa. The distinction between
recognition and decision is one of the central themes of computability theory.

## 5.5 Multitape Turing Machines

A **multitape Turing machine** has `k` tapes, each with its own head. At each step, the
machine reads the symbols under all `k` heads, and based on the current state and these
symbols, writes new symbols on all tapes, moves each head independently, and transitions
to a new state.

**Theorem**. Every multitape TM can be simulated by a single-tape TM.

The simulation incurs a polynomial slowdown: if the multitape machine runs in time `T(n)`,
the single-tape machine runs in time `O(T(n)²)`. This shows that multiple tapes add
convenience but not computational power.

## 5.6 Nondeterministic Turing Machines

A **nondeterministic Turing machine** (NTM) has a transition function that maps each
state-symbol pair to a *set* of possible actions. The machine accepts if *any* computational
path leads to acceptance.

**Theorem**. Every NTM can be simulated by a deterministic TM.

The simulation explores the tree of nondeterministic choices using breadth-first search.
If the NTM runs in time `T(n)`, the deterministic simulation runs in time `2^{O(T(n))}` —
an exponential blowup that may or may not be avoidable (this is the P vs NP question).

## 5.7 The Universal Turing Machine

Turing's most revolutionary insight was the **universal Turing machine** — a single machine
that can simulate any other Turing machine. The universal machine `U` takes as input:

1. A description (encoding) `⟨M⟩` of a Turing machine `M`
2. An input `w` for `M`

And simulates `M` running on `w`. If `M` accepts `w`, then `U` accepts `⟨M, w⟩`. If `M`
rejects, `U` rejects. If `M` loops, `U` loops.

The universal Turing machine is the theoretical ancestor of the stored-program computer.
The idea that a single machine can execute any program — that software is just data — is so
familiar today that it's hard to appreciate how radical it was in 1936. Before Turing,
machines were designed for specific tasks. After Turing, we understood that a single
machine, given the right instructions, could do *anything* that any machine could do.

## 5.8 Encoding Turing Machines

To feed a Turing machine as input to the universal machine, we need an **encoding** — a way
to represent the machine's description as a string. Any reasonable encoding will do; the
details don't matter for the theory.

One standard encoding represents a TM `M = (Q, Σ, Γ, δ, q₀, q_accept, q_reject)` as a
binary string:

1. Encode each state, symbol, and direction as a binary string
2. List all transitions `(q, a) → (q', b, D)` separated by delimiters
3. Mark the start, accept, and reject states

The key property is that the encoding is **effective**: given `M`, we can compute `⟨M⟩`,
and given `⟨M⟩`, we can recover `M`.

## 5.9 Turing Machines as Enumerators

A Turing machine can also be used to *enumerate* a language. An **enumerator** for a
language `L` is a TM with an output tape that prints the strings of `L`, one after
another (in any order, possibly with repetitions).

**Theorem**. A language `L` is Turing-recognizable if and only if some enumerator
enumerates `L`.

This theorem explains the classical name "recursively enumerable" for Turing-recognizable
languages — they are exactly the languages that can be listed by an effective procedure.

## 5.10 The Tape as Memory

It is instructive to compare the memory models of our three machine types:

| Machine              | Memory    | Power              |
|----------------------|-----------|--------------------|
| Finite automaton     | None      | Regular languages  |
| Pushdown automaton   | Stack     | Context-free languages |
| Turing machine       | Tape      | All recognizable languages |

The tape is a random-access, unbounded memory — the machine can read and write anywhere,
move in both directions, and use as much tape as it needs. This is the key feature that
gives Turing machines their universal computational power.

But the tape is also the source of all undecidability. Because the machine can use
unbounded memory, its behavior cannot be predicted by any finite analysis. In the next
chapter, we will see why this makes the halting problem undecidable.

---

*"We may compare a man in the process of computing a real number to a machine which is
only capable of a finite number of conditions... The machine is supplied with a 'tape'...
divided into sections (called 'squares') each capable of bearing a 'symbol'."*
— Alan Turing, "On Computable Numbers," 1936
