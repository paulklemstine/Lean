/-! # CatalogBuild.Tropical.Langlands.ExceptionalGroups

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 46
-/

import Mathlib

noncomputable section

/-- A tropical root system of rank n -/
structure TropicalRootSystem (n : ℕ) where
  roots : Finset (Fin n → ℝ)
  neg_closed : ∀ α ∈ roots, (fun i => -α i) ∈ roots
  zero_not_root : (fun _ => (0 : ℝ)) ∉ roots


theorem root_count_even (n : ℕ) (Φ : TropicalRootSystem n) :
    Even Φ.roots.card := by
  -- Let $S$ be the set of roots of $\Phi$.
  set S := Φ.roots;
  -- Since S is finite, we can pair each root with its negative.
  have h_pairing : ∃ (T : Finset (Finset (Fin n → ℝ))), (∀ t ∈ T, t.card = 2) ∧ (∀ t ∈ T, ∀ α ∈ t, α ∈ S) ∧ (∀ t1 ∈ T, ∀ t2 ∈ T, t1 ≠ t2 → Disjoint t1 t2) ∧ (∀ α ∈ S, ∃ t ∈ T, α ∈ t) := by
    refine' ⟨ Finset.image ( fun α => { α, -α } ) S, _, _, _, _ ⟩ <;> simp +decide [ Finset.disjoint_left ];
    · intro α hα; rw [ Finset.card_pair ] ; simp +decide [ funext_iff ];
      exact not_forall.mp fun h => Φ.zero_not_root <| by convert hα using 1; ext i; linarith [ h i ] ;
    · exact fun x hx => ⟨ hx, Φ.neg_closed x hx ⟩;
    · grind;
    · exact fun α hα => ⟨ α, hα, Or.inl rfl ⟩;
  obtain ⟨ T, hT₁, hT₂, hT₃, hT₄ ⟩ := h_pairing; rw [ show S = Finset.biUnion T id from ?_ ];
  · rw [ Finset.card_biUnion ] <;> aesop;
  · grind


/-- The dominant chamber for a set of positive roots -/
def dominantChamber (n : ℕ) (posRoots : Finset (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  { x | ∀ α ∈ posRoots, ∑ i, α i * x i ≥ 0 }


/-- The dominant chamber is always convex -/
theorem dominantChamber_convex (n : ℕ) (posRoots : Finset (Fin n → ℝ)) :
    Convex ℝ (dominantChamber n posRoots) := by
  intro x hx y hy a b ha hb _
  intro α hα
  simp only [dominantChamber, Set.mem_setOf_eq] at *
  have h1 := hx α hα
  have h2 := hy α hα
  calc ∑ i, α i * (a • x + b • y) i
      = ∑ i, α i * (a * x i + b * y i) := by simp [Pi.add_apply, Pi.smul_apply, smul_eq_mul]
    _ = ∑ i, (a * (α i * x i) + b * (α i * y i)) := by congr 1; ext i; ring
    _ = a * ∑ i, α i * x i + b * ∑ i, α i * y i := by
        rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
    _ ≥ 0 := add_nonneg (mul_nonneg ha h1) (mul_nonneg hb h2)


theorem origin_in_dominantChamber (n : ℕ) (posRoots : Finset (Fin n → ℝ)) :
    (fun _ => (0 : ℝ)) ∈ dominantChamber n posRoots := by
  exact fun α _ => by simp +decide ;


def E6_rank : ℕ := 6

def E6_num_roots : ℕ := 72

def E6_num_positive_roots : ℕ := 36

def E6_coxeter_number : ℕ := 12

def E6_weyl_order : ℕ := 51840


theorem E6_dimension : E6_rank + E6_num_roots = 78 := by native_decide

theorem E6_positive_roots_count : 2 * E6_num_positive_roots = E6_num_roots := by native_decide

theorem E6_weyl_factorization : E6_weyl_order = 2^7 * 3^4 * 5 := by native_decide


def E7_rank : ℕ := 7

def E7_num_roots : ℕ := 126

def E7_num_positive_roots : ℕ := 63

def E7_coxeter_number : ℕ := 18

def E7_weyl_order : ℕ := 2903040


theorem E7_dimension : E7_rank + E7_num_roots = 133 := by native_decide

theorem E7_positive_roots_count : 2 * E7_num_positive_roots = E7_num_roots := by native_decide

theorem E7_weyl_factorization : E7_weyl_order = 2^10 * 3^4 * 5 * 7 := by native_decide


def E8_rank : ℕ := 8

def E8_num_roots : ℕ := 240

def E8_num_positive_roots : ℕ := 120

def E8_coxeter_number : ℕ := 30

def E8_weyl_order : ℕ := 696729600


theorem E8_dimension : E8_rank + E8_num_roots = 248 := by native_decide

theorem E8_positive_roots_count : 2 * E8_num_positive_roots = E8_num_roots := by native_decide

theorem E8_weyl_factorization : E8_weyl_order = 2^14 * 3^5 * 5^2 * 7 := by native_decide


inductive LanglandsDualType
  | SelfDual
  | ExchangeDual


def E6_langlands_dual_type : LanglandsDualType := LanglandsDualType.SelfDual

def E7_langlands_dual_type : LanglandsDualType := LanglandsDualType.SelfDual

def E8_langlands_dual_type : LanglandsDualType := LanglandsDualType.SelfDual


theorem exceptional_E_self_dual :
    E6_langlands_dual_type = LanglandsDualType.SelfDual ∧
    E7_langlands_dual_type = LanglandsDualType.SelfDual ∧
    E8_langlands_dual_type = LanglandsDualType.SelfDual :=
  ⟨rfl, rfl, rfl⟩


structure TropicalSatakeParam (n : ℕ) where
  param : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → param i ≥ param j


def tropicalLFunction (n : ℕ) (sp : TropicalSatakeParam n) (s : ℝ) : ℝ :=
  ∑ i : Fin n, sp.param i * s


theorem tropicalLFunction_zero (n : ℕ) (sp : TropicalSatakeParam n) :
    tropicalLFunction n sp 0 = 0 := by
  simp [tropicalLFunction]


def tropicalWeylCharacter (n : ℕ) (wt x : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, wt i * x i


theorem tropicalWeylCharacter_add_right (n : ℕ) (wt x y : Fin n → ℝ) :
    tropicalWeylCharacter n wt (x + y) =
    tropicalWeylCharacter n wt x + tropicalWeylCharacter n wt y := by
  simp [tropicalWeylCharacter, Pi.add_apply, mul_add, Finset.sum_add_distrib]


theorem tropicalWeylCharacter_smul (n : ℕ) (c : ℝ) (wt x : Fin n → ℝ) :
    tropicalWeylCharacter n (fun i => c * wt i) x =
    c * tropicalWeylCharacter n wt x := by
  simp [tropicalWeylCharacter, mul_assoc, Finset.mul_sum]


theorem innerProduct_comm (n : ℕ) (x y : Fin n → ℝ) :
    innerProduct n x y = innerProduct n y x := by
  simp [innerProduct, mul_comm]


theorem innerProduct_add_right (n : ℕ) (x y z : Fin n → ℝ) :
    innerProduct n x (y + z) = innerProduct n x y + innerProduct n x z := by
  simp [innerProduct, Pi.add_apply, mul_add, Finset.sum_add_distrib]


theorem innerProduct_zero_right (n : ℕ) (x : Fin n → ℝ) :
    innerProduct n x (fun _ => 0) = 0 := by
  simp [innerProduct]


def tropicalCasselmanShalika (n : ℕ) (wt rho : Fin n → ℝ) : ℝ :=
  innerProduct n wt rho


theorem tropicalCasselmanShalika_add (n : ℕ) (w1 w2 rho : Fin n → ℝ) :
    tropicalCasselmanShalika n (w1 + w2) rho =
    tropicalCasselmanShalika n w1 rho + tropicalCasselmanShalika n w2 rho := by
  simp [tropicalCasselmanShalika, innerProduct, Pi.add_apply, add_mul, Finset.sum_add_distrib]


theorem tropicalCasselmanShalika_zero (n : ℕ) (rho : Fin n → ℝ) :
    tropicalCasselmanShalika n (fun _ => 0) rho = 0 := by
  simp [tropicalCasselmanShalika, innerProduct]


end
