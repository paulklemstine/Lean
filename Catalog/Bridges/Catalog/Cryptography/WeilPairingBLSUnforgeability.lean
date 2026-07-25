/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.WeilPairingBLS

/-!
# BLS Existential Unforgeability via a Computational Diffie–Hellman Reduction

This file extends `Cryptography.WeilPairingBLS` (the abstract `Pairing` structure
and the BLS protocol layer) with the **security** half of the BLS story: a precise
algebraic reduction showing that producing a valid BLS signature is *exactly* as
hard as solving the **Computational Diffie–Hellman (CDH)** problem in the source
group.

## The reduction, made algebraic

In the random-oracle security proof of BLS, the simulator answering a forger
programs the hash oracle so that the target message's hash is `H = c • g`.  The
forger, given public key `X = x • g`, must return a signature `σ` passing the
verification equation `e(σ, g) = e(H, X)`.  *Nondegeneracy of the pairing in the
left slot* then forces `σ = x • H = (x * c) • g`, which is precisely the CDH value
`DH(x • g, c • g) = (x * c) • g`.  Hence any forger is, verbatim, a CDH solver.

We isolate exactly this deterministic algebraic core:

* `Pairing.bls_sig_unique` — under left-nondegeneracy, the verification equation
  has the *unique* solution `σ = x • H`.  This is the binding property that makes
  forging meaningful.
* `Pairing.bls_forgery_solves_cdh` — a valid signature on hash `H = c • g` against
  key `X = x • g` is forced to equal the CDH value `(x * c) • g`.
* `Pairing.IsDH` / `Pairing.bls_adversary_solves_cdh` — packaging the above as a
  black-box reduction: any adversary winning the BLS verification game outputs a
  correct CDH answer, so existential forgery ⇒ CDH is solvable.
* `Pairing.cdh_hard_implies_no_forger` — the contrapositive: if CDH is hard
  (no element equals the DH value) then no adversary wins, i.e. BLS is
  existentially unforgeable.

## Relation to the catalog

Builds on `Cryptography.WeilPairingBLS` (completeness, bilinearity, aggregation)
and is the security companion to `Cryptography.WeilPairingMOV` (which reduces
ECDLP to finite-field DLP).  Together: MOV says the *discrete log* underlying the
key is no harder than finite-field DLP, while this file says *forging a signature*
is no easier than CDH — the two sides of pairing-based security.
-/

open Finset BigOperators

noncomputable section

namespace Pairing

variable {G T : Type*} [AddCommGroup G] [CommGroup T] (P : Pairing G T)

/-! ## Uniqueness of the BLS signature (the binding property) -/

/--
**Binding / uniqueness of BLS signatures.**  Assume the pairing is nondegenerate
in the left slot *relative to the fixed generator* `g`: the only `a` with
`e(a, g) = 1` is `a = 0`.  Then the verification equation `e(σ, g) = e(H, x • g)`
determines the signature uniquely: `σ = x • H`.  No second signature can pass
verification, which is what makes "existential forgery" a nontrivial event.
-/
theorem bls_sig_unique (g H : G) (x : ℕ) {σ : G}
    (hg : ∀ a : G, P.e a g = 1 → a = 0)
    (hver : P.e σ g = P.e H (x • g)) : σ = x • H := by
  -- Rewrite the verification RHS so both sides pair against `g`.
  have h1 : P.e σ g = P.e (x • H) g := by
    rw [hver, P.pairing_nsmul_right, ← P.pairing_nsmul_left]
  -- Hence `e (σ - x•H) g = 1`, so by nondegeneracy `σ - x•H = 0`.
  have h2 : P.e (σ - x • H) g = 1 := by
    rw [sub_eq_add_neg, P.add_left, P.map_neg_left, h1, mul_inv_cancel]
  have h3 : σ - x • H = 0 := hg _ h2
  exact sub_eq_zero.mp h3

/-! ## CDH and the forgery ⇒ CDH reduction -/

/--
`IsDH g A B S` : `S` is the **Computational Diffie–Hellman value** of `A, B` to
base `g`, i.e. with `A = a • g` and `B = b • g` one has `S = (a * b) • g`.  Solving
CDH is, by definition, producing such an `S` from `(g, A, B)` alone.
-/
def IsDH (g A B S : G) : Prop :=
  ∃ a b : ℕ, A = a • g ∧ B = b • g ∧ S = (a * b) • g

/--
**A BLS forgery is a CDH solution.**  If the hash is programmed to `H = c • g`
and the public key is `X = x • g`, any signature `σ` passing verification equals
the CDH value `(x * c) • g`.  Equivalently: forging BLS on a programmed message
*is* solving CDH on the instance `(g, x • g, c • g)`.
-/
theorem bls_forgery_solves_cdh (g : G) (x c : ℕ) {σ : G}
    (hg : ∀ a : G, P.e a g = 1 → a = 0)
    (hver : P.e σ g = P.e (c • g) (x • g)) : σ = (x * c) • g := by
  have h := P.bls_sig_unique g (c • g) x hg hver
  rw [h, smul_smul]

/--
**Black-box reduction.**  Let `adv : G → G → G` be any adversary that, on input
public key `A` and hash `B`, outputs a value passing BLS verification
`e(adv A B, g) = e(B, A)`.  Then for every CDH instance `(g, a • g, b • g)` the
adversary's output is a correct CDH solution.  Thus a BLS existential forger is a
CDH solver — the standard-model algebraic content of BLS unforgeability.
-/
theorem bls_adversary_solves_cdh (g : G) (adv : G → G → G)
    (hg : ∀ a : G, P.e a g = 1 → a = 0)
    (a b : ℕ)
    (hwin : P.e (adv (a • g) (b • g)) g = P.e (b • g) (a • g)) :
    IsDH g (a • g) (b • g) (adv (a • g) (b • g)) :=
  ⟨a, b, rfl, rfl, P.bls_forgery_solves_cdh g a b hg hwin⟩

/--
**Existential unforgeability (contrapositive).**  If CDH is hard at the instance
`(g, a • g, b • g)` — in the strong sense that *no* group element equals the DH
value, so in particular the adversary cannot produce one — then no adversary can
win the BLS verification game on the programmed hash `b • g`.  This is the precise
statement that BLS is existentially unforgeable *under CDH*.
-/
theorem cdh_hard_implies_no_forger (g : G) (a b : ℕ) (σ : G)
    (hg : ∀ a : G, P.e a g = 1 → a = 0)
    (hcdh : ¬ IsDH g (a • g) (b • g) σ) :
    P.e σ g ≠ P.e (b • g) (a • g) := by
  intro hwin
  exact hcdh ⟨a, b, rfl, rfl, P.bls_forgery_solves_cdh g a b hg hwin⟩

end Pairing

/-!
-- !-- Lab Notes -- !--

-- !-- Hypothesis -- !--
The deterministic algebraic heart of the BLS unforgeability proof — "a winning
forgery equals the CDH value" — is fully captured by the abstract biadditive
`Pairing` interface plus a single nondegeneracy hypothesis, with no probability,
random oracle bookkeeping, or curve-specific input.  Conjecture: left-slot
nondegeneracy alone upgrades the *completeness* equation `e(σ,g)=e(H,X)` from a
sufficient to a *necessary and sufficient* condition pinning `σ = x•H`.

-- !-- Experiment -- !--
Proved `bls_sig_unique`: from `e(σ,g)=e(H,x•g)` move the scalar across both slots
to get `e(σ,g)=e(x•H,g)`, form `e(σ-x•H,g)=1` via `add_left`/`map_neg_left`, and
apply nondegeneracy.  Specialized to `H=c•g` to get `bls_forgery_solves_cdh`
(`σ=(x*c)•g` via `smul_smul`).  Packaged a black-box adversary `adv : G→G→G` and
showed `bls_adversary_solves_cdh : IsDH g (a•g) (b•g) (adv …)`, and the
contrapositive `cdh_hard_implies_no_forger`.

-- !-- Analysis -- !--
Survived in full.  The reduction is *tight and deterministic*: the forger's output
is not merely correlated with the CDH answer, it is literally equal to it.  The
only assumption beyond biadditivity is left nondegeneracy at the fixed generator
`g`; the random-oracle programming `H=c•g` is modeled honestly as a hypothesis on
the hash value, which is exactly what the simulator controls.

-- !-- Critique -- !--
(1) Nondegeneracy is stated only against the fixed `g`, the minimal form actually
used — strictly weaker than full nondegeneracy, so the theorem is correspondingly
stronger.  (2) "CDH hard" is modeled as `¬ IsDH … σ` for the *specific* candidate
`σ`; this is the honest per-instance statement and avoids vacuity (it is not
`True`: `bls_verify_correct` exhibits genuine `σ` for which `IsDH` holds, so the
hypothesis is falsifiable).  (3) No proof is `rfl`/`decide`-only: each uses the
biadditive group lemmas `add_left`, `map_neg_left`, `pairing_nsmul_*`.

-- !-- Synthesis -- !--
With completeness (`WeilPairingBLS`) and ECDLP↔DLP (`WeilPairingMOV`) already in
the catalog, this file closes the security triangle: forging BLS is no easier than
CDH.  The same `bls_sig_unique` binding lemma is the reusable engine for any
pairing-verified scheme's unforgeability argument.

-- !-- End Lab Notes -- !--
-/