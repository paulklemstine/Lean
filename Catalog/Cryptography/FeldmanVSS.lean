import Mathlib
import Cryptography.ShamirSecretSharing

/-!
# Feldman verifiable secret sharing

We isolate the algebraic commitment interface used by Feldman's VSS.  The
codomain group is written additively: `commit a` represents the conventional
multiplicative commitment `g^a`, so addition represents multiplication of
commitments.  Injectivity says that the chosen generator has full exponent
order.  Coefficient commitments are checked by evaluating the committed
coefficient polynomial at a participant's location.
-/

namespace FeldmanVSS

open Polynomial

variable {F G : Type*} [Field F] [AddCommGroup G]

/-- Public coefficient commitments (in additive notation). -/
def commitments (commit : F →+ G) (p : F[X]) (i : ℕ) : G :=
  commit (p.coeff i)

/-- Feldman's verification equation against the public coefficient commitments. -/
def verifies (commit : F →+ G) (p : F[X]) (x claimed : F) : Prop :=
  commit claimed = p.support.sum fun i => commit (p.coeff i * x ^ i)

/-- The public right hand side in Feldman's check is the sum (product in the
usual multiplicative notation) of coefficient commitments weighted by powers
of the participant location. -/
theorem verify_eq_sum_commitments (commit : F →+ G) (p : F[X]) (x : F) :
    commit (p.eval x) =
      p.support.sum fun i => commit (p.coeff i * x ^ i) := by
  rw [Polynomial.eval_eq_sum, Polynomial.sum_def]
  exact map_sum commit _ _

/-- An honest dealer's genuine share always passes Feldman verification. -/
theorem honest_share_verifies (commit : F →+ G) (p : F[X]) (x : F) :
    verifies commit p x (p.eval x) := by
  exact verify_eq_sum_commitments commit p x

/-- **Cheating dealers are caught.**  If the commitment map is injective, every
accepted claimed share is exactly the value of the committed polynomial.
Equivalently, any altered share fails verification. -/
theorem cheating_dealer_caught (commit : F →+ G) (hcommit : Function.Injective commit)
    (p : F[X]) (x claimed : F) (hcheat : claimed ≠ p.eval x) :
    ¬ verifies commit p x claimed := by
  intro hverify
  apply hcheat
  apply hcommit
  exact hverify.trans (verify_eq_sum_commitments commit p x).symm

/-- Accepted shares at enough distinct locations reconstruct the unique
committed polynomial, hence its secret. -/
theorem accepted_shares_reconstruct_committed [DecidableEq F]
    (commit : F →+ G) (hcommit : Function.Injective commit)
    (locations : Finset F) (d : ℕ) (hcard : locations.card = d + 1)
    (committed candidate : F[X])
    (hcommitted : committed.degree ≤ (d : WithBot ℕ))
    (hcandidate : candidate.degree ≤ (d : WithBot ℕ))
    (haccepted : ∀ x ∈ locations, verifies commit committed x (candidate.eval x)) :
    candidate = committed := by
  apply ShamirSecretSharing.reconstruct_from_degree_plus_one locations d hcard
      candidate committed hcandidate hcommitted
  intro x hx
  apply hcommit
  exact (haccepted x hx).trans (verify_eq_sum_commitments commit committed x).symm

end FeldmanVSS