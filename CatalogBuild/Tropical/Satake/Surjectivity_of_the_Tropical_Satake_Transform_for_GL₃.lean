/-! # CatalogBuild.Tropical.Satake.Surjectivity_of_the_Tropical_Satake_Transform_for_GL₃

Auto-generated from theorem catalog database.
Domain: Tropical/Satake
Declarations: 43
-/

import Mathlib

/-- First tropical elementary symmetric polynomial: e₁(a,b,c) = max(a, b, c). -/
def e₁ (a b c : ℤ) : ℤ := max a (max b c)


/-- Second tropical elementary symmetric polynomial: e₂(a,b,c) = max(a+b, a+c, b+c). -/
def e₂ (a b c : ℤ) : ℤ := max (a + b) (max (a + c) (b + c))


/-- Third tropical elementary symmetric polynomial: e₃(a,b,c) = a + b + c. -/
def e₃ (a b c : ℤ) : ℤ := a + b + c


/-- The dominant Weyl chamber for GL₃: triples (x,y,z) with 2x ≥ y and 2y ≥ x+z.
These are the dominance conditions characterizing the image of the Satake transform. -/
def WeylChamber : Set (ℤ × ℤ × ℤ) :=
  { p | 2 * p.1 ≥ p.2.1 ∧ 2 * p.2.1 ≥ p.1 + p.2.2 }


/-- A sorted triple (a ≥ b ≥ c) represents a dominant coweight for GL₃. -/
def SortedTriple : Set (ℤ × ℤ × ℤ) :=
  { p | p.1 ≥ p.2.1 ∧ p.2.1 ≥ p.2.2 }


/-- [Section: ### S₃ Invariance] -/
theorem e₁_swap12 (a b c : ℤ) : e₁ b a c = e₁ a b c := by unfold e₁; omega

theorem e₁_cycle (a b c : ℤ) : e₁ b c a = e₁ a b c := by unfold e₁; omega

theorem e₂_swap12 (a b c : ℤ) : e₂ b a c = e₂ a b c := by unfold e₂; omega

theorem e₂_cycle (a b c : ℤ) : e₂ b c a = e₂ a b c := by unfold e₂; omega

theorem e₃_swap12 (a b c : ℤ) : e₃ b a c = e₃ a b c := by unfold e₃; omega

theorem e₃_cycle (a b c : ℤ) : e₃ b c a = e₃ a b c := by unfold e₃; omega


theorem satakeTransform_swap12 (a b c : ℤ) :
    satakeTransform b a c = satakeTransform a b c := by
  simp only [satakeTransform, e₁_swap12, e₂_swap12, e₃_swap12]


theorem satakeTransform_cycle (a b c : ℤ) :
    satakeTransform b c a = satakeTransform a b c := by
  simp only [satakeTransform, e₁_cycle, e₂_cycle, e₃_cycle]


/-- On sorted triples, e₁ simplifies to the first (largest) element. -/
theorem e₁_sorted {a b c : ℤ} (hab : a ≥ b) (hbc : b ≥ c) : e₁ a b c = a := by
  unfold e₁; omega


/-- On sorted triples, e₂ simplifies to a + b (sum of two largest). -/
theorem e₂_sorted {a b c : ℤ} (hab : a ≥ b) (hbc : b ≥ c) : e₂ a b c = a + b := by
  unfold e₂; omega


/-- e₃ is always a + b + c. -/
theorem e₃_val (a b c : ℤ) : e₃ a b c = a + b + c := rfl


/-- Key identity: e₂(a,b,c) = (a+b+c) - min(a, min(b,c)).
Each pairwise sum omits one element; maximizing over them omits the smallest. -/
theorem e₂_eq_sum_sub_min (a b c : ℤ) :
    e₂ a b c = a + b + c - min a (min b c) := by
  unfold e₂; omega


/-- Every triple forms the same multiset as its sorted version (max, mid, min). -/
theorem multiset_eq_sorted (a b c : ℤ) :
    ({a, b, c} : Multiset ℤ) =
    {max a (max b c),
     a + b + c - max a (max b c) - min a (min b c),
     min a (min b c)} := by
  ext x
  change Multiset.count x (a ::ₘ b ::ₘ {c}) =
    Multiset.count x (max a (max b c) ::ₘ
      (a + b + c - max a (max b c) - min a (min b c)) ::ₘ {min a (min b c)})
  simp only [Multiset.count_cons, Multiset.count_singleton]
  simp only [max_def, min_def]
  split_ifs <;> omega


/-- **Tropical Chevalley Theorem for GL₃**: The tropical elementary symmetric
polynomials separate S₃-orbits. If two triples have the same values of
e₁, e₂, e₃, they are permutations of each other. -/
theorem separates_orbits (a b c a' b' c' : ℤ)
    (h1 : e₁ a b c = e₁ a' b' c')
    (h2 : e₂ a b c = e₂ a' b' c')
    (h3 : e₃ a b c = e₃ a' b' c') :
    ({a, b, c} : Multiset ℤ) = {a', b', c'} := by
  rw [multiset_eq_sorted a b c, multiset_eq_sorted a' b' c']
  unfold e₁ e₂ e₃ at *
  suffices max a (max b c) = max a' (max b' c') ∧
      min a (min b c) = min a' (min b' c') ∧
      a + b + c = a' + b' + c' by
    rcases this with ⟨hM, hm, hs⟩; simp only [hM, hm, hs]
  exact ⟨h1, by omega, h3⟩


/-- [Section: ### Dominance Inequalities] -/
theorem dominance_e1_e2 (a b c : ℤ) : 2 * e₁ a b c ≥ e₂ a b c := by
  unfold e₁ e₂; omega


theorem dominance_e2_e3 (a b c : ℤ) : 2 * e₂ a b c ≥ e₁ a b c + e₃ a b c := by
  unfold e₁ e₂ e₃; omega


/-- The Satake transform lands in the Weyl chamber. -/
theorem satakeTransform_mem_WeylChamber (a b c : ℤ) :
    satakeTransform a b c ∈ WeylChamber :=
  ⟨dominance_e1_e2 a b c, dominance_e2_e3 a b c⟩


/-- Every point in the Weyl chamber has a preimage under the Satake transform.
The explicit witness is (x, y-x, z-y). -/
theorem satake_cone_surj (x y z : ℤ) (hxy : 2 * x ≥ y) (hyz : 2 * y ≥ x + z) :
    ∃ a b c : ℤ, e₁ a b c = x ∧ e₂ a b c = y ∧ e₃ a b c = z := by
  refine ⟨x, y - x, z - y, ?_, ?_, ?_⟩
  · exact e₁_sorted (by omega) (by omega)
  · rw [e₂_sorted (by omega) (by omega)]; omega
  · unfold e₃; omega


/-- **Tropical Satake Cone**: The image of (e₁, e₂, e₃) : ℤ³ → ℤ³ is exactly
the dominant Weyl chamber {(x,y,z) : 2x ≥ y ∧ 2y ≥ x+z}. -/
theorem image_characterization (x y z : ℤ) :
    (∃ a b c : ℤ, e₁ a b c = x ∧ e₂ a b c = y ∧ e₃ a b c = z) ↔
    (2 * x ≥ y ∧ 2 * y ≥ x + z) := by
  constructor
  · rintro ⟨a, b, c, h1, h2, h3⟩
    exact ⟨h1 ▸ h2 ▸ dominance_e1_e2 a b c, h1 ▸ h2 ▸ h3 ▸ dominance_e2_e3 a b c⟩
  · rintro ⟨hxy, hyz⟩
    exact satake_cone_surj x y z hxy hyz


/-- **Surjectivity of the Tropical Satake Transform**: Every point in the dominant
Weyl chamber is the image of some triple under the Satake transform. -/
theorem satakeTransform_surjective :
    ∀ p ∈ WeylChamber, ∃ a b c : ℤ, satakeTransform a b c = p := by
  rintro ⟨x, y, z⟩ ⟨hxy, hyz⟩
  obtain ⟨a, b, c, h1, h2, h3⟩ := satake_cone_surj x y z hxy hyz
  exact ⟨a, b, c, show satakeTransform a b c = (x, y, z) by
    simp only [satakeTransform, Prod.mk.injEq]; exact ⟨h1, h2, h3⟩⟩


/-- The explicit inverse: given a point in the Weyl chamber, construct the
canonical sorted preimage. -/
def satakeInverse (p : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (p.1, p.2.1 - p.1, p.2.2 - p.2.1)


/-- The inverse lands in sorted triples when applied to Weyl chamber points. -/
theorem satakeInverse_sorted {p : ℤ × ℤ × ℤ} (hp : p ∈ WeylChamber) :
    satakeInverse p ∈ SortedTriple := by
  obtain ⟨x, y, z⟩ := p
  obtain ⟨hxy, hyz⟩ := hp
  dsimp at hxy hyz
  exact ⟨by simp [satakeInverse]; omega, by simp [satakeInverse]; omega⟩


/-- The Satake transform composed with the inverse is the identity on the Weyl chamber. -/
theorem satakeTransform_inverse {p : ℤ × ℤ × ℤ} (hp : p ∈ WeylChamber) :
    let inv := satakeInverse p
    satakeTransform inv.1 inv.2.1 inv.2.2 = p := by
  obtain ⟨x, y, z⟩ := p
  obtain ⟨hxy, hyz⟩ := hp; dsimp at hxy hyz
  simp only [satakeInverse, satakeTransform, Prod.mk.injEq]
  exact ⟨e₁_sorted (by omega) (by omega),
    by rw [e₂_sorted (by omega) (by omega)]; omega,
    by unfold e₃; omega⟩


/-- The inverse composed with the Satake transform is the identity on sorted triples. -/
theorem satakeInverse_transform {a b c : ℤ} (hab : a ≥ b) (hbc : b ≥ c) :
    satakeInverse (satakeTransform a b c) = (a, b, c) := by
  simp only [satakeTransform, satakeInverse, Prod.mk.injEq]
  exact ⟨e₁_sorted hab hbc,
    by rw [e₂_sorted hab hbc, e₁_sorted hab hbc]; omega,
    by rw [e₃_val, e₂_sorted hab hbc]; omega⟩


/-- The Satake transform is injective on sorted triples. -/
theorem satake_injective_sorted (a b c a' b' c' : ℤ)
    (hab : a ≥ b) (hbc : b ≥ c) (hab' : a' ≥ b') (hbc' : b' ≥ c')
    (h1 : e₁ a b c = e₁ a' b' c')
    (h2 : e₂ a b c = e₂ a' b' c')
    (h3 : e₃ a b c = e₃ a' b' c') :
    a = a' ∧ b = b' ∧ c = c' := by
  rw [e₁_sorted hab hbc, e₁_sorted hab' hbc'] at h1
  rw [e₂_sorted hab hbc, e₂_sorted hab' hbc'] at h2
  rw [e₃_val, e₃_val] at h3
  exact ⟨h1, by omega, by omega⟩


/-- The Satake transform restricted to sorted triples maps into the Weyl chamber. -/
def satakeTransformRestricted (p : SortedTriple) : WeylChamber :=
  ⟨satakeTransform p.1.1 p.1.2.1 p.1.2.2, satakeTransform_mem_WeylChamber _ _ _⟩


/-- The inverse map from the Weyl chamber to sorted triples. -/
def satakeInverseRestricted (p : WeylChamber) : SortedTriple :=
  ⟨satakeInverse p.1, by obtain ⟨⟨x, y, z⟩, hp⟩ := p; exact satakeInverse_sorted hp⟩


/-- Right inverse: Satake ∘ inverse = id on the Weyl chamber. -/
theorem satakeTransformRestricted_rightInverse :
    Function.RightInverse satakeInverseRestricted satakeTransformRestricted := by
  intro ⟨⟨x, y, z⟩, hp⟩
  exact Subtype.ext (satakeTransform_inverse hp)


/-- Left inverse: inverse ∘ Satake = id on sorted triples. -/
theorem satakeTransformRestricted_leftInverse :
    Function.LeftInverse satakeInverseRestricted satakeTransformRestricted := by
  intro ⟨⟨a, b, c⟩, hab, hbc⟩
  exact Subtype.ext (satakeInverse_transform hab hbc)


/-- The Satake transform restricted to sorted triples is bijective. -/
theorem satakeTransformRestricted_bijective :
    Function.Bijective satakeTransformRestricted :=
  satakeEquiv.bijective


/-- The Satake transform restricted to sorted triples is surjective. -/
theorem satakeTransformRestricted_surjective :
    Function.Surjective satakeTransformRestricted :=
  satakeTransformRestricted_bijective.2


/-- The Satake transform restricted to sorted triples is injective. -/
theorem satakeTransformRestricted_injective :
    Function.Injective satakeTransformRestricted :=
  satakeTransformRestricted_bijective.1


/-- Tropical power sum p_k(a,b,c) = max(k·a, k·b, k·c). -/
def tropPowerSum (k : ℕ) (a b c : ℤ) : ℤ := max (k * a) (max (k * b) (k * c))


/-- **Tropical Newton's identity**: p_k = k · e₁ for all k ≥ 1. -/
theorem tropical_power_sum (k : ℕ) (hk : k ≥ 1) (a b c : ℤ) :
    tropPowerSum k a b c = k * e₁ a b c := by
  unfold tropPowerSum e₁
  have hk' : (k : ℤ) ≥ 0 := by omega
  simp [mul_max_of_nonneg _ _ hk']


/-- [Section: ### Tropical Fundamental Theorem of Symmetric Polynomials
Every S₃-invariant function on ℤ³ is determined by its values on sorted triples.
Since the Satake transform bijects sorted triples with the Weyl chamber,
S₃-invariant functions correspond bijectively with functions on the chamber.] -/
theorem tropical_fundamental_theorem
    (f g : ℤ → ℤ → ℤ → ℤ)
    (hf_sym12 : ∀ a b c, f b a c = f a b c)
    (hf_sym_cycle : ∀ a b c, f b c a = f a b c)
    (hg_sym12 : ∀ a b c, g b a c = g a b c)
    (hg_sym_cycle : ∀ a b c, g b c a = g a b c)
    (h_agree : ∀ a b c : ℤ, a ≥ b → b ≥ c → f a b c = g a b c) :
    ∀ a b c : ℤ, f a b c = g a b c := by
  grind +locals


/-- The Schur polynomial for the weight (1,0,0) equals e₁. -/
theorem tropSchur_100 (a b c : ℤ) : tropSchur 1 0 0 a b c = e₁ a b c := by
  unfold tropSchur e₁; omega


/-- The Schur polynomial for the weight (1,1,0) equals e₂. -/
theorem tropSchur_110 (a b c : ℤ) : tropSchur 1 1 0 a b c = e₂ a b c := by
  unfold tropSchur e₂; omega


/-- The Schur polynomial for the weight (1,1,1) equals e₃. -/
theorem tropSchur_111 (a b c : ℤ) : tropSchur 1 1 1 a b c = e₃ a b c := by
  unfold tropSchur e₃; omega

