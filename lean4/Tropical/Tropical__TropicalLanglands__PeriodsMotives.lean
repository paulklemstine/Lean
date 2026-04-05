import Mathlib

/-!
# Tropical Periods and Motives

Connects tropical L-functions to periods of tropical motives.
-/

noncomputable section

open Real BigOperators Finset

namespace TropicalLanglands.PeriodsMotives

/-! ## Section 1: Tropical Motives -/

structure TropicalMotive (n : ℕ) where
  weights : Fin n → ℝ
  weights_nonneg : ∀ i, weights i ≥ 0

def totalWeight (n : ℕ) (M : TropicalMotive n) : ℝ :=
  ∑ i : Fin n, M.weights i

theorem totalWeight_nonneg (n : ℕ) (M : TropicalMotive n) :
    totalWeight n M ≥ 0 := by
  exact Finset.sum_nonneg fun _ _ => M.weights_nonneg _

/-! ## Section 2: Tropical Periods -/

def tropicalPeriod (n : ℕ) (gamma : Fin n → ℤ) (omega : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, (gamma i : ℝ) * omega i

theorem period_add_cycle (n : ℕ) (g1 g2 : Fin n → ℤ) (omega : Fin n → ℝ) :
    tropicalPeriod n (g1 + g2) omega =
    tropicalPeriod n g1 omega + tropicalPeriod n g2 omega := by
  -- By definition of tropical period, we can expand both sides.
  simp [tropicalPeriod];
  simp +decide only [add_mul, sum_add_distrib]

theorem period_add_form (n : ℕ) (gamma : Fin n → ℤ) (o1 o2 : Fin n → ℝ) :
    tropicalPeriod n gamma (o1 + o2) =
    tropicalPeriod n gamma o1 + tropicalPeriod n gamma o2 := by
  simp [tropicalPeriod, Pi.add_apply, mul_add, Finset.sum_add_distrib]

theorem period_zero_cycle (n : ℕ) (omega : Fin n → ℝ) :
    tropicalPeriod n (fun _ => (0 : ℤ)) omega = 0 := by
  simp [tropicalPeriod]

theorem period_zero_form (n : ℕ) (gamma : Fin n → ℤ) :
    tropicalPeriod n gamma (fun _ => (0 : ℝ)) = 0 := by
  simp [tropicalPeriod]

/-! ## Section 3: Tropical L-functions from Motives -/

def motivicLFunction (n : ℕ) (M : TropicalMotive n) (s : ℝ) : ℝ :=
  ∑ i : Fin n, M.weights i * s

theorem motivicLFunction_eq (n : ℕ) (M : TropicalMotive n) (s : ℝ) :
    motivicLFunction n M s = totalWeight n M * s := by
  simp [motivicLFunction, totalWeight, Finset.sum_mul]

theorem motivicLFunction_at_one (n : ℕ) (M : TropicalMotive n) :
    motivicLFunction n M 1 = totalWeight n M := by
  simp [motivicLFunction_eq]

theorem motivicLFunction_at_zero (n : ℕ) (M : TropicalMotive n) :
    motivicLFunction n M 0 = 0 := by
  simp [motivicLFunction_eq]

/-! ## Section 4: Motivic Galois Group Action -/

def galoisAction (n : ℕ) (sigma : Equiv.Perm (Fin n)) (M : TropicalMotive n) :
    TropicalMotive n where
  weights := M.weights ∘ sigma
  weights_nonneg := fun i => M.weights_nonneg (sigma i)

theorem galoisAction_preserves_totalWeight (n : ℕ) (sigma : Equiv.Perm (Fin n))
    (M : TropicalMotive n) :
    totalWeight n (galoisAction n sigma M) = totalWeight n M := by
  exact Equiv.sum_comp sigma M.weights

theorem galoisAction_preserves_LFunction (n : ℕ) (sigma : Equiv.Perm (Fin n))
    (M : TropicalMotive n) (s : ℝ) :
    motivicLFunction n (galoisAction n sigma M) s = motivicLFunction n M s := by
  convert Equiv.sum_comp sigma fun i => M.weights i * s using 1

theorem galoisAction_id (n : ℕ) (M : TropicalMotive n) :
    galoisAction n 1 M = M := by
  simp [galoisAction, Function.comp_id]

/-! ## Section 5: Tropical Hodge Structure -/

structure TropicalHodgeStructure (n : ℕ) where
  hodgeNumbers : Fin (n + 1) → ℕ
  symmetry : ∀ k : Fin (n + 1),
    hodgeNumbers k = hodgeNumbers ⟨n - k.val, by omega⟩

def hodgeDimension (n : ℕ) (H : TropicalHodgeStructure n) : ℕ :=
  ∑ k : Fin (n + 1), H.hodgeNumbers k

def weight1Hodge (g : ℕ) : TropicalHodgeStructure 1 where
  hodgeNumbers := ![g, g]
  symmetry := by
    intro ⟨k, hk⟩
    interval_cases k <;> simp

theorem weight1Hodge_dimension (g : ℕ) :
    hodgeDimension 1 (weight1Hodge g) = 2 * g := by
  simp [hodgeDimension, weight1Hodge, Fin.sum_univ_two]; ring

/-! ## Section 6: Period Equivalence -/

def periodEquivalent (n : ℕ) (M1 M2 : TropicalMotive n) : Prop :=
  ∀ (gamma : Fin n → ℤ),
    tropicalPeriod n gamma M1.weights = tropicalPeriod n gamma M2.weights

theorem periodEquivalent_refl (n : ℕ) (M : TropicalMotive n) :
    periodEquivalent n M M := fun _ => rfl

theorem periodEquivalent_symm (n : ℕ) (M1 M2 : TropicalMotive n)
    (h : periodEquivalent n M1 M2) : periodEquivalent n M2 M1 :=
  fun gamma => (h gamma).symm

theorem periodEquivalent_trans (n : ℕ) (M1 M2 M3 : TropicalMotive n)
    (h12 : periodEquivalent n M1 M2) (h23 : periodEquivalent n M2 M3) :
    periodEquivalent n M1 M3 :=
  fun gamma => (h12 gamma).trans (h23 gamma)

theorem periodEquiv_same_LFunction (n : ℕ) (M1 M2 : TropicalMotive n)
    (h : periodEquivalent n M1 M2) (s : ℝ) :
    motivicLFunction n M1 s = motivicLFunction n M2 s := by
  have h_totalWeight : ∑ i, M1.weights i = ∑ i, M2.weights i := by
    convert h ( fun _ => 1 ) using 1;
    · unfold tropicalPeriod; norm_num;
    · unfold tropicalPeriod; norm_num;
  unfold motivicLFunction; simp +decide [ ← Finset.sum_mul, h_totalWeight ] ;

/-! ## Section 7: Tropical Betti Numbers -/

def tropicalBetti (genus : ℕ) (k : ℕ) : ℕ :=
  match k with
  | 0 => 1
  | 1 => genus
  | _ => 0

def tropicalEuler (vertices edges : ℕ) : ℤ :=
  (vertices : ℤ) - (edges : ℤ)

def graphGenus (vertices edges : ℕ) : ℤ :=
  1 - tropicalEuler vertices edges

theorem tree_genus_zero (n : ℕ) (hn : n ≥ 1) :
    graphGenus n (n - 1) = 0 := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ graphGenus, tropicalEuler ]

theorem tree_euler (n : ℕ) (hn : n ≥ 1) :
    tropicalEuler n (n - 1) = 1 := by
  unfold tropicalEuler; cases n <;> aesop;

end TropicalLanglands.PeriodsMotives