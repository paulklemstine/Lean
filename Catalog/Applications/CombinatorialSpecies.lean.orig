/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Combinatorial Species as Functors and the Exponential Generating Function Bridge

This file formalizes a fragment of Joyal's theory of **combinatorial species** and the
classical bridge to **analytic functors / exponential generating functions (EGF)**.

A species is modeled (in skeletal form) as a functor from the *groupoid of finite sets*
to finite sets: a family `obj : ℕ → Type` of finite "structure types", together with a
functorial action of the symmetric group `Equiv.Perm (Fin n)` (relabelling) on each
`obj n`.  Its EGF is the formal power series

  `EGF F = ∑ₙ (|F[n]| / n!) Xⁿ`.

The central enumerative-combinatorics ↔ analysis dictionary established here is:

* **sum of species ↔ sum of EGFs**            (`egf_add`)
* **product of species ↔ product of EGFs**    (`egf_mul`, `egf_card_prodSpecies`)
* **species of sets `E` ↔ `exp`**             (`EGF_setSpecies`)
* **species of linear orders `L` ↔ 1/(1-X)**  (`egf_linearOrderSpecies`)

The product law is the heart of the bridge: the *structural* product of species (the
Day-convolution `(F·G)[n] = Σ_{S ⊆ [n]} F[S] × G[n∖S]`) has cardinality the **binomial
convolution** of the counting sequences, which is exactly the Cauchy product of the EGFs.

## Main results
* `egf_add`              — additivity of the EGF.
* `egf_mul`              — binomial convolution of counting sequences ↔ product of EGFs.
* `EGF_setSpecies`       — EGF of the species of sets equals `PowerSeries.exp ℚ`.
* `egf_linearOrderSpecies` — `(1 - X) · EGF(L) = 1`, i.e. EGF of linear orders is `1/(1-X)`.
* `card_prodSpecies`     — cardinality of the structural product is the binomial convolution.
* `egf_card_prodSpecies` — the full bridge: EGF of the structural product = product of EGFs.
-/
import Mathlib

open scoped BigOperators
open PowerSeries Finset

namespace CombinatorialSpecies

noncomputable section

/-! ### Exponential generating functions of counting sequences -/

/-- The exponential generating function of a counting sequence `a : ℕ → ℚ`,
namely `∑ₙ (aₙ / n!) Xⁿ`. -/
noncomputable def egf (a : ℕ → ℚ) : ℚ⟦X⟧ := PowerSeries.mk fun n => a n / n.factorial

@[simp] lemma coeff_egf (a : ℕ → ℚ) (n : ℕ) :
    PowerSeries.coeff (R := ℚ) n (egf a) = a n / n.factorial := by
  rw [egf, coeff_mk]

/-- The binomial (exponential) convolution of two counting sequences:
`(a ⋆ b)ₙ = ∑_{i+j=n} C(n,i) aᵢ bⱼ`.  This is the counting sequence of the product species. -/
def binConv (a b : ℕ → ℚ) : ℕ → ℚ :=
  fun n => ∑ p ∈ Finset.antidiagonal n, (n.choose p.1 : ℚ) * a p.1 * b p.2

-- !-- Compare `coeff n` on both sides: it splits additively as `(aₙ + bₙ)/n!`. -- !--
/-- **Sum law.** The EGF of a (pointwise) sum of counting sequences is the sum of EGFs.
This is the analytic shadow of the disjoint-union (sum) of species. -/
theorem egf_add (a b : ℕ → ℚ) : egf (fun n => a n + b n) = egf a + egf b := by
  unfold egf; ext n; norm_num; ring

-- !-- Compare `coeff n`: the Cauchy product over `antidiagonal n` matches the binomial
--     convolution divided by `n!`, via `Nat.choose_mul_factorial_mul_factorial`. -- !--
/-- **Product law (combinatorial–analytic bridge).** The EGF of the binomial convolution of
two counting sequences equals the *product* of their EGFs.  Equivalently, the exponential
generating function is a ring homomorphism from `(ℕ → ℚ, ⋆)` to formal power series. -/
theorem egf_mul (a b : ℕ → ℚ) : egf (binConv a b) = egf a * egf b := by
  ext n
  simp +decide [egf, binConv, PowerSeries.coeff_mul]
  field_simp
  rw [Finset.mul_sum _ _ _]
  refine Finset.sum_congr rfl fun x hx => ?_
  rw [Nat.cast_choose]
  · rw [show x.2 = n - x.1 by
        rw [Finset.mem_antidiagonal] at hx; rw [eq_tsub_iff_add_eq_of_le] <;> linarith]
    ring
  · linarith [Finset.mem_antidiagonal.mp hx]

-- !-- `coeff n (egf (fun _ => 1)) = 1/n! = coeff n (exp ℚ)`, since `algebraMap ℚ ℚ = id`. -- !--
/-- **Species of sets ↔ exponential.** The EGF of the constant-one counting sequence
(the species `E` of sets, with one structure on every label set) is `exp`. -/
theorem egf_const_one : egf (fun _ => (1 : ℚ)) = PowerSeries.exp ℚ := by
  ext n
  rw [coeff_egf, coeff_exp]
  simp

-- !-- `egf (fun n => n!) = mk (fun _ => 1)`, the geometric series, whose `(1-X)`-multiple is 1. -- !--
/-- **Species of linear orders ↔ `1/(1-X)`.** Since there are `n!` linear orders on `n`
labels, the EGF of the species of linear orders is the geometric series `1/(1-X)`, i.e.
`(1 - X) · EGF = 1`. -/
theorem egf_linearOrderSpecies :
    (1 - PowerSeries.X) * egf (fun n => (n.factorial : ℚ)) = 1 := by
  ext (_ | n) <;> simp +decide [PowerSeries.coeff_one, egf]
  simp +decide [sub_mul, Nat.factorial_ne_zero]

/-! ### Species as functors on the groupoid of finite sets -/

/-- A **combinatorial species** in skeletal form: a family of finite structure types
`obj n` (structures on an `n`-element label set), together with a functorial action of the
relabelling group `Equiv.Perm (Fin n)`.  The monoid-hom field encodes functoriality on the
core groupoid of finite sets. -/
structure Species where
  /-- `obj n` = the (finite) set of `F`-structures on a fixed `n`-element label set. -/
  obj : ℕ → Type
  /-- Each structure set is finite. -/
  fintypeObj : ∀ n, Fintype (obj n)
  /-- Relabelling acts functorially: `Sₙ → Perm (F[n])`. -/
  act : ∀ n, Equiv.Perm (Fin n) →* Equiv.Perm (obj n)

attribute [instance] Species.fintypeObj

/-- The counting sequence `n ↦ |F[n]|` of a species. -/
def Species.coeffSeq (F : Species) (n : ℕ) : ℕ := Fintype.card (F.obj n)

/-- The exponential generating function of a species. -/
noncomputable def Species.EGF (F : Species) : ℚ⟦X⟧ :=
  egf fun n => (F.coeffSeq n : ℚ)

/-- The **species of sets** `E`: a unique structure on every label set. -/
def setSpecies : Species where
  obj := fun _ => Unit
  fintypeObj := fun _ => inferInstance
  act := fun _ => 1

/-- The **species of linear orders** `L`: a linear order on `n` labels is a bijection with
`Fin n`, of which there are `n!`.  Relabelling acts by the (regular) left translation. -/
def linearOrderSpecies : Species where
  obj := fun n => Equiv.Perm (Fin n)
  fintypeObj := fun _ => inferInstance
  act := fun n => MulAction.toPermHom (Equiv.Perm (Fin n)) (Equiv.Perm (Fin n))

@[simp] lemma coeffSeq_setSpecies (n : ℕ) : setSpecies.coeffSeq n = 1 := by
  simp [Species.coeffSeq, setSpecies]

@[simp] lemma coeffSeq_linearOrderSpecies (n : ℕ) :
    linearOrderSpecies.coeffSeq n = n.factorial := by
  simp [Species.coeffSeq, linearOrderSpecies, Fintype.card_perm]

-- !-- Rewrite the counting sequence to the constant `1`, then apply `egf_const_one`. -- !--
/-- The EGF of the species of sets is `exp`. -/
theorem EGF_setSpecies : setSpecies.EGF = PowerSeries.exp ℚ := by
  convert egf_const_one

/-! ### The structural product of species and the bridge theorem -/

-- !-- `Fintype.card_sigma` then `Fintype.card_prod` reduce to a sum over subsets `S ⊆ [n]`;
--     group by `S.card` (there are `C(n,k)` subsets of size `k`, by `card_powersetCard`). -- !--
/-- **Cardinality of the structural product species.** For structure families `A`, `B`, the
Day-convolution product `(A·B)[n] = Σ_{S ⊆ [n]} A[|S|] × B[n∖S]` has cardinality the binomial
convolution `∑_{i+j=n} C(n,i) |A[i]| |B[j]|` of the counting sequences. -/
theorem card_prodSpecies (A B : ℕ → Type) [∀ k, Fintype (A k)] [∀ k, Fintype (B k)] (n : ℕ) :
    Fintype.card (Σ S : Finset (Fin n), A S.card × B (n - S.card))
      = ∑ p ∈ Finset.antidiagonal n,
          n.choose p.1 * Fintype.card (A p.1) * Fintype.card (B p.2) := by
  simp +decide only [Fintype.card_sigma, Fintype.card_prod]
  rw [Finset.sum_congr rfl fun x hx => by rw [mul_comm]]
  rw [Finset.sum_congr rfl fun x hx => by rw [mul_comm]]
  rw [Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk]
  rw [show (Finset.univ : Finset (Finset (Fin n)))
        = Finset.biUnion (Finset.range (n + 1))
            fun k => Finset.powersetCard k (Finset.univ : Finset (Fin n)) from ?_,
      Finset.sum_biUnion]
  · refine Finset.sum_congr rfl fun i hi => ?_
    rw [Finset.sum_congr rfl fun j hj => by rw [Finset.mem_powersetCard.mp hj |>.2]]
    simp +decide [mul_assoc]
  · exact fun i hi j hj hij => Finset.disjoint_left.mpr fun x hx₁ hx₂ =>
      hij <| by rw [Finset.mem_powersetCard] at hx₁ hx₂; aesop
  · ext s
    simp [Finset.mem_biUnion, Finset.mem_powersetCard]
    exact le_trans (Finset.card_le_univ _) (by norm_num)

-- !-- Combine `card_prodSpecies` (cardinality = binomial convolution) with `egf_mul`
--     (binomial convolution ↔ Cauchy product of EGFs), casting `ℕ → ℚ`. -- !--
/-- **The species–EGF product bridge.** The EGF of the structural product of two species
equals the product of their EGFs.  This is the formal statement that the EGF turns the
combinatorial (Day-convolution) product into the analytic product of power series — the
combinatorial-categorical bridge for the product, i.e. that the EGF realizes the analytic
functor. -/
theorem egf_card_prodSpecies
    (A B : ℕ → Type) [∀ k, Fintype (A k)] [∀ k, Fintype (B k)] :
    egf (fun n => (Fintype.card (Σ S : Finset (Fin n), A S.card × B (n - S.card)) : ℚ))
      = egf (fun n => (Fintype.card (A n) : ℚ)) * egf (fun n => (Fintype.card (B n) : ℚ)) := by
  rw [← egf_mul]
  congr 1 with n
  convert congr_arg ((↑) : ℕ → ℚ) (card_prodSpecies A B n) using 1
  norm_num [binConv]

end

end CombinatorialSpecies