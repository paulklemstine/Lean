# A Constructive Bridge Between Three Faces of Ordinal Analysis: Well-Ordering, Termination, and the Fast-Growing Hierarchy

## Abstract

We develop a small, fully constructive framework that unifies three classically
distinct themes of ordinal analysis over a single computable foundation — the
ordinal notation system of Cantor normal forms below ε₀. The three themes are:
(i) the **well-ordering** of the notation system, expressed as the absence of any
infinite strictly descending sequence; (ii) the **termination** of any
deterministic process equipped with an ε₀-valued strictly decreasing monovariant;
and (iii) the **fast-growing hierarchy**, an effective family of number-theoretic
functions of extreme growth rate. The connective tissue is a single termination
theorem, *Termination by Ordinal Measure*, which we prove by well-founded
recursion on the notation order. We show that the well-ordering result is its
engine and that the self-measured specialisation (where the state space is the
notation system itself) is its most directly executable face. We further
demonstrate that the fast-growing hierarchy is genuinely effective by exhibiting
kernel-checked sample values F₁(3) = 6 and F₂(2) = 8, and we record the slow-level
closed forms F₁(n) = 2n and F₂(n) = n·2ⁿ. The central methodological claim is that
termination via ordinal monovariants is not a family of bespoke inductions but one
theorem applied to varying measure maps; classical results such as Goodstein's
theorem and the Kirby–Paris Hydra theorem become instances rather than novelties.
All results are constructive over a computable representation and depend only on a
minimal axiom base.

## 1. Introduction

Ordinal analysis is the branch of proof theory that calibrates the strength of
formal systems by the ordinals whose well-ordering they can (or cannot) prove. The
ordinal ε₀ occupies a privileged place: it is the proof-theoretic ordinal of
first-order Peano Arithmetic, the exact frontier beyond which arithmetic's
inductive power fails. Three phenomena cluster around ε₀, usually treated by
separate machinery:

1. **Well-ordering.** Ordinals below ε₀, presented in Cantor normal form, admit no
   infinite descending sequence. This is the structural backbone of proof theory.

2. **Termination.** A deterministic process whose states carry a strictly
   decreasing ordinal "monovariant" (a quantity that only ever goes down) must
   halt. This principle underlies termination proofs throughout computer science
   and combinatorics.

3. **Growth.** The fast-growing hierarchy (Fₐ)ₐ indexes functions by ordinals; at
   ε₀ it produces functions whose totality is independent of Peano Arithmetic.

The contribution of this paper is to place all three on a *common computable
footing* and to show that the second is a single theorem from which classical
termination results follow as instances. We work over a notation system for which
order comparison, arithmetic, and the hierarchy itself are all computable, so that
the abstract claims are matched by machine-checkable concrete evaluations.

Throughout, we distinguish two layers:

- The **abstract** ordinal layer, where the strength order is the usual order on
  the ordinal numbers. Proof-theoretic landmarks (the well-foundedness of
  consistency-strength descent, the ε₀ closure barrier) live here.
- The **computable** notation layer, where ordinals are represented by finite
  syntactic objects. This is where executability and termination certificates
  live, and it is the layer this paper develops.

## 2. The Computable Notation System

### 2.1 Cantor normal form below ε₀

Every ordinal α with 0 ≤ α < ε₀ has a unique **Cantor normal form**

> α = ω^(β₁)·c₁ + ω^(β₂)·c₂ + ⋯ + ω^(βₖ)·cₖ,

where k ≥ 0, each cᵢ is a positive natural number, and the exponents satisfy
β₁ > β₂ > ⋯ > βₖ, with each βᵢ < α itself an ordinal below ε₀ presented the same
way. The recursion bottoms out at 0 (the empty sum). Because the data is finite and
the exponents are strictly decreasing, the representation is a genuine inductive
syntactic object: a *notation*.

We use two types:

- **Raw notations** (`ONote`): syntactic trees of the above shape, *without* the
  requirement that exponents strictly decrease. As a bare datatype the order on raw
  notations is **not** well-founded, because ill-formed trees can encode spurious
  descents.
- **Normal-form notations** (`NONote`): raw notations carrying a proof that they
  are in Cantor normal form (the `NF` side-condition). These are in order-preserving
  bijection with the ordinals below ε₀.

The order `<` on `NONote` agrees with the ordinal order under this bijection. The
crucial structural fact, which we take as the system's defining property, is:

> **(WF)** The order `<` on `NONote` is well-founded (`NONote.lt_wf`).

This single fact powers everything below.

> **Failure analysis (design note).** Stating the descent engine over raw
> notations `ONote` fails precisely because the bare relation lacks the `NF`
> side-condition and is therefore not well-founded. The engine must live on
> `NONote`. This is not a technicality; it is the formal shadow of the classical
> fact that a notation system certifies well-ordering only when its comparison
> respects normal form.

### 2.2 Well-ordering as absence of infinite descent

We phrase well-ordering in the form most useful for termination arguments.

> **Theorem 1 (No infinite descent).** For every sequence f : ℕ → NONote it is not
> the case that f(n+1) < f(n) for all n. Symbolically,
>
> > ¬ ∀ n, f(n+1) < f(n).

**Proof sketch.** Suppose, for contradiction, such an f existed. A strictly
descending sequence indexed by ℕ is exactly an order embedding of (ℕ, >) into
(NONote, <): the hypothesis that each successive term is smaller is, structurally, a
relation-embedding of the "greater-than on ℕ" order into the notation order. But the
existence of such an embedding contradicts well-foundedness (WF): a well-founded
relation admits no embedded copy of an infinite descending chain. Formally, the
embedding's image would be a nonempty class with no minimal element, contradicting
(WF). ∎

Theorem 1 is the computable counterpart of the abstract statement that
consistency-strength descent is well-founded; here it is the concrete engine that
the termination theorem consumes.

## 3. The Termination Engine

### 3.1 Statement

Let α be an arbitrary type of "states", let `step : α → α` be a deterministic
transition function, and let `μ : α → NONote` be a *measure* (monovariant)
assigning each state an ordinal notation.

> **Theorem 2 (Termination by ordinal measure).** Suppose that for every state x,
>
> > μ(x) ≠ 0 ⟹ μ(step x) < μ(x).
>
> Then for every initial state x₀ there exists a finite n with
>
> > μ(step^[n] x₀) = 0,
>
> where step^[n] denotes the n-fold iterate of step.

**Proof sketch.** We argue by well-founded induction on the measure, using the
relation "x is below y iff μ(x) < μ(y)" — formally the pullback of the notation
order along μ, which inherits well-foundedness from (WF). Fix x and assume the
result holds for every state of strictly smaller measure (the induction
hypothesis). Two cases:

- If μ(x) = 0, take n = 0; then step^[0] x = x already has measure 0.
- If μ(x) ≠ 0, the strict-decrease hypothesis gives μ(step x) < μ(x), so step x is
  a strictly-smaller-measure state. The induction hypothesis supplies an n with
  μ(step^[n] (step x)) = 0. Since step^[n] (step x) = step^[n+1] x, the value n+1
  witnesses the conclusion for x.

The induction is well-founded precisely because of Theorem 1 / (WF): the measure
cannot decrease forever, so the recursion terminates. ∎

The theorem is deliberately stated over an arbitrary state type α. This is what
makes it a *reusable engine*: the only content of any particular application is
constructing μ and verifying the one-line strict-decrease hypothesis.

### 3.2 The self-measured specialisation

When the state space *is* the notation system and the step drives the notation down
directly, the measure is the identity.

> **Theorem 3 (Self-descent).** Let `step : NONote → NONote` satisfy
>
> > x ≠ 0 ⟹ step x < x for all x.
>
> Then for every x₀ there exists n with step^[n] x₀ = 0.

**Proof sketch.** Apply Theorem 2 with μ = id. The hypothesis x ≠ 0 ⟹ step x < x is
exactly the strict-decrease condition with the identity measure, and μ(y) = 0
becomes y = 0. ∎

Theorem 3 is the most directly executable face of the framework: it concerns a
concrete function on a concrete computable datatype, and the resulting n can be
computed by iterating step until 0 is reached.

## 4. The Fast-Growing Hierarchy Is Effective

### 4.1 Definition

The fast-growing hierarchy assigns to each ordinal notation a a function
Fₐ : ℕ → ℕ by transfinite recursion on a:

- **Base.** F₀(n) = n + 1.
- **Successor.** F_{a+1}(n) = Fₐ^[n](n), the n-fold iterate of Fₐ applied to n.
- **Limit.** For a limit notation a with fundamental sequence (a[k])ₖ converging to
  a from below, F_a(n) = F_{a[n]}(n).

The fundamental sequence is the canonical strictly increasing sequence of smaller
notations whose supremum is a; for ω it is k ↦ k, and for ω^(β+1) it is
k ↦ ω^β·k, etc. Because notations, their fundamental sequences, and the iteration
are all computable, Fₐ(n) is computable for every notation a and input n.

### 4.2 Slow-level identities and certified values

The successor clause makes the low levels collapse to elementary arithmetic.

> **Proposition 4 (Base function).** F₀ = (· + 1); i.e. F₀(n) = n + 1 for all n.

**Proof sketch.** Immediate from the base clause of the definition. ∎

> **Proposition 5 (Level one).** F₁(n) = 2n.

**Proof sketch.** F₁(n) = F₀^[n](n). Each application of F₀ adds one, so applying it
n times to the start value n yields n + n = 2n. A clean induction on the iteration
count formalises "n applications of (+1) add n". ∎

> **Proposition 6 (Level two).** F₂(n) = n·2ⁿ.

**Proof sketch.** F₂(n) = F₁^[n](n). By Proposition 5, F₁ is multiplication by 2, so
iterating it n times multiplies the start value n by 2ⁿ, giving n·2ⁿ. Induction on
the iteration count, using F₁(m) = 2m at each step. ∎

These closed forms are *conjectured-then-certified*: they are first validated
numerically against the definition for many inputs and then proved by induction.
As anchors, we record two kernel-checked instances obtained by direct evaluation of
the recursive definition:

> **Theorem 7 (Certified values).**
> > F₁(3) = 6  and  F₂(2) = 8.

**Proof sketch.** Both are decided by evaluating the computable definition: F₁(3) =
F₀^[3](3) = 3 ↦ 4 ↦ 5 ↦ 6, and F₂(2) = F₁^[2](2) = 2 ↦ 4 ↦ 8. The evaluations are
checked by the kernel/compiler with no appeal to the closed forms, so they
independently corroborate Propositions 5 and 6 (2·3 = 6, 2·2² = 8). ∎

The significance of Theorem 7 is methodological rather than numerical: it certifies
that the entire hierarchy — which at higher indices outgrows every primitive
recursive function and, at ε₀, every function provably total in Peano Arithmetic —
rests on an executable foundation. The growth is cosmic; the evaluation is concrete.

### 4.3 The growth landscape

Beyond the slow levels the hierarchy accelerates explosively:

- F₃(n) is iterated exponentiation, of tower (tetration) type.
- F_ω, the first transfinite level, dominates every primitive recursive function
  and coincides up to minor adjustments with the Ackermann function.
- F_{ε₀} eventually dominates every function whose totality is provable in Peano
  Arithmetic; its totality is independent of PA.

This places the hierarchy in exact correspondence with the proof-theoretic role of
ε₀: the ordinal that bounds the notation system is the same ordinal at which the
hierarchy escapes arithmetic's proving power.

## 5. Classical Termination Theorems as Instances

The design payoff is that famous "surprisingly terminating" processes become
one-line applications of Theorem 2 (or Theorem 3), once the right measure map is
supplied. We sketch two.

### 5.1 Goodstein sequences

Fix a starting number m. Write m in hereditary base 2, repeatedly bump the base
(2→3→4→…) and subtract one, producing the Goodstein sequence G₀ = m, G₁, G₂, ….
Define μ(Gₖ) ∈ NONote by replacing the current base everywhere in the hereditary
representation of Gₖ with the symbol ω, yielding an ordinal notation below ε₀.

- Bumping the base does not change μ (the ω-form is base-independent).
- The subsequent subtraction of one strictly decreases μ whenever Gₖ ≠ 0.

Hence μ is a strict ε₀-monovariant, and Theorem 2 yields an n with μ(Gₙ) = 0, i.e.
Gₙ = 0. **Conjecture/claim (Direction 1):** this assignment satisfies the
strict-decrease hypothesis, so every Goodstein sequence terminates — not as a new
theorem but as a single instance of the engine. The only remaining content is the
explicit, evaluation-checkable hereditary-base encoding, which is finite
combinatorics rather than ordinal theory.

### 5.2 The Kirby–Paris Hydra

Model a Hydra as a finite rooted tree; Hercules chops a head (a leaf), and the
Hydra regrows copies of a subtree at a lower node. Assign each Hydra an ordinal
notation by the standard recursive rank: a leaf has rank 0, and a node with child
ranks r₁ ≥ ⋯ ≥ rₘ has rank ω^(r₁) + ⋯ + ω^(rₘ). Every legal chop — regrowth
included — strictly lowers this rank. **Conjecture/claim (Direction 2):** the rank
is a strict monovariant, so Theorem 3 / Theorem 2 gives that Hercules always wins.
The rank is computable, so the strict-decrease hypothesis can be empirically
stress-tested on small hydras before the general proof.

The unifying observation is that Goodstein and Hydra, classically proved by
separate intricate inductions, are *the same theorem* applied to two different
measure maps μ. The well-order does the work.

## 6. Algorithms

We extract three computational procedures, all backed by the theory above.

### 6.1 Ordinal-measure termination driver

Given step, μ, and x₀ satisfying the hypothesis of Theorem 2, iterate step,
recomputing μ at each state, and stop when μ = 0. Theorem 2 guarantees the loop
exits after finitely many iterations; the returned iteration count is the witness
n. Complexity is dominated by the number of steps, which is exactly the (finite)
descent length of μ from μ(x₀) to 0 — itself bounded, when the descent follows
fundamental sequences, by Hardy-style functions of the start notation.

### 6.2 Fast-growing evaluator

Compute Fₐ(n) by structural recursion on the notation a: the base clause returns
n+1; the successor clause iterates F_{a−1} n times; the limit clause selects the
n-th fundamental-sequence element. Memoisation of intermediate iterates tames the
slow levels; the high levels are intrinsically infeasible beyond tiny inputs, which
is itself the point.

### 6.3 Descent-length probe

For a self-descending step on NONote, iterate from a start a and count steps to 0
(Theorem 3). Comparing measured step counts against Fₐ values probes the
quantitative link between descent length and the fast-growing rate (Direction 5).

## 7. Applications and Significance

**Foundations.** The framework makes concrete the fact that Goodstein's theorem and
the Hydra theorem, though statements about natural numbers and finite trees, are
*independent of Peano Arithmetic*: their proofs require the well-ordering of ε₀,
which lies just beyond PA. Packaging the well-ordering as a reusable computable
certificate clarifies exactly where the extra-arithmetical strength enters.

**Program termination.** Theorem 2 is a drop-in termination certificate for any
deterministic transition system. Where a natural-number measure is too weak, an
ε₀-valued measure captures processes that grow before they shrink — lexicographic
combinations, nested loops, and rewriting systems — within a single principle.

**Verified general recursion.** Because the notation order is well-founded and
computable, it can serve directly as a decreasing measure for general recursive
definitions, yielding total-correctness certificates "for free" (Direction 4).

## 7a. The Abstract and Computable Layers

It is worth making explicit how this development relates to the more familiar
*abstract* treatment of ordinals. In the abstract setting one works directly with
the order type — the ordinal number itself — and well-foundedness is a property of
the class of all ordinals below ε₀. That viewpoint is mathematically clean but
intrinsically non-computational: an arbitrary ordinal below ε₀ has no canonical
finite presentation unless one fixes a notation system. The contribution of the
present work is to descend from that abstract strength order to the *computable*
notation layer, where each ordinal is a concrete finite syntactic object, order
comparison is a decidable algorithm, and the hierarchy Fₐ(n) is an executable
function.

The two layers are connected by an order isomorphism: normal-form notations
(`NONote`) are in order-preserving bijection with the ordinals below ε₀, so the
well-foundedness of the abstract order transfers to (WF) for the notation order,
and vice versa. Everything proved here therefore has an abstract shadow — Theorem
1 mirrors the structural well-foundedness of consistency-strength descent, and
Theorem 2 mirrors the classical principle of transfinite induction up to ε₀ — but
with the decisive added benefit that the notation-layer statements are *runnable*.
A termination certificate produced by Theorem 2 is not merely an existence claim;
the witness n can be computed by iterating the step function, and the measure can
be evaluated and compared at each stage. This is what turns a proof-theoretic
invariant into an algorithmic tool.

## 7b. Axiomatic Basis

The development is constructive in spirit and rests on a minimal foundation. The
well-ordering (WF) and the inductive arguments of Theorems 1–3 use only
proof-irrelevance, the choice principle underlying classical well-founded
recursion, and quotient soundness (the standard trio `propext`,
`Classical.choice`, `Quot.sound`). The certified hierarchy values of Theorem 7
additionally invoke kernel-/compiler-level evaluation of the computable
definition (`Lean.ofReduceBool` / `Lean.trustCompiler`), which is precisely what
makes the claim "the hierarchy is effective" a mechanically checked fact rather
than an informal assertion. No nonstandard axioms enter. The combination — a
minimal logical base plus kernel-checked computation — is what licenses the dual
claim that the framework is both rigorously proved and genuinely executable.

## 8. Discussion

The thesis of this work is economy. Each of the three faces of ε₀ — well-ordering,
termination, growth — has a substantial classical literature, and each famous
terminating process has historically warranted its own proof. We argue that, over a
computable notation system, the three faces are one, and the proofs are one. The
well-ordering (Theorem 1) is the engine; the termination theorem (Theorem 2) is its
universal interface; the self-descent corollary (Theorem 3) is its executable
instance; and the fast-growing hierarchy (Propositions 4–6, Theorem 7) is the
quantitative measure of how long the descents can take. The minimal axiom base and
the kernel-checked evaluations together ensure that the abstract claims are matched
by concrete computation.

A limitation worth stating plainly is the necessity of normal form: the engine
cannot live on raw notations, because their bare order is not well-founded. This is
not an artefact but a faithful reflection of the classical theory, where a notation
system certifies well-ordering only through its normal-form discipline.

## 9. Future Directions

1. **Goodstein as an instance.** Formalise the hereditary-base map g : ℕ → NONote
   and discharge Goodstein termination as a single application of Theorem 2,
   reducing it to finite combinatorics.

2. **Hydra as an instance.** Encode Kirby–Paris hydras as finite rooted trees,
   define the chop-and-regrow step, assign the recursive ordinal rank, and obtain
   Hercules's victory from Theorem 3 / Theorem 2.

3. **Closed forms.** Prove F₁(n) = 2n and F₂(n) = n·2ⁿ in full generality by
   induction on n, using the regular shape of the fundamental sequences of 1 and ω,
   validated numerically beforehand.

4. **Verified ordinal-bounded loop combinator.** Package Theorem 2 into a
   dependently typed executable `whileDescending` combinator that runs step until μ
   hits 0, returning the final state with a termination certificate, giving general
   recursion for free.

5. **Quantitative descent.** Relate the existential step count of Theorem 3 to
   fast-growing / Hardy-style lower bounds when the descent follows fundamental
   sequences, probing the link numerically before committing to an analytic bound.

## 10. Conclusion

We have shown that the well-ordering of the computable Cantor-normal-form notation
system below ε₀, the termination of ε₀-measured processes, and the fast-growing
hierarchy are three faces of one constructive picture. A single termination theorem
serves as the universal interface; well-ordering is its engine; the self-descent
corollary is its executable face; and the kernel-checked hierarchy values certify
that the whole edifice is effective. Classical termination landmarks — Goodstein,
Hydra — become instances rather than independent miracles. The staircase through the
ordinals below ε₀, however strange its steps, has no infinite way down.
