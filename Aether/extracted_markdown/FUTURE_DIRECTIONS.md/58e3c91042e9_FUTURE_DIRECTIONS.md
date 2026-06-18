# Future Directions: Cryptographic Security Reductions in Lean 4

## 1. Formal Goldreich-Levin Hardcore Bit Theorem

The Goldreich-Levin theorem states that for any one-way function f, the inner product ⟨x, r⟩ mod 2 is a hardcore predicate. Formalizing this requires (a) defining one-way functions over `BitVec n` with negligible advantage, (b) formalizing the list-decoding algorithm, and (c) proving the reduction bound: if a predictor P guesses the hardcore bit with advantage ε, then the inverter succeeds with probability poly(ε).

The key insight is that the proof reduces to a Fourier-analytic statement about Boolean functions — specifically, that a function with significant correlation to a linear function can be list-decoded — and our `hybrid_argument` and `averaging_over_fin` already provide the averaging infrastructure needed.

Why now? Our framework of `InsecurityFn` and `SecurityReduction` already handles the quantitative reduction bounds. The missing piece is the list-decoding algorithm, which is a concrete Lean construction over `BitVec n`.

## 2. Tight vs. Non-Tight Reductions and the Tightness Gap

A central question in provable security is whether tight reductions exist between primitives. A tight reduction has `adv_loss = 1` (or O(1)). Our `reduction_composition` theorem shows that composing two reductions multiplies the advantage losses. Can we prove that certain compositions are *inherently* non-tight?

The key insight is that the multiplicative blowup in `reduction_composition` is an *algebraic fact* — it cannot be avoided by choosing different reductions — and this can be formalized as a lower bound on `adv_loss` for any reduction between specific games, using information-theoretic arguments.

Why now? The `SecurityReduction` structure already tracks `adv_loss` explicitly. A separation result would show that for certain game pairs (A, B), any `SecurityReduction A B` must have `adv_loss ≥ f(n)` for some growing function f. This is a concrete Lean statement we can attempt.

## 3. Computational Indistinguishability as a Pseudo-Metric

Statistical distance defines a metric on distributions. Computational indistinguishability defines a *pseudo-metric* (satisfying the triangle inequality up to resource bounds). Our `advantage_triangle` theorem already proves the triangle inequality for advantages. Can we formalize a full pseudo-metric space structure on distributions indexed by security parameters?

The key insight is that the triangle inequality for computational indistinguishability loses a factor of 2 in resource bounds (the distinguisher for the composed game must run both sub-distinguishers), and our `SecurityReduction` framework naturally tracks this overhead via `time_overhead`.

Why now? Mathlib has extensive `PseudoMetricSpace` infrastructure. Connecting cryptographic indistinguishability to this framework would enable applying Mathlib's metric space theorems (completeness, compactness) to sequences of distributions.

## 4. The GGM PRF Construction: PRG ⟹ PRF with Concrete Bounds

The Goldreich-Goldwasser-Micali (GGM) construction builds a PRF from any length-doubling PRG using a binary tree evaluation. The security loss is exactly the depth of the tree (the key length). Our `prg_stretch_amplification` theorem handles the linear advantage loss for PRG composition; the GGM proof uses a similar hybrid argument but over the *tree structure* rather than a linear chain.

The key insight is that the GGM hybrid argument requires a *tree-indexed* hybrid sequence (2^n hybrids), and the advantage loss is the tree depth n, not the number of leaves 2^n. This is a fundamentally different application of the averaging principle from the linear chain case.

Why now? Our `hybrid_argument` theorem is already stated for arbitrary index sets. Extending it to tree-structured hybrids requires only a recursive application of the same averaging lemma, with the `InsecurityFn` framework tracking the concrete bounds.

## 5. Impagliazzo's Five Worlds: Separating the Cryptographic Landscape

Impagliazzo's framework partitions possible computational worlds into Algorithmica (P = NP), Heuristica (average-case easy), Pessiland (hard problems but no OWF), Minicrypt (OWF but no public-key crypto), and Cryptomania (public-key crypto exists). Our `CryptoImplies` relation captures implications *within* Minicrypt and Cryptomania. Can we formalize the *separations* — proving that certain implications are NOT in `CryptoImplies`?

The key insight is that proving `¬ CryptoImplies .CPA_Secure .OWF` (CPA-security does not imply OWF existence) requires showing there is no derivation in our inductively-defined relation, which is a syntactic/structural argument about the constructors of `CryptoImplies`.

Why now? Since `CryptoImplies` is an inductive type, separation results are *decidable by structural induction*. We can prove that no finite chain of our constructors derives certain implications, formalizing the known black-box separation results as concrete Lean theorems.
