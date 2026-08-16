import Geometry.ToricCode.Homology
/-!
# The `Z`-distance of the `M × N` toric code is exactly `min M N`

This is the geometric heart of the development.  For the grid cellulation of the
torus `(ℤ/M) × (ℤ/N)` we prove

  `distance M N = min M N`,

i.e. the minimal Hamming weight of a cellular one-cycle that is not a boundary
is exactly the smaller of the two side lengths.  Together with
`ToricCode.toric_homologyRank` this establishes the parameters
`[[2MN, 2, min M N]]`, specialising to the classical `[[2L², 2, L]]` for the
square torus.

## Strategy

For each `i : ZMod M` the *column cut* consists of the `N` horizontal edges
`(false, (i, y))`.  The parity of a chain on this cut is `hWind z i`.  Dually
`vWind z j` is the parity on the *row cut* of vertical edges `(true, (x, j))`.

* `hWind_const` / `vWind_const`: for a cycle these parities do not depend on the
  cut.  (This is discrete Stokes: the difference of two neighbouring cut parities
  is the sum of the vertex boundary over a column.)
* `hWind_of_boundary` / `vWind_of_boundary`: they vanish on boundaries.
* `winding_ne_zero_of_not_boundary`: conversely, a cycle with both windings zero
  *is* a boundary.  This is proved by a dimension count: the winding map
  `cycles → 𝔽₂²` is onto, so its kernel has dimension `MN - 1`, which is exactly
  the dimension of the boundary space computed in `ToricCode.Homology`.
* Hence a logical operator has odd parity on each of the `M` pairwise disjoint
  column cuts, or on each of the `N` pairwise disjoint row cuts, so it uses at
  least `min M N` edges; and the two coordinate loops, of weights `M` and `N`,
  realise the bound.
-/

open Matrix

namespace ToricCode

variable (M N : ℕ) [NeZero M] [NeZero N]

/-! ### Winding parities -/

/-- Parity of `z` on the column cut of horizontal edges with first coordinate `i`. -/
def hWind (z : Edge M N → F2) (i : ZMod M) : F2 := ∑ y : ZMod N, z (false, (i, y))

/-- Parity of `z` on the row cut of vertical edges with second coordinate `j`. -/
def vWind (z : Edge M N → F2) (j : ZMod N) : F2 := ∑ x : ZMod M, z (true, (x, j))

/-- Reindexing a sum over `ZMod K` by a translation. -/
lemma sum_shift {K : ℕ} [NeZero K] (f : ZMod K → F2) (a : ZMod K) :
    ∑ y : ZMod K, f (y - a) = ∑ y : ZMod K, f y :=
  Equiv.sum_comp (Equiv.subRight a) f

/-- Neighbouring column cuts have the same parity, for a cycle. -/
lemma hWind_succ {z : Edge M N → F2} (hz : (d1 M N) *ᵥ z = 0) (i : ZMod M) :
    hWind M N z (i + 1) = hWind M N z i := by
  have h : ∑ y : ZMod N, (d1 M N *ᵥ z) (i + 1, y) = 0 := by rw [hz]; simp
  have hexp : ∀ y : ZMod N, (d1 M N *ᵥ z) (i + 1, y)
      = z (false, (i + 1, y)) + z (false, (i, y))
        + (z (true, (i + 1, y)) + z (true, (i + 1, y - 1))) := by
    intro y
    rw [d1_mulVec]
    congr 3 <;> simp
  rw [Finset.sum_congr rfl (fun y _ => hexp y)] at h
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_add_distrib] at h
  have hs : (∑ y : ZMod N, z (true, (i + 1, y - 1))) = ∑ y : ZMod N, z (true, (i + 1, y)) :=
    sum_shift (fun y => z (true, (i + 1, y))) 1
  rw [hs] at h
  simp only [hWind]
  have h2 : ∀ x y c : F2, x + y + (c + c) = 0 → x = y := by decide
  exact h2 _ _ _ h

/-- Neighbouring row cuts have the same parity, for a cycle. -/
lemma vWind_succ {z : Edge M N → F2} (hz : (d1 M N) *ᵥ z = 0) (j : ZMod N) :
    vWind M N z (j + 1) = vWind M N z j := by
  have h : ∑ x : ZMod M, (d1 M N *ᵥ z) (x, j + 1) = 0 := by rw [hz]; simp
  have hexp : ∀ x : ZMod M, (d1 M N *ᵥ z) (x, j + 1)
      = z (true, (x, j + 1)) + z (true, (x, j))
        + (z (false, (x, j + 1)) + z (false, (x - 1, j + 1))) := by
    intro x
    rw [d1_mulVec]
    have e1 : ((x, j + 1) : ZMod M × ZMod N) - (1, 0) = (x - 1, j + 1) := by simp
    have e2 : ((x, j + 1) : ZMod M × ZMod N) - (0, 1) = (x, j) := by simp
    rw [e1, e2]
    ring
  rw [Finset.sum_congr rfl (fun x _ => hexp x)] at h
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_add_distrib] at h
  have hs : (∑ x : ZMod M, z (false, (x - 1, j + 1))) = ∑ x : ZMod M, z (false, (x, j + 1)) :=
    sum_shift (fun x => z (false, (x, j + 1))) 1
  rw [hs] at h
  simp only [vWind]
  have h2 : ∀ x y c : F2, x + y + (c + c) = 0 → x = y := by decide
  exact h2 _ _ _ h

/-- A function on `ZMod K` invariant under `+1` is constant. -/
lemma zmod_const_of_succ {K : ℕ} [NeZero K] (F : ZMod K → F2) (h : ∀ i, F (i + 1) = F i) :
    ∀ i, F i = F 0 := by
  have hn : ∀ n : ℕ, F ((n : ZMod K)) = F 0 := by
    intro n
    induction n with
    | zero => simp
    | succ k ih => rw [Nat.cast_add, Nat.cast_one, h, ih]
  intro i
  rw [← ZMod.natCast_rightInverse i]
  exact hn i.val

lemma hWind_const {z : Edge M N → F2} (hz : (d1 M N) *ᵥ z = 0) (i : ZMod M) :
    hWind M N z i = hWind M N z 0 :=
  zmod_const_of_succ (hWind M N z) (hWind_succ M N hz) i

lemma vWind_const {z : Edge M N → F2} (hz : (d1 M N) *ᵥ z = 0) (j : ZMod N) :
    vWind M N z j = vWind M N z 0 :=
  zmod_const_of_succ (vWind M N z) (vWind_succ M N hz) j

/-! ### Windings vanish on boundaries -/

lemma hWind_of_boundary (g : Face M N → F2) (i : ZMod M) :
    hWind M N (d2 M N *ᵥ g) i = 0 := by
  have hexp : ∀ y : ZMod N, (d2 M N *ᵥ g) (false, (i, y)) = g (i, y) + g (i, y - 1) := by
    intro y
    rw [d2_mulVec]
    simp
  rw [hWind, Finset.sum_congr rfl (fun y _ => hexp y), Finset.sum_add_distrib]
  have hs : (∑ y : ZMod N, g (i, y - 1)) = ∑ y : ZMod N, g (i, y) :=
    sum_shift (fun y => g (i, y)) 1
  rw [hs]
  have h2 : ∀ x : F2, x + x = 0 := by decide
  exact h2 _

lemma vWind_of_boundary (g : Face M N → F2) (j : ZMod N) :
    vWind M N (d2 M N *ᵥ g) j = 0 := by
  have hexp : ∀ x : ZMod M, (d2 M N *ᵥ g) (true, (x, j)) = g (x, j) + g (x - 1, j) := by
    intro x
    rw [d2_mulVec]
    simp
  rw [vWind, Finset.sum_congr rfl (fun x _ => hexp x), Finset.sum_add_distrib]
  have hs : (∑ x : ZMod M, g (x - 1, j)) = ∑ x : ZMod M, g (x, j) :=
    sum_shift (fun x => g (x, j)) 1
  rw [hs]
  have h2 : ∀ x : F2, x + x = 0 := by decide
  exact h2 _

/-! ### The winding map and its surjectivity -/

/-- The pair of winding parities, as a linear functional on one-chains. -/
def psi : (Edge M N → F2) →ₗ[F2] F2 × F2 where
  toFun z := (hWind M N z 0, vWind M N z 0)
  map_add' z w := by
    simp only [hWind, vWind, Pi.add_apply, Finset.sum_add_distrib, Prod.mk_add_mk]
  map_smul' a z := by
    simp only [hWind, vWind, Pi.smul_apply, smul_eq_mul, ← Finset.mul_sum, Prod.smul_mk,
      RingHom.id_apply]

/-- The horizontal logical loop: all horizontal edges of the row `y = 0`. -/
def loopH : Edge M N → F2 := fun e => if e.1 = false ∧ e.2.2 = 0 then 1 else 0

/-- The vertical logical loop: all vertical edges of the column `x = 0`. -/
def loopV : Edge M N → F2 := fun e => if e.1 = true ∧ e.2.1 = 0 then 1 else 0

lemma loopH_cycle : (d1 M N) *ᵥ (loopH M N) = 0 := by
  funext v
  rw [d1_mulVec]
  obtain ⟨x, y⟩ := v
  simp only [loopH]
  have e1 : ((x, y) : ZMod M × ZMod N) - (1, 0) = (x - 1, y) := by simp
  have e2 : ((x, y) : ZMod M × ZMod N) - (0, 1) = (x, y - 1) := by simp
  rw [e1, e2]
  by_cases h : y = 0
  · simp [h]
    decide
  · simp [h]

lemma loopV_cycle : (d1 M N) *ᵥ (loopV M N) = 0 := by
  funext v
  rw [d1_mulVec]
  obtain ⟨x, y⟩ := v
  simp only [loopV]
  have e1 : ((x, y) : ZMod M × ZMod N) - (1, 0) = (x - 1, y) := by simp
  have e2 : ((x, y) : ZMod M × ZMod N) - (0, 1) = (x, y - 1) := by simp
  rw [e1, e2]
  by_cases h : x = 0
  · simp [h]
    decide
  · simp [h]

omit [NeZero M] in
lemma hWind_loopH (i : ZMod M) : hWind M N (loopH M N) i = 1 := by
  rw [hWind]
  have hpt : ∀ y : ZMod N, loopH M N (false, (i, y)) = if (0 : ZMod N) = y then (1 : F2) else 0 := by
    intro y
    simp only [loopH]
    by_cases h : y = 0 <;> simp [h, eq_comm]
  rw [Finset.sum_congr rfl (fun y _ => hpt y)]
  simp

omit [NeZero N] in
lemma vWind_loopH (j : ZMod N) : vWind M N (loopH M N) j = 0 := by
  rw [vWind]
  simp [loopH]

omit [NeZero M] in
lemma hWind_loopV (i : ZMod M) : hWind M N (loopV M N) i = 0 := by
  rw [hWind]
  simp [loopV]

omit [NeZero N] in
lemma vWind_loopV (j : ZMod N) : vWind M N (loopV M N) j = 1 := by
  rw [vWind]
  have hpt : ∀ x : ZMod M, loopV M N (true, (x, j)) = if (0 : ZMod M) = x then (1 : F2) else 0 := by
    intro x
    simp only [loopV]
    by_cases h : x = 0 <;> simp [h, eq_comm]
  rw [Finset.sum_congr rfl (fun x _ => hpt x)]
  simp

/-- The winding map restricted to the cycle space. -/
noncomputable def phi : cycles M N →ₗ[F2] F2 × F2 := (psi M N).comp (cycles M N).subtype

lemma loopH_mem : loopH M N ∈ cycles M N := by
  simpa [cycles, LinearMap.mem_ker] using loopH_cycle M N

lemma loopV_mem : loopV M N ∈ cycles M N := by
  simpa [cycles, LinearMap.mem_ker] using loopV_cycle M N

lemma phi_surjective : Function.Surjective (phi M N) := by
  rintro ⟨a, b⟩
  refine ⟨a • ⟨loopH M N, loopH_mem M N⟩ + b • ⟨loopV M N, loopV_mem M N⟩, ?_⟩
  simp only [phi, LinearMap.comp_apply, map_add, map_smul, Submodule.subtype_apply]
  have h1 : (psi M N) (loopH M N) = (1, 0) := by
    simp only [psi, LinearMap.coe_mk, AddHom.coe_mk]
    rw [hWind_loopH, vWind_loopH]
  have h2 : (psi M N) (loopV M N) = (0, 1) := by
    simp only [psi, LinearMap.coe_mk, AddHom.coe_mk]
    rw [hWind_loopV, vWind_loopV]
  rw [h1, h2]
  simp

/-! ### The kernel of the winding map is exactly the boundary space -/

/-- The subspace of cycles with both windings zero. -/
noncomputable def trivialWinding : Submodule F2 (Edge M N → F2) :=
  Submodule.map (cycles M N).subtype (LinearMap.ker (phi M N))

lemma finrank_trivialWinding : Module.finrank F2 (trivialWinding M N) = M * N - 1 := by
  have hinj : Function.Injective ((cycles M N).subtype) := Submodule.subtype_injective _
  have heq : Module.finrank F2 (trivialWinding M N)
      = Module.finrank F2 (LinearMap.ker (phi M N)) :=
    (LinearEquiv.finrank_eq
      (Submodule.equivMapOfInjective ((cycles M N).subtype) hinj
        (LinearMap.ker (phi M N)))).symm
  have hrk := LinearMap.finrank_range_add_finrank_ker (phi M N)
  have hrange : LinearMap.range (phi M N) = ⊤ := LinearMap.range_eq_top.2 (phi_surjective M N)
  rw [hrange, finrank_top, finrank_cycles] at hrk
  have h2 : Module.finrank F2 (F2 × F2) = 2 := by
    simp [Module.finrank_prod]
  rw [h2] at hrk
  have := one_le_mul M N
  omega

lemma boundaries_le_trivialWinding : boundaries M N ≤ trivialWinding M N := by
  rintro z ⟨g, rfl⟩
  have hz : (d2 M N).mulVecLin g ∈ cycles M N := boundaries_le_cycles M N ⟨g, rfl⟩
  refine ⟨⟨(d2 M N).mulVecLin g, hz⟩, ?_, rfl⟩
  simp only [SetLike.mem_coe, LinearMap.mem_ker]
  simp only [phi, LinearMap.comp_apply, Submodule.subtype_apply, psi, LinearMap.coe_mk,
    AddHom.coe_mk, Matrix.mulVecLin_apply]
  rw [hWind_of_boundary, vWind_of_boundary]
  rfl

/-- **A cycle with trivial winding is a boundary.**  Combined with
`hWind_of_boundary` this identifies the boundary space with the kernel of the
winding map — a purely dimension-theoretic argument. -/
theorem boundaries_eq_trivialWinding : boundaries M N = trivialWinding M N := by
  refine Submodule.eq_of_le_of_finrank_le (boundaries_le_trivialWinding M N) ?_
  rw [finrank_trivialWinding, finrank_boundaries]

/-- A logical operator has at least one nonzero winding. -/
theorem winding_ne_zero_of_not_boundary {z : Edge M N → F2} (hz : z ∈ cycles M N)
    (hnb : z ∉ boundaries M N) : hWind M N z 0 ≠ 0 ∨ vWind M N z 0 ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  apply hnb
  rw [boundaries_eq_trivialWinding]
  refine ⟨⟨z, hz⟩, ?_, rfl⟩
  simp only [SetLike.mem_coe, LinearMap.mem_ker]
  simp only [phi, LinearMap.comp_apply, Submodule.subtype_apply, psi, LinearMap.coe_mk,
    AddHom.coe_mk]
  rw [hcon.1, hcon.2]
  rfl

/-! ### The distance -/

/-- Weights of the logical `Z` operators: cycles that are not boundaries. -/
def logicalWeights : Set ℕ :=
  {w | ∃ z : Edge M N → F2, z ∈ cycles M N ∧ z ∉ boundaries M N ∧ hammingNorm z = w}

/-- The `Z`-distance of the toric code. -/
noncomputable def distance : ℕ := sInf (logicalWeights M N)

lemma support_card_eq (z : Edge M N → F2) :
    hammingNorm z = (Finset.univ.filter (fun e : Edge M N => z e ≠ 0)).card := rfl

/-- A cycle with nonzero horizontal winding meets each of the `M` column cuts. -/
theorem M_le_weight_of_hWind {z : Edge M N → F2} (hz : z ∈ cycles M N)
    (h : hWind M N z 0 ≠ 0) : M ≤ hammingNorm z := by
  have hcyc : (d1 M N) *ᵥ z = 0 := by simpa [cycles, LinearMap.mem_ker] using hz
  have hcard : (Finset.univ : Finset (ZMod M)).card = M := by simp [ZMod.card]
  refine le_trans (le_of_eq hcard.symm) ?_
  rw [support_card_eq]
  refine Finset.card_le_card_of_surjOn (fun e : Edge M N => e.2.1) ?_
  intro i _
  have hi : hWind M N z i ≠ 0 := by rw [hWind_const M N hcyc i]; exact h
  have hex : ∃ y : ZMod N, z (false, (i, y)) ≠ 0 := by
    by_contra hc
    push_neg at hc
    exact hi (Finset.sum_eq_zero (fun y _ => hc y))
  obtain ⟨y, hy⟩ := hex
  exact ⟨(false, (i, y)), by simpa using hy, rfl⟩

/-- A cycle with nonzero vertical winding meets each of the `N` row cuts. -/
theorem N_le_weight_of_vWind {z : Edge M N → F2} (hz : z ∈ cycles M N)
    (h : vWind M N z 0 ≠ 0) : N ≤ hammingNorm z := by
  have hcyc : (d1 M N) *ᵥ z = 0 := by simpa [cycles, LinearMap.mem_ker] using hz
  have hcard : (Finset.univ : Finset (ZMod N)).card = N := by simp [ZMod.card]
  refine le_trans (le_of_eq hcard.symm) ?_
  rw [support_card_eq]
  refine Finset.card_le_card_of_surjOn (fun e : Edge M N => e.2.2) ?_
  intro j _
  have hj : vWind M N z j ≠ 0 := by rw [vWind_const M N hcyc j]; exact h
  have hex : ∃ x : ZMod M, z (true, (x, j)) ≠ 0 := by
    by_contra hc
    push_neg at hc
    exact hj (Finset.sum_eq_zero (fun x _ => hc x))
  obtain ⟨x, hx⟩ := hex
  exact ⟨(true, (x, j)), by simpa using hx, rfl⟩

/-- **Lower bound.**  Every logical operator touches at least `min M N` edges. -/
theorem min_le_weight {z : Edge M N → F2} (hz : z ∈ cycles M N) (hnb : z ∉ boundaries M N) :
    min M N ≤ hammingNorm z := by
  rcases winding_ne_zero_of_not_boundary M N hz hnb with h | h
  · exact le_trans (min_le_left _ _) (M_le_weight_of_hWind M N hz h)
  · exact le_trans (min_le_right _ _) (N_le_weight_of_vWind M N hz h)

lemma loopH_not_boundary : loopH M N ∉ boundaries M N := by
  rintro ⟨g, hg⟩
  have h := hWind_of_boundary M N g 0
  rw [show (d2 M N) *ᵥ g = loopH M N from hg, hWind_loopH] at h
  exact one_ne_zero h

lemma loopV_not_boundary : loopV M N ∉ boundaries M N := by
  rintro ⟨g, hg⟩
  have h := vWind_of_boundary M N g 0
  rw [show (d2 M N) *ᵥ g = loopV M N from hg, vWind_loopV] at h
  exact one_ne_zero h

/-- The horizontal loop has weight exactly `M`. -/
lemma hammingNorm_loopH : hammingNorm (loopH M N) = M := by
  rw [support_card_eq]
  have hinj : Function.Injective (fun x : ZMod M => ((false, (x, 0)) : Edge M N)) :=
    fun a b hab => by simpa using congrArg (fun e : Edge M N => e.2.1) hab
  have himg : (Finset.univ.filter (fun e : Edge M N => loopH M N e ≠ 0))
      = Finset.univ.image (fun x : ZMod M => ((false, (x, 0)) : Edge M N)) := by
    ext e
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    constructor
    · intro h
      have hb : e.1 = false ∧ e.2.2 = 0 := by
        by_contra hc
        exact h (by simp only [loopH, if_neg hc])
      refine ⟨e.2.1, ?_⟩
      obtain ⟨b, x, y⟩ := e
      obtain ⟨h1, h2⟩ := hb
      simp_all
    · rintro ⟨x, rfl⟩
      simp [loopH]
  rw [himg, Finset.card_image_of_injective _ hinj, Finset.card_univ, ZMod.card]

/-- The vertical loop has weight exactly `N`. -/
lemma hammingNorm_loopV : hammingNorm (loopV M N) = N := by
  rw [support_card_eq]
  have hinj : Function.Injective (fun y : ZMod N => ((true, (0, y)) : Edge M N)) :=
    fun a b hab => by simpa using congrArg (fun e : Edge M N => e.2.2) hab
  have himg : (Finset.univ.filter (fun e : Edge M N => loopV M N e ≠ 0))
      = Finset.univ.image (fun y : ZMod N => ((true, (0, y)) : Edge M N)) := by
    ext e
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    constructor
    · intro h
      have hb : e.1 = true ∧ e.2.1 = 0 := by
        by_contra hc
        exact h (by simp only [loopV, if_neg hc])
      refine ⟨e.2.2, ?_⟩
      obtain ⟨b, x, y⟩ := e
      obtain ⟨h1, h2⟩ := hb
      simp_all
    · rintro ⟨y, rfl⟩
      simp [loopV]
  rw [himg, Finset.card_image_of_injective _ hinj, Finset.card_univ, ZMod.card]

/-- **The `M × N` toric code has `Z`-distance exactly `min M N`.** -/
theorem toric_distance : distance M N = min M N := by
  have hHmem : hammingNorm (loopH M N) ∈ logicalWeights M N :=
    ⟨loopH M N, loopH_mem M N, loopH_not_boundary M N, rfl⟩
  have hVmem : hammingNorm (loopV M N) ∈ logicalWeights M N :=
    ⟨loopV M N, loopV_mem M N, loopV_not_boundary M N, rfl⟩
  apply le_antisymm
  · apply le_min
    · have := Nat.sInf_le hHmem
      rwa [hammingNorm_loopH] at this
    · have := Nat.sInf_le hVmem
      rwa [hammingNorm_loopV] at this
  · apply le_csInf ⟨_, hHmem⟩
    rintro w ⟨z, hz, hnb, rfl⟩
    exact min_le_weight M N hz hnb

/-- **The toric code parameters `[[2MN, 2, min M N]]`**, specialising to
`[[2L², 2, L]]` on the square torus. -/
theorem toric_parameters :
    Fintype.card (Edge M N) = 2 * (M * N) ∧ homologyRank M N = 2 ∧
      distance M N = min M N :=
  ⟨card_edge M N, toric_homologyRank M N, toric_distance M N⟩

/-- **Systolic freedom of the rectangular torus.**  For `M < N` the code has the
same block-length shape `n = 2MN` and the same `k = 2`, but distance `M`, so
`k d² < n` strictly: the exact saturation `k d² = n` is a square-lattice
phenomenon and is not implied by genus, `k`, or bounded local geometry. -/
theorem rectangular_BPT_strict (hMN : M < N) :
    homologyRank M N * (distance M N) ^ 2 < Fintype.card (Edge M N) := by
  rw [toric_homologyRank, toric_distance, card_edge, min_eq_left hMN.le]
  have hM : 0 < M := Nat.pos_of_ne_zero (NeZero.ne M)
  nlinarith [hM, hMN]

end ToricCode

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer).
  The previous cycle proved `distance = systole` abstractly and showed that the
  abstract homology rank cannot determine the distance.  The natural bold
  conjecture is that a genuine cellulation *does* determine it, and that the
  `M × N` torus grid realises exactly `[[2MN, 2, min M N]]`: a shortest
  noncontractible cellular loop should have to cross each of the `M` disjoint
  column cuts, or each of the `N` disjoint row cuts, an odd number of times.

Experiment (Experimenter).
  Before formalising, the square case was tested by exhaustive enumeration over
  all `2^(2L²)` binary one-chains, using the very definitions of this directory
  (`d1`, `d2`, `hammingNorm`).  Data (`min` = minimum weight of a cycle that is
  not a boundary):

    L = 1 :  #cycles =    4,  #boundaries =   1,  min = 1   (dual: min = 1)
    L = 2 :  #cycles =   32,  #boundaries =   8,  min = 2   (dual: min = 2)
    L = 3 :  #cycles = 1024,  #boundaries = 256,  min = 3   (dual: min = 3)

  These match the predicted `#cycles = 2^(L²+1)`, `#boundaries = 2^(L²-1)`,
  `min = L`, and the predicted equality of primal and dual spectra.  `L = 4`
  would require enumerating `2³²` chains and was not attempted; the general
  proof supersedes it.  The full logical weight spectra were also enumerated
  (`1,2` for `L=1`; `2,4,6` for `L=2`; `3,5,6,…,15,18` for `L=3`), refuting the
  stronger guess that all logical operators have weight `L`.

Analysis (Analyst).
  Two ingredients were needed and both survived formalisation.  (i) *Discrete
  Stokes*: summing the vertex boundary over a full column shows neighbouring cut
  parities agree, so a cycle has a well-defined pair of winding parities
  (`hWind_const`, `vWind_const`).  (ii) *A dimension count replaces an explicit
  potential function*: proving directly that a cycle with zero windings bounds
  would require constructing a face chain by integrating along paths on the
  torus, with awkward wrap-around cases.  Instead the winding map
  `cycles → 𝔽₂²` is shown to be onto, so its kernel has dimension `MN - 1`,
  which the independent computation `rank d₂ = MN - 1` identifies with the
  boundary space (`boundaries_eq_trivialWinding`).  The rank computation itself
  avoids bases entirely: `rank d₁ = rank d₁ᵀ` and the kernel of a coboundary is
  the line of constants, which is exactly connectivity of the torus graph and of
  its dual graph.  Crucially, *no step used `M = N`*: this is why the whole
  argument generalises to rectangular tori and yields `distance = min M N`.

Critique (Critic).
  Nothing here is vacuous: the lower bound `min M N ≤ hammingNorm z` genuinely
  uses the hypothesis `z ∉ boundaries`, and the value is attained, so
  `distance = min M N` is a two-sided statement.  The edge cases `M = 1` or
  `N = 1` are included and are not degenerate for the argument.  Nowhere is
  `decide` used on a statement depending on `M` or `N`; the only `decide` calls
  are on closed `𝔽₂` identities such as `1 + 1 = 0`.
-/