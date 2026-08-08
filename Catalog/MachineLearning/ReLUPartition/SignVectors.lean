import Mathlib
import MachineLearning.ReLUPartition.Schlafli

/-!
# Activation patterns of one ReLU layer and the Schläfli upper bound

A single ReLU layer with `n` neurons on input space `ℝ^d` is determined by `n`
affine functionals `f_1, …, f_n`.  The layer is affine exactly on each *cell*

  `{x | sign (f_i x) = s_i for all i}`,

and the cells are indexed by the *realized activation patterns*
`pattern F x = {i | f_i x > 0} ⊆ Fin n`.  Since each cell is an intersection of
open half spaces it is convex, hence connected, so the number of realized
patterns is precisely the number of pieces of the induced piecewise-linear
partition of the input space.

The main theorem of this file is the **exact Schläfli bound**

  `regionCount F ≤ schlafli n d = ∑_{k ≤ d} C(n,k)`,

which is proved by combining

* a *Radon-type linear algebra obstruction*: no `d+1` affine functionals on
  `ℝ^d` can realize all `2^{d+1}` sign patterns, hence the VC dimension of the
  family of activation patterns is at most `d`; with
* the *Sauer–Shelah–Pajor* lemma from Mathlib.

Sharpness is proved here in two regimes (`n ≤ d`, and `d = 1` for all `n`); the
general sharpness statement, for every `n` and `d`, is proved in
`MachineLearning.ReLUPartition.MomentSharp`.
-/

open Finset

namespace ReLUPartition

variable {n d : ℕ}

/-- A finite family of `n` affine functionals on `ℝ^d`: the pre-activations of a
single ReLU layer of width `n`. -/
structure AffineFamily (n d : ℕ) where
  /-- Weight matrix of the layer. -/
  weight : Fin n → Fin d → ℝ
  /-- Bias vector of the layer. -/
  bias : Fin n → ℝ

namespace AffineFamily

/-- The `i`-th pre-activation, an affine function of the input. -/
def eval (F : AffineFamily n d) (i : Fin n) (x : Fin d → ℝ) : ℝ :=
  (∑ j, F.weight i j * x j) + F.bias i

open Classical in
/-- The activation pattern of the layer at an input `x`: the set of neurons
that are firing. -/
noncomputable def pattern (F : AffineFamily n d) (x : Fin d → ℝ) : Finset (Fin n) :=
  univ.filter (fun i => 0 < F.eval i x)

@[simp] lemma mem_pattern {F : AffineFamily n d} {x : Fin d → ℝ} {i : Fin n} :
    i ∈ F.pattern x ↔ 0 < F.eval i x := by
  classical simp [pattern]

open Classical in
/-- The set of activation patterns that actually occur: the cells of the
induced partition of the input space. -/
noncomputable def regions (F : AffineFamily n d) : Finset (Finset (Fin n)) :=
  univ.filter (fun s => ∃ x, F.pattern x = s)

@[simp] lemma mem_regions {F : AffineFamily n d} {s : Finset (Fin n)} :
    s ∈ F.regions ↔ ∃ x, F.pattern x = s := by
  classical simp [regions]

/-- The number of linear regions of the layer. -/
noncomputable def regionCount (F : AffineFamily n d) : ℕ := F.regions.card

/-- An open half space cut out by one pre-activation is convex. -/
theorem convex_eval_pos (F : AffineFamily n d) (i : Fin n) :
    Convex ℝ {x : Fin d → ℝ | 0 < F.eval i x} := by
  have hlin : IsLinearMap ℝ (fun x : Fin d → ℝ => ∑ j, F.weight i j * x j) := by
    constructor
    · intro p q; simp [mul_add, Finset.sum_add_distrib]
    · intro c p; simp only [Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
      exact Finset.sum_congr rfl fun j _ => by ring
  have h := convex_halfSpace_gt hlin (-F.bias i)
  have hset : {x : Fin d → ℝ | 0 < F.eval i x}
      = {x : Fin d → ℝ | -F.bias i < ∑ j, F.weight i j * x j} := by
    ext x; simp only [Set.mem_setOf_eq, eval]; constructor <;> intro h' <;> linarith
  rw [hset]; exact h

/-- The closed half space where one neuron is silent is convex. -/
theorem convex_eval_nonpos (F : AffineFamily n d) (i : Fin n) :
    Convex ℝ {x : Fin d → ℝ | F.eval i x ≤ 0} := by
  have hlin : IsLinearMap ℝ (fun x : Fin d → ℝ => ∑ j, F.weight i j * x j) := by
    constructor
    · intro p q; simp [mul_add, Finset.sum_add_distrib]
    · intro c p; simp only [Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
      exact Finset.sum_congr rfl fun j _ => by ring
  have h := convex_halfSpace_le hlin (-F.bias i)
  have hset : {x : Fin d → ℝ | F.eval i x ≤ 0}
      = {x : Fin d → ℝ | (∑ j, F.weight i j * x j) ≤ -F.bias i} := by
    ext x; simp only [Set.mem_setOf_eq, eval]; constructor <;> intro h' <;> linarith
  rw [hset]; exact h

/-- **Each cell is convex**, hence connected: the activation pattern really does
index the connected pieces of the induced partition of the input space. -/
theorem convex_cell (F : AffineFamily n d) (s : Finset (Fin n)) :
    Convex ℝ {x : Fin d → ℝ | F.pattern x = s} := by
  classical
  have hset : {x : Fin d → ℝ | F.pattern x = s}
      = (⋂ i ∈ s, {x : Fin d → ℝ | 0 < F.eval i x}) ∩
        (⋂ i ∈ sᶜ, {x : Fin d → ℝ | F.eval i x ≤ 0}) := by
    ext x
    simp only [Set.mem_inter_iff, Set.mem_iInter, Set.mem_setOf_eq, Finset.mem_compl]
    constructor
    · intro hx
      refine ⟨fun i hi => mem_pattern.mp (by rw [hx]; exact hi), fun i hi => ?_⟩
      by_contra hcon
      exact hi (by rw [← hx]; exact mem_pattern.mpr (lt_of_not_ge hcon))
    · rintro ⟨h1, h2⟩
      ext i
      by_cases hi : i ∈ s
      · simp [mem_pattern, h1 i hi, hi]
      · simp only [mem_pattern, hi, iff_false, not_lt]
        exact h2 i hi
  rw [hset]
  exact Convex.inter (convex_iInter fun i => convex_iInter fun _ => convex_eval_pos F i)
    (convex_iInter fun i => convex_iInter fun _ => convex_eval_nonpos F i)

/-! ### The Radon-type obstruction: VC dimension at most `d` -/

/-- **No `d+1` affine functionals on `ℝ^d` shatter their index set.**  If a set
`t` of neurons has all `2^{#t}` sign patterns realized, then `#t ≤ d`.

The proof is a Radon/Gale duality argument: more than `d` weight vectors in
`ℝ^d` are linearly dependent, say `∑ g_i w_i = 0`, and then
`x ↦ ∑ g_i f_i(x)` is the *constant* `c = ∑ g_i b_i`.  Realizing the sign
pattern `sign f_i = sign g_i` forces `c > 0` while realizing
`sign f_i = -sign g_i` forces `c < 0`. -/
theorem card_le_of_shatters (F : AffineFamily n d) {t : Finset (Fin n)}
    (h : F.regions.Shatters t) : t.card ≤ d := by
  classical
  by_contra hlt
  push_neg at hlt
  have hcard : Module.finrank ℝ (Fin d → ℝ) < Fintype.card {i // i ∈ t} := by
    simpa [Module.finrank_fintype_fun_eq_card] using hlt
  have hdep : ¬ LinearIndependent ℝ (fun i : {i // i ∈ t} => F.weight i) := by
    intro hli
    have := hli.fintype_card_le_finrank
    omega
  rw [Fintype.not_linearIndependent_iff] at hdep
  obtain ⟨g, hg0, i0, hi0⟩ := hdep
  set G : Fin n → ℝ := fun i => if h : i ∈ t then g ⟨i, h⟩ else 0 with hG
  have hzero : ∀ j : Fin d, ∑ i ∈ t, G i * F.weight i j = 0 := by
    intro j
    have hfun := congrFun hg0 j
    simp only [Finset.sum_apply, Pi.smul_apply, smul_eq_mul, Pi.zero_apply] at hfun
    rw [← hfun, ← Finset.sum_coe_sort t (fun i => G i * F.weight i j)]
    exact Finset.sum_congr rfl (fun i _ => by simp [hG, i.2])
  set c : ℝ := ∑ i ∈ t, G i * F.bias i with hc
  have key : ∀ x : Fin d → ℝ, ∑ i ∈ t, G i * F.eval i x = c := by
    intro x
    have hterms : ∀ i ∈ t, G i * F.eval i x
        = (∑ j, G i * F.weight i j * x j) + G i * F.bias i := by
      intro i _
      simp [eval, Finset.mul_sum, mul_add, mul_assoc]
    rw [Finset.sum_congr rfl hterms, Finset.sum_add_distrib, ← hc]
    have hvan : ∑ i ∈ t, ∑ j, G i * F.weight i j * x j = 0 := by
      rw [Finset.sum_comm]
      refine Finset.sum_eq_zero fun j _ => ?_
      have hz := hzero j
      calc ∑ i ∈ t, G i * F.weight i j * x j = (∑ i ∈ t, G i * F.weight i j) * x j := by
            rw [Finset.sum_mul]
        _ = 0 := by rw [hz]; ring
    rw [hvan, zero_add]
  -- Both sign choices of the dependency are realized, forcing `c` to be both
  -- positive and negative.
  have main : ∀ σ : ℝ, (0 ≤ σ * c ∧ (∀ i ∈ t, 0 < σ * G i → 0 < σ * c)) := by
    intro σ
    obtain ⟨u, hu, hx⟩ := h (Finset.filter_subset (fun i => 0 < σ * G i) t)
    obtain ⟨x, rfl⟩ := mem_regions.mp hu
    have hterm : ∀ i ∈ t, 0 ≤ σ * (G i * F.eval i x) := by
      intro i hi
      rcases lt_or_ge 0 (σ * G i) with hg | hg
      · have hm : i ∈ t ∩ F.pattern x := by rw [hx]; simp [hi, hg]
        have hE := mem_pattern.mp (mem_inter.mp hm).2
        have hnn : 0 ≤ (σ * G i) * F.eval i x := by positivity
        linarith [hnn, mul_assoc σ (G i) (F.eval i x)]
      · have hnot : i ∉ t ∩ F.pattern x := by rw [hx]; simp [not_lt.mpr hg]
        have hnp : i ∉ F.pattern x := fun hmem => hnot (mem_inter.mpr ⟨hi, hmem⟩)
        have hle : F.eval i x ≤ 0 := by
          by_contra hcon
          exact hnp (mem_pattern.mpr (lt_of_not_ge hcon))
        have hnn : 0 ≤ (σ * G i) * F.eval i x := mul_nonneg_of_nonpos_of_nonpos hg hle
        linarith [hnn, mul_assoc σ (G i) (F.eval i x)]
    have hsum : σ * c = ∑ i ∈ t, σ * (G i * F.eval i x) := by
      rw [← Finset.mul_sum, key x]
    refine ⟨by rw [hsum]; exact Finset.sum_nonneg hterm, fun i hi hgi => ?_⟩
    rw [hsum]
    refine Finset.sum_pos' hterm ⟨i, hi, ?_⟩
    have hm : i ∈ t ∩ F.pattern x := by rw [hx]; simp [hi, hgi]
    have hE := mem_pattern.mp (mem_inter.mp hm).2
    have hpos : 0 < (σ * G i) * F.eval i x := by positivity
    linarith [hpos, mul_assoc σ (G i) (F.eval i x)]
  obtain ⟨hp, hps⟩ := main 1
  obtain ⟨hm, hms⟩ := main (-1)
  have hGi0 : G i0 = g i0 := by simp [hG, i0.2]
  have hne : G i0 ≠ 0 := by rw [hGi0]; exact hi0
  rcases lt_or_gt_of_ne hne with hneg | hpos
  · have := hms i0 i0.2 (by linarith)
    linarith
  · have := hps i0 i0.2 (by linarith)
    linarith

/-- The VC dimension of the family of activation patterns of a ReLU layer on
`ℝ^d` is at most `d`, whatever the width. -/
theorem vcDim_regions_le (F : AffineFamily n d) : F.regions.vcDim ≤ d :=
  Finset.sup_le fun _ hs => F.card_le_of_shatters (mem_shatterer.mp hs)

/-- **Main upper bound (exact Schläfli bound).**  A ReLU layer of width `n` on
input space `ℝ^d` partitions the input space into at most
`∑_{k ≤ d} C(n,k)` regions. -/
theorem regionCount_le_schlafli (F : AffineFamily n d) : F.regionCount ≤ schlafli n d := by
  classical
  calc F.regionCount ≤ F.regions.shatterer.card := Finset.card_le_card_shatterer _
    _ ≤ ∑ k ∈ Iic F.regions.vcDim, (Fintype.card (Fin n)).choose k :=
        Finset.card_shatterer_le_sum_vcDim
    _ = schlafli n F.regions.vcDim := by simp [schlafli]
    _ ≤ schlafli n d := schlafli_mono_dim n (vcDim_regions_le F)

/-- Consequently the catalog capacity heuristic `(n+1)^d` is also an upper bound
for the true number of regions, and is strictly lossy in dimension `≥ 2`. -/
theorem regionCount_le_regionCapacity (F : AffineFamily n d) :
    F.regionCount ≤ ReLUWidthDepth.regionCapacity n d :=
  le_trans (regionCount_le_schlafli F) (schlafli_le_regionCapacity n d)

theorem regionCount_lt_regionCapacity (F : AffineFamily n d) (hn : 1 ≤ n) (hd : 2 ≤ d) :
    F.regionCount < ReLUWidthDepth.regionCapacity n d :=
  lt_of_le_of_lt (regionCount_le_schlafli F) (schlafli_lt_regionCapacity hn hd)

/-! ### Sharpness in the low-width regime -/

/-- The coordinate family: neuron `i` reads off coordinate `i`. -/
def coordFamily (n d : ℕ) : AffineFamily n d :=
  { weight := fun i j => if (i : ℕ) = (j : ℕ) then 1 else 0
    bias := fun _ => 0 }

theorem eval_coordFamily (h : n ≤ d) (i : Fin n) (x : Fin d → ℝ) :
    (coordFamily n d).eval i x = x ⟨i, lt_of_lt_of_le i.2 h⟩ := by
  classical
  simp only [coordFamily, eval, add_zero]
  rw [Finset.sum_eq_single (⟨i, lt_of_lt_of_le i.2 h⟩ : Fin d)]
  · simp
  · intro j _ hj
    have : (i : ℕ) ≠ (j : ℕ) := by
      intro hcon
      exact hj (Fin.ext hcon.symm)
    simp [this]
  · intro hcon
    exact absurd (Finset.mem_univ _) hcon

/-- When the width does not exceed the input dimension, *every* activation
pattern is realized, so the layer attains `2^n = schlafli n d` regions. -/
theorem regionCount_coordFamily (h : n ≤ d) :
    (coordFamily n d).regionCount = schlafli n d := by
  classical
  have huniv : (coordFamily n d).regions = (univ : Finset (Finset (Fin n))) := by
    refine Finset.eq_univ_of_forall fun s => ?_
    refine mem_regions.mpr ⟨fun j => if hj : (j : ℕ) < n then
      (if (⟨j, hj⟩ : Fin n) ∈ s then 1 else -1) else 0, ?_⟩
    ext i
    rw [mem_pattern, eval_coordFamily h]
    by_cases hi : i ∈ s
    · simp [hi]
    · simp [hi]
  rw [regionCount, huniv, Finset.card_univ, Fintype.card_finset, Fintype.card_fin,
    schlafli_eq_two_pow n d h]

/-! ### Sharpness in dimension one -/

/-- Threshold family on the line: neuron `i` fires iff the input exceeds `i`. -/
def thresholdFamily (n : ℕ) : AffineFamily n 1 :=
  { weight := fun _ _ => 1
    bias := fun i => -(i : ℝ) }

theorem eval_thresholdFamily (n : ℕ) (i : Fin n) (x : Fin 1 → ℝ) :
    (thresholdFamily n).eval i x = x 0 - (i : ℝ) := by
  simp [thresholdFamily, eval]
  ring

/-- The initial segment of the first `k` neurons. -/
def initSeg (n k : ℕ) : Finset (Fin n) := univ.filter (fun i => (i : ℕ) < k)

@[simp] lemma mem_initSeg {n k : ℕ} {i : Fin n} : i ∈ initSeg n k ↔ (i : ℕ) < k := by
  simp [initSeg]

theorem pattern_thresholdFamily (n : ℕ) (x : Fin 1 → ℝ) :
    (thresholdFamily n).pattern x = initSeg n ⌈x 0⌉₊ := by
  classical
  ext i
  rw [mem_pattern, eval_thresholdFamily, mem_initSeg, Nat.lt_ceil]
  constructor <;> intro h <;> linarith

theorem initSeg_injOn (n : ℕ) : Set.InjOn (initSeg n) (Finset.range (n + 1)) := by
  intro a ha b hb hab
  simp only [Finset.coe_range, Set.mem_Iio] at ha hb
  by_contra hne
  rcases Nat.lt_or_ge a b with h | h
  · have hlt : a < n := by omega
    have hmem : (⟨a, hlt⟩ : Fin n) ∈ initSeg n b := by simp [h]
    rw [← hab] at hmem
    simp at hmem
  · have hba : b < a := by omega
    have hlt : b < n := by omega
    have hmem : (⟨b, hlt⟩ : Fin n) ∈ initSeg n a := by simp [hba]
    rw [hab] at hmem
    simp at hmem

/-- **Exact region count on the line.**  `n` distinct thresholds cut `ℝ` into
exactly `n + 1 = schlafli n 1` pieces. -/
theorem regionCount_thresholdFamily (n : ℕ) :
    (thresholdFamily n).regionCount = schlafli n 1 := by
  classical
  have himg : (thresholdFamily n).regions = (Finset.range (n + 1)).image (initSeg n) := by
    ext s
    simp only [mem_regions, Finset.mem_image, Finset.mem_range]
    constructor
    · rintro ⟨x, rfl⟩
      refine ⟨min ⌈x 0⌉₊ n, by omega, ?_⟩
      rw [pattern_thresholdFamily]
      ext i
      simp only [mem_initSeg, lt_min_iff]
      have hi := i.2
      omega
    · rintro ⟨k, hk, rfl⟩
      refine ⟨fun _ => (k : ℝ) - 1 / 2, ?_⟩
      rw [pattern_thresholdFamily]
      ext i
      simp only [mem_initSeg, Nat.lt_ceil]
      constructor
      · intro h
        have hik : (i : ℝ) < (k : ℝ) := by linarith
        exact_mod_cast hik
      · intro h
        have h' : ((i : ℕ) : ℝ) + 1 ≤ (k : ℝ) := by exact_mod_cast Nat.succ_le_of_lt h
        linarith
  rw [regionCount, himg, Finset.card_image_of_injOn (initSeg_injOn n), Finset.card_range,
    schlafli_one_dim]

/-- The Schläfli bound is attained in dimension one. -/
theorem exists_regionCount_eq_schlafli_dim_one (n : ℕ) :
    ∃ F : AffineFamily n 1, F.regionCount = schlafli n 1 :=
  ⟨thresholdFamily n, regionCount_thresholdFamily n⟩

/-- The Schläfli bound is attained whenever the width is at most the dimension. -/
theorem exists_regionCount_eq_schlafli_of_le (h : n ≤ d) :
    ∃ F : AffineFamily n d, F.regionCount = schlafli n d :=
  ⟨coordFamily n d, regionCount_coordFamily h⟩

end AffineFamily

end ReLUPartition