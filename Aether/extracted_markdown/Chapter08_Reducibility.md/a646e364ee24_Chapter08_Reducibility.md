# Chapter 8: Reducibility

## 8.1 The Art of Comparison

How do we show that a problem is undecidable? We could try to repeat the diagonal argument
from the halting problem proof each time, but that would be tedious and miss the deeper
structure. Instead, we use **reducibility** — a technique for transferring undecidability
from one problem to another.

The idea is simple and powerful: if we can transform instances of problem A into instances
of problem B (in a way that preserves yes/no answers), then B is at least as hard as A. If
A is undecidable, then B must be undecidable too.

## 8.2 Many-One Reducibility

**Definition**. A language `A` is **many-one reducible** to a language `B`, written
`A ≤ₘ B`, if there exists a computable function `f : Σ* → Σ*` such that for all `w`:

> `w ∈ A ↔ f(w) ∈ B`

The function `f` is called a **reduction** from `A` to `B`. It transforms instances of the
`A`-problem into instances of the `B`-problem, preserving membership.

In Lean:

```lean
def ManyOneReducible (A B : Set (List Σ)) : Prop :=
  ∃ f : List Σ → List Σ, Computable f ∧ ∀ w, w ∈ A ↔ f w ∈ B
```

**Key Properties**:
- If `A ≤ₘ B` and `B` is decidable, then `A` is decidable.
- Equivalently: if `A ≤ₘ B` and `A` is undecidable, then `B` is undecidable.
- `≤ₘ` is transitive: if `A ≤ₘ B` and `B ≤ₘ C`, then `A ≤ₘ C`.

## 8.3 Using Reductions

**Example: The Acceptance Problem**. Show that `A_TM = {⟨M, w⟩ : M accepts w}` is
undecidable.

*Proof*. Reduce `HALT` to `A_TM`. Given `⟨M, w⟩`, construct `M'` that on input `x`:
1. Simulates `M` on `w`
2. If `M` halts and accepts, accept
3. If `M` halts and rejects, enter an infinite loop

Then `M` halts on `w` iff `M'` accepts some fixed string. Wait — this doesn't quite work
because we also need to handle the case where `M` loops. Let's be more careful.

Actually, the simplest reduction is: `HALT ≤ₘ A_TM` via the function that maps `⟨M, w⟩`
to `⟨M', w⟩` where `M'` simulates `M` but always accepts when `M` halts. Then `M` halts
on `w` iff `M'` accepts `w`.

Since `HALT` is undecidable, `A_TM` is undecidable. ∎

**Example: The Emptiness Problem**. Show that `E_TM = {⟨M⟩ : L(M) = ∅}` is undecidable.

*Proof*. Reduce `A_TM` to `E̅_TM` (the complement of `E_TM`). Given `⟨M, w⟩`, construct
`M'` that ignores its input and simulates `M` on `w`. Then:

- If `M` accepts `w`, then `M'` accepts everything, so `L(M') ≠ ∅`, i.e., `⟨M'⟩ ∉ E_TM`.
- If `M` does not accept `w`, then `M'` accepts nothing, so `L(M') = ∅`, i.e., `⟨M'⟩ ∈ E_TM`.

This shows `A_TM ≤ₘ E̅_TM`, so `E̅_TM` is undecidable, and therefore `E_TM` is undecidable. ∎

## 8.4 Turing Reducibility

Many-one reducibility is clean but sometimes too restrictive. **Turing reducibility** is
more general: `A` is Turing-reducible to `B`, written `A ≤_T B`, if there exists an oracle
Turing machine that decides `A` using `B` as an oracle.

An **oracle TM** for `B` is a TM augmented with a special "query tape" and states: it can
write a string `q` on the query tape, enter a special "query" state, and in one step
receive the answer to "is `q ∈ B`?"

Turing reducibility is more flexible than many-one reducibility:
- `A ≤ₘ B` implies `A ≤_T B`, but not vice versa.
- `A ≤_T Ā` always holds (just negate the oracle's answer), but `A ≤ₘ Ā` may fail.

## 8.5 The Reduction Landscape

Reductions create a rich structure on the set of all languages:

```
Decidable languages
    ↕ (≤ₘ equivalent)
    ∅, Σ*, and all decidable languages
    
HALT, A_TM, etc.
    ↕ (≤ₘ equivalent)
    The "standard" r.e.-complete problems

co-HALT, co-A_TM, etc.
    ↕
    The "standard" co-r.e.-complete problems
    
Even harder problems...
    ↕
    The arithmetic hierarchy (Chapter 10)
```

## 8.6 Complete Problems

A language `B` is **r.e.-complete** (or **Σ₁-complete**) if:
1. `B` is recognizable (r.e.)
2. Every recognizable language `A` satisfies `A ≤ₘ B`

`HALT` and `A_TM` are both r.e.-complete. They are the "hardest" recognizable languages —
if you could decide either one, you could decide all recognizable languages.

This notion of completeness is the ancestor of NP-completeness (Chapter 11), which plays
the same role for polynomial-time computation.

## 8.7 Mapping Reductions in Practice

The art of undecidability proofs is the art of constructing reductions. Here is the general
pattern:

1. **Choose the source problem**: Usually `HALT` or `A_TM` (something known to be
   undecidable).
2. **Define the reduction function**: Given an instance `⟨M, w⟩` of the source, construct
   an instance of the target.
3. **Prove correctness**: Show that the answer to the source instance equals the answer to
   the target instance.

The key creative step is (2): designing the right construction. The constructed machine
typically "embeds" the source computation inside the target problem.

## 8.8 Undecidability of Properties of Languages

Notice a pattern in our undecidability results: `E_TM` (emptiness), `EQ_TM` (equivalence),
`REGULAR_TM` (regularity) — all ask about the *language* recognized by a TM, not about the
TM's behavior on a specific input.

Is there a general principle at work? Yes — it's called **Rice's theorem**, and it says
that *every* nontrivial property of Turing-recognizable languages is undecidable. We will
state and prove it in the next chapter.

## 8.9 Computable Functions and m-Degrees

Many-one reducibility induces an equivalence relation: `A ≡ₘ B` iff `A ≤ₘ B` and
`B ≤ₘ A`. The equivalence classes are called **m-degrees**. The m-degrees form a partially
ordered set with rich structure:

- There is a least degree: the decidable languages (excluding `∅` and `Σ*`).
- There is no greatest degree.
- The structure of m-degrees is extremely complex — there are incomparable degrees,
  infinite chains, and antichains.

The study of degree structures is a central topic in computability theory, particularly the
**Turing degrees** (equivalence classes under Turing reducibility), which have been
intensively studied since the 1950s.

## 8.10 Why Reducibility Matters

Reducibility is not just a proof technique — it is a way of understanding the *structure*
of unsolvability. Different problems can be unsolvable for different reasons and to
different degrees. Reducibility gives us a precise way to compare these degrees and to
organize the landscape of undecidable problems.

In complexity theory (Part III), reducibility takes on a new life: polynomial-time
reductions replace computable reductions, and NP-completeness replaces r.e.-completeness.
The conceptual framework is the same, but the focus shifts from *what* can be computed to
*how efficiently* it can be computed.

---

*"The method of diagonalization can be described as finding, for any given
enumeration of certain objects, an object which is not in the enumeration."*
— Georg Cantor (adapted)
