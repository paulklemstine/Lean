import Pythagorean.CayleyHamiltonian.OrderPQComplete

/-!
# Order `5q`, and the square-coset criterion

The general coset-pair criterion of `CosetPair.lean` and the complete order-`pq` theorem of
`OrderPQComplete.lean` specialise to the two statements of this file, which were the first
instances of the transversal configuration to be settled:

* `CayleyHamiltonian.isHamiltonian_of_square_coset_pair` : the case `y = A x²` of the
  coset-pair criterion, whose word `x, x, y, x⁻¹, y, x, …, x` is the smallest nontrivial
  instance of the general pattern;
* `CayleyHamiltonian.isHamiltonian_of_card_eq_five_mul_prime` : every connected Cayley graph of
  a group of order `5q` is hamiltonian.
-/

namespace CayleyHamiltonian

open SimpleGraph

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G] {S : Set G}

/-- **The square-coset criterion.**  Let `|G| = q k` with `q` an odd prime coprime to `k`, let
`⟨a⟩` be normal of order `q`, let `x ∈ S` have odd order `k ≥ 5`, and let `y = A x² ∈ S` with
`A ∈ ⟨a⟩`, `A ≠ 1` — that is, `y` lies in the coset of `x²` but is different from `x²`.  Then
`Cay(G, S)` is hamiltonian.

This is the case `m = 2` of `isHamiltonian_of_coset_pair`: the hamiltonian cycle is the lift,
via the factor group lemma, of the `k`-periodic word `x, x, y, x⁻¹, y, x, …, x`. -/
theorem isHamiltonian_of_square_coset_pair {a x y A : G} {q k : ℕ}
    (hq : q.Prime) (hq2 : q ≠ 2) (hk : 5 ≤ k) (hkodd : Odd k)
    (hx : x ∈ S) (hy : y ∈ S)
    (horda : orderOf a = q) (hordx : orderOf x = k) (hcop : Nat.Coprime q k)
    (hnormal : (Subgroup.zpowers a).Normal)
    (hA : A ∈ Subgroup.zpowers a) (hA1 : A ≠ 1) (hyx : y = A * x ^ 2)
    (hcard : Fintype.card G = q * k) :
    (cayleyGraph G S).IsHamiltonian :=
  isHamiltonian_of_coset_pair hq hq2 hkodd (by norm_num) (by omega) hx hy horda
    hordx hcop hnormal hA hA1 hyx hcard

/-- **All connected Cayley graphs of a group of order `5q` (`q` a prime other than `5`) are
hamiltonian.** -/
theorem isHamiltonian_of_card_eq_five_mul_prime {q : ℕ} (hq : q.Prime) (hq5 : q ≠ 5)
    (hcard : Fintype.card G = 5 * q) (hconn : Subgroup.closure S = ⊤) :
    (cayleyGraph G S).IsHamiltonian :=
  isHamiltonian_of_card_eq_prime_mul_prime (by norm_num) hq (Ne.symm hq5) hcard hconn

end CayleyHamiltonian