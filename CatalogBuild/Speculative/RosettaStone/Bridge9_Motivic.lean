/-! # CatalogBuild.Speculative.RosettaStone.Bridge9_Motivic

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 18
-/

import Mathlib

noncomputable section

/-- A correspondence algebra: formal model of Chow correspondences. -/
class CorrespondenceAlgebra (α : Type*) extends Ring α where
  transpose : α → α
  transpose_involution : ∀ a, transpose (transpose a) = a
  transpose_antimul : ∀ a b, transpose (a * b) = transpose b * transpose a


/-- An idempotent correspondence: the defining data of a Chow motive. -/
structure IdempotentCorrespondence (α : Type*) [CorrespondenceAlgebra α] where
  corr : α
  idem : corr * corr = corr


/-- The identity correspondence (= the diagonal Δ_X). -/
def diagonal_correspondence (α : Type*) [CorrespondenceAlgebra α] :
    IdempotentCorrespondence α where
  corr := 1
  idem := one_mul 1


/-- Zero correspondence (the empty motive). -/
def zero_correspondence (α : Type*) [CorrespondenceAlgebra α] :
    IdempotentCorrespondence α where
  corr := 0
  idem := mul_zero 0


/-- [Section: ## Part 1: Idempotent Correspondences] -/
theorem complement_idem_corr {α : Type*} [CorrespondenceAlgebra α]
    (p : IdempotentCorrespondence α) :
    (1 - p.corr) * (1 - p.corr) = 1 - p.corr := by
  rename_i h';
  cases h';
  cases p;
  rename_i h₁ h₂ h₃ h₄ h₅ h₆;
  simp +decide [ sub_mul, mul_sub, h₆ ]


/-- Motivic weight structure. -/
structure MotivicWeight where
  p : ℤ
  q : ℤ


/-- The Tate motive ℤ(n) has weight (2n, n). -/
def tate_weight (n : ℤ) : MotivicWeight := ⟨2 * n, n⟩


/-- Tate twist preserves the "slope" p/q = 2. -/
theorem tate_slope (n : ℤ) (hn : n ≠ 0) :
    (tate_weight n).p = 2 * (tate_weight n).q := by
  simp [tate_weight]


/-- A Künneth system: a complete system of orthogonal idempotents. -/
structure KunnethSystem (α : Type*) [Ring α] (n : ℕ) where
  projectors : Fin (2 * n + 1) → α
  idempotent : ∀ i, projectors i * projectors i = projectors i
  orthogonal : ∀ i j, i ≠ j → projectors i * projectors j = 0
  complete : ∑ i, projectors i = 1


/-- In a Künneth system, each projector is determined by the others. -/
theorem kunneth_determined {α : Type*} [Ring α] {n : ℕ}
    (K : KunnethSystem α n) (k : Fin (2 * n + 1)) :
    K.projectors k = 1 - ∑ i ∈ Finset.univ.erase k, K.projectors i := by
  have h := K.complete
  rw [← h]
  simp [Finset.sum_erase_eq_sub (Finset.mem_univ k)]


/-- Orthogonal idempotents have zero product. -/
theorem kunneth_zero_product {α : Type*} [Ring α] {n : ℕ}
    (K : KunnethSystem α n) (i j : Fin (2 * n + 1)) (hij : i ≠ j) :
    K.projectors i * K.projectors j = 0 :=
  K.orthogonal i j hij


/-- Bridge 1→9: An idempotent in a commutative ring gives orthogonal decomposition. -/
theorem classical_to_motivic {R : Type*} [CommRing R]
    (e : R) (he : e * e = e) :
    e * (1 - e) = 0 ∧ (1 - e) * e = 0 := by
  constructor
  · have : e * (1 - e) = e - e * e := by ring
    rw [this, he, sub_self]
  · have : (1 - e) * e = e - e * e := by ring
    rw [this, he, sub_self]


/-- Bridge 9→6: A Künneth system gives a module decomposition. -/
theorem motivic_to_derived {R : Type*} [CommRing R] {n : ℕ}
    (K : KunnethSystem R n) (x : R) :
    x = ∑ i : Fin (2 * n + 1), K.projectors i * x := by
  conv_lhs => rw [← one_mul x, ← K.complete]
  rw [Finset.sum_mul]


/-- For ℙⁿ, density is 1. -/
theorem projective_space_full_density (n : ℕ) :
    (2 * n + 1 : ℚ) / (2 * n + 1) = 1 := by
  have hn : (2 * (n : ℚ) + 1) ≠ 0 := by positivity
  exact div_self hn


/-- For a curve of genus g, the motivic density. -/
noncomputable def curve_motivic_density (g : ℕ) : ℚ :=
  3 / (2 * g + 2)


/-- Genus 0 (ℙ¹) has density 3/2 > 1: overcomplete system. -/
theorem genus_zero_density : curve_motivic_density 0 = 3 / 2 := by
  simp [curve_motivic_density]


/-- [Section: ## Part 5: The Motivic Idempotent Density] -/
theorem motivic_density_vanishes :
    ∀ ε : ℚ, 0 < ε → ∃ N : ℕ, ∀ g : ℕ, N ≤ g → curve_motivic_density g < ε := by
  intro ε hε
  obtain ⟨N, hN⟩ : ∃ N : ℝ, ∀ g : ℝ, N ≤ g → 3 / (2 * g + 2) < ε := by
    exact ⟨ 3 / ε + 1, fun g hg => by rw [ div_lt_iff₀ ] <;> nlinarith [ show ( 0 : ℝ ) < ε by positivity, div_mul_cancel₀ 3 ( show ( ε : ℝ ) ≠ 0 by positivity ) ] ⟩;
  obtain ⟨N', hN'⟩ : ∃ N' : ℕ, ∀ g : ℕ, N' ≤ g → (3 : ℝ) / (2 * g + 2) < ε := by
    exact ⟨ ⌈N⌉₊, fun g hg => hN g <| Nat.le_of_ceil_le hg ⟩;
  use N';
  intro g hg
  specialize hN' g hg
  have h_cast : (3 : ℝ) / (2 * g + 2) = (curve_motivic_density g : ℝ) := by
    unfold curve_motivic_density; push_cast; ring;
  exact_mod_cast h_cast ▸ hN'


/-- The zeta function of ℙ¹ coefficients. -/
theorem p1_zeta_coefficients :
    ∀ n : ℕ, (n + 1 : ℤ) = ∑ i ∈ Finset.range (n + 1), 1 := by
  intro n
  simp [Finset.sum_const, Finset.card_range]


end
