import Probability.GaloisSideChannelSymmetryWall
import Cryptography.NonabelianTypeChannel.Semiprime

/-!
# The semiprime ledger of the Galois/Frobenius side channel

The catalog evaluates the semiprime residue channel `I₂ = I(coset(σ_p σ_q) ; {T p, T q})`
for six explicit fields (`Cryptography/NonabelianTypeChannel/Semiprime.lean`) and notes
that the `S₃`/`S₄` rows are "the `C₂` cap at the semiprime level".  This file proves the
general ledger behind that table, for *every* finite Galois group:

* `semiprime_residue_entropy` — the residue of `N = p q` is exactly uniform on the
  abelianization: `H(coset(σ_p σ_q)) = log₂ [S : N]`;
* `semiprime_residue_cap` — **the semiprime abelianization cap**: for *every* readout `R`
  of the ordered pair of Frobenius elements (types, ordered types, anything),
  `I(coset(σ_p σ_q) ; R) ≤ log₂ [S : N]`;
* `semiprime_residue_blind_to_each_factor` — **pure synergy**: the residue of `N`
  carries *exactly zero* bits about any readout of `σ_p` alone *and* about any readout
  of `σ_q` alone (one-time pad, in a possibly non-abelian group: the second half uses that
  the residue is a class function, `classFn_mul_swap`);
* `S4_semiprime_pure_synergy`, `D4_semiprime_pure_synergy` — the ledger instantiated on
  the catalog's `S₄` and `D₄` fields: zero bits about the splitting type of each factor,
  yet `1` bit (`S₄`) and `39/16 − (3/4)·log₂3 + (5/64)·log₂5 > 1` bits (`D₄`) about the
  *unordered* pair.  Every bit the residue of `N` leaks about the factorisation shape is
  *synergistic*: it is invisible to any single-factor reader.
-/

namespace TypeChannel

namespace GaloisSideChannel

open Finset Real

variable {G : Type*} [Group G] [DecidableEq G] {κ : Type*} [DecidableEq κ]
  {S N : Finset G} {c : G → κ}

/-- The fibres of the semiprime residue readout all have `|S| · |N|` elements. -/
lemma card_fiber_prodCoset (hS : IsSubgroupFinset S) (hNS : N ⊆ S)
    (hc : IsCosetReadout S N c) {g : G} (hg : g ∈ S) :
    (fiber (S ×ˢ S) (fun z : G × G => c (z.1 * z.2)) (c g)).card = S.card * N.card := by
  have := card_shear_filter hS (subset_refl S) (fun _ => True) (fun x => c x = c g)
  simp only [true_and, filter_true] at this
  unfold fiber
  rw [this]
  congr 1
  exact card_fiber_cosetReadout hS hNS hc hg

omit [DecidableEq G] in
lemma image_prodCoset (hS : IsSubgroupFinset S) :
    (S ×ˢ S).image (fun z : G × G => c (z.1 * z.2)) = S.image c := by
  ext k
  simp only [mem_image, mem_product, Prod.exists]
  constructor
  · rintro ⟨x, y, ⟨hx, hy⟩, rfl⟩
    exact ⟨x * y, hS.mul_mem _ hx _ hy, rfl⟩
  · rintro ⟨g, hg, rfl⟩
    exact ⟨g, 1, ⟨hg, hS.one_mem⟩, by rw [mul_one]⟩

/-- **The residue of `N = p q` is uniform on the abelianization.** -/
theorem semiprime_residue_entropy (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) :
    entropy (S ×ˢ S) (fun z : G × G => c (z.1 * z.2)) = logb 2 (S.image c).card := by
  rw [entropy_eq_logb_card_of_uniform_fibers (k := S.card * N.card)
    (Finset.Nonempty.product ⟨1, hS.one_mem⟩ ⟨1, hS.one_mem⟩)
    (Nat.mul_pos (card_pos.mpr ⟨1, hS.one_mem⟩) (card_pos.mpr ⟨1, hN.one_mem⟩)),
    image_prodCoset hS]
  intro k hk
  rw [image_prodCoset hS] at hk
  obtain ⟨g, hg, rfl⟩ := mem_image.mp hk
  exact card_fiber_prodCoset hS hNS hc hg

/-- **The semiprime abelianization cap.**  Whatever an adversary reads off the ordered
pair of Frobenius elements, the residue of `N = p q` shares at most `log₂ [S : N]` bits
with it. -/
theorem semiprime_residue_cap {ρ : Type*} [DecidableEq ρ] (hS : IsSubgroupFinset S)
    (hN : IsSubgroupFinset N) (hNS : N ⊆ S) (hc : IsCosetReadout S N c) (R : G × G → ρ) :
    mutualInfo (S ×ˢ S) (fun z : G × G => c (z.1 * z.2)) R ≤ logb 2 (S.image c).card := by
  rw [← semiprime_residue_entropy hS hN hNS hc]
  exact mutualInfo_le_left _ _ _

/-- **Pure synergy: the residue of `N` is blind to each factor separately.**  For any
readout `F` of a single Frobenius element (its splitting type, its residue class, its
conjugacy class, …), the residue of `N = p q` carries exactly zero bits about `F(σ_p)`
and exactly zero bits about `F(σ_q)`. -/
theorem semiprime_residue_blind_to_each_factor {α : Type*} [DecidableEq α]
    (hS : IsSubgroupFinset S) (hD : IsDerivedFinset S N) (hc : IsCosetReadout S N c)
    (F : G → α) :
    mutualInfo (S ×ˢ S) (fun z : G × G => c (z.1 * z.2)) (fun z => F z.1) = 0 ∧
      mutualInfo (S ×ˢ S) (fun z : G × G => c (z.1 * z.2)) (fun z => F z.2) = 0 := by
  have h1 : mutualInfo (S ×ˢ S) (fun z : G × G => c (z.1 * z.2)) (fun z => F z.1) = 0 := by
    rw [mutualInfo_comm]
    exact frobenius_one_time_pad hS (subset_refl S) F c
  refine ⟨h1, ?_⟩
  have himg : (S ×ˢ S).image Prod.swap = S ×ˢ S := by
    ext ⟨x, y⟩
    simp only [mem_image, mem_product, Prod.exists, Prod.swap_prod_mk, Prod.mk.injEq]
    constructor
    · rintro ⟨a, b, ⟨ha, hb⟩, rfl, rfl⟩; exact ⟨hb, ha⟩
    · rintro ⟨hx, hy⟩; exact ⟨y, x, ⟨hy, hx⟩, rfl, rfl⟩
  have hinj : Set.InjOn (Prod.swap : G × G → G × G) (S ×ˢ S : Finset (G × G)) :=
    fun a _ b _ h => Prod.swap_injective h
  rw [← himg, mutualInfo_image_of_injOn hinj]
  rw [← h1]
  refine mutualInfo_congr (fun z hz => ?_) (fun _ _ => rfl)
  simp only [mem_product] at hz
  simp only [Prod.fst_swap, Prod.snd_swap]
  exact classFn_mul_swap hS (cosetReadout_isClassFn hS hD hc) hz.1 hz.2

/-- **`S₄`: pure synergy in a five-type field.**  The residue (sign coset) of `N = p q`
carries zero bits about the splitting type of `p`, zero bits about that of `q`, exactly
one bit about the unordered pair of types, and never more than one bit about anything. -/
theorem S4_semiprime_pure_synergy :
    mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) (fun z => splitType z.1) = 0 ∧
    mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) (fun z => splitType z.2) = 0 ∧
    mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) symType = 1 ∧
    (∀ (R : Equiv.Perm (Fin 4) × Equiv.Perm (Fin 4) → ℕ × ℕ),
      mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) R ≤ 1) := by
  obtain ⟨h1, h2⟩ := semiprime_residue_blind_to_each_factor S4_isSubgroup S4_derived S4_coset
    splitType
  refine ⟨h1, h2, S4_semi_channel, fun R => ?_⟩
  have hcap := semiprime_residue_cap S4_isSubgroup A4_isSubgroup S4_derived.subset S4_coset R
  have himg : (S4.image signIdx).card = 2 := by decide
  rw [himg] at hcap
  simpa using hcap

/-- **`D₄`: pure synergy above the binary ceiling.**  The residue of `N = p q` in the `D₄`
field is blind to each factor's splitting type, yet carries more than one bit about the
unordered pair — and at most `2 = log₂ [D₄ : C₂]` bits about anything. -/
theorem D4_semiprime_pure_synergy :
    mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) (fun z => splitType z.1) = 0 ∧
    mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) (fun z => splitType z.2) = 0 ∧
    1 < mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) symType ∧
    (∀ (R : Equiv.Perm (Fin 4) × Equiv.Perm (Fin 4) → ℕ × ℕ),
      mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) R ≤ 2) := by
  obtain ⟨h1, h2⟩ := semiprime_residue_blind_to_each_factor D4_isSubgroup D4_derived D4_coset
    splitType
  refine ⟨h1, h2, ?_, fun R => ?_⟩
  · rw [D4_semi_channel]
    have h3 := logb2_three_lt_two
    have h5 := logb2_five_gt_two
    linarith
  · have hcap := semiprime_residue_cap D4_isSubgroup Z4c_isSubgroup D4_derived.subset
      D4_coset R
    have himg : (D4.image d4Idx).card = 4 := by decide
    rw [himg] at hcap
    have : logb 2 (4 : ℝ) = 2 := by
      rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.logb_pow]
      simp
    simpa [this] using hcap

/-! ## The semiprime which-factor wall for every group and every type readout

The catalog checks `I(coset(σ_p σ_q) ; ordered types) = I(coset(σ_p σ_q) ; unordered types)`
numerically for six fields (`S3_which_factor_wall`, …, `C4_which_factor_wall`).  We prove
it for *every* sample space closed under exchanging the factors, *every* swap-invariant
readout (in particular every class function of `σ_p σ_q`, e.g. the residue of `N`), and
*every* splitting-type readout `T`. -/

section OrderedWall

variable {τ : Type*} [LinearOrder τ] [DecidableEq τ]

/-- The unordered pair of splitting types. -/
def symPair (T : G → τ) (z : G × G) : τ × τ := (min (T z.1) (T z.2), max (T z.1) (T z.2))

/-- The ordered pair of splitting types. -/
def ordPair (T : G → τ) (z : G × G) : τ × τ := (T z.1, T z.2)

omit [Group G] [DecidableEq G] [DecidableEq τ] in
/-- The ordered pair is the unordered pair plus the which-factor bit. -/
lemma ordPair_eq_reconstruct (T : G → τ) (z : G × G) :
    ordPair T z = (if whichBit T z then symPair T z else ((symPair T z).2, (symPair T z).1)) := by
  unfold ordPair symPair whichBit
  rcases lt_trichotomy (T z.1) (T z.2) with h | h | h
  · simp [h, min_eq_left h.le, max_eq_right h.le]
  · simp [h]
  · simp [not_lt.mpr h.le, min_eq_right h.le, max_eq_left h.le]

omit [Group G] [DecidableEq G] [DecidableEq τ] in
lemma symPair_swap (T : G → τ) (z : G × G) : symPair T z.swap = symPair T z := by
  simp [symPair, min_comm, max_comm]

omit [Group G] [DecidableEq G] [DecidableEq κ] in
/-- On a fibre of the unordered type pair, exchanging the factors is label-transitive for
the which-factor bit. -/
lemma whichBit_labelTransitive_fiber {Ω₀ : Finset (G × G)} (hΩ : ∀ z ∈ Ω₀, z.swap ∈ Ω₀)
    (k : G × G → κ) (hk : ∀ z ∈ Ω₀, k z.swap = k z) (T : G → τ) (s : τ × τ) :
    LabelTransitive (fiber Ω₀ (symPair T) s) (whichBit T) k := by
  intro a ha b hb
  by_cases hab : a = b
  · subst hab
    exact ⟨id, Set.bijOn_id _, fun _ _ => rfl, fun _ _ => Iff.rfl⟩
  have hbna : b = !a := by cases a <;> cases b <;> simp_all
  -- some element of the fibre has strictly ordered types, hence `s.1 < s.2`
  have hlt : s.1 < s.2 := by
    have htrue : true ∈ (fiber Ω₀ (symPair T) s).image (whichBit T) := by
      cases a
      · rw [hbna] at hb; exact hb
      · exact ha
    obtain ⟨z, hz, hzt⟩ := mem_image.mp htrue
    have hs := (mem_filter.mp hz).2
    simp only [whichBit, decide_eq_true_eq] at hzt
    rw [← hs]
    simp [symPair, min_eq_left hzt.le, max_eq_right hzt.le, hzt]
  have hne : ∀ x ∈ fiber Ω₀ (symPair T) s, T x.1 ≠ T x.2 := by
    intro x hx heq
    have hs := (mem_filter.mp hx).2
    rw [← hs] at hlt
    simp [symPair, heq] at hlt
  have hmem : ∀ x ∈ fiber Ω₀ (symPair T) s, x.swap ∈ fiber Ω₀ (symPair T) s := by
    intro x hx
    obtain ⟨hx1, hx2⟩ := mem_filter.mp hx
    exact mem_filter.mpr ⟨hΩ x hx1, by rw [symPair_swap]; exact hx2⟩
  refine ⟨Prod.swap, ⟨hmem, fun x _ y _ hxy => Prod.swap_injective hxy,
    fun z hz => ⟨z.swap, hmem z hz, Prod.swap_swap z⟩⟩,
    fun x hx => hk x (mem_filter.mp hx).1, fun x hx => ?_⟩
  have hflip : whichBit T x.swap = !whichBit T x := by
    simp only [whichBit, Prod.fst_swap, Prod.snd_swap]
    rcases lt_or_gt_of_ne (hne x hx) with h | h
    · simp [h, not_lt.mpr h.le]
    · simp [h, not_lt.mpr h.le]
  rw [hflip, hbna]
  cases whichBit T x <;> cases a <;> simp

omit [Group G] [DecidableEq G] in
/-- **The semiprime which-factor wall, in general.**  On any sample space of ordered pairs
closed under exchanging the factors, for any readout `k` invariant under the exchange and
any splitting-type readout `T`, the ordered type pair carries *exactly* the same
information about `k` as the unordered one. -/
theorem ordered_eq_unordered_of_swap_invariant {Ω₀ : Finset (G × G)}
    (hΩ : ∀ z ∈ Ω₀, z.swap ∈ Ω₀) (k : G × G → κ) (hk : ∀ z ∈ Ω₀, k z.swap = k z)
    (T : G → τ) :
    mutualInfo Ω₀ k (ordPair T) = mutualInfo Ω₀ k (symPair T) := by
  -- the ordered pair induces the same partition as (unordered pair, which-factor bit)
  have hpart : mutualInfo Ω₀ k (ordPair T) = mutualInfo Ω₀ k (pairObs (symPair T) (whichBit T)) := by
    rw [mutualInfo_comm Ω₀ k, mutualInfo_comm Ω₀ k]
    refine mutualInfo_congr_partition k (fun z _ z' _ => ?_)
    simp only [pairObs, Prod.mk.injEq]
    constructor
    · rintro ⟨h1, h2⟩
      rw [ordPair_eq_reconstruct T z, ordPair_eq_reconstruct T z', h1, h2]
    · intro h
      refine ⟨?_, ?_⟩
      · simp only [symPair]
        simp only [ordPair, Prod.mk.injEq] at h
        rw [h.1, h.2]
      · simp only [whichBit]
        simp only [ordPair, Prod.mk.injEq] at h
        rw [h.1, h.2]
  rw [hpart, mutualInfo_pair_chain]
  have hcond : condMutualInfo Ω₀ k (whichBit T) (symPair T) = 0 := by
    refine Finset.sum_eq_zero (fun s _ => ?_)
    rw [mutualInfo_comm,
      (symmetry_wall (whichBit_labelTransitive_fiber hΩ k hk T s)).1, mul_zero]
  rw [hcond, add_zero]

omit [DecidableEq G] in
/-- **Corollary: the residue of `N` never learns which factor is which.**  For every
finite Galois group `S`, every class function `H` (residue class of `N`, Artin symbol,
cycle type of `σ_p σ_q`, …) and every splitting-type readout `T`,
`I(H(σ_p σ_q) ; (T p, T q)) = I(H(σ_p σ_q) ; {T p, T q})`.  This proves the catalog's six
numerical which-factor walls (`S3_which_factor_wall`, …) in full generality. -/
theorem semiprime_whichFactor_wall_general {H : G → κ} (hS : IsSubgroupFinset S)
    (hH : IsClassFn S H) (T : G → τ) :
    mutualInfo (S ×ˢ S) (fun z : G × G => H (z.1 * z.2)) (ordPair T)
      = mutualInfo (S ×ˢ S) (fun z : G × G => H (z.1 * z.2)) (symPair T) := by
  refine ordered_eq_unordered_of_swap_invariant (fun z hz => ?_) _ (fun z hz => ?_) T
  · simp only [mem_product] at hz ⊢
    exact ⟨hz.2, hz.1⟩
  · simp only [mem_product] at hz
    simp only [Prod.fst_swap, Prod.snd_swap]
    exact classFn_mul_swap hS hH hz.1 hz.2

/-- The catalog's numerically verified which-factor walls for `S₄` and `D₄`, re-derived
from the general theorem without evaluating a single entropy. -/
theorem S4_D4_which_factor_walls_structural :
    mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) ordType
        = mutualInfo (S4 ×ˢ S4) (prodCoset signIdx) symType ∧
    mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) ordType
        = mutualInfo (D4 ×ˢ D4) (prodCoset d4Idx) symType :=
  ⟨semiprime_whichFactor_wall_general S4_isSubgroup
      (cosetReadout_isClassFn S4_isSubgroup S4_derived S4_coset) typeCode,
    semiprime_whichFactor_wall_general D4_isSubgroup
      (cosetReadout_isClassFn D4_isSubgroup D4_derived D4_coset) typeCode⟩

end OrderedWall

end GaloisSideChannel

end TypeChannel