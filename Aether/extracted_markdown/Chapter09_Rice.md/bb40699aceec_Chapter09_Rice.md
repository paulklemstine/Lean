# Chapter 9: Rice's Theorem and Its Consequences

## 9.1 A Universal Undecidability Result

In the previous chapter, we proved individually that emptiness, regularity, and equivalence
of Turing machines are all undecidable. Each proof required a separate reduction. Is there
a single theorem that encompasses all of these results?

**Rice's theorem** provides exactly this. It states that *any* nontrivial property of the
language recognized by a Turing machine is undecidable. This is one of the most powerful
and widely applicable results in computability theory.

## 9.2 Properties of Languages

To state Rice's theorem precisely, we need to distinguish between properties of *machines*
and properties of *languages*.

**Definition**. A **property of r.e. languages** is a set `P` of Turing-recognizable
languages. We say that a TM `M` "has property `P`" if `L(M) ∈ P`.

**Definition**. A property `P` is **nontrivial** if:
- There exists some TM `M₁` with `L(M₁) ∈ P` (some machine has the property)
- There exists some TM `M₂` with `L(M₂) ∉ P` (some machine doesn't have it)

Examples of nontrivial properties:
- `L(M) = ∅` (emptiness)
- `L(M)` is finite
- `L(M)` is regular
- `L(M) = Σ*` (totality)
- `L(M)` contains the string "hello"

Examples of trivial properties:
- `L(M) = L(M)` (always true — every machine has this property)
- `L(M) ≠ L(M)` (always false — no machine has this property)

## 9.3 The Theorem

**Rice's Theorem (1953)**. Let `P` be any nontrivial property of Turing-recognizable
languages. Then the language

> `L_P = {⟨M⟩ : L(M) ∈ P}`

is undecidable.

*Proof*. Without loss of generality, assume `∅ ∉ P` (if `∅ ∈ P`, work with the complement
property `P̄`, which is also nontrivial).

Since `P` is nontrivial and `∅ ∉ P`, there exists some TM `M_P` with `L(M_P) ∈ P`.

We reduce `A_TM` to `L_P`. Given `⟨M, w⟩`, construct a TM `M'` that on input `x`:

1. Simulates `M` on `w` (ignoring `x`)
2. If `M` accepts `w`, simulate `M_P` on `x` and accept iff `M_P` accepts

Now:
- If `M` accepts `w`: `M'` behaves exactly like `M_P`, so `L(M') = L(M_P) ∈ P`.
  Thus `⟨M'⟩ ∈ L_P`.
- If `M` does not accept `w`: `M'` never gets past step 1, so `L(M') = ∅ ∉ P`.
  Thus `⟨M'⟩ ∉ L_P`.

Therefore `⟨M, w⟩ ∈ A_TM ↔ ⟨M'⟩ ∈ L_P`, which is a many-one reduction from `A_TM` to
`L_P`. Since `A_TM` is undecidable, `L_P` is undecidable. ∎

## 9.4 What Rice's Theorem Does and Does Not Say

Rice's theorem says:
- ✅ You cannot decide *any* nontrivial property of the language recognized by a TM.
- ✅ This includes: emptiness, finiteness, regularity, context-freeness, equivalence to a
  specific language, containing a specific string, etc.

Rice's theorem does *not* say:
- ❌ That you cannot decide properties of *machines* (as opposed to their languages). For
  example, "does `M` have an even number of states?" is decidable — it's a syntactic
  property of the machine description, not a semantic property of its language.
- ❌ That you cannot decide *any* question about TMs. Only questions about the *language*
  recognized are covered.
- ❌ That you cannot analyze *specific* programs. Rice's theorem is about the
  *impossibility of a general algorithm*. For any specific program, you might be able to
  determine its properties — you just can't build a universal tool that works for all
  programs.

## 9.5 Implications for Software Verification

Rice's theorem has profound implications for software engineering:

1. **No universal bug detector**: There is no program that can examine arbitrary source
   code and correctly determine whether it has a bug (for any nontrivial definition of
   "bug").

2. **No universal optimizer**: There is no program that can determine whether a given
   program computes the same function as a simpler program.

3. **No universal type inference**: For sufficiently expressive type systems, type
   inference is undecidable (though restricted type systems, like Hindley–Milner, have
   decidable inference).

4. **No universal equivalence checker**: Given two programs, you cannot in general
   determine whether they compute the same function.

These impossibility results do not mean we should give up on program analysis! They mean
that any analysis tool must make compromises:

- **Sound but incomplete**: The tool may say "I don't know" on some inputs (e.g., abstract
  interpretation, type systems).
- **Complete but unsound**: The tool may give wrong answers on some inputs (e.g., testing,
  fuzzing).
- **Restricted domain**: The tool works only for a specific class of programs (e.g.,
  termination checkers for structurally recursive functions).

Lean's type system takes the first approach: it is sound (every accepted proof is valid)
but incomplete (some valid proofs cannot be expressed).

## 9.6 Rice's Theorem for Indices

Rice's theorem can be restated in terms of **indices** (Gödel numbers of programs):

**Theorem**. Let `S` be a set of partial computable functions. If `S` is nontrivial (neither
empty nor the set of all partial computable functions), then `{e : φₑ ∈ S}` is undecidable,
where `φₑ` is the partial function computed by the program with index `e`.

This formulation makes the "extensional" nature of Rice's theorem explicit: it's about the
*function computed*, not the *code that computes it*.

## 9.7 Beyond Rice: The Rice–Shapiro Theorem

Rice's theorem tells us what's *undecidable*. The **Rice–Shapiro theorem** tells us what's
*recognizable* (r.e.):

**Rice–Shapiro Theorem**. A set `L_P = {⟨M⟩ : L(M) ∈ P}` is r.e. if and only if `P` is
"recursively enumerable from below," meaning:

> `L ∈ P` iff some finite subset of `L` is in `P`

More precisely, `P` must be closed under extensions and compactly generated.

**Example**: The property "L(M) contains the string '101'" is r.e. (just simulate M on
101). The property "L(M) = {101}" is not r.e. (to verify equality, you'd need to check
infinitely many non-members).

## 9.8 Connections to Gödel's Theorems

Rice's theorem is intimately connected to Gödel's incompleteness theorems:

- **First Incompleteness Theorem**: No consistent, sufficiently powerful formal system can
  prove all true statements of arithmetic. (Analogously: no algorithm can decide all
  properties of languages.)

- **Second Incompleteness Theorem**: No consistent, sufficiently powerful formal system can
  prove its own consistency. (Analogously: no TM can decide whether it itself halts.)

Both sets of results rely on self-reference and diagonalization. They express the same
fundamental limitation: sufficiently powerful systems cannot fully analyze themselves.

## 9.9 Practical Corollaries

Here is a (non-exhaustive) list of specific problems that Rice's theorem immediately shows
to be undecidable:

| Problem                                    | Property P                    |
|-------------------------------------------|-------------------------------|
| Does `M` accept any input?                 | `L(M) ≠ ∅`                   |
| Does `M` accept all inputs?                | `L(M) = Σ*`                  |
| Is `L(M)` finite?                          | `L(M)` is finite             |
| Is `L(M)` regular?                         | `L(M)` is regular            |
| Is `L(M)` context-free?                    | `L(M)` is context-free       |
| Does `M` compute the constant function 0?  | `L(M) = Σ*` (with encoding) |
| Is `L(M) = L(M')`?                         | `L(M) = L(M')` (fixed M')   |

Each of these would require a separate reduction without Rice's theorem. With Rice's
theorem, they are all immediate corollaries.

## 9.10 The Moral

Rice's theorem teaches us a fundamental lesson: **you cannot separate the wheat from the
chaff**. Among all Turing machines, you cannot algorithmically distinguish those whose
languages have a given property from those whose languages don't — unless the property is
trivially true or trivially false.

This is not a failure of our current techniques. It is a mathematical certainty, as
unshakable as the irrationality of √2 or the uncountability of the reals. The limits of
computation are not engineering problems to be solved but mathematical truths to be
understood.

---

*"Any nontrivial property of recursively enumerable sets is not recursive."*
— Henry Gordon Rice, 1953
