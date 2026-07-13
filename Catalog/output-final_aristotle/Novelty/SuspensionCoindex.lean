import Mathlib

/-!
# Co-index of free ℤ₂-complexes under suspension

This file develops a self-contained combinatorial theory of **free ℤ₂-simplicial
complexes** and their **ℤ₂-co-index**, aimed at the Simonyi–Tardos–Vrécica circle
of questions on how the co-index of a free ℤ₂-space behaves under the (unreduced)
suspension operation `S(K) = K * S⁰`.

## The model

A *free ℤ₂-complex* on a vertex type `V` is an abstract simplicial complex
(`IsFace : Finset V → Prop`, downward closed, containing `∅`) equipped with a
fixed-point-free involution `α : V → V` that carries faces to faces.  The guiding
example is the boundary of the `(n+1)`-dimensional cross-polytope (the
*octahedral `n`-sphere* `Oct n`): its vertices are the `2(n+1)` points
`Fin (n+1) × Bool`, the antipodal map flips the `Bool` coordinate, and a set of
vertices spans a face iff it contains no antipodal pair.  Geometrically `Oct n`
triangulates `Sⁿ`.

A *ℤ₂-simplicial map* `EqSimpMap K L` is a vertex map commuting with the two
involutions and sending faces to faces.  The **co-index** is captured by the
predicate

  `HasCoindGe (Oct n) K  :≡  Nonempty (EqSimpMap (Oct n) K)`,

read "the co-index of `K` is at least `n`": there is an equivariant simplicial map
from the `n`-sphere into `K`.  (This is the combinatorial, subdivision-free lower
bound for the topological ℤ₂-co-index.)

## Main results

* `EqSimpMap.comp`, `EqSimpMap.id` — the category of free ℤ₂-complexes.
* `Susp_iso_Oct` — the suspension of the octahedral `n`-sphere is realised by an
  explicit equivariant map from the octahedral `(n+1)`-sphere: `Oct (n+1) → S(Oct n)`
  (the combinatorial `Sⁿ⁺¹ ≅ S(Sⁿ)`).
* `coind_suspension` — **suspension raises the co-index by at least one**:
  `HasCoindGe (Oct m) K → HasCoindGe (Oct (m+1)) (S K)`.  This is the constructive
  heart of the sharp-excess programme.
* `coind_Oct_self` — `HasCoindGe (Oct n) (Oct n)` (the identity map), so the
  octahedral tower realises every co-index.
* `borsuk_ulam_base` — a genuine combinatorial Borsuk–Ulam instance: an equivariant
  simplicial map `Oct n → Oct 0` forces `n = 0`, i.e. the co-index of `S⁰` is `0`.
* dimension bookkeeping: `Oct_face_full`, `Oct_face_card_le` pin the dimension of
  `Oct n` to `n`, and `Susp_face_full` shows suspension raises dimension by one.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The upper bound `coind(S(K)) ≤ dim(K)+1` from the
Simonyi–Tardos–Vrécica programme should be *sharp for every feasible starting
co-index* `1 ≤ c ≤ d`.  The paper handles `c = 1`; the bold conjecture is maximal
excess `d - c` for all `c`.  A first, unconditional test of the machinery is the
*lower* half: suspension never loses co-index and in fact adds at least one, and
the octahedral tower realises the diagonal `coind = dim`.

Experiment (Experimenter): Formalise free ℤ₂-complexes, the octahedral spheres, the
join-with-`S⁰` suspension, equivariant simplicial maps, and prove (i) suspension is
functorial, (ii) `Oct (n+1)` maps equivariantly onto `S(Oct n)`, (iii) hence
`HasCoindGe (Oct m) K → HasCoindGe (Oct (m+1)) (S K)`, and (iv) the Borsuk–Ulam base
case `Oct n ↛ Oct 0` for `n ≥ 1`.

Analysis (Analyst): The constructive suspension lemma yields excess exactly `+1`;
the *large* jump `d + 1 - c > 1` in the sharp-excess conjecture is genuinely
deeper — it needs an equivariant map that "sees" the extra apex directions all at
once, not just one suspension coordinate.  The base case shows the framework already
detects the Borsuk–Ulam obstruction (no dimension-dropping equivariant map from a
sphere), which is exactly the phenomenon the upper bound `coind ≤ dim` rests on.

Critique (Critic): Freeness (`α` fixed-point-free, faces antipodal-pair-free) is
load-bearing: without it the Borsuk–Ulam base case is false (a constant map would
exist).  The suspension face predicate must forbid the apex antipodal pair
`{N, S}`, matching `S⁰` having two *disjoint* points.  All main theorems are
proved with no `sorry`.

Synthesis (PI): This is a *cross-domain bridge* entry (combinatorics ↔ equivariant
topology / Borsuk–Ulam, cf. the catalog's Lovász box-complex and Borsuk–Ulam
references).  It provides the verified lower-bound half and Borsuk–Ulam base case of
the maximal-excess programme; the large-jump construction is recorded as the central
future direction.
-/

namespace SuspensionCoindex

open Finset

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

/-
The antipodal image of an octahedral face is again a face.
-/
lemma octFace_symm (n : ℕ) {s : Finset (Fin (n + 1) × Bool)} (hs : octFace n s) :
    octFace n (s.image (octAlpha n)) := by
  intro i hi; simp_all +decide [ octFace, octAlpha ] ;
  tauto

/-- The **octahedral `n`-sphere**: the boundary of the `(n+1)`-cross-polytope.
Vertices are `Fin (n+1) × Bool`, the antipodal map flips the `Bool` coordinate, and
a vertex set is a face iff it contains no antipodal pair.  Geometrically `Sⁿ`. -/
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

/-- Face predicate of the suspension `K * S⁰`: the base part is a face of `K` and the
two apex points (the two points of `S⁰`) are never joined. -/
def suspFace {V : Type*} [DecidableEq V] (K : Z2Complex V) (T : Finset (V ⊕ Bool)) : Prop :=
  K.IsFace (T.preimage Sum.inl (Sum.inl_injective.injOn)) ∧
    ¬ (Sum.inr true ∈ T ∧ Sum.inr false ∈ T)

/-
The antipodal image of a suspension face is again a face.
-/
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

/-- The **(unreduced) suspension** `S K = K * S⁰`.  Two apex vertices `inr true`,
`inr false` are added, swapped by the involution; a set spans a face iff its base
part is a face of `K` and it does not contain both apexes. -/
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

/-
Suspending a ℤ₂-simplicial map carries suspension faces to suspension faces.
-/
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

/-- The vertex map `Oct (n+1) → S(Oct n)`: the last coordinate becomes the suspension
apex, the other coordinates stay in the base. -/
def suspIsoOctFun (n : ℕ) : Fin (n + 2) × Bool → (Fin (n + 1) × Bool) ⊕ Bool :=
  fun p => if h : (p.1 : ℕ) < n + 1 then Sum.inl (⟨p.1, h⟩, p.2) else Sum.inr p.2

/-
The connecting map is equivariant.
-/
lemma suspIsoOct_act (n : ℕ) (p : Fin (n + 2) × Bool) :
    suspIsoOctFun n (octAlpha (n + 1) p) = suspAlpha (Oct n) (suspIsoOctFun n p) := by
  unfold suspIsoOctFun octAlpha suspAlpha Oct;
  split_ifs <;> simp_all +decide [ octAlpha ]

/-
The connecting map is simplicial.
-/
lemma suspIsoOct_face (n : ℕ) {s : Finset (Fin (n + 2) × Bool)} (hs : octFace (n + 1) s) :
    suspFace (Oct n) (s.image (suspIsoOctFun n)) := by
  constructor;
  · intro i hi;
    simp_all +decide [ suspIsoOctFun ];
    grind +locals;
  · grind +locals

/-- The explicit equivariant simplicial map `Oct (n+1) → S(Oct n)` realising the
classical homeomorphism `Sⁿ⁺¹ ≅ S(Sⁿ)`. -/
def Susp_iso_Oct (n : ℕ) : EqSimpMap (Oct (n + 1)) (Susp (Oct n)) where
  toFun := suspIsoOctFun n
  map_act := suspIsoOct_act n
  map_face := fun hs => suspIsoOct_face n hs

/-- **Suspension raises the co-index by at least one.**  If there is an equivariant
simplicial map from `Sⁿ` into `K`, then there is one from `Sⁿ⁺¹` into `S(K)`. -/
theorem coind_suspension {W : Type*} [DecidableEq W]
    {K : Z2Complex W} {m : ℕ} (h : HasCoindGe (Oct m) K) :
    HasCoindGe (Oct (m + 1)) (Susp K) := by
  obtain ⟨g⟩ := h
  exact ⟨(Susp_iso_Oct m).comp g.susp⟩

/-- Corollary: the suspension of the `n`-sphere has co-index at least `n+1`
(matching the topological `coind(Sⁿ⁺¹) = n+1`). -/
theorem coind_susp_Oct (n : ℕ) : HasCoindGe (Oct (n + 1)) (Susp (Oct n)) :=
  coind_suspension (coind_Oct_self n)

/-! ### Dimension bookkeeping -/

/-
The "positive orthant" `{(i, true) : i}` is an `n`-dimensional face of `Oct n`.
-/
lemma Oct_face_full (n : ℕ) :
    (Oct n).IsFace (Finset.univ.image (fun i : Fin (n + 1) => (i, true))) := by
  exact fun i => by aesop;

/-
Every face of `Oct n` has at most `n+1` vertices: `dim (Oct n) ≤ n`.
-/
lemma Oct_face_card_le (n : ℕ) {s : Finset (Fin (n + 1) × Bool)}
    (hs : (Oct n).IsFace s) : s.card ≤ n + 1 := by
  have h_inj : ∀ p q : Fin (n + 1) × Bool, p ∈ s → q ∈ s → p.1 = q.1 → p = q := by
    simp +zetaDelta at *;
    exact fun i => ⟨ fun j hj₁ hj₂ hij => hs i ⟨ by aesop, by aesop ⟩, fun j hj₁ hj₂ hij => hs i ⟨ by aesop, by aesop ⟩ ⟩;
  convert Finset.card_le_card ( show s.image Prod.fst ⊆ Finset.univ from Finset.subset_univ _ ) using 1 ; rw [ Finset.card_image_of_injOn fun p hp q hq hpq => h_inj p q hp hq hpq ] ; simp +decide [ Finset.card_univ ] ;

/-
Suspension raises the maximal face size by one: from a top face of `K` together
with an apex we obtain a face of `S K` with one more vertex.
-/
lemma Susp_face_full {V : Type*} [DecidableEq V] (K : Z2Complex V)
    {s : Finset V} (hs : K.IsFace s) :
    (Susp K).IsFace (insert (Sum.inr true) (s.image Sum.inl)) := by
  constructor;
  · convert hs using 1;
    ext; simp [Finset.mem_image];
  · grind

/-! ### Borsuk–Ulam base case: the co-index of `S⁰` is `0` -/

/-
**Combinatorial Borsuk–Ulam, base case.**  There is no equivariant simplicial map
from the `n`-sphere to the `0`-sphere for `n ≥ 1`: the co-index of `S⁰ = Oct 0` is
exactly `0`.  Equivalently, an equivariant simplicial map `Oct n → Oct 0` forces
`n = 0`.
-/
theorem borsuk_ulam_base {n : ℕ} (g : EqSimpMap (Oct n) (Oct 0)) : n = 0 := by
  by_contra! hn;
  -- Let $a = (0, true)$ and $b = (1, true)$ be two distinct vertices in $Oct n$.
  set a : Fin (n + 1) × Bool := (⟨0, Nat.zero_lt_succ _⟩, true)
  set b : Fin (n + 1) × Bool := (⟨1, Nat.succ_lt_succ (Nat.pos_of_ne_zero hn)⟩, true);
  -- By equivariance, $g(a) = g(b)$.
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

end SuspensionCoindex