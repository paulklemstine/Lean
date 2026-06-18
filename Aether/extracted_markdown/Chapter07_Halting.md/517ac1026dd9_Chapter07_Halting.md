# Chapter 7: Decidability and the Halting Problem

## 7.1 The Limits of Computation

We have spent the first six chapters building up the power of computation — from finite
automata to Turing machines, from regular languages to the full class of computable
functions. Now we confront the other side: the *limits* of computation.

The discovery that some problems are fundamentally unsolvable — that no algorithm, no
matter how clever, can solve them — is one of the most profound insights in all of
mathematics. It means that there are truths that can be stated but never algorithmically
verified, questions that can be asked but never algorithmically answered.

The archetype of all unsolvable problems is the **halting problem**: given a program and
an input, does the program eventually halt?

## 7.2 Decidable and Recognizable Languages

Recall our definitions:

**Definition**. A language `L` is **decidable** (recursive) if there exists a Turing
machine `M` that:
- Accepts every `w ∈ L`
- Rejects every `w ∉ L`
- Halts on every input

**Definition**. A language `L` is **recognizable** (recursively enumerable, r.e.) if there
exists a Turing machine `M` that:
- Accepts every `w ∈ L`
- For `w ∉ L`, either rejects or loops forever

Every decidable language is recognizable, but the converse fails spectacularly.

## 7.3 Examples of Decidable Languages

Many natural languages are decidable:

1. `{⟨G, w⟩ : G is a CFG and w ∈ L(G)}` — Membership in a context-free language (CYK
   algorithm)
2. `{⟨D⟩ : D is a DFA and L(D) = ∅}` — Emptiness of a DFA language
3. `{⟨D₁, D₂⟩ : D₁, D₂ are DFAs and L(D₁) = L(D₂)}` — Equivalence of DFAs
4. `{⟨p⟩ : p is a prime number}` — Primality testing (AKS algorithm)

## 7.4 The Halting Problem

**Definition**. The **halting problem** is the language:

> `HALT = {⟨M, w⟩ : M is a TM and M halts on input w}`

**Theorem (Turing, 1936)**. `HALT` is undecidable.

*Proof*. Suppose for contradiction that there exists a TM `H` that decides `HALT`. That
is, on input `⟨M, w⟩`:

- `H` accepts if `M` halts on `w`
- `H` rejects if `M` does not halt on `w`

Construct a new TM `D` that, on input `⟨M⟩`:

1. Runs `H` on `⟨M, ⟨M⟩⟩`
2. If `H` accepts (i.e., `M` halts on `⟨M⟩`), then `D` loops forever
3. If `H` rejects (i.e., `M` does not halt on `⟨M⟩`), then `D` halts and accepts

Now ask: what does `D` do on input `⟨D⟩`?

- If `D` halts on `⟨D⟩`, then `H` accepts `⟨D, ⟨D⟩⟩`, so `D` loops. Contradiction.
- If `D` does not halt on `⟨D⟩`, then `H` rejects `⟨D, ⟨D⟩⟩`, so `D` halts. Contradiction.

Both cases lead to contradiction, so `H` cannot exist. ∎

## 7.5 Formalizing the Diagonal Argument

The proof above is a **diagonal argument**, directly analogous to Cantor's proof that the
reals are uncountable. Let us make the structure explicit.

Consider the infinite matrix `A` where:

> `A[i][j] = 1` if machine `Mᵢ` halts on input `⟨Mⱼ⟩`, and `0` otherwise.

The diagonal entries are `A[i][i]` — does machine `Mᵢ` halt on its own description?

The machine `D` is constructed to *disagree with every diagonal entry*:

> `D` on input `⟨Mᵢ⟩` does the opposite of `Mᵢ` on `⟨Mᵢ⟩`.

If `D = Mₖ` for some `k`, then `A[k][k]` must simultaneously be 0 and 1 — contradiction.

In Lean, we can formalize the core of this argument:

```lean
theorem cantor_diagonal {α : Type} : ¬ ∃ f : α → (α → Bool), Function.Surjective f := by
  intro ⟨f, hf⟩
  have g : α → Bool := fun a => !(f a a)
  obtain ⟨a, ha⟩ := hf g
  have : g a = f a a := congr_fun ha a
  simp [g] at this
```

This is the combinatorial core. The halting problem proof adds the layer of encoding
Turing machines as strings.

## 7.6 HALT Is Recognizable

Although `HALT` is not decidable, it *is* recognizable. The recognizer is trivial: given
`⟨M, w⟩`, simply simulate `M` on `w`. If `M` halts, accept. If `M` doesn't halt, loop
forever.

This shows that recognizability is strictly weaker than decidability.

## 7.7 The Complement of HALT

What about the complement of `HALT`?

> `co-HALT = {⟨M, w⟩ : M does not halt on input w}`

**Theorem**. `co-HALT` is not recognizable.

*Proof*. If `co-HALT` were recognizable, then `HALT` would be decidable (by running the
recognizers for `HALT` and `co-HALT` in parallel — one must accept). But `HALT` is
undecidable, so `co-HALT` is not recognizable. ∎

**Theorem**. A language `L` is decidable if and only if both `L` and `L̄` are recognizable.

This theorem precisely characterizes decidability in terms of recognizability.

## 7.8 More Undecidable Problems

The halting problem is just the beginning. Many other natural problems are undecidable:

1. **The acceptance problem**: `{⟨M, w⟩ : M accepts w}` — undecidable.
2. **The emptiness problem**: `{⟨M⟩ : L(M) = ∅}` — undecidable.
3. **The equivalence problem**: `{⟨M₁, M₂⟩ : L(M₁) = L(M₂)}` — undecidable.
4. **The regularity problem**: `{⟨M⟩ : L(M) is regular}` — undecidable.
5. **Hilbert's tenth problem**: Given a polynomial equation with integer coefficients, does
   it have an integer solution? — Undecidable (Matiyasevich, 1970).
6. **The Post correspondence problem**: Given two lists of strings, can elements be
   selected to form equal concatenations? — Undecidable.
7. **The word problem for groups**: Given a finitely presented group and a word, does the
   word represent the identity? — Undecidable in general (Novikov, 1955; Boone, 1959).

We will develop the tools to prove these undecidability results — primarily through
*reducibility* — in the next chapter.

## 7.9 The Philosophical Impact

The undecidability of the halting problem has deep philosophical implications:

**For mathematics**: There is no general algorithm to determine mathematical truth.
Combined with Gödel's incompleteness theorems, this shows that mathematics is inherently
open-ended — no finite set of axioms and rules can capture all mathematical truth.

**For software engineering**: There is no general algorithm to determine whether a program
has a bug, whether it will terminate, or whether two programs do the same thing. This
doesn't mean we can't analyze *specific* programs — it means there's no *universal*
analyzer.

**For artificial intelligence**: If intelligence involves creativity and insight that goes
beyond mechanical procedure, then perhaps the halting problem tells us something about the
limits of AI. (This is the thrust of the Lucas–Penrose argument, though it is
controversial.)

## 7.10 Self-Reference and Fixed Points

At the heart of the halting problem proof is *self-reference*: we ask what machine `D` does
when given its own description. This pattern appears throughout logic and computation:

- **Gödel's incompleteness theorem**: A sentence that says "I am not provable."
- **The liar's paradox**: "This sentence is false."
- **Quines**: Programs that print their own source code.
- **Kleene's recursion theorem**: Every computable operator has a fixed point.

**Kleene's Recursion Theorem**. For every computable function `f`, there exists a TM `M`
such that `M` computes the same function as `f(⟨M⟩)`. In other words, every computable
transformation of programs has a "fixed point" — a program that is unchanged by the
transformation.

This theorem is surprisingly powerful. It implies, for instance, that there exist
self-reproducing programs (the existence of quines), and it provides an alternative proof
of the undecidability of the halting problem.

---

*"We can never know in advance which problems are solvable and which are not; it is
precisely this uncertainty that makes mathematics interesting."*
— Adapted from Turing's legacy
