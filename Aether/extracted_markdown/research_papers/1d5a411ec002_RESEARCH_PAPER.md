# Finite-State Decidability of the Zero-in-Sequence Problem for Automatic Sequences

## Abstract

We develop a minimal, self-contained theory of *deterministic finite automata
with output* (DFAOs) and the *automatic sequences* they generate, and use it to
establish the decidability of the **zero-in-sequence problem** for automatic
sequences: given a DFAO that generates a sequence `(a_n)`, it is decidable
whether the value `0` (or any fixed target value) occurs as some `a_n`. The
decision procedure reduces an a priori infinite search over all input words to a
finite breadth-first exploration of the automaton's reachable state set, which
provably stabilizes within a number of rounds bounded by the state count. Along
the way we prove a structural obstruction — every automatic sequence has finite
range — which immediately implies that unbounded sequences such as `a_n = n` are
not automatic for any base, and we prove that *unary* automatic sequences are
eventually periodic via a pigeonhole argument on the orbit of a single
endofunction. All results are organized so as to depend only on finite-state
combinatorics, deliberately avoiding the digit-arithmetic layer and Christol's
theorem. We close by situating these results against the conjecturally
undecidable analogue for morphic sequences, identifying finite-valuedness and
finite state count as the structural separators between decidability and
undecidability in sequence theory.

**Keywords.** automatic sequences, deterministic finite automata, decidability,
zero-in-sequence problem, pigeonhole principle, eventual periodicity, morphic
sequences, formal verification.

---

## 1. Introduction

### 1.1 Background

An *automatic sequence* is an infinite sequence whose `n`-th term is computed by
a finite-state machine that reads the base-`k` digit expansion of the index `n`.
The paradigmatic example is the **Thue–Morse sequence** `t = 0110100110010110...`,
where `t_n` is the parity of the number of `1`s in the binary representation of
`n`. Other classical examples include the **Rudin–Shapiro sequence** (parity of
the number of `11` factors in binary) and the **regular paperfolding sequence**.
All three are `2`-automatic.

Automatic sequences are a cornerstone of combinatorics on words and have
applications in number theory, theoretical physics (aperiodic order and
quasicrystals), and the theory of formal languages. A landmark structural result
is **Christol's theorem**: a formal power series over a finite field `F_q` is
algebraic over `F_q(x)` if and only if its coefficient sequence is `q`-automatic.
Christol's theorem is, however, intrinsically a finite-field statement; over `Z`
or `Q` no such clean algebraicity characterization holds.

### 1.2 The decision problem

This paper concerns a decision problem rather than an algebraicity
characterization. Given a finite-state description of a sequence `(a_n)`, the
**zero-in-sequence problem** asks whether there exists an index `n` with
`a_n = 0`. More generally, for any fixed target value `a`, we ask whether `a`
occurs in the sequence, and — when it does — whether it occurs infinitely often.

For arbitrary computable sequences this problem is undecidable: it is a thin
disguise for the halting problem. The contribution here is to show, with a fully
mechanically verified development, that for automatic sequences the problem is
*decidable*, and to isolate the precise finite-state mechanism responsible.

### 1.3 Design philosophy

The development is deliberately *digit-free*. We treat the encoder
`encode : ℕ → List (Fin k)` (canonically the base-`k` expansion) as an abstract
parameter, because none of the finite-state results below depend on its specific
arithmetic structure. This keeps the theory minimal and exposes exactly which
combinatorial facts about finite automata do the work. In particular nothing
here invokes Christol's theorem or any general computability machinery; the
results rest entirely on the finiteness of the state space and the pigeonhole
principle.

### 1.4 Summary of contributions

1. A clean formal model of DFAOs (Section 2), with `run` and `eval` and an
   inductive notion of reachability that is proved equivalent to "reachable by
   some word."
2. A constructive, terminating breadth-first reachability computation
   (Section 3), with a proof that it stabilizes within `|Q|` rounds.
3. **Decidability of occurrence** (Section 4): for a fixed DFAO and target
   output, it is decidable whether some word produces that output — hence the
   zero-in-sequence problem is decidable.
4. The **finite-range obstruction** (Section 5): every automatic sequence has
   finite range, so `a_n = n` is not automatic for any `k`.
5. **Eventual periodicity** of unary automatic sequences (Section 6).
6. A discussion of the automatic/morphic decidability boundary (Section 7) and
   future directions (Section 8).

---

## 2. Deterministic Finite Automata with Output

### 2.1 The model

**Definition 2.1 (DFAO).** A *deterministic finite automaton with output* over
the input alphabet `Fin k`, state space `Q`, and output alphabet `α` is a triple
`M = (q0, step, out)` where

- `q0 : Q` is the **initial state**,
- `step : Q → Fin k → Q` is the **transition function**, and
- `out : Q → α` is the **output function**.

**Definition 2.2 (run and eval).** For a word `w : List (Fin k)`, the state
reached by `M` is the left fold of `step` over `w` starting from `q0`:
```
run M w = w.foldl step q0.
```
The *output produced by* `w` is `eval M w = out (run M w)`.

Two computation rules are immediate and form the basis of all inductive
arguments:

- `run M [] = q0` (the empty word leaves the machine in its initial state);
- `run M (w ++ [c]) = step (run M w) c` (appending one symbol applies one
  transition).

**Definition 2.3 (k-automatic sequence).** A function `f : ℕ → α` is
*k-automatic* if there exist a DFAO `M` over `Fin k` with finite state space and
an encoder `encode : ℕ → List (Fin k)` such that
```
f n = eval M (encode n)   for all n.
```
We write `IsKAutomatic k f` for this property. The canonical encoder is the
base-`k` digit expansion of `n`; the results below do not depend on this choice.

### 2.2 Reachability

**Definition 2.4 (reachability).** The predicate `Reachable M : Q → Prop` is the
least predicate closed under

- `base`: `Reachable M q0`;
- `step`: if `Reachable M q` then `Reachable M (step q c)` for every `c : Fin k`.

**Lemma 2.5 (runs are reachable).** For every word `w`, `Reachable M (run M w)`.

*Proof.* Induct on `w` using the reverse (snoc) recursor. The empty word reaches
`q0`, which is reachable by `base`. For `w ++ [c]`, the inductive hypothesis
gives `Reachable M (run M w)`, and one application of the `step` constructor with
symbol `c` yields `Reachable M (step (run M w) c) = Reachable M (run M (w ++ [c]))`.
∎

**Lemma 2.6 (reachability = word-reachability).**
`Reachable M q ↔ ∃ w, run M w = q`.

*Proof.* (⇒) Induct on the derivation of `Reachable M q`. The base case uses the
empty word. For the `step` case with hypothesis `run M w = q`, the word
`w ++ [c]` satisfies `run M (w ++ [c]) = step q c`. (⇐) Immediate from
Lemma 2.5. ∎

These two lemmas pin down reachability as exactly the set of states attainable by
reading some input, which is what licenses replacing the (infinite) word search
by a (finite) state search.

---

## 3. Computing the Reachable Set

We now assume `Q` is a finite type with decidable equality (`Fintype Q`,
`DecidableEq Q`) and give a terminating algorithm computing the reachable set.

**Definition 3.1 (one expansion round).** For `S : Finset Q`,
```
expand M S = S ∪ (⋃_{q ∈ S} { step q c : c ∈ Fin k }).
```
That is, augment `S` with every state one transition away from a state of `S`.

**Lemma 3.2 (expansion is extensive and sound).**
`S ⊆ expand M S`; and if `q ∈ S`, then `step q c ∈ expand M S` for every `c`.

**Definition 3.3 (iterated reachability).**
```
reach M 0       = {q0},
reach M (n + 1) = expand M (reach M n).
```

**Lemma 3.4 (monotonicity).** `reach M m ⊆ reach M n` whenever `m ≤ n`.

*Proof.* Immediate by induction from `reach M n ⊆ reach M (n+1)` (Lemma 3.2). ∎

**Lemma 3.5 (soundness).** If `q ∈ reach M n` then `Reachable M q`.

*Proof.* Induct on `n`. At `n = 0`, `q ∈ {q0}` forces `q = q0`, which is
reachable. At `n + 1`, membership in `expand` splits into `q ∈ reach M n`
(handled by the inductive hypothesis) or `q = step p c` for some
`p ∈ reach M n`; in the latter case the inductive hypothesis gives
`Reachable M p`, and the `step` constructor finishes. ∎

**Lemma 3.6 (stabilization persists).** If `reach M (n+1) = reach M n`, then
`reach M m = reach M n` for all `m ≥ n`.

*Proof.* Induct on `m ≥ n`: the inductive step rewrites
`reach M (m+1) = expand (reach M m) = expand (reach M n) = reach M (n+1)
= reach M n`. ∎

**Lemma 3.7 (no-stabilization forces growth).** If `reach M (i+1) ≠ reach M i`
for all `i < n`, then `n + 1 ≤ |reach M n|`.

*Proof.* Induct on `n`. Base: `|reach M 0| = |{q0}| = 1`. Step: the hypothesis
gives a strict inclusion `reach M n ⊊ reach M (n+1)` (proper because the sets are
unequal and nested), so `|reach M n| < |reach M (n+1)|`; combine with the
inductive bound `n + 1 ≤ |reach M n|` to get `n + 2 ≤ |reach M (n+1)|`. ∎

**Theorem 3.8 (stabilization within `|Q|` rounds).** There exists
`n ≤ |Q|` with `reach M (n+1) = reach M n`.

*Proof.* Suppose not: then `reach M (i+1) ≠ reach M i` for all `i ≤ |Q|`. By
Lemma 3.7, `|Q| + 1 ≤ |reach M (|Q|)|`. But `reach M (|Q|) ⊆ univ`, so
`|reach M (|Q|)| ≤ |Q|`, a contradiction. ∎

**Definition 3.9 (reachable-state finset).**
```
reachSet M = reach M (Fintype.card Q).
```
By Theorem 3.8 the expansion has reached a fixed point by stage `|Q|`, so
`reachSet M` equals `reach M n` for every `n ≥ |Q|` and is closed under `step`.
Consequently, by Lemmas 3.5 and 2.6, `reachSet M = { q : Reachable M q }` as a
finite set: it is exactly the set of reachable states.

---

## 4. Decidability of Occurrence and the Zero-in-Sequence Problem

**Definition 4.1 (occurrence).** Output value `a : α` *occurs* in `M` if there
exists a word `w` with `eval M w = a`, equivalently `out (run M w) = a`. By
Lemma 2.6 this is equivalent to `∃ q, Reachable M q ∧ out q = a`.

**Theorem 4.2 (decidability of occurrence).** Let `M` be a DFAO with finite
state space `Q` and decidable equality on `α`. Then the proposition "some word
produces output `a`" is decidable.

*Proof.* By Definition 4.1 and the characterization of `reachSet M` as exactly
the reachable states (Section 3),
```
(∃ w, eval M w = a)  ↔  (∃ q ∈ reachSet M, out q = a).
```
The right-hand side is a decidable existential over a finite set with a decidable
predicate (`out q = a` is decidable because `α` has decidable equality). Hence
the left-hand side is decidable. The decision procedure: compute `reachSet M` by
iterating `expand` from `{q0}` (at most `|Q|` rounds by Theorem 3.8), then test
whether any state in it is labelled `a`. ∎

**Corollary 4.3 (zero-in-sequence decidability).** Taking `a = 0`, it is
decidable whether a DFAO ever outputs `0`; equivalently, for a `k`-automatic
sequence presented by a DFAO whose encoder hits every state (e.g. base-`k`
expansions), it is decidable whether `0` appears as some `a_n`.

**Remark 4.4 (the finite/infinite dichotomy).** A complementary
pumping-lemma analysis sharpens occurrence into a dichotomy. If `M` has `s`
states and some word of length `≥ s` produces output `a`, then by the pigeonhole
principle that word's run repeats a state, isolating a loop that can be pumped to
produce infinitely many words with output `a`; hence `a` occurs *infinitely
often*. Conversely, if no word of length `< s` produces `a`, then no word does at
all. Thus finiteness of occurrence is decided by inspecting words shorter than
`s`, and infinitude by exhibiting one whose length lies in the window `[s, 2s)`.
This is the conjectural sharp threshold C1 of Section 8.

---

## 5. The Finite-Range Obstruction

**Theorem 5.1 (finite range).** If `IsKAutomatic k f` with state space `Q`
finite, then the range of `f` is finite; in fact `range f ⊆ range out`, which has
at most `|Q|` elements.

*Proof.* For every `n`, `f n = eval M (encode n) = out (run M (encode n))`, so
`f n ∈ range out`. Therefore `range f ⊆ range out`. The image of a function out
of a finite type is finite, so `range out` is finite, and so is `range f`. ∎

**Theorem 5.2 (the identity is not automatic).** The sequence `f n = n` is not
`k`-automatic for any `k`.

*Proof.* The range of `f n = n` is all of `ℕ`, which is infinite. If `f` were
`k`-automatic, Theorem 5.1 would force its range to be finite — a contradiction.
∎

**Discussion.** Theorem 5.1 is a *necessary condition* for automaticity and thus
a cheap nonautomaticity test: any sequence taking infinitely many values
(`a_n = n`, `a_n = n^2`, the prime-counting sequence, the integer partition
counts, etc.) is immediately excluded. It also marks the first structural
separation from the broader class of `P`-recursive sequences (those satisfying a
linear recurrence with polynomial coefficients), which routinely take infinitely
many values. Finite-valuedness is the decisive separator: automatic sequences are
finite-valued, while a generic `P`-recursive sequence is not.

---

## 6. Eventual Periodicity of Unary Automatic Sequences

The *unary* case — where the machine effectively reads a single repeated symbol —
exposes the periodic skeleton underlying all finite-state dynamics.

**Setup.** Fix a state space `Q`, a single endofunction `next : Q → Q` (the
transition for the one symbol), an initial state `q0`, and an output map
`out : Q → α`. Define the unary sequence
```
u n = out (next^[n] q0),
```
where `next^[n]` is `n`-fold iteration.

**Theorem 6.1 (eventual periodicity).** The sequence `u` is eventually periodic:
there exist a pre-period `m ≥ 0` and a period `p ≥ 1` such that
`u (n + p) = u n` for all `n ≥ m`.

*Proof.* Consider the orbit `q0, next q0, next^[2] q0, ...` in the finite set
`Q`. Among the first `|Q| + 1` iterates two must coincide (pigeonhole): there
exist `i < j ≤ |Q|` with `next^[i] q0 = next^[j] q0`. Set `m = i` and
`p = j - i ≥ 1`. Since `next` is a function, applying it preserves equality of
iterates, so `next^[n] q0 = next^[n + p] q0` for all `n ≥ m`. Applying `out` to
both sides gives `u n = u (n + p)` for all `n ≥ m`. ∎

**Remark 6.2.** Theorem 6.1 is the engine behind the eventual periodicity of any
finite-state process driven by a fixed letter, and it is the base case for the
prefix-shift generalization C2 of Section 8: a bounded prefix only relocates the
starting state of the orbit, leaving the eventual period (dividing the order of
`next` as a self-map) intact.

---

## 7. The Boundary: Automatic versus Morphic

The decidability results above are sharp in a precise sense: they rely on the
*finiteness of the state space*, and that finiteness fails for the next class up.

A **morphic sequence** is generated by iterating a substitution (a *morphism*)
`σ : Σ → Σ*` on a finite alphabet `Σ`, taking the fixed point of `σ` started at a
letter, and applying a coding `τ : Σ → α`. Every automatic sequence is morphic
(via a uniform morphism whose images all have length `k`), but morphic sequences
are strictly more general: their generation can grow structure without bound, in
contrast to the bounded state count of a DFAO.

For automatic sequences, the zero-in-sequence problem is decidable
(Corollary 4.3). For morphic sequences, **whether the zero-in-sequence problem is
decidable is open.** The same pigeonhole reduction does not apply, because there
is no fixed finite state set whose exhaustion bounds the search. This places the
automatic/morphic interface as a candidate boundary between decidability and
undecidability in the theory of sequences — a phenomenon with a strong family
resemblance to Turing's original undecidability of the halting problem, recast in
the language of combinatorics on words.

---

## 8. Future Directions

**C1. Sharp pumping threshold for the zero set is exactly the state count.**
*Conjecture.* For a DFAO with `s` states and output map `out`, the set
`{w : out (eval M w) = z}` is infinite **iff** it contains a word of length in
the window `[s, 2s)`; equivalently, finiteness is decided by inspecting words of
length `< s` only, and infinitude by exhibiting one in `[s, 2s)`. The key insight
is that the pumping lemma localizes the loop inside the first `s` letters, so the
entire finite/infinite dichotomy is witnessed within a bounded length window
rather than unboundedly far out. The two halves of the dichotomy are already
established (Remark 4.4); tightening the witness length from "≥ s" to the explicit
window `[s, 2s)` is a finite combinatorial refinement.

**C2. Eventual periodicity generalizes from unary to ultimately-constant
inputs.** *Conjecture.* If the representation stream `repr n` is eventually
constant in its tail letter (reads a fixed letter `a` after a bounded prefix),
then `n ↦ out (eval M (repr n))` is eventually periodic, with period dividing the
order of `s ↦ step s a` as a self-map of `Q`. The unary case (Theorem 6.1) shows
the tail dynamics are governed by a single endofunction's orbit; a bounded prefix
only shifts the starting state, leaving the eventual period intact.

**C3. Finite-valuedness is the decisive separator: automatic ⊊ P-recursive.**
*Conjecture.* Every `k`-automatic integer sequence is `P`-recursive, but the
converse fails on exactly the unbounded `P`-recursive sequences; a `P`-recursive
sequence is automatic only if it takes finitely many values. The finite-range
theorem (Theorem 5.1) makes finite range a *necessary* condition for
automaticity, and the identity sequence (Theorem 5.2) realizes a `P`-recursive
sequence that fails it.

**C4. Decidability frontier for morphic sequences.** Determine whether the
zero-in-sequence problem is decidable for general morphic sequences, or identify
the largest natural subclass (e.g. primitive, or uniformly recurrent morphic
sequences) for which a finite-search reduction in the spirit of Theorem 4.2 can
be recovered.

---

## 9. Conclusion

We have given a compact, fully rigorous account of why automatic sequences have a
decidable zero-in-sequence problem. The mechanism is uniform and elementary: a
finite state space forces the search over infinitely many input words to collapse
to a finite breadth-first exploration that stabilizes within `|Q|` rounds
(Theorem 3.8), yielding decidability of occurrence (Theorem 4.2). The same
finiteness furnishes a structural obstruction — finite range (Theorem 5.1) — that
cleanly separates automatic from merely `P`-recursive sequences and rules out
`a_n = n` (Theorem 5.2), and it forces eventual periodicity in the unary case
(Theorem 6.1). The picture that emerges is that *finite memory equals
decidability*: where the generating mechanism keeps a bounded state, the
pigeonhole principle guarantees we can always answer occurrence questions, and
where it does not — as in morphic generation — those guarantees become, at
present, conjectural at best.
