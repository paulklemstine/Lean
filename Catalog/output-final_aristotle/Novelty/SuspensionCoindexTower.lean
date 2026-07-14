import Mathlib

/-!
# The suspension tower of free ℤ₂-complexes and an iterated Borsuk–Ulam obstruction

This file continues the combinatorial study of **free ℤ₂-simplicial complexes** and
their **ℤ₂-co-index** under suspension.  Where the base development established the
single-step facts

* suspension raises the co-index by at least one, and
* the Borsuk–Ulam base case: there is no equivariant simplicial map from a sphere
  onto the `0`-sphere `S⁰`,

the present file iterates the construction.  We define the **`k`-fold suspension
tower** `Suspⁱ K` of a free ℤ₂-complex `K`, prove that `k` suspensions raise the
co-index by at least `k` (`coind_suspension_iter`), pin the dimension of the tower
over an octahedral sphere on the nose (`SuspIter_Oct_dim_lower`,
`SuspIter_Oct_dim_upper`), and combine these with the base case to obtain a genuine
**iterated Borsuk–Ulam obstruction**: for every `k ≥ 1` there is no equivariant
simplicial map from the `k`-fold suspension of `S⁰` back down to `S⁰`
(`no_map_susp_tower_to_S0`).

## The model (recalled)

A *free ℤ₂-complex* on a vertex type `V` is a downward-closed family of finite
faces together with a fixed-point-free, face-preserving involution `α`.  The
guiding example is the *octahedral `n`-sphere* `Oct n` (the boundary of the
`(n+1)`-cross-polytope), a triangulation of `Sⁿ`.  A *ℤ₂-simplicial map*
`EqSimpMap K L` commutes with the involutions and carries faces to faces; the
co-index lower-bound predicate `HasCoindGe (Oct n) K` asserts the existence of such
a map from the `n`-sphere into `K`.

## Main results

* `SuspIter` — the `k`-fold suspension of a free ℤ₂-complex, a free ℤ₂-complex on the
  iterated sum type `SuspVtx V k`.
* `coind_suspension_iter` — **`k` suspensions raise the co-index by at least `k`**:
  `HasCoindGe (Oct m) K → HasCoindGe (Oct (m+k)) (Suspⁱ K)`.
* `coind_susp_iter_Oct` — the tower over the `n`-sphere realises co-index `n+k`.
* `SuspIter_Oct_dim_lower`, `SuspIter_Oct_dim_upper` — the tower over `Sⁿ` has a face
  of size `n+1+k` and no larger face, so its dimension is exactly `n+k`, matching the
  co-index and the topological identity `Sⁿ⁺ᵏ ≅ Sᵏ(Sⁿ)`.
* `no_map_susp_tower_to_S0` — **iterated Borsuk–Ulam**: for `k ≥ 1` there is no
  equivariant simplicial map from the `k`-fold suspension of `S⁰` to `S⁰`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): If a single suspension adds at least one to the co-index,
then `k` suspensions should add at least `k`, and the suspension tower over `Sⁿ`
should be indistinguishable from `Sⁿ⁺ᵏ` at the level of co-index *and* dimension.
Iterating the Borsuk–Ulam base case should then forbid the tower from mapping back
down onto `S⁰` — a discrete shadow of the fact that a high-dimensional sphere admits
no odd map to `S⁰`.

Experiment (Experimenter): Introduce the iterated vertex type `SuspVtx V k` and the
tower `SuspIter K k`, prove functorial co-index growth by induction on `k`, track the
top-face cardinality up and down through a single suspension, and compose the tower
map `Oct (0+k) → Suspⁱ(S⁰)` with a hypothetical retraction to `S⁰` to invoke the base
case.

Analysis (Analyst): The co-index growth and the iterated obstruction are *formal*
consequences of the single-step lemmas — this is the "easy", constructive half.  The
dimension upper bound is the only genuinely new estimate: a face of a suspension
contains at most one of the two apexes, so cardinality grows by exactly one per
suspension.  The matching lower and upper dimension bounds certify that the tower is
"co-index efficient": it wastes no dimension, so the excess `coind − dim` stays `0`
all the way up — the exact opposite regime from the maximal-excess conjecture, and a
useful control against which excess must be measured.

Critique (Critic): The dependent iterated sum type `SuspVtx` must carry decidable
equality at every level or the suspension face predicate is ill-formed; this is
supplied by a recursive instance.  The obstruction is non-vacuous precisely because
the tower genuinely realises co-index `k ≥ 1`, so `no_map_susp_tower_to_S0` is not an
empty statement about an unreachable complex.  No `sorry` remains.

Synthesis (PI): The suspension tower gives the "zero-excess" reference family for the
maximal-excess programme and upgrades the Borsuk–Ulam base case from spheres to
arbitrary suspension towers over `S⁰`, tightening the bridge between combinatorial
co-index and the topological Borsuk–Ulam obstruction.
-/

namespace SuspensionCoindexTower

open Finset

/-! ### The free ℤ₂-complex model (recalled) -/

/-- A **free ℤ₂-simplicial complex** on vertex type `V`: an abstract simplicial
complex together with a fixed-point-free, face-preserving involution `α`. -/
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

/-- A **ℤ₂-simplicial map** between free ℤ₂-complexes: a vertex map commuting with
the involutions and carrying faces to faces. -/
structure EqSimpMap {V W : Type*} [DecidableEq V] [DecidableEq W]
    (K : Z2Complex V) (L : Z2Complex W) where
  toFun : V → W
  map_act : ∀ v, toFun (K.α v) = L.α (toFun v)
  map_face : ∀ {s : Finset V}, K.IsFace s → L.IsFace (s.image toFun)

/-- The co-index lower-bound predicate: `HasCoindGe (Oct n) K` means there is an
equivariant simplicial map from the octahedral `n`-sphere into `K`. -/
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

/-! ### Suspension `S(K) = K * S⁰` (recalled) -/

/-- Antipodal map of the suspension: `α` on the base, `Bool` flip on the two apexes. -/
def suspAlpha {V : Type*} [DecidableEq V] (K : Z2Complex V) : V ⊕ Bool → V ⊕ Bool :=
  Sum.map K.α (fun b => !b)

/-- Face predicate of the suspension `K * S⁰`: the base part is a face of `K` and the
two apex points are never joined. -/
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

/-! ### The combinatorial homeomorphism `Sⁿ⁺¹ ≅ S(Sⁿ)` (recalled) -/

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

/-! ### Dimension bookkeeping for a single suspension (recalled / new) -/

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

/-
Inserting an apex into the image of a base face adds exactly one vertex.
-/
lemma Susp_face_full_card {V : Type*} [DecidableEq V]
    {s : Finset V} :
    (insert (Sum.inr true) (s.image (Sum.inl : V → V ⊕ Bool))).card = s.card + 1 := by
  rw [ Finset.card_insert_of_notMem ] <;> simp +decide [ Finset.card_image_of_injective, Function.Injective ]

/-
**A single suspension raises the maximal face size by at most one.**  A face of
`Susp K` contains at most one apex, and its base part is a face of `K`.
-/
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

/-- **Dimension of the tower, lower bound.**  The `k`-fold suspension of `Sⁿ` has a
face of cardinality `n + 1 + k`, so its dimension is at least `n + k`. -/
theorem SuspIter_Oct_dim_lower (n k : ℕ) :
    ∃ s : Finset (SuspVtx (Fin (n + 1) × Bool) k),
      (SuspIter (Oct n) k).IsFace s ∧ s.card = n + 1 + k := by
  induction k with
  | zero =>
      show ∃ s : Finset (Fin (n + 1) × Bool), (Oct n).IsFace s ∧ s.card = n + 1 + 0
      exact ⟨Finset.univ.image (fun i : Fin (n + 1) => (i, true)), Oct_face_full n,
        by simpa using Oct_face_full_card n⟩
  | succ k ih =>
      obtain ⟨s, hface, hcard⟩ := ih
      refine ⟨insert (Sum.inr true) (s.image Sum.inl), Susp_face_full _ hface, ?_⟩
      rw [Susp_face_full_card, hcard]; omega

/-- **Dimension of the tower, upper bound.**  Every face of the `k`-fold suspension of
`Sⁿ` has at most `n + 1 + k` vertices, so its dimension is at most `n + k`. -/
theorem SuspIter_Oct_dim_upper (n k : ℕ)
    {s : Finset (SuspVtx (Fin (n + 1) × Bool) k)}
    (hs : (SuspIter (Oct n) k).IsFace s) : s.card ≤ n + 1 + k := by
  induction k with
  | zero => exact Oct_face_card_le n hs
  | succ k ih =>
      have h := Susp_face_card_le (SuspIter (Oct n) k) (n + 1 + k)
        (fun {t} ht => ih ht) hs
      omega

/-! ### An iterated Borsuk–Ulam obstruction -/

/-- **Combinatorial Borsuk–Ulam, base case.**  An equivariant simplicial map
`Oct n → Oct 0` forces `n = 0`. -/
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
simplicial map from the `k`-fold suspension of the `0`-sphere back onto the
`0`-sphere.  Because the tower `Suspⁱ(S⁰)` genuinely realises co-index `k`, such a
retraction would compose with the tower map `Oct k → Suspⁱ(S⁰)` to give an
equivariant map `Oct k → S⁰`, contradicting the Borsuk–Ulam base case. -/
theorem no_map_susp_tower_to_S0 {k : ℕ} (hk : 1 ≤ k) :
    IsEmpty (EqSimpMap (SuspIter (Oct 0) k) (Oct 0)) := by
  constructor
  intro g
  obtain ⟨f⟩ := coind_susp_iter_Oct 0 k
  have hbu := borsuk_ulam_base (f.comp g)
  omega

end SuspensionCoindexTower