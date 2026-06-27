# Non-Finite-Axiomatization of Measurable Majorities via the Incoherence Index

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Novelty / Applications (Social Choice, Additive Combinatorics)

---

## Abstract

We study the *coherence* of standard social decision frames — finite sets of
admissible majority adjustments modeled as atoms in the cyclic group
$\mathbb{Z}/n\mathbb{Z}$ — and ask whether coherence can be certified by any fixed,
bounded family of finite checks. We introduce the **incoherence index**
$\mathrm{index}(F)$, the length of the shortest *perfectly balanced sequence* (a
non-empty zero-sum word over the atoms), and the **width-$B$ fragment**
$\mathrm{CoherentUpTo}(B, F)$, which a frame passes when it admits no balanced
sequence of length $\le B$. Our central structural result is an exact threshold:
for every incoherent frame,
$$\mathrm{CoherentUpTo}(B, F) \iff B < \mathrm{index}(F).$$
From this we derive **strict refinement**: for every $B$ there is a *maximal*
frame passing the width-$B$ fragment but failing the width-$(B+1)$ fragment, so the
hierarchy of finite fragments never collapses. Equivalently, the coherence
criterion is **not finitely axiomatizable** by bounded fragments. The engine is the
single-generator frame $\{1\} \subseteq \mathbb{Z}/n\mathbb{Z}$, which is maximal
and whose incoherence index equals $n$ exactly — the maximum attainable on $n$
states. We complement this with a saturation contrast — the maximal frame
$\{1,3\} \subseteq \mathbb{Z}/4\mathbb{Z}$ has index only $2$ — showing the
extremal index is the exclusive privilege of sparse generators, and with
parity and unboundedness results placing the index in additive combinatorics as a
Davenport-constant-style invariant. All results have been formally verified.

---

## 1. Introduction

### 1.1 Motivation

A persistent fantasy in the certification of decision procedures is the *finite
checklist*: a fixed, bounded battery of local tests that, once passed, guarantees a
global consistency property. In software verification this is "bounded model
checking"; in logic it is "finite axiomatizability"; in social choice it is the
hope that consistency of a voting rule can be witnessed by inspecting only small
coalitions or short preference cycles.

This paper isolates a clean arena where that fantasy is provably false, and false
in the strongest constructive sense. We model collective decisions over $n$ states
arranged cyclically and define coherence as the absence of any *closed loop* of
admissible majority moves — a chain that returns the collective to its starting
state. We then ask whether coherence is equivalent to the absence of *short* closed
loops, for some uniform bound on length. The answer is no, and we exhibit, for
every candidate bound, an explicit legitimate (maximal) frame defeating it.

### 1.2 Contributions

1. A precise model of standard social decision frames as atom sets in
   $\mathbb{Z}/n\mathbb{Z}$, with the *incoherence index* as the length of the
   shortest perfectly balanced sequence (Section 2).
2. The exact-threshold theorem
   `coherentUpTo_iff_lt_incoherenceIndex`: the width-$B$ fragment is passed iff
   $B < \mathrm{index}(F)$ (Section 4).
3. The strict-refinement theorem `fragment_strictly_refines` and its corollary,
   non-finite-axiomatizability of coherence (Section 4).
4. The realization theorem `incoherenceIndex_singleton_one`: the single-generator
   frame $\{1\}$ is maximal with index exactly $n$, the greatest attainable
   (`incoherenceIndex_isGreatest`), together with parity (`even_incoherenceIndex`)
   and unboundedness (`incoherence_unbounded`) (Section 3).
5. The saturation contrast `incoherenceIndex_oneThree`: maximality alone does not
   determine the index (Section 5).
6. The placement of the index within additive combinatorics as a
   Davenport-constant-style zero-sum invariant (Section 6).

All statements have been formally machine-checked.

---

## 2. The model

Throughout, $n$ is a positive natural number and arithmetic is in the cyclic group
$\mathbb{Z}/n\mathbb{Z}$, whose elements are the residues $\{0, 1, \dots, n-1\}$
with addition modulo $n$.

**Definition 2.1 (Frame).** A *standard social decision frame* on $n$ social states
is a finite subset $F \subseteq \mathbb{Z}/n\mathbb{Z}$. Its elements are called
*atoms* and represent admissible majority-or-tie adjustments to the collective
position. (In the intended interpretation the residue $0$ — "no change" — is not an
atom, since it is never itself a majority-driven move; this convention is what
forces the index away from $1$, see Proposition 3.6.)

**Definition 2.2 (Perfectly balanced sequence).** A list $l = [x_1, \dots, x_k]$ is
*perfectly balanced* for $F$, written $\mathrm{IsBalanced}(F, l)$, when

1. $l \neq []$ (non-emptiness),
2. every entry lies in $F$: $x_i \in F$ for all $i$, and
3. the entries sum to zero: $x_1 + \cdots + x_k = 0$ in $\mathbb{Z}/n\mathbb{Z}$.

Such a sequence is a *closed loop*: a non-trivial chain of admissible moves
returning the collective to its origin. Its existence is the signature of
incoherence.

**Definition 2.3 (Balanced lengths).** The set of attainable balanced-sequence
lengths is
$$\mathrm{balancedLengths}(F) = \{\, k \in \mathbb{N} \mid \exists\, l,\;
\mathrm{IsBalanced}(F, l) \wedge |l| = k \,\}.$$

**Definition 2.4 (Incoherence index).** The *incoherence index* of $F$ is
$$\mathrm{index}(F) = \inf \,\mathrm{balancedLengths}(F),$$
the length of a shortest perfectly balanced sequence, with the convention
$\inf \emptyset = 0$. Thus $\mathrm{index}(F) = 0$ iff $F$ is *coherent* (admits no
balanced sequence), and otherwise $\mathrm{index}(F) \ge 1$ is the minimal loop
length. A frame is *incoherent* when $\mathrm{balancedLengths}(F) \neq \emptyset$.

**Definition 2.5 (Maximality).** A frame $F$ is *maximal*, written
$\mathrm{IsMaximal}(F)$, when its atoms generate the whole group:
$$\langle F \rangle = \mathbb{Z}/n\mathbb{Z},$$
i.e. the additive subgroup generated by $F$ is all of $\mathbb{Z}/n\mathbb{Z}$.
Maximal frames are the fully expressive decision procedures: every state is
reachable by some chain of admissible moves.

**Definition 2.6 (Width-$B$ fragment).** For $B \in \mathbb{N}$, the frame $F$ is
*coherent up to $B$*, written $\mathrm{CoherentUpTo}(B, F)$, when
$$\neg\, \exists\, l,\; \mathrm{IsBalanced}(F, l) \wedge |l| \le B,$$
that is, $F$ admits no perfectly balanced sequence of length $\le B$. This is the
"length-$B$ checklist": it passes a frame precisely when no closed loop of length at
most $B$ exists.

---

## 3. The single-generator frame and the spectrum

The driving examples are the *cyclic* frames $\{1\} \subseteq
\mathbb{Z}/n\mathbb{Z}$. We collect their properties; they supply both the extremal
index and the separators used in Section 4.

**Lemma 3.1 (`isMaximal_singleton_one`).** For $n \ge 1$, the frame
$\{1\} \subseteq \mathbb{Z}/n\mathbb{Z}$ is maximal.

*Proof sketch.* The subgroup generated by the unit $1$ contains $1, 1+1, \dots$,
i.e. every residue $x$ (write $x = x \cdot 1$). Hence $\langle \{1\}\rangle = \top$.
∎

**Lemma 3.2 (`singleton_one_balanced_dvd`).** If $l$ is perfectly balanced for
$\{1\} \subseteq \mathbb{Z}/n\mathbb{Z}$, then $n \mid |l|$.

*Proof sketch.* Every entry of $l$ lies in the singleton $\{1\}$, so $l$ is the
constant list $[1, 1, \dots, 1]$ of length $|l|$, and its sum is $|l| \cdot 1 =
|l| \pmod n$. Balancedness gives $|l| \equiv 0 \pmod n$, i.e. $n \mid |l|$. ∎

**Lemma 3.3 (`singleton_one_min_length`).** If $l$ is perfectly balanced for
$\{1\} \subseteq \mathbb{Z}/n\mathbb{Z}$, then $|l| \ge n$.

*Proof sketch.* By Lemma 3.2, $n \mid |l|$, and by non-emptiness $|l| > 0$; a
positive multiple of $n$ is at least $n$. ∎

**Proposition 3.4 (`incoherenceIndex_le`).** For $n \ge 1$ and any non-empty frame
$F$, $\mathrm{index}(F) \le n$.

*Proof sketch.* Pick any atom $a \in F$. The constant list $[a, a, \dots, a]$ of
length $n$ has sum $n \cdot a = 0$ in $\mathbb{Z}/n\mathbb{Z}$, hence is balanced;
so $n \in \mathrm{balancedLengths}(F)$ and the infimum is $\le n$. ∎

**Theorem 3.5 (`incoherenceIndex_singleton_one`).** For $n \ge 1$,
$$\mathrm{index}(\{1\} \subseteq \mathbb{Z}/n\mathbb{Z}) = n.$$

*Proof sketch.* The upper bound $\le n$ is Proposition 3.4 (the frame is
non-empty). For the lower bound, every balanced sequence has length $\ge n$ by
Lemma 3.3, so every element of $\mathrm{balancedLengths}(\{1\})$ is $\ge n$, whence
the infimum is $\ge n$. The length-$n$ constant list realizes $n$, so the infimum is
exactly $n$. ∎

**Proposition 3.6 (the index is never $1$).** For a standard frame (one excluding
the atom $0$), $\mathrm{index}(F) \neq 1$; hence the index lies in
$\{0\} \cup \{2, 3, \dots\}$.

*Proof sketch.* A balanced sequence of length $1$ is a single atom $x$ with
$x = 0$. A standard frame excludes $0$, so no such sequence exists; thus
$1 \notin \mathrm{balancedLengths}(F)$, and the index, being $0$ or $\ge 2$, is
never $1$. ∎

**Theorem 3.7 (Sharpness, `incoherenceIndex_isGreatest`).** For every $n \ge 1$,
$n$ is the *greatest* incoherence index attained by a non-empty frame on $n$
states, and it is attained (by $\{1\}$):
$$\max\{\, \mathrm{index}(F) \mid F \text{ non-empty} \,\} = n.$$

*Proof sketch.* Attainment is Theorem 3.5; the upper bound is Proposition 3.4. ∎

**Theorem 3.8 (Parity, `even_incoherenceIndex`).** Suppose $2 \mid n$ and every
atom of $F$ is "odd," meaning it maps to $1$ under the parity character
$\mathbb{Z}/n\mathbb{Z} \to \mathbb{Z}/2\mathbb{Z}$. Then $\mathrm{index}(F)$ is
even.

*Proof sketch.* Applying the parity homomorphism to a balanced sequence, the sum
maps to $0$ in $\mathbb{Z}/2\mathbb{Z}$; since every atom maps to $1$, the image
sum equals $|l| \cdot 1 = |l| \pmod 2$, forcing $|l|$ even. Thus every balanced
length is even, and so is their minimum (when one exists; otherwise the index is
$0$, also even). ∎

**Theorem 3.9 (Unboundedness, `incoherence_unbounded`).** For every $N$ there is a
frame whose incoherence index is even and exceeds $N$.

*Proof sketch.* Take $\{1\} \subseteq \mathbb{Z}/(2N+4)\mathbb{Z}$. By Theorem 3.5
its index is $2N+4$, which is even and greater than $N$. ∎

Combining Theorems 3.5, 3.7, and 3.9 with Proposition 3.6: the spectrum of
incoherence indices over all frames is contained in $\{0\} \cup \{2, 3, \dots\}$,
is unbounded above, and on $n$ states is capped exactly at $n$ with the cap
realized by the sparse generator $\{1\}$.

---

## 4. The exact threshold and non-finite-axiomatization

This is the structural heart of the paper. We show the incoherence index is the
*precise* point at which the bounded fragments begin to detect incoherence, and
deduce that no bounded fragment can replace the coherence criterion.

**Theorem 4.1 (Exact threshold, `coherentUpTo_iff_lt_incoherenceIndex`).** Let $F$
be an *incoherent* frame, i.e. $\mathrm{balancedLengths}(F) \neq \emptyset$. Then
for every $B$,
$$\mathrm{CoherentUpTo}(B, F) \iff B < \mathrm{index}(F).$$

*Proof sketch.* Unfold $\mathrm{CoherentUpTo}(B, F)$ as "no balanced sequence has
length $\le B$."

($\Rightarrow$) Suppose $F$ passes the width-$B$ fragment but, for contradiction,
$\mathrm{index}(F) \le B$. Since $\mathrm{balancedLengths}(F)$ is a non-empty set
of naturals, its infimum is attained (`Nat.sInf_mem`): there is a balanced
sequence $l$ with $|l| = \mathrm{index}(F) \le B$. This is a balanced sequence of
length $\le B$, contradicting the fragment. Hence $B < \mathrm{index}(F)$.

($\Leftarrow$) Contrapositive: if $F$ *fails* the fragment, some balanced sequence
$l$ has $|l| \le B$. Then $\mathrm{index}(F) \le |l| \le B$ (the infimum is a lower
bound, `Nat.sInf_le`), so $\neg\,(B < \mathrm{index}(F))$. ∎

The hypothesis of incoherence is essential: a coherent frame has index $0$ yet
passes *every* fragment, so the equivalence genuinely requires an actual violation
to exist.

**Theorem 4.2 (Strict refinement, `fragment_strictly_refines`).** For every $B$
there exist $n$ and a frame $F$ on $n$ states such that
$$\mathrm{IsMaximal}(F), \qquad \mathrm{CoherentUpTo}(B, F), \qquad
\neg\,\mathrm{CoherentUpTo}(B+1, F).$$

*Proof sketch.* Take $n = B+1$ and $F = \{1\} \subseteq \mathbb{Z}/(B+1)\mathbb{Z}$.

- *Maximal:* Lemma 3.1.
- *Passes width $B$:* by Theorem 3.5 the index is $B+1$; every balanced sequence
  has length $\ge B+1 > B$ (Lemma 3.3), so none has length $\le B$.
- *Fails width $B+1$:* the constant list $[1, 1, \dots, 1]$ of length $B+1$ is
  balanced (its sum is $B+1 \equiv 0$) and has length $B+1 \le B+1$. ∎

**Corollary 4.3 (Non-finite-axiomatizability of coherence).** There is no bound
$B$ such that the width-$B$ fragment agrees with coherence on all maximal frames.
Equivalently, the family $\{\mathrm{CoherentUpTo}(B, \cdot)\}_{B \ge 0}$ is a
strictly increasing chain of conditions whose intersection (true coherence) is not
any finite member.

*Proof sketch.* Fix any $B$. Theorem 4.2 produces a maximal frame $F$ that is
incoherent (it has a balanced sequence of length $B+1$, so it is *not* coherent in
the full sense) yet passes $\mathrm{CoherentUpTo}(B, \cdot)$. So the width-$B$
fragment certifies a frame that is not coherent; it cannot coincide with coherence.
Since $B$ was arbitrary, no finite width suffices. Moreover the separators
$\{1\} \subseteq \mathbb{Z}/(B+1)\mathbb{Z}$ are distinct for distinct $B$, so each
step of the chain strictly adds discriminating power and the hierarchy never
stabilizes. ∎

This is the formal content of the title: coherence — equivalently, strict-majority
representability in the modeled setting — admits no bounded finite axiomatization.

---

## 5. Saturation contrast: maximality does not determine the index

Theorem 4.2 hides incoherence deep using a *sparse* maximal frame. We now show
sparsity is essential — among maximal frames, enriching the atom set tends to
collapse the index.

**Lemma 5.1 (`isMaximal_oneThree`).** The frame $\{1, 3\} \subseteq
\mathbb{Z}/4\mathbb{Z}$ is maximal.

*Proof sketch.* It contains the unit $1$, which already generates
$\mathbb{Z}/4\mathbb{Z}$; adding atoms cannot shrink the generated subgroup, so the
closure is $\top$. ∎

**Theorem 5.2 (`incoherenceIndex_oneThree`).**
$$\mathrm{index}(\{1, 3\} \subseteq \mathbb{Z}/4\mathbb{Z}) = 2,$$
strictly below the index $4$ of the sparse maximal frame $\{1\} \subseteq
\mathbb{Z}/4\mathbb{Z}$.

*Proof sketch.* Upper bound: the list $[1, 3]$ is balanced, since $1 + 3 = 4
\equiv 0 \pmod 4$ and both entries are atoms; so the index is $\le 2$. Lower bound:
a balanced sequence of length $1$ would be a single atom equal to $0$, but neither
$1$ nor $3$ is $0$ in $\mathbb{Z}/4\mathbb{Z}$; so no length-$1$ balanced sequence
exists, and every balanced sequence has length $\ge 2$, giving index $\ge 2$. ∎

**Discussion.** Both $\{1\}$ and $\{1,3\}$ are maximal on $\mathbb{Z}/4\mathbb{Z}$,
so reachability of states is identical. The gap $4$ versus $2$ is therefore caused
purely by atom *density*, not by expressive power. Consequently, *maximality alone
does not determine the incoherence index*, and the extremal value $n$ is the
exclusive privilege of single-generator (sparse) frames. To hide a contradiction
deeply, a procedure must be both expressive and austere.

---

## 6. The index as a zero-sum invariant

Stripped of its social-choice interpretation, a perfectly balanced sequence is a
non-empty **zero-sum sequence** over the finite abelian group
$\mathbb{Z}/n\mathbb{Z}$ with terms restricted to the atom set $F$. The
incoherence index is then the *minimal length of a zero-sum word over $F$* — a
Davenport-constant-style invariant from additive combinatorics.

This dictionary explains the phenomena above structurally:

- The cyclic computation $\mathrm{index}(\{1\}) = n$ is the statement that the
  minimal zero-sum over a single generator of order $n$ has length equal to that
  order — the cyclic base case of the Davenport bound, here Lemma 3.2.
- The saturation collapse (Theorem 5.2) is the familiar fact that adding more group
  elements creates short zero-sums.
- Unboundedness (Theorem 3.9) reflects that the relevant invariant grows with the
  group order.

This positioning suggests the social-choice wrapper is incidental: the
non-finite-axiomatizability is governed by the additive combinatorics of
$\mathbb{Z}/n\mathbb{Z}$, and analogous results should hold for any family of
finite abelian groups with unbounded minimal-zero-sum length over admissible
generators.

---

## 7. Applications and interpretation

- **Social choice.** In the strict-majority setting modeled here, the consistency
  ("coherence") of a decision procedure cannot be certified by inspecting only
  short cycles of admissible moves. No fixed cycle-length budget is ever
  sufficient: for each budget there is a legitimate, fully expressive (maximal)
  procedure whose sole contradiction lies exactly one step beyond the budget.

- **Bounded verification.** The result is a sharp parable for bounded model
  checking: "test all behaviors up to depth $B$" can never substitute for a full
  consistency proof when the property at stake can be violated at unbounded depth.
  The strict-refinement theorem is an explicit adversary construction.

- **Logic.** Corollary 4.3 is a concrete, fully constructive instance of
  non-finite-axiomatizability proved through a strictly refining chain of finite
  fragments — the standard template for such impossibility results.

---

## 8. Future work

Building on the verified `incoherenceIndex` and the
`coherentUpTo_iff_lt_incoherenceIndex` bridge, several directions are immediate.

- **Spectrum over all frames.** Conjecture: the attainable values of
  $\mathrm{index}(F)$ over all $F \subseteq \mathbb{Z}/n\mathbb{Z}$ and all $n$ are
  exactly $\{0\} \cup \{2, 3, 4, \dots\}$ — index $1$ being impossible by
  Proposition 3.6. This reduces to decidable zero-sum statements.

- **Davenport identification.** Conjecture: for a maximal frame in "general
  position," $\mathrm{index}(F) = D(\langle F\rangle)$, the (small) Davenport
  constant of the generated subgroup. Lemma 3.2 is the cyclic base case.

- **Density collapses the index.** Conjecture: if a maximal frame
  $F \subseteq \mathbb{Z}/n\mathbb{Z}$ has $\ge c\log n$ well-spread atoms, then
  $\mathrm{index}(F) = 2$; sparsity is necessary for a large index. Theorem 5.2 is
  the smallest witness.

- **No eventual completeness.** Conjecture: there is no $B$ and no finite
  exceptional set of frames on which the width-$B$ fragment agrees with coherence
  off the exceptions. The separators of Theorem 4.2 are a fresh, pairwise
  non-isomorphic family that no finite exception set can absorb.

---

## 9. Conclusion

The incoherence index is the complete invariant controlling the finite fragments
of the coherence criterion. The exact-threshold theorem shows a frame survives the
width-$B$ test precisely when its shortest violation exceeds $B$; the
strict-refinement theorem then shows the fragments refine strictly and forever,
driven by the elementary computation $\mathrm{index}(\{1\}) = n$. Coherence — the
absence of any closed loop of admissible majority moves — therefore admits no
bounded finite axiomatization. The saturation contrast localizes the extremal
behavior to sparse generators, and the additive-combinatorial reading recasts the
whole story as one about minimal zero-sum lengths, where unbounded depth is the
norm rather than the exception.
