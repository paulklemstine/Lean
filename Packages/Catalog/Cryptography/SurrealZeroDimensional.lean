import Catalog.Cryptography.SurrealTotallySeparated

/-!
# The surreal line is zero-dimensional

Continuing `Catalog.Cryptography.SurrealTotallySeparated`, we upgrade total separation to
**zero-dimensionality**: every neighbourhood of every surreal contains a *clopen*
neighbourhood of that point.  The clopen neighbourhoods are the "archimedean monads"

`monad x d = {z | ∀ n, z - x < d * powHalf n} ∩ {z | ∀ n, x - z < d * powHalf n}`,

the sets of surreals whose distance to `x` is infinitesimal relative to the scale `d`.
Each monad is clopen (both halves are clopen by the lower/upper-set criteria) and is
contained in `Ioo (x - d) (x + d)`, which makes the monads a neighbourhood basis of clopen
sets at `x`.

As a consequence there is **no nonconstant continuous map from any preconnected space**
(e.g. `ℝ`) into the surreal line: the surreal line is totally path-disconnected.

Combined with `Catalog.Cryptography.SurrealLocalCharacter` this pins down the local
structure of the surreal order topology: at every point it has a basis of clopen sets, but
never a small one.
-/

open SetTheory PGame Filter Set Topology

namespace Surreal

/-! ## The mirror half of an archimedean cut -/

/-- The set of surreals lying below `x` by an amount infinitesimal relative to `d`
(together with everything above `x`). -/
def biggerPart (x d : Surreal.{u}) : Set Surreal.{u} :=
  {z | ∀ n : ℕ, x - z < d * powHalf n}

theorem mem_biggerPart_self {x d : Surreal.{u}} (hd : 0 < d) : x ∈ biggerPart x d := by
  intro n
  simpa using mul_powHalf_pos hd n

theorem biggerPart_isUpperSet {x d : Surreal.{u}} ⦃a b : Surreal.{u}⦄ (hab : a ≤ b)
    (ha : a ∈ biggerPart x d) : b ∈ biggerPart x d := fun n =>
  lt_of_le_of_lt (by linarith [hab]) (ha n)

theorem biggerPart_no_min {x d : Surreal.{u}} (hd : 0 < d) (a : Surreal.{u})
    (ha : a ∈ biggerPart x d) : ∃ b ∈ biggerPart x d, b < a := by
  rcases lt_or_ge a x with hax | hxa
  · -- `a` is strictly below `x`: double the (positive) distance `x - a`.
    refine ⟨x - (x - a) - (x - a), fun n => ?_, by linarith⟩
    have h1 : x - a < d * powHalf (n + 1) := ha (n + 1)
    have h2 := double_mul_powHalf_succ (d := d) n
    have hrw : x - (x - (x - a) - (x - a)) = (x - a) + (x - a) := by ring
    rw [hrw]
    linarith
  · -- `x ≤ a`: step down to `x - e` for `e` infinitesimal relative to `d`.
    obtain ⟨e, he0, he⟩ := exists_pos_lt_mul_powHalf hd
    refine ⟨x - e, fun n => ?_, by linarith⟩
    have hrw : x - (x - e) = e := by ring
    rw [hrw]
    exact he n

theorem compl_biggerPart_isLowerSet {x d : Surreal.{u}} ⦃a b : Surreal.{u}⦄ (hab : a ≤ b)
    (hb : b ∈ (biggerPart x d)ᶜ) : a ∈ (biggerPart x d)ᶜ := by
  simp only [biggerPart, mem_compl_iff, mem_setOf_eq, not_forall, not_lt] at hb ⊢
  obtain ⟨n, hn⟩ := hb
  exact ⟨n, by linarith⟩

theorem compl_biggerPart_no_max {x d : Surreal.{u}} (hd : 0 < d) (a : Surreal.{u})
    (ha : a ∈ (biggerPart x d)ᶜ) : ∃ b ∈ (biggerPart x d)ᶜ, a < b := by
  simp only [biggerPart, mem_compl_iff, mem_setOf_eq, not_forall, not_lt] at ha ⊢
  obtain ⟨n, hn⟩ := ha
  refine ⟨x - d * powHalf (n + 1), ⟨n + 1, by simp⟩, ?_⟩
  have hlt : d * powHalf (n + 1) < d * powHalf n := mul_powHalf_succ_lt hd n
  linarith

theorem isOpen_biggerPart {x d : Surreal.{u}} (hd : 0 < d) : IsOpen (biggerPart x d) :=
  isOpen_of_isUpperSet_of_no_min biggerPart_isUpperSet (biggerPart_no_min hd)

theorem isOpen_compl_biggerPart {x d : Surreal.{u}} (hd : 0 < d) :
    IsOpen (biggerPart x d)ᶜ :=
  isOpen_of_isLowerSet_of_no_max compl_biggerPart_isLowerSet (compl_biggerPart_no_max hd)

theorem isClopen_biggerPart {x d : Surreal.{u}} (hd : 0 < d) : IsClopen (biggerPart x d) :=
  ⟨isOpen_compl_iff.1 (isOpen_compl_biggerPart hd), isOpen_biggerPart hd⟩

/-! ## Archimedean monads: a clopen neighbourhood basis -/

/-- The archimedean monad of `x` at scale `d`: the surreals whose distance to `x` is
infinitesimal relative to `d`. -/
def monad (x d : Surreal.{u}) : Set Surreal.{u} := smallerPart x d ∩ biggerPart x d

theorem isClopen_monad {x d : Surreal.{u}} (hd : 0 < d) : IsClopen (monad x d) :=
  (isClopen_smallerPart hd).inter (isClopen_biggerPart hd)

theorem mem_monad_self {x d : Surreal.{u}} (hd : 0 < d) : x ∈ monad x d :=
  ⟨mem_smallerPart_self hd, mem_biggerPart_self hd⟩

theorem monad_subset_Ioo {x d : Surreal.{u}} : monad x d ⊆ Ioo (x - d) (x + d) := by
  rintro z ⟨hz1, hz2⟩
  have h1 := hz1 0
  have h2 := hz2 0
  rw [powHalf_zero, mul_one] at h1 h2
  exact ⟨by linarith, by linarith⟩

/-- **The surreal line is zero-dimensional**: every neighbourhood of every point contains a
clopen neighbourhood of that point. -/
theorem exists_isClopen_subset_of_mem_nhds (c : Surreal.{u}) {s : Set Surreal.{u}}
    (hs : s ∈ 𝓝 c) : ∃ t, IsClopen t ∧ c ∈ t ∧ t ⊆ s := by
  obtain ⟨l, r, ⟨hl, hr⟩, hsub⟩ := mem_nhds_iff_exists_Ioo_subset.1 hs
  set d : Surreal.{u} := min (c - l) (r - c) with hdef
  have hd : 0 < d := lt_min (by linarith) (by linarith)
  refine ⟨monad c d, isClopen_monad hd, mem_monad_self hd, ?_⟩
  refine subset_trans monad_subset_Ioo (subset_trans ?_ hsub)
  apply Ioo_subset_Ioo
  · have : d ≤ c - l := min_le_left _ _
    linarith
  · have : d ≤ r - c := min_le_right _ _
    linarith

/-- The clopen monads form a neighbourhood basis at every point. -/
theorem hasBasis_nhds_clopen (c : Surreal.{u}) :
    ∀ s ∈ 𝓝 c, ∃ d : Surreal.{u}, 0 < d ∧ monad c d ⊆ s := by
  intro s hs
  obtain ⟨l, r, ⟨hl, hr⟩, hsub⟩ := mem_nhds_iff_exists_Ioo_subset.1 hs
  refine ⟨min (c - l) (r - c), lt_min (by linarith) (by linarith), ?_⟩
  refine subset_trans monad_subset_Ioo (subset_trans ?_ hsub)
  apply Ioo_subset_Ioo
  · have : min (c - l) (r - c) ≤ c - l := min_le_left _ _
    linarith
  · have : min (c - l) (r - c) ≤ r - c := min_le_right _ _
    linarith

/-! ## Monads are the archimedean classes: they partition the line -/

theorem mem_monad_iff {c d z : Surreal.{u}} :
    z ∈ monad c d ↔ (∀ n : ℕ, z - c < d * powHalf n) ∧ ∀ n : ℕ, c - z < d * powHalf n :=
  Iff.rfl

/-- Being in the same monad is a symmetric relation. -/
theorem monad_symm {c d z : Surreal.{u}} (h : z ∈ monad c d) : c ∈ monad z d :=
  ⟨fun n => h.2 n, fun n => h.1 n⟩

/-- Being in the same monad is transitive: the monad of a point of `monad c d` is contained
in `monad c d` (via `d * powHalf (n+1) + d * powHalf (n+1) = d * powHalf n`). -/
theorem monad_subset_of_mem {c c' d : Surreal.{u}} (h : c' ∈ monad c d) :
    monad c' d ⊆ monad c d := by
  rintro z ⟨hz1, hz2⟩
  constructor
  · intro n
    have h1 := hz1 (n + 1)
    have h2 := h.1 (n + 1)
    have h3 := double_mul_powHalf_succ (d := d) n
    linarith
  · intro n
    have h1 := hz2 (n + 1)
    have h2 := h.2 (n + 1)
    have h3 := double_mul_powHalf_succ (d := d) n
    linarith

theorem monad_eq_of_mem {c c' d : Surreal.{u}} (h : c' ∈ monad c d) :
    monad c' d = monad c d :=
  subset_antisymm (monad_subset_of_mem h) (monad_subset_of_mem (monad_symm h))

/-- **At each scale the monads partition the surreal line**: two monads of the same scale
are either equal or disjoint. -/
theorem monad_eq_or_disjoint (c c' d : Surreal.{u}) :
    monad c d = monad c' d ∨ Disjoint (monad c d) (monad c' d) := by
  by_cases h : (monad c d ∩ monad c' d).Nonempty
  · obtain ⟨w, hw, hw'⟩ := h
    left
    rw [← monad_eq_of_mem hw, ← monad_eq_of_mem hw']
  · right
    rw [Set.not_nonempty_iff_eq_empty] at h
    exact Set.disjoint_iff_inter_eq_empty.2 h

/-! ## No nonconstant continuous images of connected spaces -/

/-- **The surreal line is totally path-disconnected**: every continuous map from a
preconnected space to `Surreal` is constant.  In particular there are no nonconstant
continuous curves `ℝ → Surreal`. -/
theorem eq_of_continuous_of_preconnected {X : Type*} [TopologicalSpace X] [PreconnectedSpace X]
    (f : X → Surreal.{u}) (hf : Continuous f) (a b : X) : f a = f b := by
  have himg : IsPreconnected (f '' univ) :=
    (isPreconnected_univ (α := X)).image f hf.continuousOn
  have hpre : IsPreconnected (range f) := by rwa [image_univ] at himg
  have hsub : (range f).Subsingleton := hpre.subsingleton
  exact hsub (mem_range_self a) (mem_range_self b)

/-- There is no nonconstant continuous curve from the reals into the surreals. -/
theorem eq_of_continuous_real (f : ℝ → Surreal.{u}) (hf : Continuous f) (a b : ℝ) :
    f a = f b :=
  eq_of_continuous_of_preconnected f hf a b

end Surreal