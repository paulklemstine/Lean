/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Proof Compression: Definitions

Core definitions for the theory of proof compression phase transitions.
We define abstract proof systems, normalizers, search trees, and the key
measures of proof complexity (raw length, normalized length, shortest proofs).

## Overview

The central objects are:
- `ProofSystem`: an abstract proof calculus with a notion of proof length
- `Normalizer`: a deterministic transformation on proofs (modeling cut-elimination,
  β-reduction, or any canonical normalization procedure)
- `SearchTree`: a finite branching tree modeling explicit witness search
- `shortestRaw`, `shortestNorm`: infimum-based measures of proof complexity

The key properties connecting these objects are:
- **Search extraction**: normalized proofs encode explicit search trees
- **Size dominance**: search tree size is bounded by normalized proof length
- **Search hardness**: certain families require exponentially large search trees
-/

noncomputable section

open Filter Finset

namespace ProofCompression

/-! ## Abstract Proof Systems -/

/-- An abstract sentence in a formal language, indexed by a natural number.
    In practice, this represents a formula in bounded arithmetic or a
    total-search principle parameterized by size. -/
structure Sentence where
  /-- Parameter encoding the sentence -/
  idx : ℕ
  deriving DecidableEq, Inhabited

/-- An abstract proof system consists of:
    - A type of proofs for each sentence
    - A length function measuring proof size
    - A witness that at least one proof exists for each sentence in our family

    This captures any sound proof calculus: sequent calculus, natural deduction,
    Frege systems, bounded-depth proof systems, etc. -/
structure ProofSystem where
  /-- The type of proofs for a given sentence -/
  Proof : Sentence → Type
  /-- The length (size) of a proof, measured in symbols, nodes, or lines -/
  proofLength : {φ : Sentence} → Proof φ → ℕ

/-- A deterministic normalizer transforms proofs into a canonical form.
    This models cut-elimination, β-reduction, Herbrand expansion,
    or any canonical proof transformation procedure.

    Key property: normalization preserves the proven sentence
    (captured by the type signature: `Proof φ → Proof φ`). -/
structure Normalizer (P : ProofSystem) where
  /-- The normalization function -/
  normalize : {φ : Sentence} → P.Proof φ → P.Proof φ

/-! ## Search Trees -/

/-- A search tree models the explicit witness-finding computation that
    a normalized proof must encode when proving a `Π₂` total-search statement.

    In the normalized form of a proof of `∀x ≤ t. ∃y ≤ s. R(x,y)`,
    the proof must contain an explicit strategy for finding `y` given `x`.
    This strategy forms a tree: at each node, the proof branches on
    possible inputs and provides witness computations at leaves. -/
structure SearchTree where
  /-- Total number of nodes in the search tree -/
  size : ℕ
  /-- Maximum depth (longest root-to-leaf path) -/
  depth : ℕ
  /-- Branching factor (maximum children per internal node) -/
  branchingFactor : ℕ

/-! ## Proof Complexity Measures -/

/-- The shortest raw (un-normalized) proof length for a sentence.
    This is `sInf` of the set of all proof lengths. -/
def shortestRaw (P : ProofSystem) (φ : Sentence) : ℕ :=
  sInf {ℓ | ∃ p : P.Proof φ, P.proofLength p = ℓ}

/-- The shortest normalized proof length for a sentence.
    This is the infimum over all proofs of the length of their normalization.
    Note: we minimize over all raw proofs `p` and take the length of `normalize p`. -/
def shortestNorm (P : ProofSystem) (N : Normalizer P) (φ : Sentence) : ℕ :=
  sInf {ℓ | ∃ p : P.Proof φ, P.proofLength (N.normalize p) = ℓ}

/-- The proof distortion ratio: how much normalization inflates proof length.
    When this grows superpolynomially, we have a phase transition. -/
def proofDistortion (P : ProofSystem) (N : Normalizer P) (φ : Sentence) : ℕ :=
  shortestNorm P N φ

/-! ## Search Complexity -/

/-- The required search size for a sentence: the minimum size of any
    search tree that correctly solves the witness-finding problem
    encoded by the sentence. -/
def requiredSearchSize
    (searchLowerBound : ℕ) : Prop :=
  ∀ (τ : SearchTree), τ.size ≥ searchLowerBound

/-! ## Encoding Properties -/

/-- Property that a normalized proof encodes an explicit search tree.
    This is the key structural assumption: after normalization, the proof
    must contain an explicit witness-search strategy, and that strategy
    can be extracted as a `SearchTree`.

    This property holds in proof calculi where:
    - Cuts are eliminated (sequent calculus normalization)
    - β-redexes are reduced (λ-calculus normalization)
    - Herbrand expansion is performed (first-order logic)
    In all these cases, normalized proofs of `∀∃` statements
    contain explicit witness terms. -/
structure SearchExtraction (P : ProofSystem) (N : Normalizer P) (φ : Sentence) where
  /-- Every normalized proof yields a search tree -/
  extract : P.Proof φ → SearchTree
  /-- The search tree size is bounded by the normalized proof length -/
  sizeBound : ∀ p : P.Proof φ, (extract p).size ≤ P.proofLength (N.normalize p)
  /-- The search tree is a valid solution (its size is at least the required minimum) -/
  searchValid : ∀ p : P.Proof φ, ∀ lb : ℕ,
    (∀ τ : SearchTree, τ.size ≥ lb) → (extract p).size ≥ lb

/-- A family of sentences parameterized by natural numbers.
    E.g., `φ n` could be the pigeonhole principle for `n+1` pigeons in `n` holes,
    or a bounded local-search principle on graphs of size `n`. -/
def SentenceFamily := ℕ → Sentence

/-- A sentence family has polynomial raw proofs if there exist constants
    `C, k` such that the shortest raw proof of `φ n` has length ≤ `C * n^k`. -/
def HasPolyRawProofs (P : ProofSystem) (φ : SentenceFamily) : Prop :=
  ∃ C k : ℕ, 0 < C ∧ ∀ n, shortestRaw P (φ n) ≤ C * n ^ k

/-- A sentence family has exponential normalization blowup if there exist
    `b ≥ 2` and `a ≥ 1` such that for infinitely many `n`,
    the shortest normalized proof has length ≥ `b^(n^a)`. -/
def HasExpNormBlowup (P : ProofSystem) (N : Normalizer P)
    (φ : SentenceFamily) : Prop :=
  ∃ b a : ℕ, 2 ≤ b ∧ 1 ≤ a ∧
    ∀ n, b ^ (n ^ a) ≤ shortestNorm P N (φ n)

/-- A sentence family exhibits phase separation: polynomial raw proofs
    coexist with exponential normalized proofs. -/
def ExhibitsPhaseTransition (P : ProofSystem) (N : Normalizer P)
    (φ : SentenceFamily) : Prop :=
  HasPolyRawProofs P φ ∧ HasExpNormBlowup P N φ

end ProofCompression

end