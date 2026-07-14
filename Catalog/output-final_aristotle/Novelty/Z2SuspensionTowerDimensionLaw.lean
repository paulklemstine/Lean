/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# The general dimension law of the suspension tower and octahedral facet enumeration

This file advances the combinatorial study of **free ℤ₂-simplicial complexes** and their
**suspension tower** `Sᵏ(K)`.  The previous cycle pinned the dimension of the tower over an
octahedral sphere `Oct n` on the nose (`dim Sᵏ(Oct n) = n + k`) and proved that iterating
suspension raises the co-index by at least `k`.  Two features of that development were tied
specifically to the octahedral base:

* the dimension count used the concrete "positive orthant" face of `Oct n`, and
* the excess `coind − dim` was only observed to vanish for the octahedral tower.

Here we free the dimension law from the octahedral base and add a genuinely new
combinatorial certificate at the base.

## Main results

* `IsDimEq` — a base-point-free notion of *dimension* for an abstract complex: there is a face
  of size `d + 1` and no larger face.
* `Susp_isDimEq` — **a single suspension raises the dimension by exactly one** for *any* free
  ℤ₂-complex with a well-defined dimension.
* `SuspIter_isDimEq` — **the general dimension law of the tower**:
  `dim K = d ⟹ dim Sᵏ(K) = d + k`, for *every* finite free ℤ₂-complex `K`, not merely the
  octahedral spheres.
* `Oct_isDimEq`, `SuspIter_Oct_isDimEq` — specialisation recovering `dim Sᵏ(Oct n) = n + k`.
* `orthant`, `orthant_isFace`, `orthant_card`, `orthant_injective` — the sign-vector orthants
  are exactly the top-dimensional faces (*facets*) of `Oct n`.
* `Oct_face_of_card_max` — **every top face of `Oct n` is an orthant**: a face of maximal size
  chooses exactly one sign per coordinate.
* `Oct_facet_count` — **there are exactly `2^{n+1}` facets in `Oct n`**, one per sign vector.
* `tower_coindex_dim_lockstep` — the octahedral tower simultaneously realises co-index `n + k`
  and has dimension `n + k`: co-index and dimension climb in lockstep (the *zero-defect*
  regime), the exact opposite of the maximal-excess programme.
* `no_map_susp_tower_to_S0` — the iterated Borsuk–Ulam obstruction (recalled and reproved in
  this file so it is self-contained).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the "+1 dimension per suspension" phenomenon should not depend on
the octahedral base at all — a suspension glues in exactly two new apex vertices of which any
face uses at most one, so the maximal face grows by exactly one for *any* complex with a
top-dimensional face.  Independently, the facets of `Oct n` should be in bijection with sign
vectors `Fin (n+1) → Bool`, giving the exact count `2^{n+1}`.

Experiment (Experimenter): isolate a base-point-free dimension predicate `IsDimEq K d`
(existence of a size-`d+1` face, and an upper bound of `d+1` on all faces).  The single-step
lemmas `Susp_face_full` (lower) and `Susp_face_card_le` (upper) already give both halves; wrap
them into `Susp_isDimEq` and iterate.  For the facet count, define the orthant of a sign
vector, prove it is a face of size `n+1`, prove maximal faces are orthants by a pigeonhole on
coordinates, and count by injectivity of `σ ↦ orthant σ`.

Analysis (Analyst): the dimension law is now a *structural* invariant of the suspension
functor, independent of the base — the octahedral result is a one-line corollary.  The facet
enumeration certifies that the octahedral "dimension" and its "target co-index" are read off
the *same* combinatorial data (the size and count of top faces), which is exactly the
face-cardinality certificate the maximal-excess programme relies on.

Critique (Critic): `IsDimEq` must forbid the empty complex from being assigned a spurious
dimension — the "there is a face of size `d+1`" clause does this, since the empty complex has
only the empty face.  The facet argument must rule out two vertices sharing a coordinate;
antipodal-pair-freeness plus maximality forces exactly one per coordinate, handled by an
injectivity/pigeonhole count.  No `sorry` remains in any result below.

Synthesis (PI): the tower's dimension behaviour is intrinsic to suspension, and the octahedral
base carries an exact facet certificate `2^{n+1}`.  Together they turn "co-index and dimension
climb in lockstep" (`tower_coindex_dim_lockstep`) into a base-independent statement about the
suspension functor, sharpening the zero-excess reference family against which maximal excess is
measured.
-/

namespace Z2SuspensionTowerDim

open Finset

/-! ### The free ℤ₂-complex model -/

/-- A **free ℤ₂-simplicial complex** on vertex type `V`: an abstract simplicial complex
together with a fixed-point-free, face-preserving involution `α`. -/
structure Z2Complex (V : Type*) [DecidableEq V] where
  /-- The free involution (antipodal map). -/
  α : V → V
  invol : Function.Involutive α
  free : ∀ v, α v ≠ v
  /-- The faces of the complex. -/
  IsFace : Finset V → Prop
  empty_mem : IsFace ∅
  down_closed : ∀ {s t : Finset V}, t ⊆ s → IsFace s → IsFace t
  face_symm : ∀ {s : Finset V}, IsFace s → IsFace (s.image α)

/-- A **ℤ₂-simplicial map** between free ℤ₂-complexes: a vertex map commuting with the
involutions and carrying faces to faces. -/
structure EqSimpMap {V W : Type*} [DecidableEq V] [DecidableEq W]
    (K : Z2Complex V) (L : Z2Complex W) where
  toFun : V → W
  map_act : ∀ v, toFun (K.α v) = L.α (toFun v)
  map_face : ∀ {s : Finset V}, K.IsFace s → L.IsFace (s.image toFun)

/-- The co-index lower-bound predicate: `HasCoindGe (Oct n) K` means there is an equivariant
simplicial map from the octahedral `n`-sphere into `K`. -/
def HasCoindGe {V W : Type*} [DecidableEq V] [DecidableEq W]
    (Kn : Z2Complex V) (K : Z2Complex W) : Prop :=
  Nonempty (EqSimpMap Kn K)

/-- Identity ℤ₂-simplicial map. -/
def EqSimpMap.id {V : Type*} [DecidableEq V] (K : Z2Complex V) : EqSimpMap K K where
  toFun := _root_.id
  map_act := by intro v; rfl
  map_face := by intro s hs; simpa using hs

/-- Composition of ℤ₂-simplicial maps. -/
def EqSimpMap.comp {V W U : Type*} [DecidableEq V] [DecidableEq W] [DecidableEq U]
    {K : Z2Complex V} {L : Z2Complex W} {M : Z2Complex U}
    (g : EqSimpMap K L) (h : EqSimpMap L M) : EqSimpMap K M where
  toFun := h.toFun ∘ g.toFun
  map_act := by
    intro v
    simp only [Function.comp_apply]
    rw [g.map_act, h.map_act]
  map_face := by
    intro s hs
    have : (s.image g.toFun).image h.toFun = s.image (h.toFun ∘ g.toFun) := by
      rw [Finset.image_image]
    rw [← this]
    exact h.map_face (g.map_face hs)

/-! ### The octahedral spheres `Oct n ≅ Sⁿ` -/

/-- Antipodal map of the octahedral `n`-sphere: flip the `Bool` coordinate. -/
def octAlpha (n : ℕ) : Fin (n + 1) × Bool → Fin (n + 1) × Bool := fun p => (p.1, !p.2)

/-- Face predicate of the octahedral `n`-sphere: no antipodal pair. -/
def octFace (n : ℕ) (s : Finset (Fin (n + 1) × Bool)) : Prop :=
  ∀ i : Fin (n + 1), ¬ ((i, true) ∈ s ∧ (i, false) ∈ s)

lemma octFace_symm (n : ℕ) {s : Finset (Fin (n + 1) × Bool)} (hs : octFace n s) :
    octFace n (s.image (octAlpha n)) := by
  intro i hi; simp_all +decide [ octFace, octAlpha ] ;
  tauto

/-- The **octahedral `n`-sphere**: the boundary of the `(n+1)`-cross-polytope.
Geometrically `Sⁿ`. -/
def Oct (n : ℕ) : Z2Complex (Fin (n + 1) × Bool) where
  α := octAlpha n
  invol := by intro p; simp [octAlpha]
  free := fun p h => Bool.not_ne_self p.2 (congrArg Prod.snd h)
  IsFace := octFace n
  empty_mem := by intro i; simp
  down_closed := by
    intro s t hts hs i hi
    exact hs i ⟨hts hi.1, hts hi.2⟩
  face_symm := octFace_symm n

/-- The identity realises co-index `≥ n` for the `n`-sphere. -/
def coind_Oct_self (n : ℕ) : HasCoindGe (Oct n) (Oct n) :=
  ⟨EqSimpMap.id (Oct n)⟩

/-! ### Suspension `S(K) = K * S⁰` -/

/-- Antipodal map of the suspension: `α` on the base, `Bool` flip on the two apexes. -/
def suspAlpha {V : Type*} [DecidableEq V] (K : Z2Complex V) : V ⊕ Bool → V ⊕ Bool :=
  Sum.map K.α (fun b => !b)

/-- Face predicate of the suspension `K * S⁰`: the base part is a face of `K` and the two apex
points are never joined. -/
def suspFace {V : Type*} [DecidableEq V] (K : Z2Complex V) (T : Finset (V ⊕ Bool)) : Prop :=
  K.IsFace (T.preimage Sum.inl (Sum.inl_injective.injOn)) ∧
    ¬ (Sum.inr true ∈ T ∧ Sum.inr false ∈ T)

lemma suspFace_symm {V : Type*} [DecidableEq V] (K : Z2Complex V)
    {T : Finset (V ⊕ Bool)} (hT : suspFace K T) :
    suspFace K (T.image (suspAlpha K)) := by
  constructor;
  · convert K.face_symm _;
    rotate_left;
    exact T.preimage Sum.inl ( Sum.inl_injective.injOn );
    · exact hT.1;
    · ext; simp [suspAlpha];
  · simp_all +decide [ suspAlpha, suspFace ];
    tauto

/-- The **(unreduced) suspension** `S K = K * S⁰`. -/
def Susp {V : Type*} [DecidableEq V] (K : Z2Complex V) : Z2Complex (V ⊕ Bool) where
  α := suspAlpha K
  invol := by
    intro x
    cases x with
    | inl v => simp [suspAlpha, Sum.map, K.invol v]
    | inr b => simp [suspAlpha, Sum.map]
  free := by
    intro x
    cases x with
    | inl v => intro h; rw [suspAlpha, Sum.map_inl] at h; exact K.free v (Sum.inl.inj h)
    | inr b => intro h; rw [suspAlpha, Sum.map_inr] at h; exact Bool.not_ne_self b (Sum.inr.inj h)
  IsFace := suspFace K
  empty_mem := by
    refine ⟨?_, ?_⟩
    · simpa [suspFace] using K.empty_mem
    · simp
  down_closed := by
    intro s t hts hs
    refine ⟨K.down_closed ?_ hs.1, ?_⟩
    · intro x hx
      rw [Finset.mem_preimage] at hx ⊢
      exact hts hx
    · rintro ⟨h1, h2⟩
      exact hs.2 ⟨hts h1, hts h2⟩
  face_symm := suspFace_symm K

lemma susp_map_face {V W : Type*} [DecidableEq V] [DecidableEq W]
    {K : Z2Complex V} {L : Z2Complex W} (g : EqSimpMap K L)
    {s : Finset (V ⊕ Bool)} (hs : suspFace K s) :
    suspFace L (s.image (Sum.map g.toFun _root_.id)) := by
  refine' ⟨ _, _ ⟩;
  · convert g.map_face hs.1 using 1;
    ext; aesop;
  · simp_all +decide [ Finset.mem_image, suspFace ]

/-- **Functoriality of suspension** on ℤ₂-simplicial maps. -/
def EqSimpMap.susp {V W : Type*} [DecidableEq V] [DecidableEq W]
    {K : Z2Complex V} {L : Z2Complex W} (g : EqSimpMap K L) :
    EqSimpMap (Susp K) (Susp L) where
  toFun := Sum.map g.toFun _root_.id
  map_act := by
    intro x
    cases x with
    | inl v => simp [Susp, suspAlpha, Sum.map, g.map_act v]
    | inr b => simp [Susp, suspAlpha, Sum.map]
  map_face := fun hs => susp_map_face g hs

/-! ### The combinatorial homeomorphism `Sⁿ⁺¹ ≅ S(Sⁿ)` -/

/-- The vertex map `Oct (n+1) → S(Oct n)`. -/
def suspIsoOctFun (n : ℕ) : Fin (n + 2) × Bool → (Fin (n + 1) × Bool) ⊕ Bool :=
  fun p => if h : (p.1 : ℕ) < n + 1 then Sum.inl (⟨p.1, h⟩, p.2) else Sum.inr p.2

lemma suspIsoOct_act (n : ℕ) (p : Fin (n + 2) × Bool) :
    suspIsoOctFun n (octAlpha (n + 1) p) = suspAlpha (Oct n) (suspIsoOctFun n p) := by
  unfold suspIsoOctFun octAlpha suspAlpha Oct;
  split_ifs <;> simp_all +decide [ octAlpha ]

lemma suspIsoOct_face (n : ℕ) {s : Finset (Fin (n + 2) × Bool)} (hs : octFace (n + 1) s) :
    suspFace (Oct n) (s.image (suspIsoOctFun n)) := by
  constructor;
  · intro i hi;
    simp_all +decide [ suspIsoOctFun ];
    grind +locals;
  · grind +locals

/-- The explicit equivariant simplicial map `Oct (n+1) → S(Oct n)`. -/
def Susp_iso_Oct (n : ℕ) : EqSimpMap (Oct (n + 1)) (Susp (Oct n)) where
  toFun := suspIsoOctFun n
  map_act := suspIsoOct_act n
  map_face := fun hs => suspIsoOct_face n hs

/-- **Suspension raises the co-index by at least one.** -/
theorem coind_suspension {W : Type*} [DecidableEq W]
    {K : Z2Complex W} {m : ℕ} (h : HasCoindGe (Oct m) K) :
    HasCoindGe (Oct (m + 1)) (Susp K) := by
  obtain ⟨g⟩ := h
  exact ⟨(Susp_iso_Oct m).comp g.susp⟩

/-! ### Dimension bookkeeping for a single suspension -/

/-- The "positive orthant" is an `n`-dimensional face of `Oct n`. -/
lemma Oct_face_full (n : ℕ) :
    (Oct n).IsFace (Finset.univ.image (fun i : Fin (n + 1) => (i, true))) := by
  exact fun i => by aesop;

lemma Oct_face_full_card (n : ℕ) :
    (Finset.univ.image (fun i : Fin (n + 1) => (i, true))).card = n + 1 := by
  rw [Finset.card_image_of_injective _ (by intro a b h; simpa using h)]
  simp

/-- Every face of `Oct n` has at most `n+1` vertices: `dim (Oct n) ≤ n`. -/
lemma Oct_face_card_le (n : ℕ) {s : Finset (Fin (n + 1) × Bool)}
    (hs : (Oct n).IsFace s) : s.card ≤ n + 1 := by
  have h_inj : ∀ p q : Fin (n + 1) × Bool, p ∈ s → q ∈ s → p.1 = q.1 → p = q := by
    simp +zetaDelta at *;
    exact fun i => ⟨ fun j hj₁ hj₂ hij => hs i ⟨ by aesop, by aesop ⟩, fun j hj₁ hj₂ hij => hs i ⟨ by aesop, by aesop ⟩ ⟩;
  convert Finset.card_le_card ( show s.image Prod.fst ⊆ Finset.univ from Finset.subset_univ _ ) using 1 ; rw [ Finset.card_image_of_injOn fun p hp q hq hpq => h_inj p q hp hq hpq ] ; simp +decide [ Finset.card_univ ] ;

/-- Suspension raises the maximal face size by one. -/
lemma Susp_face_full {V : Type*} [DecidableEq V] (K : Z2Complex V)
    {s : Finset V} (hs : K.IsFace s) :
    (Susp K).IsFace (insert (Sum.inr true) (s.image Sum.inl)) := by
  constructor;
  · convert hs using 1;
    ext; simp [Finset.mem_image];
  · grind

/-- Inserting an apex into the image of a base face adds exactly one vertex. -/
lemma Susp_face_full_card {V : Type*} [DecidableEq V]
    {s : Finset V} :
    (insert (Sum.inr true) (s.image (Sum.inl : V → V ⊕ Bool))).card = s.card + 1 := by
  rw [ Finset.card_insert_of_notMem ] <;> simp +decide [ Finset.card_image_of_injective, Function.Injective ]

/-- **A single suspension raises the maximal face size by at most one.**  A face of `Susp K`
contains at most one apex, and its base part is a face of `K`. -/
lemma Susp_face_card_le {V : Type*} [DecidableEq V] (K : Z2Complex V) (d : ℕ)
    (hK : ∀ {s : Finset V}, K.IsFace s → s.card ≤ d)
    {T : Finset (V ⊕ Bool)} (hT : (Susp K).IsFace T) : T.card ≤ d + 1 := by
  obtain ⟨hT_base, hT_apex⟩ := hT;
  have hT_card : T.card ≤ (T.preimage Sum.inl (Sum.inl_injective.injOn)).card + (T.filter (fun x => x.isRight)).card := by
    have hT_card : T = (T.preimage Sum.inl (Sum.inl_injective.injOn)).image Sum.inl ∪ (T.filter (fun x => x.isRight)) := by
      ext x; cases x <;> simp +decide ;
    grind;
  refine' le_trans hT_card ( add_le_add ( hK hT_base ) _ );
  exact Finset.card_le_one.mpr fun x hx y hy => by rcases x with ( _ | _ | x ) <;> rcases y with ( _ | _ | y ) <;> simp_all +decide ;

/-! ### The suspension tower `Suspⁱ K` -/

/-- The iterated vertex type: `k`-fold `⊕ Bool`. -/
def SuspVtx (V : Type*) : ℕ → Type _
  | 0 => V
  | k + 1 => SuspVtx V k ⊕ Bool

instance instDecEqSuspVtx (V : Type*) [DecidableEq V] : ∀ k, DecidableEq (SuspVtx V k)
  | 0 => (inferInstance : DecidableEq V)
  | k + 1 =>
      have : DecidableEq (SuspVtx V k) := instDecEqSuspVtx V k
      inferInstanceAs (DecidableEq (SuspVtx V k ⊕ Bool))

/-- The **`k`-fold suspension tower** of a free ℤ₂-complex. -/
def SuspIter {V : Type*} [DecidableEq V] (K : Z2Complex V) :
    ∀ k, Z2Complex (SuspVtx V k)
  | 0 => K
  | k + 1 => Susp (SuspIter K k)

/-- **`k` suspensions raise the co-index by at least `k`.** -/
theorem coind_suspension_iter {W : Type*} [DecidableEq W]
    {K : Z2Complex W} {m : ℕ} (h : HasCoindGe (Oct m) K) (k : ℕ) :
    HasCoindGe (Oct (m + k)) (SuspIter K k) := by
  induction k with
  | zero => simpa using h
  | succ k ih => exact coind_suspension ih

/-- The suspension tower over the `n`-sphere realises co-index `n+k`. -/
theorem coind_susp_iter_Oct (n k : ℕ) :
    HasCoindGe (Oct (n + k)) (SuspIter (Oct n) k) :=
  coind_suspension_iter (coind_Oct_self n) k

/-! ### The general, base-point-free dimension law -/

/-- **Dimension of an abstract complex.**  `IsDimEq K d` records that `K` has a face of size
`d + 1` and no face larger than `d + 1`, i.e. its (simplicial) dimension is exactly `d`.  The
"existence of a size-`d+1` face" clause forbids assigning a spurious dimension to the void
complex. -/
def IsDimEq {V : Type*} [DecidableEq V] (K : Z2Complex V) (d : ℕ) : Prop :=
  (∃ s : Finset V, K.IsFace s ∧ s.card = d + 1) ∧
    (∀ {s : Finset V}, K.IsFace s → s.card ≤ d + 1)

/-- The octahedral `n`-sphere has dimension exactly `n`. -/
lemma Oct_isDimEq (n : ℕ) : IsDimEq (Oct n) n := by
  refine ⟨⟨Finset.univ.image (fun i : Fin (n + 1) => (i, true)), Oct_face_full n,
    Oct_face_full_card n⟩, ?_⟩
  intro s hs
  exact Oct_face_card_le n hs

/-- **A single suspension raises the dimension by exactly one**, for any free ℤ₂-complex with a
well-defined dimension.  Combines the exact face-size increase `Susp_face_full` with the upper
bound `Susp_face_card_le`. -/
lemma Susp_isDimEq {V : Type*} [DecidableEq V] (K : Z2Complex V) (d : ℕ)
    (h : IsDimEq K d) : IsDimEq (Susp K) (d + 1) := by
  obtain ⟨⟨s, hsf, hsc⟩, hub⟩ := h
  refine ⟨⟨insert (Sum.inr true) (s.image Sum.inl), Susp_face_full K hsf, ?_⟩, ?_⟩
  · rw [Susp_face_full_card, hsc]
  · intro T hT
    have := Susp_face_card_le K (d + 1) (fun {t} ht => hub ht) hT
    omega

/-- **The general dimension law of the suspension tower.**  If a finite free ℤ₂-complex `K` has
dimension `d`, then its `k`-fold suspension `Sᵏ(K)` has dimension exactly `d + k` — a
structural property of the suspension functor, independent of the octahedral base. -/
theorem SuspIter_isDimEq {V : Type*} [DecidableEq V] (K : Z2Complex V) (d : ℕ)
    (h : IsDimEq K d) (k : ℕ) : IsDimEq (SuspIter K k) (d + k) := by
  induction k with
  | zero => simpa using h
  | succ k ih =>
      have h2 := Susp_isDimEq (SuspIter K k) (d + k) ih
      rw [Nat.add_succ]
      exact h2

/-- Specialisation: the octahedral tower `Sᵏ(Oct n)` has dimension exactly `n + k`. -/
theorem SuspIter_Oct_isDimEq (n k : ℕ) : IsDimEq (SuspIter (Oct n) k) (n + k) :=
  SuspIter_isDimEq (Oct n) n (Oct_isDimEq n) k

/-! ### The octahedral facet enumeration -/

/-- The **orthant** of a sign vector `σ : Fin (n+1) → Bool`: pick sign `σ i` in coordinate `i`.
These are the candidate top-dimensional faces of `Oct n`. -/
def orthant (n : ℕ) (σ : Fin (n + 1) → Bool) : Finset (Fin (n + 1) × Bool) :=
  Finset.univ.image (fun i => (i, σ i))

/-- An orthant is a face of `Oct n`: it never contains an antipodal pair. -/
lemma orthant_isFace (n : ℕ) (σ : Fin (n + 1) → Bool) : (Oct n).IsFace (orthant n σ) := by
  intro i hi
  obtain ⟨h1, h2⟩ := hi
  simp only [orthant, Finset.mem_image, Finset.mem_univ, true_and, Prod.ext_iff] at h1 h2
  obtain ⟨j, hj1, hj2⟩ := h1
  obtain ⟨k, hk1, hk2⟩ := h2
  rw [hj1] at hj2
  rw [hk1] at hk2
  rw [hj2] at hk2
  exact Bool.noConfusion hk2

/-- An orthant has exactly `n + 1` vertices. -/
lemma orthant_card (n : ℕ) (σ : Fin (n + 1) → Bool) : (orthant n σ).card = n + 1 := by
  rw [orthant, Finset.card_image_of_injective]
  · simp
  · intro a b h; exact (Prod.ext_iff.1 h).1

/-- Distinct sign vectors give distinct orthants. -/
lemma orthant_injective (n : ℕ) : Function.Injective (orthant n) := by
  intro σ τ h
  funext i
  have hi : (i, σ i) ∈ orthant n τ := by
    rw [← h]; exact Finset.mem_image.2 ⟨i, Finset.mem_univ _, rfl⟩
  simp only [orthant, Finset.mem_image, Finset.mem_univ, true_and, Prod.ext_iff] at hi
  obtain ⟨j, hj1, hj2⟩ := hi
  rw [hj1] at hj2
  exact hj2.symm

/-
**Every top face of `Oct n` is an orthant.**  A face of maximal size `n + 1` chooses exactly
one sign in each of the `n + 1` coordinates, so it equals `orthant σ` for the sign vector `σ`
recording those choices.
-/
lemma Oct_face_of_card_max (n : ℕ) {s : Finset (Fin (n + 1) × Bool)}
    (hs : (Oct n).IsFace s) (hcard : s.card = n + 1) :
    ∃ σ : Fin (n + 1) → Bool, s = orthant n σ := by
  -- Define the sign vector σ such that σ i = true if (i, true) ∈ s and σ i = false otherwise.
  set σ : Fin (n + 1) → Bool := fun i => (i, true) ∈ s;
  refine' ⟨ σ, Finset.eq_of_subset_of_card_le ( _ ) _ ⟩;
  · intro p hp;
    cases p ; simp_all +decide [ orthant ];
    cases ‹Bool› <;> simp_all +decide [ Oct ];
    · exact decide_eq_false fun h => hs _ ⟨ h, hp ⟩;
    · aesop;
  · rw [ hcard, orthant_card ]

/-- **Facet count of the octahedral sphere.**  There are exactly `2^{n+1}` top-dimensional faces
(facets) in `Oct n`, one for each sign vector `Fin (n+1) → Bool`. -/
theorem Oct_facet_count (n : ℕ) :
    ((Finset.univ : Finset (Fin (n + 1) → Bool)).image (orthant n)).card = 2 ^ (n + 1) := by
  rw [Finset.card_image_of_injective _ (orthant_injective n)]
  simp [Finset.card_univ]

/-- The facets of `Oct n` are *exactly* the orthants: a finite set is a top face iff it is an
orthant. -/
theorem Oct_facet_iff_orthant (n : ℕ) (s : Finset (Fin (n + 1) × Bool)) :
    ((Oct n).IsFace s ∧ s.card = n + 1) ↔ ∃ σ : Fin (n + 1) → Bool, s = orthant n σ := by
  constructor
  · rintro ⟨hs, hcard⟩; exact Oct_face_of_card_max n hs hcard
  · rintro ⟨σ, rfl⟩; exact ⟨orthant_isFace n σ, orthant_card n σ⟩

/-! ### Co-index and dimension climb in lockstep: the zero-defect regime -/

/-- **The octahedral tower is zero-defect.**  The tower `Sᵏ(Oct n)` simultaneously realises
co-index at least `n + k` (via an equivariant map from `Oct (n+k)`) and has dimension exactly
`n + k`.  Thus the realised co-index reaches the dimension: co-index and dimension climb in
lockstep, and the tower "wastes" no dimension — the exact opposite of the maximal-excess
regime. -/
theorem tower_coindex_dim_lockstep (n k : ℕ) :
    HasCoindGe (Oct (n + k)) (SuspIter (Oct n) k) ∧ IsDimEq (SuspIter (Oct n) k) (n + k) :=
  ⟨coind_susp_iter_Oct n k, SuspIter_Oct_isDimEq n k⟩

/-! ### An iterated Borsuk–Ulam obstruction (recalled, self-contained) -/

/-- **Combinatorial Borsuk–Ulam, base case.**  An equivariant simplicial map `Oct n → Oct 0`
forces `n = 0`. -/
theorem borsuk_ulam_base {n : ℕ} (g : EqSimpMap (Oct n) (Oct 0)) : n = 0 := by
  by_contra! hn;
  set a : Fin (n + 1) × Bool := (⟨0, Nat.zero_lt_succ _⟩, true)
  set b : Fin (n + 1) × Bool := (⟨1, Nat.succ_lt_succ (Nat.pos_of_ne_zero hn)⟩, true);
  have h_eq : g.toFun a = g.toFun b := by
    have h_eq : (Oct 0).IsFace ({g.toFun a, g.toFun b} : Finset (Fin 1 × Bool)) := by
      convert g.map_face _;
      rotate_left;
      exact { a, b };
      · intro i; aesop;
      · aesop;
    cases h : g.toFun a ; cases h' : g.toFun b ; simp_all +decide [ Oct ];
    rename_i i j k l; fin_cases i; fin_cases j; fin_cases k; fin_cases l <;> simp_all +decide ;
    · exact absurd ( h_eq 0 ) ( by simp +decide );
    · fin_cases k ; fin_cases l <;> simp_all +decide [ octFace ];
  have := g.map_face ( show ( Oct n ).IsFace { a, octAlpha n b } from ?_ );
  · convert this ( g.toFun b |>.1 ) ?_;
    have := g.map_act b; simp_all +decide [ Oct, octAlpha ] ;
    cases h : g.toFun b ; aesop;
  · intro i; by_cases hi : i = ⟨ 0, Nat.zero_lt_succ _ ⟩ <;> by_cases hi' : i = ⟨ 1, Nat.succ_lt_succ ( Nat.pos_of_ne_zero hn ) ⟩ <;> simp +decide [ *, octAlpha ] ;
    · grind;
    · lia;
    · aesop;
    · aesop

/-- **Iterated Borsuk–Ulam obstruction.**  For every `k ≥ 1`, there is no equivariant
simplicial map from the `k`-fold suspension of the `0`-sphere back onto the `0`-sphere. -/
theorem no_map_susp_tower_to_S0 {k : ℕ} (hk : 1 ≤ k) :
    IsEmpty (EqSimpMap (SuspIter (Oct 0) k) (Oct 0)) := by
  constructor
  intro g
  obtain ⟨f⟩ := coind_susp_iter_Oct 0 k
  have hbu := borsuk_ulam_base (f.comp g)
  omega

/-! ### Examples and sanity checks (PEGB compliance) -/

section Examples

-- The dimension law is a structural fact about the suspension functor:
#check @SuspIter_isDimEq
-- The facet count is an exact combinatorial certificate:
#check @Oct_facet_count

/-- `Oct 0` (the `0`-sphere) has dimension `0`. -/
example : IsDimEq (Oct 0) 0 := Oct_isDimEq 0

/-- One suspension of the `0`-sphere has dimension `1` (a combinatorial circle). -/
example : IsDimEq (SuspIter (Oct 0) 1) 1 := by
  simpa using SuspIter_Oct_isDimEq 0 1

/-- The circle `Oct 1` has exactly four facets (edges of the square). -/
example : ((Finset.univ : Finset (Fin 2 → Bool)).image (orthant 1)).card = 4 := by
  simpa using Oct_facet_count 1

/-- The tower over `Oct 2` at height `3` has dimension exactly `5`. -/
example : IsDimEq (SuspIter (Oct 2) 3) 5 := by
  simpa using SuspIter_Oct_isDimEq 2 3

end Examples

/-!
### Generalizations, boundaries, and limits

**Generalization.**  `SuspIter_isDimEq` extends the octahedral dimension count to *every* free
ℤ₂-complex carrying a well-defined dimension; the octahedral spheres are one instance
(`SuspIter_Oct_isDimEq`).  The lockstep theorem `tower_coindex_dim_lockstep` thereby measures
the *zero-excess* reference family against which the maximal-excess programme is contrasted.

**Boundary case.**  The dimension predicate `IsDimEq` deliberately requires the existence of a
top face; the void complex (only the empty face) satisfies no `IsDimEq K d` with `d ≥ 0`, so
suspension of the void complex is excluded — a genuine boundary where the "+1 per suspension"
law would otherwise be vacuous.

**Limit of the elementary method.**  `borsuk_ulam_base` obstructs maps *into* `Oct 0`; the full
octahedral Borsuk–Ulam (no equivariant map `Oct m → Oct n` for `m > n`) is the strength of the
Borsuk–Ulam/Tucker theorem and is not derivable from these single-step lemmas alone.  It is
recorded as a future direction, not proved here.
-/

end Z2SuspensionTowerDim