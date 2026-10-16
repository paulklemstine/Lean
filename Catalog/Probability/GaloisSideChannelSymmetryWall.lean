import Probability.GaloisSideChannelIndependence

/-!
# The which-factor wall for Galois groups, for any number of prime factors

The catalog's which-factor wall (`CyclicTypeChannel.whichFactor_wall`,
`Combinatorics/D12SemiprimeWhichFactorWall.lean`) is stated for the cyclic exponent box
of `Q(ζ_ℓ)` and for a *binary* label.  This file lifts it to

* an **abstract symmetry wall** (`symmetry_wall`): whenever the readout-preserving
  symmetries of the sample space act transitively on the values of a label `w`, the
  label is *exactly* uniform (`log₂ #labels` bits) and *every* readout preserved by those
  symmetries carries *exactly* zero bits about it;
* the **Galois semiprime wall** (`galois_whichFactor_wall`) over an *arbitrary*, possibly
  non-abelian, finite Galois group, with the key arithmetic input proved rather than
  assumed: the residue class of `N = p q` (the abelianization coset of `σ_p σ_q`) and
  more generally every class function of `σ_p σ_q` is swap-invariant
  (`classFn_mul_swap`, `cosetReadout_isClassFn`), so the full readout
  (residue of `N`, unordered type pair) hides the which-factor bit completely
  (`residue_and_types_hide_whichFactor`);
* the **multi-prime wall** (`multiFactor_wall`): for `N = p₀ ⋯ p_m` with pairwise
  distinct splitting types, *which of the `m+1` factors carries the smallest type* is a
  label of exactly `log₂ (m+1)` bits, and every readout invariant under transposing two
  factors carries exactly zero bits about it.

Each wall is shown non-vacuous: the *ordered* readout recovers the whole label
(`galois_whichFactor_ordered_full`, `multiFactor_ordered_full`).
-/

namespace TypeChannel

namespace GaloisSideChannel

open Finset Real

variable {Ω α β : Type*} [DecidableEq α] [DecidableEq β]

/-! ## 1. The abstract symmetry wall -/

section Abstract

variable {S : Finset Ω} {w : Ω → α} {k : Ω → β}

/-- The hypothesis of the symmetry wall: for any two label values in use there is a
bijection of the sample space preserving the readout `k` and carrying the first label
class onto the second. -/
def LabelTransitive (S : Finset Ω) (w : Ω → α) (k : Ω → β) : Prop :=
  ∀ a ∈ S.image w, ∀ b ∈ S.image w, ∃ σ : Ω → Ω,
    Set.BijOn σ S S ∧ (∀ x ∈ S, k (σ x) = k x) ∧ (∀ x ∈ S, w (σ x) = b ↔ w x = a)

/-- Symmetric cells have the same size. -/
lemma cell_card_eq (h : LabelTransitive S w k) {a b : α} (ha : a ∈ S.image w)
    (hb : b ∈ S.image w) (c : β) :
    (fiber S (pairObs w k) (a, c)).card = (fiber S (pairObs w k) (b, c)).card := by
  obtain ⟨σ, hbij, hk, hw⟩ := h a ha b hb
  refine Finset.card_nbij σ ?_ ?_ ?_
  · intro x hx
    have hx' := Finset.mem_filter.mp hx
    simp only [pairObs, Prod.mk.injEq] at hx'
    refine Finset.mem_filter.mpr ⟨hbij.mapsTo hx'.1, ?_⟩
    simp only [pairObs, Prod.mk.injEq]
    exact ⟨(hw x hx'.1).mpr hx'.2.1, by rw [hk x hx'.1, hx'.2.2]⟩
  · intro x hx y hy hxy
    exact hbij.injOn (fiber_subset (Finset.mem_coe.mp hx))
      (fiber_subset (Finset.mem_coe.mp hy)) hxy
  · intro y hy
    simp only [fiber, pairObs, coe_filter, Set.mem_setOf_eq, Prod.mk.injEq] at hy
    obtain ⟨x, hx, rfl⟩ := hbij.surjOn hy.1
    refine ⟨x, ?_, rfl⟩
    simp only [fiber, pairObs, coe_filter, Set.mem_setOf_eq, Prod.mk.injEq]
    exact ⟨hx, (hw x hx).mp hy.2.1, by rw [← hk x hx, hy.2.2]⟩

/-- In each readout cell the label is uniform. -/
lemma prob_cell_eq (h : LabelTransitive S w k) {a : α} (ha : a ∈ S.image w) (c : β) :
    prob S (pairObs w k) (a, c) * (S.image w).card = prob S k c := by
  rw [← sum_prob_pair_left (S := S) (f := w) (g := k) c]
  have : ∀ b ∈ S.image w, prob S (pairObs w k) (b, c) = prob S (pairObs w k) (a, c) := by
    intro b hb
    unfold prob
    rw [cell_card_eq h hb ha c]
  rw [Finset.sum_congr rfl this, Finset.sum_const, nsmul_eq_mul, mul_comm]

/-- The label itself is uniform. -/
lemma prob_label_eq (h : LabelTransitive S w k) {a : α} (ha : a ∈ S.image w) :
    prob S w a * (S.image w).card = 1 := by
  obtain ⟨x, hx, _⟩ := mem_image.mp ha
  rw [← sum_prob_pair_right (S := S) (f := w) (g := k) a, Finset.sum_mul,
    Finset.sum_congr rfl (fun c _ => prob_cell_eq h ha c), sum_prob ⟨x, hx⟩]

/-- **The symmetry wall.**  If the readout-preserving symmetries act transitively on the
label values, the readout carries *exactly* zero bits about the label, while the label
carries *exactly* `log₂ #labels` bits. -/
theorem symmetry_wall (h : LabelTransitive S w k) :
    mutualInfo S w k = 0 ∧ entropy S w = logb 2 (S.image w).card := by
  constructor
  · refine mutualInfo_eq_zero_of_prob_mul (fun a ha c _ => ?_)
    have h1 := prob_cell_eq h ha c
    have h2 := prob_label_eq h ha
    have hm : ((S.image w).card : ℝ) ≠ 0 := by
      exact_mod_cast (card_pos.mpr ⟨a, ha⟩).ne'
    have hpa : prob S w a = 1 / (S.image w).card := by
      field_simp; linarith
    rw [hpa]
    field_simp
    linarith
  · rcases S.eq_empty_or_nonempty with hS | hS
    · subst hS; simp [entropy]
    obtain ⟨x₀, hx₀⟩ := hS
    refine entropy_eq_logb_card_of_uniform_fibers (k := (fiber S w (w x₀)).card) ⟨x₀, hx₀⟩
      (card_pos.mpr ⟨x₀, mem_filter.mpr ⟨hx₀, rfl⟩⟩) (fun a ha => ?_)
    have h1 := prob_label_eq h ha
    have h2 := prob_label_eq h (mem_image_of_mem w hx₀)
    have hm : ((S.image w).card : ℝ) ≠ 0 := by
      exact_mod_cast (card_pos.mpr ⟨a, ha⟩).ne'
    have hS : (S.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.mpr ⟨x₀, hx₀⟩).ne'
    have : prob S w a = prob S w (w x₀) := by
      have := h1.trans h2.symm
      exact mul_right_cancel₀ hm this
    unfold prob at this
    rw [div_left_inj' hS] at this
    exact_mod_cast this

end Abstract

/-! ## 2. The Galois semiprime wall -/

section Semiprime

variable {G : Type*} {τ : Type*} [LinearOrder τ]

/-- A readout of the Galois group that is constant on conjugacy classes (within `S`). -/
def IsClassFn [Group G] {κ : Type*} (S : Finset G) (H : G → κ) : Prop :=
  ∀ g ∈ S, ∀ h ∈ S, H (g * h * g⁻¹) = H h

/-- **The residue of `N` is a class function.**  A coset readout of the derived subgroup
is constant on conjugacy classes, because `(g h g⁻¹) h⁻¹` is a commutator. -/
theorem cosetReadout_isClassFn [Group G] {κ : Type*} {S N : Finset G} {c : G → κ}
    (hS : IsSubgroupFinset S) (hD : IsDerivedFinset S N) (hc : IsCosetReadout S N c) :
    IsClassFn S c := by
  intro g hg h hh
  have hmem : g * h * g⁻¹ ∈ S := hS.mul_mem _ (hS.mul_mem _ hg _ hh) _ (hS.inv_mem _ hg)
  exact (hc _ hmem h hh).mpr (hD.commutator_mem g hg h hh)

/-- **Class functions of `σ_p σ_q` are swap-invariant**: `σ_q σ_p = σ_p⁻¹ (σ_p σ_q) σ_p`. -/
theorem classFn_mul_swap [Group G] {κ : Type*} {S : Finset G} {H : G → κ} (hS : IsSubgroupFinset S)
    (hH : IsClassFn S H) {x y : G} (hx : x ∈ S) (hy : y ∈ S) :
    H (y * x) = H (x * y) := by
  have := hH x⁻¹ (hS.inv_mem _ hx) (x * y) (hS.mul_mem _ hx _ hy)
  rw [inv_inv] at this
  rw [← this]
  congr 1
  group

/-- The semiprime sample space: ordered pairs of candidate Frobenius elements whose
splitting types differ (so that "which factor?" is a genuine question). -/
def asymPairs (A : Finset G) (T : G → τ) : Finset (G × G) :=
  (A ×ˢ A).filter (fun z => T z.1 ≠ T z.2)

/-- The which-factor bit: does the first factor carry the smaller splitting type? -/
def whichBit (T : G → τ) (z : G × G) : Bool := decide (T z.1 < T z.2)

lemma swap_mem_asymPairs {A : Finset G} {T : G → τ} {z : G × G} (hz : z ∈ asymPairs A T) :
    z.swap ∈ asymPairs A T := by
  simp only [asymPairs, mem_filter, mem_product, Prod.fst_swap, Prod.snd_swap] at hz ⊢
  exact ⟨⟨hz.1.2, hz.1.1⟩, fun h => hz.2 h.symm⟩

lemma whichBit_swap {A : Finset G} {T : G → τ} {z : G × G} (hz : z ∈ asymPairs A T) :
    whichBit T z.swap = !whichBit T z := by
  simp only [asymPairs, mem_filter] at hz
  simp only [whichBit, Prod.fst_swap, Prod.snd_swap]
  rcases lt_or_gt_of_ne hz.2 with h | h
  · simp [h, not_lt.mpr h.le]
  · simp [h, not_lt.mpr h.le]

/-- Swap-invariant readouts make the which-factor bit label-transitive. -/
lemma whichBit_labelTransitive {κ : Type*} [DecidableEq κ] (A : Finset G) (T : G → τ)
    (k : G × G → κ) (hk : ∀ z ∈ asymPairs A T, k z.swap = k z) :
    LabelTransitive (asymPairs A T) (whichBit T) k := by
  intro a _ b _
  by_cases hab : a = b
  · subst hab
    exact ⟨id, Set.bijOn_id _, fun _ _ => rfl, fun _ _ => Iff.rfl⟩
  · have hb : b = !a := by cases a <;> cases b <;> simp_all
    refine ⟨Prod.swap, ⟨fun z hz => swap_mem_asymPairs hz, fun x _ y _ hxy => by
      simpa using congrArg Prod.swap hxy, fun z hz => ⟨z.swap, swap_mem_asymPairs hz,
        Prod.swap_swap z⟩⟩, hk, fun z hz => ?_⟩
    rw [whichBit_swap hz, hb]
    cases whichBit T z <;> cases a <;> simp

/-- **The Galois which-factor wall.**  Over an arbitrary finite Galois group (abelian or
not), for *every* readout `k` of the semiprime that is invariant under exchanging the two
factors, `k` carries *exactly* zero bits about which factor carries the smaller splitting
type — and that bit is a genuine full bit whenever the sample space is nonempty. -/
theorem galois_whichFactor_wall {κ : Type*} [DecidableEq κ] (A : Finset G) (T : G → τ)
    (k : G × G → κ) (hk : ∀ z ∈ asymPairs A T, k z.swap = k z) :
    mutualInfo (asymPairs A T) (whichBit T) k = 0 ∧
      ((asymPairs A T).Nonempty → entropy (asymPairs A T) (whichBit T) = 1) := by
  obtain ⟨h0, hH⟩ := symmetry_wall (whichBit_labelTransitive A T k hk)
  refine ⟨h0, fun ⟨z, hz⟩ => ?_⟩
  rw [hH]
  have himg : (asymPairs A T).image (whichBit T) = {true, false} := by
    apply Finset.Subset.antisymm
    · intro b _; cases b <;> simp
    · intro b hb
      have hz' := swap_mem_asymPairs hz
      have hw := whichBit_swap hz
      rcases (show b = whichBit T z ∨ b = whichBit T z.swap by
          rw [hw]; simp only [mem_insert, mem_singleton] at hb
          cases b <;> cases whichBit T z <;> simp_all) with rfl | rfl
      · exact mem_image_of_mem _ hz
      · exact mem_image_of_mem _ hz'
  rw [himg]
  simp

/-- **Residue and unordered types hide the which-factor bit.**  Let `S` be a finite Galois
group with derived subgroup `N`, `c` the residue (coset) readout, and `T` the splitting
type.  The readout an arithmetic adversary actually has on `N = p q` — the residue class
of `N` (coset of `σ_p σ_q`) *together with* the unordered pair of splitting types —
carries exactly zero bits about which factor carries which type. -/
theorem residue_and_types_hide_whichFactor [Group G] {κ : Type*} [DecidableEq κ] {S N : Finset G}
    {c : G → κ} (hS : IsSubgroupFinset S) (hD : IsDerivedFinset S N)
    (hc : IsCosetReadout S N c) (T : G → τ) :
    mutualInfo (asymPairs S T) (whichBit T)
        (fun z => (c (z.1 * z.2), min (T z.1) (T z.2), max (T z.1) (T z.2))) = 0 := by
  refine (galois_whichFactor_wall S T _ (fun z hz => ?_)).1
  simp only [asymPairs, mem_filter, mem_product] at hz
  simp only [Prod.fst_swap, Prod.snd_swap, min_comm, max_comm]
  rw [classFn_mul_swap hS (cosetReadout_isClassFn hS hD hc) hz.1.1 hz.1.2]

/-- The same wall for the *conjugacy class* (Artin symbol) of `σ_p σ_q`: any class
function of the product, together with the unordered types, hides the bit. -/
theorem artin_and_types_hide_whichFactor [Group G] {κ : Type*} [DecidableEq κ] {S : Finset G}
    {H : G → κ} (hS : IsSubgroupFinset S) (hH : IsClassFn S H) (T : G → τ) :
    mutualInfo (asymPairs S T) (whichBit T)
        (fun z => (H (z.1 * z.2), min (T z.1) (T z.2), max (T z.1) (T z.2))) = 0 := by
  refine (galois_whichFactor_wall S T _ (fun z hz => ?_)).1
  simp only [asymPairs, mem_filter, mem_product] at hz
  simp only [Prod.fst_swap, Prod.snd_swap, min_comm, max_comm]
  rw [classFn_mul_swap hS hH hz.1.1 hz.1.2]

/-- **Non-vacuity.**  The *ordered* type readout recovers the full which-factor entropy. -/
theorem galois_whichFactor_ordered_full (A : Finset G) (T : G → τ) :
    mutualInfo (asymPairs A T) (whichBit T) (fun z => (T z.1, T z.2))
      = entropy (asymPairs A T) (whichBit T) :=
  mutualInfo_eq_left_of_factors (φ := fun u : τ × τ => decide (u.1 < u.2)) (fun _ _ => rfl)

end Semiprime

/-! ## 3. The multi-prime wall -/

section MultiPrime

variable {G : Type*} {τ : Type*} [LinearOrder τ]

/-- The sample space for `N = p₀ ⋯ p_m`: tuples of candidate Frobenius elements in `A`
whose splitting types are pairwise distinct. -/
def distinctTuples (m : ℕ) (A : Finset G) (T : G → τ) : Finset (Fin (m + 1) → G) :=
  (Fintype.piFinset (fun _ => A)).filter (fun x => Function.Injective (fun i => T (x i)))

/-- The label: the set of factors carrying the smallest splitting type (a singleton on
`distinctTuples`). -/
def minFactor {m : ℕ} (T : G → τ) (x : Fin (m + 1) → G) : Finset (Fin (m + 1)) :=
  univ.filter (fun i => ∀ j, T (x i) ≤ T (x j))

lemma minFactor_comp_perm {m : ℕ} (T : G → τ) (x : Fin (m + 1) → G)
    (s : Equiv.Perm (Fin (m + 1))) :
    minFactor T (x ∘ s) = (minFactor T x).image s.symm := by
  ext l
  simp only [minFactor, mem_filter, mem_univ, true_and, Function.comp, mem_image]
  constructor
  · intro h
    refine ⟨s l, fun j => ?_, by simp⟩
    simpa using h (s.symm j)
  · rintro ⟨i, hi, rfl⟩ j
    simpa using hi (s j)

lemma minFactor_singleton {m : ℕ} {A : Finset G} {T : G → τ} {x : Fin (m + 1) → G}
    (hx : x ∈ distinctTuples m A T) : ∃ i, minFactor T x = {i} := by
  simp only [distinctTuples, mem_filter] at hx
  obtain ⟨i, -, hi⟩ := Finset.exists_min_image univ (fun i => T (x i)) univ_nonempty
  refine ⟨i, ?_⟩
  ext l
  simp only [minFactor, mem_filter, mem_univ, true_and, mem_singleton]
  constructor
  · intro hl
    exact hx.2 (le_antisymm (hl i) (hi l (mem_univ _)))
  · rintro rfl j; exact hi j (mem_univ _)

lemma comp_swap_mem {m : ℕ} {A : Finset G} {T : G → τ} {x : Fin (m + 1) → G}
    (hx : x ∈ distinctTuples m A T) (i j : Fin (m + 1)) :
    x ∘ Equiv.swap i j ∈ distinctTuples m A T := by
  simp only [distinctTuples, mem_filter, Fintype.mem_piFinset, Function.comp] at hx ⊢
  exact ⟨fun t => hx.1 _, fun a b hab => (Equiv.swap i j).injective (hx.2 hab)⟩

/-- Transposition-invariant readouts make the min-factor label transitive. -/
lemma minFactor_labelTransitive {κ : Type*} [DecidableEq κ] (m : ℕ) (A : Finset G)
    (T : G → τ) (k : (Fin (m + 1) → G) → κ)
    (hk : ∀ x ∈ distinctTuples m A T, ∀ i j, k (x ∘ Equiv.swap i j) = k x) :
    LabelTransitive (distinctTuples m A T) (minFactor T) k := by
  intro a ha b hb
  obtain ⟨x, hx, rfl⟩ := mem_image.mp ha
  obtain ⟨y, hy, rfl⟩ := mem_image.mp hb
  obtain ⟨i, hi⟩ := minFactor_singleton hx
  obtain ⟨j, hj⟩ := minFactor_singleton hy
  rw [hi, hj]
  refine ⟨fun z => z ∘ Equiv.swap i j, ⟨fun z hz => comp_swap_mem hz i j, ?_, ?_⟩,
    fun z hz => hk z hz i j, fun z _ => ?_⟩
  · intro u _ v _ huv
    funext t
    have := congrFun huv (Equiv.swap i j t)
    simpa using this
  · intro z hz
    exact ⟨z ∘ Equiv.swap i j, comp_swap_mem hz i j, by
      ext t; simp [Function.comp]⟩
  · rw [minFactor_comp_perm, Equiv.symm_swap]
    constructor
    · intro h
      have := congrArg (Finset.image (Equiv.swap i j)) h
      simpa [Finset.image_image, Function.comp_def] using this
    · intro h
      rw [h]; simp

/-- **The multi-prime which-factor wall.**  For `N = p₀ ⋯ p_m` with pairwise distinct
splitting types (Frobenius candidates in any finite set `A` of any group), *which factor
carries the smallest splitting type* is a label of exactly `log₂ (m + 1)` bits, and every
readout of the tuple that is invariant under exchanging two factors — the residue of `N`
in an abelian quotient, the multiset of splitting types, any symmetric function of the
factors — carries **exactly zero** bits about it. -/
theorem multiFactor_wall {κ : Type*} [DecidableEq κ] (m : ℕ) (A : Finset G) (T : G → τ)
    (k : (Fin (m + 1) → G) → κ)
    (hk : ∀ x ∈ distinctTuples m A T, ∀ i j, k (x ∘ Equiv.swap i j) = k x) :
    mutualInfo (distinctTuples m A T) (minFactor T) k = 0 ∧
      ((distinctTuples m A T).Nonempty →
        entropy (distinctTuples m A T) (minFactor T) = logb 2 (m + 1)) := by
  obtain ⟨h0, hH⟩ := symmetry_wall (minFactor_labelTransitive m A T k hk)
  refine ⟨h0, fun ⟨x, hx⟩ => ?_⟩
  rw [hH]
  obtain ⟨i, hi⟩ := minFactor_singleton hx
  have himg : (distinctTuples m A T).image (minFactor T) = univ.image (fun j => {j}) := by
    ext a
    simp only [mem_image, mem_univ, true_and]
    constructor
    · rintro ⟨y, hy, rfl⟩
      obtain ⟨j, hj⟩ := minFactor_singleton hy
      exact ⟨j, hj.symm⟩
    · rintro ⟨j, rfl⟩
      refine ⟨x ∘ Equiv.swap i j, comp_swap_mem hx i j, ?_⟩
      rw [minFactor_comp_perm, hi, Equiv.symm_swap]
      simp
  rw [himg, Finset.card_image_of_injective _ (fun a b h => Finset.singleton_injective h),
    card_univ, Fintype.card_fin]
  push_cast
  ring_nf

/-- **Non-vacuity.**  The ordered tuple of splitting types determines the label, so the
ordered readout carries its full entropy. -/
theorem multiFactor_ordered_full (m : ℕ) (A : Finset G) (T : G → τ) :
    mutualInfo (distinctTuples m A T) (minFactor T) (fun x i => T (x i))
      = entropy (distinctTuples m A T) (minFactor T) :=
  mutualInfo_eq_left_of_factors
    (φ := fun t : Fin (m + 1) → τ => univ.filter (fun i => ∀ j, t i ≤ t j)) (fun _ _ => rfl)

end MultiPrime

end GaloisSideChannel

end TypeChannel