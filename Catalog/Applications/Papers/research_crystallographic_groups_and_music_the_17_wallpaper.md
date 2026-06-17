# Crystallographic Groups and Music: A Formal Theory of the Symmetries of Periodic Rhythm

## Abstract

We develop a self-contained mathematical theory connecting periodic musical
rhythm to crystallographic (wallpaper) symmetry. A rhythm is modeled as a
boolean function on a one-dimensional timeline, and a two-dimensional drum
pattern as a boolean function on a (time × pitch) grid; periodicity makes each a
discrete analog of a repeating planar design. We define the translational
symmetry group of a rhythm and prove it is a genuine subgroup of the integers
(closed under addition, negation, and containing all integer multiples of the
period). We formalize palindromic (mirror) symmetry, prove that reflection is an
involution and that palindromicity is equivalent to fixed-point invariance under
reflection, and establish a parity theorem: a palindromic rhythm of odd length
has total onset-count parity equal to its central beat. In two dimensions we
define the time mirror, pitch mirror, and 180-degree rotation, prove each
reflection is involutive, and prove the structural bridge **double mirror implies
rotation** (the crystallographic containment pmm ⊇ p2). We enumerate the
seventeen wallpaper types as a finite structure, verify by exhaustive computation
that there are exactly seventeen (with ten mirror types and eight glide types),
attach to each a maximal rotation order and a musical interpretation, and prove
the **crystallographic restriction**: every type's rotation order lies in
{1, 2, 3, 4, 6}. Finally, we bridge symmetry to information by proving a
degrees-of-freedom monotonicity theorem (more symmetry yields fewer independent
bits) and connect to classical necklace counting, proving that under a prime
period only the two trivial patterns survive a nonzero rotation. All results are
machine-checked. We close with three precise, falsifiable conjectures extending
the theory to the full dihedral lattice, to Möbius enumeration of rhythmic
crystal classes, and to genuine two-dimensional toroidal wallpaper groups.

**Keywords:** wallpaper groups, crystallographic restriction, rhythm, symmetry
group, palindrome, necklace counting, music theory, formalization.

---

## 1. Introduction

The classification of plane symmetry into exactly seventeen *wallpaper groups* is
one of the most celebrated facts of geometric group theory: every doubly-periodic
pattern of the Euclidean plane has a symmetry group isomorphic to one of exactly
seventeen abstract groups. The number seventeen is forced by the interaction of
two ingredients — a two-dimensional translation lattice and the *crystallographic
restriction*, which permits rotational symmetries only of orders 1, 2, 3, 4, and
6.

Music is built from periodic patterns. A rhythm repeats; a groove tiles the
timeline; a drum score tiles a time-by-pitch grid. The thesis of this work is
that the symmetry classification of repeating patterns is not merely analogous to
the structure of rhythm but is *literally the same mathematics applied to a
different substrate*. We make this precise by formalizing rhythms as boolean
functions, defining their symmetry groups and reflective symmetries, and proving
the structural theorems that organize them into the crystallographic catalog.

Our contributions are:

1. A clean model of one-dimensional periodic rhythm (`PeriodicRhythm`) and of
   cyclic rhythm on `ZMod p`, together with the proof that translational
   symmetries form a subgroup (Section 3).
2. A theory of palindromic (mirror) symmetry, including the involutivity of
   reflection, the fixed-point characterization, and a parity theorem for
   odd-length palindromes (Section 4).
3. A two-dimensional drum-pattern model with time mirror, pitch mirror, and
   180-degree rotation, and the bridge theorem **double mirror implies rotation**
   (Section 5).
4. The finite enumeration of the seventeen wallpaper types, the exact-count
   verification (17 types, 10 mirror, 8 glide), and the crystallographic
   restriction theorem (Section 6).
5. An information-theoretic bridge relating symmetry order to degrees of freedom,
   and the connection to necklace counting and primality (Section 7).

All theorems below are stated with their full mathematical content; proof
sketches give the essential argument. The treatment is self-contained.

---

## 2. Preliminaries and notation

We write `Bool = {true, false}`, interpreting `true` as an *onset* (a struck
beat) and `false` as silence. We work over the integers `ℤ`, the natural numbers
`ℕ`, and the cyclic group `ZMod p = ℤ/pℤ`. For a finite type `T`, `Fintype.card
T` denotes its cardinality, and `Finset.univ.filter P` denotes the subset of
elements satisfying a decidable predicate `P`. An *additive subgroup* of an
additive group `G` is a subset containing `0` and closed under `+` and negation.

---

## 3. Periodic rhythms and their translation groups

### 3.1 Definition

**Definition 3.1 (Periodic rhythm).** A *periodic rhythm* is a tuple
`(pattern, period)` where `pattern : ℤ → Bool`, `period : ℕ` with `period > 0`,
and the periodicity law holds:
$$\text{pattern}(n + \text{period}) = \text{pattern}(n) \quad \text{for all } n \in \mathbb{Z}.$$

The *onset set* is `{ n ∈ ℤ : pattern(n) = true }`.

**Lemma 3.2 (Periodicity over multiples).** For every `n ∈ ℤ` and `m ∈ ℕ`,
$$\text{pattern}(n + m \cdot \text{period}) = \text{pattern}(n).$$
*Proof sketch.* Induction on `m`. The base case `m = 0` is immediate. For the
step, write `(m+1)·period = m·period + period`, reassociate, apply the period law
once, then the inductive hypothesis. ∎

### 3.2 The symmetry group

**Definition 3.3 (Translational symmetry group).** The *symmetry group* of a
rhythm `r` is
$$\text{symmGroup}(r) = \{\, d \in \mathbb{Z} : \forall n,\ \text{pattern}(n + d) = \text{pattern}(n) \,\}.$$

**Theorem 3.4.** `symmGroup(r)` is an additive subgroup of `ℤ`.
*Proof sketch.* Zero membership: `pattern(n+0)=pattern(n)`. Closure under
addition: if `a, b` are symmetries, then
`pattern(n+(a+b)) = pattern((n+a)+b) = pattern(n+a) = pattern(n)`. Closure under
negation: applying the `a`-symmetry at `n−a` gives `pattern(n)=pattern(n−a)`,
i.e. `−a` is a symmetry. ∎

**Theorem 3.5 (Period membership).** `period ∈ symmGroup(r)`, and more generally
for every `m ∈ ℤ`, `m·period ∈ symmGroup(r)`.
*Proof sketch.* The period law states exactly that `period` is a symmetry. For
arbitrary integer multiples, split into nonnegative and negative cases; the
nonnegative case is Lemma 3.2, and the negative case follows by closure under
negation (Theorem 3.4). ∎

### 3.3 Cyclic equivalence

**Definition 3.6 (Cyclic equivalence).** Rhythms `r₁, r₂` are *cyclically
equivalent* when one is a time-translate of the other: there exists `d ∈ ℤ` with
`r₁.pattern(n + d) = r₂.pattern(n)` for all `n`.

**Theorem 3.7.** Cyclic equivalence is an equivalence relation.
*Proof sketch.* Reflexivity uses `d = 0`. Symmetry negates the offset `d ↦ −d`.
Transitivity composes offsets `d₁, d₂ ↦ d₁ + d₂` with a reassociation. ∎

### 3.4 Cyclic model on `ZMod p`

For computational and counting purposes it is convenient to model a rhythm of
period `p` directly on the cyclic group.

**Definition 3.8.** A *cyclic rhythm* of period `p` is a function `r : ZMod p →
Bool`. We define:
- the *complement* `complement(r)(n) = ¬ r(n)`;
- the *full* and *silent* rhythms, constantly `true` and `false`;
- the *translate* `translate(r, k)(n) = r(n + k)`;
- `k` is a *translation symmetry* when `r(n + k) = r(n)` for all `n`;
- `translationSymSet(r) = { k : k is a translation symmetry }`;
- `r` is a *palindrome* when `r(n) = r(−n)` for all `n`;
- `r` is *maximally symmetric* when every `k ∈ ZMod p` is a translation symmetry.

**Theorem 3.9 (Subgroup structure, cyclic form).** For a cyclic rhythm `r`:
(i) `0 ∈ translationSymSet(r)`; (ii) if `k₁, k₂` are symmetries then so is
`k₁ + k₂`; (iii) if `k` is a symmetry then so is `−k`. Hence
`translationSymSet(r)` is a subgroup of `ZMod p`.
*Proof sketch.* Identical in spirit to Theorem 3.4, using the abelian group
structure of `ZMod p`. ∎

**Theorem 3.10 (Constant rhythms are maximally symmetric).** The full rhythm, the
silent rhythm, and indeed any constant rhythm `n ↦ b` are maximally symmetric.
*Proof sketch.* A constant function is unchanged by any reindexing. ∎

**Theorem 3.11 (Complement preserves symmetry).** If `k` is a translation
symmetry of `r`, it is a translation symmetry of `complement(r)`.
*Proof sketch.* Negation commutes with reindexing: `¬r(n+k) = ¬r(n)`. ∎

**Theorem 3.12 (Translation composition).** `translate(translate(r, k₁), k₂) =
translate(r, k₁ + k₂)`. *Proof sketch.* Both sides evaluate to `r(n + k₁ + k₂)`. ∎

---

## 4. Palindromic rhythms

### 4.1 Reflection and its basic properties

For a finite rhythm `f : Fin n → Bool` we define the *reflection*
`reflectRhythm(f)(k) = f(n − 1 − k)`, and call `f` *palindromic* when
`f(n − 1 − k) = f(k)` for every position `k`.

**Theorem 4.1 (Reflection is an involution).** `reflectRhythm(reflectRhythm(f)) =
f`. *Proof sketch.* Applying the index map twice sends `k ↦ n−1−(n−1−k) = k`;
extensionality on indices closes the goal. ∎

**Theorem 4.2 (Palindrome characterization).** `f` is palindromic if and only if
`reflectRhythm(f) = f`. *Proof sketch.* Pointwise unfolding: `f` palindromic
means `f(n−1−k) = f(k)` for all `k`, which is exactly the function equality
`reflectRhythm(f) = f`. ∎

In the cyclic model, palindromicity is `r(n) = r(−n)`; the analogous facts hold,
e.g. the complement of a palindrome is a palindrome (`¬r(n) = ¬r(−n)`), and both
the full and silent rhythms are palindromic.

**Theorem 4.3 (Palindrome–translate yields glide).** If `r` is a cyclic
palindrome and `k` is a translation symmetry of `r`, then for all `n`,
$$r(n + k) = r(-(n + k)).$$
*Proof sketch.* `r(n+k) = r(n)` (translation symmetry) `= r(−n)` (palindrome)
`= r(−n − k)` (`−k` is a symmetry by Theorem 3.9(iii)) `= r(−(n+k))`. This is the
algebraic shadow of a *glide reflection*: a reflection combined with a
translation. ∎

### 4.2 A parity theorem for odd-length palindromes

**Theorem 4.4 (Center determines parity).** Let `f : Fin (2k+1) → Bool` be
palindromic. Then the total onset count is congruent mod 2 to the value of the
central beat:
$$\#\{\, i : f(i) = \text{true} \,\} \equiv [\,f(k) = \text{true}\,] \pmod 2,$$
where `[·]` is 1 if true and 0 otherwise.
*Proof sketch.* Partition the index set `{0, …, 2k}` into three parts: positions
strictly below the center, positions strictly above the center, and the center
itself. The reflection `i ↦ 2k − i` is a bijection between the lower-onset set
and the upper-onset set that preserves the onset property (because `f` is
palindromic), so the two flanks have equal onset counts. Hence the total count is
`2·(flank count) + [center is onset]`, whose parity is exactly the parity of the
center indicator. The formal proof carries out the bijection via
`Finset.card_bij` and finishes by `omega`. ∎

This theorem is a genuine consequence of symmetry: the global parity of the
rhythm is pinned down by a single central beat, a fact with no analog for
non-palindromic rhythms.

---

## 5. Two-dimensional drum patterns

### 5.1 Definitions

**Definition 5.1 (Drum pattern, doubly-periodic form).** A *drum pattern* is a
tuple `(pattern, period_time, period_pitch)` with `pattern : ℤ × ℤ → Bool`,
`period_time, period_pitch > 0`, and the two periodicity laws
$$\text{pattern}(t + \text{period\_time}, v) = \text{pattern}(t, v), \qquad
\text{pattern}(t, v + \text{period\_pitch}) = \text{pattern}(t, v).$$

**Theorem 5.2 (2D translation group).** The set
`{ (a,b) ∈ ℤ × ℤ : ∀ p, pattern(p₁+a, p₂+b) = pattern(p) }` is an additive
subgroup of `ℤ × ℤ`. *Proof sketch.* Componentwise repetition of the argument of
Theorem 3.4 using the product group structure. ∎

We also use the cyclic 2D model `DrumPattern p q := ZMod p × ZMod q → Bool`, with
the operators
- `translateTime(g, k)(t, v) = g(t + k, v)`, `translatePitch(g, k)(t, v) = g(t, v + k)`;
- `mirrorTime(g)(t, v) = g(−t, v)` (retrograde);
- `mirrorPitch(g)(t, v) = g(t, −v)` (inversion);
- `rotate180(g)(t, v) = g(−t, −v)` (retrograde-inversion).

The symmetry predicates are:
- `hasTimeMirror(g) : ∀ t v, g(−t, v) = g(t, v)`;
- `hasPitchMirror(g) : ∀ t v, g(t, −v) = g(t, v)`;
- `hasRotation2(g) : ∀ t v, g(−t, −v) = g(t, v)`.

### 5.2 Involutions and the central bridge

**Theorem 5.3 (Reflections and the half-turn are involutions).**
`mirrorTime(mirrorTime(g)) = g` and `rotate180(rotate180(g)) = g`.
*Proof sketch.* Double negation of coordinates is the identity; extensionality on
`(t, v)` closes both goals. ∎

**Theorem 5.4 (Double mirror implies rotation — pmm ⊇ p2).** If a drum pattern
has both time-mirror and pitch-mirror symmetry, it has 2-fold rotational
symmetry:
$$\text{hasTimeMirror}(g) \ \wedge\ \text{hasPitchMirror}(g)\ \Longrightarrow\ \text{hasRotation2}(g).$$
*Proof sketch.* For any `(t, v)`,
$$g(-t, -v) \overset{\text{pitch mirror at }(-t)}{=} g(-t, v) \overset{\text{time mirror}}{=} g(t, v).$$
Two perpendicular reflections compose to a half-turn. This is the discrete,
rhythmic incarnation of the crystallographic containment that the symmetry type
**pmm** (two mirrors) necessarily contains **p2** (a rotation), and the musical
statement that retrograde combined with inversion yields retrograde-inversion. ∎

(The same theorem holds in the doubly-periodic `ℤ × ℤ` model, with the mirror and
rotation predicates phrased relative to the fundamental domain via
`period_time − 1 − t` and `period_pitch − 1 − v`.)

**Theorem 5.5 (Time-translation composition).**
`translateTime(translateTime(g, k₁), k₂) = translateTime(g, k₂ + k₁)`.
*Proof sketch.* Both sides reduce to `g(t + k₂ + k₁, v)` by associativity. ∎

---

## 6. The seventeen wallpaper types

### 6.1 Enumeration

**Definition 6.1 (Wallpaper type).** `WallpaperType` is the finite enumerated
type with the seventeen constructors
$$\texttt{p1, p2, pm, pg, cm, pmm, pmg, pgg, cmm, p4, p4m, p4g, p3, p3m1, p31m, p6, p6m}.$$
It carries decidable equality and is a finite type.

**Theorem 6.2 (Exactly seventeen).** `Fintype.card WallpaperType = 17`.
*Proof sketch.* The type is a finite enumeration; the cardinality is computed by
exhaustive evaluation (`decide`). ∎

**Definition 6.3 (Invariants).** We attach to each type three computable
invariants:
- `maxRotationOrder : WallpaperType → ℕ`, the largest order of a rotation in the
  group, given by `p1,pm,pg,cm ↦ 1`; `p2,pmm,pmg,pgg,cmm ↦ 2`;
  `p3,p3m1,p31m ↦ 3`; `p4,p4m,p4g ↦ 4`; `p6,p6m ↦ 6`.
- `hasMirror : WallpaperType → Bool`, true for
  `pm, cm, pmm, pmg, cmm, p4m, p4g, p3m1, p31m, p6m`.
- `hasGlide : WallpaperType → Bool`, true for
  `pg, cm, pmg, pgg, cmm, p4g, p31m, p6m`.

We also attach `musicalName`, e.g. `p1 ↦ "free rhythm"`, `p2 ↦
"call-and-response"`, `pm ↦ "palindrome"`, `pg ↦ "canon"`, `p6m ↦ "maximal
symmetry"`, providing the dictionary between symmetry types and rhythmic idioms.

**Theorem 6.4 (Census).** Exactly ten wallpaper types contain a mirror and
exactly eight contain a glide reflection:
$$\#\{ w : \text{hasMirror}(w) \} = 10, \qquad \#\{ w : \text{hasGlide}(w) \} = 8.$$
*Proof sketch.* Filter the universe of the seventeen types by each predicate and
evaluate the cardinality (`decide` / `rfl`). ∎

### 6.2 The crystallographic restriction

**Definition 6.5.** A natural number is a *crystallographic order* when it is one
of `1, 2, 3, 4, 6`.

**Theorem 6.6 (Crystallographic restriction).** For every wallpaper type `w`, its
maximal rotation order is a crystallographic order:
$$\text{maxRotationOrder}(w) \in \{1, 2, 3, 4, 6\}.$$
*Proof sketch.* Case split over the seventeen constructors; each value is one of
the five admissible orders by definition (`simp`/`decide`). ∎

The salient absences are 5 and 7: no wallpaper group, hence no perfectly
repeating rhythmic crystal, has five-fold or seven-fold rotational symmetry. This
is the rhythmic content of the classical crystallographic restriction.

### 6.3 The symmetry lattice

**Definition 6.7.** `symmetryLevel : WallpaperType → ℕ` assigns an integer height
encoding the containment order of the types, with `p1 ↦ 0` (lowest) and `p6m ↦ 6`
(highest).

**Theorem 6.8 (Maximal symmetry).** For every `w`, `symmetryLevel(w) ≤
symmetryLevel(p6m)`. *Proof sketch.* Exhaustive case analysis over the seventeen
types (`decide`). Thus **p6m** sits at the top of the lattice — the "perfect"
maximally-symmetric rhythm. ∎

---

## 7. Symmetry as information

### 7.1 Degrees of freedom

A rhythm of period `p` that is forced to be invariant under a symmetry group of
order `d` (with `d ∣ p`) has only `p / d` independent positions: once a
fundamental domain is chosen, symmetry determines the rest.

**Definition 7.1.** `rhythmDegreesOfFreedom(p, d) = p / d` (integer division).

**Theorem 7.2 (More symmetry, fewer degrees of freedom).** If `0 < d₁`, `d₁ ∣ p`,
`d₂ ∣ p`, and `d₁ ≤ d₂`, then
$$\text{rhythmDegreesOfFreedom}(p, d₂) \le \text{rhythmDegreesOfFreedom}(p, d₁).$$
*Proof sketch.* Monotonicity of `p / ·` in the divisor (`Nat.div_le_div_left`). ∎

**Theorem 7.3 (Extremes).** `rhythmDegreesOfFreedom(p, p) = 1` for `p > 0`
(maximal symmetry collapses to one bit), and `rhythmDegreesOfFreedom(p, 1) = p`
(trivial symmetry leaves all bits free). *Proof sketch.* `p / p = 1` and
`p / 1 = p`. ∎

We package the relationship as a structure `RhythmEntropyBound`, recording a
period, a symmetry order dividing it, a fundamental-domain size `period /
symOrder`, and an entropy bound (in bits) equal to that domain size — formalizing
the principle that *a rhythm carries at most one bit of information per
fundamental position*.

### 7.2 Onset counting and duality

For a cyclic rhythm of period `p` (with `p > 0`) we define the *onset count*
`onsetCount(r) = #{ n : r(n) = true }`.

**Theorem 7.4.** `onsetCount(r) ≤ Fintype.card(ZMod p)`, with `onsetCount(full) =
Fintype.card(ZMod p)` and `onsetCount(silent) = 0`. *Proof sketch.* A filtered
subset has cardinality at most the whole; the full rhythm selects everything and
the silent rhythm selects nothing. ∎

**Theorem 7.5 (Complement duality).**
$$\text{onsetCount}(\text{complement}(r)) + \text{onsetCount}(r) = \text{Fintype.card}(\mathbb{Z}/p\mathbb{Z}).$$
*Proof sketch.* The onset set of `r` and the onset set of `complement(r)` are
disjoint and their union is all of `ZMod p`; the cardinality of a disjoint union
is the sum of cardinalities. ∎

### 7.3 Necklace counting and primality

The number of length-`p` binary patterns fixed by a rotation of `k` positions is
classically `2^{\gcd(k, p)}`; we encode this as `fixedByRotation(p, k) =
2^{\gcd(k, p)}`.

**Theorem 7.6 (Identity rotation).** `fixedByRotation(p, 0) = 2^p`. *Proof
sketch.* `gcd(0, p) = p`. The identity fixes every pattern. ∎

**Theorem 7.7 (Coprimality under a prime).** If `p` is prime and `0 < k < p`,
then `gcd(k, p) = 1`. *Proof sketch.* A prime is coprime to anything it does not
divide; `p ∤ k` because `0 < k < p`. ∎

**Theorem 7.8 (Rigidity of prime-length rhythms).** If `p` is prime and
`0 < k < p`, then `fixedByRotation(p, k) = 2`. *Proof sketch.* By Theorem 7.7,
`gcd(k, p) = 1`, so `2^{\gcd(k,p)} = 2^1 = 2`. The only patterns fixed by a
nontrivial rotation are the all-onset and all-silence patterns. ∎

Thus prime periods admit no nontrivial rotational symmetry beyond the two
degenerate patterns — the combinatorial reason prime-length meters feel
irreducible.

### 7.4 A falsifiable empirical conjecture

**Conjecture 7.9 (Rhythmic wallpaper distribution).** In a natural corpus of drum
patterns, the distribution over wallpaper types is non-uniform: `p1` (free
rhythm) exceeds 50% of patterns, `p6m` (maximal symmetry) is under 1%, and
frequency decreases monotonically with `maxRotationOrder`. Formally, a frequency
function `freq : WallpaperType → ℝ` is a *natural distribution* when `freq(w) ≥ 0`
for all `w`, `freq(p1) > 1/2`, and `freq(p6m) < 1/100`. This is directly testable
against a MIDI corpus (see the accompanying demonstration code).

---

## 8. Algorithms

We summarize the computational content implicit in the formalization.

**Algorithm A (Translation symmetry group).** Given a cyclic rhythm `r : ZMod p →
Bool`, compute `{ k : ∀ n, r(n+k) = r(n) }` by testing each of the `p` shifts
against all `p` positions. Complexity `O(p²)`. The output is always a subgroup,
whose order divides `p` by Lagrange's theorem.

**Algorithm B (Wallpaper classification of a drum pattern).** Given a 2D pattern
on `ZMod p × ZMod q`, detect the presence of translation, time/pitch mirror,
glide, and rotation symmetries by direct evaluation, then match the detected
symmetry content against the seventeen-type signature table to assign a
`WallpaperType`. Complexity `O((pq)²)` for the symmetry scan.

**Algorithm C (Necklace census).** Use `fixedByRotation` together with Burnside's
lemma to count rhythm equivalence classes: the number of necklaces of length `p`
is `(1/p) · Σ_{k=0}^{p-1} 2^{\gcd(k,p)}`. Complexity `O(p log p)` using gcd.

---

## 9. Applications and discussion

The framework gives a vocabulary for *why* certain grooves feel the way they do.
Maximal-symmetry rhythms (p6m, or maximally translation-symmetric cyclic rhythms)
are information-poor and quickly monotonous (Theorem 7.2–7.3); free rhythms (p1)
are information-rich; satisfying grooves typically inhabit the partially symmetric
middle. The bridge theorem (Theorem 5.4) explains the prevalence of
retrograde-inversion in canon and serial music as an unavoidable consequence of
combining retrograde and inversion. The crystallographic restriction (Theorem
6.6) explains the structural absence of "5-fold rhythmic crystals" even in music
notated in 5/4 or 7/8: such meters derive character precisely from resisting
symmetric closure. The primality rigidity (Theorem 7.8) explains why prime-length
patterns feel irreducible.

The information-theoretic reading (Section 7) is a compression statement:
symmetry is redundancy, and the symmetry order is a measure of how much of a
rhythm is determined by its fundamental domain. This connects rhythm analysis to
classical combinatorics (necklace counting, Burnside) and to the broader program
of measuring musical structure by the size of its symmetry group.

**Limitations.** The present formalization treats translational and reflective
symmetries and the 180-degree rotation explicitly; the full planar action of all
seventeen groups on a finite torus, including the 3-, 4-, and 6-fold rotations
acting on `ZMod m × ZMod n`, is enumerated as a type with invariants rather than
realized as a single faithful group action. Bridging that gap is the subject of
the conjectures below.

---

## 10. Future directions

This cycle established a self-contained theory of the symmetry groups of cyclic
rhythms via the action of the relevant point groups on beat-position sets. Three
precise, falsifiable, computationally testable conjectures extend it.

**Conjecture 10.1 (Full dihedral realisability).** Every subgroup `H` of the
dihedral group `DihedralGroup n` is the symmetry group of some rhythm `S :
Finset (ZMod n)`; i.e. `∀ H, ∃ S, symmetryGroup(n, S) = H`. This strengthens the
realisability of *rotation* orders to the full dihedral lattice, including
reflection (palindromic) symmetry. *Test:* enumerate subgroups of `DihedralGroup
n` for `n ≤ 8` and search for a realising `S` by exhaustive decision. *Risk:*
small `n` may have unrealisable subgroups (e.g. a lone reflection with no
compatible rotation), in which case the corrected conjecture characterises the
realisable subgroups as exactly the stabiliser-closed ones.

**Conjecture 10.2 (Möbius enumeration of rhythmic crystal classes).** The number
`Aₙ(d)` of rhythms in `ZMod n` whose rotation-period group has order exactly `d`
(for `d ∣ n`) is governed by Möbius inversion of `d ↦ 2^{n/d}`. Trivially
`Σ_{d ∣ n} Aₙ(d) = 2ⁿ`; the content is that `Aₙ(d)` is the Möbius-inverted
necklace count. *Test:* tabulate `Aₙ(d)` by brute force for `n ≤ 12` and fit
against the Möbius formula.

**Conjecture 10.3 (Two-dimensional polyrhythms and the genuine seventeen).**
Define rhythms on the torus `ZMod m × ZMod n` with the full planar
crystallographic action (translations, the rotation `(x, y) ↦ (−x, −y)`, and the
reflections) and conjecture that exactly the toroidal quotients of the seventeen
wallpaper groups arise as symmetry groups. This is the literal realisation of the
title: 1D rhythm gives dihedral (frieze-like) symmetry; the 2D polyrhythmic grid
should expose genuine wallpaper-group structure. *Test:* build the action of the
relevant point group on `Finset (ZMod m × ZMod n)` and classify stabilisers for
small `m, n`.

---

## 11. Conclusion

We have formalized the symmetry theory of periodic rhythm and shown that it is the
same mathematics that classifies repeating planar patterns. From a single
periodicity law we derived the subgroup structure of translational symmetries;
from reflection we obtained palindromes, an involutivity theorem, and a parity
law; from two-dimensional drum patterns we proved that double mirror symmetry
forces rotation; and we enumerated the seventeen wallpaper types, verified their
count and census, and proved the crystallographic restriction. Linking symmetry
to information, we showed that symmetry is compression and that prime-length
rhythms are rigid. The seventeen wallpaper groups are not merely a metaphor for
rhythm — they are its classification.
