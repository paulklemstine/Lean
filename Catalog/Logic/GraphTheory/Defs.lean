import Mathlib

/-!
# List choosability

A graph is `k`-choosable when every assignment of at least `k` permitted natural-number
colours to each vertex admits a proper colouring selected from those lists.
-/

open SimpleGraph Finset

namespace ListChoosability

/-- List choosability for finite graphs, using natural numbers as a common colour universe. -/
def Choosable {V : Type*} (G : SimpleGraph V) (k : ℕ) : Prop :=
  ∀ L : V → Finset ℕ, (∀ v, k ≤ (L v).card) →
    ∃ c : V → ℕ, (∀ v, c v ∈ L v) ∧ ∀ u v, G.Adj u v → c u ≠ c v

end ListChoosability
/-!
# Finite-field polynomial evaluation statistics

These elementary definitions are shared by the generalized Reed–Muller files.
-/

namespace GRM

open MvPolynomial Finset Fintype

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-- Number of points of finite affine space where a polynomial evaluates to zero. -/
def zeroCount {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) : ℕ :=
  (Finset.univ.filter fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0).card

/-- Hamming weight of the evaluation word of a multivariate polynomial. -/
def hammingWeight {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) : ℕ :=
  (Finset.univ.filter fun x : Fin n → 𝔽 => MvPolynomial.eval x f ≠ 0).card

/-- Weight and zero count partition finite affine space. -/
theorem hammingWeight_add_zeroCount {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) :
    hammingWeight f + zeroCount f = Fintype.card 𝔽 ^ n := by
  unfold hammingWeight zeroCount
  rw [← Finset.card_union_of_disjoint
    (Finset.disjoint_filter.mpr fun _ _ _ => by tauto)]
  have hunion :
      (Finset.univ.filter fun x : Fin n → 𝔽 => MvPolynomial.eval x f ≠ 0) ∪
        (Finset.univ.filter fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0) =
          Finset.univ := by
    ext x
    by_cases hx : MvPolynomial.eval x f = 0 <;> simp [hx]
  rw [hunion]
  simp

/-- Weight is the size of affine space minus the zero count. -/
theorem hammingWeight_eq {n : ℕ} (f : MvPolynomial (Fin n) 𝔽) :
    hammingWeight f = Fintype.card 𝔽 ^ n - zeroCount f := by
  have := hammingWeight_add_zeroCount f
  omega

/-- Cardinality of functions from `Fin n` into a finite type. -/
theorem card_fin_arrow (n : ℕ) : Fintype.card (Fin n → 𝔽) = Fintype.card 𝔽 ^ n := by
  simp

end GRM