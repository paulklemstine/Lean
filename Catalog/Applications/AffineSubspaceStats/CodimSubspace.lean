/-
# Affine subspace statistics in `𝔽₂ⁿ`: the codimension-`m` lower bound construction

This file continues the development of
`Catalog/Applications/AffineSubspaceStats/AffineStats.lean`, where the model
(random affine `d`-cubes in `𝔽₂ⁿ`, the statistic `cnt`, the probability `flatProb`)
is set up, and where the codimension-one case was computed exactly
(`AffineStats.hyperplane_flatProb`).

Here we treat arbitrary codimension `m`.  Let `A ⊆ 𝔽₂ⁿ` be the codimension-`m`
subspace `{x : x₀ = ⋯ = x_{m-1} = 0}` and let `F` be a uniformly random affine
`d`-cube.  Writing `π` for the projection onto the first `m` coordinates, the cube
`y ↦ c + ∑ yᵢvᵢ` meets `A` in exactly `2^{d-m}` points as soon as the linear map
`y ↦ ∑ yᵢ π(vᵢ)` is surjective, and surjectivity fails with probability at most
`(2^m - 1)/2^d` by a union bound over the nonzero linear functionals annihilating
the image.  Consequently, with `k = d - m`,

`P[|F ∩ A| = 2^k] ≥ 1 - 2^{-k} + 2^{-d}`,

which is the standard lower-bound construction `λ*(d, 2^k) ≥ 1 - 2^{-k}` for the
affine subspace statistics problem (with an explicit improvement `2^{-d}`).

The same argument applies verbatim to a union of `j` parallel flats of codimension `m`,
i.e. to `A = π⁻¹(S)` with `|S| = j`: the cube then meets `A` in exactly `j·2^{d-m}` points,
which gives the paper's lower-bound construction `λ*(d, j·2^k) ≥ 1 - 2^{-k}`
(`AffineStats.exists_flatProb_mul_pow_two_ge`).
-/
import Mathlib
import Applications.AffineSubspaceStats.AffineStats

namespace AffineStats

open Finset

section Codim

variable {n m d : ℕ}

/-- Projection of `𝔽₂ⁿ` onto its first `m` coordinates. -/
def proj (hmn : m ≤ n) (x : Vec n) : Vec m := fun j => x (Fin.castLE hmn j)

/-- The preimage `π⁻¹(S)` of a set `S ⊆ 𝔽₂^m` under the projection: a union of `|S|`
parallel flats of codimension `m` in `𝔽₂ⁿ`. -/
def unionFlats (hmn : m ≤ n) (S : Finset (Vec m)) : Finset (Vec n) :=
  univ.filter fun x => proj hmn x ∈ S

/-- The codimension-`m` coordinate subspace `{x : x₀ = ⋯ = x_{m-1} = 0}` of `𝔽₂ⁿ`. -/
def codimSub (n : ℕ) (hmn : m ≤ n) : Finset (Vec n) := unionFlats hmn {0}

lemma mem_codimSub (hmn : m ≤ n) (x : Vec n) : x ∈ codimSub n hmn ↔ proj hmn x = 0 := by
  simp [codimSub, unionFlats]

/-- The linear map `𝔽₂^d → 𝔽₂^m`, `y ↦ ∑ yᵢ wᵢ`, induced by a tuple of vectors. -/
noncomputable def Lmap (w : Fin d → Vec m) : (Fin d → ZMod 2) →ₗ[ZMod 2] Vec m :=
  Fintype.linearCombination (ZMod 2) w

lemma Lmap_apply (w : Fin d → Vec m) (y : Fin d → ZMod 2) :
    Lmap w y = ∑ i, y i • w i := rfl

/-- A fiber of a surjective linear map `𝔽₂^d → 𝔽₂^m` has exactly `2^{d-m}` elements. -/
lemma card_fiber_Lmap (w : Fin d → Vec m) (hs : Function.Surjective (Lmap w)) (b : Vec m) :
    (univ.filter fun y : Fin d → ZMod 2 => Lmap w y = b).card = 2 ^ (d - m) := by
  -- all fibers are translates of the kernel, hence have the same size
  have hconst : ∀ b' : Vec m, (univ.filter fun y : Fin d → ZMod 2 => Lmap w y = b').card
      = (univ.filter fun y : Fin d → ZMod 2 => Lmap w y = 0).card := by
    intro b'
    obtain ⟨y₀, hy₀⟩ := hs b'
    refine Finset.card_nbij' (fun y => y - y₀) (fun z => z + y₀) ?_ ?_ ?_ ?_ <;>
      intro a ha <;> simp_all [sub_eq_add_neg]
  set c := (univ.filter fun y : Fin d → ZMod 2 => Lmap w y = 0).card with hc
  have htot : 2 ^ d = 2 ^ m * c := by
    have h := Finset.card_eq_sum_card_fiberwise
      (f := fun y : Fin d → ZMod 2 => Lmap w y) (s := univ) (t := (univ : Finset (Vec m)))
      (fun x _ => mem_univ _)
    simp only [hconst] at h
    rw [Finset.sum_const] at h
    simp [ZMod.card] at h ⊢
    exact h
  have hmd : m ≤ d := by
    by_contra hcon
    push_neg at hcon
    have hc1 : 1 ≤ c := by
      rcases Nat.eq_zero_or_pos c with h0 | h0
      · rw [h0, mul_zero] at htot
        have : (0 : ℕ) < 2 ^ d := Nat.two_pow_pos d
        omega
      · exact h0
    have h2 : (2 : ℕ) ^ d < 2 ^ m := Nat.pow_lt_pow_right (by norm_num) hcon
    have h3 : (2 : ℕ) ^ m ≤ 2 ^ m * c := Nat.le_mul_of_pos_right _ hc1
    omega
  have heq : (2 : ℕ) ^ m * c = 2 ^ m * 2 ^ (d - m) := by
    rw [← htot, ← pow_add]
    congr 1
    omega
  rw [hconst b]
  exact Nat.eq_of_mul_eq_mul_left (Nat.two_pow_pos m) heq

/-- If the directions project onto a spanning tuple, the cube meets the union of parallel
flats `π⁻¹(S)` in exactly `|S|·2^{d-m}` points. -/
lemma cnt_unionFlats (hmn : m ≤ n) (S : Finset (Vec m)) (c : Vec n) (v : Fin d → Vec n)
    (hs : Function.Surjective (Lmap fun i => proj hmn (v i))) :
    cnt (unionFlats hmn S) c v = S.card * 2 ^ (d - m) := by
  classical
  set L := (Lmap fun i => proj hmn (v i)) with hL
  have hinv : ∀ x y : Vec m, x + y + x = y := by
    intro x y; rw [add_comm x y, add_assoc, vadd_self, add_zero]
  have hpe : ∀ y, proj hmn (pt c v y) = proj hmn c + L y := by
    intro y
    funext j
    simp only [proj, pt_apply, hL, Lmap, Fintype.linearCombination, LinearMap.coe_mk,
      AddHom.coe_mk, Finset.sum_apply, Pi.smul_apply, smul_eq_mul, Pi.add_apply]
  set T := S.image (fun s => s + proj hmn c) with hT
  have hmemT : ∀ z : Vec m, (proj hmn c + z ∈ S) ↔ z ∈ T := by
    intro z
    simp only [hT, Finset.mem_image]
    constructor
    · intro h
      exact ⟨proj hmn c + z, h, hinv _ _⟩
    · rintro ⟨s, hsS, rfl⟩
      have hcs : proj hmn c + (s + proj hmn c) = s := by
        rw [add_comm s (proj hmn c), ← add_assoc, vadd_self, zero_add]
      rwa [hcs]
  have hfilter : (univ.filter fun y : Fin d → ZMod 2 => pt c v y ∈ unionFlats hmn S)
      = univ.filter fun y : Fin d → ZMod 2 => L y ∈ T := by
    refine Finset.filter_congr fun y _ => ?_
    simp only [unionFlats, mem_filter, mem_univ, true_and, hpe y]
    exact hmemT (L y)
  have hcardT : T.card = S.card := by
    rw [hT, Finset.card_image_of_injective _ (fun a b hab => by
      have h2 := congrArg (fun z => z + proj hmn c) hab
      simpa [add_assoc, vadd_self] using h2)]
  rw [cnt, hfilter]
  rw [Finset.card_eq_sum_card_fiberwise (f := fun y : Fin d → ZMod 2 => L y)
    (s := univ.filter fun y : Fin d → ZMod 2 => L y ∈ T) (t := T)
    (fun x hx => (mem_filter.1 hx).2)]
  have hall : ∀ b ∈ T, ((univ.filter fun y : Fin d → ZMod 2 => L y ∈ T).filter
      fun y => L y = b).card = 2 ^ (d - m) := by
    intro b hb
    rw [show ((univ.filter fun y : Fin d → ZMod 2 => L y ∈ T).filter fun y => L y = b)
        = univ.filter (fun y : Fin d → ZMod 2 => L y = b) from by
      ext y
      simp only [mem_filter, mem_univ, true_and]
      constructor
      · rintro ⟨-, h⟩; exact h
      · intro h; exact ⟨by rw [h]; exact hb, h⟩]
    exact card_fiber_Lmap _ hs b
  rw [Finset.sum_congr rfl hall, Finset.sum_const, hcardT, smul_eq_mul]

/-- If the directions project onto a spanning tuple, the cube meets the codimension-`m`
subspace in exactly `2^{d-m}` points. -/
lemma cnt_codimSub (hmn : m ≤ n) (c : Vec n) (v : Fin d → Vec n)
    (hs : Function.Surjective (Lmap fun i => proj hmn (v i))) :
    cnt (codimSub n hmn) c v = 2 ^ (d - m) := by
  rw [codimSub, cnt_unionFlats hmn _ c v hs, Finset.card_singleton, one_mul]

/-- If `y ↦ ∑ yᵢ wᵢ` is not surjective, some nonzero functional annihilates all `wᵢ`. -/
lemma exists_orth_of_not_surjective (w : Fin d → Vec m)
    (h : ¬ Function.Surjective (Lmap w)) :
    ∃ a : Vec m, a ≠ 0 ∧ ∀ i, ∑ j, a j * w i j = 0 := by
  have hlt : LinearMap.range (Lmap w) < ⊤ :=
    lt_of_le_of_ne le_top fun hc => h (LinearMap.range_eq_top.1 hc)
  obtain ⟨f, hf0, hfmap⟩ := Submodule.exists_dual_map_eq_bot_of_lt_top hlt inferInstance
  set e : Fin m → Vec m := fun j k => if j = k then (1 : ZMod 2) else 0 with he
  refine ⟨fun j => f (e j), ?_, ?_⟩
  · intro hcon
    apply hf0
    refine LinearMap.ext fun x => ?_
    rw [LinearMap.pi_apply_eq_sum_univ f x]
    have hz : ∀ j : Fin m, f (e j) = 0 := fun j => congrFun hcon j
    simp [he] at hz ⊢
    simp [hz]
  · intro i
    have hmem : w i ∈ LinearMap.range (Lmap w) :=
      ⟨fun k => if i = k then (1 : ZMod 2) else 0, by
        simp [Lmap, Fintype.linearCombination, ite_smul]⟩
    have hzero : f (w i) = 0 := by
      have hm : f (w i) ∈ Submodule.map f (LinearMap.range (Lmap w)) := ⟨w i, hmem, rfl⟩
      rw [hfmap] at hm
      simpa using hm
    rw [LinearMap.pi_apply_eq_sum_univ f (w i)] at hzero
    rw [← hzero]
    exact Finset.sum_congr rfl fun j _ => by simp [he, mul_comm]

/-- For a fixed nonzero functional `a`, exactly a `2^{-d}` fraction of direction tuples
are annihilated by `a ∘ π`. -/
lemma card_orth_dirs (hmn : m ≤ n) (a : Vec m) (ha : a ≠ 0) :
    2 ^ d * (univ.filter fun v : Fin d → Vec n =>
        ∀ i, ∑ j, a j * proj hmn (v i) j = 0).card = 2 ^ (n * d) := by
  set g : Vec n → ZMod 2 := fun x => ∑ j, a j * proj hmn x j with hg
  obtain ⟨j₀, hj₀⟩ : ∃ j, a j = 1 := by
    by_contra hcon
    push_neg at hcon
    refine ha (funext fun j => ?_)
    have h1 : ∀ t : ZMod 2, t ≠ 1 → t = 0 := by decide
    simpa using h1 (a j) (hcon j)
  set u : Vec n := fun k => if Fin.castLE hmn j₀ = k then (1 : ZMod 2) else 0 with hu
  have hgu : g u = 1 := by simp [hg, hu, proj, Fin.castLE_inj, hj₀]
  have hadd : ∀ x : Vec n, g (x + u) = g x + g u := by
    intro x
    simp [hg, proj, mul_add, Finset.sum_add_distrib]
  have hhalf : 2 * (univ.filter fun x : Vec n => g x = 0).card = 2 ^ n := by
    have hinv := card_filter_involutive (α := Vec n) (fun x => g x = 0) (fun x => x + u)
      (fun x => by simp [add_assoc, vadd_self]) (by
        intro x
        show g (x + u) = 0 ↔ ¬ (g x = 0)
        rw [hadd x, hgu]
        generalize g x = t
        revert t
        decide)
    rw [hinv, card_Vec]
  have hprod : (univ.filter fun v : Fin d → Vec n => ∀ i, g (v i) = 0).card
      = (univ.filter fun x : Vec n => g x = 0).card ^ d := by
    rw [show (univ.filter fun v : Fin d → Vec n => ∀ i, g (v i) = 0)
        = Fintype.piFinset (fun _ : Fin d => univ.filter fun x : Vec n => g x = 0) from by
      ext v; simp [Fintype.mem_piFinset]]
    rw [Fintype.card_piFinset]
    simp
  rw [show (univ.filter fun v : Fin d → Vec n => ∀ i, ∑ j, a j * proj hmn (v i) j = 0)
      = univ.filter fun v : Fin d → Vec n => ∀ i, g (v i) = 0 from rfl, hprod,
    ← mul_pow, hhalf, ← pow_mul, Nat.mul_comm]

/-- Union bound: the projected directions fail to span `𝔽₂^m` for at most a
`(2^m - 1)/2^d` fraction of the direction tuples. -/
lemma card_bad_dirs_le (hmn : m ≤ n) :
    2 ^ d * (univ.filter fun v : Fin d → Vec n =>
        ¬ Function.Surjective (Lmap fun i => proj hmn (v i))).card
      ≤ (2 ^ m - 1) * 2 ^ (n * d) := by
  have hsub : (univ.filter fun v : Fin d → Vec n =>
      ¬ Function.Surjective (Lmap fun i => proj hmn (v i)))
      ⊆ (univ.filter fun a : Vec m => a ≠ 0).biUnion
          (fun a => univ.filter fun v : Fin d → Vec n =>
            ∀ i, ∑ j, a j * proj hmn (v i) j = 0) := by
    intro v hv
    simp only [mem_filter, mem_univ, true_and] at hv
    obtain ⟨a, ha0, ha⟩ := exists_orth_of_not_surjective _ hv
    exact mem_biUnion.2 ⟨a, by simp [ha0], by simpa using ha⟩
  have hcard := Finset.card_le_card hsub
  have hbu := Finset.card_biUnion_le (s := univ.filter fun a : Vec m => a ≠ 0)
    (t := fun a => univ.filter fun v : Fin d → Vec n =>
      ∀ i, ∑ j, a j * proj hmn (v i) j = 0)
  have hnz : (univ.filter fun a : Vec m => a ≠ 0).card = 2 ^ m - 1 := by
    have hers : (univ.filter fun a : Vec m => a ≠ 0) = univ.erase (0 : Vec m) := by
      ext a; simp [Finset.mem_erase]
    rw [hers, Finset.card_erase_of_mem (mem_univ _), Finset.card_univ, card_Vec]
  calc 2 ^ d * (univ.filter fun v : Fin d → Vec n =>
      ¬ Function.Surjective (Lmap fun i => proj hmn (v i))).card
      ≤ 2 ^ d * ∑ a ∈ univ.filter fun a : Vec m => a ≠ 0,
          (univ.filter fun v : Fin d → Vec n =>
            ∀ i, ∑ j, a j * proj hmn (v i) j = 0).card :=
        Nat.mul_le_mul_left _ (le_trans hcard hbu)
    _ = ∑ a ∈ univ.filter fun a : Vec m => a ≠ 0, 2 ^ d *
          (univ.filter fun v : Fin d → Vec n =>
            ∀ i, ∑ j, a j * proj hmn (v i) j = 0).card := by rw [Finset.mul_sum]
    _ = ∑ _a ∈ univ.filter fun a : Vec m => a ≠ 0, 2 ^ (n * d) :=
        Finset.sum_congr rfl fun a ha =>
          card_orth_dirs hmn a (by simpa using (mem_filter.1 ha).2)
    _ = (2 ^ m - 1) * 2 ^ (n * d) := by rw [Finset.sum_const, hnz, smul_eq_mul]

/-- **The general lower bound.** If, whenever the projected directions span `𝔽₂^m`, the
cube meets `A` in exactly `s` points, then `P[|F ∩ A| = s] ≥ 1 - (2^m - 1)/2^d`. -/
theorem flatProb_ge_of_cnt_of_surj (hmn : m ≤ n) (A : Finset (Vec n)) (s : ℕ)
    (hcnt : ∀ (c : Vec n) (v : Fin d → Vec n),
      Function.Surjective (Lmap fun i => proj hmn (v i)) → cnt A c v = s) :
    1 - ((2 : ℚ) ^ m - 1) / 2 ^ d ≤ flatProb n d A s := by
  classical
  set P : (Fin d → Vec n) → Prop :=
    fun v => Function.Surjective (Lmap fun i => proj hmn (v i)) with hP
  set G := univ.filter P with hG
  set B := univ.filter fun v => ¬ P v with hB
  have hGB : G.card + B.card = 2 ^ (n * d) := by
    rw [hG, hB, Finset.card_filter_add_card_filter_not, Finset.card_univ]
    simp [ZMod.card, ← pow_mul]
  have hsubset : (univ : Finset (Vec n)) ×ˢ G ⊆ hitSet n d A s := by
    intro p hp
    simp only [Finset.mem_product, mem_univ, true_and, hG, mem_filter] at hp
    exact mem_filter.2 ⟨mem_univ _, hcnt p.1 p.2 hp⟩
  have hcard : 2 ^ n * G.card ≤ (hitSet n d A s).card := by
    have h := Finset.card_le_card hsubset
    rwa [Finset.card_product, Finset.card_univ, card_Vec] at h
  have hbad := card_bad_dirs_le (n := n) (m := m) (d := d) hmn
  rw [← hB] at hbad
  have hbadQ : (2 : ℚ) ^ d * B.card ≤ ((2 : ℚ) ^ m - 1) * 2 ^ (n * d) := by
    have h : ((2 ^ d * B.card : ℕ) : ℚ) ≤ (((2 ^ m - 1) * 2 ^ (n * d) : ℕ) : ℚ) :=
      Nat.cast_le.2 hbad
    push_cast [Nat.cast_sub (Nat.one_le_two_pow (n := m))] at h
    linarith
  have hGq : (G.card : ℚ) + B.card = 2 ^ (n * d) := by exact_mod_cast hGB
  have hnum : (2 : ℚ) ^ n * G.card ≤ ((hitSet n d A s).card : ℚ) := by
    exact_mod_cast hcard
  rw [flatProb, le_div_iff₀ (by positivity)]
  have hden : (2 : ℚ) ^ (n * (d + 1)) = 2 ^ n * 2 ^ (n * d) := by
    rw [← pow_add]; ring_nf
  rw [hden]
  set t : ℚ := ((2 : ℚ) ^ m - 1) / 2 ^ d with ht
  have htd : t * 2 ^ d = (2 : ℚ) ^ m - 1 := by
    rw [ht, div_mul_cancel₀ _ (by positivity : ((2 : ℚ) ^ d) ≠ 0)]
  have hBt : (B.card : ℚ) ≤ t * 2 ^ (n * d) := by
    have hd : (0 : ℚ) < 2 ^ d := by positivity
    rw [← htd] at hbadQ
    nlinarith [hbadQ]
  have h2n : (0 : ℚ) < 2 ^ n := by positivity
  nlinarith [hnum, hGq, hBt, h2n]

/-- **The union-of-parallel-flats construction.** For `A = π⁻¹(S)`, a union of `|S|`
parallel flats of codimension `m`, a uniformly random affine `d`-cube meets `A` in exactly
`|S|·2^{d-m}` points with probability at least `1 - (2^m - 1)/2^d`. -/
theorem unionFlats_flatProb_ge (hmn : m ≤ n) (S : Finset (Vec m)) (d : ℕ) :
    1 - ((2 : ℚ) ^ m - 1) / 2 ^ d
      ≤ flatProb n d (unionFlats hmn S) (S.card * 2 ^ (d - m)) :=
  flatProb_ge_of_cnt_of_surj hmn _ _ fun c v hv => cnt_unionFlats hmn S c v hv

/-- **The codimension-`m` construction.** For the codimension-`m` coordinate subspace
`A ⊆ 𝔽₂ⁿ`, a uniformly random affine `d`-cube meets `A` in exactly `2^{d-m}` points with
probability at least `1 - (2^m - 1)/2^d`. -/
theorem codimSub_flatProb_ge (hmn : m ≤ n) (d : ℕ) :
    1 - ((2 : ℚ) ^ m - 1) / 2 ^ d ≤ flatProb n d (codimSub n hmn) (2 ^ (d - m)) :=
  flatProb_ge_of_cnt_of_surj hmn _ _ fun c v hv => cnt_codimSub hmn c v hv

/-- The image of `Lmap w` meets every fiber in the same number of points: the number of
points of `𝔽₂^d` is the size of the image times the size of the kernel. -/
theorem card_image_mul_fiber (w : Fin d → Vec m) :
    (univ.image (Lmap w)).card * (univ.filter fun y : Fin d → ZMod 2 => Lmap w y = 0).card
      = 2 ^ d := by
  classical
  have hconst : ∀ b' ∈ univ.image (Lmap w),
      (univ.filter fun y : Fin d → ZMod 2 => Lmap w y = b').card
      = (univ.filter fun y : Fin d → ZMod 2 => Lmap w y = 0).card := by
    intro b' hb'
    obtain ⟨y₀, -, hy₀⟩ := Finset.mem_image.1 hb'
    refine Finset.card_nbij' (fun y => y - y₀) (fun z => z + y₀) ?_ ?_ ?_ ?_ <;>
      intro a ha <;> simp_all [sub_eq_add_neg]
  have h := Finset.card_eq_sum_card_fiberwise
      (f := fun y : Fin d → ZMod 2 => Lmap w y) (s := univ)
      (t := univ.image (Lmap w)) (fun x _ => Finset.mem_image_of_mem _ (mem_univ x))
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, smul_eq_mul] at h
  simp only [Finset.card_univ] at h
  rw [← h]
  simp [ZMod.card]

/-- The intersection of the cube with the codimension-`m` subspace is a fiber of the
induced linear map. -/
theorem cnt_codimSub_eq_card_fiber (hmn : m ≤ n) (c : Vec n) (v : Fin d → Vec n) :
    cnt (codimSub n hmn) c v
      = (univ.filter fun y : Fin d → ZMod 2 =>
          (Lmap fun i => proj hmn (v i)) y = proj hmn c).card := by
  have hz : ∀ a b : ZMod 2, (a + b = 0 ↔ b = a) := by decide
  rw [cnt]
  refine congrArg Finset.card (Finset.filter_congr fun y _ => ?_)
  simp only [codimSub, unionFlats, mem_filter, mem_univ, true_and, Lmap,
    Fintype.linearCombination, LinearMap.coe_mk, AddHom.coe_mk, proj, funext_iff,
    Finset.mem_singleton, Pi.zero_apply, Finset.sum_apply, Pi.smul_apply, smul_eq_mul, pt_apply]
  exact forall_congr' fun j => hz _ _

/-- Converse of `cnt_codimSub` when `m ≤ d`: the intersection has exactly `2^{d-m}` points
*only if* the projected directions span. -/
theorem surj_of_cnt (hmn : m ≤ n) (hmd : m ≤ d) (c : Vec n) (v : Fin d → Vec n)
    (h : cnt (codimSub n hmn) c v = 2 ^ (d - m)) :
    Function.Surjective (Lmap fun i => proj hmn (v i)) := by
  classical
  set L := (Lmap fun i => proj hmn (v i)) with hL
  rw [cnt_codimSub_eq_card_fiber hmn c v, ← hL] at h
  have hne : (univ.filter fun y : Fin d → ZMod 2 => L y = proj hmn c).Nonempty := by
    rw [← Finset.card_pos, h]; positivity
  obtain ⟨y₀, hy₀⟩ := hne
  have hconst : (univ.filter fun y : Fin d → ZMod 2 => L y = proj hmn c).card
      = (univ.filter fun y : Fin d → ZMod 2 => L y = 0).card := by
    refine Finset.card_nbij' (fun y => y - y₀) (fun z => z + y₀) ?_ ?_ ?_ ?_ <;>
      intro a ha <;> simp_all [sub_eq_add_neg]
  have hfib : (univ.filter fun y : Fin d → ZMod 2 => L y = 0).card = 2 ^ (d - m) := by
    rw [← hconst, h]
  have hmul := card_image_mul_fiber (w := fun i => proj hmn (v i))
  rw [← hL, hfib] at hmul
  have hIcard : (univ.image L).card = 2 ^ m := by
    have h2 : (2 : ℕ) ^ m * 2 ^ (d - m) = 2 ^ d := by
      rw [← pow_add]; congr 1; omega
    exact Nat.eq_of_mul_eq_mul_right (Nat.two_pow_pos (d - m)) (by rw [hmul, ← h2])
  have hfull : univ.image L = univ := by
    apply Finset.eq_univ_of_card
    rw [hIcard, card_Vec]
  intro b
  have hb : b ∈ univ.image L := by rw [hfull]; exact mem_univ b
  obtain ⟨y, -, hy⟩ := Finset.mem_image.1 hb
  exact ⟨y, hy⟩

/-- **The codimension-`m` probability, exactly.** For `m ≤ d` the cube meets the
codimension-`m` subspace in exactly `2^{d-m}` points precisely when the projected
directions span `𝔽₂^m`, so the probability is exactly the fraction of spanning direction
tuples. -/
theorem flatProb_codimSub_eq (hmn : m ≤ n) (hmd : m ≤ d) :
    flatProb n d (codimSub n hmn) (2 ^ (d - m))
      = ((univ.filter fun v : Fin d → Vec n =>
          Function.Surjective (Lmap fun i => proj hmn (v i))).card : ℚ) / 2 ^ (n * d) := by
  classical
  have hset : hitSet n d (codimSub n hmn) (2 ^ (d - m))
      = (univ : Finset (Vec n)) ×ˢ (univ.filter fun v : Fin d → Vec n =>
          Function.Surjective (Lmap fun i => proj hmn (v i))) := by
    ext p
    simp only [hitSet, mem_filter, mem_univ, true_and, Finset.mem_product]
    exact ⟨fun h => surj_of_cnt hmn hmd p.1 p.2 h, fun h => cnt_codimSub hmn p.1 p.2 h⟩
  rw [flatProb, hset, Finset.card_product, Finset.card_univ, card_Vec]
  have hden : (2 : ℚ) ^ (n * (d + 1)) = 2 ^ n * 2 ^ (n * d) := by
    rw [← pow_add]; ring_nf
  rw [hden]
  push_cast
  rw [mul_div_mul_left _ _ (by positivity : (2 : ℚ) ^ n ≠ 0)]

/-- `1 - 2^{-k} + 2^{-d} = 1 - (2^{d-k} - 1)/2^d` for `k ≤ d`. -/
lemma bound_rewrite {k : ℕ} (hkd : k ≤ d) :
    1 - 1 / (2 : ℚ) ^ k + 1 / (2 : ℚ) ^ d = 1 - ((2 : ℚ) ^ (d - k) - 1) / 2 ^ d := by
  have hpow : (2 : ℚ) ^ (d - k) * 2 ^ k = 2 ^ d := by
    rw [← pow_add]
    congr 1
    omega
  have h2k : ((2 : ℚ) ^ k) ≠ 0 := by positivity
  have h2d : ((2 : ℚ) ^ d) ≠ 0 := by positivity
  field_simp
  nlinarith [hpow]

/-- **`λ*(d, 2^k) ≥ 1 - 2^{-k} + 2^{-d}`.** Writing the codimension as `m = d - k`, the
construction above realises the intersection size `2^k` with probability at least
`1 - 2^{-k} + 2^{-d}`; letting `n → ∞` this is the classical lower bound
`λ*(d, 2^k) ≥ 1 - 2^{-k}`. -/
theorem flatProb_pow_two_ge {k : ℕ} (hkd : k ≤ d) (hmn : d - k ≤ n) :
    1 - 1 / (2 : ℚ) ^ k + 1 / (2 : ℚ) ^ d
      ≤ flatProb n d (codimSub n hmn) (2 ^ k) := by
  have hbase := codimSub_flatProb_ge hmn d
  rw [show d - (d - k) = k from by omega] at hbase
  rw [bound_rewrite hkd]
  exact hbase

/-- **`λ*(d, j·2^k) ≥ 1 - 2^{-k} + 2^{-d}` for every `1 ≤ j ≤ 2^{d-k}`.** This is the
lower-bound construction of the paper: `A` is a union of `j` parallel flats of
codimension `d - k`, and a random `d`-cube meets it in exactly `j·2^k` points unless the
projected directions fail to span, an event of probability at most `2^{-k} - 2^{-d}`. -/
theorem exists_flatProb_mul_pow_two_ge {k j : ℕ} (hkd : k ≤ d) (hmn : d - k ≤ n)
    (hj : j ≤ 2 ^ (d - k)) :
    ∃ A : Finset (Vec n),
      1 - 1 / (2 : ℚ) ^ k + 1 / (2 : ℚ) ^ d ≤ flatProb n d A (j * 2 ^ k) := by
  obtain ⟨S, -, hScard⟩ := Finset.exists_subset_card_eq
    (show j ≤ (univ : Finset (Vec (d - k))).card by
      rw [Finset.card_univ, card_Vec]; exact hj)
  refine ⟨unionFlats hmn S, ?_⟩
  have hbase := unionFlats_flatProb_ge hmn S d
  rw [hScard, show d - (d - k) = k from by omega] at hbase
  rw [bound_rewrite hkd]
  exact hbase

end Codim

end AffineStats