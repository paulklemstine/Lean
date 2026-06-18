# Chapter 13: Interactive Proofs and Zero Knowledge

## 13.1 A New Kind of Proof

Classical proofs are static objects — a sequence of logical steps written on paper, to be
checked line by line. But what if proofs were *conversations*?

In an **interactive proof**, a powerful but untrusted **prover** (Merlin) tries to convince
a skeptical **verifier** (Arthur) that a statement is true. The verifier is computationally
bounded (polynomial time) but can ask questions and flip coins. The prover has unlimited
computational power but may be trying to cheat.

This model, introduced by Goldwasser, Micali, and Rackoff (1985) and independently by
Babai (1985), led to some of the most surprising and beautiful results in all of
complexity theory.

## 13.2 The Model

**Definition**. An **interactive proof system** for a language `L` consists of a prover `P`
(computationally unbounded) and a verifier `V` (probabilistic polynomial time) that
exchange messages. The system must satisfy:

- **Completeness**: If `x ∈ L`, the prover can convince the verifier to accept with
  probability ≥ 2/3.
- **Soundness**: If `x ∉ L`, *no* prover strategy can convince the verifier to accept with
  probability > 1/3.

**Definition**. `IP` is the class of languages having interactive proof systems.

Clearly `NP ⊆ IP` (the prover sends the NP certificate, the verifier checks it
deterministically). But IP turns out to be much larger.

## 13.3 Graph Non-Isomorphism

The power of interaction is illustrated by **graph non-isomorphism** (GNI): given two
graphs `G₁` and `G₂`, are they *not* isomorphic?

GNI is in co-NP but not known to be in NP. Yet it has an elegant interactive proof:

1. The verifier randomly picks `i ∈ {1, 2}`, randomly permutes `Gᵢ` to get `H`, and sends
   `H` to the prover.
2. The prover, who can solve graph isomorphism (being all-powerful), determines whether
   `H ≅ G₁` or `H ≅ G₂`, and sends back the answer `j`.
3. The verifier accepts if `j = i`.

- If `G₁ ≇ G₂`: The prover can always identify `i` correctly. Accept with probability 1.
- If `G₁ ≅ G₂`: The permuted graph `H` looks identical whether it came from `G₁` or `G₂`.
  The prover can do no better than guessing, so `Pr[j = i] = 1/2`.

By repeating `k` times, the soundness error drops to `2⁻ᵏ`.

## 13.4 IP = PSPACE

The most stunning result in this area is:

**Theorem (Shamir, 1992)**. `IP = PSPACE`.

This means that interactive proofs with a polynomial-time probabilistic verifier and an
all-powerful prover can decide exactly the same problems as polynomial-space computation.
In particular, interactive proofs can verify the truth of any quantified Boolean formula!

The proof of IP = PSPACE uses two key ingredients:

1. **PSPACE ⊆ IP**: Reduce to TQBF, then use *arithmetization* — convert the Boolean
   formula to a polynomial over a finite field and use the **sum-check protocol** to
   interactively verify its value.

2. **IP ⊆ PSPACE**: The verifier's optimal strategy can be computed in PSPACE by
   enumerating over all possible prover messages.

## 13.5 The Sum-Check Protocol

The **sum-check protocol** is the engine behind the IP = PSPACE theorem. It solves:

> Given a polynomial `p(x₁, ..., xₙ)` over a finite field `𝔽`, verify that
> `∑_{x₁ ∈ {0,1}} ∑_{x₂ ∈ {0,1}} ... ∑_{xₙ ∈ {0,1}} p(x₁, ..., xₙ) = H`

**Protocol** (n rounds):

1. The prover sends a univariate polynomial `g₁(x₁) = ∑_{x₂,...,xₙ} p(x₁, x₂, ..., xₙ)`.
   The verifier checks that `g₁(0) + g₁(1) = H`.
2. The verifier sends a random challenge `r₁ ∈ 𝔽`.
3. The prover sends `g₂(x₂) = ∑_{x₃,...,xₙ} p(r₁, x₂, x₃, ..., xₙ)`.
   The verifier checks that `g₂(0) + g₂(1) = g₁(r₁)`.
4. Continue for `n` rounds, reducing the problem to evaluating `p(r₁, r₂, ..., rₙ)` at a
   single point, which the verifier can do directly.

Each round reduces the number of variables by one, and the random challenges ensure that
a cheating prover is caught with high probability (by the Schwartz–Zippel lemma).

## 13.6 Zero-Knowledge Proofs

A **zero-knowledge proof** is an interactive proof that reveals *nothing* to the verifier
beyond the truth of the statement. This cryptographic notion is formalized by requiring
that the verifier's view of the interaction can be *simulated* without the prover — meaning
the verifier learns nothing that it couldn't have computed on its own.

**Definition**. An interactive proof `(P, V)` for `L` is **zero-knowledge** if for every
polynomial-time verifier `V*`, there exists a polynomial-time simulator `S` such that the
output of `S(x)` is computationally indistinguishable from the verifier's view of the
interaction with `P` on input `x ∈ L`.

## 13.7 Zero-Knowledge Proof for Graph Isomorphism

The classic example: given graphs `G₁` and `G₂`, prove they are isomorphic without
revealing the isomorphism.

**Protocol** (repeated `k` times):

1. The prover picks a random permutation `π`, computes `H = π(G₁)`, and sends `H`.
2. The verifier picks a random `b ∈ {1, 2}` and sends `b`.
3. The prover sends a permutation `σ` such that `σ(Gᵦ) = H`.
4. The verifier checks that `σ(Gᵦ) = H`.

- **Completeness**: If `G₁ ≅ G₂`, the prover can always respond correctly.
- **Soundness**: If `G₁ ≇ G₂`, the prover can only respond for one value of `b`, so
  cheating succeeds with probability ≤ 1/2 per round.
- **Zero-knowledge**: The verifier's view (H, b, σ) can be simulated by choosing `b`
  first, picking a random `σ`, computing `H = σ(Gᵦ)`. This simulation is identical to the
  real interaction.

## 13.8 The Power of Zero Knowledge

**Theorem (Goldreich–Micali–Wigderson, 1991)**. Assuming one-way functions exist, every
language in NP has a zero-knowledge proof system.

The proof reduces to 3-COLORING: given a 3-coloring of a graph, the prover commits to a
randomly permuted coloring using a commitment scheme, the verifier picks a random edge, and
the prover reveals the colors of its two endpoints. The verifier checks they are different
and correctly committed.

This theorem has enormous practical implications: it means that *any* NP statement can be
proved without revealing any information beyond its truth.

## 13.9 Applications

Zero-knowledge proofs are foundational to modern cryptography:

- **Authentication**: Prove you know a password without revealing it.
- **Digital signatures**: Derived from zero-knowledge identification protocols.
- **Blockchain and cryptocurrency**: ZK-SNARKs (Zero-Knowledge Succinct Non-Interactive
  Arguments of Knowledge) are used in Zcash, Ethereum, and other systems for privacy and
  scalability.
- **Verifiable computation**: Prove that a computation was performed correctly without
  redoing it.

ZK-SNARKs compress an interactive proof into a single short message, using the Fiat–Shamir
heuristic (replacing the verifier's random challenges with hash function outputs).

## 13.10 MIP and Beyond

What if we allow *multiple* provers who cannot communicate with each other?

**Definition**. `MIP` is the class of languages with interactive proofs involving multiple
provers and a polynomial-time verifier.

**Theorem (Babai–Fortnow–Lund, 1991)**. `MIP = NEXPTIME`.

And in a spectacular recent result:

**Theorem (Ji–Natarajan–Vidick–Wright–Yuen, 2020)**. `MIP* = RE` — multi-prover
interactive proofs with *entangled* provers can verify *every recognizable language*.

This last result settled Tsirelson's problem in quantum information theory and Connes'
embedding conjecture in operator algebras — a stunning connection between computational
complexity, quantum mechanics, and pure mathematics.

---

*"Zero-knowledge proofs show that you can convince someone of a truth without
revealing why it is true — the mathematical embodiment of 'trust, but verify.'"*
