# Appendix A: Notation and Lean 4 Conventions

## A.1 Mathematical Notation

| Symbol      | Meaning                                    |
|-------------|-------------------------------------------|
| `Σ`         | Alphabet (finite set of symbols)           |
| `Σ*`        | Set of all finite strings over `Σ`         |
| `ε`         | Empty string                               |
| `|w|`       | Length of string `w`                       |
| `L(M)`      | Language recognized by machine `M`         |
| `⟨M⟩`       | Encoding of machine `M` as a string        |
| `⟨M, w⟩`    | Encoding of a pair (machine, input)        |
| `≤ₘ`        | Many-one reducibility                      |
| `≤_T`       | Turing reducibility                        |
| `≤_P`       | Polynomial-time reducibility               |
| `∅'`        | Turing jump of the empty set               |
| `φₑ`        | The e-th partial computable function       |
| `Wₑ`        | Domain of `φₑ` (the e-th r.e. set)         |
| `Σₙ, Πₙ`   | Levels of the arithmetic hierarchy         |

## A.2 Lean 4 Conventions

Throughout this book, we use the following Lean 4 conventions:

### Type Universes
- `Prop` for propositions (proof-irrelevant)
- `Type` for data types
- `Type*` as a shorthand for `Type u` with implicit universe

### Common Types
```lean
-- Natural numbers (built-in)
-- Nat or ℕ

-- Lists as finite strings
-- List α represents Σ*

-- Sets
-- Set α = α → Prop

-- Functions
-- α → β
```

### Decidability
```lean
-- Decidable propositions
instance : Decidable (n = m) := ...

-- Decidable predicates
def DecidablePred (p : α → Prop) := ∀ a, Decidable (p a)
```

### Inductive Types
```lean
-- We define automata and grammars as structures or inductive types
structure DFA (Q Σ : Type) where ...
inductive RegExp (Σ : Type) where ...
```

### Proofs
```lean
-- Tactic mode
theorem foo : P := by
  intro h
  exact h

-- Term mode
theorem bar : P → P := fun h => h
```

## A.3 Imports

The formalizations in this book use the following Mathlib imports:

```lean
import Mathlib.Data.List.Basic
import Mathlib.Data.Fintype.Basic
import Mathlib.Data.Set.Basic
import Mathlib.Logic.Basic
import Mathlib.Tactic
```

## A.4 Naming Conventions

We follow Lean 4 and Mathlib naming conventions:
- Types and structures: `UpperCamelCase` (`DFA`, `TuringMachine`)
- Definitions and lemmas: `lowerCamelCase` or `snake_case` (`dfa_accepts`, `halting_undecidable`)
- Namespaces: Match the structure name (`DFA.run`, `NFA.accepts`)
