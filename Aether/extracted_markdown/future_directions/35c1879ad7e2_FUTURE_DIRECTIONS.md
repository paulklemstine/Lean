# Future Directions: Computational Complexity as Physical Law

## 1. Goldwasser-Micali Semantic Security from QRA

The quadratic residuosity results in this cycle (`qnr_product_is_qr`, `euler_criterion_applied`) establish the algebraic foundation of the Goldwasser-Micali cryptosystem. The next step is to formalize the full semantic security proof: given the Quadratic Residuosity Assumption (QRA), prove that the GM encryption scheme achieves IND-CPA security with advantage bounded by the QRA advantage.

The key insight is that the index-2 subgroup structure we proved (QR × QNR → QNR, QNR × QNR → QR) means that encrypting a 0-bit vs a 1-bit produces elements in QR vs QNR respectively, and distinguishing these reduces exactly to QRA. The formalization requires defining a probabilistic encryption scheme as a triple (KeyGen, Enc, Dec) and stating IND-CPA as a game.

Why now? The algebraic machinery (Euler criterion, QR/QNR product structure, density bounds) is now available in formalized form. The remaining gap is the probabilistic game framework, which can be built on top of Mathlib's probability theory.

## 2. Leftover Hash Lemma and Min-Entropy Extraction

The `preimage_size_sum` theorem establishes the counting foundation for key derivation: the sum of fiber sizes equals the domain size. The natural extension is the full Leftover Hash Lemma (LHL): if H is a universal hash family from {0,1}^n to {0,1}^m, and X has min-entropy k, then (H, H(X)) is 2^{(m-k)/2}-close to uniform.

The key insight is that universal hashing converts min-entropy into statistical closeness to uniform, and the bound is tight. This is the theoretical foundation of randomness extraction in cryptography and would connect our fiber-counting results to statistical distance and Rényi entropy.

Why now? The preimage counting infrastructure and surjectivity bounds are proved. The main gap is formalizing statistical distance between distributions over finite types, which can be done with `Finset.sum` over absolute differences of probability mass functions.

## 3. Decisional Diffie-Hellman in Prime-Order Groups

The `prime_order_all_generators` theorem shows that every non-identity element generates a prime-order group. This is precisely the structural property that makes the Decisional Diffie-Hellman (DDH) assumption meaningful: in a prime-order group, there are no proper subgroups to exploit, so DDH cannot be broken by subgroup membership tests.

The key insight is that DDH security can be formulated as: no efficient algorithm can distinguish (g^a, g^b, g^{ab}) from (g^a, g^b, g^c) for random a, b, c. The algebraic content is that the map (a, b) ↦ (g^a, g^b, g^{ab}) is not determined by the individual components g^a and g^b alone—there is genuine entropy in the product.

Why now? The generator structure of prime-order groups is formalized. The next step requires formalizing the DDH game and proving basic structural results (e.g., DDH implies CDH implies DL, with explicit advantage bounds composing via our `advantage_composition` theorem).

## 4. PRG Length Extension via Hybrid Argument

The `hybrid_argument_bound` provides the generic advantage composition for q-step hybrid arguments. A concrete and important application is PRG length extension: if G: {0,1}^n → {0,1}^{n+1} is a pseudorandom generator, then iterating G produces a PRG G': {0,1}^n → {0,1}^{n+q} for any polynomial q, with advantage at most q times the single-step PRG advantage.

The key insight is that each hybrid replaces one "real" G-output with a "random" block, and the total distinguishing advantage is bounded by q · ε where ε is the PRG advantage. This directly uses our hybrid bound and would be the first formalized proof of PRG length extension in Lean.

Why now? The hybrid argument infrastructure is proved with tight bounds. The remaining formalization requires defining PRGs as functions with computational indistinguishability from uniform, which builds naturally on our `CompIndist` framework.

## 5. Collision Resistance from Birthday Bound to Merkle-Damgård

The birthday bound results (`collision_free_ratio`, `no_injection_above_size`, `collision_free_positive`) give the combinatorial foundation for hash function collision resistance. The next direction is to formalize the Merkle-Damgård construction and prove that collision resistance of the compression function implies collision resistance of the iterated hash, with advantage bounded by the number of blocks times the compression function advantage.

The key insight is that the Merkle-Damgård reduction is a concrete instance of our `advantage_composition` theorem: finding a collision in the full hash reduces to finding a collision in one compression function call, and the hybrid argument over blocks gives the explicit loss factor. This connects our abstract reduction composition to a specific, widely-deployed construction.

Why now? Both the birthday bound combinatorics and the reduction composition framework are formalized. The gap is defining the Merkle-Damgård iteration over lists of fixed-size blocks and proving the collision reduction, which is a finite induction argument perfectly suited to Lean's `List.recOn`.
