import Mathlib

/-!
# Tropical Cryptocurrency II: the exact recession cone of a min-plus digest fiber

This file continues the min-plus ("tropical") hash analysis begun in the catalogue
file `Algebra/TropicalCryptocurrency/Hash.lean`, where the one-key hash
`tsha h m = min i (m i + h i)` was inverted and a *single* collision direction was
produced for two keys in dimension `≥ 3`.

Here we work with a full `r`-component digest

`digest A m i = min over j of (m j + A i j)`,

for a key family `A : Fin r → Fin k → ℝ`, and we determine the **collision cone**

`collisionCone A m = {v | ∀ s ≥ 0, digest A (m + s • v) = digest A m}`,

i.e. the recession cone of the polyhedral cell of the digest fiber containing `m`.

Main results.

* `finrank_span_collisionCone_ge` : for *every* key family and *every* message the
  span of the collision cone has dimension at least `k - r`.  This upgrades the
  single collision ray of the catalogue file to a full `(k-r)`-dimensional cone.
* `collisionCone_eq_of_strictMinimizer` : if each digest component has a *unique*
  minimizing coordinate `p i` (a generic situation) then the collision cone is
  *exactly* the set of nonnegative vectors vanishing on the coordinates `p i`.
* `finrank_span_collisionCone_eq` : consequently, if moreover `p` is injective,
  the span of the collision cone has dimension **exactly** `k - r`.
  This is the "exact recession dimension" conjecture, proved.
* `strictMinimizer_stable` : the genericity hypothesis is stable under small
  perturbations of the key family and of the message (openness of the good set),
  and `exists_strictMinimizer_injective` shows the good set is nonempty whenever
  `r ≤ k`, so the exactness theorem is not vacuous.

-- !-- Lab Notes -- !--
Hypothesis: the fiber of an `r`-component min-plus digest through a message `m`
carries a recession cone of dimension exactly `k - r` for generic data, the lower
bound holding universally.
Experiment: selecting one minimizer `p i` per component and increasing only
coordinates outside `range p` gives a `(k - |range p|)`-dimensional orthant inside
the fiber; conversely, with unique minimizers, moving a minimizing coordinate at
all (up or down) or decreasing any coordinate changes some component, which pins
the cone down to `{v ≥ 0, v (p i) = 0}`.
Analysis: the dimension count is a rank-nullity computation for the restriction
map `v ↦ v ∘ p`, which is surjective exactly when `p` is injective; injectivity of
`p` (distinct minimizers) is what makes `k - r` sharp, and non-injective `p` gives
strictly larger cones, so "generic" cannot be dropped.
Critique: the `r = 0` case must be excluded from the exact statement (an empty
digest has the whole space as collision cone, not just the nonnegative orthant),
and the upper bound genuinely requires *strict* minimizers: with ties the cone can
be larger.  Both boundaries are recorded below.
-- !-- end Lab Notes -- !--
-/

noncomputable section

namespace TropicalRecession

open Finset

variable {k r : ℕ} [Nonempty (Fin k)]

/-! ## The min-plus digest -/

/-- The `r`-component min-plus digest of a message `m : Fin k → ℝ` under the key
family `A`.  For `r = 1` this is the catalogue hash `tsha`. -/
def digest (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) (i : Fin r) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty fun j => m j + A i j

lemma digest_le (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) (i : Fin r) (j : Fin k) :
    digest A m i ≤ m j + A i j :=
  Finset.inf'_le _ (Finset.mem_univ j)

lemma le_digest {A : Fin r → Fin k → ℝ} {m : Fin k → ℝ} {i : Fin r} {c : ℝ}
    (h : ∀ j, c ≤ m j + A i j) : c ≤ digest A m i :=
  Finset.le_inf' _ _ fun j _ => h j

lemma exists_argmin (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) (i : Fin r) :
    ∃ j, m j + A i j = digest A m i := by
  obtain ⟨j, -, hj⟩ := Finset.exists_mem_eq_inf' (Finset.univ_nonempty (α := Fin k))
    fun j => m j + A i j
  exact ⟨j, hj.symm⟩

/-- Raising coordinates never lowers the digest, and if some coordinate attaining
the minimum is left untouched the digest is unchanged. -/
lemma digest_add_eq (A : Fin r → Fin k → ℝ) (m t : Fin k → ℝ) (ht : ∀ j, 0 ≤ t j)
    (i : Fin r) {j₀ : Fin k} (hact : m j₀ + A i j₀ = digest A m i) (h0 : t j₀ = 0) :
    digest A (m + t) i = digest A m i := by
  refine le_antisymm ?_ (le_digest fun j => ?_)
  · have h := digest_le A (m + t) i j₀
    simpa [Pi.add_apply, h0, hact] using h
  · have h1 := digest_le A m i j
    have h2 := ht j
    simp only [Pi.add_apply]
    linarith

/-! ## Collision supports -/

/-- `S` is a *collision support* at `m` when every nonnegative displacement
supported inside `S` leaves the whole digest unchanged. -/
def IsCollisionSupport (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) (S : Finset (Fin k)) : Prop :=
  ∀ t : Fin k → ℝ, (∀ j, 0 ≤ t j) → (∀ j ∉ S, t j = 0) → digest A (m + t) = digest A m

/-- The cone of nonnegative vectors supported in `S`. -/
def coneOn (S : Finset (Fin k)) : Set (Fin k → ℝ) :=
  {v | (∀ j, 0 ≤ v j) ∧ ∀ j ∉ S, v j = 0}

/-- The collision cone at `m`: directions along which the whole ray stays in the
digest fiber.  This is the recession cone of the fiber cell containing `m`. -/
def collisionCone (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) : Set (Fin k → ℝ) :=
  {v | ∀ s : ℝ, 0 ≤ s → digest A (m + s • v) = digest A m}

lemma coneOn_subset_collisionCone {A : Fin r → Fin k → ℝ} {m : Fin k → ℝ}
    {S : Finset (Fin k)} (hS : IsCollisionSupport A m S) :
    coneOn S ⊆ collisionCone A m := by
  rintro v ⟨hv0, hvS⟩ s hs
  exact hS (s • v) (fun j => mul_nonneg hs (hv0 j)) fun j hj => by
    simp [Pi.smul_apply, hvS j hj]

/-! ## The universal lower bound `k - r` -/

/-- Choosing one minimizing coordinate per digest component leaves at least
`k - r` coordinates free: an explicit collision support of size `≥ k - r`. -/
theorem exists_collisionSupport (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    ∃ S : Finset (Fin k), k - r ≤ S.card ∧ IsCollisionSupport A m S := by
  choose p hp using exists_argmin A m
  refine ⟨Finset.univ \ Finset.image p Finset.univ, ?_, ?_⟩
  · have h1 : (Finset.image p Finset.univ).card ≤ r := by
      calc (Finset.image p Finset.univ).card ≤ (Finset.univ : Finset (Fin r)).card :=
        Finset.card_image_le
      _ = r := by simp
    have h2 : (Finset.univ \ Finset.image p Finset.univ).card
        = k - (Finset.image p Finset.univ).card := by
      rw [← Finset.compl_eq_univ_sdiff, Finset.card_compl]
      simp
    omega
  · intro t ht htS
    funext i
    refine digest_add_eq A m t ht i (hp i) (htS (p i) ?_)
    simp

/-! ## Coordinate subspaces and their dimensions -/

/-- The coordinate subspace of all vectors supported inside `S`, realised as the
kernel of the restriction map to the complement of `S`. -/
def suppSub (S : Finset (Fin k)) : Submodule ℝ (Fin k → ℝ) :=
  LinearMap.ker (LinearMap.funLeft ℝ ℝ (fun j : {j : Fin k // j ∉ S} => (j : Fin k)))

omit [Nonempty (Fin k)] in
lemma mem_suppSub {S : Finset (Fin k)} {v : Fin k → ℝ} :
    v ∈ suppSub S ↔ ∀ j ∉ S, v j = 0 := by
  constructor
  · intro h j hj
    have h' := congrFun (LinearMap.mem_ker.mp h) ⟨j, hj⟩
    simpa using h'
  · intro h
    refine LinearMap.mem_ker.mpr ?_
    funext j
    simpa using h j.1 j.2

omit [Nonempty (Fin k)] in
/-- Rank-nullity for a restriction map along an injective reindexing. -/
lemma finrank_ker_funLeft {ι : Type} [Fintype ι] (f : ι → Fin k)
    (hf : Function.Injective f) :
    Module.finrank ℝ (LinearMap.ker (LinearMap.funLeft ℝ ℝ f)) = k - Fintype.card ι := by
  have hsurj : Function.Surjective (LinearMap.funLeft ℝ ℝ f) :=
    LinearMap.funLeft_surjective_of_injective ℝ ℝ f hf
  have hr : LinearMap.range (LinearMap.funLeft ℝ ℝ f) = ⊤ := LinearMap.range_eq_top.mpr hsurj
  have h := LinearMap.finrank_range_add_finrank_ker (LinearMap.funLeft ℝ ℝ f)
  rw [hr, finrank_top] at h
  rw [Module.finrank_fintype_fun_eq_card, Module.finrank_fintype_fun_eq_card,
    Fintype.card_fin] at h
  have hle : Fintype.card ι ≤ k := by
    simpa using Fintype.card_le_of_injective f hf
  omega

omit [Nonempty (Fin k)] in
lemma finrank_suppSub (S : Finset (Fin k)) :
    Module.finrank ℝ (suppSub S) = S.card := by
  have hcard : Fintype.card {j : Fin k // j ∉ S} = k - S.card := by
    have h : Fintype.card {j : Fin k // j ∈ Sᶜ} = (Sᶜ).card := Fintype.card_coe _
    rw [Finset.card_compl, Fintype.card_fin] at h
    rw [← h]
    exact Fintype.card_congr (Equiv.subtypeEquivRight (by simp))
  have h := finrank_ker_funLeft (k := k) (fun j : {j : Fin k // j ∉ S} => (j : Fin k))
    Subtype.val_injective
  have hle : S.card ≤ k := by simpa using Finset.card_le_univ S
  rw [hcard] at h
  rw [show suppSub S = LinearMap.ker
      (LinearMap.funLeft ℝ ℝ (fun j : {j : Fin k // j ∉ S} => (j : Fin k))) from rfl, h]
  omega

omit [Nonempty (Fin k)] in
/-- The nonnegative cone supported in `S` spans the full coordinate subspace, via
the positive-part/negative-part decomposition. -/
lemma span_coneOn (S : Finset (Fin k)) :
    Submodule.span ℝ (coneOn S) = suppSub S := by
  refine le_antisymm (Submodule.span_le.mpr ?_) ?_
  · rintro v ⟨-, hvS⟩
    exact mem_suppSub.mpr hvS
  · intro v hv
    have hvS := mem_suppSub.mp hv
    set vp : Fin k → ℝ := fun j => max (v j) 0 with hvp
    set vm : Fin k → ℝ := fun j => max (-(v j)) 0 with hvm
    have hvpmem : vp ∈ coneOn S := by
      refine ⟨fun j => le_max_right _ _, fun j hj => ?_⟩
      simp [hvp, hvS j hj]
    have hvmmem : vm ∈ coneOn S := by
      refine ⟨fun j => le_max_right _ _, fun j hj => ?_⟩
      simp [hvm, hvS j hj]
    have hsplit : v = vp - vm := by
      funext j
      simp only [hvp, hvm, Pi.sub_apply]
      rcases le_total (v j) 0 with h | h
      · rw [max_eq_right h, max_eq_left (by linarith)]; ring
      · rw [max_eq_left h, max_eq_right (by linarith)]; ring
    rw [hsplit]
    exact Submodule.sub_mem _ (Submodule.subset_span hvpmem) (Submodule.subset_span hvmmem)

/-- **Universal lower bound.**  For every key family and every message, the span of
the collision cone of the digest fiber has dimension at least `k - r`: the fiber
through `m` contains a `(k-r)`-dimensional cone of collisions. -/
theorem finrank_span_collisionCone_ge (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    k - r ≤ Module.finrank ℝ (Submodule.span ℝ (collisionCone A m)) := by
  obtain ⟨S, hScard, hS⟩ := exists_collisionSupport A m
  have hmono : suppSub S ≤ Submodule.span ℝ (collisionCone A m) := by
    rw [← span_coneOn S]
    exact Submodule.span_mono (coneOn_subset_collisionCone hS)
  have hfr := Submodule.finrank_mono hmono
  rw [finrank_suppSub] at hfr
  omega

/-! ## Genericity: unique minimizers -/

/-- `p i` is the *unique* minimizing coordinate of digest component `i` at `m`. -/
def IsStrictMinimizer (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) (p : Fin r → Fin k) : Prop :=
  ∀ i j, j ≠ p i → digest A m i < m j + A i j

lemma IsStrictMinimizer.active {A : Fin r → Fin k → ℝ} {m : Fin k → ℝ} {p : Fin r → Fin k}
    (h : IsStrictMinimizer A m p) (i : Fin r) : m (p i) + A i (p i) = digest A m i := by
  obtain ⟨j, hj⟩ := exists_argmin A m i
  by_cases hjp : j = p i
  · rwa [hjp] at hj
  · exact absurd hj (by have := h i j hjp; linarith)

/-- **Exact collision cone under genericity.**  If every digest component has a
unique minimizing coordinate `p i`, the recession cone of the fiber cell through
`m` is exactly the set of nonnegative vectors vanishing at all the `p i`. -/
theorem collisionCone_eq_of_strictMinimizer [Nonempty (Fin r)] (A : Fin r → Fin k → ℝ)
    (m : Fin k → ℝ) (p : Fin r → Fin k) (h : IsStrictMinimizer A m p) :
    collisionCone A m = {v | (∀ j, 0 ≤ v j) ∧ ∀ i, v (p i) = 0} := by
  ext v
  constructor
  · intro hv
    constructor
    · -- no coordinate may decrease: the ray would eventually drop the minimum
      intro j₀
      by_contra hneg
      push_neg at hneg
      set i : Fin r := Classical.arbitrary (Fin r)
      set c : ℝ := digest A m i with hc
      have hcle : c ≤ m j₀ + A i j₀ := digest_le A m i j₀
      have hvne : v j₀ ≠ 0 := ne_of_lt hneg
      set s : ℝ := (m j₀ + A i j₀ - c + 1) / (-(v j₀)) with hs
      have hsnonneg : 0 ≤ s := by
        rw [hs]
        apply div_nonneg <;> linarith
      have hsv : s * v j₀ = c - m j₀ - A i j₀ - 1 := by
        rw [hs, div_mul_eq_mul_div, div_eq_iff (neg_ne_zero.mpr hvne)]
        ring
      have hle := digest_le A (m + s • v) i j₀
      have heq := congrFun (hv s hsnonneg) i
      simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul] at hle
      rw [heq] at hle
      rw [hsv] at hle
      linarith
    · -- minimizing coordinates are frozen
      intro i
      set c : ℝ := digest A m i with hc
      have hact : m (p i) + A i (p i) = c := h.active i
      have hge : 0 ≤ v (p i) := by
        have hle := digest_le A (m + (1:ℝ) • v) i (p i)
        have heq := congrFun (hv 1 zero_le_one) i
        simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul, one_mul] at hle
        rw [heq] at hle
        linarith
      by_contra hne
      have hpos : 0 < v (p i) := lt_of_le_of_ne hge (Ne.symm hne)
      -- uniform gap at the non-minimizing coordinates
      set g : ℝ := Finset.univ.inf' Finset.univ_nonempty
        (fun j => if j = p i then (1:ℝ) else min 1 (m j + A i j - c)) with hg
      have hgpos : 0 < g := by
        rw [hg]
        refine (Finset.lt_inf'_iff _).mpr ?_
        intro j _
        by_cases hj : j = p i
        · simp [hj]
        · have hlt := h i j hj
          simp only [hj, if_false]
          exact lt_min zero_lt_one (by linarith)
      have hgle : ∀ j, j ≠ p i → g ≤ m j + A i j - c := by
        intro j hj
        have hb := Finset.inf'_le (f := fun j => if j = p i then (1:ℝ)
          else min 1 (m j + A i j - c)) (Finset.mem_univ j)
        simp only [hj, if_false] at hb
        exact le_trans hb (min_le_right _ _)
      set M : ℝ := 1 + Finset.univ.sup' Finset.univ_nonempty (fun j => |v j|) with hM
      have hMpos : 0 < M := by
        have hnn : (0:ℝ) ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => |v j|) := by
          obtain ⟨j⟩ := ‹Nonempty (Fin k)›
          exact le_trans (abs_nonneg (v j))
            (Finset.le_sup' (f := fun j => |v j|) (Finset.mem_univ j))
        rw [hM]; linarith
      have hMle : ∀ j, |v j| ≤ M := by
        intro j
        have hb : |v j| ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => |v j|) :=
          Finset.le_sup' (f := fun j => |v j|) (Finset.mem_univ j)
        rw [hM]; linarith
      set s : ℝ := g / (2 * M) with hs
      have hspos : 0 < s := div_pos hgpos (by linarith)
      have hsM : s * M = g / 2 := by
        rw [hs]
        field_simp
      set d : ℝ := min (g / 2) (s * v (p i)) with hd
      have hdpos : 0 < d := lt_min (by linarith) (mul_pos hspos hpos)
      have hbound : ∀ j, c + d ≤ (m + s • v) j + A i j := by
        intro j
        simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul]
        by_cases hj : j = p i
        · subst hj
          have hdle : d ≤ s * v (p i) := min_le_right _ _
          linarith
        · have h1 : g ≤ m j + A i j - c := hgle j hj
          have h2 : |s * v j| ≤ s * M := by
            rw [abs_mul, abs_of_pos hspos]
            exact mul_le_mul_of_nonneg_left (hMle j) (le_of_lt hspos)
          have h3 : -(s * M) ≤ s * v j := neg_le_of_abs_le h2
          have h4 : d ≤ g / 2 := min_le_left _ _
          linarith
      have hfin := le_digest (A := A) (m := m + s • v) (i := i) hbound
      rw [congrFun (hv s (le_of_lt hspos)) i] at hfin
      linarith
  · rintro ⟨hv0, hvp⟩ s hs
    funext i
    refine digest_add_eq A m (s • v) (fun j => mul_nonneg hs (hv0 j)) i (h.active i) ?_
    simp [hvp i]

/-- **Exact recession dimension.**  If the digest components have unique and
pairwise distinct minimizing coordinates at `m`, the span of the collision cone has
dimension exactly `k - r`. -/
theorem finrank_span_collisionCone_eq [Nonempty (Fin r)] (A : Fin r → Fin k → ℝ)
    (m : Fin k → ℝ) (p : Fin r → Fin k) (hinj : Function.Injective p)
    (h : IsStrictMinimizer A m p) :
    Module.finrank ℝ (Submodule.span ℝ (collisionCone A m)) = k - r := by
  have hset : collisionCone A m = coneOn (Finset.univ \ Finset.image p Finset.univ) := by
    rw [collisionCone_eq_of_strictMinimizer A m p h]
    ext v
    constructor
    · rintro ⟨hv0, hvp⟩
      refine ⟨hv0, fun j hj => ?_⟩
      simp only [Finset.mem_sdiff, Finset.mem_univ, true_and, not_not,
        Finset.mem_image] at hj
      obtain ⟨i, -, rfl⟩ := hj
      exact hvp i
    · rintro ⟨hv0, hvS⟩
      refine ⟨hv0, fun i => hvS (p i) ?_⟩
      simp
  have hcard : (Finset.univ \ Finset.image p Finset.univ).card = k - r := by
    have himg : (Finset.image p Finset.univ).card = r := by
      rw [Finset.card_image_of_injective _ hinj]
      simp
    rw [← Finset.compl_eq_univ_sdiff, Finset.card_compl, himg]
    simp
  rw [hset, span_coneOn, finrank_suppSub, hcard]

/-! ## Non-vacuity and stability of the genericity hypothesis -/

/-- The genericity hypothesis is satisfiable whenever `r ≤ k`: an explicit key
family whose components have unique and pairwise distinct minimizers. -/
theorem exists_strictMinimizer_injective (hrk : r ≤ k) :
    ∃ (A : Fin r → Fin k → ℝ) (p : Fin r → Fin k), Function.Injective p ∧
      IsStrictMinimizer A (0 : Fin k → ℝ) p := by
  refine ⟨fun i j => if j = Fin.castLE hrk i then 0 else 1, fun i => Fin.castLE hrk i,
    Fin.castLE_injective hrk, ?_⟩
  intro i j hj
  have hd : digest (fun i j => if j = Fin.castLE hrk i then (0:ℝ) else 1) 0 i = 0 := by
    refine le_antisymm ?_ (le_digest fun j => ?_)
    · have h := digest_le (fun i j => if j = Fin.castLE hrk i then (0:ℝ) else 1) 0 i
        (Fin.castLE hrk i)
      simpa using h
    · by_cases h : j = Fin.castLE hrk i <;> simp [h]
  rw [hd]
  simp [hj]

/-- **Openness of the generic locus.**  If the minimizers are strict with a uniform
gap `g`, then every key family and message within `g/4` (coordinatewise) still has
the same strict minimizers.  Hence the hypothesis of
`finrank_span_collisionCone_eq` holds on an open set of data. -/
theorem strictMinimizer_stable (A A' : Fin r → Fin k → ℝ) (m m' : Fin k → ℝ)
    (p : Fin r → Fin k) {g : ℝ}
    (hgap : ∀ i j, j ≠ p i → m (p i) + A i (p i) + g ≤ m j + A i j)
    (hA : ∀ i j, |A' i j - A i j| < g / 4) (hm : ∀ j, |m' j - m j| < g / 4) :
    IsStrictMinimizer A' m' p := by
  intro i j hj
  have h1 : digest A' m' i ≤ m' (p i) + A' i (p i) := digest_le A' m' i (p i)
  have h2 : |m' (p i) - m (p i)| < g / 4 := hm (p i)
  have h3 : |A' i (p i) - A i (p i)| < g / 4 := hA i (p i)
  have h4 : |m' j - m j| < g / 4 := hm j
  have h5 : |A' i j - A i j| < g / 4 := hA i j
  have h6 := hgap i j hj
  have e2 := abs_lt.mp h2
  have e3 := abs_lt.mp h3
  have e4 := abs_lt.mp h4
  have e5 := abs_lt.mp h5
  linarith [e2.1, e2.2, e3.1, e3.2, e4.1, e4.2, e5.1, e5.2]

/-! ## Sharpness: strictness of the minimizers cannot be dropped -/

/-- With a tie among the minimizing coordinates the collision cone is genuinely
larger than the generic prediction: for the zero key with `k = 2`, `r = 1`, the
collision cone spans the whole plane, of dimension `2 > k - r = 1`.
So `finrank_span_collisionCone_eq` really needs the strict-minimizer hypothesis. -/
theorem finrank_span_collisionCone_tie :
    Module.finrank ℝ (Submodule.span ℝ (collisionCone (0 : Fin 1 → Fin 2 → ℝ) 0)) = 2 := by
  have hd : ∀ i : Fin 1, digest (0 : Fin 1 → Fin 2 → ℝ) 0 i = 0 := by
    intro i
    refine le_antisymm ?_ (le_digest fun j => ?_)
    · have h := digest_le (0 : Fin 1 → Fin 2 → ℝ) 0 i 0
      simpa using h
    · simp
  have hmem : ∀ q : Fin 2, (fun j => if j = q then (1:ℝ) else 0) ∈
      collisionCone (0 : Fin 1 → Fin 2 → ℝ) 0 := by
    intro q s hs
    funext i
    obtain ⟨q', hq'⟩ : ∃ q' : Fin 2, q' ≠ q := ⟨if q = 0 then 1 else 0, by fin_cases q <;> simp⟩
    refine digest_add_eq (0 : Fin 1 → Fin 2 → ℝ) 0 (s • fun j => if j = q then (1:ℝ) else 0)
      (fun j => ?_) i (j₀ := q') ?_ ?_
    · dsimp only [Pi.smul_apply, smul_eq_mul]
      by_cases h : j = q <;> simp [h, hs]
    · simpa using (hd i).symm
    · simp [hq']
  have htop : Submodule.span ℝ (collisionCone (0 : Fin 1 → Fin 2 → ℝ) 0) = ⊤ := by
    refine Submodule.eq_top_iff'.mpr fun v => ?_
    have hv : v = v 0 • (fun j => if j = 0 then (1:ℝ) else 0)
        + v 1 • (fun j => if j = 1 then (1:ℝ) else 0) := by
      funext j
      fin_cases j <;> simp
    rw [hv]
    exact Submodule.add_mem _
      (Submodule.smul_mem _ _ (Submodule.subset_span (hmem 0)))
      (Submodule.smul_mem _ _ (Submodule.subset_span (hmem 1)))
  rw [htop, finrank_top, Module.finrank_fintype_fun_eq_card, Fintype.card_fin]

end TropicalRecession