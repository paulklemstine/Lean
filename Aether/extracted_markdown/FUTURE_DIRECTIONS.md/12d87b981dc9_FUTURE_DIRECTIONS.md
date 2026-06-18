# Future Directions: Automatic Sequences, Decidability, and Beyond

## 1. Cobham's Theorem: The Multiplicative Independence Barrier

Cobham's theorem (1972) states that if a sequence is both j-automatic and k-automatic
where log j / log k is irrational (i.e., j and k are multiplicatively independent),
then the sequence is eventually periodic. This is one of the deepest results in
automatic sequence theory and remains challenging to formalize.

**The key insight is** that multiplicative independence forces the set of positions where
a given value appears to be a "sparse" set that cannot simultaneously be recognized by
two automata with incompatible bases — unless it is ultimately periodic (a trivial case
recognized by all bases). The proof uses a delicate pigeonhole argument on the
representations of large integers in two different bases.

**Why now?** Our formalization of k-automatic sequences with Boolean closure and the
Nerode bridge provides the algebraic infrastructure needed for Cobham's theorem. The
key missing piece is the number-theoretic lemma about base representations, which could
be attacked using Mathlib's extensive `Nat.digits` API and the Skolem-Mahler-Lech theorem
machinery.

**Falsifiable test:** Formalize the contrapositive: if a non-periodic sequence is
k-automatic, construct an explicit word in the complement language that the j-automaton
must reject. Verify on Thue-Morse (2-automatic, not 3-automatic) by checking that
no 3-state DFAO over base 3 generates it.

---

## 2. Büchi-Bruyère Theorem: First-Order Decidability for Automatic Sequences

The Büchi-Bruyère theorem states that a subset S ⊆ ℕ is definable in the first-order
theory ⟨ℕ, +, Vₖ⟩ (where Vₖ(n) is the largest power of k dividing n) if and only if S
is k-recognizable (i.e., the characteristic function of S is k-automatic). This gives a
decision procedure for *any* first-order sentence about k-automatic sequences.

**The key insight is** that the logical operations (∧, ∨, ¬, ∃) correspond exactly to
the automata operations we have already formalized (product, union, complement,
projection). The existential quantifier ∃n corresponds to projecting out a track from
a multi-track automaton, which preserves regularity by the standard subset construction.

**Why now?** Our Boolean closure theorems (`kAutomatic_complement`, `kAutomatic_inter`,
`kAutomatic_union`) handle the propositional fragment. The missing piece is the projection
(existential quantification), which requires formalizing the subset construction for
nondeterministic automata — a well-understood algorithm that Mathlib nearly supports
via `Finset.powerset`.

**Falsifiable test:** Express "the Thue-Morse sequence has infinitely many zeros" as
a first-order sentence in ⟨ℕ, +, V₂⟩ and verify the decision procedure outputs TRUE.
This should reduce to checking that a specific automaton accepts at least one string,
which we can do by `DFAO.value_appears_implies_in_output_image`.

---

## 3. Morphic Decidability: Beyond the Automatic Frontier

The decidability of the zero-in-sequence problem for morphic sequences (fixed points of
arbitrary — not necessarily uniform — morphisms) is a major open problem. Durand (2013)
showed decidability for primitive morphisms; the general case remains open.

**The key insight is** that non-uniform morphisms can produce sequences whose "growth
rates" vary across positions, creating a tension between the local regularity of the
morphism and the global structure of the sequence. For uniform morphisms, the growth
is exactly kⁿ (our `AlphabetMorphism.iterate_length_uniform` in the existing catalog),
which makes the connection to DFAOs direct. For non-uniform morphisms, the connection
goes through Pansiot's theorem on the growth rates of morphic sequences.

**Why now?** Our formalization of the k-kernel closure theorem shows that uniform
morphisms stay within the automatic framework. The bridge to non-uniform morphisms
requires formalizing Pansiot's classification (polynomial, exponential, intermediate
growth) and Durand's reduction to the uniform case for primitive morphisms.

**Falsifiable test:** Construct a non-uniform morphism σ on {0,1,2} with σ(0) = 01,
σ(1) = 2, σ(2) = 0 and verify that the fixed point starting from 0 contains all three
letters. Then attempt to formalize the decidability proof for this specific morphism,
checking if BFS on the "reachability graph of letter occurrences" terminates.

---

## 4. Christol's Theorem: The Algebraic-Automatic Bridge

Christol's theorem (1979) states that a formal power series f(x) = Σ aₙxⁿ over 𝔽_p is
algebraic over 𝔽_p(x) if and only if the coefficient sequence (aₙ) is p-automatic. This
is the deepest known connection between automata theory and algebra.

**The key insight is** that the p-kernel of a p-automatic sequence corresponds exactly to
the conjugates of the algebraic element under the Frobenius endomorphism x ↦ xᵖ. The
finiteness of the kernel (which we formalize via `kKernel`) translates to the algebraic
element having finite degree over 𝔽_p(x). Our kernel closure theorem (`kKernel_closed`)
is a key ingredient — it shows the kernel is closed under the operation that corresponds
to applying Frobenius.

**Why now?** Mathlib has extensive support for formal power series (`PowerSeries`),
finite fields (`ZMod p`), and algebraic extensions. The kernel machinery in our
formalization provides the automata-theoretic side. The missing bridge is the
explicit construction of the minimal polynomial from the kernel elements, which
requires combining `PowerSeries` with `Polynomial` over `ZMod p`.

**Falsifiable test:** Verify Christol's theorem for the Thue-Morse sequence mod 2:
the generating function T(x) = Σ tₙxⁿ over 𝔽₂ satisfies T² + T + x/(1+x)² = 0
(a degree-2 algebraic equation), consistent with Thue-Morse being 2-automatic.
Compute the 2-kernel {T(x), T(x²)+x·T(x²)} and verify it has exactly 2 elements.

---

## 5. Automatic Sequences in Cryptographic Applications

Automatic sequences have natural applications in pseudorandom generation and
stream ciphers. The Rudin-Shapiro sequence (2-automatic) has optimal correlation
properties, and the sub-word complexity of automatic sequences (Θ(n) for non-periodic
ones) provides a lower bound on unpredictability.

**The key insight is** that our Boolean closure theorem implies that any Boolean
combination of automatic pseudorandom generators is still automatic — and therefore
still has decidable properties. This means that certain classes of stream cipher
constructions can be *verified* to satisfy security properties (like balance and
correlation immunity) by reduction to finite automaton checks, rather than relying
on heuristic testing.

**Why now?** Our `kAutomatic_boolean_algebra` theorem shows that Boolean combinations
preserve automaticity. Combined with `DFAO.nerode_classes_bounded`, we can bound the
state complexity of combined generators. The connection to correlation immunity requires
formalizing the Walsh-Hadamard transform of automatic sequences, which has been studied
but not formalized.

**Falsifiable test:** Construct the Rudin-Shapiro DFAO (4 states) and verify that
its auto-correlation function is bounded by O(√n), using our DFAO framework to compute
correlations for all inputs up to length 20. Compare with the Thue-Morse sequence
(which has worse correlation properties).
