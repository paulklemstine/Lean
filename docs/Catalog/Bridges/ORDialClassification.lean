import Mathlib
import Bridges.ORDialCap
import Bridges.ORDialMaximum

/-!
# Classification of the maximisers of the semiprime OR dial

`Bridges.ORDialMaximum` proves the variational principle: every class-rate profile on a
finite abelian class group obeys `Φ ≤ orCap = H(3/4) - ½H(1/2)`, and the index-two
(quadratic character) kernels attain it.  Two rigidity statements were proved there: a
maximiser has mean no-fork rate `1/2`, and its conditional no-fork probabilities are
two-valued (`0` or `1/2`).

Here we close the classification for *deterministic* (0/1-valued) profiles:

* `orInfo_comp_mulLeft`: the OR channel is invariant under translating the profile,
  so every **coset** of an index-two subgroup is a maximiser as well (this is the
  "complement" transform of the mission statement).
* `binary_max_iff_coset`: a 0/1 profile attains the cap **iff** its support is a coset
  of an index-two subgroup — i.e. exactly the quadratic-character kernels and their
  complements, and nothing else.
* `binary_of_max`: a maximiser cannot be genuinely probabilistic — it is automatically
  0/1-valued.
* `max_iff_coset_indicator`: **the complete variational principle.**  An arbitrary
  profile `r : G → [0,1]` attains `orCap` iff it is the indicator of a coset of an
  index-two subgroup.
-/

open Real Finset

namespace ORDial

variable {G : Type*} [Fintype G] [CommGroup G]

/-! ## Translation invariance of the OR channel -/

/-- Averaging is invariant under the translation `a ↦ x a`. -/
lemma avg_comp_mulLeft (F : G → ℝ) (x : G) : avg (fun a => F (x * a)) = avg F := by
  unfold avg; congr 1
  exact Fintype.sum_equiv (Equiv.mulLeft x) _ _ (fun a => rfl)

/-- Translating the profile by `x` translates the conditional no-fork probabilities by
`x²`. -/
lemma noFork_comp_mulLeft (s : G → ℝ) (x c : G) :
    noFork (fun a => s (x * a)) c = noFork s (x * x * c) := by
  unfold noFork
  rw [← avg_comp_mulLeft (fun b => s b * s (x * x * c * b⁻¹)) x]
  congr 1
  funext a
  have harg : x * (c * a⁻¹) = x * x * c * (x * a)⁻¹ := by
    rw [mul_inv_rev, mul_comm a⁻¹ x⁻¹, mul_assoc (x*x) c, mul_left_comm c x⁻¹,
      ← mul_assoc (x*x) x⁻¹, mul_assoc x x x⁻¹, mul_inv_cancel, mul_one]
  simp only [harg]

/-- **Translation invariance.**  The OR channel only sees the profile up to translation
of the class group. -/
theorem orInfo_comp_mulLeft (s : G → ℝ) (x : G) :
    orInfo (fun a => s (x * a)) = orInfo s := by
  unfold orInfo
  rw [avg_comp_mulLeft s x]
  congr 1
  have hfun : (fun c => Real.binEntropy (noFork (fun a => s (x * a)) c))
      = fun c => (fun d => Real.binEntropy (noFork s d)) (x * x * c) := by
    funext c; rw [noFork_comp_mulLeft]
  rw [hfun]
  exact avg_comp_mulLeft (fun d => Real.binEntropy (noFork s d)) (x * x)

/-- **Cosets of a quadratic kernel are maximisers too.**  Shifting an index-two kernel
profile by any `x` (in particular passing to the complement) leaves the channel at the
cap. -/
theorem orInfo_coset_index_two (K : Subgroup G) (h : K.index = 2) (x : G) :
    orInfo (fun a => subgroupProfile K (x⁻¹ * a)) = orCap := by
  rw [orInfo_comp_mulLeft (subgroupProfile K) x⁻¹, orInfo_index_two_eq_orCap K h]

/-! ## Deterministic profiles -/

variable [DecidableEq G]

/-- The 0/1 profile supported on a finite set `A` of classes. -/
def binProfile (A : Finset G) : G → ℝ := fun a => if a ∈ A then 1 else 0

omit [Fintype G] [CommGroup G] in
lemma binProfile_nonneg (A : Finset G) (a : G) : 0 ≤ binProfile A a := by
  unfold binProfile; split <;> norm_num

omit [Fintype G] [CommGroup G] in
lemma binProfile_le_one (A : Finset G) (a : G) : binProfile A a ≤ 1 := by
  unfold binProfile; split <;> norm_num

omit [CommGroup G] in
lemma avg_binProfile (A : Finset G) : avg (binProfile A) = (A.card : ℝ) / Fintype.card G := by
  unfold avg binProfile
  congr 1
  simp

/-- The number of ways to write the class `c` as a product of two classes in `A`. -/
def repCount (A : Finset G) (c : G) : ℕ := (A.filter (fun a => c * a⁻¹ ∈ A)).card

lemma noFork_binProfile (A : Finset G) (c : G) :
    noFork (binProfile A) c = (repCount A c : ℝ) / Fintype.card G := by
  unfold noFork avg binProfile repCount
  congr 1
  have h : ∀ a : G, (if a ∈ A then (1:ℝ) else 0) * (if c * a⁻¹ ∈ A then 1 else 0)
      = if (a ∈ A ∧ c * a⁻¹ ∈ A) then 1 else 0 := by
    intro a; by_cases h1 : a ∈ A <;> by_cases h2 : c * a⁻¹ ∈ A <;> simp [h1, h2]
  simp only [h, Finset.sum_boole]
  congr 2
  ext a
  simp [Finset.mem_filter]

/-- Unconditional counting identity: the representation function of `A` sums to `|A|²`. -/
lemma sum_repCount (A : Finset G) : ∑ c : G, repCount A c = A.card * A.card := by
  have hN : (0:ℝ) < Fintype.card G := card_pos' (G := G)
  have h := avg_noFork (binProfile A)
  have hL : avg (noFork (binProfile A))
      = (∑ c : G, (repCount A c : ℝ)) / ((Fintype.card G : ℝ) * Fintype.card G) := by
    unfold avg
    simp only [noFork_binProfile]
    rw [← Finset.sum_div]
    field_simp
  rw [hL, avg_binProfile, div_pow] at h
  have : (∑ c : G, (repCount A c : ℝ)) = (A.card : ℝ) * A.card := by
    field_simp at h
    nlinarith [h, hN]
  exact_mod_cast this

/-- A maximising 0/1 profile is supported on exactly half of the class group. -/
lemma card_support_of_binary_max (A : Finset G) (heq : orInfo (binProfile A) = orCap) :
    2 * A.card = Fintype.card G := by
  have hN : (0:ℝ) < Fintype.card G := card_pos' (G := G)
  have h := mean_eq_half_of_orInfo_eq_orCap (binProfile_nonneg A) (binProfile_le_one A) heq
  rw [avg_binProfile] at h
  have h2 : 2 * (A.card : ℝ) = (Fintype.card G : ℝ) := by
    field_simp at h; linarith
  exact_mod_cast h2

/-- For a maximiser, every class has either no representation as a product of two support
classes, or the maximal number `|A|` of them. -/
lemma repCount_of_binary_max (A : Finset G) (heq : orInfo (binProfile A) = orCap) (c : G) :
    repCount A c = 0 ∨ repCount A c = A.card := by
  have hN : (0:ℝ) < Fintype.card G := card_pos' (G := G)
  have hcard := card_support_of_binary_max A heq
  have h := noFork_eq_zero_or_half_of_max (binProfile_nonneg A) (binProfile_le_one A) heq c
  rw [noFork_binProfile] at h
  rcases h with h | h
  · left
    have h0 : (repCount A c : ℝ) = 0 := by field_simp at h; simpa using h
    exact_mod_cast h0
  · right
    have h2 : 2 * (repCount A c : ℝ) = (Fintype.card G : ℝ) := by
      field_simp at h; linarith
    have h3 : 2 * repCount A c = Fintype.card G := by exact_mod_cast h2
    omega

/-! ## The translation stabiliser -/

/-- The translation stabiliser of a finite set of classes, as a subgroup. -/
def stab (A : Finset G) : Subgroup G where
  carrier := {g : G | A.image (fun a => g * a) = A}
  mul_mem' := by
    intro g h hg hh
    simp only [Set.mem_setOf_eq] at hg hh ⊢
    have hcomp : (fun a : G => g * h * a) = (fun a : G => g * a) ∘ (fun a : G => h * a) := by
      funext a; simp [mul_assoc]
    rw [hcomp, ← Finset.image_image, hh, hg]
  one_mem' := by
    show A.image (fun a : G => 1 * a) = A
    simp only [one_mul]
    exact Finset.image_id'
  inv_mem' := by
    intro g hg
    simp only [Set.mem_setOf_eq] at hg ⊢
    conv_lhs => rw [← hg]
    rw [Finset.image_image]
    have hcomp : (fun a : G => g⁻¹ * a) ∘ (fun a : G => g * a) = id := by
      funext a; simp [← mul_assoc]
    rw [hcomp, Finset.image_id]

omit [Fintype G] in
lemma mem_stab_iff {A : Finset G} {g : G} : g ∈ stab A ↔ A.image (fun a => g * a) = A := Iff.rfl

/-! ## The classification -/

/-- **Classification of the deterministic maximisers.**  If a 0/1 class-rate profile
attains the cap, then its support is a coset of an index-two subgroup — i.e. the profile
is a quadratic-character kernel profile or its complement. -/
theorem coset_of_binary_max (A : Finset G) (heq : orInfo (binProfile A) = orCap) :
    ∃ (K : Subgroup G) (x : G), K.index = 2 ∧ ∀ a : G, a ∈ A ↔ x⁻¹ * a ∈ K := by
  have hcard : 2 * A.card = Fintype.card G := card_support_of_binary_max A heq
  have hGpos : 0 < Fintype.card G := Fintype.card_pos
  have hApos : 0 < A.card := by omega
  classical
  set S : Finset G := Finset.univ.filter (fun c => repCount A c = A.card) with hSdef
  -- the number of classes with full representation count is `|A|`
  have hsplit : ∑ c : G, repCount A c = S.card * A.card := by
    rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun c => repCount A c = A.card)]
    have h1 : ∑ c ∈ S, repCount A c = S.card * A.card := by
      rw [Finset.sum_congr rfl (fun c hc => (Finset.mem_filter.mp hc).2), Finset.sum_const,
        smul_eq_mul]
    have h2 : ∑ c ∈ Finset.univ.filter (fun c => ¬ repCount A c = A.card), repCount A c = 0 := by
      refine Finset.sum_eq_zero fun c hc => ?_
      have hne := (Finset.mem_filter.mp hc).2
      rcases repCount_of_binary_max A heq c with h | h
      · exact h
      · exact absurd h hne
    rw [h2, add_zero, ← hSdef, h1]
  have hScard : S.card = A.card := by
    have hmul : S.card * A.card = A.card * A.card := by rw [← hsplit, sum_repCount A]
    exact Nat.eq_of_mul_eq_mul_right hApos hmul
  -- membership in `S` says that the involution `a ↦ c a⁻¹` permutes the support
  have hmemS : ∀ c : G, c ∈ S ↔ A.image (fun a => c * a⁻¹) = A := by
    intro c
    constructor
    · intro hc
      have hrc : repCount A c = A.card := (Finset.mem_filter.mp hc).2
      have hfil : A.filter (fun a => c * a⁻¹ ∈ A) = A := by
        refine Finset.eq_of_subset_of_card_le (Finset.filter_subset _ _) ?_
        unfold repCount at hrc; omega
      have hsub : A.image (fun a => c * a⁻¹) ⊆ A := by
        intro b hb
        obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hb
        have hmem : a ∈ A.filter (fun a => c * a⁻¹ ∈ A) := by rw [hfil]; exact ha
        exact (Finset.mem_filter.mp hmem).2
      have hinj : Function.Injective (fun a : G => c * a⁻¹) := by
        intro a b hab
        simpa using hab
      have hcardim : (A.image (fun a => c * a⁻¹)).card = A.card :=
        Finset.card_image_of_injective _ hinj
      exact Finset.eq_of_subset_of_card_le hsub (le_of_eq hcardim.symm)
    · intro himg
      simp only [hSdef, Finset.mem_filter, Finset.mem_univ, true_and]
      have hfil : A.filter (fun a => c * a⁻¹ ∈ A) = A := by
        refine Finset.filter_true_of_mem fun a ha => ?_
        rw [← himg]
        exact Finset.mem_image_of_mem _ ha
      unfold repCount
      rw [hfil]
  obtain ⟨c₀, hc₀⟩ : S.Nonempty := Finset.card_pos.mp (by omega)
  have hc₀' : A.image (fun a => c₀ * a⁻¹) = A := (hmemS c₀).mp hc₀
  -- the stabiliser is in bijection with `S`
  have hHcard : (Finset.univ.filter (fun g : G => g ∈ stab A)).card = S.card := by
    refine Finset.card_nbij' (fun g => g * c₀) (fun c => c * c₀⁻¹) ?_ ?_ ?_ ?_
    · intro g hg
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at hg
      have hgs : A.image (fun a => g * a) = A := mem_stab_iff.mp hg.2
      have : A.image (fun a => g * c₀ * a⁻¹) = A := by
        have hcomp : (fun a : G => g * c₀ * a⁻¹)
            = (fun b : G => g * b) ∘ (fun a : G => c₀ * a⁻¹) := by
          funext a; simp [mul_assoc]
        rw [hcomp, ← Finset.image_image, hc₀', hgs]
      simpa [hmemS] using this
    · intro c hc
      have hcS : c ∈ S := Finset.mem_coe.mp hc
      have hcs : A.image (fun a => c * a⁻¹) = A := (hmemS c).mp hcS
      have : A.image (fun a => c * c₀⁻¹ * a) = A := by
        have hcomp : (fun a : G => c * c₀⁻¹ * a) ∘ (fun a : G => c₀ * a⁻¹)
            = fun a : G => c * a⁻¹ := by
          funext a
          simp only [Function.comp_apply]
          rw [← mul_assoc, mul_assoc c c₀⁻¹ c₀, inv_mul_cancel, mul_one]
        conv_lhs => rw [← hc₀']
        rw [Finset.image_image, hcomp]
        exact hcs
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and]
      exact mem_stab_iff.mpr this
    · intro g _; simp
    · intro c _; simp
  have hHnat : Nat.card (stab A) = A.card := by
    rw [Nat.card_eq_fintype_card, Fintype.card_subtype, hHcard, hScard]
  have hindex : (stab A).index = 2 := by
    have h := Subgroup.card_mul_index (stab A)
    rw [hHnat, Nat.card_eq_fintype_card] at h
    have h2 : A.card * (stab A).index = A.card * 2 := by rw [h, ← hcard]; ring
    exact Nat.eq_of_mul_eq_mul_left hApos h2
  obtain ⟨x, hx⟩ : A.Nonempty := Finset.card_pos.mp hApos
  refine ⟨stab A, x, hindex, ?_⟩
  -- the support is the coset `x · stab A`
  have hsub : (Finset.univ.filter (fun g : G => g ∈ stab A)).image (fun g => x * g) ⊆ A := by
    intro b hb
    obtain ⟨g, hg, rfl⟩ := Finset.mem_image.mp hb
    have hgs : A.image (fun a => g * a) = A := mem_stab_iff.mp (Finset.mem_filter.mp hg).2
    have hgx : g * x ∈ A := by rw [← hgs]; exact Finset.mem_image_of_mem _ hx
    rwa [mul_comm] at hgx
  have hcards : ((Finset.univ.filter (fun g : G => g ∈ stab A)).image (fun g => x * g)).card
      = A.card := by
    rw [Finset.card_image_of_injective _ (mul_right_injective x), hHcard, hScard]
  have heqset : (Finset.univ.filter (fun g : G => g ∈ stab A)).image (fun g => x * g) = A :=
    Finset.eq_of_subset_of_card_le hsub (le_of_eq hcards.symm)
  intro a
  constructor
  · intro ha
    rw [← heqset] at ha
    obtain ⟨g, hg, rfl⟩ := Finset.mem_image.mp ha
    have hgs : g ∈ stab A := (Finset.mem_filter.mp hg).2
    simpa using hgs
  · intro ha
    have hmem : (x⁻¹ * a) * x ∈ A := by
      rw [← mem_stab_iff.mp ha]
      exact Finset.mem_image_of_mem _ hx
    have hid : (x⁻¹ * a) * x = a := by
      rw [mul_comm x⁻¹ a, mul_assoc, inv_mul_cancel, mul_one]
    rwa [hid] at hmem

/-- **The maximisers of the OR dial among deterministic profiles are exactly the
quadratic-character kernel cosets.** -/
theorem binary_max_iff_coset (A : Finset G) :
    orInfo (binProfile A) = orCap
      ↔ ∃ (K : Subgroup G) (x : G), K.index = 2 ∧ ∀ a : G, a ∈ A ↔ x⁻¹ * a ∈ K := by
  constructor
  · exact coset_of_binary_max A
  · rintro ⟨K, x, hK, hA⟩
    have hprof : binProfile A = fun a => subgroupProfile K (x⁻¹ * a) := by
      funext a
      unfold binProfile subgroupProfile
      by_cases h1 : a ∈ A
      · have h2 : x⁻¹ * a ∈ K := (hA a).mp h1
        simp [h1, h2]
      · have h2 : x⁻¹ * a ∉ K := fun hm => h1 ((hA a).mpr hm)
        simp [h1, h2]
    rw [hprof]
    exact orInfo_coset_index_two K hK x

/-! ## Every maximiser is deterministic -/

variable {s : G → ℝ}

omit [DecidableEq G] in
/-- If a class `c` attains the upper window bound `f(c) = μ`, then the profile is
"absorbing" along `c`: `s(a) s(c a⁻¹) = s(a)` for every class `a`. -/
lemma pointwise_of_noFork_eq_mean (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) {c : G}
    (hc : noFork s c = avg s) (a : G) : s a * s (c * a⁻¹) = s a := by
  have hF0 : ∀ b : G, 0 ≤ s b - s b * s (c * b⁻¹) := by
    intro b; nlinarith [hs0 b, hs1 (c * b⁻¹), hs0 (c * b⁻¹)]
  have havg : avg (fun b => s b - s b * s (c * b⁻¹)) = avg s - noFork s c := by
    have h1 : (fun b : G => s b - s b * s (c * b⁻¹))
        = fun b => s b + (0 + (-1) * (s b * s (c * b⁻¹))) := by funext b; ring
    rw [h1, avg_add, avg_affine]
    unfold noFork
    ring
  rw [hc, sub_self] at havg
  have := eq_zero_of_avg_eq_zero hF0 havg a
  linarith

omit [DecidableEq G] in
/-- Some class has a positive no-fork probability as soon as the mean rate is positive. -/
lemma exists_noFork_ne_zero (hpos : 0 < avg s) : ∃ c : G, noFork s c ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  have h : avg (noFork s) = 0 := by
    have : noFork s = fun _ : G => (0:ℝ) := funext hcon
    rw [this, avg_const]
  rw [avg_noFork] at h
  nlinarith

omit [DecidableEq G] in
/-- **Third rigidity theorem: maximisers are deterministic.**  A class-rate profile that
attains the cap takes only the values `0` and `1`; there is no genuinely probabilistic
maximiser. -/
theorem binary_of_max (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1)
    (heq : orInfo s = orCap) (a : G) : s a = 0 ∨ s a = 1 := by
  have hhalf : avg s = 1/2 := mean_eq_half_of_orInfo_eq_orCap hs0 hs1 heq
  obtain ⟨c, hc⟩ := exists_noFork_ne_zero (s := s) (by rw [hhalf]; norm_num)
  have hcm : noFork s c = avg s := by
    rcases noFork_eq_zero_or_half_of_max hs0 hs1 heq c with h | h
    · exact absurd h hc
    · rw [h, hhalf]
  have hkey := pointwise_of_noFork_eq_mean hs0 hs1 hcm
  by_cases ha : s a = 0
  · exact Or.inl ha
  · right
    have h1 : s (c * a⁻¹) = 1 := by
      have hmul : s a * s (c * a⁻¹) = s a * 1 := by rw [mul_one]; exact hkey a
      exact mul_left_cancel₀ ha hmul
    have h2 := hkey (c * a⁻¹)
    rw [h1, one_mul] at h2
    have harg : c * (c * a⁻¹)⁻¹ = a := by
      rw [mul_inv_rev, inv_inv, ← mul_assoc, mul_comm c a, mul_assoc, mul_inv_cancel, mul_one]
    rw [harg] at h2
    exact h2

omit [DecidableEq G] in
/-- **The complete variational principle.**  A class-rate profile attains the global cap
`orCap = g(2)` if and only if it is the indicator of a coset of an index-two subgroup:
the maximisers of the semiprime OR dial are *exactly* the quadratic-character kernels and
their complements. -/
theorem max_iff_coset_indicator (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) :
    orInfo s = orCap
      ↔ ∃ (K : Subgroup G) (x : G), K.index = 2 ∧ s = fun a => subgroupProfile K (x⁻¹ * a) := by
  classical
  constructor
  · intro heq
    set A : Finset G := Finset.univ.filter (fun a => s a = 1) with hAdef
    have hsA : s = binProfile A := by
      funext a
      unfold binProfile
      rcases binary_of_max hs0 hs1 heq a with h | h
      · have hnm : a ∉ A := by
          simp only [hAdef, Finset.mem_filter, Finset.mem_univ, true_and]
          rw [h]; norm_num
        rw [if_neg hnm, h]
      · have hm : a ∈ A := by
          simp only [hAdef, Finset.mem_filter, Finset.mem_univ, true_and]
          exact h
        rw [if_pos hm, h]
    rw [hsA] at heq ⊢
    obtain ⟨K, x, hK, hA⟩ := (binary_max_iff_coset A).mp heq
    refine ⟨K, x, hK, ?_⟩
    funext a
    unfold binProfile subgroupProfile
    by_cases h1 : a ∈ A
    · rw [if_pos h1, if_pos ((hA a).mp h1)]
    · rw [if_neg h1, if_neg (fun hm => h1 ((hA a).mpr hm))]
  · rintro ⟨K, x, hK, rfl⟩
    exact orInfo_coset_index_two K hK x

omit [DecidableEq G] in
/-- Kernels of index other than two are strictly below the cap: the order-`n` law is
strictly maximised at `n = 2`. -/
theorem orInfo_subgroupProfile_lt_orCap (K : Subgroup G) (h : K.index ≠ 2) :
    orInfo (subgroupProfile K) < orCap := by
  refine orInfo_lt_orCap_of_mean_ne_half (subgroupProfile_nonneg K) (subgroupProfile_le_one K) ?_
  rw [avg_subgroupProfile]
  intro hcon
  have hidx : 0 < K.index := Nat.pos_of_ne_zero Subgroup.index_ne_zero_of_finite
  have hR : (0:ℝ) < (K.index : ℝ) := by exact_mod_cast hidx
  have h2 : (K.index : ℝ) = 2 := by field_simp at hcon; linarith
  exact h (by exact_mod_cast h2)

omit [DecidableEq G] in
/-- **An arithmetic obstruction.**  A class group of odd order carries no quadratic
character, hence its OR dial never reaches the cap: the supremum `g(2)` is unattainable
there. -/
theorem no_max_of_odd_card (hodd : Odd (Fintype.card G)) (hs0 : ∀ a, 0 ≤ s a)
    (hs1 : ∀ a, s a ≤ 1) : orInfo s ≠ orCap := by
  intro heq
  obtain ⟨K, _, hK, _⟩ := (max_iff_coset_indicator hs0 hs1).mp heq
  have hdvd : K.index ∣ Fintype.card G := by
    refine ⟨Nat.card K, ?_⟩
    rw [← Nat.card_eq_fintype_card, ← Subgroup.card_mul_index K, mul_comm]
  rw [hK] at hdvd
  exact (Nat.not_even_iff_odd.mpr hodd) (even_iff_two_dvd.mpr hdvd)


end ORDial