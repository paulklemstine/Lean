import Mathlib

/-!
# Feldman's Verifiable Secret Sharing (VSS)

This file formalizes **Feldman's VSS**, the verifiable upgrade of Shamir's scheme that
forces a (possibly malicious) dealer to commit to its sharing polynomial and lets every
participant *check* its own share without learning others'.

Following the additive group convention used elsewhere in the catalog (cf.
`SchnorrIdentification`), we model the underlying prime-order cyclic group additively as a
field `F` with a fixed nonzero generator `g`.  Group exponentiation `gᵃ` is the scalar
multiple `a * g`.

* The dealer's sharing polynomial is `f : F[X]` with `f.natDegree < t` (degree `< t`).
* The public **commitments** are `Cⱼ = (f.coeff j) * g` for `j < t`  (`feldmanCommit`).
* The **share** of the participant at point `x` is `f.eval x`.
* A claimed share value `s` at point `x` **verifies** iff `s * g = ∑_{j<t} xʲ · Cⱼ`
  (`FeldmanVerifies`).

## Main results

* `feldman_commitment_eval` — the verification right-hand side equals `(f.eval x) * g`.
* `feldman_complete` — **completeness**: an honest dealer's shares always verify.
* `feldman_verify_iff` — verification of a claimed share `s` holds **iff** `s = f.eval x`
  (uses `g ≠ 0`).
* `feldman_catches_cheater` — **soundness / cheating dealers are caught**: any share value
  differing from the committed evaluation `f.eval x` is rejected.
* `feldman_binding` — **binding**: the commitments determine the polynomial; a dealer cannot
  equivocate between two different degree-`< t` polynomials sharing the same commitments.

This bridges the **Cryptography** and **Algebra (polynomial evaluation / commitment binding)**
domains.
-/

namespace FeldmanVSS

open Polynomial Finset

variable {F : Type*} [Field F]

/-- The `j`-th Feldman commitment to polynomial `f` with generator `g`: `g^{aⱼ} = aⱼ · g`. -/
def feldmanCommit (g : F) (f : F[X]) (j : ℕ) : F := f.coeff j * g

/-- The verifier's acceptance predicate: claimed share value `s` at point `x` against the
published commitments `C : ℕ → F` with threshold `t`. -/
def FeldmanVerifies (g : F) (t : ℕ) (C : ℕ → F) (x s : F) : Prop :=
  s * g = ∑ j ∈ Finset.range t, x ^ j * C j

/-
The right-hand side of the verification equation, evaluated on the honest commitments,
equals `(f.eval x) * g`.  This is the algebraic heart of Feldman verification: the
homomorphic combination of the commitments reproduces the commitment to the share.
-/
theorem feldman_commitment_eval (g : F) (t : ℕ) (f : F[X]) (hdeg : f.natDegree < t) (x : F) :
    ∑ j ∈ Finset.range t, x ^ j * feldmanCommit g f j = (f.eval x) * g := by
  rw [ Polynomial.eval_eq_sum_range' hdeg ];
  simp +decide [ feldmanCommit, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

/-
**Completeness.**  An honest dealer's share `f.eval x` always passes verification.
-/
theorem feldman_complete (g : F) (t : ℕ) (f : F[X]) (hdeg : f.natDegree < t) (x : F) :
    FeldmanVerifies g t (feldmanCommit g f) x (f.eval x) := by
  exact feldman_commitment_eval g t f hdeg x |> Eq.symm

/-
**Verification characterization.**  With a nonzero generator `g`, a claimed share `s`
verifies against the honest commitments **iff** it equals the committed evaluation
`f.eval x`.
-/
theorem feldman_verify_iff (g : F) (hg : g ≠ 0) (t : ℕ) (f : F[X]) (hdeg : f.natDegree < t)
    (x s : F) :
    FeldmanVerifies g t (feldmanCommit g f) x s ↔ s = f.eval x := by
  -- By definition of FeldmanVerifies, we have s * g = ∑ j ∈ range t, x^j * (f.coeff j * g).
  rw [FeldmanVerifies];
  rw [ feldman_commitment_eval g t f hdeg x, mul_comm ];
  exact ⟨ fun h => mul_left_cancel₀ hg <| by linear_combination h, fun h => by rw [ h, mul_comm ] ⟩

/-
**Soundness: cheating dealers are caught.**  Any claimed share value `s` that differs
from the committed evaluation `f.eval x` is rejected by the verifier.
-/
theorem feldman_catches_cheater (g : F) (hg : g ≠ 0) (t : ℕ) (f : F[X]) (hdeg : f.natDegree < t)
    (x s : F) (hs : s ≠ f.eval x) :
    ¬ FeldmanVerifies g t (feldmanCommit g f) x s := by
  exact fun h => hs ( feldman_verify_iff g hg t f hdeg x s |>.1 h )

/-
**Binding.**  The commitments bind the dealer to a unique polynomial: if two polynomials
of degree `< t` produce the same Feldman commitments on all of `range t`, they are equal.
Hence a dealer cannot later equivocate about which polynomial it shared.
-/
theorem feldman_binding (g : F) (hg : g ≠ 0) (t : ℕ) (f f' : F[X])
    (hf : f.natDegree < t) (hf' : f'.natDegree < t)
    (hcomm : ∀ j ∈ Finset.range t, feldmanCommit g f j = feldmanCommit g f' j) :
    f = f' := by
  refine' Polynomial.ext fun j => _;
  by_cases hj : j < t <;> simp_all +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt, feldmanCommit ];
  rw [ Polynomial.coeff_eq_zero_of_natDegree_lt ( by linarith ), Polynomial.coeff_eq_zero_of_natDegree_lt ( by linarith ) ]

end FeldmanVSS

/-
-- !-- Lab Notes -- !--

CATEGORY (menu balance): Cross-domain BRIDGE — Cryptography ⟷ Algebra (homomorphic
polynomial commitments, coefficient binding).  Extends the catalog's Σ-protocol line
(`SchnorrIdentification`) with a verifiable secret-sharing primitive using the same
additive group convention `gᵃ ↦ a · g`.

HYPOTHESIS (Hypothesizer).
  H1.  The homomorphic combination `∑_{j<t} xʲ Cⱼ` of Feldman commitments reproduces the
       commitment `f(x)·g` of the share — verification has an exact algebraic meaning.
  H2.  Completeness: honest shares always verify.
  H3 (bold).  Soundness — `cheating dealers are caught`: with a nonzero generator, a share
       verifies IFF it equals the committed evaluation, so any forged share is rejected.
  H4.  Binding: the commitment vector determines the polynomial uniquely; no equivocation.

EXPERIMENT (Experimenter).
  * `feldman_commitment_eval` — `Polynomial.eval_eq_sum_range' hdeg` plus `Finset.mul_sum`
    factor the generator out of the homomorphic sum.
  * `feldman_complete` — immediate `.symm` of the above.
  * `feldman_verify_iff` — cancel the nonzero generator (`mul_left_cancel₀`).
  * `feldman_catches_cheater` — contrapositive of the iff.
  * `feldman_binding` — cancel `g` coefficient-wise on `range t`; off-support coefficients
    vanish by `coeff_eq_zero_of_natDegree_lt`; conclude with `Polynomial.ext`.

ANALYSIS (Analyst).
  Every Feldman guarantee rests on a single algebraic identity (`feldman_commitment_eval`)
  combined with injectivity of `(· * g)` on a field when `g ≠ 0`.  Soundness and binding are
  the two cancellation directions: pointwise (one share) and coefficientwise (the whole
  polynomial).  The degree bound `natDegree < t` is what makes the finite `range t` sum
  faithful to `f.eval` — drop it and high-degree coefficients escape the commitment.

CRITIQUE (Critic).
  * Non-triviality: uses `eval_eq_sum_range'`, sum manipulation, field cancellation and
    `Polynomial.ext`; no result is a definitional `rfl` or pure `decide`.
  * `g ≠ 0` is load-bearing for soundness/binding (a zero generator hides everything); it is
    an explicit hypothesis, and completeness (`feldman_complete`) is proved WITHOUT it,
    correctly reflecting that completeness needs no generator assumption.
  * No vacuity: `feldman_catches_cheater` is non-empty since for `t ≥ 1` honest and forged
    shares both exist.

SYNTHESIS (PI).
  Feldman = Shamir (`ShamirSecretSharing`) + a binding homomorphic commitment: privacy is
  inherited from Shamir, while `feldman_verify_iff`/`feldman_binding` add public
  verifiability against a malicious dealer.  Verified axioms: `propext`, `Classical.choice`,
  `Quot.sound`.
-/