# Chapter 10: The Arithmetic Hierarchy

## 10.1 Degrees of Unsolvability

We have seen that some problems are decidable and some are not. But among the undecidable
problems, are some "more undecidable" than others? The arithmetic hierarchy provides a
precise answer: it stratifies undecidable problems into an infinite hierarchy of increasing
difficulty.

## 10.2 Σₙ and Πₙ Sets

The hierarchy is built from alternating quantifiers over decidable predicates.

**Definition**. A set `A ⊆ ℕ` is:

- **Σ₀ = Π₀ = Δ₀**: Decidable (computable, recursive)
- **Σ₁**: Recognizable (r.e.). Equivalently, `A = {x : ∃y. R(x, y)}` for some decidable
  relation `R`.
- **Π₁**: Co-recognizable (co-r.e.). Equivalently, `A = {x : ∀y. R(x, y)}` for some
  decidable `R`.
- **Σ₂**: `A = {x : ∃y. ∀z. R(x, y, z)}` for some decidable `R`.
- **Π₂**: `A = {x : ∀y. ∃z. R(x, y, z)}` for some decidable `R`.
- In general, **Σₙ** uses `∃∀∃∀...` (n alternating quantifiers, starting with ∃) over a
  decidable predicate, and **Πₙ** uses `∀∃∀∃...` (starting with ∀).

**Δₙ = Σₙ ∩ Πₙ**: Sets that are both Σₙ and Πₙ.

## 10.3 Examples

| Set / Problem                              | Level |
|-------------------------------------------|-------|
| Decidable languages                        | Σ₀ = Π₀ |
| HALT = {⟨M, w⟩ : M halts on w}            | Σ₁    |
| co-HALT = {⟨M, w⟩ : M doesn't halt on w}  | Π₁    |
| TOT = {⟨M⟩ : M halts on every input}      | Π₂    |
| FIN = {⟨M⟩ : L(M) is finite}              | Σ₂    |
| COF = {⟨M⟩ : L(M) is cofinite}            | Σ₃    |

**Why is TOT Π₂?** `M` halts on every input iff `∀w. ∃t. M halts on w within t steps`.
This is `∀∃` with a decidable inner predicate (simulate M for t steps).

**Why is FIN Σ₂?** `L(M)` is finite iff `∃n. ∀w. (|w| > n → M does not accept w)` iff
`∃n. ∀w. ∀t. (|w| > n → M does not accept w within t steps)`. After collapsing adjacent
universal quantifiers, this is Σ₂.

## 10.4 The Hierarchy Is Strict

**Post's Theorem**. For all `n ≥ 0`:
- Σₙ ⊊ Σₙ₊₁ (strict containment)
- Πₙ ⊊ Πₙ₊₁ (strict containment)
- Σₙ and Πₙ are incomparable when n ≥ 1 (neither contains the other)

The hierarchy looks like:

```
              Σ₃   Π₃
             / \ / \
           Δ₃   X   ...
           |   / \
          Σ₂   Π₂
         / \ / \
       Δ₂   X
       |   / \
      Σ₁   Π₁
     / \ / \
   Δ₁   X
   |
  Σ₀ = Π₀ = Δ₀ = Decidable
```

Each level is strictly more powerful than the one below. A Σ₁-complete problem (like HALT)
cannot be solved at level Σ₀ (decidable), but can be solved with one "jump" of
unsolvability.

## 10.5 The Turing Jump

The **Turing jump** provides the engine that drives the hierarchy.

**Definition**. The **Turing jump** of a set `A`, written `A'`, is the halting problem
relativized to `A`:

> `A' = {e : φₑᴬ(e) halts}`

where `φₑᴬ` is the `e`-th partial function computable with oracle `A`.

**Key Properties**:
- `A <_T A'` (strictly harder — `A'` is not Turing-reducible to `A`)
- `∅' ≡_T HALT` (the jump of the empty set is the halting problem)
- `∅'' ≡_T TOT` (the double jump relates to totality)
- `∅⁽ⁿ⁾` is Σₙ-complete

The jump operation provides a canonical way to climb the hierarchy, one level at a time.

## 10.6 Oracle Machines

An **oracle Turing machine** is a TM augmented with access to an oracle for some set `A`.
The machine can, in one step, query whether any string is in `A`.

- `Σₙ₊₁` = the r.e. sets relative to a Σₙ oracle
- `Πₙ₊₁` = the co-r.e. sets relative to a Σₙ oracle

This relativization provides the recursive structure of the hierarchy: each level is
obtained from the previous one by adding a single layer of oracle computation.

## 10.7 Arithmetical Definability

The name "arithmetic hierarchy" comes from a parallel classification of *definable* sets
of natural numbers:

- **Σ₁ formulas**: `∃x₁. φ(x₁, ...)` where `φ` is bounded (Δ₀)
- **Π₁ formulas**: `∀x₁. φ(x₁, ...)` where `φ` is bounded
- **Σₙ formulas**: `∃x₁. ∀x₂. ∃x₃. ... φ(...)` (n blocks of alternating quantifiers)

**Post's Theorem (Definability Version)**. A set is Σₙ in the computability-theoretic
sense if and only if it is definable by a Σₙ formula of first-order arithmetic.

This beautiful correspondence connects computability theory to mathematical logic: the
complexity of a set (as measured by the oracle machinery needed to decide it) corresponds
exactly to the logical complexity of its definition (as measured by quantifier alternation).

## 10.8 The Analytical Hierarchy

Above the arithmetic hierarchy lies the **analytical hierarchy**, which allows
quantification over *functions* (or equivalently, over *sets of natural numbers*), not just
over numbers:

- **Σ¹₁**: `∃f. R(x, f)` where `R` is arithmetical
- **Π¹₁**: `∀f. R(x, f)` where `R` is arithmetical
- And so on...

The analytical hierarchy is vastly more expressive than the arithmetic hierarchy. Σ¹₁ sets
include sets that are not at any finite level of the arithmetic hierarchy.

**Example**: `{⟨T⟩ : T is a computable tree with an infinite path}` is Π¹₁-complete
(Kleene). The statement "every computable tree with no infinite path is well-founded" is
the essence of König's lemma, and its computational content lies at the Π¹₁ level.

## 10.9 Connections to Proof Theory

The arithmetic hierarchy connects to proof theory through the following observation:
a sentence `∀x. ∃y. R(x, y)` (a Π₂ sentence) is provable in Peano Arithmetic if and
only if the witnessing function `f` (with `R(x, f(x))` for all `x`) is provably total
in PA. This connects the *complexity of a statement* (its position in the hierarchy) to
the *strength of the proof system* needed to prove it.

## 10.10 The Big Picture

The arithmetic hierarchy reveals that undecidability is not a single phenomenon but a
spectrum. Just as the real numbers contain irrationals of different "qualities" (algebraic
vs. transcendental, normal vs. non-normal), the undecidable problems contain problems of
different "hardnesses."

```
Decidable → Σ₁ (r.e.) → Σ₂ → Σ₃ → ··· → Arithmetical → Σ¹₁ → ··· → Analytical → ···
```

Each level introduces genuinely new problems that cannot be solved at any lower level. The
hierarchy continues transfinitely (through the hyperarithmetical hierarchy and beyond),
providing an endlessly refined picture of the degrees of unsolvability.

---

*"The classification of sets by their logical complexity is one of the grand
themes of mathematical logic."*
— Yiannis Moschovakis, *Descriptive Set Theory*
