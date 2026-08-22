/-
# Phase-Augmented Clock-and-Switch Worlds: the Preorder Filtration Lemma

`Combinatorics.CWorldFiltration` proved that a finite preorder is a surjective bounded
morphic image of a clock-and-switch world `CWorld (Fin n) (Fin m)` **iff** it is rooted,
directed *and antisymmetric* (`representable_iff`), the antisymmetry being forced by
`BddMorphism.antisymm_image`.  So the literal mission statement — *every* finite rooted
directed **preorder** is such an image — is false, the two-element cluster being the
minimal obstruction (`not_representable_cluster`).

This file repairs the statement by enlarging the source class with an *indiscrete*
factor, and shows the repair is sharp.

A **phase-augmented world** `CWorldC A B c` is a clock-and-switch world carrying an
extra `phase : Fin c` which is **invisible to the accessibility relation**: `w ≤ v`
still means `w.base ≤ v.base`.  Thus `CWorldC A B c` is the product of the poset
`CWorld A B` with the `c`-element *indiscrete* preorder, and it is a genuine preorder,
not a partial order, as soon as `c ≥ 2`.

## Main results

* `CWorldC.card_eq` — `|CWorldC (Fin n) (Fin m) c| = n * 2 ^ m * c`.
* `CWorldC.forgetPhase` — forgetting the phase is a surjective bounded morphism onto
  `CWorld A B`, the third catalogued projection alongside `forgetSwitches` and
  `cardChain`.
* `representableC_of_clusters_le` — **the filtration lemma for preorders, sharp
  form**: if every cluster of the finite nonempty preorder `P` has at most `c`
  elements, then `P` is a surjective bounded morphic image of
  `CWorldC (Fin 1) (Fin m) c` with `m = |P/≈|`.  The morphism factors as
  "greedy climb on the antisymmetrisation, then read the phase as a choice inside the
  cluster".
* `representableC_of_rooted_directed` — the mission statement, now true: every finite
  rooted directed preorder is a bounded morphic image of some `CWorldC (Fin n) (Fin m) c`.
* `cluster_card_le` — the converse bound: in any bounded morphic image of
  `CWorldC (Fin n) (Fin m) c` every cluster has at most `c` elements.  Hence the value
  of `c` in the theorem above cannot be lowered below the maximal cluster size.
* `representableC_iff` — the resulting characterisation: a finite nonempty preorder is
  phase-representable iff it is rooted and directed.  Antisymmetry has disappeared.
* `clusterSize_eq_min_phases` — combining the two: the least usable number of phases is
  exactly the maximal cluster size.

## Lab notes

* Attempt 1 (rejected): put the *product* order on `Fin c`.  Then `CWorldC` is again a
  poset and `antisymm_image` still applies — no gain.  Indiscreteness is the whole
  point: the phase must be a coordinate the order cannot see.
* Attempt 2 (rejected): quotient `CWorld` by an equivalence.  Quotients of posets by
  order-compatible equivalences are still posets on the nose; one needs a *product*
  with an indiscrete factor, not a quotient.
* The positive proof reuses `representable_of_rooted_directed` verbatim on the
  antisymmetrisation `P/≈`; all new content is the "phase = choice of cluster
  element" layer, whose back condition needs the fibre-surjectivity of `pick`.
* The converse `cluster_card_le` is a maximality argument in the *base* poset: choose
  a base-maximal preimage `u` of the cluster; the back condition then realises every
  cluster element already at base `u`, so the cluster injects into `Fin c`.
-/

import Combinatorics.CWorldFiltration

namespace CWorldFiltration

open Function

attribute [local instance] Classical.propDecidable

/-! ## Part A — Phase-augmented worlds -/

/-- A **phase-augmented clock-and-switch world**: a clock-and-switch world together with
a phase in `Fin c` that the accessibility relation ignores. -/
structure CWorldC (A B : Type*) (c : ℕ) where
  /-- the underlying clock-and-switch world -/
  base : CWorld A B
  /-- the invisible phase -/
  phase : Fin c

namespace CWorldC

variable {A B : Type*} {c : ℕ}

/-- Accessibility ignores the phase entirely. -/
instance instPreorder [Preorder A] : Preorder (CWorldC A B c) where
  le w v := w.base ≤ v.base
  le_refl _ := le_rfl
  le_trans _ _ _ h₁ h₂ := le_trans h₁ h₂

theorem le_def [Preorder A] {w v : CWorldC A B c} : w ≤ v ↔ w.base ≤ v.base := Iff.rfl

/-- `CWorldC A B c` is the product of `CWorld A B` with `Fin c`. -/
def equivProd : CWorldC A B c ≃ CWorld A B × Fin c where
  toFun w := (w.base, w.phase)
  invFun p := ⟨p.1, p.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

instance instFintype [Fintype A] [Fintype B] [DecidableEq B] : Fintype (CWorldC A B c) :=
  Fintype.ofEquiv _ equivProd.symm

theorem card_eq (n m c : ℕ) :
    Fintype.card (CWorldC (Fin n) (Fin m) c) = n * 2 ^ m * c := by
  rw [Fintype.card_congr (equivProd (A := Fin n) (B := Fin m) (c := c))]
  rw [Fintype.card_prod, CWorld.card_eq, Fintype.card_fin]

/-- Phase-augmented worlds are rooted (as soon as there is at least one phase). -/
theorem isRooted [Preorder A] [OrderBot A] (h : 0 < c) :
    ∃ w₀ : CWorldC A B c, ∀ w, w₀ ≤ w :=
  ⟨⟨⟨⊥, fun _ => false⟩, ⟨0, h⟩⟩, fun w => ⟨bot_le, fun b hb => by simp at hb⟩⟩

/-- Phase-augmented worlds are directed. -/
theorem directed [SemilatticeSup A] (w v : CWorldC A B c) : ∃ u, w ≤ u ∧ v ≤ u := by
  obtain ⟨u, hu₁, hu₂⟩ := CWorld.directed w.base v.base
  exact ⟨⟨u, w.phase⟩, hu₁, hu₂⟩

/-- With two or more phases the order is genuinely a preorder: `⟨b, 0⟩` and `⟨b, 1⟩`
form a cluster. -/
theorem not_antisymm [Preorder A] [Nonempty A] (h : 2 ≤ c) :
    ∃ w v : CWorldC A B c, w ≤ v ∧ v ≤ w ∧ w ≠ v := by
  refine ⟨⟨⟨Classical.arbitrary A, fun _ => false⟩, ⟨0, by omega⟩⟩,
    ⟨⟨Classical.arbitrary A, fun _ => false⟩, ⟨1, by omega⟩⟩,
    CWorldC.le_def.mpr le_rfl, CWorldC.le_def.mpr le_rfl, ?_⟩
  intro hcon
  have : (⟨0, by omega⟩ : Fin c) = ⟨1, by omega⟩ := congrArg CWorldC.phase hcon
  simpa using congrArg Fin.val this

/-- **Forgetting the phase** is a bounded morphism onto the clock-and-switch world:
the third structural projection, alongside `forgetSwitches` and `cardChain`. -/
def forgetPhase (A B : Type*) [Preorder A] (c : ℕ) :
    BddMorphism (CWorldC A B c) (CWorld A B) where
  toFun w := w.base
  forth _ _ h := h
  back w u h := ⟨⟨u, w.phase⟩, h, rfl⟩

theorem forgetPhase_surjective (A B : Type*) [Preorder A] {c : ℕ} (h : 0 < c) :
    Surjective (forgetPhase A B c).toFun :=
  fun u => ⟨⟨u, ⟨0, h⟩⟩, rfl⟩

end CWorldC

/-! ## Part B — Phase-representability -/

/-- `P` is **phase-representable** if it is a surjective bounded morphic image of some
finite phase-augmented world. -/
def RepresentableC (P : Type*) [Preorder P] : Prop :=
  ∃ (n m c : ℕ) (f : BddMorphism (CWorldC (Fin n) (Fin m) c) P), Surjective f.toFun

/-- The cluster of `p₀`: all points mutually accessible with `p₀`. -/
noncomputable def clusterOf {P : Type*} [Preorder P] [Fintype P] (p₀ : P) : Finset P :=
  Finset.univ.filter fun p => p ≤ p₀ ∧ p₀ ≤ p

theorem mem_clusterOf {P : Type*} [Preorder P] [Fintype P] {p₀ p : P} :
    p ∈ clusterOf p₀ ↔ p ≤ p₀ ∧ p₀ ≤ p := by
  simp [clusterOf]

/-- **The filtration lemma for preorders, sharp form.**  A finite nonempty rooted
directed preorder all of whose clusters have at most `c` elements is a surjective
bounded morphic image of `CWorldC (Fin 1) (Fin m) c`, where `m` is the number of
clusters.  The morphism first performs the greedy climb of
`representable_of_rooted_directed` on the antisymmetrisation, then uses the phase to
choose a point inside the reached cluster. -/
theorem representableC_of_clusters_le (P : Type) [Preorder P] [Fintype P] [Nonempty P]
    {c : ℕ} (hroot : ∃ r : P, ∀ p, r ≤ p) (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z)
    (hcl : ∀ p₀ : P, (clusterOf p₀).card ≤ c) :
    ∃ (m : ℕ) (f : BddMorphism (CWorldC (Fin 1) (Fin m) c) P), Surjective f.toFun := by
  classical
  -- the antisymmetrisation `Q = P/≈`
  set Q := Antisymmetrization P (· ≤ ·) with hQ
  set pr : P → Q := toAntisymmetrization (α := P) (· ≤ ·) with hpr
  set rep : Q → P := ofAntisymmetrization (α := P) (· ≤ ·) with hrep
  have hpr_rep : ∀ q : Q, pr (rep q) = q := fun q =>
    toAntisymmetrization_ofAntisymmetrization (α := P) (· ≤ ·) q
  have hprsurj : Surjective pr := fun q => ⟨rep q, hpr_rep q⟩
  have hle : ∀ {a b : P}, pr a ≤ pr b ↔ a ≤ b := fun {a b} =>
    toAntisymmetrization_le_toAntisymmetrization_iff (α := P)
  haveI : Fintype Q := Fintype.ofSurjective pr hprsurj
  haveI : Nonempty Q := ⟨pr (Classical.arbitrary P)⟩
  -- `Q` is a finite rooted directed poset
  obtain ⟨r, hr⟩ := hroot
  have hQroot : ∃ s : Q, ∀ q, s ≤ q := by
    refine ⟨pr r, fun q => ?_⟩
    obtain ⟨p, rfl⟩ := hprsurj q
    exact hle.mpr (hr p)
  have hQdir : ∀ x y : Q, ∃ z, x ≤ z ∧ y ≤ z := by
    intro x y
    obtain ⟨a, rfl⟩ := hprsurj x
    obtain ⟨b, rfl⟩ := hprsurj y
    obtain ⟨z, hz₁, hz₂⟩ := hdir a b
    exact ⟨pr z, hle.mpr hz₁, hle.mpr hz₂⟩
  obtain ⟨f, hf⟩ := representable_of_rooted_directed Q hQroot hQdir
  -- fibres of `pr` are exactly the clusters of `P`
  have hfib : ∀ (q : Q) (p : P), pr p = q ↔ p ∈ clusterOf (rep q) := by
    intro q p
    rw [mem_clusterOf]
    constructor
    · intro h
      exact ⟨hle.mp (by rw [h, hpr_rep]), hle.mp (by rw [h, hpr_rep])⟩
    · rintro ⟨h₁, h₂⟩
      rw [← hpr_rep q]
      exact le_antisymm (hle.mpr h₁) (hle.mpr h₂)
  set F : Q → Finset P := fun q => clusterOf (rep q) with hF
  have hFcard : ∀ q, Fintype.card ↥(F q) ≤ Fintype.card (Fin c) := by
    intro q
    rw [Fintype.card_coe, Fintype.card_fin]
    exact hcl _
  -- an injection of every cluster into the phase space
  have hemb : ∀ q : Q, Nonempty (↥(F q) ↪ Fin c) := fun q =>
    Function.Embedding.nonempty_of_card_le (hFcard q)
  set emb : ∀ q : Q, ↥(F q) ↪ Fin c := fun q => Classical.choice (hemb q) with hembdef
  -- the phase-to-point choice function
  set pick : Q → Fin c → P := fun q j =>
    if h : ∃ x : ↥(F q), emb q x = j then (Classical.choose h).1 else rep q with hpick
  have hpick_pr : ∀ (q : Q) (j : Fin c), pr (pick q j) = q := by
    intro q j
    by_cases h : ∃ x : ↥(F q), emb q x = j
    · have hx := (Classical.choose h).2
      rw [hpick]
      simp only [dif_pos h]
      exact (hfib q _).mpr hx
    · rw [hpick]
      simp only [dif_neg h]
      exact hpr_rep q
  have hpick_surj : ∀ p : P, ∃ j : Fin c, pick (pr p) j = p := by
    intro p
    have hmem : p ∈ F (pr p) := (hfib (pr p) p).mp rfl
    refine ⟨emb (pr p) ⟨p, hmem⟩, ?_⟩
    have h : ∃ x : ↥(F (pr p)), emb (pr p) x = emb (pr p) ⟨p, hmem⟩ := ⟨⟨p, hmem⟩, rfl⟩
    rw [hpick]
    simp only [dif_pos h]
    have := Classical.choose_spec h
    have hx : Classical.choose h = (⟨p, hmem⟩ : ↥(F (pr p))) := (emb (pr p)).injective this
    rw [hx]
  -- assemble the morphism
  refine ⟨Fintype.card Q, ⟨fun w => pick (f.toFun w.base) w.phase, ?_, ?_⟩, ?_⟩
  · -- forth
    intro x y h
    refine hle.mp ?_
    rw [hpick_pr, hpick_pr]
    exact f.forth h
  · -- back
    intro x p h
    have hstep : f.toFun x.base ≤ pr p := by
      have := hle.mpr h
      rwa [hpick_pr] at this
    obtain ⟨u, hu, hfu⟩ := f.back x.base (pr p) hstep
    obtain ⟨j, hj⟩ := hpick_surj p
    refine ⟨⟨u, j⟩, hu, ?_⟩
    show pick (f.toFun u) j = p
    rw [hfu, hj]
  · -- surjectivity
    intro p
    obtain ⟨w, hw⟩ := hf (pr p)
    obtain ⟨j, hj⟩ := hpick_surj p
    refine ⟨⟨w, j⟩, ?_⟩
    show pick (f.toFun w) j = p
    rw [hw, hj]

/-- **The mission statement, repaired.**  Every finite rooted directed *preorder* — no
antisymmetry assumed — is a surjective bounded morphic image of a phase-augmented
clock-and-switch world. -/
theorem representableC_of_rooted_directed (P : Type) [Preorder P] [Fintype P] [Nonempty P]
    (hroot : ∃ r : P, ∀ p, r ≤ p) (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) :
    RepresentableC P := by
  obtain ⟨m, f, hf⟩ :=
    representableC_of_clusters_le P (c := Fintype.card P) hroot hdir (fun p₀ => by
      have := Finset.card_filter_le (Finset.univ : Finset P) fun p => p ≤ p₀ ∧ p₀ ≤ p
      simpa [clusterOf] using this)
  exact ⟨1, m, Fintype.card P, f, hf⟩

/-! ## Part C — The converse: phases bound cluster size -/

/-- **Cluster bound for images.**  If `P` is a surjective bounded morphic image of
`CWorldC (Fin n) (Fin m) c`, then every cluster of `P` has at most `c` elements:
pick a base-maximal preimage of the cluster, and the back condition realises the whole
cluster at that single base, hence injectively inside `Fin c`. -/
theorem cluster_card_le {n m c : ℕ} {P : Type} [Preorder P] [Fintype P]
    (f : BddMorphism (CWorldC (Fin n) (Fin m) c) P) (hf : Surjective f.toFun) (p₀ : P) :
    (clusterOf p₀).card ≤ c := by
  classical
  -- the set of bases of preimages of the cluster
  set S : Set (CWorld (Fin n) (Fin m)) :=
    {u | ∃ j : Fin c, f.toFun ⟨u, j⟩ ∈ clusterOf p₀} with hS
  have hne : S.Nonempty := by
    obtain ⟨x, hx⟩ := hf p₀
    refine ⟨x.base, x.phase, ?_⟩
    have hxx : (⟨x.base, x.phase⟩ : CWorldC (Fin n) (Fin m) c) = x := rfl
    rw [hxx, hx, mem_clusterOf]
    exact ⟨le_rfl, le_rfl⟩
  obtain ⟨u, hu⟩ := Set.Finite.exists_maximal (Set.toFinite S) hne
  have key : ∀ v, u ≤ v → v ∈ S → v = u := fun v huv hvS => le_antisymm (hu.2 hvS huv) huv
  -- every cluster element is already realised at base `u`
  have hreach : ∀ p ∈ clusterOf p₀, ∃ j : Fin c, f.toFun ⟨u, j⟩ = p := by
    intro p hp
    obtain ⟨j₀, hj₀⟩ := hu.1
    rw [mem_clusterOf] at hp
    rw [mem_clusterOf] at hj₀
    have hstep : f.toFun ⟨u, j₀⟩ ≤ p := le_trans hj₀.1 hp.2
    obtain ⟨y, hy, hyp⟩ := f.back ⟨u, j₀⟩ p hstep
    obtain ⟨yb, yp⟩ := y
    have hyS : yb ∈ S := ⟨yp, by rw [hyp, mem_clusterOf]; exact hp⟩
    have hbu : yb = u := key yb (CWorldC.le_def.mp hy) hyS
    subst hbu
    exact ⟨yp, hyp⟩
  -- hence the cluster is covered by `c` points
  have hsub : clusterOf p₀ ⊆ Finset.image (fun j : Fin c => f.toFun ⟨u, j⟩) Finset.univ := by
    intro p hp
    obtain ⟨j, hj⟩ := hreach p hp
    exact Finset.mem_image.mpr ⟨j, Finset.mem_univ j, hj⟩
  calc (clusterOf p₀).card
      ≤ (Finset.image (fun j : Fin c => f.toFun ⟨u, j⟩) Finset.univ).card :=
        Finset.card_le_card hsub
    _ ≤ (Finset.univ : Finset (Fin c)).card := Finset.card_image_le
    _ = c := by simp

/-- **Characterisation of phase-representability.**  A finite nonempty preorder is a
surjective bounded morphic image of a phase-augmented clock-and-switch world **iff** it
is rooted and directed.  Compare `representable_iff`, where antisymmetry was a third,
unavoidable condition. -/
theorem representableC_iff (P : Type) [Preorder P] [Fintype P] [Nonempty P] :
    RepresentableC P ↔ ((∃ r : P, ∀ p, r ≤ p) ∧ (∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z)) := by
  constructor
  · rintro ⟨n, m, c, f, hf⟩
    have hc : 0 < c := by
      rcases Nat.eq_zero_or_pos c with rfl | h
      · obtain ⟨w, -⟩ := hf (Classical.arbitrary P)
        exact w.phase.elim0
      · exact h
    have hn : 0 < n := by
      rcases Nat.eq_zero_or_pos n with rfl | h
      · obtain ⟨w, -⟩ := hf (Classical.arbitrary P)
        exact w.base.clock.elim0
      · exact h
    obtain ⟨k, rfl⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
    exact ⟨f.isRooted_image hf (CWorldC.isRooted hc), f.directed_image hf CWorldC.directed⟩
  · rintro ⟨hroot, hdir⟩
    exact representableC_of_rooted_directed P hroot hdir

/-- **Sharpness of the phase count.**  For a finite nonempty rooted directed preorder,
the numbers `c` for which `P` is an image of some `CWorldC (Fin 1) (Fin m) c` are
exactly those bounding all cluster sizes.  So the least admissible phase count is the
maximal cluster size, and the theorem `representableC_of_clusters_le` is optimal. -/
theorem clusterSize_eq_min_phases (P : Type) [Preorder P] [Fintype P] [Nonempty P]
    (hroot : ∃ r : P, ∀ p, r ≤ p) (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) (c : ℕ) :
    (∃ (m : ℕ) (f : BddMorphism (CWorldC (Fin 1) (Fin m) c) P), Surjective f.toFun) ↔
      ∀ p₀ : P, (clusterOf p₀).card ≤ c := by
  constructor
  · rintro ⟨m, f, hf⟩ p₀
    exact cluster_card_le f hf p₀
  · intro hcl
    exact representableC_of_clusters_le P hroot hdir hcl

/-- The two-element cluster, which `not_representable_cluster` excludes from the poset
theory, *is* phase-representable — with two phases. -/
theorem representableC_cluster : RepresentableC Cluster :=
  representableC_of_rooted_directed Cluster cluster_isRooted cluster_directed

/-- Every ordinary representable poset is phase-representable: run one phase. -/
theorem representableC_of_representable (P : Type) [Preorder P] (h : Representable P) :
    RepresentableC P := by
  obtain ⟨n, m, f, hf⟩ := h
  refine ⟨n, m, 1, f.comp (CWorldC.forgetPhase (Fin n) (Fin m) 1), ?_⟩
  intro p
  obtain ⟨w, hw⟩ := hf p
  exact ⟨⟨w, 0⟩, hw⟩

end CWorldFiltration