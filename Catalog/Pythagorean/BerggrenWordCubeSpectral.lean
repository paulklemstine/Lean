import Mathlib

/-!
# Product Noise, Low-Degree Structure, and Spectral Bias on Berggren Word Cubes

This file formalizes the spectral calculus for functions on the finite product space
`Ω_L := (Fin 3)^L ≅ Fin L → Fin 3`, the space of length-`L` words in a 3-symbol
(Berggren) alphabet.

## Main Results

* `singleSiteNoise_const` — constants are eigenvectors with eigenvalue 1
* `singleSiteNoise_meanZero` — mean-zero functions are eigenvectors with eigenvalue ρ
* `degreeLeSubmodule_mono` — degree filtration is monotone
* `productNoise_BWDependsOn` — product noise preserves coordinate dependence
* `productNoise_preserves_degreeLe` — product noise preserves degree ≤ k
* `coordNoise_meanZeroAt` — single-coordinate noise gives ρ on mean-zero functions
* `coordNoise_constantAt` — single-coordinate noise is identity on constant functions
* `productNoise_eigen_on_generator` — degree-d generators have eigenvalue ρ^d
* `productNoise_eigen_on_homogeneousDegree` — the full eigenspace theorem
-/

noncomputable section

open Finset BigOperators Function

namespace BerggrenWordCube

abbrev BerggrenWordSpace (L : ℕ) := Fin L → Fin 3
abbrev BerggrenFn (L : ℕ) := BerggrenWordSpace L → ℝ

/-! ## Single-Site Noise Operator -/

def singleSiteNoise (ρ : ℝ) : (Fin 3 → ℝ) →ₗ[ℝ] (Fin 3 → ℝ) where
  toFun f x := ρ * f x + (1 - ρ) / 3 * ∑ y : Fin 3, f y
  map_add' f g := by ext x; simp only [Pi.add_apply, Finset.sum_add_distrib]; ring
  map_smul' c f := by
    ext x; simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    have : ∑ y : Fin 3, c * f y = c * ∑ y : Fin 3, f y := (Finset.mul_sum ..).symm
    simp only [this]; ring

theorem singleSiteNoise_const (ρ c : ℝ) :
    singleSiteNoise ρ (fun _ : Fin 3 => c) = fun _ => c := by
  ext x; simp [singleSiteNoise, Fin.sum_univ_three]; ring

theorem singleSiteNoise_meanZero (ρ : ℝ) (f : Fin 3 → ℝ)
    (hmean : ∑ x : Fin 3, f x = 0) :
    singleSiteNoise ρ f = ρ • f := by
  ext x; simp [singleSiteNoise, hmean, Pi.smul_apply, smul_eq_mul]

/-! ## Noise Kernel -/

def noiseKernel (ρ : ℝ) (a b : Fin 3) : ℝ :=
  if a = b then ρ + (1 - ρ) / 3 else (1 - ρ) / 3

theorem noiseKernel_sum (ρ : ℝ) (a : Fin 3) :
    ∑ b : Fin 3, noiseKernel ρ a b = 1 := by
  simp only [noiseKernel, Fin.sum_univ_three]; fin_cases a <;> simp <;> ring

theorem noiseKernel_meanZero_action (ρ : ℝ) (a : Fin 3) (f : Fin 3 → ℝ)
    (hf : ∑ b : Fin 3, f b = 0) :
    ∑ b : Fin 3, noiseKernel ρ a b * f b = ρ * f a := by
  have h : ∑ b : Fin 3, noiseKernel ρ a b * f b =
    ρ * f a + (1 - ρ) / 3 * ∑ b : Fin 3, f b := by
    simp only [noiseKernel, Fin.sum_univ_three]; fin_cases a <;> simp <;> ring
  rw [h, hf, mul_zero, add_zero]

/-! ## Product Noise Operator -/

def productNoise (L : ℕ) (ρ : ℝ) : BerggrenFn L →ₗ[ℝ] BerggrenFn L where
  toFun f x := ∑ y : BerggrenWordSpace L, (∏ i : Fin L, noiseKernel ρ (x i) (y i)) * f y
  map_add' f g := by ext x; simp only [Pi.add_apply, mul_add, Finset.sum_add_distrib]
  map_smul' c f := by
    ext x; simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    have : ∀ y, (∏ i, noiseKernel ρ (x i) (y i)) * (c * f y) =
      c * ((∏ i, noiseKernel ρ (x i) (y i)) * f y) := fun y => by ring
    simp_rw [this, ← Finset.mul_sum]

/-! ## Coordinate Dependence -/

def BWDependsOn {L : ℕ} (S : Finset (Fin L)) (f : BerggrenFn L) : Prop :=
  ∀ x y : BerggrenWordSpace L, (∀ i ∈ S, x i = y i) → f x = f y

def dependsOnSubmodule {L : ℕ} (S : Finset (Fin L)) : Submodule ℝ (BerggrenFn L) where
  carrier := { f | BWDependsOn S f }
  add_mem' ha hb x y h := by simp [ha x y h, hb x y h]
  zero_mem' _ _ _ := rfl
  smul_mem' c _ hf x y h := by simp [hf x y h]

def degreeLeSubmodule (L k : ℕ) : Submodule ℝ (BerggrenFn L) :=
  ⨆ (S : Finset (Fin L)) (_ : S.card ≤ k), dependsOnSubmodule S

theorem degreeLeSubmodule_mono {L k₁ k₂ : ℕ} (h : k₁ ≤ k₂) :
    degreeLeSubmodule L k₁ ≤ degreeLeSubmodule L k₂ := by
  unfold degreeLeSubmodule
  apply iSup_le; intro S; apply iSup_le; intro hS
  apply le_trans _ (le_iSup (fun S => ⨆ _ : S.card ≤ k₂, dependsOnSubmodule S) S)
  exact le_iSup (fun _ : S.card ≤ k₂ => dependsOnSubmodule S) (hS.trans h)

theorem productNoise_BWDependsOn {L : ℕ} {S : Finset (Fin L)} {f : BerggrenFn L}
    (ρ : ℝ) (hf : BWDependsOn S f) :
    BWDependsOn S (productNoise L ρ f) := by
  intro x y hxy;
  -- Since $f$ depends only on $S$, we can rewrite $f(y)$ as $f(y')$ where $y'$ is the restriction of $y$ to $S$.
  have h_restrict : ∀ y : BerggrenWordSpace L, f y = f (fun i => if h : i ∈ S then y i else x i) := by
    grind +locals;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ y' : BerggrenWordSpace L, (∏ i : Fin L, noiseKernel ρ (x i) (y' i)) * f y' = ∑ y' : BerggrenWordSpace L, (∏ i : Fin L, noiseKernel ρ (y i) (y' i)) * f y' := by
    apply Finset.sum_bij (fun y' _ => fun i => if h : i ∈ S then y' i else if h' : y' i = x i then y i else if h'' : y' i = y i then x i else y' i);
    · exact fun _ _ => Finset.mem_univ _;
    · intro a₁ _ a₂ _ h; ext i; replace h := congr_fun h i; by_cases hi : i ∈ S <;> simp +decide [ hi ] at h ⊢;
      · exact congr_arg Fin.val h;
      · grind;
    · intro b hb; use fun i => if h : i ∈ S then b i else if h' : b i = x i then y i else if h'' : b i = y i then x i else b i; simp +decide [ funext_iff ] ;
      grind;
    · intro a _;
      congr! 1;
      · grind +locals;
      · grind;
  exact h_fubini

theorem productNoise_preserves_degreeLe (L k : ℕ) (ρ : ℝ) :
    ∀ f ∈ degreeLeSubmodule L k,
      productNoise L ρ f ∈ degreeLeSubmodule L k := by
  intro f hfmodule;
  -- By definition of degreeLeSubmodule, we can write f as a finite sum of elements from dependsOnSubmodule S for S with |S| ≤ k.
  have h_decomp : f ∈ ⨆ (S : Finset (Fin L)) (_ : S.card ≤ k), dependsOnSubmodule S := by
    exact hfmodule;
  rw [ Submodule.mem_iSup_iff_exists_finsupp ] at h_decomp;
  -- Since productNoise is linear, the image of a sum is the sum of the images.
  obtain ⟨g, hgmodule, hgsum⟩ := h_decomp;
  have h_prod_sum : (productNoise L ρ) f = ∑ i ∈ g.support, (productNoise L ρ) (g i) := by
    simp +decide [ ← hgsum, Finsupp.sum ];
  refine' h_prod_sum ▸ Submodule.sum_mem _ _;
  intro i hi; specialize hgmodule i; by_cases hi' : #i ≤ k <;> simp_all +decide [ Submodule.mem_iSup ] ;
  exact Submodule.mem_iSup_of_mem i ( Submodule.mem_iSup_of_mem hi' <| productNoise_BWDependsOn ρ hgmodule )

/-! ## Mean-Zero and Constant-At -/

def meanZeroSubmodule : Submodule ℝ (Fin 3 → ℝ) where
  carrier := { f | ∑ x : Fin 3, f x = 0 }
  add_mem' ha hb := by
    simp only [Set.mem_setOf_eq, Pi.add_apply, Finset.sum_add_distrib] at *; linarith
  zero_mem' := by simp
  smul_mem' c f hf := by
    simp only [Set.mem_setOf_eq, Pi.smul_apply, smul_eq_mul, ← Finset.mul_sum] at *; simp [hf]

def meanZeroAt {L : ℕ} (i : Fin L) (f : BerggrenFn L) : Prop :=
  ∀ x : BerggrenWordSpace L, ∑ v : Fin 3, f (Function.update x i v) = 0

def ConstantAt {L : ℕ} (i : Fin L) (f : BerggrenFn L) : Prop :=
  ∀ x : BerggrenWordSpace L, ∀ v : Fin 3, f (Function.update x i v) = f x

def homogeneousDegreeSubmodule (L d : ℕ) : Submodule ℝ (BerggrenFn L) :=
  Submodule.span ℝ { f | ∃ S : Finset (Fin L), S.card = d ∧
    (∀ i ∈ S, meanZeroAt i f) ∧
    (∀ i ∉ S, ConstantAt i f) }

/-! ## Coordinate Noise -/

def coordNoise (L : ℕ) (ρ : ℝ) (i : Fin L) : BerggrenFn L →ₗ[ℝ] BerggrenFn L where
  toFun f x := ∑ v : Fin 3, noiseKernel ρ (x i) v * f (Function.update x i v)
  map_add' f g := by ext x; simp only [Pi.add_apply, mul_add, Finset.sum_add_distrib]
  map_smul' c f := by
    ext x; simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    have : ∀ v, noiseKernel ρ (x i) v * (c * f (update x i v)) =
      c * (noiseKernel ρ (x i) v * f (update x i v)) := fun v => by ring
    simp_rw [this, ← Finset.mul_sum]

theorem coordNoise_meanZeroAt {L : ℕ} (ρ : ℝ) (i : Fin L)
    (f : BerggrenFn L) (hf : meanZeroAt i f) :
    coordNoise L ρ i f = ρ • f := by
  ext x; simp only [coordNoise, LinearMap.coe_mk, AddHom.coe_mk, Pi.smul_apply, smul_eq_mul]
  convert noiseKernel_meanZero_action ρ (x i) (fun v => f (Function.update x i v)) (hf x) using 1
  rw [Function.update_eq_self]

theorem coordNoise_constantAt {L : ℕ} (ρ : ℝ) (i : Fin L)
    (f : BerggrenFn L) (hf : ConstantAt i f) :
    coordNoise L ρ i f = f := by
  ext x; simp only [coordNoise, LinearMap.coe_mk, AddHom.coe_mk, hf x]
  rw [← Finset.sum_mul, noiseKernel_sum]; ring

theorem coordNoise_preserves_meanZeroAt {L : ℕ} (ρ : ℝ) (i j : Fin L)
    (f : BerggrenFn L) (hij : i ≠ j) (hf : meanZeroAt j f) :
    meanZeroAt j (coordNoise L ρ i f) := by
  intro x;
  -- By definition of `coordNoise`, we can expand the inner sum.
  have h_expand : ∑ v : Fin 3, (coordNoise L ρ i) f (Function.update x j v) = ∑ v : Fin 3, ∑ w : Fin 3, noiseKernel ρ (Function.update x j v i) w * f (Function.update (Function.update x j v) i w) := by
    exact?;
  -- By definition of `Function.update`, we can simplify the expression inside the sum.
  have h_simplify : ∀ v w : Fin 3, f (Function.update (Function.update x j v) i w) = f (Function.update (Function.update x i w) j v) := by
    intros v w
    apply congr_arg f
    funext k
    by_cases hk : k = i <;> by_cases hk' : k = j <;> simp [hk, hk', Function.update];
    · grind;
    · aesop;
    · aesop;
  simp_all +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, Finset.sum_mul ];
  rw [ Finset.sum_comm ];
  exact Finset.sum_eq_zero fun y hy => by rw [ ← Finset.mul_sum _ _ _, hf ] ; simp +decide ;

theorem coordNoise_preserves_constantAt {L : ℕ} (ρ : ℝ) (i j : Fin L)
    (f : BerggrenFn L) (hij : i ≠ j) (hf : ConstantAt j f) :
    ConstantAt j (coordNoise L ρ i f) := by
  intro x y; simp +decide [ coordNoise, hij ] ;
  congr! 2;
  convert hf ( update x i ‹_› ) y using 1;
  exact congr_arg f ( by ext k; by_cases hi : k = i <;> by_cases hj : k = j <;> aesop )

theorem meanZeroAt_smul {L : ℕ} (c : ℝ) (i : Fin L) (f : BerggrenFn L)
    (hf : meanZeroAt i f) : meanZeroAt i (c • f) := by
  intro x; simp only [Pi.smul_apply, smul_eq_mul, ← Finset.mul_sum, hf x, mul_zero]

theorem ConstantAt_smul {L : ℕ} (c : ℝ) (i : Fin L) (f : BerggrenFn L)
    (hf : ConstantAt i f) : ConstantAt i (c • f) := by
  intro x v; simp only [Pi.smul_apply, smul_eq_mul, hf x v]

/-! ## Eigenvalue Theorem -/

/-
Key induction: iterating coordNoise (as List.foldr) over a NoDup list
    on a function that is mean-zero at S and constant elsewhere gives
    ρ^(# of list elements in S) • f.
-/
theorem partialNoise_structured {L : ℕ} (ρ : ℝ) (f : BerggrenFn L)
    (S : Finset (Fin L))
    (hmean : ∀ j ∈ S, meanZeroAt j f)
    (hconst : ∀ j ∉ S, ConstantAt j f)
    (is : List (Fin L)) (hnodup : is.Nodup) :
    List.foldr (fun i g => coordNoise L ρ i g) f is =
      (ρ ^ (is.filter (· ∈ S)).length) • f := by
  nontriviality;
  induction' is with i is ih <;> simp_all +decide [ pow_succ', mul_assoc, mul_left_comm, mul_comm ];
  by_cases hi : i ∈ S <;> simp_all +decide [ List.filter_cons_of_pos, List.filter_cons_of_neg ];
  · rw [ coordNoise_meanZeroAt ρ i f ( hmean i hi ) ] ; simp +decide [ pow_succ', mul_assoc, mul_left_comm, smul_smul ];
    ring;
  · exact congr_arg _ ( coordNoise_constantAt ρ i f ( hconst i hi ) )

/-
productNoise equals foldr of coordNoise over all coordinates (Fubini).
-/
theorem productNoise_eq_foldr_coordNoise {L : ℕ} (ρ : ℝ) (f : BerggrenFn L) :
    productNoise L ρ f =
    List.foldr (fun i g => coordNoise L ρ i g) f (Finset.univ : Finset (Fin L)).toList := by
  -- By induction on the list of coordinates, we can show that the product noise operator is equal to the foldr of the coordinate noise operators.
  have h_ind : ∀ (S : Finset (Fin L)) (f : BerggrenFn L), List.foldr (fun i g => coordNoise L ρ i g) f S.toList = fun x => ∑ y : Fin L → Fin 3, (∏ i ∈ S, noiseKernel ρ (x i) (y i)) * (∏ i ∈ Sᶜ, if y i = x i then 1 else 0) * f y := by
    intro S f; ext x; induction' S using Finset.induction with i S hiS ih generalizing f x; simp_all +decide [ Finset.prod_ite ] ;
    · rw [ Finset.sum_eq_single x ] <;> simp +contextual [ Finset.prod_eq_zero_iff ];
      exact fun y hy => Or.inl <| Function.ne_iff.mp hy;
    · -- Apply the coordinate noise operator to the result of the induction hypothesis.
      have h_coord_noise : (coordNoise L ρ i) (fun x => ∑ y : Fin L → Fin 3, (∏ j ∈ S, noiseKernel ρ (x j) (y j)) * (∏ j ∈ Sᶜ, if y j = x j then 1 else 0) * f y) x = ∑ y : Fin L → Fin 3, (∏ j ∈ insert i S, noiseKernel ρ (x j) (y j)) * (∏ j ∈ (insert i S)ᶜ, if y j = x j then 1 else 0) * f y := by
        unfold coordNoise; simp +decide [ Finset.prod_insert, hiS ] ; ring;
        simp +decide [ Finset.mul_sum _ _ _, mul_assoc, Finset.sum_mul ];
        rw [ Finset.sum_comm ] ; refine' Finset.sum_congr rfl fun y hy => _ ; simp +decide [ Finset.prod_erase, Finset.mem_compl, Finset.mem_erase, hiS, update_apply ] ; ring;
        rw [ Finset.sum_eq_single ( y i ) ] <;> simp +decide [ Finset.prod_ite, Finset.filter_ne', Finset.filter_eq', hiS ] ; ring;
        · rw [ Finset.prod_congr rfl fun j hj => by rw [ if_neg ( by aesop ) ] ] ; ring;
          congr! 2;
          congr 1 with j ; aesop;
        · exact fun b hb => Or.inl <| Or.inr <| ⟨ i, hiS, by aesop ⟩;
      convert congr_arg ( fun g => ( coordNoise L ρ i ) g x ) ( funext fun x => ih f x ) using 1;
      · have h_perm : List.Perm (insert i S).toList (i :: S.toList) := by
          grind +suggestions;
        have h_foldr_perm : ∀ (l1 l2 : List (Fin L)), List.Perm l1 l2 → ∀ (f : BerggrenFn L), List.foldr (fun i g => coordNoise L ρ i g) f l1 = List.foldr (fun i g => coordNoise L ρ i g) f l2 := by
          intros l1 l2 h_perm f; induction' h_perm with l1 l2 h_perm ih generalizing f; aesop;
          · simp +decide [ *, List.foldr ];
          · -- Since the coordinate noise operators commute, the order in which they are applied does not matter.
            have h_comm : ∀ (i j : Fin L) (f : BerggrenFn L), coordNoise L ρ i (coordNoise L ρ j f) = coordNoise L ρ j (coordNoise L ρ i f) := by
              intros i j f; ext x; simp +decide [ coordNoise ] ;
              by_cases hij : i = j <;> simp +decide [ hij, update_apply ];
              simp +decide [ hij, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ];
              rw [ Finset.sum_comm ] ; congr ; ext ; congr ; ext ; simp +decide [ hij, update_apply ] ; ring;
              exact Or.inl ( by rw [ if_neg ( Ne.symm hij ) ] ; rw [ update_comm ( by aesop ) ] );
            simp +decide [ h_comm ];
          · grind;
        exact congr_fun ( h_foldr_perm _ _ h_perm _ ) _;
      · exact h_coord_noise.symm;
  convert h_ind Finset.univ f |> Eq.symm using 2 ; simp +decide [ Finset.compl_eq_univ_sdiff ];
  exact?

/-
Product noise acts as `ρ^d` on generators of the homogeneous degree-`d` submodule.
-/
theorem productNoise_eigen_on_generator
    (L d : ℕ) (ρ : ℝ) (f : BerggrenFn L)
    (S : Finset (Fin L)) (hcard : S.card = d)
    (hmean : ∀ i ∈ S, meanZeroAt i f)
    (hconst : ∀ i ∉ S, ConstantAt i f) :
    productNoise L ρ f = (ρ ^ d) • f := by
  rw [productNoise_eq_foldr_coordNoise,
      partialNoise_structured ρ f S hmean hconst _ (Finset.nodup_toList _)]
  congr 1; rw [← hcard]
  -- The length of the filter of univ.toList by (· ∈ S) equals |S|
  -- The length of the filtered list is equal to the number of elements in S because we are filtering the universal list to include only elements that are in S.
  have h_filter_length : List.length (List.filter (fun x => x ∈ S) (Finset.univ : Finset (Fin L)).toList) = Finset.card (Finset.filter (fun x => x ∈ S) Finset.univ) := by
    rw [ ← Multiset.coe_card ];
    rw [ ← Multiset.toFinset_card_of_nodup ] <;> norm_num [ Finset.nodup_toList ];
    exact List.Nodup.filter _ ( Finset.nodup_toList _ );
  aesop

/-- **Main spectral theorem**: Product noise acts as multiplication by `ρ^d`
    on the entire homogeneous degree-`d` submodule. -/
theorem productNoise_eigen_on_homogeneousDegree
    (L d : ℕ) (ρ : ℝ) :
    ∀ f ∈ homogeneousDegreeSubmodule L d,
      productNoise L ρ f = (ρ ^ d) • f := by
  refine fun f hf => Submodule.span_induction ?_ ?_ ?_ ?_ hf
  · rintro f ⟨S, hS₁, hS₂, hS₃⟩; exact productNoise_eigen_on_generator L d ρ f S hS₁ hS₂ hS₃
  · simp [map_zero, smul_zero]
  · intro f g _ _ hf hg; rw [map_add, hf, hg, smul_add]
  · intro a f _ hf; rw [map_smul, hf, smul_comm]

/-! ## Inner Product and Bias -/

def berggrenInner {L : ℕ} (f g : BerggrenFn L) : ℝ :=
  (1 / (3 ^ L : ℝ)) * ∑ x : BerggrenWordSpace L, f x * g x

def noiseBias {L : ℕ} (ρ : ℝ) (f : BerggrenFn L) : ℝ :=
  berggrenInner (productNoise L ρ f) (fun _ => 1)

end BerggrenWordCube

end