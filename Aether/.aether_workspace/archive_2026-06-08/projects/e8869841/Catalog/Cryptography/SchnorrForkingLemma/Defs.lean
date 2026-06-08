/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Schnorr–Fiat–Shamir Forking Lemma: Definitions

This file defines the core structures for formalizing the quantitative
forking lemma for Schnorr signatures in the Fiat–Shamir (random oracle) model.

We work over `ZMod q` where `q` is a prime, modeling the Schnorr protocol
in an additive cyclic group of order `q`. The verification equation is:

    z * gen = a + c * pub

where `gen` is a generator (nonzero element of `ZMod q`), `pub = x * gen`
is the public key, and `(a, c, z)` is a signature transcript.

## Main definitions

* `SchnorrTranscript` — A Schnorr signature transcript `(a, c, z)`.
* `ForkedTranscript` — Two transcripts sharing commitment `a` with distinct challenges.
* `schnorrVerifies` — The verification predicate for Schnorr transcripts.
* `schnorrExtract` — Witness extraction from a forked transcript.
* `ForkableAdversary` — A single-query forkable random-oracle adversary.
* `ForkExperiment` — The forking experiment over finite coin/challenge spaces.

## References

* Pointcheval, Stern. "Security Arguments for Digital Signatures and Blind Signatures." (2000)
* Bellare, Neven. "Multi-Signatures in the Plain Public-Key Model and a General Forking Lemma." (2006)
-/
import Mathlib

open Finset BigOperators

/-! ## Schnorr Protocol Structures -/

/-- A Schnorr signature transcript consisting of commitment `a`, challenge `c`,
    and response `z`, all in `ZMod q`. -/
structure SchnorrTranscript (q : ℕ) where
  /-- The commitment (first message from prover) -/
  a : ZMod q
  /-- The challenge (from verifier / random oracle) -/
  c : ZMod q
  /-- The response (second message from prover) -/
  z : ZMod q

/-- A forked transcript: two accepting transcripts sharing the same commitment `a`
    but with distinct challenges `c₁ ≠ c₂`. This is the output of a successful
    forking experiment. -/
structure ForkedTranscript (q : ℕ) where
  /-- The shared commitment -/
  a : ZMod q
  /-- First challenge -/
  c₁ : ZMod q
  /-- Second challenge -/
  c₂ : ZMod q
  /-- First response -/
  z₁ : ZMod q
  /-- Second response -/
  z₂ : ZMod q
  /-- The challenges are distinct -/
  hneq : c₁ ≠ c₂

/-- Schnorr verification predicate in the additive `ZMod q` model.
    A transcript `(a, c, z)` is valid for generator `gen` and public key `pub` iff
    `z * gen = a + c * pub`. -/
def schnorrVerifies {q : ℕ} (gen pub : ZMod q) (tr : SchnorrTranscript q) : Prop :=
  tr.z * gen = tr.a + tr.c * pub

/-- Extract the discrete logarithm witness from a forked transcript.
    Given two valid transcripts `(a, c₁, z₁)` and `(a, c₂, z₂)` with `c₁ ≠ c₂`,
    the witness is `x = (z₁ - z₂) * (c₁ - c₂)⁻¹`. -/
def schnorrExtract {q : ℕ} (ft : ForkedTranscript q) : ZMod q :=
  (ft.z₁ - ft.z₂) * (ft.c₁ - ft.c₂)⁻¹

/-! ## Forkable Adversary Abstraction -/

/-- A single-query forkable random-oracle adversary.

This captures the essential semantics of a Fiat–Shamir adversary that
makes exactly one random-oracle query (the "distinguished query") and
uses the oracle's response as the challenge in its output transcript.

The adversary is parameterized by:
- `Coins`: the type of internal randomness
- `run`: given coins and a challenge, produces a transcript and a success bit
- The challenge in the output transcript equals the oracle's answer.

This is the minimal abstraction under which the forking/rewinding argument works. -/
structure ForkableAdversary (q : ℕ) where
  /-- Type of adversary's internal randomness -/
  Coins : Type
  /-- The coins form a finite type -/
  [coinsFintype : Fintype Coins]
  /-- The coins type is nonempty (adversary can run) -/
  [coinsNonempty : Nonempty Coins]
  /-- Run the adversary: given coins and a challenge, produce a transcript -/
  run : Coins → ZMod q → SchnorrTranscript q
  /-- The adversary uses the oracle answer as its challenge -/
  challenge_from_oracle : ∀ (coins : Coins) (c : ZMod q),
    (run coins c).c = c
  /-- The commitment is determined before the challenge (independent of oracle answer).
      This captures the Fiat–Shamir structure: the adversary commits before querying
      the random oracle. -/
  commitment_independent : ∀ (coins : Coins) (c₁ c₂ : ZMod q),
    (run coins c₁).a = (run coins c₂).a

attribute [instance] ForkableAdversary.coinsFintype ForkableAdversary.coinsNonempty

/-! ## Fork Experiment -/

/-- The success predicate: the adversary produces a valid transcript for the
    given generator and public key. -/
def adversarySucceeds {q : ℕ} (gen pub : ZMod q) (A : ForkableAdversary q)
    (coins : A.Coins) (c : ZMod q) : Prop :=
  schnorrVerifies gen pub (A.run coins c)

/-- Decidable instance for adversary success (everything is in ZMod q). -/
instance {q : ℕ} (gen pub : ZMod q) (A : ForkableAdversary q)
    (coins : A.Coins) (c : ZMod q) :
    Decidable (adversarySucceeds gen pub A coins c) :=
  inferInstanceAs (Decidable (_ = _))

/-- The set of successful (coins, challenge) pairs. -/
noncomputable def successSet {q : ℕ} [Fact q.Prime] (gen pub : ZMod q)
    (A : ForkableAdversary q) : Finset (A.Coins × ZMod q) :=
  Finset.univ.filter (fun p => adversarySucceeds gen pub A p.1 p.2)

/-- For given coins, the set of challenges that lead to success. -/
noncomputable def successChallenges {q : ℕ} [Fact q.Prime] (gen pub : ZMod q)
    (A : ForkableAdversary q) (coins : A.Coins) : Finset (ZMod q) :=
  Finset.univ.filter (fun c => adversarySucceeds gen pub A coins c)

/-- The set of successful fork triples: same coins, two distinct challenges,
    both leading to success. -/
noncomputable def forkSuccessSet {q : ℕ} [Fact q.Prime] (gen pub : ZMod q)
    (A : ForkableAdversary q) : Finset (A.Coins × ZMod q × ZMod q) :=
  Finset.univ.filter (fun p =>
    p.2.1 ≠ p.2.2 ∧
    adversarySucceeds gen pub A p.1 p.2.1 ∧
    adversarySucceeds gen pub A p.1 p.2.2)

/-- The number of successful (coins, challenge) pairs. -/
noncomputable def successCount {q : ℕ} [Fact q.Prime] (gen pub : ZMod q)
    (A : ForkableAdversary q) : ℕ :=
  (successSet gen pub A).card

/-- The number of successful fork triples. -/
noncomputable def forkSuccessCount {q : ℕ} [Fact q.Prime] (gen pub : ZMod q)
    (A : ForkableAdversary q) : ℕ :=
  (forkSuccessSet gen pub A).card

/-- Count of successful challenges for given coins. -/
noncomputable def challengeSuccessCount {q : ℕ} [Fact q.Prime] (gen pub : ZMod q)
    (A : ForkableAdversary q) (coins : A.Coins) : ℕ :=
  (successChallenges gen pub A coins).card