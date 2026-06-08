/-
  VSAlgebra: Algebraic Foundations for Vector-Symbolic Architecture

  Bridge: connects near-ring algebra, neural representation capacity,
  and symbolic-numeric computation.
-/
import Mathlib

open Finset BigOperators

namespace VSAlgebra

/-! ## Core Structure -/

@[ext] structure HDVec (α : Type*) (d : ℕ) where
  coord : Fin d → α

namespace HDVec
variable {α : Type*} {d : ℕ}
instance [Inhabited α] : Inhabited (HDVec α d) := ⟨⟨fun _ => default⟩⟩
instance [Zero α] : Zero (HDVec α d) := ⟨⟨fun _ => 0⟩⟩
instance [One α] : One (HDVec α d) := ⟨⟨fun _ => 1⟩⟩
end HDVec

/-- Pointwise addition (superposition). -/
def vSuperpose [Add α] (v w : HDVec α d) : HDVec α d :=
  ⟨fun i => v.coord i + w.coord i⟩

/-- Pointwise multiplication (Hadamard binding). -/
def vBind [Mul α] (v w : HDVec α d) : HDVec α d :=
  ⟨fun i => v.coord i * w.coord i⟩

/-! ## Algebraic Properties -/

section Algebra
variable {α : Type*} {d : ℕ}

theorem vBind_comm [CommMonoid α] (v w : HDVec α d) :
    vBind v w = vBind w v := by ext i; exact mul_comm _ _

theorem vBind_assoc [Monoid α] (u v w : HDVec α d) :
    vBind (vBind u v) w = vBind u (vBind v w) := by ext i; exact mul_assoc _ _ _

theorem vBind_one_left [Monoid α] (v : HDVec α d) :
    vBind (1 : HDVec α d) v = v := by ext i; exact one_mul _

theorem vBind_one_right [Monoid α] (v : HDVec α d) :
    vBind v (1 : HDVec α d) = v := by ext i; exact mul_one _

/-- Exact left distributivity. Makes (V,⊕,⊗) a ring, not just near-ring. -/
theorem vBind_distrib_left [Distrib α] (a b c : HDVec α d) :
    vBind a (vSuperpose b c) = vSuperpose (vBind a b) (vBind a c) := by
  ext i; exact mul_add _ _ _

theorem vBind_distrib_right [Distrib α] (a b c : HDVec α d) :
    vBind (vSuperpose a b) c = vSuperpose (vBind a c) (vBind b c) := by
  ext i; exact add_mul _ _ _

theorem vSuperpose_comm [AddCommMonoid α] (v w : HDVec α d) :
    vSuperpose v w = vSuperpose w v := by ext i; exact add_comm _ _

theorem vSuperpose_assoc [AddMonoid α] (u v w : HDVec α d) :
    vSuperpose (vSuperpose u v) w = vSuperpose u (vSuperpose v w) := by
  ext i; exact add_assoc _ _ _
end Algebra

/-! ## Bipolar (±1) Vectors -/

section Bipolar
variable {d : ℕ}

def IsBipolar (v : HDVec ℤ d) : Prop := ∀ i : Fin d, v.coord i = 1 ∨ v.coord i = -1
def IsBipolarR (v : HDVec ℝ d) : Prop := ∀ i : Fin d, v.coord i = 1 ∨ v.coord i = -1

theorem bipolar_val_sq {a : ℤ} (ha : a = 1 ∨ a = -1) : a * a = 1 := by
  rcases ha with rfl | rfl <;> norm_num

theorem bipolar_val_sq_real {a : ℝ} (ha : a = 1 ∨ a = -1) : a * a = 1 := by
  rcases ha with rfl | rfl <;> norm_num

theorem bipolar_abs_real {a : ℝ} (ha : a = 1 ∨ a = -1) : |a| = 1 := by
  rcases ha with rfl | rfl <;> norm_num

theorem bipolar_mul_bipolar {a b : ℤ} (ha : a = 1 ∨ a = -1) (hb : b = 1 ∨ b = -1) :
    a * b = 1 ∨ a * b = -1 := by
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl <;> simp

theorem vBind_bipolar (v w : HDVec ℤ d) (hv : IsBipolar v) (hw : IsBipolar w) :
    IsBipolar (vBind v w) := fun i => bipolar_mul_bipolar (hv i) (hw i)

/-- v ⊗ v = 1 for bipolar vectors. Foundation of VSA unbinding. -/
theorem vBind_self_bipolar (v : HDVec ℤ d) (hv : IsBipolar v) :
    vBind v v = 1 := by
  ext i; show v.coord i * v.coord i = 1; exact bipolar_val_sq (hv i)

/-- Binding cancellation: v ⊗ (v ⊗ w) = w. Holographic retrieval certificate. -/
theorem vBind_cancel_left (v w : HDVec ℤ d) (hv : IsBipolar v) :
    vBind v (vBind v w) = w := by
  ext i; show v.coord i * (v.coord i * w.coord i) = w.coord i
  rw [← mul_assoc, bipolar_val_sq (hv i), one_mul]

theorem vBind_cancel_right (v w : HDVec ℤ d) (hw : IsBipolar w) :
    vBind (vBind v w) w = v := by
  ext i; show v.coord i * w.coord i * w.coord i = v.coord i
  rw [mul_assoc, bipolar_val_sq (hw i), mul_one]

theorem ones_bipolar : IsBipolar (1 : HDVec ℤ d) := fun _i => Or.inl rfl

end Bipolar

/-! ## Inner Product and Norm -/

section InnerProd
variable {d : ℕ}

def hdInnerProd (v w : HDVec ℝ d) : ℝ := ∑ i : Fin d, v.coord i * w.coord i
def hdNormSq (v : HDVec ℝ d) : ℝ := ∑ i : Fin d, v.coord i ^ 2

theorem hdInnerProd_comm (v w : HDVec ℝ d) :
    hdInnerProd v w = hdInnerProd w v := by
  simp only [hdInnerProd]; congr 1; ext i; ring

theorem hdInnerProd_self (v : HDVec ℝ d) : hdInnerProd v v = hdNormSq v := by
  simp only [hdInnerProd, hdNormSq, sq]

theorem bipolar_normSq (v : HDVec ℝ d) (hv : IsBipolarR v) : hdNormSq v = (d : ℝ) := by
  simp only [hdNormSq]
  trans ∑ _ : Fin d, (1 : ℝ)
  · apply Finset.sum_congr rfl; intro i _
    rcases hv i with h | h <;> simp [h]
  · simp

theorem bipolar_innerProd_self (v : HDVec ℝ d) (hv : IsBipolarR v) :
    hdInnerProd v v = (d : ℝ) := by rw [hdInnerProd_self, bipolar_normSq v hv]

theorem cross_correlation_bound (v w : HDVec ℝ d) (hv : IsBipolarR v) (hw : IsBipolarR w) :
    |hdInnerProd v w| ≤ (d : ℝ) := by
  calc |∑ i : Fin d, v.coord i * w.coord i|
      ≤ ∑ i : Fin d, |v.coord i * w.coord i| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ _ : Fin d, (1 : ℝ) := by
        apply Finset.sum_congr rfl; intro i _
        rw [abs_mul, bipolar_abs_real (hv i), bipolar_abs_real (hw i), mul_one]
    _ = d := by simp

theorem hdNormSq_nonneg (v : HDVec ℝ d) : 0 ≤ hdNormSq v :=
  Finset.sum_nonneg fun _i _ => sq_nonneg _

theorem hdInnerProd_bind_first (v w : HDVec ℝ d) (hv : IsBipolarR v) :
    hdInnerProd (vBind v w) v = ∑ i : Fin d, w.coord i := by
  simp only [hdInnerProd, vBind]; apply Finset.sum_congr rfl; intro i _
  rw [show v.coord i * w.coord i * v.coord i = w.coord i * (v.coord i * v.coord i) by ring,
      bipolar_val_sq_real (hv i), mul_one]

end InnerProd

/-! ## Cosine Similarity -/

section Cosine
variable {d : ℕ}

noncomputable def cosineSim (v w : HDVec ℝ d) : ℝ :=
  hdInnerProd v w / (Real.sqrt (hdNormSq v) * Real.sqrt (hdNormSq w))

theorem cosineSim_comm (v w : HDVec ℝ d) : cosineSim v w = cosineSim w v := by
  simp [cosineSim, hdInnerProd_comm, mul_comm]

theorem cosineSim_self_bipolar (hd : 0 < d) (v : HDVec ℝ d) (hv : IsBipolarR v) :
    cosineSim v v = 1 := by
  simp only [cosineSim, bipolar_innerProd_self v hv, bipolar_normSq v hv]
  have hd' : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  rw [← Real.sqrt_mul (le_of_lt hd'), Real.sqrt_mul_self (le_of_lt hd')]
  exact div_self (ne_of_gt hd')

end Cosine

/-! ## Capacity Bounds -/

section Capacity

/-- Capacity bound: d/ε² symbols in d dimensions at error ε.
    Application: certified_robustness and post_quantum_security. -/
noncomputable def capacityBound (d : ℕ) (ε : ℝ) : ℝ := (d : ℝ) / ε ^ 2

theorem capacityBound_pos (d : ℕ) (hd : 0 < d) (ε : ℝ) (hε : 0 < ε) :
    0 < capacityBound d ε := div_pos (Nat.cast_pos.mpr hd) (sq_pos_of_pos hε)

theorem capacityBound_mono_dim (d₁ d₂ : ℕ) (ε : ℝ) (hε : 0 < ε) (h : d₁ ≤ d₂) :
    capacityBound d₁ ε ≤ capacityBound d₂ ε :=
  div_le_div_of_nonneg_right (Nat.cast_le.mpr h) (sq_pos_of_pos hε).le

theorem capacityBound_at_one (d : ℕ) : capacityBound d 1 = (d : ℝ) := by
  simp [capacityBound]

theorem capacityBound_double_dim (d : ℕ) (ε : ℝ) :
    capacityBound (2 * d) ε = 2 * capacityBound d ε := by
  simp only [capacityBound]; push_cast; ring

theorem capacityBound_half_eps (d : ℕ) (ε : ℝ) (hε : 0 < ε) :
    capacityBound d (ε / 2) = 4 * capacityBound d ε := by
  simp only [capacityBound]; field_simp; ring

theorem capacity_dimension_bound (n d : ℕ) (ε : ℝ) (hε : 0 < ε)
    (h : (n : ℝ) ≤ capacityBound d ε) :
    (n : ℝ) * ε ^ 2 ≤ (d : ℝ) := by
  have h2 : (n : ℝ) ≤ (d : ℝ) / ε ^ 2 := h
  rwa [le_div_iff₀ (sq_pos_of_pos hε)] at h2

theorem dim_error_product (d : ℕ) (ε : ℝ) (hε : 0 < ε) :
    capacityBound d ε * ε ^ 2 = (d : ℝ) := by
  have : (d : ℝ) / ε ^ 2 * ε ^ 2 = (d : ℝ) := by field_simp
  exact this

end Capacity

/-! ## Interference Analysis -/

section Interference
variable {d n : ℕ}

def interferenceSum (symbols : Fin n → HDVec ℝ d) (j : Fin n) : ℝ :=
  ∑ k : Fin n, if k = j then 0 else hdInnerProd (symbols j) (symbols k)

theorem orthogonal_zero_interference (symbols : Fin n → HDVec ℝ d)
    (h_orth : ∀ j k : Fin n, j ≠ k → hdInnerProd (symbols j) (symbols k) = 0)
    (j : Fin n) : interferenceSum symbols j = 0 := by
  apply Finset.sum_eq_zero
  intro k _
  split_ifs with hk
  · rfl
  · exact h_orth j k (fun h => hk h.symm)

end Interference

/-! ## Compositional Depth -/

section CompDepth
variable {d : ℕ}

theorem kfold_bipolar (k : ℕ) (vs : Fin k → HDVec ℤ d) (hvs : ∀ j, IsBipolar (vs j))
    (i : Fin d) : (∏ j : Fin k, (vs j).coord i) = 1 ∨
                   (∏ j : Fin k, (vs j).coord i) = -1 := by
  induction k with
  | zero => left; simp
  | succ n ih =>
    rw [Fin.prod_univ_castSucc]
    rcases ih (fun j => vs j.castSucc) (fun j => hvs j.castSucc) with h1 | h1 <;>
      rcases hvs (Fin.last n) i with h2 | h2 <;> simp [h1, h2]

noncomputable def maxCompDepth (d : ℕ) : ℝ := Real.sqrt d

theorem maxCompDepth_pos (hd : 0 < d) : 0 < maxCompDepth d :=
  Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd)

theorem maxCompDepth_sq : maxCompDepth d ^ 2 = (d : ℝ) := by
  simp only [maxCompDepth]
  exact Real.sq_sqrt (Nat.cast_nonneg d)

end CompDepth

/-! ## Approximate Near-Ring -/

section ApproxNR

class ApproxNearRingStr (V : Type*) (ε : ℝ) [NormedAddCommGroup V] [Mul V] where
  approx_distrib : ∀ a b c : V, ‖a * (b + c) - (a * b + a * c)‖ ≤ ε

theorem hadamard_exact_distrib {d : ℕ} [Ring α] (a b c : Fin d → α) :
    (fun i => a i * (b i + c i)) = (fun i => a i * b i + a i * c i) := by
  ext i; simp [mul_add]

theorem vBind_distrib_finsum {d n : ℕ} [Ring α] (a : HDVec α d) (bs : Fin n → HDVec α d) :
    vBind a ⟨fun i => ∑ k : Fin n, (bs k).coord i⟩ =
    ⟨fun i => ∑ k : Fin n, (vBind a (bs k)).coord i⟩ := by
  ext i; simp [vBind, Finset.mul_sum]

end ApproxNR

/-! ## Group Embedding -/

section GroupEmbed

structure HolographicRepr (G : Type*) [Group G] (d : ℕ) where
  embed : G → HDVec ℤ d
  embed_bipolar : ∀ g, IsBipolar (embed g)
  embed_inj : Function.Injective embed

def embeddingNoise (G : Type*) [Group G] {d : ℕ} (φ : G → HDVec ℤ d) (g h : G) : ℕ :=
  (Finset.univ.filter (fun i : Fin d =>
    (vBind (φ g) (φ h)).coord i ≠ (φ (g * h)).coord i)).card

def IsPerfectHom (G : Type*) [Group G] {d : ℕ} (φ : G → HDVec ℤ d) : Prop :=
  ∀ g h : G, vBind (φ g) (φ h) = φ (g * h)

theorem perfect_hom_zero_noise (G : Type*) [Group G] {d : ℕ}
    (φ : G → HDVec ℤ d) (hφ : IsPerfectHom G φ) :
    ∀ g h : G, embeddingNoise G φ g h = 0 := by
  intro g h; simp [embeddingNoise, hφ g h]

theorem trivial_group_perfect_hom {d : ℕ} :
    IsPerfectHom Unit (fun (_ : Unit) => (1 : HDVec ℤ d)) := by
  intro g h; cases g; cases h
  show vBind 1 1 = 1
  exact vBind_one_left 1

end GroupEmbed

/-! ## Permutation -/

section Perm
variable {α : Type*} {d : ℕ}

def vPermute (k : ℕ) (v : HDVec α d) (hd : 0 < d) : HDVec α d :=
  ⟨fun i => v.coord ⟨(i.val + k) % d, Nat.mod_lt _ hd⟩⟩

theorem vPermute_zero (v : HDVec α d) (hd : 0 < d) : vPermute 0 v hd = v := by
  ext i; simp [vPermute, Nat.mod_eq_of_lt i.isLt]

theorem vPermute_period (v : HDVec α d) (hd : 0 < d) : vPermute d v hd = v := by
  ext i; simp [vPermute, Nat.add_mod_right, Nat.mod_eq_of_lt i.isLt]

theorem vPermute_bipolar (k : ℕ) (v : HDVec ℤ d) (hd : 0 < d) (hv : IsBipolar v) :
    IsBipolar (vPermute k v hd) := fun _ => hv _

end Perm

/-! ## CommMonoid Instance -/

instance hdVecCommMonoid (d : ℕ) : CommMonoid (HDVec ℤ d) where
  mul := vBind; mul_assoc := vBind_assoc; one := 1
  one_mul := vBind_one_left; mul_one := vBind_one_right; mul_comm := vBind_comm

instance hdVecCommMonoidReal (d : ℕ) : CommMonoid (HDVec ℝ d) where
  mul := vBind; mul_assoc := vBind_assoc; one := 1
  one_mul := vBind_one_left; mul_one := vBind_one_right; mul_comm := vBind_comm

/-! ## Hamming Distance -/

section Hamming
variable {d : ℕ}

def hammingDist (v w : HDVec ℤ d) : ℕ :=
  (Finset.univ.filter (fun i : Fin d => v.coord i ≠ w.coord i)).card

theorem hammingDist_comm (v w : HDVec ℤ d) : hammingDist v w = hammingDist w v := by
  simp [hammingDist, ne_comm]

theorem hammingDist_self (v : HDVec ℤ d) : hammingDist v v = 0 := by simp [hammingDist]

theorem hammingDist_le_dim (v w : HDVec ℤ d) : hammingDist v w ≤ d := by
  calc (Finset.univ.filter (fun i : Fin d => v.coord i ≠ w.coord i)).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = d := Finset.card_fin d

theorem hammingDist_zero_iff (v w : HDVec ℤ d) : hammingDist v w = 0 ↔ v = w := by
  constructor
  · intro h
    simp only [hammingDist, Finset.card_eq_zero, Finset.filter_eq_empty_iff,
               Finset.mem_univ, true_implies, not_not] at h
    exact HDVec.ext (funext h)
  · rintro rfl; exact hammingDist_self _

/-
Triangle inequality for Hamming distance.
-/
theorem hammingDist_triangle (u v w : HDVec ℤ d) :
    hammingDist u w ≤ hammingDist u v + hammingDist v w := by
  -- The Hamming distance counts positions where coordinates differ. For any position i, if u.coord i ≠ w.coord i, then either u.coord i ≠ v.coord i or v.coord i ≠ w.coord i (since if both were equal, u.coord i = v.coord i = w.coord i, contradiction).
  have h_triangle : Finset.univ.filter (fun i => u.coord i ≠ w.coord i) ⊆ Finset.univ.filter (fun i => u.coord i ≠ v.coord i) ∪ Finset.univ.filter (fun i => v.coord i ≠ w.coord i) := by
    grind +locals;
  exact le_trans ( Finset.card_le_card h_triangle ) ( Finset.card_union_le _ _ )

end Hamming

/-! ## Scaling Laws -/

theorem capacity_reliability_tradeoff (d : ℕ) (ε : ℝ) (hε : 0 < ε) :
    ∀ n : ℕ, (n : ℝ) ≤ capacityBound d ε → (n : ℝ) * ε ^ 2 ≤ d :=
  fun n hn => capacity_dimension_bound n d ε hε hn

end VSAlgebra