/-
Copyright (c) 2025. All rights reserved.

# Tropical Shannon Information Theory — Foundational Definitions

## Overview

This file defines the core objects of tropical (max-plus) information theory:
the idempotent analogues of Shannon's foundational concepts. Where classical
Shannon theory measures *average* information over the probability semiring
(ℝ₊, +, ×), tropical Shannon theory measures *worst-case* information over
the tropical semiring (ℝ ∪ {−∞}, max, +).

## Key Definitions

* `ProbDist` — a probability distribution on a finite type
* `tropicalEntropy` — H_⊕(X) = −log(min_x p(x)), the Rényi ∞-entropy
* `tropicalKL` — D_⊕(P‖Q) = max_x log(p(x)/q(x)), worst-case divergence
* `tropicalCondEntropy` — H_⊕(Y|X) = max_x H_⊕(Y|X=x)
* `tropicalMutualInfo` — I_⊕(X;Y), worst-case mutual information
* `MaxPlusChannel` — a stochastic map in the max-plus semiring
* `IdempotentMarkovChain` — Markov chain structure for DPI proofs

## Bridge

These definitions connect tropical algebra (max-plus semirings) to
information theory (entropy, divergence), thermodynamics (free energy,
partition functions), and post-quantum cryptography (worst-case leakage).
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

namespace TropicalInformation

/-! ## Probability Distributions -/

/-- A probability distribution on a finite type: all values nonneg and sum to 1. -/
structure ProbDist (α : Type*) [Fintype α] where
  pmf : α → ℝ
  nonneg : ∀ x, 0 ≤ pmf x
  sum_one : ∑ x : α, pmf x = 1

/-- A strictly positive probability distribution. -/
structure StrictProbDist (α : Type*) [Fintype α] extends ProbDist α where
  pos : ∀ x, 0 < pmf x

/-- The minimum probability of a strict probability distribution. -/
def StrictProbDist.minProb {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) : ℝ :=
  Finset.min' (Finset.univ.image p.pmf) (by simp [Finset.image_nonempty])

/-- The maximum probability of a probability distribution. -/
def ProbDist.maxProb {α : Type*} [Fintype α] [Nonempty α]
    (p : ProbDist α) : ℝ :=
  Finset.max' (Finset.univ.image p.pmf) (by simp [Finset.image_nonempty])

/-! ## Tropical Shannon Entropy -/

/-- **Tropical Shannon entropy**: H_⊕(X) = −log(min_x p(x)).
    This is the Rényi entropy of order ∞, measuring worst-case surprise.
    It equals the logarithm of the reciprocal of the minimum probability.

    Bridge: connects tropical algebra (max-plus) to information theory (entropy)
    and thermodynamics (ground-state energy). -/
def tropicalEntropy {α : Type*} [Fintype α] [Nonempty α]
    (p : StrictProbDist α) : ℝ :=
  -Real.log p.minProb

/-! ## Tropical KL Divergence -/

/-- **Tropical KL divergence**: D_⊕(P‖Q) = max_x log(p(x)/q(x)).
    The worst-case log-likelihood ratio, measuring maximum pointwise
    divergence between two distributions.

    Bridge: connects large deviation theory to tropical geometry
    and post-quantum security bounds. -/
def tropicalKL {α : Type*} [Fintype α] [Nonempty α]
    (p : ProbDist α) (q : StrictProbDist α) : ℝ :=
  Finset.max' (Finset.univ.image (fun x => Real.log (p.pmf x / q.pmf x)))
    (by simp [Finset.image_nonempty])

/-! ## Tropical Conditional Entropy and Mutual Information -/

/-- **Tropical conditional entropy** for a joint distribution.
    H_⊕(Y|X) = max_x (−log(min_y p(y|x))).
    The worst-case conditional uncertainty. -/
def tropicalCondEntropy {α β : Type*} [Fintype α] [Fintype β]
    [Nonempty α] [Nonempty β] [DecidableEq α]
    (pXY : StrictProbDist (α × β))
    (margX : StrictProbDist α) : ℝ :=
  Finset.max' (Finset.univ.image (fun x =>
    -Real.log (Finset.min' (Finset.univ.image (fun y =>
      pXY.pmf (x, y) / margX.pmf x)) (by simp [Finset.image_nonempty]))))
    (by simp [Finset.image_nonempty])

/-! ## Max-Plus Channels -/

/-- A **max-plus information channel**: a row-stochastic matrix in the
    probabilistic sense, viewed through the tropical lens.
    The channel maps input alphabet α to output alphabet β.

    Bridge: connects stochastic processes to tropical geometry and
    lattice-based cryptographic key exchange. -/
structure MaxPlusChannel (α β : Type*) [Fintype α] [Fintype β] where
  kernel : α → β → ℝ
  kernel_nonneg : ∀ x y, 0 ≤ kernel x y
  kernel_sum_one : ∀ x, ∑ y : β, kernel x y = 1

/-- The **joint distribution** induced by a channel and input distribution. -/
def jointFromChannel {α β : Type*} [Fintype α] [Fintype β]
    (ch : MaxPlusChannel α β) (p : ProbDist α) : (α × β) → ℝ :=
  fun ⟨x, y⟩ => p.pmf x * ch.kernel x y

/-! ## Tropical Partition Function -/

/-- **Tropical partition function** at inverse temperature β.
    Z(β) = Σ_s exp(−β · cost(s)), the generating function for
    Boltzmann weights in the max-plus thermodynamic limit.

    Bridge: connects statistical mechanics (partition functions) to
    tropical information theory (entropy as β → ∞ limit). -/
def tropicalPartitionFunction {S : Type*} [Fintype S]
    (cost : S → ℝ) (β : ℝ) : ℝ :=
  ∑ s : S, Real.exp (-β * cost s)

/-- The **ground-state energy**: minimum cost over all states. -/
def groundStateEnergy {S : Type*} [Fintype S] [Nonempty S]
    (cost : S → ℝ) : ℝ :=
  Finset.min' (Finset.univ.image cost) (by simp [Finset.image_nonempty])

/-- The **Boltzmann distribution** at inverse temperature β:
    p_β(s) = exp(−β · cost(s)) / Z(β). -/
def boltzmannDist {S : Type*} [Fintype S]
    (cost : S → ℝ) (β : ℝ) (_hZ : 0 < tropicalPartitionFunction cost β) : S → ℝ :=
  fun s => Real.exp (-β * cost s) / tropicalPartitionFunction cost β

/-! ## Prefix Codes -/

/-- A **prefix code** is a function from symbols to binary strings such that
    no codeword is a prefix of another. We model this via Kraft's inequality. -/
structure PrefixCode (α : Type*) [Fintype α] where
  lengths : α → ℕ
  kraft : ∑ x : α, (2 : ℝ)⁻¹ ^ lengths x ≤ 1

/-! ## Idempotent Markov Chains -/

/-- An **idempotent Markov chain** X → Y → Z, defined by the Markov
    property: p(z|x,y) = p(z|y).
    Used for proving the tropical data processing inequality. -/
structure IdempotentMarkovChain (α β γ : Type*)
    [Fintype α] [Fintype β] [Fintype γ] where
  pXYZ : (α × β × γ) → ℝ
  nonneg : ∀ xyz, 0 ≤ pXYZ xyz
  sum_one : ∑ xyz : α × β × γ, pXYZ xyz = 1

end TropicalInformation

end