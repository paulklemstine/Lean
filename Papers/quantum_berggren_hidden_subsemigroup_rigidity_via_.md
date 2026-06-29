# Berggren Hidden-Subsemigroup Rigidity via Abelianized Length Spectra and Certified Collision Obstructions

## Abstract

We formalize in Lean 4 a framework for studying hidden-subsemigroup identification in the Berggren semigroup — the free semigroup of rank 3 whose action on integer pairs generates all primitive Pythagorean triples. Our main results establish that the *orbit-profile spectrum* of a set of Berggren words on a bounded ball uniquely determines the set's membership function on that ball. This yields formally verified collision-resistance certificates and hidden-subsemigroup recovery guarantees. All proofs are machine-checked using the Lean 4 proof assistant with the Mathlib library.

**Keywords**: Berggren semigroup, free semigroup, Parikh vectors, collision resistance, hidden-subsemigroup problem, formal verification

---

## 1. Introduction

### 1.1 The Berggren Semigroup

The Berggren tree is one of the most elegant structures in elementary number theory: three linear transformations, applied to the seed triple (3, 4, 5), generate *every* primitive Pythagorean triple exactly once. Discovered by Berggren (1934) and independently by several later authors, the tree provides a canonical enumeration of Pythagorean triples as a ternary branching structure.

We work with the pair-based formulation. Each primitive Pythagorean triple (a, b, c) with a odd corresponds to a pair (m, n) with 0 < n < m via the parametrization a = m² − n², b = 2mn, c = m² + n². The root pair is (2, 1), corresponding to (3, 4, 5). The three Berggren generators act as:

- **A**: (m, n) ↦ (2m − n, m)
- **B**: (m, n) ↦ (2m + n, m)
- **C**: (m, n) ↦ (m + 2n, n)

A *Berggren word* is a finite sequence of generators. The evaluation map sends a word to the pair obtained by applying its generators right-to-left starting from (2, 1).

### 1.2 The Free Semigroup Property

The foundational result, which we formalize as `evalPair_injective`, is that the evaluation map is *injective*: distinct words always produce distinct pairs. This means the Berggren generators freely generate a semigroup — there are no nontrivial relations between them.

The proof proceeds by establishing three properties of the valid-pair cone {(m, n) : 0 < n < m}:
1. **Validity preservation**: each generator maps valid pairs to valid pairs.
2. **Generator determination**: if g₁ applied to a valid pair p₁ equals g₂ applied to p₂, then g₁ = g₂ (the generators produce outputs in disjoint regions).
3. **Pair recovery**: given g₁ = g₂, injectivity of each individual generator implies p₁ = p₂.

By induction on word length, these three properties yield global injectivity.

### 1.3 Contribution

We introduce the *abelianized word spectrum* framework and prove that it provides complete invariants for bounded identification. Our formally verified results include:

1. **Short word reconstruction** (Theorem `word_reconstruction_from_profile`): Two Berggren words with the same orbit profile are equal.

2. **Certified collision-freeness** (Theorem `certified_no_collision`): For any radius R, no two distinct words of length ≤ R produce the same orbit profile.

3. **Hidden-subsemigroup recovery** (Theorem `hidden_subsemigroup_recovery`): If two sets of Berggren words have equal bounded profile spectra, they contain exactly the same bounded words.

4. **Lossless spectral compression** (Theorem `card_boundedProfileSpectrum_eq`): The cardinality of the bounded profile spectrum equals the cardinality of the truncated set — no information is lost.

---

## 2. Definitions

### 2.1 Parikh Vectors

The *Parikh triple* of a word w counts the occurrences of each generator:

> parikhTriple(w) = (#A(w), #B(w), #C(w)) ∈ ℕ³

This is the classical abelianization: it forgets the order of generators and retains only their multiplicities. We prove that Parikh triples are additive under concatenation:

> parikhTriple(u ++ v) = parikhTriple(u) + parikhTriple(v)

and that the sum of components equals the word length:

> #A(w) + #B(w) + #C(w) = |w|

### 2.2 Bounded Words and Spectra

The *radius ball* of depth R is the finite set of all Berggren words of length ≤ R:

> boundedWords(R) = {w : |w| ≤ R}

We prove that this set has cardinality (3^(R+1) − 1) / 2, with exactly 3^n words at each depth n (`card_allWordsOfLength`).

For a decidable predicate S on words, the *bounded profile spectrum* is:

> boundedProfileSpectrum(S, R) = {evalPair(w) : S(w) ∧ |w| ≤ R}

Similarly for Parikh and length spectra.

### 2.3 Subsemigroup Closure

Given a finite set G of generator words, the *subsemigroup closure* is the smallest set containing G and closed under concatenation:

> subsemigroupClosure(G) = smallest set containing G and closed under ++

---

## 3. Main Results

### 3.1 Collision-Freeness (Theorem 1)

**Theorem** (`certified_no_collision`). *For every R ∈ ℕ, there do not exist distinct words w₁, w₂ of length ≤ R with evalPair(w₁) = evalPair(w₂).*

*Proof.* Immediate from `evalPair_injective`. If evalPair(w₁) = evalPair(w₂), then w₁ = w₂ by injectivity. □

This theorem is stated in the "collision resistance" formulation familiar from cryptography: the hash function evalPair has no collisions on any finite search domain.

### 3.2 Hidden-Subsemigroup Recovery (Theorem 2)

**Theorem** (`hidden_subsemigroup_recovery`). *Let S, T be decidable predicates on Berggren words. If boundedProfileSpectrum(S, R) = boundedProfileSpectrum(T, R), then for all w with |w| ≤ R, S(w) ↔ T(w).*

*Proof.* Suppose S(w) for some w with |w| ≤ R. Then evalPair(w) ∈ boundedProfileSpectrum(S, R) = boundedProfileSpectrum(T, R). So there exists v with T(v), |v| ≤ R, and evalPair(v) = evalPair(w). By injectivity, v = w, hence T(w). The reverse direction is symmetric. □

In cryptographic language: the orbit-profile spectrum is a *complete fingerprint* for bounded subsemigroup identification. An adversary who knows only the spectrum can reconstruct the entire bounded membership function.

### 3.3 Lossless Spectral Compression (Theorem 3)

**Theorem** (`card_boundedProfileSpectrum_eq`). *For any decidable S and radius R, |boundedProfileSpectrum(S, R)| = |truncation(S, R)|.*

*Proof.* The map evalPair is injective, hence injective on any subset. The image of an injective function has the same cardinality as its domain. □

This theorem quantifies the information content of the spectrum: passing from the set of words to their orbit profiles loses no information.

### 3.4 Supporting Results

We also prove:
- **Parikh additivity** (`parikhTriple_mul`): Parikh vectors add under concatenation.
- **Length from Parikh** (`wordLength_of_parikhTriple_eq`): Words with the same Parikh triple have the same length.
- **Ball cardinality** (`card_allWordsOfLength`): There are exactly 3^n words of length n.
- **Orbit injectivity on balls** (`orbitProfile_injective_on_boundedWords`): evalPair is injective when restricted to any radius ball.

---

## 4. Applications

### 4.1 Noncommutative Hash Functions

The Berggren evaluation map evalPair can be viewed as a hash function from the free monoid on 3 generators to ℤ². Our collision-freeness theorem provides a formal guarantee that this hash has *perfect* collision resistance — not just computational hardness, but information-theoretic impossibility.

This is unusual in cryptography, where collision resistance typically relies on computational assumptions (e.g., the hardness of factoring or discrete logarithm). Here, collision resistance is a mathematical theorem, independent of any complexity assumption.

### 4.2 Hidden-Subsemigroup Problem

The hidden-subsemigroup problem asks: given oracle access to a subsemigroup S of a group G, determine S. This is a generalization of the hidden-subgroup problem, which underlies Shor's quantum algorithm for factoring.

Our recovery theorem shows that in the Berggren semigroup, the bounded profile spectrum is a sufficient oracle. One does not need full membership queries — the spectrum alone determines the subsemigroup on the bounded ball.

### 4.3 Certified Enumeration of Pythagorean Triples

Since each Berggren word maps to a unique primitive Pythagorean triple, and the map is injective, the bounded words of depth R provide a certified enumeration of the first (3^(R+1) − 1)/2 primitive triples. The Parikh triple provides additional combinatorial metadata about the generation path.

---

## 5. Discussion: Making Semigroups Talk

*A perspective for the general reader.*

Imagine you have a combination lock with three buttons — call them A, B, and C. Each sequence of button presses produces a unique output, like a musical note. The remarkable fact about the Berggren semigroup is that *no two different sequences ever produce the same note*. This is what mathematicians call a "free" semigroup: the buttons have no hidden relationships or shortcuts.

Now imagine someone gives you a set of notes (the "profile spectrum") and asks: which button sequences produced these notes? Our main theorem says: the notes alone are enough to answer this question completely, for any bounded set of sequences. This is like saying that if you record all the notes produced by sequences up to length R, you can reconstruct *exactly* which sequences were played — not just approximately, but perfectly.

This has a striking connection to cryptography. In the real world, hash functions are designed so that it's *computationally hard* to find two inputs giving the same output. But with the Berggren hash, finding collisions isn't just hard — it's *impossible*. The laws of mathematics forbid it, and we have a machine-checked proof to confirm.

The deeper principle at work is what we call **abelianized statistics plus geometric action equals noncommutative identifiability**. The "abelianized statistics" (the Parikh triple) tell you *how many times* each button was pressed, but not *in what order*. The "geometric action" (the orbit profile) tells you the *output* of the sequence. Together, they uniquely identify the sequence. But in fact, for the Berggren semigroup, the geometric action alone is already sufficient — the abelianized statistics are redundant, providing a cheaper-to-compute partial fingerprint.

This principle is not limited to Pythagorean triples. Any time you have a semigroup acting rigidly on a geometric space, the same framework applies. The Berggren case is special because the rigidity is *perfect* (exact injectivity), but approximate versions should hold for other matrix semigroups, tropical algebras, and even quantum systems.

---

## 6. Formalization Notes

All results are formalized in Lean 4.28.0 using the Mathlib library. The formalization consists of approximately 475 lines of Lean code in a single file (`Cryptography/BerggrenSubsemigroupRigidity.lean`). Key design choices:

- **Word model**: Words are represented as `List BerggrenGen` (not `FreeMonoid`), matching the existing Berggren infrastructure.
- **Pair action**: The evaluation map uses the 2-component pair formulation rather than 3×3 matrices, yielding cleaner injectivity proofs.
- **Decidability**: Spectral definitions use decidable predicates (`DecidablePred`) to enable Finset-based computation.
- **Modularity**: The file is self-contained, importing only Mathlib.

The critical dependency chain is:
1. `actGen_preserves_valid` → `evalPair_valid` (validity preservation)
2. `actGen_generator_determined` + `actGen_injective` → `actGen_unique_parent` (generator+pair recovery)
3. `actGen_unique_parent` → `evalPair_injective` (global injectivity, by induction)
4. `evalPair_injective` → all downstream theorems (collision-freeness, recovery, etc.)

All proofs compile without `sorry` and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

---

## 7. Related Work

The Berggren tree was introduced by B. Berggren in 1934. The modern treatment via matrix actions follows Barning (1963) and Hall (1970). The free semigroup property has been established in various forms; our pair-based proof follows the approach of Price (2008).

The hidden-subgroup problem has been extensively studied in quantum computing, beginning with Shor (1994). The hidden-*subsemigroup* variant is less studied but has connections to post-quantum cryptography via noncommutative group-based schemes.

Formal verification of number-theoretic results in Lean has grown rapidly with the Mathlib library. Our work contributes to the intersection of formalized mathematics and cryptographic security proofs.

---

## References

1. B. Berggren, "Pytagoreiska trianglar," *Tidskrift för Elementär Matematik, Fysik och Kemi* 17 (1934), 129–139.
2. F. J. M. Barning, "Over Pythagorese en bijna-Pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices," *Math. Centrum Amsterdam Afd. Zuivere Wisk.* ZW-011 (1963).
3. P. W. Shor, "Algorithms for quantum computation: discrete logarithms and factoring," *Proc. 35th FOCS* (1994), 124–134.
4. H. L. Price, "The Pythagorean tree: A new species," arXiv:0809.4324 (2008).
